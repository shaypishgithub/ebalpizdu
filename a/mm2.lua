-- // MM2 GOD-TIER 2026 EXPANDED • Custom UI • All Features

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera
local UserGui          = LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
   -- Combat
   KillAura = false,
   KillAuraRange = 18,
   KillMurdererFar = false,
   AutoShootMurderer = false,
   SilentAim = false,
   
   -- Visuals
   MurderESP = true,
   SheriffESP = true,
   InnocentESP = false,
   ESPDamageShow = true,
   ShowHealthBar = true,
   
   -- Movement
   SpeedHack = false,
   WalkSpeed = 25,
   Flight = false,
   FlightSpeed = 50,
   Noclip = false,
   
   -- Utility
   AutoGrabGun = false,
   GodMode = false,
   AntiAFK = false,
   ShowSpeedometer = true,
   
   -- Other
   Aimbot = false,
   AimbotSensitivity = 0.5,
   InfiniteStamina = false,
}

-- ============== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ==============
local FlightActive = false
local FlightConnection = nil
local SpeedValue = 0
local SavedSettings = {}

-- ============== УТИЛИТЫ ==============
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

local function getNearestHead(char)
   if not char then return nil end
   local head = char:FindFirstChild("Head")
   return head or char:FindFirstChild("HumanoidRootPart")
end

local function teleportToPlayer(targetPlr)
   if not LocalPlayer.Character or not targetPlr.Character then return end
   local targetRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
   if targetRoot and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      LocalPlayer.Character.HumanoidRootPart.CFrame = targetRoot.CFrame + Vector3.new(5, 0, 0)
   end
end

-- ============== SETTINGS SAVE/LOAD ==============
local function saveSettings()
   SavedSettings = Settings
   print("✅ Settings saved!")
end

local function loadSettings()
   if SavedSettings and next(SavedSettings) then
      Settings = SavedSettings
      print("✅ Settings loaded!")
   end
end

-- ============== SILENT AIM ==============
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
   local method = getnamecallmethod()
   local args = {...}
   
   if Settings.SilentAim and method == "FireServer" then
      if self.Name:lower():find("fire") or self.Name:lower():find("shoot") or self.Name:lower():find("hit") then
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

-- ============== AIMBOT ==============
RunService.RenderStepped:Connect(function()
   if not Settings.Aimbot then return end
   
   local murd = getMurderer()
   if murd and isAlive(murd) then
      local head = getNearestHead(murd.Character)
      if head then
         local direction = (head.Position - Camera.CFrame.Position).Unit
         Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction), Settings.AimbotSensitivity * 0.1)
      end
   end
end)

-- ============== KILL AURA ==============
RunService.Heartbeat:Connect(function()
   if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
   local myRoot = LocalPlayer.Character.HumanoidRootPart
   local myPos  = myRoot.Position
   
   if Settings.KillAura then
      for _, plr in Players:GetPlayers() do
         if plr ~= LocalPlayer and isAlive(plr) and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist <= Settings.KillAuraRange then
               pcall(function() plr.Character.Humanoid.Health = 0 end)
            end
         end
      end
   end
end)

-- ============== AUTO SHOOT + FAR KILL ==============
RunService.RenderStepped:Connect(function()
   if not (Settings.AutoShootMurderer or Settings.KillMurdererFar) then return end
   
   local murd = getMurderer()
   if not murd or not isAlive(murd) then return end
   
   local head = getNearestHead(murd.Character)
   if not head then return end
   
   Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
   
   if Settings.AutoShootMurderer then
      local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
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

-- ============== SPEED HACK ==============
RunService.Heartbeat:Connect(function()
   if Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
      local humanoid = LocalPlayer.Character.Humanoid
      humanoid.WalkSpeed = Settings.WalkSpeed
   end
end)

-- ============== FLIGHT SYSTEM ==============
local function startFlight()
   if FlightActive or not LocalPlayer.Character then return end
   FlightActive = true
   
   local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
   if not root then FlightActive = false return end
   
   local bodyVelocity = Instance.new("BodyVelocity", root)
   bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   bodyVelocity.P = 10000
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
   
   FlightConnection = RunService.Heartbeat:Connect(function()
      if not FlightActive or not Settings.Flight or not root.Parent then
         if bodyVelocity then bodyVelocity:Destroy() end
         if FlightConnection then FlightConnection:Disconnect() end
         FlightActive = false
         return
      end
      
      local moveDirection = Vector3.new(0, 0, 0)
      if UserInputService:IsKeyDown(Enum.KeyCode.W) then
         moveDirection = moveDirection + (Camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.S) then
         moveDirection = moveDirection - (Camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.A) then
         moveDirection = moveDirection - Camera.CFrame.RightVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.D) then
         moveDirection = moveDirection + Camera.CFrame.RightVector
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         moveDirection = moveDirection + Vector3.new(0, 1, 0)
      end
      if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
         moveDirection = moveDirection - Vector3.new(0, 1, 0)
      end
      
      if moveDirection.Magnitude > 0 then
         bodyVelocity.Velocity = moveDirection.Unit * Settings.FlightSpeed
      else
         bodyVelocity.Velocity = Vector3.new(0, 0, 0)
      end
   end)
end

-- ============== AUTO GRAB GUN ==============
RunService.Heartbeat:Connect(function()
   if not Settings.AutoGrabGun then return end
   if not LocalPlayer.Character then return end
   if LocalPlayer.Character:FindFirstChild("Gun") then return end
   
   for _, obj in Workspace:GetChildren() do
      if obj:IsA("Tool") and obj.Name == "Gun" then
         local handle = obj.Handle or obj.PrimaryPart
         if handle and (handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 40 then
            fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
         end
      end
   end
end)

-- ============== NOCLIP ==============
RunService.Stepped:Connect(function()
   if not Settings.Noclip or not LocalPlayer.Character then return end
   for _, part in LocalPlayer.Character:GetDescendants() do
      if part:IsA("BasePart") then
         part.CanCollide = false
      end
   end
end)

-- ============== GOD MODE ==============
RunService.Heartbeat:Connect(function()
   if not Settings.GodMode or not LocalPlayer.Character then return end
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if humanoid then
      humanoid.MaxHealth = math.huge
      humanoid.Health = math.huge
   end
end)

-- ============== INFINITE STAMINA ==============
RunService.Heartbeat:Connect(function()
   if not Settings.InfiniteStamina or not LocalPlayer.Character then return end
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if humanoid then
      humanoid:FindFirstChild("Stamina") and humanoid.Stamina:Destroy()
   end
end)

-- ============== ANTI AFK ==============
RunService.Heartbeat:Connect(function()
   if Settings.AntiAFK and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local root = LocalPlayer.Character.HumanoidRootPart
      root.Velocity = root.Velocity + Vector3.new(0, 0.0001, 0)
   end
end)

-- ============== SPEEDOMETER ==============
RunService.Heartbeat:Connect(function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local root = LocalPlayer.Character.HumanoidRootPart
      SpeedValue = math.floor(root.Velocity.Magnitude + 0.5)
   end
end)

-- ============== ADVANCED ESP ==============
local ESP = {}
local function createESP(plr)
   if plr == LocalPlayer or ESP[plr] then return end
   if not plr.Character then return end
   
   local root = plr.Character:FindFirstChild("HumanoidRootPart")
   if not root then return end
   
   local bb = Instance.new("BillboardGui", root)
   bb.Adornee = root
   bb.Size = UDim2.new(0, 200, 0, 80)
   bb.AlwaysOnTop = true
   bb.StudsOffset = Vector3.new(0, 4.2, 0)
   
   local txt = Instance.new("TextLabel", bb)
   txt.Size = UDim2.new(1, 0, 0.5, 0)
   txt.BackgroundTransparency = 1
   txt.TextScaled = true
   txt.Font = Enum.Font.GothamBold
   txt.TextStrokeTransparency = 0.5
   txt.TextStrokeColor3 = Color3.new(0, 0, 0)
   
   -- Health Bar
   local healthBar = Instance.new("Frame", bb)
   healthBar.Size = UDim2.new(1, 0, 0.25, 0)
   healthBar.Position = UDim2.new(0, 0, 0.5, 0)
   healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
   healthBar.BorderSizePixel = 0
   
   local healthFill = Instance.new("Frame", healthBar)
   healthFill.Size = UDim2.new(1, 0, 1, 0)
   healthFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
   healthFill.BorderSizePixel = 0
   
   ESP[plr] = {bb = bb, txt = txt, healthBar = healthBar, healthFill = healthFill}
   
   plr.CharacterRemoving:Connect(function()
      if ESP[plr] then
         pcall(function() ESP[plr].bb:Destroy() end)
         ESP[plr] = nil
      end
   end)
end

local function refreshESP()
   for _, plr in Players:GetPlayers() do
      if plr == LocalPlayer then continue end
      local role = getRole(plr)
      local enabled = false
      local color = Color3.fromRGB(200, 200, 60)
      
      if role == "Murderer" and Settings.MurderESP then
         color = Color3.fromRGB(220, 40, 40)
         enabled = true
      elseif role == "Sheriff" and Settings.SheriffESP then
         color = Color3.fromRGB(60, 140, 255)
         enabled = true
      elseif role == "Innocent" and Settings.InnocentESP then
         enabled = true
      end
      
      if enabled then
         createESP(plr)
         if ESP[plr] then
            local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
            local health = humanoid and humanoid.Health or 100
            local maxHealth = humanoid and humanoid.MaxHealth or 100
            
            ESP[plr].txt.Text = plr.Name .. " [" .. role .. "]\n" .. math.floor(health) .. "/" .. math.floor(maxHealth)
            ESP[plr].txt.TextColor3 = color
            
            if Settings.ShowHealthBar and humanoid then
               local healthPercent = math.clamp(health / maxHealth, 0, 1)
               ESP[plr].healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
            end
         end
      else
         if ESP[plr] then
            pcall(function() ESP[plr].bb:Destroy() end)
            ESP[plr] = nil
         end
      end
   end
end

Players.PlayerAdded:Connect(function(p)
   p.CharacterAdded:Connect(function() task.delay(1, refreshESP) end)
end)
RunService.Heartbeat:Connect(refreshESP)

-- ============== SPEEDOMETER DISPLAY ==============
local Speedometer = Instance.new("TextLabel", UserGui)
Speedometer.Name = "Speedometer"
Speedometer.Size = UDim2.new(0, 150, 0, 50)
Speedometer.Position = UDim2.new(1, -170, 1, -70)
Speedometer.BackgroundColor3 = Color3.fromRGB(30, 80, 180)
Speedometer.TextColor3 = Color3.white
Speedometer.TextSize = 14
Speedometer.Font = Enum.Font.GothamBold
Speedometer.BorderSizePixel = 0

local SpeedCorner = Instance.new("UICorner", Speedometer)
SpeedCorner.CornerRadius = UDim.new(0, 8)

RunService.Heartbeat:Connect(function()
   if Settings.ShowSpeedometer then
      Speedometer.Visible = true
      Speedometer.Text = "🚀 SPEED\n" .. SpeedValue .. " studs/s"
   else
      Speedometer.Visible = false
   end
end)

-- ============== КАСТОМНЫЙ GUI ==============
local MainGui = Instance.new("ScreenGui", UserGui)
MainGui.Name = "MM2_GOD_TIER_GUI"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 750)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
MainFrame.BorderSizePixel = 0
MainFrame.CanQuery = true

-- Градиент (ЧЁРНЫЙ → СИНИЙ)
local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Color = ColorSequence.new({
   ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 15)),
   ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 200))
})
UIGradient.Rotation = 45

-- Закругленные углы
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(20, 50, 120)
Header.BorderSizePixel = 0
Header.CanQuery = true

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Text = "🔥 MM2 GOD-TIER EXPANDED"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Padding = UDim.new(0, 10)

-- Close Button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.white
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.BorderSizePixel = 0

local CloseBtnCorner = Instance.new("UICorner", CloseBtn)
CloseBtnCorner.CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
   MainFrame:TweenSize(UDim2.new(0, 400, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true, function()
      MainFrame.Visible = false
   end)
end)

-- Open Button
local OpenBtn = Instance.new("TextButton", MainGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0, 100)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 180)
OpenBtn.TextColor3 = Color3.white
OpenBtn.TextSize = 24
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Text = "🔥"
OpenBtn.BorderSizePixel = 0
OpenBtn.Visible = false

local OpenBtnCorner = Instance.new("UICorner", OpenBtn)
OpenBtnCorner.CornerRadius = UDim.new(0, 12)

OpenBtn.MouseButton1Click:Connect(function()
   MainFrame.Visible = true
   MainFrame:TweenSize(UDim2.new(0, 400, 0, 750), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3)
   OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
   OpenBtn.Visible = true
end)

-- Drag Functionality
local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input, gameProcessed)
   if gameProcessed then return end
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = MainFrame.Position
   end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
   if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
      local delta = input.Position - dragStart
      MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
   end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = false
   end
end)

-- Scroll Container
local ScrollContainer = Instance.new("ScrollingFrame", MainFrame)
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -10, 1, -60)
ScrollContainer.Position = UDim2.new(0, 5, 0, 55)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
ScrollContainer.CanQuery = true

local Layout = Instance.new("UIListLayout", ScrollContainer)
Layout.Padding = UDim.new(0, 8)
Layout.FillDirection = Enum.FillDirection.Vertical
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ============== ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕМЕНТОВ ==============
local function createToggle(parent, name, defaultValue, callback)
   local Container = Instance.new("Frame", parent)
   Container.Size = UDim2.new(1, 0, 0, 35)
   Container.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
   Container.BorderSizePixel = 0
   
   local Corner = Instance.new("UICorner", Container)
   Corner.CornerRadius = UDim.new(0, 8)
   
   local Label = Instance.new("TextLabel", Container)
   Label.Size = UDim2.new(1, -50, 1, 0)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = Color3.fromRGB(200, 200, 200)
   Label.TextSize = 13
   Label.Font = Enum.Font.Gotham
   Label.Text = name
   Label.TextXAlignment = Enum.TextXAlignment.Left
   Label.Padding = UDim.new(0, 10)
   
   local Toggle = Instance.new("TextButton", Container)
   Toggle.Size = UDim2.new(0, 35, 0, 20)
   Toggle.Position = UDim2.new(1, -40, 0.5, -10)
   Toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 100)
   Toggle.TextColor3 = Color3.white
   Toggle.TextSize = 10
   Toggle.Font = Enum.Font.GothamBold
   Toggle.Text = defaultValue and "ON" or "OFF"
   Toggle.BorderSizePixel = 0
   
   local ToggleCorner = Instance.new("UICorner", Toggle)
   ToggleCorner.CornerRadius = UDim.new(0, 4)
   
   local isEnabled = defaultValue
   Toggle.MouseButton1Click:Connect(function()
      isEnabled = not isEnabled
      Toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(100, 100, 100)
      Toggle.Text = isEnabled and "ON" or "OFF"
      callback(isEnabled)
   end)
   
   return Container
end

local function createSlider(parent, name, min, max, defaultValue, callback)
   local Container = Instance.new("Frame", parent)
   Container.Size = UDim2.new(1, 0, 0, 60)
   Container.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
   Container.BorderSizePixel = 0
   
   local Corner = Instance.new("UICorner", Container)
   Corner.CornerRadius = UDim.new(0, 8)
   
   local Label = Instance.new("TextLabel", Container)
   Label.Size = UDim2.new(1, -20, 0, 20)
   Label.Position = UDim2.new(0, 10, 0, 5)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = Color3.fromRGB(200, 200, 200)
   Label.TextSize = 12
   Label.Font = Enum.Font.GothamBold
   Label.Text = name .. ": " .. defaultValue
   Label.TextXAlignment = Enum.TextXAlignment.Left
   
   local SliderBg = Instance.new("Frame", Container)
   SliderBg.Size = UDim2.new(1, -20, 0, 10)
   SliderBg.Position = UDim2.new(0, 10, 0, 28)
   SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
   SliderBg.BorderSizePixel = 0
   
   local SliderBgCorner = Instance.new("UICorner", SliderBg)
   SliderBgCorner.CornerRadius = UDim.new(0, 4)
   
   local SliderFill = Instance.new("Frame", SliderBg)
   local fillPercent = (defaultValue - min) / (max - min)
   SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
   SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
   SliderFill.BorderSizePixel = 0
   
   local SliderFillCorner = Instance.new("UICorner", SliderFill)
   SliderFillCorner.CornerRadius = UDim.new(0, 4)
   
   SliderBg.InputBegan:Connect(function(input, gameProcessed)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
         local mousePos = input.Position.X - SliderBg.AbsolutePosition.X
         local percent = math.clamp(mousePos / SliderBg.AbsoluteSize.X, 0, 1)
         local value = math.floor(min + (max - min) * percent)
         
         SliderFill.Size = UDim2.new(percent, 0, 1, 0)
         Label.Text = name .. ": " .. value
         callback(value)
      end
   end)
   
   return Container
end

local function createButton(parent, name, callback)
   local Btn = Instance.new("TextButton", parent)
   Btn.Size = UDim2.new(1, 0, 0, 35)
   Btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
   Btn.TextColor3 = Color3.white
   Btn.TextSize = 13
   Btn.Font = Enum.Font.GothamBold
   Btn.Text = name
   Btn.BorderSizePixel = 0
   
   local BtnCorner = Instance.new("UICorner", Btn)
   BtnCorner.CornerRadius = UDim.new(0, 8)
   
   Btn.MouseButton1Click:Connect(callback)
   
   Btn.MouseEnter:Connect(function()
      Btn.BackgroundColor3 = Color3.fromRGB(120, 170, 255)
   end)
   
   Btn.MouseLeave:Connect(function()
      Btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
   end)
   
   return Btn
end

-- ============== СОЗДАНИЕ ЭЛЕМЕНТОВ ==============

-- COMBAT SECTION
local CombatLabel = Instance.new("TextLabel", ScrollContainer)
CombatLabel.Size = UDim2.new(1, -10, 0, 25)
CombatLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
CombatLabel.TextColor3 = Color3.white
CombatLabel.TextSize = 13
CombatLabel.Font = Enum.Font.GothamBold
CombatLabel.Text = "⚔️ COMBAT"
CombatLabel.BorderSizePixel = 0

local CombatCorner = Instance.new("UICorner", CombatLabel)
CombatCorner.CornerRadius = UDim.new(0, 6)

createToggle(ScrollContainer, "Kill Aura", Settings.KillAura, function(v) Settings.KillAura = v end)
createSlider(ScrollContainer, "Aura Range", 8, 35, Settings.KillAuraRange, function(v) Settings.KillAuraRange = v end)
createToggle(ScrollContainer, "Kill Murderer (Far)", Settings.KillMurdererFar, function(v) Settings.KillMurdererFar = v end)
createToggle(ScrollContainer, "Auto Shoot", Settings.AutoShootMurderer, function(v) Settings.AutoShootMurderer = v end)
createToggle(ScrollContainer, "Silent Aim", Settings.SilentAim, function(v) Settings.SilentAim = v end)
createToggle(ScrollContainer, "Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
createSlider(ScrollContainer, "Aimbot Sens", 0.1, 1, Settings.AimbotSensitivity, function(v) Settings.AimbotSensitivity = v / 10 end)

-- MOVEMENT SECTION
local MovementLabel = Instance.new("TextLabel", ScrollContainer)
MovementLabel.Size = UDim2.new(1, -10, 0, 25)
MovementLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
MovementLabel.TextColor3 = Color3.white
MovementLabel.TextSize = 13
MovementLabel.Font = Enum.Font.GothamBold
MovementLabel.Text = "🚀 MOVEMENT"
MovementLabel.BorderSizePixel = 0

local MovementCorner = Instance.new("UICorner", MovementLabel)
MovementCorner.CornerRadius = UDim.new(0, 6)

createToggle(ScrollContainer, "Speed Hack", Settings.SpeedHack, function(v) Settings.SpeedHack = v end)
createSlider(ScrollContainer, "Walk Speed", 16, 100, Settings.WalkSpeed, function(v) Settings.WalkSpeed = v end)
createToggle(ScrollContainer, "Flight", Settings.Flight, function(v) 
   Settings.Flight = v 
   if v then startFlight() end
end)
createSlider(ScrollContainer, "Flight Speed", 10, 150, Settings.FlightSpeed, function(v) Settings.FlightSpeed = v end)
createToggle(ScrollContainer, "Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)

-- VISUALS SECTION
local VisualsLabel = Instance.new("TextLabel", ScrollContainer)
VisualsLabel.Size = UDim2.new(1, -10, 0, 25)
VisualsLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
VisualsLabel.TextColor3 = Color3.white
VisualsLabel.TextSize = 13
VisualsLabel.Font = Enum.Font.GothamBold
VisualsLabel.Text = "👁️ VISUALS"
VisualsLabel.BorderSizePixel = 0

local VisualsCorner = Instance.new("UICorner", VisualsLabel)
VisualsCorner.CornerRadius = UDim.new(0, 6)

createToggle(ScrollContainer, "Murderer ESP 🔴", Settings.MurderESP, function(v) Settings.MurderESP = v refreshESP() end)
createToggle(ScrollContainer, "Sheriff ESP 🔵", Settings.SheriffESP, function(v) Settings.SheriffESP = v refreshESP() end)
createToggle(ScrollContainer, "Innocent ESP 🟡", Settings.InnocentESP, function(v) Settings.InnocentESP = v refreshESP() end)
createToggle(ScrollContainer, "Health Bars", Settings.ShowHealthBar, function(v) Settings.ShowHealthBar = v end)
createToggle(ScrollContainer, "Speedometer", Settings.ShowSpeedometer, function(v) Settings.ShowSpeedometer = v end)

-- UTILITY SECTION
local UtilityLabel = Instance.new("TextLabel", ScrollContainer)
UtilityLabel.Size = UDim2.new(1, -10, 0, 25)
UtilityLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
UtilityLabel.TextColor3 = Color3.white
UtilityLabel.TextSize = 13
UtilityLabel.Font = Enum.Font.GothamBold
UtilityLabel.Text = "🔧 UTILITY"
UtilityLabel.BorderSizePixel = 0

local UtilityCorner = Instance.new("UICorner", UtilityLabel)
UtilityCorner.CornerRadius = UDim.new(0, 6)

createToggle(ScrollContainer, "God Mode", Settings.GodMode, function(v) Settings.GodMode = v end)
createToggle(ScrollContainer, "Auto Grab Gun", Settings.AutoGrabGun, function(v) Settings.AutoGrabGun = v end)
createToggle(ScrollContainer, "Anti AFK", Settings.AntiAFK, function(v) Settings.AntiAFK = v end)
createToggle(ScrollContainer, "Infinite Stamina", Settings.InfiniteStamina, function(v) Settings.InfiniteStamina = v end)

-- SETTINGS SECTION
local SettingsLabel = Instance.new("TextLabel", ScrollContainer)
SettingsLabel.Size = UDim2.new(1, -10, 0, 25)
SettingsLabel.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SettingsLabel.TextColor3 = Color3.white
SettingsLabel.TextSize = 13
SettingsLabel.Font = Enum.Font.GothamBold
SettingsLabel.Text = "⚙️ SETTINGS"
SettingsLabel.BorderSizePixel = 0

local SettingsCorner = Instance.new("UICorner", SettingsLabel)
SettingsCorner.CornerRadius = UDim.new(0, 6)

createButton(ScrollContainer, "💾 Save Settings", saveSettings)
createButton(ScrollContainer, "📂 Load Settings", loadSettings)

-- Notification
local Notification = Instance.new("TextLabel", UserGui)
Notification.Name = "Notification"
Notification.Size = UDim2.new(0, 450, 0, 100)
Notification.Position = UDim2.new(0.5, -225, 0, 20)
Notification.BackgroundColor3 = Color3.fromRGB(30, 150, 60)
Notification.TextColor3 = Color3.white
Notification.TextSize = 14
Notification.Font = Enum.Font.GothamBold
Notification.Text = "✅ MM2 GOD-TIER 2026 EXPANDED\n✨ All Features Loaded!\n🎮 Ready to Dominate!"
Notification.BorderSizePixel = 0

local NotifCorner = Instance.new("UICorner", Notification)
NotifCorner.CornerRadius = UDim.new(0, 8)

task.wait(5)
Notification:TweenPosition(UDim2.new(0.5, -225, 0, -120), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true, function()
   Notification:Destroy()
end)

print("✅ MM2 GOD-TIER 2026 EXPANDED • All Features Ready!")
