-- Paulematic Hub: Clean Navigation, Vector Flight, & Multi-Theme Edition with Theme-Synced Slider
-- Place this inside a LocalScript inside StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

----------------------------------------------------------------
-- [!] YOUR CUSTOM MM2 CODE GOES HERE [!]
----------------------------------------------------------------
local function MyCustomMM2Script()
	-- Uses your exact repository with the correct .txt extension to prevent 404s
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Paulematic/QGTZFAW15215F/refs/heads/main/script.txt"))()
	end)
end
----------------------------------------------------------------

----------------------------------------------------------------
-- 1. MAIN WINDOW SETUP
----------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PaulematicAdmin"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = script.Parent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local function adjustForMobile()
	if ScreenGui.AbsoluteSize.X < 660 or ScreenGui.AbsoluteSize.Y < 430 then
		MainFrame.Size = UDim2.new(0, 480, 0, 300)
		MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
	end
end
task.spawn(adjustForMobile)
ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustForMobile)

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 14)
FrameCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Parent = MainFrame

----------------------------------------------------------------
-- 2. BACKGROUND RADIAL DESIGN DEPTH
----------------------------------------------------------------

local Circle1 = Instance.new("Frame")
Circle1.Size = UDim2.new(0, 180, 0, 180)
Circle1.Position = UDim2.new(0, -30, 0, -20)
Circle1.BackgroundTransparency = 0.91
Circle1.BorderSizePixel = 0
Circle1.ZIndex = 1
Circle1.Parent = MainFrame
local C1Corner = Instance.new("UICorner") C1Corner.CornerRadius = UDim.new(1, 0) C1Corner.Parent = Circle1

local Circle2 = Instance.new("Frame")
Circle2.Size = UDim2.new(0, 220, 0, 220)
Circle2.Position = UDim2.new(1, -160, 1, -160)
Circle2.BackgroundTransparency = 0.91
Circle2.BorderSizePixel = 0
Circle2.ZIndex = 1
Circle2.Parent = MainFrame
local C2Corner = Instance.new("UICorner") C2Corner.CornerRadius = UDim.new(1, 0) C2Corner.Parent = Circle2

local function animateCircle(Circle, startPos)
	task.spawn(function()
		while MainFrame and Circle.Parent do
			local targetX = startPos.X.Offset + math.random(-30, 30)
			local targetY = startPos.Y.Offset + math.random(-30, 30)
			local randomTime = math.random(5, 8)
			local tween = TweenService:Create(Circle, TweenInfo.new(randomTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Position = UDim2.new(startPos.X.Scale, targetX, startPos.Y.Scale, targetY)
			})
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end
animateCircle(Circle1, Circle1.Position)
animateCircle(Circle2, Circle2.Position)

----------------------------------------------------------------
-- 3. PRIMARY NAVIGATION PANELS
----------------------------------------------------------------

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "PAULEMATIC HUB"
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 2
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -45, 0, 15)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(240, 240, 240)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 2
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 6) CloseCorner.Parent = CloseButton

local SidePanel = Instance.new("Frame")
SidePanel.Size = UDim2.new(0, 160, 1, -80)
SidePanel.Position = UDim2.new(0, 20, 0, 65)
SidePanel.BackgroundTransparency = 1
SidePanel.ZIndex = 2
SidePanel.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout") SideLayout.Padding = UDim.new(0, 10) SideLayout.SortOrder = Enum.SortOrder.LayoutOrder SideLayout.Parent = SidePanel

local Views = { External = Instance.new("ScrollingFrame"), Games = Instance.new("ScrollingFrame"), Themes = Instance.new("ScrollingFrame") }

local TabButtons = {}

local function createTabButton(name, text, order)
	local Tab = Instance.new("TextButton")
	Tab.Name = name
	Tab.Size = UDim2.new(1, 0, 0, 40)
	Tab.BorderSizePixel = 0 Tab.Text = text
	Tab.TextSize = 14 Tab.Font = Enum.Font.GothamMedium
	Tab.LayoutOrder = order Tab.ZIndex = 2 Tab.Parent = SidePanel

	local TabCorner = Instance.new("UICorner") TabCorner.CornerRadius = UDim.new(0, 8) TabCorner.Parent = Tab
	local TabStroke = Instance.new("UIStroke") TabStroke.Thickness = 1 TabStroke.Parent = Tab

	TabButtons[name] = {Button = Tab, Stroke = TabStroke}
	return Tab
end

local ExternalTab = createTabButton("External", "[ External ]", 1)
local GamesTab = createTabButton("Games", "[ Games ]", 2)
local ThemesTab = createTabButton("Themes", "[ Themes ]", 3)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -210, 1, -80)
ContentFrame.Position = UDim2.new(0, 190, 0, 65)
ContentFrame.BorderSizePixel = 0 ContentFrame.ZIndex = 2 ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner") ContentCorner.CornerRadius = UDim.new(0, 10) ContentCorner.Parent = ContentFrame
local ContentStroke = Instance.new("UIStroke") ContentStroke.Thickness = 1 ContentStroke.Parent = ContentFrame

for typeName, scroller in pairs(Views) do
	scroller.Size = UDim2.new(0.92, 0, 0.92, 0) scroller.Position = UDim2.new(0.04, 0, 0.04, 0)
	scroller.BackgroundTransparency = 1 scroller.BorderSizePixel = 0 scroller.ScrollBarThickness = 4
	scroller.Visible = false scroller.ZIndex = 3 scroller.Parent = ContentFrame
	local list = Instance.new("UIListLayout") list.Padding = UDim.new(0, 14) list.HorizontalAlignment = Enum.HorizontalAlignment.Center list.SortOrder = Enum.SortOrder.LayoutOrder list.Parent = scroller
end

local function displayTab(tabName)
	MainFrame:SetAttribute("ActiveTab", tabName)
	for name, view in pairs(Views) do view.Visible = (name == tabName) end
end

ExternalTab.MouseButton1Click:Connect(function() displayTab("External") end)
GamesTab.MouseButton1Click:Connect(function() displayTab("Games") end)
ThemesTab.MouseButton1Click:Connect(function() displayTab("Themes") end)

----------------------------------------------------------------
-- 4. THEME MANAGEMENT SYSTEM (With Slider Config Mappings)
----------------------------------------------------------------

local ThemesConfig = {
	CrimsonRed = {
		MainGrad = ColorSequence.new(Color3.fromRGB(18, 10, 10), Color3.fromRGB(28, 12, 12)),
		Accent = Color3.fromRGB(160, 35, 35),
		ContentBg = Color3.fromRGB(14, 10, 10),
		ContentStroke = Color3.fromRGB(55, 25, 25),
		TabBg = Color3.fromRGB(30, 16, 16),
		TabStroke = Color3.fromRGB(75, 30, 30),
		TabText = Color3.fromRGB(175, 120, 120),
		TitleText = Color3.fromRGB(235, 80, 80),
		Circles = {Color3.fromRGB(140, 20, 20), Color3.fromRGB(100, 15, 40)},
		FeatureBg = Color3.fromRGB(28, 14, 14),
		FeatureStroke = Color3.fromRGB(70, 30, 30),
		FeatureText = Color3.fromRGB(210, 160, 160),
		SliderLabel = Color3.fromRGB(200, 150, 150),
		SliderTrack = Color3.fromRGB(40, 20, 20),
		SliderHandleStroke = Color3.fromRGB(255, 90, 90)
	},
	MidnightBlue = {
		MainGrad = ColorSequence.new(Color3.fromRGB(10, 12, 22), Color3.fromRGB(12, 16, 32)),
		Accent = Color3.fromRGB(35, 110, 200),
		ContentBg = Color3.fromRGB(10, 11, 18),
		ContentStroke = Color3.fromRGB(25, 40, 75),
		TabBg = Color3.fromRGB(16, 20, 36),
		TabStroke = Color3.fromRGB(30, 45, 90),
		TabText = Color3.fromRGB(120, 150, 200),
		TitleText = Color3.fromRGB(80, 160, 255),
		Circles = {Color3.fromRGB(20, 60, 140), Color3.fromRGB(15, 30, 100)},
		FeatureBg = Color3.fromRGB(14, 20, 34),
		FeatureStroke = Color3.fromRGB(30, 50, 95),
		FeatureText = Color3.fromRGB(160, 190, 230),
		SliderLabel = Color3.fromRGB(150, 180, 220),
		SliderTrack = Color3.fromRGB(20, 28, 50),
		SliderHandleStroke = Color3.fromRGB(100, 200, 255)
	},
	AcidToxic = {
		MainGrad = ColorSequence.new(Color3.fromRGB(10, 18, 12), Color3.fromRGB(12, 26, 14)),
		Accent = Color3.fromRGB(45, 185, 85),
		ContentBg = Color3.fromRGB(10, 14, 11),
		ContentStroke = Color3.fromRGB(25, 60, 35),
		TabBg = Color3.fromRGB(16, 32, 20),
		TabStroke = Color3.fromRGB(30, 80, 45),
		TabText = Color3.fromRGB(120, 185, 135),
		TitleText = Color3.fromRGB(80, 240, 120),
		Circles = {Color3.fromRGB(20, 130, 50), Color3.fromRGB(15, 90, 40)},
		FeatureBg = Color3.fromRGB(14, 30, 18),
		FeatureStroke = Color3.fromRGB(35, 75, 45),
		FeatureText = Color3.fromRGB(160, 220, 175),
		SliderLabel = Color3.fromRGB(150, 210, 165),
		SliderTrack = Color3.fromRGB(20, 40, 26),
		SliderHandleStroke = Color3.fromRGB(120, 255, 160)
	},
	VoidPurple = {
		MainGrad = ColorSequence.new(Color3.fromRGB(14, 10, 20), Color3.fromRGB(22, 12, 32)),
		Accent = Color3.fromRGB(140, 45, 215),
		ContentBg = Color3.fromRGB(12, 9, 16),
		ContentStroke = Color3.fromRGB(45, 25, 70),
		TabBg = Color3.fromRGB(24, 16, 38),
		TabStroke = Color3.fromRGB(55, 30, 95),
		TabText = Color3.fromRGB(160, 120, 200),
		TitleText = Color3.fromRGB(200, 90, 255),
		Circles = {Color3.fromRGB(110, 20, 160), Color3.fromRGB(70, 15, 120)},
		FeatureBg = Color3.fromRGB(24, 14, 36),
		FeatureStroke = Color3.fromRGB(60, 30, 90),
		FeatureText = Color3.fromRGB(200, 160, 230),
		SliderLabel = Color3.fromRGB(190, 160, 220),
		SliderTrack = Color3.fromRGB(34, 20, 50),
		SliderHandleStroke = Color3.fromRGB(220, 140, 255)
	},
	AmberGold = {
		MainGrad = ColorSequence.new(Color3.fromRGB(16, 14, 10), Color3.fromRGB(26, 20, 12)),
		Accent = Color3.fromRGB(215, 150, 35),
		ContentBg = Color3.fromRGB(14, 12, 10),
		ContentStroke = Color3.fromRGB(65, 45, 25),
		TabBg = Color3.fromRGB(34, 26, 16),
		TabStroke = Color3.fromRGB(80, 55, 30),
		TabText = Color3.fromRGB(190, 160, 120),
		TitleText = Color3.fromRGB(255, 190, 70),
		Circles = {Color3.fromRGB(160, 100, 20), Color3.fromRGB(110, 65, 15)},
		FeatureBg = Color3.fromRGB(32, 24, 14),
		FeatureStroke = Color3.fromRGB(75, 55, 30),
		FeatureText = Color3.fromRGB(225, 195, 150),
		SliderLabel = Color3.fromRGB(210, 190, 160),
		SliderTrack = Color3.fromRGB(45, 35, 20),
		SliderHandleStroke = Color3.fromRGB(255, 215, 120)
	}
}

local featureButtonsRegistry = {}
local currentTheme = "CrimsonRed"

local SliderLabel, SliderBar, SliderFill, SliderHandle, HandleStroke

local function applyTheme(themeName)
	local cfg = ThemesConfig[themeName] or ThemesConfig.CrimsonRed
	currentTheme = themeName
	
	MainGradient.Color = cfg.MainGrad
	FrameStroke.Color = cfg.Accent
	CloseButton.BackgroundColor3 = cfg.Accent
	Title.TextColor3 = cfg.TitleText
	
	ContentFrame.BackgroundColor3 = cfg.ContentBg
	ContentStroke.Color = cfg.ContentStroke
	
	Circle1.BackgroundColor3 = cfg.Circles[1]
	Circle2.BackgroundColor3 = cfg.Circles[2]
	
	for name, tabData in pairs(TabButtons) do
		tabData.Button.BackgroundColor3 = cfg.TabBg
		tabData.Button.TextColor3 = cfg.TabText
		tabData.Stroke.Color = cfg.TabStroke
	end
	
	for _, btn in ipairs(featureButtonsRegistry) do
		btn.BackgroundColor3 = cfg.FeatureBg
		btn.TextColor3 = cfg.FeatureText
		if btn:FindFirstChildOfClass("UIStroke") then
			btn:FindFirstChildOfClass("UIStroke").Color = cfg.FeatureStroke
		end
	end
	
	for _, scroller in pairs(Views) do
		scroller.ScrollBarImageColor3 = cfg.Accent
	end
	
	if SliderLabel and SliderBar then
		SliderLabel.TextColor3 = cfg.SliderLabel
		SliderBar.BackgroundColor3 = cfg.SliderTrack
		SliderFill.BackgroundColor3 = cfg.Accent
		SliderHandle.BackgroundColor3 = cfg.Accent
		HandleStroke.Color = cfg.SliderHandleStroke
	end
end

----------------------------------------------------------------
-- 5. CONTENT LAYOUT CONTROLS
----------------------------------------------------------------

local function createFeatureButton(text, parent)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 42) Btn.BorderSizePixel = 0
	Btn.Text = text Btn.TextSize = 14 Btn.Font = Enum.Font.GothamMedium Btn.ZIndex = 4 Btn.Parent = parent
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = Btn
	local s = Instance.new("UIStroke") s.Thickness = 1 s.Parent = Btn
	
	table.insert(featureButtonsRegistry, Btn)
	
	Btn.MouseEnter:Connect(function() 
		local cfg = ThemesConfig[currentTheme]
		TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = cfg.Accent, TextColor3 = Color3.fromRGB(255,255,255)}):Play() 
	end)
	Btn.MouseLeave:Connect(function() 
		local cfg = ThemesConfig[currentTheme]
		TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = cfg.FeatureBg, TextColor3 = cfg.FeatureText}):Play() 
	end)
	return Btn
end

for name, data in pairs(TabButtons) do
	data.Button.MouseEnter:Connect(function()
		local cfg = ThemesConfig[currentTheme]
		TweenService:Create(data.Button, TweenInfo.new(0.2), {BackgroundColor3 = cfg.Accent, TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)
	data.Button.MouseLeave:Connect(function()
		local cfg = ThemesConfig[currentTheme]
		if MainFrame:AttributeGet("ActiveTab") ~= name then
			TweenService:Create(data.Button, TweenInfo.new(0.2), {BackgroundColor3 = cfg.TabBg, TextColor3 = cfg.TabText}):Play()
		end
	end)
end

local FlyButton = createFeatureButton("Fly: OFF", Views.External)
local EspButton = createFeatureButton("Player ESP: OFF", Views.External)
local IYButton = createFeatureButton("Load Infinite Yield", Views.External)
local Mm2Button = createFeatureButton("Load Murder Mystery 2", Views.Games)

local ThemeBtnRed = createFeatureButton("Theme: Crimson Red", Views.Themes)
local ThemeBtnBlue = createFeatureButton("Theme: Midnight Blue", Views.Themes)
local ThemeBtnGreen = createFeatureButton("Theme: Acid Toxic", Views.Themes)
local ThemeBtnPurple = createFeatureButton("Theme: Void Purple", Views.Themes)
local ThemeBtnGold = createFeatureButton("Theme: Amber Gold", Views.Themes)

ThemeBtnRed.MouseButton1Click:Connect(function() applyTheme("CrimsonRed") end)
ThemeBtnBlue.MouseButton1Click:Connect(function() applyTheme("MidnightBlue") end)
ThemeBtnGreen.MouseButton1Click:Connect(function() applyTheme("AcidToxic") end)
ThemeBtnPurple.MouseButton1Click:Connect(function() applyTheme("VoidPurple") end)
ThemeBtnGold.MouseButton1Click:Connect(function() applyTheme("AmberGold") end)

local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, 0, 0, 55) SliderFrame.BackgroundTransparency = 1 SliderFrame.ZIndex = 4 SliderFrame.Parent = Views.External

SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20) SliderLabel.BackgroundTransparency = 1 SliderLabel.Text = "WalkSpeed: 16"
SliderLabel.TextSize = 12 SliderLabel.Font = Enum.Font.Gotham SliderLabel.ZIndex = 4 SliderLabel.Parent = SliderFrame

SliderBar = Instance.new("TextButton")
SliderBar.Size = UDim2.new(1, -12, 0, 6) SliderBar.Position = UDim2.new(0, 6, 0, 28)
SliderBar.Text = "" SliderBar.BorderSizePixel = 0 SliderBar.ZIndex = 4 SliderBar.Parent = SliderFrame

local BarCorner = Instance.new("UICorner") BarCorner.CornerRadius = UDim.new(0, 4) BarCorner.Parent = SliderBar

SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0) SliderFill.BorderSizePixel = 0 SliderFill.ZIndex = 4 SliderFill.Parent = SliderBar

local FillCorner = Instance.new("UICorner") FillCorner.CornerRadius = UDim.new(0, 4) FillCorner.Parent = SliderFill

SliderHandle = Instance.new("Frame")
SliderHandle.Size = UDim2.new(0, 14, 0, 14) SliderHandle.Position = UDim2.new(0, -7, 0.5, -7)
SliderHandle.BorderSizePixel = 0 SliderHandle.ZIndex = 5 SliderHandle.Parent = SliderBar

local HandleCorner = Instance.new("UICorner") HandleCorner.CornerRadius = UDim.new(1, 0) HandleCorner.Parent = SliderHandle
HandleStroke = Instance.new("UIStroke") HandleStroke.Thickness = 1 HandleStroke.Parent = SliderHandle

----------------------------------------------------------------
-- 6. INTERACTION LOGIC FUNCTIONS (IY, MM2, SLIDER RUNTIME)
----------------------------------------------------------------

IYButton.MouseButton1Click:Connect(function()
	IYButton.Text = "Running loadstring..."
	task.spawn(function()
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
		end)
	end)
	task.wait(1) IYButton.Text = "Infinite Yield Loaded!"
end)

Mm2Button.MouseButton1Click:Connect(function()
	Mm2Button.Text = "Loading..."
	task.spawn(MyCustomMM2Script)
	task.wait(1) Mm2Button.Text = "Murder Mystery 2 Loaded!"
end)

local minSpeed, maxSpeed = 16, 150
local isSliding = false

local function updateSlider(input)
	local ratio = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
	SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
	SliderHandle.Position = UDim2.new(ratio, -7, 0.5, -7)
	
	local speed = math.floor(minSpeed + (ratio * (maxSpeed - minSpeed)))
	SliderLabel.Text = "WalkSpeed: " .. speed
	
	local character = localPlayer.Character
	if character and character:FindFirstChildOfClass("Humanoid") then
		character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
	end
end

SliderBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isSliding = true SliderHandle.Size = UDim2.new(0, 16, 0, 16) SliderHandle.Position = UDim2.new(SliderFill.Size.X.Scale, -8, 0.5, -8) updateSlider(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateSlider(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isSliding = false SliderHandle.Size = UDim2.new(0, 14, 0, 14) SliderHandle.Position = UDim2.new(SliderFill.Size.X.Scale, -7, 0.5, -7)
	end
end)

----------------------------------------------------------------
-- 7. FLIGHT MECHANICS (Keyboard Input Vector Mapping)
----------------------------------------------------------------

local flying = false
local flySpeed = 50
local flyConnection, flyBV, flyBG

local function clearFlightObjects()
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end
	
	local char = localPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.PlatformStand = false end
end

FlyButton.MouseButton1Click:Connect(function()
	flying = not flying
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	
	if not root or not humanoid then flying = false return end
	
	if flying then
		FlyButton.Text = "Fly: ON"
		local camera = workspace.CurrentCamera
		
		flyBV = Instance.new("BodyVelocity")
		flyBV.Name = "HubFlyBV"
		flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		flyBV.Velocity = Vector3.new(0, 0, 0)
		flyBV.Parent = root
		
		flyBG = Instance.new("BodyGyro")
		flyBG.Name = "HubFlyBG"
		flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		flyBG.CFrame = root.CFrame
		flyBG.Parent = root
		
		flyConnection = RunService.RenderStepped:Connect(function()
			if not root.Parent or not humanoid.Parent then
				clearFlightObjects()
				return
			end
			
			humanoid.PlatformStand = true
			flyBG.CFrame = camera.CFrame
			
			local direction = Vector3.new(0,0,0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
			
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				direction = direction + Vector3.new(0, 1, 0)
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				direction = direction - Vector3.new(0, 1, 0)
			end
			
			if direction.Magnitude > 0 then
				flyBV.Velocity = direction.Unit * flySpeed
			else
				flyBV.Velocity = Vector3.new(0, 0, 0)
			end
		end)
	else
		FlyButton.Text = "Fly: OFF"
		clearFlightObjects()
	end
end)

----------------------------------------------------------------
-- 8. PLAYER ESP SYSTEM
----------------------------------------------------------------

local espActive = false
local espContainerFolder = nil

local function clearEsp()
	if espContainerFolder then espContainerFolder:Destroy() espContainerFolder = nil end
end

local function applyEspToCharacter(player, char)
	if player == localPlayer or not espContainerFolder then return end
	local root = char:WaitForChild("HumanoidRootPart", 5)
	local head = char:WaitForChild("Head", 5)
	if not root or not head then return end
	
	local Highlight = Instance.new("Highlight")
	Highlight.Adornee = char
	Highlight.FillColor = ThemesConfig[currentTheme].Accent
	Highlight.FillTransparency = 0.6
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	Highlight.Parent = espContainerFolder
	
	local Billboard = Instance.new("BillboardGui")
	Billboard.Size = UDim2.new(0, 200, 0, 50)
	Billboard.AlwaysOnTop = true
	Billboard.ExtentsOffset = Vector3.new(0, 3, 0)
	Billboard.Adornee = head
	Billboard.Parent = espContainerFolder
	
	local NameLabel = Instance.new("TextLabel")
	NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = player.DisplayName or player.Name
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameLabel.TextSize = 13
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Parent = Billboard
	
	local DistLabel = Instance.new("TextLabel")
	DistLabel.Size = UDim2.new(1, 0, 0.5, 0)
	DistLabel.Position = UDim2.new(0, 0, 0.5, 0)
	DistLabel.BackgroundTransparency = 1
	DistLabel.Text = "Calculating..."
	DistLabel.TextColor3 = ThemesConfig[currentTheme].TitleText
	DistLabel.TextSize = 11
	DistLabel.Font = Enum.Font.GothamMedium
	DistLabel.Parent = Billboard
	
	task.spawn(function()
		while espActive and char.Parent and root.Parent and DistLabel.Parent do
			local myChar = localPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if myRoot then
				DistLabel.Text = string.format("%.1f studs", (myRoot.Position - root.Position).Magnitude)
			end
			task.wait(0.1)
		end
	end)
end

EspButton.MouseButton1Click:Connect(function()
	espActive = not espActive
	if espActive then
		EspButton.Text = "Player ESP: ON"
		espContainerFolder = Instance.new("Folder")
		espContainerFolder.Name = "HubESPContainer"
		espContainerFolder.Parent = ScreenGui
		
		local function setupPlayer(p)
			if p.Character then task.spawn(applyEspToCharacter, p, p.Character) end
			p.CharacterAdded:Connect(function(c) if espActive then task.spawn(applyEspToCharacter, p, c) end end)
		end
		for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
		Players.PlayerAdded:Connect(setupPlayer)
	else
		EspButton.Text = "Player ESP: OFF"
		clearEsp()
	end
end)

----------------------------------------------------------------
-- 9. INITIALIZATION & VISIBILITY OVERLAYS
----------------------------------------------------------------

applyTheme("CrimsonRed")
displayTab("External")

local isVisible = true
CloseButton.MouseButton1Click:Connect(function() isVisible = false MainFrame.Visible = false end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then 
		isVisible = not isVisible
		MainFrame.Visible = isVisible
	end
end)
