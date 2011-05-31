local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].petition ~= true then return end

local function LoadSkin()
	PetitionFrame:StripTextures(true)
	PetitionFrame:SetTemplate("Transparent")
	PetitionFrame:CreateShadow("Default")
	
	E.SkinButton(PetitionFrameRequestButton)
	E.SkinButton(PetitionFrameRenameButton)
	E.SkinButton(PetitionFrameCancelButton)
	E.SkinCloseButton(PetitionFrameCloseButton)
	
	PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
	PetitionFrameCharterName:SetTextColor(1, 1, 1)
	PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
	PetitionFrameMasterName:SetTextColor(1, 1, 1)
	PetitionFrameMemberTitle:SetTextColor(1, 1, 0)
	
	for i=1, 9 do
		_G["PetitionFrameMemberName"..i]:SetTextColor(1, 1, 1)
	end
	
	PetitionFrameInstructions:SetTextColor(1, 1, 1)
	
	PetitionFrameRenameButton:Point("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0)
	PetitionFrameRenameButton:Point("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0)
	PetitionFrame:Height(PetitionFrame:GetHeight() - 80)
	
	PetitionFrameCancelButton:Point("BOTTOMRIGHT", PetitionFrame, "BOTTOMRIGHT", -40, 20)
	PetitionFrameRequestButton:Point("BOTTOMLEFT", PetitionFrame, "BOTTOMLEFT", 22, 20)
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)