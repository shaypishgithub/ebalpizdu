-- ╔═══════════════════════════════════════════════════╗
-- ║         MEGAHACK v2.0  |  Purple Edition          ║
-- ║  Purple/Black UI · Auto-Shoot · Wallbang Fix      ║
-- ╚═══════════════════════════════════════════════════╝

local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local Workspace    = game:GetService("Workspace")
local Camera       = Workspace.CurrentCamera
local LocalPlayer  = Players.LocalPlayer

-- ════════════════════════════════════════════
--  COLOUR PALETTE  (Purple / Black)
-- ════════════════════════════════════════════
local C = {
    bg       = Color3.fromRGB(10,  10,  16),   -- main background
    panel    = Color3.fromRGB(16,  16,  26),   -- panels / sidebar
    card     = Color3.fromRGB(22,  20,  36),   -- toggle rows / cards
    cardHov  = Color3.fromRGB(32,  28,  52),   -- card hover
    acc1     = Color3.fromRGB(130,  80, 255),  -- primary accent (vivid purple)
    acc2     = Color3.fromRGB(180, 100, 255),  -- secondary accent (light purple)
    accDim   = Color3.fromRGB( 70,  40, 140),  -- dim accent
    border   = Color3.fromRGB( 55,  40,  90),  -- border / stroke
    txt      = Color3.fromRGB(235, 235, 248),  -- primary text
    txtMut   = Color3.fromRGB(155, 145, 185),  -- muted text
    txtDim   = Color3.fromRGB( 80,  70, 110),  -- dim text
    green    = Color3.fromRGB( 60, 220, 140),  -- on-state
    red      = Color3.fromRGB(255,  70,  75),  -- error / off-state accent
    warn     = Color3.fromRGB(255, 185,  45),  -- warning
    scrollB  = Color3.fromRGB(110,  70, 210),  -- scroll bar
}

-- ════════════════════════════════════════════
--  SETTINGS TABLE
-- ════════════════════════════════════════════
local Settings = {
    -- Aimbot
    AimbotOn        = false,
    AutoAimbotOn    = false,
    ShowFOV         = true,
    TeamCheck       = true,
    LockRadius      = 120,
    Wallbang        = false,
    -- Auto-Shoot (new top-level toggle)
    AutoShootOn     = false,
    AutoShootDelay  = 0.08,
    -- ESP
    ESPOn           = false,
    UseTeamColors   = false,
    OwnColor        = Color3.fromRGB(80, 160, 255),
    EnemyColor      = Color3.fromRGB(200, 40, 255),
    -- Gun Mods
    InstantReload   = false,
    InfiniteAmmo    = false,
    NoRecoil        = false,
    NoSpread        = false,
    FastShoot       = false,
    -- Character
    WalkspeedOn     = false,
    WalkspeedValue  = 50,
    HipHeightOn     = false,
    HipHeightValue  = 25,
    AutoBhopOn      = false,
    AirWalkOn       = false,
    SpinbotOn       = false,
    SpinbotSpeed    = 5,
    -- Teleport
    AutoTPOn        = false,
    TPSafeZoneOn    = false,
    -- Auto / AI
    AIbotOn         = false,
    SeqTPOn         = false,
    SeqTPDelay      = 4,
    AutoRespawnOn   = false,
    -- KOTH
    KOTHZone        = nil,
}

-- ════════════════════════════════════════════
--  STATE VARIABLES
-- ════════════════════════════════════════════
local createdESPs         = {}
local currentTarget       = nil
local tpTween             = nil
local lastFire            = 0
local spinAngle           = 0
local lastKillTime        = 0
local pathCoro            = nil
local currentEnemy        = nil
local diedConn            = nil
local seqTPCoro           = nil
local autoRespawnConn     = nil
local autoShootConn       = nil    -- NEW
local safeZonePos         = Vector3.new(0, 100, 0)
local KOTHZones           = {A=nil,B=nil,C=nil,D=nil,E=nil,F=nil,G=nil,H=nil}

-- ════════════════════════════════════════════
--  HELPER: TWEEN
-- ════════════════════════════════════════════
local function tw(obj, props, dur, style)
    TweenService:Create(obj,
        TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ════════════════════════════════════════════
--  CORE GAME LOGIC
-- ════════════════════════════════════════════
local function isTeamGame()
    local seen = {}
    for _, p in ipairs(Players:GetPlayers()) do
        seen[p.Team or "NIL"] = true
    end
    local n = 0; for _ in pairs(seen) do n += 1 end
    return n > 1
end

local function getNearestPlayer()
    local best, bestDist = nil, Settings.LockRadius
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
        local char = p.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        local hum  = char:FindFirstChild("Humanoid")
        if not head or not hum or hum.Health <= 0 then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not (onScreen or Settings.Wallbang) then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(cx, cy)).Magnitude
        if dist < bestDist then bestDist = dist; best = p end
    end
    return best
end

local function getNearestEnemy()
    local best, bestDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
        local char = p.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        local d = (root.Position - myRoot.Position).Magnitude
        if d < bestDist then bestDist = d; best = p end
    end
    return best
end

local function getAllEnemies()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
        local char = p.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if root and hum and hum.Health > 0 then
            table.insert(list, p)
        end
    end
    return list
end

local function getRandomEnemy()
    local list = getAllEnemies()
    if #list > 0 then return list[math.random(1, #list)] end
    return nil
end

local function getEnemyBehind()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if Settings.TeamCheck and isTeamGame() and p.Team == LocalPlayer.Team then continue end
        local char = p.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        local dir = (root.Position - myRoot.Position).Unit
        if myRoot.CFrame.LookVector:Dot(dir) < -0.5 then return p end
    end
    return nil
end

-- ─── Firing helpers ───────────────────────────────────────────
local function getGun()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Tool")
end

local function fireGun()
    local now = tick()
    if now - lastFire < Settings.AutoShootDelay then return end
    lastFire = now
    local tool = getGun()
    if not tool then return end
    for _, rem in ipairs(tool:GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            local n = rem.Name:lower()
            if n:find("fire") or n:find("shoot") or n:find("bullet") then
                pcall(function() rem:FireServer() end)
                break
            end
        end
    end
end

local function reloadGun()
    local tool = getGun()
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
    if char:FindFirstChildOfClass("Tool") then return end
    local hum = char:FindFirstChild("Humanoid")
    local gun = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if hum and gun then hum:EquipTool(gun) end
end

-- ─── Ammo helpers ─────────────────────────────────────────────
local function setInfiniteAmmo(gun)
    if not gun then return end
    for _, v in ipairs(gun:GetDescendants()) do
        if (v:IsA("IntValue") or v:IsA("NumberValue")) then
            local n = v.Name:lower()
            if n:find("ammo") or n:find("magazine") or n:find("clip") or n:find("bullet") then
                v.Value = 9999999
            end
        end
    end
    for _, a in ipairs({"magazineSize","ammo","maxAmmo","currentAmmo","reserveAmmo"}) do
        pcall(function() gun:SetAttribute(a, 9999999) end)
    end
end

-- ─── Movement ─────────────────────────────────────────────────
local function moveToEnemy(enemy)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    local eRoot = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
    if not eRoot then return end
    if pathCoro then pcall(coroutine.close, pathCoro) pathCoro = nil end
    pathCoro = coroutine.create(function()
        local path = PathfindingService:CreatePath({
            AgentRadius = 2, AgentHeight = 5, AgentCanJump = true,
        })
        local ok = pcall(function() path:ComputeAsync(root.Position, eRoot.Position) end)
        if ok and path.Status == Enum.PathStatus.Success then
            for _, wp in ipairs(path:GetWaypoints()) do
                if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                hum:MoveTo(wp.Position)
                hum.MoveToFinished:Wait()
            end
        else
            hum:MoveTo(eRoot.Position)
        end
    end)
    coroutine.resume(pathCoro)
end

-- ─── Teleport helpers ─────────────────────────────────────────
local function tpToPos(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root,
        TweenInfo.new(4, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(pos)}
    )
    tpTween:Play()
end

local function startAutoTP()
    if not Settings.AutoTPOn then return end
    if currentTarget and currentTarget.Character and
       currentTarget.Character:FindFirstChild("Humanoid") and
       currentTarget.Character.Humanoid.Health > 0 then return end
    currentTarget = getRandomEnemy()
    if not currentTarget then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then currentTarget = nil return end
    local eRoot = currentTarget.Character.HumanoidRootPart
    local targetPos = eRoot.Position + Vector3.new(0, 5, 0)
    if tpTween then tpTween:Cancel() end
    tpTween = TweenService:Create(root,
        TweenInfo.new(4, Enum.EasingStyle.Linear),
        {CFrame = CFrame.lookAt(targetPos, eRoot.Position)}
    )
    tpTween:Play()
end

local function teleportToKOTH(zone)
    if not zone then return end
    local part = Workspace:FindFirstChild(zone)
    if not part then return end
    tpToPos(part.Position + Vector3.new(0, 50, 0))
end

local function findKOTHZones()
    for z in pairs(KOTHZones) do
        local p = Workspace:FindFirstChild(z)
        if p then KOTHZones[z] = p end
    end
end

-- ─── Abilities ────────────────────────────────────────────────
local function autoBhop()
    if not Settings.AutoBhopOn then return end
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    if hum and hum:GetState() == Enum.HumanoidStateType.Running then
        hum.Jump = true
    end
end

local function airWalk()
    if not Settings.AirWalkOn then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent   = root
    game.Debris:AddItem(bv, 0.1)
end

local function spinbot()
    if not Settings.SpinbotOn then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local target = getNearestPlayer()
    if not target then return end
    local torso = target.Character and (
        target.Character:FindFirstChild("Torso") or
        target.Character:FindFirstChild("UpperTorso")
    )
    if not torso then return end
    spinAngle += Settings.SpinbotSpeed
    local radius = 10
    local newPos = torso.Position + Vector3.new(
        math.cos(math.rad(spinAngle)) * radius, 0,
        math.sin(math.rad(spinAngle)) * radius
    )
    tw(root, {CFrame = CFrame.new(newPos, torso.Position)}, 0.1, Enum.EasingStyle.Sine)
end

local function aiBot()
    if not Settings.AIbotOn then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    equipGun()
    local tool = getGun()
    local behind = getEnemyBehind()
    if behind and behind.Character and behind.Character:FindFirstChild("Head") then
        local hp = behind.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, hp)
        root.CFrame   = CFrame.lookAt(root.Position, Vector3.new(hp.X, root.Position.Y, hp.Z))
        if tool then fireGun() end
        return
    end
    local near = getNearestPlayer()
    if near and near.Character and near.Character:FindFirstChild("Head") then
        local hp = near.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, hp)
        root.CFrame   = CFrame.lookAt(root.Position, Vector3.new(hp.X, root.Position.Y, hp.Z))
        moveToEnemy(near)
        if tool then fireGun() end
        if near ~= currentEnemy then
            if diedConn then diedConn:Disconnect() end
            currentEnemy = near
            local eHum = near.Character.Humanoid
            diedConn = eHum.Died:Connect(function()
                if tick() - lastKillTime > 1 then
                    lastKillTime = tick()
                    reloadGun()
                end
            end)
        end
    end
end

-- ─── NEW: Auto-Shoot (continuous fire at nearest target) ───────
local function startAutoShoot()
    if autoShootConn then autoShootConn:Disconnect() autoShootConn = nil end
    if not Settings.AutoShootOn then return end
    autoShootConn = RunService.Heartbeat:Connect(function()
        if not Settings.AutoShootOn then
            autoShootConn:Disconnect(); autoShootConn = nil; return
        end
        local char = LocalPlayer.Character
        if not char then return end
        equipGun()
        local target = getNearestPlayer()
        if not target then return end
        local head = target.Character and target.Character:FindFirstChild("Head")
        if not head then return end
        -- Aim
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.lookAt(root.Position,
                Vector3.new(head.Position.X, root.Position.Y, head.Position.Z))
        end
        -- Fire
        fireGun()
    end)
end

-- ─── Sequential TP ────────────────────────────────────────────
local function startSeqTP()
    if seqTPCoro then pcall(coroutine.close, seqTPCoro) seqTPCoro = nil end
    if not Settings.SeqTPOn then return end
    seqTPCoro = coroutine.create(function()
        while Settings.SeqTPOn do
            local enemies = getAllEnemies()
            if #enemies == 0 then task.wait(2); continue end
            for _, enemy in ipairs(enemies) do
                if not Settings.SeqTPOn then break end
                local char = LocalPlayer.Character
                if not char then task.wait(1); continue end
                local root  = char:FindFirstChild("HumanoidRootPart")
                local eChar = enemy.Character
                if not root or not eChar then continue end
                local eRoot = eChar:FindFirstChild("HumanoidRootPart")
                local eHum  = eChar:FindFirstChild("Humanoid")
                if not eRoot or not eHum or eHum.Health <= 0 then continue end
                -- TP behind enemy
                local behindPos = eRoot.Position - (eRoot.CFrame.LookVector * 3) + Vector3.new(0, 2, 0)
                root.CFrame = CFrame.new(behindPos, eRoot.Position)
                equipGun()
                local shootUntil = tick() + Settings.SeqTPDelay
                while tick() < shootUntil do
                    if not Settings.SeqTPOn then break end
                    local cNow = LocalPlayer.Character
                    if cNow and cNow:FindFirstChild("HumanoidRootPart") and
                       enemy.Character and enemy.Character:FindFirstChild("Head") then
                        local hp = enemy.Character.Head.Position
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, hp)
                        cNow.HumanoidRootPart.CFrame = CFrame.lookAt(
                            cNow.HumanoidRootPart.Position,
                            Vector3.new(hp.X, cNow.HumanoidRootPart.Position.Y, hp.Z)
                        )
                        fireGun()
                    end
                    task.wait(0.05)
                end
            end
        end
    end)
    coroutine.resume(seqTPCoro)
end

-- ─── Auto Respawn ─────────────────────────────────────────────
local function setupAutoRespawn()
    if autoRespawnConn then autoRespawnConn:Disconnect(); autoRespawnConn = nil end
    if not Settings.AutoRespawnOn then return end
    local function hook(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        hum.Died:Connect(function()
            if Settings.AutoRespawnOn then
                task.wait(0.5)
                LocalPlayer:LoadCharacter()
            end
        end)
    end
    autoRespawnConn = LocalPlayer.CharacterAdded:Connect(hook)
    if LocalPlayer.Character then hook(LocalPlayer.Character) end
end

-- ─── ESP ──────────────────────────────────────────────────────
local function createESP(part)
    local p = Players:GetPlayerFromCharacter(part.Parent)
    if not p or p == LocalPlayer then return end
    local color = Settings.UseTeamColors
        and (p.Team == LocalPlayer.Team and Settings.OwnColor or Settings.EnemyColor)
        or Settings.EnemyColor

    local bb = Instance.new("BillboardGui")
    bb.Name            = "MHESP"
    bb.Adornee         = part
    bb.AlwaysOnTop     = true
    bb.Size            = UDim2.new(0, 100, 0, 100)
    bb.Parent          = part
    table.insert(createdESPs, bb)

    local dot = Instance.new("Frame")
    dot.AnchorPoint        = Vector2.new(0.5, 0.5)
    dot.Size               = UDim2.new(0, 6, 0, 6)
    dot.Position           = UDim2.new(0.5, 0, 0.5, 0)
    dot.BackgroundColor3   = color
    dot.BorderSizePixel    = 0
    dot.Parent             = bb
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dot
    local ds = Instance.new("UIStroke"); ds.Thickness = 2; ds.Parent = dot

    local lbl = Instance.new("TextLabel")
    lbl.Size                 = UDim2.new(1, 0, 0, 14)
    lbl.Position             = UDim2.new(0, 0, 0.5, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = p.Name
    lbl.TextColor3           = color
    lbl.TextSize             = 12
    lbl.Font                 = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.7
    lbl.Parent               = bb

    local hum = part.Parent and part.Parent:FindFirstChild("Humanoid")
    if hum then
        hum.Died:Connect(function()
            bb:Destroy()
            for i, e in ipairs(createdESPs) do
                if e == bb then table.remove(createdESPs, i); break end
            end
        end)
    end
end

local function removeAllESP()
    for _, e in ipairs(createdESPs) do e:Destroy() end
    createdESPs = {}
end

local function scanESP()
    if not Settings.ESPOn then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Head" and obj:IsA("BasePart") then
            createESP(obj)
        end
    end
end

-- ════════════════════════════════════════════
--  SCREEN GUI
-- ════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MegaHackPurple"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiOk = false
pcall(function()
    if gethui then ScreenGui.Parent = gethui(); guiOk = true end
end)
if not guiOk then
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui"); guiOk = true
    end)
end
if not guiOk then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- FOV circle
local FOVFrame = Instance.new("Frame")
FOVFrame.Size               = UDim2.new(0, Settings.LockRadius*2, 0, Settings.LockRadius*2)
FOVFrame.Position           = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.AnchorPoint        = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.ZIndex             = 10
FOVFrame.Visible            = Settings.ShowFOV
FOVFrame.Parent             = ScreenGui
local fovC = Instance.new("UICorner"); fovC.CornerRadius = UDim.new(1,0); fovC.Parent = FOVFrame
local fovS = Instance.new("UIStroke"); fovS.Thickness = 1.5; fovS.Color = C.acc1; fovS.Parent = FOVFrame
-- Animated FOV color
RunService.Heartbeat:Connect(function()
    if not fovS or not fovS.Parent then return end
    local h = (tick() * 0.2) % 1
    fovS.Color = Color3.fromHSV(0.75 + math.sin(tick()*0.5)*0.04, 0.9, 1)
end)

-- ════════════════════════════════════════════
--  MAIN FRAME
-- ════════════════════════════════════════════
local Main = Instance.new("Frame")
Main.Name               = "Main"
Main.Size               = UDim2.new(0, 560, 0, 390)
Main.Position           = UDim2.new(0.5, -280, 0.5, -195)
Main.BackgroundColor3   = C.bg
Main.BorderSizePixel    = 0
Main.ClipsDescendants   = true
Main.Visible            = false
Main.ZIndex             = 2
Main.Parent             = ScreenGui
local mainC = Instance.new("UICorner"); mainC.CornerRadius = UDim.new(0, 10); mainC.Parent = Main
local mainS = Instance.new("UIStroke"); mainS.Thickness = 1.5; mainS.Color = C.border; mainS.Parent = Main

-- Subtle animated background gradient
local mainGrad = Instance.new("UIGradient")
mainGrad.Rotation = 135
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.bg),
    ColorSequenceKeypoint.new(1, C.panel),
})
mainGrad.Parent = Main
RunService.Heartbeat:Connect(function()
    if not mainGrad or not mainGrad.Parent then return end
    mainGrad.Offset = Vector2.new(math.sin(tick()*.12)*.04, math.cos(tick()*.09)*.04)
end)

-- ─── Header bar ───────────────────────────────────────────────
local Header = Instance.new("Frame")
Header.Size               = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3   = C.panel
Header.BorderSizePixel    = 0
Header.ZIndex             = 3
Header.Parent             = Main
local hC = Instance.new("UICorner"); hC.CornerRadius = UDim.new(0, 10); hC.Parent = Header
local hFix = Instance.new("Frame")        -- square off bottom corners
hFix.Size             = UDim2.new(1,0,0,10)
hFix.Position         = UDim2.new(0,0,1,-10)
hFix.BackgroundColor3 = C.panel
hFix.BorderSizePixel  = 0
hFix.ZIndex           = 3
hFix.Parent           = Header

-- Animated accent line under header
local hLine = Instance.new("Frame")
hLine.Size             = UDim2.new(1, 0, 0, 1)
hLine.Position         = UDim2.new(0, 0, 1, -1)
hLine.BackgroundColor3 = C.acc1
hLine.BorderSizePixel  = 0
hLine.ZIndex           = 4
hLine.Parent           = Header
local hlG = Instance.new("UIGradient"); hlG.Rotation = 0
hlG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.acc1),
    ColorSequenceKeypoint.new(1, C.acc2),
})
hlG.Parent = hLine
RunService.Heartbeat:Connect(function()
    if not hlG or not hlG.Parent then return end
    hlG.Offset = Vector2.new(math.sin(tick()*1.1)*.4, 0)
end)

-- Skull icon + title
local hTitleLbl = Instance.new("TextLabel")
hTitleLbl.Size               = UDim2.new(1, -100, 1, 0)
hTitleLbl.Position           = UDim2.new(0, 12, 0, 0)
hTitleLbl.BackgroundTransparency = 1
hTitleLbl.Text               = "☠  MEGAHACK"
hTitleLbl.TextColor3         = C.txt
hTitleLbl.Font               = Enum.Font.GothamBlack
hTitleLbl.TextSize           = 17
hTitleLbl.TextXAlignment     = Enum.TextXAlignment.Left
hTitleLbl.ZIndex             = 4
hTitleLbl.Parent             = Header
-- Gradient on title text
local hTG = Instance.new("UIGradient"); hTG.Rotation = 0
hTG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.acc1),
    ColorSequenceKeypoint.new(1, C.acc2),
})
hTG.Parent = hTitleLbl
RunService.Heartbeat:Connect(function()
    if not hTG or not hTG.Parent then return end
    hTG.Offset = Vector2.new(math.sin(tick()*.6)*.25, 0)
end)

local hVerLbl = Instance.new("TextLabel")
hVerLbl.Size               = UDim2.new(0, 60, 0, 12)
hVerLbl.Position           = UDim2.new(0, 45, 0, 28)
hVerLbl.BackgroundTransparency = 1
hVerLbl.Text               = "v2.0  PURPLE"
hVerLbl.TextColor3         = C.acc1
hVerLbl.Font               = Enum.Font.Gotham
hVerLbl.TextSize            = 9
hVerLbl.TextXAlignment      = Enum.TextXAlignment.Left
hVerLbl.ZIndex              = 4
hVerLbl.Parent              = Header

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size               = UDim2.new(0, 26, 0, 26)
CloseBtn.Position           = UDim2.new(1, -34, 0.5, -13)
CloseBtn.BackgroundColor3   = C.accDim
CloseBtn.BorderSizePixel    = 0
CloseBtn.Text               = "✕"
CloseBtn.TextColor3         = C.txt
CloseBtn.Font               = Enum.Font.GothamBold
CloseBtn.TextSize           = 13
CloseBtn.ZIndex             = 5
CloseBtn.Parent             = Header
local clC = Instance.new("UICorner"); clC.CornerRadius = UDim.new(0, 6); clC.Parent = CloseBtn

-- ─── Sidebar ──────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0, 128, 1, -44)
Sidebar.Position         = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = C.panel
Sidebar.BorderSizePixel  = 0
Sidebar.ZIndex           = 3
Sidebar.Parent           = Main
local sideS = Instance.new("UIStroke"); sideS.Thickness = 1; sideS.Color = C.border; sideS.Transparency = 0.4; sideS.Parent = Sidebar

-- Sidebar list layout
local sideLL = Instance.new("UIListLayout")
sideLL.Padding    = UDim.new(0, 2)
sideLL.SortOrder  = Enum.SortOrder.LayoutOrder
sideLL.Parent     = Sidebar
local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop   = UDim.new(0, 8)
sidePad.PaddingLeft  = UDim.new(0, 5)
sidePad.PaddingRight = UDim.new(0, 5)
sidePad.Parent       = Sidebar

-- ─── Content Area ─────────────────────────────────────────────
local ContentArea = Instance.new("Frame")
ContentArea.Size             = UDim2.new(1, -136, 1, -52)
ContentArea.Position         = UDim2.new(0, 136, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.ZIndex           = 3
ContentArea.Parent           = Main

-- ════════════════════════════════════════════
--  WIDGET HELPERS
-- ════════════════════════════════════════════

-- Scroll frame for each tab
local function makeScrollFrame(parent)
    local sf = Instance.new("ScrollingFrame")
    sf.Size              = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = C.scrollB
    sf.CanvasSize        = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.BorderSizePixel   = 0
    sf.Visible           = false
    sf.ZIndex            = 4
    sf.Parent            = parent
    local ll = Instance.new("UIListLayout")
    ll.Padding    = UDim.new(0, 5)
    ll.SortOrder  = Enum.SortOrder.LayoutOrder
    ll.Parent     = sf
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft   = UDim.new(0, 6)
    pad.PaddingRight  = UDim.new(0, 6)
    pad.Parent        = sf
    return sf
end

-- Section separator label
local function makeSep(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text              = "  " .. text:upper()
    lbl.TextColor3        = C.acc1
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 9
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 5
    lbl.LayoutOrder       = order or 0
    lbl.Parent            = parent
    return lbl
end

-- Toggle row
local function makeToggle(parent, label, state, order, cb)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel  = 0
    row.ZIndex           = 5
    row.LayoutOrder      = order or 0
    row.Parent           = parent
    local rC = Instance.new("UICorner"); rC.CornerRadius = UDim.new(0, 7); rC.Parent = row
    local rS = Instance.new("UIStroke"); rS.Thickness = 1; rS.Color = C.border; rS.Transparency = 0.5; rS.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -54, 1, 0)
    lbl.Position          = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = C.txt
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 12
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 6
    lbl.Parent            = row

    local bg = Instance.new("Frame")
    bg.Size             = UDim2.new(0, 38, 0, 20)
    bg.Position         = UDim2.new(1, -46, 0.5, -10)
    bg.BackgroundColor3 = state and C.acc1 or C.accDim
    bg.BorderSizePixel  = 0
    bg.ZIndex           = 6
    bg.Parent           = row
    local bgC = Instance.new("UICorner"); bgC.CornerRadius = UDim.new(1, 0); bgC.Parent = bg

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 7
    knob.Parent           = bg
    local knC = Instance.new("UICorner"); knC.CornerRadius = UDim.new(1, 0); knC.Parent = knob

    local isOn = state
    local overlay = Instance.new("TextButton")
    overlay.Size               = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.Text               = ""
    overlay.ZIndex             = 8
    overlay.Parent             = row

    -- Hover effect
    overlay.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = C.cardHov}, 0.1) end)
    overlay.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = C.card}, 0.1) end)

    overlay.MouseButton1Click:Connect(function()
        isOn = not isOn
        tw(bg,   {BackgroundColor3 = isOn and C.acc1 or C.accDim}, 0.15)
        tw(knob, {Position = isOn and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}, 0.15)
        if cb then cb(isOn) end
    end)

    -- External setter
    local function set(v)
        isOn = v
        tw(bg,   {BackgroundColor3 = v and C.acc1 or C.accDim}, 0.15)
        tw(knob, {Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}, 0.15)
    end

    return row, set
end

-- Input row
local function makeInput(parent, label, default, order, cb)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel  = 0
    row.ZIndex           = 5
    row.LayoutOrder      = order or 0
    row.Parent           = parent
    local rC = Instance.new("UICorner"); rC.CornerRadius = UDim.new(0, 7); rC.Parent = row
    local rS = Instance.new("UIStroke"); rS.Thickness = 1; rS.Color = C.border; rS.Transparency = 0.5; rS.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0.55, 0, 1, 0)
    lbl.Position          = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = C.txtMut
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 12
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 6
    lbl.Parent            = row

    local ibg = Instance.new("Frame")
    ibg.Size             = UDim2.new(0, 82, 0, 24)
    ibg.Position         = UDim2.new(1, -90, 0.5, -12)
    ibg.BackgroundColor3 = C.bg
    ibg.BorderSizePixel  = 0
    ibg.ZIndex           = 6
    ibg.Parent           = row
    local ibgC = Instance.new("UICorner"); ibgC.CornerRadius = UDim.new(0, 5); ibgC.Parent = ibg
    local ibgS = Instance.new("UIStroke"); ibgS.Thickness = 1; ibgS.Color = C.border; ibgS.Parent = ibg

    local box = Instance.new("TextBox")
    box.Size               = UDim2.new(1, -6, 1, 0)
    box.Position           = UDim2.new(0, 3, 0, 0)
    box.BackgroundTransparency = 1
    box.Text               = tostring(default)
    box.TextColor3         = C.txt
    box.Font               = Enum.Font.Gotham
    box.TextSize           = 12
    box.ZIndex             = 7
    box.Parent             = ibg
    box.FocusLost:Connect(function()
        if cb then cb(box.Text) end
    end)
    return row
end

-- Action button
local function makeButton(parent, label, order, cb)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C.acc1
    btn.BorderSizePixel  = 0
    btn.Text             = label
    btn.TextColor3       = Color3.new(1, 1, 1)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.ZIndex           = 5
    btn.LayoutOrder      = order or 0
    btn.Parent           = parent
    local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(0, 7); bC.Parent = btn
    local bG = Instance.new("UIGradient"); bG.Rotation = 45
    bG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.acc1),
        ColorSequenceKeypoint.new(1, C.acc2),
    })
    bG.Parent = btn
    btn.MouseEnter:Connect(function()  tw(btn, {BackgroundTransparency = 0},    0.1) end)
    btn.MouseLeave:Connect(function()  tw(btn, {BackgroundTransparency = 0.08}, 0.1) end)
    btn.MouseButton1Click:Connect(function()
        tw(btn, {Size = UDim2.new(0.97, 0, 0, 29)}, 0.08, Enum.EasingStyle.Back)
        task.delay(0.1, function()
            if btn and btn.Parent then
                tw(btn, {Size = UDim2.new(1, 0, 0, 32)}, 0.18, Enum.EasingStyle.Back)
            end
        end)
        if cb then cb() end
    end)
    return btn
end

-- ════════════════════════════════════════════
--  TABS
-- ════════════════════════════════════════════
local TabDefs = {
    {"Aimbot",    "🎯"},
    {"ESP",       "👁"},
    {"Gun Mods",  "🔫"},
    {"Character", "🏃"},
    {"Auto",      "🤖"},
    {"KOTH",      "⚑"},
}
local TabFrames  = {}
local TabBtns    = {}
local ActiveTab  = "Aimbot"

local function switchTab(name)
    ActiveTab = name
    for tName, sf in pairs(TabFrames) do
        sf.Visible = tName == name
    end
    for tName, btn in pairs(TabBtns) do
        if tName == name then
            tw(btn, {BackgroundColor3 = C.acc1}, 0.15)
            btn.TextColor3 = Color3.new(1, 1, 1)
        else
            tw(btn, {BackgroundColor3 = C.card}, 0.15)
            btn.TextColor3 = C.txtMut
        end
    end
end

for i, def in ipairs(TabDefs) do
    local name, icon = def[1], def[2]
    TabFrames[name] = makeScrollFrame(ContentArea)

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = name == ActiveTab and C.acc1 or C.card
    btn.BorderSizePixel  = 0
    btn.Text             = icon .. "  " .. name
    btn.TextColor3       = name == ActiveTab and Color3.new(1,1,1) or C.txtMut
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 12
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.LayoutOrder      = i
    btn.ZIndex           = 4
    btn.Parent           = Sidebar
    local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(0, 6); bC.Parent = btn
    local bP = Instance.new("UIPadding"); bP.PaddingLeft = UDim.new(0, 9); bP.Parent = btn
    TabBtns[name] = btn
    btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then tw(btn, {BackgroundColor3 = C.cardHov}, 0.1) end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then tw(btn, {BackgroundColor3 = C.card}, 0.1) end
    end)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

TabFrames["Aimbot"].Visible = true

-- ════════════════════════════════════════════
--  AIMBOT TAB
-- ════════════════════════════════════════════
local AbSF = TabFrames["Aimbot"]
makeSep(AbSF, "Aimbot Settings", 1)
makeToggle(AbSF, "Aimbot  (hold RMB)", Settings.AimbotOn,     2, function(v) Settings.AimbotOn = v end)
makeToggle(AbSF, "Auto Aimbot",         Settings.AutoAimbotOn, 3, function(v) Settings.AutoAimbotOn = v end)
makeToggle(AbSF, "Show FOV Circle",     Settings.ShowFOV,      4, function(v)
    Settings.ShowFOV = v; FOVFrame.Visible = v
end)
makeToggle(AbSF, "Team Check",          Settings.TeamCheck,    5, function(v) Settings.TeamCheck = v end)
makeToggle(AbSF, "Wallbang (through walls)", Settings.Wallbang, 6, function(v)
    Settings.Wallbang = v
end)
makeSep(AbSF, "FOV", 7)
makeInput(AbSF, "FOV Radius", Settings.LockRadius, 8, function(v)
    local n = tonumber(v)
    if n then
        Settings.LockRadius = n
        FOVFrame.Size = UDim2.new(0, n*2, 0, n*2)
    end
end)

-- ════════════════════════════════════════════
--  ESP TAB
-- ════════════════════════════════════════════
local EspSF = TabFrames["ESP"]
makeSep(EspSF, "ESP Settings", 1)
makeToggle(EspSF, "ESP Enabled", Settings.ESPOn, 2, function(v)
    Settings.ESPOn = v
    if v then scanESP() else removeAllESP() end
end)
makeToggle(EspSF, "Use Team Colors", Settings.UseTeamColors, 3, function(v)
    Settings.UseTeamColors = v
    removeAllESP()
    if Settings.ESPOn then scanESP() end
end)

-- ════════════════════════════════════════════
--  GUN MODS TAB
-- ════════════════════════════════════════════
local GunSF = TabFrames["Gun Mods"]
makeSep(GunSF, "Gun Modifications", 1)
makeToggle(GunSF, "Instant Reload",  Settings.InstantReload, 2, function(v) Settings.InstantReload = v end)
makeToggle(GunSF, "Infinite Ammo",   Settings.InfiniteAmmo,  3, function(v) Settings.InfiniteAmmo  = v end)
makeToggle(GunSF, "No Recoil",       Settings.NoRecoil,      4, function(v) Settings.NoRecoil      = v end)
makeToggle(GunSF, "No Spread",       Settings.NoSpread,      5, function(v) Settings.NoSpread      = v end)
makeToggle(GunSF, "Fast Shoot",      Settings.FastShoot,     6, function(v) Settings.FastShoot     = v end)
makeSep(GunSF, "Wallbang (Penetration)", 7)
makeToggle(GunSF, "Enable Wallbang",  Settings.Wallbang, 8, function(v)
    Settings.Wallbang = v
end)

-- ════════════════════════════════════════════
--  CHARACTER TAB
-- ════════════════════════════════════════════
local ChrSF = TabFrames["Character"]
makeSep(ChrSF, "Movement", 1)
makeToggle(ChrSF, "Walkspeed Boost", Settings.WalkspeedOn, 2, function(v)
    Settings.WalkspeedOn = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = v and Settings.WalkspeedValue or 16 end
end)
makeInput(ChrSF, "Walk Speed Value", Settings.WalkspeedValue, 3, function(v)
    local n = tonumber(v)
    if n then Settings.WalkspeedValue = math.min(n, 1000) end
    local hum = Settings.WalkspeedOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = Settings.WalkspeedValue end
end)
makeToggle(ChrSF, "Hip Height", Settings.HipHeightOn, 4, function(v)
    Settings.HipHeightOn = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.HipHeight = v and Settings.HipHeightValue or 0 end
end)
makeInput(ChrSF, "Hip Height Value", Settings.HipHeightValue, 5, function(v)
    local n = tonumber(v)
    if n then Settings.HipHeightValue = math.min(n, 1000) end
    local hum = Settings.HipHeightOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.HipHeight = Settings.HipHeightValue end
end)
makeSep(ChrSF, "Abilities", 6)
makeToggle(ChrSF, "Auto Bhop",  Settings.AutoBhopOn, 7, function(v) Settings.AutoBhopOn = v end)
makeToggle(ChrSF, "Air Walk",   Settings.AirWalkOn,  8, function(v) Settings.AirWalkOn  = v end)
makeSep(ChrSF, "Effects", 9)
makeToggle(ChrSF, "Spinbot", Settings.SpinbotOn, 10, function(v) Settings.SpinbotOn = v end)
makeInput(ChrSF, "Spinbot Speed", Settings.SpinbotSpeed, 11, function(v)
    local n = tonumber(v); if n then Settings.SpinbotSpeed = n end
end)
makeSep(ChrSF, "Teleport", 12)
makeToggle(ChrSF, "Auto TP (random enemy)", Settings.AutoTPOn, 13, function(v)
    Settings.AutoTPOn = v
    if v then startAutoTP()
    else currentTarget = nil; if tpTween then tpTween:Cancel() end
    end
end)
makeToggle(ChrSF, "TP to Safe Zone", Settings.TPSafeZoneOn, 14, function(v)
    Settings.TPSafeZoneOn = v
    if v then tpToPos(safeZonePos) end
end)

-- ════════════════════════════════════════════
--  AUTO TAB
-- ════════════════════════════════════════════
local AutoSF = TabFrames["Auto"]
makeSep(AutoSF, "Auto-Shoot  ★ NEW", 1)
makeToggle(AutoSF, "Auto Shoot (nearest enemy)", Settings.AutoShootOn, 2, function(v)
    Settings.AutoShootOn = v
    startAutoShoot()
end)
makeInput(AutoSF, "Shoot Delay (sec)", Settings.AutoShootDelay, 3, function(v)
    local n = tonumber(v); if n then Settings.AutoShootDelay = math.max(0.01, n) end
end)
makeSep(AutoSF, "AI Bot", 4)
makeToggle(AutoSF, "AIbot (full auto-combat)", Settings.AIbotOn, 5, function(v) Settings.AIbotOn = v end)
makeSep(AutoSF, "Sequential TP + Shoot", 6)
makeToggle(AutoSF, "Seq TP + Auto Shoot", Settings.SeqTPOn, 7, function(v)
    Settings.SeqTPOn = v
    if v then startSeqTP()
    else if seqTPCoro then pcall(coroutine.close, seqTPCoro); seqTPCoro = nil end
    end
end)
makeInput(AutoSF, "Shoot Duration (sec)", Settings.SeqTPDelay, 8, function(v)
    local n = tonumber(v); if n then Settings.SeqTPDelay = math.max(0.5, n) end
end)
makeSep(AutoSF, "Respawn", 9)
makeToggle(AutoSF, "Auto Respawn", Settings.AutoRespawnOn, 10, function(v)
    Settings.AutoRespawnOn = v; setupAutoRespawn()
end)

-- Info card
local infoCard = Instance.new("Frame")
infoCard.Size             = UDim2.new(1, 0, 0, 56)
infoCard.BackgroundColor3 = C.card
infoCard.BorderSizePixel  = 0
infoCard.ZIndex           = 5
infoCard.LayoutOrder      = 11
infoCard.Parent           = AutoSF
local icC = Instance.new("UICorner"); icC.CornerRadius = UDim.new(0, 7); icC.Parent = infoCard
local icS = Instance.new("UIStroke"); icS.Thickness = 1; icS.Color = C.border; icS.Transparency = 0.5; icS.Parent = infoCard
local icL = Instance.new("TextLabel")
icL.Size               = UDim2.new(1, -14, 1, -10)
icL.Position           = UDim2.new(0, 8, 0, 5)
icL.BackgroundTransparency = 1
icL.TextWrapped        = true
icL.Text               = "Auto Shoot: fires at the nearest enemy continuously. Works through walls if Wallbang is enabled."
icL.TextColor3         = C.txtMut
icL.Font               = Enum.Font.Gotham
icL.TextSize           = 10
icL.TextXAlignment     = Enum.TextXAlignment.Left
icL.TextYAlignment     = Enum.TextYAlignment.Top
icL.ZIndex             = 6
icL.Parent             = infoCard

-- ════════════════════════════════════════════
--  KOTH TAB
-- ════════════════════════════════════════════
local KothSF = TabFrames["KOTH"]
makeSep(KothSF, "King of the Hill Zones", 1)
for i, zone in ipairs({"A","B","C","D","E","F","G","H"}) do
    makeButton(KothSF, "⚑  Teleport to Zone " .. zone, i+1, function()
        Settings.KOTHZone = zone
        teleportToKOTH(zone)
    end)
end

-- ════════════════════════════════════════════
--  FLOATING TOGGLE BUTTON
-- ════════════════════════════════════════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size               = UDim2.new(0, 68, 0, 68)
ToggleBtn.Position           = UDim2.new(0, 18, 0, 18)
ToggleBtn.BackgroundColor3   = C.panel
ToggleBtn.BackgroundTransparency = 0.05
ToggleBtn.BorderSizePixel    = 0
ToggleBtn.Text               = ""
ToggleBtn.ZIndex             = 10
ToggleBtn.Parent             = ScreenGui
local tbC = Instance.new("UICorner"); tbC.CornerRadius = UDim.new(0, 13); tbC.Parent = ToggleBtn
local tbS = Instance.new("UIStroke"); tbS.Thickness = 2; tbS.Color = C.acc1; tbS.Parent = ToggleBtn
-- Animated stroke color
RunService.Heartbeat:Connect(function()
    if not tbS or not tbS.Parent then return end
    tbS.Color = Color3.fromHSV(0.75 + math.sin(tick()*0.5)*0.04, 0.9, 1)
end)

local tbIco = Instance.new("TextLabel")
tbIco.Size               = UDim2.new(1, 0, 0.55, 0)
tbIco.Position           = UDim2.new(0, 0, 0, 6)
tbIco.BackgroundTransparency = 1
tbIco.Text               = "☠"
tbIco.TextColor3         = C.acc1
tbIco.Font               = Enum.Font.GothamBlack
tbIco.TextSize           = 26
tbIco.ZIndex             = 11
tbIco.Parent             = ToggleBtn
RunService.Heartbeat:Connect(function()
    if not tbIco or not tbIco.Parent then return end
    tbIco.TextColor3 = Color3.fromHSV(0.75 + math.sin(tick()*0.5)*0.04, 0.9, 1)
end)

local tbTxt = Instance.new("TextLabel")
tbTxt.Size               = UDim2.new(1, 0, 0.32, 0)
tbTxt.Position           = UDim2.new(0, 0, 0.68, 0)
tbTxt.BackgroundTransparency = 1
tbTxt.Text               = "MENU"
tbTxt.TextColor3         = C.txtMut
tbTxt.Font               = Enum.Font.GothamBold
tbTxt.TextSize           = 9
tbTxt.ZIndex             = 11
tbTxt.Parent             = ToggleBtn

-- ════════════════════════════════════════════
--  DRAG SYSTEM
-- ════════════════════════════════════════════
local function makeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = i.Position
            startPos  = target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
                         i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

makeDraggable(Header,    Main)
makeDraggable(ToggleBtn, ToggleBtn)

-- ════════════════════════════════════════════
--  OPEN / CLOSE WINDOW
-- ════════════════════════════════════════════
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        tw(Main, {
            Size     = UDim2.new(0, 560, 0, 390),
            Position = UDim2.new(0.5, -280, 0.5, -195),
        }, 0.38, Enum.EasingStyle.Back)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    tw(Main, {Size = UDim2.new(0, 560, 0, 0)}, 0.2)
    task.delay(0.22, function()
        Main.Visible = false
        Main.Size = UDim2.new(0, 560, 0, 390)
    end)
end)

-- ════════════════════════════════════════════
--  AIMBOT LOCK (RMB)
-- ════════════════════════════════════════════
local lockOn = false
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        lockOn = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        lockOn = false
    end
end)

-- ════════════════════════════════════════════
--  CHARACTER MODS ON SPAWN
-- ════════════════════════════════════════════
local function applyCharMods(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
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
    task.wait(1)
    if Settings.AutoTPOn then startAutoTP() end
    if Settings.SeqTPOn  then startSeqTP()  end
    if Settings.AutoShootOn then startAutoShoot() end
    if Settings.AutoRespawnOn then setupAutoRespawn() end
end

LocalPlayer.CharacterAdded:Connect(applyCharMods)
if LocalPlayer.Character then applyCharMods(LocalPlayer.Character) end

-- ════════════════════════════════════════════
--  MAIN RENDER LOOP
-- ════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- Gun mods
    local char = Workspace:FindFirstChild(LocalPlayer.Name)
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            if Settings.InfiniteAmmo    then setInfiniteAmmo(tool) end
            if Settings.InstantReload   then tool:SetAttribute("reloadTime", 0) end
            if Settings.NoRecoil        then
                tool:SetAttribute("recoilMin",          Vector2.new(0,0))
                tool:SetAttribute("recoilMax",          Vector2.new(0,0))
                tool:SetAttribute("recoilAimReduction", Vector2.new(0,0))
            end
            if Settings.NoSpread  then tool:SetAttribute("spread", 0) end
            if Settings.FastShoot then tool:SetAttribute("rateOfFire", math.huge) end
            -- WALLBANG: maximize bullet penetration
            if Settings.Wallbang  then
                tool:SetAttribute("penetration",  math.huge)
                tool:SetAttribute("canPenetrate", true)
                tool:SetAttribute("wallbang",     true)
                tool:SetAttribute("range",        math.huge)
            end
        end
        autoBhop()
        airWalk()
        spinbot()
        aiBot()
    end

    -- Aimbot (RMB held)
    if lockOn and Settings.AimbotOn then
        local target = getNearestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- Auto Aimbot (always on)
    if Settings.AutoAimbotOn then
        local target = getNearestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- Auto TP aim assist
    if Settings.AutoTPOn and currentTarget and currentTarget.Character then
        local head = currentTarget.Character:FindFirstChild("Head")
        local hum  = currentTarget.Character:FindFirstChild("Humanoid")
        if head and hum and hum.Health > 0 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
        startAutoTP()
    end
end)

-- ════════════════════════════════════════════
--  ESP — auto-attach on new characters
-- ════════════════════════════════════════════
Workspace.DescendantAdded:Connect(function(obj)
    if Settings.ESPOn and obj.Name == "Head" and obj:IsA("BasePart") then
        task.wait(0.1)
        createESP(obj)
    end
end)

-- ════════════════════════════════════════════
--  STARTUP
-- ════════════════════════════════════════════
findKOTHZones()
scanESP()

-- Show toggle button immediately; window stays hidden until clicked
Main.Visible   = false
ToggleBtn.Size = UDim2.new(0, 0, 0, 0)
tw(ToggleBtn, {Size = UDim2.new(0, 68, 0, 68)}, 0.5, Enum.EasingStyle.Back)
