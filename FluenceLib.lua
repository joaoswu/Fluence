local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Themes = {
    Fluence = {
        MainBg     = Color3.fromRGB(11, 12, 16),
        BoxBg      = Color3.fromRGB(13, 14, 18),
        Border     = Color3.fromRGB(26, 28, 36),
        BorderLit  = Color3.fromRGB(38, 42, 54),
        Accent     = Color3.fromRGB(168, 255, 62),
        Muted      = Color3.fromRGB(90, 95, 110),
        BoxOff     = Color3.fromRGB(16, 17, 22),
        TextLight  = Color3.fromRGB(225, 230, 240),
        Hover      = Color3.fromRGB(22, 24, 32),
    },
    Crimson = {
        MainBg     = Color3.fromRGB(14, 11, 13),
        BoxBg      = Color3.fromRGB(16, 13, 15),
        Border     = Color3.fromRGB(36, 24, 28),
        BorderLit  = Color3.fromRGB(54, 34, 40),
        Accent     = Color3.fromRGB(255, 65, 84),
        Muted      = Color3.fromRGB(115, 95, 100),
        BoxOff     = Color3.fromRGB(22, 16, 18),
        TextLight  = Color3.fromRGB(235, 225, 230),
        Hover      = Color3.fromRGB(30, 20, 24),
    },
    Azure = {
        MainBg     = Color3.fromRGB(10, 12, 17),
        BoxBg      = Color3.fromRGB(13, 15, 22),
        Border     = Color3.fromRGB(24, 30, 44),
        BorderLit  = Color3.fromRGB(36, 46, 68),
        Accent     = Color3.fromRGB(60, 165, 255),
        Muted      = Color3.fromRGB(90, 105, 125),
        BoxOff     = Color3.fromRGB(16, 20, 28),
        TextLight  = Color3.fromRGB(220, 230, 245),
        Hover      = Color3.fromRGB(20, 26, 38),
    },
    Amethyst = {
        MainBg     = Color3.fromRGB(12, 10, 17),
        BoxBg      = Color3.fromRGB(15, 13, 22),
        Border     = Color3.fromRGB(32, 24, 44),
        BorderLit  = Color3.fromRGB(48, 36, 66),
        Accent     = Color3.fromRGB(185, 95, 255),
        Muted      = Color3.fromRGB(105, 95, 120),
        BoxOff     = Color3.fromRGB(20, 16, 28),
        TextLight  = Color3.fromRGB(230, 220, 245),
        Hover      = Color3.fromRGB(26, 20, 38),
    },
    Monochrome = {
        MainBg     = Color3.fromRGB(12, 12, 14),
        BoxBg      = Color3.fromRGB(14, 14, 16),
        Border     = Color3.fromRGB(28, 28, 32),
        BorderLit  = Color3.fromRGB(44, 44, 50),
        Accent     = Color3.fromRGB(240, 240, 245),
        Muted      = Color3.fromRGB(100, 100, 105),
        BoxOff     = Color3.fromRGB(18, 18, 20),
        TextLight  = Color3.fromRGB(245, 245, 250),
        Hover      = Color3.fromRGB(24, 24, 28),
    }
}

local Library = {
    CurrentTab = nil,
    ToggleKey = Enum.KeyCode.Insert,
    Open = true,
    Flags = {},
    Themes = Themes,
    CurrentTheme = Themes.Fluence,
    ThemeBindings = {
        Accent = {},
        Border = {},
        BorderLit = {},
        MainBg = {},
        BoxBg = {},
        TextLight = {},
        Muted = {},
        BoxOff = {},
        Hover = {}
    }
}

local function tween(object, goal, duration, easing)
    local info = TweenInfo.new(duration or 0.15, easing or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(object, info, goal)
    tw:Play()
    return tw
end

local function bindTheme(element, property, category)
    table.insert(Library.ThemeBindings[category], { Element = element, Property = property })
    element[property] = Library.CurrentTheme[category]
end

local function addStroke(parent, category, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bindTheme(stroke, "Color", category or "Border")
    stroke.Parent = parent
    return stroke
end

function Library:SetTheme(themeNameOrTable)
    local theme = type(themeNameOrTable) == "string" and Themes[themeNameOrTable] or themeNameOrTable
    if not theme then return end
    Library.CurrentTheme = theme

    for category, elements in pairs(Library.ThemeBindings) do
        local targetColor = theme[category]
        if targetColor then
            for i = #elements, 1, -1 do
                local entry = elements[i]
                if entry.Element and entry.Element.Parent then
                    tween(entry.Element, { [entry.Property] = targetColor }, 0.2)
                else
                    table.remove(elements, i)
                end
            end
        end
    end
end

function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "fluencelua"
    local localPlayer = Players.LocalPlayer
    local currentUsername = localPlayer and localPlayer.Name or (config.Username or "samet009")
    local expiryText = config.Expiry or "expires in 23 days"

    if config.Theme and Themes[config.Theme] then
        Library.CurrentTheme = Themes[config.Theme]
    end

    local playerGui = localPlayer:WaitForChild("PlayerGui")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FluenceUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = playerGui

    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "NotificationContainer"
    NotificationContainer.Size = UDim2.new(0, 240, 1, -40)
    NotificationContainer.Position = UDim2.new(1, -260, 0, 20)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.ZIndex = 50
    NotificationContainer.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifLayout.Padding = UDim.new(0, 6)
    NotifLayout.Parent = NotificationContainer

    function Library:Notify(opt)
        opt = opt or {}
        local notifTitle = opt.Title or "notification"
        local content = opt.Content or ""
        local duration = opt.Duration or 3

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(1, 0, 0, 0)
        NotifFrame.BackgroundTransparency = 1
        NotifFrame.BorderSizePixel = 0
        NotifFrame.ClipsDescendants = true
        NotifFrame.Parent = NotificationContainer
        bindTheme(NotifFrame, "BackgroundColor3", "BoxBg")
        addStroke(NotifFrame, "Border")

        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 2, 1, 0)
        AccentBar.BorderSizePixel = 0
        bindTheme(AccentBar, "BackgroundColor3", "Accent")
        AccentBar.Parent = NotifFrame

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -16, 0, 16)
        TitleLbl.Position = UDim2.new(0, 12, 0, 6)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Font = Enum.Font.RobotoMono
        TitleLbl.TextSize = 11
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Text = string.lower(notifTitle)
        bindTheme(TitleLbl, "TextColor3", "Accent")
        TitleLbl.Parent = NotifFrame

        local ContentLbl = Instance.new("TextLabel")
        ContentLbl.Size = UDim2.new(1, -16, 0, 18)
        ContentLbl.Position = UDim2.new(0, 12, 0, 22)
        ContentLbl.BackgroundTransparency = 1
        ContentLbl.Font = Enum.Font.RobotoMono
        ContentLbl.TextSize = 10
        ContentLbl.TextXAlignment = Enum.TextXAlignment.Left
        ContentLbl.Text = content
        bindTheme(ContentLbl, "TextColor3", "TextLight")
        ContentLbl.Parent = NotifFrame

        tween(NotifFrame, { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 0 }, 0.22, Enum.EasingStyle.Back)

        task.delay(duration, function()
            local close = tween(NotifFrame, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }, 0.2)
            close.Completed:Connect(function() NotifFrame:Destroy() end)
        end)
    end

    local Watermark = Instance.new("Frame")
    Watermark.Name = "Watermark"
    Watermark.Size = UDim2.new(0, 0, 0, 20)
    Watermark.Position = UDim2.new(0, 16, 0, 16)
    Watermark.BorderSizePixel = 0
    Watermark.Visible = false
    Watermark.ZIndex = 40
    Watermark.Parent = ScreenGui
    bindTheme(Watermark, "BackgroundColor3", "MainBg")
    addStroke(Watermark, "Border")

    local WatermarkAccent = Instance.new("Frame")
    WatermarkAccent.Size = UDim2.new(1, 0, 0, 1)
    WatermarkAccent.BorderSizePixel = 0
    bindTheme(WatermarkAccent, "BackgroundColor3", "Accent")
    WatermarkAccent.Parent = Watermark

    local WatermarkLabel = Instance.new("TextLabel")
    WatermarkLabel.Size = UDim2.new(1, -12, 1, 0)
    WatermarkLabel.Position = UDim2.new(0, 6, 0, 0)
    WatermarkLabel.BackgroundTransparency = 1
    WatermarkLabel.Font = Enum.Font.RobotoMono
    WatermarkLabel.TextSize = 10
    WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
    WatermarkLabel.RichText = true
    bindTheme(WatermarkLabel, "TextColor3", "TextLight")
    WatermarkLabel.Parent = Watermark

    function Library:SetWatermark(text, visible)
        WatermarkLabel.Text = text
        Watermark.Visible = visible ~= false
        local textSize = WatermarkLabel.TextBounds.X
        tween(Watermark, { Size = UDim2.new(0, textSize + 16, 0, 20) }, 0.2)
    end

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, 630, 0, 410)
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = false
    MainWindow.Parent = ScreenGui
    bindTheme(MainWindow, "BackgroundColor3", "MainBg")
    addStroke(MainWindow, "Border")

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 26)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.RobotoMono
    Title.TextSize = 13
    Title.RichText = true
    Title.Parent = MainWindow

    local function updateTitle()
        local acc = Library.CurrentTheme.Accent
        local txt = Library.CurrentTheme.TextLight
        Title.Text = string.format('<font color="rgb(%d,%d,%d)"><u>%s</u></font><font color="rgb(%d,%d,%d)">%s</font>',
            acc.R * 255, acc.G * 255, acc.B * 255, string.sub(windowTitle, 1, 7),
            txt.R * 255, txt.G * 255, txt.B * 255, string.sub(windowTitle, 8)
        )
    end
    updateTitle()
    table.insert(Library.ThemeBindings.Accent, { Element = Title, Property = "TextColor3" })
    Title:GetPropertyChangedSignal("TextColor3"):Connect(updateTitle)

    local dragging, dragStart, startPos, dragInput
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(MainWindow, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.04)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            if Library.Open then
                MainWindow.Visible = true
                tween(MainWindow, { Size = UDim2.new(0, 630, 0, 410) }, 0.22, Enum.EasingStyle.Quart)
            else
                local closeTw = tween(MainWindow, { Size = UDim2.new(0, 630, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
                closeTw.Completed:Connect(function()
                    if not Library.Open then MainWindow.Visible = false end
                end)
            end
        end
    end)

    local InnerContainer = Instance.new("Frame")
    InnerContainer.Name = "InnerContainer"
    InnerContainer.Size = UDim2.new(1, -16, 1, -34)
    InnerContainer.Position = UDim2.new(0, 8, 0, 26)
    InnerContainer.BorderSizePixel = 0
    InnerContainer.Parent = MainWindow
    bindTheme(InnerContainer, "BackgroundColor3", "MainBg")
    addStroke(InnerContainer, "Border")

    local UserCardBox = Instance.new("Frame")
    UserCardBox.Name = "UserCardBox"
    UserCardBox.Size = UDim2.new(0, 145, 0, 46)
    UserCardBox.Position = UDim2.new(0, 6, 0, 6)
    UserCardBox.BorderSizePixel = 0
    UserCardBox.Parent = InnerContainer
    bindTheme(UserCardBox, "BackgroundColor3", "BoxBg")
    addStroke(UserCardBox, "Border")

    local UserLabel = Instance.new("TextLabel")
    UserLabel.Size = UDim2.new(1, -16, 0, 16)
    UserLabel.Position = UDim2.new(0, 10, 0, 7)
    UserLabel.BackgroundTransparency = 1
    UserLabel.Font = Enum.Font.RobotoMono
    UserLabel.TextSize = 12
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserLabel.Text = currentUsername
    UserLabel.Parent = UserCardBox
    bindTheme(UserLabel, "TextColor3", "TextLight")

    local ExpiryLabel = Instance.new("TextLabel")
    ExpiryLabel.Size = UDim2.new(1, -16, 0, 14)
    ExpiryLabel.Position = UDim2.new(0, 10, 0, 24)
    ExpiryLabel.BackgroundTransparency = 1
    ExpiryLabel.Font = Enum.Font.RobotoMono
    ExpiryLabel.TextSize = 11
    ExpiryLabel.TextXAlignment = Enum.TextXAlignment.Left
    ExpiryLabel.Text = expiryText
    ExpiryLabel.Parent = UserCardBox
    bindTheme(ExpiryLabel, "TextColor3", "Muted")

    local NavCardBox = Instance.new("Frame")
    NavCardBox.Name = "NavCardBox"
    NavCardBox.Size = UDim2.new(0, 145, 1, -64)
    NavCardBox.Position = UDim2.new(0, 6, 0, 58)
    NavCardBox.BorderSizePixel = 0
    NavCardBox.Parent = InnerContainer
    bindTheme(NavCardBox, "BackgroundColor3", "BoxBg")
    addStroke(NavCardBox, "Border")

    local NavList = Instance.new("Frame")
    NavList.Name = "NavList"
    NavList.Size = UDim2.new(1, 0, 1, 0)
    NavList.BackgroundTransparency = 1
    NavList.Parent = NavCardBox

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 3)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Parent = NavList

    local NavPadding = Instance.new("UIPadding")
    NavPadding.PaddingTop = UDim.new(0, 8)
    NavPadding.PaddingLeft = UDim.new(0, 14)
    NavPadding.Parent = NavList

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -163, 1, -12)
    ContentArea.Position = UDim2.new(0, 157, 0, 6)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = InnerContainer

    local WindowObj = {
        _tabs = {},
        _subTabs = {},
        _orderCount = 0,
        _firstPage = nil,
    }

    local ColorPickerPopup = Instance.new("Frame")
    ColorPickerPopup.Name = "ColorPickerPopup"
    ColorPickerPopup.Size = UDim2.new(0, 175, 0, 185)
    ColorPickerPopup.BorderSizePixel = 0
    ColorPickerPopup.Visible = false
    ColorPickerPopup.ZIndex = 100
    ColorPickerPopup.Parent = ScreenGui
    bindTheme(ColorPickerPopup, "BackgroundColor3", "BoxBg")
    addStroke(ColorPickerPopup, "BorderLit")

    local CPTitle = Instance.new("TextLabel")
    CPTitle.Size = UDim2.new(1, -16, 0, 18)
    CPTitle.Position = UDim2.new(0, 8, 0, 6)
    CPTitle.BackgroundTransparency = 1
    CPTitle.Font = Enum.Font.RobotoMono
    CPTitle.TextSize = 11
    CPTitle.Text = "color picker"
    CPTitle.TextXAlignment = Enum.TextXAlignment.Left
    CPTitle.ZIndex = 101
    bindTheme(CPTitle, "TextColor3", "Muted")
    CPTitle.Parent = ColorPickerPopup

    local SVMap = Instance.new("ImageLabel")
    SVMap.Name = "SVMap"
    SVMap.Size = UDim2.new(1, -16, 0, 105)
    SVMap.Position = UDim2.new(0, 8, 0, 26)
    SVMap.BorderSizePixel = 0
    SVMap.Image = "rbxassetid://4155801252"
    SVMap.ZIndex = 101
    SVMap.Parent = ColorPickerPopup
    addStroke(SVMap, "Border")

    local SVCursor = Instance.new("Frame")
    SVCursor.Size = UDim2.new(0, 4, 0, 4)
    SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    SVCursor.BorderSizePixel = 0
    SVCursor.ZIndex = 103
    SVCursor.Parent = SVMap
    addStroke(SVCursor, "Border")

    local HueBar = Instance.new("ImageLabel")
    HueBar.Name = "HueBar"
    HueBar.Size = UDim2.new(1, -16, 0, 12)
    HueBar.Position = UDim2.new(0, 8, 0, 138)
    HueBar.BorderSizePixel = 0
    HueBar.Image = "rbxassetid://3641079629"
    HueBar.ZIndex = 101
    HueBar.Parent = ColorPickerPopup
    addStroke(HueBar, "Border")

    local HueCursor = Instance.new("Frame")
    HueCursor.Size = UDim2.new(0, 2, 1, 2)
    HueCursor.Position = UDim2.new(0, 0, 0, -1)
    HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    HueCursor.BorderSizePixel = 0
    HueCursor.ZIndex = 103
    HueCursor.Parent = HueBar

    local HexLabel = Instance.new("TextLabel")
    HexLabel.Size = UDim2.new(1, -16, 0, 18)
    HexLabel.Position = UDim2.new(0, 8, 0, 158)
    HexLabel.BackgroundTransparency = 1
    HexLabel.Font = Enum.Font.RobotoMono
    HexLabel.TextSize = 10
    HexLabel.TextXAlignment = Enum.TextXAlignment.Left
    HexLabel.Text = "#A8FF3E"
    HexLabel.ZIndex = 101
    bindTheme(HexLabel, "TextColor3", "TextLight")
    HexLabel.Parent = ColorPickerPopup

    local activePickerCallback = nil
    local currentH, currentS, currentV = 0.25, 1, 1

    local function updateColor()
        local color = Color3.fromHSV(currentH, currentS, currentV)
        SVMap.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
        HexLabel.Text = string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
        if activePickerCallback then
            activePickerCallback(color)
        end
    end

    local draggingSV, draggingHue = false, false

    SVMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = true
            local relX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
            currentS = relX
            currentV = 1 - relY
            SVCursor.Position = UDim2.new(relX, 0, relY, 0)
            updateColor()
        end
    end)

    HueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            local relX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
            currentH = relX
            HueCursor.Position = UDim2.new(relX, -1, 0, -1)
            updateColor()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = false
            draggingHue = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingSV then
                local relX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                currentS = relX
                currentV = 1 - relY
                SVCursor.Position = UDim2.new(relX, 0, relY, 0)
                updateColor()
            elseif draggingHue then
                local relX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                currentH = relX
                HueCursor.Position = UDim2.new(relX, -1, 0, -1)
                updateColor()
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorPickerPopup.Visible then
            local p = input.Position
            local cpPos = ColorPickerPopup.AbsolutePosition
            local cpSize = ColorPickerPopup.AbsoluteSize
            if p.X < cpPos.X or p.X > cpPos.X + cpSize.X or p.Y < cpPos.Y or p.Y > cpPos.Y + cpSize.Y then
                ColorPickerPopup.Visible = false
            end
        end
    end)

    function WindowObj:CreateTab(tabName)
        WindowObj._orderCount = WindowObj._orderCount + 1

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Size = UDim2.new(1, -14, 0, 18)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Font = Enum.Font.RobotoMono
        TabBtn.TextSize = 12
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.TextYAlignment = Enum.TextYAlignment.Center
        TabBtn.Text = string.lower(tabName)
        TabBtn.LayoutOrder = WindowObj._orderCount
        TabBtn.Parent = NavList
        bindTheme(TabBtn, "TextColor3", "Muted")

        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 1, 0, 14)
        AccentBar.Position = UDim2.new(0, -6, 0.5, -7)
        AccentBar.BorderSizePixel = 0
        AccentBar.Visible = false
        AccentBar.Parent = TabBtn
        bindTheme(AccentBar, "BackgroundColor3", "Accent")

        local TabObj = {
            Button = TabBtn,
            AccentBar = AccentBar,
            SubTabs = {},
        }

        function TabObj:CreateSubTab(subName, isLastSubTab)
            WindowObj._orderCount = WindowObj._orderCount + 1
            local prefix = isLastSubTab and "└ " or "├ "

            local SubBtn = Instance.new("TextButton")
            SubBtn.Name = "Sub_" .. subName
            SubBtn.Size = UDim2.new(1, -14, 0, 18)
            SubBtn.BackgroundTransparency = 1
            SubBtn.Font = Enum.Font.RobotoMono
            SubBtn.TextSize = 12
            SubBtn.TextXAlignment = Enum.TextXAlignment.Left
            SubBtn.TextYAlignment = Enum.TextYAlignment.Center
            SubBtn.Text = prefix .. string.lower(subName)
            SubBtn.LayoutOrder = WindowObj._orderCount
            SubBtn.Parent = NavList
            bindTheme(SubBtn, "TextColor3", "Muted")

            local Page = Instance.new("Frame")
            Page.Name = "Page_" .. subName
            Page.Size = UDim2.new(1, 0, 1, 0)
            Page.BackgroundTransparency = 1
            Page.Visible = false
            Page.Parent = ContentArea

            local LeftCol = Instance.new("Frame")
            LeftCol.Name = "LeftColumn"
            LeftCol.Size = UDim2.new(0.5, -3, 1, 0)
            LeftCol.Position = UDim2.new(0, 0, 0, 0)
            LeftCol.BackgroundTransparency = 1
            LeftCol.BorderSizePixel = 0
            LeftCol.Parent = Page

            local RightCol = Instance.new("Frame")
            RightCol.Name = "RightColumn"
            RightCol.Size = UDim2.new(0.5, -3, 1, 0)
            RightCol.Position = UDim2.new(0.5, 3, 0, 0)
            RightCol.BackgroundTransparency = 1
            RightCol.BorderSizePixel = 0
            RightCol.Parent = Page

            local SubObj = {
                Page = Page,
                Button = SubBtn,
                LeftCol = LeftCol,
                RightCol = RightCol,
            }

            local function activate()
                for _, otherSub in pairs(WindowObj._subTabs) do
                    otherSub.Page.Visible = false
                    tween(otherSub.Button, { TextColor3 = Library.CurrentTheme.Muted }, 0.15)
                end
                for _, otherTab in pairs(WindowObj._tabs) do
                    tween(otherTab.Button, { TextColor3 = Library.CurrentTheme.Muted }, 0.15)
                    otherTab.AccentBar.Visible = false
                end

                tween(TabBtn, { TextColor3 = Library.CurrentTheme.Accent }, 0.15)
                AccentBar.Visible = true

                tween(SubBtn, { TextColor3 = Library.CurrentTheme.Accent }, 0.15)
                Page.Visible = true
            end

            SubBtn.MouseButton1Click:Connect(activate)

            if not WindowObj._firstPage then
                WindowObj._firstPage = activate
                task.defer(activate)
            end

            table.insert(WindowObj._subTabs, SubObj)
            table.insert(TabObj.SubTabs, SubObj)

            local function buildSection(parentCol, titleText)
                local GroupBox = Instance.new("Frame")
                GroupBox.Name = "GroupBox_" .. titleText
                GroupBox.Size = UDim2.new(1, 0, 0, 230)
                GroupBox.BorderSizePixel = 0
                GroupBox.ClipsDescendants = false
                GroupBox.Parent = parentCol
                bindTheme(GroupBox, "BackgroundColor3", "BoxBg")
                addStroke(GroupBox, "Border")

                local TitleContainer = Instance.new("Frame")
                TitleContainer.Name = "TitleContainer"
                TitleContainer.Size = UDim2.new(0, 0, 0, 16)
                TitleContainer.Position = UDim2.new(0.5, 0, 0, 0)
                TitleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
                TitleContainer.BorderSizePixel = 0
                TitleContainer.Parent = GroupBox
                bindTheme(TitleContainer, "BackgroundColor3", "BoxBg")

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Size = UDim2.new(1, 0, 1, 0)
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.Font = Enum.Font.RobotoMono
                TitleLbl.TextSize = 11
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Center
                TitleLbl.TextYAlignment = Enum.TextYAlignment.Center
                TitleLbl.Text = string.lower(titleText)
                bindTheme(TitleLbl, "TextColor3", "TextLight")
                TitleLbl.Parent = TitleContainer

                local textBounds = TitleLbl.TextBounds.X
                TitleContainer.Size = UDim2.new(0, textBounds + 16, 0, 16)
                TitleLbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    TitleContainer.Size = UDim2.new(0, TitleLbl.TextBounds.X + 16, 0, 16)
                end)

                local Scroll = Instance.new("ScrollingFrame")
                Scroll.Name = "ListScroll"
                Scroll.Size = UDim2.new(1, -16, 1, -20)
                Scroll.Position = UDim2.new(0, 8, 0, 12)
                Scroll.BackgroundTransparency = 1
                Scroll.BorderSizePixel = 0
                Scroll.ScrollBarThickness = 2
                Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                Scroll.Parent = GroupBox
                bindTheme(Scroll, "ScrollBarImageColor3", "Border")

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Padding = UDim.new(0, 6)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = Scroll

                local Section = {}

                function Section:AddToggle(opt)
                    opt = opt or {}
                    local flag = opt.Flag or opt.Name
                    local state = opt.Default or false
                    local callback = opt.Callback or function() end

                    if flag then Library.Flags[flag] = state end

                    local ToggleBtn = Instance.new("TextButton")
                    ToggleBtn.Size = UDim2.new(1, -4, 0, 16)
                    ToggleBtn.BackgroundTransparency = 1
                    ToggleBtn.Text = ""
                    ToggleBtn.Parent = Scroll

                    local Box = Instance.new("Frame")
                    Box.Size = UDim2.new(0, 10, 0, 10)
                    Box.Position = UDim2.new(0, 0, 0.5, -5)
                    Box.BackgroundColor3 = state and Library.CurrentTheme.Accent or Library.CurrentTheme.BoxOff
                    Box.BorderSizePixel = 0
                    Box.Parent = ToggleBtn
                    addStroke(Box, "Border")

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0.65, 0, 1, 0)
                    Label.Position = UDim2.new(0, 16, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.RobotoMono
                    Label.TextSize = 11
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.TextYAlignment = Enum.TextYAlignment.Center
                    Label.Text = string.lower(opt.Name or "toggle")
                    Label.TextColor3 = state and Library.CurrentTheme.TextLight or Library.CurrentTheme.Muted
                    Label.Parent = ToggleBtn

                    local function update()
                        local targetBg = state and Library.CurrentTheme.Accent or Library.CurrentTheme.BoxOff
                        local targetTxt = state and Library.CurrentTheme.TextLight or Library.CurrentTheme.Muted
                        tween(Box, { BackgroundColor3 = targetBg }, 0.15)
                        tween(Label, { TextColor3 = targetTxt }, 0.15)
                        if flag then Library.Flags[flag] = state end
                        callback(state)
                    end

                    ToggleBtn.MouseButton1Click:Connect(function()
                        state = not state
                        update()
                    end)

                    local ToggleObj = {}
                    function ToggleObj:Set(val)
                        state = val
                        update()
                    end

                    if opt.Keybind ~= nil then
                        local key = opt.Keybind
                        local KeyBtn = Instance.new("TextButton")
                        KeyBtn.Size = UDim2.new(0, 38, 0, 14)
                        KeyBtn.Position = UDim2.new(1, -38, 0.5, -7)
                        KeyBtn.BorderSizePixel = 0
                        KeyBtn.Font = Enum.Font.RobotoMono
                        KeyBtn.TextSize = 10
                        KeyBtn.Text = "[" .. (typeof(key) == "EnumItem" and key.Name or tostring(key)) .. "]"
                        KeyBtn.Parent = ToggleBtn
                        bindTheme(KeyBtn, "BackgroundColor3", "BoxOff")
                        bindTheme(KeyBtn, "TextColor3", "Muted")
                        addStroke(KeyBtn, "Border")

                        local listening = false
                        KeyBtn.MouseButton1Click:Connect(function()
                            listening = true
                            KeyBtn.Text = "[...]"
                            tween(KeyBtn, { TextColor3 = Library.CurrentTheme.Accent }, 0.15)
                        end)

                        UserInputService.InputBegan:Connect(function(input, gpe)
                            if listening then
                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    key = input.KeyCode
                                    KeyBtn.Text = "[" .. key.Name .. "]"
                                    tween(KeyBtn, { TextColor3 = Library.CurrentTheme.Muted }, 0.15)
                                    listening = false
                                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                    key = Enum.UserInputType.MouseButton2
                                    KeyBtn.Text = "[M2]"
                                    tween(KeyBtn, { TextColor3 = Library.CurrentTheme.Muted }, 0.15)
                                    listening = false
                                end
                            end
                        end)
                    end

                    return ToggleObj
                end

                function Section:AddSlider(opt)
                    opt = opt or {}
                    local flag = opt.Flag or opt.Name
                    local min = opt.Min or 0
                    local max = opt.Max or 100
                    local default = opt.Default or min
                    local suffix = opt.Suffix or ""
                    local callback = opt.Callback or function() end

                    if flag then Library.Flags[flag] = default end

                    local SliderFrame = Instance.new("Frame")
                    SliderFrame.Size = UDim2.new(1, -4, 0, 24)
                    SliderFrame.BackgroundTransparency = 1
                    SliderFrame.Parent = Scroll

                    local Title = Instance.new("TextLabel")
                    Title.Size = UDim2.new(1, 0, 0, 13)
                    Title.BackgroundTransparency = 1
                    Title.Font = Enum.Font.RobotoMono
                    Title.TextSize = 11
                    Title.TextXAlignment = Enum.TextXAlignment.Left
                    Title.TextYAlignment = Enum.TextYAlignment.Center
                    Title.Text = string.format("%s [%d%s]", string.lower(opt.Name or "slider"), default, suffix)
                    bindTheme(Title, "TextColor3", "TextLight")
                    Title.Parent = SliderFrame

                    local Bar = Instance.new("Frame")
                    Bar.Size = UDim2.new(1, 0, 0, 4)
                    Bar.Position = UDim2.new(0, 0, 0, 17)
                    Bar.BorderSizePixel = 0
                    Bar.Parent = SliderFrame
                    bindTheme(Bar, "BackgroundColor3", "BoxOff")

                    local Fill = Instance.new("Frame")
                    Fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
                    Fill.BorderSizePixel = 0
                    Fill.Parent = Bar
                    bindTheme(Fill, "BackgroundColor3", "Accent")

                    local sliding = false
                    local function setVal(pct)
                        pct = math.clamp(pct, 0, 1)
                        tween(Fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.05)
                        local current = math.floor(min + (max - min) * pct)
                        Title.Text = string.format("%s [%d%s]", string.lower(opt.Name or "slider"), current, suffix)
                        if flag then Library.Flags[flag] = current end
                        callback(current)
                    end

                    Bar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliding = true
                            setVal((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                            setVal((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X)
                        end
                    end)

                    local SliderObj = {}
                    function SliderObj:Set(val)
                        setVal((val - min) / (max - min))
                    end
                    return SliderObj
                end

                function Section:AddDropdown(opt)
                    opt = opt or {}
                    local flag = opt.Flag or opt.Name
                    local items = opt.Options or {}
                    local selected = opt.Default or items[1] or "none"
                    local callback = opt.Callback or function() end

                    if flag then Library.Flags[flag] = selected end

                    local DropFrame = Instance.new("Frame")
                    DropFrame.Size = UDim2.new(1, -4, 0, 36)
                    DropFrame.BackgroundTransparency = 1
                    DropFrame.ClipsDescendants = true
                    DropFrame.Parent = Scroll

                    local Title = Instance.new("TextLabel")
                    Title.Size = UDim2.new(1, 0, 0, 13)
                    Title.BackgroundTransparency = 1
                    Title.Font = Enum.Font.RobotoMono
                    Title.TextSize = 11
                    Title.TextXAlignment = Enum.TextXAlignment.Left
                    Title.TextYAlignment = Enum.TextYAlignment.Center
                    Title.Text = string.lower(opt.Name or "dropdown")
                    bindTheme(Title, "TextColor3", "Muted")
                    Title.Parent = DropFrame

                    local Box = Instance.new("TextButton")
                    Box.Size = UDim2.new(1, 0, 0, 18)
                    Box.Position = UDim2.new(0, 0, 0, 16)
                    Box.BorderSizePixel = 0
                    Box.Font = Enum.Font.RobotoMono
                    Box.TextSize = 11
                    Box.TextXAlignment = Enum.TextXAlignment.Left
                    Box.Text = "  " .. tostring(selected)
                    Box.Parent = DropFrame
                    bindTheme(Box, "BackgroundColor3", "BoxOff")
                    bindTheme(Box, "TextColor3", "TextLight")
                    addStroke(Box, "Border")

                    local Arrow = Instance.new("TextLabel")
                    Arrow.Size = UDim2.new(0, 14, 1, 0)
                    Arrow.Position = UDim2.new(1, -16, 0, 0)
                    Arrow.BackgroundTransparency = 1
                    Arrow.Font = Enum.Font.RobotoMono
                    Arrow.TextSize = 10
                    Arrow.Text = "▾"
                    bindTheme(Arrow, "TextColor3", "Muted")
                    Arrow.Parent = Box

                    local DropList = Instance.new("Frame")
                    DropList.Size = UDim2.new(1, 0, 0, 0)
                    DropList.Position = UDim2.new(0, 0, 0, 36)
                    DropList.BorderSizePixel = 0
                    DropList.Parent = DropFrame
                    bindTheme(DropList, "BackgroundColor3", "BoxBg")
                    addStroke(DropList, "Border")

                    local DropScroll = Instance.new("ScrollingFrame")
                    DropScroll.Size = UDim2.new(1, 0, 1, 0)
                    DropScroll.BackgroundTransparency = 1
                    DropScroll.BorderSizePixel = 0
                    DropScroll.ScrollBarThickness = 2
                    DropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    DropScroll.Parent = DropList
                    bindTheme(DropScroll, "ScrollBarImageColor3", "Border")

                    local DropLayout = Instance.new("UIListLayout")
                    DropLayout.Padding = UDim.new(0, 2)
                    DropLayout.Parent = DropScroll

                    local isOpen = false

                    local function populate()
                        for _, child in pairs(DropScroll:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        for _, item in ipairs(items) do
                            local ItemBtn = Instance.new("TextButton")
                            ItemBtn.Size = UDim2.new(1, 0, 0, 18)
                            ItemBtn.BackgroundTransparency = 1
                            ItemBtn.Font = Enum.Font.RobotoMono
                            ItemBtn.TextSize = 11
                            ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                            ItemBtn.Text = "  " .. tostring(item)
                            ItemBtn.TextColor3 = (item == selected) and Library.CurrentTheme.Accent or Library.CurrentTheme.TextLight
                            ItemBtn.Parent = DropScroll

                            ItemBtn.MouseEnter:Connect(function()
                                tween(ItemBtn, { BackgroundTransparency = 0, BackgroundColor3 = Library.CurrentTheme.Hover }, 0.1)
                            end)
                            ItemBtn.MouseLeave:Connect(function()
                                tween(ItemBtn, { BackgroundTransparency = 1 }, 0.1)
                            end)

                            ItemBtn.MouseButton1Click:Connect(function()
                                selected = item
                                Box.Text = "  " .. tostring(selected)
                                if flag then Library.Flags[flag] = selected end
                                callback(selected)
                                isOpen = false
                                Arrow.Text = "▾"
                                tween(DropFrame, { Size = UDim2.new(1, -4, 0, 36) }, 0.2)
                            end)
                        end
                    end

                    Box.MouseButton1Click:Connect(function()
                        isOpen = not isOpen
                        Arrow.Text = isOpen and "▴" or "▾"
                        if isOpen then
                            populate()
                            local targetHeight = math.min(#items * 20 + 4, 85)
                            DropList.Size = UDim2.new(1, 0, 0, targetHeight)
                            tween(DropFrame, { Size = UDim2.new(1, -4, 0, 40 + targetHeight) }, 0.22, Enum.EasingStyle.Quart)
                        else
                            tween(DropFrame, { Size = UDim2.new(1, -4, 0, 36) }, 0.18, Enum.EasingStyle.Quart)
                        end
                    end)
                end

                function Section:AddColorPicker(opt)
                    opt = opt or {}
                    local flag = opt.Flag or opt.Name
                    local currentColor = opt.Default or Library.CurrentTheme.Accent
                    local callback = opt.Callback or function() end

                    if flag then Library.Flags[flag] = currentColor end

                    local PickerFrame = Instance.new("Frame")
                    PickerFrame.Size = UDim2.new(1, -4, 0, 16)
                    PickerFrame.BackgroundTransparency = 1
                    PickerFrame.Parent = Scroll

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0.7, 0, 1, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.RobotoMono
                    Label.TextSize = 11
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.TextYAlignment = Enum.TextYAlignment.Center
                    Label.Text = string.lower(opt.Name or "color")
                    bindTheme(Label, "TextColor3", "Muted")
                    Label.Parent = PickerFrame

                    local Swatch = Instance.new("TextButton")
                    Swatch.Size = UDim2.new(0, 22, 0, 10)
                    Swatch.Position = UDim2.new(1, -22, 0.5, -5)
                    Swatch.BackgroundColor3 = currentColor
                    Swatch.BorderSizePixel = 0
                    Swatch.Text = ""
                    Swatch.Parent = PickerFrame
                    addStroke(Swatch, "Border")

                    Swatch.MouseButton1Click:Connect(function()
                        local pos = Swatch.AbsolutePosition
                        ColorPickerPopup.Position = UDim2.new(0, pos.X + 28, 0, math.clamp(pos.Y - 20, 10, ScreenGui.AbsoluteSize.Y - 200))
                        ColorPickerPopup.Visible = true

                        activePickerCallback = function(col)
                            currentColor = col
                            Swatch.BackgroundColor3 = col
                            if flag then Library.Flags[flag] = col end
                            callback(col)
                        end
                    end)
                end

                function Section:AddTextBox(opt)
                    opt = opt or {}
                    local flag = opt.Flag or opt.Name
                    local placeholder = opt.Placeholder or "type here..."
                    local callback = opt.Callback or function() end

                    local BoxFrame = Instance.new("Frame")
                    BoxFrame.Size = UDim2.new(1, -4, 0, 36)
                    BoxFrame.BackgroundTransparency = 1
                    BoxFrame.Parent = Scroll

                    local Title = Instance.new("TextLabel")
                    Title.Size = UDim2.new(1, 0, 0, 13)
                    Title.BackgroundTransparency = 1
                    Title.Font = Enum.Font.RobotoMono
                    Title.TextSize = 11
                    Title.TextXAlignment = Enum.TextXAlignment.Left
                    Title.TextYAlignment = Enum.TextYAlignment.Center
                    Title.Text = string.lower(opt.Name or "input")
                    bindTheme(Title, "TextColor3", "Muted")
                    Title.Parent = BoxFrame

                    local Input = Instance.new("TextBox")
                    Input.Size = UDim2.new(1, 0, 0, 18)
                    Input.Position = UDim2.new(0, 0, 0, 16)
                    Input.BorderSizePixel = 0
                    Input.Font = Enum.Font.RobotoMono
                    Input.TextSize = 11
                    Input.PlaceholderText = placeholder
                    Input.Text = opt.Default or ""
                    Input.TextXAlignment = Enum.TextXAlignment.Left
                    Input.ClearTextOnFocus = false
                    Input.Parent = BoxFrame
                    bindTheme(Input, "BackgroundColor3", "BoxOff")
                    bindTheme(Input, "TextColor3", "TextLight")
                    bindTheme(Input, "PlaceholderColor3", "Muted")
                    addStroke(Input, "Border")

                    local InputPadding = Instance.new("UIPadding")
                    InputPadding.PaddingLeft = UDim.new(0, 6)
                    InputPadding.Parent = Input

                    Input.Focused:Connect(function()
                        tween(Input, { BackgroundColor3 = Library.CurrentTheme.Hover }, 0.15)
                    end)
                    Input.FocusLost:Connect(function(enterPressed)
                        tween(Input, { BackgroundColor3 = Library.CurrentTheme.BoxOff }, 0.15)
                        if flag then Library.Flags[flag] = Input.Text end
                        callback(Input.Text, enterPressed)
                    end)
                end

                function Section:AddButton(opt)
                    opt = opt or {}
                    local callback = opt.Callback or function() end

                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1, -4, 0, 22)
                    Btn.BorderSizePixel = 0
                    Btn.Font = Enum.Font.RobotoMono
                    Btn.TextSize = 11
                    Btn.Text = string.lower(opt.Name or "button")
                    Btn.Parent = Scroll
                    bindTheme(Btn, "BackgroundColor3", "BoxOff")
                    bindTheme(Btn, "TextColor3", "Muted")
                    addStroke(Btn, "Border")

                    Btn.MouseEnter:Connect(function()
                        tween(Btn, { BackgroundColor3 = Library.CurrentTheme.Hover, TextColor3 = Library.CurrentTheme.TextLight }, 0.12)
                    end)
                    Btn.MouseLeave:Connect(function()
                        tween(Btn, { BackgroundColor3 = Library.CurrentTheme.BoxOff, TextColor3 = Library.CurrentTheme.Muted }, 0.12)
                    end)
                    Btn.MouseButton1Down:Connect(function()
                        tween(Btn, { TextColor3 = Library.CurrentTheme.Accent }, 0.08)
                    end)
                    Btn.MouseButton1Up:Connect(function()
                        tween(Btn, { TextColor3 = Library.CurrentTheme.TextLight }, 0.12)
                    end)
                    Btn.MouseButton1Click:Connect(callback)
                end

                return Section
            end

            function SubObj:CreateLeftSection(titleText)
                return buildSection(LeftCol, titleText)
            end

            function SubObj:CreateRightSection(titleText)
                return buildSection(RightCol, titleText)
            end

            return SubObj
        end

        table.insert(WindowObj._tabs, TabObj)
        return TabObj
    end

    function WindowObj:CreateThemeTab()
        local SettingsTab = WindowObj:CreateTab("customization")
        local ThemeSub = SettingsTab:CreateSubTab("theme", true)
        local LeftSec = ThemeSub:CreateLeftSection("theme selection")
        local RightSec = ThemeSub:CreateRightSection("menu settings")

        LeftSec:AddDropdown({
            Name = "color preset",
            Options = { "Fluence", "Crimson", "Azure", "Amethyst", "Monochrome" },
            Default = "Fluence",
            Callback = function(themeName)
                Library:SetTheme(themeName)
                Library:Notify({
                    Title = "theme",
                    Content = "Applied " .. themeName .. " preset.",
                    Duration = 2
                })
            end
        })

        LeftSec:AddColorPicker({
            Name = "custom accent color",
            Default = Library.CurrentTheme.Accent,
            Callback = function(newColor)
                local customTheme = {
                    MainBg     = Library.CurrentTheme.MainBg,
                    BoxBg      = Library.CurrentTheme.BoxBg,
                    Border     = Library.CurrentTheme.Border,
                    BorderLit  = Library.CurrentTheme.BorderLit,
                    Accent     = newColor,
                    Muted      = Library.CurrentTheme.Muted,
                    BoxOff     = Library.CurrentTheme.BoxOff,
                    TextLight  = Library.CurrentTheme.TextLight,
                    Hover      = Library.CurrentTheme.Hover,
                }
                Library:SetTheme(customTheme)
            end
        })

        RightSec:AddToggle({
            Name = "watermark",
            Default = true,
            Callback = function(val)
                Library:SetWatermark("fluence.lua | " .. currentUsername .. " | 60 fps", val)
            end
        })

        RightSec:AddButton({
            Name = "copy discord",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/")
                    Library:Notify({
                        Title = "clipboard",
                        Content = "Link copied to clipboard.",
                        Duration = 2
                    })
                end
            end
        })

        return ThemeSub
    end

    return WindowObj
end

return Library
