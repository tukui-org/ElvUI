-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module		= ElvUI_ChatTweaks:NewModule("Group Say Command", "AceHook-3.0", "AceConsole-3.0")
local L				= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name			= L["Group Say Command"]

-- module vars
local format = string.format

function Module:OnTextChanged(object)
	local text = object:GetText()
	if text:sub(1, 4) == "/gs " then
		object:SetText(self:GetGroup(true) .. text:sub(5))
		ChatEdit_ParseText(object, 0)
	end
	self.hooks[object].OnTextChanged(object)
end

function Module:GetGroup(slash)
	local isIn, kind = IsInInstance()
	if isIn and kind == "pvp" then
		return slash and "/bg " or "BATTLEGROUND"
	elseif GetNumRaidMembers() > 0 then
		return slash and "/ra " or "RAID"
	elseif GetNumPartyMembers() > 0 then
		return slash and "/p " or "PARTY"
	else
		return slash and "/s " or "SAY"
	end
end

function Module:OnEnable()
	for i = 1, 10 do
		self:HookScript(_G[format("ChatFrame%dEditBox", i)], "OnTextChanged")
	end
	
	if not self.slashRegistered then
		self:RegisterChatCommand("gs", "SendChatMessage")
		self.slashRegistered = true
	end
end

function Module:Info()
	return L["Provides a /gr slash command to let you speak in your group (raid, party, or battleground) automatically."]
end