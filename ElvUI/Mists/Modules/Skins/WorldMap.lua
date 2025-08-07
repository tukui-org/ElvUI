local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:WorldMapFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap) then return end

	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()

	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrame.BorderFrame:CreateBackdrop('Transparent')
	WorldMapFrame.BorderFrame.backdrop:Point('TOPLEFT', 0, -0.5)

	WorldMapFrame.MiniBorderFrame:StripTextures()
	WorldMapFrame.MiniBorderFrame:CreateBackdrop('Transparent')
	WorldMapFrame.MiniBorderFrame.backdrop:Point('TOPLEFT', 6, -2)

	S:HandleDropDownBox(_G.WorldMapZoneMinimapDropdown, 160)
	S:HandleDropDownBox(_G.WorldMapContinentDropdown, 160)
	S:HandleDropDownBox(_G.WorldMapZoneDropdown, 160)
	S:HandleDropDownBox(_G.WorldMapFrame.WorldMapLevelDropDown, 160)
	S:HandleDropDownBox(_G.WorldMapFrame.WorldMapOptionsDropDown, 160)

	S:HandleCheckBox(_G.WorldMapTrackQuest)

	_G.WorldMapContinentDropdown:Point('TOPLEFT', WorldMapFrame, 'TOPLEFT', 330, -35)
	_G.WorldMapContinentDropdown:Height(26)

	_G.WorldMapZoneDropdown:Point('LEFT', _G.WorldMapContinentDropdown, 'RIGHT', 10, 0)
	_G.WorldMapZoneDropdown:Height(26)

	_G.WorldMapZoneMinimapDropdown:Point('RIGHT', _G.WorldMapContinentDropdown, 'LEFT', -10, 0)
	_G.WorldMapZoneMinimapDropdown:Height(26)

	_G.WorldMapZoomOutButton:Point('LEFT', _G.WorldMapZoneDropdown, 'RIGHT', 10, 1)
	_G.WorldMapZoomOutButton:Height(23)
	_G.WorldMapZoomOutButton:Width(100)
	_G.WorldMapZoomOutButton:OffsetFrameLevel(2, _G.WorldMapFrame.BlackoutFrame)

	S:HandleButton(_G.WorldMapZoomOutButton)
	S:HandleSliderFrame(_G.OpacityFrameSlider)
	S:HandleScrollBar(_G.QuestMapDetailsScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestScrollFrame.ScrollBar)

	if E.OtherAddons.Questie and _G.Questie_Toggle then
		S:HandleButton(_G.Questie_Toggle)
	end

	S:HandleMaxMinFrame(WorldMapFrame.MaxMinButtonFrame)
	S:HandleCloseButton(_G.WorldMapFrameCloseButton, WorldMapFrame.backdrop)
	_G.WorldMapFrameCloseButton:OffsetFrameLevel(2)
end

S:AddCallback('WorldMapFrame')
