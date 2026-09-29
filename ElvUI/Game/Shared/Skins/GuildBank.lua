local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame

local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local NUM_GUILDBANK_COLUMNS = 7
local NUM_GUILDBANK_ICONS_PER_ROW = 10
local NUM_GUILDBANK_ICON_ROWS = 9
local NUM_GUILDBANK_ICONS_SHOWN = NUM_GUILDBANK_ICONS_PER_ROW * NUM_GUILDBANK_ICON_ROWS

local data = S:AddCallbackForAddon('Blizzard_GuildBankUI')
data.toggle = 'gbank'

local function GuildBankOnShow(frame)
	if not frame.IsSkinned then
		if E.Modern then
			S:HandleIconSelectionFrame(frame, nil, nil, 'GuildBankPopup')
		else
			-- BuildIconArray creates the icon buttons on first show
			S:HandleIconSelectionFrame(frame, NUM_GUILDBANK_ICONS_SHOWN, 'GuildBankPopupButton', 'GuildBankPopup')
		end
	end
end

function S:Blizzard_GuildBankUI()
	local frame = _G.GuildBankFrame
	frame:StripTextures()

	if E.Modern then
		frame:SetTemplate('Transparent')
	else
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', 4, 0)
		frame.backdrop:Point('BOTTOMRIGHT', 0, 0)
		frame:Width(770)
		frame:Height(450)
	end

	-- Wrath and TBC load the older layout without BasicFrameTemplate and MoneyFrameBG
	if E.Modern or E.Mists then
		S:HandleCloseButton(frame.CloseButton)
		frame.MoneyFrameBG:StripTextures()
	else
		local _, _, _, _, _, _, _, _, _, _, closeFrameButton = frame:GetChildren() -- Emblem, Column1-7, MoneyFrame, WithdrawMoneyFrame, unnamed UIPanelCloseButton
		S:HandleCloseButton(closeFrameButton)
	end

	frame.Emblem:Kill()

	S:HandleButton(frame.DepositButton, true)
	S:HandleButton(frame.WithdrawButton, true)
	S:HandleButton(_G.GuildBankInfoSaveButton, true)
	S:HandleButton(frame.BuyInfo.PurchaseButton, true)

	frame.WithdrawButton:Point('RIGHT', frame.DepositButton, 'LEFT', -2, 0)

	local GuildBankInfoScrollFrame = _G.GuildBankInfoScrollFrame
	GuildBankInfoScrollFrame:StripTextures()

	if E.Modern then
		GuildBankInfoScrollFrame:Point('TOPLEFT', _G.GuildBankInfo, 'TOPLEFT', -10, 12)
		GuildBankInfoScrollFrame:Width(GuildBankInfoScrollFrame:GetWidth() - 8)

		frame.BlackBG:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, 1)
		frame.BlackBG.backdrop:Point('TOPLEFT', frame.BlackBG, 'TOPLEFT', 4, 0)
		frame.BlackBG.backdrop:Point('BOTTOMRIGHT', frame.BlackBG, 'BOTTOMRIGHT', -3, 3)

		S:HandleTrimScrollBar(frame.Log.ScrollBar)
		frame.Log.ScrollBar:ClearAllPoints()
		frame.Log.ScrollBar:Point('TOPRIGHT', frame.BlackBG.backdrop, -8, -4)
		frame.Log.ScrollBar:Point('BOTTOMRIGHT', frame.BlackBG.backdrop, -8, 4)

		S:HandleTrimScrollBar(GuildBankInfoScrollFrame.ScrollBar)
		GuildBankInfoScrollFrame.ScrollBar:ClearAllPoints()
		GuildBankInfoScrollFrame.ScrollBar:Point('TOPRIGHT', frame.BlackBG.backdrop, -8, -4)
		GuildBankInfoScrollFrame.ScrollBar:Point('BOTTOMRIGHT', frame.BlackBG.backdrop, -8, 4)
	else
		GuildBankInfoScrollFrame:Width(685)
		_G.GuildBankTabInfoEditBox:Width(685)

		S:HandleScrollBar(_G.GuildBankInfoScrollFrameScrollBar)
		_G.GuildBankInfoScrollFrameScrollBar:ClearAllPoints()
		_G.GuildBankInfoScrollFrameScrollBar:Point('TOPRIGHT', GuildBankInfoScrollFrame, 'TOPRIGHT', 38, -28)
		_G.GuildBankInfoScrollFrameScrollBar:Point('BOTTOMRIGHT', GuildBankInfoScrollFrame, 'BOTTOMRIGHT', 0, 17)

		local GuildBankTransactionsScrollFrame = _G.GuildBankTransactionsScrollFrame
		GuildBankTransactionsScrollFrame:StripTextures()

		S:HandleScrollBar(_G.GuildBankTransactionsScrollFrameScrollBar)
		_G.GuildBankTransactionsScrollFrameScrollBar:ClearAllPoints()
		_G.GuildBankTransactionsScrollFrameScrollBar:Point('TOPRIGHT', GuildBankTransactionsScrollFrame, 'TOPRIGHT', 29, -8)
		_G.GuildBankTransactionsScrollFrameScrollBar:Point('BOTTOMRIGHT', GuildBankTransactionsScrollFrame, 'BOTTOMRIGHT', 0, 16)

		frame.bg = CreateFrame('Frame', nil, frame)
		frame.bg:SetTemplate()
		frame.bg:Point('TOPLEFT', 24, -64)
		frame.bg:Point('BOTTOMRIGHT', -18, 62)
		frame.bg:OffsetFrameLevel(nil, frame)

		_G.GuildBankLimitLabel:Point('CENTER', frame.TabLimitBG, 'CENTER', -40, -5)

		-- Right Side Tabs
		local PreviousBankTab = _G.GuildBankTab1
		PreviousBankTab:Point('TOPLEFT', frame, 'TOPRIGHT', E.PixelMode and -1 or 2, -36)

		for i = 2, _G.MAX_GUILDBANK_TABS do
			local BankTab = _G['GuildBankTab'..i]
			BankTab:Point('TOPLEFT', PreviousBankTab, 'BOTTOMLEFT', 0, 7)

			PreviousBankTab = BankTab
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

	local lastTab
	for i = 1, 4 do
		local tab = _G['GuildBankFrameTab'..i]
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if lastTab then
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', E.Modern and -5 or -19, 0)
		elseif E.Modern then
			tab:Point('TOPLEFT', frame, 'BOTTOMLEFT', -3, 0)
		else
			tab:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', -6, -32)
		end

		lastTab = tab
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
