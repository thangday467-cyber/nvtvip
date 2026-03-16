-- ==========================================
-- TRNH V. THANG HUB - VIP AUTO RAID (Sinh Tồn + Chọn Vũ Khí)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

_G.AutoRaid = false
_G.SelectedWeapon = ""
_G.HideHealth = 30 
_G.IsHiding = false 
_G.SafeZone = CFrame.new(0, 5000, 0) 

_G.UseZ = false
_G.UseX = false
_G.UseC = false
_G.UseV = false
_G.UseE = false

local Window = Rayfield:CreateWindow({
   Name = "Trnh V. Thang Hub 👑 | VIP",
   LoadingTitle = "Đang tải hệ thống VIP...",
   LoadingSubtitle = "Phiên bản Độc Quyền",
   ConfigurationSaving = { Enabled = false }
})

local RaidTab = Window:CreateTab("Auto Raid", 4483345998)

-- [TÍNH NĂNG CHỌN VŨ KHÍ]
local WeaponList = {}
local WeaponDropdown = RaidTab:CreateDropdown({
   Name = "Chọn Vũ Khí Để Farm",
   Options = {"Chưa tải vũ khí"},
   CurrentOption = {"Chưa tải vũ khí"},
   MultipleOptions = false,
   Flag = "WeaponSelect",
   Callback = function(Option)
      _G.SelectedWeapon = Option[1]
   end,
})

RaidTab:CreateButton({
   Name = "Làm Mới Danh Sách Vũ Khí",
   Callback = function()
      table.clear(WeaponList)
      for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
         if tool:IsA("Tool") then table.insert(WeaponList, tool.Name) end
      end
      local char = LocalPlayer.Character
      if char then
          for _, tool in pairs(char:GetChildren()) do
             if tool:IsA("Tool") then table.insert(WeaponList, tool.Name) end
          end
      end
      WeaponDropdown:Refresh(WeaponList)
   end,
})

RaidTab:CreateToggle({
   Name = "🔥 Bật/Tắt Auto Raid 🔥",
   CurrentValue = false,
   Flag = "ToggleAutoRaid",
   Callback = function(Value)
      _G.AutoRaid = Value
   end,
})

RaidTab:CreateSlider({
   Name = "Mức máu đi trốn (%)",
   Info = "Dưới mức này sẽ bay lên trời trốn",
   Min = 10,
   Max = 90,
   CurrentValue = 30,
   Flag = "SliderHealth",
   Callback = function(Value)
      _G.HideHealth = Value
   end,
})

local SkillTab = Window:CreateTab("Cài Đặt Chiêu", 4483345998)
SkillTab:CreateToggle({Name = "Tự động xả chiêu Z", CurrentValue = false, Flag = "Z", Callback = function(v) _G.UseZ = v end})
SkillTab:CreateToggle({Name = "Tự động xả chiêu X", CurrentValue = false, Flag = "X", Callback = function(v) _G.UseX = v end})
SkillTab:CreateToggle({Name = "Tự động xả chiêu C", CurrentValue = false, Flag = "C", Callback = function(v) _G.UseC = v end})
SkillTab:CreateToggle({Name = "Tự động xả chiêu V", CurrentValue = false, Flag = "V", Callback = function(v) _G.UseV = v end})
SkillTab:CreateToggle({Name = "Tự động xả chiêu E", CurrentValue = false, Flag = "E", Callback = function(v) _G.UseE = v end})

local function EquipTargetWeapon()
    local char = LocalPlayer.Character
    if char and _G.SelectedWeapon ~= "" and _G.SelectedWeapon ~= "Chưa tải vũ khí" then
        local toolInBackpack = LocalPlayer.Backpack:FindFirstChild(_G.SelectedWeapon)
        if toolInBackpack then
            char.Humanoid:EquipTool(toolInBackpack)
        end
    end
end

local function FireSkill(Key)
    VirtualInputManager:SendKeyEvent(true, Key, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Key, false, game)
end

local function AutoSpamSkills()
    if _G.UseZ then FireSkill(Enum.KeyCode.Z) end
    if _G.UseX then FireSkill(Enum.KeyCode.X) end
    if _G.UseC then FireSkill(Enum.KeyCode.C) end
    if _G.UseV then FireSkill(Enum.KeyCode.V) end
    if _G.UseE then FireSkill(Enum.KeyCode.E) end
end

local function GetTarget()
    local MonsterFolder = workspace:FindFirstChild("Monster") or workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs")
    if not MonsterFolder then return nil end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local closest, shortest = nil, math.huge
    for _, mob in pairs(MonsterFolder:GetDescendants()) do
        if mob:IsA("Model") and mob ~= char then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            local mobHum = mob:FindFirstChild("Humanoid")
            if mobRoot and mobHum and mobHum.Health > 0 then
                local dist = (mobRoot.Position - char.HumanoidRootPart.Position).Magnitude
                if dist < shortest then closest, shortest = mob, dist end
            end
        end
    end
    return closest
end

task.spawn(function()
    while task.wait() do
        if _G.AutoRaid then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local Hum = char:FindFirstChild("Humanoid")
            local Root = char.HumanoidRootPart
            
            if Hum then
                local hpPercent = (Hum.Health / Hum.MaxHealth) * 100
                if hpPercent <= _G.HideHealth then
                    _G.IsHiding = true
                elseif hpPercent >= 95 then 
                    _G.IsHiding = false
                end
                
                if _G.IsHiding then
                    Root.CFrame = _G.SafeZone
                    Root.Velocity = Vector3.new(0,0,0)
                    continue 
                end
            end
            
            local TargetMob = GetTarget()
            if TargetMob then
                local MobRoot = TargetMob:FindFirstChild("HumanoidRootPart")
                if MobRoot then
                    Root.CFrame = MobRoot.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    Root.Velocity = Vector3.new(0,0,0)
                    
                    EquipTargetWeapon()
                    
                    local equippedTool = char:FindFirstChild(_G.SelectedWeapon)
                    if equippedTool then equippedTool:Activate() end
                    
                    AutoSpamSkills()
                end
            end
        end
    end
end)
