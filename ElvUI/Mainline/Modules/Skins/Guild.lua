local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:GuildInviteFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guild) then return end

	local GuildInviteFrame = _G.GuildInviteFrame
	GuildInviteFrame:StripTextures()
	GuildInviteFrame:SetTemplate('Transparent')
	GuildInviteFrame.Points:ClearAllPoints()
	GuildInviteFrame.Points:Point('TOP', GuildInviteFrame, 'CENTER', 15, -25)

	S:HandleButton(_G.GuildInviteFrameJoinButton)
	S:HandleButton(_G.GuildInviteFrameDeclineButton)

	GuildInviteFrame:Height(225)
	GuildInviteFrame:HookScript('OnEvent', function()
		GuildInviteFrame:Height(225)
	end)

	_G.GuildInviteFrameWarningText:Kill()
end

S:AddCallback('GuildInviteFrame')
