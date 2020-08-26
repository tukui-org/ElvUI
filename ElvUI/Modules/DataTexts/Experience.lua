local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local IsXPUserDisabled, GetXPExhaustion = IsXPUserDisabled, GetXPExhaustion
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
local displayString = ''

local function OnEvent(self)
	if IsXPUserDisabled() then
		displayString = 'Disabled'
	elseif E.mylevel == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] then
		displayString = 'Max'
	else
		local cur, max = UnitXP('player'), UnitXPMax('player')
		local rested = GetXPExhaustion()
		local textFormat = E.DataBars.db.experience.textFormat

		if rested and rested > 0 then
			if textFormat == 'PERCENT' then
				displayString = format('%d%% R:%d%%', cur / max * 100, rested / max * 100)
			elseif textFormat == 'CURMAX' then
				displayString = format('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max), E:ShortValue(rested))
			elseif textFormat == 'CURPERC' then
				displayString = format('%s - %d%% R:%s [%d%%]', E:ShortValue(cur), cur / max * 100, E:ShortValue(rested), rested / max * 100)
			elseif textFormat == 'CUR' then
				displayString = format('%s R:%s', E:ShortValue(cur), E:ShortValue(rested))
			elseif textFormat == 'REM' then
				displayString = format('%s R:%s', E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == 'CURREM' then
				displayString = format('%s - %s R:%s', E:ShortValue(cur), E:ShortValue(max - cur), E:ShortValue(rested))
			elseif textFormat == 'CURPERCREM' then
				displayString = format('%s - %d%% (%s) R:%s', E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur), E:ShortValue(rested))
			end
		else
			if textFormat == 'PERCENT' then
				displayString = format('%d%%', cur / max * 100)
			elseif textFormat == 'CURMAX' then
				displayString = format('%s - %s', E:ShortValue(cur), E:ShortValue(max))
			elseif textFormat == 'CURPERC' then
				displayString = format('%s - %d%%', E:ShortValue(cur), cur / max * 100)
			elseif textFormat == 'CUR' then
				displayString = format('%s', E:ShortValue(cur))
			elseif textFormat == 'REM' then
				displayString = format('%s', E:ShortValue(max - cur))
			elseif textFormat == 'CURREM' then
				displayString = format('%s - %s', E:ShortValue(cur), E:ShortValue(max - cur))
			elseif textFormat == 'CURPERCREM' then
				displayString = format('%s - %d%% (%s)', E:ShortValue(cur), cur / max * 100, E:ShortValue(max - cur))
			end
		end
	end

	self.text:SetText(displayString)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local cur, max = UnitXP('player'), UnitXPMax('player')
	local rested = GetXPExhaustion()
	DT.tooltip:AddLine(L["Experience"])
	DT.tooltip:AddLine(' ')

	DT.tooltip:AddDoubleLine(L["XP:"], format(' %d / %d (%d%%)', cur, max, E:Round(cur/max * 100)), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Remaining:"], format(' %d (%d%% - %d '..L["Bars"]..')', max - cur, E:Round((max - cur) / max * 100), 20 * (max - cur) / max), 1, 1, 1)

	if rested then
		DT.tooltip:AddDoubleLine(L["Rested:"], format('+%d (%d%%)', rested, E:Round(rested / max * 100)), 1, 1, 1)
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext('Experience', nil, {'PLAYER_XP_UPDATE', 'DISABLE_XP_GAIN', 'ENABLE_XP_GAIN', 'UPDATE_EXHAUSTION'}, OnEvent, nil, nil, OnEnter, nil, _G.COMBAT_XP_GAIN)
