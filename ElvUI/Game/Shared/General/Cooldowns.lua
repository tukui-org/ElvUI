local E, L, V, P, G = unpack(ElvUI)

local next = next

-- well, here we go again?
-- super WIP nothing is done lmao

E.RegisteredCooldowns = {}

function E:CooldownUpdate(cooldown)
	if not cooldown then return end

end

function E:CooldownSettings(db)
	for cooldown in next, E.RegisteredCooldowns do

	end
end

function E:RegisterCooldown(cooldown, db)
	if cooldown.isRegisteredCooldown then return end

	cooldown.isRegisteredCooldown = true
end
