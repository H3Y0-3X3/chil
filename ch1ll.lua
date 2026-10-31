--!nocheck
-- ============================================================
-- H3Y0 CH1LL Universal Hub v3 (полный, самодостаточный)
-- ============================================================
-- Открыть меню: RightControl / Insert
-- ============================================================

-- ============================================================
-- СЕКЦИЯ 1: ЗАЩИТА ОТ ДВОЙНОЙ ЗАГРУЗКИ
-- ============================================================
local control = getgenv and getgenv()['H3Y0 CH1LL'] or nil
if control and (control.status == 'starting' or control.status == 'loaded') then
    return control
end
control = { status = 'starting', started = os.clock() }
if getgenv then getgenv()['H3Y0 CH1LL'] = control end

-- ============================================================
-- СЕКЦИЯ 2: СЕРВИСЫ И УТИЛИТЫ
-- ============================================================
local Players = cloneref and cloneref(game:GetService('Players')) or game:GetService('Players')
local RunService = cloneref and cloneref(game:GetService('RunService')) or game:GetService('RunService')
local UIS = cloneref and cloneref(game:GetService('UserInputService')) or game:GetService('UserInputService')
local LocalPlayer = Players.LocalPlayer

local function safeCall(fn, ...)
    if type(fn) ~= 'function' then return end
    local ok, res = pcall(fn, ...)
    if not ok then warn('[H3Y0 CH1LL] ' .. tostring(res)) end
    return ok, res
end

local function silentSet(inst, prop, value)
    if not inst then return end
    pcall(function() inst[prop] = value end)
end

local function getGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    return game:GetService('CoreGui')
end

-- ============================================================
-- СЕКЦИЯ 3: LIBRARY (базовые стили + ScreenGui)
-- ============================================================
local Library = {}
Library.Font = Enum.Font.Gotham
Library.FontSize = 14
Library.MainColor = Color3.fromHex('131313')
Library.BackgroundColor = Color3.fromHex('151515')
Library.AccentColor = Color3.fromHex('a2cdff')
Library.OutlineColor = Color3.fromHex('212121')
Library.FontColor = Color3.fromHex('ffffff')
Library.Toggles = {}
Library.Options = {}

local function Create(class, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do pcall(function() inst[k] = v end) end
    end
    return inst
end

local function CreateLabel(props)
    local lbl = Create('TextLabel', props)
    lbl.BackgroundTransparency = 1
    lbl.Font = Library.Font
    lbl.TextSize = Library.FontSize
    lbl.TextColor3 = Library.FontColor
    lbl.TextStrokeTransparency = 1
    return lbl
end

Library.ScreenGui = Create('ScreenGui', {
    Name = 'H3Y0_CH1LL',
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 100,
    Parent = getGuiParent(),
})

-- ============================================================
-- СЕКЦИЯ 4: WINDOW (главное окно + перетаскивание)
-- ============================================================
local MainFrame = Create('Frame', {
    Name = 'MainFrame',
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(580, 420),
    BackgroundColor3 = Library.MainColor,
    BorderSizePixel = 0,
    Visible = false,
    Parent = Library.ScreenGui,
})
local mainStroke = Instance.new('UIStroke', MainFrame)
mainStroke.Color = Library.OutlineColor

CreateLabel({
    Text = 'H3Y0 CH1LL',
    TextSize = 16,
    Position = UDim2.new(0, 0, 0, 6),
    Size = UDim2.new(1, 0, 0, 20),
    TextXAlignment = Enum.TextXAlignment.Center,
    Parent = MainFrame,
})

local CloseBtn = Create('TextButton', {
    Text = 'X',
    Font = Library.Font,
    TextSize = 14,
    TextColor3 = Library.FontColor,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -28, 0, 6),
    Size = UDim2.fromOffset(24, 24),
    Parent = MainFrame,
})
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Перетаскивание окна
do
    local dragging = false
    local dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Открытие/закрытие меню
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Панели
local TabPanel = Create('Frame', {
    BackgroundColor3 = Library.BackgroundColor,
    Position = UDim2.new(0, 8, 0, 36),
    Size = UDim2.new(0, 150, 1, -44),
    Parent = MainFrame,
})
local ContentPanel = Create('Frame', {
    BackgroundColor3 = Library.BackgroundColor,
    BackgroundTransparency = 0.15,
    Position = UDim2.new(0, 166, 0, 36),
    Size = UDim2.new(1, -174, 1, -44),
    Parent = MainFrame,
})

-- ============================================================
-- СЕКЦИЯ 5: TABS
-- ============================================================
local Tabs = {}
local ActiveTab = nil

local function AddTab(name)
    local btn = Create('TextButton', {
        Text = name,
        Font = Library.Font,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 26),
        Parent = TabPanel,
    })
    local content = Create('Frame', {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        Parent = ContentPanel,
    })
    local left = Create('ScrollingFrame', {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -6, 1, 0),
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = content,
    })
    local right = Create('ScrollingFrame', {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 6, 0, 0),
        Size = UDim2.new(0.5, -6, 1, 0),
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = content,
    })
    local ll = Instance.new('UIListLayout', left)
    ll.Padding = UDim.new(0, 8)
    local rl = Instance.new('UIListLayout', right)
    rl.Padding = UDim.new(0, 8)

    local tab = {
        Btn = btn,
        Content = content,
        Left = left,
        Right = right,
    }

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(Tabs) do
            t.Content.Visible = false
            t.Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        content.Visible = true
        btn.TextColor3 = Library.AccentColor
        ActiveTab = tab
    end)

    table.insert(Tabs, tab)
    return tab
end

-- ============================================================
-- СЕКЦИЯ 6: GROUPBOX
-- ============================================================
local function AddGroupbox(tab, side, name)
    local parent = side == 'Left' and tab.Left or tab.Right
    local holder = Create('Frame', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })
    CreateLabel({
        Text = name,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Size = UDim2.new(1, 0, 0, 16),
        Parent = holder,
    })
    local container = Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = holder,
    })
    local s = Instance.new('UIStroke', container)
    s.Color = Library.OutlineColor
    local p = Instance.new('UIPadding', container)
    p.PaddingTop = UDim.new(0, 4)
    p.PaddingBottom = UDim.new(0, 4)
    p.PaddingLeft = UDim.new(0, 4)
    p.PaddingRight = UDim.new(0, 4)
    local l = Instance.new('UIListLayout', container)
    l.Padding = UDim.new(0, 4)
    return { Container = container, Holder = holder }
end

-- ============================================================
-- СЕКЦИЯ 7: КОМПОНЕНТЫ
-- ============================================================

-- Toggle
local function AddToggle(groupbox, idx, opts)
    opts = opts or {}
    local frame = Create('Frame', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Parent = groupbox.Container,
    })
    CreateLabel({
        Text = opts.Text or idx,
        Size = UDim2.new(1, -30, 1, 0),
        Parent = frame,
    })
    local box = Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor,
        Position = UDim2.new(1, -20, 0.5, -8),
        Size = UDim2.fromOffset(16, 16),
        Parent = frame,
    })
    local bs = Instance.new('UIStroke', box)
    bs.Color = Library.OutlineColor
    local fill = Create('Frame', {
        BackgroundColor3 = Library.AccentColor,
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(10, 10),
        Visible = false,
        Parent = box,
    })
    local value = opts.Default and true or false
    local function update()
        fill.Visible = value
        if opts.Callback then safeCall(opts.Callback, value) end
    end
    local btn = Create('TextButton', {
        Text = '',
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = frame,
    })
    btn.MouseButton1Click:Connect(function()
        value = not value
        update()
    end)
    local toggle = {
        Value = value,
        SetValue = function(v) value = v; update() end,
        GetValue = function() return value end,
    }
    Library.Toggles[idx] = toggle
    if value then update() end
    return toggle
end

-- Slider
local function AddSlider(groupbox, idx, opts)
    opts = opts or {}
    local frame = Create('Frame', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = groupbox.Container,
    })
    CreateLabel({
        Text = opts.Text or idx,
        Size = UDim2.new(1, -40, 0, 16),
        Parent = frame,
    })
    local valLabel = CreateLabel({
        Text = tostring(opts.Default or opts.Min or 0),
        Size = UDim2.new(0, 40, 0, 16),
        Position = UDim2.new(1, -40, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })
    local bar = Create('Frame', {
        BackgroundColor3 = Library.OutlineColor,
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 4),
        Parent = frame,
    })
    local fill = Create('Frame', {
        BackgroundColor3 = Library.AccentColor,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = bar,
    })
    local knob = Create('Frame', {
        BackgroundColor3 = Library.AccentColor,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(10, 10),
        Parent = bar,
    })
    local minV = opts.Min or 0
    local maxV = opts.Max or 100
    local value = opts.Default or minV
    local function update()
        local a = (value - minV) / (maxV - minV)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valLabel.Text = tostring(value)
        if opts.Callback then safeCall(opts.Callback, value) end
    end
    local btn = Create('TextButton', {
        Text = '',
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 16),
        Parent = frame,
    })
    local dragging = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            value = math.floor(minV + rel * (maxV - minV) + 0.5)
            update()
        end
    end)
    update()
    local slider = {
        Value = value,
        SetValue = function(v) value = v; update() end,
        GetValue = function() return value end,
    }
    Library.Options[idx] = slider
    return slider
end

-- Button
local function AddButton(groupbox, opts)
    opts = opts or {}
    local btn = Create('TextButton', {
        Text = opts.Text or 'Button',
        Font = Library.Font,
        TextSize = 13,
        TextColor3 = Library.FontColor,
        BackgroundColor3 = Library.BackgroundColor,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = groupbox.Container,
    })
    local s = Instance.new('UIStroke', btn)
    s.Color = Library.OutlineColor
    btn.MouseButton1Click:Connect(function()
        if opts.Func then safeCall(opts.Func) end
    end)
    return btn
end

-- Textbox
local function AddTextbox(groupbox, idx, opts)
    opts = opts or {}
    local frame = Create('Frame', {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 38),
        Parent = groupbox.Container,
    })
    CreateLabel({
        Text = opts.Text or idx,
        Size = UDim2.new(1, 0, 0, 14),
        Parent = frame,
    })
    local box = Create('TextBox', {
        Text = opts.Default or '',
        PlaceholderText = opts.Placeholder or '',
        Font = Library.Font,
        TextSize = 13,
        TextColor3 = Library.FontColor,
        BackgroundColor3 = Library.BackgroundColor,
        Position = UDim2.new(0, 0, 0, 16),
        Size = UDim2.new(1, 0, 0, 20),
        ClearTextOnFocus = false,
        Parent = frame,
    })
    local s = Instance.new('UIStroke', box)
    s.Color = Library.OutlineColor
    box.FocusLost:Connect(function()
        if opts.Callback then safeCall(opts.Callback, box.Text) end
    end)
    local tb = {
        Value = box.Text,
        SetValue = function(v) box.Text = v; tb.Value = v end,
        GetValue = function() return box.Text end,
    }
    Library.Options[idx] = tb
    return tb
end

-- Label
local function AddLabel(groupbox, text)
    return CreateLabel({
        Text = text,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Size = UDim2.new(1, 0, 0, 18),
        TextWrapped = true,
        Parent = groupbox.Container,
    })
end

-- ============================================================
-- СЕКЦИЯ 8: МОДУЛЬ FLY
-- ============================================================
local Fly = { Enabled = false, Speed = 50, _bv = nil, _bg = nil, _conn = nil }
function Fly:Enable()
    if self.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild('HumanoidRootPart')
    local hum = char:FindFirstChildOfClass('Humanoid')
    if not hrp or not hum then return end
    hum.PlatformStand = true
    self._bv = Instance.new('BodyVelocity', hrp)
    self._bv.MaxForce = Vector3.new(4000, 4000, 4000)
    self._bv.Velocity = Vector3.zero
    self._bg = Instance.new('BodyGyro', hrp)
    self._bg.MaxTorque = Vector3.new(4000, 4000, 4000)
    self._bg.P = 3000
    self._conn = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild('HumanoidRootPart')
        if not r then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
        self._bv.Velocity = move.Magnitude > 0 and move.Unit * self.Speed or Vector3.zero
        self._bg.CFrame = cam.CFrame
    end)
    self.Enabled = true
end
function Fly:Disable()
    self.Enabled = false
    if self._conn then self._conn:Disconnect(); self._conn = nil end
    if self._bv then self._bv:Destroy(); self._bv = nil end
    if self._bg then self._bg:Destroy(); self._bg = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum then hum.PlatformStand = false end
    end
end

-- ============================================================
-- СЕКЦИЯ 9: МОДУЛЬ SPEED
-- ============================================================
local Speed = { Enabled = false, _conn = nil, _target = 16, _current = 16 }
function Speed:Enable()
    if self.Enabled then return end
    self.Enabled = true
    self._conn = RunService.Heartbeat:Connect(function(dt)
        if not self.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass('Humanoid')
        if not hum then return end
        self._current = self._current + (self._target - self._current) * math.min(dt * 8, 1)
        if math.abs(self._current - self._target) < 0.5 then self._current = self._target end
        silentSet(hum, 'WalkSpeed', self._current)
    end)
end
function Speed:Disable()
    self.Enabled = false
    if self._conn then self._conn:Disconnect(); self._conn = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum then silentSet(hum, 'WalkSpeed', 16) end
    end
end

-- ============================================================
-- СЕКЦИЯ 10: МОДУЛЬ BHOP (разгон)
-- ============================================================
local Bhop = {
    Enabled = false,
    Gain = 0.5,
    Friction = 0.98,
    MaxSpeed = 120,
    AutoJump = true,
    Preserve = true,
    _conn = nil,
    _wasAir = false,
}
function Bhop:Enable()
    if self.Enabled then return end
    self.Enabled = true
    self._conn = RunService.Heartbeat:Connect(function(dt)
        if not self.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass('Humanoid')
        local hrp = char:FindFirstChild('HumanoidRootPart')
        if not hum or not hrp or hum.Health <= 0 then return end
        local inAir = hum.FloorMaterial == Enum.Material.Air
        local v = hrp.AssemblyLinearVelocity
        local hvel = Vector3.new(v.X, 0, v.Z)
        local speed = hvel.Magnitude
        if inAir then
            if speed > 0.5 and speed < self.MaxSpeed then
                local newSpeed = math.min(speed + self.Gain * (dt * 60), self.MaxSpeed)
                local dir = hvel.Unit
                hrp.AssemblyLinearVelocity = Vector3.new(dir.X * newSpeed, v.Y, dir.Z * newSpeed)
            end
            self._wasAir = true
        else
            if self._wasAir and self.Preserve and speed > 0.5 then
                local kept = math.min(speed * self.Friction, self.MaxSpeed)
                local dir = hvel.Unit
                hrp.AssemblyLinearVelocity = Vector3.new(dir.X * kept, v.Y, dir.Z * kept)
            end
            self._wasAir = false
            if self.AutoJump and UIS:IsKeyDown(Enum.KeyCode.Space) then
                hum.Jump = true
            end
        end
    end)
end
function Bhop:Disable()
    self.Enabled = false
    if self._conn then self._conn:Disconnect(); self._conn = nil end
    self._wasAir = false
end

-- ============================================================
-- СЕКЦИЯ 11: МОДУЛЬ NOCLIP
-- ============================================================
local Noclip = { Enabled = false, _conn = nil }
function Noclip:Enable()
    if self.Enabled then return end
    self.Enabled = true
    self._conn = RunService.Stepped:Connect(function()
        if not self.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA('BasePart') then
                part.CanCollide = false
            end
        end
    end)
end
function Noclip:Disable()
    self.Enabled = false
    if self._conn then self._conn:Disconnect(); self._conn = nil end
end

-- ============================================================
-- СЕКЦИЯ 12: МОДУЛЬ SPINBOT
-- ============================================================
local SpinBot = { Enabled = false, Speed = 10, _conn = nil, _angle = 0 }
function SpinBot:Enable()
    if self.Enabled then return end
    self.Enabled = true
    self._conn = RunService.RenderStepped:Connect(function(dt)
        if not self.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild('HumanoidRootPart')
        if not hrp then return end
        self._angle = self._angle + math.rad(self.Speed) * dt * 60
        silentSet(hrp, 'CFrame', CFrame.new(hrp.Position) * CFrame.Angles(0, self._angle, 0))
    end)
end
function SpinBot:Disable()
    self.Enabled = false
    if self._conn then self._conn:Disconnect(); self._conn = nil end
end

-- ============================================================
-- СЕКЦИЯ 13: МОДУЛЬ ESP
-- ============================================================
local ESP = {
    Enabled = false,
    Box = true,
    Name = true,
    Health = true,
    Distance = true,
    MaxDistance = 1000,
    _drawings = {},
    _conn = nil,
    _available = (Drawing ~= nil),
}

if not ESP._available then
    warn('[H3Y0 CH1LL] Drawing недоступен — ESP отключён.')
end

local function createDrawings()
    return {
        Box = Drawing.new('Square'),
        Name = Drawing.new('Text'),
        HealthBg = Drawing.new('Square'),
        HealthFg = Drawing.new('Square'),
        Distance = Drawing.new('Text'),
    }
end

local function initDrawings(d)
    d.Box.Thickness = 1
    d.Box.Color = Color3.fromRGB(162, 205, 255)
    d.Box.Filled = false
    d.Box.Visible = false

    d.Name.Size = 13
    d.Name.Color = Color3.fromRGB(255, 255, 255)
    d.Name.Center = true
    d.Name.Outline = true
    d.Name.Visible = false

    d.HealthBg.Thickness = 1
    d.HealthBg.Color = Color3.fromRGB(0, 0, 0)
    d.HealthBg.Filled = true
    d.HealthBg.Visible = false

    d.HealthFg.Thickness = 1
    d.HealthFg.Color = Color3.fromRGB(0, 255, 0)
    d.HealthFg.Filled = true
    d.HealthFg.Visible = false

    d.Distance.Size = 11
    d.Distance.Color = Color3.fromRGB(180, 180, 180)
    d.Distance.Center = true
    d.Distance.Outline = true
    d.Distance.Visible = false
end

local function hideDrawings(d)
    if not d then return end
    for _, obj in pairs(d) do pcall(function() obj.Visible = false end) end
end

local function destroyDrawings(d)
    if not d then return end
    for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
end

local function updateESP()
    if not ESP._available then return end
    if not ESP.Enabled then
        for _, d in pairs(ESP._drawings) do hideDrawings(d) end
        return
    end

    local cam = workspace.CurrentCamera
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            if ESP._drawings[player] then
                destroyDrawings(ESP._drawings[player])
                ESP._drawings[player] = nil
            end
        else
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass('Humanoid')
            local hrp = char and char:FindFirstChild('HumanoidRootPart')
            local ok = hum and hrp and hum.Health > 0

            if ok then
                local dist = (cam.CFrame.Position - hrp.Position).Magnitude
                if dist > ESP.MaxDistance then ok = false end
            end

            if ok then
                local headScreen, headOn = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 1.5, 0))
                local legScreen, legOn = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                if headOn and legOn then
                    if not ESP._drawings[player] then
                        local d = createDrawings()
                        initDrawings(d)
                        ESP._drawings[player] = d
                    end
                    local d = ESP._drawings[player]
                    local h = math.abs(legScreen.Y - headScreen.Y)
                    local w = h * 0.55
                    local x = headScreen.X - w / 2
                    local y = headScreen.Y

                    -- Box
                    d.Box.Visible = ESP.Box
                    if ESP.Box then
                        d.Box.Size = Vector2.new(w, h)
                        d.Box.Position = Vector2.new(x, y)
                    end

                    -- Name
                    d.Name.Visible = ESP.Name
                    if ESP.Name then
                        d.Name.Text = player.Name
                        d.Name.Position = Vector2.new(x + w / 2, y - 14)
                    end

                    -- Health
                    d.HealthBg.Visible = ESP.Health
                    d.HealthFg.Visible = ESP.Health
                    if ESP.Health then
                        local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        local barH = h
                        local barW = 3
                        local bx = x - 6
                        d.HealthBg.Size = Vector2.new(barW, barH)
                        d.HealthBg.Position = Vector2.new(bx, y)
                        local fgH = barH * hp
                        d.HealthFg.Size = Vector2.new(barW, fgH)
                        d.HealthFg.Position = Vector2.new(bx, y + (barH - fgH))
                        if hp > 0.5 then
                            d.HealthFg.Color = Color3.fromRGB(0, 255, 0)
                        elseif hp > 0.25 then
                            d.HealthFg.Color = Color3.fromRGB(255, 255, 0)
                        else
                            d.HealthFg.Color = Color3.fromRGB(255, 0, 0)
                        end
                    end

                    -- Distance
                    d.Distance.Visible = ESP.Distance
                    if ESP.Distance then
                        d.Distance.Text = string.format('[%d]', math.floor(dist))
                        d.Distance.Position = Vector2.new(x + w / 2, y + h + 2)
                    end
                else
                    hideDrawings(ESP._drawings[player])
                end
            else
                hideDrawings(ESP._drawings[player])
            end
        end
    end
end

function ESP:Enable()
    if not self._available then
        warn('[H3Y0 CH1LL] ESP недоступен: нет Drawing API')
        return
    end
    if self.Enabled then return end
    self.Enabled = true
    if not self._conn then
        self._conn = RunService.RenderStepped:Connect(updateESP)
    end
end
function ESP:Disable()
    self.Enabled = false
    for p, d in pairs(self._drawings) do
        destroyDrawings(d)
        self._drawings[p] = nil
    end
end

-- ============================================================
-- СЕКЦИЯ 14: SKIN CHANGER
-- ============================================================
local SkinChanger = { _busy = false }

function SkinChanger:ApplyByUsername(username)
    if self._busy then
        warn('[H3Y0 CH1LL] Skin changer занят')
        return
    end
    if not username or username == '' then
        warn('[H3Y0 CH1LL] Введи username')
        return
    end
    self._busy = true
    task.spawn(function()
        local okId, userId = pcall(function()
            return Players:GetUserIdFromNameAsync(username)
        end)
        if not okId or not userId then
            warn('[H3Y0 CH1LL] Юзер не найден: ' .. tostring(username))
            self._busy = false
            return
        end
        print('[H3Y0 CH1LL] UserId: ' .. tostring(userId))

        local okDesc, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(userId)
        end)
        if not okDesc or not desc then
            warn('[H3Y0 CH1LL] Не удалось получить описание аватара')
            self._busy = false
            return
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        if not hum then
            warn('[H3Y0 CH1LL] Нет персонажа/Humanoid')
            self._busy = false
            return
        end

        local okApply, err = pcall(function()
            hum:ApplyDescriptionReset(desc)
        end)
        if okApply then
            print('[H3Y0 CH1LL] Скин применён: ' .. username)
        else
            warn('[H3Y0 CH1LL] Ошибка ApplyDescriptionReset: ' .. tostring(err))
        end
        self._busy = false
    end)
end

function SkinChanger:ResetToSelf()
    local userId = LocalPlayer.UserId
    local ok, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if ok and desc then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        if hum then
            pcall(function() hum:ApplyDescriptionReset(desc) end)
            print('[H3Y0 CH1LL] Скин сброшен на свой')
        end
    end
end

-- ============================================================
-- СЕКЦИЯ 15: СБОРКА МЕНЮ
-- ============================================================

-- ===== ВКЛАДКА MOVEMENT =====
local TabMove = AddTab('Movement')
local gbMove = AddGroupbox(TabMove, 'Left', 'Movement')
local gbBhop = AddGroupbox(TabMove, 'Right', 'Bhop Tuning')

AddToggle(gbMove, 'fly_enabled', {
    Text = 'Fly',
    Default = false,
    Callback = function(v) if v then Fly:Enable() else Fly:Disable() end end,
})
AddSlider(gbMove, 'fly_speed', {
    Text = 'Fly Speed',
    Min = 10, Max = 200, Default = 50,
    Callback = function(v) Fly.Speed = v end,
})
AddToggle(gbMove, 'speed_enabled', {
    Text = 'Speed',
    Default = false,
    Callback = function(v) if v then Speed:Enable() else Speed:Disable() end end,
})
AddSlider(gbMove, 'speed_value', {
    Text = 'Speed Value',
    Min = 16, Max = 300, Default = 32,
    Callback = function(v) Speed._target = v end,
})
AddToggle(gbMove, 'noclip_enabled', {
    Text = 'Noclip',
    Default = false,
    Callback = function(v) if v then Noclip:Enable() else Noclip:Disable() end end,
})
AddToggle(gbMove, 'spin_enabled', {
    Text = 'SpinBot',
    Default = false,
    Callback = function(v) if v then SpinBot:Enable() else SpinBot:Disable() end end,
})
AddSlider(gbMove, 'spin_speed', {
    Text = 'Spin Speed',
    Min = 1, Max = 50, Default = 10,
    Callback = function(v) SpinBot.Speed = v end,
})
AddButton(gbMove, {
    Text = 'Stop All Movement',
    Func = function()
        Fly:Disable()
        Speed:Disable()
        Bhop:Disable()
        Noclip:Disable()
        SpinBot:Disable()
        -- сброс UI toggle'ов, чтобы не висели в положении "on"
        for _, id in ipairs({'fly_enabled','speed_enabled','noclip_enabled','spin_enabled','bhop_enabled'}) do
            local t = Library.Toggles[id]
            if t then t.SetValue(false) end
        end
    end,
})

AddToggle(gbBhop, 'bhop_enabled', {
    Text = 'Bhop',
    Default = false,
    Callback = function(v) if v then Bhop:Enable() else Bhop:Disable() end end,
})
AddSlider(gbBhop, 'bhop_gain', {
    Text = 'Gain (разгон)',
    Min = 0, Max = 3, Default = 0.5,
    Callback = function(v) Bhop.Gain = v end,
})
AddSlider(gbBhop, 'bhop_friction', {
    Text = 'Friction (сохранение)',
    Min = 0.5, Max = 1.0, Default = 0.98,
    Callback = function(v) Bhop.Friction = v end,
})
AddSlider(gbBhop, 'bhop_maxspeed', {
    Text = 'Max Speed',
    Min = 20, Max = 300, Default = 120,
    Callback = function(v) Bhop.MaxSpeed = v end,
})
AddToggle(gbBhop, 'bhop_autojump', {
    Text = 'Auto Jump (hold Space)',
    Default = true,
    Callback = function(v) Bhop.AutoJump = v end,
})
AddToggle(gbBhop, 'bhop_preserve', {
    Text = 'Preserve Momentum',
    Default = true,
    Callback = function(v) Bhop.Preserve = v end,
})

-- ===== ВКЛАДКА VISUALS =====
local TabVisual = AddTab('Visuals')
local gbEspToggle = AddGroupbox(TabVisual, 'Left', 'ESP')
local gbEspParts = AddGroupbox(TabVisual, 'Right', 'ESP Elements')

AddToggle(gbEspToggle, 'esp_enabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(v) if v then ESP:Enable() else ESP:Disable() end end,
})
AddSlider(gbEspToggle, 'esp_maxdist', {
    Text = 'Max Distance',
    Min = 100, Max = 5000, Default = 1000,
    Callback = function(v) ESP.MaxDistance = v end,
})
AddButton(gbEspToggle, {
    Text = 'Refresh ESP',
    Func = function()
        ESP:Disable()
        ESP:Enable()
    end,
})

AddToggle(gbEspParts, 'esp_box', {
    Text = 'Box',
    Default = true,
    Callback = function(v) ESP.Box = v end,
})
AddToggle(gbEspParts, 'esp_name', {
    Text = 'Name',
    Default = true,
    Callback = function(v) ESP.Name = v end,
})
AddToggle(gbEspParts, 'esp_health', {
    Text = 'Health',
    Default = true,
    Callback = function(v) ESP.Health = v end,
})
AddToggle(gbEspParts, 'esp_distance', {
    Text = 'Distance',
    Default = true,
    Callback = function(v) ESP.Distance = v end,
})

-- ===== ВКЛАДКА SKIN =====
local TabSkin = AddTab('Skin')
local gbSkin = AddGroupbox(TabSkin, 'Left', 'Skin By Username')
local gbSkinInfo = AddGroupbox(TabSkin, 'Right', 'Info')

AddTextbox(gbSkin, 'skin_username', {
    Text = 'Username',
    Placeholder = 'Roblox username',
    Default = '',
})
AddButton(gbSkin, {
    Text = 'Apply Skin',
    Func = function()
        local tb = Library.Options['skin_username']
        if tb then SkinChanger:ApplyByUsername(tb.Value) end
    end,
})
AddButton(gbSkin, {
    Text = 'Reset To My Avatar',
    Func = function() SkinChanger:ResetToSelf() end,
})

AddLabel(gbSkinInfo,
    'Работает только на твоего персонажа.\n' ..
    'Чужой скин по username — для СЕБЯ.\n' ..
    'На других игроков с клиента применить нельзя.\n\n' ..
    'Введи username -> Apply Skin'
)

-- ===== ВКЛАДКА SETTINGS =====
local TabSettings = AddTab('Settings')
local gbSettings = AddGroupbox(TabSettings, 'Left', 'Misc')

AddButton(gbSettings, {
    Text = 'Unload (Panic)',
    Func = function()
        Fly:Disable()
        Speed:Disable()
        Bhop:Disable()
        Noclip:Disable()
        SpinBot:Disable()
        ESP:Disable()
        if Library.ScreenGui then
            pcall(function() Library.ScreenGui:Destroy() end)
        end
        control.status = 'unloaded'
        if getgenv then getgenv()['H3Y0 CH1LL'] = nil end
    end,
})
AddButton(gbSettings, {
    Text = 'Rejoin',
    Func = function()
        local Teleport = game:GetService('TeleportService')
        pcall(function()
            Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end,
})
AddButton(gbSettings, {
    Text = 'Copy JobId',
    Func = function()
        if setclipboard then
            pcall(setclipboard, tostring(game.JobId))
            print('[H3Y0 CH1LL] JobId скопирован')
        end
    end,
})

-- ============================================================
-- СЕКЦИЯ 16: ЗАПУСК
-- ============================================================

-- Открываем первую вкладку
if Tabs[1] then
    Tabs[1].Content.Visible = true
    Tabs[1].Btn.TextColor3 = Library.AccentColor
    ActiveTab = Tabs[1]
end

-- Экспортируем наружу для отладки
if getgenv then
    getgenv().H3Y0 = {
        Fly = Fly,
        Speed = Speed,
        Bhop = Bhop,
        Noclip = Noclip,
        SpinBot = SpinBot,
        ESP = ESP,
        SkinChanger = SkinChanger,
    }
end

control.status = 'loaded'
print('[H3Y0 CH1LL] Hub v3 loaded. RightControl/Insert to toggle.')
