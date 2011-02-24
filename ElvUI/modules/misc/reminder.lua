------------------------------------------------------
-- Spell Reminder
------------------------------------------------------

local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["buffreminder"].enable ~= true then return end

local tab = E.ReminderBuffs[E.myclass]
if not tab then return end

local function OnEvent(self, event, arg1, arg2)
	local group = tab[self.id]
	if not group.spells and not group.weapon then return end
	if not GetActiveTalentGroup() then return end
	if event == "UNIT_AURA" and arg1 ~= "player" then return end 
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and arg2 ~= "ENCHANT_APPLIED" and arg2 ~= "ENCHANT_REMOVED" then return end
	if group.level and UnitLevel("player") < group.level then return end
	
	self.icon:SetTexture(nil)
	self:Hide()
	if group.negate_spells then
		for _, buff in pairs(group.negate_spells) do
			local name = GetSpellInfo(buff)
			if (name and UnitBuff("player", name)) then
				return
			end
		end
	end
	
	local hasOffhandWeapon = OffhandHasWeapon()
	local hasMainHandEnchant, _, _, hasOffHandEnchant, _, _ = GetWeaponEnchantInfo()
	if not group.weapon then
		for _, buff in pairs(group.spells) do
			local name = GetSpellInfo(buff)
			local usable, nomana = IsUsableSpell(name)
			if (usable or nomana) then
				self.icon:SetTexture(select(3, GetSpellInfo(buff)))
				break
			end			
		end
		
		if (not self.icon:GetTexture() and event == "PLAYER_LOGIN") then
			self:UnregisterAllEvents()
			self:RegisterEvent("LEARNED_SPELL_IN_TAB")
			return
		elseif (self.icon:GetTexture() and event == "LEARNED_SPELL_IN_TAB") then
			self:UnregisterAllEvents()
			self:RegisterEvent("UNIT_AURA")
			if group.combat and group.combat == true then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
				self:RegisterEvent("PLAYER_REGEN_DISABLED")
			end
			
			if (group.instance and group.instance == true) or (group.pvp and group.pvp == true) then
				self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			end
			
			if group.role and group.role == true then
				self:RegisterEvent("UNIT_INVENTORY_CHANGED")
			end
		end		
	else
		if hasOffhandWeapon == nil then
			if hasMainHandEnchant == nil then
				self.icon:SetTexture(GetInventoryItemTexture("player", 16))
			end
		else
			if hasMainHandEnchant == nil then
				self.icon:SetTexture(GetInventoryItemTexture("player", 16))
			elseif hasOffHandEnchant == nil then
				self.icon:SetTexture(GetInventoryItemTexture("player", 17))
			end
		end
		
		self:UnregisterAllEvents()
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		if group.combat and group.combat == true then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
		end
		
		if (group.instance and group.instance == true) or (group.pvp and group.pvp == true) then
			self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		end
		
		if group.role and group.role == true then
			self:RegisterEvent("UNIT_INVENTORY_CHANGED")
		end
	end
	
	local role = group.role
	local tree = group.tree
	local combat = group.combat
	local personal = group.personal
	local instance = group.instance
	local pvp = group.pvp	
	local reversecheck = group.reversecheck
	local negate_reversecheck = group.negate_reversecheck
	local canplaysound = false
	local rolepass = false
	local treepass = false
	local inInstance, instanceType = IsInInstance()
	
	if role ~= nil then
		if role == E.Role then
			rolepass = true
		else
			rolepass = false
		end
	else
		rolepass = true
	end
	
	if tree ~= nil then
		if tree == GetPrimaryTalentTree() then
			treepass = true
		else
			treepass = false	
		end
	else
		treepass = true
	end
	
	--Prevent user error
	if reversecheck ~= nil and (role == nil and tree == nil) then reversecheck = nil end
	
	--Only time we allow it to play a sound
	if (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_REGEN_DISABLED") and C["buffreminder"].sound == true then canplaysound = true end
	
	if not group.weapon then
		if ((combat and UnitAffectingCombat("player")) or (instance and (instanceType == "party" or instanceType == "raid")) or (pvp and (instanceType == "arena" or instanceType == "pvp"))) and 
		treepass == true and rolepass == true and not (UnitInVehicle("player") and self.icon:GetTexture()) then
			for _, buff in pairs(group.spells) do
				local name = GetSpellInfo(buff)
				local _, _, icon, _, _, _, _, unitCaster, _, _, _ = UnitBuff("player", name)
				if personal and personal == true then
					if (name and icon and unitCaster == "player") then
						self:Hide()
						return
					end
				else
					if (name and icon) then
						self:Hide()
						return
					end
				end
			end
			self:Show()
			if canplaysound == true then PlaySoundFile(C["media"].warning) end		
		elseif ((combat and UnitAffectingCombat("player")) or (instance and (instanceType == "party" or instanceType == "raid")) or (pvp and (instanceType == "arena" or instanceType == "pvp"))) and 
		reversecheck == true and not (UnitInVehicle("player") and self.icon:GetTexture()) then
			if negate_reversecheck and negate_reversecheck == GetPrimaryTalentTree() then self:Hide() return end
			for _, buff in pairs(group.spells) do
				local name = GetSpellInfo(buff)
				local _, _, icon, _, _, _, _, unitCaster, _, _, _ = UnitBuff("player", name)
				if (name and icon and unitCaster == "player") then
					self:Show()
					if canplaysound == true then PlaySoundFile(C["media"].warning) end
					return
				end			
			end			
		else
			self:Hide()
		end
	else
		if ((combat and UnitAffectingCombat("player")) or (instance and (instanceType == "party" or instanceType == "raid")) or (pvp and (instanceType == "arena" or instanceType == "pvp"))) and 
		treepass == true and rolepass == true and not (UnitInVehicle("player") and self.icon:GetTexture()) then
			if hasOffhandWeapon == nil then
				if hasMainHandEnchant == nil then
					self:Show()
					if canplaysound == true then PlaySoundFile(C["media"].warning) end		
					return
				end
			else
				if hasMainHandEnchant == nil then
					self:Show()
					if canplaysound == true then PlaySoundFile(C["media"].warning) end	
					return
				elseif hasOffHandEnchant == nil then
					self:Show()
					if canplaysound == true then PlaySoundFile(C["media"].warning) end	
					return
				end
			end
			self:Hide()
			return	
		else
			self:Hide()
			return
		end	
	end
end

for i=1, #tab do
	local frame = CreateFrame("Frame", "ReminderFrame"..i, UIParent)
	frame:CreatePanel("Default", E.Scale(40), E.Scale(40), "CENTER", UIParent, "CENTER", 0, E.Scale(200))
	frame:SetFrameLevel(1)
	frame.id = i
	frame.icon = frame:CreateTexture(nil, "OVERLAY")
	frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.icon:SetPoint("CENTER")
	frame.icon:SetWidth(E.Scale(36))
	frame.icon:SetHeight(E.Scale(36))
	frame:Hide()

	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("UNIT_ENTERING_VEHICLE")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITING_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
	frame:SetScript("OnEvent", OnEvent)
	frame:SetScript("OnUpdate", function(self, elapsed)
		if(self.elapsed and self.elapsed > 0.2) then
			if not self.icon:GetTexture() then
				self:Hide()
			end
			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end	
	end)
end