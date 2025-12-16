local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function PositionHousingDashboardTab(tab, _, _, _, x, y)
	if x ~= 1 or y ~= -10 then
		tab:ClearAllPoints()
		tab:SetPoint('TOPLEFT', _G.HousingDashboardFrame, 'TOPRIGHT', 1, -10)
	end
end

local function PositionTabIcons(icon, point)
	if point ~= 'CENTER' then
		icon:ClearAllPoints()
		icon:SetPoint('CENTER')
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

function S:Blizzard_HousingHouseFinder()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local FinderFrame = _G.HouseFinderFrame
	if FinderFrame then
		S:HandleFrame(FinderFrame, true)
		FinderFrame.WoodBorderFrame:Hide()
	end

	local NeighborhoodListFrame = FinderFrame.NeighborhoodListFrame
	if NeighborhoodListFrame then
		NeighborhoodListFrame:StripTextures()

		NeighborhoodListFrame.BNetFriendSearchBox:DisableDrawLayer('BACKGROUND') -- Pimp me a bit
		S:HandleEditBox(NeighborhoodListFrame.BNetFriendSearchBox)
		S:HandleButton(NeighborhoodListFrame.RefreshButton)
	end
end

function S:Blizzard_HousingDashboard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local DashBoardFrame = _G.HousingDashboardFrame
	if DashBoardFrame then
		S:HandleFrame(DashBoardFrame, true)
	end

	-- Fix the actual icon texture
	for i, tab in next, { DashBoardFrame.HouseInfoTabButton, DashBoardFrame.CatalogTabButton } do
		tab:CreateBackdrop()
		tab:Size(30, 40)

		if i == 1 then
			tab:ClearAllPoints()
			tab:SetPoint('TOPLEFT', DashBoardFrame, 'TOPRIGHT', 1, -10)

			hooksecurefunc(tab, 'SetPoint', PositionHousingDashboardTab)
		end

		if tab.Icon then
			tab.Icon:ClearAllPoints()
			tab.Icon:SetPoint('CENTER')

			hooksecurefunc(tab.Icon, 'SetPoint', PositionTabIcons)
		end

		if tab.SelectedTexture then
			tab.SelectedTexture:SetDrawLayer('ARTWORK')
			tab.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
			tab.SelectedTexture:SetAllPoints()
		end

		for _, region in next, { tab:GetRegions() } do
			if region:IsObjectType('Texture') and region:GetAtlas() == 'QuestLog-Tab-side-Glow-hover' then
				region:SetColorTexture(1, 1, 1, 0.3)
				region:SetAllPoints()
			end
		end
	end

	local InfoContent = DashBoardFrame.HouseInfoContent
	if InfoContent then
		S:HandleButton(InfoContent.HouseFinderButton)
		S:HandleDropDownBox(InfoContent.HouseDropdown)

		local ContentFrame = InfoContent.ContentFrame
		if ContentFrame then
			for _, tab in next, { ContentFrame.TabSystem:GetChildren() } do
				S:HandleTab(tab)
			end

			local HouseUpgradeFrame = ContentFrame.HouseUpgradeFrame
			if HouseUpgradeFrame then
				HouseUpgradeFrame:StripTextures()
				HouseUpgradeFrame.Background:Hide()
				S:HandleCheckBox(HouseUpgradeFrame.WatchFavorButton)
			end
		end
	end

	local CatalogContent = DashBoardFrame.CatalogContent
	if CatalogContent then
		if CatalogContent.Divider then
			CatalogContent.Divider:Hide()
		end

		if CatalogContent.Background then
			CatalogContent.Background:Hide()
		end

		if CatalogContent.SearchBox then
			S:HandleEditBox(CatalogContent.SearchBox)
			CatalogContent.SearchBox:Size(150, 17)
		end

		if CatalogContent.Filters then
			S:HandleDropDownBox(CatalogContent.Filters.FilterDropdown)
		end

		local Categories = CatalogContent.Categories
		if Categories then
			Categories.TopBorder:Hide()
			Categories.Background:Hide()
		end

		local OptionsContainer = CatalogContent.OptionsContainer
		if OptionsContainer then
			S:HandleTrimScrollBar(OptionsContainer.ScrollBar)
		end

		local PreviewFrame = CatalogContent.PreviewFrame
		if PreviewFrame then
			PreviewFrame.PreviewBackground:Hide()
			PreviewFrame.PreviewCornerLeft:Hide()
			PreviewFrame.PreviewCornerRight:Hide()
		end
	end
end

function S:Blizzard_HousingCornerstone()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local CornerVisitorFrame = _G.HousingCornerstoneVisitorFrame
	if CornerVisitorFrame then
		CornerVisitorFrame:StripTextures()
		CornerVisitorFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(CornerVisitorFrame.CloseButton)
	end

	local CornerInfoFrame = _G.HousingCornerstoneHouseInfoFrame
	if CornerInfoFrame then
		CornerInfoFrame:StripTextures()
		CornerInfoFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(CornerInfoFrame.CloseButton)
	end

	local PurchaseFrame = _G.HousingCornerstonePurchaseFrame
	if PurchaseFrame then
		PurchaseFrame:StripTextures()
		PurchaseFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(PurchaseFrame.CloseButton)
		S:HandleButton(PurchaseFrame.BuyButton)
	end

	local MoveHouseConfirmation = _G.MoveHouseConfirmationDialog
	if MoveHouseConfirmation then
		MoveHouseConfirmation:StripTextures()
		MoveHouseConfirmation:CreateBackdrop('Transparent')
		S:HandleButton(MoveHouseConfirmation.ConfirmButton)
		S:HandleButton(MoveHouseConfirmation.CancelButton)
	end
end

function S:Blizzard_HousingBulletinBoard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local BulletinBoardFrame = _G.HousingBulletinBoardFrame
	if BulletinBoardFrame then
		BulletinBoardFrame:StripTextures()
		-- BulletinBoardFrame.FoliageDecoration:Kill() -- grrr
		S:HandleCloseButton(BulletinBoardFrame.CloseButton)

		local ResidentsTab = BulletinBoardFrame.ResidentsTab
		if ResidentsTab then
			S:HandleTrimScrollBar(ResidentsTab.ScrollBar)
		end
	end

	local ChangeNameDialog = _G.NeighborhoodChangeNameDialog
	if ChangeNameDialog then
		ChangeNameDialog:StripTextures()
		ChangeNameDialog:CreateBackdrop('Transparent')
		S:HandleEditBox(ChangeNameDialog.NameEditBox)
		S:HandleButton(ChangeNameDialog.ConfirmButton) -- Fix Backdrop
		S:HandleButton(ChangeNameDialog.CancelButton)  -- Fix Backdrop
	end
end

function S:Blizzard_HouseList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local ListFrame = _G.HouseListFrame
	if ListFrame then
		ListFrame:StripTextures()
		ListFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(ListFrame.CloseButton)
		S:HandleTrimScrollBar(ListFrame.ScrollBar)

		hooksecurefunc(ListFrame.ScrollBox, 'Update', HouseList_Update)
	end
end

function S:Blizzard_HousingCreateNeighborhood()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local CreateGuildFrame = _G.HousingCreateGuildNeighborhoodFrame
	if CreateGuildFrame then
		CreateGuildFrame:StripTextures()
		CreateGuildFrame:CreateBackdrop('Transparent')

		S:HandleEditBox(CreateGuildFrame.NeighborhoodNameEditBox)
		S:HandleButton(CreateGuildFrame.ConfirmButton)
		S:HandleButton(CreateGuildFrame.CancelButton)

		local ConfirmationFrame = CreateGuildFrame.ConfirmationFrame
		ConfirmationFrame:StripTextures()
		ConfirmationFrame:SetTemplate()
		S:HandleButton(ConfirmationFrame.ConfirmButton)
		S:HandleButton(ConfirmationFrame.CancelButton)
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

	local SettingsFrame = _G.HousingHouseSettingsFrame
	if SettingsFrame then
		local PlotAccess = SettingsFrame.PlotAccess
		local HouseAccess = SettingsFrame.HouseAccess

		SettingsFrame:StripTextures()
		SettingsFrame:SetTemplate('Transparent')
		S:HandleCloseButton(SettingsFrame.CloseButton)
		S:HandleDropDownBox(SettingsFrame.HouseOwnerDropdown, 240)
		S:HandleButton(SettingsFrame.AbandonHouseButton)
		S:HandleDropDownBox(PlotAccess.AccessTypeDropdown)
		S:HandleDropDownBox(HouseAccess.AccessTypeDropdown)

		hooksecurefunc(PlotAccess, 'SetupOptions', SkinHouseSettingOptions)
		hooksecurefunc(HouseAccess, 'SetupOptions', SkinHouseSettingOptions)
		SkinHouseSettingOptions(PlotAccess)
		SkinHouseSettingOptions(HouseAccess)

		S:HandleButton(SettingsFrame.IgnoreListButton)
		S:HandleButton(SettingsFrame.SaveButton)
	end

	local AbandonHouseConfirmationDialog = _G.AbandonHouseConfirmationDialog
	if AbandonHouseConfirmationDialog then
		AbandonHouseConfirmationDialog:StripTextures()
		AbandonHouseConfirmationDialog:SetTemplate('Transparent')
		S:HandleButton(AbandonHouseConfirmationDialog.ConfirmButton)
		S:HandleButton(AbandonHouseConfirmationDialog.CancelButton)
	end
end

function S:Blizzard_HouseEditor()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local EditorFrame = _G.HouseEditorFrame

	local StorageButton = EditorFrame.StorageButton
	if StorageButton then
		S:HandleButton(StorageButton, true, nil, nil, nil, 'Transparent')
		StorageButton:NudgePoint(2)

		local StorageIcon = StorageButton.Icon
		if StorageIcon then
			StorageIcon:SetAtlas('house-chest-icon') -- Use same icon as default WoW UI
			StorageIcon:Size(32)
			StorageIcon:ClearAllPoints()
			StorageIcon:Point('CENTER')
		end
	end

	local StoragePanel = EditorFrame.StoragePanel
	if StoragePanel then
		StoragePanel:StripTextures()
		StoragePanel:SetTemplate('Transparent')
		S:HandleEditBox(StoragePanel.SearchBox)
		StoragePanel.SearchBox:Size(350, 21)
		S:HandleButton(StoragePanel.Filters.FilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
		S:HandleCloseButton(StoragePanel.Filters.FilterDropdown.ResetButton)
		StoragePanel.Filters.FilterDropdown.ResetButton:ClearAllPoints()
		StoragePanel.Filters.FilterDropdown.ResetButton:Point('CENTER', StoragePanel.Filters.FilterDropdown, 'TOPRIGHT', 0, 0)

		for _, tab in next, { StoragePanel.TabSystem:GetChildren() } do
			S:HandleTab(tab)
		end

		local Categories = StoragePanel.Categories
		if Categories then
			Categories.TopBorder:Hide()
			Categories.Background:Hide()
		end

		local OptionsContainer = StoragePanel.OptionsContainer
		if OptionsContainer then
			S:HandleTrimScrollBar(OptionsContainer.ScrollBar)
		end

		local CollapseButton = StoragePanel.CollapseButton
		if CollapseButton then
			S:HandleButton(CollapseButton, true, nil, nil, nil, 'Transparent')
			CollapseButton:NudgePoint(4)

			S:SetupArrow(CollapseButton.Icon, 'left')
			CollapseButton.Icon:SetTexCoord(0, 1, 0, 1)
			CollapseButton.Icon:Size(18)
			CollapseButton.Icon:ClearAllPoints()
			CollapseButton.Icon:Point('CENTER')
		end
	end

	local CustomizationFrame = EditorFrame.ExteriorCustomizationModeFrame
	if CustomizationFrame then
		local FixtureOptionList = CustomizationFrame.FixtureOptionList
		if FixtureOptionList then
			FixtureOptionList:StripTextures()
			FixtureOptionList:SetTemplate('Transparent')

			S:HandleCloseButton(FixtureOptionList.CloseButton)
			FixtureOptionList.CloseButton:ClearAllPoints()
			FixtureOptionList.CloseButton:Point('TOPRIGHT', FixtureOptionList, 'TOPRIGHT')

			S:HandleTrimScrollBar(FixtureOptionList.ScrollBar)
		end

		local CoreOptions = CustomizationFrame.CoreOptionsPanel
		if CoreOptions then
			for _, CorePanel in next, {
				CoreOptions,
				CoreOptions.HouseTypeOption,
				CoreOptions.HouseSizeOption,
				CoreOptions.BaseStyleOption,
				CoreOptions.RoofStyleOption,
				CoreOptions.RoofVariantOption
			} do
				if CorePanel.Dropdown then
					S:HandleDropDownBox(CorePanel.Dropdown)
				end
			end
		end
	end

	local CustomizeModeFrame = EditorFrame.CustomizeModeFrame
	local CustomizationsPane = CustomizeModeFrame and CustomizeModeFrame.RoomComponentCustomizationsPane
	if CustomizationsPane then
		CustomizationsPane:StripTextures()
		CustomizationsPane:SetTemplate('Transparent')
		CustomizationsPane.CloseButton:ClearAllPoints()
		CustomizationsPane.CloseButton:Point('TOPRIGHT')
		S:HandleCloseButton(CustomizationsPane.CloseButton)

		for _, RoomComponentPanel in next, {
			CustomizationsPane.ThemeDropdown,
			CustomizationsPane.WallpaperDropdown,
			CustomizationsPane.DoorTypeDropdown,
			CustomizationsPane.CeilingTypeDropdown
		} do
			if RoomComponentPanel.Dropdown then
				S:HandleDropDownBox(RoomComponentPanel.Dropdown)
			end
		end

		if CustomizationsPane.ApplyThemeToRoomButton then
			CustomizationsPane.ApplyThemeToRoomButton:Size(26)
			S:HandleButton(CustomizationsPane.ApplyThemeToRoomButton)
		end

		if CustomizationsPane.ApplyWallpaperToAllWallsButton then
			CustomizationsPane.ApplyWallpaperToAllWallsButton:Size(26)
			S:HandleButton(CustomizationsPane.ApplyWallpaperToAllWallsButton)
		end
	end

	local ExpertDecorModeFrame = EditorFrame.ExpertDecorModeFrame
	local PlacedDecorList = ExpertDecorModeFrame and ExpertDecorModeFrame.PlacedDecorList
	if PlacedDecorList then
		PlacedDecorList:StripTextures()
		PlacedDecorList:CreateBackdrop('Transparent')

		S:HandleTrimScrollBar(PlacedDecorList.ScrollBar)

		S:HandleCloseButton(PlacedDecorList.CloseButton)
		PlacedDecorList.CloseButton:ClearAllPoints()
		PlacedDecorList.CloseButton:Point('TOPRIGHT')
	end

	local DyeSelectionPopout = _G.DyeSelectionPopout
	if DyeSelectionPopout then
		DyeSelectionPopout:StripTextures()
		DyeSelectionPopout:CreateBackdrop('Transparent')
		S:HandleTrimScrollBar(DyeSelectionPopout.DyeSlotScrollBar)
		S:HandleCheckBox(DyeSelectionPopout.ShowOnlyOwned)
	end
end

function S:Blizzard_HousingModelPreview()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local PreviewFrame = _G.HousingModelPreviewFrame
	if PreviewFrame then
		PreviewFrame:StripTextures()
		PreviewFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(PreviewFrame.CloseButton)

		local ModelPreview = PreviewFrame.ModelPreview
		if ModelPreview then
			ModelPreview:StripTextures()
		end
	end
end

S:AddCallbackForAddon('Blizzard_HouseList')
S:AddCallbackForAddon('Blizzard_HousingBulletinBoard')
S:AddCallbackForAddon('Blizzard_HousingCornerstone')
S:AddCallbackForAddon('Blizzard_HousingCreateNeighborhood')
S:AddCallbackForAddon('Blizzard_HousingDashboard')
S:AddCallbackForAddon('Blizzard_HousingHouseFinder')
S:AddCallbackForAddon('Blizzard_HousingHouseSettings')
S:AddCallbackForAddon('Blizzard_HouseEditor')
S:AddCallbackForAddon('Blizzard_HousingModelPreview')
