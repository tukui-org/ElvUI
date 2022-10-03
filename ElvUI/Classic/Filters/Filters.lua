local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
		[339]	= List(1), -- Entangling Roots (Rank 1)
		[1062]	= List(1), -- Entangling Roots (Rank 2)
		[5195]	= List(1), -- Entangling Roots (Rank 3)
		[5196]	= List(1), -- Entangling Roots (Rank 4)
		[9852]	= List(1), -- Entangling Roots (Rank 5)
		[9853]	= List(1), -- Entangling Roots (Rank 6)
		[19975]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 1)
		[19974]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 2)
		[19973]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 3)
		[19972]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 4)
		[19971]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 5)
		[19970]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 6)
		[2637]	= List(1), -- Hibernate (Rank 1)
		[18657]	= List(1), -- Hibernate (Rank 2)
		[18658]	= List(1), -- Hibernate (Rank 3)
		[19675]	= List(2), -- Feral Charge Effect
		[5211]	= List(4), -- Bash (Rank 1)
		[6798]	= List(4), -- Bash (Rank 2)
		[8983]	= List(4), -- Bash (Rank 3)
		[16922]	= List(2), -- Celestial Focus (Starfire Stun)
		[9005]	= List(2), -- Pounce (Rank 1)
		[9823]	= List(2), -- Pounce (Rank 2)
		[9827]	= List(2), -- Pounce (Rank 3)
	--Hunter
		[3355]	= List(3), -- Freezing Trap Effect (Rank 1)
		[14308]	= List(3), -- Freezing Trap Effect (Rank 2)
		[14309]	= List(3), -- Freezing Trap Effect (Rank 3)
		[13810]	= List(1), -- Frost Trap Aura
		[19503]	= List(4), -- Scatter Shot
		[5116]	= List(2), -- Concussive Shot
		[2974]	= List(2), -- Wing Clip (Rank 1)
		[14267]	= List(2), -- Wing Clip (Rank 2)
		[14268]	= List(2), -- Wing Clip (Rank 3)
		[1513]	= List(2), -- Scare Beast (Rank 1)
		[14326]	= List(2), -- Scare Beast (Rank 2)
		[14327]	= List(2), -- Scare Beast (Rank 3)
		[24394]	= List(6), -- Intimidation
		[19386]	= List(2), -- Wyvern Sting (Rank 1)
		[24132]	= List(2), -- Wyvern Sting (Rank 2)
		[24133]	= List(2), -- Wyvern Sting (Rank 3)
		[19229]	= List(2), -- Improved Wing Clip
		[19306]	= List(2), -- Counterattack (Rank 1)
		[20909]	= List(2), -- Counterattack (Rank 2)
		[20910]	= List(2), -- Counterattack (Rank 3)
		[19410]	= List(2), -- Improved Concussive Shot
		[25999]	= List(2), -- Charge (Boar)
		[19185]	= List(1), -- Entrapment
	--Mage
		[118]	= List(3), -- Polymorph (Rank 1)
		[12824]	= List(3), -- Polymorph (Rank 2)
		[12825]	= List(3), -- Polymorph (Rank 3)
		[12826]	= List(3), -- Polymorph (Rank 4)
		[28271]	= List(3), -- Polymorph (Turtle)
		[28272]	= List(3), -- Polymorph (Pig)
		[122]	= List(1), -- Frost Nova (Rank 1)
		[865]	= List(1), -- Frost Nova (Rank 2)
		[6131]	= List(1), -- Frost Nova (Rank 3)
		[10230]	= List(1), -- Frost Nova (Rank 4)
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
		[12355]	= List(2), -- Impact
		[18469]	= List(2), -- Counterspell - Silenced
		[11113]	= List(2), -- Blast Wave
		[12484]	= List(2), -- Chilled (Blizzard) (Rank 1)
		[12485]	= List(2), -- Chilled (Blizzard) (Rank 2)
		[12486]	= List(2), -- Chilled (Blizzard) (Rank 3)
		[6136]	= List(2), -- Chilled (Frost Armor)
		[7321]	= List(2), -- Chilled (Ice Armor)
		[120]	= List(2), -- Cone of Cold
	--Paladin
		[853]	= List(3), -- Hammer of Justice (Rank 1)
		[5588]	= List(3), -- Hammer of Justice (Rank 2)
		[5589]	= List(3), -- Hammer of Justice (Rank 3)
		[10308]	= List(3), -- Hammer of Justice (Rank 4)
		[20066]	= List(3), -- Repentance
		[20170]	= List(2), -- Stun (Seal of Justice Proc)
		[2878]	= List(3), -- Turn Undead (Rank 1)
		[5627]	= List(3), -- Turn Undead (Rank 2)
		[10326]	= List(3), -- Turn Undead (Rank 3)
	--Priest
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
		[15487]	= List(2), -- Silence
	--Rogue
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
		[18425]	= List(2), -- Kick - Silenced
		[14251]	= List(2), -- Riposte
	--Shaman
		[2484]	= List(1), -- Earthbind Totem
		[8056]	= List(2), -- Frost Shock (Rank 1)
		[8058]	= List(2), -- Frost Shock (Rank 2)
		[10472]	= List(2), -- Frost Shock (Rank 3)
		[10473]	= List(2), -- Frost Shock (Rank 4)
		[8034]	= List(2), -- Frostbrand Attack (Rank 1)
		[8037]	= List(2), -- Frostbrand Attack (Rank 2)
		[10458]	= List(2), -- Frostbrand Attack (Rank 3)
		[16352]	= List(2), -- Frostbrand Attack (Rank 4)
		[16353]	= List(2), -- Frostbrand Attack (Rank 5)
	--Warlock
		[5782]	= List(3), -- Fear (Rank 1)
		[6213]	= List(3), -- Fear (Rank 2)
		[6215]	= List(3), -- Fear (Rank 3)
		[6358]	= List(3), -- Seduction (Succubus)
		[18223]	= List(2), -- Curse of Exhaustion
		[18093]	= List(2), -- Pyroclasm
		[710]	= List(2), -- Banish (Rank 1)
		[18647]	= List(2), -- Banish (Rank 2)
		[6789]	= List(3), -- Death Coil (Rank 1)
		[17925]	= List(3), -- Death Coil (Rank 2)
		[17926]	= List(3), -- Death Coil (Rank 3)
		[5484]	= List(3), -- Howl of Terror (Rank 1)
		[17928]	= List(3), -- Howl of Terror (Rank 2)
		[24259]	= List(2), -- Spell Lock (Felhunter)
		[18118]	= List(2), -- Aftermath
		[20812]	= List(2), -- Cripple (Doomguard)
		[1098]	= List(5), -- Enslave Demon (Rank 1)
		[11725]	= List(5), -- Enslave Demon (Rank 2)
		[11726]	= List(5), -- Enslave Demon (Rank 3)
	--Warrior
		[20511]	= List(4), -- Intimidating Shout (Cower)
		[5246]	= List(4), -- Intimidating Shout (Fear)
		[1715]	= List(2), -- Hamstring (Rank 1)
		[7372]	= List(2), -- Hamstring (Rank 2)
		[7373]	= List(2), -- Hamstring (Rank 3)
		[12809]	= List(2), -- Concussion Blow
		[20253]	= List(2), -- Intercept Stun (Rank 1)
		[20614]	= List(2), -- Intercept Stun (Rank 2)
		[20615]	= List(2), -- Intercept Stun (Rank 3)
		[7922]	= List(2), -- Charge Stun
		[12798]	= List(2), -- Revenge Stun
		[18498]	= List(2), -- Shield Bash - Silenced
		[23694]	= List(2), -- Improved Hamstring
		[676]	= List(2), -- Disarm
		[12323]	= List(2), -- Piercing Howl
	--Mace Specialization
		[5530]	= List(2), -- Mace Stun Effect
	--Racial
		[20549]	= List(2), -- War Stomp
	--Sunder Armor, Faerie Fire, Faerie Fire (Feral)
		[7386]	= List(6), -- Sunder Armor (Rank 1)
		[7405]	= List(6), -- Sunder Armor (Rank 2)
		[8380]	= List(6), -- Sunder Armor (Rank 3)
		[11596]	= List(6), -- Sunder Armor (Rank 4)
		[11597]	= List(6), -- Sunder Armor (Rank 5)
		[770]	= List(5), -- Faerie Fire (Rank 1)
		[778]	= List(5), -- Faerie Fire (Rank 2)
		[9749]	= List(5), -- Faerie Fire (Rank 3)
		[9907]	= List(5), -- Faerie Fire (Rank 4)
		[16857]	= List(5), -- Faerie Fire (Feral) (Rank 1)
		[17390]	= List(5), -- Faerie Fire (Feral) (Rank 2)
		[17391]	= List(5), -- Faerie Fire (Feral) (Rank 3)
		[17392]	= List(5), -- Faerie Fire (Feral) (Rank 4)
	--Winter's Chill Debuff
		[12579]	= List(5), -- Winter's Chill
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Druid
		[22812]	= List(2), -- Barkskin
	-- Hunter
		[19263]	= List(2), -- Deterrence
	--Mage
		[11958]	= List(2), -- Ice Block
	--Paladin
		[498]	= List(2), -- Divine Protection (Rank 1)
		[5573]	= List(2), -- Divine Protection (Rank 2)
		[642]	= List(2), -- Divine Shield (Rank 1)
		[1020]	= List(2), -- Divine Shield (Rank 2)
		[1022]	= List(2), -- Blessing of Protection (Rank 1)
		[5599]	= List(2), -- Blessing of Protection (Rank 2)
		[10278]	= List(2), -- Blessing of Protection (Rank 3)
	-- Rogue
		[5277]	= List(2), -- Evasion
		[1856]	= List(2), -- Vanish (Rank 1)
		[1857]	= List(2), -- Vanish (Rank 2)
	-- Warrior
		[12975]	= List(2), -- Last Stand
		[871]	= List(2), -- Shield Wall
		[20230]	= List(2), -- Retaliation
	--Consumables
		[3169]	= List(2), -- Limited Invulnerability Potion
		[6615]	= List(2), -- Free Action Potion
	--Racial
		[7744]	= List(2), -- Will of the Forsaken
		[6346]	= List(2), -- Fear Ward
		[20594]	= List(2), -- Stoneform
	--All Classes
		[19753]	= List(2), -- Divine Intervention
	},
}

--Default whitelist for player buffs, still WIP
G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
		[29166]	= List(), -- Innervate
		[22812]	= List(), -- Barkskin
		[17116]	= List(), -- Nature's Swiftness
		[16689]	= List(), -- Nature's Grasp (Rank 1)
		[16810]	= List(), -- Nature's Grasp (Rank 2)
		[16811]	= List(), -- Nature's Grasp (Rank 3)
		[16812]	= List(), -- Nature's Grasp (Rank 4)
		[16813]	= List(), -- Nature's Grasp (Rank 5)
		[17329]	= List(), -- Nature's Grasp (Rank 6)
		[16864]	= List(), -- Omen of Clarity
		[5217]	= List(), -- Tiger's Fury (Rank 1)
		[6793]	= List(), -- Tiger's Fury (Rank 2)
		[9845]	= List(), -- Tiger's Fury (Rank 3)
		[9846]	= List(), -- Tiger's Fury (Rank 4)
		[2893]	= List(), -- Abolish Poison
		[5229]	= List(), -- Enrage
		[1850]	= List(), -- Dash (Rank 1)
		[9821]	= List(), -- Dash (Rank 2)
		[33357]	= List(), -- Dash (Rank 3)
	--Hunter
		[13161]	= List(), -- Aspect of the Beast
		[5118]	= List(), -- Aspect of the Cheetah
		[13163]	= List(), -- Aspect of the Monkey
		[13159]	= List(), -- Aspect of the Pack
		[20043]	= List(), -- Aspect of the Wild (Rank 1)
		[20190]	= List(), -- Aspect of the Wild (Rank 2)
		[3045]	= List(), -- Rapid Fire
		[19263]	= List(), -- Deterrence
		[13165]	= List(), -- Aspect of the Hawk (Rank 1)
		[14318]	= List(), -- Aspect of the Hawk (Rank 2)
		[14319]	= List(), -- Aspect of the Hawk (Rank 3)
		[14320]	= List(), -- Aspect of the Hawk (Rank 4)
		[14321]	= List(), -- Aspect of the Hawk (Rank 5)
		[14322]	= List(), -- Aspect of the Hawk (Rank 6)
		[25296]	= List(), -- Aspect of the Hawk (Rank 7)
		[19574]	= List(), -- Bestial Wrath
	--Mage
		[11958]	= List(), -- Ice Block
		[12043]	= List(), -- Presence of Mind
		[28682]	= List(), -- Combustion
		[12042]	= List(), -- Arcane Power
		[11426]	= List(), -- Ice Barrier (Rank 1)
		[13031]	= List(), -- Ice Barrier (Rank 2)
		[13032]	= List(), -- Ice Barrier (Rank 3)
		[13033]	= List(), -- Ice Barrier (Rank 4)
	--Paladin
		[1044]	= List(), -- Blessing of Freedom
		[465]	= List(), -- Devotion Aura (Rank 1)
		[10290]	= List(), -- Devotion Aura (Rank 2)
		[643]	= List(), -- Devotion Aura (Rank 3)
		[10291]	= List(), -- Devotion Aura (Rank 4)
		[1032]	= List(), -- Devotion Aura (Rank 5)
		[10292]	= List(), -- Devotion Aura (Rank 6)
		[10293]	= List(), -- Devotion Aura (Rank 7)
		[19746]	= List(), -- Concentration Aura
		[7294]	= List(), -- Retribution Aura (Rank 1)
		[10298]	= List(), -- Retribution Aura (Rank 2)
		[10299]	= List(), -- Retribution Aura (Rank 3)
		[10300]	= List(), -- Retribution Aura (Rank 4)
		[10301]	= List(), -- Retribution Aura (Rank 5)
		[19876]	= List(), -- Shadow Resistance Aura (Rank 1)
		[19895]	= List(), -- Shadow Resistance Aura (Rank 2)
		[19896]	= List(), -- Shadow Resistance Aura (Rank 3)
		[19888]	= List(), -- Frost Resistance Aura (Rank 1)
		[19897]	= List(), -- Frost Resistance Aura (Rank 2)
		[19898]	= List(), -- Frost Resistance Aura (Rank 3)
		[19891]	= List(), -- Fire Resistance Aura (Rank 1)
		[19899]	= List(), -- Fire Resistance Aura (Rank 2)
		[19900]	= List(), -- Fire Resistance Aura (Rank 3)
		[498]	= List(), -- Divine Protection (Rank 1)
		[5573]	= List(), -- Divine Protection (Rank 2)
		[642]	= List(), -- Divine Shield (Rank 1)
		[1020]	= List(), -- Divine Shield (Rank 2)
		[1022]	= List(), -- Blessing of Protection (Rank 1)
		[5599]	= List(), -- Blessing of Protection (Rank 2)
		[10278]	= List(), -- Blessing of Protection (Rank 3)
		[6940]	= List(), -- Blessing of Sacrifice (Rank 1)
		[20729]	= List(), -- Blessing of Sacrifice (Rank 2)
		[20216]	= List(), -- Divine Favor
	--Priest
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
	--Rogue
		[14177]	= List(), -- Cold Blood
		[13877]	= List(), -- Blade Flurry
		[13750]	= List(), -- Adrenaline Rush
		[2983]	= List(), -- Sprint (Rank 1)
		[8696]	= List(), -- Sprint (Rank 2)
		[11305]	= List(), -- Sprint (Rank 3)
		[5171]	= List(), -- Slice and Dice (Rank 1)
		[6774]	= List(), -- Slice and Dice (Rank 2)
		[5277]	= List(), -- Evasion
		[1856]	= List(), -- Vanish (Rank 1)
		[1857]	= List(), -- Vanish (Rank 2)
	--Shaman
		[2645]	= List(), -- Ghost Wolf
		[324]	= List(), -- Lightning Shield (Rank 1)
		[325]	= List(), -- Lightning Shield (Rank 2)
		[905]	= List(), -- Lightning Shield (Rank 3)
		[945]	= List(), -- Lightning Shield (Rank 4)
		[8134]	= List(), -- Lightning Shield (Rank 5)
		[10431]	= List(), -- Lightning Shield (Rank 6)
		[10432]	= List(), -- Lightning Shield (Rank 7)
		[16188]	= List(), -- Nature's Swiftness
		[16166]	= List(), -- Elemental Mastery
		[8178]	= List(), -- Grounding Totem Effect
		[16191]	= List(), -- Mana Tide (Rank 1)
		[17355]	= List(), -- Mana Tide (Rank 2)
		[17360]	= List(), -- Mana Tide (Rank 3)
	--Warlock
		[18789]	= List(), -- Demonic Sacrifice (Burning Wish)
		[18790]	= List(), -- Demonic Sacrifice (Fel Stamina)
		[18791]	= List(), -- Demonic Sacrifice (Touch of Shadow)
		[18792]	= List(), -- Demonic Sacrifice (Fel Energy)
		[5697]	= List(), -- Unending Breath
		[6512]	= List(), -- Detect Lesser Invisibility
		[2970]	= List(), -- Detect Invisibility
		[11743]	= List(), -- Detect Greater Invisibility
		[25228]	= List(), -- Soul Link
		[18708]	= List(), -- Fel Domination
	--Warrior
		[12975]	= List(), -- Last Stand
		[871]	= List(), -- Shield Wall
		[20230]	= List(), -- Retaliation
		[1719]	= List(), -- Recklessness
		[18499]	= List(), -- Berserker Rage
		[2687]	= List(), -- Bloodrage
		[12328]	= List(), -- Death Wish
		[12292]	= List(), -- Sweeping Strikes
		[2565]	= List(), -- Shield Block
		[12880]	= List(), -- Enrage (Rank 1)
		[14201]	= List(), -- Enrage (Rank 2)
		[14202]	= List(), -- Enrage (Rank 3)
		[14203]	= List(), -- Enrage (Rank 4)
		[14204]	= List(), -- Enrage (Rank 5)
	-- Consumables
		[3169]	= List(), -- Limited Invulnerability Potion
		[6615]	= List(), -- Free Action Potion
	-- Racial
		[20554]	= List(), -- Berserking (Mana)
		[26296]	= List(), -- Berserking (Rage)
		[26297]	= List(), -- Berserking (Energy)
		[7744]	= List(), -- Will of the Forsaken
		[20572]	= List(), -- Blood Fury (Physical)
		[33697]	= List(), -- Blood Fury (Both)
		[33702]	= List(), -- Blood Fury (Spell)
		[6346]	= List(), -- Fear Ward
		[20594]	= List(), -- Stoneform
	-- All Classes
		[19753]	= List(), -- Divine Intervention
	},
}

-- Buffs that we don't really need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
	--Seasonal
		[362859] = List(), -- Adventure Awaits "Quest experience increased by 100%."
	--Druid
	--Hunter
	--Mage
	--Paladin
	--Priest
	--Rogue
	--Shaman
	--Warlock
	--Warrior
	--Racial
	},
}

--[[
	This should be a list of important buffs that we always want to see when they are active
	bloodlust, paladin hand spells, raid cooldowns, etc..
]]
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
	--Druid
	--Hunter
	--Mage
	--Paladin
	--Priest
	--Rogue
	--Shaman
	--Warlock
	--Warrior
	--Racial
	},
}

-- RAID DEBUFFS: This should be pretty self explainitory
G.unitframe.aurafilters.RaidDebuffs = {
	type = 'Whitelist',
	spells = {
	----------------------------------------------------------
	------------------------ Dungeons ------------------------
	----------------------------------------------------------
	--Multiple Dungeons
		[744]	= List(2), -- Poison
		[18267] = List(2), -- Curse of Weakness
		[20800] = List(2), -- Immolate
		[246]	= List(2), -- Slow
		[6533]	= List(2), -- Net
		[8399]	= List(2), -- Sleep
	-- Blackrock Depths
		[13704] = List(2), -- Psychic Scream
	-- Deadmines
		[6304]	= List(2), -- Rhahk'Zor Slam
		[12097] = List(2), -- Pierce Armor
		[7399]	= List(2), -- Terrify
		[6713]	= List(2), -- Disarm
		[5213]	= List(2), -- Molten Metal
		[5208]	= List(2), -- Poisoned Harpoon
	-- Maraudon
		[7964]	= List(2), -- Smoke Bomb
		[21869] = List(2), -- Repulsive Gaze
	-- Razorfen Downs
		[12255]	= List(2), -- Curse of Tuten'kash
		[12252]	= List(2), -- Web Spray
		[7645]	= List(2), -- Dominate Mind
		[12946]	= List(2), -- Putrid Stench
	-- Razorfen Kraul
		[14515]	= List(2), -- Dominate Mind
	-- Scarlet Monastry
		[9034]	= List(2), -- Immolate
		[8814]	= List(2), -- Flame Spike
		[8988]	= List(2), -- Silence
		[9256]	= List(2), -- Deep Sleep
		[8282]	= List(2), -- Curse of Blood
	-- Shadowfang Keep
		[7068]	= List(2), -- Veil of Shadow
		[7125]	= List(2), -- Toxic Saliva
		[7621]	= List(2), -- Arugal's Curse
	--Stratholme
		[16798] = List(2), -- Enchanting Lullaby
		[12734] = List(2), -- Ground Smash
		[17293] = List(2), -- Burning Winds
		[17405] = List(2), -- Domination
		[16867] = List(2), -- Banshee Curse
		[6016]	= List(2), -- Pierce Armor
		[16869] = List(2), -- Ice Tomb
		[17307] = List(2), -- Knockout
	-- Sunken Temple
		[12889] = List(2), -- Curse of Tongues
		[12888] = List(2), -- Cause Insanity
		[12479] = List(2), -- Hex of Jammal'an
		[12493] = List(2), -- Curse of Weakness
		[12890] = List(2), -- Deep Slumber
		[24375] = List(2), -- War Stomp
	-- Uldaman
		[3356]	= List(2), -- Flame Lash
		[6524]	= List(2), -- Ground Tremor
	-- Wailing Caverns
		[8040]	= List(2), -- Druid's Slumber
		[8142]	= List(2), -- Grasping Vines
		[7967]	= List(2), -- Naralex's Nightmare
		[8150]	= List(2), -- Thundercrack
	-- Zul'Farrak
		[11836] = List(2), -- Freeze Solid
	-- World Bosses
		[21056] = List(2), -- Mark of Kazzak
		[24814] = List(2), -- Seeping Fog
	----------------------------------------------------------
	-------------------------- PvP ---------------------------
	----------------------------------------------------------
	[43680] = List(6), -- Idle (Reported for AFK)
	----------------------------------------------------------
	----------------------------------------------------------
	--------------------- Onyxia's Lair ----------------------
	----------------------------------------------------------
	[18431] = List(2), -- Bellowing Roar
	----------------------------------------------------------
	---------------------- Molten Core -----------------------
	----------------------------------------------------------
	[19703] = List(5), -- Lucifron's Curse
	[19408] = List(2), -- Panic
	[19716] = List(3), -- Gehennas' Curse
	[20475] = List(6), -- Living Bomb
	[19695] = List(3), -- Inferno
	[19713] = List(5), -- Shazzrah's Curse
	[20277] = List(2), -- Fist of Ragnaros
	[19659] = List(2), -- Ignite Mana
	[19714] = List(2), -- Deaden Magic
	----------------------------------------------------------
	--------------------- Blackwing Lair ---------------------
	----------------------------------------------------------
	[23023]	= List(2), -- Conflagration
	[18173]	= List(2), -- Burning Adrenaline
	[24573]	= List(2), -- Mortal Strike
	[23340]	= List(2), -- Shadow of Ebonroc
	[23170]	= List(2), -- Brood Affliction: Bronze
	[22687]	= List(2), -- Veil of Shadow
	----------------------------------------------------------
	------------------------ Zul'Gurub -----------------------
	----------------------------------------------------------
	[23860]	= List(2), -- Holy Fire
	[22884]	= List(2), -- Psychic Scream
	[23918]	= List(2), -- Sonic Burst
	[24111]	= List(2), -- Corrosive Poison
	[21060]	= List(2), -- Blind
	[24328]	= List(2), -- Corrupted Blood
	[16856]	= List(2), -- Mortal Strike
	[24664]	= List(2), -- Sleep
	[17172]	= List(2), -- Hex
	[24306]	= List(2), -- Delusions of Jin'do
	[24099]	= List(2), -- Poison Bolt Volley
	----------------------------------------------------------
	--------------------- Ahn'Qiraj Ruins --------------------
	----------------------------------------------------------
	[25646]	= List(2), -- Mortal Wound
	[25471]	= List(2), -- Attack Order
	[96]	= List(2), -- Dismember
	[25725]	= List(2), -- Paralyze
	[25189]	= List(2), -- Enveloping Winds
	----------------------------------------------------------
	--------------------- Ahn'Qiraj Temple -------------------
	----------------------------------------------------------
	[785]	= List(2), -- True Fulfillment
	[26580]	= List(2), -- Fear
	[26050]	= List(2), -- Acid Spit
	[26180]	= List(2), -- Wyvern Sting
	[26053]	= List(2), -- Noxious Poison
	[26613]	= List(2), -- Unbalancing Strike
	[26029]	= List(2), -- Dark Glare
	----------------------------------------------------------
	------------------------ Naxxramas -----------------------
	----------------------------------------------------------
	[28732]	= List(2), -- Widow's Embrace
	[28622]	= List(2), -- Web Wrap
	[28169]	= List(2), -- Mutating Injection
	[29213]	= List(2), -- Curse of the Plaguebringer
	[28835]	= List(2), -- Mark of Zeliek
	[27808]	= List(2), -- Frost Blast
	[28410]	= List(2), -- Chains of Kel'Thuzad
	[27819]	= List(2), -- Detonate Mana
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
	---------------------- Molten Core -----------------------
	----------------------------------------------------------
	[19451] = List(), -- Frenzy
	[19714] = List(), -- Deaden Magic
	[19516] = List(), -- Enrage
	[19695] = List(), -- Inferno
	[20478] = List(), -- Armageddon
	[19779] = List(), -- Inspire
	[20620] = List(), -- Aegis of Ragnaros
	[21075] = List(), -- Damage Shield
	[20619] = List(), -- Magic Reflection
	----------------------------------------------------------
	------------------------ Zul'Gurub -----------------------
	----------------------------------------------------------
	[23895] = List(), -- Renew
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {},
	DRUID = {
		[1126]	= Aura(1126, {5232,6756,5234,8907,9884,9885}, 'TOPLEFT', {0.2, 0.8, 0.8}, true), -- Mark of the Wild
		[21849]	= Aura(21849, {21850}, 'TOPLEFT', {0.2, 0.8, 0.8}, true), -- Gift of the Wild
		[467]	= Aura(467, {782,1075,8914,9756,9910}, 'TOPRIGHT', {0.4, 0.2, 0.8}, true), -- Thorns
		[774]	= Aura(774, {1058,1430,2090,2091,3627,8910,9839,9840,9841,25299}, 'BOTTOMLEFT', {0.83, 1.00, 0.25}), -- Rejuvenation
		[8936]	= Aura(8936, {8938,8939,8940,8941,9750,9856,9857,9858}, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Regrowth
		[29166]	= Aura(29166, nil, 'CENTER', {0.49, 0.60, 0.55}, true), -- Innervate
	},
	HUNTER = {
		[19506]	= Aura(19506, {20905,20906}, 'TOPLEFT', {0.89, 0.09, 0.05}), -- Trueshot Aura
		[13159]	= Aura(13159, nil, 'BOTTOMLEFT', {0.00, 0.00, 0.85}), -- Aspect of the Pack
		[20043]	= Aura(20043, {20190}, 'BOTTOMLEFT', {0.33, 0.93, 0.79}), -- Aspect of the Wild
	},
	MAGE = {
		[1459]	= Aura(1459, {1460,1461,10156,10157}, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Arcane Intellect
		[23028]	= Aura(23028, {27127}, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Arcane Brilliance
		[604]	= Aura(604, {8450,8451,10173,10174}, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Dampen Magic
		[1008]	= Aura(1008, {8455,10169,10170}, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Amplify Magic
		[130]	= Aura(130, nil, 'CENTER', {0.00, 0.00, 0.50}, true), -- Slow Fall
	},
	PALADIN = {
		[1044]	= Aura(1044, nil, 'CENTER', {0.89, 0.45, 0}), -- Blessing of Freedom
		[6940]	= Aura(6940, {20729}, 'CENTER', {0.89, 0.1, 0.1}), -- Blessing of Sacrifice
		[19740]	= Aura(19740, {19834,19835,19836,19837,19838,25291}, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Blessing of Might
		[19742]	= Aura(19742, {19850,19852,19853,19854,25290}, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Blessing of Wisdom
		[25782]	= Aura(25782, {25916}, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Greater Blessing of Might
		[25894]	= Aura(25894, {25918}, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- Greater Blessing of Wisdom
		[465]	= Aura(465, {10290,643,10291,1032,10292,10293}, 'BOTTOMLEFT', {0.58, 1.00, 0.50}), -- Devotion Aura
		[19977]	= Aura(19977, {19978,19979}, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true), -- Blessing of Light
		[1022]	= Aura(1022, {5599,10278}, 'TOPRIGHT', {0.17, 1.00, 0.75}, true), -- Blessing of Protection
		[19746]	= Aura(19746, nil, 'BOTTOMLEFT', {0.83, 1.00, 0.07}), -- Concentration Aura
	},
	PRIEST = {
		[1243]	= Aura(1243, {1244,1245,2791,10937,10938}, 'TOPLEFT', {1, 1, 0.66}, true), -- Power Word: Fortitude
		[21562]	= Aura(21562, {21564}, 'TOPLEFT', {1, 1, 0.66}, true), -- Prayer of Fortitude
		[14752]	= Aura(14752, {14818,14819,27841}, 'TOPRIGHT', {0.2, 0.7, 0.2}, true), -- Divine Spirit
		[27681]	= Aura(27681, nil, 'TOPRIGHT', {0.2, 0.7, 0.2}, true), -- Prayer of Spirit
		[976]	= Aura(976, {10957,10958}, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true), -- Shadow Protection
		[27683]	= Aura(27683, nil, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true), -- Prayer of Shadow Protection
		[17]	= Aura(17, {592,600,3747,6065,6066,10898,10899,10900,10901}, 'BOTTOM', {0.00, 0.00, 1.00}), -- Power Word: Shield
		[139]	= Aura(139, {6074,6075,6076,6077,6078,10927,10928,10929,25315}, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Renew
	},
	ROGUE = {}, -- No buffs
	SHAMAN = {
		[29203]	= Aura(29203, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Healing Way
		[16237]	= Aura(16237, nil, 'RIGHT', {0.2, 0.2, 1}), -- Ancestral Fortitude
		[25909]	= Aura(25909, nil, 'TOP', {0.00, 0.00, 0.50}), -- Tranquil Air
		[8185]	= Aura(8185, {10534,10535}, 'TOPLEFT', {0.05, 1.00, 0.50}), -- Fire Resistance Totem
		[8182]	= Aura(8182, {10476,10477}, 'TOPLEFT', {0.54, 0.53, 0.79}), -- Frost Resistance Totem
		[10596]	= Aura(10596, {10598,10599}, 'TOPLEFT', {0.33, 1.00, 0.20}), -- Nature Resistance Totem
		[5672]	= Aura(5672, {6371,6372,10460,10461}, 'BOTTOM', {0.67, 1.00, 0.50}), -- Healing Stream Totem
		[16191]	= Aura(16191, {17355,17360}, 'BOTTOMLEFT', {0.67, 1.00, 0.80}), -- Mana Tide Totem
		[5677]	= Aura(5677, {10491,10493,10494}, 'LEFT', {0.67, 1.00, 0.80}), -- Mana Spring Totem
		[8072]	= Aura(8072, {8156,8157,10403,10404,10405}, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}), -- Stoneskin Totem
	},
	WARLOCK = {
		[5697]	= Aura(5697, nil, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Unending Breath
		[6512]	= Aura(6512, nil, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Detect Lesser Invisibility
		[2970]	= Aura(2970, nil, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Detect Invisibility
		[11743]	= Aura(11743, nil, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Detect Greater Invisibility
	},
	WARRIOR = {
		[6673]	= Aura(6673, {5242,6192,11549,11550,11551,25289}, 'TOPLEFT', {0.2, 0.2, 1}, true), -- Battle Shout
	},
	PET = {
	--Warlock Imp
		[6307]	= Aura(6307, {7804,7805,11766,11767}, 'BOTTOMLEFT', {0.89, 0.09, 0.05}), -- Blood Pact
	--Warlock Felhunter
		[19480]	= Aura(19480, nil, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Paranoia
	--Hunter Pets
		[24604]	= Aura(24604, {24605,24603,24597}, 'TOPRIGHT', {0.08, 0.59, 0.41}), -- Furious Howl
	},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	--Druid
	[740]	= 5, -- Tranquility (Rank 1)
	[8918]	= 5, -- Tranquility (Rank 2)
	[9862]	= 5, -- Tranquility (Rank 3)
	[9863]	= 5, -- Tranquility (Rank 4)
	[16914]	= 10, -- Hurricane (Rank 1)
	[17401]	= 10, -- Hurricane (Rank 2)
	[17402]	= 10, -- Hurricane (Rank 3)
	--Hunter
	[1510]	= 6, -- Volley (Rank 1)
	[14294]	= 6, -- Volley (Rank 2)
	[14295]	= 6, -- Volley (Rank 3)
	[136]	= 5, -- Mend Pet (Rank 1)
	[3111]	= 5, -- Mend Pet (Rank 2)
	[3661]	= 5, -- Mend Pet (Rank 3)
	[3662]	= 5, -- Mend Pet (Rank 4)
	[13542]	= 5, -- Mend Pet (Rank 5)
	[13543]	= 5, -- Mend Pet (Rank 6)
	[13544]	= 5, -- Mend Pet (Rank 7)
	-- Mage
	[10]	= 8, -- Blizzard (Rank 1)
	[6141]	= 8, -- Blizzard (Rank 2)
	[8427]	= 8, -- Blizzard (Rank 3)
	[10185]	= 8, -- Blizzard (Rank 4)
	[10186]	= 8, -- Blizzard (Rank 5)
	[10187]	= 8, -- Blizzard (Rank 6)
	[5143]	= 3, -- Arcane Missiles (Rank 1)
	[5144]	= 4, -- Arcane Missiles (Rank 2)
	[5145]	= 5, -- Arcane Missiles (Rank 3)
	[8416]	= 5, -- Arcane Missiles (Rank 4)
	[8417]	= 5, -- Arcane Missiles (Rank 5)
	[10211]	= 5, -- Arcane Missiles (Rank 6)
	[10212]	= 5, -- Arcane Missiles (Rank 7)
	[12051]	= 4, -- Evocation
	-- Priest
	[15407]	= 3, -- Mind Flay (Rank 1)
	[17311]	= 3, -- Mind Flay (Rank 2)
	[17312]	= 3, -- Mind Flay (Rank 3)
	[17313]	= 3, -- Mind Flay (Rank 4)
	[17314]	= 3, -- Mind Flay (Rank 5)
	[18807]	= 3, -- Mind Flay (Rank 6)
	-- Warlock
	[1120]	= 5, -- Drain Soul (Rank 1)
	[8288]	= 5, -- Drain Soul (Rank 2)
	[8289]	= 5, -- Drain Soul (Rank 3)
	[11675]	= 5, -- Drain Soul (Rank 4)
	[755]	= 10, -- Health Funnel (Rank 1)
	[3698]	= 10, -- Health Funnel (Rank 2)
	[3699]	= 10, -- Health Funnel (Rank 3)
	[3700]	= 10, -- Health Funnel (Rank 4)
	[11693]	= 10, -- Health Funnel (Rank 5)
	[11694]	= 10, -- Health Funnel (Rank 6)
	[11695]	= 10, -- Health Funnel (Rank 7)
	[689]	= 5, -- Drain Life (Rank 1)
	[699]	= 5, -- Drain Life (Rank 2)
	[709]	= 5, -- Drain Life (Rank 3)
	[7651]	= 5, -- Drain Life (Rank 4)
	[11699]	= 5, -- Drain Life (Rank 5)
	[11700]	= 5, -- Drain Life (Rank 6)
	[5740]	= 4, -- Rain of Fire (Rank 1)
	[6219]	= 4, -- Rain of Fire (Rank 2)
	[11677]	= 4, -- Rain of Fire (Rank 3)
	[11678]	= 4, -- Rain of Fire (Rank 4)
	[1949]	= 15, -- Hellfire (Rank 1)
	[11683]	= 15, -- Hellfire (Rank 2)
	[11684]	= 15, -- Hellfire (Rank 3)
	[5138]	= 5, -- Drain Mana (Rank 1)
	[6226]	= 5, -- Drain Mana (Rank 2)
	[11703]	= 5, -- Drain Mana (Rank 3)
	[11704]	= 5, -- Drain Mana (Rank 4)
	--First Aid
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
}

G.unitframe.ChannelTicksSize = {}

-- Spells Effected By Haste
G.unitframe.HastedChannelTicks = {}

G.unitframe.TalentChannelTicks = {}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {}

G.unitframe.AuraHighlightColors = {
	[25771]	= {enable = false, style = 'FILL', color = {r = 0.85, g = 0, b = 0, a = 0.85}},
}
