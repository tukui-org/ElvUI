local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local floor = math.floor
local format, join = string.format, string.join
--WoW API / Variables
local GetTime = GetTime
local IsInInstance = IsInInstance

local displayNumberString = ''
local lastPanel;
local timer = 0
local startTime = 0
local timerText = L["Combat"]

local function OnUpdate(self)
	timer = GetTime() - startTime

	self.text:SetFormattedText(displayNumberString, timerText, format("%02d:%02d.%02d", floor(timer/60), timer % 60, (timer - floor(timer)) * 100))
end

local function DelayOnUpdate(self, elapsed)
	startTime = startTime - elapsed

	if(startTime <= 0) then
		startTime = GetTime()
		timer = 0
		self:SetScript("OnUpdate", OnUpdate)
	end
end

local function OnEvent(self, event, _, timeSeconds)
	local _, instanceType = IsInInstance()
	if(event == "START_TIMER" and instanceType == "arena") then
		startTime = timeSeconds
		timer = 0
		timerText = L["Arena"]
		self.text:SetFormattedText(displayNumberString, timerText, "00:00:00")
		self:SetScript("OnUpdate", DelayOnUpdate)
	elseif(event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_REGEN_ENABLED" and instanceType ~= "arena")) then
		self:SetScript("OnUpdate", nil)
	elseif(event == "PLAYER_REGEN_DISABLED" and instanceType ~= "arena") then
		startTime = GetTime()
		timer = 0
		timerText = L["Combat"]
		self:SetScript("OnUpdate", OnUpdate)
	elseif(not self.text:GetText()) then
		self.text:SetFormattedText(displayNumberString, timerText, format("%02d:%02d:%02d", floor(timer/60), timer % 60, (timer - floor(timer)) * 100))
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Combat/Arena Time', {"START_TIMER", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, OnEvent, nil, nil, nil, nil, L["Combat/Arena Time"])
