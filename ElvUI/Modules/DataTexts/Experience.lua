local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local IsXPUserDisabled, GetXPExhaustion = IsXPUserDisabled, GetXPExhaustion
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel

local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars

local function OnEvent(self)
	local displayString = ''
	if IsXPUserDisabled() then
		displayString = L["Disabled"]
	elseif IsPlayerAtEffectiveMaxLevel() then
		displayString = L["Max Level"]
	else
		CurrentXP, XPToLevel, RestedXP = UnitXP('player'), UnitXPMax('player'), GetXPExhaustion()
		if XPToLevel <= 0 then XPToLevel = 1 end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel

		-- values we also use in OnEnter
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, E:ShortValue(remainXP)

		local textFormat = E.global.datatexts.settings.Experience.textFormat
		if textFormat == 'PERCENT' then
			displayString = format('%.2f%%', PercentXP)
		elseif textFormat == 'CURMAX' then
			displayString = format('%s - %s', E:ShortValue(CurrentXP), E:ShortValue(XPToLevel))
		elseif textFormat == 'CURPERC' then
			displayString = format('%s - %.2f%%', E:ShortValue(CurrentXP), PercentXP)
		elseif textFormat == 'CUR' then
			displayString = format('%s', E:ShortValue(CurrentXP))
		elseif textFormat == 'REM' then
			displayString = format('%s', RemainXP)
		elseif textFormat == 'CURREM' then
			displayString = format('%s - %s', E:ShortValue(CurrentXP), RemainXP)
		elseif textFormat == 'CURPERCREM' then
			displayString = format('%s - %.2f%% (%s)', E:ShortValue(CurrentXP), PercentXP, RemainXP)
		end

		if RestedXP and RestedXP > 0 then
			PercentRested = (RestedXP / XPToLevel) * 100

			if textFormat == 'PERCENT' then
				displayString = format('%s R:%.2f%%', displayString, PercentRested)
			elseif textFormat == 'CURPERC' then
				displayString = format('%s R:%s [%.2f%%]', displayString, E:ShortValue(RestedXP), PercentRested)
			elseif textFormat ~= 'NONE' then
				displayString = format('%s R:%s', displayString, E:ShortValue(RestedXP))
			end
		end
	end

	self.text:SetText(displayString)
end

local function OnEnter()
	if IsXPUserDisabled() or IsPlayerAtEffectiveMaxLevel() then return end

	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(L["Experience"])
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%.2f%%)', CurrentXP, XPToLevel, PercentXP), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %s (%.2f%% - %d '..L["Bars"]..')', RemainXP, RemainTotal, RemainBars), 1, 1, 1)

	if RestedXP and RestedXP > 0 then
		DT.tooltip:AddDoubleLine(L["Rested:"], format('+%d (%.2f%%)', RestedXP, PercentRested), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Experience', nil, {'PLAYER_XP_UPDATE', 'DISABLE_XP_GAIN', 'ENABLE_XP_GAIN', 'UPDATE_EXHAUSTION'}, OnEvent, nil, nil, OnEnter, nil, _G.COMBAT_XP_GAIN)
