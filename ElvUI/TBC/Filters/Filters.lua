local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local unpack = unpack

local function Defaults(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0
	}
end

G.unitframe.aurafilters = {}

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Druid
		[339]	= Defaults(1), -- Entangling Roots (Rank 1)
		[1062]	= Defaults(1), -- Entangling Roots (Rank 2)
		[5195]	= Defaults(1), -- Entangling Roots (Rank 3)
		[5196]	= Defaults(1), -- Entangling Roots (Rank 4)
		[9852]	= Defaults(1), -- Entangling Roots (Rank 5)
		[9853]	= Defaults(1), -- Entangling Roots (Rank 6)
		[26989]	= Defaults(1), -- Entangling Roots (Rank 7)
		[2637]	= Defaults(1), -- Hibernate (Rank 1)
		[18657]	= Defaults(1), -- Hibernate (Rank 2)
		[18658]	= Defaults(1), -- Hibernate (Rank 3)
		[19675]	= Defaults(2), -- Feral Charge Effect
		[5211]	= Defaults(4), -- Bash (Rank 1)
		[6798]	= Defaults(4), -- Bash (Rank 2)
		[8983]	= Defaults(4), -- Bash (Rank 3)
		[16922]	= Defaults(2), -- Starfire Stun
		[9005]	= Defaults(2), -- Pounce (Rank 1)
		[9823]	= Defaults(2), -- Pounce (Rank 2)
		[9827]	= Defaults(2), -- Pounce (Rank 3)
		[27006]	= Defaults(2), -- Pounce (Rank 4)
		[770]	= Defaults(5), -- Faerie Fire (Rank 1)
		[778]	= Defaults(5), -- Faerie Fire (Rank 2)
		[9749]	= Defaults(5), -- Faerie Fire (Rank 3)
		[9907]	= Defaults(5), -- Faerie Fire (Rank 4)
		[16857]	= Defaults(5), -- Faerie Fire (Feral) (Rank 1)
		[17390]	= Defaults(5), -- Faerie Fire (Feral) (Rank 2)
		[17391]	= Defaults(5), -- Faerie Fire (Feral) (Rank 3)
		[17392]	= Defaults(5), -- Faerie Fire (Feral) (Rank 4)
	-- Hunter
		[1499]	= Defaults(3), -- Freezing Trap (Rank 1)
		[14310]	= Defaults(3), -- Freezing Trap (Rank 2)
		[14311]	= Defaults(3), -- Freezing Trap (Rank 3)
		[14308]	= Defaults(3), -- Freezing Trap Effect (Rank 2)
		[14309]	= Defaults(3), -- Freezing Trap Effect (Rank 3)
		[13809]	= Defaults(1), -- Frost Trap
		[19503]	= Defaults(4), -- Scatter Shot
		[5116]	= Defaults(2), -- Concussive Shot
		[297]	= Defaults(2), -- Wing Clip (Rank 1)
		[14267]	= Defaults(2), -- Wing Clip (Rank 2)
		[14268]	= Defaults(2), -- Wing Clip (Rank 3)
		[1513]	= Defaults(2), -- Scare Beast (Rank 1)
		[14326]	= Defaults(2), -- Scare Beast (Rank 2)
		[14327]	= Defaults(2), -- Scare Beast (Rank 3)
		[24394]	= Defaults(2), -- Intimidation
		[19386]	= Defaults(2), -- Wyvern Sting (Rank 1)
		[24132]	= Defaults(2), -- Wyvern Sting (Rank 2)
		[24133]	= Defaults(2), -- Wyvern Sting (Rank 3)
		[19229]	= Defaults(2), -- Improved Wing Clip
		[19306]	= Defaults(2), -- Counterattack (Rank 1)
		[20909]	= Defaults(2), -- Counterattack (Rank 2)
		[20910]	= Defaults(2), -- Counterattack (Rank 3)
	-- Mage
		[118]	= Defaults(3), -- Polymorph (Rank 1)
		[12824]	= Defaults(3), -- Polymorph (Rank 2)
		[12825]	= Defaults(3), -- Polymorph (Rank 3)
		[12826]	= Defaults(3), -- Polymorph (Rank 4)
		[122]	= Defaults(1), -- Frost Nova (Rank 1)
		[865]	= Defaults(1), -- Frost Nova (Rank 2)
		[6131]	= Defaults(1), -- Frost Nova (Rank 3)
		[10230]	= Defaults(1), -- Frost Nova (Rank 4)
		[27088]	= Defaults(1), -- Frost Nova (Rank 5)
		[12494]	= Defaults(2), -- Frostbite
		[116]	= Defaults(2), -- Frostbolt (Rank 1)
		[205]	= Defaults(2), -- Frostbolt (Rank 2)
		[837]	= Defaults(2), -- Frostbolt (Rank 3)
		[7322]	= Defaults(2), -- Frostbolt (Rank 4)
		[8406]	= Defaults(2), -- Frostbolt (Rank 5)
		[8407]	= Defaults(2), -- Frostbolt (Rank 6)
		[8408]	= Defaults(2), -- Frostbolt (Rank 7)
		[10179]	= Defaults(2), -- Frostbolt (Rank 8)
		[10180]	= Defaults(2), -- Frostbolt (Rank 9)
		[10181]	= Defaults(2), -- Frostbolt (Rank 10)
		[25304]	= Defaults(2), -- Frostbolt (Rank 11)
		[27071]	= Defaults(2), -- Frostbolt (Rank 12)
		[27072]	= Defaults(2), -- Frostbolt (Rank 13)
		[12355]	= Defaults(2), -- Impact
	-- Paladin
		[853]	= Defaults(3), -- Hammer of Justice (Rank 1)
		[5588]	= Defaults(3), -- Hammer of Justice (Rank 2)
		[5589]	= Defaults(3), -- Hammer of Justice (Rank 3)
		[10308]	= Defaults(3), -- Hammer of Justice (Rank 4)
		[20066]	= Defaults(3), -- Repentance
	-- Priest
		[8122]	= Defaults(3), -- Psychic Scream (Rank 1)
		[8124]	= Defaults(3), -- Psychic Scream (Rank 2)
		[10888]	= Defaults(3), -- Psychic Scream (Rank 3)
		[10890]	= Defaults(3), -- Psychic Scream (Rank 4)
		[605]	= Defaults(5), -- Mind Control (Rank 1)
		[10911]	= Defaults(5), -- Mind Control (Rank 2)
		[10912]	= Defaults(5), -- Mind Control (Rank 3)
		[15269]	= Defaults(2), -- Blackout
		[15407]	= Defaults(2), -- Mind Flay (Rank 1)
		[17311]	= Defaults(2), -- Mind Flay (Rank 2)
		[17312]	= Defaults(2), -- Mind Flay (Rank 3)
		[17313]	= Defaults(2), -- Mind Flay (Rank 4)
		[17314]	= Defaults(2), -- Mind Flay (Rank 5)
		[18807]	= Defaults(2), -- Mind Flay (Rank 6)
		[25387]	= Defaults(2), -- Mind Flay (Rank 7)
	-- Rogue
		[6770]	= Defaults(4), -- Sap (Rank 1)
		[2070]	= Defaults(4), -- Sap (Rank 2)
		[11297]	= Defaults(4), -- Sap (Rank 3)
		[2094]	= Defaults(5), -- Blind
		[408]	= Defaults(4), -- Kidney Shot (Rank 1)
		[8643]	= Defaults(4), -- Kidney Shot (Rank 2)
		[1833]	= Defaults(2), -- Cheap Shot
		[1776]	= Defaults(2), -- Gouge (Rank 1)
		[1777]	= Defaults(2), -- Gouge (Rank 2)
		[8629]	= Defaults(2), -- Gouge (Rank 3)
		[11285]	= Defaults(2), -- Gouge (Rank 4)
		[11286]	= Defaults(2), -- Gouge (Rank 5)
		[38764]	= Defaults(2), -- Gouge (Rank 6)
		[5530]	= Defaults(2), -- Mace Stun Effect
	-- Shaman
		[2484]	= Defaults(1), -- Earthbind Totem
		[8056]	= Defaults(2), -- Frost Shock (Rank 1)
		[8058]	= Defaults(2), -- Frost Shock (Rank 2)
		[10472]	= Defaults(2), -- Frost Shock (Rank 3)
		[10473]	= Defaults(2), -- Frost Shock (Rank 4)
		[25464]	= Defaults(2), -- Frost Shock (Rank 5)
	-- Warlock
		[5782]	= Defaults(3), -- Fear (Rank 1)
		[6213]	= Defaults(3), -- Fear (Rank 2)
		[6215]	= Defaults(3), -- Fear (Rank 3)
		[6358]	= Defaults(3), -- Seduction (Succub)
		[18223]	= Defaults(2), -- Curse of Exhaustion
		[18093]	= Defaults(2), -- Pyroclasm
		[710]	= Defaults(2), -- Banish (Rank 1)
		[18647]	= Defaults(2), -- Banish (Rank 2)
		[30413]	= Defaults(2), -- Shadowfury
	-- Warrior
		[5246]	= Defaults(4), -- Intimidating Shout
		[1715]	= Defaults(2), -- Hamstring (Rank 1)
		[7372]	= Defaults(2), -- Hamstring (Rank 2)
		[7373]	= Defaults(2), -- Hamstring (Rank 3)
		[25212]	= Defaults(2), -- Hamstring (Rank 4)
		[12809]	= Defaults(2), -- Concussion Blow
		[20252]	= Defaults(2), -- Intercept (Rank 1)
		[20616]	= Defaults(2), -- Intercept (Rank 2)
		[20617]	= Defaults(2), -- Intercept (Rank 3)
		[25272]	= Defaults(2), -- Intercept (Rank 4)
		[25275]	= Defaults(2), -- Intercept (Rank 5)
		[7386]	= Defaults(6), -- Sunder Armor (Rank 1)
		[7405]	= Defaults(6), -- Sunder Armor (Rank 2)
		[8380]	= Defaults(6), -- Sunder Armor (Rank 3)
		[11596]	= Defaults(6), -- Sunder Armor (Rank 4)
		[11597]	= Defaults(6), -- Sunder Armor (Rank 5)
	-- Racial
		[20549]	= Defaults(2), -- War Stomp
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Mage
		[11958]	= Defaults(2), -- Ice Block A
		[27619]	= Defaults(2), -- Ice Block B
		[45438]	= Defaults(2), -- Ice Block C
	-- Paladin
		[498]	= Defaults(2), -- Divine Protection (Rank 1)
		[5573]	= Defaults(2), -- Divine Protection (Rank 2)
		[642]	= Defaults(2), -- Divine Shield (Rank 1)
		[1020]	= Defaults(2), -- Divine Shield (Rank 2)
		[1022]	= Defaults(2), -- Blessing of Protection (Rank 1)
		[5599]	= Defaults(2), -- Blessing of Protection (Rank 2)
		[10278]	= Defaults(2), -- Blessing of Protection (Rank 3)
	-- Warrior
		[20230]	= Defaults(2), -- Retaliation
	-- Consumables
		[3169]	= Defaults(2), -- Limited Invulnerability Potion
		[6615]	= Defaults(2), -- Free Action Potion
	-- Racial
		[7744]	= Defaults(2), -- Will of the Forsaken
		[6346]	= Defaults(2), -- Fear Ward
		[20594]	= Defaults(2), -- Stoneform
	-- All Classes
		[19753]	= Defaults(2), -- Divine Intervention
	},
}

G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	-- Druid
		[29166]	= Defaults(), -- Innervate
		[22812]	= Defaults(), -- Barkskin
		[17116]	= Defaults(), -- Nature's Swiftness
		[16689]	= Defaults(), -- Nature's Grasp (Rank 1)
		[16810]	= Defaults(), -- Nature's Grasp (Rank 2)
		[16811]	= Defaults(), -- Nature's Grasp (Rank 3)
		[16812]	= Defaults(), -- Nature's Grasp (Rank 4)
		[16813]	= Defaults(), -- Nature's Grasp (Rank 5)
		[17329]	= Defaults(), -- Nature's Grasp (Rank 6)
		[27009]	= Defaults(), -- Nature's Grasp (Rank 7)
		[16864]	= Defaults(), -- Omen of Clarity
		[5217]	= Defaults(), -- Tiger's Fury (Rank 1)
		[6793]	= Defaults(), -- Tiger's Fury (Rank 2)
		[9845]	= Defaults(), -- Tiger's Fury (Rank 3)
		[9846]	= Defaults(), -- Tiger's Fury (Rank 4)
		[2893]	= Defaults(), -- Abolish Poison
		[5229]	= Defaults(), -- Enrage
		[1850]	= Defaults(), -- Dash (Rank 1)
		[9821]	= Defaults(), -- Dash (Rank 2)
		[23110]	= Defaults(), -- Dash (Rank 3)
	-- Hunter
		[13161]	= Defaults(), -- Aspect of the Beast
		[5118]	= Defaults(), -- Aspect of the Cheetah
		[13163]	= Defaults(), -- Aspect of the Monkey
		[13159]	= Defaults(), -- Aspect of the Pack
		[20043]	= Defaults(), -- Aspect of the Wild (Rank 1)
		[20190]	= Defaults(), -- Aspect of the Wild (Rank 2)
		[27045]	= Defaults(), -- Aspect of the Wild (Rank 3)
		[3045]	= Defaults(), -- Rapid Fire
		[19263]	= Defaults(), -- Deterrence
		[13165]	= Defaults(), -- Aspect of the Hawk (Rank 1)
		[14318]	= Defaults(), -- Aspect of the Hawk (Rank 2)
		[14319]	= Defaults(), -- Aspect of the Hawk (Rank 3)
		[14320]	= Defaults(), -- Aspect of the Hawk (Rank 4)
		[14321]	= Defaults(), -- Aspect of the Hawk (Rank 5)
		[14322]	= Defaults(), -- Aspect of the Hawk (Rank 6)
		[25296]	= Defaults(), -- Aspect of the Hawk (Rank 7)
		[27044]	= Defaults(), -- Aspect of the Hawk (Rank 8)
	-- Mage
		[11958]	= Defaults(), -- Ice Block A
		[27619]	= Defaults(), -- Ice Block B
		[12043]	= Defaults(), -- Presence of Mind
		[11129]	= Defaults(), -- Combustion
		[12042]	= Defaults(), -- Arcane Power
		[11426]	= Defaults(), -- Ice Barrier (Rank 1)
		[13031]	= Defaults(), -- Ice Barrier (Rank 2)
		[13032]	= Defaults(), -- Ice Barrier (Rank 3)
		[13033]	= Defaults(), -- Ice Barrier (Rank 4)
		[27134]	= Defaults(), -- Ice Barrier (Rank 5)
		[33405]	= Defaults(), -- Ice Barrier (Rank 6)
	-- Paladin
		[1044]	= Defaults(), -- Blessing of Freedom
		[1038]	= Defaults(), -- Blessing of Salvation
		[465]	= Defaults(), -- Devotion Aura (Rank 1)
		[10290]	= Defaults(), -- Devotion Aura (Rank 2)
		[643]	= Defaults(), -- Devotion Aura (Rank 3)
		[10291]	= Defaults(), -- Devotion Aura (Rank 4)
		[1032]	= Defaults(), -- Devotion Aura (Rank 5)
		[10292]	= Defaults(), -- Devotion Aura (Rank 6)
		[10293]	= Defaults(), -- Devotion Aura (Rank 7)
		[27149]	= Defaults(), -- Devotion Aura (Rank 8)
		[19746]	= Defaults(), -- Concentration Aura
		[7294]	= Defaults(), -- Retribution Aura (Rank 1)
		[10298]	= Defaults(), -- Retribution Aura (Rank 2)
		[10299]	= Defaults(), -- Retribution Aura (Rank 3)
		[10300]	= Defaults(), -- Retribution Aura (Rank 4)
		[10301]	= Defaults(), -- Retribution Aura (Rank 5)
		[27150]	= Defaults(), -- Retribution Aura (Rank 6)
		[19876]	= Defaults(), -- Shadow Resistance Aura (Rank 1)
		[19895]	= Defaults(), -- Shadow Resistance Aura (Rank 2)
		[19896]	= Defaults(), -- Shadow Resistance Aura (Rank 3)
		[27151]	= Defaults(), -- Shadow Resistance Aura (Rank 4)
		[19888]	= Defaults(), -- Frost Resistance Aura (Rank 1)
		[19897]	= Defaults(), -- Frost Resistance Aura (Rank 2)
		[19898]	= Defaults(), -- Frost Resistance Aura (Rank 3)
		[27152]	= Defaults(), -- Frost Resistance Aura (Rank 4)
		[19891]	= Defaults(), -- Fire Resistance Aura (Rank 1)
		[19899]	= Defaults(), -- Fire Resistance Aura (Rank 2)
		[19900]	= Defaults(), -- Fire Resistance Aura (Rank 3)
		[27153]	= Defaults(), -- Fire Resistance Aura (Rank 4)
	-- Priest
		[15473]	= Defaults(), -- Shadowform
		[10060]	= Defaults(), -- Power Infusion
		[14751]	= Defaults(), -- Inner Focus
		[1706]	= Defaults(), -- Levitate
		[586]	= Defaults(), -- Fade (Rank 1)
		[9578]	= Defaults(), -- Fade (Rank 2)
		[9579]	= Defaults(), -- Fade (Rank 3)
		[9592]	= Defaults(), -- Fade (Rank 4)
		[10941]	= Defaults(), -- Fade (Rank 5)
		[10942]	= Defaults(), -- Fade (Rank 6)
		[25429]	= Defaults(), -- Fade (Rank 7)
	-- Rogue
		[14177]	= Defaults(), -- Cold Blood
		[13877]	= Defaults(), -- Blade Flurry
		[13750]	= Defaults(), -- Adrenaline Rush
		[2983]	= Defaults(), -- Sprint (Rank 1)
		[8696]	= Defaults(), -- Sprint (Rank 2)
		[11305]	= Defaults(), -- Sprint (Rank 3)
		[5171]	= Defaults(), -- Slice and Dice (Rank 1)
		[6774]	= Defaults(), -- Slice and Dice (Rank 2)
	-- Shaman
		[2645]	= Defaults(), -- Ghost Wolf
		[324]	= Defaults(), -- Lightning Shield (Rank 1)
		[325]	= Defaults(), -- Lightning Shield (Rank 2)
		[905]	= Defaults(), -- Lightning Shield (Rank 3)
		[945]	= Defaults(), -- Lightning Shield (Rank 4)
		[8134]	= Defaults(), -- Lightning Shield (Rank 5)
		[10431]	= Defaults(), -- Lightning Shield (Rank 6)
		[10432]	= Defaults(), -- Lightning Shield (Rank 7)
		[25469]	= Defaults(), -- Lightning Shield (Rank 8)
		[25472]	= Defaults(), -- Lightning Shield (Rank 9)
		[16188]	= Defaults(), -- Nature's Swiftness
		[16166]	= Defaults(), -- Elemental Mastery
		[24398]	= Defaults(), -- Water Shield (Rank 1)
		[33736]	= Defaults(), -- Water Shield (Rank 2)
	-- Warlock
		[18788]	= Defaults(), -- Demonic Sacrifice
		[5697]	= Defaults(), -- Unending Breath
		[19028]	= Defaults(), -- Soul Link A
		[25228]	= Defaults(), -- Soul Link B
	-- Warrior
		[12975]	= Defaults(), -- Last Stand
		[871]	= Defaults(), -- Shield Wall
		[20230]	= Defaults(), -- Retaliation
		[1719]	= Defaults(), -- Recklessness
		[18499]	= Defaults(), -- Berserker Rage
		[2687]	= Defaults(), -- Bloodrage
		[12328]	= Defaults(), -- Death Wish
		[2565]	= Defaults(), -- Shield Block
		[12880]	= Defaults(), -- Enrage (Rank 1)
		[14201]	= Defaults(), -- Enrage (Rank 2)
		[14202]	= Defaults(), -- Enrage (Rank 3)
		[14203]	= Defaults(), -- Enrage (Rank 4)
		[14204]	= Defaults(), -- Enrage (Rank 5)
	-- Racial
		[20554]	= Defaults(), -- Berserking
		[7744]	= Defaults(), -- Will of the Forsaken
		[20572]	= Defaults(), -- Blood Fury
		[6346]	= Defaults(), -- Fear Ward
		[20594]	= Defaults(), -- Stoneform
	},
}

-- Buffs that really we dont need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
	-- General
		[186403] = Defaults(), -- Sign of Battle
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
		[29833]	= Defaults(2), -- Intangible Presence
		[29711]	= Defaults(2), -- Knockdown
		-- Moroes
		[29425]	= Defaults(2), -- Gouge
		[34694]	= Defaults(2), -- Blind
		[37066]	= Defaults(2), -- Garrote
		-- Opera Hall Event
		[30822]	= Defaults(2), -- Poisoned Thrust
		[30889]	= Defaults(2), -- Powerful Attraction
		[30890]	= Defaults(2), -- Blinding Passion
		-- Maiden of Virtue
		[29511]	= Defaults(2), -- Repentance
		[29522]	= Defaults(2), -- Holy Fire
		[29512]	= Defaults(2), -- Holy Ground
		-- The Curator
		-- Terestian Illhoof
		[30053]	= Defaults(2), -- Amplify Flames
		[30115]	= Defaults(2), -- Sacrifice
		-- Shade of Aran
		[29946]	= Defaults(2), -- Flame Wreath
		[29947]	= Defaults(2), -- Flame Wreath
		[29990]	= Defaults(2), -- Slow
		[29991]	= Defaults(2), -- Chains of Ice
		[29954]	= Defaults(2), -- Frostbolt
		[29951]	= Defaults(2), -- Blizzard
		-- Netherspite
		[38637]	= Defaults(2), -- Nether Exhaustion (Red)
		[38638]	= Defaults(2), -- Nether Exhaustion (Green)
		[38639]	= Defaults(2), -- Nether Exhaustion (Blue)
		[30400]	= Defaults(2), -- Nether Beam - Perseverence
		[30401]	= Defaults(2), -- Nether Beam - Serenity
		[30402]	= Defaults(2), -- Nether Beam - Dominance
		[30421]	= Defaults(2), -- Nether Portal - Perseverence
		[30422]	= Defaults(2), -- Nether Portal - Serenity
		[30423]	= Defaults(2), -- Nether Portal - Dominance
		-- Chess Event
		[30529]	= Defaults(2), -- Recently In Game
		-- Prince Malchezaar
		[39095]	= Defaults(2), -- Amplify Damage
		[30898]	= Defaults(2), -- Shadow Word: Pain 1
		[30854]	= Defaults(2), -- Shadow Word: Pain 2
		-- Nightbane
		[37091]	= Defaults(2), -- Rain of Bones
		[30210]	= Defaults(2), -- Smoldering Breath
		[30129]	= Defaults(2), -- Charred Earth
		[30127]	= Defaults(2), -- Searing Cinders
		[36922]	= Defaults(2), -- Bellowing Roar
	-- Gruul's Lair
		-- High King Maulgar
		[36032]	= Defaults(2), -- Arcane Blast
		[11726]	= Defaults(2), -- Enslave Demon
		[33129]	= Defaults(2), -- Dark Decay
		[33175]	= Defaults(2), -- Arcane Shock
		[33061]	= Defaults(2), -- Blast Wave
		[33130]	= Defaults(2), -- Death Coil
		[16508]	= Defaults(2), -- Intimidating Roar
		-- Gruul the Dragonkiller
		[38927]	= Defaults(2), -- Fel Ache
		[36240]	= Defaults(2), -- Cave In
		[33652]	= Defaults(2), -- Stoned
		[33525]	= Defaults(2), -- Ground Slam
	-- Magtheridon's Lair
		-- Magtheridon
		[44032]	= Defaults(2), -- Mind Exhaustion
		[30530]	= Defaults(2), -- Fear
	-------------------------------------------------
	-------------------- Phase 2 --------------------
	-------------------------------------------------
	-- Serpentshrine Cavern
		-- Trash
		[38634] = Defaults(3), -- Arcane Lightning
		[39032] = Defaults(4), -- Initial Infection
		[38572] = Defaults(3), -- Mortal Cleave
		[38635] = Defaults(3), -- Rain of Fire
		[39042] = Defaults(5), -- Rampent Infection
		[39044] = Defaults(4), -- Serpentshrine Parasite
		[38591] = Defaults(4), -- Shatter Armor
		[38491] = Defaults(3), -- Silence
		-- Hydross the Unstable
		[38246] = Defaults(3), -- Vile Sludge
		[38235] = Defaults(4), -- Water Tomb
		-- Leotheras the Blind
		[37675] = Defaults(3), -- Chaos Blast
		[37749] = Defaults(5), -- Consuming Madness
		[37676] = Defaults(4), -- Insidious Whisper
		[37641] = Defaults(3), -- Whirlwind
		-- Fathom-Lord Karathress
		[39261] = Defaults(3), -- Gusting Winds
		[29436] = Defaults(4), -- Leeching Throw
		-- Morogrim Tidewalker
		[38049] = Defaults(4), -- Watery Grave
		[37850] = Defaults(4), -- Watery Grave
		-- Lady Vashj
		[38280] = Defaults(5), -- Static Charge
		[38316] = Defaults(3), -- Entangle
	-- The Eye
		-- Trash
		[37133] = Defaults(4), -- Arcane Buffet
		[37132] = Defaults(3), -- Arcane Shock
		[37122] = Defaults(5), -- Domination
		[37135] = Defaults(5), -- Domination
		[37120] = Defaults(4), -- Fragmentation Bomb
		[13005] = Defaults(3), -- Hammer of Justice
		[39077] = Defaults(3), -- Hammer of Justice
		[37279] = Defaults(3), -- Rain of Fire
		[37123] = Defaults(4), -- Saw Blade
		[37118] = Defaults(5), -- Shell Shock
		[37160] = Defaults(3), -- Silence
		-- Al'ar
		[35410] = Defaults(4), -- Melt Armor
		-- High Astromancer Solarian
		[34322] = Defaults(4), -- Psychic Scream
		[42783] = Defaults(5), -- Wrath of the Astromancer (Patch 2.2.0)
		-- Kael'thas Sunstrider
		[36965] = Defaults(4), -- Rend
		[30225] = Defaults(4), -- Silence
		[44863] = Defaults(5), -- Bellowing Roar
		[37018] = Defaults(4), -- Conflagration
		[37027] = Defaults(5), -- Remote Toy
		[36991] = Defaults(4), -- Rend
		[36797] = Defaults(5), -- Mind Control
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- The Battle for Mount Hyjal
		-- Rage Winterchill
		[31249] = Defaults(6), -- Icebolt
		[31250] = Defaults(5), -- Frost Nova
		-- Anetheron
		[31302] = Defaults(4), -- Inferno
		[31298] = Defaults(5), -- Sleep
		[31306] = Defaults(6), -- Carrion Swarm
		-- Kaz'rogal
		[31447] = Defaults(3), -- Mark of Kaz'rogal
		-- Azgalor
		[31341] = Defaults(5), -- Unquenchable Flames
		[31340] = Defaults(4), -- Rain of Fire
		[31347] = Defaults(6), -- Doom
		-- Archimonde
		[31972] = Defaults(6), -- Grip of the Legion
		[31970] = Defaults(3), -- Fear
		[31944] = Defaults(5), -- Doomfire
		-- Trash
		[31610] = Defaults(3), -- Knockdown
		[28991] = Defaults(2), -- Web
	-- Black Temple
		-- High Warlord Naj'entus
		[39837] = Defaults(2), -- Impaling Spine
		-- Supremus
		[40253] = Defaults(2), -- Molten Flame
		-- Shade of Akama
		[42023] = Defaults(2), -- Rain of Fire
		-- Teron Gorefiend
		[40243] = Defaults(5), -- Crushing Shadows
		[40239] = Defaults(6), -- Incinerate
		[40251] = Defaults(4), -- Shadow of Death
		-- Gurtogg Bloodboil
		[40481] = Defaults(6), -- Acidic Wound
		[40599] = Defaults(5), -- Arcing Smash
		[40491] = Defaults(6), -- Bewildering Strike
		[42005] = Defaults(4), -- Bloodboil
		[40508] = Defaults(5), -- Fel Acid Breath
		[40604] = Defaults(6), -- Fel Rage
		-- Reliquary of Souls
		[41303] = Defaults(3), -- Soul Drain
		[41410] = Defaults(3), -- Deaden
		[41426] = Defaults(2), -- Spirit Shack
		[41294] = Defaults(2), -- Fixate
		[41376] = Defaults(3), -- Spite
		-- Mother Shahraz
		[41001] = Defaults(6), -- Fatal Attraction
		[40860] = Defaults(5), -- Vile Beam
		[40823] = Defaults(4), -- Interrupting Shriek
		-- Illidari Council
		[41541] = Defaults(2), -- Consecration
		[41468] = Defaults(3), -- Hammer of Justice
		[41461] = Defaults(6), -- Judgement of Blood
		[41485] = Defaults(6), -- Deadly Poison
		[41472] = Defaults(6), -- Divine Wrath
		[41482] = Defaults(2), -- Blizzard
		[41481] = Defaults(3), -- Flamestrike
		-- Illidan Stormrage
		[40932] = Defaults(6), -- Agonizing Flame
		[41032] = Defaults(6), -- Shear
		[40585] = Defaults(5), -- Dark Barrage
		[41914] = Defaults(4), -- Parasitic Shadowfiend
		[41142] = Defaults(2), -- Aura of Dread
		-- Trash
		[41213] = Defaults(3), -- Throw Shield
		[40864] = Defaults(3), -- Throbbing Stun
		[41197] = Defaults(3), -- Shield Bash
		[41171] = Defaults(3), -- Skeleton Shot
		[41338] = Defaults(3), -- Love Tap
		[13444] = Defaults(2), -- Sunder Armor
		[41396] = Defaults(2), -- Sleep
		[41334] = Defaults(2), -- Polymorph
		[24698] = Defaults(2), -- Gauge
		[41150] = Defaults(2), -- Fear
		[34654] = Defaults(2), -- Blind
		[39674] = Defaults(2), -- Banish
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Zul'Aman
		-- Nalorakk
		[42398] = Defaults(2), -- Mangle
		-- Jan'alai
		[43299] = Defaults(2), -- Flame Buffet
		-- Akil'zon
		[43657] = Defaults(3), -- Electrical Storm
		[43622] = Defaults(2), -- Static Disruption
		-- Halazzi
		[43303] = Defaults(2), -- Flame Shock
		-- Hexxlord Jin'Zakk
		[43613] = Defaults(3), -- Cold Stare
		[43501] = Defaults(2), -- Siphon Soul
		-- Zul'jin
		[43150] = Defaults(3), -- Rage
		[43095] = Defaults(2), -- Paralyze
		[43093] = Defaults(3), -- Throw
	-------------------------------------------------
	-------------------- Phase 5 --------------------
	-------------------------------------------------
	-- Sunwell Plateau
		-- Kalecgos
		[45018] = Defaults(2), -- Arcane Buffet
		[45032] = Defaults(2), -- Boundless Agony
		-- Brutallus
		[46394] = Defaults(5), -- Burn
		[45150] = Defaults(3), -- Meteor Slash
		[45185] = Defaults(6), -- Stomp
		-- Felmyst
		[45855] = Defaults(3), -- Gas Nova
		[45662] = Defaults(6), -- Encapsulate
		[45402] = Defaults(2), -- Demonic Vapor
		[45717] = Defaults(5), -- Fog of Corruption
		-- Eredar Twins
		[45256] = Defaults(3), -- Confounding Blow
		[45270] = Defaults(2), -- Shadowfury
		[45333] = Defaults(4), -- Conflagration
		[45347] = Defaults(2), -- Dark Touched
		[45348] = Defaults(2), -- Fire Touched
		[46771] = Defaults(3), -- Flame Sear
		-- M'uru
		[45996] = Defaults(6), -- Darkness
		-- Kil'Jaeden
		[45442] = Defaults(2), -- Soul Flay
		[45641] = Defaults(6), -- Fire Bloom
		[45737] = Defaults(2), -- Flame Dart
		[45885] = Defaults(2), -- Shadow Spike
	},
}

G.unitframe.aurafilters.DungeonDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Hellfire Ramparts
	-- The Blood Furnace
	-- The Shattered Halls
	-- The Slave Pens
	-- The Underbog
	-- The Steamvault
	-- Mana-Tombs
	-- Auchenai Crypts
	-- Sethekk Halls
	-- Shadow Labyrinth
	-- Old Hillsbrad Foothills
	-- The Black Morass
	-- Magisters Terrace
	-- The Arcatraz
	-- The Mechanar
	-- The Botanica
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
		[29448] = Defaults(), -- Vanish
		[37023] = Defaults(), -- Enrage
		-- Opera Hall Event
		[30887] = Defaults(), -- Devotion
		[30841] = Defaults(), -- Daring
		-- Maiden of Virtue
		[32429] = Defaults(), -- Draining Touch
		-- The Curator
		-- Terestian Illhoof
		[29908] = Defaults(), -- Astral Bite
		-- Shade of Aran
		[29920] = Defaults(), -- Phasing Invisibility
		[29921] = Defaults(), -- Phasing Invisibility
		-- Netherspite
		[30522] = Defaults(), -- Nether Burn
		[30487] = Defaults(), -- Nether Portal - Perseverence
		[30491] = Defaults(), -- Nether Portal - Domination
		-- Chess Event
		[37469] = Defaults(), -- Poison Cloud
		-- Prince Malchezaar
		[30859] = Defaults(), -- Hellfire
		-- Nightbane
		[37098] = Defaults(), -- Rain of Bones
	-- Gruul's Lair
		-- High King Maulgar
		[33232] = Defaults(), -- Flurry
		[33238] = Defaults(), -- Whirlwind
		[33054] = Defaults(), -- Spell Shield
		-- Gruul the Dragonkiller
		[36300] = Defaults(), -- Growth
	-- Magtheridon's Lair
		-- Magtheridon
		[30205] = Defaults(), -- Shadow Cage
		[30576] = Defaults(), -- Quake
		[30207] = Defaults(), -- Shadow Grasp
	-------------------------------------------------
	-------------------- Phase 2 --------------------
	-------------------------------------------------
	-- Serpentshrine Cavern
		-- Hydross the Unstable
		[37935] = Defaults(), -- Cleansing Field
		-- The Lurker Below
		-- Leotheras the Blind
		[37640] = Defaults(), -- Whirlwind
		-- Fathom-Lord Karathress
		[38451] = Defaults(), -- Power of Caribdis
		[38452] = Defaults(), -- Power of Tidalvess
		[38455] = Defaults(), -- Power of Sharkkis
		[38516] = Defaults(), -- Cyclone
		[38373] = Defaults(), -- The Beast Within
		-- Morogrim Tidewalker
		-- Lady Vashj
		[38112] = Defaults(), -- Magic Barrier
	-- The Eye
		-- Al'ar
		[35412] = Defaults(), -- Charge
		-- Void Reaver
		[34162] = Defaults(), -- Pounding
		-- High Astromancer Solarian
		-- Kael'thas Sunstrider
		[36981] = Defaults(), -- Whirlwind
		[36815] = Defaults(), -- Shock Barrier
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- The Battle for Mount Hyjal
		-- Rage Winterchill
		[31256] = Defaults(), -- Frost Armor
		-- Anetheron
		-- Kaz'rogal
		-- Azgalor
		-- Archimonde
		[31540] = Defaults(), -- Frenzy
	-- Black Temple
		-- High Warlord Naj'entus
		[40076] = Defaults(), -- Electric Spur
		-- Supremus
		[42055] = Defaults(), -- Volcanic Geyser
		-- Shade of Akama
		[34970] = Defaults(), -- Enrage
		-- Teron Gorefiend
		[41254] = Defaults(), -- Frenzy
		-- Gurtogg Bloodboil
		[40594] = Defaults(), -- Fel Rage
		[40601] = Defaults(), -- Fury
		-- Reliquary of Souls
		[41305] = Defaults(), -- Enrage
		[41431] = Defaults(), -- Rune Shield
		-- Mother Shahraz
		-- Illidari Council
		[41450] = Defaults(), -- Blessing of Protection
		[41451] = Defaults(), -- Blessing of Spell Warding
		[41452] = Defaults(), -- Devotion Aura
		[41453] = Defaults(), -- Chromatic Resistance Aura
		[41475] = Defaults(3), -- Reflective Shield
		-- Illidan Stormrage
		[40836] = Defaults(), -- Flame Crash
		[40610] = Defaults(), -- Blaze
		[40683] = Defaults(), -- Enrage
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Zul'Aman
		-- Nalorakk
		-- Jan'alai
		[44779] = Defaults(), -- Enrage
		-- Akil'zon
		-- Halazzi
		[43290] = Defaults(), -- Lynx Flurry
		-- Hexlord Jin'Zakk
		[43578] = Defaults(), -- Bloodlust
		[43430] = Defaults(), -- Avenging Wrath
		-- Zul'jin
		[17207] = Defaults(), -- Whirlwind
		[43213] = Defaults(), -- Flame Whirl
		[43120] = Defaults(), -- Cyclone
	-------------------------------------------------
	-------------------- Phase 5 --------------------
	-------------------------------------------------
	-- Sunwell Plateau
		-- Kalecgos
		[44806] = Defaults(), -- Crazed Rage
		-- Brutallus
		-- Felmyst
		-- Eredar Twins
		[45366] = Defaults(), -- Empower
		[45230] = Defaults(), -- Pyrogenics
		-- M'uru
		[45934] = Defaults(), -- Dark Fiend
		[46160] = Defaults(), -- Flurry
		[45996] = Defaults(), -- Darkness
		[46102] = Defaults(), -- Spell Fury
		-- Kil'Jaeden
		[46680] = Defaults(), -- Shadow Spike
		[46474] = Defaults(), -- Sacrifice of Aveena
		[46605] = Defaults(), -- Darkness of a Thousand Souls
	},
}

-- AuraWatch: List of personal spells to show on unitframes as icon
function UF:AuraWatch_AddSpell(id, point, color, anyUnit, onlyShowMissing, displayText, textThreshold, xOffset, yOffset)

	local r, g, b = 1, 1, 1
	if color then r, g, b = unpack(color) end

	return {
		id = id,
		enabled = true,
		point = point or 'TOPLEFT',
		color = { r = r, g = g, b = b },
		anyUnit = anyUnit or false,
		onlyShowMissing = onlyShowMissing or false,
		displayText = displayText or false,
		textThreshold = textThreshold or -1,
		xOffset = xOffset or 0,
		yOffset = yOffset or 0,
		style = 'coloredIcon',
		sizeOffset = 0,
	}
end

G.unitframe.aurawatch = {
	GLOBAL = {},
	ROGUE = {}, -- No buffs
	WARRIOR = {
		[6673]	= UF:AuraWatch_AddSpell(6673, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 1)
		[5242]	= UF:AuraWatch_AddSpell(5242, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 2)
		[6192]	= UF:AuraWatch_AddSpell(6192, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 3)
		[11549]	= UF:AuraWatch_AddSpell(11549, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 4)
		[11550]	= UF:AuraWatch_AddSpell(11550, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 5)
		[11551]	= UF:AuraWatch_AddSpell(11551, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 6)
		[25289]	= UF:AuraWatch_AddSpell(25289, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 7)
		[2048]	= UF:AuraWatch_AddSpell(2048, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 8)
		[469]	= UF:AuraWatch_AddSpell(469, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Commanding Shout
	},
	PRIEST = {
		[1243]	= UF:AuraWatch_AddSpell(1243, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 1)
		[1244]	= UF:AuraWatch_AddSpell(1244, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 2)
		[1245]	= UF:AuraWatch_AddSpell(1245, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 3)
		[2791]	= UF:AuraWatch_AddSpell(2791, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 4)
		[10937]	= UF:AuraWatch_AddSpell(10937, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 5)
		[10938]	= UF:AuraWatch_AddSpell(10938, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 6)
		[25389]	= UF:AuraWatch_AddSpell(25389, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 7)
		[21562]	= UF:AuraWatch_AddSpell(21562, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 1)
		[21564]	= UF:AuraWatch_AddSpell(21564, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 2)
		[25392]	= UF:AuraWatch_AddSpell(25392, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 3)
		[14752]	= UF:AuraWatch_AddSpell(14752, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 1)
		[14818]	= UF:AuraWatch_AddSpell(14818, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 2)
		[14819]	= UF:AuraWatch_AddSpell(14819, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 3)
		[27841]	= UF:AuraWatch_AddSpell(27841, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 4)
		[25312]	= UF:AuraWatch_AddSpell(25312, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 5)
		[27681]	= UF:AuraWatch_AddSpell(27681, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 1)
		[32999]	= UF:AuraWatch_AddSpell(32999, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 2)
		[976]	= UF:AuraWatch_AddSpell(976, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),		-- Shadow Protection (Rank 1)
		[10957]	= UF:AuraWatch_AddSpell(10957, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 2)
		[10958]	= UF:AuraWatch_AddSpell(10958, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 3)
		[25433]	= UF:AuraWatch_AddSpell(25433, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 4)
		[27683]	= UF:AuraWatch_AddSpell(27683, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 1)
		[39374]	= UF:AuraWatch_AddSpell(39374, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 2)
		[17]	= UF:AuraWatch_AddSpell(17, 'BOTTOM', {0.00, 0.00, 1.00}),				-- Power Word: Shield (Rank 1)
		[592]	= UF:AuraWatch_AddSpell(592, 'BOTTOM', {0.00, 0.00, 1.00}),				-- Power Word: Shield (Rank 2)
		[600]	= UF:AuraWatch_AddSpell(600, 'BOTTOM', {0.00, 0.00, 1.00}),				-- Power Word: Shield (Rank 3)
		[3747]	= UF:AuraWatch_AddSpell(3747, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 4)
		[6065]	= UF:AuraWatch_AddSpell(6065, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 5)
		[6066]	= UF:AuraWatch_AddSpell(6066, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 6)
		[10898]	= UF:AuraWatch_AddSpell(10898, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 7)
		[10899]	= UF:AuraWatch_AddSpell(10899, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 8)
		[10900]	= UF:AuraWatch_AddSpell(10900, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 9)
		[10901]	= UF:AuraWatch_AddSpell(10901, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 10)
		[25217]	= UF:AuraWatch_AddSpell(25217, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 11)
		[25218]	= UF:AuraWatch_AddSpell(25218, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 12)
		[139]	= UF:AuraWatch_AddSpell(139, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 1)
		[6074]	= UF:AuraWatch_AddSpell(6074, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 2)
		[6075]	= UF:AuraWatch_AddSpell(6075, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 3)
		[6076]	= UF:AuraWatch_AddSpell(6076, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 4)
		[6077]	= UF:AuraWatch_AddSpell(6077, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 5)
		[6078]	= UF:AuraWatch_AddSpell(6078, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 6)
		[10927]	= UF:AuraWatch_AddSpell(10927, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 7)
		[10928]	= UF:AuraWatch_AddSpell(10928, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 8)
		[10929]	= UF:AuraWatch_AddSpell(10929, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 9)
		[25315]	= UF:AuraWatch_AddSpell(25315, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 10)
		[25221]	= UF:AuraWatch_AddSpell(25221, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 11)
		[25222]	= UF:AuraWatch_AddSpell(25222, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 12)
	},
	DRUID = {
		[1126]	= UF:AuraWatch_AddSpell(1126, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 1)
		[5232]	= UF:AuraWatch_AddSpell(5232, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 2)
		[6756]	= UF:AuraWatch_AddSpell(6756, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 3)
		[5234]	= UF:AuraWatch_AddSpell(5234, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 4)
		[8907]	= UF:AuraWatch_AddSpell(8907, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 5)
		[9884]	= UF:AuraWatch_AddSpell(9884, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 6)
		[9885]	= UF:AuraWatch_AddSpell(9885, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 7)
		[26990]	= UF:AuraWatch_AddSpell(26990, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 8)
		[21849]	= UF:AuraWatch_AddSpell(21849, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 1)
		[21850]	= UF:AuraWatch_AddSpell(21850, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 2)
		[26991]	= UF:AuraWatch_AddSpell(26991, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 3)
		[467]	= UF:AuraWatch_AddSpell(467, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 1)
		[782]	= UF:AuraWatch_AddSpell(782, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 2)
		[1075]	= UF:AuraWatch_AddSpell(1075, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 3)
		[8914]	= UF:AuraWatch_AddSpell(8914, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 4)
		[9756]	= UF:AuraWatch_AddSpell(9756, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 5)
		[9910]	= UF:AuraWatch_AddSpell(9910, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 6)
		[26992]	= UF:AuraWatch_AddSpell(26992, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 7)
		[774]	= UF:AuraWatch_AddSpell(774, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),		-- Rejuvenation (Rank 1)
		[1058]	= UF:AuraWatch_AddSpell(1058, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 2)
		[1430]	= UF:AuraWatch_AddSpell(1430, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 3)
		[2090]	= UF:AuraWatch_AddSpell(2090, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 4)
		[2091]	= UF:AuraWatch_AddSpell(2091, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 5)
		[3627]	= UF:AuraWatch_AddSpell(3627, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 6)
		[8910]	= UF:AuraWatch_AddSpell(8910, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 7)
		[9839]	= UF:AuraWatch_AddSpell(9839, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 8)
		[9840]	= UF:AuraWatch_AddSpell(9840, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 9)
		[9841]	= UF:AuraWatch_AddSpell(9841, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 10)
		[25299]	= UF:AuraWatch_AddSpell(25299, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 11)
		[26981]	= UF:AuraWatch_AddSpell(26981, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 12)
		[26982]	= UF:AuraWatch_AddSpell(26982, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 13)
		[8936]	= UF:AuraWatch_AddSpell(8936, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 1)
		[8938]	= UF:AuraWatch_AddSpell(8938, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 2)
		[8939]	= UF:AuraWatch_AddSpell(8939, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 3)
		[8940]	= UF:AuraWatch_AddSpell(8940, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 4)
		[8941]	= UF:AuraWatch_AddSpell(8941, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 5)
		[9750]	= UF:AuraWatch_AddSpell(9750, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 6)
		[9856]	= UF:AuraWatch_AddSpell(9856, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 7)
		[9857]	= UF:AuraWatch_AddSpell(9857, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 8)
		[9858]	= UF:AuraWatch_AddSpell(9858, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 9)
		[26980]	= UF:AuraWatch_AddSpell(26980, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 10)
		[29166]	= UF:AuraWatch_AddSpell(29166, 'CENTER', {0.49, 0.60, 0.55}, true),	-- Innervate
		[33763]	= UF:AuraWatch_AddSpell(33763, 'BOTTOM', {0.33, 0.37, 0.47}),		-- Lifebloom
	},
	PALADIN = {
		[1044]	= UF:AuraWatch_AddSpell(1044, 'CENTER', {0.89, 0.45, 0}),					-- Blessing of Freedom
		[1038]	= UF:AuraWatch_AddSpell(1038, 'TOPLEFT', {0.11, 1.00, 0.45}, true),			-- Blessing of Salvation
		[6940]	= UF:AuraWatch_AddSpell(6940, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 1)
		[20729]	= UF:AuraWatch_AddSpell(20729, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 2)
		[27147]	= UF:AuraWatch_AddSpell(27147, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 3)
		[27148]	= UF:AuraWatch_AddSpell(27148, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 4)
		[19740]	= UF:AuraWatch_AddSpell(19740, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 1)
		[19834]	= UF:AuraWatch_AddSpell(19834, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 2)
		[19835]	= UF:AuraWatch_AddSpell(19835, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 3)
		[19836]	= UF:AuraWatch_AddSpell(19836, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 4)
		[19837]	= UF:AuraWatch_AddSpell(19837, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 5)
		[19838]	= UF:AuraWatch_AddSpell(19838, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 6)
		[25291]	= UF:AuraWatch_AddSpell(25291, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 7)
		[27140]	= UF:AuraWatch_AddSpell(27140, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 8)
		[19742]	= UF:AuraWatch_AddSpell(19742, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 1)
		[19850]	= UF:AuraWatch_AddSpell(19850, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 2)
		[19852]	= UF:AuraWatch_AddSpell(19852, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 3)
		[19853]	= UF:AuraWatch_AddSpell(19853, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 4)
		[19854]	= UF:AuraWatch_AddSpell(19854, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 5)
		[25290]	= UF:AuraWatch_AddSpell(25290, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 6)
		[27142]	= UF:AuraWatch_AddSpell(27142, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 7)
		[25782]	= UF:AuraWatch_AddSpell(25782, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 1)
		[25916]	= UF:AuraWatch_AddSpell(25916, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 2)
		[27141]	= UF:AuraWatch_AddSpell(27141, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 3)
		[25894]	= UF:AuraWatch_AddSpell(25894, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 1)
		[25918]	= UF:AuraWatch_AddSpell(25918, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 2)
		[27143]	= UF:AuraWatch_AddSpell(27143, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 3)
		[465]	= UF:AuraWatch_AddSpell(465, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 1)
		[10290]	= UF:AuraWatch_AddSpell(10290, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 2)
		[643]	= UF:AuraWatch_AddSpell(643, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 3)
		[10291]	= UF:AuraWatch_AddSpell(10291, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 4)
		[1032]	= UF:AuraWatch_AddSpell(1032, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 5)
		[10292]	= UF:AuraWatch_AddSpell(10292, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 6)
		[10293]	= UF:AuraWatch_AddSpell(10293, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 7)
		[27149]	= UF:AuraWatch_AddSpell(27149, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 8)
		[19977]	= UF:AuraWatch_AddSpell(19977, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 1)
		[19978]	= UF:AuraWatch_AddSpell(19978, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 2)
		[19979]	= UF:AuraWatch_AddSpell(19979, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 3)
		[27144]	= UF:AuraWatch_AddSpell(27144, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 4)
		[1022]	= UF:AuraWatch_AddSpell(1022, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 1)
		[5599]	= UF:AuraWatch_AddSpell(5599, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 2)
		[10278]	= UF:AuraWatch_AddSpell(10278, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 3)
		[19746]	= UF:AuraWatch_AddSpell(19746, 'BOTTOMLEFT', {0.83, 1.00, 0.07}),			-- Concentration Aura
		[32223]	= UF:AuraWatch_AddSpell(32223, 'BOTTOMLEFT', {0.83, 1.00, 0.07}),			-- Crusader Aura
	},
	SHAMAN = {
		[29203]	= UF:AuraWatch_AddSpell(29203, 'TOPRIGHT', {0.7, 0.3, 0.7}),		-- Healing Way
		[16237]	= UF:AuraWatch_AddSpell(16237, 'RIGHT', {0.2, 0.2, 1}),				-- Ancestral Fortitude
		[8185]	= UF:AuraWatch_AddSpell(8185, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 1)
		[10534]	= UF:AuraWatch_AddSpell(10534, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 2)
		[10535]	= UF:AuraWatch_AddSpell(10535, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 3)
		[25563]	= UF:AuraWatch_AddSpell(25563, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 4)
		[8182]	= UF:AuraWatch_AddSpell(8182, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 1)
		[10476]	= UF:AuraWatch_AddSpell(10476, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 2)
		[10477]	= UF:AuraWatch_AddSpell(10477, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 3)
		[25560]	= UF:AuraWatch_AddSpell(25560, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 4)
		[10596]	= UF:AuraWatch_AddSpell(10596, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 1)
		[10598]	= UF:AuraWatch_AddSpell(10598, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 2)
		[10599]	= UF:AuraWatch_AddSpell(10599, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 3)
		[25574]	= UF:AuraWatch_AddSpell(25574, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 4)
		[5672]	= UF:AuraWatch_AddSpell(5672, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 1)
		[6371]	= UF:AuraWatch_AddSpell(6371, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 2)
		[6372]	= UF:AuraWatch_AddSpell(6372, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 3)
		[10460]	= UF:AuraWatch_AddSpell(10460, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 4)
		[10461]	= UF:AuraWatch_AddSpell(10461, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 5)
		[25567]	= UF:AuraWatch_AddSpell(25567, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 6)
		[16191]	= UF:AuraWatch_AddSpell(16191, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 1)
		[17355]	= UF:AuraWatch_AddSpell(17355, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 2)
		[17360]	= UF:AuraWatch_AddSpell(17360, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 3)
		[5677]	= UF:AuraWatch_AddSpell(5677, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 1)
		[10491]	= UF:AuraWatch_AddSpell(10491, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 2)
		[10493]	= UF:AuraWatch_AddSpell(10493, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 3)
		[10494]	= UF:AuraWatch_AddSpell(10494, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 4)
		[25570]	= UF:AuraWatch_AddSpell(25570, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 5)
		[8072]	= UF:AuraWatch_AddSpell(8072, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 1)
		[8156]	= UF:AuraWatch_AddSpell(8156, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 2)
		[8157]	= UF:AuraWatch_AddSpell(8157, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 3)
		[10403]	= UF:AuraWatch_AddSpell(10403, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 4)
		[10404]	= UF:AuraWatch_AddSpell(10404, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 5)
		[10405]	= UF:AuraWatch_AddSpell(10405, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 6)
		[25508]	= UF:AuraWatch_AddSpell(25508, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 7)
		[25509]	= UF:AuraWatch_AddSpell(25509, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 8)
		[974]	= UF:AuraWatch_AddSpell(974, 'TOP', {0.08, 0.21, 0.43}, true),		-- Earth Shield (Rank 1)
		[32593]	= UF:AuraWatch_AddSpell(32593, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 2)
		[32594]	= UF:AuraWatch_AddSpell(32594, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 3)
	},
	MAGE = {
		[1459]	= UF:AuraWatch_AddSpell(1459, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 1)
		[1460]	= UF:AuraWatch_AddSpell(1460, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 2)
		[1461]	= UF:AuraWatch_AddSpell(1461, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 3)
		[10156]	= UF:AuraWatch_AddSpell(10156, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 4)
		[10157]	= UF:AuraWatch_AddSpell(10157, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 5)
		[27126]	= UF:AuraWatch_AddSpell(27126, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 6)
		[23028]	= UF:AuraWatch_AddSpell(23028, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 1)
		[27127]	= UF:AuraWatch_AddSpell(27127, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 2)
		[604]	= UF:AuraWatch_AddSpell(604, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 1)
		[8450]	= UF:AuraWatch_AddSpell(8450, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 2)
		[8451]	= UF:AuraWatch_AddSpell(8451, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 3)
		[10173]	= UF:AuraWatch_AddSpell(10173, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 4)
		[10174]	= UF:AuraWatch_AddSpell(10174, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 5)
		[33944]	= UF:AuraWatch_AddSpell(33944, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 6)
		[1008]	= UF:AuraWatch_AddSpell(1008, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 1)
		[8455]	= UF:AuraWatch_AddSpell(8455, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 2)
		[10169]	= UF:AuraWatch_AddSpell(10169, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 3)
		[10170]	= UF:AuraWatch_AddSpell(10170, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 4)
		[27130]	= UF:AuraWatch_AddSpell(27130, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 5)
		[33946]	= UF:AuraWatch_AddSpell(33946, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 6)
		[130]	= UF:AuraWatch_AddSpell(130, 'CENTER', {0.00, 0.00, 0.50}, true),		-- Slow Fall
	},
	HUNTER = {
		[19506]	= UF:AuraWatch_AddSpell(19506, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 1)
		[20905]	= UF:AuraWatch_AddSpell(20905, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 2)
		[20906]	= UF:AuraWatch_AddSpell(20906, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 3)
		[27066]	= UF:AuraWatch_AddSpell(27066, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 4)
		[13159]	= UF:AuraWatch_AddSpell(13159, 'TOP', {0.00, 0.00, 0.85}, true),	-- Aspect of the Pack
		[20043]	= UF:AuraWatch_AddSpell(20043, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 1)
		[20190]	= UF:AuraWatch_AddSpell(20190, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 2)
		[27045]	= UF:AuraWatch_AddSpell(27045, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 3)
	},
	WARLOCK = {
		[5597]	= UF:AuraWatch_AddSpell(5597, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Unending Breath
		[6512]	= UF:AuraWatch_AddSpell(6512, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Lesser Invisibility
		[2970]	= UF:AuraWatch_AddSpell(2970, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Invisibility
		[11743]	= UF:AuraWatch_AddSpell(11743, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Greater Invisibility
	},
	PET = {
	-- Warlock Imp
		[6307]	= UF:AuraWatch_AddSpell(6307, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 1)
		[7804]	= UF:AuraWatch_AddSpell(7804, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 2)
		[7805]	= UF:AuraWatch_AddSpell(7805, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 3)
		[11766]	= UF:AuraWatch_AddSpell(11766, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 4)
		[11767]	= UF:AuraWatch_AddSpell(11767, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 5)
	-- Warlock Felhunter
		[19480]	= UF:AuraWatch_AddSpell(19480, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Paranoia
	-- Hunter Pets
		[24604]	= UF:AuraWatch_AddSpell(24604, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 1)
		[24605]	= UF:AuraWatch_AddSpell(24605, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 2)
		[24603]	= UF:AuraWatch_AddSpell(24603, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 3)
		[24597]	= UF:AuraWatch_AddSpell(24597, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 4)
	},
}

-- Profile specific BuffIndicator
P.unitframe.filters = {
	aurawatch = {},
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
	[47757]	= {tier = 1, column = 1, ticks = 4}, -- Penance (heal)
	[47758]	= {tier = 1, column = 1, ticks = 4}, -- Penance (dps)
}

G.unitframe.ChannelTicksSize = {
	-- Warlock
	[198590]	= 1, -- Drain Soul
}

-- Spells Effected By Haste
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
