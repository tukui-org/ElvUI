--[[ Element: Power Prediction Bar
 Handles updating and visibility of the power prediction status bars.

 Widget

 PowerPrediction - A table containing `mainBar` and `altBar`.

 Sub-Widgets

 mainBar - A StatusBar used to represent power cost of spells, that consume
           your main power, e.g. mana for mages;
 altBar  - A StatusBar used to represent power cost of spells, that consume
           your additional power, e.g. mana for balance druids.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
 status bar texture.

 Examples

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

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local _, ns = ...
local oUF = ns.oUF

local playerClass = select(2, UnitClass('player'))

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local pp = self.PowerPrediction

	if(pp.PreUpdate) then
		pp:PreUpdate(unit)
	end

	local _, _, _, _, startTime, endTime, _, _, _, spellID = UnitCastingInfo(unit)
	local mainPowerType = UnitPowerType(unit)
	local hasAltManaBar = ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass] and ALT_MANA_BAR_PAIR_DISPLAY_INFO[playerClass][mainPowerType]
	local mainCost, altCost = 0, 0

	if(event == 'UNIT_SPELLCAST_START' or startTime ~= endTime) then
		local costTable = GetSpellPowerCost(spellID)

		for _, costInfo in pairs(costTable) do
			--[[costInfo content:
				-- name: string (powerToken)
				-- type: number (powerType)
				-- cost: number
				-- costPercent: number
				-- costPerSec: number
				-- minCost: number
				-- hasRequiredAura: boolean
				-- requiredAuraID: number
			]]
			if(costInfo.type == mainPowerType) then
				mainCost = costInfo.cost

				break
			elseif(costInfo.type == ADDITIONAL_POWER_BAR_INDEX) then
				altCost = costInfo.cost

				break
			end
		end
	end

	if(pp.mainBar) then
		pp.mainBar:SetMinMaxValues(0, UnitPowerMax(unit, mainPowerType))
		pp.mainBar:SetValue(mainCost)
		pp.mainBar:Show()
	end

	if(pp.altBar and hasAltManaBar) then
		pp.altBar:SetMinMaxValues(0, UnitPowerMax(unit, ADDITIONAL_POWER_BAR_INDEX))
		pp.altBar:SetValue(altCost)
		pp.altBar:Show()
	end

	if(pp.PostUpdate) then
		return pp:PostUpdate(unit, mainCost, altCost, hasAltManaBar)
	end
end

local function Path(self, ...)
	return (self.PowerPrediction.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local pp = self.PowerPrediction

	if(pp) then
		pp.__owner = self
		pp.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_SPELLCAST_START', Path)
		self:RegisterEvent('UNIT_SPELLCAST_STOP', Path)
		self:RegisterEvent('UNIT_SPELLCAST_FAILED', Path)
		self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)

		if(pp.mainBar) then
			if(pp.mainBar:IsObjectType('StatusBar') and not pp.mainBar:GetStatusBarTexture()) then
				pp.mainBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(pp.altBar) then
			if(pp.altBar:IsObjectType('StatusBar') and not pp.altBar:GetStatusBarTexture()) then
				pp.altBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		return true
	end
end

local function Disable(self)
	local pp = self.PowerPrediction

	if(pp) then
		if(pp.mainBar) then
			pp.mainBar:Hide()
		end

		if(pp.altBar) then
			pp.altBar:Hide()
		end

		self:UnregisterEvent('UNIT_SPELLCAST_START', Path)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', Path)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', Path)
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
	end
end

oUF:AddElement('PowerPrediction', Path, Enable, Disable)
