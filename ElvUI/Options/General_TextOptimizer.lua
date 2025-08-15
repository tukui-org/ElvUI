local E, L, V, P, G = unpack(ElvUI)

-- Add default settings to P table (personal settings)
P.general.textOptimizer = {
    enable = false,  -- Off by default since it's experimental
    throttleInterval = 0.2,
    smartTextUpdates = true,
    enableFontStringPool = true
}

local function ConfigTable()
    E.Options.args.general.args.textOptimizer = {
        order = 13,
        type = 'group',
        name = L['Text Optimizer'],
        args = {
            header = {
                order = 1,
                type = 'header',
                name = L['Text Optimizer Settings'],
            },
            experimentalWarning = {
                order = 2,
                type = 'description',
                name = L['WARNING: These are experimental features that may cause UI issues in some situations. Use with caution.'],
                fontSize = 'medium',
                width = 'full',
            },
            enable = {
                order = 3,
                type = 'toggle',
                name = L['Enable Text Optimizer'],
                desc = L['Optimize text rendering to reduce CPU usage. This may cause some text to update slightly delayed.'],
                get = function(info) return E.db.general.textOptimizer.enable end,
                set = function(info, value) 
                    E.db.general.textOptimizer.enable = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
            },
            throttleInterval = {
                order = 4,
                type = 'range',
                name = L['Throttle Interval'],
                desc = L['How often to update text elements (in seconds).'],
                min = 0.05, max = 1, step = 0.05,
                get = function(info) return E.db.general.textOptimizer.throttleInterval end,
                set = function(info, value) E.db.general.textOptimizer.throttleInterval = value end,
                disabled = function() return not E.db.general.textOptimizer.enable end,
            },
            smartTextUpdates = {
                order = 5,
                type = 'toggle',
                name = L['Smart Text Updates'],
                desc = L['Only update visible text elements to save CPU.'],
                get = function(info) return E.db.general.textOptimizer.smartTextUpdates end,
                set = function(info, value) 
                    E.db.general.textOptimizer.smartTextUpdates = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
                disabled = function() return not E.db.general.textOptimizer.enable end,
            },
            enableFontStringPool = {
                order = 6,
                type = 'toggle',
                name = L['Enable FontString Pooling'],
                desc = L['Recycle FontString objects to reduce memory usage.'],
                get = function(info) return E.db.general.textOptimizer.enableFontStringPool end,
                set = function(info, value) 
                    E.db.general.textOptimizer.enableFontStringPool = value
                    E:StaticPopup_Show('CONFIG_RL')
                end,
                disabled = function() return not E.db.general.textOptimizer.enable end,
            },
            infoHeader = {
                order = 7,
                type = 'header',
                name = L['Information'],
            },
            infoText = {
                order = 8,
                type = 'description',
                name = L['The Text Optimizer reduces CPU usage by limiting how often text elements are updated and recycling FontString objects.'],
                fontSize = 'medium',
                width = 'full',
            },
        },
    }
end

-- Insert to ElvUI config
tinsert(E.ConfigModes.general, #E.ConfigModes.general + 1, 'textOptimizer')
E:RegisterModule('TextOptimizerConfig', ConfigTable)
