-- Roblox Fly Mode Script with Modern UI & Expandable
-- Author: 170F Team
-- Features: Fly Mode, Modern UI, Draggable, Expandable, Rainbow Text, Settings

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Fly Mode Variables
local flyingActive = false
local flySpeed = 50
local flyUpSpeed = 50
local direction = Vector3.new(0, 0, 0)
local bodyVelocity = nil
local bodyGyro = nil

-- UI Configuration
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyModeUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 480)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add Stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Rainbow Colors
local rainbowColors = {
    Color3.fromRGB(255, 0, 127),
    Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(127, 0, 255),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 0, 0)
}

local colorIndex = 1

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(0, 255, 150)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.Text = "✈️ FLY MODE"
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Author Text
local authorText = Instance.new("TextLabel")
authorText.Name = "AuthorText"
authorText.Size = UDim2.new(0.7, 0, 0.5, 0)
authorText.Position = UDim2.new(0, 10, 0.5, 0)
authorText.BackgroundTransparency = 1
authorText.TextColor3 = Color3.fromRGB(100, 200, 150)
authorText.TextSize = 9
authorText.Font = Enum.Font.Gotham
authorText.Text = "by 170F Team"
authorText.TextXAlignment = Enum.TextXAlignment.Left
authorText.Parent = titleBar

-- Hide Button
local hideButton = Instance.new("TextButton")
hideButton.Name = "HideButton"
hideButton.Size = UDim2.new(0, 32, 1, 0)
hideButton.Position = UDim2.new(1, -70, 0, 0)
hideButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hideButton.TextSize = 16
hideButton.Font = Enum.Font.GothamBold
hideButton.Text = "━"
hideButton.BorderSizePixel = 0
hideButton.Parent = titleBar

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 8)
hideCorner.Parent = hideButton

-- Expand Button
local expandButton = Instance.new("TextButton")
expandButton.Name = "ExpandButton"
expandButton.Size = UDim2.new(0, 32, 1, 0)
expandButton.Position = UDim2.new(1, -35, 0, 0)
expandButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
expandButton.TextColor3 = Color3.fromRGB(255, 255, 255)
expandButton.TextSize = 16
expandButton.Font = Enum.Font.GothamBold
expandButton.Text = "▼"
expandButton.BorderSizePixel = 0
expandButton.Parent = titleBar

local expandCorner = Instance.new("UICorner")
expandCorner.CornerRadius = UDim.new(0, 8)
expandCorner.Parent = expandButton

-- Content Frame (Scrollable)
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 5
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = mainFrame

-- Padding
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 15)
padding.PaddingRight = UDim.new(0, 15)
padding.PaddingTop = UDim.new(0, 15)
padding.PaddingBottom = UDim.new(0, 15)
padding.Parent = contentFrame

-- List Layout
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Parent = contentFrame

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 35)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "Status: ⚫ OFF"
statusLabel.BorderSizePixel = 0
statusLabel.Parent = contentFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, 0, 0, 45)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "▶ START FLYING"
toggleButton.BorderSizePixel = 0
toggleButton.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Text = "⚡ Forward Speed: 50"
speedLabel.BorderSizePixel = 0
speedLabel.Parent = contentFrame

-- Speed Slider
local speedSlider = Instance.new("Frame")
speedSlider.Name = "SpeedSlider"
speedSlider.Size = UDim2.new(1, 0, 0, 22)
speedSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = contentFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 10)
speedCorner.Parent = speedSlider

local speedBar = Instance.new("Frame")
speedBar.Name = "SpeedBar"
speedBar.Size = UDim2.new(0.5, 0, 1, 0)
speedBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
speedBar.BorderSizePixel = 0
speedBar.Parent = speedSlider

local speedBarCorner = Instance.new("UICorner")
speedBarCorner.CornerRadius = UDim.new(0, 10)
speedBarCorner.Parent = speedBar

-- Up Speed Label
local upSpeedLabel = Instance.new("TextLabel")
upSpeedLabel.Name = "UpSpeedLabel"
upSpeedLabel.Size = UDim2.new(1, 0, 0, 25)
upSpeedLabel.BackgroundTransparency = 1
upSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
upSpeedLabel.TextSize = 12
upSpeedLabel.Font = Enum.Font.GothamBold
upSpeedLabel.Text = "⬆️ Vertical Speed: 50"
upSpeedLabel.BorderSizePixel = 0
upSpeedLabel.Parent = contentFrame

-- Up Speed Slider
local upSpeedSlider = Instance.new("Frame")
upSpeedSlider.Name = "UpSpeedSlider"
upSpeedSlider.Size = UDim2.new(1, 0, 0, 22)
upSpeedSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
upSpeedSlider.BorderSizePixel = 0
upSpeedSlider.Parent = contentFrame

local upSpeedCorner = Instance.new("UICorner")
upSpeedCorner.CornerRadius = UDim.new(0, 10)
upSpeedCorner.Parent = upSpeedSlider

local upSpeedBar = Instance.new("Frame")
upSpeedBar.Name = "UpSpeedBar"
upSpeedBar.Size = UDim2.new(0.5, 0, 1, 0)
upSpeedBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
upSpeedBar.BorderSizePixel = 0
upSpeedBar.Parent = upSpeedSlider

local upSpeedBarCorner = Instance.new("UICorner")
upSpeedBarCorner.CornerRadius = UDim.new(0, 10)
upSpeedBarCorner.Parent = upSpeedBar

-- Altitude Label
local altitudeLabel = Instance.new("TextLabel")
altitudeLabel.Name = "AltitudeLabel"
altitudeLabel.Size = UDim2.new(1, 0, 0, 25)
altitudeLabel.BackgroundTransparency = 1
altitudeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
altitudeLabel.TextSize = 12
altitudeLabel.Font = Enum.Font.GothamBold
altitudeLabel.Text = "📍 Altitude: 0m"
altitudeLabel.BorderSizePixel = 0
altitudeLabel.Parent = contentFrame

-- Controls Info
local controlsLabel = Instance.new("TextLabel")
controlsLabel.Name = "ControlsLabel"
controlsLabel.Size = UDim2.new(1, 0, 0, 80)
controlsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
controlsLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
controlsLabel.TextSize = 11
controlsLabel.Font = Enum.Font.Gotham
controlsLabel.Text = "📋 CONTROLS\n\n🎮 W/A/S/D - Move\n⬆️ SPACE - Ascend\n⬇️ CTRL - Descend\n🖱️ Mouse - Look Around"
controlsLabel.TextWrapped = true
controlsLabel.BorderSizePixel = 0
controlsLabel.Parent = contentFrame

local controlsCorner = Instance.new("UICorner")
controlsCorner.CornerRadius = UDim.new(0, 8)
controlsCorner.Parent = controlsLabel

-- Update canvas size
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)
end)

-- ===== EXPAND/COLLAPSE SYSTEM =====
local isExpanded = true
local expandedSize = UDim2.new(0, 320, 0, 550)
local collapsedSize = UDim2.new(0, 280, 0, 50)

expandButton.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    
    if isExpanded then
        mainFrame:TweenSize(expandedSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true)
        contentFrame.Visible = true
        expandButton.Text = "▲"
    else
        mainFrame:TweenSize(collapsedSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true)
        contentFrame.Visible = false
        expandButton.Text = "▼"
    end
end)

-- ===== HIDE SYSTEM =====
hideButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- ===== TOUCH DRAG SYSTEM =====
local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = UDim2.new(0, 0, 0, 0)

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ===== FLY MODE FUNCTIONS =====
local function startFlying()
    if flyingActive then return end
    flyingActive = true
    
    character = player.Character
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    -- Create BodyVelocity
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    -- Create BodyGyro
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.P = 10000
    bodyGyro.Parent = humanoidRootPart
    bodyGyro.CFrame = humanoidRootPart.CFrame
    
    statusLabel.Text = "Status: 🟢 FLYING"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    toggleButton.Text = "⏹ STOP FLYING"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
end

local function stopFlying()
    flyingActive = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    statusLabel.Text = "Status: ⚫ OFF"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    toggleButton.Text = "▶ START FLYING"
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end

local function toggleFly()
    if flyingActive then
        stopFlying()
    else
        startFlying()
    end
end

-- Button Connection
toggleButton.MouseButton1Click:Connect(function()
    toggleFly()
end)

-- Slider Interactions
local speedSliding = false
local upSpeedSliding = false

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedSliding = true
    end
end)

speedSlider.InputEnded:Connect(function()
    speedSliding = false
end)

upSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        upSpeedSliding = true
    end
end)

upSpeedSlider.InputEnded:Connect(function()
    upSpeedSliding = false
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not flyingActive then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        direction = direction + (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.A then
        direction = direction - (humanoidRootPart.CFrame.RightVector)
    elseif input.KeyCode == Enum.KeyCode.S then
        direction = direction - (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.D then
        direction = direction + (humanoidRootPart.CFrame.RightVector)
    elseif input.KeyCode == Enum.KeyCode.Space then
        direction = direction + Vector3.new(0, 1, 0)
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        direction = direction - Vector3.new(0, 1, 0)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not flyingActive then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        direction = direction - (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.A then
        direction = direction + (humanoidRootPart.CFrame.RightVector)
    elseif input.KeyCode == Enum.KeyCode.S then
        direction = direction + (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.D then
        direction = direction - (humanoidRootPart.CFrame.RightVector)
    elseif input.KeyCode == Enum.KeyCode.Space then
        direction = direction - Vector3.new(0, 1, 0)
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        direction = direction + Vector3.new(0, 1, 0)
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Rainbow Title Animation
    colorIndex = colorIndex + 1
    if colorIndex > #rainbowColors then colorIndex = 1 end
    titleText.TextColor3 = rainbowColors[colorIndex]
    
    -- Speed Slider
    if speedSliding then
        local mouseLocation
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouseLocation = UserInputService:GetMouseLocation()
        else
            mouseLocation = Vector2.new(speedSlider.AbsolutePosition.X + speedSlider.AbsoluteSize.X / 2, 0)
        end
        
        local sliderPos = speedSlider.AbsolutePosition.X
        local sliderSize = speedSlider.AbsoluteSize.X
        local relativeX = math.clamp(mouseLocation.X - sliderPos, 0, sliderSize)
        
        flySpeed = math.floor((relativeX / sliderSize) * 100)
        speedBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        speedLabel.Text = "⚡ Forward Speed: " .. flySpeed
    end
    
    -- Up Speed Slider
    if upSpeedSliding then
        local mouseLocation
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouseLocation = UserInputService:GetMouseLocation()
        else
            mouseLocation = Vector2.new(upSpeedSlider.AbsolutePosition.X + upSpeedSlider.AbsoluteSize.X / 2, 0)
        end
        
        local sliderPos = upSpeedSlider.AbsolutePosition.X
        local sliderSize = upSpeedSlider.AbsoluteSize.X
        local relativeX = math.clamp(mouseLocation.X - sliderPos, 0, sliderSize)
        
        flyUpSpeed = math.floor((relativeX / sliderSize) * 100)
        upSpeedBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        upSpeedLabel.Text = "⬆️ Vertical Speed: " .. flyUpSpeed
    end
    
    -- Flying
    if flyingActive and bodyVelocity and bodyGyro then
        local moveDirection = direction * (flySpeed / 10)
        
        -- Normalize and apply speed
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * (flySpeed / 10)
        end
        
        bodyVelocity.Velocity = moveDirection
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        
        -- Update altitude
        altitudeLabel.Text = "📍 Altitude: " .. math.floor(humanoidRootPart.Position.Y) .. "m"
    end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newCharacter)
    if flyingActive then
        stopFlying()
    end
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    direction = Vector3.new(0, 0, 0)
end)

print("✅ FLY MODE SCRIPT LOADED - Author: 170F Team")
print("✈️ Click START FLYING to begin!")
