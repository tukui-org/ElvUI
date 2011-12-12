-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Invite Links", "AceEvent-3.0", "AceHook-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Invite Links"]

local gsub		= string.gsub
local format	= string.format
local sub		= string.sub
local match		= string.match

local events		= {}
local groupStyle	= "|cffffffff|Hgroupinvite:%s|h[%s]|h|r"
local guildStyle	= "|cffffffff|Hguildinvite:%s|h[%s]|h|r"
local chatEvent, chatEventTarget

local db
local options
local defaults = {
	profile = {
		groupWords			= {},
		guildWords			= {},
		altClickToInvite	= true,
		chatMsgSay			= true,
		chatMsgYell			= true,
		chatMsgWhisper		= true,
		chatMsgOfficer		= true,
		chatMsgGuild		= true,
	}
}

local function addLinks(m, t, p)
	if db.groupWords[t:lower()] and p ~= "_" then
		t = format(groupStyle, chatEventTarget, t)
		return t .. p
	elseif db.guildWords[t:lower()] and p ~= "_" and CanGuildInvite() then
		t = format(guildStyle, chatEventTarget, t)
		return t .. p
	end
	return m
end

function Module:BuildEvents()
	events = {
		CHAT_MSG_SAY		= db.chatMsgSay and true or false,
		CHAT_MSG_YELL		= db.chatMsgYell and true or false,
		CHAT_MSG_WHISPER	= db.chatMsgWhisper and true or false,
		CHAT_MSG_GUILD		= db.chatMsgGuild and true or false,
		CHAT_MSG_OFFICER	= db.chatMsgOfficer and true or false
	}
end

function Module:AddMessage(frame, text, ...)
	if not text then return self.hooks[frame].AddMessage(frame, text, ...) end
	if events[chatEvent] and type(chatEventTarget) == "string" then
		text = gsub(text, "((%w+)(.?))", addLinks)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function Module:ChatFrame_MessageEventHandler(frame, event, ...)
	chatEvent = event
	arg1, chatEventTarget = ...
	return self.hooks["ChatFrame_MessageEventHandler"](frame, event, ...)
end

function Module:SetItemRef(link, text, button)
	local linkType = sub(link, 1, link:find(":") - 1)
	if IsAltKeyDown() and not IsControlKeyDown() and linkType == "player" and db.altClickToInvite then
		local name = match(link, "player:([^:]+)")
		InviteUnit(name)
		return nil	
	elseif linkType == "guildinvite" then
		local name = sub(link, link:find(":") + 1)
		if not name or UnitIsInMyGuild(name) then return end
		local inGuild, _, _ = GetGuildInfo(name)
		if not inGuild then GuildInvite(name) end
		return nil
	elseif linkType == "groupinvite" then
		local name = sub(link, link:find(":") + 1)
		InviteUnit(name)
		return nil
	end
	return self.hooks.SetItemRef(link, text, button)
end

function Module:OnEnable()
	if not next(db.groupWords) then
		db.groupWords[L["invite"]]	= L["invite"]
		db.groupWords[L["inv"]]		= L["inv"]
	end
	
	if not next(db.guildWords) then
		db.guildWords[L["ginvite"]]	= L["ginvite"]
		db.guildWords[L["ginv"]]	= L["ginv"]
	end
	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%d", i)]
		if frame ~= COMBATLOG then
			self:RawHook(frame, "AddMessage", true)
		end
	end
	self:RawHook(nil, "SetItemRef", true)
	self:RawHook("ChatFrame_MessageEventHandler", true)
	self:BuildEvents()
end

function Module:OnDisable()
	self:UnhookAll()
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("InviteLinks", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Gives you more flexibility in how you invite people to your group and guild."]
end

function Module:GetOptions()
	if not options then
		options = {
			altClick = {
				type 	= "toggle",
				order	= 13,
				name 	= L["Alt-click name to invite"],
				width 	= "full",
				desc 	= L["Lets you alt-click player names to invite them to your party."],
				get		= function() return db.altClickToInvite end,
				set 	= function(_, value) db.altClickToInvite = value end
			},
			groupInvite = {
				type	= "group",
				order	= 98,
				inline	= true,
				name	= L["Group Invite Links"],
				args	= {
					addGroupWord = {
						type	= "input",
						order	= 1,
						name	= L["Add Group Trigger"],
						desc	= L["Add word to your group invite trigger list"],
						get		= function() end,
						set		= function(_, value) db.groupWords[value:lower()] = value end
					},
					removeGroupWord = {
						type 	= "select",
						order	= 2,
						name 	= L["Remove Group Trigger"],
						desc	= L["Remove a word from your group invite trigger list"],
						get 	= function() end,
						set 	= function(_, value) db.groupWords[value:lower()] = nil end,
						values 	= function() return db.groupWords end,
						confirm	= function() return (L["Really remove this word from your trigger list?"]) end
					}
				}
			},
			guildInvite = {
				type		= "group",
				order		= 99,
				inline		= true,
				name		= L["Guild Invite Links"],
				disabled	= function() return not CanGuildInvite() end,
				args		= {
					addGuildWord = {
						type	= "input",
						order	= 1,
						name	= L["Add Guild Trigger"],
						desc	= L["Add word to your guild invite trigger list."],
						get		= function() end,
						set		= function(_, value) db.guildWords[value:lower()] = value end
					},
					removeGuildWord = {
						type	= "select",
						order	= 2,
						name	= L["Remove Guild Trigger"],
						desc	= L["Remove a word from your guild invite trigget list."],
						get		= function() end,
						set		= function(_, value) db.guildWords[value:lower()] = nil end,
						values	= function() return db.guildWords end,
						confirm	= function() return (L["Really remove this word from your trigger list?"]) end
					}
				}
			},
			validEvents = {
				type	= "group",
				order	= 100,
				inline	= true,
				name	= L["Valid Events"],
				args	= {
					description		= {
						type	= "description",
						order	= 1,
						width	= "full",
						name	= L["Here you can select which channels this module will scan for the keygroupWords to trigger the invite."],
					},
					chatMsgSay		= {
						type	= "toggle",
						name	= L["Say"],
						desc	= L["Say Chat"],
						get		= function() return db.chatMsgSay end,
						set		= function(_, value) db.chatMsgSay = value; Module:BuildEvents() end,
					},
					chatMsgYell		= {
						type	= "toggle",
						name	= L["Yell"],
						desc	= L["Yell Chat"],
						get		= function() return db.chatMsgYell end,
						set		= function(_, value) db.chatMsgYell = value; Module:BuildEvents() end,			
					},
					chatMsgWhisper	= {
						type	= "toggle",
						name	= L["Whisper"],
						desc	= L["Whispers"],
						get		= function() return db.chatMsgWhisper end,
						set		= function(_, value) db.chatMsgWhisper = value; Module:BuildEvents() end,			
					},
					chatMsgOfficer	= {
						type	= "toggle",
						name	= L["Officer"],
						desc	= L["Officer Chat"],
						get		= function() return db.chatMsgOfficer end,
						set		= function(_, value) db.chatMsgOfficer = value; Module:BuildEvents() end,			
					},
					chatMsgGuild	= {
						type	= "toggle",
						name	= L["Guild"],
						desc	= L["Guild Chat"],
						get		= function() return db.chatMsgGuild end,
						set		= function(_, value) db.chatMsgGuild = value; Module:BuildEvents() end,			
					},
				}
			},
		}
	end
	return options
end
