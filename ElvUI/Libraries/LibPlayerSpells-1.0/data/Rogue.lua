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
lib:__RegisterSpells('ROGUE', 80000, 1, {
	COOLDOWN = {
		   1725, -- Distract
		 195457, -- Grappling Hook (Outlaw)
		 200806, -- Exsanguinate (Assassination talent)
		 280719, -- Secret Technique (Subtlety talent)
		[  1766] = 'INTERRUPT', -- Kick
		[248744] = 'DISPEL HARMFUL ENRAGE', -- Shiv (honor talent)
		AURA = {
			HARMFUL = {
				    703, -- Garrote (Assassination)
				   1330, -- Garrote - Silence (Assassination)
				 154953, -- Internal Bleeding (Assassination)
				 196937, -- Ghostly Strike (Outlaw talent)
				 197091, -- Neurotoxin (Assassination honor talent)
				 198529, -- Plunder Armor (Outlaw honor talent)
				 207777, -- Dismantle (Outlaw honor talent)
				 212150, -- Cheap Tricks (Outlaw honor talent)
				 245389, -- Toxic Blade (Assassination talent)
				 255909, -- Prey on the Weak (talent)
				 207736, -- Shadowy Duel (Subtlety honor talent)
				[248744] = 'SNARE', -- Shiv (honor talent)
				BURST = {
					 79140, -- Vendetta (Assassination)
					121471, -- Shadow Blades (Subtlety)
					137619, -- Marked for Death (talent)
				},
				CROWD_CTRL = {
					[1766] = 'INCAPACITATE', -- Gouge (Outlaw)
					[2094] = 'DISORIENT', -- Blind
					STUN = {
						   408, -- Kidney Shot (Assassination/Subtlety)
						199804, -- Between the Eyes (Outlaw)
					},
				},
			},
			HELPFUL = {
				  57934, -- Tricks of the Trade
				 212183, -- Smoke Bomb (honor talent)
				 212198, -- Crimson Vial (Outlaw honor talent)
				[221630] = 'BURST', -- Tricks of the Trade (Outlaw honor talent)
			},
			PERSONAL = {
				   2983, -- Sprint
				  11327, -- Vanish
				  13877, -- Blade Flurry (Outlaw)
				  36554, -- Shadowstep (Assassination/Subtlety)
				  51690, -- Killing Spree (Outlaw talent)
				 114018, -- Shroud of Concealment
				 185422, -- Shadow Dance (Subtlety)
				 197003, -- Maneuverability (Assassination/Outlaw honor talent)
				 213981, -- Cold Blood (Subtlety honor talent)
				 213995, -- Cheap Tricks (Outlaw honor talent)
				 256171, -- Loaded Dice (Outlaw talent)
				 269513, -- Death from Above (honor talent)
				 271896, -- Blade Rush (Outlaw talent)
				 277925, -- Shuriken Tornado (Subtlety talent)
				[196980] = 'POWER_REGEN', -- Master of Shadows (Subtlety)
				BURST = {
					  13750, -- Adrenalin Rush (Outlaw)
					[212283] = 'POWER_REGEN', -- Symbols of Death (Subtlety)
				},
				SURVIVAL = {
					  1966, -- Feint
					  5277, -- Evasion (Assassination/Subtlety)
					 31224, -- Cloak of Shadows
					185311, -- Crimson Vial
					199754, -- Riposte (Outlaw)
				},
			},
		},
	},
	AURA = {
		HARMFUL = {
			  1943, -- Rupture (Assassination)
			  2818, -- Deadly Poison (Assassination)
			  8680, -- Wound Poison (Assassination)
			 91021, -- Find Weakness (Subtlety talent)
			121411, -- Crimson Tempest (Assassination talent)
			195452, -- Nightblade (Subtlety)
			197046, -- Minor Wound Poison (Assassination honor talent)
			197051, -- Mind-Numbing Poison (Assassination honor talent)
			198097, -- Creeping Venom (Assassination honor talent)
			198688, -- Dagger in the Dark (Subtlety honor talent)
			256148, -- Iron Wire (Assassination talent)
			CROWD_CTRL = {
				[1833] = 'STUN', -- Cheap Shot
				[6770] = 'INCAPACITATE', -- Sap
			},
			SNARE = {
				  3409, -- Crippling Poison (Assassination)
				185763, -- Pistol Shot (Outlaw)
				198222, -- System Shock (Assassination honor talent)
				206760, -- Shadow's Grasp (Subtlety)
			},
		},
		HELPFUL = {
			198368, -- Take Your Cut (Outlaw honor talent)
			209754, -- Boarding Party (Outlaw honor talent)
		},
		PERSONAL = {
			  1784, -- Stealth
			  2823, -- Deadly Poison (Assassination)
			  3408, -- Crippling Poison (Assassination)
			  5171, -- Slice and Dice (Outlaw talent)
			  8679, -- Wound Poison (Assassination)
			 32645, -- Envenom (Assassination)
			108211, -- Leeching Poison (Assassination talent)
			115191, -- Stealth (with Subterfuge talent)
			115192, -- Subterfuge (Assassination/Subtlety talent)
			121153, -- Blindside (Assassination talent)
			193356, -- Broadside (Outlaw)
			193357, -- Ruthless Precision (Outlaw)
			193358, -- Grand Melee (Outlaw)
			193359, -- True Bearing (Outlaw)
			193538, -- Alacrity (Outlaw/Subtlety talent)
			193641, -- Elaborate Planning (Assassination talent)
			195627, -- Opportunity (Outlaw)
			199027, -- Veil of Midnight (Subtlety honor talent)
			199600, -- Buried Treasure (Outlaw)
			199603, -- Skull and Crossbones (Outlaw)
			245640, -- Shuriken Combo (Subtlety)
			256735, -- Master Assassin (Assassination talent)
			257506, -- Shot in the Dark (Subtlety talent)
			270070, -- Hidden Blades (Assassination talent)
		},
	},
}, {
	-- map aura to provider(s)
	[  1330] =    703, -- Garrote - Silence <- Garrote (Assassination)
	[  2818] =   2823, -- Deadly Poison (Assassination)
	[  3409] =   3408, -- Crippling Poison (Assassination)
	[  8680] =   8679, -- Wound Poison (Assassination)
	[ 11327] =   1856, -- Vanish
	[ 91021] =  91023, -- Find Weakness (Subtlety talent)
	[108211] = 280716, -- Leeching Poison (Assassination talent)
	[115192] = 108208, -- Subterfuge (Assassination/Subtlety talent)
	[121153] = 111240, -- Blindside (Assassination talent)
	[154953] = 154904, -- Internal Bleeding (Assassination)
	[185422] = 185313, -- Shadow Dance (Subtlety)
	[193356] = 193316, -- Broadside <- Roll the Bones (Outlaw)
	[193357] = 193316, -- Ruthless Precision <- Roll the Bones (Outlaw)
	[193358] = 193316, -- Grand Melee <- Roll the Bones (Outlaw)
	[193359] = 193316, -- True Bearing <- Roll the Bones (Outlaw)
	[193538] = 193539, -- Alacrity (Outlaw/Subtlety talent)
	[193641] = 193640, -- Elaborate Planning (Assassination talent)
	[195627] = 193315, -- Opportunity <- Sinister Strike (Outlaw)
	[196980] = 196976, -- Master of Shadows (Subtlety)
	[197003] = 197000, -- Maneuverability (Outlaw honor talent)
	[197046] = 197044, -- Minor Wound Poison <- Deadly Brew (Assassination honor talent)
	[197051] = 197050, -- Mind-Numbing Poison (Assassination honor talent)
	[197091] = 206328, -- Neurotoxin (Assassination honor talent)
	[198097] = 198092, -- Creeping Venom (Assassination honor talent)
	[198222] = 198145, -- System Shock (Assassination honor talent)
	[198368] = 198265, -- Take Your Cut (Outlaw honor talent)
	[198688] = 198675, -- Dagger in the Dark (Subtlety honor talent)
	[199027] = 198952, -- Veil of Midnight (Subtlety honor talent)
	[199600] = 193316, -- Buried Treasure <- Roll the Bones (Outlaw)
	[199603] = 193316, -- Skull and Crossbones <- Roll the Bones (Outlaw)
	[206760] = 277950, -- Shadow's Grasp (Subtlety)
	[209754] = 209752, -- Boarding Party (Outlaw honor talent)
	[212183] = 212182, -- Smoke Bomb (honor talent)
	[212150] = 212035, -- Cheap Tricks (Outlaw honor talent)
	[212198] = 212210, -- Crimson Vial <- Drink Up Me Hearties (Outlaw honor talent)
	[213995] = 212035, -- Cheap Tricks (Outlaw honor talent)
	[221630] = 221622, -- Tricks of the Trade <- Thick as Thieves (Outlaw honor talent)
	[245389] = 245388, -- Toxic Blade (Assassination talent)
	[245640] = 245639, -- Shuriken Combo (Subtlety)
	[255909] = 131511, -- Prey on the Weak (Assassination/Outlaw talent)
	[256148] = 196861, -- Iron Wire (Assassination talent)
	[256171] = 256170, -- Loaded Dice (Outlaw talent)
	[256735] = 255989, -- Master Assassin (Assassination talent)
	[257506] = 257505, -- Shot in the Dark (Subtlety talent)
	[270070] = 270061, -- Hidden Blades (Assassination talent)
	[271896] = 271877, -- Blade Rush (Outlaw talent)
}, {
	-- map aura to modified spell(s)
	[ 91021] = { -- Find Weakness (Subtlety talent)
		  1833, -- Cheap Shot
		185438, -- Shadowstrike
	},
	[108211] = { -- Leeching Poison (Assassination talent)
		2823, -- Deadly Poison
		8679, -- Wound Poison
	},
	[115192] = 115191, -- Subterfuge (Assassination/Subtlety talent) -> Stealth
	[154953] =    408, -- Internal Bleeding (Assassination) -> Kidney Shot
	[193538] = { -- Alacrity (Outlaw/Subtlety talent)
		   408, -- Kidney Shot (Subtlety)
		  2098, -- Dispatch (Outlaw)
		193316, -- Roll the Bones (Outlaw)
		195452, -- Nightblade (Subtlety)
		196819, -- Eviscerate (Subtlety)
		199804, -- Between the Eyes (Outlaw)
		-- 280719, -- Secret Technique (Subtlety talent) TODO: bugged on Beta or intended?
	},
	[193641] = { -- Elaborate Planning (Assassination talent)
		   408, -- Kidney Shot
		  1943, -- Rupture
		 32645, -- Envenom
		121411, -- Crimson Tempest (Assassination talent)
	},
	[195627] = 185763, -- Opportunity -> Pistol Shot (Outlaw)
	[196980] = { -- Master of Shadows (Subtlety)
		  1784, -- Stealth
		115191, -- Stealth (with Subterfuge talent)
		185313, -- Shadow Dance
	},
	[197003] =   2983, -- Maneuverability (Outlaw honor talent) -> Sprint
	[197046] =   2823, -- Minor Wound Poison (Assassination honor talent) -> Deadly Poison
	[197051] =   2823, -- Mind-Numbing Poison (Assassination honor talent) -> Deadly Poison
	[198097] =  32645, -- Creeping Venom (Assassination honor talent) -> Envenom
	[198222] =  32645, -- System Shock (Assassination honor talent) -> Envenom
	[198368] = { -- Take Your Cut (Outlaw honor talent)
		  5171, -- Slice and Dice (Outlaw talent)
		193316, -- Roll the Bones
	},
	[198688] = 185438, -- Dagger in the Dark (Subtlety honor talent) -> Shadowstrike
	[199027] = { -- Veil of Midnight (Subtlety honor talent)
		  1784, -- Stealth
		  1856, -- Vanish
		115191, -- Stealth (with Subterfuge talent)
	},
	[206760] = { -- Shadow's Grasp (Subtlety)
		    53, -- Backstab
		185438, -- Shadowstrike
		200758, -- Gloomblade (Subtlety talent)
	},
	[209754] = 199804, -- Boarding Party (Outlaw honor talent) -> Between the Eyes
	[212150] =   2094, -- Cheap Tricks (Outlaw honor talent) -> Blind
	[212198] = 212205, -- Crimson Vial -> Create: Crimson Vial (Outlaw honor talent)
	[213981] = { -- Cold Blood (Subtlety honor talent)
		  1833, -- Cheap Shot
		185438, -- Shadowstrike
	},
	[213995] = 199804, -- Cheap Tricks (Outlaw honor talent) -> Between the Eyes
	[221630] =  57934, -- Tricks of the Trade (Outlaw honor talent)
	[245640] = 196819, -- Shuriken Combo (Subtlety) -> Eviscerate
	[255909] = { -- Prey on the Weak (talent)
		   408, -- Kidney Shot (Assassination/Subtlety)
		  1833, -- Cheap Shot
		199804, -- Between the Eyes (Outlaw)
	},
	[256148] =    703, -- Iron Wire (Assassination talent) -> Garrote
	[256171] = 193316, -- Loaded Dice (Outlaw talent) -> Roll the Bones
	[256735] =   1784, -- Master Assassin (Assassination talent) -> Stealth
	[257506] =   1833, -- Shot in the Dark (Subtlety talent) -> Cheap Shot
	[270070] =  51723, -- Hidden Blades (Assassination talent) -> Fan of Knives
})
