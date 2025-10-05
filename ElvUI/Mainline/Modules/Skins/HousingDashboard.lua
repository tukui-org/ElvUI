local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_HousingDashboard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housingDashboard) then return end

	local HD = _G.HousingDashboardFrame
	S:HandlePortraitFrame(HD)

	S:HandleButton(HD.DashboardNoHousesFrame.NoHouseButton)
end

S:AddCallbackForAddon('Blizzard_HousingDashboard')
