if TukuiCF.unitframes.enable ~= true or TukuiCF.unitframes.healcomm ~= true then return end
local major = "LibHealComm-4.0"
local minor = 64
assert(LibStub, string.format("%s requires LibStub.", major))

local HealComm = LibStub:NewLibrary(major, minor)
if( not HealComm ) then return end

-- API CONSTANTS
--local ALL_DATA = 0x0f
local DIRECT_HEALS = 0x01
local CHANNEL_HEALS = 0x02
local HOT_HEALS = 0x04
--local ABSORB_SHIELDS = 0x08
local BOMB_HEALS = 0x10
local ALL_HEALS = bit.bor(DIRECT_HEALS, CHANNEL_HEALS, HOT_HEALS, BOMB_HEALS)
local CASTED_HEALS = bit.bor(DIRECT_HEALS, CHANNEL_HEALS)
local OVERTIME_HEALS = bit.bor(HOT_HEALS, CHANNEL_HEALS)

HealComm.ALL_HEALS, HealComm.CHANNEL_HEALS, HealComm.DIRECT_HEALS, HealComm.HOT_HEALS, HealComm.CASTED_HEALS, HealComm.ABSORB_SHIELDS, HealComm.ALL_DATA, HealComm.BOMB_HEALS = ALL_HEALS, CHANNEL_HEALS, DIRECT_HEALS, HOT_HEALS, CASTED_HEALS, ABSORB_SHIELDS, ALL_DATA, BOMB_HEALS

local COMM_PREFIX = "LHC40"
local playerGUID, playerName, playerLevel
local playerHealModifier = 1
local IS_BUILD30300 = tonumber((select(4, GetBuildInfo()))) >= 30300

HealComm.callbacks = HealComm.callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(HealComm)
HealComm.spellData = HealComm.spellData or {}
HealComm.hotData = HealComm.hotData or {}
HealComm.talentData = HealComm.talentData or {}
HealComm.itemSetsData = HealComm.itemSetsData or {}
HealComm.glyphCache = HealComm.glyphCache or {}
HealComm.equippedSetCache = HealComm.equippedSetCache or {}
HealComm.guidToGroup = HealComm.guidToGroup or {}
HealComm.guidToUnit = HealComm.guidToUnit or {}
HealComm.pendingHeals = HealComm.pendingHeals or {}
HealComm.tempPlayerList = HealComm.tempPlayerList or {}
HealComm.activePets = HealComm.activePets or {}
HealComm.activeHots = HealComm.activeHots or {}

if( not HealComm.unitToPet ) then
	HealComm.unitToPet = {["player"] = "pet"}
	for i=1, MAX_PARTY_MEMBERS do HealComm.unitToPet["party" .. i] = "partypet" .. i end
	for i=1, MAX_RAID_MEMBERS do HealComm.unitToPet["raid" .. i] = "raidpet" .. i end
end

local spellData, hotData, tempPlayerList, pendingHeals = HealComm.spellData, HealComm.hotData, HealComm.tempPlayerList, HealComm.pendingHeals
local equippedSetCache, itemSetsData, talentData = HealComm.equippedSetCache, HealComm.itemSetsData, HealComm.talentData
local activeHots, activePets = HealComm.activeHots, HealComm.activePets

-- Figure out what they are now since a few things change based off of this
local playerClass = select(2, UnitClass("player"))
local isHealerClass = playerClass == "DRUID" or playerClass == "PRIEST" or playerClass == "SHAMAN" or playerClass == "PALADIN"

-- Stolen from Threat-2.0, compresses GUIDs from 18 characters to around 8 - 9, 50%/55% savings
-- 44 = , / 58 = : / 255 = \255 / 0 = line break / 64 = @ / 254 = FE, used for escape code so has to be escaped
if( not HealComm.compressGUID or not HealComm.fixedCompress ) then
	local map = {[58] = "\254\250", [64] = "\254\251",  [44] = "\254\252", [255] = "\254\253", [0] = "\255", [254] = "\254\249"}
	local function guidCompressHelper(x)
	   local a = tonumber(x, 16)
	   return map[a] or string.char(a)
	end
	
	local dfmt = "0x%02X%02X%02X%02X%02X%02X%02X%02X"
	local function unescape(str)
		str = string.gsub(str, "\255", "\000")
		str = string.gsub(str, "\254\250", "\058")
		str = string.gsub(str, "\254\251", "\064")
		str = string.gsub(str, "\254\252", "\044")
		str = string.gsub(str, "\254\253", "\255")
		return string.gsub(str, "\254\249", "\254")
	end
	
	HealComm.fixedCompress = true
	HealComm.compressGUID = setmetatable({}, {
		__index = function(tbl, guid)
			local cguid = string.match(guid, "0x(.*)")
			local str = string.gsub(cguid, "(%x%x)", guidCompressHelper)
			
			rawset(tbl, guid, str)
			return str
	end})
	
	HealComm.decompressGUID = setmetatable({}, {
		__index = function(tbl, str)
			if( not str ) then return nil end
			local usc = unescape(str)
			local a, b, c, d, e, f, g, h = string.byte(usc, 1, 8)

			-- Failed to decompress, silently exit
			if( not a or not b or not c or not d or not e or not f or not g or not h ) then
				return ""
			end
			
			local guid = string.format(dfmt, a, b, c, d, e, f, g, h)
	
			rawset(tbl, str, guid)
			return guid
	end})
end

local compressGUID, decompressGUID = HealComm.compressGUID, HealComm.decompressGUID

-- Handles caching of tables for variable tick spells, like Wild Growth
if( not HealComm.tableCache ) then
	HealComm.tableCache = setmetatable({}, {__mode = "k"})
	function HealComm:RetrieveTable()
		return table.remove(HealComm.tableCache, 1) or {}
	end

	function HealComm:DeleteTable(tbl)
		table.wipe(tbl)
		table.insert(HealComm.tableCache, tbl)
	end
end
	
-- Validation for passed arguments
if( not HealComm.tooltip ) then
	local tooltip = CreateFrame("GameTooltip")
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip.TextLeft1 = tooltip:CreateFontString()
	tooltip.TextRight1 = tooltip:CreateFontString()
	tooltip:AddFontStrings(tooltip.TextLeft1, tooltip.TextRight1)
	
	HealComm.tooltip = tooltip
end

-- So I don't have to keep matching the same numbers every time or create a local copy of every rank -> # map for locals
if( not HealComm.rankNumbers ) then
	HealComm.rankNumbers = setmetatable({}, {
		__index = function(tbl, index)
			local number = tonumber(string.match(index, "(%d+)")) or 1
			
			rawset(tbl, index, number)
			return number
		end,
	})
end

-- Find the spellID by the name/rank combination
-- Need to swap this to a double table metatable something like [spellName][spellRank] so I can reduce the garbage created
if( not HealComm.spellToID ) then
	HealComm.spellToID = setmetatable({}, {
		__index = function(tbl, index)
			-- Find the spell from the spell book and cache the results!
			local offset, numSpells = select(3, GetSpellTabInfo(GetNumSpellTabs()))
			for id=1, (offset + numSpells) do
				-- Match, yay!
				local spellName, spellRank = GetSpellName(id, BOOKTYPE_SPELL)
				local name = spellName .. spellRank
				if( index == name ) then
					HealComm.tooltip:SetSpell(id, BOOKTYPE_SPELL)
					local spellID = select(3, HealComm.tooltip:GetSpell())
					if( spellID ) then
						rawset(tbl, index, spellID)
						return spellID
					end
				end
			end
			
			rawset(tbl, index, false)
			return false
		end,
	})
end

-- This gets filled out after data has been loaded, this is only for casted heals. Hots just directly pull from the averages as they do not increase in power with level, Cataclysm will change this though.
if( HealComm.averageHealMT and not HealComm.fixedAverage ) then
	HealComm.averageHealMT = nil
end

HealComm.fixedAverage = true
HealComm.averageHeal = HealComm.averageHeal or {}
HealComm.averageHealMT = HealComm.averageHealMT or {
	__index = function(tbl, index)
		local rank = HealComm.rankNumbers[index]
		local spellData = HealComm.spellData[rawget(tbl, "spell")]
		local spellLevel = spellData.levels[rank]
		
		-- No increase, it doesn't scale with levely
		if( not spellData.increase or UnitLevel("player") <= spellLevel ) then
			rawset(tbl, index, spellData.averages[rank])
			return spellData.averages[rank]
		end
		
		local average = spellData.averages[rank]
		if( UnitLevel("level") >= MAX_PLAYER_LEVEL ) then
			average = average + spellData.increase[rank]
		-- Here's how this works: If a spell increases 1,000 between 70 and 80, the player is level 75 the spell is 70
		-- it's 1000 / (80 - 70) so 100, the player learned the spell 5 levels ago which means that the spell average increases by 500
		-- This figures out how much it increases per level and how ahead of the spells level they are to figure out how much to add
		else
			average = average + (UnitLevel("player") - spellLevel) * (spellData.increase[rank] / (MAX_PLAYER_LEVEL - spellLevel))
		end
		
		rawset(tbl, index, average)
		return average
	end}
	
-- Record management, because this is getting more complicted to deal with
local function updateRecord(pending, guid, amount, stack, endTime, ticksLeft)
	if( pending[guid] ) then
		local id = pending[guid]
		
		pending[id] = guid
		pending[id + 1] = amount
		pending[id + 2] = stack
		pending[id + 3] = endTime or 0
		pending[id + 4] = ticksLeft or 0
	else
		pending[guid] = #(pending) + 1
		table.insert(pending, guid)
		table.insert(pending, amount)
		table.insert(pending, stack)
		table.insert(pending, endTime or 0)
		table.insert(pending, ticksLeft or 0)

		if( pending.bitType == HOT_HEALS ) then
			activeHots[guid] = (activeHots[guid] or 0) + 1
			HealComm.hotMonitor:Show()
		end
	end
end

local function getRecord(pending, guid)
	local id = pending[guid]
	if( not id ) then return nil end
	
	-- amount, stack, endTime, ticksLeft
	return pending[id + 1], pending[id + 2], pending[id + 3], pending[id + 4]
end

local function removeRecord(pending, guid)
	local id = pending[guid]
	if( not id ) then return nil end
	
	-- ticksLeft, endTime, stack, amount, guid
	table.remove(pending, id + 4)
	table.remove(pending, id + 3)
	table.remove(pending, id + 2)
	local amount = table.remove(pending, id + 1)
	table.remove(pending, id)
	pending[guid] = nil
	
	-- Release the table
	if( type(amount) == "table" ) then HealComm:DeleteTable(amount) end
	
	if( pending.bitType == HOT_HEALS and activeHots[guid] ) then
		activeHots[guid] = activeHots[guid] - 1
		activeHots[guid] = activeHots[guid] > 0 and activeHots[guid] or nil
	end
	
	-- Shift any records after this ones index down 5 to account for the removal
	for i=1, #(pending), 5 do
		local guid = pending[i]
		if( pending[guid] > id ) then
			pending[guid] = pending[guid] - 5
		end
	end
end

local function removeRecordList(pending, inc, comp, ...)
	for i=1, select("#", ...), inc do
		local guid = select(i, ...)
		guid = comp and decompressGUID[guid] or guid
		
		local id = pending[guid]
		-- ticksLeft, endTime, stack, amount, guid
		table.remove(pending, id + 4)
		table.remove(pending, id + 3)
		table.remove(pending, id + 2)
		local amount = table.remove(pending, id + 1)
		table.remove(pending, id)
		pending[guid] = nil

		-- Release the table
		if( type(amount) == "table" ) then HealComm:DeleteTable(amount) end
	end
	
	-- Redo all the id maps
	for i=1, #(pending), 5 do
		pending[pending[i]] = i
	end
end

-- Removes every mention to the given GUID
local function removeAllRecords(guid)
	local changed
	for _, spells in pairs(pendingHeals) do
		for _, pending in pairs(spells) do
			if( pending.bitType and pending[guid] ) then
				local id = pending[guid]
				
				-- ticksLeft, endTime, stack, amount, guid
				table.remove(pending, id + 4)
				table.remove(pending, id + 3)
				table.remove(pending, id + 2)
				local amount = table.remove(pending, id + 1)
				table.remove(pending, id)
				pending[guid] = nil
				
				-- Release the table
				if( type(amount) == "table" ) then HealComm:DeleteTable(amount) end

				-- Shift everything back
				if( #(pending) > 0 ) then
					for i=1, #(pending), 5 do
						local guid = pending[i]
						if( pending[guid] > id ) then
							pending[guid] = pending[guid] - 5
						end
					end
				else
					table.wipe(pending)
				end
				
				changed = true
			end
		end
	end
	
	activeHots[guid] = nil
	
	if( changed ) then
		HealComm.callbacks:Fire("HealComm_GUIDDisappeared", guid)
	end
end

-- These are not public APIs and are purely for the wrapper to use
HealComm.removeRecordList = removeRecordList
HealComm.removeRecord = removeRecord
HealComm.getRecord = getRecord
HealComm.updateRecord = updateRecord

-- Removes all pending heals, if it's a group that is causing the clear then we won't remove the players heals on themselves
local function clearPendingHeals()
	for casterGUID, spells in pairs(pendingHeals) do
		for _, pending in pairs(spells) do
			if( pending.bitType ) then
 				table.wipe(tempPlayerList)
				for i=#(pending), 1, -5 do table.insert(tempPlayerList, pending[i - 4]) end
				
				if( #(tempPlayerList) > 0 ) then
					local spellID, bitType = pending.spellID, pending.bitType
					table.wipe(pending)
					
					HealComm.callbacks:Fire("HealComm_HealStopped", casterGUID, spellID, bitType, true, unpack(tempPlayerList))
				end
			end
		end
	end
end

-- APIs
-- Returns the players current heaing modifier
function HealComm:GetPlayerHealingMod()
	return playerHealModifier or 1
end

-- Returns the current healing modifier for the GUID
function HealComm:GetHealModifier(guid)
	return HealComm.currentModifiers[guid] or 1
end

-- Returns whether or not the GUID has casted a heal
function HealComm:GUIDHasHealed(guid)
	return pendingHeals[guid] and true or nil
end

-- Returns the guid to unit table
function HealComm:GetGUIDUnitMapTable()
	if( not HealComm.protectedMap ) then
		HealComm.protectedMap = setmetatable({}, {
			__index = function(tbl, key) return HealComm.guidToUnit[key] end,
			__newindex = function() error("This is a read only table and cannot be modified.", 2) end,
			__metatable = false
		})
	end
	
	return HealComm.protectedMap
end

-- Gets the next heal landing on someone using the passed filters
function HealComm:GetNextHealAmount(guid, bitFlag, time, ignoreGUID)
	local healTime, healAmount, healFrom
	local currentTime = GetTime()
	
	for casterGUID, spells in pairs(pendingHeals) do
		if( not ignoreGUID or ignoreGUID ~= casterGUID ) then
			for _, pending in pairs(spells) do
				if( pending.bitType and bit.band(pending.bitType, bitFlag) > 0 ) then
					for i=1, #(pending), 5 do
						local guid = pending[i]
						local amount = pending[i + 1]
						local stack = pending[i + 2]
						local endTime = pending[i + 3]
						endTime = endTime > 0 and endTime or pending.endTime
							
						-- Direct heals are easy, if they match the filter then return them
						if( ( pending.bitType == DIRECT_HEALS or pending.bitType == BOMB_HEALS ) and ( not time or endTime <= time ) ) then
							if( not healTime or endTime < healTime ) then
								healTime = endTime
								healAmount = amount * stack
								healFrom = casterGUID
							end
							
						-- Channeled heals and hots, have to figure out how many times it'll tick within the given time band
						elseif( ( pending.bitType == CHANNEL_HEALS or pending.bitType == HOT_HEALS ) and ( not pending.hasVariableTicks or pending.hasVariableTicks and amount[1] ) ) then
							local secondsLeft = time and time - currentTime or endTime - currentTime
							local nextTick = currentTime + (secondsLeft % pending.tickInterval)
							if( not healTime or nextTick < healTime ) then
								healTime = nextTick
								healAmount = not pending.hasVariableTicks and amount * stack or amount[1] * stack
								healFrom = casterGUID
							end
						end
					end
				end
			end
		end
	end
	
	return healTime, healFrom, healAmount
end

-- Get the healing amount that matches the passed filters
local function filterData(spells, filterGUID, bitFlag, time, ignoreGUID)
	local healAmount = 0
	local currentTime = GetTime()
	
	for _, pending in pairs(spells) do
		if( pending.bitType and bit.band(pending.bitType, bitFlag) > 0 ) then
			for i=1, #(pending), 5 do
				local guid = pending[i]
				if( guid == filterGUID or ignoreGUID ) then
					local amount = pending[i + 1]
					local stack = pending[i + 2]
					local endTime = pending[i + 3]
					endTime = endTime > 0 and endTime or pending.endTime

					-- Direct heals are easy, if they match the filter then return them
					if( ( pending.bitType == DIRECT_HEALS or pending.bitType == BOMB_HEALS ) and ( not time or endTime <= time ) ) then
						healAmount = healAmount + amount * stack
					-- Channeled heals and hots, have to figure out how many times it'll tick within the given time band
					elseif( ( pending.bitType == CHANNEL_HEALS or pending.bitType == HOT_HEALS ) and endTime > currentTime ) then
						local ticksLeft = pending[i + 4]
						if( not time or time >= endTime ) then
							if( not pending.hasVariableTicks ) then
								healAmount = healAmount + (amount * stack) * ticksLeft
							else
								for _, heal in pairs(amount) do
									healAmount = healAmount + (heal * stack)
								end
							end
						else
							local secondsLeft = endTime - currentTime
							local bandSeconds = time - currentTime
							local ticks = math.floor(math.min(bandSeconds, secondsLeft) / pending.tickInterval)
							local nextTickIn = secondsLeft % pending.tickInterval
							local fractionalBand = bandSeconds % pending.tickInterval
							if( nextTickIn > 0 and nextTickIn < fractionalBand ) then
								ticks = ticks + 1
							end
							
							if( not pending.hasVariableTicks ) then
								healAmount = healAmount + (amount * stack) * math.min(ticks, ticksLeft)
							else
								for i=1, math.min(ticks, #(amount)) do
									healAmount = healAmount + (amount[i] * stack)
								end
							end
						end
					end
				end
			end
		end
	end
	
	return healAmount
end

-- Gets healing amount using the passed filters
function HealComm:GetHealAmount(guid, bitFlag, time, casterGUID)
	local amount = 0
	if( casterGUID and pendingHeals[casterGUID] ) then
		amount = filterData(pendingHeals[casterGUID], guid, bitFlag, time)
	elseif( not casterGUID ) then
		for _, spells in pairs(pendingHeals) do
			amount = amount + filterData(spells, guid, bitFlag, time)
		end
	end
	
	return amount > 0 and amount or nil
end

-- Gets healing amounts for everyone except the player using the passed filters
function HealComm:GetOthersHealAmount(guid, bitFlag, time)
	local amount = 0
	for casterGUID, spells in pairs(pendingHeals) do
		if( casterGUID ~= playerGUID ) then
			amount = amount + filterData(spells, guid, bitFlag, time)
		end
	end
	
	return amount > 0 and amount or nil
end

function HealComm:GetCasterHealAmount(guid, bitFlag, time)
	local amount = pendingHeals[guid] and filterData(pendingHeals[guid], nil, bitFlag, time, true) or 0
	return amount > 0 and amount or nil
end

-- Healing class data
-- Thanks to Gagorian (DrDamage) for letting me steal his formulas and such
local playerCurrentRelic
local averageHeal, rankNumbers = HealComm.averageHeal, HealComm.rankNumbers
local guidToUnit, guidToGroup, glyphCache = HealComm.guidToUnit, HealComm.guidToGroup, HealComm.glyphCache

-- UnitBuff priortizes our buffs over everyone elses when there is a name conflict, so yay for that
local function unitHasAura(unit, name)
	return select(8, UnitBuff(unit, name)) == "player"
end

-- Note because I always forget on the order:
-- Talents that effective the coeffiency of spell power to healing are first and are tacked directly onto the coeffiency (Empowered Rejuvenation)
-- Penalty modifiers (downranking/spell level too low) are applied directly to the spell power
-- Spell power modifiers are then applied to the spell power
-- Heal modifiers are applied after all of that
-- Crit modifiers are applied after
-- Any other modifiers such as Mortal Strike or Avenging Wrath are applied after everything else
local function calculateGeneralAmount(level, amount, spellPower, spModifier, healModifier)
	-- Apply downranking penalities for spells below 20
	local penalty = level > 20 and 1 or (1 - ((20 - level) * 0.0375))

	-- Apply further downranking penalities
	spellPower = spellPower * (penalty * math.min(1, math.max(0, 1 - (playerLevel - level - 11) * 0.05)))
				
	-- Apply zone modifier
	healModifier = healModifier * HealComm.zoneHealModifier

	-- Do the general factoring
	return healModifier * (amount + (spellPower * spModifier))
end

-- For spells like Wild Growth, it's a waste to do the calculations for each tick, easier to calculate spell power now and then manually calculate it all after
local function calculateSpellPower(level, spellPower)
	-- Apply downranking penalities for spells below 20
	local penalty = level > 20 and 1 or (1 - ((20 - level) * 0.0375))

	-- Apply further downranking penalities
	return spellPower * (penalty * math.min(1, math.max(0, 1 - (playerLevel - level - 11) * 0.05)))
end

-- Yes silly function, just cleaner to look at
local function avg(a, b)
	return (a + b) / 2
end
	
--[[
	What the different callbacks do:
	
	AuraHandler: Specific aura tracking needed for this class, who has Beacon up on them and such
	
	ResetChargeData: Due to spell "queuing" you can't always rely on aura data for buffs that last one or two casts, for example Divine Favor (+100% crit, one spell)
	if you cast Holy Light and queue Flash of Light the library would still see they have Divine Favor and give them crits on both spells. The reset means that the flag that indicates
	they have the aura can be killed and if they interrupt the cast then it will call this and let you reset the flags.
	
	What happens in terms of what the client thinks and what actually is, is something like this:
	
	UNIT_SPELLCAST_START, Holy Light -> Divine Favor up
	UNIT_SPELLCAST_SUCCEEDED, Holy Light -> Divine Favor up (But it was really used)
	UNIT_SPELLCAST_START, Flash of Light -> Divine Favor up (It's not actually up but auras didn't update)
	UNIT_AURA -> Divine Favor up (Split second where it still thinks it's up)
	UNIT_AURA -> Divine Favor faded (Client catches up and realizes it's down)
	
	CalculateHealing: Calculates the healing value, does all the formula calculations talent modifiers and such
	
	CalculateHotHealing: Used specifically for calculating the heals of hots
	
	GetHealTargets: Who the heal is going to hit, used for setting extra targets for Beacon of Light + Paladin heal or Prayer of Healing.
	The returns should either be:
	
	"compressedGUID1,compressedGUID2,compressedGUID3,compressedGUID4", healthAmount
	Or if you need to set specific healing values for one GUID it should be
	"compressedGUID1,healthAmount1,compressedGUID2,healAmount2,compressedGUID3,healAmount3", -1
	
	The latter is for cases like Glyph of Healing Wave where you need a heal for 1,000 on A and a heal for 200 on the player for B without sending 2 events.
	The -1 tells the library to look in the GUId list for the heal amounts
	
	**NOTE** Any GUID returned from GetHealTargets must be compressed through a call to compressGUID[guid]
]]
	
local CalculateHealing, GetHealTargets, AuraHandler, CalculateHotHealing, ResetChargeData, LoadClassData

-- DRUIDS
-- All data is accurate as of 3.2.2 (build 10392)
if( playerClass == "DRUID" ) then
	LoadClassData = function()
		-- Rejuvenation
		local Rejuvenation = GetSpellInfo(774)
		hotData[Rejuvenation] = {interval = 3,
			levels = {4, 10, 16, 22, 28, 34, 40, 46, 52, 58, 60, 63, 69, 75, 80}, averages = {32, 56, 116, 180, 244, 304, 388, 488, 608, 756, 888, 932, 1060, 1192, 1690}}
		-- Regrowth
		local Regrowth = GetSpellInfo(8936)
		hotData[Regrowth] = {interval = 3, ticks = 7, coeff = 1.316,
			levels = {12, 18, 24, 30, 36, 42, 48, 54, 60, 65, 71, 77}, averages = {98, 175, 259, 343, 427, 546, 686, 861, 1064, 1274, 1792, 2345}}
		-- Lifebloom
		local Lifebloom = GetSpellInfo(33763)
		hotData[Lifebloom] = {interval = 1, ticks = 7, coeff = 0.66626, dhCoeff = 0.34324 * 0.8, levels = {64, 72, 80}, averages = {224, 287, 371}, bomb = {480, 616, 776}}
		-- Wild Growth
		local WildGrowth = GetSpellInfo(48438)
		hotData[WildGrowth] = {interval = 1, ticks = 7, coeff = 0.8056, levels = {60, 70, 75, 80}, averages = {686, 861, 1239, 1442}}
		
		-- Regrowth
		spellData[Regrowth] = {coeff = 0.2867,
			levels = hotData[Regrowth].levels,
			averages = {avg(84, 98), avg(164, 188), avg(240, 274), avg(318, 360), avg(405, 457), avg(511, 575), avg(646, 724), avg(809, 905), avg(1003, 1119), avg(1215, 1355), avg(1710, 1908), avg(2234, 2494)},
			increase = {122, 155, 173, 180, 180, 178, 169, 156, 136, 115, 97, 23}}
		-- Healing Touch
		local HealingTouch = GetSpellInfo(5185)
		spellData[HealingTouch] = {
			levels = {1, 8, 14, 20, 26, 32, 38, 44, 50, 56, 60, 62, 69, 74, 79},
			averages = {avg(37, 51), avg(88, 112), avg(195, 243), avg(363, 445), avg(490, 594), avg(636, 766), avg(802, 960), avg(1199, 1427), avg(1299, 1539), avg(1620, 1912), avg(1944, 2294), avg(2026, 2392), avg(2321, 2739), avg(3223, 3805), avg(3750, 4428)}}
		-- Nourish
		local Nourish = GetSpellInfo(50464)
		spellData[Nourish] = {coeff = 0.358005, levels = {80}, averages = {avg(1883, 2187)}}
		-- Tranquility
		local Tranquility = GetSpellInfo(740)
		spellData[Tranquility] = {coeff = 1.144681, ticks = 4, levels = {30, 40, 50, 60, 70, 75, 80}, averages = {351, 515, 765, 1097, 1518, 2598, 3035}}
	
		-- Talent data, these are filled in later and modified on talent changes
		-- Master Shapeshifter (Multi)
		local MasterShapeshifter = GetSpellInfo(48411)
		talentData[MasterShapeshifter] = {mod = 0.02, current = 0}
		-- Gift of Nature (Add)
		local GiftofNature = GetSpellInfo(17104)
		talentData[GiftofNature] = {mod = 0.02, current = 0}
		-- Empowered Touch (Add, increases spell power HT/Nourish gains)
		local EmpoweredTouch = GetSpellInfo(33879)
		talentData[EmpoweredTouch] = {mod = 0.2, current = 0}
		-- Empowered Rejuvenation (Multi, this ups both the direct heal and the hot)
		local EmpoweredRejuv = GetSpellInfo(33886)
		talentData[EmpoweredRejuv] = {mod = 0.04, current = 0}
		-- Genesis (Add)
		local Genesis = GetSpellInfo(57810)
		talentData[Genesis] = {mod = 0.01, current = 0}
		-- Improved Rejuvenation (Add)
		local ImprovedRejuv = GetSpellInfo(17111)
		talentData[ImprovedRejuv] = {mod = 0.05, current = 0}
		-- Nature's Splendor (+3s Rejuv/+6s Regrowth/+2s Lifebloom)
		local NaturesSplendor = GetSpellInfo(57865)
		talentData[NaturesSplendor] = {mod = 1, current = 0}
		
		local TreeofLife = GetSpellInfo(33891)
		local Innervate = GetSpellInfo(29166)
		
		-- Set data
		-- 2 piece, +6 seconds to Regrowth
		itemSetsData["T5 Resto"] = {30216, 30217, 30219, 30220, 30221}
		-- +5% more healing to Nourish per hot
		itemSetsData["T7 Resto"] = {40460, 40461, 40462, 40463, 40465, 39531, 39538, 39539, 39542, 39543}
		--itemSetsData["T8 Resto"] = {46183, 46184, 46185, 46186, 46187, 45345, 45346, 45347, 45348, 45349} 
		--itemSetsData["T9 Resto"] = {48102, 48129, 48130, 48131, 48132, 48153, 48154, 48155, 48156, 48157, 48133, 48134, 48135, 48136, 48137, 48142, 48141, 48140, 48139, 48138, 48152, 48151, 48150, 48149, 48148, 48143, 48144, 48145, 48146, 48147}
		-- 2 piece, 30% less healing lost on WG
		itemSetsData["T10 Resto"] = {50106, 50107, 50108, 50109, 50113, 51139, 51138, 51137, 51136, 51135, 51300, 51301, 51302, 51303, 51304}
		
		local bloomBombIdols = {[28355] = 87, [33076] = 105, [33841] = 116, [35021] = 131, [42576] = 188, [42577] = 217, [42578] = 246, [42579] = 294, [42580] = 376, [51423] = 448}
		
		local hotTotals, hasRegrowth = {}, {}
		AuraHandler = function(unit, guid)
			hotTotals[guid] = 0
			if( unitHasAura(unit, Rejuvenation) ) then hotTotals[guid] = hotTotals[guid] + 1 end
			if( unitHasAura(unit, Lifebloom) ) then hotTotals[guid] = hotTotals[guid] + 1 end
			if( unitHasAura(unit, WildGrowth) ) then hotTotals[guid] = hotTotals[guid] + 1 end
			if( unitHasAura(unit, Regrowth) ) then
				hasRegrowth[guid] = true
				hotTotals[guid] = hotTotals[guid] + 1
			else
				hasRegrowth[guid] = nil
			end
		end
	
		GetHealTargets = function(bitType, guid, healAmount, spellName, hasVariableTicks)
			-- Tranquility pulses on everyone within 30 yards, if they are in range of Innervate they'll get Tranquility
			if( spellName == Tranquility ) then
				local targets = compressGUID[playerGUID]
				local playerGroup = guidToGroup[playerGUID]
				
				for groupGUID, id in pairs(guidToGroup) do
					if( id == playerGroup and playerGUID ~= groupGUID and not UnitHasVehicleUI(guidToUnit[groupID]) and IsSpellInRange(Innervate, guidToUnit[groupGUID]) == 1 ) then
						targets = targets .. "," .. compressGUID[groupGUID]
					end
				end
				
				return targets, healAmount
			elseif( hasVariableTicks ) then
				healAmount = table.concat(healAmount, "@")
			end
			
			return compressGUID[guid], healAmount
		end
		
		-- Calculate hot heals
		local wgTicks = {}
		CalculateHotHealing = function(guid, spellID)
			local spellName, spellRank = GetSpellInfo(spellID)
			local rank = HealComm.rankNumbers[spellRank]
			local healAmount = hotData[spellName].averages[rank]
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			local bombAmount, totalTicks
			healModifier = healModifier + talentData[GiftofNature].current
			healModifier = healModifier + talentData[Genesis].current
					
			-- Master Shapeshifter does not apply directly when using Lifebloom
			if( unitHasAura("player", TreeofLife) ) then
				healModifier = healModifier * (1 + talentData[MasterShapeshifter].current)
				
				-- 32387 - Idol of the Raven Godess, +44 SP while in TOL
				if( playerCurrentRelic == 32387 ) then
					spellPower = spellPower + 44
				end
			end
			
			-- Rejuvenation
			if( spellName == Rejuvenation ) then
				healModifier = healModifier + talentData[ImprovedRejuv].current
	
				-- 25643 - Harold's Rejuvenation Broach, +86 Rejuv SP
				if( playerCurrentRelic == 25643 ) then
					spellPower = spellPower + 86
				-- 22398 - Idol of Rejuvenation, +50 SP to Rejuv
				elseif( playerCurrentRelic == 22398 ) then
					spellPower = spellPower + 50
				end
				
				local duration, ticks
				if( IS_BUILD30300 ) then
					duration = 15
					ticks = 5
					totalTicks = 5
				else
					duration = rank > 14 and 15 or 12
					ticks = duration / hotData[spellName].interval
					totalTicks = ticks
				end
				
				spellPower = spellPower * (((duration / 15) * 1.88) * (1 + talentData[EmpoweredRejuv].current))
				spellPower = spellPower / ticks
				healAmount = healAmount / ticks
				
				--38366 - Idol of Pure Thoughts, +33 SP base per tick
				if( playerCurrentRelic == 38366 ) then
					spellPower = spellPower + 33
				end

				-- Nature's Splendor, +6 seconds
				if( talentData[NaturesSplendor].mod >= 1 ) then totalTicks = totalTicks + 1 end

			-- Regrowth
			elseif( spellName == Regrowth ) then
				spellPower = spellPower * (hotData[spellName].coeff * (1 + talentData[EmpoweredRejuv].current))
				spellPower = spellPower / hotData[spellName].ticks
				healAmount = healAmount / hotData[spellName].ticks
				
				totalTicks = 7
				-- Nature's Splendor, +6 seconds
				if( talentData[NaturesSplendor].mod >= 1 ) then totalTicks = totalTicks + 2 end
				-- T5 Resto, +6 seconds
				if( equippedSetCache["T5 Resto"] >= 2 ) then totalTicks = totalTicks + 2 end
				
			-- Lifebloom
			elseif( spellName == Lifebloom ) then
				-- Figure out the bomb heal, apparently Gift of Nature double dips and will heal 10% for the HOT + 10% again for the direct heal
				local bombSpellPower = spellPower
				if( playerCurrentRelic and bloomBombIdols[playerCurrentRelic] ) then
					bombSpellPower = bombSpellPower + bloomBombIdols[playerCurrentRelic]
				end
				
				local bombSpell = bombSpellPower * (hotData[spellName].dhCoeff * 1.88)
				bombAmount = math.ceil(calculateGeneralAmount(hotData[spellName].levels[rank], hotData[spellName].bomb[rank], bombSpell, spModifier, healModifier + talentData[GiftofNature].current))
			
				-- Figure out the hot tick healing
				spellPower = spellPower * (hotData[spellName].coeff * (1 + talentData[EmpoweredRejuv].current))
				spellPower = spellPower / hotData[spellName].ticks
				healAmount = healAmount / hotData[spellName].ticks
				-- Figure out total ticks
				totalTicks = 7
				
				-- Idol of Lush Moss, +125 SP per tick
				if( playerCurrentRelic == 40711 ) then
					spellPower = spellPower + 125
				-- Idol of the Emerald Queen, +47 SP per tick
				elseif( playerCurrentRelic == 27886 ) then
					spellPower = spellPower + 47
				end
								
				-- Glyph of Lifebloom, +1 second
				if( glyphCache[54826] ) then totalTicks = totalTicks + 1 end
				-- Nature's Splendor, +2 seconds
				if( talentData[NaturesSplendor].mod >= 1 ) then totalTicks = totalTicks + 1 end
			-- Wild Growth
			elseif( spellName == WildGrowth ) then
				spellPower = spellPower * (hotData[spellName].coeff * (1 + talentData[EmpoweredRejuv].current))
				spellPower = spellPower / hotData[spellName].ticks
				spellPower = calculateSpellPower(hotData[spellName].levels[rank], spellPower)
				healAmount = healAmount / hotData[spellName].ticks
				healModifier = healModifier * HealComm.zoneHealModifier
				
				table.wipe(wgTicks)
				local tickModifier = equippedSetCache["T10 Resto"] >= 2 and 0.70 or 1
				local tickAmount = healAmount / hotData[spellName].ticks
				for i=1, hotData[spellName].ticks do
					table.insert(wgTicks, math.ceil(healModifier * ((healAmount + tickAmount * (3 - (i - 1) * tickModifier)) + (spellPower * spModifier))))
				end

				return HOT_HEALS, wgTicks, hotData[spellName].ticks, hotData[spellName].interval, nil, true
			end
	
			healAmount = calculateGeneralAmount(hotData[spellName].levels[rank], healAmount, spellPower, spModifier, healModifier)
			return HOT_HEALS, math.ceil(healAmount), totalTicks, hotData[spellName].interval, bombAmount
		end
			
		-- Calcualte direct and channeled heals
		CalculateHealing = function(guid, spellName, spellRank)
			local healAmount = averageHeal[spellName][spellRank]
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			local rank = HealComm.rankNumbers[spellRank]
			
			-- Gift of Nature
			healModifier = healModifier + talentData[GiftofNature].current
			
			-- Master Shapeshifter does not apply directly when using Lifebloom
			if( unitHasAura("player", TreeofLife) ) then
				healModifier = healModifier * (1 + talentData[MasterShapeshifter].current)
				
				-- 32387 - Idol of the Raven Godess, +44 SP while in TOL
				if( playerCurrentRelic == 32387 ) then
					spellPower = spellPower + 44
				end
			end
			
			-- Regrowth
			if( spellName == Regrowth ) then
				-- Glyph of Regrowth - +20% if target has Regrowth
				if( glyphCache[54743] and hasRegrowth[guid] ) then
					healModifier = healModifier * 1.20
				end
				
				spellPower = spellPower * ((spellData[spellName].coeff * 1.88) * (1 + talentData[EmpoweredRejuv].current))
			-- Nourish
			elseif( spellName == Nourish ) then
				-- 46138 - Idol of Flourishing Life, +187 Nourish SP
				if( playerCurrentRelic == 46138 ) then
					spellPower = spellPower + 187
				end
				
				-- Apply any hot specific bonuses
				local hots = hotTotals[guid]
				if( hots and hots > 0 ) then
					local bonus = 1.20
					
					-- T7 Resto, +5% healing per each of the players hot on their target
					if( equippedSetCache["T7 Resto"] >= 2 ) then
						bonus = bonus + 0.05 * hots
					end
					
					-- Glyph of Nourish - 6% per HoT
					if( glyphCache[62971] ) then
						bonus = bonus + 0.06 * hots
					end
					
					healModifier = healModifier * bonus
				end
				
				spellPower = spellPower * ((spellData[spellName].coeff * 1.88) + talentData[EmpoweredTouch].spent * 0.10)
			-- Healing Touch
			elseif( spellName == HealingTouch ) then
				-- Glyph of Healing Touch, -50% healing
				if( glyphCache[54825] ) then
					healModifier = healModifier - 0.50
				end
	
				-- Idol of the Avian Heart, +136 baseh ealing
				if( playerCurrentRelic == 28568 ) then
					healAmount = healAmount + 136
				-- Idol of Health, +100 base healing
				elseif( playerCurrentRelic == 22399 ) then
					healAmount = healAmount + 100
				end
	
				-- Rank 1 - 3: 1.5/2/2.5 cast time, Rank 4+: 3 cast time
				local castTime = rank > 3 and 3 or rank == 3 and 2.5 or rank == 2 and 2 or 1.5
				spellPower = spellPower * (((castTime / 3.5) * 1.88) + talentData[EmpoweredTouch].current)
	
			-- Tranquility
			elseif( spellName == Tranquility ) then
				healModifier = healModifier + talentData[Genesis].current
				
				spellPower = spellPower * ((spellData[spellName].coeff * 1.88) * (1 + talentData[EmpoweredRejuv].current))
				spellPower = spellPower / spellData[spellName].ticks
			end
			
			healAmount = calculateGeneralAmount(spellData[spellName].levels[rank], healAmount, spellPower, spModifier, healModifier)
			
			-- 100% chance to crit with Nature, this mostly just covers fights like Loatheb where you will basically have 100% crit
			if( GetSpellCritChance(4) >= 100 ) then
				healAmount = healAmount * 1.50
			end
			
			if( spellData[spellName].ticks ) then
				return CHANNEL_HEALS, math.ceil(healAmount), spellData[spellName].ticks, spellData[spellName].ticks
			end
			
			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

-- PALADINS
-- All data is accurate as of 3.2.2 (build 10392)
if( playerClass == "PALADIN" ) then
	LoadClassData = function()
		-- Hot data, this is just so it realizes that FoL can be a hot so it will call the calculator
		--local FlashofLight = GetSpellInfo(19750)
		--hotData[FlashofLight] = true
		
		-- Spell data
		-- Holy Light
		local HolyLight = GetSpellInfo(635)
		spellData[HolyLight] = {coeff = 2.5 / 3.5 * 1.25,
			levels = {1, 6, 14, 22, 30, 38, 46, 54, 60, 62, 70, 75, 80},
			averages = {avg(50, 60), avg(96, 116), avg(203, 239), avg(397, 455), avg(628, 708), avg(894, 998), avg(1209, 1349), avg(1595, 1777), avg(2034, 2266), avg(2232, 2486), avg(2818, 3138), avg(4199, 4677), avg(4888, 5444)},
			increase = {63, 81, 112, 139, 155, 159, 156, 135, 116, 115, 70, 52, 0}}
		-- Flash of Light
		local FlashofLight = GetSpellInfo(19750)
		spellData[FlashofLight] = {coeff = 1.5 / 3.5 * 1.25,
			levels = {20, 26, 34, 42, 50, 58, 66, 74, 79},
			averages = {avg(81, 93), avg(124, 144), avg(189, 211), avg(256, 288), avg(346, 390), avg(445, 499), avg(588, 658), avg(682, 764), avg(785, 879)},
			increase = {60, 70, 73, 72, 66, 57, 42, 20, 3}}
		
		-- Talent data
		-- Need to figure out a way of supporting +6% healing from imp devo aura, might not be able to
		-- Healing Light (Add)
		local HealingLight = GetSpellInfo(20237)
		talentData[HealingLight] = {mod = 0.04, current = 0}
		-- Divinity (Add)
		local Divinity = GetSpellInfo(63646)
		talentData[Divinity] = {mod = 0.01, current = 0}
		-- Touched by the Light (Add?)
		local TouchedbytheLight = GetSpellInfo(53592)
		talentData[TouchedbytheLight] = {mod = 0.10, current = 0}
		-- 100% of your heal on someone within range of your beacon heals the beacon target too
		local BeaconofLight = GetSpellInfo(53563)
		-- 100% chance to crit
		local DivineFavor = GetSpellInfo(20216)
		-- Seal of Light + Glyph = 5% healing
		local SealofLight = GetSpellInfo(20165)
		-- Divine Illumination, used in T10 holy
		local DivineIllumination = GetSpellInfo(31842)
		
		local flashLibrams = {[42616] = 436, [42615] = 375, [42614] = 331, [42613] = 293, [42612] = 204, [28592] = 89, [25644] = 79, [23006] = 43, [23201] = 28}
		local holyLibrams = {[45436] = 160, [40268] = 141, [28296] = 47}
		local flashSPLibrams = {[51472] = 510}
		
		-- Holy Shock crits put a hot that heals for 15% of the HS over 9s
		--itemSetsData["T8 Holy"] = { 45370, 45371, 45372, 45373, 45374, 46178, 46179, 46180, 46181, 46182 }
		-- +100% to the hot when using Flash of Light + Sacred Shield
		--itemSetsData["T9 Holy"] = { 48595, 48596, 48597, 48598, 48599, 48564, 48566, 48568, 48572, 48574, 48593, 48591, 48592, 48590, 48594, 48588, 48586, 48587, 48585, 48589, 48576, 48578, 48577, 48579, 48575, 48583, 48581, 48582, 48580, 48584}
		itemSetsData["T10 Holy"] = {50865, 50866, 50867, 50868, 50869, 51270, 51271, 51272, 51273, 51274, 51165, 51166, 51167, 51168, 51169}
				
		-- Need the GUID of whoever has beacon on them so we can make sure they are visible to us and so we can check the mapping
		local activeBeaconGUID, hasDivineFavor
		AuraHandler = function(unit, guid)
			if( unitHasAura(unit, BeaconofLight) ) then
				activeBeaconGUID = guid
			elseif( activeBeaconGUID == guid ) then
				activeBeaconGUID = nil
			end
			
			-- Check Divine Favor
			if( unit == "player" ) then
				hasDivineFavor = unitHasAura("player", DivineFavor)
			end
		end
		
		ResetChargeData = function(guid)
			hasDivineFavor = unitHasAura("player", DivineFavor)
		end
	
		-- Check for beacon when figuring out who to heal
		GetHealTargets = function(bitType, guid, healAmount, spellName, hasVariableTicks)
			if( activeBeaconGUID and activeBeaconGUID ~= guid and guidToUnit[activeBeaconGUID] and UnitIsVisible(guidToUnit[activeBeaconGUID]) ) then
				return string.format("%s,%s", compressGUID[guid], compressGUID[activeBeaconGUID]), healAmount
			elseif( hasVariableTicks ) then
				healAmount = table.concat(healAmount, "@")
			end
			
			return compressGUID[guid], healAmount
		end
	
		-- If only every other class was as easy as Paladins
		CalculateHealing = function(guid, spellName, spellRank)
			local healAmount = averageHeal[spellName][spellRank]
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			local rank = HealComm.rankNumbers[spellRank]
			
			-- Glyph of Seal of Light, +5% healing if the player has Seal of Light up
			if( glyphCache[54943] and unitHasAura("player", SealofLight) ) then
				healModifier = healModifier + 0.05
			end
			
			healModifier = healModifier + talentData[HealingLight].current
			healModifier = healModifier * (1 + talentData[Divinity].current)
			
			-- Apply extra spell power based on libram
			if( playerCurrentRelic ) then
				if( spellName == HolyLight and holyLibrams[playerCurrentRelic] ) then
					healAmount = healAmount + (holyLibrams[playerCurrentRelic] * 0.805)
				elseif( spellName == FlashofLight and flashLibrams[playerCurrentRelic] ) then
					healAmount = healAmount + (flashLibrams[playerCurrentRelic] * 0.805)
				elseif( spellName == FlashofLight and flashSPLibrams[playerCurrentRelic] ) then
					spellPower = spellPower + flashSPLibrams[playerCurrentRelic]
				end
			end
			
			-- +35% healing while Divine Illumination is active
			if( equippedSetCache["T10 Holy"] >= 2 and unitHasAura("player", DivineIllumination) ) then
				healModifier = healModifier * 1.35
			end
			
			-- Normal calculations
			spellPower = spellPower * (spellData[spellName].coeff * 1.88)
			healAmount = calculateGeneralAmount(spellData[spellName].levels[rank], healAmount, spellPower, spModifier, healModifier)
			
			-- Divine Favor, 100% chance to crit
			-- ... or the player has over a 100% chance to crit with Holy spells
			if( hasDivineFavor or GetSpellCritChance(2) >= 100 ) then
				hasDivineFavor = nil
				healAmount = healAmount * (1.50 * (1 + talentData[TouchedbytheLight].current))
			end
			
			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

-- PRIESTS
-- Accurate as of 3.2.2 (build 10392)
if( playerClass == "PRIEST" ) then
	LoadClassData = function()
		-- Hot data
		local Renew = GetSpellInfo(139)
		hotData[Renew] = {coeff = 1, interval = 3, ticks = 5, levels = {8, 14, 20, 26, 32, 38, 44, 50, 56, 60, 65, 70, 75, 80}, averages = {45, 100, 175, 245, 315, 400, 510, 650, 810, 970, 1010, 1110, 1235, 1400}}
		--local GlyphofPoH = GetSpellInfo(56161)
		--hotData[GlyphofPoH] = {isMulti = true, interval = 3}
		
		-- Spell data
		-- Greater Heal
		local GreaterHeal = GetSpellInfo(2060)
		spellData[GreaterHeal] = {coeff = 3 / 3.5, levels = {40, 46, 52, 58, 60, 63, 68, 73, 78}, increase = {204, 197, 184, 165, 162, 142, 111, 92, 30},
			averages = {avg(899, 1013), avg(1149, 1289), avg(1437, 1609), avg(1798, 2006), avg(1966, 2194), avg(2074, 2410), avg(2394, 2784), avg(3395, 3945), avg(3950, 4590)}}
		-- Prayer of Healing
		local PrayerofHealing = GetSpellInfo(596)
		spellData[PrayerofHealing] = {coeff = 0.2798, levels = {30, 40, 50, 60, 60, 68, 76}, increase = {65, 64, 60, 48, 50, 33, 18},
			averages = {avg(301, 321), avg(444, 472), avg(657, 695), avg(939, 991), avg(997, 1053), avg(1246, 1316), avg(2091, 2209)}}
		-- Flash Heal
		local FlashHeal = GetSpellInfo(2061)
		spellData[FlashHeal] = {coeff = 1.5 / 3.5, levels = {20, 26, 32, 38, 44, 52, 58, 61, 67, 73, 79}, increase = {114, 118, 120, 117, 118, 111, 100, 89, 67, 56, 9},
			averages = {avg(193, 237), avg(258, 314), avg(327, 393), avg(400, 478), avg(518, 616), avg(644, 764), avg(812, 958), avg(913, 1059), avg(1101, 1279), avg(1578, 1832), avg(1887, 2198)}}
		-- Binding Heal
		local BindingHeal = GetSpellInfo(32546)
		spellData[BindingHeal] = {coeff = 1.5 / 3.5, levels = {64, 72, 78}, averages = {avg(1042, 1338), avg(1619, 2081), avg(1952, 2508)}, increase = {30, 24, 7}}
		-- Penance
		local Penance = GetSpellInfo(53007)
		spellData[Penance] = {coeff = 0.857, ticks = 3, levels = {60, 70, 75, 80}, averages = {avg(670, 756), avg(805, 909), avg(1278, 1442), avg(1484, 1676)}}
		-- Heal
		local Heal = GetSpellInfo(2054)
		spellData[Heal] = {coeff = 3 / 3.5, levels = {16, 22, 28, 34}, averages = {avg(295, 341), avg(429, 491), avg(566, 642), avg(712, 804)}, increase = {153, 185, 208, 207}}
		-- Lesser Heal
		local LesserHeal = GetSpellInfo(2050)
		spellData[LesserHeal] = {levels = {1, 4, 10}, averages = {avg(46, 56), avg(71, 85), avg(135, 157)}, increase = {71, 83, 112}}
					
		-- Talent data
		local Grace = GetSpellInfo(47517)
		-- Spiritual Healing (Add)
		local SpiritualHealing = GetSpellInfo(14898)
		talentData[SpiritualHealing] = {mod = 0.02, current = 0}
		-- Empowered Healing (Add, also 0.04 for FH/BH)
		local EmpoweredHealing = GetSpellInfo(33158)
		talentData[EmpoweredHealing] = {mod = 0.08, current = 0}
		-- Blessed Resilience (Add)
		local BlessedResilience = GetSpellInfo(33142)
		talentData[BlessedResilience] = {mod = 0.01, current = 0}
		-- Focused Power (Add)
		local FocusedPower = GetSpellInfo(33190)
		talentData[FocusedPower] = {mod = 0.02, current = 0}
		-- Divine Providence (Add)
		local DivineProvidence = GetSpellInfo(47567)
		talentData[DivineProvidence] = {mod = 0.02, current = 0}
		-- Improved Renew (Add)
		local ImprovedRenew = GetSpellInfo(14908)
		talentData[ImprovedRenew] = {mod = 0.05, current = 0}
		-- Empowered Renew (Multi, spell power)
		local EmpoweredRenew = GetSpellInfo(63534)
		talentData[EmpoweredRenew] = {mod = 0.05, current = 0}
		-- Twin Disciplines (Add)
		local TwinDisciplines = GetSpellInfo(47586)
		talentData[TwinDisciplines] = {mod = 0.01, current = 0}
		
		-- Keep track of who has grace on them
		local activeGraceGUID, activeGraceModifier
		AuraHandler = function(unit, guid)
			local stack, _, _, _, caster = select(4, UnitBuff(unit, Grace))
			if( caster == "player" ) then
				activeGraceModifier = stack * 0.03
				activeGraceGUID = guid
			elseif( activeGraceGUID == guid ) then
				activeGraceGUID = nil
			end
		end
		
		-- Check for beacon when figuring out who to heal
		GetHealTargets = function(bitType, guid, healAmount, spellName, hasVariableTicks)
			if( spellName == BindingHeal ) then
				return string.format("%s,%s", compressGUID[guid], compressGUID[playerGUID]), healAmount
			elseif( spellName == PrayerofHealing ) then
				local targets = compressGUID[guid]
				local group = guidToGroup[guid]
				
				for groupGUID, id in pairs(guidToGroup) do
					local unit = guidToUnit[groupGUID]
					if( id == group and guid ~= groupGUID and UnitIsVisible(unit) and not UnitHasVehicleUI(unit) ) then
						targets = targets .. "," .. compressGUID[groupGUID]
					end
				end
				
				return targets, healAmount
			elseif( hasVariableTicks ) then
				healAmount = table.concat(healAmount, "@")
			end
			
			return compressGUID[guid], healAmount
		end
		
		CalculateHotHealing = function(guid, spellID)
			local spellName, spellRank = GetSpellInfo(spellID)
			local rank = HealComm.rankNumbers[spellRank]
			local healAmount = hotData[spellName].averages[rank]
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			local totalTicks
	
			-- Add grace if it's active on them
			if( activeGraceGUID == guid and activeGraceModifier ) then
				healModifier = healModifier + activeGraceModifier
			end
			
			healModifier = healModifier + talentData[FocusedPower].current
			healModifier = healModifier + talentData[BlessedResilience].current
			healModifier = healModifier + talentData[SpiritualHealing].current
			
			if( spellName == Renew ) then
				healModifier = healModifier + talentData[ImprovedRenew].current
				healModifier = healModifier + talentData[TwinDisciplines].current
				
				-- Glyph of Renew, one less tick for +25% healing per tick. As this heals the same just faster, it has to be a flat 25% modifier
				if( glyphCache[55674] ) then
					healModifier = healModifier + 0.25
					totalTicks = 4
				else
					totalTicks = 5
				end
				
				spellPower = spellPower * ((hotData[spellName].coeff * 1.88) * (1 + (talentData[EmpoweredRenew].current)))
				spellPower = spellPower / hotData[spellName].ticks
				healAmount = healAmount / hotData[spellName].ticks
				
			end
	
			healAmount = calculateGeneralAmount(hotData[spellName].levels[rank], healAmount, spellPower, spModifier, healModifier)
			return HOT_HEALS, math.ceil(healAmount), totalTicks, hotData[spellName].interval
		end
	
		-- If only every other class was as easy as Paladins
		CalculateHealing = function(guid, spellName, spellRank)
			local healAmount = averageHeal[spellName][spellRank]
			local rank = HealComm.rankNumbers[spellRank]
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			
			-- Add grace if it's active on them
			if( activeGraceGUID == guid ) then
				healModifier = healModifier + activeGraceModifier
			end
			
			healModifier = healModifier + talentData[FocusedPower].current
			healModifier = healModifier + talentData[BlessedResilience].current
			healModifier = healModifier + talentData[SpiritualHealing].current
			
			-- Greater Heal
			if( spellName == GreaterHeal ) then
				spellPower = spellPower * ((spellData[spellName].coeff * 1.88) * (1 + talentData[EmpoweredHealing].current))
			-- Flash Heal
			elseif( spellName == FlashHeal ) then
				spellPower = spellPower * ((spellData[spellName].coeff * 1.88) * (1 + talentData[EmpoweredHealing].spent * 0.04))
			-- Binding Heal
			elseif( spellName == BindingHeal ) then
				healModifier = healModifier + talentData[DivineProvidence].current
				spellPower = spellPower * ((spellData[spellName].coeff * 1.88) * (1 + talentData[EmpoweredHealing].spent * 0.04))
			-- Penance
			elseif( spellName == Penance ) then
				spellPower = spellPower * (spellData[spellName].coeff * 1.88)
				spellPower = spellPower / spellData[spellName].ticks
			-- Prayer of Heaing
			elseif( spellName == PrayerofHealing ) then
				healModifier = healModifier + talentData[DivineProvidence].current
				spellPower = spellPower * (spellData[spellName].coeff * 1.88)
			-- Heal
			elseif( spellName == Heal ) then
				spellPower = spellPower * (spellData[spellName].coeff * 1.88)
			-- Lesser Heal
			elseif( spellName == LesserHeal ) then
				local castTime = rank > 3 and 2.5 or rank == 2 and 2 or 1.5
				spellPower = spellPower * ((castTime / 3.5) * 1.88)
			end
			
			healAmount = calculateGeneralAmount(spellData[spellName].levels[rank], healAmount, spellPower, spModifier, healModifier)
	
			-- Player has over a 100% chance to crit with Holy spells
			if( GetSpellCritChance(2) >= 100 ) then
				healAmount = healAmount * 1.50
			end
					
			-- Penance ticks 3 times, the player will see all 3 ticks, everyone else should only see the last 2
			if( spellName == Penance ) then
				return CHANNEL_HEALS, math.ceil(healAmount), 2, 3
			end
					
			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

-- SHAMANS
-- All spells accurate as of 3.2.2 (build 10392)
if( playerClass == "SHAMAN" ) then
	LoadClassData = function()
		-- Hot data
		-- Riptide
		local Riptide = GetSpellInfo(61295)
		hotData[Riptide] = {interval = 3, ticks = 5, coeff = 0.50, levels = {60, 70, 75, 80}, averages = {665, 885, 1435, 1670}}
		-- Earthliving Weapon proc
		local Earthliving = GetSpellInfo(52000)
		hotData[Earthliving] = {interval = 3, ticks = 4, coeff = 0.80, levels = {30, 40, 50, 60, 70, 80}, averages = {116, 160, 220, 348, 456, 652}}
		
		-- Spell data
		-- Chain Heal
		local ChainHeal = GetSpellInfo(1064)
		spellData[ChainHeal] = {coeff = 2.5 / 3.5, levels = {40, 46, 54, 61, 68, 74, 80}, increase = {100, 95, 85, 72, 45, 22, 0},
			averages = {avg(320, 368), avg(405, 465), avg(551, 629), avg(605, 691), avg(826, 942), avg(906, 1034), avg(1055, 1205)}}
		-- Healing Wave
		local HealingWave = GetSpellInfo(331)
		spellData[HealingWave] = {levels = {1, 6, 12, 18, 24, 32, 40, 48, 56, 60, 63, 70, 75, 80},
			averages = {avg(34, 44), avg(64, 78), avg(129, 155), avg(268, 316), avg(376, 440), avg(536, 622), avg(740, 854), avg(1017, 1167), avg(1367, 1561), avg(1620, 1850), avg(1725, 1969), avg(2134, 2438), avg(2624, 2996), avg(3034, 3466)},
			increase = {55, 74, 102, 142, 151, 158, 156, 150, 132, 110, 107, 71, 40, 0}}
		-- Lesser Healing Wave
		local LesserHealingWave = GetSpellInfo(8004)
		spellData[LesserHealingWave] = {coeff = 1.5 / 3.5, levels = {20, 28, 36, 44, 52, 60, 66, 72, 77}, increase = {102, 109, 110, 108, 100, 84, 58, 40, 18},
			averages = {avg(162, 186), avg(247, 281), avg(337, 381), avg(458, 514), avg(631, 705), avg(832, 928), avg(1039, 1185), avg(1382, 1578), avg(1606, 1834)}}
		
		-- Talent data
		local EarthShield = GetSpellInfo(49284)
		-- Improved Chain Heal (Multi)
		local ImpChainHeal = GetSpellInfo(30872)
		talentData[ImpChainHeal] = {mod = 0.10, current = 0}
		-- Tidal Waves (Add, this is a buff)
		local TidalWaves = GetSpellInfo(51566)
		talentData[TidalWaves] = {mod = 0.04, current = 0}
		-- Healing Way (Multi, this goes from 8 -> 16 -> 25 so have to manually do the conversion)
		local HealingWay = GetSpellInfo(29206)
		talentData[HealingWay] = {mod = 0, current = 0}
		-- Purification (Add)
		local Purification = GetSpellInfo(16178)
		talentData[Purification] = {mod = 0.02, current = 0}
		
		-- Set bonuses
		-- T7 Resto 4 piece, +5% healing on Chain Heal and Healing Wave
		itemSetsData["T7 Resto"] = {40508, 40509, 40510, 40512, 40513, 39583, 39588, 39589, 39590, 39591}
		-- T9 Resto 2 piece, +20% healing to Riptide
		itemSetsData["T9 Resto"] = {48280, 48281, 48282, 48283, 48284, 48295, 48296, 48297, 48298, 48299, 48301, 48302, 48303, 48304, 48300, 48306, 48307, 48308, 48309, 48305, 48286, 48287, 48288, 48289, 48285, 48293, 48292, 48291, 48290, 48294}
		
		-- Totems
		local lhwTotems = {[42598] = 320, [42597] = 267, [42596] = 236, [42595] = 204, [25645] = 79, [22396] = 80, [23200] = 53}	
		local chTotems = {[45114] = 243, [38368] = 102, [28523] = 87}
		
		-- Keep track of who has riptide on them
		local riptideData, earthshieldList = {}, {}
		AuraHandler = function(unit, guid)
			riptideData[guid] = unitHasAura(unit, Riptide) and true or nil
			
			-- Currently, Glyph of Lesser Healing Wave + Any Earth Shield increase the healing not just the players own
			if( UnitBuff(unit, EarthShield) ) then
				earthshieldList[guid] = true
			elseif( earthshieldList[guid] ) then
				earthshieldList[guid] = nil
			end
		end
		
		-- Cast was interrupted, recheck if we still have the auras up
		ResetChargeData = function(guid)
			riptideData[guid] = guidToUnit[guid] and unitHasAura(guidToUnit[guid], Riptide) and true or nil
		end
		
		-- Lets a specific override on how many people this will hit
		GetHealTargets = function(bitType, guid, healAmount, spellName, hasVariableTicks)
			-- Glyph of Healing Wave, heals you for 20% of your heal when you heal someone else
			if( glyphCache[55440] and guid ~= playerGUID and spellName == HealingWave ) then
				return string.format("%s,%d,%s,%d", compressGUID[guid], healAmount, compressGUID[playerGUID], healAmount *  0.20), -1
			elseif( hasVariableTicks ) then
				healAmount = table.concat(healAmount, "@")
			end
		
			return compressGUID[guid], healAmount
		end
		
		CalculateHotHealing = function(guid, spellID)
			local spellName, spellRank = GetSpellInfo(spellID)
			local rank = HealComm.rankNumbers[spellRank]
			local healAmount = hotData[spellName].averages[rank]
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			local totalTicks
	
			healModifier = healModifier + talentData[Purification].current
			
			-- Riptide
			if( spellName == Riptide ) then
				if( equippedSetCache["T9 Resto"] >= 2 ) then
					spModifier = spModifier * 1.20
				end
				
				spellPower = spellPower * (hotData[spellName].coeff * 1.88)
				spellPower = spellPower / hotData[spellName].ticks
				healAmount = healAmount / hotData[spellName].ticks
				
				totalTicks = hotData[spellName].ticks
				-- Glyph of Riptide, +6 seconds
				if( glyphCache[63273] ) then totalTicks = totalTicks + 2 end
				
			-- Earthliving Weapon
			elseif( spellName == Earthliving ) then
				spellPower = (spellPower * (hotData[spellName].coeff * 1.88) * 0.45)
				spellPower = spellPower / hotData[spellName].ticks
				healAmount = healAmount / hotData[spellName].ticks
				
				totalTicks = hotData[spellName].ticks
			end
			
			healAmount = calculateGeneralAmount(hotData[spellName].levels[rank], healAmount, spellPower, spModifier, healModifier)
			return HOT_HEALS, healAmount, totalTicks, hotData[spellName].interval
		end
	
		
		-- If only every other class was as easy as Paladins
		CalculateHealing = function(guid, spellName, spellRank)
			local healAmount = averageHeal[spellName][spellRank]
			local rank = HealComm.rankNumbers[spellRank]
			local spellPower = GetSpellBonusHealing()
			local healModifier, spModifier = playerHealModifier, 1
			
			healModifier = healModifier + talentData[Purification].current
			
			-- Chain Heal
			if( spellName == ChainHeal ) then
				healModifier = healModifier * (1 + talentData[ImpChainHeal].current)
				healAmount = healAmount + (playerCurrentRelic and chTotems[playerCurrentRelic] or 0)			
	
				if( equippedSetCache["T7 Resto"] >= 4 ) then
					healModifier = healModifier * 1.05
				end
	
				-- Add +25% from Riptide being up and reset the flag
				if( riptideData[guid] ) then
					healModifier = healModifier * 1.25
					riptideData[guid] = nil
				end
				
				spellPower = spellPower * (spellData[spellName].coeff * 1.88)
			-- Heaing Wave
			elseif( spellName == HealingWave ) then
				healModifier = healModifier * (talentData[HealingWay].spent == 3 and 1.25 or talentData[HealingWay].spent == 2 and 1.16 or talentData[HealingWay].spent == 1 and 1.08 or 1)
				
				if( equippedSetCache["T7 Resto"] >= 4 ) then
					healModifier = healModifier * 1.05
				end
							
				-- Totem of Spontaneous Regrowth, +88 Spell Power to Healing Wave
				if( playerCurrentRelic == 27544 ) then
					spellPower = spellPower + 88
				end
				
				local castTime = rank > 3 and 3 or rank == 3 and 2.5 or rank == 2 and 2 or 1.5
				spellPower = spellPower * (((castTime / 3.5) * 1.88) + talentData[TidalWaves].current)
							
			-- Lesser Healing Wave
			elseif( spellName == LesserHealingWave ) then
				-- Glyph of Lesser Healing Wave, +20% healing on LHW if target has ES up
				if( glyphCache[55438] and earthshieldList[guid] ) then
					healModifier = healModifier * 1.20
				end
				
				spellPower = spellPower + (playerCurrentRelic and lhwTotems[playerCurrentRelic] or 0)
				spellPower = spellPower * ((spellData[spellName].coeff * 1.88) + talentData[TidalWaves].spent * 0.02)
			end
			
			healAmount = calculateGeneralAmount(spellData[spellName].levels[rank], healAmount, spellPower, spModifier, healModifier)
	
			-- Player has over a 100% chance to crit with Nature spells
			if( GetSpellCritChance(4) >= 100 ) then
				healAmount = healAmount * 1.50
			end
			
			-- Apply the final modifier of any MS or self heal increasing effects
			return DIRECT_HEALS, math.ceil(healAmount)
		end
	end
end

local function getName(spellID)
	local name = GetSpellInfo(spellID)
	--[===[@debug@
	if( not name ) then
		print(string.format("%s-r%s: Failed to find spellID %d", major, minor, spellID))
	end
	--@end-debug@]===]
	return name or ""
end

-- Healing modifiers
if( not HealComm.aurasUpdated ) then
	HealComm.aurasUpdated = true
	HealComm.selfModifiers = nil
	HealComm.healingModifiers = nil
end

HealComm.currentModifiers = HealComm.currentModifiers or {}

HealComm.selfModifiers = HealComm.selfModifiers or {
	[64850] = 0.50, -- Unrelenting Assault
	[65925] = 0.50, -- Unrelenting Assault
	[54428] = 0.50, -- Divine Plea
	[32346] = 0.50, -- Stolen Soul
	[64849] = 0.75, -- Unrelenting Assault
	[72221] = 1.05, -- Luck of the Draw
	[70873] = 1.10, -- Emerald Vigor (Valithria Dreamwalker)
	[31884] = 1.20, -- Avenging Wrath
	[72393] = 0.25, -- Hopelessness
	[72397] = 0.40, -- Hopelessness
	[72391] = 0.50, -- Hopelessness
	[72396] = 0.60, -- Hopelessness
	[72390] = 0.75, -- Hopelessness
	[72395] = 0.80, -- Hopelessness
}

-- The only spell in the game with a name conflict is Ray of Pain from the Nagrand Void Walkers
HealComm.healingModifiers = HealComm.healingModifiers or {
	[getName(30843)] = 0.00, -- Enfeeble
	[getName(41292)] = 0.00, -- Aura of Suffering
	[59513] = 0.00, -- Embrace of the Vampyr
	[getName(55593)] = 0.00, -- Necrotic Aura
	[28776] = 0.10, -- Necrotic Poison
	[getName(34625)] = 0.25, -- Demolish
	[getName(19716)] = 0.25, -- Gehennas' Curse
	[getName(24674)] = 0.25, -- Veil of Shadow
	[69633] = 0.25, -- Veil of Shadow, in German this is translated differently from the one above
	[46296] = 0.25, -- Necrotic Poison
	[54121] = 0.25, -- Necrotic Poison
	-- Wound Poison still uses a unique spellID/spellName despite the fact that it's a static 50% reduction.
	[getName(13218)] = 0.50, -- 1
	[getName(13222)] = 0.50, -- 2
	[getName(13223)] = 0.50, -- 3
	[getName(13224)] = 0.50, -- 4
	[getName(27189)] = 0.50, -- 5
	[getName(57974)] = 0.50, -- 6
	[getName(57975)] = 0.50, -- 7
	[getName(20900)] = 0.50, -- Aimed Shot
	[getName(44534)] = 0.50, -- Wretched Strike
	[getName(21551)] = 0.50, -- Mortal Strike
	[getName(40599)] = 0.50, -- Arcing Smash
	[getName(36917)] = 0.50, -- Magma-Throwser's Curse
	[getName(23169)] = 0.50, -- Brood Affliction: Green
	[getName(22859)] = 0.50, -- Mortal Cleave
	[getName(36023)] = 0.50, -- Deathblow
	[getName(13583)] = 0.50, -- Curse of the Deadwood
	[getName(32378)] = 0.50, -- Filet
	[getName(35189)] = 0.50, -- Solar Strike
	[getName(32315)] = 0.50, -- Soul Strike
	[getName(60084)] = 0.50, -- The Veil of Shadow
	[getName(45885)] = 0.50, -- Shadow Spike
	[getName(69674)] = 0.50, -- Mutated Infection (Rotface)
	[36693] = 0.55, -- Necrotic Poison
	[getName(63038)] = 0.75, -- Dark Volley
	[getName(52771)] = 0.75, -- Wounding Strike
	[getName(48291)] = 0.75, -- Fetid Healing
	[getName(34366)] = 0.75, -- Ebon Poison
	[getName(54525)] = 0.80, -- Shroud of Darkness (This might be wrong)
	[getName(48301)] = 0.80, -- Mind Trauma (Improved Mind Blast)
	[getName(68391)] = 0.80, -- Permafrost, the debuff is generic no way of seeing 7/13/20, go with 20
	[getName(52645)] = 0.80, -- Hex of Weakness
	[getName(34073)] = 0.85, -- Curse of the Bleeding Hollow
	[getName(43410)] = 0.90, -- Chop
	[getName(70588)] = 0.90, -- Suppression (Valithria Dreamwalker NPCs?)
	[getName(34123)] = 1.06, -- Tree of Life
	[getName(64844)] = 1.10, -- Divine Hymn
	[getName(47788)] = 1.40, -- Guardian Spirit
	[getName(38387)] = 1.50, -- Bane of Infinity
	[getName(31977)] = 1.50, -- Curse of Infinity
	[getName(41350)] = 2.00, -- Aura of Desire
	[73762] = 1.05, -- Strength of Wrynn (5%)
	[73816] = 1.05, -- Hellscream's Warsong (5%)
	[73824] = 1.10, -- Strength of Wrynn (10%)
	[73818] = 1.10, -- Hellscream's Warsong (10%)
	[73825] = 1.15, -- Strength of Wrynn (15%)
	[73819] = 1.15, -- Hellscream's Warsong (15%)
	[73826] = 1.20, -- Strength of Wrynn (20%)
	[73820] = 1.20, -- Hellscream's Warsong (20%)
	[73827] = 1.25, -- Strength of Wrynn (25%)
	[73821] = 1.25, -- Hellscream's Warsong (25%)
	[73828] = 1.30, -- Strength of Wrynn (30%)
	[73822] = 1.30, -- Hellscream's Warsong (30%)
}

HealComm.healingStackMods = HealComm.healingStackMods or {
	-- Enervating Band
	[getName(74502)] = function(name, rank, icon, stacks) return 1 - stacks * 0.02 end,
	-- Tenacity
	[getName(58549)] = function(name, rank, icon, stacks) return icon == "Interface\\Icons\\Ability_Warrior_StrengthOfArms" and stacks ^ 1.18 or 1 end,
	-- Focused Will
	[getName(45242)] = function(name, rank, icon, stacks) return 1 + (stacks * (0.02 + rankNumbers[rank] / 100)) end,
	-- Nether Portal - Dominance
	[getName(30423)] = function(name, rank, icon, stacks) return 1 + stacks * 0.01 end,
	-- Dark Touched
	[getName(45347)] = function(name, rank, icon, stacks) return 1 - stacks * 0.04 end, 
	-- Necrotic Strike
	[getName(60626)] = function(name, rank, icon, stacks) return 1 - stacks * 0.10 end, 
	-- Mortal Wound
	[getName(28467)] = function(name, rank, icon, stacks) return 1 - stacks * 0.10 end, 
	-- Furious Strikes
	[getName(56112)] = function(name, rank, icon, stacks) return 1 - stacks * 0.25 end,
}

local healingStackMods, selfModifiers = HealComm.healingStackMods, HealComm.selfModifiers
local healingModifiers, currentModifiers = HealComm.healingModifiers, HealComm.currentModifiers

local distribution
local CTL = ChatThrottleLib
local function sendMessage(msg)
	if( distribution and string.len(msg) <= 240 ) then
		CTL:SendAddonMessage("BULK", COMM_PREFIX, msg, distribution)
	end
end

-- Keep track of where all the data should be going
local instanceType
local function updateDistributionChannel()
	local lastChannel = distribution
	if( instanceType == "pvp" or instanceType == "arena" ) then
		distribution = "BATTLEGROUND"
	elseif( GetNumRaidMembers() > 0 ) then
		distribution = "RAID"
	elseif( GetNumPartyMembers() > 0 ) then
		distribution = "PARTY"
	else
		distribution = nil
	end

	if( distribution == lastChannel ) then return end
	
	-- If the player is not a healer, some events can be disabled until the players grouped.
	if( distribution ) then
		HealComm.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
		if( not isHealerClass ) then
			HealComm.eventFrame:RegisterEvent("UNIT_AURA")
			HealComm.eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
			HealComm.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			HealComm.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	else
		HealComm.eventFrame:UnregisterEvent("CHAT_MSG_ADDON")
		if( not isHealerClass ) then
			HealComm.eventFrame:UnregisterEvent("UNIT_AURA")
			HealComm.eventFrame:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
			HealComm.eventFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			HealComm.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

-- Figure out where we should be sending messages and wipe some caches
function HealComm:PLAYER_ENTERING_WORLD()
	HealComm.eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	HealComm:ZONE_CHANGED_NEW_AREA()
end

function HealComm:ZONE_CHANGED_NEW_AREA()
	local pvpType = GetZonePVPInfo()
	local type = select(2, IsInInstance())
	
	HealComm.zoneHealModifier = 1
	if( pvpType == "combat" or type == "arena" or type == "pvp" ) then
		HealComm.zoneHealModifier = 0.90
	end
	
	if( type ~= instanceType ) then
		instanceType = type
		
		updateDistributionChannel()
		clearPendingHeals()
		table.wipe(activeHots)
	end

	instanceType = type
end

local alreadyAdded = {}
function HealComm:UNIT_AURA(unit)
	local guid = UnitGUID(unit)
	if( not guidToUnit[guid] ) then return end
	local increase, decrease, playerIncrease, playerDecrease = 1, 1, 1, 1
		
	-- Scan buffs
	local id = 1
	while( true ) do
		local name, rank, icon, stack, _, _, _, _, _, _, spellID = UnitAura(unit, id, "HELPFUL")
		if( not name ) then break end
		-- Prevent buffs like Tree of Life that have the same name for the shapeshift/healing increase from being calculated twice
		if( not alreadyAdded[name] ) then
			alreadyAdded[name] = true

			if( healingModifiers[spellID] ) then
				increase = increase * healingModifiers[spellID]
			elseif( healingModifiers[name] ) then
				increase = increase * healingModifiers[name]
			elseif( healingStackMods[name] ) then
				increase = increase * healingStackMods[name](name, rank, icon, stack)
			end
			
			if( unit == "player" and selfModifiers[spellID] ) then
				playerIncrease = playerIncrease * selfModifiers[spellID]
			end
		end
		
		id = id + 1
	end

	-- Scan debuffs
	id = 1
	while( true ) do
		local name, rank, icon, stack, _, _, _, _, _, _, spellID = UnitAura(unit, id, "HARMFUL")
		if( not name ) then break end
		
		if( healingModifiers[spellID] ) then
			decrease = math.min(decrease, healingModifiers[spellID])
		elseif( healingModifiers[name] ) then
			decrease = math.min(decrease, healingModifiers[name])
		elseif( healingStackMods[name] ) then
			decrease = math.min(decrease, healingStackMods[name](name, rank, icon, stack))
		end

		if( unit == "player" and selfModifiers[spellID] ) then
			playerDecrease = math.min(playerDecrease, selfModifiers[spellID])
		end
		
		id = id + 1
	end
	
	-- Check if modifier changed
	local modifier = increase * decrease
	if( modifier ~= currentModifiers[guid] ) then
		if( currentModifiers[guid] or modifier ~= 1 ) then
			currentModifiers[guid] = modifier
			self.callbacks:Fire("HealComm_ModifierChanged", guid, modifier)
		else
			currentModifiers[guid] = modifier
		end
	end

	table.wipe(alreadyAdded)
	
	if( unit == "player" ) then
		playerHealModifier = playerIncrease * playerDecrease
	end
	
	-- Class has a specific monitor it needs for auras
	if( AuraHandler ) then
		AuraHandler(unit, guid)
	end
end

-- Monitor glyph changes
function HealComm:GlyphsUpdated(id)
	local spellID = glyphCache[id]
	
	-- Invalidate the old cache value
	if( spellID ) then
		glyphCache[spellID] = nil
		glyphCache[id] = nil
	end
	
	-- Cache the new one if any
	local enabled, _, glyphID = GetGlyphSocketInfo(id)
	if( enabled and glyphID ) then
		glyphCache[glyphID] = true
		glyphCache[id] = glyphID
	end
end

HealComm.GLYPH_ADDED = HealComm.GlyphsUpdated
HealComm.GLYPH_REMOVED = HealComm.GlyphsUpdated
HealComm.GLYPH_UPDATED = HealComm.GlyphsUpdated

-- Invalidate he average cache to recalculate for spells that increase in power due to leveling up (but not training new ranks)
function HealComm:PLAYER_LEVEL_UP(level)
	for spell, average in pairs(averageHeal) do
		table.wipe(average)
		
		average.spell = spell
	end
	
	-- WoWProgramming says this is a string, why this is a string I do not know.
	playerLevel = tonumber(level) or UnitLevel("player")
end

-- Cache player talent data for spells we need
function HealComm:PLAYER_TALENT_UPDATE()
	for tabIndex=1, GetNumTalentTabs() do
		for i=1, GetNumTalents(tabIndex) do
			local name, _, _, _, spent = GetTalentInfo(tabIndex, i)
			if( name and talentData[name] ) then
				talentData[name].current = talentData[name].mod * spent
				talentData[name].spent = spent
			end
		end
	end
end

-- Save the currently equipped range weapon
local RANGED_SLOT = GetInventorySlotInfo("RangedSlot")
function HealComm:PLAYER_EQUIPMENT_CHANGED()
	-- Caches set bonus info, as you can't reequip set bonus gear in combat no sense in checking it
	if( not InCombatLockdown() ) then
		for name, items in pairs(itemSetsData) do
			equippedSetCache[name] = 0
			for _, itemID in pairs(items) do
				if( IsEquippedItem(itemID) ) then
					equippedSetCache[name] = equippedSetCache[name] + 1
				end
			end
		end
	end
	
	-- Check relic
	local relic = GetInventoryItemLink("player", RANGED_SLOT)
	playerCurrentRelic = relic and tonumber(string.match(relic, "item:(%d+):")) or nil
end

-- COMM CODE
local function loadHealAmount(...)
	local tbl = HealComm:RetrieveTable()
	for i=1, select("#", ...) do
		tbl[i] = tonumber((select(i, ...)))
	end
	
	return tbl
end

-- Direct heal started
local function loadHealList(pending, amount, stack, endTime, ticksLeft, ...)
	table.wipe(tempPlayerList)
	
	-- For the sake of consistency, even a heal doesn't have multiple end times like a hot, it'll be treated as such in the DB
	if( amount ~= -1 and amount ~= "-1" ) then
		amount = not pending.hasVariableTicks and amount or loadHealAmount(string.split("@", amount))
		
		for i=1, select("#", ...) do
			local guid = select(i, ...)
			if( guid ) then
				updateRecord(pending, decompressGUID[guid], amount, stack, endTime, ticksLeft)
				table.insert(tempPlayerList, decompressGUID[guid])
			end
		end
	else
		for i=1, select("#", ...), 2 do
			local guid = select(i, ...)
			local amount = not pending.hasVariableTicks and tonumber((select(i + 1, ...))) or loadHealAmount(string.split("@", amount))
			if( guid and amount ) then
				updateRecord(pending, decompressGUID[guid], amount, stack, endTime, ticksLeft)
				table.insert(tempPlayerList, decompressGUID[guid])
			end
		end
	end
end

local function parseDirectHeal(casterGUID, spellID, amount, ...)
	local spellName = GetSpellInfo(spellID)
	local unit = guidToUnit[casterGUID]
	if( not unit or not spellName or not amount or select("#", ...) == 0 ) then return end

	local endTime = select(6, UnitCastingInfo(unit))
	if( not endTime ) then return end

	pendingHeals[casterGUID] = pendingHeals[casterGUID] or {}
	pendingHeals[casterGUID][spellName] = pendingHeals[casterGUID][spellName] or {}
	
	local pending = pendingHeals[casterGUID][spellName]
	table.wipe(pending)
	pending.endTime = endTime / 1000
	pending.spellID = spellID
	pending.bitType = DIRECT_HEALS

	loadHealList(pending, amount, 1, 0, nil, ...)

	HealComm.callbacks:Fire("HealComm_HealStarted", casterGUID, spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
end

HealComm.parseDirectHeal = parseDirectHeal

-- Channeled heal started
local function parseChannelHeal(casterGUID, spellID, amount, totalTicks, ...)
	local spellName = GetSpellInfo(spellID)
	local unit = guidToUnit[casterGUID]
	if( not unit or not spellName or not totalTicks or not amount or select("#", ...) == 0 ) then return end

	local startTime, endTime = select(5, UnitChannelInfo(unit))
	if( not startTime or not endTime ) then return end

	pendingHeals[casterGUID] = pendingHeals[casterGUID] or {}
	pendingHeals[casterGUID][spellName] = pendingHeals[casterGUID][spellname] or {}

	local inc = amount == -1 and 2 or 1
	local pending = pendingHeals[casterGUID][spellName]
	table.wipe(pending)
	pending.startTime = startTime / 1000
	pending.endTime = endTime / 1000
	pending.duration = math.max(pending.duration or 0, pending.endTime - pending.startTime)
	pending.totalTicks = totalTicks
	pending.tickInterval = (pending.endTime - pending.startTime) / totalTicks
	pending.spellID = spellID
	pending.isMultiTarget = (select("#", ...) / inc) > 1
	pending.bitType = CHANNEL_HEALS
		
	loadHealList(pending, amount, 1, 0, math.ceil(pending.duration / pending.tickInterval), ...)
	
	HealComm.callbacks:Fire("HealComm_HealStarted", casterGUID, spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
end

-- Hot heal started
-- When the person is within visible range of us, the aura is available by the time the message reaches the target
-- as such, we can rely that at least one person is going to have the aura data on them (and that it won't be different, at least for this cast)
local function findAura(casterGUID, spellName, spellRank, inc, ...)
	for i=1, select("#", ...), inc do
		local guid = decompressGUID[select(i, ...)]
		local unit = guid and guidToUnit[guid]
		if( unit and UnitIsVisible(unit) ) then
			local id = 1
			while( true ) do
				local name, rank, _, stack, _, duration, endTime, caster = UnitBuff(unit, id)
				if( not name ) then break end
				
				if( name == spellName and spellRank == rank and caster and UnitGUID(caster) == casterGUID ) then
					return (stack and stack > 0 and stack or 1), duration, endTime
				end

				id = id + 1
			end
		end
	end
end

local function parseHotHeal(casterGUID, wasUpdated, spellID, tickAmount, totalTicks, tickInterval, ...)
	local spellName, spellRank = GetSpellInfo(spellID)
	-- If the user is on 3.3, then anything without a total ticks attached to it is rejected
	if( ( IS_BUILD30300 and not totalTicks ) or not tickAmount or not spellName or select("#", ...) == 0 ) then return end
	
	-- Retrieve the hot information
	local inc = ( tickAmount == -1 or tickAmount == "-1" ) and 2 or 1
	local stack, duration, endTime = findAura(casterGUID, spellName, spellRank, inc, ...)
	if( not stack or not duration or not endTime ) then return end

	pendingHeals[casterGUID] = pendingHeals[casterGUID] or {}
	pendingHeals[casterGUID][spellID] = pendingHeals[casterGUID][spellID] or {}
	
	local pending = pendingHeals[casterGUID][spellID]
	pending.duration = duration
	pending.endTime = endTime
	pending.stack = stack
	pending.totalTicks = totalTicks or duration / tickInterval
	pending.tickInterval = totalTicks and duration / totalTicks or tickInterval
	pending.spellID = spellID
	pending.hasVariableTicks = type(tickAmount) == "string"
	pending.isMutliTarget = (select("#", ...) / inc) > 1
	pending.bitType = HOT_HEALS
		
	-- As you can't rely on a hot being the absolutely only one up, have to apply the total amount now :<
	local ticksLeft = math.ceil((endTime - GetTime()) / pending.tickInterval)
	loadHealList(pending, tickAmount, stack, endTime, ticksLeft, ...)

	if( not wasUpdated ) then
		HealComm.callbacks:Fire("HealComm_HealStarted", casterGUID, spellID, pending.bitType, endTime, unpack(tempPlayerList))
	else
		HealComm.callbacks:Fire("HealComm_HealUpdated", casterGUID, spellID, pending.bitType, endTime, unpack(tempPlayerList))
	end
end

local function parseHotBomb(casterGUID, wasUpdated, spellID, amount, ...)
	local spellName, spellRank = GetSpellInfo(spellID)
	if( not amount or not spellName or select("#", ...) == 0 ) then return end
	
	-- If we don't have a pending hot then there is no bomb as far as were concerned
	local hotPending = pendingHeals[casterGUID] and pendingHeals[casterGUID][spellID]
	if( not hotPending or not hotPending.bitType ) then return end
	hotPending.hasBomb = true
	
	pendingHeals[casterGUID][spellName] = pendingHeals[casterGUID][spellName] or {}
	
	local pending = pendingHeals[casterGUID][spellName]
	pending.endTime = hotPending.endTime
	pending.spellID = spellID
	pending.bitType = BOMB_HEALS
	pending.stack = hotPending.stack
	
	loadHealList(pending, amount, pending.stack, pending.endTime, nil, ...)

	if( not wasUpdated ) then
		HealComm.callbacks:Fire("HealComm_HealStarted", casterGUID, spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
	else
		HealComm.callbacks:Fire("HealComm_HealUpdated", casterGUID, spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
	end
end

-- Heal finished
local function parseHealEnd(casterGUID, pending, checkField, spellID, interrupted, ...)
	local spellName = GetSpellInfo(spellID)
	if( not spellName or not pendingHeals[casterGUID] ) then return end
	
	-- Hots use spell IDs while everything else uses spell names. Avoids naming conflicts for multi-purpose spells such as Lifebloom or Regrowth
	if( not pending ) then
		pending = checkField == "id" and pendingHeals[casterGUID][spellID] or pendingHeals[casterGUID][spellName]
	end
	if( not pending or not pending.bitType ) then return end
			
	table.wipe(tempPlayerList)
	
	if( select("#", ...) == 0 ) then
		for i=#(pending), 1, -5 do
			table.insert(tempPlayerList, pending[i - 4])
			removeRecord(pending, pending[i - 4])
		end
	else
		for i=1, select("#", ...) do
			local guid = decompressGUID[select(i, ...)]
			
			table.insert(tempPlayerList, guid)
			removeRecord(pending, guid)
		end
	end
	
	-- Double check and make sure we actually removed at least one person
	if( #(tempPlayerList) == 0 ) then return end
	
	-- Heals that also have a bomb associated to them have to end at this point, they will fire there own callback too
	local bombPending = pending.hasBomb and pendingHeals[casterGUID][spellName]
	if( bombPending and bombPending.bitType ) then
		parseHealEnd(casterGUID, bombPending, "name", spellID, interrupted, ...)
	end

	local bitType = pending.bitType
	-- Clear data if we're done
	if( #(pending) == 0 ) then table.wipe(pending) end
	
	HealComm.callbacks:Fire("HealComm_HealStopped", casterGUID, spellID, bitType, interrupted, unpack(tempPlayerList))
end

HealComm.parseHealEnd = parseHealEnd

-- Heal delayed
local function parseHealDelayed(casterGUID, startTime, endTime, spellName)
	local pending = pendingHeals[casterGUID][spellName]
	-- It's possible to get duplicate interrupted due to raid1 = party1, player = raid# etc etc, just block it here
	if( pending.endTime == endTime and pending.startTime == startTime ) then return end
	
	-- Casted heal
	if( pending.bitType == DIRECT_HEALS ) then
		pending.startTime = startTime
		pending.endTime = endTime
	-- Channel heal
	elseif( pending.bitType == CHANNEL_HEALS ) then
		pending.startTime = startTime
		pending.endTime = endTime
		pending.tickInterval = (pending.endTime - pending.startTime)
	else
		return
	end

	table.wipe(tempPlayerList)
	for i=1, #(pending), 5 do
		table.insert(tempPlayerList, pending[i])
	end

	HealComm.callbacks:Fire("HealComm_HealDelayed", casterGUID, pending.spellID, pending.bitType, pending.endTime, unpack(tempPlayerList))
end

-- After checking around 150-200 messages in battlegrounds, server seems to always be passed (if they are from another server)
-- Channels use tick total because the tick interval varies by haste
-- Hots use tick interval because the total duration varies but the tick interval stays the same
function HealComm:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if( prefix ~= COMM_PREFIX or channel ~= distribution or sender == playerName ) then return end
	
	local commType, extraArg, spellID, arg1, arg2, arg3, arg4, arg5, arg6 = string.split(":", message)
	local casterGUID = UnitGUID(sender)
	spellID = tonumber(spellID)
	
	if( not commType or not spellID or not casterGUID ) then return end
			
	-- New direct heal - D:<extra>:<spellID>:<amount>:target1,target2...
	if( commType == "D" and arg1 and arg2 ) then
		parseDirectHeal(casterGUID, spellID, tonumber(arg1), string.split(",", arg2))
	-- New channel heal - C:<extra>:<spellID>:<amount>:<totalTicks>:target1,target2...
	elseif( commType == "C" and arg1 and arg3 ) then
		parseChannelHeal(casterGUID, spellID, tonumber(arg1), tonumber(arg2), string.split(",", arg3))
	-- New hot with a "bomb" component - B:<totalTicks>:<spellID>:<bombAmount>:target1,target2:<amount>:<isMulti>:<tickInterval>:target1,target2...
	elseif( commType == "B" and arg1 and arg6 ) then
		parseHotHeal(casterGUID, false, spellID, tonumber(arg3), tonumber(extraArg), tonumber(arg5), string.split(",", arg6))
		parseHotBomb(casterGUID, false, spellID, tonumber(arg1), string.split(",", arg2))
	-- New hot - H:<totalTicks>:<spellID>:<amount>:<isMulti>:<tickInterval>:target1,target2...
	elseif( commType == "H" and arg1 and arg4 ) then
		parseHotHeal(casterGUID, false, spellID, tonumber(arg1), tonumber(extraArg), tonumber(arg3), string.split(",", arg4))
	-- New updated heal somehow before ending - U:<totalTicks>:<spellID>:<amount>:<tickInterval>:target1,target2...
	elseif( commtype == "U" and arg1 and arg3 ) then
		parseHotHeal(casterGUID, true, spellID, tonumber(arg1), tonumber(extraArg), tonumber(arg2), string.split(",", arg3))
	-- New variable tick hot - VH::<spellID>:<amount>:<isMulti>:<tickInterval>:target1,target2...
	elseif( commType == "VH" and arg1 and arg4 ) then
		parseHotHeal(casterGUID, false, spellID, arg1, tonumber(arg3), nil, string.split(",", arg4))
	-- New updated variable tick hot - U::<spellID>:amount1@amount2@amount3:<tickTotal>:target1,target2...
	elseif( commtype == "VU" and arg1 and arg3 ) then
		parseHotHeal(casterGUID, true, spellID, arg1, tonumber(arg2), nil, string.split(",", arg3))
	-- New updated bomb hot - UB:<totalTicks>:<spellID>:<bombAmount>:target1,target2:<amount>:<tickInterval>:target1,target2...
	elseif( commtype == "UB" and arg1 and arg5 ) then
		parseHotHeal(casterGUID, true, spellID, tonumber(arg3), tonumber(extraArg), tonumber(arg4), string.split(",", arg5))
		parseHotBomb(casterGUID, true, spellID, tonumber(arg1), string.split(",", arg2))
	-- Heal stopped - S:<extra>:<spellID>:<ended early: 0/1>:target1,target2...
	elseif( commType == "S" or commType == "HS" ) then
		local interrupted = arg1 == "1" and true or false
		local type = commType == "HS" and "id" or "name"
		
		if( arg2 and arg2 ~= "" ) then
			parseHealEnd(casterGUID, nil, type, spellID, interrupted, string.split(",", arg2))
		else
			parseHealEnd(casterGUID, nil, type, spellID, interrupted)
		end
	end
end

-- Bucketing reduces the number of events triggered for heals such as Tranquility that hit multiple targets
-- instead of firing 5 events * ticks it will fire 1 (maybe 2 depending on lag) events
HealComm.bucketHeals = HealComm.bucketHeals or {}
local bucketHeals = HealComm.bucketHeals
local BUCKET_FILLED = 0.30

HealComm.bucketFrame = HealComm.bucketFrame or CreateFrame("Frame")
HealComm.bucketFrame:Hide()

HealComm.bucketFrame:SetScript("OnUpdate", function(self, elapsed)
	local totalLeft = 0
	for casterGUID, spells in pairs(bucketHeals) do
		for id, data in pairs(spells) do
			if( data.timeout ) then
				data.timeout = data.timeout - elapsed
				
				if( data.timeout <= 0 ) then
					-- This shouldn't happen, on the offhand chance it does then don't bother sending an event
					if( #(data) == 0 or not data.spellID or not data.spellName ) then
						table.wipe(data)
					-- We're doing a bucket for a tick heal like Tranquility or Wild Growth
					elseif( data.type == "tick" ) then
						local pending = pendingHeals[casterGUID] and ( pendingHeals[casterGUID][data.spellID] or pendingHeals[casterGUID][data.spellName] )
						if( pending and pending.bitType ) then
							local endTime = select(3, getRecord(pending, data[1]))
							HealComm.callbacks:Fire("HealComm_HealUpdated", casterGUID, pending.spellID, pending.bitType, endtime, unpack(data))
						end

						table.wipe(data)
					-- We're doing a bucket for a cast thats a multi-target heal like Wild Growth or Prayer of Healing
					elseif( data.type == "heal" ) then
						local type, amount, totalTicks, tickInterval, _, hasVariableTicks = CalculateHotHealing(data[1], data.spellID)
						if( type ) then
							local targets, amount = GetHealTargets(type, data[1], hasVariableTicks and amount or math.max(amount, 0), data.spellName, data, hasVariableTicks)
							parseHotHeal(playerGUID, false, data.spellID, amount, totalTicks, tickInterval, string.split(",", targets))
							
							if( not hasVariableTicks ) then
								sendMessage(string.format("H:%d:%d:%d::%d:%s", totalTicks, data.spellID, amount, tickInterval, targets))
							else
								sendMessage(string.format("VH::%d:%s::%d:%s", data.spellID, amount, totalTicks, targets))
							end
						end

						table.wipe(data)
					end
				else
					totalLeft = totalLeft + 1
				end
			end
		end
	end
	
	if( totalLeft <= 0 ) then
		self:Hide()
	end
end)

-- Monitor aura changes as well as new hots being cast
local eventRegistered = {["SPELL_HEAL"] = true, ["SPELL_PERIODIC_HEAL"] = true}
if( isHealerClass ) then
	eventRegistered["SPELL_AURA_REMOVED"] = true
	eventRegistered["SPELL_AURA_APPLIED"] = true
	eventRegistered["SPELL_AURA_REFRESH"] = true
	eventRegistered["SPELL_AURA_APPLIED_DOSE"] = true
	eventRegistered["SPELL_AURA_REMOVED_DOSE"] = true
end

local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local CAN_HEAL = bit.bor(COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_REACTION_NEUTRAL)
function HealComm:COMBAT_LOG_EVENT_UNFILTERED(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if( not eventRegistered[eventType] ) then return end
	
	-- Heal or hot ticked that the library is tracking
	-- It's more efficient/accurate to have the library keep track of this locally, spamming the comm channel would not be a very good thing especially when a single player can have 4 - 8 hots/channels going on them.
	if( eventType == "SPELL_HEAL" or eventType == "SPELL_PERIODIC_HEAL" ) then
		local spellID, spellName, spellSchool = ...
		local pending = sourceGUID and pendingHeals[sourceGUID] and (pendingHeals[sourceGUID][spellID] or pendingHeals[sourceGUID][spellName])
		if( pending and pending[destGUID] and pending.bitType and bit.band(pending.bitType, OVERTIME_HEALS) > 0 ) then
			local amount, stack, endTime, ticksLeft = getRecord(pending, destGUID)
			ticksLeft = ticksLeft - 1
			endTime = GetTime() + pending.tickInterval * ticksLeft
			if( pending.hasVariableTicks ) then table.remove(amount, 1) end
			
			updateRecord(pending, destGUID, amount, stack, endTime, ticksLeft)
			
			if( pending.isMultiTarget ) then
				bucketHeals[sourceGUID] = bucketHeals[sourceGUID] or {}
				bucketHeals[sourceGUID][spellID] = bucketHeals[sourceGUID][spellID] or {}
				
				local spellBucket = bucketHeals[sourceGUID][spellID]
				if( not spellBucket[destGUID] ) then
					spellBucket.timeout = BUCKET_FILLED
					spellBucket.type = "tick"
					spellBucket.spellName = spellName
					spellBucket.spellID = spellID
					spellBucket[destGUID] = true
					table.insert(spellBucket, destGUID)
					
					self.bucketFrame:Show()
				end
			else
				HealComm.callbacks:Fire("HealComm_HealUpdated", sourceGUID, spellID, pending.bitType, endTime, destGUID)
			end
		end

	-- New hot was applied
	elseif( ( eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED_DOSE" ) and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
		local spellID, spellName, spellSchool, auraType = ...
		if( hotData[spellName] ) then
			-- Multi target heal so put it in the bucket
			if( hotData[spellName].isMulti ) then
				bucketHeals[sourceGUID] = bucketHeals[sourceGUID] or {}
				bucketHeals[sourceGUID][spellName] = bucketHeals[sourceGUID][spellName] or {}
				
				-- For some reason, Glyph of Prayer of Healing fires a SPELL_AURA_APPLIED then a SPELL_AURA_REFRESH right after
				local spellBucket = bucketHeals[sourceGUID][spellName]
				if( not spellBucket[destGUID] ) then
					spellBucket.timeout = BUCKET_FILLED
					spellBucket.type = "heal"
					spellBucket.spellName = spellName
					spellBucket.spellID = spellID
					spellBucket[destGUID] = true
					table.insert(spellBucket, destGUID)
					
					self.bucketFrame:Show()
				end
				return
			end
			
			-- Single target so we can just send it off now thankfully
			local type, amount, totalTicks, tickInterval, bombAmount, hasVariableTicks = CalculateHotHealing(destGUID, spellID)
			if( type ) then
				local targets, amount = GetHealTargets(type, destGUID, hasVariableTicks and amount or math.max(amount, 0), spellName, hasVariableTicks)
				parseHotHeal(sourceGUID, false, spellID, amount, totalTicks, tickInterval, string.split(",", targets))

				-- Hot with a bomb!
				if( bombAmount ) then
					local bombTargets, bombAmount = GetHealTargets(BOMB_HEALS, destGUID, math.max(bombAmount, 0), spellName)
					parseHotBomb(sourceGUID, false, spellID, bombAmount, string.split(",", bombTargets))
					sendMessage(string.format("B:%d:%d:%d:%s:%d::%d:%s", totalTicks, spellID, bombAmount, bombTargets, amount, tickInterval, targets))
				elseif( hasVariableTicks ) then
					sendMessage(string.format("VH::%d:%s::%d:%s", spellID, amount, totalTicks, targets))
				-- Normal hot, nothing fancy
				else
					sendMessage(string.format("H:%d:%d:%d::%d:%s", totalTicks, spellID, amount, tickInterval, targets))
				end
			end
		end
	-- Single stack of a hot was removed, this only applies when going from 2 -> 1, when it goes from 1 -> 0 it fires SPELL_AURA_REMOVED
	elseif( eventType == "SPELL_AURA_REMOVED_DOSE" and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
		local spellID, spellName, spellSchool, auraType, stacks = ...
		local pending = sourceGUID and pendingHeals[sourceGUID] and pendingHeals[sourceGUID][spellID]
		if( pending and pending.bitType ) then
			local amount = getRecord(pending, destGUID)
			if( amount ) then
				parseHotHeal(sourceGUID, true, spellID, amount, pending.totalTicks, pending.tickInterval, compressGUID[destGUID])
				
				-- Plant the bomb
				local bombPending = pending.hasBomb and pendingHeals[sourceGUID][spellName]
				if( bombPending and bombPending.bitType ) then
					local bombAmount = getRecord(bombPending, destGUID)
					if( bombAmount ) then
						parseHotBomb(sourceGUID, true, spellID, bombAmount, compressGUID[destGUID])
						
						sendMessage(string.format("UB:%s:%d:%d:%s:%d:%d:%s", pending.totalTicks, spellID, bombAmount, compressGUID[destGUID], amount, pending.tickInterval, compressGUID[destGUID]))
						return
					end
				end
				
				-- Failed to find any sort of bomb-y info we needed or it doesn't have a bomb anyway
				if( pending.hasVariableTicks ) then
					sendMessage(string.format("VU::%d:%s:%d:%s", spellID, amount, pending.totalTicks, compressGUID[destGUID]))
				else
					sendMessage(string.format("U:%s:%d:%d:%d:%s", spellID, amount, pending.totalTicks, pending.tickInterval, compressGUID[destGUID]))
				end
			end
		end

	-- Aura faded		
	elseif( eventType == "SPELL_AURA_REMOVED" ) then
		local spellID, spellName, spellSchool, auraType = ...
		
		-- Hot faded that we cast 
		if( hotData[spellName] and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE ) then
			parseHealEnd(sourceGUID, nil, "id", spellID, false, compressGUID[destGUID])
			sendMessage(string.format("HS::%d::%s", spellID, compressGUID[destGUID]))
		end
	end
end

-- Spell cast magic
-- When auto self cast is on, the UNIT_SPELLCAST_SENT event will always come first followed by the funciton calls
-- Otherwise either SENT comes first then function calls, or some function calls then SENT then more function calls
local castTarget, castID, mouseoverGUID, mouseoverName, hadTargetingCursor, lastSentID, lastTargetGUID, lastTargetName
local lastFriendlyGUID, lastFriendlyName, lastGUID, lastName, lastIsFriend
local castGUIDs, guidPriorities = {}, {}

-- Deals with the fact that functions are called differently
-- Why a table when you can only cast one spell at a time you ask? When you factor in lag and mash clicking it's possible to:
-- cast A, interrupt it, cast B and have A fire SUCEEDED before B does, the tables keeps it from bugging out
local function setCastData(priority, name, guid)
	if( not guid or not lastSentID ) then return end
	if( guidPriorities[lastSentID] and guidPriorities[lastSentID] >= priority ) then return end
	
	-- This is meant as a way of locking a cast in because which function has accurate data can be called into question at times, one of them always does though
	-- this means that as soon as it finds a name match it locks the GUID in until another SENT is fired. Technically it's possible to get a bad GUID but it first requires
	-- the functions to return different data and it requires the messed up call to be for another name conflict.
	if( castTarget and castTarget == name ) then priority = 99 end
	
	castGUIDs[lastSentID] = guid
	guidPriorities[lastSentID] = priority
end

-- When the game tries to figure out the UnitID from the name it will prioritize players over non-players
-- if there are conflicts in names it will pull the one with the least amount of current health
function HealComm:UNIT_SPELLCAST_SENT(unit, spellName, spellRank, castOn)
	if( unit ~= "player" or not spellData[spellName] or not averageHeal[spellName][spellRank] ) then return end
	
	castTarget = string.gsub(castOn, "(.-)%-(.*)$", "%1")
	lastSentID = spellName .. spellRank
	
	-- Self cast is off which means it's possible to have a spell waiting for a target.
	-- It's possible that it's the mouseover unit, but if a Target, TargetLast or AssistUnit call comes right after it means it's casting on that instead instead.
	if( hadTargetingCursor ) then
		hadTargetingCursor = nil
		self.resetFrame:Show()
		
		guidPriorities[lastSentID] = nil
		setCastData(5, mouseoverName, mouseoverGUID)
	else
		-- If the player is ungrouped and healing, you can't take advantage of the name -> "unit" map, look in the UnitIDs that would most likely contain the information that's needed.
		local guid = UnitGUID(castOn)
		if( not guid ) then
			guid = UnitName("target") == castTarget and UnitGUID("target") or UnitName("focus") == castTarget and UnitGUID("focus") or UnitName("mouseover") == castTarget and UnitGUID("mouseover") or UnitName("targettarget") == castTarget and UnitGUID("target") or UnitName("focustarget") == castTarget and UnitGUID("focustarget")
		end
		
		guidPriorities[lastSentID] = nil
		setCastData(0, nil, guid)
	end
end

function HealComm:UNIT_SPELLCAST_START(unit, spellName, spellRank, id)
	if( unit ~= "player" or not spellData[spellName] or not averageHeal[spellName][spellRank] ) then return end
	local nameID = spellName .. spellRank
	local castGUID = castGUIDs[nameID]
	
	castID = id

	-- Figure out who we are healing and for how much
	local type, amount, ticks, localTicks = CalculateHealing(castGUID, spellName, spellRank)
	local targets, amount = GetHealTargets(type, castGUID, math.max(amount, 0), spellName)
	
	if( type == DIRECT_HEALS ) then
		parseDirectHeal(playerGUID, self.spellToID[nameID], amount, string.split(",", targets))
		sendMessage(string.format("D::%d:%d:%s", self.spellToID[nameID] or 0, amount or "", targets))
	elseif( type == CHANNEL_HEALS ) then
		parseChannelHeal(playerGUID, self.spellToID[nameID], amount, localTicks, string.split(",", targets))
		sendMessage(string.format("C::%d:%d:%s:%s", self.spellToID[nameID] or 0, amount, ticks, targets))
	end
end

HealComm.UNIT_SPELLCAST_CHANNEL_START = HealComm.UNIT_SPELLCAST_START

function HealComm:UNIT_SPELLCAST_SUCCEEDED(unit, spellName, spellRank, id)
	if( unit ~= "player" or not spellData[spellName] or id ~= castID or id == 0 ) then return end
	castID = nil

	parseHealEnd(playerGUID, nil, "name", self.spellToID[spellName .. spellRank], false)
	sendMessage(string.format("S::%d:0", self.spellToID[spellName .. spellRank] or 0))
end

function HealComm:UNIT_SPELLCAST_STOP(unit, spellName, spellRank, id)
	if( unit ~= "player" or not spellData[spellName] or id ~= castID ) then return end
	local nameID = spellName .. spellRank
	
	castID = nil
	parseHealEnd(playerGUID, nil, "name", self.spellToID[spellName .. spellRank], true)
	sendMessage(string.format("S::%d:1", self.spellToID[spellName .. spellRank] or 0))
end

function HealComm:UNIT_SPELLCAST_CHANNEL_STOP(unit, spellName, spellRank, id)
	if( unit ~= "player" or not spellData[spellName] or id ~= castID ) then return end
	local nameID = spellName .. spellRank

	castID = nil
	parseHealEnd(playerGUID, nil, "name", self.spellToID[nameID], false)
	sendMessage(string.format("S::%d:0", self.spellToID[nameID] or 0))
end

-- Cast didn't go through, recheck any charge data if necessary
function HealComm:UNIT_SPELLCAST_INTERRUPTED(unit, spellName, spellRank, id)
	if( unit ~= "player" or not spellData[spellName] or castID ~= id ) then return end
	
	ResetChargeData(castGUIDs[spellName .. spellRank], spellName, spellRank)
end

-- It's faster to do heal delays locally rather than through syncing, as it only has to go from WoW -> Player instead of Caster -> WoW -> Player
function HealComm:UNIT_SPELLCAST_DELAYED(unit, spellName, spellRank, id)
	local casterGUID = UnitGUID(unit)
	if( unit == "focus" or unit == "target" or not pendingHeals[casterGUID] or not pendingHeals[casterGUID][spellName] ) then return end
	
	-- Direct heal delayed
	if( pendingHeals[casterGUID][spellName].bitType == DIRECT_HEALS ) then
		local startTime, endTime = select(5, UnitCastingInfo(unit))
		if( startTime and endTime ) then
			parseHealDelayed(casterGUID, startTime / 1000, endTime / 1000, spellName)
		end
	-- Channel heal delayed
	elseif( pendingHeals[casterGUID][spellName].bitType == CHANNEL_HEALS ) then
		local startTime, endTime = select(5, UnitChannelInfo(unit))
		if( startTime and endTime ) then
			parseHealDelayed(casterGUID, startTime / 1000, endTime / 1000, spellName)
		end
	end
end

HealComm.UNIT_SPELLCAST_CHANNEL_UPDATE = HealComm.UNIT_SPELLCAST_DELAYED

-- Need to keep track of mouseover as it can change in the split second after/before casts
function HealComm:UPDATE_MOUSEOVER_UNIT()
	mouseoverGUID = UnitCanAssist("player", "mouseover") and UnitGUID("mouseover")
	mouseoverName = UnitCanAssist("player", "mouseover") and UnitName("mouseover")
end

-- Keep track of our last target/friendly target for the sake of /targetlast and /targetlastfriend
function HealComm:PLAYER_TARGET_CHANGED()
	if( lastGUID and lastName ) then
		if( lastIsFriend ) then
			lastFriendlyGUID, lastFriendlyName = lastGUID, lastName
		end
		
		lastTargetGUID, lastTargetName = lastGUID, lastName
	end
	
	-- Despite the fact that it's called target last friend, UnitIsFriend won't actually work
	lastGUID = UnitGUID("target")
	lastName = UnitName("target")
	lastIsFriend = UnitCanAssist("player", "target")
end

-- Unit was targeted through a function
function HealComm:Target(unit)
	if( self.resetFrame:IsShown() and UnitCanAssist("player", unit) ) then
		setCastData(6, UnitName(unit), UnitGUID(unit))
	end

	self.resetFrame:Hide()
	hadTargetingCursor = nil
end

-- This is only needed when auto self cast is off, in which case this is called right after UNIT_SPELLCAST_SENT
-- because the player got a waiting-for-cast icon up and they pressed a key binding to target someone
HealComm.TargetUnit = HealComm.Target

-- Works the same as the above except it's called when you have a cursor icon and you click on a secure frame with a target attribute set
HealComm.SpellTargetUnit = HealComm.Target

-- Used in /assist macros
function HealComm:AssistUnit(unit)
	if( self.resetFrame:IsShown() and UnitCanAssist("player", unit .. "target") ) then
		setCastData(6, UnitName(unit .. "target"), UnitGUID(unit .. "target"))
	end
	
	self.resetFrame:Hide()
	hadTargetingCursor = nil
end

-- Target last was used, the only reason this is called with reset frame being shown is we're casting on a valid unit
-- don't have to worry about the GUID no longer being invalid etc
function HealComm:TargetLast(guid, name)
	if( name and guid and self.resetFrame:IsShown() ) then
		setCastData(6, name, guid) 
	end
	
	self.resetFrame:Hide()
	hadTargetingCursor = nil
end

function HealComm:TargetLastFriend()
	self:TargetLast(lastFriendlyGUID, lastFriendlyName)
end

function HealComm:TargetLastTarget()
	self:TargetLast(lastTargetGUID, lastTargetName)
end

-- Spell was cast somehow
function HealComm:CastSpell(arg, unit)
	-- If the spell is waiting for a target and it's a spell action button then we know that the GUID has to be mouseover or a key binding cast.
	if( unit and UnitCanAssist("player", unit)  ) then
		setCastData(4, UnitName(unit), UnitGUID(unit))
	-- No unit, or it's a unit we can't assist 
	elseif( not SpellIsTargeting() ) then
		if( UnitCanAssist("player", "target") ) then
			setCastData(4, UnitName("target"), UnitGUID("target"))
		else
			setCastData(4, playerName, playerGUID)
		end
		
		hadTargetingCursor = nil
	else
		hadTargetingCursor = true
	end
end

HealComm.CastSpellByName = HealComm.CastSpell
HealComm.CastSpellByID = HealComm.CastSpell
HealComm.UseAction = HealComm.CastSpell

-- Make sure we don't have invalid units in this
local function sanityCheckMapping()
	for guid, unit in pairs(guidToUnit) do
		-- Unit no longer exists, remove all healing for them
		if( not UnitExists(unit) ) then
			-- Check for (and remove) any active heals
			if( pendingHeals[guid] ) then
				for id, pending in pairs(pendingHeals[guid]) do
					if( pending.bitType ) then
						parseHealEnd(guid, pending, nil, pending.spellID, true)
					end
				end
				
				pendingHeals[guid] = nil
			end
			
			-- Remove any heals that are on them
			removeAllRecords(guid)
		
			guidToUnit[guid] = nil
			guidToGroup[guid] = nil			
		end
	end
end

-- 5s poll that tries to solve the problem of X running out of range while a HoT is ticking
-- this is not really perfect far from it in fact. If I can find a better solution I will switch to that.
if( not HealComm.hotMonitor ) then
	HealComm.hotMonitor = CreateFrame("Frame")
	HealComm.hotMonitor:Hide()
	HealComm.hotMonitor.timeElapsed = 0
	HealComm.hotMonitor:SetScript("OnUpdate", function(self, elapsed)
		self.timeElapsed = self.timeElapsed + elapsed
		if( self.timeElapsed < 5 ) then return end
		self.timeElapsed = self.timeElapsed - 5
		
		-- For the time being, it will only remove them if they don't exist and it found a valid unit
		-- units that leave the raid are automatically removed 
		local found
		for guid in pairs(activeHots) do
			if( guidToUnit[guid] and not UnitIsVisible(guidToUnit[guid]) ) then
				removeAllRecords(guid)
			else
				found = true
			end
		end
		
		if( not found ) then
			self:Hide()
		end
	end)
end

-- After the player leaves a group, tables are wiped out or released for GC
local wasInParty, wasInRaid
local function clearGUIDData()
	clearPendingHeals()
	
	table.wipe(compressGUID)
	table.wipe(decompressGUID)
	table.wipe(activePets)
	
	playerGUID = playerGUID or UnitGUID("player")
	HealComm.guidToUnit = {[playerGUID] = "player"}
	guidToUnit = HealComm.guidToUnit
	
	HealComm.guidToGroup = {}
	guidToGroup = HealComm.guidToGroup
	
	HealComm.activeHots = {}
	activeHots = HealComm.activeHots
	
	HealComm.pendingHeals = {}
	pendingHeals = HealComm.pendingHeals
	
	HealComm.bucketHeals = {}
	bucketHeals = HealComm.bucketHeals
	
	wasInParty, wasInRaid = nil, nil
end

-- Keeps track of pet GUIDs, as pets are considered vehicles this will also map vehicle GUIDs to unit
function HealComm:UNIT_PET(unit)
	local pet = self.unitToPet[unit]
	local guid = pet and UnitGUID(pet)
	
	-- We have an active pet guid from this user and it's different, kill it
	local activeGUID = activePets[unit]
	if( activeGUID and activeGUID ~= guid ) then
		removeAllRecords(activeGUID)

		guidToUnit[activeGUID] = nil
		guidToGroup[activeGUID] = nil
		activePets[unit] = nil
	end

	-- Add the new record
	if( guid ) then
		guidToUnit[guid] = pet
		guidToGroup[guid] = guidToGroup[UnitGUID(unit)]
		activePets[unit] = guid
	end
end

-- Keep track of party GUIDs, ignored in raids as RRU will handle that mapping
function HealComm:PARTY_MEMBERS_CHANGED()
	if( GetNumRaidMembers() > 0 ) then return end
	updateDistributionChannel()
	
	if( GetNumPartyMembers() == 0 ) then
		if( wasInParty ) then
			clearGUIDData()
		end
		return
	end
	
	-- Parties are not considered groups in terms of API, so fake it and pretend they are all in group 0
	guidToGroup[playerGUID or UnitGUID("player")] = 0
	if( not wasInParty ) then self:UNIT_PET("player") end
	
	for i=1, MAX_PARTY_MEMBERS do
		local unit = "party" .. i
		if( UnitExists(unit) ) then
			local lastGroup = guidToGroup[guid]
			local guid = UnitGUID(unit)
			guidToUnit[guid] = unit
			guidToGroup[guid] = 0
			
			if( not wasInParty or lastGroup ~= guidToGroup[guid] ) then
				self:UNIT_PET(unit)
			end
		end
	end

	sanityCheckMapping()
	wasInParty = true
end

-- Keep track of raid GUIDs
function HealComm:RAID_ROSTER_UPDATE()
	updateDistributionChannel()

	-- Left raid, clear any cache we had
	if( GetNumRaidMembers() == 0 ) then
		if( wasInRaid ) then
			clearGUIDData()
		end
		return
	end
	
	-- Add new members
	for i=1, MAX_RAID_MEMBERS do
		local unit = "raid" .. i
		if( UnitExists(unit) ) then
			local lastGroup = guidToGroup[guid]
			local guid = UnitGUID(unit)
			guidToUnit[guid] = unit
			guidToGroup[guid] = select(3, GetRaidRosterInfo(i))
			
			-- If the pets owners group changed then the pets group should be updated too
			if( not wasInRaid or guidToGroup[guid] ~= lastGroup ) then
				self:UNIT_PET(unit)
			end
		end
	end
	
	sanityCheckMapping()
	wasInRaid = true
end

-- PLAYER_ALIVE = got talent data
function HealComm:PLAYER_ALIVE()
	self:PLAYER_TALENT_UPDATE()
	self.eventFrame:UnregisterEvent("PLAYER_ALIVE")
end

-- Initialize the library
function HealComm:OnInitialize()
	-- If another instance already loaded then the tables should be wiped to prevent old data from persisting
	-- in case of a spell being removed later on, only can happen if a newer LoD version is loaded
	table.wipe(spellData)
	table.wipe(hotData)
	table.wipe(itemSetsData)
	table.wipe(talentData)
	table.wipe(averageHeal)

	-- Load all of the classes formulas and such
	LoadClassData()
	
	-- Setup the metatables for average healing
	for spell in pairs(spellData) do
		averageHeal[spell] = setmetatable({spell = spell}, self.averageHealMT)
	end
	
	-- Cache glyphs initially
    for id=1, GetNumGlyphSockets() do
		local enabled, _, glyphID = GetGlyphSocketInfo(id)
		if( enabled and glyphID ) then
			glyphCache[glyphID] = true
			glyphCache[id] = glyphID
		end
	end
	
	self:PLAYER_EQUIPMENT_CHANGED()
	
	-- When first logging in talent data isn't available until at least PLAYER_ALIVE, so if we don't have data
	-- will wait for that event otherwise will just cache it right now
	if( GetNumTalentTabs() == 0 ) then
		self.eventFrame:RegisterEvent("PLAYER_ALIVE")
	else
		self:PLAYER_TALENT_UPDATE()
	end
	
	if( ResetChargeData ) then
		HealComm.eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	end
	
	-- Finally, register it all
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	self.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
	self.eventFrame:RegisterEvent("GLYPH_ADDED")
	self.eventFrame:RegisterEvent("GLYPH_REMOVED")
	self.eventFrame:RegisterEvent("GLYPH_UPDATED")
	self.eventFrame:RegisterEvent("UNIT_AURA")
	
	if( self.initialized ) then return end
	self.initialized = true

	self.resetFrame = CreateFrame("Frame")
	self.resetFrame:Hide()
	self.resetFrame:SetScript("OnUpdate", function(self) self:Hide() end)

	-- You can't unhook secure hooks after they are done, so will hook once and the HealComm table will update with the latest functions
	-- automagically. If a new function is ever used it'll need a specific variable to indicate those set of hooks.
	-- By default most of these are mapped to a more generic function, but I call separate ones so I don't have to rehook
	-- if it turns out I need to know something specific
	hooksecurefunc("TargetUnit", function(...) HealComm:TargetUnit(...) end)
	hooksecurefunc("SpellTargetUnit", function(...) HealComm:SpellTargetUnit(...) end)
	hooksecurefunc("AssistUnit", function(...) HealComm:AssistUnit(...) end)
	hooksecurefunc("UseAction", function(...) HealComm:UseAction(...) end)
	hooksecurefunc("TargetLastFriend", function(...) HealComm:TargetLastFriend(...) end)
	hooksecurefunc("TargetLastTarget", function(...) HealComm:TargetLastTarget(...) end)
	hooksecurefunc("CastSpellByName", function(...) HealComm:CastSpellByName(...) end)
	
	-- Fixes hook error for people who are not on 3.2 yet
	if( CastSpellByID ) then
		hooksecurefunc("CastSpellByID", function(...) HealComm:CastSpellByID(...) end)
	end
end

-- General event handler
local function OnEvent(self, event, ...)
	HealComm[event](HealComm, ...)
end

-- Event handler
HealComm.eventFrame = HealComm.frame or HealComm.eventFrame or CreateFrame("Frame")
HealComm.eventFrame:UnregisterAllEvents()
HealComm.eventFrame:RegisterEvent("UNIT_PET")
HealComm.eventFrame:SetScript("OnEvent", OnEvent)
HealComm.frame = nil

-- At PLAYER_LEAVING_WORLD (Actually more like MIRROR_TIMER_STOP but anyway) UnitGUID("player") returns nil, delay registering
-- events and set a playerGUID/playerName combo for all players on PLAYER_LOGIN not just the healers.
function HealComm:PLAYER_LOGIN()
	playerGUID = UnitGUID("player")
	playerName = UnitName("player")
	playerLevel = UnitLevel("player")
	
	-- Oddly enough player GUID is not available on file load, so keep the map of player GUID to themselves too
	guidToUnit[playerGUID] = "player"

	if( isHealerClass ) then
		self:OnInitialize()
	end

	self.eventFrame:UnregisterEvent("PLAYER_LOGIN")
	self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
	
	self:ZONE_CHANGED_NEW_AREA()
	self:RAID_ROSTER_UPDATE()
	self:PARTY_MEMBERS_CHANGED()
end

if( not IsLoggedIn() ) then
	HealComm.eventFrame:RegisterEvent("PLAYER_LOGIN")
else
	HealComm:PLAYER_LOGIN()
end
