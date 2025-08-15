local E, L = unpack(ElvUI)
local WT = E.Libs.AceAddon:GetAddon("ElvUI_WindTools", true)
if not WT then return end

local WTO = E:NewModule('WindToolsOptimizer', 'AceEvent-3.0', 'AceTimer-3.0')
local pairs, format, tinsert = pairs, format, tinsert

-- List of WindTools modules that can be safely delayed
local DELAY_MODULES = {
    "Announcement",
    "Datatexts",
    "Misc",
    "Skins",
    "Social",
    "Tooltips",
}

-- Keep track of delayed modules
local delayedModules = {}
local isOptimized = false

function WTO:Initialize()
    -- Add settings to ElvUI config
    P.general.windToolsOptimizer = {
        enable = true,
        aggressiveMode = false,
        safeMode = true,
    }
    
    -- Only run if WindTools is loaded and our optimizer is enabled
    if not WT or not E.db.general.windToolsOptimizer or not E.db.general.windToolsOptimizer.enable then return end
    
    -- Wait for WindTools to initialize
    self:ScheduleTimer("OptimizeWindTools", 2)
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function() self:ScheduleTimer("OptimizeWindTools", 3) end)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnterCombat")
    
    -- Register chat command
    E:RegisterChatCommand('elvwt', self.ChatCommand)
end

function WTO:ChatCommand(input)
    if input == "list" then
        WTO:ListModules()
    elseif input == "load" then
        WTO:LoadDelayedModules(true)
    elseif input == "config" then
        E:ToggleOptions('advanced,general,windToolsOptimizer')
    else
        E:Print("ElvUI WindTools Optimizer commands:")
        E:Print("/elvwt list - List delayed modules")
        E:Print("/elvwt load - Load all delayed modules")
        E:Print("/elvwt config - Open configuration")
    end
end

function WTO:OptimizeWindTools()
    if isOptimized or not WT then return end
    isOptimized = true
    
    -- Delay initialization of safe modules
    for _, name in pairs(DELAY_MODULES) do
        local module = WT:GetModule(name)
        if module and not module.initialized then
            self:DelayModule(name, module)
        end
    end
    
    -- If aggressive mode, delay even more modules
    if E.db.general.windToolsOptimizer.aggressiveMode then
        for name, module in pairs(WT.modules) do
            local isSafe = false
            for _, safeName in pairs(DELAY_MODULES) do
                if name == safeName then
                    isSafe = true
                    break
                end
            end
            
            if not isSafe and not module.initialized then
                self:DelayModule(name, module)
            end
        end
    end
    
    -- Report results
    local count = 0
    for name, info in pairs(delayedModules) do
        if not info.loaded then
            count = count + 1
        end
    end
    
    if count > 0 then
        E:Print(format("WindTools Optimizer: Delayed %d modules. Type /elvwt list for details", count))
    end
end

function WTO:DelayModule(name, module)
    -- Store original Initialize function
    if not delayedModules[name] then
        delayedModules[name] = {
            module = module,
            origInitialize = module.Initialize,
            loaded = false
        }
        
        -- Replace with dummy function
        module.Initialize = function() 
            -- Do nothing, we'll call the real one later
            module.initialized = false
            return
        end
    end
end

function WTO:LoadModule(name, force)
    local info = delayedModules[name]
    if not info or info.loaded then return end
    
    local module = info.module
    local origFunc = info.origInitialize
    
    -- Restore original function
    module.Initialize = origFunc
    
    -- Call it
    module:Initialize()
    info.loaded = true
    
    E:Print(format("Loaded delayed WindTools module: %s", name))
    return true
end

function WTO:LoadDelayedModules(force)
    local count = 0
    for name, info in pairs(delayedModules) do
        if not info.loaded then
            self:LoadModule(name, force)
            count = count + 1
        end
    end
    
    E:Print(format("Loaded %d delayed WindTools modules", count))
    return count
end

function WTO:EnterCombat()
    -- Load all modules in combat if safe mode is enabled
    if E.db.general.windToolsOptimizer.safeMode then
        self:LoadDelayedModules(true)
    end
end

function WTO:ListModules()
    E:Print("WindTools Module Status:")
    
    -- List delayed modules
    E:Print(" |cffff9900Delayed Modules:|r")
    local delayCount = 0
    for name, info in pairs(delayedModules) do
        if not info.loaded then
            E:Print(format(" - %s (delayed)", name))
            delayCount = delayCount + 1
        end
    end
    if delayCount == 0 then
        E:Print(" - None")
    end
    
    -- List loaded modules
    E:Print(" |cff00ff00Loaded Modules:|r")
    local loadCount = 0
    for name, module in pairs(WT.modules) do
        if module.initialized then
            E:Print(format(" - %s", name))
            loadCount = loadCount + 1
        end
    end
end

E:RegisterModule(WTO:GetName())
