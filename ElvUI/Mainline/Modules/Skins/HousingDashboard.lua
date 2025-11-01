local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_HousingDashboard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housingDashboard) then return end

	local HousingDashboard = _G.HousingDashboardFrame
	S:HandlePortraitFrame(HousingDashboard)
	S:HandleButton(HousingDashboard.DashboardNoHousesFrame.NoHouseButton)
end

S:AddCallbackForAddon('Blizzard_HousingDashboard')
