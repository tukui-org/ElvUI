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
	EncounterJournalInstanceSelect:CreateBackdrop("Default")
	EncounterJournalEncounterFrameInfo:CreateBackdrop("Default")

	S:HandleScrollBar(EncounterJournalInstanceSelectScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar, 4)
	S:HandleScrollBar(EncounterJournalEncounterFrameInfoBossesScrollFrameScrollBar, 4)

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
end

S:RegisterSkin('Blizzard_EncounterJournal', LoadSkin)