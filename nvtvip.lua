-- ==========================================
-- TRNH V. THANG HUB - PREMIUM AUTO FARM
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.AutoFarm = false
_G.Distance = 5 -- Khoảng cách bay lơ lửng trên đầu quái

-- [GIAO DIỆN CHÍNH CHỦ TRNH V. THANG]
local Window = Rayfield:CreateWindow({
   Name = "Trnh V. Thang Hub 👑",
   LoadingTitle = "Trnh V. Thang đang tải hệ thống...",
   LoadingSubtitle = "Phiên bản Độc Quyền iOS",
   ConfigurationSaving = { Enabled = false }
})

local FarmTab = Window:CreateTab("Auto Farm", 4483345998)

FarmTab:CreateToggle({
   Name = "Bật/Tắt Auto Farm Quái",
   CurrentValue = false,
   Flag = "ToggleAutoFarm",
   Callback = function(Value)
      _G.AutoFarm = Value
   end,
})

-- [HÀM HỖ TRỢ] - Tự động cầm vũ khí trên tay
local function EquipWeapon()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            Character.Humanoid:EquipTool(tool)
            break
        end
    end
end

-- [HÀM HỖ TRỢ] - Tìm radar quái vật gần nhất
local function GetTarget()
    -- Lọc thư mục chuẩn của King Legacy
    local MonsterFolder = workspace:FindFirstChild("Monster") or workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs")
    if not MonsterFolder then return nil end
    
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closestMob = nil
    local shortestDistance = math.huge
    
    for _, mob in pairs(MonsterFolder:GetDescendants()) do
        if mob:IsA("Model") and mob ~= Character then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            local mobHum = mob:FindFirstChild("Humanoid")
            
            -- Đảm bảo quái còn sống
            if mobRoot and mobHum and mobHum.Health > 0 then
                local distance = (mobRoot.Position - Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    closestMob = mob
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestMob
end

-- [VÒNG LẶP LÕI AUTO FARM]
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local Character = LocalPlayer.Character
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then continue end
            
            local MyRoot = Character.HumanoidRootPart
            local TargetMob = GetTarget()
            
            if TargetMob then
                local MobRoot = TargetMob:FindFirstChild("HumanoidRootPart")
                if MobRoot then
                    -- Bay lơ lửng trên đầu quái để né đòn
                    MyRoot.CFrame = MobRoot.CFrame * CFrame.new(0, _G.Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Khóa tọa độ Y (Chống rơi rớt khi farm)
                    MyRoot.Velocity = Vector3.new(0,0,0)
                    
                    -- Rút vũ khí ra
                    EquipWeapon()
                    
                    -- Kích hoạt đòn đánh (M1) liên tục
                    local Tool = Character:FindFirstChildOfClass("Tool")
                    if Tool then
                        Tool:Activate()
                    end
                end
            end
        end
    end
end)
