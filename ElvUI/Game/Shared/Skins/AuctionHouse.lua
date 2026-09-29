local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetAuctionSellItemInfo = GetAuctionSellItemInfo

if E.Modern or E.Mists then
	local data = S:AddCallbackForAddon('Blizzard_AuctionHouseUI')
	data.toggle = 'auctionhouse'
else
	local data = S:AddCallbackForAddon('Blizzard_AuctionUI', 'Blizzard_AuctionHouseUI')
	data.toggle = 'auctionhouse'
end

-- Credits: siweia (AuroraClassic)
local function SkinFilterButton(Button)
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
	local builder = frame.tableBuilder
	if not builder then return end -- RefreshScrollFrame runs before Init on hidden lists

	for i = 1, 22 do
		local row = builder.rows[i]
		if row then
			for j = 1, 4 do
				local cell = row.cells[j]
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

local function HandleSummaryIcon(child)
	if not child.IsSkinned then
		S:HandleIcon(child.Icon)
		child.IconBorder:Kill()

		child.IsSkinned = true
	end
end

local function HandleSummaryIcons(frame)
	frame:ForEachFrame(HandleSummaryIcon)
end

local function SkinItemDisplay(frame)
	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop('Transparent')
	ItemDisplay.backdrop:Point('TOPLEFT', 3, -3)
	ItemDisplay.backdrop:Point('BOTTOMRIGHT', -3, 0)

	local ItemButton = ItemDisplay.ItemButton
	if E.Modern then
		ItemButton.CircleMask:Hide()
	end

	S:HandleIcon(ItemButton.Icon, true)
	S:HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	ItemButton:GetHighlightTexture():Hide()
end

local function HandleHeaders(frame)
	local maxHeaders = frame.HeaderContainer:GetNumChildren()
	for i, header in next, { frame.HeaderContainer:GetChildren() } do
		if not header.IsSkinned then
			header:DisableDrawLayer('BACKGROUND')
			header:CreateBackdrop('Transparent')

			header.IsSkinned = true
		end

		header.backdrop:Point('BOTTOMRIGHT', i < maxHeaders and -5 or 0, -2)
	end

	HandleListIcon(frame)
end

local function HandleAuctionButtons(button)
	S:HandleButton(button)
	button:Size(22)
end

local function HandleBidAmount(frame)
	S:HandleEditBox(frame.gold)
	S:HandleEditBox(frame.silver)
	S:HandleEditBox(frame.copper)

	-- both bid frames name their money boxes BidAmountGold and so on, so HandleEditBox only strips whichever one holds the global
	frame.gold:DisableDrawLayer('BACKGROUND')
	frame.silver:DisableDrawLayer('BACKGROUND')
	frame.copper:DisableDrawLayer('BACKGROUND')
end

local function HandleSellFrame(frame)
	frame:StripTextures()

	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:SetTemplate('Transparent')

	local ItemButton = ItemDisplay.ItemButton
	if E.Modern then
		ItemButton.IconMask:Hide()
	end

	ItemButton.EmptyBackground:Hide()
	ItemButton:SetPushedTexture(E.ClearTexture)
	ItemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	ItemButton.Highlight:SetAllPoints(ItemButton.Icon)

	S:HandleIcon(ItemButton.Icon, true)
	S:HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)
	S:HandleEditBox(frame.QuantityInput.InputBox)
	S:HandleButton(frame.QuantityInput.MaxButton)
	S:HandleEditBox(frame.PriceInput.MoneyInputFrame.GoldBox)
	S:HandleEditBox(frame.PriceInput.MoneyInputFrame.SilverBox)
	S:HandleEditBox(frame.PriceInput.MoneyInputFrame.CopperBox)

	if frame.SecondaryPriceInput then
		S:HandleEditBox(frame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
		S:HandleEditBox(frame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
		S:HandleEditBox(frame.SecondaryPriceInput.MoneyInputFrame.CopperBox)
	end

	S:HandleDropDownBox(frame.Duration.Dropdown)
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
	if E.Modern then
		ItemButton.IconMask:Hide()
	end

	ItemButton.EmptyBackground:Hide()
	ItemButton:SetPushedTexture(E.ClearTexture)
	ItemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	ItemButton.Highlight:SetAllPoints(ItemButton.Icon)

	S:HandleIcon(ItemButton.Icon, true)
	S:HandleIconBorder(ItemButton.IconBorder, ItemButton.Icon.backdrop)

	S:HandleButton(frame.PostButton)
	HandleAuctionButtons(frame.DummyRefreshButton)

	frame.DummyItemList:StripTextures()
	frame.DummyItemList:SetTemplate('Transparent')
	S:HandleTrimScrollBar(frame.DummyItemList.DummyScrollBar)
end

local function HandleSellList(frame, hasHeader, fitScrollBar)
	frame:StripTextures()

	if frame.RefreshFrame then
		HandleAuctionButtons(frame.RefreshFrame.RefreshButton)
	end

	S:HandleTrimScrollBar(frame.ScrollBar)

	if fitScrollBar then
		frame.ScrollBar:ClearAllPoints()
		frame.ScrollBar:Point('TOPRIGHT', frame, -6, -16)
		frame.ScrollBar:Point('BOTTOMRIGHT', frame, -6, 16)
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
			tab:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', E.Modern and -3 or -10, -32)
		else -- skinned ones can be closer together
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', (tab.backdrop or tab.Backdrop) and (E.Modern and -5 or -19) or 0, 0)
		end

		lastTab = tab
	end
end

local function FilterButtonSetup(button)
	local r, g, b = unpack(E.media.rgbvaluecolor)
	button.NormalTexture:SetAlpha(0)
	button.SelectedTexture:SetColorTexture(r, g, b, .25)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .1)
end

local function SkinAuctionHouseFrame()
	--[[ Main Frame | TAB 1]]--
	local Frame = _G.AuctionHouseFrame
	S:HandlePortraitFrame(Frame)
	Frame:Width(810) -- to make space for the Browse ScrollBar (Default: 800)

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
	Categories.NineSlice:SetTemplate('Transparent')
	Categories.NineSlice:SetInside(Categories)
	S:HandleTrimScrollBar(Categories.ScrollBar)

	hooksecurefunc('AuctionHouseFilterButton_SetUp', FilterButtonSetup)

	--[[ Browse Frame ]]--
	local Browse = Frame.BrowseResultsFrame

	local BrowseList = Browse.ItemList
	BrowseList:StripTextures()
	hooksecurefunc(BrowseList, 'RefreshScrollFrame', HandleHeaders)
	S:HandleTrimScrollBar(BrowseList.ScrollBar)
	BrowseList:SetTemplate('Transparent')
	BrowseList.ScrollBar:ClearAllPoints()
	BrowseList.ScrollBar:Point('TOPRIGHT', BrowseList, -6, -16)
	BrowseList.ScrollBar:Point('BOTTOMRIGHT', BrowseList, -6, 16)

	--[[ BuyOut Frame]]
	local CommoditiesBuyFrame = Frame.CommoditiesBuyFrame
	CommoditiesBuyFrame.BuyDisplay:StripTextures()
	S:HandleButton(CommoditiesBuyFrame.BackButton)

	local CommoditiesBuyList = CommoditiesBuyFrame.ItemList
	CommoditiesBuyList:StripTextures()
	CommoditiesBuyList:SetTemplate('Transparent')
	S:HandleButton(CommoditiesBuyList.RefreshFrame.RefreshButton)
	S:HandleTrimScrollBar(CommoditiesBuyList.ScrollBar)

	local BuyDisplay = CommoditiesBuyFrame.BuyDisplay
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

	S:HandleButton(ItemBuyFrame.BidFrame.BidButton)
	ItemBuyFrame.BidFrame.BidButton:ClearAllPoints()
	ItemBuyFrame.BidFrame.BidButton:Point('LEFT', ItemBuyFrame.BidFrame.BidAmount, 'RIGHT', 2, -2)
	HandleBidAmount(ItemBuyFrame.BidFrame.BidAmount)

	--[[ Item Sell Frame | TAB 2 ]]--
	local SellFrame = Frame.ItemSellFrame
	HandleSellFrame(SellFrame)
	SellFrame:SetTemplate('Transparent')

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

	HandleSellList(AuctionsFrame.CommoditiesList, true)
	HandleSellList(AuctionsFrame.ItemList, true)
	S:HandleTab(AuctionsFrame.AuctionsTab)
	S:HandleTab(AuctionsFrame.BidsTab)

	local SummaryList = AuctionsFrame.SummaryList
	HandleSellList(SummaryList)
	SummaryList:SetTemplate('Transparent')
	S:HandleButton(AuctionsFrame.CancelAuctionButton)

	SummaryList.ScrollBar:ClearAllPoints()
	SummaryList.ScrollBar:Point('TOPRIGHT', SummaryList, -5, -20)
	SummaryList.ScrollBar:Point('BOTTOMRIGHT', SummaryList, -5, 20)

	local AllAuctionsList = AuctionsFrame.AllAuctionsList
	HandleSellList(AllAuctionsList, true, true)

	SummaryList:Point('BOTTOM', AuctionsFrame, 0, 0) -- normally this is anchored to the cancel button.. ? lol
	AuctionsFrame.CancelAuctionButton:ClearAllPoints()
	AuctionsFrame.CancelAuctionButton:Point('TOPRIGHT', AllAuctionsList, 'BOTTOMRIGHT', -6, 1)

	HandleSellList(AuctionsFrame.BidsList, true, true)
	S:HandleButton(AuctionsFrame.BidFrame.BidButton)
	HandleBidAmount(AuctionsFrame.BidFrame.BidAmount)

	if E.Forever then -- Forever shows the copper box, which sticks out of BidAmount
		for _, bidFrame in next, { ItemBuyFrame.BidFrame, AuctionsFrame.BidFrame } do
			local BidAmount = bidFrame.BidAmount
			BidAmount.gold:ClearAllPoints()
			BidAmount.gold:Point('LEFT')

			bidFrame.BidButton:ClearAllPoints()
			bidFrame.BidButton:Point('LEFT', BidAmount.copper, 'RIGHT', 2, 0)
		end
	end

	--[[ WoW Token Category ]]--
	local TokenFrame = Frame.WoWTokenResults
	TokenFrame:StripTextures()
	S:HandleButton(TokenFrame.Buyout)
	S:HandleTrimScrollBar(TokenFrame.DummyScrollBar)

	local Token = TokenFrame.TokenDisplay
	Token:StripTextures()
	Token:SetTemplate('Transparent')

	local ItemButton = Token.ItemButton
	S:HandleIcon(ItemButton.Icon, true)
	ItemButton.Icon.backdrop:SetBackdropBorderColor(0, .8, 1)
	ItemButton:GetHighlightTexture():Hide()

	if E.Modern then
		ItemButton.CircleMask:Hide()
	end

	ItemButton.IconBorder:SetAlpha(0)

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
	progressBar.IconBackdrop:OffsetFrameLevel(nil, progressBar)
	progressBar.IconBackdrop:SetOutside(progressBar.Icon)
	progressBar.IconBackdrop:SetTemplate()
end

local function AuctionsItemButton_OnEvent(button, event)
	local normal = event == 'NEW_AUCTION_UPDATE' and button:GetNormalTexture()
	if normal then
		normal:SetTexCoords()
		normal:SetInside()

		local _, _, _, quality = GetAuctionSellItemInfo()
		local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
		button:SetBackdropBorderColor(r, g, b)
	else
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function SkinAuctionFrame()
	local AuctionFrame = _G.AuctionFrame
	AuctionFrame:StripTextures(true)
	S:HandleFrame(AuctionFrame, true, nil, 10)

	for _, button in next, {
		_G.BrowseSearchButton,
		_G.BrowseBidButton,
		_G.BrowseBuyoutButton,
		_G.BrowseCloseButton,
		_G.BrowseResetButton,
		_G.BidBidButton,
		_G.BidBuyoutButton,
		_G.BidCloseButton,
		_G.AuctionsCreateAuctionButton,
		_G.AuctionsCancelAuctionButton,
		_G.AuctionsStackSizeMaxButton,
		_G.AuctionsNumStacksMaxButton,
		_G.AuctionsCloseButton
	} do
		S:HandleButton(button, true)
	end

	for i, checkBox in next, {
		_G.SortByBidPriceButton,
		_G.SortByBuyoutPriceButton,
		_G.SortByTotalPriceButton,
		_G.SortByUnitPriceButton,
		_G.IsUsableCheckButton,
		_G.ShowOnPlayerCheckButton
	} do
		S:HandleCheckBox(checkBox)

		if i <= 4 then
			checkBox:Size(24)
			checkBox:PointXY(nil, (i == 1 and -40) or (i == 3 and -5) or 3)
		else
			checkBox.Text:Point('LEFT', checkBox, 'Right', 2, 0)
		end
	end

	for _, editBox in next, {
		_G.BrowseName,
		_G.BrowseMinLevel,
		_G.BrowseMaxLevel,
		_G.BrowseBidPriceGold,
		_G.BrowseBidPriceSilver,
		_G.BrowseBidPriceCopper,
		_G.BidBidPriceGold,
		_G.BidBidPriceSilver,
		_G.BidBidPriceCopper,
		_G.AuctionsStackSizeEntry,
		_G.AuctionsNumStacksEntry,
		_G.StartPriceGold,
		_G.StartPriceSilver,
		_G.StartPriceCopper,
		_G.BuyoutPriceGold,
		_G.BuyoutPriceCopper,
		_G.BuyoutPriceSilver
	} do
		S:HandleEditBox(editBox)
		editBox:SetTextInsets(1, 1, -1, 1)
	end

	for i = 1, AuctionFrame.numTabs do
		local tab = _G['AuctionFrameTab'..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point('BOTTOMLEFT', AuctionFrame, 'BOTTOMLEFT', 0, -32)
			tab.SetPoint = E.noop
		end
	end

	-- Reposition Tabs
	_G.AuctionFrameTab2:Point('TOPLEFT', _G.AuctionFrameTab1, 'TOPRIGHT', -19, 0)
	_G.AuctionFrameTab3:Point('TOPLEFT', _G.AuctionFrameTab2, 'TOPRIGHT', -19, 0)

	for _, tab in next, {
		_G.BrowseQualitySort,
		_G.BrowseLevelSort,
		_G.BrowseDurationSort,
		_G.BrowseHighBidderSort,
		_G.BrowseCurrentBidSort,
		_G.BidQualitySort,
		_G.BidLevelSort,
		_G.BidDurationSort,
		_G.BidBuyoutSort,
		_G.BidStatusSort,
		_G.BidBidSort,
		_G.AuctionsQualitySort,
		_G.AuctionsDurationSort,
		_G.AuctionsHighBidderSort,
		_G.AuctionsBidSort,
	} do
		tab:StripTextures()
		tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
		tab:StyleButton()
	end

	local AuctionFrameBrowse = _G.AuctionFrameBrowse
	for _, filter in next, AuctionFrameBrowse.FilterButtons do
		filter:StripTextures()
		filter:StyleButton()

		local name = filter:GetName()
		local lines = _G[name..'Lines']
		lines:SetAlpha(0)
		lines.SetAlpha = E.noop

		local normal = filter:GetNormalTexture()
		normal:SetAlpha(0)
		normal.SetAlpha = E.noop
	end

	local BrowsePriceOptionsFrame = _G.BrowsePriceOptionsFrame
	BrowsePriceOptionsFrame:StripTextures()
	BrowsePriceOptionsFrame:SetTemplate('Transparent')

	local _, _, _, _, browseDoneButton = BrowsePriceOptionsFrame:GetChildren() -- SortByBidPrice, SortByBuyoutPrice, SortByTotalPrice, SortByUnitPrice, Done
	S:HandleButton(browseDoneButton)

	local BrowsePriceOptionsButtonFrame = _G.BrowsePriceOptionsButtonFrame
	BrowsePriceOptionsButtonFrame:ClearAllPoints()
	BrowsePriceOptionsButtonFrame:Point('TOPRIGHT', _G.BrowseCurrentBidSort, 'TOPRIGHT', 6, 10)
	S:HandleButton(BrowsePriceOptionsButtonFrame.Button, nil, nil, true)
	BrowsePriceOptionsButtonFrame.Button.Icon:Size(24)

	_G.BrowseLevelHyphen:Point('RIGHT', 13, 0)

	_G.AuctionFrameMoneyFrame:Point('BOTTOMRIGHT', AuctionFrame, 'BOTTOMLEFT', 181, 11)

	-- Browse Frame
	_G.BrowseTitle:ClearAllPoints()
	_G.BrowseTitle:Point('TOP', AuctionFrame, 'TOP', 0, -5)

	_G.BrowseScrollFrame:StripTextures()

	_G.BrowseFilterScrollFrame:StripTextures()

	_G.BrowseCloseButton:Point('BOTTOMRIGHT', 66, 6)
	_G.BrowseBuyoutButton:Point('RIGHT', _G.BrowseCloseButton, 'LEFT', -4, 0)

	_G.BrowseBidPrice:Point('BOTTOM', -102, 10)

	S:HandleScrollBar(_G.BrowseFilterScrollFrameScrollBar)
	S:HandleScrollBar(_G.BrowseScrollFrameScrollBar)
	S:HandleNextPrevButton(_G.BrowsePrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(_G.BrowseNextPageButton, nil, nil, true)

	-- Bid Frame
	_G.BidTitle:ClearAllPoints()
	_G.BidTitle:Point('TOP', AuctionFrame, 'TOP', 0, -5)

	local BidScrollFrame = _G.BidScrollFrame
	BidScrollFrame:StripTextures()

	_G.BidBidText:ClearAllPoints()
	_G.BidBidText:Point('RIGHT', _G.BidBidButton, 'LEFT', -270, 2)

	_G.BidCloseButton:Point('BOTTOMRIGHT', 66, 6)
	_G.BidBuyoutButton:Point('RIGHT', _G.BidCloseButton, 'LEFT', -4, 0)
	_G.BidBidButton:Point('RIGHT', _G.BidBuyoutButton, 'LEFT', -4, 0)

	_G.BidBidPrice:Point('BOTTOM', 25, 10)

	local BidScrollFrameScrollBar = _G.BidScrollFrameScrollBar
	S:HandleScrollBar(BidScrollFrameScrollBar)
	BidScrollFrameScrollBar:ClearAllPoints()
	BidScrollFrameScrollBar:Point('TOPRIGHT', BidScrollFrame, 'TOPRIGHT', 23, -18)
	BidScrollFrameScrollBar:Point('BOTTOMRIGHT', BidScrollFrame, 'BOTTOMRIGHT', 0, 16)

	-- Auctions Frame
	_G.AuctionsTitle:ClearAllPoints()
	_G.AuctionsTitle:Point('TOP', AuctionFrame, 'TOP', 0, -5)

	local AuctionsScrollFrame = _G.AuctionsScrollFrame
	AuctionsScrollFrame:StripTextures()

	local AuctionsScrollFrameScrollBar = _G.AuctionsScrollFrameScrollBar
	S:HandleScrollBar(AuctionsScrollFrameScrollBar)
	AuctionsScrollFrameScrollBar:ClearAllPoints()
	AuctionsScrollFrameScrollBar:Point('TOPRIGHT', AuctionsScrollFrame, 'TOPRIGHT', 23, -20)
	AuctionsScrollFrameScrollBar:Point('BOTTOMRIGHT', AuctionsScrollFrame, 'BOTTOMRIGHT', 0, 18)

	_G.AuctionsCloseButton:Point('BOTTOMRIGHT', 66, 6)
	_G.AuctionsCancelAuctionButton:Point('RIGHT', _G.AuctionsCloseButton, 'LEFT', -4, 0)

	_G.AuctionsStackSizeEntry.backdrop:SetAllPoints()
	_G.AuctionsNumStacksEntry.backdrop:SetAllPoints()

	local AuctionsItemButton = _G.AuctionsItemButton
	AuctionsItemButton:StripTextures()
	AuctionsItemButton:SetTemplate(nil, true)
	AuctionsItemButton:StyleButton()
	AuctionsItemButton:HookScript('OnEvent', AuctionsItemButton_OnEvent)

	S:HandleRadioButton(_G.AuctionsShortAuctionButton)
	S:HandleRadioButton(_G.AuctionsMediumAuctionButton)
	S:HandleRadioButton(_G.AuctionsLongAuctionButton)

	S:HandleDropDownBox(_G.BrowseDropdown, 155)

	-- Progress Frame
	_G.AuctionProgressFrame:StripTextures()
	_G.AuctionProgressFrame:SetTemplate('Transparent')

	local AuctionProgressFrameCancelButton = _G.AuctionProgressFrameCancelButton
	S:HandleButton(AuctionProgressFrameCancelButton)
	AuctionProgressFrameCancelButton:Size(28)
	AuctionProgressFrameCancelButton:Point('LEFT', _G.AuctionProgressBar, 'RIGHT', 8, 0)
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)

	local cancelNormal = AuctionProgressFrameCancelButton:GetNormalTexture()
	cancelNormal:SetTexture(E.Media.Textures.Close)
	cancelNormal:SetInside()

	for frame, numButtons in next, { Browse = _G.NUM_BROWSE_TO_DISPLAY, Auctions = _G.NUM_AUCTIONS_TO_DISPLAY, Bid = _G.NUM_BIDS_TO_DISPLAY } do
		for i = 1, numButtons do
			local button = _G[frame..'Button'..i]
			local itemButton = _G[frame..'Button'..i..'Item']
			local texture = _G[frame..'Button'..i..'ItemIconTexture']

			itemButton:SetTemplate()
			itemButton:StyleButton()
			itemButton.IconBorder:SetAlpha(0)

			button:StripTextures()
			button:SetHighlightTexture(E.media.blankTex)

			local normal = itemButton:GetNormalTexture()
			normal:SetTexture()

			local highlight = button:GetHighlightTexture()
			highlight:SetVertexColor(1, 1, 1, .2)
			highlight:Point('TOPLEFT', itemButton, 'TOPRIGHT', 2, 0)
			highlight:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 5)

			S:HandleIcon(texture)
			texture:SetInside()
		end
	end

	-- Custom Backdrops
	local AuctionFrameAuctions = _G.AuctionFrameAuctions
	for _, frame in next, { AuctionFrameBrowse, AuctionFrameAuctions } do
		frame.LeftBackground = CreateFrame('Frame', nil, frame)
		frame.LeftBackground:SetTemplate('Transparent')
		frame.LeftBackground:OffsetFrameLevel(-1, frame)

		frame.RightBackground = CreateFrame('Frame', nil, frame)
		frame.RightBackground:SetTemplate('Transparent')
		frame.RightBackground:OffsetFrameLevel(-1, frame)
	end

	AuctionFrameAuctions.LeftBackground:Point('TOPLEFT', 15, -72)
	AuctionFrameAuctions.LeftBackground:Point('BOTTOMRIGHT', -545, 34)

	AuctionFrameAuctions.RightBackground:Point('TOPLEFT', AuctionFrameAuctions.LeftBackground, 'TOPRIGHT', 3, 0)
	AuctionFrameAuctions.RightBackground:Point('BOTTOMRIGHT', AuctionFrame, -8, 34)

	AuctionFrameBrowse.LeftBackground:Point('TOPLEFT', 20, -103)
	AuctionFrameBrowse.LeftBackground:Point('BOTTOMRIGHT', -575, 34)

	AuctionFrameBrowse.RightBackground:Point('TOPLEFT', AuctionFrameBrowse.LeftBackground, 'TOPRIGHT', 4, 0)
	AuctionFrameBrowse.RightBackground:Point('BOTTOMRIGHT', AuctionFrame, 'BOTTOMRIGHT', -8, 34)

	local AuctionFrameBid = _G.AuctionFrameBid
	AuctionFrameBid.Background = CreateFrame('Frame', nil, AuctionFrameBid)
	S:HandleFrame(AuctionFrameBid.Background, true, nil, 22, -72, 66, 34)
	AuctionFrameBid.Background:OffsetFrameLevel(-1, AuctionFrameBid)
end

function S:Blizzard_AuctionHouseUI()
	if E.Modern or E.Mists then
		SkinAuctionHouseFrame()
	else
		SkinAuctionFrame()
	end
end
