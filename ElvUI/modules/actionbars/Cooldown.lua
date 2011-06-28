--[[
        An edited lightweight OmniCC for Elvui
                A featureless, 'pure' version of OmniCDB.
                This version should work on absolutely everything, but I've removed pretty much all of the options
--]]
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["actionbar"].enablecd ~= true or IsAddOnLoaded("OmniCC") or IsAddOnLoaded("ncCooldown") then return end

--constants!
OmniCC = true --hack to work around detection from other addons for OmniCC
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

--configuration settings
local FONT_FACE = C["media"].font --what font to use
local FONT_SIZE = 20 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 2.5 --the minimum duration to show cooldown text for
local EXPIRING_DURATION = C["actionbar"].treshold --the minimum number of seconds a cooldown must be to use to display in the expiring format


local EXPIRING_FORMAT = E.RGBToHex(unpack(C["actionbar"].expiringcolor))..'%.1f|r' --format for timers that are soon to expire
local SECONDS_FORMAT = E.RGBToHex(unpack(C["actionbar"].secondscolor))..'%d|r' --format for timers that have seconds remaining
local MINUTES_FORMAT = E.RGBToHex(unpack(C["actionbar"].minutescolor))..'%dm|r' --format for timers that have minutes remaining
local HOURS_FORMAT = E.RGBToHex(unpack(C["actionbar"].hourscolor))..'%dh|r' --format for timers that have hours remaining
local DAYS_FORMAT = E.RGBToHex(unpack(C["actionbar"].dayscolor))..'%dh|r' --format for timers that have days remaining

--local bindings!
local floor = math.floor
local min = math.min
local GetTime = GetTime

--returns both what text to display, and how long until the next update
local function getTimeText(s)
	--format text as seconds when below a minute
	if s < MINUTEISH then
		local seconds = tonumber(E.Round(s))
		if seconds > EXPIRING_DURATION then
			return SECONDS_FORMAT, seconds, s - (seconds - 0.51)
		else
			return EXPIRING_FORMAT, s, 0.051
		end
	--format text as minutes when below an hour
	elseif s < HOURISH then
		local minutes = tonumber(E.Round(s/MINUTE))
		return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	--format text as hours when below a day
	elseif s < DAYISH then
		local hours = tonumber(E.Round(s/HOUR))
		return HOURS_FORMAT, hours, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	--format text as days
	else
		local days = tonumber(E.Round(s/DAY))
		return DAYS_FORMAT, days,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

--stops the timer
local function Timer_Stop(self)
	self.enabled = nil
	self:Hide()
end

--forces the given timer to update on the next frame
local function Timer_ForceUpdate(self)
	self.nextUpdate = 0
	self:Show()
end

--adjust font size whenever the timer's parent size changes
--hide if it gets too tiny
local function Timer_OnSizeChanged(self, width, height)
	local fontScale = E.Round(width) / ICON_SIZE
	if fontScale == self.fontScale then
		return
	end

	self.fontScale = fontScale
	if fontScale < MIN_SCALE then
		self:Hide()
	else
		self.text:SetFont(FONT_FACE, fontScale * FONT_SIZE, 'OUTLINE')
		self.text:SetShadowColor(0, 0, 0, 0.5)
		self.text:SetShadowOffset(2, -2)
		if self.enabled then
			Timer_ForceUpdate(self)
		end
	end
end

--update timer text, if it needs to be
--hide the timer if done
local function Timer_OnUpdate(self, elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)
		if remain > 0.01 then
			if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
				self.text:SetText('')
				self.nextUpdate  = 1
			else
				local formatStr, time, nextUpdate = getTimeText(remain)
				self.text:SetFormattedText(formatStr, time)
				self.nextUpdate = nextUpdate
			end
		else
			Timer_Stop(self)
		end
	end
end

--returns a new timer object
local function Timer_Create(self)
	--a frame to watch for OnSizeChanged events
	--needed since OnSizeChanged has funny triggering if the frame with the handler is not shown
	local scaler = CreateFrame('Frame', nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame('Frame', nil, scaler); timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript('OnUpdate', Timer_OnUpdate)

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', E.Scale(1), E.Scale(1))
	text:SetJustifyH("CENTER")
	timer.text = text

	Timer_OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript('OnSizeChanged', function(self, ...) Timer_OnSizeChanged(timer, ...) end)

	self.timer = timer
	return timer
end

--hook the SetCooldown method of all cooldown frames
--ActionButton1Cooldown is used here since its likely to always exist
--and I'd rather not create my own cooldown frame to preserve a tiny bit of memory
hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', function(self, start, duration)
	if self.noOCC then return end
	--start timer
	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or Timer_Create(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	--stop timer
	else
		local timer = self.timer
		if timer then
			Timer_Stop(timer)
		end
	end
end)