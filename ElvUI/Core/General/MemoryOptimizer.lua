local E, L, V, P, G = unpack(ElvUI)
local MO = E:NewModule('MemoryOptimizer', 'AceEvent-3.0', 'AceTimer-3.0')
local format, select, collectgarbage = format, select, collectgarbage
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local tostring, pairs, wipe, type = tostring, pairs, wipe, type

-- Configuration
local CONFIG = {
    AUTO_OPTIMIZE = true,           -- Automatically optimize memory
    OPTIMIZE_INTERVAL = 300,         -- Run optimization every 5 minutes
    COMBAT_DELAY = 30,               -- Delay after combat
    GC_THRESHOLD = 0,                -- Garbage collection threshold (0 = default)
    TEXTURE_CACHE_SIZE = 30,         -- Maximum texture cache size in MB
    ENABLE_SCRIPT_CACHING = true,    -- Enable script result caching
    DEBUG = false                    -- Enable debug output
}

-- Caches that we'll manage
local textureCache = {}
local frameCaches = {}
local hookCache = {}
local lastOptimize = 0
local inCombat = false
local pendingOptimize = false

-- Statistics
local stats = {
    optimizeCount = 0,
    memoryBefore = 0,
    memorySaved = 0,
    texturesUnloaded = 0,
    textureCacheSize = 0
}

function MO:Initialize()
    -- Set up configuration
    CONFIG.AUTO_OPTIMIZE = E.db.general.memoryOptimizer and E.db.general.memoryOptimizer.autoOptimize or CONFIG.AUTO_OPTIMIZE
    CONFIG.OPTIMIZE_INTERVAL = E.db.general.memoryOptimizer and E.db.general.memoryOptimizer.interval or CONFIG.OPTIMIZE_INTERVAL
    CONFIG.COMBAT_DELAY = E.db.general.memoryOptimizer and E.db.general.memoryOptimizer.combatDelay or CONFIG.COMBAT_DELAY
    CONFIG.TEXTURE_CACHE_SIZE = E.db.general.memoryOptimizer and E.db.general.memoryOptimizer.textureCacheSize or CONFIG.TEXTURE_CACHE_SIZE

    -- Register events
    self:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnCombatStart')
    self:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnCombatEnd')
    
    -- Set up garbage collector
    if CONFIG.GC_THRESHOLD > 0 then
        collectgarbage("setpause", CONFIG.GC_THRESHOLD)
    end
    
    -- Register chat command
    E:RegisterChatCommand('elvmem', self.ChatCommand)
    
    -- Initialize texture manager
    self:InitTextureManager()
    
    -- Setup auto-optimization timer
    if CONFIG.AUTO_OPTIMIZE then
        self:ScheduleRepeatingTimer('OptimizeMemory', CONFIG.OPTIMIZE_INTERVAL)
    end
    
    -- Run initial optimization after a delay
    self:ScheduleTimer('OptimizeMemory', 30)
    
    self:Debug('Memory optimizer initialized')
end

function MO:Debug(...)
    if CONFIG.DEBUG then
        E:Print('|cff00FF00Memory:|r', ...)
    end
end

function MO:ChatCommand(input)
    if input == 'stats' then
        MO:PrintStats()
    elseif input == 'optimize' then
        MO:OptimizeMemory(true)
    elseif input == 'gc' then
        MO:ForceGC()
    elseif input == 'cache' then
        MO:PrintCacheInfo()
    elseif input == 'config' then
        E:ToggleOptions('advanced,general,memoryOptimizer')
    else
        E:Print('ElvUI Memory Optimizer commands:')
        E:Print('/elvmem stats - Show memory statistics')
        E:Print('/elvmem optimize - Force memory optimization')
        E:Print('/elvmem gc - Force garbage collection')
        E:Print('/elvmem cache - Show cache information')
        E:Print('/elvmem config - Open memory optimizer configuration')
    end
end

function MO:GetMemoryUsage(addon)
    UpdateAddOnMemoryUsage()
    return GetAddOnMemoryUsage(addon or 'ElvUI')
end

function MO:ForceGC()
    local before = collectgarbage('count')
    collectgarbage('collect')
    local after = collectgarbage('count')
    E:Print(format('Memory cleaned: %.2f MB', (before - after) / 1024))
    return before - after
end

function MO:OnCombatStart()
    inCombat = true
    self:Debug('Combat started, pausing optimization')
end

function MO:OnCombatEnd()
    inCombat = false
    if pendingOptimize then
        self:ScheduleTimer('OptimizeMemory', CONFIG.COMBAT_DELAY)
        pendingOptimize = false
        self:Debug('Combat ended, scheduled optimization in ' .. CONFIG.COMBAT_DELAY .. ' seconds')
    end
end

-- Texture Management
function MO:InitTextureManager()
    -- Create a function to manage texture memory
    hooksecurefunc('SetTexture', function(texture, path)
        if type(texture) ~= 'table' or type(path) ~= 'string' then return end
        
        -- Only track file textures that are not UI textures
        if path:find('Interface\\') or path:find('Textures\\') then
            textureCache[path] = (textureCache[path] or 0) + 1
            stats.textureCacheSize = stats.textureCacheSize + 1
        end
    end)
    
    -- Periodically clean up texture cache
    self:ScheduleRepeatingTimer('CleanTextureCache', 60)
end

function MO:CleanTextureCache()
    if stats.textureCacheSize > CONFIG.TEXTURE_CACHE_SIZE * 1000 then
        local removed = 0
        for path, count in pairs(textureCache) do
            if count <= 1 then
                textureCache[path] = nil
                removed = removed + 1
                if removed > 100 then break end -- Remove at most 100 at a time
            end
        end
        stats.texturesUnloaded = stats.texturesUnloaded + removed
        stats.textureCacheSize = stats.textureCacheSize - removed
        self:Debug('Cleaned ' .. removed .. ' textures from cache')
    end
end

function MO:OptimizeMemory(force)
    -- Skip if in combat
    if inCombat then
        pendingOptimize = true
        self:Debug('Optimization delayed due to combat')
        return
    end
    
    -- Don't optimize too frequently unless forced
    local now = GetTime()
    if not force and now - lastOptimize < 60 then
        self:Debug('Optimization skipped (too frequent)')
        return
    end
    
    lastOptimize = now
    stats.optimizeCount = stats.optimizeCount + 1
    stats.memoryBefore = collectgarbage('count') / 1024
    
    self:Debug('Starting memory optimization...')
    
    -- Clean texture cache
    self:CleanTextureCache()
    
    -- Force UI update to finalize any pending changes
    E:UIFrameFadeIn(UIParent, 0.001, UIParent:GetAlpha(), UIParent:GetAlpha())
    
    -- Clean weakauras cache if it exists
    if WeakAuras and WeakAuras.cloneId then
        for id, _ in pairs(WeakAuras.cloneId) do
            local region = WeakAuras.GetRegion(id)
            if region and not region.toShow and region.regionType == "dynamicgroup" then
                region:SortRegions()
            end
        end
    end
    
    -- Run garbage collector
    collectgarbage('collect')
    
    -- Calculate saved memory
    local memoryAfter = collectgarbage('count') / 1024
    local saved = stats.memoryBefore - memoryAfter
    stats.memorySaved = stats.memorySaved + saved
    
    self:Debug(format('Memory optimization completed. Saved: %.2f MB', saved))
    
    if force then
        E:Print(format('Memory optimization completed. Saved: %.2f MB', saved))
    end
    
    return saved
end

function MO:PrintStats()
    E:Print('|cff00FF00ElvUI Memory Optimizer Statistics:|r')
    E:Print(format('Optimizations run: %d', stats.optimizeCount))
    E:Print(format('Current memory usage: %.2f MB', self:GetMemoryUsage() / 1024))
    E:Print(format('Total memory saved: %.2f MB', stats.memorySaved))
    E:Print(format('Textures unloaded: %d', stats.texturesUnloaded))
    E:Print(format('Texture cache size: %d', stats.textureCacheSize))
end

function MO:PrintCacheInfo()
    E:Print('|cff00FF00ElvUI Cache Information:|r')
    E:Print(format('Texture cache entries: %d', self:TableCount(textureCache)))
    E:Print(format('Frame cache entries: %d', self:TableCount(frameCaches)))
    E:Print(format('Hook cache entries: %d', self:TableCount(hookCache)))
end

function MO:TableCount(t)
    local count = 0
    if type(t) == 'table' then
        for _ in pairs(t) do count = count + 1 end
    end
    return count
end

E:RegisterModule(MO:GetName())
