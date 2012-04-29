--[[ Element: Resurrect Icon

 Handles updating and toggles visibility of incoming resurrect icon.

 Widget

 ResurrectIcon - A Texture used to display if the unit has an incoming
 resurrect.

 Notes

 The default resurrect icon will be used if the UI widget is a texture and
 doesn't have a texture or color defined.

 Examples

   -- Position and size
   local ResurrectIcon = self:CreateTexture(nil, 'OVERLAY')
   ResurrectIcon:SetSize(16, 16)
   ResurrectIcon:SetPoint('TOPRIGHT', self)
   
   -- Register it with oUF
   self.ResurrectIcon = ResurrectIcon

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
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
