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
	S:HandleCloseButton(_G.ArenaFrameCloseButton)

	_G.ArenaFrameZoneDescription:SetTextColor(1, 1, 1)
	_G.ArenaFrameNameHeader:Point('TOPLEFT', _G.ArenaZone1, 'TOPLEFT', 8, 24)
	_G.ArenaFrameGroupJoinButton:Point('RIGHT', _G.ArenaFrameJoinButton, 'LEFT', -2, 0)

	-- Custom Backdrop 1
	if not ArenaFrame.TopBackdrop then
		local topBackdrop = CreateFrame('Frame', nil, ArenaFrame)
		topBackdrop:SetTemplate('Transparent')
		topBackdrop:Height(112)
		topBackdrop:Width(330)
		topBackdrop:Point('TOP', ArenaFrame, 'TOP', -12, -48)
		topBackdrop:OffsetFrameLevel(nil, ArenaFrame.backdrop)

		ArenaFrame.TopBackdrop = topBackdrop
	end

	-- Custom Backdrop 2
	if not ArenaFrame.BottomBackdrop then
		local bottomBackdrop = CreateFrame('Frame', nil, ArenaFrame)
		bottomBackdrop:SetTemplate('Transparent')
		bottomBackdrop:Height(240)
		bottomBackdrop:Width(330)
		bottomBackdrop:Point('BOTTOM', ArenaFrame, 'BOTTOM', -12, 108)
		bottomBackdrop:OffsetFrameLevel(nil, ArenaFrame.backdrop)

		ArenaFrame.BottomBackdrop = bottomBackdrop
	end
end

S:AddCallback('SkinArena')
