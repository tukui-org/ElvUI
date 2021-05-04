local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local GetFriendshipReputation = GetFriendshipReputation
local GetWatchedFactionInfo = GetWatchedFactionInfo
local ToggleCharacter = ToggleCharacter
local REPUTATION = REPUTATION
local STANDING = STANDING
local UNKNOWN = UNKNOWN

local function GetValues(curValue, minValue, maxValue)
	local maximum = maxValue - minValue
	local current, diff = curValue - minValue, maximum

	if diff == 0 then diff = 1 end -- prevent a division by zero

	if current == maximum then
		return 1, 1, 100, true
	else
		return current, maximum, current / diff * 100
	end
end

local function OnEvent(self)
	local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()
	if not name then return end

	local friendshipID, _, _, _, _, _, standingText, _, nextThreshold = GetFriendshipReputation(factionID)
	local displayString, textFormat, label, rewardPending = '', E.global.datatexts.settings.Reputation.textFormat

	if friendshipID then
		reaction, label = 5, standingText

		if not nextThreshold then
			minValue, maxValue, curValue = 0, 1, 1
		end
	elseif C_Reputation_IsFactionParagon(factionID) then
		local current, threshold
		current, threshold, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)

		if current and threshold then
			label, minValue, maxValue, curValue, reaction = L["Paragon"], 0, threshold, current % threshold, 8
		end
	end

	local color = _G.FACTION_BAR_COLORS[reaction]
	if not label then label = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN end

	label = E:RGBToHex(color.r, color.g, color.b, nil, label..'|r')

	local current, maximum, percent, capped = GetValues(curValue, minValue, maxValue)
	if capped and textFormat ~= 'NONE' then -- show only name and standing on exalted
		displayString = format('%s: [%s]', name, label)
	elseif textFormat == 'PERCENT' then
		displayString = format('%s: %d%% [%s]', name, percent, label)
	elseif textFormat == 'CURMAX' then
		displayString = format('%s: %s - %s [%s]', name, E:ShortValue(current), E:ShortValue(maximum), label)
	elseif textFormat == 'CURPERC' then
		displayString = format('%s: %s - %d%% [%s]', name, E:ShortValue(current), percent, label)
	elseif textFormat == 'CUR' then
		displayString = format('%s: %s [%s]', name, E:ShortValue(current), label)
	elseif textFormat == 'REM' then
		displayString = format('%s: %s [%s]', name, E:ShortValue(maximum - current), label)
	elseif textFormat == 'CURREM' then
		displayString = format('%s: %s - %s [%s]', name, E:ShortValue(current), E:ShortValue(maximum - current), label)
	elseif textFormat == 'CURPERCREM' then
		displayString = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(current), percent, E:ShortValue(maximum - current), label)
	end

	if rewardPending then
		displayString = format('|A:ParagonReputation_Bag:0:0:0:0|a %s', displayString)
	end

	self.text:SetText(displayString)
end

local function OnEnter()
	local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()
	if not name then return end

	local friendshipID, _, _, _, _, _, standingText, _, nextThreshold = GetFriendshipReputation(factionID)
	local label = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
	local isParagon = C_Reputation_IsFactionParagon(factionID)

	if friendshipID then
		label = standingText
		if not nextThreshold then
			minValue, maxValue, curValue = 0, 1, 1
		end
	elseif factionID and isParagon then
		local current, threshold = C_Reputation_GetFactionParagonInfo(factionID)
		if current and threshold then
			label, minValue, maxValue, curValue = L["Paragon"], 0, threshold, current % threshold
		end
	end

	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(name)
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(STANDING..':', label, 1, 1, 1)

	if reaction ~= _G.MAX_REPUTATION_REACTION or isParagon then
		local current, maximum, percent = GetValues(curValue, minValue, maxValue)
		DT.tooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', current, maximum, percent), 1, 1, 1)
	end

	DT.tooltip:Show()
end

local function OnClick()
	ToggleCharacter('ReputationFrame')
end

DT:RegisterDatatext('Reputation', nil, {'UPDATE_FACTION', 'COMBAT_TEXT_UPDATE'}, OnEvent, nil, OnClick, OnEnter, nil, REPUTATION)
