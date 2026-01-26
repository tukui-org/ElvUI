--[[
# Element: Castbar

Handles the visibility and updating of spell castbars.

## Widget

Castbar - A `StatusBar` to represent spell cast/channel progress.

## Sub-Widgets

.Icon     - A `Texture` to represent spell icon.
.SafeZone - A `Texture` to represent latency.
.Shield   - A `Texture` to represent if it's possible to interrupt or spell steal.
.Spark    - A `Texture` to represent the castbar's edge.
.Text     - A `FontString` to represent spell name.
.Time     - A `FontString` to represent spell duration.

## Notes

A default texture will be applied to the StatusBar and Texture widgets if they don't have a texture or a color set.

## Options

.timeToHold      - Indicates for how many seconds the castbar should be visible after a _FAILED or _INTERRUPTED
                   event. Defaults to 0 (number)
.hideTradeSkills - Makes the element ignore casts related to crafting professions (boolean)
.smoothing       - Which status bar smoothing method to use, defaults to `Enum.StatusBarInterpolation.Immediate` (number)

## Attributes

.castID           - A unique identifier of the currently cast spell (number?)
.casting          - Indicates whether the current spell is an ordinary cast (boolean)
.channeling       - Indicates whether the current spell is a channeled cast (boolean)
.empowering       - Indicates whether the current spell is an empowering cast (boolean)
.notInterruptible - Indicates whether the current spell is interruptible (boolean)
.spellID          - The spell identifier of the currently cast/channeled/empowering spell (number)
.spellName        - The name of the spell currently being cast/channeled/empowered (string)

## Examples

    -- Position and size
    local Castbar = CreateFrame('StatusBar', nil, self)
    Castbar:SetSize(20, 20)
    Castbar:SetPoint('TOP')
    Castbar:SetPoint('LEFT')
    Castbar:SetPoint('RIGHT')

    -- Add a background
    local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Castbar)
    Background:SetColorTexture(1, 1, 1, .5)

    -- Add a spark
    local Spark = Castbar:CreateTexture(nil, 'OVERLAY')
    Spark:SetSize(20, 20)
    Spark:SetBlendMode('ADD')
    Spark:SetPoint('CENTER', Castbar:GetStatusBarTexture(), 'RIGHT', 0, 0)

    -- Add a timer
    local Time = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Time:SetPoint('RIGHT', Castbar)

    -- Add spell text
    local Text = Castbar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    Text:SetPoint('LEFT', Castbar)

    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, 'OVERLAY')
    Icon:SetSize(20, 20)
    Icon:SetPoint('TOPLEFT', Castbar, 'TOPLEFT')

    -- Add Shield
    local Shield = Castbar:CreateTexture(nil, 'OVERLAY')
    Shield:SetSize(20, 20)
    Shield:SetPoint('CENTER', Castbar)

    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')

    -- Register it with oUF
    Castbar.bg = Background
    Castbar.Spark = Spark
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.Shield = Shield
    Castbar.SafeZone = SafeZone
    self.Castbar = Castbar
--]]

local _, ns = ...
local oUF = ns.oUF

local FALLBACK_ICON = 136243 -- Interface\ICONS\Trade_Engineering
local FAILED = _G.FAILED or 'Failed'
local INTERRUPTED = _G.INTERRUPTED or 'Interrupted'

local next = next

local GetTime = GetTime
local CreateFrame = CreateFrame
local GetNetStats = GetNetStats
local UnitIsUnit = UnitIsUnit
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitChannelDuration = UnitChannelDuration
local UnitCastingDuration = UnitCastingDuration
local UnitEmpoweredChannelDuration = UnitEmpoweredChannelDuration
local UnitEmpoweredStagePercentages = UnitEmpoweredStagePercentages
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

local StatusBarTimerDirection = Enum.StatusBarTimerDirection
local StatusBarInterpolation = Enum.StatusBarInterpolation

local tradeskillCurrent, tradeskillTotal, mergeTradeskill = 0, 0, false
local specialAuras = {} -- ms modifier
local specialCast = {} -- ms duration
if oUF.isClassic or oUF.isTBC then
	specialCast[2643] = 500 -- Multishot R1
	specialCast[14288] = 500 -- Multishot R2
	specialCast[14289] = 500 -- Multishot R3
	specialCast[14290] = 500 -- Multishot R4
	specialCast[25294] = 500 -- Multishot R5
	specialCast[27021] = 500 -- Multishot R6
	specialCast[19434] = 3000 -- Aimed Shot R1
	specialCast[20900] = 3000 -- Aimed Shot R2
	specialCast[20901] = 3000 -- Aimed Shot R3
	specialCast[20902] = 3000 -- Aimed Shot R4
	specialCast[20903] = 3000 -- Aimed Shot R5
	specialCast[20904] = 3000 -- Aimed Shot R6
	specialCast[27065] = 3000 -- Aimed Shot R7

	specialAuras[3045] = 0.4 -- Rapid Fire: 40%
	specialAuras[6150] = 0.3 -- Quick Shots [Improved Hawk]: 30%
	specialAuras[26635] = 0.3 -- Berserking [Troll Racial]: 10% to 30%
end

local function SpecialActive(frame, event, unit)
	if not next(specialAuras) then return end

	local speed = 1
	for spellID in next, specialAuras do
		local aura = GetPlayerAuraBySpellID(spellID)
		if aura then
			if spellID == 26635 then -- Berserking [Troll Racial]
				local current = UnitHealth(unit)
				local maximum = UnitHealthMax(unit)
				local health = current / maximum

				if health <= 0.4 then
					speed = speed - 0.3 -- 30% at 40% health or lower
				elseif health >= 1 then
					speed = speed - 0.1 -- 10% at max health
				else -- linearly interpolate between 10% to 30% for health between 40% to 100%
					speed = speed - (0.1 + (0.2 * (1 - health)) / 0.6) -- 0.2 is speed range (0.3 - 0.1), 0.6 is health range (1 - 0.4)
				end
			else
				speed = speed - specialAuras[spellID]
			end

			if speed <= 0.6 then -- fastest speed
				return speed
			end
		end
	end

	return speed -- we have to check the entire table for stacking
end

local function resetAttributes(self)
	self.castID = nil
	self.casting = nil
	self.channeling = nil
	self.empowering = nil
	self.isTradeSkill = nil
	self.notInterruptible = nil
	self.spellID = nil
	self.spellName = nil
	self.tradeSkillCastID = nil

	for _, pip in next, self.Pips do
		pip:Hide()
	end
end

local function UpdateCurrentTarget(element, target)
	element.curTarget = (oUF:NotSecretValue(target) and (target and target ~= "") and target) or nil
end

local function CreatePip(element)
	return CreateFrame('Frame', nil, element, 'CastingBarFrameStagePipTemplate')
end

local function UpdatePips(element, stages)
	local isHoriz = element:GetOrientation() == 'HORIZONTAL'
	local elementSize = isHoriz and element:GetWidth() or element:GetHeight()

	local lastOffset = 0
	for stage, stageSection in next, stages do
		local offset = lastOffset + (elementSize * stageSection)
		lastOffset = offset

		local pip = element.Pips[stage]
		if(not pip) then
			--[[ Override: Castbar:CreatePip(stage)
			Creates a "pip" for the given stage, used for empowered casts.

			* self  - the Castbar widget
			* stage - the empowered stage for which the pip should be created (number)

			## Returns

			* pip - a frame used to depict an empowered stage boundary, typically with a line texture (frame)
			--]]
			pip = (element.CreatePip or CreatePip) (element, stage)
			element.Pips[stage] = pip
		end

		pip:ClearAllPoints()
		pip:Show()

		if(isHoriz) then
			if(pip.RotateTextures) then
				pip:RotateTextures(0)
			end

			if(element:GetReverseFill()) then
				pip:SetPoint('TOP', element, 'TOPRIGHT', -offset, 0)
				pip:SetPoint('BOTTOM', element, 'BOTTOMRIGHT', -offset, 0)
			else
				pip:SetPoint('TOP', element, 'TOPLEFT', offset, 0)
				pip:SetPoint('BOTTOM', element, 'BOTTOMLEFT', offset, 0)
			end
		else
			if(pip.RotateTextures) then
				pip:RotateTextures(1.5708)
			end

			if(element:GetReverseFill()) then
				pip:SetPoint('LEFT', element, 'TOPLEFT', 0, -offset)
				pip:SetPoint('RIGHT', element, 'TOPRIGHT', 0, -offset)
			else
				pip:SetPoint('LEFT', element, 'BOTTOMLEFT', 0, offset)
				pip:SetPoint('RIGHT', element, 'BOTTOMRIGHT', 0, offset)
			end
		end

		-- ElvUI block
		if element.PostUpdatePip then
			element:PostUpdatePip(pip, stage, stages)
		end
		-- end block
	end

	--[[ Callback: Castbar:PostUpdatePips(stages)
	Called after the element has updated stage separators (pips) in an empowered cast.

	* self   - the Castbar widget
	* stages - stages with percentage of each stage (table)
	--]]
	if(element.PostUpdatePips) then
		element:PostUpdatePips(stages)
	end
end

local function CastMatch(element, castID)
	return element.castID == castID
end

--[[ Override: Castbar:ShouldShow(unit)
Handles check for which unit the castbar should show for.
Defaults to the object unit.
* self - the Castbar widget
* unit - the unit for which the update has been triggered (string)
--]]
local function ShouldShow(element, unit)
	return element.__owner.unit == unit
end

local function CastStart(self, event, unit, castGUID, spellID, castTime)
	local element = self.Castbar
	if not (element.ShouldShow or ShouldShow) (element, unit) then
		return
	end

	local real, castDuration = event
	local name, text, texture, startTime, endTime, isTradeSkill, isEmpowered, castID, barID, notInterruptible, _
	if spellID and event == 'UNIT_SPELLCAST_SENT' then
		name, _, texture, castDuration = oUF:GetSpellInfo(spellID)
		event = 'UNIT_SPELLCAST_START'

		if name then
			if castDuration and castDuration ~= 0 then
				castTime = castDuration -- prefer duration time, otherwise use the static duration
			end

			local speedMod = SpecialActive(self, real, unit)
			if speedMod then
				castTime = castTime * speedMod
			end

			castID = castGUID
			startTime = GetTime() * 1000
			endTime = startTime + castTime
		end
	elseif event == 'UNIT_SPELLCAST_START' then
		if oUF.isRetail then
			name, text, texture, startTime, endTime, isTradeSkill, _, notInterruptible, spellID, barID = UnitCastingInfo(unit)
			castID = barID -- because of secrets
		else
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit)
		end
	elseif event == 'UNIT_SPELLCAST_EMPOWER_START' or event == 'UNIT_SPELLCAST_CHANNEL_START' then
		name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, isEmpowered, _, castID = UnitChannelInfo(unit)

		-- if castID == castTime then
		----- BUG: Dream Breath maybe others have double start events (?)
		-- end
	else -- try both API when its forced
		if oUF.isRetail then
			name, text, texture, startTime, endTime, isTradeSkill, _, notInterruptible, spellID, barID = UnitCastingInfo(unit)

			castID = barID -- because of secrets
		else
			name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit)
		end

		event = 'UNIT_SPELLCAST_START'

		if not name then
			name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, isEmpowered, _, castID = UnitChannelInfo(unit)
		end
	end

	if not name or (isTradeSkill and element.hideTradeSkills) then
		if real ~= 'PLAYER_TARGET_CHANGED' or element.holdTime <= 0 then
			resetAttributes(element)
			element:Hide()
		end

		return
	end

	element.casting = event == 'UNIT_SPELLCAST_START'
	element.channeling = event == 'UNIT_SPELLCAST_CHANNEL_START'
	element.empowering = isEmpowered

	local isPlayer = UnitIsUnit(unit, 'player')
	if not isPlayer or (real ~= 'UNIT_SPELLCAST_SENT' and real ~= 'UNIT_SPELLCAST_START' and real ~= 'UNIT_SPELLCAST_CHANNEL_START') then
		UpdateCurrentTarget(element) -- we want to ignore the start events on player unit because sent adds the target info
	end

	element.delay = 0
	element.notInterruptible = notInterruptible
	element.holdTime = 0
	element.castID = castID
	element.spellID = spellID
	element.spellName = name

	-- ElvUI block
	local stages = isEmpowered and UnitEmpoweredStagePercentages(unit) or nil

	element.isTradeSkill = isTradeSkill
	element.tradeSkillCastID = (isTradeSkill and castID) or nil
	element.stages = stages
	-- end block

	-- Use new timer API when available (Retail), fall back to manual tracking for Classic
	if oUF.isRetail then
		if oUF:NotSecretValue(startTime) then
			element.startTime = startTime / 1000

			if(element.empowering) then
				element.endTime = (endTime + GetUnitEmpowerHoldAtMaxTime(unit)) / 1000
			else
				element.endTime = endTime / 1000
			end

			-- Calculate max for CustomTimeText compatibility
			element.max = element.endTime - element.startTime
		else
			element.startTime = nil
			element.endTime = nil
			element.max = nil
		end

		local duration = element.empowering and UnitEmpoweredChannelDuration(unit) or (element.channeling and UnitChannelDuration(unit) or UnitCastingDuration(unit))
		if duration then
			local direction = element.channeling and StatusBarTimerDirection.RemainingTime or StatusBarTimerDirection.ElapsedTime
			element:SetTimerDuration(duration, element.smoothing or StatusBarInterpolation.Immediate, direction)
		end
	else
		if element.empowering then
			endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
		end

		endTime = endTime * 0.001
		startTime = startTime * 0.001

		element.max = endTime - startTime
		element.startTime = startTime

		if element.channeling then
			element.duration = endTime - GetTime()
		else
			element.duration = GetTime() - startTime
		end

		-- ElvUI block
		if mergeTradeskill and isPlayer and isTradeSkill then
			element.duration = element.duration + (element.max * tradeskillCurrent)
			element.max = element.max * tradeskillTotal
			element.holdTime = 1

			tradeskillCurrent = tradeskillCurrent + 1
		end
		-- end block

		element:SetMinMaxValues(0, element.max)

		if element.SetValue_ then
			element:SetValue_(element.duration)
		else
			element:SetValue(element.duration)
		end
	end

	if(element.Shield and oUF.isRetail) then
		if(element.Shield.SetAlphaFromBoolean) then
			element.Shield:SetAlphaFromBoolean(notInterruptible, 1, 0)
		else
			element.Shield:SetShown(notInterruptible)
		end
	end

	if(element.Icon) then element.Icon:SetTexture(texture or FALLBACK_ICON) end
	if(element.Spark) then element.Spark:Show() end
	if(element.Text) then element.Text:SetText(text) end
	if(element.Time) then element.Time:SetText('') end

	local safeZone = element.SafeZone
	if(safeZone) then
		local isHoriz = element:GetOrientation() == 'HORIZONTAL'

		safeZone:ClearAllPoints()
		safeZone:SetPoint(isHoriz and 'TOP' or 'LEFT')
		safeZone:SetPoint(isHoriz and 'BOTTOM' or 'RIGHT')

		if(element.channeling) then
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'RIGHT' or 'TOP') or (isHoriz and 'LEFT' or 'BOTTOM'))
		else
			safeZone:SetPoint(element:GetReverseFill() and (isHoriz and 'LEFT' or 'BOTTOM') or (isHoriz and 'RIGHT' or 'TOP'))
		end

		if element.max then
			local _, _, _, worldPing = GetNetStats()
			local ratio = (worldPing * 0.001) / element.max
			if ratio > 1 then
				ratio = 1
			end

			local getSize = element[isHoriz and 'GetWidth' or 'GetHeight']
			local setSize = safeZone[isHoriz and 'SetWidth' or 'SetHeight']
			setSize(safeZone, getSize(element) * ratio)
		end
	end

	if(element.empowering) then
		--[[ Override: Castbar:UpdatePips(stages)
		Handles updates for stage separators (pips) in an empowered cast.
		* self   - the Castbar widget
		* stages - stages with percentage of each stage (table)
		--]]
		(element.UpdatePips or UpdatePips) (element, stages)
	end

	--[[ Callback: Castbar:PostCastStart(unit)
	Called after the element has been updated upon a spell cast or channel start.

	* self - the Castbar widget
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostCastStart) then
		element:PostCastStart(unit)
	end

	element:Show()
end

local function CastUpdate(self, event, unit, ...)
	local element = self.Castbar
	if not (element.ShouldShow or ShouldShow) (element, unit) then
		return
	end

	local castID, _
	if oUF.isRetail then
		_, _, castID = ...
	else
		castID = ...
	end

	if not element:IsShown() or not CastMatch(element, castID) then
		return
	end

	local name, startTime, endTime, _
	if(event == 'UNIT_SPELLCAST_DELAYED') then
		name, _, _, startTime, endTime = UnitCastingInfo(unit)
	else
		name, _, _, startTime, endTime = UnitChannelInfo(unit)
	end

	if(not name) then return end

	-- Use new timer API when available (Retail), fall back to manual tracking for Classic
	if oUF.isRetail then
		if oUF:NotSecretValue(startTime) then
			if(element.empowering) then
				endTime = (endTime + GetUnitEmpowerHoldAtMaxTime(unit)) / 1000
			else
				endTime = endTime / 1000
			end

			startTime = startTime / 1000

			-- Update max for CustomTimeText compatibility
			element.max = endTime - startTime
			element.startTime = startTime
			element.endTime = endTime
		else
			element.startTime = nil
			element.endTime = nil
			element.max = nil
		end

		local duration = element.empowering and UnitEmpoweredChannelDuration(unit) or (element.channeling and UnitChannelDuration(unit) or UnitCastingDuration(unit))
		if duration then
			local direction = element.channeling and StatusBarTimerDirection.RemainingTime or StatusBarTimerDirection.ElapsedTime
			element:SetTimerDuration(duration, element.smoothing or StatusBarInterpolation.Immediate, direction)
		end
	else
		if(element.empowering) then
			endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
		end

		endTime = endTime * 0.001
		startTime = startTime * 0.001

		local delta
		if(element.channeling) then
			delta = element.startTime - startTime

			element.duration = endTime - GetTime()
		else
			delta = startTime - element.startTime

			element.duration = GetTime() - startTime
		end

		if(delta < 0) then
			delta = 0
		end

		element.max = endTime - startTime
		element.startTime = startTime
		element.delay = element.delay + delta

		element:SetMinMaxValues(0, element.max)

		if element.SetValue_ then
			element:SetValue_(element.duration)
		else
			element:SetValue(element.duration)
		end
	end

	--[[ Callback: Castbar:PostCastUpdate(unit)
	Called after the element has been updated when a spell cast or channel has been updated.

	* self - the Castbar widget
	* unit - the unit that the update has been triggered (string)
	--]]
	if(element.PostCastUpdate) then
		return element:PostCastUpdate(unit)
	end
end

local function CastStop(self, event, unit, ...)
	local element = self.Castbar
	if not (element.ShouldShow or ShouldShow) (element, unit) then
		return
	end

	local castID, spellID, interruptedBy, empowerComplete, _
	if oUF.isRetail then
		if(event == 'UNIT_SPELLCAST_STOP') then
			_, _, castID = ...
		elseif(event == 'UNIT_SPELLCAST_EMPOWER_STOP') then
			_, _, empowerComplete, interruptedBy, castID = ...
		elseif(event == 'UNIT_SPELLCAST_CHANNEL_STOP') then
			_, _, interruptedBy, castID = ...
		end
	else
		castID, spellID = ...
	end

	if not element:IsShown() or not CastMatch(element, castID) then
		return
	end

	local isPlayer = UnitIsUnit(unit, 'player')
	if mergeTradeskill and isPlayer and (tradeskillCurrent == tradeskillTotal) then
		mergeTradeskill = false
	end

	if(interruptedBy) then
		if(element.Text) then
			element.Text:SetText(INTERRUPTED)
		end

		element.holdTime = element.timeToHold or 0

		-- force filled castbar
		element:SetMinMaxValues(0, 1)
		element:SetValue(1)

		--[[ Callback: Castbar:PostCastInterrupted(unit, interruptedBy)
		Called after the element has been updated when a spell cast or channel has stopped.

		* self          - the Castbar widget
		* unit          - the unit for which the update has been triggered (string)
		* interruptedBy - GUID of whomever interrupted the cast (string)
		--]]
		if(element.PostCastInterrupted) then
			element:PostCastInterrupted(unit, spellID, interruptedBy)
		end
	else
		--[[ Callback: Castbar:PostCastStop(unit[, empowerComplete])
		Called after the element has been updated when a spell cast or channel has stopped.

		* self            - the Castbar widget
		* unit            - the unit for which the update has been triggered (string)
		* empowerComplete - if the empowered cast was complete (boolean?)
		--]]
		if(element.PostCastStop) then
			element:PostCastStop(unit, spellID, empowerComplete)
		end
	end

	resetAttributes(element)
end

local function CastFail(self, event, unit, ...)
	local element = self.Castbar
	if not (element.ShouldShow or ShouldShow) (element, unit) then
		return
	end

	local castID, interruptedBy, _
	if oUF.isRetail then
		if(event == 'UNIT_SPELLCAST_INTERRUPTED') then
			_, _, interruptedBy, castID = ...
		elseif(event == 'UNIT_SPELLCAST_FAILED') then
			_, _, castID = ...
		end
	else
		castID = ...
	end

	if not element:IsShown() or not CastMatch(element, castID) then
		return
	end

	if(element.Text) then
		element.Text:SetText(event == 'UNIT_SPELLCAST_FAILED' and FAILED or INTERRUPTED)
	end

	if(element.Spark) then element.Spark:Hide() end

	element.holdTime = element.timeToHold or 0

	local isPlayer = UnitIsUnit(unit, 'player')
	if mergeTradeskill and isPlayer then
		mergeTradeskill = false
	end

	-- force filled castbar
	element:SetMinMaxValues(0, 1)
	element:SetValue(1)

	if(interruptedBy) then
		if(element.PostCastInterrupted) then
			element:PostCastInterrupted(unit, element.spellID, interruptedBy)
		end
	else
		--[[ Callback: Castbar:PostCastFail(unit)
		Called after the element has been updated upon a failed or interrupted spell cast.

		* self - the Castbar widget
		* unit - the unit for which the update has been triggered (string)
		--]]
		if(element.PostCastFail) then
			element:PostCastFail(unit)
		end
	end

	resetAttributes(element)
end

local function CastInterruptible(self, event, unit)
	local element = self.Castbar
	if not (element.ShouldShow or ShouldShow) (element, unit) then
		return
	end

	if not element:IsShown() then
		return
	end

	element.notInterruptible = event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE'

	if(element.Shield and oUF.isRetail) then
		if(element.Shield.SetAlphaFromBoolean) then
			element.Shield:SetAlphaFromBoolean(element.notInterruptible, 1, 0)
		else
			element.Shield:SetShown(element.notInterruptible)
		end
	end

	--[[ Callback: Castbar:PostCastInterruptible(unit)
	Called after the element has been updated when a spell cast has become interruptible or uninterruptible.

	* self - the Castbar widget
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostCastInterruptible) then
		return element:PostCastInterruptible(unit)
	end
end

-- ElvUI block
local UNIT_SPELLCAST_SENT = function (self, event, unit, target, castID, spellID)
	UpdateCurrentTarget(self.Castbar, target)

	local castTime = specialCast[spellID]
	if castTime then
		CastStart(self, event, unit, castID, spellID, castTime)
	end
end
-- ElvUI block

local function OnUpdateStage(element)
	if element.UpdatePipStep then
		local maxStage = 0
		local stageValue = element.duration * 1000
		for stage in next, element.stages do
			local step = element.stagePoints[stage]
			if not step or stageValue < step then
				break
			else
				maxStage = stage
			end
		end

		if maxStage ~= element.curStage then
			element:UpdatePipStep(maxStage)

			element.curStage = maxStage
		end
	end
end

local function onUpdate(self, elapsed)
	if(self.casting or self.channeling or self.empowering) then
		local duration, durationObject

		if oUF.isRetail then -- Use new timer API when available (Retail), fall back to manual tracking for Classic
			durationObject = self:GetTimerDuration() -- can be nil

			if durationObject then
				duration = durationObject:GetRemainingDuration()

				self.duration = duration
			end
		else
			local isCasting = self.casting or self.empowering
			if(isCasting) then
				duration = self.duration + elapsed

				self.duration = duration

				if(duration >= self.max) then
					local spellID = self.spellID

					resetAttributes(self)
					self:Hide()

					if(self.PostCastStop) then
						self:PostCastStop(self.__owner.unit, spellID)
					end

					return
				end
			else
				duration = self.duration - elapsed

				self.duration = duration

				if(duration <= 0) then
					local spellID = self.spellID

					resetAttributes(self)
					self:Hide()

					if(self.PostCastStop) then
						self:PostCastStop(self.__owner.unit, spellID)
					end

					return
				end
			end
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				--[[ Override: Castbar:CustomDelayText(duration)
				Used to completely override the updating of the .Time sub-widget when there is a delay to adjust for.

				* self     - the Castbar widget
				* duration - a [Duration](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject) object for the Castbar
				--]]

				if(self.CustomDelayText) then
					self:CustomDelayText(duration, durationObject)
				else
					self.Time:SetFormattedText('%.1f|cffff0000%s%.2f|r', duration or 0, (self.casting or self.empowering) and '+' or '-', self.delay)
				end
			else
				--[[ Override: Castbar:CustomTimeText(duration)
				Used to completely override the updating of the .Time sub-widget.

				* self     - the Castbar widget
				* duration - a [Duration](https://warcraft.wiki.gg/wiki/ScriptObject_DurationObject) object for the Castbar
				--]]

				if(self.CustomTimeText) then
					self:CustomTimeText(duration, durationObject)
				else
					self.Time:SetFormattedText('%.1f', duration or 0)
				end
			end
		end

		-- ISSUE: we have no way to get this information any more, Blizzard is aware
		--[[
		if(self.empowering) then
			OnUpdateStage(self)
		end
		]]

		if not oUF.isRetail then
			if self.SetValue_ then
				self:SetValue_(duration)
			else
				self:SetValue(duration)
			end
		end
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed

		-- force filled castbar
		self:SetMinMaxValues(0, 1)
		self:SetValue(1)

		if(self.Time) then
			self.Time:SetText('')
		end
	else
		resetAttributes(self)
		self:Hide()
	end
end

local function Update(...)
	CastStart(...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Castbar
	if(element and unit and not unit:match('%wtarget$')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_SPELLCAST_START', CastStart)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
		self:RegisterEvent('UNIT_SPELLCAST_STOP', CastStop)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
		self:RegisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
		self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
		self:RegisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
		self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', CastInterruptible)
		self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', CastInterruptible)

		if oUF.isRetail then
			self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_START', CastStart)
			self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_STOP', CastStop)
			self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_UPDATE', CastUpdate)
		end

		-- ElvUI block
		self:RegisterEvent('UNIT_SPELLCAST_SENT', UNIT_SPELLCAST_SENT, true)
		-- end block

	element.holdTime = 0
	element.Pips = element.Pips or {}

	if(not element.smoothing) then
		element.smoothing = StatusBarInterpolation and StatusBarInterpolation.Immediate or nil
	end

	element:SetScript('OnUpdate', element.OnUpdate or onUpdate)

	if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
		element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	end

	local spark = element.Spark
	if(spark and spark:IsObjectType('Texture') and not spark:GetTexture()) then
		spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	end

	local shield = element.Shield
	if(shield and shield:IsObjectType('Texture') and not shield:GetTexture()) then
		shield:SetTexture([[Interface\CastingBar\UI-CastingBar-Small-Shield]])
	end

	local safeZone = element.SafeZone
	if(safeZone and safeZone:IsObjectType('Texture') and not safeZone:GetTexture()) then
		safeZone:SetColorTexture(1, 0, 0)
	end

	element:Hide()

	return true
	end
end

local function Disable(self)
	local element = self.Castbar
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_SPELLCAST_START', CastStart)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', CastStop)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
		self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', CastInterruptible)
		self:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', CastInterruptible)

		if oUF.isRetail then
			self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_START', CastStart)
			self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_STOP', CastStop)
			self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_UPDATE', CastUpdate)
		end

		-- ElvUI block
		self:UnregisterEvent('UNIT_SPELLCAST_SENT', UNIT_SPELLCAST_SENT)
		-- end block

		element:SetScript('OnUpdate', nil)
	end
end

if oUF.isRetail then -- ElvUI
	hooksecurefunc(C_TradeSkillUI, 'CraftRecipe', function(_, num)
		tradeskillCurrent = 0
		tradeskillTotal = num or 1
		mergeTradeskill = true
	end)
end

oUF:AddElement('Castbar', Update, Enable, Disable)
