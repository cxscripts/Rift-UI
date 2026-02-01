--[[
    Rift UI Library
    Created by: Cxrter
    
    A professional, customizable UI library for Roblox
]]

local Rift = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Create ScreenGui
local RiftGui = Instance.new("ScreenGui")
RiftGui.Name = "RiftUI_" .. tostring(math.random(1000, 9999))
RiftGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RiftGui.ResetOnSpawn = false

-- Check if the game allows ScreenGuis in CoreGui
local success = pcall(function()
    RiftGui.Parent = CoreGui
end)

if not success then
    RiftGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Default theme
local DefaultTheme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(120, 90, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 170, 50),
    Error = Color3.fromRGB(255, 80, 80)
}

-- Utility Functions
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

-- Loading Screen
local function ShowLoadingScreen(title)
    local LoadingScreen = CreateRoundedFrame(RiftGui, UDim2.new(0, 400, 0, 200), UDim2.new(0.5, -200, 0.5, -100), DefaultTheme.Background, 12)
    LoadingScreen.ZIndex = 1000
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Rift UI"
    Title.TextColor3 = DefaultTheme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.Parent = LoadingScreen
    
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Size = UDim2.new(1, 0, 0, 20)
    LoadingText.Position = UDim2.new(0, 0, 0, 80)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "Loading..."
    LoadingText.TextColor3 = DefaultTheme.TextDark
    LoadingText.Font = Enum.Font.Gotham
    LoadingText.TextSize = 14
    LoadingText.Parent = LoadingScreen
    
    local ProgressBar = CreateRoundedFrame(LoadingScreen, UDim2.new(0.8, 0, 0, 4), UDim2.new(0.1, 0, 0, 120), DefaultTheme.Secondary, 2)
    local Progress = CreateRoundedFrame(ProgressBar, UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), DefaultTheme.Accent, 2)
    
    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, 0, 0, 20)
    Credits.Position = UDim2.new(0, 0, 1, -35)
    Credits.BackgroundTransparency = 1
    Credits.Text = "Created by Cxrter"
    Credits.TextColor3 = DefaultTheme.TextDark
    Credits.Font = Enum.Font.Gotham
    Credits.TextSize = 12
    Credits.Parent = LoadingScreen
    
    CreateTween(Progress, {Size = UDim2.new(1, 0, 1, 0)}, 1.5)
    
    task.wait(1.5)
    CreateTween(LoadingScreen, {BackgroundTransparency = 1}, 0.3)
    for _, child in pairs(LoadingScreen:GetChildren()) do
        if child:IsA("TextLabel") then
            CreateTween(child, {TextTransparency = 1}, 0.3)
        end
    end
    CreateTween(ProgressBar, {BackgroundTransparency = 1}, 0.3)
    CreateTween(Progress, {BackgroundTransparency = 1}, 0.3)
    
    task.wait(0.3)
    LoadingScreen:Destroy()
end

-- Notification System
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
NotificationContainer.Position = UDim2.new(1, -310, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = RiftGui

local NotificationList = Instance.new("UIListLayout")
NotificationList.Padding = UDim.new(0, 10)
NotificationList.SortOrder = Enum.SortOrder.LayoutOrder
NotificationList.Parent = NotificationContainer

function Rift:Notify(options)
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    local notifType = options.Type or "Default"
    
    local typeColors = {
        Default = DefaultTheme.Accent,
        Success = DefaultTheme.Success,
        Warning = DefaultTheme.Warning,
        Error = DefaultTheme.Error
    }
    
    local Notification = CreateRoundedFrame(NotificationContainer, UDim2.new(1, 0, 0, 80), UDim2.new(0, 0, 0, 0), DefaultTheme.Background, 8)
    Notification.BackgroundTransparency = 1
    
    local Accent = CreateRoundedFrame(Notification, UDim2.new(0, 4, 1, 0), UDim2.new(0, 0, 0, 0), typeColors[notifType] or DefaultTheme.Accent, 8)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 15, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = DefaultTheme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextTransparency = 1
    TitleLabel.Parent = Notification
    
    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, -20, 0, 45)
    ContentLabel.Position = UDim2.new(0, 15, 0, 30)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = content
    ContentLabel.TextColor3 = DefaultTheme.TextDark
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextSize = 12
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
    ContentLabel.TextWrapped = true
    ContentLabel.TextTransparency = 1
    ContentLabel.Parent = Notification
    
    CreateTween(Notification, {BackgroundTransparency = 0}, 0.3)
    CreateTween(TitleLabel, {TextTransparency = 0}, 0.3)
    CreateTween(ContentLabel, {TextTransparency = 0}, 0.3)
    
    task.delay(duration, function()
        CreateTween(Notification, {BackgroundTransparency = 1}, 0.3)
        CreateTween(TitleLabel, {TextTransparency = 1}, 0.3)
        CreateTween(ContentLabel, {TextTransparency = 1}, 0.3)
        task.wait(0.3)
        Notification:Destroy()
    end)
end

-- Main Window Creation
function Rift:CreateWindow(options)
    local WindowTitle = options.Name or "Rift UI"
    local Theme = options.Theme or DefaultTheme
    local ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    
    ShowLoadingScreen(WindowTitle)
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Theme = Theme
    Window.Minimized = false
    Window.Visible = true
    
    -- Main Container
    local MainFrame = CreateRoundedFrame(RiftGui, UDim2.new(0, 600, 0, 400), UDim2.new(0.5, -300, 0.5, -200), Theme.Background, 12)
    MainFrame.ClipsDescendants = true
    
    -- Drop shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- Top Bar
    local TopBar = CreateRoundedFrame(MainFrame, UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 0), Theme.Secondary, 12)
    
    local TopBarBottom = Instance.new("Frame")
    TopBarBottom.Size = UDim2.new(1, 0, 0, 12)
    TopBarBottom.Position = UDim2.new(0, 0, 1, -12)
    TopBarBottom.BackgroundColor3 = Theme.Secondary
    TopBarBottom.BorderSizePixel = 0
    TopBarBottom.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = WindowTitle
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Minimize Button
    local MinimizeButton = CreateRoundedFrame(TopBar, UDim2.new(0, 30, 0, 30), UDim2.new(1, -75, 0.5, -15), Theme.Background, 6)
    MinimizeButton.ClipsDescendants = true
    
    local MinimizeIcon = Instance.new("TextLabel")
    MinimizeIcon.Size = UDim2.new(1, 0, 1, 0)
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Text = "-"
    MinimizeIcon.TextColor3 = Theme.Text
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.TextSize = 20
    MinimizeIcon.Parent = MinimizeButton
    
    local MinimizeDetector = Instance.new("TextButton")
    MinimizeDetector.Size = UDim2.new(1, 0, 1, 0)
    MinimizeDetector.BackgroundTransparency = 1
    MinimizeDetector.Text = ""
    MinimizeDetector.Parent = MinimizeButton
    
    MinimizeDetector.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            CreateTween(MainFrame, {Size = UDim2.new(0, 600, 0, 45)}, 0.3)
            MinimizeIcon.Text = "+"
        else
            CreateTween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.3)
            MinimizeIcon.Text = "-"
        end
    end)
    
    MinimizeDetector.MouseEnter:Connect(function()
        CreateTween(MinimizeButton, {BackgroundColor3 = Theme.Accent}, 0.2)
    end)
    
    MinimizeDetector.MouseLeave:Connect(function()
        CreateTween(MinimizeButton, {BackgroundColor3 = Theme.Background}, 0.2)
    end)
    
    -- Close Button
    local CloseButton = CreateRoundedFrame(TopBar, UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0.5, -15), Theme.Background, 6)
    CloseButton.ClipsDescendants = true
    
    local CloseIcon = Instance.new("TextLabel")
    CloseIcon.Size = UDim2.new(1, 0, 1, 0)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Text = "×"
    CloseIcon.TextColor3 = Theme.Text
    CloseIcon.Font = Enum.Font.GothamBold
    CloseIcon.TextSize = 24
    CloseIcon.Parent = CloseButton
    
    local CloseDetector = Instance.new("TextButton")
    CloseDetector.Size = UDim2.new(1, 0, 1, 0)
    CloseDetector.BackgroundTransparency = 1
    CloseDetector.Text = ""
    CloseDetector.Parent = CloseButton
    
    CloseDetector.MouseButton1Click:Connect(function()
        Window.Visible = false
        CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        CreateTween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        MainFrame.Visible = false
    end)
    
    CloseDetector.MouseEnter:Connect(function()
        CreateTween(CloseButton, {BackgroundColor3 = Theme.Error}, 0.2)
    end)
    
    CloseDetector.MouseLeave:Connect(function()
        CreateTween(CloseButton, {BackgroundColor3 = Theme.Background}, 0.2)
    end)
    
    -- Tab Container
    local TabContainer = CreateRoundedFrame(MainFrame, UDim2.new(0, 150, 1, -55), UDim2.new(0, 10, 0, 50), Theme.Secondary, 8)
    TabContainer.ClipsDescendants = false
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingBottom = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = CreateRoundedFrame(MainFrame, UDim2.new(1, -180, 1, -55), UDim2.new(0, 170, 0, 50), Theme.Secondary, 8)
    ContentContainer.ClipsDescendants = false
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 5)
    ContentPadding.PaddingBottom = UDim.new(0, 5)
    ContentPadding.PaddingLeft = UDim.new(0, 5)
    ContentPadding.PaddingRight = UDim.new(0, 5)
    ContentPadding.Parent = ContentContainer
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        CreateTween(MainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
    end
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == ToggleKey then
            Window.Visible = not Window.Visible
            if Window.Visible then
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                MainFrame.BackgroundTransparency = 1
                CreateTween(MainFrame, {Size = UDim2.new(0, 600, 0, Window.Minimized and 45 or 400), Position = UDim2.new(0.5, -300, 0.5, -200)}, 0.3)
                CreateTween(MainFrame, {BackgroundTransparency = 0}, 0.3)
            else
                CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
                CreateTween(MainFrame, {BackgroundTransparency = 1}, 0.3)
                task.wait(0.3)
                MainFrame.Visible = false
            end
        end
    end)
    
    -- Create Tab Function
    function Window:CreateTab(tabName)
        local Tab = {}
        Tab.Name = tabName
        Tab.Elements = {}
        
        local TabButton = CreateRoundedFrame(TabContainer, UDim2.new(1, -20, 0, 35), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
        TabButton.ZIndex = 2
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -10, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.TextColor3 = Theme.TextDark
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.ZIndex = 3
        TabLabel.Parent = TabButton
        
        local TabDetector = Instance.new("TextButton")
        TabDetector.Size = UDim2.new(1, 0, 1, 0)
        TabDetector.BackgroundTransparency = 1
        TabDetector.Text = ""
        TabDetector.ZIndex = 4
        TabDetector.Parent = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Theme.Accent
        TabContent.Visible = false
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ZIndex = 2
        TabContent.Parent = ContentContainer
        
        local TabContentList = Instance.new("UIListLayout")
        TabContentList.Padding = UDim.new(0, 8)
        TabContentList.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentList.Parent = TabContent
        
        local TabContentPadding = Instance.new("UIPadding")
        TabContentPadding.PaddingTop = UDim.new(0, 10)
        TabContentPadding.PaddingBottom = UDim.new(0, 10)
        TabContentPadding.PaddingLeft = UDim.new(0, 10)
        TabContentPadding.PaddingRight = UDim.new(0, 10)
        TabContentPadding.Parent = TabContent
        
        TabContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentList.AbsoluteContentSize.Y + 20)
        end)
        
        TabDetector.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                CreateTween(tab.Button, {BackgroundColor3 = Theme.Background}, 0.2)
                CreateTween(tab.Label, {TextColor3 = Theme.TextDark}, 0.2)
            end
            
            TabContent.Visible = true
            CreateTween(TabButton, {BackgroundColor3 = Theme.Accent}, 0.2)
            CreateTween(TabLabel, {TextColor3 = Theme.Text}, 0.2)
            Window.CurrentTab = Tab
        end)
        
        TabDetector.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                CreateTween(TabButton, {BackgroundColor3 = Theme.Secondary}, 0.2)
            end
        end)
        
        TabDetector.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                CreateTween(TabButton, {BackgroundColor3 = Theme.Background}, 0.2)
            end
        end)
        
        table.insert(Window.Tabs, {Button = TabButton, Label = TabLabel, Content = TabContent, Tab = Tab})
        
        if #Window.Tabs == 1 then
            TabContent.Visible = true
            CreateTween(TabButton, {BackgroundColor3 = Theme.Accent}, 0.2)
            CreateTween(TabLabel, {TextColor3 = Theme.Text}, 0.2)
            Window.CurrentTab = Tab
        end
        
        -- Label
        function Tab:CreateLabel(text)
            local LabelFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 30), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = LabelFrame
            
            return {
                SetText = function(self, newText)
                    Label.Text = newText
                end
            }
        end
        
        -- Button
        function Tab:CreateButton(options)
            local buttonText = options.Name or "Button"
            local callback = options.Callback or function() end
            
            local ButtonFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 35), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Size = UDim2.new(1, -20, 1, 0)
            ButtonLabel.Position = UDim2.new(0, 10, 0, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = buttonText
            ButtonLabel.TextColor3 = Theme.Text
            ButtonLabel.Font = Enum.Font.GothamSemibold
            ButtonLabel.TextSize = 13
            ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
            ButtonLabel.Parent = ButtonFrame
            
            local ButtonDetector = Instance.new("TextButton")
            ButtonDetector.Size = UDim2.new(1, 0, 1, 0)
            ButtonDetector.BackgroundTransparency = 1
            ButtonDetector.Text = ""
            ButtonDetector.Parent = ButtonFrame
            
            ButtonDetector.MouseButton1Click:Connect(function()
                CreateTween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                task.wait(0.1)
                CreateTween(ButtonFrame, {BackgroundColor3 = Theme.Background}, 0.1)
                callback()
            end)
            
            ButtonDetector.MouseEnter:Connect(function()
                CreateTween(ButtonFrame, {BackgroundColor3 = Theme.Secondary}, 0.2)
            end)
            
            ButtonDetector.MouseLeave:Connect(function()
                CreateTween(ButtonFrame, {BackgroundColor3 = Theme.Background}, 0.2)
            end)
        end
        
        -- Toggle
        function Tab:CreateToggle(options)
            local toggleText = options.Name or "Toggle"
            local default = options.Default or false
            local callback = options.Callback or function() end
            
            local toggled = default
            
            local ToggleFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 35), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = toggleText
            ToggleLabel.TextColor3 = Theme.Text
            ToggleLabel.Font = Enum.Font.GothamSemibold
            ToggleLabel.TextSize = 13
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleOuter = CreateRoundedFrame(ToggleFrame, UDim2.new(0, 40, 0, 20), UDim2.new(1, -50, 0.5, -10), Theme.Secondary, 10)
            
            local ToggleInner = CreateRoundedFrame(ToggleOuter, UDim2.new(0, 16, 0, 16), UDim2.new(0, 2, 0.5, -8), Theme.TextDark, 8)
            
            if toggled then
                ToggleOuter.BackgroundColor3 = Theme.Accent
                ToggleInner.Position = UDim2.new(1, -18, 0.5, -8)
                ToggleInner.BackgroundColor3 = Theme.Text
            end
            
            local ToggleDetector = Instance.new("TextButton")
            ToggleDetector.Size = UDim2.new(1, 0, 1, 0)
            ToggleDetector.BackgroundTransparency = 1
            ToggleDetector.Text = ""
            ToggleDetector.Parent = ToggleFrame
            
            ToggleDetector.MouseButton1Click:Connect(function()
                toggled = not toggled
                if toggled then
                    CreateTween(ToggleOuter, {BackgroundColor3 = Theme.Accent}, 0.2)
                    CreateTween(ToggleInner, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}, 0.2)
                else
                    CreateTween(ToggleOuter, {BackgroundColor3 = Theme.Secondary}, 0.2)
                    CreateTween(ToggleInner, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDark}, 0.2)
                end
                callback(toggled)
            end)
            
            ToggleDetector.MouseEnter:Connect(function()
                CreateTween(ToggleFrame, {BackgroundColor3 = Theme.Secondary}, 0.2)
            end)
            
            ToggleDetector.MouseLeave:Connect(function()
                CreateTween(ToggleFrame, {BackgroundColor3 = Theme.Background}, 0.2)
            end)
            
            return {
                SetValue = function(self, value)
                    toggled = value
                    if toggled then
                        CreateTween(ToggleOuter, {BackgroundColor3 = Theme.Accent}, 0.2)
                        CreateTween(ToggleInner, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}, 0.2)
                    else
                        CreateTween(ToggleOuter, {BackgroundColor3 = Theme.Secondary}, 0.2)
                        CreateTween(ToggleInner, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDark}, 0.2)
                    end
                    callback(toggled)
                end
            }
        end
        
        -- Slider
        function Tab:CreateSlider(options)
            local sliderText = options.Name or "Slider"
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or min
            local increment = options.Increment or 1
            local callback = options.Callback or function() end
            
            local currentValue = default
            
            local SliderFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 50), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = sliderText
            SliderLabel.TextColor3 = Theme.Text
            SliderLabel.Font = Enum.Font.GothamSemibold
            SliderLabel.TextSize = 13
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
            ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(currentValue)
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local SliderBar = CreateRoundedFrame(SliderFrame, UDim2.new(1, -20, 0, 4), UDim2.new(0, 10, 1, -15), Theme.Secondary, 2)
            
            local SliderFill = CreateRoundedFrame(SliderBar, UDim2.new((currentValue - min) / (max - min), 0, 1, 0), UDim2.new(0, 0, 0, 0), Theme.Accent, 2)
            
            local SliderButton = CreateRoundedFrame(SliderBar, UDim2.new(0, 12, 0, 12), UDim2.new((currentValue - min) / (max - min), -6, 0.5, -6), Theme.Text, 6)
            
            local draggingSlider = false
            
            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                end
            end)
            
            SliderButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    local percentage = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    
                    currentValue = math.floor((min + (max - min) * percentage) / increment + 0.5) * increment
                    currentValue = math.clamp(currentValue, min, max)
                    
                    ValueLabel.Text = tostring(currentValue)
                    CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
                    CreateTween(SliderButton, {Position = UDim2.new(percentage, -6, 0.5, -6)}, 0.1)
                    
                    callback(currentValue)
                end
            end)
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    local percentage = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    
                    currentValue = math.floor((min + (max - min) * percentage) / increment + 0.5) * increment
                    currentValue = math.clamp(currentValue, min, max)
                    
                    ValueLabel.Text = tostring(currentValue)
                    CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.2)
                    CreateTween(SliderButton, {Position = UDim2.new(percentage, -6, 0.5, -6)}, 0.2)
                    
                    callback(currentValue)
                end
            end)
            
            return {
                SetValue = function(self, value)
                    currentValue = math.clamp(value, min, max)
                    local percentage = (currentValue - min) / (max - min)
                    ValueLabel.Text = tostring(currentValue)
                    CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.2)
                    CreateTween(SliderButton, {Position = UDim2.new(percentage, -6, 0.5, -6)}, 0.2)
                    callback(currentValue)
                end
            }
        end
        
        -- Dropdown
        function Tab:CreateDropdown(options)
            local dropdownText = options.Name or "Dropdown"
            local items = options.Options or {}
            local default = options.Default or items[1] or "None"
            local callback = options.Callback or function() end
            
            local currentOption = default
            local isOpen = false
            
            local DropdownFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 35), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = dropdownText
            DropdownLabel.TextColor3 = Theme.Text
            DropdownLabel.Font = Enum.Font.GothamSemibold
            DropdownLabel.TextSize = 13
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame
            
            local DropdownDisplay = CreateRoundedFrame(DropdownFrame, UDim2.new(0.45, 0, 0, 25), UDim2.new(0.55, -5, 0.5, -12.5), Theme.Secondary, 4)
            
            local DropdownValue = Instance.new("TextLabel")
            DropdownValue.Size = UDim2.new(1, -30, 1, 0)
            DropdownValue.Position = UDim2.new(0, 8, 0, 0)
            DropdownValue.BackgroundTransparency = 1
            DropdownValue.Text = currentOption
            DropdownValue.TextColor3 = Theme.Text
            DropdownValue.Font = Enum.Font.Gotham
            DropdownValue.TextSize = 12
            DropdownValue.TextXAlignment = Enum.TextXAlignment.Left
            DropdownValue.TextTruncate = Enum.TextTruncate.AtEnd
            DropdownValue.Parent = DropdownDisplay
            
            local DropdownArrow = Instance.new("TextLabel")
            DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
            DropdownArrow.Position = UDim2.new(1, -25, 0, 0)
            DropdownArrow.BackgroundTransparency = 1
            DropdownArrow.Text = "▼"
            DropdownArrow.TextColor3 = Theme.TextDark
            DropdownArrow.Font = Enum.Font.Gotham
            DropdownArrow.TextSize = 10
            DropdownArrow.Parent = DropdownDisplay
            
            local DropdownList = CreateRoundedFrame(DropdownFrame, UDim2.new(0.45, 0, 0, 0), UDim2.new(0.55, -5, 1, 5), Theme.Secondary, 4)
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            DropdownList.ClipsDescendants = true
            
            local DropdownScroll = Instance.new("ScrollingFrame")
            DropdownScroll.Size = UDim2.new(1, 0, 1, 0)
            DropdownScroll.BackgroundTransparency = 1
            DropdownScroll.BorderSizePixel = 0
            DropdownScroll.ScrollBarThickness = 3
            DropdownScroll.ScrollBarImageColor3 = Theme.Accent
            DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownScroll.Parent = DropdownList
            
            local DropdownListLayout = Instance.new("UIListLayout")
            DropdownListLayout.Padding = UDim.new(0, 2)
            DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropdownListLayout.Parent = DropdownScroll
            
            DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, DropdownListLayout.AbsoluteContentSize.Y)
            end)
            
            local function createDropdownItems()
                for _, item in ipairs(items) do
                    local ItemButton = CreateRoundedFrame(DropdownScroll, UDim2.new(1, -5, 0, 25), UDim2.new(0, 0, 0, 0), Theme.Background, 4)
                    
                    local ItemLabel = Instance.new("TextLabel")
                    ItemLabel.Size = UDim2.new(1, -10, 1, 0)
                    ItemLabel.Position = UDim2.new(0, 5, 0, 0)
                    ItemLabel.BackgroundTransparency = 1
                    ItemLabel.Text = item
                    ItemLabel.TextColor3 = Theme.Text
                    ItemLabel.Font = Enum.Font.Gotham
                    ItemLabel.TextSize = 12
                    ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
                    ItemLabel.Parent = ItemButton
                    
                    local ItemDetector = Instance.new("TextButton")
                    ItemDetector.Size = UDim2.new(1, 0, 1, 0)
                    ItemDetector.BackgroundTransparency = 1
                    ItemDetector.Text = ""
                    ItemDetector.Parent = ItemButton
                    
                    ItemDetector.MouseButton1Click:Connect(function()
                        currentOption = item
                        DropdownValue.Text = item
                        isOpen = false
                        CreateTween(DropdownList, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.2)
                        task.wait(0.2)
                        DropdownList.Visible = false
                        CreateTween(DropdownArrow, {Rotation = 0}, 0.2)
                        callback(item)
                    end)
                    
                    ItemDetector.MouseEnter:Connect(function()
                        CreateTween(ItemButton, {BackgroundColor3 = Theme.Accent}, 0.1)
                    end)
                    
                    ItemDetector.MouseLeave:Connect(function()
                        CreateTween(ItemButton, {BackgroundColor3 = Theme.Background}, 0.1)
                    end)
                end
            end
            
            createDropdownItems()
            
            local DropdownDetector = Instance.new("TextButton")
            DropdownDetector.Size = UDim2.new(1, 0, 1, 0)
            DropdownDetector.BackgroundTransparency = 1
            DropdownDetector.Text = ""
            DropdownDetector.ZIndex = 5
            DropdownDetector.Parent = DropdownDisplay
            
            DropdownDetector.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    DropdownList.Visible = true
                    local listHeight = math.min(#items * 27, 150)
                    CreateTween(DropdownList, {Size = UDim2.new(0.45, 0, 0, listHeight)}, 0.2)
                    CreateTween(DropdownArrow, {Rotation = 180}, 0.2)
                else
                    CreateTween(DropdownList, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.2)
                    task.wait(0.2)
                    DropdownList.Visible = false
                    CreateTween(DropdownArrow, {Rotation = 0}, 0.2)
                end
            end)
            
            DropdownDetector.MouseEnter:Connect(function()
                CreateTween(DropdownDisplay, {BackgroundColor3 = Theme.Background}, 0.2)
            end)
            
            DropdownDetector.MouseLeave:Connect(function()
                CreateTween(DropdownDisplay, {BackgroundColor3 = Theme.Secondary}, 0.2)
            end)
            
            return {
                SetValue = function(self, value)
                    if table.find(items, value) then
                        currentOption = value
                        DropdownValue.Text = value
                        callback(value)
                    end
                end,
                Refresh = function(self, newItems)
                    items = newItems
                    for _, child in pairs(DropdownScroll:GetChildren()) do
                        if child:IsA("Frame") then
                            child:Destroy()
                        end
                    end
                    createDropdownItems()
                end
            }
        end
        
        -- Input Box
        function Tab:CreateInput(options)
            local inputText = options.Name or "Input"
            local placeholder = options.PlaceholderText or "Enter text..."
            local callback = options.Callback or function() end
            
            local InputFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 35), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local InputLabel = Instance.new("TextLabel")
            InputLabel.Size = UDim2.new(0.4, 0, 1, 0)
            InputLabel.Position = UDim2.new(0, 10, 0, 0)
            InputLabel.BackgroundTransparency = 1
            InputLabel.Text = inputText
            InputLabel.TextColor3 = Theme.Text
            InputLabel.Font = Enum.Font.GothamSemibold
            InputLabel.TextSize = 13
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.Parent = InputFrame
            
            local InputBox = CreateRoundedFrame(InputFrame, UDim2.new(0.55, 0, 0, 25), UDim2.new(0.45, -5, 0.5, -12.5), Theme.Secondary, 4)
            
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -10, 1, 0)
            Input.Position = UDim2.new(0, 5, 0, 0)
            Input.BackgroundTransparency = 1
            Input.Text = ""
            Input.PlaceholderText = placeholder
            Input.TextColor3 = Theme.Text
            Input.PlaceholderColor3 = Theme.TextDark
            Input.Font = Enum.Font.Gotham
            Input.TextSize = 12
            Input.TextXAlignment = Enum.TextXAlignment.Left
            Input.ClearTextOnFocus = false
            Input.Parent = InputBox
            
            Input.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    callback(Input.Text)
                end
            end)
            
            Input.Focused:Connect(function()
                CreateTween(InputBox, {BackgroundColor3 = Theme.Background}, 0.2)
            end)
            
            Input.FocusLost:Connect(function()
                CreateTween(InputBox, {BackgroundColor3 = Theme.Secondary}, 0.2)
            end)
            
            return {
                SetValue = function(self, value)
                    Input.Text = value
                end
            }
        end
        
        -- Keybind
        function Tab:CreateKeybind(options)
            local keybindText = options.Name or "Keybind"
            local defaultKey = options.Default or Enum.KeyCode.E
            local callback = options.Callback or function() end
            
            local currentKey = defaultKey
            local listening = false
            
            local KeybindFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 35), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
            KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = keybindText
            KeybindLabel.TextColor3 = Theme.Text
            KeybindLabel.Font = Enum.Font.GothamSemibold
            KeybindLabel.TextSize = 13
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.Parent = KeybindFrame
            
            local KeyDisplay = CreateRoundedFrame(KeybindFrame, UDim2.new(0.35, 0, 0, 25), UDim2.new(0.65, -5, 0.5, -12.5), Theme.Secondary, 4)
            
            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Size = UDim2.new(1, 0, 1, 0)
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Text = currentKey.Name
            KeyLabel.TextColor3 = Theme.Text
            KeyLabel.Font = Enum.Font.Gotham
            KeyLabel.TextSize = 12
            KeyLabel.Parent = KeyDisplay
            
            local KeyDetector = Instance.new("TextButton")
            KeyDetector.Size = UDim2.new(1, 0, 1, 0)
            KeyDetector.BackgroundTransparency = 1
            KeyDetector.Text = ""
            KeyDetector.Parent = KeyDisplay
            
            KeyDetector.MouseButton1Click:Connect(function()
                listening = true
                KeyLabel.Text = "..."
                CreateTween(KeyDisplay, {BackgroundColor3 = Theme.Accent}, 0.2)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeyLabel.Text = input.KeyCode.Name
                    listening = false
                    CreateTween(KeyDisplay, {BackgroundColor3 = Theme.Secondary}, 0.2)
                end
                
                if not gameProcessed and input.KeyCode == currentKey and not listening then
                    callback(currentKey)
                end
            end)
            
            KeyDetector.MouseEnter:Connect(function()
                if not listening then
                    CreateTween(KeyDisplay, {BackgroundColor3 = Theme.Background}, 0.2)
                end
            end)
            
            KeyDetector.MouseLeave:Connect(function()
                if not listening then
                    CreateTween(KeyDisplay, {BackgroundColor3 = Theme.Secondary}, 0.2)
                end
            end)
            
            return {
                SetValue = function(self, key)
                    currentKey = key
                    KeyLabel.Text = key.Name
                end
            }
        end
        
        -- Color Picker
        function Tab:CreateColorPicker(options)
            local colorPickerText = options.Name or "Color Picker"
            local defaultColor = options.Default or Color3.fromRGB(255, 255, 255)
            local callback = options.Callback or function() end
            
            local currentColor = defaultColor
            local currentHue = 0
            local currentSat = 0
            local currentVal = 1
            local currentAlpha = options.DefaultAlpha or 1
            local isOpen = false
            
            -- Convert RGB to HSV
            local function RGBtoHSV(color)
                local r, g, b = color.R, color.G, color.B
                local max = math.max(r, g, b)
                local min = math.min(r, g, b)
                local delta = max - min
                
                local h, s, v = 0, 0, max
                
                if delta > 0 then
                    s = delta / max
                    
                    if r == max then
                        h = (g - b) / delta
                    elseif g == max then
                        h = 2 + (b - r) / delta
                    else
                        h = 4 + (r - g) / delta
                    end
                    
                    h = h / 6
                    if h < 0 then h = h + 1 end
                end
                
                return h, s, v
            end
            
            -- Convert HSV to RGB
            local function HSVtoRGB(h, s, v)
                local r, g, b
                
                local i = math.floor(h * 6)
                local f = h * 6 - i
                local p = v * (1 - s)
                local q = v * (1 - f * s)
                local t = v * (1 - (1 - f) * s)
                
                i = i % 6
                
                if i == 0 then r, g, b = v, t, p
                elseif i == 1 then r, g, b = q, v, p
                elseif i == 2 then r, g, b = p, v, t
                elseif i == 3 then r, g, b = p, q, v
                elseif i == 4 then r, g, b = t, p, v
                else r, g, b = v, p, q
                end
                
                return Color3.new(r, g, b)
            end
            
            -- Convert Color3 to Hex
            local function ColorToHex(color)
                return string.format("#%02X%02X%02X", 
                    math.floor(color.R * 255),
                    math.floor(color.G * 255),
                    math.floor(color.B * 255))
            end
            
            -- Convert Hex to Color3
            local function HexToColor(hex)
                hex = hex:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1, 2), 16) / 255
                    local g = tonumber(hex:sub(3, 4), 16) / 255
                    local b = tonumber(hex:sub(5, 6), 16) / 255
                    return Color3.new(r, g, b)
                end
                return currentColor
            end
            
            -- Initialize HSV from default color
            currentHue, currentSat, currentVal = RGBtoHSV(defaultColor)
            
            local ColorPickerFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -20, 0, 35), UDim2.new(0, 0, 0, 0), Theme.Background, 6)
            
            local ColorPickerLabel = Instance.new("TextLabel")
            ColorPickerLabel.Size = UDim2.new(0.6, 0, 1, 0)
            ColorPickerLabel.Position = UDim2.new(0, 10, 0, 0)
            ColorPickerLabel.BackgroundTransparency = 1
            ColorPickerLabel.Text = colorPickerText
            ColorPickerLabel.TextColor3 = Theme.Text
            ColorPickerLabel.Font = Enum.Font.GothamSemibold
            ColorPickerLabel.TextSize = 13
            ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
            ColorPickerLabel.Parent = ColorPickerFrame
            
            local ColorDisplay = CreateRoundedFrame(ColorPickerFrame, UDim2.new(0, 60, 0, 25), UDim2.new(1, -70, 0.5, -12.5), currentColor, 4)
            
            local ColorDetector = Instance.new("TextButton")
            ColorDetector.Size = UDim2.new(1, 0, 1, 0)
            ColorDetector.BackgroundTransparency = 1
            ColorDetector.Text = ""
            ColorDetector.Parent = ColorDisplay
            
            -- Color Picker Popup
            local ColorPickerPopup = CreateRoundedFrame(ColorPickerFrame, UDim2.new(0, 280, 0, 0), UDim2.new(0, 0, 1, 5), Theme.Secondary, 8)
            ColorPickerPopup.Visible = false
            ColorPickerPopup.ZIndex = 100
            ColorPickerPopup.ClipsDescendants = true
            
            -- Saturation/Value Picker
            local SVPicker = CreateRoundedFrame(ColorPickerPopup, UDim2.new(0, 200, 0, 200), UDim2.new(0, 10, 0, 10), Color3.fromRGB(255, 255, 255), 6)
            
            -- Create gradient for saturation
            local SaturationGradient = Instance.new("UIGradient")
            SaturationGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, HSVtoRGB(currentHue, 1, 1))
            })
            SaturationGradient.Rotation = 0
            SaturationGradient.Parent = SVPicker
            
            -- Create gradient for value (darkness)
            local ValueFrame = Instance.new("Frame")
            ValueFrame.Size = UDim2.new(1, 0, 1, 0)
            ValueFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            ValueFrame.BackgroundTransparency = 1
            ValueFrame.BorderSizePixel = 0
            ValueFrame.Parent = SVPicker
            
            local ValueGradient = Instance.new("UIGradient")
            ValueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
            })
            ValueGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            })
            ValueGradient.Rotation = 90
            ValueGradient.Parent = ValueFrame
            
            local SVPickerCorner = Instance.new("UICorner")
            SVPickerCorner.CornerRadius = UDim.new(0, 6)
            SVPickerCorner.Parent = ValueFrame
            
            -- SV Picker Cursor
            local SVCursor = Instance.new("Frame")
            SVCursor.Size = UDim2.new(0, 8, 0, 8)
            SVCursor.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
            SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SVCursor.BorderSizePixel = 2
            SVCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SVCursor.ZIndex = 101
            SVCursor.Parent = SVPicker
            
            local SVCursorCorner = Instance.new("UICorner")
            SVCursorCorner.CornerRadius = UDim.new(1, 0)
            SVCursorCorner.Parent = SVCursor
            
            -- Hue Slider
            local HueSlider = CreateRoundedFrame(ColorPickerPopup, UDim2.new(0, 20, 0, 200), UDim2.new(0, 220, 0, 10), Color3.fromRGB(255, 255, 255), 4)
            
            local HueGradient = Instance.new("UIGradient")
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            HueGradient.Rotation = 90
            HueGradient.Parent = HueSlider
            
            -- Hue Cursor
            local HueCursor = Instance.new("Frame")
            HueCursor.Size = UDim2.new(1, 4, 0, 4)
            HueCursor.Position = UDim2.new(0, -2, currentHue, -2)
            HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueCursor.BorderSizePixel = 2
            HueCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
            HueCursor.ZIndex = 101
            HueCursor.Parent = HueSlider
            
            local HueCursorCorner = Instance.new("UICorner")
            HueCursorCorner.CornerRadius = UDim.new(1, 0)
            HueCursorCorner.Parent = HueCursor
            
            -- Alpha Slider (if enabled)
            local AlphaSlider, AlphaCursor
            if options.Alpha then
                AlphaSlider = CreateRoundedFrame(ColorPickerPopup, UDim2.new(0, 20, 0, 200), UDim2.new(0, 250, 0, 10), Color3.fromRGB(255, 255, 255), 4)
                
                local AlphaGradient = Instance.new("UIGradient")
                AlphaGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                AlphaGradient.Rotation = 90
                AlphaGradient.Parent = AlphaSlider
                
                -- Update alpha gradient color
                AlphaSlider.BackgroundColor3 = currentColor
                
                AlphaCursor = Instance.new("Frame")
                AlphaCursor.Size = UDim2.new(1, 4, 0, 4)
                AlphaCursor.Position = UDim2.new(0, -2, 1 - currentAlpha, -2)
                AlphaCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                AlphaCursor.BorderSizePixel = 2
                AlphaCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
                AlphaCursor.ZIndex = 101
                AlphaCursor.Parent = AlphaSlider
                
                local AlphaCursorCorner = Instance.new("UICorner")
                AlphaCursorCorner.CornerRadius = UDim.new(1, 0)
                AlphaCursorCorner.Parent = AlphaCursor
            end
            
            -- Hex Input
            local HexInput = CreateRoundedFrame(ColorPickerPopup, UDim2.new(0, 200, 0, 30), UDim2.new(0, 10, 0, 220), Theme.Background, 4)
            
            local HexLabel = Instance.new("TextLabel")
            HexLabel.Size = UDim2.new(0, 40, 1, 0)
            HexLabel.Position = UDim2.new(0, 5, 0, 0)
            HexLabel.BackgroundTransparency = 1
            HexLabel.Text = "Hex:"
            HexLabel.TextColor3 = Theme.Text
            HexLabel.Font = Enum.Font.Gotham
            HexLabel.TextSize = 12
            HexLabel.TextXAlignment = Enum.TextXAlignment.Left
            HexLabel.Parent = HexInput
            
            local HexBox = Instance.new("TextBox")
            HexBox.Size = UDim2.new(1, -50, 1, -4)
            HexBox.Position = UDim2.new(0, 45, 0, 2)
            HexBox.BackgroundTransparency = 1
            HexBox.Text = ColorToHex(currentColor)
            HexBox.TextColor3 = Theme.Text
            HexBox.Font = Enum.Font.Gotham
            HexBox.TextSize = 12
            HexBox.TextXAlignment = Enum.TextXAlignment.Left
            HexBox.ClearTextOnFocus = false
            HexBox.Parent = HexInput
            
            -- RGB Display
            local RGBDisplay = CreateRoundedFrame(ColorPickerPopup, UDim2.new(0, 200, 0, 30), UDim2.new(0, 10, 0, 260), Theme.Background, 4)
            
            local RGBLabel = Instance.new("TextLabel")
            RGBLabel.Size = UDim2.new(1, -10, 1, 0)
            RGBLabel.Position = UDim2.new(0, 5, 0, 0)
            RGBLabel.BackgroundTransparency = 1
            RGBLabel.Text = string.format("RGB: %d, %d, %d", 
                math.floor(currentColor.R * 255),
                math.floor(currentColor.G * 255),
                math.floor(currentColor.B * 255))
            RGBLabel.TextColor3 = Theme.Text
            RGBLabel.Font = Enum.Font.Gotham
            RGBLabel.TextSize = 12
            RGBLabel.TextXAlignment = Enum.TextXAlignment.Left
            RGBLabel.Parent = RGBDisplay
            
            -- Update color function
            local function UpdateColor()
                currentColor = HSVtoRGB(currentHue, currentSat, currentVal)
                ColorDisplay.BackgroundColor3 = currentColor
                SaturationGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, HSVtoRGB(currentHue, 1, 1))
                })
                HexBox.Text = ColorToHex(currentColor)
                RGBLabel.Text = string.format("RGB: %d, %d, %d", 
                    math.floor(currentColor.R * 255),
                    math.floor(currentColor.G * 255),
                    math.floor(currentColor.B * 255))
                
                if options.Alpha and AlphaSlider then
                    AlphaSlider.BackgroundColor3 = currentColor
                    callback(currentColor, currentAlpha)
                else
                    callback(currentColor)
                end
            end
            
            -- SV Picker dragging
            local draggingSV = false
            SVPicker.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV = true
                    local pos = input.Position
                    local size = SVPicker.AbsoluteSize
                    local relPos = SVPicker.AbsolutePosition
                    
                    currentSat = math.clamp((pos.X - relPos.X) / size.X, 0, 1)
                    currentVal = 1 - math.clamp((pos.Y - relPos.Y) / size.Y, 0, 1)
                    
                    SVCursor.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
                    UpdateColor()
                end
            end)
            
            SVPicker.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSV = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSV and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = input.Position
                    local size = SVPicker.AbsoluteSize
                    local relPos = SVPicker.AbsolutePosition
                    
                    currentSat = math.clamp((pos.X - relPos.X) / size.X, 0, 1)
                    currentVal = 1 - math.clamp((pos.Y - relPos.Y) / size.Y, 0, 1)
                    
                    SVCursor.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
                    UpdateColor()
                end
            end)
            
            -- Hue Slider dragging
            local draggingHue = false
            HueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true
                    local pos = input.Position
                    local size = HueSlider.AbsoluteSize
                    local relPos = HueSlider.AbsolutePosition
                    
                    currentHue = math.clamp((pos.Y - relPos.Y) / size.Y, 0, 1)
                    HueCursor.Position = UDim2.new(0, -2, currentHue, -2)
                    UpdateColor()
                end
            end)
            
            HueSlider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = input.Position
                    local size = HueSlider.AbsoluteSize
                    local relPos = HueSlider.AbsolutePosition
                    
                    currentHue = math.clamp((pos.Y - relPos.Y) / size.Y, 0, 1)
                    HueCursor.Position = UDim2.new(0, -2, currentHue, -2)
                    UpdateColor()
                end
            end)
            
            -- Alpha Slider dragging
            if options.Alpha and AlphaSlider then
                local draggingAlpha = false
                AlphaSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingAlpha = true
                        local pos = input.Position
                        local size = AlphaSlider.AbsoluteSize
                        local relPos = AlphaSlider.AbsolutePosition
                        
                        currentAlpha = 1 - math.clamp((pos.Y - relPos.Y) / size.Y, 0, 1)
                        AlphaCursor.Position = UDim2.new(0, -2, 1 - currentAlpha, -2)
                        UpdateColor()
                    end
                end)
                
                AlphaSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingAlpha = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if draggingAlpha and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = input.Position
                        local size = AlphaSlider.AbsoluteSize
                        local relPos = AlphaSlider.AbsolutePosition
                        
                        currentAlpha = 1 - math.clamp((pos.Y - relPos.Y) / size.Y, 0, 1)
                        AlphaCursor.Position = UDim2.new(0, -2, 1 - currentAlpha, -2)
                        UpdateColor()
                    end
                end)
            end
            
            -- Hex input handling
            HexBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    local color = HexToColor(HexBox.Text)
                    currentColor = color
                    currentHue, currentSat, currentVal = RGBtoHSV(color)
                    
                    SVCursor.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
                    HueCursor.Position = UDim2.new(0, -2, currentHue, -2)
                    
                    UpdateColor()
                end
            end)
            
            -- Toggle picker
            ColorDetector.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    ColorPickerPopup.Visible = true
                    local height = options.Alpha and 300 or 270
                    CreateTween(ColorPickerPopup, {Size = UDim2.new(0, options.Alpha and 280 or 250, 0, height)}, 0.3)
                else
                    CreateTween(ColorPickerPopup, {Size = UDim2.new(0, options.Alpha and 280 or 250, 0, 0)}, 0.3)
                    task.wait(0.3)
                    ColorPickerPopup.Visible = false
                end
            end)
            
            ColorDetector.MouseEnter:Connect(function()
                CreateTween(ColorDisplay, {Size = UDim2.new(0, 65, 0, 25)}, 0.2)
            end)
            
            ColorDetector.MouseLeave:Connect(function()
                CreateTween(ColorDisplay, {Size = UDim2.new(0, 60, 0, 25)}, 0.2)
            end)
            
            return {
                SetValue = function(self, color, alpha)
                    currentColor = color
                    currentHue, currentSat, currentVal = RGBtoHSV(color)
                    if alpha then currentAlpha = alpha end
                    
                    ColorDisplay.BackgroundColor3 = color
                    SVCursor.Position = UDim2.new(currentSat, -4, 1 - currentVal, -4)
                    HueCursor.Position = UDim2.new(0, -2, currentHue, -2)
                    if options.Alpha and AlphaCursor then
                        AlphaCursor.Position = UDim2.new(0, -2, 1 - currentAlpha, -2)
                    end
                    UpdateColor()
                end
            }
        end
        
        return Tab
    end
    
    return Window
end

return Rift
