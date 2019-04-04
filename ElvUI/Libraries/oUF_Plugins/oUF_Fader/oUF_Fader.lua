local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, "oUF_Fader cannot find an instance of oUF. If your oUF is embedded into a layout, it may not be embedded properly.")

-- Credit: p3lim, Azilroka, Simpy

-- GLOBALS: ElvUI
local pairs, ipairs = pairs, ipairs
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

local function ClearTimers(element)
	if element.configTimer then
		ElvUI[1]:CancelTimer(element.configTimer)
		element.configTimer = nil
	end
	if element.delayTimer then
		ElvUI[1]:CancelTimer(element.delayTimer)
		element.delayTimer = nil
	end
end

local function FadeOut(anim, frame, timeToFade, startAlpha, endAlpha)
	anim.timeToFade = timeToFade
	anim.startAlpha = startAlpha
	anim.endAlpha = endAlpha

	ElvUI[1]:UIFrameFade(frame, anim)
end

local function ToggleAlpha(self, element, endAlpha)
	ClearTimers(element)

	if element.Smooth then
		if not element.anim then
			element.anim = { mode = 'OUT' }
		else
			element.anim.fadeTimer = nil
		end

		FadeOut(element.anim, self, element.Smooth, self:GetAlpha(), endAlpha)
	else
		self:SetAlpha(endAlpha)
	end
end

local function Update(self, event, unit)
	if self.isForced then
		self:SetAlpha(1)
		return
	end

	local element = self.Fader
	unit = unit or self.unit

	-- range fader
	if element.Range then
		if element.UpdateRange then
			element.UpdateRange(self, unit)
		end
		if element.RangeAlpha then
			ToggleAlpha(self, element, element.RangeAlpha)
		end
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
		(element.PlayerTarget and UnitExists('target')) or
		(element.UnitTarget and UnitExists(unit..'target')) or
		(element.Focus and UnitExists('focus')) or
		(element.Health and UnitHealth(unit) < UnitHealthMax(unit)) or
		(element.Power and (PowerTypesFull[powerType] and UnitPower(unit) < UnitPowerMax(unit))) or
		(element.Vehicle and UnitHasVehicleUI(unit)) or
		(element.Hover and (GetMouseFocus() == self))
	then
		ToggleAlpha(self, element, element.MaxAlpha)
	else
		if element.Delay then
			ClearTimers(element)

			element.delayTimer = ElvUI[1]:ScheduleTimer(ToggleAlpha, element.Delay, self, element, element.MinAlpha)
		else
			ToggleAlpha(self, element, element.MinAlpha)
		end
	end
end

local function ForceUpdate(element)
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
	if self.Fader and self.Fader.HoverHooked == 1 then
		self.Fader:ForceUpdate()
	end
end

local function TargetScript(self)
	if self.Fader and self.Fader.TargetHooked == 1 then
		if self:IsShown() then
			self.Fader:ForceUpdate()
		else
			self:SetAlpha(0)
		end
	end
end

local options = {
	Range = {
		func = function(self)
			if not onRangeFrame then
				onRangeFrame = CreateFrame('Frame')
				onRangeFrame:SetScript('OnUpdate', onRangeUpdate)
			end

			onRangeFrame:Show()
			tinsert(onRangeObjects, self)
		end
	},
	Hover = {
		func = function(self)
			if not self.Fader.HoverHooked then
				self:HookScript('OnEnter', HoverScript)
				self:HookScript('OnLeave', HoverScript)
			end

			self.Fader.HoverHooked = 1 -- on state
		end,
		disableFunc = function(self)
			if self.Fader.HoverHooked == 1 then
				self.Fader.HoverHooked = 0 -- off state
			end
		end
	},
	Combat = {
		func = function(self)
			self:RegisterEvent('PLAYER_REGEN_ENABLED', Update, true)
			self:RegisterEvent('PLAYER_REGEN_DISABLED', Update, true)
		end,
		events = {'PLAYER_REGEN_ENABLED','PLAYER_REGEN_DISABLED'}
	},
	Target = { --[[ UnitTarget, PlayerTarget ]]
		func = function(self)
			if not self.Fader.TargetHooked then
				self:HookScript('OnShow', TargetScript)
				self:HookScript('OnHide', TargetScript)
			end

			self.Fader.TargetHooked = 1 -- on state

			if not self:IsShown() then
				self:SetAlpha(0)
			end

			self:RegisterEvent('UNIT_TARGET', Update)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', Update, true)
			self:RegisterEvent('PLAYER_FOCUS_CHANGED', Update, true)
		end,
		events = {'UNIT_TARGET','PLAYER_TARGET_CHANGED','PLAYER_FOCUS_CHANGED'},
		disableFunc = function(self)
			if self.Fader.TargetHooked == 1 then
				self.Fader.TargetHooked = 0 -- off state
			end
		end
	},
	Focus = {
		func = function(self)
			self:RegisterEvent('PLAYER_FOCUS_CHANGED', Update, true)
		end,
		events = {'PLAYER_FOCUS_CHANGED'}
	},
	Health = {
		func = function(self)
			self:RegisterEvent('UNIT_HEALTH', Update)
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Update)
			self:RegisterEvent('UNIT_MAXHEALTH', Update)
		end,
		events = {'UNIT_HEALTH','UNIT_HEALTH_FREQUENT','UNIT_MAXHEALTH'}
	},
	Power = {
		func = function(self)
			self:RegisterEvent('UNIT_POWER_UPDATE', Update)
			self:RegisterEvent('UNIT_MAXPOWER', Update)
		end,
		events = {'UNIT_POWER_UPDATE','UNIT_MAXPOWER'}
	},
	Vehicle = {
		func = function(self)
			self:RegisterEvent('UNIT_ENTERED_VEHICLE', Update, true)
			self:RegisterEvent('UNIT_EXITED_VEHICLE', Update, true)
		end,
		events = {'UNIT_ENTERED_VEHICLE','UNIT_EXITED_VEHICLE'}
	},
	Casting = {
		func = function(self)
			self:RegisterEvent('UNIT_SPELLCAST_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', Update)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)
		end,
		events = {'UNIT_SPELLCAST_START','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_STOP','UNIT_SPELLCAST_INTERRUPTED','UNIT_SPELLCAST_CHANNEL_START','UNIT_SPELLCAST_CHANNEL_STOP'}
	},
	MinAlpha = {
		func = function(self)
			if not self.Fader.MinAlpha then
				self.Fader.MinAlpha = .35
			end
		end
	},
	MaxAlpha = {
		func = function(self)
			if not self.Fader.MaxAlpha then
				self.Fader.MaxAlpha = .35
			end
		end
	},
	Smooth = {},
	Delay = {},
}

local function SetOption(element, opt, state)
	local option = (opt == 'UnitTarget' or opt == 'PlayerTarget' and 'Target') or opt
	if option and options[option] and (element[opt] ~= state) then
		element[opt] = state

		ClearTimers(element)

		if state then
			if options[option].func then
				options[option].func(element.__owner)
			end
		else
			if options[option].events and next(options[option].events) then
				for _, event in ipairs(options[option].events) do
					element.__owner:UnregisterEvent(event, Update)
				end
			end

			if options[option].disableFunc then
				options[option].disableFunc(element.__owner)
			end

			if option == 'Range' and onRangeFrame then
				for idx, obj in next, onRangeObjects do
					if obj == element.__owner then
						tremove(onRangeObjects, idx)
						break
					end
				end

				if #onRangeObjects == 0 then
					onRangeFrame:Hide()
				end
			end
		end
	end
end

local function Enable(self)
	if self.Fader then
		self.Fader.__owner = self
		self.Fader.ForceUpdate = ForceUpdate
		self.Fader.SetOption = SetOption

		return true
	end
end

local function Disable(self)
	if self.Fader then
		for opt in pairs(options) do
			if opt == 'Target' then
				self.Fader:SetOption('UnitTarget')
				self.Fader:SetOption('PlayerTarget')
			else
				self.Fader:SetOption(opt)
			end
		end
	end
end

oUF:AddElement('Fader', nil, Enable, Disable)
