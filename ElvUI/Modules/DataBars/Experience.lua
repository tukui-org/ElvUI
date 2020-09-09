local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local min, format = min, format
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local CreateFrame = CreateFrame
local IsXPUserDisabled = IsXPUserDisabled
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_QuestLog_GetQuestsOnMap = C_QuestLog.GetQuestsOnMap
local C_QuestLog_ReadyForTurnIn = C_QuestLog.ReadyForTurnIn
local C_QuestLog_SetSelectedQuest = C_QuestLog.SetSelectedQuest
local C_QuestLog_ShouldShowQuestRewards = C_QuestLog.ShouldShowQuestRewards

local GetQuestLogRewardXP = GetQuestLogRewardXP

local CurrentXP, XPToLevel, RestedXP, QuestLogXP = 0, 0, 0

function DB:ExperienceBar_ShouldBeVisable()
	return not IsPlayerAtEffectiveMaxLevel() and not IsXPUserDisabled()
end

function DB:ExperienceBar_Update()
	local bar = DB.StatusBars.Experience
	if not DB.db.experience.enable or (bar.db.hideAtMaxLevel and not DB:ExperienceBar_ShouldBeVisable()) then
		bar:Hide()
		return
	else
		bar:Show()
	end

	CurrentXP, XPToLevel, RestedXP = UnitXP('player'), UnitXPMax('player'), GetXPExhaustion()
	if XPToLevel <= 0 then XPToLevel = 1 end

	bar:SetMinMaxValues(0, XPToLevel)
	bar:SetValue(CurrentXP)

	local expColor, restedColor = DB.db.colors.experience, DB.db.colors.rested
	bar:SetStatusBarColor(expColor.r, expColor.g, expColor.b, expColor.a)
	bar.Rested:SetStatusBarColor(restedColor.r, restedColor.g, restedColor.b, restedColor.a)

	local text, textFormat = '', DB.db.experience.textFormat

	if not DB:ExperienceBar_ShouldBeVisable() then
		text = L['Max Level']
	else
		if textFormat == 'PERCENT' then
			text = format('%d%%', CurrentXP / XPToLevel * 100)
		elseif textFormat == 'CURMAX' then
			text = format('%s - %s', E:ShortValue(CurrentXP), E:ShortValue(XPToLevel))
		elseif textFormat == 'CURPERC' then
			text = format('%s - %d%%', E:ShortValue(CurrentXP), CurrentXP / XPToLevel * 100)
		elseif textFormat == 'CUR' then
			text = format('%s', E:ShortValue(CurrentXP))
		elseif textFormat == 'REM' then
			text = format('%s', E:ShortValue(XPToLevel - CurrentXP))
		elseif textFormat == 'CURREM' then
			text = format('%s - %s', E:ShortValue(CurrentXP), E:ShortValue(XPToLevel - CurrentXP))
		elseif textFormat == 'CURPERCREM' then
			text = format('%s - %d%% (%s)', E:ShortValue(CurrentXP), CurrentXP / XPToLevel * 100, E:ShortValue(XPToLevel - CurrentXP))
		end

		if RestedXP and RestedXP > 0 then
			bar.Rested:SetMinMaxValues(0, XPToLevel)
			bar.Rested:SetValue(min(CurrentXP + RestedXP, XPToLevel))
			bar.Rested:Show()

			if textFormat == 'PERCENT' then
				text = text..format(' R:%d%%', RestedXP / XPToLevel * 100)
			elseif textFormat == 'CURPERC' then
				text = text..format(' R:%s [%d%%]', E:ShortValue(RestedXP), RestedXP / XPToLevel * 100)
			elseif textFormat ~= 'NONE' then
				text = text..format(' R:%s', E:ShortValue(RestedXP))
			end
		else
			bar.Rested:Hide()
		end
	end

	bar.text:SetText(text)
end

function DB:ExperienceBar_QuestXP()
	if not DB:ExperienceBar_ShouldBeVisable() then return end
	local bar = DB.StatusBars.Experience

	QuestLogXP = 0

	if bar.db.questCurrentZoneOnly then
		local mapQuests = C_QuestLog_GetQuestsOnMap(C_Map_GetBestMapForUnit("player"))

		for _, v in ipairs(mapQuests) do
			if v.type == -1 then
				C_QuestLog_SetSelectedQuest(v.questID)
				local rewards = C_QuestLog_ShouldShowQuestRewards(v.questID)
				local isCompleted = C_QuestLog_ReadyForTurnIn(v.questID)
				if rewards and (bar.db.questCompletedOnly and isCompleted or (not bar.db.questCompletedOnly and not isCompleted) ) then
					QuestLogXP = QuestLogXP + GetQuestLogRewardXP()
				end
			end
		end
	else
		for i = 1, C_QuestLog_GetNumQuestLogEntries() do
			local questID = C_QuestLog_GetQuestIDForLogIndex(i)
			C_QuestLog_SetSelectedQuest(questID)
			local rewards = C_QuestLog_ShouldShowQuestRewards(questID)
			local isCompleted = C_QuestLog_ReadyForTurnIn(questID)
			if rewards and (bar.db.questCompletedOnly and isCompleted or (not bar.db.questCompletedOnly and not isCompleted) ) then
				QuestLogXP = QuestLogXP + GetQuestLogRewardXP()
			end
		end
	end

	if QuestLogXP > 0 then
		bar.Quest:SetMinMaxValues(0, XPToLevel)
		bar.Quest:SetValue(min(CurrentXP + QuestLogXP, XPToLevel))
		bar.Quest:SetStatusBarColor(DB.db.colors.quest.r, DB.db.colors.quest.g, DB.db.colors.quest.b, DB.db.colors.quest.a)
		bar.Quest:Show()
	else
		bar.Quest:Hide()
	end
end

function DB:ExperienceBar_OnEnter()
	if self.db.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	if not DB:ExperienceBar_ShouldBeVisable() then return end

	_G.GameTooltip:ClearLines()
	_G.GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	_G.GameTooltip:AddLine(L["Experience"])
	_G.GameTooltip:AddLine(' ')

	_G.GameTooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%.2f%%)', CurrentXP, XPToLevel, CurrentXP/XPToLevel * 100), 1, 1, 1)
	_G.GameTooltip:AddDoubleLine(L["Remaining:"], format(' %d (%.2f%% - %.2f '..L["Bars"]..')', XPToLevel - CurrentXP, (XPToLevel - CurrentXP) / XPToLevel * 100, 20 * (XPToLevel - CurrentXP) / XPToLevel), 1, 1, 1)
	_G.GameTooltip:AddDoubleLine(L["Quest Log XP:"], QuestLogXP, 1, 1, 1)

	if RestedXP then
		_G.GameTooltip:AddDoubleLine(L["Rested:"], format('+%d (%.2f%%)', RestedXP, RestedXP / XPToLevel * 100), 1, 1, 1)
	end

	_G.GameTooltip:Show()
end

function DB:ExperienceBar_OnClick() end

function DB:ExperienceBar_Toggle()
	local bar = DB.StatusBars.Experience
	bar.db = DB.db.experience

	if bar.db.enable and not (bar.db.hideAtMaxLevel and not DB:ExperienceBar_ShouldBeVisable()) then
		bar:Show()
		E:EnableMover(bar.mover:GetName())

		DB:RegisterEvent('PLAYER_XP_UPDATE', 'ExperienceBar_Update')
		DB:RegisterEvent('DISABLE_XP_GAIN', 'ExperienceBar_Update')
		DB:RegisterEvent('ENABLE_XP_GAIN', 'ExperienceBar_Update')
		DB:RegisterEvent('UPDATE_EXHAUSTION', 'ExperienceBar_Update')
		DB:RegisterEvent('QUEST_LOG_UPDATE', 'ExperienceBar_QuestXP')
		DB:RegisterEvent('ZONE_CHANGED', 'ExperienceBar_QuestXP')
		DB:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'ExperienceBar_QuestXP')

		DB:UnregisterEvent('UPDATE_EXPANSION_LEVEL')

		DB:ExperienceBar_Update()
	else
		bar:Hide()
		E:DisableMover(bar.mover:GetName())

		DB:UnregisterEvent('PLAYER_XP_UPDATE')
		DB:UnregisterEvent('DISABLE_XP_GAIN')
		DB:UnregisterEvent('ENABLE_XP_GAIN')
		DB:UnregisterEvent('UPDATE_EXHAUSTION')
		DB:UnregisterEvent('QUEST_LOG_UPDATE')
		DB:UnregisterEvent('ZONE_CHANGED')
		DB:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
		DB:RegisterEvent('UPDATE_EXPANSION_LEVEL', 'ExperienceBar_Toggle')
	end
end

function DB:ExperienceBar()
	DB.StatusBars.Experience = DB:CreateBar('ElvUI_ExperienceBar', DB.ExperienceBar_OnEnter, DB.ExperienceBar_OnClick, 'BOTTOM', E.UIParent, 'BOTTOM', 0, 43)

	DB.StatusBars.Experience.Rested = CreateFrame('StatusBar', '$parent_Rested', DB.StatusBars.Experience)
	DB.StatusBars.Experience.Rested:SetStatusBarTexture(DB.db.customTexture and E.LSM:Fetch('statusbar', DB.db.statusbar) or E.media.normTex)
	DB.StatusBars.Experience.Rested:SetAllPoints()

	DB.StatusBars.Experience.Quest = CreateFrame('StatusBar', '$parent_Rested', DB.StatusBars.Experience)
	DB.StatusBars.Experience.Quest:SetStatusBarTexture(DB.db.customTexture and E.LSM:Fetch('statusbar', DB.db.statusbar) or E.media.normTex)
	DB.StatusBars.Experience.Quest:SetAllPoints()

	E:CreateMover(DB.StatusBars.Experience, 'ExperienceBarMover', L["Experience Bar"], nil, nil, nil, nil, nil, 'databars,experience')
	DB:ExperienceBar_Toggle()
end
