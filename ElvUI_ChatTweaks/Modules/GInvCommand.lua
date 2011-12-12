-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("GInvite Alternate Command", "AceConsole-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["GInvite Alternate Command"]

function Module:OnEnable()
	if CanGuildInvite() then
		self:RegisterChatCommand("ginv", function(args)
			local invite = self:GetArgs(args)
			if not invite then
				print(L["|cffffff00Usage: /ginvite <name>|r"])
			elseif UnitIsInMyGuild(invite) then
				print(L["|cffffff00Character already in your guild."])
			else
				local inGuild, _, _ = GetGuildInfo(invite)
				if inGuild then
					print(L["|cffffff00Character already in a guild."])
				else
					GuildInvite(invite)
				end
			end
		end)
	end
end

function Module:OnDisable()
	self:UnregisterCommand("ginv")
end

function Module:Info()
	return L["Provides |cff00ff00/ginv|r, an alternative to |cff00ff00/ginvite|r command, for us lazy folks."]
end