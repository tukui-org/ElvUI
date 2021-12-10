local lib = LibStub("LibClassicDurations", true)
if not lib then return end

local Type, Version = "DRTable", 7
if lib:GetDataVersion(Type) >= Version then return end

local FEAR = "FEAR"
local SILENCE = "SILENCE"
local INCAP = "INCAP"
local STUN = "STUN"
local HORROR = "HORROR"
local ROOT = "ROOT"
-- local OPENER_STUN = "OPENER_STUN"
local RANDOM_STUN = "RANDOM_STUN"
local RANDOM_ROOT = "RANDOM_ROOT"
local FROST_SHOCK = "FROST_SHOCK"
local KIDNEY_SHOT = "KIDNEY_SHOT"

lib.DR_TypesPVE = {
    [KIDNEY_SHOT] = true,
    [STUN] = true,
}

lib.DR_CategoryBySpellID = {
    -- Silences weren't on DR until 3.0.8
    -- Are random stuns even diminished at all among themselves?
    -- Random roots?

    [835] = STUN, -- Tidal Charm
    [20549] = STUN, -- War Stomp
    [16566] = ROOT, -- Net-o-Matic
    [1090] = INCAP, -- Magic Dust
    [13327] = INCAP, -- Goblin Rocket Helm, Reckless Charge
    [5134] = FEAR, -- Flash Bomb

    [5782] = FEAR, -- Fear 3 ranks
    [6213] = FEAR,
    [6215] = FEAR,
    [5484] = FEAR, -- Howl of Terror 2 ranks
    [17928] = FEAR,
    [6358] = FEAR, -- Seduction

    -- [24259] = SILENCE, -- Spell Lock

    -- Coil wasn't on DR in classic
    -- [6789]    = HORROR, -- Death Coil 3 ranks
    -- [17925]   = HORROR,
    -- [17926]   = HORROR,
    [22703] = STUN, -- Infernal Summon Stun


    [20066] = INCAP, -- Repentance

    [853] = STUN, -- Hammer of Justice 4 ranks
    [5588] = STUN,
    [5589] = STUN,
    [10308] = STUN,

    [20170] = RANDOM_STUN, -- Seal of Justice Stun



    [3355] = INCAP, -- Freezing Trap Effect 3 ranks
    [14308] = INCAP,
    [14309] = INCAP,

    [19386] = INCAP, -- Wyvern Sting 3 ranks
    [24132] = INCAP,
    [24133] = INCAP,

    [19503] = INCAP, -- Scatter Shot
    -- [19229] = RANDOM_ROOT, -- Improved Wing Clip Root

    [19306] = ROOT, -- Counterattack

    [19410] = RANDOM_STUN, -- Conc stun
    [24394] = STUN, -- Intimidation


    [2637] = INCAP, -- Hibernate 3 ranks
    [18657] = INCAP,
    [18658] = INCAP,

    [5211] = STUN, -- Bash 3 ranks
    [6798] = STUN,
    [8983] = STUN,

    [339] = ROOT, -- Entangling Roots 6 ranks
    [1062] = ROOT,
    [5195] = ROOT,
    [5196] = ROOT,
    [9852] = ROOT,
    [9853] = ROOT,
    [16922] = RANDOM_STUN, -- Improved Starfire

    [9005] = STUN, -- Pounce 3 ranks
    [9823] = STUN,
    [9827] = STUN,


    -- [18469] = SILENCE, -- Silence (Improved Counterspell)

    [118] = INCAP, -- Polymorph 7 variants
    [12824] = INCAP,
    [12825] = INCAP,
    [12826] = INCAP,
    [28270] = INCAP,
    [28271] = INCAP,
    [28272] = INCAP,

    -- Frostbite wasn't on DR until 2.1.0
    -- [12494] = RANDOM_ROOT, -- Frostbite
    [12355] = RANDOM_STUN, -- Impact

    [122] = ROOT, -- Frost Nova 4 rank
    [865] = ROOT,
    [6131] = ROOT,
    [10230] = ROOT,

    [8056] = FROST_SHOCK, -- Frost Shock 4 ranks
    [8058] = FROST_SHOCK,
    [10472] = FROST_SHOCK,
    [10473] = FROST_SHOCK,


    -- [15487] = SILENCE, -- Silence (Priest)
    [15269] = RANDOM_STUN, -- Blackout

    -- MIND CONTROL ???
    -- No Undeads for Shackle in classic

    [8122] = FEAR, -- Psychic Scream
    [8124] = FEAR,
    [10888] = FEAR,
    [10890] = FEAR,


    -- [18425] = SILENCE, -- Imp Kick
    [1833] = STUN, -- Cheap Shot
    -- Blind wasn't on Fear until some time in 3.0, and before that it was with Cyclone,
    -- and in classic probably with itself
    -- [2094] = FEAR, -- Blind

    [2070] = INCAP, -- Sap 3 ranks
    [6770] = INCAP,
    [11297] = INCAP,

    [1776] = INCAP, -- Gouge 5 ranks
    [1777] = INCAP,
    [8629] = INCAP,
    [11285] = INCAP,
    [11286] = INCAP,

    [408] = KIDNEY_SHOT, -- Kidney Shot 2 ranks
    [8643] = KIDNEY_SHOT,

    [5530] = RANDOM_STUN, -- Mace Spec Stun, shared by both Rogue and Warrior


    -- [18498] = SILENCE, -- Imp Shield Bash Silence
    -- [23694] = RANDOM_ROOT, -- Improved Hamstring Root

    -- Disarm wasn't on DR until 2.3.0
    -- [676] = "DISARM", -- Disarm

    [12809] = STUN, -- Concussion Blow
    [12798] = RANDOM_STUN, -- Improved Revenge
    [5246] = FEAR, -- Intimidating Shout
    [7922] = STUN, -- Charge

    [20253] = STUN, -- Intercept Stun 3 ranks
    [20614] = STUN,
    [20615] = STUN,
}

lib:SetDataVersion(Type, Version)