local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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

local function Update(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 0.1 then
		x, y = GetPlayerMapPosition("player")
		x = E:Round(100 * x, 1)
		y = E:Round(100 * y, 1)

		self.text:SetFormattedText(displayString, x, y)
		self.timeSinceUpdate = 0
	end
end

local function Click()
	ToggleFrame(WorldMapFrame)
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", hex, "%.1f|r", " , ", hex, "%.1f|r")
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
DT:RegisterDatatext('Coords', nil, nil, Update, Click)
