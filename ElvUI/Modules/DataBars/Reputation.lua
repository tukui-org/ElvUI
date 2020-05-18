local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars')
local LSM = E.Libs.LSM

local _G = _G
local format = format
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local GetFriendshipReputation = GetFriendshipReputation
local GetWatchedFactionInfo = GetWatchedFactionInfo
local InCombatLockdown = InCombatLockdown
local ToggleCharacter = ToggleCharacter
local CreateFrame = CreateFrame
local REPUTATION = REPUTATION
local STANDING = STANDING

local FACTION_BAR_COLORS = {
	[1] = {r = 1, g = 0.1, b = 0.1},
	[2] = {r = 1, g = 0.5, b = 0.25},
	[3] = {r = 1, g = 0.7, b = 0.3},
	[4] = {r = 1, g = 1, b = 0},
	[5] = {r = 0.32, g = 0.67, b = 0},
	[6] = {r = 0, g = 0.43922, b = 1},
	[7] = {r = 0.63922, g = 0.20784, b = 0.93333},
	[8] = {r = 0.90196, g = 0.8, b = 0.50196},
};

function mod:UpdateReputation(event)
	if not mod.db.reputation.enable then return end

	local bar = self.repBar
	local name, reaction, Min, Max, value, factionID = GetWatchedFactionInfo()

	if not name or (self.db.reputation.hideInCombat and (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown())) then
		bar:Hide()
	else
		bar:Show()

		if self.db.reputation.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local friendshipID = GetFriendshipReputation(factionID)
		local textFormat, text = self.db.reputation.textFormat, ''
		local isCapped, isFriend, friendText, standingLabel

		if friendshipID then
			local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
			isFriend, reaction, friendText = true, 5, friendTextLevel
			if nextFriendThreshold then
				Min, Max, value = friendThreshold, nextFriendThreshold, friendRep;
			else
				Min, Max, value = 0, 1, 1
				isCapped = true
			end
		elseif C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue and threshold then
				Min, Max = 0, threshold
				value = currentValue % threshold
				if hasRewardPending then
					value = value + threshold
				end
			end
		elseif reaction == _G.MAX_REPUTATION_REACTION then
			Min, Max, value = 0, 1, 1
			isCapped = true
		end

		bar.statusBar:SetMinMaxValues(Min, Max)
		bar.statusBar:SetValue(value)
		local color = FACTION_BAR_COLORS[reaction]
		bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

		standingLabel = _G['FACTION_STANDING_LABEL'..reaction]

		--Prevent a division by zero
		local maxMinDiff = Max - Min
		if maxMinDiff == 0 then
			maxMinDiff = 1
		end

		if isCapped and textFormat ~= 'NONE' then
			-- show only name and standing on exalted
			text = format('%s: [%s]', name, isFriend and friendText or standingLabel)
		else
			if textFormat == 'PERCENT' then
				text = format('%s: %d%% [%s]', name, ((value - Min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURMAX' then
				text = format('%s: %s - %s [%s]', name, E:ShortValue(value - Min), E:ShortValue(Max - Min), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURPERC' then
				text = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
			elseif textFormat == 'CUR' then
				text = format('%s: %s [%s]', name, E:ShortValue(value - Min), isFriend and friendText or standingLabel)
			elseif textFormat == 'REM' then
				text = format('%s: %s [%s]', name, E:ShortValue((Max - Min) - (value-Min)), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURREM' then
				text = format('%s: %s - %s [%s]', name, E:ShortValue(value - Min), E:ShortValue((Max - Min) - (value-Min)), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURPERCREM' then
				text = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), E:ShortValue((Max - Min) - (value-Min)), isFriend and friendText or standingLabel)
			end
		end

		bar.text:SetText(text)
	end
end

function mod:ReputationBar_OnEnter()
	local GameTooltip = _G.GameTooltip

	if mod.db.reputation.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	if factionID and C_Reputation_IsFactionParagon(factionID) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if currentValue and threshold then
			min, max = 0, threshold
			value = currentValue % threshold
			if hasRewardPending then
				value = value + threshold
			end
		end
	end

	if name then
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(' ')

		local friendID, friendTextLevel, _
		if factionID then friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID) end

		GameTooltip:AddDoubleLine(STANDING..':', (friendID and friendTextLevel) or _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		if reaction ~= _G.MAX_REPUTATION_REACTION or C_Reputation_IsFactionParagon(factionID) then
			GameTooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
		end
	end
	GameTooltip:Show()
end

function mod:ReputationBar_OnClick()
	ToggleCharacter("ReputationFrame")
end

function mod:UpdateReputationDimensions()
	self.repBar:Width(self.db.reputation.width)
	self.repBar:Height(self.db.reputation.height)
	self.repBar.statusBar:SetOrientation(self.db.reputation.orientation)
	self.repBar.statusBar:SetReverseFill(self.db.reputation.reverseFill)
	self.repBar.text:FontTemplate(LSM:Fetch("font", self.db.reputation.font), self.db.reputation.textSize, self.db.reputation.fontOutline)

	if self.db.reputation.orientation == "HORIZONTAL" then
		self.repBar.statusBar:SetRotatesTexture(false)
	else
		self.repBar.statusBar:SetRotatesTexture(true)
	end

	if self.db.reputation.mouseover then
		self.repBar:SetAlpha(0)
	else
		self.repBar:SetAlpha(1)
	end
end

function mod:EnableDisable_ReputationBar()
	if self.db.reputation.enable then
		self:RegisterEvent('UPDATE_FACTION', 'UpdateReputation')
		self:UpdateReputation()
		E:EnableMover(self.repBar.mover:GetName())
	else
		self:UnregisterEvent('UPDATE_FACTION')
		self.repBar:Hide()
		E:DisableMover(self.repBar.mover:GetName())
	end
end

function mod:LoadReputationBar()
	self.repBar = self:CreateBar('ElvUI_ReputationBar', self.ReputationBar_OnEnter, self.ReputationBar_OnClick, 'RIGHT', _G.RightChatPanel, 'LEFT', E.Border - E.Spacing*3, 0)
	E:RegisterStatusBar(self.repBar.statusBar)

	self.repBar.eventFrame = CreateFrame("Frame")
	self.repBar.eventFrame:Hide()
	self.repBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.repBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.repBar.eventFrame:RegisterEvent("COMBAT_TEXT_UPDATE")
	self.repBar.eventFrame:SetScript("OnEvent", function(_, event, ...)
		mod:UpdateReputation(event, ...)
	end)

	self:UpdateReputationDimensions()

	E:CreateMover(self.repBar, "ReputationBarMover", L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')
	self:EnableDisable_ReputationBar()
end
