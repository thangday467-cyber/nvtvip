-- ========================================== --
-- NVT VIP HUB (SMART AUTO OPE X KIRORU)
-- Tính năng: Nhận diện thanh năng lượng thông minh
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
    if child.Name == "NVT_VIP_Hub" then child:Destroy() end
end

-- ================= KHỞI TẠO GIAO DIỆN ================= --
local HubGui = Instance.new("ScreenGui")
HubGui.Name = "NVT_VIP_Hub"
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

-- Nút mở menu (NVT)
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

-- Khung Menu Chính
local MainFrame = Create("Frame", {
    Size = UDim2.new(0, 280, 0, 275), 
    Position = UDim2.new(0.5, -140, 0.5, -137),
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

-- Thông số trực tiếp
local StatsLabel = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 45),
    BackgroundTransparency = 1,
    Text = "Đang tải thông số...",
    TextColor3 = Color3.fromRGB(180, 180, 180),
    Font = Enum.Font.GothamSemibold,
    TextSize = 12,
    RichText = true,
    ZIndex = 10002,
    Parent = MainFrame
})

-- Bộ đếm Nguyên Liệu
local ItemStatsLabel = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 65),
    BackgroundTransparency = 1,
    Text = "💎 Nguyên liệu đã farm: 0",
    TextColor3 = Color3.fromRGB(255, 200, 50),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
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

CreateToggle(95, "Màn Đen & 5 FPS", "Optimize", function(isOn)
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

-- Chức năng Farm
CreateToggle(145, "Bật Farm Ope X Kiroru (Thông minh)", "AutoZ", function() end)

local CloseBtn = Create("TextButton", {
    Size = UDim2.new(0.9, 0, 0, 40),
    Position = UDim2.new(0.05, 0, 0, 205),
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

-- ================= HỆ THỐNG KIỂM TRA NĂNG LƯỢNG THÔNG MINH ================= --
local function IsEnergyEmpty()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return true end -- Không có GUI thì ép chạy (trường hợp lỗi)

    local foundEnergy = false
    local isEmpty = false

    -- Quét toàn bộ màn hình để tìm thanh năng lượng/room
    for _, gui in pairs(playerGui:GetDescendants()) do
        local name = string.lower(gui.Name)
        if string.find(name, "room") or string.find(name, "energy") or string.find(name, "stamina") then
            -- Chỉ kiểm tra những thanh đang hiển thị trên màn hình
            if gui:IsA("GuiObject") and gui.AbsoluteSize.X > 0 and gui.AbsoluteSize.Y > 0 then
                local isVisible = true
                local parent = gui
                while parent and parent:IsA("GuiObject") do
                    if not parent.Visible then
                        isVisible = false
                        break
                    end
                    parent = parent.Parent
                end

                if isVisible then
                    foundEnergy = true
                    
                    -- Nếu nó là cái thanh dải màu (Frame) -> Kiểm tra độ dài
                    if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                        -- Nếu thanh năng lượng ngắn hơn 5% hoặc bé hơn 20 pixels -> Coi như đã hết
                        if gui.Size.X.Scale <= 0.05 and gui.AbsoluteSize.X <= 20 then
                            isEmpty = true
                        end
                    end
                    
                    -- Nếu nó là chữ (Ví dụ: 0/100) -> Kiểm tra số 0
                    if gui:IsA("TextLabel") then
                        if gui.Text == "0" or string.find(gui.Text, "^0/") then
                            isEmpty = true
                        end
                    end
                end
            end
        end
    end

    -- ĐIỀU KIỆN 1: Nếu hoàn toàn KHÔNG CÓ thanh năng lượng trên màn hình -> Trả về True để bật lại Room
    if not foundEnergy then 
        return true 
    end
    
    -- ĐIỀU KIỆN 2: Nếu CÓ thanh năng lượng, nhưng nó đã cạn sạch -> Trả về True
    return isEmpty
end

-- ================= VÒNG LẶP HỆ THỐNG CẬP NHẬT ================= --

pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

local farmedItemsCount = 0
pcall(function()
    LocalPlayer.Backpack.ChildAdded:Connect(function(item)
        farmedItemsCount = farmedItemsCount + 1
        ItemStatsLabel.Text = "🗿 Nguyên liệu đã farm: " .. farmedItemsCount
    end)
end)

RunService.RenderStepped:Connect(function()
    local ping = 0
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    local fps = math.floor(Workspace:GetRealPhysicsFPS())
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local fpsText = (fps <= 15) and "<font color='rgb(255,80,80)'>"..fps.."</font>" or "<font color='rgb(80,255,80)'>"..fps.."</font>"
    StatsLabel.Text = "FPS: " .. fpsText .. " | Ping: " .. ping .. "ms | Server: " .. currentPlayers .. "/" .. maxPlayers
end)

-- ================= VÒNG LẶP FARM OPE X KIRORU ================= --
task.spawn(function()
    while task.wait(1) do -- Chạy mỗi 1 giây để kiểm tra liên tục
        if State.AutoZ then
            pcall(function()
                -- Lấy quyết định từ hệ thống AI quét màn hình
                if IsEnergyEmpty() then
                    -- 1. Rút vũ khí ô số 1
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    
                    task.wait(0.3) -- Cho thêm chút thời gian cầm vũ khí lên
                    
                    -- 2. Dùng chiêu Z
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
                    
                    -- 3. Click chuột nhả chiêu
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    
                    -- Đợi 3 giây để game kịp load thanh năng lượng mới lên màn hình, 
                    -- tránh việc script tưởng nhầm là chưa có năng lượng và bấm đúp
                    task.wait(3)
                end
            end)
        end
    end
end)

-- Gửi thông báo hoàn tất
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "NVT VIP HUB",
        Text = "Hệ thống Farm Ope X Kiroru (Smart Logic) đã sẵn sàng!",
        Duration = 5
    })
end)
