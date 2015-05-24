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
local parent, ns = ...
local oUF = ns.oUF

local UnitName = UnitName
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

local UNIT_SPELLCAST_START = function(self, event, unit, spell)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, text, texture, startTime, endTime, isTradeSkill, castid, interrupt = UnitCastingInfo(unit)
	if(not name) then
		castbar:Hide()
		return
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = endTime - startTime

	castbar.castid = castid
	castbar.duration = GetTime() - startTime
	castbar.max = max
	castbar.delay = 0
	castbar.casting = true
	castbar.interrupt = interrupt
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

	castbar:SetMinMaxValues(0, castbar.max)

	if(castbar.Text) then castbar.Text:SetText(text) end
	if(castbar.Icon) then castbar.Icon:SetTexture(texture) end
	if(castbar.Time) then castbar.Time:SetText() end

	local shield = castbar.Shield
	if(shield and interrupt) then
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
		castbar:PostCastStart(unit, name, castid)
	end	
	castbar:Show()
end

local UNIT_SPELLCAST_FAILED = function(self, event, unit, spellname, _, castid)
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
	castbar.interrupt = nil
	castbar:SetValue(0)
	castbar:Hide()

	if(castbar.PostCastFailed) then
		return castbar:PostCastFailed(unit, spellname, castid)
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
	castbar.interrupt = nil
	castbar:SetValue(0)
	castbar:Hide()
end

local UNIT_SPELLCAST_INTERRUPTED = function(self, event, unit, spellname, _, castid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if (castbar.castid ~= castid) then
		return
	end

	castbar.casting = nil
	castbar.channeling = nil

	castbar:SetValue(0)
	castbar:Hide()

	if(castbar.PostCastInterrupted) then
		return castbar:PostCastInterrupted(unit, spellname, castid)
	end
end

local UNIT_SPELLCAST_INTERRUPTIBLE = function(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local shield = self.Castbar.Shield
	if(shield) then
		shield:Hide()
	end

	local castbar = self.Castbar
	if(castbar.PostCastInterruptible) then
		return castbar:PostCastInterruptible(unit)
	end
end

local UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(self, event, unit)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local shield = self.Castbar.Shield
	if(shield) then
		shield:Show()
	end

	local castbar = self.Castbar
	if(castbar.PostCastNotInterruptible) then
		return castbar:PostCastNotInterruptible(unit)
	end
end

local UNIT_SPELLCAST_DELAYED = function(self, event, unit, spellname, _, castid)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, text, texture, startTime, endTime = UnitCastingInfo(unit)
	if(not startTime or not castbar:IsShown()) then return end

	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	castbar.delay = castbar.delay + castbar.duration - duration
	castbar.duration = duration

	castbar:SetValue(duration)

	if(castbar.PostCastDelayed) then
		return castbar:PostCastDelayed(unit, name, castid)
	end
end

local UNIT_SPELLCAST_STOP = function(self, event, unit, spellname, _, castid)
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
		castbar.interrupt = nil
		castbar:SetValue(0)
		castbar:Hide()
	end

	if(castbar.PostCastStop) then
		return castbar:PostCastStop(unit, spellname, castid)
	end
end

local UNIT_SPELLCAST_CHANNEL_START = function(self, event, unit, spellname)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, text, texture, startTime, endTime, isTrade, interrupt = UnitChannelInfo(unit)
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
	castbar.interrupt = interrupt

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
	if(shield and interrupt) then
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

	if(castbar.PostChannelStart) then castbar:PostChannelStart(unit, name) end
	castbar:Show()
end

local UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, event, unit, spellname)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, text, texture, startTime, endTime, oldStart = UnitChannelInfo(unit)
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
		return castbar:PostChannelUpdate(unit, name)
	end
end

local UNIT_SPELLCAST_CHANNEL_STOP = function(self, event, unit, spellname)
	if(self.unit ~= unit and self.realUnit ~= unit) then return end

	local castbar = self.Castbar
	if(castbar:IsShown()) then
		castbar.channeling = nil
		castbar.interrupt = nil

		castbar:SetValue(castbar.max)
		castbar:Hide()

		if(castbar.PostChannelStop) then
			return castbar:PostChannelStop(unit, spellname)
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
	else
		self.unitName = nil
		self.casting = nil
		self.castid = nil
		self.channeling = nil

		self:SetValue(1)
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

local Enable = function(object, unit)
	local castbar = object.Castbar

	if(castbar) then
		castbar.__owner = object
		castbar.ForceUpdate = ForceUpdate

		if(not (unit and unit:match'%wtarget$')) then
			object:RegisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT)
			object:RegisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
			object:RegisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
			object:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET", UNIT_SPELLCAST_FAILED_QUIET)
			object:RegisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
			object:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
			object:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
			object:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
			object:RegisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)
		end

		castbar:SetScript("OnUpdate", castbar.OnUpdate or onUpdate)

		if(object.unit == "player") then
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame.Show = CastingBarFrame.Hide
			CastingBarFrame:Hide()
		elseif(object.unit == 'pet') then
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
			sz:SetTexture(1, 0, 0)
		end

		castbar:Hide()

		return true
	end
end

local Disable = function(object, unit)
	local castbar = object.Castbar

	if(castbar) then
		object:UnregisterEvent("UNIT_SPELLCAST_SENT", UNIT_SPELLCAST_SENT)
		object:UnregisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
		object:UnregisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
		object:UnregisterEvent("UNIT_SPELLCAST_FAILED_QUIET", UNIT_SPELLCAST_FAILED_QUIET)
		object:UnregisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
		object:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
		object:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
		object:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
		object:UnregisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)

		castbar:SetScript("OnUpdate", nil)
	end
end

hooksecurefunc("DoTradeSkill", function(index, num, ...)
	tradeskillCurrent = 0
	tradeskillTotal = tonumber(num) or 1
	mergeTradeskill = true
end)

oUF:AddElement('Castbar', Update, Enable, Disable)