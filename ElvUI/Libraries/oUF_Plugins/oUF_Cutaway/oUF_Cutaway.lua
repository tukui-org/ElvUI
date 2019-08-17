local _, ns = ...
local oUF = _G.oUF or ns.oUF
assert(oUF, "oUF_Cutaway was unable to locate oUF install.")

--[[
	Configuration values for both health and power:
		.enabled: enable cutaway for this element, defaults to disabled
		.fadeOutTime: How long it takes the cutaway health to fade, defaults to 0.6 seconds
		.lengthBeforeFade: How long it takes before the cutaway begins to fade, defaults to 0.3 seconds
]]
-- GLOBALS: ElvUI

local _G = _G
local max = math.max
local assert = assert
local hooksecurefunc = hooksecurefunc
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local UnitIsTapDenied = UnitIsTapDenied
local UnitGUID = UnitGUID

local E -- placeholder

local function checkElvUI()
	if not E then
		E = _G.ElvUI[1]
		assert(E, "oUF_Cutaway was not able to locate ElvUI and it is required.")
	end
end

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

	E:UIFrameFadeOut(element, element.fadeOutTime, element.__parentElement:GetAlpha(), 0)
end

local function Shared_PreUpdate(self, element, unit)
	element.unit = unit
	local oldGUID, newGUID = element.guid, UnitGUID(unit)
	element.guid = newGUID
	if (not oldGUID or oldGUID ~= newGUID) then
		return
	end
	element.cur = self.cur
	element.ready = true
end

local function UpdateSize(self, element, curV, maxV)
	local isVertical = self:GetOrientation() == "VERTICAL"
	local pm = (isVertical and self:GetHeight()) or self:GetWidth()
	local oum = (1 / maxV) * pm
	local c = max(element.cur - curV, 0)
	local mm = c * oum
	if isVertical then
		element:SetHeight(mm)
	else
		element:SetWidth(mm)
	end
end

local PRE = 0
local POST = 1

local function Shared_UpdateCheckReturn(self, element, updateType, ...)
	if not element:IsVisible() then
		return true
	end
	if (updateType == PRE) then
		local maxV = ...
		return (not element.enabled or not self.cur) or element.ready or not maxV
	elseif (updateType == POST) then
		local curV, maxV, unit = ...
		return (not element.enabled or not element.cur) or (not element.ready or not curV or not maxV) or element.unit ~= unit
	else
		return false
	end
end

local function Health_PreUpdate(self, unit)
	local element = self.__owner.Cutaway.Health
	local maxV = UnitHealthMax(unit)
	if Shared_UpdateCheckReturn(self, element, PRE, maxV) or UnitIsTapDenied(unit) then
		return
	end

	Shared_PreUpdate(self, element, unit)
end

local function Health_PostUpdate(self, unit, curHealth, maxHealth)
	local element = self.__owner.Cutaway.Health
	if Shared_UpdateCheckReturn(self, element, POST, curHealth, maxHealth, unit) then
		return
	end
	UpdateSize(self, element, curHealth, maxHealth)
	if element.playing then
		return
	end

	if (element.cur - curHealth) > (maxHealth * 0.01) then
		element:SetAlpha(self:GetAlpha())

		E:Delay(element.lengthBeforeFade, fadeClosure, element)

		element.playing = true
	else
		element:SetAlpha(0)
		closureFunc(element)
	end
end

local function Health_PostUpdateColor(self, _, _, _, _)
	local r, g, b = self:GetStatusBarColor()
	self.__owner.Cutaway.Health:SetVertexColor(r * 1.5, g * 1.5, b * 1.5)
end

local function Power_PreUpdate(self, unit)
	local element = self.__owner.Cutaway.Power
	local maxV = UnitPowerMax(unit)
	if Shared_UpdateCheckReturn(self, element, PRE, maxV) then
		return
	end

	Shared_PreUpdate(self, element, unit)
end

local function Power_PostUpdate(self, unit, curPower, _, maxPower)
	local element = self.__owner.Cutaway.Power
	if Shared_UpdateCheckReturn(self, element, POST, curPower, maxPower, unit) then
		return
	end
	UpdateSize(self, element, curPower, maxPower)
	if element.playing then
		return
	end

	if (element.cur - curPower) > (maxPower * 0.01) then
		element:SetAlpha(self:GetAlpha())

		E:Delay(element.lengthBeforeFade, fadeClosure, element)

		element.playing = true
	else
		element:SetAlpha(0)
		closureFunc(element)
	end
end

local function Power_PostUpdateColor(self, _, _, _, _)
	local r, g, b = self:GetStatusBarColor()
	self.__owner.Cutaway.Power:SetVertexColor(r * 1.5, g * 1.5, b * 1.5)
end

local defaults = {
	health = {
		enabled = false,
		lengthBeforeFade = 0.3,
		fadeOutTime = 0.6
	},
	power = {
		enabled = false,
		lengthBeforeFade = 0.3,
		fadeOutTime = 0.6
	}
}

local function UpdateConfigurationValues(self, db)
	local hs, ps = false, false
	if (self.Health) then
		local health = self.Health
		local hdb = db.health
		hs = hdb.enabled
		health.enabled = hs
		if (hs) then
			health.lengthBeforeFade = hdb.lengthBeforeFade
			health.fadeOutTime = hdb.fadeOutTime
			health:Show()
		else
			health:Hide()
		end
	end
	if (self.Power) then
		local power = self.Power
		local pdb = db.power
		ps = pdb.enabled
		power.enabled = ps
		if (ps) then
			power.lengthBeforeFade = pdb.lengthBeforeFade
			power.fadeOutTime = pdb.fadeOutTime
			power:Show()
		else
			power:Hide()
		end
	end
	return hs, ps
end

local function Enable(self)
	local element = self and self.Cutaway
	if (element) then
		checkElvUI()

		if (element.Health and element.Health:IsObjectType("Texture") and not element.Health:GetTexture()) then
			element.Health:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if (element.Power and element.Power:IsObjectType("Texture") and not element.Power:GetTexture()) then
			element.Power:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if (not element.defaultsSet) then
			UpdateConfigurationValues(element, defaults)
			element.defaultsSet = true
		end

		if element.Health and self.Health then
			self.Health.__owner = self
			element.Health.__parentElement = self.Health
			element.Health:SetAlpha(0)

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
			element.Power.__parentElement = self.Power
			element.Power:SetAlpha(0)

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

		if not (element.UpdateConfigurationValues) then
			element.UpdateConfigurationValues = UpdateConfigurationValues
		end

		return true
	end
end

local function disableElement(element)
	if element then
		element.enabled = false
		element:Hide()
	end
end

local function Disable(self)
	if self and self.Cutaway then
		disableElement(self.Cutaway.Health)
		disableElement(self.Cutaway.Power)
	end
end

oUF:AddElement("Cutaway", nil, Enable, Disable)
