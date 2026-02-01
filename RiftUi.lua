--[[
    ██████╗ ██╗███████╗████████╗    ██╗   ██╗██╗
    ██╔══██╗██║██╔════╝╚══██╔══╝    ██║   ██║██║
    ██████╔╝██║█████╗     ██║       ██║   ██║██║
    ██╔══██╗██║██╔══╝     ██║       ██║   ██║██║
    ██║  ██║██║██║        ██║       ╚██████╔╝██║
    ╚═╝  ╚═╝╚═╝╚═╝        ╚═╝        ╚═════╝ ╚═╝
    
    Rift UI - Professional Glass Menu Library
    Created by Cxrter
    Version: 2.0.0
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Rift = {}

-- Theme
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Secondary = Color3.fromRGB(20, 20, 20),
    Tertiary = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(220, 50, 50),
    AccentDark = Color3.fromRGB(180, 40, 40),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(40, 40, 40),
}

-- Utility Functions
local function Tween(obj, props, time)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main Library
function Rift:CreateWindow(config)
    config = config or {}
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Settings = {},
        Minimized = false,
        Visible = true
    }
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RiftUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if RunService:IsStudio() then
        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        pcall(function()
            ScreenGui.Parent = CoreGui
        end)
        if not ScreenGui.Parent then
            ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.BackgroundTransparency = 0.1
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.5
    MainStroke.Parent = Main
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Theme.Secondary
    TopBar.BorderSizePixel = 0
    TopBar.BackgroundTransparency = 0.2
    TopBar.Parent = Main
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    TopBarCorner.Parent = TopBar
    
    -- Fix corner on bottom
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 10)
    TopBarFix.Position = UDim2.new(0, 0, 1, -10)
    TopBarFix.BackgroundColor3 = Theme.Secondary
    TopBarFix.BorderSizePixel = 0
    TopBarFix.BackgroundTransparency = 0.2
    TopBarFix.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "Rift UI"
    Title.TextColor3 = Theme.TextPrimary
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Control Buttons
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Size = UDim2.new(0, 70, 0, 25)
    ControlsFrame.Position = UDim2.new(1, -85, 0, 10)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Parent = TopBar
    
    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.Padding = UDim.new(0, 5)
    ControlsLayout.Parent = ControlsFrame
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    MinimizeBtn.BackgroundColor3 = Theme.Tertiary
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Text = "─"
    MinimizeBtn.TextColor3 = Theme.TextPrimary
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = ControlsFrame
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 5)
    MinimizeCorner.Parent = MinimizeBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.BackgroundColor3 = Theme.Accent
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextPrimary
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = ControlsFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseBtn
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "Content"
    ContentContainer.Size = UDim2.new(1, 0, 1, -45)
    ContentContainer.Position = UDim2.new(0, 0, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Main
    
    -- Tab Buttons Container
    local TabButtons = Instance.new("ScrollingFrame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(0, 140, 1, -10)
    TabButtons.Position = UDim2.new(0, 5, 0, 5)
    TabButtons.BackgroundTransparency = 1
    TabButtons.BorderSizePixel = 0
    TabButtons.ScrollBarThickness = 0
    TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtons.Parent = ContentContainer
    
    local TabButtonsList = Instance.new("UIListLayout")
    TabButtonsList.Padding = UDim.new(0, 5)
    TabButtonsList.Parent = TabButtons
    
    TabButtonsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabButtons.CanvasSize = UDim2.new(0, 0, 0, TabButtonsList.AbsoluteContentSize.Y)
    end)
    
    -- Tab Content Container
    local TabContent = Instance.new("Frame")
    TabContent.Name = "TabContent"
    TabContent.Size = UDim2.new(1, -155, 1, -10)
    TabContent.Position = UDim2.new(0, 150, 0, 5)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = ContentContainer
    
    -- Button Hover Effects
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
    end)
    
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.Tertiary}, 0.15)
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.AccentDark}, 0.15)
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
    end)
    
    -- Minimize Functionality
    MinimizeBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        
        if Window.Minimized then
            Tween(Main, {Size = UDim2.new(0, 550, 0, 45)}, 0.3)
            MinimizeBtn.Text = "□"
        else
            Tween(Main, {Size = UDim2.new(0, 550, 0, 400)}, 0.3)
            MinimizeBtn.Text = "─"
        end
    end)
    
    -- Close Functionality
    CloseBtn.MouseButton1Click:Connect(function()
        Window.Visible = false
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        ScreenGui.Enabled = false
    end)
    
    -- Make Draggable
    MakeDraggable(Main, TopBar)
    
    -- Window Methods
    function Window:Toggle()
        Window.Visible = not Window.Visible
        ScreenGui.Enabled = Window.Visible
        
        if Window.Visible then
            Main.Size = UDim2.new(0, 0, 0, 0)
            Tween(Main, {Size = Window.Minimized and UDim2.new(0, 550, 0, 45) or UDim2.new(0, 550, 0, 400)}, 0.3)
        end
    end
    
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Elements = {}
        }
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Theme.Secondary
        TabBtn.BackgroundTransparency = 0.3
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Theme.TextSecondary
        TabBtn.TextSize = 13
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = TabButtons
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn
        
        -- Tab Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.Parent = TabContent
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 6)
        PageList.Parent = Page
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab Button Click
        TabBtn.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundTransparency = 0.3
                tab.Button.TextColor3 = Theme.TextSecondary
                tab.Page.Visible = false
            end
            
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Theme.TextPrimary
            TabBtn.BackgroundColor3 = Theme.Accent
            Page.Visible = true
            Window.CurrentTab = Tab
        end)
        
        -- Hover Effect
        TabBtn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.1}, 0.15)
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.3}, 0.15)
            end
        end)
        
        Tab.Button = TabBtn
        Tab.Page = Page
        
        -- Tab Methods
        function Tab:AddButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 35)
            Button.BackgroundColor3 = Theme.Accent
            Button.BackgroundTransparency = 0.1
            Button.BorderSizePixel = 0
            Button.Text = text
            Button.TextColor3 = Theme.TextPrimary
            Button.TextSize = 13
            Button.Font = Enum.Font.Gotham
            Button.Parent = Page
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundTransparency = 0}, 0.15)
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundTransparency = 0.1}, 0.15)
            end)
            
            Button.MouseButton1Click:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                wait(0.1)
                Tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)
                if callback then callback() end
            end)
            
            return Button
        end
        
        function Tab:AddToggle(text, default, callback)
            local toggled = default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.BackgroundColor3 = Theme.Secondary
            ToggleFrame.BackgroundTransparency = 0.2
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = Page
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.TextPrimary
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -48, 0.5, -10)
            ToggleButton.BackgroundColor3 = toggled and Theme.Accent or Theme.Tertiary
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
            ToggleBtnCorner.Parent = ToggleButton
            
            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Theme.TextPrimary
            Circle.BorderSizePixel = 0
            Circle.Parent = ToggleButton
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = Circle
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                Tween(ToggleButton, {BackgroundColor3 = toggled and Theme.Accent or Theme.Tertiary}, 0.2)
                Tween(Circle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                
                if callback then callback(toggled) end
            end)
            
            return {
                SetValue = function(value)
                    toggled = value
                    ToggleButton.BackgroundColor3 = toggled and Theme.Accent or Theme.Tertiary
                    Circle.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                end,
                GetValue = function() return toggled end
            }
        end
        
        function Tab:AddSlider(text, min, max, default, callback)
            local value = default or min
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)
            SliderFrame.BackgroundColor3 = Theme.Secondary
            SliderFrame.BackgroundTransparency = 0.2
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = Page
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.TextPrimary
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -62, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(value)
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.TextSize = 13
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local SliderBack = Instance.new("Frame")
            SliderBack.Size = UDim2.new(1, -24, 0, 4)
            SliderBack.Position = UDim2.new(0, 12, 1, -15)
            SliderBack.BackgroundColor3 = Theme.Tertiary
            SliderBack.BorderSizePixel = 0
            SliderBack.Parent = SliderFrame
            
            local SliderBackCorner = Instance.new("UICorner")
            SliderBackCorner.CornerRadius = UDim.new(1, 0)
            SliderBackCorner.Parent = SliderBack
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBack
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill
            
            local dragging = false
            
            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    
                    local function update()
                        local mouse = UserInputService:GetMouseLocation()
                        local percent = math.clamp((mouse.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + (max - min) * percent)
                        
                        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        ValueLabel.Text = tostring(value)
                        
                        if callback then callback(value) end
                    end
                    
                    update()
                    
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                            update()
                        end
                    end)
                    
                    local release
                    release = UserInputService.InputEnded:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                            connection:Disconnect()
                            release:Disconnect()
                        end
                    end)
                end
            end)
            
            return {
                SetValue = function(val)
                    value = math.clamp(val, min, max)
                    local percent = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                end,
                GetValue = function() return value end
            }
        end
        
        function Tab:AddDropdown(text, options, default, callback)
            local selected = default or options[1]
            local open = false
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
            DropdownFrame.BackgroundColor3 = Theme.Secondary
            DropdownFrame.BackgroundTransparency = 0.2
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = Page
            DropdownFrame.ClipsDescendants = false
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, -12, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.TextPrimary
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            
            local DropdownBtn = Instance.new("TextButton")
            DropdownBtn.Size = UDim2.new(0.5, -16, 0, 28)
            DropdownBtn.Position = UDim2.new(0.5, 4, 0, 3.5)
            DropdownBtn.BackgroundColor3 = Theme.Tertiary
            DropdownBtn.BorderSizePixel = 0
            DropdownBtn.Text = selected
            DropdownBtn.TextColor3 = Theme.TextPrimary
            DropdownBtn.TextSize = 12
            DropdownBtn.Font = Enum.Font.Gotham
            DropdownBtn.Parent = DropdownFrame
            
            local DropdownBtnCorner = Instance.new("UICorner")
            DropdownBtnCorner.CornerRadius = UDim.new(0, 5)
            DropdownBtnCorner.Parent = DropdownBtn
            
            local OptionsList = Instance.new("Frame")
            OptionsList.Size = UDim2.new(0.5, -16, 0, 0)
            OptionsList.Position = UDim2.new(0.5, 4, 1, 5)
            OptionsList.BackgroundColor3 = Theme.Secondary
            OptionsList.BorderSizePixel = 0
            OptionsList.ClipsDescendants = true
            OptionsList.Visible = false
            OptionsList.ZIndex = 10
            OptionsList.Parent = DropdownFrame
            
            local OptionsCorner = Instance.new("UICorner")
            OptionsCorner.CornerRadius = UDim.new(0, 5)
            OptionsCorner.Parent = OptionsList
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Padding = UDim.new(0, 2)
            OptionsLayout.Parent = OptionsList
            
            for _, option in ipairs(options) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Size = UDim2.new(1, -4, 0, 25)
                OptionBtn.Position = UDim2.new(0, 2, 0, 0)
                OptionBtn.BackgroundColor3 = Theme.Tertiary
                OptionBtn.BackgroundTransparency = 0.5
                OptionBtn.BorderSizePixel = 0
                OptionBtn.Text = option
                OptionBtn.TextColor3 = Theme.TextPrimary
                OptionBtn.TextSize = 11
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.Parent = OptionsList
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionBtn
                
                OptionBtn.MouseEnter:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
                end)
                
                OptionBtn.MouseLeave:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = Theme.Tertiary}, 0.15)
                end)
                
                OptionBtn.MouseButton1Click:Connect(function()
                    selected = option
                    DropdownBtn.Text = option
                    open = false
                    Tween(OptionsList, {Size = UDim2.new(0.5, -16, 0, 0)}, 0.2)
                    task.wait(0.2)
                    OptionsList.Visible = false
                    if callback then callback(option) end
                end)
            end
            
            DropdownBtn.MouseButton1Click:Connect(function()
                open = not open
                
                if open then
                    local height = math.min(#options * 27, 150)
                    OptionsList.Visible = true
                    Tween(OptionsList, {Size = UDim2.new(0.5, -16, 0, height)}, 0.2)
                else
                    Tween(OptionsList, {Size = UDim2.new(0.5, -16, 0, 0)}, 0.2)
                    task.wait(0.2)
                    OptionsList.Visible = false
                end
            end)
        end
        
        function Tab:AddTextbox(text, placeholder, callback)
            local TextboxFrame = Instance.new("Frame")
            TextboxFrame.Size = UDim2.new(1, -10, 0, 50)
            TextboxFrame.BackgroundColor3 = Theme.Secondary
            TextboxFrame.BackgroundTransparency = 0.2
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.Parent = Page
            
            local TextboxCorner = Instance.new("UICorner")
            TextboxCorner.CornerRadius = UDim.new(0, 6)
            TextboxCorner.Parent = TextboxFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.TextPrimary
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TextboxFrame
            
            local Textbox = Instance.new("TextBox")
            Textbox.Size = UDim2.new(1, -24, 0, 22)
            Textbox.Position = UDim2.new(0, 12, 1, -27)
            Textbox.BackgroundColor3 = Theme.Tertiary
            Textbox.BorderSizePixel = 0
            Textbox.Text = ""
            Textbox.PlaceholderText = placeholder or "Enter text..."
            Textbox.TextColor3 = Theme.TextPrimary
            Textbox.PlaceholderColor3 = Theme.TextSecondary
            Textbox.TextSize = 12
            Textbox.Font = Enum.Font.Gotham
            Textbox.ClearTextOnFocus = false
            Textbox.Parent = TextboxFrame
            
            local TextboxCorner2 = Instance.new("UICorner")
            TextboxCorner2.CornerRadius = UDim.new(0, 4)
            TextboxCorner2.Parent = Textbox
            
            local TextboxPadding = Instance.new("UIPadding")
            TextboxPadding.PaddingLeft = UDim.new(0, 8)
            TextboxPadding.PaddingRight = UDim.new(0, 8)
            TextboxPadding.Parent = Textbox
            
            Textbox.FocusLost:Connect(function()
                if callback then callback(Textbox.Text) end
            end)
            
            return {
                SetValue = function(val) Textbox.Text = val end,
                GetValue = function() return Textbox.Text end
            }
        end
        
        function Tab:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 25)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.TextSecondary
            Label.TextSize = 12
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = Page
            
            return {
                SetText = function(txt) Label.Text = txt end
            }
        end
        
        function Tab:AddDivider()
            local Divider = Instance.new("Frame")
            Divider.Size = UDim2.new(1, -20, 0, 1)
            Divider.BackgroundColor3 = Theme.Border
            Divider.BorderSizePixel = 0
            Divider.Parent = Page
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            TabBtn.MouseButton1Click:Fire()
        end
        
        return Tab
    end
    
    function Window:Notify(title, text, duration)
        duration = duration or 3
        
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(0, 0, 0, 0)
        Notification.Position = UDim2.new(1, -10, 1, -10)
        Notification.AnchorPoint = Vector2.new(1, 1)
        Notification.BackgroundColor3 = Theme.Secondary
        Notification.BackgroundTransparency = 0.1
        Notification.BorderSizePixel = 0
        Notification.Parent = ScreenGui
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = Notification
        
        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = Theme.Accent
        NotifStroke.Thickness = 1
        NotifStroke.Transparency = 0.5
        NotifStroke.Parent = Notification
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Size = UDim2.new(1, -20, 0, 20)
        NotifTitle.Position = UDim2.new(0, 10, 0, 8)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = title
        NotifTitle.TextColor3 = Theme.TextPrimary
        NotifTitle.TextSize = 14
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.Parent = Notification
        
        local NotifText = Instance.new("TextLabel")
        NotifText.Size = UDim2.new(1, -20, 1, -30)
        NotifText.Position = UDim2.new(0, 10, 0, 25)
        NotifText.BackgroundTransparency = 1
        NotifText.Text = text
        NotifText.TextColor3 = Theme.TextSecondary
        NotifText.TextSize = 12
        NotifText.Font = Enum.Font.Gotham
        NotifText.TextXAlignment = Enum.TextXAlignment.Left
        NotifText.TextYAlignment = Enum.TextYAlignment.Top
        NotifText.TextWrapped = true
        NotifText.Parent = Notification
        
        local textSize = game:GetService("TextService"):GetTextSize(
            text, 12, Enum.Font.Gotham, Vector2.new(270, math.huge)
        )
        
        local height = math.max(60, textSize.Y + 40)
        
        Tween(Notification, {
            Size = UDim2.new(0, 280, 0, height),
            Position = UDim2.new(1, -10, 1, -height - 10)
        }, 0.3)
        
        task.delay(duration, function()
            Tween(Notification, {
                Position = UDim2.new(1, -10, 1, -10),
                Size = UDim2.new(0, 0, 0, 0)
            }, 0.3)
            task.wait(0.3)
            Notification:Destroy()
        end)
    end
    
    function Window:SaveSettings()
        local success = pcall(function()
            writefile(config.SettingsFile or "RiftSettings.json", HttpService:JSONEncode(Window.Settings))
        end)
        return success
    end
    
    function Window:LoadSettings()
        local success, data = pcall(function()
            if isfile and isfile(config.SettingsFile or "RiftSettings.json") then
                return HttpService:JSONDecode(readfile(config.SettingsFile or "RiftSettings.json"))
            end
        end)
        
        if success and data then
            Window.Settings = data
        end
    end
    
    return Window
end

return Rift
