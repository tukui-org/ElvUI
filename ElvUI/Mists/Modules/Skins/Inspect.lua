local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

local GetGlyphSocketInfo = GetGlyphSocketInfo
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInspectSpecialization = GetInspectSpecialization

local function FrameBackdrop_OnEnter(frame)
	if not frame.backdrop then return end

	frame.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

local function FrameBackdrop_OnLeave(frame)
	if not frame.backdrop then return end

	frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())

	local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

local function InspectTalentIconDesaturated(icon, desaturate)
	local parent = icon:GetParent()
	if parent.ShadowedTexture then
		parent.ShadowedTexture:SetShown(desaturate)
	end
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
	if frame.texture then
		frame.texture:SetTexture(glyphType and iconFilename or [[Interface\Spellbook\UI-Glyph-Rune1]])
	end
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame)
	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	-- Tabs
	HandleTabs()

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	_G.InspectPaperDollFrame:StripTextures()

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

		local name = slot:GetName()
		local icon = _G[name..'IconTexture']
		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside()
		end

		local cooldown = _G[name..'Cooldown']
		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', Update_InspectPaperDollItemSlotButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	_G.InspectModelFrameRotateLeftButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateLeftButton:GetNormalTexture():SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
	_G.InspectModelFrameRotateLeftButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateLeftButton:GetPushedTexture():SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)

	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)
	_G.InspectModelFrameRotateRightButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateRightButton:GetNormalTexture():SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
	_G.InspectModelFrameRotateRightButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.InspectModelFrameRotateRightButton:GetPushedTexture():SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)

	-- PvP Tab
	_G.InspectPVPFrame:StripTextures()

	for _, name in next, { 'RatedBG', 'Arena2v2', 'Arena3v3', 'Arena5v5' } do
		local section = _G.InspectPVPFrame[name]
		if section then
			section:CreateBackdrop('Transparent')
			section.backdrop:Point('TOPLEFT', 0, -1)
			section.backdrop:Point('BOTTOMRIGHT', 0, 1)
			section:EnableMouse(true)

			section:HookScript('OnEnter', FrameBackdrop_OnEnter)
			section:HookScript('OnLeave', FrameBackdrop_OnLeave)
		end
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

	InspectSpec.ring:SetTexture('')

	InspectSpec.specIcon:SetTexCoord(unpack(E.TexCoords))
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
			frame.roleIcon:SetTexCoord(unpack(E.TexCoords))
			frame.roleName:SetTextColor(1, 1, 1)
			frame.specIcon:SetTexture(data.icon)
		end
	end)

	for i = 1, 6 do
		for j = 1, 3 do
			local button = _G['InspectTalentFrameTalentRow'..i..'Talent'..j]
			if button then
				button:StripTextures()
				button:CreateBackdrop()
				button:Size(30)
				button:StyleButton(nil, true)
				button:GetHighlightTexture():SetInside(button.backdrop)

				if button.icon then
					button.icon:SetTexCoord(unpack(E.TexCoords))
					button.icon:SetInside(button.backdrop)

					button.ShadowedTexture = button:CreateTexture(nil, 'OVERLAY', nil, -2)
					button.ShadowedTexture:SetAllPoints(button.icon)
					button.ShadowedTexture:SetColorTexture(0, 0, 0, 0.6)

					hooksecurefunc(button.icon, 'SetDesaturated', InspectTalentIconDesaturated)
				end

				if button.border then
					hooksecurefunc(button.border, 'Show', FrameBackdrop_OnEnter)
					hooksecurefunc(button.border, 'Hide', FrameBackdrop_OnLeave)
				end
			end
		end
	end

	_G.InspectTalentFrame:HookScript('OnShow', function(frame)
		if frame.isSkinned then return end

		frame.isSkinned = true

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
				glyph.texture:SetTexCoord(unpack(E.TexCoords))
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
