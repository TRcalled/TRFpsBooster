local TweenService = game:GetService("TweenService")
local TextService  = game:GetService("TextService")
local CoreGui      = game:GetService("CoreGui")
local Players      = game:GetService("Players")

local ME = Players.LocalPlayer

local function ResolveGuiParent()
    local success, parent = pcall(function()
        if gethui then return gethui() end
        return CoreGui:FindFirstChild("RobloxGui") or CoreGui
    end)
    if success and parent then return parent end
    return ME:WaitForChild("PlayerGui")
end

local Library = {}

local RootGui = Instance.new("ScreenGui")
RootGui.Name = "ModernOptimizerUI"
RootGui.ResetOnSpawn = false
RootGui.Parent = ResolveGuiParent()

-- ==========================================
-- NOTIFICATION
-- ==========================================
local NotifContainer = Instance.new("Frame", RootGui)
NotifContainer.Name = "NotificationContainer"
NotifContainer.Size = UDim2.new(0, 300, 1, 0)
NotifContainer.Position = UDim2.new(1, -320, 0, 0)
NotifContainer.BackgroundTransparency = 1

local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)

Instance.new("UIPadding", NotifContainer).PaddingBottom = UDim.new(0, 20)

function Library:Notify(text, duration)
    duration = duration or 4

    local Wrapper = Instance.new("Frame", NotifContainer)
    Wrapper.Size = UDim2.new(1, 0, 0, 0)
    Wrapper.BackgroundTransparency = 1
    Wrapper.ClipsDescendants = true

    local Inner = Instance.new("Frame", Wrapper)
    Inner.Size = UDim2.new(1, 0, 1, 0)
    Inner.Position = UDim2.new(1, 50, 0, 0)
    Inner.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Inner.BackgroundTransparency = 0.15
    Instance.new("UICorner", Inner).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Inner)
    Stroke.Color, Stroke.Transparency, Stroke.Thickness = Color3.fromRGB(80, 120, 255), 0.5, 1.5

    local Title = Instance.new("TextLabel", Inner)
    Title.Size, Title.Position = UDim2.new(1, -30, 0, 20), UDim2.new(0, 15, 0, 8)
    Title.BackgroundTransparency, Title.Font = 1, Enum.Font.GothamBold
    Title.Text, Title.TextColor3, Title.TextSize = "FPS Engine", Color3.fromRGB(130, 170, 255), 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Body = Instance.new("TextLabel", Inner)
    Body.Size, Body.Position = UDim2.new(1, -30, 1, -35), UDim2.new(0, 15, 0, 28)
    Body.BackgroundTransparency, Body.Font = 1, Enum.Font.Gotham
    Body.Text, Body.TextColor3, Body.TextSize = text, Color3.fromRGB(220, 220, 225), 12
    Body.TextWrapped, Body.TextXAlignment, Body.TextYAlignment = true, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top

    local textHeight = TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(270, math.huge)).Y
    local targetHeight = math.max(60, textHeight + 40)

    TweenService:Create(Wrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
    TweenService:Create(Inner, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(duration, function()
        if not Inner.Parent then return end
        TweenService:Create(Inner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(Body, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        local closeTween = TweenService:Create(Wrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
        closeTween:Play()
        closeTween.Completed:Wait()
        Wrapper:Destroy()
    end)
end

-- ==========================================
-- PROGRESS BAR
-- ==========================================
function Library:CreateProgressBar(title)
    local BarObj = {}

    local ProgressGui = Instance.new("Frame", RootGui)
    ProgressGui.Size = UDim2.new(0, 360, 0, 52)
    ProgressGui.Position = UDim2.new(0.5, -180, 0.9, 0)
    ProgressGui.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    ProgressGui.BackgroundTransparency = 1
    Instance.new("UICorner", ProgressGui).CornerRadius = UDim.new(0, 10)

    local PStroke = Instance.new("UIStroke", ProgressGui)
    PStroke.Color, PStroke.Transparency, PStroke.Thickness = Color3.fromRGB(80, 120, 255), 1, 1.5

    local PText = Instance.new("TextLabel", ProgressGui)
    PText.Size, PText.Position = UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0, 6)
    PText.BackgroundTransparency, PText.Font = 1, Enum.Font.GothamBold
    PText.Text, PText.TextColor3, PText.TextSize = title or "Processing...", Color3.fromRGB(220, 220, 225), 12
    PText.TextTransparency = 1

    local BarBG = Instance.new("Frame", ProgressGui)
    BarBG.Size, BarBG.Position = UDim2.new(0.9, 0, 0, 6), UDim2.new(0.05, 0, 0.68, 0)
    BarBG.BackgroundColor3, BarBG.BackgroundTransparency = Color3.fromRGB(15, 15, 20), 1
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBG)
    BarFill.Size, BarFill.BackgroundColor3, BarFill.BackgroundTransparency = UDim2.new(0, 0, 1, 0), Color3.fromRGB(80, 120, 255), 1
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    TweenService:Create(ProgressGui, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -180, 0.85, 0), BackgroundTransparency = 0.15}):Play()
    TweenService:Create(PStroke, TweenInfo.new(0.4), {Transparency = 0.4}):Play()
    TweenService:Create(PText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(BarBG, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()

    function BarObj:Update(ratio, text)
        if text then PText.Text = text end
        TweenService:Create(BarFill, TweenInfo.new(0.08), {Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0)}):Play()
    end

    function BarObj:Destroy()
        TweenService:Create(ProgressGui, TweenInfo.new(0.4), {Position = UDim2.new(0.5, -180, 0.9, 0), BackgroundTransparency = 1}):Play()
        TweenService:Create(PStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(PText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(BarBG, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.delay(0.45, function() ProgressGui:Destroy() end)
    end

    return BarObj
end

-- ==========================================
-- MAIN WINDOW FACTORY
-- ==========================================
function Library:CreateWindow(config)
    local Window = {}

    local Backdrop = Instance.new("Frame", RootGui)
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    Backdrop.BackgroundTransparency = 1

    local MainFrame = Instance.new("Frame", Backdrop)
    MainFrame.Size = UDim2.new(0, 520, 0, 560)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    MainFrame.BackgroundTransparency = 1
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color, MainStroke.Thickness, MainStroke.Transparency = Color3.fromRGB(80, 120, 255), 1.5, 1

    -- Header
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    Header.BorderSizePixel = 0

    local HeaderTitle = Instance.new("TextLabel", Header)
    HeaderTitle.Size = UDim2.new(1, -120, 0, 26)
    HeaderTitle.Position = UDim2.new(0, 18, 0, 10)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.Text = config.Title or "CONFIG PANEL"
    HeaderTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
    HeaderTitle.TextSize = 16
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

    local HeaderSubtitle = Instance.new("TextLabel", Header)
    HeaderSubtitle.Size = UDim2.new(1, -120, 0, 16)
    HeaderSubtitle.Position = UDim2.new(0, 18, 0, 34)
    HeaderSubtitle.BackgroundTransparency = 1
    HeaderSubtitle.Font = Enum.Font.Gotham
    HeaderSubtitle.Text = config.Subtitle or "Select preferences"
    HeaderSubtitle.TextColor3 = Color3.fromRGB(140, 145, 160)
    HeaderSubtitle.TextSize = 11
    HeaderSubtitle.TextXAlignment = Enum.TextXAlignment.Left

    local Badge = Instance.new("TextLabel", Header)
    Badge.Size = UDim2.new(0, 75, 0, 24)
    Badge.Position = UDim2.new(1, -90, 0, 18)
    Badge.BackgroundColor3 = Color3.fromRGB(40, 60, 130)
    Badge.Font = Enum.Font.GothamBold
    Badge.Text = "MODULAR"
    Badge.TextColor3 = Color3.fromRGB(150, 190, 255)
    Badge.TextSize = 10
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)

    -- Preset Bar
    local PresetBar = Instance.new("Frame", MainFrame)
    PresetBar.Size = UDim2.new(1, -36, 0, 32)
    PresetBar.Position = UDim2.new(0, 18, 0, 70)
    PresetBar.BackgroundTransparency = 1

    local PresetLabel = Instance.new("TextLabel", PresetBar)
    PresetLabel.Size = UDim2.new(0, 70, 1, 0)
    PresetLabel.BackgroundTransparency = 1
    PresetLabel.Font = Enum.Font.GothamBold
    PresetLabel.Text = "PRESETS:"
    PresetLabel.TextColor3 = Color3.fromRGB(120, 125, 140)
    PresetLabel.TextSize = 11
    PresetLabel.TextXAlignment = Enum.TextXAlignment.Left

    local presetOffsetX = 75

    function Window:AddPreset(name, callback)
        local btn = Instance.new("TextButton", PresetBar)
        btn.Size = UDim2.new(0, 110, 1, 0)
        btn.Position = UDim2.new(0, presetOffsetX, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
        btn.Font = Enum.Font.GothamMedium
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 205, 220)
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(60, 70, 100)
        stroke.Thickness = 1

        btn.MouseButton1Click:Connect(callback)
        presetOffsetX = presetOffsetX + 118
    end

    -- Scroll List
    local Scroll = Instance.new("ScrollingFrame", MainFrame)
    Scroll.Size = UDim2.new(1, -36, 0, 370)
    Scroll.Position = UDim2.new(0, 18, 0, 110)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 90, 150)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local ScrollLayout = Instance.new("UIListLayout", Scroll)
    ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollLayout.Padding = UDim.new(0, 6)

    -- Toggle Component
    function Window:AddToggle(opt)
        local ToggleObj = {}
        local state = opt.Default or false

        local item = Instance.new("Frame", Scroll)
        item.Size = UDim2.new(1, -8, 0, 48)
        item.BackgroundColor3 = Color3.fromRGB(25, 26, 34)
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
        
        local itemStroke = Instance.new("UIStroke", item)
        itemStroke.Color = Color3.fromRGB(40, 42, 55)
        itemStroke.Thickness = 1

        local tLabel = Instance.new("TextLabel", item)
        tLabel.Size = UDim2.new(1, -70, 0, 20)
        tLabel.Position = UDim2.new(0, 12, 0, 6)
        tLabel.BackgroundTransparency = 1
        tLabel.Font = Enum.Font.GothamBold
        tLabel.Text = opt.Title or "Setting"
        tLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
        tLabel.TextSize = 12
        tLabel.TextXAlignment = Enum.TextXAlignment.Left

        local tipLabel = Instance.new("TextLabel", item)
        tipLabel.Size = UDim2.new(1, -70, 0, 16)
        tipLabel.Position = UDim2.new(0, 12, 0, 26)
        tipLabel.BackgroundTransparency = 1
        tipLabel.Font = Enum.Font.Gotham
        tipLabel.Text = opt.Tip or ""
        tipLabel.TextColor3 = Color3.fromRGB(130, 135, 150)
        tipLabel.TextSize = 10
        tipLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Switch = Instance.new("TextButton", item)
        Switch.Size = UDim2.new(0, 44, 0, 22)
        Switch.Position = UDim2.new(1, -56, 0.5, -11)
        Switch.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
        Switch.Text = ""
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

        local Knob = Instance.new("Frame", Switch)
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new(0, 3, 0.5, -8)
        Knob.BackgroundColor3 = Color3.fromRGB(200, 205, 220)
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local function UpdateVisuals(animated)
            local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local targetBg  = state and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 42, 55)
            local targetKnob = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 175, 190)

            if animated then
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetKnob}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
            else
                Knob.Position = targetPos
                Knob.BackgroundColor3 = targetKnob
                Switch.BackgroundColor3 = targetBg
            end
        end

        function ToggleObj:Set(newVal)
            state = newVal
            UpdateVisuals(true)
            if opt.Callback then opt.Callback(state) end
        end

        Switch.MouseButton1Click:Connect(function()
            ToggleObj:Set(not state)
        end)

        UpdateVisuals(false)
        return ToggleObj
    end

    -- Bottom Bar
    local BottomBar = Instance.new("Frame", MainFrame)
    BottomBar.Size = UDim2.new(1, 0, 0, 60)
    BottomBar.Position = UDim2.new(0, 0, 1, -60)
    BottomBar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    BottomBar.BorderSizePixel = 0

    local ProceedBtn = Instance.new("TextButton", BottomBar)
    ProceedBtn.Size = UDim2.new(1, -36, 0, 38)
    ProceedBtn.Position = UDim2.new(0, 18, 0, 11)
    ProceedBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    ProceedBtn.Font = Enum.Font.GothamBold
    ProceedBtn.Text = "APPLY & LAUNCH ENGINE"
    ProceedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProceedBtn.TextSize = 13
    Instance.new("UICorner", ProceedBtn).CornerRadius = UDim.new(0, 8)

    function Window:OnProceed(callback)
        ProceedBtn.MouseButton1Click:Connect(callback)
    end

    -- Warning Modal
    local WarnModal = Instance.new("Frame", MainFrame)
    WarnModal.Size = UDim2.new(1, 0, 1, 0)
    WarnModal.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    WarnModal.BackgroundTransparency = 1
    WarnModal.Visible = false
    WarnModal.ZIndex = 10

    local WarnBox = Instance.new("Frame", WarnModal)
    WarnBox.Size = UDim2.new(0, 440, 0, 380)
    WarnBox.Position = UDim2.new(0.5, -220, 0.5, -190)
    WarnBox.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    WarnBox.ZIndex = 11
    Instance.new("UICorner", WarnBox).CornerRadius = UDim.new(0, 10)
    
    local WarnStroke = Instance.new("UIStroke", WarnBox)
    WarnStroke.Color = Color3.fromRGB(255, 90, 90)
    WarnStroke.Thickness = 1.5

    local WarnIcon = Instance.new("TextLabel", WarnBox)
    WarnIcon.Size = UDim2.new(1, 0, 0, 30)
    WarnIcon.Position = UDim2.new(0, 0, 0, 15)
    WarnIcon.BackgroundTransparency = 1
    WarnIcon.Font = Enum.Font.GothamBold
    WarnIcon.Text = "⚠️ SENSITIVE SETTINGS DETECTED"
    WarnIcon.TextColor3 = Color3.fromRGB(255, 110, 110)
    WarnIcon.TextSize = 14
    WarnIcon.ZIndex = 12

    local WarnDesc = Instance.new("TextLabel", WarnBox)
    WarnDesc.Size = UDim2.new(1, -40, 0, 30)
    WarnDesc.Position = UDim2.new(0, 20, 0, 48)
    WarnDesc.BackgroundTransparency = 1
    WarnDesc.Font = Enum.Font.Gotham
    WarnDesc.Text = "The following aggressive options permanently delete assets or modify visual colliders:"
    WarnDesc.TextColor3 = Color3.fromRGB(190, 195, 210)
    WarnDesc.TextSize = 11
    WarnDesc.TextWrapped = true
    WarnDesc.ZIndex = 12

    local WarnScroll = Instance.new("ScrollingFrame", WarnBox)
    WarnScroll.Size = UDim2.new(1, -40, 0, 210)
    WarnScroll.Position = UDim2.new(0, 20, 0, 85)
    WarnScroll.BackgroundTransparency = 1
    WarnScroll.ScrollBarThickness = 3
    WarnScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 90, 90)
    WarnScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    WarnScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    WarnScroll.ZIndex = 12

    local WarnListLayout = Instance.new("UIListLayout", WarnScroll)
    WarnListLayout.Padding = UDim.new(0, 6)

    local WarnBtnBack = Instance.new("TextButton", WarnBox)
    WarnBtnBack.Size = UDim2.new(0.46, 0, 0, 36)
    WarnBtnBack.Position = UDim2.new(0.04, 0, 1, -46)
    WarnBtnBack.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    WarnBtnBack.Font = Enum.Font.GothamBold
    WarnBtnBack.Text = "← Back & Edit"
    WarnBtnBack.TextColor3 = Color3.fromRGB(220, 220, 230)
    WarnBtnBack.TextSize = 12
    WarnBtnBack.ZIndex = 12
    Instance.new("UICorner", WarnBtnBack).CornerRadius = UDim.new(0, 6)

    local WarnBtnConfirm = Instance.new("TextButton", WarnBox)
    WarnBtnConfirm.Size = UDim2.new(0.46, 0, 0, 36)
    WarnBtnConfirm.Position = UDim2.new(0.50, 0, 1, -46)
    WarnBtnConfirm.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    WarnBtnConfirm.Font = Enum.Font.GothamBold
    WarnBtnConfirm.Text = "Confirm & Launch"
    WarnBtnConfirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    WarnBtnConfirm.TextSize = 12
    WarnBtnConfirm.ZIndex = 12
    Instance.new("UICorner", WarnBtnConfirm).CornerRadius = UDim.new(0, 6)

    function Window:ShowWarning(itemsList, onBack, onConfirm)
        for _, child in ipairs(WarnScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        for _, item in ipairs(itemsList) do
            local wItem = Instance.new("Frame", WarnScroll)
            wItem.Size = UDim2.new(1, -6, 0, 44)
            wItem.BackgroundColor3 = Color3.fromRGB(30, 24, 26)
            wItem.ZIndex = 13
            Instance.new("UICorner", wItem).CornerRadius = UDim.new(0, 6)

            local wTitle = Instance.new("TextLabel", wItem)
            wTitle.Size = UDim2.new(1, -16, 0, 18)
            wTitle.Position = UDim2.new(0, 8, 0, 4)
            wTitle.BackgroundTransparency = 1
            wTitle.Font = Enum.Font.GothamBold
            wTitle.Text = "• " .. item.name
            wTitle.TextColor3 = Color3.fromRGB(255, 160, 160)
            wTitle.TextSize = 11
            wTitle.TextXAlignment = Enum.TextXAlignment.Left
            wTitle.ZIndex = 14

            local wSub = Instance.new("TextLabel", wItem)
            wSub.Size = UDim2.new(1, -16, 0, 16)
            wSub.Position = UDim2.new(0, 8, 0, 22)
            wSub.BackgroundTransparency = 1
            wSub.Font = Enum.Font.Gotham
            wSub.Text = item.reason
            wSub.TextColor3 = Color3.fromRGB(200, 175, 180)
            wSub.TextSize = 10
            wSub.TextXAlignment = Enum.TextXAlignment.Left
            wSub.ZIndex = 14
        end

        WarnModal.Visible = true
        WarnModal.BackgroundTransparency = 0.2

        local backConn, confConn
        backConn = WarnBtnBack.MouseButton1Click:Connect(function()
            WarnModal.Visible = false
            backConn:Disconnect()
            confConn:Disconnect()
            if onBack then onBack() end
        end)

        confConn = WarnBtnConfirm.MouseButton1Click:Connect(function()
            backConn:Disconnect()
            confConn:Disconnect()
            if onConfirm then onConfirm() end
        end)
    end

    function Window:Close(onFinished)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -260, 0.5, -240),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        local bgClose = TweenService:Create(Backdrop, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        bgClose:Play()
        bgClose.Completed:Connect(function()
            Backdrop:Destroy()
            if onFinished then onFinished() end
        end)
    end

    -- Initial Window Entrance
    TweenService:Create(Backdrop, TweenInfo.new(0.4), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -260, 0.5, -280),
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.4), {Transparency = 0.4}):Play()

    return Window
end

return Library
