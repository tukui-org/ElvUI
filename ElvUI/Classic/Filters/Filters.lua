local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local strfind, unpack = strfind, unpack

local IsPlayerSpell = IsPlayerSpell
local GetSpellSubtext = GetSpellSubtext
local GetSpellInfo = GetSpellInfo

-- These are debuffs that are some form of CC
G.unitframe.aurafilters.CCDebuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
		[339]	= UF:FilterList_Defaults(1), -- Entangling Roots (Rank 1)
		[1062]	= UF:FilterList_Defaults(1), -- Entangling Roots (Rank 2)
		[5195]	= UF:FilterList_Defaults(1), -- Entangling Roots (Rank 3)
		[5196]	= UF:FilterList_Defaults(1), -- Entangling Roots (Rank 4)
		[9852]	= UF:FilterList_Defaults(1), -- Entangling Roots (Rank 5)
		[9853]	= UF:FilterList_Defaults(1), -- Entangling Roots (Rank 6)
		[19975]	= UF:FilterList_Defaults(1), -- Entangling Roots (Nature's Grasp) (Rank 1)
		[19974]	= UF:FilterList_Defaults(1), -- Entangling Roots (Nature's Grasp) (Rank 2)
		[19973]	= UF:FilterList_Defaults(1), -- Entangling Roots (Nature's Grasp) (Rank 3)
		[19972]	= UF:FilterList_Defaults(1), -- Entangling Roots (Nature's Grasp) (Rank 4)
		[19971]	= UF:FilterList_Defaults(1), -- Entangling Roots (Nature's Grasp) (Rank 5)
		[19970]	= UF:FilterList_Defaults(1), -- Entangling Roots (Nature's Grasp) (Rank 6)
		[2637]	= UF:FilterList_Defaults(1), -- Hibernate (Rank 1)
		[18657]	= UF:FilterList_Defaults(1), -- Hibernate (Rank 2)
		[18658]	= UF:FilterList_Defaults(1), -- Hibernate (Rank 3)
		[19675]	= UF:FilterList_Defaults(2), -- Feral Charge Effect
		[5211]	= UF:FilterList_Defaults(4), -- Bash (Rank 1)
		[6798]	= UF:FilterList_Defaults(4), -- Bash (Rank 2)
		[8983]	= UF:FilterList_Defaults(4), -- Bash (Rank 3)
		[16922]	= UF:FilterList_Defaults(2), -- Celestial Focus (Starfire Stun)
		[9005]	= UF:FilterList_Defaults(2), -- Pounce (Rank 1)
		[9823]	= UF:FilterList_Defaults(2), -- Pounce (Rank 2)
		[9827]	= UF:FilterList_Defaults(2), -- Pounce (Rank 3)
	--Hunter
		[3355]	= UF:FilterList_Defaults(3), -- Freezing Trap Effect (Rank 1)
		[14308]	= UF:FilterList_Defaults(3), -- Freezing Trap Effect (Rank 2)
		[14309]	= UF:FilterList_Defaults(3), -- Freezing Trap Effect (Rank 3)
		[13810]	= UF:FilterList_Defaults(1), -- Frost Trap Aura
		[19503]	= UF:FilterList_Defaults(4), -- Scatter Shot
		[5116]	= UF:FilterList_Defaults(2), -- Concussive Shot
		[2974]	= UF:FilterList_Defaults(2), -- Wing Clip (Rank 1)
		[14267]	= UF:FilterList_Defaults(2), -- Wing Clip (Rank 2)
		[14268]	= UF:FilterList_Defaults(2), -- Wing Clip (Rank 3)
		[1513]	= UF:FilterList_Defaults(2), -- Scare Beast (Rank 1)
		[14326]	= UF:FilterList_Defaults(2), -- Scare Beast (Rank 2)
		[14327]	= UF:FilterList_Defaults(2), -- Scare Beast (Rank 3)
		[24394]	= UF:FilterList_Defaults(6), -- Intimidation
		[19386]	= UF:FilterList_Defaults(2), -- Wyvern Sting (Rank 1)
		[24132]	= UF:FilterList_Defaults(2), -- Wyvern Sting (Rank 2)
		[24133]	= UF:FilterList_Defaults(2), -- Wyvern Sting (Rank 3)
		[19229]	= UF:FilterList_Defaults(2), -- Improved Wing Clip
		[19306]	= UF:FilterList_Defaults(2), -- Counterattack (Rank 1)
		[20909]	= UF:FilterList_Defaults(2), -- Counterattack (Rank 2)
		[20910]	= UF:FilterList_Defaults(2), -- Counterattack (Rank 3)
		[19410]	= UF:FilterList_Defaults(2), -- Improved Concussive Shot
		[25999]	= UF:FilterList_Defaults(2), -- Charge (Boar)
		[19185]	= UF:FilterList_Defaults(1), -- Entrapment
	--Mage
		[118]	= UF:FilterList_Defaults(3), -- Polymorph (Rank 1)
		[12824]	= UF:FilterList_Defaults(3), -- Polymorph (Rank 2)
		[12825]	= UF:FilterList_Defaults(3), -- Polymorph (Rank 3)
		[12826]	= UF:FilterList_Defaults(3), -- Polymorph (Rank 4)
		[28271]	= UF:FilterList_Defaults(3), -- Polymorph (Turtle)
		[28272]	= UF:FilterList_Defaults(3), -- Polymorph (Pig)
		[122]	= UF:FilterList_Defaults(1), -- Frost Nova (Rank 1)
		[865]	= UF:FilterList_Defaults(1), -- Frost Nova (Rank 2)
		[6131]	= UF:FilterList_Defaults(1), -- Frost Nova (Rank 3)
		[10230]	= UF:FilterList_Defaults(1), -- Frost Nova (Rank 4)
		[12494]	= UF:FilterList_Defaults(2), -- Frostbite
		[116]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 1)
		[205]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 2)
		[837]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 3)
		[7322]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 4)
		[8406]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 5)
		[8407]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 6)
		[8408]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 7)
		[10179]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 8)
		[10180]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 9)
		[10181]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 10)
		[25304]	= UF:FilterList_Defaults(2), -- Frostbolt (Rank 11)
		[12355]	= UF:FilterList_Defaults(2), -- Impact
		[18469]	= UF:FilterList_Defaults(2), -- Counterspell - Silenced
		[11113]	= UF:FilterList_Defaults(2), -- Blast Wave
		[12484]	= UF:FilterList_Defaults(2), -- Chilled (Blizzard) (Rank 1)
		[12485]	= UF:FilterList_Defaults(2), -- Chilled (Blizzard) (Rank 2)
		[12486]	= UF:FilterList_Defaults(2), -- Chilled (Blizzard) (Rank 3)
		[6136]	= UF:FilterList_Defaults(2), -- Chilled (Frost Armor)
		[7321]	= UF:FilterList_Defaults(2), -- Chilled (Ice Armor)
		[120]	= UF:FilterList_Defaults(2), -- Cone of Cold
	--Paladin
		[853]	= UF:FilterList_Defaults(3), -- Hammer of Justice (Rank 1)
		[5588]	= UF:FilterList_Defaults(3), -- Hammer of Justice (Rank 2)
		[5589]	= UF:FilterList_Defaults(3), -- Hammer of Justice (Rank 3)
		[10308]	= UF:FilterList_Defaults(3), -- Hammer of Justice (Rank 4)
		[20066]	= UF:FilterList_Defaults(3), -- Repentance
		[20170]	= UF:FilterList_Defaults(2), -- Stun (Seal of Justice Proc)
		[2878]	= UF:FilterList_Defaults(3), -- Turn Undead (Rank 1)
		[5627]	= UF:FilterList_Defaults(3), -- Turn Undead (Rank 2)
		[10326]	= UF:FilterList_Defaults(3), -- Turn Undead (Rank 3)
	--Priest
		[8122]	= UF:FilterList_Defaults(3), -- Psychic Scream (Rank 1)
		[8124]	= UF:FilterList_Defaults(3), -- Psychic Scream (Rank 2)
		[10888]	= UF:FilterList_Defaults(3), -- Psychic Scream (Rank 3)
		[10890]	= UF:FilterList_Defaults(3), -- Psychic Scream (Rank 4)
		[605]	= UF:FilterList_Defaults(5), -- Mind Control (Rank 1)
		[10911]	= UF:FilterList_Defaults(5), -- Mind Control (Rank 2)
		[10912]	= UF:FilterList_Defaults(5), -- Mind Control (Rank 3)
		[15269]	= UF:FilterList_Defaults(2), -- Blackout
		[15407]	= UF:FilterList_Defaults(2), -- Mind Flay (Rank 1)
		[17311]	= UF:FilterList_Defaults(2), -- Mind Flay (Rank 2)
		[17312]	= UF:FilterList_Defaults(2), -- Mind Flay (Rank 3)
		[17313]	= UF:FilterList_Defaults(2), -- Mind Flay (Rank 4)
		[17314]	= UF:FilterList_Defaults(2), -- Mind Flay (Rank 5)
		[18807]	= UF:FilterList_Defaults(2), -- Mind Flay (Rank 6)
		[15487]	= UF:FilterList_Defaults(2), -- Silence
	--Rogue
		[6770]	= UF:FilterList_Defaults(4), -- Sap (Rank 1)
		[2070]	= UF:FilterList_Defaults(4), -- Sap (Rank 2)
		[11297]	= UF:FilterList_Defaults(4), -- Sap (Rank 3)
		[2094]	= UF:FilterList_Defaults(5), -- Blind
		[408]	= UF:FilterList_Defaults(4), -- Kidney Shot (Rank 1)
		[8643]	= UF:FilterList_Defaults(4), -- Kidney Shot (Rank 2)
		[1833]	= UF:FilterList_Defaults(2), -- Cheap Shot
		[1776]	= UF:FilterList_Defaults(2), -- Gouge (Rank 1)
		[1777]	= UF:FilterList_Defaults(2), -- Gouge (Rank 2)
		[8629]	= UF:FilterList_Defaults(2), -- Gouge (Rank 3)
		[11285]	= UF:FilterList_Defaults(2), -- Gouge (Rank 4)
		[11286]	= UF:FilterList_Defaults(2), -- Gouge (Rank 5)
		[18425]	= UF:FilterList_Defaults(2), -- Kick - Silenced
		[14251]	= UF:FilterList_Defaults(2), -- Riposte
	--Shaman
		[2484]	= UF:FilterList_Defaults(1), -- Earthbind Totem
		[8056]	= UF:FilterList_Defaults(2), -- Frost Shock (Rank 1)
		[8058]	= UF:FilterList_Defaults(2), -- Frost Shock (Rank 2)
		[10472]	= UF:FilterList_Defaults(2), -- Frost Shock (Rank 3)
		[10473]	= UF:FilterList_Defaults(2), -- Frost Shock (Rank 4)
		[8034]	= UF:FilterList_Defaults(2), -- Frostbrand Attack (Rank 1)
		[8037]	= UF:FilterList_Defaults(2), -- Frostbrand Attack (Rank 2)
		[10458]	= UF:FilterList_Defaults(2), -- Frostbrand Attack (Rank 3)
		[16352]	= UF:FilterList_Defaults(2), -- Frostbrand Attack (Rank 4)
		[16353]	= UF:FilterList_Defaults(2), -- Frostbrand Attack (Rank 5)
	--Warlock
		[5782]	= UF:FilterList_Defaults(3), -- Fear (Rank 1)
		[6213]	= UF:FilterList_Defaults(3), -- Fear (Rank 2)
		[6215]	= UF:FilterList_Defaults(3), -- Fear (Rank 3)
		[6358]	= UF:FilterList_Defaults(3), -- Seduction (Succubus)
		[18223]	= UF:FilterList_Defaults(2), -- Curse of Exhaustion
		[18093]	= UF:FilterList_Defaults(2), -- Pyroclasm
		[710]	= UF:FilterList_Defaults(2), -- Banish (Rank 1)
		[18647]	= UF:FilterList_Defaults(2), -- Banish (Rank 2)
		[6789]	= UF:FilterList_Defaults(3), -- Death Coil (Rank 1)
		[17925]	= UF:FilterList_Defaults(3), -- Death Coil (Rank 2)
		[17926]	= UF:FilterList_Defaults(3), -- Death Coil (Rank 3)
		[5484]	= UF:FilterList_Defaults(3), -- Howl of Terror (Rank 1)
		[17928]	= UF:FilterList_Defaults(3), -- Howl of Terror (Rank 2)
		[24259]	= UF:FilterList_Defaults(2), -- Spell Lock (Felhunter)
		[18118]	= UF:FilterList_Defaults(2), -- Aftermath
		[20812]	= UF:FilterList_Defaults(2), -- Cripple (Doomguard)
		[1098]	= UF:FilterList_Defaults(5), -- Enslave Demon (Rank 1)
		[11725]	= UF:FilterList_Defaults(5), -- Enslave Demon (Rank 2)
		[11726]	= UF:FilterList_Defaults(5), -- Enslave Demon (Rank 3)
	--Warrior
		[20511]	= UF:FilterList_Defaults(4), -- Intimidating Shout (Cower)
		[5246]	= UF:FilterList_Defaults(4), -- Intimidating Shout (Fear)
		[1715]	= UF:FilterList_Defaults(2), -- Hamstring (Rank 1)
		[7372]	= UF:FilterList_Defaults(2), -- Hamstring (Rank 2)
		[7373]	= UF:FilterList_Defaults(2), -- Hamstring (Rank 3)
		[12809]	= UF:FilterList_Defaults(2), -- Concussion Blow
		[20253]	= UF:FilterList_Defaults(2), -- Intercept Stun (Rank 1)
		[20614]	= UF:FilterList_Defaults(2), -- Intercept Stun (Rank 2)
		[20615]	= UF:FilterList_Defaults(2), -- Intercept Stun (Rank 3)
		[7922]	= UF:FilterList_Defaults(2), -- Charge Stun
		[12798]	= UF:FilterList_Defaults(2), -- Revenge Stun
		[18498]	= UF:FilterList_Defaults(2), -- Shield Bash - Silenced
		[23694]	= UF:FilterList_Defaults(2), -- Improved Hamstring
		[676]	= UF:FilterList_Defaults(2), -- Disarm
		[12323]	= UF:FilterList_Defaults(2), -- Piercing Howl
	--Mace Specialization
		[5530]	= UF:FilterList_Defaults(2), -- Mace Stun Effect
	--Racial
		[20549]	= UF:FilterList_Defaults(2), -- War Stomp
	--Sunder Armor, Faerie Fire, Faerie Fire (Feral)
		[7386]	= UF:FilterList_Defaults(6), -- Sunder Armor (Rank 1)
		[7405]	= UF:FilterList_Defaults(6), -- Sunder Armor (Rank 2)
		[8380]	= UF:FilterList_Defaults(6), -- Sunder Armor (Rank 3)
		[11596]	= UF:FilterList_Defaults(6), -- Sunder Armor (Rank 4)
		[11597]	= UF:FilterList_Defaults(6), -- Sunder Armor (Rank 5)
		[770]	= UF:FilterList_Defaults(5), -- Faerie Fire (Rank 1)
		[778]	= UF:FilterList_Defaults(5), -- Faerie Fire (Rank 2)
		[9749]	= UF:FilterList_Defaults(5), -- Faerie Fire (Rank 3)
		[9907]	= UF:FilterList_Defaults(5), -- Faerie Fire (Rank 4)
		[16857]	= UF:FilterList_Defaults(5), -- Faerie Fire (Feral) (Rank 1)
		[17390]	= UF:FilterList_Defaults(5), -- Faerie Fire (Feral) (Rank 2)
		[17391]	= UF:FilterList_Defaults(5), -- Faerie Fire (Feral) (Rank 3)
		[17392]	= UF:FilterList_Defaults(5), -- Faerie Fire (Feral) (Rank 4)
	--Winter's Chill Debuff
		[12579]	= UF:FilterList_Defaults(5), -- Winter's Chill
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	-- Druid
		[22812]	= UF:FilterList_Defaults(2), -- Barkskin
	-- Hunter
		[19263]	= UF:FilterList_Defaults(2), -- Deterrence
	--Mage
		[11958]	= UF:FilterList_Defaults(2), -- Ice Block
	--Paladin
		[498]	= UF:FilterList_Defaults(2), -- Divine Protection (Rank 1)
		[5573]	= UF:FilterList_Defaults(2), -- Divine Protection (Rank 2)
		[642]	= UF:FilterList_Defaults(2), -- Divine Shield (Rank 1)
		[1020]	= UF:FilterList_Defaults(2), -- Divine Shield (Rank 2)
		[1022]	= UF:FilterList_Defaults(2), -- Blessing of Protection (Rank 1)
		[5599]	= UF:FilterList_Defaults(2), -- Blessing of Protection (Rank 2)
		[10278]	= UF:FilterList_Defaults(2), -- Blessing of Protection (Rank 3)
	-- Rogue
		[5277]	= UF:FilterList_Defaults(2), -- Evasion
		[1856]	= UF:FilterList_Defaults(2), -- Vanish (Rank 1)
		[1857]	= UF:FilterList_Defaults(2), -- Vanish (Rank 2)
	-- Warrior
		[12975]	= UF:FilterList_Defaults(2), -- Last Stand
		[871]	= UF:FilterList_Defaults(2), -- Shield Wall
		[20230]	= UF:FilterList_Defaults(2), -- Retaliation
	--Consumables
		[3169]	= UF:FilterList_Defaults(2), -- Limited Invulnerability Potion
		[6615]	= UF:FilterList_Defaults(2), -- Free Action Potion
	--Racial
		[7744]	= UF:FilterList_Defaults(2), -- Will of the Forsaken
		[6346]	= UF:FilterList_Defaults(2), -- Fear Ward
		[20594]	= UF:FilterList_Defaults(2), -- Stoneform
	--All Classes
		[19753]	= UF:FilterList_Defaults(2), -- Divine Intervention
	},
}

--Default whitelist for player buffs, still WIP
G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
		[29166]	= UF:FilterList_Defaults(), -- Innervate
		[22812]	= UF:FilterList_Defaults(), -- Barkskin
		[17116]	= UF:FilterList_Defaults(), -- Nature's Swiftness
		[16689]	= UF:FilterList_Defaults(), -- Nature's Grasp (Rank 1)
		[16810]	= UF:FilterList_Defaults(), -- Nature's Grasp (Rank 2)
		[16811]	= UF:FilterList_Defaults(), -- Nature's Grasp (Rank 3)
		[16812]	= UF:FilterList_Defaults(), -- Nature's Grasp (Rank 4)
		[16813]	= UF:FilterList_Defaults(), -- Nature's Grasp (Rank 5)
		[17329]	= UF:FilterList_Defaults(), -- Nature's Grasp (Rank 6)
		[16864]	= UF:FilterList_Defaults(), -- Omen of Clarity
		[5217]	= UF:FilterList_Defaults(), -- Tiger's Fury (Rank 1)
		[6793]	= UF:FilterList_Defaults(), -- Tiger's Fury (Rank 2)
		[9845]	= UF:FilterList_Defaults(), -- Tiger's Fury (Rank 3)
		[9846]	= UF:FilterList_Defaults(), -- Tiger's Fury (Rank 4)
		[2893]	= UF:FilterList_Defaults(), -- Abolish Poison
		[5229]	= UF:FilterList_Defaults(), -- Enrage
		[1850]	= UF:FilterList_Defaults(), -- Dash (Rank 1)
		[9821]	= UF:FilterList_Defaults(), -- Dash (Rank 2)
		[33357]	= UF:FilterList_Defaults(), -- Dash (Rank 3)
	--Hunter
		[13161]	= UF:FilterList_Defaults(), -- Aspect of the Beast
		[5118]	= UF:FilterList_Defaults(), -- Aspect of the Cheetah
		[13163]	= UF:FilterList_Defaults(), -- Aspect of the Monkey
		[13159]	= UF:FilterList_Defaults(), -- Aspect of the Pack
		[20043]	= UF:FilterList_Defaults(), -- Aspect of the Wild (Rank 1)
		[20190]	= UF:FilterList_Defaults(), -- Aspect of the Wild (Rank 2)
		[3045]	= UF:FilterList_Defaults(), -- Rapid Fire
		[19263]	= UF:FilterList_Defaults(), -- Deterrence
		[13165]	= UF:FilterList_Defaults(), -- Aspect of the Hawk (Rank 1)
		[14318]	= UF:FilterList_Defaults(), -- Aspect of the Hawk (Rank 2)
		[14319]	= UF:FilterList_Defaults(), -- Aspect of the Hawk (Rank 3)
		[14320]	= UF:FilterList_Defaults(), -- Aspect of the Hawk (Rank 4)
		[14321]	= UF:FilterList_Defaults(), -- Aspect of the Hawk (Rank 5)
		[14322]	= UF:FilterList_Defaults(), -- Aspect of the Hawk (Rank 6)
		[25296]	= UF:FilterList_Defaults(), -- Aspect of the Hawk (Rank 7)
		[19574]	= UF:FilterList_Defaults(), -- Bestial Wrath
	--Mage
		[11958]	= UF:FilterList_Defaults(), -- Ice Block
		[12043]	= UF:FilterList_Defaults(), -- Presence of Mind
		[28682]	= UF:FilterList_Defaults(), -- Combustion
		[12042]	= UF:FilterList_Defaults(), -- Arcane Power
		[11426]	= UF:FilterList_Defaults(), -- Ice Barrier (Rank 1)
		[13031]	= UF:FilterList_Defaults(), -- Ice Barrier (Rank 2)
		[13032]	= UF:FilterList_Defaults(), -- Ice Barrier (Rank 3)
		[13033]	= UF:FilterList_Defaults(), -- Ice Barrier (Rank 4)
	--Paladin
		[1044]	= UF:FilterList_Defaults(), -- Blessing of Freedom
		[465]	= UF:FilterList_Defaults(), -- Devotion Aura (Rank 1)
		[10290]	= UF:FilterList_Defaults(), -- Devotion Aura (Rank 2)
		[643]	= UF:FilterList_Defaults(), -- Devotion Aura (Rank 3)
		[10291]	= UF:FilterList_Defaults(), -- Devotion Aura (Rank 4)
		[1032]	= UF:FilterList_Defaults(), -- Devotion Aura (Rank 5)
		[10292]	= UF:FilterList_Defaults(), -- Devotion Aura (Rank 6)
		[10293]	= UF:FilterList_Defaults(), -- Devotion Aura (Rank 7)
		[19746]	= UF:FilterList_Defaults(), -- Concentration Aura
		[7294]	= UF:FilterList_Defaults(), -- Retribution Aura (Rank 1)
		[10298]	= UF:FilterList_Defaults(), -- Retribution Aura (Rank 2)
		[10299]	= UF:FilterList_Defaults(), -- Retribution Aura (Rank 3)
		[10300]	= UF:FilterList_Defaults(), -- Retribution Aura (Rank 4)
		[10301]	= UF:FilterList_Defaults(), -- Retribution Aura (Rank 5)
		[19876]	= UF:FilterList_Defaults(), -- Shadow Resistance Aura (Rank 1)
		[19895]	= UF:FilterList_Defaults(), -- Shadow Resistance Aura (Rank 2)
		[19896]	= UF:FilterList_Defaults(), -- Shadow Resistance Aura (Rank 3)
		[19888]	= UF:FilterList_Defaults(), -- Frost Resistance Aura (Rank 1)
		[19897]	= UF:FilterList_Defaults(), -- Frost Resistance Aura (Rank 2)
		[19898]	= UF:FilterList_Defaults(), -- Frost Resistance Aura (Rank 3)
		[19891]	= UF:FilterList_Defaults(), -- Fire Resistance Aura (Rank 1)
		[19899]	= UF:FilterList_Defaults(), -- Fire Resistance Aura (Rank 2)
		[19900]	= UF:FilterList_Defaults(), -- Fire Resistance Aura (Rank 3)
		[498]	= UF:FilterList_Defaults(), -- Divine Protection (Rank 1)
		[5573]	= UF:FilterList_Defaults(), -- Divine Protection (Rank 2)
		[642]	= UF:FilterList_Defaults(), -- Divine Shield (Rank 1)
		[1020]	= UF:FilterList_Defaults(), -- Divine Shield (Rank 2)
		[1022]	= UF:FilterList_Defaults(), -- Blessing of Protection (Rank 1)
		[5599]	= UF:FilterList_Defaults(), -- Blessing of Protection (Rank 2)
		[10278]	= UF:FilterList_Defaults(), -- Blessing of Protection (Rank 3)
		[6940]	= UF:FilterList_Defaults(), -- Blessing of Sacrifice (Rank 1)
		[20729]	= UF:FilterList_Defaults(), -- Blessing of Sacrifice (Rank 2)
		[20216]	= UF:FilterList_Defaults(), -- Divine Favor
	--Priest
		[15473]	= UF:FilterList_Defaults(), -- Shadowform
		[10060]	= UF:FilterList_Defaults(), -- Power Infusion
		[14751]	= UF:FilterList_Defaults(), -- Inner Focus
		[1706]	= UF:FilterList_Defaults(), -- Levitate
		[586]	= UF:FilterList_Defaults(), -- Fade (Rank 1)
		[9578]	= UF:FilterList_Defaults(), -- Fade (Rank 2)
		[9579]	= UF:FilterList_Defaults(), -- Fade (Rank 3)
		[9592]	= UF:FilterList_Defaults(), -- Fade (Rank 4)
		[10941]	= UF:FilterList_Defaults(), -- Fade (Rank 5)
		[10942]	= UF:FilterList_Defaults(), -- Fade (Rank 6)
	--Rogue
		[14177]	= UF:FilterList_Defaults(), -- Cold Blood
		[13877]	= UF:FilterList_Defaults(), -- Blade Flurry
		[13750]	= UF:FilterList_Defaults(), -- Adrenaline Rush
		[2983]	= UF:FilterList_Defaults(), -- Sprint (Rank 1)
		[8696]	= UF:FilterList_Defaults(), -- Sprint (Rank 2)
		[11305]	= UF:FilterList_Defaults(), -- Sprint (Rank 3)
		[5171]	= UF:FilterList_Defaults(), -- Slice and Dice (Rank 1)
		[6774]	= UF:FilterList_Defaults(), -- Slice and Dice (Rank 2)
		[5277]	= UF:FilterList_Defaults(), -- Evasion
		[1856]	= UF:FilterList_Defaults(), -- Vanish (Rank 1)
		[1857]	= UF:FilterList_Defaults(), -- Vanish (Rank 2)
	--Shaman
		[2645]	= UF:FilterList_Defaults(), -- Ghost Wolf
		[324]	= UF:FilterList_Defaults(), -- Lightning Shield (Rank 1)
		[325]	= UF:FilterList_Defaults(), -- Lightning Shield (Rank 2)
		[905]	= UF:FilterList_Defaults(), -- Lightning Shield (Rank 3)
		[945]	= UF:FilterList_Defaults(), -- Lightning Shield (Rank 4)
		[8134]	= UF:FilterList_Defaults(), -- Lightning Shield (Rank 5)
		[10431]	= UF:FilterList_Defaults(), -- Lightning Shield (Rank 6)
		[10432]	= UF:FilterList_Defaults(), -- Lightning Shield (Rank 7)
		[16188]	= UF:FilterList_Defaults(), -- Nature's Swiftness
		[16166]	= UF:FilterList_Defaults(), -- Elemental Mastery
		[8178]	= UF:FilterList_Defaults(), -- Grounding Totem Effect
		[16191]	= UF:FilterList_Defaults(), -- Mana Tide (Rank 1)
		[17355]	= UF:FilterList_Defaults(), -- Mana Tide (Rank 2)
		[17360]	= UF:FilterList_Defaults(), -- Mana Tide (Rank 3)
	--Warlock
		[18789]	= UF:FilterList_Defaults(), -- Demonic Sacrifice (Burning Wish)
		[18790]	= UF:FilterList_Defaults(), -- Demonic Sacrifice (Fel Stamina)
		[18791]	= UF:FilterList_Defaults(), -- Demonic Sacrifice (Touch of Shadow)
		[18792]	= UF:FilterList_Defaults(), -- Demonic Sacrifice (Fel Energy)
		[5697]	= UF:FilterList_Defaults(), -- Unending Breath
		[6512]	= UF:FilterList_Defaults(), -- Detect Lesser Invisibility
		[2970]	= UF:FilterList_Defaults(), -- Detect Invisibility
		[11743]	= UF:FilterList_Defaults(), -- Detect Greater Invisibility
		[25228]	= UF:FilterList_Defaults(), -- Soul Link
		[18708]	= UF:FilterList_Defaults(), -- Fel Domination
	--Warrior
		[12975]	= UF:FilterList_Defaults(), -- Last Stand
		[871]	= UF:FilterList_Defaults(), -- Shield Wall
		[20230]	= UF:FilterList_Defaults(), -- Retaliation
		[1719]	= UF:FilterList_Defaults(), -- Recklessness
		[18499]	= UF:FilterList_Defaults(), -- Berserker Rage
		[2687]	= UF:FilterList_Defaults(), -- Bloodrage
		[12328]	= UF:FilterList_Defaults(), -- Death Wish
		[12292]	= UF:FilterList_Defaults(), -- Sweeping Strikes
		[2565]	= UF:FilterList_Defaults(), -- Shield Block
		[12880]	= UF:FilterList_Defaults(), -- Enrage (Rank 1)
		[14201]	= UF:FilterList_Defaults(), -- Enrage (Rank 2)
		[14202]	= UF:FilterList_Defaults(), -- Enrage (Rank 3)
		[14203]	= UF:FilterList_Defaults(), -- Enrage (Rank 4)
		[14204]	= UF:FilterList_Defaults(), -- Enrage (Rank 5)
	-- Consumables
		[3169]	= UF:FilterList_Defaults(), -- Limited Invulnerability Potion
		[6615]	= UF:FilterList_Defaults(), -- Free Action Potion
	-- Racial
		[20554]	= UF:FilterList_Defaults(), -- Berserking (Mana)
		[26296]	= UF:FilterList_Defaults(), -- Berserking (Rage)
		[26297]	= UF:FilterList_Defaults(), -- Berserking (Energy)
		[7744]	= UF:FilterList_Defaults(), -- Will of the Forsaken
		[20572]	= UF:FilterList_Defaults(), -- Blood Fury (Physical)
		[33697]	= UF:FilterList_Defaults(), -- Blood Fury (Both)
		[33702]	= UF:FilterList_Defaults(), -- Blood Fury (Spell)
		[6346]	= UF:FilterList_Defaults(), -- Fear Ward
		[20594]	= UF:FilterList_Defaults(), -- Stoneform
	-- All Classes
		[19753]	= UF:FilterList_Defaults(), -- Divine Intervention
	},
}

-- Buffs that we don't really need to see
G.unitframe.aurafilters.Blacklist = {
	type = 'Blacklist',
	spells = {
	--Seasonal
		[362859] = UF:FilterList_Defaults(), -- Adventure Awaits "Quest experience increased by 100%."
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
		[744]	= UF:FilterList_Defaults(2), -- Poison
		[18267] = UF:FilterList_Defaults(2), -- Curse of Weakness
		[20800] = UF:FilterList_Defaults(2), -- Immolate
		[246]	= UF:FilterList_Defaults(2), -- Slow
		[6533]	= UF:FilterList_Defaults(2), -- Net
		[8399]	= UF:FilterList_Defaults(2), -- Sleep
	-- Blackrock Depths
		[13704] = UF:FilterList_Defaults(2), -- Psychic Scream
	-- Deadmines
		[6304]	= UF:FilterList_Defaults(2), -- Rhahk'Zor Slam
		[12097] = UF:FilterList_Defaults(2), -- Pierce Armor
		[7399]	= UF:FilterList_Defaults(2), -- Terrify
		[6713]	= UF:FilterList_Defaults(2), -- Disarm
		[5213]	= UF:FilterList_Defaults(2), -- Molten Metal
		[5208]	= UF:FilterList_Defaults(2), -- Poisoned Harpoon
	-- Maraudon
		[7964]	= UF:FilterList_Defaults(2), -- Smoke Bomb
		[21869] = UF:FilterList_Defaults(2), -- Repulsive Gaze
	-- Razorfen Downs
		[12255]	= UF:FilterList_Defaults(2), -- Curse of Tuten'kash
		[12252]	= UF:FilterList_Defaults(2), -- Web Spray
		[7645]	= UF:FilterList_Defaults(2), -- Dominate Mind
		[12946]	= UF:FilterList_Defaults(2), -- Putrid Stench
	-- Razorfen Kraul
		[14515]	= UF:FilterList_Defaults(2), -- Dominate Mind
	-- Scarlet Monastry
		[9034]	= UF:FilterList_Defaults(2), -- Immolate
		[8814]	= UF:FilterList_Defaults(2), -- Flame Spike
		[8988]	= UF:FilterList_Defaults(2), -- Silence
		[9256]	= UF:FilterList_Defaults(2), -- Deep Sleep
		[8282]	= UF:FilterList_Defaults(2), -- Curse of Blood
	-- Shadowfang Keep
		[7068]	= UF:FilterList_Defaults(2), -- Veil of Shadow
		[7125]	= UF:FilterList_Defaults(2), -- Toxic Saliva
		[7621]	= UF:FilterList_Defaults(2), -- Arugal's Curse
	--Stratholme
		[16798] = UF:FilterList_Defaults(2), -- Enchanting Lullaby
		[12734] = UF:FilterList_Defaults(2), -- Ground Smash
		[17293] = UF:FilterList_Defaults(2), -- Burning Winds
		[17405] = UF:FilterList_Defaults(2), -- Domination
		[16867] = UF:FilterList_Defaults(2), -- Banshee Curse
		[6016]	= UF:FilterList_Defaults(2), -- Pierce Armor
		[16869] = UF:FilterList_Defaults(2), -- Ice Tomb
		[17307] = UF:FilterList_Defaults(2), -- Knockout
	-- Sunken Temple
		[12889] = UF:FilterList_Defaults(2), -- Curse of Tongues
		[12888] = UF:FilterList_Defaults(2), -- Cause Insanity
		[12479] = UF:FilterList_Defaults(2), -- Hex of Jammal'an
		[12493] = UF:FilterList_Defaults(2), -- Curse of Weakness
		[12890] = UF:FilterList_Defaults(2), -- Deep Slumber
		[24375] = UF:FilterList_Defaults(2), -- War Stomp
	-- Uldaman
		[3356]	= UF:FilterList_Defaults(2), -- Flame Lash
		[6524]	= UF:FilterList_Defaults(2), -- Ground Tremor
	-- Wailing Caverns
		[8040]	= UF:FilterList_Defaults(2), -- Druid's Slumber
		[8142]	= UF:FilterList_Defaults(2), -- Grasping Vines
		[7967]	= UF:FilterList_Defaults(2), -- Naralex's Nightmare
		[8150]	= UF:FilterList_Defaults(2), -- Thundercrack
	-- Zul'Farrak
		[11836] = UF:FilterList_Defaults(2), -- Freeze Solid
	-- World Bosses
		[21056] = UF:FilterList_Defaults(2), -- Mark of Kazzak
		[24814] = UF:FilterList_Defaults(2), -- Seeping Fog
	----------------------------------------------------------
	-------------------------- PvP ---------------------------
	----------------------------------------------------------
	[43680] = UF:FilterList_Defaults(6), -- Idle (Reported for AFK)
	----------------------------------------------------------
	----------------------------------------------------------
	--------------------- Onyxia's Lair ----------------------
	----------------------------------------------------------
	[18431] = UF:FilterList_Defaults(2), -- Bellowing Roar
	----------------------------------------------------------
	---------------------- Molten Core -----------------------
	----------------------------------------------------------
	[19703] = UF:FilterList_Defaults(5), -- Lucifron's Curse
	[19408] = UF:FilterList_Defaults(2), -- Panic
	[19716] = UF:FilterList_Defaults(3), -- Gehennas' Curse
	[20475] = UF:FilterList_Defaults(6), -- Living Bomb
	[19695] = UF:FilterList_Defaults(3), -- Inferno
	[19713] = UF:FilterList_Defaults(5), -- Shazzrah's Curse
	[20277] = UF:FilterList_Defaults(2), -- Fist of Ragnaros
	[19659] = UF:FilterList_Defaults(2), -- Ignite Mana
	[19714] = UF:FilterList_Defaults(2), -- Deaden Magic
	----------------------------------------------------------
	--------------------- Blackwing Lair ---------------------
	----------------------------------------------------------
	[23023]	= UF:FilterList_Defaults(2), -- Conflagration
	[18173]	= UF:FilterList_Defaults(2), -- Burning Adrenaline
	[24573]	= UF:FilterList_Defaults(2), -- Mortal Strike
	[23340]	= UF:FilterList_Defaults(2), -- Shadow of Ebonroc
	[23170]	= UF:FilterList_Defaults(2), -- Brood Affliction: Bronze
	[22687]	= UF:FilterList_Defaults(2), -- Veil of Shadow
	----------------------------------------------------------
	------------------------ Zul'Gurub -----------------------
	----------------------------------------------------------
	[23860]	= UF:FilterList_Defaults(2), -- Holy Fire
	[22884]	= UF:FilterList_Defaults(2), -- Psychic Scream
	[23918]	= UF:FilterList_Defaults(2), -- Sonic Burst
	[24111]	= UF:FilterList_Defaults(2), -- Corrosive Poison
	[21060]	= UF:FilterList_Defaults(2), -- Blind
	[24328]	= UF:FilterList_Defaults(2), -- Corrupted Blood
	[16856]	= UF:FilterList_Defaults(2), -- Mortal Strike
	[24664]	= UF:FilterList_Defaults(2), -- Sleep
	[17172]	= UF:FilterList_Defaults(2), -- Hex
	[24306]	= UF:FilterList_Defaults(2), -- Delusions of Jin'do
	[24099]	= UF:FilterList_Defaults(2), -- Poison Bolt Volley
	----------------------------------------------------------
	--------------------- Ahn'Qiraj Ruins --------------------
	----------------------------------------------------------
	[25646]	= UF:FilterList_Defaults(2), -- Mortal Wound
	[25471]	= UF:FilterList_Defaults(2), -- Attack Order
	[96]	= UF:FilterList_Defaults(2), -- Dismember
	[25725]	= UF:FilterList_Defaults(2), -- Paralyze
	[25189]	= UF:FilterList_Defaults(2), -- Enveloping Winds
	----------------------------------------------------------
	--------------------- Ahn'Qiraj Temple -------------------
	----------------------------------------------------------
	[785]	= UF:FilterList_Defaults(2), -- True Fulfillment
	[26580]	= UF:FilterList_Defaults(2), -- Fear
	[26050]	= UF:FilterList_Defaults(2), -- Acid Spit
	[26180]	= UF:FilterList_Defaults(2), -- Wyvern Sting
	[26053]	= UF:FilterList_Defaults(2), -- Noxious Poison
	[26613]	= UF:FilterList_Defaults(2), -- Unbalancing Strike
	[26029]	= UF:FilterList_Defaults(2), -- Dark Glare
	----------------------------------------------------------
	------------------------ Naxxramas -----------------------
	----------------------------------------------------------
	[28732]	= UF:FilterList_Defaults(2), -- Widow's Embrace
	[28622]	= UF:FilterList_Defaults(2), -- Web Wrap
	[28169]	= UF:FilterList_Defaults(2), -- Mutating Injection
	[29213]	= UF:FilterList_Defaults(2), -- Curse of the Plaguebringer
	[28835]	= UF:FilterList_Defaults(2), -- Mark of Zeliek
	[27808]	= UF:FilterList_Defaults(2), -- Frost Blast
	[28410]	= UF:FilterList_Defaults(2), -- Chains of Kel'Thuzad
	[27819]	= UF:FilterList_Defaults(2), -- Detonate Mana
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
	[19451] = UF:FilterList_Defaults(), -- Frenzy
	[19714] = UF:FilterList_Defaults(), -- Deaden Magic
	[19516] = UF:FilterList_Defaults(), -- Enrage
	[19695] = UF:FilterList_Defaults(), -- Inferno
	[20478] = UF:FilterList_Defaults(), -- Armageddon
	[19779] = UF:FilterList_Defaults(), -- Inspire
	[20620] = UF:FilterList_Defaults(), -- Aegis of Ragnaros
	[21075] = UF:FilterList_Defaults(), -- Damage Shield
	[20619] = UF:FilterList_Defaults(), -- Magic Reflection
	----------------------------------------------------------
	------------------------ Zul'Gurub -----------------------
	----------------------------------------------------------
	[23895] = UF:FilterList_Defaults(), -- Renew
	},
}

G.unitframe.aurawatch = {
	GLOBAL = {},
	DRUID = {
		[1126]	= UF:AuraWatch_AddSpell(1126, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 1)
		[5232]	= UF:AuraWatch_AddSpell(5232, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 2)
		[6756]	= UF:AuraWatch_AddSpell(6756, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 3)
		[5234]	= UF:AuraWatch_AddSpell(5234, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 4)
		[8907]	= UF:AuraWatch_AddSpell(8907, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 5)
		[9884]	= UF:AuraWatch_AddSpell(9884, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 6)
		[9885]	= UF:AuraWatch_AddSpell(9885, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Mark of the Wild (Rank 7)
		[21849]	= UF:AuraWatch_AddSpell(21849, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 1)
		[21850]	= UF:AuraWatch_AddSpell(21850, 'TOPLEFT', {0.2, 0.8, 0.8}, true),	-- Gift of the Wild (Rank 2)
		[467]	= UF:AuraWatch_AddSpell(467, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 1)
		[782]	= UF:AuraWatch_AddSpell(782, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 2)
		[1075]	= UF:AuraWatch_AddSpell(1075, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 3)
		[8914]	= UF:AuraWatch_AddSpell(8914, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 4)
		[9756]	= UF:AuraWatch_AddSpell(9756, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 5)
		[9910]	= UF:AuraWatch_AddSpell(9910, 'TOPRIGHT', {0.4, 0.2, 0.8}, true),	-- Thorns (Rank 6)
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
		[8936]	= UF:AuraWatch_AddSpell(8936, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 1)
		[8938]	= UF:AuraWatch_AddSpell(8938, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 2)
		[8939]	= UF:AuraWatch_AddSpell(8939, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 3)
		[8940]	= UF:AuraWatch_AddSpell(8940, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 4)
		[8941]	= UF:AuraWatch_AddSpell(8941, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 5)
		[9750]	= UF:AuraWatch_AddSpell(9750, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 6)
		[9856]	= UF:AuraWatch_AddSpell(9856, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 7)
		[9857]	= UF:AuraWatch_AddSpell(9857, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 8)
		[9858]	= UF:AuraWatch_AddSpell(9858, 'BOTTOMRIGHT', {0.33, 0.73, 0.75}),	-- Regrowth (Rank 9)
		[29166]	= UF:AuraWatch_AddSpell(29166, 'CENTER', {0.49, 0.60, 0.55}, true),	-- Innervate
	},
	HUNTER = {
		[19506]	= UF:AuraWatch_AddSpell(19506, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 1)
		[20905]	= UF:AuraWatch_AddSpell(20905, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 2)
		[20906]	= UF:AuraWatch_AddSpell(20906, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 3)
		[13159]	= UF:AuraWatch_AddSpell(13159, 'BOTTOMLEFT', {0.00, 0.00, 0.85}),	-- Aspect of the Pack
		[20043]	= UF:AuraWatch_AddSpell(20043, 'BOTTOMLEFT', {0.33, 0.93, 0.79}),	-- Aspect of the Wild (Rank 1)
		[20190]	= UF:AuraWatch_AddSpell(20190, 'BOTTOMLEFT', {0.33, 0.93, 0.79}),	-- Aspect of the Wild (Rank 2)
	},
	MAGE = {
		[1459]	= UF:AuraWatch_AddSpell(1459, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 1)
		[1460]	= UF:AuraWatch_AddSpell(1460, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 2)
		[1461]	= UF:AuraWatch_AddSpell(1461, 'TOPLEFT', {0.89, 0.09, 0.05}, true),		-- Arcane Intellect (Rank 3)
		[10156]	= UF:AuraWatch_AddSpell(10156, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 4)
		[10157]	= UF:AuraWatch_AddSpell(10157, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Intellect (Rank 5)
		[23028]	= UF:AuraWatch_AddSpell(23028, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 1)
		[27127]	= UF:AuraWatch_AddSpell(27127, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Arcane Brilliance (Rank 2)
		[604]	= UF:AuraWatch_AddSpell(604, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 1)
		[8450]	= UF:AuraWatch_AddSpell(8450, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 2)
		[8451]	= UF:AuraWatch_AddSpell(8451, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 3)
		[10173]	= UF:AuraWatch_AddSpell(10173, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 4)
		[10174]	= UF:AuraWatch_AddSpell(10174, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Dampen Magic (Rank 5)
		[1008]	= UF:AuraWatch_AddSpell(1008, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 1)
		[8455]	= UF:AuraWatch_AddSpell(8455, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 2)
		[10169]	= UF:AuraWatch_AddSpell(10169, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 3)
		[10170]	= UF:AuraWatch_AddSpell(10170, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),		-- Amplify Magic (Rank 4)
		[130]	= UF:AuraWatch_AddSpell(130, 'CENTER', {0.00, 0.00, 0.50}, true),		-- Slow Fall
	},
	PALADIN = {
		[1044]	= UF:AuraWatch_AddSpell(1044, 'CENTER', {0.89, 0.45, 0}),					-- Blessing of Freedom
		[6940]	= UF:AuraWatch_AddSpell(6940, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing of Sacrifice (Rank 1)
		[20729]	= UF:AuraWatch_AddSpell(20729, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing of Sacrifice (Rank 2)
		[19740]	= UF:AuraWatch_AddSpell(19740, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 1)
		[19834]	= UF:AuraWatch_AddSpell(19834, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 2)
		[19835]	= UF:AuraWatch_AddSpell(19835, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 3)
		[19836]	= UF:AuraWatch_AddSpell(19836, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 4)
		[19837]	= UF:AuraWatch_AddSpell(19837, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 5)
		[19838]	= UF:AuraWatch_AddSpell(19838, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 6)
		[25291]	= UF:AuraWatch_AddSpell(25291, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Might (Rank 7)
		[19742]	= UF:AuraWatch_AddSpell(19742, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 1)
		[19850]	= UF:AuraWatch_AddSpell(19850, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 2)
		[19852]	= UF:AuraWatch_AddSpell(19852, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 3)
		[19853]	= UF:AuraWatch_AddSpell(19853, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 4)
		[19854]	= UF:AuraWatch_AddSpell(19854, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 5)
		[25290]	= UF:AuraWatch_AddSpell(25290, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Blessing of Wisdom (Rank 6)
		[25782]	= UF:AuraWatch_AddSpell(25782, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 1)
		[25916]	= UF:AuraWatch_AddSpell(25916, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Might (Rank 2)
		[25894]	= UF:AuraWatch_AddSpell(25894, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 1)
		[25918]	= UF:AuraWatch_AddSpell(25918, 'TOPLEFT', {0.2, 0.8, 0.2}, true),			-- Greater Blessing of Wisdom (Rank 2)
		[465]	= UF:AuraWatch_AddSpell(465, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 1)
		[10290]	= UF:AuraWatch_AddSpell(10290, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 2)
		[643]	= UF:AuraWatch_AddSpell(643, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),				-- Devotion Aura (Rank 3)
		[10291]	= UF:AuraWatch_AddSpell(10291, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 4)
		[1032]	= UF:AuraWatch_AddSpell(1032, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 5)
		[10292]	= UF:AuraWatch_AddSpell(10292, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 6)
		[10293]	= UF:AuraWatch_AddSpell(10293, 'BOTTOMLEFT', {0.58, 1.00, 0.50}),			-- Devotion Aura (Rank 7)
		[19977]	= UF:AuraWatch_AddSpell(19977, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 1)
		[19978]	= UF:AuraWatch_AddSpell(19978, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 2)
		[19979]	= UF:AuraWatch_AddSpell(19979, 'BOTTOMRIGHT', {0.17, 1.00, 0.75}, true),	-- Blessing of Light (Rank 3)
		[1022]	= UF:AuraWatch_AddSpell(1022, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 1)
		[5599]	= UF:AuraWatch_AddSpell(5599, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 2)
		[10278]	= UF:AuraWatch_AddSpell(10278, 'TOPRIGHT', {0.17, 1.00, 0.75}, true),		-- Blessing of Protection (Rank 3)
		[19746]	= UF:AuraWatch_AddSpell(19746, 'BOTTOMLEFT', {0.83, 1.00, 0.07}),			-- Concentration Aura
	},
	PRIEST = {
		[1243]	= UF:AuraWatch_AddSpell(1243, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 1)
		[1244]	= UF:AuraWatch_AddSpell(1244, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 2)
		[1245]	= UF:AuraWatch_AddSpell(1245, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 3)
		[2791]	= UF:AuraWatch_AddSpell(2791, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 4)
		[10937]	= UF:AuraWatch_AddSpell(10937, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 5)
		[10938]	= UF:AuraWatch_AddSpell(10938, 'TOPLEFT', {1, 1, 0.66}, true),			-- Power Word: Fortitude (Rank 6)
		[21562]	= UF:AuraWatch_AddSpell(21562, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 1)
		[21564]	= UF:AuraWatch_AddSpell(21564, 'TOPLEFT', {1, 1, 0.66}, true),			-- Prayer of Fortitude (Rank 2)
		[14752]	= UF:AuraWatch_AddSpell(14752, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 1)
		[14818]	= UF:AuraWatch_AddSpell(14818, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 2)
		[14819]	= UF:AuraWatch_AddSpell(14819, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 3)
		[27841]	= UF:AuraWatch_AddSpell(27841, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Divine Spirit (Rank 4)
		[27681]	= UF:AuraWatch_AddSpell(27681, 'TOPRIGHT', {0.2, 0.7, 0.2}, true),		-- Prayer of Spirit (Rank 1)
		[976]	= UF:AuraWatch_AddSpell(976, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),		-- Shadow Protection (Rank 1)
		[10957]	= UF:AuraWatch_AddSpell(10957, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 2)
		[10958]	= UF:AuraWatch_AddSpell(10958, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Shadow Protection (Rank 3)
		[27683]	= UF:AuraWatch_AddSpell(27683, 'BOTTOMLEFT', {0.7, 0.7, 0.7}, true),	-- Prayer of Shadow Protection (Rank 1)
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
	},
	ROGUE = {}, -- No buffs
	SHAMAN = {
		[29203]	= UF:AuraWatch_AddSpell(29203, 'TOPRIGHT', {0.7, 0.3, 0.7}),		-- Healing Way
		[16237]	= UF:AuraWatch_AddSpell(16237, 'RIGHT', {0.2, 0.2, 1}),				-- Ancestral Fortitude
		[25909]	= UF:AuraWatch_AddSpell(25909, 'TOP', {0.00, 0.00, 0.50}),			-- Tranquil Air
		[8185]	= UF:AuraWatch_AddSpell(8185, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 1)
		[10534]	= UF:AuraWatch_AddSpell(10534, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 2)
		[10535]	= UF:AuraWatch_AddSpell(10535, 'TOPLEFT', {0.05, 1.00, 0.50}),		-- Fire Resistance Totem (Rank 3)
		[8182]	= UF:AuraWatch_AddSpell(8182, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 1)
		[10476]	= UF:AuraWatch_AddSpell(10476, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 2)
		[10477]	= UF:AuraWatch_AddSpell(10477, 'TOPLEFT', {0.54, 0.53, 0.79}),		-- Frost Resistance Totem (Rank 3)
		[10596]	= UF:AuraWatch_AddSpell(10596, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 1)
		[10598]	= UF:AuraWatch_AddSpell(10598, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 2)
		[10599]	= UF:AuraWatch_AddSpell(10599, 'TOPLEFT', {0.33, 1.00, 0.20}),		-- Nature Resistance Totem (Rank 3)
		[5672]	= UF:AuraWatch_AddSpell(5672, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 1)
		[6371]	= UF:AuraWatch_AddSpell(6371, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 2)
		[6372]	= UF:AuraWatch_AddSpell(6372, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 3)
		[10460]	= UF:AuraWatch_AddSpell(10460, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 4)
		[10461]	= UF:AuraWatch_AddSpell(10461, 'BOTTOM', {0.67, 1.00, 0.50}),		-- Healing Stream Totem (Rank 5)
		[16191]	= UF:AuraWatch_AddSpell(16191, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 1)
		[17355]	= UF:AuraWatch_AddSpell(17355, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 2)
		[17360]	= UF:AuraWatch_AddSpell(17360, 'BOTTOMLEFT', {0.67, 1.00, 0.80}),	-- Mana Tide Totem (Rank 3)
		[5677]	= UF:AuraWatch_AddSpell(5677, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 1)
		[10491]	= UF:AuraWatch_AddSpell(10491, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 2)
		[10493]	= UF:AuraWatch_AddSpell(10493, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 3)
		[10494]	= UF:AuraWatch_AddSpell(10494, 'LEFT', {0.67, 1.00, 0.80}),			-- Mana Spring Totem (Rank 4)
		[8072]	= UF:AuraWatch_AddSpell(8072, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 1)
		[8156]	= UF:AuraWatch_AddSpell(8156, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 2)
		[8157]	= UF:AuraWatch_AddSpell(8157, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 3)
		[10403]	= UF:AuraWatch_AddSpell(10403, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 4)
		[10404]	= UF:AuraWatch_AddSpell(10404, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 5)
		[10405]	= UF:AuraWatch_AddSpell(10405, 'BOTTOMRIGHT', {0.00, 0.00, 0.26}),	-- Stoneskin Totem (Rank 6)
	},
	WARLOCK = {
		[5697]	= UF:AuraWatch_AddSpell(5697, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Unending Breath
		[6512]	= UF:AuraWatch_AddSpell(6512, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Lesser Invisibility
		[2970]	= UF:AuraWatch_AddSpell(2970, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Invisibility
		[11743]	= UF:AuraWatch_AddSpell(11743, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Greater Invisibility
	},
	WARRIOR = {
		[6673]	= UF:AuraWatch_AddSpell(6673, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 1)
		[5242]	= UF:AuraWatch_AddSpell(5242, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 2)
		[6192]	= UF:AuraWatch_AddSpell(6192, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 3)
		[11549]	= UF:AuraWatch_AddSpell(11549, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 4)
		[11550]	= UF:AuraWatch_AddSpell(11550, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 5)
		[11551]	= UF:AuraWatch_AddSpell(11551, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 6)
		[25289]	= UF:AuraWatch_AddSpell(25289, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 7)
	},
	PET = {
	--Warlock Imp
		[6307]	= UF:AuraWatch_AddSpell(6307, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 1)
		[7804]	= UF:AuraWatch_AddSpell(7804, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 2)
		[7805]	= UF:AuraWatch_AddSpell(7805, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 3)
		[11766]	= UF:AuraWatch_AddSpell(11766, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 4)
		[11767]	= UF:AuraWatch_AddSpell(11767, 'BOTTOMLEFT', {0.89, 0.09, 0.05}),	-- Blood Pact (Rank 5)
	--Warlock Felhunter
		[19480]	= UF:AuraWatch_AddSpell(19480, 'BOTTOMLEFT', {0.2, 0.8, 0.2}),	-- Paranoia
	--Hunter Pets
		[24604]	= UF:AuraWatch_AddSpell(24604, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 1)
		[24605]	= UF:AuraWatch_AddSpell(24605, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 2)
		[24603]	= UF:AuraWatch_AddSpell(24603, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 3)
		[24597]	= UF:AuraWatch_AddSpell(24597, 'TOPRIGHT', {0.08, 0.59, 0.41}),	-- Furious Howl (Rank 4)
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

local checkTicks = CreateFrame('Frame')
checkTicks:RegisterEvent('PLAYER_ENTERING_WORLD')
checkTicks:SetScript('OnEvent', function()
	if E.myclass == 'PRIEST' then
		E.global.unitframe.ChannelTicks[47540]	= (IsPlayerSpell(193134) and 4 or 3) --Penance
	end
end)

G.unitframe.ChannelTicksSize = {}

-- Spells Effected By Haste
G.unitframe.HastedChannelTicks = {}

G.unitframe.TalentChannelTicks = {}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {}

G.unitframe.AuraHighlightColors = {
	[25771]	= {enable = false, style = 'FILL', color = {r = 0.85, g = 0, b = 0, a = 0.85}},
}
