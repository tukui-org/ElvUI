
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["buffreminder"].enable ~= true then return end

-- Spells that should be shown with an icon in the middle of the screen when not buffed in combat.
-- Use the rank 1 id for best results. The first valid spell in each class's list will be the icon shown. 
E.remindbuffs = {
	PRIEST = {
		588, -- inner fire
		73413, -- inner will
	},
	HUNTER = {
		82661, -- fox
		13165, -- hawk
		5118, -- cheetah
		13159, -- pack
		20043, -- wild
	},
	MAGE = {
		7302, -- frost armor
		6117, -- mage armor
		30482, -- molten armor
	},
	WARLOCK = {
		28176, -- fel armor
		687, -- demon armor
	},
	PALADIN = {
		20154, -- seal of righteousness
		20164, -- seal of justice
		20165, -- seal of insight
		31801, -- seal of truth
	},
	SHAMAN = {
		52127, -- water shield
		324, -- lightning shield
	},
}

E.tankremindbuffs = {
	PALADIN = {
		25780, -- righteous fury
	},
	
	DEATHKNIGHT = {
		48263, -- blood presence
	},
}

-- Nasty stuff below. Don't touch.
local class = select(2, UnitClass("Player"))
local buffs = E.remindbuffs[class]
local sound

if (buffs and buffs[1]) then
	local function OnEvent(self, event)	
		if (event == "PLAYER_LOGIN" or event == "LEARNED_SPELL_IN_TAB") then
			for i, buff in pairs(buffs) do
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
			end
		end
		
		local inInstance, _ = IsInInstance()	
		if (UnitAffectingCombat("player") or inInstance) and not UnitInVehicle("player") and self.icon:GetTexture() then
			for i, buff in pairs(buffs) do
				local name = GetSpellInfo(buff)
				if (name and UnitBuff("player", name)) then
					self:Hide()
					sound = true
					return
				end
			end
			self:Show()
			if C["buffreminder"].sound == true and sound == true then
				PlaySoundFile(C["media"].warning)
				sound = false
			end
		else
			self:Hide()
			sound = true
		end
	end
	
	local frame = CreateFrame("Frame", _, UIParent)
	frame:CreatePanel("Default", E.Scale(40), E.Scale(40), "CENTER", UIParent, "CENTER", 0, E.Scale(200))
	frame:SetFrameLevel(1)
	
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

-- Tanking Version
local tankbuffs = E.tankremindbuffs[class]
local tanksound
if (tankbuffs and tankbuffs[1]) then
	local function OnEvent(self, event)	
		if (event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "LEARNED_SPELL_IN_TAB") then
			for i, tankbuffs in pairs(tankbuffs) do
				local name = GetSpellInfo(tankbuffs)
				local usable, nomana = IsUsableSpell(name)
				if (usable or nomana) then
					self.icon:SetTexture(select(3, GetSpellInfo(tankbuffs)))
					break
				end
			end
			if (not self.icon:GetTexture() and event == "PLAYER_ENTERING_WORLD") then
				self:UnregisterAllEvents()
				self:RegisterEvent("LEARNED_SPELL_IN_TAB")
				return
			elseif (self.icon:GetTexture() and event == "LEARNED_SPELL_IN_TAB") then
				self:UnregisterAllEvents()
				self:RegisterEvent("UNIT_AURA")
				self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
				self:RegisterEvent("PLAYER_ENTERING_WORLD")
			end
		end
		local inInstance, instanceType = IsInInstance()	
		--check aura
		if (not UnitInVehicle("player")) and (inInstance and (instanceType == "raid" or instanceType == "party")) and E.Role == "Tank" and self.icon:GetTexture() then
			for i, tankbuffs in pairs(tankbuffs) do
				local name = GetSpellInfo(tankbuffs)
				if (name and UnitBuff("player", name)) then
					self:Hide()
					tanksound = true
					return
				end
			end
			self:Show()
			if C["buffreminder"].sound == true and tanksound1 == true then
				PlaySoundFile(C["media"].warning)
				tanksound = false
			end
		else
			self:Hide()
			tanksound = true
		end
	end
	
	local frame = CreateFrame("Frame", _, UIParent)
	frame:CreatePanel("Default", E.Scale(40), E.Scale(40), "CENTER", UIParent, "CENTER", 0, E.Scale(200))
	frame:SetFrameLevel(2)
	frame.icon = frame:CreateTexture(nil, "OVERLAY")
	frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.icon:SetPoint("CENTER")
	frame.icon:SetWidth(E.Scale(36))
	frame.icon:SetHeight(E.Scale(36))
	frame:Hide()
	
	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("UNIT_ENTERING_VEHICLE")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITING_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
	
	frame:SetScript("OnEvent", OnEvent)
end