local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--WoW API / Variables
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local C_BlackMarket_GetNumItems = C_BlackMarket.GetNumItems
local C_BlackMarket_GetItemInfoByIndex = C_BlackMarket.GetItemInfoByIndex

local function SkinTab(tab)
	tab.Left:SetAlpha(0)
	if tab.Middle then
		tab.Middle:SetAlpha(0)
	end
	tab.Right:SetAlpha(0)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bmah ~= true then return end

	BlackMarketFrame:StripTextures()
	BlackMarketFrame:CreateBackdrop('Transparent')
	BlackMarketFrame.backdrop:SetAllPoints()

	BlackMarketFrame.Inset:StripTextures()
	BlackMarketFrame.Inset:CreateBackdrop()
	BlackMarketFrame.Inset.backdrop:SetAllPoints()

	S:HandleCloseButton(BlackMarketFrame.CloseButton)
	S:HandleScrollBar(BlackMarketScrollFrameScrollBar, 4)
	SkinTab(BlackMarketFrame.ColumnName)
	SkinTab(BlackMarketFrame.ColumnLevel)
	SkinTab(BlackMarketFrame.ColumnType)
	SkinTab(BlackMarketFrame.ColumnDuration)
	SkinTab(BlackMarketFrame.ColumnHighBidder)
	SkinTab(BlackMarketFrame.ColumnCurrentBid)

	BlackMarketFrame.MoneyFrameBorder:StripTextures()
	S:HandleEditBox(BlackMarketBidPriceGold)
	BlackMarketBidPriceGold.backdrop:Point("TOPLEFT", -2, 0)
	BlackMarketBidPriceGold.backdrop:Point("BOTTOMRIGHT", -2, 0)

	S:HandleButton(BlackMarketFrame.BidButton)

	hooksecurefunc('BlackMarketScrollFrame_Update', function()
		local buttons = BlackMarketScrollFrame.buttons;
		local numButtons = #buttons;
		local offset = HybridScrollFrame_GetOffset(BlackMarketScrollFrame);
		local numItems = C_BlackMarket_GetNumItems();

		for i = 1, numButtons do
			local button = buttons[i];
			local index = offset + i; -- adjust index

			if not button.skinned then
				S:HandleItemButton(button.Item)
				button:StripTextures('BACKGROUND')
				button:StyleButton()
				button.skinned = true
			end

			if ( index <= numItems ) then
				local name, texture = C_BlackMarket_GetItemInfoByIndex(index);
				if ( name ) then
					button.Item.IconTexture:SetTexture(texture);
				end
			end
		end
	end)

	BlackMarketFrame.HotDeal:StripTextures()
	S:HandleItemButton(BlackMarketFrame.HotDeal.Item)
	BlackMarketFrame.HotDeal.Item.hover:SetAllPoints()
	BlackMarketFrame.HotDeal.Item.pushed:SetAllPoints()

	--S:HandleButton(BlackMarketFrame.HotDeal.BidButton)
	--S:HandleEditBox(BlackMarketHotItemBidPriceGold)

	for i=1, BlackMarketFrame:GetNumRegions() do
		local region = select(i, BlackMarketFrame:GetRegions())
		if region and region:IsObjectType("FontString") and region:GetText() == BLACK_MARKET_TITLE then
			region:ClearAllPoints()
			region:Point('TOP', BlackMarketFrame, 'TOP', 0, -4)
		end
	end
end

S:RegisterSkin("Blizzard_BlackMarketUI", LoadSkin)