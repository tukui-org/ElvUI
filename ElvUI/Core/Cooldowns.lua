local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local next, ipairs, pairs = next, ipairs, pairs
local floor, tinsert = floor, tinsert

local GetTime = GetTime
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local FONT_SIZE = 20 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 1.5 --the minimum duration to show cooldown text for

function E:Cooldown_TextThreshold(cd, now)
	if cd.parent and cd.parent.textThreshold and cd.endTime then
		return (cd.endTime - now) >= cd.parent.textThreshold
	end
end

function E:Cooldown_BelowScale(cd)
	if cd.parent then
		if cd.parent.hideText then return true end
		if cd.parent.skipScale then return end
	end

	return cd.fontScale and (cd.fontScale < MIN_SCALE)
end

function E:Cooldown_OnUpdate(elapsed)
	local forced = elapsed == -1
	if forced then
		self.nextUpdate = 0
	elseif self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if not E:Cooldown_IsEnabled(self) then
		E:Cooldown_StopTimer(self)
	else
		local now = GetTime()
		if self.endCooldown and now >= self.endCooldown then
			E:Cooldown_StopTimer(self)
		elseif E:Cooldown_BelowScale(self) then
			self.text:SetText('')
			if not forced then
				self.nextUpdate = 500
			end
		elseif E:Cooldown_TextThreshold(self, now) then
			self.text:SetText('')
			if not forced then
				self.nextUpdate = 1
			end
		elseif self.endTime then
			local value, id, nextUpdate, remainder = E:GetTimeInfo(self.endTime - now, self.threshold, self.hhmmThreshold, self.mmssThreshold)
			if not forced then
				self.nextUpdate = nextUpdate
			end

			local style = E.TimeFormats[id]
			if style then
				local which = (self.textColors and 2 or 1) + (self.showSeconds and 0 or 2)
				if self.textColors then
					self.text:SetFormattedText(style[which], value, self.textColors[id], remainder)
				else
					self.text:SetFormattedText(style[which], value, remainder)
				end
			end

			local color = not self.skipTextColor and self.timeColors[id]
			if color then self.text:SetTextColor(color.r, color.g, color.b) end
		end
	end
end

function E:Cooldown_OnSizeChanged(cd, width, force)
	local scale = width and (floor(width + 0.5) / ICON_SIZE)

	-- dont bother updating when the fontScale is the same, unless we are passing the force arg
	if scale and (scale == cd.fontScale) and (force ~= true) then return end
	cd.fontScale = scale

	-- this is needed because of skipScale variable, we wont allow a font size under the minscale
	if cd.fontScale and (cd.fontScale < MIN_SCALE) then
		scale = MIN_SCALE
	end

	if cd.customFont then -- override font
		cd.text:FontTemplate(cd.customFont, (scale * cd.customFontSize), cd.customFontOutline)
	elseif scale then -- default, no override
		cd.text:FontTemplate(nil, (scale * FONT_SIZE), 'OUTLINE')
	else -- this should never happen but just incase
		cd.text:FontTemplate()
	end
end

function E:Cooldown_IsEnabled(cd)
	if cd.forceEnabled then
		return true
	elseif cd.forceDisabled then
		return false
	elseif cd.reverseToggle ~= nil then
		return cd.reverseToggle
	else
		return E.db.cooldown.enable
	end
end

function E:Cooldown_ForceUpdate(cd)
	E.Cooldown_OnUpdate(cd, -1)
	cd:Show()
end

function E:Cooldown_StopTimer(cd)
	cd:Hide()
end

function E:Cooldown_Options(timer, db, parent)
	local threshold, colors, icolors, hhmm, mmss, fonts
	if parent and db.override then
		threshold = db.threshold
		icolors = db.useIndicatorColor and E.TimeIndicatorColors[parent.CooldownOverride]
		colors = E.TimeColors[parent.CooldownOverride]
	end

	if db.checkSeconds then
		hhmm, mmss = db.hhmmThreshold, db.mmssThreshold
	end

	timer.timeColors = colors or E.TimeColors
	timer.threshold = threshold or E.db.cooldown.threshold or E.TimeThreshold
	timer.textColors = icolors or (E.db.cooldown.useIndicatorColor and E.TimeIndicatorColors)
	timer.hhmmThreshold = hhmm or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
	timer.mmssThreshold = mmss or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)
	timer.hideBlizzard = db.hideBlizzard or E.db.cooldown.hideBlizzard

	if db.reverse ~= nil then
		timer.reverseToggle = (E.db.cooldown.enable and not db.reverse) or (db.reverse and not E.db.cooldown.enable)
	else
		timer.reverseToggle = nil
	end

	if timer.CooldownOverride ~= 'auras' then
		if (db ~= E.db.cooldown) and db.fonts and db.fonts.enable then
			fonts = db.fonts -- custom fonts override default fonts
		elseif E.db.cooldown.fonts and E.db.cooldown.fonts.enable then
			fonts = E.db.cooldown.fonts -- default global font override
		end

		if fonts and fonts.enable then
			timer.customFont = LSM:Fetch('font', fonts.font)
			timer.customFontSize = fonts.fontSize
			timer.customFontOutline = fonts.fontOutline
		else
			timer.customFont = nil
			timer.customFontSize = nil
			timer.customFontOutline = nil
		end
	end
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
	local db = (parent.CooldownOverride and E.db[parent.CooldownOverride]) or E.db
	if db and db.cooldown then
		E:Cooldown_Options(timer, db.cooldown, parent)

		-- prevent LibActionBar from showing blizzard CD when the CD timer is created
		if parent.CooldownOverride == 'actionbar' then
			AB:ToggleCountDownNumbers(nil, nil, parent)
		end
	end

	E:ToggleBlizzardCooldownText(parent, timer)

	-- keep an eye on the size so we can rescale the font if needed
	E:Cooldown_OnSizeChanged(timer, parent:GetWidth())
	parent:SetScript('OnSizeChanged', function(_, width)
		E:Cooldown_OnSizeChanged(timer, width)
	end)

	-- keep this after Cooldown_OnSizeChanged
	timer:SetScript('OnUpdate', E.Cooldown_OnUpdate)

	return timer
end

E.RegisteredCooldowns = {}
function E:OnSetCooldown(start, duration)
	if not self.forceDisabled and (start and duration) and (duration > MIN_DURATION) then
		local timer = self.timer or E:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.endTime = start + duration
		timer.endCooldown = timer.endTime - 0.05
		E:Cooldown_ForceUpdate(timer)
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
		local forceHide = cd.hideText or timer.hideBlizzard
		if request then
			return forceHide or E:Cooldown_IsEnabled(timer)
		else
			cd:SetHideCountdownNumbers(forceHide or E:Cooldown_IsEnabled(timer))
		end
	end
end

function E:GetCooldownColors(db)
	if not db then db = E.db.cooldown end -- just incase someone calls this without a first arg use the global
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
	if not cooldowns or not next(cooldowns) then return end

	local blizzText
	for _, parent in ipairs(cooldowns) do
		local db = (parent.CooldownOverride and E.db[parent.CooldownOverride]) or E.db
		if db and db.cooldown then
			local timer = parent.isHooked and parent.isRegisteredCooldown and parent.timer
			local cd = timer or parent

			-- cooldown override settings
			E:Cooldown_Options(cd, db.cooldown, parent)

			-- update font on cooldowns
			if timer and cd then -- has a parent, these are timers from RegisterCooldown
				E:Cooldown_OnSizeChanged(cd, parent:GetWidth(), true)

				E:ToggleBlizzardCooldownText(parent, cd)
				if (not blizzText) and parent.CooldownOverride == 'actionbar' then
					blizzText = true
				end
			elseif cd.text then
				if cd.customFont then
					cd.text:FontTemplate(cd.customFont, cd.customFontSize, cd.customFontOutline)
				elseif parent.CooldownOverride == 'auras' then
					-- parent.auraType defined in `A:UpdateHeader` and `A:CreateIcon`
					local fontDB = parent.auraType and db[parent.auraType]
					if fontDB and fontDB.timeFont then
						cd.text:FontTemplate(LSM:Fetch('font', fontDB.timeFont), fontDB.timeFontSize, fontDB.timeFontOutline)
					end
				end

				-- force update top aura cooldowns
				if parent.CooldownOverride == 'auras' then
					E:Cooldown_ForceUpdate(parent)
				end
			end
		end
	end

	if blizzText and AB.handledBars then
		for _, bar in pairs(AB.handledBars) do
			if bar then
				AB:ToggleCountDownNumbers(bar)
			end
		end
	end
end

function E:UpdateCooldownSettings(module)
	local db, timeColors, textColors = E.db.cooldown, E.TimeColors, E.TimeIndicatorColors

	-- update the module timecolors if the config called it but ignore 'global' and 'all':
	-- global is the main call from config, all is the core file calls
	local isModule = module and (module ~= 'global' and module ~= 'all') and E.db[module] and E.db[module].cooldown
	if isModule then
		if not E.TimeColors[module] then E.TimeColors[module] = {} end
		if not E.TimeIndicatorColors[module] then E.TimeIndicatorColors[module] = {} end
		db, timeColors, textColors = E.db[module].cooldown, E.TimeColors[module], E.TimeIndicatorColors[module]
	end

	timeColors[0], timeColors[1], timeColors[2], timeColors[3], timeColors[4], timeColors[5], timeColors[6], textColors[0], textColors[1], textColors[2], textColors[3], textColors[4], textColors[5], textColors[6] = E:GetCooldownColors(db)

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
		E:UpdateCooldownSettings('auras')
	end
end
