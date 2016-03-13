local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select, unpack, pairs = select, unpack, pairs

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true then return end

	local EJ = EncounterJournal
	EJ:StripTextures(true)
	EJ.inset:StripTextures(true)
	EJ:CreateBackdrop("Transparent")

	EJ.navBar:StripTextures(true)
	EJ.navBar.overlay:StripTextures(true)

	EJ.navBar:CreateBackdrop("Default")
	EJ.navBar.backdrop:Point("TOPLEFT", -2, 0)
	EJ.navBar.backdrop:Point("BOTTOMRIGHT")
	S:HandleButton(EJ.navBar.home, true)

	S:HandleEditBox(EJ.searchBox)
	S:HandleCloseButton(EncounterJournalCloseButton)

	--Instance Selection Frame
	local InstanceSelect = EJ.instanceSelect
	InstanceSelect.bg:Kill()
	S:HandleDropDownBox(InstanceSelect.tierDropDown)
	S:HandleScrollBar(InstanceSelect.scroll.ScrollBar, 4)
	S:HandleTab(InstanceSelect.suggestTab)
	S:HandleTab(InstanceSelect.dungeonsTab)
	S:HandleTab(InstanceSelect.raidsTab)
	InstanceSelect.suggestTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.dungeonsTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.raidsTab.backdrop:SetTemplate("Default", true)
	InstanceSelect.suggestTab:Width(InstanceSelect.suggestTab:GetWidth() + 24)
	InstanceSelect.dungeonsTab:Width(InstanceSelect.dungeonsTab:GetWidth() + 10)
	InstanceSelect.dungeonsTab:ClearAllPoints()
	InstanceSelect.dungeonsTab:Point("BOTTOMLEFT", InstanceSelect.suggestTab, "BOTTOMRIGHT", 0, 0)
	InstanceSelect.raidsTab:ClearAllPoints()
	InstanceSelect.raidsTab:Point("BOTTOMLEFT", InstanceSelect.dungeonsTab, "BOTTOMRIGHT", 0, 0)

	--Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterJournalEncounterFrameInfoBG:Kill()
	EncounterInfo.leftShadow:Kill()
	EncounterInfo.rightShadow:Kill()
	EncounterInfo.model.dungeonBG:Kill()
	EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()

	EncounterInfo.instanceButton:ClearAllPoints()
	EncounterInfo.instanceButton:Point("TOPLEFT", EncounterInfo, "TOPLEFT", 0, 15)
	EncounterInfo.instanceTitle:ClearAllPoints()
	EncounterInfo.instanceTitle:Point("BOTTOM", EncounterInfo.bossesScroll, "TOP", 10, 15)

	EncounterInfo.difficulty:StripTextures()
	EncounterInfo.reset:StripTextures()
	S:HandleButton(EncounterInfo.reset)
	S:HandleButton(EncounterInfo.difficulty)
	EncounterInfo.difficulty:ClearAllPoints()
	EncounterInfo.difficulty:Point("BOTTOMRIGHT", EncounterJournalEncounterFrameInstanceFrame, "TOPRIGHT", 1, 5)
	EncounterInfo.reset:ClearAllPoints()
	EncounterInfo.reset:Point("TOPRIGHT", EncounterInfo.difficulty, "TOPLEFT", -10, 0)
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)

	EncounterInfo.bossesScroll:CreateBackdrop("Transparent")
	EncounterInfo.bossesScroll.backdrop:Point("TOPLEFT", EncounterInfo.bossesScroll, "TOPLEFT", -25, E.Border)
	S:HandleScrollBar(EncounterInfo.bossesScroll.ScrollBar, 4)


	local scrollFrames = {
		EncounterInfo.overviewScroll,
		EncounterInfo.lootScroll,
		EncounterInfo.detailsScroll,
	}

	for _, scrollFrame in pairs(scrollFrames) do
		scrollFrame:CreateBackdrop("Transparent")
		scrollFrame:Height(EncounterInfo.overviewScroll:GetHeight() - (2 + E.Border))
		scrollFrame:Width(370)
		scrollFrame:ClearAllPoints()
		scrollFrame:Point("BOTTOMRIGHT", EncounterJournalEncounterFrame, "BOTTOMRIGHT", -1, 5)
		scrollFrame.backdrop:Point("TOPLEFT", EncounterInfo.bossesScroll.backdrop, "TOPRIGHT", 5, 0)
		scrollFrame.backdrop:Point("BOTTOMLEFT", EncounterInfo.bossesScroll.backdrop, "BOTTOMRIGHT", 5, 0)
	end

	S:HandleScrollBar(EncounterInfo.overviewScroll.ScrollBar, 4)
	S:HandleScrollBar(EncounterInfo.detailsScroll.ScrollBar, 4)
	S:HandleScrollBar(EncounterInfo.lootScroll.scrollBar, 4)

	EncounterInfo.lootScroll.filter:StripTextures()
	S:HandleButton(EncounterInfo.lootScroll.filter)
	EncounterInfo.lootScroll.filter:ClearAllPoints()
	EncounterInfo.lootScroll.filter:Point("BOTTOMLEFT", EncounterInfo.lootScroll.backdrop, "TOPLEFT", 0, 5)
	EncounterInfo.lootScroll.classClearFilter:ClearAllPoints()
	EncounterInfo.lootScroll.classClearFilter:Point("BOTTOM", EncounterInfo.lootScroll, "TOP", -10, -8)

	EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)
	EncounterInfo.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 1, 1)
	EncounterInfo.overviewScroll.child.overviewDescription.Text:SetTextColor(1, 1, 1)

	EncounterInfo.overviewTab:Point('TOPLEFT', EncounterInfo, 'TOPRIGHT', E.PixelMode and -3 or 0, -35)
	EncounterInfo.overviewTab.SetPoint = E.noop
	EncounterInfo.overviewTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.overviewTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.overviewTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.overviewTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.overviewTab:CreateBackdrop('Default', true)
	EncounterInfo.overviewTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.overviewTab.backdrop:Point('BOTTOMRIGHT', -6, 8)

	EncounterInfo.lootTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.lootTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.lootTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.lootTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.lootTab:CreateBackdrop('Default')
	EncounterInfo.lootTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.lootTab.backdrop:Point('BOTTOMRIGHT', -6, 8)

	EncounterInfo.bossTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.bossTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.bossTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.bossTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.bossTab:CreateBackdrop('Default')
	EncounterInfo.bossTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.bossTab.backdrop:Point('BOTTOMRIGHT', -6, 8)

	EncounterInfo.modelTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.modelTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.modelTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.modelTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.modelTab:CreateBackdrop('Default')
	EncounterInfo.modelTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.modelTab.backdrop:Point('BOTTOMRIGHT', -6, 8)

	--Encounter Instance Frame
	local EncounterInstance = EJ.encounter.instance
	EncounterInstance:CreateBackdrop("Transparent")
	EncounterInstance:Height(EncounterInfo.bossesScroll:GetHeight())
	EncounterInstance:ClearAllPoints()
	EncounterInstance:Point("BOTTOMRIGHT", EncounterJournalEncounterFrame, "BOTTOMRIGHT", -1, 3)
	EncounterInstance.loreBG:SetSize(325, 280)
	EncounterInstance.loreBG:ClearAllPoints()
	EncounterInstance.loreBG:Point("TOP", EncounterInstance, "TOP", 0, 0)
	EncounterInstance.mapButton:ClearAllPoints()
	EncounterInstance.mapButton:Point("BOTTOMLEFT", EncounterInstance.loreBG, "BOTTOMLEFT", 25, 35)
	S:HandleScrollBar(EncounterInstance.loreScroll.ScrollBar, 4)
	EncounterInstance.loreScroll.child.lore:SetTextColor(1, 1, 1)

	--Suggestions
	for i = 1, AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = EncounterJournal.suggestFrame["Suggestion"..i];
		if i == 1 then
			S:HandleButton(suggestion.button)
			S:HandleNextPrevButton(suggestion.prevButton)
			S:HandleNextPrevButton(suggestion.nextButton)
		else
			S:HandleButton(suggestion.centerDisplay.button)
		end
	end

	--Suggestion Reward Tooltips
	local tooltip = EncounterJournalTooltip
	local item1 = tooltip.Item1
	local item2 = tooltip.Item2
	tooltip:SetTemplate("Transparent")
	S:HandleIcon(item1.icon)
	S:HandleIcon(item2.icon)
	item1.IconBorder:SetTexture(nil)
	item2.IconBorder:SetTexture(nil)

	--Dungeon/raid selection buttons (From AddOnSkins)
	local function SkinDungeons()
		local b1 = EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
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
	hooksecurefunc("EncounterJournal_ListInstances", SkinDungeons)
	EncounterJournal_ListInstances()

	--Boss selection buttons
	local function SkinBosses()
		local bossIndex = 1;
		local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
		local bossButton;

		while bossID do
			bossButton = _G["EncounterJournalBossButton"..bossIndex];
			if bossButton and not bossButton.isSkinned then
				S:HandleButton(bossButton)
				bossButton.isSkinned = true
			end

			bossIndex = bossIndex + 1;
			name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
		end
	end
	hooksecurefunc("EncounterJournal_DisplayInstance", SkinBosses)

	--Loot buttons
	local items = EncounterJournal.encounter.info.lootScroll.buttons
	for i = 1, #items do
		local item = items[i]

		item.boss:SetTextColor(1, 1, 1)
		item.boss:ClearAllPoints()
		item.boss:Point("BOTTOMLEFT", 4, 7)
		item.slot:SetTextColor(1, 1, 1)
		item.armorType:SetTextColor(1, 1, 1)
		item.armorType:ClearAllPoints()
		item.armorType:Point("BOTTOMRIGHT", item.name, "TOPLEFT", 264, -25)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.icon:SetSize(36, 36)
		item.icon:Point("TOPLEFT", E.PixelMode and 1 or 2, -(E.PixelMode and 5 or 7))

		S:HandleIcon(item.icon)
		item.icon:SetDrawLayer("OVERLAY")

		item:CreateBackdrop("Transparent")
		item.backdrop:Point("TOPLEFT", 0, -4)
		item.backdrop:Point("BOTTOMRIGHT", 0, E.PixelMode and 3 or 0)

		if i == 1 then
			item:ClearAllPoints()
			item:Point("TOPLEFT", EncounterInfo.lootScroll.scrollChild, "TOPLEFT", 5, 0)
		end
	end

	--Overview Info (From Aurora)
	local function SkinOverviewInfo(self, role, index)
		local header = self.overviews[index]
		if not header.isSkinned then

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture("")
			end

			S:HandleButton(header.button)

			header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
			header.button.title.SetTextColor = E.noop
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = E.noop

			header.isSkinned = true
		end
	end
	hooksecurefunc("EncounterJournal_SetUpOverview", SkinOverviewInfo)

	--Overview Info Bullets (From Aurora)
	local function SkinOverviewInfoBullets(object, description)
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
	hooksecurefunc("EncounterJournal_SetBullets", SkinOverviewInfoBullets)

	--Abilities Info (From Aurora)
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

				S:HandleButton(header.button)

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
	hooksecurefunc("EncounterJournal_ToggleHeaders", SkinAbilitiesInfo)
end

S:RegisterSkin('Blizzard_EncounterJournal', LoadSkin)