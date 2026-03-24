local player = game.Players.LocalPlayer
local plot = player.Plot.Value

local tws = 25
local sdb = 1
local anc = false

local nex = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/library/hubs'), true))()
local window = nex.CreateWindow("EBAL HUB")

local mon = window:CreateTab("Base")
mon:CreateLabel("Your Plot: " .. plot.Name)

-- ==================== BLOX HUNT TAB ====================
local bh = window:CreateTab("Blox Hunt")

-- ESP Players
local espEnabled = false
local espConnections = {}

local function createESP(char, color)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = color
    
    local name = Drawing.new("Text")
    name.Size = 16
    name.Center = true
    name.Outline = true
    name.Color = color
    
    local conn
    conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not espEnabled or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            box.Visible = false
            name.Visible = false
            return
        end
        
        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        local humanoid = char.Humanoid
        
        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
        if onScreen then
            local top = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
            local bottom = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            local height = bottom.Y - top.Y
            local width = height / 2
            
            box.Size = Vector2.new(width, height)
            box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2 + 20) -- небольшой отступ
            box.Visible = true
            
            name.Text = char.Name .. " [" .. math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m]"
            name.Position = Vector2.new(pos.X, pos.Y - height/2 - 10)
            name.Visible = true
        else
            box.Visible = false
            name.Visible = false
        end
    end)
    
    table.insert(espConnections, conn)
end

local function toggleESP(state)
    espEnabled = state
    
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
    
    if not state then return end
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local color = plr.Team == player.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            createESP(plr.Character, color)
            
            plr.CharacterAdded:Connect(function(char)
                if espEnabled then
                    wait(0.5)
                    createESP(char, plr.Team == player.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                end
            end)
        end
    end
end

bh:CreateToggle("ESP Players", false, function(state)
    toggleESP(state)
end)

-- God Mode
bh:CreateToggle("God Mode", false, function(state)
    if state then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
        end
        player.CharacterAdded:Connect(function(char)
            wait(1)
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.MaxHealth = math.huge
                char.Humanoid.Health = math.huge
            end
        end)
    end
end)

-- Infinity Energy
local infEnergy = false
bh:CreateToggle("Infinity Energy", false, function(state)
    infEnergy = state
    spawn(function()
        while infEnergy and task.wait() do
            if player.Character and player.Character:FindFirstChild("Energy") then
                player.Character.Energy.Value = player.Character.Energy.MaxValue or 100
            end
        end
    end)
end)

-- Speed Hack
bh:CreateSlider("WalkSpeed", 16, 200, 50, function(value)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

-- Farm Coins / Tokens (простой автосбор)
local farmEnabled = false
bh:CreateToggle("Auto Farm Coins", false, function(state)
    farmEnabled = state
    spawn(function()
        while farmEnabled and task.wait(0.3) do
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("token")) then
                        if (player.Character.HumanoidRootPart.Position - obj.Position).Magnitude < 50 then
                            firetouchinterest(player.Character.HumanoidRootPart, obj, 0)
                            wait(0.1)
                            firetouchinterest(player.Character.HumanoidRootPart, obj, 1)
                        end
                    end
                end
            end)
        end
    end)
end)

bh:CreateLabel("Blox Hunt Features loaded!")
bh:CreateLabel("Use at your own risk :)")
