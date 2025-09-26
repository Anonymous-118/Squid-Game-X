local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Rayfield Example Window",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Anonymous Script",
   LoadingSubtitle = "by Anonymous_118",
   ShowText = "Anonymous", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },










   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }


})


local Tab = Window:CreateTab("Main", 4483362458) -- Title, Image
local Section = Tab:CreateSection("Main")


local Toggle = Tab:CreateToggle({
   Name = "Baby Pickup ",
   CurrentValue = false,
   Flag = "babypickup",
   Callback = function(Value)
       -- Auto Baby Pickup System for Squid Game X (Safe Version)
       local ReplicatedStorage = game:GetService("ReplicatedStorage")
       local Players = game:GetService("Players")
       local localPlayer = Players.LocalPlayer

       -- Store the connection and enabled state
       local babyEventConnection = nil
       local autoPickupEnabled = Value

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
           -- Check if auto pickup is still enabled
           if not autoPickupEnabled then
               return
           end
           
           if localPlayer:GetAttribute("IsGuard") then
               createNotification("❌ Guards cannot pick up babies!", Color3.fromRGB(255, 50, 50))
               return
           end
           
           -- Wait a moment before auto-pickup
           wait(AUTO_PICKUP_DELAY)
           
           -- Check if auto pickup is still enabled and baby still exists
           if not autoPickupEnabled or not babyModel or not babyModel.Parent then
               return
           end
           
           -- Try to pick up the baby
           local success, result = pcall(function()
               local BabyAction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BabyAction")
               BabyAction:FireServer()
               return true
           end)
           
           if success then
               createNotification("👶 Baby picked up automatically!", Color3.fromRGB(0, 255, 0))
           else
               createNotification("❌ Failed to pick up baby", Color3.fromRGB(255, 50, 50))
           end
       end

       -- Function to setup baby pickup listener
       local function setupBabyPickup()
           -- Find the required remote event
           local BabyAction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BabyAction")
           
           -- Listen for baby drop events
           babyEventConnection = BabyAction.OnClientEvent:Connect(function(action, ...)
               if not autoPickupEnabled then return end
               
               if action == "dropBaby" then
                   local cframe, babyId = ...
                   
                   -- Wait for baby to be created
                   wait(0.5)
                   
                   -- Check if still enabled
                   if not autoPickupEnabled then return end
                   
                   -- Find the baby in workspace
                   local babyModel
                   for _, obj in ipairs(workspace:GetChildren()) do
                       if obj.Name == "BabyPickup" and obj:FindFirstChild("Parts") then
                           babyModel = obj
                           break
                       end
                   end
                   
                   if babyModel then
                       createNotification("👶 Baby dropped! Auto-picking up...", Color3.fromRGB(255, 255, 0))
                       
                       -- Auto pickup the baby
                       spawn(function()
                           autoPickupBaby(babyModel)
                       end)
                   end
               end
           end)

           -- Also look for existing babies when enabled
           delay(3, function()
               if not autoPickupEnabled then return end
               
               for _, obj in ipairs(workspace:GetChildren()) do
                   if obj.Name == "BabyPickup" and obj:FindFirstChild("Parts") then
                       createNotification("👶 Found existing baby! Auto-picking up...", Color3.fromRGB(255, 255, 0))
                       
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
       end

       -- Function to cleanup and disable baby pickup
       local function disableBabyPickup()
           autoPickupEnabled = false
           
           -- Disconnect the event listener
           if babyEventConnection then
               babyEventConnection:Disconnect()
               babyEventConnection = nil
           end
           
           -- Disable notification
           game:GetService("StarterGui"):SetCore("SendNotification", {
               Title = "Auto Baby Pickup",
               Text = "System deactivated! Auto pickup disabled.",
               Duration = 5
           })
           
           print("Auto Baby Pickup System disabled.")
       end

       -- Handle toggle state
       if Value then
           -- Toggle is ON - enable auto baby pickup
           autoPickupEnabled = true
           setupBabyPickup()
       else
           -- Toggle is OFF - disable auto baby pickup
           disableBabyPickup()
       end
   end,
})



local Toggle = Tab:CreateToggle({
   Name = "Frontman Highlighter",
   CurrentValue = false,
   Flag = "highlighter",
   Callback = function(Value)
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

       -- Function to remove all highlights from all players
       local function removeAllHighlights()
           for _, player in ipairs(Players:GetPlayers()) do
               removeFrontmanHighlight(player)
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

       -- Table to store connections so we can disconnect them later
       local connections = {}

       -- Listen for attribute changes
       local function setupFrontmanTracking()
           -- Initial check
           checkAndHighlightFrontman()
           
           -- Listen for changes to IsFrontman attribute on all players
           for _, player in ipairs(Players:GetPlayers()) do
               local connection = player:GetAttributeChangedSignal("IsFrontman"):Connect(function()
                   checkAndHighlightFrontman()
               end)
               table.insert(connections, connection)
           end
           
           -- Listen for new players
           local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
               local attributeConnection = player:GetAttributeChangedSignal("IsFrontman"):Connect(function()
                   checkAndHighlightFrontman()
               end)
               table.insert(connections, attributeConnection)
               
               local characterConnection = player.CharacterAdded:Connect(function(character)
                   -- Wait a moment for attributes to load
                   wait(0.5)
                   if player:GetAttribute("IsFrontman") then
                       createFrontmanHighlight(player)
                   end
               end)
               table.insert(connections, characterConnection)
           end)
           table.insert(connections, playerAddedConnection)
           
           -- Listen for character changes on existing players
           for _, player in ipairs(Players:GetPlayers()) do
               local characterConnection = player.CharacterAdded:Connect(function(character)
                   wait(0.5)
                   if player:GetAttribute("IsFrontman") then
                       createFrontmanHighlight(player)
                   end
               end)
               table.insert(connections, characterConnection)
           end
       end

       if Value then
           -- Toggle is ON - start tracking the Frontman
           setupFrontmanTracking()
       else
           -- Toggle is OFF - remove all highlights and disconnect events
           removeAllHighlights()
           
           -- Disconnect all connections
           for _, connection in ipairs(connections) do
               connection:Disconnect()
           end
           connections = {} -- Clear the connections table
       end
   end,
})

local Divider = Tab:CreateDivider()

-- ===== ULTRA OPTIMIZED BULK PROCESSING VERSION =====
-- Advanced Player Root Part Modifier with Batch Processing & Memory Optimization
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local TARGET_SIZE = Vector3.new(100000000, 100000000, 100000000)
local TARGET_TRANSPARENCY = 1
local BATCH_SIZE = 10
local BATCH_DELAY = 0.1

-- Toggle variables
local killAllEnabled = false
local friendProtectionEnabled = true

-- Optimization variables
local playerBatchQueue = {}
local activeBatches = 0
local maxConcurrentBatches = 2
local processedPlayers = {}
local friendCache = {}

-- Cache references
local localPlayer = Players.LocalPlayer
local localPlayerUserId = localPlayer.UserId

-- Batch processing function
local function processPlayerBatch(batch)
    for _, playerData in ipairs(batch) do
        if not playerData.player or playerData.player == localPlayer then continue end
        if friendProtectionEnabled and friendCache[playerData.player] then continue end
        
        local character = playerData.player.Character
        if not character then continue end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end
        
        if humanoidRootPart.Size == TARGET_SIZE and humanoidRootPart.Transparency == TARGET_TRANSPARENCY then
            continue
        end
        
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
    if not killAllEnabled then return end
    
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
            wait(BATCH_DELAY * i)
            activeBatches = activeBatches - 1
        end)
    end
    
    playerBatchQueue = {}
end

-- Add players to batch queue
local function queuePlayersForBatchProcessing(players)
    for _, player in ipairs(players) do
        if player and player ~= localPlayer and (not friendProtectionEnabled or not friendCache[player]) then
            playerBatchQueue[player] = true
        end
    end
end

-- Bulk friend detection
local function bulkDetectFriends()
    local allPlayers = Players:GetPlayers()
    
    for _, player in ipairs(allPlayers) do
        if player ~= localPlayer then
            local success, isFriend = pcall(function()
                return player:IsFriendsWith(localPlayerUserId)
            end)
            
            if success and isFriend then
                friendCache[player] = true
            else
                friendCache[player] = nil
            end
        end
    end
end

-- Bulk character check and queue
local function bulkCharacterCheck()
    if not killAllEnabled then return end
    
    local allPlayers = Players:GetPlayers()
    local playersToProcess = {}
    
    for _, player in ipairs(allPlayers) do
        if player ~= localPlayer and (not friendProtectionEnabled or not friendCache[player]) and player.Character then
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

-- Optimized initialization
local function bulkInitialize()
    bulkDetectFriends()
    
    if killAllEnabled then
        local allPlayers = Players:GetPlayers()
        queuePlayersForBatchProcessing(allPlayers)
    end
end

-- Event handlers with bulk processing
Players.PlayerAdded:Connect(function(player)
    spawn(function()
        wait(0.5)
        bulkDetectFriends()
        if killAllEnabled then
            queuePlayersForBatchProcessing({player})
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    friendCache[player] = nil
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
            wait(0.3)
            if killAllEnabled and (not friendProtectionEnabled or not friendCache[player]) then
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
    if killAllEnabled then
        processAllBatches()
    end
end)

-- Maintenance loop (runs less frequently)
local lastMaintenanceCheck = 0
RunService.Heartbeat:Connect(function()
    local currentTime = os.time()
    if currentTime - lastMaintenanceCheck >= 3 then
        lastMaintenanceCheck = currentTime
        
        bulkDetectFriends()
        if killAllEnabled then
            bulkCharacterCheck()
        end
        
        for player, timestamp in pairs(processedPlayers) do
            if currentTime - timestamp > 60 then
                processedPlayers[player] = nil
            end
        end
    end
end)

-- Initialize with delay
delay(1, function()
    bulkInitialize()
    print("Ultra optimized bulk processing Hitbox Expander loaded!")
end)

-- Rayfield UI Toggles
local KillAllToggle = Tab:CreateToggle({
   Name = "Kill All Players",
   CurrentValue = killAllEnabled,
   Flag = "KillAllToggle",
   Callback = function(Value)
       killAllEnabled = Value
       if killAllEnabled then
           local allPlayers = Players:GetPlayers()
           queuePlayersForBatchProcessing(allPlayers)
       end
   end,
})

local FriendProtectionToggle = Tab:CreateToggle({
   Name = "Friend Protection",
   CurrentValue = friendProtectionEnabled,
   Flag = "FriendProtectionToggle",
   Callback = function(Value)
       friendProtectionEnabled = Value
       if killAllEnabled then
           local allPlayers = Players:GetPlayers()
           queuePlayersForBatchProcessing(allPlayers)
       end
   end,
})




local Divider = Tab:CreateDivider()



local Toggle = Tab:CreateToggle({
   Name = "Be Immortal",
   CurrentValue = false,
   Flag = "downwardBoost",
   Callback = function(Value)
       -- Ultra Fast Downward Movement Script (Toggle Mode)
       local Players = game:GetService("Players")
       local RunService = game:GetService("RunService")

       local localPlayer = Players.LocalPlayer
       local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
       local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

       -- Configuration
       local DOWNWARD_SPEED = 500000  -- Very fast downward velocity
       local isActive = Value
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
           textLabel.Text = isActive and "🔻 DOWNWARD BOOST ACTIVE 🔻\nContinuous fast descent" 
                                         or "🔻 DOWNWARD BOOST INACTIVE 🔻"
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
               if isActive and humanoidRootPart and humanoidRootPart.Parent then
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
       local function toggleDownwardBoost(value)
           isActive = value
           
           if isActive then
               print("Downward boost ACTIVATED! Continuous fast descent.")
               startDownwardBoost()
           else
               print("Downward boost DEACTIVATED!")
               if connection then
                   connection:Disconnect()
                   connection = nil
               end
           end
           
           updateNotification()
       end

       -- Handle character respawn
       localPlayer.CharacterAdded:Connect(function(newCharacter)
           character = newCharacter
           humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
           
           -- Restart the downward boost if it was active before respawn
           if isActive then
               wait(1) -- Wait for character to fully load
               startDownwardBoost()
           end
       end)

       -- Initial setup based on toggle value
       toggleDownwardBoost(Value)
   end,
})
