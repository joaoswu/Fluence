local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Icons = {
    crosshair = "rbxassetid://10709769841",
    eye       = "rbxassetid://10709770307",
    sliders   = "rbxassetid://10709772274",
    shield    = "rbxassetid://10709772189",
    wrench    = "rbxassetid://10709773822",
    user      = "rbxassetid://10709773273",
    chevron   = "rbxassetid://10709769508",
    check     = "rbxassetid://10709769335",
    terminal  = "rbxassetid://10709772868",
    palette   = "rbxassetid://10709771485",
    settings  = "rbxassetid://10709772098",
    bell      = "rbxassetid://10709769168",
    code      = "rbxassetid://10709769632",
    box       = "rbxassetid://10709769248",
}

local function resolveIcon(icon)
    if not icon then return nil end
    if type(icon) == "number" then return "rbxassetid://" .. tostring(icon) end
    if Icons[icon] then return Icons[icon] end
    if string.find(tostring(icon), "rbxassetid://") or string.find(tostring(icon), "http") then
        return tostring(icon)
    end
    if tonumber(icon) then return "rbxassetid://" .. tostring(icon) end
    return tostring(icon)
end

local Themes = {
    Fluence = {
        MainBg     = Color3.fromRGB(15, 16, 20),
        SidebarBg  = Color3.fromRGB(13, 14, 18),
        SectionBg  = Color3.fromRGB(13, 14, 18),
        Border     = Color3.fromRGB(30, 32, 40),
        Accent     = Color3.fromRGB(168, 255, 62),
        AccentDark = Color3.fromRGB(120, 195, 38),
        Muted      = Color3.fromRGB(105, 110, 125),
        BoxOff     = Color3.fromRGB(18, 20, 26),
        TextLight  = Color3.fromRGB(220, 225, 230),
        Hover      = Color3.fromRGB(24, 27, 36),
    },
    Crimson = {
        MainBg     = Color3.fromRGB(16, 14, 15),
        SidebarBg  = Color3.fromRGB(14, 12, 13),
        SectionBg  = Color3.fromRGB(14, 12, 13),
        Border     = Color3.fromRGB(42, 28, 30),
        Accent     = Color3.fromRGB(255, 65, 84),
        AccentDark = Color3.fromRGB(195, 38, 55),
        Muted      = Color3.fromRGB(125, 105, 110),
        BoxOff     = Color3.fromRGB(26, 18, 20),
        TextLight  = Color3.fromRGB(235, 220, 225),
        Hover      = Color3.fromRGB(36, 22, 26),
    },
    Azure = {
        MainBg     = Color3.fromRGB(14, 16, 20),
        SidebarBg  = Color3.fromRGB(12, 13, 17),
        SectionBg  = Color3.fromRGB(12, 13, 17),
        Border     = Color3.fromRGB(28, 34, 46),
        Accent     = Color3.fromRGB(60, 165, 255),
        AccentDark = Color3.fromRGB(35, 120, 200),
        Muted      = Color3.fromRGB(100, 112, 130),
        BoxOff     = Color3.fromRGB(18, 22, 30),
        TextLight  = Color3.fromRGB(220, 230, 240),
        Hover      = Color3.fromRGB(22, 28, 40),
    },
    Amethyst = {
        MainBg     = Color3.fromRGB(16, 14, 20),
        SidebarBg  = Color3.fromRGB(13, 12, 17),
        SectionBg  = Color3.fromRGB(13, 12, 17),
        Border     = Color3.fromRGB(38, 30, 48),
        Accent     = Color3.fromRGB(185, 95, 255),
        AccentDark = Color3.fromRGB(140, 60, 205),
        Muted      = Color3.fromRGB(115, 105, 128),
        BoxOff     = Color3.fromRGB(24, 18, 30),
        TextLight  = Color3.fromRGB(230, 220, 240),
        Hover      = Color3.fromRGB(32, 24, 42),
    },
    Monochrome = {
        MainBg     = Color3.fromRGB(16, 16, 17),
        SidebarBg  = Color3.fromRGB(13, 13, 14),
        SectionBg  = Color3.fromRGB(13, 13, 14),
        Border     = Color3.fromRGB(36, 36, 38),
        Accent     = Color3.fromRGB(240, 240, 245),
        AccentDark = Color3.fromRGB(180, 180, 185),
        Muted      = Color3.fromRGB(110, 110, 115),
        BoxOff     = Color3.fromRGB(22, 22, 24),
        TextLight  = Color3.fromRGB(245, 245, 250),
        Hover      = Color3.fromRGB(28, 28, 32),
    }
}

local Library = {
    CurrentTab = nil,
    ToggleKey = Enum.KeyCode.Insert,
    Open = true,
    Flags = {},
    Icons = Icons,
    Themes = Themes,
    CurrentTheme = Themes.Fluence,
    ThemeBindings = {
        Accent = {},
        Border = {},
        MainBg = {},
        SidebarBg = {},
        TextLight = {},
        Muted = {},
        BoxOff = {},
        Hover = {}
    }
}

local function tween(object, goal, duration, easing)
    local info = TweenInfo.new(duration or 0.2, easing or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
                    tween(entry.Element, { [entry.Property] = targetColor }, 0.25)
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
    local currentUsername = localPlayer and localPlayer.Name or "samet009"

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
    NotificationContainer.Size = UDim2.new(0, 260, 1, -40)
    NotificationContainer.Position = UDim2.new(1, -280, 0, 20)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.ZIndex = 50
    NotificationContainer.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.Parent = NotificationContainer

    function Library:Notify(opt)
        opt = opt or {}
        local notifTitle = opt.Title or "notification"
        local content = opt.Content or ""
        local duration = opt.Duration or 3
        local iconId = resolveIcon(opt.Icon)

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(1, 0, 0, 0)
        NotifFrame.BackgroundTransparency = 1
        NotifFrame.BorderSizePixel = 0
        NotifFrame.ClipsDescendants = true
        NotifFrame.Parent = NotificationContainer
        bindTheme(NotifFrame, "BackgroundColor3", "MainBg")
        addStroke(NotifFrame, "Border")

        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 2, 1, 0)
        AccentBar.BorderSizePixel = 0
        bindTheme(AccentBar, "BackgroundColor3", "Accent")
        AccentBar.Parent = NotifFrame

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, iconId and -36 or -16, 0, 16)
        TitleLbl.Position = UDim2.new(0, iconId and 30 or 12, 0, 7)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Font = Enum.Font.RobotoMono
        TitleLbl.TextSize = 11
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Text = string.lower(notifTitle)
        bindTheme(TitleLbl, "TextColor3", "Accent")
        TitleLbl.Parent = NotifFrame

        if iconId then
            local IconImg = Instance.new("ImageLabel")
            IconImg.Size = UDim2.new(0, 14, 0, 14)
            IconImg.Position = UDim2.new(0, 10, 0, 8)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = iconId
            bindTheme(IconImg, "ImageColor3", "Accent")
            IconImg.Parent = NotifFrame
        end

        local ContentLbl = Instance.new("TextLabel")
        ContentLbl.Size = UDim2.new(1, -20, 0, 18)
        ContentLbl.Position = UDim2.new(0, 12, 0, 25)
        ContentLbl.BackgroundTransparency = 1
        ContentLbl.Font = Enum.Font.RobotoMono
        ContentLbl.TextSize = 10
        ContentLbl.TextXAlignment = Enum.TextXAlignment.Left
        ContentLbl.Text = content
        bindTheme(ContentLbl, "TextColor3", "TextLight")
        ContentLbl.Parent = NotifFrame

        tween(NotifFrame, { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 0 }, 0.25, Enum.EasingStyle.Back)

        task.delay(duration, function()
            local close = tween(NotifFrame, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }, 0.2)
            close.Completed:Connect(function() NotifFrame:Destroy() end)
        end)
    end

    local Watermark = Instance.new("Frame")
    Watermark.Name = "Watermark"
    Watermark.Size = UDim2.new(0, 0, 0, 24)
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
    WatermarkLabel.Size = UDim2.new(1, -16, 1, 0)
    WatermarkLabel.Position = UDim2.new(0, 8, 0, 0)
    WatermarkLabel.BackgroundTransparency = 1
    WatermarkLabel.Font = Enum.Font.RobotoMono
    WatermarkLabel.TextSize = 11
    WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
    WatermarkLabel.RichText = true
    bindTheme(WatermarkLabel, "TextColor3", "TextLight")
    WatermarkLabel.Parent = Watermark

    function Library:SetWatermark(text, visible)
        WatermarkLabel.Text = text
        Watermark.Visible = visible ~= false
        local textSize = WatermarkLabel.TextBounds.X
        tween(Watermark, { Size = UDim2.new(0, textSize + 20, 0, 24) }, 0.2)
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = UDim2.new(0, 640, 0, 420)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    bindTheme(MainFrame, "BackgroundColor3", "MainBg")
    addStroke(MainFrame, "Border")

    MainFrame.Size = UDim2.new(0, 640, 0, 0)
    tween(MainFrame, { Size = UDim2.new(0, 640, 0, 420) }, 0.35, Enum.EasingStyle.Quart)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 32)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.RobotoMono
    Title.TextSize = 13
    Title.RichText = true
    Title.Parent = MainFrame

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
            startPos = MainFrame.Position
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
            tween(MainFrame, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.05)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            if Library.Open then
                MainFrame.Visible = true
                tween(MainFrame, { Size = UDim2.new(0, 640, 0, 420) }, 0.25, Enum.EasingStyle.Quart)
            else
                local closeTw = tween(MainFrame, { Size = UDim2.new(0, 640, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
                closeTw.Completed:Connect(function()
                    if not Library.Open then MainFrame.Visible = false end
                end)
            end
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 165, 1, -32)
    Sidebar.Position = UDim2.new(0, 0, 0, 32)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    bindTheme(Sidebar, "BackgroundColor3", "SidebarBg")

    local SideBorder = Instance.new("Frame")
    SideBorder.Size = UDim2.new(0, 1, 1, 0)
    SideBorder.Position = UDim2.new(1, -1, 0, 0)
    SideBorder.BorderSizePixel = 0
    SideBorder.Parent = Sidebar
    bindTheme(SideBorder, "BackgroundColor3", "Border")

    local UserCard = Instance.new("Frame")
    UserCard.Name = "UserCard"
    UserCard.Size = UDim2.new(1, 0, 0, 44)
    UserCard.BackgroundTransparency = 1
    UserCard.Parent = Sidebar

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(0, 24, 0, 24)
    AvatarImg.Position = UDim2.new(0, 14, 0.5, -12)
    AvatarImg.BorderSizePixel = 0
    AvatarImg.Parent = UserCard
    bindTheme(AvatarImg, "BackgroundColor3", "BoxOff")
    addStroke(AvatarImg, "Border")

    if localPlayer then
        task.spawn(function()
            local thumb, isReady = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            if isReady and thumb then AvatarImg.Image = thumb end
        end)
    else
        AvatarImg.Image = Icons.user
        bindTheme(AvatarImg, "ImageColor3", "Muted")
    end

    local UserLabel = Instance.new("TextLabel")
    UserLabel.Size = UDim2.new(1, -50, 1, 0)
    UserLabel.Position = UDim2.new(0, 46, 0, 0)
    UserLabel.BackgroundTransparency = 1
    UserLabel.Font = Enum.Font.RobotoMono
    UserLabel.TextSize = 12
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserLabel.TextYAlignment = Enum.TextYAlignment.Center
    UserLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UserLabel.Text = currentUsername
    UserLabel.Parent = UserCard
    bindTheme(UserLabel, "TextColor3", "TextLight")

    local CardDivider = Instance.new("Frame")
    CardDivider.Size = UDim2.new(1, 0, 0, 1)
    CardDivider.Position = UDim2.new(0, 0, 1, -1)
    CardDivider.BorderSizePixel = 0
    CardDivider.Parent = UserCard
    bindTheme(CardDivider, "BackgroundColor3", "Border")

    local NavList = Instance.new("Frame")
    NavList.Name = "NavList"
    NavList.Size = UDim2.new(1, 0, 1, -45)
    NavList.Position = UDim2.new(0, 0, 0, 45)
    NavList.BackgroundTransparency = 1
    NavList.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Parent = NavList

    local NavPadding = Instance.new("UIPadding")
    NavPadding.PaddingTop = UDim.new(0, 8)
    NavPadding.PaddingLeft = UDim.new(0, 14)
    NavPadding.Parent = NavList

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -165, 1, -32)
    ContentArea.Position = UDim2.new(0, 165, 0, 32)
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainFrame
    bindTheme(ContentArea, "BackgroundColor3", "MainBg")

    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 16)
    ContentPadding.PaddingBottom = UDim.new(0, 16)
    ContentPadding.PaddingLeft = UDim.new(0, 16)
    ContentPadding.PaddingRight = UDim.new(0, 16)
    ContentPadding.Parent = ContentArea

    local WindowObj = {
        _tabs = {},
        _subTabs = {},
        _orderCount = 0,
        _firstPage = nil,
    }

    function WindowObj:CreateTab(tabName, iconInput)
        WindowObj._orderCount = WindowObj._orderCount + 1
        local iconId = resolveIcon(iconInput)

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Size = UDim2.new(1, -14, 0, 20)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Font = Enum.Font.RobotoMono
        TabBtn.TextSize = 12
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.TextYAlignment = Enum.TextYAlignment.Center
        TabBtn.Text = (iconId and "      " or "") .. string.lower(tabName)
        TabBtn.LayoutOrder = WindowObj._orderCount
        TabBtn.Parent = NavList
        bindTheme(TabBtn, "TextColor3", "Muted")

        local IconImg
        if iconId then
            IconImg = Instance.new("ImageLabel")
            IconImg.Size = UDim2.new(0, 13, 0, 13)
            IconImg.Position = UDim2.new(0, 0, 0.5, -6)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = iconId
            bindTheme(IconImg, "ImageColor3", "Muted")
            IconImg.Parent = TabBtn
        end

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
            Icon = IconImg,
            SubTabs = {},
        }

        function TabObj:CreateSubTab(subName, isLastSubTab, subIconInput)
            WindowObj._orderCount = WindowObj._orderCount + 1
            local prefix = isLastSubTab and "└ " or "├ "
            local subIconId = resolveIcon(subIconInput)

            local SubBtn = Instance.new("TextButton")
            SubBtn.Name = "Sub_" .. subName
            SubBtn.Size = UDim2.new(1, -14, 0, 18)
            SubBtn.BackgroundTransparency = 1
            SubBtn.Font = Enum.Font.RobotoMono
            SubBtn.TextSize = 12
            SubBtn.TextXAlignment = Enum.TextXAlignment.Left
            SubBtn.TextYAlignment = Enum.TextYAlignment.Center
            SubBtn.Text = prefix .. (subIconId and "   " or "") .. string.lower(subName)
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
            LeftCol.Size = UDim2.new(0.5, -6, 1, 0)
            LeftCol.Position = UDim2.new(0, 0, 0, 0)
            LeftCol.BorderSizePixel = 0
            LeftCol.Parent = Page
            bindTheme(LeftCol, "BackgroundColor3", "SidebarBg")
            addStroke(LeftCol, "Border")

            local RightCol = Instance.new("Frame")
            RightCol.Name = "RightColumn"
            RightCol.Size = UDim2.new(0.5, -6, 1, 0)
            RightCol.Position = UDim2.new(0.5, 6, 0, 0)
            RightCol.BorderSizePixel = 0
            RightCol.Parent = Page
            bindTheme(RightCol, "BackgroundColor3", "SidebarBg")
            addStroke(RightCol, "Border")

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
                    if otherTab.Icon then
                        tween(otherTab.Icon, { ImageColor3 = Library.CurrentTheme.Muted }, 0.15)
                    end
                end

                tween(TabBtn, { TextColor3 = Library.CurrentTheme.Accent }, 0.15)
                AccentBar.Visible = true
                if IconImg then tween(IconImg, { ImageColor3 = Library.CurrentTheme.Accent }, 0.15) end

                tween(SubBtn, { TextColor3 = Library.CurrentTheme.Accent }, 0.15)
                Page.Visible = true
                Page.Position = UDim2.new(0, 6, 0, 0)
                tween(Page, { Position = UDim2.new(0, 0, 0, 0) }, 0.22, Enum.EasingStyle.Quart)
            end

            SubBtn.MouseButton1Click:Connect(activate)

            if not WindowObj._firstPage then
                WindowObj._firstPage = activate
                task.defer(activate)
            end

            table.insert(WindowObj._subTabs, SubObj)
            table.insert(TabObj.SubTabs, SubObj)

            local function buildSection(parentCol, titleText, headerIconInput)
                local iconAsset = resolveIcon(headerIconInput)

                local TitleContainer = Instance.new("Frame")
                TitleContainer.Size = UDim2.new(1, -20, 0, 20)
                TitleContainer.Position = UDim2.new(0, 12, 0, 6)
                TitleContainer.BackgroundTransparency = 1
                TitleContainer.Parent = parentCol

                if iconAsset then
                    local SIcon = Instance.new("ImageLabel")
                    SIcon.Size = UDim2.new(0, 12, 0, 12)
                    SIcon.Position = UDim2.new(0, 0, 0.5, -6)
                    SIcon.BackgroundTransparency = 1
                    SIcon.Image = iconAsset
                    bindTheme(SIcon, "ImageColor3", "Muted")
                    SIcon.Parent = TitleContainer
                end

                local TitleLbl = Instance.new("TextLabel")
                TitleLbl.Size = UDim2.new(1, iconAsset and -18 or 0, 1, 0)
                TitleLbl.Position = UDim2.new(0, iconAsset and 18 or 0, 0, 0)
                TitleLbl.BackgroundTransparency = 1
                TitleLbl.Font = Enum.Font.RobotoMono
                TitleLbl.TextSize = 11
                TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                TitleLbl.TextYAlignment = Enum.TextYAlignment.Center
                TitleLbl.Text = string.lower(titleText)
                bindTheme(TitleLbl, "TextColor3", "Muted")
                TitleLbl.Parent = TitleContainer

                local Scroll = Instance.new("ScrollingFrame")
                Scroll.Name = "ListScroll"
                Scroll.Size = UDim2.new(1, -16, 1, -36)
                Scroll.Position = UDim2.new(0, 10, 0, 30)
                Scroll.BackgroundTransparency = 1
                Scroll.BorderSizePixel = 0
                Scroll.ScrollBarThickness = 2
                Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                Scroll.Parent = parentCol
                bindTheme(Scroll, "ScrollBarImageColor3", "Border")

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Padding = UDim.new(0, 8)
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
                    Box.Size = UDim2.new(0, 11, 0, 11)
                    Box.Position = UDim2.new(0, 0, 0.5, -5)
                    Box.BackgroundColor3 = state and Library.CurrentTheme.Accent or Library.CurrentTheme.BoxOff
                    Box.BorderSizePixel = 0
                    Box.Parent = ToggleBtn
                    addStroke(Box, "Border")

                    local CheckMark = Instance.new("ImageLabel")
                    CheckMark.Size = UDim2.new(0, 9, 0, 9)
                    CheckMark.Position = UDim2.new(0.5, -4, 0.5, -4)
                    CheckMark.BackgroundTransparency = 1
                    CheckMark.Image = Icons.check
                    CheckMark.ImageColor3 = Library.CurrentTheme.MainBg
                    CheckMark.ImageTransparency = state and 0 or 1
                    CheckMark.Parent = Box

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0.65, 0, 1, 0)
                    Label.Position = UDim2.new(0, 20, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.RobotoMono
                    Label.TextSize = 11
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.TextYAlignment = Enum.TextYAlignment.Center
                    Label.Text = string.lower(opt.Name or "toggle")
                    bindTheme(Label, "TextColor3", "TextLight")
                    Label.Parent = ToggleBtn

                    local function update()
                        local targetBg = state and Library.CurrentTheme.Accent or Library.CurrentTheme.BoxOff
                        tween(Box, { BackgroundColor3 = targetBg }, 0.15)
                        tween(CheckMark, { ImageTransparency = state and 0 or 1 }, 0.12)
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
                        KeyBtn.Size = UDim2.new(0, 42, 0, 14)
                        KeyBtn.Position = UDim2.new(1, -42, 0.5, -7)
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
                    SliderFrame.Size = UDim2.new(1, -4, 0, 26)
                    SliderFrame.BackgroundTransparency = 1
                    SliderFrame.Parent = Scroll

                    local Title = Instance.new("TextLabel")
                    Title.Size = UDim2.new(1, 0, 0, 14)
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
                    Bar.Position = UDim2.new(0, 0, 0, 18)
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
                    DropFrame.Size = UDim2.new(1, -4, 0, 38)
                    DropFrame.BackgroundTransparency = 1
                    DropFrame.ClipsDescendants = false
                    DropFrame.ZIndex = 5
                    DropFrame.Parent = Scroll

                    local Title = Instance.new("TextLabel")
                    Title.Size = UDim2.new(1, 0, 0, 14)
                    Title.BackgroundTransparency = 1
                    Title.Font = Enum.Font.RobotoMono
                    Title.TextSize = 11
                    Title.TextXAlignment = Enum.TextXAlignment.Left
                    Title.TextYAlignment = Enum.TextYAlignment.Center
                    Title.Text = string.lower(opt.Name or "dropdown")
                    bindTheme(Title, "TextColor3", "Muted")
                    Title.Parent = DropFrame

                    local Box = Instance.new("TextButton")
                    Box.Size = UDim2.new(1, 0, 0, 20)
                    Box.Position = UDim2.new(0, 0, 0, 17)
                    Box.BorderSizePixel = 0
                    Box.Font = Enum.Font.RobotoMono
                    Box.TextSize = 11
                    Box.TextXAlignment = Enum.TextXAlignment.Left
                    Box.Text = "  " .. tostring(selected)
                    Box.ZIndex = 6
                    Box.Parent = DropFrame
                    bindTheme(Box, "BackgroundColor3", "BoxOff")
                    bindTheme(Box, "TextColor3", "TextLight")
                    addStroke(Box, "Border")

                    local Arrow = Instance.new("ImageLabel")
                    Arrow.Size = UDim2.new(0, 10, 0, 10)
                    Arrow.Position = UDim2.new(1, -14, 0.5, -5)
                    Arrow.BackgroundTransparency = 1
                    Arrow.Image = Icons.chevron
                    Arrow.ZIndex = 7
                    bindTheme(Arrow, "ImageColor3", "Muted")
                    Arrow.Parent = Box

                    local DropList = Instance.new("Frame")
                    DropList.Size = UDim2.new(1, 0, 0, 0)
                    DropList.Position = UDim2.new(0, 0, 1, 2)
                    DropList.BorderSizePixel = 0
                    DropList.Visible = false
                    DropList.ZIndex = 20
                    DropList.ClipsDescendants = true
                    DropList.Parent = Box
                    bindTheme(DropList, "BackgroundColor3", "SidebarBg")
                    addStroke(DropList, "Border")

                    local DropScroll = Instance.new("ScrollingFrame")
                    DropScroll.Size = UDim2.new(1, 0, 1, 0)
                    DropScroll.BackgroundTransparency = 1
                    DropScroll.BorderSizePixel = 0
                    DropScroll.ScrollBarThickness = 2
                    DropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    DropScroll.ZIndex = 21
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
                            ItemBtn.ZIndex = 22
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
                                tween(Arrow, { Rotation = 0 }, 0.2)
                                local closeTw = tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
                                closeTw.Completed:Connect(function() DropList.Visible = false end)
                            end)
                        end
                    end

                    Box.MouseButton1Click:Connect(function()
                        isOpen = not isOpen
                        tween(Arrow, { Rotation = isOpen and 180 or 0 }, 0.2)
                        if isOpen then
                            populate()
                            DropList.Visible = true
                            local targetHeight = math.min(#items * 20 + 4, 100)
                            tween(DropList, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.25, Enum.EasingStyle.Quart)
                        else
                            local closeTw = tween(DropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart)
                            closeTw.Completed:Connect(function() DropList.Visible = false end)
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
                    PickerFrame.Size = UDim2.new(1, -4, 0, 18)
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
                    bindTheme(Label, "TextColor3", "TextLight")
                    Label.Parent = PickerFrame

                    local Swatch = Instance.new("TextButton")
                    Swatch.Size = UDim2.new(0, 24, 0, 12)
                    Swatch.Position = UDim2.new(1, -24, 0.5, -6)
                    Swatch.BackgroundColor3 = currentColor
                    Swatch.BorderSizePixel = 0
                    Swatch.Text = ""
                    Swatch.Parent = PickerFrame
                    addStroke(Swatch, "Border")

                    local palette = {
                        Color3.fromRGB(168, 255, 62),
                        Color3.fromRGB(255, 65, 84),
                        Color3.fromRGB(60, 165, 255),
                        Color3.fromRGB(185, 95, 255),
                        Color3.fromRGB(255, 185, 55),
                        Color3.fromRGB(240, 240, 245),
                    }
                    local palIdx = 1

                    Swatch.MouseButton1Click:Connect(function()
                        palIdx = (palIdx % #palette) + 1
                        currentColor = palette[palIdx]
                        tween(Swatch, { BackgroundColor3 = currentColor }, 0.15)
                        if flag then Library.Flags[flag] = currentColor end
                        callback(currentColor)
                    end)
                end

                function Section:AddTextBox(opt)
                    opt = opt or {}
                    local flag = opt.Flag or opt.Name
                    local placeholder = opt.Placeholder or "type here..."
                    local callback = opt.Callback or function() end

                    local BoxFrame = Instance.new("Frame")
                    BoxFrame.Size = UDim2.new(1, -4, 0, 38)
                    BoxFrame.BackgroundTransparency = 1
                    BoxFrame.Parent = Scroll

                    local Title = Instance.new("TextLabel")
                    Title.Size = UDim2.new(1, 0, 0, 14)
                    Title.BackgroundTransparency = 1
                    Title.Font = Enum.Font.RobotoMono
                    Title.TextSize = 11
                    Title.TextXAlignment = Enum.TextXAlignment.Left
                    Title.TextYAlignment = Enum.TextYAlignment.Center
                    Title.Text = string.lower(opt.Name or "input")
                    bindTheme(Title, "TextColor3", "Muted")
                    Title.Parent = BoxFrame

                    local Input = Instance.new("TextBox")
                    Input.Size = UDim2.new(1, 0, 0, 20)
                    Input.Position = UDim2.new(0, 0, 0, 17)
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
                    bindTheme(Btn, "TextColor3", "TextLight")
                    addStroke(Btn, "Border")

                    Btn.MouseEnter:Connect(function()
                        tween(Btn, { BackgroundColor3 = Library.CurrentTheme.Hover }, 0.12)
                    end)
                    Btn.MouseLeave:Connect(function()
                        tween(Btn, { BackgroundColor3 = Library.CurrentTheme.BoxOff }, 0.12)
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

            function SubObj:CreateLeftSection(titleText, headerIconInput)
                return buildSection(LeftCol, titleText, headerIconInput)
            end

            function SubObj:CreateRightSection(titleText, headerIconInput)
                return buildSection(RightCol, titleText, headerIconInput)
            end

            return SubObj
        end

        table.insert(WindowObj._tabs, TabObj)
        return TabObj
    end

    function WindowObj:CreateThemeTab()
        local SettingsTab = WindowObj:CreateTab("settings", Icons.settings)
        local ThemeSub = SettingsTab:CreateSubTab("theme", true, Icons.palette)
        local LeftSec = ThemeSub:CreateLeftSection("theme selection", Icons.palette)
        local RightSec = ThemeSub:CreateRightSection("menu settings", Icons.sliders)

        LeftSec:AddDropdown({
            Name = "color preset",
            Options = { "Fluence", "Crimson", "Azure", "Amethyst", "Monochrome" },
            Default = "Fluence",
            Callback = function(themeName)
                Library:SetTheme(themeName)
                Library:Notify({
                    Title = "theme",
                    Content = "Applied " .. themeName .. " preset.",
                    Icon = Icons.check,
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
                    SidebarBg  = Library.CurrentTheme.SidebarBg,
                    SectionBg  = Library.CurrentTheme.SectionBg,
                    Border     = Library.CurrentTheme.Border,
                    Accent     = newColor,
                    AccentDark = newColor,
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
            Name = "copy join script",
            Callback = function()
                if setclipboard then
                    setclipboard("print('fluence.lua loaded!')")
                    Library:Notify({
                        Title = "clipboard",
                        Content = "Copied to clipboard.",
                        Icon = Icons.check,
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
