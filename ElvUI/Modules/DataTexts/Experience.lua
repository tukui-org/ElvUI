local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local IsXPUserDisabled, GetXPExhaustion = IsXPUserDisabled, GetXPExhaustion
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local displayString = ''
local CurrentXP, XPToLevel, RestedXP

local function OnEvent(self)
	if IsXPUserDisabled() then
		displayString = 'Disabled'
	elseif IsPlayerAtEffectiveMaxLevel() then
		displayString = L['Max Level']
	else
		CurrentXP, XPToLevel, RestedXP = UnitXP('player'), UnitXPMax('player'), GetXPExhaustion()
		local textFormat = E.global.datatexts.settings.Experience.textFormat

		if textFormat == 'PERCENT' then
			displayString = format('%d%%', CurrentXP / XPToLevel * 100)
		elseif textFormat == 'CURMAX' then
			displayString = format('%s - %s', E:ShortValue(CurrentXP), E:ShortValue(XPToLevel))
		elseif textFormat == 'CURPERC' then
			displayString = format('%s - %d%%', E:ShortValue(CurrentXP), CurrentXP / XPToLevel * 100)
		elseif textFormat == 'CUR' then
			displayString = format('%s', E:ShortValue(CurrentXP))
		elseif textFormat == 'REM' then
			displayString = format('%s', E:ShortValue(XPToLevel - CurrentXP))
		elseif textFormat == 'CURREM' then
			displayString = format('%s - %s', E:ShortValue(CurrentXP), E:ShortValue(XPToLevel - CurrentXP))
		elseif textFormat == 'CURPERCREM' then
			displayString = format('%s - %d%% (%s)', E:ShortValue(CurrentXP), CurrentXP / XPToLevel * 100, E:ShortValue(XPToLevel - CurrentXP))
		end

		if RestedXP and RestedXP > 0 then
			if textFormat == 'PERCENT' then
				displayString = displayString..format(' R:%d%%', RestedXP / XPToLevel * 100)
			elseif textFormat == 'CURPERC' then
				displayString = displayString..format(' R:%s [%d%%]', E:ShortValue(RestedXP), RestedXP / XPToLevel * 100)
			elseif textFormat ~= 'NONE' then
				displayString = displayString..format(' R:%s', E:ShortValue(RestedXP))
			end
		end
	end

	self.text:SetText(displayString)
end

local function OnEnter()
	if (IsXPUserDisabled() or IsPlayerAtEffectiveMaxLevel()) then return end

	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(L["Experience"])
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%.2f%%)', CurrentXP, XPToLevel, E:Round(CurrentXP/XPToLevel * 100)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %d (%.2f%% - %.2f '..L["Bars"]..')', XPToLevel - CurrentXP, E:Round((XPToLevel - CurrentXP) / XPToLevel * 100), 20 * (XPToLevel - CurrentXP) / XPToLevel), 1, 1, 1)

	if RestedXP then
		DT.tooltip:AddDoubleLine(L["Rested:"], format('+%d (%.2f%%)', RestedXP, E:Round(RestedXP / XPToLevel * 100)), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Experience', nil, {'PLAYER_XP_UPDATE', 'DISABLE_XP_GAIN', 'ENABLE_XP_GAIN', 'UPDATE_EXHAUSTION'}, OnEvent, nil, nil, OnEnter, nil, _G.COMBAT_XP_GAIN)
