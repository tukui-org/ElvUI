local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local strfind = strfind
local pairs, unpack = pairs, unpack
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local GetNumSpecializations = GetNumSpecializations
local GetSpecializationSpells = GetSpecializationSpells
local C_SpecializationInfo_GetSpecialization = C_SpecializationInfo.GetSpecialization
local C_SpecializationInfo_GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo

local GetSpellTexture = GetSpellTexture
local UnitSex = UnitSex

local function clearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 0)
end

local function PositionTabs()
	_G.PlayerTalentFrameTab1:ClearAllPoints()
	_G.PlayerTalentFrameTab1:Point('TOPLEFT', _G.PlayerTalentFrame, 'BOTTOMLEFT', -10, 0)
	_G.PlayerTalentFrameTab2:Point('TOPLEFT', _G.PlayerTalentFrameTab1, 'TOPRIGHT', -19, 0)
	_G.PlayerTalentFrameTab3:Point('TOPLEFT', _G.PlayerTalentFrameTab2, 'TOPRIGHT', -19, 0)
	_G.PlayerTalentFrameTab4:Point('TOPLEFT', _G.PlayerTalentFrameTab3, 'TOPRIGHT', -19, 0)
end

local function GlyphFrame_Update()
	local glyphFrame = _G.GlyphFrame
	if glyphFrame then
		glyphFrame.levelOverlayText1:SetTextColor(1, 1, 1)
		glyphFrame.levelOverlayText2:SetTextColor(1, 1, 1)
	end

	local talentFrame = _G.PlayerTalentFrame
	local talentGroup = talentFrame and talentFrame.talentGroup
	if talentGroup then
		local l, r, t, b = unpack(E.TexCoords)
		for i = 1, _G.NUM_GLYPH_SLOTS do
			local glyph = _G['GlyphFrameGlyph'..i]
			if glyph and glyph.icon then
				local _, _, _, _, iconFilename = _G.GetGlyphSocketInfo(i, talentGroup)
				if iconFilename then
					glyph.icon:SetTexture(iconFilename)
					glyph.icon:SetTexCoord(l, r, t, b)
				else
					glyph.icon:SetTexture([[Interface\Spellbook\UI-Glyph-Rune-]]..i)
					glyph.icon:SetTexCoord(0, 1, 0, 1)
				end

				_G.GlyphFrameGlyph_UpdateSlot(glyph)
			end
		end
	end
end

local function GlyphFrameGlyph_OnUpdate(updater)
	local frame = updater.owner
	if not frame then return end

	local glyphTexture = frame.icon and frame.icon:GetTexture()
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

local function TalentFrame_Update()
	for i = 1, 7 do -- MAX_TALENT_TIERS currently 7
		for j = 1, 3 do -- NUM_TALENT_COLUMNS currently 3
			local button = _G['PlayerTalentFrameTalentsTalentRow'..i..'Talent'..j]
			if button and button.bg then
				if button.knownSelection then
					button.icon:SetDesaturated(false)

					if button.knownSelection:IsShown() then
						button.bg.SelectedTexture:Show()
						button.ShadowedTexture:Hide()
					else
						button.bg.SelectedTexture:Hide()
						button.ShadowedTexture:Show()
					end
				end

				if button.learnSelection then
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
	end
end

local function PlayerTalentFrame_UpdateSpecFrame(s, spec)
	local playerSpec = C_SpecializationInfo_GetSpecialization(nil, s.isPet, _G.PlayerSpecTab2:GetChecked() and 2 or 1)
	local shownSpec = spec or playerSpec or 1

	local id, _, _, icon = C_SpecializationInfo_GetSpecializationInfo(shownSpec, nil, s.isPet, nil, s.isPet and UnitSex('pet') or E.mygender)
	if not id then return end

	local scrollBar = s.spellsScroll.ScrollBar
	if scrollBar and not scrollBar.backdrop then
		S:HandleScrollBar(scrollBar)
	end

	local scrollChild = s.spellsScroll.child
	scrollChild.specIcon:SetTexture(icon)
	scrollChild:SetScale(0.99) -- the scrollbar showed on simpy's when it shouldn't, this fixes it by reducing the scale by .01 lol

	local numSpecs = GetNumSpecializations(nil, s.isPet)
	for i = 1, numSpecs do
		local button = s['specButton'..i]
		if button then
			button.SelectedTexture:SetShown(button.selected)

			if button.backdrop then
				button.SelectedTexture:SetInside(button.backdrop)
			end
		end
	end

	local index, bonuses = 1
	local bonusesIncrement = 1
	if s.isPet then
		bonuses = { GetSpecializationSpells(shownSpec, nil, s.isPet, true) }
		bonusesIncrement = 2
	end

	if bonuses then
		for i = 1, #bonuses, bonusesIncrement do
			local frame = scrollChild['abilityButton'..index]
			if frame then
				local _, spellTex = GetSpellTexture(bonuses[i])
				if spellTex then
					frame.icon:SetTexture(spellTex)
				end

				if frame.subText then
					frame.subText:SetTextColor(.6, .6, .6)
				end

				if not frame.backdrop then
					frame.ring:Hide()
					frame.icon:SetTexCoord(unpack(E.TexCoords))
					frame.icon:SetInside(frame, 8, 8)

					frame:CreateBackdrop()
					frame.backdrop:SetOutside(frame.icon)
				end
			end

			index = index + 1
		end
	end

	-- Hide the default flash anim
	s.learnButton.Flash:Hide()
	s.learnButton.FlashAnim:Stop()
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

local function Transition_OnShow(frame)
	local parent = frame:GetParent()
	if not parent.transition:IsPlaying() then
		for _, child in pairs(parent.transition.color.children) do
			child:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		parent.transition:Play()
	end
end

local function Transition_OnHide(frame)
	local parent = frame:GetParent()
	if parent.transition:IsPlaying() then
		parent.transition:Stop()

		for _, child in pairs(parent.transition.color.children) do
			child:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end
end

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandlePortraitFrame(PlayerTalentFrame)

	_G.PlayerTalentFrameTalents:StripTextures()

	local disableTutorialButtons = E.global.general.disableTutorialButtons
	if disableTutorialButtons then
		_G.PlayerTalentFrameTalentsTutorialButton:Kill()
	end

	local buttons = {
		_G.PlayerTalentFrameSpecializationLearnButton,
		_G.PlayerTalentFrameTalentsLearnButton,
		_G.PlayerTalentFramePetSpecializationLearnButton
	}

	S:HandleButton(_G.PlayerTalentFrameActivateButton)

	for _, button in pairs(buttons) do
		S:HandleButton(button)
	end

	for i = 1, 4 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	-- Reposition Tabs
	PositionTabs()
	hooksecurefunc('PlayerTalentFrame_UpdateTabs', PositionTabs)

	for _, Frame in pairs({ _G.PlayerTalentFrameSpecialization, _G.PlayerTalentFramePetSpecialization }) do
		Frame:StripTextures()

		if disableTutorialButtons then
			Frame.MainHelpButton:Kill()
		end

		for _, Child in pairs({Frame:GetChildren()}) do
			if Child:IsObjectType('Frame') and not Child:GetName() then
				Child:StripTextures()
			end
		end

		for i = 1, 4 do
			local Button = Frame['specButton'..i]
			local _, _, _, icon = C_SpecializationInfo_GetSpecializationInfo(i, false, Frame.isPet)

			_G['PlayerTalentFrameSpecializationSpecButton'..i..'Glow']:Kill()

			Button:CreateBackdrop()
			if Button.backdrop then
				Button.backdrop:Point('TOPLEFT', 8, 2)
				Button.backdrop:Point('BOTTOMRIGHT', 10, -2)
			end

			Button.specIcon:Size(50, 50)
			Button.specIcon:Point('LEFT', Button, 'LEFT', 15, 0)
			Button.specIcon:SetDrawLayer('ARTWORK', 2)
			Button.roleIcon:SetDrawLayer('ARTWORK', 2)

			Button.bg:SetAlpha(0)
			Button.ring:SetAlpha(0)
			Button.learnedTex:SetAlpha(0)
			Button.selectedTex:SetAlpha(0)
			Button.specIcon:SetTexture(icon)
			S:HandleIcon(Button.specIcon, true, nil, nil, nil, nil, nil, nil, Button:GetFrameLevel() + 1)
			if Button.specIcon.backdrop then
				Button.specIcon.backdrop:SetBackdropColor(0, 0, 0, 0)
				Button.specIcon.backdrop.callbackBackdropColor = clearBackdrop
			end
			Button:SetHighlightTexture(E.ClearTexture)

			Button.SelectedTexture = Button:CreateTexture(nil, 'ARTWORK')
			Button.SelectedTexture:SetColorTexture(0, 1, 0, 0.2)
		end

		Frame.spellsScroll.child.gradient:Kill()
		Frame.spellsScroll.child.scrollwork_topleft:SetAlpha(0)
		Frame.spellsScroll.child.scrollwork_topright:SetAlpha(0)
		Frame.spellsScroll.child.scrollwork_bottomleft:SetAlpha(0)
		Frame.spellsScroll.child.scrollwork_bottomright:SetAlpha(0)
		Frame.spellsScroll.child.ring:SetAlpha(0)
		Frame.spellsScroll.child.Seperator:SetAlpha(0)

		S:HandleIcon(Frame.spellsScroll.child.specIcon, true)
	end

	for i = 1, 7 do -- MAX_TALENT_TIERS currently 7
		local row = _G['PlayerTalentFrameTalentsTalentRow'..i]

		if row then
			row:StripTextures()

			row.TopLine:Point('TOP', 0, 4)
			row.BottomLine:Point('BOTTOM', 0, -4)

			row.transition = _G.CreateAnimationGroup(row)
			row.transition:SetLooping(true)

			row.transition.color = row.transition:CreateAnimation('Color')
			row.transition.color:SetDuration(0.7)
			row.transition.color:SetColorType('border')
			row.transition.color:SetChange(unpack(E.media.rgbvaluecolor))
			row.transition.color:SetScript('OnFinished', Transition_OnFinished)

			-- unused?
			-- row.GlowFrame:StripTextures()
			-- row.GlowFrame:HookScript('OnShow', Transition_OnShow)
			-- row.GlowFrame:HookScript('OnHide', Transition_OnHide)
		end

		for j = 1, 3 do -- NUM_TALENT_COLUMNS currently 3
			local button = _G['PlayerTalentFrameTalentsTalentRow'..i..'Talent'..j]
			if button then
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

				row.transition.color:AddChild(button.bg)

				-- button.GlowFrame:Kill()

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
			tab:GetRegions():Hide()
			tab:SetTemplate()
			tab:StyleButton(nil, true)

			local normal = tab:GetNormalTexture()
			normal:SetInside()
			normal:SetTexCoord(unpack(E.TexCoords))
		end
	end

	hooksecurefunc('TalentFrame_Update', TalentFrame_Update)
	hooksecurefunc('PlayerTalentFrame_UpdateSpecFrame', PlayerTalentFrame_UpdateSpecFrame)
end

function S:Blizzard_GlyphUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

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
	_G.GlyphFrameSearchBox:Point('TOPLEFT', _G.GlyphFrameSideInset, 5, 54)

	S:HandleDropDownBox(_G.GlyphFrame.FilterDropdown, 180, 'Transparent')
	_G.GlyphFrame.FilterDropdown:Point('TOPLEFT', _G.GlyphFrameSearchBox, 'BOTTOMLEFT', 0, -3)

	for i = 1, _G.NUM_GLYPH_SLOTS do
		local frame = _G['GlyphFrameGlyph'..i]
		frame:SetTemplate('Transparent')
		frame:OffsetFrameLevel(5)
		frame:StyleButton(nil, true)

		if i == 2 or i == 4 or i == 6 then -- Major Glyphs
			frame:Size(42)
		elseif i == 1 or i == 3 or i == 5 then -- Minor Glyphs
			frame:Size(28)
		else -- Prime Glyphs
			frame:Size(62)
		end

		frame.highlight:SetTexture(nil)
		frame.ring:Hide()

		hooksecurefunc(frame.glyph, 'Show', frame.glyph.Hide)

		if not frame.icon then
			frame.icon = frame:CreateTexture(nil, 'OVERLAY')
			frame.icon:SetInside()
		end

		if not frame.onUpdate then
			frame.onUpdate = CreateFrame('Frame', nil, frame)
			frame.onUpdate:SetScript('OnUpdate', GlyphFrameGlyph_OnUpdate)
			frame.onUpdate.owner = frame
		end
	end

	hooksecurefunc('GlyphFrame_Update', GlyphFrame_Update)

	-- Scroll Frame
	_G.GlyphFrameScrollFrameScrollChild:StripTextures()

	_G.GlyphFrameScrollFrame:StripTextures()
	_G.GlyphFrameScrollFrame:CreateBackdrop('Transparent')
	_G.GlyphFrameScrollFrame.backdrop:SetAllPoints(_G.GlyphFrameSideInset)

	S:HandleScrollBar(_G.GlyphFrameScrollFrameScrollBar)
	_G.GlyphFrameScrollFrameScrollBar:ClearAllPoints()
	_G.GlyphFrameScrollFrameScrollBar:Point('TOPRIGHT', _G.GlyphFrameScrollFrame, 20, -15)
	_G.GlyphFrameScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.GlyphFrameScrollFrame, 0, 14)

	for i = 1, 3 do
		local header = _G['GlyphFrameHeader'..i]
		if header then
			header:StripTextures()
			header:StyleButton()
		end
	end

	for i = 1, 10 do
		local button = _G['GlyphFrameScrollFrameButton'..i]
		if button and not button.IsSkinned then
			S:HandleButton(button, nil, nil, nil, true, 'Transparent')
			button.backdrop:SetInside()

			local icon = _G['GlyphFrameScrollFrameButton'..i..'Icon']
			if icon then
				S:HandleIcon(icon)
				icon:ClearAllPoints()
				icon:Point('LEFT', 2, 0)
				icon:Size(36)
			end

			local disabledBG = button.disabledBG
			if disabledBG then
				disabledBG:SetAlpha(0)
			end

			button.IsSkinned = true
		end
	end

	-- Clear Info
	GlyphFrame.clearInfo:CreateBackdrop()
	GlyphFrame.clearInfo.backdrop:SetAllPoints()
	GlyphFrame.clearInfo:StyleButton()
	GlyphFrame.clearInfo:Size(20)
	GlyphFrame.clearInfo:ClearAllPoints()
	GlyphFrame.clearInfo:Point('BOTTOMLEFT', GlyphFrame, 'BOTTOMLEFT', 4, -25)

	GlyphFrame.clearInfo.icon:SetTexCoord(unpack(E.TexCoords))
	GlyphFrame.clearInfo.icon:ClearAllPoints()
	GlyphFrame.clearInfo.icon:SetInside()
end

S:AddCallbackForAddon('Blizzard_TalentUI')
S:AddCallbackForAddon('Blizzard_GlyphUI')
