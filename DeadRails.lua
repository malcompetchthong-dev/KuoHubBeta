local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/ITKuo/refs/heads/main/KUOHUBUI.lua"))()

Window:MakeWindow({
    Title = "Kuo Hub [DeadRails]",
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://126460540157931", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(35, 1) },
})

local Home = Window:Tab("Home")
local Combat = Window:Tab("Combat")

Home:Section("Main")

repeat task.wait() until game:IsLoaded()

--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- 🛡️ GOD MODE (FINAL)
-- =========================
local CombatModule = {}
local ScriptState = { GodMode = false }
local Connections = {}

function CombatModule.EnableGodMode()
    if ScriptState.GodMode then return end
    ScriptState.GodMode = true

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        local conn = humanoid.HealthChanged:Connect(function()
            if ScriptState.GodMode then
                humanoid.Health = humanoid.MaxHealth
            end
        end)

        table.insert(Connections, conn)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

        print("🛡️ God Mode ON")
    end
end

function CombatModule.DisableGodMode()
    ScriptState.GodMode = false

    for _, v in pairs(Connections) do
        pcall(function() v:Disconnect() end)
    end
    Connections = {}

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end

    print("🚫 God Mode OFF")
end

-- 🔥 กัน stun เพิ่ม
task.spawn(function()
    while task.wait(0.1) do
        if ScriptState.GodMode then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end)

-- =========================
-- 👻 INVISIBLE
-- =========================
local invisible = false
local bodyParts = {}
local character, humanoid, rootPart

local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")

    bodyParts = {}

    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency == 0 then
            table.insert(bodyParts, v)
        end
    end
end

local function setInvisible(state)
    invisible = state

    for _, v in pairs(bodyParts) do
        v.Transparency = invisible and 0.5 or 0
    end
end

function applyInvisible(state)
    setInvisible(state)
end

setupCharacter()

RunService.Heartbeat:Connect(function()
    if invisible and rootPart and humanoid then
        local cf = rootPart.CFrame
        local camOff = humanoid.CameraOffset

        rootPart.CFrame = cf * CFrame.new(0, -200000, 0)
        humanoid.CameraOffset = Vector3.new(
            camOff.X,
            camOff.Y + 200000,
            camOff.Z
        )

        RunService.RenderStepped:Wait()

        rootPart.CFrame = cf
        humanoid.CameraOffset = camOff
    end
end)

player.CharacterAdded:Connect(function()
    invisible = false
    setupCharacter()
end)

-- =========================
-- 🚶 SPEED
-- =========================
getgenv().SpeedValue = 16

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function applySpeed(v)
    local char = getChar()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = v
    end
end

task.spawn(function()
    while task.wait(0.05) do
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if hrp and hum then
                local dir = hum.MoveDirection

                if dir.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = dir * getgenv().SpeedValue
                else
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed(getgenv().SpeedValue)
end)

-- =========================
-- UI
-- =========================
Home:AddDiscordInvite({
    Name = "Kuo Hub",
    Description = "Join server",
    Logo = "rbxassetid://126460540157931",
    Invite = "https://discord.gg/Apn2j9Fez",
})

Home:Toggle({
    Title = "God Mode",
    Desc = "กันตาย",
    Callback = function(v)
        if v then
            CombatModule.EnableGodMode()
        else
            CombatModule.DisableGodMode()
        end
    end
})

Combat:Toggle({
    Title = "Invisible Mode",
    Desc = "ร่องหน",
    Callback = function(v)
        applyInvisible(v)
    end
})

Home:AddSlider({
    Name = "Adjust walking speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        getgenv().SpeedValue = v
        applySpeed(v)
    end
})
