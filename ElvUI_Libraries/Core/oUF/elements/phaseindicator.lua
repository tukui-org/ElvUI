--[[
# Element: Phasing Indicator

Toggles the visibility of an indicator based on the unit's phasing relative to the player.

## Widget

PhaseIndicator - Any UI widget.

## Sub-Widgets

Icon - A `Texture` to represent the phased status.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.
OnEnter and OnLeave script handlers will be set to display a Tooltip if the widget is mouse enabled and does not have
OnEnter and/or OnLeave handlers.

## Examples

    -- Position and size
    local PhaseIndicator = CreateFrame('Frame', nil, self)
    PhaseIndicator:SetSize(16, 16)
    PhaseIndicator:SetPoint('TOPLEFT', self)
    PhaseIndicator:EnableMouse(true)

    local Icon = PhaseIndicator:CreateTexture(nil, 'OVERLAY')
    Icon:SetAllPoints()
    PhaseIndicator.Icon = Icon

    -- Register it with oUF
    self.PhaseIndicator = PhaseIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local GameTooltip = GameTooltip

--[[ Override: PhaseIndicator:UpdateTooltip()
Used to populate the tooltip when the widget is hovered.

* self - the PhaseIndicator widget
--]]
local function UpdateTooltip(element)
	if GameTooltip:IsForbidden() then return end

	local text = PartyUtil.GetPhasedReasonString(element.reason, element.__owner.unit)
	if(text) then
		GameTooltip:SetText(text, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end
end

local function onEnter(element)
	if GameTooltip:IsForbidden() or not element:IsVisible() then return end

	if(element.reason) then
		GameTooltip:SetOwner(element, 'ANCHOR_BOTTOMRIGHT')
		element:UpdateTooltip()
	end
end

local function onLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.PhaseIndicator

	--[[ Callback: PhaseIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the PhaseIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	-- BUG: UnitPhaseReason returns wrong data for friendly NPCs in phased scenarios like WM or Chromie Time
	-- https://github.com/Stanzilla/WoWUIBugs/issues/49
	local phaseReason = UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitPhaseReason(unit) or nil
	if(phaseReason) then
		element:Show()
	else
		element:Hide()
	end

	element.reason = phaseReason

	--[[ Callback: PhaseIndicator:PostUpdate(isInSamePhase, phaseReason)
	Called after the element has been updated.

	* self          - the PhaseIndicator element
	* isInSamePhase - indicates whether the unit is in the same phase as the player (boolean)
	* phaseReason   - the reason why the unit is in a different phase (number?)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(not phaseReason, phaseReason)
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
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.PhaseIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_PHASE', Path)

		local icon = (element.Icon or element)
		if(icon:IsObjectType('Texture') and not icon:GetTexture()) then
			icon:SetTexture([[Interface\TargetingFrame\UI-PhasingIcon]])
		end

		if(element.IsMouseEnabled and element:IsMouseEnabled()) then
			if(not element:GetScript('OnEnter')) then
				element:SetScript('OnEnter', onEnter)
			end

			if(not element:GetScript('OnLeave')) then
				element:SetScript('OnLeave', onLeave)
			end

			element.UpdateTooltip = element.UpdateTooltip or UpdateTooltip
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
