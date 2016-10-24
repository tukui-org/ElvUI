--[[ Element: Castbar

 Handles updating and visibility of unit castbars.

 Widget

 Castbar - A StatusBar to represent spell progress.

 Sub-Widgets

 .Text     - A FontString to represent spell name.
 .Icon     - A Texture to represent spell icon.
 .Time     - A FontString to represent spell duration.
 .Shield   - A Texture to represent if it's possible to interrupt or spell
             steal.
 .SafeZone - A Texture to represent latency.

 Options

 .timeToHold - A Number to indicate for how many seconds the castbar should be
               visible after a _FAILED or _INTERRUPTED event. Defaults to 0.

 Credits

 Based upon oUF_Castbar by starlon.

 Notes

 The default texture will be applied if the UI widget doesn't have a texture or
 color defined.

 Examples

   -- Position and size
   local Castbar = CreateFrame("StatusBar", nil, self)
   Castbar:SetSize(20, 20)
   Castbar:SetPoint('TOP')
   Castbar:SetPoint('LEFT')
   Castbar:SetPoint('RIGHT')
   
   -- Add a background
   local Background = Castbar:CreateTexture(nil, 'BACKGROUND')
   Background:SetAllPoints(Castbar)
   Background:SetTexture(1, 1, 1, .5)
   
   -- Add a spark
   local Spark = Castbar:CreateTexture(nil, "OVERLAY")
   Spark:SetSize(20, 20)
   Spark:SetBlendMode("ADD")
   
   -- Add a timer
   local Time = Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
   Time:SetPoint("RIGHT", Castbar)
   
   -- Add spell text
   local Text = Castbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
   Text:SetPoint("LEFT", Castbar)
   
   -- Add spell icon
   local Icon = Castbar:CreateTexture(nil, "OVERLAY")
   Icon:SetSize(20, 20)
   Icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT")
   
   -- Add Shield
   local Shield = Castbar:CreateTexture(nil, "OVERLAY")
   Shield:SetSize(20, 20)
   Shield:SetPoint("CENTER", Castbar)
   
   -- Add safezone
   local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
   
   -- Register it with oUF
   self.Castbar = Castbar
   self.Castbar.bg = Background
   self.Castbar.Spark = Spark
   self.Castbar.Time = Time
   self.Castbar.Text = Text
   self.Castbar.Icon = Icon
   self.Castbar.SafeZone = SafeZone

 Hooks and Callbacks

]]
local _, ns = ...
local oUF = ns.oUF

local GetNetStats = GetNetStats
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local tradeskillCurrent, tradeskillTotal, mergeTradeskill = 0, 0, false

local updateSafeZone = function(self)
	local sz = self.SafeZone
	local width = self:GetWidth()
	local _, _, _, ms = GetNetStats()

	-- Guard against GetNetStats returning latencies of 0.
	if(ms ~= 0) then
		-- MADNESS!
		local safeZonePercent = (width / self.max) * (ms / 1e5)
		if(safeZonePercent > 1) then safeZonePercent = 1 end
		sz:SetWidth(width * safeZonePercent)
		sz:Show()
	else
		sz:Hide()
	end
end

local UNIT_SPELLCAST_SENT = function (self, event, unit, spell, rank, target, castid)
	local castbar = self.Castbar
	castbar.curTarget = (target and target ~= "") and target or nil

	if castbar.isTradeSkill then
		castbar.tradeSkillCastId = castid
	end
end

local UNIT_SPELLCAST_START = function(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, text, texture, startTime, endTime, isTradeSkill, castid, notInterruptible, spellid = UnitCastingInfo(unit)
	if(not name) then
		return castbar:Hide()
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = endTime - startTime

	castbar.castid = castid
	castbar.duration = GetTime() - startTime
	castbar.max = max
	castbar.delay = 0
	castbar.casting = true
	castbar.interrupt = notInterruptible -- NOTE: deprecated; to be removed
	castbar.notInterruptible = notInterruptible
	castbar.holdTime = 0
	castbar.isTradeSkill = isTradeSkill

	if(mergeTradeskill and isTradeSkill and UnitIsUnit(unit, "player")) then
		castbar.duration = castbar.duration + (castbar.max * tradeskillCurrent);
		castbar.max = max * tradeskillTotal;

		if(unit == "player") then
			tradeskillCurrent = tradeskillCurrent + 1;
		end
		castbar:SetValue(castbar.duration)
	else
		castbar:SetValue(0)		
	end
	castbar:SetValue(0)

	castbar:SetMinMaxValues(0, castbar.max)

	if(castbar.Text) then castbar.Text:SetText(text) end
	if(castbar.Icon) then castbar.Icon:SetTexture(texture) end
	if(castbar.Time) then castbar.Time:SetText() end

	local shield = castbar.Shield
	if(shield and notInterruptible) then
		shield:Show()
	elseif(shield) then
		shield:Hide()
	end

	local sf = castbar.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint'RIGHT'
		sf:SetPoint'TOP'
		sf:SetPoint'BOTTOM'
		updateSafeZone(castbar)
	end

	if(castbar.PostCastStart) then
		castbar:PostCastStart(unit, name, castid, spellid)
	end	
	castbar:Show()
end

local UNIT_SPELLCAST_FAILED = function(self, event, unit, spellname, _, castid, spellid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if (castbar.castid ~= castid) and (castbar.tradeSkillCastId ~= castid) then
		return
	end

	if(mergeTradeskill and UnitIsUnit(unit, "player")) then
		mergeTradeskill = false;
		castbar.tradeSkillCastId = nil
	end

	local text = castbar.Text
	if(text) then
		text:SetText(FAILED)
	end

	castbar.casting = nil
	castbar.interrupt = nil -- NOTE: deprecated; to be removed
	castbar.notInterruptible = nil
	castbar.holdTime = castbar.timeToHold or 0

	if(castbar.PostCastFailed) then
		return castbar:PostCastFailed(unit, spellname, castid, spellid)
	end
end

local UNIT_SPELLCAST_FAILED_QUIET = function(self, event, unit, spellname, _, castid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if (castbar.castid ~= castid) and (castbar.tradeSkillCastId ~= castid) then
		return
	end

	if(mergeTradeskill and UnitIsUnit(unit, "player")) then
		mergeTradeskill = false;
		castbar.tradeSkillCastId = nil
	end
	
	castbar.casting = nil
	castbar.interrupt = nil -- NOTE: deprecated; to be removed
	castbar.notInterruptible = nil
	castbar:SetValue(0)
	castbar:Hide()
end

local UNIT_SPELLCAST_INTERRUPTED = function(self, event, unit, spellname, _, castid, spellid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if (castbar.castid ~= castid) then
		return
	end

	local text = castbar.Text
	if(text) then
		text:SetText(INTERRUPTED)
	end

	castbar.casting = nil
	castbar.channeling = nil
	castbar.holdTime = castbar.timeToHold or 0

	if(castbar.PostCastInterrupted) then
		return castbar:PostCastInterrupted(unit, spellname, castid, spellid)
	end
end

local UNIT_SPELLCAST_INTERRUPTIBLE = function(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local shield = castbar.Shield
	if(shield) then
		shield:Hide()
	end

	castbar.interrupt = nil -- NOTE: deprecated; to be removed
	castbar.notInterruptible = nil

	if(castbar.PostCastInterruptible) then
		return castbar:PostCastInterruptible(unit)
	end
end

local UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local shield = castbar.Shield
	if(shield) then
		shield:Show()
	end

	castbar.interrupt = nil -- NOTE: deprecated; to be removed
	castbar.notInterruptible = nil

	if(castbar.PostCastNotInterruptible) then
		return castbar:PostCastNotInterruptible(unit)
	end
end

local UNIT_SPELLCAST_DELAYED = function(self, event, unit, _, _, _, spellid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, _, _, startTime, _, _, castid = UnitCastingInfo(unit)
	if(not startTime or not castbar:IsShown()) then return end

	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	castbar.delay = castbar.delay + castbar.duration - duration
	castbar.duration = duration

	castbar:SetValue(duration)

	if(castbar.PostCastDelayed) then
		return castbar:PostCastDelayed(unit, name, castid, spellid)
	end
end

local UNIT_SPELLCAST_STOP = function(self, event, unit, spellname, _, castid, spellid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if (castbar.castid ~= castid) then
		return
	end

	if(mergeTradeskill and UnitIsUnit(unit, "player")) then
		if(tradeskillCurrent == tradeskillTotal) then
			mergeTradeskill = false;
		end
	else
		castbar.casting = nil
		castbar.interrupt = nil -- NOTE: deprecated; to be removed
		castbar.notInterruptible = nil
	end

	if(castbar.PostCastStop) then
		return castbar:PostCastStop(unit, spellname, castid, spellid)
	end
end

local UNIT_SPELLCAST_CHANNEL_START = function(self, event, unit, _, _, _, spellid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
	if(not name) then
		return
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = (endTime - startTime)
	local duration = endTime - GetTime()

	castbar.duration = duration
	castbar.max = max
	castbar.delay = 0
	castbar.startTime = startTime
	castbar.endTime = endTime
	castbar.extraTickRatio = 0
	castbar.channeling = true
	castbar.interrupt = notInterruptible -- NOTE: deprecated; to be removed
	castbar.notInterruptible = notInterruptible
	castbar.holdTime = 0

	-- We have to do this, as it's possible for spell casts to never have _STOP
	-- executed or be fully completed by the OnUpdate handler before CHANNEL_START
	-- is called.
	castbar.casting = nil
	castbar.castid = nil

	castbar:SetMinMaxValues(0, max)
	castbar:SetValue(duration)

	if(castbar.Text) then castbar.Text:SetText(name) end
	if(castbar.Icon) then castbar.Icon:SetTexture(texture) end
	if(castbar.Time) then castbar.Time:SetText() end

	local shield = castbar.Shield
	if(shield and notInterruptible) then
		shield:Show()
	elseif(shield) then
		shield:Hide()
	end

	local sf = castbar.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint'LEFT'
		sf:SetPoint'TOP'
		sf:SetPoint'BOTTOM'
		updateSafeZone(castbar)
	end

	if(castbar.PostChannelStart) then castbar:PostChannelStart(unit, name, spellid) end
	castbar:Show()
end

local UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, event, unit, _, _, _, spellid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, _, _, startTime, endTime = UnitChannelInfo(unit)
	if(not name or not castbar:IsShown()) then
		return
	end

	local duration = (endTime / 1000) - GetTime()
	local startDelay = castbar.startTime - startTime / 1000
	castbar.startTime = startTime / 1000
	castbar.endTime = endTime / 1000
	castbar.delay = castbar.delay + startDelay
	
	castbar.duration = duration
	castbar.max = (endTime - startTime) / 1000

	castbar:SetMinMaxValues(0, castbar.max)
	castbar:SetValue(duration)

	if(castbar.PostChannelUpdate) then
		return castbar:PostChannelUpdate(unit, name, spellid)
	end
end

local UNIT_SPELLCAST_CHANNEL_STOP = function(self, event, unit, spellname, _, _, spellid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if(castbar:IsShown()) then
		castbar.channeling = nil
		castbar.interrupt = nil -- NOTE: deprecated; to be removed
		castbar.notInterruptible = nil

		if(castbar.PostChannelStop) then
			return castbar:PostChannelStop(unit, spellname, spellid)
		end
	end
end

local onUpdate = function(self, elapsed)
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
					self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if(self.Spark) then
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
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
					self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)
		if(self.Spark) then
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
		end
	elseif(self.holdTime > 0) then
		self.holdTime = self.holdTime - elapsed
	else
		self.casting = nil
		self.castid = nil
		self.channeling = nil

		self:Hide()
	end
end

local Update = function(self, ...)
	UNIT_SPELLCAST_START(self, ...)
	return UNIT_SPELLCAST_CHANNEL_START(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local castbar = self.Castbar

	if(castbar) then
		castbar.__owner = self
		castbar.ForceUpdate = ForceUpdate

		if(not (unit and unit:match'%wtarget$')) then
			self:RegisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT, true)
			self:RegisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
			self:RegisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
			self:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET", UNIT_SPELLCAST_FAILED_QUIET)
			self:RegisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
			self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
			self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
			self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
			self:RegisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)
		end

		castbar.holdTime = 0
		castbar:SetScript("OnUpdate", castbar.OnUpdate or onUpdate)

		if(self.unit == "player") then
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame.Show = CastingBarFrame.Hide
			CastingBarFrame:Hide()

			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame.Show = PetCastingBarFrame.Hide
			PetCastingBarFrame:Hide()
		end

		if(castbar:IsObjectType'StatusBar' and not castbar:GetStatusBarTexture()) then
			castbar:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		local spark = castbar.Spark
		if(spark and spark:IsObjectType'Texture' and not spark:GetTexture()) then
			spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
		end

		local shield = castbar.Shield
		if(shield and shield:IsObjectType'Texture' and not shield:GetTexture()) then
			shield:SetTexture[[Interface\CastingBar\UI-CastingBar-Small-Shield]]
		end

		local sz = castbar.SafeZone
		if(sz and sz:IsObjectType'Texture' and not sz:GetTexture()) then
			sz:SetColorTexture(1, 0, 0)
		end

		castbar:Hide()

		return true
	end
end

local Disable = function(self)
	local castbar = self.Castbar

	if(castbar) then
		castbar:Hide()
		self:UnregisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT)
		self:UnregisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
		self:UnregisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
		self:UnregisterEvent("UNIT_SPELLCAST_FAILED_QUIET", UNIT_SPELLCAST_FAILED_QUIET)
		self:UnregisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
		self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
		self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
		self:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
		self:UnregisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)

		castbar:SetScript("OnUpdate", nil)
	end
end

hooksecurefunc(C_TradeSkillUI, "CraftRecipe", function(_, num)
	tradeskillCurrent = 0
	tradeskillTotal = num or 1
	mergeTradeskill = true
end)

oUF:AddElement('Castbar', Update, Enable, Disable)