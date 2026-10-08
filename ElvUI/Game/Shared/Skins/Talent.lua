local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local strfind = strfind
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local GetNumSpecializations = GetNumSpecializations
local C_SpecializationInfo_GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo

local MAX_NUM_TALENTS = MAX_NUM_TALENTS

S:AddCallbackForAddon('Blizzard_TalentUI', nil, nil, nil, nil, nil, 'talent')

if E.Mists or E.Wrath then
	S:AddCallbackForAddon('Blizzard_GlyphUI', nil, nil, nil, nil, nil, 'talent')
end

local function ClearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 0)
end

local function PositionTabs()
	_G.PlayerTalentFrameTab1:ClearAllPoints()
	_G.PlayerTalentFrameTab1:Point('TOPLEFT', _G.PlayerTalentFrame, 'BOTTOMLEFT', -10, 0)
	_G.PlayerTalentFrameTab2:Point('TOPLEFT', _G.PlayerTalentFrameTab1, 'TOPRIGHT', -19, 0)
	_G.PlayerTalentFrameTab3:Point('TOPLEFT', _G.PlayerTalentFrameTab2, 'TOPRIGHT', -19, 0)
	_G.PlayerTalentFrameTab4:Point('TOPLEFT', _G.PlayerTalentFrameTab3, 'TOPRIGHT', -19, 0)
end

local function GlyphFrameUpdate(frame)
	frame.levelOverlayText1:SetTextColor(1, 1, 1)
	frame.levelOverlayText2:SetTextColor(1, 1, 1)

	local talentFrame = _G.PlayerTalentFrame
	local talentGroup = talentFrame and talentFrame.talentGroup -- same guard as Blizzard's GlyphFrameGlyph_UpdateSlot
	local left, right, top, bottom = E:GetTexCoords()
	for i = 1, _G.NUM_GLYPH_SLOTS do
		local glyph = _G['GlyphFrameGlyph'..i]
		local _, _, _, _, iconFilename = _G.GetGlyphSocketInfo(i, talentGroup)
		if iconFilename then
			glyph.icon:SetTexture(iconFilename)
			glyph.icon:SetTexCoord(left, right, top, bottom)
		else
			glyph.icon:SetTexture([[Interface\Spellbook\UI-Glyph-Rune-]]..i)
			glyph.icon:SetTexCoord(0, 1, 0, 1)
		end

		_G.GlyphFrameGlyph_UpdateSlot(glyph)
	end
end

local function GlyphFrameGlyph_OnUpdate(updater)
	local frame = updater.owner
	local glyphTexture = frame.icon:GetTexture()
	local glyphIcon = glyphTexture and strfind(glyphTexture, [[Interface\Spellbook\UI%-Glyph%-Rune]])

	local alpha = frame.highlight:GetAlpha()
	if alpha == 0 then
		local r, g, b = unpack(E.media.bordercolor)
		frame:SetBackdropBorderColor(r, g, b)
		frame:SetAlpha(1)

		if glyphIcon then
			frame.icon:SetVertexColor(1, 1, 1, 1)
			frame.icon:SetAlpha(1)
		end
	else
		local r, g, b = unpack(E.media.rgbvaluecolor)
		frame:SetBackdropBorderColor(r, g, b)
		frame:SetAlpha(alpha)

		if glyphIcon then
			frame.icon:SetVertexColor(r, g, b)
			frame.icon:SetAlpha(alpha)
		end
	end
end

local function TalentFrameUpdate()
	for i = 1, 6 do -- talent tiers
		for j = 1, 3 do -- talents per tier
			local button = _G['PlayerTalentFrameTalentsTalentRow'..i..'Talent'..j]
			button.icon:SetDesaturated(false)

			if button.knownSelection:IsShown() then
				button.bg.SelectedTexture:Show()
				button.ShadowedTexture:Hide()
			else
				button.bg.SelectedTexture:Hide()
				button.ShadowedTexture:Show()
			end

			if button.learnSelection:IsShown() then
				button.ShadowedTexture:Hide()

				local r, g, b = unpack(E.media.rgbvaluecolor)
				button.bg:SetBackdropBorderColor(r, g, b)
			else
				local r, g, b = unpack(E.media.bordercolor)
				button.bg:SetBackdropBorderColor(r, g, b)
			end
		end
	end
end

local function PlayerTalentFrameUpdateSpecFrame(frame)
	local numButtons = GetNumSpecializations(nil, frame.isPet)
	for i = 1, numButtons do
		local button = frame['specButton'..i]
		button.SelectedTexture:SetShown(button.selected)
	end

	-- Blizzard creates the ability buttons it needs before this hook runs
	local scrollChild = frame.spellsScroll.child
	local index, ability = 1, scrollChild.abilityButton1
	while ability do
		if not ability.backdrop then
			ability.ring:Hide()
			ability.icon:SetTexCoords()
			ability.icon:SetInside(ability, 8, 8)

			ability:CreateBackdrop()
			ability.backdrop:SetOutside(ability.icon)
		end

		ability.subText:SetTextColor(.6, .6, .6)

		index = index + 1
		ability = scrollChild['abilityButton'..index]
	end

	-- Hide the default flash anim
	frame.learnButton.Flash:Hide()
	frame.learnButton.FlashAnim:Stop()
end

local function Transition_OnFinished(frame)
	local r, g, b = frame:GetChange()
	local defaultR, defaultG, defaultB = unpack(E.media.bordercolor)
	defaultR = E:Round(defaultR, 2)
	defaultG = E:Round(defaultG, 2)
	defaultB = E:Round(defaultB, 2)

	if r == defaultR and g == defaultG and b == defaultB then
		frame:SetChange(unpack(E.media.rgbvaluecolor))
	else
		frame:SetChange(defaultR, defaultG, defaultB)
	end
end

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

local function SkinMistsTalentFrame()
	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandlePortraitFrame(PlayerTalentFrame)

	_G.PlayerTalentFrameTalents:StripTextures()

	local disableTutorialButtons = E.global.general.disableTutorialButtons
	if disableTutorialButtons then
		_G.PlayerTalentFrameTalentsTutorialButton:Kill()
	end

	S:HandleButton(_G.PlayerTalentFrameActivateButton)
	S:HandleButton(_G.PlayerTalentFrameSpecializationLearnButton)
	S:HandleButton(_G.PlayerTalentFrameTalentsLearnButton)
	S:HandleButton(_G.PlayerTalentFramePetSpecializationLearnButton)

	for i = 1, 4 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	-- Reposition Tabs
	PositionTabs()
	hooksecurefunc('PlayerTalentFrame_UpdateTabs', PositionTabs)

	for _, frame in next, { _G.PlayerTalentFrameSpecialization, _G.PlayerTalentFramePetSpecialization } do
		frame:StripTextures()

		if disableTutorialButtons then
			frame.MainHelpButton:Kill()
		end

		for _, child in next, { frame:GetChildren() } do
			if not child:GetName() then -- the border art frame has no name or key
				child:StripTextures()
			end
		end

		for i = 1, 4 do
			local button = frame['specButton'..i]
			local _, _, _, icon = C_SpecializationInfo_GetSpecializationInfo(i, false, frame.isPet)

			local glow = _G[button:GetName()..'Glow']
			glow:Kill()

			button:CreateBackdrop()
			button.backdrop:Point('TOPLEFT', 8, 2)
			button.backdrop:Point('BOTTOMRIGHT', 10, -2)

			button.specIcon:Size(50, 50)
			button.specIcon:Point('LEFT', button, 'LEFT', 15, 0)
			button.specIcon:SetDrawLayer('ARTWORK', 2)
			button.roleIcon:SetDrawLayer('ARTWORK', 2)

			button.bg:SetAlpha(0)
			button.ring:SetAlpha(0)
			button.learnedTex:SetAlpha(0)
			button.selectedTex:SetAlpha(0)
			button.CircleMask:Hide()
			button.specIcon:SetTexture(icon)
			S:HandleIcon(button.specIcon, true, nil, nil, nil, nil, nil, nil, button:GetFrameLevel() + 1)
			button.specIcon.backdrop:SetBackdropColor(0, 0, 0, 0)
			button.specIcon.backdrop.callbackBackdropColor = ClearBackdrop
			button:SetHighlightTexture(E.ClearTexture)

			button.SelectedTexture = button:CreateTexture(nil, 'ARTWORK')
			button.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)
			button.SelectedTexture:SetInside(button.backdrop)
		end

		S:HandleScrollBar(frame.spellsScroll.ScrollBar)

		local child = frame.spellsScroll.child
		child:SetScale(0.99) -- the scrollbar showed on simpy's when it shouldn't, this fixes it by reducing the scale by .01 lol
		child.gradient:Kill()
		child.scrollwork_topleft:SetAlpha(0)
		child.scrollwork_topright:SetAlpha(0)
		child.scrollwork_bottomleft:SetAlpha(0)
		child.scrollwork_bottomright:SetAlpha(0)
		child.ring:SetAlpha(0)
		child.Seperator:SetAlpha(0)
		child.CircleMask:Hide()

		S:HandleIcon(child.specIcon, true)
	end

	for i = 1, 6 do -- talent tiers
		local row = _G['PlayerTalentFrameTalentsTalentRow'..i]
		row:StripTextures()

		row.TopLine:Point('TOP', 0, 4)
		row.BottomLine:Point('BOTTOM', 0, -4)

		local transition = _G.CreateAnimationGroup(row)
		transition:SetLooping(true)
		row.transition = transition

		local colorAnimation = transition:CreateAnimation('color')
		colorAnimation:SetDuration(0.7)
		colorAnimation:SetColorType('border')
		colorAnimation:SetChange(unpack(E.media.rgbvaluecolor))
		colorAnimation:SetScript('OnFinished', Transition_OnFinished)
		transition.color = colorAnimation

		for j = 1, 3 do -- talents per tier
			local button = _G['PlayerTalentFrameTalentsTalentRow'..i..'Talent'..j]
			button:StripTextures()
			button:OffsetFrameLevel(5)
			button.knownSelection:SetAlpha(0)
			button.icon:SetDrawLayer('ARTWORK', 1)
			S:HandleIcon(button.icon, true)

			button.bg = CreateFrame('Frame', nil, button)
			button.bg:SetTemplate()
			button.bg:OffsetFrameLevel(-4, button)
			button.bg:Point('TOPLEFT', 15, 2)
			button.bg:Point('BOTTOMRIGHT', -10, -2)

			colorAnimation:AddChild(button.bg)

			button:SetHighlightTexture(E.media.blankTex)
			local highlight = button:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, 0.2)
			highlight:SetInside(button.bg)

			button.bg.SelectedTexture = button.bg:CreateTexture(nil, 'ARTWORK')
			button.bg.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)
			button.bg.SelectedTexture:SetInside(button.bg)

			button.ShadowedTexture = button:CreateTexture(nil, 'OVERLAY', nil, -2)
			button.ShadowedTexture:SetAllPoints(button.bg.SelectedTexture)
			button.ShadowedTexture:SetColorTexture(0, 0, 0, 0.6)
		end
	end

	for i = 1, 2 do
		local tab = _G['PlayerSpecTab'..i]
		local background = tab:GetRegions()
		background:Hide()

		tab:SetTemplate()
		tab:StyleButton(nil, true)

		local normal = tab:GetNormalTexture()
		normal:SetInside()
		normal:SetTexCoords()
	end

	hooksecurefunc('TalentFrame_Update', TalentFrameUpdate)
	hooksecurefunc('PlayerTalentFrame_UpdateSpecFrame', PlayerTalentFrameUpdateSpecFrame)
end

-- Blizzard_TalentUI's Classic folder, loaded by Wrath, TBC and Vanilla
local function SkinClassicTalentFrame()
	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandleFrame(PlayerTalentFrame, true, nil, 11, -12, -32, 76)

	-- Not a "cancel button", just a duplicate Closebutton
	_G.PlayerTalentFrameCancelButton:Kill()

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

	-- only Wrath widens the points bar and moves the spent points text into it
	if E.Wrath then
		_G.PlayerTalentFrameSpentPointsText:Point('LEFT', pointsBar, 'LEFT', 12, -1)
	end

	local talentPointsText = _G.PlayerTalentFrameTalentPointsText
	talentPointsText:ClearAllPoints()
	talentPointsText:Point('RIGHT', pointsBar, 'RIGHT', E.Wrath and -12 or 60, -1)

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

local function GlyphShow(frame)
	frame:Hide()
end

local function SkinMistsGlyphFrame()
	-- Glyph Tab
	local GlyphFrame = _G.GlyphFrame
	GlyphFrame:SetTemplate('Transparent')
	GlyphFrame.sideInset:StripTextures()

	if E.private.skins.parchmentRemoverEnable then
		_G.GlyphFrameBackground:SetAlpha(0)
		GlyphFrame.levelOverlay1:SetAlpha(0)
		GlyphFrame.levelOverlay2:SetAlpha(0)
		_G.GlyphFrameSpecRing:SetAlpha(0)
	else
		_G.GlyphFrameBackground:SetInside()
		_G.GlyphFrameBackground:SetDrawLayer('ARTWORK')
		GlyphFrame.levelOverlayText1:SetDrawLayer('OVERLAY', 2)
		GlyphFrame.levelOverlayText2:SetDrawLayer('OVERLAY', 2)
	end

	GlyphFrame.levelOverlayText1:FontTemplate(nil, 18, 'SHADOW')
	GlyphFrame.levelOverlayText2:FontTemplate(nil, 18, 'SHADOW')

	S:HandleEditBox(_G.GlyphFrameSearchBox)
	_G.GlyphFrameSearchBox:Point('TOPLEFT', GlyphFrame.sideInset, 5, 54)

	S:HandleDropDownBox(GlyphFrame.FilterDropdown, 180, 'Transparent')
	GlyphFrame.FilterDropdown:Point('TOPLEFT', _G.GlyphFrameSearchBox, 'BOTTOMLEFT', 0, -3)

	for i = 1, _G.NUM_GLYPH_SLOTS do
		local frame = _G['GlyphFrameGlyph'..i]
		frame:SetTemplate('Transparent')
		frame:OffsetFrameLevel(5)
		frame:StyleButton(nil, true)
		frame:Size((i % 2 == 0) and 42 or 28) -- Major or Minor Glyphs

		frame.highlight:SetTexture(nil)
		frame.ring:Hide()

		frame.glyph:HookScript('OnShow', GlyphShow)

		frame.icon = frame:CreateTexture(nil, 'OVERLAY')
		frame.icon:SetInside()

		frame.onUpdate = CreateFrame('Frame', nil, frame)
		frame.onUpdate:SetScript('OnUpdate', GlyphFrameGlyph_OnUpdate)
		frame.onUpdate.owner = frame
	end

	hooksecurefunc('GlyphFrame_Update', GlyphFrameUpdate)

	-- Scroll Frame
	local scrollFrame = GlyphFrame.scrollFrame
	scrollFrame.ScrollChild:StripTextures()

	scrollFrame:StripTextures()
	scrollFrame:CreateBackdrop('Transparent')
	scrollFrame.backdrop:SetAllPoints(GlyphFrame.sideInset)

	S:HandleScrollBar(scrollFrame.scrollBar)
	scrollFrame.scrollBar:ClearAllPoints()
	scrollFrame.scrollBar:Point('TOPRIGHT', scrollFrame, 20, -15)
	scrollFrame.scrollBar:Point('BOTTOMRIGHT', scrollFrame, 0, 14)

	for i = 1, 2 do
		local header = _G['GlyphFrameHeader'..i]
		header:StripTextures()
		header:StyleButton()
	end

	for _, button in next, scrollFrame.buttons do
		S:HandleButton(button, nil, nil, nil, true, 'Transparent')
		button.backdrop:SetInside()

		S:HandleIcon(button.icon)
		button.icon:ClearAllPoints()
		button.icon:Point('LEFT', 2, 0)
		button.icon:Size(36)

		button.disabledBG:SetAlpha(0)
	end

	-- Clear Info
	GlyphFrame.clearInfo:CreateBackdrop()
	GlyphFrame.clearInfo.backdrop:SetAllPoints()
	GlyphFrame.clearInfo:StyleButton()
	GlyphFrame.clearInfo:Size(20)
	GlyphFrame.clearInfo:ClearAllPoints()
	GlyphFrame.clearInfo:Point('BOTTOMLEFT', GlyphFrame, 'BOTTOMLEFT', 4, -25)

	GlyphFrame.clearInfo.icon:SetTexCoords()
	GlyphFrame.clearInfo.icon:ClearAllPoints()
	GlyphFrame.clearInfo.icon:SetInside()
end

local function SkinWrathGlyphFrame()
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

function S:Blizzard_TalentUI()
	if E.Mists then
		SkinMistsTalentFrame()
	else
		SkinClassicTalentFrame()
	end
end

function S:Blizzard_GlyphUI()
	if E.Mists then
		SkinMistsGlyphFrame()
	else
		SkinWrathGlyphFrame()
	end
end
