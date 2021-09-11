local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

local strjoin = strjoin

local GetHitModifier = GetHitModifier
local STAT_HIT_CHANCE = STAT_HIT_CHANCE
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local displayString = ""
local lastPanel

local function OnEvent(self)
	lastPanel = self

	local hitChance = GetHitModifier()

	if E.global.datatexts.settings.Hit.NoLabel then
		self.text:SetFormattedText(displayString, hitChance)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Hit.Label ~= '' and E.global.datatexts.settings.Hit.Label or STAT_HIT_CHANCE..': ', hitChance)
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Hit.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.Hit.decimalLength..'f%%|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Hit", STAT_CATEGORY_ENHANCEMENTS, {"COMBAT_RATING_UPDATE"}, OnEvent, nil, nil, nil, nil, STAT_HIT_CHANCE, nil, ValueColorUpdate)
