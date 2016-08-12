--[[
			// PlayerlistSettings.lua

			// Holds all settings for the playerlist, like sizes, fonts, font sizes
			// The idea is when we want to change how something looks in the view
			// we just need to edit a settings here. Settings will be based off platform
			// that way the view is platform independent.
]]
local GuiService = game:GetService('GuiService')

local IsTenFootInterface = GuiService:IsTenFootInterface()
IsTenFootInterface = true

local Settings = {}

Settings.TileSpacing = IsTenFootInterface and 5 or 2

Settings.ContainerSize = IsTenFootInterface and UDim2.new(0, 0, 0.8, 0) or UDim2.new(0, 0, 0.5, 0)
Settings.EntrySize = IsTenFootInterface and UDim2.new(0, 400, 0, 100) or UDim2.new(0, 170, 0, 24)
Settings.EntryBackgroundColor = IsTenFootInterface and Color3.new(60/255, 60/255, 60/255) or Color3.new(31/255, 31/255, 31/255)

-- Only used on consoles
Settings.HeaderSize = UDim2.new(0, 400, 0, 100)
Settings.HeaderBackgroundColor = Color3.new(25/255, 25/255, 25/255)
Settings.HeaderBackgroundTransparency = 0.5

Settings.PlayerIconSize = 58
Settings.PlayerIconColor = Color3.new(39/255, 69/255, 82/255)
Settings.PlayerIconIndent = 12
Settings.PlayerNameIndent = 16
Settings.NameFontSize = Enum.FontSize.Size36
Settings.NameFont = Enum.Font.SourceSansBold

Settings.TextColor = Color3.new(1, 1, 1)

return Settings
