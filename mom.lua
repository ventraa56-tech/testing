-- Roblox Fly Mode Script with Mobile Joystick Support (FIXED FOR MOBILE TOUCH)
-- Author: 170F Team
-- Features: Fly mode, Mobile Joystick, Modern UI, Draggable by Touch, Minimizable, Rainbow Text

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- UI Configuration
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyModeUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add Stroke for modern look
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Rainbow Text Colors
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
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Title Text (Rainbow animated)
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 0, 127)
titleText.TextSize = 18
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
authorText.TextColor3 = Color3.fromRGB(150, 150, 255)
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

-- Exit Button
local exitButton = Instance.new("TextButton")
exitButton.Name = "ExitButton"
exitButton.Size = UDim2.new(0, 32, 1, 0)
exitButton.Position = UDim2.new(1, -35, 0, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 16
exitButton.Font = Enum.Font.GothamBold
exitButton.Text = "✕"
exitButton.BorderSizePixel = 0
exitButton.Parent = titleBar

local exitCorner = Instance.new("UICorner")
exitCorner.CornerRadius = UDim.new(0, 8)
exitCorner.Parent = exitButton

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -45)
contentFrame.Position = UDim2.new(0, 0, 0, 45)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Padding
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
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
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "▶ START FLY"
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
speedLabel.Text = "⚡ Speed: 50"
speedLabel.BorderSizePixel = 0
speedLabel.Parent = contentFrame

-- Speed Slider
local speedSlider = Instance.new("Frame")
speedSlider.Name = "SpeedSlider"
speedSlider.Size = UDim2.new(1, 0, 0, 22)
speedSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = contentFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 10)
sliderCorner.Parent = speedSlider

local speedBar = Instance.new("Frame")
speedBar.Name = "SpeedBar"
speedBar.Size = UDim2.new(0.5, 0, 1, 0)
speedBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
speedBar.BorderSizePixel = 0
speedBar.Parent = speedSlider

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 10)
barCorner.Parent = speedBar

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

-- Control Info
local controlLabel = Instance.new("TextLabel")
controlLabel.Name = "ControlLabel"
controlLabel.Size = UDim2.new(1, 0, 0, 80)
controlLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
controlLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
controlLabel.TextSize = 10
controlLabel.Font = Enum.Font.Gotham
controlLabel.Text = "📱 MOBILE JOYSTICK\n🎮 Use Joystick to Move\n\n⬆️ JUMP - Ascend\n⬇️ CROUCH - Descend\n\n👆 Drag title to move"
controlLabel.TextWrapped = true
controlLabel.BorderSizePixel = 0
controlLabel.Parent = contentFrame

local controlCorner = Instance.new("UICorner")
controlCorner.CornerRadius = UDim.new(0, 8)
controlCorner.Parent = controlLabel

-- Fly System Variables
local flying = false
local speed = 50
local direction = Vector3.new(0, 0, 0)
local bodyVelocity
local bodyGyro
local jumpPressTime = 0
local crouchPressTime = 0

-- ===== TOUCH DRAG SYSTEM (MOBILE FIX) =====
local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = UDim2.new(0, 0, 0, 0)
local touchId = nil

-- Functions
local function startFly()
    if flying then return end
    flying = true
    
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
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    toggleButton.Text = "⏹ STOP FLY"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
end

local function stopFly()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    statusLabel.Text = "Status: ⚫ OFF"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    toggleButton.Text = "▶ START FLY"
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
end

-- ===== TOUCH DRAG HANDLING (MOBILE) =====
local function updateDragTouch(touchInput)
    if dragging and touchInput.UserInputType == Enum.UserInputType.Touch then
        local delta = touchInput.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        touchId = input
        
        -- Detect when touch ends
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                touchId = nil
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        updateDragTouch(input)
    end
end)

-- Input Handling for Mobile Joystick & Keyboard
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
        direction = direction + (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
        direction = direction - (humanoidRootPart.CFrame.RightVector)
    elseif input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.Down then
        direction = direction - (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
        direction = direction + (humanoidRootPart.CFrame.RightVector)
    elseif input.KeyCode == Enum.KeyCode.Space then
        jumpPressTime = tick()
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        crouchPressTime = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then
        direction = direction - (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
        direction = direction + (humanoidRootPart.CFrame.RightVector)
    elseif input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.Down then
        direction = direction + (humanoidRootPart.CFrame.LookVector)
    elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
        direction = direction - (humanoidRootPart.CFrame.RightVector)
    end
end)

-- Button Connections
toggleButton.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

hideButton.MouseButton1Click:Connect(function()
    contentFrame.Visible = not contentFrame.Visible
    titleBar.BackgroundColor3 = contentFrame.Visible and Color3.fromRGB(25, 25, 40) or Color3.fromRGB(35, 35, 55)
end)

exitButton.MouseButton1Click:Connect(function()
    if flying then stopFly() end
    screenGui:Destroy()
    script:Destroy()
end)

-- Slider Interaction (Touch + Mouse compatible)
local sliderDragging = false
local sliderTouchId = nil

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        sliderTouchId = input
    end
end)

speedSlider.InputEnded:Connect(function(input)
    if input == sliderTouchId then
        sliderDragging = false
        sliderTouchId = nil
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Rainbow Title Animation
    colorIndex = colorIndex + 1
    if colorIndex > #rainbowColors then colorIndex = 1 end
    titleText.TextColor3 = rainbowColors[colorIndex]
    
    -- Speed Slider Control
    if sliderDragging and flying then
        local mouseLocation
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouseLocation = UserInputService:GetMouseLocation()
        else
            -- For touch, estimate position
            mouseLocation = Vector2.new(screenGui.AbsoluteSize.X / 2, screenGui.AbsoluteSize.Y / 2)
        end
        
        local sliderPosition = speedSlider.AbsolutePosition.X
        local sliderSize = speedSlider.AbsoluteSize.X
        
        local relativeX = math.clamp(mouseLocation.X - sliderPosition, 0, sliderSize)
        speed = math.floor((relativeX / sliderSize) * 100)
        
        speedBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        speedLabel.Text = "⚡ Speed: " .. speed
    end
    
    -- Mobile Joystick Input (Using Humanoid.MoveDirection)
    if flying then
        local moveDirection = humanoid.MoveDirection
        
        -- Get Camera Direction
        local camera = workspace.CurrentCamera
        local cameraDirection = camera.CFrame.LookVector
        local cameraSideVector = camera.CFrame.RightVector
        
        -- Calculate movement from joystick
        local joystickMovement = (moveDirection.X * cameraSideVector + moveDirection.Z * cameraDirection)
        
        -- Vertical Control (Jump = Ascend, Crouch = Descend)
        local verticalInput = Vector3.new(0, 0, 0)
        
        if tick() - jumpPressTime < 0.1 then
            verticalInput = Vector3.new(0, 1, 0)
        elseif tick() - crouchPressTime < 0.1 then
            verticalInput = Vector3.new(0, -1, 0)
        end
        
        -- Combine directions
        local finalDirection = joystickMovement + verticalInput
        
        -- Apply velocity
        if bodyVelocity then
            bodyVelocity.Velocity = finalDirection * (speed / 10)
        end
        
        -- Update camera/player look direction
        if bodyGyro then
            bodyGyro.CFrame = camera.CFrame
        end
        
        -- Update altitude display
        altitudeLabel.Text = "📍 Altitude: " .. math.floor(humanoidRootPart.Position.Y) .. "m"
    end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newCharacter)
    if flying then
        stopFly()
    end
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)

print("✅ MOBILE FLY MODE SCRIPT LOADED - Author: 170F Team")
print("📱 Use mobile joystick to move, SPACE to ascend, CTRL to descend")
print("👆 Drag UI by touching the title bar!")
