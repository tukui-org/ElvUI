local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB

--Global Settings

G['general'] = {
	['profileBinds'] = false,
	['loot'] = true,
	['lootRoll'] = true,
	["normTex"] = "Minimalist",
	["glossTex"] = "Minimalist",	
	["dmgfont"] = "ElvUI Combat",
	['bubbles'] = true,
	['bags'] = true,
}

G['bags'] = {
	['enable'] = true,
	['bagBar'] = {
		['enable'] = true,
	},
}

G['classtimer'] = {
	['enable'] = true,
}

G['reminder'] = {
	['enable'] = true,
	['sound'] = "ElvUI Warning",
}

G["nameplate"] = {
	["enable"] = true,
}

G['auras'] = {
	['enable'] = true,
}

G['chat'] = {
	['enable'] = true,
}

G['skins'] = {
	['bigwigs'] = {
		['enable'] = true,
		['spacing'] = 7,
	},
	['ace3'] = {
		['enable'] = true,
	},
	['recount'] = {
		['enable'] = true,
	},	
	['dbm'] = {
		['enable'] = true,
	},		
	['dxe'] = {
		['enable'] = true,
	},	
	['omen'] = {
		['enable'] = true,
	},
	['skada'] = {
		['enable'] = true,
		['barHeight'] = 17,
	},		
	['tinydps'] = {
		['enable'] = true,
	},			
	['blizzard'] = {
		['enable'] = true,
		["bags"] = true,
		["reforge"] = true,
		["calendar"] = true,
		["achievement"] = true,
		["lfguild"] = true,
		["inspect"] = true,
		["binding"] = true,
		["gbank"] = true,
		["archaeology"] = true,
		["guildcontrol"] = true,
		["guild"] = true,
		["tradeskill"] = true,
		["raid"] = true,
		["talent"] = true,
		["glyph"] = true,
		["auctionhouse"] = true,
		["barber"] = true,
		["macro"] = true,
		["debug"] = true,
		["trainer"] = true,
		["socket"] = true,
		["achievement_popup"] = true,
		["bgscore"] = true,
		["merchant"] = true,
		["mail"] = true,
		["help"] = true,
		["trade"] = true,
		["gossip"] = true,
		["greeting"] = true,
		["worldmap"] = true,
		["taxi"] = true,
		["lfd"] = true,
		["quest"] = true,
		["petition"] = true,
		["dressingroom"] = true,
		["pvp"] = true,
		["nonraid"] = true,
		["friends"] = true,
		["spellbook"] = true,
		["character"] = true,
		["misc"] = true,
		["lfr"] = true,
		["tabard"] = true,
		["guildregistrar"] = true,
		["timemanager"] = true,
		["encounterjournal"] = true,
		["voidstorage"] = true,
		["transmogrify"] = true,
		["stable"] = true,
		["bgmap"] = true,
	},
}

G['tooltip'] = {
	['enable'] = true,
}

G['unitframe'] = {
	['enable'] = true,
	['aurafilters'] = {},
	['buffwatch'] = {},
	['disableBlizzard'] = true,	
}

G["actionbar"] = {
	["enable"] = true,
}