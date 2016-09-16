local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('DataBars');

--Cache global variables
--Lua functions
local _G = _G
local format = format

--WoW API / Variables
local GetFriendshipReputation = GetFriendshipReputation
local GetWatchedFactionInfo, GetNumFactions, GetFactionInfo = GetWatchedFactionInfo, GetNumFactions, GetFactionInfo
local InCombatLockdown = InCombatLockdown
local ToggleCharacter = ToggleCharacter
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local REPUTATION, STANDING = REPUTATION, STANDING

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, RightChatPanel, CreateFrame

local backupColor = FACTION_BAR_COLORS[1]
local FactionStandingLabelUnknown = UNKNOWN
function mod:UpdateReputation(event)
	if not mod.db.reputation.enable then return end

	local bar = self.repBar

	local ID
	local isFriend, friendText, standingLabel
	local name, reaction, min, max, value = GetWatchedFactionInfo()
	local numFactions = GetNumFactions();

	if not name or (event == "PLAYER_REGEN_DISABLED" and self.db.reputation.hideInCombat) then
		bar:Hide()
	elseif name and (not self.db.reputation.hideInCombat or not InCombatLockdown()) then
		bar:Show()

		if self.db.reputation.hideInVehicle then
			E:RegisterObjectForVehicleLock(bar, E.UIParent)
		else
			E:UnregisterObjectForVehicleLock(bar)
		end

		local text = ''
		local textFormat = self.db.reputation.textFormat
		local color = FACTION_BAR_COLORS[reaction] or backupColor
		bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

		bar.statusBar:SetMinMaxValues(min, max)
		bar.statusBar:SetValue(value)

		for i=1, numFactions do
			local factionName, _, standingID,_,_,_,_,_,_,_,_,_,_, factionID = GetFactionInfo(i);
			local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID);
			if factionName == name then
				if friendID ~= nil then
					isFriend = true
					friendText = friendTextLevel
				else
					ID = standingID
				end
			end
		end

		if ID then
			standingLabel = _G['FACTION_STANDING_LABEL'..ID]
		else
			standingLabel = FactionStandingLabelUnknown
		end

		if textFormat == 'PERCENT' then
			text = format('%s: %d%% [%s]', name, ((value - min) / (max - min) * 100), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURMAX' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue(max - min), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURPERC' then
			text = format('%s: %s - %d%% [%s]', name, E:ShortValue(value - min), ((value - min) / (max - min) * 100), isFriend and friendText or standingLabel)
		elseif textFormat == 'CUR' then
			text = format('%s: %s [%s]', name, E:ShortValue(value - min), isFriend and friendText or standingLabel)
		elseif textFormat == 'REM' then
			text = format('%s: %s [%s]', name, E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
		elseif textFormat == 'CURREM' then
			text = format('%s: %s - %s [%s]', name, E:ShortValue(value - min), E:ShortValue((max - min) - (value-min)), isFriend and friendText or standingLabel)
		end

		bar.text:SetText(text)
	end
end

function mod:ReputationBar_OnEnter()
	if mod.db.reputation.mouseover then
		E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, 'ANCHOR_CURSOR', 0, -4)

	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID);
	if name then
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(' ')

		GameTooltip:AddDoubleLine(STANDING..':', friendID and friendTextLevel or _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		GameTooltip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
	end
	GameTooltip:Show()
end

function mod:ReputationBar_OnClick()
	ToggleCharacter("ReputationFrame");
end

function mod:UpdateReputationDimensions()
	self.repBar:Width(self.db.reputation.width)
	self.repBar:Height(self.db.reputation.height)
	self.repBar.statusBar:SetOrientation(self.db.reputation.orientation)
	self.repBar.statusBar:SetReverseFill(self.db.reputation.reverseFill)
	self.repBar.text:FontTemplate(nil, self.db.reputation.textSize)
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
	self.repBar = self:CreateBar('ElvUI_ReputationBar', self.ReputationBar_OnEnter, self.ReputationBar_OnClick, 'RIGHT', RightChatPanel, 'LEFT', E.Border - E.Spacing*3, 0)
	E:RegisterStatusBar(self.repBar.statusBar)

	self.repBar.eventFrame = CreateFrame("Frame")
	self.repBar.eventFrame:Hide()
	self.repBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.repBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.repBar.eventFrame:SetScript("OnEvent", function(self, event) mod:UpdateReputation(event) end)

	self:UpdateReputationDimensions()

	E:CreateMover(self.repBar, "ReputationBarMover", L["Reputation Bar"])
	self:EnableDisable_ReputationBar()
end