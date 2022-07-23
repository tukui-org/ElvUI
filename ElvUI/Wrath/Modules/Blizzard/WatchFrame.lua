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
	local WatchFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	WatchFrameHolder:Size(130, 22)
	WatchFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)
	E:CreateMover(WatchFrameHolder, 'WatchFrameMover', L["Quest Objective Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')

	local WatchFrame = _G.WatchFrame
	WatchFrameHolder:SetAllPoints(_G.WatchFrameMover)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetAllPoints(WatchFrameHolder)

	hooksecurefunc(WatchFrame, 'SetPoint', function(_, _, parent)
		if parent ~= WatchFrameHolder then
			WatchFrame:ClearAllPoints()
			WatchFrame:SetAllPoints(WatchFrameHolder)
		end
	end)
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
