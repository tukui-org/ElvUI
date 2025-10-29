local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local GetItemIconByID = C_Item.GetItemIconByID
local GetReforgeItemInfo = C_Reforge.GetReforgeItemInfo

local function ReforgingFrameUpdate()
	local _, itemID, _, quality = GetReforgeItemInfo()
	local texture = itemID and GetItemIconByID(itemID) or nil
	_G.ReforgingFrameItemButtonIconTexture:SetTexture(texture)
	_G.ReforgingFrameItemButtonIconTexture:SetTexCoords()

	local r, g, b = E:GetItemQualityColor(quality)
	_G.ReforgingFrameItemButton:SetBackdropBorderColor(r, g, b)
end

function S:Blizzard_ReforgingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.reforge) then return end

	local ReforgingFrame = _G.ReforgingFrame
	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate('Transparent')

	_G.ReforgingFrameFinishedGlow:Kill()
	_G.ReforgingFrameButtonFrame:StripTextures()
	_G.ReforgingFrameItemButtonIconTexture:SetInside()

	S:HandleButton(_G.ReforgingFrameRestoreButton, true)
	S:HandleButton(_G.ReforgingFrameReforgeButton, true)
	S:HandleCloseButton(_G.ReforgingFrameCloseButton)

	ReforgingFrame.missingDescription:SetTextColor(1, 1, 1)
	_G.ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1)
	_G.ReforgingFrameReforgeButton:Point('BOTTOMRIGHT', -3, 3)

	local ItemButton = _G.ReforgingFrameItemButton
	if ItemButton then
		ItemButton.missingText:SetTextColor(1, 0.80, 0.10)
		ItemButton:StripTextures()
		ItemButton:SetTemplate(nil, true)
		ItemButton:StyleButton()
	end

	hooksecurefunc('ReforgingFrame_Update', ReforgingFrameUpdate)
end

S:AddCallbackForAddon('Blizzard_ReforgingUI')
