local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin

local NOT_APPLICABLE = NOT_APPLICABLE

local displayString = ''
local inRestrictedArea = false
local mapInfo = E.MapInfo

local function Update(panel, elapsed)
	if inRestrictedArea or not mapInfo.coordsWatching then return end

	panel.timeSinceUpdate = (panel.timeSinceUpdate or 0) + elapsed

	if panel.timeSinceUpdate > 0.1 then
		panel.text:SetFormattedText(displayString, mapInfo.xText or 0, mapInfo.yText or 0)
		panel.timeSinceUpdate = 0
	end
end

local function OnEvent(panel)
	if mapInfo.x and mapInfo.y then
		inRestrictedArea = false
		panel.text:SetFormattedText(displayString, mapInfo.xText or 0, mapInfo.yText or 0)
	else
		inRestrictedArea = true
		panel.text:SetText(NOT_APPLICABLE)
	end
end

local function Click()
	if not E:AlertCombat() then
		_G.ToggleFrame(_G.WorldMapFrame)
	end
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%.2f ', hex, '|||r %.2f')
end

DT:RegisterDatatext('Coords', nil, {'LOADING_SCREEN_DISABLED', 'ZONE_CHANGED', 'ZONE_CHANGED_INDOORS', 'ZONE_CHANGED_NEW_AREA'}, OnEvent, Update, Click, nil, nil, L["Coords"], mapInfo, ApplySettings)
