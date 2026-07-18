repeat task.wait() until game:IsLoaded()

local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/ITKuo/refs/heads/main/KUOHUBUI.lua"))()

Window:MakeWindow({
    Title = "Kuo Hub [Beta-Blox Fruits]",
})

Window:AddMinimizeButton({
    Button = {
        Image = "rbxassetid://126460540157931",
        BackgroundTransparency = 0
    },
    Corner = {
        CornerRadius = UDim.new(35,1)
    },
})

--// =========================
--// TAB
--// =========================

local Home = Window:Tab("Home")

Home:Section("Main")

local farm_level = false

--// =========================
--// SERVICES
--// =========================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Module = {}
Module.__index = Module

local SkillDB = {}

--// =========================
--// NPC LIST
--// =========================

Module.NPCList = {
    ["BanditQuest1"] = "Bandit Quest Giver",
    ["JungleQuest"] = "Adventurer",
    ["BuggyQuest1"] = "Pirate Adventurer",
    ["DesertQuest"] = "Desert Adventurer",
    ["SnowQuest"] = "Villager",
    ["Area1Quest"] = "Area 1 Quest Giver",
    ["Area2Quest"] = "Area 2 Quest Giver",
    ["ZombieQuest"] = "Graveyard Quest Giver",
    ["IceSideQuest"] = "Ice Quest Giver",
    ["FireSideQuest"] = "Fire Quest Giver",
    ["PiratePortQuest"] = "Pirate Port Quest Giver",
    ["CakeQuest1"] = "Cake Quest Giver 1",
    ["CakeQuest2"] = "Cake Quest Giver 2",
    ["ChocQuest1"] = "Chocolate Quest Giver 1",
    ["ChocQuest2"] = "Chocolate Quest Giver 2"
}

--// =========================
--// QUESTS
--// =========================

Module.Quests = {
    {1,9,"BanditQuest1",1,"Bandit"},
    {10,14,"BanditQuest1",2,"Monkey"},
    {15,29,"JungleQuest",1,"Gorilla"},
    {30,39,"JungleQuest",2,"Gorilla"},
    {40,59,"BuggyQuest1",1,"Pirate"},
    {60,74,"BuggyQuest1",2,"Brute"},
    {75,89,"DesertQuest",1,"Desert Bandit"},
    {90,99,"DesertQuest",2,"Desert Officer"},
    {100,119,"SnowQuest",1,"Snow Bandit"},
    {120,149,"SnowQuest",2,"Snowman"},
    {700,724,"Area1Quest",1,"Raider"},
    {725,774,"Area1Quest",2,"Mercenary"},
    {775,799,"Area2Quest",1,"Swan Pirate"},
    {800,874,"Area2Quest",2,"Factory Staff"},
    {950,999,"ZombieQuest",1,"Zombie"},
    {1000,1049,"ZombieQuest",2,"Vampire"},
    {1150,1199,"IceSideQuest",1,"Lab Subordinate"},
    {1200,1249,"IceSideQuest",2,"Horned Warrior"},
    {1250,1299,"FireSideQuest",1,"Magma Ninja"},
    {1300,1349,"FireSideQuest",2,"Lava Pirate"},
    {1500,1524,"PiratePortQuest",1,"Pirate Millionaire"},
    {1525,1574,"PiratePortQuest",2,"Pistol Billionaire"},
    {2350,2399,"CakeQuest1",1,"Cake Guard"},
    {2400,2449,"CakeQuest1",2,"Baking Staff"},
    {2450,2499,"CakeQuest2",1,"Head Baker"},
    {2500,2549,"CakeQuest2",2,"Cake Guard"},
    {2550,2599,"ChocQuest1",1,"Cocoa Warrior"},
    {2600,2649,"ChocQuest1",2,"Chocolate Bar Battler"},
    {2650,2699,"ChocQuest2",1,"Sweet Thief"},
    {2700,2749,"ChocQuest2",2,"Candy Rebel"},
}

--// =========================
--// FUNCTIONS
--// =========================

function Module:GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

function Module:GetHumanoid()
    return self:GetCharacter():WaitForChild("Humanoid")
end

function Module:GetHRP()
    return self:GetCharacter():WaitForChild("HumanoidRootPart")
end

function Module:GetLevel()
    return Player.Data.Level.Value
end

function Module:IsAlive(Char)
    local Hum = Char and Char:FindFirstChild("Humanoid")
    return Hum and Hum.Health > 0
end

function Module:GetQuest()
    local Level = self:GetLevel()

    for _,v in ipairs(self.Quests) do
        if Level >= v[1] and Level <= v[2] then
            return {
                QuestName = v[3],
                QuestLevel = v[4],
                Mob = v[5]
            }
        end
    end
end

function Module:HasQuest()
    local Main = Player.PlayerGui:FindFirstChild("Main")
    local Quest = Main and Main:FindFirstChild("Quest")

    return Quest and Quest.Visible
end

function Module:FindNPC(QuestName)
    local NPCName = self.NPCList[QuestName]

    if not NPCName then
        return
    end

    for _,v in ipairs(workspace.NPCs:GetChildren()) do
        if v.Name == NPCName
        and v:FindFirstChild("HumanoidRootPart") then

            return v
        end
    end
end

function Module:Tween(CF)
    local HRP = self:GetHRP()

    local Tween = TweenService:Create(
        HRP,
        TweenInfo.new(
            (HRP.Position - CF.Position).Magnitude / 250,
            Enum.EasingStyle.Linear
        ),
        {CFrame = CF}
    )

    Tween:Play()
    Tween.Completed:Wait()
end

function Module:StartQuest(Data)
    if self:HasQuest() then
        return
    end

    local NPC = self:FindNPC(Data.QuestName)

    if NPC then
        self:Tween(
            NPC.HumanoidRootPart.CFrame
            * CFrame.new(0,3,0)
        )

        task.wait(0.5)
    end

    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer(
            "StartQuest",
            Data.QuestName,
            Data.QuestLevel
        )
    end)
end

function Module:GetEnemy(Name)
    for _,Enemy in ipairs(workspace.Enemies:GetChildren()) do

        if Enemy.Name == Name
        and Enemy:FindFirstChild("Humanoid")
        and Enemy.Humanoid.Health > 0 then

            return Enemy
        end
    end
end

function Module:EquipWeapon()
    local Character = self:GetCharacter()

    local Tool = Character:FindFirstChildOfClass("Tool")

    if Tool then
        return
    end

    for _,v in ipairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            self:GetHumanoid():EquipTool(v)
            break
        end
    end
end

function Module:Attack()
    local Tool = self:GetCharacter():FindFirstChildOfClass("Tool")

    if Tool then
        Tool:Activate()
    end
end

function Module:UseSkills()

    for _,Key in ipairs({"Z","X","C","V"}) do

        if not SkillDB[Key] then

            SkillDB[Key] = true

            VirtualInputManager:SendKeyEvent(
                true,
                Key,
                false,
                game
            )

            VirtualInputManager:SendKeyEvent(
                false,
                Key,
                false,
                game
            )

            task.spawn(function()
                task.wait(0.5)
                SkillDB[Key] = nil
            end)
        end
    end
end

function Module:BringMobs(Name,CF)

    for _,Enemy in ipairs(workspace.Enemies:GetChildren()) do

        if Enemy.Name == Name
        and Enemy:FindFirstChild("HumanoidRootPart")
        and Enemy:FindFirstChild("Humanoid")
        and Enemy.Humanoid.Health > 0 then

            local HRP = Enemy.HumanoidRootPart

            HRP.CFrame = CF
            HRP.CanCollide = false
            HRP.Size = Vector3.new(25,25,25)

            Enemy.Humanoid.WalkSpeed = 0
            Enemy.Humanoid:ChangeState(14)
        end
    end
end

function Module:KillEnemy(Enemy)

    local HRP = Enemy:FindFirstChild("HumanoidRootPart")

    if not HRP then
        return
    end

    repeat
        task.wait()

        local Pos = HRP.Position

self:GetHRP().CFrame = CFrame.new(
    Pos.X,
    Pos.Y + 15,
    Pos.Z
)

        self:EquipWeapon()
        self:UseSkills()
        self:Attack()

        self:BringMobs(
            Enemy.Name,
            HRP.CFrame
        )

    until not Enemy.Parent
    or Enemy.Humanoid.Health <= 0
    or not farm_level
end

--// =========================
--// AUTO FARM
--// =========================

task.spawn(function()

    while task.wait() do

        if not farm_level then
            continue
        end

        local Quest = Module:GetQuest()

        if not Quest then
            continue
        end

        Module:StartQuest(Quest)

        local Enemy = Module:GetEnemy(Quest.Mob)

        if Enemy then
            Module:KillEnemy(Enemy)
        end
    end
end)

--// =========================
--// DISCORD
--// =========================

Home:AddDiscordInvite({
    Name = "Kuo Hub",
    Description = "Join server",
    Logo = "rbxassetid://126460540157931",
    Invite = "https://discord.gg/Apn2j9Fez",
})

Home:Toggle({
    Title = "Auto Farm Level",
    Desc = "ออโต้ฟาร์มเลเวล",
    Callback = function(v)
        farm_level = v
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

