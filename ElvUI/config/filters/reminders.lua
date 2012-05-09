local E, L, V, P, G = unpack(select(2, ...)); --Engine
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
		talentTreeException - if reverseCheck is set you can set a talent tree to follow the reverse check if not set then all trees follow the reverse check, doesn't work with weapons
	
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
		["Shields"] = { --inner fire/will group
			["spellGroup"] = {
				[588] = true, -- inner fire
				[73413] = true, -- inner will			
			},
			["instance"] = true,
			["pvp"] = true,
			['enable'] = true,
			['strictFilter'] = true,
		},

	},
	HUNTER = {
		["Aspects"] = { --aspects group
			["spellGroup"] = {
				[13165] = true, -- hawk
				[5118] = true, -- cheetah
				[20043] = true, -- wild
				[82661] = true, -- fox	
			},
			["combat"] = true,
			["instance"] = true,
			["personal"] = true,
			['enable'] = true,
			['strictFilter'] = true,
		},	
	},
	MAGE = {
		["Armors"] = { --armors group
			["spellGroup"] = {
				[7302] = true, -- frost armor
				[6117] = true, -- mage armor
				[30482] = true, -- molten armor		
			},
			["instance"] = true,
			["pvp"] = true,
			['enable'] = true,
			['strictFilter'] = true,
		},		
	},
	WARLOCK = {
		["Armors"] = { --armors group
			["spellGroup"] = {
				[28176] = true, -- fel armor
				[687] = true, -- demon armor			
			},
			["instance"] = true,
			["pvp"] = true,
			['enable'] = true,
			['strictFilter'] = true,
		},
	},
	PALADIN = {
		["Seals"] = { --Seals group
			["spellGroup"] = {
				[20154] = true, -- seal of righteousness
				[20164] = true, -- seal of justice
				[20165] = true, -- seal of insight
				[31801] = true, -- seal of truth				
			},
			["instance"] = true,
			["pvp"] = true,
			['enable'] = true,
			['strictFilter'] = true,
		},
		["Righteous Fury"] = { -- righteous fury group
			["spellGroup"] = {
				[25780] = true, 
			},
			["role"] = "Tank",
			["instance"] = true,
			["reverseCheck"] = true,
			["talentTreeException"] = 3, --Holy paladins use RF sometimes, only run the reverse check for retribution.
			['enable'] = true,
			['strictFilter'] = true,
		},
		["Auras"] = { -- auras
			["spellGroup"] = {
				[465] = true, --devo
				[7294] = true, --retr
				[19746] = true, -- conc
				[19891] = true, -- resist
			},
			["instance"] = true,
			["personal"] = true,
			['enable'] = true,
			['strictFilter'] = true,
		},	
	},
	SHAMAN = {
		["Shields"] = { --shields group
			["spellGroup"] = {
				[52127] = true, -- water shield
				[324] = true, -- lightning shield			
			},
			["instance"] = true,
			["pvp"] = true,
			['enable'] = true;
		},
		["Weapon Enchants"] = { --check weapons for enchants
			["weaponCheck"] = true,
			["instance"] = true,
			["pvp"] = true,
			["minLevel"] = 10,
			['enable'] = true,
			['disableSound'] = true,
		},		
	},
	WARRIOR = {
		["Commanding Shout"] = { -- commanding Shout group
			["spellGroup"] = {
				[469] = true, 
			},
			["negateGroup"] = {
				[6307] = true, -- Blood Pact
				[90364] = true, -- Qiraji Fortitude
				[72590] = true, -- Drums of fortitude
				[21562] = true, -- Fortitude				
			},
			["role"] = "Tank",
			["instance"] = true,
			["pvp"] = true,
			['enable'] = true,
			['strictFilter'] = true,		
		},
		["Battle Shout"] = { -- battle Shout group
			["spellGroup"] = {
				[6673] = true, 
			},
			["negateGroup"] = {
				[8076] = true, -- strength of earth
				[57330] = true, -- horn of Winter
				[93435] = true, -- roar of courage (hunter pet)						
			},
			["instance"] = true,
			["pvp"] = true,	
			["role"] = "Melee",
			['enable'] = true,
			['strictFilter'] = true,
		},	
	},
	DEATHKNIGHT = {
		["Horn of Winter"] = { -- horn of Winter group
			["spellGroup"] = {
				[57330] = true, 
			},
			["negateGroup"] = {
				[8076] = true, -- strength of earth totem
				[6673] = true, -- battle Shout
				[93435] = true, -- roar of courage (hunter pet)			
			},
			["instance"] = true,
			["pvp"] = true,	
			['enable'] = true,
			['strictFilter'] = true,
		},
		["Blood Presence"] = { -- blood presence group
			["spellGroup"] = {
				[48263] = true, 
			},
			["role"] = "Tank",
			["instance"] = true,	
			["reverseCheck"] = true,
			['enable'] = true,
			['strictFilter'] = true,
		},	
	},
	ROGUE = { 
		["Weapon Enchants"] = { --weapons enchant group
			["weaponCheck"] = true,
			["instance"] = true,
			["pvp"] = true,
			["minLevel"] = 10,
			['enable'] = true,
			['disableSound'] = true,
		},	
	},
	DRUID = {
	},
}