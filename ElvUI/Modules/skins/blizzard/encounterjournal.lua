local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function SkinDungeons()
	local b1 = _G.EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
	if b1 and not b1.isSkinned then
		S:HandleButton(b1)
		b1.bgImage:SetInside()
		b1.bgImage:SetTexCoord(.08, .6, .08, .6)
		b1.bgImage:SetDrawLayer("ARTWORK")
		b1.isSkinned = true
	end

	for i = 1, 100 do
		local b = _G["EncounterJournalInstanceSelectScrollFrameinstance"..i]
		if b and not b.isSkinned then
			S:HandleButton(b)
			b.bgImage:SetInside()
			b.bgImage:SetTexCoord(0.08,.6,0.08,.6)
			b.bgImage:SetDrawLayer("ARTWORK")
			b.isSkinned = true
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

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true then return end

	local EJ = _G.EncounterJournal
	S:HandlePortraitFrame(EJ, true)

	EJ.navBar:StripTextures(true)
	EJ.navBar.overlay:StripTextures(true)

	EJ.navBar:CreateBackdrop()
	EJ.navBar.backdrop:Point("TOPLEFT", -2, 0)
	EJ.navBar.backdrop:Point("BOTTOMRIGHT")
	S:HandleButton(EJ.navBar.home, true)


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
	InstanceSelect.dungeonsTab:ClearAllPoints()
	InstanceSelect.dungeonsTab:Point("BOTTOMLEFT", InstanceSelect.suggestTab, "BOTTOMRIGHT", 0, 0)
	InstanceSelect.raidsTab:ClearAllPoints()
	InstanceSelect.raidsTab:Point("BOTTOMLEFT", InstanceSelect.dungeonsTab, "BOTTOMRIGHT", 0, 0)
	InstanceSelect.LootJournalTab:ClearAllPoints()
	InstanceSelect.LootJournalTab:Point("BOTTOMLEFT", InstanceSelect.raidsTab, "BOTTOMRIGHT", 0, 0)

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
	EncounterInfo:CreateBackdrop()
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
	S:HandleButton(EncounterInfo.reset)
	S:HandleButton(EncounterInfo.difficulty)
	S:HandleButton(_G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle, true)
	S:HandleButton(_G.EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle, true)

	_G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle:SetPoint("BOTTOMLEFT", EncounterInfo.backdrop, "TOP", 0, 4)
	_G.EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SetPoint("LEFT", _G.EncounterJournalEncounterFrameInfoLootScrollFrameSlotFilterToggle, "RIGHT", 4, 0)

	EncounterInfo.reset:ClearAllPoints()
	EncounterInfo.reset:Point("TOPRIGHT", EncounterInfo.difficulty, "TOPLEFT", -10, 0)
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)


	S:HandleScrollBar(EncounterInfo.bossesScroll.ScrollBar, 6)
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
			S:HandleButton(suggestion.button)
			S:HandleNextPrevButton(suggestion.prevButton)
			S:HandleNextPrevButton(suggestion.nextButton)
		else
			S:HandleButton(suggestion.centerDisplay.button)
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

	--CreatureButtons

	--[[local function UpdatePortraits()
		print("fired")
		local creatures = EncounterJournal.encounter.info.creatureButtons;
		for i = 1, #creatures do
			local button = creatures[i];
			if ( button and button:IsShown() ) then
				button:SetNormalTexture("")
				button:SetHighlightTexture("")
				button.creature:SetMask('Interface\\ChatFrame\\ChatFrameBackground')
				--SetPortraitTextureFromCreatureDisplayID(button.creature, button.displayInfo);
			else
				break;
			end
		end
	end
	UpdatePortraits()
	hooksecurefunc("EncounterJournal_UpdatePortraits", UpdatePortraits)]]
end

S:AddCallbackForAddon('Blizzard_EncounterJournal', "EncounterJournal", LoadSkin)
