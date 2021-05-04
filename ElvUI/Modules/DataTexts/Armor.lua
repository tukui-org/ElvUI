local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local select = select
local format = format
local strjoin = strjoin
local UnitLevel = UnitLevel
local UnitArmor = UnitArmor
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES
local ARMOR = ARMOR

local chanceString = '%.2f%%'
local displayString, lastPanel, effectiveArmor = ''

local function OnEvent(self)
	effectiveArmor = select(2, UnitArmor('player'))

	if E.global.datatexts.settings.Armor.NoLabel then
		self.text:SetFormattedText(displayString, effectiveArmor)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Armor.Label ~= '' and E.global.datatexts.settings.Armor.Label or ARMOR..': ', effectiveArmor)
	end

	lastPanel = self
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(L["Mitigation By Level: "])
	DT.tooltip:AddLine(' ')

	local playerlvl = E.mylevel + 3
	for _ = 1, 4 do
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, playerlvl)
		DT.tooltip:AddDoubleLine(playerlvl,format(chanceString, armorReduction),1,1,1)
		playerlvl = playerlvl - 1
	end
	local lv = UnitLevel('target')
	if lv and lv > 0 and (lv > playerlvl + 3 or lv < playerlvl) then
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, lv)
		DT.tooltip:AddDoubleLine(lv, format(chanceString, armorReduction),1,1,1)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Armor.NoLabel and '' or '%s', hex, '%d|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Armor', STAT_CATEGORY_ATTRIBUTES, {'UNIT_STATS', 'UNIT_RESISTANCES', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, ARMOR, nil, ValueColorUpdate)
