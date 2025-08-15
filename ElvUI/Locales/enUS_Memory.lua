-- English localization for ElvUI memory optimizer modules
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvUI", "enUS", true)
if not L then return end

-- Memory Optimizer
L["Memory Optimizer"] = true
L["Memory Optimizer Settings"] = true
L["Auto Optimize"] = true
L["Automatically optimize memory usage periodically."] = true
L["Optimize Interval"] = true
L["How often to run memory optimization (in seconds)."] = true
L["Combat Delay"] = true
L["How long to wait after combat before optimizing (in seconds)."] = true
L["Texture Cache Size"] = true
L["Maximum size of texture cache (in MB)."] = true
L["Script Result Caching"] = true
L["Enable caching of script results to reduce CPU usage."] = true
L["Debug Mode"] = true
L["Enable debug output for memory optimization."] = true
L["Optimize Now"] = true
L["Run memory optimization immediately."] = true
L["Force Garbage Collection"] = true
L["Force Lua garbage collection."] = true

-- Module Optimizer
L["Module Optimizer"] = true
L["Module Optimizer Settings"] = true
L["WARNING: These settings require a UI reload to take effect."] = true
L["Enable Module Optimizer"] = true
L["Optimize ElvUI modules by loading some features on-demand."] = true
L["Aggressive Mode"] = true
L["Delay more modules for greater memory savings. May cause some features to not work until accessed."] = true
L["Safe Mode in Combat"] = true
L["Automatically load all delayed modules when entering combat."] = true
L["Delay Non-Core Modules"] = true
L["Delay loading of non-essential modules until needed."] = true
L["Optimize DataTexts"] = true
L["Update non-essential DataTexts less frequently to save CPU/memory."] = true
L["Load All Modules"] = true
L["Load all delayed modules immediately."] = true
L["The Module Optimizer delays loading of non-essential ElvUI modules until they are needed, reducing memory usage and improving performance."] = true
L["Total modules: %d"] = true
L["Loaded modules: %d"] = true
L["Delayed modules: %d"] = true
L["Estimated memory saved: ~%.1f MB"] = true

-- WindTools Optimizer
L["WindTools Optimizer"] = true
L["WindTools Optimizer Settings"] = true
L["Enable WindTools Optimizer"] = true
L["Optimize ElvUI WindTools modules by loading some features on-demand."] = true
L["The WindTools Optimizer delays loading of non-essential WindTools modules until they are needed, reducing memory usage and improving performance."] = true
L["Load all delayed WindTools modules immediately."] = true

-- Text Optimizer
L["Text Optimizer"] = true
L["Text Optimizer Settings"] = true
L["WARNING: These are experimental features that may cause UI issues in some situations. Use with caution."] = true
L["Enable Text Optimizer"] = true
L["Optimize text rendering to reduce CPU usage. This may cause some text to update slightly delayed."] = true
L["Throttle Interval"] = true
L["How often to update text elements (in seconds)."] = true
L["Smart Text Updates"] = true
L["Only update visible text elements to save CPU."] = true
L["Enable FontString Pooling"] = true
L["Recycle FontString objects to reduce memory usage."] = true
L["The Text Optimizer reduces CPU usage by limiting how often text elements are updated and recycling FontString objects."] = true

-- Memory Dashboard
L["Memory Dashboard"] = true
L["Memory Dashboard Settings"] = true
L["Open Dashboard"] = true
L["Show on Login"] = true
L["Automatically show the memory dashboard when logging in."] = true
L["Width"] = true
L["Width of the dashboard window."] = true
L["Height"] = true
L["Height of the dashboard window."] = true
L["Update Interval"] = true
L["How often to update the dashboard (in seconds)."] = true
L["Show System Information"] = true
L["Show system information at the top of the dashboard."] = true
L["Show CPU Usage"] = true
L["Show CPU usage information in the dashboard."] = true
L["Track History"] = true
L["Track memory usage history over time."] = true
L["History Limit"] = true
L["How many minutes of history to keep."] = true
L["Sorting and Filtering"] = true
L["Sort By"] = true
L["How to sort the addon list."] = true
L["Memory Usage"] = true
L["CPU Usage"] = true
L["Addon Name"] = true
L["Sort Order"] = true
L["Sort order for the addon list."] = true
L["Ascending"] = true
L["Descending"] = true
L["Filter Addons"] = true
L["Enter comma-separated partial names to filter the addon list. Leave empty to show all addons."] = true
L["Actions"] = true
L["Reset Statistics"] = true
L["Reset memory statistics and history."] = true
