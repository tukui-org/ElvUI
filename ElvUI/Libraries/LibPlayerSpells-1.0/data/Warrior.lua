--[[
LibPlayerSpells-1.0 - Additional information about player spells.
(c) 2013-2018 Adirelle (adirelle@gmail.com)

This file is part of LibPlayerSpells-1.0.

LibPlayerSpells-1.0 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibPlayerSpells-1.0 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibPlayerSpells-1.0. If not, see <http://www.gnu.org/licenses/>.
--]]

local lib = LibStub('LibPlayerSpells-1.0')
if not lib then return end
lib:__RegisterSpells('WARRIOR', 80000, 1, {
	COOLDOWN = {
			845, -- Cleave (Arms talent)
		   5308, -- Execute (Fury)
		   6544, -- Heroic Leap
		  57755, -- Heroic Throw
		 202168, -- Impending Victory (talent)
		[  6552] = 'INTERRUPT', -- Pummel
		[206572] = 'KNOCKBACK', -- Dragon Charge (Protection honor talent)
		AURA = {
			HARMFUL = {
				 115804, -- Mortal Wounds (Arms)
				 198819, -- Mortal Strike (Arms honor talent)
				 198912, -- Shield Bash (Protection honor talent)
				 206891, -- Intimidated (Protection honor talent)
				 236077, -- Disarm (honor talent)
				 236273, -- Duel (Arms honor talent)
				 275335, -- Punish (Protection talent)
				[  1160] = 'SURVIVAL', -- Demoralizing Shout (Protection)
				BURST = {
					208086, -- Colossus Smash (Arms)
					280773, -- Siegebreaker (Fury talent)
				},
				CROWD_CTRL = {
					[ 355] = 'TAUNT', -- Taunt
					[5246] = 'DISORIENT', -- Intimidating Shout
					ROOT = {
						105771, -- Charge
						199042, -- Thunderstruck (Protection honor talent)
					},
					STUN = {
						132168, -- Shockwave (Protection)
						132169, -- Storm Bolt (talent)
						199095, -- Warpath (Protection honor talent)
					},
				},
				SNARE = {
					  6343, -- Thunder Clap (Protection)
					118000, -- Dragon Roar (Fury/Protection talent)
				},
			},
			HELPFUL = {
				  97463, -- Rallying Cry (Protection)
				 147833, -- Intervene (Protection)
				 199038, -- Leave No Man Behind (Protection honor talent)
				 223658, -- Safeguard (Protection talent)
				 236321, -- War Banner (Arms honor talent)
				[213871] = 'SURVIVAL', -- Bodyguard (Protection honor talent)
			},
			PERSONAL = {
				  7384, -- Overpower (Arms)
				 18499, -- Berserker Rage
				 46924, -- Bladestorm (Fury talent)
				198817, -- Sharpen Blade (Arms honor talent)
				199203, -- Thirst for Battle (Fury honor talent)
				199261, -- Death Wish (Fury honor talent)
				202164, -- Bounding Stride (talent)
				202225, -- Furious Charge (Fury talent)
				213858, -- Battle Trance (Fury honor talent)
				215572, -- Frothing Berserker (Fury talent)
				227847, -- Bladestorm (Arms)
				248622, -- In For The Kill (Arms)
				260708, -- Sweeping Strikes (Arms)
				280746, -- Barbarian (Fury honor talent)
				BURST = {
					  1719, -- Recklessness (Fury)
					107574, -- Avatar (Protection, Arms talent)
					262228, -- Deadly Calm (Arms talent)
				},
				SURVIVAL = {
					   871, -- Shield Wall (Protection)
					 12975, -- Last Stand (Protection)
					 23920, -- Spell Reflection (Protection)
					118038, -- Die by the Sword (Arms)
					132404, -- Shield Block (Protection)
					184364, -- Enraged Regeneration (Fury)
					190456, -- Ignore Pain (Protection)
					197690, -- Defensive Stance (Arms talent)
					213915, -- Mass Spell Reflection (Protection honor talent)
					216890, -- Spell Reflection (Arms/Fury honor talent)
					227744, -- Ravager (Protection talent)
				},
			},
		},
		POWER_REGEN = {
			 23881, -- Bloodthirst (Fury)
			 23922, -- Shield Slam (Protection)
			 85288, -- Raging Blow (Fury)
			152277, -- Ravager (Arms talent)
			260643, -- Skullsplitter (Arms talent)
		},
	},
	AURA = {
		HARMFUL = {
			   772, -- Rend (Arms talent)
			115767, -- Deep Wounds (Protection)
			262115, -- Deep Wounds (Arms)
			SNARE = {
				 1715, -- Hamstring (Arms)
				12323, -- Piercing Howl (Fury)
			},
		},
		HELPFUL = {
			[6673] = 'RAIDBUFF', -- Battle Shout
		},
		PERSONAL = {
			  5302, -- Revenge (Protection)
			 32216, -- Victory Rush
			 52437, -- Sudden Death (Arms talent)
			 85739, -- Whirlwind (Fury)
			184362, -- Enrage (Fury)
			202539, -- Furious Stash (Fury talent)
			202573, -- Vengeance: Revenge (Protection talent)
			202574, -- Vengeance: Ignore Pain (Protection talent)
			280776, -- Suddeen Death (Fury talent)
		},
	},
}, {
	-- Map aura to provider(s)
	[  5302] =   6572, -- Revenge (Protection)
	[ 32216] =  34428, -- Victory Rush
	[ 52437] =  29725, -- Sudden Death (Arms talent)
	[ 85739] = 190411, -- Whirlwind (Fury)
	[ 97463] =  97462, -- Rallying Cry
	[105771] = { -- Charge
		   100, -- Charge (Arms/Fury)
		198304, -- Intercept (Protection)
	},
	[115767] = 115768, -- Deep Wounds (Protection)
	[115804] =  12294, -- Mortal Wounds (Arms) <- Mortal Strike
	[132168] =  46968, -- Shockwave (Protection)
	[132169] = 107570, -- Storm Bolt (talent)
	[132404] =   2565, -- Shield Block (Protection)
	[147833] = 198304, -- Intervene (Protection) <- Intercept
	[184362] = 184361, -- Enrage (Fury)
	[198819] = 198817, -- Mortal Strike <- Sharpen Blade (Arms honor talent)
	[199038] = 199037, -- Leave No Man Behind (Protection honor talent)
	[199042] = 199045, -- Thunderstruck (Protection honor talent)
	[199095] = 198096, -- Warpath (Protection honor talent)
	[199203] = 199202, -- Thirst for Battle (Fury honor talent)
	[202164] = 202163, -- Bounding Stride (talent)
	[202225] = 202224, -- Furious Charge (Fury talent)
	[202539] = 100130, -- Furious Stash (Fury talent)
	[202573] = 202572, -- Vengeance: Revenge <- Vengeance (Protection talent)
	[202574] = 202572, -- Vengeance: Ignore Pain <- Vengeance (Protection talent)
	[213858] = 213857, -- Battle Trance (Fury honor talent)
	[215572] = 215571, -- Frothing Berserker (Fury talent)
	[206891] = 205800, -- Intimidated (Protection honor talent)
	[208086] = { -- Colossus Smash (Arms)
		167105, -- Colossus Smash
		262161, -- Warbreaker (Arms talent)
	},
	[223658] = 223657, -- Safeguard (Protection talent)
	[227744] = 228920, -- Ravager (Protection talent)
	[236321] = 236320, -- War Banner (Arms honor talent)
	[248622] = 248621, -- In For The Kill (Arms)
	[262115] = 262111, -- Deep Wounds (Arms) <- Mastery: Deep Wounds
	[275335] = 275334, -- Punish (Protection talent)
	[280746] = 280745, -- Barbarian (Fury honor talent)
	[280773] = 280772, -- Siegebreaker (Fury talent)
	[280776] = 280721, -- Suddeen Death (Fury talent)
}, {
	-- map aura to modified spell(s)
	[  7384] =  12294, -- Overpower (Arms) -> Mortal Strike
	[ 52437] = 163201, -- Sudden Death (Arms talent)
	[115767] = { -- Deep Wounds (Protection)
		 6572, -- Revenge
		20243, -- Devastate
	},
	[184362] = { -- Enrage (Fury)
		 23881, -- Bloodthirst
		184367, -- Rampage
	},
	[197690] = 212520, -- Defensive Stance (Arms talent)
	[198819] =  12294, -- Mortal Strike (Arms honor talent) -> Mortal Strike
	[199038] = 198304, -- Leave No Man Behind (Protection honor talent) -> Intercept
	[199042] =   6343, -- Thunderstruck (Protection honor talent) -> Thunder Clap
	[199095] =   6544, -- Warpath (Protection honor talent) -> Heroic Leap
	[199203] =  23881, -- Thirst for Battle (Fury honor talent) -> Bloodthirst
	[202164] =   6544, -- Bounding Stride (talent) -> Heroic Leap
	[202225] =  23881, -- Furious Charge (Fury talent) -> Bloodthirst
	[202573] =   6572, -- Vengeance: Revenge (Protection talent) -> Revenge
	[202574] = 190456, -- Vengeance: Ignore Pain (Protection talent) -> Ignore Pain
	[213858] =  85288, -- Battle Trance (Fury honor talent) -> Raging Blow
	[215572] = 184367, -- Frothing Berserker (Fury talent) -> Rampage
	[223658] = 198304, -- Safeguard (Protection talent) -> Intercept
	[248622] = { -- In For The Kill (Arms)
		167105, -- Colossus Smash
		262161, -- Warbreaker (Arms talent)
	},
	[262115] = { -- Deep Wounds (Arms) <- Mastery: Deep Wounds
		   845, -- Cleave (Arms talent)
		 12294, -- Mortal Strike
		163201, -- Execute
		227847, -- Bladestorm
	},
	[275335] =  23922, -- Punish (Protection talent)
	[280746] =   6544, -- Barbarian (Fury honor talent) -> Heroic Leap
	[280776] =   5308, -- Suddeen Death (Fury talent) -> Execute
})
