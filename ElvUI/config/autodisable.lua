------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local LSM = LibStub("LibSharedMedia-3.0")

if C["general"].classcolortheme == true then
	C["unitframes"].classcolor = true
end

E.UnpackColors = function(color)
	if not color.r then color.r = 0 end
	if not color.g then color.g = 0 end
	if not color.b then color.b = 0 end
	
	if color.a then
		return color.r, color.g, color.b, color.a
	else
		return color.r, color.g, color.b
	end
end

-------------------------------
-- Convert Colors
-------------------------------
C["unitframes"].POWER_MANA = {E.UnpackColors(C["unitframes"].POWER_MANA)}
C["unitframes"].POWER_RAGE = {E.UnpackColors(C["unitframes"].POWER_RAGE)}
C["unitframes"].POWER_FOCUS = {E.UnpackColors(C["unitframes"].POWER_FOCUS)}
C["unitframes"].POWER_ENERGY = {E.UnpackColors(C["unitframes"].POWER_ENERGY)}
C["unitframes"].POWER_RUNICPOWER = {E.UnpackColors(C["unitframes"].POWER_RUNICPOWER)}
C["media"].valuecolor = {E.UnpackColors(C["media"].valuecolor)}
C["media"].backdropcolor = {E.UnpackColors(C["media"].backdropcolor)}
C["media"].bordercolor = {E.UnpackColors(C["media"].bordercolor)}
C["media"].backdropfadecolor = {E.UnpackColors(C["media"].backdropfadecolor)}
C["actionbar"].expiringcolor = {E.UnpackColors(C["actionbar"].expiringcolor)}
C["actionbar"].secondscolor = {E.UnpackColors(C["actionbar"].secondscolor)}
C["actionbar"].minutescolor = {E.UnpackColors(C["actionbar"].minutescolor)}
C["actionbar"].hourscolor = {E.UnpackColors(C["actionbar"].hourscolor)}
C["actionbar"].dayscolor = {E.UnpackColors(C["actionbar"].dayscolor)}
C["nameplate"].goodcolor = {E.UnpackColors(C["nameplate"].goodcolor)}
C["nameplate"].badcolor = {E.UnpackColors(C["nameplate"].badcolor)}
C["nameplate"].goodtransitioncolor = {E.UnpackColors(C["nameplate"].goodtransitioncolor)}
C["nameplate"].badtransitioncolor = {E.UnpackColors(C["nameplate"].badtransitioncolor)}
C["unitframes"].healthbackdropcolor = {E.UnpackColors(C["unitframes"].healthbackdropcolor)}
C["unitframes"].nointerruptcolor = {E.UnpackColors(C["unitframes"].nointerruptcolor)}
C["unitframes"].castbarcolor = {E.UnpackColors(C["unitframes"].castbarcolor)}
C["unitframes"].healthcolor = {E.UnpackColors(C["unitframes"].healthcolor)}
C["classtimer"].buffcolor = {E.UnpackColors(C["classtimer"].buffcolor)}
C["classtimer"].debuffcolor = {E.UnpackColors(C["classtimer"].debuffcolor)}
C["classtimer"].proccolor = {E.UnpackColors(C["classtimer"].proccolor)}

-------------------------------
-- Load Shared Media Settings
-------------------------------
C["media"].font = LSM:Fetch("font", C["media"].font)
C["media"].uffont = LSM:Fetch("font", C["media"].uffont)
C["media"].dmgfont = LSM:Fetch("font", C["media"].dmgfont)
C["media"].normTex = LSM:Fetch("statusbar", C["media"].normTex)
C["media"].glossTex = LSM:Fetch("statusbar", C["media"].glossTex)
C["media"].glowTex = LSM:Fetch("border", C["media"].glowTex)
C["media"].blank = LSM:Fetch("background", C["media"].blank)
C["media"].whisper = LSM:Fetch("sound", C["media"].whisper)
C["media"].warning = LSM:Fetch("sound", C["media"].warning)

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------

if C["media"].glossyTexture == true then	
	C["media"].normTex2 = C["media"].glossTex
	C["media"].normTex = C["media"].glossTex
end

--April Fools Day
function E.FoolDayCheck()
	local month = tonumber(date("%m"))
	local day = tonumber(date("%d"))
	if month == 4 and day == 1 then
		return true
	else
		return false
	end
end

if E.FoolDayCheck() == true and FoolsDay ~= true then
	C["media"].backdropcolor = { 51/255, 0, 102/255 }
	C["media"].bordercolor = { 255/255,105/255,180/255 }
	C["unitframes"].healthcolor = C["media"].bordercolor
	C["media"].valuecolor = C["media"].bordercolor
	C["classtimer"].buffcolor = C["media"].bordercolor
	C["unitframes"].castbarcolor = C["media"].bordercolor
	
	local x = CreateFrame("Frame")
	x:RegisterEvent("PLAYER_ENTERING_WORLD")
	x:SetScript("OnEvent", function(self)
		E.Delay(15, print, "|cffFF69B4Your settings have been optimized for better performance. To disable these changes type /aprilfools.|r")
		self:UnregisterAllEvents()
	end)
	
end