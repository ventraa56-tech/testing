local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "170F Team Test UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 150)
frame.Position = UDim2.new(0.5, -140, 0.5, -75)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "WalkSpeed Test - Author: 170F Team"
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(0, 120, 0, 30)
input.Position = UDim2.new(0, 10, 0, 45)
input.Text = "16"
input.Parent = frame

local apply = Instance.new("TextButton")
apply.Size = UDim2.new(0, 120, 0, 30)
apply.Position = UDim2.new(0, 145, 0, 45)
apply.Text = "Apply"
apply.Parent = frame

local hide = Instance.new("TextButton")
hide.Size = UDim2.new(0, 120, 0, 30)
hide.Position = UDim2.new(0, 10, 0, 90)
hide.Text = "Hide"
hide.Parent = frame

local exit = Instance.new("TextButton")
exit.Size = UDim2.new(0, 120, 0, 30)
exit.Position = UDim2.new(0, 145, 0, 90)
exit.Text = "Exit"
exit.Parent = frame

local minimized = false

hide.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        frame.Size = UDim2.new(0, 280, 0, 30)
        input.Visible = false
        apply.Visible = false
        exit.Visible = false
        hide.Text = "Show"
    else
        frame.Size = UDim2.new(0, 280, 0, 150)
        input.Visible = true
        apply.Visible = true
        exit.Visible = true
        hide.Text = "Hide"
    end
end)

apply.MouseButton1Click:Connect(function()
    local speed = tonumber(input.Text)
    if speed then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
end)

exit.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
