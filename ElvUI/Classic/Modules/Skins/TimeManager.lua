local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select, unpack = select, unpack
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
	S:HandleFrame(TimeManagerFrame, true)
	TimeManagerFrame:Size(185, 240)
	TimeManagerFrame:Point('TOPRIGHT', -1, -210)

	select(7, TimeManagerFrame:GetRegions()):Point('TOP', 0, -5)

	_G.TimeManagerFrameCloseButton:Point('TOPRIGHT', 4, 5)

	_G.TimeManagerStopwatchFrame:Point('TOPRIGHT', 10, -12)

	_G.TimeManagerStopwatchCheck:SetTemplate()
	_G.TimeManagerStopwatchCheck:StyleButton(nil, true)

	_G.TimeManagerStopwatchCheck:GetNormalTexture():SetInside()
	_G.TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

	_G.TimeManagerAlarmTimeFrame:Point('TOPLEFT', 12, -65)

	S:HandleDropDownBox(_G.TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(_G.TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(_G.TimeManagerAlarmAMPMDropDown, 80)

	S:HandleEditBox(_G.TimeManagerAlarmMessageEditBox)

	_G.TimeManagerAlarmEnabledButton:Point('LEFT', 16, -45)
	_G.TimeManagerAlarmEnabledButton:SetNormalTexture(E.ClearTexture)
	_G.TimeManagerAlarmEnabledButton.SetNormalTexture = E.noop
	_G.TimeManagerAlarmEnabledButton:SetPushedTexture(E.ClearTexture)
	_G.TimeManagerAlarmEnabledButton.SetPushedTexture = E.noop
	S:HandleButton(_G.TimeManagerAlarmEnabledButton)

	_G.TimeManagerMilitaryTimeCheck:Point('TOPLEFT', 155, -190)
	S:HandleCheckBox(_G.TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(_G.TimeManagerLocalTimeCheck)

	_G.StopwatchFrame:CreateBackdrop('Transparent')
	_G.StopwatchFrame.backdrop:Point('TOPLEFT', 0, -16)
	_G.StopwatchFrame.backdrop:Point('BOTTOMRIGHT', 0, 2)

	_G.StopwatchFrame:StripTextures()

	_G.StopwatchTabFrame:StripTextures()

	S:HandleCloseButton(_G.StopwatchCloseButton)

	_G.StopwatchPlayPauseButton:CreateBackdrop(nil, true)
	_G.StopwatchPlayPauseButton:SetSize(12, 12)
	_G.StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Play)
	_G.StopwatchPlayPauseButton:SetHighlightTexture(E.ClearTexture)
	_G.StopwatchPlayPauseButton.backdrop:SetOutside(_G.StopwatchPlayPauseButton, 2, 2)
	_G.StopwatchPlayPauseButton:HookScript('OnEnter', S.SetModifiedBackdrop)
	_G.StopwatchPlayPauseButton:HookScript('OnLeave', S.SetOriginalBackdrop)
	_G.StopwatchPlayPauseButton:Point('RIGHT', _G.StopwatchResetButton, 'LEFT', -4, 0)
	S:HandleButton(_G.StopwatchResetButton)
	_G.StopwatchResetButton:SetSize(16,16)
	_G.StopwatchResetButton:SetNormalTexture(E.Media.Textures.Reset)
	_G.StopwatchResetButton:Point('BOTTOMRIGHT', _G.StopwatchFrame, 'BOTTOMRIGHT', -4, 6)

	hooksecurefunc('Stopwatch_Play', SetPauseTexture)
	hooksecurefunc('Stopwatch_Pause', SetPlayTexture)
	hooksecurefunc('Stopwatch_Clear', SetPlayTexture)
end

S:AddCallbackForAddon('Blizzard_TimeManager')
