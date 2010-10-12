if TukuiCF["buffreminder"].enable ~= true then return end

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