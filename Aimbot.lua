local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // GLOBAL SETTINGS //
_G.AimbotEnabled = false
_G.TeamCheck = true
_G.WallCheck = true
_G.AimbotFOV = 100
_G.AimbotSmoothness = 0
_G.TargetPart = "Head"
_G.KnifeAura = false
_G.AutoClicker = false
_G.Noclip = false

_G.EspEnabled = false
_G.TracerEnabled = false
_G.NameEsp = false
_G.DistanceEsp = false
_G.FullBright = false

local Window = Rayfield:CreateWindow({
   Name = "GEMINI ULTIMATE",
   LoadingTitle = "Cooking Final Build...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = true, FolderName = "GeminiConfig", FileName = "UltimateHub" }
})

-- // COMBAT TAB (10 FEATURES) //
local MainTab = Window:CreateTab("Combat", 4483362458)
MainTab:CreateSection("Targeting")
MainTab:CreateToggle({Name = "1. Instant Aimbot", Callback = function(V) _G.AimbotEnabled = V end})
MainTab:CreateToggle({Name = "2. Team Check", CurrentValue = true, Callback = function(V) _G.TeamCheck = V end})
MainTab:CreateToggle({Name = "3. Wall Check", CurrentValue = true, Callback = function(V) _G.WallCheck = V end})
MainTab:CreateSlider({Name = "4. Smoothness", Range = {0, 1}, Increment = 0.1, CurrentValue = 0, Callback = function(V) _G.AimbotSmoothness = V end})
MainTab:CreateSlider({Name = "5. FOV Radius", Range = {0, 600}, Increment = 1, CurrentValue = 100, Callback = function(V) _G.AimbotFOV = V end})
MainTab:CreateDropdown({Name = "6. Target Part", Options = {"Head", "HumanoidRootPart"}, CurrentOption = "Head", Callback = function(O) _G.TargetPart = O[1] end})
MainTab:CreateSection("Utilities")
MainTab:CreateToggle({Name = "7. Knife Aura", Callback = function(V) _G.KnifeAura = V end})
MainTab:CreateToggle({Name = "8. Auto Clicker", Callback = function(V) _G.AutoClicker = V end})
MainTab:CreateToggle({Name = "9. Noclip", Callback = function(V) _G.Noclip = V end})
MainTab:CreateButton({Name = "10. Reset Character", Callback = function() game.Players.LocalPlayer.Character:BreakJoints() end})

-- // VISUALS TAB (10 FEATURES) //
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({Name = "1. Highlight ESP", Callback = function(V) _G.EspEnabled = V end})
VisualTab:CreateToggle({Name = "2. Tracers", Callback = function(V) _G.TracerEnabled = V end})
VisualTab:CreateToggle({Name = "3. Name ESP", Callback = function(V) _G.NameEsp = V end})
VisualTab:CreateToggle({Name = "4. Distance ESP", Callback = function(V) _G.DistanceEsp = V end})
VisualTab:CreateSection("Environment")
VisualTab:CreateToggle({Name = "5. Full Bright", Callback = function(V) _G.FullBright = V end})
VisualTab:CreateSlider({Name = "6. Field of View", Range = {70, 120}, Increment = 1, CurrentValue = 70, Callback = function(V) workspace.CurrentCamera.FieldOfView = V end})
VisualTab:CreateButton({Name = "7. Max Zoom Distance", Callback = function() game.Players.LocalPlayer.CameraMaxZoomDistance = 500 end})
VisualTab:CreateButton({Name = "8. Remove Textures (FPS)", Callback = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end end end})
VisualTab:CreateButton({Name = "9. Clear ESP Errors", Callback = function() for _,v in pairs(game.Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("GeminiHigh") then v.Character.GeminiHigh:Destroy() end end end})
VisualTab:CreateButton({Name = "10. Destroy GUI", Callback = function() Rayfield:Destroy() end})

-- // LOGIC CORE //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Filled = false

local Tracers = {}
local Names = {}

-- Stable Wall Check
local function IsVisible(part, char)
    if not _G.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, char, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    return result == nil
end

-- Stable Target Logic
local function GetClosestTarget()
    local target = nil
    local shortestDist = _G.AimbotFOV
    local center = Camera.ViewportSize / 2
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.TargetPart) then
            if _G.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local part = player.Character[_G.TargetPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and IsVisible(part, player.Character) then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortestDist then target = part; shortestDist = dist end
            end
        end
    end
    return target
end

-- RenderStepped Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Visible = _G.AimbotEnabled

    if _G.AimbotEnabled then
        local targetPart = GetClosestTarget()
        if targetPart then
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness > 0 and (1.1 - _G.AimbotSmoothness) * 0.4 or 1)
        end
    end

    if _G.FullBright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
    end

    if _G.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- Visuals
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local isTeammate = (player.Team ~= nil and player.Team == LocalPlayer.Team)
                local color = isTeammate and Color3.new(0,1,0) or Color3.new(1,0,0)
                local hrp = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                -- Highlights
                local high = char:FindFirstChild("GeminiHigh")
                if _G.EspEnabled and onScreen and not (_G.TeamCheck and isTeammate) then
                    if not high then high = Instance.new("Highlight", char); high.Name = "GeminiHigh" end
                    high.Enabled = true; high.FillColor = color
                elseif high then high.Enabled = false end

                -- Tracers
                if not Tracers[player] then Tracers[player] = Drawing.new("Line") end
                Tracers[player].Visible = _G.TracerEnabled and onScreen and not (_G.TeamCheck and isTeammate)
                if Tracers[player].Visible then
                    Tracers[player].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    Tracers[player].To = Vector2.new(pos.X, pos.Y)
                    Tracers[player].Color = color
                end
            end
        end
    end
end)
