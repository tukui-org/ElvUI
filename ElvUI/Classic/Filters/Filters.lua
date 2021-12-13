local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local strfind, unpack = strfind, unpack

local IsPlayerSpell = IsPlayerSpell
local GetSpellSubtext = GetSpellSubtext
local GetSpellInfo = GetSpellInfo

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
	--Druid
		[339]	= Defaults(1), -- Entangling Roots (Rank 1)
		[1062]	= Defaults(1), -- Entangling Roots (Rank 2)
		[5195]	= Defaults(1), -- Entangling Roots (Rank 3)
		[5196]	= Defaults(1), -- Entangling Roots (Rank 4)
		[9852]	= Defaults(1), -- Entangling Roots (Rank 5)
		[9853]	= Defaults(1), -- Entangling Roots (Rank 6)
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
	--Hunter
		[1499]	= Defaults(3), -- Freezing Trap (Rank 1)
		[14310]	= Defaults(3), -- Freezing Trap (Rank 2)
		[14311]	= Defaults(3), -- Freezing Trap (Rank 3)
		[13809]	= Defaults(1), -- Frost Trap
		[19503]	= Defaults(4), -- Scatter Shot
		[5116]	= Defaults(2), -- Concussive Shot
		[297]	= Defaults(2), -- Wing Clip (Rank 1)
		[14267]	= Defaults(2), -- Wing Clip (Rank 2)
		[14268]	= Defaults(2), -- Wing Clip (Rank 3)
		[1513]	= Defaults(2), -- Scare Beast (Rank 1)
		[14326]	= Defaults(2), -- Scare Beast (Rank 2)
		[14327]	= Defaults(2), -- Scare Beast (Rank 3)
		[24394]	= Defaults(6), -- Intimidation
		[19386]	= Defaults(2), -- Wyvern Sting (Rank 1)
		[24132]	= Defaults(2), -- Wyvern Sting (Rank 2)
		[24133]	= Defaults(2), -- Wyvern Sting (Rank 3)
		[19229]	= Defaults(2), -- Improved Wing Clip
		[19306]	= Defaults(2), -- Counterattack (Rank 1)
		[20909]	= Defaults(2), -- Counterattack (Rank 2)
		[20910]	= Defaults(2), -- Counterattack (Rank 3)
	--Mage
		[118]	= Defaults(3), -- Polymorph (Rank 1)
		[12824]	= Defaults(3), -- Polymorph (Rank 2)
		[12825]	= Defaults(3), -- Polymorph (Rank 3)
		[12826]	= Defaults(3), -- Polymorph (Rank 4)
		[122]	= Defaults(1), -- Frost Nova (Rank 1)
		[865]	= Defaults(1), -- Frost Nova (Rank 2)
		[6131]	= Defaults(1), -- Frost Nova (Rank 3)
		[10230]	= Defaults(1), -- Frost Nova (Rank 4)
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
		[12355]	= Defaults(2), -- Impact
	--Paladin
		[853]	= Defaults(3), -- Hammer of Justice (Rank 1)
		[5588]	= Defaults(3), -- Hammer of Justice (Rank 2)
		[5589]	= Defaults(3), -- Hammer of Justice (Rank 3)
		[10308]	= Defaults(3), -- Hammer of Justice (Rank 4)
		[20066]	= Defaults(3), -- Repentance
	--Priest
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
	--Rogue
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
		[5530]	= Defaults(2), -- Mace Stun Effect
	--Shaman
		[2484]	= Defaults(1), -- Earthbind Totem
		[8056]	= Defaults(2), -- Frost Shock (Rank 1)
		[8058]	= Defaults(2), -- Frost Shock (Rank 2)
		[10472]	= Defaults(2), -- Frost Shock (Rank 3)
		[10473]	= Defaults(2), -- Frost Shock (Rank 4)
	--Warlock
		[5782]	= Defaults(3), -- Fear (Rank 1)
		[6213]	= Defaults(3), -- Fear (Rank 2)
		[6215]	= Defaults(3), -- Fear (Rank 3)
		[18223]	= Defaults(2), -- Curse of Exhaustion
		[18093]	= Defaults(2), -- Pyroclasm
		[710]	= Defaults(2), -- Banish (Rank 1)
		[18647]	= Defaults(2), -- Banish (Rank 2)
	--Warrior
		[5246]	= Defaults(4), -- Intimidating Shout
		[1715]	= Defaults(2), -- Hamstring (Rank 1)
		[7372]	= Defaults(2), -- Hamstring (Rank 2)
		[7373]	= Defaults(2), -- Hamstring (Rank 3)
		[12809]	= Defaults(2), -- Concussion Blow
		[20252]	= Defaults(2), -- Intercept (Rank 1)
		[20616]	= Defaults(2), -- Intercept (Rank 2)
		[20617]	= Defaults(2), -- Intercept (Rank 3)
	--Racial
		[20549]	= Defaults(2), -- War Stomp
	--Sunder Armor, Faerie Fire, Faerie Fire (Feral)
		[7386]	= Defaults(6), -- Sunder Armor (Rank 1)
		[7405]	= Defaults(6), -- Sunder Armor (Rank 2)
		[8380]	= Defaults(6), -- Sunder Armor (Rank 3)
		[11596]	= Defaults(6), -- Sunder Armor (Rank 4)
		[11597]	= Defaults(6), -- Sunder Armor (Rank 5)
		[770]	= Defaults(5), -- Faerie Fire (Rank 1)
		[778]	= Defaults(5), -- Faerie Fire (Rank 2)
		[9749]	= Defaults(5), -- Faerie Fire (Rank 3)
		[9907]	= Defaults(5), -- Faerie Fire (Rank 4)
		[16857]	= Defaults(5), -- Faerie Fire (Feral) (Rank 1)
		[17390]	= Defaults(5), -- Faerie Fire (Feral) (Rank 2)
		[17391]	= Defaults(5), -- Faerie Fire (Feral) (Rank 3)
		[17392]	= Defaults(5), -- Faerie Fire (Feral) (Rank 4)
	--Winter's Chill Debuff
		[12579]	= Defaults(5), -- Winter's Chill
	},
}

-- These are buffs that can be considered 'protection' buffs
G.unitframe.aurafilters.TurtleBuffs = {
	type = 'Whitelist',
	spells = {
	--Mage
		[11958]	= Defaults(2), -- Ice Block A
		[27619]	= Defaults(2), -- Ice Block B
	--Paladin
		[498]	= Defaults(2), -- Divine Protection (Rank 1)
		[5573]	= Defaults(2), -- Divine Protection (Rank 2)
		[642]	= Defaults(2), -- Divine Shield (Rank 1)
		[1020]	= Defaults(2), -- Divine Shield (Rank 2)
		[1022]	= Defaults(2), -- Blessing of Protection (Rank 1)
		[5599]	= Defaults(2), -- Blessing of Protection (Rank 2)
		[10278]	= Defaults(2), -- Blessing of Protection (Rank 3)
	--Consumables
		[3169]	= Defaults(2), -- Limited Invulnerability Potion
		[6615]	= Defaults(2), -- Free Action Potion
	--Racial
		[7744]	= Defaults(2), -- Will of the Forsaken
		[6346]	= Defaults(2), -- Fear Ward
		[20594]	= Defaults(2), -- Stoneform
	--All Classes
		[19753]	= Defaults(2), -- Divine Intervention
	},
}

--Default whitelist for player buffs, still WIP
G.unitframe.aurafilters.PlayerBuffs = {
	type = 'Whitelist',
	spells = {
	--Druid
		[29166]	= Defaults(), -- Innervate
		[22812]	= Defaults(), -- Barkskin
		[17116]	= Defaults(), -- Nature's Swiftness
		[16689]	= Defaults(), -- Nature's Grasp (Rank 1)
		[16810]	= Defaults(), -- Nature's Grasp (Rank 2)
		[16811]	= Defaults(), -- Nature's Grasp (Rank 3)
		[16812]	= Defaults(), -- Nature's Grasp (Rank 4)
		[16813]	= Defaults(), -- Nature's Grasp (Rank 5)
		[17329]	= Defaults(), -- Nature's Grasp (Rank 6)
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
	--Hunter
		[13161]	= Defaults(), -- Aspect of the Beast
		[5118]	= Defaults(), -- Aspect of the Cheetah
		[13163]	= Defaults(), -- Aspect of the Monkey
		[13159]	= Defaults(), -- Aspect of the Pack
		[20043]	= Defaults(), -- Aspect of the Wild (Rank 1)
		[20190]	= Defaults(), -- Aspect of the Wild (Rank 2)
		[3045]	= Defaults(), -- Rapid Fire
		[19263]	= Defaults(), -- Deterrence
		[13165]	= Defaults(), -- Aspect of the Hawk (Rank 1)
		[14318]	= Defaults(), -- Aspect of the Hawk (Rank 2)
		[14319]	= Defaults(), -- Aspect of the Hawk (Rank 3)
		[14320]	= Defaults(), -- Aspect of the Hawk (Rank 4)
		[14321]	= Defaults(), -- Aspect of the Hawk (Rank 5)
		[14322]	= Defaults(), -- Aspect of the Hawk (Rank 6)
		[25296]	= Defaults(), -- Aspect of the Hawk (Rank 7)
	--Mage
		[11958]	= Defaults(), -- Ice Block A
		[27619]	= Defaults(), -- Ice Block B
		[12043]	= Defaults(), -- Presence of Mind
		[11129]	= Defaults(), -- Combustion
		[12042]	= Defaults(), -- Arcane Power
		[11426]	= Defaults(), -- Ice Barrier (Rank 1)
		[13031]	= Defaults(), -- Ice Barrier (Rank 2)
		[13032]	= Defaults(), -- Ice Barrier (Rank 3)
		[13033]	= Defaults(), -- Ice Barrier (Rank 4)
	--Paladin
		[1044]	= Defaults(), -- Blessing of Freedom
		[1038]	= Defaults(), -- Blessing of Salvation
		[465]	= Defaults(), -- Devotion Aura (Rank 1)
		[10290]	= Defaults(), -- Devotion Aura (Rank 2)
		[643]	= Defaults(), -- Devotion Aura (Rank 3)
		[10291]	= Defaults(), -- Devotion Aura (Rank 4)
		[1032]	= Defaults(), -- Devotion Aura (Rank 5)
		[10292]	= Defaults(), -- Devotion Aura (Rank 6)
		[10293]	= Defaults(), -- Devotion Aura (Rank 7)
		[19746]	= Defaults(), -- Concentration Aura
		[7294]	= Defaults(), -- Retribution Aura (Rank 1)
		[10298]	= Defaults(), -- Retribution Aura (Rank 2)
		[10299]	= Defaults(), -- Retribution Aura (Rank 3)
		[10300]	= Defaults(), -- Retribution Aura (Rank 4)
		[10301]	= Defaults(), -- Retribution Aura (Rank 5)
		[19876]	= Defaults(), -- Shadow Resistance Aura (Rank 1)
		[19895]	= Defaults(), -- Shadow Resistance Aura (Rank 2)
		[19896]	= Defaults(), -- Shadow Resistance Aura (Rank 3)
		[19888]	= Defaults(), -- Frost Resistance Aura (Rank 1)
		[19897]	= Defaults(), -- Frost Resistance Aura (Rank 2)
		[19898]	= Defaults(), -- Frost Resistance Aura (Rank 3)
		[19891]	= Defaults(), -- Fire Resistance Aura (Rank 1)
		[19899]	= Defaults(), -- Fire Resistance Aura (Rank 2)
		[19900]	= Defaults(), -- Fire Resistance Aura (Rank 3)
	--Priest
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
	--Rogue
		[14177]	= Defaults(), -- Cold Blood
		[13877]	= Defaults(), -- Blade Flurry
		[13750]	= Defaults(), -- Adrenaline Rush
		[2983]	= Defaults(), -- Sprint (Rank 1)
		[8696]	= Defaults(), -- Sprint (Rank 2)
		[11305]	= Defaults(), -- Sprint (Rank 3)
		[5171]	= Defaults(), -- Slice and Dice (Rank 1)
		[6774]	= Defaults(), -- Slice and Dice (Rank 2)
	--Shaman
		[2645]	= Defaults(), -- Ghost Wolf
		[324]	= Defaults(), -- Lightning Shield (Rank 1)
		[325]	= Defaults(), -- Lightning Shield (Rank 2)
		[905]	= Defaults(), -- Lightning Shield (Rank 3)
		[945]	= Defaults(), -- Lightning Shield (Rank 4)
		[8134]	= Defaults(), -- Lightning Shield (Rank 5)
		[10431]	= Defaults(), -- Lightning Shield (Rank 6)
		[10432]	= Defaults(), -- Lightning Shield (Rank 7)
		[16188]	= Defaults(), -- Nature's Swiftness
		[16166]	= Defaults(), -- Elemental Mastery
	--Warlock
		[18788]	= Defaults(), -- Demonic Sacrifice
		[5697]	= Defaults(), -- Unending Breath
		[19028]	= Defaults(), -- Soul Link A
		[25228]	= Defaults(), -- Soul Link B
	--Warrior
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
	--Racial
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
	--Seasonal
	[362859] = Defaults(), -- Adventure Awaits "40% Increased Quest XP"
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
	-------------------------- PvP ---------------------------
	[43680] = Defaults(6), -- Idle (Reported for AFK)
	----------------------------------------------------------
	----------------------------------------------------------
	--------------------- Onyxia's Lair ----------------------
	----------------------------------------------------------
	[18431] = Defaults(2), -- Bellowing Roar
	----------------------------------------------------------
	---------------------- Molten Core -----------------------
	----------------------------------------------------------
	[19703] = Defaults(5), -- Lucifron's Curse
	[19408] = Defaults(2), -- Panic
	[19716] = Defaults(3), -- Gehennas' Curse
	[20475] = Defaults(6), -- Living Bomb
	[19695] = Defaults(3), -- Inferno
	[19713] = Defaults(5), -- Shazzrah's Curse
	[20277] = Defaults(2), -- Fist of Ragnaros
	[19659] = Defaults(2), -- Ignite Mana
	[19714] = Defaults(2), -- Deaden Magic
	----------------------------------------------------------
	--------------------- Blackwing Lair ---------------------
	----------------------------------------------------------
	[23023]	= Defaults(2), -- Conflagration
	[18173]	= Defaults(2), -- Burning Adrenaline
	[24573]	= Defaults(2), -- Mortal Strike
	[23340]	= Defaults(2), -- Shadow of Ebonroc
	[23170]	= Defaults(2), -- Brood Affliction: Bronze
	[22687]	= Defaults(2), -- Veil of Shadow
	----------------------------------------------------------
	------------------------ Zul'Gurub -----------------------
	----------------------------------------------------------
	[23860]	= Defaults(2), -- Holy Fire
	[22884]	= Defaults(2), -- Psychic Scream
	[23918]	= Defaults(2), -- Sonic Burst
	[24111]	= Defaults(2), -- Corrosive Poison
	[21060]	= Defaults(2), -- Blind
	[24328]	= Defaults(2), -- Corrupted Blood
	[16856]	= Defaults(2), -- Mortal Strike
	[24664]	= Defaults(2), -- Sleep
	[17172]	= Defaults(2), -- Hex
	[24306]	= Defaults(2), -- Delusions of Jin'do
	[24099]	= Defaults(2), -- Poison Bolt Volley
	----------------------------------------------------------
	--------------------- Ahn'Qiraj Ruins --------------------
	----------------------------------------------------------
	[25646]	= Defaults(2), -- Mortal Wound
	[25471]	= Defaults(2), -- Attack Order
	[96]	= Defaults(2), -- Dismember
	[25725]	= Defaults(2), -- Paralyze
	[25189]	= Defaults(2), -- Enveloping Winds
	----------------------------------------------------------
	--------------------- Ahn'Qiraj Temple -------------------
	----------------------------------------------------------
	[785]	= Defaults(2), -- True Fulfillment
	[26580]	= Defaults(2), -- Fear
	[26050]	= Defaults(2), -- Acid Spit
	[26180]	= Defaults(2), -- Wyvern Sting
	[26053]	= Defaults(2), -- Noxious Poison
	[26613]	= Defaults(2), -- Unbalancing Strike
	[26029]	= Defaults(2), -- Dark Glare
	----------------------------------------------------------
	------------------------ Naxxramas -----------------------
	----------------------------------------------------------
	[28732]	= Defaults(2), -- Widow's Embrace
	[28622]	= Defaults(2), -- Web Wrap
	[28169]	= Defaults(2), -- Mutating Injection
	[29213]	= Defaults(2), -- Curse of the Plaguebringer
	[28835]	= Defaults(2), -- Mark of Zeliek
	[27808]	= Defaults(2), -- Frost Blast
	[28410]	= Defaults(2), -- Chains of Kel'Thuzad
	[27819]	= Defaults(2), -- Detonate Mana
	},
}

G.unitframe.aurafilters.DungeonDebuffs = {
	type = 'Whitelist',
	spells = {
	--Multiple Dungeons
		[744]	= Defaults(2), -- Poison
		[18267]	= Defaults(2), -- Curse of Weakness
		[20800]	= Defaults(2), -- Immolate
		[246]	= Defaults(2), -- Slow
		[6533]	= Defaults(2), -- Net
		[8399]	= Defaults(2), -- Sleep
	-- Blackrock Depths
		[13704]	= Defaults(2), -- Psychic Scream
	-- Deadmines
		[6304]	= Defaults(2), -- Rhahk'Zor Slam
		[12097]	= Defaults(2), -- Pierce Armor
		[7399]	= Defaults(2), -- Terrify
		[6713]	= Defaults(2), -- Disarm
		[5213]	= Defaults(2), -- Molten Metal
		[5208]	= Defaults(2), -- Poisoned Harpoon
	-- Maraudon
		[7964]	= Defaults(2), -- Smoke Bomb
		[21869]	= Defaults(2), -- Repulsive Gaze
	-- Razorfen Downs
		[12255]	= Defaults(2), -- Curse of Tuten'kash
		[12252]	= Defaults(2), -- Web Spray
		[7645]	= Defaults(2), -- Dominate Mind
		[12946]	= Defaults(2), -- Putrid Stench
	-- Razorfen Kraul
		[14515]	= Defaults(2), -- Dominate Mind
	-- Scarlet Monastry
		[9034]	= Defaults(2), -- Immolate
		[8814]	= Defaults(2), -- Flame Spike
		[8988]	= Defaults(2), -- Silence
		[9256]	= Defaults(2), -- Deep Sleep
		[8282]	= Defaults(2), -- Curse of Blood
	-- Shadowfang Keep
		[7068]	= Defaults(2), -- Veil of Shadow
		[7125]	= Defaults(2), -- Toxic Saliva
		[7621]	= Defaults(2), -- Arugal's Curse
	--Stratholme
		[16798]	= Defaults(2), -- Enchanting Lullaby
		[12734]	= Defaults(2), -- Ground Smash
		[17293]	= Defaults(2), -- Burning Winds
		[17405]	= Defaults(2), -- Domination
		[16867]	= Defaults(2), -- Banshee Curse
		[6016]	= Defaults(2), -- Pierce Armor
		[16869]	= Defaults(2), -- Ice Tomb
		[17307]	= Defaults(2), -- Knockout
	-- Sunken Temple
		[12889]	= Defaults(2), -- Curse of Tongues
		[12888]	= Defaults(2), -- Cause Insanity
		[12479]	= Defaults(2), -- Hex of Jammal'an
		[12493]	= Defaults(2), -- Curse of Weakness
		[12890]	= Defaults(2), -- Deep Slumber
		[24375]	= Defaults(2), -- War Stomp
	-- Uldaman
		[3356]	= Defaults(2), -- Flame Lash
		[6524]	= Defaults(2), -- Ground Tremor
	-- Wailing Caverns
		[8040]	= Defaults(2), -- Druid's Slumber
		[8142]	= Defaults(2), -- Grasping Vines
		[7967]	= Defaults(2), -- Naralex's Nightmare
		[8150]	= Defaults(2), -- Thundercrack
	-- Zul'Farrak
		[11836]	= Defaults(2), -- Freeze Solid
	-- World Bosses
		[21056]	= Defaults(2), -- Mark of Kazzak
		[24814]	= Defaults(2), -- Seeping Fog
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
	[19451] = Defaults(), -- Frenzy
	[19714] = Defaults(), -- Deaden Magic
	[19516] = Defaults(), -- Enrage
	[19695] = Defaults(), -- Inferno
	[20478] = Defaults(), -- Armageddon
	[19779] = Defaults(), -- Inspire
	[20620] = Defaults(), -- Aegis of Ragnaros
	[21075] = Defaults(), -- Damage Shield
	[20619] = Defaults(), -- Magic Reflection
	----------------------------------------------------------
	------------------------ Zul'Gurub -----------------------
	----------------------------------------------------------
	[23895] = Defaults(), -- Renew
	},
}

-- AuraWatch: List of personal spells to show on unitframes as icon
function UF:AuraWatch_AddSpell(id, point, color, anyUnit, onlyShowMissing, displayText, textThreshold, xOffset, yOffset)

	local r, g, b = 1, 1, 1
	if color then r, g, b = unpack(color) end

	local spellRank
	local spellName = GetSpellInfo(id)
	local rankText = GetSpellSubtext(id)
	if rankText and strfind(rankText, '%d') then
		spellRank = rankText
	end

	return {
		id = id,
		enabled = true,
		name = spellName,
		rank = spellRank,
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
		[6673]	= UF:AuraWatch_AddSpell(6673, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 1)
		[5242]	= UF:AuraWatch_AddSpell(5242, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 2)
		[6192]	= UF:AuraWatch_AddSpell(6192, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 3)
		[11549]	= UF:AuraWatch_AddSpell(11549, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 4)
		[11550]	= UF:AuraWatch_AddSpell(11550, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 5)
		[11551]	= UF:AuraWatch_AddSpell(11551, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 6)
		[25289]	= UF:AuraWatch_AddSpell(25289, 'TOPLEFT', {0.2, 0.2, 1}, true),	-- Battle Shout (Rank 7)
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
	PALADIN = {
		[1044]	= UF:AuraWatch_AddSpell(1044, 'CENTER', {0.89, 0.45, 0}),					-- Blessing of Freedom
		[6940]	= UF:AuraWatch_AddSpell(6940, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 1)
		[20729]	= UF:AuraWatch_AddSpell(20729, 'CENTER', {0.89, 0.1, 0.1}),					-- Blessing Sacrifice (Rank 2)
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
	HUNTER = {
		[19506]	= UF:AuraWatch_AddSpell(19506, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 1)
		[20905]	= UF:AuraWatch_AddSpell(20905, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 2)
		[20906]	= UF:AuraWatch_AddSpell(20906, 'TOPLEFT', {0.89, 0.09, 0.05}),		-- Trueshot Aura (Rank 3)
		[13159]	= UF:AuraWatch_AddSpell(13159, 'BOTTOMLEFT', {0.00, 0.00, 0.85}),	-- Aspect of the Pack
		[20043]	= UF:AuraWatch_AddSpell(20043, 'BOTTOMLEFT', {0.33, 0.93, 0.79}),	-- Aspect of the Wild (Rank 1)
		[20190]	= UF:AuraWatch_AddSpell(20190, 'BOTTOMLEFT', {0.33, 0.93, 0.79}),	-- Aspect of the Wild (Rank 2)
	},
	WARLOCK = {
		[5597]	= UF:AuraWatch_AddSpell(5597, 'TOPLEFT', {0.89, 0.09, 0.05}, true),	-- Unending Breath
		[6512]	= UF:AuraWatch_AddSpell(6512, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Lesser Invisibility
		[2970]	= UF:AuraWatch_AddSpell(2970, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Invisibility
		[11743]	= UF:AuraWatch_AddSpell(11743, 'TOPRIGHT', {0.2, 0.8, 0.2}, true),	-- Detect Greater Invisibility
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

-- Profile specific BuffIndicator
P.unitframe.filters = {
	aurawatch = {},
}

-- List of spells to display ticks
G.unitframe.ChannelTicks = {
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
	-- Priest
	[15407]	= 3, -- Mind Flay (Rank 1)
	[17311]	= 3, -- Mind Flay (Rank 2)
	[17312]	= 3, -- Mind Flay (Rank 3)
	[17313]	= 3, -- Mind Flay (Rank 4)
	[17314]	= 3, -- Mind Flay (Rank 5)
	[18807]	= 3, -- Mind Flay (Rank 6)
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
}

local checkTicks = CreateFrame('Frame')
checkTicks:RegisterEvent('PLAYER_ENTERING_WORLD')
checkTicks:SetScript('OnEvent', function()
	if E.myclass == 'PRIEST' then
		E.global.unitframe.ChannelTicks[47540]	= (IsPlayerSpell(193134) and 4 or 3) --Penance
	end
end)

G.unitframe.ChannelTicksSize = {
	-- Warlock
	[198590]	= 1, -- Drain Soul
}

-- Spells Effected By Haste
G.unitframe.HastedChannelTicks = {
	[205021]	= true, -- Ray of Frost
}

G.unitframe.TalentChannelTicks = {}

-- This should probably be the same as the whitelist filter + any personal class ones that may be important to watch
G.unitframe.AuraBarColors = {
	[2825]	= {r = 0.98, g = 0.57, b = 0.10}, -- Bloodlust
	[32182]	= {r = 0.98, g = 0.57, b = 0.10}, -- Heroism
	[80353]	= {r = 0.98, g = 0.57, b = 0.10}, -- Time Warp
	[90355]	= {r = 0.98, g = 0.57, b = 0.10}, -- Ancient Hysteria
}

G.unitframe.AuraHighlightColors = {
	[25771]	= {enable = false, style = 'FILL', color = {r = 0.85, g = 0, b = 0, a = 0.85}},
}

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
