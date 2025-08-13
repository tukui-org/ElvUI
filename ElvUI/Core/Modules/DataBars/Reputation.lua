local E, L, V, P, G = unpack(ElvUI)
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local ipairs = ipairs
local huge = math.huge

local GameTooltip = GameTooltip
local ToggleCharacter = ToggleCharacter

local GetFriendshipReputation = GetFriendshipReputation or C_GossipInfo.GetFriendshipReputation
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local C_Reputation_IsMajorFaction = C_Reputation.IsMajorFaction
local C_MajorFactions_GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local C_MajorFactions_HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown

local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetQuestLogMajorFactionReputationRewards = C_QuestLog.GetQuestLogMajorFactionReputationRewards

local BLUE_FONT_COLOR = BLUE_FONT_COLOR
local RENOWN_LEVEL_LABEL = RENOWN_LEVEL_LABEL
local REPUTATION = REPUTATION
local STANDING = STANDING
local UNKNOWN = UNKNOWN

local QuestRep = 0

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

function DB:ReputationBar_Update()
	local bar = DB.StatusBars.Reputation
	DB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	local data = E:GetWatchedFactionInfo()
	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID
	local displayString, textFormat, standing, rewardPending, _ = '', DB.db.reputation.textFormat

	if reaction == 0 then
		reaction = 1
	end

	local info = not E.Classic and factionID and GetFriendshipReputation(factionID)
	if info and info.friendshipFactionID and info.friendshipFactionID > 0 then
		standing, currentReactionThreshold, nextReactionThreshold, currentStanding = info.reaction, info.reactionThreshold or 0, info.nextThreshold or huge, info.standing or 1
	end

	if E.Retail and not standing and factionID and C_Reputation_IsFactionParagon(factionID) then
		local current, threshold
		current, threshold, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)

		if current and threshold then
			standing, currentReactionThreshold, nextReactionThreshold, currentStanding, reaction = L["Paragon"], 0, threshold, current % threshold, 9
		end
	end

	if not standing and factionID and E.Retail and C_Reputation_IsMajorFaction(factionID) then
		local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
		local renownColor = DB.db.colors.factionColors[10]

		reaction, currentReactionThreshold, nextReactionThreshold = 10, 0, majorFactionData.renownLevelThreshold
		currentStanding = C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
		standing = E:RGBToHex(renownColor.r, renownColor.g, renownColor.b, nil, format(RENOWN_LEVEL_LABEL..'|r', majorFactionData.renownLevel))

		DB:ReputationBar_QuestRep(factionID)
	end

	if not standing then
		standing = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
	end

	local customColors = DB.db.colors.useCustomFactionColors
	local customReaction = reaction == 9 or reaction == 10 -- 9 is paragon, 10 is renown
	local color = (customColors or customReaction) and DB.db.colors.factionColors[reaction] or _G.FACTION_BAR_COLORS[reaction]
	local alpha = (customColors and color.a) or DB.db.colors.reputationAlpha
	local total = nextReactionThreshold == huge and 1 or nextReactionThreshold -- we need to correct the min/max of friendship factions to display the bar at 100%

	bar:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1, alpha or 1)
	bar:SetMinMaxValues((nextReactionThreshold == huge or currentReactionThreshold == nextReactionThreshold) and 0 or currentReactionThreshold, total) -- we force min to 0 because the min will match max when a rep is maxed and cause the bar to be 0%
	bar:SetValue(currentStanding)

	bar.Reward:ClearAllPoints()
	bar.Reward:SetPoint('CENTER', bar, DB.db.reputation.rewardPosition)
	bar.Reward:SetShown(rewardPending and DB.db.reputation.showReward)

	if name then
		local current, maximum, percent, capped = GetValues(currentStanding, currentReactionThreshold, total)
		if capped and textFormat ~= 'NONE' then -- show only name and standing on exalted
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

	bar.text:SetText(displayString)
end

function DB:ReputationBar_QuestRep(factionID)
	QuestRep = 0

	for i = 1, C_QuestLog_GetNumQuestLogEntries() do
		local info = C_QuestLog_GetInfo(i)
		if info then
			local qxp = C_QuestLog_GetQuestLogMajorFactionReputationRewards(info.questID)
			if qxp then
				for _, data in ipairs(qxp) do
					if factionID == data.factionID then
						QuestRep = QuestRep + data.rewardAmount
					end
				end
			end
		end
	end
end

function DB:ReputationBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local data = E:GetWatchedFactionInfo()
	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID

	local isParagon = E.Retail and factionID and C_Reputation_IsFactionParagon(factionID)
	local standing

	if isParagon then
		local current, threshold = C_Reputation_GetFactionParagonInfo(factionID)
		if current and threshold then
			standing, currentReactionThreshold, nextReactionThreshold, currentStanding = L["Paragon"], 0, threshold, current % threshold
		end
	end

	if name and not GameTooltip:IsForbidden() then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(' ')

		local info = not E.Classic and factionID and GetFriendshipReputation(factionID)
		if info and info.friendshipFactionID and info.friendshipFactionID > 0 then
			standing, currentReactionThreshold, nextReactionThreshold, currentStanding = info.reaction, info.reactionThreshold or 0, info.nextThreshold or huge, info.standing or 1
		end

		if not standing then
			standing = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
		end

		local isMajorFaction = factionID and E.Retail and C_Reputation_IsMajorFaction(factionID)
		if not isMajorFaction then
			GameTooltip:AddDoubleLine(STANDING..':', standing, 1, 1, 1)
		end

		if not isParagon and isMajorFaction then
			local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
			currentStanding = (C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold) or majorFactionData.renownReputationEarned or 0
			nextReactionThreshold = majorFactionData.renownLevelThreshold
			GameTooltip:AddDoubleLine(format(RENOWN_LEVEL_LABEL, majorFactionData.renownLevel), format('%d / %d (%d%%)', GetValues(currentStanding, 0, nextReactionThreshold)), BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, 1, 1, 1)

			local current, _, percent = GetValues(QuestRep, 0, nextReactionThreshold)
			GameTooltip:AddDoubleLine('Reputation from Quests', format('%d (%d%%)', current, percent), nil, nil, nil, 1, 1, 1)
		elseif (isParagon or (reaction ~= _G.MAX_REPUTATION_REACTION)) and nextReactionThreshold ~= huge then
			GameTooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', GetValues(currentStanding, currentReactionThreshold, nextReactionThreshold)), 1, 1, 1)
		end

		GameTooltip:Show()
	end
end

function DB:ReputationBar_OnClick()
	if E:AlertCombat() then return end

	ToggleCharacter('ReputationFrame')
end

function DB:ReputationBar_Toggle()
	local bar = DB.StatusBars.Reputation
	bar.db = DB.db.reputation

	if bar.db.enable then
		E:EnableMover(bar.holder.mover.name)

		DB:RegisterEvent('UPDATE_FACTION', 'ReputationBar_Update')
		DB:RegisterEvent('COMBAT_TEXT_UPDATE', 'ReputationBar_Update')
		DB:RegisterEvent('QUEST_FINISHED', 'ReputationBar_Update')

		if E.Retail then
			DB:RegisterEvent('MAJOR_FACTION_RENOWN_LEVEL_CHANGED', 'ReputationBar_Update')
			DB:RegisterEvent('MAJOR_FACTION_UNLOCKED', 'ReputationBar_Update')
		end

		DB:ReputationBar_Update()
	else
		E:DisableMover(bar.holder.mover.name)

		DB:UnregisterEvent('UPDATE_FACTION')
		DB:UnregisterEvent('COMBAT_TEXT_UPDATE')
		DB:UnregisterEvent('QUEST_FINISHED')

		if E.Retail then
			DB:UnregisterEvent('MAJOR_FACTION_RENOWN_LEVEL_CHANGED', 'ReputationBar_Update')
			DB:UnregisterEvent('MAJOR_FACTION_UNLOCKED', 'ReputationBar_Update')
		end
	end
end

function DB:ReputationBar()
	local Reputation = DB:CreateBar('ElvUI_ReputationBar', 'Reputation', DB.ReputationBar_Update, DB.ReputationBar_OnEnter, DB.ReputationBar_OnClick, {'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -264})
	DB:CreateBarBubbles(Reputation)

	Reputation.Reward = Reputation:CreateTexture()
	Reputation.Reward:SetAtlas('ParagonReputation_Bag')
	Reputation.Reward:Size(20)

	Reputation.ShouldHide = function()
		if DB.db.reputation.hideBelowMaxLevel and not E:XPIsLevelMax() then
			return true
		else
			local data = E:GetWatchedFactionInfo()
			return not (data and data.name)
		end
	end

	E:CreateMover(Reputation.holder, 'ReputationBarMover', L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')

	DB:ReputationBar_Toggle()
end
