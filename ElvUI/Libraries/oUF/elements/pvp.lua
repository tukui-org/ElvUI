--[[ Element: PvP Icon

 Handles updating and toggles visibility based upon the units PvP status.

 Widget

 PvP - A Texture used to display the faction or FFA icon.

 Notes

 This element updates by changing the texture.

 Examples

   -- Position and size
   local PvP = self:CreateTexture(nil, 'OVERLAY')
   PvP:SetSize(16, 16)
   PvP:SetPoint('TOPRIGHT', self)
   
   -- Register it with oUF
   self.PvP = PvP

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(unit ~= self.unit) then return end

	local pvp = self.PvP
	if(pvp.PreUpdate) then
		pvp:PreUpdate()
	end

	local status
	local factionGroup = UnitFactionGroup(unit)
	if(UnitIsPVPFreeForAll(unit)) then
		pvp:SetTexture[[Interface\TargetingFrame\UI-PVP-FFA]]
		status = 'ffa'
	-- XXX - WoW5: UnitFactionGroup() can return Neutral as well.
	elseif(factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		pvp:SetTexture([[Interface\TargetingFrame\UI-PVP-]]..factionGroup)
		status = factionGroup
	end

	if(status) then
		pvp:Show()
	else
		pvp:Hide()
	end

	if(pvp.PostUpdate) then
		return pvp:PostUpdate(status)
	end
end

local Path = function(self, ...)
	return (self.PvP.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local pvp = self.PvP
	if(pvp) then
		pvp.__owner = self
		pvp.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_FACTION", Path)

		return true
	end
end

local Disable = function(self)
	local pvp = self.PvP
	if(pvp) then
		pvp:Hide()
		self:UnregisterEvent("UNIT_FACTION", Path)
	end
end

oUF:AddElement('PvP', Path, Enable, Disable)
