local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select = select

function S:Blizzard_GMChatUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gmChat) then return end

	local frame = _G.GMChatFrame
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:StripTextures()
	frame:SetTemplate('Transparent')
	frame.buttonFrame:Hide()

	local editbox = frame.editBox
	editbox:SetTemplate('Transparent')
	editbox:SetAltArrowKeyMode(false)
	editbox:ClearAllPoints()
	editbox:Point('TOPLEFT', frame, 'BOTTOMLEFT', 0, -7)
	editbox:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -32)

	for i = 3, 8 do
		select(i, editbox:GetRegions()):SetAlpha(0)
	end

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
	tab:Point('BOTTOMLEFT', frame, 'TOPLEFT', 0, 3)
	tab:Point('TOPRIGHT', frame, 'TOPRIGHT', 0, 28)
	_G.GMChatTabIcon:SetTexture([[Interface\ChatFrame\UI-ChatIcon-Blizz]])

	local close = _G.GMChatFrameCloseButton
	close:ClearAllPoints()
	close:Point('RIGHT', tab, -5, 0)
	S:HandleCloseButton(close)
end

S:AddCallbackForAddon('Blizzard_GMChatUI')
