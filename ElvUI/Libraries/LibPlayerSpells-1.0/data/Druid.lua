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
lib:__RegisterSpells('DRUID', 80000, 2, {
	COOLDOWN = {
		  18562, -- Swiftmend
		  18960, -- Teleport: Moonglade
		  20484, -- Rebirth
		 102401, -- Wild Charge (talent - non-shapeshifted)
		 102417, -- Wild Charge (talent - travel)
		 102383, -- Wild Charge (talent - moonkin)
		 202028, -- Brutal Slash (Feral talent)
		 202770, -- Fury of Elune (Balance talent)
		 203651, -- Overgrowth (Restoration honor talent)
		 204066, -- Lunar Beam (Guardian talent)
		 205636, -- Force of Nature (Balance talent)
		 274281, -- New Moon (Balance talent)
		 274282, -- Half Moon (Balance talent)
		[108238] = 'SURVIVAL', -- Renewal (Feral/Restoration talent)
		AURA = {
			HARMFUL = {
				  81261, -- Solar Beam (Balance)
				 106830, -- Thrash (cat)
				 164812, -- Moonfire (Guardian)
				 192090, -- Thrash (bear)
				 206891, -- Intimidated (Guardian honor talent)
				 209749, -- Faerie Swarm (Balance honor talent)
				 274838, -- Feral Frenzy (Feral talent)
				[201664] = 'SURVIVAL', -- Demoralizing Roar (Guardian honor talent)
				CROWD_CTRL = {
					[  6795] = 'TAUNT', -- Growl
					DISORIENT = {
						209753, -- Cyclone (Balance/Restoration honor talent)
						236748, -- Intimidating Roar (Guardian talent)
					},
					INCAPACITATE = {
						    99, -- Incapacitating Roar (Guardian)
						  2637, -- Hibernate -- TODO: category
						236025, -- Enraged Maim (Feral honor talent)
					},
					ROOT = {
						   339, -- Entangling Roots
						 45334, -- Immobilized (Guardian talent - bear)
						102359, -- Mass Entanglement (talent)
						235963, -- Entangling Roots (Feral honor talent)
					},
					STUN = {
						  5211, -- Mighty Bash (talent)
						163505, -- Rake (Feral)
						202244, -- Overrun (Guardian honor talent)
						203123, -- Maim (Feral)
					},
				},
				SNARE = {
					 50259, -- Dazed (talent - cat)
					 61391, -- Typhoon (talent)
					127797, -- Ursol's Vortex (Restoration)
				}
			},
			HELPFUL = {
				  29166, -- Innervate (Balance/Restoration)
				  48438, -- Wild Growth
				  77761, -- Stampeding Roar (Guardian)
				  77764, -- Stampeding Roar (Feral)
				 102351, -- Cenarion Ward (Restoration talent)
				 102352, -- Cenarion Ward (Restoration talent - HoT)
				 157982, -- Tranquility (Restoration)
				 203554, -- Focused Growth (Restoration honor talent)
				 236696, -- Thorns (Balance/Feral/Restoration honor talent)
				[102342] = 'SURVIVAL', -- Ironbark (Balance)
			},
			PERSONAL = {
				  1850, -- Dash
				  5215, -- Prowl (Guardian)
				 22842, -- Frenzied Regeneration
				 93622, -- Gore (Guardian)
				102416, -- Wild Charge (talent - aquatic)
				114108, -- Soul of the Forest (Restoration talent)
				164545, -- Solar Empowerment
				164547, -- Lunar Empowerment
				197721, -- Flourish (Restoration talent)
				202425, -- Warrior of Elune (Balance talent)
				203975, -- Earthwarden (Guardian talent)
				213680, -- Guardian of Elune (Guardian talent)
				234084, -- Moon and Stars (Balance honor talent)
				236185, -- Master Shapeshifter (Guardian honor talent)
				252071, -- Jungle Stalker (Feral talent)
				252216, -- Tiger Dash (Feral/Guardian/Restoration talent)
				BURST = {
					102543, -- Incarnation: King of the Jungle (Feral talent)
					102560, -- Incarnation: Chosen of Elune (Balance talent)
					106951, -- Berserker (Feral)
					117679, -- Incarnation: Tree of Life (Restoration talent)
					194223, -- Celestial Alignment (Balance)
				},
				POWER_REGEN = {
					 155835, -- Bristling Fur (Guardian talent)
					[  5217] = 'BURST', -- Tiger's Fury
				},
				SURVIVAL = {
					 22812, -- Barkskin (Balance/Guardian)
					 61336, -- Survival Instincts (Feral/Guardian)
					102558, -- Incarnation: Guardian of Ursoc (Guardian talent)
				},
			},
		},
		DISPEL = {
			HARMFUL = {
				[2908] = 'ENRAGE', -- Soothe (Balance/Feral/Restoration)
			},
			HELPFUL = {
				[ 2782] = 'CURSE POISON', -- Remove Corruption (Balance/Feral/Guardian)
				[88423] = 'CURSE MAGIC POISON', -- Nature's Cure (Restoration)
			},
		},
		INTERRUPT = {
			 78675, -- Solar Beam (Balance)
			106839, -- Skull Bash (Feral/Guardian)
		},
		KNOCKBACK = {
			132469, -- Typhoon (Guardian talent)
			202246, -- Overrun (Guardian honor talent)
		},
		POWER_REGEN = {
			33917, -- Mangle (Guardian)
			77758, -- Thrash (bear)
		},
	},
	AURA = {
		HARMFUL = {
			  1079, -- Rip
			155625, -- Moonfire (Feral talent)
			155722, -- Rake
			164815, -- Sunfire
			200947, -- Encroaching Vines (Restoration honor talent)
			202347, -- Stellar Flare (Balance talent)
			236021, -- Ferocious Wound (Feral honor talent)
			SNARE = {
				58180, -- Infected Wounds (Feral)
			},
		},
		HELPFUL = {
			   774, -- Rejuvenation
			  8936, -- Regrowth
			 33763, -- Lifebloom (Restoration)
			155777, -- Rejuvenation (Germination) (Restoration talent)
			200389, -- Cultivation (Restoration talent)
			203407, -- Revitalize (Restoration honor talent)
			207386, -- Spring Blossoms (Restoration talent)
			209746, -- Moonkin Aura (Balance honor talent)
		},
		PERSONAL = {
			 16870, -- Clearcasting (Restoration)
			 52610, -- Savage Roar (Feral talent)
			 69369, -- Predatory Swiftness (Feral)
			135700, -- Clearcasting (Feral)
			145152, -- Bloodtalons (Feral talent)
			158792, -- Pulverize (Guardian talent)
			191034, -- Starfall (Balance)
			202461, -- Stellar Drift (Balance talent)
			207640, -- Abundance (Restoration talent)
			209731, -- Protector of the Grove (Balance/Feral honor talent)
			213708, -- Galactic Guardian (Guardian talent)
			236187, -- Master Shapeshifter (Guardian honor talent)
			279709, -- Starfond (Balance talent)
			279943, -- Sharpened Claws (Guardian honor talent)
			SURVIVAL = {
				192081, -- Ironfur
			},
		},
	},
}, {
	-- map aura to provider(s)
	[  1079] = {
		  1079, -- Rip
		203242, -- Rip and Tear (Feral honor talent)
	},
	[ 16870] = 113043, -- Clearcasting <- Omen of Clarity (Restoration)
	[ 45334] = 102401, -- Immobilized <- Wild Charge (talent - bear)
	[ 50259] = 102401, -- Dazed <- Wild Charge (talent - cat)
	[ 58180] =  48484, -- Infected Wounds (Feral)
	[ 61391] = 132469, -- Typhoon (Guardian talent)
	[ 69369] =  16974, -- Predatory Swiftness (Feral)
	[ 81261] =  78675, -- Solar Beam (Balance)
	[ 93622] = 210706, -- Gore (Guardian)
	[102352] = 102351, -- Cenarion Ward (Restoration talent - HoT)
	[102416] = 102401, -- Wild Charge (talent - aquatic)
	[114108] = 158478, -- Soul of the Forest (Restoration talent)
	[117679] =  33891, -- Incarnation: Tree of Life (Restoration talent)
	[127797] = 102793, -- Ursol's Vortex (Restoration)
	[135700] =  16864, -- Clearcasting <- Omen of Clarity (Feral)
	[145152] = 155672, -- Bloodtalons (Feral talent)
	[155625] = 155580, -- Moonfire <- Lunar Inspiration (Feral talent)
	[155722] = { -- Rake
		  1822, -- Rake
		203242, -- Rip and Tear (Feral honor talent)
	},
	[155777] = 155675, -- Rejuvenation (Germination) <- Germination (Restoration talent)
	[157982] =    740, -- Tranquility (Restoration)
	[158792] =  80313, -- Pulverize (Guardian talent)
	[163505] = 231052, -- Rake <- Rake (Rank 2) (Feral)
	[164545] = { -- Solar Empowerment
		197626, -- Starsurge (from Balance Affinity)
		279708, -- Empowerments (Balance)
	},
	[164547] = { -- Lunar Empowerment
		197626, -- Starsurge (from Balance Affinity)
		279708, -- Empowerments (Balance)
	},
	[164812] =   8921, -- Moonfire (Guardian)
	[164815] = { -- Sunfire
		 93402, -- Sunfire (Balance/Resoration)
		197630, -- Sunfire (from Balance Affinity)
	},
	[192090] =  77758, -- Thrash (bear)
	[200389] = 200390, -- Cultivation (Restoration talent)
	[200947] = 200931, -- Encroaching Vines (Restoration honor talent)
	[202244] = 202246, -- Overrun (Guardian honor talent)
	[202461] = 202354, -- Stellar Drift (Balance talent)
	[203123] =  22570, -- Maim (Feral)
	[203407] = 203399, -- Revitalize (Restoration honor talent)
	[203554] = 203553, -- Focused Growth (Restoration honor talent)
	[203975] = 203974, -- Earthwarden (Guardian talent)
	[206891] = 207017, -- Intimidated <- Alpha Chalenge (Guardian honor talent)
	[207386] = 207385, -- Spring Blossoms (Restoration talent)
	[207640] = 207383, -- Abundance (Restoration talent)
	[209731] = 209730, -- Protector of the Grove (Balance/Feral honor talent)
	[209746] = 209740, -- Moonkin Aura (Balance honor talent)
	[213680] = 155578, -- Guardian of Elune (Guardian talent)
	[213708] = 203964, -- Galactic Guardian (Guardian talent)
	[234084] = 233750, -- Moon and Stars (Balance honor talent)
	[236021] = 236020, -- Ferocious Wound (Feral honor talent)
	[236025] = 236026, -- Enraged Maim (Feral honor talent)
	[236185] = 236144, -- Master Shapeshifter (Guardian honor talent)
	[236187] = 236144, -- Master Shapeshifter (Guardian honor talent)
	[252071] = 102543, -- Jungle Stalker <- Incarnation: King of the Jungle (Feral talent)
	[274838] = 274837, -- Feral Frenzy (Feral talent)
	[279709] = 202345, -- Starfond (Balance talent)
	[279943] = 202110, -- Sharpened Claws (Guardian honor talent)
}, {
	-- map aura to modified spell(s)
	[ 16870] =   8936, -- Clearcasting (Restoration) -> Regrowth
	[ 45334] =  16979, -- Immobilized -> Wild Charge (talent - bear)
	[ 50259] =  49376, -- Dazed -> Wild Charge (talent - cat)
	[ 58180] =   1822, -- Infected Wounds -> Rake (Feral)
	[ 69369] = { -- Predatory Swiftness (Feral)
		 339, -- Entangling Roots
		8936, -- Regrowth
	},
	[ 93622] =  33917, -- Gore (Guardian) -> Mangle
	[102416] = 102416, -- Wild Charge (talent - aquatic)
	[114108] = { -- Soul of the Forest (Restoration talent)
		  774, -- Rejuvenation
		 8936, -- Regrowth
		48438, -- Wild Growth
	},
	[135700] = { -- Clearcasting (Feral)
		  5221, -- Shred
		106785, -- Swipe
		106830, -- Thrash
		202028, -- Brutal Slash (Feral talent)
	},
	[145152] = { -- Bloodtalons (Feral talent)
		  1079, -- Rip
		  1822, -- Rake
		  5221, -- Shred
		 22568, -- Ferocious Bite
		 22570, -- Maim
		 33917, -- Mangle
		 77758, -- Thrash (bear)
		106785, -- Swipe
		106830, -- Thrash (cat)
		202028, -- Brutal Slash (Feral talent)
	},
	[155625] = 155625, -- Moonfire (Feral talent)
	[155777] =    774, -- Rejuvenation (Germination) (Restoration talent) -> Rejuvenation
	[163505] =   1822, -- Rake (Feral)
	[164545] = { -- Solar Empowerment
		190984, -- Solar Wrath (Balance)
		197629, -- Solar Wrath (from Balance Affinity)
	},
	[164547] = { -- Lunar Empowerment
		194153, -- Lunar Strike (Balance)
		197628, -- Lunar Strike (from Balance Affinity)
	},
	[200389] =    774, -- Cultivation (Restoration talent) -> Rejuvenation
	[200947] =    339, -- Encroaching Vines (Restoration honor talent) -> Entangling Roots
	[202425] = 194153, -- Warrior of Elune (Balance talent) -> Lunar Strike
	[202461] = 191034, -- Stellar Drift (Balance talent) -> Starfall
	[203407] =    774, -- Revitalize (Restoration honor talent) -> Rejuventation
	[203554] =  33763, -- Focused Growth (Restoration honor talent) -> Lifebloom
	[203975] = { -- Earthwarden (Guardian talent)
		 77758, -- Thrash (bear)
		106830, -- Thrash (cat)
	},
	[207386] = 145205, -- Spring Blossoms (Restoration talent) -> Efflorescence
	[207640] =   8936, -- Abundance (Restoration talent) -> Regrowth
	[209731] =   8936, -- Protector of the Grove (Balance/Feral honor talent) -> Regrowth
	[209746] =  78674, -- Moonkin Aura (Balance honor talent) -> Starsurge
	[213680] = { -- Guardian of Elune (Guardian talent)
		 22842, -- Frenzied Regeneration
		192081, -- Ironfur
	},
	[213708] =   8921, -- Galactic Guardian (Guardian talent) -> Moonfire
	[234084] = { -- Moon and Stars (Balance honor talent)
		102560, -- Incarnation: Chosen of Elune
		194223, -- Celestial Alignment
	},
	[236021] =  22568, -- Ferocious Wound (Feral honor talent) -> Ferocious Bite
	[236185] =  18562, -- Master Shapeshifter (Guardian honor talent) -> Swiftmend
	[236187] = 197625, -- Master Shapeshifter (Guardian honor talent) -> Moonkin Form
	[252071] = 102547, -- Jungle Stalker (Feral talent) -> Prowl
	[279709] = { -- Starfond (Balance talent)
		 78674, -- Starsurge
		191034, -- Starfall
	},
	[279943] =   6807, -- Sharpened Claws (Guardian honor talent) -> Maul
})
