-- reposition alt power bar (A new bar in Cataclysm) to top/center of the screen
-- this bar is seen for the first time in Twilight Highlands with tentacles quest serie.

PlayerPowerBarAlt:ClearAllPoints() 
PlayerPowerBarAlt:SetPoint("TOP", UIParent, "TOP", 0, -32) 
PlayerPowerBarAlt.ClearAllPoints = TukuiDB.dummy 
PlayerPowerBarAlt.SetPoint = TukuiDB.dummy

TargetFramePowerBarAlt:ClearAllPoints();
TargetFramePowerBarAlt:SetPoint("TOP", UIParent, "TOP", 0, -52);
TargetFramePowerBarAlt:SetParent("UIParent");
TargetFramePowerBarAlt.ClearAllPoints = TukuiDB.dummy;
TargetFramePowerBarAlt.SetPoint = TukuiDB.dummy;
TargetFramePowerBarAlt.SetParent = TukuiDB.dummy;

-- /run x = TargetFramePowerBarAlt x:ClearAllPoints(); x:SetPoint("TOP", UIParent, "TOP", 0, -52); x:SetParent("UIParent"); x.ClearAllPoints = function() end; x.SetPoint = function() end; x.SetParent = function() end;

-- /run PlayerPowerBarAlt:ClearAllPoints(); PlayerPowerBarAlt:SetPoint("TOP", UIParent, "TOP", 0, -32); PlayerPowerBarAlt.ClearAllPoints = function() end; PlayerPowerBarAlt.SetPoint = function() end;