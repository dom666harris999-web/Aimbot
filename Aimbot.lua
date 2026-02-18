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
_G.VisualTeamCheck = true

local Window = Rayfield:CreateWindow({
   Name = "GEMINI ULTIMATE",
   LoadingTitle = "Configurations Enabled...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GeminiHubConfigs", -- This folder will appear in your Delta workspace
      FileName = "EntrenchedSettings"
   }
})

-- // COMBAT TAB //
local MainTab = Window:CreateTab("Combat", 4483362458)
MainTab:CreateSection("Aimbot")

MainTab:CreateToggle({
   Name = "Instant Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle", -- Flags are required for saving!
   Callback = function(Value) _G.AimbotEnabled = Value end,
})

MainTab:CreateSlider({
   Name = "Smoothness",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0,
   Flag = "SmoothnessSlider",
   Callback = function(Value) _G.AimbotSmoothness = Value end,
})

MainTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Flag = "WallCheckToggle",
   Callback = function(Value) _G.WallCheck = Value end,
})

MainTab:CreateDropdown({
   Name = "Target Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Flag = "TargetDropdown",
   Callback = function(Option) _G.TargetPart = Option[1] end,
})

MainTab:CreateSlider({
   Name = "FOV Radius",
   Range = {0, 600},
   Increment = 1,
   Suffix = "px",
   CurrentValue = 100,
   Flag = "FOVSlider",
   Callback = function(Value) _G.AimbotFOV = Value end,
})

MainTab:CreateSection("Melee")
MainTab:CreateToggle({
   Name = "Knife Aura",
   CurrentValue = false,
   Flag = "KnifeToggle",
   Callback = function(Value) _G.KnifeAura = Value end,
})

-- // VISUALS TAB //
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateSection("Performance")

VisualTab:CreateToggle({
   Name = "Team Check (Hide Teammates)",
   CurrentValue = true,
   Flag = "TeamCheckToggle",
   Callback = function(Value) _G.VisualTeamCheck = Value end,
})

VisualTab:CreateSection("Visual Enhancements")

VisualTab:CreateToggle({
   Name = "Highlight ESP",
   CurrentValue = false,
   Flag = "HighlightToggle",
   Callback = function(Value) _G.EspEnabled = Value end,
})

VisualTab:CreateToggle({
   Name = "Tracers",
   CurrentValue = false,
   Flag = "TracerToggle",
   Callback = function(Value) _G.TracerEnabled = Value end,
})

VisualTab:CreateToggle({
   Name = "Name ESP",
   CurrentValue = false,
   Flag = "NameToggle",
   Callback = function(Value) _G.NameEsp = Value end,
})

VisualTab:CreateToggle({
   Name = "Distance ESP",
   CurrentValue = false,
   Flag = "DistToggle",
   Callback = function(Value) _G.DistanceEsp = Value end,
})

-- // SETTINGS TAB (FOR SAVING/LOADING) //
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Configuration Management")

SettingsTab:CreateButton({
   Name = "Save Current Config",
   Callback = function()
      Rayfield:SaveConfiguration()
   end,
})

-- // [LOGIC CORE REMAINS THE SAME AS PREVIOUS UPDATE] //
-- Note: Ensure the full Logic Core from the previous response is pasted below this line.
