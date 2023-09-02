local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')
local Misc = E:GetModule('Misc')

local _G = _G
local ipairs = ipairs
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local POSITION, ANCHOR_POINT, Y_OFFSET, BASE_YOFFSET = 'TOP', 'BOTTOM', -5, 0 -- should match in PostAlertMove

function E:PostAlertMove()
	local AlertFrame = _G.AlertFrame
	local AlertFrameMover = _G.AlertFrameMover

	local perks = _G.PerksProgramFrame
	local perksFooter = perks and perks.FooterFrame
	local perksAnchor = perksFooter and AlertFrame.baseAnchorFrame == perksFooter.RotateButtonContainer and perksFooter

	local growUp = perksAnchor
	if not growUp then
		local _, y = AlertFrameMover:GetCenter()
		growUp = y < (E.UIParent:GetTop() * 0.5)
	end

	if growUp then
		POSITION, ANCHOR_POINT, Y_OFFSET, BASE_YOFFSET = 'BOTTOM', 'TOP', 5, perksAnchor and 40 or 0
	else
		POSITION, ANCHOR_POINT, Y_OFFSET, BASE_YOFFSET = 'TOP', 'BOTTOM', -5, 0
	end

	AlertFrameMover:SetFormattedText('%s %s', AlertFrameMover.textString, growUp and '(Grow Up)' or '(Grow Down)')

	local GroupLootContainer = _G.GroupLootContainer
	GroupLootContainer:ClearAllPoints()
	AlertFrame:ClearAllPoints()

	local anchor = perksAnchor or (E.private.general.lootRoll and Misc:UpdateLootRollAnchors(POSITION)) or _G.AlertFrameHolder
	GroupLootContainer:Point(POSITION, anchor, ANCHOR_POINT, 0, Y_OFFSET)
	AlertFrame:SetAllPoints(anchor)

	if GroupLootContainer:IsShown() then
		B.GroupLootContainer_Update(GroupLootContainer)
	end
end

function B:AdjustAnchors(relativeAlert)
	local alert = self.alertFrame
	if alert:IsShown() then
		alert:ClearAllPoints()
		alert:Point(POSITION, relativeAlert, ANCHOR_POINT, 0, Y_OFFSET)

		return alert
	end

	return relativeAlert
end

function B:AdjustAnchorsNonAlert(relativeAnchor)
	local anchor = self.anchorFrame
	if anchor:IsShown() then
		anchor:ClearAllPoints()
		anchor:Point(POSITION, relativeAnchor, ANCHOR_POINT, 0, Y_OFFSET)

		return anchor
	end

	return relativeAnchor
end

function B:AdjustQueuedAnchors(relativeAlert)
	local base = BASE_YOFFSET -- copy we can clear after the first
	for alert in self.alertFramePool:EnumerateActive() do
		alert:ClearAllPoints()
		alert:Point(POSITION, relativeAlert, ANCHOR_POINT, 0, base + Y_OFFSET)

		relativeAlert = alert

		if base ~= 0 then
			base = 0 -- we only want to adjust the first alert
		end
	end

	return relativeAlert
end

function B:GroupLootContainer_Update()
	local lastIdx

	for i = 1, self.maxIndex do
		local frame = self.rollFrames[i]
		if frame then
			frame:ClearAllPoints()

			local prevFrame = self.rollFrames[i-1]
			if prevFrame and prevFrame ~= frame then
				frame:Point(POSITION, prevFrame, ANCHOR_POINT, 0, Y_OFFSET)
			else
				frame:Point(POSITION, self, POSITION, 0, Y_OFFSET)
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
	E:CreateMover(AlertFrameHolder, 'AlertFrameMover', L["Loot / Alert Frames"], nil, nil, E.PostAlertMove, nil, nil, 'general,blizzUIImprovements')

	if not E.Retail then
		_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	end

	--Replace AdjustAnchors functions to allow alerts to grow down if needed.
	--We will need to keep an eye on this in case it taints. It shouldn't, but you never know.
	for _, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end

	--This should catch any alert systems that are created by other addons
	hooksecurefunc(_G.AlertFrame, 'AddAlertFrameSubSystem', function(_, alertFrameSubSystem)
		AlertSubSystem_AdjustPosition(alertFrameSubSystem)
	end)

	if E.Retail then -- alerts on the Perks Program Frame (Trading Post)
		hooksecurefunc(_G.AlertFrame, 'SetBaseAnchorFrame', E.PostAlertMove)
		hooksecurefunc(_G.AlertFrame, 'ResetBaseAnchorFrame', E.PostAlertMove)
	end

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
		/run NewCosmeticAlertFrameSystem:AddAlert(204)

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
