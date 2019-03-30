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
lib:__RegisterSpells('WARLOCK', 80000, 1, {
	COOLDOWN = {
		   698, -- Ritual of Summoning
		  6353, -- Soul Fire (Destruction talent)
		 17877, -- Shadowburn (Destruction talent)
		 29893, -- Create Soulwell
		 48020, -- Demonic Circle: Teleport (talent)
		 89792, -- Flee (imp)
		104316, -- Call Dreadstalkers (Demonology)
		111771, -- Demonic Gateway
		111898, -- Grimoire: Felguard (Demonology talent)
		152108, -- Cataclysm (Destruction talent)
		196447, -- Channel Demonfire (Destruction talent)
		264057, -- Soul Strike (Demonology talent)
		264106, -- Deathbolt (Affliction talent)
		264130, -- Power Siphon (Demonology talent)
		267211, -- Bilescourge Bombers (Demonology talent)
		AURA = {
			HARMFUL = {
				 48181, -- Haunt (Affliction talent)
				 80240, -- Havoc (Destruction)
				199890, -- Curse of Tongues (honor talent)
				199892, -- Curse of Weakness (honor talent)
				199954, -- Curse of Fragility (honor talent)
				200548, -- Bane of Havoc (Destruction honor talent)
				205179, -- Phantom Singularity (Affliction talent)
				212580, -- Eye of the Observer (Demonology honor talent)
				234877, -- Curse of Shadows (Affliction honor talent)
				265931, -- Conflagrate (Destruction talent)
				270569, -- From the Shadows (Demonology talent)
				CROWD_CTRL = {
					[  6789] = 'INCAPACITATE', -- Mortal Coil (talent)
					[ 17735] = 'TAUNT', -- Suffering (voidwalker)
					[233582] = 'ROOT', -- Entrenced in Flame (Destruction honor talent)
					DISORIENT = {
						  6358, -- Seduction (succubus)
						261589, -- Seduction (Destruction talent)
					},
					STUN = {
						 22703, -- Infernal Awakening (Destruction)
						 30283, -- Shadowfury
						 89766, -- Axe Toss (felguard) (Demonology)
						213688, -- Fel Cleave (fel lord) (Demonology honor talent)
					},
				},
				SNARE = {
					  6360, -- Whiplash (succubus)
					278350, -- Vile Taint (Affliction talent)
				},
			},
			HELPFUL = {
				20707, -- Soulstone
			},
			PERSONAL = {
				 48018, -- Demonic Circle (talent)
				117828, -- Backdraft (Destruction)
				196099, -- Grimoire of Sacrifice (Affliction/Destruction talent)
				221705, -- Casting Circle (honor talent)
				236471, -- Soulshatter (Affliction honor talent)
				265273, -- Demonic Power (Demonology)
				266091, -- Grimoire of Supremacy (Destruction talent)
				267218, -- Nether Portal (Demonology talent)
				BURST = {
					113858, -- Dark Soul: Instability (Destruction talent)
					113860, -- Dark Soul: Misery (Affliction talent)
				},
				SURVIVAL = {
					104773, -- Unending Resolve
					108416, -- Dark Pact (talent)
					132413, -- Shadow Bulwark (Destruction talent)
					212295, -- Nether Ward (honor talent)
				},
			},
			PET = {
				  30151, -- Pursuit (felguard) (Demonology)
				  89751, -- Felstorm (felguard) (Demonology)
				 267171, -- Demonic Strength (Demonology talent)
				[ 17767] = 'SURVIVAL', -- Shadow Bulwark (voidwalker)
			},
		},
		DISPEL = {
			MAGIC = {
				[ 19505] = 'HARMFUL', -- Devour Magic (felhunter)
				HELPFUL = {
					 89808, -- Singe Magic (imp)
					119905, -- Singe Magic NOTE: Command Demon when imp summoned
					132411, -- Singe Magic NOTE: Command Demon when imp sacrificed
					212623, -- Singe Magic (Demonology honor talent)
				},
			},
		},
		INTERRUPT = {
			 19647, -- Spell Lock (felhunter)
			119910, -- Spell Lock NOTE: Command Demon when felhunter summoned
			132409, -- Spell Lock NOTE: Command Demon when felhunter sacrificed
			212619, -- Call Felhunter (Demonology honor talent)
		}
	},
	AURA = {
		HARMFUL = {
			   980, -- Agony (Affliction)
			 27243, -- Seed of Corruption (Affliction)
			 30213, -- Legion Strike (felguard) (Demonology)
			 32390, -- Shadow Embrace (Affliction talent)
			 63106, -- Siphon Life (Affliction talent)
			146739, -- Corruption (Affliction)
			157736, -- Immolate (Destruction)
			196414, -- Eradication (Destruction talent)
			198590, -- Drain Soul (Affliction talent)
			200587, -- Fel Fissure (Destruction honor talent)
			221715, -- Essence Drain (honor talent)
			233490, -- Unstable Affliction (Affliction)
			233496, -- Unstable Affliction (Affliction)
			233497, -- Unstable Affliction (Affliction)
			233498, -- Unstable Affliction (Affliction)
			233499, -- Unstable Affliction (Affliction)
			234153, -- Drain Life (Destruction)
			265412, -- Doom (Demonology talent)
			267997, -- Bile Spit (Demonology talent)
			CROWD_CTRL = {
				[   710] = 'INCAPACITATE', -- Banish
				[118699] = 'DISORIENT', -- Fear
			},
		},
		HELPFUL = {
			5697, -- Unending Breath
		},
		PERSONAL = {
			   126, -- Eye of Kilrogg
			  6307, -- Blood Pact (imp)
			111400, -- Burning Rush (talent)
			205146, -- Demonic Calling (Demonology talent)
			264173, -- Demonic Core (Demonology)
			264571, -- Nightfall (Affliction talent)
		},
		PET = {
				755, -- Health Funnel
			   7870, -- Lesser Invisibility (succubus)
			 112042, -- Threatening Presence (voidwalker)
			 134477, -- Threatening Presence (felguard) (Demonology)
			[  1098] = 'INVERT_AURA', -- Enslave Demon
		},
	},
}, {
	-- map aura to provider(s)
	[  6358] = { -- Seduction (succubus)
		  6358, -- Seduction (succubus)
		119909, -- Seduction NOTE: Control Demon when succubus summoned
	},
	[ 17767] = { -- Shadow Bulwark (void walker)
		 17767, -- Shadow Bulwark (void walker)
		119907, -- Shadow Bulwark NOTE: Command Demon when voidwalker summoned
	},
	[ 22703] =   1122, -- Infernal Awakening <- Summon Infernal (Destruction)
	[ 32390] =  32388, -- Shadow Embrace (Affliction talent)
	[ 89766] = { -- Axe Toss (felguard) (Demonology)
		 89766, -- Axe Toss (felguard)
		119914, -- Axe Toss (Demonology) NOTE: Command Demon when felguard summoned
	},
	[118699] =   5782, -- Fear
	[117828] = 196406, -- Backdraft (Destruction)
	[132413] = 108503, -- Shadow Bulwark <- Grimoire of Sacrifice (Destruction talent)
	[146739] =    172, -- Corruption (Affliction)
	[157736] = { -- Immolate (Destruction)
		   348, -- Immolate (Destruction)
		152108, -- Cataclysm (Destruction talent)
	},
	[196099] = 108503, -- Grimoire of Sacrifice (Affliction/Destruction talent)
	[196414] = 196412, -- Eradication (Destruction talent)
	[200548] = 200546, -- Bane of Havoc (Destruction honor talent)
	[200587] = 200586, -- Fel Fissure (Destruction honor talent)
	[205146] = 205145, -- Demonic Calling (Demonology talent)
	[212580] = 201996, -- Eye of the Observer (Demonology honor talent) <- Call Observer (Demonology honor talent)
	[213688] = 212459, -- Fel Cleave (fel lord) (Demonology honor talent) <- Call Fel Lord (Demonology talent)
	[221705] = 221703, -- Casting Circle (honor talent)
	[221715] = 221711, -- Essence Drain (honor talent)
	[233490] =  30108, -- Unstable Affliction (Affliction)
	[233496] =  30108, -- Unstable Affliction (Affliction)
	[233497] =  30108, -- Unstable Affliction (Affliction)
	[233498] =  30108, -- Unstable Affliction (Affliction)
	[233499] =  30108, -- Unstable Affliction (Affliction)
	[233582] = 233581, -- Entrenced in Flame (Destruction honor talent)
	[236471] = 212356, -- Soulshatter (Affliction honor talent)
	[261589] = 108503, -- Seduction <- Grimoire of Sacrifice (Destruction talent)
	[264173] = 267102, -- Demonic Core (Demonology)
	[264571] = 108558, -- Nightfall (Affliction talent)
	[265273] = 265187, -- Demonic Power (Demonology) <- Summon Demonic Tyrant
	[265931] = 205184, -- Conflagrate <- Roaring Blaze (Destruction talent)
	[266091] = 266086, -- Grimoire of Supremacy (Destruction talent)
	[267218] = 267217, -- Nether Portal (Demonology talent)
	[267997] = 264119, -- Bile Spit (Demonology talent)
	[270569] = 267171, -- From the Shadows (Demonology talent)
}, {
	-- map aura to modified spell(s)
	[ 32390] =  232670, -- Shadow Embrace (Affliction talent) -> Shadow Bolt
	[117828] = { -- Backdraft (Destruction)
		 29722, -- Incinerate
		116858, -- Chaos Bolt
	},
	[132413] = 132413, -- Shadow Bulwark (Destruction talent) NOTE: Command Demon when voidwalker sacrificed
	[196414] = 116858, -- Eradication (Destruction talent) -> Chaos Bolt
	[200587] = 116858, -- Fel Fissure (Destruction honor talent) -> Chaos Bolt
	[205146] = 104316, -- Demonic Calling (Demonology talent) -> Call Dreadstalkers
	[221715] = 234153, -- Essence Drain (honor talent) -> Drain Life
	[233582] =  17962, -- Entrenced in Flame (Destruction honor talent) -> Conflagrate
	[261589] = 261589, -- Seduction <- Grimoire of Sacrifice (Destruction talent)
	[264173] = 264178, -- Demonic Core (Demonology) -> Demonbolt
	[264571] = 232670, -- Nightfall (Affliction talent) -> Shadow Bolt
	[265931] =  17962, -- Conflagrate (Destruction talent)
	[266091] = 116858, -- Grimoire of Supremacy (Destruction talent) -> Chaos Bolt
	[270569] = 104316, -- From the Shadows (Demonology talent) -> Call Dreadstalkers
})
