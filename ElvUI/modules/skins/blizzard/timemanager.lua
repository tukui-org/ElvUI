local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.timemanager ~= true then return end
	TimeManagerFrame:StripTextures()
	TimeManagerFrame:SetTemplate("Transparent")

	S:HandleCloseButton(TimeManagerFrameCloseButton)
	TimeManagerFrameInset:Kill()
	S:HandleDropDownBox(TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmAMPMDropDown, 80)
	
	S:HandleEditBox(TimeManagerAlarmMessageEditBox)
	
	S:HandleCheckBox(TimeManagerAlarmEnabledButton)

	
	S:HandleCheckBox(TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(TimeManagerLocalTimeCheck)
	
	TimeManagerStopwatchFrame:StripTextures()
	TimeManagerStopwatchCheck:SetTemplate("Default")
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	TimeManagerStopwatchCheck:GetNormalTexture():SetInside()
	local hover = TimeManagerStopwatchCheck:CreateTexture("frame", nil, TimeManagerStopwatchCheck) -- hover
	hover:SetTexture(1,1,1,0.3)
	hover:Point("TOPLEFT",TimeManagerStopwatchCheck,2,-2)
	hover:Point("BOTTOMRIGHT",TimeManagerStopwatchCheck,-2,2)
	TimeManagerStopwatchCheck:SetHighlightTexture(hover)
	
	StopwatchFrame:StripTextures()
	StopwatchFrame:CreateBackdrop("Transparent")
	StopwatchFrame.backdrop:Point("TOPLEFT", 0, -17)
	StopwatchFrame.backdrop:Point("BOTTOMRIGHT", 0, 2)
	
	StopwatchTabFrame:StripTextures()
	S:HandleCloseButton(StopwatchCloseButton)
	S:HandleNextPrevButton(StopwatchPlayPauseButton)
	S:HandleNextPrevButton(StopwatchResetButton)
	StopwatchPlayPauseButton:Point("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	StopwatchResetButton:Point("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)
end

S:RegisterSkin("Blizzard_TimeManager", LoadSkin)