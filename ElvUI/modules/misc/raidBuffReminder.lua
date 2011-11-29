local E, L, DF = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local RBR = E:NewModule('RaidBuffReminder', 'AceEvent-3.0');

E.RaidBuffReminder = RBR

RBR.Spell1Buffs = {
	94160, --Flask of Flowing Water
	79470, --Flask of the Draconic Mind
	79471, --Flask of the Winds
	79472, --Flask of Titanic Strength
	79638, --Flask of Enhancement-STR
	79639, --Flask of Enhancement-AGI
	79640, --Flask of Enhancement-INT
	92679, --Flask of battle
	79469, --Flask of Steelskin
}

RBR.BattleElixir = {
	--Scrolls
	89343, --Agility
	63308, --Armor 
	89347, --Int
	89342, --Spirit
	63306, --Stam
	89346, --Strength
	
	--Elixirs
	79481, --Hit
	79632, --Haste
	79477, --Crit
	79635, --Mastery
	79474, --Expertise
	79468, --Spirit
}
	
RBR.GuardianElixir = {
	79480, --Armor
	79631, --Resistance+90
}
	
RBR.Spell2Buffs = {
	87545, --90 STR
	87546, --90 AGI
	87547, --90 INT
	87548, --90 SPI
	87549, --90 MAST
	87550, --90 HIT
	87551, --90 CRIT
	87552, --90 HASTE
	87554, --90 DODGE
	87555, --90 PARRY
	87635, --90 EXP
	87556, --60 STR
	87557, --60 AGI
	87558, --60 INT
	87559, --60 SPI
	87560, --60 MAST
	87561, --60 HIT
	87562, --60 CRIT
	87563, --60 HASTE
	87564, --60 DODGE
	87634, --60 EXP
	87554, --Seafood Feast
}

RBR.Spell3Buffs = {
	1126, -- "Mark of the wild"
	90363, --"Embrace of the Shale Spider"
	20217, --"Greater Blessing of Kings",
}

RBR.Spell4Buffs = {
	469, -- Commanding
	6307, -- Blood Pact
	90364, -- Qiraji Fortitude
	72590, -- Drums of fortitude
	21562, -- Fortitude	
}

RBR.Spell5Buffs = {
	61316, --"Dalaran Brilliance"
	1459, --"Arcane Brilliance"	
}

RBR.CasterSpell6Buffs = {
	5675, --"Mana Spring Totem"
	19740, --"Blessing of Might"
}

RBR.MeleeSpell6Buffs = {
	19740, --"Blessing of Might" placing it twice because i like the icon better :D code will stop after this one is read, we want this first 
	30808, --"Unleashed Rage"
	53138, --Abom Might
	19506, --Trushot
	19740, --"Blessing of Might"
}

function RBR:CheckFilterForActiveBuff(filter)
	local spellName, texture
	for _, spell in pairs(filter) do
		spellName, _, texture = GetSpellInfo(spell)
		if UnitAura("player", spellName) then
			return true, texture
		end
	end

	return false, texture
end

function RBR:UpdateReminder(event, unit)
	if (event == "UNIT_AURA" and unit ~= "player") then return end
	local frame = self.frame
	
	if E.Role == 'Caster' then
		self.Spell6Buffs = self.CasterSpell6Buffs
	else
		self.Spell6Buffs = self.MeleeSpell6Buffs
	end
	
	local hasFlask, flaskTex = self:CheckFilterForActiveBuff(self.Spell1Buffs)
	if hasFlask then
		frame.spell1.t:SetTexture(flaskTex)
		frame.spell1:SetAlpha(0.2)
	else
		local hasBattle, battleTex = self:CheckFilterForActiveBuff(self.BattleElixir)
		local hasGuardian, guardianTex = self:CheckFilterForActiveBuff(self.GuardianElixir)

		if (hasBattle and hasGuardian) or not hasGuardian and hasBattle then
			frame.spell1:SetAlpha(1)
			frame.spell1.t:SetTexture(battleTex)				
		elseif hasGuardian then
			frame.spell1:SetAlpha(1)
			frame.spell1.t:SetTexture(guardianTex)		
		else
			frame.spell1:SetAlpha(1)
			frame.spell1.t:SetTexture(flaskTex)
		end
	end
	
	for i = 2, 6 do
		local hasBuff, texture = self:CheckFilterForActiveBuff(self['Spell'..i..'Buffs'])
		frame['spell'..i].t:SetTexture(texture)
		if hasBuff then
			frame['spell'..i]:SetAlpha(0.2)
		else
			frame['spell'..i]:SetAlpha(1)
		end
	end
end

function RBR:CreateButton(relativeTo, isFirst, isLast)
	local button = CreateFrame("Frame", name, RaidBuffReminder)
	button:SetTemplate('Default')
	button:Size(E.RBRWidth - 4)
	if isFirst then
		button:Point("TOP", relativeTo, "TOP", 0, -2)
	else
		button:Point("TOP", relativeTo, "BOTTOM", 0, -1)
	end
	
	if isLast then
		button:Point("BOTTOM", RaidBuffReminder, "BOTTOM", 0, 2)
	end
	
	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:Point("TOPLEFT", 2, -2)
	button.t:Point("BOTTOMRIGHT", -2, 2)
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	return button
end

function RBR:Initialize()
	local frame = CreateFrame('Frame', 'RaidBuffReminder', Minimap)
	frame:SetTemplate('Default')
	frame:Width(E.RBRWidth)
	frame:Point('TOPLEFT', Minimap.backdrop, 'TOPRIGHT', 1, 0)
	frame:Point('BOTTOMLEFT', Minimap.backdrop, 'BOTTOMRIGHT', 1, 0)

	frame.spell1 = self:CreateButton(frame, true)
	frame.spell2 = self:CreateButton(frame.spell1)
	frame.spell3 = self:CreateButton(frame.spell2)
	frame.spell4 = self:CreateButton(frame.spell3)
	frame.spell5 = self:CreateButton(frame.spell4)
	frame.spell6 = self:CreateButton(frame.spell5, nil, true)
	
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", 'UpdateReminder')
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", 'UpdateReminder')
	self:RegisterEvent("UNIT_AURA", 'UpdateReminder')
	self:RegisterEvent("PLAYER_REGEN_ENABLED", 'UpdateReminder')
	self:RegisterEvent("PLAYER_REGEN_DISABLED", 'UpdateReminder')
	self:RegisterEvent("PLAYER_ENTERING_WORLD", 'UpdateReminder')
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", 'UpdateReminder')
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", 'UpdateReminder')
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", 'UpdateReminder')
	self.frame = frame
end

E:RegisterModule(RBR:GetName())