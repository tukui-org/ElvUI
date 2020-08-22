local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')
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
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

function DB:UpdateReputation(event)
	if not DB.db.reputation.enable then return end

	local bar = self.repBar
	local name, reaction, Min, Max, value, factionID = GetWatchedFactionInfo()

	if not name or (DB.db.reputation.hideInCombat and (event == 'PLAYER_REGEN_DISABLED' or InCombatLockdown())) or (DB.db.reputation.hideBelowMaxLevel and E.mylevel < MAX_PLAYER_LEVEL) then
		bar:Hide()
	else
		bar:Show()

		if DB.db.reputation.hideInVehicle then
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
		local color = _G.FACTION_BAR_COLORS[reaction]
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

function DB:ReputationBar_OnEnter()
	local GameTooltip = _G.GameTooltip

	if DB.db.reputation.mouseover then
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

function DB:ReputationBar_OnClick()
	ToggleCharacter('ReputationFrame')
end

function DB:UpdateReputationDimensions()
	DB.repBar:SetWidth(DB.db.reputation.width)
	DB.repBar:SetHeight(DB.db.reputation.height)
	DB.repBar.statusBar:SetOrientation(DB.db.reputation.orientation)
	DB.repBar.statusBar:SetReverseFill(DB.db.reputation.reverseFill)
	DB.repBar.text:FontTemplate(LSM:Fetch('font', DB.db.reputation.font), DB.db.reputation.textSize, DB.db.reputation.fontOutline)

	if DB.db.reputation.orientation == 'HORIZONTAL' then
		DB.repBar.statusBar:SetRotatesTexture(false)
	else
		DB.repBar.statusBar:SetRotatesTexture(true)
	end

	if DB.db.reputation.mouseover then
		DB.repBar:SetAlpha(0)
	else
		DB.repBar:SetAlpha(1)
	end
end

function DB:EnableDisable_ReputationBar()
	if DB.db.reputation.enable then
		DB:RegisterEvent('UPDATE_FACTION', 'UpdateReputation')
		DB:UpdateReputation()
		E:EnableMover(DB.repBar.mover:GetName())
	else
		DB:UnregisterEvent('UPDATE_FACTION')
		DB.repBar:Hide()
		E:DisableMover(DB.repBar.mover:GetName())
	end
end

function DB:LoadReputationBar()
	DB.repBar = DB:CreateBar('ElvUI_ReputationBar', DB.ReputationBar_OnEnter, DB.ReputationBar_OnClick, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -264)
	E:RegisterStatusBar(DB.repBar.statusBar)

	DB.repBar.eventFrame = CreateFrame('Frame')
	DB.repBar.eventFrame:Hide()
	DB.repBar.eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	DB.repBar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	DB.repBar.eventFrame:RegisterEvent('COMBAT_TEXT_UPDATE')
	DB.repBar.eventFrame:SetScript('OnEvent', function(_, event, ...)
		DB:UpdateReputation(event, ...)
	end)

	DB:UpdateReputationDimensions()

	E:CreateMover(DB.repBar, 'ReputationBarMover', L["Reputation Bar"], nil, nil, nil, nil, nil, 'databars,reputation')
	DB:EnableDisable_ReputationBar()
end
