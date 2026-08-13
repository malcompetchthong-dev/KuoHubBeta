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



  
        
if            
