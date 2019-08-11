local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local select = select
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.GMChat ~= true then return end

	local frame = _G.GMChatFrame
	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:StripTextures()
	frame:CreateBackdrop("Transparent")

	frame.buttonFrame:Hide()

	local eb = frame.editBox
	eb:CreateBackdrop("Transparent")
	eb.backdrop:Hide()
	eb:SetAltArrowKeyMode(false)
	for i = 3, 8 do
		select(i, eb:GetRegions()):SetAlpha(0)
	end
	eb:ClearAllPoints()
	eb:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -7)
	eb:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -32)

	hooksecurefunc("ChatEdit_DeactivateChat", function(editBox)
		if editBox.isGM then eb.backdrop:Hide() end
	end)
	hooksecurefunc("ChatEdit_ActivateChat", function(editBox)
		if editBox.isGM then eb.backdrop:Show() end
	end)

	local lang = _G.GMChatFrameEditBoxLanguage
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 3, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 28, 0)

	local tab = _G.GMChatTab
	tab:StripTextures()
	tab:CreateBackdrop("Transparent")
	tab:SetBackdropColor(0, .6, 1, .3)
	tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
	tab:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 28)
	_G.GMChatTabIcon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-Blizz")

	local close = _G.GMChatFrameCloseButton
	S:HandleCloseButton(close)
	close:ClearAllPoints()
	close:SetPoint("RIGHT", tab, -5, 0)
end

S:AddCallbackForAddon("Blizzard_GMChatUI", "GMChat", LoadSkin)
