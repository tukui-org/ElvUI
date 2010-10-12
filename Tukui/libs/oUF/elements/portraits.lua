local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(not unit or not UnitIsUnit(self.unit, unit)) then return end

	local portrait = self.Portrait
	if(portrait.PreUpdate) then portrait:PreUpdate(unit) end

	if(portrait:IsObjectType'Model') then
		local guid = UnitGUID(unit)
		if(not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit)) then
			portrait:SetModelScale(4.25)
			portrait:SetPosition(0, 0, -1.5)
			portrait:SetModel"Interface\\Buttons\\talktomequestionmark.mdx"
		elseif(portrait.guid ~= guid or event == 'UNIT_MODEL_CHANGED') then
			portrait:SetUnit(unit)
			portrait:SetCamera(0)

			portrait.guid = guid
		else
			portrait:SetCamera(0)
		end
	else
		SetPortraitTexture(portrait, unit)
	end

	if(portrait.PostUpdate) then
		return portrait:PostUpdate(unit)
	end
end

local Path = function(self, ...)
	return (self.Portrait.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local portrait = self.Portrait
	if(portrait) then
		portrait.__owner = self
		portrait.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:RegisterEvent("UNIT_MODEL_CHANGED", Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)

		-- The quest log uses PARTY_MEMBER_{ENABLE,DISABLE} to handle updating of
		-- party members overlapping quests. This will probably be enough to handle
		-- model updating.
		--
		-- DISABLE isn't used as it fires when we most likely don't have the
		-- information we want.
		if(unit == 'party') then
			self:RegisterEvent('PARTY_MEMBER_ENABLE', Path)
		end

		return true
	end
end

local Disable = function(self)
	local portrait = self.Portrait
	if(portrait) then
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:UnregisterEvent("UNIT_MODEL_CHANGED", Path)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('Portrait', Path, Enable, Disable)
