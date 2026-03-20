-- // MM2 GOD-TIER 2026 • Custom UI • Kill Aura • Silent Aim • Murder ESP • Noclip • God Mode

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

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

-- ===== CUSTOM GUI =====
local GUI = {}
GUI.MainFrame = nil
GUI.IsOpen = true
GUI.IsDragging = false
GUI.DragStart = nil
GUI.DragPos = nil

local function createGUI()
   local screenSize = LocalPlayer:GetMouse().Icon
   
   -- Main GUI Frame с градиентом
   local mainGui = Instance.new("ScreenGui")
   mainGui.Name = "MM2GodTierGUI"
   mainGui.ResetOnSpawn = false
   mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
   mainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
   
   -- Главное окно
   local mainFrame = Instance.new("Frame")
   mainFrame.Name = "MainFrame"
   mainFrame.Size = UDim2.new(0, 350, 0, 500)
   mainFrame.Position = UDim2.new(0, 50, 0, 50)
   mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35) -- тёмный фон
   mainFrame.BorderSizePixel = 0
   mainFrame.Parent = mainGui
   
   -- Градиент (голубой - чёрный)
   local gradient = Instance.new("UIGradient")
   gradient.Color = ColorSequence.new(
      Color3.fromRGB(30, 120, 180), -- голубой
      Color3.fromRGB(10, 10, 30)    -- чёрный
   )
   gradient.Rotation = 45
   gradient.Parent = mainFrame
   
   -- Граница
   local corner = Instance.new("UICorner")
   corner.CornerRadius = UDim.new(0, 10)
   corner.Parent = mainFrame
   
   -- Заголовок (драг панель)
   local header = Instance.new("Frame")
   header.Name = "Header"
   header.Size = UDim2.new(1, 0, 0, 40)
   header.BackgroundColor3 = Color3.fromRGB(20, 60, 100)
   header.BorderSizePixel = 0
   header.Parent = mainFrame
   
   local headerGradient = Instance.new("UIGradient")
   headerGradient.Color = ColorSequence.new(
      Color3.fromRGB(40, 150, 220),
      Color3.fromRGB(20, 80, 140)
   )
   headerGradient.Parent = header
   
   local headerCorner = Instance.new("UICorner")
   headerCorner.CornerRadius = UDim.new(0, 10)
   headerCorner.Parent = header
   
   -- Текст заголовка
   local titleLabel = Instance.new("TextLabel")
   titleLabel.Name = "Title"
   titleLabel.Size = UDim2.new(0, 250, 1, 0)
   titleLabel.Position = UDim2.new(0, 10, 0, 0)
   titleLabel.BackgroundTransparency = 1
   titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
   titleLabel.TextSize = 16
   titleLabel.Font = Enum.Font.GothamBold
   titleLabel.Text = "MM2 GOD-TIER 2026"
   titleLabel.TextXAlignment = Enum.TextXAlignment.Left
   titleLabel.Parent = header
   
   -- Кнопка Close/Open
   local toggleBtn = Instance.new("TextButton")
   toggleBtn.Name = "ToggleBtn"
   toggleBtn.Size = UDim2.new(0, 35, 0, 35)
   toggleBtn.Position = UDim2.new(1, -40, 0, 2.5)
   toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
   toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
   toggleBtn.TextSize = 14
   toggleBtn.Font = Enum.Font.GothamBold
   toggleBtn.Text = "-"
   toggleBtn.BorderSizePixel = 0
   toggleBtn.Parent = header
   
   local btnCorner = Instance.new("UICorner")
   btnCorner.CornerRadius = UDim.new(0, 5)
   btnCorner.Parent = toggleBtn
   
   -- Scroll контейнер
   local scrollContainer = Instance.new("ScrollingFrame")
   scrollContainer.Name = "ScrollContainer"
   scrollContainer.Size = UDim2.new(1, 0, 1, -45)
   scrollContainer.Position = UDim2.new(0, 0, 0, 45)
   scrollContainer.BackgroundTransparency = 1
   scrollContainer.BorderSizePixel = 0
   scrollContainer.ScrollBarThickness = 6
   scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 200)
   scrollContainer.Parent = mainFrame
   
   local listLayout = Instance.new("UIListLayout")
   listLayout.Padding = UDim.new(0, 8)
   listLayout.SortOrder = Enum.SortOrder.LayoutOrder
   listLayout.Parent = scrollContainer
   
   GUI.MainFrame = mainFrame
   GUI.Header = header
   GUI.ScrollContainer = scrollContainer
   GUI.ToggleBtn = toggleBtn
   
   -- Функция для создания Toggle
   local function createToggle(parent, name, defaultValue, callback)
      local toggleFrame = Instance.new("Frame")
      toggleFrame.Size = UDim2.new(0, 330, 0, 30)
      toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
      toggleFrame.BorderSizePixel = 0
      toggleFrame.Parent = parent
      
      local toggleCorner = Instance.new("UICorner")
      toggleCorner.CornerRadius = UDim.new(0, 5)
      toggleCorner.Parent = toggleFrame
      
      local label = Instance.new("TextLabel")
      label.Size = UDim2.new(0, 260, 1, 0)
      label.Position = UDim2.new(0, 8, 0, 0)
      label.BackgroundTransparency = 1
      label.TextColor3 = Color3.fromRGB(220, 220, 220)
      label.TextSize = 13
      label.Font = Enum.Font.Gotham
      label.Text = name
      label.TextXAlignment = Enum.TextXAlignment.Left
      label.Parent = toggleFrame
      
      local toggleBox = Instance.new("Frame")
      toggleBox.Size = UDim2.new(0, 24, 0, 24)
      toggleBox.Position = UDim2.new(1, -32, 0.5, -12)
      toggleBox.BackgroundColor3 = defaultValue and Color3.fromRGB(60, 150, 255) or Color3.fromRGB(50, 50, 80)
      toggleBox.BorderSizePixel = 0
      toggleBox.Parent = toggleFrame
      
      local boxCorner = Instance.new("UICorner")
      boxCorner.CornerRadius = UDim.new(0, 4)
      boxCorner.Parent = toggleBox
      
      local isEnabled = defaultValue
      
      toggleFrame.InputBegan:Connect(function(input, gameProcessed)
         if gameProcessed then return end
         if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isEnabled = not isEnabled
            toggleBox.BackgroundColor3 = isEnabled and Color3.fromRGB(60, 150, 255) or Color3.fromRGB(50, 50, 80)
            callback(isEnabled)
         end
      end)
      
      return toggleFrame
   end
   
   -- Функция для создания Slider
   local function createSlider(parent, name, min, max, default, callback)
      local sliderFrame = Instance.new("Frame")
      sliderFrame.Size = UDim2.new(0, 330, 0, 50)
      sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
      sliderFrame.BorderSizePixel = 0
      sliderFrame.Parent = parent
      
      local sliderCorner = Instance.new("UICorner")
      sliderCorner.CornerRadius = UDim.new(0, 5)
      sliderCorner.Parent = sliderFrame
      
      local label = Instance.new("TextLabel")
      label.Size = UDim2.new(1, -10, 0, 20)
      label.Position = UDim2.new(0, 8, 0, 2)
      label.BackgroundTransparency = 1
      label.TextColor3 = Color3.fromRGB(220, 220, 220)
      label.TextSize = 13
      label.Font = Enum.Font.Gotham
      label.Text = name .. ": " .. default
      label.TextXAlignment = Enum.TextXAlignment.Left
      label.Parent = sliderFrame
      
      local sliderBg = Instance.new("Frame")
      sliderBg.Size = UDim2.new(0, 310, 0, 4)
      sliderBg.Position = UDim2.new(0, 8, 0, 28)
      sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
      sliderBg.BorderSizePixel = 0
      sliderBg.Parent = sliderFrame
      
      local sliderBgCorner = Instance.new("UICorner")
      sliderBgCorner.CornerRadius = UDim.new(0, 2)
      sliderBgCorner.Parent = sliderBg
      
      local sliderFill = Instance.new("Frame")
      sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
      sliderFill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
      sliderFill.BorderSizePixel = 0
      sliderFill.Parent = sliderBg
      
      local fillCorner = Instance.new("UICorner")
      fillCorner.CornerRadius = UDim.new(0, 2)
      fillCorner.Parent = sliderFill
      
      sliderBg.InputBegan:Connect(function(input, gameProcessed)
         if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local sliderSize = sliderBg.AbsoluteSize.X
            local percentage = (LocalPlayer:GetMouse().X - sliderBg.AbsolutePosition.X) / sliderSize
            percentage = math.clamp(percentage, 0, 1)
            local value = math.round(min + (max - min) * percentage)
            
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            label.Text = name .. ": " .. value
            callback(value)
         end
      end)
      
      return sliderFrame
   end
   
   -- ===== СОЗДАНИЕ ЭЛЕМЕНТОВ GUI =====
   
   -- COMBAT TAB
   local combatLabel = Instance.new("TextLabel")
   combatLabel.Size = UDim2.new(0, 330, 0, 25)
   combatLabel.BackgroundColor3 = Color3.fromRGB(35, 80, 120)
   combatLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
   combatLabel.TextSize = 12
   combatLabel.Font = Enum.Font.GothamBold
   combatLabel.Text = "⚔ COMBAT"
   combatLabel.BorderSizePixel = 0
   combatLabel.Parent = scrollContainer
   
   local combatCorner = Instance.new("UICorner")
   combatCorner.CornerRadius = UDim.new(0, 5)
   combatCorner.Parent = combatLabel
   
   createToggle(scrollContainer, "Kill Aura", Settings.KillAura, function(v)
      Settings.KillAura = v
   end)
   
   createSlider(scrollContainer, "Kill Aura Range", 8, 35, Settings.KillAuraRange, function(v)
      Settings.KillAuraRange = v
   end)
   
   createToggle(scrollContainer, "Kill Murderer (Far)", Settings.KillMurdererFar, function(v)
      Settings.KillMurdererFar = v
   end)
   
   createToggle(scrollContainer, "Auto Shoot Murderer", Settings.AutoShootMurderer, function(v)
      Settings.AutoShootMurderer = v
   end)
   
   createToggle(scrollContainer, "Silent Aim", Settings.SilentAim, function(v)
      Settings.SilentAim = v
   end)
   
   -- VISUALS TAB
   local visualLabel = Instance.new("TextLabel")
   visualLabel.Size = UDim2.new(0, 330, 0, 25)
   visualLabel.BackgroundColor3 = Color3.fromRGB(35, 80, 120)
   visualLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
   visualLabel.TextSize = 12
   visualLabel.Font = Enum.Font.GothamBold
   visualLabel.Text = "👁 VISUALS"
   visualLabel.BorderSizePixel = 0
   visualLabel.Parent = scrollContainer
   
   local visualCorner = Instance.new("UICorner")
   visualCorner.CornerRadius = UDim.new(0, 5)
   visualCorner.Parent = visualLabel
   
   createToggle(scrollContainer, "Murderer ESP (Red)", Settings.MurderESP, function(v)
      Settings.MurderESP = v
   end)
   
   createToggle(scrollContainer, "Sheriff ESP (Blue)", Settings.SheriffESP, function(v)
      Settings.SheriffESP = v
   end)
   
   createToggle(scrollContainer, "Innocent ESP (Yellow)", Settings.InnocentESP, function(v)
      Settings.InnocentESP = v
   end)
   
   -- MISC TAB
   local miscLabel = Instance.new("TextLabel")
   miscLabel.Size = UDim2.new(0, 330, 0, 25)
   miscLabel.BackgroundColor3 = Color3.fromRGB(35, 80, 120)
   miscLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
   miscLabel.TextSize = 12
   miscLabel.Font = Enum.Font.GothamBold
   miscLabel.Text = "🔧 MISC"
   miscLabel.BorderSizePixel = 0
   miscLabel.Parent = scrollContainer
   
   local miscCorner = Instance.new("UICorner")
   miscCorner.CornerRadius = UDim.new(0, 5)
   miscCorner.Parent = miscLabel
   
   createToggle(scrollContainer, "Auto Grab Gun", Settings.AutoGrabGun, function(v)
      Settings.AutoGrabGun = v
   end)
   
   createToggle(scrollContainer, "Noclip", Settings.Noclip, function(v)
      Settings.Noclip = v
   end)
   
   createToggle(scrollContainer, "God Mode", Settings.GodMode, function(v)
      Settings.GodMode = v
   end)
   
   -- ===== DRAG ФУНКЦИОНАЛ =====
   header.InputBegan:Connect(function(input, gameProcessed)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
         GUI.IsDragging = true
         GUI.DragStart = LocalPlayer:GetMouse().Position
         GUI.DragPos = mainFrame.Position
      end
   end)
   
   header.InputEnded:Connect(function(input, gameProcessed)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
         GUI.IsDragging = false
      end
   end)
   
   UserInputService.InputChanged:Connect(function(input, gameProcessed)
      if GUI.IsDragging and GUI.DragStart then
         local delta = LocalPlayer:GetMouse().Position - GUI.DragStart
         mainFrame.Position = GUI.DragPos + UDim2.new(0, delta.X, 0, delta.Y)
      end
   end)
   
   -- ===== ОТКРЫТИЕ / ЗАКРЫТИЕ =====
   toggleBtn.MouseButton1Click:Connect(function()
      GUI.IsOpen = not GUI.IsOpen
      
      if GUI.IsOpen then
         mainFrame.Size = UDim2.new(0, 350, 0, 500)
         toggleBtn.Text = "-"
         toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
      else
         mainFrame.Size = UDim2.new(0, 350, 0, 45)
         toggleBtn.Text = "+"
         toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
      end
   end)
   
   print("✅ MM2 GOD-TIER GUI создана!")
end

createGUI()

-- ===== УТИЛИТЫ =====
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

-- ===== SILENT AIM =====
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

-- ===== KILL AURA =====
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

-- ===== AUTO SHOOT / FAR KILL =====
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

-- ===== AUTO GRAB GUN =====
RunService.Heartbeat:Connect(function()
   if not Settings.AutoGrabGun then return end
   if LocalPlayer.Character:FindFirstChild("Gun") then return end
   
   for _, obj in Workspace:GetChildren() do
      if obj:IsA("Tool") and obj.Name == "Gun" then
         local handle = obj.Handle or obj.PrimaryPart
         if handle and (handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 40 then
            pcall(function()
               local cd = obj:FindFirstChildOfClass("ClickDetector")
               if cd then fireclickdetector(cd) end
            end)
         end
      end
   end
end)

-- ===== NOCLIP =====
RunService.Stepped:Connect(function()
   if not Settings.Noclip or not LocalPlayer.Character then return end
   for _, part in LocalPlayer.Character:GetDescendants() do
      if part:IsA("BasePart") then
         part.CanCollide = false
      end
   end
end)

-- ===== GOD MODE (ФИКСИРОВАННЫЙ) =====
spawn(function()
   while true do
      if Settings.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         local h = LocalPlayer.Character.Humanoid
         h.MaxHealth = 1e9
         h.Health = 1e9
      end
      task.wait(0.35)
   end
end)

-- ===== ESP =====
local ESP = {}
local function createESP(plr)
   if plr == LocalPlayer or ESP[plr] then return end
   
   local char = plr.Character or plr.CharacterAdded:Wait()
   local root = char:WaitForChild("HumanoidRootPart", 6)
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
      if ESP[plr] then ESP[plr]:Destroy() ESP[plr] = nil end
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
         enabled = true
      end
      
      if enabled then
         createESP(plr)
         if ESP[plr] then
            local label = ESP[plr].TextLabel
            label.Text = plr.Name .. " [" .. role .. "]"
            label.TextColor3 = color
         end
      else
         if ESP[plr] then ESP[plr]:Destroy() ESP[plr] = nil end
      end
   end
end

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.delay(1, refreshESP) end) end)
RunService.Heartbeat:Connect(refreshESP)

print("🎮 MM2 GOD-TIER 2026 LOADED - Custom UI • Draggable • Collapsible")
print("📌 Готово к использованию! Используй на свой риск!")
