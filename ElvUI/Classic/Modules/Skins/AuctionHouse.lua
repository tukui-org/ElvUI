local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local pairs = pairs
local unpack = unpack

local GetAuctionSellItemInfo = GetAuctionSellItemInfo
local CreateFrame = CreateFrame

local GetItemQualityColor = GetItemQualityColor or (C_Item and C_Item.GetItemQualityColor)

function S:Blizzard_AuctionUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.auctionhouse) then return end

	local AuctionFrame = _G.AuctionFrame
	AuctionFrame:StripTextures(true)
	S:HandleFrame(AuctionFrame, true, nil, 10)

	local Buttons = {
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
	}

	local CheckBoxes = {
		_G.SortByBidPriceButton,
		_G.SortByBuyoutPriceButton,
		_G.SortByTotalPriceButton,
		_G.SortByUnitPriceButton,
		_G.IsUsableCheckButton,
		_G.ShowOnPlayerCheckButton
	}

	local EditBoxes = {
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
	}

	local SortTabs = {
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
	}

	for _, Button in pairs(Buttons) do
		S:HandleButton(Button, true)
	end

	for i, CheckBox in pairs(CheckBoxes) do
		S:HandleCheckBox(CheckBox)

		if i <= 4 then
			CheckBox:Size(24)

			S:HandlePointXY(CheckBox, nil, (i == 1 and -40) or (i == 3 and -5) or 3)
		elseif CheckBox.Text then
			CheckBox.Text:Point('LEFT', CheckBox, 'Right', 2, 0)
		end
	end

	for _, EditBox in pairs(EditBoxes) do
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

	for _, Tab in pairs(SortTabs) do
		Tab:StripTextures()
		Tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
		Tab:StyleButton()
	end

	for _, Filter in pairs(_G.AuctionFrameBrowse.FilterButtons) do
		Filter:StripTextures()
		Filter:StyleButton()

		Filter = Filter:GetName()
		_G[Filter..'Lines']:SetAlpha(0)
		_G[Filter..'Lines'].SetAlpha = E.noop
		_G[Filter..'NormalTexture']:SetAlpha(0)
		_G[Filter..'NormalTexture'].SetAlpha = E.noop
	end

	_G.BrowsePriceOptionsFrame:StripTextures()
	_G.BrowsePriceOptionsFrame:SetTemplate('Transparent')

	for _, child in next, { _G.BrowsePriceOptionsFrame:GetChildren() } do
		if child:IsObjectType('Button') then
			S:HandleButton(child)
		end
	end

	_G.BrowsePriceOptionsButtonFrame:ClearAllPoints()
	_G.BrowsePriceOptionsButtonFrame:Point('TOPRIGHT', _G.BrowseCurrentBidSort, 'TOPRIGHT', 6, 10)
	S:HandleButton(_G.BrowsePriceOptionsButtonFrame.Button, nil, nil, true)
	_G.BrowsePriceOptionsButtonFrame.Button.Icon:Size(24)

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
	_G.BidTitle:Point('TOP', _G.AuctionFrame, 'TOP', 0, -5)

	_G.BidScrollFrame:StripTextures()

	_G.BidBidText:ClearAllPoints()
	_G.BidBidText:Point('RIGHT', _G.BidBidButton, 'LEFT', -270, 2)

	_G.BidCloseButton:Point('BOTTOMRIGHT', 66, 6)
	_G.BidBuyoutButton:Point('RIGHT', _G.BidCloseButton, 'LEFT', -4, 0)
	_G.BidBidButton:Point('RIGHT', _G.BidBuyoutButton, 'LEFT', -4, 0)

	_G.BidBidPrice:Point('BOTTOM', 25, 10)

	S:HandleScrollBar(_G.BidScrollFrameScrollBar)
	_G.BidScrollFrameScrollBar:ClearAllPoints()
	_G.BidScrollFrameScrollBar:Point('TOPRIGHT', _G.BidScrollFrame, 'TOPRIGHT', 23, -18)
	_G.BidScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.BidScrollFrame, 'BOTTOMRIGHT', 0, 16)

	-- Auctions Frame
	_G.AuctionsTitle:ClearAllPoints()
	_G.AuctionsTitle:Point('TOP', AuctionFrame, 'TOP', 0, -5)

	_G.AuctionsScrollFrame:StripTextures()

	S:HandleScrollBar(_G.AuctionsScrollFrameScrollBar)
	_G.AuctionsScrollFrameScrollBar:ClearAllPoints()
	_G.AuctionsScrollFrameScrollBar:Point('TOPRIGHT', _G.AuctionsScrollFrame, 'TOPRIGHT', 23, -20)
	_G.AuctionsScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.AuctionsScrollFrame, 'BOTTOMRIGHT', 0, 18)

	_G.AuctionsCloseButton:Point('BOTTOMRIGHT', 66, 6)
	_G.AuctionsCancelAuctionButton:Point('RIGHT', _G.AuctionsCloseButton, 'LEFT', -4, 0)

	_G.AuctionsStackSizeEntry.backdrop:SetAllPoints()
	_G.AuctionsNumStacksEntry.backdrop:SetAllPoints()

	_G.AuctionsItemButton:StripTextures()
	_G.AuctionsItemButton:SetTemplate(nil, true)
	_G.AuctionsItemButton:StyleButton()

	_G.AuctionsItemButton:HookScript('OnEvent', function(button, event)
		local normal = event == 'NEW_AUCTION_UPDATE' and button:GetNormalTexture()
		if normal then
			normal:SetTexCoord(unpack(E.TexCoords))
			normal:SetInside()

			local _, _, _, quality = GetAuctionSellItemInfo()
			if quality and quality > 1 then
				local r, g, b = GetItemQualityColor(quality)
				button:SetBackdropBorderColor(r, g, b)
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	S:HandleRadioButton(_G.AuctionsShortAuctionButton)
	S:HandleRadioButton(_G.AuctionsMediumAuctionButton)
	S:HandleRadioButton(_G.AuctionsLongAuctionButton)

	S:HandleDropDownBox(_G.BrowseDropDown, 155)
	S:HandleDropDownBox(_G.PriceDropDown)

	-- Progress Frame
	_G.AuctionProgressFrame:StripTextures()
	_G.AuctionProgressFrame:SetTemplate('Transparent')

	local AuctionProgressFrameCancelButton = _G.AuctionProgressFrameCancelButton
	S:HandleButton(AuctionProgressFrameCancelButton)
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetTexture(E.Media.Textures.Close)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetInside()
	AuctionProgressFrameCancelButton:Size(28)
	AuctionProgressFrameCancelButton:Point('LEFT', _G.AuctionProgressBar, 'RIGHT', 8, 0)

	for Frame, NumButtons in pairs({
		Browse = _G.NUM_BROWSE_TO_DISPLAY,
		Auctions = _G.NUM_AUCTIONS_TO_DISPLAY,
		Bid = _G.NUM_BIDS_TO_DISPLAY
	}) do
		for i = 1, NumButtons do
			local Button = _G[Frame..'Button'..i]
			local ItemButton = _G[Frame..'Button'..i..'Item']
			local Texture = _G[Frame..'Button'..i..'ItemIconTexture']
			local Name = _G[Frame..'Button'..i..'Name']

			ItemButton:SetTemplate()
			ItemButton:StyleButton()
			ItemButton.IconBorder:SetAlpha(0)

			Button:StripTextures()
			Button:SetHighlightTexture(E.media.blankTex)
			ItemButton:GetNormalTexture():SetTexture()

			local highlight = Button:GetHighlightTexture()
			highlight:SetVertexColor(1, 1, 1, .2)
			highlight:Point('TOPLEFT', ItemButton, 'TOPRIGHT', 2, 0)
			highlight:Point('BOTTOMRIGHT', Button, 'BOTTOMRIGHT', -2, 5)

			S:HandleIcon(Texture)
			Texture:SetInside()
		end
	end

	-- Custom Backdrops
	for _, Frame in pairs({_G.AuctionFrameBrowse, _G.AuctionFrameAuctions}) do
		Frame.LeftBackground = CreateFrame('Frame', nil, Frame)
		Frame.LeftBackground:SetTemplate('Transparent')
		Frame.LeftBackground:SetFrameLevel(Frame:GetFrameLevel() - 1)

		Frame.RightBackground = CreateFrame('Frame', nil, Frame)
		Frame.RightBackground:SetTemplate('Transparent')
		Frame.RightBackground:SetFrameLevel(Frame:GetFrameLevel() - 1)
	end

	local AuctionFrameAuctions = _G.AuctionFrameAuctions
	AuctionFrameAuctions.LeftBackground:Point('TOPLEFT', 15, -72)
	AuctionFrameAuctions.LeftBackground:Point('BOTTOMRIGHT', -545, 34)

	AuctionFrameAuctions.RightBackground:Point('TOPLEFT', AuctionFrameAuctions.LeftBackground, 'TOPRIGHT', 3, 0)
	AuctionFrameAuctions.RightBackground:Point('BOTTOMRIGHT', AuctionFrame, -8, 34)

	local AuctionFrameBrowse = _G.AuctionFrameBrowse
	AuctionFrameBrowse.LeftBackground:Point('TOPLEFT', 20, -103)
	AuctionFrameBrowse.LeftBackground:Point('BOTTOMRIGHT', -575, 34)

	AuctionFrameBrowse.RightBackground:Point('TOPLEFT', AuctionFrameBrowse.LeftBackground, 'TOPRIGHT', 4, 0)
	AuctionFrameBrowse.RightBackground:Point('BOTTOMRIGHT', AuctionFrame, 'BOTTOMRIGHT', -8, 34)

	local AuctionFrameBid = _G.AuctionFrameBid
	AuctionFrameBid.Background = CreateFrame('Frame', nil, AuctionFrameBid)
	S:HandleFrame(AuctionFrameBid.Background, true, nil, 22, -72, 66, 34)
	AuctionFrameBid.Background:SetFrameLevel(AuctionFrameBid:GetFrameLevel() - 1)
end

S:AddCallbackForAddon('Blizzard_AuctionUI')
