CreateSpellEntry = function( id, castByAnyone, color, unitType, castSpellId )
	return { id = id, castByAnyone = castByAnyone, color = color, unitType = unitType or 0, castSpellId = castSpellId };
end

--Config starts here, do not edit anything above this point!!

-- Trinket filter - mostly for trinket procs, delete or wrap into comment block --[[  ]] if you dont want to track those
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
	CreateSpellEntry( 72416 ), -- Frostforged Sage (Ashen Band of Unmatched/Endless Destruction)
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
		},
		player = { 
			CreateSpellEntry( 59052 ), -- Freezing Fog
			CreateSpellEntry( 51124 ), -- Killing Machine  
			CreateSpellEntry( 49222 ), -- Bone Shield
			CreateSpellEntry( 57330 ), -- Horn of Winter
			CreateSpellEntry( 48707 ), -- Anti-magic Shell
			CreateSpellEntry( 48792 ), -- Icebound Fortitude
			CreateSpellEntry( 55233 ), -- Vampiric Blood
			CreateSpellEntry( 49028 ), -- Dancing Rune Weapon
		},
		procs = {
			CreateSpellEntry( 53365 ), -- Unholy Strength
			CreateSpellEntry( 81340 ), -- Sudden Doom 
		}
	},
	DRUID = { 
		target = { 
			CreateSpellEntry( 48438 ), -- Wild Growth
			CreateSpellEntry( 774 ), -- Rejuvenation
			CreateSpellEntry( 8936 ), -- Regrowth
			CreateSpellEntry( 33763 ), -- Lifebloom
			CreateSpellEntry( 5570 ), -- Insect Swarm
			CreateSpellEntry( 8921 ), -- Moonfire
			CreateSpellEntry( 93402 ), -- Sunfire
			CreateSpellEntry( 339 ), -- Entangling Roots
			CreateSpellEntry( 33786 ), -- Cyclone
			CreateSpellEntry( 60433 ), -- Earth and Moon
			CreateSpellEntry( 2637 ), -- Hibernate
			CreateSpellEntry( 2908 ), -- Soothe Animal
			CreateSpellEntry( 50259 ), -- Feral Charge (Cat) - daze
			CreateSpellEntry( 45334 ), -- Feral Charge (Bear) - immobilize
			CreateSpellEntry( 58180 ), -- Infected Wounds
			CreateSpellEntry( 6795 ), -- Growl
			CreateSpellEntry( 5209 ), -- Challenging Roar
			CreateSpellEntry( 99 ), -- Demoralizing Roar
			CreateSpellEntry( 33745 ), -- Lacerate
			CreateSpellEntry( 5211 ), -- Bash 
			CreateSpellEntry( 22570 ), -- Maim
			CreateSpellEntry( 1822 ), -- Rake
			CreateSpellEntry( 1079 ), -- Rip
			CreateSpellEntry( 33878, true ), -- Mangle (Bear)
			CreateSpellEntry( 33876, true ), -- Mangle (Cat)
			CreateSpellEntry( 9007 ), -- Pounce bleed
			CreateSpellEntry( 9005 ), -- Pounce stun
			CreateSpellEntry( 91565, true ), -- Farie Fire
		},
		player = { 
			CreateSpellEntry( 48505 ), -- Starfall
			CreateSpellEntry( 29166 ), -- Innervate
			CreateSpellEntry( 22812 ), -- Barkskin
			CreateSpellEntry( 5215 ), -- Prowl 
			CreateSpellEntry( 53312 ), -- Nature's Grasp
			CreateSpellEntry( 5229 ), -- Enrage
			CreateSpellEntry( 52610 ), -- Savage Roar
			CreateSpellEntry( 5217 ), -- Tiger's Fury
			CreateSpellEntry( 1850 ), -- Dash
			CreateSpellEntry( 22842 ), -- Frenzied Regeneration
			CreateSpellEntry( 50334 ), -- Berserk
			CreateSpellEntry( 61336 ), -- Survival Instincts
		},
		procs = {
			CreateSpellEntry( 16870 ), -- Clearcasting	
			CreateSpellEntry( 48517 ), -- Solar Eclipse
			CreateSpellEntry( 48518 ), -- Lunar Eclipse
			CreateSpellEntry( 62606 ), -- Predator's Swiftness
			CreateSpellEntry( 93400 ), -- Shooting Stars
			CreateSpellEntry( 81192 ), -- Lunar Shower
		}
	},
	HUNTER = { 
		target = {
			CreateSpellEntry( 1978 ), -- Serpent Stingng
			CreateSpellEntry( 63468 ), -- Piercing Shots
			CreateSpellEntry( 3674 ), -- Black Arrow
		},
		player = {
			CreateSpellEntry( 3045 ), -- Rapid Fire
		},
		procs = {
			CreateSpellEntry( 6150 ), -- Quick Shots
			CreateSpellEntry( 56453 ), -- Lock and Load
			CreateSpellEntry( 70728 ), -- Exploit Weakness (2pc t10)
			CreateSpellEntry( 71007 ), -- Stinger (4pc t10)
			CreateSpellEntry( 82925 ), -- Master Marksman
			CreateSpellEntry( 53220 ), -- Improved Steady Shot
			CreateSpellEntry( 82926 ), -- Fire!
		},
	},
	MAGE = {
		target = { 
			CreateSpellEntry( 44457 ), -- Living Bomb
		},
		player = {
			CreateSpellEntry( 36032 ), -- Arcane Blast
			CreateSpellEntry( 1463 ), -- Mana Shield
			CreateSpellEntry( 11426 ), -- Ice Barrier
			CreateSpellEntry( 543 ), -- Mage Ward 
			CreateSpellEntry( 12472 ), -- Icy Veins
			CreateSpellEntry( 12042 ), -- Arcane Power
			CreateSpellEntry( 48108 ), -- Hot Streak
		},
		procs = {
			CreateSpellEntry( 44544 ), -- Fingers of Frost	
			CreateSpellEntry( 79683 ), -- Arkan Missile!	
			CreateSpellEntry( 57761 ), -- Brain Frezze	
		},
	},
	PALADIN = { 
		target = {
			CreateSpellEntry( 31803 ), -- Censure
			CreateSpellEntry( 20066 ), -- Repentance
			CreateSpellEntry( 53563 ), -- Beacon of Light
			CreateSpellEntry( 853 ), -- Hammer of Justice
			CreateSpellEntry( 1022 ), -- Hand of Protection
			CreateSpellEntry( 1044 ), -- Hand of Freedom
			CreateSpellEntry( 1038 ), -- Hand of Salvation
			CreateSpellEntry( 6940 ), -- Hand of Sacrifice
		},
		player = {
			CreateSpellEntry( 642 ), -- Divine Shield
			CreateSpellEntry( 498 ), -- Divine Protection
			CreateSpellEntry( 31850 ), --Ardent Defender
			CreateSpellEntry( 31884 ), -- Avenging Wrath
			CreateSpellEntry( 54428 ), -- Divine Plea
			CreateSpellEntry( 87342 ), -- Holy Shield
			CreateSpellEntry( 85433 ), -- Sacred Duty
			CreateSpellEntry( 85416 ), --Grand Crusader
			CreateSpellEntry( 70940, true), -- Divine Guardian 
			CreateSpellEntry( 85696 ), -- Zealotry
			CreateSpellEntry( 31842 ), -- Divine Favor
			CreateSpellEntry( 1022 ), -- Hand of Protection
			CreateSpellEntry( 1044 ), -- Hand of Freedom
			CreateSpellEntry( 1038 ), -- Hand of Salvation
			CreateSpellEntry( 6940 ), -- Hand of Sacrifice
			CreateSpellEntry( 20053 ), -- Conviction
			CreateSpellEntry( 53657 ), -- Judgements of the Pure
		},
		procs = {
			CreateSpellEntry( 59578 ), -- The Art of War
			CreateSpellEntry( 90174 ), -- Hand of Light	
			CreateSpellEntry( 85496 ), -- Speed of Light	
			CreateSpellEntry( 88819 ), -- Daybreak 
			CreateSpellEntry( 54149 ), -- Infusion of Light
		},
	},
	PRIEST = { 
		target = { 
			CreateSpellEntry( 17 ), -- Power Word: Shield
			CreateSpellEntry( 6788, true, nil, 1 ), -- Weakened Soul
			CreateSpellEntry( 139 ), -- Renew
			CreateSpellEntry( 33076 ), -- Prayer of Mending
			CreateSpellEntry( 33206 ), -- Pain Suppression
			CreateSpellEntry( 34914, false, nil, nil, 34914 ), -- Vampiric Touch
			CreateSpellEntry( 589 ), -- Shadow Word: Pain
			CreateSpellEntry( 2944 ), -- Devouring Plague
			CreateSpellEntry( 47788 ), -- Guardian Spirit
		},
		player = {
			CreateSpellEntry( 10060 ), -- Power Infusion
			CreateSpellEntry( 47585 ), -- Dispersion
			CreateSpellEntry( 81207 ), -- Chakra: Renew
			CreateSpellEntry( 81208 ), -- Chakra: Heal
			CreateSpellEntry( 81206 ), -- Chakra: Prayer of Healing
			CreateSpellEntry( 81209 ), -- Chakra: Smite
			CreateSpellEntry( 81700 ), -- Archangel
			CreateSpellEntry( 87153 ), -- Dark Archangel
			CreateSpellEntry( 81661 ), -- Evangelism
		},
		procs = {
			CreateSpellEntry( 63735 ), -- Serendipity
			CreateSpellEntry( 88688 ), -- Surge of Light
			CreateSpellEntry( 77487 ), -- Shadow Orbs
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
            CreateSpellEntry( 3409 ), -- Crippling Poison 
            CreateSpellEntry( 5760 ), -- Mind-Numbling Poison
            CreateSpellEntry( 6770 ), -- Sap    
            CreateSpellEntry( 1943 ), -- Rupture
            CreateSpellEntry( 703 ), -- Garrote
            CreateSpellEntry( 93068 ), -- Master Poisoner
            CreateSpellEntry( 79140 ), -- Vendetta
            CreateSpellEntry( 16511 ), -- Hemorrhage
        },
        player = { 
            CreateSpellEntry( 32645 ), -- Envenom
            CreateSpellEntry( 5171 ), -- Slice and Dice    
            CreateSpellEntry( 57934 ), -- Tricks of the Trade
            CreateSpellEntry( 5277 ), -- Evasion
            CreateSpellEntry( 58427 ), -- Overkill
            CreateSpellEntry( 13750 ), -- Adrenaline Rush
            CreateSpellEntry( 13877 ), -- Blade Flurry
            CreateSpellEntry( 73651 ), -- Recuperate
        },
        procs = {

        },
    },
	SHAMAN = {
		target = { 
			CreateSpellEntry( 8042 ), -- Earth Shock
			CreateSpellEntry( 8050 ), -- Flame Shock
			CreateSpellEntry( 8056 ), -- Frost Shock
			CreateSpellEntry( 51514 ), -- Hex
			CreateSpellEntry( 76780 ), -- Bind Elemental
			CreateSpellEntry( 974 ), -- Earth Shield
			CreateSpellEntry( 51945 ), -- Earthliving Weapon Effect
		},
		player = { 
			CreateSpellEntry( 974 ), -- Earth Shield
			CreateSpellEntry( 324 ), -- Lightning Shield
			CreateSpellEntry( 52127 ), -- Water Shield
			CreateSpellEntry( 30823 ), -- Shamanistic Rage
			CreateSpellEntry( 16166 ), -- Elemental Mastery
			CreateSpellEntry( 53817 ), -- Maelstrom Weapon
			CreateSpellEntry( 79206 ), -- Spiritwalker's Grace
			CreateSpellEntry( 73684 ), -- Unleash Earth
			CreateSpellEntry( 73683 ), -- Unleash Flame
			CreateSpellEntry( 73682 ), -- Unleash Frost
			CreateSpellEntry( 73685 ), -- Unleash Life
			CreateSpellEntry( 73681 ), -- Unleash Wind
		},
		procs = {
			CreateSpellEntry( 51528 ), -- Maelstrom Weapon
			CreateSpellEntry( 51562 ), -- Tidal Waves
			CreateSpellEntry( 16246 ), -- Clearcasting
		},
	},
	WARLOCK = { 
		target = {
			CreateSpellEntry( 48181 ), -- Haunt
			CreateSpellEntry( 32389 ), -- Shadow Embrace 
			CreateSpellEntry( 172 ), -- Corruption
			CreateSpellEntry( 30108 ), -- Unstable Affliction
			CreateSpellEntry( 603 ), -- Bane of Doom
			CreateSpellEntry( 980 ), -- Bane of Agony
			CreateSpellEntry( 80240 ), -- Bane of Havoc
			CreateSpellEntry( 1490 ), -- Curse of the Elements 
			CreateSpellEntry( 18018 ), -- Conflagration
			CreateSpellEntry( 348 ), -- Immolate
			CreateSpellEntry( 27243 ), -- Seed of Corruption
			CreateSpellEntry( 17800 ), -- Improved Shadow Bolt
		},
		player = { 
		},
		procs = {
			CreateSpellEntry( 54277 ), -- Backdraft
			CreateSpellEntry( 64371 ), -- Eradication
			CreateSpellEntry( 71165 ), -- Molten Core
			CreateSpellEntry( 63167 ), -- Decimation 
			CreateSpellEntry( 17941 ), -- Shadow Trance
			CreateSpellEntry( 47283 ), -- Empowered Imp 
			CreateSpellEntry( 85383 ), -- Improved Soul Fire 
		},
	},
	WARRIOR = { 
		target = {
			CreateSpellEntry( 94009 ), -- Rend
			CreateSpellEntry( 12294 ), -- Mortal Strike
			CreateSpellEntry( 1160 ), -- Demoralizing Shout
			CreateSpellEntry( 64382 ), -- Shattering Throw
			CreateSpellEntry( 58567 ), -- Sunder Armor
			CreateSpellEntry( 6343 ), -- Thunder Clap
			CreateSpellEntry( 1715 ), -- Hamstring
		},
		player = { 
			CreateSpellEntry( 469 ), -- Commanding Shout
			CreateSpellEntry( 6673 ), -- Battle Shout
			CreateSpellEntry( 55694 ), -- Enraged Regeneration
			CreateSpellEntry( 23920 ), -- Spell Reflection
			CreateSpellEntry( 871 ), -- Shield Wall
			CreateSpellEntry( 1719 ), -- Recklessness
			CreateSpellEntry( 20230 ), -- Retaliation
			CreateSpellEntry( 46916 ), -- Slam!
		},
		procs = {

		},
	},
};