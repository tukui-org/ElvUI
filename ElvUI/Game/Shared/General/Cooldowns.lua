local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local next = next

-- well, here we go again?
-- super WIP nothing is done lmao

E.RegisteredCooldowns = {}

function E:CooldownUpdate(cooldown, db)
	if not cooldown.Text then return end

	local _, anchor = cooldown.Text:GetPoint()

	cooldown.Text:ClearAllPoints()
	cooldown.Text:SetTextColor(db.color.r, db.color.g, db.color.b)
	cooldown.Text:Point('CENTER', anchor, db.position, db.offsetX, db.offsetY)
	cooldown.Text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)
end

function E:CooldownSettings(which)
	if not E.db.cooldown.enable then return end

	local cooldowns = E.RegisteredCooldowns[which]
	if not cooldowns then return end

	for cooldown, db in next, cooldowns do
		E:CooldownUpdate(cooldown, db)
	end
end

function E:RegisterCooldown(cooldown, which)
	if cooldown.isRegisteredCooldown or not E.db.cooldown.enable then return end

	-- verify the settings exist here
	local options = (which and E.db[which]) or (not which and E.db)
	if not options then return end

	-- storage for types
	if not which then which = 'global' end
	if not E.RegisteredCooldowns[which] then
		E.RegisteredCooldowns[which] = {}
	end

	-- storage for settings
	local data = E.RegisteredCooldowns[which]
	if not data[cooldown] then
		data[cooldown] = options.cooldown
	end

	-- extract the blizzard cooldown region
	if not cooldown.Text then
		cooldown.Text = cooldown:GetRegions()
	end

	-- init set for the settings
	E:CooldownUpdate(cooldown, options.cooldown)

	-- store some variables for later use
	cooldown.db = options.cooldown
	cooldown.isRegisteredCooldown = true
end
