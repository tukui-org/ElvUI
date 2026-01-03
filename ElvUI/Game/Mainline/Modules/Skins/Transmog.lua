local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_Transmog()
	if not E.private.skins.blizzard.transmogrify then return end

	local TransmogFrame = _G.TransmogFrame
	S:HandlePortraitFrame(TransmogFrame)

	local OutfitCollection = TransmogFrame.OutfitCollection
	if OutfitCollection then
		if E.private.skins.parchmentRemoverEnable then
			OutfitCollection.Background:Hide()
			OutfitCollection.DividerBar:Hide()

			if not OutfitCollection.backdrop then
				OutfitCollection:CreateBackdrop('Transparent')
			end
		end

		S:HandleTrimScrollBar(OutfitCollection.OutfitList.ScrollBar)
		S:HandleButton(OutfitCollection.SaveOutfitButton, nil, nil, nil, true, nil, nil, nil, true)
		-- S:HandleButton(OutfitCollection.PurchaseOutfitButton) -- Fits good in our style tbh
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

			-- ToDo: Adjust the text position
			S:HandleNextPrevButton(ItemsFrame.PagedContent.PagingControls.PrevPageButton)
			S:HandleNextPrevButton(ItemsFrame.PagedContent.PagingControls.NextPageButton)
		end

		local SetsFrame = WardrobeCollection.TabContent.SetsFrame
		if SetsFrame then
			S:HandleButton(SetsFrame.SearchBox)
			S:HandleButton(SetsFrame.FilterButton, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')

			-- ToDo: Adjust the text position
			S:HandleNextPrevButton(SetsFrame.PagedContent.PagingControls.PrevPageButton)
			S:HandleNextPrevButton(SetsFrame.PagedContent.PagingControls.NextPageButton)
		end

		local CustomSetsFrame = WardrobeCollection.TabContent.CustomSetsFrame
		if CustomSetsFrame then
			S:HandleButton(CustomSetsFrame.NewCustomSetButton, nil, nil, nil, true, nil, nil, nil, true)

			-- ToDo: Adjust the text position
			S:HandleNextPrevButton(CustomSetsFrame.PagedContent.PagingControls.PrevPageButton)
			S:HandleNextPrevButton(CustomSetsFrame.PagedContent.PagingControls.NextPageButton)
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

			-- ToDo: Skin the Dropdowns
		end
	end
end

S:AddCallbackForAddon('Blizzard_Transmog')