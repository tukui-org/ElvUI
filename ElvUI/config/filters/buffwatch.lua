--------------------------------------------------------------------------------------------
-- Buff Watch (Raid Frame Buff Indicator)
--------------------------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["raidframes"].raidunitbuffwatch ~= true then return end
-- Classbuffs { spell ID, position [, {r,g,b,a}][, anyUnit] }

--Healer
E.HealerBuffIDs = {
	PRIEST = {
		{6788, "TOPLEFT", {1, 0, 0}, true}, -- Weakened Soul
		{33076, "TOPRIGHT", {0.2, 0.7, 0.2}}, -- Prayer of Mending
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
		{17, "BOTTOMRIGHT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
		{10060 , "RIGHT", {227/255, 23/255, 13/255}}, -- Power Infusion
		{33206, "LEFT", {227/255, 23/255, 13/255}, true}, -- Pain Suppression
		{47788, "LEFT", {221/255, 117/255, 0}, true}, -- Guardian Spirit
	},
	DRUID = {
		{774, "TOPRIGHT", {0.8, 0.4, 0.8}}, -- Rejuvenation
		{8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}}, -- Regrowth
		{94447, "TOPLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
		{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}}, -- Wild Growth
	},
	PALADIN = {
		{53563, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Beacon of Light
		{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
		{1044, "BOTTOMRIGHT", {221/255, 117/255, 0}, true}, -- Hand of Freedom
		{6940, "BOTTOMRIGHT", {227/255, 23/255, 13/255}, true}, -- Hand of Sacrafice
		{1038, "BOTTOMRIGHT", {238/255, 201/255, 0}, true} -- Hand of Salvation
	},
	SHAMAN = {
		{61295, "TOPLEFT", {0.7, 0.3, 0.7}}, -- Riptide 
		{16236, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Ancestral Fortitude
		{51945, "BOTTOMRIGHT", {0.7, 0.4, 0}}, -- Earthliving
		{974, "TOPRIGHT", {221/255, 117/255, 0}, true}, -- Earth Shield
	},
	ALL = {
		{23333, "LEFT", {1, 0, 0}}, -- Warsong Flag
	},
}

--DPS
E.DPSBuffIDs = {
	PALADIN = {
		{1022, "TOPRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
		{1044, "TOPRIGHT", {221/255, 117/255, 0}, true}, -- Hand of Freedom
		{6940, "TOPRIGHT", {227/255, 23/255, 13/255}, true}, -- Hand of Sacrafice
		{1038, "TOPRIGHT", {238/255, 201/255, 0}, true}, -- Hand of Salvation
	},
	ROGUE = {
		{57933, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Tricks of the Trade
	},
	DEATHKNIGHT = {
		{49016, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Hysteria
	},
	MAGE = {
		{54646, "TOPRIGHT", {0.2, 0.2, 1}}, -- Focus Magic
	},
	WARRIOR = {
		{59665, "TOPLEFT", {0.2, 0.2, 1}}, -- Vigilance
		{3411, "TOPRIGHT", {227/255, 23/255, 13/255}}, -- Intervene
	},
	ALL = {
		{23333, "LEFT", {1, 0, 0}}, -- Warsong flag
	},
}

--pets
E.PetBuffs = {
	HUNTER = {
		{136, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Mend Pet
	},
	DEATHKNIGHT = {
		{91342, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Shadow Infusion
		{63560, "TOPLEFT", {227/255, 23/255, 13/255}}, --Dark Transformation
	},
	WARLOCK = {
		{47193, "TOPRIGHT", {227/255, 23/255, 13/255}}, --Demonic Empowerment
	},
}