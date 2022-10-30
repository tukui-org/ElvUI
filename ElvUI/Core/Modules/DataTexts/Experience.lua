local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local GetXPExhaustion = GetXPExhaustion

local CurrentXP, XPToLevel, PercentRested, PercentXP, RemainXP, RemainTotal, RemainBars
local RestedXP, QuestLogXP = 0, 0

local function OnEvent(self)
	local displayString = ''

	if E:XPIsLevelMax() then
		displayString = E:XPIsUserDisabled() and L["Disabled"] or L["Max Level"]
	else
		CurrentXP, XPToLevel, RestedXP = UnitXP('player'), UnitXPMax('player'), (GetXPExhaustion() or 0)
		if XPToLevel <= 0 then XPToLevel = 1 end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, E:ShortValue(remainXP)

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

		local isRested = RestedXP > 0
		if isRested then
			PercentRested = (RestedXP / XPToLevel) * 100

			if textFormat == 'PERCENT' then
				displayString = format('%s R:%d%%', displayString, PercentRested)
			elseif textFormat == 'CURPERC' then
				displayString = format('%s R:%s [%d%%]', displayString, E:ShortValue(RestedXP), PercentRested)
			elseif textFormat ~= 'NONE' then
				displayString = format('%s R:%s', displayString, E:ShortValue(RestedXP))
			end
		end
	end

	self.text:SetText(displayString)
end

local function OnEnter()
	if E:XPIsLevelMax() then return end

	DT.tooltip:ClearLines()
	DT.tooltip:AddDoubleLine(L["Experience"], format('%s %d', L["Level"], E.mylevel))

	if CurrentXP then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%.2f%%)', CurrentXP, XPToLevel, PercentXP), 1, 1, 1)
	end
	if RemainXP then
		DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %s (%.2f%% - %d '..L["Bars"]..')', RemainXP, RemainTotal, RemainBars), 1, 1, 1)
	end
	if QuestLogXP > 0 then
		DT.tooltip:AddDoubleLine(L["Quest Log XP:"], format(' %d (%.2f%%)', QuestLogXP, (QuestLogXP / XPToLevel) * 100), 1, 1, 1)
	end
	if RestedXP > 0 then
		DT.tooltip:AddDoubleLine(L["Rested:"], format('%d (%.2f%%)', RestedXP, PercentRested), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Experience', nil, {'PLAYER_XP_UPDATE', 'DISABLE_XP_GAIN', 'ENABLE_XP_GAIN', 'UPDATE_EXHAUSTION'}, OnEvent, nil, nil, OnEnter, nil, _G.COMBAT_XP_GAIN)
