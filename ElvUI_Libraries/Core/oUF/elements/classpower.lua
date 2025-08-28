--[[
# Element: ClassPower

Handles the visibility and updating of the player's class resources (like Chi Orbs or Holy Power) and combo points.

## Widget

ClassPower - An `table` consisting of as many StatusBars as the theoretical maximum return of [UnitPowerMax](https://warcraft.wiki.gg/wiki/API_UnitPowerMax).

## Sub-Widgets

.bg - A `Texture` used as a background. It will inherit the color of the main StatusBar.

## Sub-Widget Options

.multiplier - Used to tint the background based on the widget's R, G and B values. Defaults to 1 (number)[0-1]

## Notes

A default texture will be applied if the sub-widgets are StatusBars and don't have a texture set.
If the sub-widgets are StatusBars, their minimum and maximum values will be set to 0 and 1 respectively.

Supported class powers:
  - All     - Combo Points
  - Evoker  - Essence
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

local floor = floor
local _, PlayerClass = UnitClass('player')

-- sourced from Blizzard_FrameXMLBase/Constants.lua
local SPEC_MAGE_ARCANE = _G.SPEC_MAGE_ARCANE or 1
local SPEC_MAGE_FROST = _G.SPEC_MAGE_FROST or 3
local SPEC_PRIEST_SHADOW = _G.SPEC_PRIEST_SHADOW or 3
local SPEC_MONK_WINDWALKER = _G.SPEC_MONK_WINDWALKER or 3
local SPEC_SHAMAN_ELEMENTAL = _G.SPEC_SHAMAN_ELEMENTAL or 1
local SPEC_SHAMAN_ENHANCEMENT = _G.SPEC_SHAMAN_ENHANCEMENT or 2
local SPEC_WARLOCK_DEMONOLOGY = _G.SPEC_WARLOCK_DEMONOLOGY or 2
local SPEC_WARLOCK_DESTRUCTION = _G.SPEC_WARLOCK_DESTRUCTION or 3

local POWERTYPE_MANA = Enum.PowerType.Mana or 0
local POWERTYPE_ENERGY = Enum.PowerType.Energy or 3
local POWERTYPE_COMBO_POINTS = Enum.PowerType.ComboPoints or 4
local POWERTYPE_SOUL_SHARDS = Enum.PowerType.SoulShards or 7
local POWERTYPE_HOLY_POWER = Enum.PowerType.HolyPower or 9
local POWERTYPE_CHI = Enum.PowerType.Chi or 12
local POWERTYPE_BURNING_EMBERS = Enum.PowerType.BurningEmbers or 14
local POWERTYPE_DEMONIC_FURY = Enum.PowerType.DemonicFury or 15
local POWERTYPE_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges or 16
local POWERTYPE_ESSENCE = Enum.PowerType.Essence or 19
local POWERTYPE_SHADOW_ORBS = Enum.PowerType.ShadowOrbs or 28

-- these are not real class powers
local POWERTYPE_ICICLES = -1
local POWERTYPE_MAELSTROM = -2

local SPELL_FROST_ICICLES = 205473
local SPELL_ARCANE_CHARGE = 36032
local SPELL_MAELSTROM = 344179
local SPELL_SOULBURN = 74434
local SPELL_CATFORM = 768
local SPELL_SHRED = 5221

local UnitPower = UnitPower
local UnitIsUnit = UnitIsUnit
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitPowerDisplayMod = UnitPowerDisplayMod
local PlayerVehicleHasComboPoints = PlayerVehicleHasComboPoints
local GetUnitChargedPowerPoints = GetUnitChargedPowerPoints
local GetComboPoints = GetComboPoints

local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local IsPlayerSpell = C_SpellBook.IsSpellKnown or IsPlayerSpell

local ClassPowerType = {
	[POWERTYPE_CHI] = 'CHI',
	[POWERTYPE_MANA] = 'MANA',
	[POWERTYPE_SHADOW_ORBS] = 'SHADOW_ORBS',
	[POWERTYPE_COMBO_POINTS] = 'COMBO_POINTS',
	[POWERTYPE_ARCANE_CHARGES] = 'ARCANE_CHARGES',
	[POWERTYPE_ICICLES] = 'FROST_ICICLES',
	[POWERTYPE_MAELSTROM] = 'MAELSTROM',
	[POWERTYPE_ESSENCE] = 'ESSENCE',
	[POWERTYPE_HOLY_POWER] = 'HOLY_POWER',
	[POWERTYPE_SOUL_SHARDS] = 'SOUL_SHARDS',
	[POWERTYPE_DEMONIC_FURY] = 'DEMONIC_FURY',
	[POWERTYPE_BURNING_EMBERS] = 'BURNING_EMBERS',
}

local ClassPowerMax = {
	[POWERTYPE_DEMONIC_FURY] = 1,
	[POWERTYPE_BURNING_EMBERS] = 4,
	[POWERTYPE_MAELSTROM] = 10,
	[POWERTYPE_ICICLES] = 5,
}

local UseFakePower = {
	[POWERTYPE_ARCANE_CHARGES] = oUF.isMists,
	[POWERTYPE_MAELSTROM] = oUF.isRetail,
	[POWERTYPE_ICICLES] = oUF.isRetail
}

local ClassPowerEnable, ClassPowerDisable
local RequirePower, RequireSpell
local CurrentSpec, ClassPowerID

local function UpdateColor(element, powerType)
	local color = element.__owner.colors.power[powerType]
	local r, g, b = color.r, color.g, color.b

	for i = 1, #element do
		local bar = element[i]
		if not bar then break end

		bar:SetStatusBarColor(r, g, b)

		local bg = bar.bg
		if bg then
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

local function CurrentApplications(spellID, filter)
	local info = GetPlayerAuraBySpellID(spellID)
	local checkFilter = info and (not filter or (filter == 'HELPFUL' and info.isHelpful) or (filter == 'HARMFUL' and info.isHarmful))
	return checkFilter and info.applications or 0
end

local function Update(self, event, unit, powerType)
	if not unit or not UnitIsUnit(unit, 'player') then return end

	local currentType = ClassPowerType[ClassPowerID]
	if event == 'UNIT_AURA' then powerType = currentType end
	if event ~= 'ClassPowerDisable' and event ~= 'ClassPowerEnable' and not powerType then return end

	local vehicle = unit == 'vehicle' and powerType == 'COMBO_POINTS'
	local classic = not oUF.isRetail and (powerType == 'COMBO_POINTS' or (PlayerClass == 'ROGUE' and powerType == 'ENERGY'))
	if not (vehicle or classic or powerType == currentType) then return end

	local element = self.ClassPower

	--[[ Callback: ClassPower:PreUpdate(event)
	Called before the element has been updated.

	* self  - the ClassPower element
	]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local current, maximum, previousMax, chargedPoints
	if event ~= 'ClassPowerDisable' then
		local powerID = (vehicle and POWERTYPE_COMBO_POINTS) or ClassPowerID
		local displayMod = (powerID > 0 and UnitPowerDisplayMod(powerID)) or 1
		local warlockDest = ClassPowerID == POWERTYPE_BURNING_EMBERS or nil
		local warlockDemo = ClassPowerID == POWERTYPE_DEMONIC_FURY or nil

		if displayMod == 0 then -- mod should never be 0, but according to Blizz code it can actually happen
			current = 0
		elseif oUF.isRetail and (PlayerClass == 'WARLOCK' and CurrentSpec == SPEC_WARLOCK_DESTRUCTION) then -- destro locks are special
			current = UnitPower(unit, powerID, true) / displayMod
		elseif oUF.isMists and ClassPowerID == POWERTYPE_ARCANE_CHARGES then
			current = CurrentApplications(SPELL_ARCANE_CHARGE, 'HARMFUL')
		elseif ClassPowerID == POWERTYPE_ICICLES then
			current = CurrentApplications(SPELL_FROST_ICICLES, 'HELPFUL')
		elseif ClassPowerID == POWERTYPE_MAELSTROM then
			current = CurrentApplications(SPELL_MAELSTROM, 'HELPFUL')
		else
			local cur = classic and GetComboPoints(unit, 'target') or UnitPower(unit, powerID, warlockDest)
			current = warlockDest and (cur * 0.1) or warlockDemo and (cur * 0.001) or cur
		end

		local powerMax = ClassPowerMax[ClassPowerID] or UnitPowerMax(unit, powerID, warlockDest)
		maximum = (ClassPowerID == POWERTYPE_MANA and 1) or powerMax or 0
		chargedPoints = oUF.isRetail and GetUnitChargedPowerPoints(unit)

		for i = 1, maximum do
			local bar = element[i]
			if not bar then break end

			bar:Show()

			if ClassPowerID == POWERTYPE_MANA then
				bar:SetValue((powerMax <= 0 and 0) or current / powerMax)
			elseif warlockDest and i == floor(current + 1) then
				bar:SetValue(current % 1)
			else
				bar:SetValue(current - i + 1)
			end
		end

		previousMax = element.__max

		if(maximum ~= previousMax) then
			if(maximum < previousMax) then
				for i = maximum + 1, previousMax do
					local bar = element[i]
					if not bar then break end

					bar:Hide()
					bar:SetValue(0)
				end
			end

			element.__max = maximum
		end
	end

	--[[ Callback: ClassPower:PostUpdate(current, maximum, hasMaxChanged, powerType)
	Called after the element has been updated.

	* self          - the ClassPower element
	* current       - the current amount of power (number)
	* maximum       - the maximum amount of power (number)
	* hasMaxChanged - indicates whether the maximum amount has changed since the last update (boolean)
	* powerType     - the active power type (string)
	* ...           - the indices of currently charged power points, if any
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(current, maximum, previousMax ~= maximum, powerType or currentType, chargedPoints)
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

	CurrentSpec = (oUF.isRetail or oUF.isMists) and GetSpecialization()
	RequirePower, RequireSpell = nil, nil -- clear these

	if PlayerClass == 'DRUID' then
		ClassPowerID = POWERTYPE_COMBO_POINTS

		RequirePower = POWERTYPE_ENERGY
		RequireSpell = oUF.isRetail and SPELL_SHRED or SPELL_CATFORM
	elseif PlayerClass == 'PALADIN' then
		ClassPowerID = POWERTYPE_HOLY_POWER
	elseif PlayerClass == 'EVOKER' then
		ClassPowerID = POWERTYPE_ESSENCE
	elseif PlayerClass == 'ROGUE' then
		ClassPowerID = POWERTYPE_COMBO_POINTS
	elseif PlayerClass == 'MONK' then
		ClassPowerID = (oUF.isMists or CurrentSpec == SPEC_MONK_WINDWALKER) and POWERTYPE_CHI or nil
	elseif PlayerClass == 'SHAMAN' then
		ClassPowerID = oUF.isRetail and (CurrentSpec == SPEC_SHAMAN_ENHANCEMENT and POWERTYPE_MAELSTROM or CurrentSpec == SPEC_SHAMAN_ELEMENTAL and POWERTYPE_MANA) or nil
	elseif PlayerClass == 'WARLOCK' then
		ClassPowerID = (not oUF.isMists and POWERTYPE_SOUL_SHARDS) or (CurrentSpec == SPEC_WARLOCK_DEMONOLOGY and POWERTYPE_DEMONIC_FURY) or (CurrentSpec == SPEC_WARLOCK_DESTRUCTION and POWERTYPE_BURNING_EMBERS) or (IsPlayerSpell(SPELL_SOULBURN) and POWERTYPE_SOUL_SHARDS) or nil
	elseif PlayerClass == 'MAGE' then
		ClassPowerID = (oUF.isRetail and CurrentSpec == SPEC_MAGE_FROST and POWERTYPE_ICICLES) or (CurrentSpec == SPEC_MAGE_ARCANE and POWERTYPE_ARCANE_CHARGES) or nil
	elseif PlayerClass == 'PRIEST' then
		ClassPowerID = (oUF.isRetail and CurrentSpec == SPEC_PRIEST_SHADOW and POWERTYPE_MANA) or (oUF.isMists and CurrentSpec == SPEC_PRIEST_SHADOW and POWERTYPE_SHADOW_ORBS) or nil
	end

	if (oUF.isRetail or oUF.isMists) and UnitHasVehicleUI('player') then
		shouldEnable = oUF.isMists and UnitPowerType('vehicle') == POWERTYPE_COMBO_POINTS or oUF.isRetail and PlayerVehicleHasComboPoints()
		unit = 'vehicle'
	elseif ClassPowerID then -- use 'player' instead of unit because 'SPELLS_CHANGED' is a unitless event
		if not RequirePower or RequirePower == UnitPowerType('player') then
			if not RequireSpell or IsPlayerSpell(RequireSpell) then
				shouldEnable = true
				unit = 'player'
			end
		end
	else
		shouldEnable = false
		unit = 'player'
	end

	local isEnabled = element.__isEnabled
	local powerType = (unit == 'vehicle' and 'COMBO_POINTS') or ClassPowerType[ClassPowerID]

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

function ClassPowerEnable(self)
	self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	self:RegisterEvent('UNIT_MAXPOWER', Path)

	if oUF.isRetail then -- according to Blizz any class may receive this event due to specific spell auras
		self:RegisterEvent('UNIT_POWER_POINT_CHARGE', Path)
	else
		self:RegisterEvent('PLAYER_TARGET_CHANGED', VisibilityPath, true)
	end

	if UseFakePower[ClassPowerID] then
		self:RegisterEvent('UNIT_AURA', Path)
	end

	self.ClassPower.__isEnabled = true

	if (oUF.isRetail or oUF.isMists) and UnitHasVehicleUI('player') then
		Path(self, 'ClassPowerEnable', 'vehicle', 'COMBO_POINTS')
	else
		Path(self, 'ClassPowerEnable', 'player', ClassPowerType[ClassPowerID])
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

	if UseFakePower[ClassPowerID] then
		self:UnregisterEvent('UNIT_AURA')
	end

	local element = self.ClassPower
	for i = 1, #element do
		element[i]:Hide()
	end

	element.__isEnabled = false

	Path(self, 'ClassPowerDisable', 'player', ClassPowerType[ClassPowerID])
end

local function Enable(self, unit)
	local element = self.ClassPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:RegisterEvent('SPELLS_CHANGED', VisibilityPath, true)

		element.ClassPowerEnable = ClassPowerEnable
		element.ClassPowerDisable = ClassPowerDisable

		for i = 1, #element do
			local bar = element[i]
			if not bar then break end

			if bar:IsObjectType('StatusBar') then
				if not bar:GetStatusBarTexture() then
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

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:UnregisterEvent('SPELLS_CHANGED', VisibilityPath)
	end
end

oUF:AddElement('ClassPower', VisibilityPath, Enable, Disable)
