-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("ElvUI", "enUS", true, true);
if not L then return; end

--Core
L["You cannot open the configuration menu while in combat."] = true
L["Uh oh, something has happened and your addon '%s' is missing or disabled."] = true

--Disable Blizzard
L['Remove Bar %d Action Page'] = true