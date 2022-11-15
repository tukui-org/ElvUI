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

## Attributes

.castID           - A globally unique identifier of the currently cast spell (string?)
.casting          - Indicates whether the current spell is an ordinary cast (boolean)
.channeling       - Indicates whether the current spell is a channeled cast (boolean)
.empowering       - Indicates whether the current spell is an empowering cast (boolean)
.notInterruptible - Indicates whether the current spell is interruptible (boolean)
.spellID          - The spell identifier of the currently cast/channeled/empowering spell (number)

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
local CASTBAR_STAGE_DURATION_INVALID = -1 -- defined in FrameXML/CastingBarFrame.lua

-- ElvUI block
local wipe = wipe
local next = next
local select = select
local CreateFrame = CreateFrame
local GetNetStats = GetNetStats
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitIsUnit = UnitIsUnit
local GetTime = GetTime
local GetUnitEmpowerStageDuration = GetUnitEmpowerStageDuration
local GetUnitEmpowerHoldAtMaxTime = GetUnitEmpowerHoldAtMaxTime

-- GLOBALS: PetCastingBarFrame, PetCastingBarFrame_OnLoad
-- GLOBALS: CastingBarFrame, CastingBarFrame_OnLoad, CastingBarFrame_SetUnit

local tradeskillCurrent, tradeskillTotal, mergeTradeskill = 0, 0, false
local UNIT_SPELLCAST_SENT = function (self, event, unit, target, castID, spellID)
	local castbar = self.Castbar
	castbar.curTarget = (target and target ~= "") and target or nil

	if castbar.isTradeSkill then
		castbar.tradeSkillCastId = castID
	end
end
-- end block

local function resetAttributes(self)
	self.castID = nil
	self.casting = nil
	self.channeling = nil
	self.empowering = nil
	self.notInterruptible = nil
	self.spellID = nil
	self.spellName = nil -- ElvUI

	wipe(self.stagePoints)

	for _, pip in next, self.Pips do
		pip:Hide()
	end
end

local function CreatePip(element)
	return CreateFrame('Frame', nil, element, 'CastingBarFrameStagePipTemplate')
end

local function UpdatePips(element, numStages)
	local stageTotalDuration = 0
	local stageMaxValue = element.max * 1000
	local isHoriz = element:GetOrientation() == 'HORIZONTAL'
	local elementSize = isHoriz and element:GetWidth() or element:GetHeight()
	element.numStages = numStages
	element.curStage = -1 -- dummy

	for stage = 1, numStages do
		local duration
		if(stage > numStages) then
			duration = GetUnitEmpowerHoldAtMaxTime(element.__owner.unit)
		else
			duration = GetUnitEmpowerStageDuration(element.__owner.unit, stage - 1)
		end

		if(duration > CASTBAR_STAGE_DURATION_INVALID) then
			stageTotalDuration = stageTotalDuration + duration
			element.stagePoints[stage] = stageTotalDuration

			local portion = stageTotalDuration / stageMaxValue
			local offset = elementSize * portion

			local pip = element.Pips[stage]
			if(not pip) then
				--[[ Override: Castbar:CreatePip(stage)
				Creates a "pip" for the given stage, used for empowered casts.

				* self - the Castbar widget

				## Returns

				* pip - a frame used to depict an empowered stage boundary, typically with a line texture (frame)
				--]]
				pip = (element.CreatePip or CreatePip) (element, stage)
				element.Pips[stage] = pip
			end

			pip:ClearAllPoints()
			pip:Show()

			if(isHoriz) then
				pip:RotateTextures(0)

				if(element:GetReverseFill()) then
					pip:SetPoint('TOP', element, 'TOPRIGHT', -offset, 0)
					pip:SetPoint('BOTTOM', element, 'BOTTOMRIGHT', -offset, 0)
				else
					pip:SetPoint('TOP', element, 'TOPLEFT', offset, 0)
					pip:SetPoint('BOTTOM', element, 'BOTTOMLEFT', offset, 0)
				end
			else
				pip:RotateTextures(1.5708)

				if(element:GetReverseFill()) then
					pip:SetPoint('LEFT', element, 'TOPLEFT', 0, -offset)
					pip:SetPoint('RIGHT', element, 'TOPRIGHT', 0, -offset)
				else
					pip:SetPoint('LEFT', element, 'BOTTOMLEFT', 0, offset)
					pip:SetPoint('RIGHT', element, 'BOTTOMRIGHT', 0, offset)
				end
			end

			if element.PostUpdatePip then -- ElvUI
				element:PostUpdatePip(pip, stage)
			end
		end
	end
end

local function CastStart(self, real, unit, castGUID)
	if self.unit ~= unit then return end
	if oUF.isRetail and real == 'UNIT_SPELLCAST_START' and not castGUID then return end

	local element = self.Castbar
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit)

	local numStages, _
	local event = 'UNIT_SPELLCAST_START'
	if not name then
		name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(unit)

		event = (numStages and numStages > 0) and 'UNIT_SPELLCAST_EMPOWER_START' or 'UNIT_SPELLCAST_CHANNEL_START'
	end

	if not name or (isTradeSkill and element.hideTradeSkills) then
		resetAttributes(element)
		element:Hide()

		return
	end

	element.casting = event == 'UNIT_SPELLCAST_START'
	element.channeling = event == 'UNIT_SPELLCAST_CHANNEL_START'
	element.empowering = event == 'UNIT_SPELLCAST_EMPOWER_START'

	if element.empowering then
		endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
	end

	endTime = endTime / 1000
	startTime = startTime / 1000

	element.max = endTime - startTime
	element.startTime = startTime
	element.delay = 0

	element.notInterruptible = notInterruptible
	element.holdTime = 0
	element.castID = castID
	element.spellID = spellID
	element.spellName = name -- ElvUI

	if element.channeling then
		element.duration = endTime - GetTime()
	else
		element.duration = GetTime() - startTime
	end

	-- ElvUI block
	if mergeTradeskill and isTradeSkill and UnitIsUnit(unit, "player") then
		element.duration = element.duration + (element.max * tradeskillCurrent)
		element.max = element.max * tradeskillTotal
		element.holdTime = 1

		if unit == 'player' then
			tradeskillCurrent = tradeskillCurrent + 1;
		end
	end
	-- end block

	element:SetMinMaxValues(0, element.max)
	element:SetValue(element.duration)

	if(element.Icon) then element.Icon:SetTexture(texture or FALLBACK_ICON) end
	if(element.Shield) then element.Shield:SetShown(notInterruptible) end
	if(element.Spark) then element.Spark:Show() end
	if(element.Text) then element.Text:SetText(text) end
	if(element.Time) then element.Time:SetText() end

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

		local ratio = (select(4, GetNetStats()) / 1000) / element.max
		if(ratio > 1) then
			ratio = 1
		end

		safeZone[isHoriz and 'SetWidth' or 'SetHeight'](safeZone, element[isHoriz and 'GetWidth' or 'GetHeight'](element) * ratio)
	end

	if(element.empowering) then
		--[[ Override: Castbar:UpdatePips(numStages)
		Handles updates for stage separators (pips) in an empowered cast.

		* self      - the Castbar widget
		* numStages - the number of stages in the current cast (number)
		--]]
		(element.UpdatePips or UpdatePips) (element, numStages)
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

local function CastUpdate(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown() or ((unit == 'player' or oUF.isRetail) and (element.castID ~= castID)) or (oUF.isRetail and (element.spellID ~= spellID))) then
		return
	end

	local name, startTime, endTime, _
	if(event == 'UNIT_SPELLCAST_DELAYED') then
		name, _, _, startTime, endTime = UnitCastingInfo(unit)
	else
		name, _, _, startTime, endTime = UnitChannelInfo(unit)
	end

	if(not name) then return end

	if(element.empowering) then
		endTime = endTime + GetUnitEmpowerHoldAtMaxTime(unit)
	end

	endTime = endTime / 1000
	startTime = startTime / 1000

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
	element:SetValue(element.duration)

	--[[ Callback: Castbar:PostCastUpdate(unit)
	Called after the element has been updated when a spell cast or channel has been updated.

	* self - the Castbar widget
	* unit - the unit that the update has been triggered (string)
	--]]
	if(element.PostCastUpdate) then
		return element:PostCastUpdate(unit)
	end
end

local function CastStop(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown() or ((unit == 'player' or oUF.isRetail) and (element.castID ~= castID)) or (oUF.isRetail and (element.spellID ~= spellID))) then
		return
	end

	-- ElvUI block
	if mergeTradeskill and UnitIsUnit(unit, "player") then
		if tradeskillCurrent == tradeskillTotal then
			mergeTradeskill = false
		end
	end
	-- end block

	resetAttributes(element)

	--[[ Callback: Castbar:PostCastStop(unit, spellID)
	Called after the element has been updated when a spell cast or channel has stopped.

	* self    - the Castbar widget
	* unit    - the unit for which the update has been triggered (string)
	* spellID - the ID of the spell (number)
	--]]
	if(element.PostCastStop) then
		return element:PostCastStop(unit, spellID)
	end
end

local function CastFail(self, event, unit, castID, spellID)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown() or ((unit == 'player' or oUF.isRetail) and (element.castID ~= castID)) or (oUF.isRetail and (element.spellID ~= spellID))) then
		return
	end

	if(element.Text) then
		element.Text:SetText(event == 'UNIT_SPELLCAST_FAILED' and FAILED or INTERRUPTED)
	end

	if(element.Spark) then element.Spark:Hide() end

	element.holdTime = element.timeToHold or 0

	-- ElvUI block
	if mergeTradeskill and UnitIsUnit(unit, "player") then
		mergeTradeskill = false
		element.tradeSkillCastId = nil
	end
	-- end block

	resetAttributes(element)
	element:SetValue(element.max)

	--[[ Callback: Castbar:PostCastFail(unit, spellID)
	Called after the element has been updated upon a failed or interrupted spell cast.

	* self    - the Castbar widget
	* unit    - the unit for which the update has been triggered (string)
	* spellID - the ID of the spell (number)
	--]]
	if(element.PostCastFail) then
		return element:PostCastFail(unit, spellID)
	end
end

local function CastInterruptible(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.Castbar
	if(not element:IsShown()) then return end

	element.notInterruptible = event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE'

	if(element.Shield) then element.Shield:SetShown(element.notInterruptible) end

	--[[ Callback: Castbar:PostCastInterruptible(unit)
	Called after the element has been updated when a spell cast has become interruptible or uninterruptible.

	* self - the Castbar widget
	* unit - the unit for which the update has been triggered (string)
	--]]
	if(element.PostCastInterruptible) then
		return element:PostCastInterruptible(unit)
	end
end

local function OnUpdateStage(element)
	if element.UpdatePipStep then
		local maxStage = 0
		local stageValue = element.duration * 1000
		for i = 1, element.numStages do
			local step = element.stagePoints[i]
			if not step or stageValue < step then
				break
			else
				maxStage = i
			end
		end

		if maxStage ~= element.curStage then
			element:UpdatePipStep(maxStage)

			element.curStage = maxStage
		end
	end
end

local function onUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if(self.casting or self.channeling or self.empowering) then
		local isCasting = self.casting or self.empowering
		if(isCasting) then
			self.duration = self.duration + elapsed
			if(self.duration >= self.max) then
				local spellID = self.spellID

				resetAttributes(self)
				self:Hide()

				if(self.PostCastStop) then
					self:PostCastStop(self.__owner.unit, spellID)
				end

				return
			end
		else
			self.duration = self.duration - elapsed
			if(self.duration <= 0) then
				local spellID = self.spellID

				resetAttributes(self)
				self:Hide()

				if(self.PostCastStop) then
					self:PostCastStop(self.__owner.unit, spellID)
				end

				return
			end
		end

		if(self.Time) and (self.elapsed >= .01) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(self.duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000%s%.2f|r', self.duration, isCasting and '+' or '-', self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(self.duration)
				else
					self.Time:SetFormattedText('%.1f', self.duration)
				end
			end

			if(self.empowering) then
				OnUpdateStage(self)
			end

			self.elapsed = 0
		end

		self:SetValue(self.duration)
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed
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

local LCC, EventFunctions = oUF.isClassic and LibStub('LibClassicCasterino', true), {}

local function Enable(self, unit)
	local element = self.Castbar
	if(element and unit and not unit:match('%wtarget$')) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if LCC then
			local CastbarEventHandler = function(event, ...)
				return EventFunctions[event](self, event, ...)
			end

			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_START', CastbarEventHandler)
			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_DELAYED', CastbarEventHandler)
			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_STOP', CastbarEventHandler)
			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_FAILED', CastbarEventHandler)
			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_INTERRUPTED', CastbarEventHandler)
			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_START', CastbarEventHandler)
			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_UPDATE', CastbarEventHandler)
			LCC.RegisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_STOP', CastbarEventHandler)
		else
			self:RegisterEvent('UNIT_SPELLCAST_START', CastStart)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', CastStop)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
			self:RegisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		end

		if oUF.isRetail then
			self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_START', CastStart)
			self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_STOP', CastStop)
			self:RegisterEvent('UNIT_SPELLCAST_EMPOWER_UPDATE', CastUpdate)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', CastInterruptible)
			self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', CastInterruptible)
		end

		-- ElvUI block
		self:RegisterEvent('UNIT_SPELLCAST_SENT', UNIT_SPELLCAST_SENT, true)
		-- end block

		element.holdTime = 0

		if not element.Pips then
			element.Pips = {}
		end
		if not element.stagePoints then
			element.stagePoints = {}
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

		if LCC then
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_START')
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_DELAYED')
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_STOP')
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_FAILED')
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_INTERRUPTED')
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_START')
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_UPDATE')
			LCC.UnregisterCallback(self, 'UNIT_SPELLCAST_CHANNEL_STOP')
		else
			self:UnregisterEvent('UNIT_SPELLCAST_START', CastStart)
			self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', CastStart)
			self:UnregisterEvent('UNIT_SPELLCAST_STOP', CastStop)
			self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', CastStop)
			self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', CastUpdate)
			self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', CastUpdate)
			self:UnregisterEvent('UNIT_SPELLCAST_FAILED', CastFail)
			self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', CastFail)
		end

		if oUF.isRetail then
			self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_START', CastStart)
			self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_STOP', CastStop)
			self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_UPDATE', CastUpdate)
			self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', CastInterruptible)
			self:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', CastInterruptible)
		end

		element:SetScript('OnUpdate', nil)
	end
end

if LCC then
	UnitCastingInfo = function(unit)
		return LCC:UnitCastingInfo(unit)
	end

	UnitChannelInfo = function(unit)
		return LCC:UnitChannelInfo(unit)
	end

	EventFunctions.UNIT_SPELLCAST_START = CastStart
	EventFunctions.UNIT_SPELLCAST_FAILED = CastFail
	EventFunctions.UNIT_SPELLCAST_INTERRUPTED = CastFail
	EventFunctions.UNIT_SPELLCAST_DELAYED = CastUpdate
	EventFunctions.UNIT_SPELLCAST_STOP = CastStop
	EventFunctions.UNIT_SPELLCAST_CHANNEL_START = CastStart
	EventFunctions.UNIT_SPELLCAST_CHANNEL_UPDATE = CastUpdate
	EventFunctions.UNIT_SPELLCAST_CHANNEL_STOP = CastStop
end

if oUF.isRetail then -- ElvUI
	hooksecurefunc(C_TradeSkillUI, 'CraftRecipe', function(_, num)
		tradeskillCurrent = 0
		tradeskillTotal = num or 1
		mergeTradeskill = true
	end)
end

oUF:AddElement('Castbar', Update, Enable, Disable)
