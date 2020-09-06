local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local pairs, select, wipe = pairs, select, wipe

local GetThreatStatusColor = GetThreatStatusColor
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local UnitClass = UnitClass
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction
local UNKNOWN = UNKNOWN
-- GLOBALS: ElvUF

function DB:ThreatBar_GetLargestThreatOnList(percent)
	local largestValue, largestUnit = 0, nil
	for unit, threatPercent in pairs(DB.StatusBars.Threat.list) do
		if threatPercent > largestValue then
			largestValue = threatPercent
			largestUnit = unit
		end
	end

	return (percent - largestValue), largestUnit
end

function DB:ThreatBar_GetColor(unit)
	local unitReaction = UnitReaction(unit, 'player')
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = E:ClassColor(unitClass)
		if not class then return 194, 194, 194 end
		return class.r*255, class.g*255, class.b*255
	elseif (unitReaction) then
		local reaction = ElvUF.colors.reaction[unitReaction]
		return reaction[1]*255, reaction[2]*255, reaction[3]*255
	else
		return 194, 194, 194
	end
end

function DB:ThreatBar_Update()
	local isInGroup, isInRaid, petExists = IsInGroup(), IsInRaid(), UnitExists('pet')
	local _, status, percent = UnitDetailedThreatSituation('player', 'target')
	local bar = DB.StatusBars.Threat
	if percent and percent > 0 and (isInGroup or petExists) then
		local name = UnitName('target')
		bar:Show()
		if percent == 100 then
			--Build threat list
			if petExists then
				bar.list.pet = select(3, UnitDetailedThreatSituation('pet', 'target'))
			end

			if isInRaid then
				for i = 1, 40 do
					if UnitExists('raid'..i) and not UnitIsUnit('raid'..i, 'player') then
						bar.list['raid'..i] = select(3, UnitDetailedThreatSituation('raid'..i, 'target'))
					end
				end
			else
				for i = 1, 4 do
					if UnitExists('party'..i) then
						bar.list['party'..i] = select(3, UnitDetailedThreatSituation('party'..i, 'target'))
					end
				end
			end

			local leadPercent, largestUnit = DB:ThreatBar_GetLargestThreatOnList(percent)
			if leadPercent > 0 and largestUnit ~= nil then
				local r, g, b = DB:ThreatBar_GetColor(largestUnit)
				bar.text:SetFormattedText(L["ABOVE_THREAT_FORMAT"], name, percent, leadPercent, r, g, b, UnitName(largestUnit) or UNKNOWN)

				if E.myrole == 'TANK' then
					bar:SetStatusBarColor(0, 0.839, 0)
					bar:SetValue(leadPercent)
				else
					bar:SetStatusBarColor(GetThreatStatusColor(status))
					bar:SetValue(percent)
				end
			else
				bar:SetStatusBarColor(GetThreatStatusColor(status))
				bar.text:SetFormattedText('%s: %.0f%%', name, percent)
				bar:SetValue(percent)
			end
		else
			bar:SetStatusBarColor(GetThreatStatusColor(status))
			bar.text:SetFormattedText('%s: %.0f%%', name, percent)
			bar:SetValue(percent)
		end
	else
		bar:Hide()
	end

	wipe(bar.list)
end

function DB:ThreatBar_Toggle()
	DB.StatusBars.Threat.db = DB.db.threat

	if DB.db.threat.enable then
		DB:RegisterEvent('PLAYER_TARGET_CHANGED', 'ThreatBar_Update')
		DB:RegisterEvent('UNIT_THREAT_LIST_UPDATE', 'ThreatBar_Update')
		DB:RegisterEvent('GROUP_ROSTER_UPDATE', 'ThreatBar_Update')
		DB:RegisterEvent('UNIT_PET', 'ThreatBar_Update')
		DB:ThreatBar_Update()
	else
		DB.StatusBars.Threat:Hide()
		DB:UnregisterEvent('PLAYER_TARGET_CHANGED')
		DB:UnregisterEvent('UNIT_THREAT_LIST_UPDATE')
		DB:UnregisterEvent('GROUP_ROSTER_UPDATE')
		DB:UnregisterEvent('UNIT_PET')
	end
end

function DB:ThreatBar()
	DB.StatusBars.Threat = DB:CreateBar('ElvUI_ThreatBar', nil, nil, 'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -245)
	DB.StatusBars.Threat:SetMinMaxValues(0, 100)
	DB.StatusBars.Threat.list = {}

	E:CreateMover(DB.StatusBars.Threat, 'ThreatBarMover', L["Threat Bar"], nil, nil, nil, nil, nil, 'databars,threat')
	DB:ThreatBar_Toggle()
end
