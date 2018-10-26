local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Cache global variables
--Lua functions
local pairs = pairs

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: AlertFrame, AlertFrameMover, MissingLootFrame, GroupLootContainer
-- GLOBALS: LOOT_WON_ALERT_FRAMES, LOOT_UPGRADE_ALERT_FRAMES, MONEY_WON_ALERT_FRAMES
-- GLOBALS: AchievementAlertFrame1, CriteriaAlertFrame1, ChallengeModeAlertFrame1
-- GLOBALS: DungeonCompletionAlertFrame1, StorePurchaseAlertFrame, ScenarioAlertFrame1
-- GLOBALS: GuildChallengeAlertFrame, DigsiteCompleteToastFrame, GarrisonBuildingAlertFrame
-- GLOBALS: GarrisonMissionAlertFrame, GarrisonFollowerAlertFrame, GarrisonShipFollowerAlertFrame
-- GLOBALS: GarrisonShipMissionAlertFrame, UIPARENT_MANAGED_FRAME_POSITIONS
-- GLOBALS: hooksecurefunc, ipairs

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.UIParent)
AlertFrameHolder:Width(180)
AlertFrameHolder:Height(20)
AlertFrameHolder:Point("TOP", E.UIParent, "TOP", 0, -18)

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

function E:PostAlertMove()
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
		GroupLootContainer:ClearAllPoints()
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
			GroupLootContainer:SetPoint(POSITION, lastShownFrame, ANCHOR_POINT, 0, YOFFSET)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
			GroupLootContainer:SetPoint(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
		end
		if GroupLootContainer:IsShown() then
			B.GroupLootContainer_Update(GroupLootContainer)
		end
	else
		AlertFrame:ClearAllPoints()
		AlertFrame:SetAllPoints(AlertFrameHolder)
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:SetPoint(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
		if GroupLootContainer:IsShown() then
			B.GroupLootContainer_Update(GroupLootContainer)
		end
	end
end

function B:AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		self.alertFrame:ClearAllPoints()
		self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET);
		return self.alertFrame;
	end
	return relativeAlert;
end

function B:AdjustAnchorsNonAlert(relativeAlert)
	if self.anchorFrame:IsShown() then
		self.anchorFrame:ClearAllPoints()
		self.anchorFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET);
		return self.anchorFrame;
	end
	return relativeAlert;
end

function B:AdjustQueuedAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		alertFrame:ClearAllPoints()
		alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET);
		relativeAlert = alertFrame;
	end
	return relativeAlert;
end

function B:GroupLootContainer_Update()
	local lastIdx = nil;

	for i=1, self.maxIndex do
		local frame = self.rollFrames[i];
		local prevFrame = self.rollFrames[i-1]
		if ( frame ) then
			frame:ClearAllPoints();
			if prevFrame and not (prevFrame == frame) then
				frame:SetPoint(POSITION, prevFrame, ANCHOR_POINT, 0, YOFFSET);
			else
				frame:SetPoint(POSITION, self, POSITION, 0, 0);
			end
			lastIdx = i;
		end
	end

	if ( lastIdx ) then
		self:SetHeight(self.reservedSize * lastIdx);
		self:Show();
	else
		self:Hide();
	end
end

local function AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	if alertFrameSubSystem.alertFramePool then --queued alert system
		alertFrameSubSystem.AdjustAnchors = B.AdjustQueuedAnchors
	elseif not alertFrameSubSystem.anchorFrame then --simple alert system
		alertFrameSubSystem.AdjustAnchors = B.AdjustAnchors
	elseif alertFrameSubSystem.anchorFrame then --anchor frame system
		alertFrameSubSystem.AdjustAnchors = B.AdjustAnchorsNonAlert
	end
end

function B:AlertMovers()
	UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil
	E:CreateMover(AlertFrameHolder, "AlertFrameMover", L["Loot / Alert Frames"], nil, nil, E.PostAlertMove, nil, nil, 'general,general')

	--Replace AdjustAnchors functions to allow alerts to grow down if needed.
	--We will need to keep an eye on this in case it taints. It shouldn't, but you never know.
	for _, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end

	--This should catch any alert systems that are created by other addons
	hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(self, alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	self:SecureHook(AlertFrame, "UpdateAnchors", E.PostAlertMove)
	hooksecurefunc("GroupLootContainer_Update", B.GroupLootContainer_Update)

	--[[ Code you can use for alert testing
		--Queued Alerts:
		/run AchievementAlertSystem:AddAlert(5192)
		/run CriteriaAlertSystem:AddAlert(9023, "Doing great!")
		/run LootAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, 1, false, false, 0, false, false)
		/run LootUpgradeAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, nil, nil, false)
		/run MoneyWonAlertSystem:AddAlert(815)
		/run NewRecipeLearnedAlertSystem:AddAlert(204)

		--Simple Alerts
		/run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
		/run InvasionAlertSystem:AddAlert(1)
		/run WorldQuestCompleteAlertSystem:AddAlert(112)
		/run GarrisonBuildingAlertSystem:AddAlert("Barracks")
		/run GarrisonFollowerAlertSystem:AddAlert(204, "Ben Stone", 90, 3, false)
		/run GarrisonMissionAlertSystem:AddAlert(681) (Requires a mission ID that is in your mission list.)
		/run GarrisonShipFollowerAlertSystem:AddAlert(592, "Test", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
		/run LegendaryItemAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r")
		/run StorePurchaseAlertSystem:AddAlert("\124cffa335ee\124Hitem:180545::::::::::\124h[Mystic Runesaber]\124h\124r", "", "", 214)
		/run DigsiteCompleteAlertSystem:AddAlert(1)

		--Bonus Rolls
		/run BonusRollFrame_StartBonusRoll(242969,1,179,1273,14)
	]]
end
