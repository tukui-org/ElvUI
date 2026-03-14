local _, ns = ...
local oUF = ns.oUF

-------------
-- Credits --  p3lim, Azilroka, Simpy
-------------

local _G = _G
local pairs, ipairs, type = pairs, ipairs, type
local next, tinsert, tremove = next, tinsert, tremove

local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
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
local C_PlayerInfo_GetGlidingInfo = C_PlayerInfo.GetGlidingInfo

local GetMouseFocus = GetMouseFocus or function()
	local frames = _G.GetMouseFoci()
	return frames and frames[1]
end

-- These variables will be left-over when disabled if they were used (for reuse later if they become re-enabled):
---- Fader.HoverHooked, Fader.TargetHooked

local E -- ElvUI engine defined in ClearTimers
local MIN_ALPHA, MAX_ALPHA = .35, 1
local onRangeObjects, onRangeFrame = {}
local PowerTypesFull = { MANA = true, FOCUS = true, ENERGY = true }

local function ClearTimers(element)
	if not E then E = _G.ElvUI[1] end

	if element.configTimer then
		E:CancelTimer(element.configTimer)
		element.configTimer = nil
	end

	if element.delayTimer then
		E:CancelTimer(element.delayTimer)
		element.delayTimer = nil
	end
end

local function ToggleAlpha(frame, element, endAlpha)
	element:ClearTimers()

	if element.Smooth then
		E:UIFrameFadeOut(frame, element.Smooth, frame:GetAlpha(), endAlpha)
	else
		frame:SetAlpha(endAlpha)
	end
end

local function UpdateInstanceDifficulty(element)
	local _, _, difficultyID = GetInstanceInfo()
	element.InstancedCached = element.InstanceDifficulty and element.InstanceDifficulty[difficultyID] or nil
end

local isGliding = false
local function Update(frame, event, unit)
	local element = frame.Fader
	if frame.isForced or (not element or not element.count or element.count <= 0) then
		frame:SetAlpha(1)
		return
	elseif element.Range and event ~= 'OnRangeUpdate' then
		return
	end

	-- stuff for Skyriding
	if oUF.isRetail then
		if event == 'ForceUpdate' then
			isGliding = C_PlayerInfo_GetGlidingInfo()
		elseif event == 'PLAYER_IS_GLIDING_CHANGED' then
			isGliding = unit -- unit is true/false with the event being PLAYER_IS_GLIDING_CHANGED
		end
	end

	-- try to get the unit from the parent
	if not unit or type(unit) ~= 'string' then
		unit = frame.realUnit or frame.unit
	end

	-- range fader
	if element.Range then
		if element.UpdateRange then
			element.UpdateRange(frame, unit)
		end

		if element.RangeAlpha then
			ToggleAlpha(frame, element, element.RangeAlpha)
		end

		return
	end

	-- Instance Difficulty is enabled and we haven't checked yet
	if element.InstanceDifficulty and not element.InstancedCached then
		UpdateInstanceDifficulty(element)
	end

	-- normal fader
	local _, powerType
	if element.Power then
		_, powerType = UnitPowerType(unit)
	end

	local currentHealth = UnitHealth(unit)
	local maxHealth = UnitHealthMax(unit)
	local currentPower = UnitPower(unit)
	local maxPower = UnitPowerMax(unit)

	if	(element.InstanceDifficulty and element.InstancedCached) or
		(element.Casting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) or
		(element.Combat and UnitAffectingCombat(unit)) or
		(element.PlayerTarget and UnitExists('target')) or
		(element.UnitTarget and UnitExists(unit..'target')) or
		(element.Focus and not oUF.isClassic and UnitExists('focus')) or
		(element.Health and oUF:NotSecretValue(currentHealth) and (currentHealth < maxHealth)) or
		(element.Power and (PowerTypesFull[powerType] and oUF:NotSecretValue(currentPower) and (currentPower < maxPower))) or
		(element.Vehicle and (oUF.isRetail or oUF.isWrath or oUF.isMists) and UnitHasVehicleUI(unit)) or
		(element.DynamicFlight and oUF.isRetail and not isGliding) or
		(element.Hover and GetMouseFocus() == (frame.__faderobject or frame))
	then
		ToggleAlpha(frame, element, element.MaxAlpha)
	elseif element.Delay then
		if element.DelayAlpha then
			ToggleAlpha(frame, element, element.DelayAlpha)
		end

		element:ClearTimers()
		element.delayTimer = E:ScheduleTimer(ToggleAlpha, element.Delay, frame, element, element.MinAlpha)
	else
		ToggleAlpha(frame, element, element.MinAlpha)
	end
end

local function ForceUpdate(element, event)
	return Update(element.__owner, event or 'ForceUpdate', element.__owner.unit)
end

local function OnRangeUpdate(frame, elapsed)
	frame.timer = (frame.timer or 0) + elapsed

	if (frame.timer >= .20) then
		for _, object in next, onRangeObjects do
			local element = object:IsVisible() and object.Fader
			if element then
				element:ForceUpdate('OnRangeUpdate')
			end
		end

		frame.timer = 0
	end
end

local function OnUnitInRangeUpdate(frame)
	local element = frame:IsVisible() and frame.Fader
	if element and element.Range then
		element:ForceUpdate('OnRangeUpdate')
	end
end

local function OnInstanceDifficulty(frame)
	local element = frame.Fader
	UpdateInstanceDifficulty(element)

	element:ForceUpdate('OnInstanceDifficulty')
end

local function HoverScript(frame)
	local Fader = frame.__faderelement or frame.Fader
	if Fader and Fader.HoverHooked == 1 then
		Fader:ForceUpdate('HoverScript')
	end
end

local function TargetScript(frame)
	local element = frame.Fader
	if element and element.TargetHooked == 1 then
		if frame:IsShown() then
			element:ForceUpdate('TargetScript')
		else
			frame:SetAlpha(0)
		end
	end
end

local options = {
	Range = {
		enable = function(frame)
			if not onRangeFrame then
				onRangeFrame = CreateFrame('Frame')
				onRangeFrame:SetScript('OnUpdate', OnRangeUpdate)
			end

			onRangeFrame:Show()
			tinsert(onRangeObjects, frame)

			-- frame:RegisterEvent('UNIT_IN_RANGE_UPDATE', OnUnitInRangeUpdate)
		end,
		disable = function(frame)
			if onRangeFrame then
				for idx, obj in next, onRangeObjects do
					if obj == frame then
						frame.Fader.RangeAlpha = nil
						tremove(onRangeObjects, idx)
						break
					end
				end

				if #onRangeObjects == 0 then
					onRangeFrame:Hide()
				end
			end

			-- frame:UnregisterEvent('UNIT_IN_RANGE_UPDATE', OnUnitInRangeUpdate)
		end
	},
	Hover = {
		enable = function(frame)
			if not frame.Fader.HoverHooked then
				local Frame = frame.__faderobject or frame
				Frame:HookScript('OnEnter', HoverScript)
				Frame:HookScript('OnLeave', HoverScript)
			end

			frame.Fader.HoverHooked = 1 -- on state
		end,
		disable = function(frame)
			if frame.Fader.HoverHooked == 1 then
				frame.Fader.HoverHooked = 0 -- off state
			end
		end
	},
	Combat = {
		enable = function(frame)
			frame:RegisterEvent('PLAYER_REGEN_ENABLED', Update, true)
			frame:RegisterEvent('PLAYER_REGEN_DISABLED', Update, true)
			frame:RegisterEvent('UNIT_FLAGS', Update)
		end,
		events = {'PLAYER_REGEN_ENABLED','PLAYER_REGEN_DISABLED','UNIT_FLAGS'}
	},
	Target = { --[[ UnitTarget, PlayerTarget ]]
		enable = function(frame)
			if not frame.Fader.TargetHooked then
				frame:HookScript('OnShow', TargetScript)
				frame:HookScript('OnHide', TargetScript)
			end

			frame.Fader.TargetHooked = 1 -- on state

			if not frame:IsShown() then
				frame:SetAlpha(0)
			end

			frame:RegisterEvent('UNIT_TARGET', Update)
			frame:RegisterEvent('PLAYER_TARGET_CHANGED', Update, true)
			frame:RegisterEvent('PLAYER_FOCUS_CHANGED', Update, true)
		end,
		events = {'UNIT_TARGET','PLAYER_TARGET_CHANGED','PLAYER_FOCUS_CHANGED'},
		disable = function(frame)
			if frame.Fader.TargetHooked == 1 then
				frame.Fader.TargetHooked = 0 -- off state
			end
		end
	},
	Health = {
		enable = function(frame)
			if oUF.isClassic then
				frame:RegisterEvent('UNIT_HEALTH_FREQUENT', Update)
			end

			frame:RegisterEvent('UNIT_HEALTH', Update)
			frame:RegisterEvent('UNIT_MAXHEALTH', Update)
		end,
		events = oUF.isClassic and {'UNIT_HEALTH_FREQUENT','UNIT_HEALTH','UNIT_MAXHEALTH'} or {'UNIT_HEALTH','UNIT_MAXHEALTH'}
	},
	Power = {
		enable = function(frame)
			frame:RegisterEvent('UNIT_POWER_UPDATE', Update)
			frame:RegisterEvent('UNIT_MAXPOWER', Update)
		end,
		events = {'UNIT_POWER_UPDATE','UNIT_MAXPOWER'}
	},
	Casting = {
		enable = function(frame)
			frame:RegisterEvent('UNIT_SPELLCAST_START', Update)
			frame:RegisterEvent('UNIT_SPELLCAST_FAILED', Update)
			frame:RegisterEvent('UNIT_SPELLCAST_STOP', Update)
			frame:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', Update)
			frame:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Update)
			frame:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Update)

			if oUF.isRetail then
				frame:RegisterEvent('UNIT_SPELLCAST_EMPOWER_START', Update)
				frame:RegisterEvent('UNIT_SPELLCAST_EMPOWER_STOP', Update)
			end
		end,
		events = {'UNIT_SPELLCAST_START','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_STOP','UNIT_SPELLCAST_INTERRUPTED','UNIT_SPELLCAST_CHANNEL_START','UNIT_SPELLCAST_CHANNEL_STOP'}
	},
	InstanceDifficulty = {
		enable = function(frame)
			frame:RegisterEvent('ZONE_CHANGED', OnInstanceDifficulty, true)
			frame:RegisterEvent('ZONE_CHANGED_INDOORS', OnInstanceDifficulty, true)
			frame:RegisterEvent('ZONE_CHANGED_NEW_AREA', OnInstanceDifficulty, true)
			frame:RegisterEvent('PLAYER_DIFFICULTY_CHANGED', OnInstanceDifficulty, true)
		end,
		events = {'ZONE_CHANGED', 'ZONE_CHANGED_INDOORS', 'ZONE_CHANGED_NEW_AREA', 'PLAYER_DIFFICULTY_CHANGED'}
	},
	MinAlpha = {
		countIgnored = true,
		enable = function(frame, state)
			frame.Fader.MinAlpha = state or MIN_ALPHA
		end
	},
	MaxAlpha = {
		countIgnored = true,
		enable = function(frame, state)
			frame.Fader.MaxAlpha = state or MAX_ALPHA
		end
	},
	Smooth = {countIgnored = true},
	DelayAlpha = {countIgnored = true},
	Delay = {countIgnored = true},
}

if oUF.isRetail then
	tinsert(options.Casting.events, 'UNIT_SPELLCAST_EMPOWER_START')
	tinsert(options.Casting.events, 'UNIT_SPELLCAST_EMPOWER_STOP')
	options.DynamicFlight = {
		enable = function(frame)
			frame:RegisterEvent('PLAYER_IS_GLIDING_CHANGED', Update, true)
		end,
		events = {'PLAYER_IS_GLIDING_CHANGED'}
	}
end

if not oUF.isClassic then
	options.Focus = {
		enable = function(frame)
			frame:RegisterEvent('PLAYER_FOCUS_CHANGED', Update, true)
		end,
		events = {'PLAYER_FOCUS_CHANGED'}
	}
end

if oUF.isRetail or oUF.isWrath or oUF.isMists then
	options.Vehicle = {
		enable = function(frame)
			frame:RegisterEvent('UNIT_ENTERED_VEHICLE', Update, true)
			frame:RegisterEvent('UNIT_EXITED_VEHICLE', Update, true)
		end,
		events = {'UNIT_ENTERED_VEHICLE','UNIT_EXITED_VEHICLE'}
	}
end

local function CountOption(element, state, oldState)
	if state and not oldState then
		element.count = (element.count or 0) + 1
	elseif oldState and element.count and not state then
		element.count = element.count - 1
	end
end

local function SetOption(element, opt, state)
	local option = ((opt == 'UnitTarget' or opt == 'PlayerTarget') and 'Target') or opt
	local oldState = element[opt]

	if opt == 'InstanceDifficulty' then
		element.InstancedCached = nil -- clear the cached value
	end

	if option and options[option] and (oldState ~= state) then
		element[opt] = state

		if state then
			if type(state) == 'table' and opt ~= 'InstanceDifficulty' then
				state.__faderelement = element
				element.__owner.__faderobject = state
			end

			if options[option].enable then
				options[option].enable(element.__owner, state)
			end
		else
			if options[option].events and next(options[option].events) then
				for _, event in ipairs(options[option].events) do
					element.__owner:UnregisterEvent(event, Update)
				end
			end

			if options[option].disable then
				options[option].disable(element.__owner)
			end
		end

		if not options[option].countIgnored then
			CountOption(element, state, oldState)
		end
	end
end

local function Enable(frame)
	local element = frame.Fader
	if element then
		element.__owner = frame
		element.ForceUpdate = ForceUpdate
		element.SetOption = SetOption
		element.ClearTimers = ClearTimers

		element.MinAlpha = MIN_ALPHA
		element.MaxAlpha = MAX_ALPHA

		return true
	end
end

local function Disable(frame)
	local element = frame.Fader
	if element then
		for opt in pairs(options) do
			if opt == 'Target' then
				element:SetOption('UnitTarget')
				element:SetOption('PlayerTarget')
			else
				element:SetOption(opt)
			end
		end

		element.count = nil
		element:ClearTimers()
	end
end

oUF:AddElement('Fader', nil, Enable, Disable)
