-- language: Luau, target: Roblox Xyz PvP, Xeno compatible
_G.XYZASSIST_VERSION = "5.0.0-ULTIMATE"
print("[xyzassist] Loading Ultimate Edition...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("XyzAssistGui") then playerGui.XyzAssistGui:Destroy() end

-- Konfiguracja
local Config = {
    Aimbot = true,
    FOV = 150,
    Smoothness = 0.2,
    Hitbox = true,
    HitboxSize = 6,
    AimKey = Enum.UserInputType.MouseButton2
}
local Aiming = false

-- ===== GŁÓWNY INTERFEJS (Zaciemnienie) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyzAssistGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

-- Ciemne tło (Overlay)
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Overlay.BackgroundTransparency = 0
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 10
Overlay.Parent = ScreenGui

-- Kontener na logo i gradient
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 300, 0, 300)
LogoContainer.Position = UDim2.new(0.5, -150, 0.5, -150)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 11
LogoContainer.Parent = Overlay

-- Efekt świetlny w tle (UIGradient + ImageLabel)
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 100, 1, 100)
Glow.Position = UDim2.new(0, -50, 0, -50)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://1316045217" -- Bazowe kółko (można zmienić)
Glow.ImageColor3 = Color3.fromRGB(180, 50, 255) -- Fiolet
Glow.ImageTransparency = 0.4
Glow.ZIndex = 11
Glow.Parent = LogoContainer

local GlowGradient = Instance.new("UIGradient")
GlowGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 255))
}
GlowGradient.Rotation = 0
GlowGradient.Parent = Glow

-- Główne Logo (Tekst)
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "XYZ\nASSIST"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 48
LogoText.ZIndex = 12
LogoText.Parent = LogoContainer

local TextGradient = Instance.new("UIGradient")
TextGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 255))
}
TextGradient.Parent = LogoText

-- Animacja obracającego się gradientu i pulsowania
task.spawn(function()
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(Glow, tweenInfo, {ImageTransparency = 0.1, Size = UDim2.new(1, 150, 1, 150)})
    tween:Play()
    
    while ScreenGui.Parent do
        for i = 0, 360, 2 do
            GlowGradient.Rotation = i
            task.wait(0.02)
        end
    end
end)

-- Animacja wyjścia (Fade out)
task.delay(3, function()
    local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Overlay, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LogoContainer, fadeInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -150, 0.5, -250)}):Play()
    
    task.wait(1)
    Overlay:Destroy()
end)

-- ===== WŁAŚCIWE MENU (Pojawia się po animacji) =====
task.delay(3.5, function()
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 200, 0, 120)
    Main.Position = UDim2.new(0, 20, 0, 100)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 2
    Main.BorderColor3 = Color3.fromRGB(180, 50, 255)
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Title.Text = "XYZ ASSIST v5"
    Title.TextColor3 = Color3.fromRGB(180, 50, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = Main

    local function makeSimpleBtn(text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = Main
        btn.MouseButton1Click:Connect(function()
            callback()
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            task.wait(0.1)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end)
    end

    makeSimpleBtn("Aimbot: ON", 35, function() Config.Aimbot = not Config.Aimbot; print("Aimbot:", Config.Aimbot) end)
    makeSimpleBtn("Hitbox: ON", 70, function() Config.Hitbox = not Config.Hitbox; print("Hitbox:", Config.Hitbox) end)

    -- ===== LOGIKA WALKI =====
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

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Config.AimKey then Aiming = true end
    end)
    UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Config.AimKey then Aiming = false end
    end)
end)
