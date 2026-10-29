local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'SkinBattlefield', nil, nil, nil, nil, 'battlefield')

function S:SkinBattlefield()
	S:HandleFrame(_G.BattlefieldFrame, true, nil, 11, -12, -32, 76)

	if E.Wrath then
		_G.BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)
		_G.BattlefieldFrameBGTex:CreateBackdrop('Transparent')
		_G.BattlefieldFrameBGTex:SetAlpha(0)
	else
		_G.BattlefieldFrameZoneDescription:SetTextColor(1, 1, 1)
	end

	local scrollFrame = E.Wrath and _G.BattlefieldFrameTypeScrollFrame or _G.BattlefieldListScrollFrame
	scrollFrame:StripTextures()
	S:HandleScrollBar(scrollFrame.ScrollBar)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	if E.Wrath then
		_G.BattlefieldFrameCloseButton:Point('TOPRIGHT', -30, -8) -- matches PVPParentFrameCloseButton
	end
end
