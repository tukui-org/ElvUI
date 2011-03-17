------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local LSM = LibStub("LibSharedMedia-3.0")

if DB["general"].classcolortheme == true then
	local c = select(2, UnitClass("player"))
	local r, g, b = RAID_CLASS_COLORS[c].r, RAID_CLASS_COLORS[c].g, RAID_CLASS_COLORS[c].b
	DB["media"].bordercolor = {r, g, b, 1}
	DB["unitframes"].classcolor = true
end

-------------------------------
-- Load Shared Media Settings
-------------------------------
DB["media"].font_ = LSM:Fetch("font", DB["media"].font)
DB["media"].uffont_ = LSM:Fetch("font", DB["media"].uffont)
DB["media"].dmgfont_ = LSM:Fetch("font", DB["media"].dmgfont)
DB["media"].normTex_ = LSM:Fetch("statusbar", DB["media"].normTex)
DB["media"].glossTex_ = LSM:Fetch("statusbar", DB["media"].glossTex)
DB["media"].glowTex_ = LSM:Fetch("border", DB["media"].glowTex)
DB["media"].blank_ = LSM:Fetch("background", DB["media"].blank)
DB["media"].whisper_ = LSM:Fetch("sound", DB["media"].whisper)
DB["media"].warning_ = LSM:Fetch("sound", DB["media"].warning)

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------

if DB["media"].glossyTexture == true then	
	DB["media"].normTex_2 = DB["media"].glossTex_
	DB["media"].normTex_ = DB["media"].glossTex_
end