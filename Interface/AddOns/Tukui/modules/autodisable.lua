------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------

if TukuiDB["actionbar"].bottomrows == 0 or TukuiDB["actionbar"].bottomrows > 2 then
	TukuiDB["actionbar"].bottomrows = 1
end

if TukuiDB["actionbar"].rightbars > 3 then
	TukuiDB["actionbar"].rightbars = 3
end

if not TukuiDB.lowversion and TukuiDB["actionbar"].bottomrows == 2 and TukuiDB["actionbar"].rightbars > 1 then
	TukuiDB["actionbar"].rightbars = 1
end

------------------------------------------------------------------------
-- overwrite font for some language
------------------------------------------------------------------------

if TukuiDB.client == "ruRU" then
	TukuiDB["media"].uffont = [[fonts\ARIALN.ttf]]
end

------------------------------------------------------------------------
-- auto-overwrite script config is X mod is found
------------------------------------------------------------------------

-- because users are too lazy to disable feature in config file
-- adding an auto disable if some mods are loaded

if (IsAddOnLoaded("Stuf") or IsAddOnLoaded("PitBull4") or IsAddOnLoaded("ShadowedUnitFrames") or IsAddOnLoaded("ag_UnitFrames")) then
	TukuiDB["unitframes"].enable = false
end

if (IsAddOnLoaded("TidyPlates") or IsAddOnLoaded("Aloft")) then
	TukuiDB["nameplate"].enable = false
end

if (IsAddOnLoaded("Dominos") or IsAddOnLoaded("Bartender4") or IsAddOnLoaded("Macaroon")) then
	TukuiDB["actionbar"].enable = false
end

if (IsAddOnLoaded("Mapster")) then
	TukuiDB["map"].enable = false
end

if (IsAddOnLoaded("Quartz") or IsAddOnLoaded("AzCastBar") or IsAddOnLoaded("eCastingBar")) then
	TukuiDB["unitframes"].unitcastbar = false
end

if (IsAddOnLoaded("Afflicted3") or IsAddOnLoaded("InterruptBar")) then
	TukuiDB["arena"].spelltracker = false
end