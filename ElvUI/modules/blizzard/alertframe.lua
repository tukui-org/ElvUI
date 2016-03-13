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

	--[[local rollBars = E:GetModule('Misc').RollBars
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
	end]]

end

function B:AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET);
		return self.alertFrame;
	end
	return relativeAlert;
end


function B:AlertMovers()
	UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
	E:CreateMover(AlertFrameHolder, "AlertFrameMover", L["Loot / Alert Frames"], nil, nil, E.PostAlertMove)
	
	hooksecurefunc(AlertFrameSimpleMixin, "AdjustAnchors", B.AdjustAnchors)
end