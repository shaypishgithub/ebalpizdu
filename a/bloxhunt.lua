local player = game.Players.LocalPlayer

local nex = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/library/hubs'),true))()
local window = nex.CreateWindow("EBAL HUB")

-- ==================== BLOX HUNT TAB ====================
local bh = window:CreateTab("Blox Hunt")

-- ESP на игроков
local espEnabled = false
local espConns = {}

local function CreateESP(char, color)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = color
    
    local nameTag = Drawing.new("Text")
    nameTag.Size = 15
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Color = color
    
    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not espEnabled or not char:FindFirstChild("HumanoidRootPart") then 
            box.Visible = false
            nameTag.Visible = false
            return 
        end
        
        local root = char.HumanoidRootPart
        local headPos = workspace.CurrentCamera:WorldToViewportPoint(root.Position + Vector3.new(0, 2, 0))
        local legPos = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        
        local onScreen = headPos.Z > 0
        if onScreen then
            local height = legPos.Y - headPos.Y
            box.Size = Vector2.new(height / 2, height)
            box.Position = Vector2.new(headPos.X - box.Size.X / 2, headPos.Y)
            box.Visible = true
            
            nameTag.Text = char.Name .. "  [" .. math.floor((player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (player.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0) .. "m]"
            nameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
            nameTag.Visible = true
        else
            box.Visible = false
            nameTag.Visible = false
        end
    end)
    
    table.insert(espConns, conn)
end

local function ToggleESP(state)
    espEnabled = state
    for _, c in pairs(espConns) do c:Disconnect() end
    espConns = {}
    
    if not state then return end
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local col = (plr.Team == player.Team) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
            CreateESP(plr.Character, col)
            
            plr.CharacterAdded:Connect(function(newChar)
                task.wait(0.6)
                if espEnabled then 
                    CreateESP(newChar, (plr.Team == player.Team) and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,50,50))
                end
            end)
        end
    end
end

bh:CreateToggle("ESP Players", false, function(v)
    ToggleESP(v)
end)

-- God Mode
bh:CreateToggle("God Mode", false, function(v)
    if v and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.MaxHealth = 9e9
        player.Character.Humanoid.Health = 9e9
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.MaxHealth = 9e9
            char.Humanoid.Health = 9e9
        end
    end)
end)

-- Infinity Energy
local infEnergy = false
bh:CreateToggle("Infinity Energy", false, function(v)
    infEnergy = v
    task.spawn(function()
        while infEnergy and task.wait() do
            pcall(function()
                if player.Character and player.Character:FindFirstChild("Energy") then
                    player.Character.Energy.Value = 100
                end
            end)
        end
    end)
end)

-- Speed Hack
bh:CreateSlider("WalkSpeed", 16, 250, 70, function(val)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = val
    end
end)

-- Auto Farm Coins
local farmCoins = false
bh:CreateToggle("Auto Farm Coins", false, function(v)
    farmCoins = v
    task.spawn(function()
        while farmCoins and task.wait(0.2) do
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("token") or obj.Name:lower():find("cash")) then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                            if dist < 70 then
                                firetouchinterest(player.Character.HumanoidRootPart, obj, 0)
                                task.wait(0.05)
                                firetouchinterest(player.Character.HumanoidRootPart, obj, 1)
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

bh:CreateLabel("Blox Hunt GUI Loaded")
bh:CreateLabel("Made for EBAL HUB")

window:Notify("EBAL HUB | Blox Hunt Loaded!", 3)
