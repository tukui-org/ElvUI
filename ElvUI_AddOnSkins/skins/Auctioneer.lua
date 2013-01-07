local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = 'AuctioneerSkin'
local function AuctioneerSkin(self,event)
	if event == "PLAYER_ENTERING_WORLD" then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end
	if not auctioneerskinned then
	AuctionsCancelAuctionButton:Point("RIGHT", AuctionFrameMoneyFrame, "RIGHT", 554, 0)
	AuctionsCloseButton:ClearAllPoints()
	AuctionsCloseButton:Point("RIGHT", AuctionsCancelAuctionButton, "RIGHT", 86, 0)
	BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -4, 0)
	BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -4, 0)
	AuctionsItemButton:StripTextures()
	AuctionsItemButton:StyleButton()
	AuctionsItemButton:SetTemplate("Transparent", true)
	BrowseName:Point("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 22, -56)
	BrowseMinLevel:ClearAllPoints()
	BrowseMinLevel:Point("RIGHT", BrowseName, "RIGHT", 42, 0)
	BrowseMaxLevel:ClearAllPoints()
	BrowseMaxLevel:Point("RIGHT", BrowseMinLevel, "RIGHT", 36, 0)
	BrowseDropDown:ClearAllPoints()
	BrowseDropDown:Point("RIGHT", BrowseMaxLevel, "RIGHT", 150, -3)
	BrowseResetButton:ClearAllPoints()
	BrowseResetButton:Point("LEFT", BrowseName, "LEFT", -2, -26)
	BrowseSearchButton:ClearAllPoints()
	BrowseSearchButton:Point("RIGHT", BrowseResetButton, "RIGHT", 83, 0)

	BrowseNameText:Point("TOPLEFT", 20, -41)
	BrowseLevelText:Point("TOPLEFT", 184, -45)
	BrowseLevelHyphen:Point("LEFT", BrowseMinLevel, "RIGHT", 4, 0)

	AuctionFrameMoneyFrame:ClearAllPoints()
	AuctionFrameMoneyFrame:Point("TOPLEFT", AuctionFrame, "BOTTOMLEFT", 55, 24)	
	BrowseBidPrice:ClearAllPoints()
	BrowseBidPrice:Point("RIGHT", AuctionFrameMoneyFrame, "RIGHT", 340, 0)
	BrowseCloseButton:ClearAllPoints()
	BrowseCloseButton:Point("RIGHT", AuctionFrameMoneyFrame, "RIGHT", 640, 0)
	BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)
	BidBidPrice:ClearAllPoints()
	BidBidPrice:Point("RIGHT", AuctionFrameMoneyFrame, "RIGHT", 340, 0)
	BidCloseButton:ClearAllPoints()
	BidCloseButton:Point("RIGHT", AuctionFrameMoneyFrame, "RIGHT", 640, 0)
	BidBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	BidBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)
	AuctionsQualitySort:Point("TOPLEFT", AuctionFrameAuctions, "TOPLEFT", 219, -48)
	BidQualitySort:Point("TOPLEFT", AuctionFrameBid, "TOPLEFT", 65, -50)
	AuctionFrameTab1:ClearAllPoints()
	AuctionFrameTab1:Point("TOPLEFT", AuctionFrame, "BOTTOMLEFT", -5, 2)
	BrowseNextPageButton:Size(20, 20)
	BrowsePrevPageButton:Size(20, 20)
	if IsAddOnLoaded("Auc-Stat-Purchased") then
		BrowseNextPageButton:Point("BOTTOMRIGHT", BrowseScrollFrame, "BOTTOMRIGHT", 0, 0)
	end

	if IsAddOnLoaded("Auc-Stat-Purchased") then
		BrowsePrevPageButton:Point("BOTTOMRIGHT", BrowseScrollFrame, "BOTTOMRIGHT", -160, 0)
	end

	if AucAdvScanButton then S:HandleButton(AucAdvScanButton) end
	if AucAdvSimpFrameCreate then S:HandleButton(AucAdvSimpFrameCreate) end
	if AucAdvSimpFrameRemember then S:HandleButton(AucAdvSimpFrameRemember) end
	if AuctionFrameTabUtilAppraiser then S:HandleTab(AuctionFrameTabUtilAppraiser) end
	if AuctionFrameTabUtilSearchUi then S:HandleTab(AuctionFrameTabUtilSearchUi) end
	if AuctionFrameTabUtilSimple then S:HandleTab(AuctionFrameTabUtilSimple) end
	if AuctionFrameTabUtilBeanCounter then S:HandleTab(AuctionFrameTabUtilBeanCounter) end
		auctioneerskinned = true
	end
	--AS:UnregisterEvent(name,self,"AUCTION_HOUSE_SHOW")
end

AS:RegisterSkin(name,AuctioneerSkin,'AUCTION_HOUSE_SHOW')
