local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestWatches = GetNumQuestWatches
local GetQuestIndexForWatch = GetQuestIndexForWatch
local QuestLog_SetSelection = QuestLog_SetSelection
local QuestLog_Update = QuestLog_Update
local ShowUIPanel = ShowUIPanel
local hooksecurefunc = hooksecurefunc

BL.QuestWatch_ClickFrames = {}

local MoverInfo = {
	QuestTimerFrameMover = { point = 'TOP', text = _G.QUEST_TIMERS },
	QuestWatchFrameMover = { point = 'TOPRIGHT', text = L["Quest Objective Frame"] }
}

local function QuestWatch_SetPoint(tracker, _, anchor)
	if tracker.holder and anchor ~= tracker.holder then
		tracker:ClearAllPoints()
		tracker:SetPoint('TOP', tracker.holder)
	end
end

function BL:QuestWatch_CreateMover(frame, name)
	local info = MoverInfo[name]
	if not (info and info.text) then return end

	local holder = CreateFrame('Frame', nil, E.UIParent)
	holder:Size(info.width or 150, info.height or 22)
	holder:SetPoint(info.point, info.parent or E.UIParent, info.x or -20, info.y or -290)
	E:CreateMover(holder, name, info.text, nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')

	frame:ClearAllPoints()
	frame:Point('TOP', holder)
	frame.holder = holder

	hooksecurefunc(frame, 'SetPoint', QuestWatch_SetPoint)
end

function BL:QuestWatch_OnClick()
	ShowUIPanel(_G.QuestLogFrame)
	QuestLog_SetSelection(self.Quest)
	QuestLog_Update()
end

function BL:QuestWatch_SetClickFrames(index, quest, text)
	if not BL.QuestWatch_ClickFrames[index] then
		BL.QuestWatch_ClickFrames[index] = CreateFrame('Frame')
	end

	local frame = BL.QuestWatch_ClickFrames[index]
	frame:SetScript('OnMouseUp', BL.QuestWatch_OnClick)
	frame:SetAllPoints(text)
	frame.Quest = quest
end

function BL:QuestWatch_AddQuestClick()
	local clickIndex = 1
	local clickFrame = BL.QuestWatch_ClickFrames[clickIndex]
	while clickFrame do
		clickFrame:SetScript('OnMouseUp', nil)

		clickIndex = clickIndex + 1
		clickFrame = BL.QuestWatch_ClickFrames[clickIndex]
	end

	if not E.db.general.objectiveTracker then return end

	local lineIndex = 0
	for i = 1, GetNumQuestWatches() do -- Set clicks
		local questIndex = GetQuestIndexForWatch(i)
		if questIndex then
			local numQuests = GetNumQuestLeaderBoards(questIndex)
			if numQuests > 0 then
				local line = lineIndex + 1
				local text = _G['QuestWatchLine'..line]

				lineIndex = numQuests + line -- Bump index

				BL:QuestWatch_SetClickFrames(i, questIndex, text)
			end
		end
	end
end
