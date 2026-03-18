-- MEGAHACK | Full Rewrite - Fixed GUI
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
    AimbotOn       = false,
    AutoAimbotOn   = false,
    ShowFOV        = true,
    TeamCheck      = true,
    LockRadius     = 100,
    WallbangOn     = false,

    ESPOn             = true,
    UseTeamColors     = false,
    OwnTeamColor      = Color3.fromRGB(0, 100, 255),
    OpponentTeamColor = Color3.fromRGB(255, 50, 50),

    InstantReload = false,
    InfiniteAmmo  = false,
    NoRecoil      = false,
    NoSpread      = false,
    FastShoot     = false,

    WalkspeedOn    = false,
    WalkspeedValue = 50,
    HipHeightOn    = false,
    HipHeightValue = 25,
    AutoBhopOn     = false,
    AirWalkOn      = false,
    SpinbotOn      = false,
    SpinbotSpeed   = 5,
    AIbotOn        = false,

    AutoTPOn     = false,
    TPToSafeZone = false,
    EnemyTPOn    = false,

    KOTHZone = nil,
}

-- ============================================================
--  LOGIC VARS
-- ============================================================
local targetList    = {{Name = "Head"}}
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
local diedConn      = nil
local enemyTPThread = nil
local lockOn        = false

-- ============================================================
--  LOGIC FUNCTIONS
-- ============================================================

local function isTeamGame()
    local t = {}
    for _, p in pairs(Players:GetPlayers()) do t[p.Team or "NIL"] = true end
    local n = 0; for _ in pairs(t) do n += 1 end
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
    dot.AnchorPoint = Vector2.new(0.5,0.5); dot.BackgroundColor3 = col
    dot.Position = UDim2.new(0.5,0,0.5,0); dot.Size = UDim2.new(0,5,0,5)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local lbl = Instance.new("TextLabel", bb)
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0,0,0.5,12)
    lbl.Size = UDim2.new(1,0,0.1,0); lbl.Text = player.Name
    lbl.TextColor3 = col; lbl.TextScaled = true
    lbl.TextStrokeTransparency = 0.8; lbl.TextStrokeColor3 = Color3.new()
    if target.Parent and target.Parent:FindFirstChild("Humanoid") then
        target.Parent.Humanoid.Died:Connect(function()
            bb:Destroy()
            for i,e in ipairs(createdESPs) do
                if e == bb then table.remove(createdESPs,i); break end
            end
            if currentTarget == player then currentTarget = nil end
        end)
    end
end

local function removeAllESPs()
    for _,e in ipairs(createdESPs) do e:Destroy() end
    createdESPs = {}
end

local function scanAndApplyESP()
    if not Settings.ESPOn then return end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            for _,t in ipairs(targetList) do
                if obj.Name == t.Name then createESP(obj) end
            end
        end
    end
end

local function getNearestPlayer()
    local best, bestD = nil, Settings.LockRadius
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local sp, onS = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local d = (Vector2.new(sp.X,sp.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if (onS or Settings.WallbangOn) and d < bestD then bestD = d; best = p end
            end
        end
    end
    return best
end

local function getAllEnemies()
    local list = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then table.insert(list,p) end
        end
    end
    return list
end

local function getEnemyBehind()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _,p in pairs(Players:GetPlayers()) do
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
    return #list > 0 and list[math.random(1,#list)] or nil
end

local function fireGun()
    local now = tick()
    if now - lastFire < fireCooldown then return end
    lastFire = now
    local char = LocalPlayer.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
    for _,rem in ipairs(tool:GetDescendants()) do
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
    for _,rem in ipairs(tool:GetDescendants()) do
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
    local char = LocalPlayer.Character; if not char then return end
    local hum  = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local eRoot = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not eRoot then return end
    if pathCoroutine then coroutine.close(pathCoroutine); pathCoroutine = nil end
    pathCoroutine = coroutine.create(function()
        local path = PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,Costs={NonPathable=math.huge}})
        local ok = pcall(function() path:ComputeAsync(root.Position, eRoot.Position) end)
        if ok and path.Status == Enum.PathStatus.Success then
            for _,wp in ipairs(path:GetWaypoints()) do
                if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                hum:MoveTo(wp.Position); hum.MoveToFinished:Wait()
            end
        else hum:MoveTo(eRoot.Position) end
    end)
    coroutine.resume(pathCoroutine)
end

local function startAutoTP()
    if not Settings.AutoTPOn then return end
    if currentTarget and currentTarget.Character
        and currentTarget.Character:FindFirstChild("Humanoid")
        and currentTarget.Character.Humanoid.Health > 0 then return end
    currentTarget = getRandomEnemy(); if not currentTarget then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local eRoot = currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart")
    if not eRoot then return end
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root, TweenInfo.new(5,Enum.EasingStyle.Linear),
        {CFrame = CFrame.lookAt(eRoot.Position + Vector3.new(0,5,0), eRoot.Position)})
    tpTween:Play()
end

local function teleportToSafeZone()
    if not Settings.TPToSafeZone then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root, TweenInfo.new(3,Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(safeZonePos + Vector3.new(0,50,0))})
    tpTween:Play()
end

local function teleportToKOTHZone(zone)
    if not zone then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local zp = Workspace:FindFirstChild(zone); if not zp then print("Zone "..zone.." not found") return end
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root, TweenInfo.new(3,Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(zp.Position + Vector3.new(0,50,0))})
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
    for _,c in ipairs(gun:GetDescendants()) do
        if c:IsA("IntValue") or c:IsA("NumberValue") then
            local nl = c.Name:lower()
            if nl:find("ammo") or nl:find("magazine") or nl:find("clip") or nl:find("bullet") then
                c.Value = math.huge
            end
        end
    end
    for _,a in ipairs({"magazineSize","ammo","maxAmmo","currentAmmo","reserveAmmo"}) do
        pcall(function() gun:SetAttribute(a, math.huge) end)
    end
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
    bv.MaxForce = Vector3.new(0,math.huge,0); bv.Velocity = Vector3.zero; bv.Parent = root
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
    local np = tp + Vector3.new(math.cos(math.rad(spinAngle))*10, 0, math.sin(math.rad(spinAngle))*10)
    TweenService:Create(root, TweenInfo.new(0.1,Enum.EasingStyle.Sine), {CFrame=CFrame.new(np,tp)}):Play()
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
        local hp = behind.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, hp)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(hp.X, root.Position.Y, hp.Z))
        if tool then fireGun() end; return
    end
    local nearest = getNearestPlayer()
    if nearest and nearest.Character and nearest.Character:FindFirstChild("Head") and nearest.Character:FindFirstChild("Humanoid") then
        local hp = nearest.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, hp)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(hp.X, root.Position.Y, hp.Z))
        moveToEnemy(nearest)
        if tool then fireGun() end
        if nearest ~= currentEnemy then
            if diedConn then diedConn:Disconnect() end
            currentEnemy = nearest
            diedConn = nearest.Character.Humanoid.Died:Connect(function()
                if tick() - lastKillTime > 1 then
                    lastKillTime = tick()
                    if tool then reloadGun() end
                end
            end)
        end
    end
end

-- Sequential Enemy TP (NEW)
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
                -- Aim & shoot for 6 seconds
                local t0 = tick()
                while tick() - t0 < 6 and Settings.EnemyTPOn do
                    char = LocalPlayer.Character
                    root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then break end
                    if not enemy.Character or not enemy.Character:FindFirstChild("Head") then break end
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
local RED     = Color3.fromRGB(200, 28, 28)
local BG      = Color3.fromRGB(12, 12, 12)
local SIDE_BG = Color3.fromRGB(18, 18, 18)
local ROW_BG  = Color3.fromRGB(24, 24, 24)
local ROW_HOV = Color3.fromRGB(35, 10, 10)
local WHITE   = Color3.fromRGB(240, 240, 240)
local GRAY    = Color3.fromRGB(100, 100, 100)
local DARK    = Color3.fromRGB(50, 50, 50)

-- ============================================================
--  SCREEN GUI
-- ============================================================
pcall(function()
    local old = game.CoreGui:FindFirstChild("Megahack")
    if old then old:Destroy() end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "Megahack"
SG.Parent = game.CoreGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- FOV ring
local FovRing = Instance.new("Frame", SG)
FovRing.BackgroundTransparency = 1
FovRing.Size = UDim2.new(0, Settings.LockRadius*2, 0, Settings.LockRadius*2)
FovRing.Position = UDim2.new(0.5, -Settings.LockRadius, 0.5, -Settings.LockRadius)
FovRing.Visible = Settings.ShowFOV
Instance.new("UICorner", FovRing).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke", FovRing)
FovStroke.Thickness = 1.5; FovStroke.Color = RED; FovStroke.Transparency = 0.2

-- ============================================================
--  OPEN BUTTON
-- ============================================================
local OpenBtn = Instance.new("TextButton", SG)
OpenBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
OpenBtn.Size = UDim2.new(0, 110, 0, 30)
OpenBtn.Position = UDim2.new(0, 10, 0, 10)
OpenBtn.Text = "▶  MEGAHACK"
OpenBtn.TextColor3 = RED
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 11
OpenBtn.AutoButtonColor = false
OpenBtn.ZIndex = 100
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 5)
do local s = Instance.new("UIStroke", OpenBtn); s.Color = RED; s.Transparency = 0.4; s.Thickness = 1 end

-- Drag open button
local ob_drag, ob_ds, ob_sp = false, nil, nil
OpenBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        ob_drag = true; ob_ds = i.Position; ob_sp = OpenBtn.Position
    end
end)
OpenBtn.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement and ob_drag then
        local d = i.Position - ob_ds
        OpenBtn.Position = UDim2.new(ob_sp.X.Scale, ob_sp.X.Offset+d.X, ob_sp.Y.Scale, ob_sp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then ob_drag = false end
end)

-- ============================================================
--  MAIN WINDOW
-- ============================================================
local MW = Instance.new("Frame", SG)
MW.BackgroundColor3 = BG
MW.Size = UDim2.new(0, 560, 0, 430)
MW.Position = UDim2.new(0.5, -280, 0.5, -215)
MW.Visible = false
MW.ClipsDescendants = true
MW.ZIndex = 10
Instance.new("UICorner", MW).CornerRadius = UDim.new(0, 8)
do local s = Instance.new("UIStroke", MW); s.Color = RED; s.Transparency = 0.35; s.Thickness = 1.5 end

OpenBtn.MouseButton1Click:Connect(function()
    MW.Visible = not MW.Visible
    OpenBtn.Text = MW.Visible and "✕  MEGAHACK" or "▶  MEGAHACK"
end)

-- Drag main window
local mw_drag, mw_ds, mw_sp = false, nil, nil
MW.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        mw_drag = true; mw_ds = i.Position; mw_sp = MW.Position
    end
end)
MW.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement and mw_drag then
        local d = i.Position - mw_ds
        MW.Position = UDim2.new(mw_sp.X.Scale, mw_sp.X.Offset+d.X, mw_sp.Y.Scale, mw_sp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then mw_drag = false end
end)

-- Title bar
local TBar = Instance.new("Frame", MW)
TBar.BackgroundColor3 = SIDE_BG; TBar.BorderSizePixel = 0
TBar.Size = UDim2.new(1, 0, 0, 42); TBar.ZIndex = 11
Instance.new("UICorner", TBar).CornerRadius = UDim.new(0, 8)
-- fill bottom rounded corners of title bar
local TBfill = Instance.new("Frame", TBar)
TBfill.BackgroundColor3 = SIDE_BG; TBfill.BorderSizePixel = 0
TBfill.Size = UDim2.new(1, 0, 0, 10); TBfill.Position = UDim2.new(0, 0, 1, -10)

-- Traffic-light dots
for xi = 1, 3 do
    local dot = Instance.new("Frame", TBar)
    dot.BackgroundColor3 = xi==1 and RED or (xi==2 and Color3.fromRGB(160,80,0) or DARK)
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 10 + (xi-1)*16, 0.5, -5)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end

local TitleLbl = Instance.new("TextLabel", TBar)
TitleLbl.BackgroundTransparency = 1; TitleLbl.Size = UDim2.new(1, 0, 1, 0)
TitleLbl.Text = "MEGAHACK"; TitleLbl.TextColor3 = WHITE
TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextSize = 15
TitleLbl.LetterSpacing = 5; TitleLbl.ZIndex = 12

-- Red accent line
local ALine = Instance.new("Frame", MW)
ALine.BackgroundColor3 = RED; ALine.BorderSizePixel = 0
ALine.Size = UDim2.new(1, 0, 0, 2); ALine.Position = UDim2.new(0, 0, 0, 42)

-- Sidebar
local SideBar = Instance.new("Frame", MW)
SideBar.BackgroundColor3 = SIDE_BG; SideBar.BorderSizePixel = 0
SideBar.Size = UDim2.new(0, 128, 1, -44); SideBar.Position = UDim2.new(0, 0, 0, 44)
SideBar.ZIndex = 11

-- Right border
local SBLine = Instance.new("Frame", SideBar)
SBLine.BackgroundColor3 = RED; SBLine.BackgroundTransparency = 0.55; SBLine.BorderSizePixel = 0
SBLine.Size = UDim2.new(0, 1, 1, 0); SBLine.Position = UDim2.new(1, -1, 0, 0)

-- Content holder
local ContentHolder = Instance.new("Frame", MW)
ContentHolder.BackgroundTransparency = 1; ContentHolder.BorderSizePixel = 0
ContentHolder.Size = UDim2.new(1, -136, 1, -52)
ContentHolder.Position = UDim2.new(0, 132, 0, 48)
ContentHolder.ClipsDescendants = true; ContentHolder.ZIndex = 11

-- ============================================================
--  TABS
-- ============================================================
local TABS   = {"Aimbot", "ESP", "Gun Mods", "Character", "Teleport", "KOTH"}
local CurTab = "Aimbot"
local NavBtns  = {}
local TabPages = {}

for idx, tabName in ipairs(TABS) do
    local isActive = tabName == CurTab

    local NB = Instance.new("TextButton", SideBar)
    NB.BackgroundColor3 = isActive and Color3.fromRGB(28, 8, 8) or SIDE_BG
    NB.BorderSizePixel = 0
    NB.Size = UDim2.new(1, -1, 0, 38)
    NB.Position = UDim2.new(0, 0, 0, (idx-1)*38)
    NB.Text = ""; NB.AutoButtonColor = false; NB.ZIndex = 12
    NavBtns[tabName] = NB

    local IBar = Instance.new("Frame", NB)
    IBar.BackgroundColor3 = RED; IBar.BorderSizePixel = 0
    IBar.Size = UDim2.new(0, 3, 0.55, 0); IBar.Position = UDim2.new(0, 0, 0.225, 0)
    IBar.Visible = isActive; IBar.Name = "IBar"

    local NLbl = Instance.new("TextLabel", NB)
    NLbl.BackgroundTransparency = 1
    NLbl.Size = UDim2.new(1, -10, 1, 0); NLbl.Position = UDim2.new(0, 10, 0, 0)
    NLbl.Text = tabName
    NLbl.TextColor3 = isActive and WHITE or GRAY
    NLbl.Font = isActive and Enum.Font.GothamBold or Enum.Font.Gotham
    NLbl.TextSize = 12; NLbl.TextXAlignment = Enum.TextXAlignment.Left
    NLbl.Name = "NLbl"; NLbl.ZIndex = 13

    local Page = Instance.new("ScrollingFrame", ContentHolder)
    Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.ScrollBarThickness = 3; Page.ScrollBarImageColor3 = RED
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = isActive; Page.ZIndex = 11

    local ULL = Instance.new("UIListLayout", Page)
    ULL.SortOrder = Enum.SortOrder.LayoutOrder; ULL.Padding = UDim.new(0, 5)
    local UPad = Instance.new("UIPadding", Page)
    UPad.PaddingTop = UDim.new(0, 8); UPad.PaddingBottom = UDim.new(0, 8)
    UPad.PaddingLeft = UDim.new(0, 5); UPad.PaddingRight = UDim.new(0, 8)

    TabPages[tabName] = Page

    NB.MouseButton1Click:Connect(function()
        CurTab = tabName
        for n, pg in pairs(TabPages) do pg.Visible = (n == tabName) end
        for n, btn in pairs(NavBtns) do
            local ib = btn:FindFirstChild("IBar")
            local lb = btn:FindFirstChild("NLbl")
            if n == tabName then
                btn.BackgroundColor3 = Color3.fromRGB(28, 8, 8)
                if ib then ib.Visible = true end
                if lb then lb.TextColor3 = WHITE; lb.Font = Enum.Font.GothamBold end
            else
                btn.BackgroundColor3 = SIDE_BG
                if ib then ib.Visible = false end
                if lb then lb.TextColor3 = GRAY; lb.Font = Enum.Font.Gotham end
            end
        end
    end)
end

-- ============================================================
--  WIDGET HELPERS
-- ============================================================

local function mkSection(parent, txt)
    local f = Instance.new("Frame", parent)
    f.BackgroundTransparency = 1; f.Size = UDim2.new(1, 0, 0, 24); f.BorderSizePixel = 0
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Text = "  ◆  " .. txt:upper()
    lbl.TextColor3 = RED; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", f)
    line.BackgroundColor3 = RED; line.BackgroundTransparency = 0.65; line.BorderSizePixel = 0
    line.Size = UDim2.new(1, -4, 0, 1); line.Position = UDim2.new(0, 2, 1, -1)
end

local function mkToggle(parent, label, initState, cb)
    local row = Instance.new("Frame", parent)
    row.BackgroundColor3 = ROW_BG; row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 34)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -56, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = label; lbl.TextColor3 = WHITE
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.BackgroundColor3 = initState and RED or DARK
    pill.Size = UDim2.new(0, 40, 0, 20); pill.Position = UDim2.new(1, -48, 0.5, -10)
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.BackgroundColor3 = WHITE; knob.BorderSizePixel = 0
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = initState and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", row)
    btn.BackgroundTransparency = 1; btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""; btn.ZIndex = row.ZIndex + 2

    local cur = initState
    btn.MouseButton1Click:Connect(function()
        cur = not cur
        TweenService:Create(pill,  TweenInfo.new(0.18), {BackgroundColor3 = cur and RED or DARK}):Play()
        TweenService:Create(knob,  TweenInfo.new(0.18), {Position = cur and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        TweenService:Create(row,   TweenInfo.new(0.12), {BackgroundColor3 = cur and ROW_HOV or ROW_BG}):Play()
        cb(cur)
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = cur and ROW_HOV or Color3.fromRGB(32,32,32)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = cur and ROW_HOV or ROW_BG}):Play()
    end)
end

local function mkToggleNum(parent, label, initState, initVal, onToggle, onNum)
    local row = Instance.new("Frame", parent)
    row.BackgroundColor3 = ROW_BG; row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 34)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.38, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = label; lbl.TextColor3 = WHITE
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local numBox = Instance.new("TextBox", row)
    numBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    numBox.Size = UDim2.new(0, 56, 0, 22); numBox.Position = UDim2.new(0.40, 0, 0.5, -11)
    numBox.Text = tostring(initVal); numBox.TextColor3 = WHITE
    numBox.Font = Enum.Font.Gotham; numBox.TextSize = 12
    numBox.ClearTextOnFocus = false; numBox.BorderSizePixel = 0
    Instance.new("UICorner", numBox).CornerRadius = UDim.new(0, 4)
    do local s = Instance.new("UIStroke", numBox); s.Color = GRAY; s.Transparency = 0.5; s.Thickness = 1 end
    numBox.FocusLost:Connect(function()
        local v = tonumber(numBox.Text)
        if v then v = onNum(v) end
        numBox.Text = tostring(v or initVal)
    end)

    local pill = Instance.new("Frame", row)
    pill.BackgroundColor3 = initState and RED or DARK
    pill.Size = UDim2.new(0, 40, 0, 20); pill.Position = UDim2.new(1, -48, 0.5, -10)
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.BackgroundColor3 = WHITE; knob.BorderSizePixel = 0
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = initState and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local pillBtn = Instance.new("TextButton", pill)
    pillBtn.BackgroundTransparency = 1; pillBtn.Size = UDim2.new(1, 0, 1, 0)
    pillBtn.Text = ""; pillBtn.ZIndex = pill.ZIndex + 2

    local cur = initState
    pillBtn.MouseButton1Click:Connect(function()
        cur = not cur
        TweenService:Create(pill,  TweenInfo.new(0.18), {BackgroundColor3 = cur and RED or DARK}):Play()
        TweenService:Create(knob,  TweenInfo.new(0.18), {Position = cur and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        TweenService:Create(row,   TweenInfo.new(0.12), {BackgroundColor3 = cur and ROW_HOV or ROW_BG}):Play()
        onToggle(cur)
    end)
end

local function mkButton(parent, label, onClick)
    local row = Instance.new("Frame", parent)
    row.BackgroundColor3 = ROW_BG; row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 34)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
    do local s = Instance.new("UIStroke", row); s.Color = RED; s.Transparency = 0.6; s.Thickness = 1 end

    local btn = Instance.new("TextButton", row)
    btn.BackgroundTransparency = 1; btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = label; btn.TextColor3 = RED
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(onClick)
    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = ROW_HOV}):Play()
        TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = WHITE}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = ROW_BG}):Play()
        TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = RED}):Play()
    end)
end

local function mkInfo(parent, txt)
    local f = Instance.new("Frame", parent)
    f.BackgroundTransparency = 1; f.Size = UDim2.new(1, 0, 0, 32); f.BorderSizePixel = 0
    local lbl = Instance.new("TextLabel", f)
    lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Text = txt; lbl.TextColor3 = GRAY
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true
    local p = Instance.new("UIPadding", lbl); p.PaddingLeft = UDim.new(0, 6)
end

-- ============================================================
--  POPULATE TABS
-- ============================================================

-- AIMBOT
do
    local p = TabPages["Aimbot"]
    mkSection(p, "Targeting")
    mkToggle(p, "Aimbot  (Hold RMB)",  Settings.AimbotOn,     function(v) Settings.AimbotOn    = v end)
    mkToggle(p, "Auto Aimbot",         Settings.AutoAimbotOn, function(v) Settings.AutoAimbotOn = v end)
    mkToggle(p, "Team Check",          Settings.TeamCheck,    function(v) Settings.TeamCheck    = v end)
    mkSection(p, "FOV")
    mkToggle(p, "Show FOV Circle", Settings.ShowFOV, function(v)
        Settings.ShowFOV = v; FovRing.Visible = v
    end)
    mkSection(p, "Penetration")
    mkToggle(p, "Wallbang", Settings.WallbangOn, function(v) Settings.WallbangOn = v end)
end

-- ESP
do
    local p = TabPages["ESP"]
    mkSection(p, "ESP Options")
    mkToggle(p, "ESP  (Player Dots)", Settings.ESPOn, function(v)
        Settings.ESPOn = v
        if v then scanAndApplyESP() else removeAllESPs() end
    end)
    mkToggle(p, "Use Team Colors", Settings.UseTeamColors, function(v)
        Settings.UseTeamColors = v
        removeAllESPs()
        if Settings.ESPOn then scanAndApplyESP() end
    end)
end

-- GUN MODS
do
    local p = TabPages["Gun Mods"]
    mkSection(p, "Ammo")
    mkToggle(p, "Infinite Ammo",  Settings.InfiniteAmmo,  function(v) Settings.InfiniteAmmo  = v end)
    mkToggle(p, "Instant Reload", Settings.InstantReload, function(v) Settings.InstantReload  = v end)
    mkSection(p, "Accuracy")
    mkToggle(p, "No Recoil", Settings.NoRecoil, function(v) Settings.NoRecoil = v end)
    mkToggle(p, "No Spread",  Settings.NoSpread, function(v) Settings.NoSpread  = v end)
    mkSection(p, "Fire Rate")
    mkToggle(p, "Fast Shoot", Settings.FastShoot, function(v) Settings.FastShoot = v end)
end

-- CHARACTER
do
    local p = TabPages["Character"]
    mkSection(p, "Speed & Physics")
    mkToggleNum(p, "Walkspeed", Settings.WalkspeedOn, Settings.WalkspeedValue,
        function(v)
            Settings.WalkspeedOn = v
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = v and Settings.WalkspeedValue or 16
            end
        end,
        function(v)
            Settings.WalkspeedValue = math.clamp(v, 1, 1000)
            if Settings.WalkspeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkspeedValue
            end
            return Settings.WalkspeedValue
        end
    )
    mkToggleNum(p, "Hip Height", Settings.HipHeightOn, Settings.HipHeightValue,
        function(v)
            Settings.HipHeightOn = v
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.HipHeight = v and Settings.HipHeightValue or 0
            end
        end,
        function(v)
            Settings.HipHeightValue = math.clamp(v, 0, 1000)
            if Settings.HipHeightOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.HipHeight = Settings.HipHeightValue
            end
            return Settings.HipHeightValue
        end
    )
    mkSection(p, "Movement")
    mkToggle(p, "Auto Bhop", Settings.AutoBhopOn, function(v) Settings.AutoBhopOn = v end)
    mkToggle(p, "Air Walk",  Settings.AirWalkOn,  function(v) Settings.AirWalkOn  = v end)
    mkSection(p, "Combat")
    mkToggleNum(p, "Spinbot", Settings.SpinbotOn, Settings.SpinbotSpeed,
        function(v) Settings.SpinbotOn = v end,
        function(v) Settings.SpinbotSpeed = v; return v end
    )
    mkToggle(p, "AIbot  (Auto Combat)", Settings.AIbotOn, function(v) Settings.AIbotOn = v end)
end

-- TELEPORT
do
    local p = TabPages["Teleport"]
    mkSection(p, "Quick")
    mkToggle(p, "Auto TP to Enemy", Settings.AutoTPOn, function(v)
        Settings.AutoTPOn = v
        if v then startAutoTP()
        else currentTarget = nil; if tpTween then tpTween:Cancel() end end
    end)
    mkToggle(p, "TP to Safe Zone", Settings.TPToSafeZone, function(v)
        Settings.TPToSafeZone = v
        if v then teleportToSafeZone()
        else if tpTween then tpTween:Cancel() end end
    end)
    mkSection(p, "Sequential Enemy TP")
    mkToggle(p, "Enemy Loop TP", Settings.EnemyTPOn, function(v)
        Settings.EnemyTPOn = v
        startEnemyTP()
    end)
    mkInfo(p, "  Teleports to enemy → aims & shoots for 6s → waits 10s → next enemy.")
end

-- KOTH
do
    local p = TabPages["KOTH"]
    mkSection(p, "Capture Zones")
    for _, zone in ipairs({"A","B","C","D","E","F","G","H"}) do
        mkButton(p, "Teleport  →  Zone  " .. zone, function()
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
local function applyChar(char)
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
    task.delay(2, function()
        if Settings.AutoTPOn     then startAutoTP() end
        if Settings.TPToSafeZone then teleportToSafeZone() end
        if Settings.KOTHZone     then teleportToKOTHZone(Settings.KOTHZone) end
        if Settings.EnemyTPOn    then startEnemyTP() end
    end)
end

LocalPlayer.CharacterAdded:Connect(applyChar)
if LocalPlayer.Character then applyChar(LocalPlayer.Character) end

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
            if Settings.NoSpread   then gun:SetAttribute("spread", 0) end
            if Settings.FastShoot  then gun:SetAttribute("rateOfFire", math.huge) end
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
        if currentTarget and currentTarget.Character
            and currentTarget.Character:FindFirstChild("Head")
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

print("[MEGAHACK] Loaded! Click the red button in the top-left to open.")
