local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- This used to be standalone and is now merged into G.unitframe.aurafilters.Whitelist
G.unitframe.aurafilters.PlayerBuffs = nil

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Evoker
		[355689]	= List(2), -- Landslide
		[370898]	= List(1), -- Permeating Chill
		[408544]	= List(4), -- Seismic Slam (Stun)
		[360806]	= List(3), -- Sleep Walk
	-- Death Knight
		[47476]		= List(2), -- Strangulate
		[108194]	= List(4), -- Asphyxiate UH
		[221562]	= List(4), -- Asphyxiate Blood
		[207171]	= List(4), -- Winter is Coming
		[206961]	= List(3), -- Tremble Before Me
		[207167]	= List(4), -- Blinding Sleet
		[212540]	= List(1), -- Flesh Hook (Pet)
		[91807]		= List(1), -- Shambling Rush (Pet)
		[204085]	= List(1), -- Deathchill
		[233395]	= List(1), -- Frozen Center
		[212332]	= List(4), -- Smash (Pet)
		[212337]	= List(4), -- Powerful Smash (Pet)
		[91800]		= List(4), -- Gnaw (Pet)
		[91797]		= List(4), -- Monstrous Blow (Pet)
		[210141]	= List(3), -- Zombie Explosion
	-- Demon Hunter
		[207685]	= List(4), -- Sigil of Misery
		[217832]	= List(3), -- Imprison
		[221527]	= List(5), -- Imprison (Banished version)
		[204490]	= List(2), -- Sigil of Silence
		[179057]	= List(3), -- Chaos Nova
		[211881]	= List(4), -- Fel Eruption
		[205630]	= List(3), -- Illidan's Grasp
		[208618]	= List(3), -- Illidan's Grasp (Afterward)
		[213491]	= List(4), -- Demonic Trample 1
		[208645]	= List(4), -- Demonic Trample 2
	-- Druid
		[81261]		= List(2), -- Solar Beam
		[5211]		= List(4), -- Mighty Bash
		[163505]	= List(4), -- Rake
		[203123]	= List(4), -- Maim
		[202244]	= List(4), -- Overrun
		[99]		= List(4), -- Incapacitating Roar
		[33786]		= List(5), -- Cyclone
		[45334]		= List(1), -- Immobilized
		[102359]	= List(1), -- Mass Entanglement
		[339]		= List(1), -- Entangling Roots
		[2637]		= List(1), -- Hibernate
		[102793]	= List(1), -- Ursol's Vortex
	-- Hunter
		[202933]	= List(2), -- Spider Sting 1
		[233022]	= List(2), -- Spider Sting 2
		[213691]	= List(4), -- Scatter Shot
		[19386]		= List(3), -- Wyvern Sting
		[3355]		= List(3), -- Freezing Trap
		[203337]	= List(5), -- Freezing Trap (PvP Talent)
		[209790]	= List(3), -- Freezing Arrow
		[24394]		= List(4), -- Intimidation
		[117526]	= List(4), -- Binding Shot
		[190927]	= List(1), -- Harpoon
		[201158]	= List(1), -- Super Sticky Tar
		[162480]	= List(1), -- Steel Trap
		[212638]	= List(1), -- Tracker's Net
		[200108]	= List(1), -- Ranger's Net
		[356727]	= List(4), -- Spider Venom (Silence)
		[407032]	= List(4), -- Super Sticky Tar Bomb (Disarm)
		[407031]	= List(4), -- Super Sticky Tar Bomb #2 (Disarm)
		[451517]	= List(4), -- Catch Out (Root)
	-- Mage
		[61721]		= List(3), -- Rabbit
		[61305]		= List(3), -- Black Cat
		[28272]		= List(3), -- Pig
		[28271]		= List(3), -- Turtle
		[126819]	= List(3), -- Porcupine
		[161354]	= List(3), -- Monkey
		[161353]	= List(3), -- Polar Bear
		[61780]		= List(3), -- Turkey
		[161355]	= List(3), -- Penguin
		[161372]	= List(3), -- Peacock
		[277787]	= List(3), -- Direhorn
		[277792]	= List(3), -- Bumblebee
		[118]		= List(3), -- Polymorph
		[82691]		= List(3), -- Ring of Frost
		[31661]		= List(3), -- Dragon's Breath
		[122]		= List(1), -- Frost Nova
		[33395]		= List(1), -- Freeze
		[157997]	= List(1), -- Ice Nova
		[228600]	= List(1), -- Glacial Spike
		[198121]	= List(1), -- Frostbite
		[461489]	= List(4), -- New Polymorph Variant #1 (CC)
		[460392]	= List(4), -- New Polymorph Variant #2 (CC)
		[391622]	= List(4), -- New Polymorph Variant #3 (CC)
		[383121]	= List(4), -- Mass Polymorph (CC)
		[449700]	= List(4), -- Gravity Lapse (Root)
	-- Monk
		[119381]	= List(4), -- Leg Sweep
		[202346]	= List(4), -- Double Barrel
		[115078]	= List(4), -- Paralysis
		[198909]	= List(3), -- Song of Chi-Ji
		[202274]	= List(3), -- Incendiary Brew
		[233759]	= List(2), -- Grapple Weapon
		[123407]	= List(1), -- Spinning Fire Blossom
		[116706]	= List(1), -- Disable
		[232055]	= List(4), -- Fists of Fury
		[324382]	= List(4), -- Clash (Root)
	-- Paladin
		[853]		= List(3), -- Hammer of Justice
		[20066]		= List(3), -- Repentance
		[105421]	= List(3), -- Blinding Light
		[31935]		= List(2), -- Avenger's Shield
		[217824]	= List(2), -- Shield of Virtue
		[205290]	= List(3), -- Wake of Ashes 1
		[255941]	= List(4), -- Wake of Ashes 2 (Stun)
	-- Priest
		[9484]		= List(3), -- Shackle Undead
		[200196]	= List(4), -- Holy Word: Chastise
		[200200]	= List(4), -- Holy Word: Chastise
		[605]		= List(5), -- Mind Control
		[8122]		= List(3), -- Psychic Scream
		[15487]		= List(2), -- Silence
		[64044]		= List(1), -- Psychic Horror
		[453]		= List(5), -- Mind Soothe
	-- Rogue
		[2094]		= List(4), -- Blind
		[6770]		= List(4), -- Sap
		[1776]		= List(4), -- Gouge
		[1330]		= List(2), -- Garrote - Silence
		[207777]	= List(2), -- Dismantle
		[408]		= List(4), -- Kidney Shot
		[1833]		= List(4), -- Cheap Shot
		[207736]	= List(5), -- Shadowy Duel (Smoke effect)
		[212182]	= List(5), -- Smoke Bomb
	-- Shaman
		[51514]		= List(3), -- Hex
		[211015]	= List(3), -- Hex (Cockroach)
		[211010]	= List(3), -- Hex (Snake)
		[211004]	= List(3), -- Hex (Spider)
		[210873]	= List(3), -- Hex (Compy)
		[196942]	= List(3), -- Hex (Voodoo Totem)
		[269352]	= List(3), -- Hex (Skeletal Hatchling)
		[277778]	= List(3), -- Hex (Zandalari Tendonripper)
		[277784]	= List(3), -- Hex (Wicker Mongrel)
		[118905]	= List(3), -- Static Charge
		[77505]		= List(4), -- Earthquake (Knocking down)
		[118345]	= List(4), -- Pulverize (Pet)
		[204399]	= List(3), -- Earthfury
		[204437]	= List(3), -- Lightning Lasso
		[157375]	= List(4), -- Gale Force
		[64695]		= List(1), -- Earthgrab
		[197214]	= List(4), -- Sundering (CC)
	-- Warlock
		[710]		= List(5), -- Banish
		[6789]		= List(3), -- Mortal Coil
		[118699]	= List(3), -- Fear
		[6358]		= List(3), -- Seduction (Succub)
		[171017]	= List(4), -- Meteor Strike (Infernal)
		[22703]		= List(4), -- Infernal Awakening (Infernal CD)
		[30283]		= List(3), -- Shadowfury
		[89766]		= List(4), -- Axe Toss
		[233582]	= List(1), -- Entrenched in Flame
		[130616]	= List(4), -- Fear Standstill (CC)
	-- Warrior
		[5246]		= List(4), -- Intimidating Shout
		[132169]	= List(4), -- Storm Bolt
		[132168]	= List(4), -- Shockwave
		[199085]	= List(4), -- Warpath
		[199042]	= List(1), -- Thunderstruck
		[236077]	= List(2), -- Disarm
		[105771]	= List(2), -- Charge
		[316593]	= List(4), -- Intimidating Shout Standstill Target (CC)
		[316595]	= List(4), -- Intimidating Shout Standstill Others (CC)
		[385954]	= List(4), -- Shield Charge (Stun)
	-- Racial
		[20549]		= List(4), -- War Stomp
		[107079]	= List(4), -- Quaking Palm
	-- Uncategorized
		[389831]	= List(4), -- Snowdrift (Stun)
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Evoker
		[378464]	= List(), -- Nullifying Shroud (PvP)
		[363916]	= List(), -- Obsidian Scales
		[374348]	= List(), -- Renewing Blaze
		[357170]	= List(), -- Time Dilation
	-- Death Knight
		[48707]		= List(), -- Anti-Magic Shell
		[49039]		= List(), -- Lichborne
		[81256]		= List(), -- Dancing Rune Weapon
		[55233]		= List(), -- Vampiric Blood
		[193320]	= List(), -- Umbilicus Eternus
		[219809]	= List(), -- Tombstone
		[48792]		= List(), -- Icebound Fortitude
		[207319]	= List(), -- Corpse Shield
		[194844]	= List(), -- BoneStorm
		[145629]	= List(), -- Anti-Magic Zone
		[194679]	= List(), -- Rune Tap
	-- Demon Hunter
		[207811]	= List(), -- Nether Bond (DH)
		[207810]	= List(), -- Nether Bond (Target)
		[187827]	= List(), -- Metamorphosis
		[263648]	= List(), -- Soul Barrier
		[209426]	= List(), -- Darkness
		[196555]	= List(), -- Netherwalk
		[212800]	= List(), -- Blur
		[188499]	= List(), -- Blade Dance
		[203819]	= List(), -- Demon Spikes
	-- Druid
		[102342]	= List(), -- Ironbark
		[61336]		= List(), -- Survival Instincts
		[210655]	= List(), -- Protection of Ashamane
		[22812]		= List(), -- Barkskin
		[200851]	= List(), -- Rage of the Sleeper
		[234081]	= List(), -- Celestial Guardian
		[202043]	= List(), -- Protector of the Pack 1
		[201940]	= List(), -- Protector of the Pack 2
		[201939]	= List(), -- Protector of the Pack 3
		[192081]	= List(), -- Ironfur
		[50334]		= List(), -- Berserk (Guardian)
	-- Hunter
		[186265]	= List(), -- Aspect of the Turtle
		[53480]		= List(), -- Roar of Sacrifice
		[202748]	= List(), -- Survival Tactics
		[264735]	= List(), -- Survival of the Fittest
	-- Mage
		[414658]	= List(), -- Ice Cold
		[45438]		= List(), -- Ice Block
		[110960]	= List(), -- Greater Invisibility
		[198111]	= List(), -- Temporal Shield
		[198065]	= List(), -- Prismatic Cloak
		[11426]		= List(), -- Ice Barrier
		[235313]	= List(), -- Blazing Barrier
		[235450]	= List(), -- Prismatic Barrier
		[110909]	= List(), -- Alter Time
		[342246]	= List(), -- Alter Time
	-- Monk
		[122783]	= List(), -- Diffuse Magic
		[122278]	= List(), -- Dampen Harm
		[125174]	= List(), -- Touch of Karma
		[201318]	= List(), -- Fortifying Elixir
		[202248]	= List(), -- Guided Meditation
		[120954]	= List(), -- Fortifying Brew
		[116849]	= List(), -- Life Cocoon
		[202162]	= List(), -- Guard
		[215479]	= List(), -- Ironskin Brew
		[353319]	= List(), -- Peaceweaver (PvP)
		[353362]	= List(), -- Dematerialize (PvP)
	-- Paladin
		[642]		= List(), -- Divine Shield
		[498]		= List(), -- Divine Protection (Holy)
		[403876]	= List(), -- Divine Protection (Retri)
		[205191]	= List(), -- Eye for an Eye
		[184662]	= List(), -- Shield of Vengeance
		[1022]		= List(), -- Blessing of Protection
		[6940]		= List(), -- Blessing of Sacrifice
		[204018]	= List(), -- Blessing of Spellwarding
		[199507]	= List(), -- Spreading The Word: Protection
		[216857]	= List(), -- Guarded by the Light
		[228049]	= List(), -- Guardian of the Forgotten Queen
		[31850]		= List(), -- Ardent Defender
		[86659]		= List(), -- Guardian of Ancien Kings
		[212641]	= List(), -- Guardian of Ancien Kings (Glyph of the Queen)
		[209388]	= List(), -- Bulwark of Order
		[132403]	= List(), -- Shield of the Righteous
	-- Priest
		[81782]		= List(), -- Power Word: Barrier
		[47585]		= List(), -- Dispersion
		[19236]		= List(), -- Desperate Prayer
		[27827]		= List(), -- Spirit of Redemption
		[197268]	= List(), -- Ray of Hope
		[47788]		= List(), -- Guardian Spirit
		[33206]		= List(), -- Pain Suppression
	-- Rogue
		[5277]		= List(), -- Evasion
		[31224]		= List(), -- Cloak of Shadows
		[1966]		= List(), -- Feint
		[199754]	= List(), -- Riposte
		[45182]		= List(), -- Cheating Death
		[199027]	= List(), -- Veil of Midnight
	-- Shaman
		[114893]	= List(), -- Stone Bulwark
		[462844]	= List(), -- Stone Bulwark (additional)
		[325174]	= List(), -- Spirit Link
		[974]		= List(), -- Earth Shield
		[207654]	= List(), -- Servant of the Queen
		[108271]	= List(), -- Astral Shift
		[207498]	= List(), -- Ancestral Protection
	-- Warlock
		[108416]	= List(), -- Dark Pact
		[104773]	= List(), -- Unending Resolve
		[221715]	= List(), -- Essence Drain
		[212295]	= List(), -- Nether Ward
	-- Warrior
		[118038]	= List(), -- Die by the Sword
		[184364]	= List(), -- Enraged Regeneration
		[209484]	= List(), -- Tactical Advance
		[97463]		= List(), -- Commanding Shout
		[213915]	= List(), -- Mass Spell Reflection
		[199038]	= List(), -- Leave No Man Behind
		[223658]	= List(), -- Safeguard
		[147833]	= List(), -- Intervene
		[198760]	= List(), -- Intercept
		[12975]		= List(), -- Last Stand
		[871]		= List(), -- Shield Wall
		[23920]		= List(), -- Spell Reflection
		[203524]	= List(), -- Neltharion's Fury
		[190456]	= List(), -- Ignore Pain
		[132404]	= List(), -- Shield Block
	-- Racial
		[65116]		= List(), -- Stoneform
	},
}

-- Buffs that we don't really need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
		[8326]		= List(), -- Ghost
		[8733]		= List(), -- Blessing of Blackfathom
		[15007]		= List(), -- Ress Sickness
		[23445]		= List(), -- Evil Twin
		[24755]		= List(), -- Tricked or Treated
		[25163]		= List(), -- Oozeling's Disgusting Aura
		[25771]		= List(), -- Forbearance
		[26013]		= List(), -- Deserter
		[36032]		= List(), -- Arcane Charge
		[36893]		= List(), -- Transporter Malfunction
		[36900]		= List(), -- Soul Split: Evil!
		[36901]		= List(), -- Soul Split: Good
		[41425]		= List(), -- Hypothermia
		[49822]		= List(), -- Bloated
		[55711]		= List(), -- Weakened Heart
		[57723]		= List(), -- Exhaustion (heroism debuff)
		[57724]		= List(), -- Sated (lust debuff)
		[58539]		= List(), -- Watcher's Corpse
		[71041]		= List(), -- Dungeon Deserter
		[80354]		= List(), -- Temporal Displacement (timewarp debuff)
		[89140]		= List(), -- Demonic Rebirth: Cooldown
		[95809]		= List(), -- Insanity debuff (hunter pet heroism: ancient hysteria)
		[96041]		= List(), -- Stink Bombed
		[97821]		= List(), -- Void-Touched
		[113942]	= List(), -- Demonic: Gateway
		[117870]	= List(), -- Touch of The Titans
		[123981]	= List(), -- Perdition
		[124273]	= List(), -- Stagger
		[124274]	= List(), -- Stagger
		[124275]	= List(), -- Stagger
		[195776]	= List(), -- Moonfeather Fever
		[196342]	= List(), -- Zanzil's Embrace
		[206150]	= List(), -- Challenger's Burden SL
		[206151]	= List(), -- Challenger's Burden BfA
		[206662]	= List(), -- Experience Eliminated (in range)
		[234143]	= List(), -- Temptation (Upper Karazhan Ring Debuff)
		[287825]	= List(), -- Lethargy debuff (fight or flight)
		[306600]	= List(), -- Experience Eliminated (oor - 5m)
		[313015]	= List(), -- Recently Failed (Mechagnome racial)
		[322695]	= List(), -- Drained
		[328891]	= List(), -- A Gilded Perspective
		[348443]	= List(), -- Experience Eliminated
		[374037]	= List(), -- Overwhelming Rage
		[374609]	= List(), -- Blood Draw
		[382912]	= List(), -- Well-Honed Instincts
		[383600]	= List(), -- Surrounding Storm (Strunraan)
		[390106]	= List(), -- Riding Along
		[390435]	= List(), -- Exhaustion (Evoker lust debuff)
		[392960]	= List(), -- Waygate Travel
		[392992]	= List(), -- Silent Lava
		[393798]	= List(), -- Activated Defense Systems
		[404464]	= List(), -- Flight Style: Skyriding
		[404468]	= List(), -- Flight Style: Steady
		[418990]	= List(), -- Wicker Men's Curse
		[426790]	= List(), -- Call of the Elder Druid
		[430191]	= List(), -- Warband Mentored Leveling
		[455020]	= List(), -- WoW's Anniversary
		[1219312]	= List(), -- Mmm, Tacos...
		[264689]	= List(), -- Fatigued (11.1 Bloodlust)
		[1226677]	= List(), -- Cartel Jumper Cables
	},
}

-- A list of important buffs that we always want to see
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
	-- General
		[256948]	= List(), -- Spatial Rift
		[65116]		= List(), -- Stoneform
		[59547]		= List(), -- Gift of the Naaru
		[20572]		= List(), -- Blood Fury
		[26297]		= List(), -- Berserking
		[68992]		= List(), -- Darkflight
		[58984]		= List(), -- Shadowmeld
	-- Evoker
		[363916]	= List(), -- Obsidian Scales
		[374348]	= List(), -- Renewing Blaze
		[375087]	= List(), -- Dragonrage
		[370553]	= List(), -- Tip the Scales
		[358267]	= List(), -- Hover
		[357210]	= List(), -- Deep Breath
		[371807]	= List(), -- Recall
		[395296]	= List(), -- Ebon Might < self
		[395152]	= List(), -- Ebon Might < others
		[390386]	= List(), -- Fury of the Aspects
	-- Death Knight
		[48707]		= List(), -- Anti-Magic Shell
		[81256]		= List(), -- Dancing Rune Weapon
		[55233]		= List(), -- Vampiric Blood
		[193320]	= List(), -- Umbilicus Eternus
		[219809]	= List(), -- Tombstone
		[48792]		= List(), -- Icebound Fortitude
		[207319]	= List(), -- Corpse Shield
		[194844]	= List(), -- BoneStorm
		[145629]	= List(), -- Anti-Magic Zone
		[194679]	= List(), -- Rune Tap
		[51271]		= List(), -- Pillar of Frost
		[207256]	= List(), -- Obliteration
		[152279]	= List(), -- Breath of Sindragosa
		[233411]	= List(), -- Blood for Blood
		[212552]	= List(), -- Wraith Walk
		[343294]	= List(), -- Soul Reaper
		[194918]	= List(), -- Blighted Rune Weapon
		[48265]		= List(), -- Death's Advance
		[49039]		= List(), -- Lichborne
		[47568]		= List(), -- Empower Rune Weapon
	-- Demon Hunter
		[207811]	= List(), -- Nether Bond (DH)
		[207810]	= List(), -- Nether Bond (Target)
		[187827]	= List(), -- Metamorphosis
		[263648]	= List(), -- Soul Barrier
		[209426]	= List(), -- Darkness
		[196555]	= List(), -- Netherwalk
		[212800]	= List(), -- Blur
		[188499]	= List(), -- Blade Dance
		[203819]	= List(), -- Demon Spikes
		[206804]	= List(), -- Rain from Above
		[211510]	= List(), -- Solitude
		[162264]	= List(), -- Metamorphosis
		[205629]	= List(), -- Demonic Trample
		[188501]	= List(), -- Spectral Sight
		[196718]	= List(), -- Darkness
	-- Druid
		[102342]	= List(), -- Ironbark
		[61336]		= List(), -- Survival Instincts
		[210655]	= List(), -- Protection of Ashamane
		[22812]		= List(), -- Barkskin
		[200851]	= List(), -- Rage of the Sleeper
		[234081]	= List(), -- Celestial Guardian
		[202043]	= List(), -- Protector of the Pack 1
		[201940]	= List(), -- Protector of the Pack 2
		[201939]	= List(), -- Protector of the Pack 3
		[192081]	= List(), -- Ironfur
		[29166]		= List(), -- Innervate
		[208253]	= List(), -- Essence of G'Hanir
		[194223]	= List(), -- Celestial Alignment
		[102560]	= List(), -- Incarnation: Chosen of Elune
		[390414]	= List(), -- Orbital Strike (Incarnation: Chosen of Elune)
		[102543]	= List(), -- Incarnation: King of the Jungle
		[102558]	= List(), -- Incarnation: Guardian of Ursoc
		[117679]	= List(), -- Incarnation
		[106951]	= List(), -- Berserk (Feral)
		[50334]		= List(), -- Berserk (Guardian)
		[5217]		= List(), -- Tiger's Fury
		[1850]		= List(), -- Dash
		[137452]	= List(), -- Displacer Beast
		[102416]	= List(), -- Wild Charge
		[77764]		= List(), -- Stampeding Roar (Cat)
		[77761]		= List(), -- Stampeding Roar (Bear)
		[305497]	= List(), -- Thorns
		[234084]	= List(), -- Moon and Stars (PvP)
		[22842]		= List(), -- Frenzied Regeneration
	-- Hunter
		[186265]	= List(), -- Aspect of the Turtle
		[53480]		= List(), -- Roar of Sacrifice
		[202748]	= List(), -- Survival Tactics
		[62305]		= List(), -- Master's Call (it's this one or the other)
		[54216]		= List(), -- Master's Call
		[288613]	= List(), -- Trueshot
		[260402]	= List(), -- Double Tap
		[193530]	= List(), -- Aspect of the Wild
		[19574]		= List(), -- Bestial Wrath
		[186289]	= List(), -- Aspect of the Eagle
		[186257]	= List(), -- Aspect of the Cheetah
		[118922]	= List(), -- Posthaste
		[90355]		= List(), -- Ancient Hysteria (Pet)
		[160452]	= List(), -- Netherwinds (Pet)
		[266779]	= List(), -- Coordinated Assault
	-- Mage
		[414658]	= List(), -- Ice Cold
		[45438]		= List(), -- Ice Block
		[110960]	= List(), -- Greater Invisibility
		[198111]	= List(), -- Temporal Shield
		[198065]	= List(), -- Prismatic Cloak
		[11426]		= List(), -- Ice Barrier
		[235313]	= List(), -- Blazing Barrier
		[235450]	= List(), -- Prismatic Barrier
		[110909]	= List(), -- Alter Time
		[342246]	= List(), -- Alter Time
		[190319]	= List(), -- Combustion
		[80353]		= List(), -- Time Warp
		[12472]		= List(), -- Icy Veins
		[12042]		= List(), -- Arcane Power
		[116014]	= List(), -- Rune of Power
		[198144]	= List(), -- Ice Form
		[108839]	= List(), -- Ice Floes
		[205025]	= List(), -- Presence of Mind
		[198158]	= List(), -- Mass Invisibility
		[221404]	= List(), -- Burning Determination
		[324220]	= List(), -- Deathborne (Covenant/Necrolord)
	-- Monk
		[122783]	= List(), -- Diffuse Magic
		[122278]	= List(), -- Dampen Harm
		[125174]	= List(), -- Touch of Karma
		[201318]	= List(), -- Fortifying Elixir
		[202248]	= List(), -- Guided Meditation
		[120954]	= List(), -- Fortifying Brew
		[116849]	= List(), -- Life Cocoon
		[202162]	= List(), -- Guard
		[215479]	= List(), -- Ironskin Brew
		[137639]	= List(), -- Storm, Earth, and Fire
		[213664]	= List(), -- Nimble Brew
		[201447]	= List(), -- Ride the Wind
		[195381]	= List(), -- Healing Winds
		[116841]	= List(), -- Tiger's Lust
		[119085]	= List(), -- Chi Torpedo
		[199407]	= List(), -- Light on Your Feet
		[209584]	= List(), -- Zen Focus Tea
	-- Paladin
		[642]		= List(), -- Divine Shield
		[498]		= List(), -- Divine Protection
		[205191]	= List(), -- Eye for an Eye
		[184662]	= List(), -- Shield of Vengeance
		[1022]		= List(), -- Blessing of Protection
		[6940]		= List(), -- Blessing of Sacrifice
		[204018]	= List(), -- Blessing of Spellwarding
		[199507]	= List(), -- Spreading The Word: Protection
		[216857]	= List(), -- Guarded by the Light
		[228049]	= List(), -- Guardian of the Forgotten Queen
		[31850]		= List(), -- Ardent Defender
		[86659]		= List(), -- Guardian of Ancien Kings
		[212641]	= List(), -- Guardian of Ancien Kings (Glyph of the Queen)
		[209388]	= List(), -- Bulwark of Order
		[132403]	= List(), -- Shield of the Righteous
		[31884]		= List(), -- Avenging Wrath
		[105809]	= List(), -- Holy Avenger
		[231895]	= List(), -- Crusade
		[200652]	= List(), -- Tyr's Deliverance
		[216331]	= List(), -- Avenging Crusader
		[1044]		= List(), -- Blessing of Freedom
		[305395] 	= List(), -- Blessing of Freedom (Unbound Freedom - Ret/Prot PvP)
		[210256]	= List(), -- Blessing of Sanctuary
		[199545]	= List(), -- Steed of Glory
		[210294]	= List(), -- Divine Favor
		[221886]	= List(), -- Divine Steed
		[31821]		= List(), -- Aura Mastery
	-- Priest
		[81782]		= List(), -- Power Word: Barrier
		[47585]		= List(), -- Dispersion
		[19236]		= List(), -- Desperate Prayer
		[27827]		= List(), -- Spirit of Redemption
		[197268]	= List(), -- Ray of Hope
		[47788]		= List(), -- Guardian Spirit
		[33206]		= List(), -- Pain Suppression
		[200183]	= List(), -- Apotheosis
		[10060]		= List(), -- Power Infusion
		[47536]		= List(), -- Rapture
		[194249]	= List(), -- Voidform
		[197862]	= List(), -- Archangel
		[197871]	= List(), -- Dark Archangel
		[197874]	= List(), -- Dark Archangel
		[215769]	= List(), -- Spirit of Redemption
		[213610]	= List(), -- Holy Ward
		[121557]	= List(), -- Angelic Feather
		[65081]		= List(), -- Body and Soul
		[197767]	= List(), -- Speed of the Pious
		[210980]	= List(), -- Focus in the Light
		[221660]	= List(), -- Holy Concentration
		[15286]		= List(), -- Vampiric Embrace
		[62618]		= List(), -- Power Word: Barrier
	-- Rogue
		[315496]	= List(), -- Slice and Dice
		[5277]		= List(), -- Evasion
		[31224]		= List(), -- Cloak of Shadows
		[1966]		= List(), -- Feint
		[199754]	= List(), -- Riposte
		[45182]		= List(), -- Cheating Death
		[199027]	= List(), -- Veil of Midnight
		[121471]	= List(), -- Shadow Blades
		[13750]		= List(), -- Adrenaline Rush
		[51690]		= List(), -- Killing Spree
		[185422]	= List(), -- Shadow Dance
		[198368]	= List(), -- Take Your Cut
		[198027]	= List(), -- Turn the Tables
		[213985]	= List(), -- Thief's Bargain
		[197003]	= List(), -- Maneuverability
		[212198]	= List(), -- Crimson Vial
		[185311]	= List(), -- Crimson Vial
		[209754]	= List(), -- Boarding Party
		[36554]		= List(), -- Shadowstep
		[2983]		= List(), -- Sprint
		[202665]	= List(), -- Curse of the Dreadblades (Self Debuff)
	-- Shaman
		[114893]	= List(), -- Stone Bulwark
		[462844]	= List(), -- Stone Bulwark (additional)
		[325174]	= List(), -- Spirit Link
		[974]		= List(), -- Earth Shield
		[207654]	= List(), -- Servant of the Queen
		[108271]	= List(), -- Astral Shift
		[207498]	= List(), -- Ancestral Protection
		[209385]	= List(), -- Windfury Totem
		[208963]	= List(), -- Skyfury Totem
		[204945]	= List(), -- Doom Winds
		[205495]	= List(), -- Stormkeeper
		[208416]	= List(), -- Sense of Urgency
		[2825]		= List(), -- Bloodlust
		[16166]		= List(), -- Elemental Mastery
		[167204]	= List(), -- Feral Spirit
		[114050]	= List(), -- Ascendance (Elem)
		[114051]	= List(), -- Ascendance (Enh)
		[114052]	= List(), -- Ascendance (Resto)
		[79206]		= List(), -- Spiritwalker's Grace
		[58875]		= List(), -- Spirit Walk
		[157384]	= List(), -- Eye of the Storm
		[192082]	= List(), -- Wind Rush
		[2645]		= List(), -- Ghost Wolf
		[32182]		= List(), -- Heroism
		[108281]	= List(), -- Ancestral Guidance
		[20608]		= List(), -- Reincarnation
	-- Warlock
		[108416]	= List(), -- Dark Pact
		[113860]	= List(), -- Dark Soul: Misery
		[113858]	= List(), -- Dark Soul: Instability
		[104773]	= List(), -- Unending Resolve
		[221715]	= List(), -- Essence Drain
		[212295]	= List(), -- Nether Ward
		[212284]	= List(), -- Firestone
		[196098]	= List(), -- Soul Harvest
		[221705]	= List(), -- Casting Circle
		[111400]	= List(), -- Burning Rush
		[196674]	= List(), -- Planeswalker
	-- Warrior
		[118038]	= List(), -- Die by the Sword
		[184364]	= List(), -- Enraged Regeneration
		[209484]	= List(), -- Tactical Advance
		[97463]		= List(), -- Commanding Shout
		[213915]	= List(), -- Mass Spell Reflection
		[199038]	= List(), -- Leave No Man Behind
		[223658]	= List(), -- Safeguard
		[147833]	= List(), -- Intervene
		[198760]	= List(), -- Intercept
		[12975]		= List(), -- Last Stand
		[871]		= List(), -- Shield Wall
		[23920]		= List(), -- Spell Reflection
		[203524]	= List(), -- Neltharion's Fury
		[190456]	= List(), -- Ignore Pain
		[132404]	= List(), -- Shield Block
		[1719]		= List(), -- Battle Cry
		[107574]	= List(), -- Avatar
		[227847]	= List(), -- Bladestorm (Arm)
		[46924]		= List(), -- Bladestorm (Fury)
		[118000]	= List(), -- Dragon Roar
		[199261]	= List(), -- Death Wish
		[18499]		= List(), -- Berserker Rage
		[202164]	= List(), -- Bounding Stride
		[215572]	= List(), -- Frothing Berserker
		[199203]	= List(), -- Thirst for Battle
		[97462]		= List(), -- Rallying Cry
	},
}

-- Debuffs applied to players by bosses, adds or trash
G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	spells = {
	----------------------------------------------------------
	------------------------- General ------------------------
	----------------------------------------------------------
	-- Misc
		[160029] = List(), -- Resurrecting (Pending CR)
		[225080] = List(), -- Reincarnation (Ankh ready)
		[255234] = List(), -- Totemic Revival
	----------------------------------------------------------
	---------------- The War Within Dungeons -----------------
	----------------------------------------------------------
	-- The Stonevault
		[427329] = List(), -- Void Corruption
		[435813] = List(), -- Void Empowerment
		[423572] = List(), -- Void Empowerment
		[424889] = List(), -- Seismic Reverberation
		[424795] = List(), -- Refracting Beam
		[457465] = List(), -- Entropy
		[425974] = List(), -- Ground Pound
		[445207] = List(), -- Piercing Wail
		[428887] = List(), -- Smashed
		[427382] = List(), -- Concussive Smash
		[449154] = List(), -- Molten Mortar
		[427361] = List(), -- Fracture
		[443494] = List(), -- Crystalline Eruption
		[424913] = List(), -- Volatile Explosion
		[443954] = List(), -- Exhaust Vents
		[426308] = List(), -- Void Infection
		[429999] = List(), -- Flaming Scrap
		[429545] = List(), -- Censoring Gear
		[428819] = List(), -- Exhaust Vents
	-- City of Threads
		[434722] = List(), -- Subjugate
		[439341] = List(), -- Splice
		[440437] = List(), -- Shadow Shunpo
		[448561] = List(), -- Shadows of Doubt
		[440107] = List(), -- Knife Throw
		[439324] = List(), -- Umbral Weave
		[442285] = List(), -- Corrupted Coating
		[440238] = List(), -- Ice Sickles
		[461842] = List(), -- Oozing Smash
		[434926] = List(), -- Lingering Influence
		[440310] = List(), -- Chains of Oppression
		[439646] = List(), -- Process of Elimination
		[448562] = List(), -- Doubt
		[441391] = List(), -- Dark Paranoia
		[461989] = List(), -- Oozing Smash
		[441298] = List(), -- Freezing Blood
		[441286] = List(), -- Dark Paranoia
		[452151] = List(), -- Rigorous Jab
		[451239] = List(), -- Brutal Jab
		[443509] = List(), -- Ravenous Swarm
		[443437] = List(), -- Shadows of Doubt
		[451295] = List(), -- Void Rush
		[443427] = List(), -- Web Bolt
		[461630] = List(), -- Venomous Spray
		[445435] = List(), -- Black Blood
		[443401] = List(), -- Venom Strike
		[443430] = List(), -- Silk Binding
		[443438] = List(), -- Doubt
		[443435] = List(), -- Twist Thoughts
		[443432] = List(), -- Silk Binding
		[448047] = List(), -- Web Wrap
		[451426] = List(), -- Gossamer Barrage
		[446718] = List(), -- Umbral Weave
		[450055] = List(), -- Gutburst
		[450783] = List(), -- Perfume Toss
	-- The Dawnbreaker
		[463428] = List(), -- Lingering Erosion
		[426736] = List(), -- Shadow Shroud
		[434096] = List(), -- Sticky Webs
		[453173] = List(), -- Collapsing Night
		[426865] = List(), -- Dark Orb
		[434090] = List(), -- Spinneret's Strands
		[434579] = List(), -- Corrosion
		[426735] = List(), -- Burning Shadows
		[434576] = List(), -- Acidic Stupor
		[452127] = List(), -- Animate Shadows
		[438957] = List(), -- Acid Pools
		[434441] = List(), -- Rolling Acid
		[451119] = List(), -- Abyssal Blast
		[453345] = List(), -- Abyssal Rot
		[449332] = List(), -- Encroaching Shadows
		[431333] = List(), -- Tormenting Beam
		[431309] = List(), -- Ensnaring Shadows
		[451107] = List(), -- Bursting Cocoon
		[434406] = List(), -- Rolling Acid
		[431491] = List(), -- Tainted Slash
		[434113] = List(), -- Spinneret's Strands
		[431350] = List(), -- Tormenting Eruption
		[431365] = List(), -- Tormenting Ray
		[434668] = List(), -- Sparking Arathi Bomb
		[460135] = List(), -- Dark Scars
		[451098] = List(), -- Tacky Nova
		[450855] = List(), -- Dark Orb
		[431494] = List(), -- Black Edge
		[451115] = List(), -- Terrifying Slam
		[432448] = List(), -- Stygian Seed
	-- Ara-Kara, City of Echoes
		[461487] = List(), -- Cultivated Poisons
		[432227] = List(), -- Venom Volley
		[432119] = List(), -- Faded
		[433740] = List(), -- Infestation
		[439200] = List(), -- Voracious Bite
		[433781] = List(), -- Ceaseless Swarm
		[432132] = List(), -- Erupting Webs
		[434252] = List(), -- Massive Slam
		[432031] = List(), -- Grasping Blood
		[438599] = List(), -- Bleeding Jab
		[438618] = List(), -- Venomous Spit
		[436401] = List(), -- AUGH!
		[434830] = List(), -- Vile Webbing
		[436322] = List(), -- Poison Bolt
		[434083] = List(), -- Ambush
		[433843] = List(), -- Erupting Webs
	-- The Rookery
		[429493] = List(), -- Unstable Corruption
		[424739] = List(), -- Chaotic Corruption
		[433067] = List(), -- Seeping Corruption
		[426160] = List(), -- Dark Gravity
		[1214324] = List(), -- Crashing Thunder
		[424966] = List(), -- Lingering Void
		[467907] = List(), -- Festering Void
		[458082] = List(), -- Stormrider's Charge
		[472764] = List(), -- Void Extraction
		[427616] = List(), -- Energized Barrage
		[430814] = List(), -- Attracting Shadows
		[430179] = List(), -- Seeping Corruption
		[1214523] = List(), -- Feasting Void
	-- Priory of the Sacred Flame
		[424414] = List(), -- Pierce Armor
		[423015] = List(), -- Castigator's Shield
		[447439] = List(), -- Savage Mauling
		[425556] = List(), -- Sanctified Ground
		[428170] = List(), -- Blinding Light
		[448492] = List(), -- Thunderclap
		[427621] = List(), -- Impale
		[446403] = List(), -- Sacrificial Flame
		[451764] = List(), -- Radiant Flame
		[424426] = List(), -- Lunging Strike
		[448787] = List(), -- Purification
		[435165] = List(), -- Blazing Strike
		[448515] = List(), -- Divine Judgment
		[427635] = List(), -- Grievous Rip
		[427897] = List(), -- Heat Wave
		[424430] = List(), -- Consecration
		[453461] = List(), -- Caltrops
		[427900] = List(), -- Molten Pool
	-- Cinderbrew Meadery
		[441397] = List(), -- Bee Venom
		[431897] = List(), -- Rowdy Yell
		[442995] = List(), -- Swarming Surprise
		[437956] = List(), -- Erupting Inferno
		[441413] = List(), -- Shredding Sting
		[434773] = List(), -- Mean Mug
		[438975] = List(), -- Shredding Sting
		[463220] = List(), -- Volatile Keg
		[449090] = List(), -- Reckless Delivery
		[437721] = List(), -- Boiling Flames
		[441179] = List(), -- Oozing Honey
		[440087] = List(), -- Oozing Honey
		[434707] = List(), -- Cinderbrew Toss
		[445180] = List(), -- Crawling Brawl
		[442589] = List(), -- Beeswax
		[435789] = List(), -- Cindering Wounds
		[440134] = List(), -- Honey Marinade
		[432182] = List(), -- Throw Cinderbrew
		[436644] = List(), -- Burning Ricochet
		[436624] = List(), -- Cash Cannon
		[436640] = List(), -- Burning Ricochet
		[439325] = List(), -- Burning Fermentation
		[432196] = List(), -- Hot Honey
		[439586] = List(), -- Fluttering Wing
		[440141] = List(), -- Honey Marinade
	-- Darkflame Cleft
		[426943] = List(), -- Rising Gloom
		[427015] = List(), -- Shadowblast
		[420696] = List(), -- Throw Darkflame
		[422648] = List(), -- Darkflame Pickaxe
		[1218308] = List(), -- Enkindling Inferno
		[422245] = List(), -- Rock Buster
		[423693] = List(), -- Luring Candleflame
		[421638] = List(), -- Wicklighter Barrage
		[421817] = List(), -- Wicklighter Barrage
		[424223] = List(), -- Incite Flames
		[421146] = List(), -- Throw Darkflame
		[427180] = List(), -- Fear of the Gloom
		[424322] = List(), -- Explosive Flame
		[422807] = List(), -- Candlelight
		[420307] = List(), -- Candlelight
		[422806] = List(), -- Smothering Shadows
		[469620] = List(), -- Creeping Shadow
		[443694] = List(), -- Crude Weapons
		[425555] = List(), -- Crude Weapons
		[428019] = List(), -- Flashpoint
		[423501] = List(), -- Wild Wallop
		[426277] = List(), -- One-Hand Headlock
		[423654] = List(), -- Ouch!
		[421653] = List(), -- Cursed Wax
		[421067] = List(), -- Molten Wax
		[426883] = List(), -- Bonk!
		[440653] = List(), -- Surging Flamethrower
	-- Operation: Floodgate
		[462737] = List(), -- Black Blood Wound
		[1213803] = List(), -- Nailed
		[468672] = List(), -- Pinch
		[468616] = List(), -- Leaping Spark
		[469799] = List(), -- Overcharge
		[469811] = List(), -- Backwash
		[468680] = List(), -- Crabsplosion
		[473051] = List(), -- Rushing Tide
		[474351] = List(), -- Shreddation Sawblade
		[465830] = List(), -- Warp Blood
		[468723] = List(), -- Shock Water
		[474388] = List(), -- Flamethrower
		[472338] = List(), -- Surveyed Ground
		[462771] = List(), -- Surveying Beam
		[472819] = List(), -- Razorchoke Vines
		[473836] = List(), -- Electrocrush
		[468815] = List(), -- Gigazap
		[470022] = List(), -- Barreling Charge
		[470038] = List(), -- Razorchoke Vines
		[473713] = List(), -- Kinetic Explosive Gel
		[468811] = List(), -- Gigazap
		[466188] = List(), -- Thunder Punch
		[460965] = List(), -- Barreling Charge
		[472878] = List(), -- Sludge Claws
		[473224] = List(), -- Sonic Boom
	----------------------------------------------------------
	--------------- The War Within (Season 3) ----------------
	----------------------------------------------------------
	-- Eco-Dome Al'dani
		[1217439] = List(), -- Toxic Regurgitation
		[1227152] = List(), -- Warp Strike
		[1219535] = List(), -- Rift Claws
		[1220390] = List(), -- Warp Strike
		[1236126] = List(), -- Binding Javelin
		[1225221] = List(), -- Dread of the Unknown
		[1217446] = List(), -- Digestive Spittle
		[1220671] = List(), -- Binding Javelin
		[1231494] = List(), -- Overgorged Burst
		[1224865] = List(), -- Fatebound
		[1231224] = List(), -- Arcane Slash
		[1221190] = List(), -- Gluttonous Miasma
		[1221483] = List(), -- Arcing Energy
		[1222202] = List(), -- Arcane Burn
	-- Halls of Atonement
		[335338] = List(), -- Ritual of Woe
		[326891] = List(), -- Anguish
		[329321] = List(), -- Jagged Swipe 1
		[344993] = List(), -- Jagged Swipe 2
		[319603] = List(), -- Curse of Stone
		[319611] = List(), -- Turned to Stone
		[325876] = List(), -- Curse of Obliteration
		[326632] = List(), -- Stony Veins
		[323650] = List(), -- Haunting Fixation
		[326874] = List(), -- Ankle Bites
		[340446] = List(), -- Mark of Envy
	-- Tazavesh, the Veiled Market
		[356943] = List(), -- Lockdown
		[350804] = List(), -- Collapsing Energy
		[350885] = List(), -- Hyperlight Jolt
		[351101] = List(), -- Energy Fragmentation
		[346828] = List(), -- Sanitizing Field
		[355641] = List(), -- Scintillate
		[355451] = List(), -- Undertow
		[355581] = List(), -- Crackle
		[349999] = List(), -- Anima Detonation
		[346961] = List(), -- Purging Field
		[351956] = List(), -- High-Value Target
		[346297] = List(), -- Unstable Explosion
		[347728] = List(), -- Flock!
		[356408] = List(), -- Ground Stomp
		[347744] = List(), -- Quickblade
		[347481] = List(), -- Shuri
		[355915] = List(), -- Glyph of Restraint
		[350101] = List(), -- Chains of Damnation
		[350134] = List(), -- Infinite Breath
		[350013] = List(), -- Gluttonous Feast
		[355465] = List(), -- Boulder Throw
		[346116] = List(), -- Shearing Swings
		[356011] = List(), -- Beam Splicer
	---------------------------------------------------------
	------------------- Manaforge Omega ---------------------
	---------------------------------------------------------
	-- Plexus Sentinel
		[1219459] = List(), -- Manifest Matrices
		[1219607] = List(), -- Eradicating Salvo 1
		[1219531] = List(), -- Eradicating Salvo 2
		[1218625] = List(), -- Displacement Matrix
	-- Loom'ithar
		[1226311] = List(5), -- Infusion Tether
		[1237212] = List(4), -- Piercing Strand
		[1226721] = List(6), -- Silken Snare
		[1247045] = List(), -- Hyper Infusion
		[1237307] = List(), -- Lair Weaving
	-- Soulbinder Naazindhri
		[1227276] = List(), -- Soulfray Annihilation
		[1226827] = List(), -- Soulrend Orb
		[1227052] = List(), -- Void Burst
	-- Forgeweaver Araz
		[1234324] = List(), -- Photon Blast
		[1228214] = List(), -- Astral Harvest
		[1243901] = List(), -- Void Harvest
		[1240705] = List(6), -- Astral Burn
	-- The Soul Hunters
		[1227847] = List(), -- The Hunt
		[1241946] = List(), -- Frailty
	-- Fractillus
		[1233411] = List(), -- Crystalline Shockwave
	-- Nexus-King Salhadaar
		[1227549] = List(), -- Banishment
		[1226362] = List(), -- Twilight Scar
		[1228056] = List(), -- Reap
	-- Dimensius, the All-Devouring
		[1239270] = List(), -- Voidwarding
		[1250055] = List(), -- Voidgrasp
		[1243699] = List(), -- Spatial Fragment
		[1249425] = List(), -- Mass Destruction
	---------------------------------------------------------
	--------------- Liberation of Undermine -----------------
	---------------------------------------------------------
	-- Vexie and the Geargrinders
		[465865] = List(), -- Tank Buster
		[459669] = List(), -- Spew Oil
	-- Cauldron of Carnage
		[1213690] = List(), -- Molten Phlegm
		[1214009] = List(), -- Voltaic Image
	-- Rik Reverb
		[1217122] = List(), -- Lingering Voltage
		[468119] = List(), -- Resonant Echoes
		[467044] = List(), -- Faulty Zap
	-- Stix Bunkjunker
		[461536] = List(), -- Rolling Rubbish
		[1217954] = List(), -- Meltdown
		[465346] = List(), -- Sorted
		[466748] = List(), -- Infected Bite
	-- Sprocketmonger Lockenstock
		[1218342] = List(), -- Unstable Shrapnel
		[465917] = List(), -- Gravi-Gunk
		[471308] = List(), -- Blisterizer Mk. II
	-- The One-Armed Bandit
		[471927] = List(), -- Withering Flames
		[460420] = List(), -- Crushed!
	-- Mug'Zee, Heads of Security
		[466509] = List(), -- Stormfury Finger Gun
		[1215488] = List(), -- Disintegration Beam (Actually getting beamed)
		[469391] = List(6), -- Perforating Wound
	-- Chrome King Gallywix
		[466154] = List(4), -- Blast Burns
		[466834] = List(6), -- Shock Barrage
		[469362] = List(6), -- Charged Giga Bomb (Carrying)
	---------------------------------------------------------
	------------------- Nerub'ar Palace ---------------------
	---------------------------------------------------------
	-- Ulgrax the Devourer
		[434776] = List(), -- Carnivorous Contest
		[434705] = List(), -- Tenderized
		[439419] = List(), -- Stalker's Netting
		[439037] = List(), -- Disembowel
	-- The Bloodbound Horror
		[442656] = List(), -- Spewing Hemorrhage
		[442604] = List(), -- Goresplatter
		[443612] = List(), -- Gruesome Disgorge
	-- Sikran
		[435410] = List(), -- Phase Lunge
		[439191] = List(), -- Decimate
		[434860] = List(), -- Phase Blades
		[433517] = List(), -- Phase Blades 2
		[438845] = List(), -- Expose
	-- Rasha'nan
		[439787] = List(), -- Acidic Stupor
		[439815] = List(), -- Infested Spawn
		[439783] = List(), -- Spinneret's Strands
		[456170] = List(), -- Spinneret's Strands 2
		[439790] = List(), -- Rolling Acid
	-- Eggtender Ovi'nax
		[442250] = List(), -- Fixate
		[442257] = List(), -- Infest
		[446351] = List(), -- Web Eruption
		[446349] = List(), -- Sticky Web
		[440421] = List(), -- Experimental Dosage
		[441362] = List(), -- Volatile Concoction
	-- Nexus-Princess Ky'veza
		[436870] = List(), -- Assassination
		[437343] = List(), -- Queensbane
		[440576] = List(), -- Chasmal Gash
	-- The Silken Court
		[438749] = List(), -- Scarab Fixation
		[440001] = List(), -- Binding Webs
		[449857] = List(), -- Impaled
		[438218] = List(), -- Piercing Strike
	-- Queen Ansurek
		[441865] = List(), -- Royal Shackles
		[436800] = List(), -- Liquefy
		[455404] = List(), -- Feast
		[439829] = List(), -- Silken Tomb
		[439825] = List(), -- Silken Tomb 2
		[437586] = List(), -- Reactive Toxin
	},
}

-- Buffs applied by bosses, adds or trash
G.unitframe.aurafilters.RaidBuffsElvUI = {
	type = 'Whitelist',
	spells = {
	----------------------------------------------------------
	---------------- The War Within Dungeons -----------------
	----------------------------------------------------------
	-- The Stonevault
		[445541] = List(), -- Activate Ventilation
		[423228] = List(), -- Crumbling Shell 1
		[445409] = List(), -- Crumbling Shell 2
		[428519] = List(), -- Deconstruction 1
		[428520] = List(), -- Deconstruction 2
		[462372] = List(), -- Exhaust Vents 1
		[428820] = List(), -- Exhaust Vents 2
		[423766] = List(), -- Fracturing Blows
		[427300] = List(), -- Pillaging
		[428212] = List(), -- Scrap Song 1
		[428242] = List(), -- Scrap Song 2
		[423246] = List(), -- Shattered Shell
		[448640] = List(), -- Shield Stampede
		[439577] = List(), -- Silenced Speaker
		[428532] = List(), -- Unleash the Void
		[423327] = List(), -- Void Discharge 1
		[423324] = List(), -- Void Discharge 2
		[426771] = List(), -- Void Outburst
		[427315] = List(), -- Void Rift
	-- City of Threads
		[450047] = List(), -- Gorged
		[439518] = List(), -- Twin Fangs
		[434829] = List(), -- Vociferous Indoctrination
		[451222] = List(), -- Void Rush
		[452162] = List(), -- Mending Web
		[434691] = List(), -- Chains of Oppression
		[444428] = List(), -- Honored Citizen
		[436205] = List(), -- Fierce Stomping
		[445813] = List(), -- Dark Barrage
		[441395] = List(), -- Dark Pulse
		[446726] = List(), -- Shadow Shield
	-- The Dawnbreaker
		[431493] = List(), -- Darkblade
		[448888] = List(), -- Erosive Spray
		[426787] = List(), -- Shadowy Decay
		[451112] = List(), -- Tactician's Rage
		[432520] = List(), -- Umbral Barrier
		[449734] = List(), -- Acidic Eruption
		[450756] = List(), -- Abyssal Howl
		[427192] = List(), -- Empowered Might
		[452450] = List(), -- Rapid Summoning
		[431364] = List(), -- Tormenting Ray
		[453212] = List(), -- Obsidian Beam
		[461904] = List(), -- Cosmic Ascension
		[431349] = List(), -- Tormenting Eruption
		[453859] = List(), -- Darkness Comes
		[451102] = List(), -- Shadowy Decay
		[446615] = List(), -- Usher Reinforcements
		[452502] = List(), -- Dark Fervor
	-- Ara-Kara, City of Echoes
		[431985] = List(), -- Black Blood 1
		[433656] = List(), -- Black Blood 2
		[439333] = List(), -- Hunger
		[438675] = List(), -- Toxic Rupture 1
		[438622] = List(), -- Toxic Rupture 2
		[441645] = List(), -- Unnatural Bloodlust
		[434254] = List(), -- Intensity
		[438494] = List(), -- Alerting Shrill
		[434793] = List(), -- Resonant Barrage
	-- The Rookery
	-- Priory of the Sacred Flame
	-- Cinderbrew Meadery
	-- Darkflame Cleft
	-- Operation: Floodgate
	----------------------------------------------------------
	--------------- The War Within (Season 3) ----------------
	----------------------------------------------------------
	-- Eco-Dome Al'dani
		[1231234] = List(), -- Protected Core
		[1231608] = List(), -- Alacrity
		[1231244] = List(), -- Unstable Core
		[1217247] = List(), -- Feast
		[1248702] = List(), -- Spirit Protection
		[1221133] = List(), -- Hungering Rage
		[1236703] = List(), -- Eternal Weave
		[1221532] = List(), -- Erratic Ritual
		[1219457] = List(), -- Incorporeal
		[1217232] = List(), -- Devour
		[1220511] = List(), -- Arcane Overload
		[1223000] = List(), -- Embrace of K'aresh
		[1248701] = List(), -- Consume Spirit
	-- Halls of Atonement
		[326450] = List(), -- Loyal Beasts
	-- Tazavesh, the Veiled Market
		[355147] = List(), -- Fish Invigoration
		[351960] = List(), -- Static Cling
		[351088] = List(), -- Relic Link
		[346296] = List(), -- Instability
		[355057] = List(), -- Cry of Mrrggllrrgg
		[355640] = List(), -- Phalanx Field
		[355783] = List(), -- Force Multiplied
		[351086] = List(), -- Power Overwhelming
		[347840] = List(), -- Feral
		[355782] = List(), -- Force Multiplier
		[347992] = List(), -- Rotar Body Armor
	---------------------------------------------------------
	------------------- Manaforge Omega ---------------------
	---------------------------------------------------------
	-- Plexus Sentinel
		[1241303] = List(), -- Arcanoshield
	-- Loom'ithar
		[1238502] = List(), -- Woven Ward
	-- Soulbinder Naazindhri
		[1241100] = List(), -- Mystic Lash
		[1225616] = List(), -- Soulfire Convergence
	-- Forgeweaver Araz
	-- The Soul Hunters
	-- Fractillus
	-- Nexus-King Salhadaar
	-- Dimensius, the All-Devouring
	---------------------------------------------------------
	--------------- Liberation of Undermine -----------------
	---------------------------------------------------------
	-- Stix Bunkjunker
		[473115] = List(), -- Short Fuse
		[467117] = List(), -- Overdrive
	-- The One-Armed Bandit
		[472718] = List(), -- Up the Ante
	-- Mug'Zee, Heads of Security
		[466385] = List(), -- Moxie
	---------------------------------------------------------
	------------------- Nerub'ar Palace ---------------------
	---------------------------------------------------------
	-- Ulgrax the Devourer
		[440177] = List(), -- Ready to Feed
	-- The Bloodbound Horror
		[454848] = List(), -- Spewing Hemorrhage 1
		[442635] = List(), -- Spewing Hemorrhage 2
		[445272] = List(), -- Blood Pact
		[451305] = List(), -- Black Bulwark 1
		[451288] = List(), -- Black Bulwark 2
		[443203] = List(), -- Crimson Rain
	-- Sikran
		[458272] = List(), -- Cosmic Simulacrum
	-- Rasha'nan
		[439811] = List(), -- Erosive Spray
		[451575] = List(), -- Wounded in Battle
	-- Eggtender Ovi'nax
		[458207] = List(), -- Mutation: Accelerated 1
		[442263] = List(), -- Mutation: Accelerated 2
		[442432] = List(), -- Ingest Black Blood
		[438807] = List(), -- Vicious Bite
		[443273] = List(), -- Transfusion
	-- Nexus-Princess Ky'veza
		[436757] = List(), -- Reaper
		[435405] = List(), -- Starless Night
		[436971] = List(), -- Assassination
		[436950] = List(), -- Stalking Shadows
		[438153] = List(), -- Twilight Massacre
		[436606] = List(), -- Regicide
		[440407] = List(), -- Void Shredders
	-- The Silken Court
		[443598] = List(), -- Uncontrollable Rage
		[451176] = List(), -- Entropic Backlash
		[451334] = List(), -- Strained Exertion
		[450980] = List(), -- Shatter Existence
		[451277] = List(), -- Spike Storm
		[442994] = List(), -- Unleashed Swarm
		[438343] = List(), -- Venomous Rain
		[440179] = List(), -- Entangled
	-- Queen Ansurek
		[448488] = List(), -- Worshipper's Protection
		[448505] = List(), -- Worshipper's Protection 2
		[445013] = List(), -- Dark Barrier
	},
}

-- Aura indicators on UnitFrames (Hots, Shields, Externals)
G.unitframe.aurawatch = {
	GLOBAL = {},
	EVOKER = {
		-- All specs
		[406732]	= Aura(406732, nil, 'RIGHT', {0.82, 0.29, 0.24}), -- Spatial Paradox < on yourself
		[406789]	= Aura(406789, nil, 'RIGHT', {0.82, 0.29, 0.24}), -- Spatial Paradox < on the partner
		-- Preservation
		[355941]	= Aura(355941, nil, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Dream Breath
		[376788]	= Aura(376788, nil, 'TOPRIGHT', {0.25, 0.25, 0.58}, nil, nil, nil, nil, -20), -- Dream Breath (echo)
		[363502]	= Aura(363502, nil, 'BOTTOMLEFT', {0.33, 0.33, 0.70}), -- Dream Flight
		[366155]	= Aura(366155, nil, 'BOTTOMRIGHT', {0.14, 1.00, 0.88}), -- Reversion
		[367364]	= Aura(367364, nil, 'BOTTOMRIGHT', {0.09, 0.69, 0.61}, nil, nil, nil, nil, -20), -- Reversion (echo)
		[373267]	= Aura(373267, nil, 'RIGHT', {0.82, 0.29, 0.24}), -- Life Bind (Verdant Embrace)
		[364343]	= Aura(364343, nil, 'TOP', {0.13, 0.87, 0.50}), -- Echo
		[357170]	= Aura(357170, nil, 'BOTTOM', {0.11, 0.57, 0.71}), -- Time Dilation
		-- Augmentation
		[360827]	= Aura(360827, nil, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Blistering Scales
		[410089]	= Aura(410089, nil, 'TOP', {0.13, 0.87, 0.50}), -- Prescience
		[395152]	= Aura(395152, nil, 'BOTTOMRIGHT', {0.98, 0.44, 0.00}), -- Ebon Might
		[361022]	= Aura(361022, nil, 'LEFT', {0.11, 0.57, 0.70}), -- Sense Power (API spell table still incomplete)
	},
	ROGUE = {
		[57934]		= Aura(57934, nil, 'TOPRIGHT', {0.89, 0.09, 0.05}), -- Tricks of the Trade
	},
	WARRIOR = {
		[3411]		= Aura(3411, nil, 'TOPRIGHT', {0.89, 0.09, 0.05}), -- Intervene
	},
	PRIEST = {
		[194384]	= Aura(194384, nil, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement
		[17]		= Aura(17, nil, 'TOPLEFT', {0.7, 0.7, 0.7}, true), -- Power Word: Shield
		[41635]		= Aura(41635, nil, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}), -- Prayer of Mending
		[193065]	= Aura(193065, nil, 'BOTTOMRIGHT', {0.54, 0.21, 0.78}, nil, nil, nil, nil, -20), -- Masochism
		[139]		= Aura(139, nil, 'BOTTOMLEFT', {0.4, 0.7, 0.2}), -- Renew
		[6788]		= Aura(6788, nil, 'BOTTOMLEFT', {0.89, 0.1, 0.1}, nil, nil, nil, nil, 20), -- Weakened Soul
		[10060]		= Aura(10060, nil, 'RIGHT', {1, 0.81, 0.11}, true), -- Power Infusion
		[77489]		= Aura(77489, nil, 'TOP', {0.75, 1.00, 0.30}), -- Echo of Light
		[33206]		= Aura(33206, nil, 'BOTTOM', {0.47, 0.35, 0.74}, true), -- Pain Suppression
		[47788]		= Aura(47788, nil, 'BOTTOM', {0.86, 0.45, 0}, true, nil, nil, nil, -20), -- Guardian Spirit
	},
	DRUID = {
		[774]		= Aura(774, nil, 'TOPRIGHT', {0.8, 0.4, 0.8}), -- Rejuvenation
		[33763]		= Aura(33763, nil, 'TOPLEFT', {0.4, 0.8, 0.2}), -- Lifebloom
		[188550]	= Aura(188550, nil, 'TOPLEFT', {0.4, 0.8, 0.2}), -- Lifebloom (Shadowlands Legendary)
		[48438]		= Aura(48438, nil, 'BOTTOMRIGHT', {0.8, 0.4, 0}), -- Wild Growth
		[8936]		= Aura(8936, nil, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Regrowth
		[155777]	= Aura(155777, nil, 'RIGHT', {0.8, 0.4, 0.8}), -- Germination
		[102351]	= Aura(102351, nil, 'LEFT', {0.2, 0.8, 0.8}), -- Cenarion Ward (Initial Buff)
		[102352]	= Aura(102352, nil, 'LEFT', {0.2, 0.8, 0.8}), -- Cenarion Ward (HoT)
		[207386]	= Aura(207386, nil, 'TOP', {0.4, 0.2, 0.8}), -- Spring Blossoms
		[203554]	= Aura(203554, nil, 'TOP', {1, 1, 0.4}, nil, nil, nil, nil, -20), -- Focused Growth (PvP)
		[200389]	= Aura(200389, nil, 'BOTTOM', {1, 1, 0.4}, nil, nil, nil, nil, -20), -- Cultivation
		[391891]	= Aura(391891, nil, 'BOTTOM', {0.01, 0.75, 0.60}, nil, nil, nil, nil, -20), -- Adaptive Swarm
		[157982]	= Aura(157982, nil, 'BOTTOM', {0.75, 0.75, 0.75}), -- Tranquility
	},
	PALADIN = {
		[53563]		= Aura(53563, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Light
		[156910]	= Aura(156910, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Faith
		[200025]	= Aura(200025, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Virtue
		[431381]	= Aura(431381, nil, 'LEFT', {0.2, 0.8, 0.2}), -- Dawnlight
		[156322]	= Aura(156322, nil, 'TOPLEFT', {0.2, 0.8, 0.2}), -- Eternal Flame
		[1022]		= Aura(1022, nil, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), -- Blessing of Protection
		[1044]		= Aura(1044, nil, 'BOTTOMRIGHT', {0.89, 0.45, 0}, true), -- Blessing of Freedom
		[6940]		= Aura(6940, nil, 'BOTTOMRIGHT', {0.89, 0.1, 0.1}, true), -- Blessing of Sacrifice
		[204018]	= Aura(204018, nil, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), -- Blessing of Spellwarding
		[157047]	= Aura(157047, nil, 'TOP', {0.15, 0.58, 0.84}), -- Saved by the Light (T25 Talent)
		[148039]	= Aura(148039, nil, 'BOTTOM', {0.98, 0.50, 0.11}), -- Barrier of Faith (accumulation)
		[395180]	= Aura(395180, nil, 'BOTTOM', {0.93, 0.80, 0.36}), -- Barrier of Faith (absorbtion)
	},
	SHAMAN = {
		[61295]		= Aura(61295, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Riptide
		[974]		= Aura(974, nil, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield
		[383648]	= Aura(383648, nil, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield (Elemental Orbit)
	},
	HUNTER = {
		[90361]		= Aura(90361, nil, 'TOP', {0.34, 0.47, 0.31}), -- Spirit Mend (HoT)
	},
	MONK = {
		[115175]	= Aura(115175, nil, 'TOP', {0.6, 0.9, 0.9}), -- Soothing Mist
		[116841]	= Aura(116841, nil, 'RIGHT', {0.12, 1.00, 0.53}), -- Tiger's Lust (Freedom)
		[116849]	= Aura(116849, nil, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Life Cocoon
		[119611]	= Aura(119611, nil, 'TOPLEFT', {0.3, 0.8, 0.6}), -- Renewing Mist
		[124682]	= Aura(124682, nil, 'BOTTOMLEFT', {0.8, 0.8, 0.25}), -- Enveloping Mist
		[325209]	= Aura(325209, nil, 'BOTTOM', {0.3, 0.6, 0.6}), -- Enveloping Breath
	},
	PET = {
		-- Warlock Pets
		[193396]	= Aura(193396, nil, 'TOPRIGHT', {0.6, 0.2, 0.8}, true), -- Demonic Empowerment
		-- Hunter Pets
		[272790]	= Aura(272790, nil, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Frenzy
		[136]		= Aura(136, nil, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Mend Pet
	},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Racials
	[291944]	= 6, -- Regeneratin (Zandalari)
	-- Evoker
	[356995]	= 3, -- Disintegrate
	-- Warlock
	[198590]	= 4, -- Drain Soul
	[755]		= 5, -- Health Funnel
	[234153]	= 5, -- Drain Life
	-- Priest
	[64843]		= 4, -- Divine Hymn
	[15407]		= 6, -- Mind Flay
	[48045]		= 6, -- Mind Sear
	[47757]		= 3, -- Penance (heal)
	[47758]		= 3, -- Penance (dps)
	[373129]	= 3, -- Penance (Dark Reprimand, dps)
	[400171]	= 3, -- Penance (Dark Reprimand, heal)
	[64902]		= 5, -- Symbol of Hope (Mana Hymn)
	-- Mage
	[5143]		= 4, -- Arcane Missiles
	[12051]		= 6, -- Evocation
	[205021]	= 5, -- Ray of Frost
	-- Druid
	[740]		= 4, -- Tranquility
	-- DK
	[206931]	= 3, -- Blooddrinker
	-- DH
	[198013]	= 10, -- Eye Beam
	[212084]	= 10, -- Fel Devastation
	-- Hunter
	[120360]	= 15, -- Barrage
	[257044]	= 7, -- Rapid Fire
	-- Monk
	[113656]	= 4, -- Fists of Fury
}

-- Spells that chain, ticks to add
G.unitframe.ChainChannelTicks = {
	-- Evoker
	[356995]	= 1, -- Disintegrate
}

-- Window to chain time (in seconds); usually the channel duration
G.unitframe.ChainChannelTime = {
	-- Evoker
	[356995]	= 3, -- Disintegrate
}

-- Spells Effected By Talents
G.unitframe.TalentChannelTicks = {
	[356995]	= { [1219723] = 4 }, -- Disintegrate (Azure Celerity)
}

-- Increase ticks from auras
G.unitframe.AuraChannelTicks = {
	-- Priest
	[47757]		= { filter = 'HELPFUL', spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (heal)
	[47758]		= { filter = 'HELPFUL', spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (dps)
}

-- Spells Effected By Haste, value is Base Tick Size
G.unitframe.HastedChannelTicks = {
	-- [spellID] = 1, -- SpellName
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825]		= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- [Shaman] Bloodlust
	[32182]		= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- [Shaman] Heroism
	[80353]		= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- [Mage] Time Warp
	[90355]		= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- [Hunter] Ancient Hysteria
	[390386]	= { enable = true, color = {r = 0.99, g = 0.82, b = 0.24 }}, -- [Evoker] Fury of the Aspects
	[395296]	= { enable = true, color = {r = 0.98, g = 0.44, b = 0.00 }}, -- [Evoker] Ebon Might < self
	[395152]	= { enable = true, color = {r = 0.98, g = 0.44, b = 0.00 }}, -- [Evoker] Ebon Might < others
}

-- Auras which should change the color of the UnitFrame
G.unitframe.AuraHighlightColors = {}
