local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local displayNumberString = ''
local lastPanel;
local join = string.join
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization
local UnitStat = UnitStat

local statID

local SPEC_STAT_STRINGS = {
	[LE_UNIT_STAT_STRENGTH] = SPEC_FRAME_PRIMARY_STAT_STRENGTH,
	[LE_UNIT_STAT_AGILITY] = SPEC_FRAME_PRIMARY_STAT_AGILITY,
	[LE_UNIT_STAT_INTELLECT] = SPEC_FRAME_PRIMARY_STAT_INTELLECT,
}

local function OnEvent(self, event, ...)
	if statID == nil or (event == 'ACTIVE_TALENT_GROUP_CHANGED' or event == 'PLAYER_ENTERING_WORLD') then
		statID = select(6, GetSpecializationInfo(GetSpecialization()))
	end

	local primStat = UnitStat("player", statID)

	self.text:SetFormattedText(displayNumberString, L[SPEC_STAT_STRINGS[statID]..': '], primStat)

	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join("", "%s", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Primary Stat', 'Primary', { "UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE" }, OnEvent)
