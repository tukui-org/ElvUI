if (TukuiDB.myclass ~= "HUNTER") then return end
local font = TukuiCF["media"].font

local PetHappiness = CreateFrame("Frame")
PetHappiness.happiness = GetPetHappiness()

local OnEvent = function(self, event, ...)
	local happiness = GetPetHappiness()
	local hunterPet = select(2, HasPetUI())
	

	local unit, power = ...
	if (event == "UNIT_POWER" and unit == "pet" and power == "HAPPINESS" and happiness and hunterPet and self.happiness ~= happiness) then
		-- happiness has changed
		self.happiness = happiness
		if (happiness == 1) then
			DEFAULT_CHAT_FRAME:AddMessage(tukuilocal.hunter_unhappy, 1, 0, 0)
		elseif (happiness == 2) then
			DEFAULT_CHAT_FRAME:AddMessage(tukuilocal.hunter_content, 1, 1, 0)
		elseif (happiness == 3) then
			DEFAULT_CHAT_FRAME:AddMessage(tukuilocal.hunter_happy, 0, 1, 0)
		end
	elseif (event == "UNIT_PET") then
		self.happiness = happiness
		if (happiness == 1) then
			DEFAULT_CHAT_FRAME:AddMessage(tukuilocal.hunter_unhappy, 1, 0, 0)
		end
	end
end
PetHappiness:RegisterEvent('UNIT_HAPPINESS')
PetHappiness:RegisterEvent("UNIT_PET")
PetHappiness:SetScript("OnEvent", OnEvent)




local function BarPanel(height, width, x, y, anchorPoint, anchorPointRel, anchor, level, parent, strata)
	local Panel = CreateFrame("Frame", _, parent)
	Panel:SetFrameLevel(level)
	Panel:SetFrameStrata(strata)
	Panel:SetHeight(height)
	Panel:SetWidth(width)
	Panel:SetPoint(anchorPoint, anchor, anchorPointRel, x, y)
	Panel:SetBackdrop( { 
	bgFile = TukuiCF["media"].blank, 
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	Panel:SetBackdropColor(0.1, 0.1, 0.1, 0)
	Panel:Show()
	return Panel
end 

-- Function to update each bar
local function UpdateBar(self)
	local duration = self.Duration
	local timeLeft = self.EndTime-GetTime()
	local roundedt = math.floor(timeLeft*10.5)/10
	self.Bar:SetValue(timeLeft/duration)
	if roundedt % 1 == 0 then 
		self.Time:SetText(roundedt .. ".0")
	else 
		self.Time:SetText(roundedt)
	end

	if timeLeft < 0 then
		self.Panel:Hide()
		self:SetScript("OnUpdate", nil)
	end
end

-- Configures the Bar
local function ConfigureBar(f)
	f.Bar = CreateFrame("StatusBar", _, f.Panel)
	f.Bar:SetStatusBarTexture(TukuiCF["media"].blank)
	f.Bar:SetStatusBarColor(13/255, 81/255, 13/255)
	f.Bar:SetPoint("BOTTOMLEFT", 0, 0)
	f.Bar:SetPoint("TOPRIGHT", 0, 0)
	f.Bar:SetMinMaxValues(0, 1)
	f.Bar:SetAlpha(0.6)
	
	f.Time = f.Bar:CreateFontString(nil, "OVERLAY")
	f.Time:SetPoint("CENTER", 0, -2)
	f.Time:SetFont(font, 10, "THINOUTLINE")
	f.Time:SetShadowOffset(1, -1)
	f.Time:SetShadowColor(0, 0, 0)
	f.Time:SetJustifyH("LEFT")

	if TukuiCF["unitframes"].ws_show_time == true then
		f.Time:Show()
	else
		f.Time:Hide()
	end

	f.Panel:Hide()
end

--------------------------------------------------------
--  Mend Pet bar Codes
--------------------------------------------------------
if TukuiCF["unitframes"].mendpet == true then

	local mp = GetSpellInfo(136)
	local MendPetLoader = CreateFrame("Frame", nil, UIParent)

	MendPetLoader:RegisterEvent("ADDON_LOADED")
	MendPetLoader:SetScript("OnEvent", function(self, event, addon)
		if not (addon == "Tukui_Dps_Layout" or (addon == "Tukui_Heal_Layout" and not TukuiCF["raidframes"].centerheallayout == true)) then return end
		

		-- MendPet bar on pet frame when active.
		local MendPetPlayerFrame = CreateFrame("Frame", _, oUF_Tukz_pet)
		MendPetPlayerFrame.Panel = BarPanel(oUF_Tukz_pet:GetHeight(), oUF_Tukz_pet:GetWidth(), 0, 0, "CENTER", "CENTER", oUF_Tukz_pet, oUF_Tukz_pet:GetFrameLevel() + 1, MendPetPlayerFrame, "MEDIUM")
								  
		
		ConfigureBar(MendPetPlayerFrame)
		
		-- Check for MendPet on me and show bar if it is
		local function MendPetPlayerCheck(self, event, unit, spell)
			if (unit == "pet" and UnitBuff("pet", mp)) then
				local name, _, _, _, _, duration, expirationTime, unitCaster = UnitBuff("pet", mp)
				if name then
					self.EndTime = expirationTime
					self.Duration = duration
					self.Panel:Show()
					self:SetScript("OnUpdate", UpdateBar)
				end
			end
		end


		MendPetPlayerFrame:SetScript("OnEvent", MendPetPlayerCheck)
		MendPetPlayerFrame:RegisterEvent("UNIT_AURA")
		self:UnregisterEvent("ADDON_LOADED")
	end)
end