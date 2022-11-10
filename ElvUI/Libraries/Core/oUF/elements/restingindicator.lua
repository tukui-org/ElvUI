--[[
# Element: Resting Indicator

Toggles the visibility of an indicator based on the player's resting status.

## Widget

RestingIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local RestingIndicator = self:CreateTexture(nil, 'OVERLAY')
    RestingIndicator:SetSize(16, 16)
    RestingIndicator:SetPoint('TOPLEFT', self)

    -- Register it with oUF
    self.RestingIndicator = RestingIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.RestingIndicator

	--[[ Callback: RestingIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the RestingIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isResting = IsResting()
	if(isResting) then
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: RestingIndicator:PostUpdate(isResting)
	Called after the element has been updated.

	* self      - the RestingIndicator element
	* isResting - indicates if the player is resting (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isResting)
	end
end

local function Path(self, ...)
	--[[ Override: RestingIndicator.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.RestingIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.RestingIndicator
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_UPDATE_RESTING', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
			element:SetTexCoord(0, 0.5, 0, 0.421875)
		end

		return true
	end
end

local function Disable(self)
	local element = self.RestingIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PLAYER_UPDATE_RESTING', Path)
	end
end

oUF:AddElement('RestingIndicator', Path, Enable, Disable)
