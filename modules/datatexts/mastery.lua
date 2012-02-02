local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local lastPanel
local displayString = '';

local function OnEvent(self, event)
	lastPanel = self
	--STAT_MASTERY
	local masteryspell, masteryTag
	if GetCombatRating(CR_MASTERY) ~= 0 and GetPrimaryTalentTree() then
		masteryTag = STAT_MASTERY..": "
		self.text:SetFormattedText(displayString, masteryTag, GetMastery())
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	GameTooltip:ClearLines()

	local mastery = GetMastery();
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY);
	mastery = string.format("%.2f", mastery);

	local masteryKnown = IsSpellKnown(CLASS_MASTERY_SPELLS[E.myclass]);
	local primaryTalentTree = GetPrimaryTalentTree();
	if (masteryKnown and primaryTalentTree) then
		local masterySpell, masterySpell2 = GetTalentTreeMasterySpells(primaryTalentTree);
		if (masterySpell) then
			GameTooltip:AddSpellByID(masterySpell);
		end
	end
	GameTooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", "%s", hex, "%.2f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true
--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Mastery', {"MASTERY_UPDATE"}, OnEvent, nil, nil, OnEnter)
