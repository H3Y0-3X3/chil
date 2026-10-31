--===================================================================================--
--      UNNAMED ENHANCEMENTS (VISUAL SUITE) - PART 2: GAMEPLAY HOOKS                 --
--===================================================================================--
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local OriginalLighting = {
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, ClockTime = Lighting.ClockTime
}
local HighlightStorage = {}
local chromaHue = 0

RunService.RenderStepped:Connect(function(dt)
    if not _G.UE_Config then return end
    
    Camera.FieldOfView = _G.UE_Config.CustomFOV
    
    if _G.UE_Config.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
    
    if _G.UE_Config.TimeChanger then Lighting.ClockTime = _G.UE_Config.TargetTime
    else Lighting.ClockTime = OriginalLighting.ClockTime end

    if _G.UE_Config.VmChroma then 
        chromaHue = (chromaHue + (dt * _G.UE_Config.ChromaSpeed * 0.05)) % 1 
    end
    local currentRGB = Color3.fromHSV(chromaHue, 1, 1)

    -- Манипуляции с оружием и руками (Viewmodel)
    local viewmodel = Camera:FindFirstChildOfClass("Model") or Camera:FindFirstChild("ViewModel")
    if viewmodel then
        local cfOffset = CFrame.new(_G.UE_Config.X, _G.UE_Config.Y, _G.UE_Config.Z) * 
                         CFrame.Angles(math.rad(_G.UE_Config.Pitch), math.rad(_G.UE_Config.Yaw), math.rad(_G.UE_Config.Roll))
        
        if _G.UE_Config.DisableBobbing or _G.UE_Config.DisableSway then
            viewmodel:PivotTo(Camera.CFrame * cfOffset)
        end
        
        for _, part in ipairs(viewmodel:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                if part.Name == "Left Arm" then part.Transparency = _G.UE_Config.LeftArmTrans
                elseif part.Name == "Right Arm" then part.Transparency = _G.UE_Config.RightArmTrans
                elseif part.Name == "UpperTorso" then part.Transparency = _G.UE_Config.HideUpperTorso and 1 or 0
                elseif part.Name == "LeftHand" or part.Name == "RightHand" then part.Transparency = _G.UE_Config.HandTrans
                else
                    if _G.UE_Config.VmWireframe then
                        part.Material = Enum.Material.ForceField
                        part.Transparency = _G.UE_Config.VmFillOpacity
                        if _G.UE_Config.VmChroma then part.Color = currentRGB end
                    else
                        part.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end
    end

    -- Обработка игроков (Chams / ESP)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            
            if _G.UE_Config.EspEnabled and _G.UE_Config.ChamsEnabled then
                local highlight = HighlightStorage[player]
                if not highlight or highlight.Parent ~= char then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "UE_Cham"
                    highlight.Parent = char
                    HighlightStorage[player] = highlight
                end
                highlight.Enabled = true
                highlight.FillColor = _G.UE_Config.VmChroma and currentRGB or Color3.fromRGB(0, 160, 255)
                highlight.FillTransparency = _G.UE_Config.ChamsFillOpacity
                highlight.OutlineTransparency = _G.UE_Config.ChamsWireframe and 0 or 1
            else
                if HighlightStorage[player] then HighlightStorage[player].Enabled = false end
            end
            
            if _G.UE_Config.EspEnabled and _G.UE_Config.LookDirection then
                if not hrp:FindFirstChild("UE_LookBeam") then
                    local att0 = Instance.new("Attachment", hrp)
                    local att1 = Instance.new("Attachment", hrp)
                    att1.Position = Vector3.new(0, 0, -15)
                    local beam = Instance.new("Beam", hrp)
                    beam.Name = "UE_LookBeam"
                    beam.Attachment0 = att0 beam.Attachment1 = att1
                    beam.Width0 = 0.15 beam.Width1 = 0.15
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                    beam.FaceCamera = true
                end
            else
                if hrp:FindFirstChild("UE_LookBeam") then hrp.UE_LookBeam:Destroy() end
            end
        end
    end
end)
