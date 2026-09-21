local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local function RotateLeftButtonSetPoint(button, _, _, _, _, _, forced)
	if forced then return end

	button:Point('BOTTOMLEFT', _G.TabardModel, 'BOTTOMLEFT', 4, 4, true)
end

local function RotateRightButtonSetPoint(button, _, _, _, _, _, forced)
	if forced then return end

	button:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0, true)
end

function S:TabardFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tabard) then return end

	local TabardFrame = _G.TabardFrame
	S:HandleFrame(TabardFrame, true, nil, 10, -12, -32, 74)

	S:HandleCloseButton(_G.TabardFrameCloseButton)

	S:HandleButton(_G.TabardFrameCancelButton)
	S:HandleButton(_G.TabardFrameAcceptButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateLeftButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateRightButton)

	_G.TabardFrameCostFrame:StripTextures()
	_G.TabardFrameCustomizationFrame:StripTextures()

	-- Add Tabard Emblem back
	local emblemFrames = {
		_G.TabardFrameEmblemTopRight,
		_G.TabardFrameEmblemBottomRight,
		_G.TabardFrameEmblemTopLeft,
		_G.TabardFrameEmblemBottomLeft,
	}
	for _, frame in pairs(emblemFrames) do
		frame:SetParent(TabardFrame)
		frame.Show = nil
		frame:Show()
	end

	do
		local i = 1
		local button, previous = _G['TabardFrameCustomization'..i]
		while button do
			button:StripTextures()

			local left = _G['TabardFrameCustomization'..i..'LeftButton']
			if left then
				S:HandleNextPrevButton(left)
			end

			local right = _G['TabardFrameCustomization'..i..'RightButton']
			if right then
				S:HandleNextPrevButton(right)
			end

			if previous then
				button:ClearAllPoints()
				button:Point('TOP', previous, 'BOTTOM', 0, -6)
			else
				button:NudgePoint(0, 4)
			end

			i = i + 1
			previous = button
			button = _G['TabardFrameCustomization'..i]
		end
	end

	_G.TabardCharacterModelRotateLeftButton:Point('BOTTOMLEFT', 4, 4)
	_G.TabardCharacterModelRotateRightButton:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0)

	hooksecurefunc(_G.TabardCharacterModelRotateLeftButton, 'SetPoint', RotateLeftButtonSetPoint)
	hooksecurefunc(_G.TabardCharacterModelRotateRightButton, 'SetPoint', RotateRightButtonSetPoint)
end

S:AddCallback('TabardFrame')
