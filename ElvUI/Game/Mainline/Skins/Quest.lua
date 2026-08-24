local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, gsub = unpack, gsub
local pairs, next, strmatch = pairs, next, strmatch
local ipairs, strfind = ipairs, strfind
local hooksecurefunc = hooksecurefunc

local GetMoney = GetMoney
local GetQuestID = GetQuestID
local CreateFrame = CreateFrame
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard

local C_QuestLog_GetRequiredMoney = C_QuestLog.GetRequiredMoney
local C_QuestLog_GetNextWaypointText = C_QuestLog.GetNextWaypointText
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest
local C_QuestInfoSystem_GetQuestRewardSpells = C_QuestInfoSystem.GetQuestRewardSpells

local sealFrameTextColor = {
	['480404'] = 'c20606',
	['042c54'] = '1c86ee',
}

function S:QuestInfoSealFrameText(text)
	if text and text ~= '' then
		local colorStr, rawText = strmatch(text, '|c[fF][fF](%x%x%x%x%x%x)(.-)|r')
		if colorStr and rawText then
			colorStr = sealFrameTextColor[colorStr] or '99ccff'
			self:SetFormattedText('|cff%s%s|r', colorStr, rawText)
		end
	end
end

local function GreetingPanel_OnShow(frame)
	for button in frame.titleButtonPool:EnumerateActive() do
		button.Icon:SetDrawLayer('ARTWORK')

		if E.private.skins.parchmentRemoverEnable then
			local text = button:GetFontString():GetText()
			if text and strfind(text, '|cff000000') then
				button:GetFontString():SetText(gsub(text, '|cff000000', '|cffffe519'))
			end
		end
	end
end

local function HandleReward(frame)
	if not frame then return end

	for _, Region in next, { frame:GetRegions() } do
		if Region:IsObjectType('Texture') and Region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
			Region:SetTexture(E.ClearTexture)
		end
	end

	if frame.Icon then
		frame.Icon:SetDrawLayer('ARTWORK')
		S:HandleIcon(frame.Icon, true)

		if frame.IconBorder then
			S:HandleIconBorder(frame.IconBorder, frame.Icon.backdrop)
		end
	end

	if frame.Count then
		frame.Count:SetDrawLayer('OVERLAY')
		frame.Count:ClearAllPoints()
		frame.Count:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 0, 0)
	end

	if frame.NameFrame then
		frame.NameFrame:SetAlpha(0)
		frame.NameFrame:Hide()
	end

	if frame.IconOverlay then
		frame.IconOverlay:SetAlpha(0)
	end

	if frame.Name then
		frame.Name:FontTemplate()
	end

	if frame.CircleBackground then
		frame.CircleBackground:SetAlpha(0)
		frame.CircleBackgroundGlow:SetAlpha(0)
	end
end

-- Quest objective text color
local function Quest_GetQuestID()
	if _G.QuestInfoFrame.questLog then
		return C_QuestLog_GetSelectedQuest()
	else
		return GetQuestID()
	end
end

function S:QuestInfo_ShowObjectives()
	local objectives = _G.QuestInfoObjectivesFrame.Objectives
	local index = 0

	local questID = Quest_GetQuestID()
	local waypointText = C_QuestLog_GetNextWaypointText(questID)
	if waypointText then
		index = index + 1
		objectives[index]:SetTextColor(.4, 1, 1)
	end

	for i = 1, GetNumQuestLeaderBoards() do
		local _, objectiveType, isCompleted = GetQuestLogLeaderBoard(i)
		if objectiveType ~= 'spell' and objectiveType ~= 'log' and index < _G.MAX_OBJECTIVES then
			index = index + 1

			local objective = objectives[index]
			if objective then
				if isCompleted then
					objective:SetTextColor(.2, 1, .2)
				else
					objective:SetTextColor(1, 1, 1)
				end
			end
		end
	end
end

local function ShowQuestPortrait(frame, _, _, _, _, _, x, y)
	local mapFrame = _G.QuestMapFrame:GetParent()
	_G.QuestModelScene:ClearAllPoints()
	_G.QuestModelScene:Point('TOPLEFT', frame, 'TOPRIGHT', (x or 0) + (frame == mapFrame and 11 or 6), y or 0)
end

function S:QuestInfoItem_OnClick() -- self is not S
	_G.QuestInfoItemHighlight:ClearAllPoints()
	_G.QuestInfoItemHighlight:SetOutside(self.Icon)

	for _, Button in ipairs(_G.QuestInfoRewardsFrame.RewardButtons) do
		Button.Name:SetTextColor(1, 1, 1)
	end

	self.Name:SetTextColor(1, .8, .1)
end

function S:QuestInfo_Display(parentFrame) -- self is template, not S
	local rewardsFrame = _G.QuestInfoFrame.rewardsFrame
	for i, questItem in ipairs(rewardsFrame.RewardButtons) do
		local point, relativeTo, relativePoint, _, y = questItem:GetPoint()
		if point and relativeTo and relativePoint then
			if i == 1 then
				questItem:Point(point, relativeTo, relativePoint, 0, y)
			elseif relativePoint == 'BOTTOMLEFT' then
				questItem:Point(point, relativeTo, relativePoint, 0, -4)
			else
				questItem:Point(point, relativeTo, relativePoint, 4, 0)
			end
		end

		HandleReward(questItem)

		questItem.NameFrame:Hide()
		questItem.Name:SetTextColor(1, 1, 1)
	end

	local questID = Quest_GetQuestID()
	local spellRewards = C_QuestInfoSystem_GetQuestRewardSpells(questID)
	if spellRewards and (#spellRewards > 0) then
		if E.private.skins.parchmentRemoverEnable then
			for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
				spellHeader:SetVertexColor(1, 1, 1)
			end
		end

		for spellIcon in rewardsFrame.spellRewardPool:EnumerateActive() do
			HandleReward(spellIcon)
		end

		for followerReward in rewardsFrame.followerRewardPool:EnumerateActive() do
			if not followerReward.IsSkinned then
				followerReward:CreateBackdrop()
				followerReward.backdrop:SetAllPoints(followerReward.BG)
				followerReward.backdrop:Point('TOPLEFT', 40, -5)
				followerReward.backdrop:Point('BOTTOMRIGHT', 2, 5)
				followerReward.BG:Hide()

				followerReward.PortraitFrame:ClearAllPoints()
				followerReward.PortraitFrame:Point('RIGHT', followerReward.backdrop, 'LEFT', -2, 0)

				followerReward.PortraitFrame.PortraitRing:Hide()
				followerReward.PortraitFrame.PortraitRingQuality:SetTexture()
				followerReward.PortraitFrame.LevelBorder:SetAlpha(0)
				followerReward.PortraitFrame.Portrait:SetTexCoord(0.2, 0.85, 0.2, 0.85)

				local level = followerReward.PortraitFrame.Level
				level:ClearAllPoints()
				level:Point('BOTTOM', followerReward.PortraitFrame, 0, 3)

				local squareBG = CreateFrame('Frame', nil, followerReward.PortraitFrame)
				squareBG:OffsetFrameLevel(-1, followerReward.PortraitFrame)
				squareBG:Point('TOPLEFT', 2, -2)
				squareBG:Point('BOTTOMRIGHT', -2, 2)
				squareBG:SetTemplate()
				followerReward.PortraitFrame.squareBG = squareBG

				followerReward.IsSkinned = true
			end

			local r, g, b = followerReward.PortraitFrame.PortraitRingQuality:GetVertexColor()
			followerReward.PortraitFrame.squareBG:SetBackdropBorderColor(r, g, b)
		end
	end

	-- MajorFaction Rewards thing
	for spellIcon in rewardsFrame.reputationRewardPool:EnumerateActive() do
		HandleReward(spellIcon)
	end

	if E.private.skins.parchmentRemoverEnable then
		_G.QuestInfoTitleHeader:SetTextColor(1, .8, .1)
		_G.QuestInfoDescriptionHeader:SetTextColor(1, .8, .1)
		_G.QuestInfoObjectivesHeader:SetTextColor(1, .8, .1)
		_G.QuestInfoRewardsFrame.Header:SetTextColor(1, .8, .1)
		_G.QuestInfoDescriptionText:SetTextColor(1, 1, 1)
		_G.QuestInfoObjectivesText:SetTextColor(1, 1, 1)
		_G.QuestInfoGroupSize:SetTextColor(1, 1, 1)
		_G.QuestInfoRewardText:SetTextColor(1, 1, 1)
		_G.QuestInfoQuestType:SetTextColor(1, 1, 1)
		_G.QuestInfoRewardsFrame.ItemChooseText:SetTextColor(1, 1, 1)
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1, 1, 1)

		if _G.QuestInfoRewardsFrame.SpellLearnText then
			_G.QuestInfoRewardsFrame.SpellLearnText:SetTextColor(1, 1, 1)
		end

		_G.QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(1, 1, 1)
		_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(1, 1, 1)

		S:QuestInfo_ShowObjectives()
	else
		_G.QuestInfoTitleHeader:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoDescriptionHeader:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoObjectivesHeader:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardsFrame.Header:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoDescriptionText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoObjectivesText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoGroupSize:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoQuestType:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardsFrame.ItemChooseText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetShadowColor(0, 0, 0, 0)
	end
end

function S:QuestFrameProgressItems_Update() -- self is not S
	_G.QuestProgressRequiredItemsText:SetTextColor(1, .8, .1)
	_G.QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
end

function S:QuestFrame_SetTitleTextColor() -- self is fontString
	self:SetTextColor(1, .8, .1)
end

function S:QuestFrame_SetTextColor() -- self is fontString
	self:SetTextColor(1, 1, 1)
end

function S:QuestInfo_ShowRequiredMoney() -- self is not S
	local requiredMoney = C_QuestLog_GetRequiredMoney()
	if requiredMoney > 0 then
		if requiredMoney > GetMoney() then
			_G.QuestInfoRequiredMoneyText:SetTextColor(.63, .09, .09)
		else
			_G.QuestInfoRequiredMoneyText:SetTextColor(1, .8, .1)
		end
	end
end

function S:BlizzardQuestFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.quest) then return end

	S:HandleTrimScrollBar(_G.QuestProgressScrollFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.QuestRewardScrollFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.QuestDetailScrollFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.QuestGreetingScrollFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.QuestLogPopupDetailFrameScrollFrame.ScrollBar)

	local QuestInfoSkillPointFrame = _G.QuestInfoSkillPointFrame
	QuestInfoSkillPointFrame:StripTextures()
	QuestInfoSkillPointFrame:StyleButton()
	QuestInfoSkillPointFrame:Width(QuestInfoSkillPointFrame:GetWidth() - 4)
	QuestInfoSkillPointFrame:OffsetFrameLevel(2)

	local QuestInfoSkillPointFrameIconTexture = _G.QuestInfoSkillPointFrameIconTexture
	QuestInfoSkillPointFrameIconTexture:SetTexCoords()
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer('OVERLAY')
	QuestInfoSkillPointFrameIconTexture:Point('TOPLEFT', 2, -2)
	QuestInfoSkillPointFrameIconTexture:Size(QuestInfoSkillPointFrameIconTexture:GetWidth() - 2, QuestInfoSkillPointFrameIconTexture:GetHeight() - 2)
	QuestInfoSkillPointFrame:SetTemplate()
	_G.QuestInfoSkillPointFrameCount:SetDrawLayer('OVERLAY')

	local QuestInfoItemHighlight = _G.QuestInfoItemHighlight
	QuestInfoItemHighlight:StripTextures()
	QuestInfoItemHighlight:SetTemplate()
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:Size(142, 40)

	hooksecurefunc('QuestInfo_Display', S.QuestInfo_Display)
	hooksecurefunc('QuestInfoItem_OnClick', S.QuestInfoItem_OnClick)

	for _, frame in pairs({'HonorFrame', 'XPFrame', 'SpellFrame', 'SkillPointFrame', 'ArtifactXPFrame', 'TitleFrame', 'WarModeBonusFrame'}) do
		HandleReward(_G.MapQuestInfoRewardsFrame[frame])
		HandleReward(_G.QuestInfoRewardsFrame[frame])
	end
	HandleReward(_G.MapQuestInfoRewardsFrame.MoneyFrame)

	--Reward: Title
	local QuestInfoPlayerTitleFrame = _G.QuestInfoPlayerTitleFrame
	QuestInfoPlayerTitleFrame.FrameLeft:SetTexture()
	QuestInfoPlayerTitleFrame.FrameCenter:SetTexture()
	QuestInfoPlayerTitleFrame.FrameRight:SetTexture()
	QuestInfoPlayerTitleFrame.Icon:SetTexCoords()

	--Quest Frame
	local QuestFrame = _G.QuestFrame
	S:HandlePortraitFrame(QuestFrame)

	S:HandleButton(_G.QuestFrameAcceptButton, true)
	S:HandleButton(_G.QuestFrameCompleteButton, true)
	S:HandleButton(_G.QuestFrameCompleteQuestButton, true)
	S:HandleButton(_G.QuestFrameDeclineButton, true)
	S:HandleButton(_G.QuestFrameGoodbyeButton, true)
	S:HandleButton(_G.QuestFrameGreetingGoodbyeButton, true)

	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestDetailScrollChildFrame:StripTextures(nil, true)
	_G.QuestDetailScrollFrame:StripTextures(nil, true)
	_G.QuestFrameDetailPanel:StripTextures(nil, true)
	_G.QuestFrameGreetingPanel:StripTextures(nil, true)
	_G.QuestFrameProgressPanel:StripTextures(nil, true)
	_G.QuestFrameRewardPanel:StripTextures(nil, true)
	_G.QuestGreetingScrollFrame:StripTextures(nil, true)
	_G.QuestLogPopupDetailFrameScrollFrame:StripTextures(nil, true)
	_G.QuestProgressScrollFrame:StripTextures(nil, true)
	_G.QuestRewardScrollChildFrame:StripTextures(nil, true)
	_G.QuestRewardScrollFrame:StripTextures(nil, true)

	_G.QuestFrameGreetingPanel:HookScript('OnShow', GreetingPanel_OnShow) -- called when actually shown
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', GreetingPanel_OnShow) -- called through QUEST_LOG_UPDATE
	hooksecurefunc('QuestFrame_ShowQuestPortrait', ShowQuestPortrait)

	if E.private.skins.parchmentRemoverEnable then
		hooksecurefunc('QuestFrameProgressItems_Update', S.QuestFrameProgressItems_Update)
		hooksecurefunc('QuestFrame_SetTitleTextColor', S.QuestFrame_SetTitleTextColor)
		hooksecurefunc('QuestFrame_SetTextColor', S.QuestFrame_SetTextColor)
		hooksecurefunc('QuestInfo_ShowRequiredMoney', S.QuestInfo_ShowRequiredMoney)
		hooksecurefunc(_G.QuestInfoSealFrame.Text, 'SetText', S.QuestInfoSealFrameText)

		_G.QuestDetailScrollFrame:SetTemplate('NoBackdrop')
		_G.QuestProgressScrollFrame:SetTemplate('NoBackdrop')
		_G.QuestGreetingScrollFrame:SetTemplate('NoBackdrop')
		_G.QuestRewardScrollFrame:SetTemplate('NoBackdrop')
		_G.QuestLogPopupDetailFrameScrollFrame:SetTemplate('NoBackdrop')

		_G.QuestModelScene.ModelTextFrame:StripTextures()
		_G.QuestNPCModelText:SetTextColor(1, 1, 1)
	else
		_G.QuestDetailScrollFrame:SetTemplate('Transparent')
		_G.QuestProgressScrollFrame:SetTemplate('Transparent')
		_G.QuestGreetingScrollFrame:SetTemplate('Transparent')
		_G.QuestRewardScrollFrame:SetTemplate('Transparent')
		_G.QuestLogPopupDetailFrameScrollFrame:SetTemplate('Transparent')

		_G.QuestFrameDetailPanel.SealMaterialBG:SetInside(_G.QuestDetailScrollFrame)
		_G.QuestFrameRewardPanel.SealMaterialBG:SetInside(_G.QuestRewardScrollFrame)
		_G.QuestFrameProgressPanel.SealMaterialBG:SetInside(_G.QuestProgressScrollFrame)
		_G.QuestFrameGreetingPanel.SealMaterialBG:SetInside(_G.QuestGreetingScrollFrame)

		_G.QuestFrameDetailPanel.Bg:SetInside(_G.QuestDetailScrollFrame)
		_G.QuestFrameRewardPanel.Bg:SetInside(_G.QuestRewardScrollFrame)
		_G.QuestFrameProgressPanel.Bg:SetInside(_G.QuestProgressScrollFrame)
		_G.QuestFrameGreetingPanel.Bg:SetInside(_G.QuestGreetingScrollFrame)

		_G.QuestFrameDetailPanel.Bg:SetAlpha(1)
		_G.QuestFrameRewardPanel.Bg:SetAlpha(1)
		_G.QuestFrameProgressPanel.Bg:SetAlpha(1)
		_G.QuestFrameGreetingPanel.Bg:SetAlpha(1)

		_G.QuestDetailScrollFrame.Center:SetAlpha(0)
		_G.QuestRewardScrollFrame.Center:SetAlpha(0)
		_G.QuestProgressScrollFrame.Center:SetAlpha(0)
		_G.QuestGreetingScrollFrame.Center:SetAlpha(0)

		S:HandleBlizzardRegions(_G.QuestModelScene.ModelTextFrame)
	end

	for i = 1, 6 do
		local button = _G['QuestProgressItem'..i]
		local icon = _G['QuestProgressItem'..i..'IconTexture']
		icon:SetTexCoords()
		icon:Point('TOPLEFT', 2, -2)
		icon:Size(icon:GetWidth() -3, icon:GetHeight() -3)
		button:Width(button:GetWidth() -4)
		button:StripTextures()
		button:OffsetFrameLevel(1)

		local frame = CreateFrame('Frame', nil, button)
		frame:OffsetFrameLevel(-1, button)
		frame:SetTemplate('Transparent', nil, true)
		frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
		frame:SetBackdropColor(0, 0, 0, 0)
		frame:SetOutside(icon)
		button.backdrop = frame

		local hover = button:CreateTexture()
		hover:SetColorTexture(1, 1, 1, 0.3)
		hover:SetAllPoints(icon)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	_G.QuestModelScene:Height(247)
	_G.QuestModelScene:StripTextures()
	_G.QuestModelScene:CreateBackdrop('Transparent')
	_G.QuestModelScene.ModelTextFrame:CreateBackdrop('Transparent')

	_G.QuestNPCModelNameText:ClearAllPoints()
	_G.QuestNPCModelNameText:Point('TOP', G.QuestModelScene, 0, -10)
	_G.QuestNPCModelNameText:FontTemplate(nil, 13, 'OUTLINE')

	_G.QuestNPCModelText:SetJustifyH('CENTER')
	_G.QuestNPCModelTextScrollFrame:ClearAllPoints()
	_G.QuestNPCModelTextScrollFrame:Point('TOPLEFT', _G.QuestModelScene.ModelTextFrame, 2, -2)
	_G.QuestNPCModelTextScrollFrame:Point('BOTTOMRIGHT', _G.QuestModelScene.ModelTextFrame, -10, 6)
	_G.QuestNPCModelTextScrollChildFrame:SetInside(_G.QuestNPCModelTextScrollFrame)

	S:HandleTrimScrollBar(_G.QuestNPCModelTextScrollFrame.ScrollBar)

	local QuestLogPopupDetailFrame = _G.QuestLogPopupDetailFrame
	S:HandleButton(_G.QuestLogPopupDetailFrameAbandonButton)
	S:HandleButton(_G.QuestLogPopupDetailFrameShareButton)
	S:HandleButton(_G.QuestLogPopupDetailFrameTrackButton)
	S:HandlePortraitFrame(QuestLogPopupDetailFrame)

	local showMapButton = QuestLogPopupDetailFrame.ShowMapButton
	if showMapButton then
		S:HandleButton(showMapButton)

		local width, height = showMapButton:GetSize()
		showMapButton:StripTextures()
		showMapButton:Size(width - 30, height)
		showMapButton.Text:ClearAllPoints()
		showMapButton.Text:Point('CENTER')
	end
end

S:AddCallback('BlizzardQuestFrames')
