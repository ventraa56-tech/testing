local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "170F Team UI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 140)
Frame.Position = UDim2.new(0.5, -130, 0.5, -70)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Auto Click Config - 170F Team"
Title.Parent = Frame

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0, 120, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 50)
SpeedBox.Text = "10"
SpeedBox.PlaceholderText = "Clicks / Second"
SpeedBox.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 220, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 95)
Status.Text = "Configured CPS: 10"
Status.Parent = Frame

SpeedBox.FocusLost:Connect(function()
	local cps = tonumber(SpeedBox.Text)
	if cps then
		Status.Text = "Configured CPS: " .. cps
	else
		SpeedBox.Text = "10"
		Status.Text = "Configured CPS: 10"
	end
end)
