local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

local GetInventoryItemQuality = GetInventoryItemQuality
local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())

	local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame)
	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	-- Reposition Tabs
	_G.InspectFrameTab1:ClearAllPoints()
	_G.InspectFrameTab1:Point('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', -10, 0)
	_G.InspectFrameTab2:Point('TOPLEFT', _G.InspectFrameTab1, 'TOPRIGHT', -19, 0)
	_G.InspectFrameTab3:Point('TOPLEFT', _G.InspectFrameTab2, 'TOPRIGHT', -19, 0)
	_G.InspectFrameTab4:Point('TOPLEFT', _G.InspectFrameTab3, 'TOPRIGHT', -19, 0)

	_G.InspectPaperDollFrame:StripTextures()

	for _, slot in next, { _G.InspectPaperDollItemsFrame:GetChildren() } do
		local icon = _G[slot:GetName()..'IconTexture']
		local cooldown = _G[slot:GetName()..'Cooldown']

		slot:StripTextures()
		slot:CreateBackdrop()
		slot.backdrop:SetAllPoints()
		slot:OffsetFrameLevel(2)
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
	_G.InspectModelFrameRotateLeftButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateLeftButton:GetNormalTexture():SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
	_G.InspectModelFrameRotateLeftButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateLeftButton:GetPushedTexture():SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)

	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)
	_G.InspectModelFrameRotateRightButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateRightButton:GetNormalTexture():SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
	_G.InspectModelFrameRotateRightButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateRightButton:GetPushedTexture():SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)

	-- Talents
	S:HandleFrame(_G.InspectTalentFrame, true, nil, 11, -12, -32, 76)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
