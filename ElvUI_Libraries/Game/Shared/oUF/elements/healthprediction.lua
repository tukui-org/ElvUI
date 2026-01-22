--[[
# Element: Health Prediction Bars

Handles the visibility and updating of incoming heals and heal/damage absorbs.

## Widget

HealthPrediction - A `table` containing references to sub-widgets and options.

## Sub-Widgets

healingOther              - A `StatusBar` used to represent incoming heals from others.
healingPlayer             - A `StatusBar` used to represent incoming heals from the player.
damageAbsorb              - A `StatusBar` used to represent damage absorbs.
healAbsorb                - A `StatusBar` used to represent heal absorbs.

### Retail only
healingAll                - A `StatusBar` used to represent incoming heals from all sources.
overHealIndicator         - A `Texture` used to indicate that the incoming healing is greater than the configured limits.
overDamageAbsorbIndicator - A `Texture` used to signify that the amount of damage absorb is greater than the configured limits.
overHealAbsorbIndicator   - A `Texture` used to signify that the amount of heal absorb is greater than the configured limits.

### Classic only
overAbsorb                - A `Texture` used to signify that the amount of damage absorb is greater than either the unit's missing
                            health or the unit's maximum health, if .showRawAbsorb is enabled.
overHealAbsorb            - A `Texture` used to signify that the amount of heal absorb is greater than the unit's current health.

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.
A default texture will be applied to the Texture widgets if they don't have a texture or a color set.

## Options

.damageAbsorbClampMode    - Defines how damage absorbs should clamp. See [Enum.UnitDamageAbsorbClampMode](https://warcraft.wiki.gg/wiki/Enum.UnitDamageAbsorbClampMode) (retail only).
.healAbsorbClampMode      - Defines how healing absorbs should clamp. See [Enum.UnitHealAbsorbClampMode](https://warcraft.wiki.gg/wiki/Enum.UnitHealAbsorbClampMode) (retail only).
.healAbsorbMode           - Defines how healing absorbs should be treated. See [Enum.UnitHealAbsorbMode](https://warcraft.wiki.gg/wiki/Enum.UnitHealAbsorbMode) (retail only).
.incomingHealClampMode    - Defines how incoming healing should clamp. See [Enum.UnitIncomingHealClampMode](https://warcraft.wiki.gg/wiki/Enum.UnitIncomingHealClampMode) (retail only).
.incomingHealOverflow     - The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
                            Defaults to 1.05 (number, retail only).
.maxOverflow              - The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
                            Defaults to 1.05 (number, classic).
.showRawAbsorb            - Makes the element show the raw amount of damage absorb (boolean, classic).

## Attributes

.values - A [unit heal prediction calculator](https://warcraft.wiki.gg/wiki/API_CreateUnitHealPredictionCalculator) used to calculate the values used in this element (retail only).
--]]

local _, ns = ...
local oUF = ns.oUF

local HealComm = LibStub('LibHealComm-4.0', true)

local select = select
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local CreateUnitHealPredictionCalculator = CreateUnitHealPredictionCalculator

local function UpdateSize(self, event, unit)
	local element = self.HealthPrediction

	if(element.healingAll) then
		element.healingAll[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingAll, element.size)
	end

	if(element.healingPlayer) then
		element.healingPlayer[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingPlayer, element.size)
	end

	if(element.healingOther) then
		element.healingOther[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healingOther, element.size)
	end

	if(element.damageAbsorb) then
		element.damageAbsorb[element.isHoriz and 'SetWidth' or 'SetHeight'](element.damageAbsorb, element.size)
	end

	if(element.healAbsorb) then
		element.healAbsorb[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healAbsorb, element.size)
	end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.HealthPrediction

	--[[ Callback: HealthPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the HealthPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local maxHealth = UnitHealthMax(unit)
	local health = UnitHealth(unit)

	-- Retail API
	if(oUF.isRetail and element.values) then
		UnitGetDetailedHealPrediction(unit, 'player', element.values)

		local allHeal, playerHeal, otherHeal, healClamped = element.values:GetIncomingHeals()
		if(element.healingAll) then
			element.healingAll:SetMinMaxValues(0, maxHealth)
			element.healingAll:SetValue(allHeal)
		end
		if(element.healingPlayer) then
			element.healingPlayer:SetMinMaxValues(0, maxHealth)
			element.healingPlayer:SetValue(playerHeal)
		end
		if(element.healingOther) then
			element.healingOther:SetMinMaxValues(0, maxHealth)
			element.healingOther:SetValue(otherHeal)
		end
		if(element.overHealIndicator) then
			element.overHealIndicator:SetAlphaFromBoolean(healClamped, 1, 0)
		end

		local damageAbsorbAmount, damageAbsorbClamped = element.values:GetDamageAbsorbs()
		if(element.damageAbsorb) then
			element.damageAbsorb:SetMinMaxValues(0, maxHealth)
			element.damageAbsorb:SetValue(damageAbsorbAmount)
		end
		if(element.overDamageAbsorbIndicator) then
			element.overDamageAbsorbIndicator:SetAlphaFromBoolean(damageAbsorbClamped, 1, 0)
		end

		local healAbsorbAmount, healAbsorbClamped = element.values:GetHealAbsorbs()
		if(element.healAbsorb) then
			element.healAbsorb:SetMinMaxValues(0, maxHealth)
			element.healAbsorb:SetValue(healAbsorbAmount)
		end
		if(element.overHealAbsorbIndicator) then
			element.overHealAbsorbIndicator:SetAlphaFromBoolean(healAbsorbClamped, 1, 0)
		end

		--[[ Callback: HealthPrediction:PostUpdate(unit)
		Called after the element has been updated.

		* self - the HealthPrediction element
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(element.PostUpdate) then
			return element:PostUpdate(unit)
		end
	else
		-- Classic API & LibHealComm implementation
		local GUID = UnitGUID(unit)
		local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
		local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
		local overTimeHeals = not oUF.isRetail and HealComm and ((HealComm:GetHealAmount(GUID, HealComm.OVERTIME_AND_BOMB_HEALS) or 0) * (HealComm:GetHealModifier(GUID) or 1)) or 0
		local absorb = (oUF.isRetail or oUF.isMists) and UnitGetTotalAbsorbs(unit) or 0
		local healAbsorb = (oUF.isRetail or oUF.isMists) and UnitGetTotalHealAbsorbs(unit) or 0
		local otherIncomingHeal = 0
		local hasOverHealAbsorb = false

		-- Kludge to override value for heals not reported by WoW client (ref: https://github.com/Stanzilla/WoWUIBugs/issues/163)
		-- There may be other bugs that this workaround does not catch, but this does fix Priest PoH
		if(HealComm and not oUF.isRetail) then
			local healAmount = HealComm:GetHealAmount(GUID, HealComm.CASTED_HEALS) or 0
			if(healAmount > 0) then
				if(myIncomingHeal == 0 and unit == 'player') then
					myIncomingHeal = healAmount
				end

				if(allIncomingHeal == 0) then
					allIncomingHeal = healAmount
				end
			end
		end

		if(healAbsorb > allIncomingHeal) then
			healAbsorb = healAbsorb - allIncomingHeal
			allIncomingHeal = 0
			myIncomingHeal = 0

			if(health < healAbsorb) then
				hasOverHealAbsorb = true
			end
		else
			allIncomingHeal = allIncomingHeal - healAbsorb
			healAbsorb = 0

			local maxOverflow = element.incomingHealOverflow or element.maxOverflow or 1.05
			if(health + allIncomingHeal > maxHealth * maxOverflow) then
				allIncomingHeal = maxHealth * maxOverflow - health
			end

			if(allIncomingHeal < myIncomingHeal) then
				myIncomingHeal = allIncomingHeal
			else
				otherIncomingHeal = allIncomingHeal - myIncomingHeal + overTimeHeals
			end
		end

		local hasOverAbsorb = false
		if(element.showRawAbsorb) then
			if(absorb > maxHealth) then
				hasOverAbsorb = true
			end
		elseif(absorb > 0) and (health + allIncomingHeal + absorb >= maxHealth) then
			hasOverAbsorb = true
		end

		if(element.healingPlayer) then
			element.healingPlayer:SetMinMaxValues(0, maxHealth)
			element.healingPlayer:SetValue(myIncomingHeal)
			element.healingPlayer:Show()
		end

		if(element.healingOther) then
			element.healingOther:SetMinMaxValues(0, maxHealth)
			element.healingOther:SetValue(otherIncomingHeal)
			element.healingOther:Show()
		end

		if(element.damageAbsorb) then
			element.damageAbsorb:SetMinMaxValues(0, maxHealth)
			element.damageAbsorb:SetValue(absorb)
			element.damageAbsorb:Show()
		end

		if(element.healAbsorb) then
			element.healAbsorb:SetMinMaxValues(0, maxHealth)
			element.healAbsorb:SetValue(healAbsorb)
			element.healAbsorb:Show()
		end

		if(element.overAbsorb) then
			if(hasOverAbsorb) then
				element.overAbsorb:Show()
			else
				element.overAbsorb:Hide()
			end
		end

		if(element.overHealAbsorb) then
			if(hasOverHealAbsorb) then
				element.overHealAbsorb:Show()
			else
				element.overHealAbsorb:Hide()
			end
		end

		--[[ Callback: HealthPrediction:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
		Called after the element has been updated.

		* self              - the HealthPrediction element
		* unit              - the unit for which the update has been triggered (string)
		* myIncomingHeal    - the amount of incoming healing done by the player (number)
		* otherIncomingHeal - the amount of incoming healing done by others (number)
		* absorb            - the amount of damage the unit can absorb without losing health (number)
		* healAbsorb        - the amount of healing the unit can absorb without gaining health (number)
		* hasOverAbsorb     - indicates if the amount of damage absorb is higher than either the unit's missing health or the unit's maximum health, if .showRawAbsorb is enabled (boolean)
		* hasOverHealAbsorb - indicates if the amount of heal absorb is higher than the unit's current health (boolean)
		--]]
		if(element.PostUpdate) then
			return element:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb, health, maxHealth)
		end
	end
end

local function shouldUpdateSize(self)
	if(not self.Health) then return end

	local isHoriz = self.Health:GetOrientation() == 'HORIZONTAL'
	local newSize = self.Health[isHoriz and 'GetWidth' or 'GetHeight'](self.Health)
	if(isHoriz ~= self.HealthPrediction.isHoriz or newSize ~= self.HealthPrediction.size) then
		self.HealthPrediction.isHoriz = isHoriz
		self.HealthPrediction.size = newSize

		return true
	end
end

local function Path(self, event, ...)
	--[[ Override: HealthPrediction.UpdateSize(self, event, unit, ...)
	Used to completely override the internal function for updating the widgets' size.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	if(shouldUpdateSize(self)) then
		(self.HealthPrediction.UpdateSize or UpdateSize) (self, ...)
	end

	--[[ Override: HealthPrediction.Override(self, event, unit)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event
	--]]
	return (self.HealthPrediction.Override or Update) (self, event, ...)
end

local function ForceUpdate(element)
	element.isHoriz = nil
	element.size = nil

	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function HealComm_Check(self, element, ...)
	if element and self:IsVisible() then
		for i = 1, select('#', ...) do
			if self.unit and UnitGUID(self.unit) == select(i, ...) then
				Path(self, nil, self.unit)
			end
		end
	end
end

local function HealComm_Create(self, element)
	local update = function(event, casterGUID, spellID, healType, _, ...) HealComm_Check(self, element, ...) end
	local modified = function(event, guid) HealComm_Check(self, element, guid) end
	return update, modified
end

local function SetUseHealComm(element, state)
	if not HealComm then return end

	if state then
		local frame = element.__owner
		if not frame.HealComm_Update then
			frame.HealComm_Update, frame.HealComm_Modified = HealComm_Create(frame, element)
		end

		HealComm.RegisterCallback(element, 'HealComm_HealStarted', frame.HealComm_Update)
		HealComm.RegisterCallback(element, 'HealComm_HealUpdated', frame.HealComm_Update)
		HealComm.RegisterCallback(element, 'HealComm_HealDelayed', frame.HealComm_Update)
		HealComm.RegisterCallback(element, 'HealComm_HealStopped', frame.HealComm_Update)
		HealComm.RegisterCallback(element, 'HealComm_ModifierChanged', frame.HealComm_Modified)
		HealComm.RegisterCallback(element, 'HealComm_GUIDDisappeared', frame.HealComm_Modified)
	else
		HealComm.UnregisterCallback(element, 'HealComm_HealStarted')
		HealComm.UnregisterCallback(element, 'HealComm_HealUpdated')
		HealComm.UnregisterCallback(element, 'HealComm_HealDelayed')
		HealComm.UnregisterCallback(element, 'HealComm_HealStopped')
		HealComm.UnregisterCallback(element, 'HealComm_ModifierChanged')
		HealComm.UnregisterCallback(element, 'HealComm_GUIDDisappeared')
	end
end

local function Enable(self)
	local element = self.HealthPrediction
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.SetUseHealComm = SetUseHealComm

		if(oUF.isRetail) then
			if(element.values) then
				element.values:Reset()
			else
				element.values = CreateUnitHealPredictionCalculator()
			end

			if(element.damageAbsorbClampMode) then
				element.values:SetDamageAbsorbClampMode(element.damageAbsorbClampMode)
			end

			if(element.healAbsorbClampMode) then
				element.values:SetHealAbsorbClampMode(element.healAbsorbClampMode)
			end

			if(element.healAbsorbMode) then
				element.values:SetHealAbsorbMode(element.healAbsorbMode)
			end

			if(element.incomingHealClampMode) then
				element.values:SetIncomingHealClampMode(element.incomingHealClampMode)
			end

			if(element.incomingHealOverflow) then
				element.values:SetIncomingHealOverflowPercent(element.incomingHealOverflow)
			end
		end

		self:RegisterEvent('UNIT_HEALTH', Path)
		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)

		if oUF.isClassic then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		if oUF.isRetail or oUF.isMists then
			self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
			self:RegisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
			self:RegisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)
		else
			element:SetUseHealComm(true)
		end

		if (not element.maxOverflow) then
			element.maxOverflow = 1.05
		end

		-- Setup retail widget names
		if(element.healingAll) then
			if(element.healingAll:IsObjectType('StatusBar') and not element.healingAll:GetStatusBarTexture()) then
				element.healingAll:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.overHealIndicator) then
			if(element.overHealIndicator:IsObjectType('Texture') and not element.overHealIndicator:GetTexture()) then
				element.overHealIndicator:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
				element.overHealIndicator:SetBlendMode('ADD')
			end
		end

		if(element.overDamageAbsorbIndicator) then
			if(element.overDamageAbsorbIndicator:IsObjectType('Texture') and not element.overDamageAbsorbIndicator:GetTexture()) then
				element.overDamageAbsorbIndicator:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
				element.overDamageAbsorbIndicator:SetBlendMode('ADD')
			end
		end

		if(element.overHealAbsorbIndicator) then
			if(element.overHealAbsorbIndicator:IsObjectType('Texture') and not element.overHealAbsorbIndicator:GetTexture()) then
				element.overHealAbsorbIndicator:SetTexture([[Interface\RaidFrame\Absorb-Overabsorb]])
				element.overHealAbsorbIndicator:SetBlendMode('ADD')
			end
		end

		-- Setup classic widget names
		if(element.healingPlayer) then
			if(element.healingPlayer:IsObjectType('StatusBar') and not element.healingPlayer:GetStatusBarTexture()) then
				element.healingPlayer:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healingOther) then
			if(element.healingOther:IsObjectType('StatusBar') and not element.healingOther:GetStatusBarTexture()) then
				element.healingOther:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.damageAbsorb) then
			if(element.damageAbsorb:IsObjectType('StatusBar') and not element.damageAbsorb:GetStatusBarTexture()) then
				element.damageAbsorb:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healAbsorb) then
			if(element.healAbsorb:IsObjectType('StatusBar') and not element.healAbsorb:GetStatusBarTexture()) then
				element.healAbsorb:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.overAbsorb) then
			if(element.overAbsorb:IsObjectType('Texture') and not element.overAbsorb:GetTexture()) then
				element.overAbsorb:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
				element.overAbsorb:SetBlendMode('ADD')
			end
		end

		if(element.overHealAbsorb) then
			if(element.overHealAbsorb:IsObjectType('Texture') and not element.overHealAbsorb:GetTexture()) then
				element.overHealAbsorb:SetTexture([[Interface\RaidFrame\Absorb-Overabsorb]])
				element.overHealAbsorb:SetBlendMode('ADD')
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.HealthPrediction
	if(element) then
		if(element.healingAll) then
			element.healingAll:Hide()
		end

		if(element.overHealIndicator) then
			element.overHealIndicator:Hide()
		end

		if(element.overDamageAbsorbIndicator) then
			element.overDamageAbsorbIndicator:Hide()
		end

		if(element.overHealAbsorbIndicator) then
			element.overHealAbsorbIndicator:Hide()
		end

		if(element.healingPlayer) then
			element.healingPlayer:Hide()
		end

		if(element.healingOther) then
			element.healingOther:Hide()
		end

		if(element.damageAbsorb) then
			element.damageAbsorb:Hide()
		end

		if(element.healAbsorb) then
			element.healAbsorb:Hide()
		end

		if(element.overAbsorb) then
			element.overAbsorb:Hide()
		end

		if(element.overHealAbsorb) then
			element.overHealAbsorb:Hide()
		end

		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)

		if oUF.isClassic then
			self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		if oUF.isRetail or oUF.isMists then
			self:UnregisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
			self:UnregisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
			self:UnregisterEvent('UNIT_MAX_HEALTH_MODIFIERS_CHANGED', Path)
		else
			element:SetUseHealComm(false)
		end
	end
end

oUF:AddElement('HealthPrediction', Path, Enable, Disable)
