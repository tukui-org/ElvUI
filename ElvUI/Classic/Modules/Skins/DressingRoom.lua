local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:DressUpFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.dressingroom) then return end

	local DressUpFrame = _G.DressUpFrame
	S:HandleFrame(DressUpFrame, true)

	DressUpFrame.BGBottomLeft:SetDesaturated(true)
	DressUpFrame.BGBottomRight:SetDesaturated(true)
	DressUpFrame.BGTopLeft:SetDesaturated(true)
	DressUpFrame.BGTopRight:SetDesaturated(true)

	_G.DressUpFrameDescriptionText:Point('CENTER', _G.DressUpFrameTitleText, 'BOTTOM', -5, -22)

	S:HandleCloseButton(_G.DressUpFrameCloseButton, DressUpFrame.backdrop)

	-- Rotate Buttons
	S:HandleRotateButton(_G.DressUpModelFrameRotateLeftButton)
	_G.DressUpModelFrameRotateLeftButton:Point('TOPLEFT', DressUpFrame, 25, -79)
	S:HandleRotateButton(_G.DressUpModelFrameRotateRightButton)
	_G.DressUpModelFrameRotateRightButton:Point('TOPLEFT', _G.DressUpModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- Cancel and Reset
	S:HandleButton(_G.DressUpFrameCancelButton)
	_G.DressUpFrameCancelButton:Point('BOTTOMRIGHT', -12, 4)
	S:HandleButton(_G.DressUpFrameResetButton)
	_G.DressUpFrameResetButton:Point('RIGHT', _G.DressUpFrameCancelButton, 'LEFT', -3, 0)

	S:HandleFrame(_G.DressUpModelFrame, true, nil, -2, -19, 0, -1)
end

S:AddCallback('DressUpFrame')
