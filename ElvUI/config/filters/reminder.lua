local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--[[
	Spell Reminder Arguments
	
	Type of Check:
		spells - List of spells in a group, if you have anyone of these spells the icon will hide.
		weapon - Run a weapon enchant check instead of a spell check
	
	Spells only Requirements:
		negate_spells - List of spells in a group, if you have anyone of these spells the icon will immediately hide and stop running the spell check (these should be other peoples spells)
		reversecheck - only works if you provide a role or a tree, instead of hiding the frame when you have the buff, it shows the frame when you have the buff, doesn't work with weapons
		negate_reversecheck - if reversecheck is set you can set a talent tree to not follow the reverse check, doesn't work with weapons
	
	Requirements: (These work for both spell and weapon checks)
		role - you must be a certain role for it to display (Tank, Melee, Caster)
		tree - you must be active in a specific talent tree for it to display (1, 2, 3) note: tree order can be viewed from left to right when you open your talent pane
		level - the minimum level you must be (most of the time we don't need to use this because it will register the spell learned event if you don't know the spell, but in the case of weapon enchants this is useful)
		personal - aura must come from the player
		
	Additional Checks: (Note we always run a check when gaining/losing an aura)
		instance - check when entering a party/raid instance
		pvp - check when entering a bg/arena
		combat - check when entering combat
	
	For every group created a new frame is created, it's a lot easier this way.
]]

E.ReminderBuffs = {
	PRIEST = {
		["Shields"] = { --inner fire/will group
			["spells"] = {
				[588] = true, -- inner fire
				[73413] = true, -- inner will			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true
		},
	},
	HUNTER = {
		["Aspects"] = { --aspects group
			["spells"] = {
				[13165] = true, -- hawk
				[5118] = true, -- cheetah
				[20043] = true, -- wild
				[82661] = true, -- fox	
			},
			["instance"] = true,
			["personal"] = true,
		},				
	},
	MAGE = {
		["Armors"] = { --armors group
			["spells"] = {
				[7302] = true, -- frost armor
				[6117] = true, -- mage armor
				[30482] = true, -- molten armor		
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},		
	},
	WARLOCK = {
		["Armors"] = { --armors group
			["spells"] = {
				[28176] = true, -- fel armor
				[687] = true, -- demon armor			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
	},
	PALADIN = {
		["Seals"] = { --Seals group
			["spells"] = {
				[20154] = true, -- seal of righteousness
				[20164] = true, -- seal of justice
				[20165] = true, -- seal of insight
				[31801] = true, -- seal of truth				
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
		["Righteous Fury"] = { -- righteous fury group
			["spells"] = {
				[25780] = true, 
			},
			["role"] = "Tank",
			["instance"] = true,
			["reversecheck"] = true,
			["negate_reversecheck"] = 1, --Holy paladins use RF sometimes
		},
		["Auras"] = { -- auras
			["spells"] = {
				[465] = true, --devo
				[7294] = true, --retr
				[19746] = true, -- conc
				[19891] = true, -- resist
			},
			["instance"] = true,
			["personal"] = true,
		},
	},
	SHAMAN = {
		["Shields"] = { --shields group
			["spells"] = {
				[52127] = true, -- water shield
				[324] = true, -- lightning shield			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
		["Weapon Enchants"] = { --check weapons for enchants
			["weapon"] = true,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
			["level"] = 10,
		},
	},
	WARRIOR = {
		["Commanding Shout"] = { -- commanding Shout group
			["spells"] = {
				[469] = true, 
			},
			["negate_spells"] = {
				[6307] = true, -- Blood Pact
				[90364] = true, -- Qiraji Fortitude
				[72590] = true, -- Drums of fortitude
				[21562] = true, -- Fortitude				
			},
			["combat"] = true,
			["role"] = "Tank",
		},
		["Battle Shout"] = { -- battle Shout group
			["spells"] = {
				[6673] = true, 
			},
			["negate_spells"] = {
				[8076] = true, -- strength of earth
				[57330] = true, -- horn of Winter
				[93435] = true, -- roar of courage (hunter pet)						
			},
			["combat"] = true,
			["role"] = "Melee",
		},
	},
	DEATHKNIGHT = {
		["Horn of Winter"] = { -- horn of Winter group
			["spells"] = {
				[57330] = true, 
			},
			["negate_spells"] = {
				[8076] = true, -- strength of earth totem
				[6673] = true, -- battle Shout
				[93435] = true, -- roar of courage (hunter pet)			
			},
			["combat"] = true,
		},
		["Blood Presence"] = { -- blood presence group
			["spells"] = {
				[48263] = true, 
			},
			["role"] = "Tank",
			["instance"] = true,	
			["reversecheck"] = true,
		},
	},
	ROGUE = { 
		["Weapon Enchants"] = { --weapons enchant group
			["weapon"] = true,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
			["level"] = 10,
		},
	},
}