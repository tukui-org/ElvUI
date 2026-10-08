local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_FrameXML', 'GuildInviteFrame', nil, nil, nil, nil, 'guild')

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
