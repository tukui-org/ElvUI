--[[
# Element: Threat Indicator

Handles the visibility and updating of an indicator based on the unit's current threat level.

## Widget

ThreatIndicator - A `Texture` used to display the current threat level.
The element works by changing the texture's vertex color.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Options

.feedbackUnit - The unit whose threat situation is being requested. If defined, it'll be passed as the first argument to
                [GetThreatStatusColor](http://wowprogramming.com/docs/api/UnitThreatSituation.html).

## Examples

    -- Position and size
    local ThreatIndicator = self:CreateTexture(nil, 'OVERLAY')
    ThreatIndicator:SetSize(16, 16)
    ThreatIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.ThreatIndicator = ThreatIndicator
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local UnitExists = Private.UnitExists

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local element = self.ThreatIndicator
	--[[ Callback: ThreatIndicator:PreUpdate(unit)
	Called before the element has been updated.

	* self - the ThreatIndicator element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local feedbackUnit = element.feedbackUnit
	unit = unit or self.unit

	local status
	-- BUG: Non-existent '*target' or '*pet' units cause UnitThreatSituation() errors
	if(UnitExists(unit)) then
		if(feedbackUnit and feedbackUnit ~= unit and UnitExists(feedbackUnit)) then
			status = UnitThreatSituation(feedbackUnit, unit)
		else
			status = UnitThreatSituation(unit)
		end
	end

	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)

		if(element.SetVertexColor) then
			element:SetVertexColor(r, g, b)
		end

		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: ThreatIndicator:PostUpdate(unit, status, r, g, b)
	Called after the element has been updated.

	* self   - the ThreatIndicator element
	* unit   - the unit for which the update has been triggered (string)
	* status - the unit's threat status (see [UnitThreatSituation](http://wowprogramming.com/docs/api/UnitThreatSituation.html))
	* r      - the red color component based on the unit's threat status (number?)[0-1]
	* g      - the green color component based on the unit's threat status (number?)[0-1]
	* b      - the blue color component based on the unit's threat status (number?)[0-1]
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, status, r, g, b)
	end
end

local function Path(self, ...)
	--[[ Override: ThreatIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ThreatIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.ThreatIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', Path)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', Path)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\Minimap\ObjectIcons]])
			element:SetTexCoord(6/8, 7/8, 1/8, 2/8)
		end

		return true
	end
end

local function Disable(self)
	local element = self.ThreatIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_THREAT_SITUATION_UPDATE', Path)
		self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE', Path)
	end
end

oUF:AddElement('ThreatIndicator', Path, Enable, Disable)
