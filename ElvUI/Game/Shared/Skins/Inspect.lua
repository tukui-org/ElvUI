local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetGlyphSocketInfo = GetGlyphSocketInfo
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInspectSpecialization = GetInspectSpecialization

local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS
local MAX_TALENT_TABS = MAX_TALENT_TABS
local MAX_NUM_TALENTS = MAX_NUM_TALENTS

S:AddCallbackForAddon('Blizzard_InspectUI', nil, nil, nil, nil, nil, 'inspect')

local function HandleTabs()
	local tab = _G.InspectFrameTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', E.Modern and -3 or -10, 0) -- classic tabs use CharacterFrameTabButtonTemplate
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', E.Modern and -5 or -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['InspectFrameTab'..index]
	end
end

local function BackgroundDesaturation(bckgnd, value)
	if value and bckgnd.ignoreDesaturated then
		bckgnd:SetDesaturated(false)
	end
end

-- Retail and Forever
local function SkinPvpTalents(slot)
	local icon = slot.Texture
	slot:StripTextures()
	slot.Border:Hide()

	S:HandleIcon(icon, true)
	icon.backdrop:SetFrameLevel(2)
end

-- Forever
local function UpdateTabLayout(frame)
	S:LayoutLargeSideTabs(frame, frame.ModeTabs.Tabs)
end

-- Mists, Wrath, TBC and Vanilla
local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())

	local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

-- Mists
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

local function InspectTalentIconDesaturated(icon, desaturate)
	local parent = icon:GetParent()
	parent.ShadowedTexture:SetShown(desaturate)
end

local function UpdateGlyph(frame)
	local talentGroup = _G.PlayerTalentFrame and _G.PlayerTalentFrame.talentGroup;
	local _, glyphType, _, _, iconFilename = GetGlyphSocketInfo(frame:GetID(), talentGroup, true, _G.INSPECTED_UNIT)
	frame.texture:SetTexture(glyphType and iconFilename or [[Interface\Spellbook\UI-Glyph-Rune1]])
end

function S:Blizzard_InspectUI()
	local InspectFrame = _G.InspectFrame
	S:HandlePortraitFrame(InspectFrame)

	-- Tabs
	HandleTabs()

	if E.Modern then
		S:HandleButton(_G.InspectPaperDollFrame.ViewButton)
		S:HandleButton(E.Forever and _G.InspectPaperDollFrame.InspectTalents or _G.InspectPaperDollItemsFrame.InspectTalents) -- Forever has it on the paper doll frame

		-- Create portrait element for the PvP Frame so we can see prestige
		local InspectPVPFrame = _G.InspectPVPFrame
		local portrait = InspectPVPFrame:CreateTexture(nil, 'OVERLAY')
		portrait:Size(55)
		InspectPVPFrame.SmallWreath:ClearAllPoints()
		InspectPVPFrame.SmallWreath:Point('TOPLEFT', -2, -25)

		-- PvP Talents
		for i = 1, 3 do
			SkinPvpTalents(InspectPVPFrame['TalentSlot'..i])
		end

		if E.Forever then -- Forever side tabs, the bottom tabs stay hidden
			for _, tab in next, InspectFrame.ModeTabs.Tabs do
				S:HandleLargeSideTab(tab)
			end

			hooksecurefunc(InspectFrame, 'UpdateTabLayout', UpdateTabLayout)
			UpdateTabLayout(InspectFrame)
		else
			_G.InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
			_G.InspectPaperDollItemsFrame.InspectTalents:Point('TOPRIGHT', _G.InspectFrame, 'BOTTOMRIGHT', 0, -1)
		end

		local InspectModelFrame = _G.InspectModelFrame
		InspectModelFrame:StripTextures()
		InspectModelFrame:CreateBackdrop()
		InspectModelFrame.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
		InspectModelFrame.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

		-- Re-add the overlay texture which was removed via StripTextures
		InspectModelFrame.BackgroundOverlay:SetColorTexture(0, 0, 0)
	else
		_G.InspectPaperDollFrame:StripTextures()

		if E.Mists then -- dims the race background, which blizzard only sets from cata on
			_G.InspectModelFrameBackgroundOverlay:SetTexture(E.media.blankTex)
			_G.InspectModelFrameBackgroundOverlay:SetVertexColor(0, 0, 0, 0.6)
		else
			_G.InspectModelFrameBackgroundOverlay:SetTexture(E.Media.Textures.Invisible)
		end

		_G.InspectModelFrameBackgroundOverlay:CreateBackdrop('Transparent')
	end

	-- Background Artwork
	if (E.Modern or E.Mists) and E.private.skins.parchmentRemoverEnable then -- the guild tab and the pvp BG start with cata
		_G.InspectGuildFrameBG:Kill()
		_G.InspectPVPFrame.BG:Kill()
	end

	_G.InspectModelFrameBorderTopLeft:Kill()
	_G.InspectModelFrameBorderTopRight:Kill()
	_G.InspectModelFrameBorderTop:Kill()
	_G.InspectModelFrameBorderLeft:Kill()
	_G.InspectModelFrameBorderRight:Kill()
	_G.InspectModelFrameBorderBottomLeft:Kill()
	_G.InspectModelFrameBorderBottomRight:Kill()
	_G.InspectModelFrameBorderBottom:Kill()

	if E.Modern then -- classic has no second bottom border
		_G.InspectModelFrameBorderBottom2:Kill()
	end

	-- Give inspect frame model backdrop it's color back
	for _, corner in next, { 'TopLeft','TopRight','BotLeft','BotRight' } do
		local bg = _G['InspectModelFrameBackground'..corner]
		bg:SetDesaturated(false)
		bg.ignoreDesaturated = true -- so plugins can prevent this if they want

		hooksecurefunc(bg, 'SetDesaturated', BackgroundDesaturation)
	end

	if E.Modern then
		for _, Slot in next, { _G.InspectPaperDollItemsFrame:GetChildren() } do
			if Slot.icon then -- the item slots, not the talents button
				S:HandleIcon(Slot.icon, true)
				Slot.icon.backdrop:OffsetFrameLevel(nil, Slot)
				Slot.icon:SetInside()
				Slot:StripTextures()
				Slot:StyleButton()

				S:HandleIconBorder(Slot.IconBorder, Slot.icon.backdrop)
			end
		end
	else
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
	end

	if E.Mists then
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
			local info = spec and E.SpecInfoBySpecID[spec]
			if info and info.role then
				if info.role == 'DAMAGER' then
					frame.roleIcon:SetTexture(E.Media.Textures.DPS)
				elseif info.role == 'TANK' then
					frame.roleIcon:SetTexture(E.Media.Textures.Tank)
				elseif info.role == 'HEALER' then
					frame.roleIcon:SetTexture(E.Media.Textures.Healer)
				end

				frame.tooltip = info.desc

				frame.roleIcon:Size(20)
				frame.roleIcon:SetTexCoords()
				frame.roleName:SetTextColor(1, 1, 1)
				frame.specIcon:SetTexture(info.icon)
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
	elseif E.Wrath or E.TBC then
		-- PvP Tab
		_G.InspectPVPFrame:StripTextures(true)

		for i = 1, MAX_ARENA_TEAMS do
			local team = _G['InspectPVPTeam'..i]
			team:StripTextures()
			team:CreateBackdrop()
			team.backdrop:Point('TOPLEFT', 9, -4)
			team.backdrop:Point('BOTTOMRIGHT', -24, 3)

			team:HookScript('OnEnter', S.SetModifiedBackdrop)
			team:HookScript('OnLeave', S.SetOriginalBackdrop)

			_G['InspectPVPTeam'..i..'Highlight']:Kill()
		end

		-- Talent Tab
		_G.InspectTalentFrame:StripTextures()

		for i = 1, MAX_TALENT_TABS do -- HandleTab looks weird on these
			local tab = _G['InspectTalentFrameTab'..i]
			tab:StripTextures()
			tab:Height(24)
			S:HandleButton(tab)
		end

		local pointsBar = _G.InspectTalentFramePointsBar
		pointsBar:StripTextures()

		_G.InspectTalentFrameSpentPointsText:Point('LEFT', pointsBar, 'LEFT', 12, -1)
		_G.InspectTalentFrameTalentPointsText:Point('RIGHT', pointsBar, 'RIGHT', -12, -1)

		local scrollFrame = _G.InspectTalentFrameScrollFrame
		scrollFrame:StripTextures()
		scrollFrame:CreateBackdrop()

		local scrollBar = _G.InspectTalentFrameScrollFrameScrollBar
		S:HandleScrollBar(scrollBar)
		scrollBar:Point('TOPLEFT', scrollFrame, 'TOPRIGHT', 10, -16)

		for i = 1, MAX_NUM_TALENTS do
			local talent = _G['InspectTalentFrameTalent'..i]
			talent:StripTextures()
			talent:SetTemplate()
			talent:StyleButton()

			local icon = talent.icon
			icon:SetInside()
			icon:SetTexCoords()
			icon:SetDrawLayer('ARTWORK')

			local rank = _G['InspectTalentFrameTalent'..i..'Rank']
			rank:FontTemplate(nil, 12, 'OUTLINE')
		end
	elseif E.Classic then
		-- Honor Tab
		_G.InspectHonorFrame:StripTextures()

		_G.InspectHonorFrameProgressButton:CreateBackdrop('Transparent')

		local progressBar = _G.InspectHonorFrameProgressBar
		progressBar:SetStatusBarTexture(E.media.normTex)
		progressBar:PointXY(19, -74)
		progressBar:Width(300)

		E:RegisterStatusBar(progressBar)
	end
end
