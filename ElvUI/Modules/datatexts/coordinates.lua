local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local ToggleFrame = ToggleFrame
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetPlayerMapPosition = C_Map.GetPlayerMapPosition

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame

local displayString = ""
local x, y = 0, 0
local inRestrictedArea = false

local function Update(self, elapsed)
	if inRestrictedArea then return; end

	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 0.1 then
		local mapID = C_Map_GetBestMapForUnit("player")
		local mapPos = mapID and C_Map_GetPlayerMapPosition(mapID, "player")
		if mapPos then x, y = mapPos:GetXY() end

		x = (mapPos and x) and E:Round(100 * x, 1) or 0
		y = (mapPos and y) and E:Round(100 * y, 1) or 0

		self.text:SetFormattedText(displayString, x, y)
		self.timeSinceUpdate = 0
	end
end

local function OnEvent(self)
	local mapID = C_Map_GetBestMapForUnit("player")
	local mapPos = mapID and C_Map_GetPlayerMapPosition(mapID, "player")
	if mapPos then x, y = mapPos:GetXY() end
	if mapPos and x and y then
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
