local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local lastPanel
local powerTag = STAT_PVP_POWER..": "
local displayString = '';
local join = string.join

local function OnEvent(self, event)
	lastPanel = self

	self.text:SetFormattedText(displayString, powerTag, GetCombatRatingBonus(CR_PVP_POWER))
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local pvpPower = BreakUpLargeNumbers(GetCombatRating(CR_PVP_POWER));
	local pvpDamage = GetPvpPowerDamage();
	local pvpHealing = GetPvpPowerHealing();

	if (pvpHealing > pvpDamage) then
		DT.tooltip:AddDoubleLine(STAT_PVP_POWER, format("%.2F%%", pvpHealing).." ("..SHOW_COMBAT_HEALING..")", 1, 1, 1);
		DT.tooltip:AddLine(PVP_POWER_TOOLTIP, nil, nil, nil, true)
		DT.tooltip:AddLine(format(PVP_POWER_HEALING_TOOLTIP, pvpPower, pvpHealing, pvpDamage))
	else
		DT.tooltip:AddDoubleLine(STAT_PVP_POWER, format("%.2F%%", pvpDamage).." ("..DAMAGE..")", 1, 1, 1);
		DT.tooltip:AddLine(PVP_POWER_TOOLTIP, nil, nil, nil, true)
		DT.tooltip:AddLine(format(PVP_POWER_DAMAGE_TOOLTIP, pvpPower, pvpDamage, pvpHealing))
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
DT:RegisterDatatext('PvP Power', {"PVP_POWER_UPDATE"}, OnEvent, nil, nil, OnEnter)
