local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local ToggleFrame = ToggleFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame

local displayString = ""
local inRestrictedArea = false

local function Update(self, elapsed)
	if inRestrictedArea or not (E.MapInfo.coordsFirst or E.MapInfo.coordsWatching) then return end

	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 0.1 then
		self.text:SetFormattedText(displayString, E.MapInfo.xText or 0, E.MapInfo.yText or 0)
		self.timeSinceUpdate = 0
	end
end

local function OnEvent(self)
	E:Update_MapInfo('PLAYER_ENTERING_WORLD')
	if E.MapInfo.mapID then
		inRestrictedArea = false
		self:Show()
	else
		inRestrictedArea = true
		self.text:SetText("N/A")
		self:Hide()
	end
end

local function Click()
	ToggleFrame(WorldMapFrame)
end

local function ValueColorUpdate(hex)
	displayString = join("", hex, "%.1f|r", " , ", hex, "%.1f|r")
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Coords', {"PLAYER_ENTERING_WORLD"}, OnEvent, Update, Click, nil, nil, L["Coords"])
