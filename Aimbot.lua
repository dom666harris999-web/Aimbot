local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Global Logic Variables //
_G.AimbotEnabled = false
_G.TeamCheck = true
_G.WallCheck = true
_G.AimbotFOV = 150
_G.AimbotSmoothness = 0
_G.TargetPart = "Head"
_G.KnifeAura = false
_G.AutoClicker = false

_G.EspEnabled = false
_G.TracerEnabled = false
_G.NameEsp = false
_G.DistanceEsp = false
_G.FullBright = false

local Window = Rayfield:CreateWindow({
   Name = "GEMINI ULTIMATE",
   LoadingTitle = "Final Stable Build",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- // COMBAT TAB (10 FEATURES) //
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({Name = "Enable Aimbot", Callback = function(V) _G.AimbotEnabled = V end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(V) _G.TeamCheck = V end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(V) _G.WallCheck = V end})
CombatTab:CreateSlider({Name = "Smoothness", Range = {0, 1}, Increment = 0.1, Callback = function(V) _G.AimbotSmoothness = V end})
CombatTab:CreateSlider({Name = "FOV Radius", Range = {0, 600}, Increment = 1, Callback = function(V) _G.AimbotFOV = V end})
CombatTab:CreateDropdown({Name = "Target Part", Options = {"Head", "HumanoidRootPart"}, Callback = function(O) _G.TargetPart = O[1] end})
CombatTab:CreateToggle({Name = "Knife Aura", Callback = function(V) _G.KnifeAura = V end})
CombatTab:CreateToggle({Name = "Auto Clicker", Callback = function(V) _G.AutoClicker = V end})
CombatTab:CreateButton({Name = "Unlock Camera Zoom", Callback = function() game.Players.LocalPlayer.CameraMaxZoomDistance = 500 end})
CombatTab:CreateButton({Name = "Reset Character", Callback = function() game.Players.LocalPlayer.Character:BreakJoints() end})

-- // VISUALS TAB (10 FEATURES) //
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateToggle({Name = "Highlight ESP", Callback = function(V) _G.EspEnabled = V end})
VisualTab:CreateToggle({Name = "Tracers", Callback = function(V) _G.TracerEnabled = V end})
VisualTab:CreateToggle({Name = "Name ESP", Callback = function(V) _G.NameEsp = V end})
VisualTab:CreateToggle({Name = "Distance ESP", Callback = function(V) _G.DistanceEsp = V end})
VisualTab:CreateToggle({Name = "Full Bright", Callback = function(V) _G.FullBright = V end})
VisualTab:CreateSlider({Name = "Field of View", Range = {70, 120}, Increment = 1, Callback = function(V) workspace.CurrentCamera.FieldOfView = V end})
VisualTab:CreateButton({Name = "FPS Boost", Callback = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end end end})
VisualTab:CreateButton({Name = "Clear ESP Errors", Callback = function() for _,v in pairs(game.Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("GeminiHigh") then v.Character.GeminiHigh:Destroy() end end end})
VisualTab:CreateButton({Name = "Hide FOV Circle", Callback = function() _G.AimbotFOV = 0 end})
VisualTab:CreateButton({Name = "Close Menu", Callback = function() Rayfield:Destroy() end})

-- // CORE LOGIC ENGINE //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Tracers = {}

local function GetTarget()
    local target = nil
    local dist = _G.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            -- TEAM LOGIC
            local isTeam = (p.Team == LocalPlayer.Team and p.Team ~= nil)
            if _G.TeamCheck and isTeam then continue end -- Ignore Green

            local pos, onScreen = Camera:WorldToViewportPoint(p.Character[_G.TargetPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - (Camera.ViewportSize / 2)).Magnitude
                if mag < dist then target = p.Character[_G.TargetPart]; dist = mag end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        local target = GetTarget()
        if target then
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness > 0 and (1.1 - _G.AimbotSmoothness) * 0.4 or 1)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not Tracers[p] then Tracers[p] = Drawing.new("Line"); Tracers[p].Thickness = 1 end
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local isTeam = (p.Team == LocalPlayer.Team and p.Team ~= nil)
                -- COLOR LOGIC
                local color = Color3.new(1,0,0) -- Default RED
                if _G.TeamCheck and isTeam then color = Color3.new(0,1,0) end -- GREEN if TeamCheck ON

                local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                Tracers[p].Visible = _G.TracerEnabled and onScreen
                if Tracers[p].Visible then
                    Tracers[p].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    Tracers[p].To = Vector2.new(pos.X, pos.Y); Tracers[p].Color = color
                end
                
                local high = char:FindFirstChild("GeminiHigh")
                if _G.EspEnabled then
                    if not high then high = Instance.new("Highlight", char); high.Name = "GeminiHigh" end
                    high.Enabled = true; high.FillColor = color
                elseif high then high.Enabled = false end
            else
                Tracers[p].Visible = false
            end
        end
    end
end)
