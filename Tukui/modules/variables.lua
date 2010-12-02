----------------------------------------------------------------
-- TUKUI VARS
----------------------------------------------------------------

TukuiCF = { }
TukuiDB = { }
tukuilocal = { }

TukuiDB.dummy = function() return end
TukuiDB.myname, _ = UnitName("player")
TukuiDB.myrealm = GetRealmName()
_, TukuiDB.myclass = UnitClass("player") 
TukuiDB.client = GetLocale() 
TukuiDB.resolution = GetCurrentResolution()
TukuiDB.getscreenresolution = select(TukuiDB.resolution, GetScreenResolutions())
TukuiDB.version = GetAddOnMetadata("Tukui", "Version")
TukuiDB.incombat = UnitAffectingCombat("player")
TukuiDB.patch = GetBuildInfo()
TukuiDB.level = UnitLevel("player")
TukuiDB.IsElvsEdit = true
BINDING_HEADER_TUKUI = GetAddOnMetadata("Tukui", "Title") --Header name inside keybinds menu