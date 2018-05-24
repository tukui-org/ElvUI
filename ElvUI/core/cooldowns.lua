local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local floor = math.floor
--WoW API / Variables
local GetTime = GetTime
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: UIParent

local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local FONT_SIZE = 20 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 1.5 --the minimum duration to show cooldown text for

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
			local timeColors, timeThreshold = E.TimeColors, E.db.cooldown.threshold
			if cd.ColorOverride and (E.db[cd.ColorOverride] and E.db[cd.ColorOverride].cooldown.override and E.TimeColors[cd.ColorOverride]) then
				timeColors, timeThreshold = E.TimeColors[cd.ColorOverride], E.db[cd.ColorOverride].cooldown.threshold
			end
			if not timeThreshold then
				timeThreshold = E.TimeThreshold
			end

			local timervalue, formatid
			timervalue, formatid, cd.nextUpdate = E:GetTimeInfo(remain, timeThreshold)
			cd.text:SetFormattedText(("%s%s|r"):format(timeColors[formatid], E.TimeFormats[formatid][2]), timervalue)
		end
	else
		E:Cooldown_StopTimer(cd)
	end
end

function E:Cooldown_OnSizeChanged(cd, width)
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

function E:Cooldown_ForceUpdate(cd)
	cd.nextUpdate = 0
	cd:Show()
end

function E:Cooldown_StopTimer(cd)
	cd.enabled = nil
	cd:Hide()
end

function E:CreateCooldownTimer(parent)
	local scaler = CreateFrame('Frame', nil, parent)
	scaler:SetAllPoints()

	local timer = CreateFrame('Frame', nil, scaler); timer:Hide()
	timer:SetAllPoints()
	timer:SetScript('OnUpdate', Cooldown_OnUpdate)

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:Point('CENTER', 1, 1)
	text:SetJustifyH("CENTER")
	timer.text = text

	self:Cooldown_OnSizeChanged(timer, parent:GetSize())
	parent:SetScript('OnSizeChanged', function(_, ...) self:Cooldown_OnSizeChanged(timer, ...) end)

	parent.timer = timer

	-- used to style nameplate aura cooldown text with `cooldownFontOverride`
	if parent.FontOverride then
		parent.FontOverride(parent)
	end

	-- used by nameplate and bag module to override the cooldown color by its setting (if enabled)
	if parent.ColorOverride then
		timer.ColorOverride = parent.ColorOverride
	end

	return timer
end

function E:OnSetCooldown(start, duration)
	if(self.noOCC) then return end

	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or E:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	else
		local timer = self.timer
		if timer then
			E:Cooldown_StopTimer(timer)
			return
		end
	end
end

function E:RegisterCooldown(cooldown)
	if(not E.private.cooldown.enable or cooldown.isHooked) then return end
	hooksecurefunc(cooldown, "SetCooldown", E.OnSetCooldown)
	cooldown.isHooked = true
	cooldown:SetHideCountdownNumbers(true)
end

function E:GetCooldownColors(db)
	if not db then db = self.db.cooldown end -- just incase someone calls this without a first arg use the global
	local c4 = E:RGBToHex(db.expiringColor.r, db.expiringColor.g, db.expiringColor.b) -- color for timers that are soon to expire
	local c3 = E:RGBToHex(db.secondsColor.r, db.secondsColor.g, db.secondsColor.b) -- color for timers that have seconds remaining
	local c2 = E:RGBToHex(db.minutesColor.r, db.minutesColor.g, db.minutesColor.b) -- color for timers that have minutes remaining
	local c1 = E:RGBToHex(db.hoursColor.r, db.hoursColor.g, db.hoursColor.b) -- color for timers that have hours remaining
	local c0 = E:RGBToHex(db.daysColor.r, db.daysColor.g, db.daysColor.b) -- color for timers that have days remaining
	return c0, c1, c2, c3, c4
end

function E:UpdateCooldownSettings(module)
	local cooldownDB, timeColors = self.db.cooldown, E.TimeColors

	-- update the module timecolors if the config called it but ignore "global" and "all":
	-- global is the main call from config, all is the core file calls
	if module and (module ~= 'global' and module ~= 'all') and self.db[module] and self.db[module].cooldown then
		if not E.TimeColors[module] then E.TimeColors[module] = {} end
		cooldownDB, timeColors = self.db[module].cooldown, E.TimeColors[module]
	end

	timeColors[0], timeColors[1], timeColors[2], timeColors[3], timeColors[4] = E:GetCooldownColors(cooldownDB)

	-- okay update the other override settings if it was one of the core file calls
	if module and (module == 'all') then
		E:UpdateCooldownSettings('bags')
		E:UpdateCooldownSettings('auras')
		E:UpdateCooldownSettings('nameplates')
		E:UpdateCooldownSettings('unitframe')
	end
end