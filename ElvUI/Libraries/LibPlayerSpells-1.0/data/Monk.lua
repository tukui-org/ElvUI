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
lib:__RegisterSpells('MONK', 80000, 1, {
	COOLDOWN = {
		 107428, -- Rising Sun Kick (Mistweaver/Windwalker)
		 109132, -- Roll
		 113656, -- Fists of Fury (Windwalker)
		 115098, -- Chi Wave (talent)
		 115313, -- Summon Jade Serpent Statue (Mistweaver talent)
		 115315, -- Summon Black Ox Statue (Brewmaster talent)
		 115399, -- Black Ox Brew (Brewmaster talent)
		 116844, -- Ring of Peace (talent)
		 119582, -- Purifying Brew (Brewmaster)
		 119996, -- Transcendence: Transfer (Brewmaster)
		 122281, -- Healing Elixir (Brewmaster/Mistweaver talent)
		 123904, -- Invoke Xuen, the White Tiger (Windwalker talent)
		 123986, -- Chi Burst (talent)
		 126892, -- Zen Pilgrimage
		 152175, -- Whirling Dragon Punch (Windwalker talent)
		 198644, -- Invoke Chi-Ji, the Red Crane (Mistweaver talent)
		 202370, -- Mighty Ox Kick (Brewmaster honor talent)
		 213658, -- Craft: Nimble Brew (Brewmaster honor talent)
		 261947, -- Fist of the White Tiger (Windwalker talent)
		[115288] = 'POWER_REGEN', -- Energizing Elixir (Windwalker talent)
		[116705] = 'INTERRUPT', -- Spear Hand Strike (Brewmaster)
		AURA = {
			HARMFUL = {
				 115804, -- Mortal Wounds (Windwalker)
				 122470, --Touch of Karma (Windwalker)
				 123725, -- Breath of Fire (Brewmaster)
				 201787, -- Heavy-Handed Strikes (Windwalker honor talent)
				 206891, -- Intimidated (Brewmaster honor talent)
				 233759, -- Grapple Weapon (Mistweaver/Windwalker honor talent)
				[115080] = 'BURST', -- Touch of Death (Windwalker)
				CROWD_CTRL = {
					[115078] = 'INCAPACITATE', -- Paralysis
					[116706] = 'ROOT', -- Disable (Windwalker)
					DISORIENT = {
						198909, -- Song of Chi-Ji (Mistweaver talent)
						202274, -- Incendiary Brew (Brewmaster honor talent)
					},
					STUN = {
						119381, -- Leg Sweep
						202346, -- Double Barrel (Brewmaster honor talent)
					},
					TAUNT = {
						116189, -- Provoke
						118635, -- Provoke (Brewmaster talent)
						196727, -- Provoke (Brewmaster talent)
					},
				},
				SNARE = {
					116095, -- Disable (Windwalker)
					121253, -- Keg Smash (Brewmaster)
					123586, -- Flying Serpent Kick (Wilnwalker)
				},
			},
			HELPFUL = {
				116841, -- Tiger's Lust (talent)
				119611, -- Renewing Mist (Mistweaver)
				191840, -- Essence Font (Mistweaver)
				201447, -- Ride the Wind (Windwalker honor talent)
				205655, -- Dome of Mist (Mistweaver honor talent)
				SURVIVAL = {
					116849, -- Life Cocoon (Mistweaver)
					202162, -- Avert Harm (Brewmaster honor talent)
					202248, -- Guided Meditation (Brewmaster honor talent)
				},
			},
			PERSONAL = {
				101643, -- Transcendence (Brewmaster)
				116680, -- Thunder Focus Tea (Mistweaver)
				116847, -- Rushing Jade Wind (Brewmaster talent)
				119085, -- Chi Torpedo (talent)
				196725, -- Refreshing Jade Wind (Mistweaver talent)
				197908, -- Mana Tea (Mistweaver talent)
				202335, -- Double Barrel (Brewmaster honor talent)
				209584, -- Zen Focus Tea (Mistweaver honor talent)
				215479, -- Ironskin Brew (Brewmaster)
				261715, -- Rushing Jade Wind (Windwalker talent)
				BURST = {
					137639, -- Storm, Earth, and Fire (Windwalker)
					152173, -- Serenity (Windwalker talent)
					216113, -- Way of the Crane (Mistweaver honor talent)
				},
				SURVIVAL = {
					115176, -- Zen Meditation (Brewmaster)
					115295, -- Guard (Brewmaster talent)
					120954, -- Fortifying Brew (Brewmaster)
					122278, -- Dampen Harm (talent)
					122783, -- Diffuse Magic (Mistweaver/Windwalker talent)
					125174, -- Touch of Karma (Windwalker)
					201318, -- Fortifying Brew (Windwalker honor talent)
					243435, -- Fortifying Brew (Mistweaver)
				},
			},
		},
		DISPEL = {
			HELPFUL = {
				[115310] = 'DISEASE MAGIC POISON', -- Revival (Mistweaver)
				[115450] = 'DISEASE MAGIC POISON', -- Detox (Mistweaver)
				[205234] = 'MAGIC', -- Healing Sphere (Mistweaver honor talent)
				[218164] = 'DISEASE POISON', -- Detox (Brewmaster/Windwalker)
			},
		}
	},
	AURA = {
		HARMFUL = {
			117952, -- Crackling Jade Lightning
			228287, -- Mark of the Crane (Windwalker)
		},
		HELPFUL = {
			115175, -- Soothing Mist (Mistweaver)
			124682, -- Enveloping Mist (Mistweaver)
			198533, -- Soothing Mist (Mistweaver talent)
			227344, -- Surging Mist (Mistweaver honor talent)
		},
		PERSONAL = {
			116768, -- Blackout Kick! (Windwalker)
			195630, -- Elusive Brawler (Brewmaster)
			196608, -- Eye of the Tiger (Brewmaster/Windwalker talent) -- NOTE: also HARMFUL with the same id (not supported)
			197916, -- Lifecycles (Vivify) (Mistweaver talent)
			197919, -- Lifecycles (Enveloping Mist) (Mistweaver talent)
			202090, -- Teachings of the Monastery (Mistweaver)
			228563, -- Blackout Combo (Brewmaster talent)
			247483, -- Tigereye Brew (Windwalker honor talent)
			261769, -- Inner Strength (Windwalker talent)
		},
	},
}, {
	-- map aura to provider(s)
	[115804] = 107428, -- Mortal Wounds (Windwalker) <- Rising Sun Kick
	[116189] = 115546, -- Provoke
	[116706] = 116095, -- Disable (Windwalker)
	[116768] = 100780, -- Blackout Kick! (Windwalker) <- Tiger Palm
	[118635] = 115315, -- Provoke (Brewmaster talent) <- Summon Black Ox Statue
	[119085] = 115008, -- Chi Torpedo (talent)
	[119611] = 115151, -- Renewing Mist (Mistweaver)
	[120954] = 115203, -- Fortifying Brew (Brewmaster)
	[123586] = 101545, -- Flying Serpent Kick (Wilnwalker)
	[123725] = 115181, -- Breath of Fire (Brewmaster)
	[125174] = 122470, -- Touch of Karma (Windwalker)
	[137639] = 221771, -- Storm, Earth, and Fire (Windwalker)
	[191840] = 231633, -- Essence Font <- Essense Font (Rank 2) (Mistweaver)
	[195630] = 117906, -- Elusive Brawler (Brewmaster) <- Mastery: Elusive Brawler
	[196608] = 196607, -- Eye of the Tiger (Brewmaster talent)
	[196727] = 132578, -- Provoke (Brewmaster talent) <- Invoke Niuzao, the Black Ox -- BUG: not in the spellbook
	[197916] = 197915, -- Lifecycles (Vivify) (Mistweaver talent) <- Lifecycles
	[197919] = 197915, -- Lifecycles (Enveloping Mist) (Mistweaver talent) <- Lifecycles
	[198533] = 115313, -- Soothing Mist (Mistweaver talent) <- Summon Jade Serpent Statue
	[198909] = 198898, -- Song of Chi-Ji (Mistweaver talent)
	[201447] = 201372, -- Ride the Wind (Windwalker honor talent)
	[201787] = 232054, -- Heavy-Handed Strikes (Windwalker honor talent)
	[202090] = 116645, -- Teachings of the Monastery (Mistweaver)
	[202248] = 202200, -- Guided Meditation (Brewmaster honor talent)
	[202274] = 202272, -- Incendiary Brew (Brewmaster honor talent) <- Incendiary Breath
	[202346] = 202335, -- Double Barrel (Brewmaster honor talent)
	[205655] = 202577, -- Dome of Mist (Mistweaver honor talent)
	[206891] = 207025, -- Intimidated (Brewmaster honor talent) <- Admonishment
	[215479] = 115308, -- Ironskin Brew (Brewmaster)
	[228287] = 101546, -- Mark of the Crane (Windwalker) <- Spinning Crane Kick
	[228563] = 196736, -- Blackout Combo (Brewmaster talent)
	[261769] = 261767, -- Inner Strength (Windwalker talent)
}, {
	-- map aura to modified spell(s)
	[116680] = { -- Thunder Focus Tea (Mistweaver)
		107428, -- Rising Sun Kick
		115151, -- Renewing Mist
		116670, -- Vivify
		124682, -- Enveloping Mist
	},
	[116768] = 100784, -- Blackout Kick! (Windwalker) -> Blackout Kick
	[118635] = 115546, -- Provoke (Brewmaster talent)
	[191840] = 191837, -- Essence Font (Mistweaver)
	[195630] = 205523, -- Elusive Brawler (Brewmaster) -> Blackout Strike
	[196608] = 100780, -- Eye of the Tiger (Brewmaster talent) -> Tiger Palm
	[196727] = 196727, -- Provoke (Niuzao) (Brewmaster talent) -- BUG: not in the spellbook
	[197916] = 116670, -- Lifecycles (Vivify) (Mistweaver talent) -> Vivify
	[197919] = 124682, -- Lifecycles (Enveloping Mist) (Mistweaver talent) -> Enveloping Mist
	[201447] = 101545, -- Ride the Wind (Windwalker honor talent) -> Flying Serpent Kick
	[201787] = 113656, -- Heavy-Handed Strikes (Windwalker honor talent) -> Fists of Fury
	[202090] = 100784, -- Teachings of the Monastery (Mistweaver) -> Blackout Kick
	[202248] = 115176, -- Guided Meditation (Brewmaster honor talent) -> Zen Meditation
	[202274] = 115181, -- Incendiary Brew (Brewmaster honor talent) -> Breath of Fire
	[202335] = 121253, -- Double Barrel (Brewmaster honor talent) -> Keg Smash
	[202346] = 121253, -- Double Barrel (Brewmaster honor talent) -> Keg Smash
	[205655] = 115151, -- Dome of Mist (Mistweaver honor talent) -> Renewing Mist
	[228563] = { -- Blackout Combo (Brewmaster talent)
		100780, -- Tiger Palm
		115181, -- Breath of Fire
		115308, -- Ironskin Brew
		121253, -- Keg Smash
	},
	[261769] = { -- Inner Strength (Windwalker talent)
		100784, -- Blackout Kick
		101546, -- Spinning Crane Kick
		107428, -- Rising Sun Kick
		113656, -- Fists of Fury
	},
})
