local E, L, V, P, G = unpack(ElvUI)

local next = next
local tremove = tremove

local CreateColor = CreateColor
local CreateNumericRuleFormatter = C_StringUtil.CreateNumericRuleFormatter

local ROUNDING = Enum.NumericRuleFormatRounding
local ROUNDUP = ROUNDING and ROUNDING.Up or 1
local ROUNDDOWN = ROUNDING and ROUNDING.Down or 2
local COOLDOWN_TYPE_LOSS_OF_CONTROL = COOLDOWN_TYPE_LOSS_OF_CONTROL or 1

E.RegisteredCooldowns = {}
E.CooldownByModule = {}

do	-- mainly used to prevent the bling from triggering when
	local blings = {} -- the actionbars are faded out
	function E:CooldownBling(cooldown, alpha)
		local db = E:CooldownData(cooldown)
		if not db then return end

		local texture = (alpha and alpha > 0.5) and (db.altBling and 131011 or 131010) or E.Media.Textures.Invisible
		if blings[cooldown] ~= texture then		-- dont change the texture unless we need to
			cooldown:SetBlingTexture(texture)	-- starburst or star4 or invisible

			blings[cooldown] = texture
		end
	end
end

function E:CooldownSwipe(cooldown) -- non retail
	local db, ob = E:CooldownData(cooldown)
	if not db then return end

	local colors = (ob and ob.colors) or db.colors
	local color = colors[(cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and 'swipeLOC') or 'swipe']
	if color then
		cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
	end
end

function E:CooldownTextures(cooldown, texture, edge, swipe)
	if not cooldown then return end

	cooldown:SetDrawEdge(true)
	cooldown:SetDrawSwipe(true)

	cooldown:SetEdgeTexture(texture, edge.r, edge.g, edge.b, edge.a)
	cooldown:SetSwipeTexture(E.media.blankTex, swipe.r, swipe.g, swipe.b, swipe.a)
end

function E:CooldownText(cooldown, secondary, hide)
	local db, ob, data = E:CooldownData(cooldown)
	if not db or secondary == nil then return end

	if secondary then -- charge or Loc
		cooldown = secondary
	end

	cooldown:SetHideCountdownNumbers(hide)
	cooldown:SetCountdownAbbrevThreshold(db.threshold)
	cooldown:SetMinimumCountdownDuration(db.minDuration) -- minimum duration above which text will be shown

	local text = cooldown.Text
	if text then
		local colors = db.colors.text -- define the color before switching the db for font settings
		local target = data.which == 'targetaura'
		if target then -- use the ab settings for text
			db = E.db.cooldown.actionbar
		elseif ob then -- use override settings
			db = ob
		end

		text:ClearAllPoints()
		text:SetTextColor(colors.r, colors.g, colors.b)
		text:Point('CENTER', nil, db.position, db.offsetX, db.offsetY)
		text:FontTemplate(db.font, db.fontSize, db.fontOutline)
	end
end

function E:CooldownColors(cooldown, edge, swipe, alpha)
	if not cooldown then return end

	cooldown:SetEdgeColor(edge.r, edge.g, edge.b, alpha or edge.a)
	cooldown:SetSwipeColor(swipe.r, swipe.g, swipe.b, alpha or swipe.a)
end

function E:CooldownUpdate(cooldown)
	local db, ob, data = E:CooldownData(cooldown)
	if not db then return end

	local colors = (ob and ob.colors) or db.colors
	local target = data.which == 'targetaura'
	local aurabars = data.which == 'aurabars'

	local exclude = target or aurabars
	local invisible = exclude and 0 or nil

	E:CooldownBling(cooldown, invisible)

	E:CooldownText(cooldown, false, db.hideNumbers)
	E:CooldownText(cooldown, data.chargeCooldown, not db.chargeText)
	E:CooldownText(cooldown, data.lossOfControl, not db.locText)

	E:CooldownColors(cooldown, colors.edge, colors.swipe, invisible)
	E:CooldownColors(data.chargeCooldown, colors.edgeCharge, colors.swipeCharge)
	E:CooldownColors(data.lossOfControl, colors.edgeLOC, colors.swipeLOC)

	E:CooldownTextures(cooldown, E.Media.Textures.Edge, colors.edge, colors.swipe)
	E:CooldownTextures(data.chargeCooldown, E.Media.Textures.Edge2, colors.edgeCharge, colors.swipeCharge)
	E:CooldownTextures(data.lossOfControl, E.Media.Textures.Edge, colors.edgeLOC, colors.swipeLOC)

	local formatters = data.formatters
	if formatters and not target then
		E:CooldownFormats(cooldown, false, formatters.text)
		E:CooldownFormats(cooldown, data.chargeCooldown, formatters.charge, 'thresholdCharge')
		E:CooldownFormats(cooldown, data.lossOfControl, formatters.loc, 'thresholdLoc')
	end

	--cooldown:SetRotation(rad(db.rotation))
	cooldown:SetDrawBling(not exclude and not db.hideBling)
	cooldown:SetReverse(db.reverse)
end

do
	local YEAR, DAY, HOUR, MINUTE, SECOND = 31557600, 86400, 3600, 60, 1
	local Y, D, H, M = YEAR - DAY, DAY - HOUR, HOUR - MINUTE, MINUTE - SECOND
	local breakpoints, default, color = {}, { r = 1, g = 1, b = 1, a = 1 }, CreateColor(1, 1, 1, 1)
	local times = { -- fake entries: key, fmt, thr
		{ key = 'expiring', fmt = '%.1f', thr = 0, step = 0.1 },
		{ key = 'seconds', fmt = '%.0f', thr = 5, step = 1 },
		{ key = 'secondsLong', fmt = '%.0f', thr = 10, step = 1 },
		{ key = 'minutes', fmt = '%.0fm', thr = M, components = {{ div = M }} },
		{ key = 'hours', fmt = '%.0fh', thr = H, components = {{ div = H }} },
		{ key = 'days', fmt = '%.0fd', thr = D, components = {{ div = D }} },
		{ key = 'years', fmt = '%.0fy', thr = Y, components = {{ div = Y }} }
	}

	function E:CooldownBreakpoints(cooldown, opt)
		local db = E:CooldownData(cooldown)
		if not db then return end

		for index, point in next, times do
			local colorKey = point.key
			if point.key == 'seconds' then
				point.rounding = (db.roundup and ROUNDUP) or ROUNDDOWN
				point.threshold = opt.expireThreshold or point.thr
			elseif point.key == 'secondsLong' then
				point.rounding = (db.roundup and ROUNDUP) or ROUNDDOWN
				point.threshold = opt.secondsThreshold or point.thr
				colorKey = 'minutes' -- use minutes color
			else
				point.rounding = nil
				point.threshold = point.thr
			end

			local colors = opt.colors[colorKey] or default
			color:SetRGBA(colors.r, colors.g, colors.b, colors.a)
			point.format = color:WrapTextInColorCode(point.fmt)

			breakpoints[index] = point
		end

		-- when toggled remove: secondsLong
		if opt.secondsThreshold == -1 then
			tremove(breakpoints, 3)
		end

		-- when toggled remove: expiring
		if opt.expireThreshold == -1 then
			tremove(breakpoints, 1)
		end

		return breakpoints
	end
end

function E:CooldownFormats(cooldown, secondary, formatter, which)
	local db, ob = E:CooldownData(cooldown)
	if not db or not formatter or secondary == nil then return end

	local opt = (ob and ob.enable and ob[which]) or db[which] -- try to use the module override first
	local breakpoints = E:CooldownBreakpoints(cooldown, (opt and opt.override and opt) or (ob and ob.enable and ob.thresholdText) or db.thresholdText)

	if secondary then -- charge or Loc
		cooldown = secondary
	end

	formatter:SetBreakpoints(breakpoints)
	cooldown:SetCountdownFormatter(formatter)
end

function E:CooldownRegion(cooldown)
	if cooldown and not cooldown.Text then
		cooldown.Text = cooldown:GetRegions()
	end
end

function E:CooldownInitialize(cooldown)
	local db, _, data = E:CooldownData(cooldown)
	if not db then return end

	-- extract the text region
	E:CooldownRegion(cooldown)
	E:CooldownRegion(data.chargeCooldown)
	E:CooldownRegion(data.lossOfControl)
end

function E:CooldownData(cooldown)
	local data = E.RegisteredCooldowns[cooldown]
	local db = data and E.db.cooldown[data.which]

	local obj = db and db.override and db.override[data.override]
	local sub = obj and obj[data.subgroup] -- switch to the subgroup
	if sub then obj = sub end -- auras on NP and UF

	return db, obj and obj.enable and obj or nil, data
end

function E:CooldownSettings(which)
	local cooldowns = E.db.cooldown.enable and E.CooldownByModule[which]
	if not cooldowns then return end

	for cooldown in next, cooldowns do
		E:CooldownUpdate(cooldown)
	end
end

function E:RegisterCooldown(cooldown, which, override, subgroup)
	if not which then which = 'global' end
	local db = E.db.cooldown.enable and E.db.cooldown[which]
	if not db then return end -- verify the settings exist here

	-- storage by cooldown (to grab a cooldowns data)
	local data = E.RegisteredCooldowns[cooldown]
	if not data then
		data = { which = which, override = override, subgroup = subgroup }

		E.RegisteredCooldowns[cooldown] = data
	else -- this cooldown was already added
		data.override = override
		data.subgroup = subgroup
		data.which = which -- pls dont

		E:CooldownUpdate(cooldown) -- update it

		return -- stop here
	end

	-- storage by module (to execute settings per module)
	if not E.CooldownByModule[which] then
		E.CooldownByModule[which] = {}
	end

	-- reference the data object
	E.CooldownByModule[which][cooldown] = data

	-- reference the charge cooldown from LAB
	local parent = which == 'actionbar' and cooldown:GetParent()
	data.chargeCooldown = parent and (parent.chargeCooldown or parent.ChargeCooldown) or nil -- ChargeCooldown is the zone ability
	data.lossOfControl = parent and parent.lossOfControlCooldown or nil

	if CreateNumericRuleFormatter then
		data.formatters = { text = CreateNumericRuleFormatter() }

		if data.chargeCooldown then
			data.formatters.charge = CreateNumericRuleFormatter()
		end

		if data.lossOfControl then
			data.formatters.loc = CreateNumericRuleFormatter()
		end
	end

	E:CooldownInitialize(cooldown) -- extract the blizzard cooldown region
	E:CooldownUpdate(cooldown) -- init set for the settings
end
