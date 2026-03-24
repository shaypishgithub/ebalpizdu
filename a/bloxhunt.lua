local player = game.Players.LocalPlayer
local plot = player:WaitForChild("Plot").Value

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("EBAL HUB", "DarkTheme")

-- ====================== BASE TAB ======================
local Base = Window:NewTab("Base")
local BaseSection = Base:NewSection("Main Functions")

BaseSection:NewLabel("Your Plot: " .. plot.Name)

BaseSection:NewButton("Collect All Cash (Once)", "", function()
    for _, a in pairs(plot.Floors:GetDescendants()) do
        if a.Name == "CollectPartTouch" then
            firetouchinterest(player.Character.HumanoidRootPart, a, 1)
            task.wait(0.1)
            firetouchinterest(player.Character.HumanoidRootPart, a, 0)
        end
    end
end)

BaseSection:NewButton("Pick Up All Computers", "", function()
    for _, a in pairs(plot.Floors:GetDescendants()) do
        if a.Name == "ProximityPrompt" and a.Parent.Name == "Top" and a.Parent.Parent:FindFirstChild("VisualModel") then
            fireproximityprompt(a)
        end
    end
end)

BaseSection:NewButton("Place All Computers", "", function()
    for _, a in pairs(player.Backpack:GetChildren()) do
        if a:FindFirstChild("ItemGUI") then
            a.Parent = player.Character
            task.wait(0.3)
            for _, b in pairs(plot.Floors:GetDescendants()) do
                if b:FindFirstChild("Top") and not b:FindFirstChild("VisualModel") then
                    fireproximityprompt(b.Top.ProximityPrompt)
                    task.wait(0.5)
                    break
                end
            end
        end
    end
end)

BaseSection:NewButton("Sell All Computers", "", function()
    Library:Notification("Подтверждение", "Ты уверен, что хочешь продать всё?", "Yes", function()
        for _, a in pairs(plot.Floors:GetDescendants()) do
            if a.Name == "SellProximity" and a.Parent.Parent:FindFirstChild("VisualModel") then
                Library:Notification("Продажа", "Sold: " .. a.Parent.Parent.VisualModel:FindFirstChildWhichIsA("MeshPart").Name, "Info")
                fireproximityprompt(a)
                task.wait(0.3)
            end
        end
    end)
end)

-- ====================== BLOX HUNT FEATURES TAB ======================
local BhTab = Window:NewTab("Blox Hunt")
local BhSection = BhTab:NewSection("Blox Hunt Features")

-- ESP на игроков
BhSection:NewToggle("ESP Players", "Показывает всех игроков через стены с именем и дистанцией", false, function(state)
    getgenv().BloxESP = state
    
    if state then
        spawn(function()
            while getgenv().BloxESP do
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local root = plr.Character.HumanoidRootPart
                        local dist = math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                        
                        -- Простой BillboardGui ESP
                        if not root:FindFirstChild("BloxESP") then
                            local bill = Instance.new("BillboardGui")
                            bill.Name = "BloxESP"
                            bill.Adornee = root
                            bill.Size = UDim2.new(0, 200, 0, 50)
                            bill.StudsOffset = Vector3.new(0, 3, 0)
                            bill.AlwaysOnTop = true
                            
                            local text = Instance.new("TextLabel")
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.Text = plr.Name .. " [" .. dist .. "m]"
                            text.TextColor3 = Color3.fromRGB(255, 50, 50)
                            text.TextScaled = true
                            text.Font = Enum.Font.GothamBold
                            text.Parent = bill
                            
                            bill.Parent = root
                        else
                            local lbl = root.BloxESP.TextLabel
                            lbl.Text = plr.Name .. " [" .. dist .. "m]"
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    else
        -- Удаляем ESP
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local esp = plr.Character.HumanoidRootPart:FindFirstChild("BloxESP")
                if esp then esp:Destroy() end
            end
        end
    end
end)

-- God Mode
BhSection:NewToggle("God Mode", "Бессмертие", false, function(state)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.MaxHealth = state and math.huge or 100
        player.Character.Humanoid.Health = state and math.huge or 100
    end
end)

-- Infinity Energy
BhSection:NewToggle("Infinity Energy", "Бесконечная энергия/стамина", false, function(state)
    getgenv().InfEnergy = state
    spawn(function()
        while getgenv().InfEnergy do
            pcall(function()
                if player.Character then
                    local energy = player.Character:FindFirstChild("Energy") or player:FindFirstChild("Energy")
                    if energy and energy.Value then
                        energy.Value = 999999
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end)

-- Speed Hack
BhSection:NewSlider("WalkSpeed", "Скорость персонажа", 16, 300, 100, function(value)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end)

-- Auto Farm Coins / Tokens
local autoFarm = false
BhSection:NewToggle("Auto Farm Coins", "Автоматический сбор монет/токенов", false, function(state)
    autoFarm = state
    if state then
        spawn(function()
            while autoFarm do
                pcall(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Part") or v:IsA("MeshPart") then
                            local n = v.Name:lower()
                            if n:find("coin") or n:find("token") or n:find("cash") or n:find("orb") then
                                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                    player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                                    task.wait(0.25)
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

-- ====================== ТВОИ ОСТАЛЬНЫЕ ТАБЫ ======================
local UpgradeTab = Window:NewTab("Upgrade")
local UpgradeSection = UpgradeTab:NewSection("Upgrades")

local autoUpgrade = false
UpgradeSection:NewToggle("Auto Upgrade All", "", false, function(state)
    autoUpgrade = state
end)

UpgradeSection:NewButton("Upgrade All (Once)", "", function()
    for _, a in pairs(plot.Floors:GetDescendants()) do
        if a:FindFirstChild("VisualModel") then
            local args = { buffer.fromstring("\v\003One"), {a} }
            game:GetService("ReplicatedStorage").Packages.Packet.RemoteEvent:FireServer(unpack(args))
        end
    end
end)

local AutoTab = Window:NewTab("Auto")
local AutoSection = AutoTab:NewSection("Automation")

local autoMoney = false
AutoSection:NewToggle("Auto Money Pick Up", "", false, function(state)
    autoMoney = state
end)

-- Авто улучшение
task.spawn(function()
    while task.wait(2) do
        if autoUpgrade then
            for _, a in pairs(plot.Floors:GetDescendants()) do
                if a:FindFirstChild("VisualModel") then
                    local args = { buffer.fromstring("\v\003One"), {a} }
                    game:GetService("ReplicatedStorage").Packages.Packet.RemoteEvent:FireServer(unpack(args))
                end
            end
        end
    end
end)

-- Автосбор денег
task.spawn(function()
    while task.wait(1) do
        if autoMoney then
            for _, a in pairs(plot.Floors:GetDescendants()) do
                if a.Name == "CollectPartTouch" and a.Parent:FindFirstChild("VisualModel") then
                    firetouchinterest(player.Character.HumanoidRootPart, a, 1)
                    task.wait(0.1)
                    firetouchinterest(player.Character.HumanoidRootPart, a, 0)
                end
            end
        end
    end
end)

Library:Notify("EBAL HUB загружен!", "Все функции Blox Hunt добавлены", 5)
