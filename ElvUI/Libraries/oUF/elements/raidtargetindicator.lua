--[[
# Element: Raid Target Indicator

Handles the visibility and updating of an indicator based on the unit's raid target assignment.

## Widget

RaidTargetIndicator - A `Texture` used to display the raid target icon.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture set.

## Examples

    -- Position and size
    local RaidTargetIndicator = self:CreateTexture(nil, 'OVERLAY')
    RaidTargetIndicator:SetSize(16, 16)
    RaidTargetIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.RaidTargetIndicator = RaidTargetIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

local function Update(self, event)
	local element = self.RaidTargetIndicator

	--[[ Callback: RaidTargetIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the RaidTargetIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local index = GetRaidTargetIndex(self.unit)
	if(index) then
		SetRaidTargetIconTexture(element, index)
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: RaidTargetIndicator:PostUpdate(index)
	Called after the element has been updated.

	* self  - the RaidTargetIndicator element
	* index - the index of the raid target marker (number?)[1-8]
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(index)
	end
end

local function Path(self, ...)
	--[[ Override: RaidTargetIndicator.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.RaidTargetIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	if(not element.__owner.unit) then return end
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.RaidTargetIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('RAID_TARGET_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.RaidTargetIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('RAID_TARGET_UPDATE', Path)
	end
end

oUF:AddElement('RaidTargetIndicator', Path, Enable, Disable)
