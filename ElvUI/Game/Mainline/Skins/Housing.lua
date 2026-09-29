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

		tab.Icon:ClearAllPoints()
		tab.Icon:SetPoint('CENTER')
		hooksecurefunc(tab.Icon, 'SetPoint', S.Housing_PositionTabIcons)

		tab.Background:SetAlpha(0)
		tab.TabGlow:SetAlpha(0)

		tab.SelectedTexture:SetDrawLayer('ARTWORK')
		tab.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
		tab.SelectedTexture:SetAllPoints()

		tab.HighlightTexture:SetColorTexture(1, 1, 1, 0.3)
		tab.HighlightTexture:SetAllPoints()
	end
end

local function HouseList_UpdateChild(child)
	if child.IsSkinned then return end

	child:StripTextures()
	child.Background:Hide()
	child:SetTemplate()
	S:HandleButton(child.VisitHouseButton)

	child.IsSkinned = true
end

local function HouseList_Update(frame)
	frame:ForEachFrame(HouseList_UpdateChild)
end

local function HandleContentFrameTabs(frame)
	for _, tab in next, { frame.TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end
end

function S:Blizzard_HousingHouseFinder()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local finderFrame = _G.HouseFinderFrame
	finderFrame.WoodBorderFrame:Hide()

	S:HandleFrame(finderFrame, true)
	S:HandleButton(finderFrame.PlotInfoFrame.VisitHouseButton)
	S:HandleDropDownBox(finderFrame.GuildSubdivisionDropdown)

	local neighborList = finderFrame.NeighborhoodListFrame
	neighborList:StripTextures()
	neighborList.BNetFriendSearchBox:DisableDrawLayer('BACKGROUND') -- Pimp me a bit

	S:HandleEditBox(neighborList.BNetFriendSearchBox)
	S:HandleButton(neighborList.RefreshButton)
	S:HandleTrimScrollBar(neighborList.ScrollFrame.ScrollBar)
end

function S:Blizzard_HousingDashboard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local dashboardFrame = _G.HousingDashboardFrame
	S:HandleFrame(dashboardFrame, true)
	S:Housing_HandleDashboardTabs(dashboardFrame)
	S:HandleDropDownBox(dashboardFrame.HouseDropdown.Dropdown)

	local infoContent = dashboardFrame.HouseInfoContent
	S:HandleButton(infoContent.DashboardNoHousesFrame.NoHouseButton)
	S:HandleButton(infoContent.HouseFinderButton)

	local contentFrame = infoContent.ContentFrame
	hooksecurefunc(contentFrame, 'UpdateTabs', HandleContentFrameTabs)

	local HouseUpgradeFrame = contentFrame.HouseUpgradeFrame
	HouseUpgradeFrame:StripTextures()
	HouseUpgradeFrame.Background:Hide()
	S:HandleCheckBox(HouseUpgradeFrame.WatchFavorButton)

	local initiativesFrame = contentFrame.InitiativesFrame
	initiativesFrame.InitiativesArt:Hide() -- Main Top Art BG

	local tasks = initiativesFrame.InitiativeSetFrame.InitiativeTasks
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
		frame:StripTextures()
	end

	local activity = initiativesFrame.InitiativeSetFrame.InitiativeActivity
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
		frame:StripTextures()
	end

	local catalogContent = dashboardFrame.CatalogContent
	catalogContent.Divider:Hide()
	catalogContent.Background:Hide()
	catalogContent.Categories.TopBorder:Hide()
	catalogContent.Categories.Background:Hide()
	catalogContent.SearchBox:Size(150, 17)

	S:HandleEditBox(catalogContent.SearchBox)
	S:HandleDropDownBox(catalogContent.Filters.FilterDropdown)
	S:HandleTrimScrollBar(catalogContent.OptionsContainer.ScrollBar)

	local previewFrame = catalogContent.PreviewFrame
	previewFrame.PreviewBackground:Hide()
	previewFrame.PreviewCornerLeft:Hide()
	previewFrame.PreviewCornerRight:Hide()

	S:HandleTrimScrollBar(dashboardFrame.CollectionContent.BlueprintCollection.ScrollBar)
end

function S:Blizzard_HousingCornerstone()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local cornerVisitor = _G.HousingCornerstoneVisitorFrame
	cornerVisitor:StripTextures()
	cornerVisitor:CreateBackdrop('Transparent')
	S:HandleCloseButton(cornerVisitor.CloseButton)

	local cornerInfo = _G.HousingCornerstoneHouseInfoFrame
	cornerInfo:StripTextures()
	cornerInfo:CreateBackdrop('Transparent')
	S:HandleCloseButton(cornerInfo.CloseButton)

	local purchaseFrame = _G.HousingCornerstonePurchaseFrame
	purchaseFrame:StripTextures()
	purchaseFrame:CreateBackdrop('Transparent')
	S:HandleCloseButton(purchaseFrame.CloseButton)
	S:HandleButton(purchaseFrame.BuyButton)
	purchaseFrame.MoneyFrameBackdrop.NineSlice:StripTextures()
	purchaseFrame.MoneyFrame:SetTemplate('Transparent')

	local moveHouseConfirmation = _G.MoveHouseConfirmationDialog
	moveHouseConfirmation:StripTextures()
	moveHouseConfirmation:CreateBackdrop('Transparent')
	S:HandleButton(moveHouseConfirmation.ConfirmButton)
	S:HandleButton(moveHouseConfirmation.CancelButton)

	local buyHouseConfirmation = _G.BuyHouseConfirmationDialog
	buyHouseConfirmation:StripTextures()
	buyHouseConfirmation:CreateBackdrop('Transparent')
	S:HandleButton(buyHouseConfirmation.AcceptButton)
	S:HandleButton(buyHouseConfirmation.CancelButton)
end

function S:Blizzard_HousingBulletinBoard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local bulletinBoard = _G.HousingBulletinBoardFrame
	bulletinBoard:StripTextures()
	bulletinBoard:CreateBackdrop('Transparent')
	bulletinBoard.backdrop:SetOutside(bulletinBoard.Background)

	if E.private.skins.parchmentRemoverEnable then
		bulletinBoard.Background:SetAlpha(0)
	else
		bulletinBoard.Background:SetTexCoord(0.01, 0.99, 0.01, 0.99)
	end

	S:HandleCloseButton(bulletinBoard.CloseButton)
	S:HandleTrimScrollBar(bulletinBoard.ResidentsTab.ScrollBar)

	local changeNameDialog = _G.NeighborhoodChangeNameDialog
	changeNameDialog:StripTextures()
	changeNameDialog:CreateBackdrop('Transparent')

	S:HandleEditBox(changeNameDialog.NameEditBox)
	S:HandleButton(changeNameDialog.ConfirmButton) -- Fix Backdrop
	S:HandleButton(changeNameDialog.CancelButton)  -- Fix Backdrop
end

function S:Blizzard_HousingCharter()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local signatureDialog = _G.HousingCharterRequestSignatureDialog
	signatureDialog:StripTextures()
	signatureDialog:CreateBackdrop('Transparent')

	S:HandleButton(signatureDialog.ConfirmButton)
	S:HandleButton(signatureDialog.CancelButton)
end

function S:Blizzard_HouseList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local listFrame = _G.HouseListFrame
	listFrame:StripTextures()
	listFrame:CreateBackdrop('Transparent')

	S:HandleCloseButton(listFrame.CloseButton)
	S:HandleTrimScrollBar(listFrame.ScrollBar)

	hooksecurefunc(listFrame.ScrollBox, 'Update', HouseList_Update)
end

function S:Blizzard_HousingCreateNeighborhood()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local createGuildNeighborhood = _G.HousingCreateGuildNeighborhoodFrame
	createGuildNeighborhood:StripTextures()
	createGuildNeighborhood:CreateBackdrop('Transparent')

	S:HandleEditBox(createGuildNeighborhood.NeighborhoodNameEditBox)
	S:HandleButton(createGuildNeighborhood.ConfirmButton)
	S:HandleButton(createGuildNeighborhood.CancelButton)

	local confirmationFrame = createGuildNeighborhood.ConfirmationFrame
	confirmationFrame:StripTextures()
	confirmationFrame:SetTemplate()

	S:HandleButton(confirmationFrame.ConfirmButton)
	S:HandleButton(confirmationFrame.CancelButton)
end

local function SkinHouseSettingOptions(panel)
	for _, option in next, panel.accessOptions do
		if not option.Checkbox.IsSkinned then
			S:HandleCheckBox(option.Checkbox)
		end
	end
end

function S:Blizzard_HousingHouseSettings()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local settingsFrame = _G.HousingHouseSettingsFrame
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

	local abandonConfirmation = _G.AbandonHouseConfirmationDialog
	abandonConfirmation:StripTextures()
	abandonConfirmation:SetTemplate('Transparent')

	S:HandleButton(abandonConfirmation.ConfirmButton)
	S:HandleButton(abandonConfirmation.CancelButton)
end

function S:Blizzard_HouseEditor()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local editorFrame = _G.HouseEditorFrame
	local storageButton = editorFrame.StorageButton
	S:HandleButton(storageButton, true, nil, nil, nil, 'Transparent')
	storageButton:NudgePoint(2)
	storageButton.Icon:SetAtlas('house-chest-icon') -- Use same icon as default WoW UI
	storageButton.Icon:Size(32)
	storageButton.Icon:ClearAllPoints()
	storageButton.Icon:Point('CENTER')

	local storagePanel = editorFrame.StoragePanel
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

	storagePanel.Categories.TopBorder:Hide()
	storagePanel.Categories.Background:Hide()
	S:HandleTrimScrollBar(storagePanel.OptionsContainer.ScrollBar)

	local collapseButton = storagePanel.CollapseButton
	S:HandleButton(collapseButton, true, nil, nil, nil, 'Transparent')
	collapseButton:NudgePoint(4)

	S:SetupArrow(collapseButton.Icon, 'left')
	collapseButton.Icon:SetTexCoord(0, 1, 0, 1)
	collapseButton.Icon:Size(18)
	collapseButton.Icon:ClearAllPoints()
	collapseButton.Icon:Point('CENTER')

	local customizationFrame = editorFrame.ExteriorCustomizationModeFrame
	local fixtureOptionList = customizationFrame.FixtureOptionList
	fixtureOptionList:StripTextures()
	fixtureOptionList:SetTemplate('Transparent')

	S:HandleCloseButton(fixtureOptionList.CloseButton)
	fixtureOptionList.CloseButton:ClearAllPoints()
	fixtureOptionList.CloseButton:Point('TOPRIGHT', fixtureOptionList, 'TOPRIGHT')

	S:HandleTrimScrollBar(fixtureOptionList.ScrollBar)

	local coreOptions = customizationFrame.CoreOptionsPanel
	for _, corePanel in next, {
		coreOptions.HouseTypeOption,
		coreOptions.HouseSizeOption,
		coreOptions.BaseStyleOption,
		coreOptions.RoofStyleOption,
		coreOptions.RoofVariantOption
	} do
		S:HandleDropDownBox(corePanel.Dropdown)
	end

	local customizeModeFrame = editorFrame.CustomizeModeFrame
	local customizationsPane = customizeModeFrame.RoomComponentCustomizationsPane
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
		S:HandleDropDownBox(RoomComponentPanel.Dropdown)
	end

	customizationsPane.ApplyThemeToRoomButton:Size(26)
	S:HandleButton(customizationsPane.ApplyThemeToRoomButton)
	customizationsPane.ApplyWallpaperToAllWallsButton:Size(26)
	S:HandleButton(customizationsPane.ApplyWallpaperToAllWallsButton)

	local decorCustomizations = customizeModeFrame.DecorCustomizationsPane
	decorCustomizations:StripTextures()
	decorCustomizations:SetTemplate('Transparent')

	decorCustomizations.CloseButton:ClearAllPoints()
	decorCustomizations.CloseButton:Point('TOPRIGHT')

	S:HandleCloseButton(decorCustomizations.CloseButton)
	S:HandleButton(decorCustomizations.ButtonFrame.CancelButton)
	S:HandleButton(decorCustomizations.ButtonFrame.ApplyButton)

	local placedDecorList = editorFrame.ExpertDecorModeFrame.PlacedDecorList
	placedDecorList:StripTextures()
	placedDecorList:CreateBackdrop('Transparent')

	S:HandleTrimScrollBar(placedDecorList.ScrollBar)

	S:HandleCloseButton(placedDecorList.CloseButton)
	placedDecorList.CloseButton:ClearAllPoints()
	placedDecorList.CloseButton:Point('TOPRIGHT')

	local dyeSelectionPopout = _G.DyeSelectionPopout
	dyeSelectionPopout:StripTextures()
	dyeSelectionPopout:CreateBackdrop('Transparent')

	S:HandleTrimScrollBar(dyeSelectionPopout.DyeSlotScrollBar)
	S:HandleCheckBox(dyeSelectionPopout.ShowOnlyOwned)
end

function S:Blizzard_HousingModelPreview()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local previewFrame = _G.HousingModelPreviewFrame
	previewFrame:StripTextures()
	previewFrame:CreateBackdrop('Transparent')

	S:HandleCloseButton(previewFrame.CloseButton)
	previewFrame.ModelPreview:StripTextures()
	S:HandleModelSceneControlButtons(previewFrame.ModelPreview.ModelSceneControls)
end

local function SkinHousingBlueprintBaseFrame(frame)
	frame.Background:SetAlpha(0)
	frame.Header:SetAlpha(0)
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)

	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:Point('TOPRIGHT', frame, 'TOPRIGHT', -2, -2)
end

local function SkinHousingBlueprintShareCodeBox(shareCodeBox)
	shareCodeBox:StripTextures(true)
	S:HandleEditBox(shareCodeBox)
end

function S:Blizzard_HousingBlueprint()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local importFrame = _G.HousingBlueprintImportFrame
	SkinHousingBlueprintBaseFrame(importFrame)
	SkinHousingBlueprintShareCodeBox(importFrame.InputContent.ShareCodeBox)
	S:HandleButton(importFrame.InputContent.NextButton)

	local validationContent = importFrame.ValidationContent
	S:HandleButton(validationContent.ImportButton)
	S:HandleButton(validationContent.ContentSummary.ContentsListButton)

	local budgetsContainer = validationContent.ContentSummary.BudgetsContainer
	budgetsContainer.Background:SetAlpha(0)
	budgetsContainer:SetTemplate('Transparent')

	local exportFrame = _G.HousingBlueprintExportFrame
	SkinHousingBlueprintBaseFrame(exportFrame)
	S:HandleDropDownBox(exportFrame.InputContent.TypeDropdown)
	S:HandleEditBox(exportFrame.InputContent.NameInputBox)
	S:HandleButton(exportFrame.InputContent.SaveButton)

	local successContent = exportFrame.SuccessContent
	S:HandleButton(successContent.BlueprintsCollectionButton)
	S:HandleButton(successContent.ChatLinkButton)
	S:HandleButton(successContent.ClipboardButton)
	SkinHousingBlueprintShareCodeBox(successContent.ShareCodeBox)
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
