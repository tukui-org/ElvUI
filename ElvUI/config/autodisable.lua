------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["general"].classcolortheme == true then
	local c = select(2, UnitClass("player"))
	local r, g, b = RAID_CLASS_COLORS[c].r, RAID_CLASS_COLORS[c].g, RAID_CLASS_COLORS[c].b
	C["media"].altbordercolor = {r, g, b, 1}
	C["unitframes"].classcolor = true
end

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------

if C["media"].glossyTexture ~= true then
	C["media"].normTex = [[Interface\AddOns\ElvUI\media\textures\normTex2]]
end