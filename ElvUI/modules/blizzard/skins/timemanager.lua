local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].timemanager ~= true then return end

local function LoadSkin()
	TimeManagerFrame:StripTextures()
	TimeManagerFrame:SetTemplate("Transparent")

	E.SkinCloseButton(TimeManagerCloseButton)

	E.SkinDropDownBox(TimeManagerAlarmHourDropDown, 80)
	E.SkinDropDownBox(TimeManagerAlarmMinuteDropDown, 80)
	E.SkinDropDownBox(TimeManagerAlarmAMPMDropDown, 80)
	
	E.SkinEditBox(TimeManagerAlarmMessageEditBox)
	
	E.SkinButton(TimeManagerAlarmEnabledButton, true)
	TimeManagerAlarmEnabledButton:HookScript("OnClick", function(self)
		E.SkinButton(self)
	end)

	TimeManagerFrame:HookScript("OnShow", function(self)
		E.SkinButton(TimeManagerAlarmEnabledButton)
	end)		
	
	E.SkinCheckBox(TimeManagerMilitaryTimeCheck)
	E.SkinCheckBox(TimeManagerLocalTimeCheck)
	
	TimeManagerStopwatchFrame:StripTextures()
	TimeManagerStopwatchCheck:SetTemplate("Default")
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
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
	E.SkinCloseButton(StopwatchCloseButton)
	E.SkinNextPrevButton(StopwatchPlayPauseButton)
	E.SkinNextPrevButton(StopwatchResetButton)
	StopwatchPlayPauseButton:Point("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	StopwatchResetButton:Point("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)
end

E.SkinFuncs["Blizzard_TimeManager"] = LoadSkin