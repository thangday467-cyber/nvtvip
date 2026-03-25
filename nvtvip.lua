local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- 1. Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),Workspace.CurrentCamera.CFrame)
end)

-- Xóa UI cũ nếu lỡ chạy lại script
if CoreGui:FindFirstChild("ThangHub_FPS_Saver") then
    CoreGui.ThangHub_FPS_Saver:Destroy()
end

-- 2. Tạo giao diện
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThangHub_FPS_Saver"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true 

-- Lớp rèm đen che màn hình
local BlackFrame = Instance.new("Frame")
BlackFrame.Parent = ScreenGui
BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) 
BlackFrame.Size = UDim2.new(1, 0, 1, 0) 
BlackFrame.Visible = false 
BlackFrame.ZIndex = 1 

-- NÚT 1: Tắt 3D & Dọn RAM
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0, 20, 0, 50)
ToggleButton.Size = UDim2.new(0, 140, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Tắt 3D & Dọn RAM"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 13
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.ZIndex = 2 

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 8)
UICorner1.Parent = ToggleButton

-- NÚT 2: Bật/Tắt Auto Skill Z (Nằm dưới nút 1)
local AutoSkillButton = Instance.new("TextButton")
AutoSkillButton.Parent = ScreenGui
AutoSkillButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AutoSkillButton.Position = UDim2.new(0, 20, 0, 100)
AutoSkillButton.Size = UDim2.new(0, 140, 0, 40)
AutoSkillButton.Font = Enum.Font.GothamBold
AutoSkillButton.Text = "Bật Auto Control (Z)"
AutoSkillButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoSkillButton.TextSize = 13
AutoSkillButton.Active = true
AutoSkillButton.Draggable = true
AutoSkillButton.ZIndex = 2 

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = AutoSkillButton

local isOptimized = false
local isAutoSkill = false

-- 3. Hàm siêu dọn rác
local function OptimizeRAM()
    Lighting.GlobalShadows = false
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
end

-- 4. Vòng lặp Auto dùng chiêu Z của Control mỗi 30s
task.spawn(function()
    local player = Players.LocalPlayer
    while task.wait(30) do
        -- Chỉ hoạt động khi bạn bấm nút bật Auto (Nút 2)
        if isAutoSkill then 
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                
                -- Tìm Control trong balo hoặc tay
                local tool = nil
                for _, v in pairs(player.Backpack:GetChildren()) do
                    if v.Name:match("Control") then tool = v break end
                end
                if not tool then
                    for _, v in pairs(character:GetChildren()) do
                        if v.Name:match("Control") then tool = v break end
                    end
                end
                
                if humanoid and tool then
                    humanoid:EquipTool(tool)
                    task.wait(0.5) 
                    
                    -- Bấm phím Z
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                end
            end
        end
    end
end)

-- 5. Lệnh thực thi Nút 1 (Đen màn hình)
ToggleButton.MouseButton1Click:Connect(function()
    isOptimized = not isOptimized
    
    if isOptimized then
        OptimizeRAM() 
        setfpscap(5)
        RunService:Set3dRenderingEnabled(false)
        settings().Rendering.QualityLevel = "Level01"
        BlackFrame.Visible = true 
        
        ToggleButton.Text = "Bật lại 3D & 60 FPS"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- Chuyển màu đỏ
    else
        setfpscap(60) 
        RunService:Set3dRenderingEnabled(true)
        settings().Rendering.QualityLevel = "Automatic" 
        BlackFrame.Visible = false 
        
        ToggleButton.Text = "Tắt 3D & Dọn RAM"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

-- 6. Lệnh thực thi Nút 2 (Auto Z)
AutoSkillButton.MouseButton1Click:Connect(function()
    isAutoSkill = not isAutoSkill
    
    if isAutoSkill then
        AutoSkillButton.Text = "Đang Auto Z (Tắt)"
        AutoSkillButton.BackgroundColor3 = Color3.fromRGB(40, 160, 40) -- Chuyển màu xanh lá
    else
        AutoSkillButton.Text = "Bật Auto Control (Z)"
        AutoSkillButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)
