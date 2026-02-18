local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // SETTINGS //
_G.AimbotEnabled = false
_G.TeamCheck = true
_G.WallCheck = true
_G.AimbotFOV = 150
_G.AimbotSmoothness = 0 -- Default to 0 for INSTANT
_G.TargetPart = "Head"

local Window = Rayfield:CreateWindow({
   Name = "GEMINI ULTIMATE",
   LoadingTitle = "Instant Snap Ready",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- // COMBAT TAB (6 FEATURES) //
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({Name = "Enable Aimbot", Callback = function(V) _G.AimbotEnabled = V end})
CombatTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(V) _G.TeamCheck = V end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(V) _G.WallCheck = V end})

-- Setting this to 0 will make it INSTANT
CombatTab:CreateSlider({
    Name = "Smoothness", 
    Range = {0, 1}, 
    Increment = 0.1, 
    CurrentValue = 0, 
    Suffix = " (0 = Instant)",
    Callback = function(V) _G.AimbotSmoothness = V end
})

CombatTab:CreateSlider({Name = "FOV Radius", Range = {0, 600}, Increment = 1, Suffix = "px", CurrentValue = 150, Callback = function(V) _G.AimbotFOV = V end})
CombatTab:CreateDropdown({Name = "Target Part", Options = {"Head", "HumanoidRootPart"}, CurrentOption = "Head", Callback = function(O) _G.TargetPart = O[1] end})

-- // VISUALS TAB (6 FEATURES) //
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateToggle({Name = "Highlight ESP", Callback = function(V) _G.EspEnabled = V end})
VisualTab:CreateToggle({Name = "Tracers", Callback = function(V) _G.TracerEnabled = V end})
VisualTab:CreateToggle({Name = "Name ESP", Callback = function(V) _G.Names = V end})
VisualTab:CreateToggle({Name = "Distance ESP", Callback = function(V) _G.Dist = V end})
VisualTab:CreateToggle({Name = "Box ESP", Callback = function(V) _G.Boxes = V end})
VisualTab:CreateToggle({Name = "Chams", Callback = function(V) _G.ChamsEnabled = V end})

-- // ENGINE LOGIC //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function GetTarget()
    local target = nil
    local dist = _G.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.TargetPart) then
            local isTeam = (p.Team == LocalPlayer.Team and p.Team ~= nil)
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
            local targetPos = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            
            if _G.AimbotSmoothness == 0 then
                -- INSTANT SNAP
                Camera.CFrame = targetPos
            else
                -- ADJUSTABLE SMOOTHNESS
                local lerpAmount = (1.1 - _G.AimbotSmoothness) * 0.5
                Camera.CFrame = Camera.CFrame:Lerp(targetPos, lerpAmount)
            end
        end
    end
end)
