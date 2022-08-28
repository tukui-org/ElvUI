local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame

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

	local backdrop_level = ArenaFrame.backdrop:GetFrameLevel()

	-- Custom Backdrop 1
	local topBackdrop = CreateFrame('Frame', nil, ArenaFrame)
	topBackdrop:SetTemplate('Transparent')
	topBackdrop:Height(112)
	topBackdrop:Width(330)
	topBackdrop:Point('TOP', ArenaFrame, 'TOP', -12, -48)
	topBackdrop:SetFrameLevel(backdrop_level)
	ArenaFrame.TopBackdrop = topBackdrop

	-- Custom Backdrop 2
	local bottomBackdrop = CreateFrame('Frame', nil, ArenaFrame)
	bottomBackdrop:SetTemplate('Transparent')
	bottomBackdrop:Height(240)
	bottomBackdrop:Width(330)
	bottomBackdrop:Point('BOTTOM', ArenaFrame, 'BOTTOM', -12, 108)
	bottomBackdrop:SetFrameLevel(backdrop_level)
	ArenaFrame.BottomBackdrop = bottomBackdrop

	S:HandleCloseButton(_G.ArenaFrameCloseButton)
end

S:AddCallback('SkinArena')
