-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------

--[[ Module based on SpamageMeters by Wrug and Cybey ]]--
local Module	= ElvUI_ChatTweaks:NewModule("Damage Meters", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Damage Meters"]

local upper		= string.upper
local format	= string.format
local insert	= table.insert

local db, options = {}, {}
local defaults = {
	profile = {
		capture = 1,
	}
}

-- spam pattern matching
local firstLines = {
	"^Recount - (.*)$", 									-- Recount
	"^Skada report on (.*) for (.*), (.*) to (.*):$",		-- Skada enUS
	"^Skada: Bericht für (.*) gegen (.*), (.*) bis (.*):$",	-- Skada deDE, might change in new Skada version
	"^Skada : (.*) pour (.*), de (.*) à (.*) :$",			-- Skada frFR
	"^(.*) - (.*)의 Skada 보고, (.*) ~ (.*):$",				-- Skada koKR
	"^Skada报告(.*)的(.*), (.*)到(.*):$",					-- Skada zhCN, might change in new Skada version
	"^(.*)的報告來自(.*)，從(.*)到(.*)：$",					-- Skada zhTW, might change in new Skada version
	"^Skada: (.*) for (.*), (.*) - (.*):$",					-- Better Skada support player details
	"^(.*) Done for (.*)$"									-- TinyDPS
}
local nextLines = {
	"^(%d+). (.*)$",										-- Recount and Skada
	"^ (%d+). (.*)$", 										-- Skada
	"^.*%%%)$", 											-- Skada player details
	"^(%d+). (.*):(.*)(%d+)(.*)(%d+)%%(.*)%((%d+)%)$" 		-- TinyDPS
}

local meters = {}
local events = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_YELL",
}

local function ChannelName(name)
	return name:lower():gsub("_", " "):gsub("(%w+)", function(first)
		return first:gsub("^%l", upper)
	end)
end

local function FilterLine(event, source, message, ...)
	local spam = false
	for k, v in ipairs(nextLines) do
		if message:match(v) then
			local curTime = time()
			for i, j in ipairs(meters) do
				local elapsed = curTime - j.time
				if j.source == source and j.event == event and elapsed < db.capture then
					local toInsert = true
					for a, b in ipairs(j.data) do
						if b == message then
							toInsert = false
						end
					end
					
					if toInsert then insert(j.data, message) end
					return true, false, nil
				end
			end
		end
	end
	
	for k, v in ipairs(firstLines) do
		local newID = 0
		if message:match(v) then
			local curTime = time()
			
			for i, j in ipairs(meters) do
				local elapsed = curTime - j.time
				if j.source == source and j.event == event and elapsed < db.capture then
					newID = i
					return true, true, format("|HECT:%1$d|h|cFFFFFF00[%2$s]|r|h", newID or 0, message or "nil")
				end
			end
			
			insert(meters, {
				source	= source,
				event	= event,
				time	= curTime,
				data	= {},
				title	= message
			})
			
			for i, j in ipairs(meters) do
				if j.source == source and j.event == event and j.time == curTime then
					newID = i
				end
			end
			
			return true, true, format("|HECT:%1$d|h|cFFFFFF00[%2$s]|r|h", newID or 0, message or "nil")
		end
	end
	return false, false, nil
end

function Module:ParseLink(link, text, button, frame)
	local linkType, id = strsplit(":", link)
	if linkType == "ECT" then
		local meterID = tonumber(id)
		ShowUIPanel(ItemRefTooltip)
		if not ItemRefTooltip:IsShown() then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		end
		ItemRefTooltip:ClearLines()
		ItemRefTooltip:AddLine(meters[meterID].title)
		ItemRefTooltip:AddLine(format(L["Reported by %s"], meters[meterID].source))
		for k, v in ipairs(meters[meterID].data) do
			local left, right = v:match("^(.*)  (.*)$")
			if left and right then
				ItemRefTooltip:AddDoubleLine(left, right, 1, 1, 1, 1, 1, 1)
			else
				ItemRefTooltip:AddLine(v, 1, 1, 1)
			end
		end
		ItemRefTooltip:Show()
	else
		return self.hooks["SetItemRef"](link, text, button, frame)
	end
end

function Module:ParseChatEvent(event, message, sender, ...)
	local hide = false
	
	for _, value in ipairs(events) do
		local name = value:match("CHAT_MSG_(.+)")
		local setting = ChannelName(name)
		if event == value and db[setting] > 1 then
			local isRecount, isFirstLine, newMessage = FilterLine(event, sender, message)
			if isRecount then
				if isFirstLine and db[setting] == 2 then
					return false, newMessage, sender, ...
				else
					return true
				end
			end
		end
	end
end

function Module:OnEnable()
	local i = 1
	for _, event in pairs(events) do
		ChatFrame_AddMessageEventFilter(event, self.ParseChatEvent)
		local name = event:match("CHAT_MSG_(.+)")
		local setting = ChannelName(name)
		db[setting] = db[setting] or 2
		if not options[name] then
			options[name] = {
				type	= "select",
				order	= 13 + i,
				name	= setting .. " Chat",
				desc	= L["What to do with Recount/Skada/TinyDPS reports in this channel."],
				values	= {
					[1] = L["Do Nothing"],
					[2] = L["Compress"],
					[3] = L["Suppress"]
				},
				get		= function() return db[setting] end,
				set		= function(_, value) db[setting] = value end,
			}
			i = i + 1
		end
	end	
	self:RawHook("SetItemRef", "ParseLink", true)
end

function Module:Disable()
	for _, event in pairs(events) do
		ChatFrame_RemoveMessageEventFilter(event, self.ParseChatEvent)
	end
	self:UnhookAll()
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("DamageMeters", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Suppress Recount/Skada/TinyDPS output into a clickable link, or filter it entirely."]
end

function Module:GetOptions()
	if not options.capture then
		options = {
			capture = {
				type	= "range",
				order	= 100,
				name	= L["Capture Delay"],
				desc	= L["Time, in seconds, the module will wait after the first line is found to assume it is complete.\n\n|cffffff00One (1) second seems to work.|r"],
				get		= function() return db.capture end,
				set		= function(_, value) db.capture = value end,
				min = 1, max = 5, step = 0.1,
			}
		}
	end
	return options
end