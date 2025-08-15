local E, L, V, P, G = unpack(ElvUI)
local WT = E.Libs.AceAddon:GetAddon("ElvUI_WindTools", true)

-- Only create config if WindTools is installed
if not WT then return end

local function ConfigTable()
    E.Options.args.general.args.windToolsOptimizer = {
        order = 12,
        type = 'group',
        name = L['WindTools Optimizer'],
        args = {
            header = {
                order = 1,
                type = 'header',
                name = L['WindTools Optimizer Settings'],
            },
            enable = {
                order = 2,
                type = 'toggle',
                name = L['Enable WindTools Optimizer'],
                desc = L['Optimize ElvUI WindTools modules by loading some features on-demand.'],
                get = function(info) return E.db.general.windToolsOptimizer.enable end,
                set = function(info, value) 
                    E.db.general.windToolsOptimizer.enable = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
            },
            aggressiveMode = {
                order = 3,
                type = 'toggle',
                name = L['Aggressive Mode'],
                desc = L['Delay more modules for greater memory savings. May cause some features to not work until accessed.'],
                get = function(info) return E.db.general.windToolsOptimizer.aggressiveMode end,
                set = function(info, value) 
                    E.db.general.windToolsOptimizer.aggressiveMode = value 
                    E:StaticPopup_Show('CONFIG_RL')
                end,
                disabled = function() return not E.db.general.windToolsOptimizer.enable end,
            },
            safeMode = {
                order = 4,
                type = 'toggle',
                name = L['Safe Mode in Combat'],
                desc = L['Automatically load all delayed modules when entering combat.'],
                get = function(info) return E.db.general.windToolsOptimizer.safeMode end,
                set = function(info, value) E.db.general.windToolsOptimizer.safeMode = value end,
                disabled = function() return not E.db.general.windToolsOptimizer.enable end,
            },
            loadModules = {
                order = 5,
                type = 'execute',
                name = L['Load All Modules'],
                desc = L['Load all delayed WindTools modules immediately.'],
                func = function() E:GetModule('WindToolsOptimizer'):LoadDelayedModules(true) end,
                disabled = function() return not E.db.general.windToolsOptimizer.enable end,
            },
            infoHeader = {
                order = 6,
                type = 'header',
                name = L['Information'],
            },
            infoText = {
                order = 7,
                type = 'description',
                name = L['The WindTools Optimizer delays loading of non-essential WindTools modules until they are needed, reducing memory usage and improving performance.'],
                fontSize = 'medium',
                width = 'full',
            },
        },
    }
end

-- Insert to ElvUI config
tinsert(E.ConfigModes.general, #E.ConfigModes.general + 1, 'windToolsOptimizer')
E:RegisterModule('WindToolsOptimizerConfig', ConfigTable)
