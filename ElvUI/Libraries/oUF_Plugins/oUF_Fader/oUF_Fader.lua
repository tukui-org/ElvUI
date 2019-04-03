local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, "oUF_Fader cannot find an instance of oUF. If your oUF is embedded into a layout, it may not be embedded properly.")

-- Credit: p3lim, Azilroka, Simpy

-- GLOBALS: ElvUI
local next, tinsert, tremove = next, tinsert, tremove
local CreateFrame = CreateFrame
local GetMouseFocus = GetMouseFocus
local UnitAffectingCombat = UnitAffectingCombat
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitExists = UnitExists
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

local onRangeObjects, onRangeFrame = {}
local PowerTypesFull = {
	MANA = true,
	FOCUS = true,
	ENERGY = true,
}

local function ToggleAlpha(self, element, endAlpha)
	if element.delayTimer then
		ElvUI[1]:CancelTimer(element.delayTimer)
	end

	if element.Smooth then
		ElvUI[1]:UIFrameFadeOut(self, element.Smooth, self:GetAlpha(), endAlpha)
	else
		self:SetAlpha(element.MinAlpha)
	end
end

local function Update(self, event, unit)
	if self.isForced then
		self:SetAlpha(1)
		return
	end

	local element = self.Fader

	if element.isOff then
		ToggleAlpha(self, element, 1)
		return
	end

	unit = unit or self.unit

	-- range fader
	if element.Range and element.UpdateRange then
		element.UpdateRange(self, unit)
	end
	if element.Range and element.RangeAlpha then
		ToggleAlpha(self, element, element.RangeAlpha)
		return
	end

	-- normal fader
	local _, powerType
	if element.Power then
		_, powerType = UnitPowerType(unit)
	end

	if
		(element.Casting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) or
		(element.Combat and UnitAffectingCombat(unit)) or
		(element.Target and ( (unit:find('target') and UnitExists(unit)) or UnitExists(unit .. 'target') )) or
		(element.Focus and UnitExists('focus')) or
		(element.Health and UnitHealth(unit) < UnitHealthMax(unit)) or
		(element.Power and (PowerTypesFull[powerType] and UnitPower(unit) < UnitPowerMax(unit))) or
		(element.Vehicle and UnitHasVehicleUI(unit)) or
		(element.Hover and (GetMouseFocus() == self))
	then
		ToggleAlpha(self, element, element.MaxAlpha)
	else
		if element.Delay then
			if element.delayTimer then ElvUI[1]:CancelTimer(element.delayTimer) end
			element.delayTimer = ElvUI[1]:ScheduleTimer(ToggleAlpha, element.Delay, self, element, element.MinAlpha)
		else
			ToggleAlpha(self, element, element.MinAlpha)
		end
	end
end

local function ForceUpdate(element, configuring)
	if configuring then
		element.configureDelay = nil
	end

	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local timer = 0
local function onRangeUpdate(_, elapsed)
	timer = timer + elapsed

	if timer >= .20 then
		for _, object in next, onRangeObjects do
			if object:IsShown() then
				object.Fader:ForceUpdate()
			end
		end

		timer = 0
	end
end

local function HoverScript(self)
	local element = self.Fader
	if element and element.HoverHooked == 1 then
		Update(self)
	end
end

local function TargetScript(self)
	local element = self.Fader
	if element and element.TargetHooked == 1 then
		Update(self)
	end
end

local function Enable(self, unit)
	local element = self.Fader

	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		local on
		if element.Range then
			on = true

			if not onRangeFrame then
				onRangeFrame = CreateFrame('Frame')
				onRangeFrame:SetScript('OnUpdate', onRangeUpdate)
			end

			onRangeFrame:Show()
			tinsert(onRangeObjects, self)
		end

		if element.Hover then
			on = true

			if not element.HoverHooked then
				self:HookScript('OnEnter', HoverScript)
				self:HookScript('OnLeave', HoverScript)
			end

			element.HoverHooked = 1 -- on state
		end

		if element.Combat then
			on = true

			self:RegisterEvent('PLAYER_REGEN_ENABLED', Update, true)
			self:RegisterEvent('PLAYER_REGEN_DISABLED', Update, true)
		end

		if element.Target then
			on = true

			if not element.TargetHooked then
				self:HookScript('OnShow', TargetScript)
			end

			element.TargetHooked = 1 -- on state

			self:RegisterEvent('UNIT_TARGET', Update)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', Update, true)
		end

		if element.Focus then
			on = true

			self:RegisterEvent("PLAYER_FOCUS_CHANGED", Update, true)
		end

		if element.Health then
			on = true

			self:RegisterEvent('UNIT_HEALTH', Update)
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Update)
			self:RegisterEvent('UNIT_MAXHEALTH', Update)
		end

		if element.Power then
			on = true

			self:RegisterEvent('UNIT_POWER_UPDATE', Update)
			self:RegisterEvent('UNIT_MAXPOWER', Update)
		end

		if element.Vehicle then
			on = true

			self:RegisterEvent('UNIT_ENTERED_VEHICLE', Update, true)
			self:RegisterEvent('UNIT_EXITED_VEHICLE', Update, true)
		end

		if element.Casting then
			on = true

			self:RegisterEvent('UNIT_SPELLCAST_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', Update)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
		end

		if not element.MinAlpha then
			element.MinAlpha = .35
		end

		if not element.MaxAlpha then
			element.MaxAlpha = 1
		end

		if not on then
			element.isOff = true
		else
			element.isOff = nil
		end

		return true
	end
end

local function Disable(self, unit)
	local element = self.Fader

	if element then
		if element.HoverHooked == 1 then
			element.HoverHooked = 0 -- off state
		end
		if element.TargetHooked == 1 then
			element.TargetHooked = 0 -- off state
		end

		self:UnregisterEvent('PLAYER_REGEN_ENABLED', Update)
		self:UnregisterEvent('PLAYER_REGEN_DISABLED', Update)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Update)
		self:UnregisterEvent('UNIT_TARGET', Update)
		self:UnregisterEvent('UNIT_HEALTH', Update)
		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Update)
		self:UnregisterEvent('UNIT_MAXHEALTH', Update)
		self:UnregisterEvent('UNIT_POWER_UPDATE', Update)
		self:UnregisterEvent('UNIT_MAXPOWER', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_START', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
		self:UnregisterEvent('UNIT_ENTERED_VEHICLE', Update)
		self:UnregisterEvent('UNIT_EXITED_VEHICLE', Update)

		if onRangeFrame then
			for index, frame in next, onRangeObjects do
				if frame == self then
					tremove(onRangeObjects, index)
					break
				end
			end

			if element.Smooth then
				ElvUI[1]:UIFrameFadeIn(self, element.Smooth, self:GetAlpha(), 1)
			else
				self:SetAlpha(1)
			end

			if #onRangeObjects == 0 then
				onRangeFrame:Hide()
			end
		end
	end
end

oUF:AddElement('Fader', nil, Enable, Disable)
