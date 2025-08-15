local E, L, V, P, G = unpack(ElvUI)

-- Register our new memory optimization modules
local files = {
    "Core\\General\\MemoryOptimizer.lua",
    "Core\\General\\ModuleOptimizer.lua",
    "Core\\General\\TextOptimizer.lua",
    "Core\\General\\MemoryDashboard.lua",
    "Core\\Compatibility\\WindToolsOptimizer.lua",
    "Options\\General_MemoryOptimizer.lua",
    "Options\\General_ModuleOptimizer.lua",
    "Options\\General_TextOptimizer.lua",
    "Options\\General_MemoryDashboard.lua",
    "Options\\General_WindToolsOptimizer.lua",
    "Locales\\enUS_Memory.lua"
}

-- Load all our files
for _, file in pairs(files) do
    local path = "ElvUI\\" .. file
    local f = _G.debugstack and loadfile(path) or nil
    if f then
        f()
    end
end

-- Initialize our memory optimization system
E:RegisterModule('MemoryOptimizationSystem', function()
    -- Add memory optimization chat command
    E:RegisterChatCommand('elvopts', function(msg)
        if msg == "" or msg == "help" then
            E:Print("ElvUI Memory Optimization Commands:")
            E:Print("/elvmem - Memory optimizer commands")
            E:Print("/elvmod - Module optimizer commands")
            E:Print("/elvtext - Text optimizer commands")
            E:Print("/elvdash - Memory dashboard commands")
            E:Print("/elvwt - WindTools optimizer commands")
            E:Print("/elvopts config - Open memory optimization config")
        elseif msg == "config" then
            E:ToggleOptions("general,memoryOptimizer")
        end
    end)
    
    -- Memory Usage DataText
    local DT = E:GetModule('DataTexts')
    if DT then
        DT:RegisterDatatext('Memory Usage', 'System', {'PLAYER_ENTERING_WORLD'}, 
            function(self)
                -- OnEvent
                self.text:SetFormattedText("Memory: %.2f MB", collectgarbage("count") / 1024)
            end,
            function(self)
                -- OnUpdate
                if not self.lastUpdate or (GetTime() - self.lastUpdate > 5) then
                    self.text:SetFormattedText("Memory: %.2f MB", collectgarbage("count") / 1024)
                    self.lastUpdate = GetTime()
                end
            end,
            function(self)
                -- OnClick
                E:GetModule('MemoryDashboard'):ShowDashboard()
            end,
            function(self)
                -- OnEnter
                DT.tooltip:ClearLines()
                DT.tooltip:AddLine("ElvUI Memory Usage")
                DT.tooltip:AddLine(" ")
                
                UpdateAddOnMemoryUsage()
                DT.tooltip:AddDoubleLine("ElvUI:", FormatMemory(GetAddOnMemoryUsage("ElvUI")), 1, 1, 1, 1, 1, 1)
                if IsAddOnLoaded("ElvUI_Options") then
                    DT.tooltip:AddDoubleLine("ElvUI Options:", FormatMemory(GetAddOnMemoryUsage("ElvUI_Options")), 1, 1, 1, 1, 1, 1)
                end
                if IsAddOnLoaded("ElvUI_SLE") then
                    DT.tooltip:AddDoubleLine("ElvUI S&L:", FormatMemory(GetAddOnMemoryUsage("ElvUI_SLE")), 1, 1, 1, 1, 1, 1)
                end
                if IsAddOnLoaded("ElvUI_WindTools") then
                    DT.tooltip:AddDoubleLine("ElvUI WindTools:", FormatMemory(GetAddOnMemoryUsage("ElvUI_WindTools")), 1, 1, 1, 1, 1, 1)
                end
                DT.tooltip:AddDoubleLine(" ", " ")
                DT.tooltip:AddDoubleLine("Total Memory Usage:", FormatMemory(collectgarbage("count")*1024), 1, 1, 1, 0, 1, 0)
                
                DT.tooltip:AddLine(" ")
                DT.tooltip:AddLine("Left Click: Open Memory Dashboard")
                DT.tooltip:AddLine("Right Click: Run Garbage Collection")
                
                DT.tooltip:Show()
            end
        )
    end
end)

-- Helper function for the datatext
local function FormatMemory(memory)
    local format = string.format
    
    if memory > 1024*1024 then
        return format("%.2f GB", memory/1024/1024)
    elseif memory > 1024 then
        return format("%.2f MB", memory/1024)
    else
        return format("%.2f KB", memory)
    end
end
