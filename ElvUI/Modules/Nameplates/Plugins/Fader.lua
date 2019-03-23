local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local GetMouseFocus = GetMouseFocus
local UnitPowerType, UnitPower, UnitPowerMax, UnitCastingInfo, UnitChannelInfo, UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax = UnitPowerType, UnitPower, UnitPowerMax, UnitCastingInfo, UnitChannelInfo, UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax

local function Update(self, event)
	local unit = self.unit

	local _, powerType = UnitPowerType(unit)
	local power = UnitPower(unit)

	if not self.Fader then
		return
	end

	if
		(self.FadeCasting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) or
		(self.FadeCombat and UnitAffectingCombat(unit)) or
		(self.FadeTarget and (unit:find('target') and UnitExists(unit))) or
		(self.FadeTarget and UnitExists(unit .. 'target')) or
		(self.FadeHealth and UnitHealth(unit) < UnitHealthMax(unit)) or
		(self.FadePower and ((powerType == 'RAGE' or powerType == 'RUNIC_POWER') and power > 0)) or
		(self.FadePower and ((powerType ~= 'RAGE' and powerType ~= 'RUNIC_POWER') and power < UnitPowerMax(unit))) or
		(self.FadeHover and (self:IsMouseOver() or GetMouseFocus() == self))
	then
		if (self.FadeSmooth) then
			E:UIFrameFadeIn(self, self.FadeSmooth or 1, self:GetAlpha(), self.FadeMaxAlpha or 1)
		else
			self:SetAlpha(self.FadeMaxAlpha or 1)
		end
	else
		if self.FadeDelay then
			E:Delay(self.FadeDelay, E.UIFrameFadeIn, E, self, self.FadeSmooth or 1, self:GetAlpha(), self.FadeMinAlpha or 0.3)
		elseif (self.FadeSmooth) then
			E:UIFrameFadeOut(self, self.FadeSmooth or 1, self:GetAlpha(), self.FadeMinAlpha or 0.3)
		else
			self:SetAlpha(self.FadeMinAlpha or 0.3)
		end
	end
end

local function Enable(self, unit)
	if(self.FadeHover) then
		self:HookScript('OnEnter', Update)
		self:HookScript('OnLeave', Update)
	end

	if(self.FadeCombat) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', Update, true)
		self:RegisterEvent('PLAYER_REGEN_DISABLED', Update, true)
	end

	if(self.FadeTarget) then
		self:HookScript('OnShow', Update)
		self:RegisterEvent('UNIT_TARGET', Update)
	end

	if(self.FadeHealth) then
		self:RegisterEvent('UNIT_HEALTH', Update)
		self:RegisterEvent('UNIT_MAXHEALTH', Update)
	end

	if(self.FadePower) then
		self:RegisterEvent('UNIT_POWER_UPDATE', Update)
		self:RegisterEvent('UNIT_MAXPOWER', Update)
	end

	if(self.FadeCasting) then
		self:RegisterEvent('UNIT_SPELLCAST_START', Update)
		self:RegisterEvent('UNIT_SPELLCAST_FAILED', Update)
		self:RegisterEvent('UNIT_SPELLCAST_STOP', Update)
		self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
	end

	Update(self)

	return true
end

local function Disable(self, unit)
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

oUF:AddElement('Fader', nil, Enable, Disable)
