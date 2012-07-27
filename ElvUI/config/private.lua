local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

--Locked Settings, These settings are stored for your character only regardless of profile options.

V['general'] = {
	['loot'] = false,
	['lootRoll'] = false,
	["normTex"] = "Minimalist",
	["glossTex"] = "Minimalist",	
	["dmgfont"] = "ElvUI Combat",
	['bubbles'] = true,
	['bags'] = true,
}

V['bags'] = {
	['enable'] = false,
	['bagBar'] = {
		['enable'] = false,
	},
}

V['reminder'] = {
	['enable'] = true,
	['sound'] = "ElvUI Warning",
}

V["nameplate"] = {
	["enable"] = false,
}

V['auras'] = {
	['enable'] = true,
	['size'] = 26,
}

V['chat'] = {
	['enable'] = true,
}

V['skins'] = {
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
		['barHeight'] = 16,
	},		
	['tinydps'] = {
		['enable'] = true,
	},			
	['clcret'] = {
		['enable'] = true,
	},			
	['clcprot'] = {
		['enable'] = true,
	},	
	['powerauras'] = {
		['enable'] = true,
	},		
	['weakauras'] = {
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
		['loot'] = true,
		["alertframes"] = true,
		["bgscore"] = true,
		["merchant"] = true,
		["mail"] = true,
		["help"] = true,
		["trade"] = true,
		["gossip"] = true,
		["greeting"] = true,
		["worldmap"] = true,
		["taxi"] = true,
		["quest"] = true,
		["petition"] = true,
		["dressingroom"] = true,
		["pvp"] = true,
		["lfg"] = true,
		["nonraid"] = true,
		["friends"] = true,
		["spellbook"] = true,
		["character"] = true,
		["misc"] = true,
		["tabard"] = true,
		["guildregistrar"] = true,
		["timemanager"] = true,
		["encounterjournal"] = true,
		["voidstorage"] = true,
		["transmogrify"] = true,
		["stable"] = true,
		["bgmap"] = true,
		['mounts'] = true,
		['petbattleui'] = true,
	},
}

V['tooltip'] = {
	['enable'] = true,
}

V['unitframe'] = {
	['enable'] = true,
	['disableBlizzard'] = true,	
}

V["actionbar"] = {
	["enable"] = true,
}