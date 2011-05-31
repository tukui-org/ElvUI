local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].mail ~= true then return end

local function LoadSkin()
	MailFrame:StripTextures(true)
	MailFrame:CreateBackdrop("Transparent")
	MailFrame.backdrop:Point("TOPLEFT", 4, 0)
	MailFrame.backdrop:Point("BOTTOMRIGHT", 2, 74)
	MailFrame.backdrop:CreateShadow("Default")
	MailFrame:SetWidth(360)

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local bg = _G["MailItem"..i]
		bg:StripTextures()
		bg:CreateBackdrop("Default")
		bg.backdrop:Point("TOPLEFT", 2, 1)
		bg.backdrop:Point("BOTTOMRIGHT", -2, 2)
		
		local b = _G["MailItem"..i.."Button"]
		b:StripTextures()
		b:SetTemplate("Default", true)
		b:StyleButton()

		local t = _G["MailItem"..i.."ButtonIcon"]
		t:SetTexCoord(.08, .92, .08, .92)
		t:ClearAllPoints()
		t:Point("TOPLEFT", 2, -2)
		t:Point("BOTTOMRIGHT", -2, 2)
	end
	
	E.SkinCloseButton(InboxCloseButton)
	E.SkinNextPrevButton(InboxPrevPageButton)
	E.SkinNextPrevButton(InboxNextPageButton)

	MailFrameTab1:StripTextures()
	MailFrameTab2:StripTextures()
	E.SkinTab(MailFrameTab1)
	E.SkinTab(MailFrameTab2)

	-- send mail
	SendMailScrollFrame:StripTextures(true)
	SendMailScrollFrame:SetTemplate("Default")

	E.SkinScrollBar(SendMailScrollFrameScrollBar)
	
	E.SkinEditBox(SendMailNameEditBox)
	E.SkinEditBox(SendMailSubjectEditBox)
	E.SkinEditBox(SendMailMoneyGold)
	E.SkinEditBox(SendMailMoneySilver)
	E.SkinEditBox(SendMailMoneyCopper)
	
	SendMailNameEditBox.backdrop:Point("BOTTOMRIGHT", 2, 0)
	SendMailSubjectEditBox.backdrop:Point("BOTTOMRIGHT", 2, 0)
	SendMailFrame:StripTextures()
	
	local function MailFrameSkin()
		for i = 1, ATTACHMENTS_MAX_SEND do				
			local b = _G["SendMailAttachment"..i]
			if not b.skinned then
				b:StripTextures()
				b:SetTemplate("Default", true)
				b:StyleButton()
				b.skinned = true
			end
			local t = b:GetNormalTexture()
			if t then
				t:SetTexCoord(.08, .92, .08, .92)
				t:ClearAllPoints()
				t:Point("TOPLEFT", 2, -2)
				t:Point("BOTTOMRIGHT", -2, 2)
			end
		end
	end
	hooksecurefunc("SendMailFrame_Update", MailFrameSkin)
	
	E.SkinButton(SendMailMailButton)
	E.SkinButton(SendMailCancelButton)
	
	-- open mail (cod)
	OpenMailFrame:StripTextures(true)
	OpenMailFrame:CreateBackdrop("Transparent")
	OpenMailFrame.backdrop:Point("TOPLEFT", 4, 0)
	OpenMailFrame.backdrop:Point("BOTTOMRIGHT", 2, 74)
	OpenMailFrame.backdrop:CreateShadow("Default")
	OpenMailFrame:SetWidth(360)
	
	E.SkinCloseButton(OpenMailCloseButton)
	E.SkinButton(OpenMailReportSpamButton)
	E.SkinButton(OpenMailReplyButton)
	E.SkinButton(OpenMailDeleteButton)
	E.SkinButton(OpenMailCancelButton)
	
	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:SetTemplate("Default")

	E.SkinScrollBar(OpenMailScrollFrameScrollBar)
	
	SendMailBodyEditBox:SetTextColor(1, 1, 1)
	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailArithmeticLine:Kill()
	
	OpenMailLetterButton:StripTextures()
	OpenMailLetterButton:SetTemplate("Default", true)
	OpenMailLetterButton:StyleButton()
	OpenMailLetterButtonIconTexture:SetTexCoord(.08, .92, .08, .92)						
	OpenMailLetterButtonIconTexture:ClearAllPoints()
	OpenMailLetterButtonIconTexture:Point("TOPLEFT", 2, -2)
	OpenMailLetterButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)
	
	OpenMailMoneyButton:StripTextures()
	OpenMailMoneyButton:SetTemplate("Default", true)
	OpenMailMoneyButton:StyleButton()
	OpenMailMoneyButtonIconTexture:SetTexCoord(.08, .92, .08, .92)						
	OpenMailMoneyButtonIconTexture:ClearAllPoints()
	OpenMailMoneyButtonIconTexture:Point("TOPLEFT", 2, -2)
	OpenMailMoneyButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)
	
	for i = 1, ATTACHMENTS_MAX_SEND do				
		local b = _G["OpenMailAttachmentButton"..i]
		b:StripTextures()
		b:SetTemplate("Default", true)
		b:StyleButton()
		
		local t = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		if t then
			t:SetTexCoord(.08, .92, .08, .92)
			t:ClearAllPoints()
			t:Point("TOPLEFT", 2, -2)
			t:Point("BOTTOMRIGHT", -2, 2)
		end				
	end
	
	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)
	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)
	SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -2, 0)
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)