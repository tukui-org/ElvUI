local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local format = format

local _G = _G
local UnitXPMax = UnitXPMax
local MouseIsOver = MouseIsOver
local IsShiftKeyDown = IsShiftKeyDown
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogRewardXP = GetQuestLogRewardXP
local SelectQuestLogEntry = SelectQuestLogEntry
local GetQuestLogRewardMoney = GetQuestLogRewardMoney
local BreakUpLargeNumbers = BreakUpLargeNumbers

local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local GetNumQuestLogEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries) or GetNumQuestLogEntries

local MAX_QUESTLOG_QUESTS = min(C_QuestLog.GetMaxNumQuestsCanAccept() + (E.Retail and 10 or 0), 35) -- 20 for ERA, 25 for WotLK, 35 for Retail
local TRACKER_HEADER_QUESTS = TRACKER_HEADER_QUESTS
local COMPLETE = COMPLETE
local INCOMPLETE = INCOMPLETE

local displayString = ''
local numEntries, numQuests, xpToLevel = 0, 0, 0

local function GetQuestInfo(questIndex)
	if E.Retail then
		return C_QuestLog_GetInfo(questIndex)
	else
		local info, _ = {}
		info.title, info.level, info.questTag, info.isHeader, info.isCollapsed, info.isComplete, info.frequency, info.questID, info.startEvent, _, info.isOnMap, info.hasLocalPOI, info.isTask, info.isBounty, info.isStory, info.isHidden, info.isScaling = GetQuestLogTitle(questIndex)
		SelectQuestLogEntry(questIndex)

		return info
	end
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local totalMoney, totalXP, completedXP = 0, 0, 0
	local isShiftDown = IsShiftKeyDown()

	DT.tooltip:AddLine(TRACKER_HEADER_QUESTS)
	DT.tooltip:AddLine(' ')

	for questIndex = 1, numEntries do
		local info = GetQuestInfo(questIndex)
		if info and not info.isHidden and not info.isHeader then
			local xp = GetQuestLogRewardXP(info.questID)
			local money = GetQuestLogRewardMoney(info.questID)
			local isComplete = info.isComplete or E.Retail and _G.C_QuestLog.ReadyForTurnIn(info.questID)

			totalMoney = totalMoney + money
			totalXP = totalXP + xp
			completedXP = completedXP + (isComplete and xp or 0)

			DT.tooltip:AddDoubleLine(info.title, isShiftDown and format('%s (%.2f%%)', BreakUpLargeNumbers(xp), (xp / xpToLevel) * 100) or (isComplete and COMPLETE or INCOMPLETE), 1, 1, 1, isComplete and .2 or 1, isComplete and 1 or .2, .2)
		end
	end

	if completedXP > 0 then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine('Completed XP:', format('%s (%.2f%%)', BreakUpLargeNumbers(completedXP), (completedXP / xpToLevel) * 100), nil, nil, nil, 1, 1, 1)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddDoubleLine('Total Gold:', E:FormatMoney(totalMoney, 'SMART'), nil, nil, nil, 1, 1, 1)
	DT.tooltip:AddDoubleLine('Total XP:', format('%s (%.2f%%)', BreakUpLargeNumbers(totalXP), (totalXP / xpToLevel) * 100), nil, nil, nil, 1, 1, 1)
	DT.tooltip:Show()
end

local function OnClick()
	_G.ToggleQuestLog()
end

local function OnEvent(self)
	numEntries, numQuests = GetNumQuestLogEntries()
	xpToLevel = UnitXPMax('player')

	self.text:SetFormattedText(displayString, numQuests, MAX_QUESTLOG_QUESTS)

	if MouseIsOver(self) then
		OnEnter(self)
	end
end

local function ApplySettings(_, hex)
	displayString = strjoin('', 'Quests: ', hex, '%d|r', '/', hex, '%d|r')
end

DT:RegisterDatatext('Quests', nil, { 'QUEST_ACCEPTED', 'QUEST_REMOVED', 'QUEST_TURNED_IN', 'QUEST_LOG_UPDATE', 'MODIFIER_STATE_CHANGED' }, OnEvent, nil, OnClick, OnEnter, nil, L["Quest Log"], nil, ApplySettings)
