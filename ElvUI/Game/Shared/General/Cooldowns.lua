local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local next = next

local COOLDOWN_TYPE_LOSS_OF_CONTROL = COOLDOWN_TYPE_LOSS_OF_CONTROL or 1

E.RegisteredCooldowns = {}

function E:CooldownUpdate(cooldown, db)
	if not (db and cooldown.Text) then return end

	cooldown.Text:ClearAllPoints()
	cooldown.Text:SetTextColor(db.colors.text.r, db.colors.text.g, db.colors.text.b)
	cooldown.Text:Point('CENTER', nil, db.position, db.offsetX, db.offsetY)
	cooldown.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)

	cooldown:SetHideCountdownNumbers(db.hideNumbers) -- hide text
	cooldown:SetCountdownAbbrevThreshold(db.threshold)
	cooldown:SetMinimumCountdownDuration(db.minDuration) -- minimum duration above which text will be shown
	--cooldown:SetRotation(rad(db.rotation))
	cooldown:SetReverse(db.reverse)

	E:CooldownBling(cooldown)

	cooldown:SetDrawBling(db ~= 'aurabars' and not db.hideBling)
	cooldown:SetEdgeColor(db.colors.edge.r, db.colors.edge.g, db.colors.edge.b, (db == 'aurabars' and 0) or db.colors.edge.a)
	cooldown:SetSwipeColor(db.colors.swipe.r, db.colors.swipe.g, db.colors.swipe.b, (db == 'aurabars' and 0) or db.colors.swipe.a)

	if cooldown.charge then
		cooldown.charge:SetEdgeColor(db.colors.edgeCharge.r, db.colors.edgeCharge.g, db.colors.edgeCharge.b, db.colors.edgeCharge.a)
		cooldown.charge:SetSwipeColor(db.colors.swipeCharge.r, db.colors.swipeCharge.g, db.colors.swipeCharge.b, db.colors.swipeCharge.a)
	end
end

function E:CooldownSettings(which)
	if not E.db.cooldown.enable then return end

	local cooldowns = E.RegisteredCooldowns[which]
	if not cooldowns then return end

	for cooldown, db in next, cooldowns do
		E:CooldownUpdate(cooldown, db)
	end
end

do
	local blings = {}
	function E:CooldownBling(cooldown, alpha)
		local db = cooldown.db
		if not db then return end

		local texture = (alpha and alpha > 0.5) and (db.altBling and 131011 or 131010) or E.Media.Textures.Invisible
		if blings[cooldown] ~= texture then		-- dont change the texture unless we need to
			cooldown:SetBlingTexture(texture)	-- starburst or star4 or invisible

			blings[cooldown] = texture
		end
	end
end

function E:CooldownInitialize(cooldown, db, charge)
	if cooldown.Text or not db then return end

	cooldown:SetAllPoints() -- place the cd inside of its parent

	cooldown.Text = cooldown:GetRegions()

	cooldown:SetDrawEdge(true)
	cooldown:SetDrawSwipe(true)

	cooldown:SetEdgeTexture(charge and E.Media.Textures.Edge2 or E.Media.Textures.Edge, db.colors.edge.r, db.colors.edge.g, db.colors.edge.b, db.colors.edge.a)
	cooldown:SetSwipeTexture(E.media.blankTex, db.colors.swipe.r, db.colors.swipe.g, db.colors.swipe.b, db.colors.swipe.a)
end

function E:LABCooldownUpdate(cooldown)
	local db = cooldown.db
	local colors = db and db.colors
	if not colors then return end

	local color = colors[(cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and 'swipeLOC') or 'swipe']
	if color then
		cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
	end
end

function E:RegisterCooldown(cooldown, which)
	if cooldown.isRegisteredCooldown or not E.db.cooldown.enable then return end

	-- verify the settings exist here
	if not which then which = 'global' end
	local db = E.db.cooldown[which]
	if not db then return end

	-- storage for types
	if not E.RegisteredCooldowns[which] then
		E.RegisteredCooldowns[which] = {}
	end

	-- storage for settings
	local data = E.RegisteredCooldowns[which]
	if not data[cooldown] then
		data[cooldown] = db
	end

	-- store some variables for later use
	cooldown.db = db
	cooldown.isRegisteredCooldown = true

	-- extract the blizzard cooldown region
	E:CooldownInitialize(cooldown, db)

	-- reference the charge cooldown from LAB
	if which == 'actionbar' then
		local parent = cooldown:GetParent()
		if parent and parent.chargeCooldown then
			cooldown.charge = parent.chargeCooldown

			E:CooldownInitialize(cooldown.charge, db, true)
		end
	end

	-- init set for the settings
	E:CooldownUpdate(cooldown, db)
end
