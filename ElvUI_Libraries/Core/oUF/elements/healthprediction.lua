--[[
# Element: Health Prediction Bars

Handles the visibility and updating of incoming heals and heal/damage absorbs.

## Widget

HealthPrediction - A `table` containing references to sub-widgets and options.

## Sub-Widgets

myBar          - A `StatusBar` used to represent incoming heals from the player.
otherBar       - A `StatusBar` used to represent incoming heals from others.
absorbBar      - A `StatusBar` used to represent damage absorbs.
healAbsorbBar  - A `StatusBar` used to represent heal absorbs.
overAbsorb     - A `Texture` used to signify that the amount of damage absorb is greater than either the unit's missing
                 health or the unit's maximum health, if .showRawAbsorb is enabled.
overHealAbsorb - A `Texture` used to signify that the amount of heal absorb is greater than the unit's current health.

## Notes

A default texture will be applied to the StatusBar widgets if they don't have a texture set.
A default texture will be applied to the Texture widgets if they don't have a texture or a color set.

## Options

.maxOverflow   - The maximum amount of overflow past the end of the health bar. Set this to 1 to disable the overflow.
                 Defaults to 1.05 (number)
.showRawAbsorb - Makes the element show the raw amount of damage absorb (boolean)

## Examples

    -- Position and size
    local myBar = CreateFrame('StatusBar', nil, self.Health)
    myBar:SetPoint('TOP')
    myBar:SetPoint('BOTTOM')
    myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    myBar:SetWidth(200)

    local otherBar = CreateFrame('StatusBar', nil, self.Health)
    otherBar:SetPoint('TOP')
    otherBar:SetPoint('BOTTOM')
    otherBar:SetPoint('LEFT', myBar:GetStatusBarTexture(), 'RIGHT')
    otherBar:SetWidth(200)

    local absorbBar = CreateFrame('StatusBar', nil, self.Health)
    absorbBar:SetPoint('TOP')
    absorbBar:SetPoint('BOTTOM')
    absorbBar:SetPoint('LEFT', otherBar:GetStatusBarTexture(), 'RIGHT')
    absorbBar:SetWidth(200)

    local healAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
    healAbsorbBar:SetPoint('TOP')
    healAbsorbBar:SetPoint('BOTTOM')
    healAbsorbBar:SetPoint('RIGHT', self.Health:GetStatusBarTexture())
    healAbsorbBar:SetWidth(200)
    healAbsorbBar:SetReverseFill(true)

    local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
    overAbsorb:SetPoint('TOP')
    overAbsorb:SetPoint('BOTTOM')
    overAbsorb:SetPoint('LEFT', self.Health, 'RIGHT')
    overAbsorb:SetWidth(10)

	local overHealAbsorb = self.Health:CreateTexture(nil, "OVERLAY")
    overHealAbsorb:SetPoint('TOP')
    overHealAbsorb:SetPoint('BOTTOM')
    overHealAbsorb:SetPoint('RIGHT', self.Health, 'LEFT')
    overHealAbsorb:SetWidth(10)

    -- Register with oUF
    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        absorbBar = absorbBar,
        healAbsorbBar = healAbsorbBar,
        overAbsorb = overAbsorb,
        overHealAbsorb = overHealAbsorb,
        maxOverflow = 1.05,
    }
--]]

local _, ns = ...
local oUF = ns.oUF

local HealComm = LibStub('LibHealComm-4.0', true)

local function UpdateSize(self, event, unit)
	local element = self.HealthPrediction

	if(element.myBar) then
		element.myBar[element.isHoriz and 'SetWidth' or 'SetHeight'](element.myBar, element.size)
	end

	if(element.otherBar) then
		element.otherBar[element.isHoriz and 'SetWidth' or 'SetHeight'](element.otherBar, element.size)
	end

	if(element.absorbBar) then
		element.absorbBar[element.isHoriz and 'SetWidth' or 'SetHeight'](element.absorbBar, element.size)
	end

	if(element.healAbsorbBar) then
		element.healAbsorbBar[element.isHoriz and 'SetWidth' or 'SetHeight'](element.healAbsorbBar, element.size)
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

	local GUID = UnitGUID(unit)
	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local overTimeHeals = not oUF.isRetail and HealComm and ((HealComm:GetHealAmount(GUID, HealComm.OVERTIME_AND_BOMB_HEALS) or 0) * (HealComm:GetHealModifier(GUID) or 1)) or 0
	local absorb = (oUF.isRetail or oUF.isMists) and UnitGetTotalAbsorbs(unit) or 0
	local healAbsorb = (oUF.isRetail or oUF.isMists) and UnitGetTotalHealAbsorbs(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
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

		if(health + allIncomingHeal > maxHealth * element.maxOverflow) then
			allIncomingHeal = maxHealth * element.maxOverflow - health
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

	if(element.myBar) then
		element.myBar:SetMinMaxValues(0, maxHealth)
		element.myBar:SetValue(myIncomingHeal)
		element.myBar:Show()
	end

	if(element.otherBar) then
		element.otherBar:SetMinMaxValues(0, maxHealth)
		element.otherBar:SetValue(otherIncomingHeal)
		element.otherBar:Show()
	end

	if(element.absorbBar) then
		element.absorbBar:SetMinMaxValues(0, maxHealth)
		element.absorbBar:SetValue(absorb)
		element.absorbBar:Show()
	end

	if(element.healAbsorbBar) then
		element.healAbsorbBar:SetMinMaxValues(0, maxHealth)
		element.healAbsorbBar:SetValue(healAbsorb)
		element.healAbsorbBar:Show()
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
	--[[if(shouldUpdateSize(self)) then
		(self.HealthPrediction.UpdateSize or UpdateSize) (self, ...)
	end]]

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

		if(element.myBar) then
			if(element.myBar:IsObjectType('StatusBar') and not element.myBar:GetStatusBarTexture()) then
				element.myBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.otherBar) then
			if(element.otherBar:IsObjectType('StatusBar') and not element.otherBar:GetStatusBarTexture()) then
				element.otherBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.absorbBar) then
			if(element.absorbBar:IsObjectType('StatusBar') and not element.absorbBar:GetStatusBarTexture()) then
				element.absorbBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.healAbsorbBar) then
			if(element.healAbsorbBar:IsObjectType('StatusBar') and not element.healAbsorbBar:GetStatusBarTexture()) then
				element.healAbsorbBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
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
		if(element.myBar) then
			element.myBar:Hide()
		end

		if(element.otherBar) then
			element.otherBar:Hide()
		end

		if(element.absorbBar) then
			element.absorbBar:Hide()
		end

		if(element.healAbsorbBar) then
			element.healAbsorbBar:Hide()
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
