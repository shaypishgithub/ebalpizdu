-- MM2 ULTIMATE RAYFIELD STYLE 2026

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local UserGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local Settings = {
   AutoFarmMurder = false,
   AutoFarmSheriff = false,
   AutoFarmInnocent = false,
   KillAura = false,
   KillAuraRange = 18,
   SilentAim = false,
   MurderESP = true,
   SheriffESP = true,
   InnocentESP = false,
   CoinESP = true,
   SpeedHack = false,
   WalkSpeed = 25,
   Noclip = false,
   GodMode = false,
}

-- ============== CORE FUNCTIONS ==============
local function getRole(plr)
   if not plr.Character then return "None" end
   local knife = plr.Backpack:FindFirstChild("Knife") or plr.Character:FindFirstChild("Knife")
   local gun = plr.Backpack:FindFirstChild("Gun") or plr.Character:FindFirstChild("Gun")
   if knife then return "Murderer" end
   if gun then return "Sheriff" end
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
end

local function getSheriff()
   for _, plr in Players:GetPlayers() do
      if plr ~= LocalPlayer and getRole(plr) == "Sheriff" and isAlive(plr) then
         return plr
      end
   end
end

-- ============== FEATURES ==============

-- Kill Aura
RunService.Heartbeat:Connect(function()
   if not LocalPlayer.Character then return end
   local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
   if not myRoot then return end
   
   if Settings.KillAura then
      for _, plr in Players:GetPlayers() do
         if plr ~= LocalPlayer and isAlive(plr) then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - myRoot.Position).Magnitude <= Settings.KillAuraRange then
               pcall(function() plr.Character.Humanoid.Health = 0 end)
            end
         end
      end
   end
   
   if Settings.AutoFarmMurder then
      local murd = getMurderer()
      if murd and isAlive(murd) then
         local root = murd.Character:FindFirstChild("HumanoidRootPart")
         if root and (root.Position - myRoot.Position).Magnitude <= 20 then
            pcall(function() murd.Character.Humanoid.Health = 0 end)
         end
      end
   end
   
   if Settings.AutoFarmSheriff then
      local sheriff = getSheriff()
      if sheriff and isAlive(sheriff) then
         local root = sheriff.Character:FindFirstChild("HumanoidRootPart")
         if root and (root.Position - myRoot.Position).Magnitude <= 20 then
            pcall(function() sheriff.Character.Humanoid.Health = 0 end)
         end
      end
   end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
   if Settings.SpeedHack and LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then humanoid.WalkSpeed = Settings.WalkSpeed end
   end
end)

-- Noclip
RunService.Stepped:Connect(function()
   if Settings.Noclip and LocalPlayer.Character then
      for _, part in LocalPlayer.Character:GetDescendants() do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
end)

-- God Mode
RunService.Heartbeat:Connect(function()
   if Settings.GodMode and LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.MaxHealth = math.huge
         humanoid.Health = math.huge
      end
   end
end)

-- Silent Aim
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
   local method = getnamecallmethod()
   local args = {...}
   
   if Settings.SilentAim and method == "FireServer" then
      local murd = getMurderer()
      if murd and isAlive(murd) then
         local head = murd.Character:FindFirstChild("Head")
         if head then
            args[1] = head.Position
            return oldNamecall(self, unpack(args))
         end
      end
   end
   
   return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ESP
local ESP = {}

local function updateESP()
   for _, plr in Players:GetPlayers() do
      if plr == LocalPlayer then continue end
      if not plr.Character then continue end
      
      local root = plr.Character:FindFirstChild("HumanoidRootPart")
      if not root then continue end
      
      local role = getRole(plr)
      local color = Color3.fromRGB(255, 255, 255)
      local show = false
      
      if role == "Murderer" and Settings.MurderESP then
         color = Color3.fromRGB(220, 40, 40)
         show = true
      elseif role == "Sheriff" and Settings.SheriffESP then
         color = Color3.fromRGB(60, 140, 255)
         show = true
      elseif role == "Innocent" and Settings.InnocentESP then
         color = Color3.fromRGB(200, 200, 60)
         show = true
      end
      
      if show then
         if not ESP[plr] then
            local bb = Instance.new("BillboardGui")
            bb.Adornee = root
            bb.MaxDistance = math.huge
            bb.Size = UDim2.new(0, 150, 0, 50)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            
            local txt = Instance.new("TextLabel")
            txt.Parent = bb
            txt.BackgroundTransparency = 1
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.TextScaled = true
            txt.Font = Enum.Font.GothamBold
            txt.TextStrokeTransparency = 0.5
            txt.TextColor3 = color
            txt.Text = plr.Name .. " [" .. role .. "]"
            
            bb.Parent = root
            ESP[plr] = bb
         end
      else
         if ESP[plr] then
            pcall(function() ESP[plr]:Destroy() end)
            ESP[plr] = nil
         end
      end
   end
end

RunService.Heartbeat:Connect(updateESP)

-- ============== GUI RAYFIELD STYLE ==============

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MM2RayfieldStyle"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = UserGui

-- Main Window
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 550, 0, 650)
Window.Position = UDim2.new(0.5, -275, 0.5, -325)
Window.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
Window.BorderSizePixel = 0
Window.Parent = MainGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 10)
WindowCorner.Parent = Window

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = Window

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 20
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "MM2 ULTIMATE"
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextYAlignment = Enum.TextYAlignment.Center
TitleText.Parent = TopBar

-- Subtitle
local SubtitleText = Instance.new("TextLabel")
SubtitleText.Name = "Subtitle"
SubtitleText.Size = UDim2.new(0.7, 0, 0, 20)
SubtitleText.Position = UDim2.new(0.05, 0, 0.5, 0)
SubtitleText.BackgroundTransparency = 1
SubtitleText.TextColor3 = Color3.fromRGB(150, 150, 150)
SubtitleText.TextSize = 12
SubtitleText.Font = Enum.Font.Gotham
SubtitleText.Text = "All Features Loaded"
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.TextYAlignment = Enum.TextYAlignment.Center
SubtitleText.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0.5, -20)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.TextColor3 = Color3.white
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TopBar

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 6)
CloseButtonCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
   Window.Visible = false
end)

-- Tab Buttons Frame
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(0.3, 0, 1, -60)
TabsFrame.Position = UDim2.new(0, 0, 0, 60)
TabsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = Window

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Padding = UDim.new(0, 0)
TabsLayout.Parent = TabsFrame

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(0.7, 0, 1, -60)
ContentFrame.Position = UDim2.new(0.3, 0, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = Window

-- Scroll Frame for Content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
ScrollFrame.Parent = ContentFrame

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding = UDim.new(0, 10)
ScrollLayout.Parent = ScrollFrame

-- Tab Creation System
local CurrentTab = nil
local Tabs = {}

local function CreateTab(TabName)
   -- Tab Button
   local TabButton = Instance.new("TextButton")
   TabButton.Name = TabName
   TabButton.Size = UDim2.new(1, 0, 0, 50)
   TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
   TabButton.TextColor3 = Color3.white
   TabButton.TextSize = 12
   TabButton.Font = Enum.Font.GothamBold
   TabButton.Text = TabName
   TabButton.BorderSizePixel = 0
   TabButton.Parent = TabsFrame
   
   local TabButtonCorner = Instance.new("UICorner")
   TabButtonCorner.CornerRadius = UDim.new(0, 0)
   TabButtonCorner.Parent = TabButton
   
   -- Active indicator
   local ActiveBar = Instance.new("Frame")
   ActiveBar.Name = "ActiveBar"
   ActiveBar.Size = UDim2.new(0, 3, 1, 0)
   ActiveBar.Position = UDim2.new(1, 0, 0, 0)
   ActiveBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
   ActiveBar.BorderSizePixel = 0
   ActiveBar.Visible = false
   ActiveBar.Parent = TabButton
   
   local function SelectTab()
      for _, tab in pairs(Tabs) do
         if tab.Button then
            tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
            tab.Button:FindFirstChild("ActiveBar").Visible = false
         end
      end
      
      TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 70)
      ActiveBar.Visible = true
      CurrentTab = TabName
      
      ScrollFrame:ClearAllChildren()
      ScrollLayout.Parent = ScrollFrame
      
      if Tabs[TabName] and Tabs[TabName].Content then
         for _, item in ipairs(Tabs[TabName].Content) do
            item.Parent = ScrollFrame
         end
      end
   end
   
   TabButton.MouseButton1Click:Connect(SelectTab)
   
   Tabs[TabName] = {
      Button = TabButton,
      Content = {},
      Select = SelectTab
   }
   
   if CurrentTab == nil then
      SelectTab()
   end
   
   return TabName
end

-- Toggle Creator
local function AddToggle(TabName, Name, DefaultValue, Callback)
   if not Tabs[TabName] then return end
   
   local Toggle = Instance.new("Frame")
   Toggle.Name = Name
   Toggle.Size = UDim2.new(1, 0, 0, 40)
   Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
   Toggle.BorderSizePixel = 0
   
   local ToggleCorner = Instance.new("UICorner")
   ToggleCorner.CornerRadius = UDim.new(0, 6)
   ToggleCorner.Parent = Toggle
   
   local Label = Instance.new("TextLabel")
   Label.Size = UDim2.new(0.6, 0, 1, 0)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = Color3.white
   Label.TextSize = 12
   Label.Font = Enum.Font.Gotham
   Label.Text = Name
   Label.TextXAlignment = Enum.TextXAlignment.Left
   Label.TextYAlignment = Enum.TextYAlignment.Center
   Label.Parent = Toggle
   
   local Button = Instance.new("TextButton")
   Button.Size = UDim2.new(0.3, 0, 0.6, 0)
   Button.Position = UDim2.new(0.65, 0, 0.2, 0)
   Button.BackgroundColor3 = DefaultValue and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 100)
   Button.TextColor3 = Color3.white
   Button.TextSize = 11
   Button.Font = Enum.Font.GothamBold
   Button.Text = DefaultValue and "ON" or "OFF"
   Button.BorderSizePixel = 0
   Button.Parent = Toggle
   
   local ButtonCorner = Instance.new("UICorner")
   ButtonCorner.CornerRadius = UDim.new(0, 4)
   ButtonCorner.Parent = Button
   
   Button.MouseButton1Click:Connect(function()
      DefaultValue = not DefaultValue
      Button.BackgroundColor3 = DefaultValue and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 100)
      Button.Text = DefaultValue and "ON" or "OFF"
      if Callback then Callback(DefaultValue) end
   end)
   
   table.insert(Tabs[TabName].Content, Toggle)
end

-- Slider Creator
local function AddSlider(TabName, Name, Min, Max, DefaultValue, Callback)
   if not Tabs[TabName] then return end
   
   local Container = Instance.new("Frame")
   Container.Name = Name
   Container.Size = UDim2.new(1, 0, 0, 60)
   Container.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
   Container.BorderSizePixel = 0
   
   local ContainerCorner = Instance.new("UICorner")
   ContainerCorner.CornerRadius = UDim.new(0, 6)
   ContainerCorner.Parent = Container
   
   local Label = Instance.new("TextLabel")
   Label.Size = UDim2.new(1, -10, 0, 20)
   Label.Position = UDim2.new(0, 5, 0, 5)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = Color3.white
   Label.TextSize = 11
   Label.Font = Enum.Font.GothamBold
   Label.Text = Name .. ": " .. DefaultValue
   Label.TextXAlignment = Enum.TextXAlignment.Left
   Label.Parent = Container
   
   local SliderBg = Instance.new("Frame")
   SliderBg.Size = UDim2.new(1, -10, 0, 8)
   SliderBg.Position = UDim2.new(0, 5, 0, 30)
   SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
   SliderBg.BorderSizePixel = 0
   SliderBg.Parent = Container
   
   local SliderBgCorner = Instance.new("UICorner")
   SliderBgCorner.CornerRadius = UDim.new(0, 4)
   SliderBgCorner.Parent = SliderBg
   
   local SliderFill = Instance.new("Frame")
   local percent = (DefaultValue - Min) / (Max - Min)
   SliderFill.Size = UDim2.new(percent, 0, 1, 0)
   SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
   SliderFill.BorderSizePixel = 0
   SliderFill.Parent = SliderBg
   
   local SliderFillCorner = Instance.new("UICorner")
   SliderFillCorner.CornerRadius = UDim.new(0, 4)
   SliderFillCorner.Parent = SliderFill
   
   SliderBg.InputBegan:Connect(function(input, gp)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
         local mouseX = input.Position.X - SliderBg.AbsolutePosition.X
         local percent = math.clamp(mouseX / SliderBg.AbsoluteSize.X, 0, 1)
         local value = math.floor(Min + (Max - Min) * percent)
         
         DefaultValue = value
         SliderFill.Size = UDim2.new(percent, 0, 1, 0)
         Label.Text = Name .. ": " .. value
         if Callback then Callback(value) end
      end
   end)
   
   table.insert(Tabs[TabName].Content, Container)
end

-- ============== BUILD GUI ==============

CreateTab("Combat")
AddToggle("Combat", "Kill Aura", Settings.KillAura, function(v) Settings.KillAura = v end)
AddSlider("Combat", "Aura Range", 8, 35, Settings.KillAuraRange, function(v) Settings.KillAuraRange = v end)
AddToggle("Combat", "Auto Farm Murder", Settings.AutoFarmMurder, function(v) Settings.AutoFarmMurder = v end)
AddToggle("Combat", "Auto Farm Sheriff", Settings.AutoFarmSheriff, function(v) Settings.AutoFarmSheriff = v end)
AddToggle("Combat", "Silent Aim", Settings.SilentAim, function(v) Settings.SilentAim = v end)

CreateTab("Visuals")
AddToggle("Visuals", "Murder ESP", Settings.MurderESP, function(v) Settings.MurderESP = v end)
AddToggle("Visuals", "Sheriff ESP", Settings.SheriffESP, function(v) Settings.SheriffESP = v end)
AddToggle("Visuals", "Innocent ESP", Settings.InnocentESP, function(v) Settings.InnocentESP = v end)
AddToggle("Visuals", "Coin ESP", Settings.CoinESP, function(v) Settings.CoinESP = v end)

CreateTab("Movement")
AddToggle("Movement", "Speed Hack", Settings.SpeedHack, function(v) Settings.SpeedHack = v end)
AddSlider("Movement", "Walk Speed", 16, 100, Settings.WalkSpeed, function(v) Settings.WalkSpeed = v end)
AddToggle("Movement", "Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)

CreateTab("Utility")
AddToggle("Utility", "God Mode", Settings.GodMode, function(v) Settings.GodMode = v end)

print("✅ MM2 ULTIMATE RAYFIELD STYLE LOADED!")
