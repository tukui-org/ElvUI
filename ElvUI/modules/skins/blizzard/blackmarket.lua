local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')

local function SkinTab(tab)
	tab.Left:SetAlpha(0)
	if tab.Middle then
		tab.Middle:SetAlpha(0)
	end
	tab.Right:SetAlpha(0)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true --[[or E.private.skins.blizzard.reforge ~= true]] then return end

	BlackMarketFrame:StripTextures()
	BlackMarketFrame:CreateBackdrop('Transparent')
	BlackMarketFrame.backdrop:SetAllPoints()

	
	BlackMarketFrame:CreateShadow('Default')
	BlackMarketFrame.Inset:StripTextures()
	BlackMarketFrame.Inset:CreateBackdrop()
	BlackMarketFrame.Inset.backdrop:SetAllPoints()
	
	S:HandleCloseButton(BlackMarketFrame.CloseButton)
	S:HandleScrollBar(BlackMarketScrollFrameScrollBar)
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

		for i = 1, numButtons do
			local button = buttons[i];

			if button then
				S:HandleItemButton(button.Item)
				button:StripTextures('BACKGROUND')
				button:StyleButton()
			end
		end
	end)
	
	BlackMarketFrame.HotDeal:StripTextures()
	S:HandleItemButton(BlackMarketFrame.HotDeal.Item)
	S:HandleButton(BlackMarketFrame.HotDeal.BidButton)
	S:HandleEditBox(BlackMarketHotItemBidPriceGold)
	
	for i=1, BlackMarketFrame:GetNumRegions() do
		local region = select(i, BlackMarketFrame:GetRegions())
		if region and region:GetObjectType() == 'FontString' and region:GetText() == BLACK_MARKET_TITLE then
			region:ClearAllPoints()
			region:SetPoint('TOP', BlackMarketFrame, 'TOP', 0, -4)
		end
	end
end

S:RegisterSkin("Blizzard_BlackMarketUI", LoadSkin)