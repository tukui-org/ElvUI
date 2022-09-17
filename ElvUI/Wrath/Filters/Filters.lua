local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local List = UF.FilterList_Defaults

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	-- Death Knight
		[55741]	= List(1), -- Desecration
		[47481]	= List(2), -- Gnaw (Ghoul)
		[49203]	= List(3), -- Hungering Cold
		[47476]	= List(2), -- Strangulate
		[53534]	= List(2), -- Chains of Ice
	-- Druid
		[339]	= List(1), -- Entangling Roots (Rank 1)
		[1062]	= List(1), -- Entangling Roots (Rank 2)
		[5195]	= List(1), -- Entangling Roots (Rank 3)
		[5196]	= List(1), -- Entangling Roots (Rank 4)
		[9852]	= List(1), -- Entangling Roots (Rank 5)
		[9853]	= List(1), -- Entangling Roots (Rank 6)
		[26989]	= List(1), -- Entangling Roots (Rank 7)
		[53308]	= List(1), -- Entangling Roots (Rank 8)
		[19975]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 1)
		[19974]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 2)
		[19973]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 3)
		[19972]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 4)
		[19971]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 5)
		[19970]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 6)
		[27010]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 7)
		[53313]	= List(1), -- Entangling Roots (Nature's Grasp) (Rank 8)
		[2637]	= List(1), -- Hibernate (Rank 1)
		[18657]	= List(1), -- Hibernate (Rank 2)
		[18658]	= List(1), -- Hibernate (Rank 3)
		[45334]	= List(2), -- Feral Charge Effect
		[5211]	= List(4), -- Bash (Rank 1)
		[6798]	= List(4), -- Bash (Rank 2)
		[8983]	= List(4), -- Bash (Rank 3)
		[16922]	= List(2), -- Celestial Focus (Starfire Stun)
		[9005]	= List(2), -- Pounce (Rank 1)
		[9823]	= List(2), -- Pounce (Rank 2)
		[9827]	= List(2), -- Pounce (Rank 3)
		[27006]	= List(2), -- Pounce (Rank 4)
		[49803]	= List(2), -- Pounce (Rank 5)
		[770]	= List(5), -- Faerie Fire
		[16857]	= List(5), -- Faerie Fire (Feral)
		[22570] = List(4), -- Maim (Rank 1)
		[49802] = List(4), -- Maim (Rank 2)
		[33786]	= List(5), -- Cyclone
		[50259]	= List(2), -- Dazed (Feral Charge - Cat)
		[61391]	= List(2), -- Typhoon
	-- Hunter
		[60210]	= List(3), -- Freezing Arrow Effect
		[3355]	= List(3), -- Freezing Trap Effect (Rank 1)
		[14308]	= List(3), -- Freezing Trap Effect (Rank 2)
		[14309]	= List(3), -- Freezing Trap Effect (Rank 3)
		[13810]	= List(1), -- Frost Trap Aura
		[19503]	= List(4), -- Scatter Shot
		[5116]	= List(2), -- Concussive Shot
		[2974]	= List(2), -- Wing Clip
		[1513]	= List(2), -- Scare Beast (Rank 1)
		[14326]	= List(2), -- Scare Beast (Rank 2)
		[14327]	= List(2), -- Scare Beast (Rank 3)
		[24394]	= List(2), -- Intimidation
		[19386]	= List(2), -- Wyvern Sting (Rank 1)
		[24132]	= List(2), -- Wyvern Sting (Rank 2)
		[24133]	= List(2), -- Wyvern Sting (Rank 3)
		[27068]	= List(2), -- Wyvern Sting (Rank 4)
		[49011]	= List(2), -- Wyvern Sting (Rank 5)
		[49012]	= List(2), -- Wyvern Sting (Rank 6)
		[19229]	= List(2), -- Improved Wing Clip
		[19306]	= List(2), -- Counterattack (Rank 1)
		[20909]	= List(2), -- Counterattack (Rank 2)
		[20910]	= List(2), -- Counterattack (Rank 3)
		[27067]	= List(2), -- Counterattack (Rank 4)
		[48998]	= List(2), -- Counterattack (Rank 5)
		[48999]	= List(2), -- Counterattack (Rank 6)
		[34490]	= List(2), -- Silencing Shot
		[25999]	= List(2), -- Charge (Boar)
		[19185]	= List(1), -- Entrapment
		[53359]	= List(2), -- Chimera Shot - Scorpid
		[35101]	= List(2), -- Concussive Barrage
		[61394]	= List(2), -- Glyph of Freezing Trap
	-- Mage
		[118]	= List(3), -- Polymorph (Rank 1)
		[12824]	= List(3), -- Polymorph (Rank 2)
		[12825]	= List(3), -- Polymorph (Rank 3)
		[12826]	= List(3), -- Polymorph (Rank 4)
		[28271]	= List(3), -- Polymorph (Turtle)
		[28272]	= List(3), -- Polymorph (Pig)
		[59634]	= List(3), -- Polymorph (Penguin)
		[61305]	= List(3), -- Polymorph (Black Cat)
		[61721]	= List(3), -- Polymorph (Rabbit)
		[61780]	= List(3), -- Polymorph (Turkey)
		[31661]	= List(3), -- Dragon's Breath (Rank 1)
		[33041]	= List(3), -- Dragon's Breath (Rank 2)
		[33042]	= List(3), -- Dragon's Breath (Rank 3)
		[33043]	= List(3), -- Dragon's Breath (Rank 4)
		[42949]	= List(3), -- Dragon's Breath (Rank 5)
		[42950]	= List(3), -- Dragon's Breath (Rank 6)
		[122]	= List(1), -- Frost Nova (Rank 1)
		[865]	= List(1), -- Frost Nova (Rank 2)
		[6131]	= List(1), -- Frost Nova (Rank 3)
		[10230]	= List(1), -- Frost Nova (Rank 4)
		[27088]	= List(1), -- Frost Nova (Rank 5)
		[42917]	= List(1), -- Frost Nova (Rank 6)
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
		[38697]	= List(2), -- Frostbolt (Rank 14)
		[42841]	= List(2), -- Frostbolt (Rank 15)
		[42842]	= List(2), -- Frostbolt (Rank 16)
		[12355]	= List(2), -- Impact
		[18469]	= List(2), -- Silenced - Improved Counterspell
		[33395]	= List(1), -- Freeze (Water Elemental)
		[11113]	= List(2), -- Blast Wave
		[12484]	= List(2), -- Chilled (Blizzard) (Rank 1)
		[12485]	= List(2), -- Chilled (Blizzard) (Rank 2)
		[12486]	= List(2), -- Chilled (Blizzard) (Rank 3)
		[6136]	= List(2), -- Chilled (Frost Armor)
		[7321]	= List(2), -- Chilled (Ice Armor)
		[120]	= List(2), -- Cone of Cold
		[44572]	= List(3), -- Deep Freeze
		[64346]	= List(2), -- Fiery Payback
		[44614]	= List(2), -- Frostfire Bolt (Rank 1)
		[47610]	= List(2), -- Frostfire Bolt (Rank 2)
		[31589]	= List(2), -- Slow
	-- Paladin
		[853]	= List(3), -- Hammer of Justice (Rank 1)
		[5588]	= List(3), -- Hammer of Justice (Rank 2)
		[5589]	= List(3), -- Hammer of Justice (Rank 3)
		[10308]	= List(3), -- Hammer of Justice (Rank 4)
		[20066]	= List(3), -- Repentance
		[20170]	= List(2), -- Stun (Seal of Justice Proc)
		[10326]	= List(3), -- Turn Evil
		[63529]	= List(2), -- Silenced - Shield of the Templar
		[31935]	= List(2), -- Avenger's Shield
	-- Priest
		[8122]	= List(3), -- Psychic Scream (Rank 1)
		[8124]	= List(3), -- Psychic Scream (Rank 2)
		[10888]	= List(3), -- Psychic Scream (Rank 3)
		[10890]	= List(3), -- Psychic Scream (Rank 4)
		[605]	= List(5), -- Mind Control
		[15269]	= List(2), -- Blackout
		[15407]	= List(2), -- Mind Flay (Rank 1)
		[17311]	= List(2), -- Mind Flay (Rank 2)
		[17312]	= List(2), -- Mind Flay (Rank 3)
		[17313]	= List(2), -- Mind Flay (Rank 4)
		[17314]	= List(2), -- Mind Flay (Rank 5)
		[18807]	= List(2), -- Mind Flay (Rank 6)
		[25387]	= List(2), -- Mind Flay (Rank 7)
		[48155]	= List(2), -- Mind Flay (Rank 8)
		[48156]	= List(2), -- Mind Flay (Rank 9)
		[9484]	= List(3), -- Shackle Undead (Rank 1)
		[9485]	= List(3), -- Shackle Undead (Rank 2)
		[10955]	= List(3), -- Shackle Undead (Rank 3)
		[64044]	= List(1), -- Psychic Horror
		[64058]	= List(1), -- Psychic Horror (Disarm)
		[15487]	= List(2), -- Silence
	-- Rogue
		[6770]	= List(4), -- Sap (Rank 1)
		[2070]	= List(4), -- Sap (Rank 2)
		[11297]	= List(4), -- Sap (Rank 3)
		[51724]	= List(4), -- Sap (Rank 4)
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
		[1330]	= List(2), -- Garrote - Silence
		[18425]	= List(2), -- Silenced - Improved Kick
		[51722]	= List(2), -- Dismantle
		[31125]	= List(2), -- Blade Twisting (Rank 1)
		[51585]	= List(2), -- Blade Twisting (Rank 2)
		[3409]	= List(2), -- Crippling Poison
		[26679]	= List(2), -- Deadly Throw
		[32747]	= List(2), -- Interrupt (Deadly Throw)
		[51693]	= List(2), -- Waylay
	-- Shaman
		[2484]	= List(1), -- Earthbind Totem
		[8056]	= List(2), -- Frost Shock (Rank 1)
		[8058]	= List(2), -- Frost Shock (Rank 2)
		[10472]	= List(2), -- Frost Shock (Rank 3)
		[10473]	= List(2), -- Frost Shock (Rank 4)
		[25464]	= List(2), -- Frost Shock (Rank 5)
		[49235]	= List(2), -- Frost Shock (Rank 6)
		[49236]	= List(2), -- Frost Shock (Rank 7)
		[39796]	= List(2), -- Stoneclaw Totem
		[58861]	= List(2), -- Bash (Spirit Wolf)
		[51514]	= List(3), -- Hex
		[8034]	= List(2), -- Frostbrand Attack (Rank 1)
		[8037]	= List(2), -- Frostbrand Attack (Rank 2)
		[10458]	= List(2), -- Frostbrand Attack (Rank 3)
		[16352]	= List(2), -- Frostbrand Attack (Rank 4)
		[16353]	= List(2), -- Frostbrand Attack (Rank 5)
		[25501]	= List(2), -- Frostbrand Attack (Rank 6)
		[58797]	= List(2), -- Frostbrand Attack (Rank 7)
		[58798]	= List(2), -- Frostbrand Attack (Rank 8)
		[58799]	= List(2), -- Frostbrand Attack (Rank 9)
	-- Warlock
		[5782]	= List(3), -- Fear (Rank 1)
		[6213]	= List(3), -- Fear (Rank 2)
		[6215]	= List(3), -- Fear (Rank 3)
		[6358]	= List(3), -- Seduction (Succubus)
		[18223]	= List(2), -- Curse of Exhaustion
		[18093]	= List(2), -- Pyroclasm
		[710]	= List(2), -- Banish (Rank 1)
		[18647]	= List(2), -- Banish (Rank 2)
		[30413]	= List(2), -- Shadowfury
		[6789]	= List(3), -- Death Coil (Rank 1)
		[17925]	= List(3), -- Death Coil (Rank 2)
		[17926]	= List(3), -- Death Coil (Rank 3)
		[27223]	= List(3), -- Death Coil (Rank 4)
		[5484]	= List(3), -- Howl of Terror (Rank 1)
		[17928]	= List(3), -- Howl of Terror (Rank 2)
		[24259]	= List(2), -- Spell Lock (Felhunter)
		[18118]	= List(2), -- Aftermath
		[20812]	= List(2), -- Cripple (Doomguard)
		[60995]	= List(2), -- Demon Charge (Metamorphosis)
		[1098]	= List(5), -- Enslave Demon (Rank 1)
		[11725]	= List(5), -- Enslave Demon (Rank 2)
		[11726]	= List(5), -- Enslave Demon (Rank 3)
		[61191]	= List(5), -- Enslave Demon (Rank 4)
		[63311]	= List(2), -- Glyph of Shadowflame
		[30153]	= List(2), -- Intercept (Felguard)
		[31117]	= List(2), -- Unstable Affliction (Silence)
	-- Warrior
		[20511]	= List(4), -- Intimidating Shout (Cower)
		[5246]	= List(4), -- Intimidating Shout (Fear)
		[1715]	= List(2), -- Hamstring
		[12809]	= List(2), -- Concussion Blow
		[20253]	= List(2), -- Intercept Stun (Rank 1)
		[20614]	= List(2), -- Intercept Stun (Rank 2)
		[20615]	= List(2), -- Intercept Stun (Rank 3)
		[25273]	= List(2), -- Intercept Stun (Rank 4)
		[25274]	= List(2), -- Intercept Stun (Rank 5)
		[7386]	= List(6), -- Sunder Armor
		[7922]	= List(2), -- Charge Stun
		[18498]	= List(2), -- Silenced - Gag Order
		[46968]	= List(3), -- Shockwave
		[23694]	= List(2), -- Improved Hamstring
		[58373]	= List(2), -- Glyph of Hamstring
		[676]	= List(2), -- Disarm
		[12323]	= List(2), -- Piercing Howl
	-- Racial
		[20549]	= List(2), -- War Stomp
		[28730]	= List(2), -- Arcane Torrent (Mana)
		[25046]	= List(2), -- Arcane Torrent (Energy)
		[50613]	= List(2), -- Arcane Torrent (Runic Power)
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Death Knight
		[48707]	= List(2), -- Anti-Magic Shell
		[51052]	= List(2), -- Anti-Magic Zone
		[42650]	= List(2), -- Army of the Dead
		[49222]	= List(2), -- Bone Shield
		[48792]	= List(2), -- Icebound Fortitude
		[49039]	= List(2), -- Lichborne
		[51271]	= List(2), -- Unbreakable Armor
		[55233]	= List(2), -- Vampiric Blood
	-- Druid
		[22812]	= List(2), -- Barkskin
	-- Hunter
		[19263]	= List(2), -- Deterrence
		[34471]	= List(2), -- The Beast Within
	-- Mage
		[45438]	= List(2), -- Ice Block
		[66]	= List(2), -- Invisibility
	-- Paladin
		[498]	= List(2), -- Divine Protection
		[642]	= List(2), -- Divine Shield
		[1022]	= List(2), -- Hand of Protection (Rank 1)
		[5599]	= List(2), -- Hand of Protection (Rank 2)
		[10278]	= List(2), -- Hand of Protection (Rank 3)
		[31821]	= List(2), -- Aura Mastery
		[70940]	= List(2), -- Divine Guardian
		[64205]	= List(2), -- Divine Sacrifice
	-- Priest
		[47585]	= List(2), -- Dispersion
		[47788]	= List(2), -- Guardian Spirit
	-- Rogue
		[31224]	= List(2), -- Cloak of Shadows
		[5277]	= List(2), -- Evasion (Rank 1)
		[26669]	= List(2), -- Evasion (Rank 2)
		[1856]	= List(2), -- Vanish (Rank 1)
		[1857]	= List(2), -- Vanish (Rank 2)
		[26889]	= List(2), -- Vanish (Rank 3)
	-- Shaman
		[974]	= List(2), -- Earth Shield (Rank 1)
		[32593]	= List(2), -- Earth Shield (Rank 2)
		[32594]	= List(2), -- Earth Shield (Rank 3)
		[49283]	= List(2), -- Earth Shield (Rank 4)
		[49284]	= List(2), -- Earth Shield (Rank 5)
		[30823]	= List(2), -- Shamanistic Rage
	-- Warrior
		[12975]	= List(2), -- Last Stand
		[871]	= List(2), -- Shield Wall
		[20230]	= List(2), -- Retaliation
		[2565]	= List(2), -- Shield Block
		[46924]	= List(2), -- Bladestorm
		[23920]	= List(2), -- Spell Reflection
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
	-- Death Knight
		[48707]	= List(), -- Anti-Magic Shell
		[51052]	= List(), -- Anti-Magic Zone
		[49222]	= List(), -- Bone Shield
		[49028]	= List(), -- Dancing Rune Weapon
		[49796]	= List(), -- Deathchill
		[63560]	= List(), -- Ghoul Frenzy (Ghoul)
		[48792]	= List(), -- Icebound Fortitude
		[49039]	= List(), -- Lichborne
		[61777]	= List(), -- Summon Gargoyle
		[51271]	= List(), -- Unbreakable Armor
		[55233]	= List(), -- Vampiric Blood
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
		[53312]	= List(), -- Nature's Grasp (Rank 8)
		[16864]	= List(), -- Omen of Clarity
		[5217]	= List(), -- Tiger's Fury (Rank 1)
		[6793]	= List(), -- Tiger's Fury (Rank 2)
		[9845]	= List(), -- Tiger's Fury (Rank 3)
		[9846]	= List(), -- Tiger's Fury (Rank 4)
		[50212]	= List(), -- Tiger's Fury (Rank 5)
		[50213]	= List(), -- Tiger's Fury (Rank 6)
		[2893]	= List(), -- Abolish Poison
		[5229]	= List(), -- Enrage
		[1850]	= List(), -- Dash (Rank 1)
		[9821]	= List(), -- Dash (Rank 2)
		[33357]	= List(), -- Dash (Rank 3)
		[50334]	= List(), -- Berserk
		[48505]	= List(), -- Starfall (Rank 1)
		[53199]	= List(), -- Starfall (Rank 2)
		[53200]	= List(), -- Starfall (Rank 3)
		[53201]	= List(), -- Starfall (Rank 4)
		[61336]	= List(), -- Survival Instincts
		[740]	= List(), -- Tranquility
	-- Hunter
		[13161]	= List(), -- Aspect of the Beast
		[5118]	= List(), -- Aspect of the Cheetah
		[13163]	= List(), -- Aspect of the Monkey
		[13159]	= List(), -- Aspect of the Pack
		[20043]	= List(), -- Aspect of the Wild (Rank 1)
		[20190]	= List(), -- Aspect of the Wild (Rank 2)
		[27045]	= List(), -- Aspect of the Wild (Rank 3)
		[49071]	= List(), -- Aspect of the Wild (Rank 4)
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
		[19574]	= List(), -- Bestial Wrath
		[35098]	= List(), -- Rapid Killing
		[34471]	= List(), -- The Beast Within
	-- Mage
		[45438]	= List(), -- Ice Block
		[12043]	= List(), -- Presence of Mind
		[28682]	= List(), -- Combustion
		[12042]	= List(), -- Arcane Power
		[11426]	= List(), -- Ice Barrier (Rank 1)
		[13031]	= List(), -- Ice Barrier (Rank 2)
		[13032]	= List(), -- Ice Barrier (Rank 3)
		[13033]	= List(), -- Ice Barrier (Rank 4)
		[27134]	= List(), -- Ice Barrier (Rank 5)
		[33405]	= List(), -- Ice Barrier (Rank 6)
		[43038]	= List(), -- Ice Barrier (Rank 7)
		[43039]	= List(), -- Ice Barrier (Rank 8)
		[12472]	= List(), -- Icy Veins
		[66]	= List(), -- Invisibility
		[55342]	= List(), -- Mirror Image
	-- Paladin
		[1044]	= List(), -- Hand of Freedom
		[1038]	= List(), -- Hand of Salvation
		[465]	= List(), -- Devotion Aura (Rank 1)
		[10290]	= List(), -- Devotion Aura (Rank 2)
		[643]	= List(), -- Devotion Aura (Rank 3)
		[10291]	= List(), -- Devotion Aura (Rank 4)
		[1032]	= List(), -- Devotion Aura (Rank 5)
		[10292]	= List(), -- Devotion Aura (Rank 6)
		[10293]	= List(), -- Devotion Aura (Rank 7)
		[27149]	= List(), -- Devotion Aura (Rank 8)
		[48941]	= List(), -- Devotion Aura (Rank 9)
		[48942]	= List(), -- Devotion Aura (Rank 10)
		[19746]	= List(), -- Concentration Aura
		[7294]	= List(), -- Retribution Aura (Rank 1)
		[10298]	= List(), -- Retribution Aura (Rank 2)
		[10299]	= List(), -- Retribution Aura (Rank 3)
		[10300]	= List(), -- Retribution Aura (Rank 4)
		[10301]	= List(), -- Retribution Aura (Rank 5)
		[27150]	= List(), -- Retribution Aura (Rank 6)
		[54043]	= List(), -- Retribution Aura (Rank 7)
		[19876]	= List(), -- Shadow Resistance Aura (Rank 1)
		[19895]	= List(), -- Shadow Resistance Aura (Rank 2)
		[19896]	= List(), -- Shadow Resistance Aura (Rank 3)
		[27151]	= List(), -- Shadow Resistance Aura (Rank 4)
		[48943]	= List(), -- Shadow Resistance Aura (Rank 5)
		[19888]	= List(), -- Frost Resistance Aura (Rank 1)
		[19897]	= List(), -- Frost Resistance Aura (Rank 2)
		[19898]	= List(), -- Frost Resistance Aura (Rank 3)
		[27152]	= List(), -- Frost Resistance Aura (Rank 4)
		[48945]	= List(), -- Frost Resistance Aura (Rank 5)
		[19891]	= List(), -- Fire Resistance Aura (Rank 1)
		[19899]	= List(), -- Fire Resistance Aura (Rank 2)
		[19900]	= List(), -- Fire Resistance Aura (Rank 3)
		[27153]	= List(), -- Fire Resistance Aura (Rank 4)
		[48497]	= List(), -- Fire Resistance Aura (Rank 5)
		[498]	= List(), -- Divine Protection
		[642]	= List(), -- Divine Shield
		[1022]	= List(), -- Hand of Protection (Rank 1)
		[5599]	= List(), -- Hand of Protection (Rank 2)
		[10278]	= List(), -- Hand of Protection (Rank 3)
		[31821]	= List(), -- Aura Mastery
		[70940]	= List(), -- Divine Guardian
		[64205]	= List(), -- Divine Sacrifice
		[6940]	= List(), -- Hand of Sacrifice
		[31884]	= List(), -- Avenging Wrath
		[20216]	= List(), -- Divine Favor
		[31842]	= List(), -- Divine Illumination
	-- Priest
		[15473]	= List(), -- Shadowform
		[10060]	= List(), -- Power Infusion
		[14751]	= List(), -- Inner Focus
		[1706]	= List(), -- Levitate
		[586]	= List(), -- Fade
		[64843]	= List(), -- Divine Hymn
		[47788]	= List(), -- Guardian Spirit
		[64901]	= List(), -- Hymn of Hope
		[47585]	= List(), -- Dispersion
	-- Rogue
		[14177]	= List(), -- Cold Blood
		[13877]	= List(), -- Blade Flurry
		[13750]	= List(), -- Adrenaline Rush
		[2983]	= List(), -- Sprint (Rank 1)
		[8696]	= List(), -- Sprint (Rank 2)
		[11305]	= List(), -- Sprint (Rank 3)
		[5171]	= List(), -- Slice and Dice (Rank 1)
		[6774]	= List(), -- Slice and Dice (Rank 2)
		[45182]	= List(), -- Cheating Death
		[51690]	= List(), -- Killing Spree
		[51713]	= List(), -- Shadow Dance
		[57933]	= List(), -- Tricks of the Trade
		[31224]	= List(), -- Cloak of Shadows
		[5277]	= List(), -- Evasion (Rank 1)
		[26669]	= List(), -- Evasion (Rank 2)
		[1856]	= List(), -- Vanish (Rank 1)
		[1857]	= List(), -- Vanish (Rank 2)
		[26889]	= List(), -- Vanish (Rank 3)
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
		[49280]	= List(), -- Lightning Shield (Rank 10)
		[49281]	= List(), -- Lightning Shield (Rank 11)
		[16188]	= List(), -- Nature's Swiftness
		[16166]	= List(), -- Elemental Mastery
		[52127]	= List(), -- Water Shield (Rank 1)
		[52129]	= List(), -- Water Shield (Rank 2)
		[52131]	= List(), -- Water Shield (Rank 3)
		[52134]	= List(), -- Water Shield (Rank 4)
		[52136]	= List(), -- Water Shield (Rank 5)
		[52138]	= List(), -- Water Shield (Rank 6)
		[24398]	= List(), -- Water Shield (Rank 7)
		[33736]	= List(), -- Water Shield (Rank 8)
		[57960]	= List(), -- Water Shield (Rank 9)
		[974]	= List(), -- Earth Shield (Rank 1)
		[32593]	= List(), -- Earth Shield (Rank 2)
		[32594]	= List(), -- Earth Shield (Rank 3)
		[49283]	= List(), -- Earth Shield (Rank 4)
		[49284]	= List(), -- Earth Shield (Rank 5)
		[30823]	= List(), -- Shamanistic Rage
		[8178]	= List(), -- Grounding Totem Effect
		[16191]	= List(), -- Mana Tide
		[55198]	= List(), -- Tidal Force
	-- Warlock
		[18789]	= List(), -- Demonic Sacrifice (Burning Wish)
		[18790]	= List(), -- Demonic Sacrifice (Fel Stamina)
		[18791]	= List(), -- Demonic Sacrifice (Touch of Shadow)
		[18792]	= List(), -- Demonic Sacrifice (Fel Energy)
		[35701]	= List(), -- Demonic Sacrifice (Touch of Shadow)
		[5697]	= List(), -- Unending Breath
		[6512]	= List(), -- Detect Lesser Invisibility
		[25228]	= List(), -- Soul Link
		[18708]	= List(), -- Fel Domination
		[47241]	= List(), -- Metamorphosis
	-- Warrior
		[12975]	= List(), -- Last Stand
		[871]	= List(), -- Shield Wall
		[20230]	= List(), -- Retaliation
		[1719]	= List(), -- Recklessness
		[18499]	= List(), -- Berserker Rage
		[2687]	= List(), -- Bloodrage
		[12292]	= List(), -- Death Wish
		[12328]	= List(), -- Sweeping Strikes
		[2565]	= List(), -- Shield Block
		[12880]	= List(), -- Enrage (Rank 1)
		[14201]	= List(), -- Enrage (Rank 2)
		[14202]	= List(), -- Enrage (Rank 3)
		[14203]	= List(), -- Enrage (Rank 4)
		[14204]	= List(), -- Enrage (Rank 5)
		[46924]	= List(), -- Bladestorm
		[23920]	= List(), -- Spell Reflection
	-- Consumables
		[3169]	= List(), -- Limited Invulnerability Potion
		[6615]	= List(), -- Free Action Potion
	-- Racial
		[26297]	= List(), -- Berserking
		[7744]	= List(), -- Will of the Forsaken
		[20572]	= List(), -- Blood Fury (Physical)
		[33697]	= List(), -- Blood Fury (Both)
		[33702]	= List(), -- Blood Fury (Spell)
		[6346]	= List(), -- Fear Ward
		[20594]	= List(), -- Stoneform
		[28880]	= List(), -- Gift of the Naaru
	-- All Classes
		[19753]	= List(), -- Divine Intervention
	},
}

-- Buffs that we don't really need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
	-- General
		[186403] = List(), -- Sign of Battle
		[377749] = List(), -- Joyous Journeys (50% exp buff)
	},
}

-- A list of important buffs that we always want to see
G.unitframe.aurafilters.Whitelist = {
	type = 'Whitelist',
	spells = {
	-- Death Knight
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
	-------------------- Dungeons -------------------
	-------------------------------------------------
	-- Ahn'kahet: The Old Kingdom
	-- Azjol-Nerub
	-- Drak'Tharon Keep
	-- Gundrak
	-- Halls of Lightning
	-- Halls of Reflection
	-- Halls of Stone
	-- Pit of Saron
	-- The Culling of Stratholme
	-- The Forge of Souls
	-- The Nexus
	-- The Oculus
	-- The Violet Hold
	-- Trial of the Champion
	-- Utgarde Keep
	-- Utgarde Pinnacle
	-------------------------------------------------
	-------------------- Phase 1 --------------------
	-------------------------------------------------
	-- Naxxramas
		-- Anub'Rekhan
		[54022] = List(), -- Locust Swarm
		[56098] = List(), -- Acid Spit
		-- Grand Widow Faerlina
		[54099] = List(), -- Rain of Fire
		[54098] = List(), -- Poison Bolt Volley
		-- Maexxna
		[54121] = List(), -- Necrotic Poison 1
		[28776] = List(), -- Necrotic Poison 2
		[28622] = List(), -- Web Wrap
		[54125] = List(), -- Web Spray
		-- Noth the Plaguebringer
		[54835] = List(), -- Curse of the Plaguebringer
		[54814] = List(), -- Cripple 1
		[29212] = List(), -- Cripple 2
		-- Heigan the Unclean
		[55011] = List(), -- Decrepit Fever
		-- Loatheb
		[55052] = List(), -- Inevitable Doom
		[55053] = List(), -- Deathbloom
		-- Instructor Razuvious
		[55550] = List(), -- Jagged Knife
		[55470] = List(), -- Unbalancing Strike
		-- Gothik the Harvester
		[55646] = List(), -- Drain Life
		[55645] = List(), -- Death Plague
		[28679] = List(), -- Harvest Soul
		-- The Four Horsemen
		[57369] = List(), -- Unholy Shadow
		[28832] = List(), -- Mark of Korth'azz
		[28835] = List(), -- Mark of Zeliek
		[28833] = List(), -- Mark of Blaumeux
		[28834] = List(), -- Mark of Rivendare
		-- Patchwerk
		[28801] = List(), -- Slime / Not really Encounter related
		-- Grobbulus
		[28169] = List(), -- Mutating Injection
		-- Gluth
		[54378] = List(), -- Mortal Wound
		[29306] = List(), -- Infected Wound
		-- Thaddius
		[28084] = List(), -- Negative Charge (-)
		[28059] = List(), -- Positive Charge (+)
		-- Sapphiron
		[28522] = List(), -- Icebolt
		[55665] = List(), -- Life Drain
		[28547] = List(), -- Chill 1
		[55699] = List(), -- Chill 2
		-- Kel'Thuzad
		[55807] = List(), -- Frostbolt 1
		[55802] = List(), -- Frostbolt 2
		[27808] = List(), -- Frost Blast
		[28410] = List(), -- Chains of Kel'Thuzad
	-- The Eye of Eternity
		-- Malygos
		[56272] = List(), -- Arcane Breath
		[55853] = List(), -- Vortex 1
		[56263] = List(), -- Vortex 2
		[57407] = List(), -- Surge of Power
		[57429] = List(), -- Static Field
	-- The Obsidian Sanctum
		-- Sartharion
		[60708] = List(4), -- Fade Armor
		[58105] = List(2), -- Power of Shadron
		[61248] = List(2), -- Power of Tenebron
		[56910] = List(6), -- Tail Lash
		[57874] = List(5), -- Twilight Shift
		[57632] = List(4), -- Magma
	-------------------------------------------------
	-------------------- Phase 2 --------------------
	-------------------------------------------------
	-- Ulduar
		-- Flame Leviathan
		-- Ignis the Furnace Master
		-- Razorscale
		-- XT-002 Deconstructor
		-- The Assembly of Iron
		-- Kologarn
		-- Auriaya
		-- Hodir
		-- Thorim
		-- Freya
		-- Mimiron
		-- General Vezax
		-- Yogg-Saron
		-- Algalon the Observer
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- Trial of the Crusader
		-- The Northrend Beasts
		-- Lord Jaraxxus
		-- Champions of the Horde
		-- Champions of the Alliance
		-- Twin Val'kyr
		-- Anub'arak
	-- Onyxia’s Lair
		-- Onyxia
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Icecrown Citadel
		-- Lord Marrowgar
		-- Lady Deathwhisper
		-- Gunship Battle Alliance
		-- Gunship Battle Horde
		-- Deathbringer Saurfang
		-- Festergut
		-- Rotface
		-- Professor Putricide
		-- Blood Prince Council
		-- Blood-Queen Lana'thel
		-- Valithria Dreamwalker
		-- Sindragosa
		-- The Lich King
	-------------------------------------------------
	-------------------- Phase 5 --------------------
	-------------------------------------------------
	-- The Ruby Sanctum
		-- Halion
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
	-------------------- Dungeons -------------------
	-------------------------------------------------
	-- Ahn'kahet: The Old Kingdom
	-- Azjol-Nerub
	-- Drak'Tharon Keep
	-- Gundrak
	-- Halls of Lightning
	-- Halls of Reflection
	-- Halls of Stone
	-- Pit of Saron
	-- The Culling of Stratholme
	-- The Forge of Souls
	-- The Nexus
	-- The Oculus
	-- The Violet Hold
	-- Trial of the Champion
	-- Utgarde Keep
	-- Utgarde Pinnacle
	-------------------------------------------------
	-------------------- Phase 1 --------------------
	-------------------------------------------------
	-- Naxxramas
		-- Anub'Rekhan
		[8269] = List(), -- Frenzy
		[54021] = List(), -- Locust Swarm
		-- Grand Widow Faerlina
		[54100] = List(), -- Frenzy
		-- Maexxna
		[54124] = List(), -- Frenzy
		-- Noth the Plaguebringer
		-- Heigan the Unclean
		-- Loatheb
		-- Instructor Razuvious
		[29061] = List(), -- Bone Barrier
		-- Gothik the Harvester
		-- The Four Horsemen
		-- Patchwerk
		[28131] = List(), -- Frenzy
		-- Grobbulus
		-- Gluth
		[54427] = List(), -- Enrage
		-- Thaddius
		[28134] = List(), -- Power Surge
		-- Sapphiron
		-- Kel'Thuzad
	-- The Eye of Eternity
		-- Malygos
		[56505] = List(), -- Surge of Power
		[57060] = List(), -- Haste
		[57428] = List(), -- Static Field
	-- The Obsidian Sanctum
		-- Sartharion
		[58766] = List(), -- Gift of Twilight
		[60639] = List(), -- Twilight Revenge
		[61254] = List(), -- Will of Sartharion
		[60430] = List(), -- Molten Fury
	-------------------------------------------------
	-------------------- Phase 2 --------------------
	-------------------------------------------------
	-- Ulduar
		-- Flame Leviathan
		-- Ignis the Furnace Master
		-- Razorscale
		-- XT-002 Deconstructor
		-- The Assembly of Iron
		-- Kologarn
		-- Auriaya
		-- Hodir
		-- Thorim
		-- Freya
		-- Mimiron
		-- General Vezax
		-- Yogg-Saron
		-- Algalon the Observer
	-------------------------------------------------
	-------------------- Phase 3 --------------------
	-------------------------------------------------
	-- Trial of the Crusader
		-- The Northrend Beasts
		-- Lord Jaraxxus
		-- Champions of the Horde
		-- Champions of the Alliance
		-- Twin Val'kyr
		-- Anub'arak
	-- Onyxia’s Lair
		-- Onyxia
	-------------------------------------------------
	-------------------- Phase 4 --------------------
	-------------------------------------------------
	-- Icecrown Citadel
		-- Lord Marrowgar
		-- Lady Deathwhisper
		-- Gunship Battle Alliance
		-- Gunship Battle Horde
		-- Deathbringer Saurfang
		-- Festergut
		-- Rotface
		-- Professor Putricide
		-- Blood Prince Council
		-- Blood-Queen Lana'thel
		-- Valithria Dreamwalker
		-- Sindragosa
		-- The Lich King
	-------------------------------------------------
	-------------------- Phase 5 --------------------
	-------------------------------------------------
	-- The Ruby Sanctum
		-- Halion
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {
		-- TODO: Infernal Protection [Cosmic Infuser] / Persistent Shield [Scarab Brooch] / Protection of Ancient Kings [Val'anyr, Hammer of Ancient Kings]
	},
	DEATHKNIGHT = {
		-- TODO: Hysteria / Unholy Frenzy
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
		[48469]	= UF:AuraWatch_AddSpell(48469, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 9)
		[21849]	= UF:AuraWatch_AddSpell(21849, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 1)
		[21850]	= UF:AuraWatch_AddSpell(21850, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 2)
		[26991]	= UF:AuraWatch_AddSpell(26991, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 3)
		[48470]	= UF:AuraWatch_AddSpell(26991, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 4)
		[467]	= UF:AuraWatch_AddSpell(467, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 1)
		[782]	= UF:AuraWatch_AddSpell(782, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 2)
		[1075]	= UF:AuraWatch_AddSpell(1075, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 3)
		[8914]	= UF:AuraWatch_AddSpell(8914, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 4)
		[9756]	= UF:AuraWatch_AddSpell(9756, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 5)
		[9910]	= UF:AuraWatch_AddSpell(9910, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 6)
		[26992]	= UF:AuraWatch_AddSpell(26992, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 7)
		[53307]	= UF:AuraWatch_AddSpell(53307, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 8)
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
		[48440]	= UF:AuraWatch_AddSpell(48440, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 14)
		[48441]	= UF:AuraWatch_AddSpell(48441, 'BOTTOMLEFT', {0.83, 1.00, 0.25}),	-- Rejuvenation (Rank 15)
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
		[48442]	= UF:AuraWatch_AddSpell(48442, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 11)
		[48443]	= UF:AuraWatch_AddSpell(48443, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 12)
		[29166]	= UF:AuraWatch_AddSpell(29166, 'CENTER', {0.49, 0.60, 0.55}, true),	-- Innervate
		[33763]	= UF:AuraWatch_AddSpell(33763, 'BOTTOM', {0.33, 0.37, 0.47}),		-- Lifebloom (Rank 1)
		[48450]	= UF:AuraWatch_AddSpell(48450, 'BOTTOM', {0.33, 0.37, 0.47}),		-- Lifebloom (Rank 2)
		[48451]	= UF:AuraWatch_AddSpell(48451, 'BOTTOM', {0.33, 0.37, 0.47}),		-- Lifebloom (Rank 3)
		[48438]	= UF:AuraWatch_AddSpell(48438, 'BOTTOMRIGHT', {0.8, 0.4, 0}),		-- Wild Growth (Rank 1)
		[53248]	= UF:AuraWatch_AddSpell(53248, 'BOTTOMRIGHT', {0.8, 0.4, 0}),		-- Wild Growth (Rank 2)
		[53249]	= UF:AuraWatch_AddSpell(53249, 'BOTTOMRIGHT', {0.8, 0.4, 0}),		-- Wild Growth (Rank 3)
		[53251]	= UF:AuraWatch_AddSpell(53251, 'BOTTOMRIGHT', {0.8, 0.4, 0}),		-- Wild Growth (Rank 4)
		-- TODO: Abolish Poison
	},
	HUNTER = {
		[19506]	= UF:AuraWatch_AddSpell(19506, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura
		[13159]	= UF:AuraWatch_AddSpell(13159, 'TOP', {0.00, 0.00, 0.85}, true),	-- Aspect of the Pack
		[20043]	= UF:AuraWatch_AddSpell(20043, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 1)
		[20190]	= UF:AuraWatch_AddSpell(20190, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 2)
		[27045]	= UF:AuraWatch_AddSpell(27045, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 3)
		[49071]	= UF:AuraWatch_AddSpell(49071, 'TOP', {0.33, 0.93, 0.79}),			-- Aspect of the Wild (Rank 4)
		-- TODO: Misdirection
	},
	MAGE = {
		[1459]	= UF:AuraWatch_AddSpell(1459, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 1)
		[1460]	= UF:AuraWatch_AddSpell(1460, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 2)
		[1461]	= UF:AuraWatch_AddSpell(1461, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 3)
		[10156]	= UF:AuraWatch_AddSpell(10156, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 4)
		[10157]	= UF:AuraWatch_AddSpell(10157, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 5)
		[27126]	= UF:AuraWatch_AddSpell(27126, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 6)
		[42995]	= UF:AuraWatch_AddSpell(42995, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 7)
		[23028]	= UF:AuraWatch_AddSpell(23028, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 1)
		[27127]	= UF:AuraWatch_AddSpell(27127, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 2)
		[43002]	= UF:AuraWatch_AddSpell(43002, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 3)
		[61024]	= UF:AuraWatch_AddSpell(61024, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Dalaran Intellect
		[61316]	= UF:AuraWatch_AddSpell(61316, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Dalaran Brilliance
		[604]	= UF:AuraWatch_AddSpell(604, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 1)
		[8450]	= UF:AuraWatch_AddSpell(8450, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 2)
		[8451]	= UF:AuraWatch_AddSpell(8451, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 3)
		[10173]	= UF:AuraWatch_AddSpell(10173, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 4)
		[10174]	= UF:AuraWatch_AddSpell(10174, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 5)
		[33944]	= UF:AuraWatch_AddSpell(33944, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 6)
		[43015]	= UF:AuraWatch_AddSpell(43015, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 7)
		[1008]	= UF:AuraWatch_AddSpell(1008, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 1)
		[8455]	= UF:AuraWatch_AddSpell(8455, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 2)
		[10169]	= UF:AuraWatch_AddSpell(10169, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 3)
		[10170]	= UF:AuraWatch_AddSpell(10170, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 4)
		[27130]	= UF:AuraWatch_AddSpell(27130, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 5)
		[33946]	= UF:AuraWatch_AddSpell(33946, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 6)
		[43017]	= UF:AuraWatch_AddSpell(43017, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 7)
		[130]	= UF:AuraWatch_AddSpell(130, 'CENTER', {0.00, 0.00, 0.50}, true),		-- Slow Fall
		-- TODO: Focus Magic
	},
	PALADIN = {
		[1044]	= UF:AuraWatch_AddSpell(1044, 'CENTER', {0.89, 0.45, 0}, true),				-- Hand of Freedom
		[1038]	= UF:AuraWatch_AddSpell(1038, 'CENTER', {0.11, 1.00, 0.45}, true),			-- Hand of Salvation
		[6940]	= UF:AuraWatch_AddSpell(6940, 'CENTER', {0.89, 0.1, 0.1}, true),			-- Hand of Sacrifice
		[1022]	= UF:AuraWatch_AddSpell(1022, 'CENTER', {0.17, 1.00, 0.75}, true),			-- Hand of Protection (Rank 1)
		[5599]	= UF:AuraWatch_AddSpell(5599, 'CENTER', {0.17, 1.00, 0.75}, true),			-- Hand of Protection (Rank 2)
		[10278]	= UF:AuraWatch_AddSpell(10278, 'CENTER', {0.17, 1.00, 0.75}, true),			-- Hand of Protection (Rank 3)
		[19740]	= UF:AuraWatch_AddSpell(19740, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 1)
		[19834]	= UF:AuraWatch_AddSpell(19834, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 2)
		[19835]	= UF:AuraWatch_AddSpell(19835, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 3)
		[19836]	= UF:AuraWatch_AddSpell(19836, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 4)
		[19837]	= UF:AuraWatch_AddSpell(19837, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 5)
		[19838]	= UF:AuraWatch_AddSpell(19838, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 6)
		[25291]	= UF:AuraWatch_AddSpell(25291, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 7)
		[27140]	= UF:AuraWatch_AddSpell(27140, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 8)
		[48931]	= UF:AuraWatch_AddSpell(48931, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 9)
		[48932]	= UF:AuraWatch_AddSpell(48932, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 10)
		[19742]	= UF:AuraWatch_AddSpell(19742, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 1)
		[19850]	= UF:AuraWatch_AddSpell(19850, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 2)
		[19852]	= UF:AuraWatch_AddSpell(19852, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 3)
		[19853]	= UF:AuraWatch_AddSpell(19853, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 4)
		[19854]	= UF:AuraWatch_AddSpell(19854, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 5)
		[25290]	= UF:AuraWatch_AddSpell(25290, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 6)
		[27142]	= UF:AuraWatch_AddSpell(27142, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 7)
		[48935]	= UF:AuraWatch_AddSpell(48935, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 8)
		[48936]	= UF:AuraWatch_AddSpell(48936, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 9)
		[25782]	= UF:AuraWatch_AddSpell(25782, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 1)
		[25916]	= UF:AuraWatch_AddSpell(25916, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 2)
		[27141]	= UF:AuraWatch_AddSpell(27141, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 3)
		[48933]	= UF:AuraWatch_AddSpell(48933, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 4)
		[48934]	= UF:AuraWatch_AddSpell(48934, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 5)
		[25894]	= UF:AuraWatch_AddSpell(25894, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 1)
		[25918]	= UF:AuraWatch_AddSpell(25918, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 2)
		[27143]	= UF:AuraWatch_AddSpell(27143, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 3)
		[48937]	= UF:AuraWatch_AddSpell(48937, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 4)
		[48938]	= UF:AuraWatch_AddSpell(48938, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 5)
		[465]	= UF:AuraWatch_AddSpell(465, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 1)
		[10290]	= UF:AuraWatch_AddSpell(10290, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 2)
		[643]	= UF:AuraWatch_AddSpell(643, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 3)
		[10291]	= UF:AuraWatch_AddSpell(10291, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 4)
		[1032]	= UF:AuraWatch_AddSpell(1032, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 5)
		[10292]	= UF:AuraWatch_AddSpell(10292, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 6)
		[10293]	= UF:AuraWatch_AddSpell(10293, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 7)
		[27149]	= UF:AuraWatch_AddSpell(27149, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 8)
		[48941]	= UF:AuraWatch_AddSpell(48941, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 9)
		[48942]	= UF:AuraWatch_AddSpell(48942, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 10)
		[19746]	= UF:AuraWatch_AddSpell(19746, 'BOTTOMLEFT', {0.83, 1.00, 0.07}),			-- Concentration Aura
		[32223]	= UF:AuraWatch_AddSpell(32223, 'BOTTOMLEFT', {0.83, 1.00, 0.07}),			-- Crusader Aura
		[53563]	= UF:AuraWatch_AddSpell(53563, 'TOPRIGHT', {0.7, 0.3, 0.7}, true),			-- Beacon of Light
		[53601]	= UF:AuraWatch_AddSpell(53601, 'BOTTOMRIGHT', {0.4, 0.7, 0.2}, true),		-- Sacred Shield
	},
	PRIEST = {
		[1243]	= UF:AuraWatch_AddSpell(1243, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 1)
		[1244]	= UF:AuraWatch_AddSpell(1244, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 2)
		[1245]	= UF:AuraWatch_AddSpell(1245, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 3)
		[2791]	= UF:AuraWatch_AddSpell(2791, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 4)
		[10937]	= UF:AuraWatch_AddSpell(10937, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 5)
		[10938]	= UF:AuraWatch_AddSpell(10938, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 6)
		[25389]	= UF:AuraWatch_AddSpell(25389, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 7)
		[48161]	= UF:AuraWatch_AddSpell(48161, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 8)
		[21562]	= UF:AuraWatch_AddSpell(21562, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 1)
		[21564]	= UF:AuraWatch_AddSpell(21564, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 2)
		[25392]	= UF:AuraWatch_AddSpell(25392, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 3)
		[48162]	= UF:AuraWatch_AddSpell(48162, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 4)
		[14752]	= UF:AuraWatch_AddSpell(14752, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 1)
		[14818]	= UF:AuraWatch_AddSpell(14818, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 2)
		[14819]	= UF:AuraWatch_AddSpell(14819, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 3)
		[27841]	= UF:AuraWatch_AddSpell(27841, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 4)
		[25312]	= UF:AuraWatch_AddSpell(25312, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 5)
		[48073]	= UF:AuraWatch_AddSpell(48073, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 6)
		[27681]	= UF:AuraWatch_AddSpell(27681, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 1)
		[32999]	= UF:AuraWatch_AddSpell(32999, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 2)
		[48074]	= UF:AuraWatch_AddSpell(48074, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 3)
		[976]	= UF:AuraWatch_AddSpell(976, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),		-- Shadow Protection (Rank 1)
		[10957]	= UF:AuraWatch_AddSpell(10957, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 2)
		[10958]	= UF:AuraWatch_AddSpell(10958, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 3)
		[25433]	= UF:AuraWatch_AddSpell(25433, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 4)
		[48169]	= UF:AuraWatch_AddSpell(48169, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 5)
		[27683]	= UF:AuraWatch_AddSpell(27683, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 1)
		[39374]	= UF:AuraWatch_AddSpell(39374, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 2)
		[48170]	= UF:AuraWatch_AddSpell(48170, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 3)
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
		[48065]	= UF:AuraWatch_AddSpell(48065, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 13)
		[48066]	= UF:AuraWatch_AddSpell(48066, 'BOTTOM', {0.00, 0.00, 1.00}),			-- Power Word: Shield (Rank 14)
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
		[48067]	= UF:AuraWatch_AddSpell(48067, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 13)
		[48068]	= UF:AuraWatch_AddSpell(48068, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),		-- Renew (Rank 14)
		[6788]	= UF:AuraWatch_AddSpell(6788, 'TOP', {0.89, 0.1, 0.1}),					-- Weakened Soul
		-- TODO: Abolish Poison / Abolish Disease / Guardian Spirit / Prayer of Mending / Pain Suppression / Power Infusion
	},
	ROGUE = {
		-- TODO: Tricks of the Trade
	},
	SHAMAN = {
		[16237]	= UF:AuraWatch_AddSpell(16237, 'RIGHT', {0.2, 0.2, 1}),				-- Ancestral Fortitude
		[8185]	= UF:AuraWatch_AddSpell(8185, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 1)
		[10534]	= UF:AuraWatch_AddSpell(10534, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 2)
		[10535]	= UF:AuraWatch_AddSpell(10535, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 3)
		[25563]	= UF:AuraWatch_AddSpell(25563, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 4)
		[58737]	= UF:AuraWatch_AddSpell(25563, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 5)
		[58739]	= UF:AuraWatch_AddSpell(25563, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 6)
		[8182]	= UF:AuraWatch_AddSpell(8182, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 1)
		[10476]	= UF:AuraWatch_AddSpell(10476, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 2)
		[10477]	= UF:AuraWatch_AddSpell(10477, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 3)
		[25560]	= UF:AuraWatch_AddSpell(25560, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 4)
		[58741]	= UF:AuraWatch_AddSpell(25560, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 5)
		[58745]	= UF:AuraWatch_AddSpell(25560, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 6)
		[10596]	= UF:AuraWatch_AddSpell(10596, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 1)
		[10598]	= UF:AuraWatch_AddSpell(10598, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 2)
		[10599]	= UF:AuraWatch_AddSpell(10599, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 3)
		[25574]	= UF:AuraWatch_AddSpell(25574, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 4)
		[58746]	= UF:AuraWatch_AddSpell(58746, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 5)
		[58749]	= UF:AuraWatch_AddSpell(58749, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 6)
		[5672]	= UF:AuraWatch_AddSpell(5672, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 1)
		[6371]	= UF:AuraWatch_AddSpell(6371, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 2)
		[6372]	= UF:AuraWatch_AddSpell(6372, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 3)
		[10460]	= UF:AuraWatch_AddSpell(10460, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 4)
		[10461]	= UF:AuraWatch_AddSpell(10461, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 5)
		[25567]	= UF:AuraWatch_AddSpell(25567, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 6)
		[58755]	= UF:AuraWatch_AddSpell(58755, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 7)
		[58756]	= UF:AuraWatch_AddSpell(58756, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 8)
		[58757]	= UF:AuraWatch_AddSpell(58757, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 9)
		[16191]	= UF:AuraWatch_AddSpell(16191, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem
		[5677]	= UF:AuraWatch_AddSpell(5677, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 1)
		[10491]	= UF:AuraWatch_AddSpell(10491, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 2)
		[10493]	= UF:AuraWatch_AddSpell(10493, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 3)
		[10494]	= UF:AuraWatch_AddSpell(10494, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 4)
		[25569]	= UF:AuraWatch_AddSpell(25569, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 5)
		[58775]	= UF:AuraWatch_AddSpell(58775, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 6)
		[58776]	= UF:AuraWatch_AddSpell(58776, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 7)
		[58777]	= UF:AuraWatch_AddSpell(58777, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 8)
		[8072]	= UF:AuraWatch_AddSpell(8072, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 1)
		[8156]	= UF:AuraWatch_AddSpell(8156, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 2)
		[8157]	= UF:AuraWatch_AddSpell(8157, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 3)
		[10403]	= UF:AuraWatch_AddSpell(10403, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 4)
		[10404]	= UF:AuraWatch_AddSpell(10404, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 5)
		[10405]	= UF:AuraWatch_AddSpell(10405, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 6)
		[25506]	= UF:AuraWatch_AddSpell(25506, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 7)
		[25507]	= UF:AuraWatch_AddSpell(25507, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 8)
		[58752]	= UF:AuraWatch_AddSpell(58752, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 9)
		[58754]	= UF:AuraWatch_AddSpell(58754, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 10)
		[974]	= UF:AuraWatch_AddSpell(974, 'TOP', {0.08, 0.21, 0.43}, true),		-- Earth Shield (Rank 1)
		[32593]	= UF:AuraWatch_AddSpell(32593, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 2)
		[32594]	= UF:AuraWatch_AddSpell(32594, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 3)
		[49283]	= UF:AuraWatch_AddSpell(49283, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 4)
		[49284]	= UF:AuraWatch_AddSpell(49284, 'TOP', {0.08, 0.21, 0.43}, true),	-- Earth Shield (Rank 5)
		-- TODO: Riptide / Earthliving
	},
	WARLOCK = {
		[5697]	= UF:AuraWatch_AddSpell(5697, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Unending Breath
		[6512]	= UF:AuraWatch_AddSpell(6512, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Lesser Invisibility
		-- TODO: Soulstone
	},
	WARRIOR = {
		[6673]	= UF:AuraWatch_AddSpell(6673, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 1)
		[5242]	= UF:AuraWatch_AddSpell(5242, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 2)
		[6192]	= UF:AuraWatch_AddSpell(6192, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 3)
		[11549]	= UF:AuraWatch_AddSpell(11549, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 4)
		[11550]	= UF:AuraWatch_AddSpell(11550, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 5)
		[11551]	= UF:AuraWatch_AddSpell(11551, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 6)
		[25289]	= UF:AuraWatch_AddSpell(25289, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 7)
		[2048]	= UF:AuraWatch_AddSpell(2048, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 8)
		[47436]	= UF:AuraWatch_AddSpell(47436, 'TOPLEFT', {0.2, 0.2, 1}, true),		-- Battle Shout (Rank 9)
		[469]	= UF:AuraWatch_AddSpell(469, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Commanding Shout (Rank 1)
		[47439]	= UF:AuraWatch_AddSpell(47439, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Commanding Shout (Rank 2)
		[47440]	= UF:AuraWatch_AddSpell(47440, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Commanding Shout (Rank 3)
	},
	PET = {
	-- Warlock Imp
		[6307]	= UF:AuraWatch_AddSpell(6307, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 1)
		[7804]	= UF:AuraWatch_AddSpell(7804, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 2)
		[7805]	= UF:AuraWatch_AddSpell(7805, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 3)
		[11766]	= UF:AuraWatch_AddSpell(11766, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 4)
		[11767]	= UF:AuraWatch_AddSpell(11767, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 5)
		[27268]	= UF:AuraWatch_AddSpell(27268, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 6)
		[47982]	= UF:AuraWatch_AddSpell(47982, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 7)
	-- Warlock Felhunter
		[54424]	= UF:AuraWatch_AddSpell(54424, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Fel Intelligence (Rank 1)
		[57564]	= UF:AuraWatch_AddSpell(57564, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Fel Intelligence (Rank 2)
		[57565]	= UF:AuraWatch_AddSpell(57565, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Fel Intelligence (Rank 3)
		[57566]	= UF:AuraWatch_AddSpell(57566, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Fel Intelligence (Rank 4)
		[57567]	= UF:AuraWatch_AddSpell(57567, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Fel Intelligence (Rank 5)
	-- Hunter Pets
		[24604]	= UF:AuraWatch_AddSpell(24604, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 1)
		[64491]	= UF:AuraWatch_AddSpell(64491, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 2)
		[64492]	= UF:AuraWatch_AddSpell(64492, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 3)
		[64493]	= UF:AuraWatch_AddSpell(64493, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 4)
		[64494]	= UF:AuraWatch_AddSpell(64494, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 5)
		[64495]	= UF:AuraWatch_AddSpell(64495, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 6)
	},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Death Knight
	[42650]	= 8, -- Army of the Dead
	--Druid
	[740]	= 4, -- Tranquility (Rank 1)
	[8918]	= 4, -- Tranquility (Rank 2)
	[9862]	= 4, -- Tranquility (Rank 3)
	[9863]	= 4, -- Tranquility (Rank 4)
	[26983]	= 4, -- Tranquility (Rank 5)
	[48446]	= 4, -- Tranquility (Rank 6)
	[48447]	= 4, -- Tranquility (Rank 7)
	[16914]	= 10, -- Hurricane (Rank 1)
	[17401]	= 10, -- Hurricane (Rank 2)
	[17402]	= 10, -- Hurricane (Rank 3)
	[27012]	= 10, -- Hurricane (Rank 4)
	[48467]	= 10, -- Hurricane (Rank 5)
	--Hunter
	[1510]	= 6, -- Volley (Rank 1)
	[14294]	= 6, -- Volley (Rank 2)
	[14295]	= 6, -- Volley (Rank 3)
	[27022]	= 6, -- Volley (Rank 4)
	[58431]	= 6, -- Volley (Rank 5)
	[58434]	= 6, -- Volley (Rank 6)
	-- Mage
	[10]	= 8, -- Blizzard (Rank 1)
	[6141]	= 8, -- Blizzard (Rank 2)
	[8427]	= 8, -- Blizzard (Rank 3)
	[10185]	= 8, -- Blizzard (Rank 4)
	[10186]	= 8, -- Blizzard (Rank 5)
	[10187]	= 8, -- Blizzard (Rank 6)
	[27085]	= 8, -- Blizzard (Rank 7)
	[42939]	= 8, -- Blizzard (Rank 8)
	[42940]	= 8, -- Blizzard (Rank 9)
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
	[38704]	= 5, -- Arcane Missiles (Rank 11)
	[42843]	= 5, -- Arcane Missiles (Rank 12)
	[42846]	= 5, -- Arcane Missiles (Rank 13)
	[12051]	= 4, -- Evocation
	-- Priest
	[15407]	= 3, -- Mind Flay (Rank 1)
	[17311]	= 3, -- Mind Flay (Rank 2)
	[17312]	= 3, -- Mind Flay (Rank 3)
	[17313]	= 3, -- Mind Flay (Rank 4)
	[17314]	= 3, -- Mind Flay (Rank 5)
	[18807]	= 3, -- Mind Flay (Rank 6)
	[25387]	= 3, -- Mind Flay (Rank 7)
	[48155]	= 3, -- Mind Flay (Rank 8)
	[48156]	= 3, -- Mind Flay (Rank 9)
	[64843]	= 4, -- Divine Hymn
	[64901]	= 4, -- Hymn of Hope -- TODO: Accurate without glyph - with glyph it is 5 ticks
	[48045]	= 5, -- Mind Sear (Rank 1)
	[53023]	= 5, -- Mind Sear (Rank 2)
	[47540]	= 2, -- Penance (Rank 1) (Dummy)
	[47750]	= 2, -- Penance (Rank 1) (Heal A)
	[47757]	= 2, -- Penance (Rank 1) (Heal B)
	[47666]	= 2, -- Penance (Rank 1) (DPS A)
	[47758]	= 2, -- Penance (Rank 1) (DPS B)
	[53005]	= 2, -- Penance (Rank 2) (Dummy)
	[52983]	= 2, -- Penance (Rank 2) (Heal A)
	[52986]	= 2, -- Penance (Rank 2) (Heal B)
	[52998]	= 2, -- Penance (Rank 2) (DPS A)
	[53001]	= 2, -- Penance (Rank 2) (DPS B)
	[53006]	= 2, -- Penance (Rank 3) (Dummy)
	[52984]	= 2, -- Penance (Rank 3) (Heal A)
	[52987]	= 2, -- Penance (Rank 3) (Heal B)
	[52999]	= 2, -- Penance (Rank 3) (DPS A)
	[53002]	= 2, -- Penance (Rank 3) (DPS B)
	[53007]	= 2, -- Penance (Rank 4) (Dummy)
	[52985]	= 2, -- Penance (Rank 4) (Heal A)
	[52988]	= 2, -- Penance (Rank 4) (Heal B)
	[53000]	= 2, -- Penance (Rank 4) (DPS A)
	[53003]	= 2, -- Penance (Rank 4) (DPS B)
	-- Warlock
	[1120]	= 5, -- Drain Soul (Rank 1)
	[8288]	= 5, -- Drain Soul (Rank 2)
	[8289]	= 5, -- Drain Soul (Rank 3)
	[11675]	= 5, -- Drain Soul (Rank 4)
	[27217]	= 5, -- Drain Soul (Rank 5)
	[47855]	= 5, -- Drain Soul (Rank 6)
	[755]	= 10, -- Health Funnel (Rank 1)
	[3698]	= 10, -- Health Funnel (Rank 2)
	[3699]	= 10, -- Health Funnel (Rank 3)
	[3700]	= 10, -- Health Funnel (Rank 4)
	[11693]	= 10, -- Health Funnel (Rank 5)
	[11694]	= 10, -- Health Funnel (Rank 6)
	[11695]	= 10, -- Health Funnel (Rank 7)
	[27259]	= 10, -- Health Funnel (Rank 8)
	[47856]	= 10, -- Health Funnel (Rank 9)
	[689]	= 5, -- Drain Life (Rank 1)
	[699]	= 5, -- Drain Life (Rank 2)
	[709]	= 5, -- Drain Life (Rank 3)
	[7651]	= 5, -- Drain Life (Rank 4)
	[11699]	= 5, -- Drain Life (Rank 5)
	[11700]	= 5, -- Drain Life (Rank 6)
	[27219]	= 5, -- Drain Life (Rank 7)
	[27220]	= 5, -- Drain Life (Rank 8)
	[47857]	= 5, -- Drain Life (Rank 9)
	[5740]	= 4, -- Rain of Fire (Rank 1)
	[6219]	= 4, -- Rain of Fire (Rank 2)
	[11677]	= 4, -- Rain of Fire (Rank 3)
	[11678]	= 4, -- Rain of Fire (Rank 4)
	[27212]	= 4, -- Rain of Fire (Rank 5)
	[47819]	= 4, -- Rain of Fire (Rank 6)
	[47820]	= 4, -- Rain of Fire (Rank 7)
	[1949]	= 15, -- Hellfire (Rank 1)
	[11683]	= 15, -- Hellfire (Rank 2)
	[11684]	= 15, -- Hellfire (Rank 3)
	[27213]	= 15, -- Hellfire (Rank 4)
	[47823]	= 15, -- Hellfire (Rank 5)
	[5138]	= 5, -- Drain Mana
	-- First Aid
	[45544]	= 8, -- Heavy Frostweave Bandage
	[45543]	= 8, -- Frostweave Bandage
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
}

-- Spells Effected By Talents
G.unitframe.TalentChannelTicks = {}

G.unitframe.ChannelTicksSize = {}

-- Spells Effected By Haste
G.unitframe.HastedChannelTicks = {}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825]	= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Bloodlust
	[32182]	= { enable = true, color = {r = 0.98, g = 0.57, b = 0.10 }}, -- Heroism
}

G.unitframe.AuraHighlightColors = {
	[25771]	= {enable = false, style = 'FILL', color = {r = 0.85, g = 0, b = 0, a = 0.85}}, -- Forbearance
}
