local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
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
	S:HandleFrame(TabardFrame)

	_G.TabardFrameMoneyInset:StripTextures()
	_G.TabardFrameMoneyBg:StripTextures()

	S:HandleButton(_G.TabardFrameCancelButton)
	S:HandleButton(_G.TabardFrameAcceptButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateLeftButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateRightButton)

	_G.TabardFrameCostFrame:StripTextures()
	_G.TabardFrameCustomizationFrame:StripTextures()

	for i = 1, 5 do
		local button = _G['TabardFrameCustomization'..i]
		button:StripTextures()

		S:HandleNextPrevButton(_G['TabardFrameCustomization'..i..'LeftButton'])
		S:HandleNextPrevButton(_G['TabardFrameCustomization'..i..'RightButton'])

		if i == 1 then
			button:NudgePoint(0, 4)
		else
			button:ClearAllPoints()
			button:Point('TOP', _G['TabardFrameCustomization'..(i - 1)], 'BOTTOM', 0, -6)
		end
	end

	_G.TabardCharacterModelRotateLeftButton:Point('BOTTOMLEFT', 4, 4)
	_G.TabardCharacterModelRotateRightButton:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0)

	hooksecurefunc(_G.TabardCharacterModelRotateLeftButton, 'SetPoint', RotateLeftButtonSetPoint)
	hooksecurefunc(_G.TabardCharacterModelRotateRightButton, 'SetPoint', RotateRightButtonSetPoint)
end

S:AddCallback('TabardFrame')
