local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

local MIN_SCALE = 0.5
local MIN_DURATION = 2.5
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times
local FONT_SIZE = 20 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 2.5 --the minimum duration to show cooldown text for
local EXPIRING_DURATION, EXPIRING_FORMAT, SECONDS_FORMAT, MINUTES_FORMAT, HOURS_FORMAT, DAYS_FORMAT

local floor = math.floor
local min = math.min
local GetTime = GetTime

local cooldown = getmetatable(ActionButton1Cooldown).__index
local hooked, active = {}, {};

function AB:Cooldown_GetTimeText(s)
	--format text as seconds when below a minute
	if s < MINUTEISH then
		local seconds = tonumber(E:Round(s))
		if seconds > EXPIRING_DURATION then
			return SECONDS_FORMAT, seconds, s - (seconds - 0.51)
		else
			return EXPIRING_FORMAT, s, 0.051
		end
	--format text as minutes when below an hour
	elseif s < HOURISH then
		local minutes = tonumber(E:Round(s/MINUTE))
		return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	--format text as hours when below a day
	elseif s < DAYISH then
		local hours = tonumber(E:Round(s/HOUR))
		return HOURS_FORMAT, hours, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	--format text as days
	else
		local days = tonumber(E:Round(s/DAY))
		return DAYS_FORMAT, days,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local function Cooldown_OnUpdate(cd, elapsed)
	if cd.nextUpdate > 0 then
		cd.nextUpdate = cd.nextUpdate - elapsed
	else
		local remain = cd.duration - (GetTime() - cd.start)
		if remain > 0.01 then
			if (cd.fontScale * cd:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
				cd.text:SetText('')
				cd.nextUpdate  = 1
			else
				local formatStr, time, nextUpdate = AB:Cooldown_GetTimeText(remain)
				cd.text:SetFormattedText(formatStr, time)
				cd.nextUpdate = nextUpdate
			end
		else
			AB:Cooldown_StopTimer(cd)
		end
	end
end

function AB:Cooldown_OnSizeChanged(cd, width, height)
	local fontScale = E:Round(width) / ICON_SIZE
	local override = cd:GetParent():GetParent().SizeOverride
	if override then 
		fontScale = override / FONT_SIZE  
	end
	
	if fontScale == cd.fontScale then
		return
	end

	cd.fontScale = fontScale
	if fontScale < MIN_SCALE and not override then
		cd:Hide()
	else
		cd:Show()
		cd.text:FontTemplate(nil, fontScale * FONT_SIZE, 'OUTLINE')
		if cd.enabled then
			self:Cooldown_ForceUpdate(cd)
		end
	end
end

function AB:Cooldown_ForceUpdate(cd)
	cd.nextUpdate = 0
	cd:Show()
end

function AB:Cooldown_StopTimer(cd)
	cd.enabled = nil
	cd:Hide()
end

function AB:CreateCooldownTimer(parent)
	local scaler = CreateFrame('Frame', nil, parent)
	scaler:SetAllPoints()

	local timer = CreateFrame('Frame', nil, scaler); timer:Hide()
	timer:SetAllPoints()
	timer:SetScript('OnUpdate', Cooldown_OnUpdate)

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', 1, 1)
	text:SetJustifyH("CENTER")
	timer.text = text

	self:Cooldown_OnSizeChanged(timer, parent:GetSize())
	parent:SetScript('OnSizeChanged', function(_, ...) self:Cooldown_OnSizeChanged(timer, ...) end)

	parent.timer = timer
	return timer
end

function AB:OnSetCooldown(cd, start, duration)
	if cd.noOCC then return end
	--start timer
	if start > 0 and duration > MIN_DURATION then
		local timer = cd.timer or self:CreateCooldownTimer(cd)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	--stop timer
	else
		local timer = cd.timer
		if timer then
			self:Cooldown_StopTimer(timer)
		end
	end
end

function AB:UpdateCooldown(cd)
	local button = cd:GetParent()
	local start, duration, enable = GetActionCooldown(button.action)

	self:OnSetCooldown(cd, start, duration)
end

function AB:ACTIONBAR_UPDATE_COOLDOWN()		
	for cooldown in pairs(active) do
		self:UpdateCooldown(cooldown)
	end
end

function AB:RegisterCooldown(frame)
	if not hooked[frame.cooldown] then
		frame.cooldown:HookScript("OnShow", function(cd) active[cd] = true; end)
		frame.cooldown:HookScript("OnHide", function(cd) active[cd] = nil; end)
		hooked[frame.cooldown] = true
	end
end

function AB:EnableCooldown()
	self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
	
	if ActionBarButtonEventsFrame.frames then
		for i, frame in pairs(ActionBarButtonEventsFrame.frames) do
			self:RegisterCooldown(frame)
		end
	end	
	
	if not self.hooks[cooldown] then
		self:SecureHook(cooldown, 'SetCooldown', 'OnSetCooldown')
	end		
end

function AB:DisableCooldown()
	self:UnregisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
	if self.hooks[cooldown] then
		self:Unhook(cooldown, 'SetCooldown')
		self.hooks[cooldown] = nil
	end		
end

local color
function AB:UpdateCooldownSettings()
	color = self.db.expiringcolor
	EXPIRING_FORMAT = E:RGBToHex(color.r, color.g, color.b)..'%.1f|r' --format for timers that are soon to expire
	
	color = self.db.secondscolor
	SECONDS_FORMAT = E:RGBToHex(color.r, color.g, color.b)..'%d|r' --format for timers that have seconds remaining
	
	color = self.db.minutescolor
	MINUTES_FORMAT = E:RGBToHex(color.r, color.g, color.b)..'%dm|r' --format for timers that have minutes remaining
	
	color = self.db.hourscolor
	HOURS_FORMAT = E:RGBToHex(color.r, color.g, color.b)..'%dh|r' --format for timers that have hours remaining
	
	color = self.db.dayscolor
	DAYS_FORMAT = E:RGBToHex(color.r, color.g, color.b)..'%dd|r' --format for timers that have days remaining
	
	
	EXPIRING_DURATION = self.db.treshold
	
	if self.db.enablecd then
		self:EnableCooldown()
	else
		self:DisableCooldown()
	end
end