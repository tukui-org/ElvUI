local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin

local UnitStat = UnitStat
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization

local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local PRIMARY_STAT = gsub(SPEC_FRAME_PRIMARY_STAT, '[:：%s]-%%s$', '')
local NOT_APPLICABLE = NOT_APPLICABLE

local displayString = ''

local function OnEvent(panel)
	local current = E.Retail and GetSpecialization() or nil
	local spec = DT.SPECIALIZATION_CACHE[current]
	local stat = spec and spec.statID

	local name = stat and _G['SPELL_STAT'..stat..'_NAME']
	if name then
		panel.text:SetFormattedText(displayString, name..': ', UnitStat('player', stat))
	else
		panel.text:SetText(NOT_APPLICABLE)
	end
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s', hex, '%.f|r')
end

DT:RegisterDatatext('Primary Stat', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, PRIMARY_STAT, nil, ApplySettings)
