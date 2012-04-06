local E, L, P, G = unpack(select(2, ...));
local R = E:NewModule('Reminder', 'AceTimer-3.0');
local LSM = LibStub("LibSharedMedia-3.0");
R.CreatedReminders = {};

function R:PlayerHasFilteredBuff(db, checkPersonal)
	for buff, value in pairs(db) do
		if value == true then
			local name = GetSpellInfo(buff);
			local _, _, icon, _, _, _, _, unitCaster, _, _, _ = UnitBuff("player", name)
			if checkPersonal then
				if (name and icon and unitCaster == "player") then
					return true;
				end
			else
				if (name and icon) then
					return true;
				end
			end
		end
	end
	
	return false;
end

function R:UpdateReminderIcon(event, unit)
	if (event == 'UNIT_AURA' and unit ~= "player") then return; end
	
	local db = E.global.reminder.filters[E.myclass][self.groupName];

	self:Hide();
	self.icon:SetTexture(nil);
	
	if not db or not db.enable or (not db.spellGroup and not db.weaponCheck) or UnitIsDeadOrGhost('player') then return; end

	--Level Check
	if db.level and UnitLevel('player') < db.level and not self.ForceShow then return; end
	
	--Negate Spells Check
	if db.negateGroup and R:PlayerHasFilteredBuff(db.negateGroup) and not self.ForceShow then return; end
	
	local hasOffhandWeapon = OffhandHasWeapon();
	local hasMainHandEnchant, _, _, hasOffHandEnchant, _, _ = GetWeaponEnchantInfo();
	if db.spellGroup and not db.weaponCheck then
		for buff, value in pairs(db.spellGroup) do
			if value == true then
				local name = GetSpellInfo(buff);
				local usable, nomana = IsUsableSpell(name);
				if (usable or nomana) or not db.strictFilter or self.ForceShow then
					self.icon:SetTexture(select(3, GetSpellInfo(buff)));
					break
				end		
			end
		end

		if (not self.icon:GetTexture() and event == "PLAYER_ENTERING_WORLD") then
			self:UnregisterAllEvents();
			self:RegisterEvent("LEARNED_SPELL_IN_TAB");
			return
		elseif (self.icon:GetTexture() and event == "LEARNED_SPELL_IN_TAB") then
			self:UnregisterAllEvents();
			self:RegisterEvent("UNIT_AURA");
			if db.combat then
				self:RegisterEvent("PLAYER_REGEN_ENABLED");
				self:RegisterEvent("PLAYER_REGEN_DISABLED");
			end
			
			if db.instance or db.pvp then
				self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
			end
			
			if db.role then
				self:RegisterEvent("UNIT_INVENTORY_CHANGED");
			end
		end		
	elseif db.weaponCheck then
		self:UnregisterAllEvents();
		self:RegisterEvent("UNIT_INVENTORY_CHANGED");
		
		if not hasOffhandWeapon and hasMainHandEnchant then
			self.icon:SetTexture(GetInventoryItemTexture("player", 16));
		else
			if not hasOffHandEnchant then
				self.icon:SetTexture(GetInventoryItemTexture("player", 17));
			end
			
			if not hasMainHandEnchant then
				self.icon:SetTexture(GetInventoryItemTexture("player", 16));
			end
		end
		
		if db.combat then
			self:RegisterEvent("PLAYER_REGEN_ENABLED");
			self:RegisterEvent("PLAYER_REGEN_DISABLED");
		end
		
		if db.instance or db.pvp then
			self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		end
		
		if db.role then
			self:RegisterEvent("UNIT_INVENTORY_CHANGED");
		end
	end
	
	if self.ForceShow and self.icon:GetTexture() then
		self:Show();
		return;
	elseif self.ForceShow then
		E:Print(L['Attempted to show a reminder icon that does not have any spells. You must add a spell first.'])
		return;
	end
	
	local _, instanceType = IsInInstance();
	local roleCheck, treeCheck, combatCheck, instanceCheck, PVPCheck;
	
	if db.role then
		if db.role == E.role then
			roleCheck = true;
		else
			roleCheck = nil;
		end
	else
		roleCheck = true;
	end
	
	if db.tree then
		if db.tree == GetPrimaryTalentTree() then
			treeCheck = true;
		else
			treeCheck = nil;
		end
	else
		treeCheck = true;
	end
	
	if db.combat then
		if InCombatLockdown() then
			combatCheck = true;
		else
			combatCheck = nil;
		end
	else
		combatCheck = true;
	end
	
	if db.instance and (instanceType == "party" or instanceType == "raid") then
		instanceCheck = true;
	else
		instanceCheck = nil;
	end

	if db.pvp and (instanceType == "arena" or instanceType == "pvp") then
		PVPCheck = true;
	else
		PVPCheck = nil;
	end
	
	if not db.pvp and not db.instance then
		PVPCheck = true;
		instanceCheck = true;
	end
	
	if db.reverseCheck and not (db.role or db.tree) then db.reverseCheck = nil; end
	if not self.icon:GetTexture() or UnitInVehicle("player") then return; end
	
	R:SetIconPosition(self.groupName)
	
	if db.spellGroup and not db.weaponCheck then
		if roleCheck and treeCheck and combatCheck and (instanceCheck or PVPCheck) and not R:PlayerHasFilteredBuff(db.spellGroup, db.personal) then
			self:Show();
		elseif combatCheck and (instanceCheck or PVPCheck) and db.reverseCheck and (not roleCheck or not treeCheck) and R:PlayerHasFilteredBuff(db.spellGroup, db.personal) and not db.talentTreeException == GetPrimaryTalentTree() then
			self:Show();
		end
	elseif db.weaponCheck then
		if roleCheck and treeCheck and combatCheck and (instanceCheck or PVPCheck) then
			if not hasOffhandWeapon and not hasMainHandEnchant then
				self:Show();
				self.icon:SetTexture(GetInventoryItemTexture("player", 16));
			elseif hasOffhandWeapon and (not hasMainHandEnchant or not hasOffHandEnchant) then				
				if not hasMainHandEnchant then
					self.icon:SetTexture(GetInventoryItemTexture("player", 16));
				else
					self.icon:SetTexture(GetInventoryItemTexture("player", 17));
				end
				self:Show();
			end
		end
	end
	
	if self:IsShown() and not db.disableSound then
		if not R.SoundThrottled then
			R.SoundThrottled = true;
			PlaySoundFile(LSM:Fetch("sound", E.global['reminder'].sound));
			R:ScheduleTimer('ThrottleSound', 10);
		end
	end
end

function R:ThrottleSound()
	self.SoundThrottled = nil;
	self:CancelAllTimers();
end

function R:GetReminderIcon(name)
	return self.CreatedReminders[name]
end

function R:SetIconPosition(name)
	local db = E.global.reminder.filters[E.myclass][name];
	local xOffset = db.xOffset or 0
	local yOffset = db.yOffset or 0
	local frame = self:GetReminderIcon(name)
	
	if not db or not frame then return; end
	frame:ClearAllPoints()
	frame:Point('CENTER', E.UIParent, 'CENTER', 0 + xOffset, 200 + yOffset);
end

function R:ToggleIcon(name)
	local frame = self:GetReminderIcon(name)
	if not frame then return; end
	if not frame.ForceShow then
		frame.ForceShow = true;
	else
		frame.ForceShow = nil;
	end
	
	R.UpdateReminderIcon(frame);
end

function R:CreateReminder(name, index)
	if self.CreatedReminders[name] then return; end

	local frame = CreateFrame("Frame", 'ReminderIcon'..index, E.UIParent);
	frame:SetTemplate('Default');
	frame:Size(40);
	frame:SetClampedToScreen(true);
	frame.groupName = name;
	frame:Point('CENTER', E.UIParent, 'CENTER', 0, 200);
	frame.icon = frame:CreateTexture(nil, "OVERLAY");
	frame.icon:SetTexCoord(unpack(E.TexCoords));
	frame.icon:Point('TOPLEFT', 2, -2);
	frame.icon:Point('BOTTOMRIGHT', -2, 2);
	frame:Hide();

	frame:RegisterEvent("UNIT_AURA");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("UNIT_INVENTORY_CHANGED");
	frame:RegisterEvent("PLAYER_REGEN_ENABLED");
	frame:RegisterEvent("PLAYER_REGEN_DISABLED");
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	frame:RegisterEvent("UNIT_ENTERING_VEHICLE");
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE");
	frame:RegisterEvent("UNIT_EXITING_VEHICLE");
	frame:RegisterEvent("UNIT_EXITED_VEHICLE");
	frame:SetScript("OnEvent", R.UpdateReminderIcon);
	
	self.CreatedReminders[name] = frame;
end

function R:UpdateAllIcons()
	for name, frame in pairs(self.CreatedReminders) do
		R.UpdateReminderIcon(frame);
	end
end

function R:CheckForNewReminders()
	local db = E.global.reminder.filters[E.myclass];
	if not db then return; end
	
	local index = 0
	for groupName, _ in pairs(db) do
		index = index + 1;
		self:CreateReminder(groupName, index);
	end
	
	self:UpdateAllIcons();
end

function R:Initialize()
	if not E.global.reminder.enable then return end
	E.Reminder = R;

	R:CheckForNewReminders();
end

E:RegisterModule(R:GetName());