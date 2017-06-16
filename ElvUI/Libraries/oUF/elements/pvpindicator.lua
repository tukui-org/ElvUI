--[[
# Element: PvP and Prestige Icons

Handles the visibility and updating of an indicator based on the unit's PvP status and prestige level.

## Widget

PvPIndicator - A `Texture` used to display faction, FFA PvP status or prestige icon.

## Sub-Widgets

Prestige - A `Texture` used to display the prestige background image.

## Notes

This element updates by changing the texture.
The `Prestige` sub-widget has to be on a lower sub-layer than the `PvP` texture.

## Examples

    -- Position and size
    local PvPIndicator = self:CreateTexture(nil, 'ARTWORK', nil, 1)
    PvPIndicator:SetSize(30, 30)
    PvPIndicator:SetPoint('RIGHT', self, 'LEFT')

    local Prestige = self:CreateTexture(nil, 'ARTWORK')
    Prestige:SetSize(50, 52)
    Prestige:SetPoint('CENTER', PvPIndicator, 'CENTER')

    -- Register it with oUF
	PvPIndicator.Prestige = Prestige
    self.PvPIndicator = PvPIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local FFA_ICON = [[Interface\TargetingFrame\UI-PVP-FFA]]
local FACTION_ICON = [[Interface\TargetingFrame\UI-PVP-]]

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
	local prestigeLevel = UnitPrestige(unit)
	local factionGroup = UnitFactionGroup(unit)

	if(UnitIsPVPFreeForAll(unit)) then
		if(element.Prestige and prestigeLevel > 0) then
			element:SetTexture(GetPrestigeInfo(prestigeLevel))
			element:SetTexCoord(0, 1, 0, 1)
			element.Prestige:SetAtlas('honorsystem-portrait-neutral', false)
		else
			element:SetTexture(FFA_ICON)
			element:SetTexCoord(0, 0.65625, 0, 0.65625)
		end

		status = 'ffa'
	elseif(factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		if(unit == 'player' and UnitIsMercenary(unit)) then
			if(factionGroup == 'Horde') then
				factionGroup = 'Alliance'
			elseif(factionGroup == 'Alliance') then
				factionGroup = 'Horde'
			end
		end

		if(element.Prestige and prestigeLevel > 0) then
			element:SetTexture(GetPrestigeInfo(prestigeLevel))
			element:SetTexCoord(0, 1, 0, 1)
			element.Prestige:SetAtlas('honorsystem-portrait-' .. factionGroup, false)
		else
			element:SetTexture(FACTION_ICON .. factionGroup)
			element:SetTexCoord(0, 0.65625, 0, 0.65625)
		end

		status = factionGroup
	end

	if(status) then
		element:Show()

		if(element.Prestige) then
			if(prestigeLevel > 0) then
				element.Prestige:Show()
			else
				element.Prestige:Hide()
			end
		end
	else
		element:Hide()

		if(element.Prestige) then
			element.Prestige:Hide()
		end
	end

	--[[ Callback: PvPIndicator:PostUpdate(unit, status, prestigeLevel)
	Called after the element has been updated.

	* self          - the PvPIndicator element
	* unit          - the unit for which the update has been triggered (string)
	* status        - the unit's current PvP status or faction accounting for mercenary mode (string)['ffa', 'Alliance',
	                  'Horde']
	* prestigeLevel - the unit's current prestige rank (number)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(unit, status, prestigeLevel)
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

		if(element.Prestige) then
			self:RegisterEvent('HONOR_PRESTIGE_UPDATE', Path)
		end

		return true
	end
end

local function Disable(self)
	local element = self.PvPIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_FACTION', Path)

		if(element.Prestige) then
			element.Prestige:Hide()

			self:UnregisterEvent('HONOR_PRESTIGE_UPDATE', Path)
		end
	end
end

oUF:AddElement('PvPIndicator', Path, Enable, Disable)
