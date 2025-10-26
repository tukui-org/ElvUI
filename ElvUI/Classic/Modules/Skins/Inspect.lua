local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local GetInventoryItemQuality = GetInventoryItemQuality

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())

	local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

local function HandleTabs()
	local tab = _G.InspectFrameTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', -10, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['InspectFrameTab'..index]
	end
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame)
	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	-- Tabs
	HandleTabs()

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	_G.InspectPaperDollFrame:StripTextures()
	_G.InspectModelFrameBackgroundOverlay:SetTexture(E.Media.Textures.Invisible)
	_G.InspectModelFrameBackgroundOverlay:CreateBackdrop('Transparent')

	_G.InspectModelFrameBorderTopLeft:Kill()
	_G.InspectModelFrameBorderTopRight:Kill()
	_G.InspectModelFrameBorderTop:Kill()
	_G.InspectModelFrameBorderLeft:Kill()
	_G.InspectModelFrameBorderRight:Kill()
	_G.InspectModelFrameBorderBottomLeft:Kill()
	_G.InspectModelFrameBorderBottomRight:Kill()
	_G.InspectModelFrameBorderBottom:Kill()

	for _, slot in next, { _G.InspectPaperDollItemsFrame:GetChildren() } do
		slot:StripTextures()
		slot:CreateBackdrop()
		slot.backdrop:SetAllPoints()
		slot:OffsetFrameLevel(2)
		slot:StyleButton()

		local name = slot:GetName()
		local icon = _G[name..'IconTexture']
		if icon then
			icon:SetTexCoords()
			icon:SetInside()
		end

		local cooldown = _G[name..'Cooldown']
		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', Update_InspectPaperDollItemSlotButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)

	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- PvP Tab
	local InspectHonorFrame = _G.InspectHonorFrame
	InspectHonorFrame:StripTextures()

	_G.InspectHonorFrameProgressButton:CreateBackdrop('Transparent')

	local InspectHonorFrameProgressBar = _G.InspectHonorFrameProgressBar
	InspectHonorFrameProgressBar:SetStatusBarTexture(E.media.normTex)
	InspectHonorFrameProgressBar:PointXY(19, -74)
	InspectHonorFrameProgressBar:Width(300)

	E:RegisterStatusBar(InspectHonorFrameProgressBar)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
