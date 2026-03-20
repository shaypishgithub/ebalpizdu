-- MM2 GOD-TIER 2026 FIXED

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local UserGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local Settings = {
   KillAura = false,
   KillAuraRange = 18,
   SilentAim = false,
   MurderESP = true,
   SheriffESP = true,
   Noclip = false,
   GodMode = false,
   SpeedHack = false,
   WalkSpeed = 25,
}

-- ============== ОСНОВНЫЕ ФУНКЦИИ ==============

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
   return nil
end

-- ============== KILL AURA ==============
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
end)

-- ============== SPEED HACK ==============
RunService.Heartbeat:Connect(function()
   if Settings.SpeedHack and LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then humanoid.WalkSpeed = Settings.WalkSpeed end
   end
end)

-- ============== NOCLIP ==============
RunService.Stepped:Connect(function()
   if Settings.Noclip and LocalPlayer.Character then
      for _, part in LocalPlayer.Character:GetDescendants() do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
end)

-- ============== GOD MODE ==============
RunService.Heartbeat:Connect(function()
   if Settings.GodMode and LocalPlayer.Character then
      local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
      if humanoid then
         humanoid.MaxHealth = math.huge
         humanoid.Health = math.huge
      end
   end
end)

-- ============== SILENT AIM ==============
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

-- ============== ESP ==============
local ESP = {}

local function createESP(plr)
   if ESP[plr] then return end
   if not plr.Character then return end
   
   local root = plr.Character:FindFirstChild("HumanoidRootPart")
   if not root then return end
   
   local bb = Instance.new("BillboardGui")
   bb.Adornee = root
   bb.MaxDistance = math.huge
   bb.Size = UDim2.new(0, 150, 0, 50)
   bb.StudsOffset = Vector3.new(0, 3, 0)
   bb.Parent = root
   
   local txt = Instance.new("TextLabel")
   txt.Parent = bb
   txt.BackgroundTransparency = 1
   txt.Size = UDim2.new(1, 0, 1, 0)
   txt.TextScaled = true
   txt.Font = Enum.Font.GothamBold
   txt.TextStrokeTransparency = 0.5
   
   ESP[plr] = bb
   
   plr.CharacterRemoving:Connect(function()
      if ESP[plr] then
         pcall(function() ESP[plr]:Destroy() end)
         ESP[plr] = nil
      end
   end)
end

local function updateESP()
   for _, plr in Players:GetPlayers() do
      if plr == LocalPlayer then continue end
      
      local role = getRole(plr)
      local color = Color3.fromRGB(255, 255, 255)
      local show = false
      
      if role == "Murderer" and Settings.MurderESP then
         color = Color3.fromRGB(220, 40, 40)
         show = true
      elseif role == "Sheriff" and Settings.SheriffESP then
         color = Color3.fromRGB(60, 140, 255)
         show = true
      end
      
      if show then
         createESP(plr)
         if ESP[plr] and ESP[plr]:FindFirstChild("TextLabel") then
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

RunService.Heartbeat:Connect(updateESP)

-- ============== GUI ==============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = UserGui

-- Основной фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 550)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Добавляем градиент
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
   ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 15)),
   ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 200))
})
Gradient.Parent = MainFrame

-- Скругление углов
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(20, 50, 120)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.85, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.white
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Text = "🔥 MM2 GOD-TIER"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.white
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

-- Перетаскивание
local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input, gp)
   if gp then return end
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = MainFrame.Position
   end
end)

UserInputService.InputChanged:Connect(function(input, gp)
   if dragging then
      local delta = input.Position - dragStart
      MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
   end
end)

UserInputService.InputEnded:Connect(function(input, gp)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = false
   end
end)

-- Список элементов
local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -10, 1, -55)
List.Position = UDim2.new(0, 5, 0, 50)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = List

-- Функция для создания тоггла
local function addToggle(text, setting)
   local Toggle = Instance.new("Frame")
   Toggle.Size = UDim2.new(1, 0, 0, 30)
   Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
   Toggle.BorderSizePixel = 0
   Toggle.Parent = List
   
   local ToggleCorner = Instance.new("UICorner")
   ToggleCorner.CornerRadius = UDim.new(0, 6)
   ToggleCorner.Parent = Toggle
   
   local Label = Instance.new("TextLabel")
   Label.Size = UDim2.new(0.7, 0, 1, 0)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = Color3.white
   Label.TextSize = 12
   Label.Font = Enum.Font.Gotham
   Label.Text = text
   Label.TextXAlignment = Enum.TextXAlignment.Left
   Label.TextYAlignment = Enum.TextYAlignment.Center
   Label.Parent = Toggle
   
   local Button = Instance.new("TextButton")
   Button.Size = UDim2.new(0.25, 0, 0.7, 0)
   Button.Position = UDim2.new(0.7, 0, 0.15, 0)
   Button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
   Button.TextColor3 = Color3.white
   Button.TextSize = 11
   Button.Font = Enum.Font.GothamBold
   Button.Text = Settings[setting] and "ON" or "OFF"
   Button.BorderSizePixel = 0
   Button.Parent = Toggle
   
   local ButtonCorner = Instance.new("UICorner")
   ButtonCorner.CornerRadius = UDim.new(0, 4)
   ButtonCorner.Parent = Button
   
   Button.MouseButton1Click:Connect(function()
      Settings[setting] = not Settings[setting]
      Button.Text = Settings[setting] and "ON" or "OFF"
      Button.BackgroundColor3 = Settings[setting] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 100)
   end)
end

-- Функция для создания слайдера
local function addSlider(text, setting, min, max)
   local Container = Instance.new("Frame")
   Container.Size = UDim2.new(1, 0, 0, 50)
   Container.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
   Container.BorderSizePixel = 0
   Container.Parent = List
   
   local ContainerCorner = Instance.new("UICorner")
   ContainerCorner.CornerRadius = UDim.new(0, 6)
   ContainerCorner.Parent = Container
   
   local Label = Instance.new("TextLabel")
   Label.Size = UDim2.new(1, -10, 0, 20)
   Label.Position = UDim2.new(0, 5, 0, 3)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = Color3.white
   Label.TextSize = 11
   Label.Font = Enum.Font.GothamBold
   Label.Text = text .. ": " .. Settings[setting]
   Label.TextXAlignment = Enum.TextXAlignment.Left
   Label.Parent = Container
   
   local SliderBg = Instance.new("Frame")
   SliderBg.Size = UDim2.new(1, -10, 0, 8)
   SliderBg.Position = UDim2.new(0, 5, 0, 25)
   SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
   SliderBg.BorderSizePixel = 0
   SliderBg.Parent = Container
   
   local SliderBgCorner = Instance.new("UICorner")
   SliderBgCorner.CornerRadius = UDim.new(0, 4)
   SliderBgCorner.Parent = SliderBg
   
   local SliderFill = Instance.new("Frame")
   local percent = (Settings[setting] - min) / (max - min)
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
         local value = math.floor(min + (max - min) * percent)
         
         Settings[setting] = value
         SliderFill.Size = UDim2.new(percent, 0, 1, 0)
         Label.Text = text .. ": " .. value
      end
   end)
end

-- Добавляем элементы
addToggle("Kill Aura", "KillAura")
addSlider("Aura Range", "KillAuraRange", 8, 35)
addToggle("Silent Aim", "SilentAim")
addToggle("Murderer ESP", "MurderESP")
addToggle("Sheriff ESP", "SheriffESP")
addToggle("Speed Hack", "SpeedHack")
addSlider("Walk Speed", "WalkSpeed", 16, 100)
addToggle("Noclip", "Noclip")
addToggle("God Mode", "GodMode")

-- Кнопка закрытия
CloseBtn.MouseButton1Click:Connect(function()
   MainFrame:TweenSize(UDim2.new(0, 300, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
      MainFrame.Visible = false
   end)
end)

-- Уведомление
local Notif = Instance.new("TextLabel")
Notif.Size = UDim2.new(0, 350, 0, 70)
Notif.Position = UDim2.new(0.5, -175, 0, 20)
Notif.BackgroundColor3 = Color3.fromRGB(30, 150, 60)
Notif.TextColor3 = Color3.white
Notif.TextSize = 13
Notif.Font = Enum.Font.GothamBold
Notif.Text = "✅ MM2 GOD-TIER Loaded!\n🎮 Enjoy the features!"
Notif.BorderSizePixel = 0
Notif.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 8)
NotifCorner.Parent = Notif

task.wait(4)
Notif:Destroy()

print("✅ MM2 GOD-TIER LOADED!")
