-- =========================    
-- KUO HUB PRO LOADER (ULTRA FINAL)
-- =========================    
local TweenService = game:GetService("TweenService")    
local player = game.Players.LocalPlayer    

-- GUI    
local gui = Instance.new("ScreenGui")    
gui.Name = "KuoLoaderPro"    
gui.ResetOnSpawn = false    
gui.Parent = player:WaitForChild("PlayerGui")    

-- MAIN FRAME    
local frame = Instance.new("Frame")    
frame.Size = UDim2.new(0, 420, 0, 220)    
frame.Position = UDim2.new(0.5, -210, 0.5, -110)    
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)    
frame.BorderSizePixel = 0    
frame.Parent = gui    
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)    

-- GRADIENT    
local gradient = Instance.new("UIGradient")    
gradient.Color = ColorSequence.new{    
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,170,255)),    
    ColorSequenceKeypoint.new(1, Color3.fromRGB(170,0,255))    
}    
gradient.Rotation = 45    
gradient.Parent = frame    

-- GLOW    
local stroke = Instance.new("UIStroke")    
stroke.Thickness = 2    
stroke.Color = Color3.fromRGB(0,170,255)    
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border    
stroke.Parent = frame    

-- TITLE    
local title = Instance.new("TextLabel")    
title.Size = UDim2.new(1,0,0,40)    
title.BackgroundTransparency = 1    
title.Text = "Kuo Hub [BETA]"    
title.TextColor3 = Color3.fromRGB(255,255,255)    
title.Font = Enum.Font.GothamBold    
title.TextSize = 22    
title.Parent = frame    

-- LOADING TEXT    
local loadingText = Instance.new("TextLabel")    
loadingText.Position = UDim2.new(0,0,0,50)    
loadingText.Size = UDim2.new(1,0,0,30)    
loadingText.BackgroundTransparency = 1    
loadingText.Text = "Loading..."    
loadingText.TextColor3 = Color3.fromRGB(200,200,200)    
loadingText.Font = Enum.Font.Gotham    
loadingText.TextSize = 18    
loadingText.Parent = frame    

-- MESSAGE    
local message = Instance.new("TextLabel")    
message.Position = UDim2.new(0.05,0,0.7,0)    
message.Size = UDim2.new(0.9,0,0,50)    
message.BackgroundTransparency = 1    
message.TextColor3 = Color3.fromRGB(220,220,220)    
message.Font = Enum.Font.Gotham    
message.TextSize = 16    
message.TextWrapped = true    
message.Text = ""    
message.Parent = frame    

-- BAR BG    
local barBG = Instance.new("Frame")    
barBG.Position = UDim2.new(0.1,0,0.55,0)    
barBG.Size = UDim2.new(0.8,0,0,18)    
barBG.BackgroundColor3 = Color3.fromRGB(40,40,40)    
barBG.BorderSizePixel = 0    
barBG.Parent = frame    
Instance.new("UICorner", barBG).CornerRadius = UDim.new(1,0)    

-- BAR    
local bar = Instance.new("Frame")    
bar.Size = UDim2.new(0,0,1,0)    
bar.BackgroundColor3 = Color3.fromRGB(0,170,255)    
bar.BorderSizePixel = 0    
bar.Parent = barBG    
Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)    

-- BAR GRADIENT    
local barGrad = Instance.new("UIGradient")    
barGrad.Color = ColorSequence.new{    
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,170,255)),    
    ColorSequenceKeypoint.new(1, Color3.fromRGB(170,0,255))    
}    
barGrad.Parent = bar    

-- =========================    
-- TYPEWRITER (UTF8 FIX)
-- =========================    
local typingId = 0    

local function typeText(label, text)    
    typingId += 1    
    local id = typingId    

    label.Text = ""    

    task.spawn(function()    
        for _, char in utf8.codes(text) do    
            if id ~= typingId then return end    
            label.Text ..= utf8.char(char)    
            task.wait(0.02)    
        end    
    end)    
end    

-- =========================    
-- MESSAGE LOOP    
-- =========================    
local messages = {        
    "ขอบคุณที่เข้าร่วม Kuo Hub รุ่น Beta",        
    "Thank you for joining Kuo Hub Beta",        
    "พบ Bug แจ้งได้ที่ Discord Kuo Hub",        
    "Report bugs on Kuo Hub Discord",    
    "รู้หรือไม่ว่าถ้าคุณใช้ Kuo Hub Beta คุณจะได้รับฟีเจอร์ใหม่และรองรับแมพใหม่ก่อนใคร",    
    "Did you know? Using Kuo Hub Beta gives you early access to new features and new map support"
}

local index = 1    

task.spawn(function()    
    while true do    
        local text = messages[index]    
        typeText(message, text)    

        task.wait(utf8.len(text) * 0.04 + 1)    

        index += 1    
        if index > #messages then index = 1 end    
    end    
end)    

-- =========================    
-- LOADING BAR    
-- =========================    
for i = 1,100 do      
    TweenService:Create(bar, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {      
        Size = UDim2.new(i/100,0,1,0)      
    }):Play()      

    loadingText.Text = "Loading... "..i.."%"      
    task.wait(0.08)      
end      

loadingText.Text = "Complete!"    

-- =========================    
-- LOAD SCRIPT    
-- =========================    
task.spawn(function()
loadstring([[local MAPBF = game.GameId == 994732206  
local MAPKL = (game.PlaceId == 4520749081 or game.PlaceId == 6381829480 or game.PlaceId == 5931540094 or game.PlaceId == 6596144663 or game.PlaceId == 15759515082)  
local MAPBLADEB = game.CreatorId == 12836673  
local MAPAFS = game.PlaceId == 6299805723  
local MAPRGH = game.PlaceId == 914010731  
local MAPHAZEP = game.PlaceId == 6918802270 or game.PlaceId == 14979402479  
local MAPALS = game.CreatorId == 12229756  
local DRIVEEMPIRE = game.PlaceId == 3351674303  
local SOLRNG = game.PlaceId == 15532962292  
local TITAN = game.CreatorId == 17347863  
local AD = game.CreatorId == 34121350  
local AV = game.CreatorId == 17219742  
local Fish = game.CreatorId == 7381705 or game.PlaceId == 16732694052  
local AA = game.CreatorId == 10611639  
local BL = game.GameId == 6325068386  
local AC = game.GameId == 7074860883 or game.PlaceId == 87039211657390  
local BS = game.GameId == 7436755782 or game.CreatorId == 33720745  
local GAG = game.PlaceId == 126884695634066  
local ASTDX = game.GameId == 6057699512  
local days99 = game.GameId == 7326934954  
local ZOmBie = game.GameId == 7750955984  
local FishIt = game.GameId == 121864768012064  
local BAZ = game.GameId == 8066283370  
local MM2 = game.GameId == 66654135 or game.PlaceId == 142823291  
Local DEADRAILS = (game.PlaceId == 116495829188952) or (game.GameId == 7018190066)
                      
repeat task.wait() until game:IsLoaded()  
  
if MAPBF then  
loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/KuoHubBeta/refs/heads/main/BF.lua", true))()  
  
elseif MAPKL then  
loadstring(game:HttpGet("https://raw.githubusercontent.com/xshiba/CreamSoScute/main/LoadKL.lua", true))()  
  
elseif MM2 then  
loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/KuoHubBeta/refs/heads/main/MM2.lua", true))()  

elseif DEADRAILS then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/KuoHubBeta/refs/heads/main/DeadRails.lua", true))()
            
elseif (MAPBLADEB or MAPAFS or MAPRGH or MAPHAZEP or MAPALS or DRIVEEMPIRE or SOLRNG or TITAN or MS or AV or PG or Fish or Jujutsu or AA or BL or AD or AC or HT or ARX or BS or GAG or ASTDX or days99 or ZOmBie or game.GameId == 6701277882 or BAZ or game.GameId == 7671049560 or game.GameId == 7394964165 or game.GameId == 8144728961 or game.GameId == 5130394318) then  
loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/KuoHubBeta/refs/heads/main/99Nights.lua", true))()  
  
else  
loadstring(game:HttpGet("https://raw.githubusercontent.com/malcompetchthong-dev/KuoHubBeta/refs/heads/main/MAPALL.lua"))()  
    end]])()
end)

-- =========================    
-- FADE OUT    
-- =========================    
task.wait(0.5)

for i = 1,20 do    
    frame.BackgroundTransparency += 0.05    
    title.TextTransparency += 0.05    
    loadingText.TextTransparency += 0.05    
    message.TextTransparency += 0.05    
    bar.BackgroundTransparency += 0.05    
    barBG.BackgroundTransparency += 0.05    
    task.wait(0.03)    
end    

gui:Destroy()
