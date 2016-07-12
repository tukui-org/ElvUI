--[[ Element: Portraits

 Handles updating of the unit's portrait.

 Widget

 Portrait - A PlayerModel or Texture used to represent the unit's portrait.

 Notes

 The quest delivery question mark will be used instead of the unit's model when
 the client doesn't have the model information for the unit.

 Examples

   -- 3D Portrait
   -- Position and size
   local Portrait = CreateFrame('PlayerModel', nil, self)
   Portrait:SetSize(32, 32)
   Portrait:SetPoint('RIGHT', self, 'LEFT')
   
   -- Register it with oUF
   self.Portrait = Portrait

   -- 2D Portrait
   local Portrait = self:CreateTexture(nil, 'OVERLAY')
   Portrait:SetSize(32, 32)
   Portrait:SetPoint('RIGHT', self, 'LEFT')
   
   -- Register it with oUF
   self.Portrait = Portrait

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit)
	if(not unit or not UnitIsUnit(self.unit, unit)) then return end

	local portrait = self.Portrait
	if(portrait.PreUpdate) then portrait:PreUpdate(unit) end

	if(portrait:IsObjectType'Model') then
		local guid = UnitGUID(unit)
		if(not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit)) then
			portrait:SetCamDistanceScale(0.25)
			portrait:SetPortraitZoom(0)
			portrait:SetPosition(0,0,0.5)
			portrait:ClearModel()
			portrait:SetModel('interface\\buttons\\talktomequestionmark.m2')
			portrait.guid = nil
		elseif(portrait.guid ~= guid or event == 'UNIT_MODEL_CHANGED') then
			portrait:SetCamDistanceScale(1)
			portrait:SetPortraitZoom(1)
			portrait:SetPosition(0,0,0)
			portrait:ClearModel()
			portrait:SetUnit(unit)
			portrait.guid = guid
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
		portrait:Show()
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
		portrait:Hide()
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:UnregisterEvent("UNIT_MODEL_CHANGED", Path)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('Portrait', Path, Enable, Disable)
