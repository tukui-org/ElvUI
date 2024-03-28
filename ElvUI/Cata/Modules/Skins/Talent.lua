local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetNumTalents = GetNumTalents

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	S:HandleFrame(_G.PlayerTalentFrame, true, nil, 0, 0, 0, 0)
	S:HandleCloseButton(_G.PlayerTalentFrameCloseButton, _G.PlayerTalentFrame.backdrop)

	_G.PlayerTalentFrameHeaderFrame:StripTextures()
	S:HandleButton(_G.PlayerTalentFrameToggleSummariesButton)

	S:HandleButton(_G.PlayerTalentFrameLearnButton)
	_G.PlayerTalentFrameLearnButton:ClearAllPoints()
	_G.PlayerTalentFrameLearnButton:Point('BOTTOMLEFT', _G.PlayerTalentFrame, 'BOTTOMLEFT', 18, 4)

	S:HandleButton(_G.PlayerTalentFrameResetButton)
	_G.PlayerTalentFrameResetButton:ClearAllPoints()
	_G.PlayerTalentFrameResetButton:Point('BOTTOMRIGHT', _G.PlayerTalentFrame, 'BOTTOMRIGHT', -38, 4)

	if _G.PlayerTalentFrameActivateButton then
		S:HandleButton(_G.PlayerTalentFrameActivateButton)
	end

	if _G.PlayerTalentFrameStatusFrame then
		_G.PlayerTalentFrameStatusFrame:StripTextures()
	end

	for i = 1, 3 do
		local panel = _G['PlayerTalentFramePanel'..i]
		local arrow = _G['PlayerTalentFramePanel'..i..'Arrow']
		local activeBonus = _G['PlayerTalentFramePanel'..i..'SummaryActiveBonus1']

		panel:StripTextures()
		panel:CreateBackdrop('Transparent')
		panel.backdrop:Point('TOPLEFT', 4, -4)
		panel.backdrop:Point('BOTTOMRIGHT', -4, 4)

		panel.InactiveShadow:Kill()

		panel.Summary:StripTextures()
		panel.Summary:CreateBackdrop()
		panel.Summary:SetFrameLevel(panel.Summary:GetFrameLevel() + 2)

		panel.Summary.Icon:SetTexCoord(unpack(E.TexCoords))

		panel.Summary.RoleIcon:Kill()
		panel.Summary.RoleIcon2:Kill()

		panel.HeaderIcon:StripTextures()
		panel.HeaderIcon:CreateBackdrop()
		panel.HeaderIcon.backdrop:SetOutside(panel.HeaderIcon.Icon)
		panel.HeaderIcon:SetFrameLevel(panel.HeaderIcon:GetFrameLevel() + 1)
		panel.HeaderIcon:Point('TOPLEFT', 4, -4)

		panel.HeaderIcon.Icon:Size(E.PixelMode and 34 or 30)
		panel.HeaderIcon.Icon:SetTexCoord(unpack(E.TexCoords))
		panel.HeaderIcon.Icon:Point('TOPLEFT', E.PixelMode and 1 or 4, -(E.PixelMode and 1 or 4))

		panel.HeaderIcon.PointsSpent:FontTemplate(nil, 13, 'OUTLINE')
		panel.HeaderIcon.PointsSpent:Point('BOTTOMRIGHT', 125, 11)

		arrow:SetFrameLevel(arrow:GetFrameLevel() + 2)

		activeBonus:StripTextures()
		activeBonus:CreateBackdrop()
		activeBonus.backdrop:SetOutside(activeBonus.Icon)
		activeBonus:SetFrameLevel(activeBonus:GetFrameLevel() + 1)

		activeBonus.Icon:SetTexCoord(unpack(E.TexCoords))

		for j = 1, 5 do
			local bonus = _G['PlayerTalentFramePanel'..i..'SummaryBonus'..j]

			bonus:StripTextures()
			bonus:CreateBackdrop()
			bonus.backdrop:SetOutside(bonus.Icon)
			bonus:SetFrameLevel(bonus:GetFrameLevel() + 1)

			bonus.Icon:SetTexCoord(unpack(E.TexCoords))
		end

		S:HandleButton(_G['PlayerTalentFramePanel'..i..'SelectTreeButton'])
	end

	for i = 1, 3 do
		for j = 1, MAX_NUM_TALENTS do
			local talent = _G['PlayerTalentFramePanel'..i..'Talent'..j]
			local icon = _G['PlayerTalentFramePanel'..i..'Talent'..j..'IconTexture']
			local rank = _G['PlayerTalentFramePanel'..i..'Talent'..j..'Rank']
			if talent then
				talent:StripTextures()
				talent:SetTemplate()
				talent:StyleButton()
	
				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer('ARTWORK')
	
				rank:FontTemplate(nil, 12, 'OUTLINE')
			end
		end
	end

	-- Pet
	_G.PlayerTalentFramePetPanel:StripTextures()
	_G.PlayerTalentFramePetPanel:CreateBackdrop('Transparent')
	_G.PlayerTalentFramePetPanel.backdrop:Point('TOPLEFT', 4, -4)
	_G.PlayerTalentFramePetPanel.backdrop:Point('BOTTOMRIGHT', -4, 4)

	_G.PlayerTalentFramePetShadowOverlay:Kill()
	_G.PlayerTalentFramePetTalents:StripTextures()

	_G.PlayerTalentFramePetModel:SetTemplate('Transparent')
	_G.PlayerTalentFramePetModel:Height(319)

	S:HandleRotateButton(_G.PlayerTalentFramePetModelRotateLeftButton)
	S:HandleRotateButton(_G.PlayerTalentFramePetModelRotateRightButton)

	_G.PlayerTalentFramePetIconBorder:Kill()
	S:HandleIcon(_G.PlayerTalentFramePetIcon)
	_G.PlayerTalentFramePetPanelHeaderIconBorder:Kill()
	S:HandleIcon(_G.PlayerTalentFramePetPanelHeaderIconIcon)

	for i = 1, GetNumTalents(1, false, true) do
		local talent = _G['PlayerTalentFramePetPanelTalent'..i]
		local icon = _G['PlayerTalentFramePetPanelTalent'..i..'IconTexture']
		local rank = _G['PlayerTalentFramePetPanelTalent'..i..'Rank']

		if talent then
			talent:StripTextures()
			talent:SetTemplate()
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')

			rank:FontTemplate(nil, 12, 'OUTLINE')
		end
	end

	-- Tabs
	for i = 1, 3 do
		S:HandleTab(_G['PlayerTalentFrameTab'..i])
	end

	hooksecurefunc('PlayerTalentFrame_UpdateTabs', function()
		_G.PlayerTalentFrameTab1:ClearAllPoints()
		_G.PlayerTalentFrameTab1:Point('TOPLEFT', _G.PlayerTalentFrame, 'BOTTOMLEFT', -10, 0)
		_G.PlayerTalentFrameTab2:Point('TOPLEFT', _G.PlayerTalentFrameTab1, 'TOPRIGHT', -19, 0)
		_G.PlayerTalentFrameTab3:Point('TOPLEFT', _G.PlayerTalentFrameTab2, 'TOPRIGHT', -19, 0)
	end)
end

function S:Blizzard_GlyphUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	-- Glyph Tab
	GlyphFrame:StripTextures()
	GlyphFrame:CreateBackdrop('Transparent')

	GlyphFrame.sideInset:StripTextures()

	S:HandleEditBox(GlyphFrameSearchBox)
	GlyphFrameSearchBox:Point('TOPLEFT', GlyphFrameSideInset, 5, 54)

	S:HandleDropDownBox(GlyphFrameFilterDropDown, 210)
	GlyphFrameFilterDropDown:Point('TOPLEFT', GlyphFrameSearchBox, 'BOTTOMLEFT', -22, -3)

	for i = 1, NUM_GLYPH_SLOTS do
		local frame = _G['GlyphFrameGlyph'..i]

		frame:SetTemplate('Default', true)
		frame:SetFrameLevel(frame:GetFrameLevel() + 5)
		frame:StyleButton(nil, true)

		if i == 1 or i == 4 or i == 6 then -- Major Glyphs
			frame:Size(52)
		elseif i == 2 or i == 3 or i == 5 then -- Minor Glyphs
			frame:Size(36)
		else -- Prime Glyphs
			frame:Size(68)
		end

		frame.highlight:SetTexture(nil)
		frame.ring:Hide()
		hooksecurefunc(frame.glyph, 'Show', function(self) self:Hide() end)

		frame.icon = frame:CreateTexture(nil, 'OVERLAY')
		frame.icon:SetInside()
		frame.icon:SetTexCoord(unpack(E.TexCoords))

		frame.onUpdate = CreateFrame('Frame', nil, frame)
		frame.onUpdate:SetScript('OnUpdate', function()
			local alpha = frame.highlight:GetAlpha()
			local glyphIcon = strfind(frame.icon:GetTexture(), 'Interface\\Spellbook\\UI%-Glyph%-Rune')

			if alpha == 0 then
				frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
				frame:SetAlpha(1)

				if glyphIcon then
					frame.icon:SetVertexColor(1, 1, 1, 1)
				end
			else
				frame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
				frame:SetAlpha(alpha)

				if glyphIcon then
					frame.icon:SetVertexColor(unpack(E.media.rgbvaluecolor))
					frame.icon:SetAlpha(alpha)
				end
			end
		end)
	end

	hooksecurefunc('GlyphFrame_Update', function(self)
		local isActiveTalentGroup = PlayerTalentFrame and not PlayerTalentFrame.pet and PlayerTalentFrame.talentGroup == GetActiveTalentGroup(PlayerTalentFrame.pet)

		GlyphFrame.levelOverlayText1:SetTextColor(1, 1, 1)
		GlyphFrame.levelOverlayText2:SetTextColor(1, 1, 1)

		for i = 1, NUM_GLYPH_SLOTS do
			local glyph = _G['GlyphFrameGlyph'..i]
			local _, _, _, _, iconFilename = GetGlyphSocketInfo(i, PlayerTalentFrame.talentGroup)

			if iconFilename then
				glyph.icon:SetTexture(iconFilename)
			else
				glyph.icon:SetTexture('Interface\\Spellbook\\UI-Glyph-Rune-'..i)
			end

			GlyphFrameGlyph_UpdateSlot(glyph)
			SetDesaturation(glyph.icon, not isActiveTalentGroup)
		end
	end)

	-- Scroll Frame
	GlyphFrameScrollFrameScrollChild:StripTextures()

	GlyphFrameScrollFrame:StripTextures()
	GlyphFrameScrollFrame:CreateBackdrop('Transparent')
	GlyphFrameScrollFrame.backdrop:Point('TOPLEFT', -1, 1)
	GlyphFrameScrollFrame.backdrop:Point('BOTTOMRIGHT', -4, -2)

	S:HandleScrollBar(GlyphFrameScrollFrameScrollBar)
	GlyphFrameScrollFrameScrollBar:ClearAllPoints()
	GlyphFrameScrollFrameScrollBar:Point('TOPRIGHT', GlyphFrameScrollFrame, 20, -15)
	GlyphFrameScrollFrameScrollBar:Point('BOTTOMRIGHT', GlyphFrameScrollFrame, 0, 14)

	for i = 1, 3 do
		local header = _G['GlyphFrameHeader'..i]

		header:StripTextures()
		header:StyleButton()
	end

	for i = 1, 10 do
		local button = _G['GlyphFrameScrollFrameButton'..i]
		local icon = _G['GlyphFrameScrollFrameButton'..i..'Icon']

		if button and not button.isSkinned then
			S:HandleButton(button)
			S:HandleIcon(icon)
			button.isSkinned = true
		end
	end

	-- Clear Info
	GlyphFrame.clearInfo:CreateBackdrop()
	GlyphFrame.clearInfo.backdrop:SetAllPoints()
	GlyphFrame.clearInfo:StyleButton()
	GlyphFrame.clearInfo:Size(28)
	GlyphFrame.clearInfo:Point('BOTTOMLEFT', GlyphFrame, 'BOTTOMRIGHT', 8, -1)

	GlyphFrame.clearInfo.icon:SetTexCoord(unpack(E.TexCoords))
	GlyphFrame.clearInfo.icon:ClearAllPoints()
	GlyphFrame.clearInfo.icon:SetInside()
end

S:AddCallbackForAddon('Blizzard_TalentUI')
S:AddCallbackForAddon('Blizzard_GlyphUI')