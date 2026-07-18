local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/ITKuo/refs/heads/main/KUOHUBUI.lua"))()

Window:MakeWindow({
Title = "Kuo Hub [Beta-TSB]",
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

--// CHARACTER
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

Home:AddDiscordInvite({
Name = "Kuo Hub",
Description = "Join server",
Logo = "rbxassetid://126460540157931",
Invite = "https://discord.gg/Apn2j9Fez",
})

getgenv().SpeedValue = 16

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function getChar()
return lp.Character or lp.CharacterAdded:Wait()
end

local function applySpeed(v)
local char = getChar()
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
hum.WalkSpeed = v
end
end
--========================
-- SLIDER
--========================
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

--========================
-- MAIN MOVEMENT LOOP (FIXED)
--========================
task.spawn(function()
while task.wait(0.05) do
local char = lp.Character
if char then
local hrp = char:FindFirstChild("HumanoidRootPart")
local hum = char:FindFirstChildOfClass("Humanoid")

if hrp and hum then
local dir = hum.MoveDirection

if dir.Magnitude > 0 then
hrp.AssemblyLinearVelocity = dir * getgenv().SpeedValue
else
-- 🔥 stop clean (กันลื่น)
hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
end
end
end

end

end)

--========================
-- RESPWAN FIX
--========================
lp.CharacterAdded:Connect(function()
task.wait(0.5)
applySpeed(getgenv().SpeedValue)
end)
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
