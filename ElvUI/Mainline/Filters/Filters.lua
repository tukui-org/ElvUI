local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Death Knight
		[47476]		= UF:FilterList_Defaults(2), -- Strangulate
		[108194]	= UF:FilterList_Defaults(4), -- Asphyxiate UH
		[221562]	= UF:FilterList_Defaults(4), -- Asphyxiate Blood
		[207171]	= UF:FilterList_Defaults(4), -- Winter is Coming
		[206961]	= UF:FilterList_Defaults(3), -- Tremble Before Me
		[207167]	= UF:FilterList_Defaults(4), -- Blinding Sleet
		[212540]	= UF:FilterList_Defaults(1), -- Flesh Hook (Pet)
		[91807]		= UF:FilterList_Defaults(1), -- Shambling Rush (Pet)
		[204085]	= UF:FilterList_Defaults(1), -- Deathchill
		[233395]	= UF:FilterList_Defaults(1), -- Frozen Center
		[212332]	= UF:FilterList_Defaults(4), -- Smash (Pet)
		[212337]	= UF:FilterList_Defaults(4), -- Powerful Smash (Pet)
		[91800]		= UF:FilterList_Defaults(4), -- Gnaw (Pet)
		[91797]		= UF:FilterList_Defaults(4), -- Monstrous Blow (Pet)
		[210141]	= UF:FilterList_Defaults(3), -- Zombie Explosion
	-- Demon Hunter
		[207685]	= UF:FilterList_Defaults(4), -- Sigil of Misery
		[217832]	= UF:FilterList_Defaults(3), -- Imprison
		[221527]	= UF:FilterList_Defaults(5), -- Imprison (Banished version)
		[204490]	= UF:FilterList_Defaults(2), -- Sigil of Silence
		[179057]	= UF:FilterList_Defaults(3), -- Chaos Nova
		[211881]	= UF:FilterList_Defaults(4), -- Fel Eruption
		[205630]	= UF:FilterList_Defaults(3), -- Illidan's Grasp
		[208618]	= UF:FilterList_Defaults(3), -- Illidan's Grasp (Afterward)
		[213491]	= UF:FilterList_Defaults(4), -- Demonic Trample (it's this one or the other)
		[208645]	= UF:FilterList_Defaults(4), -- Demonic Trample
	-- Druid
		[81261]		= UF:FilterList_Defaults(2), -- Solar Beam
		[5211]		= UF:FilterList_Defaults(4), -- Mighty Bash
		[163505]	= UF:FilterList_Defaults(4), -- Rake
		[203123]	= UF:FilterList_Defaults(4), -- Maim
		[202244]	= UF:FilterList_Defaults(4), -- Overrun
		[99]		= UF:FilterList_Defaults(4), -- Incapacitating Roar
		[33786]		= UF:FilterList_Defaults(5), -- Cyclone
		[45334]		= UF:FilterList_Defaults(1), -- Immobilized
		[102359]	= UF:FilterList_Defaults(1), -- Mass Entanglement
		[339]		= UF:FilterList_Defaults(1), -- Entangling Roots
		[2637]		= UF:FilterList_Defaults(1), -- Hibernate
		[102793]	= UF:FilterList_Defaults(1), -- Ursol's Vortex
	-- Hunter
		[202933]	= UF:FilterList_Defaults(2), -- Spider Sting (it's this one or the other)
		[233022]	= UF:FilterList_Defaults(2), -- Spider Sting
		[213691]	= UF:FilterList_Defaults(4), -- Scatter Shot
		[19386]		= UF:FilterList_Defaults(3), -- Wyvern Sting
		[3355]		= UF:FilterList_Defaults(3), -- Freezing Trap
		[203337]	= UF:FilterList_Defaults(5), -- Freezing Trap (Survival PvPT)
		[209790]	= UF:FilterList_Defaults(3), -- Freezing Arrow
		[24394]		= UF:FilterList_Defaults(4), -- Intimidation
		[117526]	= UF:FilterList_Defaults(4), -- Binding Shot
		[190927]	= UF:FilterList_Defaults(1), -- Harpoon
		[201158]	= UF:FilterList_Defaults(1), -- Super Sticky Tar
		[162480]	= UF:FilterList_Defaults(1), -- Steel Trap
		[212638]	= UF:FilterList_Defaults(1), -- Tracker's Net
		[200108]	= UF:FilterList_Defaults(1), -- Ranger's Net
	-- Mage
		[61721]		= UF:FilterList_Defaults(3), -- Rabbit (Poly)
		[61305]		= UF:FilterList_Defaults(3), -- Black Cat (Poly)
		[28272]		= UF:FilterList_Defaults(3), -- Pig (Poly)
		[28271]		= UF:FilterList_Defaults(3), -- Turtle (Poly)
		[126819]	= UF:FilterList_Defaults(3), -- Porcupine (Poly)
		[161354]	= UF:FilterList_Defaults(3), -- Monkey (Poly)
		[161353]	= UF:FilterList_Defaults(3), -- Polar bear (Poly)
		[61780]		= UF:FilterList_Defaults(3), -- Turkey (Poly)
		[161355]	= UF:FilterList_Defaults(3), -- Penguin (Poly)
		[161372]	= UF:FilterList_Defaults(3), -- Peacock (Poly)
		[277787]	= UF:FilterList_Defaults(3), -- Direhorn (Poly)
		[277792]	= UF:FilterList_Defaults(3), -- Bumblebee (Poly)
		[118]		= UF:FilterList_Defaults(3), -- Polymorph
		[82691]		= UF:FilterList_Defaults(3), -- Ring of Frost
		[31661]		= UF:FilterList_Defaults(3), -- Dragon's Breath
		[122]		= UF:FilterList_Defaults(1), -- Frost Nova
		[33395]		= UF:FilterList_Defaults(1), -- Freeze
		[157997]	= UF:FilterList_Defaults(1), -- Ice Nova
		[228600]	= UF:FilterList_Defaults(1), -- Glacial Spike
		[198121]	= UF:FilterList_Defaults(1), -- Frostbite
	-- Monk
		[119381]	= UF:FilterList_Defaults(4), -- Leg Sweep
		[202346]	= UF:FilterList_Defaults(4), -- Double Barrel
		[115078]	= UF:FilterList_Defaults(4), -- Paralysis
		[198909]	= UF:FilterList_Defaults(3), -- Song of Chi-Ji
		[202274]	= UF:FilterList_Defaults(3), -- Incendiary Brew
		[233759]	= UF:FilterList_Defaults(2), -- Grapple Weapon
		[123407]	= UF:FilterList_Defaults(1), -- Spinning Fire Blossom
		[116706]	= UF:FilterList_Defaults(1), -- Disable
		[232055]	= UF:FilterList_Defaults(4), -- Fists of Fury (it's this one or the other)
	-- Paladin
		[853]		= UF:FilterList_Defaults(3), -- Hammer of Justice
		[20066]		= UF:FilterList_Defaults(3), -- Repentance
		[105421]	= UF:FilterList_Defaults(3), -- Blinding Light
		[31935]		= UF:FilterList_Defaults(2), -- Avenger's Shield
		[217824]	= UF:FilterList_Defaults(2), -- Shield of Virtue
		[205290]	= UF:FilterList_Defaults(3), -- Wake of Ashes
	-- Priest
		[9484]		= UF:FilterList_Defaults(3), -- Shackle Undead
		[200196]	= UF:FilterList_Defaults(4), -- Holy Word: Chastise
		[200200]	= UF:FilterList_Defaults(4), -- Holy Word: Chastise
		[226943]	= UF:FilterList_Defaults(3), -- Mind Bomb
		[605]		= UF:FilterList_Defaults(5), -- Mind Control
		[8122]		= UF:FilterList_Defaults(3), -- Psychic Scream
		[15487]		= UF:FilterList_Defaults(2), -- Silence
		[64044]		= UF:FilterList_Defaults(1), -- Psychic Horror
		[453]		= UF:FilterList_Defaults(5), -- Mind Soothe
	-- Rogue
		[2094]		= UF:FilterList_Defaults(4), -- Blind
		[6770]		= UF:FilterList_Defaults(4), -- Sap
		[1776]		= UF:FilterList_Defaults(4), -- Gouge
		[1330]		= UF:FilterList_Defaults(2), -- Garrote - Silence
		[207777]	= UF:FilterList_Defaults(2), -- Dismantle
		[199804]	= UF:FilterList_Defaults(4), -- Between the Eyes
		[408]		= UF:FilterList_Defaults(4), -- Kidney Shot
		[1833]		= UF:FilterList_Defaults(4), -- Cheap Shot
		[207736]	= UF:FilterList_Defaults(5), -- Shadowy Duel (Smoke effect)
		[212182]	= UF:FilterList_Defaults(5), -- Smoke Bomb
	-- Shaman
		[51514]		= UF:FilterList_Defaults(3), -- Hex
		[211015]	= UF:FilterList_Defaults(3), -- Hex (Cockroach)
		[211010]	= UF:FilterList_Defaults(3), -- Hex (Snake)
		[211004]	= UF:FilterList_Defaults(3), -- Hex (Spider)
		[210873]	= UF:FilterList_Defaults(3), -- Hex (Compy)
		[196942]	= UF:FilterList_Defaults(3), -- Hex (Voodoo Totem)
		[269352]	= UF:FilterList_Defaults(3), -- Hex (Skeletal Hatchling)
		[277778]	= UF:FilterList_Defaults(3), -- Hex (Zandalari Tendonripper)
		[277784]	= UF:FilterList_Defaults(3), -- Hex (Wicker Mongrel)
		[118905]	= UF:FilterList_Defaults(3), -- Static Charge
		[77505]		= UF:FilterList_Defaults(4), -- Earthquake (Knocking down)
		[118345]	= UF:FilterList_Defaults(4), -- Pulverize (Pet)
		[204399]	= UF:FilterList_Defaults(3), -- Earthfury
		[204437]	= UF:FilterList_Defaults(3), -- Lightning Lasso
		[157375]	= UF:FilterList_Defaults(4), -- Gale Force
		[64695]		= UF:FilterList_Defaults(1), -- Earthgrab
	-- Warlock
		[710]		= UF:FilterList_Defaults(5), -- Banish
		[6789]		= UF:FilterList_Defaults(3), -- Mortal Coil
		[118699]	= UF:FilterList_Defaults(3), -- Fear
		[6358]		= UF:FilterList_Defaults(3), -- Seduction (Succub)
		[171017]	= UF:FilterList_Defaults(4), -- Meteor Strike (Infernal)
		[22703]		= UF:FilterList_Defaults(4), -- Infernal Awakening (Infernal CD)
		[30283]		= UF:FilterList_Defaults(3), -- Shadowfury
		[89766]		= UF:FilterList_Defaults(4), -- Axe Toss
		[233582]	= UF:FilterList_Defaults(1), -- Entrenched in Flame
	-- Warrior
		[5246]		= UF:FilterList_Defaults(4), -- Intimidating Shout
		[132169]	= UF:FilterList_Defaults(4), -- Storm Bolt
		[132168]	= UF:FilterList_Defaults(4), -- Shockwave
		[199085]	= UF:FilterList_Defaults(4), -- Warpath
		[105771]	= UF:FilterList_Defaults(1), -- Charge
		[199042]	= UF:FilterList_Defaults(1), -- Thunderstruck
		[236077]	= UF:FilterList_Defaults(2), -- Disarm
	-- Racial
		[20549]		= UF:FilterList_Defaults(4), -- War Stomp
		[107079]	= UF:FilterList_Defaults(4), -- Quaking Palm
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Death Knight
		[48707]		= UF:FilterList_Defaults(), -- Anti-Magic Shell
		[81256]		= UF:FilterList_Defaults(), -- Dancing Rune Weapon
		[55233]		= UF:FilterList_Defaults(), -- Vampiric Blood
		[193320]	= UF:FilterList_Defaults(), -- Umbilicus Eternus
		[219809]	= UF:FilterList_Defaults(), -- Tombstone
		[48792]		= UF:FilterList_Defaults(), -- Icebound Fortitude
		[207319]	= UF:FilterList_Defaults(), -- Corpse Shield
		[194844]	= UF:FilterList_Defaults(), -- BoneStorm
		[145629]	= UF:FilterList_Defaults(), -- Anti-Magic Zone
		[194679]	= UF:FilterList_Defaults(), -- Rune Tap
	-- Demon Hunter
		[207811]	= UF:FilterList_Defaults(), -- Nether Bond (DH)
		[207810]	= UF:FilterList_Defaults(), -- Nether Bond (Target)
		[187827]	= UF:FilterList_Defaults(), -- Metamorphosis
		[263648]	= UF:FilterList_Defaults(), -- Soul Barrier
		[209426]	= UF:FilterList_Defaults(), -- Darkness
		[196555]	= UF:FilterList_Defaults(), -- Netherwalk
		[212800]	= UF:FilterList_Defaults(), -- Blur
		[188499]	= UF:FilterList_Defaults(), -- Blade Dance
		[203819]	= UF:FilterList_Defaults(), -- Demon Spikes
	-- Druid
		[102342]	= UF:FilterList_Defaults(), -- Ironbark
		[61336]		= UF:FilterList_Defaults(), -- Survival Instincts
		[210655]	= UF:FilterList_Defaults(), -- Protection of Ashamane
		[22812]		= UF:FilterList_Defaults(), -- Barkskin
		[200851]	= UF:FilterList_Defaults(), -- Rage of the Sleeper
		[234081]	= UF:FilterList_Defaults(), -- Celestial Guardian
		[202043]	= UF:FilterList_Defaults(), -- Protector of the Pack (it's this one or the other)
		[201940]	= UF:FilterList_Defaults(), -- Protector of the Pack
		[201939]	= UF:FilterList_Defaults(), -- Protector of the Pack (Allies)
		[192081]	= UF:FilterList_Defaults(), -- Ironfur
		[50334]		= UF:FilterList_Defaults(), -- Berserk (Guardian)
	-- Hunter
		[186265]	= UF:FilterList_Defaults(), -- Aspect of the Turtle
		[53480]		= UF:FilterList_Defaults(), -- Roar of Sacrifice
		[202748]	= UF:FilterList_Defaults(), -- Survival Tactics
	-- Mage
		[45438]		= UF:FilterList_Defaults(), -- Ice Block
		[113862]	= UF:FilterList_Defaults(), -- Greater Invisibility
		[198111]	= UF:FilterList_Defaults(), -- Temporal Shield
		[198065]	= UF:FilterList_Defaults(), -- Prismatic Cloak
		[11426]		= UF:FilterList_Defaults(), -- Ice Barrier
		[235313]	= UF:FilterList_Defaults(), -- Blazing Barrier
		[235450]	= UF:FilterList_Defaults(), -- Prismatic Barrier
		[110909]	= UF:FilterList_Defaults(), -- Alter Time
	-- Monk
		[122783]	= UF:FilterList_Defaults(), -- Diffuse Magic
		[122278]	= UF:FilterList_Defaults(), -- Dampen Harm
		[125174]	= UF:FilterList_Defaults(), -- Touch of Karma
		[201318]	= UF:FilterList_Defaults(), -- Fortifying Elixir
		[202248]	= UF:FilterList_Defaults(), -- Guided Meditation
		[120954]	= UF:FilterList_Defaults(), -- Fortifying Brew
		[116849]	= UF:FilterList_Defaults(), -- Life Cocoon
		[202162]	= UF:FilterList_Defaults(), -- Guard
		[215479]	= UF:FilterList_Defaults(), -- Ironskin Brew
		[353319]	= UF:FilterList_Defaults(), -- Peaceweaver (PvP)
		[353362]	= UF:FilterList_Defaults(), -- Dematerialize (PvP)
	-- Paladin
		[642]		= UF:FilterList_Defaults(), -- Divine Shield
		[498]		= UF:FilterList_Defaults(), -- Divine Protection
		[205191]	= UF:FilterList_Defaults(), -- Eye for an Eye
		[184662]	= UF:FilterList_Defaults(), -- Shield of Vengeance
		[1022]		= UF:FilterList_Defaults(), -- Blessing of Protection
		[6940]		= UF:FilterList_Defaults(), -- Blessing of Sacrifice
		[204018]	= UF:FilterList_Defaults(), -- Blessing of Spellwarding
		[199507]	= UF:FilterList_Defaults(), -- Spreading The Word: Protection
		[216857]	= UF:FilterList_Defaults(), -- Guarded by the Light
		[228049]	= UF:FilterList_Defaults(), -- Guardian of the Forgotten Queen
		[31850]		= UF:FilterList_Defaults(), -- Ardent Defender
		[86659]		= UF:FilterList_Defaults(), -- Guardian of Ancien Kings
		[212641]	= UF:FilterList_Defaults(), -- Guardian of Ancien Kings (Glyph of the Queen)
		[209388]	= UF:FilterList_Defaults(), -- Bulwark of Order
		[152262]	= UF:FilterList_Defaults(), -- Seraphim
		[132403]	= UF:FilterList_Defaults(), -- Shield of the Righteous
	-- Priest
		[81782]		= UF:FilterList_Defaults(), -- Power Word: Barrier
		[47585]		= UF:FilterList_Defaults(), -- Dispersion
		[19236]		= UF:FilterList_Defaults(), -- Desperate Prayer
		[213602]	= UF:FilterList_Defaults(), -- Greater Fade
		[27827]		= UF:FilterList_Defaults(), -- Spirit of Redemption
		[197268]	= UF:FilterList_Defaults(), -- Ray of Hope
		[47788]		= UF:FilterList_Defaults(), -- Guardian Spirit
		[33206]		= UF:FilterList_Defaults(), -- Pain Suppression
	-- Rogue
		[5277]		= UF:FilterList_Defaults(), -- Evasion
		[31224]		= UF:FilterList_Defaults(), -- Cloak of Shadows
		[1966]		= UF:FilterList_Defaults(), -- Feint
		[199754]	= UF:FilterList_Defaults(), -- Riposte
		[45182]		= UF:FilterList_Defaults(), -- Cheating Death
		[199027]	= UF:FilterList_Defaults(), -- Veil of Midnight
	-- Shaman
		[325174]	= UF:FilterList_Defaults(), -- Spirit Link
		[974]		= UF:FilterList_Defaults(), -- Earth Shield
		[210918]	= UF:FilterList_Defaults(), -- Ethereal Form
		[207654]	= UF:FilterList_Defaults(), -- Servant of the Queen
		[108271]	= UF:FilterList_Defaults(), -- Astral Shift
		[207498]	= UF:FilterList_Defaults(), -- Ancestral Protection
	-- Warlock
		[108416]	= UF:FilterList_Defaults(), -- Dark Pact
		[104773]	= UF:FilterList_Defaults(), -- Unending Resolve
		[221715]	= UF:FilterList_Defaults(), -- Essence Drain
		[212295]	= UF:FilterList_Defaults(), -- Nether Ward
	-- Warrior
		[118038]	= UF:FilterList_Defaults(), -- Die by the Sword
		[184364]	= UF:FilterList_Defaults(), -- Enraged Regeneration
		[209484]	= UF:FilterList_Defaults(), -- Tactical Advance
		[97463]		= UF:FilterList_Defaults(), -- Commanding Shout
		[213915]	= UF:FilterList_Defaults(), -- Mass Spell Reflection
		[199038]	= UF:FilterList_Defaults(), -- Leave No Man Behind
		[223658]	= UF:FilterList_Defaults(), -- Safeguard
		[147833]	= UF:FilterList_Defaults(), -- Intervene
		[198760]	= UF:FilterList_Defaults(), -- Intercept
		[12975]		= UF:FilterList_Defaults(), -- Last Stand
		[871]		= UF:FilterList_Defaults(), -- Shield Wall
		[23920]		= UF:FilterList_Defaults(), -- Spell Reflection
		[227744]	= UF:FilterList_Defaults(), -- Ravager
		[203524]	= UF:FilterList_Defaults(), -- Neltharion's Fury
		[190456]	= UF:FilterList_Defaults(), -- Ignore Pain
		[132404]	= UF:FilterList_Defaults(), -- Shield Block
	-- Racial
		[65116]		= UF:FilterList_Defaults(), -- Stoneform
	-- Potion
		[251231]	= UF:FilterList_Defaults(), -- Steelskin Potion
	-- Covenant
		[324867]	= UF:FilterList_Defaults(), -- Fleshcraft (Necrolord)
	-- PvP
		[363522]	= UF:FilterList_Defaults(), -- Gladiator's Eternal Aegis
		[362699]	= UF:FilterList_Defaults(), -- Gladiator's Resolve
	},
}

G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	-- Death Knight
		[48707]		= UF:FilterList_Defaults(), -- Anti-Magic Shell
		[81256]		= UF:FilterList_Defaults(), -- Dancing Rune Weapon
		[55233]		= UF:FilterList_Defaults(), -- Vampiric Blood
		[193320]	= UF:FilterList_Defaults(), -- Umbilicus Eternus
		[219809]	= UF:FilterList_Defaults(), -- Tombstone
		[48792]		= UF:FilterList_Defaults(), -- Icebound Fortitude
		[207319]	= UF:FilterList_Defaults(), -- Corpse Shield
		[194844]	= UF:FilterList_Defaults(), -- BoneStorm
		[145629]	= UF:FilterList_Defaults(), -- Anti-Magic Zone
		[194679]	= UF:FilterList_Defaults(), -- Rune Tap
		[51271]		= UF:FilterList_Defaults(), -- Pillar of Frost
		[207256]	= UF:FilterList_Defaults(), -- Obliteration
		[152279]	= UF:FilterList_Defaults(), -- Breath of Sindragosa
		[233411]	= UF:FilterList_Defaults(), -- Blood for Blood
		[212552]	= UF:FilterList_Defaults(), -- Wraith Walk
		[343294]	= UF:FilterList_Defaults(), -- Soul Reaper
		[194918]	= UF:FilterList_Defaults(), -- Blighted Rune Weapon
		[48265]		= UF:FilterList_Defaults(), -- Death's Advance
		[49039]		= UF:FilterList_Defaults(), -- Lichborne
		[47568]		= UF:FilterList_Defaults(), -- Empower Rune Weapon
	-- Demon Hunter
		[207811]	= UF:FilterList_Defaults(), -- Nether Bond (DH)
		[207810]	= UF:FilterList_Defaults(), -- Nether Bond (Target)
		[187827]	= UF:FilterList_Defaults(), -- Metamorphosis
		[263648]	= UF:FilterList_Defaults(), -- Soul Barrier
		[209426]	= UF:FilterList_Defaults(), -- Darkness
		[196555]	= UF:FilterList_Defaults(), -- Netherwalk
		[212800]	= UF:FilterList_Defaults(), -- Blur
		[188499]	= UF:FilterList_Defaults(), -- Blade Dance
		[203819]	= UF:FilterList_Defaults(), -- Demon Spikes
		[206804]	= UF:FilterList_Defaults(), -- Rain from Above
		[211510]	= UF:FilterList_Defaults(), -- Solitude
		[162264]	= UF:FilterList_Defaults(), -- Metamorphosis
		[205629]	= UF:FilterList_Defaults(), -- Demonic Trample
		[188501]	= UF:FilterList_Defaults(), -- Spectral Sight
	-- Druid
		[102342]	= UF:FilterList_Defaults(), -- Ironbark
		[61336]		= UF:FilterList_Defaults(), -- Survival Instincts
		[210655]	= UF:FilterList_Defaults(), -- Protection of Ashamane
		[22812]		= UF:FilterList_Defaults(), -- Barkskin
		[200851]	= UF:FilterList_Defaults(), -- Rage of the Sleeper
		[234081]	= UF:FilterList_Defaults(), -- Celestial Guardian
		[202043]	= UF:FilterList_Defaults(), -- Protector of the Pack (it's this one or the other)
		[201940]	= UF:FilterList_Defaults(), -- Protector of the Pack
		[201939]	= UF:FilterList_Defaults(), -- Protector of the Pack (Allies)
		[192081]	= UF:FilterList_Defaults(), -- Ironfur
		[29166]		= UF:FilterList_Defaults(), -- Innervate
		[208253]	= UF:FilterList_Defaults(), -- Essence of G'Hanir
		[194223]	= UF:FilterList_Defaults(), -- Celestial Alignment
		[102560]	= UF:FilterList_Defaults(), -- Incarnation: Chosen of Elune
		[102543]	= UF:FilterList_Defaults(), -- Incarnation: King of the Jungle
		[102558]	= UF:FilterList_Defaults(), -- Incarnation: Guardian of Ursoc
		[117679]	= UF:FilterList_Defaults(), -- Incarnation
		[106951]	= UF:FilterList_Defaults(), -- Berserk (Feral)
		[50334]		= UF:FilterList_Defaults(), -- Berserk (Guardian)
		[5217]		= UF:FilterList_Defaults(), -- Tiger's Fury
		[1850]		= UF:FilterList_Defaults(), -- Dash
		[137452]	= UF:FilterList_Defaults(), -- Displacer Beast
		[102416]	= UF:FilterList_Defaults(), -- Wild Charge
		[77764]		= UF:FilterList_Defaults(), -- Stampeding Roar (Cat)
		[77761]		= UF:FilterList_Defaults(), -- Stampeding Roar (Bear)
		[305497]	= UF:FilterList_Defaults(), -- Thorns
		[234084]	= UF:FilterList_Defaults(), -- Moon and Stars (PvP)
		[22842]		= UF:FilterList_Defaults(), -- Frenzied Regeneration
	-- Hunter
		[186265]	= UF:FilterList_Defaults(), -- Aspect of the Turtle
		[53480]		= UF:FilterList_Defaults(), -- Roar of Sacrifice
		[202748]	= UF:FilterList_Defaults(), -- Survival Tactics
		[62305]		= UF:FilterList_Defaults(), -- Master's Call (it's this one or the other)
		[54216]		= UF:FilterList_Defaults(), -- Master's Call
		[288613]	= UF:FilterList_Defaults(), -- Trueshot
		[260402]	= UF:FilterList_Defaults(), -- Double Tap
		[193530]	= UF:FilterList_Defaults(), -- Aspect of the Wild
		[19574]		= UF:FilterList_Defaults(), -- Bestial Wrath
		[186289]	= UF:FilterList_Defaults(), -- Aspect of the Eagle
		[186257]	= UF:FilterList_Defaults(), -- Aspect of the Cheetah
		[118922]	= UF:FilterList_Defaults(), -- Posthaste
		[90355]		= UF:FilterList_Defaults(), -- Ancient Hysteria (Pet)
		[160452]	= UF:FilterList_Defaults(), -- Netherwinds (Pet)
		[266779]	= UF:FilterList_Defaults(), -- Coordinated Assault
	-- Mage
		[45438]		= UF:FilterList_Defaults(), -- Ice Block
		[113862]	= UF:FilterList_Defaults(), -- Greater Invisibility
		[198111]	= UF:FilterList_Defaults(), -- Temporal Shield
		[198065]	= UF:FilterList_Defaults(), -- Prismatic Cloak
		[11426]		= UF:FilterList_Defaults(), -- Ice Barrier
		[235313]	= UF:FilterList_Defaults(), -- Blazing Barrier
		[235450]	= UF:FilterList_Defaults(), -- Prismatic Barrier
		[110909]	= UF:FilterList_Defaults(), -- Alter Time
		[190319]	= UF:FilterList_Defaults(), -- Combustion
		[80353]		= UF:FilterList_Defaults(), -- Time Warp
		[12472]		= UF:FilterList_Defaults(), -- Icy Veins
		[12042]		= UF:FilterList_Defaults(), -- Arcane Power
		[116014]	= UF:FilterList_Defaults(), -- Rune of Power
		[198144]	= UF:FilterList_Defaults(), -- Ice Form
		[108839]	= UF:FilterList_Defaults(), -- Ice Floes
		[205025]	= UF:FilterList_Defaults(), -- Presence of Mind
		[198158]	= UF:FilterList_Defaults(), -- Mass Invisibility
		[221404]	= UF:FilterList_Defaults(), -- Burning Determination
		[324220]	= UF:FilterList_Defaults(), -- Deathborne (Covenant/Necrolord)
	-- Monk
		[122783]	= UF:FilterList_Defaults(), -- Diffuse Magic
		[122278]	= UF:FilterList_Defaults(), -- Dampen Harm
		[125174]	= UF:FilterList_Defaults(), -- Touch of Karma
		[201318]	= UF:FilterList_Defaults(), -- Fortifying Elixir
		[202248]	= UF:FilterList_Defaults(), -- Guided Meditation
		[120954]	= UF:FilterList_Defaults(), -- Fortifying Brew
		[116849]	= UF:FilterList_Defaults(), -- Life Cocoon
		[202162]	= UF:FilterList_Defaults(), -- Guard
		[215479]	= UF:FilterList_Defaults(), -- Ironskin Brew
		[152173]	= UF:FilterList_Defaults(), -- Serenity
		[137639]	= UF:FilterList_Defaults(), -- Storm, Earth, and Fire
		[213664]	= UF:FilterList_Defaults(), -- Nimble Brew
		[201447]	= UF:FilterList_Defaults(), -- Ride the Wind
		[195381]	= UF:FilterList_Defaults(), -- Healing Winds
		[116841]	= UF:FilterList_Defaults(), -- Tiger's Lust
		[119085]	= UF:FilterList_Defaults(), -- Chi Torpedo
		[199407]	= UF:FilterList_Defaults(), -- Light on Your Feet
		[209584]	= UF:FilterList_Defaults(), -- Zen Focus Tea
	-- Paladin
		[642]		= UF:FilterList_Defaults(), -- Divine Shield
		[498]		= UF:FilterList_Defaults(), -- Divine Protection
		[205191]	= UF:FilterList_Defaults(), -- Eye for an Eye
		[184662]	= UF:FilterList_Defaults(), -- Shield of Vengeance
		[1022]		= UF:FilterList_Defaults(), -- Blessing of Protection
		[6940]		= UF:FilterList_Defaults(), -- Blessing of Sacrifice
		[204018]	= UF:FilterList_Defaults(), -- Blessing of Spellwarding
		[199507]	= UF:FilterList_Defaults(), -- Spreading The Word: Protection
		[216857]	= UF:FilterList_Defaults(), -- Guarded by the Light
		[228049]	= UF:FilterList_Defaults(), -- Guardian of the Forgotten Queen
		[31850]		= UF:FilterList_Defaults(), -- Ardent Defender
		[86659]		= UF:FilterList_Defaults(), -- Guardian of Ancien Kings
		[212641]	= UF:FilterList_Defaults(), -- Guardian of Ancien Kings (Glyph of the Queen)
		[209388]	= UF:FilterList_Defaults(), -- Bulwark of Order
		[152262]	= UF:FilterList_Defaults(), -- Seraphim
		[132403]	= UF:FilterList_Defaults(), -- Shield of the Righteous
		[31884]		= UF:FilterList_Defaults(), -- Avenging Wrath
		[105809]	= UF:FilterList_Defaults(), -- Holy Avenger
		[231895]	= UF:FilterList_Defaults(), -- Crusade
		[200652]	= UF:FilterList_Defaults(), -- Tyr's Deliverance
		[216331]	= UF:FilterList_Defaults(), -- Avenging Crusader
		[1044]		= UF:FilterList_Defaults(), -- Blessing of Freedom
		[305395] 	= UF:FilterList_Defaults(), -- Blessing of Freedom (Unbound Freedom - Ret/Prot PvP)
		[210256]	= UF:FilterList_Defaults(), -- Blessing of Sanctuary
		[199545]	= UF:FilterList_Defaults(), -- Steed of Glory
		[210294]	= UF:FilterList_Defaults(), -- Divine Favor
		[221886]	= UF:FilterList_Defaults(), -- Divine Steed
		[31821]		= UF:FilterList_Defaults(), -- Aura Mastery
	-- Priest
		[81782]		= UF:FilterList_Defaults(), -- Power Word: Barrier
		[47585]		= UF:FilterList_Defaults(), -- Dispersion
		[19236]		= UF:FilterList_Defaults(), -- Desperate Prayer
		[213602]	= UF:FilterList_Defaults(), -- Greater Fade
		[27827]		= UF:FilterList_Defaults(), -- Spirit of Redemption
		[197268]	= UF:FilterList_Defaults(), -- Ray of Hope
		[47788]		= UF:FilterList_Defaults(), -- Guardian Spirit
		[33206]		= UF:FilterList_Defaults(), -- Pain Suppression
		[200183]	= UF:FilterList_Defaults(), -- Apotheosis
		[10060]		= UF:FilterList_Defaults(), -- Power Infusion
		[47536]		= UF:FilterList_Defaults(), -- Rapture
		[194249]	= UF:FilterList_Defaults(), -- Voidform
		[193223]	= UF:FilterList_Defaults(), -- Surrdender to Madness
		[197862]	= UF:FilterList_Defaults(), -- Archangel
		[197871]	= UF:FilterList_Defaults(), -- Dark Archangel
		[197874]	= UF:FilterList_Defaults(), -- Dark Archangel
		[215769]	= UF:FilterList_Defaults(), -- Spirit of Redemption
		[213610]	= UF:FilterList_Defaults(), -- Holy Ward
		[121557]	= UF:FilterList_Defaults(), -- Angelic Feather
		[214121]	= UF:FilterList_Defaults(), -- Body and Mind
		[65081]		= UF:FilterList_Defaults(), -- Body and Soul
		[197767]	= UF:FilterList_Defaults(), -- Speed of the Pious
		[210980]	= UF:FilterList_Defaults(), -- Focus in the Light
		[221660]	= UF:FilterList_Defaults(), -- Holy Concentration
		[15286]		= UF:FilterList_Defaults(), -- Vampiric Embrace
	-- Rogue
		[5277]		= UF:FilterList_Defaults(), -- Evasion
		[31224]		= UF:FilterList_Defaults(), -- Cloak of Shadows
		[1966]		= UF:FilterList_Defaults(), -- Feint
		[199754]	= UF:FilterList_Defaults(), -- Riposte
		[45182]		= UF:FilterList_Defaults(), -- Cheating Death
		[199027]	= UF:FilterList_Defaults(), -- Veil of Midnight
		[121471]	= UF:FilterList_Defaults(), -- Shadow Blades
		[13750]		= UF:FilterList_Defaults(), -- Adrenaline Rush
		[51690]		= UF:FilterList_Defaults(), -- Killing Spree
		[185422]	= UF:FilterList_Defaults(), -- Shadow Dance
		[198368]	= UF:FilterList_Defaults(), -- Take Your Cut
		[198027]	= UF:FilterList_Defaults(), -- Turn the Tables
		[213985]	= UF:FilterList_Defaults(), -- Thief's Bargain
		[197003]	= UF:FilterList_Defaults(), -- Maneuverability
		[212198]	= UF:FilterList_Defaults(), -- Crimson Vial
		[185311]	= UF:FilterList_Defaults(), -- Crimson Vial
		[209754]	= UF:FilterList_Defaults(), -- Boarding Party
		[36554]		= UF:FilterList_Defaults(), -- Shadowstep
		[2983]		= UF:FilterList_Defaults(), -- Sprint
		[202665]	= UF:FilterList_Defaults(), -- Curse of the Dreadblades (Self Debuff)
	-- Shaman
		[325174]	= UF:FilterList_Defaults(), -- Spirit Link
		[974]		= UF:FilterList_Defaults(), -- Earth Shield
		[210918]	= UF:FilterList_Defaults(), -- Ethereal Form
		[207654]	= UF:FilterList_Defaults(), -- Servant of the Queen
		[108271]	= UF:FilterList_Defaults(), -- Astral Shift
		[207498]	= UF:FilterList_Defaults(), -- Ancestral Protection
		[204366]	= UF:FilterList_Defaults(), -- Thundercharge
		[209385]	= UF:FilterList_Defaults(), -- Windfury Totem
		[208963]	= UF:FilterList_Defaults(), -- Skyfury Totem
		[204945]	= UF:FilterList_Defaults(), -- Doom Winds
		[205495]	= UF:FilterList_Defaults(), -- Stormkeeper
		[208416]	= UF:FilterList_Defaults(), -- Sense of Urgency
		[2825]		= UF:FilterList_Defaults(), -- Bloodlust
		[16166]		= UF:FilterList_Defaults(), -- Elemental Mastery
		[167204]	= UF:FilterList_Defaults(), -- Feral Spirit
		[114050]	= UF:FilterList_Defaults(), -- Ascendance (Elem)
		[114051]	= UF:FilterList_Defaults(), -- Ascendance (Enh)
		[114052]	= UF:FilterList_Defaults(), -- Ascendance (Resto)
		[79206]		= UF:FilterList_Defaults(), -- Spiritwalker's Grace
		[58875]		= UF:FilterList_Defaults(), -- Spirit Walk
		[157384]	= UF:FilterList_Defaults(), -- Eye of the Storm
		[192082]	= UF:FilterList_Defaults(), -- Wind Rush
		[2645]		= UF:FilterList_Defaults(), -- Ghost Wolf
		[32182]		= UF:FilterList_Defaults(), -- Heroism
		[108281]	= UF:FilterList_Defaults(), -- Ancestral Guidance
	-- Warlock
		[108416]	= UF:FilterList_Defaults(), -- Dark Pact
		[113860]	= UF:FilterList_Defaults(), -- Dark Soul: Misery
		[113858]	= UF:FilterList_Defaults(), -- Dark Soul: Instability
		[104773]	= UF:FilterList_Defaults(), -- Unending Resolve
		[221715]	= UF:FilterList_Defaults(), -- Essence Drain
		[212295]	= UF:FilterList_Defaults(), -- Nether Ward
		[212284]	= UF:FilterList_Defaults(), -- Firestone
		[196098]	= UF:FilterList_Defaults(), -- Soul Harvest
		[221705]	= UF:FilterList_Defaults(), -- Casting Circle
		[111400]	= UF:FilterList_Defaults(), -- Burning Rush
		[196674]	= UF:FilterList_Defaults(), -- Planeswalker
	-- Warrior
		[118038]	= UF:FilterList_Defaults(), -- Die by the Sword
		[184364]	= UF:FilterList_Defaults(), -- Enraged Regeneration
		[209484]	= UF:FilterList_Defaults(), -- Tactical Advance
		[97463]		= UF:FilterList_Defaults(), -- Commanding Shout
		[213915]	= UF:FilterList_Defaults(), -- Mass Spell Reflection
		[199038]	= UF:FilterList_Defaults(), -- Leave No Man Behind
		[223658]	= UF:FilterList_Defaults(), -- Safeguard
		[147833]	= UF:FilterList_Defaults(), -- Intervene
		[198760]	= UF:FilterList_Defaults(), -- Intercept
		[12975]		= UF:FilterList_Defaults(), -- Last Stand
		[871]		= UF:FilterList_Defaults(), -- Shield Wall
		[23920]		= UF:FilterList_Defaults(), -- Spell Reflection
		[227744]	= UF:FilterList_Defaults(), -- Ravager
		[203524]	= UF:FilterList_Defaults(), -- Neltharion's Fury
		[190456]	= UF:FilterList_Defaults(), -- Ignore Pain
		[132404]	= UF:FilterList_Defaults(), -- Shield Block
		[1719]		= UF:FilterList_Defaults(), -- Battle Cry
		[107574]	= UF:FilterList_Defaults(), -- Avatar
		[227847]	= UF:FilterList_Defaults(), -- Bladestorm (Arm)
		[46924]		= UF:FilterList_Defaults(), -- Bladestorm (Fury)
		[118000]	= UF:FilterList_Defaults(), -- Dragon Roar
		[199261]	= UF:FilterList_Defaults(), -- Death Wish
		[18499]		= UF:FilterList_Defaults(), -- Berserker Rage
		[202164]	= UF:FilterList_Defaults(), -- Bounding Stride
		[215572]	= UF:FilterList_Defaults(), -- Frothing Berserker
		[199203]	= UF:FilterList_Defaults(), -- Thirst for Battle
	-- Racials
		[65116]		= UF:FilterList_Defaults(), -- Stoneform
		[59547]		= UF:FilterList_Defaults(), -- Gift of the Naaru
		[20572]		= UF:FilterList_Defaults(), -- Blood Fury
		[26297]		= UF:FilterList_Defaults(), -- Berserking
		[68992]		= UF:FilterList_Defaults(), -- Darkflight
		[58984]		= UF:FilterList_Defaults(), -- Shadowmeld
	-- General Consumables
		[178207]	= UF:FilterList_Defaults(), -- Drums of Fury
		[230935]	= UF:FilterList_Defaults(), -- Drums of the Mountain (Legion)
		[256740]	= UF:FilterList_Defaults(), -- Drums of the Maelstrom (BfA)
		[321923]	= UF:FilterList_Defaults(), -- Tome of the Still Mind
	-- Shadowlands Consumables
		[307159]	= UF:FilterList_Defaults(), -- Potion of Spectral Agility
		[307160]	= UF:FilterList_Defaults(), -- Potion of Hardened Shadows
		[307161]	= UF:FilterList_Defaults(), -- Potion of Spiritual Clarity
		[307162]	= UF:FilterList_Defaults(), -- Potion of Spectral Intellect
		[307163]	= UF:FilterList_Defaults(), -- Potion of Spectral Stamina
		[307164]	= UF:FilterList_Defaults(), -- Potion of Spectral Strength
		[307165]	= UF:FilterList_Defaults(), -- Spiritual Anti-Venom
		[307185]	= UF:FilterList_Defaults(), -- Spectral Flask of Power
		[307187]	= UF:FilterList_Defaults(), -- Spectral Flask of Stamina
		[307195]	= UF:FilterList_Defaults(), -- Potion of Hidden Spirit
		[307196]	= UF:FilterList_Defaults(), -- Potion of Shaded Sight
		[307199]	= UF:FilterList_Defaults(), -- Potion of Soul Purity
		[307494]	= UF:FilterList_Defaults(), -- Potion of Empowered Exorcisms
		[307495]	= UF:FilterList_Defaults(), -- Potion of Phantom Fire
		[307496]	= UF:FilterList_Defaults(), -- Potion of Divine Awakening
		[307497]	= UF:FilterList_Defaults(), -- Potion of Deathly Fixation
		[307501]	= UF:FilterList_Defaults(), -- Potion of Specter Swiftness
		[308397]	= UF:FilterList_Defaults(), -- Butterscotch Marinated Ribs
		[308402]	= UF:FilterList_Defaults(), -- Surprisingly Palatable Feast
		[308404]	= UF:FilterList_Defaults(), -- Cinnamon Bonefish Stew
		[308412]	= UF:FilterList_Defaults(), -- Meaty Apple Dumplings
		[308425]	= UF:FilterList_Defaults(), -- Sweet Silvergrill Sausages
		[308434]	= UF:FilterList_Defaults(), -- Phantasmal Souffle and Fries
		[308488]	= UF:FilterList_Defaults(), -- Tenebrous Crown Roast Aspic
		[308506]	= UF:FilterList_Defaults(), -- Crawler Ravioli with Apple Sauce
		[308514]	= UF:FilterList_Defaults(), -- Steak a la Mode
		[308525]	= UF:FilterList_Defaults(), -- Banana Beef Pudding
		[308637]	= UF:FilterList_Defaults(), -- Smothered Shank
		[322302]	= UF:FilterList_Defaults(), -- Potion of Sacrificial Anima
		[327708]	= UF:FilterList_Defaults(), -- Feast of Gluttonous Hedonism
		[327715]	= UF:FilterList_Defaults(), -- Fried Bonefish
		[327851]	= UF:FilterList_Defaults(), -- Seraph Tenders
		[354016]	= UF:FilterList_Defaults(), -- Venthyr Tea
	},
}

-- Buffs that we don't really need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
		[8326]		= UF:FilterList_Defaults(), -- Ghost
		[8733]		= UF:FilterList_Defaults(), -- Blessing of Blackfathom
		[15007]		= UF:FilterList_Defaults(), -- Ress Sickness
		[23445]		= UF:FilterList_Defaults(), -- Evil Twin
		[24755]		= UF:FilterList_Defaults(), -- Tricked or Treated
		[25163]		= UF:FilterList_Defaults(), -- Oozeling's Disgusting Aura
		[25771]		= UF:FilterList_Defaults(), -- Forbearance (Pally: Divine Shield, Blessing of Protection, and Lay on Hands)
		[26013]		= UF:FilterList_Defaults(), -- Deserter
		[36032]		= UF:FilterList_Defaults(), -- Arcane Charge
		[36893]		= UF:FilterList_Defaults(), -- Transporter Malfunction
		[36900]		= UF:FilterList_Defaults(), -- Soul Split: Evil!
		[36901]		= UF:FilterList_Defaults(), -- Soul Split: Good
		[41425]		= UF:FilterList_Defaults(), -- Hypothermia
		[55711]		= UF:FilterList_Defaults(), -- Weakened Heart
		[57723]		= UF:FilterList_Defaults(), -- Exhaustion (heroism debuff)
		[57724]		= UF:FilterList_Defaults(), -- Sated (lust debuff)
		[58539]		= UF:FilterList_Defaults(), -- Watcher's Corpse
		[71041]		= UF:FilterList_Defaults(), -- Dungeon Deserter
		[80354]		= UF:FilterList_Defaults(), -- Temporal Displacement (timewarp debuff)
		[89140]		= UF:FilterList_Defaults(), -- Demonic Rebirth: Cooldown
		[95809]		= UF:FilterList_Defaults(), -- Insanity debuff (hunter pet heroism: ancient hysteria)
		[96041]		= UF:FilterList_Defaults(), -- Stink Bombed
		[97821]		= UF:FilterList_Defaults(), -- Void-Touched
		[113942]	= UF:FilterList_Defaults(), -- Demonic: Gateway
		[117870]	= UF:FilterList_Defaults(), -- Touch of The Titans
		[123981]	= UF:FilterList_Defaults(), -- Perdition
		[124273]	= UF:FilterList_Defaults(), -- Stagger
		[124274]	= UF:FilterList_Defaults(), -- Stagger
		[124275]	= UF:FilterList_Defaults(), -- Stagger
		[195776]	= UF:FilterList_Defaults(), -- Moonfeather Fever
		[206150]	= UF:FilterList_Defaults(), -- Challenger's Burden SL
		[206151]	= UF:FilterList_Defaults(), -- Challenger's Burden BfA
		[206662]	= UF:FilterList_Defaults(), -- Experience Eliminated (in range)
		[287825]	= UF:FilterList_Defaults(), -- Lethargy debuff (fight or flight)
		[306600]	= UF:FilterList_Defaults(), -- Experience Eliminated (oor - 5m)
		[313015]	= UF:FilterList_Defaults(), -- Recently Failed (Mechagnome racial)
		[322695]	= UF:FilterList_Defaults(), -- Drained
		[328891]	= UF:FilterList_Defaults(), -- A Gilded Perspective
		[348443]	= UF:FilterList_Defaults(), -- Experience Eliminated
		[234143]	= UF:FilterList_Defaults(), -- Temptation (Upper Karazhan Ring Debuff)
	},
}

-- A list of important buffs that we always want to see
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
		-- Bloodlust effects
		[2825]		= UF:FilterList_Defaults(), -- Bloodlust
		[32182]		= UF:FilterList_Defaults(), -- Heroism
		[80353]		= UF:FilterList_Defaults(), -- Time Warp
		[90355]		= UF:FilterList_Defaults(), -- Ancient Hysteria
		-- Paladin
		[31821]		= UF:FilterList_Defaults(), -- Aura Mastery
		[1022]		= UF:FilterList_Defaults(), -- Blessing of Protection
		[204018]	= UF:FilterList_Defaults(), -- Blessing of Spellwarding
		[6940]		= UF:FilterList_Defaults(), -- Blessing of Sacrifice
		[1044]		= UF:FilterList_Defaults(), -- Blessing of Freedom
		-- Priest
		[47788]		= UF:FilterList_Defaults(), -- Guardian Spirit
		[33206]		= UF:FilterList_Defaults(), -- Pain Suppression
		[62618]		= UF:FilterList_Defaults(), -- Power Word: Barrier
		-- Monk
		[116849]	= UF:FilterList_Defaults(), -- Life Cocoon
		-- Druid
		[102342]	= UF:FilterList_Defaults(), -- Ironbark
		-- Shaman
		[325174]	= UF:FilterList_Defaults(), -- Spirit Link
		[20608]		= UF:FilterList_Defaults(), -- Reincarnation
		-- Other
		[97462]		= UF:FilterList_Defaults(), -- Rallying Cry
		[196718]	= UF:FilterList_Defaults(), -- Darkness
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
		[209858] = UF:FilterList_Defaults(), -- Necrotic
		[226512] = UF:FilterList_Defaults(), -- Sanguine
		[240559] = UF:FilterList_Defaults(), -- Grievous
		[240443] = UF:FilterList_Defaults(), -- Bursting
	-- Shadowlands Season 3
		[368241] = UF:FilterList_Defaults(3), -- Decrypted Urh Cypher
		[368244] = UF:FilterList_Defaults(4), -- Urh Cloaking Field
		[368240] = UF:FilterList_Defaults(3), -- Decrypted Wo Cypher
		[368239] = UF:FilterList_Defaults(3), -- Decrypted Vy Cypher
		[366297] = UF:FilterList_Defaults(6), -- Deconstruct (Tank Debuff)
		[366288] = UF:FilterList_Defaults(6), -- Force Slam (Stun)
	-- Shadowlands Season 4
		[373364] = UF:FilterList_Defaults(), -- Vampiric Claws
		[373429] = UF:FilterList_Defaults(), -- Carrion Swarm
		[373370] = UF:FilterList_Defaults(), -- Nightmare Cloud
		[373391] = UF:FilterList_Defaults(), -- Nightmare
		[373570] = UF:FilterList_Defaults(), -- Hypnosis
		[373607] = UF:FilterList_Defaults(), -- Shadowy Barrier (Hypnosis)
		[373509] = UF:FilterList_Defaults(), -- Shadow Claws (Stacking)
	----------------------------------------------------------
	---------------- Old Dungeons (Season 4) -----------------
	----------------------------------------------------------
	-- Grimrail Depot
		[162057] = UF:FilterList_Defaults(), -- Spinning Spear
		[156357] = UF:FilterList_Defaults(), -- Blackrock Shrapnel
		[160702] = UF:FilterList_Defaults(), -- Blackrock Mortar Shells
		[160681] = UF:FilterList_Defaults(), -- Suppressive Fire
		[166570] = UF:FilterList_Defaults(), -- Slag Blast (Stacking)
		[164218] = UF:FilterList_Defaults(), -- Double Slash
		[162491] = UF:FilterList_Defaults(), -- Acquiring Targets 1
		[162507] = UF:FilterList_Defaults(), -- Acquiring Targets 2
		[161588] = UF:FilterList_Defaults(), -- Diffused Energy
		[162065] = UF:FilterList_Defaults(), -- Freezing Snare
	-- Iron Docks
		[163276] = UF:FilterList_Defaults(), -- Shredded Tendons
		[162415] = UF:FilterList_Defaults(), -- Time to Feed
		[168398] = UF:FilterList_Defaults(), -- Rapid Fire Targeting
		[172889] = UF:FilterList_Defaults(), -- Charging Slash
		[164504] = UF:FilterList_Defaults(), -- Intimidated
		[172631] = UF:FilterList_Defaults(), -- Knocked Down
		[172636] = UF:FilterList_Defaults(), -- Slippery Grease
		[158341] = UF:FilterList_Defaults(), -- Gushing Wounds
		[167240] = UF:FilterList_Defaults(), -- Leg Shot
		[173105] = UF:FilterList_Defaults(), -- Whirling Chains
		[173324] = UF:FilterList_Defaults(), -- Jagged Caltrops
		[172771] = UF:FilterList_Defaults(), -- Incendiary Slug
		[173307] = UF:FilterList_Defaults(), -- Serrated Spear
		[169341] = UF:FilterList_Defaults(), -- Demoralizing Roar
	-- Return to Karazhan: Upper
		[229248] = UF:FilterList_Defaults(), -- Fel Beam
		[227592] = UF:FilterList_Defaults(6), -- Frostbite
		[228252] = UF:FilterList_Defaults(), -- Shadow Rend
		[227502] = UF:FilterList_Defaults(), -- Unstable Mana
		[228261] = UF:FilterList_Defaults(6), -- Flame Wreath
		[229241] = UF:FilterList_Defaults(), -- Acquiring Target
		[230083] = UF:FilterList_Defaults(6), -- Nullification
		[230221] = UF:FilterList_Defaults(), -- Absorbed Mana
		[228249] = UF:FilterList_Defaults(5), -- Inferno Bolt 1
		[228958] = UF:FilterList_Defaults(5), -- Inferno Bolt 2
		[229159] = UF:FilterList_Defaults(), -- Chaotic Shadows
		[227465] = UF:FilterList_Defaults(), -- Power Discharge
		[229083] = UF:FilterList_Defaults(), -- Burning Blast (Stacking)
	-- Return to Karazhan: Lower
		[227917] = UF:FilterList_Defaults(), -- Poetry Slam
		[228164] = UF:FilterList_Defaults(), -- Hammer Down
		[228215] = UF:FilterList_Defaults(), -- Severe Dusting 1
		[228221] = UF:FilterList_Defaults(), -- Severe Dusting 2
		[29690]  = UF:FilterList_Defaults(), -- Drunken Skull Crack
		[227493] = UF:FilterList_Defaults(), -- Mortal Strike
		[228280] = UF:FilterList_Defaults(), -- Oath of Fealty
		[29574]  = UF:FilterList_Defaults(), -- Rend
		[230297] = UF:FilterList_Defaults(), -- Brittle Bones
		[228526] = UF:FilterList_Defaults(), -- Flirt
		[227851] = UF:FilterList_Defaults(), -- Coat Check 1
		[227832] = UF:FilterList_Defaults(), -- Coat Check 2
		[32752]  = UF:FilterList_Defaults(), -- Summoning Disorientation
		[228559] = UF:FilterList_Defaults(), -- Charming Perfume
		[227508] = UF:FilterList_Defaults(), -- Mass Repentance
		[241774] = UF:FilterList_Defaults(), -- Shield Smash
		[227742] = UF:FilterList_Defaults(), -- Garrote (Stacking)
		[238606] = UF:FilterList_Defaults(), -- Arcane Eruption
		[227848] = UF:FilterList_Defaults(), -- Sacred Ground (Stacking)
		[227404] = UF:FilterList_Defaults(6), -- Intangible Presence
		[228610] = UF:FilterList_Defaults(), -- Burning Brand
		[228576] = UF:FilterList_Defaults(), -- Allured
	-- Operation Mechagon
		[291928] = UF:FilterList_Defaults(), -- Giga-Zap
		[292267] = UF:FilterList_Defaults(), -- Giga-Zap
		[302274] = UF:FilterList_Defaults(), -- Fulminating Zap
		[298669] = UF:FilterList_Defaults(), -- Taze
		[295445] = UF:FilterList_Defaults(), -- Wreck
		[294929] = UF:FilterList_Defaults(), -- Blazing Chomp
		[297257] = UF:FilterList_Defaults(), -- Electrical Charge
		[294855] = UF:FilterList_Defaults(), -- Blossom Blast
		[291972] = UF:FilterList_Defaults(), -- Explosive Leap
		[285443] = UF:FilterList_Defaults(), -- 'Hidden' Flame Cannon
		[291974] = UF:FilterList_Defaults(), -- Obnoxious Monologue
		[296150] = UF:FilterList_Defaults(), -- Vent Blast
		[298602] = UF:FilterList_Defaults(), -- Smoke Cloud
		[296560] = UF:FilterList_Defaults(), -- Clinging Static
		[297283] = UF:FilterList_Defaults(), -- Cave In
		[291914] = UF:FilterList_Defaults(), -- Cutting Beam
		[302384] = UF:FilterList_Defaults(), -- Static Discharge
		[294195] = UF:FilterList_Defaults(), -- Arcing Zap
		[299572] = UF:FilterList_Defaults(), -- Shrink
		[300659] = UF:FilterList_Defaults(), -- Consuming Slime
		[300650] = UF:FilterList_Defaults(), -- Suffocating Smog
		[301712] = UF:FilterList_Defaults(), -- Pounce
		[299475] = UF:FilterList_Defaults(), -- B.O.R.K
		[293670] = UF:FilterList_Defaults(), -- Chain Blade
	----------------------------------------------------------
	------------------ Shadowlands Dungeons ------------------
	----------------------------------------------------------
	-- Tazavesh, the Veiled Market
		[350804] = UF:FilterList_Defaults(), -- Collapsing Energy
		[350885] = UF:FilterList_Defaults(), -- Hyperlight Jolt
		[351101] = UF:FilterList_Defaults(), -- Energy Fragmentation
		[346828] = UF:FilterList_Defaults(), -- Sanitizing Field
		[355641] = UF:FilterList_Defaults(), -- Scintillate
		[355451] = UF:FilterList_Defaults(), -- Undertow
		[355581] = UF:FilterList_Defaults(), -- Crackle
		[349999] = UF:FilterList_Defaults(), -- Anima Detonation
		[346961] = UF:FilterList_Defaults(), -- Purging Field
		[351956] = UF:FilterList_Defaults(), -- High-Value Target
		[346297] = UF:FilterList_Defaults(), -- Unstable Explosion
		[347728] = UF:FilterList_Defaults(), -- Flock!
		[356408] = UF:FilterList_Defaults(), -- Ground Stomp
		[347744] = UF:FilterList_Defaults(), -- Quickblade
		[347481] = UF:FilterList_Defaults(), -- Shuri
		[355915] = UF:FilterList_Defaults(), -- Glyph of Restraint
		[350134] = UF:FilterList_Defaults(), -- Infinite Breath
		[350013] = UF:FilterList_Defaults(), -- Gluttonous Feast
		[355465] = UF:FilterList_Defaults(), -- Boulder Throw
		[346116] = UF:FilterList_Defaults(), -- Shearing Swings
		[356011] = UF:FilterList_Defaults(), -- Beam Splicer
	-- Halls of Atonement
		[335338] = UF:FilterList_Defaults(), -- Ritual of Woe
		[326891] = UF:FilterList_Defaults(), -- Anguish
		[329321] = UF:FilterList_Defaults(), -- Jagged Swipe 1
		[344993] = UF:FilterList_Defaults(), -- Jagged Swipe 2
		[319603] = UF:FilterList_Defaults(), -- Curse of Stone
		[319611] = UF:FilterList_Defaults(), -- Turned to Stone
		[325876] = UF:FilterList_Defaults(), -- Curse of Obliteration
		[326632] = UF:FilterList_Defaults(), -- Stony Veins
		[323650] = UF:FilterList_Defaults(), -- Haunting Fixation
		[326874] = UF:FilterList_Defaults(), -- Ankle Bites
		[340446] = UF:FilterList_Defaults(), -- Mark of Envy
	-- Mists of Tirna Scithe
		[325027] = UF:FilterList_Defaults(), -- Bramble Burst
		[323043] = UF:FilterList_Defaults(), -- Bloodletting
		[322557] = UF:FilterList_Defaults(), -- Soul Split
		[331172] = UF:FilterList_Defaults(), -- Mind Link
		[322563] = UF:FilterList_Defaults(), -- Marked Prey
		[322487] = UF:FilterList_Defaults(), -- Overgrowth 1
		[322486] = UF:FilterList_Defaults(), -- Overgrowth 2
		[328756] = UF:FilterList_Defaults(), -- Repulsive Visage
		[325021] = UF:FilterList_Defaults(), -- Mistveil Tear
		[321891] = UF:FilterList_Defaults(), -- Freeze Tag Fixation
		[325224] = UF:FilterList_Defaults(), -- Anima Injection
		[326092] = UF:FilterList_Defaults(), -- Debilitating Poison
		[325418] = UF:FilterList_Defaults(), -- Volatile Acid
	-- Plaguefall
		[336258] = UF:FilterList_Defaults(), -- Solitary Prey
		[331818] = UF:FilterList_Defaults(), -- Shadow Ambush
		[329110] = UF:FilterList_Defaults(), -- Slime Injection
		[325552] = UF:FilterList_Defaults(), -- Cytotoxic Slash
		[336301] = UF:FilterList_Defaults(), -- Web Wrap
		[322358] = UF:FilterList_Defaults(), -- Burning Strain
		[322410] = UF:FilterList_Defaults(), -- Withering Filth
		[328180] = UF:FilterList_Defaults(), -- Gripping Infection
		[320542] = UF:FilterList_Defaults(), -- Wasting Blight
		[340355] = UF:FilterList_Defaults(), -- Rapid Infection
		[328395] = UF:FilterList_Defaults(), -- Venompiercer
		[320512] = UF:FilterList_Defaults(), -- Corroded Claws
		[333406] = UF:FilterList_Defaults(), -- Assassinate
		[332397] = UF:FilterList_Defaults(), -- Shroudweb
		[330069] = UF:FilterList_Defaults(), -- Concentrated Plague
	-- The Necrotic Wake
		[321821] = UF:FilterList_Defaults(), -- Disgusting Guts
		[323365] = UF:FilterList_Defaults(), -- Clinging Darkness
		[338353] = UF:FilterList_Defaults(), -- Goresplatter
		[333485] = UF:FilterList_Defaults(), -- Disease Cloud
		[338357] = UF:FilterList_Defaults(), -- Tenderize
		[328181] = UF:FilterList_Defaults(), -- Frigid Cold
		[320170] = UF:FilterList_Defaults(), -- Necrotic Bolt
		[323464] = UF:FilterList_Defaults(), -- Dark Ichor
		[323198] = UF:FilterList_Defaults(), -- Dark Exile
		[343504] = UF:FilterList_Defaults(), -- Dark Grasp
		[343556] = UF:FilterList_Defaults(), -- Morbid Fixation 1
		[338606] = UF:FilterList_Defaults(), -- Morbid Fixation 2
		[324381] = UF:FilterList_Defaults(), -- Chill Scythe
		[320573] = UF:FilterList_Defaults(), -- Shadow Well
		[333492] = UF:FilterList_Defaults(), -- Necrotic Ichor
		[334748] = UF:FilterList_Defaults(), -- Drain Fluids
		[333489] = UF:FilterList_Defaults(), -- Necrotic Breath
		[320717] = UF:FilterList_Defaults(), -- Blood Hunger
	-- Theater of Pain
		[333299] = UF:FilterList_Defaults(), -- Curse of Desolation 1
		[333301] = UF:FilterList_Defaults(), -- Curse of Desolation 2
		[319539] = UF:FilterList_Defaults(), -- Soulless
		[326892] = UF:FilterList_Defaults(), -- Fixate
		[321768] = UF:FilterList_Defaults(), -- On the Hook
		[323825] = UF:FilterList_Defaults(), -- Grasping Rift
		[342675] = UF:FilterList_Defaults(), -- Bone Spear
		[323831] = UF:FilterList_Defaults(), -- Death Grasp
		[330608] = UF:FilterList_Defaults(), -- Vile Eruption
		[330868] = UF:FilterList_Defaults(), -- Necrotic Bolt Volley
		[323750] = UF:FilterList_Defaults(), -- Vile Gas
		[323406] = UF:FilterList_Defaults(), -- Jagged Gash
		[330700] = UF:FilterList_Defaults(), -- Decaying Blight
		[319626] = UF:FilterList_Defaults(), -- Phantasmal Parasite
		[324449] = UF:FilterList_Defaults(), -- Manifest Death
		[341949] = UF:FilterList_Defaults(), -- Withering Blight
	-- Sanguine Depths
		[326827] = UF:FilterList_Defaults(), -- Dread Bindings
		[326836] = UF:FilterList_Defaults(), -- Curse of Suppression
		[322554] = UF:FilterList_Defaults(), -- Castigate
		[321038] = UF:FilterList_Defaults(), -- Burden Soul
		[328593] = UF:FilterList_Defaults(), -- Agonize
		[325254] = UF:FilterList_Defaults(), -- Iron Spikes
		[335306] = UF:FilterList_Defaults(), -- Barbed Shackles
		[322429] = UF:FilterList_Defaults(), -- Severing Slice
		[334653] = UF:FilterList_Defaults(), -- Engorge
	-- Spires of Ascension
		[338729] = UF:FilterList_Defaults(), -- Charged Stomp
		[323195] = UF:FilterList_Defaults(), -- Purifying Blast
		[327481] = UF:FilterList_Defaults(), -- Dark Lance
		[322818] = UF:FilterList_Defaults(), -- Lost Confidence
		[322817] = UF:FilterList_Defaults(), -- Lingering Doubt
		[324205] = UF:FilterList_Defaults(), -- Blinding Flash
		[331251] = UF:FilterList_Defaults(), -- Deep Connection
		[328331] = UF:FilterList_Defaults(), -- Forced Confession
		[341215] = UF:FilterList_Defaults(), -- Volatile Anima
		[323792] = UF:FilterList_Defaults(), -- Anima Field
		[317661] = UF:FilterList_Defaults(), -- Insidious Venom
		[330683] = UF:FilterList_Defaults(), -- Raw Anima
		[328434] = UF:FilterList_Defaults(), -- Intimidated
	-- De Other Side
		[320786] = UF:FilterList_Defaults(), -- Power Overwhelming
		[334913] = UF:FilterList_Defaults(), -- Master of Death
		[325725] = UF:FilterList_Defaults(), -- Cosmic Artifice
		[328987] = UF:FilterList_Defaults(), -- Zealous
		[334496] = UF:FilterList_Defaults(), -- Soporific Shimmerdust
		[339978] = UF:FilterList_Defaults(), -- Pacifying Mists
		[323692] = UF:FilterList_Defaults(), -- Arcane Vulnerability
		[333250] = UF:FilterList_Defaults(), -- Reaver
		[330434] = UF:FilterList_Defaults(), -- Buzz-Saw 1
		[320144] = UF:FilterList_Defaults(), -- Buzz-Saw 2
		[331847] = UF:FilterList_Defaults(), -- W-00F
		[327649] = UF:FilterList_Defaults(), -- Crushed Soul
		[331379] = UF:FilterList_Defaults(), -- Lubricate
		[332678] = UF:FilterList_Defaults(), -- Gushing Wound
		[322746] = UF:FilterList_Defaults(), -- Corrupted Blood
		[323687] = UF:FilterList_Defaults(), -- Arcane Lightning
		[323877] = UF:FilterList_Defaults(), -- Echo Finger Laser X-treme
		[334535] = UF:FilterList_Defaults(), -- Beak Slice
	--------------------------------------------------------
	-------------------- Castle Nathria --------------------
	--------------------------------------------------------
	-- Shriekwing
		[328897] = UF:FilterList_Defaults(), -- Exsanguinated
		[330713] = UF:FilterList_Defaults(), -- Reverberating Pain
		[329370] = UF:FilterList_Defaults(), -- Deadly Descent
		[336494] = UF:FilterList_Defaults(), -- Echo Screech
		[346301] = UF:FilterList_Defaults(), -- Bloodlight
		[342077] = UF:FilterList_Defaults(), -- Echolocation
	-- Huntsman Altimor
		[335304] = UF:FilterList_Defaults(), -- Sinseeker
		[334971] = UF:FilterList_Defaults(), -- Jagged Claws
		[335111] = UF:FilterList_Defaults(), -- Huntsman's Mark 3
		[335112] = UF:FilterList_Defaults(), -- Huntsman's Mark 2
		[335113] = UF:FilterList_Defaults(), -- Huntsman's Mark 1
		[334945] = UF:FilterList_Defaults(), -- Vicious Lunge
		[334852] = UF:FilterList_Defaults(), -- Petrifying Howl
		[334695] = UF:FilterList_Defaults(), -- Destabilize
	-- Hungering Destroyer
		[334228] = UF:FilterList_Defaults(), -- Volatile Ejection
		[329298] = UF:FilterList_Defaults(), -- Gluttonous Miasma
	-- Lady Inerva Darkvein
		[325936] = UF:FilterList_Defaults(), -- Shared Cognition
		[335396] = UF:FilterList_Defaults(), -- Hidden Desire
		[324983] = UF:FilterList_Defaults(), -- Shared Suffering
		[324982] = UF:FilterList_Defaults(), -- Shared Suffering (Partner)
		[332664] = UF:FilterList_Defaults(), -- Concentrate Anima
		[325382] = UF:FilterList_Defaults(), -- Warped Desires
	-- Sun King's Salvation
		[333002] = UF:FilterList_Defaults(), -- Vulgar Brand
		[326078] = UF:FilterList_Defaults(), -- Infuser's Boon
		[325251] = UF:FilterList_Defaults(), -- Sin of Pride
		[341475] = UF:FilterList_Defaults(), -- Crimson Flurry
		[341473] = UF:FilterList_Defaults(), -- Crimson Flurry Teleport
		[328479] = UF:FilterList_Defaults(), -- Eyes on Target
		[328889] = UF:FilterList_Defaults(), -- Greater Castigation
	-- Artificer Xy'mox
		[327902] = UF:FilterList_Defaults(), -- Fixate
		[326302] = UF:FilterList_Defaults(), -- Stasis Trap
		[325236] = UF:FilterList_Defaults(), -- Glyph of Destruction
		[327414] = UF:FilterList_Defaults(), -- Possession
		[328468] = UF:FilterList_Defaults(), -- Dimensional Tear 1
		[328448] = UF:FilterList_Defaults(), -- Dimensional Tear 2
		[340860] = UF:FilterList_Defaults(), -- Withering Touch
	-- The Council of Blood
		[327052] = UF:FilterList_Defaults(), -- Drain Essence 1
		[327773] = UF:FilterList_Defaults(), -- Drain Essence 2
		[346651] = UF:FilterList_Defaults(), -- Drain Essence Mythic
		[328334] = UF:FilterList_Defaults(), -- Tactical Advance
		[330848] = UF:FilterList_Defaults(), -- Wrong Moves
		[331706] = UF:FilterList_Defaults(), -- Scarlet Letter
		[331636] = UF:FilterList_Defaults(), -- Dark Recital 1
		[331637] = UF:FilterList_Defaults(), -- Dark Recital 2
	-- Sludgefist
		[335470] = UF:FilterList_Defaults(), -- Chain Slam
		[339181] = UF:FilterList_Defaults(), -- Chain Slam (Root)
		[331209] = UF:FilterList_Defaults(), -- Hateful Gaze
		[335293] = UF:FilterList_Defaults(), -- Chain Link
		[335270] = UF:FilterList_Defaults(), -- Chain This One!
		[342419] = UF:FilterList_Defaults(), -- Chain Them! 1
		[342420] = UF:FilterList_Defaults(), -- Chain Them! 2
		[335295] = UF:FilterList_Defaults(), -- Shattering Chain
		[332572] = UF:FilterList_Defaults(), -- Falling Rubble
	-- Stone Legion Generals
		[334498] = UF:FilterList_Defaults(), -- Seismic Upheaval
		[337643] = UF:FilterList_Defaults(), -- Unstable Footing
		[334765] = UF:FilterList_Defaults(), -- Heart Rend
		[334771] = UF:FilterList_Defaults(), -- Heart Hemorrhage
		[333377] = UF:FilterList_Defaults(), -- Wicked Mark
		[334616] = UF:FilterList_Defaults(), -- Petrified
		[334541] = UF:FilterList_Defaults(), -- Curse of Petrification
		[339690] = UF:FilterList_Defaults(), -- Crystalize
		[342655] = UF:FilterList_Defaults(), -- Volatile Anima Infusion
		[342698] = UF:FilterList_Defaults(), -- Volatile Anima Infection
		[343881] = UF:FilterList_Defaults(), -- Serrated Tear
	-- Sire Denathrius
		[326851] = UF:FilterList_Defaults(), -- Blood Price
		[327796] = UF:FilterList_Defaults(), -- Night Hunter
		[327992] = UF:FilterList_Defaults(), -- Desolation
		[328276] = UF:FilterList_Defaults(), -- March of the Penitent
		[326699] = UF:FilterList_Defaults(), -- Burden of Sin
		[329181] = UF:FilterList_Defaults(), -- Wracking Pain
		[335873] = UF:FilterList_Defaults(), -- Rancor
		[329951] = UF:FilterList_Defaults(), -- Impale
		[327039] = UF:FilterList_Defaults(), -- Feeding Time
		[332794] = UF:FilterList_Defaults(), -- Fatal Finesse
		[334016] = UF:FilterList_Defaults(), -- Unworthy
	--------------------------------------------------------
	---------------- Sanctum of Domination -----------------
	--------------------------------------------------------
	-- The Tarragrue
		[347283] = UF:FilterList_Defaults(5), -- Predator's Howl
		[347286] = UF:FilterList_Defaults(5), -- Unshakeable Dread
		[346986] = UF:FilterList_Defaults(3), -- Crushed Armor
		[347269] = UF:FilterList_Defaults(6), -- Chains of Eternity
		[346985] = UF:FilterList_Defaults(3), -- Overpower
	-- Eye of the Jailer
		[350606] = UF:FilterList_Defaults(4), -- Hopeless Lethargy
		[355240] = UF:FilterList_Defaults(5), -- Scorn
		[355245] = UF:FilterList_Defaults(5), -- Ire
		[349979] = UF:FilterList_Defaults(2), -- Dragging Chains
		[348074] = UF:FilterList_Defaults(3), -- Assailing Lance
		[351827] = UF:FilterList_Defaults(6), -- Spreading Misery
		[355143] = UF:FilterList_Defaults(6), -- Deathlink
		[350763] = UF:FilterList_Defaults(6), -- Annihilating Glare
	-- The Nine
		[350287] = UF:FilterList_Defaults(2), -- Song of Dissolution
		[350542] = UF:FilterList_Defaults(6), -- Fragments of Destiny
		[350202] = UF:FilterList_Defaults(3), -- Unending Strike
		[350475] = UF:FilterList_Defaults(5), -- Pierce Soul
		[350555] = UF:FilterList_Defaults(3), -- Shard of Destiny
		[350109] = UF:FilterList_Defaults(5), -- Brynja's Mournful Dirge
		[350483] = UF:FilterList_Defaults(6), -- Link Essence
		[350039] = UF:FilterList_Defaults(5), -- Arthura's Crushing Gaze
		[350184] = UF:FilterList_Defaults(5), -- Daschla's Mighty Impact
		[350374] = UF:FilterList_Defaults(5), -- Wings of Rage
	-- Remnant of Ner'zhul
		[350073] = UF:FilterList_Defaults(2), -- Torment
		[349890] = UF:FilterList_Defaults(5), -- Suffering
		[350469] = UF:FilterList_Defaults(6), -- Malevolence
		[354634] = UF:FilterList_Defaults(6), -- Spite 1
		[354479] = UF:FilterList_Defaults(6), -- Spite 2
		[354534] = UF:FilterList_Defaults(6), -- Spite 3
	-- Soulrender Dormazain
		[353429] = UF:FilterList_Defaults(2), -- Tormented
		[353023] = UF:FilterList_Defaults(3), -- Torment
		[351787] = UF:FilterList_Defaults(5), -- Agonizing Spike
		[350647] = UF:FilterList_Defaults(5), -- Brand of Torment
		[350422] = UF:FilterList_Defaults(6), -- Ruinblade
		[350851] = UF:FilterList_Defaults(6), -- Vessel of Torment
		[354231] = UF:FilterList_Defaults(6), -- Soul Manacles
		[348987] = UF:FilterList_Defaults(6), -- Warmonger Shackle 1
		[350927] = UF:FilterList_Defaults(6), -- Warmonger Shackle 2
	-- Painsmith Raznal
		[356472] = UF:FilterList_Defaults(5), -- Lingering Flames
		[355505] = UF:FilterList_Defaults(6), -- Shadowsteel Chains 1
		[355506] = UF:FilterList_Defaults(6), -- Shadowsteel Chains 2
		[348456] = UF:FilterList_Defaults(6), -- Flameclasp Trap
		[356870] = UF:FilterList_Defaults(2), -- Flameclasp Eruption
		[355568] = UF:FilterList_Defaults(6), -- Cruciform Axe
		[355786] = UF:FilterList_Defaults(5), -- Blackened Armor
		[355526] = UF:FilterList_Defaults(6), -- Spiked
	-- Guardian of the First Ones
		[352394] = UF:FilterList_Defaults(5), -- Radiant Energy
		[350496] = UF:FilterList_Defaults(6), -- Threat Neutralization
		[347359] = UF:FilterList_Defaults(6), -- Suppression Field
		[355357] = UF:FilterList_Defaults(6), -- Obliterate
		[350732] = UF:FilterList_Defaults(5), -- Sunder
		[352833] = UF:FilterList_Defaults(6), -- Disintegration
	-- Fatescribe Roh-Kalo
		[354365] = UF:FilterList_Defaults(5), -- Grim Portent
		[350568] = UF:FilterList_Defaults(5), -- Call of Eternity
		[353435] = UF:FilterList_Defaults(6), -- Overwhelming Burden
		[351680] = UF:FilterList_Defaults(6), -- Invoke Destiny
		[353432] = UF:FilterList_Defaults(6), -- Burden of Destiny
		[353693] = UF:FilterList_Defaults(6), -- Unstable Accretion
		[350355] = UF:FilterList_Defaults(6), -- Fated Conjunction
		[353931] = UF:FilterList_Defaults(2), -- Twist Fate
	-- Kel'Thuzad
		[346530] = UF:FilterList_Defaults(2), -- Frozen Destruction
		[354289] = UF:FilterList_Defaults(2), -- Sinister Miasma
		[347454] = UF:FilterList_Defaults(6), -- Oblivion's Echo 1
		[347518] = UF:FilterList_Defaults(6), -- Oblivion's Echo 2
		[347292] = UF:FilterList_Defaults(6), -- Oblivion's Echo 3
		[348978] = UF:FilterList_Defaults(6), -- Soul Exhaustion
		[355389] = UF:FilterList_Defaults(6), -- Relentless Haunt (Fixate)
		[357298] = UF:FilterList_Defaults(6), -- Frozen Binds
		[355137] = UF:FilterList_Defaults(5), -- Shadow Pool
		[348638] = UF:FilterList_Defaults(4), -- Return of the Damned
		[348760] = UF:FilterList_Defaults(6), -- Frost Blast
	-- Sylvanas Windrunner
		[349458] = UF:FilterList_Defaults(2), -- Domination Chains
		[347704] = UF:FilterList_Defaults(2), -- Veil of Darkness
		[347607] = UF:FilterList_Defaults(5), -- Banshee's Mark
		[347670] = UF:FilterList_Defaults(5), -- Shadow Dagger
		[351117] = UF:FilterList_Defaults(5), -- Crushing Dread
		[351870] = UF:FilterList_Defaults(5), -- Haunting Wave
		[351253] = UF:FilterList_Defaults(5), -- Banshee Wail
		[351451] = UF:FilterList_Defaults(6), -- Curse of Lethargy
		[351092] = UF:FilterList_Defaults(6), -- Destabilize 1
		[351091] = UF:FilterList_Defaults(6), -- Destabilize 2
		[348064] = UF:FilterList_Defaults(6), -- Wailing Arrow
	----------------------------------------------------------
	-------------- Sepulcher of the First Ones ---------------
	----------------------------------------------------------
	-- Vigilant Guardian
		[364447] = UF:FilterList_Defaults(3), -- Dissonance
		[364904] = UF:FilterList_Defaults(6), -- Anti-Matter
		[364881] = UF:FilterList_Defaults(5), -- Matter Disolution
		[360415] = UF:FilterList_Defaults(5), -- Defenseless
		[360412] = UF:FilterList_Defaults(4), -- Exposed Core
		[366393] = UF:FilterList_Defaults(5), -- Searing Ablation
	-- Skolex, the Insatiable Ravener
		[364522] = UF:FilterList_Defaults(2), -- Devouring Blood
		[359976] = UF:FilterList_Defaults(2), -- Riftmaw
		[359981] = UF:FilterList_Defaults(2), -- Rend
		[360098] = UF:FilterList_Defaults(3), -- Warp Sickness
		[366070] = UF:FilterList_Defaults(3), -- Volatile Residue
	-- Artificer Xy'mox
		[364030] = UF:FilterList_Defaults(3), -- Debilitating Ray
		[365681] = UF:FilterList_Defaults(2), -- System Shock
		[363413] = UF:FilterList_Defaults(4), -- Forerunner Rings A
		[364604] = UF:FilterList_Defaults(4), -- Forerunner Rings B
		[362615] = UF:FilterList_Defaults(6), -- Interdimensional Wormhole Player 1
		[362614] = UF:FilterList_Defaults(6), -- Interdimensional Wormhole Player 2
		[362803] = UF:FilterList_Defaults(5), -- Glyph of Relocation
	-- Dausegne, The Fallen Oracle
		[361751] = UF:FilterList_Defaults(2), -- Disintegration Halo
		[364289] = UF:FilterList_Defaults(2), -- Staggering Barrage
		[361018] = UF:FilterList_Defaults(2), -- Staggering Barrage Mythic 1
		[360960] = UF:FilterList_Defaults(2), -- Staggering Barrage Mythic 2
		[361225] = UF:FilterList_Defaults(2), -- Encroaching Dominion
		[361966] = UF:FilterList_Defaults(2), -- Infused Strikes
	-- Prototype Pantheon
		[365306] = UF:FilterList_Defaults(2), -- Invigorating Bloom
		[361689] = UF:FilterList_Defaults(3), -- Wracking Pain
		[366232] = UF:FilterList_Defaults(4), -- Animastorm
		[364839] = UF:FilterList_Defaults(2), -- Sinful Projection
		[360259] = UF:FilterList_Defaults(5), -- Gloom Bolt
		[362383] = UF:FilterList_Defaults(5), -- Anima Bolt
		[362352] = UF:FilterList_Defaults(6), -- Pinned
	-- Lihuvim, Principle Architect
		[360159] = UF:FilterList_Defaults(5), -- Unstable Protoform Energy
		[363681] = UF:FilterList_Defaults(3), -- Deconstructing Blast
		[363676] = UF:FilterList_Defaults(4), -- Deconstructing Energy Player 1
		[363795] = UF:FilterList_Defaults(4), -- Deconstructing Energy Player 2
		[464312] = UF:FilterList_Defaults(5), -- Ephemeral Barrier
	-- Halondrus the Reclaimer
		[361309] = UF:FilterList_Defaults(3), -- Lightshatter Beam
		[361002] = UF:FilterList_Defaults(4), -- Ephemeral Fissure
		[360114] = UF:FilterList_Defaults(4), -- Ephemeral Fissure II
	-- Anduin Wrynn
		[365293] = UF:FilterList_Defaults(2), -- Befouled Barrier
		[363020] = UF:FilterList_Defaults(3), -- Necrotic Claws
		[365021] = UF:FilterList_Defaults(5), -- Wicked Star (marked)
		[365024] = UF:FilterList_Defaults(6), -- Wicked Star (hit)
		[365445] = UF:FilterList_Defaults(3), -- Scarred Soul
		[365008] = UF:FilterList_Defaults(4), -- Psychic Terror
		[366849] = UF:FilterList_Defaults(6), -- Domination Word: Pain
	-- Lords of Dread
		[360148] = UF:FilterList_Defaults(5), -- Bursting Dread
		[360012] = UF:FilterList_Defaults(4), -- Cloud of Carrion
		[360146] = UF:FilterList_Defaults(4), -- Fearful Trepidation
		[360241] = UF:FilterList_Defaults(6), -- Unsettling Dreams
	-- Rygelon
		[362206] = UF:FilterList_Defaults(6), -- Event Horizon
		[362137] = UF:FilterList_Defaults(4), -- Corrupted Wound
		[362172] = UF:FilterList_Defaults(4), -- Corrupted Wound
		[361548] = UF:FilterList_Defaults(5), -- Dark Eclipse
	-- The Jailer
		[362075] = UF:FilterList_Defaults(6), -- Domination
		[365150] = UF:FilterList_Defaults(6), -- Rune of Domination
		[363893] = UF:FilterList_Defaults(5), -- Martyrdom
		[363886] = UF:FilterList_Defaults(5), -- Imprisonment
		[365219] = UF:FilterList_Defaults(5), -- Chains of Anguish
		[366285] = UF:FilterList_Defaults(6), -- Rune of Compulsion
		[363332] = UF:FilterList_Defaults(5), -- Unbreaking Grasp
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
		[209859] = UF:FilterList_Defaults(), -- Bolster
		[178658] = UF:FilterList_Defaults(), -- Raging
		[226510] = UF:FilterList_Defaults(), -- Sanguine
		[343502] = UF:FilterList_Defaults(), -- Inspiring
	-- Shadowlands Season 3
		[368104] = UF:FilterList_Defaults(), -- Acceleration Field
		[368079] = UF:FilterList_Defaults(), -- Defense Matrix
	-- Shadowlands Season 4
		[373011] = UF:FilterList_Defaults(6), -- Disguised
		[373108] = UF:FilterList_Defaults(2), -- Bounty: Critical Strike (Stacking)
		[373113] = UF:FilterList_Defaults(2), -- Bounty: Haste (Stacking)
		[373121] = UF:FilterList_Defaults(2), -- Bounty: Versatility (Stacking)
		[373116] = UF:FilterList_Defaults(2), -- Bounty: Mastery (Stacking)
	----------------------------------------------------------
	---------------- Old Dungeons (Season 4) -----------------
	----------------------------------------------------------
	-- Grimrail Depot
		[161091] = UF:FilterList_Defaults(), -- New Plan!
		[166378] = UF:FilterList_Defaults(), -- Reckless Slash
		[163550] = UF:FilterList_Defaults(), -- Blackrock Mortar
		[163947] = UF:FilterList_Defaults(), -- Recovering
		[162572] = UF:FilterList_Defaults(), -- Missile Smoke
		[166335] = UF:FilterList_Defaults(), -- Storm Shield
		[176023] = UF:FilterList_Defaults(), -- Getting Angry
		[166561] = UF:FilterList_Defaults(), -- Locking On!
	-- Iron Docks
		[164426] = UF:FilterList_Defaults(), -- Reckless Provocation
		[173091] = UF:FilterList_Defaults(), -- Champion's Presence
		[373724] = UF:FilterList_Defaults(), -- Blood Barrier
		[172943] = UF:FilterList_Defaults(), -- Brutal Inspiration
		[173455] = UF:FilterList_Defaults(), -- Pit Fighter
		[162424] = UF:FilterList_Defaults(), -- Feeding Frenzy
		[167232] = UF:FilterList_Defaults(), -- Bladestorm
		[178412] = UF:FilterList_Defaults(), -- Flurry
	-- Return to Karazhan: Upper
		[228254] = UF:FilterList_Defaults(), -- Soul Leech
		[227529] = UF:FilterList_Defaults(), -- Unstable Energy
		[227254] = UF:FilterList_Defaults(), -- Evocation
		[227257] = UF:FilterList_Defaults(), -- Overload
		[228362] = UF:FilterList_Defaults(), -- Siphon Energy
		[373388] = UF:FilterList_Defaults(), -- Nightmare Cloud
		[227270] = UF:FilterList_Defaults(), -- Arc Lightning
	-- Return to Karazhan: Lower
		[227817] = UF:FilterList_Defaults(), -- Holy Bulwark
		[228225] = UF:FilterList_Defaults(), -- Sultry Heat
		[228895] = UF:FilterList_Defaults(), -- Enrage (100/100)
		[232156] = UF:FilterList_Defaults(), -- Spectral Service
		[232142] = UF:FilterList_Defaults(), -- Flashing Forks
		[227931] = UF:FilterList_Defaults(), -- In The Spotlight
		[227872] = UF:FilterList_Defaults(), -- Ghastly Purge
		[233669] = UF:FilterList_Defaults(), -- Dinner Party
		[227999] = UF:FilterList_Defaults(), -- Pennies From Heaven
		[228729] = UF:FilterList_Defaults(), -- Eminence (Stacking)
		[227983] = UF:FilterList_Defaults(), -- Rapid Fan
		[228575] = UF:FilterList_Defaults(), -- Alluring Aura
		[233210] = UF:FilterList_Defaults(), -- Whip Rage
	-- Operation Mechagon
		[298651] = UF:FilterList_Defaults(), -- Pedal to the Metal 1
		[299164] = UF:FilterList_Defaults(), -- Pedal to the Metal 2
		[303941] = UF:FilterList_Defaults(), -- Defensive Countermeasure (Junkyard)
		[297133] = UF:FilterList_Defaults(), -- Defensive Countermeasure (Workshop)
		[299153] = UF:FilterList_Defaults(), -- Turbo Boost
		[301689] = UF:FilterList_Defaults(), -- Charged Coil
		[300207] = UF:FilterList_Defaults(), -- Shock Coil
		[300414] = UF:FilterList_Defaults(), -- Enrage
		[296080] = UF:FilterList_Defaults(), -- Haywire
		[293729] = UF:FilterList_Defaults(), -- Tune Up
		[282801] = UF:FilterList_Defaults(), -- Platinum Plating (Stacking)
		[285388] = UF:FilterList_Defaults(), -- Vent Jets
		[295169] = UF:FilterList_Defaults(), -- Capacitor Discharge
		[283565] = UF:FilterList_Defaults(), -- Maximum Thrust
		[293930] = UF:FilterList_Defaults(), -- Overclock
		[291946] = UF:FilterList_Defaults(), -- Venting Flames
		[294290] = UF:FilterList_Defaults(), -- Process Waste
	----------------------------------------------------------
	------------------ Shadowlands Dungeons ------------------
	----------------------------------------------------------
	-- Tazavesh, the Veiled Market
		[355147] = UF:FilterList_Defaults(), -- Fish Invigoration
		[351960] = UF:FilterList_Defaults(), -- Static Cling
		[351088] = UF:FilterList_Defaults(), -- Relic Link
		[346296] = UF:FilterList_Defaults(), -- Instability
		[355057] = UF:FilterList_Defaults(), -- Cry of Mrrggllrrgg
		[355640] = UF:FilterList_Defaults(), -- Phalanx Field
		[355783] = UF:FilterList_Defaults(), -- Force Multiplied
		[351086] = UF:FilterList_Defaults(), -- Power Overwhelming
		[347840] = UF:FilterList_Defaults(), -- Feral
		[355782] = UF:FilterList_Defaults(), -- Force Multiplier
		[347992] = UF:FilterList_Defaults(), -- Rotar Body Armor
	-- Halls of Atonement
		[326450] = UF:FilterList_Defaults(), -- Loyal Beasts
	-- Mists of Tirna Scithe
		[336499] = UF:FilterList_Defaults(), -- Guessing Game
	-- Plaguefall
		[336451] = UF:FilterList_Defaults(), -- Bulwark of Maldraxxus
		[333737] = UF:FilterList_Defaults(), -- Congealed Contagion
	-- The Necrotic Wake
		[321754] = UF:FilterList_Defaults(), -- Icebound Aegis
		[343558] = UF:FilterList_Defaults(), -- Morbid Fixation
		[343470] = UF:FilterList_Defaults(), -- Boneshatter Shield
	-- Theater of Pain
		[331510] = UF:FilterList_Defaults(), -- Death Wish
		[333241] = UF:FilterList_Defaults(), -- Raging Tantrum
		[326892] = UF:FilterList_Defaults(), -- Fixate
		[330545] = UF:FilterList_Defaults(), -- Commanding Presences
	-- Sanguine Depths
		[322433] = UF:FilterList_Defaults(), -- Stoneskin
		[321402] = UF:FilterList_Defaults(), -- Engorge
	-- Spires of Ascension
		[327416] = UF:FilterList_Defaults(), -- Recharge Anima
		[317936] = UF:FilterList_Defaults(), -- Forsworn Doctrine
		[327808] = UF:FilterList_Defaults(), -- Inspiring Presence
	-- De Other Side
		[344739] = UF:FilterList_Defaults(), -- Spectral
		[333227] = UF:FilterList_Defaults(), -- Undying Rage
		[322773] = UF:FilterList_Defaults(), -- Blood Barrier
	----------------------------------------------------------
	--------------------- Castle Nathria ---------------------
	----------------------------------------------------------
	-- Sun King's Salvation
		[343026] = UF:FilterList_Defaults(), -- Cloak of Flames
	-- Stone Legion Generals
		[329808] = UF:FilterList_Defaults(), -- Hardened Stone Form Grashaal
		[329636] = UF:FilterList_Defaults(), -- Hardened Stone Form Kaal
		[340037] = UF:FilterList_Defaults(), -- Volatile Stone Shell
	----------------------------------------------------------
	----------------- Sanctum of Domination ------------------
	----------------------------------------------------------
	-- The Tarragrue
		[352491] = UF:FilterList_Defaults(), -- Remnant: Mort'regar's Echoes 1
		[352389] = UF:FilterList_Defaults(), -- Remnant: Mort'regar's Echoes 2
		[352473] = UF:FilterList_Defaults(), -- Remnant: Upper Reaches' Might 1
		[352382] = UF:FilterList_Defaults(), -- Remnant: Upper Reaches' Might 2
		[352398] = UF:FilterList_Defaults(), -- Remnant: Soulforge Heat
		[347490] = UF:FilterList_Defaults(), -- Fury of the Ages
		[347740] = UF:FilterList_Defaults(), -- Hungering Mist 1
		[347679] = UF:FilterList_Defaults(), -- Hungering Mist 2
		[347369] = UF:FilterList_Defaults(), -- The Jailer's Gaze
	-- Eye of the Jailer
		[350006] = UF:FilterList_Defaults(), -- Pulled Down
		[351413] = UF:FilterList_Defaults(), -- Annihilating Glare
		[348805] = UF:FilterList_Defaults(), -- Stygian Darkshield
		[351994] = UF:FilterList_Defaults(), -- Dying Suffering
		[351825] = UF:FilterList_Defaults(), -- Shared Suffering
		[345521] = UF:FilterList_Defaults(), -- Molten Aura
	-- The Nine
		[355294] = UF:FilterList_Defaults(), -- Resentment
		[350286] = UF:FilterList_Defaults(), -- Song of Dissolution
		[352756] = UF:FilterList_Defaults(), -- Wings of Rage 1
		[350365] = UF:FilterList_Defaults(), -- Wings of Rage 2
		[352752] = UF:FilterList_Defaults(), -- Reverberating Refrain 1
		[350385] = UF:FilterList_Defaults(), -- Reverberating Refrain 2
		[350158] = UF:FilterList_Defaults(), -- Annhylde's Bright Aegis
	-- Remnant of Ner'zhul
		[355790] = UF:FilterList_Defaults(), -- Eternal Torment
		[355151] = UF:FilterList_Defaults(), -- Malevolence
		[355439] = UF:FilterList_Defaults(), -- Aura of Spite 1
		[354441] = UF:FilterList_Defaults(), -- Aura of Spite 2
		[350671] = UF:FilterList_Defaults(), -- Aura of Spite 3
		[354440] = UF:FilterList_Defaults(), -- Aura of Spite 4
	-- Soulrender Dormazain
		[351946] = UF:FilterList_Defaults(), -- Hellscream
		[352066] = UF:FilterList_Defaults(), -- Rendered Soul
		[353554] = UF:FilterList_Defaults(), -- Infuse Defiance
		[351773] = UF:FilterList_Defaults(), -- Defiance
		[350415] = UF:FilterList_Defaults(), -- Warmonger's Shackles
		[352933] = UF:FilterList_Defaults(), -- Tormented Eruptions
	-- Painsmith Raznal
		[355525] = UF:FilterList_Defaults(), -- Forge Weapon
	-- Guardian of the First Ones
		[352538] = UF:FilterList_Defaults(), -- Purging Protocol
		[353448] = UF:FilterList_Defaults(), -- Suppression Field
		[350534] = UF:FilterList_Defaults(), -- Purging Protocol
		[352385] = UF:FilterList_Defaults(), -- Energizing Link
	-- Fatescribe Roh-Kalo
		[353604] = UF:FilterList_Defaults(), -- Diviner's Probe
	-- Kel'Thuzad
		[355935] = UF:FilterList_Defaults(), -- Banshee's Cry 1
		[352141] = UF:FilterList_Defaults(), -- Banshee's Cry 2
		[355948] = UF:FilterList_Defaults(), -- Necrotic Empowerment
		[352051] = UF:FilterList_Defaults(), -- Necrotic Surge
	-- Sylvanas Windrunner
		[352650] = UF:FilterList_Defaults(), -- Ranger's Heartseeker 1
		[352663] = UF:FilterList_Defaults(), -- Ranger's Heartseeker 2
		[350865] = UF:FilterList_Defaults(), -- Accursed Might
		[348146] = UF:FilterList_Defaults(), -- Banshee Form
		[347504] = UF:FilterList_Defaults(), -- Windrunner
		[350857] = UF:FilterList_Defaults(), -- Banshee Shroud
		[351109] = UF:FilterList_Defaults(), -- Enflame
		[351452] = UF:FilterList_Defaults(), -- Lethargic Focus
	----------------------------------------------------------
	-------------- Sepulcher of the First Ones ---------------
	----------------------------------------------------------
	-- Vigilant Guardian
		[360404] = UF:FilterList_Defaults(), -- Force Field
		[366822] = UF:FilterList_Defaults(), -- Radioactive Core
		[364843] = UF:FilterList_Defaults(), -- Fractured Core
		[364962] = UF:FilterList_Defaults(), -- Core Overload
	-- Skolex, the Insatiable Ravener
		[360193] = UF:FilterList_Defaults(), -- Insatiable (stacking)
	-- Artificer Xy'mox
		[363139] = UF:FilterList_Defaults(), -- Decipher Relic
	-- Dausegne, the Fallen Oracle
		[361651] = UF:FilterList_Defaults(), -- Siphoned Barrier
		[362432] = UF:FilterList_Defaults(), -- Collapsed Barrier
		[361513] = UF:FilterList_Defaults(), -- Obliteraion Arc
	-- Prototype Pantheon
		[361938] = UF:FilterList_Defaults(), -- Reconstruction
		[360845] = UF:FilterList_Defaults(), -- Bastion's Ward
	-- Lihuvim, Principle Architect
		[363537] = UF:FilterList_Defaults(), -- Protoform Radiance
		[365036] = UF:FilterList_Defaults(), -- Ephemeral Barrier
		[361200] = UF:FilterList_Defaults(), -- Recharge
		[363130] = UF:FilterList_Defaults(), -- Synthesize
	-- Halondrus the Reclaimer
		[367078] = UF:FilterList_Defaults(), -- Phase Barrier
		[363414] = UF:FilterList_Defaults(), -- Fractal Shell
		[359235] = UF:FilterList_Defaults(), -- Reclamation Form
		[359236] = UF:FilterList_Defaults(), -- Relocation Form
	-- Anduin Wrynn
		[364248] = UF:FilterList_Defaults(), -- Dark Zeal
		[365030] = UF:FilterList_Defaults(), -- Wicked Star
		[362862] = UF:FilterList_Defaults(), -- Army of the Dea
	---------------------------------------------------------
	----------------------- Open World ----------------------
	---------------------------------------------------------
	-- Korthia
		[354840] = UF:FilterList_Defaults(), -- Rift Veiled (Silent Soulstalker, Deadsoul Hatcher, Screaming Shade)
		[355249] = UF:FilterList_Defaults(), -- Anima Gorged (Consumption)
	-- Zereth Mortis
		[360945] = UF:FilterList_Defaults(), -- Creation Catalyst Overcharge (Nascent Servitor)
		[366309] = UF:FilterList_Defaults(), -- Meltdown (Destabilized Core)
		[365596] = UF:FilterList_Defaults(), -- Overload (Destabilized Core)
		[360750] = UF:FilterList_Defaults(), -- Aurelid Lure
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {},
	ROGUE = {
		[57934]		= UF:AuraWatch_AddSpell(57934, 'TOPRIGHT', {0.89, 0.09, 0.05}),		-- Tricks of the Trade
	},
	WARRIOR = {
		[3411]		= UF:AuraWatch_AddSpell(3411, 'TOPRIGHT', {0.89, 0.09, 0.05}),		-- Intervene
	},
	PRIEST = {
		[139]		= UF:AuraWatch_AddSpell(139, 'BOTTOMLEFT', {0.4, 0.7, 0.2}),		-- Renew
		[17]		= UF:AuraWatch_AddSpell(17, 'TOPLEFT', {0.7, 0.7, 0.7}, true), 		-- Power Word: Shield
		[193065]	= UF:AuraWatch_AddSpell(193065, 'BOTTOMRIGHT', {0.54, 0.21, 0.78}),	-- Masochism
		[194384]	= UF:AuraWatch_AddSpell(194384, 'TOPRIGHT', {1, 1, 0.66}), 			-- Atonement
		[214206]	= UF:AuraWatch_AddSpell(214206, 'TOPRIGHT', {1, 1, 0.66}), 			-- Atonement (PvP)
		[33206]		= UF:AuraWatch_AddSpell(33206, 'LEFT', {0.47, 0.35, 0.74}, true),	-- Pain Suppression
		[41635]		= UF:AuraWatch_AddSpell(41635, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}),		-- Prayer of Mending
		[47788]		= UF:AuraWatch_AddSpell(47788, 'LEFT', {0.86, 0.45, 0}, true), 		-- Guardian Spirit
		[6788]		= UF:AuraWatch_AddSpell(6788, 'BOTTOMLEFT', {0.89, 0.1, 0.1}), 		-- Weakened Soul
	},
	DRUID = {
		[774]		= UF:AuraWatch_AddSpell(774, 'TOPRIGHT', {0.8, 0.4, 0.8}), 			-- Rejuvenation
		[155777]	= UF:AuraWatch_AddSpell(155777, 'RIGHT', {0.8, 0.4, 0.8}), 			-- Germination
		[8936]		= UF:AuraWatch_AddSpell(8936, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),		-- Regrowth
		[33763]		= UF:AuraWatch_AddSpell(33763, 'TOPLEFT', {0.4, 0.8, 0.2}), 		-- Lifebloom
		[188550]	= UF:AuraWatch_AddSpell(188550, 'TOPLEFT', {0.4, 0.8, 0.2}),		-- Lifebloom (Shadowlands Legendary)
		[48438]		= UF:AuraWatch_AddSpell(48438, 'BOTTOMRIGHT', {0.8, 0.4, 0}),		-- Wild Growth
		[207386]	= UF:AuraWatch_AddSpell(207386, 'TOP', {0.4, 0.2, 0.8}), 			-- Spring Blossoms
		[102351]	= UF:AuraWatch_AddSpell(102351, 'LEFT', {0.2, 0.8, 0.8}),			-- Cenarion Ward (Initial Buff)
		[102352]	= UF:AuraWatch_AddSpell(102352, 'LEFT', {0.2, 0.8, 0.8}),			-- Cenarion Ward (HoT)
		[200389]	= UF:AuraWatch_AddSpell(200389, 'BOTTOM', {1, 1, 0.4}),				-- Cultivation
		[203554]	= UF:AuraWatch_AddSpell(203554, 'TOP', {1, 1, 0.4}),				-- Focused Growth (PvP)
	},
	PALADIN = {
		[53563]		= UF:AuraWatch_AddSpell(53563, 'TOPRIGHT', {0.7, 0.3, 0.7}),			-- Beacon of Light
		[156910]	= UF:AuraWatch_AddSpell(156910, 'TOPRIGHT', {0.7, 0.3, 0.7}),			-- Beacon of Faith
		[200025]	= UF:AuraWatch_AddSpell(200025, 'TOPRIGHT', {0.7, 0.3, 0.7}),			-- Beacon of Virtue
		[1022]		= UF:AuraWatch_AddSpell(1022, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true), 		-- Blessing of Protection
		[1044]		= UF:AuraWatch_AddSpell(1044, 'BOTTOMRIGHT', {0.89, 0.45, 0}, true),	-- Blessing of Freedom
		[6940]		= UF:AuraWatch_AddSpell(6940, 'BOTTOMRIGHT', {0.89, 0.1, 0.1}, true),	-- Blessing of Sacrifice
		[204018]	= UF:AuraWatch_AddSpell(204018, 'BOTTOMRIGHT', {0.2, 0.2, 1}, true),	-- Blessing of Spellwarding
		[223306]	= UF:AuraWatch_AddSpell(223306, 'BOTTOMLEFT', {0.7, 0.7, 0.3}),			-- Bestow Faith
		[287280]	= UF:AuraWatch_AddSpell(287280, 'TOPLEFT', {0.2, 0.8, 0.2}),			-- Glimmer of Light (T50 Talent)
		[157047]	= UF:AuraWatch_AddSpell(157047, 'TOP', {0.15, 0.58, 0.84}),				-- Saved by the Light (T25 Talent)
	},
	SHAMAN = {
		[61295]		= UF:AuraWatch_AddSpell(61295, 'TOPRIGHT', {0.7, 0.3, 0.7}),		-- Riptide
		[974]		= UF:AuraWatch_AddSpell(974, 'BOTTOMRIGHT', {0.2, 0.2, 1}),			-- Earth Shield
	},
	HUNTER = {
		[90361]		= UF:AuraWatch_AddSpell(90361, 'TOP', {0.34, 0.47, 0.31}),			-- Spirit Mend (HoT)
	},
	MONK = {
		[115175]	= UF:AuraWatch_AddSpell(115175, 'TOP', {0.6, 0.9, 0.9}),			-- Soothing Mist
		[116841]	= UF:AuraWatch_AddSpell(116841, 'RIGHT', {0.12, 1.00, 0.53}),		-- Tiger's Lust (Freedom)
		[116849]	= UF:AuraWatch_AddSpell(116849, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Life Cocoon
		[119611]	= UF:AuraWatch_AddSpell(119611, 'TOPLEFT', {0.3, 0.8, 0.6}),		-- Renewing Mist
		[124682]	= UF:AuraWatch_AddSpell(124682, 'BOTTOMLEFT', {0.8, 0.8, 0.25}),	-- Enveloping Mist
		[191840]	= UF:AuraWatch_AddSpell(191840, 'BOTTOMRIGHT', {0.27, 0.62, 0.7}),	-- Essence Font
		[325209]	= UF:AuraWatch_AddSpell(325209, 'BOTTOM', {0.3, 0.6, 0.6}),			-- Enveloping Breath
	},
	PET = {
		-- Warlock Pets
		[193396]	= UF:AuraWatch_AddSpell(193396, 'TOPRIGHT', {0.6, 0.2, 0.8}, true),		-- Demonic Empowerment
		-- Hunter Pets
		[272790]	= UF:AuraWatch_AddSpell(272790, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Frenzy
		[136]		= UF:AuraWatch_AddSpell(136, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Mend Pet
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
