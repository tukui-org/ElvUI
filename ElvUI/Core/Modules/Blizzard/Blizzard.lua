local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetRewardXP = GetRewardXP
local GetCurrentRegion = GetCurrentRegion
local GetQuestLogRewardXP = GetQuestLogRewardXP
local C_QuestLog_ShouldShowQuestRewards = C_QuestLog.ShouldShowQuestRewards
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest
local hooksecurefunc = hooksecurefunc

--This changes the growth direction of the toast frame depending on position of the mover
local function PostMove(mover)
	local x, y = mover:GetCenter()
	local top = E.UIParent:GetTop()
	local right = E.UIParent:GetRight()

	local point
	if y > (top*0.5) then
		point = (x > (right*0.5)) and 'TOPRIGHT' or 'TOPLEFT'
	else
		point = (x > (right*0.5)) and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	end
	mover.anchorPoint = point

	mover.parent:ClearAllPoints()
	mover.parent:Point(point, mover)
end

function B:RepositionFrame(frame, _, anchor)
	if anchor ~= frame.mover then
		frame:ClearAllPoints()
		frame:Point(frame.mover.anchorPoint or 'TOPLEFT', frame.mover, frame.mover.anchorPoint or 'TOPLEFT')
	end
end

function B:QuestXPPercent()
	if not E.db.general.questXPPercent then return end

	local unitXP, unitXPMax = UnitXP('player'), UnitXPMax('player')
	if _G.QuestInfoFrame.questLog then
		local selectedQuest = C_QuestLog_GetSelectedQuest()
		if C_QuestLog_ShouldShowQuestRewards(selectedQuest) then
			local xp = GetQuestLogRewardXP()
			if xp and xp > 0 then
				local text = _G.MapQuestInfoRewardsFrame.XPFrame.Name:GetText()
				if text then _G.MapQuestInfoRewardsFrame.XPFrame.Name:SetFormattedText('%s (|cff4beb2c+%.2f%%|r)', text, (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax))*100) end
			end
		end
	else
		local xp = GetRewardXP()
		if xp and xp > 0 then
			local text = _G.QuestInfoXPFrame.ValueText:GetText()
			if text then _G.QuestInfoXPFrame.ValueText:SetFormattedText('%s (|cff4beb2c+%.2f%%|r)', text, (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax))*100) end
		end
	end
end

function B:Initialize()
	B.Initialized = true

	B:EnhanceColorPicker()
	B:AlertMovers()
	B:KillBlizzard()
	B:HandleWidgets()
	B:PositionCaptureBar()

	if not E.Classic then
		B:PositionVehicleFrame()
	end

	if E.Retail then
		B:DisableHelpTip()
		B:DisableNPE()
		B:SkinBlizzTimers()
		B:HandleTalkingHead()

		E:CreateMover(_G.LossOfControlFrame, 'LossControlMover', L["Loss Control Icon"])

		--Add (+X%) to quest rewards experience text
		B:SecureHook('QuestInfo_Display', 'QuestXPPercent')

		if not E:IsAddOnEnabled('SimplePowerBar') then
			B:PositionAltPowerBar()
			B:SkinAltPowerBar()
		end
	elseif E.Classic and E.db.general.objectiveTracker then
		B:QuestWatch_MoveFrames()
		hooksecurefunc('QuestWatch_Update', B.QuestWatch_AddQuestClick)
	end

	if not (E:IsAddOnEnabled('DugisGuideViewerZ') or E:IsAddOnEnabled('!KalielsTracker')) then
		B:MoveObjectiveFrame()
	end

	-- Battle.Net Frame
	_G.BNToastFrame:Point('TOPRIGHT', _G.MMHolder or _G.Minimap, 'BOTTOMRIGHT', 0, -10)
	E:CreateMover(_G.BNToastFrame, 'BNETMover', L["BNet Frame"], nil, nil, PostMove)
	_G.BNToastFrame.mover:Size(_G.BNToastFrame:GetSize())
	B:SecureHook(_G.BNToastFrame, 'SetPoint', 'RepositionFrame')

	if GetCurrentRegion() == 2 then -- TimeAlertFrame Frame
		_G.TimeAlertFrame:Point('TOPRIGHT', _G.MMHolder or _G.Minimap, 'BOTTOMRIGHT', 0, -80)
		E:CreateMover(_G.TimeAlertFrame, 'TimeAlertFrameMover', L["Time Alert Frame"], nil, nil, PostMove)
		_G.TimeAlertFrame.mover:Size(_G.TimeAlertFrame:GetSize())
		B:SecureHook(_G.TimeAlertFrame, 'SetPoint', 'RepositionFrame')
	end
end

E:RegisterModule(B:GetName())
