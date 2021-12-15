local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function SetToggleIcon(button, texture)
	local icon = button:CreateTexture()
	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetInside()
	icon:SetTexture(texture)

	button:StyleButton()
end

local function SetItemQuality(slot)
	if not slot.slotState and not slot.isHiddenVisual and slot.transmogID then
		slot.backdrop:SetBackdropBorderColor(slot.Name:GetTextColor())
	else
		slot.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function DetailsPanelRefresh(panel)
	if not panel.slotPool then return end

	for slot in panel.slotPool:EnumerateActive() do
		if not slot.backdrop then
			slot:CreateBackdrop()
			slot.backdrop:SetOutside(slot.Icon)
			slot.IconBorder:SetAlpha(0)
			S:HandleIcon(slot.Icon)
		end

		SetItemQuality(slot)
	end
end

local function DressUpConfigureSize(frame, isMinimized)
	frame.OutfitDetailsPanel:ClearAllPoints()
	frame.OutfitDetailsPanel:Point('TOPLEFT', frame, 'TOPRIGHT', 4, 0)

	frame.OutfitDropDown:ClearAllPoints()
	frame.OutfitDropDown:Point('TOP', -(isMinimized and 42 or 28), -32)
	frame.OutfitDropDown:Width(isMinimized and 140 or 190)
end

function S:DressUpFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.dressingroom) then return end

	local DressUpFrame = _G.DressUpFrame
	S:HandlePortraitFrame(DressUpFrame)
	S:HandleMaxMinFrame(DressUpFrame.MaximizeMinimizeFrame)
	S:HandleButton(_G.DressUpFrameResetButton)
	S:HandleButton(_G.DressUpFrameCancelButton)
	S:HandleButton(DressUpFrame.LinkButton)
	S:HandleButton(DressUpFrame.ToggleOutfitDetailsButton)
	SetToggleIcon(DressUpFrame.ToggleOutfitDetailsButton, 1392954)

	DressUpFrame.ModelBackground:SetDrawLayer('BACKGROUND', 1)
	DressUpFrame.LinkButton:Size(110, 22)
	DressUpFrame.LinkButton:ClearAllPoints()
	DressUpFrame.LinkButton:Point('BOTTOMLEFT', 4, 4)

	_G.DressUpFrameCancelButton:Point('BOTTOMRIGHT', -4, 4)
	_G.DressUpFrameResetButton:Point('RIGHT', _G.DressUpFrameCancelButton, 'LEFT', -3, 0)

	local OutfitDropDown = DressUpFrame.OutfitDropDown
	S:HandleDropDownBox(OutfitDropDown)
	S:HandleButton(OutfitDropDown.SaveButton)
	OutfitDropDown.SaveButton:Size(80, 22)
	OutfitDropDown.SaveButton:Point('LEFT', OutfitDropDown, 'RIGHT', -7, 3)
	OutfitDropDown.Text:ClearAllPoints()
	OutfitDropDown.Text:Point('LEFT', OutfitDropDown.backdrop, 4, 0)
	OutfitDropDown.Text:Point('RIGHT', OutfitDropDown.backdrop, -4, 0)
	OutfitDropDown.backdrop:Point('TOPLEFT', 3, 3)

	-- 9.1.5 Outfit DetailPanel | Dont use StripTextures on the DetailsPanel, plx
	DressUpFrame.OutfitDetailsPanel:DisableDrawLayer('BACKGROUND')
	DressUpFrame.OutfitDetailsPanel:DisableDrawLayer('OVERLAY') -- to keep Artwork on the frame
	DressUpFrame.OutfitDetailsPanel:CreateBackdrop('Transparent')
	--DressUpFrame.OutfitDetailsPanel.ClassBackground:SetAllPoints()
	hooksecurefunc(DressUpFrame.OutfitDetailsPanel, 'Refresh', DetailsPanelRefresh)
	hooksecurefunc(DressUpFrame, 'ConfigureSize', DressUpConfigureSize)

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
