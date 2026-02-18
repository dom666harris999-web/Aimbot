local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Global Variables //
_G.AimbotEnabled = false
_G.WallCheck = true
_G.TeamCheck = true
_G.AimbotFOV = 100
_G.AimbotSmoothness = 0
_G.TargetPart = "Head"
_G.KnifeAura = false

_G.EspEnabled = false
_G.TracerEnabled = false
_G.NameEsp = false
_G.DistanceEsp = false
_G.SkeletonEsp = false

local Window = Rayfield:CreateWindow({
   Name = "GEMINI ULTIMATE",
   LoadingTitle = "Cooking Final Build...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = true, FolderName = "GeminiConfig", FileName = "UltimateHub" }
})

-- // COMBAT TAB //
local MainTab = Window:CreateTab("Combat", 4483362458)
MainTab:CreateSection("Aimbot")

MainTab:CreateToggle({
   Name = "Instant Aimbot",
   CurrentValue = false,
   Callback = function(Value) _G.AimbotEnabled = Value end,
})

MainTab:CreateSlider({
   Name = "Smoothness",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0,
   Callback = function(Value) _G.AimbotSmoothness = Value end,
})

MainTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(Value) _G.WallCheck = Value end,
})

MainTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Callback = function(Option) _G.TargetPart = Option[1] end,
})

MainTab:CreateSlider({
   Name = "FOV Radius",
   Range = {0, 600},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 100,
   Callback = function(Value) _G.AimbotFOV = Value end,
})

MainTab:CreateSection("Melee")
MainTab:CreateToggle({
   Name = "Knife Aura",
   CurrentValue = false,
   Callback = function(Value) _G.KnifeAura = Value end,
})

-- // VISUALS TAB //
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateSection("ESP Main")

VisualTab:CreateToggle({
   Name = "Highlight ESP",
   CurrentValue = false,
   Callback = function(Value) _G.EspEnabled = Value end,
})

VisualTab:CreateToggle({
   Name = "Tracers",
   CurrentValue = false,
   Callback = function(Value) _G.TracerEnabled = Value end,
})

VisualTab:CreateSection("Advanced Visuals")
VisualTab:CreateToggle({
   Name = "Name ESP",
   CurrentValue = false,
   Callback = function(Value) _G.NameEsp = Value end,
})

VisualTab:CreateToggle({
   Name = "Distance ESP",
   CurrentValue = false,
   Callback = function(Value) _G.DistanceEsp = Value end,
})

VisualTab:CreateToggle({
   Name = "Skeleton ESP",
   CurrentValue = false,
   Callback = function(Value) _G.SkeletonEsp = Value end,
})

-- // LOGIC CORE //
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Filled = false

local Tracers = {}
local Names = {}

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
            if player.Team == LocalPlayer.Team then continue end
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

-- Knife Aura Loop
task.spawn(function()
    while task.wait(0.1) do
        if _G.KnifeAura then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("bayonet") or tool.Name:lower():find("shovel")) then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if player.Team == LocalPlayer.Team then continue end
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 15 then tool:Activate() end
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local center = Camera.ViewportSize / 2
    FOVCircle.Position = center
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Visible = _G.AimbotEnabled

    -- Aimbot Logic
    if _G.AimbotEnabled then
        local targetPart = GetClosestTarget()
        if targetPart then
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
            if _G.AimbotSmoothness > 0 then
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, (1.1 - _G.AimbotSmoothness) * 0.4)
            else
                Camera.CFrame = lookAt
            end
        end
    end

    -- Visuals Loop
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local color = (player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            
            -- Tracers
            if not Tracers[player] then Tracers[player] = Drawing.new("Line") end
            local line = Tracers[player]
            
            -- Names/Distance
            if not Names[player] then Names[player] = Drawing.new("Text"); Names[player].Center = true; Names[player].Outline = true; Names[player].Size = 14 end
            local label = Names[player]

            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    -- Tracer Update
                    line.Visible = _G.TracerEnabled
                    line.From = Vector2.new(center.X, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Color = color

                    -- Text Update
                    label.Visible = (_G.NameEsp or _G.DistanceEsp)
                    local txt = ""
                    if _G.NameEsp then txt = player.Name end
                    if _G.DistanceEsp then txt = txt .. " [" .. math.floor((hrp.Position - Camera.CFrame.Position).Magnitude) .. "m]" end
                    label.Text = txt
                    label.Position = Vector2.new(pos.X, pos.Y - 40)
                    label.Color = color
                    
                    -- Highlights
                    local high = char:FindFirstChild("GeminiHigh")
                    if _G.EspEnabled then
                        if not high then high = Instance.new("Highlight", char); high.Name = "GeminiHigh" end
                        high.Enabled = true; high.FillColor = color
                    elseif high then high.Enabled = false end
                else
                    line.Visible = false; label.Visible = false
                end
            else
                line.Visible = false; label.Visible = false
            end
        end
    end
end)
