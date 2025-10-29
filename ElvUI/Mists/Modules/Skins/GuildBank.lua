local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local CreateFrame = CreateFrame

local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local NUM_GUILDBANK_COLUMNS = 7
local NUM_GUILDBANK_ICONS_PER_ROW = 10
local NUM_GUILDBANK_ICON_ROWS = 9
local NUM_GUILDBANK_ICONS_SHOWN = NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS

local function HandleTabs()
	local tab = _G.GuildBankFrameTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('BOTTOMLEFT', _G.GuildBankFrame, 'BOTTOMLEFT', -6, -32)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['GuildBankFrameTab'..index]
	end
end

function S:Blizzard_GuildBankUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gbank) then return end

	local GuildBankFrame = _G.GuildBankFrame
	GuildBankFrame:StripTextures()
	GuildBankFrame:CreateBackdrop('Transparent')
	GuildBankFrame.backdrop:Point('TOPLEFT', 4, 0)
	GuildBankFrame.backdrop:Point('BOTTOMRIGHT', 0, 0)
	GuildBankFrame:Width(770)
	GuildBankFrame:Height(450)
	GuildBankFrame.Emblem:Kill()

	S:HandleEditBox(_G.GuildItemSearchBox)
	_G.GuildBankFrame.MoneyFrameBG:StripTextures()

	for _, child in next, { GuildBankFrame:GetChildren() } do
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

	for i = 1, _G.MAX_GUILDBANK_TABS do
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
		local column = GuildBankFrame['Column'..i]
		column:StripTextures()

		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = column['Button'..x]
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate('Transparent')

			button.icon:SetInside()
			button.icon:SetTexCoords()

			S:HandleIconBorder(button.IconBorder)
		end
	end

	S:HandleButton(GuildBankFrame.BuyInfo.PurchaseButton)
	S:HandleButton(GuildBankFrame.DepositButton)
	S:HandleButton(GuildBankFrame.WithdrawButton)
	GuildBankFrame.WithdrawButton:ClearAllPoints()
	GuildBankFrame.WithdrawButton:Point('LEFT', GuildBankFrame.DepositButton, 'LEFT', -102, 0)

	local GuildBankInfoSaveButton = _G.GuildBankInfoSaveButton
	S:HandleButton(GuildBankInfoSaveButton)

	local GuildBankInfoScrollFrame = _G.GuildBankInfoScrollFrame
	GuildBankInfoScrollFrame:StripTextures()
	GuildBankInfoScrollFrame:Width(685)

	S:HandleScrollBar(_G.GuildBankInfoScrollFrameScrollBar)
	_G.GuildBankInfoScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankInfoScrollFrameScrollBar:Point('TOPRIGHT', GuildBankInfoScrollFrame, 'TOPRIGHT', 38, -28)
	_G.GuildBankInfoScrollFrameScrollBar:Point('BOTTOMRIGHT', GuildBankInfoScrollFrame, 'BOTTOMRIGHT', 0, 17)

	local GuildBankTabInfoEditBox = _G.GuildBankTabInfoEditBox
	GuildBankTabInfoEditBox:Width(685)

	local GuildBankTransactionsScrollFrame = _G.GuildBankTransactionsScrollFrame
	GuildBankTransactionsScrollFrame:StripTextures()

	S:HandleScrollBar(_G.GuildBankTransactionsScrollFrameScrollBar)
	_G.GuildBankTransactionsScrollFrameScrollBar:ClearAllPoints()
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('TOPRIGHT', GuildBankTransactionsScrollFrame, 'TOPRIGHT', 29, -8)
	_G.GuildBankTransactionsScrollFrameScrollBar:Point('BOTTOMRIGHT', GuildBankTransactionsScrollFrame, 'BOTTOMRIGHT', 0, 16)

	GuildBankFrame.bg = CreateFrame('Frame', nil, GuildBankFrame)
	GuildBankFrame.bg:SetTemplate()
	GuildBankFrame.bg:Point('TOPLEFT', 24, -64)
	GuildBankFrame.bg:Point('BOTTOMRIGHT', -18, 62)
	GuildBankFrame.bg:OffsetFrameLevel(nil, GuildBankFrame)

	_G.GuildBankLimitLabel:Point('CENTER', GuildBankFrame.TabLimitBG, 'CENTER', -40, -5)

	-- Bottom Tabs
	HandleTabs()

	-- Right Side Tabs
	_G.GuildBankTab1:Point('TOPLEFT', GuildBankFrame, 'TOPRIGHT', E.PixelMode and -1 or 2, -36)
	_G.GuildBankTab2:Point('TOPLEFT', _G.GuildBankTab1, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab3:Point('TOPLEFT', _G.GuildBankTab2, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab4:Point('TOPLEFT', _G.GuildBankTab3, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab5:Point('TOPLEFT', _G.GuildBankTab4, 'BOTTOMLEFT', 0, 7)
	_G.GuildBankTab6:Point('TOPLEFT', _G.GuildBankTab5, 'BOTTOMLEFT', 0, 7)

	if not E.OtherAddons.ArkInventory then
		S:HandleIconSelectionFrame(_G.GuildBankPopupFrame, NUM_GUILDBANK_ICONS_SHOWN, 'GuildBankPopupButton', 'GuildBankPopup')
	end
end

S:AddCallbackForAddon('Blizzard_GuildBankUI')
