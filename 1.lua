--===================================================================================--
--      UNNAMED ENHANCEMENTS (VISUAL SUITE) - PART 1: INTERFACE & CONFIG             --
--===================================================================================--
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(12, 12, 14), TopBar = Color3.fromRGB(18, 18, 22),
    TabsFrame = Color3.fromRGB(14, 14, 18), Accent = Color3.fromRGB(0, 160, 255),
    Text = Color3.fromRGB(245, 245, 245), TextDark = Color3.fromRGB(110, 115, 125),
    ElementBg = Color3.fromRGB(24, 24, 30), Border = Color3.fromRGB(35, 35, 45)
}

_G.UE_Config = {
    X = 0, Y = 0, Z = 0, Pitch = 0, Yaw = 0, Roll = 0,
    DisableBobbing = false, DisableSway = false,
    LeftArmTrans = 0, RightArmTrans = 0, HideUpperTorso = false, HandTrans = 0,
    VmWireframe = false, VmFillOpacity = 0.5, VmChroma = false, ChromaSpeed = 2,
    EspEnabled = false, ChamsEnabled = false, ChamsWireframe = false,
    ChamsFillOpacity = 0.5, LookDirection = false,
    CustomFOV = 70, FullBright = false, TimeChanger = false, TargetTime = 14
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UE_Visual_Suite"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 400)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Theme.Border
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 1
TopBar.BorderColor3 = Theme.Border
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Unnamed Enhancements // Visuals"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 130, 1, -38)
TabsFrame.Position = UDim2.new(0, 0, 0, 38)
TabsFrame.BackgroundColor3 = Theme.TabsFrame
TabsFrame.BorderSizePixel = 1
TabsFrame.BorderColor3 = Theme.Border
TabsFrame.Parent = MainFrame

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -130, 1, -38)
PagesContainer.Position = UDim2.new(0, 130, 0, 38)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local Pages, TabButtons, tabCount = {}, {}, 0

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Accent
    page.Visible = false
    page.Parent = PagesContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    
    Pages[name] = page
    return page
end

function AddTab(name)
    local page = CreatePage(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 38)
    tabBtn.Position = UDim2.new(0, 0, 0, tabCount * 38)
    tabBtn.BackgroundColor3 = Theme.TabsFrame
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = "  " .. name
    tabBtn.TextColor3 = Theme.TextDark
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 14
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = TabsFrame
    
    TabButtons[name] = tabBtn
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = Theme.TextDark end
        page.Visible = true
        tabBtn.TextColor3 = Theme.Accent
    end)
    if tabCount == 0 then page.Visible = true tabBtn.TextColor3 = Theme.Accent end
    tabCount = tabCount + 1
end

function AddToggle(pageName, text, configKey)
    local page = Pages[pageName]
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = page
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 0, 24)
    btn.Position = UDim2.new(0.8, 0, 0.5, -12)
    btn.BackgroundColor3 = Theme.ElementBg
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Theme.Border
    btn.Text = _G.UE_Config[configKey] and "ON" or "OFF"
    btn.TextColor3 = _G.UE_Config[configKey] and Theme.Accent or Theme.TextDark
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        _G.UE_Config[configKey] = not _G.UE_Config[configKey]
        btn.Text = _G.UE_Config[configKey] and "ON" or "OFF"
        btn.TextColor3 = _G.UE_Config[configKey] and Theme.Accent or Theme.TextDark
    end)
end

function AddSlider(pageName, text, min, max, configKey)
    local page = Pages[pageName]
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundTransparency = 1
    frame.Parent = page
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. " : " .. tostring(_G.UE_Config[configKey])
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 26)
    sliderBg.BackgroundColor3 = Theme.ElementBg
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((_G.UE_Config[configKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local function updateSlider(input)
        local posX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max - min) * posX) * 10) / 10
        _G.UE_Config[configKey] = val
        label.Text = text .. " : " .. tostring(val)
        sliderFill.Size = UDim2.new(posX, 0, 1, 0)
    end
    
    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Создание структуры меню
AddTab("Viewmodel")
AddSlider("Viewmodel", "Weapon X Offset", -5, 5, "X")
AddSlider("Viewmodel", "Weapon Y Offset", -5, 5, "Y")
AddSlider("Viewmodel", "Weapon Z Offset", -5, 5, "Z")
AddSlider("Viewmodel", "Weapon Pitch Angle", -180, 180, "Pitch")
AddSlider("Viewmodel", "Weapon Yaw Angle", -180, 180, "Yaw")
AddSlider("Viewmodel", "Weapon Roll Angle", -180, 180, "Roll")
AddToggle("Viewmodel", "Disable Hand Bobbing", "DisableBobbing")
AddToggle("Viewmodel", "Disable Camera Sway", "DisableSway")

AddTab("Visuals & Tech")
AddToggle("Visuals & Tech", "Wireframe Mode (Сетка)", "VmWireframe")
AddToggle("Visuals & Tech", "Chroma RGB Effect", "VmChroma")
AddSlider("Visuals & Tech", "Chroma Speed", 1, 10, "ChromaSpeed")
AddSlider("Visuals & Tech", "Wireframe Fill Opacity", 0, 1, "VmFillOpacity")
AddSlider("Visuals & Tech", "Left Arm Trans (R6)", 0, 1, "LeftArmTrans")
AddSlider("Visuals & Tech", "Right Arm Trans (R6)", 0, 1, "RightArmTrans")
AddToggle("Visuals & Tech", "Remove UpperTorso (R15)", "HideUpperTorso")
AddSlider("Visuals & Tech", "Hands Transparency (R15)", 0, 1, "HandTrans")

AddTab("Players & World")
AddToggle("Players & World", "Enable ESP Master", "EspEnabled")
AddToggle("Players & World", "Render Player Chams", "ChamsEnabled")
AddToggle("Players & World", "Chams Wireframe Mode", "ChamsWireframe")
AddSlider("Players & World", "Chams Fill Opacity", 0, 1, "ChamsFillOpacity")
AddToggle("Players & World", "Show Look Vectors", "LookDirection")
AddSlider("Players & World", "Field Of View (FOV)", 40, 130, "CustomFOV")
AddToggle("Players & World", "FullBright Mode", "FullBright")
AddToggle("Players & World", "Enable Time Changer", "TimeChanger")
AddSlider("Players & World", "Target Time", 0, 24, "TargetTime")

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt) then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
