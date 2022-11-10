--[[
# Element: Assistant Indicator

Toggles the visibility of an indicator based on the unit's raid assistant status.

## Widget

AssistantIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local AssistantIndicator = self:CreateTexture(nil, 'OVERLAY')
    AssistantIndicator:SetSize(16, 16)
    AssistantIndicator:SetPoint('TOP', self)

    -- Register it with oUF
    self.AssistantIndicator = AssistantIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.AssistantIndicator
	local unit = self.unit

	--[[ Callback: AssistantIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the AssistantIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isAssistant = UnitInRaid(unit) and UnitIsGroupAssistant(unit) and not UnitIsGroupLeader(unit)
	if(isAssistant) then
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: AssistantIndicator:PostUpdate(isAssistant)
	Called after the element has been updated.

	* self        - the AssistantIndicator element
	* isAssistant - indicates whether the unit is a raid assistant (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isAssistant)
	end
end

local function Path(self, ...)
	--[[ Override: AssistantIndicator.Override(self, event, ...)
	Used to completely override the element's update process.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event (string)
	--]]
	return (self.AssistantIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.AssistantIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.AssistantIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('AssistantIndicator', Path, Enable, Disable)
