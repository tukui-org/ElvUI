local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

--[[
	-- To show it for now
	/run LoadAddOn('Blizzard_ProfessionsCustomerOrders');
	/run ProfessionsCustomerOrdersFrame:Show();
]]

function S:Blizzard_ProfessionsCustomerOrders()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	local ProfessionFrame = _G.ProfessionsCustomerOrdersFrame
	S:HandleFrame(ProfessionFrame)


end

S:AddCallbackForAddon('Blizzard_ProfessionsCustomerOrders')
