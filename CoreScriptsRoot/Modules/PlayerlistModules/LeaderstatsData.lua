--[[
			// LeaderstatsData.lua

			// Holds information about what stats the game is currently tracking.
			// Keeps stats sorted for displaying correctly in the playerlist view/top bar.

			// Stats are sorted in the player list by child add order. You can set a stat to primary
			// by adding a child on the stat object named IsPrimary, however this can be unsupported
			// at any time. You should use child add order to display your stats in the order you want

			// Creates a leader stats object for the player data to hold leader stat data for that player
]]
local CoreGui = game:GetService('CoreGui')
local PlayersService = game:GetService('Players')
local RobloxGui = CoreGui:FindFirstChild('RobloxGui')
local Modules = RobloxGui:FindFirstChild('Modules')
local Settings = Modules:FindFirstChild('Settings')
local Utility = require(Settings:FindFirstChild('Utility'))

local LeaderstatsData = {}	-- Module Table

--[[ Game Stats ]]--
local GameStatsMap = {}
local GameStatsSortedArray = {}
local CurrentGameStatId = 0

LeaderstatsData.GameStatAdded = Utility:CreateSignal()
LeaderstatsData.GameStatRemoved = Utility:CreateSignal()

local function sortGameStats(a, b)
	return a.AddOrder < b.AddOrder
end

local function createGameStatObject(stat)
	local this = {}

	CurrentGameStatId = CurrentGameStatId + 1

	this.Name = stat.Name
	this.AddOrder = CurrentGameStatId

	return this
end

-- Returns whether obj is a valid stat that can be used in the playerlist
function isValidStat(obj)
	if obj == nil then
		return false
	end

	return obj:IsA('StringValue') or obj:IsA('IntValue') or obj:IsA('BoolValue') or obj:IsA('NumberValue') or
		obj:IsA('DoubleConstrainedValue') or obj:IsA('IntConstrainedValue')
end

-- Attempts to add statObj for the game to track
local function addGameStat(stat)
	if isValidStat(stat) then
		local statName = stat.Name
		if not GameStatsMap[statName] then
			local newStatObject = createGameStatObject(stat)
			GameStatsMap[statName] = newStatObject
			table.insert(GameStatsSortedArray, newStatObject)
			table.sort(GameStatsSortedArray, sortGameStats)
			LeaderstatsData.GameStatAdded:fire(GameStatsSortedArray)
		end
	end
end

-- Attempts to remove a stat if no players have that stat
local function removeGameStat(statName)
	local removeStat = true
	for _,player in pairs(PlayersService:GetPlayers()) do
		local leaderstats = player:FindFirstChild('leaderstats')
		if leaderstats then
			local stat = leaderstats:FindFirstChild(statName)
			if stat and isValidStat(stat) then
				removeStat = false
				break
			end
		end
	end

	if removeStat then
		local statToRemove = GameStatsMap[statName]
		GameStatsMap[statName] = nil
		for i = 1, #GameStatsSortedArray do
			local stat = GameStatsSortedArray[i]
			if stat == statToRemove then
				table.remove(GameStatsSortedArray, i)
				table.sort(GameStatsSortedArray, sortGameStats)
				break
			end
		end
		LeaderstatsData.GameStatRemoved:fire(GameStatsSortedArray)
	end
end

-- Attempts to remove all stats if no other players have that stat
local function removeAllGameStats()
	for statName, statObject in pairs(GameStatsMap) do
		removeGameStat(statName)
	end
end

--[[ Public API ]]--

function LeaderstatsData:GetGameStats()
	return GameStatsSortedArray
end

-- returns the name of the primary stat or nil if it does not exist
function LeaderstatsData:GetPrimaryStatName()
	if #GameStatsSortedArray > 0 then
		local stat = GameStatsSortedArray[1]
		return stat.Name
	end
end

function LeaderstatsData:CreatePlayerStats(player)
	local this = {}

	local myLeaderstats = {}

	-- events
	this.StatAdded = Utility:CreateSignal()
	this.StatRemoved = Utility:CreateSignal()
	this.StatChanged = Utility:CreateSignal()

	-- initialize stats
	do
		local function addPlayerStat(newStat)
			if isValidStat(newStat) then
				myLeaderstats[newStat.Name] = newStat
				newStat.Changed:connect(function(newValue)
					this.StatChanged:fire(newStat.Name, newValue)
				end)
				addGameStat(newStat)
				this.StatAdded:fire(newStat)
			end
		end

		local function onLeaderstatsAdded(leaderstats)
			leaderstats.ChildAdded:connect(function(child)
				addPlayerStat(child)
			end)
			leaderstats.ChildRemoved:connect(function(child)
				local statName = child.Name
				local stat = myLeaderstats[statName]
				if stat and child == stat then
					myLeaderstats[statName] = nil
					removeGameStat(statName)
					this.StatRemoved:fire(statName)
				end
			end)

			for _,child in pairs(leaderstats:GetChildren()) do
				addPlayerStat(child)
			end
		end
		local function onLeaderstatsRemoved()
			myLeaderstats = {}
			removeAllGameStats()
		end

		player.ChildAdded:connect(function(child)
			if child.Name == 'leaderstats' then
				onLeaderstatsAdded(child)
			end
		end)
		player.ChildRemoved:connect(function(child)
			if child.Name == 'leaderstats' then
				onLeaderstatsRemoved()
			end
		end)

		local leaderstats = player:FindFirstChild('leaderstats')
		if leaderstats then
			onLeaderstatsAdded(leaderstats)
		end
	end	-- end initialize

	function this:GetLeaderstats()
		return myLeaderstats
	end

	return this
end

return LeaderstatsData
