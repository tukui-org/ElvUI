local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, unpack = ipairs, unpack

local GetInventoryItemID = GetInventoryItemID
local GetItemQualityColor = GetItemQualityColor
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	if not unit then return end

	local itemID = GetInventoryItemID(unit, button:GetID())
	if itemID then
		local _, _, quality = GetItemInfo(itemID)
		if quality and quality > 1 then
			local r, g, b = GetItemQualityColor(quality)
			button.backdrop:SetBackdropBorderColor(r, g, b)
			return
		end
	end

	button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame, true, nil, 11, -12, -32, 76)

	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	_G.InspectPaperDollFrame:StripTextures()

	for _, slot in ipairs({ _G.InspectPaperDollItemsFrame:GetChildren() }) do
		local icon = _G[slot:GetName()..'IconTexture']
		local cooldown = _G[slot:GetName()..'Cooldown']

		slot:StripTextures()
		slot:CreateBackdrop()
		slot.backdrop:SetAllPoints()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', Update_InspectPaperDollItemSlotButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)

	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- Honor Frame
	local InspectHonorFrame = _G.InspectHonorFrame
	S:HandleFrame(InspectHonorFrame, true, nil, 18, -105, -39, 83)
	InspectHonorFrame.backdrop:SetFrameLevel(InspectHonorFrame:GetFrameLevel())

	_G.InspectHonorFrameProgressButton:CreateBackdrop('Transparent')

	local InspectHonorFrameProgressBar = _G.InspectHonorFrameProgressBar
	InspectHonorFrameProgressBar:Width(325)
	InspectHonorFrameProgressBar:SetStatusBarTexture(E.media.normTex)

	S:HandlePointXY(InspectHonorFrameProgressBar, 19, -74)

	E:RegisterStatusBar(InspectHonorFrameProgressBar)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
