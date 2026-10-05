-- KLKOO Studio Admin Panel - Server
-- Place this Script in ServerScriptService in your own Roblox experience.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- For a group-owned experience, add your Roblox UserId(s) here.
-- Personal experiences automatically authorize only the user who owns the experience.
local ADMIN_USER_IDS = {}

local SETTINGS = {
    WalkSpeed = 32,
    JumpPower = 100,
}

local ROOT_NAME = "KLKOO_AdminPanel"
local root = ReplicatedStorage:FindFirstChild(ROOT_NAME)
if not root then
    root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = ReplicatedStorage
end

local function getOrCreate(className, name)
    local object = root:FindFirstChild(name)
    if object and not object:IsA(className) then
        object:Destroy()
        object = nil
    end
    if not object then
        object = Instance.new(className)
        object.Name = name
        object.Parent = root
    end
    return object
end

local checkAccess = getOrCreate("RemoteFunction", "CheckAccess")
local setFeature = getOrCreate("RemoteEvent", "SetFeature")

local states = {}
local validFeatures = {
    Fly = true,
    ESP = true,
    Speed = true,
    HighJump = true,
}

local function isAdmin(player)
    if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
        return true
    end
    return table.find(ADMIN_USER_IDS, player.UserId) ~= nil
end

local function getState(player)
    local state = states[player]
    if not state then
        state = {
            Fly = false,
            ESP = false,
            Speed = false,
            HighJump = false,
        }
        states[player] = state
    end
    return state
end

local function getHumanoid(player)
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function captureDefaults(state, humanoid)
    if state.BoundHumanoid == humanoid then
        return
    end
    state.BoundHumanoid = humanoid
    state.OriginalWalkSpeed = humanoid.WalkSpeed
    state.OriginalJumpPower = humanoid.JumpPower
    state.OriginalJumpHeight = humanoid.JumpHeight
    state.OriginalUseJumpPower = humanoid.UseJumpPower
end

local function bindCharacter(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then
        return
    end

    local state = getState(player)
    captureDefaults(state, humanoid)

    if state.Speed then
        humanoid.WalkSpeed = SETTINGS.WalkSpeed
    end
    if state.HighJump then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = SETTINGS.JumpPower
    end
end

local function onPlayerAdded(player)
    getState(player)
    player.CharacterAdded:Connect(function(character)
        bindCharacter(player, character)
    end)
    if player.Character then
        task.spawn(bindCharacter, player, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
end)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

checkAccess.OnServerInvoke = function(player)
    return isAdmin(player)
end

setFeature.OnServerEvent:Connect(function(player, featureName, enabled)
    if not isAdmin(player) then
        return
    end
    if type(featureName) ~= "string" or validFeatures[featureName] ~= true then
        return
    end
    if type(enabled) ~= "boolean" then
        return
    end

    local state = getState(player)
    state[featureName] = enabled
    local humanoid = getHumanoid(player)
    if not humanoid then
        return
    end
    captureDefaults(state, humanoid)

    if featureName == "Speed" then
        if enabled then
            state.OriginalWalkSpeed = state.OriginalWalkSpeed or humanoid.WalkSpeed
            humanoid.WalkSpeed = SETTINGS.WalkSpeed
        elseif state.OriginalWalkSpeed then
            humanoid.WalkSpeed = state.OriginalWalkSpeed
        end
    elseif featureName == "HighJump" then
        if enabled then
            if state.OriginalUseJumpPower == nil then
                state.OriginalUseJumpPower = humanoid.UseJumpPower
                state.OriginalJumpPower = humanoid.JumpPower
                state.OriginalJumpHeight = humanoid.JumpHeight
            end
            humanoid.UseJumpPower = true
            humanoid.JumpPower = SETTINGS.JumpPower
        else
            if state.OriginalJumpPower then
                humanoid.JumpPower = state.OriginalJumpPower
            end
            if state.OriginalJumpHeight then
                humanoid.JumpHeight = state.OriginalJumpHeight
            end
            if state.OriginalUseJumpPower ~= nil then
                humanoid.UseJumpPower = state.OriginalUseJumpPower
            end
        end
    end
end)
