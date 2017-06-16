local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local UnitSpellHaste = UnitSpellHaste
local GetRangedHaste = GetRangedHaste
local GetMeleeHaste = GetMeleeHaste
local STAT_HASTE = STAT_HASTE

local displayNumberString = ''
local lastPanel;

local function OnEvent(self)
	local hasteRating
	if E.role == "Caster" then
		hasteRating = UnitSpellHaste("player")
	elseif E.myclass == "HUNTER" then
		hasteRating = GetRangedHaste()
	else
		hasteRating = GetMeleeHaste()
	end
	self.text:SetFormattedText(displayNumberString, STAT_HASTE, hasteRating)
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Haste', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "UNIT_SPELL_HASTE"}, OnEvent, nil, nil, nil, nil, STAT_HASTE)
