------------------------------------------------------
-- Spell Reminder
------------------------------------------------------

local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["buffreminder"].enable ~= true then return end
--[[
	Arguments
	
	spells - List of spells in a group, if you have anyone of these spells the icon will hide.
		negate_spells - List of spells in a group, if you have anyone of these spells the icon will immediately hide and stop running the spell check (these should be other peoples spells)
		reversecheck - only works if you provide a role or a tree, instead of hiding the frame when you have the buff, it shows the frame when you have the buff, doesn't work with weapons
		negate_reversecheck - if reversecheck is set you can set a talent tree to not follow the reverse check, doesn't work with weapons
	
	weapon - Run a weapon enchant check instead of a spell check
	
	These can be ran no matter what you have selected from the above:
	
	combat - you must be in combat for it to display
	role - you must be a certain role for it to display (Tank, Melee, Caster)
	tree - you must be active in a specific talent tree for it to display (1, 2, 3) note: tree order can be viewed from left to right when you open your talent pane
	instance - you must be in an instance for it to display, note: if you have combat checked and this option checked then the combat check will only run when your inside a party/raid instance
	pvp - you must be in a pvp area for it to display (bg/arena), note: if you have combat checked and this option checked then the combat check will only run when your inside a bg/arena instance
	level - the minimum level you must be
	
	for every group created a new frame is created, it's a lot easier this way
]]

E.ReminderBuffs = {
	PRIEST = {
		[1] = { --inner fire/will group
			["spells"] = {
				588, -- inner fire
				73413, -- inner will			
			},
			["combat"] = true,
		},
	},
	HUNTER = {
		[1] = { --aspects group
			["spells"] = {
				13165, -- hawk
				5118, -- cheetah
				13159, -- pack
				20043, -- wild
				82661, -- fox	
			},
			["combat"] = true,
		},				
	},
	MAGE = {
		[1] = { --armors group
			["spells"] = {
				7302, -- frost armor
				6117, -- mage armor
				30482, -- molten armor		
			},
			["combat"] = true,
		},		
	},
	WARLOCK = {
		[1] = { --armors group
			["spells"] = {
				28176, -- fel armor
				687, -- demon armor			
			},
			["combat"] = true,
		},
	},
	PALADIN = {
		[1] = { --Seals group
			["spells"] = {
				20154, -- seal of righteousness
				20164, -- seal of justice
				20165, -- seal of insight
				31801, -- seal of truth				
			},
			["combat"] = true,
		},
		[2] = { -- righteous fury group
			["spells"] = {
				25780, 
			},
			["role"] = "Tank",
			["instance"] = true,
			["reversecheck"] = true,
			["negate_reversecheck"] = 1, --Holy paladins use RF sometimes
		},
	},
	SHAMAN = {
		[1] = { --shields group
			["spells"] = {
				52127, -- water shield
				324, -- lightning shield			
			},
			["combat"] = true,
			["instance"] = true,
		},
		[2] = { --check weapons for enchants
			["weapon"] = true,
			["combat"] = true,
			["level"] = 10,
		},
	},
	WARRIOR = {
		[1] = { -- commanding Shout group
			["spells"] = {
				469, 
			},
			["negate_spells"] = {
				6307, -- Blood Pact
				90364, -- Qiraji Fortitude
				72590, -- Drums of fortitude
				21562, -- Fortitude				
			},
			["combat"] = true,
			["role"] = "Tank",
		},
		[2] = { -- battle Shout group
			["spells"] = {
				6673, 
			},
			["negate_spells"] = {
				8076, -- strength of earth
				57330, -- horn of Winter
				93435, -- roar of courage (hunter pet)						
			},
			["combat"] = true,
			["role"] = "Melee",
		},
	},
	DEATHKNIGHT = {
		[1] = { -- horn of Winter group
			["spells"] = {
				57330, 
			},
			["negate_spells"] = {
				8076, -- strength of earth totem
				6673, -- battle Shout
				93435, -- roar of courage (hunter pet)			
			},
			["combat"] = true,
			["instance"] = true,
		},
		[2] = { -- blood presence group
			["spells"] = {
				48263, 
			},
			["role"] = "Tank",
			["instance"] = true,	
			["reversecheck"] = true,
		},
	},
	ROGUE = { 
		[1] = { --weapons enchant group
			["weapon"] = true,
			["combat"] = true,
			["level"] = 10,
		},
	},
}

local tab = E.ReminderBuffs[E.myclass]
if not tab then return end

local sound
local function OnEvent(self, event, arg1, arg2)
	local group = tab[self.id]
	if not group.spells and not group.weapon then return end
	if not GetActiveTalentGroup() then return end
	if event == "UNIT_AURA" and arg1 ~= "player" then return end 
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and arg2 ~= "ENCHANT_APPLIED" and arg2 ~= "ENCHANT_REMOVED" then return end
	if group.level and UnitLevel("player") < group.level then return end
	
	self:Hide()
	if group.negate_spells then
		for _, buff in pairs(group.negate_spells) do
			local name = GetSpellInfo(buff)
			if (name and UnitBuff("player", name)) then
				sound = true
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
			self:RegisterEvent("PLAYER_LOGIN")
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			self:RegisterEvent("UNIT_INVENTORY_CHANGED")
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
		self:RegisterEvent("PLAYER_LOGIN")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("UNIT_INVENTORY_CHANGED")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
	
	local role = group.role
	local tree = group.tree
	local combat = group.combat
	local instance = group.instance
	local pvp = group.pvp	
	local reversecheck = group.reversecheck
	local negate_reversecheck = group.negate_reversecheck
	local canplaysound = false
	local rolepass = false
	local treepass = false
	local combatpass = false
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
	
	if (instance ~= nil or pvp ~= nil) and combat then
		if instance then
			if instanceType == "party" or instanceType == "raid" then
				combatpass = true
			else
				combatpass = false
			end
		elseif pvp then
			if instanceType == "arena" or instanceType == "pvp" then
				combatpass = true
			else
				combatpass = false
			end		
		end
	else
		combatpass = true
	end
	
	if reversecheck ~= nil and (role == nil and tree == nil) then reversecheck = nil end
	
	if event == "ZONE_CHANGED_NEW_AREA" or (instance == nil and combat == true) then
		canplaysound = true
	end
	
	if not group.weapon then
		if ((combat and UnitAffectingCombat("player")) or (instance and (instanceType == "party" or instanceType == "raid")) or (pvp and (instanceType == "arena" or instanceType == "pvp"))) and 
		combatpass == true and treepass == true and rolepass == true and not (UnitInVehicle("player") and self.icon:GetTexture()) then
			for _, buff in pairs(group.spells) do
				local name = GetSpellInfo(buff)
				if (name and UnitBuff("player", name)) then
					self:Hide()
					sound = true
					return
				end
			end
			self:Show()
			if C["buffreminder"].sound == true and sound == true and canplaysound == true then
				PlaySoundFile(C["media"].warning)
				sound = false
			end		
		elseif ((combat and UnitAffectingCombat("player")) or (instance and (instanceType == "party" or instanceType == "raid")) or (pvp and (instanceType == "arena" or instanceType == "pvp"))) and 
		combatpass == true and reversecheck == true and not (UnitInVehicle("player") and self.icon:GetTexture()) then
			if negate_reversecheck and negate_reversecheck == GetPrimaryTalentTree() then self:Hide() sound = true return end
			for _, buff in pairs(group.spells) do
				local name = GetSpellInfo(buff)
				if (name and UnitBuff("player", name)) then
					self:Show()
					if C["buffreminder"].sound == true and canplaysound == true then PlaySoundFile(C["media"].warning) end
					return
				end			
			end			
		else
			self:Hide()
			sound = true
		end
	else
		if ((combat and UnitAffectingCombat("player")) or (instance and (instanceType == "party" or instanceType == "raid")) or (pvp and (instanceType == "arena" or instanceType == "pvp"))) and 
		combatpass == true and treepass == true and rolepass == true and not (UnitInVehicle("player") and self.icon:GetTexture()) then
			if hasOffhandWeapon == nil then
				if hasMainHandEnchant == nil then
					self:Show()
					if C["buffreminder"].sound == true and sound == true and canplaysound == true then
						PlaySoundFile(C["media"].warning)
						sound = false
					end		
					return
				end
			else
				if hasMainHandEnchant == nil then
					self:Show()
					if C["buffreminder"].sound == true and sound == true and canplaysound == true then
						PlaySoundFile(C["media"].warning)
						sound = false
					end	
					return
				elseif hasOffHandEnchant == nil then
					self:Show()
					if C["buffreminder"].sound == true and sound == true and canplaysound == true then
						PlaySoundFile(C["media"].warning)
						sound = false
					end	
					return
				end
			end
			self:Hide()
			sound = true
			return	
		else
			self:Hide()
			sound = true
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
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("UNIT_ENTERING_VEHICLE")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITING_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
	frame:SetScript("OnEvent", OnEvent)
end