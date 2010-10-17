------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------

if TukuiCF["actionbar"].bottomrows == 0 or TukuiCF["actionbar"].bottomrows > 2 then
	TukuiCF["actionbar"].bottomrows = 1
end

if TukuiCF["actionbar"].rightbars > 3 then
	TukuiCF["actionbar"].rightbars = 3
end

if TukuiCF["actionbar"].bottomrows == 2 and TukuiCF["actionbar"].rightbars > 1 and not TukuiDB.lowversion then
	TukuiCF["actionbar"].rightbars = 1
end

------------------------------------------------------------------------
-- overwrite font for some language
------------------------------------------------------------------------

if TukuiDB.client == "ruRU" then
	TukuiCF["media"].uffont = [[fonts\ARIALN.ttf]]
elseif TukuiDB.client == "zhTW" or TukuiDB.client == "zhCN" then
	TukuiCF["media"].uffont = [[fonts\bLEI00D.ttf]]
	TukuiCF["media"].font = [[fonts\bLEI00D.ttf]]
	TukuiCF["media"].dmgfont = [[fonts\bLEI00D.ttf]]
end

------------------------------------------------------------------------
-- auto-overwrite script config is X mod is found
------------------------------------------------------------------------

-- because users are too lazy to disable feature in config file
-- adding an auto disable if some mods are loaded

if (IsAddOnLoaded("Stuf") or IsAddOnLoaded("PitBull4") or IsAddOnLoaded("ShadowedUnitFrames") or IsAddOnLoaded("ag_UnitFrames")) then
	TukuiCF["unitframes"].enable = false
end

if (IsAddOnLoaded("TidyPlates") or IsAddOnLoaded("Aloft")) then
	TukuiCF["nameplate"].enable = false
end

if (IsAddOnLoaded("Dominos") or IsAddOnLoaded("Bartender4") or IsAddOnLoaded("Macaroon")) then
	TukuiCF["actionbar"].enable = false
end

if (IsAddOnLoaded("Mapster")) then
	TukuiCF["map"].enable = false
end

if (IsAddOnLoaded("Prat") or IsAddOnLoaded("Chatter")) then
	TukuiCF["chat"].enable = false
end

if (IsAddOnLoaded("Quartz") or IsAddOnLoaded("AzCastBar") or IsAddOnLoaded("eCastingBar")) then
	TukuiCF["unitframes"].unitcastbar = false
end

if (IsAddOnLoaded("Afflicted3") or IsAddOnLoaded("InterruptBar")) then
	TukuiCF["arena"].spelltracker = false
end

if (IsAddOnLoaded("TipTac")) then
	TukuiCF["tooltip"].enable = false
end

if (IsAddOnLoaded("Gladius")) then
	TukuiCF["arena"].unitframes = false
end

------------------------------------------------------------------------
-- Others
------------------------------------------------------------------------

-- auto-disable tooltip on unit frame if tooltip on cursor is enabled.
if TukuiCF.tooltip.cursor and not TukuiCF.tooltip.hideuf then
	TukuiCF.tooltip.hideuf = true
end