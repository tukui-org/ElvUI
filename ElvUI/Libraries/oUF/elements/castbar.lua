--[[
# Element: Castbar

Handles the visibility and updating of spell castbars.
Based upon oUF_Castbar by starlon.

## Widget

Castbar - A `StatusBar` to represent spell cast/channel progress.

## Sub-Widgets

.Text     - A `FontString` to represent spell name.
.Icon     - A `Texture` to represent spell icon.
.Time     - A `FontString` to represent spell duration.
.Shield   - A `Texture` to represent if it's possible to interrupt or spell steal.
.SafeZone - A `Texture` to represent latency.

## Notes

A default texture will be applied to the StatusBar and Texture widgets if they don't have a texture or a color set.

## Options

.timeToHold - indicates for how many seconds the castbar should be visible after a _FAILED or _INTERRUPTED
              event. Defaults to 0 (number)

## Attributes

.castID           - a globally unique identifier of the currently cast spell (string?)
.casting          - indicates whether the current spell is an ordinary cast (boolean)
.channeling       - indicates whether the current spell is a channeled cast (boolean)
.notInterruptible - indicates whether the current spell is interruptible (boolean)
.spellID          - the spell identifier of the currently cast/channeled spell (number)

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
    Background:SetTexture(1, 1, 1, .5)

    -- Add a spark
    local Spark = Castbar:CreateTexture(nil, 'OVERLAY')
    Spark:SetSize(20, 20)
    Spark:SetBlendMode('ADD')

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

local GetNetStats = GetNetStats
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local tradeskillCurrent, tradeskillTotal, mergeTradeskill = 0, 0, false -- ElvUI

local function updateSafeZone(self)
	local safeZone = self.SafeZone
	local width = self:GetWidth()
	local _, _, _, ms = GetNetStats()

	local safeZoneRatio = (ms / 1e3) / self.max
	if(safeZoneRatio > 1) then
		safeZoneRatio = 1
	end

	safeZone:SetWidth(width * safeZoneRatio)
end

-- ElvUI block
local UNIT_SPELLCAST_SENT = function (self, event, unit, target, castID, spellID)
	local castbar = self.Castbar
	castbar.curTarget = (target and target ~= "") and target or nil

	if castbar.isTradeSkill then
		castbar.tradeSkillCastId = castID
	end
end
-- end block

local function UNIT_SPELLCAST_START(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit) -- ElvUI adds isTradeSkill
	if(not name) then
		return element:Hide()
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = endTime - startTime

	element.castID = castID
	element.duration = GetTime() - startTime
	element.max = max
	element.delay = 0
	element.casting = true
	element.notInterruptible = notInterruptible
	element.holdTime = 0
	element.spellID = spellID

	-- ElvUI block
	element.isTradeSkill = isTradeSkill

	if(mergeTradeskill and isTradeSkill and UnitIsUnit(unit, "player")) then
		element.duration = element.duration + (element.max * tradeskillCurrent);
		element.max = max * tradeskillTotal;

		if(unit == "player") then
			tradeskillCurrent = tradeskillCurrent + 1;
		end

		element:SetValue(element.duration)
	else
		element:SetValue(0)
	end
	element:SetMinMaxValues(0, element.max)
	-- end block

	if(element.Text) then element.Text:SetText(text) end
	if(element.Icon) then element.Icon:SetTexture(texture) end
	if(element.Time) then element.Time:SetText() end

	local shield = element.Shield
	if(shield and notInterruptible) then
		shield:Show()
	elseif(shield) then
		shield:Hide()
	end

	local sf = element.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint(element:GetReverseFill() and 'LEFT' or 'RIGHT')
		sf:SetPoint('TOP')
		sf:SetPoint('BOTTOM')
		updateSafeZone(element)
	end

	--[[ Callback: Castbar:PostCastStart(unit, name)
	Called after the element has been updated upon a spell cast start.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	* name - name of the spell being cast (string)
	--]]
	if(element.PostCastStart) then
		element:PostCastStart(unit, name)
	end
	element:Show()
end

local function UNIT_SPELLCAST_FAILED(self, event, unit, castID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element.castID ~= castID) then
		return
	end

	-- ElvUI block
	if(mergeTradeskill and UnitIsUnit(unit, "player")) then
		mergeTradeskill = false;
		element.tradeSkillCastId = nil
	end
	-- end block

	local text = element.Text
	if(text) then
		text:SetText(FAILED)
	end

	element.casting = nil
	element.notInterruptible = nil
	element.holdTime = element.timeToHold or 0

	--[[ Callback: Castbar:PostCastFailed(unit)
	Called after the element has been updated upon a failed spell cast.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	--]]
	if(element.PostCastFailed) then
		return element:PostCastFailed(unit)
	end
end

-- ElvUI block
local UNIT_SPELLCAST_FAILED_QUIET = function(self, event, unit, castID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if (castbar.castID ~= castID) and (castbar.tradeSkillCastId ~= castID) then
		return
	end

	if(mergeTradeskill and UnitIsUnit(unit, "player")) then
		mergeTradeskill = false;
		castbar.tradeSkillCastId = nil
	end

	castbar.casting = nil
	castbar.notInterruptible = nil
	castbar:SetValue(0)
	castbar:Hide()
end
-- end block

local function UNIT_SPELLCAST_INTERRUPTED(self, event, unit, castID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element.castID ~= castID) then
		return
	end

	local text = element.Text
	if(text) then
		text:SetText(INTERRUPTED)
	end

	element.casting = nil
	element.channeling = nil
	element.holdTime = element.timeToHold or 0

	--[[ Callback: Castbar:PostCastInterrupted(unit)
	Called after the element has been updated upon an interrupted spell cast.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	--]]
	if(element.PostCastInterrupted) then
		return element:PostCastInterrupted(unit)
	end
end

local function UNIT_SPELLCAST_INTERRUPTIBLE(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local shield = element.Shield
	if(shield) then
		shield:Hide()
	end

	element.notInterruptible = nil

	--[[ Callback: Castbar:PostCastInterruptible(unit)
	Called after the element has been updated when a spell cast has become interruptible.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	--]]
	if(element.PostCastInterruptible) then
		return element:PostCastInterruptible(unit)
	end
end

local function UNIT_SPELLCAST_NOT_INTERRUPTIBLE(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local shield = element.Shield
	if(shield) then
		shield:Show()
	end

	element.notInterruptible = true

	--[[ Callback: Castbar:PostCastNotInterruptible(unit)
	Called after the element has been updated when a spell cast has become non-interruptible.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	--]]
	if(element.PostCastNotInterruptible) then
		return element:PostCastNotInterruptible(unit)
	end
end

local function UNIT_SPELLCAST_DELAYED(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, startTime = UnitCastingInfo(unit)
	if(not startTime or not element:IsShown()) then return end

	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	element.delay = element.delay + element.duration - duration
	element.duration = duration

	element:SetValue(duration)

	--[[ Callback: Castbar:PostCastDelayed(unit, name)
	Called after the element has been updated when a spell cast has been delayed.

	* self - the Castbar widget
	* unit - unit that the update has been triggered (string)
	* name - name of the delayed spell (string)
	--]]
	if(element.PostCastDelayed) then
		return element:PostCastDelayed(unit, name)
	end
end

local function UNIT_SPELLCAST_STOP(self, event, unit, castID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element.castID ~= castID) then
		return
	end

	-- ElvUI block
	if(mergeTradeskill and UnitIsUnit(unit, "player")) then
		if(tradeskillCurrent == tradeskillTotal) then
			mergeTradeskill = false;
		end
	else
		element.casting = nil
		element.notInterruptible = nil
	end
	-- end block

	--[[ Callback: Castbar:PostCastStop(unit)
	Called after the element has been updated when a spell cast has finished.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	--]]
	if(element.PostCastStop) then
		return element:PostCastStop(unit)
	end
end

local function UNIT_SPELLCAST_CHANNEL_START(self, event, unit, _, spellID)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
	if(not name) then
		return
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = (endTime - startTime)
	local duration = endTime - GetTime()

	element.duration = duration
	element.max = max
	element.delay = 0
	element.channeling = true
	element.notInterruptible = notInterruptible
	element.holdTime = 0
	element.spellID = spellID

	-- ElvUI block
	element.startTime = startTime
	element.endTime = endTime
	element.extraTickRatio = 0
	-- end block

	-- We have to do this, as it's possible for spell casts to never have _STOP
	-- executed or be fully completed by the OnUpdate handler before CHANNEL_START
	-- is called.
	element.casting = nil
	element.castID = nil

	element:SetMinMaxValues(0, max)
	element:SetValue(duration)

	if(element.Text) then element.Text:SetText(name) end
	if(element.Icon) then element.Icon:SetTexture(texture) end
	if(element.Time) then element.Time:SetText() end

	local shield = element.Shield
	if(shield and notInterruptible) then
		shield:Show()
	elseif(shield) then
		shield:Hide()
	end

	local sf = element.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint(element:GetReverseFill() and 'RIGHT' or 'LEFT')
		sf:SetPoint('TOP')
		sf:SetPoint('BOTTOM')
		updateSafeZone(element)
	end

	--[[ Callback: Castbar:PostChannelStart(unit, name)
	Called after the element has been updated upon a spell channel start.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	* name - name of the channeled spell (string)
	--]]
	if(element.PostChannelStart) then
		element:PostChannelStart(unit, name)
	end
	element:Show()
end

local function UNIT_SPELLCAST_CHANNEL_UPDATE(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	local name, _, _, startTime, endTime = UnitChannelInfo(unit)
	if(not name or not element:IsShown()) then
		return
	end

	local duration = (endTime / 1000) - GetTime()

	element.delay = element.delay + element.duration - duration
	element.duration = duration
	element.max = (endTime - startTime) / 1000

	-- ElvUI block
	element.startTime = startTime / 1000
	element.endTime = endTime / 1000
	-- end block

	element:SetMinMaxValues(0, element.max)
	element:SetValue(duration)

	--[[ Callback: Castbar:PostChannelUpdate(unit, name)
	Called after the element has been updated after a channeled spell has been delayed or interrupted.

	* self - the Castbar widget
	* unit - unit for which the update has been triggered (string)
	* name - name of the channeled spell (string)
	--]]
	if(element.PostChannelUpdate) then
		return element:PostChannelUpdate(unit, name)
	end
end

local function UNIT_SPELLCAST_CHANNEL_STOP(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local element = self.Castbar
	if(element:IsShown()) then
		element.channeling = nil
		element.notInterruptible = nil

		--[[ Callback: Castbar:PostChannelStop(unit)
		Called after the element has been updated after a channeled spell has been completed.

		* self - the Castbar widget
		* unit - unit for which the update has been triggered (string)
		--]]
		if(element.PostChannelStop) then
			return element:PostChannelStop(unit)
		end
	end
end

local function onUpdate(self, elapsed)
	if(self.casting) then
		local duration = self.duration + elapsed
		if(duration >= self.max) then
			self.casting = nil
			self:Hide()

			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000-%.1f|r', duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText('%.1f', duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if(self.Spark) then
			local horiz = self.horizontal
			local size = self[horiz and 'GetWidth' or 'GetHeight'](self)

			local offset = (duration / self.max) * size
			if(self:GetReverseFill()) then
				offset = size - offset
			end

			self.Spark:SetPoint('CENTER', self, horiz and 'LEFT' or 'BOTTOM', horiz and offset or 0, horiz and 0 or offset)
		end
	elseif(self.channeling) then
		local duration = self.duration - elapsed

		if(duration <= 0) then
			self.channeling = nil
			self:Hide()

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText('%.1f|cffff0000-%.1f|r', duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText('%.1f', duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)
		if(self.Spark) then
			local horiz = self.horizontal
			local size = self[horiz and 'GetWidth' or 'GetHeight'](self)

			local offset = (duration / self.max) * size
			if(self:GetReverseFill()) then
				offset = size - offset
			end

			self.Spark:SetPoint('CENTER', self, horiz and 'LEFT' or 'BOTTOM', horiz and offset or 0, horiz and 0 or offset)
		end
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed
	else
		self.casting = nil
		self.castID = nil
		self.channeling = nil

		self:Hide()
	end
end

local function Update(self, ...)
	UNIT_SPELLCAST_START(self, ...)
	return UNIT_SPELLCAST_CHANNEL_START(self, ...)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Castbar
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if(not (unit and unit:match'%wtarget$')) then
			self:RegisterEvent('UNIT_SPELLCAST_START', UNIT_SPELLCAST_START)
			self:RegisterEvent('UNIT_SPELLCAST_FAILED', UNIT_SPELLCAST_FAILED)
			self:RegisterEvent('UNIT_SPELLCAST_STOP', UNIT_SPELLCAST_STOP)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED', UNIT_SPELLCAST_INTERRUPTED)
			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', UNIT_SPELLCAST_INTERRUPTIBLE)
			self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
			self:RegisterEvent('UNIT_SPELLCAST_DELAYED', UNIT_SPELLCAST_DELAYED)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', UNIT_SPELLCAST_CHANNEL_START)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', UNIT_SPELLCAST_CHANNEL_UPDATE)
			self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', UNIT_SPELLCAST_CHANNEL_STOP)
			-- ElvUI block
			self:RegisterEvent('UNIT_SPELLCAST_SENT', UNIT_SPELLCAST_SENT, true)
			self:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET", UNIT_SPELLCAST_FAILED_QUIET)
			-- end block
		end

		element.horizontal = element:GetOrientation() == 'HORIZONTAL'
		element.holdTime = 0
		element:SetScript('OnUpdate', element.OnUpdate or onUpdate)

		if(self.unit == 'player') then
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame.Show = CastingBarFrame.Hide
			CastingBarFrame:Hide()

			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame.Show = PetCastingBarFrame.Hide
			PetCastingBarFrame:Hide()
		end

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

		self:UnregisterEvent('UNIT_SPELLCAST_START', UNIT_SPELLCAST_START)
		self:UnregisterEvent('UNIT_SPELLCAST_FAILED', UNIT_SPELLCAST_FAILED)
		self:UnregisterEvent('UNIT_SPELLCAST_STOP', UNIT_SPELLCAST_STOP)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED', UNIT_SPELLCAST_INTERRUPTED)
		self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE', UNIT_SPELLCAST_INTERRUPTIBLE)
		self:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
		self:UnregisterEvent('UNIT_SPELLCAST_DELAYED', UNIT_SPELLCAST_DELAYED)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', UNIT_SPELLCAST_CHANNEL_START)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', UNIT_SPELLCAST_CHANNEL_UPDATE)
		self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', UNIT_SPELLCAST_CHANNEL_STOP)
		-- ElvUI block
		self:UnregisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT)
		self:UnregisterEvent("UNIT_SPELLCAST_FAILED_QUIET", UNIT_SPELLCAST_FAILED_QUIET)
		-- end block

		element:SetScript('OnUpdate', nil)
	end
end

-- ElvUI block
hooksecurefunc(C_TradeSkillUI, "CraftRecipe", function(_, num)
	tradeskillCurrent = 0
	tradeskillTotal = num or 1
	mergeTradeskill = true
end)
-- end block

oUF:AddElement('Castbar', Update, Enable, Disable)
