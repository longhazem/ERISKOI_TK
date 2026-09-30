local HttpService = game:GetService('HttpService')

local ThemeManager = {} do
	ThemeManager.Folder = 'Tokaihub'
	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['Default']     = { 1, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"4f4fdb","BackgroundColor":"141414","OutlineColor":"2d2d2d"}') },
		['Dark Blue']   = { 2, HttpService:JSONDecode('{"FontColor":"dde5f7","MainColor":"0f1923","AccentColor":"3d85c8","BackgroundColor":"0a1019","OutlineColor":"1a2a3a"}') },
		['Green']       = { 3, HttpService:JSONDecode('{"FontColor":"d4edda","MainColor":"132416","AccentColor":"28a745","BackgroundColor":"0b180e","OutlineColor":"1b3a21"}') },
		['Rose']        = { 4, HttpService:JSONDecode('{"FontColor":"f7ddde","MainColor":"231518","AccentColor":"c0435a","BackgroundColor":"160c0e","OutlineColor":"3a1d21"}') },
		['Clean']       = { 5, HttpService:JSONDecode('{"FontColor":"E8E8E8","MainColor":"1D1D1D","AccentColor":"BEBEBE","BackgroundColor":"141414","OutlineColor":"383838"}') },
	}

	ThemeManager.DefaultTheme = 'Clean'

	function ThemeManager:ApplyTheme(theme)
		local customData = self:GetCustomTheme(theme)
		local data = customData or self.BuiltInThemes[theme]
		if not data then return end

		-- Custom themes are plain dicts; built-ins are { index, dict }
		local scheme = customData or data[2]

		for idx, col in next, scheme do
			self.Library[idx] = Color3.fromHex(col)
			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		local fields = { 'FontColor', 'MainColor', 'AccentColor', 'BackgroundColor', 'OutlineColor' }
		for _, field in next, fields do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		-- LinoriaLib requires AccentColorDark and a full registry refresh
		if self.Library.GetDarkerColor then
			self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor)
		end
		if self.Library.UpdateColorsUsingRegistry then
			self.Library:UpdateColorsUsingRegistry()
		elseif self.Library.UpdateColorsFor then
			self.Library:UpdateColorsFor(self.Library.ScreenGui)
		elseif self.Library.UpdateColors then
			self.Library:UpdateColors()
		end
	end

	function ThemeManager:LoadDefault()
		local theme = self.DefaultTheme
		local path = self.Folder .. '/themes/default.txt'
		local content = isfile(path) and readfile(path)

		local isBuiltIn = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isBuiltIn = false
			end
		end

		if isBuiltIn then
			if Options.ThemeManager_ThemeList then
				Options.ThemeManager_ThemeList:SetValue(theme)
			end
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then return nil end
		local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
		if not success then return nil end
		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid theme name (empty)', 3)
		end

		local theme = {}
		local fields = { 'FontColor', 'MainColor', 'AccentColor', 'BackgroundColor', 'OutlineColor' }
		for _, field in next, fields do
			theme[field] = Options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', HttpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')
		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end
				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end
		return out
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		-- Support nested paths like 'Tokaihub/BRM5'
		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:CreateThemeManager(groupbox)
		-- Inline color pickers for live editing
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor })
		groupbox:AddLabel('Main color'):AddColorPicker('MainColor', { Default = self.Library.MainColor })
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor })
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor })
		groupbox:AddLabel('Font color'):AddColorPicker('FontColor', { Default = self.Library.FontColor })

		-- Built-in theme list sorted by index
		local ThemesArray = {}
		for name in next, self.BuiltInThemes do
			table.insert(ThemesArray, name)
		end
		table.sort(ThemesArray, function(a, b)
			return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1]
		end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

		groupbox:AddButton('Set as default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
		end)

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)

		-- Custom themes
		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })

		groupbox:AddButton('Load custom theme', function()
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value)
		end)

		groupbox:AddButton('Save custom theme', function()
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)
			Options.ThemeManager_CustomThemeList.Values = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList.Values = self:ReloadCustomThemes()
			Options.ThemeManager_CustomThemeList:SetValues()
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Set custom as default', function()
			local val = Options.ThemeManager_CustomThemeList.Value
			if val ~= nil and val ~= '' then
				self:SaveDefault(val)
				self.Library:Notify(string.format('Set default theme to %q', val))
			end
		end)

		self:LoadDefault()

		-- Live color picker → immediate theme update
		local function UpdateTheme()
			self:ThemeUpdate()
		end

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
