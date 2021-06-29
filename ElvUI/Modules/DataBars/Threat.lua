local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local pairs, select, wipe = pairs, select, wipe

local GetThreatStatusColor = GetThreatStatusColor
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local UnitClass = UnitClass
local UnitAffectingCombat = UnitAffectingCombat
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local GetNumGroupMembers = GetNumGroupMembers
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
	local bar = DB.StatusBars.Threat
	local petExists = UnitExists('pet')

	if UnitAffectingCombat('player') and (petExists or IsInGroup()) then
		local _, status, percent = UnitDetailedThreatSituation('player', 'target')
		local name = UnitName('target') or UNKNOWN
		bar.showBar = true

		if percent == 100 then
			if petExists then
				bar.list.pet = select(3, UnitDetailedThreatSituation('pet', 'target'))
			end

			local isInRaid = IsInRaid()
			for i = 1, GetNumGroupMembers() do
				local groupUnit = (isInRaid and 'raid' or 'party')..i
				if UnitExists(groupUnit) and not UnitIsUnit(groupUnit, 'player') then
					bar.list[groupUnit] = select(3, UnitDetailedThreatSituation(groupUnit, 'target'))
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
		elseif percent then
			bar:SetStatusBarColor(GetThreatStatusColor(status))
			bar.text:SetFormattedText('%s: %.0f%%', name, percent)
			bar:SetValue(percent)
		else
			bar.showBar = false
		end
	else
		bar.showBar = false
	end

	DB:SetVisibility(bar) -- lower visibility because of using showBar variable

	wipe(bar.list)
end

function DB:ThreatBar_Toggle()
	local bar = DB.StatusBars.Threat
	bar.db = DB.db.threat

	if bar.db.enable then
		E:EnableMover(bar.holder.mover:GetName())

		DB:RegisterEvent('PLAYER_TARGET_CHANGED', 'ThreatBar_Update')
		DB:RegisterEvent('UNIT_THREAT_LIST_UPDATE', 'ThreatBar_Update')
		DB:RegisterEvent('GROUP_ROSTER_UPDATE', 'ThreatBar_Update')
		DB:RegisterEvent('UNIT_FLAGS', 'ThreatBar_Update')
		DB:RegisterEvent('UNIT_PET', 'ThreatBar_Update')

		DB:ThreatBar_Update()
	else
		E:DisableMover(bar.holder.mover:GetName())

		DB:UnregisterEvent('PLAYER_TARGET_CHANGED')
		DB:UnregisterEvent('UNIT_THREAT_LIST_UPDATE')
		DB:UnregisterEvent('GROUP_ROSTER_UPDATE')
		DB:UnregisterEvent('UNIT_FLAGS')
		DB:UnregisterEvent('UNIT_PET')
	end
end

function DB:ThreatBar()
	local Threat = DB:CreateBar('ElvUI_ThreatBar', 'Threat', DB.ThreatBar_Update, nil, nil, {'TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -245})
	Threat:SetMinMaxValues(0, 100)
	Threat.list = {}

	E:CreateMover(Threat.holder, 'ThreatBarMover', L["Threat Bar"], nil, nil, nil, nil, nil, 'databars,threat')

	DB:ThreatBar_Toggle()
end
