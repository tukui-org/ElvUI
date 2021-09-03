local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_GuildBankUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gbank) then return end

	_G.GuildBankFrame:StripTextures()
	_G.GuildBankFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.GuildBankFrame.CloseButton)

	_G.GuildBankEmblemFrame:StripTextures(true)
	_G.GuildBankMoneyFrameBackground:Kill()
	S:HandleScrollBar(_G.GuildBankPopupScrollFrameScrollBar)
	S:HandleButton(_G.GuildBankFrameDepositButton, true)
	S:HandleButton(_G.GuildBankFrameWithdrawButton, true)
	S:HandleButton(_G.GuildBankInfoSaveButton, true)
	S:HandleButton(_G.GuildBankFramePurchaseButton, true)

	_G.GuildBankFrameWithdrawButton:Point('RIGHT', _G.GuildBankFrameDepositButton, 'LEFT', -2, 0)
	_G.GuildBankInfoScrollFrame:Point('TOPLEFT', _G.GuildBankInfo, 'TOPLEFT', -10, 12)
	_G.GuildBankInfoScrollFrame:StripTextures()
	_G.GuildBankInfoScrollFrame:Width(_G.GuildBankInfoScrollFrame:GetWidth() - 8)
	_G.GuildBankTransactionsScrollFrame:StripTextures()

	_G.GuildBankFrameBlackBG:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, 1)
	_G.GuildBankFrameBlackBG.backdrop:Point('TOPLEFT', _G.GuildBankFrameBlackBG, 'TOPLEFT', 4, 0)
	_G.GuildBankFrameBlackBG.backdrop:Point('BOTTOMRIGHT', _G.GuildBankFrameBlackBG, 'BOTTOMRIGHT', -3, 3)

	S:HandleScrollBar(_G.GuildBankTransactionsScrollFrameScrollBar)
	S:HandleScrollBar(_G.GuildBankInfoScrollFrameScrollBar)
	_G.GuildBankTransactionsScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('TOPRIGHT', _G.GuildBankFrameBlackBG.backdrop, 'TOPRIGHT', -4, -21)
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.GuildBankFrameBlackBG.backdrop, 'BOTTOMRIGHT', -4, 21)
	_G.GuildBankInfoScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankInfoScrollFrameScrollBar:Point('TOPRIGHT', _G.GuildBankFrameBlackBG.backdrop, 'TOPRIGHT', -4, -21)
	_G.GuildBankInfoScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.GuildBankFrameBlackBG.backdrop, 'BOTTOMRIGHT', -4, 21)

	for i = 1, _G.NUM_GUILDBANK_COLUMNS do
		_G['GuildBankColumn'..i]:StripTextures()

		for x = 1, _G.NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G['GuildBankColumn'..i..'Button'..x]
			local icon = _G['GuildBankColumn'..i..'Button'..x..'IconTexture']
			local texture = _G['GuildBankColumn'..i..'Button'..x..'NormalTexture']
			if texture then
				texture:SetTexture()
			end

			button:StyleButton()
			button:SetTemplate(nil, true)

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			S:HandleIconBorder(button.IconBorder)
		end
	end

	for i = 1, _G.MAX_GUILDBANK_TABS do
		local button = _G['GuildBankTab'..i..'Button']
		local texture = _G['GuildBankTab'..i..'ButtonIconTexture']
		_G['GuildBankTab'..i]:StripTextures(true)

		button:StripTextures()
		button:StyleButton(true)
		button:SetTemplate(nil, true)

		button.searchOverlay:SetColorTexture(0, 0, 0, 0.8)

		texture:SetInside()
		texture:SetTexCoord(unpack(E.TexCoords))
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

	_G.GuildBankPopupFrame:Show() --Toggle the frame in order to create the necessary button elements
	_G.GuildBankPopupFrame:Hide()

	S:HandleIconSelectionFrame(_G.GuildBankPopupFrame, _G.NUM_GUILDBANK_ICONS_SHOWN, 'GuildBankPopupButton', 'GuildBankPopup')
end

S:AddCallbackForAddon('Blizzard_GuildBankUI')
