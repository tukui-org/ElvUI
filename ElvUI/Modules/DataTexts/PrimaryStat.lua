local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local select = select
local strjoin = strjoin
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization
local UnitStat = UnitStat
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local SPEC_FRAME_PRIMARY_STAT = SPEC_FRAME_PRIMARY_STAT

local displayString, statID, lastPanel = ''

local SPEC_STAT_STRINGS = {
	[_G.LE_UNIT_STAT_STRENGTH]	= _G.SPEC_FRAME_PRIMARY_STAT_STRENGTH,
	[_G.LE_UNIT_STAT_AGILITY]	= _G.SPEC_FRAME_PRIMARY_STAT_AGILITY,
	[_G.LE_UNIT_STAT_INTELLECT]	= _G.SPEC_FRAME_PRIMARY_STAT_INTELLECT,
}

local function OnEvent(self, event)
	if statID == nil or (event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_ENTERING_WORLD') then
		statID = select(6, GetSpecializationInfo(GetSpecialization()))
	end

	local primStat = UnitStat("player", statID)

	self.text:SetFormattedText(displayString, SPEC_STAT_STRINGS[statID]..': ', primStat)

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end

E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Primary Stat', STAT_CATEGORY_ATTRIBUTES, { "UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE" }, OnEvent, nil, nil, nil, nil, SPEC_FRAME_PRIMARY_STAT:gsub('[:：%s]-%%s$',''))
