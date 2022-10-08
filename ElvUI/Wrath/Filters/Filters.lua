local E, L, V, P, G = unpack(ElvUI)

local List = E.Filters.List
local Aura = E.Filters.Aura

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
		[120]	= List(2), -- Cone of Cold (Rank 1)
		[8492]	= List(2), -- Cone of Cold (Rank 2)
		[10159]	= List(2), -- Cone of Cold (Rank 3)
		[10160]	= List(2), -- Cone of Cold (Rank 4)
		[10161]	= List(2), -- Cone of Cold (Rank 5)
		[27087]	= List(2), -- Cone of Cold (Rank 6)
		[42930]	= List(2), -- Cone of Cold (Rank 7)
		[42931]	= List(2), -- Cone of Cold (Rank 8)
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
		[1126]	= Aura(1126, {5232,6756,5234,8907,9884,9885,26990,48469,21849,21850,26991,48470}, 'TOPLEFT', {0.2, 0.8, 0.8}, true), -- Mark/Gift of the Wild
		[467]	= Aura(467, {782,1075,8914,9756,9910,26992,53307}, 'TOPRIGHT', {0.4, 0.2, 0.8}, true), -- Thorns
		[774]	= Aura(774, {1058,1430,2090,2091,3627,8910,9839,9840,9841,25299,26981,26982,48440,48441}, 'BOTTOMLEFT', {0.83, 1.00, 0.25}), -- Rejuvenation
		[8936]	= Aura(8936, {8938,8939,8940,8941,9750,9856,9857,9858,26980,48442,48443}, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Regrowth
		[29166]	= Aura(29166, nil, 'CENTER', {0.49, 0.60, 0.55}, true), -- Innervate
		[33763]	= Aura(33763, {48450,48451}, 'BOTTOM', {0.33, 0.37, 0.47}), -- Lifebloom
		[48438]	= Aura(48438, {53248,53249,53251}, 'BOTTOMRIGHT', {0.8, 0.4, 0}), -- Wild Growth
		-- TODO: Abolish Poison
	},
	HUNTER = {
		[19506]	= Aura(19506, nil, 'TOPLEFT', {0.89, 0.09, 0.05}), -- Trueshot Aura
		[13159]	= Aura(13159, nil, 'TOP', {0.00, 0.00, 0.85}, true), -- Aspect of the Pack
		[20043]	= Aura(20043, {20190,27045,49071}, 'TOP', {0.33, 0.93, 0.79}), -- Aspect of the Wild
		-- TODO: Misdirection
	},
	MAGE = {
		[1459]	= Aura(1459, {1460,1461,10156,10157,27126,42995,61024,61316,23028,27127,43002}, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Arcane/Dalaran Intellect/Brilliance
		[604]	= Aura(604, {8450,8451,10173,10174,33944,43015}, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Dampen Magic
		[1008]	= Aura(1008, {8455,10169,10170,27130,33946,43017}, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Amplify Magic
		[130]	= Aura(130, nil, 'CENTER', {0.00, 0.00, 0.50}, true), -- Slow Fall
		-- TODO: Focus Magic
	},
	PALADIN = {
		[1044]	= Aura(1044, nil, 'CENTER', {0.89, 0.45, 0}, true), -- Hand of Freedom
		[1038]	= Aura(1038, nil, 'CENTER', {0.11, 1.00, 0.45}, true), -- Hand of Salvation
		[6940]	= Aura(6940, nil, 'CENTER', {0.89, 0.1, 0.1}, true), -- Hand of Sacrifice
		[1022]	= Aura(1022, {5599,10278}, 'CENTER', {0.17, 1.00, 0.75}, true), -- Hand of Protection
		[19740]	= Aura(19740, {19834,19835,19836,19837,19838,25291,27140,48931,48932,25782,25916,27141,48933,48934}, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- (Greater) Blessing of Might
		[19742]	= Aura(19742, {19850,19852,19853,19854,25290,27142,48935,48936,25894,25918,27143,48937,48938}, 'TOPLEFT', {0.2, 0.8, 0.2}, true), -- (Greater) Blessing of Wisdom
		[465]	= Aura(465, {10290,643,10291,1032,10292,10293,27149,48941,48942}, 'BOTTOMLEFT', {0.58, 1.00, 0.50}), -- Devotion Aura
		[19746]	= Aura(19746, nil, 'BOTTOMLEFT', {0.83, 1.00, 0.07}), -- Concentration Aura
		[32223]	= Aura(32223, nil, 'BOTTOMLEFT', {0.83, 1.00, 0.07}), -- Crusader Aura
		[53563]	= Aura(53563, nil, 'TOPRIGHT', {0.7, 0.3, 0.7}, true), -- Beacon of Light
		[53601]	= Aura(53601, nil, 'BOTTOMRIGHT', {0.4, 0.7, 0.2}, true), -- Sacred Shield
	},
	PRIEST = {
		[1243]	= Aura(1243, {1244,1245,2791,10937,10938,25389,48161}, 'TOPLEFT', {1, 1, 0.66}, true), -- Power Word: Fortitude
		[21562]	= Aura(21562, {21564,25392,48162}, 'TOPLEFT', {1, 1, 0.66}, true), -- Prayer of Fortitude
		[14752]	= Aura(14752, {14818,14819,27841,25312,48073}, 'TOPRIGHT', {0.2, 0.7, 0.2}, true), -- Divine Spirit
		[27681]	= Aura(27681, {32999,48074}, 'TOPRIGHT', {0.2, 0.7, 0.2}, true), -- Prayer of Spirit
		[976]	= Aura(976, {10957,10958,25433,48169}, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true), -- Shadow Protection
		[27683]	= Aura(27683, {39374,48170}, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true), -- Prayer of Shadow Protection
		[17]	= Aura(17, {592,600,3747,6065,6066,10898,10899,10900,10901,25217,25218,48065,48066}, 'BOTTOM', {0.00, 0.00, 1.00}), -- Power Word: Shield
		[139]	= Aura(139, {6074,6075,6076,6077,6078,10927,10928,10929,25315,25221,25222,48067,48068}, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}), -- Renew
		[6788]	= Aura(6788, nil, 'TOP', {0.89, 0.1, 0.1}), -- Weakened Soul
		[41635]	= Aura(41635, nil, 'BOTTOMRIGHT', {0.2, 0.7, 0.2}), -- Prayer of Mending
		-- TODO: Abolish Poison / Abolish Disease / Guardian Spirit / Pain Suppression / Power Infusion
	},
	ROGUE = {
		-- TODO: Tricks of the Trade
	},
	SHAMAN = {
		[16177]	= Aura(16177, {16236,16237}, 'RIGHT', {0.2, 0.2, 1}), -- Ancestral Fortitude
		[8185]	= Aura(8185, {10534,10535,25563,58737,58739}, 'TOPLEFT', {0.05, 1.00, 0.50}), -- Fire Resistance Totem
		[8182]	= Aura(8182, {10476,10477,25560,58741,58745}, 'TOPLEFT', {0.54, 0.53, 0.79}), -- Frost Resistance Totem
		[10596]	= Aura(10596, {10598,10599,25574,58746,58749}, 'TOPLEFT', {0.33, 1.00, 0.20}), -- Nature Resistance Totem
		[5672]	= Aura(5672, {6371,6372,10460,10461,25567,58755,58756,58757}, 'BOTTOM', {0.67, 1.00, 0.50}), -- Healing Stream Totem
		[16191]	= Aura(16191, nil, 'BOTTOMLEFT', {0.67, 1.00, 0.80}), -- Mana Tide Totem
		[5677]	= Aura(5677, {10491,10493,10494,25569,58775,58776,58777}, 'LEFT', {0.67, 1.00, 0.80}), -- Mana Spring Totem
		[8072]	= Aura(8072, {8156,8157,10403,10404,10405,25506,25507,58752,58754}, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}), -- Stoneskin Totem
		[974]	= Aura(974, {32593,32594,49283,49284}, 'TOP', {0.08, 0.21, 0.43}, true), -- Earth Shield
		[61295] = Aura(61295, {61299,61300,61301}, 'TOPRIGHT', {0.7, 0.3, 0.7}), -- Riptide
		[51945] = Aura(51945, {51990,51997,51998,51999,52000}, 'LEFT', {0.7, 0.3, 0.7}), -- Earthliving
	},
	WARLOCK = {
		[5697]	= Aura(5697, nil, 'TOPLEFT', {0.89, 0.09, 0.05}, true), -- Unending Breath
		[6512]	= Aura(6512, nil, 'TOPRIGHT', {0.2, 0.8, 0.2}, true), -- Detect Lesser Invisibility
		-- TODO: Soulstone
	},
	WARRIOR = {
		[6673]	= Aura(6673, {5242,6192,11549,11550,11551,25289,2048,47436}, 'TOPLEFT', {0.2, 0.2, 1}, true), -- Battle Shout
		[469]	= Aura(469, {47439,47440}, 'TOPRIGHT', {0.4, 0.2, 0.8}, true), -- Commanding Shout
	},
	PET = {
	-- Warlock Imp
		[6307]	= Aura(6307, {7804,7805,11766,11767,27268,47982}, 'BOTTOMLEFT', {0.89, 0.09, 0.05}), -- Blood Pact
	-- Warlock Felhunter
		[54424]	= Aura(54424, {57564,57565,57566,57567}, 'BOTTOMLEFT', {0.2, 0.8, 0.2}), -- Fel Intelligence
	-- Hunter Pets
		[24604]	= Aura(24604, {64491,64492,64493,64494,64495}, 'TOPRIGHT', {0.08, 0.59, 0.41}), -- Furious Howl
	},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
	-- Death Knight
	[42650]	= 8, -- Army of the Dead
	--Druid
	[740]	= 4, -- Tranquility
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
