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
lib:__RegisterSpells('MAGE', 80000, 2, {
	COOLDOWN = {
		   1953, -- Blink
		  31687, -- Summon Water Elemental (Frost)
		  55342, -- Mirror Image (talent)
		  84714, -- Frozen Orb (Frost)
		 153595, -- Comet Storm (Frost talent)
		 153626, -- Arcane Orb (Arcane talent)
		 190336, -- Conjure Refreshment
		 190356, -- Blizzard (Frost)
		 205032, -- Charged Up (Arcane talent)
		 212801, -- Displacement (Arcane)
		 212653, -- Shimmer (talent)
		 257537, -- Ebonbolt (Frost talent)
		[  2139] = 'INTERRUPT', -- Counterspell
		[157980] = 'KNOCKBACK', -- Supernova (Arcane talent)
		[235219] = 'SURVIVAL', -- Cold Snap (Frost)
		AURA = {
			HARMFUL = {
				155158, -- Meteor Burn (Fire talent)
				217694, -- Living Bomb (Fire talent) NOTE: initial
				244813, -- Living Bomb (Fire talent) NOTE: spread
				CROWD_CTRL = {
					[31661] = 'DISORIENT', -- Dragon's Breath (Fire)
					[82691] = 'INCAPACITATE', -- Ring of Frost (talent)
					ROOT = {
						   122, -- Frost Nova
						 33395, -- Freeze (Frost - Water Elemental)
						157997, -- Ice Nova (Frost talent)
					},
				},
				SNARE = {
					 205021, -- Ray of Frost (Frost talent)
					 212792, -- Cone of Cold (Frost)
					[157981] = 'KNOCKBACK', -- Blast Wave (Fire talent)
				},
			},
			HELPFUL = {
				[80353] = 'RAIDBUFF', -- Time Warp
				[80354] = 'RAIDBUFF INVERT_AURA', -- Temporal Displacement
			},
			PERSONAL = {
				  11426, -- Ice Barrier (Frost)
				 108839, -- Ice Floes (Frost talent)
				 198111, -- Temporal Shield (honor talent)
				 198144, -- Ice Form (Frost honor talent)
				 198158, -- Mass Invisibility (Arcane honor talent)
				 205025, -- Presence of Mind (Arcane)
				 206432, -- Burst of Cold (Frost honor talent)
				 210126, -- Arcane Familiar (Arcane talent)
				 270232, -- Freezing Rain (Frost talent)
				[ 12051] = 'POWER_REGEN', -- Evocation (Arcane)
				[ 41425] = 'INVERT_AURA', -- Hypothermia
				BURST = {
					 12042, -- Arcane Power (Arcane)
					 12472, -- Icy Veins (Frost)
					116014, -- Rune of Power (talent)
					190319, -- Combustion (Fire)
				},
				SURVIVAL = {
					    66, -- Invisibility (Fading)
					 32612, -- Invisibility
					 45438, -- Ice Block
					110960, -- Greater Invisibility (Arcane)
					113862, -- Greater Invisibility (Arcane) NOTE: damage reduction
					198065, -- Prismatic Cloak (honor talent)
					235313, -- Blazing Barrier (Fire)
					235450, -- Prismatic Barrier (Arcane)
				},
			},
			DISPEL = {
				[  475] = 'HELPFUL CURSE', -- Remove Curse
				[30449] = 'HARMFUL MAGIC', -- Spellsteal NOTE: has cooldown with Kleptomania (honor talent)
			},
		},
	},
	AURA = {
		HARMFUL = {
			 12654, -- Ignite (Fire)
			114923, -- Nether Tempest (Arcane talent)
			203277, -- Tinder (Fire honor talent)
			210824, -- Touch of the Magi (Arcane talent)
			226757, -- Conflagrate (Fire talent)
			228358, -- Winter's Chill (Frost)
			CROWD_CTRL = {
				[228600] = 'ROOT', -- Glacial Spike (Frost talent)
				INCAPACITATE = {
					   118, -- Polymorph (Sheep)
					 28271, -- Polymorph (Turtle)
					 28272, -- Polymorph (Pig)
					 61305, -- Polymorph (Black Cat)
					 61721, -- Polymorph (Rabbit)
					 61780, -- Polymorph (Turkey)
					126819, -- Polymorph (Porcupine)
					161353, -- Polymorph (Polar Bear Cub)
					161354, -- Polymorph (Monkey)
					161355, -- Polymorph (Penguin)
					161372, -- Polymorph (Peacock)
					277787, -- Polymorph (Direhorn)
					277792, -- Polymorph (Bumblebee)
				},
			},
			SNARE = {
				  2120, -- Flamestrike (Fire)
				 31589, -- Slow (Arcane)
				205708, -- Chilled (Frost)
				228354, -- Flurry (Frost)
				236299, -- Chrono Shift (Arcane talent)
			},
		},
		HELPFUL = {
			  130, -- Slow Fall
			[1459] = 'RAIDBUFF', -- Arcane Intellect
		},
		PERSONAL = {
			 44544, -- Fingers of Frost (Frost)
			 48108, -- Hot Streak! (Fire)
			157644, -- Enhanced Pyrotechnics (Fire)
			190446, -- Brain Freeze (Frost)
			205473, -- Icicles (Frost)
			205766, -- Bone Chilling (Frost talent)
			236060, -- Frenetic Speed (Fire talent)
			236298, -- Chrono Shift (Arcane talent)
			263725, -- Clearcasting (Arcane)
			264774, -- Rule of Threes (Arcane talent)
			269651, -- Pyroclasm (Fire talent)
			278310, -- Chain Reaction (Frost talent)
		},
	},
}, {
	-- map aura to provider(s)
	[ 12654] =  12846, -- Ignite (Fire) <- Mastery: Ignite
	[ 32612] =     66, -- Invisibility
	[ 41425] =  45438, -- Hypothermia <- Ice Block
	[ 44544] = 112965, -- Fingers of Frost (Frost)
	[ 48108] = 195283, -- Hot Streak! (Fire)
	[ 82691] = 113724, -- Ring of Frost (talent)
	[110960] = 110959, -- Greater Invisibility (Arcane)
	[113862] = 110959, -- Greater Invisibility (Arcane) NOTE: damage reduction
	[116014] = 116011, -- Rune of Power (talent)
	[155158] = 153561, -- Meteor Burn (Fire talent)
	[157644] = 157642, -- Enhanced Pyrotechnics (Fire)
	[190446] = 190447, -- Brain Freeze (Frost)
	[198065] = 198064, -- Prismatic Cloak (honor talent)
	[203277] = 203275, -- Tinder (Fire honor talent)
	[205708] = { -- Chilled (Frost)
		   116, -- Frostbolt
		 84714, -- Frozen Orb
		190356, -- Blizzard
	},
	[205473] =  76613, -- Icicles <- Mastery: Icicles (Frost)
	[205766] = 205027, -- Bone Chilling (Frost talent)
	[206432] = 206431, -- Burst of Cold (Frost honor talent)
	[210126] = 205022, -- Arcane Familiar (Arcane talent)
	[210824] = 210725, -- Touch of the Magi (Arcane talent)
	[212792] =    120, -- Cone of Cold (Frost)
	[217694] =  44457, -- Living Bomb (Fire talent) NOTE: initial
	[226757] = 205023, -- Conflagrate (Fire talent)
	[228358] = 231584, -- Winter's Chill (Frost) <- Brain Freeze (Rank 2)
	[228600] = 199786, -- Glacial Spike (Frost talent)
	[228354] =  44614, -- Flurry (Frost)
	[236060] = 236058, -- Frenetic Speed (Fire talent)
	[236298] = 235711, -- Chrono Shift (Arcane talent)
	[236299] = 235711, -- Chrono Shift (Arcane talent)
	[244813] =  44457, -- Living Bomb (Fire talent) NOTE: spread
	[263725] =  79684, -- Clearcasting (Arcane)
	[264774] = 264354, -- Rule of Threes (Arcane talent)
	[269651] = 269650, -- Pyroclasm (Fire talent)
	[270232] = 270233, -- Freezing Rain (Frost talent)
	[278310] = 278309, -- Chain Reaction (Frost talent)
}, {
	-- map aura to modified spell(s)
	[ 12654] = { -- Ignite (Fire)
		   133, -- Fireball
		  2120, -- Flamestrike
		  2948, -- Scorch
		 11366, -- Pyroblast
		108853, -- Fire Blast
		153561, -- Meteor (Fire talent)
		257541, -- Phoenix Flames (Fire talent)
	},
	[ 44544] =  30455, -- Fingers of Frost (Frost) -> Ice Lance
	[ 48108] = { -- Hot Streak! (Fire)
		 2120, -- Flamestrike
		11366, -- Pyroblast
	},
	[157644] =    133, -- Enhanced Pyrotechnics (Fire) -> Fireball
	[190446] =  44614, -- Brain Freeze (Frost) -> Flurry
	[198065] = { -- Prismatic Cloak (honor talent)
		  1953, -- Blink
		212653, -- Shimmer (talent)
	},
	[203277] =    133, -- Tinder (Fire honor talent) -> Fireball
	[205025] =  30451, -- Presence of Mind (Arcane) -> Arcane Blast
	[205473] =  { -- Icicles (Frost)
		 30455, -- Ice Lance
		199786, -- Glacial Spike (Frost talent)
	},
	[205766] = { -- Bone Chilling (Frost talent)
		   116, -- Frostbolt
		 84714, -- Frozen Orb
		190356, -- Blizzard
		205021, -- Ray of Frost (Frost talent)
	},
	[206432] =    120, -- Burst of Cold (Frost honor talent) -> Cone of Cold
	[210824] =  30451, -- Touch of the Magi (Arcane talent) -> Arcane Blast
	[226757] =    133, -- Conflagrate (Fire talent) -> Fireball
	[228358] =  44614, -- Winter's Chill (Frost) -> Flurry
	[236060] =   2948, -- Frenetic Speed (Fire talent) -> Scorch
	[236298] =  44425, -- Chrono Shift (Arcane talent) -> Arcane Barrage
	[236299] =  44425, -- Chrono Shift (Arcane talent) -> Arcane Barrage
	[263725] = { -- Clearcasting (Arcane)
		1449, -- Arcane Explosion
		5143, -- Arcane Missiles
	},
	[264774] = { -- Rule of Threes (Arcane talent)
		 5143, -- Arcane Missiles
		30451, -- Arcane Blast
	},
	[269651] =  11366, -- Pyroclasm (Fire talent) -> Pyroblast
	[270232] = 190356, -- Freezing Rain (Frost talent) -> Blizzard
	[278310] =  30455, -- Chain Reaction (Frost talent) -> Ice Lance
})
