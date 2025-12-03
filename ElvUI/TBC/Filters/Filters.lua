local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Druid
		[339]	= List(1), -- Entangling Roots (Rank 1)
		[1062]	= List(1), -- Entangling Roots (Rank 2)
		[5195]	= List(1), -- Entangling Roots (Rank 3)
		[5196]	= List(1), -- Entangling Roots (Rank 4)
		[9852]	= List(1), -- Entangling Roots (Rank 5)
		[9853]	= List(1), -- Entangling Roots (Rank 6)
		[26989]	= List(1), -- Entangling Roots (Rank 7)
		[2637]	= List(1), -- Hibernate (Rank 1)
		[18657]	= List(1), -- Hibernate (Rank 2)
		[18658]	= List(1), -- Hibernate (Rank 3)
		[19675]	= List(2), -- Feral Charge Effect
		[5211]	= List(4), -- Bash (Rank 1)
		[6798]	= List(4), -- Bash (Rank 2)
		[8983]	= List(4), -- Bash (Rank 3)
		[16922]	= List(2), -- Starfire Stun
		[9005]	= List(2), -- Pounce (Rank 1)
		[9823]	= List(2), -- Pounce (Rank 2)
		[9827]	= List(2), -- Pounce (Rank 3)
		[27006]	= List(2), -- Pounce (Rank 4)
		[770]	= List(5), -- Faerie Fire (Rank 1)
		[778]	= List(5), -- Faerie Fire (Rank 2)
		[9749]	= List(5), -- Faerie Fire (Rank 3)
		[9907]	= List(5), -- Faerie Fire (Rank 4)
		[16857]	= List(5), -- Faerie Fire (Feral) (Rank 1)
		[17390]	= List(5), -- Faerie Fire (Feral) (Rank 2)
		[17391]	= List(5), -- Faerie Fire (Feral) (Rank 3)
		[17392]	= List(5), -- Faerie Fire (Feral) (Rank 4)
	-- Hunter
		[1499]	= List(3), -- Freezing Trap (Rank 1)
		[14310]	= List(3), -- Freezing Trap (Rank 2)
		[14311]	= List(3), -- Freezing Trap (Rank 3)
		[14308]	= List(3), -- Freezing Trap Effect (Rank 2)
		[14309]	= List(3), -- Freezing Trap Effect (Rank 3)
		[13809]	= List(1), -- Frost Trap
		[19503]	= List(4), -- Scatter Shot
		[5116]	= List(2), -- Concussive Shot
		[297]	= List(2), -- Wing Clip (Rank 1)
		[14267]	= List(2), -- Wing Clip (Rank 2)
		[14268]	= List(2), -- Wing Clip (Rank 3)
		[1513]	= List(2), -- Scare Beast (Rank 1)
		[14326]	= List(2), -- Scare Beast (Rank 2)
		[14327]	= List(2), -- Scare Beast (Rank 3)
		[24394]	= List(2), -- Intimidation
		[19386]	= List(2), -- Wyvern Sting (Rank 1)
		[24132]	= List(2), -- Wyvern Sting (Rank 2)
		[24133]	= List(2), -- Wyvern Sting (Rank 3)
		[19229]	= List(2), -- Improved Wing Clip
		[19306]	= List(2), -- Counterattack (Rank 1)
		[20909]	= List(2), -- Counterattack (Rank 2)
		[20910]	= List(2), -- Counterattack (Rank 3)
	-- Mage
		[118]	= List(3), -- Polymorph (Rank 1)
		[12824]	= List(3), -- Polymorph (Rank 2)
		[12825]	= List(3), -- Polymorph (Rank 3)
		[12826]	= List(3), -- Polymorph (Rank 4)
		[122]	= List(1), -- Frost Nova (Rank 1)
		[865]	= List(1), -- Frost Nova (Rank 2)
		[6131]	= List(1), -- Frost Nova (Rank 3)
		[10230]	= List(1), -- Frost Nova (Rank 4)
		[27088]	= List(1), -- Frost Nova (Rank 5)
		[12494]	= List(2), -- Frostbite
		[116]	= List(2), -- Frostbolt (Rank 1)
		[205]	= List(2), -- Frostbolt (Rank 2)
		[837]	= List(2), -- Frostbolt (Rank 3)
		[7322]	= List(2), -- Frostbolt (Rank 4)
		[8406]	= List(2), -- Frostbolt (Rank 5)
		[8407]	= List(2), -- Frostbolt (Rank 6)
		[8408]	= List(2), -- Frostbolt (Rank 7)
		[10179]	= List(2), -- Frostbolt (Rank 8)
		[10180]	= List(2), -- Frostbolt (Rank 9)
		[10181]	= List(2), -- Frostbolt (Rank 10)
		[25304]	= List(2), -- Frostbolt (Rank 11)
		[27071]	= List(2), -- Frostbolt (Rank 12)
		[27072]	= List(2), -- Frostbolt (Rank 13)
		[12355]	= List(2), -- Impact
	-- Paladin
		[853]	= List(3), -- Hammer of Justice (Rank 1)
		[5588]	= List(3), -- Hammer of Justice (Rank 2)
		[5589]	= List(3), -- Hammer of Justice (Rank 3)
		[10308]	= List(3), -- Hammer of Justice (Rank 4)
		[20066]	= List(3), -- Repentance
	-- Priest
		[8122]	= List(3), -- Psychic Scream (Rank 1)
		[8124]	= List(3), -- Psychic Scream (Rank 2)
		[10888]	= List(3), -- Psychic Scream (Rank 3)
		[10890]	= List(3), -- Psychic Scream (Rank 4)
		[605]	= List(5), -- Mind Control (Rank 1)
		[10911]	= List(5), -- Mind Control (Rank 2)
		[10912]	= List(5), -- Mind Control (Rank 3)
		[15269]	= List(2), -- Blackout
		[15407]	= List(2), -- Mind Flay (Rank 1)
		[17311]	= List(2), -- Mind Flay (Rank 2)
		[17312]	= List(2), -- Mind Flay (Rank 3)
		[17313]	= List(2), -- Mind Flay (Rank 4)
		[17314]	= List(2), -- Mind Flay (Rank 5)
		[18807]	= List(2), -- Mind Flay (Rank 6)
		[25387]	= List(2), -- Mind Flay (Rank 7)
	-- Rogue
		[6770]	= List(4), -- Sap (Rank 1)
		[2070]	= List(4), -- Sap (Rank 2)
		[11297]	= List(4), -- Sap (Rank 3)
		[2094]	= List(5), -- Blind
		[408]	= List(4), -- Kidney Shot (Rank 1)
		[8643]	= List(4), -- Kidney Shot (Rank 2)
		[1833]	= List(2), -- Cheap Shot
		[1776]	= List(2), -- Gouge (Rank 1)
		[1777]	= List(2), -- Gouge (Rank 2)
		[8629]	= List(2), -- Gouge (Rank 3)
		[11285]	= List(2), -- Gouge (Rank 4)
		[11286]	= List(2), -- Gouge (Rank 5)
		[38764]	= List(2), -- Gouge (Rank 6)
		[5530]	= List(2), -- Mace Stun Effect
	-- Shaman
		[2484]	= List(1), -- Earthbind Totem
		[8056]	= List(2), -- Frost Shock (Rank 1)
		[8058]	= List(2), -- Frost Shock (Rank 2)
		[10472]	= List(2), -- Frost Shock (Rank 3)
		[10473]	= List(2), -- Frost Shock (Rank 4)
		[25464]	= List(2), -- Frost Shock (Rank 5)
	-- Warlock
		[5782]	= List(3), -- Fear (Rank 1)
		[6213]	= List(3), -- Fear (Rank 2)
		[6215]	= List(3), -- Fear (Rank 3)
		[6358]	= List(3), -- Seduction (Succub)
		[18223]	= List(2), -- Curse of Exhaustion
		[18093]	= List(2), -- Pyroclasm
		[710]	= List(2), -- Banish (Rank 1)
		[18647]	= List(2), -- Banish (Rank 2)
		[30413]	= List(2), -- Shadowfury
	-- Warrior
		[5246]	= List(4), -- Intimidating Shout
		[1715]	= List(2), -- Hamstring (Rank 1)
		[7372]	= List(2), -- Hamstring (Rank 2)
		[7373]	= List(2), -- Hamstring (Rank 3)
		[25212]	= List(2), -- Hamstring (Rank 4)
		[12809]	= List(2), -- Concussion Blow
		[20252]	= List(2), -- Intercept (Rank 1)
		[20616]	= List(2), -- Intercept (Rank 2)
		[20617]	= List(2), -- Intercept (Rank 3)
		[25272]	= List(2), -- Intercept (Rank 4)
		[25275]	= List(2), -- Intercept (Rank 5)
		[7386]	= List(6), -- Sunder Armor (Rank 1)
		[7405]	= List(6), -- Sunder Armor (Rank 2)
		[8380]	= List(6), -- Sunder Armor (Rank 3)
		[11596]	= List(6), -- Sunder Armor (Rank 4)
		[11597]	= List(6), -- Sunder Armor (Rank 5)
	-- Racial
		[20549]	= List(2), -- War Stomp
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Mage
		[11958]	= List(2), -- Ice Block A
		[27619]	= List(2), -- Ice Block B
		[45438]	= List(2), -- Ice Block C
	-- Paladin
		[498]	= List(2), -- Divine Protection (Rank 1)
		[5573]	= List(2), -- Divine Protection (Rank 2)
		[642]	= List(2), -- Divine Shield (Rank 1)
		[1020]	= List(2), -- Divine Shield (Rank 2)
		[1022]	= List(2), -- Blessing of Protection (Rank 1)
		[5599]	= List(2), -- Blessing of Protection (Rank 2)
		[10278]	= List(2), -- Blessing of Protection (Rank 3)
	-- Warrior
		[20230]	= List(2), -- Retaliation
	-- Consumables
		[3169]	= List(2), -- Limited Invulnerability Potion
		[6615]	= List(2), -- Free Action Potion
	-- Racial
		[7744]	= List(2), -- Will of the Forsaken
		[6346]	= List(2), -- Fear Ward
		[20594]	= List(2), -- Stoneform
	-- All Classes
		[19753]	= List(2), -- Divine Intervention
	},
}

G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	-- Druid
		[29166]	= List(), -- Innervate
		[22812]	= List(), -- Barkskin
		[17116]	= List(), -- Nature's Swiftness
		[16689]	= List(), -- Nature's Grasp (Rank 1)
		[16810]	= List(), -- Nature's Grasp (Rank 2)
		[16811]	= List(), -- Nature's Grasp (Rank 3)
		[16812]	= List(), -- Nature's Grasp (Rank 4)
		[16813]	= List(), -- Nature's Grasp (Rank 5)
		[17329]	= List(), -- Nature's Grasp (Rank 6)
		[27009]	= List(), -- Nature's Grasp (Rank 7)
		[16864]	= List(), -- Omen of Clarity
		[5217]	= List(), -- Tiger's Fury (Rank 1)
		[6793]	= List(), -- Tiger's Fury (Rank 2)
		[9845]	= List(), -- Tiger's Fury (Rank 3)
		[9846]	= List(), -- Tiger's Fury (Rank 4)
		[2893]	= List(), -- Abolish Poison
		[5229]	= List(), -- Enrage
		[1850]	= List(), -- Dash (Rank 1)
		[9821]	= List(), -- Dash (Rank 2)
		[23110]	= List(), -- Dash (Rank 3)
	-- Hunter
		[13161]	= List(), -- Aspect of the Beast
		[5118]	= List(), -- Aspect of the Cheetah
		[13163]	= List(), -- Aspect of the Monkey
		[13159]	= List(), -- Aspect of the Pack
		[20043]	= List(), -- Aspect of the Wild (Rank 1)
		[20190]	= List(), -- Aspect of the Wild (Rank 2)
		[27045]	= List(), -- Aspect of the Wild (Rank 3)
		[3045]	= List(), -- Rapid Fire
		[19263]	= List(), -- Deterrence
		[13165]	= List(), -- Aspect of the Hawk (Rank 1)
		[14318]	= List(), -- Aspect of the Hawk (Rank 2)
		[14319]	= List(), -- Aspect of the Hawk (Rank 3)
		[14320]	= List(), -- Aspect of the Hawk (Rank 4)
		[14321]	= List(), -- Aspect of the Hawk (Rank 5)
		[14322]	= List(), -- Aspect of the Hawk (Rank 6)
		[25296]	= List(), -- Aspect of the Hawk (Rank 7)
		[27044]	= List(), -- Aspect of the Hawk (Rank 8)
	-- Mage
		[11958]	= List(), -- Ice Block A
		[27619]	= List(), -- Ice Block B
		[12043]	= List(), -- Presence of Mind
		[11129]	= List(), -- Combustion
		[12042]	= List(), -- Arcane Power
		[11426]	= List(), -- Ice Barrier (Rank 1)
		[13031]	= List(), -- Ice Barrier (Rank 2)
		[13032]	= List(), -- Ice Barrier (Rank 3)
		[13033]	= List(), -- Ice Barrier (Rank 4)
		[27134]	= List(), -- Ice Barrier (Rank 5)
		[33405]	= List(), -- Ice Barrier (Rank 6)
	-- Paladin
		[1044]	= List(), -- Blessing of Freedom
		[1038]	= List(), -- Blessing of Salvation
		[465]	= List(), -- Devotion Aura (Rank 1)
		[10290]	= List(), -- Devotion Aura (Rank 2)
		[643]	= List(), -- Devotion Aura (Rank 3)
		[10291]	= List(), -- Devotion Aura (Rank 4)
		[1032]	= List(), -- Devotion Aura (Rank 5)
		[10292]	= List(), -- Devotion Aura (Rank 6)
		[10293]	= List(), -- Devotion Aura (Rank 7)
		[27149]	= List(), -- Devotion Aura (Rank 8)
		[19746]	= List(), -- Concentration Aura
		[7294]	= List(), -- Retribution Aura (Rank 1)
		[10298]	= List(), -- Retribution Aura (Rank 2)
		[10299]	= List(), -- Retribution Aura (Rank 3)
		[10300]	= List(), -- Retribution Aura (Rank 4)
		[10301]	= List(), -- Retribution Aura (Rank 5)
		[27150]	= List(), -- Retribution Aura (Rank 6)
		[19876]	= List(), -- Shadow Resistance Aura (Rank 1)
		[19895]	= List(), -- Shadow Resistance Aura (Rank 2)
		[19896]	= List(), -- Shadow Resistance Aura (Rank 3)
		[27151]	= List(), -- Shadow Resistance Aura (Rank 4)
		[19888]	= List(), -- Frost Resistance Aura (Rank 1)
		[19897]	= List(), -- Frost Resistance Aura (Rank 2)
		[19898]	= List(), -- Frost Resistance Aura (Rank 3)
		[27152]	= List(), -- Frost Resistance Aura (Rank 4)
		[19891]	= List(), -- Fire Resistance Aura (Rank 1)
		[19899]	= List(), -- Fire Resistance Aura (Rank 2)
		[19900]	= List(), -- Fire Resistance Aura (Rank 3)
		[27153]	= List(), -- Fire Resistance Aura (Rank 4)
	-- Priest
		[15473]	= List(), -- Shadowform
		[10060]	= List(), -- Power Infusion
		[14751]	= List(), -- Inner Focus
		[1706]	= List(), -- Levitate
		[586]	= List(), -- Fade (Rank 1)
		[9578]	= List(), -- Fade (Rank 2)
		[9579]	= List(), -- Fade (Rank 3)
		[9592]	= List(), -- Fade (Rank 4)
		[10941]	= List(), -- Fade (Rank 5)
		[10942]	= List(), -- Fade (Rank 6)
		[25429]	= List(), -- Fade (Rank 7)
	-- Rogue
		[14177]	= List(), -- Cold Blood
		[13877]	= List(), -- Blade Flurry
		[13750]	= List(), -- Adrenaline Rush
		[2983]	= List(), -- Sprint (Rank 1)
		[8696]	= List(), -- Sprint (Rank 2)
		[11305]	= List(), -- Sprint (Rank 3)
		[5171]	= List(), -- Slice and Dice (Rank 1)
		[6774]	= List(), -- Slice and Dice (Rank 2)
	-- Shaman
		[2645]	= List(), -- Ghost Wolf
		[324]	= List(), -- Lightning Shield (Rank 1)
		[325]	= List(), -- Lightning Shield (Rank 2)
		[905]	= List(), -- Lightning Shield (Rank 3)
		[945]	= List(), -- Lightning Shield (Rank 4)
		[8134]	= List(), -- Lightning Shield (Rank 5)
		[10431]	= List(), -- Lightning Shield (Rank 6)
		[10432]	= List(), -- Lightning Shield (Rank 7)
		[25469]	= List(), -- Lightning Shield (Rank 8)
		[25472]	= List(), -- Lightning Shield (Rank 9)
		[16188]	= List(), -- Nature's Swiftness
		[16166]	= List(), -- Elemental Mastery
		[24398]	= List(), -- Water Shield (Rank 1)
		[33736]	= List(), -- Water Shield (Rank 2)
	-- Warlock
		[18788]	= List(), -- Demonic Sacrifice
		[5697]	= List(), -- Unending Breath
		[19028]	= List(), -- Soul Link A
		[25228]	= List(), -- Soul Link B
	-- Warrior
		[12975]	= List(), -- Last Stand
		[871]	= List(), -- Shield Wall
		[20230]	= List(), -- Retaliation
		[1719]	= List(), -- Recklessness
		[18499]	= List(), -- Berserker Rage
		[2687]	= List(), -- Bloodrage
		[12328]	= List(), -- Death Wish
		[2565]	= List(), -- Shield Block
		[12880]	= List(), -- Enrage (Rank 1)
		[14201]	= List(), -- Enrage (Rank 2)
		[14202]	= List(), -- Enrage (Rank 3)
		[14203]	= List(), -- Enrage (Rank 4)
		[14204]	= List(), -- Enrage (Rank 5)
	-- Racial
		[20554]	= List(), -- Berserking
		[7744]	= List(), -- Will of the Forsaken
		[20572]	= List(), -- Blood Fury
		[6346]	= List(), -- Fear Ward
		[20594]	= List(), -- Stoneform
	},
}

-- Buffs that really we dont need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
	-- General
		[186403] = List(), -- Sign of Battle
	},
}

-- A list of important buffs that we always want to see
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
	-- Druid
	-- Hunter
	-- Mage
	-- Paladin
	-- Priest
	-- Rogue
	-- Shaman
	-- Warlock
	-- Warrior
	-- Racial
	},
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	spells = {
	-------------------------------------------------
	-------------------- Phase 1 --------------------
	-------------------------------------------------
	-- Karazhan
		-- Attument the Huntsman
		[29833]	= List(2), -- Intangible Presence
		[29711]	= List(2), -- Knockdown
		-- Moroes
		[29425]	= List(2), -- Gouge
		[34694]	= List(2), -- Blind
		[37066]	= List(2), -- Garrote
		-- Opera Hall Event
		[30822]	= List(2), -- Poisoned Thrust
		[30889]	= List(2), -- Powerful Attraction
		[30890]	= List(2), -- Blinding Passion
		-- Maiden of Virtue
		[29511]	= List(2), -- Repentance
		[29522]	= List(2), -- Holy Fire
		[29512]	= List(2), -- Holy Ground
		-- The Curator
		-- Terestian Illhoof
		[30053]	= List(2), -- Amplify Flames
		[30115]	= List(2), -- Sacrifice
		-- Shade of Aran
		[29946]	= List(2), -- Flame Wreath
		[29947]	= List(2), -- Flame Wreath
		[29990]	= List(2), -- Slow
		[29991]	= List(2), -- Chains of Ice
		[29954]	= List(2), -- Frostbolt
		[29951]	= List(2), -- Blizzard
		-- Netherspite
		[38637]	= List(2), -- Nether Exhaustion (Red)
		[38638]	= List(2), -- Nether Exhaustion (Green)
		[38639]	= List(2), -- Nether Exhaustion (Blue)
		[30400]	= List(2), -- Nether Beam - Perseverence
		[30401]	= List(2), -- Nether Beam - Serenity
		[30402]	= List(2), -- Nether Beam - Dominance
		[30421]	= List(2), -- Nether Portal - Perseverence
		[30422]	= List(2), -- Nether Portal - Serenity
		[30423]	= List(2), -- Nether Portal - Dominance
		-- Chess Event
		[30529]	= List(2), -- Recently In Game
		-- Prince Malchezaar
		[39095]	= List(2), -- Amplify Damage
		[30898]	= List(2), -- Shadow Word: Pain 1
		[30854]	= List(2), -- Shadow Word: Pain 2
		-- Nightbane
		[37091]	= List(2), -- Rain of Bones
		[30210]	= List(2), -- Smoldering Breath
		[30129]	= List(2), -- Charred Earth
		[30127]	= List(2), -- Searing Cinders
		[36922]	= List(2), -- Bellowing Roar
	-- Gruul's Lair
		-- High King Maulgar
		[36032]	= List(2), -- Arcane Blast
		[11726]	= List(2), -- Enslave Demon
		[33129]	= List(2), -- Dark Decay
		[33175]	= List(2), -- Arcane Shock
		[33061]	= List(2), -- Blast Wave
		[33130]	= List(2), -- Death Coil
		[16508]	= List(2), -- Intimidating Roar
		-- Gruul the Dragonkiller
		[38927]	= List(2), -- Fel Ache
		[36240]	= List(2), -- Cave In
		[33652]	= List(2), -- Stoned
		[33525]	= List(2), -- Ground Slam
	-- Magtheridon's Lair
		-- Magtheridon
		[44032]	= List(2), -- Mind Exhaustion
		[30530]	= List(2), -- Fear
	-------------------------------------------------
	-------------------- Phase 2 --------------------
	-------------------------------------------------
	-- Serpentshrine Cavern
		-- Trash
		[38634] = List(3), -- Arcane Lightning
		[39032] = List(4), -- Initial Infection
		[38572] = List(3), -- Mortal Cleave
		[38635] = List(3), -- Rain of Fire
		[39042] = List(5), -- Rampent Infection
		[39044] = List(4), -- Serpentshrine Parasite
		[38591] = List(4), -- Shatter Armor
		[38491] = List(3), -- Silence
		-- Hydross the Unstable
		[38246] = List(3), -- Vile Sludge
		[38235] = List(4), -- Water Tomb
		-- Leotheras the Blind
		[37675] = List(3), -- Chaos Blast
		[37749] = List(5), -- Consuming Madness
		[37676] = List(4), -- Insidious Whisper
		[37641] = List(3), -- Whirlwind
		-- Fathom-Lord Karathress
		[39261] = List(3), -- Gusting Winds
		[29436] = List(4), -- Leeching Throw
		-- Morogrim Tidewalker
		[38049] = List(4), -- Watery Grave
		[37850] = List(4), -- Watery Grave
		-- Lady Vashj
		[38280] = List(5), -- Static Charge
		[38316] = List(3), -- Entangle
	-- The Eye
		-- Trash
		[37133] = List(4), -- Arcane Buffet
		[37132] = List(3), -- Arcane Shock
		[37122] = List(5), -- Domination
		[37135] = List(5), -- Domination
		[37120] = List(4), -- Fragmentation Bomb
		[13005] = List(3), -- Hammer of Justice
		[39077] = List(3), -- Hammer of Justice
		[37279] = List(3), -- Rain of Fire
		[37123] = List(4), -- Saw Blade
		[37118] = List(5), -- Shell Shock
		[37160] = List(3), -- Silence
		-- Al'ar
		[35410] = List(4), -- Melt Armor
		-- High Astromancer Solarian
		[34322] = List(4), -- Psychic Scream
		[42783] = List(5), -- Wrath of the Astromancer (Patch 2.2.0)
		-- Kael'thas Sunstrider
		[36965] = List(4), -- Rend
		[30225] = List(4), -- Silence
		[44863] = List(5), -- Bellowing Roar
		[37018] = List(4), -- Conflagration
		[37027] = List(5), -- Remote Toy
		[36991] = List(4), -- Rend
		[36797] = List(5), -- Mind Control
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- The Battle for Mount Hyjal
		-- Rage Winterchill
		[31249] = List(6), -- Icebolt
		[31250] = List(5), -- Frost Nova
		-- Anetheron
		[31302] = List(4), -- Inferno
		[31298] = List(5), -- Sleep
		[31306] = List(6), -- Carrion Swarm
		-- Kaz'rogal
		[31447] = List(3), -- Mark of Kaz'rogal
		-- Azgalor
		[31341] = List(5), -- Unquenchable Flames
		[31340] = List(4), -- Rain of Fire
		[31347] = List(6), -- Doom
		-- Archimonde
		[31972] = List(6), -- Grip of the Legion
		[31970] = List(3), -- Fear
		[31944] = List(5), -- Doomfire
		-- Trash
		[31610] = List(3), -- Knockdown
		[28991] = List(2), -- Web
	-- Black Temple
		-- High Warlord Naj'entus
		[39837] = List(2), -- Impaling Spine
		-- Supremus
		[40253] = List(2), -- Molten Flame
		-- Shade of Akama
		[42023] = List(2), -- Rain of Fire
		-- Teron Gorefiend
		[40243] = List(5), -- Crushing Shadows
		[40239] = List(6), -- Incinerate
		[40251] = List(4), -- Shadow of Death
		-- Gurtogg Bloodboil
		[40481] = List(6), -- Acidic Wound
		[40599] = List(5), -- Arcing Smash
		[40491] = List(6), -- Bewildering Strike
		[42005] = List(4), -- Bloodboil
		[40508] = List(5), -- Fel Acid Breath
		[40604] = List(6), -- Fel Rage
		-- Reliquary of Souls
		[41303] = List(3), -- Soul Drain
		[41410] = List(3), -- Deaden
		[41426] = List(2), -- Spirit Shack
		[41294] = List(2), -- Fixate
		[41376] = List(3), -- Spite
		-- Mother Shahraz
		[41001] = List(6), -- Fatal Attraction
		[40860] = List(5), -- Vile Beam
		[40823] = List(4), -- Interrupting Shriek
		-- Illidari Council
		[41541] = List(2), -- Consecration
		[41468] = List(3), -- Hammer of Justice
		[41461] = List(6), -- Judgement of Blood
		[41485] = List(6), -- Deadly Poison
		[41472] = List(6), -- Divine Wrath
		[41482] = List(2), -- Blizzard
		[41481] = List(3), -- Flamestrike
		-- Illidan Stormrage
		[40932] = List(6), -- Agonizing Flame
		[41032] = List(6), -- Shear
		[40585] = List(5), -- Dark Barrage
		[41914] = List(4), -- Parasitic Shadowfiend
		[41142] = List(2), -- Aura of Dread
		-- Trash
		[41213] = List(3), -- Throw Shield
		[40864] = List(3), -- Throbbing Stun
		[41197] = List(3), -- Shield Bash
		[41171] = List(3), -- Skeleton Shot
		[41338] = List(3), -- Love Tap
		[13444] = List(2), -- Sunder Armor
		[41396] = List(2), -- Sleep
		[41334] = List(2), -- Polymorph
		[24698] = List(2), -- Gauge
		[41150] = List(2), -- Fear
		[34654] = List(2), -- Blind
		[39674] = List(2), -- Banish
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Zul'Aman
		-- Nalorakk
		[42398] = List(2), -- Mangle
		-- Jan'alai
		[43299] = List(2), -- Flame Buffet
		-- Akil'zon
		[43657] = List(3), -- Electrical Storm
		[43622] = List(2), -- Static Disruption
		-- Halazzi
		[43303] = List(2), -- Flame Shock
		-- Hexxlord Jin'Zakk
		[43613] = List(3), -- Cold Stare
		[43501] = List(2), -- Siphon Soul
		-- Zul'jin
		[43150] = List(3), -- Rage
		[43095] = List(2), -- Paralyze
		[43093] = List(3), -- Throw
	-------------------------------------------------
	-------------------- Phase 5 --------------------
	-------------------------------------------------
	-- Sunwell Plateau
		-- Kalecgos
		[45018] = List(2), -- Arcane Buffet
		[45032] = List(2), -- Boundless Agony
		-- Brutallus
		[46394] = List(5), -- Burn
		[45150] = List(3), -- Meteor Slash
		[45185] = List(6), -- Stomp
		-- Felmyst
		[45855] = List(3), -- Gas Nova
		[45662] = List(6), -- Encapsulate
		[45402] = List(2), -- Demonic Vapor
		[45717] = List(5), -- Fog of Corruption
		-- Eredar Twins
		[45256] = List(3), -- Confounding Blow
		[45270] = List(2), -- Shadowfury
		[45333] = List(4), -- Conflagration
		[45347] = List(2), -- Dark Touched
		[45348] = List(2), -- Fire Touched
		[46771] = List(3), -- Flame Sear
		-- M'uru
		[45996] = List(6), -- Darkness
		-- Kil'Jaeden
		[45442] = List(2), -- Soul Flay
		[45641] = List(6), -- Fire Bloom
		[45737] = List(2), -- Flame Dart
		[45885] = List(2), -- Shadow Spike
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
	-------------------------------------------------
	-------------------- Phase 1 --------------------
	-------------------------------------------------
	-- Karazhan
		-- Attument the Huntsman
		-- Moroes
		[29448] = List(), -- Vanish
		[37023] = List(), -- Enrage
		-- Opera Hall Event
		[30887] = List(), -- Devotion
		[30841] = List(), -- Daring
		-- Maiden of Virtue
		[32429] = List(), -- Draining Touch
		-- The Curator
		-- Terestian Illhoof
		[29908] = List(), -- Astral Bite
		-- Shade of Aran
		[29920] = List(), -- Phasing Invisibility
		[29921] = List(), -- Phasing Invisibility
		-- Netherspite
		[30522] = List(), -- Nether Burn
		[30487] = List(), -- Nether Portal - Perseverence
		[30491] = List(), -- Nether Portal - Domination
		-- Chess Event
		[37469] = List(), -- Poison Cloud
		-- Prince Malchezaar
		[30859] = List(), -- Hellfire
		-- Nightbane
		[37098] = List(), -- Rain of Bones
	-- Gruul's Lair
		-- High King Maulgar
		[33232] = List(), -- Flurry
		[33238] = List(), -- Whirlwind
		[33054] = List(), -- Spell Shield
		-- Gruul the Dragonkiller
		[36300] = List(), -- Growth
	-- Magtheridon's Lair
		-- Magtheridon
		[30205] = List(), -- Shadow Cage
		[30576] = List(), -- Quake
		[30207] = List(), -- Shadow Grasp
	-------------------------------------------------
	-------------------- Phase 2 --------------------
	-------------------------------------------------
	-- Serpentshrine Cavern
		-- Hydross the Unstable
		[37935] = List(), -- Cleansing Field
		-- The Lurker Below
		-- Leotheras the Blind
		[37640] = List(), -- Whirlwind
		-- Fathom-Lord Karathress
		[38451] = List(), -- Power of Caribdis
		[38452] = List(), -- Power of Tidalvess
		[38455] = List(), -- Power of Sharkkis
		[38516] = List(), -- Cyclone
		[38373] = List(), -- The Beast Within
		-- Morogrim Tidewalker
		-- Lady Vashj
		[38112] = List(), -- Magic Barrier
	-- The Eye
		-- Al'ar
		[35412] = List(), -- Charge
		-- Void Reaver
		[34162] = List(), -- Pounding
		-- High Astromancer Solarian
		-- Kael'thas Sunstrider
		[36981] = List(), -- Whirlwind
		[36815] = List(), -- Shock Barrier
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- The Battle for Mount Hyjal
		-- Rage Winterchill
		[31256] = List(), -- Frost Armor
		-- Anetheron
		-- Kaz'rogal
		-- Azgalor
		-- Archimonde
		[31540] = List(), -- Frenzy
	-- Black Temple
		-- High Warlord Naj'entus
		[40076] = List(), -- Electric Spur
		-- Supremus
		[42055] = List(), -- Volcanic Geyser
		-- Shade of Akama
		[34970] = List(), -- Enrage
		-- Teron Gorefiend
		[41254] = List(), -- Frenzy
		-- Gurtogg Bloodboil
		[40594] = List(), -- Fel Rage
		[40601] = List(), -- Fury
		-- Reliquary of Souls
		[41305] = List(), -- Enrage
		[41431] = List(), -- Rune Shield
		-- Mother Shahraz
		-- Illidari Council
		[41450] = List(), -- Blessing of Protection
		[41451] = List(), -- Blessing of Spell Warding
		[41452] = List(), -- Devotion Aura
		[41453] = List(), -- Chromatic Resistance Aura
		[41475] = List(3), -- Reflective Shield
		-- Illidan Stormrage
		[40836] = List(), -- Flame Crash
		[40610] = List(), -- Blaze
		[40683] = List(), -- Enrage
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Zul'Aman
		-- Nalorakk
		-- Jan'alai
		[44779] = List(), -- Enrage
		-- Akil'zon
		-- Halazzi
		[43290] = List(), -- Lynx Flurry
		-- Hexlord Jin'Zakk
		[43578] = List(), -- Bloodlust
		[43430] = List(), -- Avenging Wrath
		-- Zul'jin
		[17207] = List(), -- Whirlwind
		[43213] = List(), -- Flame Whirl
		[43120] = List(), -- Cyclone
	-------------------------------------------------
	-------------------- Phase 5 --------------------
	-------------------------------------------------
	-- Sunwell Plateau
		-- Kalecgos
		[44806] = List(), -- Crazed Rage
		-- Brutallus
		-- Felmyst
		-- Eredar Twins
		[45366] = List(), -- Empower
		[45230] = List(), -- Pyrogenics
		-- M'uru
		[45934] = List(), -- Dark Fiend
		[46160] = List(), -- Flurry
		[45996] = List(), -- Darkness
		[46102] = List(), -- Spell Fury
		-- Kil'Jaeden
		[46680] = List(), -- Shadow Spike
		[46474] = List(), -- Sacrifice of Aveena
		[46605] = List(), -- Darkness of a Thousand Souls
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {},
	ROGUE = {}, -- No buffs
	WARRIOR = {
		[6673]	= Aura(6673, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 1)
		[5242]	= Aura(5242, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 2)
		[6192]	= Aura(6192, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 3)
		[11549]	= Aura(11549, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 4)
		[11550]	= Aura(11550, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 5)
		[11551]	= Aura(11551, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 6)
		[25289]	= Aura(25289, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 7)
		[2048]	= Aura(2048, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 8)
		[469]	= Aura(469, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Commanding Shout
	},
	PRIEST = {
		[1243]	= Aura(1243, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 1)
		[1244]	= Aura(1244, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 2)
		[1245]	= Aura(1245, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 3)
		[2791]	= Aura(2791, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 4)
		[10937]	= Aura(10937, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 5)
		[10938]	= Aura(10938, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 6)
		[25389]	= Aura(25389, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 7)
		[21562]	= Aura(21562, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 1)
		[21564]	= Aura(21564, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 2)
		[25392]	= Aura(25392, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 3)
		[14752]	= Aura(14752, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 1)
		[14818]	= Aura(14818, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 2)
		[14819]	= Aura(14819, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 3)
		[27841]	= Aura(27841, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 4)
		[25312]	= Aura(25312, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 5)
		[27681]	= Aura(27681, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 1)
		[32999]	= Aura(32999, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 2)
		[976]	= Aura(976, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),		-- Shadow Protection (Rank 1)
		[10957]	= Aura(10957, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 2)
		[10958]	= Aura(10958, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 3)
		[25433]	= Aura(25433, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 4)
		[27683]	= Aura(27683, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 1)
		[39374]	= Aura(39374, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 2)
		[17]	= Aura(17, 'BOTTOM', {0.00, 0.00, 1.00}),				-- Power Word: Shield (Rank 1)
		[592]	= Aura(592, 'BOTTOM', {0.00, 0.00, 1.00}),				-- Power Word: Shield (Rank 2)
		[600]	= Aura(600, 'BOTTOM', {0.00, 0.00, 1.00}),				-- Power Word: Shield (Rank 3)
		[3747]	= Aura(3747, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 4)
		[6065]	= Aura(6065, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 5)
		[6066]	= Aura(6066, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 6)
		[10898]	= Aura(10898, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 7)
		[10899]	= Aura(10899, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 8)
		[10900]	= Aura(10900, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 9)
		[10901]	= Aura(10901, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 10)
		[25217]	= Aura(25217, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 11)
		[25218]	= Aura(25218, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 12)
		[139]	= Aura(139, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 1)
		[6074]	= Aura(6074, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 2)
		[6075]	= Aura(6075, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 3)
		[6076]	= Aura(6076, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 4)
		[6077]	= Aura(6077, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 5)
		[6078]	= Aura(6078, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 6)
		[10927]	= Aura(10927, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 7)
		[10928]	= Aura(10928, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 8)
		[10929]	= Aura(10929, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 9)
		[25315]	= Aura(25315, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 10)
		[25221]	= Aura(25221, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 11)
		[25222]	= Aura(25222, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 12)
	},
	DRUID = {
		[1126]	= Aura(1126, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 1)
		[5232]	= Aura(5232, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 2)
		[6756]	= Aura(6756, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 3)
		[5234]	= Aura(5234, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 4)
		[8907]	= Aura(8907, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 5)
		[9884]	= Aura(9884, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 6)
		[9885]	= Aura(9885, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 7)
		[26990]	= Aura(26990, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 8)
		[21849]	= Aura(21849, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 1)
		[21850]	= Aura(21850, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 2)
		[26991]	= Aura(26991, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 3)
		[467]	= Aura(467, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 1)
		[782]	= Aura(782, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 2)
		[1075]	= Aura(1075, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 3)
		[8914]	= Aura(8914, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 4)
		[9756]	= Aura(9756, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 5)
		[9910]	= Aura(9910, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 6)
		[26992]	= Aura(26992, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 7)
		[774]	= Aura(774, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),		-- Rejuvenation (Rank 1)
		[1058]	= Aura(1058, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 2)
		[1430]	= Aura(1430, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 3)
		[2090]	= Aura(2090, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 4)
		[2091]	= Aura(2091, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 5)
		[3627]	= Aura(3627, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 6)
		[8910]	= Aura(8910, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 7)
		[9839]	= Aura(9839, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 8)
		[9840]	= Aura(9840, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 9)
		[9841]	= Aura(9841, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 10)
		[25299]	= Aura(25299, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 11)
		[26981]	= Aura(26981, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 12)
		[26982]	= Aura(26982, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 13)
		[8936]	= Aura(8936, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 1)
		[8938]	= Aura(8938, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 2)
		[8939]	= Aura(8939, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 3)
		[8940]	= Aura(8940, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 4)
		[8941]	= Aura(8941, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 5)
		[9750]	= Aura(9750, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 6)
		[9856]	= Aura(9856, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 7)
		[9857]	= Aura(9857, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 8)
		[9858]	= Aura(9858, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 9)
		[26980]	= Aura(26980, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 10)
		[29166]	= Aura(29166, 'CENTER', {0.49, 0.60, 0.55}, true),	-- Innervate
		[33763]	= Aura(33763, 'BOTTOM', {0.33, 0.37, 0.47}),		-- Lifebloom
	},
	PALADIN = {
		[1044]	= Aura(1044, 'CENTER', {0.89, 0.45, 0}),					-- Blessing of Freedom
		[1038]	= Aura(1038, 'TOPLEFT', {0.11, 1.00, 0.45}, true),			-- Blessing of Salvation
		[6940]	= Aura(6940, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 1)
		[20729]	= Aura(20729, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 2)
		[27147]	= Aura(27147, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 3)
		[27148]	= Aura(27148, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 4)
		[19740]	= Aura(19740, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 1)
		[19834]	= Aura(19834, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 2)
		[19835]	= Aura(19835, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 3)
		[19836]	= Aura(19836, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 4)
		[19837]	= Aura(19837, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 5)
		[19838]	= Aura(19838, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 6)
		[25291]	= Aura(25291, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 7)
		[27140]	= Aura(27140, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 8)
		[19742]	= Aura(19742, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 1)
		[19850]	= Aura(19850, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 2)
		[19852]	= Aura(19852, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 3)
		[19853]	= Aura(19853, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 4)
		[19854]	= Aura(19854, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 5)
		[25290]	= Aura(25290, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 6)
		[27142]	= Aura(27142, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 7)
		[25782]	= Aura(25782, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 1)
		[25916]	= Aura(25916, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 2)
		[27141]	= Aura(27141, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 3)
		[25894]	= Aura(25894, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 1)
		[25918]	= Aura(25918, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 2)
		[27143]	= Aura(27143, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 3)
		[465]	= Aura(465, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 1)
		[10290]	= Aura(10290, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 2)
		[643]	= Aura(643, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 3)
		[10291]	= Aura(10291, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 4)
		[1032]	= Aura(1032, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 5)
		[10292]	= Aura(10292, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 6)
		[10293]	= Aura(10293, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 7)
		[27149]	= Aura(27149, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 8)
		[19977]	= Aura(19977, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 1)
		[19978]	= Aura(19978, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 2)
		[19979]	= Aura(19979, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 3)
		[27144]	= Aura(27144, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 4)
		[1022]	= Aura(1022, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 1)
		[5599]	= Aura(5599, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 2)
		[10278]	= Aura(10278, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 3)
		[19746]	= Aura(19746, 'BOTTOMLEFT', {0.83, 1.00, 0.07}),			-- Concentration Aura
		[32223]	= Aura(32223, 'BOTTOMLEFT', {0.83, 1.00, 0.07}),			-- Crusader Aura
	},
	SHAMAN = {
		[29203]	= Aura(29203, 'TOPRIGHT', {0.7, 0.3, 0.7}),		-- Healing Way
		[16237]	= Aura(16237, 'RIGHT', {0.2, 0.2, 1}),				-- Ancestral Fortitude
		[8185]	= Aura(8185, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 1)
		[10534]	= Aura(10534, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 2)
		[10535]	= Aura(10535, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 3)
		[25563]	= Aura(25563, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 4)
		[8182]	= Aura(8182, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 1)
		[10476]	= Aura(10476, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 2)
		[10477]	= Aura(10477, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 3)
		[25560]	= Aura(25560, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 4)
		[10596]	= Aura(10596, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 1)
		[10598]	= Aura(10598, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 2)
		[10599]	= Aura(10599, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 3)
		[25574]	= Aura(25574, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 4)
		[5672]	= Aura(5672, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 1)
		[6371]	= Aura(6371, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 2)
		[6372]	= Aura(6372, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 3)
		[10460]	= Aura(10460, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 4)
		[10461]	= Aura(10461, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 5)
		[25567]	= Aura(25567, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 6)
		[16191]	= Aura(16191, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 1)
		[17355]	= Aura(17355, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 2)
		[17360]	= Aura(17360, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 3)
		[5677]	= Aura(5677, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 1)
		[10491]	= Aura(10491, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 2)
		[10493]	= Aura(10493, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 3)
		[10494]	= Aura(10494, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 4)
		[25570]	= Aura(25570, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 5)
		[8072]	= Aura(8072, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 1)
		[8156]	= Aura(8156, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 2)
		[8157]	= Aura(8157, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 3)
		[10403]	= Aura(10403, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 4)
		[10404]	= Aura(10404, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 5)
		[10405]	= Aura(10405, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 6)
		[25508]	= Aura(25508, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 7)
		[25509]	= Aura(25509, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 8)
		[974]	= Aura(974, 'TOP', {0.08, 0.21, 0.43}, true),		-- Earth Shield (Rank 1)
		[32593]	= Aura(32593, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 2)
		[32594]	= Aura(32594, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 3)
	},
	MAGE = {
		[1459]	= Aura(1459, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 1)
		[1460]	= Aura(1460, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 2)
		[1461]	= Aura(1461, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 3)
		[10156]	= Aura(10156, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 4)
		[10157]	= Aura(10157, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 5)
		[27126]	= Aura(27126, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 6)
		[23028]	= Aura(23028, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 1)
		[27127]	= Aura(27127, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 2)
		[604]	= Aura(604, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 1)
		[8450]	= Aura(8450, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 2)
		[8451]	= Aura(8451, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 3)
		[10173]	= Aura(10173, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 4)
		[10174]	= Aura(10174, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 5)
		[33944]	= Aura(33944, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 6)
		[1008]	= Aura(1008, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 1)
		[8455]	= Aura(8455, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 2)
		[10169]	= Aura(10169, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 3)
		[10170]	= Aura(10170, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 4)
		[27130]	= Aura(27130, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 5)
		[33946]	= Aura(33946, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 6)
		[130]	= Aura(130, 'CENTER', {0.00, 0.00, 0.50}, true),		-- Slow Fall
	},
	HUNTER = {
		[19506]	= Aura(19506, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 1)
		[20905]	= Aura(20905, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 2)
		[20906]	= Aura(20906, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 3)
		[27066]	= Aura(27066, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 4)
		[13159]	= Aura(13159, 'TOP', {0.00, 0.00, 0.85}, true),	-- Aspect of the Pack
		[20043]	= Aura(20043, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 1)
		[20190]	= Aura(20190, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 2)
		[27045]	= Aura(27045, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 3)
	},
	WARLOCK = {
		[5597]	= Aura(5597, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Unending Breath
		[6512]	= Aura(6512, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Lesser Invisibility
		[2970]	= Aura(2970, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Invisibility
		[11743]	= Aura(11743, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Greater Invisibility
	},
	PET = {
	-- Warlock Imp
		[6307]	= Aura(6307, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 1)
		[7804]	= Aura(7804, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 2)
		[7805]	= Aura(7805, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 3)
		[11766]	= Aura(11766, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 4)
		[11767]	= Aura(11767, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 5)
	-- Warlock Felhunter
		[19480]	= Aura(19480, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Paranoia
	-- Hunter Pets
		[24604]	= Aura(24604, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 1)
		[24605]	= Aura(24605, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 2)
		[24603]	= Aura(24603, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 3)
		[24597]	= Aura(24597, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 4)
	},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- First Aid
	[27031]	= 8, -- Heavy Netherweave Bandage
	[27030]	= 8, -- Netherweave Bandage
	[23567]	= 8, -- Warsong Gulch Runecloth Bandage
	[23696]	= 8, -- Alterac Heavy Runecloth Bandage
	[24414]	= 8, -- Arathi Basin Runecloth Bandage
	[18610]	= 8, -- Heavy Runecloth Bandage
	[18608]	= 8, -- Runecloth Bandage
	[10839]	= 8, -- Heavy Mageweave Bandage
	[10838]	= 8, -- Mageweave Bandage
	[7927]	= 8, -- Heavy Silk Bandage
	[7926]	= 8, -- Silk Bandage
	[3268]	= 7, -- Heavy Wool Bandage
	[3267]	= 7, -- Wool Bandage
	[1159]	= 6, -- Heavy Linen Bandage
	[746]	= 6, -- Linen Bandage
	-- Warlock
	[1120]	= 5, -- Drain Soul (Rank 1)
	[8288]	= 5, -- Drain Soul (Rank 2)
	[8289]	= 5, -- Drain Soul (Rank 3)
	[11675]	= 5, -- Drain Soul (Rank 4)
	[27217]	= 5, -- Drain Soul (Rank 5)
	[755]	= 10, -- Health Funnel (Rank 1)
	[3698]	= 10, -- Health Funnel (Rank 2)
	[3699]	= 10, -- Health Funnel (Rank 3)
	[3700]	= 10, -- Health Funnel (Rank 4)
	[11693]	= 10, -- Health Funnel (Rank 5)
	[11694]	= 10, -- Health Funnel (Rank 6)
	[11695]	= 10, -- Health Funnel (Rank 7)
	[27259]	= 10, -- Health Funnel (Rank 8)
	[689]	= 5, -- Drain Life (Rank 1)
	[699]	= 5, -- Drain Life (Rank 2)
	[709]	= 5, -- Drain Life (Rank 3)
	[7651]	= 5, -- Drain Life (Rank 4)
	[11699]	= 5, -- Drain Life (Rank 5)
	[11700]	= 5, -- Drain Life (Rank 6)
	[27219]	= 5, -- Drain Life (Rank 7)
	[27220]	= 5, -- Drain Life (Rank 8)
	[5740]	= 4, -- Rain of Fire (Rank 1)
	[6219]	= 4, -- Rain of Fire (Rank 2)
	[11677]	= 4, -- Rain of Fire (Rank 3)
	[11678]	= 4, -- Rain of Fire (Rank 4)
	[27212]	= 4, -- Rain of Fire (Rank 5)
	[1949]	= 15, -- Hellfire (Rank 1)
	[11683]	= 15, -- Hellfire (Rank 2)
	[11684]	= 15, -- Hellfire (Rank 3)
	[27213]	= 15, -- Hellfire (Rank 4)
	[5138]	= 5, -- Drain Mana (Rank 1)
	[6226]	= 5, -- Drain Mana (Rank 2)
	[11703]	= 5, -- Drain Mana (Rank 3)
	[11704]	= 5, -- Drain Mana (Rank 4)
	[27221]	= 5, -- Drain Mana (Rank 5)
	[30908]	= 5, -- Drain Mana (Rank 6)
	-- Priest
	[15407]	= 3, -- Mind Flay (Rank 1)
	[17311]	= 3, -- Mind Flay (Rank 2)
	[17312]	= 3, -- Mind Flay (Rank 3)
	[17313]	= 3, -- Mind Flay (Rank 4)
	[17314]	= 3, -- Mind Flay (Rank 5)
	[18807]	= 3, -- Mind Flay (Rank 6)
	[25387]	= 3, -- Mind Flay (Rank 7)
	-- Mage
	[10]	= 8, -- Blizzard (Rank 1)
	[6141]	= 8, -- Blizzard (Rank 2)
	[8427]	= 8, -- Blizzard (Rank 3)
	[10185]	= 8, -- Blizzard (Rank 4)
	[10186]	= 8, -- Blizzard (Rank 5)
	[10187]	= 8, -- Blizzard (Rank 6)
	[27085]	= 8, -- Blizzard (Rank 7)
	[5143]	= 3, -- Arcane Missiles (Rank 1)
	[5144]	= 4, -- Arcane Missiles (Rank 2)
	[5145]	= 5, -- Arcane Missiles (Rank 3)
	[8416]	= 5, -- Arcane Missiles (Rank 4)
	[8417]	= 5, -- Arcane Missiles (Rank 5)
	[10211]	= 5, -- Arcane Missiles (Rank 6)
	[10212]	= 5, -- Arcane Missiles (Rank 7)
	[25345]	= 5, -- Arcane Missiles (Rank 8)
	[27075]	= 5, -- Arcane Missiles (Rank 9)
	[38699]	= 5, -- Arcane Missiles (Rank 10)
	[12051]	= 4, -- Evocation
	--Druid
	[740]	= 5, -- Tranquility (Rank 1)
	[8918]	= 5, -- Tranquility (Rank 2)
	[9862]	= 5, -- Tranquility (Rank 3)
	[9863]	= 5, -- Tranquility (Rank 4)
	[26983]	= 5, -- Tranquility (Rank 5)
	[16914]	= 10, -- Hurricane (Rank 1)
	[17401]	= 10, -- Hurricane (Rank 2)
	[17402]	= 10, -- Hurricane (Rank 3)
	[27012]	= 10, -- Hurricane (Rank 4)
	--Hunter
	[1510]	= 6, -- Volley (Rank 1)
	[14294]	= 6, -- Volley (Rank 2)
	[14295]	= 6, -- Volley (Rank 3)
	[27022]	= 6, -- Volley (Rank 4)
}

-- Spells Effected By Talents
G.unitframe.TalentChannelTicks = {
	-- Priest
	[47757]	= 4, -- Penance (heal)
	[47758]	= 4, -- Penance (dps)
}

-- Increase ticks from auras
G.unitframe.AuraChannelTicks = {
	-- Warlock
	[198590]	= 1, -- Drain Soul
}

-- Spells Effected By Haste, value is Base Tick Size
G.unitframe.HastedChannelTicks = {
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

G.unitframe.specialFilters = {
	-- Whitelists
	Boss = true,
	MyPet = true,
	OtherPet = true,
	Personal = true,
	nonPersonal = true,
	CastByUnit = true,
	notCastByUnit = true,
	Dispellable = true,
	notDispellable = true,
	CastByNPC = true,
	CastByPlayers = true,
	BlizzardNameplate = true,

	-- Blacklists
	blockNonPersonal = true,
	blockCastByPlayers = true,
	blockNoDuration = true,
	blockDispellable = true,
	blockNotDispellable = true,
}
