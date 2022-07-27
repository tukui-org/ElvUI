local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:SkinBattlefield()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.battlefield) then return end

	-- Main Frame
	local BattlefieldFrame = _G.BattlefieldFrame
	BattlefieldFrame:StripTextures(true)
	BattlefieldFrame:CreateBackdrop('Transparent')
	BattlefieldFrame.backdrop:Point('TOPLEFT', 9, -12)
	BattlefieldFrame.backdrop:Point('BOTTOMRIGHT', -32, 75)

	_G.BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)
	_G.BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	_G.BattlefieldFrameGroupJoinButton:Point('RIGHT', _G.BattlefieldFrameJoinButton, 'LEFT', -2, 0)

	-- TODO: Wrath (Wintergrasp Queue Button)
	-- local WintergraspTimer = _G.WintergraspTimer

	-- Custom Backdrop 1
	BattlefieldTopBackdrop = CreateFrame('Frame', nil, BattlefieldFrame)
	BattlefieldTopBackdrop:CreateBackdrop('Transparent')
	BattlefieldTopBackdrop:Height(130)
	BattlefieldTopBackdrop:Width(330)
	BattlefieldTopBackdrop:Point('TOP', BattlefieldFrame, 'TOP', -12, -38)

	-- Custom Backdrop 2
	BattlefieldBottomBackdrop = CreateFrame('Frame', nil, BattlefieldFrame)
	BattlefieldBottomBackdrop:CreateBackdrop('Transparent')
	BattlefieldBottomBackdrop:Height(230)
	BattlefieldBottomBackdrop:Width(330)
	BattlefieldBottomBackdrop:Point('BOTTOM', BattlefieldFrame, 'BOTTOM', -12, 110)

	S:HandleCloseButton(_G.BattlefieldFrameCloseButton)
end

S:AddCallback('SkinBattlefield')
