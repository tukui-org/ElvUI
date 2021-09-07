local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:SkinBattlefield()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.battlefield) then return end

	local BattlefieldFrame = _G.BattlefieldFrame

	BattlefieldFrame:StripTextures(true)
	BattlefieldFrame:CreateBackdrop('Transparent')
	BattlefieldFrame.backdrop:Point('TOPLEFT', 10, -12)
	BattlefieldFrame.backdrop:Point('BOTTOMRIGHT', -32, 73)

	_G.BattlefieldListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.BattlefieldListScrollFrameScrollBar)

	_G.BattlefieldFrameZoneDescription:SetTextColor(1, 1, 1)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	_G.BattlefieldFrameGroupJoinButton:Point('RIGHT', _G.BattlefieldFrameJoinButton, 'LEFT', -2, 0)

	S:HandleCloseButton(_G.BattlefieldFrameCloseButton)
end

S:AddCallback('SkinBattlefield')
