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
		[1] = { --inner fire/will group
			["spells"] = {
				588, -- inner fire
				73413, -- inner will			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true
		},
	},
	HUNTER = {
		[1] = { --aspects group
			["spells"] = {
				13165, -- hawk
				5118, -- cheetah
				20043, -- wild
				82661, -- fox	
			},
			["instance"] = true,
			["personal"] = true,
		},				
	},
	MAGE = {
		[1] = { --armors group
			["spells"] = {
				7302, -- frost armor
				6117, -- mage armor
				30482, -- molten armor		
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},		
	},
	WARLOCK = {
		[1] = { --armors group
			["spells"] = {
				28176, -- fel armor
				687, -- demon armor			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
	},
	PALADIN = {
		[1] = { --Seals group
			["spells"] = {
				20154, -- seal of righteousness
				20164, -- seal of justice
				20165, -- seal of insight
				31801, -- seal of truth				
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
		[2] = { -- righteous fury group
			["spells"] = {
				25780, 
			},
			["role"] = "Tank",
			["instance"] = true,
			["reversecheck"] = true,
			["negate_reversecheck"] = 1, --Holy paladins use RF sometimes
		},
		[3] = { -- auras
			["spells"] = {
				465, --devo
				7294, --retr
				19746, -- conc
				19891, -- resist
			},
			["instance"] = true,
			["personal"] = true,
		},
	},
	SHAMAN = {
		[1] = { --shields group
			["spells"] = {
				52127, -- water shield
				324, -- lightning shield			
			},
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
		},
		[2] = { --check weapons for enchants
			["weapon"] = true,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
			["level"] = 10,
		},
	},
	WARRIOR = {
		[1] = { -- commanding Shout group
			["spells"] = {
				469, 
			},
			["negate_spells"] = {
				6307, -- Blood Pact
				90364, -- Qiraji Fortitude
				72590, -- Drums of fortitude
				21562, -- Fortitude				
			},
			["combat"] = true,
			["role"] = "Tank",
		},
		[2] = { -- battle Shout group
			["spells"] = {
				6673, 
			},
			["negate_spells"] = {
				8076, -- strength of earth
				57330, -- horn of Winter
				93435, -- roar of courage (hunter pet)						
			},
			["combat"] = true,
			["role"] = "Melee",
		},
	},
	DEATHKNIGHT = {
		[1] = { -- horn of Winter group
			["spells"] = {
				57330, 
			},
			["negate_spells"] = {
				8076, -- strength of earth totem
				6673, -- battle Shout
				93435, -- roar of courage (hunter pet)			
			},
			["combat"] = true,
		},
		[2] = { -- blood presence group
			["spells"] = {
				48263, 
			},
			["role"] = "Tank",
			["instance"] = true,	
			["reversecheck"] = true,
		},
	},
	ROGUE = { 
		[1] = { --weapons enchant group
			["weapon"] = true,
			["combat"] = true,
			["instance"] = true,
			["pvp"] = true,
			["level"] = 10,
		},
	},
}