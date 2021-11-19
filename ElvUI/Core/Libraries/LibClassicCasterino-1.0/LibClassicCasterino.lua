--[================[
LibClassicCasterino
Author: d87
--]================]
if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end

local apiLevel = math.floor(select(4,GetBuildInfo())/10000)
local isClassic = apiLevel <= 2
local isVanilla = apiLevel == 1
local isBC = apiLevel == 2

local MAJOR, MINOR = "LibClassicCasterino", 37
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end


lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

lib.frame = lib.frame or CreateFrame("Frame")

local f = lib.frame
local callbacks = lib.callbacks

lib.casters = lib.casters or {} -- setmetatable({}, { __mode = "v" })
local casters = lib.casters

lib.movecheckGUIDs = lib.movecheckGUIDs or {}
local movecheckGUIDs = lib.movecheckGUIDs
local MOVECHECK_TIMEOUT = 4

local UnitGUID = UnitGUID
local bit_band = bit.band

local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local CastingInfo = CastingInfo
local ChannelInfo = ChannelInfo
local GetUnitSpeed = GetUnitSpeed
local UnitIsUnit = UnitIsUnit

local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_TYPE_PLAYER_OR_PET = COMBATLOG_OBJECT_TYPE_PLAYER + COMBATLOG_OBJECT_TYPE_PET
local classCasts
local classChannelsByAura
local classChannelsByCast
local talentDecreased
local crowdControlAuras
local FireToUnits

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)


local spellNameToID = {}
local NPCspellNameToID = {}
local NPCSpells

local function makeCastUIDFromSpellID(npcID, spellID)
    return tostring(npcID)..GetSpellInfo(spellID)
end
local castTimeCache = {
    [makeCastUIDFromSpellID(15990, 8407)] = 2, -- Kel'Thuzad, "Frostbolt"
}
local castTimeCacheStartTimes = setmetatable({}, { __mode = "v" })

local AIMED_SHOT = GetSpellInfo(19434)
local MULTI_SHOT = GetSpellInfo(25294)
local AimedDelay = 1
local castingAimedShot = false
local playerGUID = UnitGUID("player")

--[[
function DUMPCASTS()
    local castedSpells = {}
    local counter = 0
    for id=1,40000 do
        local name, _, texture, castTime = GetSpellInfo(id)
        136235 -- interface/icons/temp.blp -- Samwise Didier Icon aka missing icon
        if name and castTime > 500 and texture ~= 136235 then
            castedSpells[id] = true
            counter = counter + 1
        end
    end
    print(counter)
    NugHealthDB.LCDDUMP = castedSpells
end
]]

local refreshCastTable = function(tbl, ...)
    local numArgs = select("#", ...)
    for i=1, numArgs do
        tbl[i] = select(i, ...)
    end
end

local makeCastUID = function(guid, spellName)
    local _, _, _, _, _, npcID = strsplit("-", guid);
    npcID = npcID or "Unknown"
    return npcID..spellName
end

local function CastStart(srcGUID, castType, spellName, spellID, overrideCastTime, isSrcEnemyPlayer )
    -- This cast time can't be used reliably because it's changing depending on player's own haste
    local _, _, icon, castTime = GetSpellInfo(spellID)
    if castType == "CAST" then
        local knownCastDuration = classCasts[spellID]
        if knownCastDuration then
            castTime = knownCastDuration*1000
        end
    end
    if castType == "CHANNEL" then
        local channelDuration = classChannelsByAura[spellID] or classChannelsByCast[spellID]
        castTime = channelDuration*1000
    end
    local decreased = talentDecreased[spellID]
    if decreased then
        castTime = castTime - decreased*1000
    end
    if overrideCastTime then
        castTime = overrideCastTime
    end
    local now = GetTime()*1000
    local startTime = now
    local endTime = now + castTime
    local currentCast = casters[srcGUID]

    if currentCast then
        refreshCastTable(currentCast, castType, spellName, icon, startTime, endTime, spellID )
    else
        casters[srcGUID] = { castType, spellName, icon, startTime, endTime, spellID }
    end

    if isSrcEnemyPlayer then
        if not (spellID == 4068 or spellID == 19769) then -- Iron Grenade, Thorium Grenade
            movecheckGUIDs[srcGUID] = MOVECHECK_TIMEOUT
        end
    end

    if castType == "CAST" then
        if srcGUID == playerGUID and (spellName == AIMED_SHOT or spellName == MULTI_SHOT) then
            castingAimedShot = true
            AimedDelay = 1
            movecheckGUIDs[srcGUID] = MOVECHECK_TIMEOUT
            if spellName == MULTI_SHOT then
                casters[srcGUID][5] = startTime + 500
            end
            callbacks:Fire("UNIT_SPELLCAST_START", "player")
        end
        FireToUnits("UNIT_SPELLCAST_START", srcGUID)
    else
        FireToUnits("UNIT_SPELLCAST_CHANNEL_START", srcGUID)
    end
end

local function CastStop(srcGUID, castType, suffix, suffix2 )
    local currentCast = casters[srcGUID]
    if currentCast then
        castType = castType or currentCast[1]

        casters[srcGUID] = nil
        movecheckGUIDs[srcGUID] = nil

        if castType == "CAST" then
            local event = "UNIT_SPELLCAST_"..suffix
            if srcGUID == playerGUID and castingAimedShot then
                castingAimedShot = false
                callbacks:Fire(event, "player")
            end
            FireToUnits(event, srcGUID)
            if suffix2 then
                FireToUnits("UNIT_SPELLCAST_"..suffix2, srcGUID)
            end
        else
            FireToUnits("UNIT_SPELLCAST_CHANNEL_STOP", srcGUID)
        end
    end
end

function f:COMBAT_LOG_EVENT_UNFILTERED(event)

    local timestamp, eventType, hideCaster,
    srcGUID, srcName, srcFlags, srcFlags2,
    dstGUID, dstName, dstFlags, dstFlags2,
    spellID, spellName, arg3, arg4, arg5,
    arg6, resisted, blocked, absorbed = CombatLogGetCurrentEventInfo()

    local isSrcPlayer = bit_band(srcFlags, COMBATLOG_OBJECT_TYPE_PLAYER_OR_PET) > 0
    if isSrcPlayer and spellID == 0 then
        spellID = spellNameToID[spellName]
    end
    if eventType == "SPELL_CAST_START" then
        if isSrcPlayer then
            local isCasting = classCasts[spellID]
            if isCasting then
                local isSrcFriendlyPlayer = bit_band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
                CastStart(srcGUID, "CAST", spellName, spellID, nil, not isSrcFriendlyPlayer)
            end
        else
            local castUID = makeCastUID(srcGUID, spellName)
            local cachedTime = castTimeCache[castUID]
            local spellID = NPCspellNameToID[spellName] -- just for the icon
            if not spellID then
                spellID = 4036 -- Engineering Icon
            end
            if cachedTime then
                CastStart(srcGUID, "CAST", spellName, spellID, cachedTime*1000)
            else
                castTimeCacheStartTimes[srcGUID..castUID] = GetTime()
                CastStart(srcGUID, "CAST", spellName, spellID, 1500) -- using default 1.5s cast time for now
            end
        end
    elseif eventType == "SPELL_CAST_FAILED" then

            CastStop(srcGUID, "CAST", "INTERRUPTED", "STOP")

    elseif eventType == "SPELL_CAST_SUCCESS" then
            if isSrcPlayer then
                if classChannelsByAura[spellID] then
                    -- SPELL_CAST_SUCCESS can come right after AURA_APPLIED, so ignoring it
                    return
                elseif classChannelsByCast[spellID] then
                    -- Channels fire SPELL_CAST_SUCCESS at their start
                    local isChanneling = classChannelsByCast[spellID]
                    if isChanneling then
                        local isSrcFriendlyPlayer = bit_band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
                        CastStart(srcGUID, "CHANNEL", spellName, spellID, nil, not isSrcFriendlyPlayer)
                    end
                    return
                end
            end
            if not isSrcPlayer then
                local castUID = makeCastUID(srcGUID, spellName)
                local cachedTime = castTimeCache[castUID]
                if not cachedTime then
                    local restoredStartTime = castTimeCacheStartTimes[srcGUID..castUID]
                    if restoredStartTime then
                        local now = GetTime()
                        local castTime = now - restoredStartTime
                        if castTime < 10 then
                            castTimeCache[castUID] = castTime
                        end
                    end
                end
            end
            CastStop(srcGUID, nil, "SUCCEEDED", "STOP")

    elseif eventType == "SPELL_INTERRUPT" then

            CastStop(dstGUID, nil, "INTERRUPTED", "STOP")
    elseif eventType == "UNIT_DIED" then
            CastStop(dstGUID, nil, "INTERRUPTED", "STOP")

    elseif  eventType == "SPELL_AURA_APPLIED" or
            eventType == "SPELL_AURA_REFRESH" or
            eventType == "SPELL_AURA_APPLIED_DOSE"
    then
        if isSrcPlayer then
            if crowdControlAuras[spellName] then
                CastStop(dstGUID, nil, "INTERRUPTED", "STOP")
                return
            end

            local isChanneling = classChannelsByAura[spellID]
            if isChanneling then
                local isSrcFriendlyPlayer = bit_band(srcFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
                CastStart(srcGUID, "CHANNEL", spellName, spellID, nil, not isSrcFriendlyPlayer)
            end
        end
    elseif eventType == "SPELL_AURA_REMOVED" then
        if isSrcPlayer then
            local isChanneling = classChannelsByAura[spellID]
            if isChanneling then
                CastStop(srcGUID, "CHANNEL", "STOP")
            end
        end
    elseif castingAimedShot and dstGUID == UnitGUID("player") then
        if eventType == "SWING_DAMAGE" or
           eventType == "ENVIRONMENTAL_DAMAGE" or
           eventType == "RANGE_DAMAGE" or
           eventType == "SPELL_DAMAGE"
        then
            if resisted or blocked or absorbed then return end
            local currentCast = casters[UnitGUID("player")]
            if currentCast then
                refreshCastTable(currentCast, currentCast[1], currentCast[2], currentCast[3], currentCast[4], currentCast[5] + (AimedDelay *1000))
                if AimedDelay > 0.2 then
                    AimedDelay = AimedDelay - 0.2
                end
                callbacks:Fire("UNIT_SPELLCAST_DELAYED", "player")
            end
        end
    end

end

local castTimeIncreases = {
    [1714] = 1.5,    -- Curse of Tongues (Rank 1) (50%)
    [11719] = 1.6,   -- Curse of Tongues (Rank 2) (60%)
    [5760] = 1.4,    -- Mind-Numbing Poison (Rank 1) (40%)
    [8692] = 1.5,    -- Mind-Numbing Poison (Rank 2) (50%)
    [11398] = 1.6,   -- Mind-Numbing Poison (Rank 3) (60%)
    [1098] = 1.3,    -- Enslave Demon (Rank 1) (30%)
    [11725] = 1.3,   -- Enslave Demon (Rank 2) (30%)
    [11726] = 1.3,   -- Enslave Demon (Rank 3) (30%)
}
local attackTimeDecreases = {
    [6150] = 1.3,    -- Quick Shots/ Imp Aspect of the Hawk (Aimed)
    [3045] = 1.4,    -- Rapid Fire (Aimed)
    [28866] = 1.2,   -- Kiss of the Spider (Increases your _attack speed_ by 20% for 15 sec.) -- For Aimed
}

local function GetTrollBerserkHaste(unit)
    local perc = UnitHealth(unit)/UnitHealthMax(unit)
    local speed = min((1.3 - perc)/3, .3) + 1
    return speed
end
local function GetRangedHaste(unit)
    local positiveMul = 1
    for i=1, 100 do
        local name, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, i, "HELPFUL")
        if not name then return positiveMul end
        if attackTimeDecreases[spellID] or spellID == 26635 then
            positiveMul = positiveMul * (attackTimeDecreases[spellID] or GetTrollBerserkHaste(unit))
        end
    end
    return positiveMul
end
local function GetCastSlowdown(unit)
    local negativeEx = 1
    for i=1, 100 do
        local name, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, i, "HARMFUL")
        if not name then return negativeEx end
        if castTimeIncreases[spellID] then
            negativeEx = math.max(negativeEx, castTimeIncreases[spellID])
        end
    end
    return negativeEx
end

function lib:UnitCastingInfo(unit)
    if UnitIsUnit(unit,"player") then
        if not castingAimedShot then
            return CastingInfo()
        end
    end
    local guid = UnitGUID(unit)
    local cast = casters[guid]
    if cast then
        local castType, name, icon, startTimeMS, endTimeMS, spellID = unpack(cast)
        if castingAimedShot and spellID ~= 25294 then -- Multi-Shot spellID
            local haste = GetRangedHaste(unit)
            local duration = endTimeMS - startTimeMS
            endTimeMS = startTimeMS + duration/haste
        end

        local slowdown = GetCastSlowdown(unit)
        if slowdown ~= 1 then
            local duration = endTimeMS - startTimeMS
            endTimeMS = startTimeMS + duration * slowdown
        end

        if castType == "CAST" and endTimeMS > GetTime()*1000 then
            local castID = nil
            return name, nil, icon, startTimeMS, endTimeMS, nil, castID, false, spellID
        end
    end
end

function lib:UnitChannelInfo(unit)
    if UnitIsUnit(unit, "player") then return ChannelInfo() end
    local guid = UnitGUID(unit)
    local cast = casters[guid]
    if cast then
        local castType, name, icon, startTimeMS, endTimeMS, spellID = unpack(cast)
        -- Curse of Tongues doesn't matter that much for channels, skipping
        if castType == "CHANNEL" and endTimeMS > GetTime()*1000 then
            return name, nil, icon, startTimeMS, endTimeMS, nil, false, spellID
        end
    end
end


local Passthrough = function(self, event, unit, ...)
    if unit == "player" or UnitIsUnit(unit, "player") then
        callbacks:Fire(event, unit, ...)
    end
end
if isBC then
    Passthrough = function(self, event, unit, ...)
        callbacks:Fire(event, unit, ...)
    end
    lib.UnitChannelInfo = function(self, ...)
        return _G.UnitChannelInfo(...)
    end
    lib.UnitCastingInfo = function(self, ...)
        return _G.UnitCastingInfo(...)
    end
end
f.UNIT_SPELLCAST_START = Passthrough
f.UNIT_SPELLCAST_DELAYED = Passthrough
f.UNIT_SPELLCAST_STOP = Passthrough
f.UNIT_SPELLCAST_FAILED = Passthrough
f.UNIT_SPELLCAST_INTERRUPTED = Passthrough
f.UNIT_SPELLCAST_CHANNEL_START = Passthrough
f.UNIT_SPELLCAST_CHANNEL_UPDATE = Passthrough
f.UNIT_SPELLCAST_CHANNEL_STOP = Passthrough
f.UNIT_SPELLCAST_SUCCEEDED = Passthrough

function callbacks.OnUsed()
    if isVanilla then
        f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        -- for unit lookup
        f:RegisterEvent("GROUP_ROSTER_UPDATE")
        f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    end

    f:RegisterEvent("UNIT_SPELLCAST_START")
    f:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    f:RegisterEvent("UNIT_SPELLCAST_STOP")
    f:RegisterEvent("UNIT_SPELLCAST_FAILED")
    f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function callbacks.OnUnused()
    f:UnregisterAllEvents()
end

talentDecreased = {
    [25311] = 0.8,    -- Corruption (while leveling)
    [17924] = 2,       -- Soul Fire
    [25307] = 0.5,      -- Shadow Bolt
    [25309] = 0.5,      -- Immolate
    [691] = 4,        -- Summon Felhunter
    [688] = 4,        -- Summon Imp
    [697] = 4,        -- Summon Voidwalker
    [712] = 4,        -- Summon Succubus

    [15208] = 1,        -- Lightning Bolt
    [10605] = 1,        -- Chain Lightning
    [25357] = 0.5,      -- Healing Wave
    [2645] = 2,       -- Ghost Wolf

    [25304] = 0.5,      -- Frostbolt
    [25306] = 0.5,      -- Fireball

    [10934] = 0.5,      -- Smite
    [15261] = 0.5,    -- Holy Fire
    [6064] = 0.5,     -- Heal
    [25314] = 0.5,    -- Greater Heal
    [10876] = 0.5,     -- Mana Burn

    [9912] = 0.5,     -- Wrath
    [25298] = 0.5,     -- Starfire
    [25297] = 0.5,     -- Healing Touch
}

classCasts = {
    [25311] = 2, -- Corruption
    [6215] = 1.5, -- Fear
    [17928] = 2, -- Howl of Terror
    [18647] = 1.5, -- Banish
    [6366] = 3, -- Create Firestone (Lesser)
    [17951] = 3, -- Create Firestone
    [17952] = 3, -- Create Firestone (Greater)
    [17953] = 3, -- Create Firestone (Major)
    [28023] = 3, -- Create Healthstone
    [11729] = 3, -- Create Healthstone (Greater)
    [6202] = 3, -- Create Healthstone (Lesser)
    [11730] = 3, -- Create Healthstone (Major)
    [6201] = 3, -- Create Healthstone (Minor)
    [20755] = 3, -- Create Soulstone
    [20756] = 3, -- Create Soulstone (Greater)
    [20752] = 3, -- Create Soulstone (Lesser)
    [20757] = 3, -- Create Soulstone (Major)
    [693] = 3, -- Create Soulstone (Minor)
    [2362] = 5, -- Create Spellstone
    [17727] = 5, -- Create Spellstone (Greater)
    [17728] = 5, -- Create Spellstone (Major)
    [11726] = 3, -- Enslave Demon
    [126] = 5, -- Eye of Kilrogg
    [1122] = 2, -- Inferno
    [23161] = 3, -- Summon Dreadsteed
    [5784] = 3, -- Summon Felsteed
    [691] = 10, -- Summon Felhunter
    [688] = 10, -- Summon Imp
    [697] = 10, -- Summon Voidwalker
    [712] = 10, -- Summon Succubus
    [25309] = 2, -- Immolate
    [17923] = 1.5, -- Searing Pain
    [25307] = 3, -- Shadow Bolt
    [17924] = 4, -- Soul Fire
    [6358] = 1.5, -- Seduction
    [11763] = 2, -- Firebolt (Imp)

    [9853] = 1.5, -- Entangling Roots
    [18658] = 1.5, -- Hibernate
    [9901] = 1.5, -- Soothe Animal
    [25298] = 3.5, -- Starfire
    [18960] = 10, -- Teleport: Moonglade
    [9912] = 2, -- Wrath
    [25297] = 3.5, -- Healing Touch
    [20748] = 2, -- Rebirth
    [9858] = 2, -- Regrowth

    [28612] = 3, -- Conjure Food
    [759] = 3, -- Conjure Mana Agate
    [10053] = 3, -- Conjure Mana Citrine
    [3552] = 3, -- Conjure Mana Jade
    [10054] = 3, -- Conjure Mana Ruby
    [10140] = 3, -- Conjure Water
    [12826] = 1.5, -- Polymorph
    [25306] = 3.5, -- Fireball
    [10216] = 3, -- Flamestrike
    [10207] = 1.5, -- Scorch
    [25304] = 3, -- Frostbolt
    [3561] = 10, -- Teleport: Stormwind
    [3562] = 10, -- Teleport: Ironforge
    [3563] = 10, -- Teleport: Undercity
    [3565] = 10, -- Teleport: Darnassus
    [3566] = 10, -- Teleport: Thuner Bluff
    [3567] = 10, -- Teleport: Orgrimmar
    [10059] = 10, -- Portal: Stormwind
    [11416] = 10, -- Portal: Ironforge
    [11418] = 10, -- Portal: Undercity
    [11419] = 10, -- Portal: Darnassus
    [11420] = 10, -- Portal: Thuner Bluff
    [11417] = 10, -- Portal: Orgrimmar

    [10876] = 3, -- Mana Burn
    [10955] = 1.5, -- Shackle Undead
    [10917] = 1.5, -- Flash Heal
    [25314] = 3, -- Greater Heal
    [6064] = 3, -- Heal
    [15261] = 3.5, -- Holy Fire
    [2053] = 2.5, -- Lesser Heal
    [25316] = 3, -- Prayer of Healing
    [20770] = 10, -- Resurrection
    [10934] = 2.5, -- Smite
    [10947] = 1.5, -- Mind Blast
    [10912] = 3, -- Mind Control

    [19943] = 1.5, -- Flash of Light
    [24239] = 1, -- Hammer of Wrath
    [25292] = 2.5, -- Holy Light
    [10318] = 2, -- Holy Wrath
    [20773] = 10, -- Redemption
    [23214] = 3, -- Summon Charger
    [13819] = 3, -- Summon Warhorse
    [10326] = 1.5, -- Turn Undead

    [10605] = 2.5, -- Chain Lightning
    [15208] = 3, -- Lightning Bolt
    [556] = 10, -- Astral Recall
    [6196] = 2, -- Far Sight
    [2645] = 3, -- Ghost Wolf
    [20777] = 10, -- Ancestral Spirit
    [10623] = 2.5, -- Chain Heal
    [25357] = 3, -- Healing Wave
    [10468] = 1.5, -- Lesser Healing Wave

    [1842] = 2, -- Disarm Trap
    -- missing poison creation

    [11605] = 1.5, -- Slam

    [20904] = 3, -- Aimed Shot
    [25294] = 0.5, -- Multi-Shot
    [1002] = 2, -- Eyes of the Beast
    [2641] = 5, -- Dismiss pet
    [982] = 10, -- Revive Pet
    [14327] = 1.5, -- Scare Beast

    [8690] = 10, -- Hearthstone
    [4068] = 1, -- Iron Grenade
    [19769] = 1, -- Thorium Grenade
    [20589] = 0.5, -- Escape Artist

    -- Munts do not generate SPELL_CAST_START
    -- [8394] = 3, -- Striped Frostsaber
    -- [10793] = 3, -- Striped Nightsaber
}

classChannelsByAura = {
    [746] = 6,      -- First Aid
    [20577] = 10,   -- Cannibalize
    [19305] = 6,    -- Starshards

    -- DRUID
    [17402] = 10,  -- Hurricane
    [9863] = 10,      -- Tranquility

    -- HUNTER
    [6197] = 60,     -- Eagle Eye
    [13544] = 5,     -- Mend Pet
    [1515] = 20,     -- Tame Beast
    [1002] = 60,     -- Eyes of the Beast
    [14295] = 6,     -- Volley

    [10187] = 8,     -- Blizzard
    [12051] = 8,     -- Evocation

    -- PRIEST
    [18807] = 3,    -- Mind Flay
    [2096] = 60,    -- Mind Vision
    [10912] = 3,    -- Mind Control

    -- WARLOCK
    [126] = 45,       -- Eye of Kilrogg
    [11700] = 5,    -- Drain Life
    [11704] = 5,    -- Drain Mana
    [11675] = 15,   -- Drain Soul
    [11678] = 8,    -- Rain of Fire
    [11684] = 15,     -- Hellfire
    [11695] = 10,     -- Health Funnel
    [6358] = 15,    -- Seduction
    [17854] = 10,   -- Consume Shadows (Voidwalker)
}

classChannelsByCast = {
    [13278] = 4,    -- Gnomish Death Ray

    -- MAGE
    [25345] = 5,     -- Arcane Missiles
}


for id in pairs(classCasts) do
    spellNameToID[GetSpellInfo(id)] = id
end
for id in pairs(classChannelsByAura) do
    spellNameToID[GetSpellInfo(id)] = id
end
for id in pairs(classChannelsByCast) do
    spellNameToID[GetSpellInfo(id)] = id
end

local partyGUIDtoUnit = {}
local raidGUIDtoUnit = {}
local nameplateGUIDtoUnit = {}
local commonUnits = {
    -- "player",
    "target",
    "targettarget",
    "pet",
}

function f:NAME_PLATE_UNIT_ADDED(event, unit)
    local unitGUID = UnitGUID(unit)
    nameplateGUIDtoUnit[unitGUID] = unit
end


function f:NAME_PLATE_UNIT_REMOVED(event, unit)
    local unitGUID = UnitGUID(unit) -- Unit still exists at this point
    nameplateGUIDtoUnit[unitGUID] = nil
end

function f:GROUP_ROSTER_UPDATE()
    table.wipe(partyGUIDtoUnit)
    table.wipe(raidGUIDtoUnit)
    if IsInGroup() then
        for i=1,4 do
            local unit = "party"..i
            local guid = UnitGUID(unit)
            if guid then
                partyGUIDtoUnit[guid] = unit
            end
        end
    end
    if IsInRaid() then
        for i=1,40 do
            local unit = "raid"..i
            local guid = UnitGUID(unit)
            if guid then
                raidGUIDtoUnit[guid] = unit
            end
        end
    end
end

FireToUnits = function(event, guid, ...)
    for _, unit in ipairs(commonUnits) do
        if UnitGUID(unit) == guid then
            callbacks:Fire(event, unit, ...)
        end
    end

    local partyUnit = partyGUIDtoUnit[guid]
    if partyUnit then
        callbacks:Fire(event, partyUnit, ...)
    end

    local raidUnit = raidGUIDtoUnit[guid]
    if raidUnit then
        callbacks:Fire(event, raidUnit, ...)
    end

    local nameplateUnit = nameplateGUIDtoUnit[guid]
    if nameplateUnit then
        callbacks:Fire(event, nameplateUnit, ...)
    end
end

crowdControlAuras = { -- from ClassicCastbars
    [GetSpellInfo(5211)] = true,       -- Bash
    [GetSpellInfo(24394)] = true,      -- Intimidation
    [GetSpellInfo(853)] = true,        -- Hammer of Justice
    [GetSpellInfo(22703)] = true,      -- Inferno Effect (Summon Infernal)
    [GetSpellInfo(408)] = true,        -- Kidney Shot
    [GetSpellInfo(12809)] = true,      -- Concussion Blow
    [GetSpellInfo(20253)] = true,      -- Intercept Stun
    [GetSpellInfo(20549)] = true,      -- War Stomp
    [GetSpellInfo(2637)] = true,       -- Hibernate
    [GetSpellInfo(3355)] = true,       -- Freezing Trap
    [GetSpellInfo(19386)] = true,      -- Wyvern Sting
    [GetSpellInfo(118)] = true,        -- Polymorph
    [GetSpellInfo(28271)] = true,      -- Polymorph: Turtle
    [GetSpellInfo(28272)] = true,      -- Polymorph: Pig
    [GetSpellInfo(20066)] = true,      -- Repentance
    [GetSpellInfo(1776)] = true,       -- Gouge
    [GetSpellInfo(6770)] = true,       -- Sap
    [GetSpellInfo(1513)] = true,       -- Scare Beast
    [GetSpellInfo(8122)] = true,       -- Psychic Scream
    [GetSpellInfo(2094)] = true,       -- Blind
    [GetSpellInfo(5782)] = true,       -- Fear
    [GetSpellInfo(5484)] = true,       -- Howl of Terror
    [GetSpellInfo(6358)] = true,       -- Seduction
    [GetSpellInfo(5246)] = true,       -- Intimidating Shout
    [GetSpellInfo(6789)] = true,       -- Death Coil
    [GetSpellInfo(9005)] = true,       -- Pounce
    [GetSpellInfo(1833)] = true,       -- Cheap Shot
    [GetSpellInfo(16922)] = true,      -- Improved Starfire
    [GetSpellInfo(19410)] = true,      -- Improved Concussive Shot
    [GetSpellInfo(12355)] = true,      -- Impact
    [GetSpellInfo(20170)] = true,      -- Seal of Justice Stun
    [GetSpellInfo(15269)] = true,      -- Blackout
    [GetSpellInfo(18093)] = true,      -- Pyroclasm
    [GetSpellInfo(12798)] = true,      -- Revenge Stun
    [GetSpellInfo(5530)] = true,       -- Mace Stun
    [GetSpellInfo(19503)] = true,      -- Scatter Shot
    [GetSpellInfo(605)] = true,        -- Mind Control
    [GetSpellInfo(7922)] = true,       -- Charge Stun
    [GetSpellInfo(18469)] = true,      -- Counterspell - Silenced
    [GetSpellInfo(15487)] = true,      -- Silence
    [GetSpellInfo(18425)] = true,      -- Kick - Silenced
    [GetSpellInfo(24259)] = true,      -- Spell Lock
    [GetSpellInfo(18498)] = true,      -- Shield Bash - Silenced

    -- ITEMS
    [GetSpellInfo(13327)] = true,      -- Reckless Charge
    [GetSpellInfo(1090)] = true,       -- Sleep
    [GetSpellInfo(5134)] = true,       -- Flash Bomb Fear
    [GetSpellInfo(19821)] = true,      -- Arcane Bomb Silence
    [GetSpellInfo(4068)] = true,       -- Iron Grenade
    [GetSpellInfo(19769)] = true,      -- Thorium Grenade
    [GetSpellInfo(13808)] = true,      -- M73 Frag Grenade
    [GetSpellInfo(4069)] = true,       -- Big Iron Bomb
    [GetSpellInfo(12543)] = true,      -- Hi-Explosive Bomb
    [GetSpellInfo(4064)] = true,       -- Rough Copper Bomb
    [GetSpellInfo(12421)] = true,      -- Mithril Frag Bomb
    [GetSpellInfo(19784)] = true,      -- Dark Iron Bomb
    [GetSpellInfo(4067)] = true,       -- Big Bronze Bomb
    [GetSpellInfo(4066)] = true,       -- Small Bronze Bomb
    [GetSpellInfo(4065)] = true,       -- Large Copper Bomb
    [GetSpellInfo(13237)] = true,      -- Goblin Mortar
    [GetSpellInfo(835)] = true,        -- Tidal Charm
    [GetSpellInfo(13181)] = true,      -- Gnomish Mind Control Cap
    [GetSpellInfo(12562)] = true,      -- The Big One
    [GetSpellInfo(15283)] = true,      -- Stunning Blow (Weapon Proc)
    [GetSpellInfo(56)] = true,         -- Stun (Weapon Proc)
    [GetSpellInfo(26108)] = true,      -- Glimpse of Madness
}

------------------------------
-- Cast Interruption Checker
------------------------------

-- There's an issue that if you start a cast and immediately after cancel it, CAST_FAILED event won't ever come for it
-- This leads to zombie casts that have to run until completion
-- So for 4s after non-friendly player controlled guid started a cast we're watching if it's moving and cancel

do
    local GetUnitForFreshGUID = function(guid)
        local targetGUID = UnitGUID('target')
        if guid == targetGUID then
            return "target"
        end

        return nameplateGUIDtoUnit[guid]
    end

    f:SetScript("OnUpdate", function(self, elapsed)
        local guid, timeout = next(movecheckGUIDs)
        while guid ~= nil do
            -- Removing while iterating here, but it doesn't matter

            local timeStart = MOVECHECK_TIMEOUT - timeout
            if timeStart > 0.25 then
                local unit = GetUnitForFreshGUID(guid)
                if unit then
                    if GetUnitSpeed(unit) ~= 0 then
                        CastStop(guid, nil, "INTERRUPTED")
                        movecheckGUIDs[guid] = nil
                        return
                    end
                end
            end

            movecheckGUIDs[guid] = timeout - elapsed
            if timeout - elapsed < 0 then
                movecheckGUIDs[guid] = nil
            end
            -- print(guid, movecheckGUIDs[guid])

            guid, timeout = next(movecheckGUIDs, guid)
        end
    end)
end

------------------------------

if lib.NPCSpellsTimer then
    lib.NPCSpellsTimer:Cancel()
end

local prevID
local counter = 0
local function processNPCSpellTable()
    counter = 0
    local index, id = next(NPCSpells, prevID)
    while (id and counter < 150) do
        local spellName = GetSpellInfo(id)
        if spellName then
            NPCspellNameToID[spellName] = id
        end

        counter = counter + 1
        prevID = index
        index, id = next(NPCSpells, prevID)
    end
    if (id) then
        C_Timer.After(1, processNPCSpellTable)
    end
end
if isVanilla then
    lib.NPCSpellsTimer = C_Timer.NewTimer(6.5, processNPCSpellTable)
end

NPCSpells = {
    10215,
    16587,
    16651,
    20874,
    16971,
    10695,
    7428,
    30152,
    7588,
    15238,
    11399,
    11431,
    7828,
    23242,
    7892,
    15910,
    8004,
    11975,
    16102,
    12039,
    12071,
    12167,
    20299,
    20427,
    513,
    16588,
    4165,
    20811,
    20875,
    25034,
    529,
    21067,
    21131,
    8552,
    8712,
    547,
    8776,
    555,
    8936,
    569,
    9224,
    4629,
    581,
    585,
    587,
    591,
    2371,
    13607,
    2387,
    2395,
    9672,
    27658,
    27722,
    13895,
    9928,
    4981,
    19980,
    14119,
    635,
    2547,
    639,
    10248,
    2579,
    647,
    5189,
    20876,
    16973,
    2667,
    17293,
    10792,
    17613,
    2739,
    11016,
    11048,
    693,
    15207,
    697,
    2795,
    5605,
    18445,
    707,
    2835,
    711,
    11400,
    22924,
    5781,
    23308,
    15783,
    735,
    27659,
    23628,
    19725,
    16071,
    19981,
    12072,
    28299,
    759,
    3067,
    3075,
    3083,
    3091,
    16590,
    6213,
    3115,
    8489,
    25292,
    8617,
    17294,
    8681,
    6405,
    6421,
    8809,
    6469,
    8873,
    8905,
    6517,
    3275,
    26444,
    3323,
    3331,
    837,
    6725,
    13480,
    6757,
    3387,
    9481,
    9513,
    13640,
    855,
    857,
    3443,
    6917,
    867,
    6949,
    3491,
    3507,
    9961,
    9993,
    24141,
    7077,
    3563,
    895,
    7221,
    16655,
    3635,
    25037,
    913,
    915,
    25357,
    17231,
    10697,
    10793,
    939,
    15048,
    943,
    11017,
    15208,
    26381,
    26445,
    11209,
    959,
    3843,
    3851,
    3859,
    22798,
    11433,
    18831,
    15592,
    7861,
    23310,
    7893,
    27725,
    8005,
    16072,
    12073,
    4067,
    20431,
    1026,
    16528,
    16656,
    8362,
    16784,
    12521,
    1062,
    8618,
    12745,
    8682,
    1090,
    1094,
    1098,
    1106,
    30093,
    8938,
    1122,
    9002,
    13225,
    22415,
    18448,
    18576,
    22799,
    22991,
    9482,
    23247,
    4950,
    24399,
    5110,
    5174,
    16657,
    20816,
    29134,
    5270,
    17169,
    10698,
    25807,
    17745,
    15049,
    26063,
    11082,
    15241,
    15305,
    22480,
    18449,
    11338,
    15497,
    5782,
    1450,
    23248,
    23312,
    15785,
    23632,
    12074,
    24208,
    20433,
    16402,
    16594,
    16658,
    8363,
    8395,
    12522,
    6278,
    16978,
    6310,
    6358,
    6422,
    17618,
    6470,
    6518,
    9003,
    13226,
    6630,
    13322,
    13482,
    6758,
    9483,
    13642,
    23249,
    23313,
    9739,
    9771,
    6950,
    19666,
    6982,
    9931,
    9995,
    14122,
    10059,
    20434,
    16531,
    10347,
    16659,
    24913,
    25297,
    1842,
    17235,
    10699,
    10795,
    10955,
    15114,
    15242,
    7638,
    18451,
    11339,
    15498,
    15530,
    7782,
    23250,
    11659,
    23442,
    19667,
    2006,
    2010,
    12075,
    8102,
    24274,
    20435,
    2052,
    2060,
    20627,
    16596,
    16660,
    8364,
    12491,
    12523,
    16980,
    25298,
    21331,
    12747,
    8780,
    8812,
    8940,
    9004,
    13227,
    13323,
    13419,
    22867,
    9484,
    23187,
    2396,
    9612,
    13899,
    13931,
    19860,
    9964,
    28242,
    28306,
    24275,
    2540,
    2548,
    14379,
    5159,
    10348,
    16661,
    16725,
    2660,
    2668,
    10700,
    10796,
    2740,
    2812,
    18453,
    11340,
    2860,
    15659,
    2908,
    11660,
    23508,
    2948,
    15915,
    19669,
    16075,
    12044,
    12076,
    3068,
    3084,
    3092,
    6199,
    6215,
    8365,
    12492,
    3132,
    3140,
    29331,
    12684,
    21397,
    8717,
    25748,
    6471,
    6487,
    8941,
    6535,
    3276,
    3292,
    13228,
    6631,
    3324,
    3332,
    22677,
    3356,
    3364,
    3372,
    13548,
    9485,
    13612,
    13644,
    3420,
    9613,
    3436,
    23509,
    13836,
    13868,
    6951,
    27860,
    3492,
    9901,
    9933,
    9997,
    28244,
    7079,
    3564,
    14380,
    20630,
    7223,
    16663,
    20822,
    3636,
    3644,
    3652,
    16983,
    29332,
    10605,
    7383,
    10701,
    10733,
    17559,
    3748,
    26069,
    11021,
    11085,
    18199,
    7639,
    7655,
    3844,
    3852,
    3860,
    3868,
    7751,
    22870,
    7799,
    7863,
    11661,
    11725,
    23510,
    23638,
    15980,
    19863,
    12045,
    8087,
    8103,
    4068,
    16,
    16408,
    8238,
    16600,
    16664,
    16728,
    8398,
    12525,
    16984,
    21143,
    12653,
    8686,
    17496,
    17560,
    8814,
    26006,
    26070,
    26134,
    4520,
    13229,
    18392,
    18456,
    18584,
    13421,
    13485,
    22999,
    23063,
    9614,
    23639,
    13901,
    13933,
    27990,
    19864,
    9966,
    20312,
    16409,
    20568,
    10318,
    5176,
    16665,
    16729,
    16985,
    21144,
    10702,
    10798,
    17561,
    21848,
    26071,
    15117,
    22168,
    15245,
    18457,
    11342,
    22744,
    15533,
    23000,
    11534,
    5784,
    27287,
    11726,
    15853,
    11790,
    19865,
    24024,
    12046,
    12078,
    28311,
    20313,
    20377,
    16410,
    16730,
    8399,
    12526,
    25112,
    16986,
    29335,
    25304,
    8687,
    17434,
    25688,
    17562,
    21913,
    26072,
    18138,
    13230,
    13262,
    6648,
    18458,
    6728,
    22937,
    13582,
    13646,
    27608,
    9743,
    27992,
    9935,
    20314,
    20378,
    7224,
    16667,
    16731,
    16795,
    7288,
    16987,
    10703,
    17435,
    10799,
    17563,
    17883,
    15118,
    11343,
    7752,
    15534,
    22938,
    7800,
    15662,
    7896,
    7928,
    7960,
    15982,
    8008,
    19867,
    12047,
    12079,
    8104,
    20315,
    20379,
    2053,
    2061,
    8272,
    4153,
    20763,
    16732,
    8400,
    16988,
    12655,
    17180,
    21403,
    8688,
    17564,
    21787,
    8880,
    17820,
    9200,
    9232,
    13519,
    9456,
    13583,
    2389,
    2397,
    9616,
    19484,
    13935,
    19868,
    9968,
    24091,
    10096,
    2541,
    2549,
    16413,
    5161,
    5177,
    20764,
    5273,
    2645,
    25307,
    2661,
    10704,
    10768,
    5401,
    17565,
    2741,
    11024,
    18205,
    2837,
    15535,
    11568,
    27291,
    2941,
    3013,
    6041,
    20317,
    20381,
    16367,
    8209,
    3085,
    3093,
    6201,
    3109,
    3117,
    16798,
    12528,
    8465,
    16990,
    12624,
    8593,
    3205,
    17566,
    3229,
    3237,
    6521,
    17950,
    3277,
    3293,
    3325,
    3333,
    22749,
    22813,
    3373,
    6777,
    9489,
    13648,
    3421,
    3429,
    6905,
    3477,
    3493,
    3501,
    9937,
    10001,
    7081,
    20318,
    20382,
    16415,
    3605,
    20702,
    20830,
    16799,
    7289,
    16991,
    25309,
    10673,
    10705,
    17503,
    17567,
    7481,
    10961,
    17951,
    7641,
    22430,
    18399,
    3845,
    3861,
    15472,
    7753,
    15536,
    7801,
    7817,
    15664,
    15728,
    11665,
    15792,
    11729,
    15856,
    11921,
    11985,
    12049,
    12081,
    8105,
    4061,
    4069,
    20319,
    16336,
    24670,
    20831,
    8402,
    66,
    16992,
    8690,
    8786,
    17952,
    4506,
    18656,
    1179,
    13617,
    13745,
    13841,
    13905,
    13937,
    4954,
    14033,
    9970,
    20320,
    20384,
    10258,
    10322,
    5178,
    25055,
    16993,
    25311,
    10674,
    10706,
    17505,
    30046,
    15057,
    30174,
    17953,
    18081,
    1403,
    18401,
    18657,
    11410,
    15537,
    11538,
    15665,
    1451,
    23392,
    11730,
    11762,
    27871,
    11922,
    16081,
    12050,
    12082,
    20321,
    20385,
    16418,
    8275,
    6202,
    12466,
    20897,
    16866,
    12562,
    16994,
    8595,
    8691,
    17506,
    6490,
    18082,
    18402,
    26656,
    18658,
    13522,
    6778,
    13746,
    9811,
    9875,
    14034,
    10003,
    7098,
    28448,
    20322,
    20386,
    7162,
    16419,
    113,
    20770,
    10451,
    16995,
    17187,
    10675,
    10707,
    116,
    7434,
    25953,
    10963,
    118,
    18211,
    22434,
    18403,
    7754,
    11443,
    7786,
    7802,
    7818,
    15730,
    11667,
    15794,
    11763,
    7962,
    7978,
    7994,
    11923,
    16082,
    126,
    12083,
    8106,
    8138,
    20323,
    12243,
    2054,
    20707,
    16868,
    21027,
    133,
    8532,
    134,
    8596,
    12883,
    8820,
    25954,
    8980,
    4539,
    143,
    18404,
    145,
    18596,
    22883,
    22947,
    2366,
    2406,
    13939,
    9876,
    4971,
    9972,
    2542,
    20388,
    10228,
    10324,
    5179,
    5195,
    14515,
    10452,
    16869,
    5275,
    2662,
    10676,
    10708,
    5403,
    21668,
    10964,
    172,
    18149,
    26403,
    5627,
    2838,
    11444,
    2878,
    11604,
    11668,
    184,
    23652,
    11892,
    19877,
    19941,
    12052,
    12084,
    20389,
    3070,
    24612,
    8245,
    8277,
    3110,
    12468,
    20901,
    25124,
    25316,
    8693,
    3206,
    17510,
    8789,
    8949,
    205,
    18086,
    3294,
    18214,
    22373,
    6635,
    3326,
    3334,
    22757,
    13524,
    9461,
    3398,
    13620,
    13748,
    23461,
    6907,
    23653,
    9813,
    3494,
    3502,
    19942,
    10005,
    20326,
    14292,
    3606,
    20902,
    25125,
    7355,
    10677,
    10709,
    3718,
    14900,
    10837,
    10869,
    3750,
    10933,
    10965,
    26085,
    15124,
    7643,
    18407,
    22566,
    3854,
    3862,
    7739,
    7755,
    7771,
    15668,
    11605,
    7867,
    7931,
    11829,
    16084,
    19943,
    12053,
    12085,
    4054,
    4062,
    8139,
    20327,
    16340,
    4094,
    8246,
    16552,
    8342,
    16744,
    8406,
    25126,
    21159,
    8598,
    271,
    8694,
    8758,
    25958,
    8950,
    18088,
    13237,
    18408,
    22567,
    22695,
    22759,
    13653,
    9654,
    9750,
    9814,
    13941,
    19816,
    9942,
    9974,
    20008,
    24359,
    10166,
    14293,
    10326,
    5180,
    5196,
    16745,
    20904,
    25127,
    5276,
    331,
    332,
    10678,
    10710,
    21544,
    339,
    21736,
    10934,
    5484,
    26087,
    15125,
    18089,
    348,
    18217,
    18409,
    5676,
    15797,
    5884,
    23592,
    16053,
    20009,
    12086,
    6060,
    20201,
    20329,
    20393,
    24680,
    16554,
    20777,
    16746,
    6252,
    25128,
    21097,
    21161,
    17194,
    6412,
    25704,
    403,
    25960,
    8951,
    22313,
    9143,
    18410,
    22761,
    421,
    6780,
    13622,
    9591,
    19434,
    13846,
    13878,
    9879,
    10007,
    7068,
    7084,
    7132,
    20394,
    14326,
    20714,
    10391,
    455,
    29160,
    457,
    458,
    459,
    17195,
    10679,
    10711,
    7420,
    7484,
    17707,
    470,
    471,
    472,
    474,
    15254,
    18411,
    11479,
    27241,
    491,
    15734,
    11671,
    19435,
    7948,
    11895,
    19755,
    12055,
    12087,
    507,
    12151,
    509,
    20395,
    12279,
    2055,
    4141,
    12471,
    8408,
    4221,
    25130,
    21099,
    536,
    8600,
    25514,
    8760,
    17708,
    556,
    21931,
    26218,
    18412,
    578,
    18540,
    13399,
    13463,
    18796,
    13527,
    23083,
    596,
    598,
    13687,
    23339,
    606,
    13815,
    13943,
    9912,
    14103,
    2543,
    20396,
    14327,
    16429,
    2575,
    10328,
    20716,
    10392,
    5213,
    2663,
    10680,
    10712,
    17453,
    10840,
    17709,
    25963,
    686,
    15095,
    690,
    692,
    698,
    700,
    18413,
    2823,
    18541,
    710,
    712,
    11416,
    11480,
    18989,
    724,
    11672,
    15799,
    15863,
    2951,
    19821,
    3007,
    12056,
    12088,
    16247,
    12248,
    12280,
    3079,
    3087,
    3095,
    20717,
    25004,
    29163,
    3143,
    3207,
    8793,
    6461,
    25964,
    3263,
    818,
    9081,
    6637,
    6653,
    3335,
    6717,
    13464,
    13528,
    18990,
    9657,
    6909,
    6925,
    19566,
    6957,
    3495,
    14008,
    3511,
    10009,
    20078,
    7101,
    20270,
    3567,
    20398,
    3583,
    3607,
    7277,
    3655,
    10681,
    10713,
    7421,
    930,
    932,
    10841,
    10873,
    25965,
    10969,
    15128,
    18159,
    7629,
    7645,
    18351,
    18415,
    3847,
    3855,
    3863,
    968,
    11417,
    7821,
    7853,
    984,
    7901,
    990,
    7949,
    996,
    1002,
    16056,
    19887,
    20015,
    12089,
    4055,
    28461,
    20399,
    8282,
    24942,
    12505,
    12537,
    29229,
    1064,
    25262,
    4286,
    1084,
    1088,
    12825,
    8762,
    8858,
    1112,
    21935,
    1124,
    22127,
    4526,
    18416,
    13529,
    18992,
    13657,
    13689,
    9658,
    13817,
    23663,
    9818,
    13945,
    4974,
    20016,
    28270,
    24239,
    10138,
    28526,
    20400,
    16497,
    16561,
    20720,
    20848,
    5262,
    17009,
    25263,
    17137,
    10682,
    10714,
    17393,
    10842,
    10874,
    25967,
    18417,
    18609,
    11418,
    23088,
    1452,
    11642,
    15801,
    27567,
    15865,
    11802,
    23664,
    11962,
    19889,
    20017,
    12090,
    16249,
    28463,
    20401,
    1536,
    1540,
    16498,
    8283,
    6222,
    20849,
    6254,
    6270,
    17138,
    6350,
    6366,
    21425,
    6414,
    12890,
    25968,
    6510,
    8955,
    6638,
    18418,
    22705,
    13530,
    23089,
    6814,
    6894,
    27632,
    13882,
    19890,
    9979,
    10011,
    28272,
    10139,
    20402,
    1804,
    10395,
    25073,
    17203,
    10683,
    10715,
    17459,
    7454,
    10875,
    25969,
    17843,
    26097,
    11067,
    11131,
    7630,
    1916,
    18419,
    11355,
    11419,
    27057,
    23090,
    11643,
    15802,
    7918,
    7934,
    23666,
    11899,
    16058,
    12059,
    12091,
    24242,
    16250,
    8142,
    20403,
    28785,
    16564,
    8348,
    8444,
    2120,
    21171,
    12667,
    8604,
    17460,
    8764,
    30001,
    25970,
    26098,
    8988,
    18420,
    22643,
    27058,
    2368,
    23091,
    9532,
    13659,
    13819,
    23667,
    13915,
    9852,
    9916,
    9980,
    20020,
    10140,
    2544,
    20404,
    2576,
    16565,
    16629,
    10396,
    24947,
    20916,
    17141,
    2664,
    10684,
    10716,
    17461,
    10844,
    10876,
    25971,
    15067,
    5567,
    26419,
    18421,
    2824,
    11356,
    11420,
    27059,
    15611,
    11548,
    23220,
    2912,
    11836,
    19701,
    23860,
    16059,
    12060,
    12092,
    6063,
    6127,
    3072,
    3080,
    3088,
    3096,
    6223,
    3120,
    6255,
    8445,
    17142,
    6351,
    6415,
    8797,
    6463,
    25972,
    3256,
    3264,
    9053,
    3296,
    3320,
    3328,
    6671,
    22709,
    3368,
    3376,
    3400,
    3408,
    23221,
    13692,
    27572,
    3472,
    9853,
    3496,
    3504,
    28148,
    10013,
    3552,
    10205,
    3584,
    20790,
    7279,
    7295,
    7359,
    3696,
    10717,
    7439,
    3728,
    7487,
    25973,
    15228,
    15292,
    3840,
    3848,
    3856,
    3864,
    3872,
    22902,
    7791,
    15612,
    23094,
    7855,
    7919,
    7935,
    7951,
    7967,
    27829,
    23862,
    16060,
    24054,
    20023,
    12093,
    4064,
    24374,
    20407,
    20535,
    8286,
    20791,
    12509,
    8446,
    21047,
    21175,
    8606,
    4320,
    17464,
    8766,
    25974,
    26102,
    30732,
    30156,
    30096,
    30091,
    18424,
    9472,
    30047,
    16742,
    29334,
    29333,
    13501,
    5272,
    28995,
    18153,
    28739,
    13661,
    13693,
    7489,
    8467,
    28505,
    28487,
    9758,
    28482,
    13917,
    23799,
    6297,
    4960,
    9950,
    3693,
    14109,
    20698,
    28462,
    461,
    28328,
    28305,
    10206,
    28304,
    20536,
    6651,
    28286,
    16633,
    20792,
    28271,
    28243,
    25079,
    5264,
    5280,
    28210,
    10622,
    28209,
    10686,
    10718,
    28208,
    17465,
    28207,
    28205,
    28146,
    28133,
    15037,
    28089,
    5504,
    1096,
    27891,
    18105,
    27890,
    15261,
    15293,
    27870,
    21160,
    22945,
    3243,
    11358,
    27830,
    27794,
    15549,
    27760,
    27724,
    27723,
    27721,
    23224,
    9435,
    27660,
    3503,
    27637,
    15869,
    27624,
    15933,
    27831,
    23800,
    19769,
    28023,
    27588,
    18440,
    12062,
    5186,
    6064,
    4065,
    27527,
    27106,
    27100,
    16381,
    27098,
    24696,
    16570,
    26616,
    20793,
    19851,
    4983,
    12542,
    16168,
    26437,
    26436,
    26435,
    8607,
    17274,
    12766,
    26434,
    6416,
    26433,
    8799,
    26432,
    26431,
    25976,
    21945,
    26430,
    26429,
    26407,
    9055,
    12066,
    23246,
    26298,
    24093,
    6656,
    26192,
    26103,
    26086,
    13438,
    3108,
    26055,
    16724,
    20035,
    26010,
    23161,
    23225,
    25985,
    691,
    25983,
    6896,
    13822,
    20819,
    25981,
    27832,
    23801,
    25979,
    24139,
    25183,
    9983,
    10015,
    25966,
    25962,
    25961,
    7120,
    25959,
    10207,
    25849,
    25841,
    25839,
    25808,
    25804,
    20794,
    25722,
    25664,
    25081,
    20821,
    7328,
    23316,
    10623,
    25424,
    10687,
    10719,
    16006,
    25347,
    25314,
    25306,
    7488,
    10911,
    25977,
    25181,
    25180,
    25178,
    25177,
    25162,
    15230,
    15262,
    15294,
    18363,
    25146,
    25129,
    20829,
    7728,
    22336,
    23085,
    7776,
    23391,
    25082,
    23098,
    25080,
    25078,
    25074,
    25072,
    25054,
    25052,
    27641,
    7952,
    11839,
    25030,
    8000,
    8016,
    25018,
    16094,
    24997,
    12063,
    24995,
    16969,
    24314,
    24914,
    24912,
    24903,
    24902,
    24901,
    8256,
    24801,
    24706,
    8352,
    24668,
    4209,
    12543,
    2121,
    16652,
    24418,
    24358,
    24334,
    23102,
    24209,
    24189,
    8736,
    8768,
    8800,
    24173,
    24140,
    25978,
    24138,
    10329,
    24136,
    26234,
    18108,
    24092,
    24011,
    7395,
    23954,
    5274,
    23804,
    13375,
    23803,
    13439,
    23802,
    13503,
    23787,
    2369,
    23665,
    13631,
    2393,
    13695,
    23662,
    23650,
    23637,
    19452,
    23636,
    13887,
    23633,
    9856,
    9888,
    9920,
    9952,
    23629,
    20028,
    23531,
    23530,
    6413,
    10144,
    2545,
    3336,
    10771,
    5137,
    2577,
    5169,
    5185,
    2601,
    3570,
    8153,
    25083,
    5265,
    2641,
    23381,
    23338,
    2665,
    2673,
    10720,
    17405,
    25659,
    23315,
    23314,
    10880,
    10912,
    2737,
    23309,
    5505,
    23252,
    23251,
    26299,
    23243,
    15263,
    15295,
    23241,
    15119,
    23239,
    23238,
    2841,
    15451,
    23228,
    23227,
    23223,
    5761,
    15647,
    19069,
    5809,
    15743,
    23222,
    23219,
    23214,
    23206,
    23189,
    15935,
    19645,
    15999,
    16031,
    23130,
    19862,
    20773,
    20029,
    12096,
    24252,
    23093,
    23092,
    23087,
    6129,
    3073,
    3081,
    23086,
    3097,
    3105,
    20797,
    3121,
    6257,
    25084,
    23084,
    6305,
    17086,
    23030,
    6353,
    23013,
    23012,
    22990,
    6417,
    22989,
    22949,
    3233,
    22946,
    25980,
    22909,
    22876,
    22869,
    22868,
    22866,
    3297,
    18238,
    22796,
    3321,
    22790,
    3337,
    18166,
    22717,
    13440,
    22750,
    6753,
    13536,
    9473,
    22724,
    9744,
    23229,
    3513,
    20405,
    7448,
    6897,
    22718,
    22710,
    22686,
    22678,
    13952,
    9889,
    3505,
    19902,
    9985,
    7057,
    3537,
    22665,
    22662,
    7121,
    22661,
    22651,
    22539,
    22478,
    22458,
    22425,
    16639,
    22421,
    22414,
    22357,
    25085,
    3657,
    22334,
    22275,
    22167,
    13900,
    3697,
    10721,
    22048,
    21971,
    7457,
    10849,
    10881,
    17727,
    15040,
    8791,
    17919,
    16080,
    3695,
    18111,
    15232,
    18239,
    15296,
    21807,
    18431,
    3849,
    3857,
    7729,
    7745,
    7761,
    21667,
    7793,
    21565,
    15648,
    21559,
    7857,
    21549,
    21402,
    21369,
    19391,
    21367,
    5514,
    21162,
    27837,
    21096,
    19775,
    21073,
    12001,
    21072,
    20031,
    21071,
    21068,
    8129,
    21066,
    19774,
    21048,
    20903,
    20543,
    4130,
    20900,
    16640,
    20890,
    10696,
    16083,
    25086,
    16960,
    20827,
    20826,
    20825,
    20824,
    12737,
    8674,
    20823,
    25662,
    8770,
    8802,
    20820,
    17728,
    25982,
    20817,
    17920,
    8994,
    20815,
    18112,
    20813,
    18240,
    15859,
    5188,
    17509,
    3210,
    18560,
    22719,
    6576,
    3694,
    20787,
    20776,
    9474,
    23103,
    20772,
    20765,
    20762,
    20757,
    20756,
    20755,
    20752,
    13857,
    20748,
    20747,
    9858,
    20742,
    4962,
    9954,
    9986,
    20032,
    5026,
    20739,
    20733,
    28478,
    20696,
    5106,
    20695,
    20692,
    20685,
    16965,
    16641,
    20800,
    20669,
    10466,
    20665,
    5266,
    20657,
    20656,
    20629,
    20626,
    20012,
    20609,
    20604,
    17473,
    20565,
    10850,
    2672,
    20432,
    10946,
    20430,
    17921,
    20429,
    1385,
    20428,
    20426,
    15265,
    11202,
    18617,
    20408,
    20406,
    5666,
    22720,
    20397,
    20392,
    20391,
    15585,
    20390,
    20387,
    20383,
    1453,
    3065,
    3069,
    5669,
    8366,
    3133,
    18439,
    6296,
    11986,
    14106,
    16033,
    17140,
    6352,
    15267,
    20033,
    1513,
    10685,
    20324,
    8782,
    19859,
    12258,
    24576,
    16450,
    8259,
    20316,
    16642,
    20801,
    6632,
    11341,
    6274,
    8483,
    6306,
    11357,
    16597,
    3361,
    13321,
    3377,
    20296,
    6418,
    17196,
    3397,
    13628,
    20051,
    25984,
    26048,
    17922,
    20014,
    15979,
    13948,
    3497,
    18242,
    6626,
    4961,
    18434,
    11981,
    6690,
    22721,
    13442,
    12061,
    18818,
    13538,
    12077,
    20030,
    20026,
    20025,
    13698,
    3565,
    20024,
    13794,
    19750,
    13858,
    13890,
    10254,
    16502,
    16662,
    3658,
    8367,
    9987,
    20034,
    14146,
    28352,
    7106,
    28480,
    10179,
    20006,
    7408,
    20013,
    20610,
    17462,
    16643,
    20802,
    10435,
    10467,
    3729,
    3733,
    468,
    20011,
    20010,
    3506,
    1849,
    19982,
    7426,
    10787,
    14914,
    17229,
    7648,
    10915,
    10947,
    21954,
    17923,
    8368,
    19970,
    3841,
    15234,
    15266,
    19968,
    3869,
    18435,
    3873,
    14807,
    22722,
    9487,
    19940,
    19939,
    15586,
    7992,
    23106,
    19874,
    8040,
    19873,
    8088,
    19866,
    27585,
    18327,
    15906,
    512,
    15970,
    18163,
    2005,
    19861,
    16098,
    19971,
    12067,
    15253,
    19848,
    14621,
    28481,
    17273,
    12259,
    2050,
    18438,
    4131,
    8292,
    12419,
    8356,
    6620,
    548,
    8784,
    21059,
    19772,
    8912,
    12675,
    19668,
    12739,
    579,
    580,
    15453,
    8772,
    8804,
    16601,
    10688,
    30081,
    9488,
    17924,
    2386,
    9552,
    18960,
    9092,
    13219,
    17450,
    605,
    9220,
    18500,
    18564,
    22723,
    12064,
    17454,
    18991,
    2362,
    2538,
    2546,
    13635,
    2394,
    18702,
    9636,
    2738,
    27586,
    18763,
    2742,
    18809,
    8401,
    23811,
    18647,
    18241,
    9956,
    19972,
    20036,
    2670,
    1056,
    18444,
    10148,
    10180,
    20420,
    20484,
    28738,
    2578,
    10340,
    16645,
    2602,
    10436,
    10468,
    688,
    5267,
    5506,
    21188,
    17157,
    2666,
    2674,
    695,
    7633,
    5395,
    701,
    17501,
    705,
    10916,
    15043,
    7769,
    18455,
    7865,
    18454,
    18452,
    18450,
    18245,
    7929,
    18447,
    18437,
    18446,
    9857,
    18629,
    5699,
    9921,
    3018,
    15587,
    5763,
    8089,
    7788,
    8137,
    10145,
    15779,
    23428,
    27587,
    3066,
    3074,
    16412,
    14847,
    3086,
    3094,
    19845,
    16099,
    19973,
    12068,
    18436,
    10945,
    18423,
    18422,
    8010,
    12260,
    16390,
    3082,
    3090,
    8293,
    16646,
    20805,
    29059,
    5208,
    18414,
    3146,
    6530,
    3278,
    17158,
    8613,
    12740,
    8677,
    18405,
    6419,
    6650,
    3330,
    877,
    14053,
    8901,
    13028,
    849,
    8090,
    18244,
    18243,
    6898,
    18246,
    6627,
    15855,
    9221,
    18502,
    13380,
    18630,
    22789,
    3370,
    6755,
    4979,
    12065,
    885,
    3562,
    9573,
    13700,
    3566,
    23429,
    6899,
    20380,
    13860,
    7322,
    8211,
    5187,
    3498,
    19846,
    9957,
    19974,
    5219,
    10053,
    8435,
    3722,
    10149,
    10181,
    28612,
    3586,
    28740,
    1050,
    20678,
    16647,
    20806,
    14532,
    928,
    3650,
    16967,
    15264,
    2539,
    1042,
    3690,
    17287,
    3866,
    3870,
    10789,
    3561,
    7794,
    3064,
    10917,
    982,
    17639,
    9795,
    597,
    1004,
    9939,
    26373,
    18247,
    12098,
    4066,
    3842,
    3850,
    3858,
    11365,
    11397,
    17463,
    7779,
    7795,
    17458,
    7827,
    17456,
    7859,
    17455,
    15780,
    23430,
    27589,
    19463,
    6499,
    19903,
    15972,
    17290,
    15575,
    19847,
    24006,
    19975,
    12069,
    28293,
    17204,
    8131,
    20295,
    13378,
    17181,
    12824,
    16997,
    4132,
    20297,
    4164,
    20807,
    24966,
    8422,
    12549,
    3515,
    19886,
    2671,
    2675,
    7443,
    7451,
    16788,
    7483,
    16783,
    8774,
    8806,
    1366,
    30021,
    16726,
    26054,
    17928,
    7418,
    16654,
    16653,
    1464,
    26438,
    16648,
    18376,
    9222,
    16644,
    11988,
    3015,
    16599,
    10165,
    16598,
    1538,
    13626,
    12826,
    13637,
    9574,
    16533,
    3211,
    23431,
    27590,
    9734,
    6500,
    13140,
    3295,
    13220,
    19784,
    9926,
    4980,
    3319,
    16055,
    10054,
    3359,
    3363,
    10150,
    3371,
    16741,
    3611,
    1698,
    3399,
    20680,
    16649,
    20808,
    20872,
    25031,
    5252,
    5268,
    7124,
    3071,
    25351,
    8407,
    7437,
    1980,
    3651,
    17481,
    5269,
    10854,
    15861,
    21832,
    10790,
    21960,
    16396,
    22088,
    8778,
    3815,
    18406,
    26439,
    3871,
    7748,
    18441,
    15596,
    5668,
    11366,
    15493,
    15495,
    2008,
    6741,
    8092,
    15653,
    10151,
    23240,
    15050,
    15781,
    23432,
    14887,
    14871,
    14810,
    6501,
    15973,
    14809,
    14200,
    19849,
    16101,
    13947,
    12070,
    13912,
    2392,
    7054,
    12198,
    13898,
    2480,
    13663,
    7213,
    13655,
    6196,
    16650,
    7389,
    20873,
    8423,
    9918,
    16970,
    18442,
    2840,
    17162,
    12524,
    12742,
    8679,
    12421,
    9945,
    3016,
    12199,
    9820,
    17738,
    8903,
    26056,
    3116,
    8394,
    12080,
    3204,
    9095,
    26440,
    8986,
    12058,
    9223,
    12048,
    6692,
    11963,
    6766,
    3396,
    6918,
    3488,
    3500,
    3508,
    11993,
    9575,
    13702,
    7078,
    7222,
    8331,
    6654,
    27720,
    10960,
    8795,
    8939,
    10788,
    7766,
    9959,
    15800,
    24137,
    7076,
    10216,
    6639,
    20298,
    2637,
    15066,
}
