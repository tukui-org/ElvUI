local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local next, wipe, ipairs = next, wipe, ipairs
local format, sort, pairs, select = format, sort, pairs, select
local GetMouseFocus = GetMouseFocus
local HideUIPanel = HideUIPanel
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local BreakUpLargeNumbers = BreakUpLargeNumbers
local ShowGarrisonLandingPage = ShowGarrisonLandingPage
local C_Garrison_HasGarrison = C_Garrison.HasGarrison
local C_Garrison_GetBuildings = C_Garrison.GetBuildings
local C_Garrison_GetInProgressMissions = C_Garrison.GetInProgressMissions
local C_Garrison_GetLandingPageShipmentInfo = C_Garrison.GetLandingPageShipmentInfo
local C_Garrison_GetLandingPageGarrisonType = C_Garrison.GetLandingPageGarrisonType
local C_Garrison_GetCompleteTalent = C_Garrison.GetCompleteTalent
local C_Garrison_GetFollowerShipments = C_Garrison.GetFollowerShipments
local C_Garrison_GetLandingPageShipmentInfoByContainerID = C_Garrison.GetLandingPageShipmentInfoByContainerID
local C_Garrison_RequestLandingPageShipmentInfo = C_Garrison.RequestLandingPageShipmentInfo
local C_Garrison_GetCompleteMissions = C_Garrison.GetCompleteMissions
local C_Garrison_GetLooseShipments = C_Garrison.GetLooseShipments
local C_Garrison_GetTalentTreeIDsByClassID = C_Garrison.GetTalentTreeIDsByClassID
local C_Garrison_GetTalentTreeInfo = C_Garrison.GetTalentTreeInfo
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local C_IslandsQueue_GetIslandsWeeklyQuestID = C_IslandsQueue.GetIslandsWeeklyQuestID
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_Covenants_GetActiveCovenantID = C_Covenants.GetActiveCovenantID
local C_CovenantCallings_AreCallingsUnlocked = C_CovenantCallings.AreCallingsUnlocked
local CovenantCalling_Create = CovenantCalling_Create
local GetMaxLevelForExpansionLevel = GetMaxLevelForExpansionLevel
local GetQuestObjectiveInfo = GetQuestObjectiveInfo
local SecondsToTime = SecondsToTime
local IsAltKeyDown = IsAltKeyDown

local GARRISON_LANDING_NEXT = GARRISON_LANDING_NEXT
local CAPACITANCE_WORK_ORDERS = CAPACITANCE_WORK_ORDERS
local FOLLOWERLIST_LABEL_TROOPS = FOLLOWERLIST_LABEL_TROOPS
local GARRISON_EMPTY_IN_PROGRESS_LIST = GARRISON_EMPTY_IN_PROGRESS_LIST
local GARRISON_LANDING_SHIPMENT_COUNT = GARRISON_LANDING_SHIPMENT_COUNT
local GOAL_COMPLETED = GOAL_COMPLETED
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local ISLANDS_HEADER = ISLANDS_HEADER
local ISLANDS_QUEUE_FRAME_TITLE = ISLANDS_QUEUE_FRAME_TITLE
local ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS = ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS
local LE_EXPANSION_BATTLE_FOR_AZEROTH = LE_EXPANSION_BATTLE_FOR_AZEROTH
local GARRISONFOLLOWERTYPE_6_0 = Enum.GarrisonFollowerType.FollowerType_6_0
local GARRISONFOLLOWERTYPE_7_0 = Enum.GarrisonFollowerType.FollowerType_7_0
local GARRISONFOLLOWERTYPE_8_0 = Enum.GarrisonFollowerType.FollowerType_8_0
local GARRISONFOLLOWERTYPE_6_2 = Enum.GarrisonFollowerType.FollowerType_6_2
local GARRISONFOLLOWERTYPE_9_0 = Enum.GarrisonFollowerType.FollowerType_9_0
local GARRISONTYPE_6_0 = Enum.GarrisonType.Type_6_0
local GARRISONTYPE_7_0 = Enum.GarrisonType.Type_7_0
local GARRISONTYPE_8_0 = Enum.GarrisonType.Type_8_0
local GARRISONTYPE_9_0 = Enum.GarrisonType.Type_9_0
local RESEARCH_TIME_LABEL = RESEARCH_TIME_LABEL
local DATE_COMPLETED = DATE_COMPLETED:gsub('(%%s)', '|cFF33FF33%1|r') -- 'Completed: |cFF33FF33%s|r'
local EXPANSION_NAME5 = EXPANSION_NAME5 -- 'Warlords of Draenor'
local EXPANSION_NAME6 = EXPANSION_NAME6 -- 'Legion'
local EXPANSION_NAME7 = EXPANSION_NAME7 -- 'Battle for Azeroth'
local EXPANSION_NAME8 = EXPANSION_NAME8 -- 'Shadowlands'

local MAIN_CURRENCY = 1813
local iconString = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
local numMissions = 0
local callingsData = {}
local covenantTreeIDs = {
	[1] = {308, 312, 316, 320, 327},
	[2] = {309, 314, 317, 324, 326},
	[3] = {307, 311, 315, 319, 328},
	[4] = {310, 313, 318, 321, 329}
}

local function sortFunction(a, b)
	return a.missionEndTime < b.missionEndTime
end

local function LandingPage(_, ...)
	if not C_Garrison_HasGarrison(...) then
		return
	end

	if _G.GarrisonLandingPage then
		HideUIPanel(_G.GarrisonLandingPage)

		for _, frame in pairs({ 'SoulbindPanel', 'CovenantCallings', 'ArdenwealdGardeningPanel' }) do
			if _G.GarrisonLandingPage[frame] then
				_G.GarrisonLandingPage[frame]:Hide()
			end
		end
	end

	ShowGarrisonLandingPage(...)
end

local menuList = {
	{text = _G.GARRISON_LANDING_PAGE_TITLE,			 func = LandingPage, arg1 = GARRISONTYPE_6_0, notCheckable = true},
	{text = _G.ORDER_HALL_LANDING_PAGE_TITLE,		 func = LandingPage, arg1 = GARRISONTYPE_7_0, notCheckable = true},
	{text = _G.WAR_CAMPAIGN,						 func = LandingPage, arg1 = GARRISONTYPE_8_0, notCheckable = true},
	{text = _G.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, func = LandingPage, arg1 = GARRISONTYPE_9_0, notCheckable = true},
}

local data = {}
local function AddInProgressMissions(garrisonType)
	wipe(data)

	C_Garrison_GetInProgressMissions(data, garrisonType)

	if next(data) then
		sort(data, sortFunction) -- Sort by time left, lowest first

		for _, mission in ipairs(data) do
			local timeLeft = mission.timeLeftSeconds
			local r, g, b = 1, 1, 1
			if mission.isRare then
				r, g, b = 0.09, 0.51, 0.81
			end

			if timeLeft and timeLeft == 0 then
				DT.tooltip:AddDoubleLine(mission.name, GOAL_COMPLETED, r, g, b, GREEN_FONT_COLOR:GetRGB())
			else
				DT.tooltip:AddDoubleLine(mission.name, SecondsToTime(timeLeft), r, g, b, 1, 1, 1)
			end
		end
	else
		DT.tooltip:AddLine(GARRISON_EMPTY_IN_PROGRESS_LIST, 1, 1, 1)
	end
end

local function AddFollowerInfo(garrisonType)
	data = C_Garrison_GetFollowerShipments(garrisonType)

	if next(data) then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(FOLLOWERLIST_LABEL_TROOPS) -- 'Troops'
		for _, followerShipments in ipairs(data) do
			local name, _, _, shipmentsReady, shipmentsTotal, _, _, timeleftString = C_Garrison_GetLandingPageShipmentInfoByContainerID(followerShipments)
			if name and shipmentsReady and shipmentsTotal then
				if timeleftString then
					DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal) .. ' ' .. format(GARRISON_LANDING_NEXT,timeleftString), 1, 1, 1, 1, 1, 1)
				else
					DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1, 1, 1, 1)
				end
			end
		end
	end
end

local covenantInfo = {}
local function AddTalentInfo(garrisonType, currentCovenant)
	if garrisonType == GARRISONTYPE_9_0 then
		local current = covenantTreeIDs[currentCovenant]
		if current then
			wipe(covenantInfo)
			data = E:CopyTable(covenantInfo, current)
		else
			wipe(data)
		end
	else
		data = C_Garrison_GetTalentTreeIDsByClassID(garrisonType, E.myClassID)
	end

	if next(data) then
		-- This is a talent that has completed, but has not been seen in the talent UI yet.
		-- No longer provide relevant output in SL. Still used by old content.
		local completeTalentID = C_Garrison_GetCompleteTalent(garrisonType)
		if completeTalentID > 0 then
			DT.tooltip:AddLine(' ')
			DT.tooltip:AddLine(RESEARCH_TIME_LABEL) -- 'Research Time:'

			for _, treeID in ipairs(data) do
				local treeInfo = C_Garrison_GetTalentTreeInfo(treeID)
				for _, talent in ipairs(treeInfo.talents) do
					if talent.isBeingResearched or (talent.id == completeTalentID and garrisonType ~= GARRISONTYPE_9_0)then
						if talent.timeRemaining and talent.timeRemaining == 0 then
							DT.tooltip:AddDoubleLine(talent.name, GOAL_COMPLETED, 1, 1, 1, GREEN_FONT_COLOR:GetRGB())
						else
							DT.tooltip:AddDoubleLine(talent.name, SecondsToTime(talent.timeRemaining), 1, 1, 1, 1, 1, 1)
						end
					end
				end
			end
		end
	end
end

local function GetInfo(id)
	local info = C_CurrencyInfo_GetCurrencyInfo(id)
	return info.quantity, info.name, (info.iconFileID and format(iconString, info.iconFileID)) or '136012'
end

local function AddInfo(id)
	local quantity, _, icon = GetInfo(id)
	return format('%s %s', icon, BreakUpLargeNumbers(quantity))
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(EXPANSION_NAME8, 1, .5, 0)
	DT.tooltip:AddDoubleLine(L["Mission(s) Report:"], AddInfo(1813), nil, nil, nil, 1, 1, 1)
	AddInProgressMissions(GARRISONFOLLOWERTYPE_9_0)

	if C_CovenantCallings_AreCallingsUnlocked() then
		local questNum = 0
		for _, calling in ipairs(callingsData) do
			local callingObj = CovenantCalling_Create(calling)
			if callingObj:GetState() == 0 then
				questNum = questNum + 1
			end
		end
		if questNum > 0 then
			DT.tooltip:AddLine(' ')
			DT.tooltip:AddLine(format('%s %s', questNum, L["Calling Quest(s) available."]))
		end
	end

	local currentCovenant = C_Covenants_GetActiveCovenantID()
	if currentCovenant and currentCovenant > 0 then
		AddTalentInfo(GARRISONTYPE_9_0, currentCovenant)
	end

	if IsShiftKeyDown() then
		-- Battle for Azeroth
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(EXPANSION_NAME7, 1, .5, 0)
		DT.tooltip:AddDoubleLine(L["Mission(s) Report:"], AddInfo(1560), nil, nil, nil, 1, 1, 1)
		AddInProgressMissions(GARRISONFOLLOWERTYPE_8_0)

		-- Island Expeditions
		if E.mylevel >= GetMaxLevelForExpansionLevel(LE_EXPANSION_BATTLE_FOR_AZEROTH) then
			local questID = C_IslandsQueue_GetIslandsWeeklyQuestID()
			if questID then
				local _, _, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, 1, false)
				local text, r1, g1, b1

				if finished or C_QuestLog_IsQuestFlaggedCompleted(questID) then
					text = GOAL_COMPLETED
					r1, g1, b1 = GREEN_FONT_COLOR:GetRGB()
				else
					text = format(ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS, numFulfilled, numRequired)
					r1, g1, b1 = 1, 1, 1
				end

				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(ISLANDS_HEADER .. ':')
				DT.tooltip:AddDoubleLine(ISLANDS_QUEUE_FRAME_TITLE, text, 1, 1, 1, r1, g1, b1)
			end
		end

		AddFollowerInfo(GARRISONTYPE_7_0)
		AddTalentInfo(GARRISONTYPE_7_0)

		-- Legion
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(EXPANSION_NAME6, 1, .5, 0)
		DT.tooltip:AddDoubleLine(L["Mission(s) Report:"], AddInfo(1220), nil, nil, nil, 1, 1, 1)

		AddInProgressMissions(GARRISONFOLLOWERTYPE_7_0)
		AddFollowerInfo(GARRISONTYPE_7_0)

		-- 'Loose Work Orders' (i.e. research, equipment)
		data = C_Garrison_GetLooseShipments(GARRISONTYPE_7_0)
		if next(data) then
			DT.tooltip:AddLine(CAPACITANCE_WORK_ORDERS) -- 'Work Orders'

			for _, looseShipments in ipairs(data) do
				local name, _, _, shipmentsReady, shipmentsTotal, _, _, timeleftString = C_Garrison_GetLandingPageShipmentInfoByContainerID(looseShipments)
				if name then
					if timeleftString then
						DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal) .. ' ' .. format(GARRISON_LANDING_NEXT,timeleftString), 1, 1, 1, 1, 1, 1)
					else
						DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1, 1, 1, 1)
					end
				end
			end
		end

		AddTalentInfo(GARRISONTYPE_7_0)

		-- Warlords of Draenor
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(EXPANSION_NAME5, 1, .5, 0)
		DT.tooltip:AddDoubleLine(L["Mission(s) Report:"], AddInfo(824), nil, nil, nil, 1, 1, 1)
		AddInProgressMissions(GARRISONFOLLOWERTYPE_6_0)

		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(L["Naval Mission(s) Report:"], AddInfo(1101), nil, nil, nil, 1, 1 , 1)
		AddInProgressMissions(GARRISONFOLLOWERTYPE_6_2)

		--Buildings
		data = C_Garrison_GetBuildings(GARRISONTYPE_6_0)
		if next(data) then
			local AddLine = true
			for _, buildings in ipairs(data) do
				local name, _, _, shipmentsReady, shipmentsTotal, _, _, timeleftString = C_Garrison_GetLandingPageShipmentInfo(buildings.buildingID)
				if name and shipmentsTotal then
					if AddLine then
						DT.tooltip:AddLine(' ')
						DT.tooltip:AddLine(L["Building(s) Report:"])
						AddLine = false
					end

					if timeleftString then
						DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal) .. ' ' .. format(GARRISON_LANDING_NEXT,timeleftString), 1, 1, 1, 1, 1, 1)
					else
						DT.tooltip:AddDoubleLine(name, format(GARRISON_LANDING_SHIPMENT_COUNT, shipmentsReady, shipmentsTotal), 1, 1, 1, 1, 1, 1)
					end
				end
			end
		end
	else
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine('Hold Shift - Show Previous Expansions', .66, .66, .66)
	end

	DT.tooltip:Show()
end

local function OnClick(self, btn)
	if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end

	if btn == 'RightButton' then
		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menuList, DT.EasyMenu, nil, nil, nil, 'MENU')
	else
		if _G.GarrisonLandingPage and _G.GarrisonLandingPage:IsShown() then
			HideUIPanel(_G.GarrisonLandingPage)
		else
			LandingPage(nil, C_Garrison_GetLandingPageGarrisonType())
		end
	end
end

local function OnEvent(self, event, ...)
	if event == 'CURRENCY_DISPLAY_UPDATE' and select(1, ...) ~= MAIN_CURRENCY then
		return
	end

	if event == 'COVENANT_CALLINGS_UPDATED' then
		wipe(callingsData)
		callingsData = ...
	end

	if event == 'GARRISON_SHIPMENT_RECEIVED' or (event == 'SHIPMENT_UPDATE' and select(1, ...) == true) then
		C_Garrison_RequestLandingPageShipmentInfo()
	end

	if event == 'GARRISON_MISSION_NPC_OPENED' then
		self:RegisterEvent('GARRISON_MISSION_LIST_UPDATE')
	elseif event == 'GARRISON_MISSION_NPC_CLOSED' then
		self:UnregisterEvent('GARRISON_MISSION_LIST_UPDATE')
	end

	if event == 'GARRISON_LANDINGPAGE_SHIPMENTS' or event == 'GARRISON_MISSION_FINISHED' or event == 'GARRISON_MISSION_NPC_CLOSED' or event == 'GARRISON_MISSION_LIST_UPDATE' then
		numMissions = #C_Garrison_GetCompleteMissions(GARRISONFOLLOWERTYPE_9_0)
		+ #C_Garrison_GetCompleteMissions(GARRISONFOLLOWERTYPE_8_0)
		+ #C_Garrison_GetCompleteMissions(GARRISONFOLLOWERTYPE_7_0)
		+ #C_Garrison_GetCompleteMissions(GARRISONFOLLOWERTYPE_6_0)
		+ #C_Garrison_GetCompleteMissions(GARRISONFOLLOWERTYPE_6_2)
	end

	if numMissions > 0 then
		self.text:SetFormattedText(DATE_COMPLETED, numMissions)
	else
		self.text:SetText(AddInfo(MAIN_CURRENCY))
	end

	if event == 'MODIFIER_STATE_CHANGED' and not IsAltKeyDown() and GetMouseFocus() == self then
		OnEnter(self)
	end
end

DT:RegisterDatatext('Missions', nil, {'CURRENCY_DISPLAY_UPDATE', 'GARRISON_LANDINGPAGE_SHIPMENTS', 'GARRISON_TALENT_UPDATE', 'GARRISON_TALENT_COMPLETE', 'GARRISON_SHIPMENT_RECEIVED', 'SHIPMENT_UPDATE', 'GARRISON_MISSION_FINISHED', 'GARRISON_MISSION_NPC_CLOSED', 'GARRISON_MISSION_NPC_OPENED', 'MODIFIER_STATE_CHANGED', 'COVENANT_CALLINGS_UPDATED'}, OnEvent, nil, OnClick, OnEnter, nil, _G.GARRISON_MISSIONS)
