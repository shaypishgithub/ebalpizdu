-- MEGAHACK v2.0 | Redesigned GUI + Enemy Cycle TP
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local PathfindingService = game:GetService("PathfindingService")

local Settings = {
    -- Aimbot
    AimbotOn = false,
    AutoAimbotOn = false,
    ShowFOV = true,
    TeamCheck = true,
    LockRadius = 100,
    FOVColor = Color3.fromRGB(220, 30, 30),
    WallbangOn = false,
    -- ESP
    ESPOn = true,
    UseTeamColors = false,
    OwnTeamColor = Color3.fromRGB(50, 150, 255),
    OpponentTeamColor = Color3.fromRGB(220, 30, 30),
    -- Gun Mods
    InstantReload = false,
    InfiniteAmmo = false,
    NoRecoil = false,
    NoSpread = false,
    FastShoot = false,
    -- Character
    WalkspeedOn = false,
    WalkspeedValue = 50,
    HipHeightOn = false,
    HipHeightValue = 25,
    AutoBhopOn = false,
    AirWalkOn = false,
    SpinbotOn = false,
    SpinbotSpeed = 5,
    -- Teleport
    AutoTPOn = false,
    TPToSafeZone = false,
    EnemyCycleTPOn = false, -- NEW
    -- AIbot
    AIbotOn = false,
    -- KOTH
    KOTHZone = nil,
}

local targetList = {{Name = "Head", Label = "Player"}}
local createdESPs = {}
local currentTarget = nil
local tpTween = nil
local lastFire = 0
local fireCooldown = 0.1
local safeZonePosition = Vector3.new(0, 100, 0)
local spinAngle = 0
local lastKillTime = 0
local KOTHZones = {A=nil,B=nil,C=nil,D=nil,E=nil,F=nil,G=nil,H=nil}
local pathCoroutine = nil
local currentEnemy = nil
local diedConnection = nil
local enemyCycleThread = nil -- NEW

-- ===================== HELPERS =====================

local function isTeamGame()
    local teams = {}
    for _, p in pairs(Players:GetPlayers()) do
        teams[p.Team or "NIL"] = true
    end
    local n = 0
    for _ in pairs(teams) do n = n + 1 end
    return n > 1
end

local function getNearestPlayer()
    local closest, closestDist = nil, Settings.LockRadius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if (on or Settings.WallbangOn) and d < closestDist then
                    closestDist = d
                    closest = p
                end
            end
        end
    end
    return closest
end

local function getNearestEnemy()
    local closest, closestDist = nil, math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < closestDist then closestDist = d; closest = p end
            end
        end
    end
    return closest
end

local function getRandomEnemy()
    local enemies = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            table.insert(enemies, p)
        end
    end
    if #enemies > 0 then return enemies[math.random(1, #enemies)] end
    return nil
end

local function getAllEnemies()
    local enemies = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
            table.insert(enemies, p)
        end
    end
    return enemies
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

local function fireGun()
    local now = tick()
    if now - lastFire < fireCooldown then return end
    lastFire = now
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, rem in ipairs(tool:GetDescendants()) do
        if rem:IsA("RemoteEvent") and (rem.Name:lower():find("fire") or rem.Name:lower():find("shoot") or rem.Name:lower():find("bullet")) then
            pcall(function() rem:FireServer() end)
            break
        end
    end
end

local function reloadGun()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, rem in ipairs(tool:GetDescendants()) do
        if rem:IsA("RemoteEvent") and rem.Name:lower():find("reload") then
            pcall(function() rem:FireServer() end)
            break
        end
    end
end

local function equipGun()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if char:FindFirstChildOfClass("Tool") then return end
    local gun = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if gun then hum:EquipTool(gun) end
end

local function moveToEnemy(enemy)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local hum = LocalPlayer.Character.Humanoid
    local root = LocalPlayer.Character.HumanoidRootPart
    local enemyRoot = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return end
    if pathCoroutine then pcall(function() coroutine.close(pathCoroutine) end) pathCoroutine = nil end
    pathCoroutine = coroutine.create(function()
        local path = PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,Costs={NonPathable=math.huge}})
        local ok = pcall(function() path:ComputeAsync(root.Position, enemyRoot.Position) end)
        if ok and path.Status == Enum.PathStatus.Success then
            for _, wp in ipairs(path:GetWaypoints()) do
                if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                hum:MoveTo(wp.Position)
                hum.MoveToFinished:Wait()
            end
        else
            hum:MoveTo(enemyRoot.Position)
        end
    end)
    coroutine.resume(pathCoroutine)
end

local function findAndSetAmmo(gun)
    if not gun then return end
    for _, child in ipairs(gun:GetDescendants()) do
        if (child:IsA("IntValue") or child:IsA("NumberValue")) then
            local n = child.Name:lower()
            if n:find("ammo") or n:find("magazine") or n:find("clip") or n:find("bullet") then
                child.Value = math.huge
            end
        end
    end
    for _, attr in ipairs({"magazineSize","ammo","maxAmmo","currentAmmo","reserveAmmo"}) do
        pcall(function() gun:SetAttribute(attr, math.huge) end)
    end
    gun.DescendantAdded:Connect(function(desc)
        if desc:IsA("IntValue") or desc:IsA("NumberValue") then
            local n = desc.Name:lower()
            if n:find("ammo") or n:find("magazine") or n:find("clip") or n:find("bullet") then desc.Value = math.huge end
        end
    end)
end

-- ===================== ESP =====================

local function createESP(target)
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if player == LocalPlayer or not player then return end
    local teamColor = Settings.UseTeamColors and player.TeamColor.Color or
        (player.Team == LocalPlayer.Team and Settings.OwnTeamColor or Settings.OpponentTeamColor)
    local ESPBillboard = Instance.new("BillboardGui")
    ESPBillboard.Name = "ESPBillboard"
    ESPBillboard.Adornee = target
    ESPBillboard.AlwaysOnTop = true
    ESPBillboard.Size = UDim2.new(0,120,0,120)
    ESPBillboard.Parent = target
    table.insert(createdESPs, ESPBillboard)
    local dot = Instance.new("Frame")
    dot.Parent = ESPBillboard
    dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.BackgroundColor3 = teamColor
    dot.Position = UDim2.new(0.5,0,0.5,0)
    dot.Size = UDim2.new(0,6,0,6)
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)
    local stroke = Instance.new("UIStroke",dot)
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(0,0,0)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = ESPBillboard
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,0,0.5,14)
    lbl.Size = UDim2.new(1,0,0.12,0)
    lbl.Text = player.Name
    lbl.TextColor3 = teamColor
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    if target.Parent and target.Parent:FindFirstChild("Humanoid") then
        target.Parent.Humanoid.Died:Connect(function()
            ESPBillboard:Destroy()
            for i, esp in ipairs(createdESPs) do
                if esp == ESPBillboard then table.remove(createdESPs, i) break end
            end
            if currentTarget == player then currentTarget = nil end
        end)
    end
end

local function removeAllESPs()
    for _, esp in ipairs(createdESPs) do esp:Destroy() end
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

-- ===================== TELEPORT =====================

local function startAutoTP()
    if not Settings.AutoTPOn then return end
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character.Humanoid.Health > 0 then return end
    currentTarget = getRandomEnemy()
    if not currentTarget or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then currentTarget = nil return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local enemyRoot = currentTarget.Character.HumanoidRootPart
    local targetPos = enemyRoot.Position + Vector3.new(0,5,0)
    if tpTween then tpTween:Cancel() end
    local tInfo = TweenInfo.new(5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
    tpTween = TweenService:Create(root, tInfo, {CFrame = CFrame.lookAt(targetPos, enemyRoot.Position)})
    tpTween:Play()
end

local function teleportToSafeZone()
    if not Settings.TPToSafeZone or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    if tpTween then tpTween:Cancel() end
    local tInfo = TweenInfo.new(5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
    tpTween = TweenService:Create(root, tInfo, {CFrame = CFrame.new(safeZonePosition + Vector3.new(0,50,0))})
    tpTween:Play()
end

local function teleportToKOTHZone(zone)
    if not zone or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    if tpTween then tpTween:Cancel() end
    local zonePart = Workspace:FindFirstChild(zone)
    if not zonePart then return end
    local targetPos = zonePart.Position + Vector3.new(0,50,0)
    local tInfo = TweenInfo.new(5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
    tpTween = TweenService:Create(root, tInfo, {CFrame = CFrame.new(targetPos)})
    tpTween:Play()
end

-- ===================== ENEMY CYCLE TP (NEW) =====================

local function startEnemyCycleTP()
    if enemyCycleThread then
        task.cancel(enemyCycleThread)
        enemyCycleThread = nil
    end
    enemyCycleThread = task.spawn(function()
        while Settings.EnemyCycleTPOn do
            task.wait(6) -- Wait 6 seconds before first TP
            if not Settings.EnemyCycleTPOn then break end
            local enemies = getAllEnemies()
            if #enemies == 0 then task.wait(3) continue end
            local idx = 1
            while Settings.EnemyCycleTPOn and idx <= #enemies do
                local target = enemies[idx]
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Teleport behind enemy
                        local enemyRoot = target.Character.HumanoidRootPart
                        local behindPos = enemyRoot.CFrame * CFrame.new(0, 0, 3)
                        root.CFrame = behindPos
                        -- Auto shoot for 10 seconds
                        local shootEnd = tick() + 10
                        equipGun()
                        while tick() < shootEnd and Settings.EnemyCycleTPOn do
                            local h = target.Character:FindFirstChild("Humanoid")
                            if not h or h.Health <= 0 then break end
                            local tHead = target.Character:FindFirstChild("Head")
                            if tHead then
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, tHead.Position)
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char.HumanoidRootPart.CFrame = CFrame.lookAt(
                                        char.HumanoidRootPart.Position,
                                        Vector3.new(tHead.Position.X, char.HumanoidRootPart.Position.Y, tHead.Position.Z)
                                    )
                                end
                            end
                            fireGun()
                            task.wait(0.05)
                        end
                    end
                end
                idx = idx + 1
                if Settings.EnemyCycleTPOn then task.wait(10) end -- Wait 10 seconds between targets
            end
            -- Refresh enemy list
            enemies = getAllEnemies()
            idx = 1
        end
    end)
end

local function stopEnemyCycleTP()
    if enemyCycleThread then
        task.cancel(enemyCycleThread)
        enemyCycleThread = nil
    end
end

-- ===================== MOVEMENT =====================

local function autoBhop()
    if not Settings.AutoBhopOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    if LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Running then
        LocalPlayer.Character.Humanoid.Jump = true
    end
end

local function airWalk()
    if not Settings.AirWalkOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0,math.huge,0)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = root
    game.Debris:AddItem(bv, 0.1)
end

local function spinbot()
    if not Settings.SpinbotOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local closest = getNearestPlayer()
    if closest then
        local torso = closest.Character:FindFirstChild("Torso") or closest.Character:FindFirstChild("UpperTorso")
        if torso then
            spinAngle = spinAngle + Settings.SpinbotSpeed
            local root = LocalPlayer.Character.HumanoidRootPart
            local tp = torso.Position
            local np = tp + Vector3.new(math.cos(math.rad(spinAngle))*10,0,math.sin(math.rad(spinAngle))*10)
            local tween = TweenService:Create(root, TweenInfo.new(0.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {CFrame = CFrame.new(np, tp)})
            tween:Play()
        end
    end
end

local function aIbot()
    if not Settings.AIbotOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character.Humanoid
    equipGun()
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local behind = getEnemyBehind()
    if behind and behind.Character and behind.Character:FindFirstChild("Head") then
        local tp = behind.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tp)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(tp.X, root.Position.Y, tp.Z))
        if tool then fireGun() end
        return
    end
    local near = getNearestPlayer()
    if near and near.Character and near.Character:FindFirstChild("Head") and near.Character:FindFirstChild("Humanoid") then
        local tp = near.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tp)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(tp.X, root.Position.Y, tp.Z))
        moveToEnemy(near)
        if tool then fireGun() end
        if near ~= currentEnemy then
            if diedConnection then diedConnection:Disconnect() end
            currentEnemy = near
            diedConnection = near.Character.Humanoid.Died:Connect(function()
                if tick() - lastKillTime > 1 then
                    lastKillTime = tick()
                    if tool then reloadGun() end
                end
            end)
        end
    end
end

local function findKOTHZones()
    for zone in pairs(KOTHZones) do
        local p = Workspace:FindFirstChild(zone)
        if p then KOTHZones[zone] = p end
    end
end

-- ===================== GUI =====================

-- Remove old GUI if exists
if game.CoreGui:FindFirstChild("Megahack") then
    game.CoreGui.Megahack:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "Megahack"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ---- FOV Circle ----
local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size = UDim2.new(0, Settings.LockRadius*2, 0, Settings.LockRadius*2)
RadiusFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
RadiusFrame.AnchorPoint = Vector2.new(0.5, 0.5)
RadiusFrame.BackgroundTransparency = 1
RadiusFrame.Visible = Settings.ShowFOV
RadiusFrame.ZIndex = 2
RadiusFrame.Parent = ScreenGui
Instance.new("UICorner", RadiusFrame).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", RadiusFrame)
fovStroke.Thickness = 1.5
fovStroke.Color = Settings.FOVColor
fovStroke.Transparency = 0.1

-- ---- Main Window ----
local MainWindow = Instance.new("Frame")
MainWindow.Parent = ScreenGui
MainWindow.Size = UDim2.new(0, 560, 0, 420)
MainWindow.Position = UDim2.new(0.5, -280, 0.5, -210)
MainWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
MainWindow.ClipsDescendants = false
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 10)

-- Outer glow border
local outerStroke = Instance.new("UIStroke", MainWindow)
outerStroke.Thickness = 1.5
outerStroke.Color = Color3.fromRGB(200, 20, 20)
outerStroke.Transparency = 0.2

-- ---- TOP BAR ----
local TopBar = Instance.new("Frame")
TopBar.Parent = MainWindow
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

-- Red accent line under title
local AccentLine = Instance.new("Frame")
AccentLine.Parent = TopBar
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, -1)
AccentLine.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
AccentLine.BorderSizePixel = 0

-- Logo dot
local LogoDot = Instance.new("Frame")
LogoDot.Parent = TopBar
LogoDot.Size = UDim2.new(0, 8, 0, 8)
LogoDot.Position = UDim2.new(0, 14, 0.5, -4)
LogoDot.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
LogoDot.BorderSizePixel = 0
Instance.new("UICorner", LogoDot).CornerRadius = UDim.new(1, 0)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 30, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MEGAHACK"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextStrokeTransparency = 0.8
TitleLabel.TextStrokeColor3 = Color3.fromRGB(200, 20, 20)

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Parent = TopBar
VersionLabel.Size = UDim2.new(0, 60, 1, 0)
VersionLabel.Position = UDim2.new(1, -80, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v2.0"
VersionLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 11

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
end)

-- ---- SIDEBAR ----
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainWindow
Sidebar.Size = UDim2.new(0, 130, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Sidebar.BorderSizePixel = 0
local sideCorner = Instance.new("UICorner", Sidebar)
sideCorner.CornerRadius = UDim.new(0, 10)

-- Right side fill to hide right corner of sidebar
local SidebarFill = Instance.new("Frame")
SidebarFill.Parent = Sidebar
SidebarFill.Size = UDim2.new(0, 10, 1, 0)
SidebarFill.Position = UDim2.new(1, -10, 0, 0)
SidebarFill.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
SidebarFill.BorderSizePixel = 0

local SidebarSeparator = Instance.new("Frame")
SidebarSeparator.Parent = MainWindow
SidebarSeparator.Size = UDim2.new(0, 1, 1, -44)
SidebarSeparator.Position = UDim2.new(0, 130, 0, 44)
SidebarSeparator.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SidebarSeparator.BorderSizePixel = 0

local SideList = Instance.new("UIListLayout", Sidebar)
SideList.Padding = UDim.new(0, 4)
SideList.SortOrder = Enum.SortOrder.LayoutOrder

local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.PaddingLeft = UDim.new(0, 8)
SidePadding.PaddingRight = UDim.new(0, 8)

-- ---- CONTENT AREA ----
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainWindow
ContentArea.Size = UDim2.new(1, -142, 1, -54)
ContentArea.Position = UDim2.new(0, 140, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0

-- ===================== TAB SYSTEM =====================

local Tabs = {}
local TabButtons = {}
local CurrentTab = nil

local TabDefs = {
    {name = "Main",      icon = "⚡"},
    {name = "Aimbot",    icon = "🎯"},
    {name = "ESP",       icon = "👁"},
    {name = "Gun Mods",  icon = "🔫"},
    {name = "Character", icon = "🏃"},
    {name = "Teleport",  icon = "⚡"},
    {name = "KOTH",      icon = "🏆"},
}

local RED = Color3.fromRGB(200, 20, 20)
local RED_DIM = Color3.fromRGB(120, 15, 15)
local BG_DARK = Color3.fromRGB(10, 10, 12)
local BG_MED = Color3.fromRGB(20, 20, 26)
local BG_LIGHT = Color3.fromRGB(28, 28, 36)
local TEXT_WHITE = Color3.fromRGB(240, 240, 245)
local TEXT_DIM = Color3.fromRGB(130, 130, 145)
local ON_COLOR = Color3.fromRGB(200, 20, 20)
local OFF_COLOR = Color3.fromRGB(40, 40, 50)

-- Helper: Create Toggle Row
local function makeToggle(parent, yPos, labelText, isOn, onToggle)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size = UDim2.new(1, 0, 0, 34)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundColor3 = BG_LIGHT
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = TEXT_WHITE
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local togOuter = Instance.new("Frame")
    togOuter.Parent = row
    togOuter.Size = UDim2.new(0, 36, 0, 20)
    togOuter.Position = UDim2.new(1, -46, 0.5, -10)
    togOuter.BackgroundColor3 = isOn and ON_COLOR or OFF_COLOR
    togOuter.BorderSizePixel = 0
    Instance.new("UICorner", togOuter).CornerRadius = UDim.new(1, 0)

    local togDot = Instance.new("Frame")
    togDot.Parent = togOuter
    togDot.Size = UDim2.new(0, 14, 0, 14)
    togDot.Position = UDim2.new(isOn and 1 or 0, isOn and -17 or 3, 0.5, -7)
    togDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    togDot.BorderSizePixel = 0
    Instance.new("UICorner", togDot).CornerRadius = UDim.new(1, 0)

    local state = {value = isOn}

    local function updateVisual(val)
        local tweenI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(togOuter, tweenI, {BackgroundColor3 = val and ON_COLOR or OFF_COLOR}):Play()
        TweenService:Create(togDot, tweenI, {Position = val and UDim2.new(1,0,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        -- Simple position update without tween glitch
        togOuter.BackgroundColor3 = val and ON_COLOR or OFF_COLOR
        togDot.Position = UDim2.new(val and 1 or 0, val and -17 or 3, 0.5, -7)
    end

    local clickRegion = Instance.new("TextButton")
    clickRegion.Parent = row
    clickRegion.Size = UDim2.new(1, 0, 1, 0)
    clickRegion.BackgroundTransparency = 1
    clickRegion.Text = ""
    clickRegion.ZIndex = 3
    clickRegion.MouseButton1Click:Connect(function()
        state.value = not state.value
        updateVisual(state.value)
        onToggle(state.value)
    end)

    return state
end

-- Helper: Create Input Row
local function makeInput(parent, yPos, labelText, defaultVal, onChanged)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size = UDim2.new(1, 0, 0, 34)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundColor3 = BG_LIGHT
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.6, -12, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = TEXT_WHITE
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = row
    box.Size = UDim2.new(0, 70, 0, 22)
    box.Position = UDim2.new(1, -80, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(220, 30, 30)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 13
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = Color3.fromRGB(50, 50, 65)
    boxStroke.Thickness = 1

    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then
            box.Text = tostring(val)
            onChanged(val)
        else
            box.Text = tostring(defaultVal)
        end
    end)
end

-- Helper: Create Button Row
local function makeButton(parent, yPos, labelText, onClick)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(220, 30, 30)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(80, 15, 15)
    stroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 12, 12)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 10, 10)}):Play()
    end)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

-- Helper: Section Header
local function makeHeader(parent, yPos, text)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.Position = UDim2.new(0, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 20, 20)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- Create Tab + SideButton
local function makeTab(def)
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Parent = ContentArea
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.Visible = false
    tabFrame.ScrollBarThickness = 3
    tabFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 20, 20)
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tabs[def.name] = tabFrame

    local sideBtn = Instance.new("TextButton")
    sideBtn.Parent = Sidebar
    sideBtn.Size = UDim2.new(1, 0, 0, 36)
    sideBtn.LayoutOrder = #TabButtons + 1
    sideBtn.BackgroundColor3 = BG_MED
    sideBtn.Text = def.icon .. "  " .. def.name
    sideBtn.TextColor3 = TEXT_DIM
    sideBtn.Font = Enum.Font.Gotham
    sideBtn.TextSize = 13
    sideBtn.TextXAlignment = Enum.TextXAlignment.Left
    sideBtn.BorderSizePixel = 0
    Instance.new("UICorner", sideBtn).CornerRadius = UDim.new(0, 7)
    local btnPad = Instance.new("UIPadding", sideBtn)
    btnPad.PaddingLeft = UDim.new(0, 10)

    TabButtons[def.name] = sideBtn

    sideBtn.MouseButton1Click:Connect(function()
        for n, f in pairs(Tabs) do
            f.Visible = false
            TabButtons[n].BackgroundColor3 = BG_MED
            TabButtons[n].TextColor3 = TEXT_DIM
        end
        tabFrame.Visible = true
        sideBtn.BackgroundColor3 = Color3.fromRGB(35, 8, 8)
        sideBtn.TextColor3 = TEXT_WHITE
        CurrentTab = def.name
    end)

    return tabFrame
end

for _, def in ipairs(TabDefs) do
    makeTab(def)
end

-- Activate first tab
local function activateTab(name)
    for n, f in pairs(Tabs) do
        f.Visible = false
        TabButtons[n].BackgroundColor3 = BG_MED
        TabButtons[n].TextColor3 = TEXT_DIM
    end
    Tabs[name].Visible = true
    TabButtons[name].BackgroundColor3 = Color3.fromRGB(35, 8, 8)
    TabButtons[name].TextColor3 = TEXT_WHITE
    CurrentTab = name
end
activateTab("Main")

-- ===================== TAB CONTENT =====================

-- Helper for auto canvas height
local function setCanvas(frame, height)
    frame.CanvasSize = UDim2.new(0, 0, 0, height)
end

-- ---- MAIN TAB ----
do
    local f = Tabs["Main"]
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)

    makeHeader(f, 0, "INFORMATION")
    local infoBox = Instance.new("Frame")
    infoBox.Parent = f
    infoBox.Size = UDim2.new(1, 0, 0, 60)
    infoBox.Position = UDim2.new(0, 0, 0, 24)
    infoBox.BackgroundColor3 = BG_LIGHT
    infoBox.BorderSizePixel = 0
    Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 7)
    local infoText = Instance.new("TextLabel")
    infoText.Parent = infoBox
    infoText.Size = UDim2.new(1, -16, 1, 0)
    infoText.Position = UDim2.new(0, 8, 0, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "MEGAHACK v2.0 | Press [M] to toggle GUI\nUse Right Mouse Button to activate aimbot"
    infoText.TextColor3 = TEXT_DIM
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 12
    infoText.TextWrapped = true
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Center

    makeHeader(f, 94, "QUICK TOGGLES")
    makeToggle(f, 118, "Aimbot", Settings.AimbotOn, function(v) Settings.AimbotOn = v end)
    makeToggle(f, 156, "ESP", Settings.ESPOn, function(v)
        Settings.ESPOn = v
        if v then scanAndApplyESP() else removeAllESPs() end
    end)
    makeToggle(f, 194, "AIbot (Auto Play)", Settings.AIbotOn, function(v) Settings.AIbotOn = v end)
    makeToggle(f, 232, "Enemy Cycle TP", Settings.EnemyCycleTPOn, function(v)
        Settings.EnemyCycleTPOn = v
        if v then startEnemyCycleTP() else stopEnemyCycleTP() end
    end)
    setCanvas(f, 280)
end

-- ---- AIMBOT TAB ----
do
    local f = Tabs["Aimbot"]
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)

    makeHeader(f, 0, "TARGETING")
    makeToggle(f, 24, "Aimbot (Hold RMB)", Settings.AimbotOn, function(v) Settings.AimbotOn = v end)
    makeToggle(f, 62, "Auto Aimbot", Settings.AutoAimbotOn, function(v) Settings.AutoAimbotOn = v end)
    makeToggle(f, 100, "Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
    makeToggle(f, 138, "Wallbang", Settings.WallbangOn, function(v) Settings.WallbangOn = v end)

    makeHeader(f, 182, "FOV")
    makeToggle(f, 206, "Show FOV Circle", Settings.ShowFOV, function(v)
        Settings.ShowFOV = v
        RadiusFrame.Visible = v
    end)
    makeInput(f, 244, "FOV Radius", Settings.LockRadius, function(v)
        Settings.LockRadius = math.clamp(v, 10, 500)
        RadiusFrame.Size = UDim2.new(0, Settings.LockRadius*2, 0, Settings.LockRadius*2)
    end)
    setCanvas(f, 290)
end

-- ---- ESP TAB ----
do
    local f = Tabs["ESP"]
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)

    makeHeader(f, 0, "ESP SETTINGS")
    makeToggle(f, 24, "Enable ESP", Settings.ESPOn, function(v)
        Settings.ESPOn = v
        if v then scanAndApplyESP() else removeAllESPs() end
    end)
    makeToggle(f, 62, "Use Team Colors", Settings.UseTeamColors, function(v)
        Settings.UseTeamColors = v
        removeAllESPs()
        if Settings.ESPOn then scanAndApplyESP() end
    end)
    makeButton(f, 110, "🔄  Refresh ESP", function()
        removeAllESPs()
        if Settings.ESPOn then scanAndApplyESP() end
    end)
    setCanvas(f, 160)
end

-- ---- GUN MODS TAB ----
do
    local f = Tabs["Gun Mods"]
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)

    makeHeader(f, 0, "AMMUNITION")
    makeToggle(f, 24, "Infinite Ammo", Settings.InfiniteAmmo, function(v) Settings.InfiniteAmmo = v end)
    makeToggle(f, 62, "Instant Reload", Settings.InstantReload, function(v) Settings.InstantReload = v end)

    makeHeader(f, 106, "ACCURACY")
    makeToggle(f, 130, "No Recoil", Settings.NoRecoil, function(v) Settings.NoRecoil = v end)
    makeToggle(f, 168, "No Spread", Settings.NoSpread, function(v) Settings.NoSpread = v end)

    makeHeader(f, 212, "RATE")
    makeToggle(f, 236, "Fast Shoot", Settings.FastShoot, function(v) Settings.FastShoot = v end)
    makeToggle(f, 274, "Wallbang", Settings.WallbangOn, function(v) Settings.WallbangOn = v end)
    setCanvas(f, 320)
end

-- ---- CHARACTER TAB ----
do
    local f = Tabs["Character"]
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)

    makeHeader(f, 0, "MOVEMENT")
    makeToggle(f, 24, "Walkspeed Boost", Settings.WalkspeedOn, function(v)
        Settings.WalkspeedOn = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v and Settings.WalkspeedValue or 16
        end
    end)
    makeInput(f, 62, "Speed Value", Settings.WalkspeedValue, function(v)
        Settings.WalkspeedValue = math.min(v, 1000)
        if Settings.WalkspeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkspeedValue
        end
    end)
    makeToggle(f, 100, "Hip Height", Settings.HipHeightOn, function(v)
        Settings.HipHeightOn = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.HipHeight = v and Settings.HipHeightValue or 0
        end
    end)
    makeInput(f, 138, "Hip Height Value", Settings.HipHeightValue, function(v)
        Settings.HipHeightValue = math.min(v, 1000)
        if Settings.HipHeightOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.HipHeight = Settings.HipHeightValue
        end
    end)
    makeToggle(f, 176, "Auto Bhop", Settings.AutoBhopOn, function(v) Settings.AutoBhopOn = v end)
    makeToggle(f, 214, "Air Walk", Settings.AirWalkOn, function(v) Settings.AirWalkOn = v end)

    makeHeader(f, 258, "COMBAT STYLE")
    makeToggle(f, 282, "Spinbot", Settings.SpinbotOn, function(v) Settings.SpinbotOn = v end)
    makeInput(f, 320, "Spin Speed", Settings.SpinbotSpeed, function(v) Settings.SpinbotSpeed = v end)
    makeToggle(f, 358, "AIbot (Full Auto)", Settings.AIbotOn, function(v) Settings.AIbotOn = v end)
    setCanvas(f, 406)
end

-- ---- TELEPORT TAB ----
do
    local f = Tabs["Teleport"]
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)

    makeHeader(f, 0, "AUTO TELEPORT")
    makeToggle(f, 24, "Auto TP to Enemies", Settings.AutoTPOn, function(v)
        Settings.AutoTPOn = v
        if not v then
            currentTarget = nil
            if tpTween then tpTween:Cancel() end
        end
    end)
    makeToggle(f, 62, "TP to Safe Zone", Settings.TPToSafeZone, function(v)
        Settings.TPToSafeZone = v
        if v then teleportToSafeZone() else if tpTween then tpTween:Cancel() end end
    end)

    makeHeader(f, 108, "ENEMY CYCLE TP  ★ NEW")
    local infoRow = Instance.new("Frame")
    infoRow.Parent = f
    infoRow.Size = UDim2.new(1, 0, 0, 48)
    infoRow.Position = UDim2.new(0, 0, 0, 132)
    infoRow.BackgroundColor3 = Color3.fromRGB(20, 8, 8)
    infoRow.BorderSizePixel = 0
    Instance.new("UICorner", infoRow).CornerRadius = UDim.new(0, 7)
    local infoStroke = Instance.new("UIStroke", infoRow)
    infoStroke.Color = Color3.fromRGB(100, 10, 10)
    infoStroke.Thickness = 1
    local infoLbl = Instance.new("TextLabel")
    infoLbl.Parent = infoRow
    infoLbl.Size = UDim2.new(1, -14, 1, 0)
    infoLbl.Position = UDim2.new(0, 7, 0, 0)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text = "Waits 6s → TPs to enemy → Auto shoots 10s → Next enemy"
    infoLbl.TextColor3 = Color3.fromRGB(180, 60, 60)
    infoLbl.Font = Enum.Font.Gotham
    infoLbl.TextSize = 11
    infoLbl.TextWrapped = true
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    infoLbl.TextYAlignment = Enum.TextYAlignment.Center

    makeToggle(f, 190, "Enable Cycle TP", Settings.EnemyCycleTPOn, function(v)
        Settings.EnemyCycleTPOn = v
        if v then startEnemyCycleTP() else stopEnemyCycleTP() end
    end)
    setCanvas(f, 240)
end

-- ---- KOTH TAB ----
do
    local f = Tabs["KOTH"]
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 6)

    makeHeader(f, 0, "ZONE TELEPORT")
    for i, zone in ipairs({"A","B","C","D","E","F","G","H"}) do
        makeButton(f, 24 + (i-1)*42, "📍  Teleport to Zone " .. zone, function()
            Settings.KOTHZone = zone
            teleportToKOTHZone(zone)
        end)
    end
    setCanvas(f, 24 + 8*42 + 10)
end

-- ===================== TOGGLE BUTTON =====================

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
ToggleButton.Size = UDim2.new(0, 68, 0, 68)
ToggleButton.Position = UDim2.new(0, 16, 0, 16)
ToggleButton.Text = ""
ToggleButton.BorderSizePixel = 0
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)
local togStroke = Instance.new("UIStroke", ToggleButton)
togStroke.Color = Color3.fromRGB(200, 20, 20)
togStroke.Thickness = 1.5

local togIcon = Instance.new("TextLabel")
togIcon.Parent = ToggleButton
togIcon.Size = UDim2.new(1, 0, 0.55, 0)
togIcon.Position = UDim2.new(0, 0, 0.05, 0)
togIcon.BackgroundTransparency = 1
togIcon.Text = "⚡"
togIcon.Font = Enum.Font.GothamBold
togIcon.TextSize = 22
togIcon.TextColor3 = Color3.fromRGB(200, 20, 20)

local togText = Instance.new("TextLabel")
togText.Parent = ToggleButton
togText.Size = UDim2.new(1, 0, 0.35, 0)
togText.Position = UDim2.new(0, 0, 0.65, 0)
togText.BackgroundTransparency = 1
togText.Text = "MENU"
togText.Font = Enum.Font.GothamBold
togText.TextSize = 10
togText.TextColor3 = Color3.fromRGB(160, 160, 170)

ToggleButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
end)

-- Keyboard toggle [M]
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.M then
        MainWindow.Visible = not MainWindow.Visible
    end
end)

-- ===================== DRAGGING =====================

local function makeDraggable(dragTarget, dragHandle)
    local dragging, dragStart, startPos = false, nil, nil
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(MainWindow, TopBar)
makeDraggable(ToggleButton, ToggleButton)

-- ===================== AIMBOT INPUT =====================

local lockOn = false
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then lockOn = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then lockOn = false end
end)

-- ===================== CHARACTER EVENTS =====================

local function applyCharacterSettings(char)
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
    task.wait(2)
    if Settings.AutoTPOn then startAutoTP() end
    if Settings.TPToSafeZone then teleportToSafeZone() end
    if Settings.KOTHZone then teleportToKOTHZone(Settings.KOTHZone) end
    if Settings.EnemyCycleTPOn then startEnemyCycleTP() end
end

LocalPlayer.CharacterAdded:Connect(applyCharacterSettings)
if LocalPlayer.Character then
    task.spawn(function() applyCharacterSettings(LocalPlayer.Character) end)
end

-- ===================== GAME LOOP =====================

RunService.RenderStepped:Connect(function()
    local char = Workspace:FindFirstChild(LocalPlayer.Name)
    if char then
        local gun = char:FindFirstChildOfClass("Tool")
        if gun then
            if Settings.InfiniteAmmo then findAndSetAmmo(gun) end
            if Settings.InstantReload then gun:SetAttribute("reloadTime", 0) end
            if Settings.NoRecoil then
                gun:SetAttribute("recoilMin", Vector2.new(0,0))
                gun:SetAttribute("recoilMax", Vector2.new(0,0))
                gun:SetAttribute("recoilAimReduction", Vector2.new(0,0))
            end
            if Settings.NoSpread then gun:SetAttribute("spread", 0) end
            if Settings.FastShoot then gun:SetAttribute("rateOfFire", math.huge) end
            if Settings.WallbangOn then
                gun:SetAttribute("penetration", math.huge)
                gun:SetAttribute("canPenetrate", true)
            end
        end
        autoBhop()
        airWalk()
        spinbot()
        if not Settings.EnemyCycleTPOn then aIbot() end
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
    if Settings.AutoTPOn and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") and currentTarget.Character.Humanoid.Health > 0 then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character.Head.Position)
        startAutoTP()
    end
end)

Workspace.DescendantAdded:Connect(function(d)
    if Settings.ESPOn and (d:IsA("BasePart") or d:IsA("Model")) then
        for _, t in ipairs(targetList) do
            if d.Name == t.Name then createESP(d) end
        end
    end
end)

findKOTHZones()
scanAndApplyESP()

print("[MEGAHACK v2.0] Loaded | Press [M] to open GUI")
