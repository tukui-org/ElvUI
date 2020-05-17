local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars')
local LSM = E.Libs.LSM

local _G = _G
local format = format

local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local GetFriendshipReputation = GetFriendshipReputation
local GetWatchedFactionInfo, GetNumFactions, GetFactionInfo = GetWatchedFactionInfo, GetNumFactions, GetFactionInfo
local InCombatLockdown = InCombatLockdown
local ToggleCharacter = ToggleCharacter
local CreateFrame = CreateFrame
local REPUTATION, STANDING = REPUTATION, STANDING

function mod:UpdateReputation(event, eventType)
	if not mod.db.reputation.enable then return end

	local bar = self.repBar
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

	if not name or (self.db.reputation.hideInCombat and (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown())) then
		bar:Hide()
	else
		bar:Show()

		if self.db.reputation.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local friendshipID = GetFriendshipReputation(factionID);
		local text = ''
		local textFormat = self.db.reputation.textFormat

		local isFriend, friendText, standingLabel
		local isCapped

--[[
		if (event == 'COMBAT_TEXT_UPDATE' and eventType == 'FACTION') then
			local faction = GetCurrentCombatTextEventInfo()
			if faction ~= 'Guild' and faction ~= name then
				ExpandAllFactionHeaders()
				for i = 1, GetNumFactions() do
					if faction == GetFactionInfo(i) then
						SetWatchedFactionIndex(i)
						break
					end
				end
			end
		end
]]
		if friendshipID then
			local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
			isFriend, reaction, friendText = true, 5, friendTextLevel
			if ( nextFriendThreshold ) then
				min, max, value = friendThreshold, nextFriendThreshold, friendRep;
			else
				min, max, value = 0, 1, 1
				isCapped = true;
			end
		elseif C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue and threshold then
				min, max = 0, threshold
				value = currentValue % threshold
				if hasRewardPending then
					value = value + threshold
				end
			end
		else
			if reaction == _G.MAX_REPUTATION_REACTION then
				min, max, value = 0, 1, 1
				isCapped = true
			end
		end

		bar.statusBar:SetMinMaxValues(min, max)
		bar.statusBar:SetValue(value)
		local color = _G.FACTION_BAR_COLORS[reaction]
		bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

		standingLabel = _G['FACTION_STANDING_LABEL'..reaction]

		--Prevent a division by zero
		local maxMinDiff = max - min
		if (maxMinDiff == 0) then
			maxMinDiff = 1
		end

		if isCapped and textFormat ~= 'NONE' then
			-- show only name and standing on exalted
			text = format('%s: [%s]', name, isFriend and friendText or standingLabel)
		else
			if textFormat == 'PERCENT' then
				text = format('%s: %d%% [%s]', name, ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURMAX' then
				text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue(max - min), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURPERC' then
				text = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
			elseif textFormat == 'CUR' then
				text = format('%s: %s [%s]', name, E:ShortValue(value - min), isFriend and friendText or standingLabel)
			elseif textFormat == 'REM' then
				text = format('%s: %s [%s]', name, E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURREM' then
				text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
			elseif textFormat == 'CURPERCREM' then
				text = format('%s: %s - %d%% (%s) [%s]', name, E:ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
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
	self.repBar.eventFrame:SetScript("OnEvent", function(_, event, ...) mod:UpdateReputation(event, ...) end)

	self:UpdateReputationDimensions()

	E:CreateMover(self.repBar, "ReputationBarMover", L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')
	self:EnableDisable_ReputationBar()
end
