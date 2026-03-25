-- ========================================== --
-- NVT VIP HUB - EXPERT EDITION (MOBILE OPTIMIZED)
-- ========================================== --

task.wait(1) -- Đợi game ổn định luồng trước khi inject

local Services = setmetatable({}, {
    __index = function(_, service)
        return game:GetService(service)
    end
})

local Players = Services.Players
local RunService = Services.RunService
local Lighting = Services.Lighting
local Workspace = Services.Workspace
local VirtualInputManager = Services.VirtualInputManager
local VirtualUser = Services.VirtualUser
local Stats = Services.Stats
local StarterGui = Services.StarterGui

local LocalPlayer = Players.LocalPlayer

-- ================= HỆ THỐNG BYPASS UI ================= --
local function GetSafeUIParent()
    local success, parent = pcall(function() return gethui and gethui() end)
    if success and parent then return parent end
    
    success, parent = pcall(function() return Services.CoreGui end)
    if success and parent then return parent end
    
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = GetSafeUIParent()

-- Xóa rác từ phiên bản cũ (nếu có)
for _, child in ipairs(GuiParent:GetChildren()) do
    if child.Name == "NVT_Expert_Hub" then
        child:Destroy()
    end
end

-- ================= KHỞI TẠO GIAO DIỆN ================= --
local HubGui = Instance.new("ScreenGui")
HubGui.Name = "NVT_Expert_Hub"
HubGui.ResetOnSpawn = false
HubGui.IgnoreGuiInset = true
HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
HubGui.Parent = GuiParent

-- Tấm rèm đen (tiết kiệm pin)
local BlackScreen = Instance.new("Frame")
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.BackgroundColor3 = Color3.new(0, 0, 0)
BlackScreen.Visible = false
BlackScreen.ZIndex = 999
BlackScreen.Parent = HubGui

-- Hàm tiện ích tạo UI
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

-- Nút mở Menu (NVT)
local OpenBtn = Create("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 50, 0, 50), -- Đặt rõ ràng ở góc trái trên
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    Text = "NVT",
    TextColor3 = Color3.fromRGB(0, 255, 128),
    Font = Enum.Font.GothamBlack,
    TextSize = 16,
    Draggable = true,
    Active = true,
    ZIndex = 10000,
    Parent = HubGui
})
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- Khung Menu Chính
local MainFrame = Create("Frame", {
    Size = UDim2.new(0, 260, 0, 250),
    Position = UDim2.new(0.5, -130, 0.5, -125),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Draggable = true,
    Active = true,
    Visible = false,
    ZIndex = 10001,
    Parent = HubGui
})
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Tiêu đề
Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = "NVT VIP HUB",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    ZIndex = 10002,
    Parent = MainFrame
})
Create("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(0, 255, 128),
    BorderSizePixel = 0,
    ZIndex = 10002,
    Parent = MainFrame
})

-- Hiển thị FPS & Ping (Tránh lỗi chia 0)
local StatsLabel = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 45),
    BackgroundTransparency = 1,
    Text = "Loading Stats...",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    Font = Enum.Font.GothamSemibold,
    TextSize = 12,
    RichText = true,
    ZIndex = 10002,
    Parent = MainFrame
})

-- ================= LOGIC NÚT BẤM ================= --
local State = { Optimize = false, AutoZ = false }

local function CreateToggle(yPos, text, varName, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(0.9, 0, 0, 40),
        Position = UDim2.new(0.05, 0, 0, yPos),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Text = text,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        ZIndex = 10002,
        Parent = MainFrame
    })
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        State[varName] = not State[varName]
        if State[varName] then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        task.spawn(callback, State[varName])
    end)
end

-- Tính năng 1: Siêu tối ưu
CreateToggle(75, "Màn Đen & Ép 5 FPS", "Optimize", function(isOn)
    BlackScreen.Visible = isOn
    if isOn then
        pcall(function() setfpscap(5) end)
        pcall(function() RunService:Set3dRenderingEnabled(false) end)
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        pcall(function() Lighting.GlobalShadows = false end)
    else
        pcall(function() setfpscap(60) end)
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
        pcall(function() settings().Rendering.QualityLevel = "Automatic" end)
    end
end)

-- Tính năng 2: Auto Z
CreateToggle(125, "Bật Auto Control (Z)", "AutoZ", function() end)

-- Nút Đóng
local CloseBtn = Create("TextButton", {
    Size = UDim2.new(0.9, 0, 0, 40),
    Position = UDim2.new(0.05, 0, 0, 185),
    BackgroundColor3 = Color3.fromRGB(180, 50, 50),
    Text = "Ẩn Menu Chính",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    ZIndex = 10002,
    Parent = MainFrame
})
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ================= VÒNG LẶP HỆ THỐNG ================= --

-- Anti AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Cập nhật thông số FPS/Ping an toàn
RunService.RenderStepped:Connect(function()
    local ping = 0
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    
    -- Dùng hàm GetRealPhysicsFPS để đo FPS chuẩn hơn trên điện thoại
    local fps = math.floor(Workspace:GetRealPhysicsFPS())
    
    if fps <= 15 then
        StatsLabel.Text = "FPS: <font color='rgb(255,80,80)'>"..fps.."</font> | Ping: "..ping.."ms"
    else
        StatsLabel.Text = "FPS: <font color='rgb(80,255,80)'>"..fps.."</font> | Ping: "..ping.."ms"
    end
end)

-- Vòng lặp Auto Z thông minh
task.spawn(function()
    while task.wait(30) do
        if State.AutoZ and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local tool = nil
            
            -- Quét kho đồ và trên tay
            for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") and string.find(string.lower(v.Name), "control") then tool = v break end
            end
            if not tool then
                for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("Tool") and string.find(string.lower(v.Name), "control") then tool = v break end
                end
            end
            
            if humanoid and tool then
                pcall(function()
                    humanoid:EquipTool(tool)
                    task.wait(1.5) -- Cho game thời gian gắn tool vào tay
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                end)
            end
        end
    end
end)

-- Gửi thông báo hoàn tất
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NVT HUB ACTIVE",
        Text = "Hệ thống đã chạy, vui lòng tìm nút NVT trên màn hình.",
        Duration = 5
    })
end)
