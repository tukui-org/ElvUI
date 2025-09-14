--[[
# Element: PvPClassificationIndicator

Handles the visibility and updating of an indicator based on the unit's PvP classification.

## Widget

PvPClassificationIndicator - A `Texture` used to display PvP classification.

## Notes

This element updates by changing the texture.

## Options

.useAtlasSize - Makes the element use preprogrammed atlas' size instead of its set dimensions (boolean)

## Examples

    -- Position and size
    local PvPClassificationIndicator = self:CreateTexture(nil, 'OVERLAY')
    PvPClassificationIndicator:SetSize(24, 24)
    PvPClassificationIndicator:SetPoint('CENTER')

    -- Register it with oUF
    self.PvPClassificationIndicator = PvPClassificationIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

-- sourced from Blizzard_UnitFrame/Mainline/CompactUnitFrame.lua
local ICONS = {
	[Enum.PvPUnitClassification.FlagCarrierHorde or 0] = "nameplates-icon-flag-horde",
	[Enum.PvPUnitClassification.FlagCarrierAlliance or 1] = "nameplates-icon-flag-alliance",
	[Enum.PvPUnitClassification.FlagCarrierNeutral or 2] = "nameplates-icon-flag-neutral",
	[Enum.PvPUnitClassification.CartRunnerHorde or 3] = "nameplates-icon-cart-horde",
	[Enum.PvPUnitClassification.CartRunnerAlliance or 4] = "nameplates-icon-cart-alliance",
	[Enum.PvPUnitClassification.AssassinHorde or 5] = "nameplates-icon-bounty-horde",
	[Enum.PvPUnitClassification.AssassinAlliance or 6] = "nameplates-icon-bounty-alliance",
	[Enum.PvPUnitClassification.OrbCarrierBlue or 7] = "nameplates-icon-orb-blue",
	[Enum.PvPUnitClassification.OrbCarrierGreen or 8] = "nameplates-icon-orb-green",
	[Enum.PvPUnitClassification.OrbCarrierOrange or 9] = "nameplates-icon-orb-orange",
	[Enum.PvPUnitClassification.OrbCarrierPurple or 10] = "nameplates-icon-orb-purple",
}

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.PvPClassificationIndicator

	--[[ Callback: PvPClassificationIndicator:PreUpdate(unit)
	Called before the element has been updated.

	* self - the PvPClassificationIndicator element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local class = UnitPvpClassification(unit)
	local icon = ICONS[class]
	if(icon) then
		element:SetAtlas(icon, element.useAtlasSize)
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: PvPClassificationIndicator:PostUpdate(unit, class)
	Called after the element has been updated.

	* self  - the PvPClassificationIndicator element
	* unit  - the unit for which the update has been triggered (string)
	* class - the pvp classification of the unit (number?)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, class)
	end
end

local function Path(self, ...)
	--[[Override: PvPClassificationIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.PvPClassificationIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.PvPClassificationIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)

		return true
	end
end

local function Disable(self)
	local element = self.PvPClassificationIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_CLASSIFICATION_CHANGED', Path)
	end
end

oUF:AddElement('PvPClassificationIndicator', Path, Enable, Disable)
