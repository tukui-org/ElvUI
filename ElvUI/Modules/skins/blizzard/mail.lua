local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local ATTACHMENTS_MAX_SEND = ATTACHMENTS_MAX_SEND

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mail ~= true then return end
	MailFrame:StripTextures(true)
	MailFrame:SetTemplate("Transparent")
	--MailFrame:Width(360)

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
		t:SetTexCoord(unpack(E.TexCoords))
		t:SetInside()
	end

	S:HandleCloseButton(MailFrameCloseButton)
	S:HandleNextPrevButton(InboxPrevPageButton)
	S:HandleNextPrevButton(InboxNextPageButton)

	MailFrameTab1:StripTextures()
	MailFrameTab2:StripTextures()
	S:HandleTab(MailFrameTab1)
	S:HandleTab(MailFrameTab2)

	-- send mail
	SendMailScrollFrame:StripTextures(true)
	SendMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(SendMailScrollFrameScrollBar)

	S:HandleEditBox(SendMailNameEditBox)
	S:HandleEditBox(SendMailSubjectEditBox)
	S:HandleEditBox(SendMailMoneyGold)
	S:HandleEditBox(SendMailMoneySilver)
	S:HandleEditBox(SendMailMoneyCopper)
	SendMailMoneyBg:Kill()
	SendMailMoneyInset:StripTextures()
	SendMailNameEditBox.backdrop:Point("BOTTOMRIGHT", 2, 4)
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
				t:SetTexCoord(unpack(E.TexCoords))
				t:SetInside()
			end
		end
	end
	hooksecurefunc("SendMailFrame_Update", MailFrameSkin)

	S:HandleButton(SendMailMailButton)
	S:HandleButton(SendMailCancelButton)

	-- open mail (cod)
	OpenMailFrame:StripTextures(true)
	OpenMailFrame:SetTemplate("Transparent")
	OpenMailFrameInset:Kill()

	S:HandleCloseButton(OpenMailFrameCloseButton)
	S:HandleButton(OpenMailReportSpamButton)
	S:HandleButton(OpenMailReplyButton)
	S:HandleButton(OpenMailDeleteButton)
	S:HandleButton(OpenMailCancelButton)

	InboxFrame:StripTextures()
	MailFrameInset:Kill()

	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(OpenMailScrollFrameScrollBar)

	SendMailBodyEditBox:SetTextColor(1, 1, 1)
	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailArithmeticLine:Kill()

	OpenMailLetterButton:StripTextures()
	OpenMailLetterButton:SetTemplate("Default", true)
	OpenMailLetterButton:StyleButton()
	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailLetterButtonIconTexture:SetInside()

	OpenMailMoneyButton:StripTextures()
	OpenMailMoneyButton:SetTemplate("Default", true)
	OpenMailMoneyButton:StyleButton()
	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(E.TexCoords))
	OpenMailMoneyButtonIconTexture:SetInside()

	for i = 1, ATTACHMENTS_MAX_SEND do
		local b = _G["OpenMailAttachmentButton"..i]
		b:StripTextures()
		b:SetTemplate("Default", true)
		b:StyleButton()

		local t = _G["OpenMailAttachmentButton"..i.."IconTexture"]
		if t then
			t:SetTexCoord(unpack(E.TexCoords))
			t:SetInside()
		end
	end

	OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)
	OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)
	SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -2, 0)
end

S:RegisterSkin('ElvUI', LoadSkin)