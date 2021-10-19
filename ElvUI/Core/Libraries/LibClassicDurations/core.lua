--[================[
LibClassicDurations
Author: d87
Description: Tracks all aura applications in combat log and provides duration, expiration time.
And additionally enemy buffs info.

Usage example 1:
-----------------

    -- Using UnitAura wrapper
    local UnitAura = _G.UnitAura

    local LibClassicDurations = LibStub("LibClassicDurations", true)
    if LibClassicDurations then
        LibClassicDurations:Register("YourAddon")
        UnitAura = LibClassicDurations.UnitAuraWrapper
    end

--]================]
if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end

local MAJOR, MINOR = "LibClassicDurations", 69
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.frame = lib.frame or CreateFrame("Frame")

lib.guids = lib.guids or {}
lib.spells = lib.spells or {}
lib.npc_spells = lib.npc_spells or {}

lib.spellNameToID = lib.spellNameToID or {}
local spellNameToID = lib.spellNameToID

local NPCspellNameToID = {}
if lib.NPCSpellTableTimer then
    lib.NPCSpellTableTimer:Cancel()
end

lib.DRInfo = lib.DRInfo or {}
local DRInfo = lib.DRInfo

lib.buffCache = lib.buffCache or {}
local buffCache = lib.buffCache

local buffCacheValid = {}

lib.nameplateUnitMap = lib.nameplateUnitMap or {}
local nameplateUnitMap = lib.nameplateUnitMap

lib.castLog = lib.castLog or {}
local castLog = lib.castLog

lib.guidAccessTimes = lib.guidAccessTimes or {}
local guidAccessTimes = lib.guidAccessTimes

local f = lib.frame
local callbacks = lib.callbacks
local guids = lib.guids
local spells = lib.spells
local npc_spells = lib.npc_spells
local indirectRefreshSpells = lib.indirectRefreshSpells

local INFINITY = math.huge
local PURGE_INTERVAL = 900
local PURGE_THRESHOLD = 1800
local UNKNOWN_AURA_DURATION = 3600 -- 60m
local BUFF_CACHE_EXPIRATION_TIME = 40

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID
local UnitAura = UnitAura
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local tinsert = table.insert
local unpack = unpack
local GetGUIDAuraTime
local time = time

if lib.enableEnemyBuffTracking == nil then lib.enableEnemyBuffTracking = false end
local enableEnemyBuffTracking = lib.enableEnemyBuffTracking

local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER

f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

lib.dataVersions = lib.dataVersions or {}
local SpellDataVersions = lib.dataVersions

function lib:SetDataVersion(dataType, version)
    SpellDataVersions[dataType] = version
    npc_spells = lib.npc_spells
    indirectRefreshSpells = lib.indirectRefreshSpells
end

function lib:GetDataVersion(dataType)
    return SpellDataVersions[dataType] or 0
end

lib.AddAura = function(id, opts)
    if not opts then return end

    local lastRankID
    if type(id) == "table" then
        local clones = id
        lastRankID = clones[#clones]
    else
        lastRankID = id
    end

    local spellName = GetSpellInfo(lastRankID)
    if not spellName then
        -- print(MINOR, lastRankID, spellName)
        return
    end
    spellNameToID[spellName] = lastRankID

    if type(id) == "table" then
        for _, spellID in ipairs(id) do
            spells[spellID] = opts
        end
    else
        spells[id] = opts
    end
end


lib.Talent = function (...)
    for i=1, 5 do
        local spellID = select(i, ...)
        if not spellID then break end
        if IsPlayerSpell(spellID) then return i end
    end
    return 0
end

local prevID
local counter = 0
local function processNPCSpellTable()
    local dataTable = lib.npc_spells
    counter = 0
    local id = next(dataTable, prevID)
    while (id and counter < 300) do
        local spellName = GetSpellInfo(id)
        if spellName then
            NPCspellNameToID[GetSpellInfo(id)] = id
        end

        counter = counter + 1
        prevID = id
        id = next(dataTable, prevID)
    end
    if (id) then
        C_Timer.After(1, processNPCSpellTable)
    end
end
lib.NPCSpellTableTimer = C_Timer.NewTimer(10, processNPCSpellTable)


local function isHunterGUID(guid)
    return select(2, GetPlayerInfoByGUID(guid)) == "HUNTER"
end
local function isFriendlyFeigning(guid)
    if IsInRaid() then
        for i = 1, MAX_RAID_MEMBERS do
            local unitID = "raid"..i
            if (UnitGUID(unitID) == guid) and UnitIsFeignDeath(unitID) then
                return true
            end
        end
    elseif IsInGroup() then
        for i = 1, MAX_PARTY_MEMBERS do
            local unitID = "party"..i
            if (UnitGUID(unitID) == guid) and UnitIsFeignDeath(unitID) then
                return true
            end
        end
    end
end
--------------------------
-- OLD GUIDs PURGE
--------------------------

local function purgeOldGUIDsArgs(dataTable, accessTimes)
    local now = time()
    local deleted = {}
    for guid, lastAccessTime in pairs(accessTimes) do
        if lastAccessTime + PURGE_THRESHOLD < now then
            dataTable[guid] = nil
            nameplateUnitMap[guid] = nil
            buffCacheValid[guid] = nil
            buffCache[guid] = nil
            DRInfo[guid] = nil
            castLog[guid] = nil
            tinsert(deleted, guid)
        end
    end
    for _, guid in ipairs(deleted) do
        accessTimes[guid] = nil
    end
end

local function purgeOldGUIDs()
    purgeOldGUIDsArgs(guids, guidAccessTimes)
end
if lib.purgeTicker then
    lib.purgeTicker:Cancel()
end
lib.purgeTicker = C_Timer.NewTicker( PURGE_INTERVAL, purgeOldGUIDs)

------------------------------------
-- Restore data if using standalone
f:RegisterEvent("PLAYER_LOGIN")
function f:PLAYER_LOGIN()
    if LCD_Data and LCD_GUIDAccess then
        purgeOldGUIDsArgs(LCD_Data, LCD_GUIDAccess)

        local function MergeTableNoOverwrite(t1, t2)
            if not t2 then return false end
            for k,v in pairs(t2) do
                if type(v) == "table" then
                    if t1[k] == nil then
                        t1[k] = CopyTable(v)
                    else
                        MergeTableNoOverwrite(t1[k], v)
                    end
                elseif t1[k] == nil then
                    t1[k] = v
                end
            end
            return t1
        end

        local curSessionData = lib.guids
        local restoredSessionData = LCD_Data
        MergeTableNoOverwrite(curSessionData, restoredSessionData)

        local curSessionAccessTimes = lib.guidAccessTimes
        local restoredSessionAccessTimes = LCD_GUIDAccess
        MergeTableNoOverwrite(curSessionAccessTimes, restoredSessionAccessTimes)
    end

    f:RegisterEvent("PLAYER_LOGOUT")
    function f:PLAYER_LOGOUT()
        LCD_Data = guids
        LCD_GUIDAccess = guidAccessTimes
    end
end


--------------------------
-- DIMINISHING RETURNS
--------------------------
local bit_band = bit.band
local DRResetTime = 18.4
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY

local DRMultipliers = { 0.5, 0.25, 0}
local function addDRLevel(dstGUID, category)
    local guidTable = DRInfo[dstGUID]
    if not guidTable then
        DRInfo[dstGUID] = {}
        guidTable = DRInfo[dstGUID]
    end

    local catTable = guidTable[category]
    if not catTable then
        guidTable[category] = { level = 0, expires = 0}
        catTable = guidTable[category]
    end

    local now = GetTime()
    local isExpired = (catTable.expires or 0) <= now
    local oldDRLevel = catTable.level
    if isExpired or oldDRLevel >= 3 then
        catTable.level = 0
    end
    catTable.level = catTable.level + 1
    catTable.expires = now + DRResetTime
end
local function clearDRs(dstGUID)
    DRInfo[dstGUID] = nil
end
local function getDRMul(dstGUID, spellID)
    local category = lib.DR_CategoryBySpellID[spellID]
    if not category then return 1 end

    local guidTable = DRInfo[dstGUID]
    if guidTable then
        local catTable = guidTable[category]
        if catTable then
            local now = GetTime()
            local isExpired = (catTable.expires or 0) <= now
            if isExpired then
                return 1
            else
                local mul = DRMultipliers[catTable.level]
                return mul or 1
            end
        end
    end
    return 1
end

local function CountDiminishingReturns(eventType, srcGUID, srcFlags, dstGUID, dstFlags, spellID, auraType)
    if auraType == "DEBUFF" then
        if eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_REFRESH" then
            local category = lib.DR_CategoryBySpellID[spellID]
            if not category then return end

            local isDstPlayer = bit_band(dstFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
            -- local isFriendly = bit_band(dstFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0

            if not isDstPlayer then
                if not lib.DR_TypesPVE[category] then return end
            end

            addDRLevel(dstGUID, category)
        end
        if eventType == "UNIT_DIED" then
            if not isHunterGUID(dstGUID) then
                clearDRs(dstGUID)
            end
        end
    end
end

------------------------
-- COMBO POINTS
------------------------

local GetComboPoints = GetComboPoints
local _, playerClass = UnitClass("player")
local cpWas = 0
local cpNow = 0
local function GetCP()
    if not cpNow then return GetComboPoints("player", "target") end
    return cpWas > cpNow and cpWas or cpNow
end

function f:PLAYER_TARGET_CHANGED(event)
    return self:UNIT_POWER_UPDATE(event, "player", "COMBO_POINTS")
end
function f:UNIT_POWER_UPDATE(event,unit, ptype)
    if ptype == "COMBO_POINTS" then
        cpWas = cpNow
        cpNow = GetComboPoints(unit, "target")
    end
end

---------------------------
-- COMBAT LOG
---------------------------

local function cleanDuration(duration, spellID, srcGUID, comboPoints)
    if type(duration) == "function" then
        local isSrcPlayer = srcGUID == UnitGUID("player")
        -- Passing startTime for the sole reason of identifying different Rupture/KS applications for Rogues
        -- Then their duration func will cache one actual duration calculated at the moment of application
        return duration(spellID, isSrcPlayer, comboPoints)
    end
    return duration
end

local function GetSpellTable(srcGUID, dstGUID, spellID)
    local guidTable = guids[dstGUID]
    if not guidTable then return end

    local spellTable = guidTable[spellID]
    if not spellTable then return end

    local applicationTable
    if spellTable.applications then
        applicationTable = spellTable.applications[srcGUID]
    else
        applicationTable = spellTable
    end
    if not applicationTable then return end
    return applicationTable
end

local function RefreshTimer(srcGUID, dstGUID, spellID, overrideTime)
    local applicationTable = GetSpellTable(srcGUID, dstGUID, spellID)
    if not applicationTable then return end

    local oldStartTime = applicationTable[2]
    applicationTable[2] = overrideTime or GetTime() -- set start time to now
    return true, oldStartTime
end

local function SetTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, doRemove)
    if not opts then return end

    local guidTable = guids[dstGUID]
    if not guidTable then
        guids[dstGUID] = {}
        guidTable = guids[dstGUID]
    end

    local isStacking = opts.stacking
    -- local auraUID = MakeAuraUID(spellID, isStacking and srcGUID)

    if doRemove then
        if guidTable[spellID] then
            if isStacking then
                if guidTable[spellID].applications then
                    guidTable[spellID].applications[srcGUID] = nil
                end
            else
                guidTable[spellID] = nil
            end
        end
        return
    end

    local spellTable = guidTable[spellID]
    if not spellTable then
        guidTable[spellID] = {}
        spellTable = guidTable[spellID]
        if isStacking then
            spellTable.applications = {}
        end
    end

    local applicationTable
    if isStacking then
        applicationTable = spellTable.applications[srcGUID]
        if not applicationTable then
            spellTable.applications[srcGUID] = {}
            applicationTable = spellTable.applications[srcGUID]
        end
    else
        applicationTable = spellTable
    end

    local duration = opts.duration
    local isDstPlayer = bit_band(dstFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0
    if isDstPlayer and opts.pvpduration then
        duration = opts.pvpduration
    end

    if not duration then
        return SetTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, true)
    end
    -- local mul = getDRMul(dstGUID, spellID)
    -- duration = duration * mul
    local now = GetTime()
    -- local expirationTime
    -- if duration == 0 then
    --     expirationTime = now + UNKNOWN_AURA_DURATION -- 60m
    -- else
    --     -- local temporaryDuration = cleanDuration(opts.duration, spellID, srcGUID)
    --     expirationTime = now + duration
    -- end

    applicationTable[1] = duration
    applicationTable[2] = now
    -- applicationTable[2] = expirationTime
    applicationTable[3] = auraType

    local isSrcPlayer = srcGUID == UnitGUID("player")
    local comboPoints
    if isSrcPlayer and playerClass == "ROGUE" then
        comboPoints = GetCP()
    end
    applicationTable[4] = comboPoints

    guidAccessTimes[dstGUID] = time()
end

local function FireToUnits(event, dstGUID)
    if dstGUID == UnitGUID("target") then
        callbacks:Fire(event, "target")
    end
    local nameplateUnit = nameplateUnitMap[dstGUID]
    if nameplateUnit then
        callbacks:Fire(event, nameplateUnit)
    end
end

local function GetLastRankSpellID(spellName)
    local spellID = spellNameToID[spellName]
    if not spellID then
        spellID = NPCspellNameToID[spellName]
    end
    return spellID
end

local eventSnapshot
castLog.SetLastCast = function(self, srcGUID, spellID, timestamp)
    self[srcGUID] = { spellID, timestamp }
    guidAccessTimes[srcGUID] = time()
end
castLog.IsCurrent = function(self, srcGUID, spellID, timestamp, timeWindow)
    local entry = self[srcGUID]
    if entry then
        local lastSpellID, lastTimestamp = entry[1], entry[2]
        return lastSpellID == spellID and (timestamp - lastTimestamp < timeWindow)
    end
end

local lastResistSpellID
local lastResistTime = 0
---------------------------
-- COMBAT LOG HANDLER
---------------------------
function f:COMBAT_LOG_EVENT_UNFILTERED(event)
    return self:CombatLogHandler(CombatLogGetCurrentEventInfo())
end

local rollbackTable = setmetatable({}, { __mode="v" })
local function ProcIndirectRefresh(eventType, spellName, srcGUID, srcFlags, dstGUID, dstFlags, dstName, isCrit)
    if indirectRefreshSpells[spellName] then
        local targetSpells = indirectRefreshSpells[spellName]

        for targetSpellID, refreshTable in pairs(targetSpells) do
        if refreshTable.events[eventType] then


            local condition = refreshTable.condition
            if condition then
                local isMine = bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE
                if not condition(isMine, isCrit) then return end
            end

            if refreshTable.targetResistCheck then
                local now = GetTime()
                if lastResistSpellID == targetSpellID and now - lastResistTime < 0.4 then
                    return
                end
            end

            if refreshTable.applyAura then
                local opts = spells[targetSpellID]
                if opts then
                    local targetAuraType = "DEBUFF"
                    local targetSpellName = GetSpellInfo(targetSpellID)
                    SetTimer(srcGUID, dstGUID, dstName, dstFlags, targetSpellID, targetSpellName, opts, targetAuraType)
                end
            elseif refreshTable.customAction then
                refreshTable.customAction(srcGUID, dstGUID, targetSpellID)
            else
                local _, oldStartTime = RefreshTimer(srcGUID, dstGUID, targetSpellID)

                if refreshTable.rollbackMisses and oldStartTime then
                    rollbackTable[srcGUID] = rollbackTable[srcGUID] or {}
                    rollbackTable[srcGUID][dstGUID] = rollbackTable[srcGUID][dstGUID] or {}
                    local now = GetTime()
                    rollbackTable[srcGUID][dstGUID][targetSpellID] = {now, oldStartTime}
                end
            end
        end
        end
    end
end

local igniteName = GetSpellInfo(12654)
do
    local igniteOpts = { duration = 4 }
    function f:IgniteHandler(...)
        local timestamp, eventType, hideCaster,
        srcGUID, srcName, srcFlags, srcFlags2,
        dstGUID, dstName, dstFlags, dstFlags2,
        spellID, spellName, spellSchool, auraType, _, _, _, _, _, isCrit = ...

        spellID = 12654
        local opts = igniteOpts

        if eventType == "SPELL_AURA_APPLIED" then
            SetTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType)
            local spellTable = GetSpellTable(srcGUID, dstGUID, spellID)
            spellTable.tickExtended = true -- skipping first tick by treating it as already extended
            if lib.DEBUG_IGNITE then
                print(GetTime(), "[Ignite] Applied", dstGUID, "StartTime:", spellTable[2])
            end
        elseif eventType == "SPELL_PERIODIC_DAMAGE" then
            local spellTable = GetSpellTable(srcGUID, dstGUID, spellID)
            if spellTable then
                if lib.DEBUG_IGNITE then
                    print(GetTime(), "[Ignite] Tick", dstGUID)
                end
                spellTable.tickExtended = false -- unmark tick
            end
        elseif eventType == "SPELL_AURA_REMOVED" then
            SetTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, true)
            if lib.DEBUG_IGNITE then
                print(GetTime(), "[Ignite] Removed", dstGUID)
            end
        end
    end
    -- if playerClass ~= "MAGE" then
        -- f.IgniteHandler = function() end
    -- end
    function lib:GetSpellTable(...)
        return GetSpellTable(...)
    end
end

function f:CombatLogHandler(...)
    local timestamp, eventType, hideCaster,
    srcGUID, srcName, srcFlags, srcFlags2,
    dstGUID, dstName, dstFlags, dstFlags2,
    spellID, spellName, spellSchool, auraType, _, _, _, _, _, isCrit = ...

    ProcIndirectRefresh(eventType, spellName, srcGUID, srcFlags, dstGUID, dstFlags, dstName, isCrit)

    if spellName == igniteName then
        self:IgniteHandler(...)
    end

    if  eventType == "SPELL_MISSED" and
        bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE
    then
        local missType = auraType
        -- ABSORB BLOCK DEFLECT DODGE EVADE IMMUNE MISS PARRY REFLECT RESIST
        if not (missType == "ABSORB" or missType == "BLOCK") then -- not sure about those two

            local refreshTable = indirectRefreshSpells[spellName]
            -- This is just for Sunder Armor misses
            if refreshTable and refreshTable.rollbackMisses then
                local rollbacksFromSource = rollbackTable[srcGUID]
                if rollbacksFromSource then
                    local rollbacks = rollbacksFromSource[dstGUID]
                    if rollbacks then
                        local targetSpellID = refreshTable.targetSpellID
                        local snapshot = rollbacks[targetSpellID]
                        if snapshot then
                            local timestamp, oldStartTime = unpack(snapshot)
                            local now = GetTime()
                            if now - timestamp < 0.5 then
                                RefreshTimer(srcGUID, dstGUID, targetSpellID, oldStartTime)
                            end
                        end
                    end
                end
            end

            spellID = GetLastRankSpellID(spellName)
            if not spellID then
                return
            end

            lastResistSpellID = spellID
            lastResistTime = GetTime()
        end
    end

    if auraType == "BUFF" or auraType == "DEBUFF" or eventType == "SPELL_CAST_SUCCESS" then
        if spellID == 0 then
            -- so not to rewrite the whole thing to spellnames after the combat log change
            -- just treat everything as max rank id of that spell name
            spellID = GetLastRankSpellID(spellName)
            if not spellID then
                return
            end
        end

        CountDiminishingReturns(eventType, srcGUID, srcFlags, dstGUID, dstFlags, spellID, auraType)

        local isDstFriendly = bit_band(dstFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0

        local opts = spells[spellID]

        if not opts then
            local npcDurationForSpellName = npc_spells[spellID]
            if npcDurationForSpellName then
                opts = { duration = npcDurationForSpellName }
            -- elseif enableEnemyBuffTracking and not isDstFriendly and auraType == "BUFF" then
                -- opts = { duration = 0 } -- it'll be accepted but as an indefinite aura
            end
        end

        if opts then
            local castEventPass
            if opts.castFilter then
                -- Buff and Raidwide Buff events arrive in the following order:
                -- 1571716930.161 ID: 21562 SPELL_AURA_APPLIED/REFRESH to Caster himself (if selfcast or raidwide)
                -- 1571716930.161 ID: 21562 SPELL_CAST_SUCCESS on Cast Target
                -- 1571716930.161 ID: 21562 SPELL_AURA_APPLIED/REFRESH to everyone else

                -- For spells that have cast filter enabled:
                    -- First APPLIED event gets snapshotted and otherwise ignored
                    -- CAST event effectively sets castEventPass to true
                    -- Snapshotted event now gets handled with cast pass
                    -- All the following APPLIED events are accepted while cast pass is valid
                    -- (Unconfirmed whether timestamp is the same even for a 40m raid)
                local now = GetTime()
                castEventPass = castLog:IsCurrent(srcGUID, spellID, now, 0.8)
                if not castEventPass and (eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED") then
                    eventSnapshot = { timestamp, eventType, hideCaster,
                    srcGUID, srcName, srcFlags, srcFlags2,
                    dstGUID, dstName, dstFlags, dstFlags2,
                    spellID, spellName, spellSchool, auraType }
                    return
                end

                if eventType == "SPELL_CAST_SUCCESS" then
                    -- Aura spell ID can be different from cast spell id
                    -- But all buffs are usually simple spells and it's the same for them
                    castLog:SetLastCast(srcGUID, spellID, now)
                    if eventSnapshot then
                        self:CombatLogHandler(unpack(eventSnapshot))
                        eventSnapshot = nil
                    end
                end
            end

            local isEnemyBuff = not isDstFriendly and auraType == "BUFF"
            -- print(eventType, srcGUID, "=>", dstName, spellID, spellName, auraType )
            if  eventType == "SPELL_AURA_REFRESH" or
                eventType == "SPELL_AURA_APPLIED" or
                eventType == "SPELL_AURA_APPLIED_DOSE"
            then
                if  not opts.castFilter or
                    castEventPass or
                    isEnemyBuff
                then
                    SetTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType)
                end
            elseif eventType == "SPELL_AURA_REMOVED" then
                SetTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, true)
            -- elseif eventType == "SPELL_AURA_REMOVED_DOSE" then
                -- self:RemoveDose(srcGUID, dstGUID, spellID, spellName, auraType, amount)
            end
            if enableEnemyBuffTracking and isEnemyBuff then
                -- invalidate buff cache
                buffCacheValid[dstGUID] = nil

                FireToUnits("UNIT_BUFF", dstGUID)
                if  eventType == "SPELL_AURA_REFRESH" or
                    eventType == "SPELL_AURA_APPLIED" or
                    eventType == "SPELL_AURA_APPLIED_DOSE"
                then
                    FireToUnits("UNIT_BUFF_GAINED", dstGUID, spellID)
                end
            end
        end
    end
    if eventType == "UNIT_DIED" then
        if isHunterGUID(dstGUID) then
            local isDstFriendly = bit_band(dstFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
            if not isDstFriendly or isFriendlyFeigning(dstGUID) then
                return
            end
        end

        guids[dstGUID] = nil
        buffCache[dstGUID] = nil
        buffCacheValid[dstGUID] = nil
        guidAccessTimes[dstGUID] = nil
        local isDstFriendly = bit_band(dstFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
        if enableEnemyBuffTracking and not isDstFriendly then
            FireToUnits("UNIT_BUFF", dstGUID)
        end
        nameplateUnitMap[dstGUID] = nil
    end
end

---------------------------
-- ENEMY BUFFS
---------------------------
local makeBuffInfo = function(spellID, applicationTable, dstGUID, srcGUID)
    local name, rank, icon, castTime, minRange, maxRange, _spellId = GetSpellInfo(spellID)
    local durationFunc, startTime, auraType, comboPoints = unpack(applicationTable)
    local duration = cleanDuration(durationFunc, spellID, srcGUID, comboPoints) -- srcGUID isn't needed actually
    -- no DRs on buffs
    local expirationTime = startTime + duration
    if duration == INFINITY then
        duration = 0
        expirationTime = 0
    end
    local now = GetTime()
    if expirationTime > now then
        local buffType = spells[spellID] and spells[spellID].buffType
        return { name, icon, 0, buffType, duration, expirationTime, nil, nil, nil, spellID, false, false, false, false, 1 }
    end
end

local shouldDisplayAura = function(auraTable)
    if auraTable[3] == "BUFF" then
        local now = GetTime()
        local expirationTime = auraTable[2]
        return expirationTime > now
    end
    return false
end

lib.scanTip = lib.scanTip or CreateFrame("GameTooltip", "LibClassicDurationsScanTip", nil, "GameTooltipTemplate")
local scanTip = lib.scanTip
scanTip:SetOwner(WorldFrame, "ANCHOR_NONE")
local function RegenerateBuffList(unit, dstGUID)
    local buffs = {}
    local spellName
    for i=1, 32 do
        scanTip:ClearLines()
        scanTip:SetUnitAura(unit, i, "HELPFUL")
        spellName = LibClassicDurationsScanTipTextLeft1:GetText()
        if spellName then
            local spellID = GetLastRankSpellID(spellName)
            if spellID then
                local icon = GetSpellTexture(spellID)
                local opts = spells[spellID]
                local buffInfo = { spellName, icon, 0, (opts and opts.buffType), 0, 0, nil, nil, nil, spellID, false, false, false, false, 1 }
                local isStacking = opts and opts.stacking
                local srcGUID = nil
                local duration, expirationTime = GetGUIDAuraTime(dstGUID, spellName, spellID, srcGUID, isStacking)
                if duration then
                    buffInfo[5] = duration
                    buffInfo[6] = expirationTime
                end

                tinsert(buffs, buffInfo)
            end
        else
            break
        end
    end

    buffCache[dstGUID] = buffs
    buffCacheValid[dstGUID] = GetTime() + BUFF_CACHE_EXPIRATION_TIME -- Expiration timestamp
end

local FillInDuration = function(unit, buffName, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nps, spellId, ...)
    if buffName then
        local durationNew, expirationTimeNew = lib.GetAuraDurationByUnitDirect(unit, spellId, caster, buffName)
        if duration == 0 and durationNew then
            duration = durationNew
            expirationTime = expirationTimeNew
        end
        return buffName, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nps, spellId, ...
    end
end
lib.FillInDuration = FillInDuration

function lib.UnitAuraDirect(unit, index, filter)
    if enableEnemyBuffTracking and filter == "HELPFUL" and not UnitIsFriend("player", unit) and not UnitAura(unit, 1, filter) then
        local unitGUID = UnitGUID(unit)
        if not unitGUID then return end
        local isValid = buffCacheValid[unitGUID]
        if not isValid or isValid < GetTime() then
            RegenerateBuffList(unit, unitGUID)
        end

        local buffCacheHit = buffCache[unitGUID]
        if buffCacheHit then
            local buffReturns = buffCache[unitGUID][index]
            if buffReturns then
                return unpack(buffReturns)
            end
        end
    else
        return FillInDuration(unit, UnitAura(unit, index, filter))
    end
end

function lib.UnitAuraWithBuffs(...)
    return lib.UnitAuraDirect(...)
end

function lib.UnitAuraWrapper(unit, ...)
    return lib.FillInDuration(unit, UnitAura(unit, ...))
end

function lib:UnitAura(...)
    return self.UnitAuraDirect(...)
end

function f:NAME_PLATE_UNIT_ADDED(event, unit)
    local unitGUID = UnitGUID(unit)
    nameplateUnitMap[unitGUID] = unit
end
function f:NAME_PLATE_UNIT_REMOVED(event, unit)
    local unitGUID = UnitGUID(unit)
    if unitGUID then -- it returns correctly on death, but just in case
        nameplateUnitMap[unitGUID] = nil
    end
end

function callbacks.OnUsed()
    lib.enableEnemyBuffTracking = true
    enableEnemyBuffTracking = lib.enableEnemyBuffTracking
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end
function callbacks.OnUnused()
    lib.enableEnemyBuffTracking = false
    enableEnemyBuffTracking = lib.enableEnemyBuffTracking
    f:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    f:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
end

if next(callbacks.events) then
    callbacks.OnUsed()
end

---------------------------
-- PUBLIC FUNCTIONS
---------------------------
GetGUIDAuraTime = function(dstGUID, spellName, spellID, srcGUID, isStacking, forcedNPCDuration)
    local guidTable = guids[dstGUID]
    if guidTable then

        local lastRankID = GetLastRankSpellID(spellName)

        local spellTable = guidTable[lastRankID]
        if spellTable then
            local applicationTable

            -- Return when player spell and npc spell have the same name and the player spell is stacking
            -- NPC spells are always assumed to not stack, so it won't find startTime
            if forcedNPCDuration and spellTable.applications then return nil end

            if isStacking then
                if srcGUID and spellTable.applications then
                    applicationTable = spellTable.applications[srcGUID]
                elseif spellTable.applications then -- return some duration
                    applicationTable = select(2,next(spellTable.applications))
                end
            else
                applicationTable = spellTable
            end
            if not applicationTable then return end
            local durationFunc, startTime, auraType, comboPoints = unpack(applicationTable)
            local duration = forcedNPCDuration or cleanDuration(durationFunc, spellID, srcGUID, comboPoints)
            if duration == INFINITY then return nil end
            if not duration then return nil end
            if not startTime then return nil end
            local mul = getDRMul(dstGUID, spellID)
            -- local mul = getDRMul(dstGUID, lastRankID)
            duration = duration * mul
            local expirationTime = startTime + duration
            if GetTime() <= expirationTime then
                return duration, expirationTime
            end
        end
    end
end

if playerClass == "MAGE" then
    local NormalGetGUIDAuraTime = GetGUIDAuraTime
    local Chilled = GetSpellInfo(12486)
    GetGUIDAuraTime = function(dstGUID, spellName, spellID, ...)

        -- Overriding spellName for Improved blizzard's spellIDs
        if spellName == Chilled and
            spellID == 12486 or spellID == 12484 or spellID == 12485
        then
            spellName = "ImpBlizzard"
        end
        return NormalGetGUIDAuraTime(dstGUID, spellName, spellID, ...)
    end
end

function lib.GetAuraDurationByUnitDirect(unit, spellID, casterUnit, spellName)
    assert(spellID, "spellID is nil")
    local opts = spells[spellID]
    local isStacking
    local npcDurationById
    if opts then
        isStacking = opts.stacking
    else
        npcDurationById = npc_spells[spellID]
        if not npcDurationById then return end
    end
    local dstGUID = UnitGUID(unit)
    local srcGUID = casterUnit and UnitGUID(casterUnit)
    if not spellName then spellName = GetSpellInfo(spellID) end
    return GetGUIDAuraTime(dstGUID, spellName, spellID, srcGUID, isStacking, npcDurationById)
end

function lib:GetAuraDurationByUnit(...)
    return self.GetAuraDurationByUnitDirect(...)

end
function lib:GetAuraDurationByGUID(dstGUID, spellID, srcGUID, spellName)
    local opts = spells[spellID]
    if not opts then return end
    if not spellName then spellName = GetSpellInfo(spellID) end
    return GetGUIDAuraTime(dstGUID, spellName, spellID, srcGUID, opts.stacking)
end

function lib:GetLastRankSpellIDByName(spellName)
    return GetLastRankSpellID(spellName)
end

-- Will not work for cp-based durations, KS and Rupture
function lib:GetDurationForRank(spellName, spellID, srcGUID)
    local lastRankID = spellNameToID[spellName]
    local opts = spells[lastRankID]
    if opts then
        return cleanDuration(opts.duration, spellID, srcGUID)
    end
end

lib.activeFrames = lib.activeFrames or {}
local activeFrames = lib.activeFrames
function lib:RegisterFrame(frame)
    activeFrames[frame] = true
    if next(activeFrames) then
        f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        if playerClass == "ROGUE" then
            f:RegisterEvent("PLAYER_TARGET_CHANGED")
            f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        end
    end
end
lib.Register = lib.RegisterFrame

function lib:UnregisterFrame(frame)
    activeFrames[frame] = nil
    if not next(activeFrames) then
        f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        if playerClass == "ROGUE" then
            f:UnregisterEvent("PLAYER_TARGET_CHANGED")
            f:UnregisterEvent("UNIT_POWER_UPDATE")
        end
    end
end
lib.Unregister = lib.UnregisterFrame


function lib:ToggleDebug()
    if not lib.debug then
        lib.debug = CreateFrame("Frame")
        lib.debug:SetScript("OnEvent",function( self, event )
            local timestamp, eventType, hideCaster,
            srcGUID, srcName, srcFlags, srcFlags2,
            dstGUID, dstName, dstFlags, dstFlags2,
            spellID, spellName, spellSchool, auraType, amount = CombatLogGetCurrentEventInfo()
            local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
            if isSrcPlayer then
                print (GetTime(), "ID:", spellID, spellName, eventType, srcFlags, srcGUID,"|cff00ff00==>|r", dstGUID, dstFlags, auraType, amount)
            end
        end)
    end
    if not lib.debug.enabled then
        lib.debug:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        lib.debug.enabled = true
        print("[LCD] Enabled combat log event display")
    else
        lib.debug:UnregisterAllEvents()
        lib.debug.enabled = false
        print("[LCD] Disabled combat log event display")
    end
end

function lib:MonitorUnit(unit)
    if not lib.debug then
        lib.debug = CreateFrame("Frame")
        local debugGUID = UnitGUID(unit)
        lib.debug:SetScript("OnEvent",function( self, event )
            local timestamp, eventType, hideCaster,
            srcGUID, srcName, srcFlags, srcFlags2,
            dstGUID, dstName, dstFlags, dstFlags2,
            spellID, spellName, spellSchool, auraType, amount = CombatLogGetCurrentEventInfo()
            if srcGUID == debugGUID or dstGUID == debugGUID then
                print (GetTime(), "ID:", spellID, spellName, eventType, srcFlags, srcGUID,"|cff00ff00==>|r", dstGUID, dstFlags, auraType, amount)
            end
        end)
    end
    if not lib.debug.enabled then
        lib.debug:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        lib.debug.enabled = true
        print("[LCD] Enabled combat log event display")
    else
        lib.debug:UnregisterAllEvents()
        lib.debug.enabled = false
        print("[LCD] Disabled combat log event display")
    end
end

------------------
-- Set Tracking
------------------


local itemSets = {}

function lib:TrackItemSet(setname, itemArray)
    itemSets[setname] = itemSets[setname] or {}
    if not itemSets[setname].items then
        itemSets[setname].items = {}
        itemSets[setname].callbacks = {}
        local bitems = itemSets[setname].items
        for _, itemID in ipairs(itemArray) do
            bitems[itemID] = true
        end
    end
end
function lib:RegisterSetBonusCallback(setname, pieces, handle_on, handle_off)
    local set = itemSets[setname]
    if not set then error(string.format("Itemset '%s' is not registered", setname)) end
    set.callbacks[pieces] = {}
    set.callbacks[pieces].equipped = false
    set.callbacks[pieces].on = handle_on
    set.callbacks[pieces].off = handle_off
end

function lib:IsSetBonusActive(setname, bonusLevel)
    local set = itemSets[setname]
    if not set then return false end
    local setCallbacks = set.callbacks
    if setCallbacks[bonusLevel] and setCallbacks[bonusLevel].equipped then
        return true
    end
    return false
end


function lib:IsSetBonusActiveFullCheck(setname, bonusLevel)
    local set = itemSets[setname]
    if not set then return false end
    local set_items = set.items
    local pieces_equipped = 0
    for slot=1,17 do
        local itemID = GetInventoryItemID("player", slot)
        if set_items[itemID] then pieces_equipped = pieces_equipped + 1 end
    end
    return (pieces_equipped >= bonusLevel)
end


lib.setwatcher = lib.setwatcher or CreateFrame("Frame", nil, UIParent)
local setwatcher = lib.setwatcher
setwatcher:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)
setwatcher:RegisterEvent("PLAYER_LOGIN")
function setwatcher:PLAYER_LOGIN()
    if next(itemSets) then
        self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
        self:UNIT_INVENTORY_CHANGED(nil, "player")
    end
end
function setwatcher:UNIT_INVENTORY_CHANGED(event, unit)
    for setname, set in pairs(itemSets) do
        local set_items = set.items
        local pieces_equipped = 0
        for slot=1,17 do -- That excludes ranged slot in classic
            local itemID = GetInventoryItemID("player", slot)
            if set_items[itemID] then pieces_equipped = pieces_equipped + 1 end
        end
        for bp, bonus in pairs(set.callbacks) do
            if pieces_equipped >= bp then
                if not bonus.equipped then
                    if bonus.on then bonus.on() end
                    bonus.equipped = true
                end
            else
                if bonus.equipped then
                    if bonus.off then bonus.off() end
                    bonus.equipped = false
                end
            end
        end
    end
end
