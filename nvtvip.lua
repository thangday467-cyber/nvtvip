local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer

-- Xóa Hub cũ nếu có
if CoreGui:FindFirstChild("NVTVIP_Hub") then
    CoreGui.NVTVIP_Hub:Destroy()
end

-- ================= CẤU TRÚC GIAO DIỆN (UI) ================= --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NVTVIP_Hub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

-- 1. Tấm rèm đen
local BlackScreen = Instance.new("Frame")
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreen.Visible = false
BlackScreen.ZIndex = 1
BlackScreen.Parent = ScreenGui

-- 2. Nút Logo thu gọn (Bật/Tắt Menu)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0, 15)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenButton.Text = "NVT"
OpenButton.TextColor3 = Color3.fromRGB(0, 255, 150)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 14
OpenButton.Draggable = true
OpenButton.Active = true
OpenButton.ZIndex = 10
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0) 
OpenCorner.Parent = OpenButton

-- 3. Cửa sổ Menu chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 240) -- Tăng chiều cao thêm một chút
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NVT VIP HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.ZIndex = 11
Title.Parent = MainFrame

local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, 0, 0, 2)
TitleLine.Position = UDim2.new(0, 0, 0, 40)
TitleLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
TitleLine.BorderSizePixel = 0
TitleLine.ZIndex = 11
TitleLine.Parent = MainFrame

-- THÔNG SỐ PING & FPS
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 20)
StatsLabel.Position = UDim2.new(0, 0, 0, 45) -- Nằm ngay dưới vạch xanh
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: ... | Ping: ..."
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatsLabel.Font = Enum.Font.GothamSemibold
StatsLabel.TextSize = 12
StatsLabel.ZIndex = 11
StatsLabel.Parent = MainFrame

-- ================= CHỨC NĂNG & NÚT BẤM ================= --

local function CreateToggle(yPos, text, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0.9, 0, 0, 38)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleBtn.Text = text
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.Font = Enum.Font.GothamSemibold
    ToggleBtn.TextSize = 13
    ToggleBtn.ZIndex = 11
    ToggleBtn.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleBtn

    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        callback(state)
    end)
end

local isAutoZ = false

-- Nút 1: Màn Đen & Dọn RAM
CreateToggle(75, "Bật Màn Đen & Dọn RAM (5 FPS)", function(state)
    if state then
        Lighting.GlobalShadows = false
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then v:Destroy() end
        end
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
        setfpscap(5)
        RunService:Set3dRenderingEnabled(false)
        settings().Rendering.QualityLevel = 1
        BlackScreen.Visible = true
    else
        setfpscap(60)
        RunService:Set3dRenderingEnabled(true)
        settings().Rendering.QualityLevel = "Automatic"
        BlackScreen.Visible = false
    end
end)

-- Nút 2: Auto Z Control
CreateToggle(125, "Bật Auto Control (Chiêu Z)", function(state)
    isAutoZ = state
end)

-- Nút 3: Đóng Menu
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0, 38)
CloseBtn.Position = UDim2.new(0.05, 0, 0, 175)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "Ẩn Bảng Menu"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.ZIndex = 11
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ================= SỰ KIỆN & VÒNG LẶP ================= --

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Anti-AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

-- Cập nhật Live FPS & Ping
RunService.RenderStepped:Connect(function(step)
    local fps = math.floor(1 / step)
    local ping = 0
    pcall(function()
        ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    
    -- Đổi màu text nếu Ping quá cao hoặc FPS bị drop
    if fps <= 15 then
        StatsLabel.Text = "FPS: <font color='rgb(255,100,100)'>"..fps.."</font> | Ping: "..ping.."ms"
    else
        StatsLabel.Text = "FPS: "..fps.." | Ping: "..ping.."ms"
    end
    StatsLabel.RichText = true
end)

-- Vòng lặp Auto Z
task.spawn(function()
    while task.wait(30) do
        if isAutoZ and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local tool = nil
            
            for _, v in pairs(player.Backpack:GetChildren()) do
                if v:IsA("Tool") and string.find(string.lower(v.Name), "control") then
                    tool = v break
                end
            end
            if not tool then
                for _, v in pairs(player.Character:GetChildren()) do
                    if v:IsA("Tool") and string.find(string.lower(v.Name), "control") then
                        tool = v break
                    end
                end
            end
            
            if humanoid and tool then
                humanoid:EquipTool(tool)
                task.wait(1.5)
                
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                task.wait(0.2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
            end
        end
    end
end)
