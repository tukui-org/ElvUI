-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Channel Colors", "AceEvent-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Channel Colors"]

local db
local options
local defaults = {
	profile = {
		colors = {}
	}
}

function Module:AddChannels(...)
	for i = 1, select("#", ...), 2 do
		local id, name = select(i, ...)
		db.colors[name] = db.colors[name] or {}
		if not db.colors[name].r then
			local r, g, b = GetMessageTypeColor(type(id) == "number" and "CHANNEL" .. id or id)
			db.colors[name].r = r
			db.colors[name].g = g
			db.colors[name].b = b
		end
		if not options[name:gsub(" ", "_")] then
			options[name:gsub(" ", "_")] = {
				type	= "color",
				name	= name,
				desc	= L["Select a color for this channel."],
				order	= type(id) == "number" and 50 + id or 48,
				get		= function()
					local c = db.colors[name]
					if c then
						return c.r, c.g, c.b
					else
						return GetMessageTypeColor(type(id) == "number" and "CHANNEL" .. id or id)
					end
				end,
				set		= function(_, r, g, b)
					db.colors[name] = db.colors[name] or {}
					db.colors[name].r = r
					db.colors[name].g = g
					db.colors[name].b = b
					ChangeChatColor(type(id) == "number" and "CHANNEL" .. id or id, r, g, b)
				end
			}
		end
	end
end

function Module:UPDATE_CHAT_COLOR(event, channel, red, green, blue)
	if channel then
		local number = tonumber(channel:match("(%d+)$"))
		local chanNumber = number and select(2, GetChannelName(number))
		local name = chanNumber and chanNumber:match("^(%w+)") or channel
		db.colors[name] = db.colors[name] or {}
		db.colors[name].r = red
		db.colors[name].g = green
		db.colors[name].b = blue
	end
end

function Module:CHAT_MSG_CHANNEL_NOTICE(event, notice, _, _, fullname, _, _, chanType, chanNumber, chanName)
	if notice == "YOU_JOINED" then
		self:AddChannels(GetChannelList())
		chanName = chanName:match("^(%w+)")
		local color = db.colors[chanName]
		if color then
			ChangeChatColor("CHANNEL" .. chanNumber, color.r, color.g, color.b)
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("UPDATE_CHAT_COLOR")
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
	self:AddChannels(GetChannelList())
	self:AddChannels(
		"SAY",					L["Say"],
		"YELL",					L["Yell"],
		"GUILD",				L["Guild"], 
		"OFFICER",				L["Officer"], 
		"PARTY",				L["Party"], 
		"PARTY_LEADER", 		L["Party Leader"],
		"RAID",					L["Raid"], 
		"RAID_LEADER",			L["Raid Leader"],
		"RAID_WARNING",			L["Raid Warning"],
		"BATTLEGROUND",			L["Battleground"],
		"BATTLEGROUND_LEADER",	L["Battleground Leader"],
		"WHISPER",				L["Whisper"],
		"BN_WHISPER",			L["RealID Whisper"],
		"BN_CONVERSATION",		L["RealID Conversation"]	
	)
end

function Module:OnDisable()
	self:UnregisterAllEvents()
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("ChannelColors", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Keeps your channel colors by name rather than by number."]
end

function Module:GetOptions()
	if not options then
		options = {
			splitter = {
				type	= "header",
				name	= L["Other Channels"],
				order	= 49
			}
		}
	end
	return options
end