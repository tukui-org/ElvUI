local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local GetPlayerMapPosition = GetPlayerMapPosition
local ToggleFrame = ToggleFrame

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame

local displayString = ""
local x, y = 0, 0
local inRestrictedArea = false

local function Update(self, elapsed)
	if inRestrictedArea then return; end

	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 0.1 then
		x, y = GetPlayerMapPosition("player")
		x = E:Round(100 * x, 1)
		y = E:Round(100 * y, 1)

		self.text:SetFormattedText(displayString, x, y)
		self.timeSinceUpdate = 0
	end
end

local function OnEvent(self)
	local x = GetPlayerMapPosition("player")
	if not x then
		inRestrictedArea = true
		self.text:SetText("N/A")
		self:Hide()
	else
		inRestrictedArea = false
		self:Show()
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
