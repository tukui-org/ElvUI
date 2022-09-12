local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')
local Misc = E:GetModule('Misc')

local _G = _G
local ipairs = ipairs
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local POSITION, ANCHOR_POINT, YOFFSET = 'TOP', 'BOTTOM', -5

function E:PostAlertMove()
	local AlertFrameMover = _G.AlertFrameMover
	local AlertFrameHolder = _G.AlertFrameHolder

	local _, y = AlertFrameMover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	if y > (screenHeight * 0.5) then
		POSITION = 'TOP'
		ANCHOR_POINT = 'BOTTOM'
		YOFFSET = -5
		AlertFrameMover:SetText(AlertFrameMover.textString..' (Grow Down)')
	else
		POSITION = 'BOTTOM'
		ANCHOR_POINT = 'TOP'
		YOFFSET = 5
		AlertFrameMover:SetText(AlertFrameMover.textString..' (Grow Up)')
	end

	local AlertFrame = _G.AlertFrame
	local GroupLootContainer = _G.GroupLootContainer

	AlertFrame:ClearAllPoints()
	GroupLootContainer:ClearAllPoints()

	local lastRollFrame = E.private.general.lootRoll and Misc:UpdateLootRollAnchors(POSITION)
	if lastRollFrame then
		AlertFrame:SetAllPoints(lastRollFrame)
		GroupLootContainer:Point(POSITION, lastRollFrame, ANCHOR_POINT, 0, YOFFSET)
	else
		AlertFrame:SetAllPoints(AlertFrameHolder)
		GroupLootContainer:Point(POSITION, AlertFrameHolder, ANCHOR_POINT, 0, YOFFSET)
	end

	if GroupLootContainer:IsShown() then
		B.GroupLootContainer_Update(GroupLootContainer)
	end
end

function B:AdjustAnchors(relativeAlert)
	if self.alertFrame:IsShown() then
		self.alertFrame:ClearAllPoints()
		self.alertFrame:Point(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		return self.alertFrame
	end
	return relativeAlert
end

function B:AdjustAnchorsNonAlert(relativeAlert)
	if self.anchorFrame:IsShown() then
		self.anchorFrame:ClearAllPoints()
		self.anchorFrame:Point(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		return self.anchorFrame
	end
	return relativeAlert
end

function B:AdjustQueuedAnchors(relativeAlert)
	for alertFrame in self.alertFramePool:EnumerateActive() do
		alertFrame:ClearAllPoints()
		alertFrame:Point(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
		relativeAlert = alertFrame
	end
	return relativeAlert
end

function B:GroupLootContainer_Update()
	local lastIdx

	for i=1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()

			local prevFrame = self.rollFrames[i-1]
			if prevFrame and prevFrame ~= frame then
				frame:Point(POSITION, prevFrame, ANCHOR_POINT, 0, YOFFSET)
			else
				frame:Point(POSITION, self, POSITION, 0, YOFFSET)
			end

			lastIdx = i
		end
	end

	if lastIdx then
		self:Height(self.reservedSize * lastIdx)
		self:Show()
	else
		self:Hide()
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
	local AlertFrameHolder = CreateFrame('Frame', 'AlertFrameHolder', E.UIParent)
	AlertFrameHolder:Size(180, 20)
	AlertFrameHolder:Point('TOP', E.UIParent, 'TOP', 0, -20)

	_G.GroupLootContainer:EnableMouse(false) -- Prevent this weird non-clickable area stuff since 8.1; Monitor this, as it may cause addon compatibility.
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	E:CreateMover(AlertFrameHolder, 'AlertFrameMover', L["Loot / Alert Frames"], nil, nil, E.PostAlertMove, nil, nil, 'general,blizzUIImprovements')

	--Replace AdjustAnchors functions to allow alerts to grow down if needed.
	--We will need to keep an eye on this in case it taints. It shouldn't, but you never know.
	for _, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end

	--This should catch any alert systems that are created by other addons
	hooksecurefunc(_G.AlertFrame, 'AddAlertFrameSubSystem', function(_, alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	self:SecureHook(_G.AlertFrame, 'UpdateAnchors', E.PostAlertMove)
	hooksecurefunc('GroupLootContainer_Update', B.GroupLootContainer_Update)

	--[=[ Code you can use for alert testing
		--Queued Alerts:
		/run AchievementAlertSystem:AddAlert(5192)
		/run CriteriaAlertSystem:AddAlert(9023, 'Doing great!')
		/run LootAlertSystem:AddAlert('|cffa335ee|Hitem:18832::::::::::|h[Brutality Blade]|h|r', 1, 1, 1, 1, false, false, 0, false, false)
		/run LootUpgradeAlertSystem:AddAlert('|cffa335ee|Hitem:18832::::::::::|h[Brutality Blade]|h|r', 1, 1, 1, nil, nil, false)
		/run MoneyWonAlertSystem:AddAlert(81500)
		/run NewRecipeLearnedAlertSystem:AddAlert(204)

		--Simple Alerts
		/run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
		/run InvasionAlertSystem:AddAlert(678, DUNGEON_FLOOR_THENEXUS1, true, 1, 1)
		/run WorldQuestCompleteAlertSystem:AddAlert(AlertFrameMixin:BuildQuestData(42114))
		/run GarrisonTalentAlertSystem:AddAlert(3, C_Garrison.GetTalentInfo(370))
		/run GarrisonBuildingAlertSystem:AddAlert(GARRISON_CACHE)
		/run GarrisonFollowerAlertSystem:AddAlert(204, 'Ben Stone', 90, 3, false)
		/run GarrisonMissionAlertSystem:AddAlert(681) (Requires a mission ID that is in your mission list.)
		/run GarrisonShipFollowerAlertSystem:AddAlert(592, 'Test', 'Transport', 'GarrBuilding_Barracks_1_H', 3, 2, 1)
		/run LegendaryItemAlertSystem:AddAlert('|cffa335ee|Hitem:18832::::::::::|h[Brutality Blade]|h|r')
		/run EntitlementDeliveredAlertSystem:AddAlert('', [[Interface\Icons\Ability_pvp_gladiatormedallion]], TRINKET0SLOT, 214)
		/run RafRewardDeliveredAlertSystem:AddAlert('', [[Interface\Icons\Ability_pvp_gladiatormedallion]], TRINKET0SLOT, 214)
		/run DigsiteCompleteAlertSystem:AddAlert('Human')

		--Bonus Rolls
		/run BonusRollFrame_CloseBonusRoll()
		/run BonusRollFrame_StartBonusRoll(242969,'test',10,515,1273,14) --515 is darkmoon token, change to another currency id you have
	]=]
end
