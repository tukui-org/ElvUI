
local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "AuctionatorSkin"
function AtrSkin(self,event)
	if event == "PLAYER_ENTERING_WORLD" then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end
	if not auctionatorskinned then
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
	BrowseResetButton:Width(80)
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

	AS:SkinFrame(Atr_BasicOptionsFrame)
	AS:SkinFrame(Atr_TooltipsOptionsFrame)
	AS:SkinFrame(Atr_UCConfigFrame)
	AS:SkinFrame(Atr_StackingOptionsFrame)
	AS:SkinFrame(Atr_ScanningOptionsFrame)
	AS:SkinFrame(AuctionatorResetsFrame)
	AS:SkinFrame(Atr_ShpList_Options_Frame)
	AS:SkinFrame(AuctionatorDescriptionFrame)
	AS:SkinFrame(Atr_Stacking_List)
	AS:SkinFrame(Atr_ShpList_Frame)
		
	S:HandleCheckBox(AuctionatorOption_Enable_Alt_CB)
	S:HandleCheckBox(AuctionatorOption_Open_All_Bags_CB)
	S:HandleCheckBox(AuctionatorOption_Show_StartingPrice_CB)
	S:HandleCheckBox(ATR_tipsVendorOpt_CB)
	S:HandleCheckBox(ATR_tipsAuctionOpt_CB)
	S:HandleCheckBox(ATR_tipsDisenchantOpt_CB)
		
	S:HandleDropDownBox(AuctionatorOption_Deftab)
	S:HandleDropDownBox(Atr_tipsShiftDD)
	S:HandleDropDownBox(Atr_deDetailsDD)
	S:HandleDropDownBox(Atr_scanLevelDD)
	Atr_deDetailsDDText:SetJustifyH('RIGHT')

	local moneyEditBoxes = {
		'UC_5000000_MoneyInput',
		'UC_1000000_MoneyInput',
		'UC_200000_MoneyInput',
		'UC_50000_MoneyInput',
		'UC_10000_MoneyInput',
		'UC_2000_MoneyInput',
		'UC_500_MoneyInput',
	}

	for i = 1, #moneyEditBoxes do
		S:HandleEditBox(_G[moneyEditBoxes[i]..'Gold'])
		S:HandleEditBox(_G[moneyEditBoxes[i]..'Silver'])
		S:HandleEditBox(_G[moneyEditBoxes[i]..'Copper'])
	end

	S:HandleEditBox(Atr_Starting_Discount)
	S:HandleEditBox(Atr_ScanOpts_MaxHistAge)
		
	S:HandleButton(Atr_UCConfigFrame_Reset)
	S:HandleButton(Atr_StackingOptionsFrame_Edit)
	S:HandleButton(Atr_StackingOptionsFrame_New)

	for i = 1, Atr_ShpList_Options_Frame:GetNumChildren() do
		local object = select(i, Atr_ShpList_Options_Frame:GetChildren())
		if object:GetObjectType() == 'Button' then
			S:HandleButton(object)
		end
	end
		
	for i = 1, AuctionatorResetsFrame:GetNumChildren() do
		local object = select(i, AuctionatorResetsFrame:GetChildren())
		if object:GetObjectType() == 'Button' then
			S:HandleButton(object)
		end
	end

	S:HandleDropDownBox(Atr_Duration)
	S:HandleDropDownBox(Atr_DropDownSL)
	S:HandleDropDownBox(Atr_ASDD_Class)
	S:HandleDropDownBox(Atr_ASDD_Subclass)

	S:HandleButton(Atr_Search_Button, true)
	S:HandleButton(Atr_Back_Button, true)
	S:HandleButton(Atr_Buy1_Button, true)
	S:HandleButton(Atr_Adv_Search_Button, true)
	S:HandleButton(Atr_FullScanButton, true)
	S:HandleButton(Auctionator1Button, true)
	AS:SkinFrame(Atr_ListTabsTab1)
	AS:SkinFrame(Atr_ListTabsTab2)
	AS:SkinFrame(Atr_ListTabsTab3)
	S:HandleButton(Atr_CreateAuctionButton, true)
	S:HandleButton(Atr_RemFromSListButton, true)
	S:HandleButton(Atr_AddToSListButton, true)
	S:HandleButton(Atr_SrchSListButton, true)
	S:HandleButton(Atr_MngSListsButton, true)
	S:HandleButton(Atr_NewSListButton, true)
	S:HandleButton(Atr_CheckActiveButton, true)
	S:HandleButton(AuctionatorCloseButton, true)
	S:HandleButton(Atr_CancelSelectionButton, true)
	S:HandleButton(Atr_FullScanStartButton, true)
	S:HandleButton(Atr_FullScanDone, true)
	S:HandleButton(Atr_CheckActives_Yes_Button, true)
	S:HandleButton(Atr_CheckActives_No_Button, true)
	S:HandleButton(Atr_Adv_Search_ResetBut, true)
	S:HandleButton(Atr_Adv_Search_OKBut, true)
	S:HandleButton(Atr_Adv_Search_CancelBut, true)
	S:HandleButton(Atr_Buy_Confirm_OKBut, true)
	S:HandleButton(Atr_Buy_Confirm_CancelBut, true)
	S:HandleButton(Atr_SaveThisList_Button, true)
	S:HandleEditBox(Atr_StackPriceGold)
	S:HandleEditBox(Atr_StackPriceSilver)
	S:HandleEditBox(Atr_StackPriceCopper)
	S:HandleEditBox(Atr_StartingPriceGold)
	S:HandleEditBox(Atr_StartingPriceSilver)
	S:HandleEditBox(Atr_StartingPriceCopper)
	S:HandleEditBox(Atr_ItemPriceGold)
	S:HandleEditBox(Atr_ItemPriceSilver)
	S:HandleEditBox(Atr_ItemPriceCopper)
	S:HandleEditBox(Atr_Batch_NumAuctions)
	S:HandleEditBox(Atr_Batch_Stacksize)
	S:HandleEditBox(Atr_Search_Box)
	S:HandleEditBox(Atr_AS_Searchtext)
	S:HandleEditBox(Atr_AS_Minlevel)
	S:HandleEditBox(Atr_AS_Maxlevel)
	S:HandleEditBox(Atr_AS_MinItemlevel)
	S:HandleEditBox(Atr_AS_MaxItemlevel)
	AS:SkinFrame(Atr_FullScanResults)
	AS:SkinFrame(Atr_Adv_Search_Dialog)
	AS:SkinFrame(Atr_FullScanFrame)
	AS:SkinFrameD(Atr_HeadingsBar)
	Atr_HeadingsBar:Height(19)
	AS:SkinFrame(Atr_Error_Frame)
	AS:SkinFrameD(Atr_Hlist)
	Atr_Hlist:Width(196)
	Atr_Hlist:ClearAllPoints()
	Atr_Hlist:Point("TOPLEFT", -195, -75)
	AS:SkinFrameD(Atr_Buy_Confirm_Frame)
	AS:SkinFrameD(Atr_CheckActives_Frame)
	Atr_SrchSListButton:Width(196)
	Atr_MngSListsButton:Width(196)
	Atr_NewSListButton:Width(196)
	Atr_CheckActiveButton:Width(196)
	S:HandleScrollBar(Atr_Hlist_ScrollFrameScrollBar)
	Atr_ListTabs:Point("BOTTOMRIGHT", Atr_HeadingsBar, "TOPRIGHT", 8, 1)
	Atr_Back_Button:Point("TOPLEFT", Atr_HeadingsBar, "TOPLEFT", 0, 19)

	AuctionatorCloseButton:ClearAllPoints()
	AuctionatorCloseButton:Point("BOTTOMLEFT", Atr_Main_Panel, "BOTTOMRIGHT", -17, 10)
	Atr_Buy1_Button:Point("RIGHT", AuctionatorCloseButton, "LEFT", -5, 0)
	Atr_CancelSelectionButton:Point("RIGHT", Atr_Buy1_Button, "LEFT", -5, 0)
	Atr_SellControls_Tex:StripTextures()
	Atr_SellControls_Tex:StyleButton()
	Atr_SellControls_Tex:SetTemplate("Default", true)

	for i = 1, AuctionFrame.numTabs do
		S:HandleTab(_G["AuctionFrameTab"..i])
	end
	AuctionFrameTab1:Point("TOPLEFT", AuctionFrame, "BOTTOMLEFT", 5, 2)

		auctionatorskinned = true
	end

	--AS:UnregisterEvent(name,self,"AUCTION_HOUSE_SHOW")
end

AS:RegisterSkin(name,AtrSkin,'AUCTION_HOUSE_SHOW')