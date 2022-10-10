local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

--ToDo: WoW10
function S:Blizzard_ExpansionLandingPage()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.expansionLanding) then return end

	local ExpansionLandingPage = _G.ExpansionLandingPage
	ExpansionLandingPage:SetTemplate('Transparent')
	S:HandleCloseButton(ExpansionLandingPage.Overlay.CloseButton, ExpansionLandingPage.backdrop)
end

S:AddCallbackForAddon('Blizzard_ExpansionLandingPage')
