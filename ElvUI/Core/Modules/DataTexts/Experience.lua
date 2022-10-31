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
		local remainPercent = E:Round(remainXP / XPToLevel, 4)

		-- values we also use in OnEnter
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = E:Round(CurrentXP / XPToLevel, 4) * 100, E:ShortValue(remainXP)

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
			PercentRested = E:Round(RestedXP / XPToLevel, 4) * 100

			if textFormat == 'PERCENT' then
				displayString = displayString..format(' R:%.2f%%', PercentRested)
			elseif textFormat == 'CURPERC' then
				displayString = displayString..format(' R:%s [%.2f%%]', E:ShortValue(RestedXP), PercentRested)
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
	DT.tooltip:AddDoubleLine(L["Experience"], format('%s %d', L["Level"], E.mylevel))
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(L["XP:"], format(' %s / %s (%.2f%%)', E:ShortValue(CurrentXP), E:ShortValue(XPToLevel), PercentXP), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %s (%.2f%% - %.2f '..L["Bars"]..')', RemainXP, RemainTotal, RemainBars), 1, 1, 1)

	if RestedXP and RestedXP > 0 then
		DT.tooltip:AddDoubleLine(L["Rested:"], format('+%s (%.2f%%)', E:ShortValue(RestedXP), PercentRested), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Experience', nil, {'PLAYER_XP_UPDATE', 'DISABLE_XP_GAIN', 'ENABLE_XP_GAIN', 'UPDATE_EXHAUSTION'}, OnEvent, nil, nil, OnEnter, nil, _G.COMBAT_XP_GAIN)
