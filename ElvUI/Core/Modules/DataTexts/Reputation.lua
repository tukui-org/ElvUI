local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format

local ToggleCharacter = ToggleCharacter

local GetFriendshipReputation = GetFriendshipReputation or C_GossipInfo.GetFriendshipReputation
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local C_Reputation_IsMajorFaction = C_Reputation.IsMajorFaction
local C_MajorFactions_GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local C_MajorFactions_HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown

local BLUE_FONT_COLOR = BLUE_FONT_COLOR
local NOT_APPLICABLE = NOT_APPLICABLE
local RENOWN_LEVEL_LABEL = RENOWN_LEVEL_LABEL
local REPUTATION = REPUTATION
local STANDING = STANDING
local UNKNOWN = UNKNOWN

local function OnEvent(self)
	local data = E:GetWatchedFactionInfo()
	if not (data and data.name) then
		return 	self.text:SetText(NOT_APPLICABLE)
	end

	local standingLabel, isCapped
	local name, reaction, min, max, value = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding
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

local function GetValues(currentStanding, currentReactionThreshold, nextReactionThreshold)
	local maximum = nextReactionThreshold - currentReactionThreshold
	local current, diff = currentStanding - currentReactionThreshold, maximum

	if diff == 0 then diff = 1 end -- prevent a division by zero

	if current == maximum then
		return 1, 1, 100, true
	else
		return current, maximum, current / diff * 100
	end
end

local function OnEnter()
	local data = E:GetWatchedFactionInfo()
	if not data then return end
	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID

	local isParagon = factionID and C_Reputation_IsFactionParagon(factionID)
	local standing

	if isParagon then
		local current, threshold = C_Reputation_GetFactionParagonInfo(factionID)
		if current and threshold then
			standing, currentReactionThreshold, nextReactionThreshold, currentStanding = L["Paragon"], 0, threshold, current % threshold
		end
	end

	if name then
		DT.tooltip:ClearLines()
		DT.tooltip:AddLine(name)
		DT.tooltip:AddLine(' ')

		local info = E.Retail and factionID and GetFriendshipReputation(factionID)
		if info and info.friendshipFactionID and info.friendshipFactionID > 0 then
			standing, currentReactionThreshold, nextReactionThreshold, currentStanding = info.reaction, info.reactionThreshold or 0, info.nextThreshold or huge, info.standing or 1
		end

		if not standing then
			standing = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
		end

		local isMajorFaction = factionID and E.Retail and C_Reputation_IsMajorFaction(factionID)
		if not isMajorFaction then
			DT.tooltip:AddDoubleLine(STANDING..':', standing, 1, 1, 1)
		end

		if not isParagon and isMajorFaction then
			local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
			currentStanding = (C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold) or majorFactionData.renownReputationEarned or 0
			nextReactionThreshold = majorFactionData.renownLevelThreshold
			DT.tooltip:AddDoubleLine(RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel, format('%d / %d (%d%%)', GetValues(currentStanding, 0, nextReactionThreshold)), BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, 1, 1, 1)
		elseif (isParagon or (reaction ~= _G.MAX_REPUTATION_REACTION)) and nextReactionThreshold ~= huge then
			DT.tooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', GetValues(currentStanding, currentReactionThreshold, nextReactionThreshold)), 1, 1, 1)
		end

		DT.tooltip:Show()
	end
end

local function OnClick()
	ToggleCharacter('ReputationFrame')
end

DT:RegisterDatatext('Reputation', nil, { 'UPDATE_FACTION', 'COMBAT_TEXT_UPDATE' }, OnEvent, nil, OnClick, OnEnter, nil, REPUTATION)
