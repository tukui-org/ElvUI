-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Custom Chat Filters")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Custom Chat Filters"]

local format	= string.format

local db, options
local defaults = {
	profile = {
		filterMode		= "HIDE",
		filterColor		= {r = 0.45, g = 0.45, b = 0.45},
		customFilters	= {
			"^[aA]nal (.+)$",
			"[aA]nal",
			"Thunderfury",
		},
	}
}

local function CustomFilters(self, event, message, author, ...)
	if not message or #db.customFilters == 0 or author == UnitName("player") then return end
	for _, value in pairs(db.customFilters) do
		if message:match(value) then
			if db.filterMode == "COLOR" then
				-- colorize it
				local color = ("%02x%02x%02x"):format(db.filterColor.r * 255, db.filterColor.g * 255, db.filterColor.b * 255)
				return false, format("|cff%s%s|r", color, message), author, ...
			else
				-- filter
				return true
			end
		end
	end
end

function Module:PopulateFilters(filters)
	db.customFilters = {}
	for _, value in pairs(filters) do
		if value ~= "" and value ~= nil then
			db.customFilters[#db.customFilters + 1] = value
		end
	end
end

function Module:FiltersToString()
	local trigs = ""
	for i = 1, #db.customFilters do
		if db.customFilters[i]:trim() ~= "" then
			trigs = trigs .. db.customFilters[i] .. "\n"
		end
	end
	return trigs
end

function Module:OnEnable()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CustomFilters)
end

function Module:OnDisable()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", CustomFilters)
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("CustomChatFilters", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Allows you to filter certain words or phrases using Lua's pattern matching. For an item, achievement, spell, etc. just use the name of the item, don't try to link it.\n\nFor more information see this addon's Curse or WoWInterface page."]
end

function Module:GetOptions()
	if not options then
		options = {
			filterMode = {
				type		= "select",
				order		= 13,
				name		= L["Filtering Mode"],
				desc		= L["How to filter any matches."],
				values		= {
					["COLOR"]	= L["Colorize"],
					["HIDE"]	= L["Remove"],
				},
				get			= function() return db.filterMode end,
				set			= function(_, value) db.filterMode = value end
			},
			filterColor = {
				type		= "color",
				order		= 14,
				name		= L["Filter Color"],
				desc		= L["Color to change the filtered message to.\n\n|cffff0000Only works when Filtering Mode is set to |cff00ff00Colorize|r."],
				get			= function() return db.filterColor.r, db.filterColor.g, db.filterColor.b end,
				set			= function(_, r, g, b)
					db.filterColor.r = r
					db.filterColor.g = g
					db.filterColor.b = b
				end
			},
			customFilters = {
				type		= "input",
				order		= 15,
				multiline	= true,
				width		= "double",
				name		= L["Filters"],
				desc		= L["Custom chat filters."],
				get			= function() return Module:FiltersToString() end,
				set			= function(_, value)
					local trigList = {strsplit("\n", value:trim())}
					Module:PopulateFilters(trigList)
				end
			}
		}
	end
	return options
end