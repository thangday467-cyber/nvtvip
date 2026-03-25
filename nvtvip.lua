-- ========================================== --
-- NVT VIP HUB - EXPERT EDITION (BẢN SỬA LỖI HOÀN CHỈNH)
-- ĐƯỢC TỐI ƯU HÓA CHO CÁC TRÒ CHƠI CÓ HỆ THỐNG KỸ NĂNG DẠNG NÚT BẤM (image_0.png)
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
local Stats = Services.Stats
local StarterGui = Services.StarterGui
local CoreGui = Services.CoreGui

local LocalPlayer = Players.LocalPlayer

-- ================= HỆ THỐNG BYPASS UI ================= --
local function GetSafeUIParent()
    local success, parent = pcall(function() return gethui and gethui() end)
    if success and parent then return parent end
    
    success, parent = pcall(function() return game:GetService("CoreGui") end)
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

-- Hiển thị FPS & Ping
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
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- Cập nhật thông số FPS/Ping an toàn
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

-- VÒNG LẶP AUTO Z SIÊU CẤP (BẢN SỬA LỖI CHO TRÒ CHƠI DẠNGimage_0.png)
task.spawn(function()
    -- Hàm dò tìm nút 'Use Z' trong CoreGui hoặc PlayerGui bằng cách quét văn bản
    local function FindSkillZButton()
        local function Scan(parent)
            if not parent then return nil end
            for _, gui in ipairs(parent:GetDescendants()) do
                -- Tìm các nút có văn bản là "Use"
                if gui:IsA("TextButton") and gui.Text == "Use" then
                    -- Kiểm tra xem nút này có nhãn 'Z' gần đó không
                    -- Chúng ta quét các label anh em (siblings) của nút
                    local foundZ = false
                    local p = gui.Parent
                    if p then
                        for _, sibling in ipairs(p:GetChildren()) do
                            if sibling:IsA("TextLabel") and sibling.Text == "Z" then
                                foundZ = true
                                break
                            end
                        end
                    end

                    if foundZ then
                        return gui
                    end
                end
            end
            return nil
        end

        local btn = Scan(Services.CoreGui)
        if not btn then btn = Scan(LocalPlayer:WaitForChild("PlayerGui")) end
        return btn
    end

    local skillBtn = nil -- Cache button

    while task.wait(30) do
        if State.AutoZ then
            -- Chỉ tìm nút một lần và cache lại
            if not skillBtn then
                skillBtn = FindSkillZButton()
            end
            
            if skillBtn then
                -- Ép buộc hệ thống thi triển chiêu
                pcall(function()
                    skillBtn:Click()
                    -- Gửi thông báo Roblox
                    StarterGui:SetCore("SendNotification", {
                        Title = "Auto Skill",
                        Text = "Đã thi triển chiêu Z!",
                        Duration = 3
                    })
                end)
            else
                -- Không tìm thấy nút, bắn thông báo lỗi
                pcall(function()
                    StarterGui:SetCore("SendNotification", {
                        Title = "Auto Skill (LỖI)",
                        Text = "Không tìm thấy nút 'Use Z' trên màn hình!",
                        Duration = 3
                    })
                end)
            end
        else
            -- Reset cache khi tắt toggle
            skillBtn = nil
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
