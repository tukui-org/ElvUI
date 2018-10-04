--[[
# Element: Phasing Indicator

Toggles the visibility of an indicator based on the unit's phasing relative to the player.

## Widget

PhaseIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local PhaseIndicator = self:CreateTexture(nil, 'OVERLAY')
    PhaseIndicator:SetSize(16, 16)
    PhaseIndicator:SetPoint('TOPLEFT', self)

    -- Register it with oUF
    self.PhaseIndicator = PhaseIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.PhaseIndicator

	--[[ Callback: PhaseIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the PhaseIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isInSamePhase = UnitInPhase(self.unit) and not UnitIsWarModePhased(self.unit)
	if(not isInSamePhase and UnitIsPlayer(self.unit) and UnitIsConnected(self.unit)) then
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: PhaseIndicator:PostUpdate(isInSamePhase)
	Called after the element has been updated.

	* self          - the PhaseIndicator element
	* isInSamePhase - indicates whether the unit is in the same phase as the player (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isInSamePhase)
	end
end

local function Path(self, ...)
	--[[ Override: PhaseIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.PhaseIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.PhaseIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_PHASE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\TargetingFrame\UI-PhasingIcon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.PhaseIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_PHASE', Path)
	end
end

oUF:AddElement('PhaseIndicator', Path, Enable, Disable)
