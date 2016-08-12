--[[
                // PlayerlistMain.lua

                // Main entry point for the in-game playerlist
]]
local UserInputService = game:GetService('UserInputService')

local PlayerlistModules = script.Parent
local PlayerData = require(PlayerlistModules:FindFirstChild('PlayerData'))

local Platform = UserInputService:GetPlatform()

local Playerlist = {}

-- TODO:
--[[
    We'll figure out what platform we are on and get that view. The view will be returned
    by the module and attempt to best adhere to the previous module API. Changes will
    be made as needed.

    Views should be made from components.
]]

print('What is the platform?')
if Platform == Enum.Platform.XBoxOne then
    print("\tPlatform is Xbox One, init ten foot playerlist view")
end

return Playerlist

-- TODO: Let's list off what we may needed
--[[
    PlayerData
        Manages all player data - in-game players, their stats

    LeaderstatsData
        Manages all leaderstats in the game, this can be used by the top bar
        or the main view to creates views for stats

    Teams
        should have some module that manages teams that the main view can hook into to display

    Entry object
        Manages a player entry object

    Pop out
        For now, not on console. Creates the pop out context for when you select a user entry

    
]]
