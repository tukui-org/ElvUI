local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:WorldMapFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap) then return end

	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()
	WorldMapFrame.BorderFrame:CreateBackdrop('Transparent')

	S:HandleDropDownBox(_G.WorldMapZoneMinimapDropDown)
	S:HandleDropDownBox(_G.WorldMapContinentDropDown)
	S:HandleDropDownBox(_G.WorldMapZoneDropDown)

	_G.WorldMapContinentDropDown:Point('TOPLEFT', WorldMapFrame, 'TOPLEFT', 330, -35)
	_G.WorldMapContinentDropDown:Width(205)
	_G.WorldMapContinentDropDown:Height(33)

	_G.WorldMapZoneDropDown:Point('LEFT', _G.WorldMapContinentDropDown, 'RIGHT', -20, 0)
	_G.WorldMapZoneDropDown:Width(205)
	_G.WorldMapZoneDropDown:Height(33)

	_G.WorldMapZoneMinimapDropDown:Point('RIGHT', _G.WorldMapContinentDropDown, 'LEFT', 20, 0)
	_G.WorldMapZoneMinimapDropDown:Width(205)
	_G.WorldMapZoneMinimapDropDown:Height(33)

	_G.WorldMapZoomOutButton:Point('LEFT', _G.WorldMapZoneDropDown, 'RIGHT', 3, 3)
	_G.WorldMapZoomOutButton:Height(23)
	_G.WorldMapZoomOutButton:Width(100)
	_G.WorldMapZoomOutButton:SetFrameLevel(_G.WorldMapFrame.BlackoutFrame:GetFrameLevel() + 2)
	S:HandleButton(_G.WorldMapZoomOutButton)

	S:HandleCloseButton(_G.WorldMapFrameCloseButton, WorldMapFrame.backdrop)
	_G.WorldMapFrameCloseButton:SetFrameLevel(_G.WorldMapFrameCloseButton:GetFrameLevel() + 2)
end

S:AddCallback('WorldMapFrame')
