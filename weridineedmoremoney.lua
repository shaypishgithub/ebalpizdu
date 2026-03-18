-- MEGAHACK | Redesigned GUI + Sequential Enemy TP
-- ============================================================

local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local Players            = game:GetService("Players")
local LocalPlayer        = Players.LocalPlayer
local Workspace          = game:GetService("Workspace")
local Camera             = Workspace.CurrentCamera
local PathfindingService = game:GetService("PathfindingService")

-- ============================================================
--  SETTINGS
-- ============================================================
local Settings = {
    -- Aimbot
    AimbotOn       = false,
    AutoAimbotOn   = false,
    ShowFOV        = true,
    TeamCheck      = true,
    LockRadius     = 100,
    FOVColor       = Color3.fromRGB(200, 30, 30),
    WallbangOn     = false,

    -- ESP
    ESPOn             = true,
    UseTeamColors     = false,
    OwnTeamColor      = Color3.fromRGB(0, 100, 255),
    OpponentTeamColor = Color3.fromRGB(255, 50, 50),

    -- Gun Mods
    InstantReload = false,
    InfiniteAmmo  = false,
    NoRecoil      = false,
    NoSpread      = false,
    FastShoot     = false,

    -- Character
    WalkspeedOn    = false,
    WalkspeedValue = 50,
    HipHeightOn    = false,
    HipHeightValue = 25,
    AutoBhopOn     = false,
    AirWalkOn      = false,
    SpinbotOn      = false,
    SpinbotSpeed   = 5,
    AIbotOn        = false,

    -- Teleport
    AutoTPOn     = false,
    TPToSafeZone = false,
    EnemyTPOn    = false,   -- NEW: Sequential Enemy TP

    -- KOTH
    KOTHZone = nil,
}

-- ============================================================
--  LOGIC VARIABLES
-- ============================================================
local targetList    = {{Name = "Head", Label = "Player"}}
local createdESPs   = {}
local currentTarget = nil
local tpTween       = nil
local lastFire      = 0
local fireCooldown  = 0.1
local safeZonePos   = Vector3.new(0, 100, 0)
local spinAngle     = 0
local lastKillTime  = 0
local KOTHZones     = {A=nil,B=nil,C=nil,D=nil,E=nil,F=nil,G=nil,H=nil}
local pathCoroutine = nil
local currentEnemy  = nil
local diedConnection= nil
local enemyTPThread = nil
local lockOn        = false

-- ============================================================
--  LOGIC FUNCTIONS
-- ============================================================

local function isTeamGame()
    local teams = {}
    for _, p in pairs(Players:GetPlayers()) do teams[p.Team or "NIL"] = true end
    local n = 0; for _ in pairs(teams) do n += 1 end
    return n > 1
end

local function createESP(target)
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if player == LocalPlayer or not player then return end
    local col = Settings.UseTeamColors and player.TeamColor.Color
        or (player.Team == LocalPlayer.Team and Settings.OwnTeamColor or Settings.OpponentTeamColor)
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESPBillboard"; bb.Adornee = target; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 100, 0, 100); bb.Parent = target
    table.insert(createdESPs, bb)
    local dot = Instance.new("Frame", bb)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = col
    dot.Position = UDim2.new(0.5, 0, 0.5, 0)
    dot.Size = UDim2.new(0, 5, 0, 5)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", dot).Thickness = 2.5
    local lbl = Instance.new("TextLabel", bb)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 0, 0.5, 12)
    lbl.Size = UDim2.new(1, 0, 0.1, 0)
    lbl.Text = player.Name; lbl.TextColor3 = col; lbl.TextScaled = true
    lbl.TextStrokeTransparency = 0.8; lbl.TextStrokeColor3 = Color3.new()
    if target.Parent and target.Parent:FindFirstChild("Humanoid") then
        target.Parent.Humanoid.Died:Connect(function()
            bb:Destroy()
            for i, e in ipairs(createdESPs) do
                if e == bb then table.remove(createdESPs, i); break end
            end
            if currentTarget == player then currentTarget = nil end
        end)
    end
end

local function removeAllESPs()
    for _, e in ipairs(createdESPs) do e:Destroy() end
    createdESPs = {}
end

local function scanAndApplyESP()
    if not Settings.ESPOn then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            for _, t in ipairs(targetList) do
                if obj.Name == t.Name then createESP(obj) end
            end
        end
    end
end

local function getNearestPlayer()
    local best, bestD = nil, Settings.LockRadius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local sp, onS = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if (onS or Settings.WallbangOn) and d < bestD then bestD = d; best = p end
            end
        end
    end
    return best
end

local function getAllEnemies()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then table.insert(list, p) end
        end
    end
    return list
end

local function getEnemyBehind()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local dir = (p.Character.HumanoidRootPart.Position - myRoot.Position).Unit
                if myRoot.CFrame.LookVector:Dot(dir) < -0.5 then return p end
            end
        end
    end
    return nil
end

local function getRandomEnemy()
    local list = getAllEnemies()
    return #list > 0 and list[math.random(1, #list)] or nil
end

local function fireGun()
    local now = tick()
    if now - lastFire < fireCooldown then return end
    lastFire = now
    local char = LocalPlayer.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
    for _, rem in ipairs(tool:GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            local nl = rem.Name:lower()
            if nl:find("fire") or nl:find("shoot") or nl:find("bullet") then
                pcall(function() rem:FireServer() end); break
            end
        end
    end
end

local function reloadGun()
    local char = LocalPlayer.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
    for _, rem in ipairs(tool:GetDescendants()) do
        if rem:IsA("RemoteEvent") and rem.Name:lower():find("reload") then
            pcall(function() rem:FireServer() end); break
        end
    end
end

local function equipGun()
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChild("Humanoid"); if not hum then return end
    if char:FindFirstChildOfClass("Tool") then return end
    local gun = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if gun then hum:EquipTool(gun) end
end

local function moveToEnemy(enemy)
    if not LocalPlayer.Character then return end
    local hum  = LocalPlayer.Character:FindFirstChild("Humanoid")
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local eRoot = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not eRoot then return end
    if pathCoroutine then coroutine.close(pathCoroutine); pathCoroutine = nil end
    pathCoroutine = coroutine.create(function()
        local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true, Costs={NonPathable=math.huge}})
        local ok = pcall(function() path:ComputeAsync(root.Position, eRoot.Position) end)
        if ok and path.Status == Enum.PathStatus.Success then
            for _, wp in ipairs(path:GetWaypoints()) do
                if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                hum:MoveTo(wp.Position); hum.MoveToFinished:Wait()
            end
        else hum:MoveTo(eRoot.Position) end
    end)
    coroutine.resume(pathCoroutine)
end

local function startAutoTP()
    if not Settings.AutoTPOn then return end
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid")
        and currentTarget.Character.Humanoid.Health > 0 then return end
    currentTarget = getRandomEnemy()
    if not currentTarget then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local eRoot = currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart"); if not eRoot then return end
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root, TweenInfo.new(5, Enum.EasingStyle.Linear),
        {CFrame = CFrame.lookAt(eRoot.Position + Vector3.new(0, 5, 0), eRoot.Position)})
    tpTween:Play()
end

local function teleportToSafeZone()
    if not Settings.TPToSafeZone then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root, TweenInfo.new(5, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(safeZonePos + Vector3.new(0, 50, 0))})
    tpTween:Play()
end

local function teleportToKOTHZone(zone)
    if not zone then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local zp = Workspace:FindFirstChild(zone); if not zp then return end
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root, TweenInfo.new(5, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(zp.Position + Vector3.new(0, 50, 0))})
    tpTween:Play()
end

local function findKOTHZones()
    for zone in pairs(KOTHZones) do
        local p = Workspace:FindFirstChild(zone)
        if p then KOTHZones[zone] = p end
    end
end

local function findAndSetAmmo(gun)
    if not gun then return end
    for _, c in ipairs(gun:GetDescendants()) do
        if c:IsA("IntValue") or c:IsA("NumberValue") then
            local nl = c.Name:lower()
            if nl:find("ammo") or nl:find("magazine") or nl:find("clip") or nl:find("bullet") then
                c.Value = math.huge
            end
        end
    end
    for _, a in ipairs({"magazineSize","ammo","maxAmmo","currentAmmo","reserveAmmo"}) do
        pcall(function() gun:SetAttribute(a, math.huge) end)
    end
    gun.DescendantAdded:Connect(function(d)
        if d:IsA("IntValue") or d:IsA("NumberValue") then
            local nl = d.Name:lower()
            if nl:find("ammo") or nl:find("magazine") or nl:find("clip") or nl:find("bullet") then
                d.Value = math.huge
            end
        end
    end)
end

local function autoBhop()
    if not Settings.AutoBhopOn then return end
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChild("Humanoid"); if not hum then return end
    if hum:GetState() == Enum.HumanoidStateType.Running then hum.Jump = true end
end

local function airWalk()
    if not Settings.AirWalkOn then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0); bv.Velocity = Vector3.zero; bv.Parent = root
    game.Debris:AddItem(bv, 0.1)
end

local function spinbot()
    if not Settings.SpinbotOn then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local t = getNearestPlayer(); if not t then return end
    local torso = t.Character:FindFirstChild("Torso") or t.Character:FindFirstChild("UpperTorso")
    if not torso then return end
    spinAngle += Settings.SpinbotSpeed
    local tp = torso.Position
    local np = tp + Vector3.new(math.cos(math.rad(spinAngle)) * 10, 0, math.sin(math.rad(spinAngle)) * 10)
    TweenService:Create(root, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CFrame = CFrame.new(np, tp)}):Play()
end

local function aIbot()
    if not Settings.AIbotOn then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local hum  = char:FindFirstChild("Humanoid"); if not hum then return end
    equipGun()
    local tool = char:FindFirstChildOfClass("Tool")
    local behind = getEnemyBehind()
    if behind and behind.Character and behind.Character:FindFirstChild("Head") then
        local tp = behind.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tp)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(tp.X, root.Position.Y, tp.Z))
        if tool then fireGun() end; return
    end
    local nearest = getNearestPlayer()
    if nearest and nearest.Character and nearest.Character:FindFirstChild("Head") and nearest.Character:FindFirstChild("Humanoid") then
        local tp = nearest.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tp)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(tp.X, root.Position.Y, tp.Z))
        moveToEnemy(nearest)
        if tool then fireGun() end
        if nearest ~= currentEnemy then
            if diedConnection then diedConnection:Disconnect() end
            currentEnemy = nearest
            diedConnection = nearest.Character.Humanoid.Died:Connect(function()
                if tick() - lastKillTime > 1 then
                    lastKillTime = tick()
                    if tool then reloadGun() end
                end
            end)
        end
    end
end

-- NEW: Sequential Enemy Teleport
-- Teleports to each enemy → shoots 6s → waits 10s → next target
local function startEnemyTP()
    if enemyTPThread then task.cancel(enemyTPThread); enemyTPThread = nil end
    if not Settings.EnemyTPOn then return end
    enemyTPThread = task.spawn(function()
        while Settings.EnemyTPOn do
            local enemies = getAllEnemies()
            if #enemies == 0 then task.wait(3); continue end
            for _, enemy in ipairs(enemies) do
                if not Settings.EnemyTPOn then break end
                if not enemy.Character or not enemy.Character:FindFirstChild("HumanoidRootPart") then continue end
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then break end
                -- Teleport behind enemy
                local eRoot = enemy.Character.HumanoidRootPart
                root.CFrame = eRoot.CFrame * CFrame.new(0, 2, 4)
                -- Shoot for 6 seconds
                local t0 = tick()
                while tick() - t0 < 6 and Settings.EnemyTPOn do
                    char = LocalPlayer.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root or not enemy.Character or not enemy.Character:FindFirstChild("Head") then break end
                    local hp = enemy.Character.Head.Position
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, hp)
                    root.CFrame = CFrame.lookAt(root.Position, Vector3.new(hp.X, root.Position.Y, hp.Z))
                    equipGun(); fireGun()
                    task.wait(0.08)
                end
                -- Wait 10 seconds before next target
                local t1 = tick()
                while tick() - t1 < 10 and Settings.EnemyTPOn do task.wait(0.5) end
            end
        end
    end)
end

-- ============================================================
--  GUI COLORS
-- ============================================================
local C_ACCENT  = Color3.fromRGB(200, 28, 28)
local C_BG      = Color3.fromRGB(10, 10, 10)
local C_SIDEBAR = Color3.fromRGB(16, 16, 16)
local C_ROW     = Color3.fromRGB(22, 22, 22)
local C_ROW_H   = Color3.fromRGB(38, 10, 10)
local C_TEXT    = Color3.fromRGB(218, 218, 218)
local C_DIM     = Color3.fromRGB(105, 105, 105)
local C_ON      = Color3.fromRGB(190, 25, 25)
local C_OFF     = Color3.fromRGB(48, 48, 48)
local C_WHITE   = Color3.fromRGB(255, 255, 255)

-- ============================================================
--  SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Megahack"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- FOV Circle
local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size = UDim2.new(0, Settings.LockRadius * 2, 0, Settings.LockRadius * 2)
RadiusFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
RadiusFrame.AnchorPoint = Vector2.new(0.5, 0.5)
RadiusFrame.BackgroundTransparency = 1
RadiusFrame.Visible = Settings.ShowFOV
RadiusFrame.ZIndex = 5
RadiusFrame.Parent = ScreenGui
Instance.new("UICorner", RadiusFrame).CornerRadius = UDim.new(1, 0)
local FOVS = Instance.new("UIStroke", RadiusFrame)
FOVS.Thickness = 1.5; FOVS.Color = C_ACCENT; FOVS.Transparency = 0.25

-- ============================================================
--  TOGGLE PILL (top-left open button)
-- ============================================================
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
OpenBtn.Size = UDim2.new(0, 90, 0, 30)
OpenBtn.Position = UDim2.new(0, 14, 0, 14)
OpenBtn.Text = "MEGAHACK"
OpenBtn.TextColor3 = C_ACCENT
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 11
OpenBtn.AutoButtonColor = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)
local OBS = Instance.new("UIStroke", OpenBtn)
OBS.Color = C_ACCENT; OBS.Transparency = 0.35; OBS.Thickness = 1

do -- drag open button
    local drag, ds, sp = false, nil, nil
    OpenBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = OpenBtn.Position
        end
    end)
    OpenBtn.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement and drag then
            local d = i.Position - ds
            OpenBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ============================================================
--  MAIN FRAME
-- ============================================================
local MF = Instance.new("Frame")
MF.Parent = ScreenGui
MF.BackgroundColor3 = C_BG
MF.Size = UDim2.new(0, 530, 0, 420)
MF.Position = UDim2.new(0.5, -265, 0.5, -210)
MF.Visible = false
MF.ClipsDescendants = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 8)
local MFS = Instance.new("UIStroke", MF)
MFS.Color = C_ACCENT; MFS.Transparency = 0.4; MFS.Thickness = 1.5

OpenBtn.MouseButton1Click:Connect(function() MF.Visible = not MF.Visible end)

do -- drag main frame
    local drag, ds, sp = false, nil, nil
    MF.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = MF.Position
        end
    end)
    MF.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement and drag then
            local d = i.Position - ds
            MF.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ============================================================
--  TITLE BAR
-- ============================================================
local TBar = Instance.new("Frame", MF)
TBar.BackgroundColor3 = C_SIDEBAR
TBar.Size = UDim2.new(1, 0, 0, 44)
TBar.Position = UDim2.new(0, 0, 0, 0)
TBar.BorderSizePixel = 0
Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 8)
-- fill bottom corners of title bar
local TBFill = Instance.new("Frame", TBar)
TBFill.BackgroundColor3 = C_SIDEBAR
TBFill.Size = UDim2.new(1, 0, 0, 10)
TBFill.Position = UDim2.new(0, 0, 1, -10)
TBFill.BorderSizePixel = 0

local TTitle = Instance.new("TextLabel", TBar)
TTitle.BackgroundTransparency = 1
TTitle.Size = UDim2.new(1, 0, 1, 0)
TTitle.Text = "MEGAHACK"
TTitle.TextColor3 = C_WHITE
TTitle.Font = Enum.Font.GothamBold
TTitle.TextSize = 16
TTitle.LetterSpacing = 6

-- Red accent line below title
local AccentLine = Instance.new("Frame", MF)
AccentLine.BackgroundColor3 = C_ACCENT
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 44)
AccentLine.BorderSizePixel = 0

-- ============================================================
--  SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame", MF)
Sidebar.BackgroundColor3 = C_SIDEBAR
Sidebar.Size = UDim2.new(0, 130, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BorderSizePixel = 0
-- right border
local SBR = Instance.new("Frame", Sidebar)
SBR.BackgroundColor3 = C_ACCENT; SBR.BackgroundTransparency = 0.6
SBR.Size = UDim2.new(0, 1, 1, 0); SBR.Position = UDim2.new(1, 0, 0, 0)
SBR.BorderSizePixel = 0

-- ============================================================
--  CONTENT AREA
-- ============================================================
local Content = Instance.new("Frame", MF)
Content.BackgroundTransparency = 1
Content.Size = UDim2.new(1, -138, 1, -56)
Content.Position = UDim2.new(0, 134, 0, 52)

-- ============================================================
--  TAB INFRASTRUCTURE
-- ============================================================
local TabList    = {"Aimbot", "ESP", "Gun Mods", "Character", "Teleport", "KOTH"}
local CurrentTab = "Aimbot"
local NavBtns    = {}
local TabFrames  = {}

-- Build sidebar nav + scrolling frames
for i, name in ipairs(TabList) do
    local isActive = name == CurrentTab

    local NB = Instance.new("TextButton", Sidebar)
    NB.BackgroundColor3 = Color3.fromRGB(36, 9, 9)
    NB.BackgroundTransparency = isActive and 0 or 1
    NB.Size = UDim2.new(1, -1, 0, 39)
    NB.Position = UDim2.new(0, 0, 0, (i - 1) * 39)
    NB.Text = ""; NB.AutoButtonColor = false
    NavBtns[name] = NB

    local IBar = Instance.new("Frame", NB) -- left accent bar
    IBar.BackgroundColor3 = C_ACCENT
    IBar.Size = UDim2.new(0, 3, 0.5, 0)
    IBar.Position = UDim2.new(0, 0, 0.25, 0)
    IBar.Visible = isActive; IBar.BorderSizePixel = 0
    IBar.Name = "IBar"

    local NLbl = Instance.new("TextLabel", NB)
    NLbl.BackgroundTransparency = 1
    NLbl.Size = UDim2.new(1, -14, 1, 0)
    NLbl.Position = UDim2.new(0, 14, 0, 0)
    NLbl.Text = name
    NLbl.TextColor3 = isActive and C_WHITE or C_DIM
    NLbl.Font = isActive and Enum.Font.GothamBold or Enum.Font.Gotham
    NLbl.TextSize = 12
    NLbl.TextXAlignment = Enum.TextXAlignment.Left
    NLbl.Name = "NLbl"

    local SF = Instance.new("ScrollingFrame", Content)
    SF.BackgroundTransparency = 1
    SF.Size = UDim2.new(1, 0, 1, 0)
    SF.Visible = isActive
    SF.ScrollBarThickness = 3
    SF.ScrollBarImageColor3 = C_ACCENT
    SF.CanvasSize = UDim2.new(0, 0, 0, 0)
    SF.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SF.BorderSizePixel = 0
    local ULL = Instance.new("UIListLayout", SF)
    ULL.SortOrder = Enum.SortOrder.LayoutOrder; ULL.Padding = UDim.new(0, 4)
    local UPD = Instance.new("UIPadding", SF)
    UPD.PaddingTop = UDim.new(0, 8); UPD.PaddingLeft = UDim.new(0, 4); UPD.PaddingRight = UDim.new(0, 6)
    TabFrames[name] = SF

    NB.MouseButton1Click:Connect(function()
        CurrentTab = name
        for n, f  in pairs(TabFrames) do f.Visible = n == name end
        for n, btn in pairs(NavBtns) do
            local ib  = btn:FindFirstChild("IBar")
            local lbl = btn:FindFirstChild("NLbl")
            if n == name then
                btn.BackgroundTransparency = 0
                if ib  then ib.Visible = true end
                if lbl then lbl.TextColor3 = C_WHITE; lbl.Font = Enum.Font.GothamBold end
            else
                btn.BackgroundTransparency = 1
                if ib  then ib.Visible = false end
                if lbl then lbl.TextColor3 = C_DIM;   lbl.Font = Enum.Font.Gotham end
            end
        end
    end)
end

-- ============================================================
--  ROW BUILDER HELPERS
-- ============================================================

local function makeSection(parent, text)
    local H = Instance.new("TextLabel", parent)
    H.BackgroundTransparency = 1
    H.Size = UDim2.new(1, 0, 0, 20)
    H.Text = "  " .. text:upper()
    H.TextColor3 = C_ACCENT
    H.Font = Enum.Font.GothamBold
    H.TextSize = 9
    H.TextXAlignment = Enum.TextXAlignment.Left
    return H
end

local function makeToggle(parent, label, initState, callback)
    local Row = Instance.new("Frame", parent)
    Row.BackgroundColor3 = C_ROW
    Row.Size = UDim2.new(1, 0, 0, 34)
    Row.BorderSizePixel = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(1, -46, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Text = label; Lbl.TextColor3 = C_TEXT
    Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("Frame", Row)
    Box.BackgroundColor3 = initState and C_ON or C_OFF
    Box.Size = UDim2.new(0, 24, 0, 24)
    Box.Position = UDim2.new(1, -32, 0.5, -12)
    Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

    local XL = Instance.new("TextLabel", Box)
    XL.BackgroundTransparency = 1; XL.Size = UDim2.new(1, 0, 1, 0)
    XL.Text = initState and "✕" or ""; XL.TextColor3 = C_WHITE
    XL.Font = Enum.Font.GothamBold; XL.TextSize = 12

    local Btn = Instance.new("TextButton", Row)
    Btn.BackgroundTransparency = 1; Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Text = ""; Btn.ZIndex = 2

    local state = initState
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and C_ON or C_OFF
        XL.Text = state and "✕" or ""
        TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundColor3 = state and C_ROW_H or C_ROW}):Play()
        callback(state)
    end)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundColor3 = state and C_ROW_H or C_ROW}):Play()
    end)
    return Row
end

-- Toggle + editable number value on same row
local function makeToggleValue(parent, label, initState, initVal, onToggle, onValue)
    local Row = Instance.new("Frame", parent)
    Row.BackgroundColor3 = C_ROW
    Row.Size = UDim2.new(1, 0, 0, 34)
    Row.BorderSizePixel = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(0.42, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.Text = label; Lbl.TextColor3 = C_TEXT
    Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local currentVal = initVal
    local VBox = Instance.new("TextBox", Row)
    VBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    VBox.Size = UDim2.new(0, 58, 0, 22)
    VBox.Position = UDim2.new(0.44, 0, 0.5, -11)
    VBox.Text = tostring(initVal)
    VBox.TextColor3 = C_TEXT; VBox.Font = Enum.Font.Gotham; VBox.TextSize = 12
    VBox.ClearTextOnFocus = false
    Instance.new("UICorner", VBox).CornerRadius = UDim.new(0, 4)
    local VS = Instance.new("UIStroke", VBox)
    VS.Color = C_ACCENT; VS.Transparency = 0.6; VS.Thickness = 1
    VBox.FocusLost:Connect(function()
        local v = tonumber(VBox.Text)
        if v then currentVal = onValue(v) or v end
        VBox.Text = tostring(currentVal)
    end)

    local Box = Instance.new("Frame", Row)
    Box.BackgroundColor3 = initState and C_ON or C_OFF
    Box.Size = UDim2.new(0, 24, 0, 24)
    Box.Position = UDim2.new(1, -32, 0.5, -12)
    Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

    local XL = Instance.new("TextLabel", Box)
    XL.BackgroundTransparency = 1; XL.Size = UDim2.new(1, 0, 1, 0)
    XL.Text = initState and "✕" or ""; XL.TextColor3 = C_WHITE
    XL.Font = Enum.Font.GothamBold; XL.TextSize = 12

    -- Clickable area only on the left label portion
    local Btn = Instance.new("TextButton", Row)
    Btn.BackgroundTransparency = 1
    Btn.Size = UDim2.new(0.4, 0, 1, 0)
    Btn.Position = UDim2.new(0, 0, 0, 0)
    Btn.Text = ""; Btn.ZIndex = 2

    local state = initState
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and C_ON or C_OFF
        XL.Text = state and "✕" or ""
        onToggle(state)
    end)

    -- Also make the indicator box clickable
    local BtnBox = Instance.new("TextButton", Box)
    BtnBox.BackgroundTransparency = 1; BtnBox.Size = UDim2.new(1, 0, 1, 0)
    BtnBox.Text = ""; BtnBox.ZIndex = 3
    BtnBox.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and C_ON or C_OFF
        XL.Text = state and "✕" or ""
        onToggle(state)
    end)

    return Row
end

local function makeButton(parent, label, onClick)
    local Row = Instance.new("Frame", parent)
    Row.BackgroundColor3 = C_ROW
    Row.Size = UDim2.new(1, 0, 0, 34)
    Row.BorderSizePixel = 0
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    local RS = Instance.new("UIStroke", Row)
    RS.Color = C_ACCENT; RS.Transparency = 0.65; RS.Thickness = 1

    local Btn = Instance.new("TextButton", Row)
    Btn.BackgroundTransparency = 1; Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.Text = label; Btn.TextColor3 = C_ACCENT
    Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13
    Btn.AutoButtonColor = false

    Btn.MouseButton1Click:Connect(onClick)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundColor3 = C_ROW_H}):Play()
        TweenService:Create(Btn, TweenInfo.new(0.12), {TextColor3 = C_WHITE}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Row, TweenInfo.new(0.12), {BackgroundColor3 = C_ROW}):Play()
        TweenService:Create(Btn, TweenInfo.new(0.12), {TextColor3 = C_ACCENT}):Play()
    end)
    return Row
end

local function makeInfoLabel(parent, text)
    local L = Instance.new("TextLabel", parent)
    L.BackgroundTransparency = 1
    L.Size = UDim2.new(1, 0, 0, 36)
    L.Text = text; L.TextColor3 = C_DIM
    L.Font = Enum.Font.Gotham; L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextWrapped = true
    L.TextYAlignment = Enum.TextYAlignment.Top
    local LP = Instance.new("UIPadding", L)
    LP.PaddingLeft = UDim.new(0, 6)
    return L
end

-- ============================================================
--  POPULATE TABS
-- ============================================================

-- ── AIMBOT ──────────────────────────────────────────────────
do
    local f = TabFrames["Aimbot"]
    makeSection(f, "Targeting")
    makeToggle(f, "Aimbot",        Settings.AimbotOn,     function(v) Settings.AimbotOn     = v end)
    makeToggle(f, "Auto Aimbot",   Settings.AutoAimbotOn, function(v) Settings.AutoAimbotOn  = v end)
    makeToggle(f, "Team Check",    Settings.TeamCheck,    function(v) Settings.TeamCheck     = v end)
    makeSection(f, "Display")
    makeToggle(f, "Show FOV", Settings.ShowFOV, function(v)
        Settings.ShowFOV = v; RadiusFrame.Visible = v
    end)
    makeSection(f, "Advanced")
    makeToggle(f, "Wallbang", Settings.WallbangOn, function(v) Settings.WallbangOn = v end)
end

-- ── ESP ─────────────────────────────────────────────────────
do
    local f = TabFrames["ESP"]
    makeSection(f, "ESP Settings")
    makeToggle(f, "ESP", Settings.ESPOn, function(v)
        Settings.ESPOn = v
        if v then scanAndApplyESP() else removeAllESPs() end
    end)
    makeToggle(f, "Use Team Colors", Settings.UseTeamColors, function(v)
        Settings.UseTeamColors = v
        removeAllESPs()
        if Settings.ESPOn then scanAndApplyESP() end
    end)
end

-- ── GUN MODS ────────────────────────────────────────────────
do
    local f = TabFrames["Gun Mods"]
    makeSection(f, "Ammo")
    makeToggle(f, "Infinite Ammo",  Settings.InfiniteAmmo,  function(v) Settings.InfiniteAmmo  = v end)
    makeToggle(f, "Instant Reload", Settings.InstantReload, function(v) Settings.InstantReload = v end)
    makeSection(f, "Accuracy")
    makeToggle(f, "No Recoil", Settings.NoRecoil, function(v) Settings.NoRecoil = v end)
    makeToggle(f, "No Spread",  Settings.NoSpread, function(v) Settings.NoSpread  = v end)
    makeSection(f, "Fire Rate")
    makeToggle(f, "Fast Shoot", Settings.FastShoot, function(v) Settings.FastShoot = v end)
end

-- ── CHARACTER ───────────────────────────────────────────────
do
    local f = TabFrames["Character"]
    makeSection(f, "Movement")
    makeToggleValue(f, "Walkspeed", Settings.WalkspeedOn, Settings.WalkspeedValue,
        function(v)
            Settings.WalkspeedOn = v
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = v and Settings.WalkspeedValue or 16
            end
        end,
        function(v)
            Settings.WalkspeedValue = math.min(v, 1000)
            if Settings.WalkspeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkspeedValue
            end
            return Settings.WalkspeedValue
        end
    )
    makeToggleValue(f, "Hip Height", Settings.HipHeightOn, Settings.HipHeightValue,
        function(v)
            Settings.HipHeightOn = v
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.HipHeight = v and Settings.HipHeightValue or 0
            end
        end,
        function(v)
            Settings.HipHeightValue = math.min(v, 1000)
            if Settings.HipHeightOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.HipHeight = Settings.HipHeightValue
            end
            return Settings.HipHeightValue
        end
    )
    makeToggle(f, "Auto Bhop", Settings.AutoBhopOn, function(v) Settings.AutoBhopOn = v end)
    makeToggle(f, "Air Walk",  Settings.AirWalkOn,  function(v) Settings.AirWalkOn  = v end)
    makeSection(f, "Combat")
    makeToggleValue(f, "Spinbot", Settings.SpinbotOn, Settings.SpinbotSpeed,
        function(v) Settings.SpinbotOn = v end,
        function(v) Settings.SpinbotSpeed = v; return v end
    )
    makeToggle(f, "AIbot", Settings.AIbotOn, function(v) Settings.AIbotOn = v end)
end

-- ── TELEPORT ────────────────────────────────────────────────
do
    local f = TabFrames["Teleport"]
    makeSection(f, "Quick")
    makeToggle(f, "Auto TP to Enemy", Settings.AutoTPOn, function(v)
        Settings.AutoTPOn = v
        if v then startAutoTP()
        else currentTarget = nil; if tpTween then tpTween:Cancel() end end
    end)
    makeToggle(f, "TP to Safe Zone", Settings.TPToSafeZone, function(v)
        Settings.TPToSafeZone = v
        if v then teleportToSafeZone()
        else if tpTween then tpTween:Cancel() end end
    end)
    makeSection(f, "Sequential Enemy TP")
    makeToggle(f, "TP to Enemies (Sequential)", Settings.EnemyTPOn, function(v)
        Settings.EnemyTPOn = v
        startEnemyTP()
    end)
    makeInfoLabel(f, "  Teleports to each enemy → shoots for 6s → waits 10s → next target.")
end

-- ── KOTH ────────────────────────────────────────────────────
do
    local f = TabFrames["KOTH"]
    makeSection(f, "Capture Zones")
    for _, zone in ipairs({"A","B","C","D","E","F","G","H"}) do
        makeButton(f, "Teleport to Zone  " .. zone, function()
            Settings.KOTHZone = zone
            teleportToKOTHZone(zone)
        end)
    end
end

-- ============================================================
--  AIMBOT INPUT
-- ============================================================
UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then lockOn = true end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton2 then lockOn = false end
end)

-- ============================================================
--  CHARACTER SPAWN HANDLER
-- ============================================================
local function applyCharSettings(char)
    local hum = char:WaitForChild("Humanoid")
    if Settings.WalkspeedOn then
        hum.WalkSpeed = Settings.WalkspeedValue
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Settings.WalkspeedOn then hum.WalkSpeed = Settings.WalkspeedValue end
        end)
    end
    if Settings.HipHeightOn then
        hum.HipHeight = Settings.HipHeightValue
        hum:GetPropertyChangedSignal("HipHeight"):Connect(function()
            if Settings.HipHeightOn then hum.HipHeight = Settings.HipHeightValue end
        end)
    end
    if Settings.AutoTPOn     then task.delay(2, startAutoTP) end
    if Settings.TPToSafeZone then task.delay(2, teleportToSafeZone) end
    if Settings.KOTHZone     then task.delay(2, function() teleportToKOTHZone(Settings.KOTHZone) end) end
    if Settings.EnemyTPOn    then task.delay(2, startEnemyTP) end
end

LocalPlayer.CharacterAdded:Connect(applyCharSettings)
if LocalPlayer.Character then applyCharSettings(LocalPlayer.Character) end

-- ============================================================
--  GAME LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = Workspace:FindFirstChild(LocalPlayer.Name)
    if char then
        local gun = char:FindFirstChildOfClass("Tool")
        if gun then
            if Settings.InfiniteAmmo  then findAndSetAmmo(gun) end
            if Settings.InstantReload then gun:SetAttribute("reloadTime", 0) end
            if Settings.NoRecoil then
                gun:SetAttribute("recoilMin", Vector2.zero)
                gun:SetAttribute("recoilMax", Vector2.zero)
                gun:SetAttribute("recoilAimReduction", Vector2.zero)
            end
            if Settings.NoSpread  then gun:SetAttribute("spread", 0) end
            if Settings.FastShoot then gun:SetAttribute("rateOfFire", math.huge) end
            if Settings.WallbangOn then
                gun:SetAttribute("penetration", math.huge)
                gun:SetAttribute("canPenetrate", true)
            end
        end
        autoBhop(); airWalk(); spinbot(); aIbot()
    end
    if lockOn and Settings.AimbotOn then
        local t = getNearestPlayer()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
    if Settings.AutoAimbotOn then
        local t = getNearestPlayer()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
    if Settings.AutoTPOn then
        startAutoTP()
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head")
            and currentTarget.Character:FindFirstChild("Humanoid")
            and currentTarget.Character.Humanoid.Health > 0 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character.Head.Position)
        end
    end
end)

Workspace.DescendantAdded:Connect(function(desc)
    if Settings.ESPOn and (desc:IsA("BasePart") or desc:IsA("Model")) then
        for _, t in ipairs(targetList) do
            if desc.Name == t.Name then createESP(desc) end
        end
    end
end)

findKOTHZones()
scanAndApplyESP()
