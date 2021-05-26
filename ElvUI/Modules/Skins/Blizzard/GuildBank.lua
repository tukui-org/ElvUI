local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select, unpack = select, unpack
local CreateFrame = CreateFrame

function S:Blizzard_GuildBankUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gbank) then return end

	local GuildBankFrame = _G.GuildBankFrame
	GuildBankFrame:StripTextures()
	GuildBankFrame:SetTemplate('Transparent')
	_G.GuildBankEmblemFrame:StripTextures(true)
	_G.GuildBankMoneyFrameBackground:Kill()
	S:HandleScrollBar(_G.GuildBankPopupScrollFrameScrollBar)

	--Close button doesn't have a fucking name, extreme hackage
	for i = 1, GuildBankFrame:GetNumChildren() do
		local child = select(i, GuildBankFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
			child:Point('TOPRIGHT', 0, 0)
			child:SetFrameLevel(child:GetFrameLevel()+1)
		end
	end

	S:HandleButton(_G.GuildBankFrameDepositButton, true)
	S:HandleButton(_G.GuildBankFrameWithdrawButton, true)
	S:HandleButton(_G.GuildBankInfoSaveButton, true)
	S:HandleButton(_G.GuildBankFramePurchaseButton, true)

	_G.GuildBankFrameWithdrawButton:Point('RIGHT', _G.GuildBankFrameDepositButton, 'LEFT', -2, 0)
	_G.GuildBankInfoScrollFrame:Point('TOPLEFT', _G.GuildBankInfo, 'TOPLEFT', -10, 12)
	_G.GuildBankInfoScrollFrame:StripTextures()
	_G.GuildBankInfoScrollFrame:Width(_G.GuildBankInfoScrollFrame:GetWidth() - 8)
	_G.GuildBankTransactionsScrollFrame:StripTextures()

	GuildBankFrame.inset = CreateFrame('Frame', nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate()
	GuildBankFrame.inset:Point('TOPLEFT', 20, -58)
	GuildBankFrame.inset:Point('BOTTOMRIGHT', -16, 60)

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

	S:HandleScrollBar(_G.GuildBankTransactionsScrollFrameScrollBar)
	S:HandleScrollBar(_G.GuildBankInfoScrollFrameScrollBar)

	--Popup
	_G.GuildBankPopupFrame:Show() --Toggle the frame in order to create the necessary button elements
	_G.GuildBankPopupFrame:Hide()
	S:HandleIconSelectionFrame(_G.GuildBankPopupFrame, _G.NUM_GUILDBANK_ICONS_SHOWN, 'GuildBankPopupButton', 'GuildBankPopup')
end

S:AddCallbackForAddon('Blizzard_GuildBankUI')
