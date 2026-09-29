local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, gsub = unpack, gsub
local next, strmatch = next, strmatch
local ipairs, strfind = ipairs, strfind
local hooksecurefunc = hooksecurefunc

local GetMoney = GetMoney
local GetQuestID = GetQuestID
local CreateFrame = CreateFrame
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestItemLink = GetQuestItemLink
local GetQuestLogItemLink = GetQuestLogItemLink
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local GetQuestLogTitle = GetQuestLogTitle
local IsQuestComplete = IsQuestComplete

local C_QuestLog_GetRequiredMoney = C_QuestLog.GetRequiredMoney or GetQuestLogRequiredMoney
local C_QuestLog_GetNextWaypointText = C_QuestLog.GetNextWaypointText
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest or GetQuestLogSelectedID
local C_QuestInfoSystem_GetQuestRewardSpells = C_QuestInfoSystem.GetQuestRewardSpells
local GetItemQualityByID = C_Item.GetItemQualityByID

local MAX_NUM_ITEMS = MAX_NUM_ITEMS
local MAX_NUM_QUESTS = MAX_NUM_QUESTS

local LASTINDEX = 1
local TEXTR, TEXTG, TEXTB = 1, 1, 1
local TITLER, TITLEG, TITLEB = 1, 0.80, 0.10

local sealFrameTextColor = {
	['480404'] = 'c20606',
	['042c54'] = '1c86ee',
}

local data = S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'BlizzardQuestFrames', nil, nil, nil, nil, 'quest')

function data:QuestInfoSealFrameText(text)
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

local function HandleReward(frame) -- reward frames are a mix of Large/Small item buttons and plain frames
	if frame.Icon then
		frame.Icon:SetDrawLayer('ARTWORK')
		S:HandleIcon(frame.Icon, true)

		if E.Modern and frame.IconBorder then -- the classic SetItemButtonQuality always hides it
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

local function UpdateRewardQuality() -- classic reward icons show the item quality on their backdrop
	local GetItemLink = _G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink
	for _, questItem in next, _G.QuestInfoFrame.rewardsFrame.RewardButtons do
		local backdrop = questItem.Icon.backdrop
		if backdrop then -- buttons added by QuestInfo_ShowRewards wait for the next QuestInfo_Display
			local link = questItem.type and GetItemLink(questItem.type, questItem:GetID())
			local quality = link and GetItemQualityByID(link)
			local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
			backdrop:SetBackdropBorderColor(r, g, b)
		end
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

function data:QuestInfo_ShowObjectives()
	local objectives = _G.QuestInfoObjectivesFrame.Objectives
	local index = 0

	local questID = Quest_GetQuestID()
	local waypointText = E.Modern and C_QuestLog_GetNextWaypointText(questID) -- classic has no waypoints
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
	local mapFrame = E.Modern and _G.QuestMapFrame:GetParent() -- the classic quest maps never show the portrait
	_G.QuestModelScene:ClearAllPoints()
	_G.QuestModelScene:Point('TOPLEFT', frame, 'TOPRIGHT', (x or 0) + (frame == mapFrame and 11 or 6), y or 0)
end

local function ShowQuestNPCModel(frame, _, _, _, _, x, y) -- vanilla passes no model scene id
	_G.QuestNPCModel:ClearAllPoints()
	_G.QuestNPCModel:Point('TOPLEFT', frame, 'TOPRIGHT', (x or 0) + 6, y or 0)
end

function data:QuestInfoItem_OnClick() -- self is not data
	if self.type ~= 'choice' then return end -- Blizzard only highlights choices

	_G.QuestInfoItemHighlight:ClearAllPoints()
	_G.QuestInfoItemHighlight:SetOutside(self.Icon)

	for _, Button in ipairs(_G.QuestInfoRewardsFrame.RewardButtons) do
		Button.Name:SetTextColor(1, 1, 1)
	end

	self.Name:SetTextColor(1, .8, .1)
end

function data:QuestInfo_Display(parentFrame) -- self is template, not data
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

	if not E.Modern then
		UpdateRewardQuality()
	end

	-- the classic quest logs stay stripped with the remover off
	local lightText = E.private.skins.parchmentRemoverEnable or (not E.Modern and _G.QuestInfoFrame.questLog)

	local questID = Quest_GetQuestID()
	local spellRewards = C_QuestInfoSystem_GetQuestRewardSpells(questID)
	if spellRewards and (#spellRewards > 0) then
		if lightText then
			for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
				spellHeader:SetVertexColor(1, 1, 1)
			end
		end

		-- only the mainline and vanilla QuestSpellTemplate carry the spellbook border, map rewards are small item buttons
		local spellBorders = (E.Modern or E.Classic) and rewardsFrame == _G.QuestInfoRewardsFrame
		for spellIcon in rewardsFrame.spellRewardPool:EnumerateActive() do
			HandleReward(spellIcon)

			if spellBorders then
				local _, _, spellBorder = spellIcon:GetRegions() -- Icon, NameFrame, SpellBorder
				spellBorder:SetTexture(E.ClearTexture)
			end
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

	if E.Modern then -- MajorFaction Rewards thing
		for spellIcon in rewardsFrame.reputationRewardPool:EnumerateActive() do
			HandleReward(spellIcon)
		end
	end

	if lightText then
		_G.QuestInfoTitleHeader:SetTextColor(1, .8, .1)
		_G.QuestInfoDescriptionHeader:SetTextColor(1, .8, .1)
		_G.QuestInfoObjectivesHeader:SetTextColor(1, .8, .1)
		_G.QuestInfoRewardsFrame.Header:SetTextColor(1, .8, .1)
		_G.QuestInfoDescriptionText:SetTextColor(1, 1, 1)
		_G.QuestInfoObjectivesText:SetTextColor(1, 1, 1)
		_G.QuestInfoGroupSize:SetTextColor(1, 1, 1)
		_G.QuestInfoRewardText:SetTextColor(1, 1, 1)
		_G.QuestInfoTimerText:SetTextColor(1, 1, 1)
		_G.QuestInfoQuestType:SetTextColor(1, 1, 1)
		_G.QuestInfoRewardsFrame.ItemChooseText:SetTextColor(1, 1, 1)
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1, 1, 1)

		if not (E.Wrath or E.Mists) then -- wrath and mists have it on the map rewards only
			_G.QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(1, 1, 1)
		end

		_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(1, 1, 1)

		if E.Wrath or E.Mists then -- talent and arena point rewards
			_G.QuestInfoTalentFrame.ReceiveText:SetTextColor(1, 1, 1)
			_G.QuestInfoRewardsFrameReceiveText:SetTextColor(1, 1, 1)
		end

		if E.TBC or E.Wrath or E.Mists then -- honor is a text line with the faction crest here
			_G.QuestInfoRewardsFrameHonorReceiveText:SetTextColor(1, 1, 1)
		end

		data:QuestInfo_ShowObjectives()
		data:QuestInfo_ShowRequiredMoney()
	else
		_G.QuestInfoTitleHeader:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoDescriptionHeader:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoObjectivesHeader:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardsFrame.Header:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoDescriptionText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoObjectivesText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoGroupSize:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoTimerText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoQuestType:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardsFrame.ItemChooseText:SetShadowColor(0, 0, 0, 0)
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetShadowColor(0, 0, 0, 0)
	end
end

function data:QuestFrameProgressItems_Update() -- self is not data
	_G.QuestProgressRequiredItemsText:SetTextColor(1, .8, .1)
	_G.QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
end

function data:QuestFrame_SetTitleTextColor() -- self is fontString
	self:SetTextColor(1, .8, .1)
end

function data:QuestFrame_SetTextColor() -- self is fontString
	self:SetTextColor(1, 1, 1)
end

function data:QuestInfo_ShowRequiredMoney()
	local requiredMoney = C_QuestLog_GetRequiredMoney()
	if requiredMoney > 0 then
		local moneyText = _G.QuestInfoRequiredMoneyFrame:GetRegions() -- the QuestInfoRequiredMoneyText global is a later, unanchored copy
		if requiredMoney > GetMoney() then
			moneyText:SetTextColor(.63, .09, .09)
		else
			moneyText:SetTextColor(1, .8, .1)
		end
	end
end

-- parchment remover off: fit the page art of a QuestFramePanelTemplate frame into its scroll frame
local function QuestPanelParchment(panel, scrollFrame)
	if E.Modern then
		panel.Bg:SetInside(scrollFrame)
		panel.Bg:SetAlpha(1)
		panel.Bg:SetDrawLayer('BACKGROUND', 1) -- the popup frame carries its own ElvUI backdrop

		panel.SealMaterialBG:SetInside(scrollFrame)
		panel.SealMaterialBG:SetAlpha(1)

		-- stone, marble and bronze letters, same origin as the parchment
		panel.MaterialTopLeft:Point('TOPLEFT', panel.Bg)
		panel.MaterialTopLeft:SetAlpha(1)
		panel.MaterialTopRight:SetAlpha(1)
		panel.MaterialBotLeft:SetAlpha(1)
		panel.MaterialBotRight:SetAlpha(1)
	else
		-- classic panels show the page inside a larger file (vanilla inside its frame art), crop QuestBG like the gossip skin
		local parchment = panel:CreateTexture(nil, 'BACKGROUND', nil, 1)
		parchment:SetTexture([[Interface\QuestFrame\QuestBG]])
		parchment:SetTexCoord(0, 0.586, 0.02, 0.655)
		parchment:SetInside(scrollFrame)

		local name = panel:GetName()
		local materialTopLeft = _G[name..'MaterialTopLeft']
		materialTopLeft:Point('TOPLEFT', parchment)
		materialTopLeft:SetAlpha(1)
		_G[name..'MaterialTopRight']:SetAlpha(1)
		_G[name..'MaterialBotLeft']:SetAlpha(1)
		_G[name..'MaterialBotRight']:SetAlpha(1)
	end

	scrollFrame.Center:Hide()
end

local function HandleItemButton(item)
	item:SetTemplate()
	item:Size(143, 40)
	item:OffsetFrameLevel(2)

	item.Icon:Size(E.PixelMode and 35 or 32)
	item.Icon:SetDrawLayer('ARTWORK')
	item.Icon:Point('TOPLEFT', E.PixelMode and 2 or 4, -(E.PixelMode and 2 or 4))
	S:HandleIcon(item.Icon)

	item.Count:SetDrawLayer('OVERLAY')
	item.Count:ClearAllPoints()
	item.Count:SetPoint('BOTTOMRIGHT', item.Icon, 'BOTTOMRIGHT', 0, 0)

	item.NameFrame:SetAlpha(0)
	item.NameFrame:Hide()
	item.Name:FontTemplate()
end

local function HandleQualityColors(frame, text, link)
	if not frame.template then
		HandleItemButton(frame)
	end

	local quality = GetItemQualityByID(link or 0)
	if quality and quality > 1 then
		local r, g, b = E:GetItemQualityColor(quality)

		text:SetTextColor(r, g, b)
		frame:SetBackdropBorderColor(r, g, b)
	else
		text:SetTextColor(1, 1, 1)
		frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function UpdateGreetingFrame()
	local i = 1
	local title = _G['QuestTitleButton'..i]
	while (title and title:IsVisible()) do
		_G.GreetingText:SetTextColor(1, 1, 1)
		_G.CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
		_G.AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

		local text = title:GetFontString()
		local textString = gsub(title:GetText(), '|c[Ff][Ff]%x%x%x%x%x%x(.+)|r', '%1')
		title:SetText(textString)

		local icon = _G['QuestTitleButton'..i..'QuestIcon']
		if title.isActive == 1 then
			icon:SetTexture(132048)
			icon:SetDesaturation(1)
			text:SetTextColor(.6, .6, .6)
		else
			icon:SetTexture(132049)
			icon:SetDesaturation(0)
			text:SetTextColor(1, .8, .1)
		end

		local numEntries = GetNumQuestLogEntries()
		for y = 1, numEntries do
			local titleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(y)
			if not titleText then
				break
			elseif strmatch(titleText, textString) and (isComplete == 1 or IsQuestComplete(questId)) then
				icon:SetDesaturation(0)
				text:SetTextColor(1, .8, .1)
				break
			end
		end

		i = i + 1
		title = _G['QuestTitleButton'..i]
	end
end

local function QuestLogUpdate()
	if not _G.QuestLogFrame:IsShown() then return end

	local buttons = _G.QuestLogListScrollFrame.buttons
	local numDisplayed = (E.Mists or E.Wrath) and #buttons or _G.QUESTS_DISPLAYED -- get changed by other addons, keep it global
	if LASTINDEX < numDisplayed then
		for i = LASTINDEX, numDisplayed do
			local title = (E.Mists or E.Wrath) and buttons[i] or _G['QuestLogTitle'..i]
			S:HandleCollapseTexture(title, nil, true)

			local normal = title:GetNormalTexture()
			normal:Size(16)

			local highlight = title:GetHighlightTexture()
			highlight:SetAlpha(0)
		end

		LASTINDEX = numDisplayed
	end
end

local function UpdateQuestCount()
	_G.QuestLogCount:ClearAllPoints()
	_G.QuestLogCount:Point('BOTTOMLEFT', _G.QuestLogListScrollFrame.backdrop, 'TOPLEFT', 0, 5)
end

local function UpdateQuestDetails()
	-- Headers
	_G.QuestLogDescriptionTitle:SetTextColor(TITLER, TITLEG, TITLEB)
	_G.QuestLogRewardTitleText:SetTextColor(TITLER, TITLEG, TITLEB)
	_G.QuestLogQuestTitle:SetTextColor(TITLER, TITLEG, TITLEB)

	-- Other text
	_G.QuestLogItemChooseText:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestLogItemReceiveText:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestLogObjectivesText:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestLogQuestDescription:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestLogSpellLearnText:SetTextColor(TEXTR, TEXTG, TEXTB)

	if E.TBC then -- suggested group size and honor rewards
		_G.QuestLogSuggestedGroupNum:SetTextColor(TEXTR, TEXTG, TEXTB)
		_G.QuestLogHonorFrameHonorReceiveText:SetTextColor(TEXTR, TEXTG, TEXTB)
	end

	local requiredMoney = GetQuestLogRequiredMoney()
	if requiredMoney > 0 then
		if requiredMoney > GetMoney() then
			_G.QuestLogRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
		else
			_G.QuestLogRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
		end
	end

	_G.QuestLogItem1:Point('TOPLEFT', _G.QuestLogItemChooseText, 'BOTTOMLEFT', 1, -3)

	for i = 1, GetNumQuestLeaderBoards() do
		local _, _, finished = GetQuestLogLeaderBoard(i)
		local objective = _G['QuestLogObjective'..i]
		if finished then
			objective:SetTextColor(1, .8, .1)
		else
			objective:SetTextColor(.63, .09, .09)
		end
	end

	for i = 1, MAX_NUM_ITEMS do
		local item = _G['QuestLogItem'..i]
		local name = _G['QuestLogItem'..i..'Name']
		local link = item.type and GetQuestLogItemLink(item.type, item:GetID())

		HandleQualityColors(item, name, link)
	end
end

local function SkinQuestLogFrame()
	for _, object in next, { _G.EmptyQuestLogFrame, _G.QuestLogDetailScrollFrame, _G.QuestLogFrame, _G.QuestLogListScrollFrame } do
		object:StripTextures(true)
	end

	S:HandleButton(_G.QuestFramePushQuestButton, true)
	S:HandleButton(_G.QuestLogFrameAbandonButton, true)

	S:HandleScrollBar(_G.QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestLogListScrollFrameScrollBar)

	hooksecurefunc('QuestLog_Update', QuestLogUpdate)

	if not E.Classic then
		S:HandleFrame(_G.QuestLogCount)
	end

	S:HandleFrame(_G.QuestLogListScrollFrame, true, nil, -2, 2)
	S:HandleFrame(_G.QuestLogDetailScrollFrame, true, nil, -2, 2)

	_G.QuestLogListScrollFrame:Width(303)
	_G.QuestLogDetailScrollFrame:Width(303)
	_G.QuestLogFrameAbandonButton:Width(129)

	_G.QuestLogHighlightFrame:Width(303)
	_G.QuestLogHighlightFrame.SetWidth = E.noop

	_G.QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)

	if E.Mists or E.Wrath then
		S:HandleButton(_G.QuestLogFrameTrackButton, true)
		S:HandleButton(_G.QuestLogFrameCancelButton, true)

		hooksecurefunc('QuestLogUpdateQuestCount', UpdateQuestCount)

		_G.QuestFramePushQuestButton:ClearAllPoints()
		_G.QuestFramePushQuestButton:Point('LEFT', _G.QuestLogFrameAbandonButton, 'RIGHT', 1, 0)
		_G.QuestFramePushQuestButton:Point('RIGHT', _G.QuestLogFrameTrackButton, 'LEFT', -1, 0)

		S:HandleFrame(_G.QuestLogDetailFrame, true)
		S:HandleFrame(_G.QuestLogFrame)

		_G.QuestLogFrameCancelButton:PointXY(-4, 4)
		_G.QuestFramePushQuestButton:PointXY(1)

		_G.QuestLogSkillHighlight:SetAlpha(0.3)
	else
		S:HandleButton(_G.QuestFrameExitButton, true)

		for i = 1, MAX_NUM_ITEMS do
			HandleItemButton(_G['QuestLogItem'..i])
		end

		_G.QuestLogTimerText:SetTextColor(1, 1, 1)

		hooksecurefunc('QuestLog_UpdateQuestDetails', UpdateQuestDetails)

		S:HandleFrame(_G.QuestLogFrame, true, nil, 8, -10, -28, 42)

		_G.QuestLogFrameAbandonButton:PointXY(15, 49)
		_G.QuestFramePushQuestButton:PointXY(-2)
		_G.QuestFrameExitButton:PointXY(-36, 49)

		_G.QuestLogSkillHighlight:SetAlpha(0.35)

		local QuestLogCollapseAllButton = _G.QuestLogCollapseAllButton
		S:HandleCollapseTexture(QuestLogCollapseAllButton, nil, true)

		QuestLogCollapseAllButton:StripTextures()
		QuestLogCollapseAllButton:Point('TOPLEFT', -45, 7)
		QuestLogCollapseAllButton:SetHighlightTexture(E.ClearTexture)

		local normal = QuestLogCollapseAllButton:GetNormalTexture()
		normal:Size(16)
	end
end

function S:BlizzardQuestFrames()
	if E.Modern then
		S:HandleTrimScrollBar(_G.QuestProgressScrollFrame.ScrollBar)
		S:HandleTrimScrollBar(_G.QuestRewardScrollFrame.ScrollBar)
		S:HandleTrimScrollBar(_G.QuestDetailScrollFrame.ScrollBar)
		S:HandleTrimScrollBar(_G.QuestGreetingScrollFrame.ScrollBar)
		S:HandleTrimScrollBar(_G.QuestLogPopupDetailFrameScrollFrame.ScrollBar)
	else
		S:HandleScrollBar(_G.QuestProgressScrollFrameScrollBar)
		S:HandleScrollBar(_G.QuestRewardScrollFrameScrollBar)
		S:HandleScrollBar(_G.QuestDetailScrollFrameScrollBar)
		S:HandleScrollBar(_G.QuestGreetingScrollFrameScrollBar)
	end

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

	hooksecurefunc('QuestInfo_Display', data.QuestInfo_Display)
	hooksecurefunc('QuestInfoItem_OnClick', data.QuestInfoItem_OnClick)

	if not E.Modern then -- QUEST_ITEM_UPDATE refreshes the rewards without QuestInfo_Display
		hooksecurefunc('QuestInfo_ShowRewards', UpdateRewardQuality)
	end

	-- tbc, wrath and mists show honor as a text line with the faction crest, war mode is mainline only
	for _, frame in next, { (E.Modern or E.Classic) and 'HonorFrame' or nil, 'XPFrame', 'SkillPointFrame', 'ArtifactXPFrame', 'TitleFrame', E.Modern and 'WarModeBonusFrame' or nil } do
		HandleReward(_G.MapQuestInfoRewardsFrame[frame])
		HandleReward(_G.QuestInfoRewardsFrame[frame])
	end
	HandleReward(_G.MapQuestInfoRewardsFrame.MoneyFrame)

	--Reward: Title
	local QuestInfoPlayerTitleFrame = _G.QuestInfoPlayerTitleFrame
	if E.Wrath or E.Mists then -- QuestPlayerTitleFrameTemplate has no texture keys
		local icon, frameLeft, frameCenter, frameRight = QuestInfoPlayerTitleFrame:GetRegions() -- IconTexture, TitleFrameLeft, TitleFrameCenter and the unnamed right piece
		frameLeft:SetTexture()
		frameCenter:SetTexture()
		frameRight:SetTexture()
		S:HandleIcon(icon, true)
	else
		QuestInfoPlayerTitleFrame.FrameLeft:SetTexture()
		QuestInfoPlayerTitleFrame.FrameCenter:SetTexture()
		QuestInfoPlayerTitleFrame.FrameRight:SetTexture()
		QuestInfoPlayerTitleFrame.Icon:SetTexCoords()
	end

	--Quest Frame
	local QuestFrame = _G.QuestFrame
	if E.Classic then -- the vanilla frame is no ButtonFrameTemplate, its art keeps an empty margin
		S:HandleFrame(QuestFrame, true, nil, 8, -10, -28, 66)

		_G.QuestFrameAcceptButton:PointXY(15, 70)
		_G.QuestFrameDeclineButton:PointXY(-36, 70)
		_G.QuestFrameCompleteQuestButton:PointXY(15, 70)
		_G.QuestFrameCompleteButton:PointXY(15, 70)
		_G.QuestFrameCancelButton:PointXY(-36, 70)
		_G.QuestFrameGoodbyeButton:PointXY(-36, 70)
		_G.QuestFrameGreetingGoodbyeButton:PointXY(-36, 70)
	else
		S:HandlePortraitFrame(QuestFrame)
	end

	S:HandleButton(_G.QuestFrameAcceptButton, true)
	S:HandleButton(_G.QuestFrameCompleteButton, true)
	S:HandleButton(_G.QuestFrameCompleteQuestButton, true)
	S:HandleButton(_G.QuestFrameDeclineButton, true)
	S:HandleButton(_G.QuestFrameGoodbyeButton, true)
	S:HandleButton(_G.QuestFrameGreetingGoodbyeButton, true)

	if not E.Modern then
		S:HandleButton(_G.QuestFrameCancelButton, true)

		_G.QuestFrameNpcNameText:PointXY(-1, 0)
	end

	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestFrameDetailPanel:StripTextures(nil, true)
	_G.QuestFrameGreetingPanel:StripTextures(nil, true)
	_G.QuestFrameProgressPanel:StripTextures(nil, true)
	_G.QuestFrameRewardPanel:StripTextures(nil, true)

	_G.QuestDetailScrollFrame:StripTextures(nil, true)
	_G.QuestGreetingScrollFrame:StripTextures(nil, true)
	_G.QuestProgressScrollFrame:StripTextures(nil, true)
	_G.QuestRewardScrollFrame:StripTextures(nil, true)

	_G.QuestDetailScrollChildFrame:StripTextures(nil, true)
	_G.QuestRewardScrollChildFrame:StripTextures(nil, true)

	if E.Modern then
		_G.QuestLogPopupDetailFrameScrollFrame:StripTextures(nil, true)

		_G.QuestFrameGreetingPanel:HookScript('OnShow', GreetingPanel_OnShow) -- called when actually shown
		hooksecurefunc('QuestFrameGreetingPanel_OnShow', GreetingPanel_OnShow) -- called through QUEST_LOG_UPDATE
	else
		for i = 1, MAX_NUM_QUESTS do
			local icon = _G['QuestTitleButton'..i..'QuestIcon']
			icon:SetPoint('TOPLEFT', 4, 2)
			icon:SetSize(16, 16)
		end

		if E.private.skins.parchmentRemoverEnable then
			_G.QuestFrameGreetingPanel:HookScript('OnUpdate', UpdateGreetingFrame)
			hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)
		end
	end

	hooksecurefunc('QuestFrame_ShowQuestPortrait', E.Classic and ShowQuestNPCModel or ShowQuestPortrait)

	local modelTextFrame = E.Modern and _G.QuestModelScene.ModelTextFrame or _G.QuestNPCModelTextFrame
	if E.private.skins.parchmentRemoverEnable then
		hooksecurefunc('QuestFrameProgressItems_Update', data.QuestFrameProgressItems_Update)
		hooksecurefunc('QuestFrame_SetTitleTextColor', data.QuestFrame_SetTitleTextColor)
		hooksecurefunc('QuestFrame_SetTextColor', data.QuestFrame_SetTextColor)
		hooksecurefunc(_G.QuestInfoSealFrame.Text, 'SetText', data.QuestInfoSealFrameText)

		_G.QuestDetailScrollFrame:SetTemplate('NoBackdrop')
		_G.QuestProgressScrollFrame:SetTemplate('NoBackdrop')
		_G.QuestGreetingScrollFrame:SetTemplate('NoBackdrop')
		_G.QuestRewardScrollFrame:SetTemplate('NoBackdrop')

		if E.Modern then
			_G.QuestLogPopupDetailFrameScrollFrame:SetTemplate('NoBackdrop')

			_G.QuestLogPopupDetailFrame.Bg:SetAlpha(0) -- Blizzard sets the atlas again whenever the popup shows a quest
			_G.QuestLogPopupDetailFrame.SealMaterialBG:SetAlpha(0)
		end

		modelTextFrame:StripTextures()
		_G.QuestNPCModelText:SetTextColor(1, 1, 1)
	else
		_G.QuestDetailScrollFrame:SetTemplate('Transparent')
		_G.QuestProgressScrollFrame:SetTemplate('Transparent')
		_G.QuestGreetingScrollFrame:SetTemplate('Transparent')
		_G.QuestRewardScrollFrame:SetTemplate('Transparent')

		QuestPanelParchment(_G.QuestFrameDetailPanel, _G.QuestDetailScrollFrame)
		QuestPanelParchment(_G.QuestFrameRewardPanel, _G.QuestRewardScrollFrame)
		QuestPanelParchment(_G.QuestFrameProgressPanel, _G.QuestProgressScrollFrame)
		QuestPanelParchment(_G.QuestFrameGreetingPanel, _G.QuestGreetingScrollFrame)

		if E.Modern then
			_G.QuestLogPopupDetailFrameScrollFrame:SetTemplate('Transparent')
			QuestPanelParchment(_G.QuestLogPopupDetailFrame, _G.QuestLogPopupDetailFrameScrollFrame)
		end

		S:HandleBlizzardRegions(modelTextFrame)

		if not E.Modern then -- the classic text frame takes the template itself, keep the stone above its Center
			_G.QuestNPCModelTextFrameBg:SetDrawLayer('BACKGROUND', 1)
		end
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

	local modelScene = E.Classic and _G.QuestNPCModel or _G.QuestModelScene
	modelScene:StripTextures()

	if E.Modern then
		modelScene:Height(247)
		modelScene:CreateBackdrop('Transparent')
		modelTextFrame:CreateBackdrop('Transparent')
	else
		modelScene:SetTemplate('Transparent')
		modelTextFrame:SetTemplate('Transparent')
		modelTextFrame:ClearAllPoints()
		modelTextFrame:Point('BOTTOM', modelScene, 0, -66)
	end

	_G.QuestNPCModelNameText:ClearAllPoints()
	_G.QuestNPCModelNameText:Point('TOP', modelScene, 0, -10)
	_G.QuestNPCModelNameText:FontTemplate(nil, 13, 'OUTLINE')

	_G.QuestNPCModelText:SetJustifyH('CENTER')
	_G.QuestNPCModelTextScrollFrame:ClearAllPoints()
	_G.QuestNPCModelTextScrollFrame:Point('TOPLEFT', modelTextFrame, 2, -2)
	_G.QuestNPCModelTextScrollFrame:Point('BOTTOMRIGHT', modelTextFrame, -10, 6)
	_G.QuestNPCModelTextScrollChildFrame:SetInside(_G.QuestNPCModelTextScrollFrame)

	if E.Modern then
		S:HandleTrimScrollBar(_G.QuestNPCModelTextScrollFrame.ScrollBar)

		local QuestLogPopupDetailFrame = _G.QuestLogPopupDetailFrame
		S:HandleButton(_G.QuestLogPopupDetailFrameAbandonButton)
		S:HandleButton(_G.QuestLogPopupDetailFrameShareButton)
		S:HandleButton(_G.QuestLogPopupDetailFrameTrackButton)
		S:HandlePortraitFrame(QuestLogPopupDetailFrame)

		local showMapButton = QuestLogPopupDetailFrame.ShowMapButton
		S:HandleButton(showMapButton)

		local width, height = showMapButton:GetSize()
		showMapButton:StripTextures()
		showMapButton:Size(width - 30, height)
		showMapButton.Text:ClearAllPoints()
		showMapButton.Text:Point('CENTER')
	else
		S:HandleScrollBar(_G.QuestNPCModelTextScrollFrame.ScrollBar)

		SkinQuestLogFrame()
	end
end
