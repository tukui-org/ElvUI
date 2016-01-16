local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true then return end
	EncounterJournal:StripTextures(true)
	EncounterJournal:CreateBackdrop("Transparent")

	EncounterJournalNavBar:StripTextures(true)
	EncounterJournalNavBarOverlay:StripTextures(true)

	EncounterJournalNavBar:CreateBackdrop("Default")
	EncounterJournalNavBar.backdrop:Point("TOPLEFT", -2, 0)
	EncounterJournalNavBar.backdrop:SetPoint("BOTTOMRIGHT")
	S:HandleButton(EncounterJournalNavBarHomeButton, true)

	S:HandleEditBox(EncounterJournalSearchBox)
	S:HandleCloseButton(EncounterJournalCloseButton)
	S:HandleDropDownBox(EncounterJournalInstanceSelectTierDropDown)

	EncounterJournalInset:StripTextures(true)
	EncounterJournalInstanceSelectBG:Kill()
	EncounterJournalEncounterFrameInfoBG:Kill()
	EncounterJournalEncounterFrameInfoLeftHeaderShadow:Kill()
	EncounterJournalEncounterFrameInfoBossesScrollFrame:CreateBackdrop("Transparent")
	EncounterJournalEncounterFrameInfoBossesScrollFrame.backdrop:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoBossesScrollFrame, "TOPLEFT", -25, E.Border)
	EncounterJournalEncounterFrameInfoInstanceButton:ClearAllPoints()
	EncounterJournalEncounterFrameInfoInstanceButton:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPLEFT", 0, 15)
	EncounterJournalEncounterFrameInfoInstanceTitle:SetTextColor(1, 0.5, 0)
	EncounterJournalEncounterFrameInfoInstanceTitle:ClearAllPoints()
	EncounterJournalEncounterFrameInfoInstanceTitle:SetPoint("BOTTOM", EncounterJournalEncounterFrameInfoBossesScrollFrame.backdrop, "TOP", 10, 15)
	
	S:HandleTab(EncounterJournalInstanceSelectSuggestTab)
	S:HandleTab(EncounterJournalInstanceSelectDungeonTab)
	S:HandleTab(EncounterJournalInstanceSelectRaidTab)
	EncounterJournalInstanceSelectSuggestTab.backdrop:SetTemplate("Default", true)
	EncounterJournalInstanceSelectDungeonTab.backdrop:SetTemplate("Default", true)
	EncounterJournalInstanceSelectRaidTab.backdrop:SetTemplate("Default", true)
	EncounterJournalInstanceSelectSuggestTab:SetWidth(EncounterJournalInstanceSelectSuggestTab:GetWidth() + 24)
	EncounterJournalInstanceSelectDungeonTab:SetWidth(EncounterJournalInstanceSelectDungeonTab:GetWidth() + 10)
	EncounterJournalInstanceSelectDungeonTab:ClearAllPoints()
	EncounterJournalInstanceSelectDungeonTab:SetPoint("BOTTOMLEFT", EncounterJournalInstanceSelectSuggestTab, "BOTTOMRIGHT", 0, 0)
	EncounterJournalInstanceSelectRaidTab:ClearAllPoints()
	EncounterJournalInstanceSelectRaidTab:SetPoint("BOTTOMLEFT", EncounterJournalInstanceSelectDungeonTab, "BOTTOMRIGHT", 0, 0)
	
	EncounterJournalEncounterFrameInfoDifficulty:StripTextures(true)
	S:HandleButton(EncounterJournalEncounterFrameInfoDifficulty)
	EncounterJournalEncounterFrameInfoDifficulty:ClearAllPoints()
	EncounterJournalEncounterFrameInfoDifficulty:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInstanceFrame, "TOPRIGHT", 1, 5)
	EncounterJournalEncounterFrameInfoResetButton:ClearAllPoints()
	EncounterJournalEncounterFrameInfoResetButton:SetPoint("TOPRIGHT", EncounterJournalEncounterFrameInfoDifficulty, "TOPLEFT", -10, 0)
	EncounterJournalEncounterFrameInfoResetButton:StripTextures()
	S:HandleButton(EncounterJournalEncounterFrameInfoResetButton)
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
	EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)
	
	
	EncounterJournalEncounterFrameInstanceFrame:CreateBackdrop("Transparent")
	EncounterJournalEncounterFrameInstanceFrame:SetHeight(EncounterJournalEncounterFrameInfoBossesScrollFrame:GetHeight())
	EncounterJournalEncounterFrameInstanceFrame:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrame:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrame, "BOTTOMRIGHT", -1, 3)
	EncounterJournalEncounterFrameInstanceFrameBG:SetSize(325, 280)
	EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameBG:SetPoint("TOP", EncounterJournalEncounterFrameInstanceFrame, "TOP", 0, 0)
	EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	EncounterJournalEncounterFrameInstanceFrameMapButton:SetPoint("BOTTOMLEFT", EncounterJournalEncounterFrameInstanceFrameBG, "BOTTOMLEFT", 25, 35)
	EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollChildLore:SetTextColor(1,1,1)
	
	EncounterJournalEncounterFrameInfoOverviewScrollFrame:CreateBackdrop("Transparent")
	EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetHeight(EncounterJournalEncounterFrameInfoOverviewScrollFrame:GetHeight() - (2 + E.Border))
	EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetWidth(360)
	EncounterJournalEncounterFrameInfoOverviewScrollFrame:ClearAllPoints()
	EncounterJournalEncounterFrameInfoOverviewScrollFrame:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrame, "BOTTOMRIGHT", -1, 5)
	EncounterJournalEncounterFrameInfoOverviewScrollFrame.backdrop:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoBossesScrollFrame.backdrop, "TOPRIGHT", 5, 0)
	EncounterJournalEncounterFrameInfoOverviewScrollFrame.backdrop:SetPoint("BOTTOMLEFT", EncounterJournalEncounterFrameInfoBossesScrollFrame.backdrop, "BOTTOMRIGHT", 5, 0)
	EncounterJournalEncounterFrameInfoRightHeaderShadow:Kill()

	EncounterJournalEncounterFrameInfoModelFrameDungeonBG:Kill()
	EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()
	
	
	
	S:HandleScrollBar(EncounterJournalInstanceSelectScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoBossesScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollBar, 4)

	EncounterJournalEncounterFrameInfoBossTab:GetNormalTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:GetPushedTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:GetDisabledTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoBossTab:GetHighlightTexture():SetTexture(nil)

	EncounterJournalEncounterFrameInfoLootTab:GetNormalTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:GetPushedTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:GetDisabledTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoLootTab:GetHighlightTexture():SetTexture(nil)

	EncounterJournalEncounterFrameInfoModelTab:GetNormalTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoModelTab:GetPushedTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoModelTab:GetDisabledTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoModelTab:GetHighlightTexture():SetTexture(nil)

	EncounterJournalEncounterFrameInfoOverviewTab:GetNormalTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoOverviewTab:GetPushedTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoOverviewTab:GetDisabledTexture():SetTexture(nil)
	EncounterJournalEncounterFrameInfoOverviewTab:GetHighlightTexture():SetTexture(nil)

	EncounterJournalEncounterFrameInfoOverviewTab:Point('TOPLEFT', EncounterJournalEncounterFrameInfo, 'TOPRIGHT', E.PixelMode and -3 or 0, -35)
	EncounterJournalEncounterFrameInfoOverviewTab.SetPoint = E.noop

	EncounterJournalEncounterFrameInfoBossTab:CreateBackdrop('Default')
	EncounterJournalEncounterFrameInfoBossTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterJournalEncounterFrameInfoBossTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterJournalEncounterFrameInfoLootTab:CreateBackdrop('Default')
	EncounterJournalEncounterFrameInfoLootTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterJournalEncounterFrameInfoLootTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterJournalEncounterFrameInfoModelTab:CreateBackdrop('Default')
	EncounterJournalEncounterFrameInfoModelTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterJournalEncounterFrameInfoModelTab.backdrop:Point('BOTTOMRIGHT', -6, 8)
	EncounterJournalEncounterFrameInfoOverviewTab:CreateBackdrop('Default')
	EncounterJournalEncounterFrameInfoOverviewTab.backdrop:Point('TOPLEFT', 11, -8)
	EncounterJournalEncounterFrameInfoOverviewTab.backdrop:Point('BOTTOMRIGHT', -6, 8)

	EncounterJournalEncounterFrameInfoBossTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)
	EncounterJournalEncounterFrameInfoLootTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)
	EncounterJournalEncounterFrameInfoModelTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)
	EncounterJournalEncounterFrameInfoOverviewTab.backdrop.backdropTexture:SetVertexColor(189/255, 159/255, 88/255)
	
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
	EncounterJournalTooltip:SetTemplate("Transparent")
	S:HandleIcon(item1.icon)
	S:HandleIcon(item2.icon)
	item1.IconBorder:SetTexture(nil)
	item2.IconBorder:SetTexture(nil)
	
	--Dungeon/raid selection buttons
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
	
	local function SkinBosses()
		local bossIndex = 1;
		local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
		local bossButton;

		while bossID do
			bossButton = _G["EncounterJournalBossButton"..bossIndex];
			if bossButton then
				S:HandleButton(bossButton)
			end
			
			bossIndex = bossIndex + 1;
			name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
		end
	end
	hooksecurefunc("EncounterJournal_DisplayInstance", SkinBosses)
end

S:RegisterSkin('Blizzard_EncounterJournal', LoadSkin)