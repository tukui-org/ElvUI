local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.dressingroom ~= true then return end

	local DressUpFrame = _G["DressUpFrame"]
	DressUpFrame:StripTextures()
	DressUpFrame:CreateBackdrop("Transparent")

	DressUpFramePortrait:Hide()
	DressUpFrameInset:Hide()

	S:HandleButton(DressUpFrameResetButton)
	S:HandleButton(DressUpFrameCancelButton)
	S:HandleButton(DressUpFrameOutfitDropDown.SaveButton)
	DressUpFrameOutfitDropDown.SaveButton:ClearAllPoints()
	DressUpFrameOutfitDropDown.SaveButton:SetPoint("RIGHT", DressUpFrameOutfitDropDown, 86, 4)
	S:HandleDropDownBox(DressUpFrameOutfitDropDown)
	DressUpFrameOutfitDropDown:SetSize(195, 34)

	S:HandleMaxMinFrame(MaximizeMinimizeFrame)
	S:HandleCloseButton(DressUpFrameCloseButton)
	DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -2, 0)

	-- Wardrobe edit frame
	local WardrobeOutfitFrame = _G["WardrobeOutfitFrame"]
	WardrobeOutfitFrame:StripTextures(true)
	WardrobeOutfitFrame:SetTemplate("Transparent")

	local WardrobeOutfitEditFrame = _G["WardrobeOutfitEditFrame"]
	WardrobeOutfitEditFrame:StripTextures(true)
	WardrobeOutfitEditFrame:SetTemplate("Transparent")
	WardrobeOutfitEditFrame.EditBox:StripTextures()
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point("TOPLEFT", WardrobeOutfitEditFrame.EditBox, "TOPLEFT", -5, -5)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point("BOTTOMRIGHT", WardrobeOutfitEditFrame.EditBox, "BOTTOMRIGHT", 0, 5)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)
end

S:AddCallback("DressingRoom", LoadSkin)
