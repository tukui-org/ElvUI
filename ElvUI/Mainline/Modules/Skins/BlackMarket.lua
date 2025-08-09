local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local GetItemQualityByID = C_Item.GetItemQualityByID

local function SkinTab(tab)
	if tab.Left then tab.Left:SetAlpha(0) end
	if tab.Middle then tab.Middle:SetAlpha(0) end
	if tab.Right then tab.Right:SetAlpha(0) end
end

local function BlackMarketScrollUpdateChild(button)
	if not button.skinned then
		S:HandleItemButton(button.Item)
		S:HandleIconBorder(button.Item.IconBorder)

		button:StripTextures()
		button:StyleButton(nil, true)

		button.Selection:SetColorTexture(0.9, 0.8, 0.1, 0.3)

		button.skinned = true
	end
end

local function BlackMarketScrollUpdate()
	_G.BlackMarketFrame.ScrollBox:ForEachFrame(BlackMarketScrollUpdateChild)
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

	hooksecurefunc('BlackMarketScrollFrame_Update', BlackMarketScrollUpdate)

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

	hooksecurefunc('BlackMarketFrame_UpdateHotItem', function(item)
		local deal = item.HotDeal
		local link = deal and deal.Name and deal:IsShown() and deal.itemLink
		if not link then return end

		local quality = GetItemQualityByID(link)
		local r, g, b = E:GetItemQualityColor(quality)
		deal.Name:SetTextColor(r, g, b)
	end)
end

S:AddCallbackForAddon('Blizzard_BlackMarketUI')
