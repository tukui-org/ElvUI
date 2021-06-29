local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:DressUpFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.dressingroom) then return end

	local DressUpFrame = _G.DressUpFrame
	S:HandlePortraitFrame(DressUpFrame)

	S:HandleButton(_G.DressUpFrameResetButton)
	S:HandleButton(_G.DressUpFrameCancelButton)

	local DressUpFrameOutfitDropDown = _G.DressUpFrameOutfitDropDown
	S:HandleDropDownBox(DressUpFrameOutfitDropDown)
	S:HandleButton(DressUpFrameOutfitDropDown.SaveButton)
	DressUpFrameOutfitDropDown.SaveButton:Point('LEFT', DressUpFrameOutfitDropDown, 'RIGHT', -7, 3)
	DressUpFrameOutfitDropDown.backdrop:Point('TOPLEFT', -25, 3)

	S:HandleMaxMinFrame(DressUpFrame.MaximizeMinimizeFrame)
	_G.DressUpFrameResetButton:Point('RIGHT', _G.DressUpFrameCancelButton, 'LEFT', -2, 0)

	-- Wardrobe edit frame
	local WardrobeOutfitFrame = _G.WardrobeOutfitFrame
	WardrobeOutfitFrame:StripTextures(true)
	WardrobeOutfitFrame:SetTemplate('Transparent')

	local WardrobeOutfitEditFrame = _G.WardrobeOutfitEditFrame
	WardrobeOutfitEditFrame:StripTextures(true)
	WardrobeOutfitEditFrame:SetTemplate('Transparent')
	WardrobeOutfitEditFrame.EditBox:StripTextures()
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point('TOPLEFT', WardrobeOutfitEditFrame.EditBox, 'TOPLEFT', -5, -5)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point('BOTTOMRIGHT', WardrobeOutfitEditFrame.EditBox, 'BOTTOMRIGHT', 0, 5)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)
end

S:AddCallback('DressUpFrame')
