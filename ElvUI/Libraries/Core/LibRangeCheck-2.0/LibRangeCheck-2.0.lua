--[[
Name: LibRangeCheck-2.0
Revision: $Revision$
Author(s): mitch0
Website: http://www.wowace.com/projects/librangecheck-2-0/
Description: A range checking library based on interact distances and spell ranges
Dependencies: LibStub
License: Public Domain
]]

--- LibRangeCheck-2.0 provides an easy way to check for ranges and get suitable range checking functions for specific ranges.\\
-- The checkers use spell and item range checks, or interact based checks for special units where those two cannot be used.\\
-- The lib handles the refreshing of checker lists in case talents / spells change and in some special cases when equipment changes (for example some of the mage pvp gloves change the range of the Fire Blast spell), and also handles the caching of items used for item-based range checks.\\
-- A callback is provided for those interested in checker changes.
-- @usage
-- local rc = LibStub("LibRangeCheck-2.0")
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
-- @name LibRangeCheck-2.0
local MAJOR_VERSION = "LibRangeCheck-2.0"
local MINOR_VERSION = tonumber(("$Revision: 214 $"):match("%d+")) + 100000

local lib, oldminor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _, _, _, toc = GetBuildInfo()

local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isTBC = toc >= 20500 and toc < 30000 -- TODO: Wrath
local isWrath = toc >= 30400 and toc < 40000 -- TODO: Wrath

-- GLOBALS: LibStub, CreateFrame, C_Map, FriendColor (??), HarmColor (??)
local _G = _G
local next = next
local sort = sort
local type = type
local wipe = wipe
local print = print
local pairs = pairs
local ipairs = ipairs
local tinsert = tinsert
local tremove = tremove
local tostring = tostring
local setmetatable = setmetatable
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local GetSpellInfo = GetSpellInfo
local GetSpellBookItemName = GetSpellBookItemName
local GetNumSpellTabs = GetNumSpellTabs
local GetSpellTabInfo = GetSpellTabInfo
local GetItemInfo = GetItemInfo
local UnitCanAttack = UnitCanAttack
local UnitCanAssist = UnitCanAssist
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CheckInteractDistance = CheckInteractDistance
local IsSpellInRange = IsSpellInRange
local IsItemInRange = IsItemInRange
local UnitClass = UnitClass
local UnitRace = UnitRace
local GetInventoryItemLink = GetInventoryItemLink
local GetTime = GetTime
local HandSlotId = GetInventorySlotInfo("HandsSlot")
local math_floor = math.floor
local UnitIsVisible = UnitIsVisible

-- << STATIC CONFIG

local UpdateDelay = .5
local ItemRequestTimeout = 10.0

-- interact distance based checks. ranges are based on my own measurements (thanks for all the folks who helped me with this)
local DefaultInteractList = {
--  [1] = 28, -- Compare Achievements
--  [2] = 9,  -- Trade
	[3] = 8,  -- Duel
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
local FriendSpells, HarmSpells, ResSpells, PetSpells = {}, {}, {}, {}

for _, n in ipairs({ 'DEATHKNIGHT', 'DEMONHUNTER', 'DRUID', 'HUNTER', 'SHAMAN', 'MAGE', 'PALADIN', 'PRIEST', 'WARLOCK', 'WARRIOR', 'MONK', 'ROGUE' }) do
	FriendSpells[n], HarmSpells[n], ResSpells[n], PetSpells[n] = {}, {}, {}, {}
end

-- Death Knights
tinsert(HarmSpells.DEATHKNIGHT, 49576)	-- Death Grip (30 yards)
tinsert(HarmSpells.DEATHKNIGHT, 47541)	-- Death Coil (Unholy) (40 yards)

tinsert(ResSpells.DEATHKNIGHT, 61999)	-- Raise Ally (40 yards)

-- Demon Hunters
tinsert(HarmSpells.DEMONHUNTER, 185123)	-- Throw Glaive (Havoc) (30 yards)
tinsert(HarmSpells.DEMONHUNTER, 183752)	-- Consume Magic (20 yards)
tinsert(HarmSpells.DEMONHUNTER, 204021)	-- Fiery Brand (Vengeance) (30 yards)

-- Druids
tinsert(FriendSpells.DRUID, 8936)	-- Regrowth (40 yards, level 3)
tinsert(FriendSpells.DRUID, 774)	-- Rejuvenation (Restoration) (40 yards, level 10)
tinsert(FriendSpells.DRUID, 2782)	-- Remove Corruption (Restoration) (40 yards, level 19)
tinsert(FriendSpells.DRUID, 88423)	-- Natures Cure (Restoration) (40 yards, level 19)

if not isRetail then
	tinsert(FriendSpells.DRUID, 5185) -- Healing Touch (40 yards, level 1, rank 1)
end

tinsert(HarmSpells.DRUID, 5176)		-- Wrath (40 yards)
tinsert(HarmSpells.DRUID, 339)		-- Entangling Roots (35 yards)
tinsert(HarmSpells.DRUID, 6795)		-- Growl (30 yards)
tinsert(HarmSpells.DRUID, 33786)	-- Cyclone (20 yards)
tinsert(HarmSpells.DRUID, 22568)	-- Ferocious Bite (Melee Range)
tinsert(HarmSpells.DRUID, 8921)		-- Moonfire (40 yards, level 2)

tinsert(ResSpells.DRUID, 50769)		-- Revive (40 yards, level 14)
tinsert(ResSpells.DRUID, 20484)		-- Rebirth (40 yards, level 29)

-- Hunters
tinsert(HarmSpells.HUNTER, 75)		-- Auto Shot (40 yards)

if not isRetail then
	tinsert(HarmSpells.HUNTER, 2764) -- Throw (30 yards, level 1)
end

tinsert(PetSpells.HUNTER, 136)		-- Mend Pet (45 yards)

-- Mages
tinsert(FriendSpells.MAGE, 1459)	-- Arcane Intellect (40 yards, level 8)
tinsert(FriendSpells.MAGE, 475)		-- Remove Curse (40 yards, level 28)

if not isRetail then
	tinsert(FriendSpells.MAGE, 130) -- Slow Fall (40 yards, level 12)
end

tinsert(HarmSpells.MAGE, 44614)		-- Flurry (40 yards)
tinsert(HarmSpells.MAGE, 5019)		-- Shoot (30 yards)
tinsert(HarmSpells.MAGE, 118)		-- Polymorph (30 yards)
tinsert(HarmSpells.MAGE, 116)		-- Frostbolt (40 yards)
tinsert(HarmSpells.MAGE, 133)		-- Fireball (40 yards)
tinsert(HarmSpells.MAGE, 44425)		-- Arcane Barrage (40 yards)

-- Monks
tinsert(FriendSpells.MONK, 115450)	-- Detox (40 yards)
tinsert(FriendSpells.MONK, 115546)	-- Provoke (30 yards)
tinsert(FriendSpells.MONK, 116670)	-- Vivify (40 yards)

tinsert(HarmSpells.MONK, 115546)	-- Provoke (30 yards)
tinsert(HarmSpells.MONK, 115078)	-- Paralysis (20 yards)
tinsert(HarmSpells.MONK, 100780)	-- Tiger Palm (Melee Range)
tinsert(HarmSpells.MONK, 117952)	-- Crackling Jade Lightning (40 yards)

tinsert(ResSpells.MONK, 115178)		-- Resuscitate (40 yards, level 13)

-- Paladins
tinsert(FriendSpells.PALADIN, 19750)	-- Flash of Light (40 yards, level 4)
tinsert(FriendSpells.PALADIN, 85673)	-- Word of Glory (40 yards, level 7)
tinsert(FriendSpells.PALADIN, 4987)		-- Cleanse (Holy) (40 yards, level 12)
tinsert(FriendSpells.PALADIN, 213644)	-- Cleanse Toxins (Protection, Retribution) (40 yards, level 12)

if not isRetail then
	tinsert(FriendSpells.PALADIN, 635)	-- Holy Light (40 yards, level 1, rank 1)
end

tinsert(HarmSpells.PALADIN, 853)	-- Hammer of Justice (10 yards)
tinsert(HarmSpells.PALADIN, 35395)	-- Crusader Strike (Melee Range)
tinsert(HarmSpells.PALADIN, 62124)	-- Hand of Reckoning (30 yards)
tinsert(HarmSpells.PALADIN, 183218)	-- Hand of Hindrance (30 yards)
tinsert(HarmSpells.PALADIN, 20271)	-- Judgement (30 yards)
tinsert(HarmSpells.PALADIN, 20473)	-- Holy Shock (40 yards)

tinsert(ResSpells.PALADIN, 7328)	-- Redemption (40 yards)

-- Priests
if isRetail then
	tinsert(FriendSpells.PRIEST, 21562)	-- Power Word: Fortitude (40 yards, level 6) [use first to fix kyrian boon/fae soulshape]
	tinsert(FriendSpells.PRIEST, 17)	-- Power Word: Shield (40 yards, level 4)
else -- PWS is group only in classic, use lesser heal as main spell check
	tinsert(FriendSpells.PRIEST, 2050)	-- Lesser Heal (40 yards, level 1, rank 1)
end

tinsert(FriendSpells.PRIEST, 527)	-- Purify / Dispel Magic (40 yards retail, 30 yards tbc, level 18, rank 1)
tinsert(FriendSpells.PRIEST, 2061)	-- Flash Heal (40 yards, level 3 retail, level 20 tbc)

tinsert(HarmSpells.PRIEST, 589)		-- Shadow Word: Pain (40 yards)
tinsert(HarmSpells.PRIEST, 585)		-- Smite (40 yards)
tinsert(HarmSpells.PRIEST, 5019)	-- Shoot (30 yards)

if not isRetail then
	tinsert(HarmSpells.PRIEST, 8092) -- Mindblast (30 yards, level 10)
end

tinsert(ResSpells.PRIEST, 2006)		-- Resurrection (40 yards, level 10)

-- Rogues
if isRetail then
	tinsert(FriendSpells.ROGUE, 36554)	-- Shadowstep (Assassination, Subtlety) (25 yards, level 18) -- works on friendly in retail
	tinsert(FriendSpells.ROGUE, 921)	-- Pick Pocket (10 yards, level 24) -- this works for range, keep it in friendly aswell for retail but on classic this is melee range and will return min 0 range 0
end

tinsert(HarmSpells.ROGUE, 2764)		-- Throw (30 yards)
tinsert(HarmSpells.ROGUE, 36554)	-- Shadowstep (Assassination, Subtlety) (25 yards, level 18)
tinsert(HarmSpells.ROGUE, 185763)	-- Pistol Shot (Outlaw) (20 yards)
tinsert(HarmSpells.ROGUE, 2094)		-- Blind (15 yards)
tinsert(HarmSpells.ROGUE, 921)		-- Pick Pocket (10 yards, level 24)

-- Shamans
tinsert(FriendSpells.SHAMAN, 546)		-- Water Walking (30 yards)
tinsert(FriendSpells.SHAMAN, 8004)		-- Healing Surge (Resto, Elemental) (40 yards)
tinsert(FriendSpells.SHAMAN, 188070)	-- Healing Surge (Enhancement) (40 yards)

if not isRetail then
	tinsert(FriendSpells.SHAMAN, 331)	-- Healing Wave (40 yards, level 1, rank 1)
	tinsert(FriendSpells.SHAMAN, 526)	-- Cure Poison (40 yards, level 16)
	tinsert(FriendSpells.SHAMAN, 2870)	-- Cure Disease (40 yards, level 22)
end

tinsert(HarmSpells.SHAMAN, 370)		-- Purge (30 yards)
tinsert(HarmSpells.SHAMAN, 188196)	-- Lightning Bolt (40 yards)
tinsert(HarmSpells.SHAMAN, 73899)	-- Primal Strike (Melee Range)

if not isRetail then
	tinsert(HarmSpells.SHAMAN, 403)		-- Lightning Bolt (30 yards, level 1, rank 1)
	tinsert(HarmSpells.SHAMAN, 8042)	-- Earth Shock (20 yards, level 4, rank 1)
end

tinsert(ResSpells.SHAMAN, 2008)		-- Ancestral Spirit (40 yards, level 13)

-- Warriors
tinsert(HarmSpells.WARRIOR, 355)	-- Taunt (30 yards)
tinsert(HarmSpells.WARRIOR, 5246)	-- Intimidating Shout (Arms, Fury) (8 yards)
tinsert(HarmSpells.WARRIOR, 100)	-- Charge (Arms, Fury) (8-25 yards)

if not isRetail then
	tinsert(HarmSpells.WARRIOR, 2764) -- Throw (30 yards, level 1, 5-30 range)
end

-- Warlocks
tinsert(FriendSpells.WARLOCK, 5697)		-- Unending Breath (30 yards)
tinsert(FriendSpells.WARLOCK, 20707)	-- Soulstone (40 yards) ~ this can be precasted so leave it in friendly aswell as res

if isRetail then
	tinsert(FriendSpells.WARLOCK, 132)	-- Detect Invisibility (30 yards, level 26)
end

tinsert(HarmSpells.WARLOCK, 5019)		-- Shoot (30 yards)
tinsert(HarmSpells.WARLOCK, 234153)		-- Drain Life (40 yards, level 9)
tinsert(HarmSpells.WARLOCK, 198590)		-- Drain Soul (40 yards, level 15)
tinsert(HarmSpells.WARLOCK, 686)		-- Shadow Bolt (Demonology, Affliction) (40 yards)
tinsert(HarmSpells.WARLOCK, 232670)		-- Shadow Bolt (40 yards)
tinsert(HarmSpells.WARLOCK, 5782)		-- Fear (30 yards)

if not isRetail then
	tinsert(HarmSpells.WARLOCK, 172)	-- Corruption (30 yards, level 4, rank 1)
	tinsert(HarmSpells.WARLOCK, 348)	-- Immolate (30 yards, level 1, rank 1)
	tinsert(HarmSpells.WARLOCK, 17877)	-- Shadowburn (Destruction) (20 yards)
end

tinsert(ResSpells.WARLOCK, 20707)	-- Soulstone (40 yards)

tinsert(PetSpells.WARLOCK, 755)		-- Health Funnel (45 yards)

-- Items [Special thanks to Maldivia for the nice list]

local FriendItems  = {
	[1] = {
		90175, -- Gin-Ji Knife Set -- doesn't seem to work for pets (always returns nil)
	},
	[2] = {
		37727, -- Ruby Acorn
	},
	[3] = {
		42732, -- Everfrost Razor
	},
	[4] = {
		129055, -- Shoe Shine Kit
	},
	[5] = {
		8149, -- Voodoo Charm
		136605, -- Solendra's Compassion
		63427, -- Worgsaw
	},
	[7] = {
		61323, -- Ruby Seeds
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
		38643, -- Thick Frostweave Bandage
		38640, -- Dense Frostweave Bandage
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
	[38] = {
		140786, -- Ley Spider Eggs
	},
	[40] = {
		34471, -- Vial of the Sunwell
	},
	[45] = {
		32698, -- Wrangling Rope
	},
	[50] = {
		116139, -- Haunting Memento
	},
	[55] = {
		74637, -- Kiryn's Poison Vial
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
	[90] = {
		133925, -- Fel Lash
	},
	[100] = {
		41058, -- Hyldnir Harpoon
	},
	[150] = {
		46954, -- Flaming Spears
	},
	[200] = {
		75208, -- Rancher's Lariat
	},
}

local HarmItems = {
	[1] = {
	},
	[2] = {
		37727, -- Ruby Acorn
	},
	[3] = {
		42732, -- Everfrost Razor
	},
	[4] = {
		129055, -- Shoe Shine Kit
	},
	[5] = {
		8149, -- Voodoo Charm
		136605, -- Solendra's Compassion
		63427, -- Worgsaw
	},
	[7] = {
		61323, -- Ruby Seeds
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
	[38] = {
		140786, -- Ley Spider Eggs
	},
	[40] = {
		28767, -- The Decapitator
	},
	[45] = {
		--32698, -- Wrangling Rope
		23836, -- Goblin Rocket Launcher
	},
	[50] = {
		116139, -- Haunting Memento
	},
	[55] = {
		74637, -- Kiryn's Poison Vial
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
	[90] = {
		133925, -- Fel Lash
	},
	[100] = {
		33119, -- Malister's Frost Wand
	},
	[150] = {
		46954, -- Flaming Spears
	},
	[200] = {
		75208, -- Rancher's Lariat
	},
}

-- This could've been done by checking player race as well and creating tables for those, but it's easier like this
for _, v in pairs(FriendSpells) do
	tinsert(v, 28880) -- Gift of the Naaru (40 yards)
end

-- >> END OF STATIC CONFIG

-- temporary stuff

local pendingItemRequest
local itemRequestTimeoutAt
local foundNewItems
local cacheAllItems
local friendItemRequests
local harmItemRequests
local lastUpdate = 0

-- minRangeCheck is a function to check if spells with minimum range are really out of range, or fail due to range < minRange. See :init() for its setup
local minRangeCheck = function(unit) return CheckInteractDistance(unit, 2) end

local checkers_Spell = setmetatable({}, {
	__index = function(t, spellIdx)
		local func = function(unit)
			if IsSpellInRange(spellIdx, BOOKTYPE_SPELL, unit) == 1 then
				 return true
			end
		end
		t[spellIdx] = func
		return func
	end
})
local checkers_SpellWithMin = setmetatable({}, {
	__index = function(t, spellIdx)
		local func = function(unit)
			if IsSpellInRange(spellIdx, BOOKTYPE_SPELL, unit) == 1 then
				return true
			elseif minRangeCheck(unit) then
				return true, true
			end
		end
		t[spellIdx] = func
		return func
	end
})
local checkers_Item = setmetatable({}, {
	__index = function(t, item)
		local func = function(unit)
			return IsItemInRange(item, unit)
		end
		t[item] = func
		return func
	end
})
local checkers_Interact = setmetatable({}, {
	__index = function(t, index)
		local func = function(unit)
			if CheckInteractDistance(unit, index) then
				return true
			end
		end
		t[index] = func
		return func
	end
})

-- helper functions
local function copyTable(src, dst)
	if type(dst) ~= "table" then dst = {} end
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
local function findSpellIdx(spellName)
	if not spellName or spellName == "" then
		return nil
	end
	for i = 1, getNumSpells() do
		local spell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		if spell == spellName then
			return i
		end
	end
	return nil
end

-- minRange should be nil if there's no minRange, not 0
local function addChecker(t, range, minRange, checker, info)
	local rc = { ["range"] = range, ["minRange"] = minRange, ["checker"] = checker, ["info"] = info }
	for i = 1, #t do
		local v = t[i]
		if rc.range == v.range then return end
		if rc.range > v.range then
			tinsert(t, i, rc)
			return
		end
	end
	tinsert(t, rc)
end

local function createCheckerList(spellList, itemList, interactList)
	local res = {}
	if itemList then
		for range, items in pairs(itemList) do
			for i = 1, #items do
				local item = items[i]
				if GetItemInfo(item) then
					addChecker(res, range, nil, checkers_Item[item], "item:" .. item)
					break
				end
			end
		end
	end

	if spellList then
		for i = 1, #spellList do
			local sid = spellList[i]
			local name, _, _, _, minRange, range = GetSpellInfo(sid)
			local spellIdx = findSpellIdx(name)
			if spellIdx and range then
				minRange = math_floor(minRange + 0.5)
				range = math_floor(range + 0.5)

				-- print("### spell: " .. tostring(name) .. ", " .. tostring(minRange) .. " - " ..  tostring(range))

				if minRange == 0 then -- getRange() expects minRange to be nil in this case
					minRange = nil
				end

				if range == 0 then
					range = MeleeRange
				end

				if minRange then
					addChecker(res, range, minRange, checkers_SpellWithMin[spellIdx], "spell:" .. sid .. ":" .. tostring(name))
				else
					addChecker(res, range, minRange, checkers_Spell[spellIdx], "spell:" .. sid .. ":" .. tostring(name))
				end
			end
		end
	end

	if interactList and not next(res) then
		for index, range in pairs(interactList) do
			addChecker(res, range, nil,  checkers_Interact[index], "interact:" .. index)
		end
	end

	return res
end

-- returns minRange, maxRange  or nil
local function getRange(unit, checkerList)
	local lo, hi = 1, #checkerList
	while lo <= hi do
		local mid = math_floor((lo + hi) / 2)
		local rc = checkerList[mid]
		if rc.checker(unit) then
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	if lo > #checkerList then
		return 0, checkerList[#checkerList].range
	elseif lo <= 1 then
		return checkerList[1].range, nil
	else
		return checkerList[lo].range, checkerList[lo - 1].range
	end
end

local function updateCheckers(origList, newList)
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

local function null()
end

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
lib.friendRC = createCheckerList(nil, nil, DefaultInteractList)
lib.harmRC = createCheckerList(nil, nil, DefaultInteractList)
lib.resRC = createCheckerList(nil, nil, DefaultInteractList)
lib.petRC = createCheckerList(nil, nil, DefaultInteractList)
lib.friendNoItemsRC = createCheckerList(nil, nil, DefaultInteractList)
lib.harmNoItemsRC = createCheckerList(nil, nil, DefaultInteractList)

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
	if type(spell) == 'number' then
		spell = GetSpellInfo(spell)
	end
	return findSpellIdx(spell)
end

-- returns the range estimate as a string
-- deprecated, use :getRange(unit) instead and build your own strings
-- @param checkVisible if set to true, then a UnitIsVisible check is made, and **nil** is returned if the unit is not visible
function lib:getRangeAsString(unit, checkVisible, showOutOfRange)
	local minRange, maxRange = self:getRange(unit, checkVisible)
	if not minRange then return nil end
	if not maxRange then
		return showOutOfRange and minRange .. " +" or nil
	end
	return minRange .. " - " .. maxRange
end

-- initialize RangeCheck if not yet initialized or if "forced"
function lib:init(forced)
	if self.initialized and (not forced) then
		return
	end
	self.initialized = true
	local _, playerClass = UnitClass("player")
	local _, playerRace = UnitRace("player")

	minRangeCheck = nil

	-- first try to find a nice item we can use for minRangeCheck
	local harmItems = HarmItems[15]
	if harmItems then
		for i = 1, #harmItems do
			local minCheck = minItemChecker(harmItems[i])
			if minCheck then
				minRangeCheck = minCheck
				break
			end
		end
	end

	if not minRangeCheck then -- fall back to interact distance checks
		if playerClass == "HUNTER" or playerRace == "Tauren" then
			-- for Hunters: use interact4 as it's safer
			-- for Taurens: interact4 is actually closer than 25yd and interact3 is closer than 8yd, so we can't use that
			minRangeCheck = checkers_Interact[4]
		else
			minRangeCheck = checkers_Interact[3]
		end
	end

	local interactList = InteractLists[playerRace] or DefaultInteractList
	self.handSlotItem = GetInventoryItemLink("player", HandSlotId)
	local changed = false
	if updateCheckers(self.friendRC, createCheckerList(FriendSpells[playerClass], FriendItems, interactList)) then
		changed = true
	end
	if updateCheckers(self.harmRC, createCheckerList(HarmSpells[playerClass], HarmItems, interactList)) then
		changed = true
	end
	if updateCheckers(self.friendNoItemsRC, createCheckerList(FriendSpells[playerClass], nil, interactList)) then
		changed = true
	end
	if updateCheckers(self.harmNoItemsRC, createCheckerList(HarmSpells[playerClass], nil, interactList)) then
		changed = true
	end
	if updateCheckers(self.miscRC, createCheckerList(nil, nil, interactList)) then
		changed = true
	end
	if updateCheckers(self.resRC, createCheckerList(ResSpells[playerClass], nil, interactList)) then
		changed = true
	end
	if updateCheckers(self.petRC, createCheckerList(PetSpells[playerClass], nil, interactList)) then
		changed = true
	end
	if changed and self.callbacks then
		self.callbacks:Fire(self.CHECKERS_CHANGED)
	end
end

--- Return an iterator for checkers usable on friendly units as (**range**, **checker**) pairs.
function lib:GetFriendCheckers()
	return rcIterator(self.friendRC)
end

--- Return an iterator for checkers usable on enemy units as (**range**, **checker**) pairs.
function lib:GetHarmCheckers()
	return rcIterator(self.harmRC)
end

--- Return an iterator for checkers usable on miscellaneous units as (**range**, **checker**) pairs.  These units are neither enemy nor friendly, such as people in sanctuaries or corpses.
function lib:GetMiscCheckers()
	return rcIterator(self.miscRC)
end

--- Return a checker suitable for out-of-range checking on friendly units, that is, a checker whose range is equal or larger than the requested range.
-- @param range the range to check for.
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetFriendMinChecker(range)
	return getMinChecker(self.friendRC, range)
end

--- Return a checker suitable for out-of-range checking on enemy units, that is, a checker whose range is equal or larger than the requested range.
-- @param range the range to check for.
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetHarmMinChecker(range)
	return getMinChecker(self.harmRC, range)
end

--- Return a checker suitable for out-of-range checking on miscellaneous units, that is, a checker whose range is equal or larger than the requested range.
-- @param range the range to check for.
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetMiscMinChecker(range)
	return getMinChecker(self.miscRC, range)
end

--- Return a checker suitable for in-range checking on friendly units, that is, a checker whose range is equal or smaller than the requested range.
-- @param range the range to check for.
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetFriendMaxChecker(range)
	return getMaxChecker(self.friendRC, range)
end

--- Return a checker suitable for in-range checking on enemy units, that is, a checker whose range is equal or smaller than the requested range.
-- @param range the range to check for.
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetHarmMaxChecker(range)
	return getMaxChecker(self.harmRC, range)
end

--- Return a checker suitable for in-range checking on miscellaneous units, that is, a checker whose range is equal or smaller than the requested range.
-- @param range the range to check for.
-- @return **checker**, **range** pair or **nil** if no suitable checker is available. **range** is the actual range the returned **checker** checks for.
function lib:GetMiscMaxChecker(range)
	return getMaxChecker(self.miscRC, range)
end

--- Return a checker for the given range for friendly units.
-- @param range the range to check for.
-- @return **checker** function or **nil** if no suitable checker is available.
function lib:GetFriendChecker(range)
	return getChecker(self.friendRC, range)
end

--- Return a checker for the given range for enemy units.
-- @param range the range to check for.
-- @return **checker** function or **nil** if no suitable checker is available.
function lib:GetHarmChecker(range)
	return getChecker(self.harmRC, range)
end

--- Return a checker for the given range for miscellaneous units.
-- @param range the range to check for.
-- @return **checker** function or **nil** if no suitable checker is available.
function lib:GetMiscChecker(range)
	return getChecker(self.miscRC, range)
end

--- Return a checker suitable for out-of-range checking that checks the unit type and calls the appropriate checker (friend/harm/misc).
-- @param range the range to check for.
-- @return **checker** function.
function lib:GetSmartMinChecker(range)
	return createSmartChecker(
		getMinChecker(self.friendRC, range),
		getMinChecker(self.harmRC, range),
		getMinChecker(self.miscRC, range))
end

--- Return a checker suitable for in-range checking that checks the unit type and calls the appropriate checker (friend/harm/misc).
-- @param range the range to check for.
-- @return **checker** function.
function lib:GetSmartMaxChecker(range)
	return createSmartChecker(
		getMaxChecker(self.friendRC, range),
		getMaxChecker(self.harmRC, range),
		getMaxChecker(self.miscRC, range))
end

--- Return a checker for the given range that checks the unit type and calls the appropriate checker (friend/harm/misc).
-- @param range the range to check for.
-- @param fallback optional fallback function that gets called as fallback(unit) if a checker is not available for the given type (friend/harm/misc) at the requested range. The default fallback function return nil.
-- @return **checker** function.
function lib:GetSmartChecker(range, fallback)
	return createSmartChecker(
		getChecker(self.friendRC, range) or fallback,
		getChecker(self.harmRC, range) or fallback,
		getChecker(self.miscRC, range) or fallback)
end

--- Get a range estimate as **minRange**, **maxRange**.
-- @param unit the target unit to check range to.
-- @param checkVisible if set to true, then a UnitIsVisible check is made, and **nil** is returned if the unit is not visible
-- @return **minRange**, **maxRange** pair if a range estimate could be determined, **nil** otherwise. **maxRange** is **nil** if **unit** is further away than the highest possible range we can check.
-- Includes checks for unit validity and friendly/enemy status.
-- @usage
-- local rc = LibStub("LibRangeCheck-2.0")
-- local minRange, maxRange = rc:GetRange('target')
-- local minRangeIfVisible, maxRangeIfVisible = rc:GetRange('target', true)
function lib:GetRange(unit, checkVisible, noItems)
	if not UnitExists(unit) then
		return nil
	end

	if checkVisible and not UnitIsVisible(unit) then
		return nil
	end

	local canAssist = UnitCanAssist("player", unit)
	if UnitIsDeadOrGhost(unit) then
		if canAssist then
			return getRange(unit, self.resRC)
		else
			return getRange(unit, self.miscRC)
		end
	end

	if UnitCanAttack("player", unit) then
		return getRange(unit, noItems and self.harmNoItemsRC or self.harmRC)
	elseif UnitIsUnit("pet", unit) then
		local minRange, maxRange = getRange(unit, noItems and self.friendNoItemsRC or self.friendRC)
		if minRange or maxRange then
			return minRange, maxRange
		else
			return getRange(unit, self.petRC)
		end
	elseif canAssist then
		return getRange(unit, noItems and self.friendNoItemsRC or self.friendRC)
	else
		return getRange(unit, self.miscRC)
	end
end

-- keep this for compatibility
lib.getRange = lib.GetRange

-- >> Public API

function lib:OnEvent(event, ...)
	if type(self[event]) == 'function' then
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
	if item == pendingItemRequest then
		pendingItemRequest = nil
		if not success then
			self.failedItemRequests[item] = true
		end
		lastUpdate = UpdateDelay
	end
end

function lib:processItemRequests(itemRequests)
	while true do
		local range, items = next(itemRequests)
		if not range then return end
		while true do
			local i, item = next(items)
			if not i then
				itemRequests[range] = nil
				break
			elseif self.failedItemRequests[item] then
				-- print("### processItemRequests: failed: " .. tostring(item))
				tremove(items, i)
			elseif item == pendingItemRequest and GetTime() < itemRequestTimeoutAt then
				return true; -- still waiting for server response
			elseif GetItemInfo(item) then
				-- print("### processItemRequests: found: " .. tostring(item))
				if itemRequestTimeoutAt then
					-- print("### processItemRequests: new: " .. tostring(item))
					foundNewItems = true
					itemRequestTimeoutAt = nil
					pendingItemRequest = nil
				end
				if not cacheAllItems then
					itemRequests[range] = nil
					break
				end
				tremove(items, i)
			elseif not itemRequestTimeoutAt then
				-- print("### processItemRequests: waiting: " .. tostring(item))
				itemRequestTimeoutAt = GetTime() + ItemRequestTimeout
				pendingItemRequest = item
				if not self.frame:IsEventRegistered("GET_ITEM_INFO_RECEIVED") then
					self.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
				end
				return true
			elseif GetTime() >= itemRequestTimeoutAt then
				-- print("### processItemRequests: timeout: " .. tostring(item))
				if cacheAllItems then
					print(MAJOR_VERSION .. ": timeout for item: " .. tostring(item))
				end
				self.failedItemRequests[item] = true
				itemRequestTimeoutAt = nil
				pendingItemRequest = nil
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
		if self:processItemRequests(friendItemRequests) then return end
		friendItemRequests = nil
	end
	if harmItemRequests then
		if self:processItemRequests(harmItemRequests) then return end
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

function lib:activate()
	if not self.frame then
		local frame = CreateFrame("Frame")
		self.frame = frame

		frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
		frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
		frame:RegisterEvent("SPELLS_CHANGED")

		if isRetail or isWrath then
			frame:RegisterEvent("PLAYER_TALENT_UPDATE")
		end

		local _, playerClass = UnitClass("player")
		if playerClass == "MAGE" or playerClass == "SHAMAN" then
			-- Mage and Shaman gladiator gloves modify spell ranges
			frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
		end
	end

	initItemRequests()

	self.frame:SetScript("OnEvent", function(_, ...) self:OnEvent(...) end)
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
	lib.RegisterCallback = lib.RegisterCallback or function(...)
		local CBH = LibStub("CallbackHandler-1.0")
		lib.RegisterCallback = nil -- extra safety, we shouldn't get this far if CBH is not found, but better an error later than an infinite recursion now
		lib.callbacks = CBH:New(lib)
		-- ok, CBH hopefully injected or new shiny RegisterCallback
		return lib.RegisterCallback(...)
	end
end

--- END CallbackHandler stuff

lib:activate()
