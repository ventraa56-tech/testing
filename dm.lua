--// 170F Team - Damage Test UI (For Your Own Game)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
Player:SetAttribute("DamageMultiplier", 1)

local gui = Instance.new("ScreenGui")
gui.Name = "170F_DamageTest"
gui.ResetOnSpawn = false
gui.Parent = Player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,180)
frame.Position = UDim2.new(0.5,-150,0.5,-90)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "170F Team | Damage Tester"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local value = Instance.new("TextBox")
value.Size = UDim2.new(0.8,0,0,35)
value.Position = UDim2.new(0.1,0,0.3,0)
value.PlaceholderText = "Damage Multiplier"
value.Text = "1"
value.Parent = frame

local apply = Instance.new("TextButton")
apply.Size = UDim2.new(0.8,0,0,35)
apply.Position = UDim2.new(0.1,0,0.58,0)
apply.Text = "Apply"
apply.Parent = frame

local hide = Instance.new("TextButton")
hide.Size = UDim2.new(0,30,0,30)
hide.Position = UDim2.new(1,-65,0,0)
hide.Text = "-"
hide.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.Parent = frame

local hidden = false
hide.MouseButton1Click:Connect(function()
	hidden = not hidden
	value.Visible = not hidden
	apply.Visible = not hidden
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

apply.MouseButton1Click:Connect(function()
	local num = tonumber(value.Text)
	if num then
		Player:SetAttribute("DamageMultiplier", num)
	end
end)

-- Drag UI
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Rainbow title
RunService.RenderStepped:Connect(function()
	local t = tick() * 0.5
	title.TextColor3 = Color3.fromHSV(t % 1, 1, 1)
end)
