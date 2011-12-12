-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Channel Sounds", "AceEvent-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
local LSM		= LibStub("LibSharedMedia-3.0")
Module.name		= L["Channel Sounds"]

local format	= string.format
local upper		= string.upper

local db
local channelString	= "CHAT_MSG_%s"
local channelPattern	= "CHAT_MSG_(.+)"
local soundChannels 		= {
	[L["Guild"]]				= "GUILD",
	[L["Officer"]] 				= "OFFICER",
	[L["Party"]] 				= "PARTY",
	[L["Party Leader"]] 		= "PARTY_LEADER",
	[L["Raid"]] 				= "RAID",
	[L["Raid Leader"]] 			= "RAID_LEADER",
	[L["Say"]] 					= "SAY",
	[L["Yell"]]					= "YELL",
	[L["Battleground"]]			= "BATTLEGROUND",
	[L["Battleground Leader"]]	= "BATTLEGROUND_LEADER",
	[L["Emote"]] 				= "EMOTE",
	[L["Monster Emote"]] 		= "MONSTER_EMOTE",
	[L["Monster Say"]]			= "MONSTER_SAY",
	[L["Raid Boss Emote"]] 		= "RAID_BOSS_EMOTE"
}

local options = {}

local defaults = {
	profile = {
		guildSound				= "None",
		officerSound			= "None",
		partySound				= "None",
		partyLeaderSound		= "None",
		raidSound				= "None",
		raidLeaderSound			= "None",
		battlegroundSound		= "None",
		battlegroundLeaderSound	= "None",
		bgSystemAlliance		= "None",
		bgSystemHorde			= "None",
		bgSystemNeutral			= "None",
		saySound				= "None",
		yellSound				= "None",
		emoteSound				= "None",
		monsterEmoteSound		= "None",
		monsterSaySound			= "None",
		raidBossEmoteSound		= "None"
	}
}

local function capitalize(str)
    return str:gsub("^%l", upper)
end

local function getSettingName(str)
	if not str:find("_") then
		return str:lower() .. "Sound"
	else
		local first, temp = false, ""
		for word in str:gmatch("%w+") do
			if not first then
				temp = word:lower()
				first = true
			else
				temp = temp .. capitalize(word:lower())
			end
		end
		return temp .. "Sound"
	end
end

function Module:ChannelSounds(event, ...)
	local channel = event:match(channelPattern)
	if not channel then return end
	local setting = getSettingName(channel)
	if db[setting] and db[setting] ~= "None" then
		PlaySoundFile(LSM:Fetch("sound", db[setting]))
	end
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("ChannelSounds", defaults)
	db = self.db.profile
	
	for name, value in pairs(soundChannels) do
		local setting = getSettingName(value)
		if not options[setting] then
			options[setting] = {
				type			= "select",
				dialogControl	= "LSM30_Sound",
				name			= name,
				desc			= format(L["Sound to play when a message in %s is received.\n\n|cff00ff00To disable set to \"None\"|r."], name:lower()),
				values			= AceGUIWidgetLSMlists.sound,
				get				= function() return db[setting] or "None" end,
				set				= function(_, value) db[setting] = value end
			}
		end
	end
end

function Module:OnEnable()
	for name, value in pairs(soundChannels) do
		self:RegisterEvent(format(channelString, value), "ChannelSounds")
	end
end

function Module:OnDisable()
	self:UnregisterAllEvents()
end

function Module:GetOptions()
	return options
end

function Module:Info()
	return L["Plays a sound, of your choosing (via LibSharedMedia-3.0), whenever a message is received in a given channel."]
end