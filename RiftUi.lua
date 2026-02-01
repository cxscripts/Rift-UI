--[[
    ██████╗ ██╗███████╗████████╗    ██╗   ██╗██╗
    ██╔══██╗██║██╔════╝╚══██╔══╝    ██║   ██║██║
    ██████╔╝██║█████╗     ██║       ██║   ██║██║
    ██╔══██╗██║██╔══╝     ██║       ██║   ██║██║
    ██║  ██║██║██║        ██║       ╚██████╔╝██║
    ╚═╝  ╚═╝╚═╝╚═╝        ╚═╝        ╚═════╝ ╚═╝
    
    Rift UI - Modern Glass Executor Interface
    Features: Glass/Blur effects, Full customization, Settings saving, All components
    Version: 1.0.0
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Rift = {}
Rift.__index = Rift

-- Default Theme (Fully Customizable)
local DefaultTheme = {
    -- Main Colors
    Primary = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(138, 43, 226), -- Purple accent
    AccentHover = Color3.fromRGB(158, 63, 246),
    AccentActive = Color3.fromRGB(118, 23, 206),
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TextDisabled = Color3.fromRGB(100, 100, 110),
    
    -- UI Colors
    Border = Color3.fromRGB(60, 60, 75),
    Divider = Color3.fromRGB(40, 40, 50),
    Success = Color3.fromRGB(75, 210, 143),
    Warning = Color3.fromRGB(255, 195, 88),
    Error = Color3.fromRGB(255, 89, 94),
    Info = Color3.fromRGB(88, 166, 255),
    
    -- Glass Effect Settings
    GlassTransparency = 0.3,
    BlurIntensity = 20,
    BorderTransparency = 0.4,
    
    -- Animation Settings
    AnimationSpeed = 0.25,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
    
    -- Component Settings
    CornerRadius = UDim.new(0, 8),
    Padding = 10,
    Spacing = 8,
    
    -- Font Settings
    Font = Enum.Font.GothamMedium,
    TitleFont = Enum.Font.GothamBold,
    CodeFont = Enum.Font.Code,
}

-- Utility Functions
local Utils = {}

function Utils:Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or DefaultTheme.AnimationSpeed,
        style or DefaultTheme.EasingStyle,
        direction or DefaultTheme.EasingDirection
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils:CreateElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        if property == "Parent" then
            -- Set parent last to avoid unnecessary renders
            continue
        end
        element[property] = value
    end
    if properties.Parent then
        element.Parent = properties.Parent
    end
    return element
end

function Utils:ApplyGlassEffect(frame, transparency)
    transparency = transparency or DefaultTheme.GlassTransparency
    
    frame.BackgroundTransparency = transparency
    
    local uiCorner = Utils:CreateElement("UICorner", {
        CornerRadius = DefaultTheme.CornerRadius,
        Parent = frame
    })
    
    local uiStroke = Utils:CreateElement("UIStroke", {
        Color = DefaultTheme.Border,
        Transparency = DefaultTheme.BorderTransparency,
        Thickness = 1,
        Parent = frame
    })
    
    return uiCorner, uiStroke
end

function Utils:MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Utils:Tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

function Utils:AddBlur(intensity)
    intensity = intensity or DefaultTheme.BlurIntensity
    
    local blur = Instance.new("BlurEffect")
    blur.Size = intensity
    blur.Parent = game:GetService("Lighting")
    
    return blur
end

function Utils:SaveSettings(fileName, data)
    local success, result = pcall(function()
        writefile(fileName, HttpService:JSONEncode(data))
    end)
    return success
end

function Utils:LoadSettings(fileName)
    local success, result = pcall(function()
        if isfile(fileName) then
            return HttpService:JSONDecode(readfile(fileName))
        end
        return nil
    end)
    return success and result or nil
end

-- Main Library Functions
function Rift:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Theme = config.Theme or DefaultTheme,
        Blur = nil,
        Minimized = false,
        Settings = {},
        SettingsFile = config.SettingsFile or "RiftUI_Settings.json"
    }
    
    -- Create ScreenGui
    local screenGui = Utils:CreateElement("ScreenGui", {
        Name = "RiftUI",
        Parent = RunService:IsStudio() and game.Players.LocalPlayer.PlayerGui or CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    -- Add Blur Effect
    if config.Blur ~= false then
        Window.Blur = Utils:AddBlur(config.BlurIntensity)
    end
    
    -- Main Container
    local mainFrame = Utils:CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, config.Width or 600, 0, config.Height or 400),
        Position = UDim2.new(0.5, -((config.Width or 600) / 2), 0.5, -((config.Height or 400) / 2)),
        BackgroundColor3 = Window.Theme.Primary,
        BorderSizePixel = 0,
        Parent = screenGui
    })
    
    Utils:ApplyGlassEffect(mainFrame)
    
    -- Title Bar
    local titleBar = Utils:CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Window.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    Utils:ApplyGlassEffect(titleBar, 0.2)
    
    -- Title Text
    local titleLabel = Utils:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Rift UI",
        TextColor3 = Window.Theme.TextPrimary,
        TextSize = 16,
        Font = Window.Theme.TitleFont,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Control Buttons Container
    local controlsContainer = Utils:CreateElement("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 80, 0, 30),
        Position = UDim2.new(1, -90, 0, 5),
        BackgroundTransparency = 1,
        Parent = titleBar
    })
    
    -- Minimize Button
    local minimizeBtn = Utils:CreateElement("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Window.Theme.Secondary,
        BorderSizePixel = 0,
        Text = "─",
        TextColor3 = Window.Theme.TextPrimary,
        TextSize = 14,
        Font = Window.Theme.Font,
        Parent = controlsContainer
    })
    
    Utils:ApplyGlassEffect(minimizeBtn, 0.5)
    
    -- Close Button
    local closeBtn = Utils:CreateElement("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundColor3 = Window.Theme.Error,
        BorderSizePixel = 0,
        Text = "✕",
        TextColor3 = Window.Theme.TextPrimary,
        TextSize = 14,
        Font = Window.Theme.Font,
        Parent = controlsContainer
    })
    
    Utils:ApplyGlassEffect(closeBtn, 0.5)
    
    -- Tab Container
    local tabContainer = Utils:CreateElement("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })
    
    local tabList = Utils:CreateElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Window.Theme.Spacing),
        Parent = tabContainer
    })
    
    -- Content Container
    local contentContainer = Utils:CreateElement("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -180, 1, -60),
        Position = UDim2.new(0, 170, 0, 50),
        BackgroundColor3 = Window.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    Utils:ApplyGlassEffect(contentContainer, 0.2)
    
    -- Make window draggable
    Utils:MakeDraggable(mainFrame, titleBar)
    
    -- Button Interactions
    minimizeBtn.MouseEnter:Connect(function()
        Utils:Tween(minimizeBtn, {BackgroundColor3 = Window.Theme.Accent}, 0.15)
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        Utils:Tween(minimizeBtn, {BackgroundColor3 = Window.Theme.Secondary}, 0.15)
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        
        if Window.Minimized then
            Utils:Tween(mainFrame, {
                Size = UDim2.new(0, config.Width or 600, 0, 40)
            }, 0.3)
            minimizeBtn.Text = "□"
        else
            Utils:Tween(mainFrame, {
                Size = UDim2.new(0, config.Width or 600, 0, config.Height or 400)
            }, 0.3)
            minimizeBtn.Text = "─"
        end
    end)
    
    closeBtn.MouseEnter:Connect(function()
        Utils:Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.15)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Utils:Tween(closeBtn, {BackgroundColor3 = Window.Theme.Error}, 0.15)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Utils:Tween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        
        task.wait(0.3)
        screenGui:Destroy()
        if Window.Blur then
            Window.Blur:Destroy()
        end
    end)
    
    -- Window Methods
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Elements = {},
            Container = nil,
            Button = nil
        }
        
        -- Tab Button
        local tabBtn = Utils:CreateElement("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Window.Theme.Secondary,
            BorderSizePixel = 0,
            Text = tabName,
            TextColor3 = Window.Theme.TextSecondary,
            TextSize = 14,
            Font = Window.Theme.Font,
            Parent = tabContainer
        })
        
        Utils:ApplyGlassEffect(tabBtn, 0.4)
        
        Tab.Button = tabBtn
        
        -- Tab Content
        local tabContent = Utils:CreateElement("ScrollingFrame", {
            Name = tabName .. "_Content",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Window.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = contentContainer
        })
        
        local contentList = Utils:CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, Window.Theme.Spacing),
            Parent = tabContent
        })
        
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
        end)
        
        Tab.Container = tabContent
        
        -- Tab Button Click
        tabBtn.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Container.Visible = false
                Utils:Tween(tab.Button, {
                    BackgroundColor3 = Window.Theme.Secondary,
                    TextColor3 = Window.Theme.TextSecondary
                }, 0.2)
            end
            
            tabContent.Visible = true
            Utils:Tween(tabBtn, {
                BackgroundColor3 = Window.Theme.Accent,
                TextColor3 = Window.Theme.TextPrimary
            }, 0.2)
            
            Window.CurrentTab = Tab
        end)
        
        -- Tab Button Hover
        tabBtn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Tween(tabBtn, {BackgroundColor3 = Window.Theme.AccentHover}, 0.15)
            end
        end)
        
        tabBtn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utils:Tween(tabBtn, {BackgroundColor3 = Window.Theme.Secondary}, 0.15)
            end
        end)
        
        -- Tab Component Methods
        function Tab:AddButton(config)
            config = config or {}
            
            local buttonFrame = Utils:CreateElement("Frame", {
                Name = "Button",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Parent = tabContent
            })
            
            local button = Utils:CreateElement("TextButton", {
                Name = config.Name or "Button",
                Size = UDim2.new(1, -10, 1, 0),
                BackgroundColor3 = Window.Theme.Accent,
                BorderSizePixel = 0,
                Text = config.Text or "Button",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 14,
                Font = Window.Theme.Font,
                Parent = buttonFrame
            })
            
            Utils:ApplyGlassEffect(button, 0.3)
            
            button.MouseEnter:Connect(function()
                Utils:Tween(button, {BackgroundColor3 = Window.Theme.AccentHover}, 0.15)
            end)
            
            button.MouseLeave:Connect(function()
                Utils:Tween(button, {BackgroundColor3 = Window.Theme.Accent}, 0.15)
            end)
            
            button.MouseButton1Click:Connect(function()
                Utils:Tween(button, {BackgroundColor3 = Window.Theme.AccentActive}, 0.1)
                task.wait(0.1)
                Utils:Tween(button, {BackgroundColor3 = Window.Theme.AccentHover}, 0.1)
                
                if config.Callback then
                    config.Callback()
                end
            end)
            
            table.insert(Tab.Elements, {Type = "Button", Object = button})
            return button
        end
        
        function Tab:AddToggle(config)
            config = config or {}
            
            local toggleFrame = Utils:CreateElement("Frame", {
                Name = "Toggle",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = tabContent
            })
            
            Utils:ApplyGlassEffect(toggleFrame, 0.4)
            
            local toggleLabel = Utils:CreateElement("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Toggle",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 14,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })
            
            local toggleButton = Utils:CreateElement("TextButton", {
                Name = "ToggleButton",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = Window.Theme.Divider,
                BorderSizePixel = 0,
                Text = "",
                Parent = toggleFrame
            })
            
            local toggleCorner = Utils:CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleButton
            })
            
            local toggleIndicator = Utils:CreateElement("Frame", {
                Name = "Indicator",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Window.Theme.TextPrimary,
                BorderSizePixel = 0,
                Parent = toggleButton
            })
            
            local indicatorCorner = Utils:CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleIndicator
            })
            
            local toggled = config.Default or false
            
            local function updateToggle(state)
                toggled = state
                
                if toggled then
                    Utils:Tween(toggleButton, {BackgroundColor3 = Window.Theme.Success}, 0.2)
                    Utils:Tween(toggleIndicator, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                else
                    Utils:Tween(toggleButton, {BackgroundColor3 = Window.Theme.Divider}, 0.2)
                    Utils:Tween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                end
                
                if config.Callback then
                    config.Callback(toggled)
                end
                
                Window.Settings[config.Flag or config.Text] = toggled
            end
            
            updateToggle(toggled)
            
            toggleButton.MouseButton1Click:Connect(function()
                updateToggle(not toggled)
            end)
            
            table.insert(Tab.Elements, {Type = "Toggle", Object = toggleFrame, Update = updateToggle})
            
            return {
                SetValue = updateToggle,
                GetValue = function() return toggled end
            }
        end
        
        function Tab:AddSlider(config)
            config = config or {}
            
            local sliderFrame = Utils:CreateElement("Frame", {
                Name = "Slider",
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = tabContent
            })
            
            Utils:ApplyGlassEffect(sliderFrame, 0.4)
            
            local sliderLabel = Utils:CreateElement("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = config.Text or "Slider",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 14,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame
            })
            
            local valueLabel = Utils:CreateElement("TextLabel", {
                Name = "Value",
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -60, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(config.Default or config.Min or 0),
                TextColor3 = Window.Theme.Accent,
                TextSize = 14,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame
            })
            
            local sliderTrack = Utils:CreateElement("Frame", {
                Name = "Track",
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0, 35),
                BackgroundColor3 = Window.Theme.Divider,
                BorderSizePixel = 0,
                Parent = sliderFrame
            })
            
            local trackCorner = Utils:CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderTrack
            })
            
            local sliderFill = Utils:CreateElement("Frame", {
                Name = "Fill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Window.Theme.Accent,
                BorderSizePixel = 0,
                Parent = sliderTrack
            })
            
            local fillCorner = Utils:CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            local sliderHandle = Utils:CreateElement("Frame", {
                Name = "Handle",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, -8, 0.5, -8),
                BackgroundColor3 = Window.Theme.TextPrimary,
                BorderSizePixel = 0,
                Parent = sliderTrack
            })
            
            local handleCorner = Utils:CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderHandle
            })
            
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local increment = config.Increment or 1
            local value = default
            
            local dragging = false
            
            local function updateSlider(val)
                value = math.clamp(val, min, max)
                value = math.floor(value / increment + 0.5) * increment
                
                local percent = (value - min) / (max - min)
                
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderHandle.Position = UDim2.new(percent, -8, 0.5, -8)
                valueLabel.Text = tostring(value)
                
                if config.Callback then
                    config.Callback(value)
                end
                
                Window.Settings[config.Flag or config.Text] = value
            end
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    
                    local function update()
                        local mousePos = UserInputService:GetMouseLocation().X
                        local trackPos = sliderTrack.AbsolutePosition.X
                        local trackSize = sliderTrack.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                        local newValue = min + (max - min) * percent
                        
                        updateSlider(newValue)
                    end
                    
                    update()
                    
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                            update()
                        end
                    end)
                    
                    local endConnection
                    endConnection = UserInputService.InputEnded:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                            connection:Disconnect()
                            endConnection:Disconnect()
                        end
                    end)
                end
            end)
            
            updateSlider(value)
            
            table.insert(Tab.Elements, {Type = "Slider", Object = sliderFrame, Update = updateSlider})
            
            return {
                SetValue = updateSlider,
                GetValue = function() return value end
            }
        end
        
        function Tab:AddDropdown(config)
            config = config or {}
            
            local dropdownFrame = Utils:CreateElement("Frame", {
                Name = "Dropdown",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = tabContent
            })
            
            Utils:ApplyGlassEffect(dropdownFrame, 0.4)
            
            local dropdownLabel = Utils:CreateElement("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0.5, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Dropdown",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 14,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })
            
            local dropdownButton = Utils:CreateElement("TextButton", {
                Name = "Button",
                Size = UDim2.new(0.5, -20, 0, 30),
                Position = UDim2.new(0.5, 10, 0, 5),
                BackgroundColor3 = Window.Theme.Divider,
                BorderSizePixel = 0,
                Text = config.Default or (config.Options and config.Options[1]) or "Select",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 13,
                Font = Window.Theme.Font,
                Parent = dropdownFrame
            })
            
            Utils:ApplyGlassEffect(dropdownButton, 0.3)
            
            local dropdownIcon = Utils:CreateElement("TextLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -25, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Window.Theme.TextSecondary,
                TextSize = 10,
                Font = Window.Theme.Font,
                Parent = dropdownButton
            })
            
            local dropdownList = Utils:CreateElement("ScrollingFrame", {
                Name = "List",
                Size = UDim2.new(0.5, -20, 0, 0),
                Position = UDim2.new(0.5, 10, 1, 5),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Window.Theme.Accent,
                Visible = false,
                ZIndex = 10,
                Parent = dropdownFrame
            })
            
            Utils:ApplyGlassEffect(dropdownList, 0.2)
            
            local listLayout = Utils:CreateElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = dropdownList
            })
            
            local selected = config.Default or (config.Options and config.Options[1])
            local open = false
            
            local function updateOptions()
                dropdownList:ClearAllChildren()
                
                local listLayout = Utils:CreateElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = dropdownList
                })
                
                for _, option in ipairs(config.Options or {}) do
                    local optionBtn = Utils:CreateElement("TextButton", {
                        Name = option,
                        Size = UDim2.new(1, -10, 0, 30),
                        BackgroundColor3 = Window.Theme.Divider,
                        BorderSizePixel = 0,
                        Text = option,
                        TextColor3 = Window.Theme.TextPrimary,
                        TextSize = 13,
                        Font = Window.Theme.Font,
                        Parent = dropdownList
                    })
                    
                    Utils:ApplyGlassEffect(optionBtn, 0.5)
                    
                    optionBtn.MouseEnter:Connect(function()
                        Utils:Tween(optionBtn, {BackgroundColor3 = Window.Theme.Accent}, 0.15)
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        Utils:Tween(optionBtn, {BackgroundColor3 = Window.Theme.Divider}, 0.15)
                    end)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        dropdownButton.Text = option
                        
                        Utils:Tween(dropdownList, {Size = UDim2.new(0.5, -20, 0, 0)}, 0.2)
                        task.wait(0.2)
                        dropdownList.Visible = false
                        open = false
                        
                        Utils:Tween(dropdownIcon, {Rotation = 0}, 0.2)
                        
                        if config.Callback then
                            config.Callback(option)
                        end
                        
                        Window.Settings[config.Flag or config.Text] = option
                    end)
                end
                
                local contentSize = listLayout.AbsoluteContentSize.Y
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, contentSize)
            end
            
            updateOptions()
            
            dropdownButton.MouseButton1Click:Connect(function()
                open = not open
                
                if open then
                    local maxHeight = 150
                    local contentHeight = math.min(listLayout.AbsoluteContentSize.Y + 10, maxHeight)
                    
                    dropdownList.Visible = true
                    Utils:Tween(dropdownList, {Size = UDim2.new(0.5, -20, 0, contentHeight)}, 0.2)
                    Utils:Tween(dropdownIcon, {Rotation = 180}, 0.2)
                else
                    Utils:Tween(dropdownList, {Size = UDim2.new(0.5, -20, 0, 0)}, 0.2)
                    Utils:Tween(dropdownIcon, {Rotation = 0}, 0.2)
                    task.wait(0.2)
                    dropdownList.Visible = false
                end
            end)
            
            table.insert(Tab.Elements, {Type = "Dropdown", Object = dropdownFrame, Update = updateOptions})
            
            return {
                SetValue = function(val)
                    selected = val
                    dropdownButton.Text = val
                end,
                GetValue = function() return selected end,
                UpdateOptions = function(newOptions)
                    config.Options = newOptions
                    updateOptions()
                end
            }
        end
        
        function Tab:AddTextbox(config)
            config = config or {}
            
            local textboxFrame = Utils:CreateElement("Frame", {
                Name = "Textbox",
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = tabContent
            })
            
            Utils:ApplyGlassEffect(textboxFrame, 0.4)
            
            local textboxLabel = Utils:CreateElement("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = config.Text or "Textbox",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 14,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textboxFrame
            })
            
            local textbox = Utils:CreateElement("TextBox", {
                Name = "Input",
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 25),
                BackgroundColor3 = Window.Theme.Divider,
                BorderSizePixel = 0,
                Text = config.Default or "",
                PlaceholderText = config.Placeholder or "Enter text...",
                TextColor3 = Window.Theme.TextPrimary,
                PlaceholderColor3 = Window.Theme.TextDisabled,
                TextSize = 13,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = textboxFrame
            })
            
            Utils:ApplyGlassEffect(textbox, 0.3)
            
            local textboxPadding = Utils:CreateElement("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = textbox
            })
            
            textbox.FocusLost:Connect(function(enterPressed)
                if config.Callback then
                    config.Callback(textbox.Text)
                end
                
                Window.Settings[config.Flag or config.Text] = textbox.Text
            end)
            
            table.insert(Tab.Elements, {Type = "Textbox", Object = textboxFrame})
            
            return {
                SetValue = function(val)
                    textbox.Text = val
                end,
                GetValue = function() return textbox.Text end
            }
        end
        
        function Tab:AddKeybind(config)
            config = config or {}
            
            local keybindFrame = Utils:CreateElement("Frame", {
                Name = "Keybind",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = tabContent
            })
            
            Utils:ApplyGlassEffect(keybindFrame, 0.4)
            
            local keybindLabel = Utils:CreateElement("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0.6, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Keybind",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 14,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = keybindFrame
            })
            
            local keybindButton = Utils:CreateElement("TextButton", {
                Name = "Button",
                Size = UDim2.new(0.4, -20, 0, 30),
                Position = UDim2.new(0.6, 10, 0, 5),
                BackgroundColor3 = Window.Theme.Divider,
                BorderSizePixel = 0,
                Text = config.Default and config.Default.Name or "None",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 13,
                Font = Window.Theme.Font,
                Parent = keybindFrame
            })
            
            Utils:ApplyGlassEffect(keybindButton, 0.3)
            
            local currentKey = config.Default
            local listening = false
            
            keybindButton.MouseButton1Click:Connect(function()
                listening = true
                keybindButton.Text = "..."
                Utils:Tween(keybindButton, {BackgroundColor3 = Window.Theme.Accent}, 0.15)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keybindButton.Text = input.KeyCode.Name
                        listening = false
                        Utils:Tween(keybindButton, {BackgroundColor3 = Window.Theme.Divider}, 0.15)
                        
                        Window.Settings[config.Flag or config.Text] = input.KeyCode.Name
                    end
                elseif currentKey and input.KeyCode == currentKey and not gameProcessed then
                    if config.Callback then
                        config.Callback()
                    end
                end
            end)
            
            table.insert(Tab.Elements, {Type = "Keybind", Object = keybindFrame})
            
            return {
                SetValue = function(key)
                    currentKey = key
                    keybindButton.Text = key.Name
                end,
                GetValue = function() return currentKey end
            }
        end
        
        function Tab:AddColorPicker(config)
            config = config or {}
            
            local pickerFrame = Utils:CreateElement("Frame", {
                Name = "ColorPicker",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Window.Theme.Secondary,
                BorderSizePixel = 0,
                Parent = tabContent
            })
            
            Utils:ApplyGlassEffect(pickerFrame, 0.4)
            
            local pickerLabel = Utils:CreateElement("TextLabel", {
                Name = "Label",
                Size = UDim2.new(0.7, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Color Picker",
                TextColor3 = Window.Theme.TextPrimary,
                TextSize = 14,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = pickerFrame
            })
            
            local colorDisplay = Utils:CreateElement("TextButton", {
                Name = "Display",
                Size = UDim2.new(0, 60, 0, 30),
                Position = UDim2.new(1, -70, 0, 5),
                BackgroundColor3 = config.Default or Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Text = "",
                Parent = pickerFrame
            })
            
            Utils:ApplyGlassEffect(colorDisplay, 0.2)
            
            local currentColor = config.Default or Color3.fromRGB(255, 255, 255)
            
            -- Simple color picker (you can expand this with a full HSV picker)
            colorDisplay.MouseButton1Click:Connect(function()
                -- This is a simplified version - you can create a full color picker UI here
                if config.Callback then
                    config.Callback(currentColor)
                end
            end)
            
            table.insert(Tab.Elements, {Type = "ColorPicker", Object = pickerFrame})
            
            return {
                SetValue = function(color)
                    currentColor = color
                    colorDisplay.BackgroundColor3 = color
                end,
                GetValue = function() return currentColor end
            }
        end
        
        function Tab:AddLabel(text)
            local labelFrame = Utils:CreateElement("Frame", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = tabContent
            })
            
            local label = Utils:CreateElement("TextLabel", {
                Name = "Text",
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text or "Label",
                TextColor3 = Window.Theme.TextSecondary,
                TextSize = 13,
                Font = Window.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = labelFrame
            })
            
            table.insert(Tab.Elements, {Type = "Label", Object = labelFrame})
            
            return {
                SetText = function(newText)
                    label.Text = newText
                end
            }
        end
        
        function Tab:AddDivider()
            local divider = Utils:CreateElement("Frame", {
                Name = "Divider",
                Size = UDim2.new(1, -20, 0, 1),
                BackgroundColor3 = Window.Theme.Divider,
                BorderSizePixel = 0,
                Parent = tabContent
            })
            
            table.insert(Tab.Elements, {Type = "Divider", Object = divider})
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab by default
        if #Window.Tabs == 1 then
            tabBtn.MouseButton1Click:Fire()
        end
        
        return Tab
    end
    
    function Window:CreateNotification(config)
        config = config or {}
        
        local notifContainer = Utils:CreateElement("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 300, 0, 0),
            Position = UDim2.new(1, -320, 1, -20),
            BackgroundColor3 = Window.Theme.Secondary,
            BorderSizePixel = 0,
            Parent = screenGui,
            ZIndex = 100
        })
        
        Utils:ApplyGlassEffect(notifContainer, 0.2)
        
        local notifTitle = Utils:CreateElement("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = config.Title or "Notification",
            TextColor3 = Window.Theme.TextPrimary,
            TextSize = 14,
            Font = Window.Theme.TitleFont,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notifContainer
        })
        
        local notifContent = Utils:CreateElement("TextLabel", {
            Name = "Content",
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 40),
            BackgroundTransparency = 1,
            Text = config.Content or "",
            TextColor3 = Window.Theme.TextSecondary,
            TextSize = 12,
            Font = Window.Theme.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = notifContainer
        })
        
        -- Calculate content height
        local textService = game:GetService("TextService")
        local textSize = textService:GetTextSize(
            config.Content or "",
            12,
            Window.Theme.Font,
            Vector2.new(280, math.huge)
        )
        
        notifContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        
        local totalHeight = 60 + textSize.Y
        
        -- Animate in
        Utils:Tween(notifContainer, {
            Size = UDim2.new(0, 300, 0, totalHeight),
            Position = UDim2.new(1, -320, 1, -(totalHeight + 20))
        }, 0.3)
        
        -- Auto dismiss
        local duration = config.Duration or 3
        task.delay(duration, function()
            Utils:Tween(notifContainer, {
                Position = UDim2.new(1, -320, 1, -20),
                Size = UDim2.new(0, 300, 0, 0)
            }, 0.3)
            
            task.wait(0.3)
            notifContainer:Destroy()
        end)
    end
    
    function Window:SaveSettings()
        return Utils:SaveSettings(Window.SettingsFile, Window.Settings)
    end
    
    function Window:LoadSettings()
        local settings = Utils:LoadSettings(Window.SettingsFile)
        if settings then
            Window.Settings = settings
            
            -- Apply loaded settings to components
            for _, tab in pairs(Window.Tabs) do
                for _, element in pairs(tab.Elements) do
                    local flag = element.Config and element.Config.Flag
                    if flag and Window.Settings[flag] ~= nil then
                        if element.Update then
                            element.Update(Window.Settings[flag])
                        end
                    end
                end
            end
        end
    end
    
    function Window:SetTheme(newTheme)
        for key, value in pairs(newTheme) do
            Window.Theme[key] = value
        end
        
        -- Update UI colors (you can expand this to update all elements)
        mainFrame.BackgroundColor3 = Window.Theme.Primary
        titleBar.BackgroundColor3 = Window.Theme.Secondary
        contentContainer.BackgroundColor3 = Window.Theme.Secondary
    end
    
    function Window:Destroy()
        screenGui:Destroy()
        if Window.Blur then
            Window.Blur:Destroy()
        end
    end
    
    return Window
end

-- Export library
return Rift
