CreateSpellEntry = function( id, castByAnyone, color, unitType, castSpellId )
	return { id = id, castByAnyone = castByAnyone, color = color, unitType = unitType or 0, castSpellId = castSpellId };
end




TRINKET_FILTER = {
	CreateSpellEntry( 75477 ), -- Scaly Nimbleness [Petrified Twilight Scale] 271
	CreateSpellEntry( 75480 ), -- Scaly Nimbleness [Petrified Twilight Scale] 285
	CreateSpellEntry( 71432 ), -- Tiny Abom in a jar (Mote of Anger)
	CreateSpellEntry( 73422 ), -- Chaos Bane
	CreateSpellEntry( 71905 ), -- Soul Fragment
	CreateSpellEntry( 67671 ), -- Fury(Banner of Victory)
	CreateSpellEntry( 54758 ), -- Hyperspeed Acceleration (Hyperspeed Accelerators)
	CreateSpellEntry( 55637 ), -- Lightweave
	CreateSpellEntry( 71635 ), -- Aegis of Dalaran 264
	CreateSpellEntry( 71638 ), -- Aegis of Dalaran 272
	CreateSpellEntry( 71586 ), -- Hardened Skin	
	CreateSpellEntry( 2825, true ), --Heroism
	CreateSpellEntry( 32182, true ), -- Bloodlust
	CreateSpellEntry( 80353 ), -- Time Warp 
	CreateSpellEntry( 26297 ), -- Berserking (troll racial)
	CreateSpellEntry( 33702 ), CreateSpellEntry( 33697 ), CreateSpellEntry( 20572 ), -- Blood Fury (orc racial)
	CreateSpellEntry( 57933, true ), -- Tricks of Trade (15% dmg buff)
    CreateSpellEntry( 71403 ), -- Fatal Flaws (Needle-Encrusted Scorpion)
    CreateSpellEntry( 71396 ), -- Rage of the Fallen (Herkuml War Token)
    CreateSpellEntry( 67695 ), -- Rage (Mark of Supremacy)
    CreateSpellEntry( 59620 ), -- Berserk (Weapon Enchant Berserking)
    CreateSpellEntry( 28093 ), -- Lightning Speed (Weapon Enchant Mongoose)
    CreateSpellEntry( 71491 ), -- Aim of the Iron Dwarves (Deathbringer's Will)
    CreateSpellEntry( 71486 ), -- Power of the Taunka (Deathbringer's Will)
    CreateSpellEntry( 71487 ), -- Precision of the Iron Dwarves (Deathbringer's Will)
    CreateSpellEntry( 71492 ), -- Speed of the Vrykul (Deathbringer's Will)
    CreateSpellEntry( 71484 ), -- Strength of the Taunka (Deathbringer's Will)
    CreateSpellEntry( 71485 ), -- Agility of the Vrykul (Deathbringer's Will)
    CreateSpellEntry( 71559 ), -- Aim of the Iron Dwarves (Deathbringer's Will Heroic)
    CreateSpellEntry( 71558 ), -- Power of the Taunka (Deathbringer's Will Heroic)
    CreateSpellEntry( 71557 ), -- Precision of the Iron Dwarves (Deathbringer's Will Heroic)
    CreateSpellEntry( 71560 ), -- Speed of the Vrykul (Deathbringer's Will Heroic)
    CreateSpellEntry( 71561 ), -- Strength of the Taunka (Deathbringer's Will Heroic)
    CreateSpellEntry( 71556 ), -- Agility of the Vrykul (Deathbringer's Will Heroic)
    CreateSpellEntry( 71401 ), -- Icy Rage (Whispering Fanged Skull)
    CreateSpellEntry( 71541 ), -- Icy Rage (Whispering Fanged Skull Heroic)
    CreateSpellEntry( 75458 ), -- Piercing Twilight (Sharpened Twilight Scale)
    CreateSpellEntry( 75456 ), -- Piercing Twilight (Sharpened Twilight Scale Heroic)
    CreateSpellEntry( 67703 ), -- Paragon Agility (Death's Verdict/Choice)
    CreateSpellEntry( 67708 ), -- Paragon Strength (Death's Verdict/Choice)
    CreateSpellEntry( 67772 ), -- Paragon Agility (Death's Verdict/Choice Heroic)
    CreateSpellEntry( 67773 ), -- Paragon Strength (Death's Verdict/Choice Heroic)
	CreateSpellEntry( 71579 ), -- Elusive Power (Maghia's Misguided Quill)
	CreateSpellEntry( 67669 ), -- Elusive Power (Abyssal Rune)

	CreateSpellEntry( 67684 ), -- Hospitality (Talisman of Resurgence)
	CreateSpellEntry( 71584 ), -- Revitalized (Purified Lunar Dust)
	CreateSpellEntry( 53909 ), -- Potion of Wild Magic
	CreateSpellEntry( 53908 ), -- Potion of Speed
	CreateSpellEntry( 59545 ), CreateSpellEntry( 59543 ), CreateSpellEntry( 59548 ), CreateSpellEntry( 59542 ), CreateSpellEntry( 59544 ), CreateSpellEntry( 59547 ), CreateSpellEntry( 28880 ), -- Gift of the Naaru
	CreateSpellEntry( 55503 ), CreateSpellEntry( 55502 ), CreateSpellEntry( 55501 ), CreateSpellEntry( 55500 ), CreateSpellEntry( 55480 ), CreateSpellEntry( 55428 ), -- Lifeblood
};

--[[ Configuration functions
	id - spell id
	castByAnyone - show if aura wasn't created by player, set true to show if its by anyone
	color - bar color (nil for default color)
	unitType - 0 all, 1 friendly, 2 enemy
	castSpellId - fill only if you want to see line on bar that indicates if its safe to start casting spell and not clip the last tick, also note that this can be different from aura id 

	Example: CreateSpellEntry( spellID , castByAnyone, color, unitType, castSpellId), 
]]--

CLASS_FILTERS = {
	DEATHKNIGHT = { 
		target = {
			CreateSpellEntry( 55095 ), -- Frost Fever
			CreateSpellEntry( 55078 ), -- Blood Plague
			CreateSpellEntry( 81130 ), -- Scarlet Fever
			CreateSpellEntry( 50536 ), -- Unholy Blight
			CreateSpellEntry( 65142 ), -- Ebon Plague

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
		},
		procs = {
			CreateSpellEntry( 53365 ), -- Unholy Strength
			CreateSpellEntry( 64856 ), -- Blade barrier
			CreateSpellEntry( 70657 ), -- Advantage
			CreateSpellEntry( 81340 ), -- Sudden Doom
		}		},


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
			CreateSpellEntry( 93401 ), -- Sunfire
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
		},
		procs = {
			CreateSpellEntry( 16870 ), -- Clearcasting
			CreateSpellEntry( 48518 ), -- Eclipse Lunar
			CreateSpellEntry( 48517 ), -- Eclipse Solar
			CreateSpellEntry( 69369 ), -- Predator's Swiftness
			CreateSpellEntry( 93400 ), -- Shooting Stars
			CreateSpellEntry( 81192 ), -- Lunar Shower

		},
		procs = {		

		}
	},
	HUNTER = { 
		target = {
			CreateSpellEntry( 49050 ), -- Aimed Shot
			CreateSpellEntry( 1978 ), -- Serpent Sting
			CreateSpellEntry( 53238 ), -- Piercing Shots
			CreateSpellEntry( 3674 ), -- Black Arrow
			CreateSpellEntry( 82654 ), -- Widow Venom
			CreateSpellEntry( 34490 ), -- Silencing Shot
			CreateSpellEntry( 37506 ), -- Scatter Shot
			CreateSpellEntry( 53243 ), -- Marker for death, need to be changed I think
			CreateSpellEntry( 1130 ), -- Hunters mark
		},
		player = {
			CreateSpellEntry( 82749 ), -- killing streak
			CreateSpellEntry( 3045 ), -- Rapid Fire
			CreateSpellEntry( 34471 ), --The beast within
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

			CreateSpellEntry( 31884 ), -- Avenging Wrath
			CreateSpellEntry( 87342 ), -- Holy Shield
			CreateSpellEntry( 85433 ), -- Sacred Duty
			CreateSpellEntry( 85416 ), --Grand Crusader
			CreateSpellEntry( 20053 ), -- Conviction

			CreateSpellEntry( 85696 ), -- Zealotry
			CreateSpellEntry( 1044 ), -- Hand of Freedom
			CreateSpellEntry( 1022 ), -- Hand of Protection

			CreateSpellEntry( 1038 ), -- Hand of Salvation
			CreateSpellEntry( 6940 ), -- Hand of Sacrifice

			CreateSpellEntry( 53657 ), -- Judgements of the Pure
			CreateSpellEntry( 53563 ), -- Beacon of Light
			CreateSpellEntry( 31821 ), -- Aura Mastery
			CreateSpellEntry( 54428 ), -- Divine Plea
			CreateSpellEntry( 31482 ), -- Divine Favor
			CreateSpellEntry( 70940, true), -- Divine Guardian 
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
			CreateSpellEntry( 552 ), -- Abolish Disease
			CreateSpellEntry( 63877 ), -- Pain Suppression
			CreateSpellEntry( 34914, false, nil, nil, 34914 ), -- Vampiric Touch
			CreateSpellEntry( 589 ), -- Shadow Word: Pain
			CreateSpellEntry( 2944 ), -- Devouring Plague
			CreateSpellEntry( 48153 ), -- Guardian Spirit
			CreateSpellEntry( 77489 ), -- Echo of Light
		},
		player = {
			CreateSpellEntry( 10060 ), -- Power Infusion
			CreateSpellEntry( 588 ), -- Inner Fire
			CreateSpellEntry( 47585 ), -- Dispersion




			CreateSpellEntry( 81700 ), -- Archangel
			CreateSpellEntry( 14751 ), -- Chakra
			CreateSpellEntry( 81208 ), -- Chakra Heal
			CreateSpellEntry( 81207 ), -- Chakra Renew
			CreateSpellEntry( 81209 ), -- Chakra Smite
			CreateSpellEntry( 81206 ), -- Prayer of Healing

		},
		procs = {
			CreateSpellEntry( 63735 ), -- Serendipity
			CreateSpellEntry( 88690 ), -- Surge of Light
			CreateSpellEntry( 77487 ), -- Shadow Orb
			CreateSpellEntry( 71572 ), -- Cultivated Power
			CreateSpellEntry( 81661 ), -- Evangelism
			CreateSpellEntry( 72418 ), -- Kuhlendes Wissen
			CreateSpellEntry( 71584 ), -- Revitalize
		},
	},
	ROGUE = { 
		target = { 
			CreateSpellEntry( 1833 ), -- Cheap Shot --
			CreateSpellEntry( 408 ), -- Kidney Shot --
			CreateSpellEntry( 1776 ), -- Gouge   --
			CreateSpellEntry( 2094 ), -- Blind --
			CreateSpellEntry( 8647 ), -- Expose Armor --
			CreateSpellEntry( 51722 ), -- Dismantle --
			CreateSpellEntry( 2818 ), -- Deadly Poison --
			CreateSpellEntry( 13218 ), -- Wound Posion --
			CreateSpellEntry( 3409 ),  -- Crippling Poison 
			CreateSpellEntry( 5760 ), -- Mind-Numbing Poison --
			CreateSpellEntry( 6770 ), -- Sap
			CreateSpellEntry( 1943 ), -- Rupture --
			CreateSpellEntry( 703 ), -- Garrote --


			CreateSpellEntry( 79140 ), -- vendetta
			CreateSpellEntry( 16511 ), -- Hemorrhage
		},
		player = {
			CreateSpellEntry( 32645 ), -- Envenom --
			CreateSpellEntry( 2983 ), -- Sprint --
			CreateSpellEntry( 5277 ), -- Evasion --
			CreateSpellEntry( 1776 ), -- Gouge --
			CreateSpellEntry( 51713 ), -- Shadow Dance --
			CreateSpellEntry( 1966 ), -- Feint --
			CreateSpellEntry( 73651 ), -- Recuperate --
			CreateSpellEntry( 5171 ), -- Slice and Dice
			CreateSpellEntry( 55503 ), -- Lifeblood --
			CreateSpellEntry( 13877 ), -- Blade Flurry --







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
			CreateSpellEntry( 77657 ), -- Searing Flames
		},
			player = {

			CreateSpellEntry( 324 ), -- Lightning Shield
			CreateSpellEntry( 52127 ), -- Water Shield
			CreateSpellEntry( 974 ), -- Earth Shield
			CreateSpellEntry( 30823 ), -- Shamanistic Rage
			CreateSpellEntry( 55198 ), -- Tidal Force








			CreateSpellEntry( 61295 ), -- Riptide

		},
		procs = {
			CreateSpellEntry( 53817 ), -- Maelstrom Weapon			



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

		},
			player = {            
			CreateSpellEntry( 17941 ), -- Shadow trance 
			CreateSpellEntry( 64371 ), -- Eradication
		},
		procs = {
			CreateSpellEntry( 86121 ), -- Soul Swap
			CreateSpellEntry( 54276 ), -- Backdraft

			CreateSpellEntry( 71165 ), -- Molten Cor
			CreateSpellEntry( 63167 ), -- Decimation




		},
	},
	WARRIOR = { 
		target = {
			CreateSpellEntry( 772 ), -- Rend
			CreateSpellEntry( 12294 ), -- Mortal Strike
			CreateSpellEntry( 1160 ), -- Demoralizing Shout
			CreateSpellEntry( 64382 ), -- Shattering Throw
			CreateSpellEntry( 7386 ), -- Sunder Armor
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
			CreateSpellEntry( 12975 ), -- Last Stand
			CreateSpellEntry( 90806 ), -- Executioner
			CreateSpellEntry( 85738 ), CreateSpellEntry( 85739 ), -- Meat Cleaver Rank 1 and 2
			CreateSpellEntry( 86662 ), CreateSpellEntry( 86663 ), -- Rude interruption rank 1 and 2
		},
		procs = {

		},
	},
};