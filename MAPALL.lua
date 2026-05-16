local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/ITKuo/refs/heads/main/KUOHUBUI.lua"))()

Window:MakeWindow({
Title = "Kuo Hub [Beta]",
})

Window:AddMinimizeButton({
Button = { Image = "rbxassetid://103308551113442", BackgroundTransparency = 0 },
Corner = { CornerRadius = UDim.new(35, 1) },
})

local Home = Window:Tab("Home")

Home:Section("Main")

repeat task.wait() until game:IsLoaded()

--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// CHARACTER
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

--// SETTINGS
local flying = false
local speed = 60
local noclip = false
local infjump = false
local godmode = false

-- =========================
-- GOD MODE
-- =========================
RunService.Heartbeat:Connect(function()
    if godmode then
        local char = getChar()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end
end)

-- =========================
-- FLY
-- =========================
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(9e9,9e9,9e9)

local bg = Instance.new("BodyGyro")
bg.MaxTorque = Vector3.new(9e9,9e9,9e9)

local function setFly(state)
    flying = state
    local char = getChar()
    local root = char:WaitForChild("HumanoidRootPart")
    
    bv.Parent = state and root or nil
    bg.Parent = state and root or nil
end

RunService.RenderStepped:Connect(function()
    if flying then
        local char = getChar()
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            local cam = workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            
            bv.Velocity = (cam.CFrame.LookVector * moveDir.Z + cam.CFrame.RightVector * moveDir.X) * speed
            bg.CFrame = cam.CFrame
        end
    end
end)

-- =========================
-- NOCLIP
-- =========================
RunService.Stepped:Connect(function()
    if noclip then
        local char = getChar()
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- =========================
-- INFINITE JUMP
-- =========================
UIS.JumpRequest:Connect(function()
    if infjump then
        local char = getChar()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
-- =========================      
-- ร่องหน      
-- =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

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

-- 🔥 ตัวนี้เอาไปใช้กับ Toggle
function applyInvisible(state)
    setInvisible(state)
end

-- setup ครั้งแรก
setupCharacter()

-- ระบบล่องหน (ของเดิม 100%)
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

-- กันตายแล้วพัง
player.CharacterAdded:Connect(function()
    invisible = false
    setupCharacter()
end)

-- =========================
-- UI
-- =========================
Home:AddDiscordInvite({
Name = "Kuo Hub",
Description = "Join server",
Logo = "rbxassetid://103308551113442",
Invite = "https://discord.gg/Apn2j9Fez",
})

Home:Toggle({
    Title="God Mode",
    Desc="อมตะ (รีเลือดตลอด)",
    Callback=function(v)
        godmode = v
    end
})

Home:Toggle({
    Title="Fly",
    Desc="บิน",
    Callback=function(v)
        setFly(v)
    end
})

Home:Toggle({
    Title="Noclip",
    Desc="เดินทะลุ",
    Callback=function(v)
        noclip = v
    end
})

Home:Toggle({
    Title="Infinite Jump",
    Desc="กระโดดไม่จำกัด",
    Callback=function(v)
        infjump = v
    end
})

Home:Toggle({
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
        local char = getChar()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v
        end
    end
})


Home:AddSlider({
    Name = "Adjust flight speed",
    Min = 16,
    Max = 200,
    Default = 60,
    Callback = function(v)
        speed = v
    end
})

-- KEY
UIS.InputBegan:Connect(function(i,g)
    if not g and i.KeyCode == Enum.KeyCode.F then
        setFly(not flying)
    end
end)
-- =========================
-- WARNING GUI
-- =========================
local TweenService =
    game:GetService("TweenService")

local CoreGui =
    game:GetService("CoreGui")

pcall(function()
    CoreGui:FindFirstChild("Kuo Hub"):Destroy()
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Kuo Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- =========================
-- MAIN
-- =========================
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.AnchorPoint = Vector2.new(0.5,0)
Main.Position = UDim2.new(0.5,0,-0.3,0)
Main.Size = UDim2.new(0,420,0,145)
Main.BackgroundColor3 =
    Color3.fromRGB(15,15,15)
Main.BorderSizePixel = 0

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0,20)

-- Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Parent = Main
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(255,170,0)

-- Glow
local Glow = Instance.new("ImageLabel")
Glow.Parent = Main
Glow.BackgroundTransparency = 1
Glow.Size = UDim2.new(1,50,1,50)
Glow.Position = UDim2.new(0,-25,0,-25)
Glow.Image = "rbxassetid://5028857084"
Glow.ImageTransparency = 0.35
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(24,24,276,276)
Glow.ImageColor3 =
    Color3.fromRGB(255,170,0)

-- =========================
-- ICON
-- =========================
local Icon = Instance.new("TextLabel")
Icon.Parent = Main
Icon.BackgroundTransparency = 1
Icon.Position = UDim2.new(0,14,0,8)
Icon.Size = UDim2.new(0,40,0,40)
Icon.Font = Enum.Font.GothamBold
Icon.Text = "⚠️"
Icon.TextSize = 28

-- =========================
-- TITLE
-- =========================
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,55,0,10)
Title.Size = UDim2.new(1,-65,0,30)
Title.Font = Enum.Font.GothamBold
Title.Text = "DELTA DETECT WARNING"
Title.TextSize = 24
Title.TextColor3 =
    Color3.fromRGB(255,255,255)
Title.TextXAlignment =
    Enum.TextXAlignment.Left

-- =========================
-- MESSAGE
-- =========================
local Desc = Instance.new("TextLabel")
Desc.Parent = Main
Desc.BackgroundTransparency = 1
Desc.Position = UDim2.new(0,18,0,48)
Desc.Size = UDim2.new(1,-36,0,70)
Desc.Font = Enum.Font.Gotham
Desc.TextWrapped = true
Desc.TextYAlignment =
    Enum.TextYAlignment.Top
Desc.TextXAlignment =
    Enum.TextXAlignment.Left
Desc.TextSize = 15

Desc.Text =
"⚠️ ตัวรัน Delta โดน Detect (โดนตรวจจับ)\n\n" ..
"ตอนนี้มีหลายคนโดนเตือนหรือโดนแบน\n" ..
"ใครยังไม่โดน แนะนำให้งดใช้ตัวรันหลัก\n" ..
"หรือใช้ในไอดีสำรองไปก่อน"

Desc.TextColor3 =
    Color3.fromRGB(220,220,220)

-- =========================
-- BAR
-- =========================
local BarBG = Instance.new("Frame")
BarBG.Parent = Main
BarBG.Position = UDim2.new(0,18,1,-16)
BarBG.Size = UDim2.new(1,-36,0,6)
BarBG.BackgroundColor3 =
    Color3.fromRGB(35,35,35)
BarBG.BorderSizePixel = 0

Instance.new("UICorner", BarBG).CornerRadius =
    UDim.new(1,0)

local Bar = Instance.new("Frame")
Bar.Parent = BarBG
Bar.Size = UDim2.new(0,0,1,0)
Bar.BackgroundColor3 =
    Color3.fromRGB(255,170,0)
Bar.BorderSizePixel = 0

Instance.new("UICorner", Bar).CornerRadius =
    UDim.new(1,0)

-- =========================
-- ANIMATION
-- =========================

TweenService:Create(
    Main,
    TweenInfo.new(
        0.45,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    ),
    {
        Position = UDim2.new(0.5,0,0.04,0)
    }
):Play()

TweenService:Create(
    Bar,
    TweenInfo.new(7),
    {
        Size = UDim2.new(1,0,1,0)
    }
):Play()

-- Glow Pulse
task.spawn(function()

    while Main.Parent do

        TweenService:Create(
            Glow,
            TweenInfo.new(
                1,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                ImageTransparency = 0.55
            }
        ):Play()

        task.wait(1)

        TweenService:Create(
            Glow,
            TweenInfo.new(
                1,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                ImageTransparency = 0.3
            }
        ):Play()

        task.wait(1)
    end
end)

-- =========================
-- REMOVE
-- =========================
task.delay(7.2,function()

    TweenService:Create(
        Main,
        TweenInfo.new(
            0.4,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        ),
        {
            Position = UDim2.new(0.5,0,-0.3,0),
            BackgroundTransparency = 1
        }
    ):Play()

    task.wait(0.45)

    ScreenGui:Destroy()

end)
