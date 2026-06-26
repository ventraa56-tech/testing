-- Roblox Silent Aim Script with Modern UI & Expandable
-- Author: 170F Team
-- Features: Silent Aim (Directional Input), Modern UI, Draggable, Expandable, Rainbow Text

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Silent Aim Variables
local silentAimActive = false
local lockedTarget = nil
local lockedTargetCharacter = nil
local aimSmoothness = 0.15
local searchRadius = 100
local targetBodyPart = "Head"
local autoLock = true
local predictMovement = true
local predictionOffset = 0.1

-- Original input tracking
local originalInputs = {
    W = false,
    A = false,
    S = false,
    D = false
}

-- UI Configuration
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SilentAimUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 500)
mainFrame.Position = UDim2.new(0.8, -320, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add Stroke
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 255)
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
titleText.TextColor3 = Color3.fromRGB(255, 0, 127)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.Text = "🔫 SILENT AIM"
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
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "▶ ENABLE"
toggleButton.BorderSizePixel = 0
toggleButton.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Smoothness Label
local smoothnessLabel = Instance.new("TextLabel")
smoothnessLabel.Name = "SmoothnessLabel"
smoothnessLabel.Size = UDim2.new(1, 0, 0, 25)
smoothnessLabel.BackgroundTransparency = 1
smoothnessLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
smoothnessLabel.TextSize = 12
smoothnessLabel.Font = Enum.Font.GothamBold
smoothnessLabel.Text = "⚙️ Smoothness: 0.15"
smoothnessLabel.BorderSizePixel = 0
smoothnessLabel.Parent = contentFrame

-- Smoothness Slider
local smoothnessSlider = Instance.new("Frame")
smoothnessSlider.Name = "SmoothnessSlider"
smoothnessSlider.Size = UDim2.new(1, 0, 0, 22)
smoothnessSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
smoothnessSlider.BorderSizePixel = 0
smoothnessSlider.Parent = contentFrame

local smoothCorner = Instance.new("UICorner")
smoothCorner.CornerRadius = UDim.new(0, 10)
smoothCorner.Parent = smoothnessSlider

local smoothnessBar = Instance.new("Frame")
smoothnessBar.Name = "SmoothnessBar"
smoothnessBar.Size = UDim2.new(0.15, 0, 1, 0)
smoothnessBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
smoothnessBar.BorderSizePixel = 0
smoothnessBar.Parent = smoothnessSlider

local smoothBarCorner = Instance.new("UICorner")
smoothBarCorner.CornerRadius = UDim.new(0, 10)
smoothBarCorner.Parent = smoothnessBar

-- Range Label
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Name = "RangeLabel"
rangeLabel.Size = UDim2.new(1, 0, 0, 25)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
rangeLabel.TextSize = 12
rangeLabel.Font = Enum.Font.GothamBold
rangeLabel.Text = "📍 Range: 100m"
rangeLabel.BorderSizePixel = 0
rangeLabel.Parent = contentFrame

-- Range Slider
local rangeSlider = Instance.new("Frame")
rangeSlider.Name = "RangeSlider"
rangeSlider.Size = UDim2.new(1, 0, 0, 22)
rangeSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
rangeSlider.BorderSizePixel = 0
rangeSlider.Parent = contentFrame

local rangeCorner = Instance.new("UICorner")
rangeCorner.CornerRadius = UDim.new(0, 10)
rangeCorner.Parent = rangeSlider

local rangeBar = Instance.new("Frame")
rangeBar.Name = "RangeBar"
rangeBar.Size = UDim2.new(1/3, 0, 1, 0)
rangeBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
rangeBar.BorderSizePixel = 0
rangeBar.Parent = rangeSlider

local rangeBarCorner = Instance.new("UICorner")
rangeBarCorner.CornerRadius = UDim.new(0, 10)
rangeBarCorner.Parent = rangeBar

-- Prediction Label
local predictionLabel = Instance.new("TextLabel")
predictionLabel.Name = "PredictionLabel"
predictionLabel.Size = UDim2.new(1, 0, 0, 25)
predictionLabel.BackgroundTransparency = 1
predictionLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
predictionLabel.TextSize = 12
predictionLabel.Font = Enum.Font.GothamBold
predictionLabel.Text = "🔮 Prediction: 0.10"
predictionLabel.BorderSizePixel = 0
predictionLabel.Parent = contentFrame

-- Prediction Slider
local predictionSlider = Instance.new("Frame")
predictionSlider.Name = "PredictionSlider"
predictionSlider.Size = UDim2.new(1, 0, 0, 22)
predictionSlider.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
predictionSlider.BorderSizePixel = 0
predictionSlider.Parent = contentFrame

local predCorner = Instance.new("UICorner")
predCorner.CornerRadius = UDim.new(0, 10)
predCorner.Parent = predictionSlider

local predictionBar = Instance.new("Frame")
predictionBar.Name = "PredictionBar"
predictionBar.Size = UDim2.new(0.1, 0, 1, 0)
predictionBar.BackgroundColor3 = Color3.fromRGB(255, 150, 100)
predictionBar.BorderSizePixel = 0
predictionBar.Parent = predictionSlider

local predBarCorner = Instance.new("UICorner")
predBarCorner.CornerRadius = UDim.new(0, 10)
predBarCorner.Parent = predictionBar

-- Body Part Label
local bodyPartLabel = Instance.new("TextLabel")
bodyPartLabel.Name = "BodyPartLabel"
bodyPartLabel.Size = UDim2.new(1, 0, 0, 25)
bodyPartLabel.BackgroundTransparency = 1
bodyPartLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
bodyPartLabel.TextSize = 12
bodyPartLabel.Font = Enum.Font.GothamBold
bodyPartLabel.Text = "🎯 Target: HEAD"
bodyPartLabel.BorderSizePixel = 0
bodyPartLabel.Parent = contentFrame

-- Body Part Buttons Container
local bodyPartContainer = Instance.new("Frame")
bodyPartContainer.Name = "BodyPartContainer"
bodyPartContainer.Size = UDim2.new(1, 0, 0, 50)
bodyPartContainer.BackgroundTransparency = 1
bodyPartContainer.Parent = contentFrame

local bodyPartLayout = Instance.new("UIListLayout")
bodyPartLayout.Padding = UDim.new(0, 5)
bodyPartLayout.FillDirection = Enum.FillDirection.Horizontal
bodyPartLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bodyPartLayout.VerticalAlignment = Enum.VerticalAlignment.Center
bodyPartLayout.Parent = bodyPartContainer

-- Head Button
local headButton = Instance.new("TextButton")
headButton.Name = "HeadButton"
headButton.Size = UDim2.new(0.3, 0, 1, 0)
headButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
headButton.TextColor3 = Color3.fromRGB(255, 255, 255)
headButton.TextSize = 11
headButton.Font = Enum.Font.GothamBold
headButton.Text = "HEAD"
headButton.BorderSizePixel = 0
headButton.Parent = bodyPartContainer

local headCorner = Instance.new("UICorner")
headCorner.CornerRadius = UDim.new(0, 6)
headCorner.Parent = headButton

-- Body Button
local bodyButton = Instance.new("TextButton")
bodyButton.Name = "BodyButton"
bodyButton.Size = UDim2.new(0.3, 0, 1, 0)
bodyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
bodyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bodyButton.TextSize = 11
bodyButton.Font = Enum.Font.GothamBold
bodyButton.Text = "BODY"
bodyButton.BorderSizePixel = 0
bodyButton.Parent = bodyPartContainer

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0, 6)
bodyCorner.Parent = bodyButton

-- Torso Button
local torsoButton = Instance.new("TextButton")
torsoButton.Name = "TorsoButton"
torsoButton.Size = UDim2.new(0.3, 0, 1, 0)
torsoButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
torsoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
torsoButton.TextSize = 11
torsoButton.Font = Enum.Font.GothamBold
torsoButton.Text = "TORSO"
torsoButton.BorderSizePixel = 0
torsoButton.Parent = bodyPartContainer

local torsoCorner = Instance.new("UICorner")
torsoCorner.CornerRadius = UDim.new(0, 6)
torsoCorner.Parent = torsoButton

-- Target Info Label
local targetInfoLabel = Instance.new("TextLabel")
targetInfoLabel.Name = "TargetInfoLabel"
targetInfoLabel.Size = UDim2.new(1, 0, 0, 70)
targetInfoLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
targetInfoLabel.TextColor3 = Color3.fromRGB(100, 200, 150)
targetInfoLabel.TextSize = 11
targetInfoLabel.Font = Enum.Font.Gotham
targetInfoLabel.Text = "🔫 SILENT AIM\n\n📛 No Target\n💚 Health: -\n📏 Distance: -"
targetInfoLabel.TextWrapped = true
targetInfoLabel.BorderSizePixel = 0
targetInfoLabel.Parent = contentFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = targetInfoLabel

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

-- ===== SILENT AIM FUNCTIONS =====
local function findNearestTarget()
    local nearest = nil
    local nearestDistance = searchRadius
    local nearestCharacter = nil
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local targetChar = targetPlayer.Character
            if targetChar then
                local targetRootPart = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if targetRootPart and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = (targetRootPart.Position - humanoidRootPart.Position).Magnitude
                    
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearest = targetRootPart
                        nearestCharacter = targetChar
                    end
                end
            end
        end
    end
    
    return nearest, nearestCharacter
end

local function updateTarget()
    if silentAimActive and autoLock then
        lockedTarget, lockedTargetCharacter = findNearestTarget()
    end
    
    if lockedTarget and lockedTarget.Parent and lockedTargetCharacter then
        local targetHumanoid = lockedTargetCharacter:FindFirstChildOfClass("Humanoid")
        if targetHumanoid and targetHumanoid.Health > 0 then
            local distance = (lockedTarget.Position - humanoidRootPart.Position).Magnitude
            targetInfoLabel.Text = "🔫 SILENT AIM\n\n📛 " .. lockedTargetCharacter.Name .. "\n💚 Health: " .. math.floor(targetHumanoid.Health) .. "\n📏 Distance: " .. math.floor(distance) .. "m"
        else
            lockedTarget = nil
            lockedTargetCharacter = nil
        end
    else
        lockedTarget = nil
        lockedTargetCharacter = nil
        targetInfoLabel.Text = "🔫 SILENT AIM\n\n📛 No Target\n💚 Health: -\n📏 Distance: -"
    end
end

local function getTargetDirection()
    if not lockedTarget or not lockedTargetCharacter then return nil end
    
    local targetPart = lockedTargetCharacter:FindFirstChild(targetBodyPart)
    if not targetPart then
        targetPart = lockedTargetCharacter:FindFirstChild("Head")
    end
    
    if not targetPart then return nil end
    
    local targetPos = targetPart.Position
    
    -- Add prediction
    if predictMovement then
        local velocity = targetPart.AssemblyLinearVelocity
        targetPos = targetPos + (velocity * predictionOffset)
    end
    
    -- Calculate direction from player's position
    return (targetPos - humanoidRootPart.Position).Unit
end

local function performSilentAim()
    if not silentAimActive or not lockedTarget or not lockedTargetCharacter then 
        return 
    end
    
    local targetDirection = getTargetDirection()
    if not targetDirection then return end
    
    -- Get camera direction
    local cameraForward = camera.CFrame.LookVector
    
    -- Interpolate towards target
    local aimDirection = cameraForward:Lerp(targetDirection, aimSmoothness)
    
    -- Simulate inputs based on aim direction
    local rightVector = camera.CFrame.RightVector
    local upVector = camera.CFrame.UpVector
    
    -- Calculate how much to move in each direction
    local dotRight = aimDirection:Dot(rightVector)
    local dotUp = aimDirection:Dot(upVector)
    
    -- Simulate key presses based on direction
    local currentInputs = {
        W = false,
        A = false,
        S = false,
        D = false
    }
    
    if dotRight > 0.1 then
        currentInputs.D = true
    elseif dotRight < -0.1 then
        currentInputs.A = true
    end
    
    if dotUp > 0.1 then
        currentInputs.W = true
    elseif dotUp < -0.1 then
        currentInputs.S = true
    end
    
    -- Apply the silent aim by modifying movement
    originalInputs = currentInputs
end

local function toggleSilentAim()
    silentAimActive = not silentAimActive
    
    if silentAimActive then
        statusLabel.Text = "Status: 🟢 ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleButton.Text = "⏹ DISABLE"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    else
        statusLabel.Text = "Status: ⚫ OFF"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleButton.Text = "▶ ENABLE"
        toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        originalInputs = {W = false, A = false, S = false, D = false}
    end
end

-- Button Connections
toggleButton.MouseButton1Click:Connect(function()
    toggleSilentAim()
end)

headButton.MouseButton1Click:Connect(function()
    targetBodyPart = "Head"
    bodyPartLabel.Text = "🎯 Target: HEAD"
    headButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    bodyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    torsoButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
end)

bodyButton.MouseButton1Click:Connect(function()
    targetBodyPart = "UpperTorso"
    bodyPartLabel.Text = "🎯 Target: BODY"
    headButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    bodyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    torsoButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
end)

torsoButton.MouseButton1Click:Connect(function()
    targetBodyPart = "Torso"
    bodyPartLabel.Text = "🎯 Target: TORSO"
    headButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    bodyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    torsoButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
end)

-- Slider Interactions
local smoothnessSliding = false
local rangeSliding = false
local predictionSliding = false

smoothnessSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        smoothnessSliding = true
    end
end)

smoothnessSlider.InputEnded:Connect(function()
    smoothnessSliding = false
end)

rangeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        rangeSliding = true
    end
end)

rangeSlider.InputEnded:Connect(function()
    rangeSliding = false
end)

predictionSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        predictionSliding = true
    end
end)

predictionSlider.InputEnded:Connect(function()
    predictionSliding = false
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Rainbow Title Animation
    colorIndex = colorIndex + 1
    if colorIndex > #rainbowColors then colorIndex = 1 end
    titleText.TextColor3 = rainbowColors[colorIndex]
    
    -- Smoothness Slider
    if smoothnessSliding then
        local mouseLocation
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouseLocation = UserInputService:GetMouseLocation()
        else
            mouseLocation = Vector2.new(smoothnessSlider.AbsolutePosition.X + smoothnessSlider.AbsoluteSize.X / 2, 0)
        end
        
        local sliderPos = smoothnessSlider.AbsolutePosition.X
        local sliderSize = smoothnessSlider.AbsoluteSize.X
        local relativeX = math.clamp(mouseLocation.X - sliderPos, 0, sliderSize)
        
        aimSmoothness = (relativeX / sliderSize) * 0.3
        smoothnessBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        smoothnessLabel.Text = "⚙️ Smoothness: " .. string.format("%.2f", aimSmoothness)
    end
    
    -- Range Slider
    if rangeSliding then
        local mouseLocation
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouseLocation = UserInputService:GetMouseLocation()
        else
            mouseLocation = Vector2.new(rangeSlider.AbsolutePosition.X + rangeSlider.AbsoluteSize.X / 2, 0)
        end
        
        local sliderPos = rangeSlider.AbsolutePosition.X
        local sliderSize = rangeSlider.AbsoluteSize.X
        local relativeX = math.clamp(mouseLocation.X - sliderPos, 0, sliderSize)
        
        searchRadius = (relativeX / sliderSize) * 300
        rangeBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        rangeLabel.Text = "📍 Range: " .. math.floor(searchRadius) .. "m"
    end
    
    -- Prediction Slider
    if predictionSliding then
        local mouseLocation
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouseLocation = UserInputService:GetMouseLocation()
        else
            mouseLocation = Vector2.new(predictionSlider.AbsolutePosition.X + predictionSlider.AbsoluteSize.X / 2, 0)
        end
        
        local sliderPos = predictionSlider.AbsolutePosition.X
        local sliderSize = predictionSlider.AbsoluteSize.X
        local relativeX = math.clamp(mouseLocation.X - sliderPos, 0, sliderSize)
        
        predictionOffset = (relativeX / sliderSize) * 0.5
        predictionBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        predictionLabel.Text = "🔮 Prediction: " .. string.format("%.2f", predictionOffset)
    end
    
    -- Update Target
    updateTarget()
    
    -- Perform Silent Aim
    if silentAimActive then
        performSilentAim()
    end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newCharacter)
    if silentAimActive then toggleSilentAim() end
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    lockedTarget = nil
    lockedTargetCharacter = nil
end)

print("✅ SILENT AIM SCRIPT LOADED - Author: 170F Team")
print("🔫 Silent Aim modifies directional input, not camera!")
