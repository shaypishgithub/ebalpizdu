local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local lpGui = lp:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

local C = {
    BG      = Color3.fromRGB(12, 11, 16),
    PANEL   = Color3.fromRGB(18, 17, 23),
    CARD    = Color3.fromRGB(24, 23, 31),
    CARDH   = Color3.fromRGB(32, 30, 42),
    SIDE    = Color3.fromRGB(15, 14, 20),
    BORDER  = Color3.fromRGB(44, 42, 58),
    RED     = Color3.fromRGB(218, 45, 60),
    RED2    = Color3.fromRGB(255, 80, 95),
    CYAN    = Color3.fromRGB(45, 195, 210),
    GOLD    = Color3.fromRGB(255, 188, 65),
    GREEN   = Color3.fromRGB(55, 210, 115),
    PURPLE  = Color3.fromRGB(185, 125, 255),
    ORANGE  = Color3.fromRGB(255, 165, 55),
    BLUE    = Color3.fromRGB(95, 155, 255),
    PINK    = Color3.fromRGB(255, 115, 190),
    TEXT    = Color3.fromRGB(220, 218, 228),
    DIM     = Color3.fromRGB(110, 106, 130),
    OFF     = Color3.fromRGB(38, 36, 50),
    SCROLL  = Color3.fromRGB(50, 48, 64),
}

local TI  = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TIS = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local states = {}
local conns  = {}

local function tw(o, p, i) TweenService:Create(o, i or TI, p):Play() end
local function co(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 6) c.Parent = p end
local function st(p, col, th) local s = Instance.new("UIStroke") s.Color = col or C.BORDER s.Thickness = th or 1 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Parent = p end
local function pd(p, a) local u = Instance.new("UIPadding") u.PaddingTop = UDim.new(0,a) u.PaddingBottom = UDim.new(0,a) u.PaddingLeft = UDim.new(0,a) u.PaddingRight = UDim.new(0,a) u.Parent = p end
local function ll(p, sp) local l = Instance.new("UIListLayout") l.SortOrder = Enum.SortOrder.LayoutOrder l.Padding = UDim.new(0, sp or 4) l.Parent = p end
local function lbl(p, t, s, col, f) local l = Instance.new("TextLabel") l.BackgroundTransparency = 1 l.Text = t l.TextSize = s or 12 l.TextColor3 = col or C.TEXT l.Font = f or Enum.Font.Gotham l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = p return l end
local function getChar() return lp.Character end
local function getHRP() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function clrConn(k) if conns[k] then conns[k]:Disconnect() conns[k] = nil end end

local Root = Instance.new("ScreenGui")
Root.Name = "VD_GUI"
Root.ResetOnSpawn = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.IgnoreGuiInset = true
Root.DisplayOrder = 99
Root.Parent = lpGui

local WIN_W, WIN_H = 520, 400

local Win = Instance.new("Frame")
Win.Name = "Win"
Win.Size = UDim2.new(0, WIN_W, 0, WIN_H)
Win.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Win.BackgroundColor3 = C.BG
Win.BorderSizePixel = 0
Win.ClipsDescendants = true
Win.Parent = Root
co(Win, 10)
st(Win, C.BORDER, 1)

local dragActive = false
local dragStart, winStart

Win.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStart = i.Position
        winStart = Win.Position
    end
end)
Win.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragActive = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragActive and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        Win.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + delta.X,
            winStart.Y.Scale, winStart.Y.Offset + delta.Y
        )
    end
end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BackgroundColor3 = C.SIDE
TopBar.BorderSizePixel = 0
TopBar.Parent = Win

local AccLine = Instance.new("Frame")
AccLine.Size = UDim2.new(1, 0, 0, 2)
AccLine.Position = UDim2.new(0, 0, 1, -2)
AccLine.BackgroundColor3 = C.RED
AccLine.BorderSizePixel = 0
AccLine.Parent = TopBar

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 6, 0, 6)
Dot.Position = UDim2.new(0, 12, 0.5, -3)
Dot.BackgroundColor3 = C.RED
Dot.BorderSizePixel = 0
Dot.Parent = TopBar
co(Dot, 99)
TweenService:Create(Dot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency=0.7}):Play()

local TitleL = lbl(TopBar, "Violence District", 13, C.TEXT, Enum.Font.GothamBold)
TitleL.Size = UDim2.new(0, 170, 1, 0)
TitleL.Position = UDim2.new(0, 24, 0, 0)

local VBadge = Instance.new("Frame")
VBadge.Size = UDim2.new(0, 36, 0, 15)
VBadge.Position = UDim2.new(0, 162, 0.5, -7)
VBadge.BackgroundColor3 = C.RED
VBadge.BorderSizePixel = 0
VBadge.Parent = TopBar
co(VBadge, 4)
local VL = lbl(VBadge, "v1.3", 9, Color3.new(1,1,1), Enum.Font.GothamBold)
VL.Size = UDim2.new(1,0,1,0)
VL.TextXAlignment = Enum.TextXAlignment.Center

local function topBtn(xOff, col)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,11,0,11)
    f.Position = UDim2.new(1, xOff, 0.5, -5)
    f.BackgroundColor3 = col
    f.BorderSizePixel = 0
    f.Parent = TopBar
    co(f, 99)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.Parent = f
    b.MouseEnter:Connect(function() tw(f, {BackgroundColor3=Color3.new(1,1,1)}) end)
    b.MouseLeave:Connect(function() tw(f, {BackgroundColor3=col}) end)
    return b
end

local btnClose = topBtn(-14, Color3.fromRGB(218,55,65))
local btnMin   = topBtn(-30, Color3.fromRGB(240,178,48))
btnClose.MouseButton1Click:Connect(function() Root:Destroy() end)

local isMin = false
btnMin.MouseButton1Click:Connect(function()
    isMin = not isMin
    tw(Win, {Size = isMin and UDim2.new(0,WIN_W,0,34) or UDim2.new(0,WIN_W,0,WIN_H)}, TIS)
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -34)
Sidebar.Position = UDim2.new(0, 0, 0, 34)
Sidebar.BackgroundColor3 = C.SIDE
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Win

local SDiv = Instance.new("Frame")
SDiv.Size = UDim2.new(0,1,1,0)
SDiv.Position = UDim2.new(1,-1,0,0)
SDiv.BackgroundColor3 = C.BORDER
SDiv.BorderSizePixel = 0
SDiv.Parent = Sidebar

local SScroll = Instance.new("ScrollingFrame")
SScroll.Size = UDim2.new(1,-6,1,-6)
SScroll.Position = UDim2.new(0,3,0,3)
SScroll.BackgroundTransparency = 1
SScroll.ScrollBarThickness = 2
SScroll.ScrollBarImageColor3 = C.SCROLL
SScroll.CanvasSize = UDim2.new(0,0,0,0)
SScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SScroll.BorderSizePixel = 0
SScroll.Parent = Sidebar
ll(SScroll, 2)
pd(SScroll, 4)

local CArea = Instance.new("Frame")
CArea.Size = UDim2.new(1,-110,1,-34)
CArea.Position = UDim2.new(0,110,0,34)
CArea.BackgroundColor3 = C.PANEL
CArea.BorderSizePixel = 0
CArea.ClipsDescendants = true
CArea.Parent = Win

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 18, 0, 56)
ToggleBtn.Position = UDim2.new(0, -18, 0.5, -28)
ToggleBtn.AnchorPoint = Vector2.new(0, 0)
ToggleBtn.BackgroundColor3 = C.RED
ToggleBtn.Text = ""
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = Win
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0,6)
tc.Parent = ToggleBtn

local TArrow = lbl(ToggleBtn, "◀", 10, Color3.new(1,1,1), Enum.Font.GothamBold)
TArrow.Size = UDim2.new(1,0,1,0)
TArrow.TextXAlignment = Enum.TextXAlignment.Center
TArrow.ZIndex = 11

local isOpen = true
ToggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    if isOpen then
        tw(Win, {Size=UDim2.new(0,WIN_W,0,isMin and 34 or WIN_H)}, TIS)
        TArrow.Text = "◀"
    else
        tw(Win, {Size=UDim2.new(0,18,0,56)}, TIS)
        TArrow.Text = "▶"
    end
    Sidebar.Visible = isOpen
    CArea.Visible = isOpen
    TopBar.Visible = isOpen
end)

local tabs, pages = {}, {}
local tabDefs = {
    {k="main",     n="MAIN",     ic="◈", col=C.GOLD},
    {k="survivor", n="SURVIVOR", ic="⬡", col=C.CYAN},
    {k="killer",   n="KILLER",   ic="◆", col=C.RED},
    {k="fling",    n="FLING",    ic="◉", col=C.PURPLE},
    {k="sound",    n="SOUND",    ic="◎", col=C.GREEN},
    {k="emotes",   n="EMOTES",   ic="◇", col=C.ORANGE},
    {k="player",   n="PLAYER",   ic="○", col=C.BLUE},
    {k="esp",      n="ESP",      ic="◐", col=C.CYAN},
    {k="visuals",  n="VISUALS",  ic="◑", col=C.PINK},
    {k="aimbot",   n="AIMBOT",   ic="◎", col=C.RED},
}

for i, def in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,27)
    btn.BackgroundColor3 = C.SIDE
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.Parent = SScroll
    co(btn, 5)

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0,2,0.6,0)
    ind.Position = UDim2.new(0,0,0.2,0)
    ind.BackgroundColor3 = def.col
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.Parent = btn
    co(ind, 2)

    local icL = lbl(btn, def.ic, 10, C.DIM, Enum.Font.GothamBold)
    icL.Size = UDim2.new(0,18,1,0)
    icL.Position = UDim2.new(0,7,0,0)
    icL.TextXAlignment = Enum.TextXAlignment.Center

    local nmL = lbl(btn, def.n, 10, C.DIM, Enum.Font.Gotham)
    nmL.Size = UDim2.new(1,-30,1,0)
    nmL.Position = UDim2.new(0,28,0,0)

    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1,0,1,0)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 3
    sc.ScrollBarImageColor3 = C.SCROLL
    sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.BorderSizePixel = 0
    sc.Visible = false
    sc.Parent = CArea
    ll(sc, 0)
    local p2 = Instance.new("UIPadding")
    p2.PaddingTop = UDim.new(0,7)
    p2.PaddingBottom = UDim.new(0,7)
    p2.PaddingLeft = UDim.new(0,8)
    p2.PaddingRight = UDim.new(0,8)
    p2.Parent = sc

    tabs[def.k] = {btn=btn, ind=ind, icL=icL, nmL=nmL, sc=sc, col=def.col}
    pages[def.k] = sc

    btn.MouseButton1Click:Connect(function()
        for k, t in pairs(tabs) do
            local a = k==def.k
            t.sc.Visible = a
            tw(t.btn, {BackgroundColor3 = a and C.CARD or C.SIDE})
            tw(t.ind, {BackgroundTransparency = a and 0 or 1})
            tw(t.nmL, {TextColor3 = a and t.col or C.DIM})
            tw(t.icL, {TextColor3 = a and t.col or C.DIM})
        end
    end)
end

local function g(k) return pages[k] end

local function sec(p, t, col)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,20)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = p
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1,0,0,1)
    ln.Position = UDim2.new(0,0,0.5,0)
    ln.BackgroundColor3 = C.BORDER
    ln.BorderSizePixel = 0
    ln.Parent = f
    local l = lbl(f, "  "..t.."  ", 9, col or C.GOLD, Enum.Font.GothamBold)
    l.Size = UDim2.new(0,0,1,0)
    l.AutomaticSize = Enum.AutomaticSize.X
    l.Position = UDim2.new(0,2,0,0)
    l.BackgroundColor3 = C.PANEL
    local lp2 = Instance.new("UIPadding") lp2.PaddingLeft=UDim.new(0,2) lp2.PaddingRight=UDim.new(0,2) lp2.Parent = l
end

local function tog(p, t, sub, col, key, cb)
    local on = states[key] or false
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,sub and 44 or 32)
    f.BackgroundColor3 = C.CARD
    f.BorderSizePixel = 0
    f.Parent = p
    co(f, 5)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,2,0.55,0)
    bar.Position = UDim2.new(0,0,0.225,0)
    bar.BackgroundColor3 = col or C.BORDER
    bar.BorderSizePixel = 0
    bar.Parent = f
    co(bar, 2)

    local ml = lbl(f, t, 11, C.TEXT, Enum.Font.Gotham)
    ml.Size = UDim2.new(1,-52,0,16)
    ml.Position = UDim2.new(0,10,0,sub and 6 or 8)

    if sub then
        local sl = lbl(f, sub, 9, C.DIM, Enum.Font.Gotham)
        sl.Size = UDim2.new(1,-52,0,13)
        sl.Position = UDim2.new(0,10,0,23)
    end

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(0,30,0,15)
    tr.Position = UDim2.new(1,-40,0.5,-7)
    tr.BackgroundColor3 = on and C.GREEN or C.OFF
    tr.BorderSizePixel = 0
    tr.Parent = f
    co(tr, 99)
    st(tr, C.BORDER, 1)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0,9,0,9)
    kn.Position = on and UDim2.new(0,18,0.5,-4) or UDim2.new(0,2,0.5,-4)
    kn.BackgroundColor3 = on and Color3.new(1,1,1) or C.DIM
    kn.BorderSizePixel = 0
    kn.Parent = tr
    co(kn, 99)

    local cb2 = Instance.new("TextButton")
    cb2.Size = UDim2.new(1,0,1,0)
    cb2.BackgroundTransparency = 1
    cb2.Text = ""
    cb2.Parent = f

    cb2.MouseButton1Click:Connect(function()
        on = not on
        states[key] = on
        tw(tr, {BackgroundColor3 = on and C.GREEN or C.OFF})
        tw(kn, {Position = on and UDim2.new(0,18,0.5,-4) or UDim2.new(0,2,0.5,-4)})
        tw(kn, {BackgroundColor3 = on and Color3.new(1,1,1) or C.DIM})
        if cb then cb(on) end
    end)

    f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
    return f
end

local function sld(p, t, mn, mx, def, key, col, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,46)
    f.BackgroundColor3 = C.CARD
    f.BorderSizePixel = 0
    f.Parent = p
    co(f, 5)

    local ml = lbl(f, t, 11, C.TEXT, Enum.Font.Gotham)
    ml.Size = UDim2.new(0.65,0,0,15)
    ml.Position = UDim2.new(0,10,0,5)

    local vl = lbl(f, tostring(def), 11, col or C.RED2, Enum.Font.GothamBold)
    vl.Size = UDim2.new(0.32,0,0,15)
    vl.Position = UDim2.new(0.66,0,0,5)
    vl.TextXAlignment = Enum.TextXAlignment.Right

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(1,-20,0,3)
    tr.Position = UDim2.new(0,10,0,30)
    tr.BackgroundColor3 = C.OFF
    tr.BorderSizePixel = 0
    tr.Parent = f
    co(tr, 99)

    local pct = (def-mn)/(mx-mn)
    local fi = Instance.new("Frame")
    fi.Size = UDim2.new(pct,0,1,0)
    fi.BackgroundColor3 = col or C.RED
    fi.BorderSizePixel = 0
    fi.Parent = tr
    co(fi, 99)

    local th = Instance.new("Frame")
    th.Size = UDim2.new(0,9,0,9)
    th.AnchorPoint = Vector2.new(0.5,0.5)
    th.Position = UDim2.new(pct,0,0.5,0)
    th.BackgroundColor3 = Color3.new(1,1,1)
    th.BorderSizePixel = 0
    th.Parent = tr
    co(th, 99)

    local drag = false
    local function upd(x)
        local a = tr.AbsolutePosition.X
        local s = tr.AbsoluteSize.X
        local pp = math.clamp((x-a)/s,0,1)
        local v = math.round(mn+(mx-mn)*pp)
        tw(fi, {Size=UDim2.new(pp,0,1,0)})
        th.Position = UDim2.new(pp,0,0.5,0)
        vl.Text = tostring(v)
        states[key] = v
        if cb then cb(v) end
    end
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true upd(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)

    f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
    return f
end

local function btn(p, t, col, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,30)
    f.BackgroundColor3 = C.CARD
    f.BorderSizePixel = 0
    f.Parent = p
    co(f, 5)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,2,0.55,0)
    bar.Position = UDim2.new(0,0,0.225,0)
    bar.BackgroundColor3 = col or C.RED
    bar.BorderSizePixel = 0
    bar.Parent = f
    co(bar, 2)

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-16,0,20)
    b.Position = UDim2.new(0,10,0.5,-10)
    b.BackgroundColor3 = col or C.RED
    b.BackgroundTransparency = 0.84
    b.Text = t
    b.TextColor3 = col or C.RED2
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.Parent = f
    co(b, 4)

    b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.6}) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0.84}) end)
    b.MouseButton1Click:Connect(function()
        tw(b,{BackgroundTransparency=0.15})
        task.delay(0.12, function() tw(b,{BackgroundTransparency=0.84}) end)
        if cb then pcall(cb) end
    end)

    f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
    return f
end

local function inp(p, t, ph, key, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,46)
    f.BackgroundColor3 = C.CARD
    f.BorderSizePixel = 0
    f.Parent = p
    co(f, 5)

    local ml = lbl(f, t, 10, C.DIM, Enum.Font.Gotham)
    ml.Size = UDim2.new(1,-10,0,14)
    ml.Position = UDim2.new(0,10,0,5)

    local bx = Instance.new("TextBox")
    bx.Size = UDim2.new(1,-20,0,20)
    bx.Position = UDim2.new(0,10,0,21)
    bx.BackgroundColor3 = C.BG
    bx.Text = ""
    bx.PlaceholderText = ph or ""
    bx.PlaceholderColor3 = C.DIM
    bx.TextColor3 = C.TEXT
    bx.Font = Enum.Font.Gotham
    bx.TextSize = 11
    bx.TextXAlignment = Enum.TextXAlignment.Left
    bx.BorderSizePixel = 0
    bx.Parent = f
    co(bx, 4)
    st(bx, C.BORDER)
    local pp = Instance.new("UIPadding") pp.PaddingLeft=UDim.new(0,7) pp.PaddingRight=UDim.new(0,7) pp.Parent=bx

    bx.Focused:Connect(function() tw(bx,{BackgroundColor3=C.CARD}) end)
    bx.FocusLost:Connect(function(enter)
        tw(bx,{BackgroundColor3=C.BG})
        if key then states[key]=bx.Text end
        if enter and cb then pcall(cb, bx.Text) end
    end)

    f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
    return f, bx
end

local function drp(p, t, opts, key, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,46)
    f.BackgroundColor3 = C.CARD
    f.BorderSizePixel = 0
    f.ClipsDescendants = false
    f.ZIndex = 5
    f.Parent = p
    co(f, 5)

    local ml = lbl(f, t, 10, C.DIM, Enum.Font.Gotham)
    ml.Size = UDim2.new(1,-10,0,14)
    ml.Position = UDim2.new(0,10,0,5)
    ml.ZIndex = 5

    local db = Instance.new("TextButton")
    db.Size = UDim2.new(1,-20,0,20)
    db.Position = UDim2.new(0,10,0,21)
    db.BackgroundColor3 = C.BG
    db.Text = (opts[1] or "Select").."  ▾"
    db.TextColor3 = C.TEXT
    db.Font = Enum.Font.Gotham
    db.TextSize = 11
    db.TextXAlignment = Enum.TextXAlignment.Left
    db.BorderSizePixel = 0
    db.ZIndex = 6
    db.Parent = f
    co(db, 4)
    st(db, C.BORDER)
    local pp = Instance.new("UIPadding") pp.PaddingLeft=UDim.new(0,7) pp.Parent=db

    local mn = Instance.new("Frame")
    mn.Size = UDim2.new(1,-20,0,#opts*24)
    mn.Position = UDim2.new(0,10,0,45)
    mn.BackgroundColor3 = C.SIDE
    mn.BorderSizePixel = 0
    mn.Visible = false
    mn.ZIndex = 20
    mn.Parent = f
    co(mn, 5)
    st(mn, C.BORDER)
    ll(mn, 0)

    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,24)
        ob.BackgroundColor3 = C.SIDE
        ob.Text = opt
        ob.TextColor3 = C.TEXT
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 11
        ob.TextXAlignment = Enum.TextXAlignment.Left
        ob.BorderSizePixel = 0
        ob.ZIndex = 21
        ob.Parent = mn
        local op = Instance.new("UIPadding") op.PaddingLeft=UDim.new(0,8) op.Parent=ob
        ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=C.CARD}) end)
        ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=C.SIDE}) end)
        ob.MouseButton1Click:Connect(function()
            db.Text = opt.."  ▾"
            mn.Visible = false
            f.Size = UDim2.new(1,0,0,46)
            if key then states[key]=opt end
            if cb then pcall(cb, opt) end
        end)
    end

    local open = false
    db.MouseButton1Click:Connect(function()
        open = not open
        mn.Visible = open
        f.Size = open and UDim2.new(1,0,0,46+#opts*24) or UDim2.new(1,0,0,46)
    end)

    f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
    f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
    return f
end

local function sp(p, h) local s = Instance.new("Frame") s.Size = UDim2.new(1,0,0,h or 3) s.BackgroundTransparency=1 s.Parent=p end

local function notify(msg)
    local ng = lpGui:FindFirstChild("VD_Notify")
    if not ng then
        ng = Instance.new("ScreenGui")
        ng.Name = "VD_Notify"
        ng.ResetOnSpawn = false
        ng.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ng.IgnoreGuiInset = true
        ng.Parent = lpGui
    end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,220,0,32)
    frame.Position = UDim2.new(1,-230,1,-48)
    frame.BackgroundColor3 = C.CARD
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.1
    frame.Parent = ng
    co(frame, 7)
    st(frame, C.BORDER)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,5,0,5)
    dot.Position = UDim2.new(0,9,0.5,-2)
    dot.BackgroundColor3 = C.GREEN
    dot.BorderSizePixel = 0
    dot.Parent = frame
    co(dot, 99)
    local ml = lbl(frame, msg, 11, C.TEXT, Enum.Font.Gotham)
    ml.Size = UDim2.new(1,-22,1,0)
    ml.Position = UDim2.new(0,20,0,0)
    tw(frame, {Position=UDim2.new(1,-230,1,-48)}, TIS)
    task.delay(2.5, function()
        tw(frame, {BackgroundTransparency=1})
        task.delay(0.3, function() frame:Destroy() end)
    end)
end

local sc = g("main")
sec(sc,"GENERATORS",C.GOLD)
tog(sc,"Anti Fail Generator","Auto-prevents fails",C.GOLD,"antifail",function(on)
    clrConn("antifail")
    if on then conns["antifail"]=RunService.Heartbeat:Connect(function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("NumberValue") and v.Name=="FailChance" then v.Value=0 end
        end
    end) end
    notify(on and "Anti Fail ON" or "Anti Fail OFF")
end)
tog(sc,"Auto Perfect Skill-Check","Hits perfect zone always",C.GOLD,"autoskill",function(on)
    clrConn("autoskill")
    if on then conns["autoskill"]=RunService.Heartbeat:Connect(function()
        local gui = lp.PlayerGui:FindFirstChild("SkillCheckGui") or lp.PlayerGui:FindFirstChild("SkillCheckUI")
        if gui then
            local arr = gui:FindFirstChildWhichIsA("ImageLabel",true)
            if arr then arr.Rotation=90 end
        end
    end) end
    notify(on and "Auto Skill-Check ON" or "Auto Skill-Check OFF")
end)

local sc2 = g("survivor")
sec(sc2,"MOVEMENT",C.CYAN)
tog(sc2,"No Fall","Prevents fall damage",C.CYAN,"nofall",function(on)
    local hum=getHum()
    if hum then hum.FallingDown:Connect(function() if states.nofall then hum:ChangeState(Enum.HumanoidStateType.Running) end end) end
    notify(on and "No Fall ON" or "No Fall OFF")
end)
tog(sc2,"No Turn Speed Limit",nil,C.CYAN,"noturn",function(on)
    local hum=getHum() if hum then hum.AutoRotate=not on end
    notify(on and "No Turn Limit ON" or "No Turn Limit OFF")
end)
tog(sc2,"Auto Escape","Auto-escapes grabs",C.CYAN,"autoescape",function(on)
    clrConn("autoescape")
    if on then conns["autoescape"]=RunService.Heartbeat:Connect(function()
        local c=getChar() if not c then return end
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BoolValue") and (v.Name=="IsGrabbed" or v.Name=="Grabbed") and v.Value then v.Value=false end
        end
    end) end
    notify(on and "Auto Escape ON" or "Auto Escape OFF")
end)
sec(sc2,"COMBAT",C.CYAN)
tog(sc2,"Auto Parry","Auto-parries attacks",C.CYAN,"autoparry",function(on)
    clrConn("autoparry")
    if on then conns["autoparry"]=RunService.Heartbeat:Connect(function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("parry") then pcall(function() v:FireServer() end) end
        end
    end) end
    notify(on and "Auto Parry ON" or "Auto Parry OFF")
end)
tog(sc2,"Instant Heal Others",nil,C.CYAN,"instheal",function(on)
    clrConn("instheal")
    if on then conns["instheal"]=RunService.Heartbeat:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local h=p.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
            end
        end
    end) end
    notify(on and "Heal Others ON" or "Heal Others OFF")
end)
tog(sc2,"Grab Nearest (OP)",nil,C.CYAN,"grabnearest",function(on)
    if not on then notify("Grab Nearest OFF") return end
    local hrp=getHRP() if not hrp then return end
    local near,d=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
            if dd<d then near=p d=dd end
        end
    end
    if near then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("grab") then pcall(function() v:FireServer(near.Character) end) end
        end
        notify("Grabbed: "..near.Name)
    end
    states.grabnearest=false
end)
tog(sc2,"Instant Escape",nil,C.CYAN,"instescape",function(on)
    clrConn("instescape")
    if on then conns["instescape"]=RunService.Heartbeat:Connect(function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("escape") then pcall(function() v:FireServer() end) end
        end
    end) end
    notify(on and "Instant Escape ON" or "Instant Escape OFF")
end)
tog(sc2,"Sacrifice Self",nil,C.CYAN,"sacrifice",function(on)
    if not on then return end
    local hum=getHum() if hum then hum.Health=0 end
    states.sacrifice=false
    notify("Sacrificed")
end)
sec(sc2,"STEALTH",C.CYAN)
tog(sc2,"Invisible (OP)","Full character invisibility",C.CYAN,"invis",function(on)
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then tw(p,{Transparency=on and 1 or 0}) end
        if p:IsA("Decal") then p.Transparency=on and 1 or 0 end
    end
    notify(on and "Invisible ON" or "Invisible OFF")
end)
tog(sc2,"Invisible Effect","Flicker invisible",C.CYAN,"inviseffect",function(on)
    clrConn("inviseffect")
    if on then conns["inviseffect"]=RunService.Heartbeat:Connect(function()
        local c=getChar() if not c then return end
        local t=math.sin(tick()*8)>0 and 0.92 or 0.25
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.LocalTransparencyModifier=t end
        end
    end)
    else
        local c=getChar() if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier=0 end end end
    end
    notify(on and "Invis Effect ON" or "Invis Effect OFF")
end)
tog(sc2,"Invisible Button (mobile)",nil,C.CYAN,"invisbtn",function(on) notify(on and "Mobile Invis Btn ON" or "OFF") end)

local sc3 = g("killer")
sec(sc3,"POWER",C.RED)
tog(sc3,"Full Generator Break",nil,C.RED,"fullgenbreak",function(on)
    clrConn("fullgenbreak")
    if on then conns["fullgenbreak"]=RunService.Heartbeat:Connect(function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("NumberValue") and v.Name=="Progress" then v.Value=0 end
        end
    end) end
    notify(on and "Gen Break ON" or "Gen Break OFF")
end)
tog(sc3,"Anti Blind",nil,C.RED,"antiblind",function(on)
    clrConn("antiblind")
    if on then conns["antiblind"]=RunService.Heartbeat:Connect(function()
        for _,v in pairs(lp.PlayerGui:GetDescendants()) do
            if (v:IsA("ImageLabel") or v:IsA("Frame")) and v.Name:lower():find("blind") then v.Visible=false end
        end
        local ce=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if ce then ce.Brightness=0 end
    end) end
    notify(on and "Anti Blind ON" or "Anti Blind OFF")
end)
tog(sc3,"No Slowdown",nil,C.RED,"noslowdown",function(on)
    clrConn("noslowdown")
    if on then conns["noslowdown"]=RunService.Heartbeat:Connect(function()
        local hum=getHum() if hum and hum.WalkSpeed<14 then hum.WalkSpeed=states.speedval or 16 end
    end) end
    notify(on and "No Slowdown ON" or "No Slowdown OFF")
end)
tog(sc3,"Infinite Lunge",nil,C.RED,"influnge",function(on)
    clrConn("influnge")
    if on then conns["influnge"]=RunService.Heartbeat:Connect(function()
        local c=getChar() if not c then return end
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("NumberValue") and v.Name:lower():find("lunge") and v.Name:lower():find("cd") then v.Value=0 end
        end
    end) end
    notify(on and "Infinite Lunge ON" or "Infinite Lunge OFF")
end)
tog(sc3,"Double Tap","Instantly downs on hit",C.RED,"doubletap",function(on)
    clrConn("doubletap")
    if on then conns["doubletap"]=RunService.Heartbeat:Connect(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local ph=p.Character:FindFirstChild("HumanoidRootPart")
                if ph and (ph.Position-hrp.Position).Magnitude<8 then
                    for _,v in pairs(workspace:GetDescendants()) do
                        if v:IsA("RemoteEvent") and v.Name:lower():find("hit") then pcall(function() v:FireServer(p.Character) end) end
                    end
                end
            end
        end
    end) end
    notify(on and "Double Tap ON" or "Double Tap OFF")
end)
tog(sc3,"No Pallet Stun",nil,C.RED,"nopalletstun",function(on)
    clrConn("nopalletstun")
    if on then conns["nopalletstun"]=RunService.Heartbeat:Connect(function()
        local c=getChar() if not c then return end
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BoolValue") and v.Name:lower():find("stun") then v.Value=false end
        end
    end) end
    notify(on and "No Pallet Stun ON" or "No Pallet Stun OFF")
end)
sec(sc3,"CAMERA",C.RED)
tog(sc3,"Shift Lock",nil,C.RED,"shiftlock",function(on)
    clrConn("shiftlock")
    if on then conns["shiftlock"]=RunService.RenderStepped:Connect(function()
        local hrp=getHRP() if not hrp then return end
        local angle=math.atan2(cam.CFrame.LookVector.X,cam.CFrame.LookVector.Z)
        hrp.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,angle,0)
    end) end
    notify(on and "Shift Lock ON" or "Shift Lock OFF")
end)
tog(sc3,"Third Person",nil,C.RED,"thirdperson",function(on) notify(on and "Third Person ON" or "Third Person OFF") end)
tog(sc3,"Veil Crosshair",nil,C.RED,"veilcross",function(on)
    local ex=lpGui:FindFirstChild("VDCross")
    if on then
        if not ex then
            local cg=Instance.new("ScreenGui") cg.Name="VDCross" cg.ResetOnSpawn=false cg.IgnoreGuiInset=true cg.Parent=lpGui
            local function ln(w,h,xo,yo)
                local f=Instance.new("Frame") f.Size=UDim2.new(0,w,0,h) f.Position=UDim2.new(0.5,xo-w/2,0.5,yo-h/2)
                f.BackgroundColor3=Color3.new(1,1,1) f.BackgroundTransparency=0.2 f.BorderSizePixel=0 f.Parent=cg
            end
            ln(12,1,0,0) ln(1,12,0,0)
            local dot=Instance.new("Frame") dot.Size=UDim2.new(0,3,0,3) dot.Position=UDim2.new(0.5,-1,0.5,-1)
            dot.BackgroundColor3=C.RED dot.BorderSizePixel=0 dot.Parent=cg co(dot,99)
        end
    else if ex then ex:Destroy() end end
    notify(on and "Crosshair ON" or "Crosshair OFF")
end)
sec(sc3,"MASK",C.RED)
drp(sc3,"Select Mask",{"None","Mask A","Mask B","Mask C","Mask D"},"selectedmask",function(v) notify("Mask: "..v) end)
btn(sc3,"▶  Activate Mask",C.RED,function()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("mask") then pcall(function() v:FireServer("activate",states.selectedmask) end) end
    end
    notify("Mask Activated")
end)
btn(sc3,"◼  Deactivate Mask",C.DIM,function() notify("Mask Deactivated") end)
sec(sc3,"HITBOX",C.RED)
tog(sc3,"Hitbox Expander",nil,C.RED,"hitboxexp",function(on)
    clrConn("hitboxexp")
    if on then conns["hitboxexp"]=RunService.Heartbeat:Connect(function()
        local sz=states.hitboxsz or 5
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size=Vector3.new(sz,sz,sz) end
            end
        end
    end) end
    notify(on and "Hitbox ON" or "Hitbox OFF")
end)
sld(sc3,"Hitbox Size",1,30,5,"hitboxsz",C.RED)
sec(sc3,"MAP",C.RED)
btn(sc3,"💥 Destroy All Pallets",C.RED,function()
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("pallet") and v:IsA("Model") then v:Destroy() end
    end
    notify("All pallets destroyed")
end)

local sc4=g("fling")
sec(sc4,"FLING",C.PURPLE)
btn(sc4,"▶  Fling Nearest",C.PURPLE,function()
    local hrp=getHRP() if not hrp then return end
    local near,d=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
            if dd<d then near=p d=dd end
        end
    end
    if near then
        local nh=near.Character:FindFirstChild("HumanoidRootPart")
        if nh then
            local bv=Instance.new("BodyVelocity") bv.Velocity=Vector3.new(math.random(-1,1)*(states.flingstr or 200),states.flingstr or 200,math.random(-1,1)*(states.flingstr or 200))
            bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.Parent=nh
            game:GetService("Debris"):AddItem(bv,0.12)
            notify("Flung: "..near.Name)
        end
    end
end)
btn(sc4,"▶  Fling All",C.PURPLE,function()
    local wl={} for w in (states.flingwl or ""):gmatch("[^,]+") do wl[w:match("^%s*(.-)%s*$")]=true end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and not wl[p.Name] and p.Character then
            local nh=p.Character:FindFirstChild("HumanoidRootPart")
            if nh then
                local bv=Instance.new("BodyVelocity") bv.Velocity=Vector3.new(math.random(-1,1)*(states.flingstr or 200),states.flingstr or 200,math.random(-1,1)*(states.flingstr or 200))
                bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.Parent=nh
                game:GetService("Debris"):AddItem(bv,0.12)
            end
        end
    end
    notify("Flung all")
end)
sld(sc4,"Fling Strength",1,2000,200,"flingstr",C.PURPLE)
inp(sc4,"Fling Whitelist","Player1, Player2...","flingwl")

local sc5=g("sound")
sec(sc5,"SOUND PLAYER",C.GREEN)
inp(sc5,"Sound ID","rbxassetid://...","soundid")
sld(sc5,"Distance",1,1000,100,"sounddist",C.GREEN)
sld(sc5,"Volume",0,10,5,"soundvol",C.GREEN)
btn(sc5,"▶  Play Sound",C.GREEN,function()
    local ex=workspace:FindFirstChild("VDSound") if ex then ex:Destroy() end
    local s=Instance.new("Sound") s.Name="VDSound"
    local id=states.soundid or ""
    s.SoundId=id:find("rbxassetid") and id or "rbxassetid://"..id
    s.RollOffMaxDistance=states.sounddist or 100
    s.Volume=(states.soundvol or 5)/10*2
    s.Parent=workspace s:Play()
    notify("Sound playing")
end)
btn(sc5,"■  Stop",C.DIM,function()
    local s=workspace:FindFirstChild("VDSound") if s then s:Destroy() end notify("Sound stopped")
end)

local sc6=g("emotes")
sec(sc6,"EMOTES",C.ORANGE)
drp(sc6,"Select Emote",{"Wave","Dance","Dance2","Dance3","Laugh","Cheer","Cry","Point","Salute","Shrug","Zombie"},"selemote",function(v) notify("Emote: "..v) end)
btn(sc6,"▶  Play Emote",C.ORANGE,function()
    local ids={Wave="507770239",Dance="507771019",Dance2="507776043",Dance3="507777268",Laugh="507770818",Cheer="507770453",Cry="501694108",Point="507770453",Salute="3360689775",Shrug="3360692915",Zombie="3360825058"}
    local id=ids[states.selemote] or "507770239"
    local hum=getHum() if not hum then return end
    local anim=Instance.new("Animation") anim.AnimationId="rbxassetid://"..id
    local t=hum:LoadAnimation(anim) t:Play()
    notify("Emote: "..(states.selemote or "Wave"))
end)

local sc7=g("player")
sec(sc7,"SPEED",C.BLUE)
tog(sc7,"Speed Boost",nil,C.BLUE,"speedboost",function(on)
    local hum=getHum() if hum then hum.WalkSpeed=on and (states.speedval or 16) or 16 end
    notify(on and "Speed: "..(states.speedval or 16) or "Speed reset")
end)
sld(sc7,"Speed",1,300,16,"speedval",C.BLUE,function(v)
    if states.speedboost then local hum=getHum() if hum then hum.WalkSpeed=v end end
end)
drp(sc7,"Speed Method",{"Attribute","TP","BodyVelocity"},"speedmethod",function(v) notify("Method: "..v) end)
inp(sc7,"Speed Keybind","e.g. E","speedkeystr",function(v)
    local k=Enum.KeyCode[v:upper()] if k then states.speedkey=k notify("Key: "..v) end
end)
sec(sc7,"PHYSICS",C.BLUE)
sld(sc7,"Jump Power",1,500,50,"jumppower",C.BLUE,function(v)
    local hum=getHum() if hum then hum.JumpPower=v end
end)
sld(sc7,"Hip Height",0,20,0,"hipheight",C.BLUE,function(v)
    local hum=getHum() if hum then hum.HipHeight=v end
end)
tog(sc7,"Infinite Jump",nil,C.BLUE,"infjump",function(on)
    clrConn("infjump")
    if on then conns["infjump"]=UserInputService.JumpRequest:Connect(function()
        local hum=getHum() if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end) end
    notify(on and "Infinite Jump ON" or "Infinite Jump OFF")
end)
tog(sc7,"Freeze Self",nil,C.BLUE,"freeze",function(on)
    local hrp=getHRP() if hrp then hrp.Anchored=on end notify(on and "Frozen" or "Unfrozen")
end)
sec(sc7,"CAMERA",C.BLUE)
sld(sc7,"FOV",30,140,70,"fov",C.BLUE,function(v) cam.FieldOfView=v end)
sec(sc7,"FLY / NOCLIP",C.BLUE)
tog(sc7,"Noclip",nil,C.BLUE,"noclip",function(on)
    clrConn("noclip")
    if on then conns["noclip"]=RunService.Stepped:Connect(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end)
    else local c=getChar() if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end end
    notify(on and "Noclip ON" or "Noclip OFF")
end)
tog(sc7,"Fly",nil,C.BLUE,"fly",function(on)
    clrConn("fly")
    if on then
        local hrp=getHRP() if not hrp then return end
        local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.Velocity=Vector3.zero bv.Parent=hrp
        local bg=Instance.new("BodyGyro") bg.MaxTorque=Vector3.new(1e9,1e9,1e9) bg.D=100 bg.Parent=hrp
        conns["fly"]=RunService.Heartbeat:Connect(function()
            if not states.fly then return end
            local hrp2=getHRP() if not hrp2 then return end
            local spd=states.flyspeed or 50 local v=Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then v=v+cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then v=v-cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then v=v-cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then v=v+cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v=v+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,1,0) end
            if bv and bv.Parent then bv.Velocity=v.Magnitude>0 and v.Unit*spd or Vector3.zero end
            if bg and bg.Parent then bg.CFrame=cam.CFrame end
        end)
    end
    notify(on and "Fly ON" or "Fly OFF")
end)
drp(sc7,"Fly Mode",{"Velocity","CFrame"},"flymode",function(v) notify("Fly: "..v) end)
sld(sc7,"Fly Speed",1,300,50,"flyspeed",C.BLUE)

local sc8=g("esp")
sec(sc8,"PLAYER ESP",C.CYAN)
tog(sc8,"Toggle ESP (Master)",nil,C.CYAN,"espon",function(on) notify(on and "ESP ON" or "ESP OFF") end)
tog(sc8,"2D Boxes",nil,C.CYAN,"esp2d")
tog(sc8,"3D Boxes",nil,C.CYAN,"esp3d")
tog(sc8,"Show Names",nil,C.CYAN,"espnames")
tog(sc8,"Show Distance",nil,C.CYAN,"espdist")
tog(sc8,"Show Weapon",nil,C.CYAN,"espweap")
tog(sc8,"Health Bars",nil,C.CYAN,"esphealth")
tog(sc8,"Health Text",nil,C.CYAN,"esphealthtxt")
tog(sc8,"Tracers",nil,C.CYAN,"esptrace")
tog(sc8,"Highlights",nil,C.CYAN,"esphl")
tog(sc8,"Off-Screen Arrows",nil,C.CYAN,"esparrow")
sec(sc8,"INSTANCE ESP",C.CYAN)
tog(sc8,"Generator ESP",nil,C.CYAN,"genesp")
tog(sc8,"Hook ESP",nil,C.CYAN,"hookesp")
tog(sc8,"Vault ESP",nil,C.CYAN,"vaultesp")
tog(sc8,"Pallet ESP",nil,C.CYAN,"palletesp")
tog(sc8,"Gate ESP",nil,C.CYAN,"gateesp")
sec(sc8,"GLOBAL SETTINGS",C.CYAN)
tog(sc8,"Team Color",nil,C.CYAN,"teamcol")
tog(sc8,"Show Teammates",nil,C.CYAN,"showteam")
sld(sc8,"Line Thickness",1,10,1,"linethick",C.CYAN)
sld(sc8,"Highlight Distance",10,5000,500,"highldist",C.CYAN)
sld(sc8,"Fill Transparency",0,10,8,"filltrans",C.CYAN)
sld(sc8,"Outline Transparency",0,10,0,"outltrans",C.CYAN)
sld(sc8,"Arrow Size",1,50,10,"arrowsz",C.CYAN)
sld(sc8,"Arrow Radius",50,600,200,"arrowrad",C.CYAN)
sld(sc8,"ESP Update Interval",1,60,10,"espupd",C.CYAN)
sld(sc8,"ESP Check Interval",1,60,5,"espchk",C.CYAN)

RunService.Heartbeat:Connect(function()
    if not states.espon then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        if not p.Character then continue end
        local c=p.Character local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then continue end
        local myhrp=getHRP() if not myhrp then continue end
        if (hrp.Position-myhrp.Position).Magnitude>(states.highldist or 500) then continue end
        if states.esphl then
            if not c:FindFirstChild("VD_HL") then
                local sb=Instance.new("SelectionBox") sb.Name="VD_HL" sb.Adornee=c
                sb.Color3=C.CYAN sb.LineThickness=(states.linethick or 1)/10
                sb.SurfaceTransparency=(states.filltrans or 8)/10 sb.SurfaceColor3=C.CYAN sb.Parent=c
            end
        else local h=c:FindFirstChild("VD_HL") if h then h:Destroy() end end
        if states.espnames or states.espdist then
            if not hrp:FindFirstChild("VD_BB") then
                local bg=Instance.new("BillboardGui") bg.Name="VD_BB" bg.Size=UDim2.new(0,160,0,40)
                bg.StudsOffset=Vector3.new(0,3.5,0) bg.AlwaysOnTop=true bg.Parent=hrp
                local tl=Instance.new("TextLabel") tl.Name="T" tl.Size=UDim2.new(1,0,1,0)
                tl.BackgroundTransparency=1 tl.TextColor3=C.CYAN tl.Font=Enum.Font.GothamBold tl.TextSize=12 tl.Parent=bg
            end
            local bg=hrp:FindFirstChild("VD_BB")
            if bg then
                local tl=bg:FindFirstChild("T")
                if tl then
                    local dist=math.round((hrp.Position-myhrp.Position).Magnitude)
                    tl.Text=(states.espnames and p.Name or "")..(states.espdist and " ["..dist.."m]" or "")
                end
            end
        else local b=hrp:FindFirstChild("VD_BB") if b then b:Destroy() end end
    end
end)

local sc9=g("visuals")
sec(sc9,"AMBIENCE",C.PINK)
tog(sc9,"Ambience Override",nil,C.PINK,"ambience",function(on)
    local ex=Lighting:FindFirstChild("VD_CC")
    if on then if not ex then local cc=Instance.new("ColorCorrectionEffect") cc.Name="VD_CC" cc.Parent=Lighting end
    else if ex then ex:Destroy() end end
    notify(on and "Ambience ON" or "Ambience OFF")
end)
tog(sc9,"Force Time",nil,C.PINK,"forcetime",function(on)
    clrConn("forcetime")
    if on then conns["forcetime"]=RunService.Heartbeat:Connect(function()
        Lighting.TimeOfDay=string.format("%02d:00:00",states.timeval or 12)
    end) end
    notify(on and "Force Time ON" or "Force Time OFF")
end)
sld(sc9,"Time of Day (h)",0,23,12,"timeval",C.PINK,function(v)
    if states.forcetime then Lighting.TimeOfDay=string.format("%02d:00:00",v) end
end)
tog(sc9,"Custom Saturation",nil,C.PINK,"custsat",function(on)
    local ce=Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect",Lighting)
    ce.Saturation=on and (states.satval or 5)/5-1 or 0
    notify(on and "Saturation ON" or "Saturation OFF")
end)
sld(sc9,"Saturation",0,10,5,"satval",C.PINK,function(v)
    if states.custsat then
        local ce=Lighting:FindFirstChildOfClass("ColorCorrectionEffect") if ce then ce.Saturation=v/5-1 end
    end
end)
inp(sc9,"Skybox Asset ID","rbxassetid://...","skyboxid",function(v)
    local sky=Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky",Lighting)
    local id=v:find("rbxassetid") and v or "rbxassetid://"..v
    sky.SkyboxBk=id sky.SkyboxDn=id sky.SkyboxFt=id sky.SkyboxLf=id sky.SkyboxRt=id sky.SkyboxUp=id
    notify("Skybox applied")
end)
sec(sc9,"BODY MODIFIER",C.PINK)
drp(sc9,"Material",{"SmoothPlastic","Neon","Glass","Metal","Wood","DiamondPlate","Foil","Brick"},"matsel",function(v)
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function() p.Material=Enum.Material[v] end) end end
    notify("Material: "..v)
end)
inp(sc9,"Color (R,G,B)","255, 100, 100","matcol",function(v)
    local r,g,b=v:match("(%d+),%s*(%d+),%s*(%d+)")
    if r then
        local col=Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b))
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.BrickColor=BrickColor.new(col) end end
        notify("Color applied")
    end
end)
btn(sc9,"↺  Reset Appearance",C.DIM,function()
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.Material=Enum.Material.SmoothPlastic end) p.Transparency=0 p.LocalTransparencyModifier=0 end
    end
    notify("Appearance reset")
end)

local sc10=g("aimbot")
sec(sc10,"SPEAR AIMBOT",C.RED)
tog(sc10,"Spear Aimbot",nil,C.RED,"spearaim",function(on)
    clrConn("spearaim")
    if on then conns["spearaim"]=RunService.RenderStepped:Connect(function()
        if not states.spearaim then return end
        if not UserInputService:IsKeyDown(states.spearkey or Enum.KeyCode.E) then return end
        local hrp=getHRP() if not hrp then return end
        local near,d=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
                if dd<d then near=p d=dd end
            end
        end
        if near then
            local tp=near.Character.HumanoidRootPart.Position
            local tt=d/(states.spearspeed or 150)
            local pred=tp+near.Character.HumanoidRootPart.Velocity*tt
            cam.CFrame=CFrame.lookAt(cam.CFrame.Position,pred)
        end
    end) end
    notify(on and "Spear Aim ON" or "Spear Aim OFF")
end)
inp(sc10,"Aim Key","E","spearkeystr",function(v)
    local k=Enum.KeyCode[v:upper()] if k then states.spearkey=k notify("Key: "..v) end
end)
sld(sc10,"Gravity",0,300,60,"speargrav",C.RED)
sld(sc10,"Projectile Speed",10,1000,150,"spearspeed",C.RED)
btn(sc10,"🎯  Aim (Mobile)",C.RED,function()
    local hrp=getHRP() if not hrp then return end
    local near,d=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
            if dd<d then near=p d=dd end
        end
    end
    if near then cam.CFrame=CFrame.lookAt(cam.CFrame.Position,near.Character.HumanoidRootPart.Position) notify("Aimed at "..near.Name) end
end)
tog(sc10,"Lock Spear Target",nil,C.RED,"lockspear",function(on)
    clrConn("lockspear")
    if on then conns["lockspear"]=RunService.RenderStepped:Connect(function()
        local hrp=getHRP() if not hrp then return end
        local near,d=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
                if dd<d then near=p d=dd end
            end
        end
        if near then cam.CFrame=CFrame.lookAt(cam.CFrame.Position,near.Character.HumanoidRootPart.Position) end
    end) end
    notify(on and "Lock Spear ON" or "Lock Spear OFF")
end)
sld(sc10,"Button Size (Mobile)",20,200,80,"spearbtnsz",C.RED)
sec(sc10,"GUN SILENT AIM",C.RED)
tog(sc10,"Gun Silent Aim",nil,C.RED,"gunsilent",function(on)
    notify(on and "Silent Aim ON (requires executor hook)" or "Silent Aim OFF")
end)
drp(sc10,"Target Part",{"Head","HumanoidRootPart","UpperTorso","Torso","LowerTorso"},"silentpart",function(v) notify("Part: "..v) end)

tabs["main"].btn.MouseButton1Click:Fire()

lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    local hum=char:WaitForChild("Humanoid")
    if states.speedboost then hum.WalkSpeed=states.speedval or 16 end
    if states.jumppower then hum.JumpPower=states.jumppower end
    if states.hipheight then hum.HipHeight=states.hipheight end
    if states.fov then cam.FieldOfView=states.fov end
    if states.noclip then
        clrConn("noclip")
        conns["noclip"]=RunService.Stepped:Connect(function()
            for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    end
end)

tw(Win, {BackgroundTransparency=0}, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out))
notify("Violence District v1.3 loaded")
