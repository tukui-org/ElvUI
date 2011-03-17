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
C["media"].font_ = LSM:Fetch("font", C["media"].font)
C["media"].uffont_ = LSM:Fetch("font", C["media"].uffont)
C["media"].dmgfont_ = LSM:Fetch("font", C["media"].dmgfont)
C["media"].normTex_ = LSM:Fetch("statusbar", C["media"].normTex)
C["media"].glossTex_ = LSM:Fetch("statusbar", C["media"].glossTex)
C["media"].glowTex_ = LSM:Fetch("border", C["media"].glowTex)
C["media"].blank_ = LSM:Fetch("background", C["media"].blank)
C["media"].whisper_ = LSM:Fetch("sound", C["media"].whisper)
C["media"].warning_ = LSM:Fetch("sound", C["media"].warning)

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------

if C["media"].glossyTexture == true then	
	C["media"].normTex_2 = C["media"].glossTex_
	C["media"].normTex_ = C["media"].glossTex_
end