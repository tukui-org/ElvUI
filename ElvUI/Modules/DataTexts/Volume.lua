local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local format = string.format
local tonumber = tonumber
local ipairs = ipairs

--WoW API / Variables
local SetCVar = SetCVar
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local IsShiftKeyDown = IsShiftKeyDown
local SOUND = SOUND
local ShowOptionsPanel = ShowOptionsPanel

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

local activeIndex = 1
local activeStream = AudioStreams[activeIndex]
local panel, OnEvent
local menu = {{ text = L["Select Volume Stream"], isTitle = true, notCheckable = true }}
local toggleMenu = {{ text = L["Toggle Volume Stream"], isTitle = true, notCheckable = true }}
local deviceMenu = {{ text = L["Output Audio Device"], isTitle = true, notCheckable = true }}

local function GetStatusColor(vol, text)
	if not text then
		text = vol.Name
	end

	return format('|cFF%s%s%%|r', GetCVarBool(AudioStreams[1].Enabled) and GetCVarBool(vol.Enabled) and '00FF00' or 'FF3333', text)
end

local function SelectStream(_, ...)
	activeIndex = ...
	activeStream = AudioStreams[activeIndex]

	panel.text:SetText(activeStream.Name..': '..GetStatusColor(activeStream, format('%.f', GetCVar(activeStream.Volume) * 100)))
end

local function ToggleStream(_, ...)
	local Stream = AudioStreams[...]

	SetCVar(Stream.Enabled, GetCVarBool(Stream.Enabled) and 0 or 1, 'ELVUI_VOLUME')

	panel.text:SetText(activeStream.Name..': '..GetStatusColor(activeStream, format('%.f', GetCVar(activeStream.Volume) * 100)))
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
		DT.tooltip:AddDoubleLine(Stream.Name, GetStatusColor(Stream, format('%.f', GetCVar(Stream.Volume) * 100)))
	end

	DT.tooltip:AddLine(' ')

	DT.tooltip:AddLine(L["|cFFffffffLeft Click:|r Select Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffMiddle Click:|r Toggle Mute Master Stream"])
	DT.tooltip:AddLine(L["|cFFffffffRight Click:|r Toggle Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Left Click:|r Open System Audio Panel"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Right Click:|r Select Output Audio Device"])

	DT.tooltip:Show()
end

function OnEvent(self, event, ...)
	activeStream = AudioStreams[activeIndex]
	panel = self

	if (event == 'ELVUI_FORCE_UPDATE') then
		self:EnableMouseWheel(true)
		self:SetScript('OnMouseWheel', function(_, delta)
			local vol = GetCVar(activeStream.Volume);
			local volScale = 100;

			if (IsShiftKeyDown()) then
				volScale = 10;
			end

			vol = vol + (delta / volScale)

			if (vol >= 1) then
				vol = 1
			elseif (vol <= 0) then
				vol = 0
			end

			SetCVar(activeStream.Volume, vol, 'ELVUI_VOLUME')
		end)

		self.text:SetText(activeStream.Name..': '..GetStatusColor(activeStream, format('%.f', GetCVar(activeStream.Volume) * 100)))
	end

	if event == 'CVAR_UPDATE' then
		local cvar_name, value = ...

		if cvar_name == 'ELVUI_VOLUME' then
			self.text:SetText(activeStream.Name..': '..GetStatusColor(activeStream, format('%.f', value * 100)))
		end
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
