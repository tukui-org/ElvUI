--[[
# Element: PvP and Honor Level Icons

Handles the visibility and updating of an indicator based on the unit's PvP status and honor level.

## Widget

PvPIndicator - A `Texture` used to display faction, FFA PvP status or honor level icon.

## Sub-Widgets

Badge - A `Texture` used to display the honor badge background image.

## Notes

This element updates by changing the texture.
The `Badge` sub-widget has to be on a lower sub-layer than the `PvP` texture.

## Examples

    -- Position and size
    local PvPIndicator = self:CreateTexture(nil, 'ARTWORK', nil, 1)
    PvPIndicator:SetSize(30, 30)
    PvPIndicator:SetPoint('RIGHT', self, 'LEFT')

    local Badge = self:CreateTexture(nil, 'ARTWORK')
    Badge:SetSize(50, 52)
    Badge:SetPoint('CENTER', PvPIndicator, 'CENTER')

    -- Register it with oUF
    PvPIndicator.Badge = Badge
    self.PvPIndicator = PvPIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(unit and unit ~= self.unit) then return end

	local element = self.PvPIndicator
	unit = unit or self.unit

	--[[ Callback: PvPIndicator:PreUpdate(unit)
	Called before the element has been updated.

	* self - the PvPIndicator element
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PreUpdate) then
		element:PreUpdate(unit)
	end

	local status
	local factionGroup = UnitFactionGroup(unit) or 'Neutral'
	local honorRewardInfo = oUF.isRetail and C_PvP.GetHonorRewardInfo(UnitHonorLevel(unit))

	if(UnitIsPVPFreeForAll(unit)) then
		status = 'FFA'
	elseif(factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		if oUF.isRetail and (unit == 'player' and UnitIsMercenary(unit)) then
			if(factionGroup == 'Horde') then
				factionGroup = 'Alliance'
			elseif(factionGroup == 'Alliance') then
				factionGroup = 'Horde'
			end
		end

		status = factionGroup
	end

	if(status) then
		element:Show()

		if(element.Badge and honorRewardInfo) then
			element:SetTexture(honorRewardInfo.badgeFileDataID)
			element:SetTexCoord(0, 1, 0, 1)
			element.Badge:SetAtlas('honorsystem-portrait-' .. factionGroup, false)
			element.Badge:Show()
		else
			element:SetTexture([[Interface\TargetingFrame\UI-PVP-]] .. status)
			element:SetTexCoord(0, 0.65625, 0, 0.65625)

			if(element.Badge) then
				element.Badge:Hide()
			end
		end
	else
		element:Hide()

		if(element.Badge) then
			element.Badge:Hide()
		end
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

		if oUF.isRetail then
			self:RegisterEvent('HONOR_LEVEL_UPDATE', Path, true)
		end

		return true
	end
end

local function Disable(self)
	local element = self.PvPIndicator
	if(element) then
		element:Hide()

		if(element.Badge) then
			element.Badge:Hide()
		end

		self:UnregisterEvent('UNIT_FACTION', Path)

		if oUF.isRetail then
			self:UnregisterEvent('HONOR_LEVEL_UPDATE', Path)
		end
	end
end

oUF:AddElement('PvPIndicator', Path, Enable, Disable)
