local E, L, V, P, G, _ = unpack(select(2, ...)); --Engine

--Cache global variables
--Lua functions
local print, unpack, select, pairs = print, unpack, select, pairs
local lower = string.lower
--WoW API / Variables
local GetSpellInfo = GetSpellInfo
local UnitClass, IsEquippedItem = UnitClass, IsEquippedItem

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end

local function Defaults(priorityOverride)
	return {['enable'] = true, ['priority'] = priorityOverride or 0, ['stackThreshold'] = 0}
end

G.unitframe.aurafilters = {};

--[[
	These are debuffs that are some form of CC
]]
G.unitframe.aurafilters['CCDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	-- Death Knight
		[47476] = Defaults(), --Strangulate
		[91800] = Defaults(), --Gnaw (Pet)
		[91807] = Defaults(), --Shambling Rush (Pet)
		[91797] = Defaults(), --Monstrous Blow (Pet)
		[108194] = Defaults(), --Asphyxiate
	-- Druid
		[33786] = Defaults(), --Cyclone
		[339] = Defaults(), --Entangling Roots
		[78675] = Defaults(), --Solar Beam
		[22570] = Defaults(), --Maim
		[5211] = Defaults(), --Mighty Bash
		[102359] = Defaults(), --Mass Entanglement
		[99] = Defaults(), --Disorienting Roar
		[127797] = Defaults(), --Ursol's Vortex
		[45334] = Defaults(), --Immobilized
	-- Hunter
		[3355] = Defaults(), --Freezing Trap
		[24394] = Defaults(), --Intimidation
		[64803] = Defaults(), --Entrapment
		[19386] = Defaults(), --Wyvern Sting
		[117405] = Defaults(), --Binding Shot
		[128405] = Defaults(), --Narrow Escape
	-- Mage
		[31661] = Defaults(), --Dragon's Breath
		[118] = Defaults(), --Polymorph
		[122] = Defaults(), --Frost Nova
		[82691] = Defaults(), --Ring of Frost
		[44572] = Defaults(), --Deep Freeze
		[33395] = Defaults(), --Freeze (Water Ele)
		[102051] = Defaults(), --Frostjaw
	-- Paladin
		[20066] = Defaults(), --Repentance
		[853] = Defaults(), --Hammer of Justice
		[31935] = Defaults(), --Avenger's Shield
		[105421] = Defaults(), --Blinding Light
	-- Priest
		[605] = Defaults(), --Dominate Mind
		[64044] = Defaults(), --Psychic Horror
		[8122] = Defaults(), --Psychic Scream
		[9484] = Defaults(), --Shackle Undead
		[15487] = Defaults(), --Silence
		[114404] = Defaults(), --Void Tendrils
		[88625] = Defaults(), --Holy Word: Chastise
	-- Rogue
		[2094] = Defaults(), --Blind
		[1776] = Defaults(), --Gouge
		[6770] = Defaults(), --Sap
		[1833] = Defaults(), --Cheap Shot
		[1330] = Defaults(), --Garrote - Silence
		[408] = Defaults(), --Kidney Shot
		[88611] = Defaults(), --Smoke Bomb
	-- Shaman
		[51514] = Defaults(), --Hex
		[64695] = Defaults(), --Earthgrab
		--[63685] = Defaults(), --Freeze (Frozen Power)
		[118905] = Defaults(), --Static Charge
		[118345] = Defaults(), --Pulverize (Earth Elemental)
	-- Warlock
		[710] = Defaults(), --Banish
		[6789] = Defaults(), --Mortal Coil
		[118699] = Defaults(), --Fear
		[5484] = Defaults(), --Howl of Terror
		[6358] = Defaults(), --Seduction
		[30283] = Defaults(), --Shadowfury
		[115268] = Defaults(), --Mesmerize (Shivarra)
		[89766] = Defaults(), --Axe Toss (Felguard)
		--[137143] = Defaults(), --Blood Horror
	-- Warrior
		[7922] = Defaults(), --Charge Stun
		[105771] = Defaults(), --Warbringer
		[107566] = Defaults(), --Staggering Shout
		[132168] = Defaults(), --Shockwave
		[107570] = Defaults(), --Storm Bolt
	-- Monk
		[116706] = Defaults(), --Disable
		[115078] = Defaults(), --Paralysis
		--[119392] = Defaults(), --Charging Ox Wave
		[119381] = Defaults(), --Leg Sweep
		[120086] = Defaults(), --Fists of Fury
		[140023] = Defaults(), --Ring of Peace
	-- Racial
		[25046] = Defaults(), --Arcane Torrent
		[20549] = Defaults(), --War Stomp
		[107079] = Defaults(), --Quaking Palm
	},
}

--[[
	These are buffs that can be considered "protection" buffs
]]
G.unitframe.aurafilters['TurtleBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	--Mage
		[45438] = Defaults(5), -- Ice Block
		[115610] = Defaults(), -- Temporal Shield
	--Death Knight
		[48797] = Defaults(5), -- Anti-Magic Shell
		[48792] = Defaults(), -- Icebound Fortitude
		[49039] = Defaults(), -- Lichborne
		[87256] = Defaults(4), -- Dancing Rune Weapon
		[55233] = Defaults(), -- Vampiric Blood
		[50461] = Defaults(), -- Anti-Magic Zone
	--Priest
		[33206] = Defaults(3), -- Pain Suppression
		[47788] = Defaults(), -- Guardian Spirit
		[81782] = Defaults(), -- Power Word: Barrier
		[47585] = Defaults(5), -- Dispersion
	--Warlock
		[104773] = Defaults(), -- Unending Resolve
		--[110913] = Defaults(), -- Dark Bargain
		[108359] = Defaults(), -- Dark Regeneration
	--Druid
		[22812] = Defaults(2), -- Barkskin
		[102342] = Defaults(2), -- Ironbark
		[61336] = Defaults(), -- Survival Instincts
	--Hunter
		[19263] = Defaults(5), -- Deterrence
		[53480] = Defaults(), -- Roar of Sacrifice (Cunning)
	--Rogue
		[1966] = Defaults(), -- Feint
		[31224] = Defaults(), -- Cloak of Shadows
		[74001] = Defaults(), -- Combat Readiness
		[5277] = Defaults(5), -- Evasion
		[45182] = Defaults(), -- Cheating Death
	--Shaman
		[98007] = Defaults(), -- Spirit Link Totem
		[30823] = Defaults(), -- Shamanistic Rage
	--Paladin
		[1022] = Defaults(5), -- Hand of Protection
		[6940] = Defaults(), -- Hand of Sacrifice
		[31821] = Defaults(3), -- Devotion Aura
		[498] = Defaults(2), -- Divine Protection
		[642] = Defaults(5), -- Divine Shield
		[86659] = Defaults(4), -- Guardian of the Ancient Kings (Prot)
		[31850] = Defaults(4), -- Ardent Defender
	--Warrior
		[118038] = Defaults(5), -- Die by the Sword
		[97463] = Defaults(), -- Rallying Cry
		[12975] = Defaults(), -- Last Stand
		[114029] = Defaults(2), -- Safeguard
		[871] = Defaults(3), -- Shield Wall
		[114030] = Defaults(), -- Vigilance
	--Monk
		[120954] = Defaults(2), -- Fortifying Brew
		[122783] = Defaults(), -- Diffuse Magic
		[122278] = Defaults(), -- Dampen Harm
		[116849] = Defaults(), -- Life Cocoon
	--Racial
		[20594] = Defaults(), -- Stoneform
	},
}

G.unitframe.aurafilters['PlayerBuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
	--Mage
		[45438] = Defaults(), -- Ice Block
		[115610] = Defaults(), -- Temporal Shield
		[110909] = Defaults(), -- Alter Time
		[12051] = Defaults(), -- Evocation
		[12472] = Defaults(), -- Icy Veins
		[80353] = Defaults(), -- Time Warp
		[12042] = Defaults(), -- Arcane Power
		[32612] = Defaults(), -- Invisibility
		[110960] = Defaults(), -- Greater Invisibility
		[108839] = Defaults(), -- Ice Flows
		[108843] = Defaults(), -- Blazing Speed
	--Death Knight
		[48797] = Defaults(), -- Anti-Magic Shell
		[48792] = Defaults(), -- Icebound Fortitude
		[49039] = Defaults(), -- Lichborne
		[87256] = Defaults(), -- Dancing Rune Weapon
		[55233] = Defaults(), -- Vampiric Blood
		[50461] = Defaults(), -- Anti-Magic Zone
		[51271] = Defaults(), -- Pillar of Frost
	--Priest
		[33206] = Defaults(), -- Pain Suppression
		[47788] = Defaults(), -- Guardian Spirit
		[81782] = Defaults(), -- Power Word: Barrier
		[47585] = Defaults(), -- Dispersion
		[10060] = Defaults(), -- Power Infusion
		[114239] = Defaults(), -- Phantasm
		[119032] = Defaults(), -- Spectral Guise
		[27827] = Defaults(), -- Spirit of Redemption
	--Warlock
		[104773] = Defaults(), -- Unending Resolve
		[108359] = Defaults(), -- Dark Regeneration
		[88448] = Defaults(), -- Demonic Rebirth
	--Druid
		[22812] = Defaults(), -- Barkskin
		[102342] = Defaults(), -- Ironbark
		[61336] = Defaults(), -- Survival Instincts
		[117679] = Defaults(), -- Incarnation (Tree of Life)
		[102543] = Defaults(), -- Incarnation: King of the Jungle
		[102558] = Defaults(), -- Incarnation: Son of Ursoc
		[102560] = Defaults(), -- Incarnation: Chosen of Elune
		[106898] = Defaults(), -- Stampeding Roar
		[1850] = Defaults(), -- Dash
		[106951] = Defaults(), -- Berserk
		[52610] = Defaults(), -- Savage Roar
		[69369] = Defaults(), -- Predatory Swiftness
		[124974] = Defaults(), -- Nature's Vigil
	--Hunter
		[19263] = Defaults(), -- Deterrence
		[53480] = Defaults(), -- Roar of Sacrifice (Cunning)
		[54216] = Defaults(), -- Master's Call
		[3045] = Defaults(), -- Rapid Fire
		[3584] = Defaults(), -- Feign Death
		[131894] = Defaults(), -- A Murder of Crows
		[90355] = Defaults(), -- Ancient Hysteria
		[90361] = Defaults(), -- Spirit Mend
	--Rogue
		[31224] = Defaults(), -- Cloak of Shadows
		[74001] = Defaults(), -- Combat Readiness
		[5277] = Defaults(), -- Evasion
		[45182] = Defaults(), -- Cheating Death
		[2983] = Defaults(), -- Sprint
		[11327] = Defaults(), -- Vanish
		[108212] = Defaults(), -- Burst of Speed
		[79140] = Defaults(), -- Vendetta
		[13750] = Defaults(), -- Adrenaline Rush
	--Shaman
		[98007] = Defaults(), -- Spirit Link Totem
		[30823] = Defaults(), -- Shamanistic Rage
		[2825] = Defaults(), -- Bloodlust
		[79206] = Defaults(), -- Spiritwalker's Grace
		[8178] = Defaults(), -- Grounding Totem Effect
		[58875] = Defaults(), -- Spirit Walk
		[108281] = Defaults(), -- Ancestral Guidance
		[16166] = Defaults(), -- Elemental Mastery
		[114896] = Defaults(), -- Windwalk Totem
	--Paladin
		[1044] = Defaults(), -- Hand of Freedom
		[1022] = Defaults(), -- Hand of Protection
		[6940] = Defaults(), -- Hand of Sacrifice
		[31821] = Defaults(), -- Devotion Aura
		[498] = Defaults(), -- Divine Protection
		[642] = Defaults(), -- Divine Shield
		[86659] = Defaults(), -- Guardian of the Ancient Kings (Prot)
		[31850] = Defaults(), -- Ardent Defender
		[31884] = Defaults(), -- Avenging Wrath
		[53563] = Defaults(), -- Beacon of Light
		[31842] = Defaults(), -- Divine Favor
		[105809] = Defaults(), -- Holy Avenger
		[85499] = Defaults(), -- Speed of Light
	--Warrior
		[118038] = Defaults(), -- Die by the Sword
		[97463] = Defaults(), -- Rallying Cry
		[12975] = Defaults(), -- Last Stand
		[114029] = Defaults(), -- Safeguard
		[871] = Defaults(), -- Shield Wall
		[114030] = Defaults(), -- Vigilance
		[18499] = Defaults(), -- Berserker Rage
		[1719] = Defaults(), -- Recklessness
		[23920] = Defaults(), -- Spell Reflection
		[114028] = Defaults(), -- Mass Spell Reflection
		[46924] = Defaults(), -- Bladestorm
		[3411] = Defaults(), -- Intervene
		[107574] = Defaults(), -- Avatar
	--Monk
		[120954] = Defaults(), -- Fortifying Brew
		[122783] = Defaults(), -- Diffuse Magic
		[122278] = Defaults(), -- Dampen Harm
		[116849] = Defaults(), -- Life Cocoon
		[125174] = Defaults(), -- Touch of Karma
		[116841] = Defaults(), -- Tiger's Lust
	--Racial
		[20594] = Defaults(), -- Stoneform
		[59545] = Defaults(), -- Gift of the Naaru
		[20572] = Defaults(), -- Blood Fury
		[26297] = Defaults(), -- Berserking
		[68992] = Defaults(), -- Darkflight
	},
}

--[[
	Buffs that really we dont need to see
]]
G.unitframe.aurafilters['Blacklist'] = {
	['type'] = 'Blacklist',
	['spells'] = {
		[36900] = Defaults(), --Soul Split: Evil!
		[36901] = Defaults(), --Soul Split: Good
		[36893] = Defaults(), --Transporter Malfunction
		[114216] = Defaults(), --Angelic Bulwark
		[97821] = Defaults(), --Void-Touched
		[36032] = Defaults(), -- Arcane Charge
		[8733] = Defaults(), --Blessing of Blackfathom
		[57724] = Defaults(), --Sated
		[25771] = Defaults(), --forbearance
		[57723] = Defaults(), --Exhaustion
		[58539] = Defaults(), --watchers corpse
		[26013] = Defaults(), --deserter
		[71041] = Defaults(), --dungeon deserter
		[41425] = Defaults(), --"Hypothermia"
		[55711] = Defaults(), --Weakened Heart
		[8326] = Defaults(), --ghost
		[23445] = Defaults(), --evil twin
		[24755] = Defaults(), --gay homosexual tricked or treated debuff
		[25163] = Defaults(), --fucking annoying pet debuff oozeling disgusting aura
		[80354] = Defaults(), --timewarp debuff
		[95223] = Defaults(), --group res debuff
		[124275] = Defaults(), -- Stagger
		[124274] = Defaults(), -- Stagger
		[124273] = Defaults(), -- Stagger
		[117870] = Defaults(), -- Touch of The Titans
		[123981] = Defaults(), -- Perdition
		[15007] = Defaults(), -- Ress Sickness
		[113942] = Defaults(), -- Demonic: Gateway
		[89140] = Defaults(), -- Demonic Rebirth: Cooldown
		[95809] = Defaults(), --Insanity debuff (Hunter Pet heroism)
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters['Whitelist'] = {
	['type'] = 'Whitelist',
	['spells'] = {
		[31821] = Defaults(),  -- Devotion Aura
		[2825] = Defaults(),   -- Bloodlust
		[32182] = Defaults(),  -- Heroism
		[80353] = Defaults(),  -- Time Warp
		[90355] = Defaults(),  -- Ancient Hysteria
		[47788] = Defaults(),  -- Guardian Spirit
		[33206] = Defaults(),  -- Pain Suppression
		[116849] = Defaults(), -- Life Cocoon
		[22812] = Defaults(),  -- Barkskin
		[192132] = Defaults(), -- Mystic Empowerment: Thunder (Hyrja, Halls of Valor)
		[192133] = Defaults(), -- Mystic Empowerment: Holy (Hyrja, Halls of Valor)
	},
}

--RAID DEBUFFS
--[[
	This should be pretty self explainitory
]]
G.unitframe.aurafilters['RaidDebuffs'] = {
	['type'] = 'Whitelist',
	['spells'] = {
-- Legion
-- The Nighthold
	-- Skorpyron
		[204766] = Defaults(), -- Energy Surge
		[214718] = Defaults(), -- Acidic Fragments
		[211801] = Defaults(), -- Volatile Fragments
		[204284] = Defaults(), -- Broken Shard (Protection)
		[204275] = Defaults(), -- Arcanoslash (Tank)
		[211659] = Defaults(), -- Arcane Tether (Tank debuff)
		[204483] = Defaults(), -- Focused Blast (Stun)

	-- Chronomatic Anomaly
		[206607] = Defaults(), -- Chronometric Particles (Tank stack debuff)
		[206609] = Defaults(), -- Time Release (Heal buff/debuff)
		[205653] = Defaults(), -- Passage of Time
		[225901] = Defaults(), -- Time Bomb
		[207871] = Defaults(), -- Vortex (Mythic)
		[212099] = Defaults(), -- Temporal Charge

	-- Trilliax
		[206488] = Defaults(), -- Arcane Seepage
		[206641] = Defaults(), -- Arcane Spear (Tank)
		[206798] = Defaults(), -- Toxic Slice
		[214672] = Defaults(), -- Annihilation
		[214573] = Defaults(), -- Stuffed
		[214583] = Defaults(), -- Sterilize
		[208910] = Defaults(), -- Arcing Bonds
		[206838] = Defaults(), -- Succulent Feast

	-- Spellblade Aluriel
		[212492] = Defaults(), -- Annihilate (Tank)
		[212494] = Defaults(), -- Annihilated (Main Tank debuff)
		[212587] = Defaults(), -- Mark of Frost
		[212531] = Defaults(), -- Mark of Frost (marked)
		[212530] = Defaults(), -- Replicate: Mark of Frost
		[212647] = Defaults(), -- Frostbitten
		[212736] = Defaults(), -- Pool of Frost
		[213085] = Defaults(), -- Frozen Tempest
		[213621] = Defaults(), -- Entombed in Ice
		[213148] = Defaults(), -- Searing Brand Chosen
		[213181] = Defaults(), -- Searing Brand Stunned
		[213166] = Defaults(), -- Searing Brand
		[213278] = Defaults(), -- Burning Ground
		[213504] = Defaults(), -- Arcane Fog

	-- Tichondrius
		[206480] = Defaults(), -- Carrion Plague
		[215988] = Defaults(), -- Carrion Nightmare
		[208230] = Defaults(), -- Feast of Blood
		[212794] = Defaults(), -- Brand of Argus
		[216685] = Defaults(), -- Flames of Argus
		[206311] = Defaults(), -- Illusionary Night
		[206466] = Defaults(), -- Essence of Night
		[216024] = Defaults(), -- Volatile Wound
		[216027] = Defaults(), -- Nether Zone
		[216039] = Defaults(), -- Fel Storm
		[216726] = Defaults(), -- Ring of Shadows
		[216040] = Defaults(), -- Burning Soul

	-- Krosus
		[206677] = Defaults(), -- Searing Brand
		[205344] = Defaults(), -- Orb of Destruction

	-- High Botanist Tel'arn
		[218503] = Defaults(), -- Recursive Strikes (Tank)
		[219235] = Defaults(), -- Toxic Spores
		[218809] = Defaults(), -- Call of Night
		[218342] = Defaults(), -- Parasitic Fixate
		[218304] = Defaults(), -- Parasitic Fetter
		[218780] = Defaults(), -- Plasma Explosion

	-- Star Augur Etraeus
		[205984] = Defaults(), -- Gravitaional Pull
		[214167] = Defaults(), -- Gravitaional Pull
		[214335] = Defaults(), -- Gravitaional Pull
		[206936] = Defaults(), -- Icy Ejection
		[206388] = Defaults(), -- Felburst
		[206585] = Defaults(), -- Absolute Zero
		[206398] = Defaults(), -- Felflame
		[206589] = Defaults(), -- Chilled
		[205649] = Defaults(), -- Fel Ejection
		[206965] = Defaults(), -- Voidburst
		[206464] = Defaults(), -- Coronal Ejection
		[207143] = Defaults(), -- Void Ejection
		[206603] = Defaults(), -- Frozen Solid
		[207720] = Defaults(), -- Witness the Void
		[216697] = Defaults(), -- Frigid Pulse

	-- Grand Magistrix Elisande
		[209166] = Defaults(), -- Fast Time
		[211887] = Defaults(), -- Ablated
		[209615] = Defaults(), -- Ablation
		[209244] = Defaults(), -- Delphuric Beam
		[209165] = Defaults(), -- Slow Time
		[209598] = Defaults(), -- Conflexive Burst
		[209433] = Defaults(), -- Spanning Singularity
		[209973] = Defaults(), -- Ablating Explosion
		[209549] = Defaults(), -- Lingering Burn
		[211261] = Defaults(), -- Permaliative Torment
		[208659] = Defaults(), -- Arcanetic Ring

	-- Gul'dan
		[210339] = Defaults(), -- Time Dilation
		[180079] = Defaults(), -- Felfire Munitions
		[206875] = Defaults(), -- Fel Obelisk (Tank)
		[206840] = Defaults(), -- Gaze of Vethriz
		[206896] = Defaults(), -- Torn Soul
		[206221] = Defaults(), -- Empowered Bonds of Fel
		[208802] = Defaults(), -- Soul Corrosion
		[212686] = Defaults(), -- Flames of Sargeras

-- The Emerald Nightmare
	-- Nythendra
		[204504] = Defaults(), -- Infested
		[205043] = Defaults(), -- Infested mind
		[203096] = Defaults(), -- Rot
		[204463] = Defaults(), -- Volatile Rot
		[203045] = Defaults(), -- Infested Ground
		[203646] = Defaults(), -- Burst of Corruption

	-- Elerethe Renferal
		[210228] = Defaults(), -- Dripping Fangs
		[215307] = Defaults(), -- Web of Pain
		[215300] = Defaults(), -- Web of Pain
		[215460] = Defaults(), -- Necrotic Venom
		[213124] = Defaults(), -- Venomous Pool
		[210850] = Defaults(), -- Twisting Shadows
		[215489] = Defaults(), -- Venomous Pool

	-- Il'gynoth, Heart of the Corruption
		[208929] = Defaults(), -- Spew Corruption
		[210984] = Defaults(), -- Eye of Fate
		[209469] = Defaults(5), -- Touch of Corruption
		[208697] = Defaults(), -- Mind Flay

	-- Ursoc
		[198108] = Defaults(), -- Unbalanced
		[197943] = Defaults(), -- Overwhelm
		[204859] = Defaults(), -- Rend Flesh
		[205611] = Defaults(), -- Miasma
		[198006] = Defaults(), -- Focused Gaze
		[197980] = Defaults(), -- Nightmarish Cacophony

	-- Dragons of Nightmare
		[203102] = Defaults(), -- Mark of Ysondre
		[203121] = Defaults(), -- Mark of Taerar
		[203125] = Defaults(), -- Mark of Emeriss
		[203124] = Defaults(), -- Mark of Lethon
		[204731] = Defaults(5), -- Wasting Dread
		[203110] = Defaults(5), -- Slumbering Nightmare
		[207681] = Defaults(5), -- Nightmare Bloom
		[205341] = Defaults(5), -- Sleeping Fog
		[203770] = Defaults(5), -- Defiled Vines
		[203787] = Defaults(5), -- Volatile Infection

	-- Cenarius
		[210279] = Defaults(), -- Creeping Nightmares
		[213162] = Defaults(), -- Nightmare Blast
		[210315] = Defaults(), -- Nightmare Brambles
		[212681] = Defaults(), -- Cleansed Ground
		[211507] = Defaults(), -- Nightmare Javelin
		[211471] = Defaults(), -- Scorned Touch
		[211612] = Defaults(), -- Replenishing Roots
		[216516] = Defaults(), -- Ancient Dream

	-- Xavius
		[206005] = Defaults(), -- Dream Simulacrum
		[206651] = Defaults(), -- Darkening Soul
		[209158] = Defaults(), -- Blackening Soul
		[211802] = Defaults(), -- Nightmare Blades
		[206109] = Defaults(), -- Awakening to the Nightmare
		[209034] = Defaults(), -- Bonds of Terror
		[210451] = Defaults(), -- Bonds of Terror
		[208431] = Defaults(), -- Corruption: Descent into Madness
		[207409] = Defaults(), -- Madness
		[211634] = Defaults(), -- The Infinite Dark
		[208385] = Defaults(), -- Tainted Discharge
	},
}

--Spells that we want to show the duration backwards
E.ReverseTimer = {

}

--BuffWatch
--List of personal spells to show on unitframes as icon
local function ClassBuff(id, point, color, anyUnit, onlyShowMissing, style, displayText, decimalThreshold, textColor, textThreshold, xOffset, yOffset)
	local r, g, b = unpack(color)

	local r2, g2, b2 = 1, 1, 1
	if textColor then
		r2, g2, b2 = unpack(textColor)
	end

	return {["enabled"] = true, ["id"] = id, ["point"] = point, ["color"] = {["r"] = r, ["g"] = g, ["b"] = b},
	["anyUnit"] = anyUnit, ["onlyShowMissing"] = onlyShowMissing, ['style'] = style or 'coloredIcon', ['displayText'] = displayText or false, ['decimalThreshold'] = decimalThreshold or 5,
	['textColor'] = {["r"] = r2, ["g"] = g2, ["b"] = b2}, ['textThreshold'] = textThreshold or -1, ['xOffset'] = xOffset or 0, ['yOffset'] = yOffset or 0}
end

G.unitframe.buffwatch = {
	PRIEST = {
		[194384] = ClassBuff(194384, "TOPRIGHT", {1, 0, 0.75}, true),        -- Atonement
		[41635] = ClassBuff(41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}),          -- Prayer of Mending
		[139] = ClassBuff(139, "BOTTOMLEFT", {0.4, 0.7, 0.2}),               -- Renew
		[17] = ClassBuff(17, "TOPLEFT", {0.81, 0.85, 0.1}, true),            -- Power Word: Shield
		[47788] = ClassBuff(47788, "LEFT", {221/255, 117/255, 0}, true),     -- Guardian Spirit
		[33206] = ClassBuff(33206, "LEFT", {227/255, 23/255, 13/255}, true), -- Pain Suppression
	},
	DRUID = {
		[774] = ClassBuff(774, "TOPRIGHT", {0.8, 0.4, 0.8}),      -- Rejuvenation
		[155777] = ClassBuff(155777, "RIGHT", {0.8, 0.4, 0.8}),   -- Germination
		[8936] = ClassBuff(8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}),  -- Regrowth
		[33763] = ClassBuff(33763, "TOPLEFT", {0.4, 0.8, 0.2}),   -- Lifebloom
		[188550] = ClassBuff(188550, "TOPLEFT", {0.4, 0.8, 0.2}), -- Lifebloom T18 4pc
		[48438] = ClassBuff(48438, "BOTTOMRIGHT", {0.8, 0.4, 0}), -- Wild Growth
		[207386] = ClassBuff(207386, "TOP", {0.4, 0.2, 0.8}),     -- Spring Blossoms
		[102352] = ClassBuff(102352, "LEFT", {0.2, 0.8, 0.8}),    -- Cenarion Ward
		[200389] = ClassBuff(200389, "BOTTOM", {1, 1, 0.4}),      -- Cultivation
	},
	PALADIN = {
		[53563] = ClassBuff(53563, "TOPRIGHT", {0.7, 0.3, 0.7}),         -- Beacon of Light
		[156910] = ClassBuff(156910, "TOPRIGHT", {0.7, 0.3, 0.7}),       -- Beacon of Faith
		[1022] = ClassBuff(1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true),    -- Hand of Protection
		[1044] = ClassBuff(1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true),  -- Hand of Freedom
		[6940] = ClassBuff(6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true), -- Hand of Sacrifice
		[114163] = ClassBuff(114163, 'BOTTOMLEFT', {0.87, 0.7, 0.03}),   -- Eternal Flame
	},
	SHAMAN = {
		[61295] = ClassBuff(61295, "TOPRIGHT", {0.7, 0.3, 0.7}), -- Riptide
	},
	MONK = {
		[119611] = ClassBuff(119611, "TOPLEFT", {0.8, 0.4, 0.8}),    --Renewing Mist
		[116849] = ClassBuff(116849, "TOPRIGHT", {0.2, 0.8, 0.2}),   -- Life Cocoon
		[124682] = ClassBuff(124682, "BOTTOMLEFT", {0.4, 0.8, 0.2}), -- Enveloping Mist
		[124081] = ClassBuff(124081, "BOTTOMRIGHT", {0.7, 0.4, 0}),  -- Zen Sphere
	},
	ROGUE = {
		[57934] = ClassBuff(57934, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Tricks of the Trade
	},
	WARRIOR = {
		[114030] = ClassBuff(114030, "TOPLEFT", {0.2, 0.2, 1}),          -- Vigilance
		[3411] = ClassBuff(3411, "TOPRIGHT", {227/255, 23/255, 13/255}), -- Intervene
	},
	PET = {
		[19615] = ClassBuff(19615, 'TOPLEFT', {227/255, 23/255, 13/255}, true), -- Frenzy
		[136] = ClassBuff(136, 'TOPRIGHT', {0.2, 0.8, 0.2}, true) --Mend Pet
	},
	HUNTER = {}, --Keep even if it's an empty table, so a reference to G.unitframe.buffwatch[E.myclass][SomeValue] doesn't trigger error
	DEMONHUNTER = {},
	WARLOCK = {},
	MAGE = {},
	DEATHKNIGHT = {},
}

--Profile specific BuffIndicator
P['unitframe']['filters'] = {
	['buffwatch'] = {},
}

--List of spells to display ticks
G.unitframe.ChannelTicks = {
	--Warlock
	[SpellName(689)] = 6, -- "Drain Life"
	[SpellName(198590)] = 6, -- "Drain Soul"
	[SpellName(755)] = 6, -- Health Funnel
	--Priest
	[SpellName(48045)] = 5, -- "Mind Sear"
	[SpellName(179338)] = 5, -- "Searing insanity"
	[SpellName(64843)] = 4, -- Divine Hymn
	[SpellName(15407)] = 4, -- Mind Flay
	--Mage
	[SpellName(5143)] = 5, -- "Arcane Missiles"
	[SpellName(12051)] = 3, -- "Evocation"
}

local priestTier17 = {115560,115561,115562,115563,115564}
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:SetScript("OnEvent", function()
	local class = select(2, UnitClass("player"))
	if lower(class) ~= "priest" then return; end

	local penanceTicks = 3
	local equippedPriestTier17 = 0
	for _, item in pairs(priestTier17) do
		if IsEquippedItem(item) then
			equippedPriestTier17 = equippedPriestTier17 + 1
		end
	end
	if equippedPriestTier17 >= 2 then
		penanceTicks = 4
	end
	E.global.unitframe.ChannelTicks[SpellName(47540)] = penanceTicks --Penance
end)

G.unitframe.ChannelTicksSize = {
	--Warlock
	[SpellName(689)] = 1, -- "Drain Life"
	[SpellName(198590)] = 1, -- "Drain Soul"
}

--Spells Effected By Haste
G.unitframe.HastedChannelTicks = {

}

--This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825] = {r = 250/255, g = 146/255, b = 27/255},  --Bloodlust
	[32182] = {r = 250/255, g = 146/255, b = 27/255}, --Heroism
	[80353] = {r = 250/255, g = 146/255, b = 27/255}, --Time Warp
	[90355] = {r = 250/255, g = 146/255, b = 27/255}, --Ancient Hysteria
}

G.unitframe.DebuffHighlightColors = {
	[25771] = {enable = false, style = "FILL", color = {r = 0.85, g = 0, b = 0, a = 0.85}},
}
