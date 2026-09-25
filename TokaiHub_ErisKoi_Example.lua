-- TokaiHub_ErisKoi Example / Test Script
-- Source: https://github.com/longhazem/ERISKOI_TK
-- Load Library trước, sau đó chạy file này
-- Toggle menu: RightControl hoặc RightShift

-- ─────────────────────────────────────────────
-- LOAD LIBRARY
-- ─────────────────────────────────────────────

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/longhazem/ERISKOI_TK/main/TokaiHub_ErisKoi_UI.lua"
))()

-- ─────────────────────────────────────────────
-- WINDOW
-- ─────────────────────────────────────────────

local Window = Library:CreateWindow({
    Title   = "TokaiHub_ErisKoi",
    Center  = true,
    AutoShow = true,
    MenuFadeTime = 0.2,
    Size    = UDim2.fromOffset(550, 600),
})

-- ─────────────────────────────────────────────
-- TABS
-- ─────────────────────────────────────────────

local MainTab    = Window:AddTab("Main")
local CombatTab  = Window:AddTab("Combat")
local VisualTab  = Window:AddTab("Visuals")
local MiscTab    = Window:AddTab("Misc")

-- ─────────────────────────────────────────────
-- MAIN TAB — Left / Right groupboxes
-- ─────────────────────────────────────────────

local LeftMain  = MainTab:AddLeftGroupbox("Player")
local RightMain = MainTab:AddRightGroupbox("World")

-- Toggles
LeftMain:AddToggle("Noclip", {
    Text    = "Noclip",
    Default = false,
    Tooltip = "Bay xuyên tường",
    Callback = function(val)
        -- patch vào đây
        print("[TokaiHub] Noclip:", val)
    end,
})

LeftMain:AddToggle("InfiniteJump", {
    Text    = "Infinite Jump",
    Default = false,
    Callback = function(val)
        print("[TokaiHub] InfiniteJump:", val)
    end,
})

LeftMain:AddToggle("SpeedHack", {
    Text    = "Speed Hack",
    Default = false,
    Risky   = true,       -- text đỏ cảnh báo
    Callback = function(val)
        print("[TokaiHub] Speed:", val)
    end,
})

-- Slider
LeftMain:AddSlider("WalkSpeed", {
    Text     = "Walk Speed",
    Default  = 16,
    Min      = 1,
    Max      = 500,
    Rounding = 0,
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end,
})

LeftMain:AddSlider("JumpPower", {
    Text     = "Jump Power",
    Default  = 50,
    Min      = 0,
    Max      = 500,
    Rounding = 0,
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = val
        end
    end,
})

-- Divider
LeftMain:AddDivider()

-- Label
LeftMain:AddLabel("Thông tin nhân vật")

-- Input
LeftMain:AddInput("TeleportCoords", {
    Text     = "Tọa độ teleport (x,y,z)",
    Default  = "0,0,0",
    Numeric  = false,
    Finished = true,
    Callback = function(val)
        print("[TokaiHub] Coords input:", val)
    end,
    Tooltip = "Nhập x,y,z cách nhau bằng dấu phẩy",
})

-- Button
LeftMain:AddButton({
    Text = "Teleport",
    Func = function()
        local input = Options["TeleportCoords"]
        if not input then return end
        local parts = input.Value:split(",")
        if #parts == 3 then
            local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
            if x and y and z then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
                end
            end
        end
    end,
    DoubleClick = false,
    Tooltip = "Click để teleport đến tọa độ đã nhập",
})

-- Right groupbox
RightMain:AddToggle("FogRemover", {
    Text    = "Remove Fog",
    Default = false,
    Callback = function(val)
        game.Lighting.FogEnd = val and 9e9 or 100000
        print("[TokaiHub] Fog removed:", val)
    end,
})

RightMain:AddToggle("FullBright", {
    Text    = "Full Bright",
    Default = false,
    Callback = function(val)
        game.Lighting.Brightness = val and 2 or 1
        game.Lighting.ClockTime  = val and 14 or game.Lighting.ClockTime
        print("[TokaiHub] FullBright:", val)
    end,
})

RightMain:AddSlider("TimeOfDay", {
    Text     = "Time of Day",
    Default  = 14,
    Min      = 0,
    Max      = 24,
    Rounding = 1,
    Callback = function(val)
        game.Lighting.ClockTime = val
    end,
})

-- ─────────────────────────────────────────────
-- COMBAT TAB — Tabbox chia Aimbot / Triggerbot
-- ─────────────────────────────────────────────

local CombatLeft  = CombatTab:AddLeftGroupbox("Aimbot")
local CombatRight = CombatTab:AddRightGroupbox("Triggerbot")

CombatLeft:AddToggle("Aimbot", {
    Text    = "Enable Aimbot",
    Default = false,
    Risky   = true,
    Callback = function(val)
        print("[TokaiHub] Aimbot:", val)
    end,
})

CombatLeft:AddSlider("AimFOV", {
    Text     = "FOV",
    Default  = 100,
    Min      = 10,
    Max      = 600,
    Rounding = 0,
    Callback = function(val)
        print("[TokaiHub] AimFOV:", val)
    end,
})

CombatLeft:AddSlider("AimSmooth", {
    Text     = "Smoothness",
    Default  = 5,
    Min      = 1,
    Max      = 50,
    Rounding = 1,
    Callback = function(val)
        print("[TokaiHub] Smooth:", val)
    end,
})

CombatLeft:AddDropdown("AimPart", {
    Text    = "Aim Part",
    Values  = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Callback = function(val)
        print("[TokaiHub] AimPart:", val)
    end,
})

CombatLeft:AddDivider()

CombatLeft:AddDropdown("AimTeam", {
    Text    = "Team Filter",
    Values  = { "Enemies Only", "All Players", "Friends Only" },
    Default = "Enemies Only",
    Callback = function(val)
        print("[TokaiHub] TeamFilter:", val)
    end,
})

-- Triggerbot
CombatRight:AddToggle("Triggerbot", {
    Text    = "Enable Triggerbot",
    Default = false,
    Risky   = true,
    Callback = function(val)
        print("[TokaiHub] Triggerbot:", val)
    end,
})

CombatRight:AddSlider("TriggerDelay", {
    Text     = "Delay (ms)",
    Default  = 80,
    Min      = 0,
    Max      = 500,
    Rounding = 0,
    Callback = function(val)
        print("[TokaiHub] TriggerDelay:", val)
    end,
})

-- ─────────────────────────────────────────────
-- VISUALS TAB — ESP + Chams + Color Pickers
-- ─────────────────────────────────────────────

local ESPGroup   = VisualTab:AddLeftGroupbox("ESP")
local ChamsGroup = VisualTab:AddRightGroupbox("Chams / Color")

ESPGroup:AddToggle("ESPEnabled", {
    Text    = "Enable ESP",
    Default = false,
    Callback = function(val)
        print("[TokaiHub] ESP:", val)
    end,
}):AddColorPicker("ESPBoxColor", {
    Default     = Color3.fromRGB(255, 50, 50),
    Title       = "Box Color",
    Transparency = 0,
    Callback = function(col)
        print("[TokaiHub] Box color:", col)
    end,
})

ESPGroup:AddToggle("ESPBox", {
    Text    = "Box",
    Default = false,
    Callback = function(val) print("[TokaiHub] Box:", val) end,
})

ESPGroup:AddToggle("ESPBox3D", {
    Text    = "3D Box",
    Default = false,
    Callback = function(val) print("[TokaiHub] Box3D:", val) end,
})

ESPGroup:AddToggle("ESPName", {
    Text    = "Name",
    Default = true,
    Callback = function(val) print("[TokaiHub] Name:", val) end,
})

ESPGroup:AddToggle("ESPHealth", {
    Text    = "Health Bar",
    Default = false,
    Callback = function(val) print("[TokaiHub] HealthBar:", val) end,
})

ESPGroup:AddToggle("ESPTracer", {
    Text    = "Tracer",
    Default = false,
    Callback = function(val) print("[TokaiHub] Tracer:", val) end,
})

ESPGroup:AddToggle("ESPDistance", {
    Text    = "Distance",
    Default = false,
    Callback = function(val) print("[TokaiHub] Distance:", val) end,
})

ESPGroup:AddSlider("ESPMaxDist", {
    Text     = "Max Distance",
    Default  = 150,
    Min      = 10,
    Max      = 1000,
    Rounding = 0,
    Callback = function(val) print("[TokaiHub] MaxDist:", val) end,
})

-- Chams
ChamsGroup:AddToggle("ChamsEnabled", {
    Text    = "Enable Chams",
    Default = false,
    Callback = function(val) print("[TokaiHub] Chams:", val) end,
}):AddColorPicker("ChamsFillColor", {
    Default      = Color3.fromRGB(255, 50, 50),
    Title        = "Fill Color",
    Transparency = 0.5,
    Callback = function(col) print("[TokaiHub] ChamsFill:", col) end,
})

ChamsGroup:AddToggle("ChamsVisibleOnly", {
    Text    = "Visible Only",
    Default = false,
    Callback = function(val) print("[TokaiHub] VisibleOnly:", val) end,
})

ChamsGroup:AddDivider()
ChamsGroup:AddLabel("Accent Color")

ChamsGroup:AddColorPicker("AccentColorPicker", {
    Default  = Library.AccentColor,
    Title    = "Menu Accent",
    Callback = function(col)
        Library.AccentColor = col
        Library.AccentColorDark = Library:GetDarkerColor(col)
        Library:UpdateColorsUsingRegistry()
    end,
})

-- ─────────────────────────────────────────────
-- MISC TAB — Keybinds, Dropdown, Buttons, Input
-- ─────────────────────────────────────────────

local MiscLeft  = MiscTab:AddLeftGroupbox("Settings")
local MiscRight = MiscTab:AddRightGroupbox("Info")

-- Keybind gắn vào Toggle
local KpToggle = MiscLeft:AddToggle("GodMode", {
    Text    = "God Mode",
    Default = false,
    Risky   = true,
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.MaxHealth = val and math.huge or 100
                hum.Health    = val and math.huge or 100
            end
        end
    end,
})

KpToggle:AddKeyPicker("GodModeKey", {
    Default      = "G",
    SyncToggleState = true,
    Mode         = "Toggle",
    Text         = "God Mode Keybind",
    Callback     = function(val)
        print("[TokaiHub] GodMode key fired:", val)
    end,
})

-- Multi-select dropdown
MiscLeft:AddDropdown("DisabledPlayers", {
    Text    = "Ignore Players (multi)",
    Values  = {},
    Default = nil,
    AllowNull = true,
    Multi   = true,
    SpecialType = "Player",
    Callback = function(val)
        print("[TokaiHub] Ignored players:", val)
    end,
})

MiscLeft:AddDivider()

-- Buttons
MiscLeft:AddButton({
    Text = "Rejoin Server",
    Func = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
    Tooltip = "Rejoin game hiện tại",
})

MiscLeft:AddButton({
    Text = "Copy Game ID",
    Func = function()
        setclipboard(tostring(game.PlaceId))
        Library:Notify("Đã copy PlaceId: " .. game.PlaceId, 3)
    end,
    Tooltip = "Copy PlaceId vào clipboard",
})

-- Right misc groupbox — info labels
MiscRight:AddLabel("TokaiHub_ErisKoi v1.0")
MiscRight:AddLabel("github.com/longhazem/ERISKOI_TK")
MiscRight:AddDivider()
MiscRight:AddLabel("Toggle menu: RightControl")
MiscRight:AddLabel("Keybind mode: Hold / Toggle")

MiscRight:AddDivider()

-- Dependency box example: chỉ hiện khi ESPEnabled = true
local DepBox = ESPGroup:AddDependencyBox()
DepBox:SetupDependencies({
    { Idx = "ESPEnabled", Value = true }
})
-- elements thêm vào DepBox sẽ chỉ visible khi ESPEnabled = true

-- ─────────────────────────────────────────────
-- THEME COLORS — Update theo accent
-- ─────────────────────────────────────────────

Toggles["ESPEnabled"]:OnChanged(function(val)
    -- Hook riêng để sync ESP library nếu có
    if getgenv().EspInterface then
        getgenv().EspInterface.teamSettings.enemy.enabled = val
        getgenv().EspInterface.teamSettings.friendly.enabled = val
    end
end)

-- ─────────────────────────────────────────────
-- DONE
-- ─────────────────────────────────────────────
Library:Notify("TokaiHub_ErisKoi loaded!", 4)

-- ─────────────────────────────────────────────
-- MOBILE SUPPORT — Draggable toggle button
-- Chỉ hiện trên mobile, desktop bỏ qua
-- ─────────────────────────────────────────────
if Library.IsMobile then
    local MobileBtn = Library:AddDraggableButton('☰ Menu', function()
        Library:Toggle()
    end)

    -- Đặt vào góc trên phải cho dễ bấm
    MobileBtn:SetPosition(
        game.Workspace.CurrentCamera.ViewportSize.X - 80,
        12
    )

    -- AutoScale bật cho mobile
    Library:SetAutoScaleEnabled(true)
    Library:SetAutoScaleMultiplier(1.1)
end
