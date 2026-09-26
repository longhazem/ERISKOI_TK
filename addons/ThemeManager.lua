-- ThemeManager | LinoriaLib Addon
-- Compatible with LinoriaLib (violin-suzutsuki)

local ThemeManager = {}
ThemeManager.__index = ThemeManager

ThemeManager.Library = nil
ThemeManager.Folder = 'TokaihubThemes'

ThemeManager.BuiltInThemes = {
    ['Default'] = { 1, {
        FontColor       = 'ffffff',
        MainColor       = '1c1c1c',
        BackgroundColor = '141414',
        AccentColor     = '4f4fdb',
        OutlineColor    = '2d2d2d',
    }},
    ['Dark Blue'] = { 2, {
        FontColor       = 'dde5f7',
        MainColor       = '0f1923',
        BackgroundColor = '0a1019',
        AccentColor     = '3d85c8',
        OutlineColor    = '1a2a3a',
    }},
    ['Green'] = { 3, {
        FontColor       = 'd4edda',
        MainColor       = '132416',
        BackgroundColor = '0b180e',
        AccentColor     = '28a745',
        OutlineColor    = '1b3a21',
    }},
    ['Rose'] = { 4, {
        FontColor       = 'f7ddde',
        MainColor       = '231518',
        BackgroundColor = '160c0e',
        AccentColor     = 'c0435a',
        OutlineColor    = '3a1d21',
    }},
    ['Clean'] = { 5, {
        FontColor       = 'E8E8E8',
        MainColor       = '1D1D1D',
        BackgroundColor = '141414',
        AccentColor     = 'BEBEBE',
        OutlineColor    = '383838',
    }},
}

ThemeManager.DefaultTheme = 'Default'

local function hexToColor3(hex)
    hex = hex:gsub('#', '')
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

local function color3ToHex(c)
    return string.format('%02x%02x%02x',
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5)
    )
end

function ThemeManager:SetLibrary(lib)
    self.Library = lib
end

function ThemeManager:SetFolder(folder)
    self.Folder = folder
    self:EnsureFolder()
end

function ThemeManager:EnsureFolder()
    if not isfolder then return end
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    local sub = self.Folder .. '/themes'
    if not isfolder(sub) then
        makefolder(sub)
    end
end

function ThemeManager:GetThemeFilePath(name)
    return self.Folder .. '/themes/' .. name .. '.json'
end

function ThemeManager:ApplyTheme(name)
    local lib = self.Library
    if not lib then return end

    local themeData
    if self.BuiltInThemes[name] then
        themeData = self.BuiltInThemes[name][2]
    elseif isfile and isfile(self:GetThemeFilePath(name)) then
        local ok, data = pcall(function()
            return game:GetService('HttpService'):JSONDecode(readfile(self:GetThemeFilePath(name)))
        end)
        if ok then themeData = data end
    end

    if not themeData then return end

    local map = {
        FontColor       = 'Font',
        MainColor       = 'Main',
        BackgroundColor = 'Background',
        AccentColor     = 'Accent',
        OutlineColor    = 'Outline',
    }

    for themeKey, libKey in pairs(map) do
        if themeData[themeKey] and lib.Theme and lib.Theme[libKey] ~= nil then
            lib.Theme[libKey] = hexToColor3(themeData[themeKey])
        end
    end

    if lib.UpdateColorsFor then
        lib:UpdateColorsFor(lib.ScreenGui)
    elseif lib.UpdateColors then
        lib:UpdateColors()
    end

    self.CurrentTheme = name
    self:SaveCurrentTheme()
end

function ThemeManager:SaveCurrentTheme()
    if not writefile then return end
    self:EnsureFolder()
    local ok = pcall(writefile, self.Folder .. '/currenttheme.txt', self.CurrentTheme or self.DefaultTheme)
    if not ok then end
end

function ThemeManager:LoadCurrentTheme()
    if not isfile then return self.DefaultTheme end
    local path = self.Folder .. '/currenttheme.txt'
    if isfile(path) then
        local name = readfile(path)
        if name and name ~= '' then
            return name
        end
    end
    return self.DefaultTheme
end

function ThemeManager:SaveCustomTheme(name)
    if not writefile then return end
    self:EnsureFolder()
    local lib = self.Library
    if not lib or not lib.Theme then return end

    local data = {
        FontColor       = color3ToHex(lib.Theme.Font or Color3.new(1,1,1)),
        MainColor       = color3ToHex(lib.Theme.Main or Color3.new(0.1,0.1,0.1)),
        BackgroundColor = color3ToHex(lib.Theme.Background or Color3.new(0.08,0.08,0.08)),
        AccentColor     = color3ToHex(lib.Theme.Accent or Color3.new(0.3,0.3,0.85)),
        OutlineColor    = color3ToHex(lib.Theme.Outline or Color3.new(0.18,0.18,0.18)),
    }

    writefile(self:GetThemeFilePath(name), game:GetService('HttpService'):JSONEncode(data))
end

function ThemeManager:GetThemeList()
    local list = {}
    for name in pairs(self.BuiltInThemes) do
        table.insert(list, name)
    end
    table.sort(list, function(a, b)
        return (self.BuiltInThemes[a][1] or 99) < (self.BuiltInThemes[b][1] or 99)
    end)
    if listfiles then
        local path = self.Folder .. '/themes'
        if isfolder and isfolder(path) then
            for _, file in ipairs(listfiles(path)) do
                local name = file:match('([^/\\]+)%.json$')
                if name and not self.BuiltInThemes[name] then
                    table.insert(list, name)
                end
            end
        end
    end
    return list
end

function ThemeManager:ApplyToTab(tab)
    local lib = self.Library
    if not lib then return end

    local orderA = tab:AddLeftGroupbox('Themes')

    local themeList = self:GetThemeList()
    local currentTheme = self:LoadCurrentTheme()

    orderA:AddDropdown('ThemeManager_ThemeList', {
        Text    = 'Theme',
        Values  = themeList,
        Default = currentTheme,
        Callback = function(val)
            self:ApplyTheme(val)
        end,
    })

    orderA:AddButton({
        Text = 'Save Current Theme',
        Func = function()
            local name = 'Custom_' .. tostring(os.time())
            self:SaveCustomTheme(name)
            lib:Notify('Theme saved as: ' .. name)
        end,
    })

    self:ApplyTheme(currentTheme)
end

function ThemeManager:ApplyToGroupbox(groupbox)
    local lib = self.Library
    if not lib then return end

    local themeList = self:GetThemeList()
    local currentTheme = self:LoadCurrentTheme()

    groupbox:AddDropdown('ThemeManager_ThemeList', {
        Text    = 'Theme',
        Values  = themeList,
        Default = currentTheme,
        Callback = function(val)
            self:ApplyTheme(val)
        end,
    })

    self:ApplyTheme(currentTheme)
end

return ThemeManager
