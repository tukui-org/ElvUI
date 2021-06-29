local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
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

	S:HandleDropDownBox(_G.TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(_G.TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(_G.TimeManagerAlarmAMPMDropDown, 80)

	S:HandleEditBox(_G.TimeManagerAlarmMessageEditBox)
	S:HandleCheckBox(_G.TimeManagerAlarmEnabledButton)
	S:HandleCheckBox(_G.TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(_G.TimeManagerLocalTimeCheck)

	local TimeManagerStopwatchCheck = _G.TimeManagerStopwatchCheck
	_G.TimeManagerStopwatchFrame:StripTextures()
	TimeManagerStopwatchCheck:SetTemplate()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	TimeManagerStopwatchCheck:GetNormalTexture():SetInside()

	local hover = TimeManagerStopwatchCheck:CreateTexture() -- hover
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
	StopwatchPlayPauseButton:Size(12, 12)
	StopwatchPlayPauseButton:SetNormalTexture(E.Media.Textures.Play)
	StopwatchPlayPauseButton:SetHighlightTexture('')
	StopwatchPlayPauseButton:HookScript('OnEnter', S.SetModifiedBackdrop)
	StopwatchPlayPauseButton:HookScript('OnLeave', S.SetOriginalBackdrop)
	StopwatchPlayPauseButton:Point('RIGHT', StopwatchResetButton, 'LEFT', -4, 0)
	S:HandleButton(StopwatchResetButton)
	StopwatchResetButton:Size(16,16)
	StopwatchResetButton:SetNormalTexture(E.Media.Textures.Reset)
	StopwatchResetButton:Point('BOTTOMRIGHT', StopwatchFrame, 'BOTTOMRIGHT', -4, 6)

	hooksecurefunc('Stopwatch_Play', SetPauseTexture)
	hooksecurefunc('Stopwatch_Pause', SetPlayTexture)
	hooksecurefunc('Stopwatch_Clear', SetPlayTexture)
end

S:AddCallbackForAddon('Blizzard_TimeManager')
