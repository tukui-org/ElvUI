local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, select = unpack, select
local ipairs, next, rad = ipairs, next, rad
local hooksecurefunc = hooksecurefunc

local GetItemQualityByID = C_Item.GetItemQualityByID

local lootQuality = {
	['loottab-set-itemborder-white'] = nil, -- dont show white
	['loottab-set-itemborder-green'] = 2,
	['loottab-set-itemborder-blue'] = 3,
	['loottab-set-itemborder-purple'] = 4,
	['loottab-set-itemborder-orange'] = 5,
	['loottab-set-itemborder-artifact'] = 6,
}

local function HandleButton(btn, strip, ...)
	S:HandleButton(btn, strip, ...)

	local str = btn:GetFontString()
	if str then
		str:SetTextColor(1, 1, 1)
	end
end

local function ReskinHeader(header)
	for i = 4, 18 do
		select(i, header.button:GetRegions()):SetTexture()
	end

	HandleButton(header.button)

	header.descriptionBG:SetAlpha(0)
	header.descriptionBGBottom:SetAlpha(0)
	header.description:SetTextColor(1, 1, 1)
	header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
	header.button.expandedIcon:SetTextColor(1, 1, 1)
	header.button.expandedIcon:SetWidth(20) -- don't wrap the text
end

local SkinOverviewInfo
do -- this prevents a taint trying to force a color lock by setting it to E.noop
	local LockColors = {}
	local function LockValue(button, r, g, b)
		local rr, gg, bb = unpack(E.media.rgbvaluecolor)
		if r ~= rr or gg ~= g or b ~= bb then
			button:SetTextColor(rr, gg, bb)
		end
	end

	local function LockWhite(button, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			button:SetTextColor(1, 1, 1)
		end
	end

	local function LockColor(button, valuecolor)
		if LockColors[button] then return end

		hooksecurefunc(button, 'SetTextColor', (valuecolor and LockValue) or LockWhite)

		LockColors[button] = true
	end

	SkinOverviewInfo = function(frame, _, index)
		local header = frame.overviews[index]
		if not header.IsSkinned then
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture()
			end

			ReskinHeader(header)
			HandleButton(header.button)

			LockColor(header.button.title, true)
			LockColor(header.button.expandedIcon)

			header.IsSkinned = true
		end
	end
end

local function SkinOverviewInfoBullets(object)
	local parent = object:GetParent()

	if parent.Bullets then
		for _, bullet in next, parent.Bullets do
			if not bullet.IsSkinned then
				bullet.Text:SetTextColor('P', 1, 1, 1)
				bullet.IsSkinned = true
			end
		end
	end
end

local function HandleTabs(tab)
	local str = tab:GetFontString()
	tab:StripTextures()
	tab:SetText(tab.tooltip)
	str:FontTemplate(nil, nil, 'SHADOW')
	tab:SetTemplate()
	tab:SetScript('OnEnter', E.noop)
	tab:SetScript('OnLeave', E.noop)
	tab:Size(str:GetStringWidth() * 1.5, 20)
	tab.SetPoint = E.noop
end

local function SkinAbilitiesInfo()
	local index = 1
	local header = _G['EncounterJournalInfoHeader'..index]
	while header do
		if not header.IsSkinned then
			ReskinHeader(header)
			header.IsSkinned = true
		end

		index = index + 1
		header = _G['EncounterJournalInfoHeader'..index]
	end
end

local function ItemSetsItemBorder(border, atlas)
	local parent = border:GetParent()
	local backdrop = parent and parent.Icon and parent.Icon.backdrop
	if backdrop then
		local r, g, b = E:GetItemQualityColor(lootQuality[atlas])
		backdrop:SetBackdropBorderColor(r, g, b)
	end
end

local function ItemSetElements(set)
	local parchment = E.private.skins.parchmentRemoverEnable
	if parchment and not set.backdrop then
		set:CreateBackdrop('Transparent')
	end

	if parchment and set.Background then
		set.Background:Hide()
	end

	if set.ItemButtons then
		for _, button in next, set.ItemButtons do
			local icon = button.Icon
			if icon and not icon.backdrop then
				S:HandleIcon(icon, true)
			end

			local border = button.Border
			if border and not border.IsSkinned then
				border:SetAlpha(0)

				ItemSetsItemBorder(border, border:GetAtlas()) -- handle first one
				hooksecurefunc(border, 'SetAtlas', ItemSetsItemBorder)

				border.IsSkinned = true
			end
		end
	end
end

local function HandleItemSetsElements(frame)
	frame:ForEachFrame(ItemSetElements)
end

local function InstanceSelectScrollUpdateChild(child)
	if not child.IsSkinned then
		child:SetNormalTexture(E.ClearTexture)
		child:SetPushedTexture(E.ClearTexture)
		child:SetHighlightTexture(E.media.normTex)
		local hl = child:GetHighlightTexture()
		hl:SetVertexColor(0.8, 0.8, 0.8, .25)
		hl:SetInside(child, 3, 3)

		local bgImage = child.bgImage
		if bgImage then
			bgImage:CreateBackdrop()
			bgImage.backdrop:Point('TOPLEFT', 3, -3)
			bgImage.backdrop:Point('BOTTOMRIGHT', -4, 2)
		end

		child.IsSkinned = true
	end
end

local function InstanceSelectScrollUpdate(frame)
	frame:ForEachFrame(InstanceSelectScrollUpdateChild)
end

local function BossesScrollUpdateChild(child)
	if not child.IsSkinned then
		S:HandleButton(child)

		local hl = child:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()

		child.text:SetTextColor(1, 1, 1)
		child.text.SetTextColor = E.noop
		child.creature:Point('TOPLEFT', 0, -4)

		child.IsSkinned = true
	end
end

local function BossesScrollUpdate(frame)
	frame:ForEachFrame(BossesScrollUpdateChild)
end

local function LootContainerUpdateChild(child)
	if not child.IsSkinned then
		if child.bossTexture then child.bossTexture:SetAlpha(0) end
		if child.bosslessTexture then child.bosslessTexture:SetAlpha(0) end

		if child.name and child.icon then
			child.icon:SetSize(32, 32)
			child.icon:Point('TOPLEFT', E.PixelMode and 3 or 4, -(E.PixelMode and 7 or 8))
			S:HandleIcon(child.icon, true)
			S:HandleIconBorder(child.IconBorder, child.icon.backdrop)

			child.name:ClearAllPoints()
			child.name:Point('TOPLEFT', child.icon, 'TOPRIGHT', 6, -2)

			-- we only want this when name and icon both exist
			if not child.backdrop then
				child:CreateBackdrop('Transparent')
				child.backdrop:Point('TOPLEFT')
				child.backdrop:Point('BOTTOMRIGHT', 0, 1)
			end
		end

		if child.boss then
			child.boss:ClearAllPoints()
			child.boss:Point('BOTTOMLEFT', 4, 6)
			child.boss:SetTextColor(1, 1, 1)
		end

		if child.slot then
			child.slot:ClearAllPoints()
			child.slot:Point('TOPLEFT', child.name, 'BOTTOMLEFT', 0, -3)
			child.slot:SetTextColor(1, 1, 1)
		end

		if child.armorType then
			child.armorType:ClearAllPoints()
			child.armorType:Point('RIGHT', child, 'RIGHT', -10, 0)
			child.armorType:SetTextColor(1, 1, 1)
		end

		child.IsSkinned = true
	end
end

local function LootContainerUpdate(frame)
	frame:ForEachFrame(LootContainerUpdateChild)
end

local function LoreScrollingFontChild(child)
	if child.FontString then
		child.FontString:SetTextColor(1, 1, 1)
	end
end

function S:Blizzard_EncounterJournal()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.encounterjournal) then return end

	local EJ = _G.EncounterJournal
	S:HandlePortraitFrame(EJ)

	EJ.navBar:StripTextures(true)
	EJ.navBar.overlay:StripTextures(true)

	EJ.navBar:CreateBackdrop()
	EJ.navBar.backdrop:Point('TOPLEFT', -2, 0)
	EJ.navBar.backdrop:Point('BOTTOMRIGHT')
	HandleButton(EJ.navBar.home, true)

	S:HandleEditBox(EJ.searchBox)
	EJ.searchBox:ClearAllPoints()
	EJ.searchBox:Point('TOPLEFT', EJ.navBar, 'TOPRIGHT', 4, 0)

	S:HandleTrimScrollBar(EJ.MonthlyActivitiesFrame.ScrollBar)
	S:HandleTrimScrollBar(EJ.MonthlyActivitiesFrame.FilterList.ScrollBar)

	if E.global.general.disableTutorialButtons then
		EJ.MonthlyActivitiesFrame.HelpButton:Kill()
	end

	local InstanceSelect = EJ.instanceSelect
	InstanceSelect.bg:Kill()

	S:HandleDropDownBox(InstanceSelect.ExpansionDropdown)
	S:HandleTrimScrollBar(InstanceSelect.ScrollBar)

	-- Bottom tabs
	for _, tab in next, {
		_G.EncounterJournalSuggestTab,
		_G.EncounterJournalDungeonTab,
		_G.EncounterJournalRaidTab,
		_G.EncounterJournalLootJournalTab,
		_G.EncounterJournalMonthlyActivitiesTab
	} do
		S:HandleTab(tab)
	end

	_G.EncounterJournalMonthlyActivitiesTab:ClearAllPoints()
	_G.EncounterJournalMonthlyActivitiesTab:Point('TOPLEFT', _G.EncounterJournal, 'BOTTOMLEFT', -3, 0)

	hooksecurefunc('EncounterJournal_CheckAndDisplayTradingPostTab', function()
		_G.EncounterJournalSuggestTab:Point('LEFT', _G.EncounterJournalMonthlyActivitiesTab, 'RIGHT', -5, 0)
	end)

	hooksecurefunc('EncounterJournal_CheckAndDisplaySuggestedContentTab', function()
		if E.TimerunningID then
			_G.EncounterJournalDungeonTab:Point('LEFT', _G.EncounterJournalMonthlyActivitiesTab, 'RIGHT')
		else
			_G.EncounterJournalDungeonTab:Point('LEFT', _G.EncounterJournalSuggestTab, 'RIGHT', -5, 0)
		end
	end)

	_G.EncounterJournalRaidTab:ClearAllPoints()
	_G.EncounterJournalRaidTab:Point('LEFT', _G.EncounterJournalDungeonTab, 'RIGHT', -5, 0)

	_G.EncounterJournalLootJournalTab:ClearAllPoints()
	_G.EncounterJournalLootJournalTab:Point('LEFT', _G.EncounterJournalRaidTab, 'RIGHT', -5, 0)

	-- Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterInfo:SetTemplate('Transparent')

	EncounterInfo.encounterTitle:Kill()

	EncounterInfo.leftShadow:SetAlpha(0) -- dont kill these
	EncounterInfo.rightShadow:SetAlpha(0) -- it will taint

	EncounterInfo.instanceButton.icon:Size(32)
	EncounterInfo.instanceButton.icon:SetTexCoord(0, 1, 0, 1)
	EncounterInfo.instanceButton:SetNormalTexture(E.ClearTexture)
	EncounterInfo.instanceButton:SetHighlightTexture(E.ClearTexture)

	EncounterInfo.model.dungeonBG:Kill()
	_G.EncounterJournalEncounterFrameInfoBG:Height(385)
	_G.EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()

	EncounterInfo.instanceButton:ClearAllPoints()
	EncounterInfo.instanceButton:Point('TOPLEFT', EncounterInfo, 'TOPLEFT', 0, 10)

	EncounterInfo.instanceTitle:ClearAllPoints()
	EncounterInfo.instanceTitle:Point('BOTTOM', EncounterInfo.bossesScroll, 'TOP', 10, 15)

	-- Buttons
	EncounterInfo.difficulty:ClearAllPoints()
	EncounterInfo.difficulty:Point('BOTTOMRIGHT', _G.EncounterJournalEncounterFrameInfoBG, 'TOPRIGHT', -5, 7)
	S:HandleDropDownBox(EncounterInfo.difficulty, 120)

	EncounterInfo.LootContainer.filter:ClearAllPoints()
	EncounterInfo.LootContainer.filter:Point('RIGHT', EncounterInfo.difficulty, 'LEFT', -120, 0)
	S:HandleDropDownBox(EncounterInfo.LootContainer.filter, 120)
	S:HandleDropDownBox(EncounterInfo.LootContainer.slotFilter, 100)

	S:HandleTrimScrollBar(EncounterInfo.BossesScrollBar)
	S:HandleTrimScrollBar(_G.EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)

	_G.EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.85)
	_G.EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameBG:Point('CENTER', 0, 15)
	_G.EncounterJournalEncounterFrameInstanceFrame.titleBG:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrame.titleBG:Point('TOP', _G.EncounterJournalEncounterFrameInstanceFrameBG, 'TOP', 0, -32)
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:Point('TOP', 0, -85)
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:Point('LEFT', 55, -78)

	S:HandleTrimScrollBar(EncounterInfo.overviewScroll.ScrollBar)
	S:HandleTrimScrollBar(EncounterInfo.detailsScroll.ScrollBar)
	S:HandleTrimScrollBar(EncounterInfo.LootContainer.ScrollBar)

	EncounterInfo.detailsScroll:Height(360)
	EncounterInfo.LootContainer:Height(360)
	EncounterInfo.overviewScroll:Height(360)

	-- Tabs
	if E.Retail then
		for _, name in next, { 'overviewTab', 'modelTab', 'bossTab', 'lootTab' } do
			local info = _G.EncounterJournal.encounter.info

			local tab = info[name]
			tab:CreateBackdrop('Transparent')
			tab.backdrop:SetInside(nil, 2, 2)

			tab:SetNormalTexture(E.ClearTexture)
			tab:SetPushedTexture(E.ClearTexture)
			tab:SetDisabledTexture(E.ClearTexture)

			local hl = tab:GetHighlightTexture()
			local r, g, b = unpack(E.media.rgbvaluecolor)
			hl:SetColorTexture(r, g, b, .2)
			hl:SetInside(tab.backdrop)

			tab:ClearAllPoints()
			if name == 'overviewTab' then
				tab:Point('TOPLEFT', _G.EncounterJournalEncounterFrameInfo, 'TOPRIGHT', 9, 0)
			elseif name == 'lootTab' then
				tab:Point('TOPLEFT', info.overviewTab, 'BOTTOMLEFT', 0, -1)
			elseif name == 'bossTab' then
				tab:Point('TOPLEFT', info.lootTab, 'BOTTOMLEFT', 0, -1)
			elseif name == 'modelTab' then
				tab:Point('TOPLEFT', info.bossTab, 'BOTTOMLEFT', 0, -1)

			end
		end
	else
		local tabs = {
			EncounterInfo.overviewTab,
			EncounterInfo.lootTab,
			EncounterInfo.bossTab,
			EncounterInfo.modelTab
		}

		for index, tab in next, tabs do
			tab:ClearAllPoints()

			if index == 4 then
				tab:Point('TOPRIGHT', EJ, 'BOTTOMRIGHT', -10, E.PixelMode and 0 or 2)
			else
				tab:Point('RIGHT', tabs[index+1], 'LEFT', -4, 0)
			end

			HandleTabs(tab)
		end

		hooksecurefunc('EncounterJournal_SetTabEnabled', function(tab, enabled)
			if enabled then
				tab:GetFontString():SetTextColor(1, 1, 1)
			else
				tab:GetFontString():SetTextColor(0.6, 0.6, 0.6)
			end
		end)
	end

	-- Search
	_G.EncounterJournalSearchResults:StripTextures()
	_G.EncounterJournalSearchResults:SetTemplate()
	_G.EncounterJournalSearchBox.searchPreviewContainer:StripTextures()

	S:HandleCloseButton(_G.EncounterJournalSearchResultsCloseButton)
	S:HandleTrimScrollBar(_G.EncounterJournalSearchResults.ScrollBar)

	-- Suggestions
	for i = 1, _G.AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = EJ.suggestFrame['Suggestion'..i]
		if i == 1 then
			HandleButton(suggestion.button)
			suggestion.button:SetFrameLevel(4)
			S:HandleNextPrevButton(suggestion.prevButton, nil, nil, true)
			S:HandleNextPrevButton(suggestion.nextButton, nil, nil, true)
		else
			HandleButton(suggestion.centerDisplay.button)
		end
	end

	if E.private.skins.parchmentRemoverEnable then
		EJ.MonthlyActivitiesFrame.Divider:Hide()
		EJ.MonthlyActivitiesFrame.DividerVertical:Hide()
		EJ.MonthlyActivitiesFrame.Bg:SetAlpha(0)
		EJ.MonthlyActivitiesFrame.ThemeContainer:SetAlpha(0)
		_G.EncounterJournalInstanceSelectBG:SetAlpha(0)

		local suggestFrame = EJ.suggestFrame

		-- Suggestion 1
		local suggestion = suggestFrame.Suggestion1
		suggestion.bg:Hide()
		suggestion:SetTemplate('Transparent')

		local centerDisplay = suggestion.centerDisplay
		centerDisplay.title.text:SetTextColor(1, 1, 1)
		centerDisplay.description.text:SetTextColor(.9, .9, .9)

		local reward = suggestion.reward
		reward.text:SetTextColor(.9, .9, .9)
		reward.iconRing:Hide()
		reward.iconRingHighlight:SetTexture()

		-- Suggestion 2 and 3
		for i = 2, 3 do
			suggestion = suggestFrame['Suggestion'..i]
			suggestion.bg:Hide()
			suggestion:SetTemplate('Transparent')
			suggestion.icon:Point('TOPLEFT', 10, -10)

			centerDisplay = suggestion.centerDisplay
			centerDisplay:ClearAllPoints()
			centerDisplay:Point('TOPLEFT', 85, -10)
			centerDisplay.title.text:SetTextColor(1, 1, 1)
			centerDisplay.description.text:SetTextColor(.9, .9, .9)

			reward = suggestion.reward
			reward.iconRing:Hide()
			reward.iconRingHighlight:SetTexture()
		end

		hooksecurefunc('EJSuggestFrame_RefreshDisplay', function()
			for i, data in ipairs(suggestFrame.suggestions) do
				local sugg = next(data) and suggestFrame['Suggestion'..i]
				if sugg then
					if not sugg.icon.backdrop then
						sugg.icon:CreateBackdrop()
					end

					sugg.icon:SetMask('')
					sugg.icon:SetTexture(data.iconPath)
					sugg.icon:SetTexCoord(unpack(E.TexCoords))
					sugg.iconRing:Hide()
				end
			end
		end)

		hooksecurefunc('EJSuggestFrame_UpdateRewards', function(sugg)
			local rewardData = sugg.reward.data
			if rewardData then
				if not sugg.reward.icon.backdrop then
					sugg.reward.icon:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, 3)
				end

				sugg.reward.icon:SetMask('')
				sugg.reward.icon:SetTexture(rewardData.itemIcon or rewardData.currencyIcon or [[Interface\Icons\achievement_guildperk_mobilebanking]])
				sugg.reward.icon:SetTexCoord(unpack(E.TexCoords))

				local quality = rewardData.itemID and GetItemQualityByID(rewardData.itemID)
				local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)

				sugg.reward.icon.backdrop:SetBackdropBorderColor(r, g, b)
			end
		end)
	end

	-- Suggestion Reward Tooltips
	if E.private.skins.blizzard.tooltip then
		local tooltip = _G.EncounterJournalTooltip
		local item1 = tooltip.Item1
		local item2 = tooltip.Item2
		tooltip.NineSlice:SetTemplate('Transparent')
		S:HandleIcon(item1.icon)
		S:HandleIcon(item2.icon)
		item1.IconBorder:Kill()
		item2.IconBorder:Kill()
	end

	local LJ = EJ.LootJournal
	S:HandleTrimScrollBar(LJ.ScrollBar)

	for _, button in next, { _G.EncounterJournalEncounterFrameInfoFilterToggle, _G.EncounterJournalEncounterFrameInfoSlotFilterToggle } do
		HandleButton(button, true)
	end

	hooksecurefunc(_G.EncounterJournal.instanceSelect.ScrollBox, 'Update', InstanceSelectScrollUpdate)

	if E.private.skins.parchmentRemoverEnable then
		LJ:StripTextures()
		LJ:SetTemplate('Transparent')

		hooksecurefunc(_G.EncounterJournal.encounter.info.BossesScrollBox, 'Update', BossesScrollUpdate)

		hooksecurefunc(_G.EncounterJournal.encounter.info.LootContainer.ScrollBox, 'Update', LootContainerUpdate)

		hooksecurefunc('EncounterJournal_SetUpOverview', SkinOverviewInfo)
		hooksecurefunc('EncounterJournal_SetBullets', SkinOverviewInfoBullets)
		hooksecurefunc('EncounterJournal_ToggleHeaders', SkinAbilitiesInfo)

		_G.EncounterJournalEncounterFrameInfoBG:Kill()
		EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)
		EncounterInfo.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)

		_G.EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject('GameFontNormalLarge')
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, .8, 0)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetAlpha(0)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor('P', 1, 1, 1)

		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetTexCoord(0.71, 0.06, 0.582, 0.08)
		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetRotation(rad(180))
		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.7)
		_G.EncounterJournalEncounterFrameInstanceFrameBG:CreateBackdrop()
		_G.EncounterJournalEncounterFrameInstanceFrame.titleBG:SetAlpha(0)
		_G.EncounterJournalEncounterFrameInstanceFrameTitle:FontTemplate(nil, 25)

		for _, child in next, { _G.EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont.ScrollBox.ScrollTarget:GetChildren() } do
			LoreScrollingFontChild(child)
		end

		local parchment = LJ:GetRegions()
		if parchment then
			parchment:Kill()
		end
	end

	do -- Item Sets
		local ItemSetsFrame = EJ.LootJournalItems.ItemSetsFrame
		S:HandleTrimScrollBar(ItemSetsFrame.ScrollBar)
		S:HandleDropDownBox(ItemSetsFrame.ClassDropdown)

		if E.private.skins.parchmentRemoverEnable then
			EJ.LootJournalItems:StripTextures()
			EJ.LootJournalItems:SetTemplate('Transparent')
		end

		hooksecurefunc(ItemSetsFrame.ScrollBox, 'Update', HandleItemSetsElements)
	end
end

S:AddCallbackForAddon('Blizzard_EncounterJournal')
