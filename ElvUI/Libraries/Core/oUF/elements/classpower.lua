--[[
# Element: ClassPower

Handles the visibility and updating of the player's class resources (like Chi Orbs or Holy Power) and combo points.

## Widget

ClassPower - An `table` consisting of as many StatusBars as the theoretical maximum return of [UnitPowerMax](http://wowprogramming.com/docs/api/UnitPowerMax.html).

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Sub-Widget Options

.multiplier - Used to tint the background based on the widget's R, G and B values. Defaults to 1 (number)[0-1]

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don't have a texture set.
If the sub-widgets are StatusBars, their minimum and maximum values will be set to 0 and 1 respectively.

Supported class powers:
  - All     - Combo Points
  - Mage    - Arcane Charges
  - Monk    - Chi Orbs
  - Paladin - Holy Power
  - Warlock - Soul Shards

## Examples

    local ClassPower = {}
    for index = 1, 10 do
        local Bar = CreateFrame('StatusBar', nil, self)

        -- Position and size.
        Bar:SetSize(16, 16)
        Bar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', (index - 1) * Bar:GetWidth(), 0)

        ClassPower[index] = Bar
    end

    -- Register with oUF
    self.ClassPower = ClassPower
--]]

local _, ns = ...
local oUF = ns.oUF

local _, PlayerClass = UnitClass('player')

-- sourced from FrameXML/Constants.lua
local SPEC_MAGE_ARCANE = _G.SPEC_MAGE_ARCANE or 1
local SPEC_MONK_WINDWALKER = _G.SPEC_MONK_WINDWALKER or 3
local SPEC_WARLOCK_DESTRUCTION = _G.SPEC_WARLOCK_DESTRUCTION or 3
local SPELL_POWER_ENERGY = Enum.PowerType.Energy or 3
local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints or 4
local SPELL_POWER_SOUL_SHARDS = Enum.PowerType.SoulShards or 7
local SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower or 9
local SPELL_POWER_CHI = Enum.PowerType.Chi or 12
local SPELL_POWER_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges or 16

-- Holds the class specific stuff.
local ClassPowerID, ClassPowerType
local ClassPowerEnable, ClassPowerDisable
local RequireSpec, RequirePower, RequireSpell

local function UpdateColor(element, powerType)
	local color = element.__owner.colors.power[powerType]
	local r, g, b = color[1], color[2], color[3]
	for i = 1, #element do
		local bar = element[i]
		bar:SetStatusBarColor(r, g, b)

		local bg = bar.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	--[[ Callback: ClassPower:PostUpdateColor(r, g, b)
	Called after the element color has been updated.

	* self - the ClassPower element
	* r    - the red component of the used color (number)[0-1]
	* g    - the green component of the used color (number)[0-1]
	* b    - the blue component of the used color (number)[0-1]
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(r, g, b)
	end
end

local function Update(self, event, unit, powerType)
	if(not (unit and (UnitIsUnit(unit, 'player') and (not powerType or powerType == ClassPowerType)
		or unit == 'vehicle' and powerType == 'COMBO_POINTS'))) then
		return
	end

	local element = self.ClassPower

	--[[ Callback: ClassPower:PreUpdate(event)
	Called before the element has been updated.

	* self  - the ClassPower element
	]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cur, max, mod, oldMax, chargedPoints
	if(event ~= 'ClassPowerDisable') then
		local powerID = unit == 'vehicle' and SPELL_POWER_COMBO_POINTS or ClassPowerID
		cur = not oUF.isRetail and powerType == 'COMBO_POINTS' and GetComboPoints('player', 'target') or UnitPower(unit, powerID, true)
		max = UnitPowerMax(unit, powerID)
		mod = UnitPowerDisplayMod(powerID)

		-- mod should never be 0, but according to Blizz code it can actually happen
		cur = mod == 0 and 0 or cur / mod

		-- BUG: Destruction is supposed to show partial soulshards, but Affliction and Demonology should only show full ones
		if oUF.isRetail and (ClassPowerType == 'SOUL_SHARDS' and GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION) then
			cur = cur - cur % 1
		end

		if oUF.isRetail and (PlayerClass == 'ROGUE') then
			chargedPoints = GetUnitChargedPowerPoints(unit)

			-- UNIT_POWER_POINT_CHARGE doesn't provide a power type
			powerType = powerType or ClassPowerType
		end

		local numActive = cur + 0.9
		for i = 1, max do
			if(i > numActive) then
				element[i]:Hide()
				element[i]:SetValue(0)
			else
				element[i]:Show()
				element[i]:SetValue(cur - i + 1)
			end
		end

		oldMax = element.__max
		if(max ~= oldMax) then
			if(max < oldMax) then
				for i = max + 1, oldMax do
					element[i]:Hide()
					element[i]:SetValue(0)
				end
			end

			element.__max = max
		end
	end
	--[[ Callback: ClassPower:PostUpdate(cur, max, hasMaxChanged, powerType)
	Called after the element has been updated.

	* self          - the ClassPower element
	* cur           - the current amount of power (number)
	* max           - the maximum amount of power (number)
	* hasMaxChanged - indicates whether the maximum amount has changed since the last update (boolean)
	* powerType     - the active power type (string)
	* chargedTable  - current chargedPoints table
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(cur, max, oldMax ~= max, powerType, chargedPoints)  -- ElvUI uses chargedPoints as table
	end
end

local function Path(self, ...)
	--[[ Override: ClassPower.Override(self, event, unit, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.ClassPower.Override or Update) (self, ...)
end

local function Visibility(self, event, unit)
	local element = self.ClassPower
	local shouldEnable

	if oUF.isRetail and UnitHasVehicleUI('player') then
		shouldEnable = PlayerVehicleHasComboPoints()
		unit = 'vehicle'
	elseif(ClassPowerID) then
		if(not RequireSpec or oUF.isRetail and (RequireSpec == GetSpecialization())) then
			-- use 'player' instead of unit because 'SPELLS_CHANGED' is a unitless event
			if(not RequirePower or RequirePower == UnitPowerType('player')) then
				if(not RequireSpell or IsPlayerSpell(RequireSpell)) then
					self:UnregisterEvent('SPELLS_CHANGED', Visibility)
					shouldEnable = true
					unit = 'player'
				else
					self:RegisterEvent('SPELLS_CHANGED', Visibility, true)
				end
			end
		end
	end

	local isEnabled = element.__isEnabled
	local powerType = unit == 'vehicle' and 'COMBO_POINTS' or ClassPowerType

	if(shouldEnable) then
		--[[ Override: ClassPower:UpdateColor(powerType)
		Used to completely override the internal function for updating the widgets' colors.

		* self      - the ClassPower element
		* powerType - the active power type (string)
		--]]
		(element.UpdateColor or UpdateColor) (element, powerType)
	end

	if(shouldEnable and not isEnabled) then
		ClassPowerEnable(self)

		--[[ Callback: ClassPower:PostVisibility(isVisible)
		Called after the element's visibility has been changed.

		* self      - the ClassPower element
		* isVisible - the current visibility state of the element (boolean)
		--]]
		if(element.PostVisibility) then
			element:PostVisibility(true)
		end
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		ClassPowerDisable(self)

		if(element.PostVisibility) then
			element:PostVisibility(false)
		end
	elseif(shouldEnable and isEnabled) then
		Path(self, event, unit, powerType)
	end
end

local function VisibilityPath(self, ...)
	--[[ Override: ClassPower.OverrideVisibility(self, event, unit)
	Used to completely override the internal visibility function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* unit  - the unit accompanying the event (string)
	--]]
	return (self.ClassPower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

do
	function ClassPowerEnable(self)
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)

		if not oUF.isRetail then
			self:RegisterEvent('PLAYER_TARGET_CHANGED', VisibilityPath, true)
		end

		if oUF.isRetail and (PlayerClass == 'ROGUE') then
			self:RegisterEvent('UNIT_POWER_POINT_CHARGE', Path)
		end

		self.ClassPower.__isEnabled = true

		if (oUF.isRetail or oUF.isWrath) and UnitHasVehicleUI('player') then
			Path(self, 'ClassPowerEnable', 'vehicle', 'COMBO_POINTS')
		else
			Path(self, 'ClassPowerEnable', 'player', ClassPowerType)
		end
	end

	function ClassPowerDisable(self)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)

		if oUF.isRetail then
			self:UnregisterEvent('UNIT_POWER_POINT_CHARGE', Path)
		else
			self:UnregisterEvent('PLAYER_TARGET_CHANGED', VisibilityPath)
		end

		local element = self.ClassPower
		for i = 1, #element do
			element[i]:Hide()
		end

		element.__isEnabled = false
		Path(self, 'ClassPowerDisable', 'player', ClassPowerType)
	end

	if(PlayerClass == 'MONK') then
		ClassPowerID = SPELL_POWER_CHI
		ClassPowerType = 'CHI'
		RequireSpec = SPEC_MONK_WINDWALKER
	elseif(PlayerClass == 'PALADIN') then
		ClassPowerID = SPELL_POWER_HOLY_POWER
		ClassPowerType = 'HOLY_POWER'
	elseif(PlayerClass == 'WARLOCK') then
		ClassPowerID = SPELL_POWER_SOUL_SHARDS
		ClassPowerType = 'SOUL_SHARDS'
	elseif(PlayerClass == 'ROGUE' or PlayerClass == 'DRUID') then
		ClassPowerID = SPELL_POWER_COMBO_POINTS
		ClassPowerType = 'COMBO_POINTS'

		if(PlayerClass == 'DRUID') then
			RequirePower = SPELL_POWER_ENERGY
			RequireSpell = oUF.isRetail and 5221 or 768
		end
	elseif(PlayerClass == 'MAGE') then
		ClassPowerID = SPELL_POWER_ARCANE_CHARGES
		ClassPowerType = 'ARCANE_CHARGES'
		RequireSpec = SPEC_MAGE_ARCANE
	end
end

local function Enable(self, unit)
	local element = self.ClassPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		if(oUF.isRetail or oUF.isWrath) and (RequireSpec or RequireSpell) then
			self:RegisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath, true)
		end

		if(RequirePower) then
			self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		end

		element.ClassPowerEnable = ClassPowerEnable
		element.ClassPowerDisable = ClassPowerDisable

		for i = 1, #element do
			local bar = element[i]
			if(bar:IsObjectType('StatusBar')) then
				if(not (bar:GetStatusBarTexture() or bar:GetStatusBarAtlas())) then
					bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
				end

				bar:SetMinMaxValues(0, 1)
			end
		end

		return true
	end
end

local function Disable(self)
	if(self.ClassPower) then
		ClassPowerDisable(self)

		if oUF.isRetail or oUF.isWrath then
			self:UnregisterEvent('PLAYER_TALENT_UPDATE', VisibilityPath)
		end

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:UnregisterEvent('SPELLS_CHANGED', Visibility)
	end
end

oUF:AddElement('ClassPower', VisibilityPath, Enable, Disable)
