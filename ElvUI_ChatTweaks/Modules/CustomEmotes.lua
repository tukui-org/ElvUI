-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Custom Emotes", "AceConsole-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Custom Emotes"]

local format	= string.format

local db, options
local defaults = {
	profile = {
		addCmd		= true,
		messages	= {}
	}
}

local pattern = "^([^/:].+):(.+)$"

local function RegisterEmotes()
	if not db.messages or #db.messages == 0 then return end
	for _, value in pairs(db.messages) do
		if value:match(pattern) then
			local command, text = value:match(pattern)
			Module:RegisterChatCommand(command, function()
				SendChatMessage(text, "EMOTE", nil)
			end)
		end
	end
end

local function UnregisterEmotes()
	if not db.messages or #db.messages == 0 then return end
	for _, value in pairs(db.messages) do
		if value:match(pattern) then
			local command, _ = value:match(pattern)
			Module:UnregisterChatCommand(command)
		end
	end
end

function Module:PopulateEmotes(array)
	db.messages = {}
	for _, value in pairs(array) do
		if value:match(pattern) then
			db.messages[#db.messages + 1] = value
		end
	end
	RegisterEmotes()
end

function Module:EmotesToString()
	local emotes = ""
	for i = 1, #db.messages do
		if db.messages[i]:match(pattern) then
			emotes = emotes .. db.messages[i] .. "\n"
		end
	end
	return emotes
end

function Module:AddCommand()
	Module:RegisterChatCommand("emotes", function()
		if #db.messages == 0 then
			ElvUI_ChatTweaks:Print(L["No custom emotes are currently being used."])
			return
		end
		local customEmote = "    |cff00ff00/%s|r - %s %s"
		ElvUI_ChatTweaks:Print(format(L["|cff00ff00%d|r Custom %s Being Used"], #db.messages, #db.messages == 1 and "Emote" or "Emotes"))
		for _, value in pairs(db.messages) do
			if value:match(pattern) then
				local cmd, text = value:match(pattern)
				print(format(customEmote, cmd, UnitName("player"), text))
			end
		end
	end)
end

function Module:OnEnable()
	RegisterEmotes()
	
	if db.addCmd then
		self:AddCommand()
	end
end

function Module:OnDisable()
	UnregisterEmotes()
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("CustomEmotes", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Add custom emotes.  Please remember that your character's name will always be the first word.\n\n|cff00ff00%t|r is your current target."]
end

function Module:GetOptions()
	if not options then
		options = {
			addCmd = {
				type		= "toggle",
				order		= 13,
				width		= "full",
				name		= L["Add |cff00ff00/emotes|r Command"],
				desc		= L["Add an |cff00ff00/emotes|r command to see what custom emotes you currently have running."],
				get			= function() return db.addCmd end,
				set			= function(_, value)
					db.addCmd = value
					if db.addCmd then
						Module:AddCommand()
					else
						Module:UnregisterChatCommand("emotes")
					end
				end
			},
			messages = {
				type		= "input",
				multiline	= true,
				width		= "full",
				name		= L["Custom Emotes"],
				desc		= L["Put each emote on a separate line.\nSeparate the command from the text with a colon (\":\")."],
				get			= function() return Module:EmotesToString() end,
				set			= function(_, value) Module:PopulateEmotes({strsplit("\n", value:trim())}) end,
			}
		}
	end
	return options
end