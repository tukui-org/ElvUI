local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local RBR = E:NewModule('RaidBuffReminder', 'AceEvent-3.0');

E.RaidBuffReminder = RBR

--Stats, Stamina, Attack Power, Attack Speed, SpellPower, Spell Haste, Critical Strike, Mastery

RBR.Stats = {
	117667, --Legacy of The Emperor
	1126, -- Mark of The Wild
	20217, -- Blessing Of Kings
}

RBR.Stamina = {
	469, -- Commanding Shout
	6307, -- Imp. Blood Pact
	21562, -- Power Word: Fortitude
}

RBR.AttackPower = {
	19506, -- Trueshot Aura
	6673, -- Battle Shout
	57330, -- Horn of Winter
}

RBR.SpellPower = {
	77747, -- Burning Wrath
	109773, -- Dark Intent
	1459, -- Arcane Brilliance
}

RBR.AttackSpeed = {
	30809, -- Unleashed Rage
	113742, -- Swiftblade's Cunning
	55610, -- Improved Icy Talons
}

RBR.SpellHaste = {
	24907, -- Moonkin Aura
	49868, -- Mind Quickening
}

RBR.CriticalStrike = {
	19506, -- Trueshot Aura
	1459, -- Arcane Brilliance
	24932, -- Leader of The Pact
}

RBR.Mastery = {
	116956, --Grace of Air
	--118757, -- Legacy of the Wight Tiger <<Monk buff removed?
	19740, -- Blessing of Might
}

RBR.IndexTable = {
	[1] = RBR.Stats,
	[2] = RBR.Stamina,
	[3] = RBR.AttackPower,
	[4] = RBR.AttackSpeed,
	[5] = RBR.CriticalStrike,
	[6] = RBR.Mastery,
}

function RBR:CheckFilterForActiveBuff(filter)
	local spellName, texture
	for _, spell in pairs(filter) do
		spellName, _, texture = GetSpellInfo(spell)
		
		assert(spellName, spell..': ID is not correct.')
		
		if UnitAura("player", spellName) then
			return spellName, texture
		end
	end

	return false, texture
end

function RBR:UpdateReminder(event, unit)
	if (event == "UNIT_AURA" and unit ~= "player") then return end
	local frame = self.frame
	
	if E.role == 'Caster' then
		RBR.IndexTable[3] = RBR.SpellPower
		RBR.IndexTable[4] = RBR.SpellHaste
	else
		RBR.IndexTable[3] = RBR.AttackPower
		RBR.IndexTable[4] = RBR.AttackSpeed
	end
	
	
	for i = 1, 6 do
		local hasBuff, texture = self:CheckFilterForActiveBuff(self.IndexTable[i])
		frame['spell'..i].t:SetTexture(texture)
		if hasBuff then
			frame['spell'..i]:SetAlpha(0.2)
			frame['spell'..i].hasBuff = hasBuff
		else
			frame['spell'..i]:SetAlpha(1)
			frame['spell'..i].hasBuff = nil
		end
	end
end

function RBR:Button_OnEnter()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT", -4, -(self:GetHeight() + 5))
	GameTooltip:ClearLines()
	
	local id = self:GetID()
	
	if (id == 3 or id == 4) and E.role == 'Caster' then
		RBR.IndexTable[3] = RBR.SpellPower
		RBR.IndexTable[4] = RBR.SpellHaste
		
		GameTooltip:AddLine(_G["RAID_BUFF_"..id+2])
	elseif id >= 5 then
		GameTooltip:AddLine(_G["RAID_BUFF_"..id+2])
	else
		if E.role ~= "Caster" then
			RBR.IndexTable[3] = RBR.AttackPower
			RBR.IndexTable[4] = RBR.AttackSpeed
		end
		
		GameTooltip:AddLine(_G["RAID_BUFF_"..id])
	end

	GameTooltip:AddLine(" ")
	for _, spellID in pairs(RBR.IndexTable[id]) do
		local spellName = GetSpellInfo(spellID)
		if self.hasBuff == spellName then
			GameTooltip:AddLine(spellName, 1, 0, 0)
		else
			GameTooltip:AddLine(spellName, 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

function RBR:Button_OnLeave()
	GameTooltip:Hide()
end

function RBR:CreateButton(relativeTo, isFirst, isLast)
	local button = CreateFrame("Button", name, RaidBuffReminder)
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
	
	button:SetScript("OnEnter", RBR.Button_OnEnter)
	button:SetScript("OnLeave", RBR.Button_OnLeave)
	
	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:Point("TOPLEFT", 2, -2)
	button.t:Point("BOTTOMRIGHT", -2, 2)
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	return button
end

function RBR:EnableRBR()
	RaidBuffReminder:Show()
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", 'UpdateReminder')
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", 'UpdateReminder')
	self:RegisterEvent("UNIT_AURA", 'UpdateReminder')
	self:RegisterEvent("PLAYER_REGEN_ENABLED", 'UpdateReminder')
	self:RegisterEvent("PLAYER_REGEN_DISABLED", 'UpdateReminder')
	self:RegisterEvent("PLAYER_ENTERING_WORLD", 'UpdateReminder')
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", 'UpdateReminder')
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", 'UpdateReminder')
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", 'UpdateReminder')
	self:UpdateReminder()
end

function RBR:DisableRBR()
	RaidBuffReminder:Hide()
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
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
	self.frame = frame
	
	for i=1, 6 do
		frame["spell"..i]:SetID(i)
	end
	
	if E.db.general.raidReminder then
		self:EnableRBR()
	else
		self:DisableRBR()
	end
end

E:RegisterModule(RBR:GetName())