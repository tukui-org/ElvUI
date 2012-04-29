--[[ Element: Power Bar

 Handles updating of `self.Power` based upon the units power.

 Widget

 Power - A StatusBar used to represent mana.

 Sub-Widgets

 .bg - A Texture which functions as a background. It will inherit the color of
       the main StatusBar.

 Notes

 The default StatusBar texture will be applied if the UI widget doesn't have a
 status bar texture or color defined.

 Options

 The following options are listed by priority. The first check that returns
 true decides the color of the bar.

 .colorTapping      - Use `self.colors.tapping` to color the bar if the unit
                      isn't tapped by the player.
 .colorDisconnected - Use `self.colors.disconnected` to color the bar if the
                      unit is offline.
 .colorPower        - Use `self.colors.power[token]` to color the bar based on
                      the unit's power type. This method will fall-back to
                      `:GetAlternativeColor()` if it can't find a color matching
                      the token. If this function isn't defined, then it will
                      attempt to color based upon the alternative power colors
                      returned by [UnitPowerType](http://wowprogramming.com/docs/api/UnitPowerType).
                      Finally, if these aren't defined, then it will attempt to
                      color the bar based upon `self.colors.power[type]`.
 .colorClass        - Use `self.colors.class[class]` to color the bar based on
                      unit class. `class` is defined by the second return of
                      [UnitClass](http://wowprogramming.com/docs/api/UnitClass).
 .colorClassNPC     - Use `self.colors.class[class]` to color the bar if the
                      unit is a NPC.
 .colorClassPet     - Use `self.colors.class[class]` to color the bar if the
                      unit is player controlled, but not a player.
 .colorReaction     - Use `self.colors.reaction[reaction]` to color the bar
                      based on the player's reaction towards the unit.
                      `reaction` is defined by the return value of
                      [UnitReaction](http://wowprogramming.com/docs/api/UnitReaction).
 .colorSmooth       - Use `self.colors.smooth` to color the bar with a smooth
                      gradient based on the player's current health percentage.

 Sub-Widget Options

 .multiplier - Defines a multiplier, which is used to tint the background based
               on the main widgets R, G and B values. Defaults to 1 if not
               present.

 Examples

   -- Position and size
   local Power = CreateFrame("StatusBar", nil, self)
   Power:SetHeight(20)
   Power:SetPoint('BOTTOM')
   Power:SetPoint('LEFT')
   Power:SetPoint('RIGHT')
   
   -- Add a background
   local Background = Power:CreateTexture(nil, 'BACKGROUND')
   Background:SetAllPoints(Power)
   Background:SetTexture(1, 1, 1, .5)
   
   -- Options
   Power.frequentUpdates = true
   Power.colorTapping = true
   Power.colorDisconnected = true
   Power.colorPower = true
   Power.colorClass = true
   Power.colorReaction = true
   
   -- Make the background darker.
   Background.multiplier = .5
   
   -- Register it with oUF
   self.Power = Power
   self.Power.bg = Background

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

oUF.colors.power = {}
for power, color in next, PowerBarColor do
	if (type(power) == "string") then
		oUF.colors.power[power] = {color.r, color.g, color.b}
	end
end

oUF.colors.power[0] = oUF.colors.power["MANA"]
oUF.colors.power[1] = oUF.colors.power["RAGE"]
oUF.colors.power[2] = oUF.colors.power["FOCUS"]
oUF.colors.power[3] = oUF.colors.power["ENERGY"]
oUF.colors.power[4] = oUF.colors.power["UNUSED"]
oUF.colors.power[5] = oUF.colors.power["RUNES"]
oUF.colors.power[6] = oUF.colors.power["RUNIC_POWER"]
oUF.colors.power[7] = oUF.colors.power["SOUL_SHARDS"]
oUF.colors.power[8] = oUF.colors.power["ECLIPSE"]
oUF.colors.power[9] = oUF.colors.power["HOLY_POWER"]

local GetDisplayPower = function(power, unit)
	local _, _, _, _, _, _, showOnRaid = UnitAlternatePowerInfo(unit)
	if(power.displayAltPower and showOnRaid) then
		return ALTERNATE_POWER_INDEX
	else
		return (UnitPowerType(unit))
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local power = self.Power

	if(power.PreUpdate) then power:PreUpdate(unit) end

	local displayType = GetDisplayPower(power, unit)
	local min, max = UnitPower(unit, displayType), UnitPowerMax(unit, displayType)
	local disconnected = not UnitIsConnected(unit)
	power:SetMinMaxValues(0, max)

	if(disconnected) then
		power:SetValue(max)
	else
		power:SetValue(min)
	end

	power.disconnected = disconnected

	local r, g, b, t
	if(power.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		t = self.colors.tapped
	elseif(power.colorDisconnected and not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	elseif(power.colorPower) then
		local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)

		t = self.colors.power[ptoken]
		if(not t) then
			if(power.GetAlternativeColor) then
				r, g, b = power:GetAlternativeColor(unit, ptype, ptoken, altR, altG, altB)
			elseif(altR) then
				r, g, b = altR, altG, altB
			else
				t = self.colors.power[ptype]
			end
		end
	elseif(power.colorClass and UnitIsPlayer(unit)) or
		(power.colorClassNPC and not UnitIsPlayer(unit)) or
		(power.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(power.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(power.colorSmooth) then
		r, g, b = self.ColorGradient(min, max, unpack(power.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		power:SetStatusBarColor(r, g, b)

		local bg = power.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(power.PostUpdate) then
		return power:PostUpdate(unit, min, max)
	end
end

local Path = function(self, ...)
	return (self.Power.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		power.__owner = self
		power.ForceUpdate = ForceUpdate

		if(power.frequentUpdates and (unit == 'player' or unit == 'pet')) then
			self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		else
			self:RegisterEvent('UNIT_POWER', Path)
		end

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Path)

		if(power:IsObjectType'StatusBar' and not power:GetStatusBarTexture()) then
			power:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local power = self.Power
	if(power) then
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Power', Path, Enable, Disable)
