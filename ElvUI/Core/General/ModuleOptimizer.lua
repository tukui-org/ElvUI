local E, L, V, P, G = unpack(ElvUI)
local MOM = E:NewModule('ModuleOptimizer', 'AceEvent-3.0', 'AceTimer-3.0')
local pairs, format, tinsert, tremove = pairs, format, tinsert, tremove

-- Configuration
local LAZY_MODULES = {
    -- Non-combat modules that can be loaded on demand
    "Blizzard",
    "DataBars",
    "DataTexts",
    "Tooltip",
    "Threat",
    "Totems",
    "DataPanels",
    "CopyChatFrame"
}

-- Core modules that should always be loaded
local CORE_MODULES = {
    "ActionBars", 
    "Bags", 
    "Chat", 
    "UnitFrames", 
    "Nameplates",
    "Auras",
    "Minimap"
}

-- Track delayed modules
local delayedModules = {}
local loadedModules = {}

function MOM:Initialize()
    -- Add settings to ElvUI config
    P.general.moduleOptimizer = {
        enable = false,  -- Off by default, needs /reload to take effect
        aggressiveMode = false,
        safeModeInCombat = true,
        dataTextOptimization = false,
        delayNonCoreModules = true
    }
    
    -- Register events
    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'SetupModules')
    self:RegisterEvent('PLAYER_REGEN_DISABLED', 'EnterCombat')
    self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ExitCombat')
    
    -- Register chat command
    E:RegisterChatCommand('elvmod', self.ChatCommand)
end

function MOM:ChatCommand(input)
    if input == "list" then
        MOM:ListModules()
    elseif input == "load" then
        MOM:LoadDelayedModules(true)
    elseif input == "stats" then
        MOM:PrintModuleStats()
    elseif input == "config" then
        E:ToggleOptions('advanced,general,moduleOptimizer')
    else
        E:Print("ElvUI Module Optimizer commands:")
        E:Print("/elvmod list - List module status")
        E:Print("/elvmod load - Load delayed modules")
        E:Print("/elvmod stats - Show module stats")
        E:Print("/elvmod config - Open configuration")
    end
end

function MOM:SetupModules()
    if not E.db.general.moduleOptimizer or not E.db.general.moduleOptimizer.enable then return end
    
    -- This function runs after ElvUI has initialized all modules
    -- We'll check which modules are safe to delay
    
    -- Track all modules
    for name, module in pairs(E.modules) do
        loadedModules[name] = true
    end
    
    -- If using aggressive mode, delay all non-core modules
    if E.db.general.moduleOptimizer.aggressiveMode then
        for name, module in pairs(E.modules) do
            local isCore = false
            for _, coreMod in pairs(CORE_MODULES) do
                if name == coreMod then
                    isCore = true
                    break
                end
            end
            
            if not isCore and not delayedModules[name] then
                -- Check if module is already initialized
                if module.Initialize and not module.initialized then
                    self:DelayModule(name, module)
                end
            end
        end
    -- Otherwise just delay known safe modules
    elseif E.db.general.moduleOptimizer.delayNonCoreModules then
        for _, name in pairs(LAZY_MODULES) do
            local module = E:GetModule(name, true)
            if module and module.Initialize and not module.initialized then
                self:DelayModule(name, module)
            end
        end
    end
    
    -- DataText optimization if enabled
    if E.db.general.moduleOptimizer.dataTextOptimization then
        self:OptimizeDataTexts()
    end
    
    self:ScheduleTimer('ReportDelayedModules', 5)
end

function MOM:DelayModule(name, module)
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

function MOM:LoadModule(name, force)
    local info = delayedModules[name]
    if not info or info.loaded then return end
    
    local module = info.module
    local origFunc = info.origInitialize
    
    -- Restore original function
    module.Initialize = origFunc
    
    -- Call it
    module:Initialize()
    info.loaded = true
    
    E:Print(format("Loaded delayed module: %s", name))
    return true
end

function MOM:LoadDelayedModules(force)
    local count = 0
    for name, info in pairs(delayedModules) do
        if not info.loaded then
            self:LoadModule(name, force)
            count = count + 1
        end
    end
    
    E:Print(format("Loaded %d delayed modules", count))
    return count
end

function MOM:ReportDelayedModules()
    local count = 0
    for name, info in pairs(delayedModules) do
        if not info.loaded then
            count = count + 1
        end
    end
    
    if count > 0 then
        E:Print(format("Optimized %d modules. Type /elvmod list to see details.", count))
    end
end

function MOM:EnterCombat()
    if not E.db.general.moduleOptimizer or not E.db.general.moduleOptimizer.enable then return end
    
    -- In safe mode, load all modules in combat
    if E.db.general.moduleOptimizer.safeModeInCombat then
        self:LoadDelayedModules(true)
    end
end

function MOM:ExitCombat()
    -- Nothing special needed here yet
end

function MOM:ListModules()
    E:Print("ElvUI Module Status:")
    
    -- List delayed modules first
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
    for name, module in pairs(E.modules) do
        if module.initialized then
            local status = ""
            for _, coreName in pairs(CORE_MODULES) do
                if name == coreName then
                    status = " |cff00ff00(core)|r"
                    break
                end
            end
            E:Print(format(" - %s%s", name, status))
            loadCount = loadCount + 1
        end
    end
end

function MOM:PrintModuleStats()
    local total = 0
    local loaded = 0
    local delayed = 0
    
    for name, _ in pairs(E.modules) do
        total = total + 1
    end
    
    for name, module in pairs(E.modules) do
        if module.initialized then
            loaded = loaded + 1
        end
    end
    
    for name, info in pairs(delayedModules) do
        if not info.loaded then
            delayed = delayed + 1
        end
    end
    
    E:Print("ElvUI Module Statistics:")
    E:Print(format("Total modules: %d", total))
    E:Print(format("Loaded modules: %d", loaded))
    E:Print(format("Delayed modules: %d", delayed))
    E:Print(format("Memory saved: ~%.1f MB (estimate)", delayed * 0.25))
end

function MOM:OptimizeDataTexts()
    local DT = E:GetModule('DataTexts')
    if not DT then return end
    
    -- This optimizes DataTexts by only loading them when moused over
    -- Only applies to non-essential datatexts
    local optimizableDatatexts = {
        'Agility', 'Armor', 'CallToArms', 'Crit', 'Durability', 
        'ElvUI', 'Gold', 'Haste', 'Intellect', 'Mastery', 'MovementSpeed',
        'Stamina', 'Strength', 'Versatility'
    }
    
    for _, name in pairs(optimizableDatatexts) do
        local datatext = DT.RegisteredDataTexts[name]
        if datatext and datatext.onClick then
            -- Wrap the datatext's update function to be on-demand
            local origUpdate = datatext.onUpdate
            if origUpdate then
                datatext.onUpdate = function(self, elapsed)
                    -- Only update when moused over or every 5 seconds
                    if self.lastUpdate and (GetTime() - self.lastUpdate < 5) and not MouseIsOver(self) then
                        return
                    end
                    self.lastUpdate = GetTime()
                    return origUpdate(self, elapsed)
                end
            end
        end
    end
end

E:RegisterModule(MOM:GetName())
