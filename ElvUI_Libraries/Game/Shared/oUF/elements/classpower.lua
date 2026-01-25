--[[
# Element: ClassPower

Handles the visibility and updating of the player's class resources (like Chi Orbs or Holy Power) and combo points.

## Widget

ClassPower - An `table` consisting of as many StatusBars as the theoretical maximum return of [UnitPowerMax](https://warcraft.wiki.gg/wiki/API_UnitPowerMax).

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

-- sourced from Blizzard_FrameXMLBase/Constants.lua
local SPEC_MAGE_ARCANE = SPEC_MAGE_ARCANE or 1
local SPEC_MAGE_FROST = SPEC_MAGE_FROST or 3
local SPEC_PRIEST_SHADOW = SPEC_PRIEST_SHADOW or 3
local SPEC_MONK_WINDWALKER = SPEC_MONK_WINDWALKER or 3
local SPEC_SHAMAN_ELEMENTAL = SPEC_SHAMAN_ELEMENTAL or 1
local SPEC_SHAMAN_ENHANCEMENT = SPEC_SHAMAN_ENHANCEMENT or 2
local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY or 2
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION or 3
local SPEC_DEMONHUNTER_DEVOURER = SPEC_DEMONHUNTER_DEVOURER or 3
local SPEC_EVOKER_AUGMENTATION = SPEC_EVOKER_AUGMENTATION or 3

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

-- these are not real class powers: some removed because of Midnight
-- we used to have class mana bars for elemental and shadow
-- we also cant do fake icicles anymore either
local POWERTYPE_ICICLES = -1
local POWERTYPE_MAELSTROM = -2
local POWERTYPE_SOUL_FRAGMENTS = -3 -- wait this isnt fake kek
local POWERTYPE_EBON_MIGHT = -4 -- wait this isnt fake either

local SPELL_EBON_MIGHT = 395296
local SPELL_DARK_HEART = 1225789
local SPELL_SILENCE_WHISPERS = 1227702
local SPELL_VOID_METAMORPHOSIS = 1217607
local SPELL_FROST_ICICLES = 205473
local SPELL_ARCANE_CHARGE = 36032
local SPELL_MAELSTROM = 344179
local SPELL_SOULBURN = 74434
local SPELL_CATFORM = 768
local SPELL_SHRED = 5221

local next = next
local floor = floor
local GetTime = GetTime
local UnitPower = UnitPower
local UnitIsUnit = UnitIsUnit
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitPowerDisplayMod = UnitPowerDisplayMod
local PlayerVehicleHasComboPoints = PlayerVehicleHasComboPoints
local GetUnitChargedPowerPoints = GetUnitChargedPowerPoints
local GetCollapsingStarCost = GetCollapsingStarCost
local GetComboPoints = GetComboPoints

local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetSpellMaxCumulativeAuraApplications = C_Spell.GetSpellMaxCumulativeAuraApplications
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local IsPlayerSpell = C_SpellBook.IsSpellKnown or IsPlayerSpell
local StatusBarInterpolation = Enum.StatusBarInterpolation

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
	[POWERTYPE_SOUL_FRAGMENTS] = 'SOUL_FRAGMENTS',
	[POWERTYPE_EBON_MIGHT] = 'EBON_MIGHT'
}

local ClassPowerMax = {
	[POWERTYPE_EBON_MIGHT] = 20,
	[POWERTYPE_DEMONIC_FURY] = 1,
	[POWERTYPE_BURNING_EMBERS] = 4,
	[POWERTYPE_MAELSTROM] = 10,
	[POWERTYPE_ICICLES] = 5,
}

local UseFakePower = {
	[POWERTYPE_EBON_MIGHT] = oUF.isRetail,
	[POWERTYPE_SOUL_FRAGMENTS] = oUF.isRetail,
	[POWERTYPE_ARCANE_CHARGES] = oUF.isMists,
	[POWERTYPE_MAELSTROM] = oUF.isRetail,
	[POWERTYPE_ICICLES] = oUF.isRetail
}

local function UpdateColor(element, powerType)
	local color = element.__owner.colors.power[powerType]
	if(color) then
		for i = 1, #element do
			local bar = element[i]
			bar:GetStatusBarTexture():SetVertexColor(color:GetRGB())
		end
	end

	--[[ Callback: ClassPower:PostUpdateColor(color)
	Called after the element color has been updated.

	* self  - the ClassPower element
	* color - the used ColorMixin-based object (table?)
	--]]
	if(element.PostUpdateColor) then
		element:PostUpdateColor(element.__owner.unit, color)
	end
end

local function CheckAura(spellID, filter)
	local info = GetPlayerAuraBySpellID(spellID)
	local allow = info and (not filter or (filter == 'HELPFUL' and info.isHelpful) or (filter == 'HARMFUL' and info.isHarmful))
	return (allow and info) or nil
end

local function GetApplications(spellID, filter)
	local info = CheckAura(spellID, filter)
	return (info and info.applications) or 0
end

local function GetExpiration(spellID, filter)
	local info = CheckAura(spellID, filter)
	return (info and info.expirationTime) or nil
end

local function GetDuration(spellID)
	local expiration = GetExpiration(spellID, 'HELPFUL')
	return (not expiration and 0) or (expiration - GetTime())
end

local watcher = CreateFrame('Frame')
watcher.frames = {}
watcher:Hide()
watcher:SetScript('OnUpdate', function(w, elapsed)
	w.waiting = (w.waiting or 0) + elapsed

	if w.waiting > 0.1 then
		for frame, spellID in next, w.frames do
			frame:SetValue(GetDuration(spellID), frame.smoothing)
		end

		w.waiting = 0
	end
end)

local function ThirdVisibility(element, enabled)
	if not element then return end

	if enabled == nil then
		enabled = element.__allowPower
	end

	element:SetShown(enabled)

	if not enabled then
		watcher:Hide()
	end
end

local function Update(self, element, event, unit, powerType)
	if not unit or not UnitIsUnit(unit, 'player') then return end

	local classPowerID = element.classPowerID
	local currentType = ClassPowerType[classPowerID]
	if event == 'UNIT_AURA' then powerType = currentType end
	if event ~= 'ClassPowerDisable' and event ~= 'ClassPowerEnable' and not powerType then return end

	local myClass = oUF.myclass
	local vehicle = unit == 'vehicle' and powerType == 'COMBO_POINTS'
	local classic = not oUF.isRetail and (powerType == 'COMBO_POINTS' or (myClass == 'ROGUE' and powerType == 'ENERGY'))
	if not (vehicle or classic or powerType == currentType) then return end

	--[[ Callback: ClassPower:PreUpdate(event)
	Called before the element has been updated.

	* self  - the ClassPower element
	]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local current, maximum, powerMax, previousMax, chargedPoints
	if event ~= 'ClassPowerDisable' then
		local powerID = (vehicle and POWERTYPE_COMBO_POINTS) or classPowerID
		local displayMod = (powerID > 0 and UnitPowerDisplayMod(powerID)) or 1
		local warlockDest = classPowerID == POWERTYPE_BURNING_EMBERS or nil
		local warlockDemo = classPowerID == POWERTYPE_DEMONIC_FURY or nil
		local devourerDemon = classPowerID == POWERTYPE_SOUL_FRAGMENTS or nil

		if displayMod == 0 then -- mod should never be 0, but according to Blizz code it can actually happen
			current = 0
		elseif devourerDemon then
			local metamorphosis = GetPlayerAuraBySpellID(SPELL_VOID_METAMORPHOSIS)
			local spell = metamorphosis and SPELL_SILENCE_WHISPERS or SPELL_DARK_HEART
			current = GetApplications(spell, 'HELPFUL')

			if metamorphosis then
				maximum, powerMax = 1, GetCollapsingStarCost()
			else
				maximum, powerMax = 1, GetSpellMaxCumulativeAuraApplications(SPELL_DARK_HEART)
			end
		elseif oUF.isRetail and (myClass == 'WARLOCK' and element.currentSpec == SPEC_WARLOCK_DESTRUCTION) then -- destro locks are special
			current = UnitPower(unit, powerID, true) / displayMod
		elseif oUF.isRetail and classPowerID == POWERTYPE_EBON_MIGHT then
			local duration = GetDuration(SPELL_EBON_MIGHT)

			element:SetMinMaxValues(0, duration)
			watcher:SetShown(duration > 0)

			watcher.frames[element] = SPELL_EBON_MIGHT or nil
		elseif oUF.isMists and classPowerID == POWERTYPE_ARCANE_CHARGES then
			current = GetApplications(SPELL_ARCANE_CHARGE, 'HARMFUL')
		elseif classPowerID == POWERTYPE_ICICLES then
			current = GetApplications(SPELL_FROST_ICICLES, 'HELPFUL')
		elseif classPowerID == POWERTYPE_MAELSTROM then
			current = GetApplications(SPELL_MAELSTROM, 'HELPFUL')
		else
			local cur = classic and GetComboPoints(unit, 'target') or UnitPower(unit, powerID, warlockDest)
			current = warlockDest and (cur * 0.1) or warlockDemo and (cur * 0.001) or cur
		end

		if not maximum then
			powerMax = ClassPowerMax[classPowerID] or UnitPowerMax(unit, powerID, warlockDest)
			maximum = (classPowerID == POWERTYPE_MANA and 1) or powerMax or 0
		end

		chargedPoints = oUF.isRetail and GetUnitChargedPowerPoints(unit)

		for i = 1, maximum do
			local bar = element[i]
			if not bar then break end

			bar:Show()

			if devourerDemon then
				bar:SetValue(current / powerMax)
			elseif classPowerID == POWERTYPE_MANA then
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

	if self.ThirdPower then
		(self.ThirdPower.Override or Update) (self, self.ThirdPower, ...)
	end

	return (self.ClassPower.Override or Update) (self, self.ClassPower, ...)
end

local function Visibility(self, element, event, unit)
	local shouldEnable

	local currentSpec = (oUF.isRetail or oUF.isMists) and GetSpecialization()

	local classPowerID, requirePower, requireSpell
	local myClass = oUF.myclass
	if myClass == 'DRUID' then
		classPowerID = POWERTYPE_COMBO_POINTS

		requirePower = POWERTYPE_ENERGY
		requireSpell = oUF.isRetail and SPELL_SHRED or SPELL_CATFORM
	elseif myClass == 'PALADIN' then
		classPowerID = POWERTYPE_HOLY_POWER
	elseif myClass == 'ROGUE' then
		classPowerID = POWERTYPE_COMBO_POINTS
	elseif myClass == 'MONK' then
		classPowerID = (oUF.isMists or currentSpec == SPEC_MONK_WINDWALKER) and POWERTYPE_CHI or nil
	elseif myClass == 'SHAMAN' then
		classPowerID = oUF.isRetail and (currentSpec == SPEC_SHAMAN_ENHANCEMENT and POWERTYPE_MAELSTROM) or nil
	elseif myClass == 'EVOKER' and not element.which then
		classPowerID = POWERTYPE_ESSENCE
	elseif myClass == 'EVOKER' and element.which then
		classPowerID = oUF.isRetail and (currentSpec == SPEC_EVOKER_AUGMENTATION and POWERTYPE_EBON_MIGHT) or nil
	elseif myClass == 'DEMONHUNTER' then
		classPowerID = oUF.isRetail and (currentSpec == SPEC_DEMONHUNTER_DEVOURER and POWERTYPE_SOUL_FRAGMENTS) or nil
	elseif myClass == 'WARLOCK' then
		classPowerID = (not oUF.isMists and POWERTYPE_SOUL_SHARDS) or (currentSpec == SPEC_WARLOCK_DEMONOLOGY and POWERTYPE_DEMONIC_FURY) or (currentSpec == SPEC_WARLOCK_DESTRUCTION and POWERTYPE_BURNING_EMBERS) or (IsPlayerSpell(SPELL_SOULBURN) and POWERTYPE_SOUL_SHARDS) or nil
	elseif myClass == 'MAGE' then
		classPowerID = (currentSpec == SPEC_MAGE_ARCANE and POWERTYPE_ARCANE_CHARGES) or nil
	elseif myClass == 'PRIEST' then
		classPowerID = (oUF.isMists and currentSpec == SPEC_PRIEST_SHADOW and POWERTYPE_SHADOW_ORBS) or nil
	end

	if (oUF.isRetail or oUF.isWrath or oUF.isMists) and UnitHasVehicleUI('player') then
		shouldEnable = (oUF.isWrath or oUF.isMists) and UnitPowerType('vehicle') == POWERTYPE_COMBO_POINTS or oUF.isRetail and PlayerVehicleHasComboPoints()
		unit = 'vehicle'
	elseif classPowerID then -- use 'player' instead of unit because 'SPELLS_CHANGED' is a unitless event
		if not requirePower or requirePower == UnitPowerType('player') then
			if not requireSpell or IsPlayerSpell(requireSpell) then
				shouldEnable = true
				unit = 'player'
			end
		end
	else
		shouldEnable = false
		unit = 'player'
	end

	element.currentSpec = currentSpec
	element.classPowerID = classPowerID

	local isEnabled = element.__isEnabled
	local powerType = (unit == 'vehicle' and 'COMBO_POINTS') or ClassPowerType[classPowerID]

	if element.which then
		ThirdVisibility(element)
	end

	if(shouldEnable) then
		--[[ Override: ClassPower:UpdateColor(powerType)
		Used to completely override the internal function for updating the widgets' colors.

		* self      - the ClassPower element
		* powerType - the active power type (string)
		--]]
		(element.UpdateColor or UpdateColor) (element, powerType)
	end

	if(shouldEnable and not isEnabled) then
		element:ClassPowerEnable(self)

		--[[ Callback: ClassPower:PostVisibility(isVisible)
		Called after the element's visibility has been changed.

		* self      - the ClassPower element
		* isVisible - the current visibility state of the element (boolean)
		--]]
		if(element.PostVisibility) then
			element:PostVisibility(true)
		end
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		element:ClassPowerDisable(self)

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

	if self.ThirdPower then
		(self.ThirdPower.OverrideVisibility or Visibility) (self, self.ThirdPower, ...)
	end

	return (self.ClassPower.OverrideVisibility or Visibility) (self, self.ClassPower, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function ClassPowerEnable(element, owner)
	owner:RegisterEvent('UNIT_POWER_FREQUENT', Path)
	owner:RegisterEvent('UNIT_MAXPOWER', Path)

	if oUF.isRetail then -- according to Blizz any class may receive this event due to specific spell auras
		owner:RegisterEvent('UNIT_POWER_POINT_CHARGE', Path)
	else
		owner:RegisterEvent('PLAYER_TARGET_CHANGED', VisibilityPath, true)
	end

	if UseFakePower[element.classPowerID] then
		owner:RegisterEvent('UNIT_AURA', Path)
	end

	ThirdVisibility(owner.ThirdPower, true)

	element.__isEnabled = true

	if (oUF.isRetail or oUF.isWrath or oUF.isMists) and UnitHasVehicleUI('player') then
		Path(owner, 'ClassPowerEnable', 'vehicle', 'COMBO_POINTS')
	else
		Path(owner, 'ClassPowerEnable', 'player', ClassPowerType[element.classPowerID])
	end
end

local function ClassPowerDisable(element, owner)
	owner:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
	owner:UnregisterEvent('UNIT_MAXPOWER', Path)

	if oUF.isRetail then
		owner:UnregisterEvent('UNIT_POWER_POINT_CHARGE', Path)
	else
		owner:UnregisterEvent('PLAYER_TARGET_CHANGED', VisibilityPath)
	end

	if UseFakePower[element.classPowerID] then
		owner:UnregisterEvent('UNIT_AURA')
	end

	for i = 1, #element do
		element[i]:Hide()
	end

	ThirdVisibility(owner.ThirdPower, false)

	element.__isEnabled = false

	Path(owner, 'ClassPowerDisable', 'player', ClassPowerType[element.classPowerID])
end

local function Enable(self, unit)
	local element = self.ClassPower
	if(element and UnitIsUnit(unit, 'player')) then
		element.__owner = self
		element.__max = #element
		element.ForceUpdate = ForceUpdate

		local timer = self.ThirdPower
		if timer then
			timer.__owner = self
			timer.__max = 1
			timer.which = 'ThirdPower'

			timer:SetMinMaxValues(0, 1)
			timer:SetValue(0)

			if(not timer.smoothing) then
				timer.smoothing = StatusBarInterpolation and StatusBarInterpolation.Immediate or nil
			end

			timer.ClassPowerEnable = ClassPowerEnable
			timer.ClassPowerDisable = ClassPowerDisable
		end

		element.ClassPowerEnable = ClassPowerEnable
		element.ClassPowerDisable = ClassPowerDisable

		self:RegisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:RegisterEvent('SPELLS_CHANGED', VisibilityPath, true)

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
	local element = self.ClassPower
	if(element) then
		ClassPowerDisable(element, self)

		self:UnregisterEvent('UNIT_DISPLAYPOWER', VisibilityPath)
		self:UnregisterEvent('SPELLS_CHANGED', VisibilityPath)
	end
end

oUF:AddElement('ClassPower', VisibilityPath, Enable, Disable)
