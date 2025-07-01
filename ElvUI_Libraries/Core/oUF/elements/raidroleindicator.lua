--[[
# Element: Raid Role Indicator

Handles the visibility and updating of an indicator based on the unit's raid assignment (main tank or main assist).

## Widget

RaidRoleIndicator - A `Texture` representing the unit's raid assignment.

## Notes

This element updates by changing the texture.

## Examples

    -- Position and size
    local RaidRoleIndicator = self:CreateTexture(nil, 'OVERLAY')
    RaidRoleIndicator:SetSize(16, 16)
    RaidRoleIndicator:SetPoint('TOPLEFT')

    -- Register it with oUF
    self.RaidRoleIndicator = RaidRoleIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local MAINTANK_ICON = [[Interface\GROUPFRAME\UI-GROUP-MAINTANKICON]]
local MAINASSIST_ICON = [[Interface\GROUPFRAME\UI-GROUP-MAINASSISTICON]]

local function Update(self, event)
	local element = self.RaidRoleIndicator
	local unit = self.unit

	--[[ Callback: RaidRoleIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the RaidRoleIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local inVehicle, role = (oUF.isRetail or oUF.isMists) and UnitHasVehicleUI(unit)
	if(UnitInRaid(unit) and not inVehicle) then
		if(GetPartyAssignment('MAINTANK', unit)) then
			role = 'MAINTANK'
			element:SetTexture(MAINTANK_ICON)
		elseif(GetPartyAssignment('MAINASSIST', unit)) then
			role = 'MAINASSIST'
			element:SetTexture(MAINASSIST_ICON)
		end
	end

	if element.combatHide and UnitAffectingCombat(unit) then
		element:SetShown(false)
	else
		element:SetShown(not not role)
	end

	--[[ Callback: RaidRoleIndicator:PostUpdate(role)
	Called after the element has been updated.

	* self - the RaidRoleIndicator element
	* role - the unit's raid assignment (string?)['MAINTANK', 'MAINASSIST']
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(role)
	end
end

local function Path(self, ...)
	--[[ Override: RaidRoleIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.RaidRoleIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.RaidRoleIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		oUF:RegisterEvent(self, 'UNIT_FLAGS', Path)
		oUF:RegisterEvent(self, 'GROUP_ROSTER_UPDATE', Path, true)
		oUF:RegisterEvent(self, 'PLAYER_REGEN_DISABLED', Path, true)
		oUF:RegisterEvent(self, 'PLAYER_REGEN_ENABLED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.RaidRoleIndicator
	if(element) then
		element:Hide()

		oUF:UnregisterEvent(self, 'UNIT_FLAGS', Path)
		oUF:UnregisterEvent(self, 'GROUP_ROSTER_UPDATE', Path)
		oUF:UnregisterEvent(self, 'PLAYER_REGEN_DISABLED', Path)
		oUF:UnregisterEvent(self, 'PLAYER_REGEN_ENABLED', Path)
	end
end

oUF:AddElement('RaidRoleIndicator', Path, Enable, Disable)
