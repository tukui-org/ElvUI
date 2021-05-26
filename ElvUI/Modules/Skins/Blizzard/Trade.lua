local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame

function S:TradeFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trade) then return end

	local TradeFrame = _G.TradeFrame
	S:HandlePortraitFrame(TradeFrame)

	TradeFrame.RecipientOverlay.portrait:SetAlpha(0)
	TradeFrame.RecipientOverlay.portraitFrame:SetAlpha(0)

	S:HandleButton(_G.TradeFrameTradeButton, true)
	S:HandleButton(_G.TradeFrameCancelButton, true)

	S:HandleEditBox(_G.TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameCopper)
	_G.TradeRecipientItemsInset:Kill()
	_G.TradePlayerItemsInset:Kill()
	_G.TradePlayerInputMoneyInset:Kill()
	_G.TradePlayerEnchantInset:Kill()
	_G.TradeRecipientEnchantInset:Kill()
	_G.TradeRecipientMoneyInset:Kill()
	_G.TradeRecipientMoneyBg:Kill()

	for i = 1, _G.MAX_TRADE_ITEMS do
		local player = _G['TradePlayerItem'..i]
		local recipient = _G['TradeRecipientItem'..i]
		local player_button = _G['TradePlayerItem'..i..'ItemButton']
		local recipient_button = _G['TradeRecipientItem'..i..'ItemButton']
		local player_button_icon = _G['TradePlayerItem'..i..'ItemButtonIconTexture']
		local recipient_button_icon = _G['TradeRecipientItem'..i..'ItemButtonIconTexture']

		if player_button and recipient_button then
			player:StripTextures()
			recipient:StripTextures()
			player_button:StripTextures()
			recipient_button:StripTextures()

			player_button_icon:SetInside(player_button)
			player_button_icon:SetTexCoord(unpack(E.TexCoords))
			player_button:SetTemplate(nil, true)
			player_button:StyleButton()
			player_button.IconBorder:Kill()
			player_button:SetFrameLevel(player_button:GetFrameLevel() - 1)

			player_button.bg = CreateFrame('Frame', nil, player_button)
			player_button.bg:SetTemplate()
			player_button.bg:Point('TOPLEFT', player_button, 'TOPRIGHT', 4, 0)
			player_button.bg:Point('BOTTOMRIGHT', _G['TradePlayerItem'..i..'NameFrame'], 'BOTTOMRIGHT', 0, 14)
			player_button.bg:SetFrameLevel(player_button:GetFrameLevel() - 3)

			recipient_button_icon:SetInside(recipient_button)
			recipient_button_icon:SetTexCoord(unpack(E.TexCoords))
			recipient_button:SetTemplate(nil, true)
			recipient_button:StyleButton()
			recipient_button.IconBorder:Kill()
			recipient_button:SetFrameLevel(recipient_button:GetFrameLevel() - 1)

			recipient_button.bg = CreateFrame('Frame', nil, recipient_button)
			recipient_button.bg:SetTemplate()
			recipient_button.bg:Point('TOPLEFT', recipient_button, 'TOPRIGHT', 4, 0)
			recipient_button.bg:Point('BOTTOMRIGHT', _G['TradeRecipientItem'..i..'NameFrame'], 'BOTTOMRIGHT', 0, 14)
			recipient_button.bg:SetFrameLevel(recipient_button:GetFrameLevel() - 3)

			S:HandleIconBorder(player_button.IconBorder)
			S:HandleIconBorder(recipient_button.IconBorder)
		end
	end

	_G.TradeHighlightPlayerTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayer:SetFrameStrata('HIGH')

	_G.TradeHighlightPlayerEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightPlayerEnchant:SetFrameStrata('HIGH')

	_G.TradeHighlightRecipientTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipient:SetFrameStrata('HIGH')

	_G.TradeHighlightRecipientEnchantTop:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchantBottom:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchantMiddle:SetColorTexture(0, 1, 0, 0.2)
	_G.TradeHighlightRecipientEnchant:SetFrameStrata('HIGH')
end

S:AddCallback('TradeFrame')
