local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

-- Cache global variables
-- Lua functions
-- WoW API / Variables
local C_Timer_After = C_Timer.After
local hooksecurefunc = hooksecurefunc
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

local HealthIsDone, PowerIsDone
local function CloseHealth()
	HealthIsDone = false
end

local function ClosePower()
	PowerIsDone = false
end

local function Health_PreUpdate(self, unit)
	if HealthIsDone then return end
	self.__owner.Cutaway.Health.cur = UnitHealth(unit)
	self.__owner.Cutaway.Health:SetValue(UnitHealth(unit))
	self.__owner.Cutaway.Health:SetMinMaxValues(0, UnitHealthMax(unit))
	HealthIsDone = true
end

local function Health_PostUpdate(self, unit, cur, max)
	if not HealthIsDone then return end
	if (self.__owner.Cutaway.Health.cur or 1) > (cur) then
		E:UIFrameFadeOut(self.__owner.Cutaway.Health, 2, 1, 0);
		C_Timer_After(2, CloseHealth)
	end
end

local function Power_PreUpdate(self, unit)
	if PowerIsDone then return end
	self.__owner.Cutaway.Power.cur = UnitPower(unit)
	self.__owner.Cutaway.Power:SetValue(UnitPower(unit))
	self.__owner.Cutaway.Power:SetMinMaxValues(0, UnitPowerMax(unit))
	PowerIsDone = true
end

local function Power_PostUpdate(self, unit, cur, max)
	if not PowerIsDone then return end
	if (self.__owner.Cutaway.Power.cur or 1) > (cur) then
		E:UIFrameFadeOut(self.__owner.Cutaway.Power, 2, 1, 0);
		C_Timer_After(2, ClosePower)
	end
end

local function Enable(self)
	local element = self.Cutaway
	if (element) then
		if (element.Health and element.Health:IsObjectType('StatusBar') and not element.Health:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if (element.Power and element.Power:IsObjectType('StatusBar') and not element.Power:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if element.Health then
			element.Health.__owner = self

			if self.Health and not element.Health.hasCutawayHook then
				if self.Health.PreUpdate then
					hooksecurefunc(self.Health, 'PreUpdate', Health_PreUpdate)
				else
					self.Health.PreUpdate = Health_PreUpdate
				end

				if self.Health.PostUpdate then
					hooksecurefunc(self.Health, 'PostUpdate', Health_PostUpdate)
				else
					self.Health.PostUpdate = Health_PostUpdate
				end

				element.Health.hasCutawayHook = true
			end
		end

		if element.Power then
			element.Power.__owner = self

			if self.Power and not element.Power.hasCutawayHook then
				if self.Power.PreUpdate then
					hooksecurefunc(self.Power, 'PreUpdate', Power_PreUpdate)
				else
					self.Power.PreUpdate = Power_PreUpdate
				end

				if self.Power.PostUpdate then
					hooksecurefunc(self.Power, 'PostUpdate', Power_PostUpdate)
				else
					self.Power.PostUpdate = Power_PostUpdate
				end

				element.Power.hasCutawayHook = true
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.Cutaway
	if (element) then
		element:Hide()
	end
end

oUF:AddElement('Cutaway', nil, Enable, Disable)
