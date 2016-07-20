local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local MAX_ACHIEVEMENT_ALERTS = MAX_ACHIEVEMENT_ALERTS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: AlertFrame, AlertFrameMover, MissingLootFrame, GroupLootContainer
-- GLOBALS: LOOT_WON_ALERT_FRAMES, LOOT_UPGRADE_ALERT_FRAMES, MONEY_WON_ALERT_FRAMES
-- GLOBALS: AchievementAlertFrame1, CriteriaAlertFrame1, ChallengeModeAlertFrame1
-- GLOBALS: DungeonCompletionAlertFrame1, StorePurchaseAlertFrame, ScenarioAlertFrame1
-- GLOBALS: GuildChallengeAlertFrame, DigsiteCompleteToastFrame, GarrisonBuildingAlertFrame
-- GLOBALS: GarrisonMissionAlertFrame, GarrisonFollowerAlertFrame, GarrisonShipFollowerAlertFrame
-- GLOBALS: GarrisonShipMissionAlertFrame, UIPARENT_MANAGED_FRAME_POSITIONS

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.UIParent)
AlertFrameHolder:Width(180)
AlertFrameHolder:Height(20)
AlertFrameHolder:Point("TOP", E.UIParent, "TOP", 0, -18)

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10
local FORCE_POSITION = false;

function E:PostAlertMove(screenQuadrant)
	local _, y = AlertFrameMover:GetCenter();
	local screenHeight = E.UIParent:GetTop();
	if y > (screenHeight / 2) then
		POSITION = 'TOP'
		ANCHOR_POINT = 'BOTTOM'
		YOFFSET = -10
		AlertFrameMover:SetText(AlertFrameMover.textString..' (Grow Down)')
	else
		POSITION = 'BOTTOM'
		ANCHOR_POINT = 'TOP'
		YOFFSET = 10
		AlertFrameMover:SetText(AlertFrameMover.textString..' (Grow Up)')
	end

	local rollBars = E:GetModule('Misc').RollBars
	if E.private.general.lootRoll then
		local lastframe, lastShownFrame
		for i, frame in pairs(rollBars) do
			frame:ClearAllPoints()
			if i ~= 1 then
				if POSITION == "TOP" then
					frame:Point("TOP", lastframe, "BOTTOM", 0, -4)
				else
					frame:Point("BOTTOM", lastframe, "TOP", 0, 4)
				end
			else
				if POSITION == "TOP" then
					frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
				else
					frame:Point("BOTTOM", AlertFrameHolder, "TOP", 0, 4)
				end
			end
			lastframe = frame

			if frame:IsShown() then
				lastShownFrame = frame
			end
		end

		AlertFrame:ClearAllPoints()
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
		end
	else
		AlertFrame:ClearAllPoints()
		AlertFrame:SetAllPoints(AlertFrameHolder)
	end

end

function B:AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		self.alertFrame:ClearAllPoints()
		self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AdjustQueuedAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		alertFrame:ClearAllPoints()
		alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET);
		relativeAlert = alertFrame;
	end
end

function B:AlertMovers()
	UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
	E:CreateMover(AlertFrameHolder, "AlertFrameMover", L["Loot / Alert Frames"], nil, nil, E.PostAlertMove)

	--From Leatrix Plus
	-- Achievements
	hooksecurefunc(AchievementAlertSystem, "AdjustAnchors", B.AdjustQueuedAnchors) 		-- /run AchievementAlertSystem:AddAlert(5192)
	hooksecurefunc(CriteriaAlertSystem, "AdjustAnchors", B.AdjustQueuedAnchors) 		-- /run CriteriaAlertSystem:AddAlert(9023, "Doing great!")
	-- Encounters
	hooksecurefunc(DungeonCompletionAlertSystem, "AdjustAnchors", B.AdjustAnchors) 		-- /run DungeonCompletionAlertSystem
	hooksecurefunc(GuildChallengeAlertSystem, "AdjustAnchors", B.AdjustAnchors) 		-- /run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
	hooksecurefunc(InvasionAlertSystem, "AdjustAnchors", B.AdjustAnchors) 				-- /run InvasionAlertSystem:AddAlert(1)
	hooksecurefunc(ScenarioAlertSystem, "AdjustAnchors",  B.AdjustAnchors) 				-- ScenarioAlertSystem
	hooksecurefunc(WorldQuestCompleteAlertSystem, "AdjustAnchors", B.AdjustAnchors) 	-- /run WorldQuestCompleteAlertSystem:AddAlert(112)
	-- Garrisons
	hooksecurefunc(GarrisonBuildingAlertSystem, "AdjustAnchors",  B.AdjustAnchors) 		-- /run GarrisonBuildingAlertSystem:AddAlert("Barracks")
	hooksecurefunc(GarrisonFollowerAlertSystem, "AdjustAnchors",  B.AdjustAnchors) 		-- /run GarrisonFollowerAlertSystem:AddAlert(204, "Ben Stone", 90, 3, false)
	hooksecurefunc(GarrisonMissionAlertSystem, "AdjustAnchors", B.AdjustAnchors) 		-- /run GarrisonMissionAlertSystem:AddAlert(681)
	hooksecurefunc(GarrisonShipMissionAlertSystem, "AdjustAnchors", B.AdjustAnchors)	-- No test for this, it was missing from Leatrix Plus
	hooksecurefunc(GarrisonRandomMissionAlertSystem, "AdjustAnchors", B.AdjustAnchors)	-- GarrisonRandomMissionAlertSystem
	hooksecurefunc(GarrisonShipFollowerAlertSystem, "AdjustAnchors", B.AdjustAnchors)	-- /run GarrisonShipFollowerAlertSystem:AddAlert(592, "Test", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
	hooksecurefunc(GarrisonTalentAlertSystem, "AdjustAnchors",  B.AdjustAnchors) 		-- GarrisonTalentAlertSystem
	-- Loot
	hooksecurefunc(LegendaryItemAlertSystem, "AdjustAnchors",  B.AdjustAnchors) 		-- /run LegendaryItemAlertSystem:AddAlert("\\124cffa335ee\\124Hitem:18832::::::::::\\124h[Brutality Blade]\\124h\\124r")
	hooksecurefunc(LootAlertSystem, "AdjustAnchors", B.AdjustQueuedAnchors) 			-- /run LootAlertSystem:AddAlert("\\124cffa335ee\\124Hitem:18832::::::::::\\124h[Brutality Blade]\\124h\\124r", 1, 1, 1, 1, false, false, 0, false, false)
	hooksecurefunc(LootUpgradeAlertSystem, "AdjustAnchors", B.AdjustQueuedAnchors) 		-- /run LootUpgradeAlertSystem:AddAlert("\\124cffa335ee\\124Hitem:18832::::::::::\\124h[Brutality Blade]\\124h\\124r", 1, 1, 1, nil, nil, false)
	hooksecurefunc(MoneyWonAlertSystem, "AdjustAnchors", B.AdjustQueuedAnchors) 		-- /run MoneyWonAlertSystem:AddAlert(815)
	hooksecurefunc(StorePurchaseAlertSystem, "AdjustAnchors", B.AdjustAnchors) 			-- /run StorePurchaseAlertSystem:AddAlert("\\124cffa335ee\\124Hitem:180545::::::::::\\124h[Mystic Runesaber]\\124h\\124r", "", "", 214)
	-- Professions
	hooksecurefunc(DigsiteCompleteAlertSystem, "AdjustAnchors", B.AdjustAnchors) 		-- /run DigsiteCompleteAlertSystem:AddAlert(1)
	hooksecurefunc(NewRecipeLearnedAlertSystem, "AdjustAnchors", B.AdjustQueuedAnchors)	-- /run NewRecipeLearnedAlertSystem:AddAlert(204)
end