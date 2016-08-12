--[[
			// SocialData.lua

			 // Stores all social relationships for the current client

			 // TODO: We don't need this for xbox right now
]]
local CoreGui = game:GetService('CoreGui')
local PlayersService = game:GetService('Players')

local RobloxGui = CoreGui:FindFirstChild('RobloxGui')
local Modules = RobloxGui:FindFirstChild('Modules')
local Settings = Modules:FindFirstChild('Settings')
local Utility = require(Settings:FindFirstChild('Utility'))

local CreateSignal = Utility.CreateSignal

local SocialData = {}

SocialData.FollowStatus = {
	None = 1;
	Follower = 2;
	Following = 3;
	Mutual = 4;
}

local LocalPlayer = PlayersService.LocalPlayer
local MyRelationshipMap  = {}	-- Map of userId to relationship

--[[ Public Events ]]--
SocialData.SocialStatusChanged = CreateSignal()

local function getFriendsStatus(otherPlayer)
	local success, result = pcall(function()
		return LocalPlayer:GetFriendStatus(otherPlayer)
	end)
	if not success then
		return Enum.FriendStatus.Unknown
	end

	return result
end

local function createSocialRelationship(userId)
	local this = {}

	this.UserId = userId
	this.FriendStatus = Enum.FriendStatus.Unknown
	this.FollowStatus = SocialData.FollowStatus.None

	return this
end

local function onFriendshipChanged(otherPlayer, friendshipStatus)
	local relationshipObject = MyRelationshipMap[otherPlayer.UserId]
	if not relationshipObject then
		relationshipObject = createSocialRelationship(otherPlayer.UserId)
	end

	relationshipObject.FriendStatus = friendshipStatus
	SocialData.SocialStatusChanged:fire(relationshipObject)
end

-- CoreScript Only
-- This will fire when any new player joins the server, and for each player already in the server
-- when our client joins
LocalPlayer.FriendStatusChanged:connect(onFriendshipChanged)
for _,player in pairs(PlayersService:GetPlayers()) do
	if player.UserId > 0 and player.UserId ~= LocalPlayer.UserId then
		local status = getFriendsStatus(player)
		onFriendshipChanged(player, status)
	end
end
PlayersService.ChildRemoved:connect(function(child)
	if child:IsA('Player') then
		MyRelationshipMap[child.UserId] = nil
	end
end)

--[[ Public API ]]--
function SocialData:GetSocialRelationship(userId)
	return MyRelationshipMap[userId]
end

function SocialData:GetAllSocialRelationships()
	return MyRelationshipMap
end

return SocialData
