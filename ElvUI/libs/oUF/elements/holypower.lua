--[[ Element: Holy Power Indicator

 Toggles the visibility of the player's holy power indicator.

 Widget

 HolyPower - An array consisting of three UI widgets.

 Examples

   local HolyPower = {}
   for index = 1, MAX_HOLY_POWER do
      local Texture = self:CreateTexture(nil, 'BACKGROUND')
   
      -- Position and size
      Texture:SetSize(16, 16)
      Texture:SetTexture(1, 1, 0)
      Texture:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Texture:GetWidth(), 0)
   
      HolyPower[index] = Texture
   end
   
   -- Register with oUF
   self.HolyPower = HolyPower

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

if(select(2, UnitClass('player')) ~= 'PALADIN') then return end

local parent, ns = ...
local oUF = ns.oUF

local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER
local MAX_HOLY_POWER = MAX_HOLY_POWER

local Update = function(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end

	local hp = self.HolyPower
	if(hp.PreUpdate) then hp:PreUpdate() end

	local num = UnitPower('player', SPELL_POWER_HOLY_POWER)
	for i = 1, MAX_HOLY_POWER do
		if(i <= num) then
			hp[i]:Show()
		else
			hp[i]:Hide()
		end
	end

	if(hp.PostUpdate) then
		return hp:PostUpdate(num)
	end
end

local Path = function(self, ...)
	return (self.HolyPower.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'HOLY_POWER')
end

local function Enable(self)
	local hp = self.HolyPower
	if(hp) then
		hp.__owner = self
		hp.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER', Path)

		return true
	end
end

local function Disable(self)
	local hp = self.HolyPower
	if(hp) then
		self:UnregisterEvent('UNIT_POWER', Path)
	end
end

oUF:AddElement('HolyPower', Path, Enable, Disable)
