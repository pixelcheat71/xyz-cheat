-- language: Luau, target: Roblox Xyz PvP, Xeno compatible
local success, err = pcall(function()
    print("[xyzassist] Loading Simple UI...")

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
        AimKey = Enum.UserInputType.MouseButton2
    }
    local Aiming = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XyzAssistGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = playerGui

    -- ================= PROSTY LOADING SCREEN =================
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Overlay.ZIndex = 10
    Overlay.Parent = ScreenGui

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "XYZ\nASSIST"
    LogoText.TextColor3 = Color3.fromRGB(200, 200, 255)
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.TextSize = 40
    LogoText.ZIndex = 12
    LogoText.Parent = Overlay

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(0, 200, 0, 4)
    BarBg.Position = UDim2.new(0.5, -100, 0.5, 50)
    BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    BarBg.ZIndex = 11
    BarBg.Parent = Overlay

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
    BarFill.ZIndex = 12
    BarFill.Parent = BarBg

    -- Animacja ładowania
    task.spawn(function()
        local barTween = TweenService:Create(BarFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
        barTween:Play()
        barTween.Completed:Wait()
        task.wait(0.2)
        
        TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(LogoText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(BarBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        Overlay:Destroy()
    end)

    -- ================= GŁÓWNE MENU =================
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 500, 0, 300)
    Main.Position = UDim2.new(0.5, -250, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Main.Active = true
    Main.Draggable = true
    Main.Visible = false
    Main.ZIndex = 5
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "XYZ ASSIST - MENU [7]"
    Title.TextColor3 = Color3.fromRGB(240, 240, 245)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Main

    local function makeBtn(text, yPos, keyName, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -30, 0, 40)
        btn.Position = UDim2.new(0, 15, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        btn.Text = text .. " [" .. keyName .. "]"
        btn.TextColor3 = Color3.fromRGB(240, 240, 245)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.Parent = Main
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            callback()
        end)
        return btn
    end

    local aimBtn = makeBtn("Aimbot: ON", 60, "9", function()
        Config.Aimbot = not Config.Aimbot
        aimBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF") .. " [9]"
        aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(150, 150, 160)
    end)

    local hbBtn = makeBtn("Hitbox: OFF", 110, "8", function()
        Config.Hitbox = not Config.Hitbox
        hbBtn.Text = "Hitbox: " .. (Config.Hitbox and "ON" or "OFF") .. " [8]"
        hbBtn.TextColor3 = Config.Hitbox and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(150, 150, 160)
    end)

    -- ================= STEROWANIE =================
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        
        if input.KeyCode == Enum.KeyCode.Seven then
            Main.Visible = not Main.Visible
        end
        
        if input.KeyCode == Enum.KeyCode.Nine then
            Config.Aimbot = not Config.Aimbot
            aimBtn.Text = "Aimbot: " .. (Config.Aimbot and "ON" or "OFF") .. " [9]"
            aimBtn.TextColor3 = Config.Aimbot and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(150, 150, 160)
        end
        
        if input.KeyCode == Enum.KeyCode.Eight then
            Config.Hitbox = not Config.Hitbox
            hbBtn.Text = "Hitbox: " .. (Config.Hitbox and "ON" or "OFF") .. " [8]"
            hbBtn.TextColor3 = Config.Hitbox and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(150, 150, 160)
        end
        
        if input.KeyCode == Enum.KeyCode.Six then
            Config.Aimbot = false
            Config.Hitbox = false
            Main.Visible = false
            aimBtn.Text = "Aimbot: OFF [9]"
            hbBtn.Text = "Hitbox: OFF [8]"
            aimBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
            hbBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
        end

        if input.UserInputType == Config.AimKey then Aiming = true end
    end)

    UserInputService.InputEnded:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Config.AimKey then Aiming = false end
    end)

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
