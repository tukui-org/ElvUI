local E, L, V, P, G = unpack(select(2, ...)) --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin
local UnitStat = UnitStat
local GetSpecialization = GetSpecialization
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local PRIMARY_STAT = SPEC_FRAME_PRIMARY_STAT:gsub('[:：%s]-%%s$','')
local displayString, lastPanel = ''

local function OnEvent(self)
	local StatID = DT.SPECIALIZATION_CACHE[GetSpecialization()] and DT.SPECIALIZATION_CACHE[GetSpecialization()].statID

	local name = StatID and _G['SPELL_STAT'..StatID..'_NAME']
	if name then
		self.text:SetFormattedText(displayString, name..': ', UnitStat('player', StatID))
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s', hex, '%.f|r')

	if lastPanel then OnEvent(lastPanel) end
end

E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Primary Stat', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE' }, OnEvent, nil, nil, nil, nil, PRIMARY_STAT, nil, ValueColorUpdate)
