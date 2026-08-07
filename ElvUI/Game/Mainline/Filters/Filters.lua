local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- This used to be standalone and is now merged into G.unitframe.aurafilters.Whitelist
G.unitframe.aurafilters.PlayerBuffs = nil

G.unitframe.aurafilters.ClassDebuffs = {
	type = 'Whitelist',
	desc = L["Only important debuffs which influence your action priority. Recommended to be paired with 'Non Personal' set to 'Block'."],
	spells = {}
}

G.unitframe.aurafilters.ImportantCC = {
	type = 'Whitelist',
	desc = L["Only important CC debuffs like Polymorph, Hex, Stuns. Also includes important cc-like debuffs, for example Mind Soothe and Solar Beam."],
	spells = {}
}

G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	desc = L["Debuffs that are some form of CC. This can be stuns, roots, slows, etc."],
	spells = {}
}

G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	desc = L["Immunity buffs like Bubble and Ice Block, but also most major defensive class cooldowns."],
	spells = {}
}

G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	desc = L["Auras you don't want to see on your frames."],
	spells = {
		-- Rogue Poisons
		[2823]		= List(nil, false), -- Deadly Poison
		[315584]	= List(nil, false), -- Instant Poison
		[3408]		= List(nil, false), -- Crippling Poison
		[381637]	= List(nil, false), -- Atrophic Poison
		[381664]	= List(nil, false), -- Amplifying Poison
		[8679]		= List(nil, false), -- Wound Poison
		-- Shaman Imbuements
		[319773]	= List(nil, false), -- Windfury Weapon
		[319778]	= List(nil, false), -- Flametongue Weapon
		[382021]	= List(nil, false), -- Earthliving Weapon
		[382022]	= List(nil, false), -- Earthliving Weapon
		[457496]	= List(nil, false), -- Tidecaller's Guard
		[457481]	= List(nil, false), -- Tidecaller's Guard
		[462757]	= List(nil, false), -- Thunderstrike Ward
		[462742]	= List(nil, false), -- Thunderstrike Ward
		-- Skyriding
		[404464]	= List(), -- Flight Style: Skyriding
		[404468]	= List(), -- Flight Style: Steady
		[427490]	= List(), -- Ride Along
		[447959]	= List(), -- Ride Along - Enabled
		[447960]	= List(), -- Ride Along - Inactive
		-- The rest
		[160455]	= List(), -- Hunter Pet Fatigued
		[26013]		= List(), -- Deserter
		[264689]	= List(), -- Hunter Pet Fatigued
		[377234]	= List(), -- Thrill of the Skies
		[390435]	= List(), -- Exhaustion
		[433568]	= List(), -- Rite of Sanctification
		[433583]	= List(), -- Rite of Adjuration
		[57723]		= List(), -- Exhaustion
		[57724]		= List(), -- Sated
		[71041]		= List(), -- Dungeon Deserter
		[80354]		= List(), -- Temporal Displacement
		[95809]		= List(), -- Hunter Pet Insanity
		-- 12.1
		[8326]		= List(), -- Ghost
		[8733]		= List(), -- Blessing of Blackfathom
		[15007]		= List(), -- Ress Sickness
		[23445]		= List(), -- Evil Twin
		[24755]		= List(), -- Tricked or Treated
		[25163]		= List(), -- Oozeling's Disgusting Aura
		[25771]		= List(), -- Forbearance
		[36032]		= List(), -- Arcane Charge
		[36893]		= List(), -- Transporter Malfunction
		[36900]		= List(), -- Soul Split: Evil!
		[36901]		= List(), -- Soul Split: Good
		[41425]		= List(), -- Hypothermia
		[49822]		= List(), -- Bloated
		[55711]		= List(), -- Weakened Heart
		[58539]		= List(), -- Watcher's Corpse
		[89140]		= List(), -- Demonic Rebirth: Cooldown
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
		[392960]	= List(), -- Waygate Travel
		[392992]	= List(), -- Silent Lava
		[393798]	= List(), -- Activated Defense Systems
		[418990]	= List(), -- Wicker Men's Curse
		[426790]	= List(), -- Call of the Elder Druid
		[430191]	= List(), -- Warband Mentored Leveling
		[455020]	= List(), -- WoW's Anniversary
		[1219312]	= List(), -- Mmm, Tacos...
		[1226677]	= List(), -- Cartel Jumper Cables
	}
}

G.unitframe.aurafilters.Blocklist = {
	type = 'Blacklist',
	desc = L["Non-Secret Auras you don't want to see on your frames."],
	spells = {
		-- Rogue Poisons
		[2823]		= List(nil, false), -- Deadly Poison
		[315584]	= List(nil, false), -- Instant Poison
		[3408]		= List(nil, false), -- Crippling Poison
		[381637]	= List(nil, false), -- Atrophic Poison
		[381664]	= List(nil, false), -- Amplifying Poison
		[8679]		= List(nil, false), -- Wound Poison
		-- Shaman Imbuements
		[319773]	= List(nil, false), -- Windfury Weapon
		[319778]	= List(nil, false), -- Flametongue Weapon
		[382021]	= List(nil, false), -- Earthliving Weapon
		[382022]	= List(nil, false), -- Earthliving Weapon
		[457496]	= List(nil, false), -- Tidecaller's Guard
		[457481]	= List(nil, false), -- Tidecaller's Guard
		[462757]	= List(nil, false), -- Thunderstrike Ward
		[462742]	= List(nil, false), -- Thunderstrike Ward
		-- Skyriding
		[404464]	= List(), -- Flight Style: Skyriding
		[404468]	= List(), -- Flight Style: Steady
		[427490]	= List(), -- Ride Along
		[447959]	= List(), -- Ride Along - Enabled
		[447960]	= List(), -- Ride Along - Inactive
		-- The rest
		[160455]	= List(), -- Hunter Pet Fatigued
		[26013]		= List(), -- Deserter
		[264689]	= List(), -- Hunter Pet Fatigued
		[377234]	= List(), -- Thrill of the Skies
		[390435]	= List(), -- Exhaustion
		[433568]	= List(), -- Rite of Sanctification
		[433583]	= List(), -- Rite of Adjuration
		[57723]		= List(), -- Exhaustion
		[57724]		= List(), -- Sated
		[71041]		= List(), -- Dungeon Deserter
		[80354]		= List(), -- Temporal Displacement
		[95809]		= List(), -- Hunter Pet Insanity
	}
}

G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	desc = L["Auras which should always be displayed."],
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
		[199203]	= List(), -- Thirst for Battle
		[97462]		= List(), -- Rallying Cry
	}
}

G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	desc = L["List of important Dungeon and Raid debuffs. Includes affixes and utility on dead players like pending resurrection and available reincarnation."],
	spells = {}
}

-- Buffs applied by bosses, adds or trash
G.unitframe.aurafilters.RaidBuffsElvUI = {
	type = 'Whitelist',
	desc = L["List of important Dungeon and Raid buffs."],
	spells = {}
}

-- Aura indicators on UnitFrames (Hots, Shields, Externals)
G.unitframe.aurawatch = {
	EVOKER = {
		-- All
		[381748]	= Aura(381748, {381732, 381741, 381746, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758}, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Blessing of the Bronze
		-- Preservation
		[355941]	= Aura(355941, nil, true, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Dream Breath
		[376788]	= Aura(376788, nil, true, 'TOPRIGHT', {0.25, 0.25, 0.58}, nil, nil, nil, -20), -- Dream Breath (echo)
		[363502]	= Aura(363502, nil, true, 'BOTTOMLEFT', {0.33, 0.33, 0.70}), -- Dream Flight
		[366155]	= Aura(366155, nil, true, 'BOTTOMRIGHT', {0.14, 1.00, 0.88}), -- Reversion
		[367364]	= Aura(367364, nil, true, 'BOTTOMRIGHT', {0.09, 0.69, 0.61}, nil, nil, nil, -20), -- Reversion (echo)
		[373267]	= Aura(373267, nil, true, 'RIGHT', {0.82, 0.29, 0.24}), -- Life Bind (Verdant Embrace)
		[364343]	= Aura(364343, nil, true, 'TOP', {0.13, 0.87, 0.50}), -- Echo
		-- Augmentation
		[360827]	= Aura(360827, nil, true, 'TOPRIGHT', {0.33, 0.33, 0.77}), -- Blistering Scales
		[410089]	= Aura(410089, nil, true, 'TOP', {0.13, 0.87, 0.50}), -- Prescience
		[395152]	= Aura(395152, nil, true, 'BOTTOMRIGHT', {0.98, 0.44, 0.00}), -- Ebon Might
		[410263]	= Aura(410263, nil, false, 'TOPLEFT', {0.02, 0.78, 0.43}), -- Inferno's Blessing
		[410686]	= Aura(410686, nil, false, 'TOPLEFT', {0.18, 0.84, 0.78}), -- Symbiotic Bloom
		[413984]	= Aura(413984, nil, false, 'BOTTOM', {0.09, 0.89, 0.86}), -- Shifting Sands
		[369459]	= Aura(369459, nil, false, 'BOTTOMLEFT', {0.59, 0.50, 0.75}, true), -- Source of Magic
	},
	PRIEST = {
		-- All
		[21562]		= Aura(21562, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Power Word: Fortitude
		-- Discipline
		[194384]	= Aura(194384, nil, true, 'TOPRIGHT', {1, 1, 0.66}), -- Atonement
		[17]		= Aura(17, nil, true, 'TOPLEFT', {0.7, 0.7, 0.7}, true), -- Power Word: Shield
		[1253593]	= Aura(1253593, nil, true, 'TOP', {0.71, 0.29, 0.38}), -- Void Shield
		-- Holy
		[41635]		= Aura(41635, nil, true, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}), -- Prayer of Mending
		[139]		= Aura(139, nil, true, 'BOTTOMLEFT', {0.4, 0.7, 0.2}), -- Renew
		[77489]		= Aura(77489, nil, true, 'TOP', {0.75, 1.00, 0.30}), -- Echo of Light
	},
	DRUID = {
		-- All
		[1126]		= Aura(1126, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Mark of the Wild
		[474754]	= Aura(474754, nil, false, 'BOTTOM', {0.59, 0.50, 0.75}, true, true), -- Symbiotic Relationship
		-- Restoration
		[774]		= Aura(774, nil, true, 'TOPRIGHT', {0.8, 0.4, 0.8}), -- Rejuvenation
		[33763]		= Aura(33763, nil, true, 'TOPLEFT', {0.4, 0.8, 0.2}), -- Lifebloom
		[48438]		= Aura(48438, nil, true, 'BOTTOMRIGHT', {0.8, 0.4, 0}), -- Wild Growth
		[8936]		= Aura(8936, nil, true, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Regrowth
		[155777]	= Aura(155777, nil, true, 'RIGHT', {0.8, 0.4, 0.8}), -- Germination
	},
	PALADIN = {
		-- Holy
		[53563]		= Aura(53563, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Light
		[156910]	= Aura(156910, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Faith
		[200025]	= Aura(200025, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Beacon of Virtue
		[156322]	= Aura(156322, nil, true, 'TOPLEFT', {0.2, 0.8, 0.2}), -- Eternal Flame
		[1244893]	= Aura(1244893, nil, true, 'RIGHT', {0.06, 0.77, 0.34}), -- Beacon of the Savior
	},
	SHAMAN = {
		-- All
		[462854]	= Aura(462854, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Skyfury
		-- Restoration
		[61295]		= Aura(61295, nil, true, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Riptide
		[974]		= Aura(974, nil, true, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield
		[383648]	= Aura(383648, nil, true, 'BOTTOMRIGHT', {0.91, 0.80, 0.44}), -- Earth Shield (Elemental Orbit)
		[207400]	= Aura(207400, nil, true, 'TOPLEFT', {0.59, 0.23, 0.70}), -- Ancestral Vigor
		[382024]	= Aura(382024, nil, true, 'TOP', {0.87, 0.98, 0.76}), -- Earthliving Weapon
		[444490]	= Aura(444490, nil, false, 'RIGHT', {0.67, 1.00, 0.62}), -- Hydrobubble
	},
	MONK = {
		-- Mistweaver
		[115175]	= Aura(115175, nil, true, 'TOP', {0.6, 0.9, 0.9}), -- Soothing Mist
		[119611]	= Aura(119611, nil, true, 'TOPLEFT', {0.3, 0.8, 0.6}), -- Renewing Mist
		[450769]	= Aura(450769, nil, true, 'TOPLEFT', {0.3, 0.8, 0.6}), -- Aspect of Harmony (Modified version of Renewing Mist)
		[124682]	= Aura(124682, nil, true, 'BOTTOMLEFT', {0.8, 0.8, 0.25}), -- Enveloping Mist
	},
	MAGE = {
		[1459]		= Aura(1459, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Arcane Intellect
	},
	WARRIOR = {
		[6673]		= Aura(6673, nil, false, 'CENTER', {0.17, 0.94, 0.75}, true, true), -- Battle Shout
	},
	-- Not used for now
	ROGUE = {},
	HUNTER = {},
	PET = {},
	GLOBAL = {},
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
	-- [spellID] = true, -- SpellName
}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {}

-- Auras which should change the color of the UnitFrame
G.unitframe.AuraHighlightColors = {}
