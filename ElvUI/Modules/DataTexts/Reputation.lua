local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local GetFriendshipReputation = GetFriendshipReputation
local ToggleCharacter = ToggleCharacter
local GetWatchedFactionInfo = GetWatchedFactionInfo
local REPUTATION, STANDING = REPUTATION, STANDING

local function OnEvent(self)
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	if not name then return end

	local friendshipID = GetFriendshipReputation(factionID);
	local isFriend, friendText, standingLabel
	local isCapped

	if friendshipID then
		local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
		isFriend, reaction, friendText = true, 5, friendTextLevel
		if ( nextFriendThreshold ) then
			min, max, value = friendThreshold, nextFriendThreshold, friendRep;
		else
			isCapped = true;
		end
	elseif C_Reputation_IsFactionParagon(factionID) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if currentValue and threshold then
			min, max = 0, threshold
			value = currentValue % threshold
			if hasRewardPending then
				value = value + threshold
			end
		end
	else
		if reaction == _G.MAX_REPUTATION_REACTION then
			isCapped = true
		end
	end

	local color = _G.FACTION_BAR_COLORS[reaction]
	local text = ''
	local textFormat = E.DataBars.db.reputation.textFormat

	standingLabel = E:RGBToHex(color.r, color.g, color.b, nil, _G['FACTION_STANDING_LABEL'..reaction]..'|r')

	--Prevent a division by zero
	local maxMinDiff = max - min
	if (maxMinDiff == 0) then
		maxMinDiff = 1
	end

	if isCapped and textFormat ~= 'NONE' then
		-- show only name and standing on exalted
		text = format('%s: [%s]', name, isFriend and friendText or standingLabel)
	else
		if textFormat == 'PERCENT' then
			text = format('%s: %d%% [%s]', name, ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURMAX' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue(max - min), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURPERC' then
			text = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
		elseif textFormat == 'CUR' then
			text = format('%s: %s [%s]', name, E:ShortValue(value - min), isFriend and friendText or standingLabel)
		elseif textFormat == 'REM' then
			text = format('%s: %s [%s]', name, E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURREM' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURPERCREM' then
			text = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
		end
	end

	self.text:SetText(text)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	if factionID and C_Reputation_IsFactionParagon(factionID) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if currentValue and threshold then
			min, max = 0, threshold
			value = currentValue % threshold
			if hasRewardPending then
				value = value + threshold
			end
		end
	end

	if name then
		DT.tooltip:AddLine(name)
		DT.tooltip:AddLine(' ')

		local friendID, friendTextLevel, _
		if factionID then friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID) end

		DT.tooltip:AddDoubleLine(STANDING..':', (friendID and friendTextLevel) or _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		if reaction ~= _G.MAX_REPUTATION_REACTION or C_Reputation_IsFactionParagon(factionID) then
			DT.tooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
		end

		DT.tooltip:Show()
	end
end

local function OnClick()
	ToggleCharacter('ReputationFrame')
end

DT:RegisterDatatext('Reputation', nil, {'UPDATE_FACTION', 'COMBAT_TEXT_UPDATE'}, OnEvent, nil, OnClick, OnEnter, nil, REPUTATION)
