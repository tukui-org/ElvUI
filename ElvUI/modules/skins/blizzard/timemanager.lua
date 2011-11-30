local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.db.skins.blizzard.enable ~= true or E.db.skins.blizzard.timemanager ~= true then return end
	TimeManagerFrame:StripTextures()
	TimeManagerFrame:SetTemplate("Transparent")

	S:HandleCloseButton(TimeManagerCloseButton)

	S:HandleDropDownBox(TimeManagerAlarmHourDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmMinuteDropDown, 80)
	S:HandleDropDownBox(TimeManagerAlarmAMPMDropDown, 80)
	
	S:HandleEditBox(TimeManagerAlarmMessageEditBox)
	
	S:HandleButton(TimeManagerAlarmEnabledButton, true)
	TimeManagerAlarmEnabledButton:HookScript("OnClick", function(self)
		S:HandleButton(self)
	end)

	TimeManagerFrame:HookScript("OnShow", function(self)
		S:HandleButton(TimeManagerAlarmEnabledButton)
	end)		
	
	S:HandleCheckBox(TimeManagerMilitaryTimeCheck)
	S:HandleCheckBox(TimeManagerLocalTimeCheck)
	
	TimeManagerStopwatchFrame:StripTextures()
	TimeManagerStopwatchCheck:SetTemplate("Default")
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	TimeManagerStopwatchCheck:GetNormalTexture():ClearAllPoints()
	TimeManagerStopwatchCheck:GetNormalTexture():Point("TOPLEFT", 2, -2)
	TimeManagerStopwatchCheck:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
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