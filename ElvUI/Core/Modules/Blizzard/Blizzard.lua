local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')
local LSM = E.Libs.LSM

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

function B:HandleAddonCompartment()
	local compartment = _G.AddonCompartmentFrame
	if compartment then
		if not compartment.mover then
			compartment:SetParent(_G.UIParent)
			compartment:SetFrameLevel(10) -- over minimap mover
			compartment:ClearAllPoints()
			compartment:Point('RIGHT', _G.ElvUI_MinimapHolder or _G.Minimap, -5, 10)
			E:CreateMover(compartment, 'AddonCompartmentMover', L["Addon Compartment"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements,addonCompartment')
		end

		local db = E.db.general.addonCompartment
		if db.hide then
			E:DisableMover(compartment.mover.name)
			compartment:SetParent(E.HiddenFrame)
		else
			E:EnableMover(compartment.mover.name)
			compartment.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
			compartment:SetFrameLevel(db.frameLevel or 20)
			compartment:SetFrameStrata(db.frameStrata or 'MEDIUM')
			compartment:SetParent(_G.UIParent)
			compartment:Size(db.size or 18)
		end
	end
end

function B:Initialize()
	B.Initialized = true

	B:EnhanceColorPicker()
	B:AlertMovers()
	B:HandleWidgets()
	B:PositionCaptureBar()

	if not E.Retail then
		B:KillBlizzard()
	else
		B:DisableHelpTip()
		B:DisableTutorials()
		B:SkinBlizzTimers()
		B:HandleTalkingHead()
		B:HandleAddonCompartment()

		E:CreateMover(_G.LossOfControlFrame, 'LossControlMover', L["Loss Control Icon"])

		--Add (+X%) to quest rewards experience text
		B:SecureHook('QuestInfo_Display', 'QuestXPPercent')

		if not E:IsAddOnEnabled('SimplePowerBar') then
			B:PositionAltPowerBar()
			B:SkinAltPowerBar()
		end
	end

	if not E.Classic then
		B:PositionVehicleFrame()

		if not (E:IsAddOnEnabled('DugisGuideViewerZ') or E:IsAddOnEnabled('!KalielsTracker')) then
			B:MoveObjectiveFrame()
		end
	elseif E.db.general.objectiveTracker then -- classic check
		B:QuestWatch_MoveFrames()
		hooksecurefunc('QuestWatch_Update', B.QuestWatch_AddQuestClick)
	end

	local MinimapAnchor = _G.ElvUI_MinimapHolder or _G.Minimap
	do -- Battle.Net Frame
		_G.BNToastFrame:ClearAllPoints()
		_G.BNToastFrame:Point('TOPRIGHT', MinimapAnchor, 'BOTTOMRIGHT', 0, -10)
		E:CreateMover(_G.BNToastFrame, 'BNETMover', L["BNet Frame"], nil, nil, PostMove)
		_G.BNToastFrame.mover:Size(_G.BNToastFrame:GetSize())
		B:SecureHook(_G.BNToastFrame, 'SetPoint', 'RepositionFrame')
	end

	if GetCurrentRegion() == 2 then -- TimeAlertFrame Frame
		_G.TimeAlertFrame:Point('TOPRIGHT', MinimapAnchor, 'BOTTOMRIGHT', 0, -80)
		E:CreateMover(_G.TimeAlertFrame, 'TimeAlertFrameMover', L["Time Alert Frame"], nil, nil, PostMove)
		_G.TimeAlertFrame.mover:Size(_G.TimeAlertFrame:GetSize())
		B:SecureHook(_G.TimeAlertFrame, 'SetPoint', 'RepositionFrame')
	end
end

E:RegisterModule(B:GetName())
