local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local AlertFrame_FixAnchors = AlertFrame_FixAnchors
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

	if screenQuadrant then
		FORCE_POSITION = true
		AlertFrame_FixAnchors()
		FORCE_POSITION = false
	end
end

function B:AlertFrame_SetLootAnchors(alertAnchor)
	--This is a bit of reverse logic to get it to work properly because blizzard was a bit lazy..
	if ( MissingLootFrame:IsShown() ) then
		MissingLootFrame:ClearAllPoints()
		MissingLootFrame:Point(POSITION, alertAnchor, ANCHOR_POINT)
		if ( GroupLootContainer:IsShown() ) then
			GroupLootContainer:ClearAllPoints()
			GroupLootContainer:Point(POSITION, MissingLootFrame, ANCHOR_POINT, 0, YOFFSET)
		end
	elseif ( GroupLootContainer:IsShown() or FORCE_POSITION) then
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:Point(POSITION, alertAnchor, ANCHOR_POINT)
	end
end

function B:AlertFrame_SetLootWonAnchors(alertAnchor)
	for i=1, #LOOT_WON_ALERT_FRAMES do
		local frame = LOOT_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
			alertAnchor = frame
		end
	end
end

function B:AlertFrame_SetLootUpgradeFrameAnchors(alertAnchor)
	for i=1, #LOOT_UPGRADE_ALERT_FRAMES do
		local frame = LOOT_UPGRADE_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
			alertAnchor = frame;
		end
	end
end

function B:AlertFrame_SetMoneyWonAnchors(alertAnchor)
	for i=1, #MONEY_WON_ALERT_FRAMES do
		local frame = MONEY_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
			alertAnchor = frame
		end
	end
end

function B:AlertFrame_SetAchievementAnchors(alertAnchor)
	if ( AchievementAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:ClearAllPoints()
				frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
				alertAnchor = frame
			end
		end
	end
end

function B:AlertFrame_SetCriteriaAnchors(alertAnchor)
	if ( CriteriaAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:ClearAllPoints()
				frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
				alertAnchor = frame
			end
		end
	end
end

function B:AlertFrame_SetChallengeModeAnchors(alertAnchor)
	local frame = ChallengeModeAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetStorePurchaseAnchors(alertAnchor)
	local frame = StorePurchaseAlertFrame;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints();
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetDigsiteCompleteToastFrameAnchors(alertAnchor)
	if ( DigsiteCompleteToastFrame and DigsiteCompleteToastFrame:IsShown() ) then
		DigsiteCompleteToastFrame:ClearAllPoints()
		DigsiteCompleteToastFrame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
		alertAnchor = DigsiteCompleteToastFrame;
	end
end

function B:AlertFrame_SetGarrisonBuildingAlertFrameAnchors(alertAnchor)
	if ( GarrisonBuildingAlertFrame and GarrisonBuildingAlertFrame:IsShown() ) then
		GarrisonBuildingAlertFrame:ClearAllPoints()
		GarrisonBuildingAlertFrame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
		alertAnchor = GarrisonBuildingAlertFrame;
	end
end

function B:AlertFrame_SetGarrisonMissionAlertFrameAnchors(alertAnchor)
	if ( GarrisonMissionAlertFrame and GarrisonMissionAlertFrame:IsShown() ) then
		GarrisonMissionAlertFrame:ClearAllPoints()
		GarrisonMissionAlertFrame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
		alertAnchor = GarrisonMissionAlertFrame;
	end
end

function B:AlertFrame_SetGarrisonFollowerAlertFrameAnchors(alertAnchor)
	if ( GarrisonFollowerAlertFrame and GarrisonFollowerAlertFrame:IsShown() ) then
		GarrisonFollowerAlertFrame:ClearAllPoints()
		GarrisonFollowerAlertFrame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
		alertAnchor = GarrisonFollowerAlertFrame;
	end
end

function B:AlertFrame_SetGarrisonShipFollowerAlertFrameAnchors(alertAnchor)
	if ( GarrisonShipFollowerAlertFrame and GarrisonShipFollowerAlertFrame:IsShown() ) then
		GarrisonShipFollowerAlertFrame:ClearAllPoints()
		GarrisonShipFollowerAlertFrame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
		alertAnchor = GarrisonShipFollowerAlertFrame;
	end
end

function B:AlertFrame_SetGarrisonShipMissionAlertFrameAnchors(alertAnchor)
	if ( GarrisonShipMissionAlertFrame and GarrisonShipMissionAlertFrame:IsShown() ) then
		GarrisonShipMissionAlertFrame:ClearAllPoints()
		GarrisonShipMissionAlertFrame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
		alertAnchor = GarrisonShipMissionAlertFrame;
	end
end

function B:AlertMovers()
	UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
	E:CreateMover(AlertFrameHolder, "AlertFrameMover", L["Loot / Alert Frames"], nil, nil, E.PostAlertMove)

	self:SecureHook('AlertFrame_FixAnchors', E.PostAlertMove)
	self:SecureHook('AlertFrame_SetLootAnchors')
	self:SecureHook('AlertFrame_SetStorePurchaseAnchors')
	self:SecureHook('AlertFrame_SetLootWonAnchors')
	self:SecureHook('AlertFrame_SetLootUpgradeFrameAnchors')
	self:SecureHook('AlertFrame_SetMoneyWonAnchors')
	self:SecureHook('AlertFrame_SetAchievementAnchors')
	self:SecureHook('AlertFrame_SetCriteriaAnchors')
	self:SecureHook('AlertFrame_SetChallengeModeAnchors')
	self:SecureHook('AlertFrame_SetDungeonCompletionAnchors')
	self:SecureHook('AlertFrame_SetScenarioAnchors')
	self:SecureHook('AlertFrame_SetGuildChallengeAnchors')
	self:SecureHook('AlertFrame_SetDigsiteCompleteToastFrameAnchors')
	self:SecureHook('AlertFrame_SetGarrisonBuildingAlertFrameAnchors')
	self:SecureHook('AlertFrame_SetGarrisonMissionAlertFrameAnchors')
	self:SecureHook('AlertFrame_SetGarrisonFollowerAlertFrameAnchors')
	self:SecureHook('AlertFrame_SetGarrisonShipMissionAlertFrameAnchors')
	self:SecureHook('AlertFrame_SetGarrisonShipFollowerAlertFrameAnchors')
end