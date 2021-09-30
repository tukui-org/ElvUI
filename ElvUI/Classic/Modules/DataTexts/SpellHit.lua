local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetSpellHitModifier = GetSpellHitModifier

local displayString, lastPanel = ''

local function OnEvent(self)
	lastPanel = self

	self.text:SetFormattedText(displayString, GetSpellHitModifier())
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', L["Spell Hit"], ': ', hex, '%.2f%%|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Spell Hit', _G.STAT_CATEGORY_ENHANCEMENTS, {'COMBAT_RATING_UPDATE'}, OnEvent, nil, nil, nil, nil, 'Spell Hit')
