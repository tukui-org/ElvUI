local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine
--[[
	Spell Reminder Arguments
	
	General:
		enable - turn the reminder off and on.
		strictFilter - allow the use of spells that are not actually in your spellbook (Spell Procs)
		disableSound - Don't play the warning sound.
		
	Type of Check:
		spellGroup - List of spells in a group, if you have anyone of these spells the icon will hide.
		weaponCheck - Run a weapon enchant check instead of a spell check
		CDSpell - Run checks to see if a spell is on cooldown or not.
		
	Spells only Requirements:
		negateGroup - List of spells in a group, if you have anyone of these spells the icon will immediately hide and stop running the spell check (these should be other peoples spells)
		reverseCheck - only works if you provide a role or a tree, instead of hiding the frame when you have the buff, it shows the frame when you have the buff, doesn't work with weapons
		talentTreeException - if reverseCheck is set you can set a talent tree to not follow the reverse check, doesn't work with weapons
	
	Cooldown only Requirements:
		OnCooldown - Set to "SHOW or "HIDE".
	
	Requirements: (These work for both spell and weapon checks)
		role - you must be a certain role for it to display (Tank, Melee, Caster)
		tree - you must be active in a specific talent tree for it to display (1, 2, 3) note: tree order can be viewed from left to right when you open your talent pane
		minLevel - the minimum level you must be (most of the time we don't need to use this because it will register the spell learned event if you don't know the spell, but in the case of weapon enchants this is useful)
		personal - aura must come from the player
		
	Additional Checks: (Note we always run a check when gaining/losing an aura)
		instance - check when entering a party/raid instance
		pvp - check when entering a bg/arena
		combat - check when entering combat

	For every group created a new frame is created, it's a lot easier this way.
]]

G['reminder']['filters'] = {
	PRIEST = {

	},
	HUNTER = {

	},
	MAGE = {

	},
	WARLOCK = {

	},
	PALADIN = {
		["Righteous Fury"] = { -- righteous fury group
			["spellGroup"] = {
				[25780] = true, 
			},
			["role"] = "Tank",
			["instance"] = true,
			["talentTreeException"] = 2, --Don't run reverse check for prot paladins, holy paladins you have to disable this if it annoys you sorry.
			['enable'] = true,
			['strictFilter'] = true,
		},
	},
	SHAMAN = {
	
	},
	WARRIOR = {

	},
	DEATHKNIGHT = {

	},
	ROGUE = { 

	},
	DRUID = {
	},
}