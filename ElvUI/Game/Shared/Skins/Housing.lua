local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, next = ipairs, next
local hooksecurefunc = hooksecurefunc

local PROGESS_COLOR = { .81, .52, .04 }

for _, addonName in next, {
	'Blizzard_HouseList',
	'Blizzard_HousingCharter',
	'Blizzard_HousingBulletinBoard',
	'Blizzard_HousingCornerstone',
	'Blizzard_HousingCreateNeighborhood',
	'Blizzard_HousingHouseFinder',
	'Blizzard_HousingHouseSettings',
	'Blizzard_HouseEditor',
	'Blizzard_HousingModelPreview',
	'Blizzard_HousingBlueprint',
} do
	S:AddCallbackForAddon(addonName, nil, nil, nil, nil, nil, 'housing')
end

local dashboard = S:AddCallbackForAddon('Blizzard_HousingDashboard', nil, nil, nil, nil, nil, 'housing')

function dashboard:PositionTabIcons(_, x)
	if not x then return end

	self:ClearAllPoints()
	self:SetPoint('CENTER')
end

function dashboard:HandleDashboardTabs(frame)
	local previous
	for _, tab in ipairs(frame.TabButtons) do
		tab:Size(32, 42)
		tab:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true) -- noScale

		tab:ClearAllPoints()
		if previous then
			tab:Point('TOPLEFT', previous, 'BOTTOMLEFT', 0, -1)
		else
			tab:Point('TOPLEFT', frame, 'TOPRIGHT', 1, 0)
		end

		previous = tab

		tab.SelectedTexture:SetDrawLayer('ARTWORK')
		tab.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
		tab.SelectedTexture:SetInside(tab.backdrop)

		tab.HighlightTexture:SetColorTexture(1, 1, 1, 0.3)
		tab.HighlightTexture:SetInside(tab.backdrop)

		tab.Background:SetAlpha(0)
		tab.TabGlow:SetAlpha(0)

		tab.Icon:ClearAllPoints()
		tab.Icon:SetPoint('CENTER')

		hooksecurefunc(tab.Icon, 'SetPoint', dashboard.PositionTabIcons)
	end
end

-- Initiative task rows (HousingDashboard_InitiativeTaskTemplate, HousingDashboard_InitiativeSubtaskTemplate)
function dashboard:HandleInitiativeTask()
	if self.IsSkinned then return end

	self.BG:SetAlpha(0)

	self:CreateBackdrop()
	self.backdrop:SetInside(self, 0, 1)

	-- hover texture, the template sets its alpha to .7
	local hover = self.BGAlphaAdd
	hover:SetColorTexture(1, 1, 1, .25)
	hover:SetInside(self.backdrop)
	hover:SetAlpha(1)

	self.IsSkinned = true
end

function dashboard:TaskListUpdate()
	self:ForEachFrame(dashboard.HandleInitiativeTask)
end

-- Activity log rows (HousingDashboard_InitiativeTaskActivityEntryTemplate)
function dashboard:HandleActivityEntry()
	if self.IsSkinned then return end

	self.Divider:SetAlpha(0)

	self:CreateBackdrop()
	self.backdrop:SetInside(self, 0, 1)

	self.IsSkinned = true
end

function dashboard:ActivityLogUpdate()
	self:ForEachFrame(dashboard.HandleActivityEntry)
end

-- Clear the gradient instead of ClearEdgeFade
function dashboard:ClearEdgeGradient()
	self:ClearAlphaGradient()
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
	local dashboardFrame = _G.HousingDashboardFrame
	S:HandleFrame(dashboardFrame, true)
	dashboard:HandleDashboardTabs(dashboardFrame)
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

	local initiativeSet = initiativesFrame.InitiativeSetFrame

	-- Progress bar in Blizzard's fill color
	local progressBar = initiativeSet.ProgressBar
	S:HandleStatusBar(progressBar, PROGESS_COLOR)
	progressBar.BarEnd.Overlay:SetAlpha(0)

	local tasks = initiativeSet.InitiativeTasks
	tasks.BG:StripTextures()
	tasks:SetTemplate('Transparent')
	S:HandleTrimScrollBar(tasks.ScrollBar)

	local taskList = tasks.TaskList
	hooksecurefunc(taskList, 'Update', dashboard.TaskListUpdate)
	hooksecurefunc(taskList, 'ApplyEdgeFade', dashboard.ClearEdgeGradient)

	for _, frame in next, {
		tasks.BG,
		tasks.BorderRight,
		tasks.BorderTop,
		tasks.TitleCornerTR,
		tasks.TaskListTitleContainer.TitleCornerBR,
		tasks.TaskListTitleContainer.TitleFoliage
	} do
		frame:StripTextures()
	end

	local activity = initiativeSet.InitiativeActivity
	activity:SetTemplate('Transparent')
	S:HandleTrimScrollBar(activity.ScrollBar)

	local activityLog = activity.ActivityLog
	hooksecurefunc(activityLog, 'Update', dashboard.ActivityLogUpdate)
	hooksecurefunc(activityLog, 'ApplyEdgeFade', dashboard.ClearEdgeGradient)

	for _, frame in next, {
		activity.BG,
		activity.BGTexture,
		activity.BorderTop,
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
	local signatureDialog = _G.HousingCharterRequestSignatureDialog
	signatureDialog:StripTextures()
	signatureDialog:CreateBackdrop('Transparent')

	S:HandleButton(signatureDialog.ConfirmButton)
	S:HandleButton(signatureDialog.CancelButton)
end

function S:Blizzard_HouseList()
	local listFrame = _G.HouseListFrame
	listFrame:StripTextures()
	listFrame:CreateBackdrop('Transparent')

	S:HandleCloseButton(listFrame.CloseButton)
	S:HandleTrimScrollBar(listFrame.ScrollBar)

	hooksecurefunc(listFrame.ScrollBox, 'Update', HouseList_Update)
end

function S:Blizzard_HousingCreateNeighborhood()
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
