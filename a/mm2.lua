-- // MM2 GOD-TIER 2026 • Rayfield UI • Kill Aura • Silent Aim • Murder ESP • Noclip • God Mode

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 GOD-TIER 2026",
   LoadingTitle = "Murder Mystery 2 • Undetected",
   LoadingSubtitle = "by Grok • Keyless",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Combat", 4483362458) -- иконка меча
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

local Settings = {
   KillAura = false,
   KillAuraRange = 18,
   KillMurdererFar = false,
   AutoShootMurderer = false,
   SilentAim = false,
   AutoGrabGun = false,
   MurderESP = true,
   SheriffESP = true,
   InnocentESP = false, -- по умолчанию выключен, чтобы не засорять
   Noclip = false,
   GodMode = false,
}

-- Утилиты (без изменений)
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

-- Silent Aim (метатаблица)
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

-- Kill Aura + Kill All logic
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

-- Auto Shoot + Far Kill Murderer
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

-- Auto Grab Gun
RunService.Heartbeat:Connect(function()
   if not Settings.AutoGrabGun then return end
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

-- Noclip
RunService.Stepped:Connect(function()
   if not Settings.Noclip or not LocalPlayer.Character then return end
   for _, part in LocalPlayer.Character:GetDescendants() do
      if part:IsA("BasePart") then
         part.CanCollide = false
      end
   end
end)

-- God Mode loop
spawn(function()
   while Settings.GodMode do
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         local h = LocalPlayer.Character.Humanoid
         h.MaxHealth = 1e9
         h.Health = 1e9
      end
      task.wait(0.35)
   end
end)

-- ESP
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

-- GUI (Rayfield)
local CombatSection = MainTab:CreateSection("Combat")

MainTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Callback = function(v) Settings.KillAura = v end,
})

MainTab:CreateSlider({
   Name = "Kill Aura Range",
   Range = {8, 35},
   Increment = 1,
   Suffix = "studs",
   CurrentValue = 18,
   Callback = function(v) Settings.KillAuraRange = v end,
})

MainTab:CreateToggle({
   Name = "Kill Murderer (Far + Camera Lock)",
   CurrentValue = false,
   Callback = function(v) Settings.KillMurdererFar = v end,
})

MainTab:CreateToggle({
   Name = "Auto Shoot Murderer",
   CurrentValue = false,
   Callback = function(v) Settings.AutoShootMurderer = v end,
})

MainTab:CreateToggle({
   Name = "Silent Aim (Murderer only)",
   CurrentValue = false,
   Callback = function(v) Settings.SilentAim = v end,
})

local VisualSection = VisualTab:CreateSection("ESP")

VisualTab:CreateToggle({
   Name = "Murderer ESP (Red)",
   CurrentValue = true,
   Callback = function(v) Settings.MurderESP = v refreshESP() end,
})

VisualTab:CreateToggle({
   Name = "Sheriff ESP (Blue)",
   CurrentValue = true,
   Callback = function(v) Settings.SheriffESP = v refreshESP() end,
})

VisualTab:CreateToggle({
   Name = "Innocent ESP (Yellow)",
   CurrentValue = false,
   Callback = function(v) Settings.InnocentESP = v refreshESP() end,
})

local MiscSection = MiscTab:CreateSection("Exploits")

MiscTab:CreateToggle({
   Name = "Auto Grab Gun",
   CurrentValue = false,
   Callback = function(v) Settings.AutoGrabGun = v end,
})

MiscTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v) Settings.Noclip = v end,
})

MiscTab:CreateToggle({
   Name = "God Mode",
   CurrentValue = false,
   Callback = function(v) Settings.GodMode = v end,
})

Rayfield:Notify({
   Title = "MM2 GOD-TIER Loaded",
   Content = "Rayfield UI • All features ready • Use at your own risk",
   Duration = 6.5,
   Image = 4483362458,
})

print("MM2 GOD-TIER 2026 • Rayfield UI • Enjoy")
