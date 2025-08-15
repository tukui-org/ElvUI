local E, L, V, P, G = unpack(ElvUI)

-- Add default settings to P table (personal settings)
P.general.memoryOptimizer = {
    autoOptimize = true,
    interval = 300,
    combatDelay = 30,
    textureCacheSize = 30,
    enableScriptCaching = true,
    debug = false
}

local function ConfigTable()
    E.Options.args.general.args.memoryOptimizer = {
        order = 10,
        type = 'group',
        name = L['Memory Optimizer'],
        args = {
            header = {
                order = 1,
                type = 'header',
                name = L['Memory Optimizer Settings'],
            },
            autoOptimize = {
                order = 2,
                type = 'toggle',
                name = L['Auto Optimize'],
                desc = L['Automatically optimize memory usage periodically.'],
                get = function(info) return E.db.general.memoryOptimizer.autoOptimize end,
                set = function(info, value) 
                    E.db.general.memoryOptimizer.autoOptimize = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
            },
            interval = {
                order = 3,
                type = 'range',
                name = L['Optimize Interval'],
                desc = L['How often to run memory optimization (in seconds).'],
                min = 60, max = 1800, step = 30,
                get = function(info) return E.db.general.memoryOptimizer.interval end,
                set = function(info, value) E.db.general.memoryOptimizer.interval = value end,
                disabled = function() return not E.db.general.memoryOptimizer.autoOptimize end,
            },
            combatDelay = {
                order = 4,
                type = 'range',
                name = L['Combat Delay'],
                desc = L['How long to wait after combat before optimizing (in seconds).'],
                min = 5, max = 120, step = 5,
                get = function(info) return E.db.general.memoryOptimizer.combatDelay end,
                set = function(info, value) E.db.general.memoryOptimizer.combatDelay = value end,
            },
            textureCacheSize = {
                order = 5,
                type = 'range',
                name = L['Texture Cache Size'],
                desc = L['Maximum size of texture cache (in MB).'],
                min = 10, max = 100, step = 5,
                get = function(info) return E.db.general.memoryOptimizer.textureCacheSize end,
                set = function(info, value) E.db.general.memoryOptimizer.textureCacheSize = value end,
            },
            enableScriptCaching = {
                order = 6,
                type = 'toggle',
                name = L['Script Result Caching'],
                desc = L['Enable caching of script results to reduce CPU usage.'],
                get = function(info) return E.db.general.memoryOptimizer.enableScriptCaching end,
                set = function(info, value)
                    E.db.general.memoryOptimizer.enableScriptCaching = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
            },
            debug = {
                order = 7,
                type = 'toggle',
                name = L['Debug Mode'],
                desc = L['Enable debug output for memory optimization.'],
                get = function(info) return E.db.general.memoryOptimizer.debug end,
                set = function(info, value) E.db.general.memoryOptimizer.debug = value end,
            },
            optimize = {
                order = 8,
                type = 'execute',
                name = L['Optimize Now'],
                desc = L['Run memory optimization immediately.'],
                func = function() E:GetModule('MemoryOptimizer'):OptimizeMemory(true) end,
            },
            forceGC = {
                order = 9,
                type = 'execute',
                name = L['Force Garbage Collection'],
                desc = L['Force Lua garbage collection.'],
                func = function() E:GetModule('MemoryOptimizer'):ForceGC() end,
            },
        },
    }
end

tinsert(E.ConfigModes.general, #E.ConfigModes.general + 1, 'memoryOptimizer')
E:RegisterModule('MemoryOptimizerConfig', ConfigTable)
