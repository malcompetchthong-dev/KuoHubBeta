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

--========================
-- FEEDBACK TAB
--========================

local Feedback = Window:Tab("📝 Feedback")

--========================
-- SERVICES
--========================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local WEBHOOK = "https://discord.com/api/webhooks/1527850015211389108/Is3vaQ_-VngplDfF0D3Xgp70RC-kDQ4TpddG9Ed3Q1ZiICMhviPCAZkhhv1VeRse9T5r"

local req =
    (syn and syn.request) or
    (http and http.request) or
    http_request or
    (fluxus and fluxus.request) or
    request

--========================
-- GAME NAME
--========================
local function getGame()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)

    return ok and info.Name or ("Place "..game.PlaceId)
end

--========================
-- SEND FEEDBACK
--========================
local function sendFeedback(message)

    if not req then
        return false
    end

    local data = {
        embeds = {{
            title = "📩 New Feedback",
            color = 0x8A2BE2,

            description =
                "👤 **Player :** "..player.Name..
                "\n🆔 **UserId :** "..player.UserId..
                "\n🌍 **Place :** "..getGame()..
                "\n\n💬 **Message**"..
                "\n-----------------------"..
                "\n"..message..
                "\n-----------------------"..
                "\n\n🕒 "..os.date("%d/%m/%Y %I:%M %p"),

            footer = {
                text = "Kuo Hub Feedback System"
            }
        }}
    }

    local ok = pcall(function()
        req({
            Url = WEBHOOK,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)

    return ok
end

--========================
-- UI
--========================

local FeedbackMessage = ""
local LastSend = 0

Feedback:Section("📝 Feedback")

Feedback:AddInput({
    Title = "Feedback",
    Placeholder = "Write your feedback here...",
    Callback = function(text)
        FeedbackMessage = text
    end
})

Feedback:Button({
    Title = "📨 Send Feedback",
    Callback = function()

        if FeedbackMessage:gsub("%s+","") == "" then
            Window:Notify({
                Title = "Feedback",
                Desc = "⚠ กรุณาพิมพ์ข้อความก่อน",
                Time = 3
            })
            return
        end

        if tick() - LastSend < 5 then
            Window:Notify({
                Title = "Feedback",
                Desc = "⌛ กรุณารอ 5 วินาทีก่อนส่งอีกครั้ง",
                Time = 3
            })
            return
        end

        LastSend = tick()

        if sendFeedback(FeedbackMessage) then
            Window:Notify({
                Title = "Feedback",
                Desc = "✅ ส่งข้อเสนอแนะเรียบร้อย",
                Time = 3
            })
            FeedbackMessage = ""
        else
            Window:Notify({
                Title = "Feedback",
                Desc = "❌ ส่งไม่สำเร็จ",
                Time = 3
            })
        end

    end
})


-- KEY
UIS.InputBegan:Connect(function(i,g)
    if not g and i.KeyCode == Enum.KeyCode.F then
        setFly(not flying)
    end
end)
