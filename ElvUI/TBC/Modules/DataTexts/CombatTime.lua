local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local floor, format, strjoin = floor, format, strjoin
local GetTime = GetTime

local displayString, lastPanel = ''
local timerText, timer, startTime = L["Combat"], 0, 0

local function UpdateText()
	return format("%02d:%02d:%02d", floor(timer/60), timer % 60, (timer - floor(timer)) * 100)
end

local function OnUpdate(self)
	timer = GetTime() - startTime
	self.text:SetFormattedText(displayString, timerText, UpdateText())
end

local function OnEvent(self, event)
	if event == "PLAYER_REGEN_ENABLED" then
		self:SetScript("OnUpdate", nil)
	elseif event == "PLAYER_REGEN_DISABLED" then
		timerText, timer, startTime = L["Combat"], 0, GetTime()
		self:SetScript("OnUpdate", OnUpdate)
	else
		local txt = self.text:GetText()
		if not txt or txt == '' then
			self.text:SetFormattedText(displayString, timerText, UpdateText())
		end
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Combat Time', nil, {'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, L["Combat Time"], nil, ValueColorUpdate)
