local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:SkinBattlefield()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.battlefield) then return end

	-- Main Frame
	local BattlefieldFrame = _G.BattlefieldFrame
	BattlefieldFrame:StripTextures(true)
	BattlefieldFrame:CreateBackdrop('Transparent')
	BattlefieldFrame.backdrop:Point('TOPLEFT', 10, -12)
	BattlefieldFrame.backdrop:Point('BOTTOMRIGHT', -32, 73)

	_G.BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)
	_G.BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	_G.BattlefieldFrameGroupJoinButton:Point('RIGHT', _G.BattlefieldFrameJoinButton, 'LEFT', -2, 0)

	-- Custom Backdrop
	BottomBackdrop = CreateFrame('Frame', nil, BattlefieldFrame)
	BottomBackdrop:CreateBackdrop('Transparent')
	BottomBackdrop:Height(210)
	BottomBackdrop:Width(330)
	BottomBackdrop:Point('BOTTOM', BattlefieldFrame, 'BOTTOM', -12, 120)

	S:HandleCloseButton(_G.BattlefieldFrameCloseButton)
end

S:AddCallback('SkinBattlefield')
