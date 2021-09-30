local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local TalentFrame = _G.TalentFrame
	S:HandleFrame(TalentFrame, true, nil, 11, -12, -32, 76)

	S:HandleCloseButton(_G.TalentFrameCloseButton, TalentFrame.backdrop)

	_G.TalentFrameCancelButton:Kill()

	for i = 1, 5 do
		S:HandleTab(_G['TalentFrameTab'..i])
	end

	_G.TalentFrameScrollFrame:StripTextures()
	_G.TalentFrameScrollFrame:CreateBackdrop('Default')

	S:HandleScrollBar(_G.TalentFrameScrollFrameScrollBar)
	_G.TalentFrameScrollFrameScrollBar:Point('TOPLEFT', _G.TalentFrameScrollFrame, 'TOPRIGHT', 10, -16)

	_G.TalentFrameSpentPoints:Point('TOP', 0, -42)
	_G.TalentFrameTalentPointsText:Point('BOTTOMRIGHT', TalentFrame, 'BOTTOMLEFT', 220, 84)

	for i = 1, _G.MAX_NUM_TALENTS do
		local talent = _G['TalentFrameTalent'..i]
		local icon = _G['TalentFrameTalent'..i..'IconTexture']
		local rank = _G['TalentFrameTalent'..i..'Rank']

		if talent then
			talent:StripTextures()
			talent:SetTemplate('Default')
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')

			rank:SetFont(E.LSM:Fetch('font', E.db['general'].font), 12, 'OUTLINE')
		end
	end
end

S:AddCallbackForAddon('Blizzard_TalentUI')
