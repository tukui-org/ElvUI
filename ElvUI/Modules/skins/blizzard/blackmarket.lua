local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
local _G = _G
local select, type, unpack = select, type, unpack
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local C_BlackMarket_GetNumItems = C_BlackMarket.GetNumItems
local C_BlackMarket_GetItemInfoByIndex = C_BlackMarket.GetItemInfoByIndex
local hooksecurefunc = hooksecurefunc
-- GLOBALS: HybridScrollFrame_GetOffset, BLACK_MARKET_TITLE

local function SkinTab(tab)
	tab.Left:SetAlpha(0)
	if tab.Middle then
		tab.Middle:SetAlpha(0)
	end
	tab.Right:SetAlpha(0)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bmah ~= true then return end

	local BlackMarketFrame = _G["BlackMarketFrame"]
	BlackMarketFrame:StripTextures()
	BlackMarketFrame:SetTemplate('Transparent')
	BlackMarketFrame.Inset:StripTextures()

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

				local cR, cG, cB = button.Item.IconBorder:GetVertexColor()
				if not cR then cR, cG, cB = unpack(E.media.bordercolor) end
				button.Item.backdrop:SetBackdropBorderColor(cR, cG, cB)
				button.Item.IconBorder:SetTexture(nil)

				hooksecurefunc(button.Item.IconBorder, 'SetVertexColor', function(self, r, g, b)
					self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
					self:SetTexture("")
				end)
				hooksecurefunc(button.Item.IconBorder, 'Hide', function(self)
					self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)

				button.skinned = true
			end

			if ( type(numItems) == "number" and index <= numItems ) then
				local name, texture = C_BlackMarket_GetItemInfoByIndex(index);
				if ( name ) then
					button.Item.IconTexture:SetTexture(texture);
				end
			end
		end
	end)

	BlackMarketFrame.HotDeal:StripTextures()
	BlackMarketFrame.HotDeal.Item.IconTexture:SetTexCoord(unpack(E.TexCoords))
	BlackMarketFrame.HotDeal.Item.IconBorder:SetAlpha(0)

	for i=1, BlackMarketFrame:GetNumRegions() do
		local region = select(i, BlackMarketFrame:GetRegions())
		if region and region:IsObjectType("FontString") and region:GetText() == BLACK_MARKET_TITLE then
			region:ClearAllPoints()
			region:Point('TOP', BlackMarketFrame, 'TOP', 0, -4)
		end
	end

	hooksecurefunc("BlackMarketFrame_UpdateHotItem", function(self)
		local hotDeal = self.HotDeal
		if hotDeal:IsShown() and hotDeal.itemLink then
			local _, _, quality = GetItemInfo(hotDeal.itemLink)
			hotDeal.Name:SetTextColor(GetItemQualityColor(quality))
		end
	end)
end

S:AddCallbackForAddon("Blizzard_BlackMarketUI", "BlackMarket", LoadSkin)
