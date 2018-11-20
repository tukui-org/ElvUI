local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")
if youScared then return end
-- sourced from FrameXML/Constants.lua
local SPEC_MAGE_ARCANE = SPEC_MAGE_ARCANE or 1
local SPEC_MONK_WINDWALKER = SPEC_MONK_WINDWALKER or 3
local SPEC_PALADIN_RETRIBUTION = SPEC_PALADIN_RETRIBUTION or 3
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION or 3
local SPELL_POWER_ENERGY = Enum.PowerType.Energy or 3
local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints or 4
local SPELL_POWER_SOUL_SHARDS = Enum.PowerType.SoulShards or 7
local SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower or 9
local SPELL_POWER_CHI = Enum.PowerType.Chi or 12
local SPELL_POWER_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges or 16

-- sourced from FrameXML/TargetFrame.lua
local MAX_COMBO_POINTS = MAX_COMBO_POINTS or 5

-- Holds the class specific stuff.
local ClassPowerID, ClassPowerType
local ClassPowerEnable, ClassPowerDisable
local RequireSpec, RequirePower, RequireSpell
local _, PlayerClass = UnitClass('player')

if(PlayerClass == 'MONK') then
	ClassPowerID = SPELL_POWER_CHI
	ClassPowerType = 'CHI'
	RequireSpec = SPEC_MONK_WINDWALKER
elseif(PlayerClass == 'PALADIN') then
	ClassPowerID = SPELL_POWER_HOLY_POWER
	ClassPowerType = 'HOLY_POWER'
	RequireSpec = SPEC_PALADIN_RETRIBUTION
elseif(PlayerClass == 'WARLOCK') then
	ClassPowerID = SPELL_POWER_SOUL_SHARDS
	ClassPowerType = 'SOUL_SHARDS'
elseif(PlayerClass == 'ROGUE' or PlayerClass == 'DRUID') then
	ClassPowerID = SPELL_POWER_COMBO_POINTS
	ClassPowerType = 'COMBO_POINTS'

	if(PlayerClass == 'DRUID') then
		RequirePower = SPELL_POWER_ENERGY
		RequireSpell = 5221 -- Shred
	end
elseif(PlayerClass == 'MAGE') then
	ClassPowerID = SPELL_POWER_ARCANE_CHARGES
	ClassPowerType = 'ARCANE_CHARGES'
	RequireSpec = SPEC_MAGE_ARCANE
end

function mod:UpdateElement_ClassBar(frame, event, unit ...)
	if(self.db.units[frame.UnitType].castbar.enable ~= true) then return end

	if(not (unit and (UnitIsUnit(unit, 'player') and powerType == ClassPowerType
		or unit == 'vehicle' and powerType == 'COMBO_POINTS'))) then
		return
	end

	local element = self.ClassPower

	local cur, max, mod, oldMax
	if(unit == 'vehicle') then
		-- BUG: UnitPower always returns 0 combo points for vehicles
		cur = GetComboPoints(unit)
		max = MAX_COMBO_POINTS
		mod = 1
	else
		cur = UnitPower('player', ClassPowerID, true)
		max = UnitPowerMax('player', ClassPowerID)
		mod = UnitPowerDisplayMod(ClassPowerID)
	end
	
	cur = mod == 0 and 0 or cur / mod

	-- BUG: Destruction is supposed to show partial soulshards, but Affliction and Demonology should only show full ones
	if(ClassPowerType == 'SOUL_SHARDS' and GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION) then
		cur = cur - cur % 1
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

function mod:UpdateColor_ClassBar(element, powerType)
	local color = {0.3, 0.7, 0.3}
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
end

function mod:UpdateVisibility_ClassBar(event, unit)
	local element = self.ClassPower
	local shouldEnable

	if(UnitHasVehicleUI('player')) then
		shouldEnable = true
		unit = 'vehicle'
	elseif(ClassPowerID) then
		if(not RequireSpec or RequireSpec == GetSpecialization()) then
			-- use 'player' instead of unit because 'SPELLS_CHANGED' is a unitless event
			if(not RequirePower or RequirePower == UnitPowerType('player')) then
				if(not RequireSpell or IsPlayerSpell(RequireSpell)) then
					self:UnregisterEvent('SPELLS_CHANGED', "UpdateVisibility_ClassBar")
					shouldEnable = true
					unit = 'player'
				else
					self:RegisterEvent('SPELLS_CHANGED', "UpdateVisibility_ClassBar")
				end
			end
		end
	end

	local isEnabled = element.isEnabled
	local powerType = unit == 'vehicle' and 'COMBO_POINTS' or ClassPowerType

	if(shouldEnable) then
		self:UpdateColor_ClassBar(element, powerType)
	end

	if(shouldEnable and not isEnabled) then
		self:ClassBar_Enable()
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		self:ClassBar_Disable()
	elseif(shouldEnable and isEnabled) then
		self:UpdateElement_ClassBar(event, unit, powerType)
	end
end

function mod:ClassBar_Enable()
	self:RegisterEvent('UNIT_POWER_FREQUENT', "UpdateElement_ClassBar")
	self:RegisterEvent('UNIT_MAXPOWER', "UpdateElement_ClassBar")

	self.ClassPower.isEnabled = true

	if(UnitHasVehicleUI('player')) then
		mod:UpdateElement_ClassBar(self.ClassPower, "COMBO_POINTS", "vehicle")
	else
		mod:UpdateElement_ClassBar(self.ClassPower, ClassPowerType, "player")
	end
end

function mod:ClassBar_Disable()
	self:UnregisterEvent('UNIT_POWER_FREQUENT', "UpdateElement_ClassBar")
	self:UnregisterEvent('UNIT_MAXPOWER', "UpdateElement_ClassBar")

	local element = self.ClassPower
	for i = 1, #element do
		element[i]:Hide()
	end

	self.ClassPower.isEnabled = false
	self:UpdateElement_ClassBar()
end

function mod:ConfigureElement_ClassBar(frame)
	local classBar = frame.ClassBar

	--Position
	classBar:ClearAllPoints()

	if(RequireSpec or RequireSpell) then
		self:RegisterEvent('PLAYER_TALENT_UPDATE', "UpdateElement_ClassBar")
	end

	if(RequirePower) then
		self:RegisterEvent('UNIT_DISPLAYPOWER', "UpdateElement_ClassBar")
	end

	--Texture
	--castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function mod:ConstructElement_CastBar(parent)
	local function updateGlowPosition()
		if not parent then return end
		mod:UpdatePosition_Glow(parent)
	end

	local frame = CreateFrame("StatusBar", "$parentClassbar", parent)
	self:StyleFrame(frame)

	self.ClassPower = frame

	frame:Hide()

	return frame
end
