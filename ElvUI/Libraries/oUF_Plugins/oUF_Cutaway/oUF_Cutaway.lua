local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, "oUF_Cutaway was unable to locate oUF install.")

--[[
	Configuration values for both health and power:
		.enabled: enable cutaway for this element, defaults to disabled
		.fadeOutTime: How long it takes the cutaway health to fade, defaults to 0.6 seconds
		.lengthBeforeFade: How long it takes before the cutaway begins to fade, defaults to 0.3 seconds
]]
-- GLOBALS: ElvUI

local hooksecurefunc = hooksecurefunc
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local UnitIsTapDenied = UnitIsTapDenied

local E  -- holder
local function closureFunc(self)
	self.ready = nil
	self.playing = nil
	self.cur = nil
end

local function fadeClosure(element)
	if not element.FadeObject then
		element.FadeObject = {
			finishedFuncKeep = true,
			finishedArg1 = element,
			finishedFunc = closureFunc
		}
	end

	if not E then
		E = ElvUI[1]
	end
	E:UIFrameFadeOut(element, element.fadeOutTime, element.__parentElement:GetAlpha(), 0)
end

local function Health_PreUpdate(self, unit)
	local element = self.__owner.Cutaway.Health
	if (not element.enabled or not self.cur) or element.ready or UnitIsTapDenied(unit) or not UnitHealthMax(unit) then
		return
	end

	element.cur = self.cur
	element.unit = unit
	element:SetValue(element.cur)
	element:SetMinMaxValues(0, UnitHealthMax(unit))
	element.ready = true
end

local function Health_PostUpdate(self, unit, curHealth, maxHealth)
	local element = self.__owner.Cutaway.Health
	if (not element.ready or not element.cur or not curHealth or not maxHealth) or element.playing or element.unit ~= unit then
		return
	end

	if (element.cur - curHealth) > (maxHealth * 0.01) then
		element:SetAlpha(1)

		if not E then
			E = ElvUI[1]
		end
		E:Delay(element.lengthBeforeFade, fadeClosure, element)

		element.playing = true
	else
		element:SetAlpha(0)
		closureFunc(element)
	end
end

local function Health_PostUpdateColor(self, _, _, _, _)
	local r, g, b, a = self:GetStatusBarColor()
	self.__owner.Cutaway.Health:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, a)
end

local function Power_PreUpdate(self, unit)
	local element = self.__owner.Cutaway.Power
	if (not element.enabled or not self.cur) or element.ready or not UnitPowerMax(unit) then
		return
	end

	element.cur = self.cur
	element.unit = unit
	element:SetValue(element.cur)
	element:SetMinMaxValues(0, UnitPowerMax(unit))
	element.ready = true
end

local function Power_PostUpdate(self, unit, curPower, maxPower)
	local element = self.__owner.Cutaway.Power
	if (not element.ready or not element.cur or not curPower or not maxPower) or element.playing or element.unit ~= unit then
		return
	end

	if (element.cur - curPower) > (maxPower * 0.1) then
		element:SetAlpha(1)

		if not E then
			E = ElvUI[1]
		end
		E:Delay(element.lengthBeforeFade, fadeClosure, element)

		element.playing = true
	else
		element:SetAlpha(0)
		closureFunc(element)
	end
end

local function Power_PostUpdateColor(self, _, _, _, _)
	local r, g, b, a = self:GetStatusBarColor()
	self.__owner.Cutaway.Power:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, a)
end

local function Enable(self)
	local element = self and self.Cutaway
	if (element) then
		if (element.Health and element.Health:IsObjectType("StatusBar") and not element.Health:GetStatusBarTexture()) then
			element.Health:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if (element.Power and element.Power:IsObjectType("StatusBar") and not element.Power:GetStatusBarTexture()) then
			element.Power:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if element.Health and self.Health then
			self.Health.__owner = self

			element.Health.lengthBeforeFade = element.Health.lengthBeforeFade or 0.3
			element.Health.fadeOutTime = element.Health.fadeOutTime or 0.6
			element.Health:SetMinMaxValues(0, 1)
			element.Health:SetValue(0)
			element.Health.__parentElement = self.Health
			element.Health:Show()

			if not element.Health.hasCutawayHook then
				if self.Health.PreUpdate then
					hooksecurefunc(self.Health, "PreUpdate", Health_PreUpdate)
				else
					self.Health.PreUpdate = Health_PreUpdate
				end

				if self.Health.PostUpdate then
					hooksecurefunc(self.Health, "PostUpdate", Health_PostUpdate)
				else
					self.Health.PostUpdate = Health_PostUpdate
				end

				if self.Health.PostUpdateColor then
					hooksecurefunc(self.Health, "PostUpdateColor", Health_PostUpdateColor)
				else
					self.Health.PostUpdateColor = Health_PostUpdateColor
				end

				element.Health.hasCutawayHook = true
			end
		end

		if element.Power and self.Power then
			self.Power.__owner = self

			element.Power.lengthBeforeFade = element.Power.lengthBeforeFade or 0.3
			element.Power.fadeOutTime = element.Power.fadeOutTime or 0.6
			element.Power:SetMinMaxValues(0, 1)
			element.Power:SetValue(0)
			element.Power.__parentElement = self.Power
			element.Power:Show()

			if not element.Power.hasCutawayHook then
				if self.Power.PreUpdate then
					hooksecurefunc(self.Power, "PreUpdate", Power_PreUpdate)
				else
					self.Power.PreUpdate = Power_PreUpdate
				end

				if self.Power.PostUpdate then
					hooksecurefunc(self.Power, "PostUpdate", Power_PostUpdate)
				else
					self.Power.PostUpdate = Power_PostUpdate
				end

				if self.Power.PostUpdateColor then
					hooksecurefunc(self.Power, "PostUpdateColor", Power_PostUpdateColor)
				else
					self.Power.PostUpdateColor = Power_PostUpdateColor
				end

				element.Power.hasCutawayHook = true
			end
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	if self and self.Cutaway then
		self.Cutaway:Hide()

		if self.Cutaway.Health then
			self.Cutaway.Health:Hide()
		end
		if self.Cutaway.Power then
			self.Cutaway.Power:Hide()
		end
	end
end

oUF:AddElement("Cutaway", nil, Enable, Disable)
