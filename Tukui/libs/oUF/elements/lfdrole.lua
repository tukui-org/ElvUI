local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local lfdrole = self.LFDRole
	local isTank, isHealer, isDamage = UnitGroupRolesAssigned(self.unit)

	if(isTank) then
		lfdrole:SetTexCoord(0, 19/64, 22/64, 41/64)
		lfdrole:Show()
	elseif(isHealer) then
		lfdrole:SetTexCoord(20/64, 39/64, 1/64, 20/64)
		lfdrole:Show()
	elseif(isDamage) then
		lfdrole:SetTexCoord(20/64, 39/64, 22/64, 41/64)
		lfdrole:Show()
	else
		lfdrole:Hide()
	end
end

local Enable = function(self)
	local lfdrole = self.LFDRole
	if(lfdrole) then
		local Update = lfdrole.Update or Update
		if(self.unit == "player") then
			self:RegisterEvent("PLAYER_ROLES_ASSIGNED", Update)
		else
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", Update)
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
		local Update = lfdrole.Update or Update
		self:UnregisterEvent("PLAYER_ROLES_ASSIGNED", Update)
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Update)
	end
end

oUF:AddElement('LFDRole', Update, Enable, Disable)
