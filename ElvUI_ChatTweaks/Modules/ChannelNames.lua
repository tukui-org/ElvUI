-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module		= ElvUI_ChatTweaks:NewModule("Channel Names", "AceHook-3.0", "AceEvent-3.0")
local L				= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name			= L["Channel Names"]

local gsub		= string.gsub
local find		= string.find
local format	= string.format

local emptyTag	= L["$$EMPTY$$"]
local channels
local functions = {}

local db
local options
local defaults = {
	profile = {
		guild					= true,
		guildText				= "[G]",
		officer					= true,
		officerText				= "[O]",
		party					= true,
		partyText				= "[P]",
		partyLeader				= true,
		partyLeaderText			= "[PL]",
		dungeonGuide			= true,
		dungeonGuideText		= "[DG]",
		raid					= true,
		raidText				= "[R]",
		raidLeader				= true,
		raidLeaderText			= "[RL]",
		raidWarning				= true,
		raidWarningText			= "[RW]",
		battleground			= true,
		battlegroundText		= "[BG]",
		battlegroundLeader		= true,
		bgLeaderText			= "[BGL]",
		addSpace				= true,
		filterAFK				= true,
		afkMessage				= "[Away]",
		useAFKColor				= true,
		afkColor				= {r = 1.0, g = 1.0, b = 0.0},
		filterDND				= true,
		dndMessage				= "[Busy]",
		useDNDColor				= true,
		dndColor				= {r = 1.0, g = 0.0, b = 0.0},
	}
}

local function replaceChannel(origChannel, msg, num, channel)
	local f = functions[channel] or functions[channel:lower()]
	local newChannelName = f and f(channel) or channels[channel] or channels[channel:lower()] or msg
	if newChannelName == emptyTag then return "" end
	return ("|Hchannel:%s|h%s|h%s"):format(origChannel, newChannelName, db.addSpace and " " or "")
end

local function replaceChannelRW(msg, channel)
	local f = functions[channel] or functions[channel:lower()]
	local newChannelName = f and f(channel) or channels[channel] or channels[channel:lower()] or msg
	return newChannelName .. (db.addSpace and " " or "")
end

function Module:AddMessage(frame, text, ...)
	if not text then 
		return self.hooks[frame].AddMessage(frame, text, ...)
	end
	-- removed the start of check, since blizz timestamps inject themselves in front of the line
	text = text:gsub("|Hchannel:(%S-)|h(%[([%d. ]*)([^%]]+)%])|h ", replaceChannel)
	text = text:gsub("(%[(" .. L["Raid Warning"] .. ")%]) ", replaceChannelRW)
	
	-- afk flag
	if db.filterAFK and text:match(CHAT_FLAG_AFK) then
		local color = ("%02x%02x%02x"):format(db.afkColor.r * 255, db.afkColor.g * 255, db.afkColor.b * 255)
		local msg = ("%s%s%s "):format(db.useAFKColor == true and "|cff" .. color or "", db.afkMessage, db.useAFKColor == true and "|r" or "")
		text = text:gsub(CHAT_FLAG_AFK, msg)
	end
	
	-- dnd flag
	if db.filterDND and text:match(CHAT_FLAG_DND) then
		local color = ("%02x%02x%02x"):format(db.dndColor.r * 255, db.dndColor.g * 255, db.dndColor.b * 255)
		local msg = ("%s%s%s "):format(db.useDNDColor == true and "|cff" .. color or "", db.dndMessage, db.useDNDColor == true and "|r" or "")
		text = text:gsub(CHAT_FLAG_DND, msg)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function Module:BuildChannels()
	channels = {
		[L["Guild"]]				= db.guild and db.guildText or L["[Guild]"],
		[L["Officer"]]				= db.officer and db.officerText or L["[Officer]"],
		[L["Party"]]				= db.party and db.partyText or L["[Party]"],
		[L["Party Leader"]]			= db.partyLeader and db.partyLeaderText or L["[Party Leader]"],
		[L["Dungeon Guide"]]		= db.dungeonGuide and db.dungeonGuideText or L["[Dungeon Guide]"],
		[L["Raid"]]					= db.raid and db.raidText or L["[Raid]"],
		[L["Raid Leader"]]			= db.raidLeader and db.raidLeaderText or L["[Raid Leader]"],
		[L["Raid Warning"]]			= db.raidWarning and db.raidWarningText or L["[Raid Warning]"],
		[L["Battleground"]]			= db.battleground and db.battlegroundText or L["[Battleground]"],
		[L["Battleground Leader"]]	= db.battlegroundLeader and db.bgLeaderText or L["[Battleground Leader]"],	
	}
	functions = {}
	-- for channel name replacement
	for k, v in pairs(channels) do
		if v:match("^function%(") then
			functions[k] = loadstring("return " .. v)()
		end
	end
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("ChannelNames", defaults)
	db = self.db.profile
end

function Module:Decorate(frame)
	if not self:IsHooked(frame, "AddMessage") then
		self:RawHook(frame, "AddMessage", true)
	end
end

function Module:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[format("ChatFrame%d", i)]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index, frame in ipairs(self.TempChatFrames) do
		local cf = _G[frame]
		self:RawHook(cf, "AddMessage", true)
	end
	self:BuildChannels()
end

function Module:Info()
	return L["Enables you to replace channel names with your own names. You can use '%s' to force an empty string."]:format( emptyTag )
end

function Module:GetOptions()
	if not options then
		options = {
			afkFiltering = {
				type		= "group",
				name		= L["AFK Flag Replacement"],
				args		= {
					afkDesc = {
						type		= "description",
						name		= L["These settings allow you to change the text used when a player has the AFK flag.\n\n|cffff0000NOTE|r  This does not affect the AFK flag on the player's nameplate."],
						order		= 1,
					},			
					filterAFK = {
						type		= "toggle",
						order		= 2,
						name		= L["AFK Flag"],
						desc		= L["Replace AFK flag text with our own custom one."],
						get			= function() return db.filterAFK end,
						set			= function(_, value) db.filterAFK = value end,
					},
					afkMessage = {
						type		= "input",
						order		= 3,
						name		= L["New AFK Message"],
						desc		= L["Replacement text for the AFK flag."],
						disabled	= function() return not db.filterAFK end,
						get			= function() return db.afkMessage end,
						set			= function(_, value) db.afkMessage = value end
					},
					useAFKColor = {
						type		= "toggle",
						order		= 4,
						name		= L["Color AFK Flag?"],
						desc		= L["Use a color to distinguish the AFK flag."],
						get			= function() return db.useAFKColor end,
						set			= function(_, value) db.useAFKColor = value end,
					},
					afkColor = {
						type		= "color",
						order		= 5,
						name		= L["AFK Flag Color"],
						desc		= L["Color to use for the AFK flag."],
						disabled	= function() return not db.useAFKColor end,
						get			= function() return db.afkColor.r, db.afkColor.g, db.afkColor.b end,
						set			= function(_, r, g, b)
							db.afkColor.r = r
							db.afkColor.g = g
							db.afkColor.b = b
						end
					}
				}
			},
			dndFiltering = {
				type		= "group",
				name		= L["DND Flag Replacement"],
				args		= {
					dndDesc = {
						type		= "description",
						name		= L["These settings allow you to change the text used when a player has the DND flag.\n\n|cffff0000NOTE|r  This does not affect the DND flag on the player's nameplate."],
						order		= 1,
					},	
					filterDND = {
						type		= "toggle",
						order		= 2,
						name		= L["DND Flag"],
						desc		= L["Replace DND flag text with our own custom one."],
						get			= function() return db.filterDND end,
						set			= function(_, value) db.filterDND = value end
					},
					dndMessage = {
						type		= "input",
						order		= 3,
						name		= L["New DND Message"],
						desc		= L["Replacement text for the DND flag."],
						disabled	= function() return not db.filterDND end,
						get			= function() return db.dndMessage end,
						set			= function(_, value) db.dndMessage = value end
					},
					useDNDColor = {
						type		= "toggle",
						order		= 4,
						name		= L["Color DND Flag"],
						desc		= L["Use a color to distinguish the DND flag."],
						get			= function() return db.useDNDColor end,
						set			= function(_, value) db.useDNDColor = value end
					},
					dndColor = {
						type		= "color",
						order		= 5,
						name		= L["DND Flag Color"],
						desc		= L["Color to use for the DND flag."],
						disabled	= function() return not db.useDNDColor end,
						get			= function() return db.dndColor.r, db.dndColor.g, db.dndColor.b end,
						set			= function(_, r, g, b)
							db.dndColor.r = r
							db.dndColor.g = g
							db.dndColor.b = b
						end
					}
				}
			},
			guild				= {
				type		= "toggle",
				order		= 13,
				name		= L["Guild"],
				desc		= L["Guild Channel"],
				get			= function() return db.guild end,
				set			= function(_, value) db.guild = value; Module:BuildChannels() end
			},
			guildText			= {
				type		= "input",
				order		= 14,
				name		= L["Guild Text"],
				desc		= L["Text for guild chat."],
				disabled	= function() return not db.guild end,
				get			= function() return db.guildText end,
				set			= function(_, value) db.guildText = value; Module:BuildChannels() end,
			},
			officer				= {
				type		= "toggle",
				order		= 15,
				name		= L["Officer"],
				desc		= L["Officer Channel"],
				get			= function() return db.officer end,
				set			= function(_, value) db.officer = value; Module:BuildChannels() end
			},
			officerText			= {
				type		= "input",
				order		= 16,
				name		= L["Officer Text"],
				desc		= L["Text for officer chat."],
				disabled	= function() return not db.officer end,
				get			= function() return db.officerText end,
				set			= function(_, value) db.officerText = value; Module:BuildChannels() end
			},
			party				= {
				type		= "toggle",
				order		= 17,
				name		= L["Party"],
				desc		= L["Party Channel"],
				get			= function() return db.party end,
				set			= function(_, value) db.party = value; Module:BuildChannels() end
			},
			partyText			= {
				type		= "input",
				order		= 18,
				name		= L["Party Text"],
				desc		= L["Text for party chat."],
				disabled	= function() return not db.party end,
				get			= function() return db.partyText end,
				set			= function(_, value) db.partyText = value; Module:BuildChannels() end
			},
			partyLeader			= {
				type		= "toggle",
				order		= 19,
				name		= L["Party Leader"],
				desc		= L["Party Leader Channel"],
				get			= function() return db.partyLeader end,
				set			= function(_, value) db.partyLeader = value; Module:BuildChannels() end
			},
			partyLeaderText		= {
				type		= "input",
				order		= 20,
				name		= L["Party Leader Text"],
				desc		= L["Text for party leader chat."],
				disabled	= function() return not db.partyLeader end,
				get			= function() return db.partyLeaderText end,
				set			= function(_, value) db.partyLeaderText = value; Module:BuildChannels() end
			},
			dungeonGuide		= {
				type		= "toggle",
				order		= 21,
				name		= L["Dungeon Guide"],
				desc		= L["Dungeon Guide Channel"],
				get			= function() return db.dungeonGuide end,
				set			= function(_, value) db.dungeonGuide = value; Module:BuildChannels() end
			},
			dungeonGuideText	= {
				type		= "input",
				order		= 22,
				name		= L["Dungeon Guide Text"],
				desc		= L["Text for dungeon guide text."],
				disabled	= function() return not db.dungeonGuide end,
				get			= function() return db.dungeonGuideText end,
				set			= function(_, value) db.dungeonGuideText = value; Module:BuildChannels() end
			},
			raid				= {
				type		= "toggle",
				order		= 23,
				name		= L["Raid"],
				desc		= L["Raid Channel"],
				get			= function() return db.raid end,
				set			= function(_, value) db.raid = value; Module:BuildChannels() end
			},
			raidText			= {
				type		= "input",
				order		= 24,
				name		= L["Raid Text"],
				desc		= L["Text for raid chat."],
				disabled	= function() return not db.raid end,
				get			= function() return db.raidText end,
				set			= function(_, value) db.raidText = value; Module:BuildChannels() end
			},
			raidLeader			= {
				type		= "toggle",
				order		= 25,
				name		= L["Raid Leader"],
				desc		= L["Raid Leader Channel"],
				get			= function() return db.raidLeader end,
				set			= function(_, value) db.raidLeader = value; Module:BuildChannels() end
			},
			raidLeaderText		= {
				type		= "input",
				order		= 26,
				name		= L["Raid Leader Text"],
				desc		= L["Text for raid leader chat."],
				disabled	= function() return not db.raidLeader end,
				get			= function() return db.raidLeaderText end,
				set			= function(_, value) db.raidLeaderText = value; Module:BuildChannels() end
			},
			raidWarning			= {
				type		= "toggle",
				order		= 27,
				name		= L["Raid Warning"],
				desc		= L["Raid Warning Channel"],
				get			= function() return db.raidWarning end,
				set			= function(_, value) db.raidWarning = value; Module:BuildChannels() end
			},
			raidWarningText		= {
				type		= "input",
				order		= 28,
				name		= L["Raid Warning Text"],
				desc		= L["Text for raid warning chat."],
				disabled	= function() return not db.raidWarning end,
				get			= function() return db.raidWarningText end,
				set			= function(_, value) db.raidWarningText = value; Module:BuildChannels() end
			},
			battleground		= {
				type		= "toggle",
				order		= 29,
				name		= L["Battleground"],
				desc		= L["Battleground Channel"],
				get			= function() return db.battleground end,
				set			= function(_, value) db.battleground = value; Module:BuildChannels() end
			},
			battlegroundText	= {
				type		= "input",
				order		= 30,
				name		= L["Battleground Text"],
				desc		= L["Text for battleground chat."],
				disabled	= function() return not db.battleground end,
				get			= function() return db.battlegroundText end,
				set			= function(_, value) db.battlegroundText = value; Module:BuildChannels() end
			},
			battlegroundLeader	= {
				type		= "toggle",
				order		= 31,
				name		= L["Battleground Leader"],
				desc		= L["Battleground Leader Channel"],
				get			= function() return db.battlegroundLeader end,
				set			= function(_, value) db.battlegroundLeader = value; Module:BuildChannels() end
			},
			bgLeaderText		= {
				type		= "input",
				order		= 32,
				name		= L["Battleground Leader Text"],
				desc		= L["Text for battleground leader chat."],
				disabled	= function() return not db.battlegroundLeader end,
				get			= function() return db.bgLeaderText end,
				set			= function(_, value) db.bgLeaderText = value; Module:BuildChannels() end
			},
			addSpace			= {
				type		= "toggle",
				order		= 33,
				name		= L["Add Space"],
				desc		= L["Add a space after the channel name."],
				get			= function() return db.addSpace end,
				set			= function(_, value) db.addSpace = value end
			}
		}
	end
	return options
end

Module.funcs = functions