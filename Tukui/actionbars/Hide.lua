if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Hide all Blizzard stuff that we don't need
---------------------------------------------------------------------------

do
	MainMenuBar:SetScale(0.00001)
	MainMenuBar:SetAlpha(0)
	MainMenuBar:EnableMouse(false)
	VehicleMenuBar:SetScale(0.00001)
	VehicleMenuBar:SetAlpha(0)
	VehicleMenuBar:EnableMouse(false)
	PetActionBarFrame:EnableMouse(false)
	ShapeshiftBarFrame:EnableMouse(false)
	
	local elements = {
		MainMenuBar, MainMenuBarArtFrame, BonusActionBarFrame, VehicleMenuBar,
		PossessBarFrame, PetActionBarFrame, ShapeshiftBarFrame,
		ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
	}
	for _, element in pairs(elements) do
		if element:GetObjectType() == "Frame" then
			element:UnregisterAllEvents()
		end
		element:Hide()
		element:SetAlpha(0)
	end
	elements = nil
end

do
	local uiManagedFrames = {
		"MultiBarLeft",
		"MultiBarRight",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"ShapeshiftBarFrame",
		"PossessBarFrame",
		"PETACTIONBAR_YPOS",
		"MultiCastActionBarFrame",
		"MULTICASTACTIONBAR_YPOS",
		"ChatFrame1",
		"ChatFrame2",
	}
	for _, frame in pairs(uiManagedFrames) do
		UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
	end
	uiManagedFrames = nil
end

