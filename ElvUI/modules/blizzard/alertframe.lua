local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", E.UIParent, "TOP", 0, -70)

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

SlashCmdList.TEST_ACHIEVEMENT = function()
	PlaySound("LFG_Rewards")
	AchievementFrame_LoadUI()
	AchievementAlertFrame_ShowAlert(5780)
	AchievementAlertFrame_ShowAlert(5000)
	GuildChallengeAlertFrame_ShowAlert(3, 2, 5)
	ChallengeModeAlertFrame_ShowAlert()
	CriteriaAlertFrame_GetAlertFrame()
	AlertFrame_AnimateIn(CriteriaAlertFrame1)
	AlertFrame_AnimateIn(DungeonCompletionAlertFrame1)
	AlertFrame_AnimateIn(ScenarioAlertFrame1)
	
	local _, itemLink = GetItemInfo(6948)
	LootWonAlertFrame_ShowAlert(itemLink, -1, 1, 1)
	MoneyWonAlertFrame_ShowAlert(1)
	
	AlertFrame_FixAnchors()
end
SLASH_TEST_ACHIEVEMENT1 = "/testalerts"

function E:PostAlertMove(pos)
	POSITION = pos or POSITION
	
	if POSITION == 'TOP' then
		ANCHOR_POINT = 'BOTTOM'
		YOFFSET = -10
	else
		ANCHOR_POINT = 'TOP'
		YOFFSET = 10
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

	GroupLootContainer:ClearAllPoints()
	GroupLootContainer:SetPoint(POSITION, AlertFrame, ANCHOR_POINT)
	
	MissingLootFrame:ClearAllPoints()
	MissingLootFrame:SetPoint(POSITION, AlertFrame, ANCHOR_POINT)
	
	if pos == 'TOP' or pos == 'BOTTOM' then
		AlertFrame_FixAnchors()
	end
end

function B:AlertFrame_SetLootWonAnchors(alertAnchor)
	for i=1, #LOOT_WON_ALERT_FRAMES do
		local frame = LOOT_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
			alertAnchor = frame
		end
	end
end

function B:AlertFrame_SetMoneyWonAnchors(alertAnchor)
	for i=1, #MONEY_WON_ALERT_FRAMES do
		local frame = MONEY_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
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
				frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
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
				frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
				alertAnchor = frame
			end
		end
	end
end

function B:AlertFrame_SetChallengeModeAnchors(alertAnchor)
	local frame = ChallengeModeAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end

function B:AlertMovers()
	self:SecureHook('AlertFrame_FixAnchors', E.PostAlertMove)
	self:SecureHook('AlertFrame_SetLootWonAnchors')
	self:SecureHook('AlertFrame_SetMoneyWonAnchors')
	self:SecureHook('AlertFrame_SetAchievementAnchors')
	self:SecureHook('AlertFrame_SetCriteriaAnchors')
	self:SecureHook('AlertFrame_SetChallengeModeAnchors')
	self:SecureHook('AlertFrame_SetDungeonCompletionAnchors')
	self:SecureHook('AlertFrame_SetScenarioAnchors')
	self:SecureHook('AlertFrame_SetGuildChallengeAnchors')
	
	hooksecurefunc(GroupLootContainer, 'SetPoint', function(self, point, anchorTo, attachPoint, xOffset, yOffset)
		if _G[anchorTo] == UIParent then
			AlertFrame_FixAnchors()
		end
	end)
	
	E:CreateMover(AlertFrameHolder, "AlertFrameMover", "Loot / Alert Frames", nil, nil, E.PostAlertMove)
end