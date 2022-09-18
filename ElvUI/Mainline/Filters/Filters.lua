local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
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
		[213491]	= List(4), -- Demonic Trample (it's this one or the other)
		[208645]	= List(4), -- Demonic Trample
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
		[202933]	= List(2), -- Spider Sting (it's this one or the other)
		[233022]	= List(2), -- Spider Sting
		[213691]	= List(4), -- Scatter Shot
		[19386]		= List(3), -- Wyvern Sting
		[3355]		= List(3), -- Freezing Trap
		[203337]	= List(5), -- Freezing Trap (Survival PvPT)
		[209790]	= List(3), -- Freezing Arrow
		[24394]		= List(4), -- Intimidation
		[117526]	= List(4), -- Binding Shot
		[190927]	= List(1), -- Harpoon
		[201158]	= List(1), -- Super Sticky Tar
		[162480]	= List(1), -- Steel Trap
		[212638]	= List(1), -- Tracker's Net
		[200108]	= List(1), -- Ranger's Net
	-- Mage
		[61721]		= List(3), -- Rabbit (Poly)
		[61305]		= List(3), -- Black Cat (Poly)
		[28272]		= List(3), -- Pig (Poly)
		[28271]		= List(3), -- Turtle (Poly)
		[126819]	= List(3), -- Porcupine (Poly)
		[161354]	= List(3), -- Monkey (Poly)
		[161353]	= List(3), -- Polar bear (Poly)
		[61780]		= List(3), -- Turkey (Poly)
		[161355]	= List(3), -- Penguin (Poly)
		[161372]	= List(3), -- Peacock (Poly)
		[277787]	= List(3), -- Direhorn (Poly)
		[277792]	= List(3), -- Bumblebee (Poly)
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
		[232055]	= List(4), -- Fists of Fury (it's this one or the other)
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
		[199804]	= List(4), -- Between the Eyes
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
		[202043]	= List(), -- Protector of the Pack (it's this one or the other)
		[201940]	= List(), -- Protector of the Pack
		[201939]	= List(), -- Protector of the Pack (Allies)
		[192081]	= List(), -- Ironfur
		[50334]		= List(), -- Berserk (Guardian)
	-- Hunter
		[186265]	= List(), -- Aspect of the Turtle
		[53480]		= List(), -- Roar of Sacrifice
		[202748]	= List(), -- Survival Tactics
	-- Mage
		[45438]		= List(), -- Ice Block
		[113862]	= List(), -- Greater Invisibility
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
		[213602]	= List(), -- Greater Fade
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
		[202043]	= List(), -- Protector of the Pack (it's this one or the other)
		[201940]	= List(), -- Protector of the Pack
		[201939]	= List(), -- Protector of the Pack (Allies)
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
		[113862]	= List(), -- Greater Invisibility
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
		[213602]	= List(), -- Greater Fade
		[27827]		= List(), -- Spirit of Redemption
		[197268]	= List(), -- Ray of Hope
		[47788]		= List(), -- Guardian Spirit
		[33206]		= List(), -- Pain Suppression
		[200183]	= List(), -- Apotheosis
		[10060]		= List(), -- Power Infusion
		[47536]		= List(), -- Rapture
		[194249]	= List(), -- Voidform
		[193223]	= List(), -- Surrdender to Madness
		[197862]	= List(), -- Archangel
		[197871]	= List(), -- Dark Archangel
		[197874]	= List(), -- Dark Archangel
		[215769]	= List(), -- Spirit of Redemption
		[213610]	= List(), -- Holy Ward
		[121557]	= List(), -- Angelic Feather
		[214121]	= List(), -- Body and Mind
		[65081]		= List(), -- Body and Soul
		[197767]	= List(), -- Speed of the Pious
		[210980]	= List(), -- Focus in the Light
		[221660]	= List(), -- Holy Concentration
		[15286]		= List(), -- Vampiric Embrace
	-- Rogue
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
		[65116]		= List(), -- Stoneform
		[59547]		= List(), -- Gift of the Naaru
		[20572]		= List(), -- Blood Fury
		[26297]		= List(), -- Berserking
		[68992]		= List(), -- Darkflight
		[58984]		= List(), -- Shadowmeld
	-- General Consumables
		[178207]	= List(), -- Drums of Fury
		[230935]	= List(), -- Drums of the Mountain (Legion)
		[256740]	= List(), -- Drums of the Maelstrom (BfA)
		[321923]	= List(), -- Tome of the Still Mind
	-- Shadowlands Consumables
		[307159]	= List(), -- Potion of Spectral Agility
		[307160]	= List(), -- Potion of Hardened Shadows
		[307161]	= List(), -- Potion of Spiritual Clarity
		[307162]	= List(), -- Potion of Spectral Intellect
		[307163]	= List(), -- Potion of Spectral Stamina
		[307164]	= List(), -- Potion of Spectral Strength
		[307165]	= List(), -- Spiritual Anti-Venom
		[307185]	= List(), -- Spectral Flask of Power
		[307187]	= List(), -- Spectral Flask of Stamina
		[307195]	= List(), -- Potion of Hidden Spirit
		[307196]	= List(), -- Potion of Shaded Sight
		[307199]	= List(), -- Potion of Soul Purity
		[307494]	= List(), -- Potion of Empowered Exorcisms
		[307495]	= List(), -- Potion of Phantom Fire
		[307496]	= List(), -- Potion of Divine Awakening
		[307497]	= List(), -- Potion of Deathly Fixation
		[307501]	= List(), -- Potion of Specter Swiftness
		[308397]	= List(), -- Butterscotch Marinated Ribs
		[308402]	= List(), -- Surprisingly Palatable Feast
		[308404]	= List(), -- Cinnamon Bonefish Stew
		[308412]	= List(), -- Meaty Apple Dumplings
		[308425]	= List(), -- Sweet Silvergrill Sausages
		[308434]	= List(), -- Phantasmal Souffle and Fries
		[308488]	= List(), -- Tenebrous Crown Roast Aspic
		[308506]	= List(), -- Crawler Ravioli with Apple Sauce
		[308514]	= List(), -- Steak a la Mode
		[308525]	= List(), -- Banana Beef Pudding
		[308637]	= List(), -- Smothered Shank
		[322302]	= List(), -- Potion of Sacrificial Anima
		[327708]	= List(), -- Feast of Gluttonous Hedonism
		[327715]	= List(), -- Fried Bonefish
		[327851]	= List(), -- Seraph Tenders
		[354016]	= List(), -- Venthyr Tea
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
		[25771]		= List(), -- Forbearance (Pally: Divine Shield, Blessing of Protection, and Lay on Hands)
		[26013]		= List(), -- Deserter
		[36032]		= List(), -- Arcane Charge
		[36893]		= List(), -- Transporter Malfunction
		[36900]		= List(), -- Soul Split: Evil!
		[36901]		= List(), -- Soul Split: Good
		[41425]		= List(), -- Hypothermia
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
	},
}

-- A list of important buffs that we always want to see
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
		-- Bloodlust effects
		[2825]		= List(), -- Bloodlust
		[32182]		= List(), -- Heroism
		[80353]		= List(), -- Time Warp
		[90355]		= List(), -- Ancient Hysteria
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
		[209858] = List(), -- Necrotic
		[226512] = List(), -- Sanguine
		[240559] = List(), -- Grievous
		[240443] = List(), -- Bursting
	-- Shadowlands Season 3
		[368241] = List(3), -- Decrypted Urh Cypher
		[368244] = List(4), -- Urh Cloaking Field
		[368240] = List(3), -- Decrypted Wo Cypher
		[368239] = List(3), -- Decrypted Vy Cypher
		[366297] = List(6), -- Deconstruct (Tank Debuff)
		[366288] = List(6), -- Force Slam (Stun)
	-- Shadowlands Season 4
		[373364] = List(), -- Vampiric Claws
		[373429] = List(), -- Carrion Swarm
		[373370] = List(), -- Nightmare Cloud
		[373391] = List(), -- Nightmare
		[373570] = List(), -- Hypnosis
		[373607] = List(), -- Shadowy Barrier (Hypnosis)
		[373509] = List(), -- Shadow Claws (Stacking)
	----------------------------------------------------------
	---------------- Old Dungeons (Season 4) -----------------
	----------------------------------------------------------
	-- Grimrail Depot
		[162057] = List(), -- Spinning Spear
		[156357] = List(), -- Blackrock Shrapnel
		[160702] = List(), -- Blackrock Mortar Shells
		[160681] = List(), -- Suppressive Fire
		[166570] = List(), -- Slag Blast (Stacking)
		[164218] = List(), -- Double Slash
		[162491] = List(), -- Acquiring Targets 1
		[162507] = List(), -- Acquiring Targets 2
		[161588] = List(), -- Diffused Energy
		[162065] = List(), -- Freezing Snare
	-- Iron Docks
		[163276] = List(), -- Shredded Tendons
		[162415] = List(), -- Time to Feed
		[168398] = List(), -- Rapid Fire Targeting
		[172889] = List(), -- Charging Slash
		[164504] = List(), -- Intimidated
		[172631] = List(), -- Knocked Down
		[172636] = List(), -- Slippery Grease
		[158341] = List(), -- Gushing Wounds
		[167240] = List(), -- Leg Shot
		[173105] = List(), -- Whirling Chains
		[173324] = List(), -- Jagged Caltrops
		[172771] = List(), -- Incendiary Slug
		[173307] = List(), -- Serrated Spear
		[169341] = List(), -- Demoralizing Roar
	-- Return to Karazhan: Upper
		[229248] = List(), -- Fel Beam
		[227592] = List(6), -- Frostbite
		[228252] = List(), -- Shadow Rend
		[227502] = List(), -- Unstable Mana
		[228261] = List(6), -- Flame Wreath
		[229241] = List(), -- Acquiring Target
		[230083] = List(6), -- Nullification
		[230221] = List(), -- Absorbed Mana
		[228249] = List(5), -- Inferno Bolt 1
		[228958] = List(5), -- Inferno Bolt 2
		[229159] = List(), -- Chaotic Shadows
		[227465] = List(), -- Power Discharge
		[229083] = List(), -- Burning Blast (Stacking)
	-- Return to Karazhan: Lower
		[227917] = List(), -- Poetry Slam
		[228164] = List(), -- Hammer Down
		[228215] = List(), -- Severe Dusting 1
		[228221] = List(), -- Severe Dusting 2
		[29690]  = List(), -- Drunken Skull Crack
		[227493] = List(), -- Mortal Strike
		[228280] = List(), -- Oath of Fealty
		[29574]  = List(), -- Rend
		[230297] = List(), -- Brittle Bones
		[228526] = List(), -- Flirt
		[227851] = List(), -- Coat Check 1
		[227832] = List(), -- Coat Check 2
		[32752]  = List(), -- Summoning Disorientation
		[228559] = List(), -- Charming Perfume
		[227508] = List(), -- Mass Repentance
		[241774] = List(), -- Shield Smash
		[227742] = List(), -- Garrote (Stacking)
		[238606] = List(), -- Arcane Eruption
		[227848] = List(), -- Sacred Ground (Stacking)
		[227404] = List(6), -- Intangible Presence
		[228610] = List(), -- Burning Brand
		[228576] = List(), -- Allured
	-- Operation Mechagon
		[291928] = List(), -- Giga-Zap
		[292267] = List(), -- Giga-Zap
		[302274] = List(), -- Fulminating Zap
		[298669] = List(), -- Taze
		[295445] = List(), -- Wreck
		[294929] = List(), -- Blazing Chomp
		[297257] = List(), -- Electrical Charge
		[294855] = List(), -- Blossom Blast
		[291972] = List(), -- Explosive Leap
		[285443] = List(), -- 'Hidden' Flame Cannon
		[291974] = List(), -- Obnoxious Monologue
		[296150] = List(), -- Vent Blast
		[298602] = List(), -- Smoke Cloud
		[296560] = List(), -- Clinging Static
		[297283] = List(), -- Cave In
		[291914] = List(), -- Cutting Beam
		[302384] = List(), -- Static Discharge
		[294195] = List(), -- Arcing Zap
		[299572] = List(), -- Shrink
		[300659] = List(), -- Consuming Slime
		[300650] = List(), -- Suffocating Smog
		[301712] = List(), -- Pounce
		[299475] = List(), -- B.O.R.K
		[293670] = List(), -- Chain Blade
	----------------------------------------------------------
	------------------ Shadowlands Dungeons ------------------
	----------------------------------------------------------
	-- Tazavesh, the Veiled Market
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
		[350134] = List(), -- Infinite Breath
		[350013] = List(), -- Gluttonous Feast
		[355465] = List(), -- Boulder Throw
		[346116] = List(), -- Shearing Swings
		[356011] = List(), -- Beam Splicer
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
	-- Mists of Tirna Scithe
		[325027] = List(), -- Bramble Burst
		[323043] = List(), -- Bloodletting
		[322557] = List(), -- Soul Split
		[331172] = List(), -- Mind Link
		[322563] = List(), -- Marked Prey
		[322487] = List(), -- Overgrowth 1
		[322486] = List(), -- Overgrowth 2
		[328756] = List(), -- Repulsive Visage
		[325021] = List(), -- Mistveil Tear
		[321891] = List(), -- Freeze Tag Fixation
		[325224] = List(), -- Anima Injection
		[326092] = List(), -- Debilitating Poison
		[325418] = List(), -- Volatile Acid
	-- Plaguefall
		[336258] = List(), -- Solitary Prey
		[331818] = List(), -- Shadow Ambush
		[329110] = List(), -- Slime Injection
		[325552] = List(), -- Cytotoxic Slash
		[336301] = List(), -- Web Wrap
		[322358] = List(), -- Burning Strain
		[322410] = List(), -- Withering Filth
		[328180] = List(), -- Gripping Infection
		[320542] = List(), -- Wasting Blight
		[340355] = List(), -- Rapid Infection
		[328395] = List(), -- Venompiercer
		[320512] = List(), -- Corroded Claws
		[333406] = List(), -- Assassinate
		[332397] = List(), -- Shroudweb
		[330069] = List(), -- Concentrated Plague
	-- The Necrotic Wake
		[321821] = List(), -- Disgusting Guts
		[323365] = List(), -- Clinging Darkness
		[338353] = List(), -- Goresplatter
		[333485] = List(), -- Disease Cloud
		[338357] = List(), -- Tenderize
		[328181] = List(), -- Frigid Cold
		[320170] = List(), -- Necrotic Bolt
		[323464] = List(), -- Dark Ichor
		[323198] = List(), -- Dark Exile
		[343504] = List(), -- Dark Grasp
		[343556] = List(), -- Morbid Fixation 1
		[338606] = List(), -- Morbid Fixation 2
		[324381] = List(), -- Chill Scythe
		[320573] = List(), -- Shadow Well
		[333492] = List(), -- Necrotic Ichor
		[334748] = List(), -- Drain Fluids
		[333489] = List(), -- Necrotic Breath
		[320717] = List(), -- Blood Hunger
	-- Theater of Pain
		[333299] = List(), -- Curse of Desolation 1
		[333301] = List(), -- Curse of Desolation 2
		[319539] = List(), -- Soulless
		[326892] = List(), -- Fixate
		[321768] = List(), -- On the Hook
		[323825] = List(), -- Grasping Rift
		[342675] = List(), -- Bone Spear
		[323831] = List(), -- Death Grasp
		[330608] = List(), -- Vile Eruption
		[330868] = List(), -- Necrotic Bolt Volley
		[323750] = List(), -- Vile Gas
		[323406] = List(), -- Jagged Gash
		[330700] = List(), -- Decaying Blight
		[319626] = List(), -- Phantasmal Parasite
		[324449] = List(), -- Manifest Death
		[341949] = List(), -- Withering Blight
	-- Sanguine Depths
		[326827] = List(), -- Dread Bindings
		[326836] = List(), -- Curse of Suppression
		[322554] = List(), -- Castigate
		[321038] = List(), -- Burden Soul
		[328593] = List(), -- Agonize
		[325254] = List(), -- Iron Spikes
		[335306] = List(), -- Barbed Shackles
		[322429] = List(), -- Severing Slice
		[334653] = List(), -- Engorge
	-- Spires of Ascension
		[338729] = List(), -- Charged Stomp
		[323195] = List(), -- Purifying Blast
		[327481] = List(), -- Dark Lance
		[322818] = List(), -- Lost Confidence
		[322817] = List(), -- Lingering Doubt
		[324205] = List(), -- Blinding Flash
		[331251] = List(), -- Deep Connection
		[328331] = List(), -- Forced Confession
		[341215] = List(), -- Volatile Anima
		[323792] = List(), -- Anima Field
		[317661] = List(), -- Insidious Venom
		[330683] = List(), -- Raw Anima
		[328434] = List(), -- Intimidated
	-- De Other Side
		[320786] = List(), -- Power Overwhelming
		[334913] = List(), -- Master of Death
		[325725] = List(), -- Cosmic Artifice
		[328987] = List(), -- Zealous
		[334496] = List(), -- Soporific Shimmerdust
		[339978] = List(), -- Pacifying Mists
		[323692] = List(), -- Arcane Vulnerability
		[333250] = List(), -- Reaver
		[330434] = List(), -- Buzz-Saw 1
		[320144] = List(), -- Buzz-Saw 2
		[331847] = List(), -- W-00F
		[327649] = List(), -- Crushed Soul
		[331379] = List(), -- Lubricate
		[332678] = List(), -- Gushing Wound
		[322746] = List(), -- Corrupted Blood
		[323687] = List(), -- Arcane Lightning
		[323877] = List(), -- Echo Finger Laser X-treme
		[334535] = List(), -- Beak Slice
	--------------------------------------------------------
	-------------------- Castle Nathria --------------------
	--------------------------------------------------------
	-- Shriekwing
		[328897] = List(), -- Exsanguinated
		[330713] = List(), -- Reverberating Pain
		[329370] = List(), -- Deadly Descent
		[336494] = List(), -- Echo Screech
		[346301] = List(), -- Bloodlight
		[342077] = List(), -- Echolocation
	-- Huntsman Altimor
		[335304] = List(), -- Sinseeker
		[334971] = List(), -- Jagged Claws
		[335111] = List(), -- Huntsman's Mark 3
		[335112] = List(), -- Huntsman's Mark 2
		[335113] = List(), -- Huntsman's Mark 1
		[334945] = List(), -- Vicious Lunge
		[334852] = List(), -- Petrifying Howl
		[334695] = List(), -- Destabilize
	-- Hungering Destroyer
		[334228] = List(), -- Volatile Ejection
		[329298] = List(), -- Gluttonous Miasma
	-- Lady Inerva Darkvein
		[325936] = List(), -- Shared Cognition
		[335396] = List(), -- Hidden Desire
		[324983] = List(), -- Shared Suffering
		[324982] = List(), -- Shared Suffering (Partner)
		[332664] = List(), -- Concentrate Anima
		[325382] = List(), -- Warped Desires
	-- Sun King's Salvation
		[333002] = List(), -- Vulgar Brand
		[326078] = List(), -- Infuser's Boon
		[325251] = List(), -- Sin of Pride
		[341475] = List(), -- Crimson Flurry
		[341473] = List(), -- Crimson Flurry Teleport
		[328479] = List(), -- Eyes on Target
		[328889] = List(), -- Greater Castigation
	-- Artificer Xy'mox
		[327902] = List(), -- Fixate
		[326302] = List(), -- Stasis Trap
		[325236] = List(), -- Glyph of Destruction
		[327414] = List(), -- Possession
		[328468] = List(), -- Dimensional Tear 1
		[328448] = List(), -- Dimensional Tear 2
		[340860] = List(), -- Withering Touch
	-- The Council of Blood
		[327052] = List(), -- Drain Essence 1
		[327773] = List(), -- Drain Essence 2
		[346651] = List(), -- Drain Essence Mythic
		[328334] = List(), -- Tactical Advance
		[330848] = List(), -- Wrong Moves
		[331706] = List(), -- Scarlet Letter
		[331636] = List(), -- Dark Recital 1
		[331637] = List(), -- Dark Recital 2
	-- Sludgefist
		[335470] = List(), -- Chain Slam
		[339181] = List(), -- Chain Slam (Root)
		[331209] = List(), -- Hateful Gaze
		[335293] = List(), -- Chain Link
		[335270] = List(), -- Chain This One!
		[342419] = List(), -- Chain Them! 1
		[342420] = List(), -- Chain Them! 2
		[335295] = List(), -- Shattering Chain
		[332572] = List(), -- Falling Rubble
	-- Stone Legion Generals
		[334498] = List(), -- Seismic Upheaval
		[337643] = List(), -- Unstable Footing
		[334765] = List(), -- Heart Rend
		[334771] = List(), -- Heart Hemorrhage
		[333377] = List(), -- Wicked Mark
		[334616] = List(), -- Petrified
		[334541] = List(), -- Curse of Petrification
		[339690] = List(), -- Crystalize
		[342655] = List(), -- Volatile Anima Infusion
		[342698] = List(), -- Volatile Anima Infection
		[343881] = List(), -- Serrated Tear
	-- Sire Denathrius
		[326851] = List(), -- Blood Price
		[327796] = List(), -- Night Hunter
		[327992] = List(), -- Desolation
		[328276] = List(), -- March of the Penitent
		[326699] = List(), -- Burden of Sin
		[329181] = List(), -- Wracking Pain
		[335873] = List(), -- Rancor
		[329951] = List(), -- Impale
		[327039] = List(), -- Feeding Time
		[332794] = List(), -- Fatal Finesse
		[334016] = List(), -- Unworthy
	--------------------------------------------------------
	---------------- Sanctum of Domination -----------------
	--------------------------------------------------------
	-- The Tarragrue
		[347283] = List(5), -- Predator's Howl
		[347286] = List(5), -- Unshakeable Dread
		[346986] = List(3), -- Crushed Armor
		[347269] = List(6), -- Chains of Eternity
		[346985] = List(3), -- Overpower
	-- Eye of the Jailer
		[350606] = List(4), -- Hopeless Lethargy
		[355240] = List(5), -- Scorn
		[355245] = List(5), -- Ire
		[349979] = List(2), -- Dragging Chains
		[348074] = List(3), -- Assailing Lance
		[351827] = List(6), -- Spreading Misery
		[355143] = List(6), -- Deathlink
		[350763] = List(6), -- Annihilating Glare
	-- The Nine
		[350287] = List(2), -- Song of Dissolution
		[350542] = List(6), -- Fragments of Destiny
		[350202] = List(3), -- Unending Strike
		[350475] = List(5), -- Pierce Soul
		[350555] = List(3), -- Shard of Destiny
		[350109] = List(5), -- Brynja's Mournful Dirge
		[350483] = List(6), -- Link Essence
		[350039] = List(5), -- Arthura's Crushing Gaze
		[350184] = List(5), -- Daschla's Mighty Impact
		[350374] = List(5), -- Wings of Rage
	-- Remnant of Ner'zhul
		[350073] = List(2), -- Torment
		[349890] = List(5), -- Suffering
		[350469] = List(6), -- Malevolence
		[354634] = List(6), -- Spite 1
		[354479] = List(6), -- Spite 2
		[354534] = List(6), -- Spite 3
	-- Soulrender Dormazain
		[353429] = List(2), -- Tormented
		[353023] = List(3), -- Torment
		[351787] = List(5), -- Agonizing Spike
		[350647] = List(5), -- Brand of Torment
		[350422] = List(6), -- Ruinblade
		[350851] = List(6), -- Vessel of Torment
		[354231] = List(6), -- Soul Manacles
		[348987] = List(6), -- Warmonger Shackle 1
		[350927] = List(6), -- Warmonger Shackle 2
	-- Painsmith Raznal
		[356472] = List(5), -- Lingering Flames
		[355505] = List(6), -- Shadowsteel Chains 1
		[355506] = List(6), -- Shadowsteel Chains 2
		[348456] = List(6), -- Flameclasp Trap
		[356870] = List(2), -- Flameclasp Eruption
		[355568] = List(6), -- Cruciform Axe
		[355786] = List(5), -- Blackened Armor
		[355526] = List(6), -- Spiked
	-- Guardian of the First Ones
		[352394] = List(5), -- Radiant Energy
		[350496] = List(6), -- Threat Neutralization
		[347359] = List(6), -- Suppression Field
		[355357] = List(6), -- Obliterate
		[350732] = List(5), -- Sunder
		[352833] = List(6), -- Disintegration
	-- Fatescribe Roh-Kalo
		[354365] = List(5), -- Grim Portent
		[350568] = List(5), -- Call of Eternity
		[353435] = List(6), -- Overwhelming Burden
		[351680] = List(6), -- Invoke Destiny
		[353432] = List(6), -- Burden of Destiny
		[353693] = List(6), -- Unstable Accretion
		[350355] = List(6), -- Fated Conjunction
		[353931] = List(2), -- Twist Fate
	-- Kel'Thuzad
		[346530] = List(2), -- Frozen Destruction
		[354289] = List(2), -- Sinister Miasma
		[347454] = List(6), -- Oblivion's Echo 1
		[347518] = List(6), -- Oblivion's Echo 2
		[347292] = List(6), -- Oblivion's Echo 3
		[348978] = List(6), -- Soul Exhaustion
		[355389] = List(6), -- Relentless Haunt (Fixate)
		[357298] = List(6), -- Frozen Binds
		[355137] = List(5), -- Shadow Pool
		[348638] = List(4), -- Return of the Damned
		[348760] = List(6), -- Frost Blast
	-- Sylvanas Windrunner
		[349458] = List(2), -- Domination Chains
		[347704] = List(2), -- Veil of Darkness
		[347607] = List(5), -- Banshee's Mark
		[347670] = List(5), -- Shadow Dagger
		[351117] = List(5), -- Crushing Dread
		[351870] = List(5), -- Haunting Wave
		[351253] = List(5), -- Banshee Wail
		[351451] = List(6), -- Curse of Lethargy
		[351092] = List(6), -- Destabilize 1
		[351091] = List(6), -- Destabilize 2
		[348064] = List(6), -- Wailing Arrow
	----------------------------------------------------------
	-------------- Sepulcher of the First Ones ---------------
	----------------------------------------------------------
	-- Vigilant Guardian
		[364447] = List(3), -- Dissonance
		[364904] = List(6), -- Anti-Matter
		[364881] = List(5), -- Matter Disolution
		[360415] = List(5), -- Defenseless
		[360412] = List(4), -- Exposed Core
		[366393] = List(5), -- Searing Ablation
	-- Skolex, the Insatiable Ravener
		[364522] = List(2), -- Devouring Blood
		[359976] = List(2), -- Riftmaw
		[359981] = List(2), -- Rend
		[360098] = List(3), -- Warp Sickness
		[366070] = List(3), -- Volatile Residue
	-- Artificer Xy'mox
		[364030] = List(3), -- Debilitating Ray
		[365681] = List(2), -- System Shock
		[363413] = List(4), -- Forerunner Rings A
		[364604] = List(4), -- Forerunner Rings B
		[362615] = List(6), -- Interdimensional Wormhole Player 1
		[362614] = List(6), -- Interdimensional Wormhole Player 2
		[362803] = List(5), -- Glyph of Relocation
	-- Dausegne, The Fallen Oracle
		[361751] = List(2), -- Disintegration Halo
		[364289] = List(2), -- Staggering Barrage
		[361018] = List(2), -- Staggering Barrage Mythic 1
		[360960] = List(2), -- Staggering Barrage Mythic 2
		[361225] = List(2), -- Encroaching Dominion
		[361966] = List(2), -- Infused Strikes
	-- Prototype Pantheon
		[365306] = List(2), -- Invigorating Bloom
		[361689] = List(3), -- Wracking Pain
		[366232] = List(4), -- Animastorm
		[364839] = List(2), -- Sinful Projection
		[360259] = List(5), -- Gloom Bolt
		[362383] = List(5), -- Anima Bolt
		[362352] = List(6), -- Pinned
	-- Lihuvim, Principle Architect
		[360159] = List(5), -- Unstable Protoform Energy
		[363681] = List(3), -- Deconstructing Blast
		[363676] = List(4), -- Deconstructing Energy Player 1
		[363795] = List(4), -- Deconstructing Energy Player 2
		[464312] = List(5), -- Ephemeral Barrier
	-- Halondrus the Reclaimer
		[361309] = List(3), -- Lightshatter Beam
		[361002] = List(4), -- Ephemeral Fissure
		[360114] = List(4), -- Ephemeral Fissure II
	-- Anduin Wrynn
		[365293] = List(2), -- Befouled Barrier
		[363020] = List(3), -- Necrotic Claws
		[365021] = List(5), -- Wicked Star (marked)
		[365024] = List(6), -- Wicked Star (hit)
		[365445] = List(3), -- Scarred Soul
		[365008] = List(4), -- Psychic Terror
		[366849] = List(6), -- Domination Word: Pain
	-- Lords of Dread
		[360148] = List(5), -- Bursting Dread
		[360012] = List(4), -- Cloud of Carrion
		[360146] = List(4), -- Fearful Trepidation
		[360241] = List(6), -- Unsettling Dreams
	-- Rygelon
		[362206] = List(6), -- Event Horizon
		[362137] = List(4), -- Corrupted Wound
		[362172] = List(4), -- Corrupted Wound
		[361548] = List(5), -- Dark Eclipse
	-- The Jailer
		[362075] = List(6), -- Domination
		[365150] = List(6), -- Rune of Domination
		[363893] = List(5), -- Martyrdom
		[363886] = List(5), -- Imprisonment
		[365219] = List(5), -- Chains of Anguish
		[366285] = List(6), -- Rune of Compulsion
		[363332] = List(5), -- Unbreaking Grasp
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
		[343502] = List(), -- Inspiring
	-- Shadowlands Season 3
		[368104] = List(), -- Acceleration Field
		[368079] = List(), -- Defense Matrix
	-- Shadowlands Season 4
		[373011] = List(6), -- Disguised
		[373108] = List(2), -- Bounty: Critical Strike (Stacking)
		[373113] = List(2), -- Bounty: Haste (Stacking)
		[373121] = List(2), -- Bounty: Versatility (Stacking)
		[373116] = List(2), -- Bounty: Mastery (Stacking)
	----------------------------------------------------------
	---------------- Old Dungeons (Season 4) -----------------
	----------------------------------------------------------
	-- Grimrail Depot
		[161091] = List(), -- New Plan!
		[166378] = List(), -- Reckless Slash
		[163550] = List(), -- Blackrock Mortar
		[163947] = List(), -- Recovering
		[162572] = List(), -- Missile Smoke
		[166335] = List(), -- Storm Shield
		[176023] = List(), -- Getting Angry
		[166561] = List(), -- Locking On!
	-- Iron Docks
		[164426] = List(), -- Reckless Provocation
		[173091] = List(), -- Champion's Presence
		[373724] = List(), -- Blood Barrier
		[172943] = List(), -- Brutal Inspiration
		[173455] = List(), -- Pit Fighter
		[162424] = List(), -- Feeding Frenzy
		[167232] = List(), -- Bladestorm
		[178412] = List(), -- Flurry
	-- Return to Karazhan: Upper
		[228254] = List(), -- Soul Leech
		[227529] = List(), -- Unstable Energy
		[227254] = List(), -- Evocation
		[227257] = List(), -- Overload
		[228362] = List(), -- Siphon Energy
		[373388] = List(), -- Nightmare Cloud
		[227270] = List(), -- Arc Lightning
	-- Return to Karazhan: Lower
		[227817] = List(), -- Holy Bulwark
		[228225] = List(), -- Sultry Heat
		[228895] = List(), -- Enrage (100/100)
		[232156] = List(), -- Spectral Service
		[232142] = List(), -- Flashing Forks
		[227931] = List(), -- In The Spotlight
		[227872] = List(), -- Ghastly Purge
		[233669] = List(), -- Dinner Party
		[227999] = List(), -- Pennies From Heaven
		[228729] = List(), -- Eminence (Stacking)
		[227983] = List(), -- Rapid Fan
		[228575] = List(), -- Alluring Aura
		[233210] = List(), -- Whip Rage
	-- Operation Mechagon
		[298651] = List(), -- Pedal to the Metal 1
		[299164] = List(), -- Pedal to the Metal 2
		[303941] = List(), -- Defensive Countermeasure (Junkyard)
		[297133] = List(), -- Defensive Countermeasure (Workshop)
		[299153] = List(), -- Turbo Boost
		[301689] = List(), -- Charged Coil
		[300207] = List(), -- Shock Coil
		[300414] = List(), -- Enrage
		[296080] = List(), -- Haywire
		[293729] = List(), -- Tune Up
		[282801] = List(), -- Platinum Plating (Stacking)
		[285388] = List(), -- Vent Jets
		[295169] = List(), -- Capacitor Discharge
		[283565] = List(), -- Maximum Thrust
		[293930] = List(), -- Overclock
		[291946] = List(), -- Venting Flames
		[294290] = List(), -- Process Waste
	----------------------------------------------------------
	------------------ Shadowlands Dungeons ------------------
	----------------------------------------------------------
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
	-- Halls of Atonement
		[326450] = List(), -- Loyal Beasts
	-- Mists of Tirna Scithe
		[336499] = List(), -- Guessing Game
	-- Plaguefall
		[336451] = List(), -- Bulwark of Maldraxxus
		[333737] = List(), -- Congealed Contagion
	-- The Necrotic Wake
		[321754] = List(), -- Icebound Aegis
		[343558] = List(), -- Morbid Fixation
		[343470] = List(), -- Boneshatter Shield
	-- Theater of Pain
		[331510] = List(), -- Death Wish
		[333241] = List(), -- Raging Tantrum
		[326892] = List(), -- Fixate
		[330545] = List(), -- Commanding Presences
	-- Sanguine Depths
		[322433] = List(), -- Stoneskin
		[321402] = List(), -- Engorge
	-- Spires of Ascension
		[327416] = List(), -- Recharge Anima
		[317936] = List(), -- Forsworn Doctrine
		[327808] = List(), -- Inspiring Presence
	-- De Other Side
		[344739] = List(), -- Spectral
		[333227] = List(), -- Undying Rage
		[322773] = List(), -- Blood Barrier
	----------------------------------------------------------
	--------------------- Castle Nathria ---------------------
	----------------------------------------------------------
	-- Sun King's Salvation
		[343026] = List(), -- Cloak of Flames
	-- Stone Legion Generals
		[329808] = List(), -- Hardened Stone Form Grashaal
		[329636] = List(), -- Hardened Stone Form Kaal
		[340037] = List(), -- Volatile Stone Shell
	----------------------------------------------------------
	----------------- Sanctum of Domination ------------------
	----------------------------------------------------------
	-- The Tarragrue
		[352491] = List(), -- Remnant: Mort'regar's Echoes 1
		[352389] = List(), -- Remnant: Mort'regar's Echoes 2
		[352473] = List(), -- Remnant: Upper Reaches' Might 1
		[352382] = List(), -- Remnant: Upper Reaches' Might 2
		[352398] = List(), -- Remnant: Soulforge Heat
		[347490] = List(), -- Fury of the Ages
		[347740] = List(), -- Hungering Mist 1
		[347679] = List(), -- Hungering Mist 2
		[347369] = List(), -- The Jailer's Gaze
	-- Eye of the Jailer
		[350006] = List(), -- Pulled Down
		[351413] = List(), -- Annihilating Glare
		[348805] = List(), -- Stygian Darkshield
		[351994] = List(), -- Dying Suffering
		[351825] = List(), -- Shared Suffering
		[345521] = List(), -- Molten Aura
	-- The Nine
		[355294] = List(), -- Resentment
		[350286] = List(), -- Song of Dissolution
		[352756] = List(), -- Wings of Rage 1
		[350365] = List(), -- Wings of Rage 2
		[352752] = List(), -- Reverberating Refrain 1
		[350385] = List(), -- Reverberating Refrain 2
		[350158] = List(), -- Annhylde's Bright Aegis
	-- Remnant of Ner'zhul
		[355790] = List(), -- Eternal Torment
		[355151] = List(), -- Malevolence
		[355439] = List(), -- Aura of Spite 1
		[354441] = List(), -- Aura of Spite 2
		[350671] = List(), -- Aura of Spite 3
		[354440] = List(), -- Aura of Spite 4
	-- Soulrender Dormazain
		[351946] = List(), -- Hellscream
		[352066] = List(), -- Rendered Soul
		[353554] = List(), -- Infuse Defiance
		[351773] = List(), -- Defiance
		[350415] = List(), -- Warmonger's Shackles
		[352933] = List(), -- Tormented Eruptions
	-- Painsmith Raznal
		[355525] = List(), -- Forge Weapon
	-- Guardian of the First Ones
		[352538] = List(), -- Purging Protocol
		[353448] = List(), -- Suppression Field
		[350534] = List(), -- Purging Protocol
		[352385] = List(), -- Energizing Link
	-- Fatescribe Roh-Kalo
		[353604] = List(), -- Diviner's Probe
	-- Kel'Thuzad
		[355935] = List(), -- Banshee's Cry 1
		[352141] = List(), -- Banshee's Cry 2
		[355948] = List(), -- Necrotic Empowerment
		[352051] = List(), -- Necrotic Surge
	-- Sylvanas Windrunner
		[352650] = List(), -- Ranger's Heartseeker 1
		[352663] = List(), -- Ranger's Heartseeker 2
		[350865] = List(), -- Accursed Might
		[348146] = List(), -- Banshee Form
		[347504] = List(), -- Windrunner
		[350857] = List(), -- Banshee Shroud
		[351109] = List(), -- Enflame
		[351452] = List(), -- Lethargic Focus
	----------------------------------------------------------
	-------------- Sepulcher of the First Ones ---------------
	----------------------------------------------------------
	-- Vigilant Guardian
		[360404] = List(), -- Force Field
		[366822] = List(), -- Radioactive Core
		[364843] = List(), -- Fractured Core
		[364962] = List(), -- Core Overload
	-- Skolex, the Insatiable Ravener
		[360193] = List(), -- Insatiable (stacking)
	-- Artificer Xy'mox
		[363139] = List(), -- Decipher Relic
	-- Dausegne, the Fallen Oracle
		[361651] = List(), -- Siphoned Barrier
		[362432] = List(), -- Collapsed Barrier
		[361513] = List(), -- Obliteraion Arc
	-- Prototype Pantheon
		[361938] = List(), -- Reconstruction
		[360845] = List(), -- Bastion's Ward
	-- Lihuvim, Principle Architect
		[363537] = List(), -- Protoform Radiance
		[365036] = List(), -- Ephemeral Barrier
		[361200] = List(), -- Recharge
		[363130] = List(), -- Synthesize
	-- Halondrus the Reclaimer
		[367078] = List(), -- Phase Barrier
		[363414] = List(), -- Fractal Shell
		[359235] = List(), -- Reclamation Form
		[359236] = List(), -- Relocation Form
	-- Anduin Wrynn
		[364248] = List(), -- Dark Zeal
		[365030] = List(), -- Wicked Star
		[362862] = List(), -- Army of the Dea
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
	ROGUE = {
		[57934]		= Aura(57934, nil, 'TOPRIGHT', {0.89, 0.09, 0.05}), -- Tricks of the Trade
	},
	WARRIOR = {
		[3411]		= Aura(3411, nil, 'TOPRIGHT', {0.89, 0.09, 0.05}), -- Intervene
	},
	PRIEST = {
		[139]		= Aura(139, nil, 'BOTTOMLEFT', {0.4, 0.7, 0.2}), -- Renew
		[17]		= Aura(17, nil, 'TOPLEFT', {0.7, 0.7, 0.7}, true), -- Power Word: Shield
		[193065]	= Aura(193065, nil, 'BOTTOMRIGHT', {0.54, 0.21, 0.78}), -- Masochism
		[194384]	= Aura(194384, nil, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement
		[214206]	= Aura(214206, nil, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement (PvP)
		[33206]		= Aura(33206, nil, 'LEFT', {0.47, 0.35, 0.74}, true), -- Pain Suppression
		[41635]		= Aura(41635, nil, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}), -- Prayer of Mending
		[47788]		= Aura(47788, nil, 'LEFT', {0.86, 0.45, 0}, true), -- Guardian Spirit
		[6788]		= Aura(6788, nil, 'BOTTOMLEFT', {0.89, 0.1, 0.1}), -- Weakened Soul
	},
	DRUID = {
		[774]		= Aura(774, nil, 'TOPRIGHT', {0.8, 0.4, 0.8}), -- Rejuvenation
		[155777]	= Aura(155777, nil, 'RIGHT', {0.8, 0.4, 0.8}), -- Germination
		[8936]		= Aura(8936, nil, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Regrowth
		[33763]		= Aura(33763, nil, 'TOPLEFT', {0.4, 0.8, 0.2}), -- Lifebloom
		[188550]	= Aura(188550, nil, 'TOPLEFT', {0.4, 0.8, 0.2}), -- Lifebloom (Shadowlands Legendary)
		[48438]		= Aura(48438, nil, 'BOTTOMRIGHT', {0.8, 0.4, 0}), -- Wild Growth
		[207386]	= Aura(207386, nil, 'TOP', {0.4, 0.2, 0.8}), -- Spring Blossoms
		[102351]	= Aura(102351, nil, 'LEFT', {0.2, 0.8, 0.8}), -- Cenarion Ward (Initial Buff)
		[102352]	= Aura(102352, nil, 'LEFT', {0.2, 0.8, 0.8}), -- Cenarion Ward (HoT)
		[200389]	= Aura(200389, nil, 'BOTTOM', {1, 1, 0.4}), -- Cultivation
		[203554]	= Aura(203554, nil, 'TOP', {1, 1, 0.4}), -- Focused Growth (PvP)
	},
	PALADIN = {
		[53563]		= Aura(53563, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Light
		[156910]	= Aura(156910, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Faith
		[200025]	= Aura(200025, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Virtue
		[1022]		= Aura(1022, nil, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), -- Blessing of Protection
		[1044]		= Aura(1044, nil, 'BOTTOMRIGHT', {0.89, 0.45, 0}, true), -- Blessing of Freedom
		[6940]		= Aura(6940, nil, 'BOTTOMRIGHT', {0.89, 0.1, 0.1}, true), -- Blessing of Sacrifice
		[204018]	= Aura(204018, nil, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), -- Blessing of Spellwarding
		[223306]	= Aura(223306, nil, 'BOTTOMLEFT', {0.7, 0.7, 0.3}), -- Bestow Faith
		[287280]	= Aura(287280, nil, 'TOPLEFT', {0.2, 0.8, 0.2}), -- Glimmer of Light (T50 Talent)
		[157047]	= Aura(157047, nil, 'TOP', {0.15, 0.58, 0.84}), -- Saved by the Light (T25 Talent)
	},
	SHAMAN = {
		[61295]		= Aura(61295, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Riptide
		[974]		= Aura(974, nil, 'BOTTOMRIGHT', {0.2, 0.2, 1}), -- Earth Shield
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
	-- Keep those for reference to G.unitframe.aurawatch[E.myclass][SomeValue]
	WARLOCK = {},
	MAGE = {},
	DEATHKNIGHT = {},
	DEMONHUNTER = {},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Racials
	[291944]	= 6, -- Regeneratin (Zandalari)
	-- Warlock
	[198590]	= 5, -- Drain Soul
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

-- Spells Effected By Talents
G.unitframe.TalentChannelTicks = {
	-- Priest
	[47757]	= {tier = 1, column = 1, ticks = 4}, -- Penance (Heal)
	[47758]	= {tier = 1, column = 1, ticks = 4}, -- Penance (DPS)
}

G.unitframe.ChannelTicksSize = {
	-- Warlock
	[198590]	= 1, -- Drain Soul
	-- Mage
	[205021]	= 1, -- Ray of Frost
}

-- Spells Effected By Haste, these spells require a Tick Size (table above)
G.unitframe.HastedChannelTicks = {
	-- Mage
	[205021]	= true, -- Ray of Frost
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825]	= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Bloodlust
	[32182]	= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Heroism
	[80353]	= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Time Warp
	[90355]	= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Ancient Hysteria
}

G.unitframe.AuraHighlightColors = {}
