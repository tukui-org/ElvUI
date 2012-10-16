local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local A = E:GetModule('Auras');
local LSM = LibStub("LibSharedMedia-3.0")

A.Stats = {
	[90363] = 'HUNTER', -- Embrace of the Shale Spider
	[117667] = 'MONK', --Legacy of The Emperor
	[1126] = 'DRUID', -- Mark of The Wild
	[20217] = 'PALADIN', -- Blessing Of Kings
	['DEFAULT'] = 20217
}

A.Stamina = {
	[90364] = 'HUNTER', -- Qiraji Fortitude
	[469] = 'WARRIOR', -- Commanding Shout
	[6307] = 'WARLOCK', -- Imp. Blood Pact
	[21562] = 'PRIEST', -- Power Word: Fortitude
	['DEFAULT'] = 21562
}

A.AttackPower = {
	[19506] = 'HUNTER', -- Trueshot Aura
	[6673] = 'WARRIOR', -- Battle Shout
	[57330] = 'DEATHKNIGHT', -- Horn of Winter
	['DEFAULT'] = 57330
}

A.SpellPower = {
	[126309] = 'HUNTER', -- Still Water
	[77747] = 'SHAMAN', -- Burning Wrath
	[109773] = 'WARLOCK', -- Dark Intent
	[61316] = 'MAGE', -- Dalaran Brilliance
	[1459] = 'MAGE', -- Arcane Brilliance
	['DEFAULT'] = 1459
}

A.AttackSpeed = {
	[128432] = 'HUNTER', -- Cackling Howl
	[128433] = 'HUNTER', -- Serpent's Swiftness
	[30809] = 'SHAMAN', -- Unleashed Rage
	[113742] = 'ROGUE', -- Swiftblade's Cunning
	[55610] = 'DEATHKNIGHT', -- Improved Icy Talons
	['DEFAULT'] = 55610
}

A.SpellHaste = {
	[24907] = 'DRUID', -- Moonkin Aura
	[51470] = 'SHAMAN', -- Elemental Oath
	[49868] = 'PRIEST', -- Mind Quickening
	['DEFAULT'] = 49868
}

A.CriticalStrike = {
	[126309] = 'HUNTER', -- Still Water
	[24604] = 'HUNTER', -- Furious Howl
	[90309] = 'HUNTER', -- Terrifying Roar
	[126373] = 'HUNTER', -- Fearless Roar
	[1459] = 'MAGE', -- Arcane Brilliance
	[61316] = 'MAGE', -- Dalaran Brilliance
	[24932] = 'DRUID', -- Leader of The Pact
	[116781] = 'MONK', -- Legacy of the White Tiger
	['DEFAULT'] = 116781
}

A.Mastery = {
	[93435] = 'HUNTER', --Roar of Courage
	[128997] = 'HUNTER', --Spirit Beast Blessing
	[116956] = 'SHAMAN', --Grace of Air
	[19740] = 'PALADIN', -- Blessing of Might	
	['DEFAULT'] = 19740
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
	for spell, _ in pairs(filter) do
		if spell ~= 'DEFAULT' then
			spellName, _, texture = GetSpellInfo(spell)
			
			assert(spellName, spell..': ID is not correct.')
			
			if UnitAura("player", spellName) then
				return spellName, texture
			end
		end
		
		texture =  select(3, GetSpellInfo(filter['DEFAULT']))
	end

	return false, texture
end

function A:UpdateConsolidatedTime(elapsed)
	if(self.expiration) then	
		self.expiration = math.max(self.expiration - elapsed, 0)
		if(self.expiration <= 0) then
			self.timer:SetText("")
		else
			local time = A:FormatTime(self.expiration)
			if self.expiration <= 86400.5 and self.expiration > 3600.5 then
				self.timer:SetText("|cffcccccc"..time.."|r")
			elseif self.expiration <= 3600.5 and self.expiration > 60.5 then
				self.timer:SetText("|cffcccccc"..time.."|r")
			elseif self.expiration <= 60.5 and self.expiration > E.db.auras.fadeThreshold then
				self.timer:SetText("|cffcccccc"..time.."|r")
			elseif self.expiration <= 5 then
				self.timer:SetText("|cffff0000"..time.."|r")
			end
		end
	end
end

function A:UpdateReminder(event, unit)
	if (event == "UNIT_AURA" and unit ~= "player") then return end	
	local frame = self.frame
	
	if event ~= 'UNIT_AURA' and not InCombatLockdown() then
		if E.db.auras.consolidatedBuffs.filter then
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
		else
			for i=3, 6 do
				_G['ConsolidatedBuffsTooltipBuff'..i]:Show()
			end			
		end
	end
	
	if E.db.auras.consolidatedBuffs.filter then
		A.IndexTable[7] = nil;
		A.IndexTable[8] = nil;		
		A.IndexTable[5] = A.CriticalStrike;
		A.IndexTable[6] = A.Mastery;
		
		if E.role == 'Caster' then
			A.IndexTable[3] = A.SpellPower
			A.IndexTable[4] = A.SpellHaste
		else
			A.IndexTable[3] = A.AttackPower
			A.IndexTable[4] = A.AttackSpeed
		end
	else
		A.IndexTable[3] = A.AttackPower;
		A.IndexTable[4] = A.AttackSpeed;
		A.IndexTable[5] = A.SpellPower;
		A.IndexTable[6] = A.SpellHaste;			
		A.IndexTable[7] = A.CriticalStrike;
		A.IndexTable[8] = A.Mastery;	
	end
	
	for i = 1, E.db.auras.consolidatedBuffs.filter and 6 or 8 do
		local hasBuff, texture = self:CheckFilterForActiveBuff(self.IndexTable[i])
		frame['spell'..i].t:SetTexture(texture)
		
		if hasBuff then
			local spellName, duration, expirationTime, _
			for i=1, 32 do
				spellName, _, _, _, _, duration, expirationTime = UnitBuff('player', i)
				if spellName == hasBuff then
					break;
				end
			end
			
			frame['spell'..i].expiration = expirationTime - GetTime()
			frame['spell'..i].duration = duration
			
			if (duration == 0 and expirationTime == 0) or E.db.auras.consolidatedBuffs.durations ~= true then
				frame['spell'..i].t:SetAlpha(0.3)
				frame['spell'..i]:SetScript('OnUpdate', nil)
				frame['spell'..i].timer:SetText(nil)
				CooldownFrame_SetTimer(frame['spell'..i].cd, 0, 0, 0)
			else
				CooldownFrame_SetTimer(frame['spell'..i].cd, expirationTime - duration, duration, 1)
				frame['spell'..i].t:SetAlpha(1)
				frame['spell'..i]:SetScript('OnUpdate', A.UpdateConsolidatedTime)
			end
			frame['spell'..i].hasBuff = hasBuff
		else
			CooldownFrame_SetTimer(frame['spell'..i].cd, 0, 0, 0)
			frame['spell'..i].hasBuff = nil
			frame['spell'..i].t:SetAlpha(1)
			frame['spell'..i]:SetScript('OnUpdate', nil)
			frame['spell'..i].timer:SetText(nil)
		end
	end
end

function A:Button_OnEnter()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -3, self:GetHeight() + 2)
	GameTooltip:ClearLines()
	
	local id = self:GetParent():GetID()
	
	if E.db.auras.consolidatedBuffs.filter then
		A.IndexTable[7] = nil;
		A.IndexTable[8] = nil;	
		A.IndexTable[5] = A.CriticalStrike;
		A.IndexTable[6] = A.Mastery;
		
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
	else
		A.IndexTable[3] = A.AttackPower;
		A.IndexTable[4] = A.AttackSpeed;
		A.IndexTable[5] = A.SpellPower;
		A.IndexTable[6] = A.SpellHaste;			
		A.IndexTable[7] = A.CriticalStrike;
		A.IndexTable[8] = A.Mastery;
		
		GameTooltip:AddLine(_G["RAID_BUFF_"..id])
	end
	
	GameTooltip:AddLine(" ")
	for spellID, buffProvider in pairs(A.IndexTable[id]) do
		if spellID ~= 'DEFAULT' then
			local spellName = GetSpellInfo(spellID)
			local color = RAID_CLASS_COLORS[buffProvider]
			
			if self:GetParent().hasBuff == spellName then
				GameTooltip:AddLine(spellName..' - '..ACTIVE_PETS, color.r, color.g, color.b)
			else
				GameTooltip:AddLine(spellName, color.r, color.g, color.b)
			end
		end
	end

	GameTooltip:Show()
end

function A:Button_OnLeave()
	GameTooltip:Hide()
end

function A:CreateButton()
	local button = CreateFrame("Button", nil, ElvUI_ConsolidatedBuffs)
	button:SetTemplate('Default')
	
	button.t = button:CreateTexture(nil, "OVERLAY")
	button.t:SetTexCoord(unpack(E.TexCoords))
	button.t:SetInside()
	button.t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	button.cd = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
	button.cd:SetInside()
	button.cd.noOCC = true;
	
	button.timer = button.cd:CreateFontString(nil, 'OVERLAY')
	button.timer:SetPoint('CENTER')
	
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

function A:Update_ConsolidatedBuffsSettings()
	local frame = self.frame
	frame:Width(E.ConsolidatedBuffsWidth)
	for i=1, NUM_LE_RAID_BUFF_TYPES do
		local id = i
		if i > 4 and E.db.auras.consolidatedBuffs.filter then
			id = i - 2
		end
		
		frame['spell'..i].t:SetAlpha(1)
		frame['spell'..i]:ClearAllPoints()
		frame['spell'..i]:Size(E.ConsolidatedBuffsWidth - (E.PixelMode and 1 or 4)) -- 4 needs to be 1
		
		if i == 1 then
			frame['spell'..i]:Point("TOP", ElvUI_ConsolidatedBuffs, "TOP", 0, -(E.PixelMode and 0 or 2)) -- -2 needs to be 0
		else
			frame['spell'..i]:Point("TOP", frame['spell'..i - 1], "BOTTOM", 0, (E.PixelMode and 1 or -1)) -- -1 needs to be 1
		end

		if i == 6 and E.db.auras.consolidatedBuffs.filter or i == 8 then
			frame['spell'..i]:Point("BOTTOM", ElvUI_ConsolidatedBuffs, "BOTTOM", 0, (E.PixelMode and 0 or 2)) --2 needs to be 0
		end
		
		if E.db.auras.consolidatedBuffs.filter and i > 6 then
			frame['spell'..i]:Hide()
		else
			frame['spell'..i]:Show()
		end
		
		if E.db.auras.consolidatedBuffs.durations then
			frame['spell'..i].cd:SetAlpha(1)
		else
			frame['spell'..i].cd:SetAlpha(0)
		end
		
		local font = LSM:Fetch("font", E.db.auras.consolidatedBuffs.font)
		frame['spell'..i].timer:FontTemplate(font, E.db.auras.consolidatedBuffs.fontSize, E.db.auras.consolidatedBuffs.fontOutline)	
		
		--This is so hackish its funny.. 
		--Have to do this to be able to right click a consolidated buff icon in combat and remove the aura.
		_G['ConsolidatedBuffsTooltipBuff'..i]:ClearAllPoints()
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetAllPoints(frame['spell'..id])
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetParent(frame['spell'..id])
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetAlpha(0)
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetScript("OnEnter", A.Button_OnEnter)
		_G['ConsolidatedBuffsTooltipBuff'..i]:SetScript("OnLeave", A.Button_OnLeave)		
	end
	
	if E.db.auras.consolidatedBuffs.enable and E.private.general.minimap.enable then
		E:GetModule('Auras'):EnableCB()
	else
		E:GetModule('Auras'):DisableCB()
	end	
end

function A:Construct_ConsolidatedBuffs()
	local frame = CreateFrame('Frame', 'ElvUI_ConsolidatedBuffs', Minimap)
	frame:SetTemplate('Default')
	frame:Width(E.ConsolidatedBuffsWidth)
	frame:Point('TOPLEFT', Minimap.backdrop, 'TOPRIGHT', (E.PixelMode and -1 or 1), 0)
	frame:Point('BOTTOMLEFT', Minimap.backdrop, 'BOTTOMRIGHT', (E.PixelMode and -1 or 1), 0)
	self.frame = frame
	
	for i=1, NUM_LE_RAID_BUFF_TYPES do
		frame['spell'..i] = self:CreateButton()
		frame["spell"..i]:SetID(i)
	end

	
	self:Update_ConsolidatedBuffsSettings()
end

E:RegisterModule(A:GetName())