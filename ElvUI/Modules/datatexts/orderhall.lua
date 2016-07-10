local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format = string.format
local tsort = table.sort
--WoW API / Variables
local GetCurrencyInfo = GetCurrencyInfo
local C_GarrisonGetInProgressMissions = C_Garrison.GetInProgressMissions
local COMPLETE = COMPLETE
local LE_FOLLOWER_TYPE_GARRISON_7_0 = LE_FOLLOWER_TYPE_GARRISON_7_0

local GARRISON_CURRENCY = 1220
local GARRISON_ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", select(3, GetCurrencyInfo(GARRISON_CURRENCY)), 16, 16)

local function sortFunction(a, b)
	return a.missionEndTime < b.missionEndTime
end

local function OnEnter(self, _, noUpdate)
	--[[DT:SetupTooltip(self)

	if(not noUpdate) then
		DT.tooltip:Hide()
		return
	end

	--Missions
	local inProgressMissions = C_GarrisonGetInProgressMissions(LE_FOLLOWER_TYPE_GARRISON_7_0)
	local numMissions = #inProgressMissions
	if(numMissions > 0) then
		tsort(inProgressMissions, sortFunction) --Sort by time left, lowest first

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
	end]]
end

local function OnEvent(self, event, ...)
	--[[if(event == "GARRISON_LANDINGPAGE_SHIPMENTS") then
		if(GetMouseFocus() == self) then
			OnEnter(self, nil, true)
		end

		return
	end]]

	local _, numGarrisonResources = GetCurrencyInfo(GARRISON_CURRENCY)
	self.text:SetFormattedText("%s %s", GARRISON_ICON, numGarrisonResources)
end

DT:RegisterDatatext('Orderhall', {"PLAYER_ENTERING_WORLD", "CURRENCY_DISPLAY_UPDATE", "GARRISON_LANDINGPAGE_SHIPMENTS"}, OnEvent, nil, GarrisonLandingPage_Toggle, OnEnter)
