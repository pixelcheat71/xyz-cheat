-- language: Luau, target: Roblox Xyz PvP, Xeno compatible
-- xyzassist v3.1.0 — Xeno Fixes (PlayerGui, pcall, drawing safe)
_G.XYZASSIST_VERSION = "3.1.0"
print("[xyzassist] loaded v" .. _G.XYZASSIST_VERSION)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local SettingsFile = "xyzassist_v3.json"

-- ================= KONFIGURACJA =================
local DefaultState = {
    Aimbot = true,
    FOV = 150,
    Smoothness = 0.15,
    Prediction = 0.15,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    Hitbox = true,
    HitboxSize = 6,
    WallCheck = true,
    TeamCheck = true,
    FOVCircle = true,
    WalkSpeed = 16,
    JumpPower = 50,
    AutoClicker = false,
    AimKey = Enum.UserInputType.MouseButton2,
}

-- Bezpieczne ładowanie ustawień (Xeno może nie mieć isfile/readfile)
local State = table.clone(DefaultState)
if isfile and readfile and HttpService then
    local ok, data = pcall(function() 
        if isfile(SettingsFile) then
            return HttpService:JSONDecode(readfile(SettingsFile)) 
        end
    end)
    if ok and type(data) == "table" then
        for k, v in pairs(DefaultState) do 
            if data[k] ~= nil then State[k] = data[k] end 
        end
    end
end

local function saveSettings()
    if writefile and HttpService then 
        pcall(function() writefile(SettingsFile, HttpService:JSONEncode(State)) end) 
    end
end

-- ================= INTERFEJS (PlayerGui Fix) =================
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("XyzAssistGui") then playerGui.XyzAssistGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyzAssistGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui -- Xeno lepiej ogarnia PlayerGui niż CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 460)
Main.Position = UDim2.new(0, 20, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(180, 50, 255)
Stroke.Thickness = 1
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.Text = "  XYZ ASSIST v" .. _G.XYZASSIST_VERSION
Title.TextColor3 = Color3.fromRGB(180, 50, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -52)
Scroll.Position = UDim2.new(0, 8, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
Scroll.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

local function makeToggle(name, key, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = Scroll
    
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
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = State[key] and Color3.fromRGB(180, 50, 255) or Color3.fromRGB(45, 45, 52)
    btn.Text = State[key] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        btn.BackgroundColor3 = State[key] and Color3.fromRGB(180, 50, 255) or Color3.fromRGB(45, 45, 52)
        btn.Text = State[key] and "ON" or "OFF"
        saveSettings()
    end)
end

local function makeSlider(name, key, min, max, isFloat, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.Parent = Scroll
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(210, 210, 215)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 50, 0, 16)
    val.Position = UDim2.new(1, -50, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = isFloat and string.format("%.2f", State[key]) or tostring(State[key])
    val.TextColor3 = Color3.fromRGB(180, 50, 255)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    local rel = math.clamp((State[key] - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 50, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = min + (max - min) * rel
            if isFloat then
                v = math.floor(v * 100 + 0.5) / 100
                val.Text = string.format("%.2f", v)
            else
                v = math.floor(v + 0.5)
                val.Text = tostring(v)
            end
            fill.Size = UDim2.new(rel, 0, 1, 0)
            State[key] = v
            saveSettings()
        end
    end)
end

-- Sekcja: Aimbot
local lbl1 = Instance.new("TextLabel") lbl1.Size = UDim2.new(1,0,0,20) lbl1.BackgroundTransparency = 1 lbl1.Text = "--- AIMBOT ---" lbl1.TextColor3 = Color3.fromRGB(180, 50, 255) lbl1.Font = Enum.Font.GothamBold lbl1.TextSize = 12 lbl1.LayoutOrder = 1 lbl1.Parent = Scroll
makeToggle("Aimbot", "Aimbot", 2)
makeSlider("FOV", "FOV", 20, 400, false, 3)
makeSlider("Smoothness", "Smoothness", 0.01, 1, true, 4)
makeSlider("Prediction", "Prediction", 0, 0.5, true, 5)
makeToggle("FOV Circle", "FOVCircle", 6)

-- Sekcja: Combat
local lbl3 = Instance.new("TextLabel") lbl3.Size = UDim2.new(1,0,0,20) lbl3.BackgroundTransparency = 1 lbl3.Text = "--- COMBAT ---" lbl3.TextColor3 = Color3.fromRGB(180, 50, 255) lbl3.Font = Enum.Font.GothamBold lbl3.TextSize = 12 lbl3.LayoutOrder = 7 lbl3.Parent = Scroll
makeToggle("Hitbox Expander", "Hitbox", 8)
makeSlider("Hitbox Size", "HitboxSize", 2, 20, false, 9)
makeToggle("Wall Check", "WallCheck", 10)
makeToggle("Team Check", "TeamCheck", 11)

-- ================= RYSOWANIE (DRAWING API) =================
local FovCircle = nil
pcall(function()
    FovCircle = Drawing.new("Circle")
    FovCircle.Thickness = 1.5
    FovCircle.Color = Color3.fromRGB(180, 50, 255)
    FovCircle.Filled = false
    FovCircle.Visible = false
end)

-- ================= LOGIKA WALKI =================
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
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = Workspace:Raycast(origin, part.Position - origin, params)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function getTargetPart(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function getPredictedPosition(part)
    if State.Prediction <= 0 then return part.Position end
    return part.Position + (part.AssemblyLinearVelocity * State.Prediction)
end

local function getClosest()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and not isSameTeam(plr) then
            local part = getTargetPart(plr)
            if part and hasLOS(part) then
                local predictedPos = getPredictedPosition(part)
                local sp, onScreen = Camera:WorldToViewportPoint(predictedPos)
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
    if FovCircle then
        FovCircle.Visible = State.FOVCircle and State.Aimbot
        FovCircle.Radius = State.FOV
        FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    if State.Aimbot and Aiming then
        local target = getClosest()
        if target then
            local targetPos = getPredictedPosition(target)
            local goal = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(goal, math.clamp(State.Smoothness, 0.01, 1))
        end
    end

    if State.Hitbox then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local part = getTargetPart(plr)
                if part then
                    part.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                    part.Transparency = 0.5
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
