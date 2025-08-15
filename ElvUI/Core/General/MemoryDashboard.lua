local E, L, V, P, G = unpack(ElvUI)
local MD = E:NewModule('MemoryDashboard', 'AceEvent-3.0', 'AceTimer-3.0')
local AceGUI = E.Libs.AceGUI
local format, table, pairs, ipairs, floor = format, table, pairs, ipairs, floor
local GetAddOnMemoryUsage, UpdateAddOnMemoryUsage = GetAddOnMemoryUsage, UpdateAddOnMemoryUsage
local UpdateAddOnCPUUsage, GetAddOnCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage
local collectgarbage, GetTime, IsAddOnLoaded = collectgarbage, GetTime, IsAddOnLoaded

-- Configuration
MD.config = {
    showOnLogin = false,
    width = 700,
    height = 500,
    updateInterval = 1,
    showSystemInfo = true,
    trackHistory = true,
    historyLimit = 30, -- 30 minutes
    showCPUUsage = true,
    sortBy = "memory", -- "memory", "cpu", "name"
    sortOrder = "desc", -- "asc", "desc"
    filterAddons = "" -- comma-separated list of addons to filter
}

-- State variables
MD.frame = nil
MD.isVisible = false
MD.addonData = {}
MD.history = {}
MD.historyTimers = {}

-- Statistics
MD.stats = {
    totalMemory = 0,
    totalCPU = 0,
    gcRuns = 0,
    startupMemory = 0,
    peakMemory = 0
}

function MD:Initialize()
    -- Setup configuration
    P.general.memoryDashboard = P.general.memoryDashboard or {
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
    
    self.config = E.db.general.memoryDashboard or self.config
    
    -- Register chat command
    E:RegisterChatCommand('elvmem', self.ChatCommand)
    E:RegisterChatCommand('elvdash', self.ChatCommand)
    
    -- Set initial stats
    self:ScheduleTimer("InitializeStats", 5)
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
end

function MD:InitializeStats()
    UpdateAddOnMemoryUsage()
    self.stats.startupMemory = collectgarbage("count") / 1024
    self.stats.peakMemory = self.stats.startupMemory
    
    -- If configured, show dashboard at login
    if self.config.showOnLogin then
        self:ScheduleTimer("ShowDashboard", 10)
    end
end

function MD:OnPlayerEnteringWorld()
    self:InitializeStats()
end

function MD:ChatCommand(msg)
    if msg == "show" or msg == "" then
        MD:ShowDashboard()
    elseif msg == "hide" then
        MD:HideDashboard()
    elseif msg == "reset" then
        MD:ResetStats()
        E:Print("Memory statistics reset.")
    elseif msg == "collect" then
        local before = collectgarbage("count") / 1024
        collectgarbage("collect")
        local after = collectgarbage("count") / 1024
        E:Print(format("Garbage collection complete. Memory freed: %.2f MB", before - after))
    elseif msg == "config" then
        E:ToggleOptions("general,memoryDashboard")
    else
        E:Print("ElvUI Memory Dashboard commands:")
        E:Print("/elvdash - Show memory dashboard")
        E:Print("/elvdash hide - Hide memory dashboard")
        E:Print("/elvdash reset - Reset memory statistics")
        E:Print("/elvdash collect - Force garbage collection")
        E:Print("/elvdash config - Open configuration")
    end
end

function MD:UpdateData()
    -- Update addon memory usage
    UpdateAddOnMemoryUsage()
    if self.config.showCPUUsage then
        UpdateAddOnCPUUsage()
    end
    
    -- Clear old data
    self.addonData = {}
    
    -- Get memory usage for all addons
    local totalMemory = 0
    local totalCPU = 0
    
    for i=1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        if IsAddOnLoaded(i) then
            local memory = GetAddOnMemoryUsage(i)
            local cpu = self.config.showCPUUsage and GetAddOnCPUUsage(i) or 0
            
            -- Skip if filtered
            if self:ShouldShowAddon(name) then
                table.insert(self.addonData, {
                    name = name,
                    memory = memory,
                    cpu = cpu
                })
                
                totalMemory = totalMemory + memory
                totalCPU = totalCPU + cpu
            end
        end
    end
    
    -- Sort data
    self:SortData()
    
    -- Update statistics
    self.stats.totalMemory = totalMemory / 1024  -- Convert to MB
    self.stats.totalCPU = totalCPU
    
    if totalMemory / 1024 > self.stats.peakMemory then
        self.stats.peakMemory = totalMemory / 1024
    end
    
    -- Save history if enabled
    if self.config.trackHistory then
        self:AddHistoryPoint(totalMemory / 1024, totalCPU)
    end
    
    return self.addonData
end

function MD:ShouldShowAddon(name)
    if not self.config.filterAddons or self.config.filterAddons == "" then
        return true
    end
    
    local filters = {strsplit(",", self.config.filterAddons)}
    for _, filter in ipairs(filters) do
        filter = strtrim(filter:lower())
        if filter ~= "" and name:lower():find(filter) then
            return true
        end
    end
    
    return false
end

function MD:SortData()
    local sortBy = self.config.sortBy
    local sortOrder = self.config.sortOrder
    
    table.sort(self.addonData, function(a, b)
        if sortBy == "memory" then
            if sortOrder == "asc" then
                return a.memory < b.memory
            else
                return a.memory > b.memory
            end
        elseif sortBy == "cpu" then
            if sortOrder == "asc" then
                return a.cpu < b.cpu
            else
                return a.cpu > b.cpu
            end
        else -- name
            if sortOrder == "asc" then
                return a.name < b.name
            else
                return a.name > b.name
            end
        end
    end)
end

function MD:AddHistoryPoint(memory, cpu)
    local time = GetTime()
    
    -- Add new point
    table.insert(self.history, {
        time = time,
        memory = memory,
        cpu = cpu
    })
    
    -- Remove old points
    while #self.history > self.config.historyLimit * 60 / self.config.updateInterval do
        table.remove(self.history, 1)
    end
end

function MD:ResetStats()
    self.stats.gcRuns = 0
    self.stats.peakMemory = collectgarbage("count") / 1024
    wipe(self.history)
end

function MD:FormatMemory(value)
    if value > 1024 then
        return format("%.2f GB", value / 1024)
    else
        return format("%.2f MB", value)
    end
end

function MD:ShowDashboard()
    if self.frame then
        self.frame:Show()
        self.isVisible = true
        return
    end
    
    -- Create main frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("ElvUI Memory Dashboard")
    frame:SetLayout("Flow")
    frame:SetWidth(self.config.width)
    frame:SetHeight(self.config.height)
    frame:SetCallback("OnClose", function(widget) 
        MD.isVisible = false
        AceGUI:Release(widget)
        MD.frame = nil
    end)
    self.frame = frame
    self.isVisible = true
    
    -- Create system info panel
    local infoPanel = AceGUI:Create("SimpleGroup")
    infoPanel:SetFullWidth(true)
    infoPanel:SetLayout("Flow")
    frame:AddChild(infoPanel)
    
    -- Current Memory
    local memoryText = AceGUI:Create("Label")
    memoryText:SetWidth(180)
    infoPanel:AddChild(memoryText)
    
    -- Peak Memory
    local peakText = AceGUI:Create("Label")
    peakText:SetWidth(180)
    infoPanel:AddChild(peakText)
    
    -- Total CPU
    local cpuText = AceGUI:Create("Label")
    cpuText:SetWidth(180)
    infoPanel:AddChild(cpuText)
    
    -- GC Button
    local gcButton = AceGUI:Create("Button")
    gcButton:SetText("Run Garbage Collector")
    gcButton:SetWidth(200)
    gcButton:SetCallback("OnClick", function()
        local before = collectgarbage("count") / 1024
        collectgarbage("collect")
        local after = collectgarbage("count") / 1024
        MD.stats.gcRuns = MD.stats.gcRuns + 1
        E:Print(format("Garbage collection complete. Memory freed: %.2f MB", before - after))
    end)
    infoPanel:AddChild(gcButton)
    
    -- Separator
    local sep = AceGUI:Create("Heading")
    sep:SetFullWidth(true)
    frame:AddChild(sep)
    
    -- Create scrolling table
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullHeight(true)
    frame:AddChild(scrollFrame)
    
    -- Header row
    local headerGroup = AceGUI:Create("SimpleGroup")
    headerGroup:SetFullWidth(true)
    headerGroup:SetLayout("Flow")
    scrollFrame:AddChild(headerGroup)
    
    -- Addon Name Header
    local nameHeader = AceGUI:Create("Button")
    nameHeader:SetText("Addon Name")
    nameHeader:SetWidth(350)
    nameHeader:SetCallback("OnClick", function()
        if MD.config.sortBy == "name" then
            MD.config.sortOrder = MD.config.sortOrder == "asc" and "desc" or "asc"
        else
            MD.config.sortBy = "name"
            MD.config.sortOrder = "asc"
        end
        E.db.general.memoryDashboard.sortBy = MD.config.sortBy
        E.db.general.memoryDashboard.sortOrder = MD.config.sortOrder
        MD:UpdateDashboard()
    end)
    headerGroup:AddChild(nameHeader)
    
    -- Memory Header
    local memoryHeader = AceGUI:Create("Button")
    memoryHeader:SetText("Memory Usage")
    memoryHeader:SetWidth(150)
    memoryHeader:SetCallback("OnClick", function()
        if MD.config.sortBy == "memory" then
            MD.config.sortOrder = MD.config.sortOrder == "asc" and "desc" or "asc"
        else
            MD.config.sortBy = "memory"
            MD.config.sortOrder = "desc"
        end
        E.db.general.memoryDashboard.sortBy = MD.config.sortBy
        E.db.general.memoryDashboard.sortOrder = MD.config.sortOrder
        MD:UpdateDashboard()
    end)
    headerGroup:AddChild(memoryHeader)
    
    -- CPU Header
    local cpuHeader = AceGUI:Create("Button")
    cpuHeader:SetText("CPU Usage")
    cpuHeader:SetWidth(150)
    cpuHeader:SetCallback("OnClick", function()
        if MD.config.sortBy == "cpu" then
            MD.config.sortOrder = MD.config.sortOrder == "asc" and "desc" or "asc"
        else
            MD.config.sortBy = "cpu"
            MD.config.sortOrder = "desc"
        end
        E.db.general.memoryDashboard.sortBy = MD.config.sortBy
        E.db.general.memoryDashboard.sortOrder = MD.config.sortOrder
        MD:UpdateDashboard()
    end)
    headerGroup:AddChild(cpuHeader)
    
    -- Container for addon rows
    local addonContainer = AceGUI:Create("SimpleGroup")
    addonContainer:SetFullWidth(true)
    addonContainer:SetLayout("Flow")
    scrollFrame:AddChild(addonContainer)
    self.addonContainer = addonContainer
    
    -- Update function
    local function UpdateUI()
        if not MD.frame then return end
        
        -- Update system info
        memoryText:SetText(format("Memory: %s", MD:FormatMemory(MD.stats.totalMemory)))
        peakText:SetText(format("Peak: %s", MD:FormatMemory(MD.stats.peakMemory)))
        cpuText:SetText(format("CPU: %.2f ms", MD.stats.totalCPU))
        
        -- Clear addon list
        addonContainer:ReleaseChildren()
        
        -- Update addon data
        MD:UpdateData()
        
        -- Create addon rows
        for i, addon in ipairs(MD.addonData) do
            local row = AceGUI:Create("SimpleGroup")
            row:SetFullWidth(true)
            row:SetLayout("Flow")
            
            local nameLabel = AceGUI:Create("Label")
            nameLabel:SetWidth(350)
            nameLabel:SetText(addon.name)
            row:AddChild(nameLabel)
            
            local memLabel = AceGUI:Create("Label")
            memLabel:SetWidth(150)
            memLabel:SetText(format("%.2f MB", addon.memory / 1024))
            row:AddChild(memLabel)
            
            local cpuLabel = AceGUI:Create("Label")
            cpuLabel:SetWidth(150)
            cpuLabel:SetText(format("%.2f ms", addon.cpu))
            row:AddChild(cpuLabel)
            
            addonContainer:AddChild(row)
            
            -- Color alternating rows
            if i % 2 == 0 then
                row.frame:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
            end
        end
    end
    
    -- Initial update
    UpdateUI()
    
    -- Start update timer
    self.updateTimer = self:ScheduleRepeatingTimer(UpdateUI, self.config.updateInterval)
end

function MD:UpdateDashboard()
    if not self.frame then return end
    
    -- Force update if frame exists
    if self.updateTimer then
        self:CancelTimer(self.updateTimer)
    end
    
    -- Call the update directly and restart the timer
    self.frame.OnUpdate()
    self.updateTimer = self:ScheduleRepeatingTimer(self.frame.OnUpdate, self.config.updateInterval)
end

function MD:HideDashboard()
    if self.frame then
        self.frame:Hide()
        self.isVisible = false
        
        -- Stop update timer
        if self.updateTimer then
            self:CancelTimer(self.updateTimer)
            self.updateTimer = nil
        end
    end
end

E:RegisterModule(MD:GetName())
