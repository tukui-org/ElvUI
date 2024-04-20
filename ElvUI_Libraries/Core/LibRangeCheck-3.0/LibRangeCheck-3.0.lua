--[[
Name: LibRangeCheck-3.0
Author(s): mitch0, WoWUIDev Community
Website: https://www.curseforge.com/wow/addons/librangecheck-3-0
Description: A range checking library based on interact distances and spell ranges
Dependencies: LibStub
License: MIT
]]

--- LibRangeCheck-3.0 provides an easy way to check for ranges and get suitable range checking functions for specific ranges.\\
-- The checkers use spell and item range checks, or interact based checks for special units where those two cannot be used.\\
-- The lib handles the refreshing of checker lists in case talents / spells change and in some special cases when equipment changes (for example some of the mage pvp gloves change the range of the Fire Blast spell), and also handles the caching of items used for item-based range checks.\\
-- A callback is provided for those interested in checker changes.
-- @usage
-- local rc = LibStub("LibRangeCheck-3.0")
--
-- rc.RegisterCallback(self, rc.CHECKERS_CHANGED, function() print("need to refresh my stored checkers") end)
--
-- local minRange, maxRange = rc:GetRange('target')
-- if not minRange then
--     print("cannot get range estimate for target")
-- elseif not maxRange then
--     print("target is over " .. minRange .. " yards")
-- else
--     print("target is between " .. minRange .. " and " .. maxRange .. " yards")
-- end
--
-- local meleeChecker = rc:GetFriendMaxChecker(rc.MeleeRange) or rc:GetFriendMinChecker(rc.MeleeRange) -- use the closest checker (MinChecker) if no valid Melee checker is found
-- for i = 1, 4 do
--     -- TODO: check if unit is valid, etc
--     if meleeChecker("party" .. i) then
--         print("Party member " .. i .. " is in Melee range")
--     end
-- end
--
-- local safeDistanceChecker = rc:GetHarmMinChecker(30)
-- -- negate the result of the checker!
-- local isSafelyAway = not safeDistanceChecker('target')
--
-- @class file
-- @name LibRangeCheck-3.0
local MAJOR_VERSION = "LibRangeCheck-3.0-ElvUI"
local MINOR_VERSION = 16 -- real minor version: 13

-- GLOBALS: LibStub, CreateFrame

---@class lib
local lib, oldminor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then
  return
end

local next = next
local type = type
local wipe = wipe
local floor = floor
local pairs = pairs
local print = print
local ipairs = ipairs
local tinsert = tinsert
local tremove = tremove
local strsplit = strsplit
local tostring = tostring
local setmetatable = setmetatable

local CheckInteractDistance = CheckInteractDistance
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetNumSpellTabs = GetNumSpellTabs
local GetSpellBookItemName = GetSpellBookItemName
local GetSpellInfo = GetSpellInfo
local GetSpellTabInfo = GetSpellTabInfo
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsItemInRange = IsItemInRange
local IsSpellInRange = IsSpellInRange
local UnitCanAssist = UnitCanAssist
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsUnit = UnitIsUnit
local UnitIsVisible = UnitIsVisible
local UnitRace = UnitRace

local C_Timer = C_Timer
local Item = Item

local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local HandSlotId = GetInventorySlotInfo("HANDSSLOT")

local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
local isEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

local IsEngravingEnabled = C_Engraving and C_Engraving.IsEngravingEnabled
local isEraSOD = IsEngravingEnabled and IsEngravingEnabled()

local InCombatLockdownRestriction
if isRetail or isEra or isCata then
  InCombatLockdownRestriction = function(unit) return InCombatLockdown() and not UnitCanAttack("player", unit) end
else
  InCombatLockdownRestriction = function() return false end
end

-- << STATIC CONFIG

local UpdateDelay = 0.5
local ItemRequestTimeout = 10.0

-- interact distance based checks. ranges are based on my own measurements (thanks for all the folks who helped me with this)
local DefaultInteractList = {
  --  [1] = 28, -- Compare Achievements
  --  [2] = 9,  -- Trade
  [3] = 8, -- Duel
  [4] = 28, -- Follow
  --  [5] = 7,  -- unknown
}

-- interact list overrides for races
local InteractLists = {
  Tauren = {
    --  [2] = 7,
    [3] = 6,
    [4] = 25,
  },
  Scourge = {
    --  [2] = 8,
    [3] = 7,
    [4] = 27,
  },
}

local MeleeRange = 2
local MatchSpellByID = {} -- specific matching to avoid incorrect index
local FriendSpells, HarmSpells, ResSpells, PetSpells = {}, {}, {}, {}

for _, n in ipairs({ "EVOKER", "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "HUNTER", "SHAMAN", "MAGE", "PALADIN", "PRIEST", "WARLOCK", "WARRIOR", "MONK", "ROGUE" }) do
  FriendSpells[n], HarmSpells[n], ResSpells[n], PetSpells[n] = {}, {}, {}, {}
end

-- Evoker
tinsert(HarmSpells.EVOKER, 369819) -- Disintegrate (25 yards)

tinsert(FriendSpells.EVOKER, 361469) -- Living Flame (25 yards)
tinsert(FriendSpells.EVOKER, 360823) -- Naturalize (Preservation) (30 yards)

tinsert(ResSpells.EVOKER, 361227) -- Return (40 yards)

-- Death Knights
tinsert(HarmSpells.DEATHKNIGHT, 49576) -- Death Grip (30 yards)
tinsert(HarmSpells.DEATHKNIGHT, 47541) -- Death Coil (Unholy) (40 yards)

tinsert(ResSpells.DEATHKNIGHT, 61999) -- Raise Ally (40 yards)

-- Demon Hunters
tinsert(HarmSpells.DEMONHUNTER, 185123) -- Throw Glaive (Havoc) (30 yards)
tinsert(HarmSpells.DEMONHUNTER, 183752) -- Consume Magic (20 yards)
tinsert(HarmSpells.DEMONHUNTER, 204021) -- Fiery Brand (Vengeance) (30 yards)

-- Druids
tinsert(FriendSpells.DRUID, 8936) -- Regrowth (40 yards, level 3)
tinsert(FriendSpells.DRUID, 774) -- Rejuvenation (Restoration) (40 yards, level 10)
tinsert(FriendSpells.DRUID, 2782) -- Remove Corruption (Restoration) (40 yards, level 19)
tinsert(FriendSpells.DRUID, 88423) -- Natures Cure (Restoration) (40 yards, level 19)

if not isRetail then
  tinsert(FriendSpells.DRUID, 5185) -- Healing Touch (40 yards, level 1, rank 1)
end

tinsert(HarmSpells.DRUID, 5176) -- Wrath (40 yards)
tinsert(HarmSpells.DRUID, 339) -- Entangling Roots (35 yards)
tinsert(HarmSpells.DRUID, 6795) -- Growl (30 yards)
tinsert(HarmSpells.DRUID, 33786) -- Cyclone (20 yards)
tinsert(HarmSpells.DRUID, 22568) -- Ferocious Bite (Melee Range)
tinsert(HarmSpells.DRUID, 8921) -- Moonfire (40 yards, level 2)

tinsert(ResSpells.DRUID, 50769) -- Revive (40 yards, level 14)
tinsert(ResSpells.DRUID, 20484) -- Rebirth (40 yards, level 29)

-- Hunters
tinsert(HarmSpells.HUNTER, 75) -- Auto Shot (40 yards)

if not isRetail then
  tinsert(HarmSpells.HUNTER, 2764) -- Throw (30 yards, level 1)
end

tinsert(PetSpells.HUNTER, 136) -- Mend Pet (45 yards)

-- Mages
tinsert(FriendSpells.MAGE, 1459) -- Arcane Intellect (40 yards, level 8)
tinsert(FriendSpells.MAGE, 475) -- Remove Curse (40 yards, level 28)

if not isRetail then
  tinsert(FriendSpells.MAGE, 130) -- Slow Fall (40 yards, level 12)
end

if isEraSOD then
  MatchSpellByID[401417] = true -- Regeneration (Rune): Conflicts with Racial Passive on Trolls

  tinsert(FriendSpells.MAGE, 401417) -- Regeneration (40 yards)
  tinsert(FriendSpells.MAGE, 412510) -- Mass Regeneration (40 yards)
end

tinsert(HarmSpells.MAGE, 44614) -- Flurry (40 yards)
tinsert(HarmSpells.MAGE, 5019) -- Shoot (30 yards)
tinsert(HarmSpells.MAGE, 118) -- Polymorph (30 yards)
tinsert(HarmSpells.MAGE, 116) -- Frostbolt (40 yards)
tinsert(HarmSpells.MAGE, 133) -- Fireball (40 yards)
tinsert(HarmSpells.MAGE, 44425) -- Arcane Barrage (40 yards)

-- Monks
tinsert(FriendSpells.MONK, 115450) -- Detox (40 yards)
tinsert(FriendSpells.MONK, 115546) -- Provoke (30 yards)
tinsert(FriendSpells.MONK, 116670) -- Vivify (40 yards)

tinsert(HarmSpells.MONK, 115546) -- Provoke (30 yards)
tinsert(HarmSpells.MONK, 115078) -- Paralysis (20 yards)
tinsert(HarmSpells.MONK, 100780) -- Tiger Palm (Melee Range)
tinsert(HarmSpells.MONK, 117952) -- Crackling Jade Lightning (40 yards)

tinsert(ResSpells.MONK, 115178) -- Resuscitate (40 yards, level 13)

-- Paladins
tinsert(FriendSpells.PALADIN, 19750) -- Flash of Light (40 yards, level 4)
tinsert(FriendSpells.PALADIN, 85673) -- Word of Glory (40 yards, level 7)
tinsert(FriendSpells.PALADIN, 4987) -- Cleanse (Holy) (40 yards, level 12)
tinsert(FriendSpells.PALADIN, 213644) -- Cleanse Toxins (Protection, Retribution) (40 yards, level 12)

if not isRetail then
  tinsert(FriendSpells.PALADIN, 635) -- Holy Light (40 yards, level 1, rank 1)
end

tinsert(HarmSpells.PALADIN, 853) -- Hammer of Justice (10 yards)
tinsert(HarmSpells.PALADIN, 35395) -- Crusader Strike (Melee Range)
tinsert(HarmSpells.PALADIN, 62124) -- Hand of Reckoning (30 yards)
tinsert(HarmSpells.PALADIN, 183218) -- Hand of Hindrance (30 yards)
tinsert(HarmSpells.PALADIN, 20271) -- Judgement (30 yards)
tinsert(HarmSpells.PALADIN, 20473) -- Holy Shock (40 yards)

tinsert(ResSpells.PALADIN, 7328) -- Redemption (40 yards)

-- Priests
if isRetail then
  tinsert(FriendSpells.PRIEST, 21562) -- Power Word: Fortitude (40 yards, level 6) [use first to fix Kyrian boon/fae soulshape]
  tinsert(FriendSpells.PRIEST, 17) -- Power Word: Shield (40 yards, level 4)
else -- PWS is group only in classic, use lesser heal as main spell check
  tinsert(FriendSpells.PRIEST, 2050) -- Lesser Heal (40 yards, level 1, rank 1)
end

tinsert(FriendSpells.PRIEST, 527) -- Purify / Dispel Magic (40 yards retail, 30 yards tbc, level 18, rank 1)
tinsert(FriendSpells.PRIEST, 2061) -- Flash Heal (40 yards, level 3 retail, level 20 tbc)

tinsert(HarmSpells.PRIEST, 589) -- Shadow Word: Pain (40 yards)
tinsert(HarmSpells.PRIEST, 585) -- Smite (40 yards)
tinsert(HarmSpells.PRIEST, 5019) -- Shoot (30 yards)

if not isRetail then
  tinsert(HarmSpells.PRIEST, 8092) -- Mindblast (30 yards, level 10)
end

tinsert(ResSpells.PRIEST, 2006) -- Resurrection (40 yards, level 10)

-- Rogues
if isRetail then
  tinsert(FriendSpells.ROGUE, 36554) -- Shadowstep (Assassination, Subtlety) (25 yards, level 18) -- works on friendly in retail
  tinsert(FriendSpells.ROGUE, 921) -- Pick Pocket (10 yards, level 24) -- this works for range, keep it in friendly as well for retail but on classic this is melee range and will return min 0 range 0
else
  tinsert(HarmSpells.ROGUE, 2764) -- Throw (30 yards)
end

tinsert(HarmSpells.ROGUE, 185565) -- Poisoned Knife (Assassination) (30 yards, level 29)
tinsert(HarmSpells.ROGUE, 36554) -- Shadowstep (Assassination, Subtlety) (25 yards, level 18)
tinsert(HarmSpells.ROGUE, 185763) -- Pistol Shot (Outlaw) (20 yards)
tinsert(HarmSpells.ROGUE, 2094) -- Blind (15 yards)
tinsert(HarmSpells.ROGUE, 921) -- Pick Pocket (10 yards, level 24)

-- Shamans
tinsert(FriendSpells.SHAMAN, 546) -- Water Walking (30 yards)
tinsert(FriendSpells.SHAMAN, 8004) -- Healing Surge (Resto, Elemental) (40 yards)
tinsert(FriendSpells.SHAMAN, 188070) -- Healing Surge (Enhancement) (40 yards)

if not isRetail then
  tinsert(FriendSpells.SHAMAN, 331) -- Healing Wave (40 yards, level 1, rank 1)
  tinsert(FriendSpells.SHAMAN, 526) -- Cure Poison (40 yards, level 16)
  tinsert(FriendSpells.SHAMAN, 2870) -- Cure Disease (40 yards, level 22)
end

tinsert(HarmSpells.SHAMAN, 370) -- Purge (30 yards)
tinsert(HarmSpells.SHAMAN, 188196) -- Lightning Bolt (40 yards)
tinsert(HarmSpells.SHAMAN, 73899) -- Primal Strike (Melee Range)

if not isRetail then
  tinsert(HarmSpells.SHAMAN, 403) -- Lightning Bolt (30 yards, level 1, rank 1)
  tinsert(HarmSpells.SHAMAN, 8042) -- Earth Shock (20 yards, level 4, rank 1)
end

tinsert(ResSpells.SHAMAN, 2008) -- Ancestral Spirit (40 yards, level 13)

-- Warriors
tinsert(HarmSpells.WARRIOR, 355) -- Taunt (30 yards)
tinsert(HarmSpells.WARRIOR, 5246) -- Intimidating Shout (Arms, Fury) (8 yards)
tinsert(HarmSpells.WARRIOR, 100) -- Charge (Arms, Fury) (8-25 yards)

if not isRetail then
  tinsert(HarmSpells.WARRIOR, 2764) -- Throw (30 yards, level 1, 5-30 range)
end

-- Warlocks
tinsert(FriendSpells.WARLOCK, 132) -- Detect Invisibility (30 yards, level 26)
tinsert(FriendSpells.WARLOCK, 5697) -- Unending Breath (30 yards)
tinsert(FriendSpells.WARLOCK, 20707) -- Soulstone (40 yards) ~ this can be precasted so leave it in friendly as well as res

if isRetail then
  tinsert(HarmSpells.WARLOCK, 234153) -- Drain Life (40 yards, level 9)
  tinsert(HarmSpells.WARLOCK, 198590) -- Drain Soul (40 yards, level 15)
  tinsert(HarmSpells.WARLOCK, 232670) -- Shadow Bolt (40 yards)
else
  tinsert(HarmSpells.WARLOCK, 172) -- Corruption (30/33/36 yards, level 4, rank 1)
  tinsert(HarmSpells.WARLOCK, 348) -- Immolate (30/33/36 yards, level 1, rank 1)
  tinsert(HarmSpells.WARLOCK, 17877) -- Shadowburn (Destruction) (20/22/24 yards, rank 1)
  tinsert(HarmSpells.WARLOCK, 18223) -- Curse of Exhaustion (Affliction) (30/33/36/35/38/42 yards)
  tinsert(HarmSpells.WARLOCK, 689) -- Drain Life (Affliction) (20/22/24 yards, level 14, rank 1)
  tinsert(HarmSpells.WARLOCK, 403677) -- Master Channeler (Affliction) (20/22/24 yards, level 14, rank 1)
end

tinsert(HarmSpells.WARLOCK, 5019) -- Shoot (30 yards)
tinsert(HarmSpells.WARLOCK, 686) -- Shadow Bolt (Demonology, Affliction) (40 yards)
tinsert(HarmSpells.WARLOCK, 5782) -- Fear (30 yards)

tinsert(ResSpells.WARLOCK, 20707) -- Soulstone (40 yards)

tinsert(PetSpells.WARLOCK, 755) -- Health Funnel (45 yards)

-- Items [Special thanks to Maldivia for the nice list]

local FriendItems = {
  [2] = {
    37727, -- Ruby Acorn
  },
  [3] = {
    42732, -- Everfrost Razor
  },
  [5] = {
    8149, -- Voodoo Charm
    136605, -- Solendra's Compassion
    63427, -- Worgsaw
  },
  [8] = {
    34368, -- Attuned Crystal Cores
    33278, -- Burning Torch
  },
  [10] = {
    32321, -- Sparrowhawk Net
    17626, -- Frostwolf Muzzle
  },
  [15] = {
    1251, -- Linen Bandage
    2581, -- Heavy Linen Bandage
    3530, -- Wool Bandage
    3531, -- Heavy Wool Bandage
    6450, -- Silk Bandage
    6451, -- Heavy Silk Bandage
    8544, -- Mageweave Bandage
    8545, -- Heavy Mageweave Bandage
    14529, -- Runecloth Bandage
    14530, -- Heavy Runecloth Bandage
    21990, -- Netherweave Bandage
    21991, -- Heavy Netherweave Bandage
    34721, -- Frostweave Bandage
    34722, -- Heavy Frostweave Bandage
    --38643, -- Thick Frostweave Bandage (uncomment for Wotlk)
    --38640, -- Dense Frostweave Bandage (uncomment for Wotlk)
  },
  [20] = {
    21519, -- Mistletoe
  },
  [25] = {
    31463, -- Zezzak's Shard
    13289, -- Egan's Blaster
  },
  [30] = {
    1180, -- Scroll of Stamina
    1478, -- Scroll of Protection II
    3012, -- Scroll of Agility
    1712, -- Scroll of Spirit II
    2290, -- Scroll of Intellect II
    1711, -- Scroll of Stamina II
    34191, -- Handful of Snowflakes
  },
  [35] = {
    18904, -- Zorbin's Ultra-Shrinker
  },
  [40] = {
    34471, -- Vial of the Sunwell
  },
  [45] = {
    32698, -- Wrangling Rope
  },
  [60] = {
    32825, -- Soul Cannon
    37887, -- Seeds of Nature's Wrath
  },
  [70] = {
    41265, -- Eyesore Blaster
  },
  [80] = {
    35278, -- Reinforced Net
  },
  [100] = {
    41058, -- Hyldnir Harpoon
  },
  [150] = {
    46954, -- Flaming Spears
  },
}

if isRetail then
  FriendItems[1] = {
    90175, -- Gin-Ji Knife Set -- doesn't seem to work for pets (always returns nil)
  }
  FriendItems[4] = {
    129055, -- Shoe Shine Kit
  }
  FriendItems[7] = {
    61323, -- Ruby Seeds
  }
  FriendItems[38] = {
    140786, -- Ley Spider Eggs
  }
  FriendItems[55] = {
    74637, -- Kiryn's Poison Vial
  }
  FriendItems[50] = {
    116139, -- Haunting Memento
  }
  FriendItems[90] = {
    133925, -- Fel Lash
  }
  FriendItems[200] = {
    75208, -- Rancher's Lariat
  }
end

local HarmItems = {
  [1] = {},
  [2] = {
    37727, -- Ruby Acorn
  },
  [3] = {
    42732, -- Everfrost Razor
  },
  [5] = {
    8149, -- Voodoo Charm
    136605, -- Solendra's Compassion
    63427, -- Worgsaw
  },
  [8] = {
    34368, -- Attuned Crystal Cores
    33278, -- Burning Torch
  },
  [10] = {
    32321, -- Sparrowhawk Net
    17626, -- Frostwolf Muzzle
  },
  [15] = {
    33069, -- Sturdy Rope
  },
  [20] = {
    10645, -- Gnomish Death Ray
  },
  [25] = {
    24268, -- Netherweave Net
    41509, -- Frostweave Net
    31463, -- Zezzak's Shard
    13289, -- Egan's Blaster
  },
  [30] = {
    835, -- Large Rope Net
    7734, -- Six Demon Bag
    34191, -- Handful of Snowflakes
  },
  [35] = {
    24269, -- Heavy Netherweave Net
    18904, -- Zorbin's Ultra-Shrinker
  },
  [40] = {
    28767, -- The Decapitator
  },
  [45] = {
    --32698, -- Wrangling Rope
    23836, -- Goblin Rocket Launcher
  },
  [60] = {
    32825, -- Soul Cannon
    37887, -- Seeds of Nature's Wrath
  },
  [70] = {
    41265, -- Eyesore Blaster
  },
  [80] = {
    35278, -- Reinforced Net
  },
  [100] = {
    33119, -- Malister's Frost Wand
  },
  [150] = {
    46954, -- Flaming Spears
  },
}

if isRetail then
  HarmItems[4] = {
    129055, -- Shoe Shine Kit
  }
  HarmItems[7] = {
    61323, -- Ruby Seeds
  }
  HarmItems[38] = {
    140786, -- Ley Spider Eggs
  }
  HarmItems[50] = {
    116139, -- Haunting Memento
  }
  HarmItems[55] = {
    74637, -- Kiryn's Poison Vial
  }
  HarmItems[90] = {
    133925, -- Fel Lash
  }
  HarmItems[200] = {
    75208, -- Rancher's Lariat
  }
end

-- This could've been done by checking player race as well and creating tables for those, but it's easier like this
for _, v in pairs(FriendSpells) do
  tinsert(v, 28880) -- Gift of the Naaru (40 yards)
end

-- >> END OF STATIC CONFIG

-- temporary stuff

local pendingItemRequest = {}
local itemRequestTimeoutAt = {}
local foundNewItems
local cacheAllItems
local friendItemRequests
local harmItemRequests
local lastUpdate = 0

local checkers_Spell = setmetatable({}, {
  __index = function(t, spellIdx)
    local func = function(unit)
      if IsSpellInRange(spellIdx, BOOKTYPE_SPELL, unit) == 1 then
        return true
      end
    end
    t[spellIdx] = func
    return func
  end,
})

local checkers_Item = setmetatable({}, {
  __index = function(t, item)
    local func = function(unit, skipInCombatCheck)
      if not skipInCombatCheck and InCombatLockdownRestriction(unit) then
        return nil
      else
        return IsItemInRange(item, unit) or nil
      end
    end
    t[item] = func
    return func
  end,
})

local checkers_Interact = setmetatable({}, {
  __index = function(t, index)
    local func = function(unit, skipInCombatCheck)
      if not skipInCombatCheck and InCombatLockdownRestriction(unit) then
        return nil
      else
        return CheckInteractDistance(unit, index) and true or false
      end
    end
    t[index] = func
    return func
  end,
})

local checkers_SpellWithMin = setmetatable({}, {
  __index = function(t, key, value)
    if key == 'MinInteractList' then
      return value
    else
      local which, id = strsplit(':', key)
      local isInteract = which == 'interact'

      local func = function(unit, skipInCombatCheck)
        if isInteract then
          local interactCheck = checkers_Interact[id]
          if interactCheck and interactCheck(unit, skipInCombatCheck) then
            return true
          end
        else
          local spellCheck = checkers_Spell[id]
          if spellCheck and spellCheck(unit) then
            return true
          elseif t.MinInteractList then -- fallback to try interact when a spell failed
            for index in pairs(t.MinInteractList) do
              local interactCheck = checkers_Interact[index]
              if interactCheck and interactCheck(unit, skipInCombatCheck) then
                return true
              end
            end
          end
        end
      end

      t[id] = func

      return func
    end
  end,
})

-- helper functions
local function copyTable(src, dst)
  if type(dst) ~= "table" then
    dst = {}
  end
  if type(src) == "table" then
    for k, v in pairs(src) do
      if type(v) == "table" then
        v = copyTable(v, dst[k])
      end
      dst[k] = v
    end
  end
  return dst
end

local function initItemRequests(cacheAll)
  friendItemRequests = copyTable(FriendItems)
  harmItemRequests = copyTable(HarmItems)
  cacheAllItems = cacheAll
  foundNewItems = nil
end

local function getNumSpells()
  local _, _, offset, numSpells = GetSpellTabInfo(GetNumSpellTabs())
  return offset + numSpells
end

-- return the spellIndex of the given spell by scanning the spellbook
local function findSpellIdx(spellName, sid)
  if not spellName or spellName == "" then
    return nil
  end

  for i = 1, getNumSpells() do
    local name, _, id = GetSpellBookItemName(i, BOOKTYPE_SPELL)
    if sid == id or (spellName == name and not MatchSpellByID[id]) then
      return i
    end
  end

  return nil
end

local function fixRange(range)
  if range then
    return floor(range + 0.5)
  end
end

local function getSpellData(sid)
  local name, _, _, _, minRange, range = GetSpellInfo(sid)
  return name, fixRange(minRange), fixRange(range), findSpellIdx(name, sid)
end

-- minRange should be nil if there's no minRange, not 0
local function addChecker(t, range, minRange, checker, info)
  local rc = { ["range"] = range, ["minRange"] = minRange, ["checker"] = checker, ["info"] = info }
  for i = 1, #t do
    local v = t[i]
    if rc.range == v.range then
      return
    end
    if rc.range > v.range then
      tinsert(t, i, rc)
      return
    end
  end
  tinsert(t, rc)
end

local function createCheckerList(spellList, itemList, interactList)
  local res, resInCombat = {}, {}
  if itemList then
    for range, items in pairs(itemList) do
      for i = 1, #items do
        local item = items[i]
        if Item:CreateFromItemID(item):IsItemDataCached() and GetItemInfo(item) then
          addChecker(res, range, nil, checkers_Item[item], "item:" .. item)
          break
        end
      end
    end
  end

  local minInteract
  if spellList then
    for i = 1, #spellList do
      local sid = spellList[i]
      local name, minRange, range, spellIdx = getSpellData(sid)
      if spellIdx and range then
        -- print("### spell: " .. tostring(name) .. ", " .. tostring(minRange) .. " - " ..  tostring(range))

        if minRange == 0 then -- getRange() expects minRange to be nil in this case
          minRange = nil
        end

        if range == 0 then
          range = MeleeRange
        end

        if minRange then
          if not checkers_SpellWithMin.MinInteractList then
            checkers_SpellWithMin.MinInteractList = interactList
          end

          addChecker(res, range, minRange, checkers_SpellWithMin["spell:"..spellIdx], "spell:" .. sid .. ":" .. tostring(name))
          addChecker(resInCombat, range, minRange, checkers_SpellWithMin["spell:"..spellIdx], "spell:" .. sid .. ":" .. tostring(name))

          minInteract = true
        else
          addChecker(res, range, minRange, checkers_Spell[spellIdx], "spell:" .. sid .. ":" .. tostring(name))
          addChecker(resInCombat, range, minRange, checkers_Spell[spellIdx], "spell:" .. sid .. ":" .. tostring(name))
        end
      end
    end
  end

  if interactList and (minInteract or not next(res)) then
    local _, playerClass = UnitClass("player")
    for index, range in pairs(interactList) do
      if minInteract then -- spells have min range, step to use interact as a fallback when close
        if not (playerClass == "WARRIOR" and index == 4) then -- warrior: skip Follow 28, so it will use Charge 25
          addChecker(res, range, nil, checkers_SpellWithMin["interact:"..index], "interact:" .. index)
        end
      else
        addChecker(res, range, nil, checkers_Interact[index], "interact:" .. index)
      end
    end
  end

  return res, resInCombat
end

local rangeCache = {}

local function resetRangeCache()
  wipe(rangeCache)
end

local function invalidateRangeCache(maxAge)
  local currentTime = GetTime()
  for k, v in pairs(rangeCache) do
    -- if the entry is older than maxAge, clear this data from the cache
    if v.updateTime + maxAge < currentTime then
      rangeCache[k] = nil
    end
  end
end

-- returns minRange, maxRange  or nil
local function getRangeWithCheckerList(unit, checkerList)
  local lo, hi = 1, #checkerList
  while lo <= hi do
    local mid = floor((lo + hi) / 2)
    local rc = checkerList[mid]
    if rc.checker(unit, true) then
      lo = mid + 1
    else
      hi = mid - 1
    end
  end
  if #checkerList == 0 then
    return nil, nil
  elseif lo > #checkerList then
    return 0, checkerList[#checkerList].range
  elseif lo <= 1 then
    return checkerList[1].range, nil
  else
    return checkerList[lo].range, checkerList[lo - 1].range
  end
end

local function getRange(unit, noItems)
  local canAssist = UnitCanAssist("player", unit)
  if UnitIsDeadOrGhost(unit) then
    if canAssist then
      return getRangeWithCheckerList(unit, InCombatLockdownRestriction(unit) and lib.resRCInCombat or lib.resRC)
    else
      return getRangeWithCheckerList(unit, InCombatLockdownRestriction(unit) and lib.miscRCInCombat or lib.miscRC)
    end
  end

  if UnitCanAttack("player", unit) then
    return getRangeWithCheckerList(unit, noItems and lib.harmNoItemsRC or lib.harmRC)
  elseif UnitIsUnit("pet", unit) then
    if InCombatLockdownRestriction(unit) then
      local minRange, maxRange = getRangeWithCheckerList(unit, noItems and lib.friendNoItemsRCInCombat or lib.friendRCInCombat)
      if minRange or maxRange then
        return minRange, maxRange
      else
        return getRangeWithCheckerList(unit, lib.petRCInCombat)
      end
    else
      local minRange, maxRange = getRangeWithCheckerList(unit, noItems and lib.friendNoItemsRC or lib.friendRC)
      if minRange or maxRange then
        return minRange, maxRange
      else
        return getRangeWithCheckerList(unit, lib.petRC)
      end
    end
  elseif canAssist then
    if InCombatLockdownRestriction(unit) then
      return getRangeWithCheckerList(unit, noItems and lib.friendNoItemsRCInCombat or lib.friendRCInCombat)
    else
      return getRangeWithCheckerList(unit, noItems and lib.friendNoItemsRC or lib.friendRC)
    end
  else
    return getRangeWithCheckerList(unit, InCombatLockdownRestriction(unit) and lib.miscRCInCombat or lib.miscRC)
  end
end

local function getCachedRange(unit, noItems, maxCacheAge)
  -- maxCacheAge has a default of 0.1 and a maximum of 1 second
  maxCacheAge = maxCacheAge or 0.1
  maxCacheAge = maxCacheAge > 1 and 1 or maxCacheAge

  -- compose cache key out of unit guid and noItems
  local guid = UnitGUID(unit)
  local cacheKey = guid .. (noItems and "-1" or "-0")
  local cacheItem = rangeCache[cacheKey]

  local currentTime = GetTime()

  -- if then cache item is valid return it
  if cacheItem and cacheItem.updateTime + maxCacheAge > currentTime then
    return cacheItem.minRange, cacheItem.maxRange
  end

  -- otherwise create a new or update the existing cache item
  local result = cacheItem or {}
  result.minRange, result.maxRange = getRange(unit, noItems)
  result.updateTime = currentTime
  rangeCache[cacheKey] = result
  return result.minRange, result.maxRange
end

local function updateList(origList, newList)
  if #origList ~= #newList then
    wipe(origList)
    copyTable(newList, origList)
    return true
  end
  for i = 1, #origList do
    if origList[i].range ~= newList[i].range or origList[i].checker ~= newList[i].checker then
      wipe(origList)
      copyTable(newList, origList)
      return true
    end
  end
end

local function updateCheckers(origList, origList2, newList, newList2)
  local changed = updateList(origList, newList)
  changed = updateList(origList2, newList2) or changed
  return changed
end

local function rcIterator(checkerList)
  local curr = #checkerList
  return function()
    local rc = checkerList[curr]
    if not rc then
      return nil
    end
    curr = curr - 1
    return rc.range, rc.checker
  end
end

local function getMinChecker(checkerList, range)
  local checker, checkerRange
  for i = 1, #checkerList do
    local rc = checkerList[i]
    if rc.range < range then
      return checker, checkerRange
    end
    checker, checkerRange = rc.checker, rc.range
  end
  return checker, checkerRange
end

local function getMaxChecker(checkerList, range)
  for i = 1, #checkerList do
    local rc = checkerList[i]
    if rc.range <= range then
      return rc.checker, rc.range
    end
  end
end

local function getChecker(checkerList, range)
  for i = 1, #checkerList do
    local rc = checkerList[i]
    if rc.range == range then
      return rc.checker
    end
  end
end

local function null() end

local function createSmartChecker(friendChecker, harmChecker, miscChecker)
  miscChecker = miscChecker or null
  friendChecker = friendChecker or miscChecker
  harmChecker = harmChecker or miscChecker
  return function(unit)
    if not UnitExists(unit) then
      return nil
    end
    if UnitIsDeadOrGhost(unit) then
      return miscChecker(unit)
    end
    if UnitCanAttack("player", unit) then
      return harmChecker(unit)
    elseif UnitCanAssist("player", unit) then
      return friendChecker(unit)
    else
      return miscChecker(unit)
    end
  end
end

local minItemChecker = function(item)
  if GetItemInfo(item) then
    return function(unit)
      return IsItemInRange(item, unit)
    end
  end
end

-- OK, here comes the actual lib

-- pre-initialize the checkerLists here so that we can return some meaningful result even if
-- someone manages to call us before we're properly initialized. miscRC should be independent of
-- race/class/talents, so it's safe to initialize it here
-- friendRC and harmRC will be properly initialized later when we have all the necessary data for them
lib.checkerCache_Spell = lib.checkerCache_Spell or {}
lib.checkerCache_Item = lib.checkerCache_Item or {}
lib.miscRC = createCheckerList(nil, nil, DefaultInteractList)
lib.miscRCInCombat = {}
lib.friendRC = createCheckerList(nil, nil, DefaultInteractList)
lib.friendRCInCombat = {}
lib.harmRC = createCheckerList(nil, nil, DefaultInteractList)
lib.harmRCInCombat = {}
lib.resRC = createCheckerList(nil, nil, DefaultInteractList)
lib.resRCInCombat = {}
lib.petRC = createCheckerList(nil, nil, DefaultInteractList)
lib.petRCInCombat = {}
lib.friendNoItemsRC = createCheckerList(nil, nil, DefaultInteractList)
lib.friendNoItemsRCInCombat = {}
lib.harmNoItemsRC = createCheckerList(nil, nil, DefaultInteractList)
lib.harmNoItemsRCInCombat = {}

lib.failedItemRequests = {}

-- << Public API

--- The callback name that is fired when checkers are changed.
-- @field
lib.CHECKERS_CHANGED = "CHECKERS_CHANGED"
-- "export" it, maybe someone will need it for formatting
--- Constant for Melee range (2yd).
-- @field
lib.MeleeRange = MeleeRange

function lib:findSpellIndex(spell)
  local name, _, _, _, _, _, sid = GetSpellInfo(spell)
  return findSpellIdx(name, sid)
end

-- returns the range estimate as a string
-- deprecated, use :getRange(unit) instead and build your own strings
-- @param checkVisible if set to true, then a UnitIsVisible check is made, and **nil** is returned if the unit is not visible
function lib:getRangeAsString(unit, checkVisible, showOutOfRange)
  local minRange, maxRange = self:getRange(unit, checkVisible)
  if not minRange then
    return nil
  end
  if not maxRange then
    return showOutOfRange and minRange .. " +" or nil
  end
  return minRange .. " - " .. maxRange
end

-- initialize RangeCheck if not yet initialized or if "forced"
function lib:init(forced)
  if self.initialized and not forced then
    return
  end
  self.initialized = true
  local _, playerClass = UnitClass("player")
  local _, playerRace = UnitRace("player")

  local interactList = InteractLists[playerRace] or DefaultInteractList
  self.handSlotItem = GetInventoryItemLink("player", HandSlotId)
  local changed = false
  if updateCheckers(self.friendRC, self.friendRCInCombat, createCheckerList(FriendSpells[playerClass], FriendItems, interactList)) then
    changed = true
  end
  if updateCheckers(self.harmRC, self.harmRCInCombat, createCheckerList(HarmSpells[playerClass], HarmItems, interactList)) then
    changed = true
  end
  if updateCheckers(self.friendNoItemsRC, self.friendNoItemsRCInCombat, createCheckerList(FriendSpells[playerClass], nil, interactList)) then
    changed = true
  end
  if updateCheckers(self.harmNoItemsRC, self.harmNoItemsRCInCombat, createCheckerList(HarmSpells[playerClass], nil, interactList)) then
    changed = true
  end
  if updateCheckers(self.miscRC, self.miscRCInCombat, createCheckerList(nil, nil, interactList)) then
    changed = true
  end
  if updateCheckers(self.resRC, self.resRCInCombat, createCheckerList(ResSpells[playerClass], nil, interactList)) then
    changed = true
  end
  if updateCheckers(self.petRC, self.petRCInCombat, createCheckerList(PetSpells[playerClass], nil, interactList)) then
    changed = true
  end
  if changed and self.callbacks then
    self.callbacks:Fire(self.CHECKERS_CHANGED)
  end
end

--- Return an iterator for checkers usable on friendly units as (**range**, **checker**) pairs.
-- @param inCombat if true, only checkers that can be used in combat ar returned
function lib:GetFriendCheckers(inCombat)
  return rcIterator(inCombat and self.friendRCInCombat or self.friendRC)
end

--- Return an iterator for checkers usable on friendly units as (**range**, **checker**) pairs.
-- @param inCombat if true, only checkers that can be used in combat ar returned
function lib:GetFriendCheckersNoItems(inCombat)
  return rcIterator(inCombat and self.friendNoItemsRCInCombat or self.friendNoItemsRC)
end


--- Return an iterator for checkers usable on enemy units as (**range**, **checker**) pairs.
-- @param inCombat if true, only checkers that can be used in combat ar returned
function lib:GetHarmCheckers(inCombat)
  return rcIterator(inCombat and self.harmRCInCombat or self.harmRC)
end


--- Return an iterator for checkers usable on enemy units as (**range**, **checker**) pairs.
-- @param inCombat if true, only checkers that can be used in combat ar returned
function lib:GetHarmCheckersNoItems(inCombat)
  return rcIterator(inCombat and self.harmNoItemsRCInCombat or self.harmNoItemsRC)
end


--- Return an iterator for checkers usable on miscellaneous units as (**range**, **checker**) pairs.  These units are neither enemy nor friendly, such as people in sanctuaries or corpses.
-- @param inCombat if true, only checkers that can be used in combat ar returned
function lib:GetMiscCheckers(inCombat)
  return rcIterator(inCombat and self.miscRCInCombat or self.miscRC)
end

--- Return a checker suitable for out-of-range checking on friendly units, that is, a checker whose range is equal or larger than the requested range.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetFriendMinChecker(range, inCombat)
  return getMinChecker(inCombat and self.friendRCInCombat or self.friendRC , range)
end

--- Return a checker suitable for out-of-range checking on enemy units, that is, a checker whose range is equal or larger than the requested range.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetHarmMinChecker(range, inCombat)
  return getMinChecker(inCombat and self.harmRCInCombat or self.harmRC, range)
end

--- Return a checker suitable for out-of-range checking on miscellaneous units, that is, a checker whose range is equal or larger than the requested range.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetMiscMinChecker(range, inCombat)
  return getMinChecker(inCombat and self.miscRCInCombat or self.miscRC, range)
end

--- Return a checker suitable for in-range checking on friendly units, that is, a checker whose range is equal or smaller than the requested range.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetFriendMaxChecker(range, inCombat)
  return getMaxChecker(inCombat and self.friendRCInCombat or self.friendRC, range)
end

--- Return a checker suitable for in-range checking on enemy units, that is, a checker whose range is equal or smaller than the requested range.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetHarmMaxChecker(range, inCombat)
  return getMaxChecker(inCombat and self.harmRCInCombat or self.harmRC, range)
end

--- Return a checker suitable for in-range checking on miscellaneous units, that is, a checker whose range is equal or smaller than the requested range.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetMiscMaxChecker(range, inCombat)
  return getMaxChecker(inCombat and self.miscRCInCombat and self.miscRC, range)
end

--- Return a checker for the given range for friendly units.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker** function or **nil** if no suitable checker is available.
function lib:GetFriendChecker(range, inCombat)
  return getChecker(inCombat and self.friendRCInCombat or self.friendRC, range)
end

--- Return a checker for the given range for enemy units.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker** function or **nil** if no suitable checker is available.
function lib:GetHarmChecker(range, inCombat)
  return getChecker(inCombat and self.harmRCInCombat or self.harmRC, range)
end

--- Return a checker for the given range for miscellaneous units.
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker** function or **nil** if no suitable checker is available.
function lib:GetMiscChecker(range, inCombat)
  return getChecker(inCombat and self.miscRCInCombat or self.miscRC, range)
end

--- Return a checker suitable for out-of-range checking that checks the unit type and calls the appropriate checker (friend/harm/misc).
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker** function.
function lib:GetSmartMinChecker(range, inCombat)
  if inCombat then
    return createSmartChecker(getMinChecker(self.friendRCInCombat, range),
                              getMinChecker(self.harmRCInCombat, range),
                              getMinChecker(self.miscRCInCombat, range))
  else
    return createSmartChecker(getMinChecker(self.friendRC, range),
                              getMinChecker(self.harmRC, range),
                              getMinChecker(self.miscRC, range))
  end
end

--- Return a checker suitable for in-range checking that checks the unit type and calls the appropriate checker (friend/harm/misc).
-- @param range the range to check for.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker** function.
function lib:GetSmartMaxChecker(range, inCombat)
  if inCombat then
    return createSmartChecker(getMaxChecker(self.friendRCInCombat, range),
                              getMaxChecker(self.harmRCInCombat, range),
                              getMaxChecker(self.miscRCInCombat, range))
  else
    return createSmartChecker(getMaxChecker(self.friendRC, range),
                              getMaxChecker(self.harmRC, range),
                              getMaxChecker(self.miscRC, range))
  end
end

--- Return a checker for the given range that checks the unit type and calls the appropriate checker (friend/harm/misc).
-- @param range the range to check for.
-- @param fallback optional fallback function that gets called as fallback(unit) if a checker is not available for the given type (friend/harm/misc) at the requested range. The default fallback function return nil.
-- @param inCombat if true, only checkers that can be used in combat ar returned
-- @return **checker** function.
function lib:GetSmartChecker(range, fallback, inCombat)
  if inCombat then
    return createSmartChecker(getChecker(self.friendRCInCombat, range) or fallback,
                              getChecker(self.harmRCInCombat, range) or fallback,
                              getChecker(self.miscRCInCombat, range) or fallback)
  else
    return createSmartChecker(getChecker(self.friendRC, range) or fallback,
                              getChecker(self.harmRC, range) or fallback,
                              getChecker(self.miscRC, range) or fallback)
  end
end

--- Get a range estimate as **minRange**, **maxRange**.
-- @param unit the target unit to check range to.
-- @param checkVisible if set to true, then a UnitIsVisible check is made, and **nil** is returned if the unit is not visible
-- @param noItems if set to true, no items and only spells are being used for the range check
-- @param maxCacheAge the timespan a cached range value is considered valid (default 0.1 seconds, maximum 1 second)
-- @return **minRange**, **maxRange** pair if a range estimate could be determined, **nil** otherwise. **maxRange** is **nil** if **unit** is further away than the highest possible range we can check.
-- Includes checks for unit validity and friendly/enemy status.
-- @usage
-- local rc = LibStub("LibRangeCheck-3.0")
-- local minRange, maxRange = rc:GetRange('target')
-- local minRangeIfVisible, maxRangeIfVisible = rc:GetRange('target', true)
function lib:GetRange(unit, checkVisible, noItems, maxCacheAge)
  if not UnitExists(unit) then
    return nil
  end

  if checkVisible and not UnitIsVisible(unit) then
    return nil
  end

  return getCachedRange(unit, noItems, maxCacheAge)
end

-- keep this for compatibility
lib.getRange = lib.GetRange

-- >> Public API

function lib:OnEvent(event, ...)
  if type(self[event]) == "function" then
    self[event](self, event, ...)
  end
end

function lib:LEARNED_SPELL_IN_TAB()
  self:scheduleInit()
end

function lib:CHARACTER_POINTS_CHANGED()
  self:scheduleInit()
end

function lib:PLAYER_TALENT_UPDATE()
  self:scheduleInit()
end

function lib:SPELLS_CHANGED()
  self:scheduleInit()
end

function lib:CVAR_UPDATE(_, cvar)
  if cvar == "ShowAllSpellRanks" then
    self:scheduleInit()
  end
end

function lib:UNIT_INVENTORY_CHANGED(event, unit)
  if self.initialized and unit == "player" and self.handSlotItem ~= GetInventoryItemLink("player", HandSlotId) then
    self:scheduleInit()
  end
end

function lib:UNIT_AURA(event, unit)
  if self.initialized and unit == "player" then
    self:scheduleAuraCheck()
  end
end

function lib:GET_ITEM_INFO_RECEIVED(event, item, success)
  -- print("### GET_ITEM_INFO_RECEIVED: " .. tostring(item) .. ", " .. tostring(success))
  if pendingItemRequest[item] then
    pendingItemRequest[item] = nil
    itemRequestTimeoutAt[item] = nil
    if not success then
      self.failedItemRequests[item] = true
    end
    lastUpdate = UpdateDelay
  end
end

function lib:processItemRequests(itemRequests)
  while true do
    local range, items = next(itemRequests)
    if not range then
      return
    end
    while true do
      local i, item = next(items)
      if not i then
        itemRequests[range] = nil
        break
      elseif Item:CreateFromItemID(item):IsItemEmpty() or self.failedItemRequests[item] then
        -- print("### processItemRequests: failed: " .. tostring(item))
        tremove(items, i)
      elseif pendingItemRequest[item] and GetTime() < itemRequestTimeoutAt[item] then
        return true -- still waiting for server response
      elseif GetItemInfo(item) then
        -- print("### processItemRequests: found: " .. tostring(item))
        foundNewItems = true
        itemRequestTimeoutAt[item] = nil
        pendingItemRequest[item] = nil
        if not cacheAllItems then
          itemRequests[range] = nil
          break
        end
        tremove(items, i)
      elseif not itemRequestTimeoutAt[item] then
        -- print("### processItemRequests: waiting: " .. tostring(item))
        itemRequestTimeoutAt[item] = GetTime() + ItemRequestTimeout
        pendingItemRequest[item] = true
        if not self.frame:IsEventRegistered("GET_ITEM_INFO_RECEIVED") then
          self.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        end
        return true
      elseif GetTime() >= itemRequestTimeoutAt[item] then
        -- print("### processItemRequests: timeout: " .. tostring(item))
        if cacheAllItems then
          print(MAJOR_VERSION .. ": timeout for item: " .. tostring(item))
        end
        self.failedItemRequests[item] = true
        itemRequestTimeoutAt[item] = nil
        pendingItemRequest[item] = nil
        tremove(items, i)
      else
        return true -- still waiting for server response
      end
    end
  end
end

function lib:initialOnUpdate()
  self:init()
  if friendItemRequests then
    if self:processItemRequests(friendItemRequests) then
      return
    end
    friendItemRequests = nil
  end
  if harmItemRequests then
    if self:processItemRequests(harmItemRequests) then
      return
    end
    harmItemRequests = nil
  end
  if foundNewItems then
    self:init(true)
    foundNewItems = nil
  end
  if cacheAllItems then
    print(MAJOR_VERSION .. ": finished cache")
    cacheAllItems = nil
  end
  self.frame:Hide()
  self.frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
end

function lib:scheduleInit()
  self.initialized = nil
  lastUpdate = 0
  self.frame:Show()
end

function lib:scheduleAuraCheck()
  lastUpdate = UpdateDelay
  self.frame:Show()
end

-- << load-time initialization

local function invalidateRangeFive()
  invalidateRangeCache(5)
end

function lib:activate()
  if not self.frame then
    local frame = CreateFrame("Frame")
    self.frame = frame

    frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    frame:RegisterEvent("SPELLS_CHANGED")

    if isEra or isCata then
      frame:RegisterEvent("CVAR_UPDATE")
    end

    if isRetail or isCata then
      frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    end

    local _, playerClass = UnitClass("player")
    if playerClass == "MAGE" or playerClass == "SHAMAN" then
      -- Mage and Shaman gladiator gloves modify spell ranges
      frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
    end
  end

  if not self.cacheResetTimer then
    self.cacheResetTimer = C_Timer.NewTicker(5, invalidateRangeFive)
  end

  initItemRequests()

  self.frame:SetScript("OnEvent", function(_, ...)
    self:OnEvent(...)
  end)
  self.frame:SetScript("OnUpdate", function(_, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate < UpdateDelay then
      return
    end
    lastUpdate = 0
    self:initialOnUpdate()
  end)

  self:scheduleInit()
end

--- BEGIN CallbackHandler stuff

do
  --- Register a callback to get called when checkers are updated
  -- @class function
  -- @name lib.RegisterCallback
  -- @usage
  -- rc.RegisterCallback(self, rc.CHECKERS_CHANGED, "myCallback")
  -- -- or
  -- rc.RegisterCallback(self, "CHECKERS_CHANGED", someCallbackFunction)
  -- @see CallbackHandler-1.0 documentation for more details
  lib.RegisterCallback = lib.RegisterCallback
    or function(...)
      local CBH = LibStub("CallbackHandler-1.0")
      lib.RegisterCallback = nil -- extra safety, we shouldn't get this far if CBH is not found, but better an error later than an infinite recursion now
      lib.callbacks = CBH:New(lib)
      -- ok, CBH hopefully injected or new shiny RegisterCallback
      return lib.RegisterCallback(...)
    end
end

--- END CallbackHandler stuff

lib:activate()
