--[[
# Element: Leader Indicator

Toggles the visibility of an indicator based on the unit's leader status.

## Widget

LeaderIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local LeaderIndicator = self:CreateTexture(nil, 'OVERLAY')
    LeaderIndicator:SetSize(16, 16)
    LeaderIndicator:SetPoint('BOTTOM', self, 'TOP')

    -- Register it with oUF
    self.LeaderIndicator = LeaderIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event)
	local element = self.LeaderIndicator
	local unit = self.unit

	--[[ Callback: LeaderIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the LeaderIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isLeader = UnitLeadsAnyGroup(unit)
	if IsInInstance() then
		isLeader = UnitIsGroupLeader(unit)
	end

	if(isLeader) then
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: LeaderIndicator:PostUpdate(isLeader)
	Called after the element has been updated.

	* self     - the LeaderIndicator element
	* isLeader - indicates whether the element is shown (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isLeader)
	end
end

local function Path(self, ...)
	--[[ Override: LeaderIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.LeaderIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local element = self.LeaderIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PARTY_LEADER_CHANGED', Path, true)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.LeaderIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PARTY_LEADER_CHANGED', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('LeaderIndicator', Path, Enable, Disable)
