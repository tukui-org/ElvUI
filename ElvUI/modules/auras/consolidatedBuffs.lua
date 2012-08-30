local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local A = E:GetModule('Auras');

A.Stats = {
	90363, -- Embrace of the Shale Spider
	117667, --Legacy of The Emperor
	1126, -- Mark of The Wild
	20217, -- Blessing Of Kings
}

A.Stamina = {
	90364, -- Qiraji Fortitude
	469, -- Commanding Shout
	6307, -- Imp. Blood Pact
	21562 -- Power Word: Fortitude
}

A.AttackPower = {
	19506, -- Trueshot Aura
	6673, -- Battle Shout
	57330, -- Horn of Winter
}

A.SpellPower = {
	77747, -- Burning Wrath
	109773, -- Dark Intent
	61316, -- Dalaran Brilliance
	1459, -- Arcane Brilliance
}

A.AttackSpeed = {
	128432, -- Cackling Howl
	128433, -- Serpent's Swiftness
	30809, -- Unleashed Rage
	113742, -- Swiftblade's Cunning
	55610 -- Improved Icy Talons
}

A.SpellHaste = {
	24907, -- Moonkin Aura
	51470, -- Elemental Oath
	49868, -- Mind Quickening
}

A.CriticalStrike = {
	24604, -- Furious Howl
	90309, -- Terrifying Roar
	1459, -- Arcane Brilliance
	61316, -- Dalaran Brilliance
	24932, -- Leader of The Pact
	116781, -- Legacy of the White Tiger
}

A.Mastery = {
	93435, --Roar of Courage
	128997, --Spirit Beast Blessing
	116956, --Grace of Air
	19740, -- Blessing of Might	
}

A.IndexTable = {
	[1] = A.Stats,
	[2] = A.Stamina,
	[3] = A.AttackPower,
	[4] = A.AttackSpeed,
	[5] = A.CriticalStrike,
	[6] = A.Mastery,
}

function A:CheckFilterForActiveBuff(filter)
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

function A:UpdateReminder(event, unit)
	if (event == "UNIT_AURA" and unit ~= "player") then return end	
	local frame = self.frame
	
	if event ~= 'UNIT_AURA' and not InCombatLockdown() then
		if E.role == 'Caster' then
			ConsolidatedBuffsTooltipBuff3:Hide()
			ConsolidatedBuffsTooltipBuff4:Hide()
			ConsolidatedBuffsTooltipBuff5:Show()
			ConsolidatedBuffsTooltipBuff6:Show()			
		else
			ConsolidatedBuffsTooltipBuff3:Show()
			ConsolidatedBuffsTooltipBuff4:Show()
			ConsolidatedBuffsTooltipBuff5:Hide()
			ConsolidatedBuffsTooltipBuff6:Hide()		
		end
	end
	
	if E.role == 'Caster' then
		A.IndexTable[3] = A.SpellPower
		A.IndexTable[4] = A.SpellHaste
	else
		A.IndexTable[3] = A.AttackPower
		A.IndexTable[4] = A.AttackSpeed
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

function A:Button_OnEnter()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -3, self:GetHeight() + 2)
	GameTooltip:ClearLines()
	
	local id = self:GetParent():GetID()
	
	if (id == 3 or id == 4) and E.role == 'Caster' then
		A.IndexTable[3] = A.SpellPower
		A.IndexTable[4] = A.SpellHaste
		
		GameTooltip:AddLine(_G["RAID_BUFF_"..id+2])
	elseif id >= 5 then
		GameTooltip:AddLine(_G["RAID_BUFF_"..id+2])
	else
		if E.role ~= "Caster" then
			A.IndexTable[3] = A.AttackPower
			A.IndexTable[4] = A.AttackSpeed
		end
		
		GameTooltip:AddLine(_G["RAID_BUFF_"..id])
	end

	GameTooltip:AddLine(" ")
	for _, spellID in pairs(A.IndexTable[id]) do
		local spellName = GetSpellInfo(spellID)
		if self:GetParent().hasBuff == spellName then
			GameTooltip:AddLine(spellName, 1, 0, 0)
		else
			GameTooltip:AddLine(spellName, 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

function A:Button_OnLeave()
	GameTooltip:Hide()
end

function A:CreateButton(relativeTo, isFirst, isLast)
	local button = CreateFrame("Button", name, ElvUI_ConsolidatedBuffs)
	button:SetTemplate('Default')
	button:Size(E.ConsolidatedBuffsWidth - 4)
	if isFirst then
		button:Point("TOP", relativeTo, "TOP", 0, -2)
	else
		button:Point("TOP", relativeTo, "BOTTOM", 0, -1)
	end
	
	if isLast then
		button:Point("BOTTOM", ElvUI_ConsolidatedBuffs, "BOTTOM", 0, 2)
	end

	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:SetInside()
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	return button
end

function A:EnableCB()
	ElvUI_ConsolidatedBuffs:Show()
	BuffFrame:RegisterEvent('UNIT_AURA')
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

function A:DisableCB()
	ElvUI_ConsolidatedBuffs:Hide()
	BuffFrame:UnregisterEvent('UNIT_AURA')
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

function A:Construct_ConsolidatedBuffs()
	local frame = CreateFrame('Frame', 'ElvUI_ConsolidatedBuffs', Minimap)
	frame:SetTemplate('Default')
	frame:Width(E.ConsolidatedBuffsWidth)
	frame:Point('TOPLEFT', Minimap.backdrop, 'TOPRIGHT', 1, 0)
	frame:Point('BOTTOMLEFT', Minimap.backdrop, 'BOTTOMRIGHT', 1, 0)

	frame.spell1 = self:CreateButton(frame, true)
	frame.spell2 = self:CreateButton(frame.spell1)
	frame.spell3 = self:CreateButton(frame.spell2)
	frame.spell4 = self:CreateButton(frame.spell3)
	frame.spell5 = self:CreateButton(frame.spell4)
	frame.spell6 = self:CreateButton(frame.spell5, nil, true)
	self.frame = frame

	for i=1, NUM_LE_RAID_BUFF_TYPES do
		local id = i
		if i > 4 then
			id = i - 2
		end
		
		frame["spell"..id]:SetID(id)
		
		--This is so hackish its funny.. 
		--Have to do this to be able to right click a consolidated buff icon in combat and remove the aura.
		_G['ConsolidatedBuffsTooltipBuff'..i]:ClearAllPoints()
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetAllPoints(frame['spell'..id])
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetParent(frame['spell'..id])
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetAlpha(0)
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetScript("OnEnter", A.Button_OnEnter)
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetScript("OnLeave", A.Button_OnLeave)		
	end
	
	if E.db.auras.consolidedBuffs then
		self:EnableCB()
	else
		self:DisableCB()
	end
end

E:RegisterModule(A:GetName())