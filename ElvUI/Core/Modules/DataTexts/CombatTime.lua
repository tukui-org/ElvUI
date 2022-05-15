local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local floor, format, strjoin = floor, format, strjoin
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime

local displayString, lastPanel = ''
local timerText, timer, startTime, inEncounter = L["Combat"], 0, 0

local function UpdateText()
	return format(E.global.datatexts.settings.Combat.TimeFull and '%02d:%02d:%02d' or '%02d:%02d', floor(timer/60), timer % 60, (timer - floor(timer)) * 100)
end

local function OnUpdate(self)
	timer = GetTime() - startTime
	self.text:SetFormattedText(displayString, timerText, UpdateText())
end

local function DelayOnUpdate(self, elapsed)
	startTime = startTime - elapsed
	if startTime <= 0 then
		timer, startTime = 0, GetTime()
		self:SetScript('OnUpdate', OnUpdate)
	end
end

local function OnEvent(self, event, _, timeSeconds)
	local _, instanceType = GetInstanceInfo()
	local inArena, started, ended = instanceType == 'arena', event == 'ENCOUNTER_START', event == 'ENCOUNTER_END'
	local noLabel = E.global.datatexts.settings.Combat.NoLabel and ''

	if inArena and event == 'START_TIMER' then
		timerText, timer, startTime = noLabel or L["Arena"], 0, timeSeconds
		self.text:SetFormattedText(displayString, timerText, E.global.datatexts.settings.Combat.TimeFull and '00:00:00' or '00:00')
		self:SetScript('OnUpdate', DelayOnUpdate)
	elseif not inArena and ((not inEncounter and event == 'PLAYER_REGEN_ENABLED') or ended) then
		self:SetScript('OnUpdate', nil)
		if ended then inEncounter = nil end
	elseif not inArena and (event == 'PLAYER_REGEN_DISABLED' or started) then
		timerText, timer, startTime = noLabel or L["Combat"], 0, GetTime()
		self:SetScript('OnUpdate', OnUpdate)
		if started then inEncounter = true end
	elseif not self.text:GetText() or event == 'ELVUI_FORCE_UPDATE' then
		timerText = noLabel or L["Combat"]
		self.text:SetFormattedText(displayString, timerText, E.global.datatexts.settings.Combat.TimeFull and '00:00:00' or '00:00')
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	local noLabel = E.global.datatexts.settings.Combat.NoLabel and ''
	displayString = strjoin('', '%s', noLabel or ': ', hex, '%s|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Combat', nil, {'START_TIMER', 'ENCOUNTER_START', 'ENCOUNTER_END', 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, L["Combat/Arena Time"], nil, ValueColorUpdate)
