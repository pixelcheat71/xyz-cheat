-- language: Luau, target: Roblox Xyz PvP, Xeno compatible
-- Skrypt owinięty w pcall, żeby wyłapać błąd i pokazać go na ekranie.

local success, err = pcall(function()
    _G.XYZASSIST_VERSION = "11.0.0-DEBUG"
    print("[xyzassist] Loading...")

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
        FOV = 120,
        Smoothness = 0.15,
        Hitbox = false,
        HitboxSize = 4,
        AimKey = Enum.UserInputType.MouseButton2,
        MenuKey = Enum.KeyCode.U
    }
    local Aiming = false

    local C_BG = Color3.fromRGB(15, 15, 18)
    local C_SIDEBAR = Color3.fromRGB(22, 22, 28)
    local C_ELEMENT = Color3.fromRGB(35, 35, 42)
    local C_TEXT = Color3.fromRGB(240, 240, 245)
    local C_SUBTEXT = Color3.fromRGB(150, 150, 160)
    local C_ACCENT = Color3.fromRGB(100, 180, 255)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XyzAssistGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = playerGui

    -- GŁÓWNE OKNO
    local Main = Instance.new("Frame")
    Main.Name = "SysUpdateFrame"
    Main.Size = UDim2.new(0, 500, 0, 300)
    Main.Position = UDim2.new(0.5, -250, 0.5, -150)
    Main.BackgroundColor3 = C_BG
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Visible = false
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.9
    MainStroke.Parent = Main

    -- GÓRNY PASEK
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Theme 'Dark'"
    Title.TextColor3 = C_TEXT
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, -40, 0, 15)
    SubTitle.Position = UDim2.new(0, 15, 0, 22)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "by pxq"
    SubTitle.TextColor3 = C_SUBTEXT
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 10
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = C_SUBTEXT
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TopBar

    -- LEWY PANEL
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = C_SIDEBAR
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    local SidebarCorner = Instance.new("Frame")
    SidebarCorner.Size = UDim2.new(0, 12, 1, 0)
    SidebarCorner.Position = UDim2.new(1, -12, 0, 0)
    SidebarCorner.BackgroundColor3 = C_SIDEBAR
    SidebarCorner.BorderSizePixel = 0
    SidebarCorner.Parent = Sidebar

    local function makeTab(name, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundTransparency = 1
        btn.Text = "  " .. name
        btn.TextColor3 = C_SUBTEXT
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = Sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, TextColor3 = C_TEXT}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = C_SUBTEXT}):Play() end)
    end
    makeTab("Main", 10)
    makeTab("Settings", 50)

    -- PRAWY PANEL
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -150, 1, -40)
    Content.Position = UDim2.new(0, 150, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, -30, 0, 30)
    Header.Position = UDim2.new(0, 15, 0, 10)
    Header.BackgroundTransparency = 1
    Header.Text = "Interactive Elements"
    Header.TextColor3 = C_TEXT
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 16
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Content

    local SubHeader = Instance.new("TextLabel")
    SubHeader.Size = UDim2.new(1, -30, 0, 15)
    SubHeader.Position = UDim2.new(0, 15, 0, 30)
    SubHeader.BackgroundTransparency = 1
    SubHeader.Text = "Demonstration of new UI components"
    SubHeader.TextColor3 = C_SUBTEXT
    SubHeader.Font = Enum.Font.Gotham
    SubHeader.TextSize = 10
    SubHeader.TextXAlignment = Enum.TextXAlignment.Left
    SubHeader.Parent = Content

    local function makeSwitch(text, yPos, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -30, 0, 35)
        frame.Position = UDim2.new(0, 15, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = Content
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = C_TEXT
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local switchBg = Instance.new("Frame")
        switchBg.Size = UDim2.new(0, 40, 0, 20)
        switchBg.Position = UDim2.new(1, -40, 0.5, -10)
        switchBg.BackgroundColor3 = Config[text] and C_ACCENT or C_ELEMENT
        switchBg.Parent = frame
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = Config[text] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = switchBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = frame
        
        local state = Config[text]
        btn.MouseButton1Click:Connect(function()
            state = not state
            Config[text] = state
            callback(state)
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and C_ACCENT or C_ELEMENT}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        end)
    end

    local function makeSlider(text, yPos, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -30, 0, 45)
        frame.Position = UDim2.new(0, 15, 0, yPos)
        frame.BackgroundTransparency = 1
        frame.Parent = Content
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 15)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = C_TEXT
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 4)
        sliderBg.Position = UDim2.new(0, 0, 0, 25)
        sliderBg.BackgroundColor3 = C_ELEMENT
        sliderBg.Parent = frame
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = C_ACCENT
        sliderFill.Parent = sliderBg
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = sliderBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local v = min + (max - min) * rel
                sliderFill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, -6, 0.5, -6)
                callback(v)
            end
        end)
    end

    makeSwitch("Aimbot", 60, function(v) Config.Aimbot = v end)
    makeSwitch("Hitbox", 105, function(v) Config.Hitbox = v end)
    makeSlider("Brightness Control (Smoothness)", 160, 0.01, 0.5, Config.Smoothness, function(v) Config.Smoothness = v end)

    -- ANIMACJE
    local function OpenMenu()
        if Main.Visible then return end
        Main.Visible = true
        Main.BackgroundTransparency = 1
        Main.Size = UDim2.new(0, 480, 0, 280)
        Main.Position = UDim2.new(0.5, -240, 0.5, -140)
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 300),
            Position = UDim2.new(0.5, -250, 0.5, -150),
            BackgroundTransparency = 0
        }):Play()
    end

    local function CloseMenu()
        if not Main.Visible then return end
        local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 480, 0, 280),
            Position = UDim2.new(0.5, -240, 0.5, -140),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function() Main.Visible = false end)
    end
    CloseBtn.MouseButton1Click:Connect(CloseMenu)

    -- LOGIKA
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
end)

if not success then
    print("[xyzassist] ERROR CAUGHT:", err)
    local errorGui = Instance.new("ScreenGui")
    errorGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local errLabel = Instance.new("TextLabel")
    errLabel.Size = UDim2.new(0, 400, 0, 100)
    errLabel.Position = UDim2.new(0.5, -200, 0.5, -50)
    errLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    errLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    errLabel.TextScaled = true
    errLabel.Text = tostring(err)
    errLabel.Parent = errorGui
end
