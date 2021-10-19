local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, type, gsub = unpack, type, gsub
local select, ipairs, pairs = select, ipairs, pairs
local strfind, strmatch = strfind, strmatch

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
local MAX_NUM_ITEMS = MAX_NUM_ITEMS
local MAX_NUM_QUESTS = MAX_NUM_QUESTS
local MAX_REQUIRED_ITEMS = MAX_REQUIRED_ITEMS
local hooksecurefunc = hooksecurefunc

function S:BlizzardQuestFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.quest) then return end

	local QuestStrip = {
		'EmptyQuestLogFrame',
		'QuestDetailScrollChildFrame',
		'QuestDetailScrollFrame',
		'QuestFrame',
		'QuestFrameDetailPanel',
		'QuestFrameGreetingPanel',
		'QuestFrameProgressPanel',
		'QuestFrameRewardPanel',
		'QuestGreetingScrollFrame',
		'QuestInfoItemHighlight',
		'QuestLogDetailScrollFrame',
		'QuestLogFrame',
		'QuestLogListScrollFrame',
		'QuestLogQuestCount',
		'QuestProgressScrollFrame',
		'QuestRewardScrollChildFrame',
		'QuestRewardScrollFrame',
		'QuestRewardScrollFrame'
	}
	for _, object in pairs(QuestStrip) do
		_G[object]:StripTextures(true)
	end

	local QuestButtons = {
		'QuestFrameAcceptButton',
		'QuestFrameCancelButton',
		'QuestFrameCompleteButton',
		'QuestFrameCompleteQuestButton',
		'QuestFrameDeclineButton',
		'QuestFrameExitButton',
		'QuestFrameGoodbyeButton',
		'QuestFrameGreetingGoodbyeButton',
		'QuestFramePushQuestButton',
		'QuestLogFrameAbandonButton'
	}
	for _, button in pairs(QuestButtons) do
		_G[button]:StripTextures()
		S:HandleButton(_G[button])
	end

	local ScrollBars = {
		'QuestDetailScrollFrameScrollBar',
		'QuestGreetingScrollFrameScrollBar',
		'QuestLogDetailScrollFrameScrollBar',
		'QuestLogListScrollFrameScrollBar',
		'QuestProgressScrollFrameScrollBar',
		'QuestRewardScrollFrameScrollBar'
	}
	for _, object in pairs(ScrollBars) do
		S:HandleScrollBar(_G[object])
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

	for frame, numItems in pairs({ QuestLogItem = MAX_NUM_ITEMS, QuestProgressItem = MAX_REQUIRED_ITEMS }) do
		for i = 1, numItems do
			handleItemButton(_G[frame..i])
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
		local item, name, link

		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

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

		local item, name, link

		for i = 1, _G.MAX_REQUIRED_ITEMS do
			item = _G['QuestProgressItem'..i]
			name = _G['QuestProgressItem'..i..'Name']
			link = item.type and GetQuestItemLink(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc('QuestLog_UpdateQuestDetails', function()
		local requiredMoney = GetQuestLogRequiredMoney()

		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestLogRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestLogRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end
	end)

	local textColor = {1, 1, 1}
	local titleTextColor = {1, 0.80, 0.10}
	hooksecurefunc('QuestFrameItems_Update', function()
		-- Headers
		_G.QuestLogDescriptionTitle:SetTextColor(unpack(titleTextColor))
		_G.QuestLogRewardTitleText:SetTextColor(unpack(titleTextColor))
		_G.QuestLogQuestTitle:SetTextColor(unpack(titleTextColor))
		-- Other text
		_G.QuestLogItemChooseText:SetTextColor(unpack(textColor))
		_G.QuestLogItemReceiveText:SetTextColor(unpack(textColor))
		_G.QuestLogObjectivesText:SetTextColor(unpack(textColor))
		_G.QuestLogQuestDescription:SetTextColor(unpack(textColor))
		_G.QuestLogSpellLearnText:SetTextColor(unpack(textColor))

		local requiredMoney = GetQuestLogRequiredMoney()

		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		_G.QuestLogItem1:Point('TOPLEFT', _G.QuestLogItemChooseText, 'BOTTOMLEFT', 1, -3)

		local numObjectives = GetNumQuestLeaderBoards()
		local _, objType, finished
		local numVisibleObjectives = 0

		for i = 1, numObjectives do
			_, objType, finished = GetQuestLogLeaderBoard(i)
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

		local item, name, link

		for i = 1, _G.MAX_NUM_ITEMS do
			item = _G['QuestLogItem'..i]
			name = _G['QuestLogItem'..i..'Name']
			link = item.type and (GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	hooksecurefunc('QuestInfo_Display', function()
		-- Headers
		_G.QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor))
		_G.QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor))
		_G.QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor))
		_G.QuestInfoRewardsFrame.Header:SetTextColor(unpack(titleTextColor))
		-- Other text
		_G.QuestInfoDescriptionText:SetTextColor(unpack(textColor))
		_G.QuestInfoObjectivesText:SetTextColor(unpack(textColor))
		_G.QuestInfoGroupSize:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardText:SetTextColor(unpack(textColor))
		-- Reward frame text
		_G.QuestInfoRewardsFrame.ItemChooseText:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(unpack(textColor))
		_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(unpack(textColor))

		_G.QuestInfoRewardsFrame.spellHeaderPool.textR, _G.QuestInfoRewardsFrame.spellHeaderPool.textG, _G.QuestInfoRewardsFrame.spellHeaderPool.textB = unpack(textColor)

		local requiredMoney = GetQuestLogRequiredMoney()

		for spellHeader, _ in _G.QuestInfoFrame.rewardsFrame.spellHeaderPool:EnumerateActive() do
			spellHeader:SetVertexColor(1, 1, 1)
		end
		for spellIcon, _ in _G.QuestInfoFrame.rewardsFrame.spellRewardPool:EnumerateActive() do
			if not spellIcon.template then
				handleItemButton(spellIcon)
			end
		end

		if requiredMoney > 0 then
			if requiredMoney > GetMoney() then
				_G.QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				_G.QuestInfoRequiredMoneyText:SetTextColor(1, 0.80, 0.10)
			end
		end

		local item, name, link

		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			item = _G['QuestInfoRewardsFrameQuestInfoItem'..i]
			name = _G['QuestInfoRewardsFrameQuestInfoItem'..i..'Name']
			link = item.type and (_G.QuestInfoFrame.questLog and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			questQualityColors(item, name, link)
		end
	end)

	for i = 1, MAX_NUM_QUESTS do
		_G['QuestTitleButton'..i..'QuestIcon']:SetPoint('TOPLEFT', 4, 2)
		_G['QuestTitleButton'..i..'QuestIcon']:SetSize(16, 16)
	end

	local function UpdateGreetingFrame()
		local i = 1
		while _G['QuestTitleButton'..i]:IsVisible() do
			local title = _G['QuestTitleButton'..i]
			local icon = _G['QuestTitleButton'..i..'QuestIcon']
			local text = title:GetFontString()
			local textString = gsub(title:GetText(), '|c[Ff][Ff]%x%x%x%x%x%x(.+)|r', '%1')

			_G.GreetingText:SetTextColor(1, 1, 1)
			_G.CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
			_G.AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

			title:SetText(textString)

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
				local questLogTitleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(y)
				if strmatch(questLogTitleText, textString) then
					if (isComplete == 1 or IsQuestComplete(questId)) then
						icon:SetDesaturation(0)
						text:SetTextColor(1, .8, .1)
						break
					end
				end
			end
			i = i + 1
		end
	end

	_G.QuestFrameGreetingPanel:HookScript('OnUpdate', UpdateGreetingFrame)
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)

	_G.QuestLogTimerText:SetTextColor(1, 1, 1)

	S:HandleFrame(_G.QuestFrame, true, nil, 11, -12, -32, 66)
	S:HandleFrame(_G.QuestLogFrame, true, nil, 11, -12, -32, 45)
	S:HandleFrame(_G.QuestLogListScrollFrame, true, nil, -1, 2)
	S:HandleFrame(_G.QuestLogDetailScrollFrame, true, nil, -1, 2)
	S:HandleFrame(_G.QuestDetailScrollFrame, true, nil, -6, 2)
	S:HandleFrame(_G.QuestRewardScrollFrame, true, nil, -6, 2)
	S:HandleFrame(_G.QuestProgressScrollFrame, true, nil, -6, 2)
	S:HandleFrame(_G.QuestGreetingScrollFrame, true, nil, -6, 2)

	S:HandlePointXY(_G.QuestLogFrameAbandonButton, 15, 49)
	S:HandlePointXY(_G.QuestFramePushQuestButton, -2)
	S:HandlePointXY(_G.QuestFrameExitButton, -36, 49)
	S:HandlePointXY(_G.QuestFrameAcceptButton, 15, 70)
	S:HandlePointXY(_G.QuestFrameDeclineButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameCompleteQuestButton, 15, 70)
	S:HandlePointXY(_G.QuestFrameCompleteButton, 15, 70)
	S:HandlePointXY(_G.QuestFrameCancelButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameGoodbyeButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameGreetingGoodbyeButton, -36, 70)
	S:HandlePointXY(_G.QuestFrameNpcNameText, -1, 0)

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

	local index = 1
	while _G['QuestLogTitle'..index] do
		local questLogTitle = _G['QuestLogTitle'..index]

		questLogTitle:SetNormalTexture(E.Media.Textures.PlusButton)
		questLogTitle.SetNormalTexture = E.noop

		questLogTitle:GetNormalTexture():Size(16)
		questLogTitle:GetNormalTexture():Point('LEFT', 5, 0)

		questLogTitle:SetHighlightTexture('')
		questLogTitle.SetHighlightTexture = E.noop

		questLogTitle:Width(300)

		_G['QuestLogTitle'..index..'Highlight']:SetAlpha(0)

		hooksecurefunc(questLogTitle, 'SetNormalTexture', function(title, texture)
			local tex = title:GetNormalTexture()

			if strfind(texture, 'MinusButton') then
				tex:SetTexture(E.Media.Textures.MinusButton)
			elseif strfind(texture, 'PlusButton') then
				tex:SetTexture(E.Media.Textures.PlusButton)
			else
				tex:SetTexture()
			end
		end)

		index = index + 1
	end

	local QuestLogCollapseAllButton = _G.QuestLogCollapseAllButton
	QuestLogCollapseAllButton:StripTextures()
	QuestLogCollapseAllButton:Point('TOPLEFT', -45, 7)

	QuestLogCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
	QuestLogCollapseAllButton.SetNormalTexture = E.noop
	QuestLogCollapseAllButton:GetNormalTexture():Size(16)

	QuestLogCollapseAllButton:SetHighlightTexture('')
	QuestLogCollapseAllButton.SetHighlightTexture = E.noop

	QuestLogCollapseAllButton:SetDisabledTexture(E.Media.Textures.PlusButton)
	QuestLogCollapseAllButton.SetDisabledTexture = E.noop
	QuestLogCollapseAllButton:GetDisabledTexture():Size(16)
	QuestLogCollapseAllButton:GetDisabledTexture():SetTexture(E.Media.Textures.PlusButton)
	QuestLogCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	hooksecurefunc(_G.QuestLogCollapseAllButton, 'SetNormalTexture', function(button, texture)
		local tex = button:GetNormalTexture()

		if strfind(texture, 'MinusButton') then
			tex:SetTexture(E.Media.Textures.MinusButton)
		else
			tex:SetTexture(E.Media.Textures.PlusButton)
		end
	end)
end

S:AddCallback('BlizzardQuestFrames')
