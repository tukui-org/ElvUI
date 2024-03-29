local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local tinsert = tinsert
local strfind = strfind
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetNumTalents = GetNumTalents
local HasPetUI = HasPetUI

local function GlyphFrame_Update()
	local glyphFrame = _G.GlyphFrame
	if glyphFrame then
		glyphFrame.levelOverlayText1:SetTextColor(1, 1, 1)
		glyphFrame.levelOverlayText2:SetTextColor(1, 1, 1)
	end

	local talentFrame = _G.PlayerTalentFrame
	local talentGroup = talentFrame and talentFrame.talentGroup
	if talentGroup then
		for i = 1, _G.NUM_GLYPH_SLOTS do
			local glyph = _G['GlyphFrameGlyph'..i]
			if glyph and glyph.icon then
				local _, _, _, _, iconFilename = _G.GetGlyphSocketInfo(i, talentGroup)
				if iconFilename then
					glyph.icon:SetTexture(iconFilename)
				else
					glyph.icon:SetTexture([[Interface\Spellbook\UI-Glyph-Rune-]]..i)
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

local TalentTabs = {}
local function HandleTabs()
	local lastTab
	for index, tab in next, TalentTabs do
		if index ~= 2 or HasPetUI() then
			tab:ClearAllPoints()

			if index == 1 then
				tab:Point('TOPLEFT', _G.PlayerTalentFrame, 'BOTTOMLEFT', -10, 0)
			else
				tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			end

			lastTab = tab
		end
	end
end

function S:Blizzard_TalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	S:HandleFrame(PlayerTalentFrame, true, nil, 0, 0, 0, 0)
	S:HandleCloseButton(_G.PlayerTalentFrameCloseButton, PlayerTalentFrame.backdrop)

	_G.PlayerTalentFrameHeaderFrame:StripTextures()
	S:HandleButton(_G.PlayerTalentFrameToggleSummariesButton)

	S:HandleButton(_G.PlayerTalentFrameLearnButton)
	_G.PlayerTalentFrameLearnButton:ClearAllPoints()
	_G.PlayerTalentFrameLearnButton:Point('BOTTOMLEFT', PlayerTalentFrame, 'BOTTOMLEFT', 18, 4)

	S:HandleButton(_G.PlayerTalentFrameResetButton)
	_G.PlayerTalentFrameResetButton:ClearAllPoints()
	_G.PlayerTalentFrameResetButton:Point('BOTTOMRIGHT', PlayerTalentFrame, 'BOTTOMRIGHT', -38, 4)

	if _G.PlayerTalentFrameActivateButton then
		S:HandleButton(_G.PlayerTalentFrameActivateButton)
	end

	if _G.PlayerTalentFrameStatusFrame then
		_G.PlayerTalentFrameStatusFrame:StripTextures()
	end

	for i = 1, 3 do
		local panelName = 'PlayerTalentFramePanel'..i
		local panel = _G[panelName]

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

		local arrow = _G[panelName..'Arrow']
		if arrow then
			arrow:SetFrameLevel(arrow:GetFrameLevel() + 2)
		end

		local activeBonus = _G[panelName..'SummaryActiveBonus1']
		if activeBonus then
			activeBonus:StripTextures()
			activeBonus:CreateBackdrop()
			activeBonus.backdrop:SetOutside(activeBonus.Icon)
			activeBonus:SetFrameLevel(activeBonus:GetFrameLevel() + 1)
			activeBonus.Icon:SetTexCoord(unpack(E.TexCoords))
		end

		for j = 1, 5 do
			local bonus = _G[panelName..'SummaryBonus'..j]
			if bonus then
				bonus:StripTextures()
				bonus:CreateBackdrop()
				bonus.backdrop:SetOutside(bonus.Icon)
				bonus:SetFrameLevel(bonus:GetFrameLevel() + 1)

				bonus.Icon:SetTexCoord(unpack(E.TexCoords))
			end
		end

		for j = 1, _G.MAX_NUM_BRANCH_TEXTURES do
			local branch = _G[panelName..'Branch'..j]
			if branch then
				branch:SetTexture(136962) -- Interface\\TalentFrame\\UI-TalentBranches
			end
		end

		for j = 1, _G.MAX_NUM_TALENTS do
			local talent = _G[panelName..'Talent'..j]
			if talent then
				talent:StripTextures()
				talent:SetTemplate()
				talent:StyleButton()

				local icon = _G[panelName..'Talent'..j..'IconTexture']
				if icon then
					icon:SetInside()
					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetDrawLayer('ARTWORK')
				end

				local rank = _G[panelName..'Talent'..j..'Rank']
				if rank then
					rank:FontTemplate(nil, 12, 'OUTLINE')
				end
			end
		end

		S:HandleButton(_G[panelName..'SelectTreeButton'])
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
		if talent then
			talent:StripTextures()
			talent:SetTemplate()
			talent:StyleButton()

			local icon = _G['PlayerTalentFramePetPanelTalent'..i..'IconTexture']
			if icon then
				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer('ARTWORK')
			end

			local rank = _G['PlayerTalentFramePetPanelTalent'..i..'Rank']
			if rank then
				rank:FontTemplate(nil, 12, 'OUTLINE')
			end
		end
	end

	-- Tabs
	for i = 1, 3 do
		local tab = _G['PlayerTalentFrameTab'..i]
		tinsert(TalentTabs, tab)
		S:HandleTab(tab)
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

	hooksecurefunc('PlayerTalentFrame_UpdateTabs', HandleTabs)
end

function S:Blizzard_GlyphUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	-- Glyph Tab
	local GlyphFrame = _G.GlyphFrame
	GlyphFrame:StripTextures()
	GlyphFrame:SetTemplate('Transparent')

	GlyphFrame.sideInset:StripTextures()

	S:HandleEditBox(_G.GlyphFrameSearchBox)
	_G.GlyphFrameSearchBox:Point('TOPLEFT', _G.GlyphFrameSideInset, 5, 54)

	S:HandleDropDownBox(_G.GlyphFrameFilterDropDown, 210)
	_G.GlyphFrameFilterDropDown:Point('TOPLEFT', _G.GlyphFrameSearchBox, 'BOTTOMLEFT', -22, -3)

	for i = 1, _G.NUM_GLYPH_SLOTS do
		local frame = _G['GlyphFrameGlyph'..i]

		frame:SetTemplate('Default', true)
		frame:SetFrameLevel(frame:GetFrameLevel() + 5)
		frame:StyleButton(nil, true)

		if i == 1 or i == 4 or i == 6 then -- Major Glyphs
			frame:Size(42)
		elseif i == 2 or i == 3 or i == 5 then -- Minor Glyphs
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
			frame.icon:SetTexCoord(unpack(E.TexCoords))
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
	_G.GlyphFrameScrollFrame.backdrop:Point('TOPLEFT', -1, 1)
	_G.GlyphFrameScrollFrame.backdrop:Point('BOTTOMRIGHT', -4, -2)

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
		if button and not button.isSkinned then
			S:HandleButton(button)

			local icon = _G['GlyphFrameScrollFrameButton'..i..'Icon']
			if icon then
				S:HandleIcon(icon)
			end

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
