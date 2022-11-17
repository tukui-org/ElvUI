local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local select = select
local ipairs = ipairs
local next = next
local rad = rad

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc
local GetItemQualityColor = GetItemQualityColor

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

local function SkinOverviewInfo(frame, _, index)
	local header = frame.overviews[index]
	if not header.isSkinned then
		for i = 4, 18 do
			select(i, header.button:GetRegions()):SetTexture()
		end

		HandleButton(header.button)

		header.descriptionBG:SetAlpha(0)
		header.descriptionBGBottom:SetAlpha(0)
		header.description:SetTextColor(1, 1, 1)
		header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
		header.button.title.SetTextColor = E.noop
		header.button.expandedIcon:SetTextColor(1, 1, 1)
		header.button.expandedIcon.SetTextColor = E.noop

		header.isSkinned = true
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
	str:FontTemplate(nil, nil, '')
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
		if not header.isSkinned then
			header.flashAnim.Play = E.noop

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture()
			end

			header.description:SetTextColor(1, 1, 1)
			header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
			header.button.title.SetTextColor = E.noop
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = E.noop

			HandleButton(header.button)

			header.button.bg = CreateFrame('Frame', nil, header.button)
			header.button.bg:SetTemplate()
			header.button.bg:SetOutside(header.button.abilityIcon)
			header.button.bg:SetFrameLevel(header.button.bg:GetFrameLevel() - 1)
			header.button.abilityIcon:SetTexCoord(.08, .92, .08, .92)

			header.isSkinned = true
		end

		if header.button.abilityIcon:IsShown() then
			header.button.bg:Show()
		else
			header.button.bg:Hide()
		end

		index = index + 1
		header = _G['EncounterJournalInfoHeader'..index]
	end
end

local function ItemSetsItemBorder(border, atlas)
	local parent = border:GetParent()
	local backdrop = parent and parent.Icon and parent.Icon.backdrop
	if backdrop then
		local color = E.QualityColors[lootQuality[atlas]]
		if color then
			backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
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
	EJ.navBar.home.xoffset = 1

	S:HandleEditBox(EJ.searchBox)
	EJ.searchBox:ClearAllPoints()
	EJ.searchBox:Point('TOPLEFT', EJ.navBar, 'TOPRIGHT', 4, 0)

	local InstanceSelect = EJ.instanceSelect
	InstanceSelect.bg:Kill()

	S:HandleDropDownBox(InstanceSelect.tierDropDown)
	S:HandleTrimScrollBar(InstanceSelect.ScrollBar)

	-- Bottom tabs
	for _, tab in next, {
		_G.EncounterJournalSuggestTab,
		_G.EncounterJournalDungeonTab,
		_G.EncounterJournalRaidTab,
		_G.EncounterJournalLootJournalTab
	} do
		S:HandleTab(tab)
	end

	_G.EncounterJournalSuggestTab:ClearAllPoints()
	_G.EncounterJournalDungeonTab:ClearAllPoints()
	_G.EncounterJournalRaidTab:ClearAllPoints()
	_G.EncounterJournalLootJournalTab:ClearAllPoints()

	_G.EncounterJournalSuggestTab:Point('TOPLEFT', _G.EncounterJournal, 'BOTTOMLEFT', -3, 0)
	_G.EncounterJournalDungeonTab:Point('TOPLEFT', _G.EncounterJournalSuggestTab, 'TOPRIGHT', -5, 0)
	_G.EncounterJournalRaidTab:Point('TOPLEFT', _G.EncounterJournalDungeonTab, 'TOPRIGHT', -5, 0)
	_G.EncounterJournalLootJournalTab:Point('TOPLEFT', _G.EncounterJournalRaidTab, 'TOPRIGHT', -5, 0)

	--Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterInfo:SetTemplate('Transparent')

	EncounterInfo.encounterTitle:Kill()

	EncounterInfo.instanceButton.icon:Size(32)
	EncounterInfo.instanceButton.icon:SetTexCoord(0, 1, 0, 1)
	EncounterInfo.instanceButton:SetNormalTexture(E.ClearTexture)
	EncounterInfo.instanceButton:SetHighlightTexture(E.ClearTexture)

	EncounterInfo.leftShadow:Kill()
	EncounterInfo.rightShadow:Kill()
	EncounterInfo.model.dungeonBG:Kill()
	_G.EncounterJournalEncounterFrameInfoBG:Height(385)
	_G.EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()

	EncounterInfo.instanceButton:ClearAllPoints()
	EncounterInfo.instanceButton:Point('TOPLEFT', EncounterInfo, 'TOPLEFT', 0, 10)

	EncounterInfo.instanceTitle:ClearAllPoints()
	EncounterInfo.instanceTitle:Point('BOTTOM', EncounterInfo.bossesScroll, 'TOP', 10, 15)

	EncounterInfo.difficulty:StripTextures()
	EncounterInfo.reset:StripTextures()

	-- Buttons
	EncounterInfo.difficulty:ClearAllPoints()
	EncounterInfo.difficulty:Point('BOTTOMRIGHT', _G.EncounterJournalEncounterFrameInfoBG, 'TOPRIGHT', -5, 7)
	HandleButton(EncounterInfo.reset)
	HandleButton(EncounterInfo.difficulty)

	EncounterInfo.reset:ClearAllPoints()
	EncounterInfo.reset:Point('TOPRIGHT', EncounterInfo.difficulty, 'TOPLEFT', -10, 0)
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]])
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)

	S:HandleTrimScrollBar(EncounterInfo.BossesScrollBar)
	S:HandleTrimScrollBar(_G.EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)
	_G.EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.85)
	_G.EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameBG:Point('CENTER', 0, 40)
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:Point('TOP', 0, -105)
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:Point('LEFT', 55, -56)

	S:HandleScrollBar(EncounterInfo.overviewScroll.ScrollBar)
	S:HandleScrollBar(EncounterInfo.detailsScroll.ScrollBar)
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
			tab.backdrop:SetInside(2, 2)

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

				local r, g, b = unpack(E.media.bordercolor)
				if rewardData.itemID then
					local quality = select(3, GetItemInfo(rewardData.itemID))
					if quality and quality > 1 then
						r, g, b = GetItemQualityColor(quality)
					end
				end
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

	-- Powers
	local LJ = EJ.LootJournal
	HandleButton(LJ.ClassDropDownButton, true)
	LJ.ClassDropDownButton:SetFrameLevel(10)
	HandleButton(LJ.RuneforgePowerFilterDropDownButton, true)
	LJ.RuneforgePowerFilterDropDownButton:SetFrameLevel(10)

	S:HandleTrimScrollBar(_G.EncounterJournal.LootJournal.ScrollBar)

	for _, button in next, { _G.EncounterJournalEncounterFrameInfoFilterToggle, _G.EncounterJournalEncounterFrameInfoSlotFilterToggle } do
		HandleButton(button, true)
	end

	hooksecurefunc(_G.EncounterJournal.instanceSelect.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				child:SetNormalTexture(E.ClearTexture)
				child:SetHighlightTexture(E.ClearTexture)
				child:SetPushedTexture(E.ClearTexture)

				local bgImage = child.bgImage
				if bgImage then
					bgImage:CreateBackdrop()
					bgImage.backdrop:Point('TOPLEFT', 3, -3)
					bgImage.backdrop:Point('BOTTOMRIGHT', -4, 2)
				end

				child.isSkinned = true
			end
		end
	end)

	if E.private.skins.parchmentRemoverEnable then
		LJ:StripTextures()
		LJ:SetTemplate('Transparent')

		hooksecurefunc(_G.EncounterJournal.encounter.info.BossesScrollBox, 'Update', function(frame)
			for _, child in next, { frame.ScrollTarget:GetChildren() } do
				if not child.isSkinned then
					S:HandleButton(child)

					local hl = child:GetHighlightTexture()
					hl:SetColorTexture(1, 1, 1, .25)
					hl:SetInside()

					child.text:SetTextColor(1, 1, 1)
					child.text.SetTextColor = E.noop
					child.creature:Point('TOPLEFT', 0, -4)

					child.isSkinned = true
				end
			end
		end)

		hooksecurefunc(_G.EncounterJournal.encounter.info.LootContainer.ScrollBox, 'Update', function(frame)
			for _, child in next, { frame.ScrollTarget:GetChildren() } do
				if not child.isSkinned then
					if child.bossTexture then child.bossTexture:SetAlpha(0) end
					if child.bosslessTexture then child.bosslessTexture:SetAlpha(0) end

					if child.name then
						child.name:ClearAllPoints()
						child.name:Point('TOPLEFT', child.icon, 'TOPRIGHT', 6, -2)
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

					if child.icon then
						child.icon:SetSize(32, 32)
						child.icon:Point('TOPLEFT', E.PixelMode and 3 or 4, -(E.PixelMode and 7 or 8))
						S:HandleIcon(child.icon, true)
						S:HandleIconBorder(child.IconBorder, child.icon.backdrop)
					end

					if not child.backdrop then
						child:CreateBackdrop('Transparent')
						child.backdrop:Point('TOPLEFT')
						child.backdrop:Point('BOTTOMRIGHT', 0, 1)
					end

					child.isSkinned = true
				end
			end
		end)

		hooksecurefunc('EncounterJournal_SetUpOverview', SkinOverviewInfo)
		hooksecurefunc('EncounterJournal_SetBullets', SkinOverviewInfoBullets)
		hooksecurefunc('EncounterJournal_ToggleHeaders', SkinAbilitiesInfo)

		_G.EncounterJournalEncounterFrameInfoBG:Kill()
		EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)
		EncounterInfo.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)

		_G.EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")
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
			if child.FontString then
				child.FontString:SetTextColor(1, 1, 1)
			end
		end

		local parchment = LJ:GetRegions()
		if parchment then
			parchment:Kill()
		end
	end

	local LootDropdown = _G.EncounterJournalLootJournalViewDropDown
	S:HandleDropDownBox(LootDropdown)
	LootDropdown:SetScript('OnShow', function(dd) dd:SetFrameLevel(5) end) -- might be able to hook a function later; hotfix builds didn't export Blizzard_LootJournalItems.xml

	do -- Item Sets
		local ItemSetsFrame = EJ.LootJournalItems.ItemSetsFrame
		HandleButton(ItemSetsFrame.ClassButton, true)
		S:HandleScrollBar(ItemSetsFrame.scrollBar)

		if E.private.skins.parchmentRemoverEnable then
			EJ.LootJournalItems:StripTextures()
			EJ.LootJournalItems:SetTemplate('Transparent')

			hooksecurefunc(ItemSetsFrame, 'UpdateList', function(frame)
				if frame.buttons then
					for _, button in ipairs(frame.buttons) do
						if button and not button.backdrop then
							button:CreateBackdrop('Transparent')
							button.Background:Hide()
						end
					end
				end
			end)
		end

		hooksecurefunc(ItemSetsFrame, 'ConfigureItemButton', function(_, button)
			if not button.Icon then return end

			if not button.Icon.backdrop then
				S:HandleIcon(button.Icon, true)
			end

			if button.Border and not button.Border.isSkinned then
				button.Border:SetAlpha(0)

				ItemSetsItemBorder(button.Border, button.Border:GetAtlas()) -- handle first one
				hooksecurefunc(button.Border, 'SetAtlas', ItemSetsItemBorder)

				button.Border.isSkinned = true
			end
		end)
	end
end

S:AddCallbackForAddon('Blizzard_EncounterJournal')
