local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_AzeriteUI')
data.toggle = 'azerite'

function S:Blizzard_AzeriteUI()
	_G.AzeriteEmpoweredItemUIPortrait:Hide()
	_G.AzeriteEmpoweredItemUI:StripTextures()
	_G.AzeriteEmpoweredItemUI:SetTemplate('Transparent')
	_G.AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
	S:HandleCloseButton(_G.AzeriteEmpoweredItemUICloseButton)
end
