local lib = LibStub and LibStub("LibClassicDurations", true)
if not lib then return end

local Type, Version = "SpellTable", 71
if lib:GetDataVersion(Type) >= Version then return end  -- older versions didn't have that function

local Spell = lib.AddAura
local Talent = lib.Talent
local INFINITY = math.huge

local _, class = UnitClass("player")
local locale = GetLocale()

-- Temporary
-- Erases Fire Vulnerability from the name to id table in case older version of the lib written it there
if locale == "zhCN" then
    lib.spellNameToID[GetSpellInfo(980)] = nil
end
if locale == "ruRU" then
    lib.spellNameToID[GetSpellInfo(12721)] = nil -- Deep Wounds conflict with Rake on ruRU
end

-- https://github.com/rgd87/LibClassicDurations/issues/11
lib.indirectRefreshSpells = {
    [GetSpellInfo(11597)] = { -- Sunder Armor
        [11597] = {
            events = {
                ["SPELL_CAST_SUCCESS"] = true
            },
            -- targetSpellID = 11597,
            rollbackMisses = true,
        }
    },

    [GetSpellInfo(25357)] = { -- Healing Wave
        [29203] = {
            events = {
                ["SPELL_CAST_SUCCESS"] = true
            },
            -- targetSpellID = 29203, -- Healing Way
        }
    },
}

if class == "MAGE" then


    lib.indirectRefreshSpells[GetSpellInfo(25304)] = { -- Frostbolt
        [12579] = {
            events = {
                ["SPELL_DAMAGE"] = true
            },
            targetSpellID = 12579, -- Winter's Chill
            rollbackMisses = true,
            condition = function(isMine) return isMine end,
        }
    }

    lib.indirectRefreshSpells[GetSpellInfo(10161)] = { -- Cone of Cold
        [12579] = {
            events = {
                ["SPELL_DAMAGE"] = true
            },
            targetSpellID = 12579, -- Winter's Chill
            rollbackMisses = true,
            condition = function(isMine) return isMine end,
        }
    }

    lib.indirectRefreshSpells[GetSpellInfo(10230)] = { -- Frost Nova
        [12579] = {
            events = {
                ["SPELL_DAMAGE"] = true
            },
            targetSpellID = 12579, -- Winter's Chill
            rollbackMisses = true,
            condition = function(isMine) return isMine end,
        }
    }

    -- Winter's Chill = Frostbolt
    lib.indirectRefreshSpells[GetSpellInfo(12579)] = lib.indirectRefreshSpells[GetSpellInfo(25304)]

    lib.indirectRefreshSpells[GetSpellInfo(10)] = { -- Blizzard
        [12486] = {
            events = {
                ["SPELL_PERIODIC_DAMAGE"] = true
            },
            applyAura = true,
            targetSpellID = 12486, -- Imp Blizzard
        }
    }

    -- Ignite

    lib.indirectRefreshSpells[GetSpellInfo(10207)] = { -- Scorch
        [22959] = {
            events = {
                ["SPELL_DAMAGE"] = true
            },
            -- targetSpellID = 22959, -- Fire Vulnerability
            rollbackMisses = true,
            -- condition = function(isMine) return isMine end,
            -- it'll refresg only from mages personal casts which is fine
            -- because if mage doesn't have imp scorch then he won't even see a Fire Vulnerability timer
        },
    }

    local fire_spells = {133, 10207, 2136, 2120, 11113} -- Fireball, Scorch, Fireblast, Flamestrike, Blast Wave

    for _, spellId in ipairs(fire_spells) do
        local spellName = GetSpellInfo(spellId)
        if not lib.indirectRefreshSpells[spellName] then
            lib.indirectRefreshSpells[spellName] = {}
        end
        lib.indirectRefreshSpells[spellName][12654] = {
            events = {
                ["SPELL_DAMAGE"] = true
            },
            -- targetSpellID = 12654, -- Ignite
            rollbackMisses = true,
            condition = function(isMine, isCrit) return isCrit end,
            customAction = function(srcGUID, dstGUID, spellID)
                local lib = LibStub("LibClassicDurations")
                local spellTable = lib:GetSpellTable(srcGUID, dstGUID, spellID)
                if spellTable and not spellTable.tickExtended then
                    local igniteStartTime = spellTable[2]
                    spellTable[2] = igniteStartTime + 2
                    spellTable.tickExtended = true
                    if lib.DEBUG_IGNITE then
                        print(GetTime(), "[Ignite] Extended", dstGUID, "New start time:", spellTable[2])
                    end
                end
            end,
        }
    end



    lib.indirectRefreshSpells[GetSpellInfo(12654)] = CopyTable(lib.indirectRefreshSpells[GetSpellInfo(133)]) -- Just adding Ignite to indirectRefreshSpells table
    lib.indirectRefreshSpells[GetSpellInfo(12654)][12654].events = {}
end

if class == "PRIEST" then
    -- Shadow Weaving
    lib.indirectRefreshSpells[GetSpellInfo(10894)] = { -- SW:Pain
        [15258] = {
            events = {
                ["SPELL_AURA_APPLIED"] = true,
                ["SPELL_AURA_REFRESH"] = true,
            },
            -- targetSpellID = 15258, -- Shadow Weaving
            -- targetResistCheck = true,
            rollbackMisses = true,
            condition = function(isMine) return isMine end,
        }
    }
    lib.indirectRefreshSpells[GetSpellInfo(10947)] = { -- Mind Blast
        [15258] = {
            events = {
                ["SPELL_DAMAGE"] = true,
            },
            -- targetResistCheck = true,
            rollbackMisses = true,
            condition = function(isMine) return isMine end,
        }
    }
    lib.indirectRefreshSpells[GetSpellInfo(18807)] = { -- Mind Flay
        [15258] = {
            events = {
                ["SPELL_AURA_APPLIED"] = true,
                ["SPELL_AURA_REFRESH"] = true,
            },
            rollbackMisses = true,
            condition = function(isMine) return isMine end,
        }
    }

    -- Shadow Weaving = SW: Pain
    lib.indirectRefreshSpells[GetSpellInfo(15258)] = CopyTable(lib.indirectRefreshSpells[GetSpellInfo(10894)])
    lib.indirectRefreshSpells[GetSpellInfo(15258)][15258].events = {}
end

------------------
-- GLOBAL
------------------

-- World Buffs incl. Chronoboon IDs
Spell(349981, { duration = INFINITY }) -- World effect suspended
Spell({ 355363, 22888 }, { duration = 7200 }) -- Rallying Cry of the Dragonslayer
Spell({ 355365, 24425 }, { duration = 7200 }) -- Spirit of Zandalar
Spell({ 355366, 16609 }, { duration = 3600 }) -- Warchief's Blessing

-- Atiesh Buffs
Spell( 28142, { duration = INFINITY, type = "BUFF" }) -- Power of the Guardian
Spell( 28143, { duration = INFINITY, type = "BUFF" }) -- Power of the Guardian
Spell( 28144, { duration = INFINITY, type = "BUFF" }) -- Power of the Guardian
Spell( 28145, { duration = INFINITY, type = "BUFF" }) -- Power of the Guardian

Spell( 2479, { duration = 30 }) -- Honorless Target
Spell(1604, { duration = 4 }) -- Common Daze
Spell( 23605, { duration = 5 }) -- Nightfall (Axe) Proc
Spell( 835, { duration = 3 }) -- Tidal Charm
Spell( 11196, { duration = 60 }) -- Recently Bandaged
Spell( 16928, { duration = 45 }) -- Armor Shatter, procced by Annihilator, axe weapon

Spell({ 13099, 13138, 16566 }, {
    duration = function(spellID)
        if spellID == 13138 then return 20 -- backfire
        elseif spellID == 16566 then return 30 -- backfire
        else return 10 end
    end
}) -- Net-o-Matic

Spell( 23451, { duration = 10 }) -- Battleground speed buff
Spell( 23493, { duration = 10 }) -- Battleground heal buff
Spell( 23505, { duration = 60 }) -- Battleground damage buff
Spell({ 4068 }, { duration = 3 }) -- Iron Grenade
Spell({ 19769 }, { duration = 3 }) -- Thorium Grenade
Spell( 6615, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Free Action Potion
Spell( 24364, { duration = 5, type = "BUFF", buffType = "Magic" }) -- Living Action Potion
Spell( 3169, { duration = 6, type = "BUFF", buffType = "Magic" }) -- Limited Invulnerability Potion
Spell( 16621, { duration = 3, type = "BUFF" }) -- Invulnerable Mail
Spell( 1090, { duration = 30 }) -- Magic Dust
Spell( 13327, { duration = 30 }) -- Reckless Charge
Spell({ 26740, 13181 }, { duration = 20 }) -- Mind Control Cap + Backfire
Spell( 11359, { duration = 30, type = "BUFF" }) -- Restorative Potion
Spell( 6727, { duration = 30 }) -- Violet Tragan
Spell( 5024, { duration = 10, type = "BUFF" }) -- Skull of Impending Doom
Spell( 2379, { duration = 15, type = "BUFF", buffType = "Magic" }) -- Swiftness Potion
Spell( 5134, { duration = 10 }) -- Flash Bomb
Spell( 23097, { duration = 5, type = "BUFF" }) -- Fire Reflector
Spell( 23131, { duration = 5, type = "BUFF" }) -- Frost Reflector
Spell( 23132, { duration = 5, type = "BUFF" }) -- Shadow Reflector
Spell({ 25750, 25747, 25746, 23991 }, { duration = 15, type = "BUFF" }) -- AB Trinkets
Spell( 23506, { duration = 20, type = "BUFF" }) -- Arena Grand Master trinket
Spell( 29506, { duration = 20, type = "BUFF" }) -- Burrower's Shell trinket
Spell( 12733, { duration = 30, type = "BUFF" }) -- Blacksmith trinket
-- Spell( 15753, { duration = 2 }) -- Linken's Boomerang stun
-- Spell( 15752, { duration = 10 }) -- Linken's Boomerang disarm
Spell( 14530, { duration = 10, type = "BUFF" }) -- Nifty Stopwatch
Spell( 13237, { duration = 3 }) -- Goblin Mortar trinket
Spell( 21152, { duration = 3 }) -- Earthshaker, weapon proc
Spell( 14253, { duration = 8, type = "BUFF" }) -- Black Husk Shield
Spell( 9175, { duration = 15, type = "BUFF" }) -- Swift Boots
Spell( 13141, { duration = 20, type = "BUFF" }) -- Gnomish Rocket Boots
Spell( 8892, { duration = 20, type = "BUFF" }) -- Goblin Rocket Boots
Spell( 9774, { duration = 5, type = "BUFF" }) -- Spider Belt & Ornate Mithril Boots
Spell({ 746, 1159, 3267, 3268, 7926, 7927, 10838, 10839, 18608, 18610, 23567, 23568, 23569, 23696, 24412, 24413, 24414}, { duration = 8, type = "BUFF" }) -- First Aid
Spell({ 21992, 27648 }, { duration = 12 }) -- Thunderfury, -Nature Resist, -Atk Spd


-------------
-- RACIALS
-------------

Spell( 26635 ,{ duration = 10, type = "BUFF" }) -- Berserking
Spell( 20600 ,{ duration = 20, type = "BUFF" }) -- Perception
Spell( 23234 ,{ duration = 15, type = "BUFF" }) -- Blood Fury
Spell( 23230 ,{ duration = 25 }) -- Blood Fury debuff
Spell( 20594 ,{ duration = 8, type = "BUFF" }) -- Stoneform
Spell( 20549 ,{ duration = 2 }) -- War Stomp
Spell( 7744, { duration = 5, type = "BUFF" }) -- Will of the Forsaken

-------------
-- PRIEST
-------------

Spell( 15473, { duration = INFINITY, type = "BUFF" }) -- Shadowform
Spell( 14751, { duration = INFINITY, type = "BUFF", buffType = "Magic" }) -- Inner focus

-- Why long auras are disabled
-- When you first get in combat log range with a player,
-- you'll get AURA_APPLIED event as if it was just applied, when it actually wasn't.
-- That's extremely common for these long self-buffs
-- Long raid buffs now have cast filter, that is only if you directly casted a spell it'll register
-- Cast Filter is ignored for enemies, so some personal buffs have it to still show enemy buffs

Spell({ 1243, 1244, 1245, 2791, 10937, 10938 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Power Word: Fortitude
Spell({ 21562, 21564 }, { duration = 3600, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Prayer of Fortitude
Spell({ 976, 10957, 10958 }, { duration = 600, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Shadow Protection
Spell( 27683, { duration = 1200, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Prayer of Shadow Protection
Spell({ 14752, 14818, 14819, 27841 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Divine Spirit
Spell( 27681, { duration = 3600, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Prayer of Spirit

Spell({ 588, 602, 1006, 7128, 10951, 10952 }, { duration = 600, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Inner Fire

Spell({ 14743, 27828 }, { duration = 6, type = "BUFF", buffType = "Magic" }) -- Focused Casting (Martyrdom)
Spell( 27827, { duration = 10, type = "BUFF" }) -- Spirit of Redemption
Spell( 15271, { duration = 15, type = "BUFF" }) -- Spirit Tap

Spell({ 2943, 19249, 19251, 19252, 19253, 19254 }, { duration = 120 }) -- Touch of Weakness Effect
Spell({ 13896, 19271, 19273, 19274, 19275 }, { duration = 15, type = "BUFF" }) -- Feedback
Spell({ 2651, 19289, 19291, 19292, 19293 }, { duration = 15, type = "BUFF" }) -- Elune's Grace
Spell({ 9035, 19281, 19282, 19283, 19284, 19285 }, { duration = 120 }) -- Hex of Weakness

Spell( 6346, { duration = 600, type = "BUFF", buffType = "Magic" }) -- Fear Ward
Spell({ 14893, 15357 ,15359 }, { duration = 15, type = "BUFF", buffType = "Magic" }) -- Inspiration
Spell({ 7001, 27873, 27874 }, { duration = 10, type = "BUFF", buffType = "Magic" }) -- Lightwell Renew
Spell( 552, { duration = 20, type = "BUFF", buffType = "Magic" }) -- Abolish Disease
Spell({ 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 }, {duration = 30, type = "BUFF", buffType = "Magic" }) -- PWS
Spell( 6788, { duration = 15 }) -- Weakened Soul
if class == "PRIEST" then
    lib:TrackItemSet("Garments of the Oracle", { 21349, 21350, 21348, 21352, 21351 })
    lib:RegisterSetBonusCallback("Garments of the Oracle", 5)
end
Spell({ 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer and lib:IsSetBonusActive("Garments of the Oracle", 5) then
            return 18
        else
            return 15
        end
    end,
    type = "BUFF", buffType = "Magic" }) -- Renew

Spell( 15487, { duration = 5 }) -- Silence
Spell({ 10797, 19296, 19299, 19302, 19303, 19304, 19305 }, { duration = 6, stacking = true }) -- starshards
Spell({ 2944, 19276, 19277, 19278, 19279, 19280 }, { duration = 24, stacking = true }) --devouring plague
Spell({ 453, 8192, 10953 }, { duration = 15 }) -- mind soothe

Spell({ 9484, 9485, 10955 }, {
    duration = function(spellID)
        if spellID == 9484 then return 30
        elseif spellID == 9485 then return 40
        else return 50 end
    end
}) -- Shackle Undead

Spell( 10060, { duration = 15, type = "BUFF", buffType = "Magic" }) --Power Infusion
Spell({ 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267 }, { duration = 10, stacking = true }) -- Holy Fire, stacking?
Spell({ 586, 9578, 9579, 9592, 10941, 10942 }, { duration = 10, type = "BUFF" }) -- Fade
if class == "PRIEST" then
    lib:TrackItemSet("PriestPvPSet", {
        17604, 17603, 17605, 17608, 17607, 17602,
        17623, 17625, 17622, 17624, 17618, 17620,
        22869, 22859, 22882, 22885, 23261, 23262,
        23302, 23303, 23288, 23289, 23316, 23317,
    })
    lib:RegisterSetBonusCallback("PriestPvPSet", 3)
end
Spell({ 8122, 8124, 10888, 10890 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local pvpSetBonus = lib:IsSetBonusActive("PriestPvPSet", 3) and 1 or 0
            return 8 + pvpSetBonus
        else
            return 8
        end
    end
}) -- Psychic Scream
Spell({ 589, 594, 970, 992, 2767, 10892, 10893, 10894 }, { stacking = true,
    duration = function(spellID, isSrcPlayer)
        -- Improved SWP, 2 ranks: Increases the duration of your Shadow Word: Pain spell by 3 sec.
        local talents = isSrcPlayer and 3*Talent(15275, 15317) or 0
        return 18 + talents
    end
}) -- SW:P
Spell( 15269 ,{ duration = 3 }) -- Blackout

if class == "PRIEST" then
Spell( 15258 ,{
    duration = function(spellID, isSrcPlayer)
        -- Only SP himself can see the timer
        if Talent(15257, 15331, 15332, 15333, 15334) > 0 then
            return 15
        else
            return nil
        end
    end
}) -- Shadow Weaving
end

Spell( 15286 ,{ duration = 60 }) -- Vampiric Embrace
Spell({ 15407, 17311, 17312, 17313, 17314, 18807 }, { duration = 3 }) -- Mind Flay
Spell({ 605, 10911, 10912 }, { duration = 60 }) -- Mind Control

---------------
-- DRUID
---------------

Spell( 768, { duration = INFINITY, type = "BUFF" }) -- Cat Form
Spell( 783, { duration = INFINITY, type = "BUFF" }) -- Travel Form
Spell( 5487, { duration = INFINITY, type = "BUFF" }) -- Bear Form
Spell( 9634, { duration = INFINITY, type = "BUFF" }) -- Dire Bear Form
Spell( 1066, { duration = INFINITY, type = "BUFF" }) -- Aquatic Form
Spell( 24858, { duration = INFINITY, type = "BUFF" }) -- Moonkin Form
Spell( 24932, { duration = INFINITY, type = "BUFF" }) -- Leader of the Pack
Spell( 17116, { duration = INFINITY, type = "BUFF", buffType = "Magic" }) -- Nature's Swiftness

Spell({ 1126, 5232, 5234, 6756, 8907, 9884, 9885 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Mark of the Wild
Spell({ 21849, 21850 }, { duration = 3600, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Gift of the Wild
Spell( 19975, { duration = 12, buffType = "Magic" }) -- Nature's Grasp root
Spell({ 16689, 16810, 16811, 16812, 16813, 17329 }, { duration = 45, type = "BUFF", buffType = "Magic" }) -- Nature's Grasp
Spell( 16864, { duration = 600, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Omen of Clarity
Spell( 16870, { duration = 15, type = "BUFF", buffType = "Magic" }) -- Clearcasting from OoC



Spell( 19675, { duration = 4 }) -- Feral Charge
Spell({ 467, 782, 1075, 8914, 9756, 9910 }, { duration = 600, type = "BUFF", buffType = "Magic" }) -- Thorns
Spell( 22812 ,{ duration = 15, type = "BUFF", buffType = "Magic" }) -- Barkskin
--SKIPPING: Hurricane (Channeled)
Spell({ 339, 1062, 5195, 5196, 9852, 9853 }, {
    pvpduration = 20,
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 339 then return 12
        elseif spellID == 1062 then return 15
        elseif spellID == 5195 then return 18
        elseif spellID == 5196 then return 21
        elseif spellID == 9852 then return 24
        else return 27 end
    end
}) -- Entangling Roots
Spell({ 2908, 8955, 9901 }, { duration = 15 }) -- Soothe Animal
Spell({ 770, 778, 9749, 9907 }, { duration = 40 }) -- Faerie Fire
Spell({ 16857, 17390, 17391, 17392 }, { duration = 40 }) -- Faerie Fire (Feral)
Spell({ 2637, 18657, 18658 }, {
    pvpduration = 20,
    duration = function(spellID)
        if spellID == 2637 then return 20
        elseif spellID == 18657 then return 30
        else return 40 end
    end
}) -- Hibernate
Spell({ 99, 1735, 9490, 9747, 9898 }, { duration = 30 }) -- Demoralizing Roar
Spell({ 5211, 6798, 8983 }, { stacking = true, -- stacking?
    duration = function(spellID)
        local brutal_impact = Talent(16940, 16941)*0.5
        if spellID == 5211 then return 2+brutal_impact
        elseif spellID == 6798 then return 3+brutal_impact
        else return 4+brutal_impact end
    end
}) -- Bash
Spell( 5209, { duration = 6 }) -- Challenging Roar
Spell( 6795, { duration = 3, stacking = true }) -- Taunt

Spell({ 1850, 9821 }, { duration = 15, type = "BUFF" }) -- Dash
Spell( 5229, { duration = 10, type = "BUFF" }) -- Enrage
Spell({ 22842, 22895, 22896 }, { duration = 10, type = "BUFF" }) -- Frenzied Regeneration
Spell( 16922, { duration = 3 }) -- Imp Starfire Stun

Spell({ 9005, 9823, 9827 }, { -- Pounce stun doesn't create a debuff icon, so this is not going to be used
    duration = function(spellID)
        local brutal_impact = Talent(16940, 16941)*0.5
        return 2+brutal_impact
    end
}) -- Pounce
Spell({ 9007, 9824, 9826 }, { duration = 18, stacking = true, }) -- Pounce Bleed
Spell({ 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835 }, { stacking = true,
    duration = function(spellID)
        if spellID == 8921 then return 9
        else return 12 end
    end
}) -- Moonfire
Spell({ 1822, 1823, 1824, 9904 }, { duration = 9, stacking = true }) -- Rake
Spell({ 1079, 9492, 9493, 9752, 9894, 9896 }, { duration = 12, stacking = true }) -- Rip
Spell({ 5217, 6793, 9845, 9846 }, { name = "Tiger's Fury", duration = 6 })

Spell( 2893 ,{ duration = 8, type = "BUFF", buffType = "Magic" }) -- Abolish Poison
Spell( 29166 , { duration = 20, type = "BUFF", buffType = "Magic" }) -- Innervate

Spell({ 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858 }, { duration = 21, type = "BUFF", buffType = "Magic" }) -- Regrowth

if class == "DRUID" then
    lib:TrackItemSet("StormrageRaiment", { 16899, 16900, 16901, 16902, 16903, 16904, 16897, 16898, })
    lib:RegisterSetBonusCallback("StormrageRaiment", 8)
end
Spell({ 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer and lib:IsSetBonusActive("StormrageRaiment", 8) then
            return 15
        else
            return 12
        end
    end,
    stacking = false, type = "BUFF", buffType = "Magic" }) -- Rejuv
Spell({ 5570, 24974, 24975, 24976, 24977 }, { duration = 12, stacking = true }) -- Insect Swarm

-------------
-- WARRIOR
-------------

Spell( 2457 , { duration = INFINITY, type = "BUFF" }) -- Battle Stance
Spell( 2458 , { duration = INFINITY, type = "BUFF" }) -- Berserker Stance
Spell( 71 , { duration = INFINITY, type = "BUFF" }) -- Def Stance

Spell({ 12294, 21551, 21552, 21553 }, { duration = 10 }) -- Mortal Strike Healing Reduction

Spell({72, 1671, 1672}, { duration = 6 }) -- Shield Bash
Spell( 18498, { duration = 3 }) -- Improved Shield Bash

Spell( 20230, { duration = 15, type = "BUFF" }) -- Retaliation
Spell( 1719, { duration = 15, type = "BUFF" }) -- Recklessness
Spell( 871, { type = "BUFF", duration = 10 }) -- Shield wall, varies
Spell( 12976, { duration = 20, type = "BUFF" }) -- Last Stand
Spell( 12328, { duration = 30 }) -- Death Wish
Spell({ 772, 6546, 6547, 6548, 11572, 11573, 11574 }, { stacking = true,
    duration = function(spellID)
        if spellID == 772 then return 9
        elseif spellID == 6546 then return 12
        elseif spellID == 6547 then return 15
        elseif spellID == 6548 then return 18
        else return 21 end
    end
}) -- Rend
if locale ~= "ruRU" or class ~= "DRUID" then
Spell( 12721, { duration = 12, stacking = true }) -- Deep Wounds
end

Spell({ 1715, 7372, 7373 }, { duration = 15 }) -- Hamstring
Spell( 23694 , { duration = 5 }) -- Improved Hamstring
Spell({ 6343, 8198, 8204, 8205, 11580, 11581 }, {
    duration = function(spellID)
        if spellID == 6343 then return 10
        elseif spellID == 8198 then return 14
        elseif spellID == 8204 then return 18
        elseif spellID == 8205 then return 22
        elseif spellID == 11580 then return 26
        else return 30 end
    end
}) -- Thunder Clap
Spell({ 694, 7400, 7402, 20559, 20560 }, { duration = 6 }) -- Mocking Blow
Spell( 1161 ,{ duration = 6 }) -- Challenging Shout
Spell( 355 ,{ duration = 3, stacking = true }) -- Taunt
Spell({ 5242, 6192, 6673, 11549, 11550, 11551, 25289 }, { type = "BUFF",
    duration = function(spellID, isSrcPlayer)
        local talents = isSrcPlayer and Talent(12321, 12835, 12836, 12837, 12838) or 0
        return 120 * (1 + 0.1 * talents)
    end
}) -- Battle Shout
Spell({ 1160, 6190, 11554, 11555, 11556 }, {
    duration = function(spellID, isSrcPlayer)
        local talents = isSrcPlayer and Talent(12321, 12835, 12836, 12837, 12838) or 0
        return 30 * (1 + 0.1 * talents)
    end
}) -- Demoralizing Shout, varies
Spell( 18499, { duration = 10, type = "BUFF" }) -- Berserker Rage
Spell({ 20253, 20614, 20615 }, { duration = 3 }) -- Intercept
Spell( 12323, { duration = 6 }) -- Piercing Howl
Spell( 5246, { duration = 8 }) -- Intimidating Shout Fear
Spell( 20511, { duration = 8 }) -- Intimidating Shout Main Target Cower Effect

Spell( 676 ,{
    duration = function(spellID, isSrcPlayer)
        local talents = isSrcPlayer and Talent(12313, 12804, 12807) or 0
        return 10 + talents
    end,
}) -- Disarm, varies
Spell( 29131 ,{ duration = 10, type = "BUFF" }) -- Bloodrage
Spell( 12798 , { duration = 3 }) -- Imp Revenge Stun
Spell( 2565 ,{ duration = 5, type = "BUFF" }) -- Shield Block, varies BUFF

Spell({ 7386, 7405, 8380, 11596, 11597 }, { duration = 30 }) -- Sunder Armor
Spell( 12809 ,{ duration = 5 }) -- Concussion Blow
Spell( 12292 ,{ duration = 20, type = "BUFF" }) -- Sweeping Strikes
Spell({ 12880, 14201, 14202, 14203, 14204 }, { duration = 12, type = "BUFF" }) -- Enrage
Spell({ 12966, 12967, 12968, 12969, 12970 }, { duration = 15, type = "BUFF" }) -- Flurry
Spell({ 16488, 16490, 16491 }, { duration = 6, type = "BUFF" }) -- Blood Craze
Spell({ 23885, 23886, 23887, 23888 }, { duration = 6, type = "BUFF" }) -- Bloodthirst
Spell(7922, { duration = 1 }) -- Charge
Spell(5530, { duration = 3 }) -- Mace Specialization

--------------
-- ROGUE
--------------

Spell( 14177 , { duration = INFINITY, type = "BUFF" }) -- Cold Blood
Spell({ 1784, 1785, 1786, 1787 } , { duration = INFINITY, type = "BUFF" }) -- Stealth

Spell( 14278 , { duration = 7, type = "BUFF" }) -- Ghostly Strike
Spell({ 16511, 17347, 17348 }, { duration = 15 }) -- Hemorrhage
Spell({ 11327, 11329 }, { duration = 10 }) -- Vanish
Spell({ 3409, 11201 }, { duration = 12 }) -- Crippling Poison
-- Spell({ 13218, 13222, 13223, 13224 }, { duration = 15 }) -- Wound Poison
-- Spell({ 2818, 2819, 11353, 11354, 25349 }, { duration = 12, stacking = true }) -- Deadly Poison
Spell({ 5760, 8692, 11398 }, {
    duration = function(spellID)
        if spellID == 5760 then return 10
        elseif spellID == 8692 then return 12
        else return 14 end
    end
}) -- Mind-numbing Poison

Spell( 18425, { duration = 2 }) -- Improved Kick Silence
Spell( 13750, { duration = 15, type = "BUFF" }) -- Adrenaline Rush
Spell( 13877, { duration = 15, type = "BUFF" }) -- Blade Flurry
Spell( 1833, { duration = 4 }) -- Cheap Shot
Spell({ 2070, 6770, 11297 }, {
    pvpduration = 20,
    duration = function(spellID)
        if spellID == 6770 then return 25 -- yes, Rank 1 spell id is 6770 actually
        elseif spellID == 2070 then return 35
        else return 45 end
    end
}) -- Sap
Spell( 2094 , { duration = 10 }) -- Blind

Spell({ 8647, 8649, 8650, 11197, 11198 }, { duration = 30 }) -- Expose Armor
Spell({ 703, 8631, 8632, 8633, 11289, 11290 }, { duration = 18 }) -- Garrote

Spell({ 408, 8643 }, {
    duration = function(spellID, isSrcPlayer, comboPoints)
        local duration = spellID == 8643 and 1 or 0 -- if Rank 2, add 1s
        if isSrcPlayer then
            return duration + comboPoints
        else
            return duration + 5 -- just assume 5cp i guess
        end
    end
}) -- Kidney Shot

Spell({ 1943, 8639, 8640, 11273, 11274, 11275 }, { stacking = true,
    duration = function(spellID, isSrcPlayer, comboPoints)
        if isSrcPlayer then
            return (6 + comboPoints*2)
        else
            return 16
        end
    end
}) -- Rupture

Spell({ 5171, 6774 }, { duration = nil, type = "BUFF" }) -- SnD, to prevent fallback to incorrect db values

Spell({ 2983, 8696, 11305 }, { duration = 15, type = "BUFF" }) -- Sprint
Spell( 5277 ,{ duration = 15, type = "BUFF" }) -- Evasion
Spell({ 1776, 1777, 8629, 11285, 11286 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            return 4 + 0.5*Talent(13741, 13793, 13792)
        else
            return 5.5
        end
    end
}) -- Gouge

Spell( 14251 , { duration = 6 }) -- Riposte (disarm)

------------
-- WARLOCK
------------

Spell({ 20707, 20762, 20763, 20764, 20765 }, { duration = 1800, type = "BUFF" }) -- Soulstone Resurrection
Spell({ 687, 696 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Demon SKin
Spell({ 706, 1086, 11733, 11734, 11735 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Demon Armor
Spell({ 18791 }, { duration = 1800, type = "BUFF", castFilter = true })  -- Touch of Shadow
Spell({ 18789 }, { duration = 1800, type = "BUFF", castFilter = true })  -- Burning Wish
Spell({ 18792 }, { duration = 1800, type = "BUFF", castFilter = true })  -- Fel Energy
Spell({ 18790 }, { duration = 1800, type = "BUFF", castFilter = true })  -- Fel Stamina

--SKIPPING: Drain Life, Mana, Soul, Enslave, Health funnel, kilrog
Spell( 24259 ,{ duration = 3 }) -- Spell Lock Silence
Spell({ 17767, 17850, 17851, 17852, 17853, 17854 }, { duration = 10 }) -- Consume Shadows (Voidwalker)
Spell( 18118, { duration = 5 }) -- Aftermath Proc
Spell({ 132, 2970, 11743 }, { duration = 600 }) -- Detect Invisibility
Spell( 5697, { duration = 600 }) -- Unending Breath
if class == "WARLOCK" then
    Spell({ 17794, 17798, 17797, 17799, 17800 }, { duration = 12 }) -- Shadow Vulnerability (Imp Shadow Bolt)
end
Spell({ 18288 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" })  -- Amplify Curse
Spell({ 1714, 11719 }, { duration = 30 }) -- Curse of Tongues
Spell({ 702, 1108, 6205, 7646, 11707, 11708 },{ duration = 120 }) -- Curse of Weakness
Spell({ 17862, 17937 }, { duration = 300 }) -- Curse of Shadows
Spell({ 1490, 11721, 11722 }, { duration = 300 }) -- Curse of Elements
Spell({ 704, 7658, 7659, 11717 }, { duration = 120 }) -- Curse of Recklessness
Spell( 603 ,{ duration = 60, stacking = true }) -- Curse of Doom
Spell( 18223 ,{ duration = 12 }) -- Curse of Exhaustion
Spell( 6358, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local mul = 1 + Talent(18754, 18755, 18756)*0.1
            return 15*mul
        else
            return 15
        end
    end
}) -- Seduction, varies, Improved Succubus
Spell({ 5484, 17928 }, {
    duration = function(spellID)
        return spellID == 5484 and 10 or 15
    end
}) -- Howl of Terror
Spell({ 5782, 6213, 6215 }, {
    pvpduration = 20,
    duration = function(spellID)
        if spellID == 5782 then return 10
        elseif spellID == 6213 then return 15
        else return 20 end
    end
}) -- Fear

Spell({ 710, 18647 }, {
    duration = function(spellID)
        return spellID == 710 and 20 or 30
    end
}) -- Banish
Spell({ 6789, 17925, 17926 }, { duration = 3 }) -- Death Coil
Spell({ 6307, 7804, 7805, 11766, 11767 }, { duration = INFINITY }) -- Blood Pact
Spell({ 18708 }, { duration = 15, type = "BUFF", buffType = "Magic" }) -- Fel Domination
Spell({ 19480 }, { duration = INFINITY }) -- Paranoia
Spell({ 25228 }, { duration = INFINITY, type = "BUFF", buffType = "Magic" }) -- Soul Link
Spell({ 23829 }, { duration = INFINITY, type = "BUFF" }) -- Master Demonologist
Spell({ 18265, 18879, 18880, 18881}, { duration = 30, stacking = true }) -- Siphon Life

if locale ~= "zhCN" or class ~= "MAGE" then
Spell({ 980, 1014, 6217, 11711, 11712, 11713 }, { duration = 24, stacking = true }) -- Curse of Agony
end

Spell({ 172, 6222, 6223, 7648, 11671, 11672, 25311 }, { stacking = true,
    duration = function(spellID)
        if spellID == 172 then
            return 12
        elseif spellID == 6222 then
            return 15
        else
            return 18
        end
    end
})
Spell({ 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 },{ duration = 15, stacking = true }) -- Immolate

Spell({ 6229, 11739, 11740, 28610 } ,{ duration = 30, type = "BUFF", buffType = "Magic" }) -- Shadow Ward
Spell({ 7812, 19438, 19440, 19441, 19442, 19443 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Sacrifice
Spell({ 17877, 18867, 18868, 18869, 18870, 18871 }, { duration = 5 }) -- Shadowburn Debuff
Spell( 18093 ,{ duration = 3 }) -- Pyroclasm

---------------
-- SHAMAN
---------------

Spell({ 8185, 10534, 10535 }, { duration = INFINITY, type = "BUFF" }) -- Fire Resistance Totem
Spell({ 8182, 10476, 10477 }, { duration = INFINITY, type = "BUFF" }) -- Frost Resistance Totem
Spell({ 10596, 10598, 10599 }, { duration = INFINITY, type = "BUFF" }) -- Nature Resistance Totem
Spell( 25909, { duration = INFINITY, type = "BUFF" }) -- Tranquil Air Totem
Spell({ 5672, 6371, 6372, 10460, 10461 }, { duration = INFINITY, type = "BUFF" }) -- Healing Stream Totem
Spell({ 5677, 10491, 10493, 10494 }, { duration = INFINITY, type = "BUFF" }) -- Mana Spring Totem
Spell({ 8076, 8162, 8163, 10441, 25362 }, { duration = INFINITY, type = "BUFF" }) -- Strength of Earth Totem
Spell({ 8836, 10626, 25360 }, { duration = INFINITY, type = "BUFF" }) -- Grace of Air Totem
Spell({ 8072, 8156, 8157, 10403, 10404, 10405 }, { duration = INFINITY, type = "BUFF" }) -- Stoneskin Totem
Spell({ 16191, 17355, 17360 }, { duration = 12, type = "BUFF" }) -- Mana Tide Totem
Spell( 16166, { duration = INFINITY, type = "BUFF" }) -- Elemental Mastery

Spell( 8178 ,{ duration = 45, type = "BUFF" }) -- Grounding Totem Effect, no duration, but lasts 45s. Keeping for enemy buffs

-- Using Druid's NS
-- Spell( 16188, { duration = INFINITY, type = "BUFF" }) -- Nature's Swiftness

Spell({ 324, 325, 905, 945, 8134, 10431, 10432 }, { duration = 600, type = "BUFF", buffType = "Magic" }) -- Lightning Shield
Spell( 546 ,{ duration = 600, type = "BUFF", buffType = "Magic" }) -- Water Walking
Spell( 131 ,{ duration = 600, type = "BUFF", buffType = "Magic" }) -- Water Breahing
Spell({ 16257, 16277, 16278, 16279, 16280 }, { duration = 15, type = "BUFF" }) -- Flurry

Spell( 17364 ,{ duration = 12 }) -- Stormstrike
Spell({ 16177, 16236, 16237 }, { duration = 15, type = "BUFF", buffType = "Magic" }) -- Ancestral Fortitude from Ancestral Healing
Spell({ 8056, 8058, 10472, 10473 }, { duration = 8 }) -- Frost Shock
Spell({ 8050, 8052, 8053, 10447, 10448, 29228 }, { duration = 12, stacking = true }) -- Flame Shock
Spell( 29203 ,{ duration = 15, type = "BUFF", buffType = "Magic" }) -- Healing Way
Spell({ 8034, 8037, 10458, 16352, 16353 }, { duration = 8 }) -- Frostbrand Attack
Spell( 3600 ,{ duration = 5 }) -- Earthbind Totem

--------------
-- PALADIN
--------------

Spell( 19746, { duration = INFINITY, type = "BUFF" }) -- Concentration Aura
Spell({ 465, 643, 1032, 10290, 10291, 10292, 10293 }, { duration = INFINITY, type = "BUFF" }) -- Devotion Aura
Spell({ 19891, 19899, 19900 }, { duration = INFINITY, type = "BUFF" }) -- Fire Resistance Aura
Spell({ 19888, 19897, 19898 }, { duration = INFINITY, type = "BUFF" }) -- Frost Resistance Aura
Spell({ 19876, 19895, 19896 }, { duration = INFINITY, type = "BUFF" }) -- Shadow Resistance Aura
Spell({ 7294, 10298, 10299, 10300, 10301 }, { duration = INFINITY, type = "BUFF" }) -- Retribution Aura
Spell({ 20218 }, { duration = INFINITY, type = "BUFF" }) -- Sanctity Aura


Spell( 25780, { duration = 1800, type = "BUFF", buffType = "Magic" }) -- Righteous Fury

Spell({ 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, { duration = 300, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Blessing of Might
Spell({ 25782, 25916 }, { duration = 900, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Greater Blessing of Might

Spell({ 19742, 19850, 19852, 19853, 19854, 25290 }, { duration = 300, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Blessing of Wisdom
Spell({ 25894, 25918 }, { duration = 900, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Greater Blessing of Might

Spell(20217, { duration = 300, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Blessing of Kings
Spell(25898, { duration = 900, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Greater Blessing of Kings

Spell({ 20911, 20912, 20913 }, { duration = 300, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Blessing of Sanctuary
Spell(25899, { duration = 900, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Greater Blessing of Sanctuary

Spell(1038, { duration = 300, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Blessing of Salvation
Spell(25895, { duration = 900, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Greater Blessing of Salvation

Spell({ 19977, 19978, 19979 }, { duration = 300, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Blessing of Light
Spell(25890, { duration = 900, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Greater Blessing of Light

Spell( 20066, { duration = 6 }) -- Repentance
Spell({ 2878, 5627, 5627 }, {
    duration = function(spellID)
        if spellID == 2878 then return 10
        elseif spellID == 5627 then return 15
        else return 20 end
    end
}) -- Turn Undead

Spell( 1044, {
    duration = function(spellID, isSrcPlayer)
        local talents = 0
        if isSrcPlayer then talents = 3*Talent(20174, 20175)  end
        return 10 + talents
    end, type = "BUFF", buffType = "Magic" }) -- Blessing of Freedom
Spell({ 6940, 20729 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Blessing of Sacrifice
Spell({ 1022, 5599, 10278 }, { type = "BUFF",
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 1022 then return 6
        elseif spellID == 5599 then return 8
        else return 10 end
    end
}) -- Blessing of Protection
Spell(25771, { duration = 60 }) -- Forbearance
Spell({ 498, 5573 }, { type = "BUFF",
    duration = function(spellID)
        return spellID == 498 and 6 or 8
    end
}) -- Divine Protection
Spell({ 642, 1020 }, { type = "BUFF",
    duration = function(spellID)
        return spellID == 642 and 10 or 12
    end
}) -- Divine Shield
Spell({ 20375, 20915, 20918, 20919, 20920 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Seal of Command
Spell({ 21084, 20287, 20288, 20289, 20290, 20291, 20292, 20293 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Seal of Righteousness
Spell({ 20162, 20305, 20306, 20307, 20308, 21082 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Seal of the Crusader
Spell({ 20165, 20347, 20348, 20349 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Seal of Light
Spell({ 20166, 20356, 20357 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Seal of Wisdom
Spell( 20164 , { duration = 30, type = "BUFF", buffType = "Magic" }) -- Seal of Justice

Spell({ 21183, 20188, 20300, 20301, 20302, 20303 }, { duration = 10 }) -- Judgement of the Crusader
Spell({ 20185, 20344, 20345, 20346 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local talents = 10*Talent(20359, 20360, 20361)
            return 10+talents
        else
            return 10
        end
    end
}) -- Judgement of Light
Spell({ 20186, 20354, 20355 }, {
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local talents = 10*Talent(20359, 20360, 20361)
            return 10+talents
        else
            return 10
        end
    end
}) -- Judgement of Wisdom
Spell(20184, { duration = 10 }) -- Judgement of Justice

Spell({ 853, 5588, 5589, 10308 }, {
    duration = function(spellID)
        if spellID == 853 then return 3
        elseif spellID == 5588 then return 4
        elseif spellID == 5589 then return 5
        else return 6 end
    end
}) -- Hammer of Justice

Spell({ 20925, 20927, 20928 }, { duration = 10, type = "BUFF", buffType = "Magic" }) -- Holy Shield
Spell({ 20128, 20131, 20132, 20133, 20134 }, { duration = 10, type = "BUFF" }) -- Redoubt
Spell({ 67, 26017, 26018 }, { duration = 10, type = "BUFF", buffType = "Magic" }) -- Vindication
Spell({ 20050, 20052, 20053, 20054, 20055 }, { duration = 8, type = "BUFF", buffType = "Magic" }) -- Vengeance
Spell( 20170 ,{ duration = 2 }) -- Seal of Justice stun

-------------
-- HUNTER
-------------

Spell( 13161, { duration = INFINITY, type = "BUFF" }) -- Aspect of the Beast
Spell( 5118, { duration = INFINITY, type = "BUFF" }) -- Aspect of the Cheetah
Spell( 13159, { duration = INFINITY, type = "BUFF" }) -- Aspect of the Pack
Spell( 13163, { duration = INFINITY, type = "BUFF" }) -- Aspect of the Monkey
Spell({ 20043, 20190 }, { duration = INFINITY, type = "BUFF" }) -- Aspect of the Wild
Spell({ 13165, 14318, 14319, 14320, 14321, 14322, 25296 }, { duration = INFINITY, type = "BUFF" }) -- Aspect of the Hawk
Spell( 5384, { duration = INFINITY, type = "BUFF" }) -- Feign Death (Will it work?)
Spell({ 19579, 24529 }, { duration = INFINITY, type = "BUFF" }) -- Spirit Bond

Spell({ 19506, 20905, 20906 }, { duration = 1800, type = "BUFF", castFilter = true }) -- Trueshot Aura
Spell(19615, { duration = 8, type = "BUFF" }) -- Frenzy
Spell({ 1130, 14323, 14324, 14325 }, { duration = 120 }) -- Hunter's Mark
Spell(19263, { duration = 10, type = "BUFF" }) -- Deterrence
Spell(3045, { duration = 15, type = "BUFF" }) -- Rapid Fire
Spell(19574, { duration = 18, type = "BUFF" }) -- Bestial Wrath
Spell({ 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295 }, { duration = 15, stacking = true }) -- Serpent Sting
Spell({ 3043, 14275, 14276, 14277 }, { duration = 20 }) -- Scorpid Sting
Spell({ 3034, 14279, 14280 }, { duration = 8 }) -- Viper Sting
Spell({ 19386, 24132, 24133 }, { duration = 12 }) -- Wyvern Sting
Spell({ 24131, 24134, 24135 }, { duration = 12 }) -- Wyvern Sting Dot
Spell({ 1513, 14326, 14327 }, {
    pvpduration = 20,
    duration = function(spellID)
        if spellID == 1513 then return 10
        elseif spellID == 14326 then return 15
        else return 20 end
    end
}) -- Scare Beast

Spell(19229, { duration = 5 }) -- Wing Clip Root
Spell({ 19306, 20909, 20910 }, { duration = 5 }) -- Counterattack
-- Spell({ 13812, 14314, 14315 }, { duration = 20, stacking = true }) -- Explosive Trap
Spell({ 13797, 14298, 14299, 14300, 14301 }, { duration = 15, stacking = true }) -- Immolation Trap
Spell({ 3355, 14308, 14309 }, {
    pvpduration = 20,
    duration = function(spellID, isSrcPlayer)
        local mul = 1
        if isSrcPlayer then
            mul = mul + 0.15*Talent(19239, 19245) -- Clever Traps
        end
        if spellID == 3355 then return 10*mul
        elseif spellID == 14308 then return 15*mul
        else return 20*mul end
    end
}) -- Freezing Trap
Spell(19503, { duration = 4 }) -- Scatter Shot
Spell({ 2974, 14267, 14268 }, { duration = 10 }) -- Wing Clip
Spell(5116, { duration = 4 }) -- Concussive Shot
Spell(19410, { duration = 3 }) -- Conc Stun
Spell(24394, { duration = 3 }) -- Intimidation
-- Spell(15571, { duration = 4 }) -- Daze from Aspect
Spell(19185, { duration = 5 }) -- Entrapment
Spell(25999, { duration = 1 }) -- Boar Charge
Spell({ 23099, 23109, 23110 } , { duration = 15 }) -- Dash
Spell(1002, { duration = 60 }) -- Eye of the Beast
Spell(1539, { duration = 20 }) -- Feed Pet Effect
Spell({ 136, 3111, 3661, 3662, 13542, 13543, 13544 }, { duration = 5, type = "BUFF" }) -- Mend Pet

-------------
-- MAGE
-------------

Spell( 12043, { duration = INFINITY, type = "BUFF", buffType = "Magic" }) -- Presence of Mind

Spell({ 1459, 1460, 1461, 10156, 10157 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Arcane Intellect
Spell( 23028, { duration = 3600, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Arcane Brilliance
Spell({ 6117, 22782, 22783 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Mage Armor
Spell({ 168, 7300, 7301 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Frost Armor
Spell({ 7302, 7320, 10219, 10220 }, { duration = 1800, type = "BUFF", castFilter = true, buffType = "Magic" }) -- Ice Armor

Spell( 2855, { duration = 120, type = "BUFF", buffType = "Magic" }) -- Detect Magic
Spell( 130, { duration = 1800, type = "BUFF", buffType = "Magic" }) -- Slow Fall

Spell({ 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 }, {
    stacking = true,
    duration = function(spellID)
        if spellID == 133 then return 4
        elseif spellID == 143 then return 6
        elseif spellID == 145 then return 6
        else return 8 end
    end
}) -- Fireball
Spell({ 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 }, { duration = 12, stacking = true }) -- Pyroblast

Spell({ 604, 8450, 8451, 10173, 10174 }, { duration = 600, type = "BUFF", buffType = "Magic" }) -- Dampen Magic
Spell({ 1008, 8455, 10169, 10170 }, { duration = 600, type = "BUFF", buffType = "Magic" }) -- Amplify Magic

Spell(18469, { duration = 4 }) -- Imp CS Silence
Spell({ 118, 12824, 12825, 12826, 28270, 28271, 28272 }, {
    pvpduration = 20,
    duration = function(spellID)
        if spellID == 118 then return 20
        elseif spellID == 12824 then return 30
        elseif spellID == 12825 then return 40
        else return 50 end
    end
}) -- Polymorph
Spell(11958, { duration = 10, type = "BUFF" }) -- Ice Block
Spell({ 1463, 8494, 8495, 10191, 10192, 10193 }, { duration = 60, type = "BUFF", buffType = "Magic" }) -- Mana Shield
Spell({ 11426, 13031, 13032, 13033 }, { duration = 60, type = "BUFF", buffType = "Magic" }) -- Ice Barrier
Spell({ 543, 8457, 8458, 10223, 10225 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Fire Ward
Spell({ 6143, 8461, 8462, 10177, 28609 }, { duration = 30, type = "BUFF", buffType = "Magic" }) -- Frost Ward

Spell(12355, { duration = 2 }) -- Impact
lib.spellNameToID[GetSpellInfo(12654)] = 12654
-- Spell(12654, { duration = 4 }) -- Ignite

if class == "MAGE" then
Spell(22959, {
    duration = function(spellID, isSrcPlayer)
        if Talent(11095, 12872, 12873) > 0 then
            return 30
        else
            return nil
        end
    end }) -- Fire Vulnerability
end

if class == "MAGE" then
Spell(12579, {
    duration = function(spellID, isSrcPlayer)
        if Talent(11180, 28592, 28593, 28594, 28595) > 0 then
            return 15
        else
            return nil
        end
    end }) -- Winter's Chill
end

Spell({ 11113, 13018, 13019, 13020, 13021 }, { duration = 6 }) -- Blast Wave

Spell({ 2120, 2121, 8422, 8423, 10215, 10216 }, { duration = 8, stacking = true }) -- Flamestrike

Spell({ 120, 8492, 10159, 10160, 10161 }, {
    duration = function(spellID, isSrcPlayer)
        local permafrost = isSrcPlayer and Talent(11175, 12569, 12571) or 0
        return 8 + permafrost
    end
}) -- Cone of Cold


if class == "MAGE" then
-- Chilled from Imp Blizzard
Spell({ 12484, 12485, 12486 }, {
    duration = function(spellID, isSrcPlayer)
        if Talent(11185, 12487, 12488) > 0 then -- Don't show anything if mage doesn't have imp blizzard talent
            local permafrost = Talent(11175, 12569, 12571) -- Always count player's permafost, even source isn't player.
            return 1.5 + permafrost + 0.5
            -- 0.5 compensates for delay between damage event and slow application
        else
            return nil
        end
    end
}) -- Improved Blizzard (Chilled)

-- Manually setting a custom spellname for ImpBlizzard's "Chilled" aura
lib.spellNameToID["ImpBlizzard"] = 12486
-- Frost Armor will overwrite Chilled to 7321 right after
end

Spell({6136, 7321}, {
    duration = function(spellID, isSrcPlayer)
        local permafrost = isSrcPlayer and Talent(11175, 12569, 12571) or 0
        return 5 + permafrost
    end
}) -- Frost/Ice Armor (Chilled)

Spell({ 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304 }, {
    duration = function(spellID, isSrcPlayer)
        local permafrost = isSrcPlayer and Talent(11175, 12569, 12571) or 0
        if spellID == 116 then return 5 + permafrost
        elseif spellID == 205 then return 6 + permafrost
        elseif spellID == 837 then return 6 + permafrost
        elseif spellID == 7322 then return 7 + permafrost
        elseif spellID == 8406 then return 7 + permafrost
        elseif spellID == 8407 then return 8 + permafrost
        elseif spellID == 8408 then return 8 + permafrost
        else return 9 + permafrost end
    end
}) -- Frostbolt

Spell(12494, { duration = 5 }) -- Frostbite
Spell({ 122, 865, 6131, 10230 }, { duration = 8 }) -- Frost Nova
-- Spell(12536, { duration = 15 }) -- Clearcasting
Spell(12043, { duration = 15 }) -- Presence of Mind
Spell(12042, { duration = 15 }) -- Arcane Power
Spell(12051, { duration = 8, type = "BUFF" }) -- Evocation

-------------
-- MOUNTS
-------------

Spell(17481, { duration = INFINITY, type = "BUFF" }) -- Deathcharger's Reins
Spell(24252, { duration = INFINITY, type = "BUFF" }) -- Swift Zulian Tiger
Spell(23509, { duration = INFINITY, type = "BUFF" }) -- Horn of the Frostwolf Howler
Spell(17229, { duration = INFINITY, type = "BUFF" }) -- Reins of the Winterspring Frostsaber
Spell(26656, { duration = INFINITY, type = "BUFF" }) -- Black Qiraji Resonating Crystal
Spell(24242, { duration = INFINITY, type = "BUFF" }) -- Swift Razzashi Raptor
Spell(23510, { duration = INFINITY, type = "BUFF" }) -- Stormpike Battle Charger
Spell(470, { duration = INFINITY, type = "BUFF" }) -- Black Stallion Bridle
Spell(22723, { duration = INFINITY, type = "BUFF" }) -- Reins of the Black War Tiger
Spell(472, { duration = INFINITY, type = "BUFF" }) -- Pinto Bridle
Spell(23221, { duration = INFINITY, type = "BUFF" }) -- Reins of the Swift Frostsaber
Spell(23227, { duration = INFINITY, type = "BUFF" }) -- Swift Palomino
Spell(23228, { duration = INFINITY, type = "BUFF" }) -- Swift White Steed
Spell(6648, { duration = INFINITY, type = "BUFF" }) -- Chestnut Mare Bridle
Spell(458, { duration = INFINITY, type = "BUFF" }) -- Brown Horse Bridle
Spell(23338, { duration = INFINITY, type = "BUFF" }) -- Reins of the Swift Stormsaber
Spell(23219, { duration = INFINITY, type = "BUFF" }) -- Reins of the Swift Mistsaber
Spell(22721, { duration = INFINITY, type = "BUFF" }) -- Whistle of the Black War Raptor
Spell(23229, { duration = INFINITY, type = "BUFF" }) -- Swift Brown Steed
Spell(22717, { duration = INFINITY, type = "BUFF" }) -- Black War Steed Bridle
Spell(10793, { duration = INFINITY, type = "BUFF" }) -- Reins of the Striped Nightsaber
Spell(22722, { duration = INFINITY, type = "BUFF" }) -- Red Skeletal Warhorse
Spell(18791, { duration = INFINITY, type = "BUFF" }) -- Purple Skeletal Warhorse
Spell(10789, { duration = INFINITY, type = "BUFF" }) -- Reins of the Spotted Frostsaber
Spell(18245, { duration = INFINITY, type = "BUFF" }) -- Horn of the Black War Wolf
Spell(6653, { duration = INFINITY, type = "BUFF" }) -- Horn of the Dire Wolf
Spell(23241, { duration = INFINITY, type = "BUFF" }) -- Swift Blue Raptor
Spell(8394, { duration = INFINITY, type = "BUFF" }) -- Reins of the Striped Frostsaber
Spell(23250, { duration = INFINITY, type = "BUFF" }) -- Horn of the Swift Brown Wolf
Spell(22718, { duration = INFINITY, type = "BUFF" }) -- Black War Kodo
Spell(580, { duration = INFINITY, type = "BUFF" }) -- Horn of the Timber Wolf
Spell(17463, { duration = INFINITY, type = "BUFF" }) -- Blue Skeletal Horse
Spell(23251, { duration = INFINITY, type = "BUFF" }) -- Horn of the Swift Timber Wolf
Spell(23243, { duration = INFINITY, type = "BUFF" }) -- Swift Orange Raptor
Spell(17465, { duration = INFINITY, type = "BUFF" }) -- Green Skeletal Warhorse
Spell(22720, { duration = INFINITY, type = "BUFF" }) -- Black War Ram
Spell(8395, { duration = INFINITY, type = "BUFF" }) -- Whistle of the Emerald Raptor
Spell(6654, { duration = INFINITY, type = "BUFF" }) -- Horn of the Brown Wolf
Spell(17462, { duration = INFINITY, type = "BUFF" }) -- Red Skeletal Horse
Spell(23240, { duration = INFINITY, type = "BUFF" }) -- Swift White Ram
Spell(23252, { duration = INFINITY, type = "BUFF" }) -- Horn of the Swift Gray Wolf
Spell(23247, { duration = INFINITY, type = "BUFF" }) -- Great White Kodo
Spell(23242, { duration = INFINITY, type = "BUFF" }) -- Swift Olive Raptor
Spell(23225, { duration = INFINITY, type = "BUFF" }) -- Swift Green Mechanostrider
Spell(10969, { duration = INFINITY, type = "BUFF" }) -- Blue Mechanostrider
Spell(10799, { duration = INFINITY, type = "BUFF" }) -- Whistle of the Violet Raptor
Spell(22719, { duration = INFINITY, type = "BUFF" }) -- Black Battlestrider
Spell(6898, { duration = INFINITY, type = "BUFF" }) -- White Ram
Spell(17464, { duration = INFINITY, type = "BUFF" }) -- Brown Skeletal Horse
Spell(17454, { duration = INFINITY, type = "BUFF" }) -- Unpainted Mechanostrider
Spell(23223, { duration = INFINITY, type = "BUFF" }) -- Swift White Mechanostrider
Spell(10796, { duration = INFINITY, type = "BUFF" }) -- Whistle of the Turquoise Raptor
Spell(23238, { duration = INFINITY, type = "BUFF" }) -- Swift Brown Ram
Spell(23239, { duration = INFINITY, type = "BUFF" }) -- Swift Gray Ram
Spell(6899, { duration = INFINITY, type = "BUFF" }) -- Brown Ram
Spell(6777, { duration = INFINITY, type = "BUFF" }) -- Gray Ram
Spell(10873, { duration = INFINITY, type = "BUFF" }) -- Red Mechanostrider
Spell(23249, { duration = INFINITY, type = "BUFF" }) -- Great Brown Kodo
Spell(18989, { duration = INFINITY, type = "BUFF" }) -- Gray Kodo
Spell(18990, { duration = INFINITY, type = "BUFF" }) -- Brown Kodo
Spell(23248, { duration = INFINITY, type = "BUFF" }) -- Great Gray Kodo
Spell(23222, { duration = INFINITY, type = "BUFF" }) -- Swift Yellow Mechanostrider
Spell(17453, { duration = INFINITY, type = "BUFF" }) -- Green Mechanostrider
Spell(23214, { duration = INFINITY, type = "BUFF" }) -- Summon Charger
Spell(13819, { duration = INFINITY, type = "BUFF" }) -- Summon Warhorse
Spell(23161, { duration = INFINITY, type = "BUFF" }) -- Summon Dreadsteed
Spell(5784, { duration = INFINITY, type = "BUFF" }) -- Summon Felsteed

-------------
-- ITEMS
-------------

Spell(17670, { duration = INFINITY, type = "BUFF" }) -- Argent Dawn Commission

lib:SetDataVersion(Type, Version)
