local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local MAX_NUM_TALENTS = MAX_NUM_TALENTS

local function GlyphFrameOnShow()
	_G.PlayerTalentFrameTitleText:Hide()
	_G.PlayerTalentFramePointsBar:Hide()
	_G.PlayerTalentFrameScrollFrame:Hide()
	_G.PlayerTalentFrameStatusFrame:Hide()
end

local function GlyphFrameOnHide()
	_G.PlayerTalentFrameTitleText:Show()
	_G.PlayerTalentFramePointsBar:Show()
	_G.PlayerTalentFrameScrollFrame:Show()
end

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandleFrame(PlayerTalentFrame, true, nil, 11, -12, -32, 76)

	for i = 1, 4 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	-- Reposition Tabs
	_G.PlayerTalentFrameTab1:ClearAllPoints()
	_G.PlayerTalentFrameTab1:Point('TOPLEFT', PlayerTalentFrame, 'BOTTOMLEFT', 1, 76)
	_G.PlayerTalentFrameTab2:Point('TOPLEFT', _G.PlayerTalentFrameTab1, 'TOPRIGHT', -19, 0)
	_G.PlayerTalentFrameTab3:Point('TOPLEFT', _G.PlayerTalentFrameTab2, 'TOPRIGHT', -19, 0)
	_G.PlayerTalentFrameTab4:Point('TOPLEFT', _G.PlayerTalentFrameTab3, 'TOPRIGHT', -19, 0)

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
	pointsBar:StripTextures()

	_G.PlayerTalentFrameSpentPointsText:Point('LEFT', pointsBar, 'LEFT', 12, -1)
	_G.PlayerTalentFrameTalentPointsText:Point('RIGHT', pointsBar, 'RIGHT', -12, -1)

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

function S:Blizzard_GlyphUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local GlyphFrame = _G.GlyphFrame

	-- Otherwise TalenFrame texts/elements will overlap with Glyph texts/elements
	GlyphFrame:HookScript('OnShow', GlyphFrameOnShow)
	GlyphFrame:HookScript('OnHide', GlyphFrameOnHide)
	GlyphFrame:StripTextures()

	local background = _G.GlyphFrameBackground
	background:Size(334, 385)
	background:Point('TOPLEFT', 15, -47)
	background:SetTexture([[Interface\Spellbook\UI-GlyphFrame]])
	background:SetTexCoord(0.041015625, 0.65625, 0.140625, 0.8046875)

	local glyphGlow = _G.GlyphFrameGlow
	glyphGlow:SetAllPoints(background)
	glyphGlow:SetTexture([[Interface\Spellbook\UI-GlyphFrame-Glow]])
	glyphGlow:SetTexCoord(0.05859375, 0.673828125, 0.06640625, 0.73046875)
end

S:AddCallbackForAddon('Blizzard_TalentUI')
S:AddCallbackForAddon('Blizzard_GlyphUI')
