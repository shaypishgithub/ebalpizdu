--[[
    MEGA AI BOT v3.0
    Полностью автономный бот с:
    - Автоматическим движением к врагам
    - Поворотом камеры при обнаружении врага
    - Прыжками через препятствия
    - Обходом препятствий
    - Автоматической стрельбой
    - Системой pathfinding
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local PathfindingService = game:GetService("PathfindingService")
local Debris = game:GetService("Debris")

-- ============================================================
-- НАСТРОЙКИ
-- ============================================================
local Settings = {
    -- Основные настройки AI
    AIBotEnabled = true,           -- Включить AI бота
    AutoMove = true,               -- Автоматическое движение
    AutoShoot = true,              -- Автоматическая стрельба
    AutoAim = true,                -- Автоматическое прицеливание
    AutoJump = true,               -- Автоматические прыжки
    
    -- Настройки поиска врагов
    DetectionRange = 150,          -- Дальность обнаружения врагов
    AttackRange = 80,              -- Дальность атаки
    TeamCheck = true,              -- Проверка команды
    
    -- Настройки движения
    MovementSpeed = 50,            -- Скорость движения
    PathfindingRadius = 5,         -- Радиус поиска пути
    JumpPower = 50,                -- Сила прыжка
    
    -- Настройки камеры
    CameraSensitivity = 5,         -- Чувствительность камеры
    LookAheadDistance = 30,        -- Дистанция просмотра вперед
    
    -- Настройки стрельбы
    ShootDelay = 0.1,              -- Задержка между выстрелами
    AimPart = "Head",              -- Часть тела для прицела
    
    -- Визуальные настройки
    ShowDebug = true,              -- Показывать отладку
    ShowPath = true,               -- Показывать путь
}

-- ============================================================
-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================================
local CurrentTarget = nil
local PathWaypoints = {}
local CurrentWaypoint = 1
local LastShootTime = 0
local IsMoving = false
local CurrentPath = nil
local DebugObjects = {}
local NavMeshAgent = nil

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================

-- Проверка, является ли игра командной
local function IsTeamGame()
    local teams = {}
    for _, player in pairs(Players:GetPlayers()) do
        local team = player.Team or "NIL"
        teams[team] = true
    end
    local numTeams = 0
    for _ in pairs(teams) do numTeams = numTeams + 1 end
    return numTeams > 1
end

-- Получение всех живых врагов
local function GetAliveEnemies()
    local enemies = {}
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return enemies end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Проверка команды
            if Settings.TeamCheck and IsTeamGame() and player.Team == LocalPlayer.Team then
                continue
            end
            
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local humanoid = char.Humanoid
                if humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    local distance = (char.HumanoidRootPart.Position - myPos.Position).Magnitude
                    if distance <= Settings.DetectionRange then
                        table.insert(enemies, {
                            Player = player,
                            Character = char,
                            Distance = distance,
                            Root = char.HumanoidRootPart,
                            Humanoid = humanoid
                        })
                    end
                end
            end
        end
    end
    
    -- Сортировка по расстоянию
    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    return enemies
end

-- Получение ближайшего врага
local function GetNearestEnemy()
    local enemies = GetAliveEnemies()
    return enemies[1]
end

-- Получение части тела для прицела
local function GetAimPart(character)
    local parts = {
        "Head",
        "UpperTorso",
        "Torso",
        "HumanoidRootPart"
    }
    
    for _, partName in ipairs(parts) do
        local part = character:FindFirstChild(partName)
        if part then return part end
    end
    return character:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- СИСТЕМА ДВИЖЕНИЯ С ПРЕПЯТСТВИЯМИ
-- ============================================================

-- Проверка препятствия перед игроком
local function CheckObstacleAhead()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return false end
    
    -- Получаем направление движения
    local lookVector = root.CFrame.LookVector
    local rayOrigin = root.Position
    local rayDirection = lookVector * Settings.LookAheadDistance
    
    -- Создаем луч для обнаружения препятствий
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {char}
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult then
        local hit = raycastResult.Instance
        local distance = raycastResult.Distance
        
        -- Если препятствие близко
        if distance < 5 then
            -- Проверяем, можно ли перепрыгнуть
            local obstacleHeight = hit.Position.Y - root.Position.Y
            if obstacleHeight < 5 and humanoid:GetState() == Enum.HumanoidStateType.Running then
                humanoid.Jump = true
                if Settings.ShowDebug then
                    print("[AI] Прыжок через препятствие")
                end
            end
            return true
        end
    end
    
    return false
end

-- Построение пути к цели
local function BuildPathToTarget(targetPosition)
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentMaxSlope = 45,
        Costs = {
            Water = 10,
            Lava = math.huge,
            NonPathable = math.huge
        }
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(root.Position, targetPosition)
    end)
    
    if not success or path.Status ~= Enum.PathStatus.Success then
        return nil
    end
    
    return path
end

-- Движение к цели
local function MoveToTarget(targetPosition)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false end
    
    -- Устанавливаем скорость
    humanoid.WalkSpeed = Settings.MovementSpeed
    
    -- Строим путь
    local path = BuildPathToTarget(targetPosition)
    if not path then
        -- Если путь не построен, двигаемся напрямую
        humanoid:MoveTo(targetPosition)
        return true
    end
    
    -- Получаем точки пути
    local waypoints = path:GetWaypoints()
    if #waypoints == 0 then return false end
    
    -- Визуализация пути
    if Settings.ShowPath then
        for _, obj in pairs(DebugObjects) do
            obj:Destroy()
        end
        DebugObjects = {}
        
        for _, waypoint in ipairs(waypoints) do
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Position = waypoint.Position
            part.Anchored = true
            part.CanCollide = false
            part.BrickColor = BrickColor.new("Bright red")
            part.Material = Enum.Material.Neon
            part.Parent = workspace
            Debris:AddItem(part, 5)
            table.insert(DebugObjects, part)
        end
    end
    
    -- Двигаемся по точкам
    for i, waypoint in ipairs(waypoints) do
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        
        humanoid:MoveTo(waypoint.Position)
        humanoid.MoveToFinished:Wait(0.5)
        
        -- Проверяем, не умерла ли цель
        if not CurrentTarget or not CurrentTarget.Character or 
           not CurrentTarget.Character:FindFirstChild("Humanoid") or
           CurrentTarget.Character.Humanoid.Health <= 0 then
            return false
        end
    end
    
    return true
end

-- ============================================================
-- СИСТЕМА ПРИЦЕЛИВАНИЯ И СТРЕЛЬБЫ
-- ============================================================

-- Поворот камеры к цели
local function AimAtTarget(targetPart)
    if not targetPart then return false end
    
    local targetPosition = targetPart.Position
    local cameraPosition = Camera.CFrame.Position
    
    -- Плавный поворот камеры
    local newCFrame = CFrame.new(cameraPosition, targetPosition)
    local tweenInfo = TweenInfo.new(
        0.05 / Settings.CameraSensitivity,
        Enum.EasingStyle.Linear
    )
    
    local tween = TweenService:Create(Camera, tweenInfo, {CFrame = newCFrame})
    tween:Play()
    
    return true
end

-- Получение оружия
local function GetCurrentWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    
    local backpack = LocalPlayer.Backpack
    return backpack:FindFirstChildOfClass("Tool")
end

-- Выстрел
local function Shoot()
    local now = tick()
    if now - LastShootTime < Settings.ShootDelay then
        return false
    end
    
    local weapon = GetCurrentWeapon()
    if not weapon then return false end
    
    -- Поиск RemoteEvent для стрельбы
    local fireEvent = nil
    for _, child in ipairs(weapon:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local nameLower = child.Name:lower()
            if string.find(nameLower, "fire") or 
               string.find(nameLower, "shoot") or 
               string.find(nameLower, "bullet") then
                fireEvent = child
                break
            end
        end
    end
    
    if fireEvent then
        pcall(function()
            fireEvent:FireServer()
            LastShootTime = now
            if Settings.ShowDebug then
                print("[AI] Выстрел произведен")
            end
            return true
        end)
    end
    
    return false
end

-- Экипировка оружия
local function EquipWeapon()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    -- Проверяем, есть ли оружие в руках
    if char:FindFirstChildOfClass("Tool") then
        return true
    end
    
    -- Ищем оружие в инвентаре
    local backpack = LocalPlayer.Backpack
    local weapon = backpack:FindFirstChildOfClass("Tool")
    
    if weapon then
        humanoid:EquipTool(weapon)
        return true
    end
    
    return false
end

-- ============================================================
-- ОСНОВНАЯ AI ЛОГИКА
-- ============================================================

-- Обновление AI бота (вызывается каждый кадр)
local function UpdateAIBot()
    if not Settings.AIBotEnabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    -- Получаем ближайшего врага
    local nearestEnemy = GetNearestEnemy()
    
    if nearestEnemy then
        CurrentTarget = nearestEnemy
        local aimPart = GetAimPart(nearestEnemy.Character)
        
        -- Автоматическое прицеливание
        if Settings.AutoAim and aimPart then
            AimAtTarget(aimPart)
        end
        
        -- Проверяем дистанцию до врага
        local distanceToEnemy = (nearestEnemy.Root.Position - root.Position).Magnitude
        
        -- Если враг в зоне атаки
        if distanceToEnemy <= Settings.AttackRange then
            -- Останавливаем движение
            if IsMoving then
                humanoid:MoveTo(root.Position)
                IsMoving = false
            end
            
            -- Автоматическая стрельба
            if Settings.AutoShoot then
                EquipWeapon()
                Shoot()
            end
        else
            -- Двигаемся к врагу
            if Settings.AutoMove then
                if not IsMoving then
                    IsMoving = true
                end
                
                -- Двигаемся к врагу с обходом препятствий
                MoveToTarget(nearestEnemy.Root.Position)
                
                -- Проверяем препятствия перед собой
                if Settings.AutoJump then
                    CheckObstacleAhead()
                end
            end
        end
    else
        -- Если врагов нет, случайное патрулирование
        if Settings.AutoMove and not IsMoving then
            -- Случайная точка для патрулирования
            local randomPos = root.Position + Vector3.new(
                math.random(-Settings.DetectionRange, Settings.DetectionRange),
                0,
                math.random(-Settings.DetectionRange, Settings.DetectionRange)
            )
            humanoid:MoveTo(randomPos)
            IsMoving = true
        end
    end
end

-- ============================================================
-- ВИЗУАЛЬНЫЕ ЭФФЕКТЫ
-- ============================================================

-- Создание FOV круга
local function CreateFOVCircle()
    local radius = Settings.AttackRange
    local circle = Instance.new("Part")
    circle.Name = "FOVCircle"
    circle.Shape = Enum.PartType.Ball
    circle.Size = Vector3.new(radius * 2, 0.1, radius * 2)
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 0.8
    circle.BrickColor = BrickColor.new("Bright red")
    circle.Material = Enum.Material.Neon
    
    -- Привязываем к игроку
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = circle
    weld.Part1 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    weld.Parent = circle
    
    circle.Parent = workspace
    return circle
end

-- Создание индикатора цели
local function CreateTargetIndicator(target)
    if not target or not target.Character then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🎯 ЦЕЛЬ"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    
    billboard.Parent = workspace
    return billboard
end

-- ============================================================
-- ОБРАБОТКА СОБЫТИЙ
-- ============================================================

-- При появлении персонажа
local function OnCharacterAdded(character)
    -- Ждем загрузки
    task.wait(2)
    
    -- Настройка персонажа
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = Settings.MovementSpeed
    
    -- Создаем FOV круг
    local fovCircle = CreateFOVCircle()
    
    -- Очистка при смерти
    humanoid.Died:Connect(function()
        if fovCircle then fovCircle:Destroy() end
        IsMoving = false
        CurrentTarget = nil
    end)
end

-- Обработка клавиш
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Включение/выключение AI по клавише F1
    if input.KeyCode == Enum.KeyCode.F1 then
        Settings.AIBotEnabled = not Settings.AIBotEnabled
        print("[AI] AI Bot " .. (Settings.AIBotEnabled and "включен" or "выключен"))
    end
    
    -- Переключение режимов
    if input.KeyCode == Enum.KeyCode.F2 then
        Settings.AutoMove = not Settings.AutoMove
        print("[AI] Автоматическое движение: " .. (Settings.AutoMove and "вкл" or "выкл"))
    end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        Settings.AutoShoot = not Settings.AutoShoot
        print("[AI] Автоматическая стрельба: " .. (Settings.AutoShoot and "вкл" or "выкл"))
    end
end)

-- ============================================================
-- ОСНОВНОЙ ЦИКЛ
-- ============================================================

-- Запуск AI бота
local function StartAIBot()
    print("[AI] MEGA AI BOT v3.0 запущен!")
    print("[AI] Управление:")
    print("  F1 - Вкл/Выкл AI бота")
    print("  F2 - Вкл/Выкл движение")
    print("  F3 - Вкл/Выкл стрельбу")
    
    -- Подключаем событие появления персонажа
    LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
    
    -- Если персонаж уже есть
    if LocalPlayer.Character then
        OnCharacterAdded(LocalPlayer.Character)
    end
    
    -- Основной игровой цикл
    RunService.RenderStepped:Connect(function()
        UpdateAIBot()
        
        -- Обновление позиции FOV круга
        local fovCircle = workspace:FindFirstChild("FOVCircle")
        if fovCircle and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                fovCircle.Position = root.Position
            end
        end
    end)
end

-- Запуск бота
StartAIBot()
