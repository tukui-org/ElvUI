--[[ Element: Combat Icon
 Toggles the visibility of `self.Combat` based on the player's combat status.

 Widget

 Combat - Any UI widget.

 Notes

 The default assistant icon will be applied if the UI widget is a texture and
 doesn't have a texture or color defined.

 Examples

   -- Position and size
   local Combat = self:CreateTexture(nil, "OVERLAY")
   Combat:SetSize(16, 16)
   Combat:SetPoint('TOP', self)
   
   -- Register it with oUF
   self.Combat = Combat

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.

]]

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local combat = self.Combat
	if(combat.PreUpdate) then
		combat:PreUpdate()
	end

	local inCombat = UnitAffectingCombat('player')
	if(inCombat) then
		combat:Show()
	else
		combat:Hide()
	end

	if(combat.PostUpdate) then
		return combat:PostUpdate(inCombat)
	end
end

local Path = function(self, ...)
	return (self.Combat.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local combat = self.Combat
	if(combat and unit == 'player') then
		combat.__owner = self
		combat.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_REGEN_DISABLED", Path, true)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Path, true)

		if(combat:IsObjectType"Texture" and not combat:GetTexture()) then
			combat:SetTexture[[Interface\CharacterFrame\UI-StateIcon]]
			combat:SetTexCoord(.5, 1, 0, .49)
		end

		return true
	end
end

local Disable = function(self)
	if(self.Combat) then
		self.Combat:Hide()
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Path)
	end
end

oUF:AddElement('Combat', Path, Enable, Disable)
