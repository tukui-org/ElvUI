local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: NUM_BIDS_TO_DISPLAY, NUM_BROWSE_TO_DISPLAY, NUM_AUCTIONS_TO_DISPLAY, NUM_FILTERS_TO_DISPLAY

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	local AuctionFrame = _G["AuctionFrame"]
	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop("Transparent")
	AuctionFrame.backdrop:SetPoint('TOPLEFT', 0, -10)
	AuctionFrame.backdrop:SetPoint('BOTTOMRIGHT', 0, 10)

	local Buttons = {
		BrowseSearchButton,
		BrowseResetButton,
		BrowseBidButton,
		BrowseBuyoutButton,
		BrowseCloseButton,
		BidBidButton,
		BidBuyoutButton,
		BidCloseButton,
		AuctionsCreateAuctionButton,
		AuctionsCancelAuctionButton,
		AuctionsCloseButton,
		AuctionsStackSizeMaxButton,
		AuctionsNumStacksMaxButton,
	}

	local CheckBoxes = {
		ExactMatchCheckButton,
		IsUsableCheckButton,
		ShowOnPlayerCheckButton,
	}

	local EditBoxes = {
		BrowseName,
		BrowseMinLevel,
		BrowseMaxLevel,
		BrowseBidPriceGold,
		BrowseBidPriceSilver,
		BrowseBidPriceCopper,
		BidBidPriceGold,
		BidBidPriceSilver,
		BidBidPriceCopper,
		AuctionsStackSizeEntry,
		AuctionsNumStacksEntry,
		StartPriceGold,
		StartPriceSilver,
		StartPriceCopper,
		BuyoutPriceGold,
		BuyoutPriceSilver,
		BuyoutPriceCopper,
	}

	local SortTabs = {
		BrowseQualitySort,
		BrowseLevelSort,
		BrowseDurationSort,
		BrowseHighBidderSort,
		BrowseCurrentBidSort,
		BidQualitySort,
		BidLevelSort,
		BidDurationSort,
		BidBuyoutSort,
		BidStatusSort,
		BidBidSort,
		AuctionsQualitySort,
		AuctionsDurationSort,
		AuctionsHighBidderSort,
		AuctionsBidSort,
	}

	for _, Button in pairs(Buttons) do
		S:HandleButton(Button, true)
	end

	for _, CheckBox in pairs(CheckBoxes) do
		S:HandleCheckBox(CheckBox)
	end

	for _, EditBox in pairs(EditBoxes) do
		S:HandleEditBox(EditBox)
		EditBox:SetTextInsets(1, 1, -1, 1)
	end

	for i = 1, AuctionFrame.numTabs do
		S:HandleTab(_G["AuctionFrameTab"..i])
	end

	for _, Tab in pairs(SortTabs) do
		Tab:StripTextures()
		Tab:SetNormalTexture([[Interface\Buttons\UI-SortArrow]])
	end

	for _, Filter in pairs(AuctionFrameBrowse.FilterButtons) do
		Filter:StripTextures()
		Filter:StyleButton()

		Filter = Filter:GetName()
		_G[Filter..'Lines']:SetAlpha(0)
		_G[Filter..'Lines'].SetAlpha = E.noop
		_G[Filter..'NormalTexture']:SetAlpha(0)
		_G[Filter..'NormalTexture'].SetAlpha = E.noop
	end

	S:HandleCloseButton(AuctionFrameCloseButton)
	S:HandleScrollBar(AuctionsScrollFrameScrollBar)

	BrowseFilterScrollFrame:StripTextures()
	BrowseScrollFrame:StripTextures()
	AuctionsScrollFrame:StripTextures()
	BidScrollFrame:StripTextures()

	S:HandleDropDownBox(BrowseDropDown)
	S:HandleDropDownBox(PriceDropDown)
	S:HandleDropDownBox(DurationDropDown)
	S:HandleScrollBar(BrowseFilterScrollFrameScrollBar)
	S:HandleScrollBar(BrowseScrollFrameScrollBar)

	SideDressUpFrame:StripTextures(true)
	SideDressUpFrame:SetTemplate("Transparent")
	SideDressUpFrame:Point("TOPLEFT", AuctionFrame, "TOPRIGHT", 2, 0)
	S:HandleButton(SideDressUpModelResetButton)
	S:HandleCloseButton(SideDressUpModelCloseButton)

	S:HandleNextPrevButton(BrowseNextPageButton)
	S:HandleNextPrevButton(BrowsePrevPageButton)
	BrowseNextPageButton:Size(20, 20)
	BrowseNextPageButton:ClearAllPoints()
	BrowseNextPageButton:Point("TOPRIGHT", BrowseResetButton, "BOTTOMRIGHT", 0, -3)
	BrowsePrevPageButton:Size(20, 20)
	BrowsePrevPageButton:ClearAllPoints()
	BrowsePrevPageButton:Point("TOPLEFT", BrowseSearchButton, "BOTTOMLEFT", 0, -3)

	--Fix Button Positions
	BrowsePrevPageButton:SetSize(20, 20)
	BrowsePrevPageButton:SetPoint('TOPLEFT', "$parent", "TOPLEFT", 660, -60)
	BrowseNextPageButton:SetSize(20, 20)
	BrowseNextPageButton:SetPoint('TOPRIGHT', "$parent", "TOPRIGHT", 67, -60)
	BrowseBuyoutButton:SetPoint("RIGHT", BrowseCloseButton, "LEFT", -1, 0)
	BrowseBidButton:SetPoint("RIGHT", BrowseBuyoutButton, "LEFT", -1, 0)
	BidBuyoutButton:SetPoint("RIGHT", BidCloseButton, "LEFT", -1, 0)
	BidBidButton:SetPoint("RIGHT", BidBuyoutButton, "LEFT", -1, 0)
	BrowseMaxLevel:SetPoint("LEFT", BrowseMinLevel, "RIGHT", 8, 0)
	BrowseLevelHyphen:SetPoint('LEFT', BrowseMinLevel, 'RIGHT', 2, 1)
	AuctionsCloseButton:SetPoint("BOTTOMRIGHT", AuctionFrameAuctions, "BOTTOMRIGHT", 66, 12)
	AuctionsCancelAuctionButton:SetPoint("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)

	AuctionsItemButton:StripTextures()
	AuctionsItemButton:StyleButton()
	AuctionsItemButton:SetTemplate("Default", true)
	AuctionsItemButton.IconBorder:SetAlpha(0)

	hooksecurefunc(AuctionsItemButton.IconBorder, 'SetVertexColor', function(self, r, g, b)
		self:GetParent():SetBackdropBorderColor(r, g, b)
	end)

	hooksecurefunc(AuctionsItemButton.IconBorder, 'Hide', function(self)
		self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	hooksecurefunc(AuctionsItemButton, "SetNormalTexture", function(self, texture)
		if self:GetNormalTexture() then
			self:GetNormalTexture():SetInside()
			S:HandleTexture(self:GetNormalTexture())
		end
	end)

	_G["BrowseName"]:SetTextInsets(15, 15, -1, 1)
	AuctionsStackSizeEntry.backdrop:SetAllPoints()
	AuctionsNumStacksEntry.backdrop:SetAllPoints()

	--Progress Frame
	AuctionProgressFrame:StripTextures()
	AuctionProgressFrame:SetTemplate("Transparent")
	AuctionProgressFrameCancelButton:StyleButton()
	AuctionProgressFrameCancelButton:SetTemplate("Default")
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	AuctionProgressFrameCancelButton:GetNormalTexture():SetInside()
	AuctionProgressFrameCancelButton:GetNormalTexture():SetTexCoord(0.67, 0.37, 0.61, 0.26)
	AuctionProgressFrameCancelButton:Size(28, 28)
	AuctionProgressFrameCancelButton:Point("LEFT", AuctionProgressBar, "RIGHT", 8, 0)

	local backdrop = CreateFrame("Frame", nil, AuctionProgressBar.Icon:GetParent())
	AuctionProgressBar.Icon:SetTexCoord(unpack(E.TexCoords))
	backdrop:SetOutside(AuctionProgressBar.Icon)
	backdrop:SetTemplate("Default")
	AuctionProgressBar.Icon:SetParent(backdrop)

	AuctionProgressBar.Text:ClearAllPoints()
	AuctionProgressBar.Text:Point("CENTER")

	AuctionProgressBar:StripTextures()
	AuctionProgressBar:CreateBackdrop("Default")
	AuctionProgressBar:SetStatusBarTexture(E.media.normTex)
	AuctionProgressBar:SetStatusBarColor(1, 1, 0)
	E:RegisterStatusBar(AuctionProgressBar)

	for Frame, NumButtons in pairs({ ['Browse'] = NUM_BROWSE_TO_DISPLAY, ['Auctions'] = NUM_AUCTIONS_TO_DISPLAY, ['Bid'] = NUM_BIDS_TO_DISPLAY }) do
		for i = 1, NumButtons do
			local Button = _G[Frame..'Button'..i]
			local ItemButton = _G[Frame..'Button'..i..'Item']
			local Texture = _G[Frame..'Button'..i..'ItemIconTexture']

			ItemButton:SetTemplate()
			ItemButton:StyleButton()
			ItemButton.IconBorder:SetAlpha(0)

			Button:StripTextures()
			Button:SetHighlightTexture(E.media.blankTex)
			Button:GetHighlightTexture():SetVertexColor(1, 1, 1, .2)

			ItemButton:GetNormalTexture():SetTexture('')
			Button:GetHighlightTexture():SetPoint("TOPLEFT", ItemButton, "TOPRIGHT", 2, 0)
			Button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -2, 5)

			S:HandleTexture(Texture)
			Texture:SetInside()

			hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(self, r, g, b) ItemButton:SetBackdropBorderColor(r, g, b) end)
			hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
		end
	end

	--Custom Backdrops
	for _, Frame in pairs({ AuctionFrameBrowse, AuctionFrameAuctions }) do
		Frame.LeftBackground = CreateFrame("Frame", nil, Frame)
		Frame.LeftBackground:SetTemplate('Transparent')
		Frame.LeftBackground:SetFrameLevel(Frame:GetFrameLevel())

		Frame.RightBackground = CreateFrame("Frame", nil, Frame)
		Frame.RightBackground:SetTemplate('Transparent')
		Frame.RightBackground:SetFrameLevel(Frame:GetFrameLevel())
	end

	AuctionFrameAuctions.LeftBackground:SetPoint("TOPLEFT", 15, -70)
	AuctionFrameAuctions.LeftBackground:SetPoint("BOTTOMRIGHT", -545, 35)

	AuctionFrameAuctions.RightBackground:SetPoint("TOPLEFT", AuctionFrameAuctions.LeftBackground, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.RightBackground:SetPoint("BOTTOMRIGHT", AuctionFrame, -8, 35)

	AuctionFrameBrowse.LeftBackground:SetPoint("TOPLEFT", 20, -103)
	AuctionFrameBrowse.LeftBackground:SetPoint("BOTTOMRIGHT", -575, 40)

	AuctionFrameBrowse.RightBackground:SetPoint("TOPLEFT", AuctionFrameBrowse.LeftBackground, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.RightBackground:SetPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)

	AuctionFrameBid.Background = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.Background:SetTemplate('Transparent')
	AuctionFrameBid.Background:SetPoint("TOPLEFT", 22, -72)
	AuctionFrameBid.Background:SetPoint("BOTTOMRIGHT", 66, 39)
	BidScrollFrame:SetHeight(332)

	--WoW Token Category
	S:HandleButton(BrowseWowTokenResults.Buyout)
	BrowseWowTokenResultsToken:CreateBackdrop("Default")
	S:HandleTexture(BrowseWowTokenResultsTokenIconTexture)
	BrowseWowTokenResultsToken.backdrop:SetOutside(BrowseWowTokenResultsTokenIconTexture)
	BrowseWowTokenResultsToken.backdrop:SetBackdropBorderColor(BrowseWowTokenResultsToken.IconBorder:GetVertexColor())
	BrowseWowTokenResultsToken.backdrop:SetFrameLevel(BrowseWowTokenResultsToken:GetFrameLevel())
	BrowseWowTokenResultsToken.IconBorder:SetTexture(nil)
	BrowseWowTokenResultsToken.ItemBorder:SetTexture(nil)

	--WoW Token Tutorial Frame
	WowTokenGameTimeTutorial:CreateBackdrop("Transparent")
	S:HandleCloseButton(WowTokenGameTimeTutorial.CloseButton)
	S:HandleButton(StoreButton)
	WowTokenGameTimeTutorial.Inset.Bg:SetAlpha(0)
end

S:AddCallbackForAddon("Blizzard_AuctionUI", "AuctionHouse", LoadSkin)
