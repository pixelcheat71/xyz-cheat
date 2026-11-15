-- language: Luau, target: Roblox Xyz PvP, Xeno compatible
-- Cały interfejs jest chroniony przez pcall.

local success, err = pcall(function()
    _G.XYZASSIST_VERSION = "13.0.0-BINDS"
    print("[xyzassist] Keybinds loaded...")

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

    -- ================= SYSTEM POWIADOMIEŃ =================
    local NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "XyzNotify"
    NotifyGui.ResetOnSpawn = false
    NotifyGui.Parent = playerGui

    local function showNotify(text)
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 200, 0, 40)
        box.Position = UDim2.new(1, -220, 0, 20)
        box.BackgroundColor3 = C_BG
        box.BackgroundTransparency = 1
        box.Parent = NotifyGui
        
        local stroke = Instance.new("UIStroke", box)
        stroke.Color = C_ACCENT
        stroke.Thickness = 1.5
        
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
        
        local txt = Instance.new("TextLabel", box)
        txt.Size = UDim2.new(1, -20, 1, 0)
        txt.Position = UDim2.new(0, 10, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = C_TEXT
        txt.Font = Enum.Font.GothamMedium
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        
        TweenService:Create(box, TweenInfo.new(0.2), {Position = UDim2.new(1, -220, 0, 30), BackgroundTransparency = 0.1}):Play()
        task.wait(1.5)
        local tw = TweenService:Create(box, TweenInfo.new(0.2), {Position = UDim2.new(1, -220, 0, 0), BackgroundTransparency = 1})
        tw:Play()
        tw.Completed:Connect(function() box:Destroy() end)
    end

    -- ================= GŁÓWNE OKNO =================
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

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = C_SUBTEXT
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TopBar

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
    end
    makeTab("Main", 10)
    makeTab("Settings", 50)

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

    local function makeSwitch(text, yPos, initial, callback)
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
        switchBg.BackgroundColor3 = initial and C_ACCENT or C_ELEMENT
        switchBg.Parent = frame
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = initial and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = switchBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = frame
        
        local state = initial
        btn.MouseButton1Click:Connect(function()
            state = not state
            callback(state)
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and C_ACCENT or C_ELEMENT}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        end)
        
        -- Zwracamy referencję, żeby można było zmieniać z klawiatury
        return switchBg, knob
    end

    local aimSwitchBg, aimKnob = makeSwitch("Aimbot [9]", 60, Config.Aimbot, function(v) Config.Aimbot = v end)
    local hbSwitchBg, hbKnob = makeSwitch("Hitbox [8]", 105, Config.Hitbox, function(v) Config.Hitbox = v end)

    -- ================= ANIMACJE =================
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

    -- ================= STEROWANIE KLAWIATURĄ =================
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        
        -- 7 - Otwórz / Zamknij Menu
        if input.KeyCode == Enum.KeyCode.Seven then
            if Main.Visible then CloseMenu() else OpenMenu() end
        end
        
        -- 9 - Aimbot
        if input.KeyCode == Enum.KeyCode.Nine then
            Config.Aimbot = not Config.Aimbot
            TweenService:Create(aimSwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Config.Aimbot and C_ACCENT or C_ELEMENT}):Play()
            TweenService:Create(aimKnob, TweenInfo.new(0.2), {Position = Config.Aimbot and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
            showNotify("Aimbot: " .. (Config.Aimbot and "ON" or "OFF"))
        end
        
        -- 8 - Hitbox
        if input.KeyCode == Enum.KeyCode.Eight then
            Config.Hitbox = not Config.Hitbox
            TweenService:Create(hbSwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Config.Hitbox and C_ACCENT or C_ELEMENT}):Play()
            TweenService:Create(hbKnob, TweenInfo.new(0.2), {Position = Config.Hitbox and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
            showNotify("Hitbox: " .. (Config.Hitbox and "ON" or "OFF"))
        end
        
        -- 6 - Kill Switch (Wyłącza wszystko)
        if input.KeyCode == Enum.KeyCode.Six then
            Config.Aimbot = false
            Config.Hitbox = false
            Main.Visible = false
            TweenService:Create(aimSwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = C_ELEMENT}):Play()
            TweenService:Create(aimKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
            TweenService:Create(hbSwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = C_ELEMENT}):Play()
            TweenService:Create(hbKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
            showNotify("KILL SWITCH: ALL OFF")
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
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("ErrorTestGui") then playerGui.ErrorTestGui:Destroy() end
    local errorGui = Instance.new("ScreenGui")
    errorGui.Name = "ErrorTestGui"
    errorGui.Parent = playerGui
    local errLabel = Instance.new("TextLabel")
    errLabel.Size = UDim2.new(0, 500, 0, 150)
    errLabel.Position = UDim2.new(0.5, -250, 0.5, -75)
    errLabel.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
    errLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    errLabel.Font = Enum.Font.GothamBold
    errLabel.TextScaled = true
    errLabel.Text = "BŁĄD W GUI:\n" .. tostring(err)
    errLabel.ZIndex = 999
    errLabel.Parent = errorGui
end
