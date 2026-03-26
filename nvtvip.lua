-- ========================================== --
-- NVT VIP HUB - EXPERT EDITION (SIMPLIFIED AUTO Z)
-- Tối ưu hóa: Bấm phím 1 -> Bấm phím Z mỗi 10 giây
-- ========================================== --

task.wait(1) 

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

for _, child in ipairs(GuiParent:GetChildren()) do
    if child.Name == "NVT_Expert_Hub" then child:Destroy() end
end

-- ================= KHỞI TẠO GIAO DIỆN ================= --
local HubGui = Instance.new("ScreenGui")
HubGui.Name = "NVT_Expert_Hub"
HubGui.ResetOnSpawn = false
HubGui.IgnoreGuiInset = true
HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
HubGui.Parent = GuiParent

local BlackScreen = Instance.new("Frame")
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.BackgroundColor3 = Color3.new(0, 0, 0)
BlackScreen.Visible = false
BlackScreen.ZIndex = 999
BlackScreen.Parent = HubGui

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local OpenBtn = Create("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 50, 0, 50), 
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

-- Đổi tên nút thành 10 giây
CreateToggle(125, "Bật Auto 1 & Z (10s)", "AutoZ", function() end)

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

pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

RunService.RenderStepped:Connect(function()
    local ping = 0
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    local fps = math.floor(Workspace:GetRealPhysicsFPS())
    if fps <= 15 then
        StatsLabel.Text = "FPS: <font color='rgb(255,80,80)'>"..fps.."</font> | Ping: "..ping.."ms"
    else
        StatsLabel.Text = "FPS: <font color='rgb(80,255,80)'>"..fps.."</font> | Ping: "..ping.."ms"
    end
end)

-- ================= VÒNG LẶP AUTO 1 VÀ Z ĐƠN GIẢN ================= --
task.spawn(function()
    while task.wait(10) do -- Lặp lại mỗi 10 giây
        if State.AutoZ then
            pcall(function()
                -- 1. Giả lập bấm phím số 1 (Để trang bị đồ ở ô đầu tiên)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                
                -- Đợi 1 giây cho nhân vật rút vũ khí ra xong
                task.wait(1) 
                
                -- 2. Giả lập bấm phím Z (Kích hoạt chiêu thức)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                
                -- 3. Click chuột để nhả chiêu (dành cho chiêu cần định hướng)
                task.wait(0.2)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
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
