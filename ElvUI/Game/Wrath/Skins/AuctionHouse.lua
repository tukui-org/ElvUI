local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack

local CreateFrame = CreateFrame
local GetAuctionSellItemInfo = GetAuctionSellItemInfo

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

function S:Blizzard_AuctionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.auctionhouse) then return end

	local AuctionFrame = _G.AuctionFrame
	AuctionFrame:StripTextures(true)
	S:HandleFrame(AuctionFrame, true, nil, 10)

	for _, Button in next, {
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
		S:HandleButton(Button, true)
	end

	for i, CheckBox in next, {
		_G.SortByBidPriceButton,
		_G.SortByBuyoutPriceButton,
		_G.SortByTotalPriceButton,
		_G.SortByUnitPriceButton,
		_G.IsUsableCheckButton,
		_G.ShowOnPlayerCheckButton
	} do
		S:HandleCheckBox(CheckBox)

		if i <= 4 then
			CheckBox:Size(24)
			CheckBox:PointXY(nil, (i == 1 and -40) or (i == 3 and -5) or 3)
		else
			CheckBox.Text:Point('LEFT', CheckBox, 'Right', 2, 0)
		end
	end

	for _, EditBox in next, {
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
		S:HandleEditBox(EditBox)
		EditBox:SetTextInsets(1, 1, -1, 1)
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

	for _, Tab in next, {
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
		Tab:StripTextures()
		Tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
		Tab:StyleButton()
	end

	local AuctionFrameBrowse = _G.AuctionFrameBrowse
	for _, Filter in next, AuctionFrameBrowse.FilterButtons do
		Filter:StripTextures()
		Filter:StyleButton()

		local name = Filter:GetName()
		local lines = _G[name..'Lines']
		lines:SetAlpha(0)
		lines.SetAlpha = E.noop

		local normal = Filter:GetNormalTexture()
		normal:SetAlpha(0)
		normal.SetAlpha = E.noop
	end

	local BrowsePriceOptionsFrame = _G.BrowsePriceOptionsFrame
	BrowsePriceOptionsFrame:StripTextures()
	BrowsePriceOptionsFrame:SetTemplate('Transparent')

	local _, _, _, _, doneButton = BrowsePriceOptionsFrame:GetChildren() -- SortByBidPrice, SortByBuyoutPrice, SortByTotalPrice, SortByUnitPrice, Done
	S:HandleButton(doneButton)

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
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	local cancelNormal = AuctionProgressFrameCancelButton:GetNormalTexture()
	cancelNormal:SetTexture(E.Media.Textures.Close)
	cancelNormal:SetInside()
	AuctionProgressFrameCancelButton:Size(28)
	AuctionProgressFrameCancelButton:Point('LEFT', _G.AuctionProgressBar, 'RIGHT', 8, 0)

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
	for _, Frame in next, { AuctionFrameBrowse, AuctionFrameAuctions } do
		Frame.LeftBackground = CreateFrame('Frame', nil, Frame)
		Frame.LeftBackground:SetTemplate('Transparent')
		Frame.LeftBackground:OffsetFrameLevel(-1, Frame)

		Frame.RightBackground = CreateFrame('Frame', nil, Frame)
		Frame.RightBackground:SetTemplate('Transparent')
		Frame.RightBackground:OffsetFrameLevel(-1, Frame)
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

S:AddCallbackForAddon('Blizzard_AuctionUI')
