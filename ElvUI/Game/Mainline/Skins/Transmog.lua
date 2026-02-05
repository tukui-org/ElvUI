local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function SkinSituationsDropdowns()
	local SituationsFrame = _G.TransmogFrame.WardrobeCollection.TabContent.SituationsFrame
	if not SituationsFrame then return end

	local Situations = SituationsFrame.Situations
	if Situations then
		for _, child in next, { Situations:GetChildren() } do
			if child.Dropdown and not child.Dropdown.IsSkinned then
				S:HandleDropDownBox(child.Dropdown, 300)

				child.Dropdown.IsSkinned = true
			end
		end
	end
end

local function PageControlsPositionUpdate(frame)
	if frame.PrevPageButton then
		frame.PrevPageButton:ClearAllPoints()
		frame.PrevPageButton:Point('TOPLEFT', frame, 'TOPLEFT', 64, -6)
	end
	if frame.NextPageButton then
		frame.NextPageButton:ClearAllPoints()
		frame.NextPageButton:Point('LEFT', frame.PrevPageButton, 'RIGHT', 14, -1)
	end
end

function S:Blizzard_Transmog()
	if not E.private.skins.blizzard.transmogrify then return end

	local TransmogFrame = _G.TransmogFrame
	S:HandlePortraitFrame(TransmogFrame)

	local HelpPlateButton = TransmogFrame.HelpPlateButton
	if HelpPlateButton then
		HelpPlateButton:Kill()

		if HelpPlateButton.Ring then
			HelpPlateButton.Ring:Hide()
		end
	end

	local OutfitCollection = TransmogFrame.OutfitCollection
	if OutfitCollection then
		if E.private.skins.parchmentRemoverEnable then
			OutfitCollection.Background:Hide()
			OutfitCollection.DividerBar:Hide()

			if not OutfitCollection.backdrop then
				OutfitCollection:CreateBackdrop('Transparent')
			end
		end

		if OutfitCollection.GradientTop then
			OutfitCollection.GradientTop:Hide()
		end

		if OutfitCollection.GradientBottom then
			OutfitCollection.GradientBottom:Hide()
		end

		S:HandleTrimScrollBar(OutfitCollection.OutfitList.ScrollBar)
		S:HandleButton(OutfitCollection.SaveOutfitButton, nil, nil, nil, true, nil, nil, nil, true)
		-- S:HandleButton(OutfitCollection.PurchaseOutfitButton) -- Fits good in our style tbh
		OutfitCollection.MoneyFrame:StripTextures()
		OutfitCollection.MoneyFrame:SetTemplate()
	end

	local CharacterPreview = TransmogFrame.CharacterPreview
	if CharacterPreview then
		if E.private.skins.parchmentRemoverEnable then
			CharacterPreview.Background:Hide()
			CharacterPreview.Gradients:Hide()

			if not CharacterPreview.backdrop then
				CharacterPreview:CreateBackdrop('Transparent')
			end
		end

		S:HandleCheckBox(CharacterPreview.HideIgnoredToggle.Checkbox)
		S:HandleButton(CharacterPreview.ClearAllPendingButton)
		S:HandleModelSceneControlButtons(CharacterPreview.ModelScene.ControlFrame)
	end

	local WardrobeCollection = TransmogFrame.WardrobeCollection
	if WardrobeCollection.TabContent then
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
		if ItemsFrame then
			S:HandleEditBox(ItemsFrame.SearchBox)
			S:HandleButton(ItemsFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
			--[[
				S:HandleButton(ItemsFrame.DisplayTypeUnassignedButton) -- Leave it or change it (unskinned it fits really good tbh)
				S:HandleButton(ItemsFrame.DisplayTypeEquippedButton) -- Leave it or change it (unskinned it fits really good tbh)
			]]
			S:HandleDropDownBox(ItemsFrame.WeaponDropdown)

			S:HandleNextPrevButton(ItemsFrame.PagedContent.PagingControls.PrevPageButton)
			S:HandleNextPrevButton(ItemsFrame.PagedContent.PagingControls.NextPageButton)
			hooksecurefunc(ItemsFrame.PagedContent.PagingControls, 'ShouldClearOnUpdateAfterClean', PageControlsPositionUpdate)
		end

		local SetsFrame = WardrobeCollection.TabContent.SetsFrame
		if SetsFrame then
			S:HandleButton(SetsFrame.SearchBox)
			S:HandleButton(SetsFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')

			S:HandleNextPrevButton(SetsFrame.PagedContent.PagingControls.PrevPageButton)
			S:HandleNextPrevButton(SetsFrame.PagedContent.PagingControls.NextPageButton)
			hooksecurefunc(SetsFrame.PagedContent.PagingControls, 'ShouldClearOnUpdateAfterClean', PageControlsPositionUpdate)
		end

		local CustomSetsFrame = WardrobeCollection.TabContent.CustomSetsFrame
		if CustomSetsFrame then
			S:HandleButton(CustomSetsFrame.NewCustomSetButton, nil, nil, nil, true, nil, nil, nil, true)

			S:HandleNextPrevButton(CustomSetsFrame.PagedContent.PagingControls.PrevPageButton)
			S:HandleNextPrevButton(CustomSetsFrame.PagedContent.PagingControls.NextPageButton)
			hooksecurefunc(CustomSetsFrame.PagedContent.PagingControls, 'ShouldClearOnUpdateAfterClean', PageControlsPositionUpdate)
		end

		local SituationsFrame = WardrobeCollection.TabContent.SituationsFrame
		if SituationsFrame then
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
		end
	end
end

S:AddCallbackForAddon('Blizzard_Transmog')
