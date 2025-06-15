local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local GetGlyphSocketInfo = GetGlyphSocketInfo
local GetInspectSpecialization = GetInspectSpecialization
local GetInventoryItemQuality = GetInventoryItemQuality
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetSpecializationRoleByID = GetSpecializationRoleByID
local InspectGlyphFrameGlyph_UpdateGlyphs = InspectGlyphFrameGlyph_UpdateGlyphs

local INSPECTED_UNIT = INSPECTED_UNIT

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())

	local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame)
	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	-- Reposition Tabs
	_G.InspectFrameTab1:ClearAllPoints()
	_G.InspectFrameTab1:Point('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', -10, 0)
	_G.InspectFrameTab2:Point('TOPLEFT', _G.InspectFrameTab1, 'TOPRIGHT', -19, 0)
	_G.InspectFrameTab3:Point('TOPLEFT', _G.InspectFrameTab2, 'TOPRIGHT', -19, 0)
	_G.InspectFrameTab4:Point('TOPLEFT', _G.InspectFrameTab3, 'TOPRIGHT', -19, 0)

	_G.InspectPaperDollFrame:StripTextures()

	for _, slot in next, { _G.InspectPaperDollItemsFrame:GetChildren() } do
		local icon = _G[slot:GetName()..'IconTexture']
		local cooldown = _G[slot:GetName()..'Cooldown']

		slot:StripTextures()
		slot:CreateBackdrop()
		slot.backdrop:SetAllPoints()
		slot:OffsetFrameLevel(2)
		slot:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

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
	InspectPVPFrame:StripTextures()

	for _, Section in pairs({'RatedBG', 'Arena2v2', 'Arena3v3', 'Arena5v5'}) do
		local Frame = InspectPVPFrame[Section]
		Frame:CreateBackdrop('Transparent')
		Frame.backdrop:Point('TOPLEFT', 0, -1)
		Frame.backdrop:Point('BOTTOMRIGHT', 0, 1)
		Frame:EnableMouse(true)

		Frame:HookScript('OnEnter', function(self)
			self.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end)
		Frame:HookScript('OnLeave', function(self)
			self.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
	end

	-- Talent Tab
	_G.InspectTalentFrame:StripTextures()

	Specialization:CreateBackdrop('Transparent')
	Specialization.backdrop:Point('TOPLEFT', 18, -16)
	Specialization.backdrop:Point('BOTTOMRIGHT', 20, 12)
	Specialization:SetHitRectInsets(18, -20, 16, 12)

	Specialization.ring:SetTexture('')

	Specialization.specIcon:SetTexCoord(unpack(E.TexCoords))
	Specialization.specIcon.backdrop = CreateFrame('Frame', nil, Specialization)
	Specialization.specIcon.backdrop:SetTemplate()
	Specialization.specIcon.backdrop:SetOutside(Specialization.specIcon)
	Specialization.specIcon:SetParent(Specialization.specIcon.backdrop)

	Specialization:HookScript('OnShow', function(self)
		local spec = nil
		self.tooltip = nil

		if INSPECTED_UNIT ~= nil then
			spec = GetInspectSpecialization(INSPECTED_UNIT)
		end

		local _, role, description, icon
		if spec ~= nil and spec > 0 then
			role = GetSpecializationRoleByID(spec)

			if role ~= nil then
				_, _, description, icon = GetSpecializationInfoByID(spec)

				self.specIcon:SetTexture(icon)
				self.tooltip = description

				if role == 'DAMAGER' then
					self.roleIcon:SetTexture(E.Media.Textures.DPS)
					self.roleIcon:Size(19)
				elseif role == 'TANK' then
					self.roleIcon:SetTexture(E.Media.Textures.Tank)
					self.roleIcon:Size(20)
				elseif role == 'HEALER' then
					self.roleIcon:SetTexture(E.Media.Textures.Healer)
					self.roleIcon:Size(20)
				end
				self.roleIcon:SetTexCoord(unpack(E.TexCoords))

				self.roleName:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, 6 do
		for j = 1, 3 do
			local button = _G['TalentsTalentRow'..i..'Talent'..j]

			if button then
				button:StripTextures()
				button:CreateBackdrop()
				button:Size(30)
				button:StyleButton(nil, true)
				button:GetHighlightTexture():SetInside(button.backdrop)

				button.icon:SetTexCoord(unpack(E.TexCoords))
				button.icon:SetInside(button.backdrop)

				hooksecurefunc(button.border, 'Show', function()
					button.backdrop:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
				end)

				hooksecurefunc(button.border, 'Hide', function()
					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end)
			end
		end
	end

	_G.TalentsTalentRow1:Point('TOPLEFT', 20, -142)

	_G.InspectTalentFrame:HookScript('OnShow', function(self)
		if self.isSkinned then return end

		for i = 1, 6 do
			local Glyph = _G.InspectGlyphs['Glyph'..i]

			Glyph:SetTemplate('Default', true)
			Glyph:StyleButton(nil, true)
			Glyph:SetFrameLevel(Glyph:GetFrameLevel() + 5)

			Glyph.highlight:SetTexture(nil)
			Glyph.glyph:Kill()
			Glyph.ring:Kill()

			Glyph.icon = Glyph:CreateTexture(nil, 'OVERLAY')
			Glyph.icon:SetInside()
			Glyph.icon:SetTexCoord(unpack(E.TexCoords))

			if i % 2 == 1 then
				Glyph:Size(40)
			else
				Glyph:Size(60)
			end
		end

		InspectGlyphs.Glyph1:Point('TOPLEFT', 90, -7)
		InspectGlyphs.Glyph2:Point('TOPLEFT', 15, 0)
		InspectGlyphs.Glyph3:Point('TOPLEFT', 90, -97)
		InspectGlyphs.Glyph4:Point('TOPLEFT', 15, -90)
		InspectGlyphs.Glyph5:Point('TOPLEFT', 90, -187)
		InspectGlyphs.Glyph6:Point('TOPLEFT', 15, -180)

		InspectGlyphFrameGlyph_UpdateGlyphs(self.InspectGlyphs, false)

		self.isSkinned = true
	end)

	hooksecurefunc('InspectGlyphFrameGlyph_UpdateSlot', function(self)
		local id = self:GetID()
		local talentGroup = _G.PlayerTalentFrame and _G.PlayerTalentFrame.talentGroup
		local _, glyphType, _, _, iconFilename = GetGlyphSocketInfo(id, talentGroup, true, INSPECTED_UNIT)

		if self.icon then
			if glyphType and iconFilename then
				self.icon:SetTexture(iconFilename)
			else
				self.icon:SetTexture([[Interface\Spellbook\UI-Glyph-Rune1]])
			end
		end
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
