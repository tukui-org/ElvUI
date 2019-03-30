--[[
LibPlayerSpells-1.0 - Additional information about player spells.
(c) 2013-2018 Adirelle (adirelle@gmail.com)

This file is part of LibPlayerSpells-1.0.

LibPlayerSpells-1.0 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibPlayerSpells-1.0 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibPlayerSpells-1.0. If not, see <http://www.gnu.org/licenses/>.
--]]

local MAJOR, MINOR, lib = "LibPlayerSpells-1.0", 11
if LibStub then
	local oldMinor
	lib, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
	if not lib then return end

	if oldMinor and oldMinor < 8 then
		-- The internal data changed at minor 8, wipe anything coming from the previous version
		wipe(lib)
	end
else
	lib = {}
end

local Debug = function() end
if AdiDebug then
	Debug = AdiDebug:Embed({}, MAJOR)
end

local _G = _G
local ceil = _G.ceil
local error = _G.error
local format = _G.format
local GetSpellInfo = _G.GetSpellInfo
local gsub = _G.string.gsub
local ipairs = _G.ipairs
local max = _G.max
local next = _G.next
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local wipe = _G.wipe

local bor = _G.bit.bor
local band = _G.bit.band
local bxor = _G.bit.bxor
local bnot = _G.bit.bnot

-- Basic constants use for the bitfields
lib.constants = {
	-- Special types -- these alters how the 13 lower bits are to be interpreted
	DISPEL       = 0x80000000,
	CROWD_CTRL   = 0x40000000,

	-- Sources
	DEATHKNIGHT  = 0x00000001,
	DEMONHUNTER  = 0x00000002,
	DRUID        = 0x00000004,
	HUNTER       = 0x00000008,
	MAGE         = 0x00000010,
	MONK         = 0x00000020,
	PALADIN      = 0x00000040,
	PRIEST       = 0x00000080,
	ROGUE        = 0x00000100,
	SHAMAN       = 0x00000200,
	WARLOCK      = 0x00000400,
	WARRIOR      = 0x00000800,
	RACIAL       = 0x00001000, -- Racial trait

	-- Crowd control types, *requires* CROWD_CTRL, else this messes up sources
	DISORIENT    = 0x00000001,
	INCAPACITATE = 0x00000002,
	ROOT         = 0x00000004,
	STUN         = 0x00000008,
	TAUNT        = 0x00000010,

	-- Dispel types, *requires* DISPEL, else this messes up sources
	CURSE        = 0x00000001,
	DISEASE      = 0x00000002,
	MAGIC        = 0x00000004,
	POISON       = 0x00000008,
	ENRAGE       = 0x00000010,

	-- Targeting
	HELPFUL      = 0x00004000, -- Usable on allies
	HARMFUL      = 0x00008000, -- Usable on enemies
	PERSONAL     = 0x00010000, -- Only usable on self
	PET          = 0x00020000, -- Only usable on pet

	-- Various flags
	AURA         = 0x00040000, -- Applies an aura
	INVERT_AURA  = 0x00080000, -- Watch this as a debuff on allies or a buff on enemies
	UNIQUE_AURA  = 0x00100000, -- Only one aura on a given unit
	COOLDOWN     = 0x00200000, -- Has a cooldown
	SURVIVAL     = 0x00400000, -- Survival spell
	BURST        = 0x00800000, -- Damage/healing burst spell
	POWER_REGEN  = 0x01000000, -- Recharge any power
	IMPORTANT    = 0x02000000, -- Important spell the player should react to
	INTERRUPT    = 0x04000000,
	KNOCKBACK    = 0x08000000,
	SNARE        = 0x10000000,
	RAIDBUFF     = 0x20000000,
}
local constants = lib.constants

local CROWD_CTRL_TYPES = {
	constants.DISORIENT, constants.INCAPACITATE, constants.ROOT,
	constants.STUN, constants.TAUNT,
}

local DISPEL_TYPES = {
	constants.CURSE, constants.DISEASE,
	constants.ENRAGE , constants.MAGIC, constants.POISON,
}

local CROWD_CTRL_CATEGORY_NAMES = {
	[constants.DISORIENT]    = _G.LOSS_OF_CONTROL_DISPLAY_DISORIENT,
	[constants.INCAPACITATE] = _G.LOSS_OF_CONTROL_DISPLAY_INCAPACITATE,
	[constants.ROOT]         = _G.LOSS_OF_CONTROL_DISPLAY_ROOT,
	[constants.STUN]         = _G.LOSS_OF_CONTROL_DISPLAY_STUN,
	[constants.TAUNT]        = _G.LOSS_OF_CONTROL_DISPLAY_TAUNT,
}

local DISPEL_TYPE_NAMES = {
	[constants.CURSE]   = _G.ENCOUNTER_JOURNAL_SECTION_FLAG8,
	[constants.DISEASE] = _G.ENCOUNTER_JOURNAL_SECTION_FLAG10,
	[constants.ENRAGE]  = _G.ENCOUNTER_JOURNAL_SECTION_FLAG11,
	[constants.MAGIC]   = _G.ENCOUNTER_JOURNAL_SECTION_FLAG7,
	[constants.POISON]  = _G.ENCOUNTER_JOURNAL_SECTION_FLAG9,
}

-- Convenient bitmasks
lib.masks = {
	CLASS = bor(
		constants.DEATHKNIGHT,
		constants.DEMONHUNTER,
		constants.DRUID,
		constants.HUNTER,
		constants.MAGE,
		constants.MONK,
		constants.PALADIN,
		constants.PRIEST,
		constants.ROGUE,
		constants.SHAMAN,
		constants.WARLOCK,
		constants.WARRIOR
	),
	SOURCE = bor(
		constants.DEATHKNIGHT,
		constants.DEMONHUNTER,
		constants.DRUID,
		constants.HUNTER,
		constants.MAGE,
		constants.MONK,
		constants.PALADIN,
		constants.PRIEST,
		constants.ROGUE,
		constants.SHAMAN,
		constants.WARLOCK,
		constants.WARRIOR,
		constants.RACIAL
	),
	TARGETING = bor(
		constants.HELPFUL,
		constants.HARMFUL,
		constants.PERSONAL,
		constants.PET
	),
	TYPE = bor(
		constants.CROWD_CTRL,
		constants.DISPEL
	),
	CROWD_CTRL_TYPE = bor(
		constants.DISORIENT,
		constants.INCAPACITATE,
		constants.ROOT,
		constants.STUN,
		constants.TAUNT
	),
	DISPEL_TYPE = bor(
		constants.CURSE,
		constants.DISEASE,
		constants.ENRAGE,
		constants.MAGIC,
		constants.POISON
	),
}
local masks = lib.masks

-- Spells and their flags
lib.__spells = lib.__spells or {}
local spells = lib.__spells

-- Spells by categories
lib.__categories = lib.__categories or {
	DEATHKNIGHT = {},
	DEMONHUNTER = {},
	DRUID       = {},
	HUNTER      = {},
	MAGE        = {},
	MONK        = {},
	PALADIN     = {},
	PRIEST      = {},
	ROGUE       = {},
	SHAMAN      = {},
	WARLOCK     = {},
	WARRIOR     = {},
	RACIAL      = {},
}
local categories = lib.__categories

-- Special spells
lib.__specials = lib.__specials or {
	CROWD_CTRL = {},
	DISPEL     = {},
}
local specials = lib.__specials

-- Versions of the different categories
lib.__versions = lib.__versions or {}
local versions = lib.__versions

-- Buff to provider map.
-- The provider is the spell from the spellbook than can provides the given buff.
-- Said otherwise, a buff cannot appear on a player if the provider spell is not in his spellbook.
lib.__providers = lib.__providers or {}
local providers = lib.__providers

-- Buff to modified map.
-- Indicate which spell is modified by a buff.
lib.__modifiers = lib.__modifiers or {}
local modifiers = lib.__modifiers

-- Spell to category map.
-- Indicate which category defined a spell.
lib.__sources = lib.__sources or {}
local sources = lib.__sources

local function ParseFilter(filter)
	local flags = 0
	for word in filter:gmatch("[%a_]+") do
		local value = constants[word] or masks[word]
		if not value then
			error(format("%s: invalid filter: %q (because of %q)",  MAJOR, tostring(filter), tostring(word)), 5)
		end
		flags = bor(flags, value)
	end
	return flags
end

-- A weak table to memoize parsed filters
lib.__filters = setmetatable(
	wipe(lib.__filters or {}),
	{
		__mode = 'kv',
		__index = function(self, key)
			if not key then return 0 end
			local value = type(key) == "string" and ParseFilter(key) or tonumber(key)
			self[key] = value
			return value
		end,
	}
)
local filters = lib.__filters
filters[""] = 0

--- Return version information about a category
-- @param category (string) The category.
-- @return (number) A version number suitable for comparison.
-- @return (number) The interface (i.e. patch) version.
-- @return (number) Minor version for the given interface version.
function lib:GetVersionInfo(category)
	local cats = { strsplit(" ", category) }
	local v
	for i = 1, #cats do
		if not categories[cats[i]] then
			error(format("%s: invalid category: %q", MAJOR, tostring(category)), 2)
		end
		v = versions[cats[i]] or 0
	end
	return v, floor(v/100), v % 100
end

local TRUE = function() return true end

--- Create a flag tester callback.
-- This callback takes a flag as an argument and returns true when the conditions are met.
-- @param anyOf (string|number) The tested value should contain at least one these flags.
-- @param include (string|number) The tested value must contain all these flags.
-- @param exclude (string|number) The testes value must not contain any of these flags.
-- @return (function) The tester callback.
function lib:GetFlagTester(anyOf, include, exclude)
	local anyOfMask = filters[anyOf]
	if include or exclude then
		local includeMask, excludeMask = filters[include], filters[exclude]
		local mask = bor(includeMask, excludeMask)
		local expected = bxor(mask, excludeMask)
		if anyOf then
			return function(flags)
				return flags and band(flags, anyOfMask) ~= 0 and band(flags, mask) == expected
			end
		else
			return function(flags)
				return flags and band(flags, mask) == expected
			end
		end
	elseif anyOf then
		return function(flags)
			return flags and band(flags, anyOfMask) ~= 0
		end
	else
		return TRUE
	end
end

--- Create a spell tester callback.
-- This callback takes a spell identifier as an argument and returns true when the conditions are met.
-- @param anyOf (string|number) The tested value should contain at least one these flags.
-- @param include (string|number) The tested value must contain all these flags.
-- @param exclude (string|number) The testes value must not contain any of these flags.
-- @return (function) The tester callback.
function lib:GetSpellTester(anyOf, include, exclude)
	local tester = lib:GetFlagTester(anyOf, include, exclude)
	return function(spellId) return tester(spells[spellId or false] or 0) end
end

-- Filtering iterator
local function FilterIterator(tester, spellId)
	local flags
	repeat
		spellId, flags = next(spells, spellId)
		if spellId and tester(flags) then
			return spellId, flags, providers[spellId], modifiers[spellId], specials.CROWD_CTRL[spellId], sources[spellId], specials.DISPEL[spellId]
		end
	until not spellId
end

-- Iterate through spells.
-- @return An iterator suitable for for .. in .. do loops.
function lib:IterateSpells(anyOf, include, exclude)
	return FilterIterator, lib:GetFlagTester(anyOf, include, exclude)
end

--- Iterate through spell categories.
-- The iterator returns the category name and the spells in that category.
-- @return An iterator suitable for .. in .. do loops.
function lib:IterateCategories()
	return pairs(categories)
end

--- Return the list of crowd control types.
-- @return (table)
function lib:GetCrowdControlTypes()
	return CROWD_CTRL_TYPES
end

--- Return the list of dispel types.
-- @return (table)
function lib:GetDispelTypes()
	return DISPEL_TYPES
end

--- Return the localized name of the category a crowd control aura belongs to.
-- Can be called with either a bitmask or a spellId.
-- @param bitmask (number) a bitmask for the aura.
-- @param spellId (number) spell identifier of the aura.
-- @return (string|nil) The localized category name or nil.
function lib:GetCrowdControlCategoryName(bitmask, spellId)
	bitmask = bitmask or spellId and specials.CROWD_CTRL[spellId]

	if not bitmask then return end

	for mask, name in pairs(CROWD_CTRL_CATEGORY_NAMES) do
		if band(bitmask, mask) > 0 then
			return name
		end
	end
end

--- Return a table containing the localized names of the dispel types.
-- Can be called with either a bitmask or a spellId.
-- @param bitmask (number) a bitmask for the spell.
-- @param spellId (number) spell identifier of the spell.
-- @return (table|nil) A table of localized dispel type names or nil.
function lib:GetDispelTypeNames(bitmask, spellId)
	bitmask = bitmask or spellId and specials.DISPEL[spellId]

	if not bitmask then return end

	local names = {}
	for mask, name in pairs(DISPEL_TYPE_NAMES) do
		if band(bitmask, mask) > 0 then
			names[#names + 1] = name
		end
	end
	return names
end

--- Return information about a spell.
-- @param spellId (number) The spell identifier.
-- @return (number) The spell flags or nil if it is unknown.
-- @return (number|table) Spell(s) providing the given spell.
-- @return (number|table) Spell(s) modified by the given spell.
-- @return (number) Crowd control category, if the spell is a crowd control.
-- @return (string) Spell source(s).
-- @return (number) Dispel category, if the spell is a dispel.
function lib:GetSpellInfo(spellId)
	local flags = spellId and spells[spellId]
	if flags then
		return flags, providers[spellId], modifiers[spellId], specials.CROWD_CTRL[spellId], sources[spellId], specials.DISPEL[spellId]
	end
end

-- Filter valid spell ids.
-- This can fails when the client cache is empty (e.g. after a major patch).
-- Accept a table, in which case it is recursively validated.
local function FilterSpellId(spellId, spellType, errors)
	if type(spellId) == "table"  then
		local ids = {}
		for i, subId in pairs(spellId) do
			local validated = FilterSpellId(subId, spellType, errors)
			if validated then
				tinsert(ids, validated)
			end
		end
		return next(ids) and ids or nil
	elseif type(spellId) ~= "number" then
		errors[spellId] = format("invalid %s, expected number, got %s", spellType, type(spellId))
	elseif not GetSpellInfo(spellId) then
		errors[spellId] = format("unknown %s", spellType)
	else
		return spellId
	end
end

-- Flatten and validate the spell data.
local function FlattenSpellData(source, target, prefix, errorLevel)
	prefix = strtrim(prefix)
	for key, value in pairs(source) do
		local keyType, valueType = type(key), type(value)
		if valueType == "number" then
			-- value is a spell id
			target[value] = prefix
		elseif keyType == "number" and value == true then
			-- key is a spell id, value is true
			target[key] = prefix
		elseif keyType == "number" and valueType == "string" then
			-- key is a spell id, value is a flag
			target[key] = prefix.." "..value
		elseif keyType == "string" and valueType == "table" then
			-- Value is a nested table, key indicates common flags
			FlattenSpellData(value, target,  prefix.." "..key, errorLevel+1)
		else
			error(format("%s: invalid spell definition: [%q] = %q", MAJOR, tostring(key), tostring(value)), errorLevel+1)
		end
	end
end

-- either a or b is not nil
-- a and b are either a number or a table
local function Merge(a, b)
	if not a then return b end
	if not b then return a end

	local hash = {}

	if type(a) == "number" then hash[a] = true
	else for i = 1, #a do hash[a[i]] = true end end

	if type(b) == "number" then hash[b] = true
	else for i = 1, #b do hash[b[i]] = true end end

	local merged = {}
	for k in pairs(hash) do merged[#merged + 1] = k end

	if #merged == 1 then return merged[1] end

	table.sort(merged)
	return merged
end

function lib:__RegisterSpells(category, interface, minor, newSpells, newProviders, newModifiers)
	if not categories[category] then
		error(format("%s: invalid category: %q", MAJOR, tostring(category)), 2)
	end
	local version = tonumber(interface) * 100 + minor

	if (versions[category] or 0) >= version then return end
	versions[category] = version

	local categoryFlag = constants[category] or 0

	-- Wipe previous spells
	local db, crowd_ctrl, dispels = categories[category], specials.CROWD_CTRL, specials.DISPEL
	for spellId in pairs(db) do
		db[spellId] = nil
		-- wipe the rest only if the current category is the only source
		local sourceFlags = band(spells[spellId], masks.SOURCE)
		if bxor(sourceFlags, categoryFlag) == 0 then
			spells[spellId] = nil
			providers[spellId] = nil
			modifiers[spellId] = nil
			crowd_ctrl[spellId] = nil
			dispels[spellId] = nil
			sources[spellId] = nil
		end

		if spells[spellId] then -- there are other sources
			-- remove current category from source flags
			spells[spellId] = bxor(spells[spellId], categoryFlag)
			-- can't remove old providers -> slight performance hit but no problem
			-- can't remove old modifiers -> slight performance hit but no problem
			-- crowd_ctrl and dispels contain no source information
			sources[spellId] = strtrim(gsub(sources[spellId], category, ""))
		end
	end

	-- Flatten the spell definitions
	local defs = {}
	FlattenSpellData(newSpells, defs, "", 2)

	-- Useful constants
	local CROWD_CTRL = constants.CROWD_CTRL
	local DISPEL = constants.DISPEL
	local TYPE = masks.TYPE
	local CROWD_CTRL_TYPE = masks.CROWD_CTRL_TYPE
	local NOT_CC_TYPE = bnot(CROWD_CTRL_TYPE)
	local DISPEL_TYPE = masks.DISPEL_TYPE
	local NOT_DISPEL_TYPE = bnot(DISPEL_TYPE)

	local errors = {}

	-- Build the flags
	for spellId, flagDef in pairs(defs) do
		spellId = FilterSpellId(spellId, "spell", errors)
		if spellId then
			local flags = filters[flagDef]

			if band(flags, TYPE) == CROWD_CTRL then
				crowd_ctrl[spellId] = band(flags, CROWD_CTRL_TYPE)
				-- clear the crowd control flags
				flags = band(flags, NOT_CC_TYPE)
			elseif band(flags, TYPE) == DISPEL then
				dispels[spellId] = band(flags, DISPEL_TYPE)
				-- clear the dispel flags
				flags = band(flags, NOT_DISPEL_TYPE)
			end

			db[spellId] = bor(db[spellId] or 0, flags, categoryFlag) -- TODO: db[spellId] can't be present?
		end
	end

	-- Consistency checks
	if newProviders then
		for spellId, providerId in pairs(newProviders) do
			if not db[spellId] then
				if not errors[spellId] then
					errors[spellId] = "only in providers"
				end
				newProviders[spellId] = nil
			else
				local validSpellId = FilterSpellId(spellId, "provided spell", errors)
				local validProviderId = FilterSpellId(providerId, "provider spell", errors)
				newProviders[spellId] = validSpellId and validProviderId
			end
		end
	end
	if newModifiers then
		for spellId, modified in pairs(newModifiers) do
			if not db[spellId] then
				if not errors[spellId] then
					errors[spellId] = "only in modifiers"
				end
				newModifiers[spellId] = nil
			else
				local validSpellId = FilterSpellId(spellId, "modifier spell", errors)
				local validModified = FilterSpellId(modified, "modified spell", errors)
				newModifiers[spellId] = validSpellId and validModified
			end
		end
	end

	-- Copy the new values to the merged categories
	for spellId in pairs(db) do
		spells[spellId] = bor(spells[spellId] or 0, db[spellId])
		providers[spellId] = Merge(newProviders and newProviders[spellId] or spellId, providers[spellId])
		modifiers[spellId] = Merge(newModifiers and newModifiers[spellId] or providers[spellId], modifiers[spellId])
		sources[spellId] = format("%s%s", sources[spellId] and sources[spellId].." " or "", category)
	end

	local errorCount = 0
	for spellId, msg in pairs(errors) do
		Debug(category, format("spell #%d: %s", spellId, msg))
		errorCount = errorCount + 1
	end

	return errorCount
end

return lib
