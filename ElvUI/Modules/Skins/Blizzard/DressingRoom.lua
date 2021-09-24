local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

-- Please check someone, Patch 9.1.5 new OutFit thing
local function ResetToggleTexture(button, texture)
	button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
	button:GetNormalTexture():SetInside()
	button:SetNormalTexture(texture)
	button:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
	button:GetPushedTexture():SetInside()
	button:SetPushedTexture(texture)
end

function S:DressUpFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.dressingroom) then return end

	local DressUpFrame = _G.DressUpFrame
	S:HandlePortraitFrame(DressUpFrame)

	S:HandleButton(_G.DressUpFrameResetButton)
	S:HandleButton(_G.DressUpFrameCancelButton)
	S:HandleButton(DressUpFrame.LinkButton)
	S:HandleButton(DressUpFrame.ToggleOutfitDetailsButton)
	ResetToggleTexture(DressUpFrame.ToggleOutfitDetailsButton, 1392954) -- find a better texture

	local DressUpFrameOutfitDropDown = _G.DressUpFrameOutfitDropDown
	S:HandleDropDownBox(DressUpFrameOutfitDropDown)
	S:HandleButton(DressUpFrameOutfitDropDown.SaveButton)
	DressUpFrameOutfitDropDown.SaveButton:Point('LEFT', DressUpFrameOutfitDropDown, 'RIGHT', -7, 3)
	DressUpFrameOutfitDropDown.backdrop:Point('TOPLEFT', -25, 3)

	S:HandleMaxMinFrame(DressUpFrame.MaximizeMinimizeFrame)
	_G.DressUpFrameResetButton:Point('RIGHT', _G.DressUpFrameCancelButton, 'LEFT', -2, 0)

	-- 9.1.5 Outfit DetailPanel | Dont use StripTextures on the DetailsPanel, plx
	DressUpFrame.OutfitDetailsPanel:DisableDrawLayer('BACKGROUND')
	DressUpFrame.OutfitDetailsPanel:DisableDrawLayer('OVERLAY') -- to keep Artwork on the frame
	DressUpFrame.OutfitDetailsPanel:CreateBackdrop('Transparent')

	-- ToDO: Reposition the frame
	-- @Simpy please check <3
	hooksecurefunc(DressUpFrame.OutfitDetailsPanel, 'Refresh', function(self)
		if self.slotPool then
			for slot in self.slotPool:EnumerateActive() do
				if not slot.isSkinned then
					S:HandleIcon(slot.Icon)
					--S:HandleIconBorder(slot.IconBorder) -- i dont get it
					slot.isSkinned = true
				end
			end
		end
	end)

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
