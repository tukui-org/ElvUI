local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')
local Skins = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local CreateFrame = CreateFrame
local GetQuestLogRewardXP = GetQuestLogRewardXP
local GetRewardXP = GetRewardXP
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local C_QuestLog_ShouldShowQuestRewards = C_QuestLog.ShouldShowQuestRewards
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest

--This changes the growth direction of the toast frame depending on position of the mover
local function PostBNToastMove(mover)
	local x, y = mover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	local screenWidth = E.UIParent:GetRight()

	local anchorPoint
	if y > (screenHeight / 2) then
		anchorPoint = (x > (screenWidth/2)) and 'TOPRIGHT' or 'TOPLEFT'
	else
		anchorPoint = (x > (screenWidth/2)) and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	end
	mover.anchorPoint = anchorPoint

	_G.BNToastFrame:ClearAllPoints()
	_G.BNToastFrame:Point(anchorPoint, mover)
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
	B:KillBlizzard()
	B:DisableHelpTip()
	B:DisableNPE()
	B:AlertMovers()
	B:PositionCaptureBar()
	B:PositionDurabilityFrame()
	B:PositionGMFrames()
	B:SkinBlizzTimers()
	B:PositionVehicleFrame()
	B:PositionTalkingHead()
	B:Handle_BossBanner()
	B:Handle_UIWidgets()

	if not (E:IsAddOnEnabled('DugisGuideViewerZ') or E:IsAddOnEnabled('!KalielsTracker')) then
		B:MoveObjectiveFrame()
	end

	if not E:IsAddOnEnabled('SimplePowerBar') then
		B:PositionAltPowerBar()
		B:SkinAltPowerBar()
	end

	E:CreateMover(_G.LossOfControlFrame, 'LossControlMover', L["Loss Control Icon"])

	-- Battle.Net Frame
	_G.BNToastFrame:Point('TOPRIGHT', _G.MMHolder or _G.Minimap, 'BOTTOMRIGHT', 0, -10)
	E:CreateMover(_G.BNToastFrame, 'BNETMover', L["BNet Frame"], nil, nil, PostBNToastMove)
	_G.BNToastFrame.mover:Size(_G.BNToastFrame:GetSize())
	TT:SecureHook(_G.BNToastFrame, 'SetPoint', 'RepositionBNET')

	-- Quick Join Bug
	CreateFrame('Frame'):SetScript('OnUpdate', function()
		if _G.LFRBrowseFrame.timeToClear then
			_G.LFRBrowseFrame.timeToClear = nil
		end
	end)

	--Add (+X%) to quest rewards experience text
	B:SecureHook('QuestInfo_Display', 'QuestXPPercent')

	-- MicroButton Talent Alert
	local TalentMicroButtonAlert = _G.TalentMicroButtonAlert
	if TalentMicroButtonAlert then -- why do we need to check this?
		if E.global.general.showMissingTalentAlert then
			TalentMicroButtonAlert:ClearAllPoints()
			TalentMicroButtonAlert:Point('CENTER', E.UIParent, 'TOP', 0, -75)
			TalentMicroButtonAlert:StripTextures()
			TalentMicroButtonAlert.Arrow:Hide()
			TalentMicroButtonAlert.Text:FontTemplate()
			TalentMicroButtonAlert:CreateBackdrop('Transparent')
			Skins:HandleCloseButton(TalentMicroButtonAlert.CloseButton)

			TalentMicroButtonAlert.tex = TalentMicroButtonAlert:CreateTexture(nil, 'OVERLAY')
			TalentMicroButtonAlert.tex:Point('RIGHT', -10, 0)
			TalentMicroButtonAlert.tex:SetTexture([[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]])
			TalentMicroButtonAlert.tex:Size(32, 32)
		else
			TalentMicroButtonAlert:Kill() -- Kill it, because then the blizz default will show
		end
	end
end

E:RegisterModule(B:GetName())
