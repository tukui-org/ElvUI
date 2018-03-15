local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local select, ipairs = select, ipairs
local format = string.format
local tsort = table.sort
--WoW API / Variables
local C_Garrison_GetCompleteTalent = C_Garrison.GetCompleteTalent
local C_Garrison_GetFollowerShipments = C_Garrison.GetFollowerShipments
local C_Garrison_GetInProgressMissions = C_Garrison.GetInProgressMissions
local C_Garrison_GetLandingPageShipmentInfoByContainerID = C_Garrison.GetLandingPageShipmentInfoByContainerID
local C_Garrison_GetLooseShipments = C_Garrison.GetLooseShipments
local C_Garrison_GetTalentTreeIDsByClassID = C_Garrison.GetTalentTreeIDsByClassID
local C_Garrison_GetTalentTreeInfoForID = C_Garrison.GetTalentTreeInfoForID
local C_Garrison_HasGarrison = C_Garrison.HasGarrison
local C_Garrison_RequestLandingPageShipmentInfo = C_Garrison.RequestLandingPageShipmentInfo
local GetCurrencyInfo = GetCurrencyInfo
local GetMouseFocus = GetMouseFocus
local HideUIPanel = HideUIPanel
local ShowGarrisonLandingPage = ShowGarrisonLandingPage
local CAPACITANCE_WORK_ORDERS = CAPACITANCE_WORK_ORDERS
local COMPLETE = COMPLETE
local FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS
local GARRISON_LANDING_SHIPMENT_COUNT = GARRISON_LANDING_SHIPMENT_COUNT
local GARRISON_TALENT_ORDER_ADVANCEMENT = GARRISON_TALENT_ORDER_ADVANCEMENT
local LE_FOLLOWER_TYPE_GARRISON_7_0 = LE_FOLLOWER_TYPE_GARRISON_7_0
local LE_GARRISON_TYPE_7_0 = LE_GARRISON_TYPE_7_0
local ORDER_HALL_MISSIONS = ORDER_HALL_MISSIONS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GarrisonLandingPage

local GARRISON_CURRENCY = 1220
local GARRISON_ICON = format("|T%s:16:16:0:0:64:64:4:60:4:60|t", select(3, GetCurrencyInfo(GARRISON_CURRENCY)))

local function sortFunction(a, b)
	return a.missionEndTime < b.missionEndTime
end

local function OnEnter(self, _, noUpdate)
	DT:SetupTooltip(self)

	if(not noUpdate) then
		DT.tooltip:Hide()
		C_Garrison_RequestLandingPageShipmentInfo();
		return
	end

	local firstLine = true

	--Missions
	local inProgressMissions = C_Garrison_GetInProgressMissions(LE_FOLLOWER_TYPE_GARRISON_7_0)
	local numMissions = (inProgressMissions and #inProgressMissions or 0)
	if(numMissions > 0) then
		tsort(inProgressMissions, sortFunction) --Sort by time left, lowest first

		DT.tooltip:AddLine(ORDER_HALL_MISSIONS) -- "Class Hall Missions"
		firstLine = false
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

	-- Troop Work Orders
	local followerShipments = C_Garrison_GetFollowerShipments(LE_GARRISON_TYPE_7_0)
	local hasFollowers = false
	if (followerShipments) then
		for i = 1, #followerShipments do
			local name, _, _, shipmentsReady, shipmentsTotal = C_Garrison_GetLandingPageShipmentInfoByContainerID(followerShipments[i])
			if ( name and shipmentsReady and shipmentsTotal ) then
				if(hasFollowers == false) then
					if not firstLine then
						DT.tooltip:AddLine(" ")
					end
					firstLine = false
					DT.tooltip:AddLine(FOLLOWERLIST_LABEL_TROOPS) -- "Troops"
					hasFollowers = true
				end

				DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1)
			end
		end
	end

	-- "Loose Work Orders" (i.e. research, equipment)
	local looseShipments = C_Garrison_GetLooseShipments(LE_GARRISON_TYPE_7_0)
	local hasLoose = false
	if (looseShipments) then
		for i = 1, #looseShipments do
			local name, _, _, shipmentsReady, shipmentsTotal = C_Garrison_GetLandingPageShipmentInfoByContainerID(looseShipments[i])
			if ( name and shipmentsReady and shipmentsTotal ) then
				if(hasLoose == false) then
					if not firstLine then
						DT.tooltip:AddLine(" ")
					end
					firstLine = false
					DT.tooltip:AddLine(CAPACITANCE_WORK_ORDERS) -- "Work Orders"
					hasLoose = true
				end

				DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1)
			end
		end
	end

	-- Talents
	local talentTreeIDs = C_Garrison_GetTalentTreeIDsByClassID(LE_GARRISON_TYPE_7_0, E.myClassID);
	local hasTalent = false
	if (talentTreeIDs) then
		-- this is a talent that has completed, but has not been seen in the talent UI yet.
		local completeTalentID = C_Garrison_GetCompleteTalent(LE_GARRISON_TYPE_7_0);
		for _, treeID in ipairs(talentTreeIDs) do
			local _, _, tree = C_Garrison_GetTalentTreeInfoForID(treeID);
			for _, talent in ipairs(tree) do
				local showTalent = false;
				if (talent.isBeingResearched) then
					showTalent = true;
				end
				if (talent.id == completeTalentID) then
					showTalent = true;
				end
				if (showTalent) then
					if not firstLine then
						DT.tooltip:AddLine(" ")
					end
					firstLine = false
					DT.tooltip:AddLine(GARRISON_TALENT_ORDER_ADVANCEMENT); -- "Order Advancement"
					DT.tooltip:AddDoubleLine(talent.name, format(GARRISON_LANDING_SHIPMENT_COUNT, talent.isBeingResearched and 0 or 1, 1), 1, 1, 1);
					hasTalent = true
				end
			end
		end
	end

	if(numMissions > 0 or hasFollowers or hasLoose or hasTalent) then
		DT.tooltip:Show()
	else
		DT.tooltip:Hide()
	end
end

local function OnClick()
	if not (C_Garrison_HasGarrison(LE_GARRISON_TYPE_7_0)) then
		return;
	end

	local isShown = GarrisonLandingPage and GarrisonLandingPage:IsShown();
	if (not isShown) then
		ShowGarrisonLandingPage(LE_GARRISON_TYPE_7_0);
	elseif (GarrisonLandingPage) then
		local currentGarrType = GarrisonLandingPage.garrTypeID;
		HideUIPanel(GarrisonLandingPage);
		if (currentGarrType ~= LE_GARRISON_TYPE_7_0) then
			ShowGarrisonLandingPage(LE_GARRISON_TYPE_7_0);
		end
	end
end

local function OnEvent(self, event)
	if(event == "GARRISON_LANDINGPAGE_SHIPMENTS" or event == "GARRISON_TALENT_UPDATE" or event == "GARRISON_TALENT_COMPLETE") then
		if(GetMouseFocus() == self) then
			OnEnter(self, nil, true)
		end

		return
	end

	local _, numGarrisonResources = GetCurrencyInfo(GARRISON_CURRENCY)
	self.text:SetFormattedText("%s %s", GARRISON_ICON, numGarrisonResources)
end

DT:RegisterDatatext('Orderhall', {"PLAYER_ENTERING_WORLD", "CURRENCY_DISPLAY_UPDATE", "GARRISON_LANDINGPAGE_SHIPMENTS", "GARRISON_TALENT_UPDATE", "GARRISON_TALENT_COMPLETE"}, OnEvent, nil, OnClick, OnEnter)
