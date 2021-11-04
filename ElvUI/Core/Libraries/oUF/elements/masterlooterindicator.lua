--[[
# Element: Master Looter Indicator

Toggles the visibility of an indicator based on the unit's master looter status.

## Widget

MasterLooterIndicator - Any UI widget.

## Notes

A default texture will be applied if the widget is a Texture and doesn't have a texture or a color set.

## Examples

    -- Position and size
    local MasterLooterIndicator = self:CreateTexture(nil, 'OVERLAY')
    MasterLooterIndicator:SetSize(16, 16)
    MasterLooterIndicator:SetPoint('TOPRIGHT', self)

    -- Register it with oUF
    self.MasterLooterIndicator = MasterLooterIndicator
--]]

local _, ns = ...
local oUF = ns.oUF

local GetLootMethod = GetLootMethod
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsUnit = UnitIsUnit

local function Update(self, event)
	local unit = self.unit
	local element = self.MasterLooterIndicator

	--[[ Callback: MasterLooterIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the MasterLooterIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local isShown = false
	if(UnitInParty(unit) or UnitInRaid(unit)) then
		local method, partyIndex, raidIndex = GetLootMethod()
		if(method == 'master') then
			local mlUnit
			if(partyIndex) then
				if(partyIndex == 0) then
					mlUnit = 'player'
				else
					mlUnit = 'party' .. partyIndex
				end
			elseif(raidIndex) then
				mlUnit = 'raid' .. raidIndex
			end

			isShown = mlUnit and UnitIsUnit(unit, mlUnit)
		end
	end

	if isShown then
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: MasterLooterIndicator:PostUpdate(isShown)
	Called after the element has been updated.

	* self    - the MasterLooterIndicator element
	* isShown - indicates whether the element is shown (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isShown)
	end
end

local function Path(self, ...)
	--[[ Override: MasterLooterIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.MasterLooterIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.MasterLooterIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PARTY_LOOT_METHOD_CHANGED', Path, true)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetTexture([[Interface\GroupFrame\UI-Group-MasterLooter]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.MasterLooterIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PARTY_LOOT_METHOD_CHANGED', Path)
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Path)
	end
end

oUF:AddElement('MasterLooterIndicator', Path, Enable, Disable)
