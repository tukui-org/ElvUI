local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, pairs, unpack = next, pairs, unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- Credits: siweia (AuroraClassic)
local function SkinEditBoxes(Frame)
	S:HandleEditBox(Frame.MinLevel)
	S:HandleEditBox(Frame.MaxLevel)
end

local function SkinFilterButton(Button)
	SkinEditBoxes(Button.LevelRangeFrame)

	S:HandleCloseButton(Button.ClearFiltersButton)
	S:HandleButton(Button)
end

local function HandleSearchBarFrame(Frame)
	SkinFilterButton(Frame.FilterButton)

	S:HandleButton(Frame.SearchButton)
	S:HandleEditBox(Frame.SearchBox)
	S:HandleButton(Frame.FavoritesSearchButton)
	Frame.FavoritesSearchButton:Size(22)
end

local function HandleListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			for j = 1, 4 do
				local cell = row.cells and row.cells[j]
				if cell and cell.Icon then
					if not cell.IsSkinned then
						S:HandleIcon(cell.Icon)

						if cell.IconBorder then
							cell.IconBorder:Kill()
						end

						cell.IsSkinned = true
					end
				end
			end
		end
	end
end

local function HandleSummaryIcons(frame)
	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		if child.Icon then
			if not child.IsSkinned then
				S:HandleIcon(child.Icon)

				if child.IconBorder then
					child.IconBorder:Kill()
				end

				child.IsSkinned = true
			end
		end
	end
end

local function SkinItemDisplay(frame)
	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop('Transparent')
	ItemDisplay.backdrop:Point('TOPLEFT', 3, -3)
	ItemDisplay.backdrop:Point('BOTTOMRIGHT', -3, 0)

	local ItemButton = ItemDisplay.ItemButton
	ItemButton.CircleMask:Hide()

	S:HandleIcon(ItemButton.Icon, true)
	S:HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	ItemButton:GetHighlightTexture():Hide()
end

local function HandleHeaders(frame)
	local maxHeaders = frame.HeaderContainer:GetNumChildren()
	for i, header in next, { frame.HeaderContainer:GetChildren() } do
		if not header.IsSkinned then
			header:DisableDrawLayer('BACKGROUND')

			if not header.backdrop then
				header:CreateBackdrop('Transparent')
			end

			header.IsSkinned = true
		end

		if header.backdrop then
			header.backdrop:Point('BOTTOMRIGHT', i < maxHeaders and -5 or 0, -2)
		end
	end

	HandleListIcon(frame)
end

local function HandleAuctionButtons(button)
	S:HandleButton(button)
	button:Size(22)
end

local function HandleSellFrame(frame)
	frame:StripTextures()

	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:SetTemplate('Transparent')

	local ItemButton = ItemDisplay.ItemButton
	if ItemButton.IconMask then ItemButton.IconMask:Hide() end

	ItemButton.EmptyBackground:Hide()
	ItemButton:SetPushedTexture(E.ClearTexture)
	ItemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	ItemButton.Highlight:SetAllPoints(ItemButton.Icon)

	S:HandleIcon(ItemButton.Icon, true)
	S:HandleEditBox(frame.QuantityInput.InputBox)
	S:HandleButton(frame.QuantityInput.MaxButton)
	S:HandleEditBox(frame.PriceInput.MoneyInputFrame.GoldBox)
	S:HandleEditBox(frame.PriceInput.MoneyInputFrame.SilverBox)

	if ItemButton.IconBorder then
		S:HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	end

	if frame.SecondaryPriceInput then
		S:HandleEditBox(frame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
		S:HandleEditBox(frame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
	end

	S:HandleDropDownBox(frame.DurationDropDown.DropDown)
	S:HandleButton(frame.PostButton)

	if frame.BuyoutModeCheckButton then
		S:HandleCheckBox(frame.BuyoutModeCheckButton)
		frame.BuyoutModeCheckButton:Size(20)
	end
end

local function HandleTokenSellFrame(frame)
	frame:StripTextures()

	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:SetTemplate('Transparent')

	local ItemButton = ItemDisplay.ItemButton
	if ItemButton.IconMask then ItemButton.IconMask:Hide() end

	ItemButton.EmptyBackground:Hide()
	ItemButton:SetPushedTexture(E.ClearTexture)
	ItemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	ItemButton.Highlight:SetAllPoints(ItemButton.Icon)

	S:HandleIcon(ItemButton.Icon, true)

	if ItemButton.IconBorder then
		S:HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	end

	S:HandleButton(frame.PostButton)
	HandleAuctionButtons(frame.DummyRefreshButton)

	frame.DummyItemList:StripTextures()
	frame.DummyItemList:SetTemplate('Transparent')
	HandleAuctionButtons(frame.DummyRefreshButton)
	S:HandleScrollBar(frame.DummyItemList.DummyScrollBar)
end

local function HandleSellList(frame, hasHeader, fitScrollBar)
	frame:StripTextures()

	if frame.RefreshFrame then
		HandleAuctionButtons(frame.RefreshFrame.RefreshButton)
	end

	S:HandleTrimScrollBar(frame.ScrollBar)

	if fitScrollBar then
		frame.ScrollBar:ClearAllPoints()
		frame.ScrollBar:Point('TOPLEFT', frame, 'TOPRIGHT', 1, -16)
		frame.ScrollBar:Point('BOTTOMLEFT', frame, 'BOTTOMRIGHT', 1, 16)
	end

	if hasHeader then
		frame.ScrollBox:SetTemplate('Transparent')

		hooksecurefunc(frame, 'RefreshScrollFrame', HandleHeaders)
	else
		hooksecurefunc(frame.ScrollBox, 'Update', HandleSummaryIcons)
	end
end

local function HandleTabs(arg1)
	local frame = _G.AuctionHouseFrame
	if not arg1 or arg1 ~= frame then return end

	local lastTab = _G.AuctionHouseFrameBuyTab
	for index, tab in next, frame.Tabs do
		-- we can move addon tabs but only skin the blizzard ones (AddonSkins handles the rest)
		local blizzTab = tab == _G.AuctionHouseFrameBuyTab or tab == _G.AuctionHouseFrameSellTab or tab == _G.AuctionHouseFrameAuctionsTab
		if blizzTab and not tab.backdrop then
			S:HandleTab(tab)
		end

		-- tab positions
		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', -3, -32)
		else -- skinned ones can be closer together
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', (tab.backdrop or tab.Backdrop) and -5 or 0, 0)
		end

		lastTab = tab
	end
end

local function LoadSkin()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.auctionhouse) then return end

	--[[ Main Frame | TAB 1]]--
	local Frame = _G.AuctionHouseFrame
	S:HandlePortraitFrame(Frame)

	-- handle tab spacing
	hooksecurefunc('PanelTemplates_SetNumTabs', HandleTabs)
	HandleTabs(Frame) -- call it once to setup our tabs

	-- SearchBar Frame
	HandleSearchBarFrame(Frame.SearchBar)
	Frame.MoneyFrameBorder:StripTextures()
	Frame.MoneyFrameInset:StripTextures()

	--[[ Categorie List ]]--
	local Categories = Frame.CategoriesList
	Categories:StripTextures()
	Categories:SetTemplate('Transparent')
	S:HandleTrimScrollBar(Categories.ScrollBar)

	hooksecurefunc('AuctionHouseFilterButton_SetUp', function(button)
		local r, g, b = unpack(E.media.rgbvaluecolor)
		button.NormalTexture:SetAlpha(0)
		button.SelectedTexture:SetColorTexture(r, g, b, .25)
		button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
	end)

	--[[ Browse Frame ]]--
	local Browse = Frame.BrowseResultsFrame

	local BrowseList = Browse.ItemList
	BrowseList:StripTextures()
	hooksecurefunc(BrowseList, 'RefreshScrollFrame', HandleHeaders)
	S:HandleTrimScrollBar(BrowseList.ScrollBar)
	BrowseList:SetTemplate('Transparent')
	BrowseList.ScrollBar:ClearAllPoints()
	BrowseList.ScrollBar:Point('TOPLEFT', BrowseList, 'TOPRIGHT', 1, -16)
	BrowseList.ScrollBar:Point('BOTTOMLEFT', BrowseList, 'BOTTOMRIGHT', 1, 16)

	--[[ BuyOut Frame]]
	local CommoditiesBuyFrame = Frame.CommoditiesBuyFrame
	CommoditiesBuyFrame.BuyDisplay:StripTextures()
	S:HandleButton(CommoditiesBuyFrame.BackButton)

	local CommoditiesBuyList = Frame.CommoditiesBuyFrame.ItemList
	CommoditiesBuyList:StripTextures()
	CommoditiesBuyList:SetTemplate('Transparent')
	S:HandleButton(CommoditiesBuyList.RefreshFrame.RefreshButton)
	S:HandleTrimScrollBar(CommoditiesBuyList.ScrollBar)

	local BuyDisplay = Frame.CommoditiesBuyFrame.BuyDisplay
	S:HandleEditBox(BuyDisplay.QuantityInput.InputBox)
	S:HandleButton(BuyDisplay.BuyButton)

	SkinItemDisplay(BuyDisplay)

	--[[ ItemBuyOut Frame]]
	local ItemBuyFrame = Frame.ItemBuyFrame
	S:HandleButton(ItemBuyFrame.BackButton)
	S:HandleButton(ItemBuyFrame.BuyoutFrame.BuyoutButton)

	SkinItemDisplay(ItemBuyFrame)

	local ItemBuyList = ItemBuyFrame.ItemList
	ItemBuyList:StripTextures()
	ItemBuyList:SetTemplate('Transparent')
	S:HandleTrimScrollBar(ItemBuyList.ScrollBar)
	S:HandleButton(ItemBuyList.RefreshFrame.RefreshButton)
	hooksecurefunc(ItemBuyList, 'RefreshScrollFrame', HandleHeaders)

	local EditBoxes = {
		_G.AuctionHouseFrameGold,
		_G.AuctionHouseFrameSilver,
	}

	for _, EditBox in pairs(EditBoxes) do
		S:HandleEditBox(EditBox)
	end

	S:HandleButton(ItemBuyFrame.BidFrame.BidButton)
	ItemBuyFrame.BidFrame.BidButton:ClearAllPoints()
	ItemBuyFrame.BidFrame.BidButton:Point('LEFT', ItemBuyFrame.BidFrame.BidAmount, 'RIGHT', 2, -2)
	S:HandleButton(ItemBuyFrame.BidFrame.BidButton)

	--[[ Item Sell Frame | TAB 2 ]]--
	local SellFrame = Frame.ItemSellFrame
	HandleSellFrame(SellFrame)
	Frame.ItemSellFrame:SetTemplate('Transparent')

	local ItemSellList = Frame.ItemSellList
	HandleSellList(ItemSellList, true, true)

	local CommoditiesSellFrame = Frame.CommoditiesSellFrame
	HandleSellFrame(CommoditiesSellFrame)

	local CommoditiesSellList = Frame.CommoditiesSellList
	HandleSellList(CommoditiesSellList, true)

	local TokenSellFrame = Frame.WoWTokenSellFrame
	HandleTokenSellFrame(TokenSellFrame)

	--[[ Auctions Frame | TAB 3 ]]--
	local AuctionsFrame = _G.AuctionHouseFrameAuctionsFrame
	AuctionsFrame:StripTextures()
	SkinItemDisplay(AuctionsFrame)
	S:HandleButton(AuctionsFrame.BuyoutFrame.BuyoutButton)

	local CommoditiesList = AuctionsFrame.CommoditiesList
	HandleSellList(CommoditiesList, true)
	S:HandleButton(CommoditiesList.RefreshFrame.RefreshButton)

	local AuctionsList = AuctionsFrame.ItemList
	HandleSellList(AuctionsList, true)
	S:HandleButton(AuctionsList.RefreshFrame.RefreshButton)

	local AuctionsFrameTabs = {
		_G.AuctionHouseFrameAuctionsFrameAuctionsTab,
		_G.AuctionHouseFrameAuctionsFrameBidsTab,
	}

	for _, tab in pairs(AuctionsFrameTabs) do
		if tab then
			S:HandleTab(tab)
		end
	end

	local SummaryList = AuctionsFrame.SummaryList
	HandleSellList(SummaryList)
	SummaryList:SetTemplate('Transparent')
	S:HandleButton(AuctionsFrame.CancelAuctionButton)

	SummaryList.ScrollBar:ClearAllPoints()
	SummaryList.ScrollBar:Point('TOPRIGHT', SummaryList, -3, -20)
	SummaryList.ScrollBar:Point('BOTTOMRIGHT', SummaryList, -3, 20)

	local AllAuctionsList = AuctionsFrame.AllAuctionsList
	HandleSellList(AllAuctionsList, true, true)
	S:HandleButton(AllAuctionsList.RefreshFrame.RefreshButton)
	AllAuctionsList.ResultsText:SetParent(AllAuctionsList.ScrollFrame)

	SummaryList:Point('BOTTOM', AuctionsFrame, 0, 0) -- normally this is anchored to the cancel button.. ? lol
	AuctionsFrame.CancelAuctionButton:ClearAllPoints()
	AuctionsFrame.CancelAuctionButton:Point('TOPRIGHT', AllAuctionsList, 'BOTTOMRIGHT', -6, 1)

	local BidsList = AuctionsFrame.BidsList
	HandleSellList(BidsList, true, true)
	BidsList.ResultsText:SetParent(BidsList.ScrollFrame)
	S:HandleButton(BidsList.RefreshFrame.RefreshButton)
	S:HandleEditBox(_G.AuctionHouseFrameAuctionsFrameGold)
	S:HandleEditBox(_G.AuctionHouseFrameAuctionsFrameSilver)
	S:HandleButton(AuctionsFrame.BidFrame.BidButton)

	--[[ ProgressBars ]]--

	--[[ WoW Token Category ]]--
	local TokenFrame = Frame.WoWTokenResults
	TokenFrame:StripTextures()
	S:HandleButton(TokenFrame.Buyout)
	S:HandleScrollBar(TokenFrame.DummyScrollBar) --MONITOR THIS

	local Token = TokenFrame.TokenDisplay
	Token:StripTextures()
	Token:SetTemplate('Transparent')

	local ItemButton = Token.ItemButton
	S:HandleIcon(ItemButton.Icon, true)
	ItemButton.Icon.backdrop:SetBackdropBorderColor(0, .8, 1)
	ItemButton:GetHighlightTexture():Hide()
	ItemButton.CircleMask:Hide()
	ItemButton.IconBorder:Kill()

	--WoW Token Tutorial Frame
	local WowTokenGameTimeTutorial = Frame.WoWTokenResults.GameTimeTutorial
	WowTokenGameTimeTutorial.NineSlice:Hide()
	WowTokenGameTimeTutorial:SetTemplate('Transparent')
	S:HandleCloseButton(WowTokenGameTimeTutorial.CloseButton)
	S:HandleButton(WowTokenGameTimeTutorial.RightDisplay.StoreButton)
	WowTokenGameTimeTutorial.Bg:SetAlpha(0)
	WowTokenGameTimeTutorial.LeftDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.LeftDisplay.Tutorial1:SetTextColor(1, 0, 0)
	WowTokenGameTimeTutorial.RightDisplay.Label:SetTextColor(1, 1, 1)
	WowTokenGameTimeTutorial.RightDisplay.Tutorial1:SetTextColor(1, 0, 0)

	--[[ Dialogs ]]--
	Frame.BuyDialog:StripTextures()
	Frame.BuyDialog:SetTemplate('Transparent')
	S:HandleButton(Frame.BuyDialog.BuyNowButton)
	S:HandleButton(Frame.BuyDialog.CancelButton)

	--[[ Multisell ]]--
	local multisellFrame = _G.AuctionHouseMultisellProgressFrame
	multisellFrame:StripTextures()
	multisellFrame:SetTemplate('Transparent')

	local progressBar = multisellFrame.ProgressBar
	progressBar:StripTextures()
	progressBar:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, true)
	progressBar:SetStatusBarTexture(E.media.normTex)

	progressBar.Text:ClearAllPoints()
	progressBar.Text:Point('BOTTOM', progressBar, 'TOP', 0, 5)

	S:HandleCloseButton(multisellFrame.CancelButton)
	S:HandleIcon(progressBar.Icon)

	-- progressBar already has a backdrop for itself
	progressBar.IconBackdrop = CreateFrame('Frame', '$parentIconBackdrop', progressBar)
	progressBar.IconBackdrop:SetFrameLevel(progressBar:GetFrameLevel())
	progressBar.IconBackdrop:SetOutside(progressBar.Icon)
	progressBar.IconBackdrop:SetTemplate()
end

S:AddCallbackForAddon('Blizzard_AuctionHouseUI', 'AuctionHouse', LoadSkin)
