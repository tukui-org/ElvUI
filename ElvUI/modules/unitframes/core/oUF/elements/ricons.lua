local parent, ns = ...
local oUF = ns.oUF

local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

local Update = function(self, event)
	local index = GetRaidTargetIndex(self.unit)
	local icon = self.RaidIcon

	if(index) then
		SetRaidTargetIconTexture(icon, index)
		icon:Show()
	else
		icon:Hide()
	end
end

local Path = function(self, ...)
	return (self.RaidIcon.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	if(not element.__owner.unit) then return end
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local ricon = self.RaidIcon
	if(ricon) then
		ricon.__owner = self
		ricon.ForceUpdate = ForceUpdate

		self:RegisterEvent("RAID_TARGET_UPDATE", Path)

		if(ricon:IsObjectType"Texture" and not ricon:GetTexture()) then
			ricon:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]
		end

		return true
	end
end

local Disable = function(self)
	local ricon = self.RaidIcon
	if(ricon) then
		self:UnregisterEvent("RAID_TARGET_UPDATE", Path)
	end
end

oUF:AddElement('RaidIcon', Path, Enable, Disable)
