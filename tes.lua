--//====================================================
--// 170F Team - WalkSpeed UI (Updated)
--// Features:
--// ✔ Rainbow UI Accent
--// ✔ Drag UI
--// ✔ Hide / Show
--// ✔ Exit
--// ✔ WalkSpeed Input
--// ✔ Reset Button
--// ✔ Auto Apply on Respawn
--// ✔ Delta Executor Friendly
--//====================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local parent = (gethui and gethui()) or game:GetService("CoreGui")

pcall(function()
	if parent:FindFirstChild("170F_WalkSpeed") then
		parent["170F_WalkSpeed"]:Destroy()
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "170F_WalkSpeed"
gui.ResetOnSpawn = false
gui.Parent = parent

------------------------------------------------
-- Main
------------------------------------------------

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,340,0,210)
frame.Position = UDim2.new(.5,-170,.5,-105)
frame.BackgroundColor3 = Color3.fromRGB(22,22,22)
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Parent = frame

------------------------------------------------
-- Title
------------------------------------------------

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "⚡ 170F Team - WalkSpeed Editor"
title.Font = Enum.Font.GothamBold
title.TextScaled = true

------------------------------------------------
-- Input
------------------------------------------------

local input = Instance.new("TextBox")
input.Parent = frame
input.Size = UDim2.new(.82,0,0,38)
input.Position = UDim2.new(.09,0,.28,0)
input.PlaceholderText = "Example : 16 / 50 / 100"
input.Text = "16"
input.Font = Enum.Font.Gotham
input.TextScaled = true
input.ClearTextOnFocus = false

Instance.new("UICorner",input)

------------------------------------------------
-- Buttons
------------------------------------------------

local function MakeButton(text,x)
	local b = Instance.new("TextButton")
	b.Parent = frame
	b.Size = UDim2.new(0,95,0,34)
	b.Position = UDim2.new(0,x,0,120)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	Instance.new("UICorner",b)
	return b
end

local setBtn   = MakeButton("SET",15)
local resetBtn = MakeButton("RESET",122)
local hideBtn  = MakeButton("HIDE",230)

local exitBtn = Instance.new("TextButton")
exitBtn.Parent = frame
exitBtn.Size = UDim2.new(.82,0,0,32)
exitBtn.Position = UDim2.new(.09,0,.83,0)
exitBtn.Text = "EXIT UI"
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextScaled = true
Instance.new("UICorner",exitBtn)

------------------------------------------------
-- Credit
------------------------------------------------

local credit = Instance.new("TextLabel")
credit.Parent = frame
credit.BackgroundTransparency = 1
credit.Position = UDim2.new(0,0,1,-18)
credit.Size = UDim2.new(1,0,0,16)
credit.Font = Enum.Font.Gotham
credit.TextScaled = true
credit.Text = "Author : 170F Team"

------------------------------------------------
-- Rainbow
------------------------------------------------

task.spawn(function()
	while task.wait() do
		local h = (tick()*0.15)%1
		local c = Color3.fromHSV(h,1,1)

		title.TextColor3 = c
		credit.TextColor3 = c
		stroke.Color = c

		setBtn.BackgroundColor3 = c
		resetBtn.BackgroundColor3 = c
		hideBtn.BackgroundColor3 = c
		exitBtn.BackgroundColor3 = c
	end
end)

------------------------------------------------
-- Drag
------------------------------------------------

local dragging=false
local dragInput
local dragStart
local startPos

frame.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1
	or inp.UserInputType==Enum.UserInputType.Touch then
		dragging=true
		dragStart=inp.Position
		startPos=frame.Position

		inp.Changed:Connect(function()
			if inp.UserInputState==Enum.UserInputState.End then
				dragging=false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseMovement
	or inp.UserInputType==Enum.UserInputType.Touch then
		dragInput=inp
	end
end)

UIS.InputChanged:Connect(function(inp)
	if inp==dragInput and dragging then
		local delta=inp.Position-dragStart
		frame.Position=UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset+delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset+delta.Y
		)
	end
end)

------------------------------------------------
-- WalkSpeed
------------------------------------------------

local savedSpeed=16

local function Apply(speed)
	local char=player.Character or player.CharacterAdded:Wait()
	local hum=char:FindFirstChildWhichIsA("Humanoid")
	if hum then
		hum.WalkSpeed=speed
	end
end

setBtn.MouseButton1Click:Connect(function()
	local num=tonumber(input.Text)
	if num then
		savedSpeed=num
		Apply(num)
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	savedSpeed=16
	input.Text="16"
	Apply(16)
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	Apply(savedSpeed)
end)

------------------------------------------------
-- Hide
------------------------------------------------

local minimized=false

hideBtn.MouseButton1Click:Connect(function()

	minimized=not minimized

	input.Visible=not minimized
	setBtn.Visible=not minimized
	resetBtn.Visible=not minimized
	exitBtn.Visible=not minimized
	credit.Visible=not minimized

	if minimized then
		frame.Size=UDim2.new(0,340,0,40)
		hideBtn.Text="SHOW"
	else
		frame.Size=UDim2.new(0,340,0,210)
		hideBtn.Text="HIDE"
	end

end)

------------------------------------------------
-- Exit
------------------------------------------------

exitBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
