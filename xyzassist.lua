-- language: Luau, target: Roblox Xyz PvP, Xeno compatible
_G.XYZASSIST_VERSION = "7.0.0-GLASS"
print("[xyzassist] Modern UI loaded...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("XyzAssistGui") then playerGui.XyzAssistGui:Destroy() end

local Config = {
    Aimbot = true,
    FOV = 150,
    Smoothness = 0.2,
    Hitbox = true,
    HitboxSize = 6,
    AimKey = Enum.UserInputType.MouseButton2,
    MenuKey = Enum.KeyCode.U
}
local Aiming = false

-- KOLORY (Modern Palette)
local C_BG = Color3.fromRGB(12, 12, 16)
local C_GLASS = Color3.fromRGB(255, 255, 255)
local C_ACCENT = Color3.fromRGB(160, 60, 255) -- Pastelowy fiolet
local C_TEXT = Color3.fromRGB(240, 240, 245)
local C_SUBTEXT = Color3.fromRGB(150, 150, 160)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XyzAssistGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

-- ================= 1. MODERN LOADER =================
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = C_BG
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 10
Overlay.Parent = ScreenGui

-- Efekt tła (Radial Glow)
local BgGlow = Instance.new("ImageLabel")
BgGlow.Size = UDim2.new(0, 600, 0, 600)
BgGlow.Position = UDim2.new(0.5, -300, 0.5, -300)
BgGlow.BackgroundTransparency = 1
BgGlow.Image = "rbxassetid://1316045217" 
BgGlow.ImageColor3 = C_ACCENT
BgGlow.ImageTransparency = 0.7
BgGlow.ZIndex = 10
BgGlow.Parent = Overlay

local GlowGradient = Instance.new("UIGradient")
GlowGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C_ACCENT),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 150, 255)),
    ColorSequenceKeypoint.new(1, C_ACCENT)
}
GlowGradient.Parent = BgGlow

local LoaderContainer = Instance.new("Frame")
LoaderContainer.Size = UDim2.new(0, 300, 0, 200)
LoaderContainer.Position = UDim2.new(0.5, -150, 0.5, -100)
LoaderContainer.BackgroundTransparency = 1
LoaderContainer.ZIndex = 11
LoaderContainer.Parent = Overlay

-- Nowoczesny Spinner (Dwa obracające się pierścienie)
local Ring1 = Instance.new("Frame")
Ring1.Size = UDim2.new(0, 60, 0, 60)
Ring1.Position = UDim2.new(0.5, -30, 0, 20)
Ring1.BackgroundTransparency = 1
Ring1.ZIndex = 11
Ring1.Parent = LoaderContainer

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(1, 0)
UICorner1.Parent = Ring1

local Stroke1 = Instance.new("UIStroke")
Stroke1.Color = C_ACCENT
Stroke1.Thickness = 3
Stroke1.Transparency = 0.2
Stroke1.Parent = Ring1

local Ring2 = Instance.new("Frame")
Ring2.Size = UDim2.new(0, 40, 0, 40)
Ring2.Position = UDim2.new(0.5, -20, 0, 30)
Ring2.BackgroundTransparency = 1
Ring2.ZIndex = 11
Ring2.Parent = LoaderContainer
Instance.new("UICorner", Ring2).CornerRadius = UDim.new(1, 0)
local Stroke2 = Instance.new("UIStroke")
Stroke2.Color = Color3.fromRGB(60, 150, 255)
Stroke2.Thickness = 3
Stroke2.Transparency = 0.2
Stroke2.Parent = Ring2

-- Tekst
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 0, 40)
LogoText.Position = UDim2.new(0, 0, 0, 90)
LogoText.BackgroundTransparency = 1
LogoText.Text = "XYZ ASSIST"
LogoText.TextColor3 = C_TEXT
LogoText.Font = Enum.Font.GothamMedium
LogoText.TextSize = 28
LogoText.ZIndex = 12
LogoText.Parent = LoaderContainer

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(1, 0, 0, 20)
SubText.Position = UDim2.new(0, 0, 0, 130)
SubText.BackgroundTransparency = 1
SubText.Text = "Inicjalizacja..."
SubText.TextColor3 = C_SUBTEXT
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 12
SubText.ZIndex = 12
SubText.Parent = LoaderContainer

-- Animacje Loadera
task.spawn(function()
    while ScreenGui.Parent do
        for i = 0, 360, 2 do
            GlowGradient.Rotation = i
            task.wait(0.02)
        end
    end
end)

task.spawn(function()
    local tween1 = TweenService:Create(Ring1, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
    local tween2 = TweenService:Create(Ring2, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = -360})
    tween1:Play()
    tween2:Play()
    
    local pulse = TweenService:Create(BgGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.4, Size = UDim2.new(0, 700, 0, 700)})
    pulse:Play()
end)

task.delay(2.5, function()
    SubText.Text = "Ładowanie modułów..."
    task.wait(1)
    SubText.Text = "Gotowe."
    
    local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(Overlay, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderContainer, fadeInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -150, 0.5, -150)}):Play()
    
    task.wait(0.8)
    Overlay:Destroy()
    MiniBtn.Visible = true 
end)

-- ================= 2. MODERN GLASS MENU =================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 180)
Main.Position = UDim2.new(0.5, -130, 0.5, -90)
Main.BackgroundColor3 = C_BG
Main.BackgroundTransparency = 0.2 -- Glassmorphism
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.ZIndex = 5
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Stroke = Instance.new("UIStroke")
Stroke.Color = C_GLASS
Stroke.Thickness = 1
Stroke.Transparency = 0.8
Stroke.Parent = Main

local GlowBar = Instance.new("Frame")
GlowBar.Size = UDim2.new(1, -40, 0, 3)
GlowBar.Position = UDim2.new(0, 20, 0, 0)
GlowBar.BackgroundColor3 = C_ACCENT
GlowBar.BorderSizePixel = 0
GlowBar.ZIndex = 6
GlowBar.Parent = Main
Instance.new("UICorner", GlowBar).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "XYZ ASSIST"
Title.TextColor3 = C_TEXT
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 6
Title.Parent = Main

local function makeModernBtn(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 45)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.Text = text
    btn.TextColor3 = C_TEXT
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = C_GLASS
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.9
    btnStroke.Parent = btn

    -- Padding tekstu
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 15)

    -- Hover Effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        callback()
        btn.TextColor3 = C_ACCENT
        task.wait(0.15)
        btn.TextColor3 = C_TEXT
    end)
end

makeModernBtn("Aimbot: ON", 65, function() Config.Aimbot = not Config.Aimbot; print("Aimbot:", Config.Aimbot) end)
makeModernBtn("Hitbox: ON", 120, function() Config.Hitbox = not Config.Hitbox; print("Hitbox:", Config.Hitbox) end)

-- ================= 3. MINI PRZYCISK (Dolny róg) =================
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(1, -70, 1, -70)
MiniBtn.BackgroundColor3 = C_BG
MiniBtn.BackgroundTransparency = 0.2
MiniBtn.Text = "XYZ"
MiniBtn.TextColor3 = C_TEXT
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 14
MiniBtn.BorderSizePixel = 0
MiniBtn.Visible = false
MiniBtn.ZIndex = 5
MiniBtn.Parent = ScreenGui

Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 12)
local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = C_ACCENT
MiniStroke.Thickness = 1
MiniStroke.Transparency = 0.5
MiniStroke.Parent = MiniBtn

-- ================= ANIMACJE MENU =================
local function OpenMenu()
    if Main.Visible then return end
    Main.Visible = true
    Main.Position = UDim2.new(0.5, -130, 0.5, -70)
    Main.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(Main, tweenInfo, {
        Position = UDim2.new(0.5, -130, 0.5, -90),
        BackgroundTransparency = 0.2
    }):Play()
    
    MiniBtn.Visible = false
end

local function CloseMenu()
    if not Main.Visible then return end
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local tween = TweenService:Create(Main, tweenInfo, {
        Position = UDim2.new(0.5, -130, 0.5, -50),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        Main.Visible = false
        MiniBtn.Visible = true
    end)
end

MiniBtn.MouseButton1Click:Connect(OpenMenu)

-- ================= LOGIKA WALKI =================
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
    if input.KeyCode == Config.MenuKey then
        if Main.Visible then CloseMenu() else OpenMenu() end
    end
    if input.UserInputType == Config.AimKey then Aiming = true end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Config.AimKey then Aiming = false end
end)
