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
	local topBackdrop = CreateFrame('Frame', nil, BattlefieldFrame)
	topBackdrop:CreateBackdrop('Transparent')
	topBackdrop:Height(130)
	topBackdrop:Width(330)
	topBackdrop:Point('TOP', BattlefieldFrame, 'TOP', -12, -38)
	BattlefieldFrame.TopBackdrop = topBackdrop

	-- Custom Backdrop 2
	local bottomBackdrop = CreateFrame('Frame', nil, BattlefieldFrame)
	bottomBackdrop:CreateBackdrop('Transparent')
	bottomBackdrop:Height(230)
	bottomBackdrop:Width(330)
	bottomBackdrop:Point('BOTTOM', BattlefieldFrame, 'BOTTOM', -12, 110)
	BattlefieldFrame.BottomBackdrop = bottomBackdrop

	S:HandleCloseButton(_G.BattlefieldFrameCloseButton)

	if _G.WintergraspTimer then
		_G.WintergraspTimer.texture:SetTexCoord(0.2, 0.8, 0.1, 0.4)
	end
end

S:AddCallback('SkinBattlefield')
