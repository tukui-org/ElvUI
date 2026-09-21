local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, gsub = unpack, gsub
local pairs, next, strmatch = pairs, next, strmatch
local hooksecurefunc = hooksecurefunc

local GetMoney = GetMoney
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestItemLink = GetQuestItemLink
local GetQuestLogItemLink = GetQuestLogItemLink
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestMoneyToGet = GetQuestMoneyToGet
local IsQuestComplete = IsQuestComplete

local GetItemQualityByID = C_Item.GetItemQualityByID

local MAX_NUM_ITEMS = MAX_NUM_ITEMS
local MAX_NUM_QUESTS = MAX_NUM_QUESTS
local MAX_REQUIRED_ITEMS = MAX_REQUIRED_ITEMS

local LASTINDEX = 1
local TEXTR, TEXTG, TEXTB = 1, 1, 1
local TITLER, TITLEG, TITLEB = 1, 0.80, 0.10

local function HandleItemButton(item)
	item:SetTemplate()
	item:Size(143, 40)
	item:OffsetFrameLevel(2)

	item.Icon:Size(E.PixelMode and 35 or 32)
	item.Icon:SetDrawLayer('ARTWORK')
	item.Icon:Point('TOPLEFT', E.PixelMode and 2 or 4, -(E.PixelMode and 2 or 4))
	S:HandleIcon(item.Icon)

	if item.IconBorder then -- reward items only, progress, quest log and spell reward items have none
		S:HandleIconBorder(item.IconBorder)
		item.IconOverlay:SetAlpha(0)
	end

	if item.Count then -- spell rewards have none
		item.Count:SetDrawLayer('OVERLAY')
		item.Count:ClearAllPoints()
		item.Count:SetPoint('BOTTOMRIGHT', item.Icon, 'BOTTOMRIGHT', 0, 0)
	end

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

local function ShowQuestPortrait(frame, _, _, _, _, _, x, y)
	_G.QuestModelScene:ClearAllPoints()
	_G.QuestModelScene:Point('TOPLEFT', frame, 'TOPRIGHT', (x or 0) + 6, y or 0)
end

local function GetRewardButton(rewardsFrame, index)
	local button = rewardsFrame.RewardButtons[index]
	if not button.template then
		HandleItemButton(button)
	end
end

local function UpdateRewardButtons(selected)
	for _, item in next, _G.QuestInfoRewardsFrame.RewardButtons do
		if item ~= selected then
			local link = item.type and GetQuestItemLink(item.type, item:GetID())
			HandleQualityColors(item, item.Name, link)
		end
	end
end

local function ItemOnClick(frame)
	if frame.type == 'choice' then
		frame:SetBackdropBorderColor(1, 0.80, 0.10)
		frame.Name:SetTextColor(1, 0.80, 0.10)

		UpdateRewardButtons(frame)
	end
end

local function ProgressItemsUpdate()
	_G.QuestProgressTitleText:SetTextColor(1, .8, .1)
	_G.QuestProgressText:SetTextColor(1, 1, 1)
	_G.QuestProgressRequiredItemsText:SetTextColor(1, .8, 0.1)

	local moneyToGet = GetQuestMoneyToGet()
	if moneyToGet > 0 then
		if moneyToGet > GetMoney() then
			_G.QuestProgressRequiredMoneyText:SetTextColor(.6, .6, .6)
		else
			_G.QuestProgressRequiredMoneyText:SetTextColor(1, .8, .1)
		end
	end

	for i = 1, MAX_REQUIRED_ITEMS do
		local item = _G['QuestProgressItem'..i]
		local name = _G['QuestProgressItem'..i..'Name']
		local link = item.type and GetQuestItemLink(item.type, item:GetID())

		HandleQualityColors(item, name, link)
	end
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
	_G.QuestLogSuggestedGroupNum:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestLogQuestDescription:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestLogSpellLearnText:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestLogHonorFrameHonorReceiveText:SetTextColor(TEXTR, TEXTG, TEXTB)

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

local function QuestLogUpdate()
	if not _G.QuestLogFrame:IsShown() then return end

	local numDisplayed = _G.QUESTS_DISPLAYED -- get changed by other addons, keep it global
	if LASTINDEX < numDisplayed then
		for i = LASTINDEX, numDisplayed do
			local title = _G['QuestLogTitle'..i]
			S:HandleCollapseTexture(title, nil, true)

			local normal = title:GetNormalTexture()
			normal:Size(16)

			local highlight = title:GetHighlightTexture()
			highlight:SetAlpha(0)
		end

		LASTINDEX = numDisplayed
	end
end

local function QuestInfoDisplay()
	local rewardsFrame = _G.QuestInfoRewardsFrame

	-- Headers
	_G.QuestInfoTitleHeader:SetTextColor(TITLER, TITLEG, TITLEB)
	_G.QuestInfoObjectivesHeader:SetTextColor(TITLER, TITLEG, TITLEB)
	rewardsFrame.Header:SetTextColor(TITLER, TITLEG, TITLEB)

	-- Other text
	_G.QuestInfoDescriptionText:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestInfoObjectivesText:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestInfoGroupSize:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestInfoRewardText:SetTextColor(TEXTR, TEXTG, TEXTB)

	-- Reward frame text
	rewardsFrame.ItemChooseText:SetTextColor(TEXTR, TEXTG, TEXTB)
	rewardsFrame.ItemReceiveText:SetTextColor(TEXTR, TEXTG, TEXTB)
	_G.QuestInfoRewardsFrameHonorReceiveText:SetTextColor(TEXTR, TEXTG, TEXTB)

	local spellHeaderPool = rewardsFrame.spellHeaderPool
	spellHeaderPool.textR, spellHeaderPool.textG, spellHeaderPool.textB = TEXTR, TEXTG, TEXTB

	for spellHeader in spellHeaderPool:EnumerateActive() do
		spellHeader:SetVertexColor(1, 1, 1)
	end

	for spellIcon in rewardsFrame.spellRewardPool:EnumerateActive() do
		if not spellIcon.template then
			HandleItemButton(spellIcon)
		end
	end

	UpdateRewardButtons()
end

function S:BlizzardQuestFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.quest) then return end

	local QuestStrip = {
		_G.EmptyQuestLogFrame,
		_G.QuestDetailScrollChildFrame,
		_G.QuestDetailScrollFrame,
		_G.QuestFrame,
		_G.QuestFrameDetailPanel,
		_G.QuestFrameGreetingPanel,
		_G.QuestFrameProgressPanel,
		_G.QuestFrameRewardPanel,
		_G.QuestGreetingScrollFrame,
		_G.QuestInfoItemHighlight,
		_G.QuestLogDetailScrollFrame,
		_G.QuestLogFrame,
		_G.QuestLogListScrollFrame,
		_G.QuestProgressScrollFrame,
		_G.QuestRewardScrollChildFrame,
		_G.QuestRewardScrollFrame
	}
	for _, object in pairs(QuestStrip) do
		object:StripTextures(true)
	end

	local QuestButtons = {
		_G.QuestFrameAcceptButton,
		_G.QuestFrameCancelButton,
		_G.QuestFrameCompleteButton,
		_G.QuestFrameCompleteQuestButton,
		_G.QuestFrameDeclineButton,
		_G.QuestFrameExitButton,
		_G.QuestFrameGoodbyeButton,
		_G.QuestFrameGreetingGoodbyeButton,
		_G.QuestFramePushQuestButton,
		_G.QuestLogFrameAbandonButton
	}
	for _, button in pairs(QuestButtons) do
		button:StripTextures()
		S:HandleButton(button)
	end

	local ScrollBars = {
		_G.QuestDetailScrollFrameScrollBar,
		_G.QuestGreetingScrollFrameScrollBar,
		_G.QuestLogDetailScrollFrameScrollBar,
		_G.QuestLogListScrollFrameScrollBar,
		_G.QuestProgressScrollFrameScrollBar,
		_G.QuestRewardScrollFrameScrollBar
	}
	for _, object in pairs(ScrollBars) do
		S:HandleScrollBar(object)
	end

	for frame, numItems in pairs({ QuestLogItem = MAX_NUM_ITEMS, QuestProgressItem = MAX_REQUIRED_ITEMS }) do
		for i = 1, numItems do
			HandleItemButton(_G[frame..i])
		end
	end

	_G.QuestLogTimerText:SetTextColor(1, 1, 1)

	_G.QuestModelScene:StripTextures()
	_G.QuestModelScene:SetTemplate('Transparent')

	_G.QuestNPCModelTextFrame:StripTextures()
	_G.QuestNPCModelTextFrame:SetTemplate('Transparent')
	_G.QuestNPCModelTextFrame:ClearAllPoints()
	_G.QuestNPCModelTextFrame:Point('BOTTOM', _G.QuestModelScene, 0, -66)

	_G.QuestNPCModelNameText:ClearAllPoints()
	_G.QuestNPCModelNameText:Point('TOP', _G.QuestModelScene, 0, -10)
	_G.QuestNPCModelNameText:FontTemplate(nil, 13, 'OUTLINE')

	_G.QuestNPCModelText:SetJustifyH('CENTER')
	_G.QuestNPCModelTextScrollFrame:ClearAllPoints()
	_G.QuestNPCModelTextScrollFrame:Point('TOPLEFT', _G.QuestNPCModelTextFrame, 2, -2)
	_G.QuestNPCModelTextScrollFrame:Point('BOTTOMRIGHT', _G.QuestNPCModelTextFrame, -10, 6)
	_G.QuestNPCModelTextScrollChildFrame:SetInside(_G.QuestNPCModelTextScrollFrame)

	S:HandleScrollBar(_G.QuestNPCModelTextScrollFrame.ScrollBar)

	_G.QuestFrameGreetingPanel:HookScript('OnUpdate', UpdateGreetingFrame)
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)
	hooksecurefunc('QuestFrame_ShowQuestPortrait', ShowQuestPortrait)
	hooksecurefunc('QuestFrameProgressItems_Update', ProgressItemsUpdate)
	hooksecurefunc('QuestInfo_Display', QuestInfoDisplay)
	hooksecurefunc('QuestInfo_GetRewardButton', GetRewardButton)
	hooksecurefunc('QuestInfo_ShowRewards', UpdateRewardButtons)
	hooksecurefunc('QuestInfoItem_OnClick', ItemOnClick)
	hooksecurefunc('QuestLog_Update', QuestLogUpdate)
	hooksecurefunc('QuestLog_UpdateQuestDetails', UpdateQuestDetails)

	for i = 1, MAX_NUM_QUESTS do
		local icon = _G['QuestTitleButton'..i..'QuestIcon']
		icon:SetPoint('TOPLEFT', 4, 2)
		icon:SetSize(16, 16)
	end

	S:HandleFrame(_G.QuestFrame)
	S:HandleFrame(_G.QuestLogCount)
	S:HandleFrame(_G.QuestLogFrame, true, nil, 8, -10, -28, 42)
	S:HandleFrame(_G.QuestLogListScrollFrame, true, nil, -2, 2)
	S:HandleFrame(_G.QuestLogDetailScrollFrame, true, nil, -2, 2)
	S:HandleFrame(_G.QuestDetailScrollFrame, true, nil, 2, -2)
	S:HandleFrame(_G.QuestRewardScrollFrame, true, nil, 2, -2)
	S:HandleFrame(_G.QuestProgressScrollFrame, true, nil, 2, -2)
	S:HandleFrame(_G.QuestGreetingScrollFrame, true, nil, 2, -2)

	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestLogFrameAbandonButton:PointXY(15, 49)
	_G.QuestFramePushQuestButton:PointXY(-2)
	_G.QuestFrameExitButton:PointXY(-36, 49)
	_G.QuestFrameAcceptButton:PointXY(7, 4)
	_G.QuestFrameDeclineButton:PointXY(-7, 4)
	_G.QuestFrameCompleteQuestButton:PointXY(7, 4)
	_G.QuestFrameCompleteButton:PointXY(8, 4)
	_G.QuestFrameCancelButton:PointXY(-10, 4)
	_G.QuestFrameGoodbyeButton:PointXY(-32, 4)
	_G.QuestFrameGreetingGoodbyeButton:PointXY(-32, 4)
	_G.QuestFrameNpcNameText:PointXY(-1, 0)

	_G.QuestLogListScrollFrame:Width(303)
	_G.QuestLogDetailScrollFrame:Width(303)
	_G.QuestLogFrameAbandonButton:Width(129)

	_G.QuestLogHighlightFrame:Width(303)
	_G.QuestLogHighlightFrame.SetWidth = E.noop

	_G.QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	_G.QuestLogSkillHighlight:SetAlpha(0.35)

	local QuestLogCollapseAllButton = _G.QuestLogCollapseAllButton
	S:HandleCollapseTexture(QuestLogCollapseAllButton, nil, true)

	QuestLogCollapseAllButton:StripTextures()
	QuestLogCollapseAllButton:Point('TOPLEFT', -45, 7)
	QuestLogCollapseAllButton:SetHighlightTexture(E.ClearTexture)

	local normal = QuestLogCollapseAllButton:GetNormalTexture()
	normal:Size(16)
end

S:AddCallback('BlizzardQuestFrames')
