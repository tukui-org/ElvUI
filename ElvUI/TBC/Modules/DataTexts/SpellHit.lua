local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")

local strjoin = strjoin
local GetCombatRatingBonus = GetCombatRatingBonus

local CR_HIT_SPELL = CR_HIT_SPELL
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString = ""
local lastPanel


-- Still not 100% accurate: GetCombatRatingBonus(CR_HIT_SPELL) always displays the
-- same value as the PaperDoll UI but does not account for GetSpellHitModifier()
-- Example: GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier() returns 21 spell hit
-- when dropping a 3% spellhit totem on a naked character.

function GetRealSpellHit()
	local spellHitRating = GetCombatRatingBonus(CR_HIT_SPELL)

	-- Set it to 0 if it returns nil, this way it can't error
	if spellHitRating == nil then spellHitRating = 0 end

	return spellHitRating
end

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, GetRealSpellHit())
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", L["Spell Hit"], ": ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Spell Hit", STAT_CATEGORY_ENHANCEMENTS, {"COMBAT_RATING_UPDATE"}, OnEvent, nil, nil, nil, nil, "Spell Hit")
