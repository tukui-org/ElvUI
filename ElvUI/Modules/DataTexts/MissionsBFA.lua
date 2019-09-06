local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

--Lua functions
local _G = _G
local format, sort, ipairs = format, sort, ipairs
local select, unpack = select, unpack
--WoW API / Variables
local GetCurrencyInfo = GetCurrencyInfo
local GetMaxLevelForExpansionLevel = GetMaxLevelForExpansionLevel
local GetMouseFocus = GetMouseFocus
local GetQuestObjectiveInfo = GetQuestObjectiveInfo
local GOAL_COMPLETED = GOAL_COMPLETED
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local HideUIPanel = HideUIPanel
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted
local SecondsToTime = SecondsToTime
local ShowGarrisonLandingPage = ShowGarrisonLandingPage
local C_Garrison_GetCompleteTalent = C_Garrison.GetCompleteTalent
local C_Garrison_GetFollowerShipments = C_Garrison.GetFollowerShipments
local C_Garrison_GetInProgressMissions = C_Garrison.GetInProgressMissions
local C_Garrison_GetLandingPageShipmentInfoByContainerID = C_Garrison.GetLandingPageShipmentInfoByContainerID
local C_Garrison_GetTalentTreeIDsByClassID = C_Garrison.GetTalentTreeIDsByClassID
local C_Garrison_GetTalentTreeInfoForID = C_Garrison.GetTalentTreeInfoForID
local C_Garrison_HasGarrison = C_Garrison.HasGarrison
local C_Garrison_RequestLandingPageShipmentInfo = C_Garrison.RequestLandingPageShipmentInfo
local C_IslandsQueue_GetIslandsWeeklyQuestID = C_IslandsQueue.GetIslandsWeeklyQuestID
local LE_EXPANSION_BATTLE_FOR_AZEROTH = LE_EXPANSION_BATTLE_FOR_AZEROTH
local LE_FOLLOWER_TYPE_GARRISON_8_0 = LE_FOLLOWER_TYPE_GARRISON_8_0
local LE_GARRISON_TYPE_8_0 = LE_GARRISON_TYPE_8_0
local ISLANDS_HEADER = ISLANDS_HEADER
local ISLANDS_QUEUE_FRAME_TITLE = ISLANDS_QUEUE_FRAME_TITLE
local ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS = ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS
local FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS
local GARRISON_LANDING_SHIPMENT_COUNT = GARRISON_LANDING_SHIPMENT_COUNT
local RESEARCH_TIME_LABEL = RESEARCH_TIME_LABEL
local InCombatLockdown = InCombatLockdown

local Widget_IDs, lastPanel = {
	["Alliance"] = {
		56156, -- A Tempered Blade
		{L["Farseer Ori"], 1940},
		{L["Hunter Akana"], 1613},
		{L["Bladesman Inowari"], 1966}
	},
	["Horde"] = {
		55500, -- Save a Friend
		{L["Neri Sharpfin"], 1621},
		{L["Poen Gillbrack"], 1622},
		{L["Vim Brineheart"], 1920}
	}
}

local WARRESOURCES_CURRENCY = 1560
local WARRESOURCES_ICON = format("|T%s:16:16:0:0:64:64:4:60:4:60|t", select(3, GetCurrencyInfo(WARRESOURCES_CURRENCY)))
local BODYGUARD_LEVEL_XP_FORMAT = L["Rank"] .. " %d (%d/%d)"
local NAZJATAR_MAP_ID = 1355

local function sortFunction(a, b)
	return a.missionEndTime < b.missionEndTime
end

local function OnEnter(self, _, noUpdate)
	DT:SetupTooltip(self)

	if (not noUpdate) then
		DT.tooltip:Hide()
		C_Garrison_RequestLandingPageShipmentInfo()
		return
	end

	local firstLine = true

	--Missions
	local inProgressMissions = {}
	C_Garrison_GetInProgressMissions(inProgressMissions, LE_FOLLOWER_TYPE_GARRISON_8_0)
	DT.tooltip:AddLine(L["Mission(s) Report:"]) -- always show the header
	local numMissions = #inProgressMissions
	if (numMissions > 0) then
		sort(inProgressMissions, sortFunction) --Sort by time left, lowest first

		firstLine = false
		for i = 1, numMissions do
			local mission = inProgressMissions[i]
			local timeLeft = mission.timeLeft:match("%d")
			local r, g, b = 1, 1, 1
			if (mission.isRare) then
				r, g, b = 0.09, 0.51, 0.81
			end

			if (timeLeft and timeLeft == "0") then
				DT.tooltip:AddDoubleLine(mission.name, GOAL_COMPLETED, r, g, b, GREEN_FONT_COLOR:GetRGB())
			else
				DT.tooltip:AddDoubleLine(mission.name, mission.timeLeft, r, g, b)
			end
		end
	end

	-- Troop Work Orders
	local followerShipments = C_Garrison_GetFollowerShipments(LE_GARRISON_TYPE_8_0)
	local hasFollowers = false
	if (followerShipments) then
		for i = 1, #followerShipments do
			local name, _, _, shipmentsReady, shipmentsTotal, _, _, timeleftString =
				C_Garrison_GetLandingPageShipmentInfoByContainerID(followerShipments[i])
			if (name and shipmentsReady and shipmentsTotal) then
				if (hasFollowers == false) then
					if not firstLine then
						DT.tooltip:AddLine(" ")
					end
					firstLine = false
					DT.tooltip:AddLine(FOLLOWERLIST_LABEL_TROOPS) -- "Troops"
					hasFollowers = true
				end

				timeleftString = (timeleftString and timeleftString .. " ") or ""

				DT.tooltip:AddDoubleLine(
					name,
					timeleftString .. format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal),
					1, 1, 1
				)
			end
		end
	end

	-- Talents
	local talentTreeIDs = C_Garrison_GetTalentTreeIDsByClassID(LE_GARRISON_TYPE_8_0, E.myClassID)
	local hasTalent = false
	if (talentTreeIDs) then
		-- this is a talent that has completed, but has not been seen in the talent UI yet.
		local completeTalentID = C_Garrison_GetCompleteTalent(LE_GARRISON_TYPE_8_0)
		for _, treeID in ipairs(talentTreeIDs) do
			local _, _, tree = C_Garrison_GetTalentTreeInfoForID(treeID)
			for _, talent in ipairs(tree) do
				if talent.isBeingResearched or talent.id == completeTalentID then
					if not firstLine then
						DT.tooltip:AddLine(" ")
					end
					firstLine = false
					DT.tooltip:AddLine(RESEARCH_TIME_LABEL) -- "Research Time:"
					if (talent.researchTimeRemaining and talent.researchTimeRemaining == 0) then
						DT.tooltip:AddDoubleLine(talent.name, GOAL_COMPLETED, 1, 1, 1, GREEN_FONT_COLOR:GetRGB())
					else
						DT.tooltip:AddDoubleLine(talent.name, SecondsToTime(talent.researchTimeRemaining), 1, 1, 1)
					end

					hasTalent = true
				end
			end
		end
	end

	-- Island Expeditions
	local hasIsland = false
	if (E.mylevel >= GetMaxLevelForExpansionLevel(LE_EXPANSION_BATTLE_FOR_AZEROTH)) then
		local questID = C_IslandsQueue_GetIslandsWeeklyQuestID()
		if questID then
			local _, _, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, 1, false)
			local text, r1, g1, b1

			if finished or IsQuestFlaggedCompleted(questID) then
				text = GOAL_COMPLETED
				r1, g1, b1 = GREEN_FONT_COLOR:GetRGB()
			else
				text = ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS:format(numFulfilled, numRequired)
				r1, g1, b1 = 1, 1, 1
			end

			DT.tooltip:AddLine(" ")
			DT.tooltip:AddLine(ISLANDS_HEADER .. ":")
			DT.tooltip:AddDoubleLine(ISLANDS_QUEUE_FRAME_TITLE, text, 1, 1, 1, r1, g1, b1)
			hasIsland = true
		end
	end

	local hasNazjatarBodyguardXP = false
	local widgetGroup = Widget_IDs[E.myfaction]
	if (E.MapInfo.mapID == NAZJATAR_MAP_ID and widgetGroup and IsQuestFlaggedCompleted(widgetGroup[1])) then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddLine(L["Nazjatar Follower XP"])
		for i = 2, 4 do
			local npcName, widgetID = unpack(widgetGroup[i])
			local rank, cur, toNext, _, isMax = E:GetNazjatarBodyguardXP(widgetID)
			if npcName and rank then
				DT.tooltip:AddDoubleLine(npcName, (isMax and L["Max Rank"]) or BODYGUARD_LEVEL_XP_FORMAT:format(rank, cur, toNext), 1, 1, 1)
			end
		end
		hasNazjatarBodyguardXP = true
	end

	if (numMissions > 0 or hasFollowers or hasTalent or hasIsland or hasNazjatarBodyguardXP) then
		DT.tooltip:Show()
	else
		DT.tooltip:Hide()
	end
end

local function OnClick()
	if InCombatLockdown() then
		_G.UIErrorsFrame:AddMessage(E.InfoColor .. _G.ERR_NOT_IN_COMBAT)
		return
	end

	if not (C_Garrison_HasGarrison(LE_GARRISON_TYPE_8_0)) then
		return
	end

	local GarrisonLandingPage = _G.GarrisonLandingPage
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
	if (event == "GARRISON_LANDINGPAGE_SHIPMENTS") then
		if (GetMouseFocus() == self) then
			OnEnter(self, nil, true)
		end
		return
	end

	local _, numGarrisonResources = GetCurrencyInfo(WARRESOURCES_CURRENCY)
	self.text:SetFormattedText("%s %s", WARRESOURCES_ICON, numGarrisonResources)

	lastPanel = self
end

local function ValueColorUpdate()
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("BfA Missions", {"PLAYER_ENTERING_WORLD", "CURRENCY_DISPLAY_UPDATE", "GARRISON_LANDINGPAGE_SHIPMENTS"}, OnEvent, nil, OnClick, OnEnter, nil, L["BfA Missions"])
