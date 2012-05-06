local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local RBR = E:NewModule('RaidBuffReminder', 'AceEvent-3.0');

E.RaidBuffReminder = RBR

RBR.Spell1Buffs = {

}

RBR.BattleElixir = {

}
	
RBR.GuardianElixir = {

}
	
RBR.Spell2Buffs = {

}

RBR.Spell3Buffs = {

}

RBR.Spell4Buffs = {

}

RBR.CasterSpell5Buffs = {

}

RBR.MeleeSpell5Buffs = {

}

RBR.CasterSpell6Buffs = {

}

RBR.MeleeSpell6Buffs = {

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
	
	if E.role == 'Caster' then
		self.Spell5Buffs = self.CasterSpell5Buffs
		self.Spell6Buffs = self.CasterSpell6Buffs
	else
		self.Spell5Buffs = self.MeleeSpell5Buffs
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
	
	if E.db.general.raidReminder then
		self:EnableRBR()
	else
		self:DisableRBR()
	end
end

E:RegisterModule(RBR:GetName())