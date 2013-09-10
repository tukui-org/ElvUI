local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

local MIN_SCALE = 0.5
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local FONT_SIZE = 20 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 2.5 --the minimum duration to show cooldown text for

local floor = math.floor
local min = math.min
local GetTime = GetTime

local threshold

local TimeColors = {
	[0] = '|cfffefefe',
	[1] = '|cfffefefe',
	[2] = '|cfffefefe',
	[3] = '|cfffefefe',
	[4] = '|cfffe0000',
}

local function Cooldown_OnUpdate(cd, elapsed)
	if cd.nextUpdate > 0 then
		cd.nextUpdate = cd.nextUpdate - elapsed
		return
	end

	local remain = cd.duration - (GetTime() - cd.start)

	if remain > 0.05 then
		if (cd.fontScale * cd:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
			cd.text:SetText('')
			cd.nextUpdate = 500
		else
			local timervalue, formatid
			timervalue, formatid, cd.nextUpdate = E:GetTimeInfo(remain, threshold)		
			cd.text:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], E.TimeFormats[formatid][2]), timervalue)
		end
	else
		AB:Cooldown_StopTimer(cd)
	end
end

function AB:Cooldown_OnSizeChanged(cd, width, height)
	local fontScale = floor(width +.5) / ICON_SIZE
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

function AB:OnSetCooldown(start, duration, charges, maxCharges)
	if(self.noOCC) then return end
	local button = self:GetParent()

	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or AB:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	else
		local timer = self.timer
		if timer then
			AB:Cooldown_StopTimer(timer)
		end
	end
	

	if self.timer then
		if charges and charges > 0 then
			self.timer:SetAlpha(0)
		else
			self.timer:SetAlpha(1)	
		end
	end
end

function AB:RegisterCooldown(cooldown)
	hooksecurefunc(cooldown, "SetCooldown", AB.OnSetCooldown)
end

function AB:UpdateCooldownSettings()
	threshold = self.db.treshold
	
	local color = E.db.actionbar.expiringcolor
	TimeColors[4] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that are soon to expire
	
	color = E.db.actionbar.secondscolor
	TimeColors[3] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have seconds remaining
	
	color = E.db.actionbar.minutescolor
	TimeColors[2] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have minutes remaining
	
	color = E.db.actionbar.hourscolor
	TimeColors[1] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have hours remaining
	
	color = E.db.actionbar.dayscolor
	TimeColors[0] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have days remaining	
end