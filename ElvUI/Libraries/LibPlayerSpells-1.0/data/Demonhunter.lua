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
lib:__RegisterSpells("DEMONHUNTER", 80000, 2, {
	COOLDOWN = {
		 185123, -- Throw Glaive (Havoc)
		 189110, -- Infernal Strike (Vengeance)
		 195072, -- Fel Rush (Havoc)
		 198013, -- Eye Beam (Havoc)
		 203704, -- Mana Break (Havoc honor talent)
		 212084, -- Fel Devastation (Vengeance talent)
		 235903, -- Mana Rift (Havon honor talent)
		 258925, -- Fel Barrage (Havoc talent)
		[183752] = 'INTERRUPT', -- Disrupt
		AURA = {
			HELPFUL = {
				[209426] = 'SURVIVAL', -- Darkness (Havoc)
			},
			HARMFUL = {
				204598, -- Sigil of Flame (Vengeance)
				206491, -- Nemesis (Havoc talent)
				206649, -- Eye of Leotheras (Havoc honor talent)
				206891, -- Intimidated (Vengeance honor talent)
				207744, -- Fiery Brand (Vengeance)
				258860, -- Dark Slash (Havoc talent)
				258883, -- Trail of Ruin (Havoc talent)
				[204490] = 'INTERRUPT', -- Sigil of Silence (Vengeance)
				CROWD_CTRL = {
					[185245] = 'TAUNT', -- Torment (Vengeance)
					DISORIENT = {
						207685, -- Sigil of Misery (Vengeance)
					},
					INCAPACITATE = {
						217832, -- Imprison
						221527, -- Imprison (honor talent)
					},
					STUN = {
						179057, -- Chaos Nova (Havoc) -- BUG: the debuff is currently not applied
						200166, -- Metamorphosis (Havoc)
						205630, -- Illidan's Grasp (hold) (Vengeance honor talent)
						208618, -- Illidan's Grasp (thrown) (Vengeance honor talent)
						211881, -- Fel Eruption (Havoc talent)
						213491, -- Demonic Trample (Vengeance honor talent)
					},
				},
				SNARE = {
					198813, -- Vengeful Retreat (Havoc)
					204843, -- Sigil of Chains (Vengeance talent)
					210003, -- Razor Spikes (Vengeance talent)
					213405, -- Master of the Glaive (Havoc talent)
				},
			},
			PERSONAL = {
				188499, -- Blade Dance (Havoc) -- NOTE: somehow the same id as Sigil of Flame
				188501, -- Spectral Sight
				205629, -- Demonic Trample (Vengeance honor talent)
				206803, -- Rain from Above (launching) (Havoc honor talent)
				206804, -- Rain from Above (gliding) (Havoc honor talent)
				210152, -- Death Sweep (replaces Blade Dance when Metamorphosis) (Havoc)
				BURST = {
					162264, -- Metamorphosis (Havoc)
					208579, -- Nemesis (Demons) (Havoc talent)
					208605, -- Nemesis (Humanoids) (Havoc talent)
					208607, -- Nemesis (Aberrations) (Havoc talent)
					208608, -- Nemesis (Beasts) (Havoc talent)
					208609, -- Nemesis (Critters) (Havoc talent)
					208610, -- Nemesis (Draginkin) (Havoc talent)
					208611, -- Nemesis (Elementals) (Havoc talent)
					208612, -- Nemesis (Giants) (Havoc talent)
					208613, -- Nemesis (Mechanicals) (Havoc talent)
					208614, -- Nemesis (Undead) (Havoc talent)
					208628, -- Momentum (Havoc talent) (Havoc talent)
				},
				POWER_REGEN = {
					178740, -- Immolation Aura (Vengeance)
					258920, -- Immolation Aura (Havoc talent)
				},
				SURVIVAL = {
					187827, -- Metamorphosis (Vengeance)
					196555, -- Netherwalk (Havoc)
					203819, -- Demon Spikes (Vengeance)
					208796, -- Jagged Spikes (Vengeance honor talent)
					212800, -- Blur (Havoc)
					263648, -- Soul Barrier (Vengeance talent)
				},
			},
		},
		DISPEL = {
			MAGIC = {
				[205604] = 'HELPFUL', -- Reverse Magic (honor talent)
				[205625] = 'PERSONAL', -- Cleaned by Flame (Vengeance honor talent) -- NOTE: Immolation Aura is the dispelling spell
				[278326] = 'HARMFUL', -- Consume Magic
			},
		},
		POWER_REGEN = {
			162243, -- Demon's Bite (Havoc)
			232893, -- Felblade (talent)
			263642, -- Fracture (Vengeance talent)
		},
	},
	AURA = {
		HARMFUL = {
			247456, -- Frailty (Vengeance talent)
			268178, -- Void Reaver (Vengeance talent)
		},
		PERSONAL = {
			203981, -- Soul Fragments (Vengeance)
			207693, -- Feast of Souls (Vengeance talent)
		},
	},
	POWER_REGEN = {
		203782, -- Shear (Vengeance)
	}
}, {
	-- map aura to provider(s)
	[162264] = 191427, -- Metamorphosis (Havoc)
	[185245] = 198589, -- Torment (Vengeance)
	[187827] = 191427, -- Metamorphosis (Vengeance)
	[198813] = 198793, -- Vengeful Retreat (Havoc)
	[200166] = 191427, -- Metamorphosis (Havoc)
	[203819] = 203720, -- Demon Spikes (Vengeance)
	[203981] = { -- Soul Fragments (Vengeance)
		203782, -- Shear
		264632, -- Fracture (talent)
	},
	[204490] = 202137, -- Sigil of Silence (Vengeange)
	[204598] = 188499, -- Sigil of Flame (Vengeance)
	[204843] = 202138, -- Sigil of Chains (Vengeance talent)
	[206804] = 206803, -- Rain from Above (gliding) (Havoc honor talent)
	[206891] = 198589, -- Intimidated (Vengeance honor talent) <- Tormentor
	[207685] = 207684, -- Sigil of Misery (Vengeance)
	[207693] = 207697, -- Feast of Souls (Vengeance talent)
	[207744] = 204021, -- Fiery Brand (Vengeance)
	[208579] = 206491, -- Nemesis (Demons) (Havoc talent)
	[208605] = 206491, -- Nemesis (Humanoids) (Havoc talent)
	[208607] = 206491, -- Nemesis (Aberrations) (Havoc talent)
	[208608] = 206491, -- Nemesis (Beasts) (Havoc talent)
	[208609] = 206491, -- Nemesis (Critters) (Havoc talent)
	[208610] = 206491, -- Nemesis (Draginkin) (Havoc talent)
	[208611] = 206491, -- Nemesis (Elementals) (Havoc talent)
	[208612] = 206491, -- Nemesis (Giants) (Havoc talent)
	[208613] = 206491, -- Nemesis (Mechanicals) (Havoc talent)
	[208614] = 206491, -- Nemesis (Undead) (Havoc talent)
	[208618] = 205630, -- Illidan's Grasp (thrown) (Vengeance honor talent)
	[208628] = 206476, -- Momentum (Havoc talent)
	[208796] = 205627, -- Jagged Spikes (Vengeance honor talent) -- BUG: not in the spellbook
	[209426] = 196718, -- Darkness (Havoc)
	[210003] = 209400, -- Razor Spikes (Vengeance talent)
	[212800] = 198589, -- Blur (Havoc)
	[213405] = 203556, -- Master of the Glaive (Havoc talent)
	[213491] = 205629, -- Demonic Trample (Vengeance honor talent)
	[247456] = 247454, -- Frailty (Vengeance talent) <- Spirit Bomb
	[258883] = 258881, -- Trail of Ruin (Havoc talent)
	[268178] = 268175, -- Void Reaver (Vengeance talent)
}, {
	-- map aura to modified spell(s)
	[185245] = 185245, -- Torment (Vengeance)
	[187827] = 187827, -- Metamorphosis (Vengeance)
	[203981] = { -- Soul Fragments (Vengeance)
		228477, -- Soul Cleave
		247454, -- Soul Bomb (talent)
		263648, -- Soul Barrier (talent)
	},
	[204490] = { -- Sigil of Silence (Vengeange)
		202137, -- Sigil of Silence
		207682, -- Sigil of Silence (with Concentrated Sigils talent)
	},
	[204598] = { -- Sigil of Flame (Vengeance)
		204513, -- Sigil of Flame (with Concentrated Sigils talent)
		204596, -- Sigil of Flame
	},
	[205630] = 208173, -- Illidan's Grasp (Vengeance honor talent) -> Illidan's Grasp: Throw
	[206891] = 207029, -- Intimidated (Vengeance honor talent) <- Tormentor
	[207685] = { -- Sigil of Misery (Vengeance)
		202140, -- Sigil of Misery (with Concentrated Sigils talent)
		207684, -- Sigil of Misery
	},
	[207693] = 228477, -- Feast of Souls (Vengeance talent) -> Soul Cleave
	[208628] = 195072, -- Momentum (Havoc talent) -> Fel Rush
	[208796] = 203720, -- Jagged Spikes (Vengeance honor talent) -> Demon Spikes
	[210003] = 6603, -- Razor Spikes (Vengeance talent) -> Auto Attack
	[213405] = 185123, -- Master of the Glaive (Havoc talent) -> Throw Glaive
	[258883] = { -- Trail of Ruin (Havoc talent)
		188499, -- Blade Dance
		210152, -- Death Sweep (during Metamorphosis)
	},
	[268178] = 228477, -- Void Reaver (Vengeance talent) -> Soul Cleave
})
