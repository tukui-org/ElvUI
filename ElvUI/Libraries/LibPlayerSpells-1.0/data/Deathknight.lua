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
lib:__RegisterSpells('DEATHKNIGHT', 80000, 1, {
	COOLDOWN = {
		  46584, -- Raise Dead (Unholy)
		  49206, -- Summon Gargoyle (Unholy talent)
		  49576, -- Death Grip
		  50977, -- Death Gate
		  61999, -- Raise Ally
		 194913, -- Glacial Advance (Frost talent)
		 210764, -- Rune Strike (Blood talent)
		 274156, -- Consumption (Blood talent)
		 275699, -- Apocalypse (Unholy)
		[ 47528] = 'INTERRUPT', -- Mind Freeze
		[108199] = 'KNOCKBACK', -- Gorefiend's Grasp (Blood)
		AURA = {
			HARMFUL = {
				 47476, -- Strangulate (Blood honor talent) -- NOTE: Silence
				 55078, -- Blood Plague (Blood)
				 77606, -- Dark Simulacrum (Blood/Unholy honor talent)
				115994, -- Unholy Blight (Unholy talent)
				130736, -- Soul Reaper (Unholy talent)
				203173, -- Death Chain (Blood honor talent)
				206891, -- Intimidated (Blood honor talent)
				206931, -- Blooddrinker (Blood talent)
				206940, -- Mark of Blood (Blood talent)
				211794, -- Winter is Comming (Frost talent)
				212610, -- Walking Dead (Blood honor talent)
				CROWD_CTRL = {
					[207167] = 'DISORIENT', -- Blinding Sleet (Frost talent)
					ROOT = {
						 91807, -- Shambling Rush (Ghoul) (Unholy)
						233395, -- Frozen Center (Frost honor talent)
					},
					STUN = {
						 91797, -- Monstrous Blow (Ghoul) (Unholy)
						 91800, -- Gnaw (Ghoul) (Unholy)
						108194, -- Asphyxiate (Unholy talent)
						221562, -- Asphyxiate (Blood)
					},
					TAUNT = {
						51399, -- Death Grip (Blood)
						56222, -- Dark Command
					}
				},
				SNARE = {
					204206, -- Chilled (Frost honor talent)
					206930, -- Heart Strike (Blood)
					211793, -- Remorsless Winter (Frost)
					273977, -- Grip of the Dead (Blood talent)
					279303, -- Frost Breath (Frost talent)
				},
			},
			HELPFUL = {
				[145622] = 'SURVIVAL', -- Anti-Magic Zone (honor talent)
			},
			PERSONAL = {
				  48265, -- Death's Advance
				  77535, -- Blood Shield (Blood)
				 115989, -- Unholy Blight (Unholy talent)
				 152279, -- Breath of Sindragosa (Frost talent)
				 188290, -- Death and Decay (Blood/Unholy)
				 194844, -- Bonestorm (Blood talent)
				 195181, -- Bone Shield (Blood)
				 196770, -- Remorseless Winter (Frost)
				 212552, -- Wraith Walk (talent)
				 215711, -- Soul Ripper (Unholy talent)
				 219788, -- Ossuary (Blood talent)
				 273947, -- Hemostasis (Blood talent)
				 274009, -- Voracious (Blood talent)
				[ 48743] = 'INVERT_AURA', -- Death Pact (Unholy talent)
				BURST = {
					 42650, -- Army of the Dead (Unholy)
					 51271, -- Pillar of Frost (Frost)
					207256, -- Obliteration (Frost talent)
					207289, -- Unholy Frenzy (Unholy talent)
				},
				POWER_REGEN = {
					 47568, -- Empower Rune Weapon (Frost)
					219809, -- Tombstone (Blood talent)
				},
				SURVIVAL = {
					 48707, -- Anti-Magic Shell
					 48792, -- Icebound Fortitude
					 55233, -- Vampiric Blood (Blood)
					 81256, -- Dancing Rune Weapon (Blood)
					194679, -- Rune Tap (Blood talent)
				},
			},
			PET = {
				63560, -- Dark Transformation (Unholy)
				SURVIVAL = {
					91837, -- Putrid Bulwark (Ghoul) (Unholy)
					91838, -- Huddle (Ghoul) (Unholy)
				}
			},
		},
		POWER_REGEN = {
			 57330, -- Horn of Winter (Frost talent)
			207127, -- Hungering Rune Weapon (Frost talent)
		}
	},
	AURA = {
		HARMFUL = {
			 55095, -- Frost Fever (Frost)
			191587, -- Virulent Plague (Unholy)
			194310, -- Festering Wound (Unholy)
			196782, -- Outbreak (Unholy)
			199969, -- Wandering Plague (Unholy honor talent)
			223929, -- Necrotic Wound (Unholy honor talent)
			233397, -- Delirium (Frost honor talent)
			CROWD_CTRL = {
				[204085] = 'ROOT', -- Deathchill (Frost honor talent)
				STUN = {
					207165, -- Abomination's Might (Frost talent)
					210141, -- Zombie Explosion (Unholy honor talent)
				},
			},
			SNARE = {
				 45524, -- Chains of Ice (Frost/Unholy)
				200646, -- Unholy Mutation (Unholy honor talent)
			},
		},
		HELPFUL = {
			3714, -- Path of Frost
		},
		PERSONAL = {
			 51124, -- Killing Machine (Frost)
			 59052, -- Rime (Frost)
			 81141, -- Crimson Scourge (Blood)
			 81340, -- Sudden Doom (Unholy)
			101568, -- Dark Succor (Frost/Unholy)
			194879, -- Icy Talons (Frost talent)
			207203, -- Frost Shield (Frost talent)
			233411, -- Blood for Blood (Blood honor talent)
			253595, -- Inexorable Assault (Frost talent)
			279942, -- Tundra Stalker (Frost honor talent)
			281209, -- Cold Heart (Frost talent)
		},
		PET = {
			[111673] = 'INVERT_AURA', -- Control Undead
		},
	},
}, {
	-- map aura to provider(s)
	[ 51124] =  51128, -- Killing Machine (Frost)
	[ 51399] =  48263, -- Death Grip (Blood) <- Veteran of the Third War -- NOTE: to signify the taunt is Blood only
	[ 55078] = { -- Blood Plague (Blood)
		 50842, -- Blood Boil
		195292, -- Death's Caress
	},
	[ 55095] =  49184, -- Frost Fever (Frost) <- Howling Blast
	[ 59052] =  59057, -- Rime (Frost)
	[ 77535] =  77513, -- Blood Shield (Blood) <- Mastery: Blood Shield
	[ 81141] =  81136, -- Crimson Scourge (Blood)
	[ 81256] =  49028, -- Dancing Rune Weapon (Blood)
	[ 81340] =  49530, -- Sudden Doom (Unholy)
	[ 91797] =  63560, -- Monstrous Blow (Ghoul) (Unholy) <- Dark Transformation
	[ 91800] =  47481, -- Gnaw (Ghoul) (Unholy)
	[ 91807] =  63560, -- Shambling Rush (Ghoul) (Unholy) <- Dark Transformation
	[ 91837] =  63560, -- Putrid Bulwark (Ghoul) (Unholy) <- Dark Transformation
	[ 91838] =  47484, -- Huddle (Ghoul) (Unholy)
	[101568] = 178819, -- Dark Succor (Frost/Unholy)
	[145622] =  51052, -- Anti-Magic Zone (honor talent)
	[115994] = 115989, -- Unholy Blight (Unholy talent)
	[188290] = { -- Death and Decay (Blood/Unholy)
		 43265, -- Death and Decay (Blood/Unholy)
		152280, -- Defile (Unholy talent)
	},
	[191587] =  77575, -- Virulent Plague (Unholy) <- Outbreak
	[194310] =  85948, -- Festering Wound (Unholy) <- Festering Strike
	[194879] = 194878, -- Icy Talons (Frost talent)
	[195181] = 195182, -- Bone Shield (Blood) <- Marrowrend
	[204085] = 204080, -- Deathchill (Frost honor talent)
	[211793] = 196770, -- Remorsless Winter (Frost)
	[196782] =  77575, -- Outbreak (Unholy)
	[199969] = 199725, -- Wandering Plague (Unholy honor talent)
	[200646] = 201934, -- Unholy Mutation (Unholy honor talent)
	[204206] = 204160, -- Chilled (Frost honor talent) <- Chill Streak
	[206891] = 207018, -- Intimidated <- Murderous Intent (Blood honor talent)
	[207165] = 207161, -- Abomination's Might (Frost talent)
	[207203] = 207200, -- Frost Shield <- Permafrost (Frost talent)
	[210141] = 210128, -- Zombie Explosion <- Reanimation (Unholy honor talent)
	[211794] = 207170, -- Winter is Comming (Frost talent)
	[212610] = 202731, -- Walking Dead (Blood honor talent)
	[215711] = 130736, -- Soul Ripper (Unholy talent)
	[219788] = 219786, -- Ossuary (Blood talent)
	[223929] = 223829, -- Necrotic Wound (Unholy honor talent)
	[233395] = 204135, -- Frozen Center (Frost honor talent)
	[233397] = 233396, -- Delirium (Frost honor talent)
	[253595] = 253593, -- Inexorable Assault (Frost talent)
	[273947] = 273946, -- Hemostasis (Blood talent)
	[273977] = 273952, -- Grip of the Dead (Blood talent)
	[274009] = 273953, -- Voracious (Blood talent)
	[279303] = 279302, -- Frost Breath <- Frostwyrm's Fury (Frost talent)
	[279942] = 279941, -- Tundra Stalker (Frost honor talent)
	[281209] = 281208, -- Cold Heart (Frost talent)
}, {
	-- map aura to modified spell(s)
	[ 51124] = { -- Killing Machine (Frost)
		 49020, -- Obliterate
		207230, -- Frostscythe (Frost talent)
	},
	[ 51399] =  49576, -- Death Grip (Blood)
	[ 59052] =  49184, -- Rime (Frost) -> Howling Blast
	[ 77535] =  49998, -- Blood Shield (Blood) -> Death Strike
	[ 81141] =  43265, -- Crimson Scourge (Blood) -> Death and Decay
	[ 81340] =  47541, -- Sudden Doom (Unholy) -> Death Coil
	[ 91797] =  47481, -- Monstrous Blow (Ghoul) (Unholy) <- Gnaw (Ghoul)
	[ 91807] =  47482, -- Shambling Rush (Ghoul) (Unholy) <- Leap (Ghoul)
	[ 91837] =  47484, -- Putrid Bulwark (Ghoul) (Unholy) <- Huddle (Ghoul)
	[101568] =  49998, -- Dark Succor (Frost/Unholy) -> Death Strike
	[194879] =  { -- Icy Talons (Frost talent)
		 49143, -- Frost Strike
		 49998, -- Death Strike
		152279, -- Breath of Sindragosa (Frost talent)
		194913, -- Glacial Advance (Frost talent)
	},
	[199969] =  77575, -- Wandering Plague (Unholy honor talent) -> Outbreak
	[200646] =  77575, -- Unholy Mutation (Unholy honor talent) -> Outbreak
	[207165] =  49020, -- Abomination's Might (Frost talent) -> Obliterate
	[207203] =   6603, -- Frost Shield (Frost talent) -> Auto Attack
	[204085] =  45524, -- Deathchill (Frost honor talent) -> Chains of Ice
	[211794] = 196170, -- Winter is Comming (Frost talent) -> Remorseless Winter
	[212610] =  49576, -- Walking Dead (Blood honor talent) -> Death Grip
	[219788] = 195182, -- Ossuary (Blood talent) -> Marrowrend
	[233395] = 196770, -- Frozen Center (Frost honor talent) -> Remorseless Winter
	[233397] = { -- Delirium (Frost honor talent)
		49143, -- Frost Strike
		49184, -- Howling Blast
	},
	[253595] =   6603, -- Inexorable Assault (Frost talent) -> Auto Attack
	[273947] =  49998, -- Hemostasis (Blood talent) -> Death Strike
	[273977] =  43265, -- Grip of the Dead (Blood talent) -> Death and Decay
	[274009] =  49998, -- Voracious (Blood talent) -> Death Strike
	[279942] =  49143, -- Tundra Stalker (Frost honor talent) -> Frost Strike
	[281209] =  45524, -- Cold Heart (Frost talent) -> Chains of Ice
})
