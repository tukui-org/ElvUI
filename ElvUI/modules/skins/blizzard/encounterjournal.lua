local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

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
	EJ.navBar.backdrop:SetPoint("BOTTOMRIGHT")
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
	InstanceSelect.suggestTab:SetWidth(InstanceSelect.suggestTab:GetWidth() + 24)
	InstanceSelect.dungeonsTab:SetWidth(InstanceSelect.dungeonsTab:GetWidth() + 10)
	InstanceSelect.dungeonsTab:ClearAllPoints()
	InstanceSelect.dungeonsTab:SetPoint("BOTTOMLEFT", InstanceSelect.suggestTab, "BOTTOMRIGHT", 0, 0)
	InstanceSelect.raidsTab:ClearAllPoints()
	InstanceSelect.raidsTab:SetPoint("BOTTOMLEFT", InstanceSelect.dungeonsTab, "BOTTOMRIGHT", 0, 0)
	
	--Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterJournalEncounterFrameInfoBG:Kill()
	EncounterInfo.leftShadow:Kill()
	EncounterInfo.rightShadow:Kill()
	EncounterInfo.model.dungeonBG:Kill()
	EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()
	
	EncounterInfo.instanceButton:ClearAllPoints()
	EncounterInfo.instanceButton:SetPoint("TOPLEFT", EncounterInfo, "TOPLEFT", 0, 15)
	EncounterInfo.instanceTitle:SetTextColor(1, 0.5, 0)
	EncounterInfo.instanceTitle:ClearAllPoints()
	EncounterInfo.instanceTitle:SetPoint("BOTTOM", EncounterInfo.bossesScroll, "TOP", 10, 15)
	
	EncounterInfo.difficulty:StripTextures()
	EncounterInfo.reset:StripTextures()
	S:HandleButton(EncounterInfo.reset)
	S:HandleButton(EncounterInfo.difficulty)
	EncounterInfo.difficulty:ClearAllPoints()
	EncounterInfo.difficulty:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInstanceFrame, "TOPRIGHT", 1, 5)
	EncounterInfo.reset:ClearAllPoints()
	EncounterInfo.reset:SetPoint("TOPRIGHT", EncounterInfo.difficulty, "TOPLEFT", -10, 0)
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)
	
	EncounterInfo.bossesScroll:CreateBackdrop("Transparent")
	EncounterInfo.bossesScroll.backdrop:SetPoint("TOPLEFT", EncounterInfo.bossesScroll, "TOPLEFT", -25, E.Border)

	EncounterInfo.overviewScroll:CreateBackdrop("Transparent")
	EncounterInfo.overviewScroll:SetHeight(EncounterInfo.overviewScroll:GetHeight() - (2 + E.Border))
	EncounterInfo.overviewScroll:SetWidth(360)
	EncounterInfo.overviewScroll:ClearAllPoints()
	EncounterInfo.overviewScroll:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrame, "BOTTOMRIGHT", -1, 5)
	EncounterInfo.overviewScroll.backdrop:SetPoint("TOPLEFT", EncounterInfo.bossesScroll.backdrop, "TOPRIGHT", 5, 0)
	EncounterInfo.overviewScroll.backdrop:SetPoint("BOTTOMLEFT", EncounterInfo.bossesScroll.backdrop, "BOTTOMRIGHT", 5, 0)

	S:HandleScrollBar(EncounterInfo.detailsScroll.ScrollBar, 4)
	S:HandleScrollBar(EncounterInfo.lootScroll.scrollBar, 4)
	S:HandleScrollBar(EncounterInfo.bossesScroll.ScrollBar, 4)
	S:HandleScrollBar(EncounterInfo.overviewScroll.ScrollBar, 4)

	EncounterInfo.overviewTab:Point('TOPLEFT', EncounterInfo, 'TOPRIGHT', E.PixelMode and -3 or 0, -35)
	EncounterInfo.overviewTab.SetPoint = E.noop
	EncounterInfo.overviewTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.overviewTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.overviewTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.overviewTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.overviewTab:CreateBackdrop('Default')
	EncounterInfo.overviewTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.overviewTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterInfo.overviewTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)
	
	EncounterInfo.lootTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.lootTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.lootTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.lootTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.lootTab:CreateBackdrop('Default')
	EncounterInfo.lootTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.lootTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterInfo.lootTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)
	
	EncounterInfo.bossTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.bossTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.bossTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.bossTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.bossTab:CreateBackdrop('Default')
	EncounterInfo.bossTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.bossTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterInfo.bossTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)
	
	EncounterInfo.modelTab:GetNormalTexture():SetTexture(nil)
	EncounterInfo.modelTab:GetPushedTexture():SetTexture(nil)
	EncounterInfo.modelTab:GetDisabledTexture():SetTexture(nil)
	EncounterInfo.modelTab:GetHighlightTexture():SetTexture(nil)
	EncounterInfo.modelTab:CreateBackdrop('Default')
	EncounterInfo.modelTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterInfo.modelTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterInfo.modelTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)

	
	--Encounter Instance Frame
	local EncounterInstance = EJ.encounter.instance
	EncounterInstance:CreateBackdrop("Transparent")
	EncounterInstance:SetHeight(EncounterInfo.bossesScroll:GetHeight())
	EncounterInstance:ClearAllPoints()
	EncounterInstance:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrame, "BOTTOMRIGHT", -1, 3)
	EncounterInstance.loreBG:SetSize(325, 280)
	EncounterInstance.loreBG:ClearAllPoints()
	EncounterInstance.loreBG:SetPoint("TOP", EncounterInstance, "TOP", 0, 0)
	EncounterInstance.mapButton:ClearAllPoints()
	EncounterInstance.mapButton:SetPoint("BOTTOMLEFT", EncounterInstance.loreBG, "BOTTOMLEFT", 25, 35)
	S:HandleScrollBar(EncounterInstance.loreScroll.ScrollBar, 4)
	EncounterInstance.loreScroll.child.lore:SetTextColor(1,1,1)
	
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
end

S:RegisterSkin('Blizzard_EncounterJournal', LoadSkin)