local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local floor, strjoin = floor, strjoin
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime

local displayString, db = ''
local timerText, timer, startTime, inEncounter = L["Combat"], 0, 0

local function UpdateText()
	return floor(timer/60), timer % 60, (timer - floor(timer)) * 100
end

local function OnUpdate(panel)
	timer = GetTime() - startTime
	panel.text:SetFormattedText(displayString, timerText, UpdateText())
end

local function DelayOnUpdate(panel, elapsed)
	startTime = startTime - elapsed
	if startTime <= 0 then
		timer, startTime = 0, GetTime()
		panel:SetScript('OnUpdate', OnUpdate)
	end
end

local function OnEvent(panel, event, _, timeSeconds)
	local _, instanceType = GetInstanceInfo()
	local inArena, started, ended = instanceType == 'arena', event == 'ENCOUNTER_START', event == 'ENCOUNTER_END'
	timerText = (db.NoLabel and '') or inArena and L["Arena"] or L["Combat"]

	if inArena and event == 'START_TIMER' then
		timer, startTime = 0, timeSeconds
		panel.text:SetFormattedText(displayString, timerText, UpdateText())
		panel:SetScript('OnUpdate', DelayOnUpdate)
	elseif not inArena and ((not inEncounter and event == 'PLAYER_REGEN_ENABLED') or ended) then
		panel:SetScript('OnUpdate', nil)
		if ended then inEncounter = nil end
	elseif not inArena and ((not inEncounter and event == 'PLAYER_REGEN_DISABLED') or started) then
		timer, startTime = 0, GetTime()
		panel:SetScript('OnUpdate', OnUpdate)
		if started then inEncounter = true end
	elseif not panel.text:GetText() or event == 'ELVUI_FORCE_UPDATE' then
		panel.text:SetFormattedText(displayString, timerText, UpdateText())
	end
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	displayString = strjoin('', '%s', db.NoLabel and '' or ': ', hex, (db.TimeFull and '%02d|cFFFFFFFF:|r%02d|cFFFFFFFF:|r%02d' or '%02d|cFFFFFFFF:|r%02d')..'|r')
end

DT:RegisterDatatext('Combat', nil, {'START_TIMER', 'ENCOUNTER_START', 'ENCOUNTER_END', 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED'}, OnEvent, nil, nil, nil, nil, L["Combat/Arena Time"], nil, ApplySettings)
