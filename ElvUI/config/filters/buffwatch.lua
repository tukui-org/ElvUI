--------------------------------------------------------------------------------------------
-- Buff Watch (Raid Frame Buff Indicator)
--------------------------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

-- Classbuffs { enabled, spell ID, position [, {r,g,b,a}][, anyUnit] }

local function ClassBuff(id, point, color, anyUnit, onlyShowMissing)
	local r, g, b = unpack(color)
	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b}, ["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing}
end

--Healer
E.HealerBuffIDs = {
	PRIEST = {
		ClassBuff(6788, "TOPLEFT", {1, 0, 0}, true), -- Weakened Soul
		ClassBuff(33076, "TOPRIGHT", {0.2, 0.7, 0.2}), -- Prayer of Mending
		ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Renew
		ClassBuff(17, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true), -- Power Word: Shield
		ClassBuff(10060 , "RIGHT", {227/255, 23/255, 13/255}), -- Power Infusion
		ClassBuff(33206, "LEFT", {227/255, 23/255, 13/255}, true), -- Pain Suppression
		ClassBuff(47788, "LEFT", {221/255, 117/255, 0}, true), -- Guardian Spirit
	},
	DRUID = {
		ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}), -- Rejuvenation
		ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}), -- Regrowth
		ClassBuff(94447, "TOPLEFT", {0.4, 0.8, 0.2}), -- Lifebloom
		ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Wild Growth
	},
	PALADIN = {
		ClassBuff(53563, "TOPRIGHT", {0.7, 0.3, 0.7}), -- Beacon of Light
		ClassBuff(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true), -- Hand of Protection
		ClassBuff(1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true), -- Hand of Freedom
		ClassBuff(6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true), -- Hand of Sacrafice
		ClassBuff(1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true) -- Hand of Salvation
	},
	SHAMAN = {
		ClassBuff(61295, "TOPLEFT", {0.7, 0.3, 0.7}), -- Riptide 
		ClassBuff(16236, "BOTTOMLEFT", {0.4, 0.7, 0.2}), -- Ancestral Fortitude
		ClassBuff(51945, "BOTTOMRIGHT", {0.7, 0.4, 0}), -- Earthliving
		ClassBuff(974, "TOPRIGHT", {221/255, 117/255, 0}, true), -- Earth Shield
	},
}

--DPS
E.DPSBuffIDs = {
	PALADIN = {
		ClassBuff(1022, "TOPRIGHT", {0.2, 0.2, 1}, true), -- Hand of Protection
		ClassBuff(1044, "TOPRIGHT", {221/255, 117/255, 0}, true), -- Hand of Freedom
		ClassBuff(6940, "TOPRIGHT", {227/255, 23/255, 13/255}, true), -- Hand of Sacrafice
		ClassBuff(1038, "TOPRIGHT", {238/255, 201/255, 0}, true), -- Hand of Salvation
	},
	ROGUE = {
		ClassBuff(57933, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Tricks of the Trade
	},
	DEATHKNIGHT = {
		ClassBuff(49016, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Hysteria
	},
	MAGE = {
		ClassBuff(54646, "TOPRIGHT", {0.2, 0.2, 1}), -- Focus Magic
	},
	WARRIOR = {
		ClassBuff(59665, "TOPLEFT", {0.2, 0.2, 1}), -- Vigilance
		ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Intervene
	},
}

--pets
E.PetBuffs = {
	HUNTER = {
		ClassBuff(136, "TOPRIGHT", {0.2, 0.8, 0.2}), -- Mend Pet
	},
	DEATHKNIGHT = {
		ClassBuff(91342, "TOPRIGHT", {0.2, 0.8, 0.2}), -- Shadow Infusion
		ClassBuff(63560, "TOPLEFT", {227/255, 23/255, 13/255}), --Dark Transformation
	},
	WARLOCK = {
		ClassBuff(47193, "TOPRIGHT", {227/255, 23/255, 13/255}), --Demonic Empowerment
	},
}