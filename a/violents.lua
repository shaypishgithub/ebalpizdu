local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local lpGui = lp:WaitForChild("PlayerGui")
local cam = Workspace.CurrentCamera

local T = {
    BG       = Color3.fromRGB(8,8,11),
    PANEL    = Color3.fromRGB(13,13,17),
    SIDEBAR  = Color3.fromRGB(11,11,15),
    CARD     = Color3.fromRGB(19,19,25),
    CARDH    = Color3.fromRGB(26,26,34),
    BORDER   = Color3.fromRGB(38,36,50),
    ACCENT   = Color3.fromRGB(210,40,55),
    ACCENT2  = Color3.fromRGB(255,80,95),
    CYAN     = Color3.fromRGB(50,195,215),
    GOLD     = Color3.fromRGB(255,190,70),
    GREEN    = Color3.fromRGB(60,215,120),
    PURPLE   = Color3.fromRGB(190,130,255),
    ORANGE   = Color3.fromRGB(255,170,60),
    BLUE     = Color3.fromRGB(100,160,255),
    PINK     = Color3.fromRGB(255,120,195),
    TEXT     = Color3.fromRGB(225,222,232),
    DIM      = Color3.fromRGB(120,115,140),
    MUTED    = Color3.fromRGB(60,57,78),
    OFF      = Color3.fromRGB(42,40,55),
    SCROLL   = Color3.fromRGB(55,52,70),
}

local TI = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TIS = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local states = {
    antifailgen = false,
    autoskillcheck = false,
    nofall = false,
    noturnlimit = false,
    autoescape = false,
    autoparry = false,
    insthealhers = false,
    grabnearest = false,
    instescape = false,
    sacrificeself = false,
    invisible = false,
    inviseffect = false,
    invisbtn = false,
    fullgenbreak = false,
    antiblind = false,
    noslowdown = false,
    influnge = false,
    doubletap = false,
    nopalletstun = false,
    shiftlock = false,
    thirdperson = false,
    veilcross = false,
    hitboxexp = false,
    hitboxsize = 5,
    speedboost = false,
    speedval = 16,
    speedmethod = "Attribute",
    speedkey = Enum.KeyCode.Q,
    jumppower = 50,
    hipheight = 0,
    fov = 70,
    noclip = false,
    fly = false,
    flymode = "Velocity",
    flyspeed = 50,
    infinitejump = false,
    freezeself = false,
    toggleesp = false,
    player2dbox = false,
    player3dbox = false,
    shownames = false,
    showdist = false,
    showweapon = false,
    healthbars = false,
    healthtext = false,
    tracers = false,
    highlights = false,
    offscrenarrows = false,
    genesp = false,
    hookesp = false,
    vaultesp = false,
    palletesp = false,
    gateesp = false,
    teamcolor = false,
    showteam = false,
    linethick = 1,
    highldist = 500,
    filltrans = 8,
    outlinetrans = 0,
    arrowsize = 10,
    arrowradius = 200,
    espupdate = 10,
    espcheck = 5,
    ambience = false,
    forcetime = false,
    timeval = 12,
    custsat = false,
    satval = 5,
    spearaimbot = false,
    speargrav = 60,
    spearspeed = 150,
    spearkey = Enum.KeyCode.E,
    lockspear = false,
    spearbtnsz = 80,
    gunsilent = false,
    silentpart = "HumanoidRootPart",
    flingstr = 200,
    soundid = "",
    sounddist = 100,
    soundvol = 5,
    selectedemote = "Wave",
    selectedmask = "None",
    materialsel = "SmoothPlastic",
    matcolor = Color3.fromRGB(255,255,255),
    skyboxid = "",
    highlightbudget = 100,
}

local connections = {}
local espObjects = {}
local flyConn = nil
local noclipConn = nil
local jumpConn = nil
local espConn = nil
local skillCheckConn = nil
local arrowFrames = {}

local function tw(obj, props, inf)
    TweenService:Create(obj, inf or TI, props):Play()
end

local function newCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function newStroke(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or T.BORDER
    s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function newPad(p, a, t, b, l, r)
    local pd = Instance.new("UIPadding")
    if a then pd.PaddingTop=UDim.new(0,a) pd.PaddingBottom=UDim.new(0,a) pd.PaddingLeft=UDim.new(0,a) pd.PaddingRight=UDim.new(0,a)
    else
        if t then pd.PaddingTop=UDim.new(0,t) end
        if b then pd.PaddingBottom=UDim.new(0,b) end
        if l then pd.PaddingLeft=UDim.new(0,l) end
        if r then pd.PaddingRight=UDim.new(0,r) end
    end
    pd.Parent = p
end

local function newList(p, sp, dir)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, sp or 5)
    l.Parent = p
    return l
end

local function newLabel(p, txt, sz, col, font, ax)
    local lb = Instance.new("TextLabel")
    lb.BackgroundTransparency = 1
    lb.Text = txt or ""
    lb.TextSize = sz or 13
    lb.TextColor3 = col or T.TEXT
    lb.Font = font or Enum.Font.Gotham
    lb.TextXAlignment = ax or Enum.TextXAlignment.Left
    lb.Parent = p
    return lb
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VDGui_v13"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 120
ScreenGui.Parent = lpGui

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(0, 690, 0, 472)
Shadow.Position = UDim2.new(0.5, -342, 0.5, -232)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.55
Shadow.BorderSizePixel = 0
Shadow.Parent = ScreenGui
newCorner(Shadow, 13)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 684, 0, 464)
Main.Position = UDim2.new(0.5, -342, 0.5, -232)
Main.BackgroundColor3 = T.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui
newCorner(Main, 10)
newStroke(Main, T.BORDER, 1)

local TBar = Instance.new("Frame")
TBar.Size = UDim2.new(1, 0, 0, 38)
TBar.BackgroundColor3 = T.SIDEBAR
TBar.BorderSizePixel = 0
TBar.Parent = Main

local TBarLine = Instance.new("Frame")
TBarLine.Size = UDim2.new(1, 0, 0, 2)
TBarLine.Position = UDim2.new(0, 0, 1, -2)
TBarLine.BackgroundColor3 = T.ACCENT
TBarLine.BorderSizePixel = 0
TBarLine.Parent = TBar

local function winDot(xoff, col)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 12, 0, 12)
    d.Position = UDim2.new(1, xoff, 0.5, -6)
    d.BackgroundColor3 = col
    d.BorderSizePixel = 0
    d.Parent = TBar
    newCorner(d, 99)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = d
    btn.MouseEnter:Connect(function() tw(d, {BackgroundColor3=Color3.fromRGB(255,255,255)}) end)
    btn.MouseLeave:Connect(function() tw(d, {BackgroundColor3=col}) end)
    return btn, d
end

local closeBtn, closeDot = winDot(-18, Color3.fromRGB(220, 55, 65))
local minBtn, minDot     = winDot(-36, Color3.fromRGB(240, 180, 50))
local hideBtn, hideDot   = winDot(-54, Color3.fromRGB(55, 185, 100))

closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tw(Main, {Size = minimized and UDim2.new(0,684,0,38) or UDim2.new(0,684,0,464)}, TIS)
end)

local hidden = false
hideBtn.MouseButton1Click:Connect(function()
    hidden = not hidden
    tw(Main, {BackgroundTransparency = hidden and 0.92 or 0}, TIS)
end)

local TitleDot = Instance.new("Frame")
TitleDot.Size = UDim2.new(0, 7, 0, 7)
TitleDot.Position = UDim2.new(0, 14, 0.5, -3)
TitleDot.BackgroundColor3 = T.ACCENT
TitleDot.BorderSizePixel = 0
TitleDot.Parent = TBar
newCorner(TitleDot, 99)

local TitleLbl = newLabel(TBar, "Violence District", 14, T.TEXT, Enum.Font.GothamBold)
TitleLbl.Size = UDim2.new(0, 200, 1, 0)
TitleLbl.Position = UDim2.new(0, 26, 0, 0)

local VerBadge = Instance.new("Frame")
VerBadge.Size = UDim2.new(0, 42, 0, 16)
VerBadge.Position = UDim2.new(0, 168, 0.5, -8)
VerBadge.BackgroundColor3 = T.ACCENT
VerBadge.BorderSizePixel = 0
VerBadge.Parent = TBar
newCorner(VerBadge, 4)
local verLbl = newLabel(VerBadge, "v1.3", 10, Color3.fromRGB(255,255,255), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
verLbl.Size = UDim2.new(1,0,1,0)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = T.SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideDiv = Instance.new("Frame")
SideDiv.Size = UDim2.new(0, 1, 1, 0)
SideDiv.Position = UDim2.new(1, -1, 0, 0)
SideDiv.BackgroundColor3 = T.BORDER
SideDiv.BorderSizePixel = 0
SideDiv.Parent = Sidebar

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Size = UDim2.new(1, -6, 1, -6)
SideScroll.Position = UDim2.new(0, 3, 0, 3)
SideScroll.BackgroundTransparency = 1
SideScroll.ScrollBarThickness = 2
SideScroll.ScrollBarImageColor3 = T.SCROLL
SideScroll.CanvasSize = UDim2.new(0,0,0,0)
SideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SideScroll.BorderSizePixel = 0
SideScroll.Parent = Sidebar
newList(SideScroll, 2)
newPad(SideScroll, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -150, 1, -38-20)
ContentArea.Position = UDim2.new(0, 150, 0, 38)
ContentArea.BackgroundColor3 = T.PANEL
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent = Main

local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -150, 0, 20)
StatusBar.Position = UDim2.new(0, 150, 1, -20)
StatusBar.BackgroundColor3 = T.SIDEBAR
StatusBar.BorderSizePixel = 0
StatusBar.Parent = Main

local StatusDiv = Instance.new("Frame")
StatusDiv.Size = UDim2.new(1,0,0,1)
StatusDiv.BackgroundColor3 = T.BORDER
StatusDiv.BorderSizePixel = 0
StatusDiv.Parent = StatusBar

local SDot = Instance.new("Frame")
SDot.Size = UDim2.new(0,6,0,6)
SDot.Position = UDim2.new(0,10,0.5,-3)
SDot.BackgroundColor3 = T.GREEN
SDot.BorderSizePixel = 0
SDot.Parent = StatusBar
newCorner(SDot, 99)

local STxt = newLabel(StatusBar, "Ready  •  All systems operational  •  Violence District v1.3", 10, T.MUTED, Enum.Font.Gotham)
STxt.Size = UDim2.new(1,-24,1,0)
STxt.Position = UDim2.new(0,22,0,0)

TweenService:Create(SDot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency=0.7}):Play()

local allTabs = {}
local activeTabKey = nil

local tabDefs = {
    {k="main",     name="MAIN",     icon="⚙",  col=T.GOLD},
    {k="survivor", name="SURVIVOR", icon="🏃", col=T.CYAN},
    {k="killer",   name="KILLER",   icon="🔪", col=T.ACCENT},
    {k="fling",    name="FLING",    icon="💫", col=T.PURPLE},
    {k="sound",    name="SOUND",    icon="🔊", col=T.GREEN},
    {k="emotes",   name="EMOTES",   icon="💃", col=T.ORANGE},
    {k="player",   name="PLAYER",   icon="👤", col=T.BLUE},
    {k="esp",      name="ESP",      icon="👁",  col=T.CYAN},
    {k="visuals",  name="VISUALS",  icon="🎨", col=T.PINK},
    {k="aimbot",   name="AIMBOT",   icon="🎯", col=T.ACCENT},
}

for i, def in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Name = def.k
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = T.SIDEBAR
    btn.BackgroundTransparency = 0
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.Parent = SideScroll
    newCorner(btn, 5)

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0.65, 0)
    ind.Position = UDim2.new(0, 0, 0.175, 0)
    ind.BackgroundColor3 = def.col
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.Parent = btn
    newCorner(ind, 2)

    local ico = newLabel(btn, def.icon, 12, T.DIM, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    ico.Size = UDim2.new(0, 22, 1, 0)
    ico.Position = UDim2.new(0, 8, 0, 0)

    local nm = newLabel(btn, def.name, 11, T.DIM, Enum.Font.Gotham, Enum.TextXAlignment.Left)
    nm.Size = UDim2.new(1, -36, 1, 0)
    nm.Position = UDim2.new(0, 34, 0, 0)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = def.k.."_page"
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = T.SCROLL
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.BorderSizePixel = 0
    scroll.Visible = false
    scroll.Parent = ContentArea
    newList(scroll, 0)
    newPad(scroll, nil, 8, 10, 10, 10)

    allTabs[def.k] = {btn=btn, ind=ind, ico=ico, nm=nm, scroll=scroll, col=def.col}

    btn.MouseButton1Click:Connect(function()
        for k, t in pairs(allTabs) do
            local active = k == def.k
            t.scroll.Visible = active
            tw(t.btn, {BackgroundColor3 = active and T.CARD or T.SIDEBAR})
            tw(t.ind, {BackgroundTransparency = active and 0 or 1})
            tw(t.nm, {TextColor3 = active and t.col or T.DIM})
            tw(t.ico, {TextColor3 = active and t.col or T.DIM})
        end
        activeTabKey = def.k
    end)
end

local function getSc(k)
    return allTabs[k].scroll
end

local function sec(parent, txt, col)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = T.BORDER
    line.BorderSizePixel = 0
    line.Parent = f

    local lbl = newLabel(f, "  "..txt.."  ", 10, col or T.GOLD, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundColor3 = T.PANEL
    newPad(lbl, 2)
    return f
end

local function row(parent, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, h or 36)
    f.BackgroundColor3 = T.CARD
    f.BorderSizePixel = 0
    f.Parent = parent
    newCorner(f, 6)
    return f
end

local function makeToggle(parent, lbl, sub, col, stateKey, onCb)
    local f = row(parent, sub and 50 or 36)
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0.65, 0)
    bar.Position = UDim2.new(0, 0, 0.175, 0)
    bar.BackgroundColor3 = col or T.BORDER
    bar.BorderSizePixel = 0
    bar.Parent = f
    newCorner(bar, 2)

    local mainLbl = newLabel(f, lbl, 12, T.TEXT, Enum.Font.Gotham)
    mainLbl.Size = UDim2.new(1, -60, 0, 18)
    mainLbl.Position = UDim2.new(0, 12, 0, sub and 7 or 9)

    if sub then
        local subLbl = newLabel(f, sub, 10, T.DIM, Enum.Font.Gotham)
        subLbl.Size = UDim2.new(1, -60, 0, 14)
        subLbl.Position = UDim2.new(0, 12, 0, 27)
    end

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 34, 0, 17)
    track.Position = UDim2.new(1, -46, 0.5, -8)
    track.BackgroundColor3 = T.OFF
    track.BorderSizePixel = 0
    track.Parent = f
    newCorner(track, 99)
    newStroke(track, T.BORDER, 1)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 11, 0, 11)
    knob.Position = UDim2.new(0, 3, 0.5, -5)
    knob.BackgroundColor3 = T.DIM
    knob.BorderSizePixel = 0
    knob.Parent = track
    newCorner(knob, 99)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1,0,1,0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = f

    local function setVisual(on)
        tw(track, {BackgroundColor3 = on and T.GREEN or T.OFF})
        tw(knob, {Position = on and UDim2.new(0,20,0.5,-5) or UDim2.new(0,3,0.5,-5)})
        tw(knob, {BackgroundColor3 = on and Color3.fromRGB(255,255,255) or T.DIM})
    end

    if stateKey and states[stateKey] then setVisual(true) end

    clickArea.MouseButton1Click:Connect(function()
        local newState = not (stateKey and states[stateKey] or false)
        if stateKey then states[stateKey] = newState end
        setVisual(newState)
        if onCb then onCb(newState) end
    end)

    f.MouseEnter:Connect(function() tw(f, {BackgroundColor3=T.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f, {BackgroundColor3=T.CARD}) end)
    return f
end

local function makeSlider(parent, lbl, mn, mx, def, stateKey, col, onCb)
    local f = row(parent, 52)

    local mainLbl = newLabel(f, lbl, 12, T.TEXT, Enum.Font.Gotham)
    mainLbl.Size = UDim2.new(0.7, 0, 0, 18)
    mainLbl.Position = UDim2.new(0, 12, 0, 7)

    local valLbl = newLabel(f, tostring(def), 12, col or T.ACCENT2, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.28, 0, 0, 18)
    valLbl.Position = UDim2.new(0.7, 0, 0, 7)

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 3)
    track.Position = UDim2.new(0, 12, 0, 36)
    track.BackgroundColor3 = T.OFF
    track.BorderSizePixel = 0
    track.Parent = f
    newCorner(track, 99)

    local pct = (def - mn) / (mx - mn)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = col or T.ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = track
    newCorner(fill, 99)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 11, 0, 11)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(pct, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    newCorner(thumb, 99)

    local drag = false
    local function update(x)
        local abs = track.AbsolutePosition.X
        local sz = track.AbsoluteSize.X
        local p = math.clamp((x - abs) / sz, 0, 1)
        local v = math.round(mn + (mx - mn) * p)
        tw(fill, {Size=UDim2.new(p,0,1,0)})
        thumb.Position = UDim2.new(p, 0, 0.5, 0)
        valLbl.Text = tostring(v)
        if stateKey then states[stateKey] = v end
        if onCb then onCb(v) end
    end
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)

    f.MouseEnter:Connect(function() tw(f, {BackgroundColor3=T.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f, {BackgroundColor3=T.CARD}) end)
    return f
end

local function makeButton(parent, txt, col, onCb)
    local f = row(parent, 34)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0.65, 0)
    accentBar.Position = UDim2.new(0, 0, 0.175, 0)
    accentBar.BackgroundColor3 = col or T.ACCENT
    accentBar.BorderSizePixel = 0
    accentBar.Parent = f
    newCorner(accentBar, 2)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -18, 0, 22)
    btn.Position = UDim2.new(0, 12, 0.5, -11)
    btn.BackgroundColor3 = col or T.ACCENT
    btn.BackgroundTransparency = 0.82
    btn.Text = txt
    btn.TextColor3 = col or T.ACCENT2
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = f
    newCorner(btn, 5)

    btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency=0.6}) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency=0.82}) end)
    btn.MouseButton1Click:Connect(function()
        tw(btn, {BackgroundTransparency=0.15})
        task.delay(0.12, function() tw(btn, {BackgroundTransparency=0.82}) end)
        if onCb then onCb() end
    end)

    f.MouseEnter:Connect(function() tw(f, {BackgroundColor3=T.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f, {BackgroundColor3=T.CARD}) end)
    return f
end

local function makeInput(parent, lbl, ph, stateKey, onCb)
    local f = row(parent, 52)

    local mainLbl = newLabel(f, lbl, 11, T.DIM, Enum.Font.Gotham)
    mainLbl.Size = UDim2.new(1,-12,0,16)
    mainLbl.Position = UDim2.new(0,12,0,6)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-24,0,22)
    box.Position = UDim2.new(0,12,0,24)
    box.BackgroundColor3 = T.BG
    box.Text = ""
    box.PlaceholderText = ph or ""
    box.PlaceholderColor3 = T.MUTED
    box.TextColor3 = T.TEXT
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.BorderSizePixel = 0
    box.Parent = f
    newCorner(box, 4)
    newStroke(box, T.BORDER)
    newPad(box, nil, 0, 0, 8, 8)

    box.Focused:Connect(function() tw(box, {BackgroundColor3=T.CARD}) end)
    box.FocusLost:Connect(function(enter)
        tw(box, {BackgroundColor3=T.BG})
        if stateKey then states[stateKey] = box.Text end
        if enter and onCb then onCb(box.Text) end
    end)

    f.MouseEnter:Connect(function() tw(f, {BackgroundColor3=T.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f, {BackgroundColor3=T.CARD}) end)
    return f, box
end

local function makeDropdown(parent, lbl, opts, stateKey, onCb)
    local f = row(parent, 52)
    f.ZIndex = 8
    f.ClipsDescendants = false

    local mainLbl = newLabel(f, lbl, 11, T.DIM, Enum.Font.Gotham)
    mainLbl.Size = UDim2.new(1,-12,0,16)
    mainLbl.Position = UDim2.new(0,12,0,6)
    mainLbl.ZIndex = 8

    local dBtn = Instance.new("TextButton")
    dBtn.Size = UDim2.new(1,-24,0,22)
    dBtn.Position = UDim2.new(0,12,0,24)
    dBtn.BackgroundColor3 = T.BG
    dBtn.Text = (opts[1] or "Select").."  ▾"
    dBtn.TextColor3 = T.TEXT
    dBtn.Font = Enum.Font.Gotham
    dBtn.TextSize = 12
    dBtn.TextXAlignment = Enum.TextXAlignment.Left
    dBtn.BorderSizePixel = 0
    dBtn.ZIndex = 9
    dBtn.Parent = f
    newCorner(dBtn, 4)
    newStroke(dBtn, T.BORDER)
    newPad(dBtn, nil, 0, 0, 8, 8)

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(1,-24,0,#opts*26)
    menu.Position = UDim2.new(0,12,0,50)
    menu.BackgroundColor3 = T.SIDEBAR
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 20
    menu.Parent = f
    newCorner(menu, 5)
    newStroke(menu, T.BORDER)
    newList(menu, 0)

    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,26)
        ob.BackgroundColor3 = T.SIDEBAR
        ob.BackgroundTransparency = 0
        ob.Text = opt
        ob.TextColor3 = T.TEXT
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 12
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.BorderSizePixel = 0
        ob.ZIndex = 21
        ob.Parent = menu
        newPad(ob, nil, 0, 0, 10, 0)
        ob.MouseEnter:Connect(function() tw(ob, {BackgroundColor3=T.CARD}) end)
        ob.MouseLeave:Connect(function() tw(ob, {BackgroundColor3=T.SIDEBAR}) end)
        ob.MouseButton1Click:Connect(function()
            dBtn.Text = opt.."  ▾"
            menu.Visible = false
            if stateKey then states[stateKey] = opt end
            if onCb then onCb(opt) end
        end)
    end

    local open = false
    dBtn.MouseButton1Click:Connect(function()
        open = not open
        menu.Visible = open
        f.Size = open and UDim2.new(1,0,0,52 + #opts*26) or UDim2.new(1,0,0,52)
    end)

    f.MouseEnter:Connect(function() tw(f, {BackgroundColor3=T.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f, {BackgroundColor3=T.CARD}) end)
    return f
end

local function spacer(parent, h)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1,0,0,h or 4)
    s.BackgroundTransparency = 1
    s.Parent = parent
end

local function getChar()
    return lp.Character
end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function clearConn(name)
    if connections[name] then
        connections[name]:Disconnect()
        connections[name] = nil
    end
end

local function notify(msg)
    STxt.Text = msg
    task.delay(3, function() STxt.Text = "Ready  •  All systems operational  •  Violence District v1.3" end)
end

local sc = getSc("main")
sec(sc, "GENERATORS", T.GOLD)
makeToggle(sc, "Anti Fail Generator", "Stops generator auto-fail", T.GOLD, "antifailgen", function(on)
    if on then
        connections["antifailgen"] = RunService.Heartbeat:Connect(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("NumberValue") and v.Name == "FailChance" then
                    v.Value = 0
                end
            end
        end)
        notify("Anti Fail Generator ON")
    else
        clearConn("antifailgen")
        notify("Anti Fail Generator OFF")
    end
end)

makeToggle(sc, "Auto Perfect Skill-Check", "Auto-hits perfect zone", T.GOLD, "autoskillcheck", function(on)
    if on then
        connections["autoskillcheck"] = RunService.Heartbeat:Connect(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "SkillCheckArrow" or v.Name == "SkillCheckIndicator" then
                    v.Rotation = 90
                end
                if v:IsA("Frame") and v.Name:find("SkillCheck") then
                    local perfect = v:FindFirstChild("PerfectZone") or v:FindFirstChild("Perfect")
                    if perfect then
                        fireproximityprompt = fireproximityprompt
                    end
                end
            end
            local gui = lp.PlayerGui:FindFirstChild("SkillCheckGui") or lp.PlayerGui:FindFirstChild("SkillCheckUI")
            if gui then
                local arr = gui:FindFirstChildWhichIsA("ImageLabel", true)
                if arr then arr.Rotation = 90 end
            end
        end)
        notify("Auto Perfect Skill-Check ON")
    else
        clearConn("autoskillcheck")
        notify("Auto Skill-Check OFF")
    end
end)

spacer(sc, 4)

local sc2 = getSc("survivor")
sec(sc2, "MOVEMENT", T.CYAN)
makeToggle(sc2, "No Fall", "Disables all fall damage", T.CYAN, "nofall", function(on)
    local hum = getHum()
    if hum then hum.FallingDown:Connect(function() if states.nofall then hum:ChangeState(Enum.HumanoidStateType.Running) end end) end
    notify(on and "No Fall ON" or "No Fall OFF")
end)

makeToggle(sc2, "No Turn Speed Limit", "Removes rotation clamping", T.CYAN, "noturnlimit", function(on)
    local hum = getHum()
    if hum then
        if on then hum.AutoRotate = false else hum.AutoRotate = true end
    end
    notify(on and "No Turn Limit ON" or "No Turn Limit OFF")
end)

makeToggle(sc2, "Auto Escape", "Automatically escapes grabs", T.CYAN, "autoescape", function(on)
    if on then
        connections["autoescape"] = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if not char then return end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BoolValue") and (v.Name == "IsGrabbed" or v.Name == "Grabbed") then
                    if v.Value then v.Value = false end
                end
            end
        end)
        notify("Auto Escape ON")
    else
        clearConn("autoescape")
        notify("Auto Escape OFF")
    end
end)

sec(sc2, "COMBAT", T.CYAN)
makeToggle(sc2, "Auto Parry", "Automatically parries hits", T.CYAN, "autoparry", function(on)
    if on then
        connections["autoparry"] = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if not char then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name:lower():find("parry") or obj.Name:lower():find("block")) then
                    pcall(function() obj:FireServer() end)
                end
            end
        end)
        notify("Auto Parry ON")
    else
        clearConn("autoparry")
        notify("Auto Parry OFF")
    end
end)

makeToggle(sc2, "Instant Heal Others", "Instantly heals nearby survivors", T.CYAN, "insthealhers", function(on)
    if on then
        connections["insthealhers"] = RunService.Heartbeat:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end
            end
        end)
        notify("Instant Heal Others ON")
    else
        clearConn("insthealhers")
        notify("Instant Heal Others OFF")
    end
end)

makeToggle(sc2, "Invisible (OP)", "Full character invisibility", T.CYAN, "invisible", function(on)
    local char = getChar()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            tw(p, {Transparency = on and 1 or 0})
        end
        if p:IsA("Decal") then p.Transparency = on and 1 or 0 end
    end
    notify(on and "Invisible ON" or "Invisible OFF")
end)

makeToggle(sc2, "Invisible Effect", "Flickering invisibility effect", T.CYAN, "inviseffect", function(on)
    if on then
        connections["inviseffect"] = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if not char then return end
            local t = math.sin(tick() * 8) > 0 and 0.92 or 0.3
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.LocalTransparencyModifier = t
                end
            end
        end)
        notify("Invis Effect ON")
    else
        clearConn("inviseffect")
        local char = getChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
            end
        end
        notify("Invis Effect OFF")
    end
end)

makeToggle(sc2, "Grab Nearest (OP)", "Grabs the nearest player", T.CYAN, "grabnearest", function(on)
    if on then
        local hrp = getHRP()
        if not hrp then return end
        local nearest, dist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then nearest = p dist = d end
            end
        end
        if nearest then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name:lower():find("grab") then
                    pcall(function() v:FireServer(nearest.Character) end)
                end
            end
            notify("Grabbed: "..nearest.Name)
        end
    else
        notify("Grab Nearest OFF")
    end
end)

makeToggle(sc2, "Instant Escape", "Instantly escapes captures", T.CYAN, "instescape", function(on)
    if on then
        connections["instescape"] = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if not char then return end
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("escape") or v.Name:lower():find("free")) then
                    pcall(function() v:FireServer() end)
                end
            end
        end)
        notify("Instant Escape ON")
    else
        clearConn("instescape")
        notify("Instant Escape OFF")
    end
end)

makeToggle(sc2, "Sacrifice Self", "Instantly sacrifice yourself", T.CYAN, "sacrificeself", function(on)
    if on then
        local hum = getHum()
        if hum then hum.Health = 0 end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("sacrifice") then
                pcall(function() v:FireServer() end)
            end
        end
        states.sacrificeself = false
        notify("Sacrifice Self triggered")
    end
end)

makeToggle(sc2, "Invisible Button (mobile)", "Mobile-only invisible button", T.CYAN, "invisbtn", function(on)
    notify(on and "Mobile Invis Btn ON" or "Mobile Invis Btn OFF")
end)

spacer(sc2, 4)

local sc3 = getSc("killer")
sec(sc3, "POWER", T.ACCENT)
makeToggle(sc3, "Full Generator Break", "Instantly breaks generator progress", T.ACCENT, "fullgenbreak", function(on)
    if on then
        connections["fullgenbreak"] = RunService.Heartbeat:Connect(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("NumberValue") and v.Name == "Progress" and v.Parent and v.Parent:FindFirstChild("Generator") then
                    v.Value = 0
                end
            end
        end)
        notify("Full Gen Break ON")
    else
        clearConn("fullgenbreak")
        notify("Full Gen Break OFF")
    end
end)

makeToggle(sc3, "Anti Blind", "Removes blind/flash effects", T.ACCENT, "antiblind", function(on)
    if on then
        connections["antiblind"] = RunService.Heartbeat:Connect(function()
            for _, v in pairs(lp.PlayerGui:GetDescendants()) do
                if v:IsA("ImageLabel") or v:IsA("Frame") then
                    if v.Name:lower():find("blind") or v.Name:lower():find("flash") or v.Name:lower():find("stun") then
                        v.Visible = false
                    end
                end
            end
            local ce = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
            if ce then ce.Brightness = 0 ce.Contrast = 0 ce.Saturation = 0 end
        end)
        notify("Anti Blind ON")
    else
        clearConn("antiblind")
        notify("Anti Blind OFF")
    end
end)

makeToggle(sc3, "No Slowdown", "Removes post-hit slowdown", T.ACCENT, "noslowdown", function(on)
    if on then
        connections["noslowdown"] = RunService.Heartbeat:Connect(function()
            local hum = getHum()
            if hum then
                if hum.WalkSpeed < 14 then hum.WalkSpeed = states.speedval or 16 end
            end
        end)
        notify("No Slowdown ON")
    else
        clearConn("noslowdown")
        notify("No Slowdown OFF")
    end
end)

makeToggle(sc3, "Infinite Lunge", "Unlimited lunge range/cooldown", T.ACCENT, "influnge", function(on)
    if on then
        connections["influnge"] = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if not char then return end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name == "LungeCooldown" or v.Name == "LungeCD") then
                    v.Value = 0
                end
            end
        end)
        notify("Infinite Lunge ON")
    else
        clearConn("influnge")
        notify("Infinite Lunge OFF")
    end
end)

makeToggle(sc3, "Double Tap", "Instantly downs survivors on hit", T.ACCENT, "doubletap", function(on)
    if on then
        connections["doubletap"] = RunService.Heartbeat:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = getHRP()
                    local phrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and phrp and (phrp.Position - hrp.Position).Magnitude < 8 then
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v:IsA("RemoteEvent") and v.Name:lower():find("hit") then
                                pcall(function() v:FireServer(p.Character) end)
                            end
                        end
                    end
                end
            end
        end)
        notify("Double Tap ON")
    else
        clearConn("doubletap")
        notify("Double Tap OFF")
    end
end)

makeToggle(sc3, "No Pallet Stun", "Removes pallet stun effect", T.ACCENT, "nopalletstun", function(on)
    if on then
        connections["nopalletstun"] = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if not char then return end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BoolValue") and v.Name:lower():find("stun") then
                    v.Value = false
                end
            end
        end)
        notify("No Pallet Stun ON")
    else
        clearConn("nopalletstun")
        notify("No Pallet Stun OFF")
    end
end)

sec(sc3, "CAMERA", T.ACCENT)
makeToggle(sc3, "Shift Lock", "Enables shift-lock camera mode", T.ACCENT, "shiftlock", function(on)
    if on then
        cam.CameraType = Enum.CameraType.Custom
        local ss = game:GetService("StarterGui")
        pcall(function() ss:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
        connections["shiftlock"] = RunService.RenderStepped:Connect(function()
            local hrp = getHRP()
            if hrp then
                local angle = math.atan2(cam.CFrame.LookVector.X, cam.CFrame.LookVector.Z)
                hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, angle, 0)
            end
        end)
        notify("Shift Lock ON")
    else
        clearConn("shiftlock")
        notify("Shift Lock OFF")
    end
end)

makeToggle(sc3, "Third Person", "Forces third-person view", T.ACCENT, "thirdperson", function(on)
    if on then
        lp.CameraMode = Enum.CameraMode.Classic
        cam.CameraType = Enum.CameraType.Custom
        connections["thirdperson"] = RunService.RenderStepped:Connect(function()
            if cam.CameraSubject then
                local cf = cam.CFrame
                local newcf = cf - cf.LookVector * 10
                cam.CFrame = CFrame.new(newcf.Position, cf.Position)
            end
        end)
        notify("Third Person ON")
    else
        clearConn("thirdperson")
        notify("Third Person OFF")
    end
end)

makeToggle(sc3, "Veil Crosshair", "Shows custom crosshair overlay", T.ACCENT, "veilcross", function(on)
    local existing = lpGui:FindFirstChild("VDCrosshair")
    if on then
        if not existing then
            local cg = Instance.new("ScreenGui")
            cg.Name = "VDCrosshair"
            cg.ResetOnSpawn = false
            cg.Parent = lpGui
            local function line(w, h, xo, yo)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(0,w,0,h)
                f.Position = UDim2.new(0.5,xo,0.5,yo)
                f.AnchorPoint = Vector2.new(0.5,0.5)
                f.BackgroundColor3 = Color3.fromRGB(255,255,255)
                f.BorderSizePixel = 0
                f.BackgroundTransparency = 0.2
                f.Parent = cg
            end
            line(12,1,0,0) line(1,12,0,0)
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0,3,0,3)
            dot.Position = UDim2.new(0.5,0,0.5,0)
            dot.AnchorPoint = Vector2.new(0.5,0.5)
            dot.BackgroundColor3 = T.ACCENT
            dot.BorderSizePixel = 0
            dot.Parent = cg
            newCorner(dot, 99)
        end
        notify("Veil Crosshair ON")
    else
        if existing then existing:Destroy() end
        notify("Veil Crosshair OFF")
    end
end)

sec(sc3, "MASK", T.ACCENT)
makeDropdown(sc3, "Select Mask", {"None","Mask A","Mask B","Mask C","Mask D","Custom"}, "selectedmask", function(v)
    notify("Mask selected: "..v)
end)
makeButton(sc3, "▶  Activate Mask", T.ACCENT, function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("mask") then
            pcall(function() v:FireServer("activate", states.selectedmask) end)
        end
    end
    notify("Mask Activated: "..states.selectedmask)
end)
makeButton(sc3, "◼  Deactivate Mask", T.DIM, function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("mask") then
            pcall(function() v:FireServer("deactivate") end)
        end
    end
    notify("Mask Deactivated")
end)

sec(sc3, "HITBOX", T.ACCENT)
makeToggle(sc3, "Hitbox Expander", "Expands hitbox for easier hits", T.ACCENT, "hitboxexp", function(on)
    if on then
        connections["hitboxexp"] = RunService.Heartbeat:Connect(function()
            local sz = states.hitboxsize or 5
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(sz, sz, sz)
                    end
                end
            end
        end)
        notify("Hitbox Expander ON")
    else
        clearConn("hitboxexp")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(2, 2, 1) end
            end
        end
        notify("Hitbox Expander OFF")
    end
end)
makeSlider(sc3, "Hitbox Size", 1, 30, 5, "hitboxsize", T.ACCENT, function(v)
    notify("Hitbox size: "..v)
end)

sec(sc3, "MAP", T.ACCENT)
makeButton(sc3, "💥  Destroy All Pallets", T.ACCENT, function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("pallet") and v:IsA("Model") then
            v:Destroy()
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("pallet") then
            pcall(function() v:FireServer("destroy") end)
        end
    end
    notify("Destroyed all pallets")
end)

spacer(sc3, 4)

local sc4 = getSc("fling")
sec(sc4, "FLING", T.PURPLE)
makeButton(sc4, "▶  Fling Nearest", T.PURPLE, function()
    local hrp = getHRP()
    if not hrp then notify("No character found") return end
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then nearest = p dist = d end
        end
    end
    if nearest then
        local nhrp = nearest.Character:FindFirstChild("HumanoidRootPart")
        if nhrp then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(math.random(-1,1)*states.flingstr, states.flingstr, math.random(-1,1)*states.flingstr)
            bv.MaxForce = Vector3.new(1e9,1e9,1e9)
            bv.Parent = nhrp
            game:GetService("Debris"):AddItem(bv, 0.15)
            notify("Flung: "..nearest.Name)
        end
    end
end)

makeButton(sc4, "▶  Fling All", T.PURPLE, function()
    local whitelist = {}
    for w in (states.flingwhitelist or ""):gmatch("[^,]+") do
        whitelist[w:match("^%s*(.-)%s*$")] = true
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and not whitelist[p.Name] and p.Character then
            local nhrp = p.Character:FindFirstChild("HumanoidRootPart")
            if nhrp then
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(math.random(-1,1)*states.flingstr, states.flingstr, math.random(-1,1)*states.flingstr)
                bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                bv.Parent = nhrp
                game:GetService("Debris"):AddItem(bv, 0.15)
            end
        end
    end
    notify("Flung all (excluding whitelist)")
end)

makeSlider(sc4, "Fling Strength", 1, 2000, 200, "flingstr", T.PURPLE, function(v)
    notify("Fling strength: "..v)
end)
makeInput(sc4, "Fling All Whitelist", "Player1, Player2...", "flingwhitelist")
spacer(sc4, 4)

local sc5 = getSc("sound")
sec(sc5, "SOUND PLAYER", T.GREEN)
local _, soundInputBox = makeInput(sc5, "Sound ID", "rbxassetid://123456789", "soundid")
makeSlider(sc5, "Sound Distance", 1, 1000, 100, "sounddist", T.GREEN, nil)
makeSlider(sc5, "Sound Volume", 0, 10, 5, "soundvol", T.GREEN, nil)
makeButton(sc5, "▶  Play Sound", T.GREEN, function()
    local existing = Workspace:FindFirstChild("VDSound")
    if existing then existing:Destroy() end
    local snd = Instance.new("Sound")
    snd.Name = "VDSound"
    local sid = states.soundid or ""
    if not sid:find("rbxassetid") then sid = "rbxassetid://"..sid end
    snd.SoundId = sid
    snd.RollOffMaxDistance = states.sounddist or 100
    snd.Volume = (states.soundvol or 5) / 10 * 2
    snd.Parent = Workspace
    snd:Play()
    notify("Playing sound: "..states.soundid)
end)
makeButton(sc5, "■  Stop Sound", T.DIM, function()
    local snd = Workspace:FindFirstChild("VDSound")
    if snd then snd:Destroy() end
    notify("Sound stopped")
end)
spacer(sc5, 4)

local sc6 = getSc("emotes")
sec(sc6, "EMOTES", T.ORANGE)
makeDropdown(sc6, "Select Emote", {
    "Wave","Dance","Dance2","Dance3","Laugh","Cheer","Cry","Point",
    "Salute","Shrug","Stadium","Tilt","Wave2","Zombie"
}, "selectedemote", function(v) notify("Emote selected: "..v) end)
makeButton(sc6, "▶  Play Emote", T.ORANGE, function()
    local anim = Instance.new("Animation")
    local emoteIds = {
        Wave="rbxassetid://507770239", Dance="rbxassetid://507771019",
        Dance2="rbxassetid://507776043", Dance3="rbxassetid://507777268",
        Laugh="rbxassetid://507770818", Cheer="rbxassetid://507770453",
        Cry="rbxassetid://501694108", Point="rbxassetid://507770453",
        Salute="rbxassetid://3360689775", Shrug="rbxassetid://3360692915",
    }
    local id = emoteIds[states.selectedemote] or "rbxassetid://507770239"
    anim.AnimationId = id
    local hum = getHum()
    if hum then
        local track = hum:LoadAnimation(anim)
        track:Play()
        notify("Playing emote: "..states.selectedemote)
    end
end)
spacer(sc6, 4)

local sc7 = getSc("player")
sec(sc7, "SPEED", T.BLUE)
makeToggle(sc7, "Speed Boost", "Activates custom walk speed", T.BLUE, "speedboost", function(on)
    local hum = getHum()
    if hum then hum.WalkSpeed = on and states.speedval or 16 end
    notify(on and ("Speed: "..states.speedval) or "Speed reset")
end)

makeSlider(sc7, "Speed Value", 1, 300, 16, "speedval", T.BLUE, function(v)
    if states.speedboost then
        local hum = getHum()
        if hum then hum.WalkSpeed = v end
    end
end)

makeDropdown(sc7, "Speed Method", {"Attribute","TP (Teleport)","BodyVelocity"}, "speedmethod", function(v)
    notify("Speed method: "..v)
end)

makeInput(sc7, "Speed Keybind", "e.g. E", "speedkeystr", function(v)
    local key = Enum.KeyCode[v:upper()]
    if key then
        states.speedkey = key
        notify("Speed keybind: "..v)
    end
end)

sec(sc7, "PHYSICS", T.BLUE)
makeSlider(sc7, "Jump Power", 1, 500, 50, "jumppower", T.BLUE, function(v)
    local hum = getHum()
    if hum then hum.JumpPower = v end
end)

makeSlider(sc7, "Hip Height", 0, 20, 0, "hipheight", T.BLUE, function(v)
    local hum = getHum()
    if hum then hum.HipHeight = v end
end)

makeToggle(sc7, "Infinite Jump", "Jump infinitely in the air", T.BLUE, "infinitejump", function(on)
    clearConn("infinitejump")
    if on then
        connections["infinitejump"] = UserInputService.JumpRequest:Connect(function()
            local hum = getHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        notify("Infinite Jump ON")
    else
        notify("Infinite Jump OFF")
    end
end)

makeToggle(sc7, "Freeze Self", "Freezes your character", T.BLUE, "freezeself", function(on)
    local hrp = getHRP()
    if hrp then
        hrp.Anchored = on
    end
    notify(on and "Frozen" or "Unfreeze")
end)

sec(sc7, "CAMERA", T.BLUE)
makeSlider(sc7, "FOV Changer", 30, 140, 70, "fov", T.BLUE, function(v)
    cam.FieldOfView = v
end)

sec(sc7, "FLY", T.BLUE)
makeToggle(sc7, "Noclip", "Walk through all objects", T.BLUE, "noclip", function(on)
    clearConn("noclip")
    if on then
        connections["noclip"] = RunService.Stepped:Connect(function()
            local char = getChar()
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
        notify("Noclip ON")
    else
        local char = getChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
        notify("Noclip OFF")
    end
end)

local flyBV, flyBG
makeToggle(sc7, "Fly", "Enables flight mode", T.BLUE, "fly", function(on)
    clearConn("fly")
    if on then
        local hrp = getHRP()
        if not hrp then return end
        flyBV = Instance.new("BodyVelocity")
        flyBV.Velocity = Vector3.zero
        flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
        flyBG.D = 100
        flyBG.Parent = hrp
        connections["fly"] = RunService.Heartbeat:Connect(function()
            if not states.fly then return end
            local hrp2 = getHRP()
            if not hrp2 then return end
            local spd = states.flyspeed or 50
            local v = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0,1,0) end
            if flyBV and flyBV.Parent then flyBV.Velocity = v.Magnitude > 0 and v.Unit * spd or Vector3.zero end
            if flyBG and flyBG.Parent then flyBG.CFrame = cam.CFrame end
        end)
        notify("Fly ON")
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        notify("Fly OFF")
    end
end)

makeDropdown(sc7, "Fly Mode", {"Velocity","CFrame"}, "flymode", function(v) notify("Fly mode: "..v) end)
makeSlider(sc7, "Fly Speed", 1, 500, 50, "flyspeed", T.BLUE, function(v)
    notify("Fly speed: "..v)
end)

spacer(sc7, 4)

local sc8 = getSc("esp")
sec(sc8, "PLAYER ESP", T.CYAN)
makeToggle(sc8, "Toggle ESP (Master)", "Enables all ESP features", T.CYAN, "toggleesp", function(on)
    if not on then
        for _, e in pairs(espObjects) do
            if e and e.Parent then e:Destroy() end
        end
        espObjects = {}
        clearConn("esp")
    else
        notify("ESP ON - configure options below")
    end
end)

makeToggle(sc8, "2D Boxes", nil, T.CYAN, "player2dbox")
makeToggle(sc8, "3D Boxes", nil, T.CYAN, "player3dbox")
makeToggle(sc8, "Show Names", nil, T.CYAN, "shownames")
makeToggle(sc8, "Show Distance", nil, T.CYAN, "showdist")
makeToggle(sc8, "Show Weapon", nil, T.CYAN, "showweapon")
makeToggle(sc8, "Health Bars", nil, T.CYAN, "healthbars")
makeToggle(sc8, "Health Text", nil, T.CYAN, "healthtext")
makeToggle(sc8, "Tracers", nil, T.CYAN, "tracers")
makeToggle(sc8, "Highlights", nil, T.CYAN, "highlights")
makeToggle(sc8, "Off-Screen Arrows", nil, T.CYAN, "offscrenarrows")

sec(sc8, "INSTANCE ESP", T.CYAN)
makeToggle(sc8, "Generator ESP", nil, T.CYAN, "genesp")
makeToggle(sc8, "Hook ESP", nil, T.CYAN, "hookesp")
makeToggle(sc8, "Vault ESP", nil, T.CYAN, "vaultesp")
makeToggle(sc8, "Pallet ESP", nil, T.CYAN, "palletesp")
makeToggle(sc8, "Gate ESP", nil, T.CYAN, "gateesp")

sec(sc8, "INSTANCE BOX SETTINGS", T.CYAN)
makeToggle(sc8, "2D Boxes (Instance)", nil, T.CYAN, "inst2dbox")
makeToggle(sc8, "3D Boxes (Instance)", nil, T.CYAN, "inst3dbox")
makeToggle(sc8, "Show Names (Instance)", nil, T.CYAN, "instnames")
makeToggle(sc8, "Show Distance (Instance)", nil, T.CYAN, "instdist")
makeToggle(sc8, "Tracers (Instance)", nil, T.CYAN, "insttracers")
makeToggle(sc8, "Highlights (Instance)", nil, T.CYAN, "insthighlights")
makeToggle(sc8, "Off-Screen Arrows (Instance)", nil, T.CYAN, "instarrows")

sec(sc8, "GLOBAL ESP SETTINGS", T.CYAN)
makeToggle(sc8, "Team Color", nil, T.CYAN, "teamcolor")
makeToggle(sc8, "Show Teammates", nil, T.CYAN, "showteam")
makeSlider(sc8, "Line Thickness", 1, 10, 1, "linethick", T.CYAN, nil)
makeSlider(sc8, "Highlight Distance", 10, 5000, 500, "highldist", T.CYAN, nil)
makeSlider(sc8, "Highlight Budget", 1, 500, 100, "highlightbudget", T.CYAN, nil)
makeSlider(sc8, "Fill Transparency", 0, 10, 8, "filltrans", T.CYAN, nil)
makeSlider(sc8, "Outline Transparency", 0, 10, 0, "outlinetrans", T.CYAN, nil)
makeSlider(sc8, "Arrow Size", 1, 50, 10, "arrowsize", T.CYAN, nil)
makeSlider(sc8, "Arrow Radius", 50, 600, 200, "arrowradius", T.CYAN, nil)
makeSlider(sc8, "ESP Update Interval", 1, 60, 10, "espupdate", T.CYAN, nil)
makeSlider(sc8, "ESP Check Interval", 1, 60, 5, "espcheck", T.CYAN, nil)

RunService.Heartbeat:Connect(function()
    if not states.toggleesp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        if not p.Character then continue end
        local char = p.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp then continue end

        local playerGui = lp.PlayerGui

        if states.shownames or states.showdist then
            local lbl = playerGui:FindFirstChild("ESP_"..p.UserId.."_name")
            if not lbl then
                local sg = Instance.new("BillboardGui")
                sg.Name = "ESP_"..p.UserId.."_name"
                sg.Size = UDim2.new(0,200,0,50)
                sg.StudsOffset = Vector3.new(0,3,0)
                sg.AlwaysOnTop = true
                sg.Parent = hrp
                espObjects["name_"..p.UserId] = sg
                local t = Instance.new("TextLabel")
                t.Name = "lbl"
                t.Size = UDim2.new(1,0,1,0)
                t.BackgroundTransparency = 1
                t.TextColor3 = states.teamcolor and lp.TeamColor.Color or T.CYAN
                t.Font = Enum.Font.GothamBold
                t.TextSize = 12
                t.Text = ""
                t.Parent = sg
            end
            local sg = hrp:FindFirstChild("ESP_"..p.UserId.."_name")
            if sg then
                local t = sg:FindFirstChild("lbl")
                if t then
                    local dist = math.round((hrp.Position - getHRP().Position).Magnitude)
                    t.Text = (states.shownames and p.Name or "")..(states.showdist and (" ["..dist.."m]") or "")
                end
            end
        end

        if states.highlights then
            local hl = char:FindFirstChild("VD_ESP_Highlight")
            if not hl then
                hl = Instance.new("SelectionBox")
                hl.Name = "VD_ESP_Highlight"
                hl.Adornee = char
                hl.Color3 = T.CYAN
                hl.LineThickness = states.linethick / 10
                hl.SurfaceTransparency = states.filltrans / 10
                hl.SurfaceColor3 = T.CYAN
                hl.Parent = char
                espObjects["hl_"..p.UserId] = hl
            end
        else
            local hl = char:FindFirstChild("VD_ESP_Highlight")
            if hl then hl:Destroy() end
        end
    end
end)

spacer(sc8, 4)

local sc9 = getSc("visuals")
sec(sc9, "SHADERS / AMBIENCE", T.PINK)
makeToggle(sc9, "Ambience Override", "Enables custom ambience", T.PINK, "ambience", function(on)
    if on then
        local ca = Instance.new("ColorCorrectionEffect")
        ca.Name = "VD_Ambience"
        ca.Parent = Lighting
    else
        local ca = Lighting:FindFirstChild("VD_Ambience")
        if ca then ca:Destroy() end
    end
    notify(on and "Ambience ON" or "Ambience OFF")
end)

makeToggle(sc9, "Force Time of Day", "Locks the game time", T.PINK, "forcetime", function(on)
    if on then
        connections["forcetime"] = RunService.Heartbeat:Connect(function()
            Lighting.TimeOfDay = string.format("%02d:00:00", states.timeval or 12)
        end)
        notify("Force Time ON")
    else
        clearConn("forcetime")
        notify("Force Time OFF")
    end
end)

makeSlider(sc9, "Time Slider (0-23h)", 0, 23, 12, "timeval", T.PINK, function(v)
    if states.forcetime then
        Lighting.TimeOfDay = string.format("%02d:00:00", v)
    end
end)

makeToggle(sc9, "Custom Saturation", "Applies color saturation", T.PINK, "custsat", function(on)
    local ce = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
    if on then
        ce.Saturation = (states.satval or 5) / 5 - 1
        notify("Custom Saturation ON")
    else
        ce.Saturation = 0
        notify("Custom Saturation OFF")
    end
end)

makeSlider(sc9, "Saturation", 0, 10, 5, "satval", T.PINK, function(v)
    if states.custsat then
        local ce = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if ce then ce.Saturation = v / 5 - 1 end
    end
end)

local _, skyboxInput = makeInput(sc9, "Skybox Changer (Asset ID)", "rbxassetid://...", "skyboxid", function(v)
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then sky = Instance.new("Sky", Lighting) end
    local id = v:find("rbxassetid") and v or "rbxassetid://"..v
    sky.SkyboxBk = id sky.SkyboxDn = id sky.SkyboxFt = id
    sky.SkyboxLf = id sky.SkyboxRt = id sky.SkyboxUp = id
    notify("Skybox applied")
end)

sec(sc9, "BODY MODIFIER", T.PINK)
makeDropdown(sc9, "Material Select", {
    "SmoothPlastic","Neon","Glass","Metal","Wood",
    "DiamondPlate","Foil","Brick","Marble","Slate"
}, "materialsel", function(v)
    local char = getChar()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            pcall(function() p.Material = Enum.Material[v] end)
        end
    end
    notify("Material: "..v)
end)

makeInput(sc9, "Material Color (R,G,B)", "255, 100, 100", "matcolorstr", function(v)
    local r,g,b = v:match("(%d+),%s*(%d+),%s*(%d+)")
    if r then
        local col = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        local char = getChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.BrickColor = BrickColor.new(col)
                end
            end
        end
        notify("Material color applied")
    end
end)

makeButton(sc9, "↺  Reset Character Appearance", T.DIM, function()
    local char = getChar()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.Material = Enum.Material.SmoothPlastic end)
            p.Transparency = 0
        end
    end
    notify("Appearance reset")
end)

spacer(sc9, 4)

local sc10 = getSc("aimbot")
sec(sc10, "SPEAR AIMBOT", T.ACCENT)
makeToggle(sc10, "Spear Aimbot", "Auto-aims spear at closest target", T.ACCENT, "spearaimbot", function(on)
    clearConn("spearaimbot")
    if on then
        connections["spearaimbot"] = RunService.RenderStepped:Connect(function()
            if not states.spearaimbot then return end
            if not UserInputService:IsKeyDown(states.spearkey or Enum.KeyCode.E) then return end
            local hrp = getHRP()
            if not hrp then return end
            local nearest, dist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < dist then nearest = p dist = d end
                end
            end
            if nearest then
                local targetPos = nearest.Character.HumanoidRootPart.Position
                local travelTime = dist / (states.spearspeed or 150)
                local grav = Vector3.new(0, -states.speargrav or -60, 0)
                local predictedPos = targetPos + nearest.Character.HumanoidRootPart.Velocity * travelTime
                local aimPos = predictedPos - grav * travelTime * travelTime * 0.5
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, aimPos)
            end
        end)
        notify("Spear Aimbot ON")
    else
        notify("Spear Aimbot OFF")
    end
end)

makeInput(sc10, "Spear Aim Key", "E", "spearkeystr", function(v)
    local key = Enum.KeyCode[v:upper()]
    if key then states.spearkey = key notify("Spear key: "..v) end
end)
makeSlider(sc10, "Spear Gravity", 0, 300, 60, "speargrav", T.ACCENT, nil)
makeSlider(sc10, "Spear Projectile Speed", 10, 1000, 150, "spearspeed", T.ACCENT, nil)
makeButton(sc10, "🎯  Spear Aim Button (MOBILE)", T.ACCENT, function()
    notify("Spear aimed at nearest target")
    local hrp = getHRP()
    if not hrp then return end
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then nearest = p dist = d end
        end
    end
    if nearest then
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, nearest.Character.HumanoidRootPart.Position)
    end
end)

makeToggle(sc10, "Lock Spear Target", "Continuously locks aim on target", T.ACCENT, "lockspear", function(on)
    clearConn("lockspear")
    if on then
        connections["lockspear"] = RunService.RenderStepped:Connect(function()
            local hrp = getHRP()
            if not hrp then return end
            local nearest, dist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < dist then nearest = p dist = d end
                end
            end
            if nearest then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, nearest.Character.HumanoidRootPart.Position)
            end
        end)
        notify("Spear Lock ON")
    else
        notify("Spear Lock OFF")
    end
end)
makeSlider(sc10, "Spear Button Size", 20, 200, 80, "spearbtnsz", T.ACCENT, nil)

sec(sc10, "GUN SILENT AIM", T.ACCENT)
makeToggle(sc10, "Gun Silent Aim", "Redirects bullets to target body part", T.ACCENT, "gunsilent", function(on)
    clearConn("gunsilent")
    if on then
        local mt = getrawmetatable and getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            local newNamecall = newcclosure and newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    local args = {...}
                    local hrp = getHRP()
                    if hrp then
                        local nearest, dist = nil, math.huge
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= lp and p.Character and p.Character:FindFirstChild(states.silentpart) then
                                local d = (p.Character[states.silentpart].Position - hrp.Position).Magnitude
                                if d < dist then nearest = p dist = d end
                            end
                        end
                        if nearest and nearest.Character:FindFirstChild(states.silentpart) then
                            for i, v in pairs(args) do
                                if typeof(v) == "Vector3" then
                                    args[i] = nearest.Character[states.silentpart].Position
                                end
                                if typeof(v) == "CFrame" then
                                    args[i] = nearest.Character[states.silentpart].CFrame
                                end
                            end
                        end
                    end
                    return oldNamecall(self, table.unpack(args))
                end
                return oldNamecall(self, ...)
            end) or function(self, ...) return oldNamecall(self, ...) end
            if setreadonly then setreadonly(mt, false) end
            mt.__namecall = newNamecall
            if setreadonly then setreadonly(mt, true) end
        end
        notify("Gun Silent Aim ON")
    else
        notify("Gun Silent Aim OFF - restart required to fully disable")
    end
end)

makeDropdown(sc10, "Silent Aim Part", {
    "Head","HumanoidRootPart","UpperTorso","Torso","LowerTorso"
}, "silentpart", function(v) notify("Silent aim part: "..v) end)

spacer(sc10, 4)

UserInputService.JumpRequest:Connect(function()
    if states.infinitejump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    if states.noclip then
        connections["noclip"] = RunService.Stepped:Connect(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
    if states.freezeself then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = true end
    end
    if states.speedboost then hum.WalkSpeed = states.speedval end
    if states.jumppower then hum.JumpPower = states.jumppower end
    if states.hipheight then hum.HipHeight = states.hipheight end
    if states.fov then cam.FieldOfView = states.fov end
end)

allTabs["main"].btn.MouseButton1Click:Fire()

tw(Main, {BackgroundTransparency=0}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

print("[Violence District GUI v1.3] Loaded — "..#tabDefs.." tabs, full feature set active")
