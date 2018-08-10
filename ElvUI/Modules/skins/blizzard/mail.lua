local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: INBOXITEMS_TO_DISPLAY, ATTACHMENTS_MAX_SEND

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mail ~= true then return end

	local MailFrame = _G["MailFrame"]
	MailFrame:StripTextures(true)
	MailFrame:SetTemplate("Transparent")

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

		local ib = _G["MailItem"..i.."ButtonIconBorder"]
		hooksecurefunc(ib, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)
		hooksecurefunc(ib, 'Hide', function(self)
			self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
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
	SendMailSubjectEditBox:Point("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -10)
	SendMailSubjectEditBox:SetHeight(18)
	SendMailNameEditBox:SetHeight(18)
	SendMailFrame:StripTextures()

	local function MailFrameSkin()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local b = _G["SendMailAttachment"..i]
			if not b.skinned then
				b:StripTextures()
				b:SetTemplate("Default", true)
				b:StyleButton()
				b.skinned = true
				hooksecurefunc(b.IconBorder, 'SetVertexColor', function(self, r, g, b)
					self:GetParent():SetBackdropBorderColor(r, g, b)
					self:SetTexture("")
				end)
				hooksecurefunc(b.IconBorder, 'Hide', function(self)
					self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)
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
	S:HandleButton(OpenAllMail)

	InboxFrame:StripTextures()
	MailFrameInset:Kill()

	OpenMailScrollFrame:StripTextures(true)
	OpenMailScrollFrame:SetTemplate("Default")

	S:HandleScrollBar(OpenMailScrollFrameScrollBar)

	InboxPrevPageButton:Point("BOTTOMLEFT", 30, 100)
	InboxNextPageButton:Point("BOTTOMRIGHT", -80, 100)
	InvoiceTextFontNormal:SetFont(E.media.normFont, 13)
	MailTextFontNormal:SetFont(E.media.normFont, 13)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	MailTextFontNormal:SetTextColor(1, 1, 1)
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

		hooksecurefunc(b.IconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)
		hooksecurefunc(b.IconBorder, 'Hide', function(self)
			self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

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

S:AddCallback("Mail", LoadSkin)
