-- Roblox Aimlock POV Script with Modern UI
-- Author: 170F Team
-- Features: Aimlock, POV Camera, Modern UI, Draggable, Minimizable, Rainbow Text

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Aimlock Variables
local aimlockActive = false
local povActive = false
local lockedTarget = nil
local aimSmoothness = 0.1
local targetDistance = 50
local searchRadius = 100
local autoTarget = true

-- UI Configuration
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimlockUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 520)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
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
titleBar.BackgroundColor3 = Color3.fromRGB(15, 25, 30)
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
titleText.Text = "🎯 AIMLOCK"
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
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundTransparency = 1
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
statusLabel.Size = UDim2.new(1, 0, 0, 40)
statusLabel.BackgroundColor3 = Color3.fromRGB(15, 25, 30)
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 150)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "Status: ⚫ OFF"
statusLabel.BorderSizePixel = 0
statusLabel.Parent = contentFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- Toggle Aimlock Button
local toggleAimlockButton = Instance.new("TextButton")
toggleAimlockButton.Name = "ToggleAimlockButton"
toggleAimlockButton.Size = UDim2.new(1, 0, 0, 50)
toggleAimlockButton.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
toggleAimlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleAimlockButton.TextSize = 15
toggleAimlockButton.Font = Enum.Font.GothamBold
toggleAimlockButton.Text = "▶ ENABLE AIMLOCK"
toggleAimlockButton.BorderSizePixel = 0
toggleAimlockButton.Parent = contentFrame

local aimlockCorner = Instance.new("UICorner")
aimlockCorner.CornerRadius = UDim.new(0, 8)
aimlockCorner.Parent = toggleAimlockButton

-- Toggle POV Button
local togglePovButton = Instance.new("TextButton")
togglePovButton.Name = "TogglePovButton"
togglePovButton.Size = UDim2.new(1, 0, 0, 50)
togglePovButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
togglePovButton.TextColor3 = Color3.fromRGB(255, 255, 255)
togglePovButton.TextSize = 15
togglePovButton.Font = Enum.Font.GothamBold
togglePovButton.Text = "📷 ENABLE POV"
togglePovButton.BorderSizePixel = 0
togglePovButton.Parent = contentFrame

local povCorner = Instance.new("UICorner")
povCorner.CornerRadius = UDim.new(0, 8)
povCorner.Parent = togglePovButton

-- Smoothness Label
local smoothnessLabel = Instance.new("TextLabel")
smoothnessLabel.Name = "SmoothnessLabel"
smoothnessLabel.Size = UDim2.new(1, 0, 0, 28)
smoothnessLabel.BackgroundTransparency = 1
smoothnessLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
smoothnessLabel.TextSize = 13
smoothnessLabel.Font = Enum.Font.GothamBold
smoothnessLabel.Text = "🔧 Smoothness: 0.10"
smoothnessLabel.BorderSizePixel = 0
smoothnessLabel.Parent = contentFrame

-- Smoothness Slider
local smoothnessSlider = Instance.new("Frame")
smoothnessSlider.Name = "SmoothnessSlider"
smoothnessSlider.Size = UDim2.new(1, 0, 0, 24)
smoothnessSlider.BackgroundColor3 = Color3.fromRGB(15, 25, 30)
smoothnessSlider.BorderSizePixel = 0
smoothnessSlider.Parent = contentFrame

local smoothCorner = Instance.new("UICorner")
smoothCorner.CornerRadius = UDim.new(0, 10)
smoothCorner.Parent = smoothnessSlider

local smoothnessBar = Instance.new("Frame")
smoothnessBar.Name = "SmoothnessBar"
smoothnessBar.Size = UDim2.new(0.1, 0, 1, 0)
smoothnessBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
smoothnessBar.BorderSizePixel = 0
smoothnessBar.Parent = smoothnessSlider

local smoothBarCorner = Instance.new("UICorner")
smoothBarCorner.CornerRadius = UDim.new(0, 10)
smoothBarCorner.Parent = smoothnessBar

-- Range Label
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Name = "RangeLabel"
rangeLabel.Size = UDim2.new(1, 0, 0, 28)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
rangeLabel.TextSize = 13
rangeLabel.Font = Enum.Font.GothamBold
rangeLabel.Text = "📍 Range: 100m"
rangeLabel.BorderSizePixel = 0
rangeLabel.Parent = contentFrame

-- Range Slider
local rangeSlider = Instance.new("Frame")
rangeSlider.Name = "RangeSlider"
rangeSlider.Size = UDim2.new(1, 0, 0, 24)
rangeSlider.BackgroundColor3 = Color3.fromRGB(15, 25, 30)
rangeSlider.BorderSizePixel = 0
rangeSlider.Parent = contentFrame

local rangeCorner = Instance.new("UICorner")
rangeCorner.CornerRadius = UDim.new(0, 10)
rangeCorner.Parent = rangeSlider

local rangeBar = Instance.new("Frame")
rangeBar.Name = "RangeBar"
rangeBar.Size = UDim2.new(1, 0, 1, 0)
rangeBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
rangeBar.BorderSizePixel = 0
rangeBar.Parent = rangeSlider

local rangeBarCorner = Instance.new("UICorner")
rangeBarCorner.CornerRadius = UDim.new(0, 10)
rangeBarCorner.Parent = rangeBar

-- Target Info Label
local targetInfoLabel = Instance.new("TextLabel")
targetInfoLabel.Name = "TargetInfoLabel"
targetInfoLabel.Size = UDim2.new(1, 0, 0, 75)
targetInfoLabel.BackgroundColor3 = Color3.fromRGB(15, 25, 30)
targetInfoLabel.TextColor3 = Color3.fromRGB(100, 200, 150)
targetInfoLabel.TextSize = 11
targetInfoLabel.Font = Enum.Font.Gotham
targetInfoLabel.Text = "🎯 TARGET INFO\n\n📛 No Target\n💚 Health: -\n📏 Distance: -"
targetInfoLabel.TextWrapped = true
targetInfoLabel.BorderSizePixel = 0
targetInfoLabel.Parent = contentFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = targetInfoLabel

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

-- ===== AIMLOCK FUNCTIONS =====
local function findNearestTarget()
    local nearest = nil
    local nearestDistance = searchRadius
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") then
            local targetCharacter = obj.Parent
            local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
            
            if obj ~= humanoid and obj.Health > 0 and targetRootPart then
                local distance = (targetRootPart.Position - humanoidRootPart.Position).Magnitude
                
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearest = targetRootPart
                end
            end
        end
    end
    
    return nearest
end

local function updateTarget()
    if autoTarget then
        lockedTarget = findNearestTarget()
    end
    
    if lockedTarget and lockedTarget.Parent then
        local targetHumanoid = lockedTarget.Parent:FindFirstChildOfClass("Humanoid")
        if targetHumanoid and targetHumanoid.Health > 0 then
            local distance = (lockedTarget.Position - humanoidRootPart.Position).Magnitude
            targetDistance = distance
            targetInfoLabel.Text = "🎯 TARGET INFO\n\n📛 " .. lockedTarget.Parent.Name .. "\n💚 Health: " .. math.floor(targetHumanoid.Health) .. "/" .. math.floor(targetHumanoid.MaxHealth) .. "\n📏 Distance: " .. math.floor(distance) .. "m"
        else
            lockedTarget = nil
        end
    else
        lockedTarget = nil
        targetInfoLabel.Text = "🎯 TARGET INFO\n\n📛 No Target\n💚 Health: -\n📏 Distance: -"
    end
end

local function performAimlock()
    if aimlockActive and lockedTarget then
        local targetPosition = lockedTarget.Position
        
        -- Calculate direction to target (with head offset for better aiming)
        local targetHead = lockedTarget.Parent:FindFirstChild("Head")
        if targetHead then
            targetPosition = targetHead.Position
        end
        
        -- Get current camera direction
        local currentLookAt = camera.CFrame.LookVector
        local directionToTarget = (targetPosition - camera.CFrame.Position).Unit
        
        -- Smoothly interpolate camera direction
        local newLookVector = currentLookAt:Lerp(directionToTarget, aimSmoothness)
        camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + newLookVector)
    end
end

local function performPOV()
    if povActive and lockedTarget then
        -- Set camera to first-person view of locked target
        local targetHead = lockedTarget.Parent:FindFirstChild("Head")
        if targetHead then
            local targetNeck = lockedTarget.Parent:FindFirstChild("Neck")
            if targetNeck then
                camera.CFrame = targetHead.CFrame * CFrame.new(0, 0, -0.5)
            else
                camera.CFrame = targetHead.CFrame * CFrame.new(0, 0, -0.5)
            end
        end
    end
end

local function toggleAimlock()
    aimlockActive = not aimlockActive
    
    if aimlockActive then
        statusLabel.Text = "Status: 🟢 ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleAimlockButton.Text = "⏸ DISABLE AIMLOCK"
        toggleAimlockButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    else
        statusLabel.Text = "Status: ⚫ OFF"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 150)
        toggleAimlockButton.Text = "▶ ENABLE AIMLOCK"
        toggleAimlockButton.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    end
end

local function togglePOV()
    povActive = not povActive
    
    if povActive then
        togglePovButton.Text = "📷 DISABLE POV"
        togglePovButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    else
        togglePovButton.Text = "📷 ENABLE POV"
        togglePovButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    end
end

-- Button Connections
toggleAimlockButton.MouseButton1Click:Connect(function()
    toggleAimlock()
end)

togglePovButton.MouseButton1Click:Connect(function()
    togglePOV()
end)

hideButton.MouseButton1Click:Connect(function()
    contentFrame.Visible = not contentFrame.Visible
    titleBar.BackgroundColor3 = contentFrame.Visible and Color3.fromRGB(15, 25, 30) or Color3.fromRGB(20, 30, 35)
end)

exitButton.MouseButton1Click:Connect(function()
    if aimlockActive then toggleAimlock() end
    if povActive then togglePOV() end
    screenGui:Destroy()
    script:Destroy()
end)

-- Slider Interactions
local smoothnessSliding = false
local rangeSliding = false

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
        
        aimSmoothness = (relativeX / sliderSize) * 0.5
        smoothnessBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        smoothnessLabel.Text = "🔧 Smoothness: " .. string.format("%.2f", aimSmoothness)
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
    
    -- Update Target
    updateTarget()
    
    -- Perform Aimlock
    if aimlockActive then
        performAimlock()
    end
    
    -- Perform POV
    if povActive then
        performPOV()
    end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newCharacter)
    if aimlockActive then toggleAimlock() end
    if povActive then togglePOV() end
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    lockedTarget = nil
end)

print("✅ AIMLOCK POV SCRIPT LOADED - Author: 170F Team")
print("🎯 Enable aimlock to lock onto nearby targets!")
