local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetPlayTexture()
	_G.StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Play)
end
local function SetPauseTexture()
	_G.StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Pause)
end

function S:Blizzard_TimeManager()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.timemanager) then return end

	local TimeManagerFrame = _G.TimeManagerFrame
	S:HandlePortraitFrame(TimeManagerFrame)

	local Alarm = _G.TimeManagerAlarmTimeFrame
	if Alarm then
		S:HandleDropDownBox(Alarm.HourDropdown, 80)
		S:HandleDropDownBox(Alarm.MinuteDropdown, 80)
		S:HandleDropDownBox(Alarm.AMPMDropdown, 80)
	end

	S:HandleEditBox(_G.TimeManagerAlarmMessageEditBox)
	S:HandleCheckBox(_G.TimeManagerAlarmEnabledButton)
	S:HandleCheckBox(_G.TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(_G.TimeManagerLocalTimeCheck)

	local TimeManagerStopwatchCheck = _G.TimeManagerStopwatchCheck
	_G.TimeManagerStopwatchFrame:StripTextures()
	TimeManagerStopwatchCheck:SetTemplate()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoords()
	TimeManagerStopwatchCheck:GetNormalTexture():SetInside()

	local hover = TimeManagerStopwatchCheck:CreateTexture()
	hover:SetColorTexture(1,1,1,0.3)
	hover:Point('TOPLEFT',TimeManagerStopwatchCheck,2,-2)
	hover:Point('BOTTOMRIGHT',TimeManagerStopwatchCheck,-2,2)
	TimeManagerStopwatchCheck:SetHighlightTexture(hover)

	local StopwatchFrame = _G.StopwatchFrame
	StopwatchFrame:StripTextures()
	StopwatchFrame:CreateBackdrop('Transparent')
	StopwatchFrame.backdrop:Point('TOPLEFT', 0, -17)
	StopwatchFrame.backdrop:Point('BOTTOMRIGHT', 0, 2)

	_G.StopwatchTabFrame:StripTextures()
	S:HandleCloseButton(_G.StopwatchCloseButton)

	--Play/Pause and Reset buttons
	local StopwatchPlayPauseButton = _G.StopwatchPlayPauseButton
	local StopwatchResetButton = _G.StopwatchResetButton
	StopwatchPlayPauseButton:SetTemplate(nil, true)
	StopwatchPlayPauseButton:Size(12)
	StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Play)
	StopwatchPlayPauseButton:SetHighlightTexture(E.ClearTexture)
	StopwatchPlayPauseButton:HookScript('OnEnter', S.SetModifiedBackdrop)
	StopwatchPlayPauseButton:HookScript('OnLeave', S.SetOriginalBackdrop)
	StopwatchPlayPauseButton:Point('RIGHT', StopwatchResetButton, 'LEFT', -4, 0)
	S:HandleButton(StopwatchResetButton)
	StopwatchResetButton:Size(16)
	StopwatchResetButton:SetNormalTexture(E.Media.Textures.Reset)
	StopwatchResetButton:Point('BOTTOMRIGHT', StopwatchFrame, 'BOTTOMRIGHT', -4, 6)

	hooksecurefunc('Stopwatch_Play', SetPauseTexture)
	hooksecurefunc('Stopwatch_Pause', SetPlayTexture)
	hooksecurefunc('Stopwatch_Clear', SetPlayTexture)
end

S:AddCallbackForAddon('Blizzard_TimeManager')
