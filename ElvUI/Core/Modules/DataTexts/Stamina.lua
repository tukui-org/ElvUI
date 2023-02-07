local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat

local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local ITEM_MOD_STAMINA_SHORT = ITEM_MOD_STAMINA_SHORT
local LE_UNIT_STAT_STAMINA = LE_UNIT_STAT_STAMINA

local displayString, db = ''

local function OnEvent(self)
	if db.NoLabel then
		self.text:SetFormattedText(displayString, UnitStat('player', LE_UNIT_STAT_STAMINA))
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or ITEM_MOD_STAMINA_SHORT..': ', UnitStat('player', LE_UNIT_STAT_STAMINA))
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('Stamina', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_STAMINA_SHORT, nil, ApplySettings)
