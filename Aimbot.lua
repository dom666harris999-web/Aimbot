local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // GLOBAL SETTINGS //
_G.AimbotEnabled = false
_G.TeamCheck = true
_G.WallCheck = true
_G.AimbotFOV = 100
_G.AimbotSmoothness = 0
_G.TargetPart = "Head"
_G.KnifeAura = false

_G.EspEnabled = false
_G.TracerEnabled = false

local Window = Rayfield:CreateWindow({
   Name = "GEMINI ULTIMATE",
   LoadingTitle = "Aimbot: RED ONLY Mode",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- // COMBAT TAB //
local MainTab = Window:CreateTab("Combat", 4483362458)
MainTab:CreateToggle({Name = "Enable Aimbot", Callback = function(V) _G.AimbotEnabled = V end})
MainTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(V) _G.TeamCheck = V end})
MainTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(V) _G.WallCheck = V end})
MainTab:CreateSlider({Name = "Smoothness", Range = {0, 1}, Increment = 0.1, Callback = function(V) _G.AimbotSmoothness = V end})
MainTab:CreateSlider({Name = "FOV Radius", Range = {0, 600}, Increment = 1, Callback = function(V) _G.AimbotFOV = V end})
MainTab:CreateDropdown({Name = "Target Part", Options = {"Head", "HumanoidRootPart"}, Callback = function(O) _G.TargetPart = O[1] end})
MainTab:CreateToggle({Name = "Knife Aura", Callback = function(V) _G.KnifeAura = V end})
MainTab:CreateButton({Name = "Reset Camera", Callback = function() workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid end})
MainTab:CreateButton({Name = "Unlock Third Person", Callback = function() game.Players.LocalPlayer.CameraMaxZoomDistance = 500 end})
MainTab:CreateButton({Name = "Reset Character", Callback = function() game.Players.LocalPlayer.Character:BreakJoints() end})

-- // VISUALS TAB //
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateToggle({Name = "Highlight ESP", Callback = function(V) _G.EspEnabled = V end})
VisualTab:CreateToggle({Name = "Tracers", Callback = function(V) _G.TracerEnabled = V end})
-- (Add 8 more buttons here for your 10/10 layout)

-- // LOGIC CORE //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local Tracers = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Visible = true

local function IsVisible(part, char)
    if not _G.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, char, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return result == nil
end

local function GetClosestTarget()
    local target = nil
    local shortestDist = _G.AimbotFOV
    local center = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.TargetPart) then
            -- AIMBOT RED-ONLY LOGIC
            local isTeammate = (player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team)
            
            -- If Team Check is ON, skip teammates (because they are Green)
            if _G.TeamCheck and isTeammate then continue end
            
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end

            local part = player.Character[_G.TargetPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)

            if onScreen and IsVisible(part, player.Character) then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortestDist then
                    target = part
                    shortestDist = dist
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Visible = _G.AimbotEnabled

    -- Aimbot Execution
    if _G.AimbotEnabled then
        local targetPart = GetClosestTarget()
        if targetPart then
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness > 0 and (1.1 - _G.AimbotSmoothness) * 0.4 or 1)
        end
    end

    -- Visuals Execution
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if not Tracers[player] then Tracers[player] = Drawing.new("Line") end
            local line = Tracers[player]

            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local isTeammate = (player.Team ~= nil and player.Team == LocalPlayer.Team)
                
                -- COLOR SWAP LOGIC
                local finalColor = Color3.new(1, 0, 0) -- Red
                if _G.TeamCheck and isTeammate then
                    finalColor = Color3.new(0, 1, 0) -- Green
                end

                -- Tracers
                if _G.TracerEnabled and onScreen then
                    line.Visible = true
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Color = finalColor
                else
                    line.Visible = false
                end

                -- Highlights
                local high = char:FindFirstChild("GeminiHigh")
                if _G.EspEnabled then
                    if not high then high = Instance.new("Highlight", char); high.Name = "GeminiHigh" end
                    high.Enabled = true; high.FillColor = finalColor
                elseif high then
                    high.Enabled = false
                end
            else
                line.Visible = false
            end
        end
    end
end)
