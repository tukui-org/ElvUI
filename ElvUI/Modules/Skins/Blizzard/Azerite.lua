local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteUI ~= true then return end

	_G.AzeriteEmpoweredItemUI:StripTextures()
	_G.AzeriteEmpoweredItemUIPortrait:Hide()
	_G.AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
	_G.AzeriteEmpoweredItemUI:CreateBackdrop("Transparent")
	S:HandleCloseButton(_G.AzeriteEmpoweredItemUICloseButton)
end

S:AddCallbackForAddon("Blizzard_AzeriteUI", "AzeriteUI", LoadSkin)
