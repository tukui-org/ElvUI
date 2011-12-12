-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Spam Throttle", "AceEvent-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
local Frame		= CreateFrame("Frame")
Module.name		= L["Spam Throttle"]

local db
local options
local defaults = {
	profile = {
		throttleMode		= "HIDE",
		throttleColor		= { r = 0.45, g = 0.45, b = 0.45 },
		throttleInterval	= 60, -- 1 minutes
		throttle			= {}
	}
}

-- we'll use them later
local msgList, msgCount, msgTime = {}, {}, {}

local function PrepareMessage(author, message)
	return author:upper() .. message
end

local function MessageFilter(self, event, message, author, ...)
	local blockFlag = false
	local msg = PrepareMessage(author, message)
	
	if msg == nil then return false end
	
	-- ignore player messages
	if author == UnitName("player") then return false end
	
	if event == "CHAT_MSG_YELL" then
		if msgList[msg] and msgCount[msg] > 1 then
			if difftime(time(), msgTime[msg]) <= db.throttleInterval then
				blockFlag = true
			end
		end
	else
		if msgList[msg] then
			if difftime(time(), msgTime[msg]) <= db.throttleInterval then
				blockFlag = true
			end
		end
	end
	
	if blockFlag then
		if db.throttleMode == "COLOR" then
			-- clean the text and then change the color
			local cleantext = message:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h", ""):gsub("|h", "")
			local color = ("%02x%02x%02x"):format(db.throttleColor.r * 255, db.throttleColor.g * 255, db.throttleColor.b * 255)
			return false, ("|cff%s%s|r"):format(color, cleantext), author, ...
		else
			return true
		end
	end
	
	msgTime[msg] = time()
	return false
end

local function EventHandler(self, event, ...)
	local arg1, arg2 = ...
	
	if arg2 ~= "" then
		local message = PrepareMessage(arg2, arg1)
		if msgList[message] == nil then
			msgList[message] = true
			msgCount[message] = 1
			msgTime[message] = time()
		else
			msgCount[message] = msgCount[message] + 1
		end
	end
end
Frame:RegisterEvent("CHAT_MSG_CHANNEL")
Frame:RegisterEvent("CHAT_MSG_YELL")
Frame:SetScript("OnEvent", EventHandler)

function Module:OnEnable()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL",	MessageFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL",	MessageFilter)
end

function Module:OnDisable()
	self:UnregisterAllEvents()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL",	MessageFilter)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL",		MessageFilter)
	table.wipe(msgList); table.wipe(msgCount); table.wipe(msgTime)
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("SpamThrottle", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Throttle messages from being displayed (spammed) in chat channels."]
end

function Module:GetOptions()
	if not options then
		options = {
			throttleMode = {
				type		= "select",
				order		= 13,
				name		= L["Filtering Mode"],
				desc		= L["How to throttle the spam.\n\n|cff00ff00Colorize|r changes the spam to a different color.\n|cff00ff00Remove|r removes the line all together."],
				values		= {
					["COLOR"]	= L["Colorize"],
					["HIDE"]	= L["Remove"],
				},
				get			= function() return db.throttleMode end,
				set			= function(_, value) db.throttleMode = value end,
			},
			throttleColor = {
				type		= "color",
				order		= 14,
				name		= L["Filter Color"],
				desc		= L["Color to change the spam to.\n\n|cffff0000Only works when Filtering Mode is set to |cff00ff00Colorize|r."],
				get			= function() return db.throttleColor.r, db.throttleColor.g, db.throttleColor.b end,
				set			= function(_, r, g, b)
					db.throttleColor.r = r
					db.throttleColor.g = g
					db.throttleColor.b = b
				end
			},
			throttleInterval = {
				type		= "range",
				order		= 14,
				name		= L["Filter Interval"],
				desc		= L["Time, in seconds, in between throttleed message being allowed."],
				get			= function() return db.throttleInterval end,
				set			= function(_, value) db.throttleInterval = value end,
				min = 0, max = 600, step = 20,
			}
		}
	end
	return options
end