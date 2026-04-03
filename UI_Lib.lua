-- open sourced thanks to fsploit for this
-- fixed by me
repeat task.wait() until game:IsLoaded()

local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer.PlayerGui

local DefaultTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local Library = {
    Flags      = {},
    Components = {},
}

local function IsClick(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
end

local function IsTouch(input)
    return input.UserInputType == Enum.UserInputType.Touch
end

local function IsMoveInput(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

local function ConnectButton(btn, fn)
    btn.MouseButton1Click:Connect(fn)
    btn.TouchTap:Connect(fn)
end

function Library:Drag(handle, moveTarget)
    moveTarget = moveTarget or handle
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    handle.InputBegan:Connect(function(input)
        if IsClick(input) or IsTouch(input) then
            dragging  = true
            dragStart = input.Position
            startPos  = moveTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and IsMoveInput(input) then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:UpdateComponents()
    for _, comp in pairs(Library.Components) do
        if not comp.obj then continue end
        if comp.type == "toggle" then
            comp.obj:Toggle(Library.Flags[comp.flag], true)
        elseif comp.type == "module_expanded" then
            comp.obj:Toggle(Library.Flags[comp.flag], true)
        elseif comp.type == "mini_toggle" and comp.obj.Set then
            comp.obj:Set(Library.Flags[comp.flag])
        elseif comp.type == "dropdown" and comp.obj.Select then
            comp.obj:Select(Library.Flags[comp.flag], true)
        elseif comp.type == "slider" and comp.obj.Set then
            comp.obj:Set(Library.Flags[comp.flag])
        elseif comp.type == "colorpicker" and comp.obj.SetColor then
            comp.obj:SetColor(Library.Flags[comp.flag])
        end
    end
end

function Library:SaveConfig(name)
    if name and name ~= "" then
        writefile("Byte/Configs/" .. name .. ".lua", HttpService:JSONEncode(Library.Flags))
    end
end

function Library:LoadConfig(name)
    if name and name ~= "" and isfile("Byte/Configs/" .. name .. ".lua") then
        Library.Flags = HttpService:JSONDecode(readfile("Byte/Configs/" .. name .. ".lua"))
        Library:UpdateComponents()
    end
end

function Library:DeleteConfig(name)
    if name and name ~= "" and isfile("Byte/Configs/" .. name .. ".lua") then
        delfile("Byte/Configs/" .. name .. ".lua")
    end
end

if not isfolder("Byte")         then makefolder("Byte") end
if not isfolder("Byte/Configs") then makefolder("Byte/Configs") end

Library.MobileGui                = Instance.new("ScreenGui", RunService:IsStudio() and PlayerGui or CoreGui)
Library.MobileGui.Name           = "Mobile_Gui"
Library.MobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Library.MobileButton                    = Instance.new("TextButton", Library.MobileGui)
Library.MobileButton.Name               = "Mobile"
Library.MobileButton.BorderSizePixel    = 0
Library.MobileButton.Modal              = false
Library.MobileButton.AutoButtonColor    = false
Library.MobileButton.TextSize           = 14
Library.MobileButton.TextColor3         = Color3.fromRGB(0, 0, 0)
Library.MobileButton.BackgroundColor3   = Color3.fromRGB(28, 29, 34)
Library.MobileButton.FontFace           = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
Library.MobileButton.Size               = UDim2.new(0, 122, 0, 38)
Library.MobileButton.BorderColor3       = Color3.fromRGB(0, 0, 0)
Library.MobileButton.Text               = ""
Library.MobileButton.Position           = UDim2.new(0.021, -4, 0.918, -5)
Instance.new("UICorner", Library.MobileButton).CornerRadius = UDim.new(0, 13)

local MobileShadow                    = Instance.new("ImageLabel", Library.MobileButton)
MobileShadow.ZIndex                   = 0
MobileShadow.BorderSizePixel          = 0
MobileShadow.BackgroundColor3         = Color3.fromRGB(255, 255, 255)
MobileShadow.ImageTransparency        = 0.2
MobileShadow.AnchorPoint              = Vector2.new(0.5, 0.5)
MobileShadow.Image                    = "rbxassetid://17183270335"
MobileShadow.Size                     = UDim2.new(0, 144, 0, 58)
MobileShadow.BorderColor3             = Color3.fromRGB(0, 0, 0)
MobileShadow.BackgroundTransparency   = 1
MobileShadow.Name                     = "Shadow"
MobileShadow.Position                 = UDim2.new(0.5, 0, 0.5, 0)

local MobileIcon                    = Instance.new("ImageLabel", Library.MobileButton)
MobileIcon.BorderSizePixel          = 0
MobileIcon.BackgroundColor3         = Color3.fromRGB(255, 255, 255)
MobileIcon.AnchorPoint              = Vector2.new(0.5, 0.5)
MobileIcon.Image                    = "rbxassetid://10709810463"
MobileIcon.Size                     = UDim2.new(0, 15, 0, 15)
MobileIcon.BorderColor3             = Color3.fromRGB(0, 0, 0)
MobileIcon.BackgroundTransparency   = 1
MobileIcon.Name                     = "Icon"
MobileIcon.Position                 = UDim2.new(0.5, 0, 0.5, 0)

function Library.Add_Window(title)
    local Gui = {
        Tabs        = {},
        CurrentTab  = nil,
        _defaultTab = nil,
    }

    local function BuildHeader(parent, name)
        local Frame = Instance.new("Frame", parent)
        Frame.BorderSizePixel        = 0
        Frame.BackgroundColor3       = Color3.fromRGB(27, 27, 27)
        Frame.ClipsDescendants       = true
        Frame.Size                   = UDim2.new(0, 237, 0, 28)
        Frame.BorderColor3           = Color3.fromRGB(0, 0, 0)
        Frame.Name                   = "Module"
        Frame.BackgroundTransparency = 0.5
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

        local Header = Instance.new("ImageButton", Frame)
        Header.BorderSizePixel        = 0
        Header.ImageTransparency      = 1
        Header.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        Header.Image                  = "rbxassetid://85806357619289"
        Header.Size                   = UDim2.new(0, 237, 0, 28)
        Header.BackgroundTransparency = 1
        Header.Name                   = "Header"
        Header.BorderColor3           = Color3.fromRGB(0, 0, 0)
        Header.AutoButtonColor        = false

        local Arrow = Instance.new("ImageLabel", Header)
        Arrow.BorderSizePixel        = 0
        Arrow.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        Arrow.ImageTransparency      = 0.5
        Arrow.Image                  = "rbxassetid://119990362562133"
        Arrow.Size                   = UDim2.new(0, 11, 0, 11)
        Arrow.BorderColor3           = Color3.fromRGB(0, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Rotation               = 0
        Arrow.Name                   = "Arrow"
        Arrow.Position               = UDim2.new(0.9, 0, 0.286, 0)

        local KeyBtn = Instance.new("TextButton", Header)
        KeyBtn.BorderSizePixel        = 0
        KeyBtn.AutoButtonColor        = false
        KeyBtn.TextSize               = 14
        KeyBtn.TextColor3             = Color3.fromRGB(0, 0, 0)
        KeyBtn.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        KeyBtn.FontFace               = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular)
        KeyBtn.AnchorPoint            = Vector2.new(0, 0.5)
        KeyBtn.Size                   = UDim2.new(0, 33, 0, 28)
        KeyBtn.BackgroundTransparency = 1
        KeyBtn.Name                   = "Keybind"
        KeyBtn.BorderColor3           = Color3.fromRGB(0, 0, 0)
        KeyBtn.Text                   = ""
        KeyBtn.Position               = UDim2.new(0, 0, 0.5, 0)

        local KeyBg = Instance.new("Frame", KeyBtn)
        KeyBg.BorderSizePixel        = 0
        KeyBg.BackgroundColor3       = Color3.fromRGB(63, 63, 63)
        KeyBg.AnchorPoint            = Vector2.new(0.5, 0.5)
        KeyBg.Size                   = UDim2.new(0, 20, 0, 20)
        KeyBg.Position               = UDim2.new(0.5, 0, 0.5, 0)
        KeyBg.BorderColor3           = Color3.fromRGB(0, 0, 0)
        KeyBg.Name                   = "Background"
        KeyBg.BackgroundTransparency = 0.5
        Instance.new("UICorner", KeyBg).CornerRadius = UDim.new(0, 4)

        local KeyLbl = Instance.new("TextLabel", KeyBg)
        KeyLbl.BorderSizePixel        = 0
        KeyLbl.TextTransparency       = 0.5
        KeyLbl.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        KeyLbl.TextSize               = 10
        KeyLbl.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        KeyLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
        KeyLbl.BackgroundTransparency = 1
        KeyLbl.AnchorPoint            = Vector2.new(0.5, 0.5)
        KeyLbl.Size                   = UDim2.new(0, 12, 0, 12)
        KeyLbl.Visible                = false
        KeyLbl.BorderColor3           = Color3.fromRGB(0, 0, 0)
        KeyLbl.Text                   = "R"
        KeyLbl.Name                   = "String"
        KeyLbl.Position               = UDim2.new(0.5, 0, 0.5, 0)
        local kc = Instance.new("UITextSizeConstraint", KeyLbl)
        kc.MaxTextSize = 11; kc.MinTextSize = 11

        local DelIcon = Instance.new("ImageLabel", KeyBg)
        DelIcon.BorderSizePixel        = 0
        DelIcon.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        DelIcon.AnchorPoint            = Vector2.new(0.5, 0.5)
        DelIcon.Image                  = "rbxassetid://114520037763143"
        DelIcon.Size                   = UDim2.new(0, 10, 0, 10)
        DelIcon.Visible                = false
        DelIcon.BorderColor3           = Color3.fromRGB(0, 0, 0)
        DelIcon.BackgroundTransparency = 1
        DelIcon.Name                   = "Delete"
        DelIcon.Position               = UDim2.new(0.5, 0, 0.5, 0)

        local EditIcon = Instance.new("ImageLabel", KeyBg)
        EditIcon.BorderSizePixel        = 0
        EditIcon.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        EditIcon.AnchorPoint            = Vector2.new(0.5, 0.5)
        EditIcon.Image                  = "rbxassetid://10734887784"
        EditIcon.Size                   = UDim2.new(0, 10, 0, 10)
        EditIcon.BorderColor3           = Color3.fromRGB(0, 0, 0)
        EditIcon.BackgroundTransparency = 1
        EditIcon.Name                   = "Edit"
        EditIcon.Position               = UDim2.new(0.5, 0, 0.5, 0)

        local TitleLbl = Instance.new("TextLabel", KeyBtn)
        TitleLbl.TextWrapped            = true
        TitleLbl.BorderSizePixel        = 0
        TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left
        TitleLbl.TextTransparency       = 0.5
        TitleLbl.TextScaled             = true
        TitleLbl.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        TitleLbl.TextSize               = 14
        TitleLbl.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
        TitleLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.AnchorPoint            = Vector2.new(0, 0.5)
        TitleLbl.Size                   = UDim2.new(0, 156, 0, 12)
        TitleLbl.BorderColor3           = Color3.fromRGB(0, 0, 0)
        TitleLbl.Text                   = name
        TitleLbl.Name                   = "Title"
        TitleLbl.Position               = UDim2.new(1, 0, 0.5, 0)
        local tc = Instance.new("UITextSizeConstraint", TitleLbl)
        tc.MaxTextSize = 12; tc.MinTextSize = 12

        return Frame, Header, Arrow
    end

    local function BuildMiniToggle(parent, labelText, layoutOrder, flagKey)
        local TW = 28
        local TH = 12
        local CD = 6

        if Library.Flags[flagKey] == nil then
            Library.Flags[flagKey] = false
        end

        local Row = Instance.new("Frame", parent)
        Row.Name                  = labelText .. "_MiniRow"
        Row.Size                  = UDim2.new(0, 218, 0, 18)
        Row.BackgroundTransparency = 1
        Row.LayoutOrder           = layoutOrder or 0

        local LblEl = Instance.new("TextLabel", Row)
        LblEl.Size                  = UDim2.new(1, -(TW + 8), 1, 0)
        LblEl.BackgroundTransparency = 1
        LblEl.Text                  = labelText
        LblEl.TextXAlignment        = Enum.TextXAlignment.Left
        LblEl.TextColor3            = Color3.fromRGB(200, 200, 200)
        LblEl.TextSize              = 12
        LblEl.Font                  = Enum.Font.GothamMedium

        local Track = Instance.new("TextButton", Row)
        Track.AnchorPoint           = Vector2.new(1, 0.5)
        Track.Position              = UDim2.new(1, -4, 0.5, 0)
        Track.Size                  = UDim2.new(0, TW, 0, TH)
        Track.BackgroundColor3      = Color3.fromRGB(45, 45, 45)
        Track.BorderSizePixel       = 0
        Track.BackgroundTransparency = 0.2
        Track.Text                  = ""
        Track.AutoButtonColor       = false
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame", Track)
        Fill.AnchorPoint            = Vector2.new(0, 0.5)
        Fill.Position               = UDim2.new(0, 0, 0.5, 0)
        Fill.Size                   = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3       = Color3.fromRGB(120, 120, 120)
        Fill.BorderSizePixel        = 0
        Fill.BackgroundTransparency = 0.6
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local Circle = Instance.new("Frame", Track)
        Circle.AnchorPoint      = Vector2.new(0.5, 0.5)
        Circle.Size             = UDim2.new(0, CD, 0, CD)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BorderSizePixel  = 0
        Circle.ZIndex           = 3
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        local OffPos = UDim2.new(0, 4 + CD / 2, 0.5, 0)
        local OnPos  = UDim2.new(1, -(4 + CD / 2), 0.5, 0)

        local function SetVisual(state, instant)
            Library.Flags[flagKey] = state
            if instant then
                Fill.Size                   = state and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)
                Fill.BackgroundTransparency = state and 0 or 0.6
                Circle.Position             = state and OnPos or OffPos
                return
            end
            TweenService:Create(Fill, TweenInfo.new(0.18), {
                Size                   = state and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0),
                BackgroundTransparency = state and 0 or 0.6,
            }):Play()
            TweenService:Create(Circle, TweenInfo.new(0.18), {
                Position = state and OnPos or OffPos,
            }):Play()
        end

        SetVisual(Library.Flags[flagKey] == true, true)

        local Obj = {}

        function Obj:Set(state)
            state = not not state
            if Library.Flags[flagKey] == state then return end
            SetVisual(state, false)
        end

        function Obj:Toggle()
            self:Set(not Library.Flags[flagKey])
        end

        function Obj:Get()
            return Library.Flags[flagKey]
        end

        ConnectButton(Track, function()
            Obj:Toggle()
        end)

        return Obj, SetVisual
    end

    local function BuildHSVSlider(parent, labelText, layoutOrder)
        local Row = Instance.new("Frame", parent)
        Row.Name                   = labelText .. "_HSVRow"
        Row.BackgroundTransparency = 1
        Row.Size                   = UDim2.new(0, 206, 0, 28)
        Row.LayoutOrder            = layoutOrder

        local RowLbl = Instance.new("TextLabel", Row)
        RowLbl.Size                  = UDim2.new(0, 40, 0, 13)
        RowLbl.Position              = UDim2.new(0, 0, 0, 0)
        RowLbl.BackgroundTransparency = 1
        RowLbl.Text                  = labelText
        RowLbl.TextXAlignment        = Enum.TextXAlignment.Left
        RowLbl.TextColor3            = Color3.fromRGB(180, 180, 180)
        RowLbl.TextTransparency      = 0.3
        RowLbl.TextSize              = 11
        RowLbl.Font                  = Enum.Font.GothamMedium

        local ValLbl = Instance.new("TextLabel", Row)
        ValLbl.Size                  = UDim2.new(0, 30, 0, 13)
        ValLbl.Position              = UDim2.new(1, -30, 0, 0)
        ValLbl.BackgroundTransparency = 1
        ValLbl.TextXAlignment        = Enum.TextXAlignment.Right
        ValLbl.TextColor3            = Color3.fromRGB(255, 255, 255)
        ValLbl.TextTransparency      = 0.4
        ValLbl.TextSize              = 11
        ValLbl.Font                  = Enum.Font.GothamMedium

        local TrackBg = Instance.new("Frame", Row)
        TrackBg.Name                = "TrackBg"
        TrackBg.Size                = UDim2.new(1, 0, 0, 6)
        TrackBg.Position            = UDim2.new(0, 0, 0, 19)
        TrackBg.BorderSizePixel     = 0
        TrackBg.BackgroundColor3    = Color3.fromRGB(45, 45, 45)
        Instance.new("UICorner", TrackBg).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame", TrackBg)
        Fill.Name                  = "Fill"
        Fill.Size                  = UDim2.new(0, 0, 1, 0)
        Fill.BorderSizePixel       = 0
        Fill.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local TrackBtn = Instance.new("TextButton", TrackBg)
        TrackBtn.Size                  = UDim2.new(1, 0, 1, 0)
        TrackBtn.BackgroundTransparency = 1
        TrackBtn.Text                  = ""
        TrackBtn.BorderSizePixel       = 0
        TrackBtn.ZIndex                = 5
        TrackBtn.AutoButtonColor       = false

        return TrackBg, TrackBtn, Fill, ValLbl
    end

    local function BindSliderDrag(trackBg, trackBtn, onDrag)
        local dragging = false

        trackBtn.InputBegan:Connect(function(input)
            if IsClick(input) or IsTouch(input) then
                dragging = true
                onDrag(math.clamp(
                    (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X,
                    0, 1
                ))
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if IsMoveInput(input) then
                onDrag(math.clamp(
                    (input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X,
                    0, 1
                ))
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if IsClick(input) or IsTouch(input) then
                dragging = false
            end
        end)
    end

    Gui.ScreenGui = Instance.new("ScreenGui", RunService:IsStudio() and PlayerGui or CoreGui)
    Gui.ScreenGui.Name           = "Stream"
    Gui.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Gui.Container = Instance.new("Frame", Gui.ScreenGui)
    Gui.Container.Active                = true
    Gui.Container.BorderSizePixel       = 0
    Gui.Container.BackgroundColor3      = Color3.fromRGB(13, 13, 13)
    Gui.Container.AnchorPoint           = Vector2.new(0.5, 0.5)
    Gui.Container.Size                  = UDim2.new(0, 640, 0, 355)
    Gui.Container.Position              = UDim2.new(0.5, 0, 0.4935, 0)
    Gui.Container.BorderColor3          = Color3.fromRGB(0, 0, 0)
    Gui.Container.Name                  = "Container"
    Gui.Container.BackgroundTransparency = 0.1
    Instance.new("UICorner", Gui.Container).CornerRadius = UDim.new(0, 10)

    Gui.ContainerScale = Instance.new("UIScale", Gui.Container)

    Gui.HeaderBar = Instance.new("Frame", Gui.Container)
    Gui.HeaderBar.Active                = true
    Gui.HeaderBar.BorderSizePixel       = 0
    Gui.HeaderBar.BackgroundColor3      = Color3.fromRGB(28, 28, 28)
    Gui.HeaderBar.Size                  = UDim2.new(0, 624, 0, 24)
    Gui.HeaderBar.Position              = UDim2.new(0.0125, 0, 0.02254, 0)
    Gui.HeaderBar.BorderColor3          = Color3.fromRGB(0, 0, 0)
    Gui.HeaderBar.Name                  = "Header"
    Gui.HeaderBar.BackgroundTransparency = 0.5
    Instance.new("UICorner", Gui.HeaderBar).CornerRadius = UDim.new(0, 5)

    Library:Drag(Gui.HeaderBar, Gui.Container)

    Gui.TitleLabel = Instance.new("TextLabel", Gui.HeaderBar)
    Gui.TitleLabel.TextWrapped            = true
    Gui.TitleLabel.BorderSizePixel        = 0
    Gui.TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
    Gui.TitleLabel.TextScaled             = true
    Gui.TitleLabel.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    Gui.TitleLabel.TextSize               = 14
    Gui.TitleLabel.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
    Gui.TitleLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
    Gui.TitleLabel.BackgroundTransparency = 1
    Gui.TitleLabel.AnchorPoint            = Vector2.new(0, 0.5)
    Gui.TitleLabel.Size                   = UDim2.new(0, 78, 0, 12)
    Gui.TitleLabel.BorderColor3           = Color3.fromRGB(0, 0, 0)
    Gui.TitleLabel.Text                   = title
    Gui.TitleLabel.Name                   = "TitleText"
    Gui.TitleLabel.Position               = UDim2.new(0.044, 0, 0.5, 0)
    local titleC = Instance.new("UITextSizeConstraint", Gui.TitleLabel)
    titleC.MaxTextSize = 12; titleC.MinTextSize = 12

    Gui.SearchBar = Instance.new("Frame", Gui.HeaderBar)
    Gui.SearchBar.BorderSizePixel        = 0
    Gui.SearchBar.BackgroundColor3       = Color3.fromRGB(34, 34, 34)
    Gui.SearchBar.AnchorPoint            = Vector2.new(1, 0.5)
    Gui.SearchBar.Size                   = UDim2.new(0, 64, 0, 17)
    Gui.SearchBar.Position               = UDim2.new(0.995, 0, 0.5, 0)
    Gui.SearchBar.BorderColor3           = Color3.fromRGB(0, 0, 0)
    Gui.SearchBar.Name                   = "SearchBar"
    Gui.SearchBar.BackgroundTransparency = 0.5
    Instance.new("UICorner", Gui.SearchBar).CornerRadius = UDim.new(0, 4)

    local searchPad = Instance.new("UIPadding", Gui.SearchBar)
    searchPad.PaddingLeft = UDim.new(0, 9)

    Gui.SearchInput = Instance.new("TextBox", Gui.SearchBar)
    Gui.SearchInput.TextColor3             = Color3.fromRGB(255, 255, 255)
    Gui.SearchInput.PlaceholderColor3      = Color3.fromRGB(255, 255, 255)
    Gui.SearchInput.BorderSizePixel        = 0
    Gui.SearchInput.TextXAlignment         = Enum.TextXAlignment.Left
    Gui.SearchInput.TextWrapped            = true
    Gui.SearchInput.TextTransparency       = 0.5
    Gui.SearchInput.TextSize               = 10
    Gui.SearchInput.Name                   = "Input"
    Gui.SearchInput.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    Gui.SearchInput.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
    Gui.SearchInput.AnchorPoint            = Vector2.new(0, 0.5)
    Gui.SearchInput.ClearTextOnFocus       = false
    Gui.SearchInput.PlaceholderText        = "Search"
    Gui.SearchInput.Size                   = UDim2.new(0, 39, 0, 14)
    Gui.SearchInput.Position               = UDim2.new(0, 0, 0.5, 0)
    Gui.SearchInput.BorderColor3           = Color3.fromRGB(0, 0, 0)
    Gui.SearchInput.Text                   = ""
    Gui.SearchInput.BackgroundTransparency = 1
    local searchC = Instance.new("UITextSizeConstraint", Gui.SearchInput)
    searchC.MaxTextSize = 10; searchC.MinTextSize = 10

    local SearchIconBg = Instance.new("ImageLabel", Gui.SearchBar)
    SearchIconBg.BorderSizePixel        = 0
    SearchIconBg.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    SearchIconBg.AnchorPoint            = Vector2.new(1, 0.5)
    SearchIconBg.Image                  = "rbxassetid://72131122316767"
    SearchIconBg.Size                   = UDim2.new(0, 17, 0, 17)
    SearchIconBg.BorderColor3           = Color3.fromRGB(0, 0, 0)
    SearchIconBg.BackgroundTransparency = 1
    SearchIconBg.Name                   = "IconBG"
    SearchIconBg.Position               = UDim2.new(1, 0, 0.5, 0)

    local SearchIcon = Instance.new("ImageLabel", SearchIconBg)
    SearchIcon.BorderSizePixel          = 0
    SearchIcon.BackgroundColor3         = Color3.fromRGB(255, 255, 255)
    SearchIcon.AnchorPoint              = Vector2.new(0.5, 0.5)
    SearchIcon.Image                    = "rbxassetid://79243925523770"
    SearchIcon.Size                     = UDim2.new(0, 9, 0, 9)
    SearchIcon.BorderColor3             = Color3.fromRGB(0, 0, 0)
    SearchIcon.BackgroundTransparency   = 1
    SearchIcon.Name                     = "Icon"
    SearchIcon.Position                 = UDim2.new(0.5, 0, 0.5, 0)

    Gui.SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = Gui.SearchInput.Text:lower()
        for _, folder in pairs(Gui.Container:GetChildren()) do
            if folder:IsA("Folder") and folder.Name == "Sections" then
                for _, section in pairs(folder:GetChildren()) do
                    if section:IsA("ScrollingFrame") and section.Visible then
                        for _, child in pairs(section:GetChildren()) do
                            if child:IsA("Frame") and child.Name == "Module" then
                                local t = child:FindFirstChild("Title", true)
                                if t and t:IsA("TextLabel") then
                                    child.Visible = query == "" or t.Text:lower():find(query, 1, true) ~= nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    Gui.TabList = Instance.new("ScrollingFrame", Gui.Container)
    Gui.TabList.Active                     = true
    Gui.TabList.BorderSizePixel            = 0
    Gui.TabList.CanvasSize                 = UDim2.new(0, 0, 0.5, 0)
    Gui.TabList.BackgroundColor3           = Color3.fromRGB(255, 255, 255)
    Gui.TabList.Name                       = "Tabs"
    Gui.TabList.ScrollBarImageTransparency = 1
    Gui.TabList.AutomaticCanvasSize        = Enum.AutomaticSize.X
    Gui.TabList.Size                       = UDim2.new(0, 138, 0, 308)
    Gui.TabList.ScrollBarImageColor3       = Color3.fromRGB(0, 0, 0)
    Gui.TabList.Position                   = UDim2.new(0.0125, 0, 0.10986, 0)
    Gui.TabList.BorderColor3               = Color3.fromRGB(0, 0, 0)
    Gui.TabList.ScrollBarThickness         = 0
    Gui.TabList.BackgroundTransparency     = 1
    local tabLayout = Instance.new("UIListLayout", Gui.TabList)
    tabLayout.Padding   = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local WIN_TWEEN = 0.65

    local function ToggleWindow()
        if Gui.ScreenGui.Enabled then
            local t = TweenService:Create(Gui.ContainerScale,
                TweenInfo.new(WIN_TWEEN, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Scale = 0.01 })
            t:Play()
            t.Completed:Wait()
            Gui.ScreenGui.Enabled = false
        else
            Gui.ScreenGui.Enabled    = true
            Gui.ContainerScale.Scale = 0.01
            TweenService:Create(Gui.ContainerScale,
                TweenInfo.new(WIN_TWEEN, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Scale = 1 }):Play()
        end
    end

    ConnectButton(Library.MobileButton, ToggleWindow)

    function Gui.Create_Tab(options)
        local Tab = { Active = false }
        table.insert(Gui.Tabs, Tab)

        Tab.Button = Instance.new("TextButton", Gui.TabList)
        Tab.Button.BorderSizePixel        = 0
        Tab.Button.AutoButtonColor        = false
        Tab.Button.Text                   = ""
        Tab.Button.Size                   = UDim2.new(0, 138, 0, 27)
        Tab.Button.BackgroundColor3       = Color3.fromRGB(28, 28, 28)
        Tab.Button.BackgroundTransparency = 1
        Tab.Button.Name                   = "Tab"
        Instance.new("UICorner", Tab.Button).CornerRadius = UDim.new(0, 5)

        Tab.Icon = Instance.new("ImageLabel", Tab.Button)
        Tab.Icon.BackgroundTransparency = 1
        Tab.Icon.BorderSizePixel        = 0
        Tab.Icon.AnchorPoint            = Vector2.new(0, 0.5)
        Tab.Icon.Position               = UDim2.new(0.1, 0, 0.5, 0)
        Tab.Icon.Size                   = UDim2.new(0, 12, 0, 12)
        Tab.Icon.Image                  = options.icon or ""
        Tab.Icon.ImageColor3            = Color3.fromRGB(170, 170, 170)

        Tab.Title = Instance.new("TextLabel", Tab.Button)
        Tab.Title.BackgroundTransparency = 1
        Tab.Title.BorderSizePixel        = 0
        Tab.Title.AnchorPoint            = Vector2.new(0, 0.5)
        Tab.Title.Position               = UDim2.new(0.225, 0, 0.5, 0)
        Tab.Title.Size                   = UDim2.new(0, 75, 0, 12)
        Tab.Title.TextWrapped            = true
        Tab.Title.TextScaled             = true
        Tab.Title.TextXAlignment         = Enum.TextXAlignment.Left
        Tab.Title.Font                   = Enum.Font.GothamBold
        Tab.Title.TextSize               = 12
        Tab.Title.Text                   = options.name
        Tab.Title.TextColor3             = Color3.fromRGB(170, 170, 170)
        local ttc = Instance.new("UITextSizeConstraint", Tab.Title)
        ttc.MinTextSize = 12; ttc.MaxTextSize = 12

        function Tab:SetActive(state)
            Tab.Active = state
            if state then
                Tab.Button.BackgroundTransparency = 0.4
                Tab.Title.TextColor3              = Color3.fromRGB(200, 200, 200)
                Tab.Icon.ImageColor3              = Color3.fromRGB(255, 255, 255)
            else
                Tab.Button.BackgroundTransparency = 1
                Tab.Title.TextColor3              = Color3.fromRGB(170, 170, 170)
                Tab.Icon.ImageColor3              = Color3.fromRGB(170, 170, 170)
            end
        end

        function Tab:Activate()
            for _, t in ipairs(Gui.Tabs) do t:SetActive(false) end
            Tab:SetActive(true)
            Gui.CurrentTab = Tab
            for _, folder in pairs(Gui.Container:GetChildren()) do
                if folder:IsA("Folder") and folder.Name == "Sections" then
                    for _, section in pairs(folder:GetChildren()) do
                        if section:IsA("ScrollingFrame") then
                            section.Visible = false
                        end
                    end
                end
            end
            if Tab.Section then
                if Tab.Section.Left  then Tab.Section.Left.Visible  = true end
                if Tab.Section.Right then Tab.Section.Right.Visible = true end
            end
        end

        ConnectButton(Tab.Button, function() Tab:Activate() end)

        Tab:SetActive(false)
        if #Gui.Tabs == 1 then Tab:Activate() end

        function Tab.Create_Section()
            local Section = {}

            Section.Folder      = Instance.new("Folder", Gui.Container)
            Section.Folder.Name = "Sections"

            local function MakeSF(sfName, posX)
                local sf = Instance.new("ScrollingFrame", Section.Folder)
                sf.Active                     = true
                sf.BorderSizePixel            = 0
                sf.CanvasSize                 = UDim2.new(0, 0, 0, 0)
                sf.BackgroundColor3           = Color3.fromRGB(255, 255, 255)
                sf.Name                       = options.name .. "_" .. sfName
                sf.ScrollBarImageTransparency = 1
                sf.AutomaticCanvasSize        = Enum.AutomaticSize.Y
                sf.ScrollingDirection         = Enum.ScrollingDirection.Y
                sf.Size                       = UDim2.new(0, 237, 0, 306)
                sf.ScrollBarImageColor3       = Color3.fromRGB(0, 0, 0)
                sf.Position                   = UDim2.new(posX, 0, 0.11, 0)
                sf.BorderColor3               = Color3.fromRGB(0, 0, 0)
                sf.ScrollBarThickness         = 0
                sf.BackgroundTransparency     = 1
                sf.Visible                    = false
                local l = Instance.new("UIListLayout", sf)
                l.Padding   = UDim.new(0, 6)
                l.SortOrder = Enum.SortOrder.LayoutOrder
                return sf
            end

            Section.Left  = MakeSF("Left",  0.24)
            Section.Right = MakeSF("Right", 0.62)

            Tab.Section = {
                Folder = Section.Folder,
                Left   = Section.Left,
                Right  = Section.Right,
            }

            if Tab.Active then
                Section.Left.Visible  = true
                Section.Right.Visible = true
            end

            if Gui._defaultTab == Tab then
                Tab:Activate()
                Gui._defaultTab = nil
            end

            local function GetSide(side)
                return side == "left" and Section.Left or Section.Right
            end

            function Section.Create_Toggle(opts)
                local Toggle = { flag = opts.flag }

                if Library.Flags[Toggle.flag] == nil then
                    Library.Flags[Toggle.flag] = false
                end

                local Frame, Header, _ = BuildHeader(GetSide(opts.section), opts.name)
                Toggle.Frame  = Frame
                Toggle.Header = Header

                local function Refresh()
                    TweenService:Create(Toggle.Header, TweenInfo.new(0.2), {
                        ImageTransparency = Library.Flags[Toggle.flag] and 0.5 or 1,
                    }):Play()
                end

                function Toggle:Toggle(state, silent)
                    Library.Flags[self.flag] = (state == nil) and (not Library.Flags[self.flag]) or state
                    Refresh()
                    if not silent and opts.callback then
                        pcall(opts.callback, Library.Flags[self.flag])
                    end
                end

                Refresh()
                ConnectButton(Toggle.Header, function() Toggle:Toggle() end)

                table.insert(Library.Components, { type = "toggle", obj = Toggle, flag = Toggle.flag })
                return Toggle
            end

            function Section.Create_Module(opts)
                local Module = { flag = opts.flag }

                if Library.Flags[Module.flag] == nil then
                    Library.Flags[Module.flag] = false
                end

                local Frame, Header, Arrow = BuildHeader(GetSide(opts.section), opts.name)
                Module.Frame  = Frame
                Module.Header = Header
                Module.Arrow  = Arrow

                Module.Settings = Instance.new("Frame", Module.Frame)
                Module.Settings.BorderSizePixel        = 0
                Module.Settings.BackgroundColor3       = Color3.fromRGB(28, 28, 28)
                Module.Settings.AnchorPoint            = Vector2.new(0, 1)
                Module.Settings.ClipsDescendants       = true
                Module.Settings.Size                   = UDim2.new(0, 237, 0, 0)
                Module.Settings.Position               = UDim2.new(0, 0, 1, 0)
                Module.Settings.BorderColor3           = Color3.fromRGB(0, 0, 0)
                Module.Settings.Name                   = "Settings"
                Module.Settings.BackgroundTransparency = 1

                Module.SettingsLayout = Instance.new("UIListLayout", Module.Settings)
                Module.SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                Module.SettingsLayout.SortOrder           = Enum.SortOrder.LayoutOrder
                Module.SettingsLayout.Padding             = UDim.new(0, 4)

                local sp = Instance.new("UIPadding", Module.Settings)
                sp.PaddingTop    = UDim.new(0, 4)
                sp.PaddingBottom = UDim.new(0, 4)

                function Module:UpdateHeight()
                    if Library.Flags[Module.flag] then
                        local h = Module.SettingsLayout.AbsoluteContentSize.Y + 8
                        TweenService:Create(Module.Settings, TweenInfo.new(0.2), { Size = UDim2.new(0, 237, 0, h) }):Play()
                        TweenService:Create(Module.Frame,    TweenInfo.new(0.2), { Size = UDim2.new(0, 237, 0, 28 + h) }):Play()
                    else
                        TweenService:Create(Module.Settings, TweenInfo.new(0.2), { Size = UDim2.new(0, 237, 0, 0) }):Play()
                        TweenService:Create(Module.Frame,    TweenInfo.new(0.2), { Size = UDim2.new(0, 237, 0, 28) }):Play()
                    end
                end

                function Module:Toggle(state, silent)
                    Library.Flags[self.flag] = (state == nil) and (not Library.Flags[self.flag]) or state
                    if Library.Flags[Module.flag] then
                        TweenService:Create(Module.Header, TweenInfo.new(0.2), { ImageTransparency = 0.5 }):Play()
                        TweenService:Create(Module.Arrow,  TweenInfo.new(0.2), { Rotation = -90 }):Play()
                    else
                        TweenService:Create(Module.Header, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
                        TweenService:Create(Module.Arrow,  TweenInfo.new(0.2), { Rotation = 0 }):Play()
                    end
                    Module:UpdateHeight()
                    if not silent and opts.callback then
                        pcall(opts.callback, Library.Flags[self.flag])
                    end
                end

                Module:Toggle(Library.Flags[Module.flag], true)
                ConnectButton(Module.Header, function() Module:Toggle() end)

                function Module:Add_Label(opts)
                    local Row = Instance.new("Frame", Module.Settings)
                    Row.Name                   = "LabelRow"
                    Row.BackgroundTransparency = 1
                    Row.Size                   = UDim2.new(0, 218, 0, 16)
                    Row.LayoutOrder            = opts.layoutorder or 0

                    local LblText = Instance.new("TextLabel", Row)
                    LblText.BorderSizePixel        = 0
                    LblText.BackgroundTransparency = 1
                    LblText.Size                   = UDim2.new(1, 0, 1, 0)
                    LblText.TextXAlignment         = Enum.TextXAlignment.Left
                    LblText.TextColor3             = Color3.fromRGB(180, 180, 180)
                    LblText.TextTransparency       = 0.3
                    LblText.TextSize               = 12
                    LblText.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                    LblText.Text                   = opts.text or opts.name or ""
                    LblText.Name                   = "LabelText"
                    LblText.TextWrapped            = true
                    local lc = Instance.new("UITextSizeConstraint", LblText)
                    lc.MaxTextSize = 12; lc.MinTextSize = 12

                    local LabelObj = {}
                    function LabelObj:SetText(t) LblText.Text = t end
                    function LabelObj:GetText()  return LblText.Text end
                    return LabelObj
                end

                function Module:Add_Dropdown(opts)
                    local Drop = { Open = false }
                    local flag = opts.flag or opts.name
                    local PW   = 218
                    local TH   = 14
                    local HH   = 18
                    local OH   = 85

                    local Holder = Instance.new("Frame", Module.Settings)
                    Holder.Name                   = "DropdownHolder"
                    Holder.BackgroundTransparency = 1
                    Holder.Size                   = UDim2.new(0, PW, 0, TH + HH)
                    Holder.ClipsDescendants       = true
                    Holder.LayoutOrder            = opts.layoutorder or 0

                    local TitleLbl = Instance.new("TextLabel", Holder)
                    TitleLbl.Name                 = "Title"
                    TitleLbl.Size                 = UDim2.new(1, 0, 0, TH)
                    TitleLbl.BackgroundTransparency = 1
                    TitleLbl.TextXAlignment       = Enum.TextXAlignment.Left
                    TitleLbl.Text                 = opts.name
                    TitleLbl.TextSize             = 12
                    TitleLbl.TextTransparency     = 0.35
                    TitleLbl.TextColor3           = Color3.fromRGB(255, 255, 255)
                    TitleLbl.FontFace             = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

                    local Box = Instance.new("Frame", Holder)
                    Box.Name                  = "Box"
                    Box.Size                  = UDim2.new(0, PW, 0, HH)
                    Box.Position              = UDim2.new(0, 0, 0, TH)
                    Box.BackgroundTransparency = 1
                    Box.BorderSizePixel       = 0
                    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 5)

                    local BoxHeader = Instance.new("ImageButton", Box)
                    BoxHeader.Name                = "Header"
                    BoxHeader.Size                = UDim2.new(1, 0, 1, 0)
                    BoxHeader.BackgroundTransparency = 1
                    BoxHeader.BorderSizePixel     = 0
                    BoxHeader.Image               = "rbxassetid://101868605252082"
                    BoxHeader.ScaleType           = Enum.ScaleType.Slice
                    BoxHeader.SliceCenter         = Rect.new(6, 6, 6, 6)
                    BoxHeader.AutoButtonColor     = false

                    local ValueLbl = Instance.new("TextLabel", BoxHeader)
                    ValueLbl.Name                 = "Option"
                    ValueLbl.Size                 = UDim2.new(1, -24, 1, 0)
                    ValueLbl.Position             = UDim2.new(0, 8, 0, 0)
                    ValueLbl.BackgroundTransparency = 1
                    ValueLbl.TextXAlignment       = Enum.TextXAlignment.Left
                    ValueLbl.TextYAlignment       = Enum.TextYAlignment.Center
                    ValueLbl.TextSize             = 12
                    ValueLbl.TextTransparency     = 0.5
                    ValueLbl.TextColor3           = Color3.fromRGB(255, 255, 255)
                    ValueLbl.FontFace             = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

                    local DropArrow = Instance.new("ImageLabel", BoxHeader)
                    DropArrow.Name                = "Arrow"
                    DropArrow.Size                = UDim2.new(0, 10, 0, 10)
                    DropArrow.Position            = UDim2.new(1, -14, 0.5, -5)
                    DropArrow.BackgroundTransparency = 1
                    DropArrow.ImageTransparency   = 0.5
                    DropArrow.Image               = "rbxassetid://119990362562133"

                    local OptionsFrame = Instance.new("Frame", Box)
                    OptionsFrame.Name              = "Options"
                    OptionsFrame.Position          = UDim2.new(0, 0, 1, 4)
                    OptionsFrame.Size              = UDim2.new(1, 0, 0, 0)
                    OptionsFrame.BackgroundTransparency = 1
                    OptionsFrame.ClipsDescendants  = true

                    local OptionsBg = Instance.new("ImageLabel", OptionsFrame)
                    OptionsBg.Name                 = "Background"
                    OptionsBg.Size                 = UDim2.new(1, 0, 1, 0)
                    OptionsBg.BackgroundTransparency = 1
                    OptionsBg.Image                = "rbxassetid://101868605252082"
                    OptionsBg.ScaleType            = Enum.ScaleType.Slice
                    OptionsBg.SliceCenter          = Rect.new(6, 6, 6, 6)
                    OptionsBg.ZIndex               = 0
                    Instance.new("UICorner", OptionsBg).CornerRadius = UDim.new(0, 5)

                    local OptionsList = Instance.new("ScrollingFrame", OptionsFrame)
                    OptionsList.Name               = "List"
                    OptionsList.Size               = UDim2.new(1, -6, 0, OH)
                    OptionsList.Position           = UDim2.new(0, 3, 0, 3)
                    OptionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    OptionsList.ScrollBarThickness = 0
                    OptionsList.BackgroundTransparency = 1
                    OptionsList.BorderSizePixel    = 0
                    OptionsList.ZIndex             = 1
                    local ol = Instance.new("UIListLayout", OptionsList)
                    ol.HorizontalAlignment = Enum.HorizontalAlignment.Center

                    function Drop:Select(value, silent)
                        if not table.find(opts.options, value) then
                            value = opts.options[1]
                        end
                        ValueLbl.Text       = value
                        Library.Flags[flag] = value
                        if not silent and opts.callback then
                            pcall(opts.callback, value)
                        end
                    end

                    local function CloseDropdown()
                        Drop.Open = false
                        TweenService:Create(DropArrow,    TweenInfo.new(0.2), { Rotation = 0 }):Play()
                        TweenService:Create(OptionsFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()
                        Holder.Size = UDim2.new(0, PW, 0, TH + HH)
                        Module:UpdateHeight()
                    end

                    local function OpenDropdown()
                        Drop.Open = true
                        TweenService:Create(DropArrow,    TweenInfo.new(0.2), { Rotation = -90 }):Play()
                        TweenService:Create(OptionsFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, OH + 6) }):Play()
                        Holder.Size = UDim2.new(0, PW, 0, TH + HH + OH + 10)
                        Module:UpdateHeight()
                    end

                    ConnectButton(BoxHeader, function()
                        if Drop.Open then CloseDropdown() else OpenDropdown() end
                    end)

                    for _, opt in ipairs(opts.options) do
                        local Btn = Instance.new("TextButton", OptionsList)
                        Btn.Size                  = UDim2.new(1, -4, 0, 18)
                        Btn.BackgroundTransparency = 1
                        Btn.Text                  = opt
                        Btn.TextXAlignment        = Enum.TextXAlignment.Left
                        Btn.TextSize              = 12
                        Btn.TextTransparency      = 0.5
                        Btn.TextColor3            = Color3.fromRGB(255, 255, 255)
                        Btn.FontFace              = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
                        Btn.BorderSizePixel       = 0
                        Btn.ZIndex                = 2
                        Btn.AutoButtonColor       = false
                        ConnectButton(Btn, function()
                            Drop:Select(opt)
                            CloseDropdown()
                        end)
                    end

                    Drop:Select(Library.Flags[flag] or opts.default, true)
                    table.insert(Library.Components, { type = "dropdown", obj = Drop, flag = flag })
                    return Drop
                end

                function Module:Add_MiniToggle(opts)
                    local flag = opts.flag or opts.name or "mini_toggle"
                    if Library.Flags[flag] == nil then
                        Library.Flags[flag] = opts.default == nil and false or opts.default
                    end

                    local Obj, _ = BuildMiniToggle(Module.Settings, opts.name or "Toggle", opts.layoutorder or 0, flag)

                    if opts.callback then
                        local origSet = Obj.Set
                        function Obj:Set(state)
                            local prev = Library.Flags[flag]
                            origSet(self, state)
                            if Library.Flags[flag] ~= prev then
                                pcall(opts.callback, Library.Flags[flag])
                            end
                        end
                        local origToggle = Obj.Toggle
                        function Obj:Toggle()
                            origToggle(self)
                            pcall(opts.callback, Library.Flags[flag])
                        end
                    end

                    if opts.default and opts.callback then
                        task.defer(opts.callback, true)
                    end

                    table.insert(Library.Components, { type = "mini_toggle", obj = Obj, flag = flag })
                    return Obj
                end

                function Module:Add_Slider(opts)
                    local flag = opts.flag or opts.name
                    if Library.Flags[flag] == nil then
                        Library.Flags[flag] = opts.default or opts.min
                    end

                    local SliderFrame = Instance.new("Frame", Module.Settings)
                    SliderFrame.BackgroundTransparency = 1
                    SliderFrame.Size                   = UDim2.new(0, 218, 0, 35)
                    SliderFrame.LayoutOrder            = opts.layoutorder or 0

                    local SliderTitle = Instance.new("TextLabel", SliderFrame)
                    SliderTitle.Text                   = opts.name
                    SliderTitle.Size                   = UDim2.new(1, 0, 0, 15)
                    SliderTitle.BackgroundTransparency = 1
                    SliderTitle.TextXAlignment         = Enum.TextXAlignment.Left
                    SliderTitle.TextColor3             = Color3.fromRGB(200, 200, 200)
                    SliderTitle.Font                   = Enum.Font.GothamMedium
                    SliderTitle.TextSize               = 12

                    local SliderValue = Instance.new("TextLabel", SliderFrame)
                    SliderValue.Text                   = tostring(Library.Flags[flag])
                    SliderValue.Size                   = UDim2.new(1, 0, 0, 15)
                    SliderValue.BackgroundTransparency = 1
                    SliderValue.TextXAlignment         = Enum.TextXAlignment.Right
                    SliderValue.TextColor3             = Color3.fromRGB(255, 255, 255)
                    SliderValue.Font                   = Enum.Font.GothamMedium
                    SliderValue.TextSize               = 12

                    local BarBg = Instance.new("Frame", SliderFrame)
                    BarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    BarBg.Size             = UDim2.new(1, 0, 0, 6)
                    BarBg.Position         = UDim2.new(0, 0, 0, 24)
                    BarBg.BorderSizePixel  = 0
                    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

                    local BarFill = Instance.new("Frame", BarBg)
                    BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    BarFill.Size             = UDim2.new(0, 0, 1, 0)
                    BarFill.BorderSizePixel  = 0
                    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

                    local BarBtn = Instance.new("TextButton", BarBg)
                    BarBtn.Size                  = UDim2.new(1, 0, 1, 0)
                    BarBtn.BackgroundTransparency = 1
                    BarBtn.Text                  = ""
                    BarBtn.BorderSizePixel       = 0
                    BarBtn.ZIndex                = 5
                    BarBtn.AutoButtonColor       = false

                    local function UpdateSlider(inputX)
                        local pct = math.clamp(
                            (inputX - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X,
                            0, 1
                        )
                        local val = math.floor(((opts.max - opts.min) * pct) + opts.min)
                        BarFill.Size        = UDim2.new(pct, 0, 1, 0)
                        SliderValue.Text    = tostring(val)
                        Library.Flags[flag] = val
                        if opts.callback then pcall(opts.callback, val) end
                    end

                    local pct0 = (Library.Flags[flag] - opts.min) / (opts.max - opts.min)
                    BarFill.Size = UDim2.new(pct0, 0, 1, 0)

                    BindSliderDrag(BarBg, BarBtn, function(pct)
                        local val = math.floor(((opts.max - opts.min) * pct) + opts.min)
                        BarFill.Size        = UDim2.new(pct, 0, 1, 0)
                        SliderValue.Text    = tostring(val)
                        Library.Flags[flag] = val
                        if opts.callback then pcall(opts.callback, val) end
                    end)

                    local SliderObj = {}

                    function SliderObj:Set(val)
                        if type(val) ~= "number" then return end
                        val = math.clamp(val, opts.min, opts.max)
                        Library.Flags[flag] = val
                        local p = (val - opts.min) / (opts.max - opts.min)
                        BarFill.Size     = UDim2.new(p, 0, 1, 0)
                        SliderValue.Text = tostring(val)
                    end

                    SliderObj:Set(Library.Flags[flag])
                    table.insert(Library.Components, { type = "slider", obj = SliderObj, flag = flag })
                    return SliderObj
                end

                function Module:Add_ColorPicker(opts)
                    local CP = {
                        flag        = opts.flag,
                        enableFlag  = opts.flag .. "_enabled",
                        rainbowFlag = opts.flag .. "_rainbow",
                    }

                    if Library.Flags[CP.flag] == nil then
                        local def = opts.default or Color3.new(1, 1, 1)
                        Library.Flags[CP.flag] = { r = def.R, g = def.G, b = def.B }
                    end
                    if Library.Flags[CP.enableFlag]  == nil then Library.Flags[CP.enableFlag]  = opts.defaultEnabled ~= false end
                    if Library.Flags[CP.rainbowFlag] == nil then Library.Flags[CP.rainbowFlag] = false end

                    local function FlagsToColor()
                        local f = Library.Flags[CP.flag]
                        return type(f) == "table" and Color3.new(f.r or 1, f.g or 1, f.b or 1) or Color3.new(1, 1, 1)
                    end

                    local function ColorToFlags(c)
                        Library.Flags[CP.flag] = { r = c.R, g = c.G, b = c.B }
                    end

                    local cur   = FlagsToColor()
                    local H, S, V = Color3.toHSV(cur)

                    local CPRow = Instance.new("Frame", Module.Settings)
                    CPRow.BorderSizePixel        = 0
                    CPRow.BackgroundColor3       = Color3.fromRGB(27, 27, 27)
                    CPRow.ClipsDescendants       = true
                    CPRow.Size                   = UDim2.new(0, 218, 0, 28)
                    CPRow.BorderColor3           = Color3.fromRGB(0, 0, 0)
                    CPRow.Name                   = "ColorPickerRow"
                    CPRow.BackgroundTransparency = 0.5
                    CPRow.LayoutOrder            = opts.layoutorder or 0
                    Instance.new("UICorner", CPRow).CornerRadius = UDim.new(0, 5)

                    local CPHeader = Instance.new("ImageButton", CPRow)
                    CPHeader.BorderSizePixel        = 0
                    CPHeader.ImageTransparency      = 1
                    CPHeader.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                    CPHeader.Image                  = "rbxassetid://85806357619289"
                    CPHeader.Size                   = UDim2.new(0, 218, 0, 28)
                    CPHeader.BackgroundTransparency = 1
                    CPHeader.Name                   = "CPHeader"
                    CPHeader.AutoButtonColor        = false

                    local CPArrow = Instance.new("ImageLabel", CPHeader)
                    CPArrow.BorderSizePixel        = 0
                    CPArrow.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                    CPArrow.ImageTransparency      = 0.5
                    CPArrow.Image                  = "rbxassetid://119990362562133"
                    CPArrow.Size                   = UDim2.new(0, 11, 0, 11)
                    CPArrow.BorderColor3           = Color3.fromRGB(0, 0, 0)
                    CPArrow.BackgroundTransparency = 1
                    CPArrow.Rotation               = 0
                    CPArrow.Name                   = "Arrow"
                    CPArrow.Position               = UDim2.new(0.88, 0, 0.286, 0)

                    local Swatch = Instance.new("Frame", CPHeader)
                    Swatch.AnchorPoint       = Vector2.new(1, 0.5)
                    Swatch.Position          = UDim2.new(0.82, 0, 0.5, 0)
                    Swatch.Size              = UDim2.new(0, 16, 0, 10)
                    Swatch.BorderSizePixel   = 0
                    Swatch.BackgroundColor3  = FlagsToColor()
                    Swatch.Name              = "Swatch"
                    Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 3)

                    local CPTitle = Instance.new("TextLabel", CPHeader)
                    CPTitle.TextWrapped            = true
                    CPTitle.BorderSizePixel        = 0
                    CPTitle.TextXAlignment         = Enum.TextXAlignment.Left
                    CPTitle.TextTransparency       = 0.5
                    CPTitle.TextScaled             = true
                    CPTitle.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                    CPTitle.FontFace               = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                    CPTitle.TextColor3             = Color3.fromRGB(255, 255, 255)
                    CPTitle.BackgroundTransparency = 1
                    CPTitle.AnchorPoint            = Vector2.new(0, 0.5)
                    CPTitle.Size                   = UDim2.new(0, 110, 0, 12)
                    CPTitle.Text                   = opts.name
                    CPTitle.Name                   = "Title"
                    CPTitle.Position               = UDim2.new(0.06, 0, 0.5, 0)
                    local cptc = Instance.new("UITextSizeConstraint", CPTitle)
                    cptc.MaxTextSize = 12; cptc.MinTextSize = 12

                    local CPInner = Instance.new("Frame", CPRow)
                    CPInner.BorderSizePixel        = 0
                    CPInner.BackgroundColor3       = Color3.fromRGB(28, 28, 28)
                    CPInner.AnchorPoint            = Vector2.new(0, 1)
                    CPInner.ClipsDescendants       = true
                    CPInner.Size                   = UDim2.new(0, 218, 0, 0)
                    CPInner.Position               = UDim2.new(0, 0, 1, 0)
                    CPInner.BorderColor3           = Color3.fromRGB(0, 0, 0)
                    CPInner.Name                   = "CPInner"
                    CPInner.BackgroundTransparency = 1

                    local CPLayout = Instance.new("UIListLayout", CPInner)
                    CPLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    CPLayout.SortOrder           = Enum.SortOrder.LayoutOrder
                    CPLayout.Padding             = UDim.new(0, 4)

                    local cpPad = Instance.new("UIPadding", CPInner)
                    cpPad.PaddingTop    = UDim.new(0, 6)
                    cpPad.PaddingBottom = UDim.new(0, 6)

                    local cpOpen = false

                    local function UpdateCPHeight()
                        if cpOpen then
                            local h = CPLayout.AbsoluteContentSize.Y + 12
                            TweenService:Create(CPInner, TweenInfo.new(0.2), { Size = UDim2.new(0, 218, 0, h) }):Play()
                            local t = TweenService:Create(CPRow, TweenInfo.new(0.2), { Size = UDim2.new(0, 218, 0, 28 + h) })
                            t.Completed:Connect(function() Module:UpdateHeight() end)
                            t:Play()
                        else
                            TweenService:Create(CPInner, TweenInfo.new(0.2), { Size = UDim2.new(0, 218, 0, 0) }):Play()
                            local t = TweenService:Create(CPRow, TweenInfo.new(0.2), { Size = UDim2.new(0, 218, 0, 28) })
                            t.Completed:Connect(function() Module:UpdateHeight() end)
                            t:Play()
                        end
                    end

                    local function FireCallback()
                        if opts.callback then
                            pcall(opts.callback, {
                                color   = Color3.fromHSV(H, S, V),
                                enabled = Library.Flags[CP.enableFlag],
                                rainbow = Library.Flags[CP.rainbowFlag],
                            })
                        end
                    end

                    local function ApplyColor()
                        ColorToFlags(Color3.fromHSV(H, S, V))
                        Swatch.BackgroundColor3 = Color3.fromHSV(H, S, V)
                        FireCallback()
                    end

                    local HueBg, HueBtn, HueFill, HueVal = BuildHSVSlider(CPInner, "Hue", 1)
                    HueFill.BackgroundTransparency = 1
                    local HueGrad = Instance.new("UIGradient", HueBg)
                    HueGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,     Color3.fromHSV(0,     1, 1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                        ColorSequenceKeypoint.new(0.5,   Color3.fromHSV(0.5,   1, 1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                        ColorSequenceKeypoint.new(1,     Color3.fromHSV(1,     1, 1)),
                    })
                    local HueCursor = Instance.new("Frame", HueBg)
                    HueCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
                    HueCursor.Size             = UDim2.new(0, 5, 0, 10)
                    HueCursor.Position         = UDim2.new(H, 0, 0.5, 0)
                    HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    HueCursor.BorderSizePixel  = 0
                    HueCursor.ZIndex           = 3
                    Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0, 2)
                    HueVal.Text = tostring(math.floor(H * 360))

                    local SatBg, SatBtn, SatFill, SatVal = BuildHSVSlider(CPInner, "Sat", 2)
                    SatFill.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    SatFill.Size             = UDim2.new(S, 0, 1, 0)
                    SatVal.Text              = tostring(math.floor(S * 100))

                    local BriBg, BriBtn, BriFill, BriVal = BuildHSVSlider(CPInner, "Value", 3)
                    BriFill.BackgroundColor3 = Color3.fromHSV(H, S, 1)
                    BriFill.Size             = UDim2.new(V, 0, 1, 0)
                    BriVal.Text              = tostring(math.floor(V * 100))

                    local function RefreshSliders()
                        HueCursor.Position       = UDim2.new(H, 0, 0.5, 0)
                        HueVal.Text              = tostring(math.floor(H * 360))
                        SatFill.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                        SatFill.Size             = UDim2.new(S, 0, 1, 0)
                        SatVal.Text              = tostring(math.floor(S * 100))
                        BriFill.BackgroundColor3 = Color3.fromHSV(H, S, 1)
                        BriFill.Size             = UDim2.new(V, 0, 1, 0)
                        BriVal.Text              = tostring(math.floor(V * 100))
                        Swatch.BackgroundColor3  = Color3.fromHSV(H, S, V)
                    end

                    BindSliderDrag(HueBg, HueBtn, function(pct) H = pct; RefreshSliders(); ApplyColor() end)
                    BindSliderDrag(SatBg, SatBtn, function(pct) S = pct; RefreshSliders(); ApplyColor() end)
                    BindSliderDrag(BriBg, BriBtn, function(pct) V = pct; RefreshSliders(); ApplyColor() end)

                    local EnableObj, _ = BuildMiniToggle(CPInner, "Enable", 4, CP.enableFlag)
                    local origEnSet = EnableObj.Set
                    function EnableObj:Set(state)
                        origEnSet(self, state)
                        FireCallback()
                    end
                    local origEnTog = EnableObj.Toggle
                    function EnableObj:Toggle()
                        origEnTog(self)
                        FireCallback()
                    end

                    local RainbowObj, _ = BuildMiniToggle(CPInner, "Enable Rainbow", 5, CP.rainbowFlag)
                    local origRbSet = RainbowObj.Set
                    function RainbowObj:Set(state)
                        origRbSet(self, state)
                        FireCallback()
                    end
                    local origRbTog = RainbowObj.Toggle
                    function RainbowObj:Toggle()
                        origRbTog(self)
                        FireCallback()
                    end

                    local rbHue = H
                    RunService.Heartbeat:Connect(function(dt)
                        if not Library.Flags[CP.rainbowFlag] then return end
                        if not Library.Flags[CP.enableFlag] then return end
                        rbHue = (rbHue + dt * 0.3) % 1
                        H = rbHue
                        ColorToFlags(Color3.fromHSV(H, S, V))
                        RefreshSliders()
                        if opts.callback then
                            pcall(opts.callback, { color = Color3.fromHSV(H, S, V), enabled = true, rainbow = true })
                        end
                    end)

                    ConnectButton(CPHeader, function()
                        cpOpen = not cpOpen
                        TweenService:Create(CPArrow,  TweenInfo.new(0.2), { Rotation = cpOpen and -90 or 0 }):Play()
                        TweenService:Create(CPHeader, TweenInfo.new(0.2), { ImageTransparency = cpOpen and 0.5 or 1 }):Play()
                        UpdateCPHeight()
                    end)

                    function CP:SetColor(data)
                        if type(data) == "table" then
                            local c = Color3.new(data.r or 1, data.g or 1, data.b or 1)
                            ColorToFlags(c)
                            H, S, V = Color3.toHSV(c)
                            RefreshSliders()
                        end
                    end

                    function CP:GetColor()   return FlagsToColor() end
                    function CP:GetEnabled() return Library.Flags[CP.enableFlag] end
                    function CP:GetRainbow() return Library.Flags[CP.rainbowFlag] end

                    table.insert(Library.Components, { type = "colorpicker", obj = CP, flag = CP.flag })
                    return CP
                end

                table.insert(Library.Components, { type = "module_expanded", obj = Module, flag = Module.flag })
                return Module
            end

            return Section
        end

        return Tab
    end

    function Gui:DefaultTab(identifier)
        local target = nil
        if identifier == nil then
            target = self.Tabs[1]
        elseif type(identifier) == "number" then
            target = self.Tabs[identifier]
        elseif type(identifier) == "string" then
            for _, t in ipairs(self.Tabs) do
                if t.Title and t.Title.Text == identifier then
                    target = t; break
                end
            end
        elseif type(identifier) == "table" then
            target = identifier
        end
        if target then
            if target.Section then
                target:Activate()
            else
                self._defaultTab = target
            end
        end
    end

    return Gui
end

return Library
