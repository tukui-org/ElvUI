local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local next = next

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
	local db = E:CooldownData(cooldown)
	if not db then return end

	local c = db.colors[(cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and 'swipeLOC') or 'swipe']
	if c then
		cooldown:SetSwipeColor(c.r, c.g, c.b, c.a)
	end
end

function E:CooldownTextures(cooldown, attach, texture, edge, swipe)
	cooldown:SetInside(attach, attach and 0, attach and 0)

	cooldown:SetDrawEdge(true)
	cooldown:SetDrawSwipe(true)

	cooldown:SetEdgeTexture(texture, edge.r, edge.g, edge.b, edge.a)
	cooldown:SetSwipeTexture(E.media.blankTex, swipe.r, swipe.g, swipe.b, swipe.a)
end

function E:CooldownUpdate(cooldown)
	local db, data = E:CooldownData(cooldown)
	if not db or not cooldown.Text then return end

	local which, colors = data.which, db.colors
	cooldown.Text:ClearAllPoints()
	cooldown.Text:SetTextColor(colors.text.r, colors.text.g, colors.text.b)
	cooldown.Text:Point('CENTER', nil, db.position, db.offsetX, db.offsetY)
	cooldown.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)

	cooldown:SetHideCountdownNumbers(db.hideNumbers) -- hide text
	cooldown:SetCountdownAbbrevThreshold(db.threshold)
	cooldown:SetMinimumCountdownDuration(db.minDuration) -- minimum duration above which text will be shown
	--cooldown:SetRotation(rad(db.rotation))
	cooldown:SetReverse(db.reverse)

	E:CooldownBling(cooldown)

	local aurabars = which == 'aurabars' and 0 or nil
	cooldown:SetDrawBling(not aurabars and not db.hideBling)
	cooldown:SetEdgeColor(colors.edge.r, colors.edge.g, colors.edge.b, aurabars or colors.edge.a)
	cooldown:SetSwipeColor(colors.swipe.r, colors.swipe.g, colors.swipe.b, aurabars or colors.swipe.a)

	local charge = data.chargeCooldown
	if charge then
		charge:SetEdgeColor(colors.edgeCharge.r, colors.edgeCharge.g, colors.edgeCharge.b, colors.edgeCharge.a)
		charge:SetSwipeColor(colors.swipeCharge.r, colors.swipeCharge.g, colors.swipeCharge.b, colors.swipeCharge.a)
	end

	local lossControl = data.lossOfControl
	if lossControl then
		lossControl:SetEdgeColor(colors.edgeLOC.r, colors.edgeLOC.g, colors.edgeLOC.b, colors.edgeLOC.a)
		lossControl:SetSwipeColor(colors.swipeLOC.r, colors.swipeLOC.g, colors.swipeLOC.b, colors.swipeLOC.a)
	end
end

function E:CooldownInitialize(cooldown, attach)
	local db, data = E:CooldownData(cooldown)
	if not db or cooldown.Text then return end

	local c = db.colors
	cooldown.Text = cooldown:GetRegions() -- extract the timer text

	E:CooldownTextures(cooldown, attach, E.Media.Textures.Edge, c.edge, c.swipe)

	local charge = data.chargeCooldown
	if charge then
		E:CooldownTextures(charge, attach, E.Media.Textures.Edge2, c.edgeCharge, c.swipeCharge)
	end

	local lossControl = data.lossOfControl
	if lossControl then
		E:CooldownTextures(lossControl, attach, E.Media.Textures.Edge, c.edgeLOC, c.swipeLOC)
	end
end

function E:CooldownData(cooldown)
	local data = E.RegisteredCooldowns[cooldown]
	local db = data and E.db.cooldown[data.which]

	return db, data
end

function E:CooldownSettings(which)
	local cooldowns = E.db.cooldown.enable and E.CooldownByModule[which]
	if not cooldowns then return end

	for cooldown in next, cooldowns do
		E:CooldownUpdate(cooldown)
	end
end

function E:RegisterCooldown(cooldown, which, attach)
	if not which then which = 'global' end
	local db = E.db.cooldown.enable and E.db.cooldown[which]
	if not db then return end -- verify the settings exist here

	-- storage by cooldown (to grab a cooldowns data)
	if not E.RegisteredCooldowns[cooldown] then -- data can include: charge = chargeCooldown
		E.RegisteredCooldowns[cooldown] = { which = which }
	else -- this cooldown was already added
		return -- stop here
	end

	-- storage by module (to execute settings per module)
	if not E.CooldownByModule[which] then
		E.CooldownByModule[which] = {}
	end

	-- reference the data object
	local data = E.RegisteredCooldowns[cooldown]
	E.CooldownByModule[which][cooldown] = data

	-- reference the charge cooldown from LAB
	local parent = which == 'actionbar' and cooldown:GetParent()
	data.chargeCooldown = parent and parent.chargeCooldown or nil
	data.lossOfControl = parent and parent.lossOfControlCooldown or nil

	-- extract the blizzard cooldown region
	E:CooldownInitialize(cooldown, attach)

	-- init set for the settings
	E:CooldownUpdate(cooldown)
end
