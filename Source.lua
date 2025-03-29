-- Blox Fruits FPS Booster + Soft Hacks (KRNL)
-- SOFT HACKS --

local FPSBooster = {
    Enabled = true,
    UIVisible = false,
    Settings = {
        DisableShadows = true,
        LowerGraphics = true,
        RemoveParticles = true,
        ReduceRenderDistance = true,
        TargetFPS = 60,
        Aimbot = false,
        ClickTP = false,
        AimbotKey = Enum.UserInputType.MouseButton2, -- Right-click to aim
        AimbotRange = 1000,
        AimbotFOV = 50
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Aimbot Variables
local AimbotTarget = nil
local AimbotActive = false

-- FPS Booster Optimizations
function FPSBooster:ApplyOptimizations()
    if not self.Enabled then return end
    
    -- Graphics Settings
    if self.Settings.DisableShadows then
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.FogEnd = 9e9
        sethiddenproperty(Lighting, "Technology", "Compatibility")
    end
    
    if self.Settings.LowerGraphics then
        settings().Rendering.QualityLevel = 1
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Part") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") and self.Settings.RemoveParticles then
                v.Enabled = false
            end
        end
    end
    
    if self.Settings.ReduceRenderDistance then
        UserGameSettings.SavedQualityLevel = 1
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", 100)
        sethiddenproperty(LocalPlayer, "SimulationRadius", 100)
    end
    
    -- Set FPS Cap
    pcall(function()
        setfpscap(self.Settings.TargetFPS)
    end)
end

-- Aimbot Function
function FPSBooster:FindClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = self.Settings.AimbotRange
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    
    return closestPlayer
end

-- Aimbot Lock
function FPSBooster:AimbotLock()
    if not self.Settings.Aimbot or not AimbotActive then return end
    
    local target = AimbotTarget or self:FindClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local camera = workspace.CurrentCamera
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end
end

-- Click TP Function
function FPSBooster:ClickTeleport()
    if not self.Settings.ClickTP then return end
    
    Mouse.Button1Down:Connect(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then -- Hold Ctrl + Click to TP
            LocalPlayer.Character:MoveTo(Mouse.Hit.Position)
        end
    end)
end

-- Mobile UI
function FPSBooster:CreateMobileUI()
    -- Main Toggle Button
    self.ToggleButton = Instance.new("TextButton")
    self.ToggleButton.Name = "FPSToggleButton"
    self.ToggleButton.Text = "FPS Booster"
    self.ToggleButton.Size = UDim2.new(0, 100, 0, 40)
    self.ToggleButton.Position = UDim2.new(0, 10, 0.5, -20)
    self.ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
    self.ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    self.ToggleButton.TextSize = 14
    self.ToggleButton.BorderSizePixel = 0
    self.ToggleButton.ZIndex = 10
    self.ToggleButton.Parent = game:GetService("CoreGui")

    -- Settings Panel
    self.SettingsFrame = Instance.new("Frame")
    self.SettingsFrame.Name = "FPSSettingsFrame"
    self.SettingsFrame.Size = UDim2.new(0, 200, 0, 300)
    self.SettingsFrame.Position = UDim2.new(0, 120, 0.5, -150)
    self.SettingsFrame.AnchorPoint = Vector2.new(0, 0.5)
    self.SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.SettingsFrame.BorderSizePixel = 0
    self.SettingsFrame.Visible = false
    self.SettingsFrame.ZIndex = 9
    self.SettingsFrame.Parent = game:GetService("CoreGui")

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "FPS BOOSTER + HACKS"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = self.SettingsFrame

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 16
    CloseButton.BorderSizePixel = 0
    CloseButton.ZIndex = 10
    CloseButton.Parent = self.SettingsFrame

    -- FPS Booster Toggles
    local yOffset = 35
    for setting, value in pairs(self.Settings) do
        if setting ~= "AimbotKey" and setting ~= "AimbotRange" and setting ~= "AimbotFOV" then
            local Toggle = Instance.new("TextButton")
            Toggle.Name = setting
            Toggle.Text = setting .. ": " .. tostring(value)
            Toggle.Size = UDim2.new(1, -20, 0, 30)
            Toggle.Position = UDim2.new(0, 10, 0, yOffset)
            Toggle.BackgroundColor3 = value and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
            Toggle.TextColor3 = Color3.new(1, 1, 1)
            Toggle.TextSize = 12
            Toggle.BorderSizePixel = 0
            Toggle.Parent = self.SettingsFrame

            Toggle.MouseButton1Click:Connect(function()
                self.Settings[setting] = not self.Settings[setting]
                Toggle.Text = setting .. ": " .. tostring(self.Settings[setting])
                Toggle.BackgroundColor3 = self.Settings[setting] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
                self:ApplyOptimizations()
            end)
            yOffset = yOffset + 35
        end
    end

    -- Main Toggle
    local MainToggle = Instance.new("TextButton")
    MainToggle.Text = "TOGGLE ALL"
    MainToggle.Size = UDim2.new(1, -20, 0, 40)
    MainToggle.Position = UDim2.new(0, 10, 0, yOffset)
    MainToggle.BackgroundColor3 = self.Enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    MainToggle.TextColor3 = Color3.new(1, 1, 1)
    MainToggle.TextSize = 14
    MainToggle.BorderSizePixel = 0
    MainToggle.Parent = self.SettingsFrame

    MainToggle.MouseButton1Click:Connect(function()
        self.Enabled = not self.Enabled
        MainToggle.BackgroundColor3 = self.Enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        self.ToggleButton.BackgroundColor3 = self.Enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        self:ApplyOptimizations()
    end)

    -- UI Controls
    self.ToggleButton.MouseButton1Click:Connect(function()
        self.UIVisible = not self.UIVisible
        self.SettingsFrame.Visible = self.UIVisible
    end)

    CloseButton.MouseButton1Click:Connect(function()
        self.UIVisible = false
        self.SettingsFrame.Visible = false
    end)

    -- Draggable UI
    local dragging, dragInput, dragStart, startPos
    self.SettingsFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.SettingsFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.SettingsFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.SettingsFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Initialize
FPSBooster:ApplyOptimizations()
FPSBooster:CreateMobileUI()
FPSBooster:ClickTeleport()

-- Aimbot Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == FPSBooster.Settings.AimbotKey then
        AimbotActive = true
        AimbotTarget = FPSBooster:FindClosestPlayer()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == FPSBooster.Settings.AimbotKey then
        AimbotActive = false
        AimbotTarget = nil
    end
end)

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    FPSBooster:AimbotLock()
end)

print("FPS Booster + Soft Hacks Loaded! Tap the button to open settings.")
