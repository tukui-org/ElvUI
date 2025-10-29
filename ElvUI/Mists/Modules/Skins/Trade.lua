local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame

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
		local player = _G['TradePlayerItem'..i..'ItemButton']
		local recipient = _G['TradeRecipientItem'..i..'ItemButton']

		if player and recipient then
			player:StripTextures()
			recipient:StripTextures()

			_G['TradePlayerItem'..i]:StripTextures()
			_G['TradeRecipientItem'..i]:StripTextures()

			local playerIcon = _G['TradePlayerItem'..i..'ItemButtonIconTexture']
			if playerIcon then
				playerIcon:SetInside(player)
				playerIcon:SetTexCoords()
			end

			local recipientIcon = _G['TradeRecipientItem'..i..'ItemButtonIconTexture']
			if recipientIcon then
				recipientIcon:SetInside(recipient)
				recipientIcon:SetTexCoords()
			end

			player:OffsetFrameLevel(-1)
			player:SetTemplate(nil, true)
			player:StyleButton()

			player.bg = CreateFrame('Frame', nil, player)
			player.bg:Point('TOPLEFT', player, 'TOPRIGHT', 4, 0)
			player.bg:Point('BOTTOMRIGHT', _G['TradePlayerItem'..i..'NameFrame'], 'BOTTOMRIGHT', 0, 14)
			player.bg:OffsetFrameLevel(-3, player)
			player.bg:SetTemplate('Transparent')

			recipient:OffsetFrameLevel(-1)
			recipient:SetTemplate(nil, true)
			recipient:StyleButton()

			recipient.bg = CreateFrame('Frame', nil, recipient)
			recipient.bg:Point('TOPLEFT', recipient, 'TOPRIGHT', 4, 0)
			recipient.bg:Point('BOTTOMRIGHT', _G['TradeRecipientItem'..i..'NameFrame'], 'BOTTOMRIGHT', 0, 14)
			recipient.bg:OffsetFrameLevel(-3, recipient)
			recipient.bg:SetTemplate('Transparent')

			S:HandleIconBorder(player.IconBorder)
			S:HandleIconBorder(recipient.IconBorder)
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
