local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_FrameXML', 'GuildInviteFrame')
data.toggle = 'guild'

function S:GuildInviteFrame()
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
