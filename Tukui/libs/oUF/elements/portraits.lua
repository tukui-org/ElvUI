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

local Enable = function(self, unit)
	local portrait = self.Portrait
	if(portrait) then
		local Update = portrait.Update or Update
		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:RegisterEvent("UNIT_MODEL_CHANGED", Update)

		-- The quest log uses PARTY_MEMBER_{ENABLE,DISABLE} to handle updating of
		-- party members overlapping quests. This will probably be enough to handle
		-- model updating.
		--
		-- DISABLE isn't used as it fires when we most likely don't have the
		-- information we want.
		if(unit == 'party') then
			self:RegisterEvent('PARTY_MEMBER_ENABLE', Update)
		end

		return true
	end
end

local Disable = function(self)
	local portrait = self.Portrait
	if(portrait) then
		local Update = portrait.Update or Update
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:UnregisterEvent("UNIT_MODEL_CHANGED", Update)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Update)
	end
end

oUF:AddElement('Portrait', Update, Enable, Disable)
