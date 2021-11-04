local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestWatches = GetNumQuestWatches
local GetQuestIndexForWatch = GetQuestIndexForWatch
local QuestLog_SetSelection = QuestLog_SetSelection
local QuestLog_Update = QuestLog_Update
local ShowUIPanel = ShowUIPanel

B.QuestWatch_ClickFrames = {}
function B:QuestWatch_MoveFrames()
	local QuestWatchFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	QuestWatchFrameHolder:Size(130, 22)
	QuestWatchFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)
	E:CreateMover(QuestWatchFrameHolder, 'QuestWatchFrameMover', L["Quest Objective Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')

	local QuestTimerFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	QuestTimerFrameHolder:Size(158, 72)
	QuestTimerFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)
	E:CreateMover(QuestTimerFrameHolder, 'QuestTimerFrameMover', L["Quest Timer Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')

	local QuestWatchFrame = _G.QuestWatchFrame
	QuestWatchFrameHolder:SetAllPoints(_G.QuestWatchFrameMover)
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetAllPoints(QuestWatchFrameHolder)

	local QuestTimerFrame = _G.QuestTimerFrame
	QuestTimerFrameHolder:SetAllPoints(_G.QuestTimerFrameMover)
	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetAllPoints(QuestTimerFrameHolder)
end

function B:QuestWatch_OnClick()
	ShowUIPanel(_G.QuestLogFrame)
	QuestLog_SetSelection(self.Quest)
	QuestLog_Update()
end

function B:QuestWatch_SetClickFrames(index, quest, text)
	if not B.QuestWatch_ClickFrames[index] then
		B.QuestWatch_ClickFrames[index] = CreateFrame('Frame')
	end

	local frame = B.QuestWatch_ClickFrames[index]
	frame:SetScript('OnMouseUp', B.QuestWatch_OnClick)
	frame:SetAllPoints(text)
	frame.Quest = quest
end

function B:QuestWatch_AddQuestClick()
	local clickIndex = 1
	local clickFrame = B.QuestWatch_ClickFrames[clickIndex]
	while clickFrame do
		clickFrame:SetScript('OnMouseUp', nil)

		clickIndex = clickIndex + 1
		clickFrame = B.QuestWatch_ClickFrames[clickIndex]
	end

	if not E.db.general.objectiveTracker then return end

	local lineIndex = 0
	for i = 1, GetNumQuestWatches() do -- Set clicks
		local questIndex = GetQuestIndexForWatch(i)
		if questIndex then
			local numQuests = GetNumQuestLeaderBoards(questIndex)
			if numQuests > 0 then
				local text = _G['QuestWatchLine'..lineIndex + 1]

				lineIndex = numQuests + lineIndex + 1 -- Bump index

				B:QuestWatch_SetClickFrames(i, questIndex, text)
			end
		end
	end
end
