local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Evoker
		[355689]	= List(2), -- Landslide
		[370898]	= List(1), -- Permeating Chill
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
	-- Paladin
		[853]		= List(3), -- Hammer of Justice
		[20066]		= List(3), -- Repentance
		[105421]	= List(3), -- Blinding Light
		[31935]		= List(2), -- Avenger's Shield
		[217824]	= List(2), -- Shield of Virtue
		[205290]	= List(3), -- Wake of Ashes
	-- Priest
		[9484]		= List(3), -- Shackle Undead
		[200196]	= List(4), -- Holy Word: Chastise
		[200200]	= List(4), -- Holy Word: Chastise
		[226943]	= List(3), -- Mind Bomb
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
	-- Warrior
		[5246]		= List(4), -- Intimidating Shout
		[132169]	= List(4), -- Storm Bolt
		[132168]	= List(4), -- Shockwave
		[199085]	= List(4), -- Warpath
		[105771]	= List(1), -- Charge
		[199042]	= List(1), -- Thunderstruck
		[236077]	= List(2), -- Disarm
	-- Racial
		[20549]		= List(4), -- War Stomp
		[107079]	= List(4), -- Quaking Palm
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
	-- Mage
		[45438]		= List(), -- Ice Block
		[110960]	= List(), -- Greater Invisibility
		[198111]	= List(), -- Temporal Shield
		[198065]	= List(), -- Prismatic Cloak
		[11426]		= List(), -- Ice Barrier
		[235313]	= List(), -- Blazing Barrier
		[235450]	= List(), -- Prismatic Barrier
		[110909]	= List(), -- Alter Time
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
		[152262]	= List(), -- Seraphim
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
		[325174]	= List(), -- Spirit Link
		[974]		= List(), -- Earth Shield
		[210918]	= List(), -- Ethereal Form
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
		[227744]	= List(), -- Ravager
		[203524]	= List(), -- Neltharion's Fury
		[190456]	= List(), -- Ignore Pain
		[132404]	= List(), -- Shield Block
	-- Racial
		[65116]		= List(), -- Stoneform
	-- Potion
		[251231]	= List(), -- Steelskin Potion
	-- Covenant
		[324867]	= List(), -- Fleshcraft (Necrolord)
	-- PvP
		[363522]	= List(), -- Gladiator's Eternal Aegis
		[362699]	= List(), -- Gladiator's Resolve
	},
}

G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	-- Evoker
		[363916]	= List(), -- Obsidian Scales
		[374348]	= List(), -- Renewing Blaze
		[375087]	= List(), -- Dragonrage
		[370553]	= List(), -- Tip the Scales
		[358267]	= List(), -- Hover
		[357210]	= List(), -- Deep Breath
		[371807]	= List(), -- Recall
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
		[45438]		= List(), -- Ice Block
		[110960]	= List(), -- Greater Invisibility
		[198111]	= List(), -- Temporal Shield
		[198065]	= List(), -- Prismatic Cloak
		[11426]		= List(), -- Ice Barrier
		[235313]	= List(), -- Blazing Barrier
		[235450]	= List(), -- Prismatic Barrier
		[110909]	= List(), -- Alter Time
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
		[152173]	= List(), -- Serenity
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
		[152262]	= List(), -- Seraphim
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
		[325174]	= List(), -- Spirit Link
		[974]		= List(), -- Earth Shield
		[210918]	= List(), -- Ethereal Form
		[207654]	= List(), -- Servant of the Queen
		[108271]	= List(), -- Astral Shift
		[207498]	= List(), -- Ancestral Protection
		[204366]	= List(), -- Thundercharge
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
		[227744]	= List(), -- Ravager
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
	-- Racials
		[256948]	= List(), -- Spatial Rift
		[65116]		= List(), -- Stoneform
		[59547]		= List(), -- Gift of the Naaru
		[20572]		= List(), -- Blood Fury
		[26297]		= List(), -- Berserking
		[68992]		= List(), -- Darkflight
		[58984]		= List(), -- Shadowmeld
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
		[287825]	= List(), -- Lethargy debuff (fight or flight)
		[306600]	= List(), -- Experience Eliminated (oor - 5m)
		[313015]	= List(), -- Recently Failed (Mechagnome racial)
		[322695]	= List(), -- Drained
		[328891]	= List(), -- A Gilded Perspective
		[348443]	= List(), -- Experience Eliminated
		[234143]	= List(), -- Temptation (Upper Karazhan Ring Debuff)
		[392960]	= List(), -- Waygate Travel
		[390106]	= List(), -- Riding Along
		[383600]	= List(), -- Surrounding Storm (Strunraan)
		[392992]	= List(), -- Silent Lava
		[393798]	= List(), -- Activated Defense Systems
		[374037]	= List(), -- Overwhelming Rage
	},
}

-- A list of important buffs that we always want to see
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
	-- Haste effects
		[2825]		= List(), -- [Shaman] Bloodlust
		[32182]		= List(), -- [Shaman] Heroism
		[80353]		= List(), -- [Mage] Time Warp
		[90355]		= List(), -- [Hunter] Ancient Hysteria
		[390386]	= List(), -- [Evoker] Fury of the Aspects
	-- Paladin
		[31821]		= List(), -- Aura Mastery
		[1022]		= List(), -- Blessing of Protection
		[204018]	= List(), -- Blessing of Spellwarding
		[6940]		= List(), -- Blessing of Sacrifice
		[1044]		= List(), -- Blessing of Freedom
	-- Priest
		[47788]		= List(), -- Guardian Spirit
		[33206]		= List(), -- Pain Suppression
		[62618]		= List(), -- Power Word: Barrier
	-- Monk
		[116849]	= List(), -- Life Cocoon
	-- Druid
		[102342]	= List(), -- Ironbark
	-- Shaman
		[325174]	= List(), -- Spirit Link
		[20608]		= List(), -- Reincarnation
	-- Other
		[97462]		= List(), -- Rallying Cry
		[196718]	= List(), -- Darkness
	},
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	spells = {
	----------------------------------------------------------
	-------------------- Mythic+ Specific --------------------
	----------------------------------------------------------
	-- General Affixes
		[226512] = List(), -- Sanguine
		[240559] = List(), -- Grievous
		[240443] = List(), -- Bursting
	----------------------------------------------------------
	----------------- Dragonflight Dungeons ------------------
	----------------------------------------------------------
	-- Brackenhide Hollow
		[385361] = List(), -- Rotting Sickness
		[378020] = List(), -- Gash Frenzy
		[385356] = List(), -- Ensnaring Trap
		[373917] = List(), -- Decaystrike 1
		[377864] = List(), -- Infectious Spit
		[376933] = List(), -- Grasping Vines
		[384425] = List(), -- Smell Like Meat
		[373912] = List(), -- Decaystrike 2
		[373896] = List(), -- Withering Rot
		[377844] = List(), -- Bladestorm 1
		[378229] = List(), -- Marked for Butchery
		[381835] = List(), -- Bladestorm 2
		[376149] = List(), -- Choking Rotcloud
		[384725] = List(), -- Feeding Frenzy
		[385303] = List(), -- Teeth Trap
		[368299] = List(), -- Toxic Trap
		[384970] = List(), -- Scented Meat 1
		[384974] = List(), -- Scented Meat 2
		[368091] = List(), -- Infected Bite
		[385185] = List(), -- Disoriented
		[387210] = List(), -- Decaying Strength
		[382808] = List(), -- Withering Contagion 1
		[383087] = List(), -- Withering Contagion 2
		[382723] = List(), -- Crushing Smash
		[382787] = List(), -- Decay Claws
		[385058] = List(), -- Withering Poison
		[383399] = List(), -- Rotting Surge
		[367484] = List(), -- Vicious Clawmangle
		[367521] = List(), -- Bone Bolt
		[368081] = List(), -- Withering
		[374245] = List(), -- Rotting Creek
		[367481] = List(), -- Bloody Bite
	-- Halls of Infusion
		[387571] = List(), -- Focused Deluge
		[383935] = List(), -- Spark Volley
		[385555] = List(), -- Gulp
		[384524] = List(), -- Titanic Fist
		[385963] = List(), -- Frost Shock
		[374389] = List(), -- Gulp Swog Toxin
		[386743] = List(), -- Polar Winds
		[389179] = List(), -- Power Overload
		[389181] = List(), -- Power Field
		[257274] = List(), -- Vile Coating
		[375384] = List(), -- Rumbling Earth
		[374563] = List(), -- Dazzle
		[389446] = List(), -- Nullifying Pulse
		[374615] = List(), -- Cheap Shot
		[391610] = List(), -- Blinding Winds
		[374724] = List(), -- Molten Subduction
		[385168] = List(), -- Thunderstorm
		[387359] = List(), -- Waterlogged
		[391613] = List(), -- Creeping Mold
		[374706] = List(), -- Pyretic Burst
		[389443] = List(), -- Purifying Blast
		[374339] = List(), -- Demoralizing Shout
		[374020] = List(), -- Containment Beam
		[391634] = List(), -- Deep Chill
		[393444] = List(), -- Gushing Wound
	-- Neltharus
		[374534] = List(), -- Heated Swings
		[373735] = List(), -- Dragon Strike
		[377018] = List(), -- Molten Gold
		[374842] = List(), -- Blazing Aegis 1
		[392666] = List(), -- Blazing Aegis 2
		[375890] = List(), -- Magma Eruption
		[396332] = List(), -- Fiery Focus
		[389059] = List(), -- Slag Eruption
		[376784] = List(), -- Flame Vulnerability
		[377542] = List(), -- Burning Ground
		[374451] = List(), -- Burning Chain
		[372461] = List(), -- Imbued Magma
		[378818] = List(), -- Magma Conflagration
		[377522] = List(), -- Burning Pursuit
		[375204] = List(), -- Liquid Hot Magma
		[374482] = List(), -- Grounding Chain
		[372971] = List(), -- Reverberating Slam
		[384161] = List(), -- Mote of Combustion
		[374854] = List(), -- Erupted Ground
		[373089] = List(), -- Scorching Fusillade
		[372224] = List(), -- Dragonbone Axe
		[372570] = List(), -- Bold Ambush
		[372459] = List(), -- Burning
		[372208] = List(), -- Djaradin Lava
		[414585] = List(), -- Fiery Demise
	-- Uldaman: Legacy of Tyr
		[368996] = List(), -- Purging Flames
		[369792] = List(), -- Skullcracker
		[372718] = List(), -- Earthen Shards
		[382071] = List(), -- Resonating Orb
		[377405] = List(), -- Time Sink
		[369006] = List(), -- Burning Heat
		[369110] = List(), -- Unstable Embers
		[375286] = List(), -- Searing Cannonfire
		[372652] = List(), -- Resonating Orb
		[377825] = List(), -- Burning Pitch
		[369411] = List(), -- Sonic Burst
		[382576] = List(), -- Scorn of Tyr
		[369366] = List(), -- Trapped in Stone
		[369365] = List(), -- Curse of Stone
		[369419] = List(), -- Venomous Fangs
		[377486] = List(), -- Time Blade
		[369818] = List(), -- Diseased Bite
		[377732] = List(), -- Jagged Bite
		[369828] = List(), -- Chomp
		[369811] = List(), -- Brutal Slam
		[376325] = List(), -- Eternity Zone
		[369337] = List(), -- Difficult Terrain
		[376333] = List(), -- Temporal Zone
		[377510] = List(), -- Stolen Time
	-- Ruby Life Pools
		[392406] = List(), -- Thunderclap
		[372820] = List(), -- Scorched Earth
		[384823] = List(), -- Inferno 1
		[373692] = List(), -- Inferno 2
		[381862] = List(), -- Infernocore
		[372860] = List(), -- Searing Wounds
		[373869] = List(), -- Burning Touch
		[385536] = List(), -- Flame Dance
		[381518] = List(), -- Winds of Change
		[372858] = List(), -- Searing Blows
		[372682] = List(), -- Primal Chill 1
		[373589] = List(), -- Primal Chill 2
		[373693] = List(), -- Living Bomb
		[392924] = List(), -- Shock Blast
		[381515] = List(), -- Stormslam
		[396411] = List(), -- Primal Overload
		[384773] = List(), -- Flaming Embers
		[392451] = List(), -- Flashfire
		[372697] = List(), -- Jagged Earth
		[372047] = List(), -- Flurry
		[372963] = List(), -- Chillstorm
	-- The Nokhud Offensive
		[382628] = List(), -- Surge of Power
		[386025] = List(), -- Tempest
		[381692] = List(), -- Swift Stab
		[387615] = List(), -- Grasp of the Dead
		[387629] = List(), -- Rotting Wind
		[386912] = List(), -- Stormsurge Cloud
		[395669] = List(), -- Aftershock
		[384134] = List(), -- Pierce
		[388451] = List(), -- Stormcaller's Fury 1
		[388446] = List(), -- Stormcaller's Fury 2
		[395035] = List(), -- Shatter Soul
		[376899] = List(), -- Crackling Cloud
		[384492] = List(), -- Hunter's Mark
		[376730] = List(), -- Stormwinds
		[376894] = List(), -- Crackling Upheaval
		[388801] = List(), -- Mortal Strike
		[376827] = List(), -- Conductive Strike
		[376864] = List(), -- Static Spear
		[375937] = List(), -- Rending Strike
		[376634] = List(), -- Iron Spear
	-- The Azure Vault
		[388777] = List(), -- Oppressive Miasma
		[386881] = List(), -- Frost Bomb
		[387150] = List(), -- Frozen Ground
		[387564] = List(), -- Mystic Vapors
		[385267] = List(), -- Crackling Vortex
		[386640] = List(), -- Tear Flesh
		[374567] = List(), -- Explosive Brand
		[374523] = List(), -- Arcane Roots
		[375596] = List(), -- Erratic Growth Channel
		[375602] = List(), -- Erratic Growth
		[370764] = List(), -- Piercing Shards
		[384978] = List(), -- Dragon Strike
		[375649] = List(), -- Infused Ground
		[387151] = List(), -- Icy Devastator
		[377488] = List(), -- Icy Bindings
		[374789] = List(), -- Infused Strike
		[371007] = List(), -- Splintering Shards
		[375591] = List(), -- Sappy Burst
		[385409] = List(), -- Ouch, ouch, ouch!
		[386549] = List(), -- Waking Bane
	-- Algeth'ar Academy
		[389033] = List(), -- Lasher Toxin
		[391977] = List(), -- Oversurge
		[386201] = List(), -- Corrupted Mana
		[389011] = List(), -- Overwhelming Power
		[387932] = List(), -- Astral Whirlwind
		[396716] = List(), -- Splinterbark
		[388866] = List(), -- Mana Void
		[386181] = List(), -- Mana Bomb
		[388912] = List(), -- Severing Slash
		[377344] = List(), -- Peck
		[376997] = List(), -- Savage Peck
		[388984] = List(), -- Vicious Ambush
		[388544] = List(), -- Barkbreaker
		[377008] = List(), -- Deafening Screech
	----------------------------------------------------------
	---------------- Dragonflight (Season 2) -----------------
	----------------------------------------------------------
	-- Freehold
		[258323] = List(), -- Infected Wound
		[257775] = List(), -- Plague Step
		[257908] = List(), -- Oiled Blade
		[257436] = List(), -- Poisoning Strike
		[274389] = List(), -- Rat Traps
		[274555] = List(), -- Scabrous Bites
		[258875] = List(), -- Blackout Barrel
		[256363] = List(), -- Ripper Punch
		[258352] = List(), -- Grapeshot
		[413136] = List(), -- Whirling Dagger 1
		[413131] = List(), -- Whirling Dagger 2
	-- Neltharion's Lair
		[199705] = List(), -- Devouring
		[199178] = List(), -- Spiked Tongue
		[210166] = List(), -- Toxic Retch 1
		[217851] = List(), -- Toxic Retch 2
		[193941] = List(), -- Impaling Shard
		[183465] = List(), -- Viscid Bile
		[226296] = List(), -- Piercing Shards
		[226388] = List(), -- Rancid Ooze
		[200154] = List(), -- Burning Hatred
		[183407] = List(), -- Acid Splatter
		[215898] = List(), -- Crystalline Ground
		[188494] = List(), -- Rancid Maw
		[192800] = List(), -- Choking Dust
	-- Underrot
		[265468] = List(), -- Withering Curse
		[278961] = List(), -- Decaying Mind
		[259714] = List(), -- Decaying Spores
		[272180] = List(), -- Death Bolt
		[272609] = List(), -- Maddening Gaze
		[269301] = List(), -- Putrid Blood
		[265533] = List(), -- Blood Maw
		[265019] = List(), -- Savage Cleave
		[265377] = List(), -- Hooked Snare
		[265625] = List(), -- Dark Omen
		[260685] = List(), -- Taint of G'huun
		[266107] = List(), -- Thirst for Blood
		[260455] = List(), -- Serrated Fangs
	-- Vortex Pinnacle
		[87618] = List(), -- Static Cling
		[410870] = List(), -- Cyclone
		[86292] = List(), -- Cyclone Shield
		[88282] = List(), -- Upwind of Altairus
		[88286] = List(), -- Downwind of Altairus
		[410997] = List(), -- Rushing Wind
		[411003] = List(), -- Turbulence
		[87771] = List(), -- Crusader Strike
		[87759] = List(), -- Shockwave
		[88314] = List(), -- Twisting Winds
		[76622] = List(), -- Sunder Armor
		[88171] = List(), -- Hurricane
		[88182] = List(), -- Lethargic Poison
	---------------------------------------------------------
	------------ Aberrus, the Shadowed Crucible -------------
	---------------------------------------------------------
	-- Kazzara
		[406530] = List(), -- Riftburn
		[402420] = List(), -- Molten Scar
		[402253] = List(), -- Ray of Anguish
		[406525] = List(), -- Dread Rift
		[404743] = List(), -- Terror Claws
	-- Molgoth
		[405084] = List(), -- Lingering Umbra
		[405645] = List(), -- Engulfing Heat
		[405642] = List(), -- Blistering Twilight
		[402617] = List(), -- Blazing Heat
		[401809] = List(), -- Corrupting Shadow
		[405394] = List(), -- Shadowflame
	-- Experimentation of Dracthyr
		[406317] = List(), -- Mutilation 1
		[406365] = List(), -- Mutilation 2
		[405392] = List(), -- Disintegrate 1
		[405423] = List(), -- Disintegrate 2
		[406233] = List(), -- Deep Breath
		[407327] = List(), -- Unstable Essence
		[406313] = List(), -- Infused Strikes
		[407302] = List(), -- Infused Explosion
	-- Zaqali Invasion
		[408873] = List(), -- Heavy Cudgel
		[410353] = List(), -- Flaming Cudgel
		[407017] = List(), -- Vigorous Gale
		[401407] = List(), -- Blazing Spear 1
		[401452] = List(), -- Blazing Spear 2
		[409275] = List(), -- Magma Flow
	-- Rashok
		[407547] = List(), -- Flaming Upsurge
		[407597] = List(), -- Earthen Crush
		[405819] = List(), -- Searing Slam
		[408857] = List(), -- Doom Flame
	-- Zskarn
		[404955] = List(), -- Shrapnel Bomb
		[404010] = List(), -- Unstable Embers
		[404942] = List(), -- Searing Claws
		[403978] = List(), -- Blast Wave
		[405592] = List(), -- Salvage Parts
		[405462] = List(), -- Dragonfire Traps
		[409942] = List(), -- Elimination Protocol
	-- Magmorax
		[404846] = List(), -- Incinerating Maws 1
		[408955] = List(), -- Incinerating Maws 2
		[402994] = List(), -- Molten Spittle
		[403747] = List(), -- Igniting Roar
	-- Echo of Neltharion
		[409373] = List(), -- Disrupt Earth
		[407220] = List(), -- Rushing Shadows 1
		[407182] = List(), -- Rushing Shadows 2
		[405484] = List(), -- Surrendering to Corruption
		[409058] = List(), -- Seeping Lava
		[402120] = List(), -- Collapsed Earth
		[407728] = List(), -- Sundered Shadow
		[401998] = List(), -- Calamitous Strike
		[408160] = List(), -- Shadow Strike
		[403846] = List(), -- Sweeping Shadows
		[401133] = List(), -- Wildshift (Druid)
		[401131] = List(), -- Wild Summoning (Warlock)
		[401130] = List(), -- Wild Magic (Mage)
		[401135] = List(), -- Wild Breath (Evoker)
		[408071] = List(), -- Shapeshifter's Fervor
	-- Scalecommander Sarkareth
		[403520] = List(), -- Embrace of Nothingness
		[401383] = List(), -- Oppressing Howl
		[401951] = List(), -- Oblivion
		[407496] = List(), -- Infinite Duress
	---------------------------------------------------------
	---------------- Vault of the Incarnates ----------------
	---------------------------------------------------------
	-- Eranog
		[370648] = List(5), -- Primal Flow
		[390715] = List(6), -- Primal Rifts
		[370597] = List(6), -- Kill Order
	-- Terros
		[382776] = List(5), -- Awakened Earth 1
		[381253] = List(5), -- Awakened Earth 2
		[386352] = List(3), -- Rock Blast
		[382458] = List(6), -- Resonant Aftermath
	-- The Primal Council
		[371624] = List(5), -- Conductive Mark
		[372027] = List(4), -- Slashing Blaze
		[374039] = List(4), -- Meteor Axe
	-- Sennarth, the Cold Breath
		[371976] = List(4), -- Chilling Blast
		[372082] = List(5), -- Enveloping Webs
		[374659] = List(4), -- Rush
		[374104] = List(5), -- Wrapped in Webs Slow
		[374503] = List(6), -- Wrapped in Webs Stun
		[373048] = List(3), -- Suffocating Webs
	-- Dathea, Ascended
		[391686] = List(5), -- Conductive Mark
		[388290] = List(4), -- Cyclone
	-- Kurog Grimtotem
		[377780] = List(5), -- Skeletal Fractures
		[372514] = List(5), -- Frost Bite
		[374554] = List(4), -- Lava Pool
		[374709] = List(4), -- Seismic Rupture
		[374023] = List(6), -- Searing Carnage
		[374427] = List(6), -- Ground Shatter
		[390920] = List(5), -- Shocking Burst
		[372458] = List(6), -- Below Zero
	-- Broodkeeper Diurna
		[388920] = List(6), -- Frozen Shroud
		[378782] = List(5), -- Mortal Wounds
		[378787] = List(5), -- Crushing Stoneclaws
		[375620] = List(6), -- Ionizing Charge
		[375578] = List(4), -- Flame Sentry
	-- Raszageth the Storm-Eater
		[381615] = List(6), -- Static Charge
		[399713] = List(6), -- Magnetic Charge
		[385073] = List(5), -- Ball Lightning
		[377467] = List(6), -- Fulminating Charge
	},
}

--[[
	RAID BUFFS:
	Buffs that are provided by NPCs in raid or other PvE content.
	This can be buffs put on other enemies or on players.
]]
G.unitframe.aurafilters.RaidBuffsElvUI = {
	type = 'Whitelist',
	spells = {
	----------------------------------------------------------
	-------------------- Mythic+ Specific --------------------
	----------------------------------------------------------
	-- Mythic+ General
		[209859] = List(), -- Bolster
		[178658] = List(), -- Raging
		[226510] = List(), -- Sanguine
	----------------------------------------------------------
	----------------- Dragonflight Dungeons ------------------
	----------------------------------------------------------
	-- Brackenhide Hollow
		[384764] = List(), -- Feeding Frenzy
		[376933] = List(), -- Grasping Vines
		[374186] = List(), -- Decaying Strength
		[390968] = List(), -- Starving Frenzy
		[378029] = List(), -- Gash Frenzy
		[388046] = List(), -- Violent Whirlwind
		[377965] = List(), -- Bloodfrenzy
		[389788] = List(), -- Prey on the Weak
		[387890] = List(), -- Huntleader's Tactics 1
		[387889] = List(), -- Huntleader's Tactics 2
		[382444] = List(), -- Rotchant
		[376231] = List(), -- Decay Spray
		[383385] = List(), -- Rotting Surge
		[367484] = List(), -- Vicious Clawmangle
		[384930] = List(), -- Stealth
		[375259] = List(), -- Essence of Decay
		[389808] = List(), -- Predatory Instincts
		[383161] = List(), -- Decay Infusion
	-- Halls of Infusion
		[387585] = List(), -- Submerge
		[389872] = List(), -- Undertow
		[389056] = List(), -- Siphon Power 1
		[389490] = List(), -- Siphon Power 2
		[383840] = List(), -- Ablative Barrier
		[385743] = List(), -- Hangry
		[385442] = List(), -- Toxic Effluvia
		[385181] = List(), -- Overpowering Croak
		[384351] = List(), -- Spark Volley
		[386559] = List(), -- Glacial Surge
		[384014] = List(), -- Static Surge
		[395694] = List(), -- Elemental Focus
		[377402] = List(), -- Aqueous Barrier
		[375351] = List(), -- Oceanic Breath
		[387618] = List(), -- Infuse
		[374823] = List(), -- Zephyr's Call
		[393432] = List(), -- Spear Flurry
		[377384] = List(), -- Boiling Rage
		[374617] = List(), -- Rising Squall
	-- Neltharus
		[371992] = List(), -- Burning Chain 1
		[374451] = List(), -- Burning Chain 2
		[372824] = List(), -- Burning Chain 3
		[384663] = List(), -- Forgewrought Fury
		[383651] = List(), -- Molten Army
		[382791] = List(), -- Molten Barrier
		[381663] = List(), -- Candescent Tempest
		[375957] = List(), -- Forgestorm 1
		[375958] = List(), -- Forgestorm 2
		[375209] = List(), -- Forgestorm 3
		[375055] = List(), -- Fiery Focus
		[375780] = List(), -- Magma Shield
		[391765] = List(), -- Magma Shell
		[372472] = List(), -- Imbued Magma
		[374410] = List(), -- Magma Tentacle
		[374482] = List(), -- Grounding Chain
		[371875] = List(), -- Fired Up
		[372202] = List(), -- Scorching Breath
		[378149] = List(), -- Granite Shell
		[372311] = List(), -- Magma Fist
		[376780] = List(), -- Magma Shield
	-- Uldaman: Legacy of Tyr
		[369791] = List(), -- Skullcracker
		[369602] = List(), -- Defensive Bulwark 1
		[369603] = List(), -- Defensive Bulwark 2
		[372719] = List(), -- Titanic Empowerment
		[369754] = List(), -- Bloodlust(NPC)
		[368990] = List(), -- Purging Flames
		[386332] = List(), -- Unrelenting
		[369031] = List(), -- Sacred Barrier
		[376208] = List(), -- Rewing Timeflow
		[375339] = List(), -- Recovering...
		[372600] = List(), -- Inexorable
		[382264] = List(), -- Temporal Theft
		[377500] = List(), -- Hasten
		[369823] = List(), -- Spiked Carapace
		[369043] = List(), -- Infusion
		[369806] = List(), -- Reckless Rage
		[369465] = List(), -- Hail of Stone
		[377738] = List(), -- Ancient Power
		[377511] = List(), -- Stolen Time
	-- Ruby Life Pools
		[372743] = List(), -- Ice Shield
		[392569] = List(), -- Molten Blood
		[392486] = List(), -- Lightning Storm
		[385063] = List(), -- Burning Ambition
		[373972] = List(), -- Blaze of Glory
		[381525] = List(), -- Roaring Firebreath
		[392454] = List(), -- Burning Veins
		[381517] = List(), -- Winds of Change
		[391723] = List(), -- Flame Breath
		[372988] = List(), -- Ice Bulwark
		[391050] = List(), -- Tempest Stormshield
	-- The Nokhud Offensive
		[392198] = List(), -- Ancestral Bond
		[386319] = List(), -- Swirling Gusts
		[386223] = List(), -- Stormshield
		[387614] = List(), -- Chant of the Dead
		[384686] = List(), -- Energy Surge
		[376705] = List(), -- Crackling Shield
		[383823] = List(), -- Rally the Clan
		[384510] = List(), -- Cleaving Strikes
		[395045] = List(), -- Consumed Soul
		[386024] = List(), -- Tempest
		[386914] = List(), -- Primal Storm
		[386915] = List(), -- Stormsurge Totems
		[385339] = List(), -- Earthsplitter
		[384808] = List(), -- Guardian Winds
		[384620] = List(), -- Electrical Storm
		[383067] = List(), -- Raging Kin
	-- The Azure Vault
		[371042] = List(), -- Revealing Gaze
		[378065] = List(), -- Mage Hunters Fervor
		[395498] = List(), -- Scornful Haste
		[379256] = List(), -- Seal Empowerment
		[374778] = List(), -- Brilliant Scales
		[371358] = List(), -- Forbidden Knowledge
		[389686] = List(), -- Arcane Fury
		[374720] = List(), -- Consuming Stomp
		[395535] = List(), -- Sluggish Adoration
		[388084] = List(), -- Glacial Shield
		[391118] = List(), -- Spellfrost Breath
		[387122] = List(), -- Conjured Barrier
		[384132] = List(), -- Overwhelming Energy
		[388773] = List(), -- Oppressive Miasma
	-- Algeth'ar Academy
		[389032] = List(), -- Toxic
		[387910] = List(), -- Toxic Whirlwind
		[388958] = List(), -- Riftbreath
		[388796] = List(), -- Germinate
		[388886] = List(), -- Arcane Rain 1
		[388899] = List(), -- Arcane Rain 2
		[390938] = List(), -- Agitation
		[390297] = List(), -- Dormant
	----------------------------------------------------------
	---------------- Dragonflight (Season 2) -----------------
	----------------------------------------------------------
	-- Freehold
		[256060] = List(), -- Revitalizing Brew
		[256405] = List(), -- Shark Tornado
		[257899] = List(), -- Painful Motivation
		[257314] = List(), -- Black Powder Bomb
		[257870] = List(), -- Blade Barrage
		[257736] = List(), -- Thundering Squall
		[274860] = List(), -- Shattering Toss
		[257741] = List(), -- Blind Rage
		[256589] = List(), -- Barrel Smash
		[257476] = List(), -- Bestial Wrath
		[257757] = List(), -- Goin' Bananas
	-- Neltharion's Lair
		[183526] = List(), -- War Drums(Drogbar)
		[202198] = List(), -- Kill Command
		[198719] = List(), -- Falling Debris 1
		[193267] = List(), -- Falling Debris 2
		[199775] = List(), -- Frenzy
		[188587] = List(), -- Charskin
		[187714] = List(), -- Brittle
		[199246] = List(), -- Ravenous
		[199178] = List(), -- Spiked Tongue
		[202075] = List(), -- Scorch
		[193803] = List(), -- Metamorphosis
		[201983] = List(), -- Frenzy(Drogbar)
		[183433] = List(), -- Submerge
	-- Underrot
		[265091] = List(), -- Gift of G'huun
		[259830] = List(), -- Boundless Rot
		[265081] = List(), -- Warcry
		[269185] = List(), -- Blood Barrier
		[266201] = List(), -- Bone Shield
		[266209] = List(), -- Wicked Frenzy
	-- Vortex Pinnacle
		[87721] = List(), -- Beam A
		[87722] = List(), -- Beam B
		[87723] = List(), -- Beam C
		[86930] = List(), -- Supremacy of the Storm
		[86911] = List(), -- Unstable Grounding Field
		[85084] = List(), -- Howling Gale
		[411002] = List(), -- Turbulence
		[87780] = List(), -- Desperate Speed
		[88186] = List(), -- Vapor Form
		[410998] = List(), -- Wind Flurry
		[85467] = List(), -- Lurk
		[87762] = List(), -- Lightning Lash
		[87761] = List(), -- Rally
		[87726] = List(), -- Grounding Field
	---------------------------------------------------------
	------------ Aberrus, the Shadowed Crucible -------------
	---------------------------------------------------------
	-- Kazzara
		[406516] = List(), -- Dread Rifts
		[407199] = List(), -- Dread Rifts
		[407200] = List(), -- Dread Rifts
		[407198] = List(), -- Dread Rifts
		[408367] = List(), -- Infernal Heart
		[408372] = List(), -- Infernal Heart
		[408373] = List(), -- Infernal Heart
		[407069] = List(), -- Rays of Anguish
		[402219] = List(), -- Rays of Anguish
	-- Molgoth
		[406730] = List(), -- Crucible Instability
	-- Experimentation of Dracthyr
		[410019] = List(), -- Volatile Spew
		[406358] = List(), -- Mutilation
		[405413] = List(), -- Disintegrate
	-- Zaqali Invasion
		[410791] = List(), -- Blazing Focus
		[409696] = List(), -- Molten Empowerment
		[408620] = List(), -- Scorching Roar
		[397383] = List(), -- Molten Barrier
		[409271] = List(), -- Magma Flow
		[409359] = List(), -- Desperate Immolation
		[406585] = List(), -- Ignara's Fury
		[411230] = List(), -- Ignara's Flame
	-- Rashok
		[401419] = List(), -- Siphon Energy
		[405091] = List(), -- Unyielding Rage
		[407706] = List(), -- Molten Wrath
		[403536] = List(), -- Lava Infusion
	-- Zskarn
		[404939] = List(), -- Searing Claws
		[409463] = List(), -- Reinforced
	-- Magmorax
		[404846] = List(), -- Incinerating Maws
	-- Echo of Neltharion
		[404430] = List(), -- Wild Breath
		[403049] = List(), -- Shadow Barrier
		[404045] = List(), -- Annihilating Shadows
		[407088] = List(), -- Empowered Shadows
		[407039] = List(), -- Empower Shadows
	-- Scalecommander Sarkareth
		[404705] = List(), -- Rescind
		[404269] = List(), -- Ebon Might
		[401810] = List(), -- Glittering Surge
		[410631] = List(), -- Void Empowerment 1
		[403284] = List(), -- Void Empowerment 2
		[410654] = List(), -- Void Empowerment 3
		[410625] = List(), -- End Existence
	---------------------------------------------------------
	---------------- Vault of the Incarnates ----------------
	---------------------------------------------------------
	-- Eranog
		[393298] = List(), -- Eruption
		[394904] = List(), -- Burning Wound
		[395433] = List(), -- Shape Tempest
		[370307] = List(), -- Collapsing Army
	-- Terros
		[388393] = List(), -- Tectonic Barrage
	-- The Primal Council
		[374038] = List(), -- Meteor Axes
		[373059] = List(), -- Primal Blizzard
		[386375] = List(), -- Storming Convocation
		[386370] = List(), -- Quaking Convocation
		[386440] = List(), -- Glacial Convocation
		[386289] = List(), -- Burning Convocation
	-- Sennarth, the Cold Breath
		[374327] = List(), -- Caustic Blood
		[372238] = List(), -- Call Spiderlings
	-- Dathea, Ascended
		[388988] = List(), -- Crosswinds
		[389221] = List(), -- Gale Expulsion
		[381688] = List(), -- Unstable Gusts
		[377206] = List(), -- Cyclone
		[388029] = List(), -- Diverted Essence 1
		[387982] = List(), -- Diverted Essence 2
	-- Kurog Grimtotem
		[374321] = List(), -- Breaking Gravel
		[395893] = List(), -- Erupting Bedrock
		[374485] = List(), -- Magma Flow
		[374779] = List(), -- Primal Barrier
		[374707] = List(), -- Seismic Rupture
		[374624] = List(), -- Freezing Tempest
	-- Broodkeeper Diurna
		[380176] = List(), -- Empowered Greatstaff of the Broodkeeper
		[380174] = List(), -- Empowered Greatstaff of the Broodkeeper
		[388949] = List(), -- Frozen Shroud
		[375879] = List(), -- Broodkeeper's Fury
		[375457] = List(), -- Chilling Tantrum
		[375809] = List(), -- Broodkeeper's Bond
		[390561] = List(), -- Diurna's Gaze
	-- Raszageth the Storm-Eater
		[388691] = List(), -- Stormsurge
		[385360] = List(), -- Overload
		[382530] = List(), -- Surge
		[385547] = List(), -- Ascension
	---------------------------------------------------------
	----------------------- Open World ----------------------
	---------------------------------------------------------
	-- Korthia
		[354840] = List(), -- Rift Veiled (Silent Soulstalker, Deadsoul Hatcher, Screaming Shade)
		[355249] = List(), -- Anima Gorged (Consumption)
	-- Zereth Mortis
		[360945] = List(), -- Creation Catalyst Overcharge (Nascent Servitor)
		[366309] = List(), -- Meltdown (Destabilized Core)
		[365596] = List(), -- Overload (Destabilized Core)
		[360750] = List(), -- Aurelid Lure
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {},
	EVOKER = {
		[355941]	= Aura(355941, nil, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Dream Breath
		[376788]	= Aura(376788, nil, 'TOPRIGHT', {0.25, 0.25, 0.58}, nil, nil, nil, nil, -20), -- Dream Breath (echo)
		[363502]	= Aura(363502, nil, 'BOTTOMLEFT', {0.33, 0.33, 0.70}), -- Dream Flight
		[366155]	= Aura(366155, nil, 'BOTTOMRIGHT', {0.14, 1.00, 0.88}), -- Reversion
		[367364]	= Aura(367364, nil, 'BOTTOMRIGHT', {0.09, 0.69, 0.61}, nil, nil, nil, nil, -20), -- Reversion (echo)
		[373267]	= Aura(373267, nil, 'RIGHT', {0.82, 0.29, 0.24}), -- Life Bind (Verdant Embrace)
		[364343]	= Aura(364343, nil, 'TOP', {0.13, 0.87, 0.50}), -- Echo
		[357170]	= Aura(357170, nil, 'BOTTOM', {0.11, 0.57, 0.71}), -- Time Dilation
	},
	ROGUE = {
		[57934]		= Aura(57934, nil, 'TOPRIGHT', {0.89, 0.09, 0.05}), -- Tricks of the Trade
	},
	WARRIOR = {
		[3411]		= Aura(3411, nil, 'TOPRIGHT', {0.89, 0.09, 0.05}), -- Intervene
	},
	PRIEST = {
		[194384]	= Aura(194384, nil, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement
		[214206]	= Aura(214206, nil, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement (PvP)
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
		[287280]	= Aura(287280, nil, 'TOPLEFT', {0.2, 0.8, 0.2}), -- Glimmer of Light (T50 Talent)
		[1022]		= Aura(1022, nil, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), -- Blessing of Protection
		[1044]		= Aura(1044, nil, 'BOTTOMRIGHT', {0.89, 0.45, 0}, true), -- Blessing of Freedom
		[6940]		= Aura(6940, nil, 'BOTTOMRIGHT', {0.89, 0.1, 0.1}, true), -- Blessing of Sacrifice
		[204018]	= Aura(204018, nil, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), -- Blessing of Spellwarding
		[223306]	= Aura(223306, nil, 'BOTTOMLEFT', {0.7, 0.7, 0.3}), -- Bestow Faith
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
		[191840]	= Aura(191840, nil, 'BOTTOMRIGHT', {0.27, 0.62, 0.7}), -- Essence Font
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
}

-- Spells that chain, second step
G.unitframe.ChainChannelTicks = {
	-- Evoker
	[356995]	= 4, -- Disintegrate
}

-- Window to chain time (in seconds); usually the channel duration
G.unitframe.ChainChannelTime = {
	-- Evoker
	[356995]	= 3, -- Disintegrate
}

-- Spells Effected By Talents (unused; talents changed)
G.unitframe.TalentChannelTicks = {
	-- TODO: going to change this to a method which allows for the following API checks
	-- IsSpellKnownOrOverridesKnown and/or IsPlayerSpell (for some spells, ex: Improved Purify)
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
	[390386]	= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- [Evoker] Fury of the Aspects
}

G.unitframe.AuraHighlightColors = {}
