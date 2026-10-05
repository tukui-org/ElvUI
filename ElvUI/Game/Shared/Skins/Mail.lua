local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

if E.Modern then
	S:AddCallbackForAddon('Blizzard_MailFrame', nil, nil, nil, nil, nil, 'mail')
else
	S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'Blizzard_MailFrame', nil, nil, nil, nil, 'mail')
end

local function Skin_SendMail()
	for i = 1, _G.ATTACHMENTS_MAX_SEND do
		local btn = _G['SendMailAttachment'..i]
		if not btn.template then
			btn:StripTextures()
			btn:SetTemplate()
			btn:StyleButton()

			S:HandleIconBorder(btn.IconBorder)
		end

		local icon = btn:GetNormalTexture()
		if icon then
			icon:SetTexCoords()
			icon:SetInside()
		end
	end

	if not E.Modern then
		_G.MailEditBox.ScrollBox.EditBox:SetTextColor(1, 1, 1)
		_G.MailEditBox:Size(285, _G.SendStationeryBackgroundLeft:GetHeight())
	end
end

local function Skin_OpenMail()
	for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
		local btn = _G['OpenMailAttachmentButton'..i]
		if not btn.template then
			btn:StripTextures()
			btn:SetTemplate(nil, true)
			btn:StyleButton()

			S:HandleIconBorder(btn.IconBorder)
		end

		btn.icon:SetTexCoords()
		btn.icon:SetInside()
	end
end

local function Skin_InboxItems()
	for i = 1, _G.INBOXITEMS_TO_DISPLAY do
		local item = _G['MailItem'..i]
		item:StripTextures() -- background

		local btn = item.Button
		if not btn.template then
			btn:StripTextures()
			btn:SetTemplate(nil, true)
			btn:StyleButton()

			S:HandleIconBorder(btn.IconBorder)
		end

		btn.Icon:SetTexCoords()
		btn.Icon:SetInside()
	end
end

function S:Blizzard_MailFrame()
	local MailFrame = _G.MailFrame
	S:HandlePortraitFrame(MailFrame)

	_G.InboxFrame:CreateBackdrop('Transparent')
	_G.InboxFrame.backdrop:Point('TOPLEFT', _G.MailItem1, 'TOPLEFT')
	_G.InboxFrame.backdrop:Point('BOTTOMRIGHT', _G.MailItem7, 'BOTTOMRIGHT')

	local prevButton = E.Forever and _G.InboxFrame.PrevPageButton or _G.InboxPrevPageButton
	S:HandleNextPrevButton(prevButton, nil, nil, true)
	prevButton:StripTexts()

	local nextButton = E.Forever and _G.InboxFrame.NextPageButton or _G.InboxNextPageButton
	S:HandleNextPrevButton(nextButton, nil, nil, true)
	nextButton:StripTexts()

	if not E.Forever then
		prevButton:Point('BOTTOMLEFT', 30, 100)
		nextButton:Point('BOTTOMRIGHT', -80, 100)
	end

	_G.MailFrameTab1:StripTextures()
	_G.MailFrameTab2:StripTextures()
	S:HandleTab(_G.MailFrameTab1)
	S:HandleTab(_G.MailFrameTab2)

	-- Reposition Tabs
	_G.MailFrameTab1:ClearAllPoints()
	_G.MailFrameTab2:ClearAllPoints()
	_G.MailFrameTab1:Point('TOPLEFT', _G.MailFrame, 'BOTTOMLEFT', E.Modern and -3 or -10, 0)
	_G.MailFrameTab2:Point('TOPLEFT', _G.MailFrameTab1, 'TOPRIGHT', E.Modern and -5 or -19, 0)

	-- send mail
	if E.Modern then
		_G.SendMailScrollFrame:StripTextures(true)
		_G.SendMailScrollFrame:SetTemplate()

		S:HandleTrimScrollBar(_G.SendMailScrollFrame.ScrollBar)
	else
		_G.SendStationeryBackgroundLeft:Hide()
		_G.SendStationeryBackgroundRight:Hide()

		_G.MailEditBox:ClearAllPoints()
		_G.MailEditBox:Point('TOPLEFT', _G.SendMailFrame, 20, -80)

		_G.MailEditBox.ScrollBox:StripTextures(true)
		_G.MailEditBox.ScrollBox:SetTemplate()

		_G.SendMailTitleText:Point('CENTER', _G.SendMailFrame, 'TOP', -10, -17)
		_G.InboxTitleText:Point('CENTER', _G.InboxFrame, 'TOP', -10, -17)

		S:HandleTrimScrollBar(_G.MailEditBoxScrollBar)
		_G.MailEditBoxScrollBar:ClearAllPoints()
		_G.MailEditBoxScrollBar:Point('TOPLEFT', _G.MailEditBox.ScrollBox, 'TOPRIGHT', 0, 8)
		_G.MailEditBoxScrollBar:Point('BOTTOMLEFT', _G.MailEditBox.ScrollBox, 'BOTTOMRIGHT', 0, 0)
	end

	S:HandleEditBox(_G.SendMailNameEditBox)
	S:HandleEditBox(_G.SendMailSubjectEditBox)
	S:HandleEditBox(_G.SendMailMoneyGold)
	S:HandleEditBox(_G.SendMailMoneySilver)
	S:HandleEditBox(_G.SendMailMoneyCopper)
	_G.SendMailMoneyBg:Kill()
	_G.SendMailMoneyInset:StripTextures()

	_G.SendMailNameEditBox:ClearAllPoints()
	_G.SendMailNameEditBox:Point('TOPLEFT', _G.SendMailFrame, 'TOPLEFT', 90, -30)
	_G.SendMailNameEditBox:Width(109)
	_G.SendMailNameEditBox:Height(18)

	_G.SendMailSubjectEditBox:Point('TOPLEFT', _G.SendMailNameEditBox, 'BOTTOMLEFT', 0, -10)
	_G.SendMailSubjectEditBox:Width(214)
	_G.SendMailSubjectEditBox:Height(18)

	_G.SendMailFrame:StripTextures()

	Skin_InboxItems() -- send and open mail get skinned by the hooks below before they show

	hooksecurefunc('SendMailFrame_Update', Skin_SendMail)

	if E.Forever then
		hooksecurefunc(_G.OpenMailFrame, 'Update', Skin_OpenMail)
		hooksecurefunc(_G.InboxFrame, 'Update', Skin_InboxItems)
	else
		hooksecurefunc('OpenMail_Update', Skin_OpenMail)
		hooksecurefunc('InboxFrame_Update', Skin_InboxItems)
	end

	S:HandleButton(_G.SendMailMailButton, true)
	S:HandleButton(_G.SendMailCancelButton, true)

	S:HandleRadioButton(_G.SendMailSendMoneyButton)
	S:HandleRadioButton(_G.SendMailCODButton)

	_G.SendMailSendMoneyButton:ClearAllPoints()
	_G.SendMailSendMoneyButton:Point('TOPRIGHT', _G.SendMailMoney, 'TOPRIGHT', E.Modern and 30 or 20, 8)

	-- open mail (cod)
	_G.OpenMailFrame:StripTextures(true)
	_G.OpenMailFrame:SetTemplate('Transparent')
	_G.OpenMailFrameInset:Kill()

	-- titan keeps the frame border in a child frame
	if E.Wrath then
		_G.OpenMailFrame.BorderTexture:SetAlpha(0)
	end

	S:HandleCloseButton(_G.OpenMailFrameCloseButton)
	S:HandleButton(_G.OpenMailReportSpamButton, true)
	S:HandleButton(_G.OpenMailReplyButton, true)
	S:HandleButton(_G.OpenMailDeleteButton, true)
	S:HandleButton(_G.OpenMailCancelButton, true)
	S:HandleButton(_G.OpenAllMail, true)

	_G.InboxFrame:StripTextures()
	_G.MailFrameInset:Kill()

	_G.OpenMailScrollFrame:StripTextures(true)
	_G.OpenMailScrollFrame:SetTemplate()

	if E.Modern then
		S:HandleTrimScrollBar(_G.OpenMailScrollFrame.ScrollBar)
	else
		S:HandleScrollBar(_G.OpenMailScrollFrameScrollBar)
	end

	_G.InvoiceTextFontNormal:FontTemplate(nil, 13)
	_G.MailTextFontNormal:FontTemplate(nil, 13)
	_G.InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	_G.MailTextFontNormal:SetTextColor(1, 1, 1)
	_G.OpenMailArithmeticLine:Kill()

	_G.OpenMailLetterButton:StripTextures()
	_G.OpenMailLetterButton:SetTemplate(nil, true)
	_G.OpenMailLetterButton:StyleButton()
	_G.OpenMailLetterButtonIconTexture:SetTexCoords()
	_G.OpenMailLetterButtonIconTexture:SetInside()

	_G.OpenMailMoneyButton:StripTextures()
	_G.OpenMailMoneyButton:SetTemplate(nil, true)
	_G.OpenMailMoneyButton:StyleButton()
	_G.OpenMailMoneyButtonIconTexture:SetTexCoords()
	_G.OpenMailMoneyButtonIconTexture:SetInside()

	_G.OpenMailReplyButton:Point('RIGHT', _G.OpenMailDeleteButton, 'LEFT', -2, 0)
	_G.OpenMailDeleteButton:Point('RIGHT', _G.OpenMailCancelButton, 'LEFT', -2, 0)
	_G.SendMailMailButton:Point('RIGHT', _G.SendMailCancelButton, 'LEFT', -2, 0)
end
