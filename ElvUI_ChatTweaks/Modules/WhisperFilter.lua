-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Whisper Filter", "AceEvent-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Whisper Filter"]

local wipe = table.wipe

local response		= L["You need to be at least level %d to whisper me."]
local friendError	= L["You have reached the maximum amount of friends, remove 2 for this module to function properly."]
local good, maybe, filter, login = {}, {}, {}, false

local db
local options
local defaults = {
	profile = {
		minLevel	= 3,
		dkLevel		= 57,
		respond		= true,
		friends		= true,
		guild		= true,
	}
}

local function SystemMessage(_, _, message)
	if message == ERR_FRIEND_LIST_FULL then
		ElvUI_ChatTweaks:Print(friendError)
		return
	end
	for k in pairs(filter) do
		if message == ERR_FRIEND_ADDED_S:format(k) or msg == ERR_FRIEND_REMOVED_S:format(k) then
			return true
		end
	end
end

local function WhisperMessage(...)
	local player, flag = select(4, ...), select(8, ...)
	if good[player] or player:find("%-") or (db.guild and UnitIsInMyGuild("player")) or flag == "GM" then return end
	
	if db.friend then
		for i = 1, select(2, BNGetNumFriends()) do
			local toon = BNGetNumFriendToons(i)
			for j = 1, toon do
				local _, rName, rGame, rServer = BNGetFriendToonInfo(i, j)
				if rName == player and rGame == "WoW" and rServer == GetRealmName() then
					good[player] = true
					return
				end
			end
		end
	end
	
	if not maybe[player] then maybe[player] = {} end
	local frame = select(1, ...):GetName()
	if IsAddOnLoaded("WIM") and not frame:find("WIM") then return true end
	if not maybe[player][frame] then maybe[player][frame] = {} end
	
	local id = select(13, ...)
	maybe[player][frame][id] = {}
	local n = IsAddOnLoaded("WIM") and 2 or 0
	for i = 1, select("#", ...) do
		maybe[player][frame][id][i] = select(i + n, ...)
	end
	
	local guid = select(14, ...)
	local _, class = GetPlayerInfoByGUID(guid)
	local level = (class == "DEATHKNIGHT") and db.dkLevel + 1 or db.minLevel + 1
	if not filter[player] or filter[player] ~= level then
		filter[player] = level
		AddFriend(player, true)	-- for FriendsWithBenefits compatibility
	end
	return true
end

local function WhisperInform(_, _, message, player)
	if good[player] then return end
	if db.respond and filter[player] and msg:find(format(response, filter[player])) then return true end
	good[player] = true
end

function Module:ExcludeFriends()
	for i = 1, GetNumFriends() do
		local friend = GetFriendInfo(i)
		if friend then good[friend] = true end
	end
end

function Module:PLAYER_LOGIN(event)
	ShowFriends()
	good[UnitName("player")] = true -- we're good
end

function Module:FRIENDLIST_UPDATE(event)
	if db.friends and not login then
		-- only do this once
		login = true
		self:ExcludeFriends()
		return
	end
	
	for i = 1, GetNumFriends() do
		local player, level = GetFriendInfo(i)
		
		if not player then
			ShowFriends()
		else
			if maybe[player] then
				RemoveFriend(player, true)
				if level < filter[player] then
					if respond then
						SendChatMessage(response:format(filter[player]), "WHISPER", nil, player)
					end
					for _, v in pairs(maybe[player]) do
						for _, p in pairs(v) do
							wipe(p)
						end
						wipe(v)
					end
				else
					good[player] = true
					for _, v in pairs(maybe[player]) do
						for _, p in pairs(v) do
							if IsAddOnLoaded("WIM") then
								WIM.modules.WhisperEngine:CHAT_MSG_WHISPER(unpack(p))
							else
								ChatFrame_MessageEventHandler(unpack(p))
							end
							wipe(p)
						end
						wipe(v)
					end
				end
				wipe(maybe[player])
				maybe[player] = nil
			end
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("FRIENDLIST_UPDATE")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SystemMessage)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperMessage)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", WhisperInform)
end

function Module:OnDisable()
	self:UnregisterAllEvents()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", SystemMessage)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", WhisperMessage)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", WhisperInform)
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("WhisperFilter", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Filters whispers if the sender does not meet the level requirement.  Useful for gold seller spam."]
end

function Module:GetOptions()
	if not options then
		options = {
			minLevel = {
				type	= "range",
				order	= 13,
				name	= L["Minimum Level"],
				desc	= L["Minimum level of the sender to able to whisper you."],
				get		= function() return db.minLevel end,
				set		= function(_, value) db.minLevel = value end,
				min = 1, max = GetMaxPlayerLevel(), step = 1,
			},
			dkLevel = {
				type	= "range",
				order	= 14,
				name	= L["Minimum DK Level"],
				desc	= L["Minimum level of a Death Knight to be able to whisper you."],
				get		= function() return db.dkLevel end,
				set		= function(_, value) db.dkLevel = value end,
				min = 55, max = GetMaxPlayerLevel(), step = 1,
			},
			respond = {
				type	= "toggle",
				order	= 15,
				name	= L["Send Response"],
				desc	= L["Send a reponse when a whisper is filtered."],
				get		= function() return db.respond end,
				set		= function(_, value) db.respond = value end,
			},
			exceptions = {
				type	= "group",
				order	= 16,
				inline	= true,
				name	= L["Exceptions"],
				args	= {
					friends = {
						type	= "toggle",
						name	= L["Friends"],
						desc	= L["Allow people on your friends list to whisper you, regardless of their level."],
						get		= function() return db.friends end,
						set		= function(_, value)
							db.friends = value
							wipe(good)
							if db.friends then Module:ExcludeFriends() end
						end,
					},
					guild = {
						type	= "toggle",
						name	= L["Guildies"],
						desc	= L["Allow people in your guild to whisper you, regardless of their level."],
						get		= function() return db.guild end,
						set		= function(_, value) db.guild = value end,
					},
				}
			}
		}
	end
	return options
end
