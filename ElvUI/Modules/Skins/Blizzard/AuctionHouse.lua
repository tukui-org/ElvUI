local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	--[[ Main Frame | TAB 1]]--
	local Frame = _G.AuctionHouseFrame
	S:HandlePortraitFrame(Frame)

	local Tabs = {
		_G.AuctionHouseFrameBuyTab,
		_G.AuctionHouseFrameSellTab,
		_G.AuctionHouseFrameAuctionsTab,
	}

	for _, tab in pairs(Tabs) do
		if tab then
			S:HandleTab(tab)
		end
	end

	S:HandleButton(Frame.SearchBar.FavoritesSearchButton)
	Frame.SearchBar.FavoritesSearchButton:SetSize(22, 22)
	S:HandleEditBox(Frame.SearchBar.SearchBox)
	S:HandleButton(Frame.SearchBar.FilterButton)
	S:HandleCloseButton(Frame.SearchBar.FilterButton.ClearFiltersButton)
	S:HandleButton(Frame.SearchBar.SearchButton)

	Frame.MoneyFrameBorder:StripTextures(true)

	--[[ Categorie List ]]--
	local Categories = Frame.CategoriesList
	Categories.ScrollFrame:StripTextures()
	Categories.Background:Hide()
	Categories.NineSlice:Hide()

	S:HandleScrollBar(_G.AuctionHouseFrameScrollBar)

	for i = 1, _G.NUM_FILTERS_TO_DISPLAY do
		local button = Categories.FilterButtons[i]

		button:StripTextures(true)
		button:StyleButton()

		button.SelectedTexture:SetAlpha(0)
	end

	--[[ Browse Frame ]]--
	local Browse = Frame.BrowseResultsFrame

	local ItemList = Browse.ItemList
	ItemList:StripTextures()

	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)

	--[[ BuyOut Frame]]
	local CommoditiesBuyFrame = Frame.CommoditiesBuyFrame
	CommoditiesBuyFrame.BuyDisplay:StripTextures()
	S:HandleButton(CommoditiesBuyFrame.BackButton)

	local ItemList = Frame.CommoditiesBuyFrame.ItemList
	ItemList:StripTextures()
	ItemList:CreateBackdrop("Transparent")
	S:HandleButton(ItemList.RefreshFrame.RefreshButton)
	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)

	local BuyDisplay = Frame.CommoditiesBuyFrame.BuyDisplay
	S:HandleEditBox(BuyDisplay.QuantityInput.InputBox)
	S:HandleButton(_G.BuyButton)

	local ItemDisplay = BuyDisplay.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop("Transparent")

	local ItemButton = ItemDisplay.ItemButton
	S:HandleIcon(ItemButton.Icon, true)
	-- FIX ME
	--hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b) ItemButton.Icon:SetBackdropBorderColor(r, g, b) end)
	--hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton.Icon:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	ItemButton.CircleMask:SetAlpha(0)
	ItemButton.IconBorder:SetAlpha(0)
	ItemButton.IconOverlay:SetAlpha(0)

	--[[ ItemBuyOut Frame]]
	local ItemBuyFrame = Frame.ItemBuyFrame
	S:HandleButton(ItemBuyFrame.BackButton)
	S:HandleButton(ItemBuyFrame.BuyoutFrame.BuyoutButton)

	local ItemDisplay = ItemBuyFrame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop("Transparent")

	local ItemButton = ItemDisplay.ItemButton
	S:HandleIcon(ItemButton.Icon, true)
	-- FIX ME
	--hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b) ItemButton.Icon:SetBackdropBorderColor(r, g, b) end)
	--hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton.Icon:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	ItemButton.CircleMask:SetAlpha(0)
	ItemButton.IconBorder:SetAlpha(0)
	ItemButton.IconOverlay:SetAlpha(0)

	local ItemList = ItemBuyFrame.ItemList
	ItemList:StripTextures()
	ItemList:CreateBackdrop("Transparent")
	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)
	S:HandleButton(ItemList.RefreshFrame.RefreshButton)

	local EditBoxes = {
		_G.AuctionHouseFrameGold,
		_G.AuctionHouseFrameSilver,
	}

	for _, EditBox in pairs(EditBoxes) do
		S:HandleEditBox(EditBox)
		EditBox:SetTextInsets(1, 1, -1, 1)
	end

	S:HandleButton(ItemBuyFrame.BidFrame.BidButton)

	--[[ Item Sell Frame | TAB 2 ]]--
	local SellFrame = Frame.ItemSellFrame
	SellFrame:StripTextures()
	SellFrame.ItemDisplay:StripTextures()
	SellFrame.ItemDisplay:CreateBackdrop("Transparent")
	S:HandleEditBox(SellFrame.QuantityInput.InputBox)
	S:HandleButton(SellFrame.QuantityInput.MaxButton)
	S:HandleEditBox(SellFrame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
	S:HandleEditBox(SellFrame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
	S:HandleEditBox(SellFrame.PriceInput.MoneyInputFrame.GoldBox)
	S:HandleEditBox(SellFrame.PriceInput.MoneyInputFrame.SilverBox)
	S:HandleDropDownBox(SellFrame.DurationDropDown.DropDown)
	S:HandleButton(SellFrame.PostButton)
	S:HandleCheckBox(SellFrame.BuyoutModeCheckButton)
	SellFrame.BuyoutModeCheckButton:SetSize(20, 20)

	local ItemButton = SellFrame.ItemDisplay.ItemButton
	ItemButton.EmptyBackground:Hide()
	S:HandleIcon(ItemButton.Icon, true)
	hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b) ItemButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
	hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	ItemButton.IconBorder:SetAlpha(0)
	ItemButton.IconMask:SetAlpha(0)

	local ItemList = Frame.ItemSellList
	ItemList:StripTextures()
	ItemList:CreateBackdrop("Transparent")
	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)
	S:HandleButton(ItemList.RefreshFrame.RefreshButton)

	local CommoditiesSellFrame = Frame.CommoditiesSellFrame
	CommoditiesSellFrame:StripTextures()
	CommoditiesSellFrame.ItemDisplay:StripTextures()
	CommoditiesSellFrame.ItemDisplay:CreateBackdrop("Transparent")
	S:HandleEditBox(CommoditiesSellFrame.QuantityInput.InputBox)
	S:HandleButton(CommoditiesSellFrame.QuantityInput.MaxButton)
	S:HandleEditBox(CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox)
	S:HandleEditBox(CommoditiesSellFrame.PriceInput.MoneyInputFrame.SilverBox)
	S:HandleDropDownBox(CommoditiesSellFrame.DurationDropDown.DropDown)
	S:HandleButton(CommoditiesSellFrame.PostButton)

	local ItemButton = CommoditiesSellFrame.ItemDisplay.ItemButton
	ItemButton.EmptyBackground:Hide()
	S:HandleIcon(ItemButton.Icon, true)
	hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b) ItemButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
	hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	ItemButton.IconBorder:SetAlpha(0)
	ItemButton.IconMask:SetAlpha(0)

	local ItemList = Frame.CommoditiesSellList
	ItemList:StripTextures()
	ItemList:CreateBackdrop("Transparent")
	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)
	S:HandleButton(ItemList.RefreshFrame.RefreshButton)

	--[[ Auctions Frame | TAB 3 ]]--
	local AuctionsFrame = _G.AuctionHouseFrameAuctionsFrame
	AuctionsFrame:StripTextures()

	local Tabs = {
		_G.AuctionHouseFrameAuctionsFrameAuctionsTab,
		_G.AuctionHouseFrameAuctionsFrameBidsTab,
	}

	for _, tab in pairs(Tabs) do
		if tab then
			S:HandleTab(tab)
		end
	end

	local SummaryList = AuctionsFrame.SummaryList
	SummaryList:StripTextures()
	SummaryList:CreateBackdrop("Transparent")
	S:HandleButton(AuctionsFrame.CancelAuctionButton)
	S:HandleScrollBar(SummaryList.ScrollFrame.scrollBar)

	local AllAuctionsList = AuctionsFrame.AllAuctionsList
	AllAuctionsList:StripTextures()
	AllAuctionsList:CreateBackdrop("Transparent")
	S:HandleScrollBar(AllAuctionsList.ScrollFrame.scrollBar)
	S:HandleButton(AllAuctionsList.RefreshFrame.RefreshButton)

	local BidsList = AuctionsFrame.BidsList
	BidsList:StripTextures()
	BidsList:CreateBackdrop("Transparent")
	S:HandleScrollBar(BidsList.ScrollFrame.scrollBar)
	S:HandleButton(BidsList.RefreshFrame.RefreshButton)
	S:HandleEditBox(_G.AuctionHouseFrameAuctionsFrameGold)
	S:HandleEditBox(_G.AuctionHouseFrameAuctionsFrameSilver)
	S:HandleButton(AuctionsFrame.BidFrame.BidButton)
	S:HandleButton(AuctionsFrame.BuyoutFrame.BuyoutButton)

	--[[ WoW Token Category ]]--
	local TokenFrame = Frame.WoWTokenResults
	TokenFrame:StripTextures()
	S:HandleButton(TokenFrame.Buyout)
	S:HandleScrollBar(TokenFrame.DummyScrollBar) --MONITOR THIS

	local Token = TokenFrame.Token
	S:HandleIcon(Token.Icon, true)
	Token.Icon.backdrop:SetBackdropBorderColor(Token.IconBorder:GetVertexColor())
	Token.IconBorder:SetAlpha(0)
	Token.ItemBorder:SetAlpha(0)
	Token.ItemBorder:CreateBackdrop("Transparent")

	--WoW Token Tutorial Frame
	local WowTokenGameTimeTutorial = Frame.WoWTokenResults.GameTimeTutorial
	WowTokenGameTimeTutorial.TitleBg:SetAlpha(0)
	WowTokenGameTimeTutorial:CreateBackdrop("Transparent")
	S:HandleCloseButton(WowTokenGameTimeTutorial.CloseButton)
	S:HandleButton(WowTokenGameTimeTutorial.RightDisplay.StoreButton)
	WowTokenGameTimeTutorial.Bg:SetAlpha(0)

	--[[ Dialogs ]]--
	Frame.BuyDialog:StripTextures()
	Frame.BuyDialog:CreateBackdrop("Transparent")
	S:HandleButton(Frame.BuyDialog.BuyNowButton)
	S:HandleButton(Frame.BuyDialog.CancelButton)
end

S:AddCallbackForAddon("Blizzard_AuctionHouseUI", "AuctionHouse", LoadSkin)
