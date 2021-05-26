local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

function S:TabardFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tabard) then return end

	local TabardFrame = _G.TabardFrame
	S:HandlePortraitFrame(TabardFrame)

	S:HandleButton(_G.TabardFrameCancelButton)
	S:HandleButton(_G.TabardFrameAcceptButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateLeftButton)
	S:HandleRotateButton(_G.TabardCharacterModelRotateRightButton)

	_G.TabardModel:SetTemplate()
	_G.TabardFrameCostFrame:StripTextures()
	_G.TabardFrameCustomizationFrame:StripTextures()
	_G.TabardFrameMoneyInset:Kill()
	_G.TabardFrameMoneyBg:StripTextures()

	--Add Tabard Emblem back
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

	for i=1, 5 do
		local custom = 'TabardFrameCustomization'..i
		_G[custom]:StripTextures()
		S:HandleNextPrevButton(_G[custom..'LeftButton'])
		S:HandleNextPrevButton(_G[custom..'RightButton'])

		if i > 1 then
			_G[custom]:ClearAllPoints()
			_G[custom]:Point('TOP', _G['TabardFrameCustomization'..i-1], 'BOTTOM', 0, -6)
		else
			local point, anchor, point2, x, y = _G[custom]:GetPoint()
			_G[custom]:Point(point, anchor, point2, x, y+4)
		end
	end

	_G.TabardCharacterModelRotateLeftButton:Point('BOTTOMLEFT', _G.TabardModel, 'BOTTOMLEFT', 4, 4)
	_G.TabardCharacterModelRotateRightButton:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0)
	hooksecurefunc(_G.TabardCharacterModelRotateLeftButton, 'SetPoint', function(s, _, _, _, _, _, forced)
		if forced ~= true then
			s:Point('BOTTOMLEFT', _G.TabardModel, 'BOTTOMLEFT', 4, 4, true)
		end
	end)

	hooksecurefunc(_G.TabardCharacterModelRotateRightButton, 'SetPoint', function(s, _, _, _, _, _, forced)
		if forced ~= true then
			s:Point('TOPLEFT', _G.TabardCharacterModelRotateLeftButton, 'TOPRIGHT', 4, 0, true)
		end
	end)
end

S:AddCallback('TabardFrame')
