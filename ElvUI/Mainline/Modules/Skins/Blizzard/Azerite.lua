local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_AzeriteUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.azerite) then return end

	_G.AzeriteEmpoweredItemUIPortrait:Hide()
	_G.AzeriteEmpoweredItemUI:StripTextures()
	_G.AzeriteEmpoweredItemUI:SetTemplate('Transparent')
	_G.AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
	S:HandleCloseButton(_G.AzeriteEmpoweredItemUICloseButton)
end

S:AddCallbackForAddon('Blizzard_AzeriteUI')
