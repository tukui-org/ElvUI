local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local huge = math.huge

local ToggleCharacter = ToggleCharacter
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local C_Reputation_IsMajorFaction = C_Reputation.IsMajorFaction
local C_MajorFactions_GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local C_MajorFactions_HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown
local GetFriendshipReputation = GetFriendshipReputation or C_GossipInfo.GetFriendshipReputation

local BLUE_FONT_COLOR = BLUE_FONT_COLOR
local NOT_APPLICABLE = NOT_APPLICABLE
local RENOWN_LEVEL_LABEL = RENOWN_LEVEL_LABEL
local REPUTATION = REPUTATION
local STANDING = STANDING
local UNKNOWN = UNKNOWN

local function GetValues(currentStanding, currentReactionThreshold, nextReactionThreshold)
	local current = currentStanding - currentReactionThreshold
	local maximum = nextReactionThreshold - currentReactionThreshold

	if maximum < 0 then
		maximum = current -- account for negative maximum
	end

	if current == maximum then
		return 1, 1, 100, true
	else
		local diff = (maximum ~= 0 and maximum) or 1 -- prevent a division by zero
		return current, maximum, current / diff * 100
	end
end

local function OnEvent(self)
	local data = E:GetWatchedFactionInfo()
	if not (data and data.name) then
		return 	self.text:SetText(NOT_APPLICABLE)
	end

	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID
	local displayString, textFormat, standing = '', E.global.datatexts.settings.Reputation.textFormat

	if reaction == 0 then
		reaction = 1
	end

	local info = not E.Classic and factionID and GetFriendshipReputation(factionID)
	if info and info.friendshipFactionID and info.friendshipFactionID > 0 then
		standing, currentReactionThreshold, nextReactionThreshold, currentStanding = info.reaction, info.reactionThreshold or 0, info.nextThreshold or huge, info.standing or 1
	end

	if E.Retail and not standing and factionID and C_Reputation_IsFactionParagon(factionID) then
		local current, threshold
		current, threshold = C_Reputation_GetFactionParagonInfo(factionID)

		if current and threshold then
			standing, currentReactionThreshold, nextReactionThreshold, currentStanding, reaction = L["Paragon"], 0, threshold, current % threshold, 9
		end
	end

	local color = _G.FACTION_BAR_COLORS[reaction]
	if not standing and factionID and E.Retail and C_Reputation_IsMajorFaction(factionID) then
		local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
		color = E.DataBars.db.colors.factionColors[10]

		currentReactionThreshold, nextReactionThreshold = 0, majorFactionData.renownLevelThreshold
		currentStanding = C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
		standing = E:RGBToHex(color.r, color.g, color.b, nil, format(RENOWN_LEVEL_LABEL..'|r', majorFactionData.renownLevel))
	end

	if not standing then
		local standingLabel = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
		standing = E:RGBToHex(color.r, color.g, color.b, nil, standingLabel..'|r')
	end

	if name then
		local total = nextReactionThreshold == huge and 1 or nextReactionThreshold -- we need to correct the min/max of friendship factions to display the bar at 100%
		local current, maximum, percent, capped = GetValues(currentStanding, currentReactionThreshold, total)
		if capped then -- show only name and standing on exalted
			displayString = format('%s: [%s]', name, standing)
		elseif textFormat == 'PERCENT' then
			displayString = format('%s: %d%% [%s]', name, percent, standing)
		elseif textFormat == 'CURMAX' then
			displayString = format('%s: %s / %s [%s]', name, E:ShortValue(current), E:ShortValue(maximum), standing)
		elseif textFormat == 'CURPERC' then
			displayString = format('%s: %s / %d%% [%s]', name, E:ShortValue(current), percent, standing)
		elseif textFormat == 'CUR' then
			displayString = format('%s: %s [%s]', name, E:ShortValue(current), standing)
		elseif textFormat == 'REM' then
			displayString = format('%s: %s [%s]', name, E:ShortValue(maximum - current), standing)
		elseif textFormat == 'CURREM' then
			displayString = format('%s: %s / %s [%s]', name, E:ShortValue(current), E:ShortValue(maximum - current), standing)
		elseif textFormat == 'CURPERCREM' then
			displayString = format('%s: %s / %d%% (%s) [%s]', name, E:ShortValue(current), percent, E:ShortValue(maximum - current), standing)
		end
	end

	self.text:SetText(displayString)
end

local function OnEnter()
	local data = E:GetWatchedFactionInfo()
	if not data then return end
	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID

	local isParagon = E.Retail and factionID and C_Reputation_IsFactionParagon(factionID)
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

		local info = not E.Classic and factionID and GetFriendshipReputation(factionID)
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
			DT.tooltip:AddDoubleLine(format(RENOWN_LEVEL_LABEL, majorFactionData.renownLevel), format('%d / %d (%d%%)', GetValues(currentStanding, 0, nextReactionThreshold)), BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, 1, 1, 1)
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
