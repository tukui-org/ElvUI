local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local next = next

E.RegisteredCooldowns = {}

function E:CooldownUpdate(cooldown, db)
	if not cooldown.Text then return end

	local colors = db.colors
	cooldown.Text:ClearAllPoints()
	cooldown.Text:SetTextColor(colors.text.r, colors.text.g, colors.text.b)
	cooldown.Text:Point('CENTER', nil, db.position, db.offsetX, db.offsetY)
	cooldown.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)

	cooldown:SetInside() -- place the cd inside of its parent

	cooldown:SetEdgeColor(colors.edge.r, colors.edge.g, colors.edge.b, colors.edge.a)
	cooldown:SetSwipeColor(colors.swipe.r, colors.swipe.g, colors.swipe.b, colors.swipe.a)

	cooldown:SetHideCountdownNumbers(db.hideNumbers) -- hide text
	cooldown:SetCountdownAbbrevThreshold(db.threshold)
	cooldown:SetMinimumCountdownDuration(db.minDuration) -- minimum duration above which text will be shown
	--cooldown:SetRotation(rad(db.rotation))
	cooldown:SetReverse(db.reverse)

	cooldown:SetDrawEdge(not db.hideEdge)
	cooldown:SetDrawBling(not db.hideBling)
	cooldown:SetDrawSwipe(not db.hideSwipe)

	-- cooldown:SetBlingTexture(texture)
	-- cooldown:SetEdgeTexture(texture) -- texture which follows the moving edge of the cooldown
end

function E:CooldownSettings(which)
	if not E.db.cooldown.enable then return end

	local cooldowns = E.RegisteredCooldowns[which]
	if not cooldowns then return end

	for cooldown, db in next, cooldowns do
		E:CooldownUpdate(cooldown, db)
	end
end

function E:OnCooldownUpdate(cooldown) -- chain from LibActionButton
	local db = cooldown.db
	local colors = db and db.colors
	if not colors then return end

	local color = colors[(cooldown.currentCooldownType == _G.COOLDOWN_TYPE_LOSS_OF_CONTROL and 'swipeLOC') or 'swipe']
	cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
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
	if not cooldown.Text then
		cooldown.Text = cooldown:GetRegions()

		cooldown:SetSwipeTexture(E.media.blankTex, db.colors.swipe.r, db.colors.swipe.g, db.colors.swipe.b, db.colors.swipe.a)
		cooldown:SetEdgeTexture(E.Media.Textures.Edge, db.colors.edge.r, db.colors.edge.g, db.colors.edge.b, db.colors.edge.a)
	end

	-- init set for the settings
	E:CooldownUpdate(cooldown, db)
end
