local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local next = next

local COOLDOWN_TYPE_LOSS_OF_CONTROL = COOLDOWN_TYPE_LOSS_OF_CONTROL or 1

E.RegisteredCooldowns = {}
E.CooldownByModule = {}

function E:CooldownUpdate(cooldown)
	local data = cooldown.Text and E.RegisteredCooldowns[cooldown]
	if not data then return end

	local db, which, c = data.db, data.which, data.colors
	cooldown.Text:ClearAllPoints()
	cooldown.Text:SetTextColor(c.text.r, c.text.g, c.text.b)
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
	cooldown:SetEdgeColor(c.edge.r, c.edge.g, c.edge.b, aurabars or c.edge.a)
	cooldown:SetSwipeColor(c.swipe.r, c.swipe.g, c.swipe.b, aurabars or c.swipe.a)

	local charge = data.chargeCooldown
	if charge then
		charge:SetEdgeColor(c.edgeCharge.r, c.edgeCharge.g, c.edgeCharge.b, c.edgeCharge.a)
		charge:SetSwipeColor(c.swipeCharge.r, c.swipeCharge.g, c.swipeCharge.b, c.swipeCharge.a)
	end

	local lossControl = data.lossOfControl
	if lossControl then
		lossControl:SetEdgeColor(c.edgeLOC.r, c.edgeLOC.g, c.edgeLOC.b, c.edgeLOC.a)
		lossControl:SetSwipeColor(c.swipeLOC.r, c.swipeLOC.g, c.swipeLOC.b, c.swipeLOC.a)
	end
end

function E:CooldownSettings(which)
	if not E.db.cooldown.enable then return end

	local cooldowns = E.CooldownByModule[which]
	if not cooldowns then return end

	for cooldown, data in next, cooldowns do
		E:CooldownUpdate(cooldown, data)
	end
end

do	-- mainly used to prevent the bling from triggering when
	local blings = {} -- the actionbars are faded out
	function E:CooldownBling(cooldown, alpha)
		local data = E.RegisteredCooldowns[cooldown]
		if not data then return end

		local texture = (alpha and alpha > 0.5) and (data.db.altBling and 131011 or 131010) or E.Media.Textures.Invisible
		if blings[cooldown] ~= texture then		-- dont change the texture unless we need to
			cooldown:SetBlingTexture(texture)	-- starburst or star4 or invisible

			blings[cooldown] = texture
		end
	end
end

function E:CooldownTextures(cooldown, texture, edge, swipe)
	cooldown:SetAllPoints()
	cooldown:SetDrawEdge(true)
	cooldown:SetDrawSwipe(true)

	cooldown:SetEdgeTexture(texture, edge.r, edge.g, edge.b, edge.a)
	cooldown:SetSwipeTexture(E.media.blankTex, swipe.r, swipe.g, swipe.b, swipe.a)
end

function E:CooldownInitialize(cooldown)
	local data = not cooldown.Text and E.RegisteredCooldowns[cooldown]
	if not data then return end

	local c = data.colors
	cooldown.Text = cooldown:GetRegions() -- extract the timer text

	E:CooldownTextures(cooldown, E.Media.Textures.Edge, c.edge, c.swipe)

	local charge = data.chargeCooldown
	if charge then
		E:CooldownTextures(cooldown, E.Media.Textures.Edge2, c.edgeCharge, c.swipeCharge)
	end

	local lossControl = data.lossOfControl
	if lossControl then
		E:CooldownTextures(lossControl, E.Media.Textures.Edge, c.edgeLOC, c.swipeLOC)
	end
end

function E:LABCooldownUpdate(cooldown) -- non retail
	local data = E.RegisteredCooldowns[cooldown]
	if not data then return end

	local c = data.colors[(cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and 'swipeLOC') or 'swipe']
	if c then
		cooldown:SetSwipeColor(c.r, c.g, c.b, c.a)
	end
end

function E:RegisterCooldown(cooldown, which)
	if not which then which = 'global' end
	local db = E.db.cooldown.enable and E.db.cooldown[which]
	if not db then return end -- verify the settings exist here

	-- storage by cooldown (to grab a cooldowns data)
	if not E.RegisteredCooldowns[cooldown] then -- data can include: charge = chargeCooldown
		E.RegisteredCooldowns[cooldown] = { db = db, colors = db.colors, which = which }
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
	E:CooldownInitialize(cooldown)

	-- init set for the settings
	E:CooldownUpdate(cooldown)
end
