local E, L, V, P, G = unpack(ElvUI)
local DB = E:GetModule('DataBars')
local ElvUF = E.oUF

local _G = _G
local format = format
local ipairs = ipairs
local huge = math.huge

local GameTooltip = GameTooltip
local ToggleCharacter = ToggleCharacter

-- API
local GetFriendshipReputation = GetFriendshipReputation or C_GossipInfo.GetFriendshipReputation
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagonForCurrentPlayer = C_Reputation.IsFactionParagonForCurrentPlayer
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

-- Cache
local QuestRep = 0

-- =====================================================
-- UTIL
-- =====================================================

local function GetValues(current, min, max)
	local cur = current - min
	local maximum = max - min

	if maximum <= 0 then
		maximum = cur
	end

	if cur >= maximum then
		return maximum, maximum, 100, true
	end

	local diff = maximum ~= 0 and maximum or 1
	return cur, maximum, (cur / diff) * 100
end

-- =====================================================
-- QUEST REP (cached + safe)
-- =====================================================

function DB:ReputationBar_UpdateQuestRep(factionID)
	QuestRep = 0

	if not factionID then return end

	for i = 1, C_QuestLog_GetNumQuestLogEntries() do
		local info = C_QuestLog_GetInfo(i)
		if info and info.questID then
			local rewards = C_QuestLog_GetQuestLogMajorFactionReputationRewards(info.questID)

			if rewards and type(rewards) == "table" then
				for _, data in ipairs(rewards) do
					if data and data.factionID == factionID then
						QuestRep = QuestRep + (data.rewardAmount or 0)
					end
				end
			end
		end
	end
end

-- =====================================================
-- UPDATE
-- =====================================================

function DB:ReputationBar_Update()
	local bar = DB.StatusBars.Reputation
	DB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	local data = E:GetWatchedFactionInfo()
	if not data or not data.name then return end

	local name = data.name
	local reaction = data.reaction or 1
	local currentReactionThreshold = data.currentReactionThreshold or 0
	local nextReactionThreshold = data.nextReactionThreshold or 1
	local currentStanding = data.currentStanding or 0
	local factionID = data.factionID

	local standing, rewardPending
	local textFormat = DB.db.reputation.textFormat
	local displayString = ''

	-- FRIENDSHIP
	local info = not E.Classic and factionID and GetFriendshipReputation(factionID)
	if info and info.friendshipFactionID and info.friendshipFactionID > 0 then
		standing = info.reaction
		currentReactionThreshold = info.reactionThreshold or 0
		nextReactionThreshold = info.nextThreshold or huge
		currentStanding = info.standing or 1
	end

	-- PARAGON
	if not standing and factionID and E.Retail and C_Reputation_IsFactionParagonForCurrentPlayer(factionID) then
		local current, threshold, _, pending = C_Reputation_GetFactionParagonInfo(factionID)

		if current and threshold then
			standing = L["Paragon"]
			currentReactionThreshold = 0
			nextReactionThreshold = threshold
			currentStanding = current % threshold
			reaction = 9
			rewardPending = pending
		end
	end

	-- MAJOR FACTION (RENOWN)
	if not standing and factionID and E.Retail and C_Reputation_IsMajorFaction(factionID) then
		local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
		if not majorFactionData then return end

		local renownColor = DB.db.colors.factionColors[10]

		reaction = 10
		currentReactionThreshold = 0
		nextReactionThreshold = majorFactionData.renownLevelThreshold or 1
		currentStanding = majorFactionData.renownReputationEarned or 0

		standing = E:RGBToHex(
			renownColor.r, renownColor.g, renownColor.b,
			nil,
			format(RENOWN_LEVEL_LABEL..'|r', majorFactionData.renownLevel or 0)
		)

		DB:ReputationBar_UpdateQuestRep(factionID)
	end

	-- NORMAL
	if not standing then
		standing = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
	end

	-- BAR COLOR
	local customColors = DB.db.colors.useCustomFactionColors
	local customReaction = reaction == 9 or reaction == 10
	local color = (customColors or customReaction) and DB.db.colors.factionColors[reaction] or ElvUF.colors.reaction[reaction]
	local alpha = (customColors and color.a) or DB.db.colors.reputationAlpha

	local total = nextReactionThreshold == huge and 1 or nextReactionThreshold

	bar:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1, alpha or 1)
	bar:SetMinMaxValues(
		(nextReactionThreshold == huge or currentReactionThreshold == nextReactionThreshold) and 0 or currentReactionThreshold,
		total
	)
	bar:SetValue(currentStanding)

	-- PARAGON ICON
	bar.Reward:ClearAllPoints()
	bar.Reward:SetPoint('CENTER', bar, DB.db.reputation.rewardPosition)
	bar.Reward:SetShown((rewardPending or QuestRep > 0) and DB.db.reputation.showReward)

	-- TEXT
	local cur, max, perc, capped = GetValues(currentStanding, currentReactionThreshold, total)

	if capped and textFormat ~= 'NONE' then
		displayString = format('%s: [%s]', name, standing)
	elseif textFormat == 'PERCENT' then
		displayString = format('%s: %d%% [%s]', name, perc, standing)
	elseif textFormat == 'CURMAX' then
		displayString = format('%s: %s / %s [%s]', name, E:ShortValue(cur), E:ShortValue(max), standing)
	elseif textFormat == 'CURPERC' then
		displayString = format('%s: %s / %d%% [%s]', name, E:ShortValue(cur), perc, standing)
	elseif textFormat == 'CUR' then
		displayString = format('%s: %s [%s]', name, E:ShortValue(cur), standing)
	elseif textFormat == 'REM' then
		displayString = format('%s: %s [%s]', name, E:ShortValue(max - cur), standing)
	elseif textFormat == 'CURREM' then
		displayString = format('%s: %s / %s [%s]', name, E:ShortValue(cur), E:ShortValue(max - cur), standing)
	elseif textFormat == 'CURPERCREM' then
		displayString = format('%s: %s / %d%% (%s) [%s]', name, E:ShortValue(cur), perc, E:ShortValue(max - cur), standing)
	end

	-- Append QuestRep (Renown preview)
	if QuestRep > 0 and reaction == 10 then
		displayString = displayString .. format(' (+%s)', E:ShortValue(QuestRep))
	end

	bar.text:SetText(displayString)
end

-- =====================================================
-- TOOLTIP
-- =====================================================

function DB:ReputationBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	local data = E:GetWatchedFactionInfo()
	if not data or not data.name then return end

	local name = data.name
	local reaction = data.reaction
	local currentReactionThreshold = data.currentReactionThreshold
	local nextReactionThreshold = data.nextReactionThreshold
	local currentStanding = data.currentStanding
	local factionID = data.factionID

	if GameTooltip:IsForbidden() then return end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
	GameTooltip:AddLine(name)
	GameTooltip:AddLine(' ')

	local standing = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN

	local isMajorFaction = factionID and E.Retail and C_Reputation_IsMajorFaction(factionID)

	if not isMajorFaction then
		GameTooltip:AddDoubleLine(STANDING..':', standing, 1, 1, 1)
	end

	if isMajorFaction then
		local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
		if not majorFactionData then return end

		currentStanding = majorFactionData.renownReputationEarned or 0
		nextReactionThreshold = majorFactionData.renownLevelThreshold or 1

		local cur, max, perc = GetValues(currentStanding, 0, nextReactionThreshold)

		GameTooltip:AddDoubleLine(
			format(RENOWN_LEVEL_LABEL, majorFactionData.renownLevel or 0),
			format('%d / %d (%d%%)', cur, max, perc),
			BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, 1, 1, 1
		)

		local qcur, _, qperc = GetValues(QuestRep, 0, nextReactionThreshold)

		GameTooltip:AddDoubleLine(
			'Reputation from Quests',
			format('%d (%d%%)', qcur, qperc),
			1, 1, 1, 1, 1, 1
		)
	else
		if nextReactionThreshold ~= huge then
			local cur, max, perc = GetValues(currentStanding, currentReactionThreshold, nextReactionThreshold)

			GameTooltip:AddDoubleLine(
				REPUTATION..':',
				format('%d / %d (%d%%)', cur, max, perc),
				1, 1, 1
			)
		end
	end

	GameTooltip:Show()
end

-- =====================================================
-- CLICK
-- =====================================================

function DB:ReputationBar_OnClick()
	if E:AlertCombat() then return end
	ToggleCharacter('ReputationFrame')
end

-- =====================================================
-- TOGGLE / EVENTS (12.0.7 SAFE)
-- =====================================================

function DB:ReputationBar_Toggle()
	local bar = DB.StatusBars.Reputation
	bar.db = DB.db.reputation

	if bar.db.enable then
		E:EnableMover(bar.holder.mover.name)

		DB:RegisterEvent('UPDATE_FACTION', 'ReputationBar_Update')
		DB:RegisterEvent('COMBAT_TEXT_UPDATE', 'ReputationBar_Update')

		-- QUEST EVENTS (FIXED)
		DB:RegisterEvent('QUEST_LOG_UPDATE', 'ReputationBar_Update')
		DB:RegisterEvent('QUEST_ACCEPTED', 'ReputationBar_Update')
		DB:RegisterEvent('QUEST_REMOVED', 'ReputationBar_Update')
		DB:RegisterEvent('QUEST_FINISHED', 'ReputationBar_Update')

		if E.Retail then
			DB:RegisterEvent('MAJOR_FACTION_RENOWN_LEVEL_CHANGED', 'ReputationBar_Update')
			DB:RegisterEvent('MAJOR_FACTION_UNLOCKED', 'ReputationBar_Update')
			DB:RegisterEvent('MAJOR_FACTION_RENOWN_CATCH_UP_STATE_UPDATE', 'ReputationBar_Update')
		end

		DB:ReputationBar_Update()
	else
		E:DisableMover(bar.holder.mover.name)

		DB:UnregisterAllEvents()
	end
end

-- =====================================================
-- INIT
-- =====================================================

function DB:ReputationBar()
	local Reputation = DB:CreateBar(
		'ElvUI_ReputationBar',
		'Reputation',
		DB.ReputationBar_Update,
		DB.ReputationBar_OnEnter,
		DB.ReputationBar_OnClick,
		{'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -264}
	)

	DB:CreateBarBubbles(Reputation)

	Reputation.Reward = Reputation:CreateTexture()
	Reputation.Reward:SetAtlas('ParagonReputation_Bag')
	Reputation.Reward:Size(20)

	Reputation.ShouldHide = function()
		if DB.db.reputation.hideBelowMaxLevel and not E:XPIsLevelMax() then
			return true
		end

		local data = E:GetWatchedFactionInfo()
		return not (data and data.name)
	end

	E:CreateMover(Reputation.holder, 'ReputationBarMover', L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')

	DB:ReputationBar_Toggle()
end
