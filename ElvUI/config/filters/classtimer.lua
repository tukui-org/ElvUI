--[[
	ClassTimers

	Configuration functions
	id - spell id
	castByAnyone - show if aura wasn't created by player, set true to show if its by anyone
	color - bar color (nil for default color)
	unitType - 0 all, 1 friendly, 2 enemy
	castSpellId - fill only if you want to see line on bar that indicates if its safe to start casting spell and not clip the last tick, also note that this can be different from aura id 

	Example: CreateSpellEntry( spellID , castByAnyone, color, unitType, castSpellId), 
]]--
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

CreateSpellEntry = function( id, castByAnyone, color, unitType, castSpellId )
	return { enabled = true, id = id, castByAnyone = castByAnyone, color = color, unitType = unitType or 0, castSpellId = castSpellId };
end

TRINKET_FILTER = {
	CreateSpellEntry( 99090 ), --Flaming Aegis, Paladin 4-Piece
	CreateSpellEntry( 96881 ), --Weight of a feather
	CreateSpellEntry( 73422 ), -- Chaos Bane
	CreateSpellEntry( 71905 ), -- Soul Fragment
	CreateSpellEntry( 67671 ), -- Fury(Banner of Victory)
	CreateSpellEntry( 54758 ), -- Hyperspeed Acceleration (Hyperspeed Accelerators)
	CreateSpellEntry( 75170 ), -- Lightweave
	CreateSpellEntry( 2825, true ), --Heroism
	CreateSpellEntry( 32182, true ), -- Bloodlust
	CreateSpellEntry( 90355, true ), -- Hunter Pet Bloodlust
	CreateSpellEntry( 80353 ), -- Time Warp 
	CreateSpellEntry( 26297 ), -- Berserking (troll racial)
	CreateSpellEntry( 33702 ), CreateSpellEntry( 33697 ), CreateSpellEntry( 20572 ), -- Blood Fury (orc racial)
	CreateSpellEntry( 57933, true ), -- Tricks of Trade (15% dmg buff)
	CreateSpellEntry( 90992 ), -- Hymn of Power (H Anhuur's Hymnal)
	CreateSpellEntry( 91149 ), -- Blessing of Isiset (H Blood of Isiset)
	CreateSpellEntry( 91308 ), -- Egg Shell (H Corrupted Egg Shell)
	CreateSpellEntry( 90985 ), -- Dead Winds (H Gale of Shadows)
	CreateSpellEntry( 92087 ), -- Herald of Doom (H Grace of the Herald)
	CreateSpellEntry( 91364 ), -- Heartened (H Heart of Solace)
	CreateSpellEntry( 92187 ), -- Amazing Fortitude (H Heart of Thunder)
	CreateSpellEntry( 92200 ), -- Blademaster (H Impetuous Query)
	CreateSpellEntry( 92091 ), -- Final Key (H Key the Endless Chamber)
	CreateSpellEntry( 92184 ), -- Lead Plating (H Leaden Despair)
	CreateSpellEntry( 92094 ), -- Eye of Vengeance (H Left Eye of Rajh)
	CreateSpellEntry( 91352 ), -- Polarization (H Magnetite Mirror)
	CreateSpellEntry( 91374 ), -- Battle Prowess (H Mark of Khardros)
	CreateSpellEntry( 91340 ), -- Typhoon (H Might of the Ocean)
	CreateSpellEntry( 92174 ), -- Hardened Shell (H Porcelain Crab)
	CreateSpellEntry( 92099 ), -- Speed of Thought (H Skardyn's Grace)
	CreateSpellEntry( 91136 ), -- Leviathan (H Sea Star)
	CreateSpellEntry( 91368 ), -- Eye of Doom (H Right Eye of Rajh)
	CreateSpellEntry( 91141 ), -- Anthem (Rainsong)
	CreateSpellEntry( 91143 ), -- Anthem (H Rainsong)
	CreateSpellEntry( 91002 ), -- Crescendo of Suffering (H Sorrowsong)
	CreateSpellEntry( 91139 ), -- Cleansing Tears (H Tear of Blood)
	CreateSpellEntry( 90898 ), -- Tendrils of Darkness (H Tendrils of the Burrowing Dark)
	CreateSpellEntry( 92205 ), -- Duelist (H Throngus's Finger)
	CreateSpellEntry( 92089 ), -- Grace (H Tia's Grace)
	CreateSpellEntry( 90887 ), -- Witching Hour (H Witching Hourglass)
	CreateSpellEntry( 89181 ), -- Mighty Earthquake (DMC: Earthquake)
	CreateSpellEntry( 89087 ), -- Lightning Strike (DMC: Hurricane)
	CreateSpellEntry( 89182 ), -- Giant Wave (DMC: Tsunami)
	CreateSpellEntry( 89091 ), -- Volcanic Destruction (DMC: Volcano)
	CreateSpellEntry( 92233 ), -- Tectonic Shift (Bedrock Talisman)
	CreateSpellEntry( 91155 ), -- Expansive Soul (Core of Ripeness)
	CreateSpellEntry( 92104 ), -- River of Death (Fluid Death)
	CreateSpellEntry( 91810 ), -- Slayer (License to Slay)
	CreateSpellEntry( 91019 ), -- Soul Power (Soul Casket)
	CreateSpellEntry( 82174 ), -- Synapse Springs
	CreateSpellEntry( 95712 ), -- Gnomish X-Ray Scope
	CreateSpellEntry( 96228 ), -- Synapse Springs (engineer tinker)	
	CreateSpellEntry( 91047 ), -- Battle Magic (Stump of Time)
	CreateSpellEntry( 91821 ), -- Race Against Death (Crushing Weight)
	CreateSpellEntry( 92342 ), -- Race Against Death (H Crushing Weight)
	CreateSpellEntry( 91816 ), -- Rageheart (Heart of Rage)
	CreateSpellEntry( 92345 ), -- Rageheart (H Heart of Rage)
	CreateSpellEntry( 67684 ), -- Hospitality (Talisman of Resurgence)
	CreateSpellEntry( 71584 ), -- Revitalized (Purified Lunar Dust)
	CreateSpellEntry( 92213 ), -- Memory of Invincibility
	CreateSpellEntry( 59473 ), -- Twisted (Essence of the Cyclone)
	CreateSpellEntry(81932), -- Gnomish X-Ray Scope
	CreateSpellEntry(92123), -- Enigma (Unsolvable Riddle)
	CreateSpellEntry( 73549 ), -- Demon Panther (Figurine: Demon Panther)
	CreateSpellEntry( 73552 ), -- Dream Owl (Figurine: Dream Owl)
	CreateSpellEntry( 73550 ), -- Earthen Guardian (Figurine: Earthen Guardian)
	CreateSpellEntry( 73551 ), -- Jeweled Serpent (Figurine: Jeweled Serpent)
	CreateSpellEntry( 73522 ), -- King of Boars (Figurine: King of Boars)
	CreateSpellEntry( 91828 ), -- Thrill of Victory (Impatience of Youth)
	CreateSpellEntry( 91192 ), -- Pattern of Light (Mandala of Stirring Patterns)
	CreateSpellEntry( 92222 ), -- Image of Immortality (Mirror of Broken Images)
	CreateSpellEntry( 92123 ), -- Enigma (Unsolvable Riddle)
	CreateSpellEntry( 91007 ), -- Dire Magic (Bell of Enraging Resonance)
	CreateSpellEntry( 92318 ), -- Dire Magic (H Bell of Enraging Resonance)
	CreateSpellEntry( 91184 ), -- Grounded Soul (Fall of Mortality)
	CreateSpellEntry( 92332 ), -- Grounded Soul (H Fall of Mortality)
	CreateSpellEntry( 91836 ), -- Forged Fury (Fury of Angerforge)
	CreateSpellEntry( 91027 ), -- Heart's Revelation (Heart of Ignacious)
	CreateSpellEntry( 91041 ), -- Heart's Judgement (Heart of Ignacious)
	CreateSpellEntry( 92325 ), -- Heart's Revelation (H Heart of Ignacious)
	CreateSpellEntry( 92328 ), -- Heart's Judgement (H Heart of Ignacious)
	CreateSpellEntry( 92124 ), -- Nefarious Plot (Prestor's Talisman of Machination)
	CreateSpellEntry( 92349 ), -- Nefarious Plot (H Prestor's Talisman of Machination)
	CreateSpellEntry( 92235 ), -- Turn of the Worm (Symbiotic Worm)
	CreateSpellEntry( 92355 ), -- Turn of the Worm (H Symbiotic Worm)
	CreateSpellEntry( 91024 ), -- Revelation (Theralion's Mirror)
	CreateSpellEntry( 92320 ), -- Revelation (H Theralion's Mirror)
	CreateSpellEntry( 92108 ), -- Heedless Carnage (Unheeded Warning)
	CreateSpellEntry( 92213 ), -- Memory of Invincibility (Vial of Stolen Memories)
	CreateSpellEntry( 92357 ), -- Memory of Invincibility (H Vial of Stolen Memories)	
	CreateSpellEntry( 54861 ), -- Nitro Boosts (engineer tinker)
	CreateSpellEntry( 92126 ), -- Twisted (Essence of the Cyclone)
	CreateSpellEntry( 92351 ), -- Twisted (Heroic Essence of the Cyclone)
	CreateSpellEntry( 92220 ), -- Surge of Conquest (PvP Agility Trinket)
	CreateSpellEntry( 92216 ), -- Surge of Conquest	(PvP Strength Trinket)
	CreateSpellEntry( 79633 ), -- Tol'vir Agility (Agility potion)
	CreateSpellEntry( 79475 ), -- Earthen Armor (Armor potion)
	CreateSpellEntry( 79634 ), -- Golem's Strength (Strength potion)
	CreateSpellEntry( 78993 ), -- Concentration (Mana potion)
	CreateSpellEntry( 79476 ), -- Volcanic Power (Spell power potion)
	CreateSpellEntry( 7001 ), -- Lightwell Renew
	CreateSpellEntry( 91832 ), -- Raw Fury
	CreateSpellEntry( 91836 ), -- Forged Fury
	CreateSpellEntry( 74241 ), -- Power Torrent
	CreateSpellEntry( 74243 ), -- Windwalk
	CreateSpellEntry( 74245), -- Landslide
	CreateSpellEntry( 74221), -- Hurricane	
	CreateSpellEntry( 91320 ), -- Inner Eye (Jar of Ancient Remedies)
	CreateSpellEntry( 92329 ), -- Inner Eye (H Jar of Ancient Remedies)
	CreateSpellEntry( 74224 ), -- Heartsong
	CreateSpellEntry( 74225 ), -- Heartsong
	CreateSpellEntry( 91011 ), -- Bell of Enraging Resonance
	CreateSpellEntry( 91048 ), -- Stump of Time
	CreateSpellEntry( 90019 ), -- Soul Casket	
	CreateSpellEntry( 75170 ), -- Lightweave
	CreateSpellEntry( 97129 ), --Loom of fate
	CreateSpellEntry( 96945 ), --Loom of fate
	
	--Turtle Shit
	CreateSpellEntry( 63877, true ), -- Pain Suppression
	CreateSpellEntry( 47788, true ), -- Guardian Spirit	
	CreateSpellEntry( 1044, true ), -- Hand of Freedom
	CreateSpellEntry( 1022, true ), -- Hand of Protection
	CreateSpellEntry( 1038, true ), -- Hand of Salvation
	CreateSpellEntry( 6940, true ), -- Hand of Sacrifice
	CreateSpellEntry( 62618, true ), --Power Word: Barrier
	CreateSpellEntry( 70940, true), -- Divine Guardian 
	
	CreateSpellEntry( 59545 ), CreateSpellEntry( 59543 ), CreateSpellEntry( 59548 ), CreateSpellEntry( 59542 ), CreateSpellEntry( 59544 ), CreateSpellEntry( 59547 ), CreateSpellEntry( 28880 ), -- Gift of the Naaru
	CreateSpellEntry( 74497 ), CreateSpellEntry( 55503 ), CreateSpellEntry( 55502 ), CreateSpellEntry( 55501 ), CreateSpellEntry( 55500 ), CreateSpellEntry( 55480 ), CreateSpellEntry( 55428 ), CreateSpellEntry( 81708 ), -- Lifeblood
}

CLASS_FILTERS = {
	DEATHKNIGHT = { 
		target = {
			CreateSpellEntry( 55095 ), -- Frost Fever
			CreateSpellEntry( 55078 ), -- Blood Plague
			CreateSpellEntry( 81130 ), -- Scarlet Fever
			CreateSpellEntry( 50536 ), -- Unholy Blight
			CreateSpellEntry( 65142 ), -- Ebon Plague
			CreateSpellEntry( 73975 ), -- Necrotic Strike
		},
		player = {
			CreateSpellEntry( 59052 ), -- Freezing Fog
			CreateSpellEntry( 51124 ), -- Killing Machine
			CreateSpellEntry( 49016 ), -- Unholy Frenzy
			CreateSpellEntry( 57330 ), -- Horn of Winter
			CreateSpellEntry( 70654 ), -- Blood Armor
			CreateSpellEntry( 77535 ), -- Blood Shield
			CreateSpellEntry( 55233 ), -- Vampiric Blood
			CreateSpellEntry( 81141 ), -- Blood Swarm
			CreateSpellEntry( 45529 ), -- Blood Tap
			CreateSpellEntry( 49222 ), -- Bone sheild
			CreateSpellEntry( 48792 ), -- Ice Bound Fortitude
			CreateSpellEntry( 49028 ), -- Dancing Rune Weapon
			CreateSpellEntry( 51271 ), -- Pillar of Frost
			CreateSpellEntry( 48707 ), -- Anti-Magic Shell
			CreateSpellEntry( 49039 ), -- Lichborne			
		},
		procs = {
			CreateSpellEntry( 53365 ), -- Unholy Strength
			CreateSpellEntry( 64856 ), -- Blade barrier
			CreateSpellEntry( 70657 ), -- Advantage
			CreateSpellEntry( 81340 ), -- Sudden Doom
		},
	},
	DRUID = { 
		target = { 
			CreateSpellEntry( 48438 ), -- Wild Growth
			CreateSpellEntry( 774 ), -- Rejuvenation
			CreateSpellEntry( 8936, false, nil, nil, 8936 ), -- Regrowth
			CreateSpellEntry( 33763 ), -- Lifebloom
			CreateSpellEntry( 5570 ), -- Insect Swarm
			CreateSpellEntry( 8921 ), -- Moonfire
			CreateSpellEntry( 339 ), -- Entangling Roots
			CreateSpellEntry( 33786 ), -- Cyclone
			CreateSpellEntry( 2637 ), -- Hibernate
			CreateSpellEntry( 2908 ), -- Soothe
			CreateSpellEntry( 50259 ), -- Feral Charge (Cat) - daze
			CreateSpellEntry( 45334 ), -- Feral Charge (Bear) - immobilize
			CreateSpellEntry( 58180 ), -- Infected Wounds
			CreateSpellEntry( 6795 ), -- Growl
			CreateSpellEntry( 5209 ), -- Challenging Roar
			CreateSpellEntry( 99 ), -- Demoralizing Roar
			CreateSpellEntry( 33745 ), -- Lacerate
			CreateSpellEntry( 5211 ), -- Bash
			CreateSpellEntry( 80964 ), -- Skull Bash (Bear)
			CreateSpellEntry( 80965 ), -- Skull Bash (Cat)
			CreateSpellEntry( 22570 ), -- Maim
			CreateSpellEntry( 1822 ), -- Rake
			CreateSpellEntry( 1079 ), -- Rip
			CreateSpellEntry( 33878, true ), -- Mangle (Bear)
			CreateSpellEntry( 33876, true ), -- Mangle (Cat)
			CreateSpellEntry( 9007 ), -- Pounce bleed
			CreateSpellEntry( 9005 ), -- Pounce stun
			CreateSpellEntry( 16857, true ), -- Faerie Fire (Feral)
			CreateSpellEntry( 770, true ), -- Farie Fire
			CreateSpellEntry( 467 ), -- Thorns
			CreateSpellEntry( 78675 ), -- Solar Beam
			CreateSpellEntry( 93402 ), -- Sunfire
			CreateSpellEntry( 77758 ), -- Thrash
		},
		player = {
			CreateSpellEntry( 48505 ), -- Starfall
			CreateSpellEntry( 29166 ), -- Innervate
			CreateSpellEntry( 22812 ), -- Barkskin
			CreateSpellEntry( 5215 ), -- Prowl
			CreateSpellEntry( 16689 ), -- Nature's Grasp
			CreateSpellEntry( 17116 ), -- Nature's Swiftness
			CreateSpellEntry( 5229 ), -- Enrage
			CreateSpellEntry( 52610 ), -- Savage Roar
			CreateSpellEntry( 5217 ), -- Tiger's Fury
			CreateSpellEntry( 1850 ), -- Dash
			CreateSpellEntry( 22842 ), -- Frenzied Regeneration
			CreateSpellEntry( 50334 ), -- Berserk
			CreateSpellEntry( 61336 ), -- Survival Instincts
			CreateSpellEntry( 48438 ), -- Wild Growth
			CreateSpellEntry( 774 ), -- Rejuvenation
			CreateSpellEntry( 8936, false, nil, nil, 8936 ), -- Regrowth
			CreateSpellEntry( 33763 ), -- Lifebloom
			CreateSpellEntry( 467 ), -- Thorns
			CreateSpellEntry( 80951 ), -- Pulverize
			CreateSpellEntry( 62600 ), --[[ Savage Defense]] CreateSpellEntry( 62606 ), -- Savage Defense
			CreateSpellEntry( 33891 ), --Tree of life
		},
		procs = {
			CreateSpellEntry( 16870 ), -- Clearcasting
			CreateSpellEntry( 48518 ), -- Eclipse Lunar
			CreateSpellEntry( 48517 ), -- Eclipse Solar
			CreateSpellEntry( 69369 ), -- Predator's Swiftness
			CreateSpellEntry( 93400 ), -- Shooting Stars
			CreateSpellEntry( 81192 ), -- Lunar Shower
		},
	},
	HUNTER = { 
		target = {
			CreateSpellEntry( 49050 ), -- Aimed Shot
			CreateSpellEntry( 53238 ), -- Piercing Shots
			CreateSpellEntry( 3674 ), -- Black Arrow
			CreateSpellEntry( 82654 ), -- Widow Venom
			CreateSpellEntry( 34490 ), -- Silencing Shot
			CreateSpellEntry( 37506 ), -- Scatter Shot
			CreateSpellEntry( 53243 ), -- Marker for death, need to be changed I think
			CreateSpellEntry( 1130 ), -- Hunters mark
			CreateSpellEntry( 88453 ), --Serpent Sting
			CreateSpellEntry( 88466 ), --Serpent Sting
			CreateSpellEntry( 1978 ), --Serpent sting
			CreateSpellEntry( 90337 ), --Bad Manner
			CreateSpellEntry( 53301 ), --Explosive Shot
			CreateSpellEntry( 13809 ), -- Ice Trap
		},
		player = {
			CreateSpellEntry( 82749 ), -- killing streak
			CreateSpellEntry( 3045 ), -- Rapid Fire
			CreateSpellEntry( 34471 ), --The beast within
			CreateSpellEntry( 77769 ), -- Trap Launcher
			CreateSpellEntry( 19263 ), -- Detterence
			CreateSpellEntry( 53434 ), -- Call of the Wild
		},
		procs = {
			CreateSpellEntry( 53257 ), -- cobra strikes 
			CreateSpellEntry( 6150 ), -- Quick Shots
			CreateSpellEntry( 56453 ), -- Lock and Load
			CreateSpellEntry( 82692 ), --Focus Fire
			CreateSpellEntry( 35099 ), --Rapid Killing Rank 2
			CreateSpellEntry( 53220 ), -- Improved Steadyshot
			CreateSpellEntry( 70728 ), -- Exploit Weakness (2pc t10)
			CreateSpellEntry( 71007 ), -- Stinger (4pc t10)
			CreateSpellEntry( 63087 ), -- Glyph of Raptor stike
			CreateSpellEntry( 82925 ), -- Mastermarksman
			CreateSpellEntry( 82926 ), -- Fire!			
		},
	},
	MAGE = {
		target = { 
			CreateSpellEntry( 44457 ), -- Living Bomb
			CreateSpellEntry( 118 ), -- Polymorph
			CreateSpellEntry( 28271 ), -- Polymorph Turtle
			CreateSpellEntry( 31589 ), -- Slow
			CreateSpellEntry( 116 ), -- Frostbolt
			CreateSpellEntry( 120 ), -- Cone of Cold
			CreateSpellEntry( 122 ), -- Frost Nova
			CreateSpellEntry( 44614 ), -- Frostfire Bolt
			CreateSpellEntry( 92315 ), -- Pyroblast!
			CreateSpellEntry( 12654 ), -- Ignite
			CreateSpellEntry( 22959 ), -- Critical Mass
			CreateSpellEntry( 83853 ), -- Combustion
			CreateSpellEntry( 31661 ), -- Dragon's Breath
			CreateSpellEntry( 83154 ), -- Piercing Chill
			CreateSpellEntry( 44572 ), -- Deep Freeze
			CreateSpellEntry( 11366 ), -- Dot Pyroblast
		},
		player = {
			CreateSpellEntry( 36032 ), -- Arcane Blast
			CreateSpellEntry( 12042 ), -- Arcane Power
			CreateSpellEntry( 32612 ), -- Invisibility
			CreateSpellEntry( 1463 ), -- Mana Shield
			CreateSpellEntry( 543 ), -- Mage Ward
			CreateSpellEntry( 11426 ), -- Ice Barrier
			CreateSpellEntry( 45438 ), -- Ice Block
			CreateSpellEntry( 12472 ), -- Icy Veins
			CreateSpellEntry( 130 ), -- Slow Fall
			CreateSpellEntry( 57761 ), -- Brain Freeze
		},
		procs = {
			CreateSpellEntry( 44544 ), -- Fingers of Frost
			CreateSpellEntry( 79683 ), -- Arcane Missiles!
			CreateSpellEntry( 48108 ), -- Hot Streak
			CreateSpellEntry( 64343 ), -- Impact
			CreateSpellEntry( 12536 ), -- Clearcasting
		},
	},
	PALADIN = { 
		target = {
			CreateSpellEntry( 31803 ), -- Censure 
			CreateSpellEntry( 20066 ), -- Repentance 
			CreateSpellEntry( 853 ), -- Hammer of Justice 
			CreateSpellEntry( 31935 ), -- Avenger's Shield 
			CreateSpellEntry( 20170 ), -- Seal of Justice 
			CreateSpellEntry( 26017 ), -- Vindication 
			CreateSpellEntry( 68055 ), -- Judgements of the Just 
			CreateSpellEntry( 86273 ), -- Illuminated Healing
			CreateSpellEntry( 1044 ), -- Hand of Freedom
			CreateSpellEntry( 1022 ), -- Hand of Protection
			CreateSpellEntry( 1038 ), -- Hand of Salvation
			CreateSpellEntry( 6940 ), -- Hand of Sacrifice
		},
		player = {
			CreateSpellEntry( 642 ), -- Divine Shield
			CreateSpellEntry( 31850 ), -- Ardent Defender
			CreateSpellEntry( 498 ), -- Divine Protection
			CreateSpellEntry( 84963 ), -- Inquisition
			CreateSpellEntry( 31884 ), -- Avenging Wrath
			CreateSpellEntry( 87342, nil, {r=235/255, g=232/255, b=101/255}), -- Holy Shield
			CreateSpellEntry( 85433 ), -- Sacred Duty
			CreateSpellEntry( 85416 ), --Grand Crusader
			CreateSpellEntry( 85696 ), -- Zealotry
			CreateSpellEntry( 53657 ), -- Judgements of the Pure
			CreateSpellEntry( 53563 ), -- Beacon of Light
			CreateSpellEntry( 31821 ), -- Aura Mastery
			CreateSpellEntry( 54428 ), -- Divine Plea
			CreateSpellEntry( 86659 ), --Guardian of Ancient Kings (Prot)
			CreateSpellEntry( 86669 ), --Guardian of Ancient Kings (Holy)
			CreateSpellEntry( 86698 ), --Guardian of Ancient Kings (Ret)
			CreateSpellEntry( 85510 ), --Denounce
			CreateSpellEntry( 88063 ), --Guarded by the light
			CreateSpellEntry( 82327	), --Holy Radiance
			CreateSpellEntry( 20925 ), --Holy Shield
			CreateSpellEntry( 94686, nil, {r=235/255, g=232/255, b=101/255}), -- Crusade
		},
		procs = {
			CreateSpellEntry( 59578 ), -- The Art of War
			CreateSpellEntry( 90174 ), -- Hand of Light
			CreateSpellEntry( 71396 ), -- Rage of the Fallen		
			CreateSpellEntry( 53672 ), CreateSpellEntry( 54149 ), -- Infusion of Light (Rank1/Rank2)
			CreateSpellEntry( 85496 ), -- Speed of Light
			CreateSpellEntry( 88819 ), -- Daybreak
			CreateSpellEntry( 20050 ), CreateSpellEntry( 20052 ), CreateSpellEntry( 20053 ), -- Conviction (Rank1/Rank2/Rank3)
		},
	},
	PRIEST = { 
		target = { 
			CreateSpellEntry( 17 ), -- Power Word: Shield
			CreateSpellEntry( 6788, true, nil, 1 ), -- Weakened Soul
			CreateSpellEntry( 139 ), -- Renew
			CreateSpellEntry( 33076 ), -- Prayer of Mending
			CreateSpellEntry( 63877 ), -- Pain Suppression
			CreateSpellEntry( 34914, false, nil, nil, 34914 ), -- Vampiric Touch
			CreateSpellEntry( 589 ), -- Shadow Word: Pain
			CreateSpellEntry( 2944 ), -- Devouring Plague
			CreateSpellEntry( 47788	), -- Guardian Spirit
			CreateSpellEntry( 77489 ), -- Echo of Light
			CreateSpellEntry( 9484 ), -- Shackle Undead
			CreateSpellEntry( 34914, false, nil, nil, 34914 ), -- Vampiric Touch
			CreateSpellEntry( 34914 ), -- Vampiric Touch	
		},
		player = {
			CreateSpellEntry( 10060 ), -- Power Infusion
			CreateSpellEntry( 47585 ), -- Dispersion
			CreateSpellEntry( 81700 ), -- Archangel
			CreateSpellEntry( 87153 ), -- Dark Archangel
			CreateSpellEntry( 14751 ), -- Chakra
			CreateSpellEntry( 81208 ), -- Chakra Heal
			CreateSpellEntry( 81207 ), -- Chakra Renew
			CreateSpellEntry( 81209 ), -- Chakra Smite
			CreateSpellEntry( 81206 ), -- Prayer of Healing
			CreateSpellEntry( 27827	), -- Spirit of Redemption
			CreateSpellEntry( 586 ), -- Fade			
		},
		procs = {
			CreateSpellEntry( 63735 ), -- Serendipity
			CreateSpellEntry( 88690 ), -- Surge of Light
			CreateSpellEntry( 77487 ), -- Shadow Orb
			CreateSpellEntry( 71572 ), -- Cultivated Power
			CreateSpellEntry( 81661 ), -- Evangelism
			CreateSpellEntry( 72418 ), -- Kuhlendes Wissen
			CreateSpellEntry( 71584 ), -- Revitalize
			CreateSpellEntry( 95799 ), -- Empowered Shadow
			CreateSpellEntry( 65081	), -- Body and Soul
			CreateSpellEntry( 88688	), -- Surge of Light	
			CreateSpellEntry( 87117 ), -- Dark Evangelism
			CreateSpellEntry( 87118 ), -- Dark Evangelism			
		},
	},
	ROGUE = { 
		target = { 
			CreateSpellEntry( 1833 ), -- Cheap Shot
			CreateSpellEntry( 408 ), -- Kidney Shot
			CreateSpellEntry( 1776 ), -- Gouge
			CreateSpellEntry( 2094 ), -- Blind
			CreateSpellEntry( 8647 ), -- Expose Armor
			CreateSpellEntry( 51722 ), -- Dismantle
			CreateSpellEntry( 2818 ), -- Deadly Poison
			CreateSpellEntry( 13218 ), -- Wound Posion
			CreateSpellEntry( 3409 ),  -- Crippling Poison 
			CreateSpellEntry( 5760 ), -- Mind-Numbing Poison
			CreateSpellEntry( 6770 ), -- Sap
			CreateSpellEntry( 1943 ), -- Rupture
			CreateSpellEntry( 703 ), -- Garrote
			CreateSpellEntry( 79140 ), -- vendetta
			CreateSpellEntry( 16511 ), -- Hemorrhage
		},
		player = {
			CreateSpellEntry( 32645 ), -- Envenom
			CreateSpellEntry( 2983 ), -- Sprint
			CreateSpellEntry( 5277 ), -- Evasion
			CreateSpellEntry( 1776 ), -- Gouge
			CreateSpellEntry( 51713 ), -- Shadow Dance
			CreateSpellEntry( 1966 ), -- Feint
			CreateSpellEntry( 73651 ), -- Recuperate
			CreateSpellEntry( 5171 ), -- Slice and Dice
			CreateSpellEntry( 13877 ), -- Blade Flurry
			CreateSpellEntry( 58426 ), CreateSpellEntry( 58427 ), --Overkill
			CreateSpellEntry( 74001 ), --combat readiness
		},
		procs = {
			CreateSpellEntry( 71396 ), -- Rage of the Fallen
		},
	},
	SHAMAN = {
		target = {
			CreateSpellEntry( 974 ), -- Earth Shield
			CreateSpellEntry( 8050), -- Flame Shock
			CreateSpellEntry( 8056 ), -- Frost Shock
			CreateSpellEntry( 17364 ), -- Storm Strike
			CreateSpellEntry( 61295 ), -- Riptide
			CreateSpellEntry( 51945 ), -- Earthliving
			CreateSpellEntry( 77661 ), -- Searing Flames
			CreateSpellEntry( 51514 ), -- Hex
		},
		player = {
			CreateSpellEntry( 324 ), -- Lightning Shield
			CreateSpellEntry( 52127 ), -- Water Shield
			CreateSpellEntry( 974 ), -- Earth Shield
			CreateSpellEntry( 30823 ), -- Shamanistic Rage
			CreateSpellEntry( 55198 ), -- Tidal Force
			CreateSpellEntry( 61295 ), -- Riptide
			CreateSpellEntry( 16166 ), -- Elemental Mastery (instant cast)
			CreateSpellEntry( 64701 ), -- Elemental Mastery (damage increase)
			CreateSpellEntry( 16188 ), -- Nature Swiftness	
			CreateSpellEntry( 79206 ), -- Spiritwalker's Grace
		},
		procs = {
			CreateSpellEntry( 53817 ), -- Maelstrom Weapon
			CreateSpellEntry( 53390 ), -- Tidal Waves
			CreateSpellEntry( 16246 ), -- Clearcasting
			CreateSpellEntry( 73685 ), -- Unleash Life
			CreateSpellEntry( 73683 ), -- Unleash Fire
			CreateSpellEntry( 73681 ), -- Unleash Wind			
		},
	},
	WARLOCK = {
		target = {
				CreateSpellEntry( 48181, false, nil, nil, 48181 ), -- Haunt
				CreateSpellEntry( 32389 ), -- Shadow Embrace
				CreateSpellEntry( 172 ), -- Corruption
				CreateSpellEntry( 30108, false, nil, nil, 30108 ), -- Unstable Affliction
				CreateSpellEntry( 603 ), -- Curse of Doom
				CreateSpellEntry( 980 ), -- Curse of Agony
				CreateSpellEntry( 1490 ), -- Curse of the Elements
				CreateSpellEntry( 17962 ), -- Conflagration
				CreateSpellEntry( 348, false, nil, nil, 348 ), -- Immolate
				CreateSpellEntry( 27243, false, nil, nil, 27243 ), -- Seed of Corruption
				CreateSpellEntry( 17941 ), -- Shadow trance
				CreateSpellEntry( 64371 ), -- Eradication
				CreateSpellEntry( 1714 ), -- Curse of Tongue
				CreateSpellEntry( 18223 ), -- Curse of Exhaustion
				CreateSpellEntry( 18179 ), -- Jinx
				CreateSpellEntry( 47960 ), -- Shadowflame
				CreateSpellEntry( 6789 ), -- Death Coil
				CreateSpellEntry( 6358 ), -- Seduction
				CreateSpellEntry( 5782, false, nil, nil, 5782 ), -- Fear
				CreateSpellEntry( 702 ), -- Curse of Weakness
				CreateSpellEntry( 710, false, nil, nil, 710 ), -- Banish
				CreateSpellEntry( 17801 ), -- Shadow and Flame
				CreateSpellEntry( 80240 ), -- Bane of Havoc
		},
		player = {
			CreateSpellEntry( 17941 ), -- Shadow trance
			CreateSpellEntry( 64371 ), -- Eradication
			CreateSpellEntry( 85403 ), -- Hellfire
			CreateSpellEntry( 48018 ), -- Demon Circle: Summon
			CreateSpellEntry( 86121 ), -- Soul Swap
			CreateSpellEntry( 74434 ), -- Soulburn
			CreateSpellEntry( 6229 ), -- Shadow Ward
			CreateSpellEntry( 79459 ), -- Demon Soul (Imp)
			CreateSpellEntry( 79463 ), -- Demon Soul (Succubus)
			CreateSpellEntry( 79460 ), -- Demon Soul (Felhunter)
			CreateSpellEntry( 79464 ), -- Demon Soul (Voidwalker)
			CreateSpellEntry( 79462 ), -- Demon Soul (Felguard)
		},
		procs = {
			CreateSpellEntry( 54274 ), CreateSpellEntry( 54276 ), CreateSpellEntry( 54277 ), -- Backdraft rank 1/2/3
			CreateSpellEntry( 71165 ), -- Molten Cor
			CreateSpellEntry( 63167 ), -- Decimation
			CreateSpellEntry( 85383, false, nil, nil, 6353 ), -- Imp Soul Fire
			CreateSpellEntry( 47283 ), -- Empowered Imp
		},
	},
	WARRIOR = { 
		target = {
			CreateSpellEntry( 94009 ), -- Rend
			CreateSpellEntry( 12294 ), -- Mortal Strike
			CreateSpellEntry( 1160 ), -- Demoralizing Shout
			CreateSpellEntry( 64382 ), -- Shattering Throw
			CreateSpellEntry( 58567 ), -- Sunder Armor
			CreateSpellEntry( 86346 ), -- Colossus Smash
			CreateSpellEntry( 7922 ), -- Charge (stun)
			CreateSpellEntry( 1715 ), -- Hamstring
			CreateSpellEntry( 50725 ), -- Vigilance
			CreateSpellEntry( 676 ), -- Disarm
			CreateSpellEntry( 29703 ), -- Daze (Shield Bash)
			CreateSpellEntry( 18498 ), -- Gag Order
			CreateSpellEntry( 12809 ), -- Concussion Blow
			CreateSpellEntry( 6343 ), -- Thunderclap
		},
		player = {
			CreateSpellEntry( 469 ), -- Commanding Shout
			CreateSpellEntry( 6673 ), -- Battle Shout
			CreateSpellEntry( 55694 ), -- Enraged Regeneration
			CreateSpellEntry( 23920 ), -- Spell Reflection
			CreateSpellEntry( 871 ), -- Shield Wall
			CreateSpellEntry( 1719 ), -- Recklessness
			CreateSpellEntry( 20230 ), -- Retaliation
			CreateSpellEntry( 2565 ), -- Shield Block
			CreateSpellEntry( 12976 ), -- Last Stand
			CreateSpellEntry( 90806 ), -- Executioner
			CreateSpellEntry( 85738 ), CreateSpellEntry( 85739 ), -- Meat Cleaver Rank 1 and 2
			CreateSpellEntry( 86662 ), CreateSpellEntry( 86663 ), -- Rude interruption rank 1 and 2
			CreateSpellEntry( 12328 ), -- Sweeping Stikes
			CreateSpellEntry( 18499 ), -- Berzerker Rage
			CreateSpellEntry( 85730 ), -- Deadly Calm
			CreateSpellEntry( 46924 ), -- Bladestorm	
			CreateSpellEntry( 86627 ), -- Incite
			CreateSpellEntry( 12964 ), -- Battle Trance
			CreateSpellEntry( 14202 ), --Enrage
			CreateSpellEntry( 12292 ), --Death Wish
		},
		procs = {
			CreateSpellEntry( 65156 ), -- Juggernaut
			CreateSpellEntry( 84586 ), -- Slaughter
			CreateSpellEntry( 60503 ), -- Taste for Blood
			CreateSpellEntry( 32216 ), -- Victory (Victory Rush)
			CreateSpellEntry( 57519 ), -- Enrage (Arms talent)
			CreateSpellEntry( 1134 ), -- Inner Rage
			CreateSpellEntry( 16491 ), -- Blood Craze
			CreateSpellEntry( 29842 ), -- Second Wind
		},
	},
};