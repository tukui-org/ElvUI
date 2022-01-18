local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local displayString = ''

local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars

local function OnEvent(self)
	if E:XPIsLevelMax() then
		displayString = L['Max Level']
	else
		CurrentXP, XPToLevel, RestedXP = UnitXP('player'), UnitXPMax('player'), GetXPExhaustion()

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = E:Round(remainXP / XPToLevel)

		-- values we also use in OnEnter
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = E:Round(CurrentXP / XPToLevel) * 100, E:ShortValue(remainXP)

		local textFormat = E.global.datatexts.settings.Experience.textFormat
		if textFormat == 'PERCENT' then
			displayString = format('%d%%', PercentXP)
		elseif textFormat == 'CURMAX' then
			displayString = format('%s - %s', E:ShortValue(CurrentXP), E:ShortValue(XPToLevel))
		elseif textFormat == 'CURPERC' then
			displayString = format('%s - %d%%', E:ShortValue(CurrentXP), PercentXP)
		elseif textFormat == 'CUR' then
			displayString = format('%s', E:ShortValue(CurrentXP))
		elseif textFormat == 'REM' then
			displayString = format('%s', RemainXP)
		elseif textFormat == 'CURREM' then
			displayString = format('%s - %s', E:ShortValue(CurrentXP), RemainXP)
		elseif textFormat == 'CURPERCREM' then
			displayString = format('%s - %d%% (%s)', E:ShortValue(CurrentXP), PercentXP, RemainXP)
		end

		if RestedXP and RestedXP > 0 then
			PercentRested = E:Round(RestedXP / XPToLevel) * 100

			if textFormat == 'PERCENT' then
				displayString = displayString..format(' R:%d%%', PercentRested)
			elseif textFormat == 'CURPERC' then
				displayString = displayString..format(' R:%s [%d%%]', E:ShortValue(RestedXP), PercentRested)
			elseif textFormat ~= 'NONE' then
				displayString = displayString..format(' R:%s', E:ShortValue(RestedXP))
			end
		end
	end

	self.text:SetText(displayString)
end

local function OnEnter()
	if E:XPIsLevelMax() then return end

	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(L["Experience"])
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%.2f%%)', CurrentXP, XPToLevel, PercentXP), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %d (%.2f%% - %.2f '..L["Bars"]..')', RemainXP, RemainTotal, RemainBars), 1, 1, 1)

	if RestedXP then
		DT.tooltip:AddDoubleLine(L["Rested:"], format('+%d (%.2f%%)', RestedXP, PercentRested), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Experience', nil, {'PLAYER_XP_UPDATE', 'DISABLE_XP_GAIN', 'ENABLE_XP_GAIN', 'UPDATE_EXHAUSTION'}, OnEvent, nil, nil, OnEnter, nil, _G.COMBAT_XP_GAIN)
