-- SaveManager | LinoriaLib Addon
-- Compatible with LinoriaLib (violin-suzutsuki)

local SaveManager = {}
SaveManager.__index = SaveManager

SaveManager.Library       = nil
SaveManager.Folder        = 'TokaihubConfigs'
SaveManager.IgnoredToggles = {}
SaveManager.IgnoredIndexes = {}

local HttpService = game:GetService('HttpService')

function SaveManager:SetLibrary(lib)
    self.Library = lib
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
    self:EnsureFolder()
end

function SaveManager:EnsureFolder()
    if not isfolder then return end
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
end

function SaveManager:GetConfigPath(name)
    return self.Folder .. '/' .. name .. '.json'
end

function SaveManager:IgnoreThemeSettings()
    local themeKeys = {
        'ThemeManager_ThemeList',
        'ThemeManager_CustomThemeName',
    }
    for _, k in ipairs(themeKeys) do
        self.IgnoredIndexes[k] = true
    end
end

function SaveManager:SetIgnoreIndexes(list)
    for _, k in ipairs(list) do
        self.IgnoredIndexes[k] = true
    end
end

function SaveManager:GetCurrentValues()
    local lib = self.Library
    if not lib then return {} end

    local data = {}
    local Toggles = lib.Toggles or {}
    local Options  = lib.Options  or {}

    for flag, toggle in pairs(Toggles) do
        if not self.IgnoredIndexes[flag] then
            local ok, val = pcall(function() return toggle.Value end)
            if ok then data[flag] = val end
        end
    end

    for flag, option in pairs(Options) do
        if not self.IgnoredIndexes[flag] then
            local ok, val = pcall(function()
                if option.Type == 'ColorPicker' then
                    return {
                        option.Value.R,
                        option.Value.G,
                        option.Value.B,
                    }
                elseif option.Type == 'KeyPicker' then
                    return { option.Value, option.Mode }
                else
                    return option.Value
                end
            end)
            if ok then data[flag] = val end
        end
    end

    return data
end

function SaveManager:ApplyValues(data)
    local lib = self.Library
    if not lib then return end

    local Toggles = lib.Toggles or {}
    local Options  = lib.Options  or {}

    for flag, val in pairs(data) do
        if self.IgnoredIndexes[flag] then continue end

        local toggle = Toggles[flag]
        if toggle then
            local ok = pcall(function() toggle:SetValue(val) end)
            if not ok then end
        end

        local option = Options[flag]
        if option then
            local ok = pcall(function()
                if option.Type == 'ColorPicker' and type(val) == 'table' then
                    option:SetValueRGB(Color3.new(val[1], val[2], val[3]))
                elseif option.Type == 'KeyPicker' and type(val) == 'table' then
                    option:SetValue(val)
                else
                    option:SetValue(val)
                end
            end)
            if not ok then end
        end
    end
end

function SaveManager:Save(name)
    if not writefile then return false, 'writefile not available' end
    name = name or 'default'
    self:EnsureFolder()

    local data = self:GetCurrentValues()
    local ok, err = pcall(function()
        writefile(self:GetConfigPath(name), HttpService:JSONEncode(data))
    end)

    if ok then
        return true
    else
        return false, tostring(err)
    end
end

function SaveManager:Load(name)
    if not readfile or not isfile then return false, 'readfile not available' end
    name = name or 'default'

    local path = self:GetConfigPath(name)
    if not isfile(path) then
        return false, 'config not found: ' .. name
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)

    if not ok then
        return false, 'failed to parse config: ' .. tostring(data)
    end

    self:ApplyValues(data)
    return true
end

function SaveManager:Delete(name)
    if not delfile or not isfile then return false end
    local path = self:GetConfigPath(name)
    if isfile(path) then
        pcall(delfile, path)
        return true
    end
    return false
end

function SaveManager:GetConfigList()
    local list = {}
    if not listfiles or not isfolder then return list end
    self:EnsureFolder()
    if isfolder(self.Folder) then
        for _, file in ipairs(listfiles(self.Folder)) do
            local name = file:match('([^/\\]+)%.json$')
            if name then
                table.insert(list, name)
            end
        end
    end
    table.sort(list)
    return list
end

function SaveManager:SetAutoloadConfig(name)
    if not writefile then return end
    self:EnsureFolder()
    writefile(self.Folder .. '/autoload.txt', name)
end

function SaveManager:LoadAutoloadConfig()
    if not isfile or not readfile then return end
    local path = self.Folder .. '/autoload.txt'
    if isfile(path) then
        local name = readfile(path)
        if name and name ~= '' then
            local ok, err = self:Load(name)
            if not ok and self.Library then
                self.Library:Notify('Failed to load autoload config: ' .. tostring(err))
            end
        end
    end
end

function SaveManager:BuildConfigSection(tab)
    local lib = self.Library
    if not lib then return end

    local section = tab:AddRightGroupbox('Configs')

    local configList = self:GetConfigList()

    local configDrop
    configDrop = section:AddDropdown('SaveManager_ConfigList', {
        Text    = 'Config',
        Values  = configList,
        Default = configList[1] or '',
    })

    local nameBox
    nameBox = section:AddInput('SaveManager_ConfigName', {
        Text        = 'Config Name',
        Default     = '',
        Placeholder = 'Enter config name...',
        Numeric     = false,
        Finished    = false,
    })

    section:AddButton({
        Text = 'Save Config',
        Func = function()
            local name = (lib.Options and lib.Options['SaveManager_ConfigName'] and lib.Options['SaveManager_ConfigName'].Value) or 'default'
            name = name:gsub('[^%w%-_]', '_')
            if name == '' then name = 'default' end

            local ok, err = self:Save(name)
            if ok then
                lib:Notify('Config saved: ' .. name)
                local newList = self:GetConfigList()
                if lib.Options and lib.Options['SaveManager_ConfigList'] then
                    lib.Options['SaveManager_ConfigList']:SetValues(newList)
                    lib.Options['SaveManager_ConfigList']:SetValue(name)
                end
            else
                lib:Notify('Save failed: ' .. tostring(err))
            end
        end,
    })

    section:AddButton({
        Text = 'Load Config',
        Func = function()
            local name = (lib.Options and lib.Options['SaveManager_ConfigList'] and lib.Options['SaveManager_ConfigList'].Value) or ''
            if name == '' then
                lib:Notify('No config selected.')
                return
            end
            local ok, err = self:Load(name)
            if ok then
                lib:Notify('Config loaded: ' .. name)
            else
                lib:Notify('Load failed: ' .. tostring(err))
            end
        end,
    })

    section:AddButton({
        Text = 'Delete Config',
        Func = function()
            local name = (lib.Options and lib.Options['SaveManager_ConfigList'] and lib.Options['SaveManager_ConfigList'].Value) or ''
            if name == '' then
                lib:Notify('No config selected.')
                return
            end
            local deleted = self:Delete(name)
            if deleted then
                lib:Notify('Config deleted: ' .. name)
                local newList = self:GetConfigList()
                if lib.Options and lib.Options['SaveManager_ConfigList'] then
                    lib.Options['SaveManager_ConfigList']:SetValues(newList)
                    lib.Options['SaveManager_ConfigList']:SetValue(newList[1] or '')
                end
            else
                lib:Notify('Delete failed: config not found.')
            end
        end,
    })

    section:AddButton({
        Text = 'Set Autoload',
        Func = function()
            local name = (lib.Options and lib.Options['SaveManager_ConfigList'] and lib.Options['SaveManager_ConfigList'].Value) or ''
            if name == '' then
                lib:Notify('No config selected.')
                return
            end
            self:SetAutoloadConfig(name)
            lib:Notify('Autoload set to: ' .. name)
        end,
    })
end

return SaveManager
