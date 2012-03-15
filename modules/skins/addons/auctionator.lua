local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Credit Tomkuzyno

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.auctionhouse ~= true then return end
	-- Options skinning
	Atr_BasicOptionsFrame:StripTextures()
	Atr_BasicOptionsFrame:SetTemplate("Transparent")
	Atr_TooltipsOptionsFrame:StripTextures()
	Atr_TooltipsOptionsFrame:SetTemplate("Transparent")
	Atr_UCConfigFrame:StripTextures()
	Atr_UCConfigFrame:SetTemplate("Transparent")
	Atr_StackingOptionsFrame:StripTextures()
	Atr_StackingOptionsFrame:SetTemplate("Transparent")
	Atr_ScanningOptionsFrame:StripTextures()
	Atr_ScanningOptionsFrame:SetTemplate("Transparent")
	AuctionatorResetsFrame:StripTextures()
	AuctionatorResetsFrame:SetTemplate("Transparent")
	Atr_ShpList_Options_Frame:StripTextures()
	Atr_ShpList_Options_Frame:SetTemplate("Transparent")
	AuctionatorDescriptionFrame:StripTextures()
	AuctionatorDescriptionFrame:SetTemplate("Transparent")
	Atr_Stacking_List:StripTextures()
	Atr_Stacking_List:SetTemplate('Transparent')
	Atr_ShpList_Frame:StripTextures()
	Atr_ShpList_Frame:SetTemplate('Transparent')
	
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
	
	S:HandleButton(Atr_UCConfigFrame_Reset, true)
	S:HandleButton(Atr_StackingOptionsFrame_Edit, true)
	S:HandleButton(Atr_StackingOptionsFrame_New, true)
	
	for i = 1, Atr_ShpList_Options_Frame:GetNumChildren() do
		local object = select(i, Atr_ShpList_Options_Frame:GetChildren())
		if object:GetObjectType() == 'Button' then
			S:HandleButton(object, true)
		end
	end
	
	for i = 1, AuctionatorResetsFrame:GetNumChildren() do
		local object = select(i, AuctionatorResetsFrame:GetChildren())
		if object:GetObjectType() == 'Button' then
			S:HandleButton(object)
		end
	end
	-- Main window skinning
	local AtrSkin = CreateFrame('Frame')
	AtrSkin:RegisterEvent('AUCTION_HOUSE_SHOW')
	AtrSkin:SetScript('OnEvent', function(self)
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
		S:HandleButton(Atr_ListTabsTab1, true)
		S:HandleButton(Atr_ListTabsTab2, true)
		S:HandleButton(Atr_ListTabsTab3, true)
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

		Atr_FullScanResults:StripTextures()
		Atr_FullScanResults:SetTemplate("Transparent")
		Atr_Adv_Search_Dialog:StripTextures()
		Atr_Adv_Search_Dialog:SetTemplate("Transparent")
		Atr_FullScanFrame:StripTextures()
		Atr_FullScanFrame:SetTemplate("Transparent")
		Atr_HeadingsBar:StripTextures()
		Atr_HeadingsBar:SetTemplate("Default")
		Atr_HeadingsBar:Height(19)
		Atr_Error_Frame:StripTextures()
		Atr_Error_Frame:SetTemplate("Transparent")
		Atr_Hlist:StripTextures()
		Atr_Hlist:SetTemplate("Default")
		Atr_Hlist:Width(196)
		Atr_Hlist:ClearAllPoints()
		Atr_Hlist:Point("TOPLEFT", -195, -75)
		Atr_Buy_Confirm_Frame:StripTextures()
		Atr_Buy_Confirm_Frame:SetTemplate("Default")
		Atr_CheckActives_Frame:StripTextures()
		Atr_CheckActives_Frame:SetTemplate("Default")

		-- resize some buttons to fit
		Atr_SrchSListButton:Width(196)
		Atr_MngSListsButton:Width(196)
		Atr_NewSListButton:Width(196)
		Atr_CheckActiveButton:Width(196)

		-- Button Positions
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

		self:UnregisterEvent('AUCTION_HOUSE_SHOW')
	end)
end

S:RegisterSkin('Auctionator', LoadSkin)
