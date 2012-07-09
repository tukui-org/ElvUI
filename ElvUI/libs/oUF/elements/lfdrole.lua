local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local lfdrole = self.LFDRole
	if(lfdrole.PreUpdate) then
		lfdrole:PreUpdate()
	end

	local role = UnitGroupRolesAssigned(self.unit)
	if(role == 'TANK' or role == 'HEALER' or role == 'DAMAGER') then
		lfdrole:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
		lfdrole:Show()
	else
		lfdrole:Hide()
	end

	if(lfdrole.PostUpdate) then
		return lfdrole:PostUpdate(role)
	end
end

local Path = function(self, ...)
	return (self.LFDRole.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local lfdrole = self.LFDRole
	if(lfdrole) then
		lfdrole.__owner = self
		lfdrole.ForceUpdate = ForceUpdate

		if(self.unit == "player") then
			self:RegisterEvent("PLAYER_ROLES_ASSIGNED", Path, true)
		else
			self:RegisterEvent("GROUP_ROSTER_UPDATE", Path, true)
		end

		if(lfdrole:IsObjectType"Texture" and not lfdrole:GetTexture()) then
			lfdrole:SetTexture[[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]]
		end

		return true
	end
end

local Disable = function(self)
	local lfdrole = self.LFDRole
	if(lfdrole) then
		self:UnregisterEvent("PLAYER_ROLES_ASSIGNED", Path)
		self:UnregisterEvent("GROUP_ROSTER_UPDATE", Path)
	end
end

oUF:AddElement('LFDRole', Path, Enable, Disable)
