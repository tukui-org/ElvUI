-- ElvUI Memory Optimization Demo Script
-- This script demonstrates the key features of the memory optimization system

-- The memory optimization system works automatically after installation,
-- but these settings can be adjusted for maximum performance benefit.

-- 1. Module Optimizer Settings
-- These settings control which modules are loaded and when

-- Enable Module Optimizer with aggressive mode
/script E.db.general.moduleOptimizer.enable = true
/script E.db.general.moduleOptimizer.aggressiveMode = true
/reload

-- To view the current status of module optimization:
/script print("Delayed modules: " .. (E:GetModule('ModuleOptimizer') and E:GetModule('ModuleOptimizer'):GetDelayedCount() or "Module optimizer not active"))

-- 2. Memory Optimizer Settings
-- These settings control how memory is managed

-- Enable Memory Optimizer with frequent optimization
/script E.db.general.memoryOptimizer.autoOptimize = true
/script E.db.general.memoryOptimizer.interval = 180  -- seconds
/reload

-- Force garbage collection manually (useful for testing)
/script collectgarbage("collect"); print("Garbage collection completed")

-- 3. Text Optimizer Settings
-- These settings control text rendering optimization

-- Enable Text Optimizer with FontString pooling
/script E.db.general.textOptimizer.enable = true
/script E.db.general.textOptimizer.enableFontStringPool = true
/reload

-- 4. WindTools Integration (if WindTools is installed)
-- Enable WindTools optimization
/script if E.db.general.windToolsOptimizer then E.db.general.windToolsOptimizer.enable = true; E:StaticPopup_Show('CONFIG_RL') end

-- 5. Monitor Memory Usage via ElvUI Options
-- Open ElvUI configuration (/ec) and navigate to:
-- General -> Memory Optimizer

-- 6. Memory Usage
-- Check current memory usage:
/script print("Current memory usage: " .. collectgarbage("count")/1024 .. " MB")
