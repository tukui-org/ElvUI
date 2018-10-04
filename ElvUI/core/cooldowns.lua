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

local AB -- used to store the ActionBars module when we need it to set the buttons `.disableCountDownNumbers`

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
			if self.fontScale and ((self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE) then
				self.text:SetText('')
				self.nextUpdate = 500
			else
				local timeColors, timeThreshold = (self.timerOptions and self.timerOptions.timeColors) or E.TimeColors, (self.timerOptions and self.timerOptions.timeThreshold) or E.db.cooldown.threshold
				if not timeThreshold then timeThreshold = E.TimeThreshold end

				local hhmmThreshold = (self.timerOptions and self.timerOptions.hhmmThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
				local mmssThreshold = (self.timerOptions and self.timerOptions.mmssThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)

				local value1, formatid, nextUpdate, value2 = E:GetTimeInfo(remain, timeThreshold, hhmmThreshold, mmssThreshold)
				self.nextUpdate = nextUpdate
				self.text:SetFormattedText(("%s%s|r"):format(timeColors[formatid], E.TimeFormats[formatid][2]), value1, value2)
			end
		else
			E:Cooldown_StopTimer(self)
		end
	end
end

function E:Cooldown_OnSizeChanged(cd, parent, width, force)
	local fontScale = width and (floor(width + .5) / ICON_SIZE)

	-- .CooldownFontSize is used when we the cooldown button/icon does not use `SetSize` or `Size` for some reason. IE: nameplates
	if parent and parent.CooldownFontSize then
		fontScale = (parent.CooldownFontSize / FONT_SIZE)
	end

	if fontScale and (fontScale == cd.fontScale) and (force ~= 'override') then return end
	cd.fontScale = fontScale

	if fontScale and (fontScale < MIN_SCALE) and not (parent and parent.CooldownFontSize) then
		cd:Hide()
	else
		local text = cd.text or cd.time
		if text then
			local useCustomFont = (cd.timerOptions and cd.timerOptions.fontOptions and cd.timerOptions.fontOptions.enable) and E.LSM:Fetch("font", cd.timerOptions.fontOptions.font)
			if useCustomFont then
				local customSize = (parent and parent.CooldownFontSize and cd.timerOptions.fontOptions.fontSize) or (fontScale * cd.timerOptions.fontOptions.fontSize)
				text:FontTemplate(useCustomFont, customSize, cd.timerOptions.fontOptions.fontOutline)
			elseif fontScale and parent and parent.CooldownSettings and parent.CooldownSettings.font and parent.CooldownSettings.fontOutline then
				text:FontTemplate(parent.CooldownSettings.font, (fontScale * FONT_SIZE), parent.CooldownSettings.fontOutline)
			elseif fontScale then
				text:FontTemplate(nil, (fontScale * FONT_SIZE), 'OUTLINE')
			end
		end

		if cd.enabled and (force ~= 'override') then
			self:Cooldown_ForceUpdate(cd)
		end
	end
end

function E:Cooldown_IsEnabled(cd)
	if cd.alwaysEnabled then
		return true
	elseif cd.timerOptions and (cd.timerOptions.reverseToggle ~= nil) then
		return (E.db.cooldown.enable and not cd.timerOptions.reverseToggle) or (not E.db.cooldown.enable and cd.timerOptions.reverseToggle)
	else
		return E.db.cooldown.enable
	end
end

function E:Cooldown_ForceUpdate(cd)
	cd.nextUpdate = 0

	if cd.fontScale and (cd.fontScale >= MIN_SCALE) then
		cd:Show()
	end
end

function E:Cooldown_StopTimer(cd)
	cd.enabled = nil
	cd:Hide()
end

function E:CreateCooldownTimer(parent)
	local scaler = CreateFrame('Frame', nil, parent)
	scaler:SetAllPoints()

	local timer = CreateFrame('Frame', nil, scaler)
	timer:Hide()
	timer:SetAllPoints()
	parent.timer = timer

	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:Point('CENTER', 1, 1)
	text:SetJustifyH("CENTER")
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

			if db.cooldown.override and E.TimeColors[parent.CooldownOverride] then
				timer.timerOptions.timeColors, timer.timerOptions.timeThreshold = E.TimeColors[parent.CooldownOverride], db.cooldown.threshold
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
	self:Cooldown_OnSizeChanged(timer, parent, parent:GetSize())
	parent:SetScript('OnSizeChanged', function(_, ...)
		self:Cooldown_OnSizeChanged(timer, parent, ...)
	end)

	-- keep this after Cooldown_OnSizeChanged
	timer:SetScript('OnUpdate', E.Cooldown_OnUpdate)

	return timer
end

E.RegisteredCooldowns = {}
function E:OnSetCooldown(start, duration)
	if (start > 0) and (duration > MIN_DURATION) then
		local timer = self.timer or E:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0

		if timer.fontScale and (timer.fontScale >= MIN_SCALE) then
			timer:Show()
		end
	elseif self.timer then
		E:Cooldown_StopTimer(self.timer)
	end
end

function E:RegisterCooldown(cooldown)
	if not cooldown.isHooked then
		hooksecurefunc(cooldown, "SetCooldown", E.OnSetCooldown)
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
		local forceHide = (timer.timerOptions and timer.timerOptions.hideBlizzard) or E.db.cooldown.hideBlizzard
		if request then
			return forceHide or E:Cooldown_IsEnabled(timer)
		else
			cd:SetHideCountdownNumbers(forceHide or E:Cooldown_IsEnabled(timer))
		end
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

			if cd.CooldownOverride and db.override and E.TimeColors[cd.CooldownOverride] then
				CD.timerOptions.timeColors, CD.timerOptions.timeThreshold = E.TimeColors[cd.CooldownOverride], db.threshold
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
				self:Cooldown_OnSizeChanged(CD, cd, cd:GetSize(), 'override')
			else
				text = CD.text or CD.time
				if text then
					if CD.timerOptions.fontOptions and CD.timerOptions.fontOptions.enable then
						if not customFont then
							customFont = E.LSM:Fetch("font", CD.timerOptions.fontOptions.font)
						end
						if customFont then
							text:FontTemplate(customFont, CD.timerOptions.fontOptions.fontSize, CD.timerOptions.fontOptions.fontOutline)
						end
					elseif cd.CooldownOverride then
						if not customFont then
							customFont = E.LSM:Fetch("font", E.db[cd.CooldownOverride].font)
						end
						if customFont then
							-- cd.auraType defined in `A:UpdateHeader` and `A:CreateIcon`
							if cd.auraType and (cd.CooldownOverride == 'auras') then
								customFontSize = E.db[cd.CooldownOverride][cd.auraType] and E.db[cd.CooldownOverride][cd.auraType].durationFontSize
								if customFontSize then
									text:FontTemplate(customFont, customFontSize, E.db[cd.CooldownOverride].fontOutline)
								end
							elseif (cd.CooldownOverride == 'unitframe') then
								text:FontTemplate(customFont, E.db[cd.CooldownOverride].fontSize, E.db[cd.CooldownOverride].fontOutline)
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
			elseif cd.CooldownOverride and not (timer and CD) then
				if cd.CooldownOverride == 'auras' then
					cd.nextUpdate = -1
				elseif cd.CooldownOverride == 'unitframe' then
					cd.nextupdate = -1
					if E.private.unitframe.enable then
						-- cd.unit defined in `UF:UpdateAuraIconSettings`, it's safe to pass even if `nil`
						E:GetModule('UnitFrames'):PostUpdateAura(cd.unit, cd)
						E:ToggleBlizzardCooldownText(cd.cd, cd)
					end
				end
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
		if not AB then AB = E:GetModule('ActionBars') end
		E:UpdateCooldownSettings('bags')
		E:UpdateCooldownSettings('nameplates')
		E:UpdateCooldownSettings('actionbar')
		E:UpdateCooldownSettings('unitframe') -- has special OnUpdate
		E:UpdateCooldownSettings('auras') -- has special OnUpdate
	end
end
