--===================================================================================--
--      UNNAMED ENHANCEMENTS (VISUAL SUITE REPLICA) - COMPLETE OFFLINE SOURCE        --
--===================================================================================--

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки темы интерфейса UE
local Theme = {
    Background = Color3.fromRGB(16, 16, 20),
    TopBar = Color3.fromRGB(24, 24, 30),
    TabsFrame = Color3.fromRGB(20, 20, 26),
    Accent = Color3.fromRGB(0, 160, 255),
    Text = Color3.fromRGB(245, 245, 245),
    TextDark = Color3.fromRGB(120, 125, 135),
    ElementBg = Color3.fromRGB(28, 28, 36),
    Border = Color3.fromRGB(40, 40, 50)
}

-- Полный рабочий конфиг параметров чита
local UE_Config = {
    -- VIEWMODEL OFFSETS
    X = 0, Y = 0, Z = 0,
    Pitch = 0, Yaw = 0, Roll = 0,
    
    -- VIEWMODEL MECHANICS
    DisableBobbing = false,
    DisableSway = false,
    
    -- LIMBS (TECH)
    LeftArmTrans = 0, 
    RightArmTrans = 0,
    HideUpperTorso = false, 
    HandTrans = 0,
    
    -- VIEWMODEL VISUALS
    VmWireframe = false, 
    VmFillOpacity = 0.5, 
    VmChroma = false, 
    ChromaSpeed = 2,
    
    -- PLAYERS VISUALS (ESP)
    EspEnabled = false,
    ChamsEnabled = false,
    ChamsWireframe = false,
    ChamsFillOpacity = 0.5,
    LookDirection = false,
    
    -- WORLD
    CustomFOV = 70,
    FullBright = false,
    TimeChanger = false,
    TargetTime = 14
}

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime
}

---------------------------------------------------------------------------------------
-- ГЕНЕРАЦИЯ ИНТЕРФЕЙСА (UI ENGINE)
---------------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UE_Ultimate_Visual_Suite"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Theme.Border
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Верхняя панель (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 1
TopBar.BorderColor3 = Theme.Border
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Unnamed Enhancements [Visuals Only]"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Панель Вкладок (Слева)
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(0, 150, 1, -40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundColor3 = Theme.TabsFrame
TabsFrame.BorderSizePixel = 1
TabsFrame.BorderColor3 = Theme.Border
TabsFrame.Parent = MainFrame

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -150, 1, -40)
PagesContainer.Position = UDim2.new(0, 150, 0, 40)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local Pages = {}
local TabButtons = {}
local tabCount = 0

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
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page
    
    Pages[name] = page
    return page
end

local function AddTab(name)
    local page = CreatePage(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 40)
    tabBtn.Position = UDim2.new(0, 0, 0, tabCount * 40)
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
    
    if tabCount == 0 then
        page.Visible = true
        tabBtn.TextColor3 = Theme.Accent
    end
    tabCount = tabCount + 1
end

-- Конструкторы элементов управления
local function AddToggle(page, text, configKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = page
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 0, 26)
    btn.Position = UDim2.new(0.8, 0, 0.5, -13)
    btn.BackgroundColor3 = Theme.ElementBg
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Theme.Border
    btn.Text = UE_Config[configKey] and "ON" or "OFF"
    btn.TextColor3 = UE_Config[configKey] and Theme.Accent or Theme.TextDark
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        UE_Config[configKey] = not UE_Config[configKey]
        btn.Text = UE_Config[configKey] and "ON" or "OFF"
        btn.TextColor3 = UE_Config[configKey] and Theme.Accent or Theme.TextDark
    end)
end

local function AddSlider(page, text, min, max, configKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    frame.Parent = page
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text .. " : " .. tostring(UE_Config[configKey])
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Theme.ElementBg
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((UE_Config[configKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local function updateSlider(input)
        local posX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * posX
        -- Округление
        val = math.floor(val * 10) / 10
        UE_Config[configKey] = val
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

---------------------------------------------------------------------------------------
-- НАПОЛНЕНИЕ МЕНЮ СТРУКТУРОЙ UE
---------------------------------------------------------------------------------------
AddTab("Viewmodel")
AddSlider(Pages["Viewmodel"], "X Offset (Влево / Вправо)", -5, 5, "X")
AddSlider(Pages["Viewmodel"], "Y Offset (Выше / Ниже)", -5, 5, "Y")
AddSlider(Pages["Viewmodel"], "Z Offset (Глубина вперед/назад)", -5, 5, "Z")
AddSlider(Pages["Viewmodel"], "Pitch Angle (Наклон)", -180, 180, "Pitch")
AddSlider(Pages["Viewmodel"], "Yaw Angle (Поворот)", -180, 180, "Yaw")
AddSlider(Pages["Viewmodel"], "Roll Angle (Вращение оси)", -180, 180, "Roll")
AddToggle(Pages["Viewmodel"], "Disable Bobbing (Тряска ходьбы)", "DisableBobbing")
AddToggle(Pages["Viewmodel"], "Disable Sway (Инерция камеры)", "DisableSway")

AddTab("Visuals & Tech")
AddToggle(Pages["Visuals & Tech"], "Wireframe Mode (Сетка полигонов)", "VmWireframe")
AddToggle(Pages["Visuals & Tech"], "Chroma RGB Effect (Радуга)", "VmChroma")
AddSlider(Pages["Visuals & Tech"], "Chroma Cycle Speed", 1, 10, "ChromaSpeed")
AddSlider(Pages["Visuals & Tech"], "Wireframe Fill Opacity", 0, 1, "VmFillOpacity")
AddSlider(Pages["Visuals & Tech"], "Left Arm Transparency (R6)", 0, 1, "LeftArmTrans")
AddSlider(Pages["Visuals & Tech"], "Right Arm Transparency (R6)", 0, 1, "RightArmTrans")
AddToggle(Pages["Visuals & Tech"], "Remove UpperTorso (R15 Плечи)", "HideUpperTorso")
AddSlider(Pages["Visuals & Tech"], "Hands Transparency (R15 Кисти)", 0, 1, "HandTrans")
AddTab("Players Visuals")
AddToggle(Pages["Players Visuals"], "Enable ESP Master", "EspEnabled")
AddToggle(Pages["Players Visuals"], "Render Player Chams", "ChamsEnabled")
AddToggle(Pages["Players Visuals"], "Chams Wireframe Mode", "ChamsWireframe")
AddSlider(Pages["Players Visuals"], "Chams Fill Opacity", 0, 1, "ChamsFillOpacity")
AddToggle(Pages["Players Visuals"], "Show Look Vectors (Линии взгляда)", "LookDirection")
AddTab("World & Env")
AddSlider(Pages["World & Env"], "Field Of View (FOV)", 40, 130, "CustomFOV")
AddToggle(Pages["World & Env"], "FullBright Mode (Без теней)", "FullBright")
AddToggle(Pages["World & Env"], "Enable Time Changer", "TimeChanger")
AddSlider(Pages["World & Env"], "Target World Time (Часы)", 0, 24, "TargetTime")
-- Хоткей бинд на LeftAlt / RightAlt
UserInputService.InputBegan:Connect(function(input, gpe)
if not gpe and (input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt) then
MainFrame.Visible = not MainFrame.Visible
    end)
end

-- ИГРОВОЙ ДВИЖОК И ХУКИ (МАТЕМАТИКА РЕНДЕРА)

local chromaHue = 0
local HighlightStorage = {}
local LookVectorBeams = {}
RunService.RenderStepped:Connect(function(dt)
-- Настройка Камеры и Окружения
Camera.FieldOfView = UE_Config.CustomFOV
if UE_Config.FullBright then
Lighting.Ambient = Color3.fromRGB(255, 255, 255)
Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
else
Lighting.Ambient = OriginalLighting.Ambient
Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
end
if UE_Config.TimeChanger then
Lighting.ClockTime = UE_Config.TargetTime
else
Lighting.ClockTime = OriginalLighting.ClockTime
end
-- Расчет Chroma RGB
if UE_Config.VmChroma then
chromaHue = (chromaHue + (dt * UE_Config.ChromaSpeed * 0.05)) % 1
end
local currentRGB = Color3.fromHSV(chromaHue, 1, 1)
-- ХУК НА VIEWMODEL (Руки и Оружие)
local viewmodel = Camera:FindFirstChildOfClass("Model") or Camera:FindFirstChild("ViewModel")
if viewmodel then
local cfOffset = CFrame.new(UE_Config.X, UE_Config.Y, UE_Config.Z) *
CFrame.Angles(math.rad(UE_Config.Pitch), math.rad(UE_Config.Yaw), math.rad(UE_Config.Roll))
-- Перехват позиции (Disable Sway / Bobbing)
if UE_Config.DisableBobbing or UE_Config.DisableSway then
viewmodel:PivotTo(Camera.CFrame * cfOffset)
end
-- Стилизация частей модели
for _, part in ipairs(viewmodel:GetDescendants()) do
if part:IsA("BasePart") or part:IsA("MeshPart") then
if part.Name == "Left Arm" then
part.Transparency = UE_Config.LeftArmTrans
elseif part.Name == "Right Arm" then
part.Transparency = UE_Config.RightArmTrans
elseif part.Name == "UpperTorso" then
part.Transparency = UE_Config.HideUpperTorso and 1 or 0
elseif part.Name == "LeftHand" or part.Name == "RightHand" then
part.Transparency = UE_Config.HandTrans
else
if UE_Config.VmWireframe then
part.Material = Enum.Material.ForceField
part.Transparency = UE_Config.VmFillOpacity
if UE_Config.VmChroma then part.Color = currentRGB end
else
part.Material = Enum.Material.SmoothPlastic
end
end
end
end
end
-- ХУК НА ИГРОКОВ (ESP / CHAMS)
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local char = player.Character
local hrp = char.HumanoidRootPart
-- Логика Chams
if UE_Config.EspEnabled and UE_Config.ChamsEnabled then
local highlight = HighlightStorage[player]
if not highlight or highlight.Parent ~= char then
highlight = Instance.new("Highlight")
highlight.Name = "UE_Visual_Cham"
highlight.Parent = char
HighlightStorage[player] = highlight
end
highlight.Enabled = true
highlight.FillColor = UE_Config.VmChroma and currentRGB or Color3.fromRGB(0, 160, 255)
highlight.FillTransparency = UE_Config.ChamsFillOpacity
highlight.OutlineTransparency = UE_Config.ChamsWireframe and 0 or 1
else
if HighlightStorage[player] then HighlightStorage[player].Enabled = false end
end
-- Прорисовка линий направления взгляда (Look Direction)
if UE_Config.EspEnabled and UE_Config.LookDirection then
local bData = LookVectorBeams[player]
if not bData or not hrp:FindFirstChild("UE_LookBeam") then
local att0 = Instance.new("Attachment", hrp)
local att1 = Instance.new("Attachment", hrp)
att1.Position = Vector3.new(0, 0, -15) -- Длина линии вперед
local beam = Instance.new("Beam", hrp)
beam.Name = "UE_LookBeam"
beam.Attachment0 = att0
beam.Attachment1 = att1
beam.Width0 = 0.15
beam.Width1 = 0.15
beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
beam.FaceCamera = true
LookVectorBeams[player] = {Beam = beam, Att0 = att0, Att1 = att1}
end
else
if hrp:FindFirstChild("UE_LookBeam") then hrp.UE_LookBeam:Destroy() end
end
end
end
end)
