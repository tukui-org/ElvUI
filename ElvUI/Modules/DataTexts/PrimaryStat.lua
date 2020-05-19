local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetNumSpecializations = GetNumSpecializations
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization
local UnitStat = UnitStat
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local SPEC_FRAME_PRIMARY_STAT = SPEC_FRAME_PRIMARY_STAT

local displayString, lastPanel = ''

local SPEC_STAT_STRINGS = {
	[_G.LE_UNIT_STAT_STRENGTH]	= _G.SPEC_FRAME_PRIMARY_STAT_STRENGTH,
	[_G.LE_UNIT_STAT_AGILITY]	= _G.SPEC_FRAME_PRIMARY_STAT_AGILITY,
	[_G.LE_UNIT_STAT_INTELLECT]	= _G.SPEC_FRAME_PRIMARY_STAT_INTELLECT,
}

local SPECIALIZATION_CACHE = {}

local function OnEvent(self, event)
	if not next(SPECIALIZATION_CACHE) then
		for index = 1, GetNumSpecializations() do
			local id, _, _, _, _, statID = GetSpecializationInfo(index)
			if id then
				SPECIALIZATION_CACHE[id] = { statID = statID }
			end
		end
	end

	local StatID = SPECIALIZATION_CACHE[GetSpecialization()].statID
	self.text:SetFormattedText(displayString, SPEC_STAT_STRINGS[StatID]..': ', UnitStat("player", StatID))

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
