local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function SkinSituationsDropdowns(frame)
	for situation in frame.SituationFramePool:EnumerateActive() do
		if not situation.Dropdown.IsSkinned then
			S:HandleDropDownBox(situation.Dropdown, 300)

			situation.Dropdown.IsSkinned = true
		end
	end
end

local function PageControlsPositionUpdate(frame)
	frame.PrevPageButton:ClearAllPoints()
	frame.PrevPageButton:Point('TOPLEFT', frame, 'TOPLEFT', 64, -6)
	frame.NextPageButton:ClearAllPoints()
	frame.NextPageButton:Point('LEFT', frame.PrevPageButton, 'RIGHT', 14, -1)
end

local function OutfitPopup_OnShow(frame)
	if not frame.IsSkinned then -- set by HandleIconSelectionFrame
		S:HandleIconSelectionFrame(frame, nil, nil, 'TransmogFrame')
	end
end

function S:Blizzard_Transmog()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.transmogrify) then return end

	local TransmogFrame = _G.TransmogFrame
	S:HandlePortraitFrame(TransmogFrame)

	TransmogFrame.HelpPlateButton:Kill()
	TransmogFrame.HelpPlateButton.Ring:Hide()

	local OutfitCollection = TransmogFrame.OutfitCollection
	if E.private.skins.parchmentRemoverEnable then
		OutfitCollection.Background:Hide()
		OutfitCollection.DividerBar:Hide()

		if not OutfitCollection.backdrop then
			OutfitCollection:CreateBackdrop('Transparent')
		end
	end

	OutfitCollection.GradientTop:Hide()
	OutfitCollection.GradientBottom:Hide()

	S:HandleTrimScrollBar(OutfitCollection.OutfitList.ScrollBar)
	S:HandleButton(OutfitCollection.SaveOutfitButton, nil, nil, nil, true, nil, nil, nil, true)
	OutfitCollection.MoneyFrame:StripTextures()
	OutfitCollection.MoneyFrame:SetTemplate()

	local CharacterPreview = TransmogFrame.CharacterPreview
	if E.private.skins.parchmentRemoverEnable then
		CharacterPreview.Background:Hide()
		CharacterPreview.Gradients:Hide()

		if not CharacterPreview.backdrop then
			CharacterPreview:CreateBackdrop('Transparent')
		end
	end

	local ToggleOptions = CharacterPreview.ToggleOptions
	S:HandleCheckBox(ToggleOptions.HideIgnoredToggle.Checkbox)
	S:HandleCheckBox(ToggleOptions.PreviewedWeaponToggle.Checkbox)
	S:HandleCheckBox(ToggleOptions.SheatheWeaponToggle.Checkbox)

	S:HandleButton(CharacterPreview.ClearAllPendingButton)
	S:HandleModelSceneControlButtons(CharacterPreview.ModelScene.ControlFrame)

	local WardrobeCollection = TransmogFrame.WardrobeCollection
	if E.private.skins.parchmentRemoverEnable then
		WardrobeCollection.TabContent.Border:Hide()
		WardrobeCollection.TabContent.Background:Hide()
		WardrobeCollection.Background:Hide()

		if not WardrobeCollection.backdrop then
			WardrobeCollection:CreateBackdrop('Transparent')
		end
	end

	for _, tab in next, { WardrobeCollection.TabHeaders:GetChildren() } do
		S:HandleTab(tab)
	end

	local ItemsFrame = WardrobeCollection.TabContent.ItemsFrame
	S:HandleEditBox(ItemsFrame.SearchBox)
	S:HandleButton(ItemsFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleDropDownBox(ItemsFrame.WeaponDropdown)
	S:HandleDropDownBox(ItemsFrame.WeaponSheatheDropdown)
	S:HandleCheckBox(ItemsFrame.SecondaryAppearanceToggle.Checkbox)

	S:HandleNextPrevButton(ItemsFrame.PagedContent.PagingControls.PrevPageButton)
	S:HandleNextPrevButton(ItemsFrame.PagedContent.PagingControls.NextPageButton)
	hooksecurefunc(ItemsFrame.PagedContent.PagingControls, 'ShouldClearOnUpdateAfterClean', PageControlsPositionUpdate)

	local SetsFrame = WardrobeCollection.TabContent.SetsFrame
	S:HandleButton(SetsFrame.SearchBox)
	S:HandleButton(SetsFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')

	S:HandleNextPrevButton(SetsFrame.PagedContent.PagingControls.PrevPageButton)
	S:HandleNextPrevButton(SetsFrame.PagedContent.PagingControls.NextPageButton)
	hooksecurefunc(SetsFrame.PagedContent.PagingControls, 'ShouldClearOnUpdateAfterClean', PageControlsPositionUpdate)

	local CustomSetsFrame = WardrobeCollection.TabContent.CustomSetsFrame
	S:HandleButton(CustomSetsFrame.NewCustomSetButton, nil, nil, nil, true, nil, nil, nil, true)

	S:HandleNextPrevButton(CustomSetsFrame.PagedContent.PagingControls.PrevPageButton)
	S:HandleNextPrevButton(CustomSetsFrame.PagedContent.PagingControls.NextPageButton)
	hooksecurefunc(CustomSetsFrame.PagedContent.PagingControls, 'ShouldClearOnUpdateAfterClean', PageControlsPositionUpdate)

	local SituationsFrame = WardrobeCollection.TabContent.SituationsFrame
	if E.private.skins.parchmentRemoverEnable then
		SituationsFrame.Situations.Background:Hide()

		if not SituationsFrame.Situations.backdrop then
			SituationsFrame.Situations:CreateBackdrop('Transparent')
		end
	end

	S:HandleButton(SituationsFrame.DefaultsButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleCheckBox(SituationsFrame.EnabledToggle.Checkbox)
	S:HandleButton(SituationsFrame.ApplyButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(SituationsFrame.UndoButton)

	hooksecurefunc(SituationsFrame, 'Init', SkinSituationsDropdowns)
	hooksecurefunc(SituationsFrame, 'Refresh', SkinSituationsDropdowns)

	TransmogFrame.OutfitPopup:HookScript('OnShow', OutfitPopup_OnShow)
end

S:AddCallbackForAddon('Blizzard_Transmog')
