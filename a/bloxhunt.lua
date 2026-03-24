local player = game.Players.LocalPlayer
local plot = player.Plot.Value

local tws = 25
local sdb = 1
local anc = false

local nex = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/library/hubs'), true))()
local window = nex.CreateWindow("EBAL HUB")

local mon = window:CreateTab("Base")
mon:CreateLabel("Your Plot: " .. plot.Name)

-- ====================== BLOX HUNT TAB ======================
local bh = window:CreateTab("Blox Hunt")

-- ESP Players
local espEnabled = false
bh:CreateToggle("ESP Players", false, function(state)
    espEnabled = state
    if state then
        -- Простой Drawing ESP (работает в большинстве эксплойтов)
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local esp = Drawing.new("Text")
                esp.Text = v.Name .. " (" .. math.floor((player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude) .. ")"
                esp.Size = 16
                esp.Color = Color3.fromRGB(255, 0, 0)
                esp.Outline = true
                esp.Visible = true
                
                -- Можно улучшить, но для начала хватит
                spawn(function()
                    while espEnabled and v.Character and v.Character:FindFirstChild("HumanoidRootPart") do
                        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                        if onScreen then
                            esp.Position = Vector2.new(pos.X, pos.Y)
                            esp.Text = v.Name .. " (" .. math.floor((player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude) .. ")"
                            esp.Visible = true
                        else
                            esp.Visible = false
                        end
                        wait(0.1)
                    end
                    esp:Remove()
                end)
            end
        end
    end
end)

-- God Mode
bh:CreateToggle("God Mode", false, function(state)
    if state then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
        end
        -- Защита от урона
        player.CharacterAdded:Connect(function(char)
            wait(1)
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.MaxHealth = math.huge
                char.Humanoid.Health = math.huge
            end
        end)
    end
end)

-- Infinity Energy (предполагаем, что энергия хранится в Character или Player)
bh:CreateToggle("Infinity Energy", false, function(state)
    if state then
        spawn(function()
            while state do
                if player.Character and player.Character:FindFirstChild("Energy") or player:FindFirstChild("Energy") then
                    local energy = player.Character:FindFirstChild("Energy") or player:FindFirstChild("Energy")
                    if energy then energy.Value = 999999 end
                end
                wait(0.5)
            end
        end)
    end
end)

-- Speed Hack
bh:CreateSlider("WalkSpeed", 16, 500, 100, false, function(value)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

-- Auto Farm Coins / Tokens (простая версия — телепорт к ближайшим токенам)
local farmEnabled = false
bh:CreateToggle("Auto Farm Coins", false, function(state)
    farmEnabled = state
    if state then
        spawn(function()
            while farmEnabled do
                pcall(function()
                    for _, token in pairs(workspace:GetDescendants()) do
                        if token:IsA("Part") and (token.Name:lower():find("coin") or token.Name:lower():find("token") or token.Name:lower():find("cash")) then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                player.Character.HumanoidRootPart.CFrame = token.CFrame + Vector3.new(0, 3, 0)
                                wait(0.3)
                            end
                        end
                    end
                end)
                wait(1)
            end
        end)
    end
end)

bh:CreateLabel("Blox Hunt Features loaded!")
bh:CreateButton("Destroy GUI", function()
    window:Destroy()
end)
