local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame
local GetNumQuestWatches = GetNumQuestWatches
local GetQuestIndexForWatch = GetQuestIndexForWatch
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local ShowUIPanel = ShowUIPanel
local QuestLog_SetSelection = QuestLog_SetSelection
local QuestLog_Update = QuestLog_Update
local hooksecurefunc = hooksecurefunc

local ClickFrames = {}

function B:MoveQuestWatchFrame()
	local QuestWatchFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	QuestWatchFrameHolder:Size(130, 22)
	QuestWatchFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

	E:CreateMover(QuestWatchFrameHolder, 'QuestWatchFrameMover', L["Quest Objective Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')

	local QuestTimerFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	QuestTimerFrameHolder:Size(158, 72)
	QuestTimerFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

	E:CreateMover(QuestTimerFrameHolder, 'QuestTimerFrameMover', L["Quest Timer Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')

	local QuestWatchFrameMover = _G.QuestWatchFrameMover
	local QuestTimerFrameMover = _G.QuestTimerFrameMover
	local QuestWatchFrame = _G.QuestWatchFrame
	local QuestTimerFrame = _G.QuestTimerFrame

	QuestWatchFrameHolder:SetAllPoints(QuestWatchFrameMover)

	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetAllPoints(QuestWatchFrameHolder)

	QuestTimerFrameHolder:SetAllPoints(QuestTimerFrameMover)

	QuestTimerFrame:ClearAllPoints()
	QuestTimerFrame:SetAllPoints(QuestTimerFrameHolder)

end

function B:OnQuestClick()
	ShowUIPanel(_G.QuestLogFrame)
	QuestLog_SetSelection(self.Quest)
	QuestLog_Update()
end

function B:SetClickFrame(index, quest, text)
	if not ClickFrames[index] then
		ClickFrames[index] = CreateFrame('Frame')
	end

	local Frame = ClickFrames[index]
	Frame:SetScript('OnMouseUp', self.OnQuestClick)

	Frame:SetAllPoints(text)
	Frame.Quest = quest
end

function B:AddQuestClick()
	local Index = 0

	-- Reset clicks
	for i = 1, 5 do
		local Frame = ClickFrames[i]

		if Frame then
			Frame:SetScript('OnMouseUp', nil)
		end
	end

	-- Set new clicks
	for i = 1, GetNumQuestWatches() do
		local Quest = GetQuestIndexForWatch(i)

		if Quest then
			local NumQuest = GetNumQuestLeaderBoards(Quest)

			if NumQuest > 0 then
				Index = Index + 1

				local Text = _G['QuestWatchLine'..Index]

				for j = 1, NumQuest do
					Index = Index + 1
				end

				B:SetClickFrame(i, Quest, Text)
			end
		end
	end
end

function B:AddHook()
	hooksecurefunc('QuestWatch_Update', self.AddQuestClick)
end

function B:QuestWatchFrame()
	if E.db.general.objectiveTracker then
		self:MoveQuestWatchFrame()
		self:AddHook()
	end
end
