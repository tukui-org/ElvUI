local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format

local GetWatchedFactionInfo = GetWatchedFactionInfo
local ToggleCharacter = ToggleCharacter

local NOT_APPLICABLE = NOT_APPLICABLE
local REPUTATION = REPUTATION
local STANDING = STANDING

local function OnEvent(self)
	local name, reaction, min, max, value = GetWatchedFactionInfo()
	if not name then
		return 	self.text:SetText(NOT_APPLICABLE)
	end

	local standingLabel
	local isCapped

	if reaction == _G.MAX_REPUTATION_REACTION then
		isCapped = true
	end

	local text = name
	local color = _G.FACTION_BAR_COLORS[reaction]
	local textFormat = E.global.datatexts.settings.Reputation.textFormat

	standingLabel = E:RGBToHex(color.r, color.g, color.b, nil, _G['FACTION_STANDING_LABEL'..reaction]..'|r')

	--Prevent a division by zero
	local maxMinDiff = max - min
	if maxMinDiff == 0 then
		maxMinDiff = 1
	end

	if isCapped then
		text = format('%s: [%s]', name, standingLabel)
	else
		if textFormat == 'PERCENT' then
			text = format('%s: %d%% [%s]', name, ((value - min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 'CURMAX' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue(max - min), standingLabel)
		elseif textFormat == 'CURPERC' then
			text = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), standingLabel)
		elseif textFormat == 'CUR' then
			text = format('%s: %s [%s]', name, E:ShortValue(value - min), standingLabel)
		elseif textFormat == 'REM' then
			text = format('%s: %s [%s]', name, E:ShortValue((max - min) - (value-min)), standingLabel)
		elseif textFormat == 'CURREM' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue((max - min) - (value-min)), standingLabel)
		elseif textFormat == 'CURPERCREM' then
			text = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), E:ShortValue((max - min) - (value-min)), standingLabel)
		end
	end

	self.text:SetText(text)
end

local function OnEnter()
	local name, reaction, min, max, value = GetWatchedFactionInfo()

	if name then
		DT.tooltip:ClearLines()
		DT.tooltip:AddLine(name)
		DT.tooltip:AddLine(' ')

		DT.tooltip:AddDoubleLine(STANDING..':', _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		if reaction ~= _G.MAX_REPUTATION_REACTION then
			DT.tooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
		end
		DT.tooltip:Show()
	end
end

local function OnClick()
	ToggleCharacter('ReputationFrame')
end

DT:RegisterDatatext('Reputation', nil, { 'UPDATE_FACTION', 'COMBAT_TEXT_UPDATE' }, OnEvent, nil, OnClick, OnEnter, nil, REPUTATION)
