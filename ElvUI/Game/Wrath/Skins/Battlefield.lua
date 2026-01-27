local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:SkinBattlefield()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.battlefield) then return end

	S:HandleFrame(_G.BattlefieldFrame, true, nil, 11, -12, -32, 76)

	_G.BattlefieldFrameTypeScrollFrame:StripTextures()
	S:HandleScrollBar(_G.BattlefieldFrameTypeScrollFrameScrollBar)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	S:HandleCloseButton(_G.BattlefieldFrameCloseButton)
end

S:AddCallback('SkinBattlefield')
