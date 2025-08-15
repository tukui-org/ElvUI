local E, L, V, P, G = unpack(ElvUI)

local function ConfigTable()
    E.Options.args.general.args.moduleOptimizer = {
        order = 11,
        type = 'group',
        name = L['Module Optimizer'],
        args = {
            header = {
                order = 1,
                type = 'header',
                name = L['Module Optimizer Settings'],
            },
            warning = {
                order = 2,
                type = 'description',
                name = L['WARNING: These settings require a UI reload to take effect.'],
                fontSize = 'medium',
                width = 'full',
            },
            enable = {
                order = 3,
                type = 'toggle',
                name = L['Enable Module Optimizer'],
                desc = L['Optimize ElvUI modules by loading some features on-demand.'],
                get = function(info) return E.db.general.moduleOptimizer.enable end,
                set = function(info, value) 
                    E.db.general.moduleOptimizer.enable = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
            },
            aggressiveMode = {
                order = 4,
                type = 'toggle',
                name = L['Aggressive Mode'],
                desc = L['Delay more modules for greater memory savings. May cause some features to not work until accessed.'],
                get = function(info) return E.db.general.moduleOptimizer.aggressiveMode end,
                set = function(info, value) 
                    E.db.general.moduleOptimizer.aggressiveMode = value 
                    E.db.general.moduleOptimizer.delayNonCoreModules = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
                disabled = function() return not E.db.general.moduleOptimizer.enable end,
            },
            safeModeInCombat = {
                order = 5,
                type = 'toggle',
                name = L['Safe Mode in Combat'],
                desc = L['Automatically load all delayed modules when entering combat.'],
                get = function(info) return E.db.general.moduleOptimizer.safeModeInCombat end,
                set = function(info, value) E.db.general.moduleOptimizer.safeModeInCombat = value end,
                disabled = function() return not E.db.general.moduleOptimizer.enable end,
            },
            delayNonCoreModules = {
                order = 6,
                type = 'toggle',
                name = L['Delay Non-Core Modules'],
                desc = L['Delay loading of non-essential modules until needed.'],
                get = function(info) return E.db.general.moduleOptimizer.delayNonCoreModules end,
                set = function(info, value) 
                    E.db.general.moduleOptimizer.delayNonCoreModules = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
                disabled = function() return not E.db.general.moduleOptimizer.enable or E.db.general.moduleOptimizer.aggressiveMode end,
            },
            dataTextOptimization = {
                order = 7,
                type = 'toggle',
                name = L['Optimize DataTexts'],
                desc = L['Update non-essential DataTexts less frequently to save CPU/memory.'],
                get = function(info) return E.db.general.moduleOptimizer.dataTextOptimization end,
                set = function(info, value) 
                    E.db.general.moduleOptimizer.dataTextOptimization = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
                disabled = function() return not E.db.general.moduleOptimizer.enable end,
            },
            loadModules = {
                order = 8,
                type = 'execute',
                name = L['Load All Modules'],
                desc = L['Load all delayed modules immediately.'],
                func = function() E:GetModule('ModuleOptimizer'):LoadDelayedModules(true) end,
                disabled = function() return not E.db.general.moduleOptimizer.enable end,
            },
            spacer = {
                order = 9,
                type = 'description',
                name = '',
                width = 'full',
            },
            infoHeader = {
                order = 10,
                type = 'header',
                name = L['Information'],
            },
            infoText = {
                order = 11,
                type = 'description',
                name = function()
                    local mom = E:GetModule('ModuleOptimizer')
                    local total, loaded, delayed = 0, 0, 0
                    
                    if mom and mom.GetModuleStats then
                        total, loaded, delayed = mom:GetModuleStats()
                    end
                    
                    return L['The Module Optimizer delays loading of non-essential ElvUI modules until they are needed, reducing memory usage and improving performance.']..
                           '\n\n'..
                           format(L['Total modules: %d'], total)..'\n'..
                           format(L['Loaded modules: %d'], loaded)..'\n'..
                           format(L['Delayed modules: %d'], delayed)..'\n'..
                           format(L['Estimated memory saved: ~%.1f MB'], delayed * 0.25)
                end,
                fontSize = 'medium',
                width = 'full',
            },
        },
    }
end

-- Insert to ElvUI config
tinsert(E.ConfigModes.general, #E.ConfigModes.general + 1, 'moduleOptimizer')
E:RegisterModule('ModuleOptimizerConfig', ConfigTable)
