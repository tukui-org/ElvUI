local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select, unpack, pairs = select, unpack, pairs
--WoW API / Variables
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc
local GetItemQualityColor = GetItemQualityColor

local function SkinTab(tab)
	tab.Left:SetAlpha(0)
	if tab.Middle then
		tab.Middle:SetAlpha(0)
	end
	tab.Right:SetAlpha(0)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bmah ~= true then return end

	local BlackMarketFrame = _G.BlackMarketFrame
	BlackMarketFrame:StripTextures()
	BlackMarketFrame:SetTemplate('Transparent')
	BlackMarketFrame.Inset:StripTextures()

	S:HandleCloseButton(BlackMarketFrame.CloseButton)
	S:HandleScrollBar(_G.BlackMarketScrollFrameScrollBar, 4)
	SkinTab(BlackMarketFrame.ColumnName)
	SkinTab(BlackMarketFrame.ColumnLevel)
	SkinTab(BlackMarketFrame.ColumnType)
	SkinTab(BlackMarketFrame.ColumnDuration)
	SkinTab(BlackMarketFrame.ColumnHighBidder)
	SkinTab(BlackMarketFrame.ColumnCurrentBid)

	BlackMarketFrame.MoneyFrameBorder:StripTextures()
	S:HandleEditBox(_G.BlackMarketBidPriceGold)
	_G.BlackMarketBidPriceGold.backdrop:Point("TOPLEFT", -2, 0)
	_G.BlackMarketBidPriceGold.backdrop:Point("BOTTOMRIGHT", -2, 0)

	S:HandleButton(BlackMarketFrame.BidButton)

	hooksecurefunc('BlackMarketScrollFrame_Update', function()
		for _, button in pairs(_G.BlackMarketScrollFrame.buttons) do
			if not button.skinned then
				S:HandleItemButton(button.Item)
				button:StripTextures()
				button:StyleButton()

				local cR, cG, cB = button.Item.IconBorder:GetVertexColor()
				if not cR then cR, cG, cB = unpack(E.media.bordercolor) end
				button.Item.backdrop:SetBackdropBorderColor(cR, cG, cB)
				button.Item.IconBorder:SetTexture()

				hooksecurefunc(button.Item.IconBorder, 'SetVertexColor', function(self, r, g, b)
					self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
					self:SetTexture()
				end)
				hooksecurefunc(button.Item.IconBorder, 'Hide', function(self)
					self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)

				button.skinned = true
			end
		end
	end)

	BlackMarketFrame.HotDeal:StripTextures()
	BlackMarketFrame.HotDeal.Item.IconTexture:SetTexCoord(unpack(E.TexCoords))
	BlackMarketFrame.HotDeal.Item.IconBorder:SetAlpha(0)

	for i=1, BlackMarketFrame:GetNumRegions() do
		local region = select(i, BlackMarketFrame:GetRegions())
		if region and region:IsObjectType("FontString") and region:GetText() == _G.BLACK_MARKET_TITLE then
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
