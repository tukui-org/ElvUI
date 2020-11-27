local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')


--Lua functions
local format = string.format
local tonumber = tonumber
local ipairs = ipairs

--WoW API / Variables
local setCV = SetCVar
local getCV = GetCVar
local IsShiftKeyDown = IsShiftKeyDown
local SOUND = SOUND
local ShowOptionsPanel = ShowOptionsPanel

local Sound_GameSystem_GetOutputDriverNameByIndex = Sound_GameSystem_GetOutputDriverNameByIndex
local Sound_GameSystem_GetNumOutputDrivers = Sound_GameSystem_GetNumOutputDrivers
local Sound_GameSystem_RestartSoundSystem = Sound_GameSystem_RestartSoundSystem


local volumeCVars =
	{
		[1] = {Name = MASTER, CVs = { Volume = 'Sound_MasterVolume', Enabled = 'Sound_EnableAllSound' }, Enabled = nil},
		[2] = {Name = SOUND_VOLUME, CVs = { Volume = 'Sound_SFXVolume', Enabled = 'Sound_EnableSFX' }, Enabled = nil},
		[3] = {Name = AMBIENCE_VOLUME, CVs = { Volume = 'Sound_AmbienceVolume', Enabled = 'Sound_EnableAmbience' }, Enabled = nil},
		[4] = {Name = DIALOG_VOLUME, CVs = { Volume = 'Sound_DialogVolume', Enabled = 'Sound_EnableDialog' }, Enabled = nil},
		[5] = {Name = MUSIC_VOLUME, CVs = { Volume = 'Sound_MusicVolume', Enabled = 'Sound_EnableMusic' }, Enabled = nil}
	}


local activeVolumeIndex = 1
local activeVolume = volumeCVars[activeVolumeIndex]
local menu = {
	[1] = {text = L["Select Volume Stream"], isTitle = true, notCheckable = true},
}
local toggleMenu = {
	[1] = {text = L["Toggle Volume Stream"], isTitle = true, notCheckable = true},
}
local deviceMenu = {
	[1] = {text = L["Output Audio Device"], isTitle = true, notCheckable = true}
}

local function GetStatusColor(vol, text)
	if not text then
		text = vol.Name
	end

	return format('|cFF%s%s|r',(getCV(vol.CVs.Volume) == '0' or not vol.Enabled) and 'FF0000' or '00FF00', text)
end

local function OnEnter(self)
	E:UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1)

	DT:SetupTooltip(self)
	DT.tooltip:ClearLines()

	local audioDev = Sound_GameSystem_GetOutputDriverNameByIndex(getCV('Sound_OutputDriverIndex'))

	DT.tooltip:AddLine(L["|cFFffffffActive Output Audio Device|r"])
	DT.tooltip:AddLine(audioDev)
	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cFFffffffVolume Streams|r"])
	for _,vol in ipairs(volumeCVars) do
		DT.tooltip:AddDoubleLine(vol.Name, GetStatusColor(vol, format('%.f', getCV(vol.CVs.Volume) * 100) .. '%'))
	end

	DT.tooltip:AddLine(' ')


	DT.tooltip:AddLine(L["|cFFffffffLeft Click:|r Select Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffMiddle Click:|r Toggle Mute Master Stream"])
	DT.tooltip:AddLine(L["|cFFffffffRight Click:|r Toggle Volume Stream"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Left Click:|r Open System Audio Panel"])
	DT.tooltip:AddLine(L["|cFFffffffShift + Right Click:|r Select Output Audio Device"])

	DT.tooltip:Show()
end



local function OnEvent(self, event, ...)
	activeVolume = volumeCVars[activeVolumeIndex]

	if (event == 'ELVUI_FORCE_UPDATE' ) then -- I hate you Azil <3

		self:EnableMouseWheel(true)

		self:SetScript('OnMouseWheel', function(_, delta)
			local vol = getCV(activeVolume.CVs.Volume);
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

			setCV(activeVolume.CVs.Volume, vol, 'ELV_VOLUME_CHANGED')
		end)

		OnEvent(self, 'CVAR_UPDATE', 'ELV_VOLUME_TEXT_CHANGE')
		OnEvent(self, 'CVAR_UPDATE', 'ELV_VOLUME_STREAM_TOGGLE')
		OnEvent(self, 'CVAR_UPDATE', 'ELV_OUTPUT_SOUND_DEVICE_CHANGED')
		OnEvent(self, 'CVAR_UPDATE', 'ELV_VOLUME_CHANGED', getCV(activeVolume.CVs.Volume))
	end


	if event == 'CVAR_UPDATE' then
		local cvar_name, value = ...

		if cvar_name == 'ELV_VOLUME_CHANGED' then
			self.text:SetText(activeVolume.Name..': '..GetStatusColor(activeVolume, format('%.f', value * 100) .. '%'))
		elseif cvar_name == 'ELV_VOLUME_TEXT_CHANGE' then
			for i,vol in pairs(volumeCVars) do
				menu[i+1]={
					text = vol.Name,
					checked = i == activeVolumeIndex,
					func = function()
						activeVolumeIndex = i;
						OnEvent(self, 'CVAR_UPDATE', 'ELV_VOLUME_TEXT_CHANGE');
						OnEvent(self, 'CVAR_UPDATE', 'ELV_VOLUME_CHANGED', getCV(vol.CVs.Volume));
					 end
				}
			end
		elseif cvar_name == 'ELV_VOLUME_STREAM_TOGGLE' then
			for i,vol in pairs(volumeCVars) do
				vol.Enabled = getCV(vol.CVs.Enabled) == '1'
				toggleMenu[i + 1] = {
					text = vol.Name,
					checked = getCV(vol.CVs.Enabled) == '1',
					func = function()
						setCV(
							vol.CVs.Enabled,
							(not vol.Enabled) and '1' or '0',
							'ELV_VOLUME_STREAM_TOGGLE'
						)

						OnEvent(self, 'CVAR_UPDATE', 'ELV_VOLUME_CHANGED', getCV(activeVolume.CVs.Volume));
					end
				}
			end

		elseif cvar_name == 'ELV_OUTPUT_SOUND_DEVICE_CHANGED' then
			local numDevices = Sound_GameSystem_GetNumOutputDrivers()
			local activeIndex = tonumber(getCV('Sound_OutputDriverIndex'))

			for i=0,numDevices-1 do --the only thing I have found that is 0 based....
				deviceMenu[i+2] = {
					text = Sound_GameSystem_GetOutputDriverNameByIndex(i),
					checked = i == activeIndex,
					func = function() setCV('Sound_OutputDriverIndex', i, 'ELV_OUTPUT_SOUND_DEVICE_CHANGED'); Sound_GameSystem_RestartSoundSystem(); end
				}
			end
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
		setCV(volumeCVars[1].CVs.Enabled, (not volumeCVars[1].Enabled) and '1' or '0', 'ELV_VOLUME_STREAM_TOGGLE')
		OnEvent(self, 'CVAR_UPDATE', 'ELV_VOLUME_CHANGED', getCV(activeVolume.CVs.Volume));
	elseif button == 'RightButton' then
		DT:SetEasyMenuAnchor(DT.EasyMenu, self)

		if IsShiftKeyDown() then
			_G.EasyMenu(deviceMenu, DT.EasyMenu, nil, nil, nil, 'MENU')
			return
		end

		_G.EasyMenu(toggleMenu, DT.EasyMenu, nil, nil, nil, 'MENU')
	end
end


DT:RegisterDatatext(L["Volume"], nil, {'CVAR_UPDATE'}, OnEvent, nil, OnClick, OnEnter)