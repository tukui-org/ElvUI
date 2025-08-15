local E, L, V, P, G = unpack(ElvUI)
local TO = E:NewModule('TextOptimizer', 'AceTimer-3.0')
local pairs, format, wipe = pairs, format, wipe

-- Configuration
local CONFIG = {
    ENABLE = true,
    THROTTLE_INTERVAL = 0.2,  -- Only update text every 0.2 seconds
    SMART_TEXT_UPDATES = true, -- Only update visible text elements
    ENABLE_FONTSTRING_POOL = true -- Use a fontstring pool for common text elements
}

-- Cache tables
local updateQueue = {}
local fontStringPool = {}
local fontStringPoolSize = 0
local fontStringUsageCount = 0
local throttledFontStrings = {}
local isThrottling = false
local lastUpdateTime = 0

function TO:Initialize()
    -- Set up configuration
    CONFIG.ENABLE = E.db.general.textOptimizer and E.db.general.textOptimizer.enable or CONFIG.ENABLE
    CONFIG.THROTTLE_INTERVAL = E.db.general.textOptimizer and E.db.general.textOptimizer.throttleInterval or CONFIG.THROTTLE_INTERVAL
    CONFIG.SMART_TEXT_UPDATES = E.db.general.textOptimizer and E.db.general.textOptimizer.smartTextUpdates or CONFIG.SMART_TEXT_UPDATES
    CONFIG.ENABLE_FONTSTRING_POOL = E.db.general.textOptimizer and E.db.general.textOptimizer.enableFontStringPool or CONFIG.ENABLE_FONTSTRING_POOL

    -- Only continue if enabled
    if not CONFIG.ENABLE then return end

    -- Set up text optimization
    self:OptimizeText()
    
    -- Start update queue processor
    self:ScheduleRepeatingTimer("ProcessUpdateQueue", CONFIG.THROTTLE_INTERVAL)
    
    -- Register chat command
    E:RegisterChatCommand('elvtext', self.ChatCommand)
end

function TO:ChatCommand(input)
    if input == "stats" then
        TO:PrintStats()
    elseif input == "debug" then
        TO:ToggleDebug()
    else
        E:Print("ElvUI Text Optimizer commands:")
        E:Print("/elvtext stats - Show text optimization stats")
        E:Print("/elvtext debug - Toggle debug mode")
    end
end

function TO:OptimizeText()
    -- Hook the SetText method to throttle updates
    if CONFIG.SMART_TEXT_UPDATES then
        hooksecurefunc("FontString_SetText", function(fontString, text)
            if not fontString or fontString.TO_Optimized then return end
            
            -- Skip this optimization for nameplates and unit frames text
            if fontString:GetObjectType() == "FontString" and fontString:GetParent() then
                local parent = fontString:GetParent()
                local grandParent = parent and parent:GetParent()
                
                -- Skip optimization for critical UI elements
                if parent and (
                    parent:GetName() and (
                        parent:GetName():find("NamePlate") or 
                        parent:GetName():find("UnitFrame") or
                        parent:GetName():find("InfoBar") or
                        parent:GetName():find("CastBar")
                    )
                ) then
                    return
                end
                
                -- Skip optimization for chat frames
                if parent and parent:GetObjectType() == "ScrollingMessageFrame" then
                    return
                end
                
                -- Add to throttled font strings
                throttledFontStrings[fontString] = {
                    text = text,
                    lastUpdate = GetTime(),
                    updateCount = (throttledFontStrings[fontString] and throttledFontStrings[fontString].updateCount or 0) + 1
                }
                
                -- Add to update queue
                updateQueue[fontString] = text
            end
        end)
    end
    
    -- Create FontString pool if enabled
    if CONFIG.ENABLE_FONTSTRING_POOL then
        self:SetupFontStringPool()
    end
end

function TO:ProcessUpdateQueue()
    local now = GetTime()
    if now - lastUpdateTime < CONFIG.THROTTLE_INTERVAL then
        return
    end
    lastUpdateTime = now
    
    local processed = 0
    local skipped = 0
    
    for fontString, text in pairs(updateQueue) do
        -- Only update if fontString exists and is shown
        if fontString and fontString:GetObjectType() == "FontString" and fontString:IsVisible() then
            fontString.TO_Optimized = true
            fontString:SetText(text)
            fontString.TO_Optimized = nil
            processed = processed + 1
        else
            skipped = skipped + 1
        end
    end
    
    wipe(updateQueue)
end

function TO:SetupFontStringPool()
    -- Create a pool of FontStrings for reuse
    local createFontString = CreateFrame("Frame").CreateFontString
    
    -- Hook the CreateFontString method
    hooksecurefunc("Frame_CreateFontString", function(frame, name, layer, inherits)
        fontStringUsageCount = fontStringUsageCount + 1
    end)
    
    -- Replace the CreateFontString method with our pooled version
    CreateFrame("Frame").CreateFontString = function(self, name, layer, inherits)
        -- Try to get one from the pool if it exists
        local fontString
        if fontStringPoolSize > 0 and inherits then
            for i, fs in pairs(fontStringPool) do
                if fs.inheritedFrom == inherits then
                    fontString = fs
                    fontStringPool[i] = nil
                    fontStringPoolSize = fontStringPoolSize - 1
                    break
                end
            end
        end
        
        -- Create a new one if not found in pool
        if not fontString then
            fontString = createFontString(self, name, layer, inherits)
            fontString.inheritedFrom = inherits
        end
        
        -- Track total usage
        fontStringUsageCount = fontStringUsageCount + 1
        
        return fontString
    end
    
    -- Hook frame deletion to recycle FontStrings
    hooksecurefunc(GameTooltip, "Hide", function(self)
        -- When tooltips hide, check for fontstrings to recycle
        if CONFIG.ENABLE_FONTSTRING_POOL and self.textLeft and #self.textLeft > 0 then
            for i=1, #self.textLeft do
                if self.textLeft[i] and not self.textLeft[i]:GetText() then
                    -- Store in the pool
                    fontStringPoolSize = fontStringPoolSize + 1
                    fontStringPool[fontStringPoolSize] = self.textLeft[i]
                    self.textLeft[i] = nil
                end
            end
        end
    end)
end

function TO:PrintStats()
    E:Print("ElvUI Text Optimizer Statistics:")
    E:Print(format("FontStrings in use: %d", fontStringUsageCount))
    E:Print(format("FontStrings in pool: %d", fontStringPoolSize))
    E:Print(format("Throttled text updates: %d", self:CountTable(throttledFontStrings)))
end

function TO:ToggleDebug()
    CONFIG.DEBUG = not CONFIG.DEBUG
    E:Print("Text Optimizer Debug: " .. (CONFIG.DEBUG and "Enabled" or "Disabled"))
end

function TO:CountTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

E:RegisterModule(TO:GetName())
