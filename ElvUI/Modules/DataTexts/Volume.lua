local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local tonumber = tonumber
local format = format
local ipairs = ipairs
local tinsert = tinsert

local SetCVar = SetCVar
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local IsShiftKeyDown = IsShiftKeyDown
local ShowOptionsPanel = ShowOptionsPanel
local SOUND = SOUND

local Sound_GameSystem_GetOutputDriverNameByIndex = Sound_GameSystem_GetOutputDriverNameByIndex
local Sound_GameSystem_GetNumOutputDrivers = Sound_GameSystem_GetNumOutputDrivers
local Sound_GameSystem_RestartSoundSystem = Sound_GameSystem_RestartSoundSystem

local AudioStreams = {
	{ Name = _G.MASTER, Volume = 'Sound_MasterVolume', Enabled = 'Sound_EnableAllSound' },
	{ Name = _G.SOUND_VOLUME, Volume = 'Sound_SFXVolume', Enabled = 'Sound_EnableSFX' },
	{ Name = _G.AMBIENCE_VOLUME, Volume = 'Sound_AmbienceVolume', Enabled = 'Sound_EnableAmbience' },
	{ Name = _G.DIALOG_VOLUME, Volume = 'Sound_DialogVolume', Enabled = 'Sound_EnableDialog' },
	{ Name = _G.MUSIC_VOLUME, Volume = 'Sound_MusicVolume', Enabled = 'Sound_EnableMusic' }
}

local panel, OnEvent
local activeIndex = 1
local activeStream = AudioStreams[activeIndex]
local menu = {{ text = L["Select Volume Stream"], isTitle = true, notCheckable = true }}
local toggleMenu = {{ text = L["Toggle Volume Stream"], isTitle = true, notCheckable = true }}
local deviceMenu = {{ text = L["Output Audio Device"], isTitle = true, notCheckable = true }}

local function GetStreamString(stream, tooltip)
	if not stream then stream = AudioStreams[1] end

	local color = GetCVarBool(AudioStreams[1].Enabled) and GetCVarBool(stream.Enabled) and '00FF00' or 'FF3333'
	local level = GetCVar(stream.Volume) * 100

	if tooltip then
		return format('|cFF%s%.f%%|r', color, level)
	else
		return format('%s: |cFF%s%.f%%|r', stream.Name, color, level)
	end
end

local function SelectStream(_, ...)
	activeIndex = ...
	activeStream = AudioStreams[activeIndex]

	panel.text:SetText(GetStreamString(activeStream))
end

local function ToggleStream(_, ...)
	local Stream = AudioStreams[...]

	SetCVar(Stream.Enabled, GetCVarBool(Stream.Enabled) and 0 or 1, 'ELVUI_VOLUME')

	panel.text:SetText(GetStreamString(activeStream))
end

for Index, Stream in ipairs(AudioStreams) do
	tinsert(menu, { text = Stream.Name, checked = function() return Index == activeIndex end, func = SelectStream, arg1 = Index })
	tinsert(toggleMenu, { text = Stream.Name, checked = function() return GetCVarBool(Stream.Enabled) end, func = ToggleStream, arg1 = Index})
end

local function SelectSoundOutput(_, ...)
	SetCVar('Sound_OutputDriverIndex', ..., 'ELVUI_VOLUME')
	Sound_GameSystem_RestartSoundSystem()
end

local numDevices = Sound_GameSystem_GetNumOutputDrivers()
for i = 0, numDevices - 1 do
	tinsert(deviceMenu, { text = Sound_GameSystem_GetOutputDriverNameByIndex(i), checked = function() return i == tonumber(GetCVar('Sound_OutputDriverIndex')) end, func = SelectSoundOutput, arg1 = i })
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(L["Active Output Audio Device"], 1, 1, 1)
	DT.tooltip:AddLine(Sound_GameSystem_GetOutputDriverNameByIndex(GetCVar('Sound_OutputDriverIndex')))
	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["Volume Streams"], 1, 1, 1)

	for _, Stream in ipairs(AudioStreams) do
		DT.tooltip:AddDoubleLine(Stream.Name, GetStreamString(Stream, true))
	end

	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(L["|cFFffffffLeft Click:|r Select Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffMiddle Click:|r Toggle Mute Master Stream"])
	DT.tooltip:AddLine(L["|cFFffffffRight Click:|r Toggle Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Left Click:|r Open System Audio Panel"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Right Click:|r Select Output Audio Device"])

	DT.tooltip:Show()
end

local function onMouseWheel(_, delta)
	local vol = GetCVar(activeStream.Volume)
	local scale = 100

	if IsShiftKeyDown() then
		scale = 10
	end

	vol = vol + (delta / scale)

	if vol >= 1 then
		vol = 1
	elseif vol <= 0 then
		vol = 0
	end

	SetCVar(activeStream.Volume, vol, 'ELVUI_VOLUME')
end

function OnEvent(self, event, arg1)
	activeStream = AudioStreams[activeIndex]
	panel = self

	if event == 'ELVUI_FORCE_UPDATE' then
		self:EnableMouseWheel(true)
		self:SetScript('OnMouseWheel', onMouseWheel)
	end

	if event == 'CVAR_UPDATE' and arg1 == 'ELVUI_VOLUME' or event == 'ELVUI_FORCE_UPDATE' then
		self.text:SetText(GetStreamString(activeStream))
	end
end

local function OnClick(self, button)
	if button == 'LeftButton' then
		if IsShiftKeyDown() then
			ShowOptionsPanel(_G.VideoOptionsFrame, _G.GameMenuFrame, SOUND)
			return
		end

		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(menu, DT.EasyMenu, nil, nil, nil, 'MENU')
	elseif button == 'MiddleButton' then
		SetCVar(AudioStreams[1].Enabled, GetCVarBool(AudioStreams[1].Enabled) and 0 or 1, 'ELVUI_VOLUME')
	elseif button == 'RightButton' then
		DT:SetEasyMenuAnchor(DT.EasyMenu, self)
		_G.EasyMenu(IsShiftKeyDown() and deviceMenu or toggleMenu, DT.EasyMenu, nil, nil, nil, 'MENU')
	end
end

DT:RegisterDatatext(L["Volume"], nil, {'CVAR_UPDATE'}, OnEvent, nil, OnClick, OnEnter)
