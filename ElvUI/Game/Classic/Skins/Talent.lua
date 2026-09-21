local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local MAX_TALENT_TABS = MAX_TALENT_TABS
local MAX_NUM_TALENTS = MAX_NUM_TALENTS

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandleFrame(PlayerTalentFrame, true, nil, 11, -12, -32, 76)

	-- Not a "cancel button", just a duplicate Closebutton
	_G.PlayerTalentFrameCancelButton:Kill()

	for i = 1, MAX_TALENT_TABS do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	-- Reposition Tabs
	_G.PlayerTalentFrameTab1:ClearAllPoints()
	_G.PlayerTalentFrameTab1:Point('TOPLEFT', PlayerTalentFrame, 'BOTTOMLEFT', 1, 76)
	_G.PlayerTalentFrameTab2:Point('TOPLEFT', _G.PlayerTalentFrameTab1, 'TOPRIGHT', -19, 0)
	_G.PlayerTalentFrameTab3:Point('TOPLEFT', _G.PlayerTalentFrameTab2, 'TOPRIGHT', -19, 0)

	for i = 1, 3 do -- spec1, spec2, petspec1
		local tab = _G['PlayerSpecTab'..i]
		local background = tab:GetRegions()
		background:Hide()

		tab:SetTemplate()
		tab:StyleButton(nil, true)

		local normal = tab:GetNormalTexture()
		normal:SetInside()
		normal:SetTexCoords()
	end

	S:HandleButton(_G.PlayerTalentFrameActivateButton)
	_G.PlayerTalentFrameStatusFrame:StripTextures()

	local scrollFrame = _G.PlayerTalentFrameScrollFrame
	scrollFrame:StripTextures()
	scrollFrame:CreateBackdrop()

	local scrollBar = _G.PlayerTalentFrameScrollFrameScrollBar
	S:HandleScrollBar(scrollBar)
	scrollBar:Point('TOPLEFT', scrollFrame, 'TOPRIGHT', 10, -16)

	local pointsBar = _G.PlayerTalentFramePointsBar
	_G.PlayerTalentFrameSpentPointsText:Point('LEFT', pointsBar, 'LEFT', 12, -1)

	local talentPointsText = _G.PlayerTalentFrameTalentPointsText
	talentPointsText:ClearAllPoints()
	talentPointsText:Point('RIGHT', pointsBar, 'RIGHT', 60, -1)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G['PlayerTalentFrameTalent'..i]
		talent:StripTextures()
		talent:SetTemplate()
		talent:StyleButton()

		local icon = talent.icon
		icon:SetInside()
		icon:SetTexCoords()
		icon:SetDrawLayer('ARTWORK')

		local rank = _G['PlayerTalentFrameTalent'..i..'Rank']
		rank:FontTemplate(nil, 12, 'OUTLINE')
	end

	-- Talent preview section / E:SetCVar('previewTalents', 1)
	_G.PlayerTalentFramePreviewBar:StripTextures()
	_G.PlayerTalentFramePreviewBarFiller:StripTextures()

	local learnButton = _G.PlayerTalentFrameLearnButton
	S:HandleButton(learnButton)
	learnButton:ClearAllPoints()
	learnButton:Point('BOTTOMLEFT', PlayerTalentFrame, 'BOTTOMLEFT', 18, 80)

	local resetButton = _G.PlayerTalentFrameResetButton
	S:HandleButton(resetButton)
	resetButton:ClearAllPoints()
	resetButton:Point('BOTTOMRIGHT', PlayerTalentFrame, 'BOTTOMRIGHT', -38, 80)
end

S:AddCallbackForAddon('Blizzard_TalentUI')
