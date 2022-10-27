local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

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

function S:Blizzard_BlackMarketUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bmah) then return end

	local BlackMarketFrame = _G.BlackMarketFrame
	BlackMarketFrame:StripTextures()
	BlackMarketFrame:SetTemplate('Transparent')
	BlackMarketFrame.Inset:StripTextures()
	BlackMarketFrame.Inset:SetTemplate('Transparent')

	S:HandleCloseButton(BlackMarketFrame.CloseButton)
	S:HandleTrimScrollBar(BlackMarketFrame.ScrollBar)
	SkinTab(BlackMarketFrame.ColumnName)
	SkinTab(BlackMarketFrame.ColumnLevel)
	SkinTab(BlackMarketFrame.ColumnType)
	SkinTab(BlackMarketFrame.ColumnDuration)
	SkinTab(BlackMarketFrame.ColumnHighBidder)
	SkinTab(BlackMarketFrame.ColumnCurrentBid)

	BlackMarketFrame.MoneyFrameBorder:StripTextures()
	S:HandleEditBox(_G.BlackMarketBidPriceGold)
	_G.BlackMarketBidPriceGold.backdrop:Point('TOPLEFT', -2, 0)
	_G.BlackMarketBidPriceGold.backdrop:Point('BOTTOMRIGHT', -2, 0)

	S:HandleButton(BlackMarketFrame.BidButton)

	BlackMarketFrame.ColumnName:ClearAllPoints()
	BlackMarketFrame.ColumnName:Point('TOPLEFT', BlackMarketFrame.TopLeftCorner, 25, -50)

	hooksecurefunc('BlackMarketScrollFrame_Update', function()
		for _, button in next, { BlackMarketFrame.ScrollBox.ScrollTarget:GetChildren() } do
			if not button.skinned then
				S:HandleItemButton(button.Item)
				S:HandleIconBorder(button.Item.IconBorder)

				button:StripTextures()
				button:StyleButton(nil, true)

				button.Selection:SetColorTexture(0.9, 0.8, 0.1, 0.3)

				button.skinned = true
			end
		end
	end)

	for _, region in next, { BlackMarketFrame:GetRegions() } do
		if region:IsObjectType('FontString') and region:GetText() == _G.BLACK_MARKET_TITLE then
			region:ClearAllPoints()
			region:Point('TOP', BlackMarketFrame, 'TOP', 0, -4)
		end
	end

	BlackMarketFrame.HotDeal:StripTextures()
	BlackMarketFrame.HotDeal:SetTemplate('Transparent')

	S:HandleItemButton(BlackMarketFrame.HotDeal.Item, true)
	S:HandleIconBorder(BlackMarketFrame.HotDeal.Item.IconBorder)

	hooksecurefunc('BlackMarketFrame_UpdateHotItem', function(s)
		local deal = s.HotDeal
		local link = deal and deal.Name and deal:IsShown() and deal.itemLink
		if link then
			local _, _, quality = GetItemInfo(link)
			local r, g, b = GetItemQualityColor(quality)
			deal.Name:SetTextColor(r, g, b)
		end
	end)
end

S:AddCallbackForAddon('Blizzard_BlackMarketUI')
