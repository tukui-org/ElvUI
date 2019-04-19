local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	local AuctionFrame = _G.AuctionFrame
	AuctionFrame:StripTextures(true)
	AuctionFrame:CreateBackdrop("Transparent")
	AuctionFrame.backdrop:Point('TOPLEFT', 0, -10)
	AuctionFrame.backdrop:Point('BOTTOMRIGHT', 0, 10)

	local Buttons = {
		_G.BrowseSearchButton,
		_G.BrowseResetButton,
		_G.BrowseBidButton,
		_G.BrowseBuyoutButton,
		_G.BrowseCloseButton,
		_G.BidBidButton,
		_G.BidBuyoutButton,
		_G.BidCloseButton,
		_G.AuctionsCreateAuctionButton,
		_G.AuctionsCancelAuctionButton,
		_G.AuctionsCloseButton,
		_G.AuctionsStackSizeMaxButton,
		_G.AuctionsNumStacksMaxButton,
	}

	local CheckBoxes = {
		_G.ExactMatchCheckButton,
		_G.IsUsableCheckButton,
		_G.ShowOnPlayerCheckButton,
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
		_G.BuyoutPriceSilver,
		_G.BuyoutPriceCopper,
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

	for _, Filter in pairs(_G.AuctionFrameBrowse.FilterButtons) do
		Filter:StripTextures()
		Filter:StyleButton()

		Filter = Filter:GetName()
		_G[Filter..'Lines']:SetAlpha(0)
		_G[Filter..'Lines'].SetAlpha = E.noop
		_G[Filter..'NormalTexture']:SetAlpha(0)
		_G[Filter..'NormalTexture'].SetAlpha = E.noop
	end

	_G.BrowseFilterScrollFrame:StripTextures()
	_G.BrowseScrollFrame:StripTextures()
	_G.AuctionsScrollFrame:StripTextures()
	_G.BidScrollFrame:StripTextures()

	S:HandleCloseButton(_G.AuctionFrameCloseButton)
	S:HandleScrollBar(_G.AuctionsScrollFrameScrollBar)

	S:HandleDropDownBox(_G.BrowseDropDown, 155)
	S:HandleDropDownBox(_G.PriceDropDown)
	S:HandleDropDownBox(_G.DurationDropDown)
	S:HandleScrollBar(_G.BrowseFilterScrollFrameScrollBar)
	S:HandleScrollBar(_G.BrowseScrollFrameScrollBar)

	_G.BrowseDropDown:Point('TOPLEFT', _G.BrowseMaxLevel, 'TOPRIGHT', -6, 7)
	_G.BrowseDropDown.Text:Point("RIGHT", _G.BrowseDropDownRight, "RIGHT", -43, -2)
	_G.BrowseDropDownName:Point('BOTTOMLEFT', _G.BrowseDropDown, 'TOPLEFT', 20, -2)
	_G.BrowseLevelHyphen:Point('LEFT', _G.BrowseMinLevel, 'RIGHT', 2, 1)

	S:HandleNextPrevButton(_G.BrowseNextPageButton)
	S:HandleNextPrevButton(_G.BrowsePrevPageButton)
	_G.BrowseNextPageButton:Size(20, 20)
	_G.BrowseNextPageButton:ClearAllPoints()
	_G.BrowseNextPageButton:Point("TOPRIGHT", _G.BrowseResetButton, "BOTTOMRIGHT", 0, -3)
	_G.BrowsePrevPageButton:Size(20, 20)
	_G.BrowsePrevPageButton:ClearAllPoints()
	_G.BrowsePrevPageButton:Point("TOPLEFT", _G.BrowseSearchButton, "BOTTOMLEFT", 0, -3)

	--Fix Button Positions
	_G.BrowsePrevPageButton:Size(20, 20)
	_G.BrowsePrevPageButton:Point('TOPLEFT', "$parent", "TOPLEFT", 660, -60)
	_G.BrowseNextPageButton:Size(20, 20)
	_G.BrowseNextPageButton:Point('TOPRIGHT', "$parent", "TOPRIGHT", 67, -60)
	_G.BrowseBuyoutButton:Point("RIGHT", _G.BrowseCloseButton, "LEFT", -1, 0)
	_G.BrowseBidButton:Point("RIGHT", _G.BrowseBuyoutButton, "LEFT", -1, 0)
	_G.BidBuyoutButton:Point("RIGHT", _G.BidCloseButton, "LEFT", -1, 0)
	_G.BidBidButton:Point("RIGHT", _G.BidBuyoutButton, "LEFT", -1, 0)
	_G.BrowseMaxLevel:Point("LEFT", _G.BrowseMinLevel, "RIGHT", 8, 0)
	_G.BrowseLevelHyphen:Point('LEFT', _G.BrowseMinLevel, 'RIGHT', 2, 1)
	_G.AuctionsCloseButton:Point("BOTTOMRIGHT", _G.AuctionFrameAuctions, "BOTTOMRIGHT", 66, 12)
	_G.AuctionsCancelAuctionButton:Point("RIGHT", _G.AuctionsCloseButton, "LEFT", -4, 0)

	_G.AuctionsItemButton:StripTextures()
	_G.AuctionsItemButton:StyleButton()
	_G.AuctionsItemButton:SetTemplate(nil, true)
	_G.AuctionsItemButton.IconBorder:SetAlpha(0)

	hooksecurefunc(_G.AuctionsItemButton.IconBorder, 'SetVertexColor', function(self, r, g, b)
		self:GetParent():SetBackdropBorderColor(r, g, b)
	end)

	hooksecurefunc(_G.AuctionsItemButton.IconBorder, 'Hide', function(self)
		self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	hooksecurefunc(_G.AuctionsItemButton, "SetNormalTexture", function(self)
		if self:GetNormalTexture() then
			self:GetNormalTexture():SetInside()
			S:HandleIcon(self:GetNormalTexture())
		end
	end)

	_G.BrowseName:SetTextInsets(15, 15, -1, 1)
	_G.AuctionsStackSizeEntry.backdrop:SetAllPoints()
	_G.AuctionsNumStacksEntry.backdrop:SetAllPoints()

	--Progress Frame
	_G.AuctionProgressFrame:StripTextures()
	_G.AuctionProgressFrame:SetTemplate("Transparent")
	_G.AuctionProgressFrameCancelButton:StyleButton()
	_G.AuctionProgressFrameCancelButton:SetTemplate()
	_G.AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	_G.AuctionProgressFrameCancelButton:GetNormalTexture():SetInside()
	_G.AuctionProgressFrameCancelButton:GetNormalTexture():SetTexCoord(0.67, 0.37, 0.61, 0.26)
	_G.AuctionProgressFrameCancelButton:Size(28, 28)
	_G.AuctionProgressFrameCancelButton:Point("LEFT", _G.AuctionProgressBar, "RIGHT", 8, 0)

	local AuctionProgressBar = _G.AuctionProgressBar

	S:HandleIcon(AuctionProgressBar.Icon)

	AuctionProgressBar.Text:ClearAllPoints()
	AuctionProgressBar.Text:Point("CENTER")

	S:HandleStatusBar(AuctionProgressBar, {1, 1, 0})

	for Frame, NumButtons in pairs({
		['Browse'] = _G.NUM_BROWSE_TO_DISPLAY,
		['Auctions'] = _G.NUM_AUCTIONS_TO_DISPLAY,
		['Bid'] = _G.NUM_BIDS_TO_DISPLAY
	}) do
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

			ItemButton:GetNormalTexture():SetTexture()
			Button:GetHighlightTexture():Point("TOPLEFT", ItemButton, "TOPRIGHT", 2, 0)
			Button:GetHighlightTexture():Point("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -2, 5)

			S:HandleIcon(Texture)
			Texture:SetInside()

			hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b)
				ItemButton:SetBackdropBorderColor(r, g, b)
			end)
			hooksecurefunc(ItemButton.IconBorder, 'Hide', function()
				ItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)
		end
	end

	--Custom Backdrops
	for _, Frame in pairs({ _G.AuctionFrameBrowse, _G.AuctionFrameAuctions }) do
		Frame.LeftBackground = CreateFrame("Frame", nil, Frame)
		Frame.LeftBackground:SetTemplate('Transparent')
		Frame.LeftBackground:SetFrameLevel(Frame:GetFrameLevel())

		Frame.RightBackground = CreateFrame("Frame", nil, Frame)
		Frame.RightBackground:SetTemplate('Transparent')
		Frame.RightBackground:SetFrameLevel(Frame:GetFrameLevel())
	end

	local AuctionFrameAuctions = _G.AuctionFrameAuctions
	AuctionFrameAuctions.LeftBackground:Point("TOPLEFT", 15, -70)
	AuctionFrameAuctions.LeftBackground:Point("BOTTOMRIGHT", -545, 35)

	AuctionFrameAuctions.RightBackground:Point("TOPLEFT", AuctionFrameAuctions.LeftBackground, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, -8, 35)

	local AuctionFrameBrowse = _G.AuctionFrameBrowse
	AuctionFrameBrowse.LeftBackground:Point("TOPLEFT", 20, -103)
	AuctionFrameBrowse.LeftBackground:Point("BOTTOMRIGHT", -575, 40)

	AuctionFrameBrowse.RightBackground:Point("TOPLEFT", AuctionFrameBrowse.LeftBackground, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.RightBackground:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)

	local AuctionFrameBid = _G.AuctionFrameBid
	AuctionFrameBid.Background = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.Background:SetTemplate('Transparent')
	AuctionFrameBid.Background:Point("TOPLEFT", 22, -72)
	AuctionFrameBid.Background:Point("BOTTOMRIGHT", 66, 39)
	_G.BidScrollFrame:Height(332)

	--WoW Token Category
	local BrowseWowTokenResultsToken = _G.BrowseWowTokenResultsToken
	S:HandleButton(_G.BrowseWowTokenResults.Buyout)
	BrowseWowTokenResultsToken:CreateBackdrop()
	S:HandleIcon(_G.BrowseWowTokenResultsTokenIconTexture, true)
	BrowseWowTokenResultsToken.backdrop:SetBackdropBorderColor(BrowseWowTokenResultsToken.IconBorder:GetVertexColor())
	BrowseWowTokenResultsToken.IconBorder:SetTexture()
	BrowseWowTokenResultsToken.ItemBorder:SetTexture()

	--WoW Token Tutorial Frame
	local WowTokenGameTimeTutorial = _G.WowTokenGameTimeTutorial
	WowTokenGameTimeTutorial:CreateBackdrop("Transparent")
	S:HandleCloseButton(WowTokenGameTimeTutorial.CloseButton)
	S:HandleButton(_G.StoreButton)
	WowTokenGameTimeTutorial.Inset.Bg:SetAlpha(0)
end

S:AddCallbackForAddon("Blizzard_AuctionUI", "AuctionHouse", LoadSkin)
