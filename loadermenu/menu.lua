--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              MEGAHACK  v1  —  PREMIUM EDITION            ║
    ║    Glass · Neon · Gradients · Shimmer · Color Picker     ║
    ╚══════════════════════════════════════════════════════════╝
--]]

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")
local MarketplaceService= game:GetService("MarketplaceService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 5)
if not playerGui then warn("[MH] PlayerGui not found!") return end

local isMobile     = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local platformName = isMobile and "Mobile" or "PC"

-- ══════════════════════════════════════════════════════════════
--  SAFE LOAD
-- ══════════════════════════════════════════════════════════════
local function safeLoad(url)
    local ok, res = pcall(function() return loadstring(game:HttpGet(url, true))() end)
    if ok and res then return res end
    warn("[MH] failed to load: " .. tostring(url))
    return {}
end

-- ══════════════════════════════════════════════════════════════
--  HUB DATA
-- ══════════════════════════════════════════════════════════════
local HubData = {
    Brookhaven       = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/brookhaven"),
    Evade            = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/evade"),
    MM2              = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/MM2.lua"),
    MegaHack         = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/megapizda"),
    Hacks            = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Hacks.lua"),
    Admins           = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/admin"),
    Animations       = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/animation"),
    FE               = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FE.lua"),
    RagdollEngine    = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ragdoll"),
    NaturalDisaster  = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/NaturalDisaster.lua"),
    BloxFruit        = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BloxFruit.lua"),
    BladeBall        = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/BladeBall.lua"),
    StealBrainRoot   = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/StealBrainRoot.lua"),
    TowerOfHell      = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/tower.lua"),
    AdoptMe          = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/adoptme"),
    GrowGarden       = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/GrowGarden.lua"),
    Night            = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Night.lua"),
    Weird            = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Weird.lua"),
    DuelsMVS         = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/DuelsMVS.lua"),
    ViolenceDistrict = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/ViolenceDistrict.lua"),
    IKEA3008         = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/3008.lua"),
    Rivals           = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/Rivals.lua"),
    FORSAKEN         = safeLoad("https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/FORSAKEN.lua"),
}

-- ══════════════════════════════════════════════════════════════
--  COLOUR THEME
-- ══════════════════════════════════════════════════════════════
local T = {
    BgBase    = Color3.fromRGB(8,   8,  14),   -- очень тёмный базовый фон
    BgSide    = Color3.fromRGB(12,  12,  20),   -- сайдбар
    BgPanel   = Color3.fromRGB(16,  16,  28),   -- панели
    BgBtn     = Color3.fromRGB(22,  22,  36),   -- кнопки
    BgBtnHov  = Color3.fromRGB(30,  30,  50),
    BgGlass   = Color3.fromRGB(255,255, 255),   -- для эффекта стекла (с прозрачностью)
    Accent    = Color3.fromRGB(155,  28,  28),
    AccentHov = Color3.fromRGB(190,  42,  42),
    AccentGlow= Color3.fromRGB(220,  55,  55),
    Neon      = Color3.fromRGB(255,  60,  60),  -- неоновый блик
    NeonGlow  = Color3.fromRGB(255, 100, 100),  -- мягкое свечение
    TextMain  = Color3.fromRGB(230, 230, 240),
    TextSub   = Color3.fromRGB(140, 140, 160),
    TextMuted = Color3.fromRGB(80,   80, 100),
    Stroke    = Color3.fromRGB(50,   50,  75),
    StrokeBrt = Color3.fromRGB(80,   80, 120),
    Separator = Color3.fromRGB(30,   30,  48),
}

-- accent registry для updateGuiColors
local accentRegistry = {}
local function regA(obj, prop)
    table.insert(accentRegistry, { obj = obj, prop = prop or "BackgroundColor3" })
end

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function mkCorner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end

local function mkStroke(p, th, col, tr)
    local s = Instance.new("UIStroke"); s.Thickness = th or 1
    s.Color = col or T.Stroke; s.Transparency = tr or 0.5; s.Parent = p; return s
end

-- Градиент на фрейме
local function mkGradient(p, c0, c1, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rotation or 90
    g.Parent = p; return g
end

-- Эффект стекла: полупрозрачный белый слой поверх
local function mkGlass(parent, alpha)
    alpha = alpha or 0.88
    local g = Instance.new("Frame")
    g.Name = "GlassOverlay"
    g.Size = UDim2.new(1, 0, 1, 0)
    g.BackgroundColor3 = Color3.fromRGB(200, 200, 230)
    g.BackgroundTransparency = alpha
    g.BorderSizePixel = 0
    g.ZIndex = parent.ZIndex + 1
    g.Parent = parent
    mkCorner(g, 12)
    -- тонкий верхний световой блик
    local shine = Instance.new("Frame")
    shine.Size = UDim2.new(0.9, 0, 0, 1)
    shine.Position = UDim2.new(0.05, 0, 0, 2)
    shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.6
    shine.BorderSizePixel = 0
    shine.ZIndex = g.ZIndex + 1
    shine.Parent = parent
    mkCorner(shine, 1)
    return g
end

-- Неоновый контур (UIStroke с цветом свечения)
local function mkNeonStroke(p, color, thick)
    thick = thick or 1.5
    local s = Instance.new("UIStroke")
    s.Thickness = thick
    s.Color = color or T.Neon
    s.Transparency = 0.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

-- ══════════════════════════════════════════════════════════════
--  COUNT SCRIPTS
-- ══════════════════════════════════════════════════════════════
local function countScripts()
    local n = 0
    for _, cat in pairs(HubData) do
        if type(cat) == "table" then n = n + #cat end
    end
    return n
end

-- ══════════════════════════════════════════════════════════════
--  SETTINGS STATE
-- ══════════════════════════════════════════════════════════════
local rgbConnections       = {}
local colorPickerConnections = {}
local settings = {
    locked      = false,
    rgbAccent   = false,
    rgbStroke   = false,
    transparency = 0.08,
    colors = {
        bgColor     = T.BgBase,
        textColor   = T.TextMain,
        strokeColor = T.Stroke,
        accentColor = T.Accent,
    }
}

-- ══════════════════════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HackGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = false
screenGui.ResetOnSpawn = false

local function Hide_UI(gui)
    pcall(function()
        if get_hidden_gui then gui.Parent = get_hidden_gui()
        elseif gethui then gui.Parent = gethui()
        elseif syn and typeof(syn)=="table" and syn.protect_gui then
            syn.protect_gui(gui); gui.Parent = CoreGui
        elseif CoreGui:FindFirstChild("RobloxGui") then gui.Parent = CoreGui.RobloxGui
        else gui.Parent = CoreGui end
    end)
    if not gui.Parent then gui.Parent = CoreGui end
end
Hide_UI(screenGui)

-- ══════════════════════════════════════════════════════════════
--  NOTIFICATION  (с неон-баром и стеклом)
-- ══════════════════════════════════════════════════════════════
local function createNotification(title, subtitle, duration, iconId)
    local notGui = Instance.new("ScreenGui")
    notGui.Name = "MH_Notif"; notGui.Parent = playerGui; notGui.ResetOnSpawn = false
    local W, H = 250, 68

    local mf = Instance.new("Frame"); mf.Size = UDim2.new(0,W,0,H)
    mf.Position = UDim2.new(1, W+16, 0, 24)
    mf.BackgroundTransparency = 1; mf.Parent = notGui

    -- Основной тёмный фон
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = T.BgPanel; bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0; bg.Parent = mf; mkCorner(bg, 10)

    -- Градиент фона
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new(
        Color3.fromRGB(20, 18, 32), Color3.fromRGB(12, 10, 22)
    ); bgGrad.Rotation = 135; bgGrad.Parent = bg

    -- Стеклянный слой
    local glassLayer = Instance.new("Frame"); glassLayer.Size = UDim2.new(1,0,1,0)
    glassLayer.BackgroundColor3 = Color3.fromRGB(180,170,220)
    glassLayer.BackgroundTransparency = 1; glassLayer.BorderSizePixel = 0
    glassLayer.ZIndex = bg.ZIndex+1; glassLayer.Parent = mf; mkCorner(glassLayer, 10)

    local stk = Instance.new("UIStroke"); stk.Thickness = 1
    stk.Color = T.NeonGlow; stk.Transparency = 1; stk.Parent = bg

    -- Неоновый левый бар
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(0,3,1,-12)
    bar.Position = UDim2.new(0,0,0,6); bar.BackgroundColor3 = T.Neon
    bar.BackgroundTransparency = 1; bar.BorderSizePixel = 0; bar.Parent = mf; mkCorner(bar, 3)

    -- Свечение вокруг бара
    local barGlow = Instance.new("Frame"); barGlow.Size = UDim2.new(0,12,1,-8)
    barGlow.Position = UDim2.new(0,-4,0,4); barGlow.BackgroundColor3 = T.Neon
    barGlow.BackgroundTransparency = 1; barGlow.BorderSizePixel = 0; barGlow.Parent = mf
    mkCorner(barGlow, 6)
    local barGlowGrad = Instance.new("UIGradient")
    barGlowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.5,0.7), NumberSequenceKeypoint.new(1,1)
    }); barGlowGrad.Rotation = 0; barGlowGrad.Parent = barGlow

    local ic = Instance.new("ImageLabel"); ic.Size = UDim2.new(0,26,0,26)
    ic.Position = UDim2.new(0,14,0.5,-13); ic.BackgroundTransparency = 1
    ic.Image = "rbxassetid://"..tostring(iconId or 74283928898866)
    ic.ImageTransparency = 1; ic.ZIndex = bg.ZIndex+2; ic.Parent = mf

    local t1 = Instance.new("TextLabel"); t1.Text = title; t1.Font = Enum.Font.GothamBold
    t1.TextColor3 = T.TextMain; t1.TextSize = 13; t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.Size = UDim2.new(1,-52,0,18); t1.Position = UDim2.new(0,48,0,12)
    t1.BackgroundTransparency = 1; t1.TextTransparency = 1; t1.ZIndex = bg.ZIndex+2; t1.Parent = mf

    local t2 = Instance.new("TextLabel"); t2.Text = subtitle; t2.Font = Enum.Font.Gotham
    t2.TextColor3 = T.TextSub; t2.TextSize = 11; t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.Size = UDim2.new(1,-52,0,14); t2.Position = UDim2.new(0,48,0,32)
    t2.BackgroundTransparency = 1; t2.TextTransparency = 1; t2.ZIndex = bg.ZIndex+2; t2.Parent = mf

    local function fadeIn()
        local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(mf, ti, {Position = UDim2.new(1,-(W+16),0,24)}):Play()
        TweenService:Create(bg,        ti, {BackgroundTransparency = 0.08}):Play()
        TweenService:Create(glassLayer,ti, {BackgroundTransparency = 0.9}):Play()
        TweenService:Create(stk,       ti, {Transparency = 0.3}):Play()
        TweenService:Create(bar,       ti, {BackgroundTransparency = 0}):Play()
        TweenService:Create(barGlow,   ti, {BackgroundTransparency = 0.7}):Play()
        TweenService:Create(t1,        ti, {TextTransparency = 0}):Play()
        TweenService:Create(t2,        ti, {TextTransparency = 0.1}):Play()
        TweenService:Create(ic,        ti, {ImageTransparency = 0}):Play()
    end
    local function fadeOut()
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        TweenService:Create(mf,        ti, {Position = UDim2.new(1,W+16,0,24)}):Play()
        TweenService:Create(bg,        ti, {BackgroundTransparency = 1}):Play()
        TweenService:Create(glassLayer,ti, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stk,       ti, {Transparency = 1}):Play()
        TweenService:Create(bar,       ti, {BackgroundTransparency = 1}):Play()
        TweenService:Create(t1,        ti, {TextTransparency = 1}):Play()
        TweenService:Create(t2,        ti, {TextTransparency = 1}):Play()
        TweenService:Create(ic,        ti, {ImageTransparency = 1}):Play()
        task.delay(0.32, function() notGui:Destroy() end)
    end
    fadeIn(); task.delay(duration, fadeOut)
end

-- ══════════════════════════════════════════════════════════════
--  SAVE / LOAD COLOR SETTINGS
-- ══════════════════════════════════════════════════════════════
local function saveColorSettings()
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        local col = settings.colors
        writefile("MegaHack/colorSettings.json", HttpService:JSONEncode({
            bgColor     = {col.bgColor.R,     col.bgColor.G,     col.bgColor.B    },
            textColor   = {col.textColor.R,   col.textColor.G,   col.textColor.B  },
            strokeColor = {col.strokeColor.R, col.strokeColor.G, col.strokeColor.B},
            accentColor = {col.accentColor.R, col.accentColor.G, col.accentColor.B},
            transparency = settings.transparency,
            rgbAccent    = settings.rgbAccent,
            rgbStroke    = settings.rgbStroke,
        }))
    end)
end

local function loadColorSettings()
    pcall(function()
        if not isfile("MegaHack/colorSettings.json") then return end
        local d = HttpService:JSONDecode(readfile("MegaHack/colorSettings.json"))
        local function toC3(t) return t and Color3.new(t[1],t[2],t[3]) end
        if d.bgColor     then settings.colors.bgColor     = toC3(d.bgColor)     end
        if d.textColor   then settings.colors.textColor   = toC3(d.textColor)   end
        if d.strokeColor then settings.colors.strokeColor = toC3(d.strokeColor) end
        if d.accentColor then settings.colors.accentColor = toC3(d.accentColor) end
        if d.transparency~=nil then settings.transparency = d.transparency end
        if d.rgbAccent   ~=nil then settings.rgbAccent    = d.rgbAccent    end
        if d.rgbStroke   ~=nil then settings.rgbStroke    = d.rgbStroke    end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  MAIN FRAME  —  тёмное стекло с градиентом
-- ══════════════════════════════════════════════════════════════
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = T.BgBase
mainFrame.BackgroundTransparency = settings.transparency
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 580, 0, 390)
mainFrame.ZIndex = 2
mainFrame.Parent = screenGui
mkCorner(mainFrame, 14)

-- Диагональный градиент фона
local mainBgGrad = Instance.new("UIGradient")
mainBgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(14, 10, 24)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,  8, 18)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,   6, 16)),
})
mainBgGrad.Rotation = 135
mainBgGrad.Parent = mainFrame

-- Неоновый внешний контур
local mainNeonStroke = mkNeonStroke(mainFrame, T.Neon, 1.5)
mainNeonStroke.Transparency = 0.55

-- Стеклянный бликовый слой
local mainGlass = Instance.new("Frame")
mainGlass.Size = UDim2.new(1,0,1,0); mainGlass.BackgroundColor3 = Color3.fromRGB(200,190,255)
mainGlass.BackgroundTransparency = 0.96; mainGlass.BorderSizePixel = 0
mainGlass.ZIndex = 2; mainGlass.Parent = mainFrame; mkCorner(mainGlass, 14)

-- Верхний световой блик (горизонтальная линия)
local topShine = Instance.new("Frame")
topShine.Size = UDim2.new(0.7,0,0,1)
topShine.Position = UDim2.new(0.15,0,0,3)
topShine.BackgroundColor3 = Color3.fromRGB(255,255,255)
topShine.BackgroundTransparency = 0.55; topShine.BorderSizePixel = 0
topShine.ZIndex = 3; topShine.Parent = mainFrame; mkCorner(topShine, 1)
-- Fade на краях
local topShineGrad = Instance.new("UIGradient")
topShineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.15,0),
    NumberSequenceKeypoint.new(0.85,0), NumberSequenceKeypoint.new(1,1)
}); topShineGrad.Parent = topShine

-- ══════════════════════════════════════════════════════════════
--  HEADER  —  с градиентом и неоновой линией снизу
-- ══════════════════════════════════════════════════════════════
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.BackgroundColor3 = T.BgSide
headerFrame.BackgroundTransparency = 0.05
headerFrame.BorderSizePixel = 0
headerFrame.Size = UDim2.new(1,0,0,46)
headerFrame.ZIndex = 4; headerFrame.Parent = mainFrame; mkCorner(headerFrame, 14)

-- Градиент шапки
local hdrGrad = Instance.new("UIGradient")
hdrGrad.Color = ColorSequence.new(
    Color3.fromRGB(22,16,36), Color3.fromRGB(14,10,24)
); hdrGrad.Rotation = 90; hdrGrad.Parent = headerFrame

-- Патч нижних углов шапки
local headerPatch = Instance.new("Frame")
headerPatch.BackgroundColor3 = T.BgSide; headerPatch.BackgroundTransparency = 0.05
headerPatch.BorderSizePixel = 0; headerPatch.Size = UDim2.new(1,0,0,14)
headerPatch.Position = UDim2.new(0,0,1,-14); headerPatch.ZIndex = 4; headerPatch.Parent = headerFrame
local hdrPatchGrad = Instance.new("UIGradient")
hdrPatchGrad.Color = ColorSequence.new(Color3.fromRGB(22,16,36), Color3.fromRGB(14,10,24))
hdrPatchGrad.Rotation = 90; hdrPatchGrad.Parent = headerPatch

-- Неоновая линия-разделитель под шапкой
local headerNeonLine = Instance.new("Frame")
headerNeonLine.BackgroundColor3 = T.Neon; headerNeonLine.BackgroundTransparency = 0.4
headerNeonLine.BorderSizePixel = 0; headerNeonLine.Size = UDim2.new(1,0,0,1)
headerNeonLine.Position = UDim2.new(0,0,1,-1); headerNeonLine.ZIndex = 6; headerNeonLine.Parent = headerFrame
-- Светящееся размытие под линией (эффект неонового свечения)
local neonLineGlow = Instance.new("Frame")
neonLineGlow.BackgroundColor3 = T.Neon; neonLineGlow.BackgroundTransparency = 0.75
neonLineGlow.BorderSizePixel = 0; neonLineGlow.Size = UDim2.new(1,0,0,4)
neonLineGlow.Position = UDim2.new(0,0,1,-2); neonLineGlow.ZIndex = 5; neonLineGlow.Parent = headerFrame
local neonLineGrad = Instance.new("UIGradient")
neonLineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.1,0),
    NumberSequenceKeypoint.new(0.9,0), NumberSequenceKeypoint.new(1,1)
}); neonLineGrad.Parent = neonLineGlow

-- Стеклянный блик на шапке
local hdrGlass = Instance.new("Frame"); hdrGlass.Size = UDim2.new(1,0,0.5,0)
hdrGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); hdrGlass.BackgroundTransparency = 0.94
hdrGlass.BorderSizePixel = 0; hdrGlass.ZIndex = 5; hdrGlass.Parent = headerFrame; mkCorner(hdrGlass, 14)

-- Акцент-пилюля слева
local headerAccent = Instance.new("Frame")
headerAccent.BackgroundColor3 = T.Neon; headerAccent.BackgroundTransparency = 0
headerAccent.BorderSizePixel = 0; headerAccent.Size = UDim2.new(0,4,0,26)
headerAccent.Position = UDim2.new(0,14,0.5,-13); headerAccent.ZIndex = 7; headerAccent.Parent = headerFrame
mkCorner(headerAccent, 3); regA(headerAccent)
-- Неоновое свечение вокруг пилюли
local accentGlow = Instance.new("Frame"); accentGlow.BackgroundColor3 = T.Neon
accentGlow.BackgroundTransparency = 0.7; accentGlow.BorderSizePixel = 0
accentGlow.Size = UDim2.new(0,14,0,32); accentGlow.Position = UDim2.new(0,8,0.5,-16)
accentGlow.ZIndex = 6; accentGlow.Parent = headerFrame; mkCorner(accentGlow, 7)
local accentGlowGrad = Instance.new("UIGradient")
accentGlowGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.5,0.5), NumberSequenceKeypoint.new(1,1)
}); accentGlowGrad.Parent = accentGlow; regA(accentGlow)

local logoIcon = Instance.new("ImageLabel"); logoIcon.BackgroundTransparency = 1
logoIcon.Image = "rbxassetid://7072717762"; logoIcon.Size = UDim2.new(0,22,0,22)
logoIcon.Position = UDim2.new(0,24,0.5,-11); logoIcon.ZIndex = 7; logoIcon.Parent = headerFrame

local titleLabel = Instance.new("TextLabel"); titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MEGAHACK"; titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 17
titleLabel.TextColor3 = T.TextMain; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Size = UDim2.new(0,130,0,24); titleLabel.Position = UDim2.new(0,52,0.5,-12)
titleLabel.ZIndex = 7; titleLabel.Parent = headerFrame; titleLabel:SetAttribute("TextRole","main")

-- Версионный бейдж с градиентом
local vBadge = Instance.new("Frame"); vBadge.BackgroundColor3 = T.Accent
vBadge.BackgroundTransparency = 0; vBadge.BorderSizePixel = 0
vBadge.Size = UDim2.new(0,38,0,17); vBadge.Position = UDim2.new(0,184,0.5,-8)
vBadge.ZIndex = 7; vBadge.Parent = headerFrame; mkCorner(vBadge, 5); regA(vBadge)
local vBadgeGrad = Instance.new("UIGradient")
vBadgeGrad.Color = ColorSequence.new(T.AccentGlow, T.Accent); vBadgeGrad.Rotation = 135
vBadgeGrad.Parent = vBadge
local vBadgeTxt = Instance.new("TextLabel"); vBadgeTxt.BackgroundTransparency = 1
vBadgeTxt.Text = "v1.0"; vBadgeTxt.Font = Enum.Font.GothamBold; vBadgeTxt.TextSize = 10
vBadgeTxt.TextColor3 = Color3.fromRGB(255,220,220); vBadgeTxt.Size = UDim2.new(1,0,1,0)
vBadgeTxt.ZIndex = 8; vBadgeTxt.Parent = vBadge; vBadgeTxt:SetAttribute("TextRole","main")

local ok_g, gname = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
local scriptCountLabel = Instance.new("TextLabel"); scriptCountLabel.BackgroundTransparency = 1
scriptCountLabel.Text = countScripts() .. " scripts"; scriptCountLabel.Font = Enum.Font.Gotham
scriptCountLabel.TextSize = 11; scriptCountLabel.TextColor3 = T.TextSub
scriptCountLabel.TextXAlignment = Enum.TextXAlignment.Right
scriptCountLabel.Size = UDim2.new(0,110,0,20); scriptCountLabel.Position = UDim2.new(1,-158,0.5,-10)
scriptCountLabel.ZIndex = 7; scriptCountLabel.Parent = headerFrame

local gameNameHeader = Instance.new("TextLabel"); gameNameHeader.BackgroundTransparency = 1
gameNameHeader.Text = ok_g and gname or "Unknown Game"
gameNameHeader.Font = Enum.Font.Gotham; gameNameHeader.TextSize = 10
gameNameHeader.TextColor3 = T.TextMuted; gameNameHeader.TextXAlignment = Enum.TextXAlignment.Right
gameNameHeader.Size = UDim2.new(0,150,0,14); gameNameHeader.Position = UDim2.new(1,-196,0.5,5)
gameNameHeader.ZIndex = 7; gameNameHeader.Parent = headerFrame

-- Кнопка закрытия с неоном
local closeBtn = Instance.new("TextButton"); closeBtn.BackgroundColor3 = Color3.fromRGB(140,30,30)
closeBtn.BackgroundTransparency = 0.3; closeBtn.BorderSizePixel = 0
closeBtn.Size = UDim2.new(0,26,0,26); closeBtn.Position = UDim2.new(1,-38,0.5,-13)
closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.fromRGB(255,200,200); closeBtn.TextSize = 19
closeBtn.Font = Enum.Font.GothamBold; closeBtn.ZIndex = 9; closeBtn.Parent = headerFrame
mkCorner(closeBtn, 7); mkNeonStroke(closeBtn, Color3.fromRGB(255,80,80), 1)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn,TweenInfo.new(0.14),{BackgroundTransparency=0, BackgroundColor3=T.Neon}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn,TweenInfo.new(0.14),{BackgroundTransparency=0.3, BackgroundColor3=Color3.fromRGB(140,30,30)}):Play()
end)

-- ══════════════════════════════════════════════════════════════
--  SIDEBAR  —  тёмное стекло с левым неоновым краем
-- ══════════════════════════════════════════════════════════════
local sidebarFrame = Instance.new("Frame"); sidebarFrame.Name = "Sidebar"
sidebarFrame.BackgroundColor3 = T.BgSide; sidebarFrame.BackgroundTransparency = 0.05
sidebarFrame.BorderSizePixel = 0; sidebarFrame.Size = UDim2.new(0,132,1,-46)
sidebarFrame.Position = UDim2.new(0,0,0,46); sidebarFrame.ZIndex = 3; sidebarFrame.Parent = mainFrame

-- Градиент сайдбара
local sideGrad = Instance.new("UIGradient")
sideGrad.Color = ColorSequence.new(Color3.fromRGB(20,15,34), Color3.fromRGB(10,8,20))
sideGrad.Rotation = 180; sideGrad.Parent = sidebarFrame

mkCorner(sidebarFrame, 14)

-- патчи
local sPatchTop = Instance.new("Frame"); sPatchTop.BackgroundColor3 = T.BgSide
sPatchTop.BackgroundTransparency = 0.05; sPatchTop.BorderSizePixel = 0
sPatchTop.Size = UDim2.new(1,0,0,14); sPatchTop.ZIndex = 3; sPatchTop.Parent = sidebarFrame
local sPatchTopGrad = Instance.new("UIGradient")
sPatchTopGrad.Color = ColorSequence.new(Color3.fromRGB(20,15,34), Color3.fromRGB(10,8,20))
sPatchTopGrad.Rotation = 180; sPatchTopGrad.Parent = sPatchTop

local sPatchRight = Instance.new("Frame"); sPatchRight.BackgroundColor3 = T.BgSide
sPatchRight.BackgroundTransparency = 0.05; sPatchRight.BorderSizePixel = 0
sPatchRight.Size = UDim2.new(0,14,1,0); sPatchRight.Position = UDim2.new(1,-14,0,0)
sPatchRight.ZIndex = 3; sPatchRight.Parent = sidebarFrame

-- Неоновый вертикальный правый бордер сайдбара
local sideBorderGlow = Instance.new("Frame"); sideBorderGlow.BackgroundColor3 = T.Neon
sideBorderGlow.BackgroundTransparency = 0.7; sideBorderGlow.BorderSizePixel = 0
sideBorderGlow.Size = UDim2.new(0,6,1,-46); sideBorderGlow.Position = UDim2.new(0,128,0,46)
sideBorderGlow.ZIndex = 4; sideBorderGlow.Parent = mainFrame; mkCorner(sideBorderGlow, 3)
local sideBorderGrad = Instance.new("UIGradient")
sideBorderGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.15,0.4),
    NumberSequenceKeypoint.new(0.85,0.4), NumberSequenceKeypoint.new(1,1)
}); sideBorderGrad.Rotation = 90; sideBorderGrad.Parent = sideBorderGlow; regA(sideBorderGlow)

-- Тонкая неоновая линия разделителя
local sideSep = Instance.new("Frame"); sideSep.BackgroundColor3 = T.Neon
sideSep.BackgroundTransparency = 0.6; sideSep.BorderSizePixel = 0
sideSep.Size = UDim2.new(0,1,1,-46); sideSep.Position = UDim2.new(0,132,0,46)
sideSep.ZIndex = 4; sideSep.Parent = mainFrame; regA(sideSep)

-- Стеклянный слой сайдбара
local sideGlass = Instance.new("Frame"); sideGlass.Size = UDim2.new(1,0,0.4,0)
sideGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); sideGlass.BackgroundTransparency = 0.96
sideGlass.BorderSizePixel = 0; sideGlass.ZIndex = 4; sideGlass.Parent = sidebarFrame

local catScroll = Instance.new("ScrollingFrame"); catScroll.BackgroundTransparency = 1
catScroll.BorderSizePixel = 0; catScroll.Size = UDim2.new(1,0,1,-10)
catScroll.Position = UDim2.new(0,0,0,10); catScroll.CanvasSize = UDim2.new(0,0,0,0)
catScroll.ScrollBarThickness = 2; catScroll.ScrollBarImageColor3 = T.Neon
catScroll.ZIndex = 5; catScroll.Parent = sidebarFrame; regA(catScroll,"ScrollBarImageColor3")
local catLayout = Instance.new("UIListLayout"); catLayout.Padding = UDim.new(0,2)
catLayout.SortOrder = Enum.SortOrder.LayoutOrder; catLayout.Parent = catScroll
local catPad = Instance.new("UIPadding"); catPad.PaddingLeft = UDim.new(0,6)
catPad.PaddingRight = UDim.new(0,6); catPad.Parent = catScroll
catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    catScroll.CanvasSize = UDim2.new(0,0,0,catLayout.AbsoluteContentSize.Y+10)
end)

-- ══════════════════════════════════════════════════════════════
--  CONTENT PANEL
-- ══════════════════════════════════════════════════════════════
local contentFrame = Instance.new("Frame"); contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0; contentFrame.Size = UDim2.new(1,-133,1,-50)
contentFrame.Position = UDim2.new(0,133,0,50); contentFrame.ZIndex = 3; contentFrame.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame"); scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0; scrollingFrame.Size = UDim2.new(1,-4,1,0)
scrollingFrame.CanvasSize = UDim2.new(0,0,0,0); scrollingFrame.ScrollBarThickness = 3
scrollingFrame.ScrollBarImageColor3 = T.Neon; scrollingFrame.ZIndex = 3; scrollingFrame.Parent = contentFrame
regA(scrollingFrame,"ScrollBarImageColor3")
local scrollLayout = Instance.new("UIListLayout"); scrollLayout.Padding = UDim.new(0,5)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder; scrollLayout.Parent = scrollingFrame
local scrollPad = Instance.new("UIPadding"); scrollPad.PaddingLeft = UDim.new(0,8)
scrollPad.PaddingRight = UDim.new(0,8); scrollPad.PaddingTop = UDim.new(0,6); scrollPad.Parent = scrollingFrame
scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0,0,0,scrollLayout.AbsoluteContentSize.Y+16)
end)

-- ══════════════════════════════════════════════════════════════
--  REOPEN BUTTON  —  неоновое кольцо
-- ══════════════════════════════════════════════════════════════
local reopenButton = Instance.new("ImageButton"); reopenButton.Size = UDim2.new(0,48,0,48)
reopenButton.Position = UDim2.new(0.5,-24,0.9,-24)
reopenButton.BackgroundColor3 = T.BgPanel; reopenButton.BackgroundTransparency = 0.1
reopenButton.Image = "rbxassetid://74283928898866"; reopenButton.ImageTransparency = 0.1
reopenButton.Visible = false; reopenButton.ZIndex = 10; reopenButton.Parent = screenGui
mkCorner(reopenButton, 24)
local reopenNeon = mkNeonStroke(reopenButton, T.Neon, 1.5); regA(reopenNeon,"Color")
reopenButton.MouseEnter:Connect(function()
    TweenService:Create(reopenButton,TweenInfo.new(0.18),{BackgroundColor3=T.Neon,BackgroundTransparency=0}):Play()
end)
reopenButton.MouseLeave:Connect(function()
    TweenService:Create(reopenButton,TweenInfo.new(0.18),{BackgroundColor3=T.BgPanel,BackgroundTransparency=0.1}):Play()
end)

-- ══════════════════════════════════════════════════════════════
--  SHIMMER ANIMATION  —  проходящий блик по элементам
-- ══════════════════════════════════════════════════════════════
local function addShimmer(frame, interval)
    interval = interval or 4
    local shimmer = Instance.new("Frame")
    shimmer.Size = UDim2.new(0,40,1,0)
    shimmer.Position = UDim2.new(-0.2,0,0,0)
    shimmer.BackgroundColor3 = Color3.fromRGB(255,255,255)
    shimmer.BackgroundTransparency = 1
    shimmer.BorderSizePixel = 0
    shimmer.ZIndex = frame.ZIndex + 10
    shimmer.ClipsDescendants = false
    shimmer.Parent = frame
    mkCorner(shimmer, 4)
    local sg = Instance.new("UIGradient")
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),
        NumberSequenceKeypoint.new(0.5,0.65),
        NumberSequenceKeypoint.new(1,1),
    })
    sg.Rotation = 15; sg.Parent = shimmer
    task.spawn(function()
        task.wait(math.random()*interval)
        while shimmer and shimmer.Parent do
            TweenService:Create(shimmer, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
                Position = UDim2.new(1.2,0,0,0), BackgroundTransparency = 0.75
            }):Play()
            task.wait(0.7)
            shimmer.Position = UDim2.new(-0.2,0,0,0)
            shimmer.BackgroundTransparency = 1
            task.wait(interval + math.random()*2)
        end
    end)
    return shimmer
end

-- Шиммер на шапке
addShimmer(headerFrame, 5)

-- ══════════════════════════════════════════════════════════════
--  ПУЛЬСИРУЮЩЕЕ НЕОНОВОЕ СВЕЧЕНИЕ вокруг mainFrame
-- ══════════════════════════════════════════════════════════════
task.spawn(function()
    while mainFrame and mainFrame.Parent do
        TweenService:Create(mainNeonStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.2
        }):Play()
        task.wait(1.8)
        TweenService:Create(mainNeonStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.7
        }):Play()
        task.wait(1.8)
    end
end)

-- ══════════════════════════════════════════════════════════════
--  UPDATE GUI COLORS  —  с обновлением акцента/неона
-- ══════════════════════════════════════════════════════════════
local function clearRgbConnections()
    for _, c in pairs(rgbConnections) do c:Disconnect() end; rgbConnections = {}
end

local function updateGuiColors()
    clearRgbConnections()

    local acc = settings.colors.accentColor
    local bg  = settings.colors.bgColor
    local tx  = settings.colors.textColor

    T.Accent     = acc
    T.AccentHov  = Color3.new(math.min(acc.R*1.22,1), math.min(acc.G*1.22,1), math.min(acc.B*1.22,1))
    T.AccentGlow = Color3.new(math.min(acc.R*1.4,1),  math.min(acc.G*1.4,1),  math.min(acc.B*1.4,1))
    T.Neon       = Color3.new(math.min(acc.R*1.6,1),  math.min(acc.G*1.6,1),  math.min(acc.B*1.6,1))
    T.NeonGlow   = Color3.new(math.min(acc.R*1.8,1),  math.min(acc.G*1.8,1),  math.min(acc.B*1.8,1))
    T.BgBase     = bg
    T.BgSide     = Color3.new(math.min(bg.R+0.02,1),  math.min(bg.G+0.02,1),  math.min(bg.B+0.03,1))
    T.BgPanel    = Color3.new(math.min(bg.R+0.04,1),  math.min(bg.G+0.04,1),  math.min(bg.B+0.06,1))
    T.BgBtn      = Color3.new(math.min(bg.R+0.07,1),  math.min(bg.G+0.07,1),  math.min(bg.B+0.10,1))
    T.BgBtnHov   = Color3.new(math.min(bg.R+0.10,1),  math.min(bg.G+0.10,1),  math.min(bg.B+0.14,1))
    T.TextMain   = tx

    -- Accent registry
    for _, e in ipairs(accentRegistry) do
        if e.obj and e.obj.Parent then e.obj[e.prop] = T.Neon end
    end

    -- Структурные фреймы
    mainFrame.BackgroundColor3       = bg
    mainFrame.BackgroundTransparency = settings.transparency
    mainNeonStroke.Color             = T.Neon
    headerFrame.BackgroundColor3     = T.BgSide
    headerPatch.BackgroundColor3     = T.BgSide
    sidebarFrame.BackgroundColor3    = T.BgSide
    sPatchTop.BackgroundColor3       = T.BgSide
    sPatchRight.BackgroundColor3     = T.BgSide
    headerNeonLine.BackgroundColor3  = T.Neon
    neonLineGlow.BackgroundColor3    = T.Neon

    -- Неоновые разделители
    sideBorderGlow.BackgroundColor3  = T.Neon
    sideSep.BackgroundColor3         = T.Neon

    -- Цвет градиентов (обновляем через Color3 напрямую не получится, но stroke и фоны обновились)

    -- Потомки
    for _, obj in pairs(mainFrame:GetDescendants()) do
        if obj:IsA("UIStroke") then
            if settings.rgbStroke then
                local c; c = RunService.Heartbeat:Connect(function()
                    if not obj:IsDescendantOf(mainFrame) then c:Disconnect() return end
                    obj.Color = Color3.fromHSV((tick()%5)/5, 1, 1)
                end); table.insert(rgbConnections, c)
            else
                obj.Color = settings.colors.strokeColor
            end
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            if settings.rgbAccent then
                local c; c = RunService.Heartbeat:Connect(function()
                    if not obj:IsDescendantOf(mainFrame) then c:Disconnect() return end
                    obj.TextColor3 = Color3.fromHSV((tick()%5)/5, 1, 1)
                end); table.insert(rgbConnections, c)
            else
                if obj:GetAttribute("TextRole") == "main" then obj.TextColor3 = tx end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════
--  SECTION HEADER  —  с неоновым пипом и градиентной линией
-- ══════════════════════════════════════════════════════════════
local function createSectionHeader(text, parent)
    local c = Instance.new("Frame"); c.BackgroundTransparency = 1
    c.Size = UDim2.new(1,0,0,24); c.ZIndex = 3; c.Parent = parent

    -- Разделительная линия с градиентом
    local ln = Instance.new("Frame"); ln.BackgroundColor3 = T.Neon
    ln.BackgroundTransparency = 0.6; ln.BorderSizePixel = 0
    ln.Size = UDim2.new(1,0,0,1); ln.Position = UDim2.new(0,0,1,-1)
    ln.ZIndex = 3; ln.Parent = c; regA(ln)
    local lnGrad = Instance.new("UIGradient")
    lnGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.05,0),
        NumberSequenceKeypoint.new(0.7,0), NumberSequenceKeypoint.new(1,1)
    }); lnGrad.Parent = ln

    -- Неоновый пип с свечением
    local pipGlow = Instance.new("Frame"); pipGlow.BackgroundColor3 = T.Neon
    pipGlow.BackgroundTransparency = 0.6; pipGlow.BorderSizePixel = 0
    pipGlow.Size = UDim2.new(0,9,0,16); pipGlow.Position = UDim2.new(0,-2,0.5,-8)
    pipGlow.ZIndex = 3; pipGlow.Parent = c; mkCorner(pipGlow, 5); regA(pipGlow)

    local pip = Instance.new("Frame"); pip.BackgroundColor3 = T.Neon
    pip.BackgroundTransparency = 0; pip.BorderSizePixel = 0
    pip.Size = UDim2.new(0,3,0,14); pip.Position = UDim2.new(0,0,0.5,-7)
    pip.ZIndex = 4; pip.Parent = c; mkCorner(pip, 2); regA(pip)

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
    lbl.TextColor3 = T.TextSub; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Size = UDim2.new(1,-12,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.ZIndex = 4; lbl.Parent = c
    return c
end

-- ══════════════════════════════════════════════════════════════
--  CREATE BUTTON  —  стеклянный с неоновым ховером
-- ══════════════════════════════════════════════════════════════
local currentActiveSideBtn = nil

local function createButton(text, parent, callback, isCategoryButton)
    if isCategoryButton then
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,0,30)
        btn.BackgroundColor3 = T.BgBtn; btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0; btn.Text = text; btn.TextColor3 = T.TextSub
        btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham; btn.ZIndex = 6; btn.Parent = parent; mkCorner(btn, 6)
        local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0,10); pad.Parent = btn

        local ind = Instance.new("Frame"); ind.BackgroundColor3 = T.Neon
        ind.BackgroundTransparency = 1; ind.BorderSizePixel = 0
        ind.Size = UDim2.new(0,3,0,16); ind.Position = UDim2.new(0,-6,0.5,-8)
        ind.ZIndex = 7; ind.Parent = btn; mkCorner(ind, 2); regA(ind)

        -- Свечение индикатора
        local indGlow = Instance.new("Frame"); indGlow.BackgroundColor3 = T.Neon
        indGlow.BackgroundTransparency = 1; indGlow.BorderSizePixel = 0
        indGlow.Size = UDim2.new(0,12,0,22); indGlow.Position = UDim2.new(0,-8,0.5,-11)
        indGlow.ZIndex = 6; indGlow.Parent = btn; mkCorner(indGlow, 6); regA(indGlow)

        btn.MouseEnter:Connect(function()
            if btn:GetAttribute("Active") then return end
            TweenService:Create(btn,TweenInfo.new(0.16),{BackgroundTransparency=0.6,TextColor3=T.TextMain}):Play()
        end)
        btn.MouseLeave:Connect(function()
            if btn:GetAttribute("Active") then return end
            TweenService:Create(btn,TweenInfo.new(0.16),{BackgroundTransparency=1,TextColor3=T.TextSub}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            if currentActiveSideBtn and currentActiveSideBtn ~= btn then
                currentActiveSideBtn:SetAttribute("Active", false)
                TweenService:Create(currentActiveSideBtn,TweenInfo.new(0.16),{
                    BackgroundColor3=T.BgBtn,BackgroundTransparency=1,TextColor3=T.TextSub}):Play()
                local pi  = currentActiveSideBtn:FindFirstChild("Frame")
                local pi2 = pi and pi:FindFirstChild("Frame")
                if pi  then TweenService:Create(pi, TweenInfo.new(0.16),{BackgroundTransparency=1}):Play() end
                if pi2 then TweenService:Create(pi2,TweenInfo.new(0.16),{BackgroundTransparency=1}):Play() end
            end
            btn:SetAttribute("Active",true); currentActiveSideBtn = btn
            TweenService:Create(btn,TweenInfo.new(0.16),{
                BackgroundColor3=T.Neon,BackgroundTransparency=0.75,TextColor3=T.TextMain}):Play()
            TweenService:Create(ind,TweenInfo.new(0.16),{BackgroundTransparency=0}):Play()
            TweenService:Create(indGlow,TweenInfo.new(0.16),{BackgroundTransparency=0.7}):Play()
            callback()
        end)
        return btn
    else
        -- Стеклянная кнопка контент-панели
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,0,34)
        btn.BackgroundColor3 = T.BgBtn; btn.BackgroundTransparency = 0.25
        btn.BorderSizePixel = 0; btn.Text = text; btn.TextColor3 = T.TextMain
        btn.TextTransparency = 0.05; btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.ZIndex = 4; btn.Parent = parent
        btn:SetAttribute("TextRole","main"); mkCorner(btn, 8)

        -- Стеклянный блик на кнопке
        local btnGlass = Instance.new("Frame"); btnGlass.Size = UDim2.new(1,0,0.5,0)
        btnGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); btnGlass.BackgroundTransparency = 0.94
        btnGlass.BorderSizePixel = 0; btnGlass.ZIndex = btn.ZIndex+1; btnGlass.Parent = btn; mkCorner(btnGlass, 8)

        -- Неоновый stroke (невидим пока не наведёте)
        local btnStroke = mkStroke(btn, 1, T.Stroke, 0.45)

        -- Акцентная левая линия
        local acLine = Instance.new("Frame"); acLine.BackgroundColor3 = T.Neon
        acLine.BackgroundTransparency = 1; acLine.BorderSizePixel = 0
        acLine.Size = UDim2.new(0,2,0,18); acLine.Position = UDim2.new(0,7,0.5,-9)
        acLine.ZIndex = 5; acLine.Parent = btn; mkCorner(acLine, 2); regA(acLine)

        -- Свечение акц. линии
        local acGlow = Instance.new("Frame"); acGlow.BackgroundColor3 = T.Neon
        acGlow.BackgroundTransparency = 1; acGlow.BorderSizePixel = 0
        acGlow.Size = UDim2.new(0,10,0,22); acGlow.Position = UDim2.new(0,4,0.5,-11)
        acGlow.ZIndex = 4; acGlow.Parent = btn; mkCorner(acGlow, 5); regA(acGlow)

        local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0,15); pad.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn,    TweenInfo.new(0.14),{BackgroundTransparency=0.08}):Play()
            TweenService:Create(btnStroke,TweenInfo.new(0.14),{Color=T.Neon,Transparency=0.25}):Play()
            TweenService:Create(acLine, TweenInfo.new(0.14),{BackgroundTransparency=0}):Play()
            TweenService:Create(acGlow, TweenInfo.new(0.14),{BackgroundTransparency=0.7}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn,    TweenInfo.new(0.14),{BackgroundTransparency=0.25}):Play()
            TweenService:Create(btnStroke,TweenInfo.new(0.14),{Color=T.Stroke,Transparency=0.45}):Play()
            TweenService:Create(acLine, TweenInfo.new(0.14),{BackgroundTransparency=1}):Play()
            TweenService:Create(acGlow, TweenInfo.new(0.14),{BackgroundTransparency=1}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=T.Neon,BackgroundTransparency=0.55}):Play()
            task.delay(0.12,function()
                TweenService:Create(btn,TweenInfo.new(0.14),{BackgroundColor3=T.BgBtn,BackgroundTransparency=0.08}):Play()
            end)
            callback()
        end)
        return btn
    end
end

-- ══════════════════════════════════════════════════════════════
--  CREATE LABEL
-- ══════════════════════════════════════════════════════════════
local function createLabel(text, parent, size, position)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1
    l.Text = text; l.Font = Enum.Font.Gotham; l.TextSize = 13
    l.TextColor3 = T.TextMain; l.TextTransparency = 0.1
    l.TextXAlignment = Enum.TextXAlignment.Left; l.TextWrapped = true
    l.Size = size or UDim2.new(1,0,0,24); l.Position = position or UDim2.new(0,0,0,0)
    l.ZIndex = 4; l.Parent = parent; l:SetAttribute("TextRole","main")
    return l
end

-- ══════════════════════════════════════════════════════════════
--  CLEAR CONTENT
-- ══════════════════════════════════════════════════════════════
local function clearContent()
    for _, c in pairs(colorPickerConnections) do pcall(function() c:Disconnect() end) end
    colorPickerConnections = {}
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
    end
end

-- ══════════════════════════════════════════════════════════════
--  LOAD CATEGORY
-- ══════════════════════════════════════════════════════════════
local function loadHacksFromCategory(catName)
    clearContent()
    local data = HubData[catName]
    if not data or #data == 0 then
        createSectionHeader("Empty / Failed", scrollingFrame)
        createLabel("⚠  No scripts loaded: " .. catName, scrollingFrame)
        return
    end
    createSectionHeader(catName, scrollingFrame)
    for _, hack in ipairs(data) do
        if type(hack)=="table" and type(hack[1])=="string" and type(hack[2])=="function" then
            createButton(hack[1], scrollingFrame, function()
                local s, e = pcall(hack[2])
                if not s then createNotification("ERROR",tostring(e):sub(1,60),5,7733968497) end
            end)
        end
    end
end

-- ══════════════════════════════════════════════════════════════
--  SEARCH
-- ══════════════════════════════════════════════════════════════
local function searchScriptsByMegahack(q)
    local r = {}
    for catName, hacks in pairs(HubData) do
        if type(hacks)=="table" then
            for _, hack in ipairs(hacks) do
                if type(hack)=="table" and type(hack[1])=="string"
                   and string.find(string.lower(hack[1]), string.lower(q)) then
                    table.insert(r,{name=hack[1],category=catName,func=hack[2]})
                end
            end
        end
    end
    return r
end

local function showAllScripts()
    clearContent()
    createSectionHeader("Search Scripts", scrollingFrame)

    local sb = Instance.new("TextBox"); sb.Size = UDim2.new(1,0,0,34)
    sb.BackgroundColor3 = T.BgBtn; sb.BackgroundTransparency = 0.2
    sb.TextColor3 = T.TextMain; sb.PlaceholderText = "🔍  Search scripts..."
    sb.PlaceholderColor3 = T.TextMuted; sb.TextSize = 13; sb.Text = ""
    sb.Font = Enum.Font.Gotham; sb.ClearTextOnFocus = false; sb.ZIndex = 4; sb.Parent = scrollingFrame
    sb:SetAttribute("TextRole","main"); mkCorner(sb, 8); mkNeonStroke(sb, T.Neon, 1)
    local sbGlass = Instance.new("Frame"); sbGlass.Size = UDim2.new(1,0,0.5,0)
    sbGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); sbGlass.BackgroundTransparency = 0.94
    sbGlass.BorderSizePixel = 0; sbGlass.ZIndex = 5; sbGlass.Parent = sb; mkCorner(sbGlass, 8)
    local sbPad = Instance.new("UIPadding"); sbPad.PaddingLeft = UDim.new(0,12); sbPad.Parent = sb

    local resLbl = createLabel("Enter 3+ characters...", scrollingFrame); resLbl.TextColor3 = T.TextSub

    local function doSearch(q)
        for _, c in ipairs(scrollingFrame:GetChildren()) do
            if c~=sb and c~=resLbl and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
        end
        if #q < 3 then resLbl.Text = "Enter 3+ characters..."; return end
        resLbl.Text = "Searching..."
        local found = 0
        for _, r in ipairs(searchScriptsByMegahack(q)) do
            createButton(r.name.."  ["..r.category.."]", scrollingFrame, function()
                local s,e = pcall(r.func)
                if not s then createNotification("ERROR",tostring(e):sub(1,60),5,7733968497) end
            end)
            found = found + 1
        end
        pcall(function()
            local resp = HttpService:GetAsync("https://scriptblox.com/api/script/search?q="..HttpService:UrlEncode(q))
            local data = HttpService:JSONDecode(resp)
            if data and data.result and data.result.scripts then
                for _, sc in ipairs(data.result.scripts) do
                    createButton(sc.title.."  [ScriptBlox]", scrollingFrame, function()
                        createNotification("ScriptBlox","ID: "..sc._id,5)
                    end)
                    found = found + 1
                end
            end
        end)
        resLbl.Text = found .. " results"
    end
    sb:GetPropertyChangedSignal("Text"):Connect(function()
        if #sb.Text >= 3 then task.delay(0.5, function() doSearch(sb.Text) end)
        elseif #sb.Text == 0 then doSearch("") end
    end)
    sb.FocusLost:Connect(function() doSearch(sb.Text) end)
end

-- ══════════════════════════════════════════════════════════════
--  SHOW HOME
-- ══════════════════════════════════════════════════════════════
local function showHome()
    clearContent()
    createSectionHeader("Overview", scrollingFrame)

    -- Карточка игрока — стеклянная панель
    local card = Instance.new("Frame"); card.Size = UDim2.new(1,0,0,96)
    card.BackgroundColor3 = T.BgPanel; card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0; card.ZIndex = 4; card.Parent = scrollingFrame; mkCorner(card, 10)
    -- Градиент карточки
    local cardGrad = Instance.new("UIGradient")
    cardGrad.Color = ColorSequence.new(
        Color3.fromRGB(26,20,44), Color3.fromRGB(14,12,28)
    ); cardGrad.Rotation = 135; cardGrad.Parent = card
    -- Стекло
    local cardGlass = Instance.new("Frame"); cardGlass.Size = UDim2.new(1,0,0.45,0)
    cardGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); cardGlass.BackgroundTransparency = 0.93
    cardGlass.BorderSizePixel = 0; cardGlass.ZIndex = 5; cardGlass.Parent = card; mkCorner(cardGlass, 10)
    -- Неоновый контур карточки
    mkNeonStroke(card, T.Neon, 1); regA(card:FindFirstChildWhichIsA("UIStroke"),"Color")

    -- Аватар с неоновым кольцом
    local ok_av, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
    end)
    local avRing = Instance.new("Frame"); avRing.Size = UDim2.new(0,72,0,72)
    avRing.Position = UDim2.new(0,12,0.5,-36); avRing.BackgroundColor3 = T.Neon
    avRing.BackgroundTransparency = 0.6; avRing.BorderSizePixel = 0; avRing.ZIndex = 5; avRing.Parent = card
    mkCorner(avRing, 36); regA(avRing)
    local av = Instance.new("ImageLabel"); av.Size = UDim2.new(0,66,0,66)
    av.Position = UDim2.new(0,15,0.5,-33); av.BackgroundColor3 = T.BgBase
    av.BackgroundTransparency = 0; av.Image = ok_av and thumb or ""
    av.ZIndex = 6; av.Parent = card; mkCorner(av, 33)

    local function infoLbl(txt, yOff, big)
        local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1
        l.Text = txt; l.Font = big and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize = big and 15 or 11; l.TextColor3 = big and T.TextMain or T.TextSub
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Size = UDim2.new(1,-98,0,17); l.Position = UDim2.new(0,94,0,yOff)
        l.ZIndex = 6; l.Parent = card
        if big then l:SetAttribute("TextRole","main") end
        return l
    end
    infoLbl(player.Name, 12, true)
    infoLbl("UserID: " .. player.UserId, 32, false)
    infoLbl((ok_g and gname or "Unknown") .. "  ·  PlaceID: " .. game.PlaceId, 50, false)
    local platLbl = Instance.new("TextLabel"); platLbl.BackgroundTransparency = 1
    platLbl.Text = "● " .. platformName; platLbl.Font = Enum.Font.GothamBold; platLbl.TextSize = 10
    platLbl.TextColor3 = T.Neon; platLbl.TextXAlignment = Enum.TextXAlignment.Left
    platLbl.Size = UDim2.new(0,80,0,14); platLbl.Position = UDim2.new(0,94,0,68)
    platLbl.ZIndex = 6; platLbl.Parent = card; regA(platLbl,"TextColor3")

    -- FPS карточка стеклянная
    local fpsRow = Instance.new("Frame"); fpsRow.Size = UDim2.new(1,0,0,34)
    fpsRow.BackgroundColor3 = T.BgPanel; fpsRow.BackgroundTransparency = 0.12
    fpsRow.BorderSizePixel = 0; fpsRow.ZIndex = 4; fpsRow.Parent = scrollingFrame; mkCorner(fpsRow, 8)
    local fpsGrad = Instance.new("UIGradient")
    fpsGrad.Color = ColorSequence.new(Color3.fromRGB(22,18,38), Color3.fromRGB(14,12,26))
    fpsGrad.Rotation = 0; fpsGrad.Parent = fpsRow
    local fpsGlass = Instance.new("Frame"); fpsGlass.Size = UDim2.new(1,0,0.5,0)
    fpsGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); fpsGlass.BackgroundTransparency = 0.94
    fpsGlass.BorderSizePixel = 0; fpsGlass.ZIndex = 5; fpsGlass.Parent = fpsRow; mkCorner(fpsGlass, 8)
    mkNeonStroke(fpsRow, T.Neon, 1)
    local fpsLbl = Instance.new("TextLabel"); fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS: ..."; fpsLbl.Font = Enum.Font.GothamBold; fpsLbl.TextSize = 12
    fpsLbl.TextColor3 = T.TextMain; fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
    fpsLbl.Size = UDim2.new(1,-20,1,0); fpsLbl.Position = UDim2.new(0,16,0,0)
    fpsLbl.ZIndex = 6; fpsLbl.Parent = fpsRow; fpsLbl:SetAttribute("TextRole","main")
    local lt, fc = tick(), 0
    RunService.Heartbeat:Connect(function()
        fc=fc+1; local ct=tick()
        if ct-lt>=1 then fpsLbl.Text="⚡ FPS: "..fc; fc=0; lt=ct end
    end)

    createSectionHeader("Social", scrollingFrame)
    createLabel("▶  YouTube  ·  youtube.com/@Vermax",     scrollingFrame)
    createLabel("✈  Telegram  ·  t.me/@vermax",            scrollingFrame)
    createLabel("💬  Discord  ·  discord.com/invite/vermax",scrollingFrame)
end

-- ══════════════════════════════════════════════════════════════
--  UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════════════
local function checkFunctions()
    local funcs = {
        "getrawmetatable","makefolder","getscriptbytecode","setthreadidentity","delfile","request",
        "Drawing.Fonts","isscriptable","iscclosure","getscripts","isfolder","sethiddenproperty",
        "getthreadidentity","readfile","getscriptclosure","delfolder","setscriptable","Drawing.new",
        "hookmetamethod","getrunningscripts","checkcaller","setrawmetatable","gethiddenproperty",
        "writefile","getnamecallmethod","isfile","fireclickdetector","getnilinstances","getcustomasset",
        "islclosure","loadstring","cache.iscached","cache.invalidate","cloneref","cache.replace","getgc",
        "getrenv","hookfunction","setreadonly","getloadedmodules","fireproximityprompt","listfiles","gethui",
        "isreadonly","appendfile","loadfile","getinstances","isexecutorclosure","getcallbackvalue",
        "replicatesignal","decompile","filtergc","identifyexecutor","firesignal","firetouchinterest",
        "getcallingscript","getsenv","clonefunction","getgenv","newcclosure","getconnections","restorefunction",
    }
    local av, unav = {}, {}
    for _, fn in ipairs(funcs) do
        local s = pcall(function()
            if fn:find("%.") then
                local parts = fn:split("%."); local obj = _G
                for i, p in ipairs(parts) do
                    if i==#parts then if obj[p]~=nil then return true end
                    else obj=obj[p]; if obj==nil then return false end end
                end
            else return _G[fn]~=nil end
        end)
        if s then table.insert(av, fn) else table.insert(unav, fn) end
    end
    return av, unav
end

local function setupAntiBanKick()
    pcall(function()
        local mt = getrawmetatable(game); if not mt then return end
        local old = mt.__namecall; setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self,...)
            local m = getnamecallmethod()
            if m=="Kick" or m=="kick" then createNotification("ANTI-KICK","Blocked",3,7733960981) return nil end
            if m=="Ban"  or m=="ban"  then createNotification("ANTI-BAN","Blocked",3,7733960981)  return nil end
            return old(self,...)
        end); setreadonly(mt, true)
    end)
    createNotification("PROTECTION","Anti-Ban/Anti-Kick ON",3,7733960981)
end

local function saveCoordinates()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then createNotification("ERROR","No HumanoidRootPart",3,7733968497) return end
    local p = root.Position
    local txt = string.format("X: %.2f, Y: %.2f, Z: %.2f", p.X, p.Y, p.Z)
    pcall(function()
        if not isfolder("MegaHack") then makefolder("MegaHack") end
        writefile("MegaHack/coordinates.txt", txt)
    end)
    createNotification("SAVED", txt, 4, 7733960981)
end

local function teleportToCoordinates()
    local ok2, txt = pcall(readfile,"MegaHack/coordinates.txt")
    if not ok2 then createNotification("ERROR","No saved coords",3,7733968497) return end
    local x,y,z = txt:match("X: ([%-%.%d]+), Y: ([%-%.%d]+), Z: ([%-%.%d]+)")
    if not x then createNotification("ERROR","Invalid format",3,7733968497) return end
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(tonumber(x),tonumber(y),tonumber(z))
        createNotification("TELEPORT","Done!",3,7733960981)
    end
end

-- ══════════════════════════════════════════════════════════════
--  HSV COLOR PICKER
-- ══════════════════════════════════════════════════════════════
local function createColorPicker(parent)
    local selType = "bgColor"
    local curH, curS, curV = Color3.toHSV(settings.colors.bgColor)
    local curR = math.floor(settings.colors.bgColor.R*255+0.5)
    local curG = math.floor(settings.colors.bgColor.G*255+0.5)
    local curB = math.floor(settings.colors.bgColor.B*255+0.5)

    local function syncFromType()
        local col = settings.colors[selType]
        curH,curS,curV = Color3.toHSV(col)
        curR=math.floor(col.R*255+0.5); curG=math.floor(col.G*255+0.5); curB=math.floor(col.B*255+0.5)
    end

    local container = Instance.new("Frame"); container.BackgroundTransparency = 1
    container.Size = UDim2.new(1,0,0,340); container.ZIndex = 4; container.Parent = parent
    local innerLayout = Instance.new("UIListLayout"); innerLayout.Padding = UDim.new(0,6)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder; innerLayout.Parent = container
    innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1,0,0,innerLayout.AbsoluteContentSize.Y+4)
    end)

    -- Тип выбора
    local typeRow = Instance.new("Frame"); typeRow.BackgroundTransparency = 1
    typeRow.Size = UDim2.new(1,0,0,30); typeRow.LayoutOrder = 1; typeRow.ZIndex = 4; typeRow.Parent = container
    local typeRowLayout = Instance.new("UIListLayout"); typeRowLayout.FillDirection = Enum.FillDirection.Horizontal
    typeRowLayout.Padding = UDim.new(0,4); typeRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    typeRowLayout.Parent = typeRow

    local typeBtnMap = {}
    local typeItems = {
        {label="BG Color", key="bgColor"}, {label="Text", key="textColor"},
        {label="Stroke",   key="strokeColor"}, {label="Accent", key="accentColor"},
    }
    local updatePickerUI

    local function refreshTypeBtns(activeKey)
        for _, td in ipairs(typeItems) do
            local b = typeBtnMap[td.key]
            if b then
                if td.key == activeKey then
                    b.BackgroundColor3 = T.Neon; b.BackgroundTransparency = 0.25; b.TextColor3 = T.TextMain
                else
                    b.BackgroundColor3 = T.BgBtn; b.BackgroundTransparency = 0.3; b.TextColor3 = T.TextSub
                end
            end
        end
    end

    for i, td in ipairs(typeItems) do
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0.25,-3,1,0)
        btn.BackgroundColor3 = T.BgBtn; btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0; btn.Text = td.label; btn.TextColor3 = T.TextSub
        btn.TextSize = 11; btn.Font = Enum.Font.GothamBold; btn.LayoutOrder = i; btn.ZIndex = 5; btn.Parent = typeRow
        mkCorner(btn, 6); mkNeonStroke(btn, T.Neon, 1)
        typeBtnMap[td.key] = btn
        btn.MouseButton1Click:Connect(function()
            selType = td.key; syncFromType(); refreshTypeBtns(selType)
            if updatePickerUI then updatePickerUI() end
        end)
    end
    refreshTypeBtns(selType)

    local sqSz = 148
    local mainArea = Instance.new("Frame"); mainArea.BackgroundTransparency = 1
    mainArea.Size = UDim2.new(1,0,0,sqSz); mainArea.LayoutOrder = 2; mainArea.ZIndex = 4; mainArea.Parent = container

    -- SV квадрат
    local svBase = Instance.new("Frame"); svBase.Size = UDim2.new(0,sqSz,0,sqSz)
    svBase.BackgroundColor3 = Color3.fromHSV(curH,1,1); svBase.BorderSizePixel = 0
    svBase.ZIndex = 5; svBase.Parent = mainArea; mkCorner(svBase, 6)
    mkNeonStroke(svBase, T.Neon, 1)

    local whiteOv = Instance.new("Frame"); whiteOv.Size = UDim2.new(1,0,1,0)
    whiteOv.BackgroundColor3 = Color3.new(1,1,1); whiteOv.BorderSizePixel = 0
    whiteOv.ZIndex = 6; whiteOv.Parent = svBase; mkCorner(whiteOv, 6)
    local wg = Instance.new("UIGradient"); wg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)
    }); wg.Rotation = 0; wg.Parent = whiteOv

    local blackOv = Instance.new("Frame"); blackOv.Size = UDim2.new(1,0,1,0)
    blackOv.BackgroundColor3 = Color3.new(0,0,0); blackOv.BorderSizePixel = 0
    blackOv.ZIndex = 7; blackOv.Parent = svBase; mkCorner(blackOv, 6)
    local bg2 = Instance.new("UIGradient"); bg2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)
    }); bg2.Rotation = 90; bg2.Parent = blackOv

    local svCursor = Instance.new("Frame"); svCursor.Size = UDim2.new(0,12,0,12)
    svCursor.AnchorPoint = Vector2.new(0.5,0.5); svCursor.Position = UDim2.new(curS,0,1-curV,0)
    svCursor.BackgroundColor3 = Color3.new(1,1,1); svCursor.BorderSizePixel = 0
    svCursor.ZIndex = 9; svCursor.Parent = svBase; mkCorner(svCursor, 6)
    mkStroke(svCursor, 2, Color3.new(0,0,0), 0.3)

    -- Правая панель
    local rightPanel = Instance.new("Frame"); rightPanel.BackgroundTransparency = 1
    rightPanel.Size = UDim2.new(1,-(sqSz+8),1,0); rightPanel.Position = UDim2.new(0,sqSz+8,0,0)
    rightPanel.ZIndex = 4; rightPanel.Parent = mainArea

    -- Превью с градиентом и стеклом
    local previewSwatch = Instance.new("Frame"); previewSwatch.Size = UDim2.new(1,0,0,54)
    previewSwatch.BackgroundColor3 = settings.colors[selType]; previewSwatch.BorderSizePixel = 0
    previewSwatch.ZIndex = 5; previewSwatch.Parent = rightPanel; mkCorner(previewSwatch, 7)
    mkNeonStroke(previewSwatch, T.Neon, 1)
    local pvGlass = Instance.new("Frame"); pvGlass.Size = UDim2.new(1,0,0.5,0)
    pvGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); pvGlass.BackgroundTransparency = 0.86
    pvGlass.BorderSizePixel = 0; pvGlass.ZIndex = 6; pvGlass.Parent = previewSwatch; mkCorner(pvGlass, 7)
    local previewLbl = Instance.new("TextLabel"); previewLbl.BackgroundTransparency = 1
    previewLbl.Text = "PREVIEW"; previewLbl.Font = Enum.Font.GothamBold; previewLbl.TextSize = 9
    previewLbl.TextColor3 = Color3.new(1,1,1); previewLbl.TextTransparency = 0.45
    previewLbl.Size = UDim2.new(1,0,1,0); previewLbl.ZIndex = 7; previewLbl.Parent = previewSwatch

    -- Hex input
    local hexRow = Instance.new("Frame"); hexRow.Size = UDim2.new(1,0,0,26)
    hexRow.Position = UDim2.new(0,0,0,60); hexRow.BackgroundColor3 = T.BgPanel
    hexRow.BackgroundTransparency = 0.1; hexRow.BorderSizePixel = 0
    hexRow.ZIndex = 5; hexRow.Parent = rightPanel; mkCorner(hexRow, 5); mkNeonStroke(hexRow, T.Neon, 1)
    local hashLbl = Instance.new("TextLabel"); hashLbl.Size = UDim2.new(0,18,1,0)
    hashLbl.Position = UDim2.new(0,2,0,0); hashLbl.BackgroundTransparency = 1; hashLbl.Text = "#"
    hashLbl.TextColor3 = T.Neon; hashLbl.TextSize = 12; hashLbl.Font = Enum.Font.GothamBold
    hashLbl.ZIndex = 6; hashLbl.Parent = hexRow; regA(hashLbl,"TextColor3")
    local hexBox = Instance.new("TextBox"); hexBox.Size = UDim2.new(1,-20,1,0)
    hexBox.Position = UDim2.new(0,20,0,0); hexBox.BackgroundTransparency = 1
    hexBox.TextColor3 = T.TextMain; hexBox.TextSize = 11; hexBox.Font = Enum.Font.Code
    hexBox.PlaceholderText = "RRGGBB"; hexBox.PlaceholderColor3 = T.TextMuted; hexBox.Text = ""
    hexBox.ClearTextOnFocus = false; hexBox.ZIndex = 6; hexBox.Parent = hexRow
    hexBox:SetAttribute("TextRole","main")

    local rgbReadouts = {}
    for i, nm in ipairs({"R","G","B"}) do
        local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,0,0,14)
        lbl.Position = UDim2.new(0,0,0,92+(i-1)*17); lbl.BackgroundTransparency = 1
        lbl.Text = nm..": 0"; lbl.TextColor3 = T.TextSub; lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 5; lbl.Parent = rightPanel; rgbReadouts[i] = lbl
    end

    -- Hue slider
    local hueTrack = Instance.new("Frame"); hueTrack.Size = UDim2.new(1,0,0,16)
    hueTrack.BackgroundColor3 = Color3.new(1,0,0); hueTrack.BorderSizePixel = 0
    hueTrack.LayoutOrder = 3; hueTrack.ZIndex = 5; hueTrack.Parent = container
    mkCorner(hueTrack, 4); mkNeonStroke(hueTrack, T.Neon, 1)
    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6,1,1)),
        ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
        ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)),
        ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6,1,1)),
        ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)),
        ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
        ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,  1,1)),
    }); hueGrad.Parent = hueTrack

    local hueCursor = Instance.new("Frame"); hueCursor.Size = UDim2.new(0,8,1,4)
    hueCursor.AnchorPoint = Vector2.new(0.5,0.5); hueCursor.Position = UDim2.new(curH,0,0.5,0)
    hueCursor.BackgroundColor3 = Color3.new(1,1,1); hueCursor.BorderSizePixel = 0
    hueCursor.ZIndex = 6; hueCursor.Parent = hueTrack; mkCorner(hueCursor, 4)
    mkStroke(hueCursor, 1.5, Color3.new(0,0,0), 0.2)

    -- RGB слайдеры
    local rgbTracks, rgbCursors, rgbValLbls = {},{},{}
    local rgbPureCol = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1)}
    for i, nm in ipairs({"R","G","B"}) do
        local slot = Instance.new("Frame"); slot.BackgroundTransparency = 1
        slot.Size = UDim2.new(1,0,0,22); slot.LayoutOrder = 3+i; slot.ZIndex = 4; slot.Parent = container
        local nmLbl = Instance.new("TextLabel"); nmLbl.Size = UDim2.new(0,14,1,0)
        nmLbl.BackgroundTransparency = 1; nmLbl.Text = nm; nmLbl.TextColor3 = T.TextSub
        nmLbl.TextSize = 11; nmLbl.Font = Enum.Font.GothamBold; nmLbl.ZIndex = 5; nmLbl.Parent = slot
        local track = Instance.new("Frame"); track.Size = UDim2.new(1,-52,0,12)
        track.Position = UDim2.new(0,18,0.5,-6); track.BackgroundColor3 = Color3.new(0,0,0)
        track.BorderSizePixel = 0; track.ZIndex = 5; track.Parent = slot; mkCorner(track, 4)
        mkNeonStroke(track, T.Neon, 1)
        local tg = Instance.new("UIGradient"); tg.Color = ColorSequence.new(Color3.new(0,0,0),rgbPureCol[i]); tg.Parent = track
        local cur = Instance.new("Frame"); cur.Size = UDim2.new(0,10,1,4); cur.AnchorPoint = Vector2.new(0.5,0.5)
        cur.Position = UDim2.new(0,0,0.5,0); cur.BackgroundColor3 = Color3.new(1,1,1); cur.BorderSizePixel = 0
        cur.ZIndex = 6; cur.Parent = track; mkCorner(cur, 5); mkStroke(cur, 1.5, Color3.new(0,0,0), 0.2)
        local valLbl = Instance.new("TextLabel"); valLbl.Size = UDim2.new(0,32,1,0)
        valLbl.Position = UDim2.new(1,-32,0,0); valLbl.BackgroundTransparency = 1; valLbl.Text = "0"
        valLbl.TextColor3 = T.TextMain; valLbl.TextSize = 11; valLbl.Font = Enum.Font.Gotham
        valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 5; valLbl.Parent = slot
        valLbl:SetAttribute("TextRole","main")
        rgbTracks[i]=track; rgbCursors[i]=cur; rgbValLbls[i]=valLbl
    end

    -- Кнопка Apply
    local applyBtn = Instance.new("TextButton"); applyBtn.Size = UDim2.new(1,0,0,32)
    applyBtn.BackgroundColor3 = T.Accent; applyBtn.BackgroundTransparency = 0.1
    applyBtn.BorderSizePixel = 0; applyBtn.Text = "✔  Apply & Save"
    applyBtn.TextColor3 = Color3.fromRGB(255,210,210); applyBtn.TextSize = 13
    applyBtn.Font = Enum.Font.GothamBold; applyBtn.LayoutOrder = 7; applyBtn.ZIndex = 5; applyBtn.Parent = container
    applyBtn:SetAttribute("TextRole","main"); mkCorner(applyBtn, 7)
    mkNeonStroke(applyBtn, T.Neon, 1.5); regA(applyBtn)
    -- Градиент кнопки
    local applyGrad = Instance.new("UIGradient")
    applyGrad.Color = ColorSequence.new(T.AccentGlow, T.Accent); applyGrad.Rotation = 135; applyGrad.Parent = applyBtn
    -- Стекло
    local applyGlass = Instance.new("Frame"); applyGlass.Size = UDim2.new(1,0,0.5,0)
    applyGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); applyGlass.BackgroundTransparency = 0.87
    applyGlass.BorderSizePixel = 0; applyGlass.ZIndex = 6; applyGlass.Parent = applyBtn; mkCorner(applyGlass, 7)

    applyBtn.MouseEnter:Connect(function()
        TweenService:Create(applyBtn,TweenInfo.new(0.14),{BackgroundTransparency=0}):Play()
    end)
    applyBtn.MouseLeave:Connect(function()
        TweenService:Create(applyBtn,TweenInfo.new(0.14),{BackgroundTransparency=0.1}):Play()
    end)

    -- UpdateUI
    updatePickerUI = function()
        local col = Color3.fromHSV(curH, curS, curV)
        svBase.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
        svCursor.Position = UDim2.new(curS, 0, 1-curV, 0)
        hueCursor.Position = UDim2.new(curH, 0, 0.5, 0)
        previewSwatch.BackgroundColor3 = col
        curR=math.floor(col.R*255+0.5); curG=math.floor(col.G*255+0.5); curB=math.floor(col.B*255+0.5)
        hexBox.Text = string.format("%02X%02X%02X", curR, curG, curB)
        rgbReadouts[1].Text="R: "..curR; rgbReadouts[2].Text="G: "..curG; rgbReadouts[3].Text="B: "..curB
        local vals = {curR/255, curG/255, curB/255}
        for i=1,3 do
            rgbCursors[i].Position = UDim2.new(vals[i],0,0.5,0)
            rgbValLbls[i].Text = tostring(({curR,curG,curB})[i])
        end
    end
    updatePickerUI()

    applyBtn.MouseButton1Click:Connect(function()
        settings.colors[selType] = Color3.fromHSV(curH, curS, curV)
        updateGuiColors(); saveColorSettings()
        createNotification("COLOR PICKER","Applied & saved!",2,74283928898866)
        TweenService:Create(applyBtn,TweenInfo.new(0.08),{BackgroundColor3=T.Neon,BackgroundTransparency=0}):Play()
        task.delay(0.2,function()
            TweenService:Create(applyBtn,TweenInfo.new(0.2),{BackgroundColor3=T.Accent,BackgroundTransparency=0.1}):Play()
        end)
    end)

    local draggingSV, draggingHue, draggingRGB = false, false, 0
    local c1 = svBase.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingSV=true end
    end)
    local c2 = hueTrack.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingHue=true end
    end)
    for i=1,3 do
        local ci = rgbTracks[i].InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then draggingRGB=i end
        end); table.insert(colorPickerConnections, ci)
    end
    table.insert(colorPickerConnections, c1); table.insert(colorPickerConnections, c2)
    local mc = UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
        if draggingSV then
            local ap=svBase.AbsolutePosition; local as=svBase.AbsoluteSize
            curS=math.clamp((inp.Position.X-ap.X)/as.X,0,1)
            curV=1-math.clamp((inp.Position.Y-ap.Y)/as.Y,0,1); updatePickerUI()
        elseif draggingHue then
            local ap=hueTrack.AbsolutePosition; local as=hueTrack.AbsoluteSize
            curH=math.clamp((inp.Position.X-ap.X)/as.X,0,1); updatePickerUI()
        elseif draggingRGB>0 then
            local i=draggingRGB; local ap=rgbTracks[i].AbsolutePosition; local as=rgbTracks[i].AbsoluteSize
            local v=math.floor(math.clamp((inp.Position.X-ap.X)/as.X,0,1)*255+0.5)
            if i==1 then curR=v elseif i==2 then curG=v else curB=v end
            curH,curS,curV=Color3.toHSV(Color3.fromRGB(curR,curG,curB)); updatePickerUI()
        end
    end); table.insert(colorPickerConnections, mc)
    local ec = UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            draggingSV=false; draggingHue=false; draggingRGB=0
        end
    end); table.insert(colorPickerConnections, ec)
    hexBox.FocusLost:Connect(function(enter)
        if not enter then return end
        local hex = hexBox.Text:gsub("[^%x]",""):upper()
        if #hex==6 then
            local r=tonumber(hex:sub(1,2),16); local g=tonumber(hex:sub(3,4),16); local b=tonumber(hex:sub(5,6),16)
            if r and g and b then
                curR,curG,curB=r,g,b; curH,curS,curV=Color3.toHSV(Color3.fromRGB(r,g,b)); updatePickerUI()
            end
        end
    end)
    return container
end

-- ══════════════════════════════════════════════════════════════
--  SHOW SETTINGS
-- ══════════════════════════════════════════════════════════════
local function showSettings()
    clearContent()
    local function saveAndUpdate()
        updateGuiColors(); showSettings()
    end

    createSectionHeader("Color Picker", scrollingFrame)
    createColorPicker(scrollingFrame)

    createSectionHeader("Transparency", scrollingFrame)
    for _, t in ipairs({{"0%",0},{"8%",0.08},{"20%",0.20},{"40%",0.40},{"60%",0.60},{"80%",0.80}}) do
        createButton(t[1], scrollingFrame, function()
            settings.transparency = t[2]; saveAndUpdate()
        end)
    end

    createSectionHeader("Server", scrollingFrame)
    createButton("Rejoin", scrollingFrame, function()
        local s,e = pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        if not s then createNotification("ERROR","Rejoin: "..tostring(e):sub(1,50),5,7733968497) end
    end)
    createButton("Server Hop", scrollingFrame, function()
        local s,e = pcall(function()
            local sv = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            if #sv.data>0 then TeleportService:TeleportToPlaceInstance(game.PlaceId,sv.data[math.random(1,#sv.data)].id,player)
            else createNotification("ERROR","No servers",5,7733968497) end
        end)
        if not s then createNotification("ERROR","Hop: "..tostring(e):sub(1,50),5,7733968497) end
    end)
    createButton("Copy Server ID", scrollingFrame, function()
        pcall(function() setclipboard(game.JobId); createNotification("COPIED","Server ID copied",3) end)
    end)

    createSectionHeader("Coordinates", scrollingFrame)
    createButton("Save Current Position",      scrollingFrame, saveCoordinates)
    createButton("Teleport to Saved Position", scrollingFrame, teleportToCoordinates)

    createSectionHeader("Security", scrollingFrame)
    createButton("Enable Anti-Ban / Anti-Kick", scrollingFrame, setupAntiBanKick)
    createButton("Check Executor Functions",    scrollingFrame, function()
        local av,unav = checkFunctions()
        createNotification("FUNCTIONS","Available: "..#av.."/"..(#av+#unav),5,7733960981)
        print("=== AVAILABLE ==="); for _,f in ipairs(av) do print("✓ "..f) end
        print("=== UNAVAILABLE ==="); for _,f in ipairs(unav) do print("✗ "..f) end
    end)

    createSectionHeader("Appearance", scrollingFrame)
    createButton((settings.locked and "🔓 Unlock GUI" or "🔒 Lock GUI"), scrollingFrame, function()
        settings.locked = not settings.locked; saveAndUpdate()
    end)
    createButton("RGB Text: "..(settings.rgbAccent and "ON ✦" or "OFF"), scrollingFrame, function()
        settings.rgbAccent = not settings.rgbAccent; saveColorSettings(); saveAndUpdate()
    end)
    createButton("RGB Stroke: "..(settings.rgbStroke and "ON ✦" or "OFF"), scrollingFrame, function()
        settings.rgbStroke = not settings.rgbStroke; saveColorSettings(); saveAndUpdate()
    end)

    createSectionHeader("Actions", scrollingFrame)
    createButton("Apply & Restart", scrollingFrame, function()
        local s,r = pcall(function()
            screenGui:Destroy()
            loadstring(game:HttpGet("https://pastefy.app/QVzDuYQA/raw",true))()
        end)
        if not s then createNotification("ERROR","Restart: "..tostring(r):sub(1,50),5,7733968497) end
    end)
    createButton("Close GUI", scrollingFrame, function() screenGui:Destroy() end)
end

-- ══════════════════════════════════════════════════════════════
--  CATEGORIES
-- ══════════════════════════════════════════════════════════════
local categories = {
    ["Home"]             = showHome,
    ["Settings"]         = showSettings,
    ["All Scripts"]      = showAllScripts,
    ["MegaHack"]         = function() loadHacksFromCategory("MegaHack") end,
    ["Hacks"]            = function() loadHacksFromCategory("Hacks") end,
    ["MM2"]              = function() loadHacksFromCategory("MM2") end,
    ["Admins"]           = function() loadHacksFromCategory("Admins") end,
    ["Animations"]       = function() loadHacksFromCategory("Animations") end,
    ["FE"]               = function() loadHacksFromCategory("FE") end,
    ["Ragdoll Engine"]   = function() loadHacksFromCategory("RagdollEngine") end,
    ["Natural Disaster"] = function() loadHacksFromCategory("NaturalDisaster") end,
    ["Evade"]            = function() loadHacksFromCategory("Evade") end,
    ["IKEA 3008"]        = function() loadHacksFromCategory("IKEA3008") end,
    ["Brookhaven"]       = function() loadHacksFromCategory("Brookhaven") end,
    ["Blade Ball"]       = function() loadHacksFromCategory("BladeBall") end,
    ["Blox Fruit"]       = function() loadHacksFromCategory("BloxFruit") end,
    ["Steal Brain Root"] = function() loadHacksFromCategory("StealBrainRoot") end,
    ["Tower of Hell"]    = function() loadHacksFromCategory("TowerOfHell") end,
    ["Adopt Me"]         = function() loadHacksFromCategory("AdoptMe") end,
    ["Grow Garden"]      = function() loadHacksFromCategory("GrowGarden") end,
    ["Night99"]          = function() loadHacksFromCategory("Night") end,
    ["FORSAKEN"]         = function() loadHacksFromCategory("FORSAKEN") end,
    ["Weird Gun Game"]   = function() loadHacksFromCategory("Weird") end,
    ["Rivals"]           = function() loadHacksFromCategory("Rivals") end,
    ["Duels MVS"]        = function() loadHacksFromCategory("DuelsMVS") end,
    ["Violence District"]= function() loadHacksFromCategory("ViolenceDistrict") end,
}
local categoryOrder = {
    "Home","Settings","All Scripts",
    "MegaHack","Hacks","Admins","Animations","FE","Steal Brain Root",
    "Blade Ball","Ragdoll Engine","Natural Disaster",
    "MM2","Duels MVS","Evade","IKEA 3008","Blox Fruit","Brookhaven",
    "Adopt Me","Tower of Hell","Night99","FORSAKEN",
    "Grow Garden","Violence District","Weird Gun Game","Rivals",
}

for _, catName in ipairs(categoryOrder) do
    createButton(catName, catScroll, function()
        clearContent(); categories[catName](); updateGuiColors()
    end, true)
end

-- ══════════════════════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════════════════════
local function MakeDraggable(frame, dragPart)
    dragPart = dragPart or frame
    local dragging, dragInput, mousePos, framePos
    dragPart.InputBegan:Connect(function(input)
        if settings.locked then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; mousePos=input.Position; framePos=frame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            dragInput=input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input==dragInput and dragging then
            local d=input.Position-mousePos
            frame.Position=UDim2.new(framePos.X.Scale, framePos.X.Offset+d.X, framePos.Y.Scale, framePos.Y.Offset+d.Y)
        end
    end)
end
MakeDraggable(mainFrame, headerFrame)
MakeDraggable(reopenButton, reopenButton)

-- ══════════════════════════════════════════════════════════════
--  CLOSE / REOPEN  —  анимация с масштабированием
-- ══════════════════════════════════════════════════════════════
closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame,
        TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size=UDim2.new(0,580,0,0), BackgroundTransparency=1}
    ):Play()
    task.delay(0.3, function()
        mainFrame.Visible=false
        mainFrame.Size=UDim2.new(0,580,0,390)
        mainFrame.BackgroundTransparency=settings.transparency
        reopenButton.Visible=true
    end)
end)
reopenButton.MouseButton1Click:Connect(function()
    mainFrame.Visible=true; mainFrame.Size=UDim2.new(0,580,0,0)
    mainFrame.BackgroundTransparency=1; reopenButton.Visible=false
    TweenService:Create(mainFrame,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size=UDim2.new(0,580,0,390), BackgroundTransparency=settings.transparency}
    ):Play()
end)

-- ══════════════════════════════════════════════════════════════
--  INTRO ANIMATION  —  Back easing с упругостью
-- ══════════════════════════════════════════════════════════════
mainFrame.Size=UDim2.new(0,0,0,0); mainFrame.BackgroundTransparency=1

loadColorSettings()

TweenService:Create(mainFrame,
    TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size=UDim2.new(0,580,0,390), BackgroundTransparency=settings.transparency}
):Play()

-- ══════════════════════════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════════════════════════
showHome()
updateGuiColors()

task.delay(0.1, function()
    local first = catScroll:FindFirstChildWhichIsA("TextButton")
    if first then
        first:SetAttribute("Active",true); currentActiveSideBtn=first
        TweenService:Create(first,TweenInfo.new(0.18),{
            BackgroundColor3=T.Neon, BackgroundTransparency=0.75, TextColor3=T.TextMain
        }):Play()
        local ind = first:FindFirstChildWhichIsA("Frame")
        if ind then TweenService:Create(ind,TweenInfo.new(0.18),{BackgroundTransparency=0}):Play() end
    end
end)

createNotification("MEGAHACK V1", "Loaded  ·  " .. platformName, 3, 74283928898866)
