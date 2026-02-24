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

	local colors = db.colors[(cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and 'swipeLOC') or 'swipe']
	if colors then
		cooldown:SetSwipeColor(colors.r, colors.g, colors.b, colors.a)
	end
end

function E:CooldownTextures(cooldown, texture, edge, swipe)
	if not cooldown then return end

	cooldown:SetDrawEdge(true)
	cooldown:SetDrawSwipe(true)

	cooldown:SetEdgeTexture(texture, edge.r, edge.g, edge.b, edge.a)
	cooldown:SetSwipeTexture(E.media.blankTex, swipe.r, swipe.g, swipe.b, swipe.a)
end

function E:CooldownText(cooldown, hide)
	local db, data = E:CooldownData(cooldown)
	if not db then return end

	cooldown:SetHideCountdownNumbers(hide)
	cooldown:SetCountdownAbbrevThreshold(db.threshold)
	cooldown:SetMinimumCountdownDuration(db.minDuration) -- minimum duration above which text will be shown

	local text = cooldown.Text
	if text then
		local colors = db.colors.text -- define the color before switching the db for font settings
		local target = data.which == 'targetaura'
		if target then -- use the ab settings for text
			db = E.db.cooldown.actionbar
		end

		text:ClearAllPoints()
		text:SetTextColor(colors.r, colors.g, colors.b)
		text:Point('CENTER', nil, db.position, db.offsetX, db.offsetY)
		text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
	end
end

function E:CooldownColors(cooldown, edge, swipe, alpha)
	if not cooldown then return end

	cooldown:SetEdgeColor(edge.r, edge.g, edge.b, alpha or edge.a)
	cooldown:SetSwipeColor(swipe.r, swipe.g, swipe.b, alpha or swipe.a)
end

function E:CooldownUpdate(cooldown)
	local db, data = E:CooldownData(cooldown)
	if not db then return end

	local colors = db.colors
	local target = data.which == 'targetaura'
	local aurabars = data.which == 'aurabars'

	local exclude = target or aurabars
	local invisible = exclude and 0 or nil

	E:CooldownBling(cooldown)

	E:CooldownText(cooldown, db.hideNumbers)
	E:CooldownText(data.chargeCooldown, not db.chargeText)
	E:CooldownText(data.lossOfControl, not db.locText)

	E:CooldownColors(cooldown, colors.edge, colors.swipe, invisible)
	E:CooldownColors(data.chargeCooldown, colors.edgeCharge, colors.swipeCharge)
	E:CooldownColors(data.lossOfControl, colors.edgeLOC, colors.swipeLOC)

	--cooldown:SetRotation(rad(db.rotation))
	cooldown:SetDrawBling(not exclude and not db.hideBling)
	cooldown:SetReverse(db.reverse)
end

function E:CooldownRegion(cooldown)
	if cooldown and not cooldown.Text then
		cooldown.Text = cooldown:GetRegions()
	end
end

function E:CooldownInitialize(cooldown)
	local db, data = E:CooldownData(cooldown)
	if not db then return end

	-- extract the text region
	E:CooldownRegion(cooldown)
	E:CooldownRegion(data.chargeCooldown)
	E:CooldownRegion(data.lossOfControl)

	local colors = db.colors
	E:CooldownTextures(cooldown, E.Media.Textures.Edge, colors.edge, colors.swipe)
	E:CooldownTextures(data.chargeCooldown, E.Media.Textures.Edge2, colors.edgeCharge, colors.swipeCharge)
	E:CooldownTextures(data.lossOfControl, E.Media.Textures.Edge, colors.edgeLOC, colors.swipeLOC)
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

function E:RegisterCooldown(cooldown, which)
	if not which then which = 'global' end
	local db = E.db.cooldown.enable and E.db.cooldown[which]
	if not db then return end -- verify the settings exist here

	-- storage by cooldown (to grab a cooldowns data)
	if not E.RegisteredCooldowns[cooldown] then
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
	data.chargeCooldown = parent and (parent.chargeCooldown or parent.ChargeCooldown) or nil -- ChargeCooldown is the zone ability
	data.lossOfControl = parent and parent.lossOfControlCooldown or nil

	-- extract the blizzard cooldown region
	E:CooldownInitialize(cooldown)

	-- init set for the settings
	E:CooldownUpdate(cooldown)
end
