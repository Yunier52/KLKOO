-- KLKOO Studio Admin Panel - Client
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts in your own experience.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("KLKOO_AdminPanel")
local checkAccess = remotes:WaitForChild("CheckAccess")
local setFeatureRemote = remotes:WaitForChild("SetFeature")

local accessCallSucceeded, isAdmin = pcall(function()
    return checkAccess:InvokeServer()
end)
if not accessCallSucceeded or isAdmin ~= true then
    warn("[KLKOO Admin] No tienes permiso para abrir este panel.")
    return
end

local Theme = {
    Background = Color3.fromRGB(9, 19, 42),
    Panel = Color3.fromRGB(15, 31, 64),
    Card = Color3.fromRGB(21, 44, 85),
    CardMuted = Color3.fromRGB(17, 35, 67),
    Blue = Color3.fromRGB(36, 126, 235),
    BlueLight = Color3.fromRGB(70, 170, 255),
    Text = Color3.fromRGB(240, 247, 255),
    Muted = Color3.fromRGB(158, 181, 212),
    Red = Color3.fromRGB(193, 62, 82),
    Green = Color3.fromRGB(35, 164, 119),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KLKOO_StudioAdminPanel"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 50
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(480, 370)
panel.BackgroundColor3 = Theme.Panel
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Theme.BlueLight
panelStroke.Thickness = 1.5
panelStroke.Transparency = 0.25
panelStroke.Parent = panel

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = Theme.Background
header.BorderSizePixel = 0
header.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerFill = Instance.new("Frame")
headerFill.Name = "HeaderSquareBottom"
headerFill.Size = UDim2.new(1, 0, 0, 18)
headerFill.Position = UDim2.new(0, 0, 1, -18)
headerFill.BackgroundColor3 = Theme.Background
headerFill.BorderSizePixel = 0
headerFill.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.new(0, 18, 0, 7)
title.Size = UDim2.new(1, -80, 0, 25)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "KLKOO  /  ADMIN PANEL"
title.TextColor3 = Theme.Text
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Position = UDim2.new(0, 19, 0, 31)
subtitle.Size = UDim2.new(1, -90, 0, 17)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Herramientas de desarrollo · Solo administradores"
subtitle.TextColor3 = Theme.Muted
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -12, 0, 11)
closeButton.Size = UDim2.fromOffset(34, 34)
closeButton.BackgroundColor3 = Theme.Red
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Theme.Text
closeButton.TextSize = 15
closeButton.AutoButtonColor = true
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 9)
closeCorner.Parent = closeButton

local content = Instance.new("Frame")
content.Name = "FeatureGrid"
content.Position = UDim2.new(0, 14, 0, 68)
content.Size = UDim2.new(1, -28, 1, -82)
content.BackgroundTransparency = 1
content.Parent = panel

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.5, -6, 0, 82)
grid.CellPadding = UDim2.fromOffset(10, 9)
grid.FillDirection = Enum.FillDirection.Horizontal
grid.FillDirectionMaxCells = 2
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = content

local featureStates = {
    Fly = false,
    ESP = false,
    Speed = false,
    HighJump = false,
}
local toggleButtons = {}

local flySpeed = 55
local flyConnection
local flyVelocity
local flyAttachment
local flyHumanoid
local originalPlatformStand
local espHighlights = {}
local characterConnection

local function clearESP()
    for target, highlight in pairs(espHighlights) do
        if highlight then
            highlight:Destroy()
        end
        espHighlights[target] = nil
    end
end

local function refreshESP()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player then
            local character = target.Character
            local current = espHighlights[target]
            if character then
                if not current or current.Adornee ~= character or current.Parent == nil then
                    if current then
                        current:Destroy()
                    end
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "KLKOO_AdminESP"
                    highlight.Adornee = character
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 1
                    highlight.OutlineColor = Theme.BlueLight
                    highlight.OutlineTransparency = 0
                    highlight.Parent = character
                    espHighlights[target] = highlight
                end
            elseif current then
                current:Destroy()
                espHighlights[target] = nil
            end
        end
    end

    for target, highlight in pairs(espHighlights) do
        if target.Parent ~= Players then
            if highlight then
                highlight:Destroy()
            end
            espHighlights[target] = nil
        end
    end
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end
    if flyHumanoid and originalPlatformStand ~= nil then
        pcall(function()
            flyHumanoid.PlatformStand = originalPlatformStand
            if not originalPlatformStand then
                flyHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
    flyHumanoid = nil
    originalPlatformStand = nil
end

local function startFly()
    stopFly()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then
        warn("[KLKOO Admin] Fly espera a que cargue tu personaje.")
        return
    end

    flyHumanoid = humanoid
    originalPlatformStand = humanoid.PlatformStand
    humanoid.PlatformStand = true

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "KLKOO_FlyAttachment"
    flyAttachment.Parent = rootPart

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "KLKOO_FlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.MaxForce = 1000000
    flyVelocity.Parent = rootPart

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyVelocity or not flyVelocity.Parent then
            return
        end

        local camera = Workspace.CurrentCamera
        if not camera then
            flyVelocity.VectorVelocity = Vector3.zero
            return
        end

        local look = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        local forward = Vector3.new(look.X, 0, look.Z)
        local strafe = Vector3.new(right.X, 0, right.Z)
        if forward.Magnitude > 0 then
            forward = forward.Unit
        end
        if strafe.Magnitude > 0 then
            strafe = strafe.Unit
        end

        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction += forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction -= forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction += strafe
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction -= strafe
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.yAxis
        end

        if direction.Magnitude > 1 then
            direction = direction.Unit
        end
        flyVelocity.VectorVelocity = direction * flySpeed
    end)
end

local function updateToggleButton(featureName)
    local toggleButton = toggleButtons[featureName]
    if not toggleButton then
        return
    end
    local enabled = featureStates[featureName]
    toggleButton.Text = enabled and "ON" or "OFF"
    toggleButton.BackgroundColor3 = enabled and Theme.Green or Theme.Blue
end

local function setFeature(featureName, enabled)
    featureStates[featureName] = enabled
    updateToggleButton(featureName)

    local fired, err = pcall(function()
        setFeatureRemote:FireServer(featureName, enabled)
    end)
    if not fired then
        warn("[KLKOO Admin] No se pudo enviar la opción al servidor: " .. tostring(err))
    end

    if featureName == "Fly" then
        if enabled then
            startFly()
        else
            stopFly()
        end
    elseif featureName == "ESP" then
        if enabled then
            task.spawn(function()
                while featureStates.ESP and screenGui.Parent do
                    refreshESP()
                    task.wait(0.4)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
end

local featureInfo = {
    {Name = "Fly", Title = "FLY", Description = "WASD para moverte · Espacio sube · Ctrl baja", LayoutOrder = 1},
    {Name = "ESP", Title = "ESP", Description = "Resalta los personajes para depuración", LayoutOrder = 2},
    {Name = "Speed", Title = "SPEED", Description = "Aumenta la velocidad de movimiento", LayoutOrder = 3},
    {Name = "HighJump", Title = "HIGH JUMP", Description = "Aumenta la fuerza de salto", LayoutOrder = 4},
}

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

local function createFeatureCard(info)
    local card = Instance.new("Frame")
    card.Name = info.Name .. "Card"
    card.LayoutOrder = info.LayoutOrder
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = content
    addCorner(card, 11)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Theme.BlueLight
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.72
    cardStroke.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Position = UDim2.new(0, 12, 0, 9)
    nameLabel.Size = UDim2.new(1, -96, 0, 21)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = info.Title
    nameLabel.TextColor3 = Theme.Text
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    local description = Instance.new("TextLabel")
    description.Position = UDim2.new(0, 12, 0, 32)
    description.Size = UDim2.new(1, -96, 0, 40)
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.Gotham
    description.Text = info.Description
    description.TextColor3 = Theme.Muted
    description.TextSize = 10
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.Parent = card

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.AnchorPoint = Vector2.new(1, 0.5)
    toggleButton.Position = UDim2.new(1, -10, 0.5, 0)
    toggleButton.Size = UDim2.fromOffset(66, 34)
    toggleButton.BackgroundColor3 = Theme.Blue
    toggleButton.BorderSizePixel = 0
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Theme.Text
    toggleButton.TextSize = 13
    toggleButton.AutoButtonColor = true
    toggleButton.Parent = card
    addCorner(toggleButton, 8)

    toggleButtons[info.Name] = toggleButton
    toggleButton.Activated:Connect(function()
        setFeature(info.Name, not featureStates[info.Name])
    end)
end

for _, info in ipairs(featureInfo) do
    createFeatureCard(info)
end

for slotNumber = 5, 6 do
    local placeholder = Instance.new("Frame")
    placeholder.Name = "FutureSlot" .. slotNumber
    placeholder.LayoutOrder = slotNumber
    placeholder.BackgroundColor3 = Theme.CardMuted
    placeholder.BorderSizePixel = 0
    placeholder.Parent = content
    addCorner(placeholder, 11)

    local placeholderStroke = Instance.new("UIStroke")
    placeholderStroke.Color = Theme.BlueLight
    placeholderStroke.Thickness = 1
    placeholderStroke.Transparency = 0.85
    placeholderStroke.Parent = placeholder

    local placeholderText = Instance.new("TextLabel")
    placeholderText.Size = UDim2.new(1, 0, 1, 0)
    placeholderText.BackgroundTransparency = 1
    placeholderText.Font = Enum.Font.Gotham
    placeholderText.Text = "+  ESPACIO " .. tostring(slotNumber) .. "  ·  PRÓXIMAMENTE"
    placeholderText.TextColor3 = Theme.Muted
    placeholderText.TextSize = 11
    placeholderText.Parent = placeholder
end

local function closePanel()
    for featureName, enabled in pairs(featureStates) do
        if enabled then
            setFeature(featureName, false)
        end
    end
    if characterConnection then
        characterConnection:Disconnect()
        characterConnection = nil
    end
    stopFly()
    clearESP()
    screenGui:Destroy()
end

closeButton.Activated:Connect(closePanel)

characterConnection = player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if featureStates.Fly and screenGui.Parent then
        startFly()
    end
end)
