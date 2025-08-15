local E, L, V, P, G = unpack(ElvUI)

-- Add default settings to P table (personal settings)
P.general.memoryDashboard = {
    showOnLogin = false,
    width = 700,
    height = 500,
    updateInterval = 1,
    showSystemInfo = true,
    trackHistory = true,
    historyLimit = 30,
    showCPUUsage = true,
    sortBy = "memory",
    sortOrder = "desc",
    filterAddons = ""
}

local function ConfigTable()
    E.Options.args.general.args.memoryDashboard = {
        order = 14,
        type = 'group',
        name = L['Memory Dashboard'],
        args = {
            header = {
                order = 1,
                type = 'header',
                name = L['Memory Dashboard Settings'],
            },
            showDashboard = {
                order = 2,
                type = 'execute',
                name = L['Open Dashboard'],
                func = function() E:GetModule('MemoryDashboard'):ShowDashboard() end,
            },
            showOnLogin = {
                order = 3,
                type = 'toggle',
                name = L['Show on Login'],
                desc = L['Automatically show the memory dashboard when logging in.'],
                get = function(info) return E.db.general.memoryDashboard.showOnLogin end,
                set = function(info, value) E.db.general.memoryDashboard.showOnLogin = value end,
            },
            width = {
                order = 4,
                type = 'range',
                name = L['Width'],
                desc = L['Width of the dashboard window.'],
                min = 500, max = 1200, step = 10,
                get = function(info) return E.db.general.memoryDashboard.width end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.width = value
                    local MD = E:GetModule('MemoryDashboard')
                    if MD.frame then
                        MD.frame:SetWidth(value)
                    end
                end,
            },
            height = {
                order = 5,
                type = 'range',
                name = L['Height'],
                desc = L['Height of the dashboard window.'],
                min = 300, max = 800, step = 10,
                get = function(info) return E.db.general.memoryDashboard.height end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.height = value
                    local MD = E:GetModule('MemoryDashboard')
                    if MD.frame then
                        MD.frame:SetHeight(value)
                    end
                end,
            },
            updateInterval = {
                order = 6,
                type = 'range',
                name = L['Update Interval'],
                desc = L['How often to update the dashboard (in seconds).'],
                min = 0.5, max = 5, step = 0.5,
                get = function(info) return E.db.general.memoryDashboard.updateInterval end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.updateInterval = value
                    local MD = E:GetModule('MemoryDashboard')
                    if MD.updateTimer then
                        MD:CancelTimer(MD.updateTimer)
                        MD.updateTimer = MD:ScheduleRepeatingTimer(MD.frame.OnUpdate, value)
                    end
                end,
            },
            showSystemInfo = {
                order = 7,
                type = 'toggle',
                name = L['Show System Information'],
                desc = L['Show system information at the top of the dashboard.'],
                get = function(info) return E.db.general.memoryDashboard.showSystemInfo end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.showSystemInfo = value
                    E:GetModule('MemoryDashboard'):UpdateDashboard()
                end,
            },
            showCPUUsage = {
                order = 8,
                type = 'toggle',
                name = L['Show CPU Usage'],
                desc = L['Show CPU usage information in the dashboard.'],
                get = function(info) return E.db.general.memoryDashboard.showCPUUsage end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.showCPUUsage = value
                    E:GetModule('MemoryDashboard'):UpdateDashboard()
                end,
            },
            trackHistory = {
                order = 9,
                type = 'toggle',
                name = L['Track History'],
                desc = L['Track memory usage history over time.'],
                get = function(info) return E.db.general.memoryDashboard.trackHistory end,
                set = function(info, value) E.db.general.memoryDashboard.trackHistory = value end,
            },
            historyLimit = {
                order = 10,
                type = 'range',
                name = L['History Limit'],
                desc = L['How many minutes of history to keep.'],
                min = 5, max = 60, step = 5,
                get = function(info) return E.db.general.memoryDashboard.historyLimit end,
                set = function(info, value) E.db.general.memoryDashboard.historyLimit = value end,
                disabled = function() return not E.db.general.memoryDashboard.trackHistory end,
            },
            sortHeader = {
                order = 11,
                type = 'header',
                name = L['Sorting and Filtering'],
            },
            sortBy = {
                order = 12,
                type = 'select',
                name = L['Sort By'],
                desc = L['How to sort the addon list.'],
                values = {
                    ['memory'] = L['Memory Usage'],
                    ['cpu'] = L['CPU Usage'],
                    ['name'] = L['Addon Name']
                },
                get = function(info) return E.db.general.memoryDashboard.sortBy end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.sortBy = value
                    E:GetModule('MemoryDashboard'):UpdateDashboard() 
                end,
            },
            sortOrder = {
                order = 13,
                type = 'select',
                name = L['Sort Order'],
                desc = L['Sort order for the addon list.'],
                values = {
                    ['asc'] = L['Ascending'],
                    ['desc'] = L['Descending']
                },
                get = function(info) return E.db.general.memoryDashboard.sortOrder end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.sortOrder = value
                    E:GetModule('MemoryDashboard'):UpdateDashboard()
                end,
            },
            filterAddons = {
                order = 14,
                type = 'input',
                name = L['Filter Addons'],
                desc = L['Enter comma-separated partial names to filter the addon list. Leave empty to show all addons.'],
                width = 'full',
                get = function(info) return E.db.general.memoryDashboard.filterAddons end,
                set = function(info, value) 
                    E.db.general.memoryDashboard.filterAddons = value
                    E:GetModule('MemoryDashboard'):UpdateDashboard()
                end,
            },
            actions = {
                order = 15,
                type = 'header',
                name = L['Actions'],
            },
            resetStats = {
                order = 16,
                type = 'execute',
                name = L['Reset Statistics'],
                desc = L['Reset memory statistics and history.'],
                func = function() E:GetModule('MemoryDashboard'):ResetStats() end,
            },
            forceGC = {
                order = 17,
                type = 'execute',
                name = L['Force Garbage Collection'],
                desc = L['Force Lua garbage collection to free memory.'],
                func = function()
                    local before = collectgarbage("count") / 1024
                    collectgarbage("collect")
                    local after = collectgarbage("count") / 1024
                    E:Print(format("Garbage collection complete. Memory freed: %.2f MB", before - after))
                end,
            },
        },
    }
end

-- Insert to ElvUI config
tinsert(E.ConfigModes.general, #E.ConfigModes.general + 1, 'memoryDashboard')
E:RegisterModule('MemoryDashboardConfig', ConfigTable)
