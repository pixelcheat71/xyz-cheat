-- language: Luau, target: Roblox Xyz PvP, Xeno compatible
print("[xyzassist] Ultra Minimal Loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("XyzAssistGui") then playerGui.XyzAssistGui:Destroy() end

local Config = {
    Aimbot = true,
    FOV = 120,
    Smoothness = 0.15,
    Hitbox = false,
    HitboxSize = 4,
    AimKey = Enum.UserInputType.MouseButton2
}
local Aiming = false

-- Główne okno
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyzAssistGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 150)
Main.Position = UDim2.new(0.5, -125, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = true -- Od razu widoczne
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "XYZ ASSIST"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- Przyciski
local function makeBtn(text, yPos, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text .. " [" .. key .. "]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local aimBtn = makeBtn("Aimbot: ON", 40, "9")
local hbBtn = makeBtn("Hitbox: OFF", 85, "8")

local function updateUI()
    aimBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF") .. " [9]"
    hbBtn.Text = "Hitbox: " .. (Config.Hitbox and "ON" or "OFF") .. " [8]"
    aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    hbBtn.TextColor3 = Config.Hitbox and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
end

aimBtn.MouseButton1Click:Connect(function() Config.Aimbot = not Config.Aimbot; updateUI() end)
hbBtn.MouseButton1Click:Connect(function() Config.Hitbox = not Config.Hitbox; updateUI() end)

-- Sterowanie klawiszami
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Seven then
        Main.Visible = not Main.Visible
    end
    if input.KeyCode == Enum.KeyCode.Nine then
        Config.Aimbot = not Config.Aimbot
        updateUI()
    end
    if input.KeyCode == Enum.KeyCode.Eight then
        Config.Hitbox = not Config.Hitbox
        updateUI()
    end
    if input.KeyCode == Enum.KeyCode.Six then
        Config.Aimbot = false
        Config.Hitbox = false
        Main.Visible = false
        updateUI()
    end
    if input.UserInputType == Config.AimKey then Aiming = true end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Config.AimKey then Aiming = false end
end)

-- Logika walki
local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
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
        if plr ~= LocalPlayer and isAlive(plr) then
            local part = getTargetPart(plr)
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d <= Config.FOV and d < shortest then
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
    if Config.Aimbot and Aiming then
        local target = getClosest()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, Config.Smoothness)
        end
    end
    if Config.Hitbox then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local part = getTargetPart(plr)
                if part then
                    part.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    part.Transparency = 0.5
                end
            end
        end
    end
end)

updateUI()
