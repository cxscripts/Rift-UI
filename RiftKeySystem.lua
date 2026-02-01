--[[
    Rift Key System
    A professional authentication system for Rift UI
    Features:
    - Key validation
    - HWID locking (optional)
    - Modern UI matching Rift's design
    - Easy configuration
]]

local RiftKeySystem = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Configuration
local Config = {
    -- Valid keys (add your keys here)
   ValidKeys = {
    "CxRift"
},
    
    -- HWID locked keys (optional)
    -- Format: ["KEY"] = "HWID"
    HWIDKeys = {
        -- Example: ["LOCKED-KEY-001"] = "B4D455-EXAMPLE-HWID"
    },
    
    -- Settings
    KeyLength = 0, -- Expected key length (set to 0 to disable length check)
    MaxAttempts = 5, -- Maximum failed attempts before lockout
    LockoutDuration = 300, -- Lockout duration in seconds (5 minutes)
    SaveKey = false, -- Save valid key for future sessions
    
    -- UI Theme (matches Rift UI)
    Theme = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(120, 90, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(80, 200, 120),
        Error = Color3.fromRGB(255, 80, 80)
    },
    
    -- Website link
    KeyLink = "https://yourwebsite.com/getkey"
}

-- Utility Functions
local function GetHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    return hwid
end

local function CreateTween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateRoundedFrame(parent, size, position, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    corner.Parent = frame
    
    return frame
end

-- Storage Functions
local function SaveKeyLocally(key)
    if Config.SaveKey then
        writefile("rift_key.txt", key)
    end
end

local function LoadSavedKey()
    if Config.SaveKey and isfile("rift_key.txt") then
        return readfile("rift_key.txt")
    end
    return nil
end

local function ClearSavedKey()
    if isfile("rift_key.txt") then
        delfile("rift_key.txt")
    end
end

-- Key Validation
local function ValidateKey(key)
    -- Check if key is in valid keys list
    for _, validKey in ipairs(Config.ValidKeys) do
        if key == validKey then
            return true, "valid"
        end
    end
    
    -- Check if key is HWID locked
    for lockedKey, hwid in pairs(Config.HWIDKeys) do
        if key == lockedKey then
            local currentHWID = GetHWID()
            if currentHWID == hwid then
                return true, "hwid_valid"
            else
                return false, "hwid_mismatch"
            end
        end
    end
    
    return false, "invalid"
end

-- Notification System
local function ShowNotification(title, message, notifType, duration)
    duration = duration or 3
    
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "RiftNotification"
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationGui.Parent = CoreGui
    
    local typeColors = {
        Success = Config.Theme.Success,
        Error = Config.Theme.Error,
        Info = Config.Theme.Accent
    }
    
    local Notification = CreateRoundedFrame(NotificationGui, 
        UDim2.new(0, 300, 0, 80), 
        UDim2.new(1, 10, 0, 20), 
        Config.Theme.Background, 8)
    
    local Accent = CreateRoundedFrame(Notification, 
        UDim2.new(0, 4, 1, 0), 
        UDim2.new(0, 0, 0, 0), 
        typeColors[notifType] or Config.Theme.Accent, 8)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 15, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Config.Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Notification
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -20, 0, 45)
    MessageLabel.Position = UDim2.new(0, 15, 0, 30)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Config.Theme.TextDark
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 12
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = Notification
    
    -- Animate in
    CreateTween(Notification, {Position = UDim2.new(1, -310, 0, 20)}, 0.5, Enum.EasingStyle.Back)
    
    -- Animate out and destroy
    task.delay(duration, function()
        CreateTween(Notification, {Position = UDim2.new(1, 10, 0, 20)}, 0.3)
        task.wait(0.3)
        NotificationGui:Destroy()
    end)
end

-- Main Key System
function RiftKeySystem:Initialize(callback)
    local KeySystemGui = Instance.new("ScreenGui")
    KeySystemGui.Name = "RiftKeySystem"
    KeySystemGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeySystemGui.ResetOnSpawn = false
    
    -- Try to parent to CoreGui, fall back to PlayerGui
    local success = pcall(function()
        KeySystemGui.Parent = CoreGui
    end)
    
    if not success then
        KeySystemGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Variables
    local attempts = 0
    local locked = false
    local lockExpiry = 0
    
    -- Check for saved key
    local savedKey = LoadSavedKey()
    if savedKey then
        local isValid, reason = ValidateKey(savedKey)
        if isValid then
            ShowNotification("Key System", "Authenticated with saved key!", "Success", 2)
            task.wait(0.5)
            KeySystemGui:Destroy()
            callback(true)
            return
        else
            ClearSavedKey()
        end
    end
    
    -- Background Blur
    local Blur = Instance.new("Frame")
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Blur.BackgroundTransparency = 0.5
    Blur.BorderSizePixel = 0
    Blur.Parent = KeySystemGui
    
    -- Main Container
    local MainFrame = CreateRoundedFrame(KeySystemGui, 
        UDim2.new(0, 450, 0, 500), 
        UDim2.new(0.5, -225, 0.5, -250), 
        Config.Theme.Background, 12)
    
    -- Drop Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- Top Bar
    local TopBar = CreateRoundedFrame(MainFrame, 
        UDim2.new(1, 0, 0, 60), 
        UDim2.new(0, 0, 0, 0), 
        Config.Theme.Secondary, 12)
    
    local TopBarBottom = Instance.new("Frame")
    TopBarBottom.Size = UDim2.new(1, 0, 0, 12)
    TopBarBottom.Position = UDim2.new(0, 0, 1, -12)
    TopBarBottom.BackgroundColor3 = Config.Theme.Secondary
    TopBarBottom.BorderSizePixel = 0
    TopBarBottom.Parent = TopBar
    
    -- Logo/Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🔐 RIFT KEY SYSTEM"
    Title.TextColor3 = Config.Theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.Parent = TopBar
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -40, 0, 30)
    Subtitle.Position = UDim2.new(0, 20, 0, 70)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Enter your key to continue"
    Subtitle.TextColor3 = Config.Theme.TextDark
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 14
    Subtitle.Parent = MainFrame
    
    -- HWID Display
    local HWIDFrame = CreateRoundedFrame(MainFrame, 
        UDim2.new(1, -40, 0, 50), 
        UDim2.new(0, 20, 0, 110), 
        Config.Theme.Secondary, 8)
    
    local HWIDLabel = Instance.new("TextLabel")
    HWIDLabel.Size = UDim2.new(1, -20, 0, 20)
    HWIDLabel.Position = UDim2.new(0, 10, 0, 5)
    HWIDLabel.BackgroundTransparency = 1
    HWIDLabel.Text = "Your HWID:"
    HWIDLabel.TextColor3 = Config.Theme.TextDark
    HWIDLabel.Font = Enum.Font.Gotham
    HWIDLabel.TextSize = 12
    HWIDLabel.TextXAlignment = Enum.TextXAlignment.Left
    HWIDLabel.Parent = HWIDFrame
    
    local HWIDValue = Instance.new("TextLabel")
    HWIDValue.Size = UDim2.new(1, -60, 0, 20)
    HWIDValue.Position = UDim2.new(0, 10, 0, 25)
    HWIDValue.BackgroundTransparency = 1
    HWIDValue.Text = GetHWID()
    HWIDValue.TextColor3 = Config.Theme.Text
    HWIDValue.Font = Enum.Font.GothamBold
    HWIDValue.TextSize = 11
    HWIDValue.TextXAlignment = Enum.TextXAlignment.Left
    HWIDValue.TextTruncate = Enum.TextTruncate.AtEnd
    HWIDValue.Parent = HWIDFrame
    
    -- Copy HWID Button
    local CopyButton = CreateRoundedFrame(HWIDFrame, 
        UDim2.new(0, 40, 0, 30), 
        UDim2.new(1, -50, 0, 10), 
        Config.Theme.Accent, 6)
    
    local CopyIcon = Instance.new("TextLabel")
    CopyIcon.Size = UDim2.new(1, 0, 1, 0)
    CopyIcon.BackgroundTransparency = 1
    CopyIcon.Text = "📋"
    CopyIcon.Font = Enum.Font.Gotham
    CopyIcon.TextSize = 18
    CopyIcon.Parent = CopyButton
    
    local CopyDetector = Instance.new("TextButton")
    CopyDetector.Size = UDim2.new(1, 0, 1, 0)
    CopyDetector.BackgroundTransparency = 1
    CopyDetector.Text = ""
    CopyDetector.Parent = CopyButton
    
    CopyDetector.MouseButton1Click:Connect(function()
        setclipboard(GetHWID())
        ShowNotification("Copied", "HWID copied to clipboard!", "Success", 2)
        CreateTween(CopyButton, {BackgroundColor3 = Config.Theme.Success}, 0.2)
        task.wait(0.5)
        CreateTween(CopyButton, {BackgroundColor3 = Config.Theme.Accent}, 0.2)
    end)
    
    CopyDetector.MouseEnter:Connect(function()
        CreateTween(CopyButton, {Size = UDim2.new(0, 45, 0, 35)}, 0.2)
    end)
    
    CopyDetector.MouseLeave:Connect(function()
        CreateTween(CopyButton, {Size = UDim2.new(0, 40, 0, 30)}, 0.2)
    end)
    
    -- Key Input Container
    local InputContainer = CreateRoundedFrame(MainFrame, 
        UDim2.new(1, -40, 0, 80), 
        UDim2.new(0, 20, 0, 180), 
        Config.Theme.Secondary, 8)
    
    local InputLabel = Instance.new("TextLabel")
    InputLabel.Size = UDim2.new(1, -20, 0, 20)
    InputLabel.Position = UDim2.new(0, 10, 0, 10)
    InputLabel.BackgroundTransparency = 1
    InputLabel.Text = "Enter Key:"
    InputLabel.TextColor3 = Config.Theme.TextDark
    InputLabel.Font = Enum.Font.Gotham
    InputLabel.TextSize = 12
    InputLabel.TextXAlignment = Enum.TextXAlignment.Left
    InputLabel.Parent = InputContainer
    
    -- Key Input Box
    local KeyInputBox = CreateRoundedFrame(InputContainer, 
        UDim2.new(1, -20, 0, 40), 
        UDim2.new(0, 10, 0, 35), 
        Config.Theme.Background, 6)
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -20, 1, 0)
    KeyInput.Position = UDim2.new(0, 10, 0, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    KeyInput.TextColor3 = Config.Theme.Text
    KeyInput.PlaceholderColor3 = Config.Theme.TextDark
    KeyInput.Font = Enum.Font.GothamBold
    KeyInput.TextSize = 14
    KeyInput.TextXAlignment = Enum.TextXAlignment.Center
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = KeyInputBox
    
    KeyInput.Focused:Connect(function()
        CreateTween(KeyInputBox, {BackgroundColor3 = Config.Theme.Accent}, 0.2)
        CreateTween(KeyInputBox, {Size = UDim2.new(1, -15, 0, 42)}, 0.2)
    end)
    
    KeyInput.FocusLost:Connect(function()
        CreateTween(KeyInputBox, {BackgroundColor3 = Config.Theme.Background}, 0.2)
        CreateTween(KeyInputBox, {Size = UDim2.new(1, -20, 0, 40)}, 0.2)
    end)
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -40, 0, 30)
    StatusLabel.Position = UDim2.new(0, 20, 0, 275)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Config.Theme.TextDark
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 13
    StatusLabel.TextTransparency = 1
    StatusLabel.Parent = MainFrame
    
    -- Submit Button
    local SubmitButton = CreateRoundedFrame(MainFrame, 
        UDim2.new(1, -40, 0, 50), 
        UDim2.new(0, 20, 0, 315), 
        Config.Theme.Accent, 8)
    
    local SubmitLabel = Instance.new("TextLabel")
    SubmitLabel.Size = UDim2.new(1, 0, 1, 0)
    SubmitLabel.BackgroundTransparency = 1
    SubmitLabel.Text = "SUBMIT KEY"
    SubmitLabel.TextColor3 = Config.Theme.Text
    SubmitLabel.Font = Enum.Font.GothamBold
    SubmitLabel.TextSize = 16
    SubmitLabel.Parent = SubmitButton
    
    local SubmitDetector = Instance.new("TextButton")
    SubmitDetector.Size = UDim2.new(1, 0, 1, 0)
    SubmitDetector.BackgroundTransparency = 1
    SubmitDetector.Text = ""
    SubmitDetector.Parent = SubmitButton
    
    -- Get Key Button
    local GetKeyButton = CreateRoundedFrame(MainFrame, 
        UDim2.new(0.48, 0, 0, 45), 
        UDim2.new(0, 20, 0, 380), 
        Config.Theme.Secondary, 8)
    
    local GetKeyLabel = Instance.new("TextLabel")
    GetKeyLabel.Size = UDim2.new(1, 0, 1, 0)
    GetKeyLabel.BackgroundTransparency = 1
    GetKeyLabel.Text = "🔑 Get Key"
    GetKeyLabel.TextColor3 = Config.Theme.Text
    GetKeyLabel.Font = Enum.Font.GothamSemibold
    GetKeyLabel.TextSize = 14
    GetKeyLabel.Parent = GetKeyButton
    
    local GetKeyDetector = Instance.new("TextButton")
    GetKeyDetector.Size = UDim2.new(1, 0, 1, 0)
    GetKeyDetector.BackgroundTransparency = 1
    GetKeyDetector.Text = ""
    GetKeyDetector.Parent = GetKeyButton
    
    GetKeyDetector.MouseButton1Click:Connect(function()
        setclipboard(Config.KeyLink)
        ShowNotification("Key Link", "Link copied to clipboard!", "Info", 3)
        CreateTween(GetKeyButton, {BackgroundColor3 = Config.Theme.Accent}, 0.2)
        task.wait(0.3)
        CreateTween(GetKeyButton, {BackgroundColor3 = Config.Theme.Secondary}, 0.2)
    end)
    
    GetKeyDetector.MouseEnter:Connect(function()
        CreateTween(GetKeyButton, {BackgroundColor3 = Config.Theme.Background}, 0.2)
    end)
    
    GetKeyDetector.MouseLeave:Connect(function()
        CreateTween(GetKeyButton, {BackgroundColor3 = Config.Theme.Secondary}, 0.2)
    end)
    
    -- Discord Button
    local DiscordButton = CreateRoundedFrame(MainFrame, 
        UDim2.new(0.48, 0, 0, 45), 
        UDim2.new(0.52, 0, 0, 380), 
        Config.Theme.Secondary, 8)
    
    local DiscordLabel = Instance.new("TextLabel")
    DiscordLabel.Size = UDim2.new(1, 0, 1, 0)
    DiscordLabel.BackgroundTransparency = 1
    DiscordLabel.Text = "💬 Discord"
    DiscordLabel.TextColor3 = Config.Theme.Text
    DiscordLabel.Font = Enum.Font.GothamSemibold
    DiscordLabel.TextSize = 14
    DiscordLabel.Parent = DiscordButton
    
    local DiscordDetector = Instance.new("TextButton")
    DiscordDetector.Size = UDim2.new(1, 0, 1, 0)
    DiscordDetector.BackgroundTransparency = 1
    DiscordDetector.Text = ""
    DiscordDetector.Parent = DiscordButton
    
    DiscordDetector.MouseButton1Click:Connect(function()
        setclipboard(Config.DiscordLink)
        ShowNotification("Discord", "Discord link copied!", "Info", 3)
        CreateTween(DiscordButton, {BackgroundColor3 = Config.Theme.Accent}, 0.2)
        task.wait(0.3)
        CreateTween(DiscordButton, {BackgroundColor3 = Config.Theme.Secondary}, 0.2)
    end)
    
    DiscordDetector.MouseEnter:Connect(function()
        CreateTween(DiscordButton, {BackgroundColor3 = Config.Theme.Background}, 0.2)
    end)
    
    DiscordDetector.MouseLeave:Connect(function()
        CreateTween(DiscordButton, {BackgroundColor3 = Config.Theme.Secondary}, 0.2)
    end)
    
    -- Footer
    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 30)
    Footer.Position = UDim2.new(0, 0, 1, -40)
    Footer.BackgroundTransparency = 1
    Footer.Text = "Rift Key System v1.0 | Secure Authentication"
    Footer.TextColor3 = Config.Theme.TextDark
    Footer.Font = Enum.Font.Gotham
    Footer.TextSize = 11
    Footer.Parent = MainFrame
    
    -- Key Validation Function
    local function ValidateAndSubmit()
        if locked then
            local timeLeft = math.ceil(lockExpiry - os.time())
            if timeLeft > 0 then
                StatusLabel.Text = string.format("⏱️ Locked out for %d seconds", timeLeft)
                StatusLabel.TextColor3 = Config.Theme.Error
                CreateTween(StatusLabel, {TextTransparency = 0}, 0.2)
                ShowNotification("Locked Out", "Too many failed attempts!", "Error", 3)
                return
            else
                locked = false
                attempts = 0
            end
        end
        
        local key = KeyInput.Text:gsub("%s+", "") -- Remove whitespace
        
        -- Check key length
        if Config.KeyLength > 0 and #key ~= Config.KeyLength then
            StatusLabel.Text = string.format("❌ Key must be %d characters", Config.KeyLength)
            StatusLabel.TextColor3 = Config.Theme.Error
            CreateTween(StatusLabel, {TextTransparency = 0}, 0.2)
            CreateTween(KeyInputBox, {BackgroundColor3 = Config.Theme.Error}, 0.1)
            task.wait(0.1)
            CreateTween(KeyInputBox, {BackgroundColor3 = Config.Theme.Background}, 0.1)
            return
        end
        
        -- Validate key
        local isValid, reason = ValidateKey(key)
        
        if isValid then
            StatusLabel.Text = "✅ Key Valid! Loading..."
            StatusLabel.TextColor3 = Config.Theme.Success
            CreateTween(StatusLabel, {TextTransparency = 0}, 0.2)
            CreateTween(SubmitButton, {BackgroundColor3 = Config.Theme.Success}, 0.3)
            
            ShowNotification("Success", "Authentication successful!", "Success", 2)
            
            -- Save key
            SaveKeyLocally(key)
            
            -- Close UI
            task.wait(1)
            CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5)
            CreateTween(MainFrame, {BackgroundTransparency = 1}, 0.5)
            CreateTween(Blur, {BackgroundTransparency = 1}, 0.5)
            task.wait(0.5)
            KeySystemGui:Destroy()
            
            -- Execute callback
            callback(true)
        else
            attempts = attempts + 1
            
            local errorMessages = {
                invalid = "❌ Invalid key",
                hwid_mismatch = "❌ HWID mismatch"
            }
            
            StatusLabel.Text = errorMessages[reason] or "❌ Invalid key"
            StatusLabel.TextColor3 = Config.Theme.Error
            CreateTween(StatusLabel, {TextTransparency = 0}, 0.2)
            
            -- Shake animation
            local originalPos = KeyInputBox.Position
            CreateTween(KeyInputBox, {Position = originalPos + UDim2.new(0, -10, 0, 0)}, 0.05)
            task.wait(0.05)
            CreateTween(KeyInputBox, {Position = originalPos + UDim2.new(0, 10, 0, 0)}, 0.05)
            task.wait(0.05)
            CreateTween(KeyInputBox, {Position = originalPos}, 0.05)
            
            CreateTween(KeyInputBox, {BackgroundColor3 = Config.Theme.Error}, 0.1)
            task.wait(0.2)
            CreateTween(KeyInputBox, {BackgroundColor3 = Config.Theme.Background}, 0.3)
            
            ShowNotification("Error", string.format("Invalid key! (%d/%d attempts)", attempts, Config.MaxAttempts), "Error", 3)
            
            -- Check for lockout
            if attempts >= Config.MaxAttempts then
                locked = true
                lockExpiry = os.time() + Config.LockoutDuration
                StatusLabel.Text = string.format("⏱️ Locked out for %d seconds", Config.LockoutDuration)
                ShowNotification("Locked Out", string.format("Too many attempts! Locked for %d seconds", Config.LockoutDuration), "Error", 5)
            end
        end
    end
    
    -- Submit button click
    SubmitDetector.MouseButton1Click:Connect(ValidateAndSubmit)
    
    -- Enter key to submit
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            ValidateAndSubmit()
        end
    end)
    
    -- Button hover effects
    SubmitDetector.MouseEnter:Connect(function()
        if not locked then
            CreateTween(SubmitButton, {Size = UDim2.new(1, -35, 0, 52)}, 0.2)
        end
    end)
    
    SubmitDetector.MouseLeave:Connect(function()
        CreateTween(SubmitButton, {Size = UDim2.new(1, -40, 0, 50)}, 0.2)
    end)
    
    -- Entrance animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    task.wait(0.1)
    CreateTween(MainFrame, {Size = UDim2.new(0, 450, 0, 500), Position = UDim2.new(0.5, -225, 0.5, -250)}, 0.5, Enum.EasingStyle.Back)
end

return RiftKeySystem
