local plot = game.Players.LocalPlayer.Plot.Value
local tws = 25
local sdb = 1
local anc = false

local nex = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shaypishgithub/megahack/refs/heads/main/library/hubs'),true))()
local window = nex.CreateWindow("EBAL HUB")
local mon = window:CreateTab("Base")
mon:CreateLabel("Your Plot: ".. game.Players.LocalPlayer.Plot.Value.Name)
mon:CreateButton("Collect All Cash (Once)",function()
for i, a in plot.Floors:GetDescendants() do
if a.Name == "CollectPartTouch" then firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,a,1) task.wait(.1) firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,a,0) end
end
end)
mon:CreateButton("Pick Up All Computers",function() for i,a in plot.Floors:GetDescendants() do
if a.Name == "ProximityPrompt" and a.Parent.Name == "Top" and a.Parent.Parent:FindFirstChild("VisualModel")  then
fireproximityprompt(a)
end
end
 end)
mon:CreateButton("Place All Computers",function() 
for i,a in game.Players.LocalPlayer.Backpack:GetChildren() do
if a:FindFirstChild("ItemGUI") then
a.Parent = game.Players.LocalPlayer.Character
local topla = nil
local stop = false
stop = false
for i,b in plot.Floors:GetDescendants() do
if b:FindFirstChild("Top") and not b:FindFirstChild("VisualModel") and stop == false then
stop = true
fireproximityprompt(b.Top.ProximityPrompt)
end
end
stop = false
task.wait(.5)
end
end
end)
mon:CreateButton("Sell All Computers",function()
window:Ask("ARE YOU SURE?",{"Yes","No"},function(as)
if as == "Yes" then
for i,a in plot.Floors:GetDescendants() do
if a.Name == "SellProximity" and a.Parent.Parent:FindFirstChild("VisualModel") then
window:Notify("Sold: ".. a.Parent.Parent.VisualModel:FindFirstChildWhichIsA("MeshPart").Name,1,"Info")
fireproximityprompt(a)
end
end
end
end) 
end)
local vid = window:CreateTab("Card")
vid:CreateButton("Place Gc.Card",function()
for i,b in game.Players.LocalPlayer.Backpack:GetChildren() do
if not b:FindFirstChild("ItemGui") then
b.Parent = game.Players.LocalPlayer.Character
for i,a in plot.Floors:GetDescendants() do
if a:FindFirstChild("VisualModel") then
fireproximityprompt(a:FindFirstChild("Top"):FindFirstChild("ProximityPrompt"))
task.wait(.5)
end
end
end
end
end)
local upgr = false
local upg = window:CreateTab("Upgraade")
local mone = window:CreateTab("Sell")
upg:CreateToggle("Auto Upgrade All",false,function(v) upgr = v end)
upg:CreateButton("Upgrade All",function()
for i,a in plot.Floors:GetDescendants() do
local b
if a:FindFirstChild("VisualModel") then b = a end
local args = {
	buffer.fromstring("\v\003One"),
	{
		b
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Packet"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end
end)
mone:CreateButton("Sell Thing In A Hand",function()
local args = {
	buffer.fromstring("\015\bEquipped")
}
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Packet"):WaitForChild("RemoteEvent"):FireServer(unpack(args))

end)
local auto = false
local aut = window:CreateTab("Auto")
aut:CreateLabel("AUTOMATION TAB: you can change in settings")
aut:CreateToggle("Auto Money Pick Up",false,function(a)
if a == false then auto = false elseif a == true then auto = true end
end)
task.spawn(function()
while task.wait(1) do
if auto == true then
print(sdb)
for i, a in plot.Floors:GetDescendants() do
if a.Name == "CollectPartTouch" and a.Parent:FindFirstChild("VisualModel") then firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,a,1) task.wait(.1) firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,a,0) task.wait(.1) end
end
end
end
end)
local set = window:CreateTab("Settings")
set:CreateLabel("Settings Tab | Flex your values")
set:CreateSlider("Auto Collect | Cooldown (coming soon)",1,60,1,function(a) sdb = a end)
set:CreateToggle("Anchor HumanoidRootPart On Tween",false,function(a) anc = a end)
task.spawn(function()
while task.wait(2) do
if upgr == true then
for i,a in plot.Floors:GetDescendants() do
local b
if a:FindFirstChild("VisualModel") then b = a end
local args = {
	buffer.fromstring("\v\003One"),
	{
		b
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Packet"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end
end
end
end)







window:Notify("Hub Loaded!",3)
