-- PaulematicHubV2
-- LocalScript in StarterPlayerScripts or StarterGui

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local SECRET_KEY = "paulematic67"

-- ============================================================
-- UTILITIES
-- ============================================================
local function tw(obj, props, t, style, dir)
	return TweenService:Create(obj, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
end
local function blob(parent, col, x, y, sz)
	local b = Instance.new("Frame")
	b.Size = UDim2.new(0,sz,0,sz); b.Position = UDim2.new(0,x,0,y)
	b.BackgroundColor3 = col; b.BackgroundTransparency = 0.74
	b.BorderSizePixel = 0; b.ZIndex = 3; b.Parent = parent
	Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
end
local function corner(obj, r) Instance.new("UICorner",obj).CornerRadius = UDim.new(0, r or 8) end
local function stroke(obj, col, thick) local s=Instance.new("UIStroke",obj); s.Color=col; s.Thickness=thick or 1 end
local function drag(handle, win)
	local dragging, ds, sp
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; ds=i.Position; sp=win.Position end
	end)
	handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - ds
			win.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
		end
	end)
end
local function winBtn(parent, xOff, col, hov)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,12,0,12); b.Position = UDim2.new(0,xOff,0.5,-6)
	b.BackgroundColor3 = col; b.BorderSizePixel = 0; b.Text = ""; b.ZIndex = 9; b.Parent = parent
	corner(b,99)
	b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=hov},0.12):Play() end)
	b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=col},0.12):Play() end)
	return b
end
local function makeAvatar(parent, size, ax, ay)
	local ring = Instance.new("Frame")
	ring.Size=UDim2.new(0,size,0,size); ring.Position=UDim2.new(0,ax,0,ay)
	ring.BackgroundColor3=Color3.fromRGB(70,65,115); ring.BorderSizePixel=0; ring.ZIndex=5; ring.Parent=parent
	corner(ring,99)
	local inner = Instance.new("Frame")
	inner.Size=UDim2.new(0,size-8,0,size-8); inner.Position=UDim2.new(0.5,-(size-8)/2,0.5,-(size-8)/2)
	inner.BackgroundColor3=Color3.fromRGB(22,22,28); inner.BorderSizePixel=0; inner.ZIndex=6; inner.Parent=ring
	corner(inner,99)
	local img = Instance.new("ImageLabel")
	img.Size=UDim2.new(0,size-12,0,size-12); img.Position=UDim2.new(0.5,-(size-12)/2,0.5,-(size-12)/2)
	img.BackgroundTransparency=1; img.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png"
	img.ScaleType=Enum.ScaleType.Crop; img.ZIndex=7; img.Parent=ring; corner(img,99)
	local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,13,0,13); dot.Position=UDim2.new(1,-13,1,-13)
	dot.BackgroundColor3=Color3.fromRGB(50,215,115); dot.BorderSizePixel=0; dot.ZIndex=9; dot.Parent=ring; corner(dot,99)
	local db=Instance.new("UIStroke",dot); db.Color=Color3.fromRGB(14,14,18); db.Thickness=2.5
end

-- ============================================================
-- KEYBIND SYSTEM
-- ============================================================
-- keybinds[keyChar] = { label, callback, toggleState }
local keybinds = {}

-- Listen globally for keypresses and fire matching keybinds
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local keyName = input.KeyCode.Name -- e.g. "P", "F", "G"
	local key = keyName:upper()
	if keybinds[key] then
		keybinds[key].callback()
	end
end)

-- Returns a function to register/update a keybind for a feature
local function registerKeybind(keyChar, label, callback)
	local key = keyChar:upper()
	if key == "" then return end
	keybinds[key] = { label=label, callback=callback }
end
local function unregisterKeybind(keyChar)
	local key = keyChar:upper()
	keybinds[key] = nil
end

-- ============================================================
-- SHARED TOGGLE + KEYBIND ROW BUILDER
-- ============================================================
local function makeSection(parent, text, order)
	local l = Instance.new("TextLabel")
	l.Size=UDim2.new(1,0,0,24); l.BackgroundTransparency=1; l.Text=text
	l.TextColor3=Color3.fromRGB(140,100,200); l.TextSize=11; l.Font=Enum.Font.GothamBold
	l.TextXAlignment=Enum.TextXAlignment.Left; l.LayoutOrder=order; l.ZIndex=23; l.Parent=parent
end

-- makeToggleRow: creates a toggle row WITH a keybind input box
-- callback(isOn) called when toggle changes
-- returns a setter so keybind can also toggle it
local function makeToggleRow(parent, label, desc, order, callback)
	local togOn = false

	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1,0,0,68)
	Row.BackgroundColor3 = Color3.fromRGB(18,16,26)
	Row.BorderSizePixel = 0; Row.LayoutOrder = order; Row.ZIndex = 23; Row.Parent = parent
	corner(Row,10); stroke(Row,Color3.fromRGB(45,30,70))

	-- Label
	local RL = Instance.new("TextLabel")
	RL.Size=UDim2.new(1,-80,0,20); RL.Position=UDim2.new(0,14,0,8)
	RL.BackgroundTransparency=1; RL.Text=label; RL.TextColor3=Color3.fromRGB(215,210,235)
	RL.TextSize=13; RL.Font=Enum.Font.GothamBold; RL.TextXAlignment=Enum.TextXAlignment.Left
	RL.ZIndex=24; RL.Parent=Row

	-- Desc
	local RD = Instance.new("TextLabel")
	RD.Size=UDim2.new(1,-80,0,14); RD.Position=UDim2.new(0,14,0,28)
	RD.BackgroundTransparency=1; RD.Text=desc; RD.TextColor3=Color3.fromRGB(110,100,140)
	RD.TextSize=10; RD.Font=Enum.Font.Gotham; RD.TextXAlignment=Enum.TextXAlignment.Left
	RD.ZIndex=24; RD.Parent=Row

	-- Toggle pill
	local TPill = Instance.new("Frame")
	TPill.Size=UDim2.new(0,42,0,22); TPill.Position=UDim2.new(1,-56,0,8)
	TPill.BackgroundColor3=Color3.fromRGB(40,30,60); TPill.BorderSizePixel=0; TPill.ZIndex=24; TPill.Parent=Row
	corner(TPill,99)
	local TPS=Instance.new("UIStroke",TPill); TPS.Color=Color3.fromRGB(70,50,100); TPS.Thickness=1
	local TKnob=Instance.new("Frame")
	TKnob.Size=UDim2.new(0,16,0,16); TKnob.Position=UDim2.new(0,3,0.5,-8)
	TKnob.BackgroundColor3=Color3.fromRGB(150,130,190); TKnob.BorderSizePixel=0; TKnob.ZIndex=25; TKnob.Parent=TPill
	corner(TKnob,99)

	-- Keybind section (bottom strip)
	local KeyStrip = Instance.new("Frame")
	KeyStrip.Size=UDim2.new(1,-28,0,18); KeyStrip.Position=UDim2.new(0,14,0,46)
	KeyStrip.BackgroundTransparency=1; KeyStrip.ZIndex=24; KeyStrip.Parent=Row

	local KeyLabel = Instance.new("TextLabel")
	KeyLabel.Size=UDim2.new(0,60,1,0); KeyLabel.BackgroundTransparency=1
	KeyLabel.Text="Keybind:"; KeyLabel.TextColor3=Color3.fromRGB(90,85,120)
	KeyLabel.TextSize=10; KeyLabel.Font=Enum.Font.Gotham
	KeyLabel.TextXAlignment=Enum.TextXAlignment.Left; KeyLabel.ZIndex=25; KeyLabel.Parent=KeyStrip

	local KeyBox = Instance.new("Frame")
	KeyBox.Size=UDim2.new(0,32,1,0); KeyBox.Position=UDim2.new(0,62,0,0)
	KeyBox.BackgroundColor3=Color3.fromRGB(26,22,40); KeyBox.BorderSizePixel=0; KeyBox.ZIndex=25; KeyBox.Parent=KeyStrip
	corner(KeyBox,5); stroke(KeyBox,Color3.fromRGB(65,50,100))

	local KeyInput = Instance.new("TextBox")
	KeyInput.Size=UDim2.new(1,0,1,0); KeyInput.BackgroundTransparency=1
	KeyInput.Text=""; KeyInput.PlaceholderText="—"; KeyInput.PlaceholderColor3=Color3.fromRGB(80,70,110)
	KeyInput.TextColor3=Color3.fromRGB(200,180,255); KeyInput.TextSize=11; KeyInput.Font=Enum.Font.GothamBold
	KeyInput.TextXAlignment=Enum.TextXAlignment.Center; KeyInput.ClearTextOnFocus=true
	KeyInput.ZIndex=26; KeyInput.Parent=KeyBox

	local KeyHint = Instance.new("TextLabel")
	KeyHint.Size=UDim2.new(1,-100,1,0); KeyHint.Position=UDim2.new(0,98,0,0)
	KeyHint.BackgroundTransparency=1; KeyHint.Text="(click box, type 1 key)"
	KeyHint.TextColor3=Color3.fromRGB(70,65,95); KeyHint.TextSize=9; KeyHint.Font=Enum.Font.Gotham
	KeyHint.TextXAlignment=Enum.TextXAlignment.Left; KeyHint.ZIndex=25; KeyHint.Parent=KeyStrip

	-- Current bound key for this toggle
	local currentKey = ""

	local function doToggle()
		togOn = not togOn
		if togOn then
			tw(TPill,{BackgroundColor3=Color3.fromRGB(100,50,180)},0.2):Play()
			tw(TPS,{Color=Color3.fromRGB(140,80,220)},0.2):Play()
			tw(TKnob,{Position=UDim2.new(0,23,0.5,-8),BackgroundColor3=Color3.fromRGB(220,200,255)},0.2):Play()
		else
			tw(TPill,{BackgroundColor3=Color3.fromRGB(40,30,60)},0.2):Play()
			tw(TPS,{Color=Color3.fromRGB(70,50,100)},0.2):Play()
			tw(TKnob,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=Color3.fromRGB(150,130,190)},0.2):Play()
		end
		callback(togOn)
	end

	-- Click pill to toggle
	local TBtn = Instance.new("TextButton")
	TBtn.Size=UDim2.new(1,0,1,0); TBtn.BackgroundTransparency=1; TBtn.Text=""
	TBtn.ZIndex=26; TBtn.Parent=TPill
	TBtn.MouseButton1Click:Connect(doToggle)

	-- Keybind input: limit to 1 char, register
	KeyInput.Focused:Connect(function()
		tw(KeyBox,{BackgroundColor3=Color3.fromRGB(35,28,55)},0.15):Play()
		stroke(KeyBox,Color3.fromRGB(110,80,200))
	end)
	KeyInput.FocusLost:Connect(function(enterPressed)
		tw(KeyBox,{BackgroundColor3=Color3.fromRGB(26,22,40)},0.15):Play()
		stroke(KeyBox,Color3.fromRGB(65,50,100))
		local raw = KeyInput.Text:upper():gsub("[^A-Z0-9]",""):sub(1,1)
		-- Unregister old key
		if currentKey ~= "" then
			unregisterKeybind(currentKey)
		end
		currentKey = raw
		KeyInput.Text = raw
		if raw ~= "" then
			registerKeybind(raw, label, doToggle)
			KeyHint.Text = "["..raw.."] bound"
			KeyHint.TextColor3 = Color3.fromRGB(100,200,120)
		else
			KeyHint.Text = "(click box, type 1 key)"
			KeyHint.TextColor3 = Color3.fromRGB(70,65,95)
		end
	end)

	-- Limit to 1 char while typing
	KeyInput:GetPropertyChangedSignal("Text"):Connect(function()
		if #KeyInput.Text > 1 then
			KeyInput.Text = KeyInput.Text:sub(1,1):upper()
		end
	end)

	Row.MouseEnter:Connect(function() tw(Row,{BackgroundColor3=Color3.fromRGB(22,20,32)},0.15):Play() end)
	Row.MouseLeave:Connect(function() tw(Row,{BackgroundColor3=Color3.fromRGB(18,16,26)},0.15):Play() end)

	return doToggle -- expose toggle fn
end

-- ============================================================
-- KEY WINDOW
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "PaulematicHubV2"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.Parent=LocalPlayer:WaitForChild("PlayerGui")

local Backdrop = Instance.new("Frame")
Backdrop.Size=UDim2.new(1,0,1,0); Backdrop.BackgroundColor3=Color3.fromRGB(0,0,0)
Backdrop.BackgroundTransparency=0.55; Backdrop.BorderSizePixel=0; Backdrop.ZIndex=1; Backdrop.Parent=SG

local KW = Instance.new("Frame")
KW.Size=UDim2.new(0,340,0,0); KW.Position=UDim2.new(0.5,-170,0.5,0)
KW.BackgroundColor3=Color3.fromRGB(14,14,18); KW.BorderSizePixel=0; KW.ClipsDescendants=true
KW.ZIndex=2; KW.Parent=SG; corner(KW,14); stroke(KW,Color3.fromRGB(60,60,75))
blob(KW,Color3.fromRGB(60,55,110),-60,-60,180)
blob(KW,Color3.fromRGB(30,80,100),240,230,160)

local KTB = Instance.new("Frame")
KTB.Size=UDim2.new(1,0,0,38); KTB.BackgroundTransparency=1; KTB.ZIndex=8; KTB.Parent=KW
local KClose = winBtn(KTB,14,Color3.fromRGB(210,65,65),Color3.fromRGB(240,90,90))
local KMin   = winBtn(KTB,32,Color3.fromRGB(190,145,30),Color3.fromRGB(230,175,50))
winBtn(KTB,50,Color3.fromRGB(45,175,75),Color3.fromRGB(60,210,95))
drag(KTB,KW)

KClose.MouseButton1Click:Connect(function()
	tw(KW,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In):Play()
	tw(Backdrop,{BackgroundTransparency=1},0.2):Play()
	task.delay(0.22,function() SG:Destroy() end)
end)
local kMinimized=false
KMin.MouseButton1Click:Connect(function()
	kMinimized=not kMinimized
	tw(KW,{Size=kMinimized and UDim2.new(0,340,0,38) or UDim2.new(0,340,0,350)},0.22):Play()
end)

makeAvatar(KW,74,133,48)

local KNameLbl=Instance.new("TextLabel"); KNameLbl.Size=UDim2.new(1,0,0,24); KNameLbl.Position=UDim2.new(0,0,0,132)
KNameLbl.BackgroundTransparency=1; KNameLbl.Text=LocalPlayer.DisplayName; KNameLbl.TextColor3=Color3.fromRGB(235,235,245)
KNameLbl.TextSize=18; KNameLbl.Font=Enum.Font.GothamBold; KNameLbl.ZIndex=5; KNameLbl.Parent=KW

local KHandleLbl=Instance.new("TextLabel"); KHandleLbl.Size=UDim2.new(1,0,0,16); KHandleLbl.Position=UDim2.new(0,0,0,158)
KHandleLbl.BackgroundTransparency=1; KHandleLbl.Text="@"..LocalPlayer.Name.."  •  #"..tostring(LocalPlayer.UserId)
KHandleLbl.TextColor3=Color3.fromRGB(100,100,125); KHandleLbl.TextSize=11; KHandleLbl.Font=Enum.Font.Gotham
KHandleLbl.ZIndex=5; KHandleLbl.Parent=KW

local KDivLine=Instance.new("Frame"); KDivLine.Size=UDim2.new(1,-40,0,1); KDivLine.Position=UDim2.new(0,20,0,184)
KDivLine.BackgroundColor3=Color3.fromRGB(45,45,58); KDivLine.BorderSizePixel=0; KDivLine.ZIndex=5; KDivLine.Parent=KW

local KKeyLbl=Instance.new("TextLabel"); KKeyLbl.Size=UDim2.new(1,-40,0,16); KKeyLbl.Position=UDim2.new(0,20,0,196)
KKeyLbl.BackgroundTransparency=1; KKeyLbl.Text="Enter Key"; KKeyLbl.TextColor3=Color3.fromRGB(140,140,165)
KKeyLbl.TextSize=11; KKeyLbl.Font=Enum.Font.GothamBold; KKeyLbl.TextXAlignment=Enum.TextXAlignment.Left
KKeyLbl.ZIndex=5; KKeyLbl.Parent=KW

local KInputBg=Instance.new("Frame"); KInputBg.Size=UDim2.new(1,-40,0,42); KInputBg.Position=UDim2.new(0,20,0,216)
KInputBg.BackgroundColor3=Color3.fromRGB(22,22,30); KInputBg.BorderSizePixel=0; KInputBg.ZIndex=5; KInputBg.Parent=KW
corner(KInputBg,8); local KIS=Instance.new("UIStroke",KInputBg); KIS.Color=Color3.fromRGB(55,55,72); KIS.Thickness=1

local KLockIco=Instance.new("TextLabel"); KLockIco.Size=UDim2.new(0,30,1,0); KLockIco.BackgroundTransparency=1
KLockIco.Text="🔑"; KLockIco.TextSize=14; KLockIco.Font=Enum.Font.Gotham; KLockIco.ZIndex=6; KLockIco.Parent=KInputBg

local KKeyInput=Instance.new("TextBox"); KKeyInput.Size=UDim2.new(1,-44,1,0); KKeyInput.Position=UDim2.new(0,32,0,0)
KKeyInput.BackgroundTransparency=1; KKeyInput.PlaceholderText="Enter your key..."; KKeyInput.PlaceholderColor3=Color3.fromRGB(70,70,90)
KKeyInput.Text=""; KKeyInput.TextColor3=Color3.fromRGB(210,210,225); KKeyInput.TextSize=13; KKeyInput.Font=Enum.Font.Gotham
KKeyInput.TextXAlignment=Enum.TextXAlignment.Left; KKeyInput.ClearTextOnFocus=false; KKeyInput.ZIndex=6; KKeyInput.Parent=KInputBg
KKeyInput.Focused:Connect(function() tw(KIS,{Color=Color3.fromRGB(100,95,180)},0.2):Play() end)
KKeyInput.FocusLost:Connect(function() tw(KIS,{Color=Color3.fromRGB(55,55,72)},0.2):Play() end)

local KBtn=Instance.new("TextButton"); KBtn.Size=UDim2.new(1,-40,0,40); KBtn.Position=UDim2.new(0,20,0,270)
KBtn.BackgroundColor3=Color3.fromRGB(80,75,150); KBtn.BorderSizePixel=0; KBtn.Text="Unlock"
KBtn.TextColor3=Color3.fromRGB(225,220,255); KBtn.TextSize=13; KBtn.Font=Enum.Font.GothamBold
KBtn.ZIndex=5; KBtn.Parent=KW; corner(KBtn,8); stroke(KBtn,Color3.fromRGB(110,105,190))
KBtn.MouseEnter:Connect(function() tw(KBtn,{BackgroundColor3=Color3.fromRGB(95,90,175)},0.15):Play() end)
KBtn.MouseLeave:Connect(function() tw(KBtn,{BackgroundColor3=Color3.fromRGB(80,75,150)},0.15):Play() end)

-- ============================================================
-- MM2 HUB
-- ============================================================
local function openMM2Hub()
	if LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("MM2Hub") then return end
	local MM2SG=Instance.new("ScreenGui"); MM2SG.Name="MM2Hub"; MM2SG.ResetOnSpawn=false
	MM2SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; MM2SG.Parent=LocalPlayer:WaitForChild("PlayerGui")

	local espHL={}; local espEnabled=false; local espDistConn=nil
	local flyEnabled=false; local flyBV,flyBG,flyConn=nil,nil,nil
	local infJumpConn=nil; local aimlockConn=nil; local aimbotConn=nil
	local aimLerp=0.35
	local noclipConn=nil
	local hitboxConn=nil; local hitboxOrigSizes={}
	local autokillConn=nil
	local sheriffShotConn=nil
	local dodgeConn=nil; local dodgeCooldown=false

	local function getMM2Role(plr)
		local char=plr.Character; if not char then return "innocent" end
		local bp=plr:FindFirstChild("Backpack")
		if char:FindFirstChild("Knife") or char:FindFirstChild("MM2Knife") then return "murderer" end
		if char:FindFirstChild("Gun") or char:FindFirstChild("MM2Gun") then return "sheriff" end
		if bp then
			if bp:FindFirstChild("Knife") or bp:FindFirstChild("MM2Knife") then return "murderer" end
			if bp:FindFirstChild("Gun") or bp:FindFirstChild("MM2Gun") then return "sheriff" end
		end
		return "innocent"
	end

	local function removeESP(plr)
		if espHL[plr] then espHL[plr]:Destroy(); espHL[plr]=nil end
		local char=plr.Character; if not char then return end
		local head=char:FindFirstChild("Head"); if not head then return end
		local bg=head:FindFirstChild("PaulESPBG"); if bg then bg:Destroy() end
	end

	local function applyESP(plr)
		if plr==LocalPlayer then return end
		local char=plr.Character; if not char then return end
		removeESP(plr)
		local role=getMM2Role(plr)
		local fillCol=role=="murderer" and Color3.fromRGB(200,30,30) or role=="sheriff" and Color3.fromRGB(30,100,210) or Color3.fromRGB(120,50,200)
		local outCol=role=="murderer" and Color3.fromRGB(255,100,100) or role=="sheriff" and Color3.fromRGB(100,180,255) or Color3.fromRGB(190,130,255)
		local h=Instance.new("Highlight"); h.Name="PaulESP"; h.Adornee=char
		h.FillColor=fillCol; h.OutlineColor=outCol; h.FillTransparency=0.45; h.OutlineTransparency=0
		h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=char; espHL[plr]=h
		local head=char:FindFirstChild("Head"); if not head then return end
		local bg=Instance.new("BillboardGui"); bg.Name="PaulESPBG"; bg.Size=UDim2.new(0,140,0,44)
		bg.StudsOffset=Vector3.new(0,3.2,0); bg.AlwaysOnTop=true; bg.Parent=head
		local tag=role~="innocent" and "  ["..role:sub(1,3):upper().."]" or ""
		local nl=Instance.new("TextLabel"); nl.Name="NL"; nl.Size=UDim2.new(1,0,0,22); nl.BackgroundTransparency=1
		nl.Text=plr.Name..tag; nl.TextColor3=outCol; nl.TextSize=13; nl.Font=Enum.Font.GothamBold; nl.Parent=bg
		local dl=Instance.new("TextLabel"); dl.Name="DL"; dl.Size=UDim2.new(1,0,0,18); dl.Position=UDim2.new(0,0,0,22)
		dl.BackgroundTransparency=1; dl.Text="-- studs"; dl.TextColor3=Color3.fromRGB(180,180,200); dl.TextSize=11; dl.Font=Enum.Font.Gotham; dl.Parent=bg
	end

	local function refreshESP()
		for _,plr in ipairs(Players:GetPlayers()) do
			if espEnabled then applyESP(plr) else removeESP(plr) end
		end
	end

	local function startFly()
		local char=LocalPlayer.Character; if not char then return end
		local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=true end
		if flyBV then flyBV:Destroy() end; if flyBG then flyBG:Destroy() end
		flyBV=Instance.new("BodyVelocity"); flyBV.Velocity=Vector3.new(0,0,0)
		flyBV.MaxForce=Vector3.new(1e6,1e6,1e6); flyBV.P=1e4; flyBV.Parent=hrp
		flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
		flyBG.P=2e4; flyBG.D=200; flyBG.Parent=hrp
		if flyConn then flyConn:Disconnect() end
		flyConn=RunService.Heartbeat:Connect(function()
			if not flyEnabled then return end
			local cam=workspace.CurrentCamera; local dir=Vector3.new(0,0,0)
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
			local boost=UIS:IsKeyDown(Enum.KeyCode.LeftControl) and 2.5 or 1
			flyBV.Velocity=dir.Magnitude>0 and dir.Unit*(60*boost) or Vector3.new(0,0,0)
			flyBG.CFrame=cam.CFrame
		end)
	end

	local function stopFly()
		if flyConn then flyConn:Disconnect(); flyConn=nil end
		if flyBV then flyBV:Destroy(); flyBV=nil end
		if flyBG then flyBG:Destroy(); flyBG=nil end
		local char=LocalPlayer.Character; if not char then return end
		local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
	end

	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5); if flyEnabled then startFly() end
		task.wait(1); if espEnabled then refreshESP() end
	end)
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=LocalPlayer then plr.CharacterAdded:Connect(function() task.wait(1); if espEnabled then applyESP(plr) end end) end
	end
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function() task.wait(1); if espEnabled then applyESP(plr) end end)
	end)

	-- WINDOW
	local HW=Instance.new("Frame"); HW.Size=UDim2.new(0,0,0,0); HW.Position=UDim2.new(0.5,0,0.5,0)
	HW.BackgroundColor3=Color3.fromRGB(13,13,17); HW.BorderSizePixel=0; HW.ClipsDescendants=true
	HW.ZIndex=20; HW.Parent=MM2SG; corner(HW,14)
	local HWS=Instance.new("UIStroke",HW); HWS.Color=Color3.fromRGB(80,45,130); HWS.Thickness=1
	blob(HW,Color3.fromRGB(90,40,150),-60,-60,200); blob(HW,Color3.fromRGB(40,20,80),380,300,180)
	local HShimmer=Instance.new("Frame"); HShimmer.Size=UDim2.new(1,-2,0,1); HShimmer.Position=UDim2.new(0,1,0,1)
	HShimmer.BackgroundColor3=Color3.fromRGB(160,100,255); HShimmer.BackgroundTransparency=0.5
	HShimmer.BorderSizePixel=0; HShimmer.ZIndex=30; HShimmer.Parent=HW; corner(HShimmer,14)

	local HH=Instance.new("Frame"); HH.Size=UDim2.new(1,0,0,50); HH.BackgroundColor3=Color3.fromRGB(10,10,14)
	HH.BorderSizePixel=0; HH.ZIndex=22; HH.Parent=HW; corner(HH,14)
	local HHCover=Instance.new("Frame"); HHCover.Size=UDim2.new(1,0,0,14); HHCover.Position=UDim2.new(0,0,1,-14)
	HHCover.BackgroundColor3=Color3.fromRGB(10,10,14); HHCover.BorderSizePixel=0; HHCover.ZIndex=22; HHCover.Parent=HH
	local HHDiv=Instance.new("Frame"); HHDiv.Size=UDim2.new(1,0,0,1); HHDiv.Position=UDim2.new(0,0,1,0)
	HHDiv.BackgroundColor3=Color3.fromRGB(80,45,130); HHDiv.BackgroundTransparency=0.5; HHDiv.BorderSizePixel=0; HHDiv.ZIndex=23; HHDiv.Parent=HH

	local HClose=winBtn(HH,14,Color3.fromRGB(210,65,65),Color3.fromRGB(240,90,90))
	local HMin=winBtn(HH,32,Color3.fromRGB(190,145,30),Color3.fromRGB(230,175,50))
	local HMax=winBtn(HH,50,Color3.fromRGB(45,175,75),Color3.fromRGB(60,210,95))
	HClose.ZIndex=25; HMin.ZIndex=25; HMax.ZIndex=25

	local HTitleLbl=Instance.new("TextLabel"); HTitleLbl.Size=UDim2.new(1,-80,1,0); HTitleLbl.Position=UDim2.new(0,76,0,0)
	HTitleLbl.BackgroundTransparency=1; HTitleLbl.Text="🔪  Murder Mystery 2  |  PaulematicHubV2"
	HTitleLbl.TextColor3=Color3.fromRGB(180,150,230); HTitleLbl.TextSize=12; HTitleLbl.Font=Enum.Font.GothamBold
	HTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; HTitleLbl.ZIndex=23; HTitleLbl.Parent=HH
	drag(HH,HW)

	HClose.MouseButton1Click:Connect(function()
		flyEnabled=false; stopFly()
		if espDistConn then espDistConn:Disconnect() end
		if aimlockConn then aimlockConn:Disconnect() end
		if aimbotConn then aimbotConn:Disconnect() end
		if infJumpConn then infJumpConn:Disconnect() end
		if noclipConn then noclipConn:Disconnect() end
		if hitboxConn then hitboxConn:Disconnect() end
		if autokillConn then autokillConn:Disconnect() end
		if sheriffShotConn then sheriffShotConn:Disconnect() end
		if dodgeConn then dodgeConn:Disconnect() end
		-- restore hitboxes
		for hrp,sz in pairs(hitboxOrigSizes) do if hrp and hrp.Parent then hrp.Size=sz end end
		-- restore collision
		local lChar=LocalPlayer.Character
		if lChar then for _,p in ipairs(lChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
		tw(HW,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In):Play()
		task.delay(0.22,function() MM2SG:Destroy() end)
	end)
	local hwMin=false
	HMin.MouseButton1Click:Connect(function()
		hwMin=not hwMin
		tw(HW,{Size=hwMin and UDim2.new(0,500,0,50) or UDim2.new(0,500,0,500)},0.22):Play()
	end)
	local hwBig=false
	HMax.MouseButton1Click:Connect(function()
		hwBig=not hwBig; local w=hwBig and 620 or 500; local h=hwBig and 600 or 500
		tw(HW,{Size=UDim2.new(0,w,0,h),Position=UDim2.new(0.5,-w/2,0.5,-h/2)},0.24):Play()
	end)

	-- LEFT NAV
	local HNav=Instance.new("Frame"); HNav.Size=UDim2.new(0,130,1,-50); HNav.Position=UDim2.new(0,0,0,50)
	HNav.BackgroundColor3=Color3.fromRGB(10,10,14); HNav.BorderSizePixel=0; HNav.ZIndex=22; HNav.Parent=HW
	local HNavDiv=Instance.new("Frame"); HNavDiv.Size=UDim2.new(0,1,1,0); HNavDiv.Position=UDim2.new(1,0,0,0)
	HNavDiv.BackgroundColor3=Color3.fromRGB(55,30,90); HNavDiv.BorderSizePixel=0; HNavDiv.ZIndex=23; HNavDiv.Parent=HNav

	local NavRing=Instance.new("Frame"); NavRing.Size=UDim2.new(0,36,0,36); NavRing.Position=UDim2.new(0.5,-18,0,14)
	NavRing.BackgroundColor3=Color3.fromRGB(70,45,110); NavRing.BorderSizePixel=0; NavRing.ZIndex=23; NavRing.Parent=HNav; corner(NavRing,99)
	local NavImg=Instance.new("ImageLabel"); NavImg.Size=UDim2.new(0,32,0,32); NavImg.Position=UDim2.new(0.5,-16,0.5,-16)
	NavImg.BackgroundTransparency=1; NavImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png"
	NavImg.ScaleType=Enum.ScaleType.Crop; NavImg.ZIndex=24; NavImg.Parent=NavRing; corner(NavImg,99)
	local NavName=Instance.new("TextLabel"); NavName.Size=UDim2.new(1,-8,0,16); NavName.Position=UDim2.new(0,4,0,54)
	NavName.BackgroundTransparency=1; NavName.Text=LocalPlayer.Name; NavName.TextColor3=Color3.fromRGB(200,190,225)
	NavName.TextSize=11; NavName.Font=Enum.Font.GothamBold; NavName.ZIndex=23; NavName.Parent=HNav
	local NavDivLine=Instance.new("Frame"); NavDivLine.Size=UDim2.new(1,-20,0,1); NavDivLine.Position=UDim2.new(0,10,0,78)
	NavDivLine.BackgroundColor3=Color3.fromRGB(45,28,70); NavDivLine.BorderSizePixel=0; NavDivLine.ZIndex=23; NavDivLine.Parent=HNav

	-- CONTENT
	local HContent=Instance.new("Frame"); HContent.Size=UDim2.new(1,-130,1,-50); HContent.Position=UDim2.new(0,130,0,50)
	HContent.BackgroundTransparency=1; HContent.ClipsDescendants=true; HContent.ZIndex=21; HContent.Parent=HW

	local function makePage()
		local p=Instance.new("ScrollingFrame"); p.Size=UDim2.new(1,-20,1,-16); p.Position=UDim2.new(0,10,0,10)
		p.BackgroundTransparency=1; p.BorderSizePixel=0; p.ScrollBarThickness=3
		p.ScrollBarImageColor3=Color3.fromRGB(100,60,170); p.CanvasSize=UDim2.new(0,0,0,0)
		p.AutomaticCanvasSize=Enum.AutomaticSize.Y; p.ZIndex=22; p.Visible=false; p.Parent=HContent
		local lay=Instance.new("UIListLayout",p); lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Padding=UDim.new(0,8)
		return p
	end

	local combatPage=makePage(); local movePage=makePage(); local aimPage=makePage()

	-- COMBAT PAGE
	makeSection(combatPage,"PLAYER ESP",1)
	makeToggleRow(combatPage,"Player ESP","Purple=innocent  Red=murderer  Blue=sheriff + distance",2,function(on)
		espEnabled=on
		if on then
			refreshESP()
			if espDistConn then espDistConn:Disconnect() end
			espDistConn=RunService.Heartbeat:Connect(function()
				local lChar=LocalPlayer.Character; local lHRP=lChar and lChar:FindFirstChild("HumanoidRootPart")
				for _,plr in ipairs(Players:GetPlayers()) do
					if plr==LocalPlayer then continue end
					local char=plr.Character; if not char then continue end
					local head=char:FindFirstChild("Head"); if not head then continue end
					local bg=head:FindFirstChild("PaulESPBG"); if not bg then continue end
					local dl=bg:FindFirstChild("DL"); if dl and lHRP then dl.Text=math.floor((head.Position-lHRP.Position).Magnitude).." studs" end
					local nl=bg:FindFirstChild("NL"); if nl then
						local role=getMM2Role(plr)
						local outCol=role=="murderer" and Color3.fromRGB(255,100,100) or role=="sheriff" and Color3.fromRGB(100,180,255) or Color3.fromRGB(190,130,255)
						nl.TextColor3=outCol; nl.Text=plr.Name..(role~="innocent" and "  ["..role:sub(1,3):upper().."]" or "")
						local hl=espHL[plr]; if hl then
							hl.FillColor=role=="murderer" and Color3.fromRGB(200,30,30) or role=="sheriff" and Color3.fromRGB(30,100,210) or Color3.fromRGB(120,50,200)
							hl.OutlineColor=outCol
						end
					end
				end
			end)
		else
			if espDistConn then espDistConn:Disconnect(); espDistConn=nil end; refreshESP()
		end
	end)

	makeSection(combatPage,"KILLER",3)
	makeToggleRow(combatPage,"Auto Kill (Murderer)","Click once as murderer — everyone dies instantly",4,function(on)
		if autokillConn then autokillConn:Disconnect(); autokillConn=nil end
		if not on then return end
		autokillConn=UIS.InputBegan:Connect(function(input,gp)
			if gp or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
			local myRole=getMM2Role(LocalPlayer)
			if myRole~="murderer" then return end
			local lChar=LocalPlayer.Character; if not lChar then return end
			local lHRP=lChar:FindFirstChild("HumanoidRootPart"); if not lHRP then return end
			for _,plr in ipairs(Players:GetPlayers()) do
				if plr==LocalPlayer then continue end
				local char=plr.Character; if not char then continue end
				local hrp=char:FindFirstChild("HumanoidRootPart")
				local hum=char:FindFirstChildOfClass("Humanoid")
				if not hrp or not hum or hum.Health<=0 then continue end
				-- teleport to each player and stab (move HRP onto their HRP)
				local origPos=lHRP.CFrame
				lHRP.CFrame=hrp.CFrame
				task.wait(0.05)
				lHRP.CFrame=origPos
				task.wait(0.02)
			end
		end)
	end)

	makeSection(combatPage,"SHERIFF",5)
	makeToggleRow(combatPage,"Sheriff One-Shot","Shoot anywhere — murderer dies instantly",6,function(on)
		if sheriffShotConn then sheriffShotConn:Disconnect(); sheriffShotConn=nil end
		if not on then return end
		sheriffShotConn=UIS.InputBegan:Connect(function(input,gp)
			if gp or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
			local myRole=getMM2Role(LocalPlayer)
			if myRole~="sheriff" then return end
			local lChar=LocalPlayer.Character; if not lChar then return end
			local lHRP=lChar:FindFirstChild("HumanoidRootPart"); if not lHRP then return end
			-- find murderer and teleport to them briefly (forces hit detection)
			for _,plr in ipairs(Players:GetPlayers()) do
				if plr==LocalPlayer then continue end
				local char=plr.Character; if not char then continue end
				local hum=char:FindFirstChildOfClass("Humanoid")
				local hrp=char:FindFirstChild("HumanoidRootPart")
				if not hrp or not hum or hum.Health<=0 then continue end
				if getMM2Role(plr)=="murderer" then
					local origCF=lHRP.CFrame
					lHRP.CFrame=hrp.CFrame*CFrame.new(0,0,-2)
					task.wait(0.05)
					lHRP.CFrame=origCF
					break
				end
			end
		end)
	end)

	makeSection(combatPage,"DEFENSE",7)
	makeToggleRow(combatPage,"Dodge","Auto sidestep when a knife gets within 8 studs",8,function(on)
		if dodgeConn then dodgeConn:Disconnect(); dodgeConn=nil end
		if not on then return end
		dodgeConn=RunService.Heartbeat:Connect(function()
			if dodgeCooldown then return end
			local lChar=LocalPlayer.Character; if not lChar then return end
			local lHRP=lChar:FindFirstChild("HumanoidRootPart"); if not lHRP then return end
			-- scan workspace for fast-moving parts that look like knives
			for _,obj in ipairs(workspace:GetDescendants()) do
				local nameL=obj.Name:lower()
				if not (nameL:find("knife") or nameL:find("blade") or nameL:find("throw") or nameL:find("projectile")) then continue end
				if not obj:IsA("BasePart") then continue end
				local dist=(obj.Position-lHRP.Position).Magnitude
				if dist<8 then
					dodgeCooldown=true
					-- dodge: move sideways 12 studs instantly
					local side=lHRP.CFrame.RightVector
					local flip=math.random(0,1)==0 and 1 or -1
					lHRP.CFrame=lHRP.CFrame*CFrame.new(flip*12,0,0)
					task.wait(1.2) -- cooldown before next dodge
					dodgeCooldown=false
					break
				end
			end
		end)
	end)

	makeSection(combatPage,"MOVEMENT",9)
	makeToggleRow(combatPage,"Noclip","Walk through walls freely",10,function(on)
		if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
		if not on then
			-- restore collision
			local lChar=LocalPlayer.Character
			if lChar then
				for _,p in ipairs(lChar:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide=true end
				end
			end
			return
		end
		noclipConn=RunService.Stepped:Connect(function()
			local lChar=LocalPlayer.Character; if not lChar then return end
			for _,p in ipairs(lChar:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide=false end
			end
		end)
	end)

	makeToggleRow(combatPage,"Hitbox Expander","Makes all players easy to hit (big hitbox)",11,function(on)
		if hitboxConn then hitboxConn:Disconnect(); hitboxConn=nil end
		if not on then
			-- restore original sizes
			for hrp,sz in pairs(hitboxOrigSizes) do
				if hrp and hrp.Parent then hrp.Size=sz end
			end
			hitboxOrigSizes={}
			return
		end
		-- expand hrp of all players
		local function expandPlayer(plr)
			if plr==LocalPlayer then return end
			local char=plr.Character; if not char then return end
			local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
			if not hitboxOrigSizes[hrp] then hitboxOrigSizes[hrp]=hrp.Size end
			hrp.Size=Vector3.new(10,10,10)
			hrp.Transparency=1
		end
		for _,plr in ipairs(Players:GetPlayers()) do expandPlayer(plr) end
		hitboxConn=Players.PlayerAdded:Connect(function(plr)
			plr.CharacterAdded:Connect(function() task.wait(1); expandPlayer(plr) end)
		end)
		-- also reapply when chars respawn
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr~=LocalPlayer then
				plr.CharacterAdded:Connect(function() task.wait(1); expandPlayer(plr) end)
			end
		end
	end)

	-- MOVEMENT PAGE
	makeSection(movePage,"FLY",1)
	makeToggleRow(movePage,"Fly","WASD + Space/Shift | Ctrl = speed boost",2,function(on)
		flyEnabled=on; if on then startFly() else stopFly() end
	end)
	makeSection(movePage,"JUMP",3)
	makeToggleRow(movePage,"Infinite Jump","Jump unlimited times mid-air",4,function(on)
		if infJumpConn then infJumpConn:Disconnect(); infJumpConn=nil end
		if on then infJumpConn=UIS.JumpRequest:Connect(function()
			local char=LocalPlayer.Character; if not char then return end
			local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end) end
	end)

	-- AIM PAGE
	makeSection(aimPage,"AIM LOCK",1)
	makeToggleRow(aimPage,"Aim Lock","Locks camera to nearest player (use with shiftlock)",2,function(on)
		if aimlockConn then aimlockConn:Disconnect(); aimlockConn=nil end
		if not on then return end
		aimlockConn=RunService.Heartbeat:Connect(function()
			local lChar=LocalPlayer.Character; if not lChar then return end
			local lHRP=lChar:FindFirstChild("HumanoidRootPart"); if not lHRP then return end
			local best,bd=nil,math.huge
			for _,plr in ipairs(Players:GetPlayers()) do
				if plr==LocalPlayer then continue end
				local char=plr.Character; if not char then continue end
				local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
				if not hrp or not hum or hum.Health<=0 then continue end
				local d=(hrp.Position-lHRP.Position).Magnitude
				if d<bd then bd=d; best=hrp.Position+Vector3.new(0,1.5,0) end
			end
			if best then Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,best),aimLerp) end
		end)
	end)
	makeSection(aimPage,"AIMBOT",3)
	makeToggleRow(aimPage,"Aimbot","Snaps HRP toward nearest player on click (60 stud range)",4,function(on)
		if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end
		if not on then return end
		aimbotConn=UIS.InputBegan:Connect(function(input,gp)
			if gp or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
			local lChar=LocalPlayer.Character; if not lChar then return end
			local lHRP=lChar:FindFirstChild("HumanoidRootPart"); if not lHRP then return end
			local best,bd=nil,math.huge
			for _,plr in ipairs(Players:GetPlayers()) do
				if plr==LocalPlayer then continue end
				local char=plr.Character; if not char then continue end
				local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
				if not hrp or not hum or hum.Health<=0 then continue end
				local d=(hrp.Position-lHRP.Position).Magnitude
				if d<bd and d<60 then bd=d; best=hrp end
			end
			if best then
				local tp=best.Position
				lHRP.CFrame=CFrame.new(lHRP.Position,Vector3.new(tp.X,lHRP.Position.Y,tp.Z))
				Camera.CFrame=CFrame.new(Camera.CFrame.Position,tp+Vector3.new(0,1.5,0))
			end
		end)
	end)

	-- NAV BUTTONS
	local navBtns={}; local activeNavPage=nil
	local function selectNav(page,btn,lbl)
		if activeNavPage then activeNavPage.Visible=false end
		activeNavPage=page; page.Visible=true
		for _,nb in ipairs(navBtns) do
			nb.btn.BackgroundTransparency=1; nb.lbl.TextColor3=Color3.fromRGB(110,90,150); nb.lbl.Font=Enum.Font.Gotham
		end
		btn.BackgroundTransparency=0; btn.BackgroundColor3=Color3.fromRGB(28,18,46)
		lbl.TextColor3=Color3.fromRGB(200,170,240); lbl.Font=Enum.Font.GothamBold
	end

	local navDefs={{label="⚔️  Combat",page=combatPage},{label="🚀  Movement",page=movePage},{label="🎯  Aim",page=aimPage}}
	for i,nd in ipairs(navDefs) do
		local NBtn=Instance.new("TextButton"); NBtn.Size=UDim2.new(1,-16,0,34); NBtn.Position=UDim2.new(0,8,0,90+(i-1)*42)
		NBtn.BackgroundColor3=Color3.fromRGB(28,18,46); NBtn.BackgroundTransparency=1; NBtn.BorderSizePixel=0
		NBtn.Text=""; NBtn.ZIndex=23; NBtn.Parent=HNav; corner(NBtn,8)
		local NLbl=Instance.new("TextLabel"); NLbl.Size=UDim2.new(1,0,1,0); NLbl.BackgroundTransparency=1
		NLbl.Text=nd.label; NLbl.TextColor3=Color3.fromRGB(110,90,150); NLbl.TextSize=12; NLbl.Font=Enum.Font.Gotham
		NLbl.ZIndex=24; NLbl.Parent=NBtn
		local cp=nd.page; local cb=NBtn; local cl=NLbl
		table.insert(navBtns,{btn=NBtn,lbl=NLbl})
		NBtn.MouseButton1Click:Connect(function() selectNav(cp,cb,cl) end)
		NBtn.MouseEnter:Connect(function() if activeNavPage~=cp then NBtn.BackgroundTransparency=0; tw(NBtn,{BackgroundColor3=Color3.fromRGB(22,14,38)},0.15):Play() end end)
		NBtn.MouseLeave:Connect(function() if activeNavPage~=cp then tw(NBtn,{BackgroundColor3=Color3.fromRGB(0,0,0)},0.15):Play(); task.defer(function() NBtn.BackgroundTransparency=1 end) end end)
	end
	selectNav(combatPage,navBtns[1].btn,navBtns[1].lbl)

	tw(HW,{Size=UDim2.new(0,500,0,500),Position=UDim2.new(0.5,-250,0.5,-250)},0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out):Play()
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local function openMainGui()
	local ASG=Instance.new("ScreenGui"); ASG.Name="PaulematicMain"; ASG.ResetOnSpawn=false
	ASG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ASG.Parent=LocalPlayer:WaitForChild("PlayerGui")

	local MW=Instance.new("Frame"); MW.Size=UDim2.new(0,0,0,0); MW.Position=UDim2.new(0.5,0,0.5,0)
	MW.BackgroundColor3=Color3.fromRGB(14,14,18); MW.BorderSizePixel=0; MW.ClipsDescendants=true
	MW.ZIndex=2; MW.Parent=ASG; corner(MW,14); stroke(MW,Color3.fromRGB(60,60,75))
	blob(MW,Color3.fromRGB(60,55,110),-80,-80,260); blob(MW,Color3.fromRGB(30,80,100),500,360,200)

	local MTB=Instance.new("Frame"); MTB.Size=UDim2.new(1,0,0,44); MTB.BackgroundColor3=Color3.fromRGB(11,11,15)
	MTB.BorderSizePixel=0; MTB.ZIndex=8; MTB.Parent=MW; corner(MTB,14)
	local MTBCover=Instance.new("Frame"); MTBCover.Size=UDim2.new(1,0,0,14); MTBCover.Position=UDim2.new(0,0,1,-14)
	MTBCover.BackgroundColor3=Color3.fromRGB(11,11,15); MTBCover.BorderSizePixel=0; MTBCover.ZIndex=8; MTBCover.Parent=MTB
	local MTBDiv=Instance.new("Frame"); MTBDiv.Size=UDim2.new(1,0,0,1); MTBDiv.Position=UDim2.new(0,0,1,0)
	MTBDiv.BackgroundColor3=Color3.fromRGB(40,40,55); MTBDiv.BorderSizePixel=0; MTBDiv.ZIndex=9; MTBDiv.Parent=MTB

	local MClose=winBtn(MTB,14,Color3.fromRGB(210,65,65),Color3.fromRGB(240,90,90))
	local MMin=winBtn(MTB,32,Color3.fromRGB(190,145,30),Color3.fromRGB(230,175,50))
	local MMax=winBtn(MTB,50,Color3.fromRGB(45,175,75),Color3.fromRGB(60,210,95))

	local MTitleLbl=Instance.new("TextLabel"); MTitleLbl.Size=UDim2.new(1,-80,1,0); MTitleLbl.Position=UDim2.new(0,76,0,0)
	MTitleLbl.BackgroundTransparency=1; MTitleLbl.Text="⚡  PaulematicHubV2  —  "..LocalPlayer.DisplayName
	MTitleLbl.TextColor3=Color3.fromRGB(160,160,185); MTitleLbl.TextSize=12; MTitleLbl.Font=Enum.Font.GothamBold
	MTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; MTitleLbl.ZIndex=9; MTitleLbl.Parent=MTB
	drag(MTB,MW)

	MClose.MouseButton1Click:Connect(function()
		tw(MW,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In):Play()
		task.delay(0.24,function() ASG:Destroy() end)
	end)
	local mwMin=false
	MMin.MouseButton1Click:Connect(function()
		mwMin=not mwMin; tw(MW,{Size=mwMin and UDim2.new(0,700,0,44) or UDim2.new(0,700,0,520)},0.24):Play()
	end)
	local mwBig=false
	MMax.MouseButton1Click:Connect(function()
		mwBig=not mwBig; local w=mwBig and 920 or 700; local h=mwBig and 660 or 520
		tw(MW,{Size=UDim2.new(0,w,0,h),Position=UDim2.new(0.5,-w/2,0.5,-h/2)},0.24):Play()
	end)

	-- Sidebar
	local Sidebar=Instance.new("Frame"); Sidebar.Size=UDim2.new(0,210,1,-44); Sidebar.Position=UDim2.new(0,0,0,44)
	Sidebar.BackgroundColor3=Color3.fromRGB(11,11,15); Sidebar.BorderSizePixel=0; Sidebar.ZIndex=4; Sidebar.Parent=MW
	local SDiv=Instance.new("Frame"); SDiv.Size=UDim2.new(0,1,1,0); SDiv.Position=UDim2.new(1,0,0,0)
	SDiv.BackgroundColor3=Color3.fromRGB(40,40,55); SDiv.BorderSizePixel=0; SDiv.ZIndex=5; SDiv.Parent=Sidebar

	makeAvatar(Sidebar,72,69,20)
	local function sLbl(txt,col,sz,fnt,y)
		local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-16,0,sz+4); l.Position=UDim2.new(0,8,0,y)
		l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=col; l.TextSize=sz; l.Font=fnt or Enum.Font.Gotham
		l.ZIndex=5; l.Parent=Sidebar
	end
	sLbl(LocalPlayer.DisplayName,Color3.fromRGB(230,230,245),15,Enum.Font.GothamBold,100)
	sLbl("@"..LocalPlayer.Name,Color3.fromRGB(95,95,120),11,Enum.Font.Gotham,122)
	sLbl("#"..tostring(LocalPlayer.UserId),Color3.fromRGB(70,70,90),10,Enum.Font.Gotham,138)

	local SBadge=Instance.new("Frame"); SBadge.Size=UDim2.new(1,-24,0,24); SBadge.Position=UDim2.new(0,12,0,162)
	SBadge.BackgroundColor3=Color3.fromRGB(25,55,35); SBadge.BorderSizePixel=0; SBadge.ZIndex=5; SBadge.Parent=Sidebar
	corner(SBadge,6); stroke(SBadge,Color3.fromRGB(40,110,60))
	local SBLbl=Instance.new("TextLabel"); SBLbl.Size=UDim2.new(1,0,1,0); SBLbl.BackgroundTransparency=1
	SBLbl.Text="✓  Access Granted"; SBLbl.TextColor3=Color3.fromRGB(60,210,100); SBLbl.TextSize=11
	SBLbl.Font=Enum.Font.GothamBold; SBLbl.ZIndex=6; SBLbl.Parent=SBadge

	-- Content
	local CA=Instance.new("Frame"); CA.Size=UDim2.new(1,-210,1,-44); CA.Position=UDim2.new(0,210,0,44)
	CA.BackgroundTransparency=1; CA.ClipsDescendants=true; CA.ZIndex=4; CA.Parent=MW

	local TabBar=Instance.new("Frame"); TabBar.Size=UDim2.new(1,0,0,44); TabBar.BackgroundColor3=Color3.fromRGB(12,12,16)
	TabBar.BorderSizePixel=0; TabBar.ZIndex=6; TabBar.Parent=CA
	local TBDiv=Instance.new("Frame"); TBDiv.Size=UDim2.new(1,0,0,1); TBDiv.Position=UDim2.new(0,0,1,-1)
	TBDiv.BackgroundColor3=Color3.fromRGB(40,40,55); TBDiv.BorderSizePixel=0; TBDiv.ZIndex=7; TBDiv.Parent=TabBar

	local TabContent=Instance.new("Frame"); TabContent.Size=UDim2.new(1,0,1,-44); TabContent.Position=UDim2.new(0,0,0,44)
	TabContent.BackgroundTransparency=1; TabContent.ClipsDescendants=true; TabContent.ZIndex=4; TabContent.Parent=CA

	-- Games page
	local GamesPage=Instance.new("ScrollingFrame"); GamesPage.Size=UDim2.new(1,-24,1,-20); GamesPage.Position=UDim2.new(0,12,0,10)
	GamesPage.BackgroundTransparency=1; GamesPage.BorderSizePixel=0; GamesPage.ScrollBarThickness=3
	GamesPage.ScrollBarImageColor3=Color3.fromRGB(70,70,90); GamesPage.CanvasSize=UDim2.new(0,0,0,0)
	GamesPage.AutomaticCanvasSize=Enum.AutomaticSize.Y; GamesPage.ZIndex=5; GamesPage.Visible=true; GamesPage.Parent=TabContent
	local GL=Instance.new("UIListLayout",GamesPage); GL.SortOrder=Enum.SortOrder.LayoutOrder; GL.Padding=UDim.new(0,10)

	-- Important page
	local ImpPage=Instance.new("ScrollingFrame"); ImpPage.Size=UDim2.new(1,-24,1,-20); ImpPage.Position=UDim2.new(0,12,0,10)
	ImpPage.BackgroundTransparency=1; ImpPage.BorderSizePixel=0; ImpPage.ScrollBarThickness=3
	ImpPage.ScrollBarImageColor3=Color3.fromRGB(70,70,90); ImpPage.CanvasSize=UDim2.new(0,0,0,0)
	ImpPage.AutomaticCanvasSize=Enum.AutomaticSize.Y; ImpPage.ZIndex=5; ImpPage.Visible=false; ImpPage.Parent=TabContent
	local IL=Instance.new("UIListLayout",ImpPage); IL.SortOrder=Enum.SortOrder.LayoutOrder; IL.Padding=UDim.new(0,12)

	local MadeByLbl=Instance.new("TextLabel"); MadeByLbl.Size=UDim2.new(1,0,0,40); MadeByLbl.BackgroundTransparency=1
	MadeByLbl.Text="🌟  Made by Paulematic"; MadeByLbl.TextColor3=Color3.fromRGB(180,150,240)
	MadeByLbl.TextSize=16; MadeByLbl.Font=Enum.Font.GothamBold; MadeByLbl.LayoutOrder=1; MadeByLbl.ZIndex=5; MadeByLbl.Parent=ImpPage
	local SubLbl=Instance.new("TextLabel"); SubLbl.Size=UDim2.new(1,0,0,24); SubLbl.BackgroundTransparency=1
	SubLbl.Text="PaulematicHubV2 — Your personal script hub"; SubLbl.TextColor3=Color3.fromRGB(110,100,140)
	SubLbl.TextSize=11; SubLbl.Font=Enum.Font.Gotham; SubLbl.LayoutOrder=2; SubLbl.ZIndex=5; SubLbl.Parent=ImpPage
	local ImpDiv=Instance.new("Frame"); ImpDiv.Size=UDim2.new(1,0,0,1); ImpDiv.BackgroundColor3=Color3.fromRGB(45,45,58)
	ImpDiv.BorderSizePixel=0; ImpDiv.LayoutOrder=3; ImpDiv.ZIndex=5; ImpDiv.Parent=ImpPage

	local IYBtn=Instance.new("TextButton"); IYBtn.Size=UDim2.new(1,0,0,50); IYBtn.BackgroundColor3=Color3.fromRGB(30,80,150)
	IYBtn.BorderSizePixel=0; IYBtn.Text="⚙️  Load Infinite Yield"; IYBtn.TextColor3=Color3.fromRGB(180,220,255)
	IYBtn.TextSize=14; IYBtn.Font=Enum.Font.GothamBold; IYBtn.LayoutOrder=4; IYBtn.ZIndex=5; IYBtn.Parent=ImpPage
	corner(IYBtn,10); stroke(IYBtn,Color3.fromRGB(60,130,220))
	IYBtn.MouseEnter:Connect(function() tw(IYBtn,{BackgroundColor3=Color3.fromRGB(40,100,180)},0.15):Play() end)
	IYBtn.MouseLeave:Connect(function() tw(IYBtn,{BackgroundColor3=Color3.fromRGB(30,80,150)},0.15):Play() end)
	IYBtn.MouseButton1Click:Connect(function()
		IYBtn.Text="⏳  Loading..."; IYBtn.TextColor3=Color3.fromRGB(255,220,100)
		local ok=pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))() end)
		if ok then
			IYBtn.Text="✓  Infinite Yield Loaded"; IYBtn.TextColor3=Color3.fromRGB(100,220,140)
			tw(IYBtn,{BackgroundColor3=Color3.fromRGB(20,70,40)},0.2):Play()
		else
			IYBtn.Text="✗  Failed to Load"; IYBtn.TextColor3=Color3.fromRGB(255,120,120)
			tw(IYBtn,{BackgroundColor3=Color3.fromRGB(80,20,20)},0.2):Play()
			task.delay(3,function() IYBtn.Text="⚙️  Load Infinite Yield"; IYBtn.TextColor3=Color3.fromRGB(180,220,255); tw(IYBtn,{BackgroundColor3=Color3.fromRGB(30,80,150)},0.2):Play() end)
		end
	end)

	-- Tab buttons
	local tabPages={GamesPage,ImpPage}; local activeTab=1; local tabBtns={}
	local tabLabels={"🎮  Games","⚠️  Important"}
	for i,tabLabel in ipairs(tabLabels) do
		local TBtn=Instance.new("TextButton"); TBtn.Size=UDim2.new(0,135,1,-10); TBtn.Position=UDim2.new(0,8+(i-1)*141,0,5)
		TBtn.BackgroundColor3=Color3.fromRGB(30,30,42); TBtn.BackgroundTransparency=i==1 and 0 or 1; TBtn.BorderSizePixel=0
		TBtn.Text=tabLabel; TBtn.TextColor3=i==1 and Color3.fromRGB(215,215,240) or Color3.fromRGB(110,110,135)
		TBtn.TextSize=12; TBtn.Font=i==1 and Enum.Font.GothamBold or Enum.Font.Gotham; TBtn.ZIndex=7; TBtn.Parent=TabBar; corner(TBtn,8)
		table.insert(tabBtns,TBtn)
		local ci=i
		TBtn.MouseButton1Click:Connect(function()
			tabPages[activeTab].Visible=false; activeTab=ci; tabPages[ci].Visible=true
			for j,b in ipairs(tabBtns) do
				b.BackgroundTransparency=j==ci and 0 or 1; b.BackgroundColor3=Color3.fromRGB(30,30,42)
				b.Font=j==ci and Enum.Font.GothamBold or Enum.Font.Gotham
				b.TextColor3=j==ci and Color3.fromRGB(215,215,240) or Color3.fromRGB(110,110,135)
			end
		end)
		TBtn.MouseEnter:Connect(function() if ci~=activeTab then TBtn.BackgroundTransparency=0; tw(TBtn,{BackgroundColor3=Color3.fromRGB(22,22,32)},0.15):Play() end end)
		TBtn.MouseLeave:Connect(function() if ci~=activeTab then tw(TBtn,{BackgroundColor3=Color3.fromRGB(0,0,0)},0.15):Play(); task.defer(function() TBtn.BackgroundTransparency=1 end) end end)
	end

	-- MM2 Card
	local MM2Card=Instance.new("Frame"); MM2Card.Size=UDim2.new(1,0,0,72); MM2Card.BackgroundColor3=Color3.fromRGB(18,18,26)
	MM2Card.BorderSizePixel=0; MM2Card.LayoutOrder=1; MM2Card.ZIndex=5; MM2Card.Parent=GamesPage; corner(MM2Card,12); stroke(MM2Card,Color3.fromRGB(50,38,75))
	local MM2Accent=Instance.new("Frame"); MM2Accent.Size=UDim2.new(0,3,1,-16); MM2Accent.Position=UDim2.new(0,0,0,8)
	MM2Accent.BackgroundColor3=Color3.fromRGB(150,80,220); MM2Accent.BorderSizePixel=0; MM2Accent.ZIndex=6; MM2Accent.Parent=MM2Card; corner(MM2Accent,4)
	local MM2Icon=Instance.new("TextLabel"); MM2Icon.Size=UDim2.new(0,46,1,0); MM2Icon.Position=UDim2.new(0,12,0,0)
	MM2Icon.BackgroundTransparency=1; MM2Icon.Text="🔪"; MM2Icon.TextSize=26; MM2Icon.Font=Enum.Font.Gotham; MM2Icon.ZIndex=6; MM2Icon.Parent=MM2Card
	local MM2Title=Instance.new("TextLabel"); MM2Title.Size=UDim2.new(1,-180,0,22); MM2Title.Position=UDim2.new(0,62,0,12)
	MM2Title.BackgroundTransparency=1; MM2Title.Text="Murder Mystery 2"; MM2Title.TextColor3=Color3.fromRGB(225,220,245)
	MM2Title.TextSize=14; MM2Title.Font=Enum.Font.GothamBold; MM2Title.TextXAlignment=Enum.TextXAlignment.Left; MM2Title.ZIndex=6; MM2Title.Parent=MM2Card
	local MM2Sub=Instance.new("TextLabel"); MM2Sub.Size=UDim2.new(1,-180,0,16); MM2Sub.Position=UDim2.new(0,62,0,36)
	MM2Sub.BackgroundTransparency=1; MM2Sub.Text="ESP • Fly • Aimbot • Keybinds"; MM2Sub.TextColor3=Color3.fromRGB(110,100,140)
	MM2Sub.TextSize=10; MM2Sub.Font=Enum.Font.Gotham; MM2Sub.TextXAlignment=Enum.TextXAlignment.Left; MM2Sub.ZIndex=6; MM2Sub.Parent=MM2Card
	local MM2Btn=Instance.new("TextButton"); MM2Btn.Size=UDim2.new(0,70,0,30); MM2Btn.Position=UDim2.new(1,-82,0.5,-15)
	MM2Btn.BackgroundColor3=Color3.fromRGB(100,60,180); MM2Btn.BorderSizePixel=0; MM2Btn.Text="Open"
	MM2Btn.TextColor3=Color3.fromRGB(230,220,255); MM2Btn.TextSize=12; MM2Btn.Font=Enum.Font.GothamBold; MM2Btn.ZIndex=7; MM2Btn.Parent=MM2Card
	corner(MM2Btn,8); stroke(MM2Btn,Color3.fromRGB(130,80,220))
	MM2Btn.MouseEnter:Connect(function() tw(MM2Btn,{BackgroundColor3=Color3.fromRGB(120,75,210)},0.15):Play() end)
	MM2Btn.MouseLeave:Connect(function() tw(MM2Btn,{BackgroundColor3=Color3.fromRGB(100,60,180)},0.15):Play() end)
	MM2Btn.MouseButton1Click:Connect(openMM2Hub)
	MM2Card.MouseEnter:Connect(function() tw(MM2Card,{BackgroundColor3=Color3.fromRGB(22,20,32)},0.15):Play() end)
	MM2Card.MouseLeave:Connect(function() tw(MM2Card,{BackgroundColor3=Color3.fromRGB(18,18,26)},0.15):Play() end)

	tw(MW,{Size=UDim2.new(0,700,0,520),Position=UDim2.new(0.5,-350,0.5,-260)},0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out):Play()
end

-- ============================================================
-- KEY VALIDATION
-- ============================================================
local function tryKey()
	local typed=KKeyInput.Text:lower():gsub("%s","")
	if typed==SECRET_KEY then
		tw(KInputBg,{BackgroundColor3=Color3.fromRGB(20,45,28)},0.15):Play()
		tw(KIS,{Color=Color3.fromRGB(50,170,80)},0.15):Play()
		KBtn.Text="✓  Unlocked"; tw(KBtn,{BackgroundColor3=Color3.fromRGB(35,130,65)},0.15):Play()
		task.delay(0.4,function()
			tw(KW,{BackgroundTransparency=1},0.28):Play(); tw(Backdrop,{BackgroundTransparency=1},0.28):Play()
			task.delay(0.3,function() SG:Destroy(); openMainGui() end)
		end)
	else
		tw(KInputBg,{BackgroundColor3=Color3.fromRGB(42,20,20)},0.1):Play()
		tw(KIS,{Color=Color3.fromRGB(180,50,50)},0.1):Play()
		KBtn.Text="✗  Invalid Key"; tw(KBtn,{BackgroundColor3=Color3.fromRGB(130,40,40)},0.1):Play()
		local op=UDim2.new(0,20,0,216)
		for i=1,4 do task.delay(i*0.04,function() KInputBg.Position=UDim2.new(0,20+(i%2==0 and 6 or -6),0,216) end) end
		task.delay(0.22,function() KInputBg.Position=op end)
		task.delay(1.3,function()
			tw(KInputBg,{BackgroundColor3=Color3.fromRGB(22,22,30)},0.2):Play()
			tw(KIS,{Color=Color3.fromRGB(55,55,72)},0.2):Play()
			tw(KBtn,{BackgroundColor3=Color3.fromRGB(80,75,150)},0.2):Play()
			KBtn.Text="Unlock"
		end)
	end
end

KBtn.MouseButton1Click:Connect(tryKey)
KKeyInput.FocusLost:Connect(function(enter) if enter then tryKey() end end)
tw(KW,{Size=UDim2.new(0,340,0,350),Position=UDim2.new(0.5,-170,0.5,-175)},0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out):Play()

print("[PaulematicHubV2] Loaded for "..LocalPlayer.Name)
