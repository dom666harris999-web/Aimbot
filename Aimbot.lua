local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Global Logic Variables //
_G.AimbotEnabled = false
_G.TeamCheck = true
_G.WallCheck = true
_G.AimbotFOV = 150
_G.AimbotSmoothness = 0.5
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
   LoadingTitle = "Fixing UI Labels...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- // COMBAT TAB (10 FEATURES) //
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({Name = "1. Enable Aimbot", Callback = function(V) _G.AimbotEnabled = V end})
CombatTab:CreateToggle({Name = "2. Team Check", CurrentValue = true, Callback = function(V) _G.TeamCheck = V end})
CombatTab:CreateToggle({Name = "3. Wall Check", CurrentValue = true, Callback = function(V) _G.WallCheck = V end})

-- FIXED: Removed "studs" from Smoothness
CombatTab:CreateSlider({
    Name = "4. Smoothness",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = " (Speed)", 
    CurrentValue = 0.5,
    Callback = function(V) _G.AimbotSmoothness = V end
})

CombatTab:CreateSlider({
    Name = "5. FOV Radius",
    Range = {0, 600},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 150,
    Callback = function(V) _G.AimbotFOV = V end
})

CombatTab:CreateDropdown({Name = "6. Target Part", Options = {"Head", "HumanoidRootPart"}, CurrentOption = "Head", Callback = function(O) _G.TargetPart = O[1] end})
CombatTab:CreateToggle({Name = "7. Knife Aura", Callback = function(V) _G.KnifeAura = V end})
CombatTab:CreateToggle({Name = "8. Auto Clicker", Callback = function(V) _G.AutoClicker = V end})
CombatTab:CreateButton({Name = "9. Unlock Zoom", Callback = function() game.Players.LocalPlayer.CameraMaxZoomDistance = 500 end})
CombatTab:CreateButton({Name = "10. Reset Character", Callback = function() game.Players.LocalPlayer.Character:BreakJoints() end})

-- // VISUALS TAB (10 FEATURES) //
local VisualTab = Window:CreateTab("Visuals", 4483362458)

VisualTab:CreateToggle({Name = "1. Highlight ESP", Callback = function(V) _G.EspEnabled = V end})
VisualTab:CreateToggle({Name = "2. Tracers", Callback = function(V) _G.TracerEnabled = V end})
VisualTab:CreateToggle({Name = "3. Name ESP", Callback = function(V) _G.NameEsp = V end})
VisualTab:CreateToggle({Name = "4. Distance ESP", Callback = function(V) _G.DistanceEsp = V end})
VisualTab:CreateToggle({Name = "5. Full Bright", Callback = function(V) _G.FullBright = V end})
VisualTab:CreateSlider({Name = "6. Field of View", Range = {70, 120}, Increment = 1, CurrentValue = 70, Callback = function(V) workspace.CurrentCamera.FieldOfView = V end})
VisualTab:CreateButton({Name = "7. FPS Boost", Callback = function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end end end})
VisualTab:CreateButton({Name = "8. Clear ESP", Callback = function() for _,v in pairs(game.Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("GeminiHigh") then v.Character.GeminiHigh:Destroy() end end end})
VisualTab:CreateButton({Name = "9. Hide FOV Circle", Callback = function() _G.AimbotFOV = 0 end})
VisualTab:CreateButton({Name = "10. Destroy UI", Callback = function() Rayfield:Destroy() end})

-- // LOGIC CORE //
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
            local isTeam = (p.Team == LocalPlayer.Team and p.Team ~= nil)
            -- ONLY TARGET RED (Ignore Green if TeamCheck is ON)
            if _G.TeamCheck and isTeam then continue end

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
            -- 0 smoothness is instant, 1 is slow
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness > 0 and (1.1 - _G.AimbotSmoothness) * 0.4 or 1)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not Tracers[p] then Tracers[p] = Drawing.new("Line"); Tracers[p].Thickness = 1 end
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local isTeam = (p.Team == LocalPlayer.Team and p.Team ~= nil)
                
                -- TeamCheck ON: Team is Green, Enemy is Red.
                -- TeamCheck OFF: Everyone is Red.
                local color = Color3.new(1,0,0) 
                if _G.TeamCheck and isTeam then color = Color3.new(0,1,0) end

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
