local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local GARRISON_CURRENCY = 824
local format = string.format
local GARRISON_ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(GARRISON_CURRENCY)), 16, 16)

local function OnEnter(self, _, noUpdate)
	DT:SetupTooltip(self)

	if(not noUpdate) then
		DT.tooltip:Hide()
		C_Garrison.RequestLandingPageShipmentInfo();
		return
	end
	local buildings = C_Garrison.GetBuildings();
	local numBuildings = #buildings
	local hasBuilding = false
	if(numBuildings > 0) then
		for i = 1, #buildings do
			local buildingID = buildings[i].buildingID;
			if ( buildingID ) then
				local name, _, _, shipmentsReady, shipmentsTotal = C_Garrison.GetLandingPageShipmentInfo(buildingID);
				if ( name and shipmentsReady and shipmentsTotal ) then
					if(hasBuilding == false) then
						DT.tooltip:AddLine(L["Building(s) Report:"])
						hasBuilding = true
					end

					DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1)
				end
			end
		end
	end

	local inProgressMissions = C_Garrison.GetInProgressMissions()
	local numMissions = #inProgressMissions
	local currentTime = time()
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

			if(mission.missionEndTime and currentTime and mission.missionEndTime <= currentTime) then
				DT.tooltip:AddDoubleLine(mission.name, COMPLETE, r, g, b, 0, 1, 0)
			else
				DT.tooltip:AddDoubleLine(mission.name, mission.timeLeft, r, g, b)
			end
		end
	end

	if(hasBuilding == true or numMissions > 0) then
		DT.tooltip:Show()
	else
		DT.tooltip:Hide()
	end
end

local function OnEvent(self, event, ...)
	if(event == "GARRISON_LANDINGPAGE_SHIPMENTS") then
		if(GetMouseFocus() == self) then
			OnEnter(self, nil, true)
		end

		return
	end

	local _, numResources = GetCurrencyInfo(GARRISON_CURRENCY)
	self.text:SetFormattedText("%s %s", GARRISON_ICON, numResources)
end


DT:RegisterDatatext('Garrison', {"PLAYER_ENTERING_WORLD", "CURRENCY_DISPLAY_UPDATE", "GARRISON_LANDINGPAGE_SHIPMENTS"}, OnEvent, nil, GarrisonLandingPage_Toggle, OnEnter)
