local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

function S:Blizzard_GMChatUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.gmChat) then return end

	local frame = _G.GMChatFrame
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	frame.buttonFrame:Hide()

	local eb = frame.editBox
	eb:SetTemplate('Transparent')
	eb.backdrop:Hide()
	eb:SetAltArrowKeyMode(false)
	for i = 3, 8 do
		select(i, eb:GetRegions()):SetAlpha(0)
	end
	eb:ClearAllPoints()
	eb:Point('TOPLEFT', frame, 'BOTTOMLEFT', 0, -7)
	eb:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -32)

	hooksecurefunc('ChatEdit_DeactivateChat', function(editBox)
		if editBox.isGM then eb.backdrop:Hide() end
	end)
	hooksecurefunc('ChatEdit_ActivateChat', function(editBox)
		if editBox.isGM then eb.backdrop:Show() end
	end)

	local lang = _G.GMChatFrameEditBoxLanguage
	lang:GetRegions():SetAlpha(0)
	lang:ClearAllPoints()
	lang:Point('TOPLEFT', eb, 'TOPRIGHT', 3, 0)
	lang:Point('BOTTOMRIGHT', eb, 'BOTTOMRIGHT', 28, 0)

	local tab = _G.GMChatTab
	tab:StripTextures()
	tab:SetTemplate('Transparent')
	tab:SetBackdropColor(0, .6, 1, .3)
	tab:ClearAllPoints()
	tab:Point('BOTTOMLEFT', frame, 'TOPLEFT', 0, 3)
	tab:Point('TOPRIGHT', frame, 'TOPRIGHT', 0, 28)
	_G.GMChatTabIcon:SetTexture([[Interface\ChatFrame\UI-ChatIcon-Blizz]])

	local close = _G.GMChatFrameCloseButton
	S:HandleCloseButton(close)
	close:ClearAllPoints()
	close:Point('RIGHT', tab, -5, 0)
end

S:AddCallbackForAddon('Blizzard_GMChatUI')
