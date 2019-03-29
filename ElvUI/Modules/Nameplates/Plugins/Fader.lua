local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local GetMouseFocus = GetMouseFocus
local UnitPowerType, UnitPower, UnitPowerMax, UnitCastingInfo, UnitChannelInfo, UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax = UnitPowerType, UnitPower, UnitPowerMax, UnitCastingInfo, UnitChannelInfo, UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax

local PowerTypesEmpty = {
	RAGE = true,
	RUNIC_POWER = true,
	LUNAR_POWER = true,
	MAELSTROM = true,
	FURY = true,
	PAIN = true
}

local PowerTypesFull = {
	MANA = true,
	FOCUS = true,
	ENERGY = true,
}

local function Update(self, event, unit)
	unit = unit or self.unit
	local element = self.Fader

	local _, powerType = UnitPowerType(unit)
	local power = UnitPower(unit)

	if
		(element.Casting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) or
		(element.Combat and UnitAffectingCombat(unit)) or
		(element.Target and (unit:find('target') and UnitExists(unit))) or
		(element.Target and UnitExists(unit .. 'target')) or
		(element.Focus and UnitExists('focus')) or
		(element.Health and UnitHealth(unit) < UnitHealthMax(unit)) or
		(element.Power and (PowerTypesEmpty[powerType] and power > 0)) or
		(element.Power and (PowerTypesFull[powerType] and power < UnitPowerMax(unit))) or
		(element.Hover and (GetMouseFocus() == self))
	then
		if (element.Smooth) then
			E:UIFrameFadeIn(self, element.Smooth, self:GetAlpha(), element.MaxAlpha)
		else
			self:SetAlpha(element.MaxAlpha)
		end
	else
		if element.Delay then
			E:Delay(element.Delay, E.UIFrameFadeIn, E, self, element.Smooth, self:GetAlpha(), element.MinAlpha)
		elseif (element.Smooth) then
			E:UIFrameFadeOut(self, element.Smooth, self:GetAlpha(), element.MinAlpha)
		else
			self:SetAlpha(element.MinAlpha)
		end
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Fader

	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(element.Hover) then
			self:HookScript('OnEnter', Update)
			self:HookScript('OnLeave', Update)
		end

		if(element.Combat) then
			self:RegisterEvent('PLAYER_REGEN_ENABLED', Update, true)
			self:RegisterEvent('PLAYER_REGEN_DISABLED', Update, true)
		end

		if(element.Target) then
			self:HookScript('OnShow', Update)
			self:RegisterEvent('UNIT_TARGET', Update)
		end

		if(element.Focus) then
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", Update, true)
		end

		if(element.Health) then
			self:RegisterEvent('UNIT_HEALTH', Update)
			self:RegisterEvent('UNIT_MAXHEALTH', Update)
		end

		if(element.Power) then
			self:RegisterEvent('UNIT_POWER_UPDATE', Update)
			self:RegisterEvent('UNIT_MAXPOWER', Update)
		end

		if(element.Casting) then
			self:RegisterEvent('UNIT_SPELLCAST_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', Update)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
		end

		if not element.Smooth then
			element.Smooth = 1
		end

		if not element.MinAlpha then
			element.MinAlpha = .35
		end

		if not element.MaxAlpha then
			element.MaxAlpha = 1
		end

		if not element.Delay then
			element.Delay = 3
		end

		return true
	end
end

local function Disable(self, unit)
	local element = self.Fader

	if element then
		self:UnregisterEvent('PLAYER_REGEN_ENABLED', Update)
		self:UnregisterEvent('PLAYER_REGEN_DISABLED', Update)
		self:UnregisterEvent('UNIT_TARGET', Update)
		self:UnregisterEvent('UNIT_HEALTH', Update)
		self:UnregisterEvent('UNIT_MAXHEALTH', Update)
		self:UnregisterEvent('UNIT_POWER_UPDATE', Update)
		self:UnregisterEvent('UNIT_MAXPOWER', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_START', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
	end
end

oUF:AddElement('Fader', nil, Enable, Disable)
