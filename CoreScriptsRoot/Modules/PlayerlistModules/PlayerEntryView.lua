--[[
            // PlayerEntryView.lua
            
            // Creates an entry view for a player to be used in the player list
]]
local CoreGui = game:GetService('CoreGui')
local RobloxGui = CoreGui:FindFirstChild('RobloxGui')
local Modules = RobloxGui:FindFirstChild('Modules')

local SettingsModules = Modules:FindFirstChild('Settings')
local Utility = require(SettingsModules:FindFirstChild('Utility'))

local BACKGROUND_TRANSPARENCY = 0.5
local BACKGROUND_COLOR = Color3.new(25/255, 25/255, 25/255)

local BASE_TEXT_COLOR = Color3.new(1, 1, 1)
local FONT = Enum.Font.SourceSansBold

-- Console values
local SELECTED_BG_COLOR = Color3.new(209/255, 216/255, 221/255)
local SELECTED_TEXT_COLOR = Color3.new(0, 0, 0)
local AVATAR_BG_COLOR = Color3.new(39/255, 69/255, 82/255)
local AVATAR_INDENT = 12
local TF_NAME_INDENT = 16
local TF_FONT_SIZE = Enum.FontSize.Size36

return createEntryView
