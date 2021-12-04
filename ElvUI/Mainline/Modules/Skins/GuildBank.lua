local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local NUM_GUILDBANK_ICONS_PER_ROW = 10
local NUM_GUILDBANK_ICON_ROWS = 9
local NUM_GUILDBANK_COLUMNS = 7
local NUM_GUILDBANK_ICONS_SHOWN = NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS

function S:Blizzard_GuildBankUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gbank) then return end

	_G.GuildBankFrame:StripTextures()
	_G.GuildBankFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.GuildBankFrame.CloseButton)
	_G.GuildBankFrame.Emblem:Kill()
	_G.GuildBankFrame.MoneyFrameBG:StripTextures()

	S:HandleButton(_G.GuildBankFrame.DepositButton, true)
	S:HandleButton(_G.GuildBankFrame.WithdrawButton, true)
	S:HandleButton(_G.GuildBankInfoSaveButton, true)
	S:HandleButton(_G._G.GuildBankFrame.BuyInfo.PurchaseButton, true)

	_G.GuildBankFrame.WithdrawButton:Point('RIGHT', _G.GuildBankFrame.DepositButton, 'LEFT', -2, 0)
	_G.GuildBankInfoScrollFrame:Point('TOPLEFT', _G.GuildBankInfo, 'TOPLEFT', -10, 12)
	_G.GuildBankInfoScrollFrame:StripTextures()
	_G.GuildBankInfoScrollFrame:Width(_G.GuildBankInfoScrollFrame:GetWidth() - 8)
	_G.GuildBankTransactionsScrollFrame:StripTextures()

	_G.GuildBankFrame.BlackBG:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, 1)
	_G.GuildBankFrame.BlackBG.backdrop:Point('TOPLEFT', _G.GuildBankFrame.BlackBG, 'TOPLEFT', 4, 0)
	_G.GuildBankFrame.BlackBG.backdrop:Point('BOTTOMRIGHT', _G.GuildBankFrame.BlackBG, 'BOTTOMRIGHT', -3, 3)

	S:HandleScrollBar(_G.GuildBankTransactionsScrollFrameScrollBar)
	S:HandleScrollBar(_G.GuildBankInfoScrollFrameScrollBar)
	_G.GuildBankTransactionsScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('TOPRIGHT', _G.GuildBankFrame.BlackBG.backdrop, 'TOPRIGHT', -4, -21)
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.GuildBankFrame.BlackBG.backdrop, 'BOTTOMRIGHT', -4, 21)
	_G.GuildBankInfoScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankInfoScrollFrameScrollBar:Point('TOPRIGHT', _G.GuildBankFrame.BlackBG.backdrop, 'TOPRIGHT', -4, -21)
	_G.GuildBankInfoScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.GuildBankFrame.BlackBG.backdrop, 'BOTTOMRIGHT', -4, 21)

	for i=1, _G.MAX_GUILDBANK_TABS do
		local tab = _G['GuildBankTab'..i]
		tab:StripTextures()

		local button = tab.Button
		local icon = button.IconTexture
		local texture = icon:GetTexture()
		button:StripTextures()
		button:StyleButton(true)
		button:SetTemplate(nil, true)
		icon:SetTexture(texture)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	for i = 1, NUM_GUILDBANK_COLUMNS do
		local column = _G.GuildBankFrame['Column'..i]
		column:StripTextures()

		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = column['Button'..x]
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate('Transparent')

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))

			S:HandleIconBorder(button.IconBorder)
		end
	end

	for i = 1, 4 do
		S:HandleTab(_G['GuildBankFrameTab'..i])
	end

	local GuildItemSearchBox = _G.GuildItemSearchBox
	GuildItemSearchBox.Left:Kill()
	GuildItemSearchBox.Middle:Kill()
	GuildItemSearchBox.Right:Kill()
	GuildItemSearchBox.searchIcon:Kill()
	GuildItemSearchBox:SetTemplate()

	if not E:IsAddOnEnabled('ArkInventory') then
		S:HandleIconSelectionFrame(_G.GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, 'GuildBankPopupButton', 'GuildBankPopup')
	end
end

S:AddCallbackForAddon('Blizzard_GuildBankUI')
