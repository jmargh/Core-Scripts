--[[
]]
local CoreGui = game:GetService('CoreGui')
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Http = require(RobloxGui.Modules.Common.Http)

local PlayerPermissionsModule = {}

local CAN_MANAGE_PATH = "/users/%d/canmanage/%d"

local function HasRankInGroupFunctionFactory(groupId, requiredRank)
	local hasRankCache = {}
	assert(type(requiredRank) == "number", "requiredRank must be a number")
	return function(player)
		if player and player.UserId > 0 then
			if hasRankCache[player.UserId] == nil then
				local hasRank = false
				pcall(function()
					hasRank = player:GetRankInGroup(groupId) >= requiredRank
				end)
				hasRankCache[player.UserId] = hasRank
			end
			return hasRankCache[player.UserId]
		end
		return false
	end
end

local function IsInGroupFunctionFactory(groupId)
	local inGroupCache = {}
	return function(player)
		if player and player.UserId > 0 then
			if inGroupCache[player.UserId] == nil then
				local inGroup = false
				pcall(function()
					inGroup = player:IsInGroup(groupId)
				end)
				inGroupCache[player.UserId] = inGroup
			end
			return inGroupCache[player.UserId]
		end
		return false
	end
end

function PlayerPermissionsModule.CanManagePlaceAsync(userId)
	if not userId then
		return false
	end

	-- user is the place owner
	if game.CreatorType == Enum.CreatorType.User and userId == game.CreatorId then
		return true
	end

	-- check if user can manage group game
	if game.CreatorType == Enum.CreatorType.Group then
		local success, result = pcall(function()
			return settings():GetFFlag("UseCanManageApiToDetermineConsoleAccess")
		end)

		if success and result == true then
			local placeId = game.PlaceId
			local path = string.format(CAN_MANAGE_PATH, userId, placeId)
			local result = Http.RbxApiGetAsync(path)

			return result and result["CanManage"] or false
		end
	end
end

PlayerPermissionsModule.IsPlayerAdminAsync = IsInGroupFunctionFactory(1200769)
PlayerPermissionsModule.IsPlayerInternAsync = HasRankInGroupFunctionFactory(2868472, 100)

return PlayerPermissionsModule