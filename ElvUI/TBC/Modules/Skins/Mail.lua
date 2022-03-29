local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, select = unpack, select

local GetInboxHeaderInfo = GetInboxHeaderInfo
local GetInboxItemLink = GetInboxItemLink
local GetInboxNumItems = GetInboxNumItems
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetSendMailItem = GetSendMailItem
local hooksecurefunc = hooksecurefunc

function S:MailFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.mail) then return end

	-- Mail Frame / Inbox Frame
	local MailFrame = _G.MailFrame
	S:HandleFrame(MailFrame, true, nil, -5, 0, -2, 0)

	_G.MailFrameCloseButton:Point('TOPRIGHT', 0, 2)

	_G.InboxFrameBg:StripTextures()
	_G.MailFrameBg:StripTextures()

	_G.InboxTitleText:Point('CENTER', _G.InboxFrame, 'TOP', -10, -17)

	for i = 1, _G.INBOXITEMS_TO_DISPLAY do
		local mail = _G['MailItem'..i]
		local button = _G['MailItem'..i..'Button']
		local icon = _G['MailItem'..i..'ButtonIcon']

		mail:StripTextures()
		mail:CreateBackdrop('Default')
		mail.backdrop:Point('TOPLEFT', 42, -3)
		mail.backdrop:Point('BOTTOMRIGHT', -2, 5)

		button:StripTextures()
		button:SetTemplate()
		button:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	hooksecurefunc('InboxFrame_Update', function()
		local numItems = GetInboxNumItems()
		local index = ((_G.InboxFrame.pageNum - 1) * _G.INBOXITEMS_TO_DISPLAY) + 1

		for i = 1, _G.INBOXITEMS_TO_DISPLAY do
			local mail = _G['MailItem'..i]

			if index <= numItems then
				local packageIcon, _, _, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(index)
				if packageIcon and not isGM then
					local itemlink = GetInboxItemLink(index, 1)
					if itemlink then
						local quality = select(3, GetItemInfo(itemlink))

						if quality and quality > 1 then
							mail.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						else
							mail.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end
				elseif isGM then
					mail.backdrop:SetBackdropBorderColor(0, 0.56, 0.94)
				else
					mail.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				mail.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end

			index = index + 1
		end
	end)

	S:HandleNextPrevButton(_G.InboxPrevPageButton, nil, nil, true)
	_G.InboxPrevPageButton:Size(24)
	_G.InboxPrevPageButton:Point('CENTER', _G.InboxFrame, 'BOTTOMLEFT', 12, 104)

	S:HandleNextPrevButton(_G.InboxNextPageButton, nil, nil, true)
	_G.InboxNextPageButton:Size(24)
	_G.InboxNextPageButton:Point('CENTER', _G.InboxFrame, 'BOTTOMLEFT', 319, 104)

	S:HandleButton(_G.OpenAllMail)
	_G.OpenAllMail:Point('CENTER', _G.InboxFrame, 'BOTTOM', -28, 104)

	for i = 1, 2 do
		local tab = _G['MailFrameTab'..i]

		tab:StripTextures()
		S:HandleTab(tab)
	end

	-- Send Mail Frame
	_G.SendMailFrame:StripTextures()
	_G.SendStationeryBackgroundLeft:Hide()
	_G.SendStationeryBackgroundRight:Hide()
	_G.MailEditBox.ScrollBox:StripTextures(true)
	_G.MailEditBox.ScrollBox:SetTemplate('Default')
	_G.MailEditBox.ScrollBox.EditBox:SetTextColor(1, 1, 1)

	_G.SendMailTitleText:Point('CENTER', _G.SendMailFrame, 'TOP', -10, -17)

	hooksecurefunc('SendMailFrame_Update', function()
		for i = 1, _G.ATTACHMENTS_MAX_SEND do
			local button = _G['SendMailAttachment'..i]
			if not button.skinned then
				button:StripTextures()
				button:SetTemplate('Default', true)
				button:StyleButton(nil, true)

				button.skinned = true
			end

			local name = GetSendMailItem(i)
			if name then
				local quality = select(3, GetItemInfo(name))
				if quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end

				local icon = button:GetNormalTexture()
				if icon then
					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetInside()
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end

		_G.MailEditBox:SetHeight(_G.SendStationeryBackgroundLeft:GetHeight())
	end)

	S:HandleScrollBar(_G.MailEditBoxScrollBar)
	S:HandleEditBox(_G.SendMailNameEditBox)
	S:HandleEditBox(_G.SendMailSubjectEditBox)
	S:HandleEditBox(_G.SendMailMoneyGold)
	S:HandleEditBox(_G.SendMailMoneySilver)
	S:HandleEditBox(_G.SendMailMoneyCopper)

	_G.SendMailMoneyBg:Kill()
	_G.SendMailMoneyInset:StripTextures()
	_G.SendMailSubjectEditBox:Point('TOPLEFT', _G.SendMailNameEditBox, 'BOTTOMLEFT', 0, -10)
	_G.SendMailSubjectEditBox:Height(18)
	_G.SendMailNameEditBox:Height(18)
	_G.SendMailFrame:StripTextures()

	S:HandleButton(_G.SendMailMailButton)
	_G.SendMailMailButton:Point('RIGHT', _G.SendMailCancelButton, 'LEFT', -2, 0)

	S:HandleButton(_G.SendMailCancelButton)
	_G.SendMailCancelButton:Point('BOTTOMRIGHT', -53, 94)

	_G.SendMailMoneyFrame:Point('BOTTOMLEFT', 170, 94)

	S:HandleRadioButton(_G.SendMailSendMoneyButton)
	S:HandleRadioButton(_G.SendMailCODButton)

	for i = 1, 5 do
		_G['AutoCompleteButton'..i]:StyleButton()
	end

	-- Open Mail Frame
	local OpenMailFrame = _G.OpenMailFrame
	OpenMailFrame:StripTextures(true) -- stupid portrait
	S:HandleFrame(OpenMailFrame, true)
	OpenMailFrame.backdrop:Point('TOPLEFT', -5, 0)
	OpenMailFrame.backdrop:Point('BOTTOMRIGHT', -2, 0)

	_G.OpenMailFrameCloseButton:Point('TOPRIGHT', OpenMailFrame.backdrop, 'TOPRIGHT', 4, 3)

	for i = 1, _G.ATTACHMENTS_MAX_SEND do
		local button = _G['OpenMailAttachmentButton'..i]
		local icon = _G['OpenMailAttachmentButton'..i..'IconTexture']
		local count = _G['OpenMailAttachmentButton'..i..'Count']

		button:StripTextures()
		button:SetTemplate('Default', true)
		button:StyleButton()

		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')
			icon:SetInside()

			count:SetDrawLayer('OVERLAY')
		end
	end

	hooksecurefunc('OpenMailFrame_UpdateButtonPositions', function()
		for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
			local itemLink = GetInboxItemLink(_G.InboxFrame.openMailID, i)
			local button = _G['OpenMailAttachmentButton'..i]

			button:SetTemplate('NoBackdrop')

			if itemLink then
				local quality = select(3, GetItemInfo(itemLink))

				if quality and quality > 1 then
					button:SetBackdropBorderColor(GetItemQualityColor(quality))
				else
					button:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	S:HandleButton(_G.OpenMailReportSpamButton)

	S:HandleButton(_G.OpenMailReplyButton)
	_G.OpenMailReplyButton:Point('RIGHT', _G.OpenMailDeleteButton, 'LEFT', -2, 0)

	S:HandleButton(_G.OpenMailDeleteButton)
	_G.OpenMailDeleteButton:Point('RIGHT', _G.OpenMailCancelButton, 'LEFT', -2, 0)

	S:HandleButton(_G.OpenMailCancelButton)

	_G.OpenMailScrollFrame:StripTextures(true)
	_G.OpenMailScrollFrame:SetTemplate('Default')

	S:HandleScrollBar(_G.OpenMailScrollFrameScrollBar)

	_G.OpenMailBodyText:SetTextColor(1, 1, 1)
	_G.InvoiceTextFontNormal:SetFont(E.media.normFont, 13)
	_G.InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	_G.OpenMailInvoiceBuyMode:SetTextColor(1, 0.80, 0.10)

	_G.OpenMailArithmeticLine:Kill()

	_G.OpenMailLetterButton:StripTextures()
	_G.OpenMailLetterButton:SetTemplate('Default', true)
	_G.OpenMailLetterButton:StyleButton()

	_G.OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	_G.OpenMailLetterButtonIconTexture:SetDrawLayer('ARTWORK')
	_G.OpenMailLetterButtonIconTexture:SetInside()

	_G.OpenMailLetterButtonCount:SetDrawLayer('OVERLAY')

	_G.OpenMailMoneyButton:StripTextures()
	_G.OpenMailMoneyButton:SetTemplate('Default', true)
	_G.OpenMailMoneyButton:StyleButton()

	_G.OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	_G.OpenMailMoneyButtonIconTexture:SetDrawLayer('ARTWORK')
	_G.OpenMailMoneyButtonIconTexture:SetInside()

	_G.OpenMailMoneyButtonCount:SetDrawLayer('OVERLAY')
end

S:AddCallback('MailFrame')
