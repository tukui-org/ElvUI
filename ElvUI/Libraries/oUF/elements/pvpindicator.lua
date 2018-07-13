--[[
# Element: PvP Icon

Handles the visibility and updating of an indicator based on the unit's PvP status.

## Widget

PvPIndicator - A `Texture` used to display faction or FFA PvP status icon.

## Notes

This element updates by changing the texture.

## Examples

    -- Position and size
    local PvPIndicator = self:CreateTexture(nil, 'ARTWORK', nil, 1)
    PvPIndicator:SetSize(30, 30)
    PvPIndicator:SetPoint('RIGHT', self, 'LEFT')

    -- Register it with oUF
    self.PvPIndicator = PvPIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.PvPIndicator

	--[[ Callback: PvPIndicator:PreUpdate(unit)
	Called before the element has been updated.

	* self - the PvPIndicator element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local status
	local factionGroup = UnitFactionGroup(unit)

	if(UnitIsPVPFreeForAll(unit)) then
		status = 'FFA'
	elseif(factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		if(unit == 'player' and UnitIsMercenary(unit)) then
			if(factionGroup == 'Horde') then
				factionGroup = 'Alliance'
			elseif(factionGroup == 'Alliance') then
				factionGroup = 'Horde'
			end
		end

		status = factionGroup
	end

	if(status) then
		element:SetTexture([[Interface\TargetingFrame\UI-PVP-]] .. status)
		element:SetTexCoord(0, 0.65625, 0, 0.65625)
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: PvPIndicator:PostUpdate(unit, status)
	Called after the element has been updated.

	* self   - the PvPIndicator element
	* unit   - the unit for which the update has been triggered (string)
	* status - the unit's current PvP status or faction accounting for mercenary mode (string)['FFA', 'Alliance',
	           'Horde']
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, status)
	end
end

local function Path(self, ...)
	--[[Override: PvPIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.PvPIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.PvPIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_FACTION', Path)

		return true
	end
end

local function Disable(self)
	local element = self.PvPIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('PvPIndicator', Path, Enable, Disable)
