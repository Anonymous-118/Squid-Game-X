-- Ultra Fast Downward Movement Script (Toggle Mode)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local DOWNWARD_SPEED = 500000  -- Very fast downward velocity
local ACTIVATION_KEY = Enum.KeyCode.H  -- Press H to toggle
local isActive = false
local connection

-- Create UI notification
local function updateNotification()
    local screenGui = localPlayer.PlayerGui:FindFirstChild("DownfallNotification")
    
    if screenGui then
        screenGui:Destroy()
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DownfallNotification"
    screenGui.Parent = localPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 350, 0, 70)
    textLabel.Position = UDim2.new(0.5, -175, 0, 20)
    textLabel.BackgroundColor3 = isActive and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    textLabel.BackgroundTransparency = 0.3
    textLabel.BorderSizePixel = 0
    textLabel.Text = isActive and "🔻 DOWNWARD BOOST ACTIVE (H to stop) 🔻\nContinuous fast descent" 
                              or "🔻 PRESS H FOR DOWNWARD BOOST 🔻\nToggle continuous fast descent"
    textLabel.TextColor3 = isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.Parent = screenGui
end

-- Apply downward movement in loop
local function startDownwardBoost()
    if connection then
        connection:Disconnect()
    end
    
    connection = RunService.Heartbeat:Connect(function()
        if isActive and humanoidRootPart then
            -- Apply constant downward velocity
            humanoidRootPart.Velocity = Vector3.new(
                humanoidRootPart.Velocity.X,  -- Keep X velocity
                -DOWNWARD_SPEED,              -- Strong downward force
                humanoidRootPart.Velocity.Z   -- Keep Z velocity
            )
        end
    end)
end

-- Toggle function
local function toggleDownwardBoost()
    isActive = not isActive
    
    if isActive then
        print("Downward boost ACTIVATED! Continuous fast descent.")
        startDownwardBoost()
    else
        print("Downward boost DEACTIVATED!")
        if connection then
            connection:Disconnect()
            connection = nil
        end
        -- Restore normal transparency when deactivated
        if humanoidRootPart then
            humanoidRootPart.Transparency = 0
        end
    end
    
    updateNotification()
end

-- Key press detection (toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == ACTIVATION_KEY then
        toggleDownwardBoost()
    end
end)

-- Handle character respawn
localPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    
    -- Reset state on respawn
    if isActive then
        isActive = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
        updateNotification()
    end
end)

-- Initial notification
updateNotification()

print("Downward movement script loaded! Press H to toggle continuous downward boost.")




-- Auto Baby Pickup System for Squid Game X (Safe Version)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Find the required services and events
local BabyAction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BabyAction")

-- Configuration
local AUTO_PICKUP_DELAY = 0.1 -- seconds before auto pickup

-- Create notification function
local function createNotification(message, color)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BabyNotification"
    screenGui.Parent = localPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 350, 0, 70)
    textLabel.Position = UDim2.new(0.5, -175, 0, 20)
    textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textLabel.BackgroundTransparency = 0.5
    textLabel.Text = message
    textLabel.TextColor3 = color
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.Parent = screenGui

    delay(5, function()
        screenGui:Destroy()
    end)
end

-- Function to automatically pick up a baby
local function autoPickupBaby(babyModel)
    if localPlayer:GetAttribute("IsGuard") then
        createNotification("âŒ Guards cannot pick up babies!", Color3.fromRGB(255, 50, 50))
        return
    end
    
    -- Wait a moment before auto-pickup
    wait(AUTO_PICKUP_DELAY)
    
    -- Check if baby still exists
    if not babyModel or not babyModel.Parent then
        return
    end
    
    -- Try to pick up the baby
    local success, result = pcall(function()
        BabyAction:FireServer()
        return true
    end)
    
    if success then
        createNotification("ðŸ‘¶ Baby picked up automatically!", Color3.fromRGB(0, 255, 0))
    else
        createNotification("âŒ Failed to pick up baby", Color3.fromRGB(255, 50, 50))
    end
end

-- Listen for baby drop events
BabyAction.OnClientEvent:Connect(function(action, ...)
    if action == "dropBaby" then
        local cframe, babyId = ...
        
        -- Wait for baby to be created
        wait(0.5)
        
        -- Find the baby in workspace
        local babyModel
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == "BabyPickup" and obj:FindFirstChild("Parts") then
                babyModel = obj
                break
            end
        end
        
        if babyModel then
            createNotification("ðŸ‘¶ Baby dropped! Auto-picking up...", Color3.fromRGB(255, 255, 0))
            
            -- Auto pickup the baby
            spawn(function()
                autoPickupBaby(babyModel)
            end)
        end
    end
end)

-- Also look for existing babies when script starts
delay(3, function()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "BabyPickup" and obj:FindFirstChild("Parts") then
            createNotification("ðŸ‘¶ Found existing baby! Auto-picking up...", Color3.fromRGB(255, 255, 0))
            
            spawn(function()
                autoPickupBaby(obj)
            end)
        end
    end
end)

-- Initial notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Baby Pickup",
    Text = "System activated! Babies will be picked up automatically.",
    Duration = 5
})

print("Auto Baby Pickup System loaded! Babies will be picked up automatically.")
















-- ===== NOTIFICATION SYSTEM =====
local function createNotificationSystem()
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    
    local notificationQueue = {}
    local isShowingNotification = false
    
    local function showNextNotification()
        if isShowingNotification or #notificationQueue == 0 then return end
        
        isShowingNotification = true
        local notificationData = table.remove(notificationQueue, 1)
        
        -- Create notification UI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ScriptNotification"
        screenGui.Parent = CoreGui
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 320, 0, 60)
        frame.Position = UDim2.new(0, 20, 1, -80)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        frame.BorderSizePixel = 0
        frame.BackgroundTransparency = 0.2
        frame.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -20, 1, -10)
        textLabel.Position = UDim2.new(0, 10, 0, 5)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = notificationData.message
        textLabel.TextColor3 = notificationData.color
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Parent = frame

        -- Animate in
        local tweenIn = TweenService:Create(
            frame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 20, 1, -150)}
        )
        tweenIn:Play()

        -- Wait for duration
        wait(notificationData.duration or 4)

        -- Animate out
        local tweenOut = TweenService:Create(
            frame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 20, 1, -80)}
        )
        tweenOut:Play()

        tweenOut.Completed:Connect(function()
            screenGui:Destroy()
            isShowingNotification = false
            showNextNotification()
        end)
    end
    
    local function notify(message, color, duration)
        table.insert(notificationQueue, {
            message = message,
            color = color or Color3.fromRGB(255, 255, 255),
            duration = duration or 4
        })
        showNextNotification()
    end
    
    return notify
end

-- Create notification function
local notify = createNotificationSystem()




-- ===== ULTRA OPTIMIZED BULK PROCESSING VERSION =====
-- Advanced Player Root Part Modifier with Batch Processing & Memory Optimization
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local TARGET_SIZE = Vector3.new(100000000, 100000000, 100000000)
local TARGET_TRANSPARENCY = 1
local BATCH_SIZE = 30 -- Process 5 players per batch
local BATCH_DELAY = 0.1 -- Delay between batches

-- Optimization variables
local playerBatchQueue = {}
local activeBatches = 0
local maxConcurrentBatches = 2
local processedPlayers = {} -- Track already processed players
local friendCache = {}
local notifiedFriends = {}

-- Cache references
local localPlayer = Players.LocalPlayer
local localPlayerUserId = localPlayer.UserId

-- Bulk notification system
local notificationQueue = {}
local lastNotificationTime = 0
local NOTIFICATION_COOLDOWN = 0.5

-- Optimized bulk notification function
local function bulkNotify(messages)
    for _, msgData in ipairs(messages) do
        local screenGui = game:GetService("CoreGui"):FindFirstChild("BulkNotifier") 
        if not screenGui then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "BulkNotifier"
            screenGui.Parent = game:GetService("CoreGui")
            screenGui.ResetOnSpawn = false
        end

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0, 350, 0, 70)
        textLabel.Position = UDim2.new(0.5, -175, 0.7 + (#notificationQueue * 0.08), 0)
        textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        textLabel.BackgroundTransparency = 0.3
        textLabel.Text = msgData.message
        textLabel.TextColor3 = msgData.color
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextWrapped = true
        textLabel.Parent = screenGui

        delay(msgData.duration or 3, function()
            if textLabel and textLabel.Parent then
                textLabel:Destroy()
            end
        end)
    end
end

-- Batch processing function
local function processPlayerBatch(batch)
    for _, playerData in ipairs(batch) do
        if not playerData.player or playerData.player == localPlayer then continue end
        if friendCache[playerData.player] then continue end
        
        local character = playerData.player.Character
        if not character then continue end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end
        
        -- Skip if already processed with correct values
        if humanoidRootPart.Size == TARGET_SIZE and humanoidRootPart.Transparency == TARGET_TRANSPARENCY then
            continue
        end
        
        -- Bulk modification
        humanoidRootPart.Size = TARGET_SIZE
        humanoidRootPart.Transparency = TARGET_TRANSPARENCY
        humanoidRootPart.CanCollide = false
        
        processedPlayers[playerData.player] = os.time()
    end
end

-- Create batches from player list
local function createBatches(players)
    local batches = {}
    for i = 1, #players, BATCH_SIZE do
        local batch = {}
        for j = i, math.min(i + BATCH_SIZE - 1, #players) do
            table.insert(batch, {player = players[j]})
        end
        table.insert(batches, batch)
    end
    return batches
end

-- Process all batches with controlled concurrency
local function processAllBatches()
    if activeBatches >= maxConcurrentBatches then return end
    
    local playersToProcess = {}
    for player, _ in pairs(playerBatchQueue) do
        if player and player.Parent then
            table.insert(playersToProcess, player)
        end
    end
    
    if #playersToProcess == 0 then return end
    
    local batches = createBatches(playersToProcess)
    activeBatches = #batches
    
    for i, batch in ipairs(batches) do
        spawn(function()
            processPlayerBatch(batch)
            wait(BATCH_DELAY * i) -- Stagger batches
            activeBatches = activeBatches - 1
        end)
    end
    
    -- Clear queue after processing
    playerBatchQueue = {}
end

-- Add players to batch queue
local function queuePlayersForBatchProcessing(players)
    for _, player in ipairs(players) do
        if player and player ~= localPlayer and not friendCache[player] then
            playerBatchQueue[player] = true
        end
    end
end

-- Bulk friend detection
local function bulkDetectFriends()
    local allPlayers = Players:GetPlayers()
    local friendList = {}
    
    for _, player in ipairs(allPlayers) do
        if player ~= localPlayer then
            local success, isFriend = pcall(function()
                return player:IsFriendsWith(localPlayerUserId)
            end)
            
            if success and isFriend then
                friendCache[player] = true
                table.insert(friendList, player)
                
                if not notifiedFriends[player] then
                    table.insert(notificationQueue, {
                        message = "Friend detected: " .. player.Name,
                        color = Color3.fromRGB(0, 255, 255),
                        duration = 2
                    })
                    notifiedFriends[player] = true
                end
            else
                friendCache[player] = nil
                notifiedFriends[player] = nil
            end
        end
    end
    
    return friendList
end

-- Bulk character check and queue
local function bulkCharacterCheck()
    local allPlayers = Players:GetPlayers()
    local playersToProcess = {}
    
    for _, player in ipairs(allPlayers) do
        if player ~= localPlayer and not friendCache[player] and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart and (humanoidRootPart.Size ~= TARGET_SIZE or humanoidRootPart.Transparency ~= TARGET_TRANSPARENCY) then
                table.insert(playersToProcess, player)
            end
        end
    end
    
    if #playersToProcess > 0 then
        queuePlayersForBatchProcessing(playersToProcess)
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.N then
        protectFriends = not protectFriends
        
        table.insert(notificationQueue, {
            message = protectFriends and "FRIEND PROTECTION: ON" or "FRIEND PROTECTION: OFF",
            color = protectFriends and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50),
            duration = 3
        })
        
        if not protectFriends then
            friendCache = {}
            notifiedFriends = {}
        else
            bulkDetectFriends()
        end
    end
end)

-- Optimized initialization
local function bulkInitialize()
    -- Initial friend detection
    bulkDetectFriends()
    
    -- Queue all existing players
    local allPlayers = Players:GetPlayers()
    queuePlayersForBatchProcessing(allPlayers)
    
    -- Bulk notification
    table.insert(notificationQueue, {
        message = "Bulk Hitbox Expander Loaded!",
        color = Color3.fromRGB(0, 255, 255),
        duration = 3
    })
    table.insert(notificationQueue, {
        message = "Friend Protection: ON - Press N to toggle",
        color = Color3.fromRGB(255, 165, 0),
        duration = 4
    })
end

-- Event handlers with bulk processing
Players.PlayerAdded:Connect(function(player)
    spawn(function()
        wait(0.5) -- Small delay for character load
        bulkDetectFriends()
        queuePlayersForBatchProcessing({player})
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    friendCache[player] = nil
    notifiedFriends[player] = nil
    processedPlayers[player] = nil
    playerBatchQueue[player] = nil
end)

-- Character added events with bulk handling
local characterAddedConnections = {}
local function setupPlayerCharacterEvents(player)
    if characterAddedConnections[player] then
        characterAddedConnections[player]:Disconnect()
    end
    
    characterAddedConnections[player] = player.CharacterAdded:Connect(function(character)
        spawn(function()
            wait(0.3) -- Wait for character to fully load
            if not friendCache[player] then
                queuePlayersForBatchProcessing({player})
            end
        end)
    end)
end

-- Setup events for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        setupPlayerCharacterEvents(player)
    end
end

-- Main processing loop
RunService.Heartbeat:Connect(function()
    local currentTime = os.time()
    
    -- Process notifications in bulk
    if #notificationQueue > 0 and currentTime - lastNotificationTime > NOTIFICATION_COOLDOWN then
        bulkNotify(notificationQueue)
        notificationQueue = {}
        lastNotificationTime = currentTime
    end
    
    -- Process batches
    processAllBatches()
end)

-- Maintenance loop (runs less frequently)
local lastMaintenanceCheck = 0
RunService.Heartbeat:Connect(function()
    local currentTime = os.time()
    if currentTime - lastMaintenanceCheck >= 3 then -- Every 3 seconds
        lastMaintenanceCheck = currentTime
        
        -- Bulk operations
        bulkDetectFriends()
        bulkCharacterCheck()
        
        -- Cleanup old processed players cache (prevent memory leak)
        for player, timestamp in pairs(processedPlayers) do
            if currentTime - timestamp > 60 then -- Remove after 60 seconds
                processedPlayers[player] = nil
            end
        end
    end
end)

-- Initialize with delay
delay(1, function()
    bulkInitialize()
    print("Ultra optimized bulk processing Hitbox Expander loaded!")
    print("Batch Size: " .. BATCH_SIZE)
    print("Max Concurrent Batches: " .. maxConcurrentBatches)
end)









-- Frontman Highlighter Script
-- This script highlights the Frontman player with a yellow glow

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Function to create highlight effect
local function createFrontmanHighlight(player)
    if not player.Character then
        return nil
    end
    
    -- Create highlight object
    local highlight = Instance.new("Highlight")
    highlight.Name = "FrontmanHighlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)  -- Yellow
    highlight.OutlineColor = Color3.fromRGB(255, 215, 0) -- Gold outline
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    
    return highlight
end

-- Function to remove highlight
local function removeFrontmanHighlight(player)
    if player.Character then
        local existingHighlight = player.Character:FindFirstChild("FrontmanHighlight")
        if existingHighlight then
            existingHighlight:Destroy()
        end
    end
end

-- Function to check for Frontman and apply highlight
local function checkAndHighlightFrontman()
    for _, player in ipairs(Players:GetPlayers()) do
        -- Remove any existing highlights first
        removeFrontmanHighlight(player)
        
        -- Check if this player is the Frontman
        if player:GetAttribute("IsFrontman") then
            -- Add highlight to Frontman
            local highlight = createFrontmanHighlight(player)
            
            -- If character doesn't exist yet, wait for it
            if not highlight then
                player.CharacterAdded:Connect(function()
                    wait(1) -- Wait for character to fully load
                    if player:GetAttribute("IsFrontman") then
                        createFrontmanHighlight(player)
                    end
                end)
            end
        end
    end
end

-- Listen for attribute changes
local function setupFrontmanTracking()
    -- Initial check
    checkAndHighlightFrontman()
    
    -- Listen for changes to IsFrontman attribute on all players
    for _, player in ipairs(Players:GetPlayers()) do
        player:GetAttributeChangedSignal("IsFrontman"):Connect(function()
            checkAndHighlightFrontman()
        end)
    end
    
    -- Listen for new players
    Players.PlayerAdded:Connect(function(player)
        player:GetAttributeChangedSignal("IsFrontman"):Connect(function()
            checkAndHighlightFrontman()
        end)
    end)
    
    -- Listen for character changes
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            -- Wait a moment for attributes to load
            wait(0.5)
            if player:GetAttribute("IsFrontman") then
                createFrontmanHighlight(player)
            end
        end)
    end)
end

-- Start tracking the Frontman
setupFrontmanTracking()

print("Frontman highlighter script loaded. The Frontman will be highlighted in yellow.")


