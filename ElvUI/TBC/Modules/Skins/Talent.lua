local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	S:HandleFrame(_G.PlayerTalentFrame, true, nil, 11, -12, -32, 76)
	S:HandleCloseButton(_G.PlayerTalentFrameCloseButton, _G.PlayerTalentFrame.backdrop)

	_G.PlayerTalentFrameCancelButton:Kill()

	for i = 1, 3 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	_G.PlayerTalentFrameScrollFrame:StripTextures()
	_G.PlayerTalentFrameScrollFrame:CreateBackdrop()

	S:HandleScrollBar(_G.PlayerTalentFrameScrollFrameScrollBar)
	_G.PlayerTalentFrameScrollFrameScrollBar:Point('TOPLEFT', _G.PlayerTalentFrameScrollFrame, 'TOPRIGHT', 10, -16)

	_G.PlayerTalentFrameSpentPoints:Point('TOP', 0, -42)
	_G.PlayerTalentFrameTalentPointsText:Point('BOTTOMRIGHT', _G.PlayerTalentFrame, 'BOTTOMLEFT', 220, 84)

	for i = 1, _G.MAX_NUM_TALENTS do
		local talent = _G['PlayerTalentFrameTalent'..i]
		local icon = _G['PlayerTalentFrameTalent'..i..'IconTexture']
		local rank = _G['PlayerTalentFrameTalent'..i..'Rank']

		if talent then
			talent:StripTextures()
			talent:SetTemplate()
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')

			rank:SetFont(E.LSM:Fetch('font', E.db['general'].font), 12, 'OUTLINE')
		end
	end
end

S:AddCallbackForAddon('Blizzard_TalentUI')
