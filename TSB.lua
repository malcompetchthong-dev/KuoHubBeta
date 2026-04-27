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
