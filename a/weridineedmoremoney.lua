
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local PathfindingService = game:GetService("PathfindingService")

local Settings = {
    AimbotOn = false,
    ShowFOV = true,
    TeamCheck = true,
    LockRadius = 100,
    FOVColor = Color3.fromRGB(170, 0, 255),
    ESPOn = true,
    UseTeamColors = false,
    OwnTeamColor = Color3.fromRGB(50, 120, 255),
    OpponentTeamColor = Color3.fromRGB(220, 30, 30),
    InstantReload = false,
    InfiniteAmmo = false,
    NoRecoil = false,
    NoSpread = false,
    FastShoot = false,
    WalkspeedOn = false,
    WalkspeedValue = 50,
    HipHeightOn = false,
    HipHeightValue = 25,
    AutoTPOn = false,
    AutoAimbotOn = false,
    TPToSafeZone = false,
    WallbangOn = false,
    AutoBhopOn = false,
    AirWalkOn = false,
    SpinbotOn = false,
    SpinbotSpeed = 5,
    AIbotOn = false,
    KOTHZone = nil,
    SeqTPOn = false,
    AutoRespawnOn = false,
    SeqTPDelay = 4,
    -- NEW: Auto Wallbang Shoot
    AutoWallbangShoot = false,
    WallbangShootDelay = 0.1,
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
local KOTHZones = {A = nil, B = nil, C = nil, D = nil, E = nil, F = nil, G = nil, H = nil}
local pathCoroutine = nil
local currentEnemy = nil
local diedConnection = nil
local seqTPCoroutine = nil
local autoRespawnConnection = nil
local wallbangShootConnection = nil

-- ============================================================
-- CORE LOGIC FUNCTIONS
-- ============================================================

local function isTeamGame()
    local teams = {}
    for _, player in pairs(Players:GetPlayers()) do
        local team = player.Team or "NIL"
        teams[team] = true
    end
    local numTeams = 0
    for _ in pairs(teams) do numTeams = numTeams + 1 end
    return numTeams > 1
end

local function createESP(target)
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if player == LocalPlayer or not player then return end
    local teamColor = Settings.UseTeamColors and player.TeamColor.Color or
        (player.Team == LocalPlayer.Team and Settings.OwnTeamColor or Settings.OpponentTeamColor)
    local ESPBillboard = Instance.new("BillboardGui")
    ESPBillboard.Name = "ESPBillboard"
    ESPBillboard.Adornee = target
    ESPBillboard.AlwaysOnTop = true
    ESPBillboard.Size = UDim2.new(0, 100, 0, 100)
    ESPBillboard.Parent = target
    table.insert(createdESPs, ESPBillboard)
    local ESPFrame = Instance.new("Frame")
    ESPFrame.Parent = ESPBillboard
    ESPFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ESPFrame.BackgroundColor3 = teamColor
    ESPFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ESPFrame.Size = UDim2.new(0, 5, 0, 5)
    local FrameUICorner = Instance.new("UICorner")
    FrameUICorner.CornerRadius = UDim.new(1, 0)
    FrameUICorner.Parent = ESPFrame
    local FrameUIGradient = Instance.new("UIGradient")
    FrameUIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.5, 0.5, 0.5))
    FrameUIGradient.Rotation = 90
    FrameUIGradient.Parent = ESPFrame
    local FrameUIStroke = Instance.new("UIStroke")
    FrameUIStroke.Thickness = 2.5
    FrameUIStroke.Parent = ESPFrame
    local ESPLabel = Instance.new("TextLabel")
    ESPLabel.Parent = ESPBillboard
    ESPLabel.BackgroundTransparency = 1
    ESPLabel.Position = UDim2.new(0, 0, 0.5, 12)
    ESPLabel.Size = UDim2.new(1, 0, 0.1, 0)
    ESPLabel.Text = player.Name
    ESPLabel.TextColor3 = teamColor
    ESPLabel.TextScaled = true
    ESPLabel.TextStrokeTransparency = 0.8
    ESPLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    if target.Parent and target.Parent:FindFirstChild("Humanoid") then
        local humanoid = target.Parent.Humanoid
        humanoid.Died:Connect(function()
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
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("BasePart") or object:IsA("Model") then
            for _, target in ipairs(targetList) do
                if object.Name == target.Name then createESP(object) end
            end
        end
    end
end

local function getNearestPlayer()
    local closestPlayer = nil
    local closestDistance = Settings.LockRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and isTeamGame() and player.Team == LocalPlayer.Team then continue end
            local head = player.Character.Head
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if (onScreen or Settings.WallbangOn) and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function getNearestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and isTeamGame() and player.Team == LocalPlayer.Team then continue end
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestEnemy = player
                end
            end
        end
    end
    return closestEnemy
end

local function getEnemyBehind()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    local myForward = myRoot.CFrame.LookVector
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and isTeamGame() and player.Team == LocalPlayer.Team then continue end
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dirToEnemy = (player.Character.HumanoidRootPart.Position - myPos).Unit
                local dot = myForward:Dot(dirToEnemy)
                if dot < -0.5 then return player end
            end
        end
    end
    return nil
end

local function getRandomEnemy()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and isTeamGame() and player.Team == LocalPlayer.Team then continue end
            table.insert(enemies, player)
        end
    end
    if #enemies > 0 then return enemies[math.random(1, #enemies)] end
    return nil
end

local function getAllEnemies()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and isTeamGame() and player.Team == LocalPlayer.Team then continue end
            table.insert(enemies, player)
        end
    end
    return enemies
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
        if rem:IsA("RemoteEvent") and (string.find(rem.Name:lower(), "fire") or string.find(rem.Name:lower(), "shoot") or string.find(rem.Name:lower(), "bullet")) then
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
        if rem:IsA("RemoteEvent") and string.find(rem.Name:lower(), "reload") then
            pcall(function() rem:FireServer() end)
            break
        end
    end
end

local function equipGun()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if char:FindFirstChildOfClass("Tool") then return end
    local backpack = LocalPlayer.Backpack
    local gun = backpack:FindFirstChildOfClass("Tool")
    if gun then humanoid:EquipTool(gun) end
end

local function moveToEnemy(enemy)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid
    local root = LocalPlayer.Character.HumanoidRootPart
    local enemyRoot = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return end
    if pathCoroutine then coroutine.close(pathCoroutine) pathCoroutine = nil end
    pathCoroutine = coroutine.create(function()
        local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, Costs = {NonPathable = math.huge}})
        local success = pcall(function() path:ComputeAsync(root.Position, enemyRoot.Position) end)
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for _, waypoint in ipairs(waypoints) do
                if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
                humanoid:MoveTo(waypoint.Position)
                humanoid.MoveToFinished:Wait()
            end
        else
            humanoid:MoveTo(enemyRoot.Position)
        end
    end)
    coroutine.resume(pathCoroutine)
end

local function startAutoTP()
    if not Settings.AutoTPOn then return end
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character.Humanoid.Health > 0 then return end
    currentTarget = getRandomEnemy()
    if not currentTarget or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then currentTarget = nil return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local enemyRoot = currentTarget.Character.HumanoidRootPart
    local targetPos = enemyRoot.Position + Vector3.new(0, 5, 0)
    if tpTween then tpTween:Cancel() end
    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local targetCFrame = CFrame.lookAt(targetPos, enemyRoot.Position)
    tpTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tpTween:Play()
end

local function teleportToSafeZone()
    if not Settings.TPToSafeZone or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    if tpTween then tpTween:Cancel() end
    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local targetCFrame = CFrame.new(safeZonePosition + Vector3.new(0, 50, 0))
    tpTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tpTween:Play()
end

local function teleportToKOTHZone(zone)
    if not zone or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    if tpTween then tpTween:Cancel() end
    local zonePart = Workspace:FindFirstChild(zone)
    if not zonePart then return end
    local targetPos = zonePart.Position + Vector3.new(0, 50, 0)
    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local targetCFrame = CFrame.new(targetPos)
    tpTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tpTween:Play()
end

local function findKOTHZones()
    for zone, _ in pairs(KOTHZones) do
        local zonePart = Workspace:FindFirstChild(zone)
        if zonePart then KOTHZones[zone] = zonePart end
    end
end

local function findAndSetAmmo(gun)
    if not gun then return end
    for _, child in ipairs(gun:GetDescendants()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local nameLower = child.Name:lower()
            if string.find(nameLower, "ammo") or string.find(nameLower, "magazine") or string.find(nameLower, "clip") or string.find(nameLower, "bullet") then
                child.Value = math.huge
            end
        end
    end
    local attributes = {"magazineSize", "ammo", "maxAmmo", "currentAmmo", "reserveAmmo"}
    for _, attr in ipairs(attributes) do pcall(function() gun:SetAttribute(attr, math.huge) end) end
    gun.DescendantAdded:Connect(function(desc)
        if desc:IsA("IntValue") or desc:IsA("NumberValue") then
            local nameLower = desc.Name:lower()
            if string.find(nameLower, "ammo") or string.find(nameLower, "magazine") or string.find(nameLower, "clip") or string.find(nameLower, "bullet") then
                desc.Value = math.huge
            end
        end
    end)
end

local function autoBhop()
    if not Settings.AutoBhopOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid
    if humanoid:GetState() == Enum.HumanoidStateType.Running then humanoid.Jump = true end
end

local function airWalk()
    if not Settings.AirWalkOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root
    game.Debris:AddItem(bodyVelocity, 0.1)
end

local function spinbot()
    if not Settings.SpinbotOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local closestPlayer = getNearestPlayer()
    if closestPlayer then
        local targetTorso = closestPlayer.Character:FindFirstChild("Torso") or closestPlayer.Character:FindFirstChild("UpperTorso")
        if targetTorso then
            spinAngle = spinAngle + Settings.SpinbotSpeed
            local root = LocalPlayer.Character.HumanoidRootPart
            local targetPos = targetTorso.Position
            local radius = 10
            local newPos = targetPos + Vector3.new(math.cos(math.rad(spinAngle)) * radius, 0, math.sin(math.rad(spinAngle)) * radius)
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(newPos, targetPos)})
            tween:Play()
        end
    end
end

local function aIbot()
    if not Settings.AIbotOn or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local humanoid = LocalPlayer.Character.Humanoid
    equipGun()
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local enemyBehind = getEnemyBehind()
    if enemyBehind and enemyBehind.Character and enemyBehind.Character:FindFirstChild("Head") then
        local targetPos = enemyBehind.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        if tool then fireGun() end
        return
    end
    local nearestEnemy = getNearestPlayer()
    if nearestEnemy and nearestEnemy.Character and nearestEnemy.Character:FindFirstChild("Head") and nearestEnemy.Character:FindFirstChild("Humanoid") then
        local targetPos = nearestEnemy.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        moveToEnemy(nearestEnemy)
        if tool then fireGun() end
        if nearestEnemy ~= currentEnemy then
            if diedConnection then diedConnection:Disconnect() end
            currentEnemy = nearestEnemy
            local enemyHumanoid = nearestEnemy.Character.Humanoid
            diedConnection = enemyHumanoid.Died:Connect(function()
                if tick() - lastKillTime > 1 then
                    lastKillTime = tick()
                    if tool then reloadGun() end
                end
            end)
        end
    end
end

-- ============================================================
-- SEQUENTIAL TP TO ENEMIES
-- ============================================================
local function startSeqTP()
    if seqTPCoroutine then
        coroutine.close(seqTPCoroutine)
        seqTPCoroutine = nil
    end
    if not Settings.SeqTPOn then return end
    seqTPCoroutine = coroutine.create(function()
        while Settings.SeqTPOn do
            local enemies = getAllEnemies()
            if #enemies == 0 then
                task.wait(2)
            else
                for _, enemy in ipairs(enemies) do
                    if not Settings.SeqTPOn then break end
                    if not enemy.Character or not enemy.Character:FindFirstChild("HumanoidRootPart") then continue end
                    local enemyHumanoid = enemy.Character:FindFirstChild("Humanoid")
                    if not enemyHumanoid or enemyHumanoid.Health <= 0 then continue end

                    local myChar = LocalPlayer.Character
                    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then task.wait(1) continue end
                    local root = myChar.HumanoidRootPart
                    local enemyRoot = enemy.Character.HumanoidRootPart
                    local behindPos = enemyRoot.Position - (enemyRoot.CFrame.LookVector * 3) + Vector3.new(0, 2, 0)
                    root.CFrame = CFrame.new(behindPos, enemyRoot.Position)

                    equipGun()
                    local shootUntil = tick() + Settings.SeqTPDelay
                    while tick() < shootUntil do
                        if not Settings.SeqTPOn then break end
                        local myCharNow = LocalPlayer.Character
                        if myCharNow and myCharNow:FindFirstChild("HumanoidRootPart") and enemy.Character and enemy.Character:FindFirstChild("Head") then
                            local headPos = enemy.Character.Head.Position
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
                            myCharNow.HumanoidRootPart.CFrame = CFrame.lookAt(myCharNow.HumanoidRootPart.Position, Vector3.new(headPos.X, myCharNow.HumanoidRootPart.Position.Y, headPos.Z))
                            fireGun()
                        end
                        task.wait(0.05)
                    end
                end
            end
        end
    end)
    coroutine.resume(seqTPCoroutine)
end

-- ============================================================
-- AUTO RESPAWN
-- ============================================================
local function setupAutoRespawn()
    if autoRespawnConnection then
        autoRespawnConnection:Disconnect()
        autoRespawnConnection = nil
    end
    if not Settings.AutoRespawnOn then return end
    local function connectHumanoid(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        humanoid.Died:Connect(function()
            if Settings.AutoRespawnOn then
                task.wait(0.5)
                LocalPlayer:LoadCharacter()
            end
        end)
    end
    autoRespawnConnection = LocalPlayer.CharacterAdded:Connect(connectHumanoid)
    if LocalPlayer.Character then
        connectHumanoid(LocalPlayer.Character)
    end
end

-- ============================================================
-- NEW: AUTO WALLBANG SHOOT
-- ============================================================
local function startWallbangShoot()
    if wallbangShootConnection then
        wallbangShootConnection:Disconnect()
        wallbangShootConnection = nil
    end
    if not Settings.AutoWallbangShoot then return end
    
    wallbangShootConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AutoWallbangShoot then return end
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
        
        local nearestEnemy = getNearestPlayer()
        if nearestEnemy and nearestEnemy.Character and nearestEnemy.Character:FindFirstChild("Head") then
            local headPos = nearestEnemy.Character.Head.Position
            
            -- Принудительно включаем Wallbang для выстрела
            local oldWallbang = Settings.WallbangOn
            Settings.WallbangOn = true
            
            -- Наводимся и стреляем
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
            fireGun()
            
            -- Возвращаем настройку
            Settings.WallbangOn = oldWallbang
            
            -- Задержка между выстрелами
            task.wait(Settings.WallbangShootDelay)
        end
    end)
end

-- ============================================================
-- GUI SETUP - Purple/Black Style
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "Megahack"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- FOV Circle
local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size = UDim2.new(0, Settings.LockRadius * 2, 0, Settings.LockRadius * 2)
RadiusFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
RadiusFrame.AnchorPoint = Vector2.new(0.5, 0.5)
RadiusFrame.BackgroundTransparency = 1
RadiusFrame.Visible = Settings.ShowFOV
RadiusFrame.ZIndex = 10
RadiusFrame.Parent = ScreenGui
local UICornerFOV = Instance.new("UICorner")
UICornerFOV.CornerRadius = UDim.new(1, 0)
UICornerFOV.Parent = RadiusFrame
local UIStrokeFOV = Instance.new("UIStroke")
UIStrokeFOV.Thickness = 2
UIStrokeFOV.Color = Settings.FOVColor
UIStrokeFOV.Transparency = 0.3
UIStrokeFOV.Parent = RadiusFrame

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 2

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(170, 0, 255)
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.ZIndex = 3

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- Purple gradient line
local AccentLine = Instance.new("Frame")
AccentLine.Parent = MainFrame
AccentLine.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
AccentLine.Size = UDim2.new(1, 0, 0, 3)
AccentLine.Position = UDim2.new(0, 0, 0, 45)
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 3

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Text = "☠  MEGAHACK  ☠"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 4

local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Parent = TopBar
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.Size = UDim2.new(0, 100, 0, 14)
SubTitleLabel.Position = UDim2.new(0, 40, 0, 28)
SubTitleLabel.Text = "v2.1 | PURPLE"
SubTitleLabel.TextColor3 = Color3.fromRGB(170, 0, 255)
SubTitleLabel.Font = Enum.Font.Gotham
SubTitleLabel.TextSize = 10
SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubTitleLabel.ZIndex = 4

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 5
local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
Sidebar.Size = UDim2.new(0, 140, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.ZIndex = 3

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Thickness = 2
SidebarStroke.Color = Color3.fromRGB(170, 0, 255)
SidebarStroke.Transparency = 0.3
SidebarStroke.Parent = Sidebar

-- Content area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Size = UDim2.new(1, -148, 1, -56)
ContentArea.Position = UDim2.new(0, 148, 0, 52)
ContentArea.ZIndex = 3
ContentArea.ClipsDescendants = true

-- ============================================================
-- SCROLLING FRAME HELPER
-- ============================================================
local function makeScrollFrame(parent)
    local sf = Instance.new("ScrollingFrame")
    sf.Parent = parent
    sf.BackgroundTransparency = 1
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.Position = UDim2.new(0, 0, 0, 0)
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(170, 0, 255)
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.BorderSizePixel = 0
    sf.Visible = false
    sf.ZIndex = 4
    local layout = Instance.new("UIListLayout")
    layout.Parent = sf
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = sf
    return sf
end

-- ============================================================
-- SECTION LABEL HELPER
-- ============================================================
local function makeSectionLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Text = "  " .. text:upper()
    lbl.TextColor3 = Color3.fromRGB(170, 0, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.LayoutOrder = order or 0
    return lbl
end

-- ============================================================
-- TOGGLE BUTTON HELPER
-- ============================================================
local function makeToggle(parent, labelText, state, order, callback)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.ZIndex = 5
    row.LayoutOrder = order or 0
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6

    local toggleBg = Instance.new("Frame")
    toggleBg.Parent = row
    toggleBg.Size = UDim2.new(0, 40, 0, 22)
    toggleBg.Position = UDim2.new(1, -48, 0.5, -11)
    toggleBg.BackgroundColor3 = state and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(40, 35, 50)
    toggleBg.ZIndex = 6
    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(1, 0)
    toggleBgCorner.Parent = toggleBg

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Parent = toggleBg
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.ZIndex = 7
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob

    local isOn = state
    local btn = Instance.new("TextButton")
    btn.Parent = row
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    btn.ZIndex = 8

    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        local tweenI = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
        TweenService:Create(toggleBg, tweenI, {BackgroundColor3 = isOn and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(40, 35, 50)}):Play()
        TweenService:Create(toggleKnob, tweenI, {Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        if callback then callback(isOn) end
    end)

    return row, function(v)
        isOn = v
        local tweenI = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
        TweenService:Create(toggleBg, tweenI, {BackgroundColor3 = v and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(40, 35, 50)}):Play()
        TweenService:Create(toggleKnob, tweenI, {Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
    end
end

-- ============================================================
-- INPUT ROW HELPER
-- ============================================================
local function makeInput(parent, labelText, defaultVal, order, callback)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.ZIndex = 5
    row.LayoutOrder = order or 0
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(190, 190, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6

    local inputBg = Instance.new("Frame")
    inputBg.Parent = row
    inputBg.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    inputBg.Size = UDim2.new(0, 85, 0, 26)
    inputBg.Position = UDim2.new(1, -93, 0.5, -13)
    inputBg.ZIndex = 6
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputBg
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Thickness = 1
    inputStroke.Color = Color3.fromRGB(170, 0, 255)
    inputStroke.Transparency = 0.5
    inputStroke.Parent = inputBg

    local box = Instance.new("TextBox")
    box.Parent = inputBg
    box.BackgroundTransparency = 1
    box.Size = UDim2.new(1, -6, 1, 0)
    box.Position = UDim2.new(0, 3, 0, 0)
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.ZIndex = 7
    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)
    return row
end

-- ============================================================
-- ACTION BUTTON HELPER
-- ============================================================
local function makeButton(parent, labelText, order, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.ZIndex = 5
    btn.LayoutOrder = order or 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        local tweenI = TweenInfo.new(0.08, Enum.EasingStyle.Quad)
        TweenService:Create(btn, tweenI, {BackgroundColor3 = Color3.fromRGB(120, 0, 180)}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, tweenI, {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
        end)
        if callback then callback() end
    end)
    return btn
end

-- ============================================================
-- TABS SETUP
-- ============================================================
local TabNames = {"Aimbot", "ESP", "Gun Mods", "Character", "Auto", "KOTH"}
local TabIcons = {"🎯", "👁", "🔫", "🏃", "🤖", "⚑"}
local CurrentTab = "Aimbot"
local TabButtons = {}
local TabFrames = {}

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 8)
SidebarPad.PaddingRight = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

local function setTab(name)
    CurrentTab = name
    for tName, sf in pairs(TabFrames) do
        sf.Visible = tName == name
        if TabButtons[tName] then
            local btn = TabButtons[tName]
            if tName == name then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 20, 35)}):Play()
                btn.TextColor3 = Color3.fromRGB(150, 150, 160)
            end
        end
    end
end

for i, tabName in ipairs(TabNames) do
    local sf = makeScrollFrame(ContentArea)
    TabFrames[tabName] = sf

    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = Sidebar
    TabBtn.BackgroundColor3 = tabName == CurrentTab and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(25, 20, 35)
    TabBtn.Size = UDim2.new(1, 0, 0, 38)
    TabBtn.Text = TabIcons[i] .. "  " .. tabName
    TabBtn.TextColor3 = tabName == CurrentTab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.ZIndex = 4
    TabBtn.LayoutOrder = i
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 8)
    TabBtnCorner.Parent = TabBtn
    local TBPad = Instance.new("UIPadding")
    TBPad.PaddingLeft = UDim.new(0, 12)
    TBPad.Parent = TabBtn
    TabButtons[tabName] = TabBtn
    TabBtn.MouseButton1Click:Connect(function() setTab(tabName) end)
end

TabFrames["Aimbot"].Visible = true

-- ============================================================
-- AIMBOT TAB
-- ============================================================
local AimbotSF = TabFrames["Aimbot"]
makeSectionLabel(AimbotSF, "Aimbot Settings", 1)
makeToggle(AimbotSF, "Aimbot", Settings.AimbotOn, 2, function(v) Settings.AimbotOn = v end)
makeToggle(AimbotSF, "Auto Aimbot", Settings.AutoAimbotOn, 3, function(v) Settings.AutoAimbotOn = v end)
makeToggle(AimbotSF, "Show FOV Circle", Settings.ShowFOV, 4, function(v)
    Settings.ShowFOV = v
    RadiusFrame.Visible = v
end)
makeToggle(AimbotSF, "Team Check", Settings.TeamCheck, 5, function(v) Settings.TeamCheck = v end)
makeToggle(AimbotSF, "Wallbang", Settings.WallbangOn, 6, function(v) Settings.WallbangOn = v end)
makeSectionLabel(AimbotSF, "FOV Settings", 7)
makeInput(AimbotSF, "FOV Radius", Settings.LockRadius, 8, function(v)
    local val = tonumber(v)
    if val then
        Settings.LockRadius = val
        RadiusFrame.Size = UDim2.new(0, val * 2, 0, val * 2)
    end
end)

-- ============================================================
-- ESP TAB
-- ============================================================
local ESPSf = TabFrames["ESP"]
makeSectionLabel(ESPSf, "ESP Settings", 1)
makeToggle(ESPSf, "ESP", Settings.ESPOn, 2, function(v)
    Settings.ESPOn = v
    if v then scanAndApplyESP() else removeAllESPs() end
end)
makeToggle(ESPSf, "Use Team Colors", Settings.UseTeamColors, 3, function(v)
    Settings.UseTeamColors = v
    removeAllESPs()
    if Settings.ESPOn then scanAndApplyESP() end
end)

-- ============================================================
-- GUN MODS TAB
-- ============================================================
local GunSF = TabFrames["Gun Mods"]
makeSectionLabel(GunSF, "Gun Modifications", 1)
makeToggle(GunSF, "Instant Reload", Settings.InstantReload, 2, function(v) Settings.InstantReload = v end)
makeToggle(GunSF, "Infinite Ammo", Settings.InfiniteAmmo, 3, function(v) Settings.InfiniteAmmo = v end)
makeToggle(GunSF, "No Recoil", Settings.NoRecoil, 4, function(v) Settings.NoRecoil = v end)
makeToggle(GunSF, "No Spread", Settings.NoSpread, 5, function(v) Settings.NoSpread = v end)
makeToggle(GunSF, "Fast Shoot", Settings.FastShoot, 6, function(v) Settings.FastShoot = v end)

-- ============================================================
-- CHARACTER TAB
-- ============================================================
local CharSF = TabFrames["Character"]
makeSectionLabel(CharSF, "Movement", 1)
makeToggle(CharSF, "Walkspeed Boost", Settings.WalkspeedOn, 2, function(v)
    Settings.WalkspeedOn = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v and Settings.WalkspeedValue or 16
    end
end)
makeInput(CharSF, "Walkspeed Value", Settings.WalkspeedValue, 3, function(v)
    local val = tonumber(v)
    if val then Settings.WalkspeedValue = math.min(val, 1000) end
    if Settings.WalkspeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkspeedValue
    end
end)
makeToggle(CharSF, "Hip Height", Settings.HipHeightOn, 4, function(v)
    Settings.HipHeightOn = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.HipHeight = v and Settings.HipHeightValue or 0
    end
end)
makeInput(CharSF, "Hip Height Value", Settings.HipHeightValue, 5, function(v)
    local val = tonumber(v)
    if val then Settings.HipHeightValue = math.min(val, 1000) end
    if Settings.HipHeightOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.HipHeight = Settings.HipHeightValue
    end
end)
makeSectionLabel(CharSF, "Abilities", 6)
makeToggle(CharSF, "Auto Bhop", Settings.AutoBhopOn, 7, function(v) Settings.AutoBhopOn = v end)
makeToggle(CharSF, "Air Walk", Settings.AirWalkOn, 8, function(v) Settings.AirWalkOn = v end)
makeSectionLabel(CharSF, "Spin & Effects", 9)
makeToggle(CharSF, "Spinbot", Settings.SpinbotOn, 10, function(v) Settings.SpinbotOn = v end)
makeInput(CharSF, "Spinbot Speed", Settings.SpinbotSpeed, 11, function(v)
    local val = tonumber(v)
    if val then Settings.SpinbotSpeed = val end
end)
makeSectionLabel(CharSF, "Teleport", 12)
makeToggle(CharSF, "Auto TP (Random)", Settings.AutoTPOn, 13, function(v)
    Settings.AutoTPOn = v
    if v then startAutoTP() else currentTarget = nil if tpTween then tpTween:Cancel() end end
end)
makeToggle(CharSF, "TP to Safe Zone", Settings.TPToSafeZone, 14, function(v)
    Settings.TPToSafeZone = v
    if v then teleportToSafeZone() else if tpTween then tpTween:Cancel() end end
end)

-- ============================================================
-- AUTO TAB (with new Auto Wallbang Shoot)
-- ============================================================
local AutoSF = TabFrames["Auto"]
makeSectionLabel(AutoSF, "AI Bot", 1)
makeToggle(AutoSF, "AIbot (Auto Combat)", Settings.AIbotOn, 2, function(v) Settings.AIbotOn = v end)

makeSectionLabel(AutoSF, "Auto Wallbang Shoot", 3)
makeToggle(AutoSF, "Auto Wallbang Shoot", Settings.AutoWallbangShoot, 4, function(v)
    Settings.AutoWallbangShoot = v
    if v then 
        startWallbangShoot()
    else
        if wallbangShootConnection then
            wallbangShootConnection:Disconnect()
            wallbangShootConnection = nil
        end
    end
end)
makeInput(AutoSF, "Shoot Delay (sec)", Settings.WallbangShootDelay, 5, function(v)
    local val = tonumber(v)
    if val then Settings.WallbangShootDelay = math.max(0.05, val) end
end)

makeSectionLabel(AutoSF, "Sequential Enemy TP", 6)
makeToggle(AutoSF, "Sequential TP + Shoot", Settings.SeqTPOn, 7, function(v)
    Settings.SeqTPOn = v
    if v then startSeqTP() else
        if seqTPCoroutine then coroutine.close(seqTPCoroutine) seqTPCoroutine = nil end
    end
end)
makeInput(AutoSF, "Shoot Duration (sec)", Settings.SeqTPDelay, 8, function(v)
    local val = tonumber(v)
    if val then Settings.SeqTPDelay = math.max(0.5, val) end
end)

makeSectionLabel(AutoSF, "Respawn", 9)
makeToggle(AutoSF, "Auto Respawn", Settings.AutoRespawnOn, 10, function(v)
    Settings.AutoRespawnOn = v
    setupAutoRespawn()
end)

-- ============================================================
-- KOTH TAB
-- ============================================================
local KOTHSf = TabFrames["KOTH"]
makeSectionLabel(KOTHSf, "King of the Hill Zones", 1)
for i, zone in ipairs({"A", "B", "C", "D", "E", "F", "G", "H"}) do
    makeButton(KOTHSf, "⚑  Teleport to Zone " .. zone, i + 1, function()
        Settings.KOTHZone = zone
        teleportToKOTHZone(zone)
    end)
end

-- ============================================================
-- TOGGLE BUTTON (floating)
-- ============================================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
ToggleButton.Size = UDim2.new(0, 75, 0, 75)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.Text = ""
ToggleButton.ZIndex = 10

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(0, 15)
TBCorner.Parent = ToggleButton

local TBStroke = Instance.new("UIStroke")
TBStroke.Thickness = 3
TBStroke.Color = Color3.fromRGB(170, 0, 255)
TBStroke.Transparency = 0.2
TBStroke.Parent = ToggleButton

local TBIcon = Instance.new("TextLabel")
TBIcon.Parent = ToggleButton
TBIcon.BackgroundTransparency = 1
TBIcon.Size = UDim2.new(1, 0, 0.55, 0)
TBIcon.Position = UDim2.new(0, 0, 0, 8)
TBIcon.Text = "☠"
TBIcon.TextColor3 = Color3.fromRGB(170, 0, 255)
TBIcon.Font = Enum.Font.GothamBold
TBIcon.TextSize = 30
TBIcon.ZIndex = 11

local TBText = Instance.new("TextLabel")
TBText.Parent = ToggleButton
TBText.BackgroundTransparency = 1
TBText.Size = UDim2.new(1, 0, 0.35, 0)
TBText.Position = UDim2.new(0, 0, 0.65, 0)
TBText.Text = "PURPLE"
TBText.TextColor3 = Color3.fromRGB(200, 200, 220)
TBText.Font = Enum.Font.GothamBold
TBText.TextSize = 10
TBText.ZIndex = 11

-- ============================================================
-- DRAGGING
-- ============================================================
local function makeDraggable(dragTarget, moveTarget)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    dragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
        end
    end)
    dragTarget.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

makeDraggable(TopBar, MainFrame)
makeDraggable(ToggleButton, ToggleButton)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    local tweenI = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(MainFrame, tweenI, {
            Size = UDim2.new(0, 600, 0, 400),
            Position = UDim2.new(0.5, -300, 0.5, -200)
        }):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    local tweenI = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    TweenService:Create(MainFrame, tweenI, {Size = UDim2.new(0, 600, 0, 0)}):Play()
    task.delay(0.16, function() MainFrame.Visible = false MainFrame.Size = UDim2.new(0, 600, 0, 400) end)
end)

-- ============================================================
-- AIMBOT LOCK (Right Mouse Button)
-- ============================================================
local lockOn = false
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then lockOn = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then lockOn = false end
end)

-- ============================================================
-- CHARACTER MODS ON SPAWN
-- ============================================================
local function applyCharMods(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    if Settings.WalkspeedOn then
        humanoid.WalkSpeed = Settings.WalkspeedValue
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Settings.WalkspeedOn then humanoid.WalkSpeed = Settings.WalkspeedValue end
        end)
    end
    if Settings.HipHeightOn then
        humanoid.HipHeight = Settings.HipHeightValue
        humanoid:GetPropertyChangedSignal("HipHeight"):Connect(function()
            if Settings.HipHeightOn then humanoid.HipHeight = Settings.HipHeightValue end
        end)
    end
    task.wait(2)
    if Settings.AutoTPOn then startAutoTP() end
    if Settings.TPToSafeZone then teleportToSafeZone() end
    if Settings.KOTHZone then teleportToKOTHZone(Settings.KOTHZone) end
    if Settings.SeqTPOn then startSeqTP() end
    if Settings.AutoRespawnOn then setupAutoRespawn() end
    if Settings.AutoWallbangShoot then startWallbangShoot() end
end

LocalPlayer.CharacterAdded:Connect(applyCharMods)
if LocalPlayer.Character then applyCharMods(LocalPlayer.Character) end

-- ============================================================
-- GAME LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = Workspace:FindFirstChild(LocalPlayer.Name)
    if char then
        local gun = char:FindFirstChildOfClass("Tool")
        if gun then
            if Settings.InfiniteAmmo then findAndSetAmmo(gun) end
            if Settings.InstantReload then gun:SetAttribute("reloadTime", 0) end
            if Settings.NoRecoil then
                gun:SetAttribute("recoilMin", Vector2.new(0, 0))
                gun:SetAttribute("recoilMax", Vector2.new(0, 0))
                gun:SetAttribute("recoilAimReduction", Vector2.new(0, 0))
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
        aIbot()
    end
    if lockOn and Settings.AimbotOn then
        local lockedTarget = getNearestPlayer()
        if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Character.Head.Position)
        end
    end
    if Settings.AutoAimbotOn then
        local lockedTarget = getNearestPlayer()
        if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedTarget.Character.Head.Position)
        end
    end
    if Settings.AutoTPOn and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") and currentTarget.Character.Humanoid.Health > 0 then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Character.Head.Position)
    end
    if Settings.AutoTPOn then startAutoTP() end
end)

Workspace.DescendantAdded:Connect(function(descendant)
    if Settings.ESPOn and (descendant:IsA("BasePart") or descendant:IsA("Model")) then
        for _, target in ipairs(targetList) do
            if descendant.Name == target.Name then createESP(descendant) end
        end
    end
end)

findKOTHZones()
scanAndApplyESP()
