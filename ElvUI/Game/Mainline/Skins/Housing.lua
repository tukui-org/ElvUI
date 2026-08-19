local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

do
	local X, Y = 2, -1
	function S:Housing_PositionDashboardTab(_, _, _, x, y)
		if x ~= X or y ~= Y then
			self:ClearAllPoints()
			self:SetPoint('TOPLEFT', _G.HousingDashboardFrame, 'TOPRIGHT', X, Y)
		end
	end
end

function S:Housing_PositionTabIcons(point)
	if point == 'CENTER' then return end

	self:ClearAllPoints()
	self:SetPoint('CENTER')
end

function S:Housing_HandleDashboardTabs(frame)
	local tabs = {
		frame.HouseInfoTabButton,
		frame.CatalogTabButton,
		frame.CollectionTabButton
	}

	for i, tab in next, tabs do
		tab:CreateBackdrop()
		tab:Size(30, 40)

		local previous = tabs[i - 1]
		if i == 1 then
			tab:ClearAllPoints()
			tab:SetPoint('TOPLEFT', frame, 'TOPRIGHT', 2, -1)

			hooksecurefunc(tab, 'SetPoint', S.Housing_PositionDashboardTab)
		elseif previous then
			tab:ClearAllPoints()
			tab:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', 0, -3)
		end

		if tab.Icon then
			tab.Icon:ClearAllPoints()
			tab.Icon:SetPoint('CENTER')

			hooksecurefunc(tab.Icon, 'SetPoint', S.Housing_PositionTabIcons)
		end

		if tab.Background then
			tab.Background:SetAlpha(0)
		end

		if tab.SelectedTexture then
			tab.SelectedTexture:SetDrawLayer('ARTWORK')
			tab.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
			tab.SelectedTexture:SetAllPoints()
		end

		if tab.HighlightTexture then
			tab.HighlightTexture:SetColorTexture(1, 1, 1, 0.3)
			tab.HighlightTexture:SetAllPoints()
		end

		if tab.TabGlow then
			tab.TabGlow:SetAlpha(0)
		end
	end
end

local function HouseList_UpdateChild(child)
	if child.IsSkinned then return end

	child:StripTextures()
	child.Background:Hide()
	child:SetTemplate()

	if child.VisitHouseButton then
		S:HandleButton(child.VisitHouseButton)
	end

	child.IsSkinned = true
end

local function HouseList_Update(frame)
	frame:ForEachFrame(HouseList_UpdateChild)
end

local function HandleContentFrameTabs(frame)
	if not frame.TabSystem then return end

	for _, tab in next, { frame.TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end
end

function S:Blizzard_HousingHouseFinder()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local finderFrame = _G.HouseFinderFrame
	if finderFrame then
		S:HandleFrame(finderFrame, true)
		finderFrame.WoodBorderFrame:Hide()

		local neighborList = finderFrame.NeighborhoodListFrame
		if neighborList then
			neighborList:StripTextures()

			neighborList.BNetFriendSearchBox:DisableDrawLayer('BACKGROUND') -- Pimp me a bit
			S:HandleEditBox(neighborList.BNetFriendSearchBox)
			S:HandleButton(neighborList.RefreshButton)
			S:HandleTrimScrollBar(neighborList.ScrollFrame.ScrollBar)
		end

		local subdivisionDropdown = finderFrame.GuildSubdivisionDropdown
		if subdivisionDropdown then
			S:HandleDropDownBox(subdivisionDropdown)
		end
	end
end

function S:Blizzard_HousingDashboard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local dashboardFrame = _G.HousingDashboardFrame
	if dashboardFrame then
		S:HandleFrame(dashboardFrame, true)
		S:Housing_HandleDashboardTabs(dashboardFrame)
	end

	local houseDropdown = dashboardFrame.HouseDropdown
	if houseDropdown then
		S:HandleDropDownBox(houseDropdown.Dropdown or houseDropdown)
	end

	local infoContent = dashboardFrame.HouseInfoContent
	if infoContent then
		S:HandleButton(infoContent.DashboardNoHousesFrame.NoHouseButton)
		S:HandleButton(infoContent.HouseFinderButton)

		local contentFrame = infoContent.ContentFrame
		if contentFrame then
			local HouseUpgradeFrame = contentFrame.HouseUpgradeFrame
			if HouseUpgradeFrame then
				HouseUpgradeFrame:StripTextures()
				HouseUpgradeFrame.Background:Hide()
				S:HandleCheckBox(HouseUpgradeFrame.WatchFavorButton)
			end

			hooksecurefunc(contentFrame, 'UpdateTabs', HandleContentFrameTabs)
		end

		local initiativesFrame = contentFrame.InitiativesFrame
		if initiativesFrame then
			initiativesFrame.InitiativesArt:Hide() -- Main Top Art BG

			local tasks = initiativesFrame.InitiativeSetFrame.InitiativeTasks
			if tasks then
				tasks.BG:StripTextures()
				tasks:SetTemplate('Transparent')
				S:HandleTrimScrollBar(tasks.ScrollBar)

				for _, frame in next, {
					tasks.BG,
					tasks.BorderRight,
					tasks.BorderTop,
					tasks.TitleCornerBR,
					tasks.TitleCornerTR,
					tasks.TaskListTitleContainer.TitleCornerBR,
					tasks.TaskListTitleContainer.TitleFoliage
				} do
					if frame then
						frame:StripTextures()
					end
				end
			end

			local activity = initiativesFrame.InitiativeSetFrame.InitiativeActivity
			if activity then
				activity:SetTemplate('Transparent')
				S:HandleTrimScrollBar(activity.ScrollBar)

				for _, frame in next, {
					activity.BG,
					activity.BGTexture,
					activity.BorderTop,
					activity.TitleCornerBL,
					activity.TitleCornerTR,
					activity.ActivityLogTitleContainer.TitleCornerBL,
					activity.ActivityLogTitleContainer.TitleFoliage
				} do
					if frame then
						frame:StripTextures()
					end
				end
			end
		end
	end

	local catalogContent = dashboardFrame.CatalogContent
	if catalogContent then
		if catalogContent.Divider then
			catalogContent.Divider:Hide()
		end

		if catalogContent.Background then
			catalogContent.Background:Hide()
		end

		if catalogContent.SearchBox then
			S:HandleEditBox(catalogContent.SearchBox)
			catalogContent.SearchBox:Size(150, 17)
		end

		if catalogContent.Filters then
			S:HandleDropDownBox(catalogContent.Filters.FilterDropdown)
		end

		local categories = catalogContent.Categories
		if categories then
			categories.TopBorder:Hide()
			categories.Background:Hide()
		end

		local optionsContainer = catalogContent.OptionsContainer
		if optionsContainer then
			S:HandleTrimScrollBar(optionsContainer.ScrollBar)
		end

		local previewFrame = catalogContent.PreviewFrame
		if previewFrame then
			previewFrame.PreviewBackground:Hide()
			previewFrame.PreviewCornerLeft:Hide()
			previewFrame.PreviewCornerRight:Hide()
		end
	end

	local collectionContent = dashboardFrame.CollectionContent
	if collectionContent then
		local blueprintCollection = collectionContent.BlueprintCollection
		if blueprintCollection then
			S:HandleTrimScrollBar(blueprintCollection.ScrollBar)
		end
	end
end

function S:Blizzard_HousingCornerstone()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local cornerVisitor = _G.HousingCornerstoneVisitorFrame
	if cornerVisitor then
		cornerVisitor:StripTextures()
		cornerVisitor:CreateBackdrop('Transparent')
		S:HandleCloseButton(cornerVisitor.CloseButton)
	end

	local cornerInfo = _G.HousingCornerstoneHouseInfoFrame
	if cornerInfo then
		cornerInfo:StripTextures()
		cornerInfo:CreateBackdrop('Transparent')
		S:HandleCloseButton(cornerInfo.CloseButton)
	end

	local purchaseFrame = _G.HousingCornerstonePurchaseFrame
	if purchaseFrame then
		purchaseFrame:StripTextures()
		purchaseFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(purchaseFrame.CloseButton)
		S:HandleButton(purchaseFrame.BuyButton)
		purchaseFrame.MoneyFrameBackdrop.NineSlice:StripTextures()
		purchaseFrame.MoneyFrame:SetTemplate('Transparent')
	end

	local moveHouseConfirmation = _G.MoveHouseConfirmationDialog
	if moveHouseConfirmation then
		moveHouseConfirmation:StripTextures()
		moveHouseConfirmation:CreateBackdrop('Transparent')
		S:HandleButton(moveHouseConfirmation.ConfirmButton)
		S:HandleButton(moveHouseConfirmation.CancelButton)
	end
end

function S:Blizzard_HousingBulletinBoard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local bulletinBoard = _G.HousingBulletinBoardFrame
	if bulletinBoard then
		bulletinBoard:StripTextures()
		S:HandleCloseButton(bulletinBoard.CloseButton)

		local residentsTab = bulletinBoard.ResidentsTab
		if residentsTab then
			S:HandleTrimScrollBar(residentsTab.ScrollBar)
		end
	end

	local changeNameDialog = _G.NeighborhoodChangeNameDialog
	if changeNameDialog then
		changeNameDialog:StripTextures()
		changeNameDialog:CreateBackdrop('Transparent')

		S:HandleEditBox(changeNameDialog.NameEditBox)
		S:HandleButton(changeNameDialog.ConfirmButton) -- Fix Backdrop
		S:HandleButton(changeNameDialog.CancelButton)  -- Fix Backdrop
	end
end

function S:Blizzard_HousingCharter()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local signatureDialog = _G.HousingCharterRequestSignatureDialog
	if signatureDialog then
		signatureDialog:StripTextures()
		signatureDialog:CreateBackdrop('Transparent')

		S:HandleButton(signatureDialog.ConfirmButton)
		S:HandleButton(signatureDialog.CancelButton)
	end
end

function S:Blizzard_HouseList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local listFrame = _G.HouseListFrame
	if listFrame then
		listFrame:StripTextures()
		listFrame:CreateBackdrop('Transparent')

		S:HandleCloseButton(listFrame.CloseButton)
		S:HandleTrimScrollBar(listFrame.ScrollBar)

		hooksecurefunc(listFrame.ScrollBox, 'Update', HouseList_Update)
	end
end

function S:Blizzard_HousingCreateNeighborhood()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local createGuildNeighborhood = _G.HousingCreateGuildNeighborhoodFrame
	if createGuildNeighborhood then
		createGuildNeighborhood:StripTextures()
		createGuildNeighborhood:CreateBackdrop('Transparent')

		S:HandleEditBox(createGuildNeighborhood.NeighborhoodNameEditBox)
		S:HandleButton(createGuildNeighborhood.ConfirmButton)
		S:HandleButton(createGuildNeighborhood.CancelButton)

		local confirmationFrame = createGuildNeighborhood.ConfirmationFrame
		if confirmationFrame then
			confirmationFrame:StripTextures()
			confirmationFrame:SetTemplate()

			S:HandleButton(confirmationFrame.ConfirmButton)
			S:HandleButton(confirmationFrame.CancelButton)
		end
	end
end

local function SkinHouseSettingOptions(panel)
	if not panel.accessOptions then return end

	for _, option in next, panel.accessOptions do
		local checkbox = option.Checkbox
		if checkbox and not checkbox.IsSkinned then
			S:HandleCheckBox(option.Checkbox)
		end
	end
end

function S:Blizzard_HousingHouseSettings()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local settingsFrame = _G.HousingHouseSettingsFrame
	if settingsFrame then
		local plotAccess = settingsFrame.PlotAccess
		local houseAccess = settingsFrame.HouseAccess
		local blueprintExport = settingsFrame.BlueprintExport

		settingsFrame:StripTextures()
		settingsFrame:SetTemplate('Transparent')

		S:HandleCloseButton(settingsFrame.CloseButton)
		S:HandleDropDownBox(settingsFrame.HouseOwnerDropdown, 240)
		S:HandleButton(settingsFrame.AbandonHouseButton)
		S:HandleDropDownBox(plotAccess.AccessTypeDropdown)
		S:HandleDropDownBox(houseAccess.AccessTypeDropdown)
		S:HandleDropDownBox(blueprintExport.AccessTypeDropdown)

		hooksecurefunc(plotAccess, 'SetupOptions', SkinHouseSettingOptions)
		hooksecurefunc(houseAccess, 'SetupOptions', SkinHouseSettingOptions)
		hooksecurefunc(blueprintExport, 'SetupOptions', SkinHouseSettingOptions)

		SkinHouseSettingOptions(plotAccess)
		SkinHouseSettingOptions(houseAccess)
		SkinHouseSettingOptions(blueprintExport)

		S:HandleButton(settingsFrame.IgnoreListButton)
		S:HandleButton(settingsFrame.SaveButton)
	end

	local abandonConfirmation = _G.AbandonHouseConfirmationDialog
	if abandonConfirmation then
		abandonConfirmation:StripTextures()
		abandonConfirmation:SetTemplate('Transparent')

		S:HandleButton(abandonConfirmation.ConfirmButton)
		S:HandleButton(abandonConfirmation.CancelButton)
	end
end

function S:Blizzard_HouseEditor()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local editorFrame = _G.HouseEditorFrame
	local storageButton = editorFrame.StorageButton
	if storageButton then
		S:HandleButton(storageButton, true, nil, nil, nil, 'Transparent')
		storageButton:NudgePoint(2)

		local storageIcon = storageButton.Icon
		if storageIcon then
			storageIcon:SetAtlas('house-chest-icon') -- Use same icon as default WoW UI
			storageIcon:Size(32)
			storageIcon:ClearAllPoints()
			storageIcon:Point('CENTER')
		end
	end

	local storagePanel = editorFrame.StoragePanel
	if storagePanel then
		storagePanel:StripTextures()
		storagePanel:SetTemplate('Transparent')
		S:HandleEditBox(storagePanel.SearchBox)
		storagePanel.SearchBox:Size(350, 21)
		S:HandleButton(storagePanel.Filters.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
		S:HandleCloseButton(storagePanel.Filters.FilterDropdown.ResetButton)
		storagePanel.Filters.FilterDropdown.ResetButton:ClearAllPoints()
		storagePanel.Filters.FilterDropdown.ResetButton:Point('CENTER', storagePanel.Filters.FilterDropdown, 'TOPRIGHT', 0, 0)

		for _, tab in next, { storagePanel.TabSystem:GetChildren() } do
			S:HandleTab(tab)
		end

		local categories = storagePanel.Categories
		if categories then
			categories.TopBorder:Hide()
			categories.Background:Hide()
		end

		local optionsContainer = storagePanel.OptionsContainer
		if optionsContainer then
			S:HandleTrimScrollBar(optionsContainer.ScrollBar)
		end

		local collapseButton = storagePanel.CollapseButton
		if collapseButton then
			S:HandleButton(collapseButton, true, nil, nil, nil, 'Transparent')
			collapseButton:NudgePoint(4)

			S:SetupArrow(collapseButton.Icon, 'left')
			collapseButton.Icon:SetTexCoord(0, 1, 0, 1)
			collapseButton.Icon:Size(18)
			collapseButton.Icon:ClearAllPoints()
			collapseButton.Icon:Point('CENTER')
		end
	end

	local customizationFrame = editorFrame.ExteriorCustomizationModeFrame
	if customizationFrame then
		local fixtureOptionList = customizationFrame.FixtureOptionList
		if fixtureOptionList then
			fixtureOptionList:StripTextures()
			fixtureOptionList:SetTemplate('Transparent')

			S:HandleCloseButton(fixtureOptionList.CloseButton)
			fixtureOptionList.CloseButton:ClearAllPoints()
			fixtureOptionList.CloseButton:Point('TOPRIGHT', fixtureOptionList, 'TOPRIGHT')

			S:HandleTrimScrollBar(fixtureOptionList.ScrollBar)
		end

		local coreOptions = customizationFrame.CoreOptionsPanel
		if coreOptions then
			for _, corePanel in next, {
				coreOptions,
				coreOptions.HouseTypeOption,
				coreOptions.HouseSizeOption,
				coreOptions.BaseStyleOption,
				coreOptions.RoofStyleOption,
				coreOptions.RoofVariantOption
			} do
				if corePanel.Dropdown then
					S:HandleDropDownBox(corePanel.Dropdown)
				end
			end
		end
	end

	local customizeModeFrame = editorFrame.CustomizeModeFrame
	local customizationsPane = customizeModeFrame and customizeModeFrame.RoomComponentCustomizationsPane
	if customizationsPane then
		customizationsPane:StripTextures()
		customizationsPane:SetTemplate('Transparent')
		customizationsPane.CloseButton:ClearAllPoints()
		customizationsPane.CloseButton:Point('TOPRIGHT')
		S:HandleCloseButton(customizationsPane.CloseButton)

		for _, RoomComponentPanel in next, {
			customizationsPane.ThemeDropdown,
			customizationsPane.WallpaperDropdown,
			customizationsPane.DoorTypeDropdown,
			customizationsPane.CeilingTypeDropdown
		} do
			if RoomComponentPanel.Dropdown then
				S:HandleDropDownBox(RoomComponentPanel.Dropdown)
			end
		end

		if customizationsPane.ApplyThemeToRoomButton then
			customizationsPane.ApplyThemeToRoomButton:Size(26)
			S:HandleButton(customizationsPane.ApplyThemeToRoomButton)
		end

		if customizationsPane.ApplyWallpaperToAllWallsButton then
			customizationsPane.ApplyWallpaperToAllWallsButton:Size(26)
			S:HandleButton(customizationsPane.ApplyWallpaperToAllWallsButton)
		end
	end

	local decorCustomizations = customizeModeFrame and customizeModeFrame.DecorCustomizationsPane
	if decorCustomizations then
		decorCustomizations:StripTextures()
		decorCustomizations:SetTemplate('Transparent')

		decorCustomizations.CloseButton:ClearAllPoints()
		decorCustomizations.CloseButton:Point('TOPRIGHT')

		S:HandleCloseButton(decorCustomizations.CloseButton)
		S:HandleButton(decorCustomizations.ButtonFrame.CancelButton)
		S:HandleButton(decorCustomizations.ButtonFrame.ApplyButton)
	end

	local expertDecorMode = editorFrame.ExpertDecorModeFrame
	local placedDecorList = expertDecorMode and expertDecorMode.PlacedDecorList
	if placedDecorList then
		placedDecorList:StripTextures()
		placedDecorList:CreateBackdrop('Transparent')

		S:HandleTrimScrollBar(placedDecorList.ScrollBar)

		S:HandleCloseButton(placedDecorList.CloseButton)
		placedDecorList.CloseButton:ClearAllPoints()
		placedDecorList.CloseButton:Point('TOPRIGHT')
	end

	local dyeSelectionPopout = _G.DyeSelectionPopout
	if dyeSelectionPopout then
		dyeSelectionPopout:StripTextures()
		dyeSelectionPopout:CreateBackdrop('Transparent')

		S:HandleTrimScrollBar(dyeSelectionPopout.DyeSlotScrollBar)
		S:HandleCheckBox(dyeSelectionPopout.ShowOnlyOwned)
	end
end

function S:Blizzard_HousingModelPreview()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local previewFrame = _G.HousingModelPreviewFrame
	if previewFrame then
		previewFrame:StripTextures()
		previewFrame:CreateBackdrop('Transparent')

		S:HandleCloseButton(previewFrame.CloseButton)

		local modelPreview = previewFrame.ModelPreview
		if modelPreview then
			modelPreview:StripTextures()

			local modelSceneControls = modelPreview.ModelSceneControls
			if modelSceneControls then
				S:HandleModelSceneControlButtons(modelSceneControls)
			end
		end
	end
end

local function SkinHousingBlueprintBaseFrame(frame)
	if not frame or frame.IsSkinned then return end

	if frame.Background then
		frame.Background:SetAlpha(0)
	end

	if frame.Header then
		frame.Header:SetAlpha(0)
	end

	frame:StripTextures()
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)

	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', -2, -2)

	frame.IsSkinned = true
end

local function SkinHousingBlueprintShareCodeBox(shareCodeBox)
	if not shareCodeBox or shareCodeBox.IsSkinned then return end

	shareCodeBox:StripTextures(true)

	S:HandleEditBox(shareCodeBox)

	shareCodeBox.IsSkinned = true
end

function S:Blizzard_HousingBlueprint()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local importFrame = _G.HousingBlueprintImportFrame
	if importFrame then
		SkinHousingBlueprintBaseFrame(importFrame)

		local inputContent = importFrame.InputContent
		if inputContent then
			SkinHousingBlueprintShareCodeBox(inputContent.ShareCodeBox)
			S:HandleButton(inputContent.NextButton)
		end

		local validationContent = importFrame.ValidationContent
		if validationContent then
			S:HandleButton(validationContent.ImportButton)

			local contentSummary = validationContent.ContentSummary
			if contentSummary then
				S:HandleButton(contentSummary.ContentsListButton)

				local budgetsContainer = contentSummary.BudgetsContainer
				if budgetsContainer then
					if budgetsContainer.Background then
						budgetsContainer.Background:SetAlpha(0)
					end

					budgetsContainer:SetTemplate('Transparent')
				end
			end
		end
	end

	local exportFrame = _G.HousingBlueprintExportFrame
	if exportFrame then
		SkinHousingBlueprintBaseFrame(exportFrame)

		local inputContent = exportFrame.InputContent
		if inputContent then
			S:HandleDropDownBox(inputContent.TypeDropdown)
			S:HandleEditBox(inputContent.NameInputBox)
			S:HandleButton(inputContent.SaveButton)
		end

		local successContent = exportFrame.SuccessContent
		if successContent then
			S:HandleButton(successContent.BlueprintsCollectionButton)
			S:HandleButton(successContent.ChatLinkButton)
			S:HandleButton(successContent.ClipboardButton)

			SkinHousingBlueprintShareCodeBox(successContent.ShareCodeBox)
		end
	end
end

S:AddCallbackForAddon('Blizzard_HouseList')
S:AddCallbackForAddon('Blizzard_HousingCharter')
S:AddCallbackForAddon('Blizzard_HousingBulletinBoard')
S:AddCallbackForAddon('Blizzard_HousingCornerstone')
S:AddCallbackForAddon('Blizzard_HousingCreateNeighborhood')
S:AddCallbackForAddon('Blizzard_HousingDashboard')
S:AddCallbackForAddon('Blizzard_HousingHouseFinder')
S:AddCallbackForAddon('Blizzard_HousingHouseSettings')
S:AddCallbackForAddon('Blizzard_HouseEditor')
S:AddCallbackForAddon('Blizzard_HousingModelPreview')
S:AddCallbackForAddon('Blizzard_HousingBlueprint')
