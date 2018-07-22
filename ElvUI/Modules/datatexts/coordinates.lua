local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local ToggleFrame = ToggleFrame
local CreateFrame = CreateFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame

local displayString = ""
local inRestrictedArea = false
local watcher = CreateFrame("Frame")

local function Update(self, elapsed)
	if inRestrictedArea or not self.dt or not (E.MapInfo.coordsCalled or E.MapInfo.coordsWatching) then return end

	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 0.1 then
		self.dt.text:SetFormattedText(displayString, E.MapInfo.xText or 0, E.MapInfo.yText or 0)
		self.timeSinceUpdate = 0
	end
end

local function OnEvent(self)
	E:MapInfo_Update('PLAYER_ENTERING_WORLD')

	if watcher.dt ~= self then
		watcher.dt = self
	end

	if E.MapInfo.x and E.MapInfo.y then
		inRestrictedArea = false
		watcher:SetScript("OnUpdate", Update)
	else
		inRestrictedArea = true
		self.text:SetText("N/A")
		watcher:SetScript("OnUpdate", nil)
	end
end

local function Click()
	ToggleFrame(WorldMapFrame)
end

local function ValueColorUpdate(hex)
	displayString = join("", hex, "%.2f|r", " , ", hex, "%.2f|r")
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Coords', {"PLAYER_ENTERING_WORLD"}, OnEvent, nil, Click, nil, nil, L["Coords"])
