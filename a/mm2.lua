-- // MM2 GOD-TIER PRO 2026 • EXPANDED VERSION • Multiple New Features
-- 🔥 KILL AURA • SILENT AIM • ESP • TELEPORT • SPEED HACK • SPEED TRAINER
-- 💀 AUTO FARM • MURDER HUNTER • WALK SPEED • JUMP POWER • FLIGHT

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
   KillAuraSpeed = 1,
   KillMurdererFar = false,
   AutoShootMurderer = false,
   SilentAim = false,
   
   -- Movement
   Noclip = false,
   GodMode = false,
   SpeedHack = false,
   SpeedHackValue = 1.5,
   JumpPower = 50,
   WalkSpeed = 16,
   Flight = false,
   FlightSpeed = 50,
   
   -- Farming
   AutoGrabGun = false,
   AutoFarm = false,
   MurderHunter = false,
   
   -- ESP
   MurderESP = true,
   SheriffESP = true,
   InnocentESP = false,
   ESPDistance = true,
   
   -- Other
   AntiStun = false,
   LoopKill = false,
   TargetSpecificPlayer = false,
}

local TargetPlayer = nil

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

local function getNearestPlayer()
   local nearest = nil
   local distance = math.huge
   for _, plr in Players:GetPlayers() do
      if plr ~= LocalPlayer and isAlive(plr) and plr.Character:FindFirstChild("HumanoidRootPart") then
         local dist = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
         if dist < distance then
            distance = dist
            nearest = plr
         end
      end
   end
   return nearest
end

local function getNearestHead(char)
   if not char then return nil end
   local head = char:FindFirstChild("Head")
   return head or char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(position)
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
   end
end

local function getDistance(plr)
   if not plr.Character or not LocalPlayer.Character then return 0 end
   return (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
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
         local target = TargetPlayer if Settings.TargetSpecificPlayer and TargetPlayer else getMurderer()
         if target and isAlive(target) then
            local head = getNearestHead(target.Character)
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

-- ============== KILL AURA ==============
local killAuraCounter = 0
RunService.Heartbeat:Connect(function()
   if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
   local myRoot = LocalPlayer.Character.HumanoidRootPart
   local myPos  = myRoot.Position
   
   if Settings.KillAura or Settings.LoopKill then
      killAuraCounter = killAuraCounter + 1
      if killAuraCounter < (10 / Settings.KillAuraSpeed) then return end
      killAuraCounter = 0
      
      for _, plr in Players:GetPlayers() do
         if plr ~= LocalPlayer and isAlive(plr) and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist <= Settings.KillAuraRange then
               pcall(function() plr.Character.Humanoid:TakeDamage(100) end)
            end
         end
      end
   end
end)

-- ============== MURDER HUNTER ==============
RunService.Heartbeat:Connect(function()
   if not Settings.MurderHunter or not LocalPlayer.Character then return end
   
   local murderer = getMurderer()
   if murderer and isAlive(murderer) and murderer.Character:FindFirstChild("HumanoidRootPart") then
      teleportTo(murderer.Character.HumanoidRootPart.Position + Vector3.new(5, 0, 0))
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

-- ============== AUTO GRAB GUN ==============
RunService.Heartbeat:Connect(function()
   if not Settings.AutoGrabGun then return end
   if not LocalPlayer.Character then return end
   if LocalPlayer.Character:FindFirstChild("Gun") then return end
   
   for _, obj in Workspace:GetChildren() do
      if obj:IsA("Tool") and obj.Name == "Gun" then
         local handle = obj.Handle or obj.PrimaryPart
         if handle and (handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 40 then
            pcall(function() fireclickdetector(obj:FindFirstChildOfClass("ClickDetector")) end)
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

-- ============== SPEED HACK & FLIGHT ==============
RunService.RenderStepped:Connect(function()
   if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if not humanoid then return end
   
   -- Walk Speed
   humanoid.WalkSpeed = Settings.WalkSpeed
   
   -- Jump Power
   humanoid.JumpPower = Settings.JumpPower
   
   -- Speed Hack
   if Settings.SpeedHack then
      local direction = humanoid.MoveDirection
      if direction.Magnitude > 0 then
         LocalPlayer.Character.HumanoidRootPart.Velocity = direction * Settings.SpeedHackValue * 100
      end
   end
   
   -- Flight
   if Settings.Flight then
      local root = LocalPlayer.Character.HumanoidRootPart
      local moveDir = humanoid.MoveDirection
      if moveDir.Magnitude > 0 then
         root.Velocity = moveDir * Settings.FlightSpeed
      end
   end
end)

-- ============== ANTI STUN ==============
RunService.Heartbeat:Connect(function()
   if not Settings.AntiStun or not LocalPlayer.Character then return end
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if humanoid then
      humanoid:ClearStateStack()
   end
end)

-- ============== AUTO FARM ==============
RunService.Heartbeat:Connect(function()
   if not Settings.AutoFarm then return end
   if not LocalPlayer.Character then return end
   
   -- Auto grab dropped items
   for _, obj in Workspace:GetChildren() do
      if obj:IsA("Tool") and obj ~= LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
         local handle = obj.Handle or obj.PrimaryPart
         if handle and (handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 30 then
            pcall(function() fireclickdetector(obj:FindFirstChildOfClass("ClickDetector")) end)
         end
      end
   end
end)

-- ============== ESP ==============
local ESP = {}
local function createESP(plr)
   if plr == LocalPlayer or ESP[plr] then return end
   if not plr.Character then return end
   
   local root = plr.Character:FindFirstChild("HumanoidRootPart")
   if not root then return end
   
   local bb = Instance.new("BillboardGui", root)
   bb.Adornee = root
   bb.Size = UDim2.new(0, 200, 0, 50)
   bb.AlwaysOnTop = true
   bb.StudsOffset = Vector3.new(0, 4.2, 0)
   
   local txt = Instance.new("TextLabel", bb)
   txt.Size = UDim2.new(1,0,1,0)
   txt.BackgroundTransparency = 1
   txt.TextScaled = true
   txt.Font = Enum.Font.GothamBold
   txt.TextStrokeTransparency = 0.5
   txt.TextStrokeColor3 = Color3.new(0,0,0)
   
   ESP[plr] = bb
   
   plr.CharacterRemoving:Connect(function()
      if ESP[plr] then pcall(function() ESP[plr]:Destroy() end) ESP[plr] = nil end
   end)
end

local function refreshESP()
   for _, plr in Players:GetPlayers() do
      if plr == LocalPlayer then continue end
      local role = getRole(plr)
      local enabled = false
      local color = Color3.fromRGB(200,200,60)
      local displayText = plr.Name .. " [" .. role .. "]"
      
      if Settings.ESPDistance then
         displayText = displayText .. " [" .. math.floor(getDistance(plr)) .. "m]"
      end
      
      if role == "Murderer" and Settings.MurderESP then
         color = Color3.fromRGB(220,40,40)
         enabled = true
      elseif role == "Sheriff" and Settings.SheriffESP then
         color = Color3.fromRGB(60,140,255)
         enabled = true
      elseif role == "Innocent" and Settings.InnocentESP then
         enabled = true
      end
      
      if enabled then
         createESP(plr)
         if ESP[plr] and ESP[plr].TextLabel then
            ESP[plr].TextLabel.Text = displayText
            ESP[plr].TextLabel.TextColor3 = color
         end
      else
         if ESP[plr] then pcall(function() ESP[plr]:Destroy() end) ESP[plr] = nil end
      end
   end
end

Players.PlayerAdded:Connect(function(p) 
   p.CharacterAdded:Connect(function() task.delay(1, refreshESP) end) 
end)
RunService.Heartbeat:Connect(refreshESP)

-- ============== GUI КАСТОМНЫЙ ==============
local MainGui = Instance.new("ScreenGui", UserGui)
MainGui.Name = "MM2_GOD_TIER_PRO_GUI"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 650)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
MainFrame.BorderSizePixel = 0

local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Color = ColorSequence.new({
   ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 5, 15)),
   ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 200))
})
UIGradient.Rotation = 45

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(20, 50, 120)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Text = "🔥 MM2 GOD-TIER PRO"
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
   MainFrame:TweenSize(UDim2.new(0, 350, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true, function()
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
   MainFrame:TweenSize(UDim2.new(0, 350, 0, 650), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3)
   OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
   OpenBtn.Visible = true
end)

-- Drag
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

-- ScrollContainer
local ScrollContainer = Instance.new("ScrollingFrame", MainFrame)
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -10, 1, -60)
ScrollContainer.Position = UDim2.new(0, 5, 0, 55)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)

local Layout = Instance.new("UIListLayout", ScrollContainer)
Layout.Padding = UDim.new(0, 8)
Layout.FillDirection = Enum.FillDirection.Vertical
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ============== UI FUNCTIONS ==============
local function createSection(parent, name, emoji)
   local Label = Instance.new("TextLabel", parent)
   Label.Size = UDim2.new(1, -10, 0, 25)
   Label.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
   Label.TextColor3 = Color3.white
   Label.TextSize = 12
   Label.Font = Enum.Font.GothamBold
   Label.Text = emoji .. " " .. name
   Label.BorderSizePixel = 0
   local Corner = Instance.new("UICorner", Label)
   Corner.CornerRadius = UDim.new(0, 6)
end

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
   Label.TextSize = 12
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
   Container.Size = UDim2.new(1, 0, 0, 50)
   Container.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
   Container.BorderSizePixel = 0
   
   local Corner = Instance.new("UICorner", Container)
   Corner.CornerRadius = UDim.new(0, 8)
   
   local Label = Instance.new("TextLabel", Container)
   Label.Size = UDim2.new(1, -60, 0, 20)
   Label.Position = UDim2.new(0, 10, 0, 5)
   Label.BackgroundTransparency = 1
   Label.TextColor3 = Color3.fromRGB(200, 200, 200)
   Label.TextSize = 11
   Label.Font = Enum.Font.GothamBold
   Label.Text = name .. ": " .. defaultValue
   Label.TextXAlignment = Enum.TextXAlignment.Left
   
   local SliderBg = Instance.new("Frame", Container)
   SliderBg.Size = UDim2.new(1, -20, 0, 8)
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
   local Button = Instance.new("TextButton", parent)
   Button.Size = UDim2.new(1, 0, 0, 35)
   Button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
   Button.TextColor3 = Color3.white
   Button.TextSize = 13
   Button.Font = Enum.Font.GothamBold
   Button.Text = name
   Button.BorderSizePixel = 0
   
   local Corner = Instance.new("UICorner", Button)
   Corner.CornerRadius = UDim.new(0, 8)
   
   Button.MouseButton1Click:Connect(callback)
   
   Button.MouseEnter:Connect(function()
      Button.BackgroundColor3 = Color3.fromRGB(90, 150, 200)
   end)
   
   Button.MouseLeave:Connect(function()
      Button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
   end)
   
   return Button
end

-- ============== GUI ELEMENTS ==============

-- COMBAT SECTION
createSection(ScrollContainer, "COMBAT", "⚔️")
createToggle(ScrollContainer, "Kill Aura", Settings.KillAura, function(v) Settings.KillAura = v end)
createSlider(ScrollContainer, "Aura Range", 8, 35, Settings.KillAuraRange, function(v) Settings.KillAuraRange = v end)
createSlider(ScrollContainer, "Aura Speed", 0.5, 3, Settings.KillAuraSpeed, function(v) Settings.KillAuraSpeed = v end)
createToggle(ScrollContainer, "Loop Kill All", Settings.LoopKill, function(v) Settings.LoopKill = v end)
createToggle(ScrollContainer, "Kill Murderer (Far)", Settings.KillMurdererFar, function(v) Settings.KillMurdererFar = v end)
createToggle(ScrollContainer, "Auto Shoot", Settings.AutoShootMurderer, function(v) Settings.AutoShootMurderer = v end)
createToggle(ScrollContainer, "Silent Aim", Settings.SilentAim, function(v) Settings.SilentAim = v end)
createToggle(ScrollContainer, "Murder Hunter", Settings.MurderHunter, function(v) Settings.MurderHunter = v end)

-- MOVEMENT SECTION
createSection(ScrollContainer, "MOVEMENT", "🏃")
createToggle(ScrollContainer, "God Mode", Settings.GodMode, function(v) Settings.GodMode = v end)
createToggle(ScrollContainer, "Noclip", Settings.Noclip, function(v) Settings.Noclip = v end)
createSlider(ScrollContainer, "Walk Speed", 16, 100, Settings.WalkSpeed, function(v) Settings.WalkSpeed = v end)
createSlider(ScrollContainer, "Jump Power", 50, 150, Settings.JumpPower, function(v) Settings.JumpPower = v end)
createToggle(ScrollContainer, "Speed Hack", Settings.SpeedHack, function(v) Settings.SpeedHack = v end)
createSlider(ScrollContainer, "Speed Value", 1, 3, Settings.SpeedHackValue, function(v) Settings.SpeedHackValue = v end)
createToggle(ScrollContainer, "Flight", Settings.Flight, function(v) Settings.Flight = v end)
createSlider(ScrollContainer, "Flight Speed", 10, 150, Settings.FlightSpeed, function(v) Settings.FlightSpeed = v end)
createToggle(ScrollContainer, "Anti Stun", Settings.AntiStun, function(v) Settings.AntiStun = v end)

-- FARMING SECTION
createSection(ScrollContainer, "FARMING", "💎")
createToggle(ScrollContainer, "Auto Grab Gun", Settings.AutoGrabGun, function(v) Settings.AutoGrabGun = v end)
createToggle(ScrollContainer, "Auto Farm", Settings.AutoFarm, function(v) Settings.AutoFarm = v end)
createButton(ScrollContainer, "📍 Teleport to Murderer", function()
   local murd = getMurderer()
   if murd and isAlive(murd) then
      teleportTo(murd.Character.HumanoidRootPart.Position + Vector3.new(5, 3, 0))
   end
end)
createButton(ScrollContainer, "📍 Teleport to Nearest", function()
   local nearest = getNearestPlayer()
   if nearest then
      teleportTo(nearest.Character.HumanoidRootPart.Position + Vector3.new(5, 3, 0))
   end
end)

-- VISUAL SECTION
createSection(ScrollContainer, "VISUALS", "👁️")
createToggle(ScrollContainer, "Murderer ESP", Settings.MurderESP, function(v) Settings.MurderESP = v refreshESP() end)
createToggle(ScrollContainer, "Sheriff ESP", Settings.SheriffESP, function(v) Settings.SheriffESP = v refreshESP() end)
createToggle(ScrollContainer, "Innocent ESP", Settings.InnocentESP, function(v) Settings.InnocentESP = v refreshESP() end)
createToggle(ScrollContainer, "Show Distance", Settings.ESPDistance, function(v) Settings.ESPDistance = v refreshESP() end)

-- NOTIFICATION
local Notification = Instance.new("TextLabel", UserGui)
Notification.Name = "Notification"
Notification.Size = UDim2.new(0, 450, 0, 100)
Notification.Position = UDim2.new(0.5, -225, 0, 20)
Notification.BackgroundColor3 = Color3.fromRGB(30, 150, 60)
Notification.TextColor3 = Color3.white
Notification.TextSize = 13
Notification.Font = Enum.Font.GothamBold
Notification.Text = "✅ MM2 GOD-TIER PRO 2026 LOADED!\n🔥 All Features Ready • Draggable UI\n💀 Kill Aura • Flight • Speed Hack • Murder Hunter"
Notification.BorderSizePixel = 0
Notification.TextWrapped = true

local NotifCorner = Instance.new("UICorner", Notification)
NotifCorner.CornerRadius = UDim.new(0, 8)

task.wait(5)
Notification:TweenPosition(UDim2.new(0.5, -225, 0, -120), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true, function()
   Notification:Destroy()
end)

print("✅ MM2 GOD-TIER PRO 2026 • EXPANDED • All Features Active!")
