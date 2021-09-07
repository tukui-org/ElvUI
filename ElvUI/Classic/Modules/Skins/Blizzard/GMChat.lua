local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select

local hooksecurefunc = hooksecurefunc

function S:Blizzard_GMChatUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.GMChat) then return end

	local GMChatFrame = _G.GMChatFrame
	S:HandleFrame(GMChatFrame, true)
	GMChatFrame:SetClampRectInsets(0, 0, 0, 0)

	GMChatFrame.buttonFrame:Hide()

	local GMChatFrameEditBox = _G.GMChatFrameEditBox
	GMChatFrameEditBox:CreateBackdrop('Transparent')
	GMChatFrameEditBox.backdrop:Hide()
	GMChatFrameEditBox:SetAltArrowKeyMode(false)
	for i = 2, 7 do
		select(i, GMChatFrameEditBox:GetRegions()):SetAlpha(0)
	end
	GMChatFrameEditBox:ClearAllPoints()
	GMChatFrameEditBox:SetPoint('TOPLEFT', GMChatFrame, 'BOTTOMLEFT', 0, -7)
	GMChatFrameEditBox:SetPoint('BOTTOMRIGHT', GMChatFrame, 'BOTTOMRIGHT', 0, -32)

	hooksecurefunc('ChatEdit_DeactivateChat', function(editBox)
		if editBox.isGM then GMChatFrameEditBox.backdrop:Hide() end
	end)
	hooksecurefunc('ChatEdit_ActivateChat', function(editBox)
		if editBox.isGM then GMChatFrameEditBox.backdrop:Show() end
	end)

	local GMChatFrameEditBoxLanguage = _G.GMChatFrameEditBoxLanguage
	GMChatFrameEditBoxLanguage:GetRegions():SetAlpha(0)
	GMChatFrameEditBoxLanguage:SetPoint('TOPLEFT', eb, 'TOPRIGHT', 3, 0)
	GMChatFrameEditBoxLanguage:SetPoint('BOTTOMRIGHT', eb, 'BOTTOMRIGHT', 28, 0)

	local GMChatTab = _G.GMChatTab
	S:HandleFrame(GMChatTab, true)
	GMChatTab:SetBackdropColor(0, .6, 1, .3)
	GMChatTab:SetPoint('BOTTOMLEFT', GMChatFrame, 'TOPLEFT', 0, 3)
	GMChatTab:SetPoint('TOPRIGHT', GMChatFrame, 'TOPRIGHT', 0, 28)
	_G.GMChatTabIcon:SetTexture('Interface\\ChatFrame\\UI-ChatIcon-Blizz')

	GMChatStatusFrame:HookScript("OnShow", function(self)
		if TicketStatusFrame and TicketStatusFrame:IsShown() then
			self:Point("TOPLEFT", TicketStatusFrame, "BOTTOMLEFT", 0, 1)
		else
			self:SetAllPoints(TicketStatusFrame)
		end
	end)

	local GMChatFrameCloseButton = _G.GMChatFrameCloseButton
	S:HandleCloseButton(GMChatFrameCloseButton, GMChatTab.backdrop, 2, 4)

	TicketStatusFrame:HookScript("OnShow", function(self)
		GMChatStatusFrame:Point("TOPLEFT", self, "BOTTOMLEFT", 0, 1)
	end)
	TicketStatusFrame:HookScript("OnHide", function(self)
		GMChatStatusFrame:SetAllPoints(self)
	end)

end

function S:Blizzard_GMSurveyUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.GMChat) then return end

	S:HandleFrame(GMSurveyFrame, true, nil, 4, 4, -44, 10)

	GMSurveyHeader:StripTextures()
	S:HandleCloseButton(GMSurveyCloseButton, GMSurveyFrame.backdrop)

	GMSurveyScrollFrame:StripTextures()
	S:HandleScrollBar(GMSurveyScrollFrameScrollBar)

	GMSurveyCancelButton:Point('BOTTOMLEFT', 19, 18)
	S:HandleButton(GMSurveyCancelButton)

	GMSurveySubmitButton:Point('BOTTOMRIGHT', -57, 18)
	S:HandleButton(GMSurveySubmitButton)

	for i = 1, 7 do
		local frame = _G['GMSurveyQuestion'..i]
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	GMSurveyCommentFrame:StripTextures()
	GMSurveyCommentFrame:SetTemplate('Transparent')
end

S:AddCallbackForAddon('Blizzard_GMChatUI')
S:AddCallbackForAddon('Blizzard_GMSurveyUI')
