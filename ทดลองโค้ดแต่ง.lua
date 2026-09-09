-- [[ Rscripts Risk Notice ]]
-- This script is not verified by rscripts.net. Deal with caution.
--
-- Stay safe:
--   • Never log in on unofficial Roblox sites or lookalike domains.
--   • Real Roblox links use roblox.com (check the .com ending).
--   • Treat fake Roblox login / "claim reward" pages as phishing.
-- [[ End Rscripts Risk Notice ]]

--[[
    Place_100484168444874 multiplayer defense-trust probe

    Contains multiplayer targeting, the exact two defense trust hooks from the
    supplied working script, and a close-range outgoing hitbox-origin trust probe.
    Targeting supports enemy-only rosters,
    sticky/manual selection, automatic nearest selection, and cycling.

    Controls:
      Numpad 1  toggle player lock
      Numpad 2  previous opponent
      Numpad 3  next opponent
      Numpad 4  toggle defense trust hooks
      Numpad 5  toggle manual/automatic targeting
      Numpad 7  toggle close-range hitbox trust hook
      Home      show/hide panel
      Numpad 0 or End  unload
]]

if getgenv().CombatTrustProbe then
    pcall(function()
        getgenv().CombatTrustProbe:Unload()
    end)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayerCharacter = Remotes:WaitForChild("PlayerCharacter")
local ResolveImpact = PlayerCharacter:WaitForChild("Request"):WaitForChild("ResolveImpact")
local RequestHitboxOnImpact = PlayerCharacter.Request:WaitForChild("RequestHitboxOnImpact")

local CONFIG_FOLDER = "DefenseTrustProbe"
local CONFIG_PATH = CONFIG_FOLDER .. "/multiplayer_config.json"
local configStorageAvailable = type(readfile) == "function" and type(writefile) == "function"
local loadedConfig = {}
local configStatus = configStorageAvailable and "defaults" or "unavailable"

if configStorageAvailable then
    local ok, result = pcall(function()
        if type(isfile) == "function" and not isfile(CONFIG_PATH) then
            return nil
        end
        return HttpService:JSONDecode(readfile(CONFIG_PATH))
    end)
    if ok and type(result) == "table" then
        loadedConfig = result
        configStatus = "loaded"
    elseif not ok then
        configStatus = "load error"
    end
end

local function savedBoolean(key, fallback)
    return type(loadedConfig[key]) == "boolean" and loadedConfig[key] or fallback
end

local loadedTargetMode = loadedConfig.TargetMode == "AUTO" and "AUTO" or "MANUAL"
local loadedTargetKey = type(loadedConfig.ManualTargetKey) == "string" and loadedConfig.ManualTargetKey or nil

local Probe = {
    Alive = true,
    PlayerTargeting = savedBoolean("PlayerTargeting", true),
    TrustHooks = savedBoolean("TrustHooks", true),
    TargetMode = loadedTargetMode,
    ManualTargetKey = loadedTargetKey,
    PanelVisible = savedBoolean("PanelVisible", true),
    CloseHitHook = savedBoolean("CloseHitHook", true),
    CloseHitRange = 9,
    ConfigStatus = configStatus,
    CurrentTarget = nil,
    Roster = {},
    Connections = {},
    Counts = {
        TrustParries = 0,
        RedirectedHitboxes = 0,
    },
    Record = {
        TrustParries = 0,
        Timeline = {},
    },
    CombatIntel = {
        CounterWindowUntil = 0,
    },
}
getgenv().CombatTrustProbe = Probe

local function log(message)
    print("[defense trust probe] " .. message)
end

local function recordEvent(kind, detail)
    local timeline = Probe.Record.Timeline
    timeline[#timeline + 1] = {
        Time = os.clock(),
        Kind = kind,
        Detail = detail,
    }
    if #timeline > 80 then
        table.remove(timeline, 1)
    end
end

local function saveConfig()
    if not configStorageAvailable then
        Probe.ConfigStatus = "unavailable"
        return false
    end
    local manualKey = type(Probe.ManualTargetKey) == "string" and Probe.ManualTargetKey or nil
    local payload = {
        Version = 2,
        PlayerTargeting = Probe.PlayerTargeting,
        TrustHooks = Probe.TrustHooks,
        TargetMode = Probe.TargetMode,
        ManualTargetKey = manualKey,
        PanelVisible = Probe.PanelVisible,
        CloseHitHook = Probe.CloseHitHook,
    }
    local ok, err = pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" then
            if not isfolder(CONFIG_FOLDER) then
                makefolder(CONFIG_FOLDER)
            end
        elseif type(makefolder) == "function" then
            pcall(makefolder, CONFIG_FOLDER)
        end
        writefile(CONFIG_PATH, HttpService:JSONEncode(payload))
    end)
    Probe.ConfigStatus = ok and "saved" or "save error"
    if not ok then
        log("config save failed: " .. tostring(err))
    end
    return ok
end

local configSaveSerial = 0
local function queueConfigSave()
    configSaveSerial += 1
    local serial = configSaveSerial
    task.delay(0.2, function()
        if Probe.Alive and serial == configSaveSerial then
            saveConfig()
        end
    end)
end

local GameManager
local CharacterController
local TargetLockController
local MatchController

local function refreshControllers()
    if GameManager and CharacterController and TargetLockController and MatchController then
        return true
    end

    if not GameManager then
        local ok, manager = pcall(require, ReplicatedStorage:WaitForChild("GameManager"))
        if not ok then
            log("GameManager unavailable: " .. tostring(manager))
            return false
        end
        GameManager = manager
    end

    local ok = pcall(function()
        CharacterController = GameManager:GetController("CharacterController")
        TargetLockController = GameManager:GetController("TargetLockController")
        MatchController = GameManager:GetController("MatchController")
    end)
    if not ok then
        return false
    end
    return CharacterController ~= nil
end

local function getHandler()
    if not refreshControllers() then
        return nil
    end

    if CharacterController.LoadedCharacterHandler then
        return CharacterController.LoadedCharacterHandler
    end

    local ok, handler = pcall(function()
        return CharacterController:GetLocalCharacterHandler()
    end)
    if ok and handler then
        return handler
    end

    local camera = workspace.CurrentCamera
    local subject = camera and camera.CameraSubject or nil
    local subjectModel = subject and (subject:IsA("Humanoid") and subject.Parent or subject:FindFirstAncestorWhichIsA("Model")) or nil
    if subjectModel then
        local subjectOk, subjectHandler = pcall(function()
            return CharacterController:GetCharacterHandler(subjectModel)
        end)
        if subjectOk and subjectHandler then
            return subjectHandler
        end
    end

    for _, model in CollectionService:GetTagged("CustomCharacter") do
        if model:GetAttribute("UserId") == LocalPlayer.UserId then
            local modelOk, modelHandler = pcall(function()
                return CharacterController:GetCharacterHandler(model)
            end)
            if modelOk and modelHandler then
                return modelHandler
            end
        end
    end
    return nil
end

local function getRoot()
    local handler = getHandler()
    if handler and handler.Root and handler.Root:IsDescendantOf(workspace) then
        return handler.Root
    end
    local character = LocalPlayer.Character
    return character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart) or nil
end

local function getTargetPart(model)
    if not model then
        return nil
    end
    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
end

local function isLocalModel(model, part, localRoot)
    if model == LocalPlayer.Character or model:GetAttribute("UserId") == LocalPlayer.UserId then
        return true
    end
    local handler = getHandler()
    return (handler and (model == handler.Model or model == handler.OriginalModel))
        or (part and localRoot and part == localRoot)
end

local function isEnemyModel(model, player)
    if MatchController and type(MatchController.IsCharacterEnemyOfLocalPlayer) == "function" then
        local ok, enemy = pcall(function()
            return MatchController:IsCharacterEnemyOfLocalPlayer(model)
        end)
        if ok then
            return enemy == true
        end
    end
    if player and LocalPlayer.Team and player.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return player ~= LocalPlayer
end

local function targetKey(model, player)
    local userId = player and player.UserId or model:GetAttribute("UserId")
    return userId and ("user:" .. tostring(userId)) or model
end

local function collectEnemyRoster()
    local localRoot = getRoot()
    if not localRoot then
        return {}
    end

    local roster = {}
    local bestByKey = {}
    local function consider(model, player, preferred)
        if not model or not model:IsDescendantOf(workspace) or model:GetAttribute("IsDead") == true then
            return
        end
        local part = getTargetPart(model)
        if not part or not part:IsDescendantOf(workspace) or isLocalModel(model, part, localRoot) then
            return
        end
        if not isEnemyModel(model, player) then
            return
        end
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            return
        end

        local key = targetKey(model, player)
        local target = {
            Key = key,
            Model = model,
            Player = player,
            Part = part,
            Humanoid = humanoid,
            Distance = (part.Position - localRoot.Position).Magnitude,
            Preferred = preferred == true,
        }
        local current = bestByKey[key]
        if not current or (target.Preferred and not current.Preferred) or target.Distance < current.Distance then
            bestByKey[key] = target
        end
    end

    for _, model in CollectionService:GetTagged("CustomCharacter") do
        local userId = model:GetAttribute("UserId")
        local player = userId and Players:GetPlayerByUserId(userId) or nil
        if player and player ~= LocalPlayer then
            consider(model, player, true)
        end
    end
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer then
            consider(player.Character, player, false)
        end
    end
    for _, target in bestByKey do
        table.insert(roster, target)
    end
    table.sort(roster, function(left, right)
        return left.Distance < right.Distance
    end)
    return roster
end

local function findRosterIndex(key)
    for index, target in Probe.Roster do
        if target.Key == key then
            return index
        end
    end
    return nil
end

local function selectRosterIndex(index)
    local count = #Probe.Roster
    if count == 0 then
        Probe.ManualTargetKey = nil
        Probe.CurrentTarget = nil
        return
    end
    index = ((index - 1) % count) + 1
    Probe.TargetMode = "MANUAL"
    Probe.ManualTargetKey = Probe.Roster[index].Key
    Probe.CurrentTarget = Probe.Roster[index]
    local player = Probe.CurrentTarget.Player
    log("manual target: " .. (player and player.Name or Probe.CurrentTarget.Model.Name))
    queueConfigSave()
end

local function cycleTarget(direction)
    local count = #Probe.Roster
    if count == 0 then
        log("no enemy players available to cycle")
        return
    end
    local currentIndex = findRosterIndex(Probe.ManualTargetKey)
        or (Probe.CurrentTarget and findRosterIndex(Probe.CurrentTarget.Key))
        or 1
    selectRosterIndex(currentIndex + direction)
end

local function toggleTargetMode()
    if Probe.TargetMode == "AUTO" then
        Probe.TargetMode = "MANUAL"
        Probe.ManualTargetKey = Probe.CurrentTarget and Probe.CurrentTarget.Key or Probe.ManualTargetKey
    else
        Probe.TargetMode = "AUTO"
    end
    log("target mode " .. Probe.TargetMode)
    queueConfigSave()
end

local function resolveSelectedTarget()
    local roster = Probe.Roster
    if #roster == 0 then
        return nil
    end
    if Probe.TargetMode == "AUTO" then
        return roster[1]
    end
    local index = findRosterIndex(Probe.ManualTargetKey)
    if not index then
        index = 1
        Probe.ManualTargetKey = roster[1].Key
        queueConfigSave()
    end
    return roster[index]
end

local colors = {
    Background = Color3.fromRGB(16, 19, 26),
    Surface = Color3.fromRGB(25, 29, 39),
    SurfaceHover = Color3.fromRGB(34, 39, 51),
    Border = Color3.fromRGB(49, 56, 72),
    Text = Color3.fromRGB(241, 244, 250),
    Muted = Color3.fromRGB(145, 156, 178),
    On = Color3.fromRGB(54, 205, 126),
    Off = Color3.fromRGB(82, 90, 107),
    Accent = Color3.fromRGB(255, 184, 72),
    AccentSoft = Color3.fromRGB(83, 65, 36),
    Health = Color3.fromRGB(81, 210, 132),
    Danger = Color3.fromRGB(235, 91, 101),
}

local gui = Instance.new("ScreenGui")
gui.Name = "MultiplayerDefenseTrustProbe"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Potassium's current thread can create objects under CoreGui/gethui but may
-- lose permission to update them afterward ("lacking capability Plugin").
-- PlayerGui remains writable by the local client throughout the heartbeat.
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(460, 440)
panel.Position = UDim2.new(0, 24, 0.5, -220)
panel.BackgroundColor3 = colors.Background
panel.BorderSizePixel = 0
panel.Visible = Probe.PanelVisible
panel.Parent = gui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = colors.Border
panelStroke.Thickness = 1
panelStroke.Transparency = 0.15
panelStroke.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 62)
header.BackgroundColor3 = colors.Surface
header.BorderSizePixel = 0
header.Parent = panel
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header
local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 12)
headerCover.Position = UDim2.new(0, 0, 1, -12)
headerCover.BackgroundColor3 = colors.Surface
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 28)
title.Position = UDim2.fromOffset(16, 9)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = colors.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "COMBAT TRUST"
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -90, 0, 18)
subtitle.Position = UDim2.fromOffset(16, 34)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Code
subtitle.TextSize = 10
subtitle.TextColor3 = colors.Muted
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "defense + close-hit validation"
subtitle.Parent = header

local enemyBadge = Instance.new("TextLabel")
enemyBadge.Size = UDim2.fromOffset(62, 28)
enemyBadge.Position = UDim2.new(1, -76, 0, 17)
enemyBadge.BackgroundColor3 = colors.AccentSoft
enemyBadge.BorderSizePixel = 0
enemyBadge.Font = Enum.Font.GothamBold
enemyBadge.TextSize = 11
enemyBadge.TextColor3 = colors.Accent
enemyBadge.Text = "0 ENEMY"
enemyBadge.Parent = header
local enemyBadgeCorner = Instance.new("UICorner")
enemyBadgeCorner.CornerRadius = UDim.new(1, 0)
enemyBadgeCorner.Parent = enemyBadge

local stateButtons = {}
local function makeStateButton(x, key, hotkey, label)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.5, -18, 0, 42)
    button.Position = UDim2.new(x, x == 0 and 12 or 6, 0, 74)
    button.BackgroundColor3 = colors.Surface
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.Border
    stroke.Transparency = 0.35
    stroke.Parent = button

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.fromOffset(44, 22)
    keyLabel.Position = UDim2.fromOffset(10, 10)
    keyLabel.BackgroundColor3 = colors.Off
    keyLabel.BorderSizePixel = 0
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextSize = 9
    keyLabel.TextColor3 = colors.Text
    keyLabel.Text = hotkey
    keyLabel.Parent = button
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 5)
    keyCorner.Parent = keyLabel

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -68, 1, 0)
    textLabel.Position = UDim2.fromOffset(62, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 11
    textLabel.TextColor3 = colors.Text
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Text = label
    textLabel.Parent = button

    stateButtons[key] = { Button = button, Key = keyLabel, Stroke = stroke }
    table.insert(Probe.Connections, button.Activated:Connect(function()
        Probe[key] = not Probe[key]
        log(key .. " " .. (Probe[key] and "enabled" or "disabled"))
        queueConfigSave()
    end))
end

makeStateButton(0, "PlayerTargeting", "NUM 1", "PLAYER LOCK")
makeStateButton(0.5, "TrustHooks", "NUM 4", "TRUST HOOK")

local function makeActionButton(x, width, textValue)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, width, 0, 38)
    button.Position = UDim2.fromOffset(x, 126)
    button.BackgroundColor3 = colors.Surface
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.TextColor3 = colors.Text
    button.Text = textValue
    button.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.Border
    stroke.Transparency = 0.35
    stroke.Parent = button
    return button
end

local previousButton = makeActionButton(12, 82, "◀  PREV")
local modeButton = makeActionButton(101, 168, "MODE  MANUAL")
local hitHookButton = makeActionButton(276, 83, "NUM7  HIT")
local nextButton = makeActionButton(366, 82, "NEXT  ▶")

table.insert(Probe.Connections, previousButton.Activated:Connect(function()
    cycleTarget(-1)
end))
table.insert(Probe.Connections, nextButton.Activated:Connect(function()
    cycleTarget(1)
end))
table.insert(Probe.Connections, modeButton.Activated:Connect(toggleTargetMode))
table.insert(Probe.Connections, hitHookButton.Activated:Connect(function()
    Probe.CloseHitHook = not Probe.CloseHitHook
    log("close-range hitbox trust hook " .. (Probe.CloseHitHook and "enabled" or "disabled"))
    queueConfigSave()
end))

local rosterHeader = Instance.new("TextLabel")
rosterHeader.Size = UDim2.new(1, -24, 0, 24)
rosterHeader.Position = UDim2.fromOffset(12, 174)
rosterHeader.BackgroundTransparency = 1
rosterHeader.Font = Enum.Font.GothamBold
rosterHeader.TextSize = 11
rosterHeader.TextColor3 = colors.Muted
rosterHeader.TextXAlignment = Enum.TextXAlignment.Left
rosterHeader.Text = "ENEMY ROSTER"
rosterHeader.Parent = panel

local rosterRows = {}
for index = 1, 3 do
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -24, 0, 46)
    row.Position = UDim2.fromOffset(12, 199 + ((index - 1) * 50))
    row.BackgroundColor3 = colors.Surface
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""
    row.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = row
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors.Border
    stroke.Transparency = 0.45
    stroke.Parent = row

    local number = Instance.new("TextLabel")
    number.Size = UDim2.fromOffset(30, 30)
    number.Position = UDim2.fromOffset(8, 8)
    number.BackgroundColor3 = colors.Off
    number.BorderSizePixel = 0
    number.Font = Enum.Font.GothamBold
    number.TextSize = 11
    number.TextColor3 = colors.Text
    number.Text = tostring(index)
    number.Parent = row
    local numberCorner = Instance.new("UICorner")
    numberCorner.CornerRadius = UDim.new(1, 0)
    numberCorner.Parent = number

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -180, 0, 21)
    name.Position = UDim2.fromOffset(48, 4)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamSemibold
    name.TextSize = 11
    name.TextColor3 = colors.Text
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Text = "Waiting for opponent"
    name.Parent = row

    local detail = Instance.new("TextLabel")
    detail.Size = UDim2.new(1, -180, 0, 16)
    detail.Position = UDim2.fromOffset(48, 24)
    detail.BackgroundTransparency = 1
    detail.Font = Enum.Font.Code
    detail.TextSize = 9
    detail.TextColor3 = colors.Muted
    detail.TextXAlignment = Enum.TextXAlignment.Left
    detail.Text = "--"
    detail.Parent = row

    local distance = Instance.new("TextLabel")
    distance.Size = UDim2.fromOffset(116, 20)
    distance.Position = UDim2.new(1, -128, 0, 5)
    distance.BackgroundTransparency = 1
    distance.Font = Enum.Font.GothamBold
    distance.TextSize = 10
    distance.TextColor3 = colors.Accent
    distance.TextXAlignment = Enum.TextXAlignment.Right
    distance.Text = "-- STUDS"
    distance.Parent = row

    local healthBack = Instance.new("Frame")
    healthBack.Size = UDim2.fromOffset(112, 5)
    healthBack.Position = UDim2.new(1, -124, 0, 31)
    healthBack.BackgroundColor3 = colors.Off
    healthBack.BorderSizePixel = 0
    healthBack.Parent = row
    local healthBackCorner = Instance.new("UICorner")
    healthBackCorner.CornerRadius = UDim.new(1, 0)
    healthBackCorner.Parent = healthBack
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.BackgroundColor3 = colors.Health
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBack
    local healthFillCorner = Instance.new("UICorner")
    healthFillCorner.CornerRadius = UDim.new(1, 0)
    healthFillCorner.Parent = healthFill

    rosterRows[index] = {
        Row = row,
        Stroke = stroke,
        Number = number,
        Name = name,
        Detail = detail,
        Distance = distance,
        HealthFill = healthFill,
    }
    table.insert(Probe.Connections, row.Activated:Connect(function()
        if Probe.Roster[index] then
            selectRosterIndex(index)
        end
    end))
end

local targetReadout = Instance.new("TextLabel")
targetReadout.Size = UDim2.new(1, -24, 0, 38)
targetReadout.Position = UDim2.fromOffset(12, 355)
targetReadout.BackgroundTransparency = 1
targetReadout.Font = Enum.Font.GothamBold
targetReadout.TextSize = 12
targetReadout.TextColor3 = colors.Accent
targetReadout.TextXAlignment = Enum.TextXAlignment.Left
targetReadout.TextYAlignment = Enum.TextYAlignment.Top
targetReadout.Text = "LOCKED: none"
targetReadout.Parent = panel

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 30)
footer.Position = UDim2.fromOffset(12, 400)
footer.BackgroundTransparency = 1
footer.Font = Enum.Font.Code
footer.TextSize = 9
footer.TextColor3 = colors.Muted
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.TextWrapped = true
footer.Text = "AUTO-SAVE: DEFAULTS • NUM2/3 cycle • NUM5 mode • NUM7 hit • HOME hide"
footer.Parent = panel

local highlight = Instance.new("Highlight")
highlight.Name = "DefenseTrustLockedEnemy"
highlight.FillColor = colors.Accent
highlight.FillTransparency = 0.78
highlight.OutlineColor = Color3.fromRGB(255, 229, 158)
highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Enabled = false
highlight.Parent = gui

local billboard = Instance.new("BillboardGui")
billboard.Name = "DefenseTrustLockedLabel"
billboard.Size = UDim2.fromOffset(230, 42)
billboard.StudsOffset = Vector3.new(0, 3.2, 0)
billboard.AlwaysOnTop = true
billboard.Enabled = false
billboard.Parent = gui
local billboardText = Instance.new("TextLabel")
billboardText.Size = UDim2.fromScale(1, 1)
billboardText.BackgroundColor3 = colors.Background
billboardText.BackgroundTransparency = 0.12
billboardText.BorderSizePixel = 0
billboardText.Font = Enum.Font.GothamBold
billboardText.TextSize = 11
billboardText.TextColor3 = colors.Text
billboardText.Text = "LOCKED"
billboardText.Parent = billboard
local billboardCorner = Instance.new("UICorner")
billboardCorner.CornerRadius = UDim.new(0, 7)
billboardCorner.Parent = billboardText

local function clearTarget()
    if TargetLockController then
        pcall(function()
            TargetLockController:SetTarget(nil)
        end)
    end
    Probe.CurrentTarget = nil
    highlight.Enabled = false
    billboard.Enabled = false
end

local function updatePanel()
    for _, key in { "PlayerTargeting", "TrustHooks" } do
        local enabled = Probe[key]
        local item = stateButtons[key]
        item.Key.BackgroundColor3 = enabled and colors.On or colors.Off
        item.Stroke.Color = enabled and colors.On or colors.Border
        item.Stroke.Transparency = enabled and 0.05 or 0.35
    end

    modeButton.Text = Probe.TargetMode == "AUTO" and "MODE  AUTO" or "MODE  MANUAL"
    modeButton.BackgroundColor3 = Probe.TargetMode == "AUTO" and colors.AccentSoft or colors.Surface
    hitHookButton.BackgroundColor3 = Probe.CloseHitHook and colors.AccentSoft or colors.Surface
    hitHookButton.TextColor3 = Probe.CloseHitHook and colors.Accent or colors.Muted
    enemyBadge.Text = string.format("%d %s", #Probe.Roster, #Probe.Roster == 1 and "ENEMY" or "ENEMIES")
    footer.Text = string.format(
        "AUTO-SAVE: %s  •  NUM2/3 cycle  •  NUM5 mode  •  NUM7 hit  •  HOME hide",
        string.upper(Probe.ConfigStatus)
    )

    for index, row in rosterRows do
        local target = Probe.Roster[index]
        local selected = target and Probe.CurrentTarget and target.Key == Probe.CurrentTarget.Key
        if target then
            local player = target.Player
            local humanoid = target.Humanoid
            local displayName = player and player.DisplayName or target.Model.Name
            local accountName = player and ("@" .. player.Name) or target.Model.Name
            local health = humanoid and humanoid.Health or 0
            local maxHealth = humanoid and humanoid.MaxHealth or 0
            local healthRatio = maxHealth > 0 and math.clamp(health / maxHealth, 0, 1) or 0
            row.Name.Text = displayName
            row.Detail.Text = string.format("%s  •  %.0f/%.0f HP", accountName, health, maxHealth)
            row.Distance.Text = string.format("%.1f STUDS", target.Distance)
            row.HealthFill.Size = UDim2.fromScale(healthRatio, 1)
            row.HealthFill.BackgroundColor3 = healthRatio <= 0.3 and colors.Danger or colors.Health
            row.Row.BackgroundColor3 = selected and colors.AccentSoft or colors.Surface
            row.Stroke.Color = selected and colors.Accent or colors.Border
            row.Stroke.Transparency = selected and 0 or 0.45
            row.Number.BackgroundColor3 = selected and colors.Accent or colors.Off
            row.Number.TextColor3 = selected and colors.Background or colors.Text
            row.Row.Active = true
        else
            row.Name.Text = "Empty opponent slot"
            row.Detail.Text = "waiting for enemy player"
            row.Distance.Text = "-- STUDS"
            row.HealthFill.Size = UDim2.fromScale(0, 1)
            row.Row.BackgroundColor3 = colors.Surface
            row.Stroke.Color = colors.Border
            row.Stroke.Transparency = 0.65
            row.Number.BackgroundColor3 = colors.Off
            row.Number.TextColor3 = colors.Muted
            row.Row.Active = false
        end
    end

    local target = Probe.CurrentTarget
    if target and target.Part and target.Part:IsDescendantOf(workspace) then
        local player = target.Player
        local name = player and player.Name or target.Model.Name
        targetReadout.Text = string.format(
            "LOCKED: %s\nPARRIES %d  •  HIT REDIRECTS %d  •  %.1f/%.0f studs",
            name,
            Probe.Counts.TrustParries,
            Probe.Counts.RedirectedHitboxes,
            target.Distance,
            Probe.CloseHitRange
        )
        highlight.Adornee = target.Model
        highlight.Enabled = Probe.PlayerTargeting
        billboard.Adornee = target.Part
        billboard.Enabled = Probe.PlayerTargeting
        billboardText.Text = string.format("LOCKED: %s  •  %.1f studs", name, target.Distance)
    else
        targetReadout.Text = string.format(
            "LOCKED: none\nPARRIES %d  •  HIT REDIRECTS %d",
            Probe.Counts.TrustParries,
            Probe.Counts.RedirectedHitboxes
        )
        highlight.Enabled = false
        billboard.Enabled = false
    end

end

-- Trust hook 1: make the game's own impact computation observe a parry state.
-- This preserves the normal Parry resultData/staggerProperties shape, allowing
-- the test to show whether the server trusts a client-computed Parry outcome.
local resolutionHookTarget
local resolutionHookOriginal
local resolutionHookInstalled = false
local function installImpactResolutionHook()
    if resolutionHookInstalled or not Probe.TrustHooks
        or type(hookfunction) ~= "function" or type(newcclosure) ~= "function" then
        return
    end
    local handler = getHandler()
    local manager = handler and handler.ActionManager
    local targetFunction = manager and manager._computeImpactResolution
    if type(targetFunction) ~= "function" then
        return
    end
    resolutionHookTarget = targetFunction
    local replacement
    replacement = newcclosure(function(self, impactData)
        local liveHandler = getHandler()
        if not Probe.Alive or not Probe.TrustHooks or self ~= (liveHandler and liveHandler.ActionManager) then
            return resolutionHookOriginal(self, impactData)
        end
        local characterHandler = self.CharacterHandler
        local previousParry = characterHandler.IsParrying
        local previousBlock = characterHandler.IsBlocking
        characterHandler.IsParrying = true
        characterHandler.IsBlocking = true
        local results = table.pack(resolutionHookOriginal(self, impactData))
        characterHandler.IsParrying = previousParry
        characterHandler.IsBlocking = previousBlock
        local resolution = results[1]
        if type(resolution) == "table" and resolution.result == "Parry" then
            Probe.Counts.TrustParries += 1
            Probe.Record.TrustParries += 1
            Probe.CombatIntel.CounterWindowUntil = os.clock() + 0.9
            recordEvent("trust_hook_parry", "native impact computation returned Parry")
        end
        return table.unpack(results, 1, results.n)
    end)
    local ok, original = pcall(hookfunction, targetFunction, replacement)
    if ok and type(original) == "function" then
        resolutionHookOriginal = original
        resolutionHookInstalled = true
        log("defense trust hook installed on _computeImpactResolution")
    end
end

-- Trust hook 2: outgoing-result fallback. If the computation hook cannot make
-- a valid defensive result, rewrite the result string at the final RemoteEvent.
local oldNamecall
local namecallHookInstalled = false
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" and type(newcclosure) == "function" then
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Probe.Alive and Probe.TrustHooks and self == ResolveImpact and method == "FireServer" then
            local args = { ... }
            local originalResult = args[2]
            if originalResult ~= "Parry" and originalResult ~= "Dodge" then
                args[2] = "Parry"
                Probe.Counts.TrustParries += 1
                Probe.Record.TrustParries += 1
                Probe.CombatIntel.CounterWindowUntil = os.clock() + 0.9
                recordEvent("trust_hook_forced", tostring(originalResult) .. " -> Parry")
                log("TRUST HOOK: rewrote impact result " .. tostring(originalResult) .. " -> Parry")
            end
            return oldNamecall(self, table.unpack(args))
        end
        return oldNamecall(self, ...)
    end))
    namecallHookInstalled = true
end

-- Close-range outgoing hitbox trust probe. The game asks the attacking client
-- to return a root CFrame, timestamp, and server-issued request token through
-- RequestHitboxOnImpact. For a locked enemy inside the normal Katana envelope,
-- this hook redirects only that reported origin so the hitbox covers the target.
-- The original timestamp and token remain untouched.
local oldHitNamecall
local hitNamecallHookInstalled = false
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" and type(newcclosure) == "function" then
    oldHitNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Probe.Alive and Probe.CloseHitHook and self == RequestHitboxOnImpact and method == "FireServer" then
            local args = { ... }
            local target = Probe.CurrentTarget
            local localRoot = getRoot()
            local targetPart = target and target.Part or nil
            if localRoot and targetPart and targetPart:IsDescendantOf(workspace) and typeof(args[1]) == "CFrame" then
                local offset = targetPart.Position - localRoot.Position
                local distance = offset.Magnitude
                if distance > 0.05 and distance <= Probe.CloseHitRange then
                    local direction = offset.Unit
                    local reportedOrigin = targetPart.Position - direction * 2.75
                    args[1] = CFrame.lookAt(reportedOrigin, targetPart.Position)
                    Probe.Counts.RedirectedHitboxes += 1
                    local targetName = target.Player and target.Player.Name or target.Model.Name
                    recordEvent(
                        "hitbox_origin_redirect",
                        string.format("%s at %.2f studs; token preserved", targetName, distance)
                    )
                    log(string.format(
                        "HITBOX TRUST: redirected server-requested origin to %s at %.2f studs",
                        targetName,
                        distance
                    ))
                    return oldHitNamecall(self, table.unpack(args))
                end
            end
        end
        return oldHitNamecall(self, ...)
    end))
    hitNamecallHookInstalled = true
end

local lastPanelUpdate = 0

table.insert(Probe.Connections, RunService.Heartbeat:Connect(function()
    if not Probe.Alive then
        return
    end

    installImpactResolutionHook()
    Probe.Roster = collectEnemyRoster()

    if Probe.PlayerTargeting then
        local target = resolveSelectedTarget()
        Probe.CurrentTarget = target
        if target and TargetLockController then
            pcall(function()
                TargetLockController:SetTarget(target.Part)
            end)
        elseif not target and TargetLockController then
            pcall(function()
                TargetLockController:SetTarget(nil)
            end)
        end
    elseif Probe.CurrentTarget then
        clearTarget()
    end

    if os.clock() - lastPanelUpdate >= 0.1 then
        lastPanelUpdate = os.clock()
        updatePanel()
    end
end))

table.insert(Probe.Connections, UserInputService.InputBegan:Connect(function(input)
    if not Probe.Alive or UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == Enum.KeyCode.KeypadOne then
        Probe.PlayerTargeting = not Probe.PlayerTargeting
        log("PlayerTargeting " .. (Probe.PlayerTargeting and "enabled" or "disabled"))
        queueConfigSave()
    elseif input.KeyCode == Enum.KeyCode.KeypadTwo then
        cycleTarget(-1)
    elseif input.KeyCode == Enum.KeyCode.KeypadThree then
        cycleTarget(1)
    elseif input.KeyCode == Enum.KeyCode.KeypadFour then
        Probe.TrustHooks = not Probe.TrustHooks
        log("TrustHooks " .. (Probe.TrustHooks and "enabled" or "disabled"))
        queueConfigSave()
    elseif input.KeyCode == Enum.KeyCode.KeypadFive then
        toggleTargetMode()
    elseif input.KeyCode == Enum.KeyCode.KeypadSeven then
        Probe.CloseHitHook = not Probe.CloseHitHook
        log("close-range hitbox trust hook " .. (Probe.CloseHitHook and "enabled" or "disabled"))
        queueConfigSave()
    elseif input.KeyCode == Enum.KeyCode.Home then
        panel.Visible = not panel.Visible
        Probe.PanelVisible = panel.Visible
        queueConfigSave()
    elseif input.KeyCode == Enum.KeyCode.KeypadZero or input.KeyCode == Enum.KeyCode.End then
        Probe:Unload()
    end
end))

function Probe:Unload()
    if not self.Alive then
        return
    end
    self.PanelVisible = panel and panel.Visible or self.PanelVisible
    saveConfig()
    self.Alive = false
    self.PlayerTargeting = false
    self.TrustHooks = false
    self.CloseHitHook = false

    for _, connection in self.Connections do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(self.Connections)
    clearTarget()

    if resolutionHookInstalled and resolutionHookTarget and resolutionHookOriginal then
        if type(restorefunction) == "function" then
            pcall(restorefunction, resolutionHookTarget)
        elseif type(hookfunction) == "function" then
            pcall(hookfunction, resolutionHookTarget, resolutionHookOriginal)
        end
    end
    if hitNamecallHookInstalled and oldHitNamecall then
        pcall(function()
            hookmetamethod(game, "__namecall", oldHitNamecall)
        end)
    end
    if namecallHookInstalled and oldNamecall then
        pcall(function()
            hookmetamethod(game, "__namecall", oldNamecall)
        end)
    end

    if gui then
        gui:Destroy()
    end
    getgenv().CombatTrustProbe = nil
    log("unloaded")
end

updatePanel()
if configStorageAvailable and Probe.ConfigStatus ~= "loaded" then
    queueConfigSave()
end
