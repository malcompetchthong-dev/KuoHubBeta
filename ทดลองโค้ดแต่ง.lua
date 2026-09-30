local KuoHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/ITKuo/refs/heads/main/Librarykuohub-BETA.lua"))()

local Window = KuoHub:MakeWindow({
    Title = "Kuo Hub | MM2",
})

Window:AddMinimizeButton({
    Button = {
        Image = "rbxassetid://126460540157931",
        BackgroundTransparency = 0
    },
    Position = UDim2.new(0,20,0.5,-25)
})
  
local Home = Window:Tab("Home")  
  
local Combat = Window:MakeTab({"Combat","sword"})  

local Info = Window:MakeTab({"System","history"})
  
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
  
--// SETTINGS    
local speed = 60
local walkSpeed = 16
local ESP_ENABLED = false  
local AUTO_WARP_GUN = false  
local INFINITE_JUMP = false  
local AIMLOCK = false  
local LOCK_TARGET = nil  
local NOCLIP = false  
local AUTO_SHOOT = false  
local AUTO_KNIFE = false  
local KILL_AURA = false    
local MAX_DISTANCE = 1000  
local AUTO_COIN_COLLECT = false  
local CHAT_ANNOUNCE = false  
local Anti_Pling = false  
local AUTO_PUSH = false  
local AUTO_LEECH_MURDER = false  
local LOOP_DELAY = 0.1  
local lastKnifeEquip = 0  
local lastGunEquip = 0  
local gotGunThisRound = false  
local wasInvisibleBeforeWarp = false  
local SAFE_DISTANCE_GUN = 2  
local GunESP = false  
local Shot_AURA = false  
  
-- =========================  
-- FLY  
-- =========================  
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local speed = 60
local TOGGLE_KEY = Enum.KeyCode.F

--==================================================
-- VARIABLES
--==================================================

local Character
local Humanoid
local Root
local Animator
local AnimateScript

local Flying = false

local BodyVelocity
local BodyGyro
local IdleTrack

local PCKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Up = false,
	Down = false
}

--==================================================
-- CHARACTER SETUP
--==================================================

local function SetupCharacter()
	Character = Player.Character or Player.CharacterAdded:Wait()

	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")

	Animator = Humanoid:FindFirstChildOfClass("Animator")

	if not Animator then
		Animator = Instance.new("Animator")
		Animator.Parent = Humanoid
	end

	AnimateScript = Character:FindFirstChild("Animate")
end

SetupCharacter()

Player.CharacterAdded:Connect(function()
	Flying = false

	if BodyVelocity then
		BodyVelocity:Destroy()
		BodyVelocity = nil
	end

	if BodyGyro then
		BodyGyro:Destroy()
		BodyGyro = nil
	end

	if IdleTrack then
		IdleTrack:Stop()
		IdleTrack:Destroy()
		IdleTrack = nil
	end

	task.wait(0.2)
	SetupCharacter()
end)

--==================================================
-- STOP NORMAL ANIMATIONS
--==================================================

local function StopNormalAnimations()
	if not Animator then
		return
	end

	for _, Track in ipairs(Animator:GetPlayingAnimationTracks()) do
		Track:Stop(0.1)
	end
end

--==================================================
-- IDLE ANIMATION
--==================================================

local function StartIdleAnimation()
	if not Animator then
		return
	end

	StopNormalAnimations()

	local Animation = Instance.new("Animation")

	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation.AnimationId = "rbxassetid://507766666"
	else
		Animation.AnimationId = "rbxassetid://180435571"
	end

	IdleTrack = Animator:LoadAnimation(Animation)
	IdleTrack.Priority = Enum.AnimationPriority.Idle
	IdleTrack.Looped = true
	IdleTrack:Play(0.15)

	Animation:Destroy()
end

local function StopIdleAnimation()
	if IdleTrack then
		IdleTrack:Stop(0.15)
		IdleTrack:Destroy()
		IdleTrack = nil
	end
end

--==================================================
-- START FLY
--==================================================

local function StartFly()
	if Flying then
		return
	end

	if not Character or not Humanoid or not Root then
		return
	end

	Flying = true

	StopNormalAnimations()

	if AnimateScript then
		AnimateScript.Enabled = false
	end

	Humanoid.AutoRotate = false

	BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Name = "FlyVelocity"
	BodyVelocity.MaxForce = Vector3.new(
		math.huge,
		math.huge,
		math.huge
	)
	BodyVelocity.P = 50000
	BodyVelocity.Velocity = Vector3.zero
	BodyVelocity.Parent = Root

	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.Name = "FlyGyro"
	BodyGyro.MaxTorque = Vector3.new(
		math.huge,
		math.huge,
		math.huge
	)
	BodyGyro.P = 50000
	BodyGyro.D = 1000
	BodyGyro.CFrame = Root.CFrame
	BodyGyro.Parent = Root

	StartIdleAnimation()
end

--==================================================
-- STOP FLY
--==================================================

local function StopFly()
	if not Flying then
		return
	end

	Flying = false

	if BodyVelocity then
		BodyVelocity:Destroy()
		BodyVelocity = nil
	end

	if BodyGyro then
		BodyGyro:Destroy()
		BodyGyro = nil
	end

	StopIdleAnimation()

	if AnimateScript then
		AnimateScript.Enabled = true
	end

	Humanoid.AutoRotate = true

	Humanoid:ChangeState(
		Enum.HumanoidStateType.GettingUp
	)
end

--==================================================
-- SET FLY
--==================================================

function setFly(v)
	if v then
		StartFly()
	else
		StopFly()
	end
end

--==================================================
-- PC KEYBOARD
--==================================================

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end

	if Input.KeyCode == TOGGLE_KEY then
		setFly(not Flying)
		return
	end

	if Input.KeyCode == Enum.KeyCode.W then
		PCKeys.W = true

	elseif Input.KeyCode == Enum.KeyCode.A then
		PCKeys.A = true

	elseif Input.KeyCode == Enum.KeyCode.S then
		PCKeys.S = true

	elseif Input.KeyCode == Enum.KeyCode.D then
		PCKeys.D = true

	elseif Input.KeyCode == Enum.KeyCode.Space then
		PCKeys.Up = true

	elseif Input.KeyCode == Enum.KeyCode.LeftControl then
		PCKeys.Down = true
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.W then
		PCKeys.W = false

	elseif Input.KeyCode == Enum.KeyCode.A then
		PCKeys.A = false

	elseif Input.KeyCode == Enum.KeyCode.S then
		PCKeys.S = false

	elseif Input.KeyCode == Enum.KeyCode.D then
		PCKeys.D = false

	elseif Input.KeyCode == Enum.KeyCode.Space then
		PCKeys.Up = false

	elseif Input.KeyCode == Enum.KeyCode.LeftControl then
		PCKeys.Down = false
	end
end)

--==================================================
-- PC DIRECTION
--==================================================

local function GetPCDirection(Camera)
	local Direction = Vector3.zero

	local Forward = Camera.CFrame.LookVector
	local Right = Camera.CFrame.RightVector

	if PCKeys.W then
		Direction += Forward
	end

	if PCKeys.S then
		Direction -= Forward
	end

	if PCKeys.D then
		Direction += Right
	end

	if PCKeys.A then
		Direction -= Right
	end

	if PCKeys.Up then
		Direction += Vector3.new(0, 1, 0)
	end

	if PCKeys.Down then
		Direction -= Vector3.new(0, 1, 0)
	end

	if Direction.Magnitude > 1 then
		Direction = Direction.Unit
	end

	return Direction
end

--==================================================
-- MOBILE DIRECTION
--==================================================

local function GetMobileDirection(Camera)
	local Move = Humanoid.MoveDirection

	if Move.Magnitude <= 0.01 then
		return Vector3.zero
	end

	local Look = Camera.CFrame.LookVector
	local Right = Camera.CFrame.RightVector

	local FlatForward = Vector3.new(
		Look.X,
		0,
		Look.Z
	)

	local FlatRight = Vector3.new(
		Right.X,
		0,
		Right.Z
	)

	if FlatForward.Magnitude > 0 then
		FlatForward = FlatForward.Unit
	end

	if FlatRight.Magnitude > 0 then
		FlatRight = FlatRight.Unit
	end

	local ForwardAmount = Move:Dot(FlatForward)
	local RightAmount = Move:Dot(FlatRight)

	local Direction =
		Look * ForwardAmount
		+
		FlatRight * RightAmount

	if Direction.Magnitude > 1 then
		Direction = Direction.Unit
	end

	return Direction
end

--==================================================
-- MAIN FLY LOOP
--==================================================

RunService.RenderStepped:Connect(function()
	if not Flying then
		return
	end

	if not Character
		or not Humanoid
		or not Root
		or not BodyVelocity
		or not BodyGyro then
		return
	end

	local Camera = workspace.CurrentCamera

	local Direction

	-- PC
	if UserInputService.KeyboardEnabled then
		Direction = GetPCDirection(Camera)

	-- Mobile
	else
		Direction = GetMobileDirection(Camera)
	end

	--================================================
	-- SPEED
	--================================================

	BodyVelocity.Velocity = Direction * speed

	--================================================
	-- ROTATION
	--================================================

	if Direction.Magnitude > 0.01 then

		BodyGyro.CFrame = CFrame.lookAt(
			Root.Position,
			Root.Position + Direction.Unit
		)

	else

		local Look = Camera.CFrame.LookVector

		BodyGyro.CFrame = CFrame.lookAt(
			Root.Position,
			Root.Position + Look
		)
	end

	--================================================
	-- KEEP IDLE
	--================================================

	if IdleTrack and not IdleTrack.IsPlaying then
		IdleTrack:Play(0.1)
	end
end)
  
-- =========================  
-- CLEAN OLD CONNECTION  
-- =========================  
getgenv().KuoESPConnections =  
getgenv().KuoESPConnections or {}  
  
for _,c in pairs(  
getgenv().KuoESPConnections  
) do  
pcall(function()  
c:Disconnect()  
end)  
end  
  
table.clear(getgenv().KuoESPConnections)  
  
-- =========================  
-- SERVICES  
-- =========================  
local Players =  
game:GetService("Players")  
  
local RunService =  
game:GetService("RunService")  
  
local Camera =  
workspace.CurrentCamera  
  
local player =  
Players.LocalPlayer  
  
ESP_ENABLED =  
ESP_ENABLED or false  
  
-- =========================  
-- SETTINGS  
-- =========================  
local ESP_CONFIG = {  
  
MaxDistance = math.huge,    
  
ShowNames = true,    
ShowDistance = true,    
ShowTracer = true,    
ShowHealth = true,    
  
-- 🔥 PLAYER COLOR    
Highlight = true,    
  
FillTransparency = 0.55,    
OutlineTransparency = 0,  
  
}  
  
-- =========================  
-- ROLE COLORS  
-- =========================  
local ROLE_COLORS = {  
  
Murderer =    
    Color3.fromRGB(255,0,0),    
  
Sheriff =    
    Color3.fromRGB(0,170,255),    
  
Innocent =    
    Color3.fromRGB(0,255,120),  
  
}  
  
-- =========================  
-- ROLE CACHE  
-- =========================  
local RoleCache = {}  
  
-- =========================  
-- UPDATE ROLE  
-- =========================  
local function updateRole(plr)  
  
local role = "Innocent"    
  
local char =    
    plr.Character    
  
local bp =    
    plr:FindFirstChild("Backpack")    
  
local function checkContainer(container)    
  
    if not container then    
        return nil    
    end    
  
    for _,tool in ipairs(    
        container:GetChildren()    
    ) do    
  
        if tool:IsA("Tool") then    
  
            local name =    
                string.lower(tool.Name)    
  
            if name == "knife"    
            or name:find("knife") then    
  
                return "Murderer"    
            end    
  
            if name == "gun"    
            or name:find("gun")    
            or name:find("revolver") then    
  
                return "Sheriff"    
            end    
        end    
    end    
end    
  
local charRole =    
    checkContainer(char)    
  
if charRole then    
  
    role = charRole    
  
else    
  
    local bpRole =    
        checkContainer(bp)    
  
    if bpRole then    
        role = bpRole    
    end    
end    
  
RoleCache[plr] = role  
  
end  
  
-- =========================  
-- GET ROLE  
-- =========================  
local function getRole(plr)  
  
return RoleCache[plr]    
    or "Innocent"  
  
end  
  
-- =========================  
-- ESP CACHE  
-- =========================  
local ESPCache = {}  
  
-- =========================  
-- CREATE DRAWINGS  
-- =========================  
local function createDrawings(plr)  
  
if ESPCache[plr] then    
    return ESPCache[plr]    
end    
  
local cache = {}    
  
-- 🏷️ NAME    
cache.Name =    
    Drawing.new("Text")    
  
cache.Name.Center = true    
cache.Name.Size = 16    
cache.Name.Outline = true    
cache.Name.Font = 2    
  
-- 📏 DISTANCE    
cache.Distance =    
    Drawing.new("Text")    
  
cache.Distance.Center = true    
cache.Distance.Size = 13    
cache.Distance.Outline = true    
cache.Distance.Font = 2    
  
-- ❤️ HEALTH    
cache.Health =    
    Drawing.new("Text")    
  
cache.Health.Center = true    
cache.Health.Size = 13    
cache.Health.Outline = true    
cache.Health.Font = 2    
  
-- 👀 TRACER    
cache.Tracer =    
    Drawing.new("Line")    
  
cache.Tracer.Thickness = 1.2    
  
ESPCache[plr] = cache    
  
return cache  
  
end  
  
-- =========================  
-- HIDE DRAWINGS  
-- =========================  
local function hideDrawings(cache)  
  
if not cache then    
    return    
end    
  
for _,v in pairs(cache) do    
    v.Visible = false    
end  
  
end  
  
-- =========================  
-- REMOVE HIGHLIGHT  
-- =========================  
local function removeHighlight(char)  
  
if not char then    
    return    
end    
  
local hl =    
    char:FindFirstChild("KuoHL")    
  
if hl then    
    hl:Destroy()    
end  
  
end  
  
-- =========================  
-- CREATE HIGHLIGHT  
-- =========================  
local function createHighlight(  
char,  
color  
)  
  
if not ESP_CONFIG.Highlight then    
    return    
end    
  
local hl =    
    char:FindFirstChild("KuoHL")    
  
if not hl then    
  
    hl = Instance.new("Highlight")    
  
    hl.Name = "KuoHL"    
  
    hl.DepthMode =    
        Enum.HighlightDepthMode.AlwaysOnTop    
  
    hl.Parent = char    
end    
  
hl.FillTransparency =    
    ESP_CONFIG.FillTransparency    
  
hl.OutlineTransparency =    
    ESP_CONFIG.OutlineTransparency    
  
hl.FillColor = color    
hl.OutlineColor = color  
  
end  
  
-- =========================  
-- REMOVE ESP  
-- =========================  
local function removeESP(plr)  
  
local cache =    
    ESPCache[plr]    
  
if cache then    
  
    hideDrawings(cache)    
  
    for _,obj in pairs(cache) do    
        pcall(function()    
            obj:Remove()    
        end)    
    end    
end    
  
ESPCache[plr] = nil    
  
if plr.Character then    
    removeHighlight(plr.Character)    
end  
  
end  
  
-- =========================  
-- UPDATE ESP  
-- =========================  
local function updateESP(plr)  
  
if plr == player then    
    return    
end    
  
local char =    
    plr.Character    
  
if not char then    
    removeESP(plr)    
    return    
end    
  
local root =    
    char:FindFirstChild(    
        "HumanoidRootPart"    
    )    
  
local humanoid =    
    char:FindFirstChild(    
        "Humanoid"    
    )    
  
if not root    
or not humanoid    
or humanoid.Health <= 0 then    
  
    removeESP(plr)    
    return    
end    
  
-- 🔥 ESP OFF = ลบทุกอย่าง    
if not ESP_ENABLED then    
  
    local cache =    
        ESPCache[plr]    
  
    if cache then    
        hideDrawings(cache)    
    end    
  
    removeHighlight(char)    
  
    return    
end    
  
local pos,visible =    
    Camera:WorldToViewportPoint(    
        root.Position    
    )    
  
local cache =    
    createDrawings(plr)    
  
if not visible then    
  
    hideDrawings(cache)    
  
    removeHighlight(char)    
  
    return    
end    
  
local role =    
    getRole(plr)    
  
local color =    
    ROLE_COLORS[role]    
  
local distance =    
    (root.Position    
    - Camera.CFrame.Position).Magnitude    
  
-- 🔥 PLAYER COLOR    
createHighlight(char, color)    
  
-- =========================    
-- NAME    
-- =========================    
cache.Name.Visible =    
    ESP_CONFIG.ShowNames    
  
cache.Name.Text =    
    "["..role.."] "..plr.Name    
  
cache.Name.Position =    
    Vector2.new(    
        pos.X,    
        pos.Y - 35    
    )    
  
cache.Name.Color =    
    color    
  
-- =========================    
-- DISTANCE    
-- =========================    
cache.Distance.Visible =    
    ESP_CONFIG.ShowDistance    
  
cache.Distance.Text =    
    math.floor(distance)    
    .."m"    
  
cache.Distance.Position =    
    Vector2.new(    
        pos.X,    
        pos.Y + 18    
    )    
  
cache.Distance.Color =    
    color    
  
-- =========================    
-- HEALTH    
-- =========================    
cache.Health.Visible =    
    ESP_CONFIG.ShowHealth    
  
cache.Health.Text =    
    math.floor(humanoid.Health)    
    .." HP"    
  
cache.Health.Position =    
    Vector2.new(    
        pos.X,    
        pos.Y + 34    
    )    
  
cache.Health.Color =    
    Color3.fromRGB(0,255,0)    
  
-- =========================    
-- TRACER    
-- =========================    
cache.Tracer.Visible =    
    ESP_CONFIG.ShowTracer    
  
cache.Tracer.From =    
    Vector2.new(    
        Camera.ViewportSize.X / 2,    
        Camera.ViewportSize.Y    
    )    
  
cache.Tracer.To =    
    Vector2.new(    
        pos.X,    
        pos.Y    
    )    
  
cache.Tracer.Color =    
    color  
  
end  
  
-- =========================  
-- PLAYER SETUP  
-- =========================  
local function setupPlayer(plr)  
  
if plr == player then    
    return    
end    
  
updateRole(plr)    
  
-- CHARACTER ADDED    
table.insert(    
    getgenv().KuoESPConnections,    
  
    plr.CharacterAdded:Connect(    
        function(char)    
  
            task.wait(0.2)    
  
            updateRole(plr)    
  
            char.ChildAdded:Connect(    
                function(obj)    
  
                    if obj:IsA("Tool") then    
                        updateRole(plr)    
                    end    
                end    
            )    
  
            char.ChildRemoved:Connect(    
                function(obj)    
  
                    if obj:IsA("Tool") then    
                        updateRole(plr)    
                    end    
                end    
            )    
  
            if ESP_ENABLED then    
                updateESP(plr)    
            end    
        end    
    )    
)    
  
-- CHARACTER REMOVING    
table.insert(    
    getgenv().KuoESPConnections,    
  
    plr.CharacterRemoving:Connect(    
        function()    
            removeESP(plr)    
        end    
    )    
)    
  
-- BACKPACK    
local bp =    
    plr:WaitForChild("Backpack")    
  
table.insert(    
    getgenv().KuoESPConnections,    
  
    bp.ChildAdded:Connect(    
        function(obj)    
  
            if obj:IsA("Tool") then    
                updateRole(plr)    
            end    
        end    
    )    
)    
  
table.insert(    
    getgenv().KuoESPConnections,    
  
    bp.ChildRemoved:Connect(    
        function(obj)    
  
            if obj:IsA("Tool") then    
                updateRole(plr)    
            end    
        end    
    )    
)  
  
end  
  
-- =========================  
-- INIT PLAYERS  
-- =========================  
for _,plr in ipairs(  
Players:GetPlayers()  
) do  
setupPlayer(plr)  
end  
  
-- PLAYER ADDED  
table.insert(  
getgenv().KuoESPConnections,  
  
Players.PlayerAdded:Connect(    
    setupPlayer    
)  
  
)  
  
-- PLAYER REMOVED  
table.insert(  
getgenv().KuoESPConnections,  
  
Players.PlayerRemoving:Connect(    
    removeESP    
)  
  
)  
  
-- =========================  
-- MAIN LOOP  
-- =========================  
table.insert(  
getgenv().KuoESPConnections,  
  
RunService.RenderStepped:Connect(    
    function()    
  
        for _,plr in ipairs(    
            Players:GetPlayers()    
        ) do    
  
            pcall(function()    
  
                updateRole(plr)    
                updateESP(plr)    
  
            end)    
        end    
    end    
)  
  
)  
-- =========================  
-- 🔫 GUN ESP  
-- =========================  
  
local GunHL = nil  
  
local function removeGunESP()  
if GunHL then  
GunHL:Destroy()  
GunHL = nil  
end  
end  
  
local function createGunESP(gun)  
  
removeGunESP()    
  
local part =    
    gun:IsA("BasePart") and gun    
    or gun:FindFirstChildWhichIsA("BasePart", true)    
  
if not part then    
    return    
end    
  
GunHL = Instance.new("Highlight")    
GunHL.Name = "KuoGunESP"    
  
GunHL.FillColor = Color3.fromRGB(0,170,255)    
GunHL.OutlineColor = Color3.fromRGB(255,255,255)    
  
GunHL.FillTransparency = 0.2    
GunHL.OutlineTransparency = 0    
  
GunHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop    
GunHL.Adornee = gun    
GunHL.Parent = game.CoreGui  
  
end  
  
-- =========================  
-- 🔁 LOOP  
-- =========================  
task.spawn(function()  
  
while task.wait(0.2) do    
  
    if not GunESP then    
        removeGunESP()    
        continue    
    end    
  
    local gun =    
        workspace:FindFirstChild("GunDrop", true)    
        or workspace:FindFirstChild("Gun", true)    
  
    if gun then    
        createGunESP(gun)    
    else    
        removeGunESP()    
    end    
end  
  
end)  
  
-- =========================  
-- 🚀 AUTO WARP GUN  
-- =========================  
  
-- 🔍 หา Murderer  
local function getMurderer()  
for _, plr in ipairs(game.Players:GetPlayers()) do  
if plr ~= game.Players.LocalPlayer and plr.Character then  
if getRole(plr) == "Murderer" then  
return plr  
end  
end  
end  
end  
  
-- 🔍 เช็คปืนร่วงจริง  
local function isDroppedGun(gun)  
if not gun then return false end  
  
local parent = gun.Parent  
if not parent then return false end  
  
if parent:FindFirstChild("Humanoid") then return false end  
if parent:IsA("Backpack") then return false end  
  
return gun:IsDescendantOf(workspace)  
  
end  
  
-- 🧠 เช็คว่าปลอดภัยไหม  
local function isSafeToWarp(gunPart)  
local murderer = getMurderer()  
if not murderer or not murderer.Character then return true end  
  
local mRoot = murderer.Character:FindFirstChild("HumanoidRootPart")  
if not mRoot then return true end  
  
local dist = (mRoot.Position - gunPart.Position).Magnitude  
  
-- ❌ ใกล้เกิน = อันตราย  
if dist < SAFE_DISTANCE_GUN then  
return false  
end  
  
return true  
  
end  
  
-- 🔁 LOOP  
task.spawn(function()  
while task.wait(0.2) do  
if not AUTO_WARP_GUN then continue end  
  
local player = game.Players.LocalPlayer  
local char = player.Character  
local hrp = char and char:FindFirstChild("HumanoidRootPart")  
if not hrp then continue end  
  
local gun = workspace:FindFirstChild("GunDrop", true)  
or workspace:FindFirstChild("Gun", true)  
  
if not isDroppedGun(gun) then  
gotGunThisRound = false  
continue  
end  
  
if gotGunThisRound then continue end  
  
local targetPart = gun:IsA("BasePart") and gun  
or gun:FindFirstChildWhichIsA("BasePart", true)  
  
if not targetPart then continue end  
  
-- 🧠 เช็คความปลอดภัย  
if not isSafeToWarp(targetPart) then  
continue -- ❌ ไม่วาร์ป  
end  
  
gotGunThisRound = true  
  
local oldPos = hrp.CFrame  
  
-- 👻 ปิด Invisible  
wasInvisibleBeforeWarp = invisible  
if wasInvisibleBeforeWarp then  
applyInvisible(false)  
task.wait(0.05)  
end  
  
-- 🚀 วาร์ป  
hrp.CFrame = targetPart.CFrame  
task.wait(0.15)  
  
-- 🔙 กลับ  
hrp.CFrame = oldPos  
  
-- 👻 เปิดกลับ  
if wasInvisibleBeforeWarp then  
task.wait(0.05)  
applyInvisible(true)  
end  
  
end  
  
end)  
  
-- =========================  
-- 🔫 AUTO GUN SYSTEM (FULL + 50/50 AIM)  
-- =========================  
  
-- 🔍 หา Murderer  
local function findMurderer()  
for _, plr in ipairs(Players:GetPlayers()) do  
if plr ~= player and plr.Character and getRole(plr) == "Murderer" then  
return plr  
end  
end  
end  
  
-- =========================  
-- 🎲 RANDOM PART (50% HEAD / 50% BODY)  
-- =========================  
local function getRandomPart50(targetChar)  
local head = targetChar:FindFirstChild("Head")  
  
-- 50% ยิงหัว  
if head and math.random() < 0.5 then  
return head  
end  
  
-- 50% ยิงส่วนอื่น  
local parts = {}  
for _, v in ipairs(targetChar:GetDescendants()) do  
if v:IsA("BasePart") and v.Name ~= "Head" then  
table.insert(parts, v)  
end  
end  
  
if #parts > 0 then  
return parts[math.random(1, #parts)]  
end  
  
return head  
  
end  
  
-- =========================  
-- 🎯 PREDICT AIM (50/50)  
-- =========================  
local function getLeadCFrame(targetChar, originPos)  
local part = getRandomPart50(targetChar)  
local root = targetChar:FindFirstChild("HumanoidRootPart")  
if not part or not root then return end  
  
local velocity = root.AssemblyLinearVelocity  
  
local distance = (part.Position - originPos).Magnitude  
local predictTime = math.clamp(distance / 200, 0.15, 0.35)  
  
local predictedPos = part.Position + (velocity * predictTime)  
  
-- ชดเชยแกน Y  
predictedPos = predictedPos + Vector3.new(0, math.clamp(velocity.Y * 0.1, -2, 2), 0)  
  
return CFrame.new(predictedPos)  
  
end  
  
-- =========================  
-- 🔫 AUTO EQUIP GUN  
-- =========================  
local lastGunEquip = 0  
  
local function equipGun()  
if tick() - lastGunEquip < 0.3 then return end  
lastGunEquip = tick()  
  
local char = player.Character  
local backpack = player:FindFirstChild("Backpack")  
  
if not char or not backpack then return end  
  
local gun = backpack:FindFirstChild("Gun")  
if gun then  
gun.Parent = char  
end  
  
end  
  
-- =========================  
-- 🔫 AUTO SHOOT LOOP  
-- =========================  
task.spawn(function()  
while task.wait(0.01) do  
if not AUTO_SHOOT then continue end  
  
local target = findMurderer()  
if not target or not target.Character then continue end  
  
-- 🔥 ถือปืนอัตโนมัติ  
equipGun()  
  
local char = player.Character  
local gun = char and char:FindFirstChild("Gun")  
  
-- ❗ ยังไม่ถือ = ไม่ยิง  
if not gun then continue end  
  
local shootEvent = gun:FindFirstChild("Shoot")  
local originPart = gun:FindFirstChild("Handle")  
  
if not shootEvent or not originPart then continue end  
  
local originCF = originPart.CFrame  
local targetCF = getLeadCFrame(target.Character, originPart.Position)  
  
if targetCF then  
pcall(function()  
shootEvent:FireServer(originCF, targetCF)  
end)  
end  
  
end  
  
end)  
  
-- =========================  
-- INFINITE JUMP  
-- =========================  
UIS.JumpRequest:Connect(function()  
if INFINITE_JUMP then  
local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")  
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end  
end  
end)  
  
-- =========================  
-- NOCLIP  
-- =========================  
RunService.Stepped:Connect(function()  
if NOCLIP then  
local char = player.Character  
if char then  
for _, v in ipairs(char:GetDescendants()) do  
if v:IsA("BasePart") then v.CanCollide = false end  
end  
end  
end  
end)  
  
-- =========================  
-- AIMLOCK  
-- =========================  
local function getMurdererRoot()  
for _, plr in ipairs(Players:GetPlayers()) do  
if plr ~= player and plr.Character and getRole(plr) == "Murderer" then  
return plr.Character:FindFirstChild("HumanoidRootPart")  
end  
end  
end  
  
RunService.RenderStepped:Connect(function()  
if AIMLOCK then  
if not LOCK_TARGET or not LOCK_TARGET.Parent then  
LOCK_TARGET = getMurdererRoot()  
end  
local cam = workspace.CurrentCamera  
if LOCK_TARGET then  
cam.CFrame = CFrame.new(cam.CFrame.Position, LOCK_TARGET.Position)  
end  
end  
end)  
  
-- =========================  
-- 🔪 AUTO KNIFE + AUTO EQUIP (FINAL FIX)  
-- =========================  
  
local Players = game:GetService("Players")  
local player = Players.LocalPlayer -- 🔥 แก้จาก LocalPlayers  
  
-- =========================  
-- 📦 GET CHARACTER  
-- =========================  
local function getChar()  
return player.Character or player.CharacterAdded:Wait()  
end  
  
local function getHRP()  
local char = getChar()  
return char and char:FindFirstChild("HumanoidRootPart")  
end  
  
-- =========================  
-- 🔥 AUTO EQUIP KNIFE  
-- =========================  
local function equipKnife()  
if tick() - lastKnifeEquip < 0.3 then return end  
lastKnifeEquip = tick()  
  
local char = getChar()  
local backpack = player:FindFirstChild("Backpack")  
  
if not char or not backpack then return end  
  
local knife = backpack:FindFirstChild("Knife")  
if knife then  
knife.Parent = char  
end  
  
end  
  
local function getKnife()  
local char = getChar()  
return char and char:FindFirstChild("Knife")  
end  
  
-- =========================  
-- 🔪 THROW KNIFE  
-- =========================  
local function throwKnife(enemyRoot)  
local knife = getKnife()  
if not knife or not enemyRoot then return end  
  
local events = knife:FindFirstChild("Events")  
local throw = events and events:FindFirstChild("KnifeThrown")  
if not throw then return end  
  
local myRoot = getHRP()  
if not myRoot then return end  
  
local distance = (myRoot.Position - enemyRoot.Position).Magnitude  
local prediction = math.clamp(distance / 200, 0.1, 0.3)  
  
local velocity = enemyRoot.AssemblyLinearVelocity  
local predictedPos = enemyRoot.Position + (velocity * prediction)  
  
throw:FireServer(  
CFrame.new(myRoot.Position),  
CFrame.new(predictedPos)  
)  
  
end  
  
-- =========================  
-- 🔪 STAB KNIFE  
-- =========================  
local function stabKnife(enemyRoot)  
local knife = getKnife()  
if not knife or not enemyRoot then return end  
  
local events = knife:FindFirstChild("Events")  
if not events then return end  
  
local handleTouched = events:FindFirstChild("HandleTouched")  
local stabbed = events:FindFirstChild("KnifeStabbed")  
  
if handleTouched then  
handleTouched:FireServer(enemyRoot)  
end  
  
if stabbed then  
stabbed:FireServer()  
end  
  
end  
  
-- =========================  
-- 🎯 FIND TARGET  
-- =========================  
local function getNearestEnemy()  
local hrp = getHRP()  
if not hrp then return nil end  
  
local closest = nil  
local distMin = MAX_DISTANCE  
  
for _, plr in pairs(Players:GetPlayers()) do  
if plr ~= player and plr.Character then  
local root = plr.Character:FindFirstChild("HumanoidRootPart")  
if root then  
local dist = (hrp.Position - root.Position).Magnitude  
if dist < distMin then  
distMin = dist  
closest = plr  
end  
end  
end  
end  
  
return closest  
  
end    
-- =========================  
-- 🔁 AUTO KNIFE LOOP (FIX)  
-- =========================  
task.spawn(function()  
while task.wait(0.01) do  
if not AUTO_KNIFE then continue end  
  
local target = getNearestEnemy()  
if not target or not target.Character then continue end  
  
local root = target.Character:FindFirstChild("HumanoidRootPart")  
if not root then continue end  
  
equipKnife()  
  
local knife = getKnife()  
if not knife then continue end -- ✅ กันยิงตอนยังไม่ถือ  
  
throwKnife(root)  
  
end  
  
end)  
  
-- =========================  
-- 💀 ATTACK (NO THROW)  
-- =========================  
local function attack(plr)  
  
    equipKnife()  
  
    local knife = getKnife()  
    if not knife then  
        return  
    end  
  
    if not plr.Character then  
        return  
    end  
  
    local enemyRoot =  
        plr.Character:FindFirstChild(  
            "HumanoidRootPart"  
        )  
  
    if not enemyRoot then  
        return  
    end  
  
    -- 🔥 แทงระยะไกล  
    for i = 1, 4 do  
  
        pcall(function()  
  
            stabKnife(enemyRoot)  
  
        end)  
  
        task.wait(0.02)  
    end  
end  
  
-- =========================  
-- 🔁 KILL AURA LOOP  
-- =========================  
task.spawn(function()  
  
    while task.wait(LOOP_DELAY) do  
  
        if not KILL_AURA then  
            continue  
        end  
  
        local target =  
            getNearestEnemy()  
  
        if not target then  
            continue  
        end  
  
        equipKnife()  
  
        local knife = getKnife()  
  
        if not knife then  
            continue  
        end  
  
        attack(target)  
  
    end  
end)
  
local TweenService = game:GetService("TweenService")  
  
local COIN_SPEED = 30  
local SAFE_DISTANCE = 40  
local STUCK_TIME = 1  
  
local currentTarget = nil  
local lastMoveTime = tick()  
local lastPos = nil  
  
-- 🔍 หาเหรียญแบบฉลาด (หลบคน)  
local function getSmartCoin(root)  
local bestCoin = nil  
local bestScore = math.huge  
  
for _, coin in ipairs(workspace:GetDescendants()) do  
if (coin.Name == "Coin" or coin.Name == "Coin_Server") and coin:IsA("BasePart") then  
  
local dist = (coin.Position - root.Position).Magnitude  
  
-- 🧠 เช็คศัตรูใกล้เหรียญ  
local danger = 0  
for _, plr in ipairs(Players:GetPlayers()) do  
if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then  
local d = (plr.Character.HumanoidRootPart.Position - coin.Position).Magnitude  
if d < SAFE_DISTANCE then  
danger = danger + (SAFE_DISTANCE - d)  
end  
end  
end  
  
-- 🎯 score ต่ำ = ดี  
local score = dist + (danger * 5)  
  
if score < bestScore then  
bestScore = score  
bestCoin = coin  
end  
  
end  
  
end  
  
return bestCoin  
  
end  
  
-- 🚀 Tween Fly (เนียน + กันแบน)  
local function tweenTo(root, pos)  
local dist = (root.Position - pos).Magnitude  
local time = dist / COIN_SPEED  
  
local tween = TweenService:Create(  
root,  
TweenInfo.new(time, Enum.EasingStyle.Linear),  
{CFrame = CFrame.new(pos)}  
)  
  
tween:Play()  
return tween  
  
end  
  
-- 🔥 LOOP  
task.spawn(function()  
while task.wait(0.01) do  
if not AUTO_COIN_COLLECT then continue end  
  
local char = player.Character  
local root = char and char:FindFirstChild("HumanoidRootPart")  
if not root then continue end  
  
-- ❗ ปิด Fly ปกติ  
if flying then  
setFly(false)  
end  
  
-- 🎯 ล็อคเป้าหมาย  
if not currentTarget or not currentTarget.Parent then  
currentTarget = getSmartCoin(root)  
end  
  
if not currentTarget then continue end  
  
local targetPos = currentTarget.Position + Vector3.new(0, 2, 0)  
  
-- 🚀 Tween ไปหา  
local tween = tweenTo(root, targetPos)  
  
-- 🧠 Anti Stuck  
local startTime = tick()  
lastPos = root.Position  
  
while tween.PlaybackState == Enum.PlaybackState.Playing do  
task.wait(0.01)  
  
if not AUTO_COIN_COLLECT then  
tween:Cancel()  
break  
end  
  
-- 🧱 ติด = วาร์ป  
if (root.Position - lastPos).Magnitude < 1 then  
if tick() - startTime > STUCK_TIME then  
root.CFrame = CFrame.new(targetPos)  
break  
end  
else  
startTime = tick()  
lastPos = root.Position  
end  
  
end  
  
-- 🔄 รีเซ็ตเป้าหมาย  
currentTarget = nil  
  
end  
  
end)  
  
-- =========================  
-- 📢 CHAT ANNOUNCE (FIXED)  
-- =========================  
  
local TextChatService = game:GetService("TextChatService")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
  
-- 🔥 ส่งแชท (โคตรเสถียร)  
local function sendChat(msg)  
pcall(function()  
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then  
  
local channels = TextChatService:WaitForChild("TextChannels", 2)  
local channel = channels and channels:FindFirstChild("RBXGeneral")  
  
if channel then  
channel:SendAsync(msg)  
else  
warn("No RBXGeneral channel")  
end  
  
else  
ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")  
:WaitForChild("SayMessageRequest")  
:FireServer(msg, "All")  
end  
  
end)  
  
end  
  
-- 🔪 หา Murderer  
local function getMurderer()  
for _, plr in ipairs(Players:GetPlayers()) do  
if plr ~= player and getRole(plr) == "Murderer" then  
return plr  
end  
end  
end  
  
-- 👮 หา Sheriff  
local function getSheriffPlayer()  
for _, plr in ipairs(Players:GetPlayers()) do  
if plr ~= player and getRole(plr) == "Sheriff" then  
return plr  
end  
end  
end  
  
-- 🔁 Loop ประกาศ  
task.spawn(function()  
local announced = false  
  
while task.wait(0.1) do  
if not CHAT_ANNOUNCE then  
announced = false  
continue  
end  
  
if not announced then  
local murderer = getMurderer()  
local sheriff = getSheriffPlayer()  
  
if murderer and sheriff then  
local msg = "Murderer: "..murderer.Name..  
" | Sheriff: "..sheriff.Name..  
" | Kuo Hub"  
  
sendChat(msg)  
announced = true  
  
task.wait(0.01) -- ✅ ต้อง 1-2 วิ ถึงจะเสถียร  
  
end  
  
end  
  
-- 🔄 รีรอบใหม่  
if not getMurderer() and not getSheriffPlayer() then  
announced = false  
end  
  
end  
  
end)  
  
-- =========================  
-- SYSTEM: ANTI PLING (NO COLLIDE)  
-- =========================  
  
local function setCollision(character, state)  
for _, part in ipairs(character:GetDescendants()) do  
if part:IsA("BasePart") then  
part.CanCollide = state  
end  
end  
end  
  
local function applyNoCollide(player)  
if not player.Character then return end  
  
setCollision(player.Character, false)  
  
player.Character.DescendantAdded:Connect(function(part)  
if part:IsA("BasePart") then  
part.CanCollide = false  
end  
end)  
  
end  
  
-- =========================  
-- MAIN LOOP (TOGGLE CONTROL)  
-- =========================  
task.spawn(function()  
while task.wait(0.01) do  
if Anti_Pling then  
for _, plr in ipairs(Players:GetPlayers()) do  
if plr.Character then  
applyNoCollide(plr)  
end  
end  
else  
for _, plr in ipairs(Players:GetPlayers()) do  
if plr.Character then  
setCollision(plr.Character, true)  
end  
end  
end  
end  
end)  
  
-- =========================  
-- INVISIBLE (MM2 FIX)  
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
-- GET GUN  
-- =========================  
  
local Players = game:GetService("Players")  
local LocalPlayer = Players.LocalPlayer  
  
-- =========================  
-- AIM SETTINGS  
-- =========================  
local AIMBOT_CONFIG = {  
  
-- ⚡ Predict ยิงไกล    
Prediction = 0.07,    
  
-- 🌍 ชดเชยแรงโน้มถ่วง    
GravityCompensation = 0.012,    
  
-- 🎲 Randomization    
Randomness = 0.008,    
  
-- ⚡ ความเร็วลูป    
ShootDelay = 0.003,  
  
}  
  
-- =========================  
-- GET GUN  
-- =========================  
local function getGun()  
  
local char = LocalPlayer.Character    
  
if not char then    
    return nil    
end    
  
return char:FindFirstChild("Gun")  
  
end  
  
-- =========================  
-- AUTO EQUIP GUN  
-- =========================  
local lastGunEquip = 0  
  
local function equipGun()  
  
if tick() - lastGunEquip < 0.25 then    
    return    
end    
  
lastGunEquip = tick()    
  
local char = LocalPlayer.Character    
local backpack =    
    LocalPlayer:FindFirstChild("Backpack")    
  
if not char or not backpack then    
    return    
end    
  
if not char:FindFirstChild("Gun") then    
  
    local gun =    
        backpack:FindFirstChild("Gun")    
  
    if gun then    
        gun.Parent = char    
    end    
end  
  
end  
  
-- =========================  
-- CHECK MURDERER  
-- =========================  
local function isMurderer(model)  
  
local plr =    
    Players:GetPlayerFromCharacter(model)    
  
if not plr then    
    return false    
end    
  
local bp = plr:FindFirstChild("Backpack")    
local char = plr.Character    
  
if (bp and bp:FindFirstChild("Knife")) or    
   (char and char:FindFirstChild("Knife")) then    
  
    return true    
end    
  
return false  
  
end  
  
-- =========================  
-- BODY AIM 100%  
-- =========================  
local function getSmartPart(targetChar)  
  
local hrp =    
    targetChar:FindFirstChild(    
        "HumanoidRootPart"    
    )    
  
if hrp then    
    return hrp    
end    
  
return targetChar:FindFirstChild("Head")  
  
end  
  
-- =========================  
-- ULTRA PREDICTION  
-- =========================  
local function getUltraPrediction(  
targetChar,  
originPos  
)  
  
local targetPart =    
    getSmartPart(targetChar)    
  
local root =    
    targetChar:FindFirstChild(    
        "HumanoidRootPart"    
    )    
  
if not targetPart or not root then    
    return nil    
end    
  
local velocity =    
    root.AssemblyLinearVelocity    
  
local distance =    
    (targetPart.Position    
    - originPos).Magnitude    
  
-- ⚡ Predict    
local travelTime =    
    distance    
    * AIMBOT_CONFIG.Prediction    
    / 100    
  
local predictedPos =    
    targetPart.Position    
    + (velocity * travelTime)    
  
-- 🌍 Gravity Compensation    
predictedPos =    
    predictedPos    
    + Vector3.new(    
        0,    
        distance    
        * AIMBOT_CONFIG.GravityCompensation,    
        0    
    )    
  
-- 🎲 Randomization    
predictedPos =    
    predictedPos    
    + Vector3.new(    
        math.random(-100,100)    
        * AIMBOT_CONFIG.Randomness,    
  
        math.random(-100,100)    
        * AIMBOT_CONFIG.Randomness,    
  
        math.random(-100,100)    
        * AIMBOT_CONFIG.Randomness    
    )    
  
-- 🔥 ยิงกลางตัว    
predictedPos =    
    predictedPos    
    + Vector3.new(0, -0.2, 0)    
  
return CFrame.new(predictedPos)  
  
end  
  
-- =========================  
-- WALL ORIGIN  
-- =========================  
local function getWallOrigin(targetChar)  
  
local char = LocalPlayer.Character    
  
if not char then    
    return nil    
end    
  
local root =    
    char:FindFirstChild(    
        "HumanoidRootPart"    
    )    
  
local targetRoot =    
    targetChar:FindFirstChild(    
        "HumanoidRootPart"    
    )    
  
if not root or not targetRoot then    
    return nil    
end    
  
local direction =    
    (targetRoot.Position    
    - root.Position).Unit    
  
-- 🔥 จุดยิงทะลุกำแพง    
local pos =    
    targetRoot.Position    
    - (direction * 3)    
  
return CFrame.new(pos)  
  
end  
  
-- =========================  
-- FIRE WALL  
-- =========================  
local function fireWall()  
  
equipGun()    
  
local gun = getGun()    
  
if not gun then    
    return    
end    
  
local shootEvent =    
    gun:FindFirstChild("Shoot")    
  
if not shootEvent then    
    return    
end    
  
-- 🔥 หา Murderer    
for _,plr in ipairs(    
    Players:GetPlayers()    
) do    
  
    if plr ~= LocalPlayer    
    and plr.Character then    
  
        local char = plr.Character    
  
        local humanoid =    
            char:FindFirstChild(    
                "Humanoid"    
            )    
  
        if humanoid    
        and humanoid.Health > 0    
        and isMurderer(char) then    
  
            -- 🔥 จุดยิงทะลุกำแพง    
            local originCF =    
                getWallOrigin(char)    
  
            if not originCF then    
                continue    
            end    
  
            local targetCF =    
                getUltraPrediction(    
                    char,    
                    originCF.Position    
                )    
  
            if targetCF then    
  
                pcall(function()    
  
                    shootEvent:FireServer(    
                        originCF,    
                        targetCF    
                    )    
  
                end)    
  
                break    
            end    
        end    
    end    
end  
  
end  
  
-- =========================  
-- LOOP  
-- =========================  
task.spawn(function()  
  
while task.wait(    
    AIMBOT_CONFIG.ShootDelay    
) do    
  
    if not Shot_AURA then    
        continue    
    end    
  
    pcall(function()    
        fireWall()    
    end)    
  
end  
  
end)  

-- =========================  
-- Info  
-- =========================  

Info:Section("📌 KuoHub Information | ข้อมูลสคริปต์")

Info:Button({
Title = "📅 Last Update | อัปเดตล่าสุด :12/07/2026",
Callback = function()
end
})

Info:Button({
Title = "🇹🇭 Developed By Thai | พัฒนาโดยคนไทย",
Callback = function()
end
})

Info:Button({
Title = "⚡ Script Version | เวอร์ชันสคริปต์ : v10.1 FUTURISTIC",
Callback = function()
end
})

Info:Button({
Title = "🛠 Status : ✔️| สถานะ : Stable✔️",
Callback = function()
end
})

Info:Button({
Title = "📃 Punk status : Yes | สถานะพังค์ชั้น : ยังใช้งานได้",
Callback = function()
end
})
-- =========================  
-- UI  
-- =========================  
Home:AddDiscordInvite({  
Name = "Kuo Hub",  
Description = "Join server",  
Logo = "rbxassetid://126460540157931",  
Invite = "https://discord.gg/Apn2j9Fez",  
})
Home:Toggle({Title="ESP",Desc="ไฮไลต์ผู้เล่น",Callback=function(v) ESP_ENABLED=v end})  
Home:Toggle({Title ="Gun ESP",Desc ="ไฮไลต์ปืนตก",Callback =function(v) GunESP =v end})  
Home:Toggle({
	Title = "Fly",
	Desc = "บิน",
	Callback = function(v)
		setFly(v)
	end
})
	
Home:Toggle({Title="Auto Warp Gun",Desc="วาร์ปเก็บปืน",Callback=function(v) AUTO_WARP_GUN=v end})  
Home:Toggle({Title="Infinite Jump",Desc="กระโดดไม่จำกัด",Callback=function(v) INFINITE_JUMP=v end})  
Home:Toggle({Title="NoClip",Desc="ทะลุกำแพง",Callback=function(v) NOCLIP=v end})  
  
Combat:Toggle({Title="Aim Lock",Desc="ล็อคฆาตกร",Callback=function(v) AIMLOCK=v LOCK_TARGET=nil end})  
Combat:Toggle({Title="Auto Shoot",Desc="ยิงออโต้",Callback=function(v) AUTO_SHOOT=v end})  
Combat:Toggle({  
Title="Auto Knife",  
Desc="ปามีดอัตโนมัติ",  
Callback=function(v)  
AUTO_KNIFE=v  
end  
})  
Combat:Toggle({  
Title="Kill Aura",  
Desc="ฆ่าทุกคนอัตโนมัติ",  
Callback=function(v)  
KILL_AURA=v  
end  
})  
  
Home:Toggle({  
Title = "Auto Coin Collect",  
Desc = "ออโต้เก็บเหรียญ",  
Callback = function(v)  
AUTO_COIN_COLLECT = v  
end  
})  
  
Home:Toggle({  
Title="Reveal Role",  
Desc="เปิดเผยวายร้าย",  
Callback=function(v)  
CHAT_ANNOUNCE = v  
end  
})  
  
Home:Toggle({  
Title="Anti-Fling",  
Desc="กันปลิง",  
Callback=function(v)  
Anti_Pling = v  
end  
})  
  
Combat:Toggle({  
Title = "Shoot through the wall",  
Desc = "ยิงทะลุกำแพง",  
Callback = function(v)  
Shot_AURA = v  
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
	Name = "Adjust walk speed",
	Min = 16,
	Max = 200,
	Default = 16,
	Callback = function(v)
		walkSpeed = v
	end
})

game:GetService("RunService").Heartbeat:Connect(function()
	local character = game.Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = walkSpeed
	end
end)

--========================  
-- RESPWAN FIX  
--========================  
lp.CharacterAdded:Connect(function()  
task.wait(0.5)  
applySpeed(getgenv().SpeedValue)  
end)  
  
Home:AddSlider({
	Name = "Adjust flight speed",
	Min = 1,
	Max = 200,
	Default = 60,
	Callback = function(v)
		speed = v
	end
})
  
Home:AddSlider({  
Name = "Coin Collect Speed",  
Min = 16,  
Max = 200,  
Default = 30,  
Callback = function(v)  
COIN_SPEED = v  
end  
})  
  
-- KEY  
UIS.InputBegan:Connect(function(i,g)  
if not g and i.KeyCode == Enum.KeyCode.F then  
setFly(not flying)  
--=====================================================
--  Kuo Hub AI | AI Chat System (Thai / English)
--  วางบล็อกนี้ "ท้ายสุด" ของสคริปต์ Kuo Hub
--  เปิด/ปิด UI : ปุ่ม RightShift
--=====================================================

do
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- กันรันซ้ำ: ลบ UI เก่า
pcall(function()
	local old = CoreGui:FindFirstChild("KuoHubAI_UI")
	if old then old:Destroy() end
end)

--=====================================================
-- LANGUAGE DETECTOR
--=====================================================
local function isThai(s)
	return s:match("[\u{0E00}-\u{0E7F}]") ~= nil
end

--=====================================================
-- GAME NAME
--=====================================================
local CurrentGameName = "Roblox"
pcall(function()
	local info = MarketplaceService:GetProductInfo(game.PlaceId)
	if info and info.Name then CurrentGameName = info.Name end
end)

--=====================================================
-- INTRO SCREEN
--=====================================================
local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "KuoHubAI_Intro"
pcall(function() IntroGui.Parent = CoreGui end)
if not IntroGui.Parent then IntroGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local IntroLabel = Instance.new("TextLabel", IntroGui)
IntroLabel.Size = UDim2.new(1, 0, 1, 0)
IntroLabel.BackgroundTransparency = 1
IntroLabel.Text = "Kuo Hub AI"
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.Font = Enum.Font.GothamBold
IntroLabel.TextSize = 36
IntroLabel.TextTransparency = 1

TweenService:Create(IntroLabel, TweenInfo.new(1.2), {TextTransparency = 0}):Play()
task.wait(2.2)
TweenService:Create(IntroLabel, TweenInfo.new(1.2), {TextTransparency = 1}):Play()
task.wait(1.2)
IntroGui:Destroy()

--=====================================================
-- UI SETUP
--=====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KuoHubAI_UI"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.ResetOnSpawn = false

local NormalSize = UDim2.new(0, 470, 0, 280)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = NormalSize
MainFrame.Position = UDim2.new(0.5, 0, 0.475, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
MainFrame.BackgroundTransparency = 0.05
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(48, 54, 61)
UIStroke.Thickness = 1.2

-- ปุ่มลอยตอน minimize
local MinBtn = Instance.new("ImageButton", ScreenGui)
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 42, 0, 42)
MinBtn.Position = UDim2.new(0, 15, 0, 90)
MinBtn.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
MinBtn.Image = "rbxassetid://126460540157931"
MinBtn.Visible = false
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
local ms = Instance.new("UIStroke", MinBtn)
ms.Color = Color3.fromRGB(48, 54, 61)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5

local TitleIcon = Instance.new("ImageLabel", TopBar)
TitleIcon.Size = UDim2.new(0, 18, 0, 18)
TitleIcon.Position = UDim2.new(0, 10, 0, 8)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = "rbxassetid://126460540157931"
TitleIcon.ScaleType = Enum.ScaleType.Fit

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 260, 1, 0)
Title.Position = UDim2.new(0, 32, 0, 0)
Title.Text = 'Kuo Hub AI <font color="#32CD96">[FREE]</font>'
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 44)
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -64, 0, 5)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 13
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 44)
MinimizeBtn.ZIndex = 10
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -16, 1, -40)
ContentFrame.Position = UDim2.new(0, 8, 0, 34)
ContentFrame.BackgroundTransparency = 1

local ChatBoxFrame = Instance.new("ScrollingFrame", ContentFrame)
ChatBoxFrame.Size = UDim2.new(1, 0, 1, -42)
ChatBoxFrame.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
ChatBoxFrame.BackgroundTransparency = 0.4
ChatBoxFrame.BorderSizePixel = 0
ChatBoxFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatBoxFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatBoxFrame.ScrollBarThickness = 3
ChatBoxFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 70, 80)
Instance.new("UICorner", ChatBoxFrame).CornerRadius = UDim.new(0, 8)
local ChatList = Instance.new("UIListLayout", ChatBoxFrame)
ChatList.Padding = UDim.new(0, 5)
local ChatPadding = Instance.new("UIPadding", ChatBoxFrame)
ChatPadding.PaddingLeft = UDim.new(0, 8)
ChatPadding.PaddingRight = UDim.new(0, 8)
ChatPadding.PaddingTop = UDim.new(0, 8)

local InputFrame = Instance.new("Frame", ContentFrame)
InputFrame.Size = UDim2.new(1, -105, 0, 32)
InputFrame.Position = UDim2.new(0, 0, 1, -32)
InputFrame.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 8)
local InputStroke = Instance.new("UIStroke", InputFrame)
InputStroke.Color = Color3.fromRGB(40, 46, 54)
InputStroke.Transparency = 0.3

local CommandInput = Instance.new("TextBox", InputFrame)
CommandInput.Size = UDim2.new(1, -12, 1, 0)
CommandInput.Position = UDim2.new(0, 6, 0, 0)
CommandInput.BackgroundTransparency = 1
CommandInput.Text = ""
CommandInput.PlaceholderText = "พิมพ์ข้อความถึง Kuo Hub AI... / Type a message..."
CommandInput.PlaceholderColor3 = Color3.fromRGB(139, 148, 158)
CommandInput.TextColor3 = Color3.fromRGB(240, 240, 240)
CommandInput.Font = Enum.Font.Gotham
CommandInput.TextSize = 11
CommandInput.TextXAlignment = Enum.TextXAlignment.Left

local ModeSelectBtn = Instance.new("TextButton", ContentFrame)
ModeSelectBtn.Size = UDim2.new(0, 54, 0, 32)
ModeSelectBtn.Position = UDim2.new(1, -101, 1, -32)
ModeSelectBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 44)
ModeSelectBtn.Text = "TALK | คุย"
ModeSelectBtn.TextColor3 = Color3.fromRGB(50, 205, 150)
ModeSelectBtn.Font = Enum.Font.GothamBold
ModeSelectBtn.TextSize = 8
ModeSelectBtn.TextWrapped = true
Instance.new("UICorner", ModeSelectBtn).CornerRadius = UDim.new(0, 8)

local ModeDropdown = Instance.new("Frame", ContentFrame)
ModeDropdown.Size = UDim2.new(0, 54, 0, 60)
ModeDropdown.Position = UDim2.new(1, -101, 1, -96)
ModeDropdown.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
ModeDropdown.BorderSizePixel = 0
ModeDropdown.Visible = false
ModeDropdown.ZIndex = 20
Instance.new("UICorner", ModeDropdown).CornerRadius = UDim.new(0, 8)
local DropdownStroke = Instance.new("UIStroke", ModeDropdown)
DropdownStroke.Color = Color3.fromRGB(48, 54, 61)

local ModeBtn1 = Instance.new("TextButton", ModeDropdown)
ModeBtn1.Size = UDim2.new(1, 0, 0.5, 0)
ModeBtn1.BackgroundColor3 = Color3.fromRGB(35, 42, 52)
ModeBtn1.BackgroundTransparency = 0
ModeBtn1.Text = "TALK | คุย"
ModeBtn1.TextColor3 = Color3.fromRGB(50, 205, 150)
ModeBtn1.Font = Enum.Font.GothamBold
ModeBtn1.TextSize = 8
ModeBtn1.TextWrapped = true
ModeBtn1.ZIndex = 21
Instance.new("UICorner", ModeBtn1).CornerRadius = UDim.new(0, 6)

local ModeBtn2 = Instance.new("TextButton", ModeDropdown)
ModeBtn2.Size = UDim2.new(1, 0, 0.5, 0)
ModeBtn2.Position = UDim2.new(0, 0, 0.5, 0)
ModeBtn2.BackgroundTransparency = 1
ModeBtn2.Text = "CODE | โปร"
ModeBtn2.TextColor3 = Color3.fromRGB(200, 200, 200)
ModeBtn2.Font = Enum.Font.GothamBold
ModeBtn2.TextSize = 8
ModeBtn2.TextWrapped = true
ModeBtn2.ZIndex = 21
Instance.new("UICorner", ModeBtn2).CornerRadius = UDim.new(0, 6)

local SendBtn = Instance.new("TextButton", ContentFrame)
SendBtn.Size = UDim2.new(0, 42, 0, 32)
SendBtn.Position = UDim2.new(1, -42, 1, -32)
SendBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 150)
SendBtn.Text = "ส่ง"
SendBtn.TextColor3 = Color3.fromRGB(13, 17, 23)
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextSize = 11
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 8)

local SuggestionBox = Instance.new("ScrollingFrame", ContentFrame)
SuggestionBox.Size = UDim2.new(1, 0, 0, 100)
SuggestionBox.Position = UDim2.new(0, 0, 1, -136)
SuggestionBox.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
SuggestionBox.BorderSizePixel = 0
SuggestionBox.Visible = false
SuggestionBox.ScrollBarThickness = 2
SuggestionBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", SuggestionBox).CornerRadius = UDim.new(0, 6)
local SuggestionLayout = Instance.new("UIListLayout", SuggestionBox)
SuggestionLayout.Padding = UDim.new(0, 2)

--=====================================================
-- CHAT HISTORY (แยกตามโหมด)
--=====================================================
local CurrentMode = "TALK"
local ChatHistories = { TALK = {}, CODE = {} }

local function SaveCurrentChatToHistory()
	local history = {}
	for _, child in pairs(ChatBoxFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			table.insert(history, {
				Text = child.Text,
				TextColor3 = child.TextColor3,
				TextXAlignment = child.TextXAlignment,
				Font = child.Font,
				TextSize = child.TextSize,
				RichText = child.RichText,
			})
		end
	end
	ChatHistories[CurrentMode] = history
end

local function RestoreChatHistory(mode)
	for _, child in pairs(ChatBoxFrame:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end
	for _, data in ipairs(ChatHistories[mode]) do
		local lbl = Instance.new("TextLabel", ChatBoxFrame)
		lbl.Size = UDim2.new(1, 0, 0, 0)
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = data.TextColor3
		lbl.TextXAlignment = data.TextXAlignment
		lbl.Font = data.Font
		lbl.TextSize = data.TextSize
		lbl.TextWrapped = true
		lbl.RichText = data.RichText
		lbl.Text = data.Text
	end
	task.wait(0.02)
	ChatBoxFrame.CanvasPosition = Vector2.new(0, ChatBoxFrame.AbsoluteCanvasSize.Y)
end

local AI_NAME = "Kuo Hub AI"

local function AddChatMessage(sender, text, color)
	local MsgLabel = Instance.new("TextLabel", ChatBoxFrame)
	MsgLabel.Size = UDim2.new(1, 0, 0, 0)
	MsgLabel.AutomaticSize = Enum.AutomaticSize.Y
	MsgLabel.BackgroundTransparency = 1
	MsgLabel.Font = Enum.Font.GothamSemibold
	MsgLabel.TextSize = 12
	MsgLabel.TextWrapped = true
	MsgLabel.RichText = true

	if sender == "You" then
		MsgLabel.TextColor3 = Color3.fromRGB(50, 205, 150)
		MsgLabel.TextXAlignment = Enum.TextXAlignment.Right
		MsgLabel.Text = text .. " : [You]"
		task.wait(0.02)
		ChatBoxFrame.CanvasPosition = Vector2.new(0, ChatBoxFrame.AbsoluteCanvasSize.Y)
	else
		MsgLabel.TextColor3 = Color3.fromRGB(160, 170, 180)
		MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
		local thinking = isThai(text) and ("["..AI_NAME.."]: กำลังประมวลผล...") or ("["..AI_NAME.."]: Thinking...")
		MsgLabel.Text = thinking
		task.wait(0.02)
		ChatBoxFrame.CanvasPosition = Vector2.new(0, ChatBoxFrame.AbsoluteCanvasSize.Y)

		task.wait(math.clamp(#text * 0.004, 0.3, 1.2))
		MsgLabel.TextColor3 = color or Color3.fromRGB(220, 225, 230)

		if string.find(text, "<font") or string.find(text, "```") then
			MsgLabel.Text = "["..AI_NAME.."]: " .. text
			task.wait(0.02)
			ChatBoxFrame.CanvasPosition = Vector2.new(0, ChatBoxFrame.AbsoluteCanvasSize.Y)
		else
			local fullText = "["..AI_NAME.."]: " .. text
			MsgLabel.Text = ""
			for i = 1, utf8.len(fullText) or #fullText do
				local nextOff = utf8.offset(fullText, i + 1)
				MsgLabel.Text = string.sub(fullText, 1, nextOff and (nextOff - 1) or #fullText)
				ChatBoxFrame.CanvasPosition = Vector2.new(0, ChatBoxFrame.AbsoluteCanvasSize.Y)
				task.wait(0.012)
			end
		end
	end
end

-- ข้อความต้อนรับ
AddChatMessage("AI", "สวัสดีครับ! ผมคือ <b>Kuo Hub AI</b> 🤖 พิมพ์ <font color='#32CD96'>help</font> เพื่อดูความสามารถทั้งหมด | Hello! Type <font color='#32CD96'>help</font> to see my capabilities.", Color3.fromRGB(50, 205, 150))
SaveCurrentChatToHistory()

local function SwitchMode(mode)
	if CurrentMode == mode then return end
	SaveCurrentChatToHistory()
	CurrentMode = mode
	ModeDropdown.Visible = false
	if mode == "TALK" then
		ModeSelectBtn.Text = "TALK | คุย"
		ModeBtn1.BackgroundTransparency = 0
		ModeBtn1.TextColor3 = Color3.fromRGB(50, 205, 150)
		ModeBtn2.BackgroundTransparency = 1
		ModeBtn2.TextColor3 = Color3.fromRGB(200, 200, 200)
	else
		ModeSelectBtn.Text = "CODE | โปร"
		ModeBtn2.BackgroundTransparency = 0
		ModeBtn2.TextColor3 = Color3.fromRGB(50, 205, 150)
		ModeBtn1.BackgroundTransparency = 1
		ModeBtn1.TextColor3 = Color3.fromRGB(200, 200, 200)
	end
	RestoreChatHistory(mode)
end

ModeSelectBtn.MouseButton1Click:Connect(function() ModeDropdown.Visible = not ModeDropdown.Visible end)
ModeBtn1.MouseButton1Click:Connect(function() SwitchMode("TALK") end)
ModeBtn2.MouseButton1Click:Connect(function() SwitchMode("CODE") end)

--=====================================================
-- SUGGESTION BOX (พิมพ์ / เพื่อเลือกคนวาร์ป)
--=====================================================
local function RefreshSuggestions()
	for _, child in pairs(SuggestionBox:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local btn = Instance.new("TextButton", SuggestionBox)
			btn.Size = UDim2.new(1, 0, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(30, 36, 44)
			btn.Text = "🚀 " .. p.Name
			btn.TextColor3 = Color3.fromRGB(220, 220, 220)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 10
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			btn.MouseButton1Click:Connect(function()
				CommandInput.Text = "warp " .. p.Name
				SuggestionBox.Visible = false
			end)
		end
	end
end

CommandInput:GetPropertyChangedSignal("Text"):Connect(function()
	if CurrentMode == "CODE" and CommandInput.Text:sub(1, 1) == "/" then
		SuggestionBox.Visible = true
		RefreshSuggestions()
	else
		SuggestionBox.Visible = false
	end
end)

--=====================================================
-- CHEAT STATE
--=====================================================
local AI = {
	Fly = false, FlySpeed = 60,
	Noclip = false, InfJump = false,
	ESP = false, ESPColor = Color3.fromRGB(255, 0, 0), ESPColorName = "Red/แดง",
	Hitbox = 0,
	God = false, Bright = false,
	Speed = nil, Jump = nil,
	Spin = false,
}
local Conn = {}

local function UpdateESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			if AI.ESP then
				local hl = p.Character:FindFirstChild("KuoAI_HL") or Instance.new("Highlight")
				hl.Name = "KuoAI_HL"
				hl.FillColor = AI.ESPColor
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.FillTransparency = 0.3
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Parent = p.Character
			elseif p.Character:FindFirstChild("KuoAI_HL") then
				p.Character.KuoAI_HL:Destroy()
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if AI.Hitbox > 0 then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local root = p.Character:FindFirstChild("HumanoidRootPart")
				if root and root.Size.X < AI.Hitbox then
					root.Size = Vector3.new(AI.Hitbox, AI.Hitbox, AI.Hitbox)
					root.Transparency = 0.7
					root.CanCollide = false
				end
			end
		end
	end
	if AI.ESP then UpdateESP() end
	if AI.Spin then
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(35), 0) end
	end
end)

-- speed/jump override (เชื่อมทีหลังสคริปต์หลัก จึงทับค่าได้)
RunService.Heartbeat:Connect(function()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		if AI.Speed then hum.WalkSpeed = AI.Speed end
		if AI.Jump then hum.UseJumpPower = true; hum.JumpPower = AI.Jump end
	end
end)

local function FullReset(silent)
	AI.Fly = false; AI.Noclip = false; AI.InfJump = false
	AI.ESP = false; AI.Hitbox = 0; AI.God = false; AI.Bright = false
	AI.Speed = nil; AI.Jump = nil; AI.Spin = false
	UpdateESP()
	for k, c in pairs(Conn) do pcall(function() c:Disconnect() end); Conn[k] = nil end
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.PlatformStand = false; hum.MaxHealth = 100 end
	Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = true
	if not silent then
		AddChatMessage("AI", isThai(CommandInput.Text) and "รีเซ็ตค่าโปรทั้งหมดกลับเป็นปกติเรียบร้อยครับ ✅" or "All cheat values have been reset to normal ✅", Color3.fromRGB(240, 180, 50))
		SaveCurrentChatToHistory()
	end
end

local function SetupDeathReset(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.Died:Connect(function() FullReset(true) end)
	end
end
if LocalPlayer.Character then SetupDeathReset(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupDeathReset)

local function HasAny(text, words)
	for _, w in ipairs(words) do
		if text:find(w) then return true end
	end
	return false
end

--=====================================================
-- TALK ENGINE (ไทย + อังกฤษ)
--=====================================================
local function Reply(text, th, en)
	AddChatMessage("AI", isThai(text) and th or en, Color3.fromRGB(120, 170, 240))
	SaveCurrentChatToHistory()
end

local function ProcessTalk(raw)
	local c = string.lower(raw):gsub("['\"%,%.%-_?!]", ""):gsub("%s+", " ")
	local name = LocalPlayer.DisplayName

	if HasAny(c, {"สวัสดี", "หวัดดี", "ดีครับ", "ดีค่ะ", "ดีจ้า", "โย่", "ฮัลโหล", "ทักทาย", "hi", "hello", "hey", "yo", "sup", "greetings"}) then
		local th = {
			"สวัสดีครับคุณ "..name.."! มีอะไรให้ Kuo Hub AI ช่วยไหมครับ? พิมพ์ help เพื่อดูคำสั่งทั้งหมด",
			"โย่ว! ว่าไงครับท่าน "..name.." อยากเปิดโปรตัวไหน หรืออยากคุยเล่นก็ได้นะ 555",
		}
		local en = {
			"Hello, "..name.."! How can Kuo Hub AI help you today? Type help to see all commands.",
			"Hey there! Want to toggle a cheat or just chat? I'm all ears!",
		}
		return Reply(raw, th[math.random(#th)], en[math.random(#en)])
	end

	if HasAny(c, {"เป็นไงบ้าง", "สบายดีไหม", "ทำอะไรอยู่", "ทำไรอยู่", "how are you", "hows it going", "how's it going", "whats up", "what's up", "wsp", "how u doing"}) then
		return Reply(raw,
			"ผมรอตอบคำถามอยู่ตลอดเลยครับ ไม่มีวันเหนื่อย! ว่าแต่คุณล่ะ วันนี้ลุยแมปอะไรยาวๆ ดี?",
			"I'm always here waiting to help, never tired! What map are you grinding today?")
	end

	if HasAny(c, {"คุณคือใคร", "นายคือใคร", "แกคือใคร", "ชื่ออะไร", "แนะนำตัว", "who are you", "what are you", "your name", "introduce yourself"}) then
		return Reply(raw,
			"ผมคือ <b>Kuo Hub AI</b> 🤖 ผู้ช่วยอัจฉริยะของสคริปต์ Kuo Hub รองรับทั้งภาษาไทยและอังกฤษ ถามได้ทุกเรื่องเลยครับ!",
			"I'm <b>Kuo Hub AI</b> 🤖, the smart assistant built into Kuo Hub. I speak both Thai and English — ask me anything!")
	end

	if HasAny(c, {"เล่นเกมอะไร", "เล่นแมปอะไร", "แมปอะไร", "เกมอะไร", "อยู่แมปไหน", "what game", "what map", "which game", "which map"}) then
		return Reply(raw,
			"ตอนนี้คุณกำลังเล่นแมป: <b>"..CurrentGameName.."</b> อยู่ครับ ลุยให้สนุกนะ!",
			"You're currently playing: <b>"..CurrentGameName.."</b>. Have fun out there!")
	end

	if HasAny(c, {"ควรเปิดโปรไหน", "แนะนำโปร", "เปิดอะไรดี", "โปรอะไรดี", "recommend", "what cheat", "best cheat", "what should i use", "which cheat"}) then
		return Reply(raw,
			"จากแมป <b>"..CurrentGameName.."</b> ผมแนะนำให้ลอง: <font color='#32CD96'>speed 100</font> (วิ่งเร็ว), <font color='#32CD96'>esp red</font> (มองทะลุ), หรือ <font color='#32CD96'>fly</font> (บิน) ครับ สลับไปโหมด CODE แล้วพิมพ์ได้เลย!",
			"For <b>"..CurrentGameName.."</b>, I'd suggest: <font color='#32CD96'>speed 100</font>, <font color='#32CD96'>esp red</font>, or <font color='#32CD96'>fly</font>. Switch to CODE mode and type the command!")
	end

	if HasAny(c, {"help", "ช่วย", "คำสั่ง", "ทำอะไรได้บ้าง", "ใช้ยังไง", "commands", "menu", "what can you do", "how to use"}) then
		local thMsg = "🤖 <b>Kuo Hub AI</b> มี 2 โหมด:\n\n" ..
			"💬 <b>โหมด TALK</b> — คุยเล่น ถามตอบ (ไทย/อังกฤษ)\n\n" ..
			"⚡ <b>โหมด CODE</b> — คำสั่งโปร (พิมพ์ได้ทั้ง 2 ภาษา):\n" ..
			"• <font color='#32CD96'>fly / บิน</font> — บินอิสระ\n" ..
			"• <font color='#32CD96'>unfly / ปิดบิน</font>\n" ..
			"• <font color='#32CD96'>speed 100 / วิ่ง 100</font> — วิ่งเร็ว\n" ..
			"• <font color='#32CD96'>jump 100 / โดด 100</font> — โดดสูง\n" ..
			"• <font color='#32CD96'>infjump / โดดไม่จำกัด</font>\n" ..
			"• <font color='#32CD96'>noclip / ทะลุ</font>\n" ..
			"• <font color='#32CD96'>esp red / มอง แดง</font> — มองทะลุ (รองรับ: red, green, blue, yellow, pink, purple, white, black / แดง เขียว น้ำเงิน เหลือง ชมพู ม่วง ขาว ดำ)\n" ..
			"• <font color='#32CD96'>unesp / ปิดมอง</font>\n" ..
			"• <font color='#32CD96'>hitbox 10 / ฮิต 10</font> — ขยายฮิตบ็อกซ์\n" ..
			"• <font color='#32CD96'>spin / สปิน</font> — หมุนตัว | <font color='#32CD96'>unspin / ปิดสปิน</font>\n" ..
			"• <font color='#32CD96'>bright / สว่าง</font> — สว่างทั้งแมป\n" ..
			"• <font color='#32CD96'>god / อมตะ</font>\n" ..
			"• <font color='#32CD96'>invisible / ล่องหน</font>\n" ..
			"• <font color='#32CD96'>warp ชื่อ / วาป ชื่อ</font> — วาร์ปหาคน (หรือพิมพ์ <b>/</b> เพื่อเลือกจากรายชื่อ)\n" ..
			"• <font color='#32CD96'>reset / รีเซ็ต</font> — ล้างโปรทั้งหมด"
		local enMsg = "🤖 <b>Kuo Hub AI</b> has 2 modes:\n\n" ..
			"💬 <b>TALK mode</b> — chat with me (Thai/English)\n\n" ..
			"⚡ <b>CODE mode</b> — cheat commands:\n" ..
			"• <font color='#32CD96'>fly</font> — fly freely\n" ..
			"• <font color='#32CD96'>unfly</font>\n" ..
			"• <font color='#32CD96'>speed 100</font> — run faster\n" ..
			"• <font color='#32CD96'>jump 100</font> — jump higher\n" ..
			"• <font color='#32CD96'>infjump</font> — infinite jump\n" ..
			"• <font color='#32CD96'>noclip</font> — walk through walls\n" ..
			"• <font color='#32CD96'>esp red</font> — player ESP (red, green, blue, yellow, pink, purple, white, black)\n" ..
			"• <font color='#32CD96'>unesp</font>\n" ..
			"• <font color='#32CD96'>hitbox 10</font> — expand hitboxes\n" ..
			"• <font color='#32CD96'>spin</font> — spin bot | <font color='#32CD96'>unspin</font>\n" ..
			"• <font color='#32CD96'>bright</font> — full brightness\n" ..
			"• <font color='#32CD96'>god</font> — god mode\n" ..
			"• <font color='#32CD96'>invisible</font>\n" ..
			"• <font color='#32CD96'>warp Name</font> — teleport to player (or type <b>/</b> to pick)\n" ..
			"• <font color='#32CD96'>reset</font> — reset all cheats"
		AddChatMessage("AI", isThai(raw) and thMsg or enMsg, Color3.fromRGB(120, 170, 240))
		SaveCurrentChatToHistory()
		return
	end

	if HasAny(c, {"ขอบคุณ", "แต้ง", "thanks", "thank you", "thankyou", "thx", "ty"}) then
		return Reply(raw,
			"ยินดีครับผม! มีอะไรให้ช่วยอีกก็เรียกได้เลยนะ 😄",
			"You're welcome! Call me anytime you need help 😄")
	end

	if HasAny(c, {"บาย", "ลาก่อน", "ไปแล้ว", "ไปนอน", "bye", "goodbye", "goodnight", "gn", "cya", "see you"}) then
		return Reply(raw,
			"บายครับ! ไว้เจอกันใหม่ ขอให้สนุกกับเกมนะ 🎮",
			"Goodbye! See you next time, enjoy the game 🎮")
	end

	if HasAny(c, {"เก่ง", "สุดยอด", "เจ๋ง", "ฉลาด", "awesome", "amazing", "great", "cool", "smart", "op", "nice"}) then
		return Reply(raw,
			"เขินเลยครับเนี่ย ฮ่าๆ ระบบ Kuo Hub ซะอย่าง ต้องเก่งตามสคริปต์หน่อยล่ะ! 😎",
			"Haha, thanks! Gotta keep up with how powerful Kuo Hub is! 😎")
	end

	if HasAny(c, {"เบื่อ", "เหงา", "ไม่มีไรทำ", "bored", "boring"}) then
		return Reply(raw,
			"เบื่อเหรอครับ? ลองสลับไปโหมด CODE แล้วพิมพ์ <font color='#32CD96'>fly</font> ไปป่วนคนอื่นดูสิ รับรองหายเบื่อ! 555",
			"Bored? Switch to CODE mode and type <font color='#32CD96'>fly</font> — guaranteed fun! 😆")
	end

	if HasAny(c, {"รัก", "ชอบ", "น่ารัก", "love", "cute", "ilu"}) then
		return Reply(raw,
			"โอ้โห AI เขินแย่เลยนะเนี่ย! 💚 ขอให้ใช้ Kuo Hub ให้สนุกนะครับ",
			"Aww, you're making this AI blush! 💚 Enjoy using Kuo Hub!")
	end

	-- ตอบกลับแบบทั่วไป
	return Reply(raw,
		"ขอโทษด้วยนะครับ ผมยังไม่เข้าใจข้อความนี้ พิมพ์ <font color='#32CD96'>help</font> เพื่อดูสิ่งที่ผมทำได้ หรือสลับไปโหมด CODE เพื่อใช้คำสั่งโปรได้เลยครับ",
		"Sorry, I didn't quite get that. Type <font color='#32CD96'>help</font> to see what I can do, or switch to CODE mode for cheat commands!")
end

--=====================================================
-- CODE ENGINE (ไทย + อังกฤษ)
--=====================================================
local function ok(th, en)
	AddChatMessage("AI", isThai(CommandInput.Text) and th or en, Color3.fromRGB(50, 205, 150))
	SaveCurrentChatToHistory()
end
local function infoMsg(th, en)
	AddChatMessage("AI", isThai(CommandInput.Text) and th or en, Color3.fromRGB(180, 180, 180))
	SaveCurrentChatToHistory()
end
local function err(th, en)
	AddChatMessage("AI", isThai(CommandInput.Text) and th or en, Color3.fromRGB(255, 100, 100))
	SaveCurrentChatToHistory()
end

local COLOR_MAP = {
	{th = "แดง", en = "red", color = Color3.fromRGB(220, 20, 20)},
	{th = "เขียว", en = "green", color = Color3.fromRGB(20, 160, 60)},
	{th = "น้ำเงิน", en = "blue", color = Color3.fromRGB(20, 80, 220)},
	{th = "ฟ้า", en = "sky", color = Color3.fromRGB(50, 150, 255)},
	{th = "เหลือง", en = "yellow", color = Color3.fromRGB(240, 200, 20)},
	{th = "ชมพู", en = "pink", color = Color3.fromRGB(240, 50, 150)},
	{th = "ม่วง", en = "purple", color = Color3.fromRGB(150, 50, 240)},
	{th = "ขาว", en = "white", color = Color3.fromRGB(255, 255, 255)},
	{th = "ดำ", en = "black", color = Color3.fromRGB(0, 0, 0)},
	{th = "เทา", en = "gray", color = Color3.fromRGB(120, 120, 120)},
}

local function ProcessCode(raw)
	local c = string.lower(raw):gsub("['\"%,%.%-_?!]", "")
	local cs = c:gsub("%s+", " ")
	local cn = c:gsub("%s+", "")
	local num = tonumber(cn:match("%d+"))
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	-- ===== HELP =====
	if cn == "help" or HasAny(cs, {"คำสั่ง", "วิธีใช้", "รายการ", "command list"}) then
		ProcessTalk("help")
		return
	end

	-- ===== RESET =====
	if HasAny(cs, {"reset", "รีเซ็ต", "รีเซต", "ล้างค่า", "clear"}) then
		FullReset(false)
		return
	end

	-- ===== FLY (เชื่อมกับ setFly ของสคริปต์หลักถ้ามี) =====
	if HasAny(cs, {"ปิดบิน", "unfly", "stop fly", "land"}) then
		AI.Fly = false
		pcall(function() if typeof(setFly) == "function" then setFly(false) end end)
		if hum then hum.PlatformStand = false end
		infoMsg("ปิดระบบบินเรียบร้อย", "Fly disabled")
		return
	end
	if HasAny(cs, {"บิน", "fly"}) then
		AI.Fly = true
		local usedMain = pcall(function()
			if typeof(setFly) == "function" then setFly(true); return true end
			return false
		end)
		if not usedMain then
			if Conn.Fly then Conn.Fly:Disconnect() end
			Conn.Fly = RunService.RenderStepped:Connect(function()
				if AI.Fly and root and hum then
					hum.PlatformStand = true
					local cam = workspace.CurrentCamera
					local md = hum.MoveDirection
					local vel = Vector3.zero
					if md.Magnitude > 0 then
						local rel = cam.CFrame:VectorToObjectSpace(md)
						vel = (cam.CFrame.LookVector * (-rel.Z) + cam.CFrame.RightVector * rel.X).Unit * AI.FlySpeed
					end
					root.AssemblyLinearVelocity = vel
				end
			end)
		end
		ok("เปิดระบบบินเรียบร้อย! (กดปุ่ม F ของสคริปต์หลักก็ได้)", "Fly enabled! (you can also press F from the main script)")
		return
	end

	-- ===== SPEED =====
	if HasAny(cs, {"speed", "วิ่ง", "run", "ไว"}) then
		local v = num or 100
		AI.Speed = v
		ok("ตั้งความเร็ววิ่งเป็น "..v.." เรียบร้อย!", "Speed set to "..v.."!")
		return
	end

	-- ===== JUMP =====
	if HasAny(cs, {"jump", "โดด", "กระโดด"}) and not HasAny(cs, {"infjump", "ไม่จำกัด", "โดดรัว"}) then
		local v = num or 100
		AI.Jump = v
		ok("ตั้งพลังโดดเป็น "..v.." เรียบร้อย!", "Jump power set to "..v.."!")
		return
	end

	-- ===== INFINITE JUMP =====
	if HasAny(cs, {"infjump", "โดดไม่จำกัด", "โดดรัว", "กระโดดรัว", "infinite jump"}) then
		AI.InfJump = not AI.InfJump
		if AI.InfJump then
			if Conn.InfJump then Conn.InfJump:Disconnect() end
			Conn.InfJump = UserInputService.JumpRequest:Connect(function()
				local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if AI.InfJump and h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
			ok("เปิดโดดไม่จำกัดเรียบร้อย!", "Infinite jump enabled!")
		else
			if Conn.InfJump then Conn.InfJump:Disconnect(); Conn.InfJump = nil end
			infoMsg("ปิดโดดไม่จำกัดแล้ว", "Infinite jump disabled")
		end
		return
	end

	-- ===== NOCLIP =====
	if HasAny(cs, {"noclip", "ทะลุ", "ทะลุกำแพง", "เดินทะลุ", "wallhack walk"}) then
		AI.Noclip = not AI.Noclip
		if AI.Noclip then
			if Conn.Noclip then Conn.Noclip:Disconnect() end
			Conn.Noclip = RunService.Stepped:Connect(function()
				local ch = LocalPlayer.Character
				if ch then
					for _, v in pairs(ch:GetDescendants()) do
						if v:IsA("BasePart") then v.CanCollide = false end
					end
				end
			end)
			ok("เปิดทะลุกำแพงเรียบร้อย!", "Noclip enabled!")
		else
			if Conn.Noclip then Conn.Noclip:Disconnect(); Conn.Noclip = nil end
			infoMsg("ปิดทะลุกำแพงแล้ว", "Noclip disabled")
		end
		return
	end

	-- ===== ESP =====
	if HasAny(cs, {"unesp", "ปิดมอง", "ปิดesp", "เลิกมอง"}) then
		AI.ESP = false
		UpdateESP()
		infoMsg("ปิดมองทะลุแล้ว", "ESP disabled")
		return
	end
	if HasAny(cs, {"esp", "มอง", "มองทะลุ", "ไฮไลท์", "highlight"}) then
		local chosen = COLOR_MAP[1]
		for _, data in ipairs(COLOR_MAP) do
			if cs:find(data.th) or cs:find(data.en) then
				chosen = data
				break
			end
		end
		AI.ESP = true
		AI.ESPColor = chosen.color
		AI.ESPColorName = chosen.en.."/"..chosen.th
		UpdateESP()
		ok("เปิดมองทะลุสี "..chosen.th.." ("..chosen.en..") เรียบร้อย!", "ESP enabled: "..chosen.en)
		return
	end

	-- ===== HITBOX =====
	if HasAny(cs, {"hitbox", "ฮิต", "ตัวใหญ่", "หัวโต"}) then
		local v = num or 10
		AI.Hitbox = v
		ok("ขยายฮิตบ็อกซ์เป็น "..v.." เรียบร้อย!", "Hitbox expanded to "..v.."!")
		return
	end

	-- ===== SPIN =====
	if HasAny(cs, {"unspin", "ปิดสปิน", "หยุดหมุน"}) then
		AI.Spin = false
		infoMsg("ปิดสปินบอทแล้ว", "Spin bot disabled")
		return
	end
	if HasAny(cs, {"spin", "สปิน", "หมุน", "spinbot"}) then
		AI.Spin = true
		ok("เปิดสปินบอทเรียบร้อย!", "Spin bot enabled!")
		return
	end

	-- ===== BRIGHT =====
	if HasAny(cs, {"unbright", "ปิดสว่าง", "มืด"}) then
		AI.Bright = false
		if Conn.Bright then Conn.Bright:Disconnect(); Conn.Bright = nil end
		Lighting.GlobalShadows = true
		infoMsg("ปิดสว่างสุดแล้ว", "Fullbright disabled")
		return
	end
	if HasAny(cs, {"bright", "สว่าง", "สว่างสุด", "fullbright"}) then
		AI.Bright = true
		if Conn.Bright then Conn.Bright:Disconnect() end
		Conn.Bright = RunService.RenderStepped:Connect(function()
			if AI.Bright then
				Lighting.Brightness = 2
				Lighting.ClockTime = 14
				Lighting.GlobalShadows = false
				Lighting.FogEnd = 999999
			end
		end)
		ok("เปิดสว่างสุดทั้งแมปเรียบร้อย!", "Fullbright enabled!")
		return
	end

	-- ===== GOD =====
	if HasAny(cs, {"god", "อมตะ", "เลือดอนันต์", "ไม่ตาย", "godmode"}) then
		AI.God = true
		if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
		ok("เปิดโหมดอมตะเรียบร้อย!", "God mode enabled!")
		return
	end

	-- ===== INVISIBLE (เชื่อมกับ applyInvisible ของสคริปต์หลัก) =====
	if HasAny(cs, {"invisible", "ล่องหน", "มองไม่เห็น", "หายตัว"}) then
		local used = pcall(function() if typeof(applyInvisible) == "function" then applyInvisible(true); return true end return false end)
		ok("เปิดโหมดล่องหนเรียบร้อย!", "Invisible mode enabled!")
		return
	end
	if HasAny(cs, {"uninvisible", "ปิดล่องหน", "เลิกล่องหน", "มาเห็น"}) then
		pcall(function() if typeof(applyInvisible) == "function" then applyInvisible(false) end end)
		infoMsg("ปิดล่องหนแล้ว", "Invisible mode disabled")
		return
	end

	-- ===== WARP =====
	if HasAny(cs, {"warp", "วาป", "วาร์ป", "ไปหา", "teleport", "goto"}) then
		local found = nil
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				local nm = string.lower(p.Name)
				local dn = string.lower(p.DisplayName)
				if nm ~= "" and (cs:find(nm, 1, true) or cs:find(dn, 1, true)) then
					found = p
					break
				end
			end
		end
		if found and found.Character and found.Character:FindFirstChild("HumanoidRootPart") and root then
			root.CFrame = found.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
			ok("วาร์ปไปหา "..found.DisplayName.." เรียบร้อย!", "Teleported to "..found.DisplayName.."!")
		else
			err("ไม่พบผู้เล่นนี้ พิมพ์ / เพื่อเลือกจากรายชื่อ", "Player not found. Type / to pick from the list.")
		end
		return
	end

	err("ไม่พบคำสั่งนี้ พิมพ์ help เพื่อดูรายการคำสั่งทั้งหมด",
		"Unknown command. Type help to see all commands.")
end

--=====================================================
-- SUBMIT
--=====================================================
local function OnSubmit()
	local text = CommandInput.Text
	if text and text ~= "" then
		AddChatMessage("You", text, Color3.fromRGB(240, 240, 240))
		SaveCurrentChatToHistory()
		CommandInput.Text = ""
		SuggestionBox.Visible = false
		task.wait(0.05)
		if CurrentMode == "TALK" then
			ProcessTalk(text)
		else
			ProcessCode(text)
		end
	end
end

SendBtn.MouseButton1Click:Connect(OnSubmit)
CommandInput.FocusLost:Connect(function(enter) if enter then OnSubmit() end end)

--=====================================================
-- OPEN / CLOSE / MINIMIZE
--=====================================================
local isOpen, isTweening = true, false

local function OpenUI()
	if isTweening or isOpen then return end
	isTweening, isOpen = true, true
	MinBtn.Visible = false
	MainFrame.Size = UDim2.new(0, 0, 0, 0)
	MainFrame.Visible = true
	local tw = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = NormalSize})
	tw:Play()
	tw.Completed:Connect(function() isTweening = false end)
end

local function MinimizeUI()
	if isTweening or not isOpen then return end
	isTweening, isOpen = true, false
	SuggestionBox.Visible = false
	ModeDropdown.Visible = false
	local tw = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
	tw:Play()
	tw.Completed:Connect(function()
		MainFrame.Visible = false
		MinBtn.Visible = true
		isTweening = false
	end)
end

MinimizeBtn.MouseButton1Click:Connect(MinimizeUI)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinBtn.MouseButton1Click:Connect(OpenUI)

UserInputService.InputBegan:Connect(function(i, g)
	if not g and i.KeyCode == Enum.KeyCode.RightShift then
		if isOpen then MinimizeUI() else OpenUI() end
	end
end)

-- เปิด UI ตอนเริ่ม
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Visible = true
TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = NormalSize}):Play()

end
end
end)
