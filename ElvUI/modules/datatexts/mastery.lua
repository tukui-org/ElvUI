local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local DT = E:GetModule('DataTexts')

local lastPanel
local displayString = '';
local join = string.join

local function OnEvent(self, event)
	lastPanel = self
	--STAT_MASTERY
	local masteryspell, masteryTag
	if GetCombatRating(CR_MASTERY) ~= 0 and GetSpecialization() then
		masteryTag = STAT_MASTERY..": "
		self.text:SetFormattedText(displayString, masteryTag, GetMasteryEffect())
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	DT.tooltip:ClearLines()

	local primaryTalentTree = GetSpecialization();
	
	if (primaryTalentTree) then
		local masterySpell = GetSpecializationMasterySpells(primaryTalentTree);
		local masteryKnown = IsSpellKnown(masterySpell);
		
		if (masteryKnown) then
			DT.tooltip:AddSpellByID(masterySpell);
		end
	end
	DT.tooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s", hex, "%.2f%%|r")

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
