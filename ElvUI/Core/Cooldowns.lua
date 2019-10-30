local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

--Lua functions
local next, ipairs, pairs = next, ipairs, pairs
local floor, tinsert = floor, tinsert
--WoW API / Variables
local GetTime = GetTime
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

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
			if self.parent.hideText or (self.fontScale and (self.fontScale < MIN_SCALE)) then
				self.text:SetText('')
				self.nextUpdate = 500
			else
				local timeColors, indicatorColors, timeThreshold = (self.timerOptions and self.timerOptions.timeColors) or E.TimeColors, (self.timerOptions and self.timerOptions.indicatorColors) or E.TimeIndicatorColors, (self.timerOptions and self.timerOptions.timeThreshold) or E.db.cooldown.threshold
				if not timeThreshold then timeThreshold = E.TimeThreshold end

				local hhmmThreshold = (self.timerOptions and self.timerOptions.hhmmThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
				local mmssThreshold = (self.timerOptions and self.timerOptions.mmssThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)
				local useIndicatorColor = (self.timerOptions and self.timerOptions.useIndicatorColor) or E.db.cooldown.useIndicatorColor

				local value1, formatID, nextUpdate, value2 = E:GetTimeInfo(remain, timeThreshold, hhmmThreshold, mmssThreshold) --?? Simpy
				self.nextUpdate = nextUpdate

				if useIndicatorColor then
					self.text:SetFormattedText(E.TimeFormats[formatID][3], value1, indicatorColors[formatID], value2)
				else
					self.text:SetFormattedText(E.TimeFormats[formatID][2], value1, value2)
				end

				self.text:SetTextColor(timeColors[formatID].r, timeColors[formatID].g, timeColors[formatID].b)
			end
		else
			E:Cooldown_StopTimer(self)
		end
	end
end

function E:Cooldown_OnSizeChanged(cd, width, force)
	local fontScale = width and (floor(width + .5) / ICON_SIZE)

	if fontScale and (fontScale == cd.fontScale) and (force ~= true) then return end
	cd.fontScale = fontScale

	if fontScale and (fontScale < MIN_SCALE) then
		cd:Hide()
	else
		local text = cd.text or cd.time
		if text then
			local useCustomFont = (cd.timerOptions and cd.timerOptions.fontOptions and cd.timerOptions.fontOptions.enable) and E.Libs.LSM:Fetch('font', cd.timerOptions.fontOptions.font)
			if useCustomFont then
				text:FontTemplate(useCustomFont, (fontScale * cd.timerOptions.fontOptions.fontSize), cd.timerOptions.fontOptions.fontOutline)
			elseif fontScale then
				text:FontTemplate(nil, (fontScale * FONT_SIZE), 'OUTLINE')
			end
		end

		if cd.enabled and (force ~= true) then
			self:Cooldown_ForceUpdate(cd)
		end
	end
end

function E:Cooldown_IsEnabled(cd)
	if cd.forceEnabled then
		return true
	elseif cd.forceDisabled then
		return false
	elseif cd.timerOptions and (cd.timerOptions.reverseToggle ~= nil) then
		return (E.db.cooldown.enable and not cd.timerOptions.reverseToggle) or (not E.db.cooldown.enable and cd.timerOptions.reverseToggle)
	else
		return E.db.cooldown.enable
	end
end

function E:Cooldown_ForceUpdate(cd)
	cd.nextUpdate = -1

	if cd.fontScale and (cd.fontScale >= MIN_SCALE) then
		cd:Show()
	end
end

function E:Cooldown_StopTimer(cd)
	cd.enabled = nil
	cd:Hide()
end

function E:CreateCooldownTimer(parent)
	local timer = CreateFrame('Frame', nil, parent)
	timer:Hide()
	timer:SetAllPoints()
	timer.parent = parent
	parent.timer = timer

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:Point('CENTER', 1, 1)
	text:SetJustifyH('CENTER')
	timer.text = text

	-- can be used to modify elements created from this function
	if parent.CooldownPreHook then
		parent.CooldownPreHook(parent)
	end

	-- cooldown override settings
	if parent.CooldownOverride then
		local db = E.db[parent.CooldownOverride]
		if db and db.cooldown then
			if not timer.timerOptions then
				timer.timerOptions = {}
			end

			timer.timerOptions.reverseToggle = db.cooldown.reverse
			timer.timerOptions.hideBlizzard = db.cooldown.hideBlizzard
			timer.timerOptions.useIndicatorColor = db.cooldown.useIndicatorColor

			if db.cooldown.override and E.TimeColors[parent.CooldownOverride] and E.TimeIndicatorColors[parent.CooldownOverride] then
				timer.timerOptions.timeColors, timer.timerOptions.indicatorColors, timer.timerOptions.timeThreshold = E.TimeColors[parent.CooldownOverride], E.TimeIndicatorColors[parent.CooldownOverride], db.cooldown.threshold
			else
				timer.timerOptions.timeColors, timer.timerOptions.timeThreshold = nil, nil
			end

			if db.cooldown.checkSeconds then
				timer.timerOptions.hhmmThreshold, timer.timerOptions.mmssThreshold = db.cooldown.hhmmThreshold, db.cooldown.mmssThreshold
			else
				timer.timerOptions.hhmmThreshold, timer.timerOptions.mmssThreshold = nil, nil
			end

			if (db.cooldown ~= self.db.cooldown) and db.cooldown.fonts and db.cooldown.fonts.enable then
				timer.timerOptions.fontOptions = db.cooldown.fonts
			elseif self.db.cooldown.fonts and self.db.cooldown.fonts.enable then
				timer.timerOptions.fontOptions = self.db.cooldown.fonts
			else
				timer.timerOptions.fontOptions = nil
			end

			-- prevent LibActionBar from showing blizzard CD when the CD timer is created
			if AB and (parent.CooldownOverride == 'actionbar') then
				AB:ToggleCountDownNumbers(nil, nil, parent)
			end
		end
	end
	----------

	E:ToggleBlizzardCooldownText(parent, timer)

	-- keep an eye on the size so we can rescale the font if needed
	self:Cooldown_OnSizeChanged(timer, parent:GetWidth())
	parent:SetScript('OnSizeChanged', function(_, width)
		self:Cooldown_OnSizeChanged(timer, width)
	end)

	-- keep this after Cooldown_OnSizeChanged
	timer:SetScript('OnUpdate', E.Cooldown_OnUpdate)

	return timer
end

E.RegisteredCooldowns = {}
function E:OnSetCooldown(start, duration)
	if (not self.forceDisabled) and (start and duration) and (duration > MIN_DURATION) then
		local timer = self.timer or E:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = -1

		if timer.fontScale and (timer.fontScale >= MIN_SCALE) then
			timer:Show()
		end
	elseif self.timer then
		E:Cooldown_StopTimer(self.timer)
	end
end

function E:RegisterCooldown(cooldown)
	if not cooldown.isHooked then
		hooksecurefunc(cooldown, 'SetCooldown', E.OnSetCooldown)
		cooldown.isHooked = true
	end

	if not cooldown.isRegisteredCooldown then
		local module = (cooldown.CooldownOverride or 'global')
		if not E.RegisteredCooldowns[module] then E.RegisteredCooldowns[module] = {} end

		tinsert(E.RegisteredCooldowns[module], cooldown)
		cooldown.isRegisteredCooldown = true
	end
end

function E:ToggleBlizzardCooldownText(cd, timer, request)
	-- we should hide the blizzard cooldown text when ours are enabled
	if timer and cd and cd.SetHideCountdownNumbers then
		local forceHide = cd.hideText or (timer.timerOptions and timer.timerOptions.hideBlizzard) or (E.db and E.db.cooldown and E.db.cooldown.hideBlizzard)
		if request then
			return forceHide or E:Cooldown_IsEnabled(timer)
		else
			cd:SetHideCountdownNumbers(forceHide or E:Cooldown_IsEnabled(timer))
		end
	end
end

function E:GetCooldownColors(db)
	if not db then db = self.db.cooldown end -- just incase someone calls this without a first arg use the global
	local c13 = E:RGBToHex(db.hhmmColorIndicator.r, db.hhmmColorIndicator.g, db.hhmmColorIndicator.b) -- color for timers that are soon to expire
	local c12 = E:RGBToHex(db.mmssColorIndicator.r, db.mmssColorIndicator.g, db.mmssColorIndicator.b) -- color for timers that are soon to expire
	local c11 = E:RGBToHex(db.expireIndicator.r, db.expireIndicator.g, db.expireIndicator.b) -- color for timers that are soon to expire
	local c10 = E:RGBToHex(db.secondsIndicator.r, db.secondsIndicator.g, db.secondsIndicator.b) -- color for timers that have seconds remaining
	local c9 = E:RGBToHex(db.minutesIndicator.r, db.minutesIndicator.g, db.minutesIndicator.b) -- color for timers that have minutes remaining
	local c8 = E:RGBToHex(db.hoursIndicator.r, db.hoursIndicator.g, db.hoursIndicator.b) -- color for timers that have hours remaining
	local c7 = E:RGBToHex(db.daysIndicator.r, db.daysIndicator.g, db.daysIndicator.b) -- color for timers that have days remaining
	local c6 = db.hhmmColor -- HH:MM color
	local c5 = db.mmssColor -- MM:SS color
	local c4 = db.expiringColor -- color for timers that are soon to expire
	local c3 = db.secondsColor -- color for timers that have seconds remaining
	local c2 = db.minutesColor -- color for timers that have minutes remaining
	local c1 = db.hoursColor -- color for timers that have hours remaining
	local c0 = db.daysColor -- color for timers that have days remaining
	return c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13
end

function E:UpdateCooldownOverride(module)
	local cooldowns = (module and E.RegisteredCooldowns[module])
	if (not cooldowns) or not next(cooldowns) then return end

	local CD, db, customFont, customFontSize, timer, text, blizzTextAB
	for _, cd in ipairs(cooldowns) do
		db = (cd.CooldownOverride and E.db[cd.CooldownOverride]) or self.db
		db = db and db.cooldown

		if db then
			timer = cd.isHooked and cd.isRegisteredCooldown and cd.timer
			CD = timer or cd

			-- cooldown override settings
			if not CD.timerOptions then
				CD.timerOptions = {}
			end

			CD.timerOptions.reverseToggle = db.reverse
			CD.timerOptions.hideBlizzard = db.hideBlizzard

			if cd.CooldownOverride and db.override and E.TimeColors[cd.CooldownOverride] and E.TimeIndicatorColors[cd.CooldownOverride] then
				CD.timerOptions.timeColors, CD.timerOptions.indicatorColors, CD.timerOptions.timeThreshold = E.TimeColors[cd.CooldownOverride], E.TimeIndicatorColors[cd.CooldownOverride], db.threshold
			else
				CD.timerOptions.timeColors, CD.timerOptions.timeThreshold = nil, nil
			end

			if db.checkSeconds then
				CD.timerOptions.hhmmThreshold, CD.timerOptions.mmssThreshold = db.hhmmThreshold, db.mmssThreshold
			else
				CD.timerOptions.hhmmThreshold, CD.timerOptions.mmssThreshold = nil, nil
			end

			if (db ~= self.db.cooldown) and db.fonts and db.fonts.enable then
				CD.timerOptions.fontOptions = db.fonts
			elseif self.db.cooldown.fonts and self.db.cooldown.fonts.enable then
				CD.timerOptions.fontOptions = self.db.cooldown.fonts
			else
				CD.timerOptions.fontOptions = nil
			end
			----------

			-- update font
			if timer and CD then
				self:Cooldown_OnSizeChanged(CD, cd:GetWidth(), true)
			else
				text = CD.text or CD.time
				if text then
					if CD.timerOptions.fontOptions and CD.timerOptions.fontOptions.enable then
						if not customFont then
							customFont = E.Libs.LSM:Fetch('font', CD.timerOptions.fontOptions.font)
						end
						if customFont then
							text:FontTemplate(customFont, CD.timerOptions.fontOptions.fontSize, CD.timerOptions.fontOptions.fontOutline)
						end
					elseif cd.CooldownOverride then
						if not customFont then
							customFont = E.Libs.LSM:Fetch('font', E.db[cd.CooldownOverride].font)
						end

						-- cd.auraType defined in `A:UpdateHeader` and `A:CreateIcon`
						if customFont and cd.auraType and (cd.CooldownOverride == 'auras') then
							customFontSize = E.db[cd.CooldownOverride][cd.auraType] and E.db[cd.CooldownOverride][cd.auraType].durationFontSize
							if customFontSize then
								text:FontTemplate(customFont, customFontSize, E.db[cd.CooldownOverride].fontOutline)
							end
						end
					end
				end
			end

			-- force update cooldown
			if timer and CD then
				E:Cooldown_ForceUpdate(CD)
				E:ToggleBlizzardCooldownText(cd, CD)
				if (not blizzTextAB) and AB and AB.handledBars and (cd.CooldownOverride == 'actionbar') then
					blizzTextAB = true
				end
			elseif cd.CooldownOverride == 'auras' and not (timer and CD) then
				cd.nextUpdate = -1
			end
		end
	end

	if blizzTextAB then
		for _, bar in pairs(AB.handledBars) do
			if bar then
				AB:ToggleCountDownNumbers(bar)
			end
		end
	end
end

function E:UpdateCooldownSettings(module)
	local cooldownDB, timeColors, indicatorColors = self.db.cooldown, E.TimeColors, E.TimeIndicatorColors

	-- update the module timecolors if the config called it but ignore 'global' and 'all':
	-- global is the main call from config, all is the core file calls
	local isModule = module and (module ~= 'global' and module ~= 'all') and self.db[module] and self.db[module].cooldown
	if isModule then
		if not E.TimeColors[module] then E.TimeColors[module] = {} end
		if not E.TimeIndicatorColors[module] then E.TimeIndicatorColors[module] = {} end
		cooldownDB, timeColors, indicatorColors = self.db[module].cooldown, E.TimeColors[module], E.TimeIndicatorColors[module]
	end

	timeColors[0], timeColors[1], timeColors[2], timeColors[3], timeColors[4], timeColors[5], timeColors[6], indicatorColors[0], indicatorColors[1], indicatorColors[2], indicatorColors[3], indicatorColors[4], indicatorColors[5], indicatorColors[6] = E:GetCooldownColors(cooldownDB)

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
		E:UpdateCooldownSettings('unitframe')
		E:UpdateCooldownSettings('auras') -- has special OnUpdate
	end
end
