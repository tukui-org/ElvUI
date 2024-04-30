local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetItemIconByID = C_Item.GetItemIconByID
local GetReforgeItemInfo = C_Reforge.GetReforgeItemInfo

local function ReforgingFrameUpdate()
	local _, itemID, _, quality = GetReforgeItemInfo()
	local itemTexture = itemID and GetItemIconByID(itemID)
	if itemTexture then
		_G.ReforgingFrameItemButtonIconTexture:SetTexture(itemTexture)
	end

	--[[ Blizzard bug / commented out on their end / Blizzard_ReforgingUI.lua:101
	if quality then
		local r, g, b = GetItemQualityColor(quality)
		_G.ReforgingFrameItemButton:SetBackdropBorderColor(r, g, b)
	else
		local r, g, b = unpack(E.media.bordercolor)
		_G.ReforgingFrameItemButton:SetBackdropBorderColor(r, g, b)
	end
	]]
end

function S:Blizzard_ReforgingUI()
	if not (E.private.skins.blizzard.enable or not E.private.skins.blizzard.reforge) then return end

	local ReforgingFrame = _G.ReforgingFrame
	ReforgingFrame:StripTextures()
	ReforgingFrame:SetTemplate('Transparent')

	_G.ReforgingFrameFinishedGlow:Kill()
	_G.ReforgingFrameButtonFrame:StripTextures()

	S:HandleButton(_G.ReforgingFrameRestoreButton, true)
	S:HandleButton(_G.ReforgingFrameReforgeButton, true)
	S:HandleCloseButton(_G.ReforgingFrameCloseButton)

	ReforgingFrame.missingDescription:SetTextColor(1, 1, 1)
	_G.ReforgingFrameRestoreMessage:SetTextColor(1, 1, 1)
	_G.ReforgingFrameReforgeButton:Point('BOTTOMRIGHT', -3, 3)

	_G.ReforgingFrameItemButtonIconTexture:SetInside()
	_G.ReforgingFrameItemButtonIconTexture:SetTexCoord(unpack(E.TexCoords))

	local ItemButton = _G.ReforgingFrameItemButton
	ItemButton.missingText:SetTextColor(1, 0.80, 0.10)
	ItemButton:StripTextures()
	ItemButton:SetTemplate('Default', true)
	ItemButton:StyleButton()

	hooksecurefunc('ReforgingFrame_Update', ReforgingFrameUpdate)
end

S:AddCallbackForAddon('Blizzard_ReforgingUI')
