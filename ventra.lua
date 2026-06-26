-- Roblox Stick to Player Script with Minimalist UI & Resizable
-- Author: 170F Team
-- Features: Stick to Player, Minimalist UI, Draggable, Resizable, Rainbow Text, Settings

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Stick to Player Variables
local stickActive = false
local selectedTarget = nil
local selectedTargetCharacter = nil
local stickDistance = 5

-- UI Configuration
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StickToPlayerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (Minimalist)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 320)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Drag Enabled
mainFrame.Draggable = false
mainFrame.Active = true

-- Add Stroke (Minimalist)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 100)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
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

-- Title Bar (Minimalist)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 25, 15)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0, 8, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(0, 200, 100)
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.Text = "🔗 STICK"
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Author Text
local authorText = Instance.new("TextLabel")
authorText.Name = "AuthorText"
authorText.Size = UDim2.new(1, 0, 0.5, 0)
authorText.Position = UDim2.new(0, 8, 0.5, 0)
authorText.BackgroundTransparency = 1
authorText.TextColor3 = Color3.fromRGB(100, 150, 120)
authorText.TextSize = 8
authorText.Font = Enum.Font.Gotham
authorText.Text = "170F Team"
authorText.TextXAlignment = Enum.TextXAlignment.Left
authorText.Parent = titleBar

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 26, 1, 0)
minimizeButton.Position = UDim2.new(1, -65, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 100, 70)
minimizeButton.TextColor3 = Color3.fromRGB(200, 255, 200)
minimizeButton.TextSize = 14
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "−"
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeButton

-- Resize Button
local resizeButton = Instance.new("TextButton")
resizeButton.Name = "ResizeButton"
resizeButton.Size = UDim2.new(0, 26, 1, 0)
resizeButton.Position = UDim2.new(1, -35, 0, 0)
resizeButton.BackgroundColor3 = Color3.fromRGB(50, 100, 70)
resizeButton.TextColor3 = Color3.fromRGB(200, 255, 200)
resizeButton.TextSize = 12
resizeButton.Font = Enum.Font.GothamBold
resizeButton.Text = "□"
resizeButton.BorderSizePixel = 0
resizeButton.Parent = titleBar

local resizeCorner = Instance.new("UICorner")
resizeCorner.CornerRadius = UDim.new(0, 6)
resizeCorner.Parent = resizeButton

-- Content Frame (Scrollable, Minimalist)
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 4
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = mainFrame

-- Padding (Minimalist)
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = contentFrame

-- List Layout
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Parent = contentFrame

-- Status Label (Minimalist)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 28)
statusLabel.BackgroundColor3 = Color3.fromRGB(10, 25, 15)
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 150)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "⚫ Waiting"
statusLabel.BorderSizePixel = 0
statusLabel.Parent = contentFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

-- Toggle Stick Button (Minimalist)
local toggleStickButton = Instance.new("TextButton")
toggleStickButton.Name = "ToggleStickButton"
toggleStickButton.Size = UDim2.new(1, 0, 0, 40)
toggleStickButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
toggleStickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleStickButton.TextSize = 13
toggleStickButton.Font = Enum.Font.GothamBold
toggleStickButton.Text = "▶ START"
toggleStickButton.BorderSizePixel = 0
toggleStickButton.Parent = contentFrame

local stickCorner = Instance.new("UICorner")
stickCorner.CornerRadius = UDim.new(0, 6)
stickCorner.Parent = toggleStickButton

-- Distance Label (Minimalist)
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Name = "DistanceLabel"
distanceLabel.Size = UDim2.new(1, 0, 0, 22)
distanceLabel.BackgroundTransparency = 1
distanceLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
distanceLabel.TextSize = 11
distanceLabel.Font = Enum.Font.GothamBold
distanceLabel.Text = "📏 5m"
distanceLabel.BorderSizePixel = 0
distanceLabel.Parent = contentFrame

-- Distance Slider (Minimalist)
local distanceSlider = Instance.new("Frame")
distanceSlider.Name = "DistanceSlider"
distanceSlider.Size = UDim2.new(1, 0, 0, 18)
distanceSlider.BackgroundColor3 = Color3.fromRGB(10, 25, 15)
distanceSlider.BorderSizePixel = 0
distanceSlider.Parent = contentFrame

local distanceCorner = Instance.new("UICorner")
distanceCorner.CornerRadius = UDim.new(0, 8)
distanceCorner.Parent = distanceSlider

local distanceBar = Instance.new("Frame")
distanceBar.Name = "DistanceBar"
distanceBar.Size = UDim2.new(0.25, 0, 1, 0)
distanceBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
distanceBar.BorderSizePixel = 0
distanceBar.Parent = distanceSlider

local distanceBarCorner = Instance.new("UICorner")
distanceBarCorner.CornerRadius = UDim.new(0, 8)
distanceBarCorner.Parent = distanceBar

-- Players Label (Minimalist)
local playersLabel = Instance.new("TextLabel")
playersLabel.Name = "PlayersLabel"
playersLabel.Size = UDim2.new(1, 0, 0, 22)
playersLabel.BackgroundTransparency = 1
playersLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
playersLabel.TextSize = 11
playersLabel.Font = Enum.Font.GothamBold
playersLabel.Text = "👥 PLAYERS"
playersLabel.BorderSizePixel = 0
playersLabel.Parent = contentFrame

-- Players Container
local playersContainer = Instance.new("Frame")
playersContainer.Name = "PlayersContainer"
playersContainer.Size = UDim2.new(1, 0, 0, 120)
playersContainer.BackgroundColor3 = Color3.fromRGB(10, 25, 15)
playersContainer.BorderSizePixel = 0
playersContainer.Parent = contentFrame

local playersCorner = Instance.new("UICorner")
playersCorner.CornerRadius = UDim.new(0, 6)
playersCorner.Parent = playersContainer

-- Players List
local playersList = Instance.new("ScrollingFrame")
playersList.Name = "PlayersList"
playersList.Size = UDim2.new(1, 0, 1, 0)
playersList.BackgroundTransparency = 1
playersList.ScrollBarThickness = 3
playersList.CanvasSize = UDim2.new(0, 0, 0, 0)
playersList.Parent = playersContainer

local playersListLayout = Instance.new("UIListLayout")
playersListLayout.Padding = UDim.new(0, 4)
playersListLayout.FillDirection = Enum.FillDirection.Vertical
playersListLayout.Parent = playersList

local playersPadding = Instance.new("UIPadding")
playersPadding.PaddingLeft = UDim.new(0, 6)
playersPadding.PaddingRight = UDim.new(0, 6)
playersPadding.PaddingTop = UDim.new(0, 6)
playersPadding.PaddingBottom = UDim.new(0, 6)
playersPadding.Parent = playersList

-- Target Info Label (Minimalist)
local targetInfoLabel = Instance.new("TextLabel")
targetInfoLabel.Name = "TargetInfoLabel"
targetInfoLabel.Size = UDim2.new(1, 0, 0, 60)
targetInfoLabel.BackgroundColor3 = Color3.fromRGB(10, 25, 15)
targetInfoLabel.TextColor3 = Color3.fromRGB(100, 200, 150)
targetInfoLabel.TextSize = 10
targetInfoLabel.Font = Enum.Font.Gotham
targetInfoLabel.Text = "None"
targetInfoLabel.TextWrapped = true
targetInfoLabel.BorderSizePixel = 0
targetInfoLabel.Parent = contentFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = targetInfoLabel

-- Update canvas size
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end)

-- ===== RESIZE SYSTEM =====
local isLargeMode = false
local smallSize = UDim2.new(0, 280, 0, 320)
local largeSize = UDim2.new(0, 420, 0, 500)

resizeButton.MouseButton1Click:Connect(function()
    isLargeMode = not isLargeMode
    
    if isLargeMode then
        mainFrame:TweenSize(largeSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true)
        resizeButton.Text = "◻"
    else
        mainFrame:TweenSize(smallSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true)
        resizeButton.Text = "□"
    end
end)

-- ===== MINIMIZE SYSTEM =====
local isMinimized = false

minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, mainFrame.AbsoluteSize.X, 0, 35)
        minimizeButton.Text = "+"
    else
        contentFrame.Visible = true
        mainFrame:TweenSize(isLargeMode and largeSize or smallSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3, true)
        minimizeButton.Text = "−"
    end
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

-- ===== STICK TO PLAYER FUNCTIONS =====
local function updatePlayersList()
    for _, button in pairs(playersList:GetChildren()) do
        if button:IsA("TextButton") then
            button:Destroy()
        end
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local targetChar = targetPlayer.Character
            if targetChar then
                local targetRootPart = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                
                if targetRootPart and targetHumanoid and targetHumanoid.Health > 0 then
                    local playerButton = Instance.new("TextButton")
                    playerButton.Name = targetPlayer.Name .. "Button"
                    playerButton.Size = UDim2.new(1, 0, 0, 28)
                    playerButton.BackgroundColor3 = selectedTarget == targetPlayer and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(20, 40, 30)
                    playerButton.TextColor3 = Color3.fromRGB(200, 255, 200)
                    playerButton.TextSize = 11
                    playerButton.Font = Enum.Font.Gotham
                    playerButton.Text = "👤 " .. targetPlayer.Name .. " [" .. math.floor(targetHumanoid.Health) .. "]"
                    playerButton.BorderSizePixel = 0
                    playerButton.Parent = playersList
                    
                    local buttonCorner = Instance.new("UICorner")
                    buttonCorner.CornerRadius = UDim.new(0, 5)
                    buttonCorner.Parent = playerButton
                    
                    playerButton.MouseButton1Click:Connect(function()
                        selectedTarget = targetPlayer
                        selectedTargetCharacter = targetChar
                        updatePlayersList()
                    end)
                end
            end
        end
    end
    
    playersListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        playersList.CanvasSize = UDim2.new(0, 0, 0, playersListLayout.AbsoluteContentSize.Y + 12)
    end)
end

local function performStick()
    if stickActive and selectedTarget and selectedTargetCharacter then
        local targetRootPart = selectedTargetCharacter:FindFirstChild("HumanoidRootPart")
        
        if targetRootPart then
            local targetPos = targetRootPart.Position + (targetRootPart.CFrame.LookVector * -stickDistance)
            humanoidRootPart.CFrame = CFrame.new(targetPos)
        end
    end
end

local function updateTargetInfo()
    if selectedTarget and selectedTargetCharacter then
        local targetRootPart = selectedTargetCharacter:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = selectedTargetCharacter:FindFirstChildOfClass("Humanoid")
        
        if targetRootPart and targetHumanoid and targetHumanoid.Health > 0 then
            local distance = (targetRootPart.Position - humanoidRootPart.Position).Magnitude
            targetInfoLabel.Text = "📛 " .. selectedTarget.Name .. "\n📍 " .. math.floor(distance) .. "m\n💚 " .. math.floor(targetHumanoid.Health) .. "/" .. math.floor(targetHumanoid.MaxHealth)
        else
            selectedTarget = nil
            selectedTargetCharacter = nil
            targetInfoLabel.Text = "None"
        end
    else
        targetInfoLabel.Text = "None"
    end
end

local function toggleStick()
    stickActive = not stickActive
    
    if stickActive then
        if not selectedTarget then
            stickActive = false
            print("❌ Please select a target first!")
            return
        end
        
        statusLabel.Text = "🟢 Sticking"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleStickButton.Text = "⏹ STOP"
        toggleStickButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    else
        statusLabel.Text = "⚫ Waiting"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 150)
        toggleStickButton.Text = "▶ START"
        toggleStickButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    end
end

-- Button Connections
toggleStickButton.MouseButton1Click:Connect(function()
    toggleStick()
end)

-- Slider Interactions
local distanceSliding = false

distanceSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        distanceSliding = true
    end
end)

distanceSlider.InputEnded:Connect(function()
    distanceSliding = false
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Rainbow Title Animation
    colorIndex = colorIndex + 1
    if colorIndex > #rainbowColors then colorIndex = 1 end
    titleText.TextColor3 = rainbowColors[colorIndex]
    
    -- Distance Slider
    if distanceSliding then
        local mouseLocation
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouseLocation = UserInputService:GetMouseLocation()
        else
            mouseLocation = Vector2.new(distanceSlider.AbsolutePosition.X + distanceSlider.AbsoluteSize.X / 2, 0)
        end
        
        local sliderPos = distanceSlider.AbsolutePosition.X
        local sliderSize = distanceSlider.AbsoluteSize.X
        local relativeX = math.clamp(mouseLocation.X - sliderPos, 0, sliderSize)
        
        stickDistance = (relativeX / sliderSize) * 20
        distanceBar.Size = UDim2.new(relativeX / sliderSize, 0, 1, 0)
        distanceLabel.Text = "📏 " .. math.floor(stickDistance) .. "m"
    end
    
    -- Update players list
    updatePlayersList()
    
    -- Update target info
    updateTargetInfo()
    
    -- Perform stick
    if stickActive then
        performStick()
    end
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(newCharacter)
    if stickActive then toggleStick() end
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    selectedTarget = nil
    selectedTargetCharacter = nil
end)

print("✅ STICK TO PLAYER SCRIPT LOADED - Author: 170F Team")
print("🔗 Select a player and click START to stick to them!")
