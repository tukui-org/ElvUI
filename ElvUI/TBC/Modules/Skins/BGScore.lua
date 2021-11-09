local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:SkinWorldStateScore()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgscore) then return end

	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	S:HandleFrame(WorldStateScoreFrame, true, nil, 0, -5, -70, 25)

	_G.WorldStateScoreScrollFrame:StripTextures()
	_G.WorldStateScoreScrollFrameScrollBar:SetPoint('RIGHT', 110, 40)
	S:HandleScrollBar(_G.WorldStateScoreScrollFrameScrollBar)

	for i = 1, 3 do
		S:HandleTab(_G['WorldStateScoreFrameTab'..i])
		_G['WorldStateScoreFrameTab'..i..'Text']:SetPoint('CENTER', 0, 2)
	end

	S:HandleButton(_G.WorldStateScoreFrameLeaveButton)
	S:HandleCloseButton(_G.WorldStateScoreFrameCloseButton)
	_G.WorldStateScoreFrameCloseButton:SetPoint('TOPRIGHT', -68, 0)

	_G.WorldStateScoreFrameKB:StyleButton()
	_G.WorldStateScoreFrameDeaths:StyleButton()
	_G.WorldStateScoreFrameHK:StyleButton()
	_G.WorldStateScoreFrameHonorGained:StyleButton()
	_G.WorldStateScoreFrameName:StyleButton()

	for i = 1, 7 do
		_G['WorldStateScoreColumn'..i]:StyleButton()
	end
end

S:AddCallback('SkinWorldStateScore')
