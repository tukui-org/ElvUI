local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local NUM_GUILDBANK_COLUMNS = 7

local function GuildBankOnShow(frame)
	if not frame.IsSkinned then
		S:HandleIconSelectionFrame(frame, nil, nil, 'GuildBankPopup')
	end
end

function S:Blizzard_GuildBankUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gbank) then return end

	local frame = _G.GuildBankFrame
	frame:StripTextures()
	frame:SetTemplate('Transparent')
	S:HandleCloseButton(frame.CloseButton)
	frame.Emblem:Kill()
	frame.MoneyFrameBG:StripTextures()

	S:HandleButton(frame.DepositButton, true)
	S:HandleButton(frame.WithdrawButton, true)
	S:HandleButton(_G.GuildBankInfoSaveButton, true)
	S:HandleButton(frame.BuyInfo.PurchaseButton, true)

	frame.WithdrawButton:Point('RIGHT', frame.DepositButton, 'LEFT', -2, 0)
	_G.GuildBankInfoScrollFrame:Point('TOPLEFT', _G.GuildBankInfo, 'TOPLEFT', -10, 12)
	_G.GuildBankInfoScrollFrame:StripTextures()
	_G.GuildBankInfoScrollFrame:Width(_G.GuildBankInfoScrollFrame:GetWidth() - 8)

	frame.BlackBG:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, 1)
	frame.BlackBG.backdrop:Point('TOPLEFT', frame.BlackBG, 'TOPLEFT', 4, 0)
	frame.BlackBG.backdrop:Point('BOTTOMRIGHT', frame.BlackBG, 'BOTTOMRIGHT', -3, 3)

	S:HandleTrimScrollBar(frame.Log.ScrollBar)
	frame.Log.ScrollBar:ClearAllPoints()
	frame.Log.ScrollBar:Point('TOPRIGHT', frame.BlackBG.backdrop, -8, -4)
	frame.Log.ScrollBar:Point('BOTTOMRIGHT', frame.BlackBG.backdrop, -8, 4)

	S:HandleTrimScrollBar(_G.GuildBankInfoScrollFrame.ScrollBar)
	_G.GuildBankInfoScrollFrame.ScrollBar:ClearAllPoints()
	_G.GuildBankInfoScrollFrame.ScrollBar:Point('TOPRIGHT', frame.BlackBG.backdrop, -8, -4)
	_G.GuildBankInfoScrollFrame.ScrollBar:Point('BOTTOMRIGHT', frame.BlackBG.backdrop, -8, 4)

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
		icon:SetTexCoords()
		icon:SetInside()
	end

	for i = 1, NUM_GUILDBANK_COLUMNS do
		local column = frame['Column'..i]
		column:StripTextures()

		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = column['Button'..x]
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate()

			button.icon:SetInside()
			button.icon:SetTexCoords()

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

	if not E.OtherAddons.ArkInventory then
		_G.GuildBankPopupFrame:HookScript('OnShow', GuildBankOnShow)
	end
end

S:AddCallbackForAddon('Blizzard_GuildBankUI')
