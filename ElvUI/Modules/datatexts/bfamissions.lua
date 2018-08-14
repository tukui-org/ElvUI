local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format = string.format
local tsort = table.sort
local ipairs = ipairs
--WoW API / Variables
local C_Garrison_GetFollowerShipments = C_Garrison.GetFollowerShipments
local C_Garrison_GetInProgressMissions = C_Garrison.GetInProgressMissions
local C_Garrison_RequestLandingPageShipmentInfo = C_Garrison.RequestLandingPageShipmentInfo
local C_Garrison_GetLandingPageShipmentInfoByContainerID = C_Garrison.GetLandingPageShipmentInfoByContainerID
local C_Garrison_GetTalentTreeIDsByClassID = C_Garrison.GetTalentTreeIDsByClassID
local C_Garrison_GetTalentTreeInfoForID = C_Garrison.GetTalentTreeInfoForID
local C_Garrison_GetCompleteTalent = C_Garrison.GetCompleteTalent
local C_Garrison_HasGarrison = C_Garrison.HasGarrison
local ShowGarrisonLandingPage = ShowGarrisonLandingPage
local HideUIPanel = HideUIPanel
local GetCurrencyInfo = GetCurrencyInfo
local GetMouseFocus = GetMouseFocus
local SecondsToTime = SecondsToTime
local COMPLETE = COMPLETE
local RESEARCH_TIME_LABEL = RESEARCH_TIME_LABEL
local GARRISON_LANDING_SHIPMENT_COUNT = GARRISON_LANDING_SHIPMENT_COUNT
local FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS
local LE_FOLLOWER_TYPE_GARRISON_8_0 = LE_FOLLOWER_TYPE_GARRISON_8_0
local LE_GARRISON_TYPE_8_0 = LE_GARRISON_TYPE_8_0

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GarrisonLandingPage

local WARRESOURCES_CURRENCY = 1560
local WARRESOURCES_ICON = format("|T%s:16:16:0:0:64:64:4:60:4:60|t", select(3, GetCurrencyInfo(WARRESOURCES_CURRENCY)))

local function sortFunction(a, b)
	return a.missionEndTime < b.missionEndTime
end

local function OnEnter(self, _, noUpdate)
	DT:SetupTooltip(self)

	if(not noUpdate) then
		DT.tooltip:Hide()
		C_Garrison_RequestLandingPageShipmentInfo()
		return
	end

	local firstLine = true

	--Missions
	local inProgressMissions = {}
	C_Garrison_GetInProgressMissions(inProgressMissions, LE_FOLLOWER_TYPE_GARRISON_8_0)
	local numMissions = #inProgressMissions
	if(numMissions > 0) then
		tsort(inProgressMissions, sortFunction) --Sort by time left, lowest first

		firstLine = false
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

	-- Troop Work Orders
	local followerShipments = C_Garrison_GetFollowerShipments(LE_GARRISON_TYPE_8_0)
	local hasFollowers = false
	if(followerShipments) then
		for i = 1, #followerShipments do
			local name, _, _, shipmentsReady, shipmentsTotal, _, _, timeleftString = C_Garrison_GetLandingPageShipmentInfoByContainerID(followerShipments[i])
			if(name and shipmentsReady and shipmentsTotal) then
				if(hasFollowers == false) then
					if not firstLine then
						DT.tooltip:AddLine(" ")
					end
					firstLine = false
					DT.tooltip:AddLine(FOLLOWERLIST_LABEL_TROOPS) -- "Troops"
					hasFollowers = true
				end

				if timeleftString then
					timeleftString = timeleftString.." "
				else
					timeleftString = ""
				end
				DT.tooltip:AddDoubleLine(name, timeleftString..format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1)
			end
		end
	end

	-- Talents
	local talentTreeIDs = C_Garrison_GetTalentTreeIDsByClassID(LE_GARRISON_TYPE_8_0, E.myClassID)
	local hasTalent = false
	if(talentTreeIDs) then
		-- this is a talent that has completed, but has not been seen in the talent UI yet.
		local completeTalentID = C_Garrison_GetCompleteTalent(LE_GARRISON_TYPE_8_0)
		for _, treeID in ipairs(talentTreeIDs) do
			local _, _, tree = C_Garrison_GetTalentTreeInfoForID(treeID)
			for _, talent in ipairs(tree) do
				local showTalent = false
				if(talent.isBeingResearched) then
					showTalent = true
				end
				if(talent.id == completeTalentID) then
					showTalent = true
				end
				if(showTalent) then
					if not firstLine then
						DT.tooltip:AddLine(" ")
					end
					firstLine = false
					DT.tooltip:AddLine(RESEARCH_TIME_LABEL) -- "Research Time:"
					if(talent.researchTimeRemaining and talent.researchTimeRemaining == 0) then
						DT.tooltip:AddDoubleLine(talent.name, COMPLETE, 1, 1, 1)
					else
						DT.tooltip:AddDoubleLine(talent.name, SecondsToTime(talent.researchTimeRemaining), 1, 1, 1)
					end

					hasTalent = true
				end
			end
		end
	end

	if(numMissions > 0 or hasFollowers or hasTalent) then
		DT.tooltip:Show()
	else
		DT.tooltip:Hide()
	end
end

local function OnClick()
	if not (C_Garrison_HasGarrison(LE_GARRISON_TYPE_8_0)) then
		return
	end

	local isShown = GarrisonLandingPage and GarrisonLandingPage:IsShown()
	if (not isShown) then
		ShowGarrisonLandingPage(LE_GARRISON_TYPE_8_0)
	elseif (GarrisonLandingPage) then
		local currentGarrType = GarrisonLandingPage.garrTypeID
		HideUIPanel(GarrisonLandingPage)
		if (currentGarrType ~= LE_GARRISON_TYPE_8_0) then
			ShowGarrisonLandingPage(LE_GARRISON_TYPE_8_0)
		end
	end
end

local function OnEvent(self, event)
	if(event == "GARRISON_LANDINGPAGE_SHIPMENTS") then
		if(GetMouseFocus() == self) then
			OnEnter(self, nil, true)
		end
		return
	end

	local _, numGarrisonResources = GetCurrencyInfo(WARRESOURCES_CURRENCY)
	self.text:SetFormattedText("%s %s", WARRESOURCES_ICON, numGarrisonResources)
end

DT:RegisterDatatext('BfA Missions', {"PLAYER_ENTERING_WORLD", "CURRENCY_DISPLAY_UPDATE", "GARRISON_LANDINGPAGE_SHIPMENTS"}, OnEvent, nil, OnClick, OnEnter, nil, L["BfA Missions"])
