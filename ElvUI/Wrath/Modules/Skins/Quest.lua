local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local gsub, strmatch, unpack = gsub, strmatch, unpack
local pairs, select = pairs, select

local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
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
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset

local MAX_NUM_ITEMS = MAX_NUM_ITEMS
local MAX_NUM_QUESTS = MAX_NUM_QUESTS
local MAX_REQUIRED_ITEMS = MAX_REQUIRED_ITEMS
local hooksecurefunc = hooksecurefunc

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

local function handleItemButton(item)
	if not item then return end

	if item then
		item:SetTemplate()
		item:Size(143, 40)
		item:SetFrameLevel(item:GetFrameLevel() + 2)
	end

	if item.Icon then
		item.Icon:Size(E.PixelMode and 35 or 32)
		item.Icon:SetDrawLayer('ARTWORK')
		item.Icon:Point('TOPLEFT', E.PixelMode and 2 or 4, -(E.PixelMode and 2 or 4))
		S:HandleIcon(item.Icon)
	end

	if item.IconBorder then
		S:HandleIconBorder(item.IconBorder)
	end

	if item.Count then
		item.Count:SetDrawLayer('OVERLAY')
		item.Count:ClearAllPoints()
		item.Count:SetPoint('BOTTOMRIGHT', item.Icon, 'BOTTOMRIGHT', 0, 0)
	end

	if item.NameFrame then
		item.NameFrame:SetAlpha(0)
		item.NameFrame:Hide()
	end

	if item.IconOverlay then
		item.IconOverlay:SetAlpha(0)
	end

	if item.Name then
		item.Name:FontTemplate()
	end

	if item.CircleBackground then
		item.CircleBackground:SetAlpha(0)
		item.CircleBackgroundGlow:SetAlpha(0)
	end

	for i = 1, item:GetNumRegions() do
		local Region = select(i, item:GetRegions())
		if Region and Region:IsObjectType('Texture') and Region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
			Region:SetTexture('')
		end
	end
end

local function questQualityColors(frame, text, link)
	if not frame.template then
		handleItemButton(frame)
	end

	local quality = link and select(3, GetItemInfo(link))
	if quality and quality > 1 then
		local r, g, b = GetItemQualityColor(quality)

		text:SetTextColor(r, g, b)
		frame:SetBackdropBorderColor(r, g, b)
	else
		text:SetTextColor(1, 1, 1)
		frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
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
		_G.QuestLogQuestCount,
		_G.QuestProgressScrollFrame,
		_G.QuestRewardScrollChildFrame,
		_G.QuestRewardScrollFrame,
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
		_G.QuestFrameGoodbyeButton,
		_G.QuestFrameGreetingGoodbyeButton,
		_G.QuestFramePushQuestButton,
		_G.QuestLogFrameAbandonButton,
		_G.QuestLogFrameTrackButton,
		_G.QuestLogFrameCancelButton
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
			handleItemButton(_G[frame..i])
		end
	end

	hooksecurefunc('QuestInfo_GetRewardButton', function(rewardsFrame, index)
		local button = rewardsFrame.RewardButtons[index]
		if not button and button.template then return end

		handleItemButton(button)
	end)

	hooksecurefunc('QuestInfoItem_OnClick', function(frame)
		if frame.type == 'choice' then
			frame:SetBackdropBorderColor(1, 0.80, 0.10)
			_G[frame:GetName()..'Name']:SetTextColor(1, 0.80, 0.10)

			for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
				local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]

				if item ~= frame then
					local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
					local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

					questQualityColors(item, name, link)
				end
			end
		end
	end)

	hooksecurefunc('QuestInfo_ShowRewards', function()
		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc('QuestInfo_ShowRequiredMoney', function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	hooksecurefunc('QuestFrameProgressItems_Update', function()
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

		for i = 1, _G.MAX_REQUIRED_ITEMS do
			local item = _G['QuestProgressItem'..i]
			local name = _G['QuestProgressItem'..i..'Name']
			local link = item.type and GetQuestItemLink(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc('QuestLog_Update', function()
		if not _G.QuestLogFrame:IsShown() then return end
		local numEntries = GetNumQuestLogEntries()
		local scrollOffset = HybridScrollFrame_GetOffset(_G.QuestLogListScrollFrame)
		local buttons = _G.QuestLogListScrollFrame.buttons

		for i = 1, 22 do
			local questIndex = i + scrollOffset
			if questIndex <= numEntries then
				local _, _, _, isHeader, isCollapsed = GetQuestLogTitle(questIndex)
				if isHeader then
					if isCollapsed then
						buttons[i]:SetNormalTexture(E.Media.Textures.PlusButton)
					else
						buttons[i]:SetNormalTexture(E.Media.Textures.MinusButton)
					end
				end
			end
		end
	end)

	hooksecurefunc('QuestLogUpdateQuestCount', function()
		_G.QuestLogCount:ClearAllPoints()
		_G.QuestLogCount:Point('BOTTOMLEFT', _G.QuestLogListScrollFrame.backdrop, 'TOPLEFT', 0, 5)
	end)

	hooksecurefunc('QuestLog_UpdateQuestDetails', function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	local textR, textG, textB = 1, 1, 1
	local titleR, titleG, titleB = 1, 0.80, 0.10
	hooksecurefunc('QuestFrameItems_Update', function()
		-- Headers
		_G.QuestLogDescriptionTitle:SetTextColor(titleR, titleG, titleB)
		_G.QuestLogRewardTitleText:SetTextColor(titleR, titleG, titleB)
		_G.QuestLogQuestTitle:SetTextColor(titleR, titleG, titleB)

		-- Other text
		_G.QuestLogItemChooseText:SetTextColor(textR, textG, textB)
		_G.QuestLogItemReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestLogObjectivesText:SetTextColor(textR, textG, textB)
		_G.QuestLogQuestDescription:SetTextColor(textR, textG, textB)
		_G.QuestLogSpellLearnText:SetTextColor(textR, textG, textB)
		_G.QuestInfoQuestType:SetTextColor(textR, textG, textB)

		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		_G.QuestLogItem1:Point('TOPLEFT', _G.QuestLogItemChooseText, 'BOTTOMLEFT', 1, -3)

		local numVisibleObjectives = 0
		local numObjectives = GetNumQuestLeaderBoards()
		for i = 1, numObjectives do
			local _, objType, finished = GetQuestLogLeaderBoard(i)
			if objType ~= 'spell' then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = _G['QuestLogObjective'..numVisibleObjectives]

				if objective then
					if finished then
						objective:SetTextColor(1, .8, .1)
					else
						objective:SetTextColor(.63, .09, .09)
					end
				end
			end
		end

		for i = 1, _G.MAX_NUM_ITEMS do
			local item = _G['QuestLogItem'..i]
			local name = _G['QuestLogItem'..i..'Name']
			local link = item.type and (GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc('QuestInfo_Display', function()
		-- Headers
		_G.QuestInfoTitleHeader:SetTextColor(titleR, titleG, titleB)
		_G.QuestInfoDescriptionHeader:SetTextColor(titleR, titleG, titleB)
		_G.QuestInfoObjectivesHeader:SetTextColor(titleR, titleG, titleB)
		_G.QuestInfoRewardsFrame.Header:SetTextColor(titleR, titleG, titleB)

		-- Other text
		_G.QuestInfoDescriptionText:SetTextColor(textR, textG, textB)
		_G.QuestInfoObjectivesText:SetTextColor(textR, textG, textB)
		_G.QuestInfoGroupSize:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardText:SetTextColor(textR, textG, textB)
		_G.QuestInfoQuestType:SetTextColor(textR, textG, textB)

		local numObjectives = GetNumQuestLeaderBoards()
		for i = 1, numObjectives do
			local text = _G['QuestInfoObjective'..i]
			if not text then break end

			text:SetTextColor(textR, textG, textB)
		end

		-- Reward frame text
		_G.QuestInfoRewardsFrame.ItemChooseText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrameHonorReceiveText:SetTextColor(textR, textG, textB)
		_G.QuestInfoRewardsFrameReceiveText:SetTextColor(textR, textG, textB)

		_G.QuestInfoRewardsFrame.spellHeaderPool.textR, _G.QuestInfoRewardsFrame.spellHeaderPool.textG, _G.QuestInfoRewardsFrame.spellHeaderPool.textB = textR, textG, textB

		for spellHeader, _ in _G.QuestInfoFrame.rewardsFrame.spellHeaderPool:EnumerateActive() do
			spellHeader:SetVertexColor(1, 1, 1)
		end
		for spellIcon, _ in _G.QuestInfoFrame.rewardsFrame.spellRewardPool:EnumerateActive() do
			if not spellIcon.template then
				handleItemButton(spellIcon)
			end
		end

		local requiredMoney = GetQuestLogRequiredMoney()
		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			local name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			local link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	for i = 1, MAX_NUM_QUESTS do
		_G['QuestTitleButton'..i..'QuestIcon']:SetPoint('TOPLEFT', 4, 2)
		_G['QuestTitleButton'..i..'QuestIcon']:SetSize(16, 16)
	end

	_G.QuestFrameGreetingPanel:HookScript('OnUpdate', UpdateGreetingFrame)
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)

	_G.QuestFramePushQuestButton:ClearAllPoints()
	_G.QuestFramePushQuestButton:Point('LEFT', _G.QuestLogFrameAbandonButton, 'RIGHT', 1, 0)
	_G.QuestFramePushQuestButton:Point('RIGHT', _G.QuestLogFrameTrackButton, 'LEFT', -1, 0)

	local QuestLogDetailFrame = _G.QuestLogDetailFrame
	S:HandleFrame(QuestLogDetailFrame, true, nil, 8, -8, 8)

	S:HandleFrame(_G.QuestFrame, true, nil, 11, -12, -32, 66)
	S:HandleFrame(_G.QuestLogCount)
	S:HandleFrame(_G.QuestLogFrame, true, nil, 10, -10, 1, 8)
	S:HandleFrame(_G.QuestLogListScrollFrame, true, nil, -1, 2)
	S:HandleFrame(_G.QuestLogDetailScrollFrame, true, nil, -1, 2)
	S:HandleFrame(_G.QuestDetailScrollFrame, true, nil, -6, 2)
	S:HandleFrame(_G.QuestRewardScrollFrame, true, nil, -6, 2)
	S:HandleFrame(_G.QuestProgressScrollFrame, true, nil, -6, 2)
	S:HandleFrame(_G.QuestGreetingScrollFrame, true, nil, -6, 2)

	S:HandlePointXY(_G.QuestLogFrameAbandonButton, 0, -2)
	S:HandlePointXY(_G.QuestLogFrameTrackButton, 0, -2)
	S:HandlePointXY(_G.QuestFramePushQuestButton, 1)
	S:HandlePointXY(_G.QuestFrameAcceptButton, 15, 70)
	S:HandlePointXY(_G.QuestFrameDeclineButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameCompleteQuestButton, 15, 70)
	S:HandlePointXY(_G.QuestFrameCompleteButton, 15, 70)
	S:HandlePointXY(_G.QuestFrameCancelButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameGoodbyeButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameGreetingGoodbyeButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameNpcNameText, -1, 0)

	_G.QuestLogFrameCancelButton:Point('BOTTOMRIGHT', _G.QuestLogFrame, 'BOTTOMRIGHT', -7, 12)

	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestLogListScrollFrame:Width(303)
	_G.QuestLogDetailScrollFrame:Width(303)
	_G.QuestLogFrameAbandonButton:Width(129)

	_G.QuestLogHighlightFrame:Width(303)
	_G.QuestLogHighlightFrame.SetWidth = E.noop

	_G.QuestLogSkillHighlight:SetTexture(E.Media.Textures.Highlight)
	_G.QuestLogSkillHighlight:SetAlpha(0.35)

	S:HandleCloseButton(_G.QuestFrameCloseButton, _G.QuestFrame.backdrop)
	S:HandleCloseButton(_G.QuestLogFrameCloseButton, _G.QuestLogFrame.backdrop)
	S:HandleCloseButton(_G.QuestLogDetailFrameCloseButton, _G.QuestLogDetailFrame.backdrop)
end

S:AddCallback('BlizzardQuestFrames')
