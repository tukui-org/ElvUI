local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local next, ipairs, pairs = next, ipairs, pairs
local floor = math.floor
local tinsert = table.insert
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

function E:Cooldown_OnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if not E:Cooldown_IsEnabled(self) then
		E:Cooldown_StopTimer(self)
	else
		local remain = self.duration - (GetTime() - self.start)
		if remain > 0.05 then
			if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
				self.text:SetText('')
				self.nextUpdate = 500
			else
				local timeColors, timeThreshold = (self.timeColors or E.TimeColors), (self.timeThreshold or E.db.cooldown.threshold)
				if not timeThreshold then timeThreshold = E.TimeThreshold end

				local hhmmThreshold = self.hhmmThreshold or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
				local mmssThreshold = self.mmssThreshold or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)

				local value1, formatid, nextUpdate, value2 = E:GetTimeInfo(remain, timeThreshold, hhmmThreshold, mmssThreshold)
				self.nextUpdate = nextUpdate

				self.text:SetFormattedText(("%s%s|r"):format(timeColors[formatid], E.TimeFormats[formatid][2]), value1, value2)
			end
		else
			E:Cooldown_StopTimer(self)
		end
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

function E:Cooldown_IsEnabled(cd)
	return cd.alwaysEnabled or (E.db.cooldown.enable and not cd.reverseToggle) or (not E.db.cooldown.enable and cd.reverseToggle)
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
	timer:SetScript('OnUpdate', E.Cooldown_OnUpdate)

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:Point('CENTER', 1, 1)
	text:SetJustifyH("CENTER")
	timer.text = text

	self:Cooldown_OnSizeChanged(timer, parent:GetSize())
	parent:SetScript('OnSizeChanged', function(_, ...)
		self:Cooldown_OnSizeChanged(timer, ...)
	end)

	parent.timer = timer

	-- used to style nameplate aura cooldown text with `cooldownFontOverride`
	if parent.FontOverride then
		parent.FontOverride(parent)
	end

	-- used by nameplate and bag module to override the cooldown color by its setting (if enabled)
	if parent.ColorOverride then
		local db = E.db[parent.ColorOverride]
		if db and db.cooldown then
			if db.cooldown.override and E.TimeColors[parent.ColorOverride] then
				timer.timeColors, timer.timeThreshold = E.TimeColors[parent.ColorOverride], db.cooldown.threshold
			end

			if db.cooldown.checkSeconds then
				timer.hhmmThreshold, timer.mmssThreshold = db.cooldown.hhmmThreshold, db.cooldown.mmssThreshold
			end

			timer.reverseToggle = db.cooldown.reverse
		end
	end

	return timer
end

E.RegisteredCooldowns = {}
function E:OnSetCooldown(start, duration)
	if self.noOCC or not E:Cooldown_IsEnabled(self) then return end

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
	if not cooldown.isHooked then
		hooksecurefunc(cooldown, "SetCooldown", E.OnSetCooldown)
		cooldown:SetHideCountdownNumbers(true)
		cooldown.isHooked = true
	end

	if not cooldown.isRegisteredCooldown then
		local module = (cooldown.ColorOverride or 'global')
		if not E.RegisteredCooldowns[module] then E.RegisteredCooldowns[module] = {} end

		tinsert(E.RegisteredCooldowns[module], cooldown)
		cooldown.isRegisteredCooldown = true
	end
end

function E:GetCooldownColors(db)
	if not db then db = self.db.cooldown end -- just incase someone calls this without a first arg use the global
	local c6 = E:RGBToHex(db.hhmmColor.r, db.hhmmColor.g, db.hhmmColor.b) -- HH:MM color
	local c5 = E:RGBToHex(db.mmssColor.r, db.mmssColor.g, db.mmssColor.b) -- MM:SS color
	local c4 = E:RGBToHex(db.expiringColor.r, db.expiringColor.g, db.expiringColor.b) -- color for timers that are soon to expire
	local c3 = E:RGBToHex(db.secondsColor.r, db.secondsColor.g, db.secondsColor.b) -- color for timers that have seconds remaining
	local c2 = E:RGBToHex(db.minutesColor.r, db.minutesColor.g, db.minutesColor.b) -- color for timers that have minutes remaining
	local c1 = E:RGBToHex(db.hoursColor.r, db.hoursColor.g, db.hoursColor.b) -- color for timers that have hours remaining
	local c0 = E:RGBToHex(db.daysColor.r, db.daysColor.g, db.daysColor.b) -- color for timers that have days remaining
	return c0, c1, c2, c3, c4, c5, c6
end

function E:UpdateCooldownOverride(module)
	local cooldowns = (module and E.RegisteredCooldowns[module])
	if (not cooldowns) or not next(cooldowns) then return end

	local timer, CD, db -- timer = cooldown from RegisterCooldown
	local parent, unit -- used to resummon timer text on auras for unitframes

	for _, cd in ipairs(cooldowns) do
		timer = cd.isHooked and cd.isRegisteredCooldown and cd.timer
		CD = timer or cd

		if cd then
			db = (cd.ColorOverride and E.db[cd.ColorOverride]) or self.db

			if db and db.cooldown then
				if cd.ColorOverride then
					if db.cooldown.override and E.TimeColors[cd.ColorOverride] then
						CD.timeColors, CD.timeThreshold = E.TimeColors[cd.ColorOverride], db.cooldown.threshold
					else
						CD.timeColors, CD.timeThreshold = nil, nil
					end

					if db.cooldown.checkSeconds then
						CD.hhmmThreshold, CD.mmssThreshold = db.cooldown.hhmmThreshold, db.cooldown.mmssThreshold
					else
						CD.hhmmThreshold, CD.mmssThreshold = nil, nil
					end

					CD.reverseToggle = db.cooldown.reverse
				end

				if timer and CD then
					E:Cooldown_ForceUpdate(CD)
				elseif cd.ColorOverride then
					if cd.ColorOverride == 'auras' then
						cd.nextUpdate = -1
					elseif cd.ColorOverride == 'unitframe' then
						cd.nextupdate = -1
						if E.private.unitframe.enable then
							parent = cd:GetParent():GetParent():GetParent()
							unit = parent and parent.unit
							E:GetModule('UnitFrames'):PostUpdateAura(unit, cd)
						end
					end
				end
			end
		end
	end
end

function E:UpdateCooldownSettings(module)
	local cooldownDB, timeColors = self.db.cooldown, E.TimeColors

	-- update the module timecolors if the config called it but ignore "global" and "all":
	-- global is the main call from config, all is the core file calls
	local isModule = module and (module ~= 'global' and module ~= 'all') and self.db[module] and self.db[module].cooldown
	if isModule then
		if not E.TimeColors[module] then E.TimeColors[module] = {} end
		cooldownDB, timeColors = self.db[module].cooldown, E.TimeColors[module]
	end

	timeColors[0], timeColors[1], timeColors[2], timeColors[3], timeColors[4], timeColors[5], timeColors[6] = E:GetCooldownColors(cooldownDB)

	if isModule then
		E:UpdateCooldownOverride(module)
	elseif module == 'global' then -- this is only a call from the config change
		for key in pairs(E.RegisteredCooldowns) do
			E:UpdateCooldownOverride(key)
		end
	end

	-- okay update the other override settings if it was one of the core file calls
	if module and (module == 'all') then
		E:UpdateCooldownSettings('bags')
		E:UpdateCooldownSettings('nameplates')
		E:UpdateCooldownSettings('actionbar')
		E:UpdateCooldownSettings('unitframe') -- has special OnUpdate
		E:UpdateCooldownSettings('auras') -- has special OnUpdate
	end
end