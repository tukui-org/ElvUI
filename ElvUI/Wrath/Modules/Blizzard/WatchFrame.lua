local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame

B.QuestWatch_ClickFrames = {}
function B:QuestWatch_MoveFrames()
	local WatchFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	WatchFrameHolder:Size(130, 22)
	WatchFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)
	E:CreateMover(WatchFrameHolder, 'WatchFrameMover', L["Quest Objective Frame"], nil, nil, nil, nil, nil, 'general,objectiveFrameGroup')

	local WatchFrame = _G.WatchFrame
	WatchFrameHolder:SetAllPoints(_G.WatchFrameMover)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint('TOPLEFT', WatchFrameHolder, 'TOPLEFT')

	hooksecurefunc(WatchFrame, 'SetPoint', function(_, _, parent)
		if parent ~= WatchFrameHolder then
			WatchFrame:ClearAllPoints()
			WatchFrame:SetPoint('TOPLEFT', WatchFrameHolder, 'TOPLEFT')
		end
	end)
	B:SetObjectiveFrameHeight()
end
