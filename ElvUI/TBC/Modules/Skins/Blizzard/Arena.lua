local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:SkinArena()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.arena) then return end

	local ArenaFrame = _G.ArenaFrame
	ArenaFrame:StripTextures(true)
	ArenaFrame:CreateBackdrop('Transparent')
	ArenaFrame.backdrop:Point('TOPLEFT', 10, -12)
	ArenaFrame.backdrop:Point('BOTTOMRIGHT', -32, 73)

	S:HandleButton(_G.ArenaFrameCancelButton)
	S:HandleButton(_G.ArenaFrameJoinButton)
	S:HandleButton(_G.ArenaFrameGroupJoinButton)

	_G.ArenaFrameZoneDescription:SetTextColor(1, 1, 1)

	_G.ArenaFrameNameHeader:Point('TOPLEFT', _G.ArenaZone1, 'TOPLEFT', 8, 24)
	_G.ArenaFrameGroupJoinButton:Point('RIGHT', _G.ArenaFrameJoinButton, 'LEFT', -2, 0)

	S:HandleCloseButton(_G.ArenaFrameCloseButton)
end

S:AddCallback('SkinArena')
