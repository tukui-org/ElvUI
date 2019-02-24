local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local rad = math.rad

local function HandleButton(btn, ...)
	S:HandleButton(btn, ...)
	if btn:GetFontString() then
		btn:GetFontString():SetTextColor(1, 1, 1)
	end
end


local function SkinDungeons()
	local b1 = _G.EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
	if b1 and not b1.isSkinned then
		HandleButton(b1)
		b1.bgImage:SetInside()
		b1.bgImage:SetTexCoord(.08, .6, .08, .6)
		b1.bgImage:SetDrawLayer("ARTWORK")
		b1.isSkinned = true
	end

	for i = 1, 100 do
		local b = _G["EncounterJournalInstanceSelectScrollFrameinstance"..i]
		if b and not b.isSkinned then
			HandleButton(b)
			b.bgImage:SetInside()
			b.bgImage:SetTexCoord(0.08,.6,0.08,.6)
			b.bgImage:SetDrawLayer("ARTWORK")
			b.isSkinned = true
		end
	end
end

local function SkinBosses()
	local bossIndex = 1;
	local _, _, bossID = _G.EJ_GetEncounterInfoByIndex(bossIndex);
	local bossButton;

	while bossID do
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
		if bossButton and not bossButton.isSkinned then
			HandleButton(bossButton)
			bossButton.creature:ClearAllPoints()
			bossButton.creature:Point("TOPLEFT", 1, -4)
			bossButton.isSkinned = true
		end

		bossIndex = bossIndex + 1;
		_, _, bossID = _G.EJ_GetEncounterInfoByIndex(bossIndex);
	end
end

local function SkinOverviewInfo(self, _, index)
	local header = self.overviews[index]
	if not header.isSkinned then

		header.descriptionBG:SetAlpha(0)
		header.descriptionBGBottom:SetAlpha(0)
		for i = 4, 18 do
			select(i, header.button:GetRegions()):SetTexture("")
		end

		HandleButton(header.button)

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
		for _, bullet in pairs(parent.Bullets) do
			if not bullet.styled then
				bullet.Text:SetTextColor(1, 1, 1)
				bullet.styled = true
			end
		end
	end
end

local function HandleTabs(tab)
	tab:StripTextures()
	tab:SetText(tab.tooltip)
	tab:GetFontString():FontTemplate(nil, nil, "")
	tab:CreateBackdrop()
	tab:SetScript("OnEnter", E.noop)
	tab:SetScript("OnLeave", E.noop)
	tab:SetSize(tab:GetFontString():GetStringWidth()*1.5, 20)
	tab.SetPoint = E.noop
end


local function SkinAbilitiesInfo()
	local index = 1
	local header = _G["EncounterJournalInfoHeader"..index]
	while header do
		if not header.isSkinned then
			header.flashAnim.Play = E.noop

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture("")
			end

			header.description:SetTextColor(1, 1, 1)
			header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
			header.button.title.SetTextColor = E.noop
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = E.noop

			HandleButton(header.button)

			header.button.bg = CreateFrame("Frame", nil, header.button)
			header.button.bg:SetTemplate("Default")
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
		header = _G["EncounterJournalInfoHeader"..index]
	end
end

local function ItemSetsFrame(parent, button)
	local frame = button:GetParent()

	if not button.Icon.backdrop then
		S:HandleIcon(button.Icon, true)
		button.Border:SetAlpha(0)

		if E.private.skins.parchmentRemover.enable then
			frame:StripTextures()
			frame.ItemLevel:SetTextColor(1, 1, 1)
			frame:CreateBackdrop("Transparent")
			frame.backdrop:SetPoint("BOTTOMLEFT")
			frame.backdrop:SetPoint("TOPLEFT", 10, 0)
		end
	end

	button.Icon.backdrop:SetBackdropBorderColor(frame.SetName:GetTextColor())
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true then return end

	local EJ = _G.EncounterJournal
	S:HandlePortraitFrame(EJ, true)

	EJ.navBar:StripTextures(true)
	EJ.navBar.overlay:StripTextures(true)

	EJ.navBar:CreateBackdrop()
	EJ.navBar.backdrop:Point("TOPLEFT", -2, 0)
	EJ.navBar.backdrop:Point("BOTTOMRIGHT")
	HandleButton(EJ.navBar.home, true)


	S:HandleEditBox(EJ.searchBox)
	EJ.searchBox:ClearAllPoints()
	EJ.searchBox:SetPoint("TOPLEFT", EJ.navBar, "TOPRIGHT", 4, 0)

	local InstanceSelect = EJ.instanceSelect
	_G.EncounterJournalEncounterFrameInfoInstanceTitle:Kill()

	EJ.instanceSelect.bg:Kill()
	S:HandleDropDownBox(InstanceSelect.tierDropDown)
	EJ.instanceSelect.tierDropDown:HookScript("OnShow", function(self)
		local text = self.Text
		local a, b, c, d, e = text:GetPoint()
		text:SetPoint(a, b, c, d + 10, e - 4)
		text:SetWidth(self:GetWidth() / 1.4)
	end)

	S:HandleScrollBar(InstanceSelect.scroll.ScrollBar, 6)
	S:HandleTab(InstanceSelect.suggestTab)
	S:HandleTab(InstanceSelect.dungeonsTab)
	S:HandleTab(InstanceSelect.raidsTab)
	S:HandleTab(InstanceSelect.LootJournalTab)
	InstanceSelect.suggestTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.dungeonsTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.raidsTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.LootJournalTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.suggestTab:Width(InstanceSelect.suggestTab:GetWidth() + 24)
	InstanceSelect.dungeonsTab:Width(InstanceSelect.dungeonsTab:GetWidth() + 10)
	InstanceSelect.suggestTab:ClearAllPoints()
	InstanceSelect.suggestTab:SetPoint("BOTTOMLEFT", InstanceSelect, "TOPLEFT", -8, -45)
	InstanceSelect.dungeonsTab:ClearAllPoints()
	InstanceSelect.dungeonsTab:Point("BOTTOMLEFT", InstanceSelect.suggestTab, "BOTTOMRIGHT", -18, 0)
	InstanceSelect.raidsTab:ClearAllPoints()
	InstanceSelect.raidsTab:Point("BOTTOMLEFT", InstanceSelect.dungeonsTab, "BOTTOMRIGHT", -18, 0)
	InstanceSelect.LootJournalTab:ClearAllPoints()
	InstanceSelect.LootJournalTab:Point("BOTTOMLEFT", InstanceSelect.raidsTab, "BOTTOMRIGHT", -18, 0)

	--Skin the tab text
	for i = 1, #InstanceSelect.Tabs do
		local tab = InstanceSelect.Tabs[i]
		local text = tab:GetFontString()

		text:FontTemplate()
		text:SetPoint("CENTER")
	end

	_G.EncounterJournalEncounterFrameInfoInstanceButton:Kill()

	--Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterInfo:CreateBackdrop("Transparent")
	EncounterInfo.backdrop:SetOutside(_G.EncounterJournalEncounterFrameInfoBG)

	EncounterInfo.encounterTitle:Kill()

	--_G.EncounterJournalEncounterFrameInfoBG:Kill()
	_G.EncounterJournalEncounterFrameInfoBG:SetHeight(385)
	EncounterInfo.leftShadow:Kill()
	EncounterInfo.rightShadow:Kill()
	EncounterInfo.model.dungeonBG:Kill()
	_G.EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()

	EncounterInfo.instanceButton:ClearAllPoints()
	EncounterInfo.instanceButton:Point("TOPLEFT", EncounterInfo, "TOPLEFT", 0, 15)

	EncounterInfo.instanceTitle:ClearAllPoints()
	EncounterInfo.instanceTitle:Point("BOTTOM", EncounterInfo.bossesScroll, "TOP", 10, 15)

	_G.EncounterJournalEncounterFrameInfoLootScrollFrameClassFilterClearFrame:GetRegions():SetAlpha(0)

	EncounterInfo.difficulty:StripTextures()
	EncounterInfo.reset:StripTextures()


	--buttons
	EncounterInfo.difficulty:ClearAllPoints()
	EncounterInfo.difficulty:SetPoint("BOTTOMRIGHT", _G.EncounterJournalEncounterFrameInfoBG, "TOPRIGHT", -1, 5)
	HandleButton(EncounterInfo.reset)
	HandleButton(EncounterInfo.difficulty)
	HandleButton(_G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle, true)
	HandleButton(_G.EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle, true)

	_G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle:SetPoint("BOTTOMLEFT", EncounterInfo.backdrop, "TOP", 0, 4)
	_G.EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SetPoint("LEFT", _G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle, "RIGHT", 4, 0)

	EncounterInfo.reset:ClearAllPoints()
	EncounterInfo.reset:Point("TOPRIGHT", EncounterInfo.difficulty, "TOPLEFT", -10, 0)
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)


	S:HandleScrollBar(EncounterInfo.bossesScroll.ScrollBar, 6)
	S:HandleScrollBar(_G.EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar)
	_G.EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.85)
	_G.EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameBG:SetPoint("CENTER", 0, 40)
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:SetPoint("TOP", 0, -105)
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint("LEFT", 55, -56)

	S:HandleScrollBar(EncounterInfo.overviewScroll.ScrollBar, 4)
	S:HandleScrollBar(EncounterInfo.detailsScroll.ScrollBar, 4)
	S:HandleScrollBar(EncounterInfo.lootScroll.scrollBar, 4)

	EncounterInfo.detailsScroll:SetHeight(360)
	EncounterInfo.lootScroll:SetHeight(360)
	EncounterInfo.overviewScroll:SetHeight(360)
	EncounterInfo.bossesScroll:SetHeight(360)
	_G.EncounterJournalEncounterFrameInfoLootScrollFrame:SetHeight(360)
	_G.EncounterJournalEncounterFrameInfoLootScrollFrame:SetPoint("TOPLEFT", _G.EncounterJournalEncounterFrameInfoLootScrollFrame:GetParent(), "TOP", 20, -70)
	_G.EncounterJournalEncounterFrameInfoLootScrollFrame:SetPoint("BOTTOMRIGHT", _G.EncounterJournalEncounterFrameInfoLootScrollFrame:GetParent(), "BOTTOMRIGHT", -10, 5)

	--Tabs
	local tabs = {
		EncounterInfo.overviewTab,
		EncounterInfo.lootTab,
		EncounterInfo.bossTab,
		EncounterInfo.modelTab
	}

	for i=1, #tabs do --not beautiful but eh
		tabs[i]:ClearAllPoints()
	end

	for i=1, #tabs do
		local tab = tabs[i]

		if i == 4 then
			tab:SetPoint('TOPRIGHT', _G.EncounterJournal, 'BOTTOMRIGHT', -10, E.PixelMode and 0 or 2)
		else
			tab:SetPoint("RIGHT", tabs[i+1], "LEFT", -4, 0)
		end

		HandleTabs(tab)
	end

	hooksecurefunc("EncounterJournal_SetTabEnabled", function(tab, enabled)
		if enabled then
			tab:GetFontString():SetTextColor(1, 1, 1)
		else
			tab:GetFontString():SetTextColor(0.6, 0.6, 0.6)
		end
	end)


	-- Loot buttons
	local items = _G.EncounterJournal.encounter.info.lootScroll.buttons
	for i = 1, #items do
		local item = items[i]

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.icon:SetSize(32, 32)
		item.icon:Point("TOPLEFT", E.PixelMode and 3 or 4, -(E.PixelMode and 7 or 8))
		item.icon:SetDrawLayer("ARTWORK")
		item.icon:SetTexCoord(unpack(E.TexCoords))

		item.IconBackdrop = CreateFrame("Frame", nil, item)
		item.IconBackdrop:SetFrameLevel(item:GetFrameLevel())
		item.IconBackdrop:SetPoint("TOPLEFT", item.icon, -1, 1)
		item.IconBackdrop:SetPoint("BOTTOMRIGHT", item.icon, 1, -1)
		item.IconBackdrop:SetTemplate()

		item.name:ClearAllPoints()
		item.name:Point("TOPLEFT", item.icon, "TOPRIGHT", 6, -2)
		item.name:SetFontObject("QuestFont_Large")
		item.boss:ClearAllPoints()
		item.boss:Point("BOTTOMLEFT", 4, 6)
		item.slot:ClearAllPoints()
		item.slot:Point("TOPLEFT", item.name, "BOTTOMLEFT", 0, -3)

		item.armorType:ClearAllPoints()
		item.armorType:Point("RIGHT", item, "RIGHT", -10, 0)

		hooksecurefunc(item.IconBorder, "SetVertexColor", function(self, r, g, b)
			self:GetParent().IconBackdrop:SetBackdropBorderColor(r, g, b)
			self:SetTexture()
		end)

		if E.private.skins.parchmentRemover.enable then
			item.boss:SetTextColor(1, 1, 1)
			item.slot:SetTextColor(1, 1, 1)
			item.armorType:SetTextColor(1, 1, 1)			
		end


		if i == 1 then
			item:ClearAllPoints()
			item:Point("TOPLEFT", EncounterInfo.lootScroll.scrollChild, "TOPLEFT", 5, 0)
		end
	end

	-- Search
	_G.EncounterJournalSearchResults:StripTextures()
	_G.EncounterJournalSearchResults:SetTemplate()
	_G.EncounterJournalSearchBox.searchPreviewContainer:StripTextures()

	S:HandleCloseButton(_G.EncounterJournalSearchResultsCloseButton)
	S:HandleScrollBar(_G.EncounterJournalSearchResultsScrollFrameScrollBar)

	--Suggestions
	for i = 1, _G.AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = _G.EncounterJournal.suggestFrame["Suggestion"..i];
		if i == 1 then
			HandleButton(suggestion.button)
			S:HandleNextPrevButton(suggestion.prevButton, nil, nil, true)
			S:HandleNextPrevButton(suggestion.nextButton, nil, nil, true)
		else
			HandleButton(suggestion.centerDisplay.button)
		end
	end

	--Suggestion Reward Tooltips
	if E.private.skins.blizzard.tooltip then
		local tooltip = _G.EncounterJournalTooltip
		local item1 = tooltip.Item1
		local item2 = tooltip.Item2
		tooltip:SetTemplate("Transparent")
		S:HandleIcon(item1.icon)
		S:HandleIcon(item2.icon)
		item1.IconBorder:SetTexture()
		item2.IconBorder:SetTexture()
	end

	--Dungeon/raid selection buttons (From AddOnSkins)
	hooksecurefunc("EncounterJournal_ListInstances", SkinDungeons)
	_G.EncounterJournal_ListInstances()

	_G.EncounterJournal.LootJournal:CreateBackdrop("Transparent")
	local parch = _G.EncounterJournal.LootJournal:GetRegions()
	_G.EncounterJournal.LootJournal.backdrop:SetOutside(parch)


	HandleButton(_G.EncounterJournal.LootJournal.ItemSetsFrame.ClassButton, true)


	hooksecurefunc(EncounterJournal.LootJournal.ItemSetsFrame, "ConfigureItemButton", ItemSetsFrame)

	if E.private.skins.parchmentRemover.enable then
		--Boss selection buttons
		hooksecurefunc("EncounterJournal_DisplayInstance", SkinBosses)

		--Overview Info (From Aurora)
		hooksecurefunc("EncounterJournal_SetUpOverview", SkinOverviewInfo)

		--Overview Info Bullets (From Aurora)
		hooksecurefunc("EncounterJournal_SetBullets", SkinOverviewInfoBullets)

		--Abilities Info (From Aurora)
		hooksecurefunc("EncounterJournal_ToggleHeaders", SkinAbilitiesInfo)	
		
		_G.EncounterJournalEncounterFrameInfoBG:Kill()

		EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)
		EncounterInfo.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 1, 1)
		EncounterInfo.overviewScroll.child.overviewDescription.Text:SetTextColor(1, 1, 1)		
		EJ.encounter.instance.loreScroll.child.lore:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetTexCoord(0.71, 0.06, 0.582, 0.08)
		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetRotation(rad(180))
		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.7)
		_G.EncounterJournalEncounterFrameInstanceFrameBG:CreateBackdrop()
		_G.EncounterJournalEncounterFrameInstanceFrameMapButtonShadow:SetAlpha(0)
		_G.EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
		_G.EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint("BOTTOMLEFT", _G.EncounterJournalEncounterFrameInstanceFrameBG.backdrop, "BOTTOMLEFT", 5, 5)
		_G.EncounterJournalEncounterFrameInstanceFrame.titleBG:SetAlpha(0)
		_G.EncounterJournalEncounterFrameInstanceFrameTitle:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInstanceFrameTitle:FontTemplate(nil, 25)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetAlpha(0)
		_G.EncounterJournalEncounterFrameInstanceFrameMapButton:StripTextures()
		HandleButton(_G.EncounterJournalEncounterFrameInstanceFrameMapButton)
		_G.EncounterJournalEncounterFrameInstanceFrameMapButtonText:ClearAllPoints()
		_G.EncounterJournalEncounterFrameInstanceFrameMapButtonText:SetPoint("CENTER")
		_G.EncounterJournalEncounterFrameInstanceFrameMapButtonText:SetText(SHOW_MAP)
		_G.EncounterJournalEncounterFrameInstanceFrameMapButton:SetHeight(25)
		_G.EncounterJournalEncounterFrameInstanceFrameMapButton:SetWidth(_G.EncounterJournalEncounterFrameInstanceFrameMapButtonText:GetStringWidth()*1.5)

		parch:Kill()
	end

end

S:AddCallbackForAddon('Blizzard_EncounterJournal', "EncounterJournal", LoadSkin)
