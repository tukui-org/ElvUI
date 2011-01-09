--[[
	Original codebase:
		oUF_Castbar by starlon.
		http://svn.wowace.com/wowace/trunk/oUF_Castbar/
--]]
local parent, ns = ...
local oUF = ns.oUF

local UnitName = UnitName
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local UNIT_SPELLCAST_START = function(self, event, unit, spell)
	if(self.unit ~= unit) then return end

	local castbar = self.Castbar
	local name, _, text, texture, startTime, endTime, _, castid, interrupt = UnitCastingInfo(unit)
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

	castbar:SetMinMaxValues(0, max)
	castbar:SetValue(0)

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
	end

	--- XXX: 1.6: Kill the rank field.
	if(castbar.PostCastStart) then
		castbar:PostCastStart(unit, name, nil, castid)
	end
	castbar:Show()
end

local UNIT_SPELLCAST_FAILED = function(self, event, unit, spellname, _, castid)
	if(self.unit ~= unit) then return end

	local castbar = self.Castbar
	if(castbar.castid ~= castid) then
		return
	end

	castbar.casting = nil
	castbar.interrupt = nil
	castbar:SetValue(0)
	castbar:Hide()

	--- XXX: 1.6: Kill the rank field.
	if(castbar.PostCastFailed) then
		return castbar:PostCastFailed(unit, spellname, nil, castid)
	end
end

local UNIT_SPELLCAST_INTERRUPTED = function(self, event, unit, spellname, _, castid)
	if(self.unit ~= unit) then return end

	local castbar = self.Castbar
	if(castbar.castid ~= castid) then
		return
	end
	castbar.casting = nil
	castbar.channeling = nil

	castbar:SetValue(0)
	castbar:Hide()

	--- XXX: 1.6: Kill the rank field.
	if(castbar.PostCastInterrupted) then
		return castbar:PostCastInterrupted(unit, spellname, nil, castid)
	end
end

local UNIT_SPELLCAST_INTERRUPTIBLE = function(self, event, unit)
	if(self.unit ~= unit) then return end

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
	if(self.unit ~= unit) then return end

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
	if(self.unit ~= unit) then return end

	local name, _, text, texture, startTime, endTime = UnitCastingInfo(unit)
	if(not startTime) then return end

	local castbar = self.Castbar
	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	castbar.delay = castbar.delay + castbar.duration - duration
	castbar.duration = duration

	castbar:SetValue(duration)

	--- XXX: 1.6: Kill the rank field.
	if(castbar.PostCastDelayed) then
		return castbar:PostCastDelayed(unit, name, nil, castid)
	end
end

local UNIT_SPELLCAST_STOP = function(self, event, unit, spellname, _, castid)
	if(self.unit ~= unit) then return end

	local castbar = self.Castbar
	if(castbar.castid ~= castid) then
		return
	end

	castbar.casting = nil
	castbar.interrupt = nil
	castbar:SetValue(0)
	castbar:Hide()

	--- XXX: 1.6: Kill the rank field.
	if(castbar.PostCastStop) then
		return castbar:PostCastStop(unit, spellname, nil, castid)
	end
end

local UNIT_SPELLCAST_CHANNEL_START = function(self, event, unit, spellname)
	if(self.unit ~= unit) then return end

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
	castbar.channeling = true
	castbar.interrupt = interrupt

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
	end

	--- XXX: 1.6: Kill the rank field.
	if(castbar.PostChannelStart) then castbar:PostChannelStart(unit, name) end
	castbar:Show()
end

local UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, event, unit, spellname)
	if(self.unit ~= unit) then return end

	local name, _, text, texture, startTime, endTime, oldStart = UnitChannelInfo(unit)
	if(not name) then
		return
	end

	local castbar = self.Castbar
	local duration = (endTime / 1000) - GetTime()

	castbar.delay = castbar.delay + castbar.duration - duration
	castbar.duration = duration
	castbar.max = (endTime - startTime) / 1000

	castbar:SetMinMaxValues(0, castbar.max)
	castbar:SetValue(duration)

	--- XXX: 1.6: Kill the rank field.
	if(castbar.PostChannelUpdate) then
		return castbar:PostChannelUpdate(unit, name)
	end
end

local UNIT_SPELLCAST_CHANNEL_STOP = function(self, event, unit, spellname)
	if(self.unit ~= unit) then return end

	local castbar = self.Castbar
	if(castbar:IsShown()) then
		castbar.channeling = nil
		castbar.interrupt = nil

		castbar:SetValue(castbar.max)
		castbar:Hide()

		--- XXX: 1.6: Kill the rank field.
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

		if(self.SafeZone) then
			local width = self:GetWidth()
			local _, _, ms = GetNetStats()
			-- MADNESS!
			local safeZonePercent = (width / self.max) * (ms / 1e5)
			if(safeZonePercent > 1) then safeZonePercent = 1 end
			self.SafeZone:SetWidth(width * safeZonePercent)
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

		if(self.SafeZone) then
			local width = self:GetWidth()
			local _, _, ms = GetNetStats()
			-- MADNESS!
			local safeZonePercent = (width / self.max) * (ms / 1e5)
			if(safeZonePercent > 1) then safeZonePercent = 1 end
			self.SafeZone:SetWidth(width * safeZonePercent)
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
			object:RegisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
			object:RegisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
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

		if(not castbar:GetStatusBarTexture()) then
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
		object:UnregisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
		object:UnregisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
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

oUF:AddElement('Castbar', Update, Enable, Disable)
