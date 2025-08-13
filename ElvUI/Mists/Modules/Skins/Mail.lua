local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

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
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end
	end

	_G.MailEditBox.ScrollBox.EditBox:SetTextColor(1, 1, 1)
	_G.MailEditBox:Size(285, _G.SendStationeryBackgroundLeft:GetHeight())
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

		local icon = btn.icon or btn.Icon
		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end
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

		local icon = btn.icon or btn.Icon
		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end
	end
end

function S:MailFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mail) then return end

	local MailFrame = _G.MailFrame
	S:HandlePortraitFrame(MailFrame)

	_G.InboxFrame:CreateBackdrop('Transparent')
	_G.InboxFrame.backdrop:Point('TOPLEFT', _G.MailItem1, 'TOPLEFT')
	_G.InboxFrame.backdrop:Point('BOTTOMRIGHT', _G.MailItem7, 'BOTTOMRIGHT')

	S:HandleNextPrevButton(_G.InboxPrevPageButton, nil, nil, true)
	_G.InboxPrevPageButton:StripTexts()
	_G.InboxPrevPageButton:Point('BOTTOMLEFT', 30, 100)

	S:HandleNextPrevButton(_G.InboxNextPageButton, nil, nil, true)
	_G.InboxNextPageButton:StripTexts()
	_G.InboxNextPageButton:Point('BOTTOMRIGHT', -80, 100)

	_G.MailFrameTab1:StripTextures()
	_G.MailFrameTab2:StripTextures()
	S:HandleTab(_G.MailFrameTab1)
	S:HandleTab(_G.MailFrameTab2)

	-- Reposition Tabs
	_G.MailFrameTab1:ClearAllPoints()
	_G.MailFrameTab2:ClearAllPoints()
	_G.MailFrameTab1:Point('TOPLEFT', _G.MailFrame, 'BOTTOMLEFT', -10, 0)
	_G.MailFrameTab2:Point('TOPLEFT', _G.MailFrameTab1, 'TOPRIGHT', -19, 0)

	-- send mail
	_G.SendMailFrame:StripTextures()
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

	Skin_SendMail()
	Skin_OpenMail()
	Skin_InboxItems()

	hooksecurefunc('SendMailFrame_Update', Skin_SendMail)
	hooksecurefunc('OpenMail_Update', Skin_OpenMail)
	hooksecurefunc('InboxFrame_Update', Skin_InboxItems)

	S:HandleButton(_G.SendMailMailButton, true)
	S:HandleButton(_G.SendMailCancelButton, true)

	S:HandleRadioButton(_G.SendMailSendMoneyButton)
	S:HandleRadioButton(_G.SendMailCODButton)

	_G.SendMailSendMoneyButton:ClearAllPoints()
	_G.SendMailSendMoneyButton:Point('TOPRIGHT', _G.SendMailMoney, 'TOPRIGHT', 20, 8)

	-- open mail (cod)
	_G.OpenMailFrame:StripTextures(true)
	_G.OpenMailFrame:SetTemplate('Transparent')
	_G.OpenMailFrameInset:Kill()

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
	S:HandleScrollBar(_G.OpenMailScrollFrameScrollBar)

	_G.InvoiceTextFontNormal:FontTemplate(nil, 13)
	_G.MailTextFontNormal:FontTemplate(nil, 13)
	_G.InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	_G.MailTextFontNormal:SetTextColor(1, 1, 1)
	_G.OpenMailArithmeticLine:Kill()

	_G.OpenMailLetterButton:StripTextures()
	_G.OpenMailLetterButton:SetTemplate(nil, true)
	_G.OpenMailLetterButton:StyleButton()
	_G.OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	_G.OpenMailLetterButtonIconTexture:SetInside()

	_G.OpenMailMoneyButton:StripTextures()
	_G.OpenMailMoneyButton:SetTemplate(nil, true)
	_G.OpenMailMoneyButton:StyleButton()
	_G.OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	_G.OpenMailMoneyButtonIconTexture:SetInside()

	_G.OpenMailReplyButton:Point('RIGHT', _G.OpenMailDeleteButton, 'LEFT', -2, 0)
	_G.OpenMailDeleteButton:Point('RIGHT', _G.OpenMailCancelButton, 'LEFT', -2, 0)
	_G.SendMailMailButton:Point('RIGHT', _G.SendMailCancelButton, 'LEFT', -2, 0)
end

S:AddCallback('MailFrame')
