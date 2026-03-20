-- // MM2 God-Tier Script 2026 // Murder Mystery 2
-- KILL ALL + KILL AURA + KILL MURDERER FROM FAR + AUTO SHOOT + SILENT AIM + AUTO GRAB GUN + ESP + NOCLIP + GOD MODE

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

local Settings = {
    KillAll             = false,
    KillAura            = false,
    KillAuraRange       = 18,
    KillMurdererFar     = false,
    AutoShootMurderer   = false,
    SilentAim           = false,
    SilentAimFOV        = 350,
    AutoGrabGun         = false,
    MurderESP           = true,
    SheriffESP          = true,
    InnocentESP         = true,
    Noclip              = false,
    GodMode             = false,
}

-- Хранилище ESP объектов
local ESP_Objects = {}

-- Утилиты
local function getRole(plr)
    if not plr.Character then return "None" end
    local knife = plr.Backpack:FindFirstChild("Knife") or plr.Character:FindFirstChild("Knife")
    local gun   = plr.Backpack:FindFirstChild("Gun")   or plr.Character:FindFirstChild("Gun")
    if knife then return "Murderer" end
    if gun   then return "Sheriff"  end
    return "Innocent"
end

local function isAlive(plr)
    return plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
end

local function getMurderer()
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and getRole(plr) == "Murderer" and isAlive(plr) then
            return plr
        end
    end
    return nil
end

local function getNearestHead(part)
    if not part then return nil end
    local root = part:FindFirstChild("HumanoidRootPart") or part.PrimaryPart
    if not root then return nil end
    
    local head = part:FindFirstChild("Head")
    if head then return head end
    
    -- fallback
    return root
end

-- Silent Aim (hitscan redirection)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Settings.SilentAim and method == "FireServer" then
        if self.Name:lower():find("fire") or self.Name:lower():find("shoot") or self.Name:lower():find("hit") then
            local murderer = getMurderer()
            if murderer and isAlive(murderer) then
                local head = getNearestHead(murderer.Character)
                if head then
                    args[1] = head.Position + Vector3.new(0, 0.15, 0)  -- небольшое смещение для хита
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Kill Aura / Kill All
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local myPos  = myRoot.Position
    
    -- Kill All
    if Settings.KillAll then
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and isAlive(plr) and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < 30 then
                    pcall(function()
                        plr.Character.Humanoid.Health = 0
                    end)
                end
            end
        end
    end
    
    -- Kill Aura
    if Settings.KillAura then
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and isAlive(plr) and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist <= Settings.KillAuraRange then
                    pcall(function()
                        plr.Character.Humanoid.Health = 0
                    end)
                end
            end
        end
    end
end)

-- Auto Shoot Murderer + Kill Murderer from far
RunService.RenderStepped:Connect(function()
    if not Settings.AutoShootMurderer and not Settings.KillMurdererFar then return end
    
    local murderer = getMurderer()
    if not murderer or not isAlive(murderer) then return end
    
    local head = getNearestHead(murderer.Character)
    if not head then return end
    
    -- Камера смотрит на голову
    if Settings.AutoShootMurderer or Settings.KillMurdererFar then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    end
    
    -- Авто-выстрел (если есть пистолет)
    if Settings.AutoShootMurderer then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in tool:GetDescendants() do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("fire") or v.Name:lower():find("shoot")) then
                    v:FireServer(head.Position)
                    break
                end
            end
        end
    end
end)

-- Auto Grab Gun
RunService.Heartbeat:Connect(function()
    if not Settings.AutoGrabGun then return end
    if LocalPlayer.Character:FindFirstChild("Gun") then return end
    
    for _, drop in Workspace:GetChildren() do
        if drop:IsA("Tool") and drop.Name == "Gun" then
            local handle = drop:FindFirstChild("Handle") or drop.PrimaryPart
            if handle and (handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 35 then
                fireclickdetector(drop:FindFirstChildOfClass("ClickDetector"))
                break
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not Settings.Noclip then return end
    if not LocalPlayer.Character then return end
    
    for _, part in LocalPlayer.Character:GetDescendants() do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- God Mode (очень простой вариант — бесконечное здоровье)
spawn(function()
    while Settings.GodMode do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character.Humanoid
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end
        task.wait(0.4)
    end
end)

-- ESP (Murderer / Sheriff / Innocent)
local function createESP(plr)
    if plr == LocalPlayer then return end
    if ESP_Objects[plr] then return end
    
    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 8)
    if not root then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 180, 0, 45)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.Parent = root
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.4
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.Parent = billboard
    
    ESP_Objects[plr] = billboard
    
    local con; con = plr.CharacterRemoving:Connect(function()
        if ESP_Objects[plr] then
            ESP_Objects[plr]:Destroy()
            ESP_Objects[plr] = nil
        end
        con:Disconnect()
    end)
end

local function updateESP()
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        
        local role = getRole(plr)
        local color = Color3.fromRGB(220,220,50) -- innocent
        
        if role == "Murderer" and Settings.MurderESP then
            color = Color3.fromRGB(220, 30, 30)
        elseif role == "Sheriff" and Settings.SheriffESP then
            color = Color3.fromRGB(50, 120, 255)
        elseif role == "Innocent" and not (Settings.MurderESP or Settings.SheriffESP) then
            -- можно отключить innocent если не нужны
        else
            if ESP_Objects[plr] then
                ESP_Objects[plr]:Destroy()
                ESP_Objects[plr] = nil
            end
            continue
        end
        
        createESP(plr)
        if ESP_Objects[plr] then
            local lbl = ESP_Objects[plr]:FindFirstChild("TextLabel")
            if lbl then
                lbl.Text = string.format("%s  [%s]", plr.Name, role)
                lbl.TextColor3 = color
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.delay(1.5, updateESP) end)
end)

RunService.Heartbeat:Connect(function()
    if Settings.MurderESP or Settings.SheriffESP or Settings.InnocentESP then
        updateESP()
    end
end)

-- Простое меню (можно заменить на Rayfield / Linoria / любой UI-библиотеку)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("MM2 GOD-TIER 2026", "DarkTheme")

local Tab1 = Window:NewTab("Main")
local Tab1Sec = Tab1:NewSection("Combat")

Tab1Sec:NewToggle("Kill All (local)", "", function(v) Settings.KillAll = v end)
Tab1Sec:NewToggle("Kill Aura", "", function(v) Settings.KillAura = v end)
Tab1Sec:NewSlider("Kill Aura Range", "", 50, 8, function(v) Settings.KillAuraRange = v end)

Tab1Sec:NewToggle("Kill Murderer (Far)", "", function(v) Settings.KillMurdererFar = v end)
Tab1Sec:NewToggle("Auto Shoot Murderer", "", function(v) Settings.AutoShootMurderer = v end)
Tab1Sec:NewToggle("Silent Aim", "", function(v) Settings.SilentAim = v end)

local Tab2 = Window:NewTab("Visuals")
local Tab2Sec = Tab2:NewSection("ESP")

Tab2Sec:NewToggle("Murderer ESP", "", function(v) Settings.MurderESP = v end)
Tab2Sec:NewToggle("Sheriff ESP",   "", function(v) Settings.SheriffESP = v end)
Tab2Sec:NewToggle("Innocent ESP",  "", function(v) Settings.InnocentESP = v end)

local Tab3 = Window:NewTab("Misc")
local Tab3Sec = Tab3:NewSection("Movement / Exploits")

Tab3Sec:NewToggle("Auto Grab Gun", "", function(v) Settings.AutoGrabGun = v end)
Tab3Sec:NewToggle("Noclip", "", function(v) Settings.Noclip = v end)
Tab3Sec:NewToggle("God Mode", "", function(v) Settings.GodMode = v end)

print("MM2 GOD-TIER LOADED • KILL AURA • SILENT AIM • MURDER ESP • NOCLIP • GOD MODE")
