--[[
			 // PlayerData.lua

			 // Model class for player objects, to be used for getting information
			 // about the players in the game

			 // View will hook into each playerObject and set listeners for each player view entry
]]
local CoreGui = game:GetService('CoreGui')
local PlayersService = game:GetService('Players')

local RobloxGui = CoreGui:FindFirstChild('RobloxGui')
local Modules = RobloxGui:FindFirstChild('Modules')
local Settings = Modules:FindFirstChild('Settings')
local Utility = require(Settings:FindFirstChild('Utility'))
local PlayerlistModules = Modules:FindFirstChild('PlayerlistModules')
local LeaderstatsData = require(PlayerlistModules:FindFirstChild('LeaderstatsData'))

local PlayerData = {} -- Module Table

local PlayerMap = {}
local PlayerArraySorted = {}
local LocalPlayerData = nil

-- Module Events
PlayerData.PlayerAdded = Utility:CreateSignal()
PlayerData.PlayerRemoved = Utility:CreateSignal()

local function createPlayerObject(player)
	local this = {}

	this.Player = player
	this.Leaderstats = LeaderstatsData:CreatePlayerStats(player)

	return this
end

local function sortPlayers(a, b)
	-- TODO: Implement additional sort details
	local aPlayerObject = PlayerMap[a]
	local bPlayerObject = PlayerMap[b]

	return aPlayerObject.Player.Name:upper() < bPlayerObject.Player.Name:upper()
end

local function onPlayerAdded(player)
	if not PlayerMap[player.UserId] then
		local playerObject = createPlayerObject(player)
		PlayerMap[player.UserId] = playerObject
		table.insert(PlayerArraySorted, player.UserId)
		table.sort(PlayerArraySorted, sortPlayers)

		if player.UserId == PlayersService.LocalPlayer.UserId then
			LocalPlayerData = playerObject
		end

		PlayerData.PlayerAdded:fire(playerObject)
	end
end

local function onPlayerRemoved(player)
	if PlayerMap[player.UserId] then
		local removedPlayer = PlayerMap[player.UserId]
		PlayerMap[player.UserId] = nil
		for i = 1, #PlayerArraySorted do
			if PlayerArraySorted[i] == player.UserId then
				table.remove(PlayerArraySorted, i)
				PlayerData.PlayerRemoved:fire(removedPlayer)
				break
			end
		end
	end
end

--[[ Event Listeners ]]--
PlayersService.PlayerAdded:connect(onPlayerAdded)
PlayersService.PlayerRemoving:connect(onPlayerRemoved)
-- Retro check
for _,player in pairs(PlayersService:GetPlayers()) do
	onPlayerAdded(player)
end

--[[ Public API ]]--
function PlayerData:GetPlayersSorted()
	local sortedPlayers = {}
	for i = 1, #PlayerArraySorted do
		table.insert(sortedPlayers, PlayerMap[PlayerArraySorted[i]])
	end

	return sortedPlayers
end

function PlayerData:GetLocalPlayer()
	return LocalPlayerData
end

return PlayerData
