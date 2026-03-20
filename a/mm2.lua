-- // MM2 GOD-TIER 2026 • Rayfield UI • Enhanced Gradient Design • Full Update Support

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

-- Глобальная переменная для контроля GUI (работает даже после обновлений)
_G.MM2GodModeGUI = {
    Open = true,
    Window = nil,
    ToggleButton = nil
}

-- Функция для создания градиентного фона с анимацией
local function createGradient(frame, color1, color2, direction)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = direction or 135
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Parent = frame
    return gradient
end

-- Загрузка Rayfield (с обработкой ошибок)
local RayfieldLoaded = false
local Rayfield
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    RayfieldLoaded = true
end)

if not RayfieldLoaded then
    -- Альтернативный UI если Rayfield недоступен
    warn("Rayfield not loaded, using fallback UI")
    -- Создаем простой ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2GodModeGUI"
    screenGui.Parent = game.CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    createGradient(mainFrame, Color3.fromRGB(30, 60, 120), Color3.fromRGB(10, 10, 25), 135)
    
    -- Добавляем кнопку закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = mainFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 10, 1, -60)
    toggleBtn.Text = "⚡"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 24
    toggleBtn.Parent = screenGui
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        toggleBtn.Visible = true
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        toggleBtn.Visible = false
    end)
    
    -- Добавляем текст
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "MM2 GOD-TIER 2026"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = mainFrame
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0, 60)
    infoText.Position = UDim2.new(0, 10, 0, 50)
    infoText.Text = "GUI Loaded Successfully!\nUse the toggle button to show/hide"
    infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoText.BackgroundTransparency = 1
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 14
    infoText.TextWrapped = true
    infoText.Parent = mainFrame
end

-- Основные настройки (если Rayfield загружен, создаем красивое окно)
if RayfieldLoaded then
    -- Создаем кастомные цвета для градиента
    local gradientColors = {
        Start = Color3.fromRGB(40, 80, 180),
        End = Color3.fromRGB(15, 15, 35)
    }
    
    local Window = Rayfield:CreateWindow({
        Name = "MM2 GOD-TIER 2026",
        LoadingTitle = "Murder Mystery 2 • Premium",
        LoadingSubtitle = "Enhanced Edition • Fully Updated",
        ConfigurationSaving = { 
            Enabled = true,
            FolderName = "MM2GodMode",
            FileName = "Config_v2"
        },
        Discord = { 
            Enabled = false,
            Invite = "",
            RememberJoins = false
        },
        KeySystem = false,
        -- Кастомные цвета окна
        Theme = {
            Background = gradientColors.Start,
            Accent = Color3.fromRGB(80, 150, 255),
            Secondary = gradientColors.End
        }
    })
    
    -- Сохраняем окно в глобальную переменную для контроля
    _G.MM2GodModeGUI.Window = Window
    
    -- Функция для создания кнопки Open/Close (красивая анимация)
    local function createToggleButton()
        local screenGui = game.CoreGui:FindFirstChild("Rayfield")
        if not screenGui then return end
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = "MM2ToggleButton"
        toggleBtn.Size = UDim2.new(0, 60, 0, 60)
        toggleBtn.Position = UDim2.new(0, 20, 1, -80)
        toggleBtn.Text = "⚡"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
        toggleBtn.BackgroundTransparency = 0.15
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 28
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Parent = screenGui
        
        -- Добавляем градиент на кнопку
        local btnGradient = Instance.new("UIGradient")
        btnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 120, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 70, 180))
        })
        btnGradient.Rotation = 45
        btnGradient.Parent = toggleBtn
        
        -- Анимация при наведении
        toggleBtn.MouseEnter:Connect(function()
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)}):Play()
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        
        toggleBtn.MouseLeave:Connect(function()
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
        end)
        
        local isOpen = true
        
        toggleBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                Window:Open()
                toggleBtn.Text = "⚡"
                TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 100, 200)}):Play()
            else
                Window:Close()
                toggleBtn.Text = "🔒"
                TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 50, 150)}):Play()
            end
        end)
        
        _G.MM2GodModeGUI.ToggleButton = toggleBtn
    end
    
    -- Ждем пока загрузится Rayfield UI и создаем кнопку
    task.wait(1)
    pcall(createToggleButton)
end

-- Настройки (без изменений, но с улучшенной стабильностью)
local Settings = {
    KillAura = false,
    KillAuraRange = 18,
    KillMurdererFar = false,
    AutoShootMurderer = false,
    SilentAim = false,
    AutoGrabGun = false,
    MurderESP = true,
    SheriffESP = true,
    InnocentESP = false,
    Noclip = false,
    GodMode = false,
}

-- Утилиты с защитой от ошибок
local function getRole(plr)
    if not plr or not plr.Character then return "None" end
    local knife = pcall(function() return plr.Backpack:FindFirstChild("Knife") or plr.Character:FindFirstChild("Knife") end)
    local gun = pcall(function() return plr.Backpack:FindFirstChild("Gun") or plr.Character:FindFirstChild("Gun") end)
    if knife then return "Murderer" end
    if gun then return "Sheriff" end
    return "Innocent"
end

local function isAlive(plr)
    return plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
end

local function getMurderer()
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and getRole(plr) == "Murderer" and isAlive(plr) then
            return plr
        end
    end
    return nil
end

local function getNearestHead(char)
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    return head or char:FindFirstChild("HumanoidRootPart")
end

-- Silent Aim с улучшенной стабильностью
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Settings.SilentAim and method == "FireServer" then
        if self.Name and (self.Name:lower():find("fire") or self.Name:lower():find("shoot") or self.Name:lower():find("hit")) then
            local murd = getMurderer()
            if murd and isAlive(murd) then
                local head = getNearestHead(murd.Character)
                if head then
                    args[1] = head.Position + Vector3.new(0, 0.12, 0)
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Kill Aura с оптимизацией
RunService.Heartbeat:Connect(function()
    if not Settings.KillAura then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local myPos  = myRoot.Position
    
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and isAlive(plr) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist <= Settings.KillAuraRange then
                pcall(function() 
                    plr.Character.Humanoid.Health = 0 
                end)
            end
        end
    end
end)

-- Auto Shoot + Far Kill Murderer
RunService.RenderStepped:Connect(function()
    if not (Settings.AutoShootMurderer or Settings.KillMurdererFar) then return end
    
    local murd = getMurderer()
    if not murd or not isAlive(murd) then return end
    
    local head = getNearestHead(murd.Character)
    if not head then return end
    
    if Settings.KillMurdererFar then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    end
    
    if Settings.AutoShootMurderer then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            for _, v in tool:GetDescendants() do
                if v:IsA("RemoteEvent") and v.Name and (v.Name:lower():find("fire") or v.Name:lower():find("shoot")) then
                    pcall(function() v:FireServer(head.Position) end)
                    break
                end
            end
        end
    end
end)

-- Auto Grab Gun с улучшением
RunService.Heartbeat:Connect(function()
    if not Settings.AutoGrabGun then return end
    if not LocalPlayer.Character then return end
    if LocalPlayer.Character:FindFirstChild("Gun") then return end
    
    for _, obj in Workspace:GetChildren() do
        if obj:IsA("Tool") and obj.Name == "Gun" then
            local handle = obj:FindFirstChild("Handle") or obj.PrimaryPart
            if handle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if (handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 40 then
                    local detector = obj:FindFirstChildOfClass("ClickDetector")
                    if detector then
                        pcall(function() fireclickdetector(detector) end)
                    end
                end
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not Settings.Noclip or not LocalPlayer.Character then return end
    for _, part in LocalPlayer.Character:GetDescendants() do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- God Mode с защитой от дизейбла
spawn(function()
    while true do
        if Settings.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local h = LocalPlayer.Character.Humanoid
            pcall(function()
                h.MaxHealth = 1e9
                h.Health = 1e9
                h.BreakJointsOnDeath = false
            end)
        end
        task.wait(0.35)
    end
end)

-- ESP с улучшенной производительностью
local ESP = {}
local function createESP(plr)
    if plr == LocalPlayer or ESP[plr] then return end
    
    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 6)
    if not root then return end
    
    local bb = Instance.new("BillboardGui")
    bb.Adornee = root
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 4.2, 0)
    bb.Parent = root
    
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0.5
    txt.TextStrokeColor3 = Color3.new(0,0,0)
    
    -- Добавляем красивый градиентный фон
    local bgFrame = Instance.new("Frame", bb)
    bgFrame.Size = UDim2.new(1, 10, 1, 5)
    bgFrame.Position = UDim2.new(0, -5, 0, -2.5)
    bgFrame.BackgroundTransparency = 0.3
    bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgFrame.ZIndex = 0
    
    ESP[plr] = bb
    
    plr.CharacterRemoving:Connect(function()
        if ESP[plr] then 
            pcall(function() ESP[plr]:Destroy() end)
            ESP[plr] = nil 
        end
    end)
end

local function refreshESP()
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        local role = getRole(plr)
        local enabled = false
        local color = Color3.fromRGB(200,200,60)
        
        if role == "Murderer" and Settings.MurderESP then
            color = Color3.fromRGB(220,40,40)
            enabled = true
        elseif role == "Sheriff" and Settings.SheriffESP then
            color = Color3.fromRGB(60,140,255)
            enabled = true
        elseif role == "Innocent" and Settings.InnocentESP then
            color = Color3.fromRGB(255,200,50)
            enabled = true
        end
        
        if enabled then
            createESP(plr)
            if ESP[plr] and ESP[plr].TextLabel then
                ESP[plr].TextLabel.Text = plr.Name .. " [" .. role .. "]"
                ESP[plr].TextLabel.TextColor3 = color
            end
        else
            if ESP[plr] then 
                pcall(function() ESP[plr]:Destroy() end)
                ESP[plr] = nil 
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p) 
    p.CharacterAdded:Connect(function() 
        task.delay(1, refreshESP) 
    end) 
end)
RunService.Heartbeat:Connect(refreshESP)

-- GUI Creation (если Rayfield загружен)
if RayfieldLoaded then
    local MainTab = Window:CreateTab("⚔️ Combat", 4483362458)
    local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)
    local MiscTab = Window:CreateTab("🔧 Misc", 4483362458)
    local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
    
    -- Combat Tab
    local CombatSection = MainTab:CreateSection("Combat Features")
    
    MainTab:CreateToggle({
        Name = "🔪 Kill Aura",
        CurrentValue = false,
        Callback = function(v) Settings.KillAura = v end,
    })
    
    MainTab:CreateSlider({
        Name = "📏 Kill Aura Range",
        Range = {8, 35},
        Increment = 1,
        Suffix = "studs",
        CurrentValue = 18,
        Callback = function(v) Settings.KillAuraRange = v end,
    })
    
    MainTab:CreateToggle({
        Name = "🎯 Kill Murderer (Far + Camera Lock)",
        CurrentValue = false,
        Callback = function(v) Settings.KillMurdererFar = v end,
    })
    
    MainTab:CreateToggle({
        Name = "🔫 Auto Shoot Murderer",
        CurrentValue = false,
        Callback = function(v) Settings.AutoShootMurderer = v end,
    })
    
    MainTab:CreateToggle({
        Name = "🎯 Silent Aim (Murderer only)",
        CurrentValue = false,
        Callback = function(v) Settings.SilentAim = v end,
    })
    
    -- Visuals Tab
    local VisualSection = VisualTab:CreateSection("ESP Settings")
    
    VisualTab:CreateToggle({
        Name = "🔴 Murderer ESP (Red)",
        CurrentValue = true,
        Callback = function(v) Settings.MurderESP = v refreshESP() end,
    })
    
    VisualTab:CreateToggle({
        Name = "🔵 Sheriff ESP (Blue)",
        CurrentValue = true,
        Callback = function(v) Settings.SheriffESP = v refreshESP() end,
    })
    
    VisualTab:CreateToggle({
        Name = "🟡 Innocent ESP (Yellow)",
        CurrentValue = false,
        Callback = function(v) Settings.InnocentESP = v refreshESP() end,
    })
    
    -- Misc Tab
    local MiscSection = MiscTab:CreateSection("Utility Features")
    
    MiscTab:CreateToggle({
        Name = "🔫 Auto Grab Gun",
        CurrentValue = false,
        Callback = function(v) Settings.AutoGrabGun = v end,
    })
    
    MiscTab:CreateToggle({
        Name = "💨 Noclip",
        CurrentValue = false,
        Callback = function(v) Settings.Noclip = v end,
    })
    
    MiscTab:CreateToggle({
        Name = "🛡️ God Mode",
        CurrentValue = false,
        Callback = function(v) Settings.GodMode = v end,
    })
    
    -- Settings Tab
    local SettingsSection = SettingsTab:CreateSection("Interface")
    
    SettingsTab:CreateButton({
        Name = "🔄 Refresh ESP",
        Callback = function()
            refreshESP()
            Rayfield:Notify({
                Title = "ESP Refreshed",
                Content = "All ESP elements have been updated",
                Duration = 3,
                Image = 4483362458,
            })
        end,
    })
    
    SettingsTab:CreateButton({
        Name = "📋 Copy Script Info",
        Callback = function()
            setclipboard("MM2 GOD-TIER 2026 - Enhanced Edition")
            Rayfield:Notify({
                Title = "Copied!",
                Content = "Script info copied to clipboard",
                Duration = 2,
                Image = 4483362458,
            })
        end,
    })
    
    -- Notify
    Rayfield:Notify({
        Title = "✨ MM2 GOD-TIER 2026",
        Content = "Enhanced Edition Loaded • All features ready",
        Duration = 5,
        Image = 4483362458,
    })
end

print("MM2 GOD-TIER 2026 • Enhanced Edition • Fully Updated")
print("Use the toggle button (⚡) to show/hide the GUI")
