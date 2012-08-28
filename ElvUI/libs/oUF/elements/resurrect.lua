local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	if not self.unit then return; end
	local resurrect = self.ResurrectIcon
	if(resurrect.PreUpdate) then
		resurrect:PreUpdate()
	end

	local incomingResurrect = UnitHasIncomingResurrection(self.unit)
	if(incomingResurrect) then
		resurrect:Show()
	else
		resurrect:Hide()
	end

	if(resurrect.PostUpdate) then
		return resurrect:PostUpdate(incomingResurrect)
	end
end

local Path = function(self, ...)
	return (self.ResurrectIcon.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local resurrect = self.ResurrectIcon
	if(resurrect) then
		resurrect.__owner = self
		resurrect.ForceUpdate = ForceUpdate

		self:RegisterEvent('INCOMING_RESURRECT_CHANGED', Path, true)

		if(resurrect:IsObjectType('Texture') and not resurrect:GetTexture()) then
			resurrect:SetTexture[[Interface\RaidFrame\Raid-Icon-Rez]]
		end

		return true
	end
end

local Disable = function(self)
	local resurrect = self.ResurrectIcon
	if(resurrect) then
		self:UnregisterEvent('INCOMING_RESURRECT_CHANGED', Path)
	end
end

oUF:AddElement('ResurrectIcon', Path, Enable, Disable)
