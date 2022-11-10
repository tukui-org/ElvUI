--[[
# Element: Leader Indicator

Toggles the visibility of an indicator based on the unit's leader status.

## Widget

LeaderIndicator - A `Texture` used to display if the unit is a leader.

## Notes

This element updates by changing the texture.

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

	-- There are two kinds of group leaders: guides and leaders. Guides are leaders of groups formed via LFD/LFR.
	-- There are also two types of groups: home (LE_PARTY_CATEGORY_HOME) and instance (LE_PARTY_CATEGORY_INSTANCE).
	-- A unit can be the leader of both, only one, or none. Use UnitIsGroupLeader(unit, LE_PARTY_CATEGORY_HOME) and
	-- UnitIsGroupLeader(unit, LE_PARTY_CATEGORY_INSTANCE) for more detailed info.
	-- There can be only ONE guide in any given party, but there can be multiple leaders, for instance, if two 2-man
	-- premades were put in one group, they'll keep their leader roles which can be seen by other members of their
	-- own groups via UnitIsGroupLeader(unit, LE_PARTY_CATEGORY_HOME) or by members of other groups via
	-- UnitLeadsAnyGroup(unit). Inside the group formed by the dungeon finder UnitIsGroupLeader(unit) will only return
	-- true for the instance leader.
	local isInLFGInstance = oUF.isRetail and HasLFGRestrictions()

	-- ElvUI changed block
	local isLeader
	if IsInInstance() then
		isLeader = UnitIsGroupLeader(unit)
	else
		isLeader = UnitLeadsAnyGroup(unit)
	end
	-- end block

	if(isLeader) then
       if(isInLFGInstance) then
			element:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])
			element:SetTexCoord(0, 0.296875, 0.015625, 0.3125)
		else
			element:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
			element:SetTexCoord(0, 1, 0, 1)
		end

		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: LeaderIndicator:PostUpdate(isLeader)
	Called after the element has been updated.

	* self            - the LeaderIndicator element
	* isLeader        - indicates whether the unit is the leader of the group (boolean)
	* isInLFGInstance - indicates whether the current party is subject to LFG restrictions (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(isLeader, isInLFGInstance)
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
