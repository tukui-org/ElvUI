if TukuiCF["buffreminder"].enable ~= true then return end

-- Spells that should be shown with an icon in the middle of the screen when not buffed in combat.
-- Use the rank 1 id for best results. The first valid spell in each class's list will be the icon shown. 
TukuiDB.remindbuffs = {
	PRIEST = {
		588, -- inner fire
	},
	HUNTER = {
		13163, -- monkey
		13165, -- hawk
		5118, -- cheetah
		34074, -- viper
		13161, -- beast
		13159, -- pack
		20043, -- wild
		61846, -- dragonhawk
	},
	MAGE = {
		168, -- frost armor
		6117, -- mage armor
		7302, -- ice armor
		30482, -- molten armor
	},
	WARLOCK = {
		28176, -- fel armor
		706, -- demon armor
		687, -- demon skin
	},
	PALADIN = {
		21084, -- seal of righteousness
		20375, -- seal of command
		20164, -- seal of justice
		20165, -- seal of light
		20166, -- seal of wisdom
		53736, -- seal of corruption
		31801, -- seal of vengeance
	},
	SHAMAN = {
		52127, -- water shield
		324, -- lightning shield
		974, -- earth shield
	},
	WARRIOR = {
		469, -- commanding Shout
		6673, -- battle Shout
	},
	DEATHKNIGHT = {
		57330, -- horn of Winter
		31634, -- Shaman Strength of Earth Totem
	},
}

-- Nasty stuff below. Don't touch.
local class = select(2, UnitClass("Player"))
local buffs = TukuiDB.remindbuffs[class]
local sound

if (buffs and buffs[1]) then
	local function OnEvent(self, event)	
		if (event == "PLAYER_LOGIN" or event == "LEARNED_SPELL_IN_TAB") then
			for i, buff in pairs(buffs) do
				local name = GetSpellInfo(buff)
				local usable, nomana = IsUsableSpell(name)
				if (usable or nomana) then
					if TukuiDB.myclass == "PRIEST" then 
						self.icon:SetTexture([[Interface\AddOns\Tukui\media\textures\innerarmor]])
					else
						self.icon:SetTexture(select(3, GetSpellInfo(buff)))
					end
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
			end
		end
				
		if (UnitAffectingCombat("player") and not UnitInVehicle("player")) then
			for i, buff in pairs(buffs) do
				local name = GetSpellInfo(buff)
				if (name and UnitBuff("player", name)) then
					self:Hide()
					sound = true
					return
				end
			end
			self:Show()
			if TukuiCF["buffreminder"].sound == true and sound == true then
				PlaySoundFile(TukuiCF["media"].warning)
				sound = false
			end
		else
			self:Hide()
			sound = true
		end
	end
	
	local frame = CreateFrame("Frame", _, UIParent)
	
	frame.icon = frame:CreateTexture(nil, "OVERLAY")
	frame.icon:SetPoint("CENTER")
	if TukuiDB.myclass ~= "PRIEST" then
		TukuiDB.CreatePanel(frame, TukuiDB.Scale(40), TukuiDB.Scale(40), "CENTER", UIParent, "CENTER", 0, TukuiDB.Scale(200))
		frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.icon:SetWidth(TukuiDB.Scale(36))
		frame.icon:SetHeight(TukuiDB.Scale(36))
	else
		TukuiDB.CreatePanel(frame, TukuiDB.Scale(96), TukuiDB.Scale(192), "CENTER", UIParent, "CENTER", 0, TukuiDB.Scale(200))
		frame.icon:SetWidth(TukuiDB.Scale(96))
		frame.icon:SetHeight(TukuiDB.Scale(192))
		frame:SetBackdropColor(0, 0, 0, 0)
		frame:SetBackdropBorderColor(0, 0, 0, 0)
	end
	frame:Hide()
	
	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:RegisterEvent("UNIT_ENTERING_VEHICLE")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITING_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
	
	frame:SetScript("OnEvent", OnEvent)
end