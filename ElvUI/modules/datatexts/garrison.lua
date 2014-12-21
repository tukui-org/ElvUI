local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local GARRISON_CURRENCY = 824
local format = string.format
local GARRISON_ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(GARRISON_CURRENCY)), 16, 16)

local function OnEvent(self, event, ...)
	local _, numResources = GetCurrencyInfo(GARRISON_CURRENCY)
	self.text:SetFormattedText("%s %s", GARRISON_ICON, numResources)
end


local function OnEnter(self)
	DT:SetupTooltip(self)

	local buildings = C_Garrison.GetBuildings();
	local numBuildings = #buildings
	if(numBuildings > 0) then
		DT.tooltip:AddLine(L["Building(s) Report:"])
		
		for i = 1, #buildings do
			local buildingID = buildings[i].buildingID;
			if ( buildingID ) then
				local name, _, _, shipmentsReady, shipmentsTotal = C_Garrison.GetLandingPageShipmentInfo(buildingID);
				if ( name and shipmentsReady and shipmentsTotal ) then
					DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1)
				end
			end
		end
	end

	local inProgressMissions = C_Garrison.GetInProgressMissions()
	local numMissions = #inProgressMissions
	if(numMissions > 0) then
		if(numBuildings > 0) then
			DT.tooltip:AddLine(" ")
		end
		DT.tooltip:AddLine(L["Mission(s) Report:"])
		for i=1, numMissions do
			local mission = inProgressMissions[i]
			local r, g, b = 1, 1, 1
			if(mission.isRare) then
				r, g, b = 0.09, 0.51, 0.81
			end

			if(mission.timeLeft == "0 sec") then --may have localization issues here
				DT.tooltip:AddDoubleLine(mission.name, COMPLETE, r, g, b, 0, 1, 0)
			else
				DT.tooltip:AddDoubleLine(mission.name, mission.timeLeft, r, g, b)
			end
		end
	end


	DT.tooltip:Show()
end


DT:RegisterDatatext('Garrison', {"PLAYER_ENTERING_WORLD", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, GarrisonLandingPage_Toggle, OnEnter)
