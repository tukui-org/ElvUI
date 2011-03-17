------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local LSM = LibStub("LibSharedMedia-3.0")

if C["general"].classcolortheme == true then
	local c = select(2, UnitClass("player"))
	local r, g, b = RAID_CLASS_COLORS[c].r, RAID_CLASS_COLORS[c].g, RAID_CLASS_COLORS[c].b
	C["media"].bordercolor = {r, g, b, 1}
	C["unitframes"].classcolor = true
end

-------------------------------
-- Load Shared Media Settings
-------------------------------
C["media"].font = LSM:Fetch("font", C["media"].font_)
C["media"].uffont = LSM:Fetch("font", C["media"].uffont_)
C["media"].dmgfont = LSM:Fetch("font", C["media"].dmgfont_)
C["media"].normTex = LSM:Fetch("statusbar", C["media"].normTex_)
C["media"].glossTex = LSM:Fetch("statusbar", C["media"].glossTex_)
C["media"].glowTex = LSM:Fetch("border", C["media"].glowTex_)
C["media"].blank = LSM:Fetch("background", C["media"].blank_)
C["media"].whisper = LSM:Fetch("sound", C["media"].whisper_)
C["media"].warning = LSM:Fetch("sound", C["media"].warning_)

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------

if C["media"].glossyTexture == true then	
	C["media"].normTex_2 = C["media"].glossTex
	C["media"].normTex = C["media"].glossTex
end