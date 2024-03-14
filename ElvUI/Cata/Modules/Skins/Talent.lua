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

	_G.GlyphFrame:StripTextures()

	_G.GlyphFrameBackground:Size(334, 385)
	_G.GlyphFrameBackground:Point('TOPLEFT', 15, -47)

	_G.GlyphFrameBackground:SetTexture([[Interface\Spellbook\UI-GlyphFrame]])
	_G.GlyphFrameGlow:SetTexture([[Interface\Spellbook\UI-GlyphFrame-Glow]])
	_G.GlyphFrameGlow:SetAllPoints(_G.GlyphFrameBackground)

	_G.GlyphFrameBackground:SetTexCoord(0.041015625, 0.65625, 0.140625, 0.8046875)
	_G.GlyphFrameGlow:SetTexCoord(0.05859375, 0.673828125, 0.06640625, 0.73046875)

	-- Otherwise TalenFrame texts/elements will overlap with Glyph texts/elements
	_G.GlyphFrame:HookScript('OnShow', function()
		_G.PlayerTalentFrameTitleText:Hide()
		_G.PlayerTalentFramePointsBar:Hide()
		_G.PlayerTalentFrameScrollFrame:Hide()
		_G.PlayerTalentFrameStatusFrame:Hide()
	end)

	_G.GlyphFrame:HookScript('OnHide', function()
		_G.PlayerTalentFrameTitleText:Show()
		_G.PlayerTalentFramePointsBar:Show()
		_G.PlayerTalentFrameScrollFrame:Show()
	end)
end

S:AddCallbackForAddon('Blizzard_TalentUI')
S:AddCallbackForAddon('Blizzard_GlyphUI')
