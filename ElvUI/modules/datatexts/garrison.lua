local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format = string.format
local tsort = table.sort
--WoW API / Variables
local GetMouseFocus = GetMouseFocus
local GetCurrencyInfo = GetCurrencyInfo
local C_GarrisonRequestLandingPageShipmentInfo = C_Garrison.RequestLandingPageShipmentInfo
local C_GarrisonGetBuildings = C_Garrison.GetBuildings
local C_GarrisonGetInProgressMissions = C_Garrison.GetInProgressMissions
local C_GarrisonGetLandingPageShipmentInfo = C_Garrison.GetLandingPageShipmentInfo
local GARRISON_LANDING_SHIPMENT_COUNT = GARRISON_LANDING_SHIPMENT_COUNT
local COMPLETE = COMPLETE
local LE_FOLLOWER_TYPE_GARRISON_6_0 = LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2 = LE_FOLLOWER_TYPE_SHIPYARD_6_2

local GARRISON_CURRENCY = 824
local OIL_CURRENCY = 1101
local GARRISON_ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(GARRISON_CURRENCY)), 16, 16)
local OIL_ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(OIL_CURRENCY)), 16, 16)

local function sortFunction(a, b)
	return a.missionEndTime < b.missionEndTime
end

local function OnEnter(self, _, noUpdate)
	DT:SetupTooltip(self)

	if(not noUpdate) then
		DT.tooltip:Hide()
		C_GarrisonRequestLandingPageShipmentInfo();
		return
	end

	--Buildings
	local buildings = C_GarrisonGetBuildings();
	local numBuildings = #buildings
	local hasBuilding = false
	if(numBuildings > 0) then
		for i = 1, #buildings do
			local buildingID = buildings[i].buildingID;
			if ( buildingID ) then
				local name, _, _, shipmentsReady, shipmentsTotal = C_GarrisonGetLandingPageShipmentInfo(buildingID);
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
	
	--Missions
	local inProgressMissions = C_GarrisonGetInProgressMissions(LE_FOLLOWER_TYPE_GARRISON_6_0)
	local numMissions = #inProgressMissions
	if(numMissions > 0) then
		tsort(inProgressMissions, sortFunction) --Sort by time left, lowest first

		if(numBuildings > 0) then
			DT.tooltip:AddLine(" ")
		end
		DT.tooltip:AddLine(L["Mission(s) Report:"])
		for i=1, numMissions do
			local mission = inProgressMissions[i]
			local timeLeft = mission.timeLeft:match("%d")
			local r, g, b = 1, 1, 1
			if(mission.isRare) then
				r, g, b = 0.09, 0.51, 0.81
			end

			if(timeLeft and timeLeft == "0") then
				DT.tooltip:AddDoubleLine(mission.name, COMPLETE, r, g, b, 0, 1, 0)
			else
				DT.tooltip:AddDoubleLine(mission.name, mission.timeLeft, r, g, b)
			end
		end
	end

	--Naval Missions
	local inProgressShipMissions = C_GarrisonGetInProgressMissions(LE_FOLLOWER_TYPE_SHIPYARD_6_2)
	local numShipMissions = #inProgressShipMissions
	if(numShipMissions > 0) then
		tsort(inProgressShipMissions, sortFunction) --Sort by time left, lowest first

		if(numBuildings > 0 or numMissions > 0) then
			DT.tooltip:AddLine(" ")
		end
		DT.tooltip:AddLine(L["Naval Mission(s) Report:"])
		for i=1, numShipMissions do
			local mission = inProgressShipMissions[i]
			local timeLeft = mission.timeLeft:match("%d")
			local r, g, b = 1, 1, 1
			if(mission.isRare) then
				r, g, b = 0.09, 0.51, 0.81
			end

			if(timeLeft and timeLeft == "0") then
				DT.tooltip:AddDoubleLine(mission.name, COMPLETE, r, g, b, 0, 1, 0)
			else
				DT.tooltip:AddDoubleLine(mission.name, mission.timeLeft, r, g, b)
			end
		end
	end

	if(hasBuilding == true or numMissions > 0 or numShipMissions > 0) then
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

	local _, numGarrisonResources = GetCurrencyInfo(GARRISON_CURRENCY)
	local _, numOil = GetCurrencyInfo(OIL_CURRENCY)
	self.text:SetFormattedText("%s %s %s %s", GARRISON_ICON, numGarrisonResources, OIL_ICON, numOil)
end

DT:RegisterDatatext('Garrison', {"PLAYER_ENTERING_WORLD", "CURRENCY_DISPLAY_UPDATE", "GARRISON_LANDINGPAGE_SHIPMENTS"}, OnEvent, nil, GarrisonLandingPage_Toggle, OnEnter)
