local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, ipairs = pairs, ipairs
local unpack, select = unpack, select
local hooksecurefunc = hooksecurefunc

local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

function S:TradeFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trade) then return end

	local TradeFrame = _G.TradeFrame
	S:HandleFrame(TradeFrame, true, nil, -5, 0, 0)

	S:HandleButton(_G.TradeFrameTradeButton, true)
	S:HandleButton(_G.TradeFrameCancelButton, true)

	S:HandlePointXY(_G.TradeFrameCloseButton, -5)
	S:HandlePointXY(_G.TradeFrameTradeButton, -85)
	S:HandlePointXY(_G.TradeFrameTradeButton, -85, 2)
	S:HandlePointXY(_G.TradeFrameCancelButton, 3)
	S:HandlePointXY(_G.TradePlayerItem1, 8)

	S:HandleEditBox(_G.TradePlayerInputMoneyFrameGold)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameSilver)
	S:HandleEditBox(_G.TradePlayerInputMoneyFrameCopper)

	_G.TradePlayerInputMoneyInset:StripTextures()

	local tradeFrames = {
		_G.TradeFramePlayerPortrait,
		_G.TradeFrameRecipientPortrait,
		_G.TradePlayerInputMoneyInset,
		_G.TradeRecipientPortraitFrame,
		_G.TradeRecipientMoneyBg
	}

	for _, frame in ipairs(tradeFrames) do
		frame:Kill()
	end

	for _, Frame in pairs({'TradePlayerItem', 'TradeRecipientItem'}) do
		for i = 1, 7 do
			local ItemBackground = _G[Frame..i]
			local ItemButton = _G[Frame..i..'ItemButton']

			ItemBackground:StripTextures()
			S:HandleItemButton(ItemButton)
			ItemButton:StyleButton()

			S:HandleIcon(ItemButton.icon, true)

			ItemButton.backdrop:SetBackdropColor(0, 0, 0, 0)
			ItemButton.backdrop:SetPoint('TOPLEFT', ItemButton, 'TOPRIGHT', 4, 0)
			ItemButton.backdrop:SetPoint('BOTTOMRIGHT', _G[Frame..i..'NameFrame'], 'BOTTOMRIGHT', -1, 14)
		end
	end

	for _, Inset in pairs({ _G.TradePlayerItemsInset, _G.TradeRecipientItemsInset, _G.TradePlayerEnchantInset, _G.TradeRecipientEnchantInset, _G.TradeRecipientMoneyInset }) do
		Inset:StripTextures()
		Inset:SetTemplate('Transparent')
	end

	for _, Highlight in pairs({ _G.TradeHighlightPlayer, _G.TradeHighlightRecipient, _G.TradeHighlightPlayerEnchant, _G.TradeHighlightRecipientEnchant }) do
		Highlight:StripTextures()
	end

	_G.TradeFrame:HookScript('OnShow', function()
		_G.TradePlayerItemsInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
		_G.TradePlayerEnchantInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
		_G.TradeRecipientItemsInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
		_G.TradeRecipientEnchantInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
		_G.TradeRecipientMoneyInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	hooksecurefunc('TradeFrame_SetAcceptState', function(playerState, targetState)
		if playerState == 1 then
			_G.TradePlayerItemsInset:SetBackdropBorderColor(0, 1, 0)
			_G.TradePlayerEnchantInset:SetBackdropBorderColor(0, 1, 0)
		else
			_G.TradePlayerItemsInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
			_G.TradePlayerEnchantInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
		if targetState == 1 then
			_G.TradeRecipientItemsInset:SetBackdropBorderColor(0, 1, 0)
			_G.TradeRecipientEnchantInset:SetBackdropBorderColor(0, 1, 0)
			_G.TradeRecipientMoneyInset:SetBackdropBorderColor(0, 1, 0)
		else
			_G.TradeRecipientItemsInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
			_G.TradeRecipientEnchantInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
			_G.TradeRecipientMoneyInset:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc('TradeFrame_UpdatePlayerItem', function(id)
		local tradeItemButton = _G['TradePlayerItem'..id..'ItemButton']
		local link = GetTradePlayerItemLink(id)

		tradeItemButton:SetTemplate('NoBackdrop')
		tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))

		if link then
			local tradeItemName = _G['TradePlayerItem'..id..'Name']
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))

			if quality and quality > 1 then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end
	end)

	hooksecurefunc('TradeFrame_UpdateTargetItem', function(id)
		local tradeItemButton = _G['TradeRecipientItem'..id..'ItemButton']
		local link = GetTradeTargetItemLink(id)

		tradeItemButton:SetTemplate('NoBackdrop')
		tradeItemButton:SetBackdropBorderColor(unpack(E.media.bordercolor))

		if link then
			local tradeItemName = _G['TradeRecipientItem'..id..'Name']
			local quality = select(3, GetItemInfo(link))

			tradeItemName:SetTextColor(GetItemQualityColor(quality))

			if quality and quality > 1 then
				tradeItemButton:SetBackdropBorderColor(GetItemQualityColor(quality))
			end
		end
	end)
end

S:AddCallback('TradeFrame')
