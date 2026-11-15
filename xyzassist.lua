-- language: Luau, target: Roblox Xyz PvP, executor required
-- GUI 覆盖层，与上一版战斗逻辑合并；直接贴进执行器即可
-- 右键吸附默认开启，滑条实时调 FOV/平滑/命中框大小

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========== 配置状态 ==========
local State = {
    Aimbot = true,
    FOV = 120,
    Smoothness = 0.25,
    Hitbox = true,
    HitboxSize = 8,
    WallCheck = true,
    TeamCheck = true,
    FOVCircle = true,
    AimKey = Enum.UserInputType.MouseButton2,
}

-- ========== 清理旧 GUI ==========
local old = CoreGui:FindFirstChild("XyzAssistGui")
if old then old:Destroy() end
local oldDrawing = _G.XyzFovCircle
if oldDrawing then oldDrawing:Remove() end

-- ========== 构建 GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyzAssistGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- 主窗口
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0, 20, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 200, 120)
Stroke.Thickness = 1
Stroke.Parent = Main

-- 标题栏
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Title.BackgroundTransparency = 0
Title.Text = "  XYZ PVP ASSIST"
Title.TextColor3 = Color3.fromRGB(0, 220, 130)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- 内容容器
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -52)
Content.Position = UDim2.new(0, 8, 0, 44)
Content.BackgroundTransparency = 1
Content.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Content

-- 通用组件
local function makeToggle(name, default, callback, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(210, 210, 215)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 22)
    btn.Position = UDim2.new(1, -40, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(45, 45, 52)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = row

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(45, 45, 52)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return btn
end

local function makeSlider(name, min, max, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(210, 210, 215)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 50, 0, 18)
    val.Position = UDim2.new(1, -50, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.TextColor3 = Color3.fromRGB(0, 220, 130)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 26)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = min + (max - min) * rel
            v = math.floor(v + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            val.Text = tostring(v)
            callback(v)
        end
    end)
end

-- 组件实例化
makeToggle("Aimbot", State.Aimbot, function(v) State.Aimbot = v end, 1)
makeSlider("FOV", 20, 400, State.FOV, function(v) State.FOV = v end, 2)
makeSlider("Smoothness %", 1, 100, math.floor(State.Smoothness * 100), function(v) State.Smoothness = v / 100 end, 3)
makeToggle("FOV Circle", State.FOVCircle, function(v) State.FOVCircle = v end, 4)
makeToggle("Hitbox", State.Hitbox, function(v) State.Hitbox = v end, 5)
makeSlider("Hitbox Size", 2, 20, State.HitboxSize, function(v) State.HitboxSize = v end, 6)
makeToggle("Wall Check", State.WallCheck, function(v) State.WallCheck = v end, 7)
makeToggle("Team Check", State.TeamCheck, function(v) State.TeamCheck = v end, 8)

-- ========== FOV 圆环 (Drawing) ==========
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(0, 255, 120)
FovCircle.Filled = false
FovCircle.Visible = false
_G.XyzFovCircle = FovCircle

-- ========== 战斗逻辑 ==========
local Aiming = false

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isSameTeam(plr)
    if not State.TeamCheck then return false end
    local myTeam = LocalPlayer.Team
    return myTeam ~= nil and plr.Team == myTeam
end

local function hasLOS(part)
    if not State.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function getTargetPart(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function getClosest()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and not isSameTeam(plr) then
            local part = getTargetPart(plr)
            if part and hasLOS(part) then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d <= State.FOV and d < shortest then
                        shortest = d
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    FovCircle.Visible = State.FOVCircle and State.Aimbot
    FovCircle.Radius = State.FOV
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if State.Aimbot and Aiming then
        local target = getClosest()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, math.clamp(State.Smoothness, 0.01, 1))
        end
    end

    -- 命中框
    if State.Hitbox then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local part = getTargetPart(plr)
                if part then
                    part.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                    part.Transparency = 0.6
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == State.AimKey then Aiming = true end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == State.AimKey then Aiming = false end
end)
