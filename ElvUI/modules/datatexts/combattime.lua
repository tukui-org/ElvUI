local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local displayNumberString = ''
local lastPanel;
local join = string.join
local timer = 0
local startTime = 0

local floor = math.floor
local function OnUpdate(self)
	timer = GetTime() - startTime

	self.text:SetFormattedText(displayNumberString, L["Combat Time"], format("%02d:%02d:%02d", floor(timer/60), timer % 60, (timer - floor(timer)) * 100))
end

local function OnEvent(self, event, unit)
	if event == "PLAYER_REGEN_DISABLED" then
		timer = 0
		startTime = GetTime()
		self:SetScript("OnUpdate", OnUpdate)
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:SetScript("OnUpdate", nil)
	else
		self.text:SetFormattedText(displayNumberString, L["Combat Time"], "00:00:00")
	end

	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join("", "%s: ", hex, "%s|r")
	
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
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
DT:RegisterDatatext('Combat Time', {"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED"}, OnEvent)
