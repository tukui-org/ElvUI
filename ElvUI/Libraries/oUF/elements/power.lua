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

 .displayAltPower   - Use this to let the widget display alternate power if the
                      unit has one. If no alternate power the display will fall
                      back to primary power.
 .useAtlas          - Use this to let the widget use an atlas for its texture if
                      `.atlas` is defined on the widget or an atlas is present in
                      `self.colors.power` for the appropriate power type.
 .atlas             - A custom atlas

 The following options are listed by priority. The first check that returns
 true decides the color of the bar.

 .colorTapping      - Use `self.colors.tapping` to color the bar if the unit
                      isn't tapped by the player.
 .colorDisconnected - Use `self.colors.disconnected` to color the bar if the
                      unit is offline.
 .altPowerColor     - A table containing the RGB values to use for a fixed
                      color if the alt power bar is being displayed instead
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

local updateFrequentUpdates
oUF.colors.power = {}
for power, color in next, PowerBarColor do
	if (type(power) == "string") then
		if(type(select(2, next(color))) == 'table') then
			oUF.colors.power[power] = {}

			for index, color in next, color do
				oUF.colors.power[power][index] = {color.r, color.g, color.b}
			end
		else
			oUF.colors.power[power] = {color.r, color.g, color.b, atlas = color.atlas}
		end
	end
end

-- sourced from FrameXML/Constants.lua
oUF.colors.power[0] = oUF.colors.power.MANA
oUF.colors.power[1] = oUF.colors.power.RAGE
oUF.colors.power[2] = oUF.colors.power.FOCUS
oUF.colors.power[3] = oUF.colors.power.ENERGY
oUF.colors.power[4] = oUF.colors.power.COMBO_POINTS
oUF.colors.power[5] = oUF.colors.power.RUNES
oUF.colors.power[6] = oUF.colors.power.RUNIC_POWER
oUF.colors.power[7] = oUF.colors.power.SOUL_SHARDS
oUF.colors.power[8] = oUF.colors.power.LUNAR_POWER
oUF.colors.power[9] = oUF.colors.power.HOLY_POWER
oUF.colors.power[11] = oUF.colors.power.MAELSTROM
oUF.colors.power[12] = oUF.colors.power.CHI
oUF.colors.power[13] = oUF.colors.power.INSANITY
oUF.colors.power[16] = oUF.colors.power.ARCANE_CHARGES
oUF.colors.power[17] = oUF.colors.power.FURY
oUF.colors.power[18] = oUF.colors.power.PAIN

local GetDisplayPower = function(unit)
	if not unit then return; end
	local _, min, _, _, _, _, showOnRaid = UnitAlternatePowerInfo(unit)
	if(showOnRaid) then
		return ALTERNATE_POWER_INDEX, min
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end
	local power = self.Power

	if(power.PreUpdate) then power:PreUpdate(unit) end

	local displayType, min
	if power.displayAltPower then
		displayType, min = GetDisplayPower(unit)
	end
	local cur, max = UnitPower(unit, displayType), UnitPowerMax(unit, displayType)
	local disconnected = not UnitIsConnected(unit)
	local tapped = not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)

	if max == 0 then
		max = 1
	end

	power:SetMinMaxValues(min or 0, max)

	if(disconnected) then
		power:SetValue(max)
	else
		power:SetValue(cur)
	end

	power.disconnected = disconnected
	power.tapped = tapped

	if power.frequentUpdates ~= power.__frequentUpdates then
		power.__frequentUpdates = power.frequentUpdates
		updateFrequentUpdates(self)
	end

	local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)
	local r, g, b, t

	if(power.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = self.colors.tapped
	elseif(power.colorDisconnected and disconnected) then
		t = self.colors.disconnected
	elseif(displayType == ALTERNATE_POWER_INDEX and power.altPowerColor) then
		t = power.altPowerColor
	elseif(power.colorPower) then
		t = self.colors.power[ptoken]
		if(not t) then
			if(power.GetAlternativeColor) then
				r, g, b = power:GetAlternativeColor(unit, ptype, ptoken, altR, altG, altB)
			elseif(altR) then
				-- As of 7.0.3, altR, altG, altB may be in 0-1 or 0-255 range.
				if(altR > 1) or (altG > 1) or (altB > 1) then
					r, g, b = altR / 255, altG / 255, altB / 255
				else
					r, g, b = altR, altG, altB
				end
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
		local adjust = 0 - (min or 0)
		r, g, b = self.ColorGradient(cur + adjust, max + adjust, unpack(power.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	t = self.colors.power[ptoken or ptype]
	local atlas = power.atlas or (t and t.atlas)
	if(power.useAtlas and atlas and displayType ~= ALTERNATE_POWER_INDEX) then
		power:SetStatusBarAtlas(atlas)
		power:SetStatusBarColor(1, 1, 1)
		if(power.colorTapping or power.colorDisconnected) then
			t = disconnected and self.colors.disconnected or self.colors.tapped
			power:GetStatusBarTexture():SetDesaturated(disconnected or tapped)
		end
		if(t and b) then
			r, g, b = t[1], t[2], t[3]
		end
	else
		power:SetStatusBarTexture(power.texture)
		if(b) then
			power:SetStatusBarColor(r, g, b)
		end
	end

	local bg = power.bg
	if(bg and b) then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if(power.PostUpdate) then
		return power:PostUpdate(unit, cur, max, min, ptoken, ptype)
	end
end

local Path = function(self, ...)
	return (self.Power.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

function updateFrequentUpdates(self)
	local power = self.Power
	if power.frequentUpdates and not self:IsEventRegistered('UNIT_POWER_FREQUENT') then
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)

		if self:IsEventRegistered('UNIT_POWER') then
			self:UnregisterEvent('UNIT_POWER', Path)
		end
	elseif not self:IsEventRegistered('UNIT_POWER') then
		self:RegisterEvent('UNIT_POWER', Path)

		if self:IsEventRegistered('UNIT_POWER_FREQUENT') then
			self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		end		
	end
end

local Enable = function(self, unit)
	local power = self.Power
	if(power) then
		power.__owner = self
		power.ForceUpdate = ForceUpdate

		power.__frequentUpdates = power.frequentUpdates
		updateFrequentUpdates(self)

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', Path)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Path)

		if(power:IsObjectType'StatusBar') then
			power.texture = power:GetStatusBarTexture() and power:GetStatusBarTexture():GetTexture() or [[Interface\TargetingFrame\UI-StatusBar]]
			power:SetStatusBarTexture(power.texture)
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
