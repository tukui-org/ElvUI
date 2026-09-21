local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetGlyphSocketInfo = GetGlyphSocketInfo
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInspectSpecialization = GetInspectSpecialization

local function FrameBackdrop_OnEnter(frame)
	frame.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

local function FrameBackdrop_OnLeave(frame)
	frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

local function TalentBorderSetShown(border, shown) -- TalentFrame_Update shows the border on the inspected unit's chosen talents
	local button = border:GetParent()
	if shown then
		button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	else
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function TalentBorderHide(border)
	TalentBorderSetShown(border, false)
end

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())

	local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

local function InspectTalentIconDesaturated(icon, desaturate)
	local parent = icon:GetParent()
	parent.ShadowedTexture:SetShown(desaturate)
end

local function HandleTabs()
	local tab = _G.InspectFrameTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', -10, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['InspectFrameTab'..index]
	end
end

local function UpdateGlyph(frame)
	local talentGroup = _G.PlayerTalentFrame and _G.PlayerTalentFrame.talentGroup;
	local _, glyphType, _, _, iconFilename = GetGlyphSocketInfo(frame:GetID(), talentGroup, true, _G.INSPECTED_UNIT)
	frame.texture:SetTexture(glyphType and iconFilename or [[Interface\Spellbook\UI-Glyph-Rune1]])
end

local function BackgroundDesaturation(bckgnd, value)
	if value and bckgnd.ignoreDesaturated then
		bckgnd:SetDesaturated(false)
	end
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame)

	-- Tabs
	HandleTabs()

	_G.InspectPaperDollFrame:StripTextures()
	_G.InspectModelFrameBackgroundOverlay:SetTexture(E.media.blankTex)
	_G.InspectModelFrameBackgroundOverlay:SetVertexColor(0, 0, 0, 0.6)
	_G.InspectModelFrameBackgroundOverlay:CreateBackdrop('Transparent')

	-- Give inspect frame model backdrop it's color back
	for _, corner in next, { 'TopLeft','TopRight','BotLeft','BotRight' } do
		local bg = _G['InspectModelFrameBackground'..corner]
		bg:SetDesaturated(false)
		bg.ignoreDesaturated = true -- so plugins can prevent this if they want

		hooksecurefunc(bg, 'SetDesaturated', BackgroundDesaturation)
	end

	_G.InspectModelFrameBorderTopLeft:Kill()
	_G.InspectModelFrameBorderTopRight:Kill()
	_G.InspectModelFrameBorderTop:Kill()
	_G.InspectModelFrameBorderLeft:Kill()
	_G.InspectModelFrameBorderRight:Kill()
	_G.InspectModelFrameBorderBottomLeft:Kill()
	_G.InspectModelFrameBorderBottomRight:Kill()
	_G.InspectModelFrameBorderBottom:Kill()

	for _, slot in next, { _G.InspectPaperDollItemsFrame:GetChildren() } do
		slot:StripTextures()
		slot:CreateBackdrop()
		slot.backdrop:SetAllPoints()
		slot:OffsetFrameLevel(2)
		slot:StyleButton()

		local icon = slot.icon
		icon:SetTexCoords()
		icon:SetInside()
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', Update_InspectPaperDollItemSlotButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)

	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- PvP Tab
	_G.InspectPVPFrame:StripTextures()

	for _, name in next, { 'RatedBG', 'Arena2v2', 'Arena3v3', 'Arena5v5' } do
		local section = _G.InspectPVPFrame[name]
		section:CreateBackdrop('Transparent')
		section.backdrop:Point('TOPLEFT', 0, -1)
		section.backdrop:Point('BOTTOMRIGHT', 0, 1)
		section:EnableMouse(true)

		section:HookScript('OnEnter', FrameBackdrop_OnEnter)
		section:HookScript('OnLeave', FrameBackdrop_OnLeave)
	end

	-- Talent Tab
	_G.InspectTalentFrame:StripTextures()

	local InspectTalents = _G.InspectTalentFrame.InspectTalents
	InspectTalents.tier1:Point('TOPLEFT', 20, -142)

	local InspectSpec = _G.InspectTalentFrame.InspectSpec
	InspectSpec:CreateBackdrop('Transparent')
	InspectSpec.backdrop:Point('TOPLEFT', 18, -16)
	InspectSpec.backdrop:Point('BOTTOMRIGHT', 20, 12)
	InspectSpec:SetHitRectInsets(18, -20, 16, 12)

	InspectSpec.ring:SetTexture()

	InspectSpec.specIcon:SetTexCoords()
	InspectSpec.specIcon.backdrop = CreateFrame('Frame', nil, InspectSpec)
	InspectSpec.specIcon.backdrop:SetTemplate()
	InspectSpec.specIcon.backdrop:SetOutside(InspectSpec.specIcon)
	InspectSpec.specIcon:SetParent(InspectSpec.specIcon.backdrop)

	InspectSpec:HookScript('OnShow', function(frame)
		frame.tooltip = nil

		local spec = _G.INSPECTED_UNIT and GetInspectSpecialization(_G.INSPECTED_UNIT)
		local data = spec and E.SpecInfoBySpecID[spec]
		if data and data.role then
			if data.role == 'DAMAGER' then
				frame.roleIcon:SetTexture(E.Media.Textures.DPS)
			elseif data.role == 'TANK' then
				frame.roleIcon:SetTexture(E.Media.Textures.Tank)
			elseif data.role == 'HEALER' then
				frame.roleIcon:SetTexture(E.Media.Textures.Healer)
			end

			frame.tooltip = data.desc

			frame.roleIcon:Size(20)
			frame.roleIcon:SetTexCoords()
			frame.roleName:SetTextColor(1, 1, 1)
			frame.specIcon:SetTexture(data.icon)
		end
	end)

	for i = 1, 6 do
		for j = 1, 3 do
			local button = _G['InspectTalentFrameTalentRow'..i..'Talent'..j]
			button:StripTextures()
			button:CreateBackdrop()
			button:Size(30)
			button:StyleButton(nil, true)

			local highlight = button:GetHighlightTexture()
			highlight:SetInside(button.backdrop)

			local icon = button.icon
			icon:SetTexCoords()
			icon:SetInside(button.backdrop)

			button.ShadowedTexture = button:CreateTexture(nil, 'OVERLAY', nil, -2)
			button.ShadowedTexture:SetAllPoints(icon)
			button.ShadowedTexture:SetColorTexture(0, 0, 0, 0.6)

			hooksecurefunc(icon, 'SetDesaturated', InspectTalentIconDesaturated)
			hooksecurefunc(button.border, 'SetShown', TalentBorderSetShown)
			hooksecurefunc(button.border, 'Hide', TalentBorderHide)
		end
	end

	_G.InspectTalentFrame:HookScript('OnShow', function(frame)
		if frame.IsSkinned then return end

		frame.IsSkinned = true

		local InspectGlyphs = frame.InspectGlyphs
		for i = 1, 6 do
			local glyph = InspectGlyphs['Glyph'..i]

			glyph:SetTemplate('Transparent')
			glyph:StyleButton(nil, true)
			glyph:OffsetFrameLevel(5)

			glyph.highlight:SetTexture(nil)
			glyph.glyph:Kill()
			glyph.ring:Kill()

			glyph:Size(i % 2 == 1 and 40 or 60)

			if not glyph.texture then
				glyph.texture = glyph:CreateTexture(nil, 'OVERLAY')
				glyph.texture:SetTexCoords()
				glyph.texture:SetInside()

				UpdateGlyph(glyph)
				hooksecurefunc(glyph, 'UpdateSlot', UpdateGlyph)
			end
		end

		InspectGlyphs.Glyph1:Point('TOPLEFT', 90, -7)
		InspectGlyphs.Glyph2:Point('TOPLEFT', 15, 0)
		InspectGlyphs.Glyph3:Point('TOPLEFT', 90, -97)
		InspectGlyphs.Glyph4:Point('TOPLEFT', 15, -90)
		InspectGlyphs.Glyph5:Point('TOPLEFT', 90, -187)
		InspectGlyphs.Glyph6:Point('TOPLEFT', 15, -180)
	end)

	-- Guild Tabard
	_G.InspectGuildFrame.bg = CreateFrame('Frame', nil, _G.InspectGuildFrame)
	_G.InspectGuildFrame.bg:SetTemplate()
	_G.InspectGuildFrame.bg:Point('TOPLEFT', 7, -63)
	_G.InspectGuildFrame.bg:Point('BOTTOMRIGHT', -9, 27)
	_G.InspectGuildFrame.bg:SetBackdropColor(0, 0, 0, 0)

	_G.InspectGuildFrameBG:SetInside(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameBG:SetParent(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameBG:SetDesaturated(true)

	_G.InspectGuildFrameBanner:SetParent(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameBannerBorder:SetParent(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameTabardLeftIcon:SetParent(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameTabardRightIcon:SetParent(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameGuildName:SetParent(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameGuildLevel:SetParent(_G.InspectGuildFrame.bg)
	_G.InspectGuildFrameGuildNumMembers:SetParent(_G.InspectGuildFrame.bg)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
