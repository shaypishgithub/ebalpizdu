local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local lp=Players.LocalPlayer
local lpGui=lp:WaitForChild("PlayerGui")
local cam=workspace.CurrentCamera

local C={
	BG=Color3.fromRGB(10,9,14),
	PANEL=Color3.fromRGB(15,14,20),
	SIDE=Color3.fromRGB(12,11,17),
	CARD=Color3.fromRGB(21,20,28),
	CARDH=Color3.fromRGB(28,27,38),
	BORDER=Color3.fromRGB(42,40,56),
	RED=Color3.fromRGB(215,42,58),
	RED2=Color3.fromRGB(255,75,92),
	CYAN=Color3.fromRGB(42,192,208),
	GOLD=Color3.fromRGB(255,186,62),
	GREEN=Color3.fromRGB(52,208,112),
	PURPLE=Color3.fromRGB(182,122,255),
	ORANGE=Color3.fromRGB(255,162,52),
	BLUE=Color3.fromRGB(92,152,255),
	PINK=Color3.fromRGB(255,112,188),
	TEXT=Color3.fromRGB(218,215,228),
	DIM=Color3.fromRGB(108,104,128),
	MUTED=Color3.fromRGB(58,55,76),
	OFF=Color3.fromRGB(36,34,48),
	SCROLL=Color3.fromRGB(48,46,62),
}
local TI=TweenInfo.new(0.14,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local TIS=TweenInfo.new(0.26,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local st={}
local cn={}

local function tw(o,p,i) TweenService:Create(o,i or TI,p):Play() end
local function co(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 6) c.Parent=p end
local function sk(p,col,th) local s=Instance.new("UIStroke") s.Color=col or C.BORDER s.Thickness=th or 1 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p end
local function ll(p,sp) local l=Instance.new("UIListLayout") l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,sp or 4) l.Parent=p return l end
local function pd(p,t,b,l,r) local u=Instance.new("UIPadding") u.PaddingTop=UDim.new(0,t or 0) u.PaddingBottom=UDim.new(0,b or 0) u.PaddingLeft=UDim.new(0,l or 0) u.PaddingRight=UDim.new(0,r or 0) u.Parent=p end
local function tx(p,t,s,c,f,ax) local lb=Instance.new("TextLabel") lb.BackgroundTransparency=1 lb.Text=t or "" lb.TextSize=s or 12 lb.TextColor3=c or C.TEXT lb.Font=f or Enum.Font.Gotham lb.TextXAlignment=ax or Enum.TextXAlignment.Left lb.Parent=p return lb end
local function gC() return lp.Character end
local function gH() local c=gC() return c and c:FindFirstChild("HumanoidRootPart") end
local function gHm() local c=gC() return c and c:FindFirstChildOfClass("Humanoid") end
local function cc(k) if cn[k] then cn[k]:Disconnect() cn[k]=nil end end

local Root=Instance.new("ScreenGui")
Root.Name="VD13"
Root.ResetOnSpawn=false
Root.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Root.IgnoreGuiInset=true
Root.DisplayOrder=100
Root.Parent=lpGui

local WW,WH=530,415

local Win=Instance.new("Frame")
Win.Name="Win"
Win.Size=UDim2.new(0,WW,0,WH)
Win.Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)
Win.BackgroundColor3=C.BG
Win.BorderSizePixel=0
Win.ClipsDescendants=true
Win.Parent=Root
co(Win,10)
sk(Win,C.BORDER,1)

local dragOn=false
local dragSt,winSt
Win.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then
		dragOn=true dragSt=i.Position winSt=Win.Position
	end
end)
Win.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then dragOn=false end
end)
UserInputService.InputChanged:Connect(function(i)
	if dragOn and i.UserInputType==Enum.UserInputType.MouseMovement then
		local d=i.Position-dragSt
		Win.Position=UDim2.new(winSt.X.Scale,winSt.X.Offset+d.X,winSt.Y.Scale,winSt.Y.Offset+d.Y)
	end
end)

local TB=Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,36)
TB.BackgroundColor3=C.SIDE
TB.BorderSizePixel=0
TB.Parent=Win

local AL=Instance.new("Frame")
AL.Size=UDim2.new(1,0,0,2)
AL.Position=UDim2.new(0,0,1,-2)
AL.BackgroundColor3=C.RED
AL.BorderSizePixel=0
AL.Parent=TB

local PD=Instance.new("Frame")
PD.Size=UDim2.new(0,6,0,6)
PD.Position=UDim2.new(0,12,0.5,-3)
PD.BackgroundColor3=C.RED
PD.BorderSizePixel=0
PD.Parent=TB
co(PD,99)
TweenService:Create(PD,TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.7}):Play()

local TL=tx(TB,"Violence District",13,C.TEXT,Enum.Font.GothamBold)
TL.Size=UDim2.new(0,160,1,0)
TL.Position=UDim2.new(0,24,0,0)

local VB=Instance.new("Frame")
VB.Size=UDim2.new(0,34,0,14)
VB.Position=UDim2.new(0,158,0.5,-7)
VB.BackgroundColor3=C.RED
VB.BorderSizePixel=0
VB.Parent=TB
co(VB,4)
local VL=tx(VB,"v1.3",9,Color3.new(1,1,1),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
VL.Size=UDim2.new(1,0,1,0)

local function mkWBtn(xoff,col)
	local f=Instance.new("Frame")
	f.Size=UDim2.new(0,11,0,11)
	f.Position=UDim2.new(1,xoff,0.5,-5)
	f.BackgroundColor3=col
	f.BorderSizePixel=0
	f.Parent=TB
	co(f,99)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,0,1,0)
	b.BackgroundTransparency=1
	b.Text=""
	b.Parent=f
	b.MouseEnter:Connect(function() tw(f,{BackgroundColor3=Color3.new(1,1,1)}) end)
	b.MouseLeave:Connect(function() tw(f,{BackgroundColor3=col}) end)
	return b,f
end

local btnX,_=mkWBtn(-14,Color3.fromRGB(215,52,62))
local btnM,_=mkWBtn(-30,Color3.fromRGB(238,176,46))
btnX.MouseButton1Click:Connect(function() Root:Destroy() end)

local isMin=false
btnM.MouseButton1Click:Connect(function()
	isMin=not isMin
	tw(Win,{Size=isMin and UDim2.new(0,WW,0,36) or UDim2.new(0,WW,0,WH)},TIS)
end)

local TogBtn=Instance.new("TextButton")
TogBtn.Size=UDim2.new(0,16,0,52)
TogBtn.Position=UDim2.new(0,-16,0.5,-26)
TogBtn.BackgroundColor3=C.RED
TogBtn.Text=""
TogBtn.BorderSizePixel=0
TogBtn.ZIndex=10
TogBtn.Parent=Win
local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(0,5) tc.Parent=TogBtn
local TA=tx(TogBtn,"◀",9,Color3.new(1,1,1),Enum.Font.GothamBold,Enum.TextXAlignment.Center)
TA.Size=UDim2.new(1,0,1,0)
TA.ZIndex=11

local isOpen=true
TogBtn.MouseButton1Click:Connect(function()
	isOpen=not isOpen
	if isOpen then
		tw(Win,{Size=UDim2.new(0,WW,0,isMin and 36 or WH)},TIS)
		TA.Text="◀"
	else
		tw(Win,{Size=UDim2.new(0,16,0,52)},TIS)
		TA.Text="▶"
	end
end)

local SB=Instance.new("Frame")
SB.Name="Sidebar"
SB.Size=UDim2.new(0,118,1,-36)
SB.Position=UDim2.new(0,0,0,36)
SB.BackgroundColor3=C.SIDE
SB.BorderSizePixel=0
SB.Parent=Win

local SD=Instance.new("Frame")
SD.Size=UDim2.new(0,1,1,0)
SD.Position=UDim2.new(1,-1,0,0)
SD.BackgroundColor3=C.BORDER
SD.BorderSizePixel=0
SD.Parent=SB

local SS=Instance.new("ScrollingFrame")
SS.Size=UDim2.new(1,-6,1,-6)
SS.Position=UDim2.new(0,3,0,3)
SS.BackgroundTransparency=1
SS.ScrollBarThickness=2
SS.ScrollBarImageColor3=C.SCROLL
SS.CanvasSize=UDim2.new(0,0,0,0)
SS.AutomaticCanvasSize=Enum.AutomaticSize.Y
SS.BorderSizePixel=0
SS.Parent=SB
ll(SS,2)
pd(SS,4,4,4,4)

local CA=Instance.new("Frame")
CA.Size=UDim2.new(1,-118,1,-36)
CA.Position=UDim2.new(0,118,0,36)
CA.BackgroundColor3=C.PANEL
CA.BorderSizePixel=0
CA.ClipsDescendants=true
CA.Parent=Win

local TABS={}
local PAGES={}

local TD={
	{k="main",n="MAIN",i="◈",c=C.GOLD},
	{k="survivor",n="SURVIVOR",i="⬡",c=C.CYAN},
	{k="killer",n="KILLER",i="◆",c=C.RED},
	{k="fling",n="FLING",i="◉",c=C.PURPLE},
	{k="sound",n="SOUND",i="◎",c=C.GREEN},
	{k="emotes",n="EMOTES",i="◇",c=C.ORANGE},
	{k="player",n="PLAYER",i="○",c=C.BLUE},
	{k="esp",n="ESP",i="◐",c=C.CYAN},
	{k="visuals",n="VISUALS",i="◑",c=C.PINK},
	{k="aimbot",n="AIMBOT",i="◎",c=C.RED},
}

for idx,def in ipairs(TD) do
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(1,0,0,28)
	btn.BackgroundColor3=C.SIDE
	btn.Text=""
	btn.BorderSizePixel=0
	btn.LayoutOrder=idx
	btn.Parent=SS
	co(btn,5)

	local ind=Instance.new("Frame")
	ind.Size=UDim2.new(0,2,0.58,0)
	ind.Position=UDim2.new(0,0,0.21,0)
	ind.BackgroundColor3=def.c
	ind.BackgroundTransparency=1
	ind.BorderSizePixel=0
	ind.Parent=btn
	co(ind,2)

	local ic=tx(btn,def.i,10,C.DIM,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
	ic.Size=UDim2.new(0,16,1,0)
	ic.Position=UDim2.new(0,6,0,0)

	local nm=tx(btn,def.n,10,C.DIM,Enum.Font.Gotham)
	nm.Size=UDim2.new(1,-26,1,0)
	nm.Position=UDim2.new(0,26,0,0)

	local pg=Instance.new("ScrollingFrame")
	pg.Size=UDim2.new(1,0,1,0)
	pg.BackgroundTransparency=1
	pg.ScrollBarThickness=3
	pg.ScrollBarImageColor3=C.SCROLL
	pg.CanvasSize=UDim2.new(0,0,0,0)
	pg.AutomaticCanvasSize=Enum.AutomaticSize.Y
	pg.BorderSizePixel=0
	pg.Visible=false
	pg.Parent=CA
	ll(pg,0)
	pd(pg,7,8,8,8)

	TABS[def.k]={btn=btn,ind=ind,ic=ic,nm=nm,pg=pg,c=def.c}
	PAGES[def.k]=pg

	btn.MouseButton1Click:Connect(function()
		for k,t in pairs(TABS) do
			local a=k==def.k
			t.pg.Visible=a
			tw(t.btn,{BackgroundColor3=a and C.CARD or C.SIDE})
			tw(t.ind,{BackgroundTransparency=a and 0 or 1})
			tw(t.nm,{TextColor3=a and t.c or C.DIM})
			tw(t.ic,{TextColor3=a and t.c or C.DIM})
		end
	end)
end

local function P(k) return PAGES[k] end

local function sec(p,t,col)
	local f=Instance.new("Frame")
	f.Size=UDim2.new(1,0,0,22)
	f.BackgroundTransparency=1
	f.BorderSizePixel=0
	f.Parent=p
	local ln=Instance.new("Frame")
	ln.Size=UDim2.new(1,0,0,1)
	ln.Position=UDim2.new(0,0,0.5,0)
	ln.BackgroundColor3=C.BORDER
	ln.BorderSizePixel=0
	ln.Parent=f
	local lb=tx(f,"  "..t.."  ",9,col or C.GOLD,Enum.Font.GothamBold)
	lb.Size=UDim2.new(0,0,1,0)
	lb.AutomaticSize=Enum.AutomaticSize.X
	lb.Position=UDim2.new(0,2,0,0)
	lb.BackgroundColor3=C.PANEL
	pd(lb,0,0,2,2)
end

local function tog(p,lab,sub,col,key,cb)
	local on=st[key] or false
	local f=Instance.new("Frame")
	f.Size=UDim2.new(1,0,0,sub and 46 or 32)
	f.BackgroundColor3=C.CARD
	f.BorderSizePixel=0
	f.Parent=p
	co(f,5)

	local bar=Instance.new("Frame")
	bar.Size=UDim2.new(0,2,0.52,0)
	bar.Position=UDim2.new(0,0,0.24,0)
	bar.BackgroundColor3=col or C.BORDER
	bar.BorderSizePixel=0
	bar.Parent=f
	co(bar,2)

	local ml=tx(f,lab,11,C.TEXT,Enum.Font.Gotham)
	ml.Size=UDim2.new(1,-54,0,16)
	ml.Position=UDim2.new(0,10,0,sub and 6 or 8)

	if sub then
		local sl=tx(f,sub,9,C.DIM,Enum.Font.Gotham)
		sl.Size=UDim2.new(1,-54,0,12)
		sl.Position=UDim2.new(0,10,0,23)
	end

	local tr=Instance.new("Frame")
	tr.Size=UDim2.new(0,30,0,15)
	tr.Position=UDim2.new(1,-38,0.5,-7)
	tr.BackgroundColor3=on and C.GREEN or C.OFF
	tr.BorderSizePixel=0
	tr.Parent=f
	co(tr,99)
	sk(tr,C.BORDER,1)

	local kn=Instance.new("Frame")
	kn.Size=UDim2.new(0,9,0,9)
	kn.Position=on and UDim2.new(0,18,0.5,-4) or UDim2.new(0,2,0.5,-4)
	kn.BackgroundColor3=on and Color3.new(1,1,1) or C.DIM
	kn.BorderSizePixel=0
	kn.Parent=tr
	co(kn,99)

	local cb2=Instance.new("TextButton")
	cb2.Size=UDim2.new(1,0,1,0)
	cb2.BackgroundTransparency=1
	cb2.Text=""
	cb2.Parent=f

	cb2.MouseButton1Click:Connect(function()
		on=not on
		st[key]=on
		tw(tr,{BackgroundColor3=on and C.GREEN or C.OFF})
		tw(kn,{Position=on and UDim2.new(0,18,0.5,-4) or UDim2.new(0,2,0.5,-4)})
		tw(kn,{BackgroundColor3=on and Color3.new(1,1,1) or C.DIM})
		if cb then pcall(cb,on) end
	end)

	f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
	f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
end

local function sld(p,lab,mn,mx,def,key,col,cb)
	local f=Instance.new("Frame")
	f.Size=UDim2.new(1,0,0,48)
	f.BackgroundColor3=C.CARD
	f.BorderSizePixel=0
	f.Parent=p
	co(f,5)

	local ml=tx(f,lab,11,C.TEXT,Enum.Font.Gotham)
	ml.Size=UDim2.new(0.62,0,0,15)
	ml.Position=UDim2.new(0,10,0,5)

	local vl=tx(f,tostring(def),11,col or C.RED2,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
	vl.Size=UDim2.new(0.34,0,0,15)
	vl.Position=UDim2.new(0.64,0,0,5)

	local tr=Instance.new("Frame")
	tr.Size=UDim2.new(1,-20,0,3)
	tr.Position=UDim2.new(0,10,0,32)
	tr.BackgroundColor3=C.OFF
	tr.BorderSizePixel=0
	tr.Parent=f
	co(tr,99)

	local pct=(def-mn)/(mx-mn)
	local fi=Instance.new("Frame")
	fi.Size=UDim2.new(pct,0,1,0)
	fi.BackgroundColor3=col or C.RED
	fi.BorderSizePixel=0
	fi.Parent=tr
	co(fi,99)

	local th=Instance.new("Frame")
	th.Size=UDim2.new(0,10,0,10)
	th.AnchorPoint=Vector2.new(0.5,0.5)
	th.Position=UDim2.new(pct,0,0.5,0)
	th.BackgroundColor3=Color3.new(1,1,1)
	th.BorderSizePixel=0
	th.Parent=tr
	co(th,99)

	local drag=false
	local function upd(x)
		local a=tr.AbsolutePosition.X
		local s=tr.AbsoluteSize.X
		local pp=math.clamp((x-a)/s,0,1)
		local v=math.round(mn+(mx-mn)*pp)
		tw(fi,{Size=UDim2.new(pp,0,1,0)})
		th.Position=UDim2.new(pp,0,0.5,0)
		vl.Text=tostring(v)
		st[key]=v
		if cb then pcall(cb,v) end
	end
	tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true upd(i.Position.X) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
	UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)

	f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
	f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
end

local function btn(p,t,col,cb)
	local f=Instance.new("Frame")
	f.Size=UDim2.new(1,0,0,30)
	f.BackgroundColor3=C.CARD
	f.BorderSizePixel=0
	f.Parent=p
	co(f,5)

	local bar=Instance.new("Frame")
	bar.Size=UDim2.new(0,2,0.52,0)
	bar.Position=UDim2.new(0,0,0.24,0)
	bar.BackgroundColor3=col or C.RED
	bar.BorderSizePixel=0
	bar.Parent=f
	co(bar,2)

	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,-16,0,20)
	b.Position=UDim2.new(0,10,0.5,-10)
	b.BackgroundColor3=col or C.RED
	b.BackgroundTransparency=0.84
	b.Text=t
	b.TextColor3=col or C.RED2
	b.Font=Enum.Font.GothamBold
	b.TextSize=11
	b.BorderSizePixel=0
	b.Parent=f
	co(b,4)

	b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.62}) end)
	b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0.84}) end)
	b.MouseButton1Click:Connect(function()
		tw(b,{BackgroundTransparency=0.18})
		task.delay(0.1,function() tw(b,{BackgroundTransparency=0.84}) end)
		if cb then pcall(cb) end
	end)
	f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
	f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
end

local function inp(p,lab,ph,key,cb)
	local f=Instance.new("Frame")
	f.Size=UDim2.new(1,0,0,48)
	f.BackgroundColor3=C.CARD
	f.BorderSizePixel=0
	f.Parent=p
	co(f,5)

	local ml=tx(f,lab,10,C.DIM,Enum.Font.Gotham)
	ml.Size=UDim2.new(1,-10,0,14)
	ml.Position=UDim2.new(0,10,0,5)

	local bx=Instance.new("TextBox")
	bx.Size=UDim2.new(1,-20,0,20)
	bx.Position=UDim2.new(0,10,0,22)
	bx.BackgroundColor3=C.BG
	bx.Text=""
	bx.PlaceholderText=ph or ""
	bx.PlaceholderColor3=C.MUTED
	bx.TextColor3=C.TEXT
	bx.Font=Enum.Font.Gotham
	bx.TextSize=11
	bx.TextXAlignment=Enum.TextXAlignment.Left
	bx.BorderSizePixel=0
	bx.Parent=f
	co(bx,4)
	sk(bx,C.BORDER)
	pd(bx,0,0,7,7)

	bx.Focused:Connect(function() tw(bx,{BackgroundColor3=C.CARD}) end)
	bx.FocusLost:Connect(function(enter)
		tw(bx,{BackgroundColor3=C.BG})
		if key then st[key]=bx.Text end
		if enter and cb then pcall(cb,bx.Text) end
	end)

	f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
	f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
	return bx
end

local function drp(p,lab,opts,key,cb)
	local f=Instance.new("Frame")
	f.Size=UDim2.new(1,0,0,48)
	f.BackgroundColor3=C.CARD
	f.BorderSizePixel=0
	f.ClipsDescendants=false
	f.ZIndex=5
	f.Parent=p
	co(f,5)

	local ml=tx(f,lab,10,C.DIM,Enum.Font.Gotham)
	ml.Size=UDim2.new(1,-10,0,14)
	ml.Position=UDim2.new(0,10,0,5)
	ml.ZIndex=5

	local db=Instance.new("TextButton")
	db.Size=UDim2.new(1,-20,0,20)
	db.Position=UDim2.new(0,10,0,22)
	db.BackgroundColor3=C.BG
	db.Text=(opts[1] or "Select").."  ▾"
	db.TextColor3=C.TEXT
	db.Font=Enum.Font.Gotham
	db.TextSize=11
	db.TextXAlignment=Enum.TextXAlignment.Left
	db.BorderSizePixel=0
	db.ZIndex=6
	db.Parent=f
	co(db,4)
	sk(db,C.BORDER)
	pd(db,0,0,7,0)

	local mn=Instance.new("Frame")
	mn.Size=UDim2.new(1,-20,0,#opts*22)
	mn.Position=UDim2.new(0,10,0,46)
	mn.BackgroundColor3=C.SIDE
	mn.BorderSizePixel=0
	mn.Visible=false
	mn.ZIndex=20
	mn.Parent=f
	co(mn,5)
	sk(mn,C.BORDER)
	ll(mn,0)

	for _,opt in ipairs(opts) do
		local ob=Instance.new("TextButton")
		ob.Size=UDim2.new(1,0,0,22)
		ob.BackgroundColor3=C.SIDE
		ob.Text=opt
		ob.TextColor3=C.TEXT
		ob.Font=Enum.Font.Gotham
		ob.TextSize=11
		ob.TextXAlignment=Enum.TextXAlignment.Left
		ob.BorderSizePixel=0
		ob.ZIndex=21
		ob.Parent=mn
		pd(ob,0,0,8,0)
		ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=C.CARD}) end)
		ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=C.SIDE}) end)
		ob.MouseButton1Click:Connect(function()
			db.Text=opt.."  ▾"
			mn.Visible=false
			f.Size=UDim2.new(1,0,0,48)
			if key then st[key]=opt end
			if cb then pcall(cb,opt) end
		end)
	end

	local open=false
	db.MouseButton1Click:Connect(function()
		open=not open
		mn.Visible=open
		f.Size=open and UDim2.new(1,0,0,48+#opts*22) or UDim2.new(1,0,0,48)
	end)

	f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.CARDH}) end)
	f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.CARD}) end)
end

local function sp(p,h) local s=Instance.new("Frame") s.Size=UDim2.new(1,0,0,h or 3) s.BackgroundTransparency=1 s.Parent=p end

local notifGui=Instance.new("ScreenGui")
notifGui.Name="VD_NF"
notifGui.ResetOnSpawn=false
notifGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
notifGui.IgnoreGuiInset=true
notifGui.DisplayOrder=101
notifGui.Parent=lpGui

local notifY=0
local function notif(msg)
	local f=Instance.new("Frame")
	f.Size=UDim2.new(0,225,0,30)
	f.Position=UDim2.new(1,-235,1,-(42+notifY))
	f.BackgroundColor3=C.CARD
	f.BorderSizePixel=0
	f.Parent=notifGui
	co(f,6)
	sk(f,C.BORDER)
	local d=Instance.new("Frame")
	d.Size=UDim2.new(0,4,0.6,0)
	d.Position=UDim2.new(0,0,0.2,0)
	d.BackgroundColor3=C.RED
	d.BorderSizePixel=0
	d.Parent=f
	co(d,2)
	local ml=tx(f,msg,11,C.TEXT,Enum.Font.Gotham)
	ml.Size=UDim2.new(1,-14,1,0)
	ml.Position=UDim2.new(0,10,0,0)
	notifY=notifY+34
	task.delay(2.8,function()
		tw(f,{BackgroundTransparency=1,Position=UDim2.new(1,0,f.Position.Y.Scale,f.Position.Y.Offset)},TIS)
		task.delay(0.3,function() f:Destroy() notifY=math.max(0,notifY-34) end)
	end)
end

local m1=P("main")
sec(m1,"GENERATORS",C.GOLD)
tog(m1,"Anti Fail Generator","Auto-prevents generator failures",C.GOLD,"antifail",function(on)
	cc("antifail")
	if on then
		cn["antifail"]=RunService.Heartbeat:Connect(function()
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("NumberValue") and v.Name=="FailChance" then v.Value=0 end
				if v:IsA("NumberValue") and v.Name=="FailProgress" then v.Value=0 end
			end
		end)
	end
	notif(on and "Anti Fail Generator ON" or "Anti Fail Generator OFF")
end)
tog(m1,"Auto Perfect Skill-Check","Auto-hits the perfect zone",C.GOLD,"autoskill",function(on)
	cc("autoskill")
	if on then
		cn["autoskill"]=RunService.Heartbeat:Connect(function()
			for _,gui in pairs(lp.PlayerGui:GetDescendants()) do
				if (gui.Name:lower():find("skillcheck") or gui.Name:lower():find("skill_check")) then
					local arr=gui:FindFirstChildWhichIsA("ImageLabel",true) or gui:FindFirstChildWhichIsA("Frame",true)
					if arr and arr:FindFirstChildOfClass("UIRotation") then
						arr:FindFirstChildOfClass("UIRotation").Angle=90
					end
					if arr and arr:IsA("ImageLabel") then arr.Rotation=90 end
				end
			end
		end)
	end
	notif(on and "Auto Skill-Check ON" or "Auto Skill-Check OFF")
end)

local m2=P("survivor")
sec(m2,"MOVEMENT",C.CYAN)
tog(m2,"No Fall","Prevents all fall damage",C.CYAN,"nofall",function(on)
	cc("nofall")
	if on then
		cn["nofall"]=RunService.Heartbeat:Connect(function()
			local hm=gHm()
			if hm and hm:GetState()==Enum.HumanoidStateType.FallingDown then
				hm:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
	notif(on and "No Fall ON" or "No Fall OFF")
end)
tog(m2,"No Turn Speed Limit","Removes turn speed cap",C.CYAN,"noturn",function(on)
	local hm=gHm()
	if hm then hm.AutoRotate=not on end
	notif(on and "No Turn Limit ON" or "No Turn Limit OFF")
end)
tog(m2,"Auto Escape","Auto-breaks from grabs",C.CYAN,"autoescape",function(on)
	cc("autoescape")
	if on then
		cn["autoescape"]=RunService.Heartbeat:Connect(function()
			local c=gC() if not c then return end
			for _,v in pairs(c:GetDescendants()) do
				if v:IsA("BoolValue") and (v.Name=="IsGrabbed" or v.Name=="Grabbed" or v.Name=="IsCaught") then
					if v.Value then v.Value=false end
				end
			end
		end)
	end
	notif(on and "Auto Escape ON" or "Auto Escape OFF")
end)
sec(m2,"COMBAT",C.CYAN)
tog(m2,"Auto Parry","Auto-parries incoming hits",C.CYAN,"autoparry",function(on)
	cc("autoparry")
	if on then
		cn["autoparry"]=RunService.Heartbeat:Connect(function()
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("RemoteEvent") and (v.Name:lower():find("parry") or v.Name:lower():find("block")) then
					pcall(function() v:FireServer() end)
				end
			end
		end)
	end
	notif(on and "Auto Parry ON" or "Auto Parry OFF")
end)
tog(m2,"Instant Heal Others","Instantly heals all survivors",C.CYAN,"instheal",function(on)
	cc("instheal")
	if on then
		cn["instheal"]=RunService.Heartbeat:Connect(function()
			for _,p in ipairs(Players:GetPlayers()) do
				if p~=lp and p.Character then
					local h=p.Character:FindFirstChildOfClass("Humanoid")
					if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
				end
			end
		end)
	end
	notif(on and "Heal Others ON" or "Heal Others OFF")
end)
tog(m2,"Invisible (OP)","Full character invisibility",C.CYAN,"invis",function(on)
	local c=gC() if not c then return end
	for _,p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
			tw(p,{Transparency=on and 1 or 0})
		end
		if p:IsA("Decal") or p:IsA("SpecialMesh") then p.Transparency=on and 1 or 0 end
	end
	notif(on and "Invisible ON" or "Invisible OFF")
end)
tog(m2,"Invisible Effect","Flicker invisibility effect",C.CYAN,"invisefx",function(on)
	cc("invisefx")
	if on then
		cn["invisefx"]=RunService.Heartbeat:Connect(function()
			local c=gC() if not c then return end
			local t=math.sin(tick()*9)>0 and 0.94 or 0.22
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
					p.LocalTransparencyModifier=t
				end
			end
		end)
	else
		local c=gC()
		if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier=0 end end end
	end
	notif(on and "Invis Effect ON" or "Invis Effect OFF")
end)
tog(m2,"Invisible Button (mobile)","Creates mobile invis button",C.CYAN,"invisbtn",function(on)
	local ex=lpGui:FindFirstChild("VD_MobileInvis")
	if on then
		if not ex then
			local sg=Instance.new("ScreenGui") sg.Name="VD_MobileInvis" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.Parent=lpGui
			local mb=Instance.new("TextButton")
			mb.Size=UDim2.new(0,64,0,64)
			mb.Position=UDim2.new(0.85,0,0.75,0)
			mb.BackgroundColor3=C.RED
			mb.BackgroundTransparency=0.25
			mb.Text="INVIS"
			mb.TextColor3=Color3.new(1,1,1)
			mb.Font=Enum.Font.GothamBold
			mb.TextSize=11
			mb.BorderSizePixel=0
			mb.Active=true
			mb.Parent=sg
			co(mb,99)
			mb.MouseButton1Click:Connect(function()
				st.invis=not st.invis
				local c=gC() if not c then return end
				for _,p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
						tw(p,{Transparency=st.invis and 1 or 0})
					end
				end
			end)
		end
	else
		if ex then ex:Destroy() end
	end
	notif(on and "Mobile Invis Button ON" or "Mobile Invis Button OFF")
end)
tog(m2,"Grab Nearest (OP)","Grabs the nearest player",C.CYAN,"grab",function(on)
	if not on then st.grab=false notif("Grab OFF") return end
	local hrp=gH() if not hrp then return end
	local near,d=nil,math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
			if dd<d then near=p d=dd end
		end
	end
	if near then
		for _,v in pairs(workspace:GetDescendants()) do
			if v:IsA("RemoteEvent") and v.Name:lower():find("grab") then
				pcall(function() v:FireServer(near.Character) end)
			end
		end
		notif("Grabbed: "..near.Name)
	end
	st.grab=false
end)
tog(m2,"Instant Escape","Instantly breaks captures",C.CYAN,"instescape",function(on)
	cc("instescape")
	if on then
		cn["instescape"]=RunService.Heartbeat:Connect(function()
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("RemoteEvent") and (v.Name:lower():find("escape") or v.Name:lower():find("free")) then
					pcall(function() v:FireServer() end)
				end
			end
		end)
	end
	notif(on and "Instant Escape ON" or "Instant Escape OFF")
end)
tog(m2,"Sacrifice Self","Instantly sacrifices yourself",C.CYAN,"sacrifice",function(on)
	if not on then st.sacrifice=false return end
	local hm=gHm() if hm then hm.Health=0 end
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("RemoteEvent") and v.Name:lower():find("sacrifice") then
			pcall(function() v:FireServer() end)
		end
	end
	st.sacrifice=false
	notif("Sacrifice triggered")
end)

local m3=P("killer")
sec(m3,"POWER",C.RED)
tog(m3,"Full Generator Break","Breaks all gen progress",C.RED,"genbreak",function(on)
	cc("genbreak")
	if on then
		cn["genbreak"]=RunService.Heartbeat:Connect(function()
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("NumberValue") and v.Name=="Progress" then v.Value=0 end
			end
		end)
	end
	notif(on and "Gen Break ON" or "Gen Break OFF")
end)
tog(m3,"Anti Blind","Removes all blind effects",C.RED,"antiblind",function(on)
	cc("antiblind")
	if on then
		cn["antiblind"]=RunService.Heartbeat:Connect(function()
			for _,v in pairs(lp.PlayerGui:GetDescendants()) do
				if v:IsA("Frame") or v:IsA("ImageLabel") then
					if v.Name:lower():find("blind") or v.Name:lower():find("flash") then
						v.Visible=false
					end
				end
			end
			local ce=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
			if ce then ce.Brightness=0 end
		end)
	end
	notif(on and "Anti Blind ON" or "Anti Blind OFF")
end)
tog(m3,"No Slowdown","No post-hit slowdown",C.RED,"noslowdown",function(on)
	cc("noslowdown")
	if on then
		cn["noslowdown"]=RunService.Heartbeat:Connect(function()
			local hm=gHm()
			if hm and hm.WalkSpeed<14 then hm.WalkSpeed=st.speedval or 16 end
		end)
	end
	notif(on and "No Slowdown ON" or "No Slowdown OFF")
end)
tog(m3,"Infinite Lunge","Unlimited lunge/cooldown",C.RED,"influnge",function(on)
	cc("influnge")
	if on then
		cn["influnge"]=RunService.Heartbeat:Connect(function()
			local c=gC() if not c then return end
			for _,v in pairs(c:GetDescendants()) do
				if v:IsA("NumberValue") and v.Name:lower():find("lunge") then v.Value=0 end
			end
		end)
	end
	notif(on and "Infinite Lunge ON" or "Infinite Lunge OFF")
end)
tog(m3,"Double Tap","Instantly downs on melee",C.RED,"doubletap",function(on)
	cc("doubletap")
	if on then
		cn["doubletap"]=RunService.Heartbeat:Connect(function()
			local hrp=gH() if not hrp then return end
			for _,p in ipairs(Players:GetPlayers()) do
				if p~=lp and p.Character then
					local ph=p.Character:FindFirstChild("HumanoidRootPart")
					if ph and (ph.Position-hrp.Position).Magnitude<7 then
						for _,v in pairs(workspace:GetDescendants()) do
							if v:IsA("RemoteEvent") and v.Name:lower():find("hit") then
								pcall(function() v:FireServer(p.Character) end)
							end
						end
					end
				end
			end
		end)
	end
	notif(on and "Double Tap ON" or "Double Tap OFF")
end)
tog(m3,"No Pallet Stun","Removes pallet stun",C.RED,"nopalletstun",function(on)
	cc("nopalletstun")
	if on then
		cn["nopalletstun"]=RunService.Heartbeat:Connect(function()
			local c=gC() if not c then return end
			for _,v in pairs(c:GetDescendants()) do
				if v:IsA("BoolValue") and v.Name:lower():find("stun") then v.Value=false end
			end
		end)
	end
	notif(on and "No Pallet Stun ON" or "No Pallet Stun OFF")
end)
sec(m3,"CAMERA",C.RED)
tog(m3,"Shift Lock","Shift-lock rotation",C.RED,"shiftlock",function(on)
	cc("shiftlock")
	if on then
		cn["shiftlock"]=RunService.RenderStepped:Connect(function()
			local hrp=gH() if not hrp then return end
			local ang=math.atan2(cam.CFrame.LookVector.X,cam.CFrame.LookVector.Z)
			hrp.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,ang,0)
		end)
	end
	notif(on and "Shift Lock ON" or "Shift Lock OFF")
end)
tog(m3,"Third Person","Forces third-person view",C.RED,"thirdperson",function(on)
	notif(on and "Third Person ON" or "Third Person OFF")
end)
tog(m3,"Veil Crosshair","Custom crosshair overlay",C.RED,"crosshair",function(on)
	local ex=lpGui:FindFirstChild("VD_Cross")
	if on then
		if not ex then
			local cg=Instance.new("ScreenGui") cg.Name="VD_Cross" cg.ResetOnSpawn=false cg.IgnoreGuiInset=true cg.Parent=lpGui
			local function mk(w,h,xo,yo)
				local f=Instance.new("Frame") f.Size=UDim2.new(0,w,0,h)
				f.Position=UDim2.new(0.5,xo-w/2,0.5,yo-h/2)
				f.BackgroundColor3=Color3.new(1,1,1) f.BackgroundTransparency=0.15 f.BorderSizePixel=0 f.Parent=cg
			end
			mk(14,1,0,0) mk(1,14,0,0)
			local d=Instance.new("Frame") d.Size=UDim2.new(0,3,0,3)
			d.Position=UDim2.new(0.5,-1,0.5,-1) d.BackgroundColor3=C.RED d.BorderSizePixel=0 d.Parent=cg co(d,99)
		end
	else
		if ex then ex:Destroy() end
	end
	notif(on and "Crosshair ON" or "Crosshair OFF")
end)
sec(m3,"MASK",C.RED)
drp(m3,"Select Mask",{"None","Mask A","Mask B","Mask C","Mask D","Veil"},"selectedmask",function(v) notif("Mask: "..v) end)
btn(m3,"▶  Activate Mask",C.RED,function()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("RemoteEvent") and v.Name:lower():find("mask") then
			pcall(function() v:FireServer("activate",st.selectedmask) end)
		end
	end
	notif("Mask Activated")
end)
btn(m3,"◼  Deactivate Mask",C.DIM,function()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("RemoteEvent") and v.Name:lower():find("mask") then
			pcall(function() v:FireServer("deactivate") end)
		end
	end
	notif("Mask Deactivated")
end)
sec(m3,"HITBOX",C.RED)
tog(m3,"Hitbox Expander","Enlarges enemy hitboxes",C.RED,"hitboxon",function(on)
	cc("hitboxon")
	if on then
		cn["hitboxon"]=RunService.Heartbeat:Connect(function()
			local sz=st.hitboxsz or 5
			for _,p in ipairs(Players:GetPlayers()) do
				if p~=lp and p.Character then
					local hrp=p.Character:FindFirstChild("HumanoidRootPart")
					if hrp then hrp.Size=Vector3.new(sz,sz,sz) end
				end
			end
		end)
	else
		for _,p in ipairs(Players:GetPlayers()) do
			if p~=lp and p.Character then
				local hrp=p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.Size=Vector3.new(2,2,1) end
			end
		end
	end
	notif(on and "Hitbox Expander ON" or "Hitbox Expander OFF")
end)
sld(m3,"Hitbox Size",1,30,5,"hitboxsz",C.RED,function(v) notif("Hitbox size: "..v) end)
sec(m3,"MAP",C.RED)
btn(m3,"💥 Destroy All Pallets",C.RED,function()
	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower():find("pallet") and v:IsA("Model") then v:Destroy() end
	end
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("RemoteEvent") and v.Name:lower():find("pallet") then
			pcall(function() v:FireServer("destroy") end)
		end
	end
	notif("All pallets destroyed")
end)

local m4=P("fling")
sec(m4,"FLING",C.PURPLE)
btn(m4,"▶  Fling Nearest",C.PURPLE,function()
	local hrp=gH() if not hrp then return end
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
			local fs=st.flingstr or 200
			local bv=Instance.new("BodyVelocity")
			bv.Velocity=Vector3.new(math.random(-1,1)*fs,fs,math.random(-1,1)*fs)
			bv.MaxForce=Vector3.new(1e9,1e9,1e9)
			bv.Parent=nh
			game:GetService("Debris"):AddItem(bv,0.12)
			notif("Flung: "..near.Name)
		end
	end
end)
btn(m4,"▶  Fling All",C.PURPLE,function()
	local wl={}
	for w in (st.flingwl or ""):gmatch("[^,]+") do wl[w:match("^%s*(.-)%s*$")]=true end
	local count=0
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=lp and not wl[p.Name] and p.Character then
			local nh=p.Character:FindFirstChild("HumanoidRootPart")
			if nh then
				local fs=st.flingstr or 200
				local bv=Instance.new("BodyVelocity")
				bv.Velocity=Vector3.new(math.random(-1,1)*fs,fs,math.random(-1,1)*fs)
				bv.MaxForce=Vector3.new(1e9,1e9,1e9)
				bv.Parent=nh
				game:GetService("Debris"):AddItem(bv,0.12)
				count=count+1
			end
		end
	end
	notif("Flung "..count.." players")
end)
sld(m4,"Fling Strength",1,2000,200,"flingstr",C.PURPLE,function(v) notif("Fling strength: "..v) end)
inp(m4,"Fling Whitelist","Player1, Player2...","flingwl")

local m5=P("sound")
sec(m5,"SOUND PLAYER",C.GREEN)
local sndBox=inp(m5,"Sound ID","rbxassetid://...","soundid")
sld(m5,"Distance",1,1000,100,"sounddist",C.GREEN)
sld(m5,"Volume",0,10,5,"soundvol",C.GREEN)
btn(m5,"▶  Play Sound",C.GREEN,function()
	local ex=workspace:FindFirstChild("VD_SND") if ex then ex:Destroy() end
	local snd=Instance.new("Sound")
	snd.Name="VD_SND"
	local id=st.soundid or ""
	snd.SoundId=id:find("rbxassetid") and id or ("rbxassetid://"..id)
	snd.RollOffMaxDistance=st.sounddist or 100
	snd.Volume=(st.soundvol or 5)/10*2
	snd.Parent=workspace
	snd:Play()
	notif("Playing sound")
end)
btn(m5,"■  Stop Sound",C.DIM,function()
	local s=workspace:FindFirstChild("VD_SND") if s then s:Destroy() end notif("Sound stopped")
end)

local m6=P("emotes")
sec(m6,"EMOTES",C.ORANGE)
drp(m6,"Select Emote",{"Wave","Dance","Dance2","Dance3","Laugh","Cheer","Cry","Point","Salute","Shrug","Zombie","Stadium"},"selemote",function(v) notif("Emote: "..v) end)
btn(m6,"▶  Play Emote",C.ORANGE,function()
	local ids={
		Wave="507770239",Dance="507771019",Dance2="507776043",Dance3="507777268",
		Laugh="507770818",Cheer="507770453",Cry="501694108",Point="507770453",
		Salute="3360689775",Shrug="3360692915",Zombie="3360825058",Stadium="3360727776"
	}
	local id=ids[st.selemote] or "507770239"
	local hm=gHm() if not hm then notif("No character") return end
	local anim=Instance.new("Animation") anim.AnimationId="rbxassetid://"..id
	local t=hm:LoadAnimation(anim) t:Play()
	notif("Emote: "..(st.selemote or "Wave"))
end)

local m7=P("player")
sec(m7,"SPEED",C.BLUE)
tog(m7,"Speed Boost","Activates custom speed",C.BLUE,"speedon",function(on)
	local hm=gHm() if hm then hm.WalkSpeed=on and (st.speedval or 16) or 16 end
	notif(on and "Speed: "..(st.speedval or 16) or "Speed reset")
end)
sld(m7,"Speed Value",1,300,16,"speedval",C.BLUE,function(v)
	if st.speedon then local hm=gHm() if hm then hm.WalkSpeed=v end end
end)
drp(m7,"Speed Method",{"Attribute","TP (Teleport)","BodyVelocity"},"speedmethod",function(v) notif("Method: "..v) end)
inp(m7,"Speed Keybind","e.g. E","speedkeystr",function(v)
	local k=Enum.KeyCode[v:upper()]
	if k then st.speedkey=k notif("Speed key: "..v) end
end)
sec(m7,"PHYSICS",C.BLUE)
sld(m7,"Jump Power",1,500,50,"jumppower",C.BLUE,function(v)
	local hm=gHm() if hm then hm.JumpPower=v end
end)
sld(m7,"Hip Height",0,20,0,"hipheight",C.BLUE,function(v)
	local hm=gHm() if hm then hm.HipHeight=v end
end)
tog(m7,"Infinite Jump","Jump again mid-air",C.BLUE,"infjump",function(on)
	cc("infjump")
	if on then
		cn["infjump"]=UserInputService.JumpRequest:Connect(function()
			local hm=gHm() if hm then hm:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	end
	notif(on and "Infinite Jump ON" or "Infinite Jump OFF")
end)
tog(m7,"Freeze Self","Anchors your character",C.BLUE,"freeze",function(on)
	local hrp=gH() if hrp then hrp.Anchored=on end
	notif(on and "Frozen" or "Unfrozen")
end)
sec(m7,"CAMERA",C.BLUE)
sld(m7,"FOV Changer",30,140,70,"fov",C.BLUE,function(v) cam.FieldOfView=v end)
sec(m7,"FLY / NOCLIP",C.BLUE)
tog(m7,"Noclip","Walk through objects",C.BLUE,"noclip",function(on)
	cc("noclip")
	if on then
		cn["noclip"]=RunService.Stepped:Connect(function()
			local c=gC() if not c then return end
			for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
		end)
	else
		local c=gC()
		if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
	end
	notif(on and "Noclip ON" or "Noclip OFF")
end)

local flyBV,flyBG
tog(m7,"Fly","Enables flight",C.BLUE,"fly",function(on)
	cc("fly")
	if flyBV then pcall(function() flyBV:Destroy() end) flyBV=nil end
	if flyBG then pcall(function() flyBG:Destroy() end) flyBG=nil end
	if on then
		local hrp=gH() if not hrp then return end
		flyBV=Instance.new("BodyVelocity")
		flyBV.MaxForce=Vector3.new(1e9,1e9,1e9)
		flyBV.Velocity=Vector3.zero
		flyBV.Parent=hrp
		flyBG=Instance.new("BodyGyro")
		flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9)
		flyBG.D=100
		flyBG.Parent=hrp
		cn["fly"]=RunService.Heartbeat:Connect(function()
			if not st.fly then return end
			local hrp2=gH() if not hrp2 then return end
			local spd=st.flyspeed or 50
			local v=Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then v=v+cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then v=v-cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then v=v-cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then v=v+cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v=v+Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,1,0) end
			if flyBV and flyBV.Parent then flyBV.Velocity=v.Magnitude>0 and v.Unit*spd or Vector3.zero end
			if flyBG and flyBG.Parent then flyBG.CFrame=cam.CFrame end
		end)
	end
	notif(on and "Fly ON (WASD+Space/Ctrl)" or "Fly OFF")
end)
drp(m7,"Fly Mode",{"Velocity","CFrame"},"flymode",function(v) notif("Fly mode: "..v) end)
sld(m7,"Fly Speed",1,400,50,"flyspeed",C.BLUE)

local m8=P("esp")
sec(m8,"PLAYER ESP",C.CYAN)
tog(m8,"Toggle ESP (Master)","Master on/off for all ESP",C.CYAN,"espon",function(on)
	if not on then
		for _,c in pairs(gC and gC() and {} or {}) do end
		for _,p in ipairs(Players:GetPlayers()) do
			if p.Character then
				local h=p.Character:FindFirstChild("VD_HL")
				if h then h:Destroy() end
				local hrp=p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then local b=hrp:FindFirstChild("VD_BB") if b then b:Destroy() end end
			end
		end
	end
	notif(on and "ESP ON" or "ESP OFF")
end)
tog(m8,"2D Boxes",nil,C.CYAN,"esp2d")
tog(m8,"3D Boxes",nil,C.CYAN,"esp3d")
tog(m8,"Show Names",nil,C.CYAN,"espnames")
tog(m8,"Show Distance",nil,C.CYAN,"espdist")
tog(m8,"Show Weapon",nil,C.CYAN,"espweapon")
tog(m8,"Health Bars",nil,C.CYAN,"esphealthbar")
tog(m8,"Health Text",nil,C.CYAN,"esphealthtxt")
tog(m8,"Tracers",nil,C.CYAN,"esptrace")
tog(m8,"Highlights",nil,C.CYAN,"esphl")
tog(m8,"Off-Screen Arrows",nil,C.CYAN,"esparrows")
sec(m8,"INSTANCE ESP",C.CYAN)
tog(m8,"Generator ESP",nil,C.CYAN,"genesp")
tog(m8,"Hook ESP",nil,C.CYAN,"hookesp")
tog(m8,"Vault ESP",nil,C.CYAN,"vaultesp")
tog(m8,"Pallet ESP",nil,C.CYAN,"palletesp")
tog(m8,"Gate ESP",nil,C.CYAN,"gateesp")
sec(m8,"ESP SETTINGS (PLAYER)",C.CYAN)
tog(m8,"2D Boxes (Instance)",nil,C.CYAN,"inst2dbox")
tog(m8,"3D Boxes (Instance)",nil,C.CYAN,"inst3dbox")
tog(m8,"Show Names (Instance)",nil,C.CYAN,"instnames")
tog(m8,"Show Distance (Instance)",nil,C.CYAN,"instdist")
tog(m8,"Tracers (Instance)",nil,C.CYAN,"insttrace")
tog(m8,"Highlights (Instance)",nil,C.CYAN,"insthl")
tog(m8,"Off-Screen Arrows (Instance)",nil,C.CYAN,"instarrows")
sec(m8,"GLOBAL ESP SETTINGS",C.CYAN)
tog(m8,"Team Color",nil,C.CYAN,"espteamcol")
tog(m8,"Show Teammates",nil,C.CYAN,"espshowteam")
sld(m8,"Line Thickness",1,10,1,"linethick",C.CYAN)
sld(m8,"Highlight Distance",10,5000,500,"highldist",C.CYAN)
sld(m8,"Highlight Budget",1,500,100,"highlbudget",C.CYAN)
sld(m8,"Fill Transparency",0,10,8,"filltrans",C.CYAN)
sld(m8,"Outline Transparency",0,10,0,"outltrans",C.CYAN)
sld(m8,"Arrow Size",1,50,10,"arrowsz",C.CYAN)
sld(m8,"Arrow Radius",50,600,200,"arrowrad",C.CYAN)
sld(m8,"ESP Update Interval",1,60,10,"espupd",C.CYAN)
sld(m8,"ESP Check Interval",1,60,5,"espchk",C.CYAN)

RunService.Heartbeat:Connect(function()
	if not st.espon then return end
	local myhrp=gH()
	if not myhrp then return end
	for _,p in ipairs(Players:GetPlayers()) do
		if p==lp then continue end
		local c=p.Character if not c then continue end
		local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then continue end
		local dist=(hrp.Position-myhrp.Position).Magnitude
		if dist>(st.highldist or 500) then
			local h=c:FindFirstChild("VD_HL") if h then h:Destroy() end
			local b=hrp:FindFirstChild("VD_BB") if b then b:Destroy() end
			continue
		end
		if st.esphl then
			if not c:FindFirstChild("VD_HL") then
				local sb=Instance.new("SelectionBox")
				sb.Name="VD_HL"
				sb.Adornee=c
				sb.Color3=st.espteamcol and lp.TeamColor.Color or C.CYAN
				sb.LineThickness=(st.linethick or 1)/12
				sb.SurfaceTransparency=(st.filltrans or 8)/10
				sb.SurfaceColor3=C.CYAN
				sb.Parent=c
			end
		else
			local h=c:FindFirstChild("VD_HL") if h then h:Destroy() end
		end
		if st.espnames or st.espdist then
			if not hrp:FindFirstChild("VD_BB") then
				local bg=Instance.new("BillboardGui")
				bg.Name="VD_BB"
				bg.Size=UDim2.new(0,180,0,42)
				bg.StudsOffset=Vector3.new(0,3.8,0)
				bg.AlwaysOnTop=true
				bg.Parent=hrp
				local tl=Instance.new("TextLabel")
				tl.Name="T"
				tl.Size=UDim2.new(1,0,1,0)
				tl.BackgroundTransparency=1
				tl.TextColor3=st.espteamcol and lp.TeamColor.Color or C.CYAN
				tl.Font=Enum.Font.GothamBold
				tl.TextSize=12
				tl.Parent=bg
			end
			local bg=hrp:FindFirstChild("VD_BB")
			if bg then
				local tl=bg:FindFirstChild("T")
				if tl then
					local hm=c:FindFirstChildOfClass("Humanoid")
					local hp=hm and math.round(hm.Health).."hp" or ""
					local nm=st.espnames and p.Name or ""
					local ds=st.espdist and "["..math.round(dist).."m]" or ""
					local wp=st.espweapon and hp or ""
					tl.Text=nm.." "..ds.." "..wp
				end
			end
		else
			local b=hrp:FindFirstChild("VD_BB") if b then b:Destroy() end
		end
	end
end)

local m9=P("visuals")
sec(m9,"SHADERS / AMBIENCE",C.PINK)
tog(m9,"Ambience Override","Custom lighting override",C.PINK,"ambience",function(on)
	local ex=Lighting:FindFirstChild("VD_CC")
	if on then
		if not ex then local cc2=Instance.new("ColorCorrectionEffect") cc2.Name="VD_CC" cc2.Parent=Lighting end
	else
		if ex then ex:Destroy() end
	end
	notif(on and "Ambience ON" or "Ambience OFF")
end)
tog(m9,"Force Time","Locks game time of day",C.PINK,"forcetime",function(on)
	cc("forcetime")
	if on then
		cn["forcetime"]=RunService.Heartbeat:Connect(function()
			Lighting.TimeOfDay=string.format("%02d:00:00",st.timeval or 12)
		end)
	end
	notif(on and "Force Time ON" or "Force Time OFF")
end)
sld(m9,"Time Slider (0-23)",0,23,12,"timeval",C.PINK,function(v)
	if st.forcetime then Lighting.TimeOfDay=string.format("%02d:00:00",v) end
end)
tog(m9,"Custom Saturation","Applies color saturation",C.PINK,"custsat",function(on)
	local ce=Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect",Lighting)
	ce.Saturation=on and (st.satval or 5)/5-1 or 0
	notif(on and "Saturation ON" or "Saturation OFF")
end)
sld(m9,"Saturation Density",0,10,5,"satval",C.PINK,function(v)
	if st.custsat then
		local ce=Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
		if ce then ce.Saturation=v/5-1 end
	end
end)
inp(m9,"Skybox Changer","rbxassetid://...","skyboxid",function(v)
	local sky=Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky",Lighting)
	local id=v:find("rbxassetid") and v or "rbxassetid://"..v
	sky.SkyboxBk=id sky.SkyboxDn=id sky.SkyboxFt=id
	sky.SkyboxLf=id sky.SkyboxRt=id sky.SkyboxUp=id
	notif("Skybox applied")
end)
sec(m9,"BODY MODIFIER",C.PINK)
drp(m9,"Material Select",{"SmoothPlastic","Neon","Glass","Metal","Wood","DiamondPlate","Foil","Brick","Marble"},"matsel",function(v)
	local c=gC() if not c then return end
	for _,p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
			pcall(function() p.Material=Enum.Material[v] end)
		end
	end
	notif("Material: "..v)
end)
inp(m9,"Material Color (R,G,B)","255, 100, 100","matcol",function(v)
	local r,g,b=v:match("(%d+),%s*(%d+),%s*(%d+)")
	if r then
		local col=Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b))
		local c=gC() if not c then return end
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
				p.BrickColor=BrickColor.new(col)
			end
		end
		notif("Color applied")
	end
end)
btn(m9,"↺  Reset Appearance",C.DIM,function()
	local c=gC() if not c then return end
	for _,p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") then
			pcall(function() p.Material=Enum.Material.SmoothPlastic end)
			p.Transparency=0
			p.LocalTransparencyModifier=0
		end
	end
	notif("Appearance reset")
end)

local m10=P("aimbot")
sec(m10,"SPEAR AIMBOT",C.RED)
tog(m10,"Spear Aimbot","Auto-aims spear at nearest",C.RED,"spearaim",function(on)
	cc("spearaim")
	if on then
		cn["spearaim"]=RunService.RenderStepped:Connect(function()
			if not st.spearaim then return end
			local sk2=st.spearkey or Enum.KeyCode.E
			if not UserInputService:IsKeyDown(sk2) then return end
			local hrp=gH() if not hrp then return end
			local near,d=nil,math.huge
			for _,p in ipairs(Players:GetPlayers()) do
				if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
					if dd<d then near=p d=dd end
				end
			end
			if near then
				local tp=near.Character.HumanoidRootPart.Position
				local vel=near.Character.HumanoidRootPart.Velocity
				local tt=d/(st.spearspeed or 150)
				local grav=Vector3.new(0,-(st.speargrav or 60),0)
				local pred=tp+vel*tt-grav*tt*tt*0.5
				cam.CFrame=CFrame.lookAt(cam.CFrame.Position,pred)
			end
		end)
	end
	notif(on and "Spear Aimbot ON" or "Spear Aimbot OFF")
end)
inp(m10,"Spear Aim Key","E","spearkeystr",function(v)
	local k=Enum.KeyCode[v:upper()]
	if k then st.spearkey=k notif("Spear key: "..v) end
end)
sld(m10,"Spear Gravity",0,300,60,"speargrav",C.RED)
sld(m10,"Spear Projectile Speed",10,1000,150,"spearspeed",C.RED)
btn(m10,"🎯  Spear Aim Button (MOBILE)",C.RED,function()
	local hrp=gH() if not hrp then return end
	local near,d=nil,math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
			if dd<d then near=p d=dd end
		end
	end
	if near then
		cam.CFrame=CFrame.lookAt(cam.CFrame.Position,near.Character.HumanoidRootPart.Position)
		notif("Aimed at "..near.Name)
	end
end)
tog(m10,"Lock Spear Button","Continuously locks to target",C.RED,"lockspear",function(on)
	cc("lockspear")
	if on then
		cn["lockspear"]=RunService.RenderStepped:Connect(function()
			if not st.lockspear then return end
			local hrp=gH() if not hrp then return end
			local near,d=nil,math.huge
			for _,p in ipairs(Players:GetPlayers()) do
				if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local dd=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
					if dd<d then near=p d=dd end
				end
			end
			if near then cam.CFrame=CFrame.lookAt(cam.CFrame.Position,near.Character.HumanoidRootPart.Position) end
		end)
	end
	notif(on and "Lock Spear ON" or "Lock Spear OFF")
end)
sld(m10,"Spear Button Size (Mobile)",20,200,80,"spearbtnsz",C.RED)
sec(m10,"GUN SILENT AIM",C.RED)
tog(m10,"Gun Silent Aim","Redirects shots to target part",C.RED,"gunsilent",function(on)
	notif(on and "Silent Aim ON" or "Silent Aim OFF (restart to fully reset)")
end)
drp(m10,"Gun Silent Aim Part",{"Head","HumanoidRootPart","UpperTorso","Torso","LowerTorso"},"silentpart",function(v)
	notif("Silent aim part: "..v)
end)

TABS["main"].btn.MouseButton1Click:Fire()

lp.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart")
	local hm=char:WaitForChild("Humanoid")
	if st.speedon then hm.WalkSpeed=st.speedval or 16 end
	if st.jumppower then hm.JumpPower=st.jumppower end
	if st.hipheight then hm.HipHeight=st.hipheight end
	if st.fov then cam.FieldOfView=st.fov end
	if st.noclip then
		cc("noclip")
		cn["noclip"]=RunService.Stepped:Connect(function()
			for _,p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide=false end
			end
		end)
	end
	if st.freeze then
		local hrp=char:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored=true end
	end
end)

tw(Win,{BackgroundTransparency=0},TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out))
notif("Violence District v1.3 loaded")
