local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function PositionHousingDashbardTab(tab, _, _, _, x, y)
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

function S:Blizzard_HousingHouseFinder()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local FinderFrame = _G.HouseFinderFrame
	S:HandleFrame(FinderFrame, true)

	local woodBorder = FinderFrame.WoodBorderFrame
	if woodBorder then
		woodBorder:Hide()
	end

	local ListFrame = FinderFrame.NeighborhoodListFrame
	if ListFrame then
		ListFrame:StripTextures()

		ListFrame.BNetFriendSearchBox:DisableDrawLayer('BACKGROUND') -- Pimp me a bit

		S:HandleEditBox(ListFrame.BNetFriendSearchBox)
		S:HandleButton(ListFrame.RefreshButton)
	end
end

function S:Blizzard_HousingDashboard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local DashBoardFrame = _G.HousingDashboardFrame

	S:HandleFrame(DashBoardFrame, true)

	-- Fix the actual icon texture
	for i, tab in next, { DashBoardFrame.HouseInfoTabButton, DashBoardFrame.CatalogTabButton } do
		tab:CreateBackdrop()
		tab:Size(30, 40)

		if i == 1 then
			tab:ClearAllPoints()
			tab:SetPoint('TOPLEFT', DashBoardFrame, 'TOPRIGHT', 1, -10)

			hooksecurefunc(tab, 'SetPoint', PositionHousingDashbardTab)
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

		local HouseUpgradeFrame = InfoContent.ContentFrame.HouseUpgradeFrame
		if HouseUpgradeFrame then
			HouseUpgradeFrame.Background:Hide()

			S:HandleCheckBox(HouseUpgradeFrame.WatchFavorButton)
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
			Categories.Background:Hide()
		end

		local OptionsContainer = CatalogContent.OptionsContainer
		if OptionsContainer then
			S:HandleTrimScrollBar(OptionsContainer.ScrollBar)
		end

		local PreviewFrame = CatalogContent.PreviewFrame
		if PreviewFrame then
			PreviewFrame.PreviewBackground:Hide()
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
end

function S:Blizzard_HouseList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local ListFrame = _G.HouseListFrame
	if ListFrame then
		ListFrame:StripTextures()
		ListFrame:CreateBackdrop('Transparent')

		S:HandleCloseButton(ListFrame.CloseButton)
		S:HandleTrimScrollBar(ListFrame.ScrollBar)
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
		if ConfirmationFrame then
			ConfirmationFrame:StripTextures()
			ConfirmationFrame:SetTemplate()

			S:HandleButton(ConfirmationFrame.ConfirmButton)
			S:HandleButton(ConfirmationFrame.CancelButton)
		end
	end
end

S:AddCallbackForAddon('Blizzard_HouseList')
S:AddCallbackForAddon('Blizzard_HousingBulletinBoard')
S:AddCallbackForAddon('Blizzard_HousingCornerstone')
S:AddCallbackForAddon('Blizzard_HousingCreateNeighborhood')
S:AddCallbackForAddon('Blizzard_HousingDashboard')
S:AddCallbackForAddon('Blizzard_HousingHouseFinder')
