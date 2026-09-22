local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame

local function HandleTradeItem(item, button, icon, name)
	button:StripTextures()
	button:OffsetFrameLevel(-1)
	button:SetTemplate(nil, true)
	button:StyleButton()

	button.bg = CreateFrame('Frame', nil, button)
	button.bg:Point('TOPLEFT', button, 'TOPRIGHT', 4, 0)
	button.bg:Point('BOTTOMRIGHT', name, 'BOTTOMRIGHT', 0, 14)
	button.bg:OffsetFrameLevel(-3, button)
	button.bg:SetTemplate('Transparent')

	S:HandleIconBorder(button.IconBorder)

	item:StripTextures()

	icon:SetInside(button)
	icon:SetTexCoords()
end

function S:TradeFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trade) then return end

	local TradeFrame = _G.TradeFrame
	S:HandlePortraitFrame(TradeFrame)

	_G.TradeFramePlayerPortrait:SetAlpha(0)
	_G.TradeFrameRecipientPortrait:SetAlpha(0)

	S:HandleButton(_G.TradeFrameTradeButton, true)
	S:HandleButton(_G.TradeFrameCancelButton, true)

	_G.TradeRecipientItemsInset:Kill()
	_G.TradePlayerItemsInset:Kill()
	_G.TradePlayerInputMoneyInset:Kill()
	_G.TradePlayerEnchantInset:Kill()
	_G.TradeRecipientEnchantInset:Kill()
	_G.TradeRecipientMoneyInset:Kill()
	_G.TradeRecipientMoneyBg:Kill()

	for i = 1, _G.MAX_TRADE_ITEMS do
		HandleTradeItem(_G['TradePlayerItem'..i], _G['TradePlayerItem'..i..'ItemButton'], _G['TradePlayerItem'..i..'ItemButtonIconTexture'], _G['TradePlayerItem'..i..'NameFrame'])
		HandleTradeItem(_G['TradeRecipientItem'..i], _G['TradeRecipientItem'..i..'ItemButton'], _G['TradeRecipientItem'..i..'ItemButtonIconTexture'], _G['TradeRecipientItem'..i..'NameFrame'])
	end

	_G.TradeHighlightPlayer:SetFrameStrata('HIGH')
	_G.TradeHighlightPlayerTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerMiddle:SetColorTexture(0, 1, 0, 0.2)

	_G.TradeHighlightPlayerEnchant:SetFrameStrata('HIGH')
	_G.TradeHighlightPlayerEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)

	_G.TradeHighlightRecipient:SetFrameStrata('HIGH')
	_G.TradeHighlightRecipientTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientMiddle:SetColorTexture(0, 1, 0, 0.2)

	_G.TradeHighlightRecipientEnchant:SetFrameStrata('HIGH')
	_G.TradeHighlightRecipientEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'TradeFrame')
