local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format, strjoin = format, strjoin
local date = date

local GetGameTime = GetGameTime
local RequestRaidInfo = RequestRaidInfo
local TIMEMANAGER_TOOLTIP_LOCALTIME = TIMEMANAGER_TOOLTIP_LOCALTIME
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME

local APM = { TIMEMANAGER_PM, TIMEMANAGER_AM }
local ukDisplayFormat, europeDisplayFormat = '', ''
local europeDisplayFormat_nocolor = strjoin("", "%02d", ":|r%02d")
local ukDisplayFormat_nocolor = strjoin("", "", "%d", ":|r%02d", " %s|r")
local lockoutColorNormal = { r=.8,g=.8,b=.8 }
local enteredFrame, curHr, curMin, curAmPm = false

local Update, lastPanel

local function ValueColorUpdate(hex)
	europeDisplayFormat = strjoin("", "%02d", hex, ":|r%02d")
	ukDisplayFormat = strjoin("", "", "%d", hex, ":|r%02d", hex, " %s|r")

	if lastPanel ~= nil then
		Update(lastPanel, 20000)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

local function ConvertTime(h, m)
	local AmPm
	if E.global.datatexts.settings.Time.time24 == true then
		return h, m, -1
	else
		if h >= 12 then
			if h > 12 then h = h - 12 end
			AmPm = 1
		else
			if h == 0 then h = 12 end
			AmPm = 2
		end
	end
	return h, m, AmPm
end

local function CalculateTimeValues(tooltip)
	if (tooltip and E.global.datatexts.settings.Time.localTime) or (not tooltip and not E.global.datatexts.settings.Time.localTime) then
		return ConvertTime(GetGameTime())
	else
		local dateTable = date("*t")
		return ConvertTime(dateTable.hour, dateTable.min)
	end
end

local function OnLeave()
	DT.tooltip:Hide()
	enteredFrame = false
end

local function OnEnter()
	DT.tooltip:ClearLines()

	if(not enteredFrame) then
		enteredFrame = true
		RequestRaidInfo()
	end

	local Hr, Min, AmPm = CalculateTimeValues(true)
	if DT.tooltip:NumLines() > 0 then
		DT.tooltip:AddLine(" ")
	end
	if AmPm == -1 then
		DT.tooltip:AddDoubleLine(E.global.datatexts.settings.Time.localTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	else
		DT.tooltip:AddDoubleLine(E.global.datatexts.settings.Time.localTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		OnEnter(self)
	end
end

local int = 3
function Update(self, t)
	int = int - t

	if int > 0 then return end

	if _G.GameTimeFrame.flashInvite then
		E:Flash(self, 0.53, true)
	else
		E:StopFlash(self)
	end

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, AmPm = CalculateTimeValues(false)

	-- no update quick exit
	if (Hr == curHr and Min == curMin and AmPm == curAmPm) and not (int < -15000) then
		int = 5
		return
	end

	curHr = Hr
	curMin = Min
	curAmPm = AmPm

	if AmPm == -1 then
		self.text:SetFormattedText(europeDisplayFormat, Hr, Min)
	else
		self.text:SetFormattedText(ukDisplayFormat, Hr, Min, APM[AmPm])
	end
	lastPanel = self
	int = 5
end

local function OnClick(self, btn)
	if btn == "RightButton" then
		-- Show clock
		_G.TimeManager_Toggle()
	elseif btn == "LeftButton" then
		-- Show stopwatch
		_G.Stopwatch_Toggle()
	end
end

DT:RegisterDatatext('Time', nil, {'UPDATE_INSTANCE_INFO'}, OnEvent, Update, OnClick, OnEnter, OnLeave, nil, nil, ValueColorUpdate)
