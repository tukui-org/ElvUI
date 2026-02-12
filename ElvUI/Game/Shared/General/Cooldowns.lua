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

function E:CooldownText(cooldown, db, hide)
	if not cooldown then return end

	cooldown:SetHideCountdownNumbers(hide)

	if not cooldown.Text then return end

	local colors = db.colors.text
	cooldown.Text:ClearAllPoints()
	cooldown.Text:SetTextColor(colors.r, colors.g, colors.b)
	cooldown.Text:Point('CENTER', nil, db.position, db.offsetX, db.offsetY)
	cooldown.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
end

function E:CooldownColors(cooldown, edge, swipe, alpha)
	if not cooldown then return end

	cooldown:SetEdgeColor(edge.r, edge.g, edge.b, alpha or edge.a)
	cooldown:SetSwipeColor(swipe.r, swipe.g, swipe.b, alpha or swipe.a)
end

function E:CooldownUpdate(cooldown)
	local db, data = E:CooldownData(cooldown)
	if not db then return end

	E:CooldownBling(cooldown)

	E:CooldownText(cooldown, db, db.hideNumbers)
	E:CooldownText(data.chargeCooldown, db, not db.chargeText)
	E:CooldownText(data.lossOfControl, db, not db.locText)

	local colors = db.colors
	local aurabars = data.which == 'aurabars' and 0 or nil
	E:CooldownColors(cooldown, colors.edge, colors.swipe, aurabars)
	E:CooldownColors(data.chargeCooldown, colors.edgeCharge, colors.swipeCharge)
	E:CooldownColors(data.lossOfControl, colors.edgeLOC, colors.swipeLOC)

	cooldown:SetDrawBling(not aurabars and not db.hideBling)
	cooldown:SetCountdownAbbrevThreshold(db.threshold)
	cooldown:SetMinimumCountdownDuration(db.minDuration) -- minimum duration above which text will be shown
	--cooldown:SetRotation(rad(db.rotation))
	cooldown:SetReverse(db.reverse)
end

function E:Cooldown_OnShow()
	if not self.mainCooldown then return end

	self.mainCooldown:SetHideCountdownNumbers(true)
end

function E:Cooldown_OnHide()
	local db = E:CooldownData(self.mainCooldown)
	if not db then return end

	self.mainCooldown:SetHideCountdownNumbers(db.hideNumbers)
end

function E:CooldownRegion(cooldown, main)
	if not cooldown then return end

	if not cooldown.Text then -- extract the timer text
		cooldown.Text = cooldown:GetRegions()
	end

	if main and not cooldown.mainCooldown then
		cooldown.mainCooldown = main

		cooldown:HookScript('OnShow', E.Cooldown_OnShow)
		cooldown:HookScript('OnHide', E.Cooldown_OnHide)
	end
end

function E:CooldownInitialize(cooldown)
	local db, data = E:CooldownData(cooldown)
	if not db then return end

	-- setup the text region
	E:CooldownRegion(cooldown)
	E:CooldownRegion(data.chargeCooldown, cooldown)
	E:CooldownRegion(data.lossOfControl, cooldown)

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
	data.chargeCooldown = parent and parent.chargeCooldown or nil
	data.lossOfControl = parent and parent.lossOfControlCooldown or nil

	-- extract the blizzard cooldown region
	E:CooldownInitialize(cooldown)

	-- init set for the settings
	E:CooldownUpdate(cooldown)
end
