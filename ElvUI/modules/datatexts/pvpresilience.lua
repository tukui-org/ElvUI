local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local lastPanel
local resilTag = STAT_RESILIENCE..": "
local displayString = '';
local join = string.join

local function OnEvent(self, event)
	lastPanel = self

	local ratingBonus = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN);
	local damageReduction = ratingBonus + GetModResilienceDamageReduction();

	self.text:SetFormattedText(displayString, resilTag, damageReduction)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local resilienceRating = BreakUpLargeNumbers(GetCombatRating(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN));
	local ratingBonus = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN);
	local damageReduction = ratingBonus + GetModResilienceDamageReduction();

	DT.tooltip:AddDoubleLine(STAT_RESILIENCE, format("%.2F%%", damageReduction), 1, 1, 1);
	DT.tooltip:AddLine(RESILIENCE_TOOLTIP, nil, nil, nil, true)
	DT.tooltip:AddLine(format(STAT_RESILIENCE_BASE_TOOLTIP, resilienceRating, ratingBonus));

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
DT:RegisterDatatext('PvP Resilience', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter)
