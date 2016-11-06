local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.dressingroom ~= true then return end
	DressUpFrame:StripTextures(true)
	DressUpFrame:CreateBackdrop("Transparent")
	DressUpFrame.backdrop:Point("TOPLEFT", 6, 0)
	DressUpFrame.backdrop:Point("BOTTOMRIGHT", -32, 70)

	S:HandleButton(DressUpFrameResetButton)
	S:HandleButton(DressUpFrameCancelButton)
	S:HandleButton(DressUpFrameOutfitDropDown.SaveButton)
	DressUpFrameOutfitDropDown.SaveButton:ClearAllPoints()
	DressUpFrameOutfitDropDown.SaveButton:SetPoint("RIGHT", DressUpFrameOutfitDropDown, 86, 4)
	S:HandleDropDownBox(DressUpFrameOutfitDropDown)
	DressUpFrameOutfitDropDown:SetSize(195, 34)
	
	S:HandleCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop)
	
	-- Wardrobe edit frame
	WardrobeOutfitFrame:StripTextures(true)
	WardrobeOutfitFrame:SetTemplate("Transparent")

	WardrobeOutfitEditFrame:StripTextures(true)
	WardrobeOutfitEditFrame:SetTemplate("Transparent")
	WardrobeOutfitEditFrame.EditBox:StripTextures()
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point("TOPLEFT", WardrobeOutfitEditFrame.EditBox, "TOPLEFT", -5, -5)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point("BOTTOMRIGHT", WardrobeOutfitEditFrame.EditBox, "BOTTOMRIGHT", 0, 5)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)

	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -2, 0)
end

S:AddCallback("DressingRoom", LoadSkin)