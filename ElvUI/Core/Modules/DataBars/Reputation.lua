local E, L, V, P, G = unpack(ElvUI)
local DB = E:GetModule('DataBars')

local _G = _G
local format = format
local ipairs = ipairs

local GameTooltip = GameTooltip
local GetWatchedFactionInfo = GetWatchedFactionInfo
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

function DB:ReputationBar_Update()
	local bar = DB.StatusBars.Reputation
	DB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	local displayString, textFormat, label, rewardPending, _ = '', DB.db.reputation.textFormat
	local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()

	local info = E.Retail and factionID and GetFriendshipReputation(factionID)
	if info and info.friendshipFactionID then
		local isMajorFaction = factionID and C_Reputation_IsMajorFaction(factionID)

		if info and info.friendshipFactionID > 0 then
			label, minValue, maxValue, curValue = info.reaction, info.reactionThreshold or 0, info.nextThreshold or 1, info.standing or 1
		elseif isMajorFaction then
			local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
			local renownColor = DB.db.colors.factionColors[10]
			local renownHex = E:RGBToHex(renownColor.r, renownColor.g, renownColor.b)

			reaction, minValue, maxValue = 10, 0, majorFactionData.renownLevelThreshold
			curValue = C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
			label = format('%s%s %s|r', renownHex, RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)

			DB:ReputationBar_QuestRep(factionID)
		end
	end

	if not label and C_Reputation_IsFactionParagon(factionID) then
		local current, threshold
		current, threshold, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)

		if current and threshold then
			label, minValue, maxValue, curValue, reaction = L["Paragon"], 0, threshold, current % threshold, 9
		end
	end

	if not label then
		label = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
	end

	local customColors = DB.db.colors.useCustomFactionColors
	local customReaction = reaction == 9 or reaction == 10 -- 9 is paragon, 10 is renown
	local color = (customColors or customReaction) and DB.db.colors.factionColors[reaction] or _G.FACTION_BAR_COLORS[reaction]
	local alpha = (customColors and color.a) or DB.db.colors.reputationAlpha

	bar:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1, alpha or 1)
	bar:SetMinMaxValues(minValue, maxValue)
	bar:SetValue(curValue)

	bar.Reward:ClearAllPoints()
	bar.Reward:SetPoint('CENTER', bar, DB.db.reputation.rewardPosition)
	bar.Reward:SetShown(rewardPending and DB.db.reputation.showReward)

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

	local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()
	local standing = _G['FACTION_STANDING_LABEL'..reaction] or UNKNOWN
	local isParagon = C_Reputation_IsFactionParagon(factionID)

	if factionID and isParagon then
		local current, threshold = C_Reputation_GetFactionParagonInfo(factionID)
		if current and threshold then
			standing, minValue, maxValue, curValue = L["Paragon"], 0, threshold, current % threshold
		end
	end

	if name and not GameTooltip:IsForbidden() then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(' ')

		local friendID, friendTextLevel, _
		if E.Retail and factionID then
			friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
			if friendID and friendID.friendshipFactionID > 0 then
				standing = friendID.reaction
			end
		end

		local isMajorFaction = E.Retail and factionID and C_Reputation_IsMajorFaction(factionID)
		if not isMajorFaction then
			GameTooltip:AddDoubleLine(STANDING..':', (friendID and friendTextLevel) or standing, 1, 1, 1)
		end

		if isMajorFaction then
			local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
			curValue = C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
			maxValue = majorFactionData.renownLevelThreshold
			GameTooltip:AddDoubleLine(RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel, format('%d / %d (%d%%)', GetValues(curValue, 0, maxValue)), BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, 1, 1, 1)

			local current, _, percent = GetValues(QuestRep, 0, maxValue)
			GameTooltip:AddDoubleLine('Reputation from Quests', format('%d (%d%%)', current, percent), nil, nil, nil, 1, 1, 1)
		elseif isParagon or (reaction ~= _G.MAX_REPUTATION_REACTION) then
			local current, maximum, percent = GetValues(curValue, minValue, maxValue)
			GameTooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', current, maximum, percent), 1, 1, 1)
		end

		GameTooltip:Show()
	end
end

function DB:ReputationBar_OnClick()
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
		return (DB.db.reputation.hideBelowMaxLevel and not E:XPIsLevelMax()) or not GetWatchedFactionInfo()
	end

	E:CreateMover(Reputation.holder, 'ReputationBarMover', L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')

	DB:ReputationBar_Toggle()
end
