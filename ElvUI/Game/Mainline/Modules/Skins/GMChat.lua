local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_GMChatUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gmChat) then return end

	local frame = _G.GMChatFrame
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:StripTextures()
	frame:SetTemplate('Transparent')
	frame.buttonFrame:Hide()

	local editbox = frame.editBox
	editbox:SetAltArrowKeyMode(false)
	editbox:SetTemplate()
	editbox:ClearAllPoints()
	editbox:Point('TOPLEFT', frame, 'BOTTOMLEFT', 0, -5)
	editbox:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -32)

	_G.GMChatFrameEditBoxRight:SetAlpha(0)
	_G.GMChatFrameEditBoxLeft:SetAlpha(0)
	_G.GMChatFrameEditBoxMid:SetAlpha(0)
	_G.GMChatFrameEditBoxFocusRight:SetAlpha(0)
	_G.GMChatFrameEditBoxFocusLeft:SetAlpha(0)
	_G.GMChatFrameEditBoxFocusMid:SetAlpha(0)

	local lang = _G.GMChatFrameEditBoxLanguage
	lang:GetRegions():SetAlpha(0)
	lang:ClearAllPoints()
	lang:Point('TOPLEFT', editbox, 'TOPRIGHT', 3, 0)
	lang:Point('BOTTOMRIGHT', editbox, 'BOTTOMRIGHT', 28, 0)

	local tab = _G.GMChatTab
	tab:StripTextures()
	tab:SetTemplate('Transparent')
	tab:SetBackdropColor(0, .6, 1, .3)
	tab:ClearAllPoints()
	tab:Point('BOTTOMLEFT', frame, 'TOPLEFT', 0, 2)
	tab:Point('TOPRIGHT', frame, 'TOPRIGHT', 0, 28)
	_G.GMChatTabIcon:SetTexture([[Interface\ChatFrame\UI-ChatIcon-Blizz]])

	local close = _G.GMChatFrameCloseButton
	close:ClearAllPoints()
	close:Point('RIGHT', tab, -5, 0)
	S:HandleCloseButton(close)
end

S:AddCallbackForAddon('Blizzard_GMChatUI')
