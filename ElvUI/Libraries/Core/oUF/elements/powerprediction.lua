--[[
# Element: Power Prediction Bar

Handles the visibility and updating of power cost prediction.

## Widget

PowerPrediction - A `table` containing the sub-widgets.

## Sub-Widgets

mainBar - A `StatusBar` used to represent power cost of spells on top of the Power element.
altBar  - A `StatusBar` used to represent power cost of spells on top of the AdditionalPower element.

## Notes

A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.

## Examples

    -- Position and size
    local mainBar = CreateFrame('StatusBar', nil, self.Power)
    mainBar:SetReverseFill(true)
    mainBar:SetPoint('TOP')
    mainBar:SetPoint('BOTTOM')
    mainBar:SetPoint('RIGHT', self.Power:GetStatusBarTexture(), 'RIGHT')
    mainBar:SetWidth(200)

    local altBar = CreateFrame('StatusBar', nil, self.AdditionalPower)
    altBar:SetReverseFill(true)
    altBar:SetPoint('TOP')
    altBar:SetPoint('BOTTOM')
    altBar:SetPoint('RIGHT', self.AdditionalPower:GetStatusBarTexture(), 'RIGHT')
    altBar:SetWidth(200)

    -- Register with oUF
    self.PowerPrediction = {
        mainBar = mainBar,
        altBar = altBar
    }
--]]

local _, ns = ...
local oUF = ns.oUF

-- sourced from FrameXML/AlternatePowerBar.lua
local ADDITIONAL_POWER_BAR_INDEX = _G.ADDITIONAL_POWER_BAR_INDEX or 0
local ALT_MANA_BAR_PAIR_DISPLAY_INFO = _G.ALT_MANA_BAR_PAIR_DISPLAY_INFO

local _, playerClass = UnitClass('player')

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.PowerPrediction

	--[[ Callback: PowerPrediction:PreUpdate(unit)
	Called before the element has been updated.

	* self - the PowerPrediction element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local mainCost, altCost = 0, 0
	local mainType = UnitPowerType(unit)
	local mainMax = UnitPowerMax(unit, mainType)
	local isPlayer = UnitIsUnit('player', unit)
	local altManaInfo = isPlayer and oUF.isRetail and ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass]
	local hasAltManaBar = altManaInfo and altManaInfo[mainType]
	local _, _, _, startTime, endTime, _, _, _, spellID = UnitCastingInfo(unit)

	if(event == 'UNIT_SPELLCAST_START' and startTime ~= endTime) then
		local costTable = GetSpellPowerCost(spellID)
		if not costTable then
			element.mainCost = mainCost
			element.altCost = altCost
		else
			local checkRequiredAura = isPlayer and #costTable > 1
			for _, costInfo in next, costTable do
				local cost, ctype, cperc = costInfo.cost, costInfo.type, costInfo.costPercent
				local checkSpec = not checkRequiredAura or costInfo.hasRequiredAura
				if checkSpec and ctype == mainType then
					mainCost = ((isPlayer or cost < mainMax) and cost) or (mainMax * cperc) / 100
					element.mainCost = mainCost

					break
				elseif hasAltManaBar and checkSpec and ctype == ADDITIONAL_POWER_BAR_INDEX then
					altCost = cost
					element.altCost = altCost

					break
				end
			end
		end
	elseif(spellID) then
		-- if we try to cast a spell while casting another one we need to avoid resetting the element
		mainCost = element.mainCost or 0
		altCost = element.altCost or 0
	else
		element.mainCost = mainCost
		element.altCost = altCost
	end

	if(element.mainBar) then
		element.mainBar:SetMinMaxValues(0, mainMax)
		element.mainBar:SetValue(mainCost)
		element.mainBar:Show()
	end

	if(element.altBar and hasAltManaBar) then
		element.altBar:SetMinMaxValues(0, UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX))
		element.altBar:SetValue(altCost)
		element.altBar:Show()
	end

	--[[ Callback: PowerPrediction:PostUpdate(unit, mainCost, altCost, hasAltManaBar)
	Called after the element has been updated.

	* self          - the PowerPrediction element
	* unit          - the unit for which the update has been triggered (string)
	* mainCost      - the main power type cost of the cast ability (number)
	* altCost       - the secondary power type cost of the cast ability (number)
	* hasAltManaBar - indicates if the unit has a secondary power bar (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, mainCost, altCost, hasAltManaBar)
	end
end

local function Path(self, ...)
	--[[ Override: PowerPrediction.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.PowerPrediction.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.PowerPrediction
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		oUF:RegisterEvent(self, 'UNIT_SPELLCAST_START', Path)
		oUF:RegisterEvent(self, 'UNIT_SPELLCAST_STOP', Path)
		oUF:RegisterEvent(self, 'UNIT_SPELLCAST_FAILED', Path)
		oUF:RegisterEvent(self, 'UNIT_SPELLCAST_SUCCEEDED', Path)
		oUF:RegisterEvent(self, 'UNIT_DISPLAYPOWER', Path)

		if(element.mainBar) then
			if(element.mainBar:IsObjectType('StatusBar')
				and not (element.mainBar:GetStatusBarTexture() or element.mainBar:GetStatusBarAtlas())) then
				element.mainBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(element.altBar) then
			if(element.altBar:IsObjectType('StatusBar')
				and not (element.altBar:GetStatusBarTexture() or element.altBar:GetStatusBarAtlas())) then
				element.altBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.PowerPrediction
	if(element) then
		if(element.mainBar) then
			element.mainBar:Hide()
		end

		if(element.altBar) then
			element.altBar:Hide()
		end

		oUF:UnregisterEvent(self, 'UNIT_SPELLCAST_START', Path)
		oUF:UnregisterEvent(self, 'UNIT_SPELLCAST_STOP', Path)
		oUF:UnregisterEvent(self, 'UNIT_SPELLCAST_FAILED', Path)
		oUF:UnregisterEvent(self, 'UNIT_SPELLCAST_SUCCEEDED', Path)
		oUF:UnregisterEvent(self, 'UNIT_DISPLAYPOWER', Path)
	end
end

oUF:AddElement('PowerPrediction', Path, Enable, Disable)
