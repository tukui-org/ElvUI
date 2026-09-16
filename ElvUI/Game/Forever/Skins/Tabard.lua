local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

function S:TabardFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tabard) then return end

	local TabardFrame = _G.TabardFrame
	S:HandlePortraitFrame(TabardFrame)

	S:HandleButton(_G.TabardFrameCancelButton)
	S:HandleButton(_G.TabardFrameAcceptButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateLeftButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateRightButton)

	_G.TabardFrameCostFrame:StripTextures()
	_G.TabardFrameCustomizationFrame:StripTextures()
	_G.TabardFrameMoneyInset:Kill()
	_G.TabardFrameMoneyBg:StripTextures()

	local TabardModel = _G.TabardModel
	TabardModel:SetTemplate()

	-- Add Tabard Emblem back
	for _, frame in next, {
		_G.TabardFrameEmblemTopRight,
		_G.TabardFrameEmblemBottomRight,
		_G.TabardFrameEmblemTopLeft,
		_G.TabardFrameEmblemBottomLeft,
	} do
		frame:SetParent(TabardModel)
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

	_G.TabardCharacterModelRotateLeftButton:Point('BOTTOMLEFT', TabardModel, 'BOTTOMLEFT', 4, 4)
	hooksecurefunc(_G.TabardCharacterModelRotateLeftButton, 'SetPoint', function(s, _, _, _, _, _, forced)
		if forced ~= true then
			s:Point('BOTTOMLEFT', TabardModel, 'BOTTOMLEFT', 4, 4, true)
		end
	end)

	_G.TabardCharacterModelRotateRightButton:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0)
	hooksecurefunc(_G.TabardCharacterModelRotateRightButton, 'SetPoint', function(s, _, _, _, _, _, forced)
		if forced ~= true then
			s:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0, true)
		end
	end)
end

S:AddCallback('TabardFrame')
