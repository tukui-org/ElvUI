local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, pairs, strfind = unpack, pairs, strfind

local HasPetUI = HasPetUI
local GetPetHappiness = GetPetHappiness
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = GetItemQualityColor
local GetNumFactions = GetNumFactions
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES
local hooksecurefunc = hooksecurefunc

function S:CharacterFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- Character Frame
	local CharacterFrame = _G.CharacterFrame
	S:HandleFrame(CharacterFrame, true, nil, 11, -12, -32, 76)

	S:HandleCloseButton(_G.CharacterFrameCloseButton, CharacterFrame.backdrop)

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		S:HandleTab(_G['CharacterFrameTab'..i])
	end

	_G.PaperDollFrame:StripTextures()

	S:HandleRotateButton(_G.CharacterModelFrameRotateLeftButton)
	_G.CharacterModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	S:HandleRotateButton(_G.CharacterModelFrameRotateRightButton)
	_G.CharacterModelFrameRotateRightButton:Point('TOPLEFT', _G.CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	_G.CharacterAttributesFrame:StripTextures()

	local ResistanceCoords = {
		[1] = { 0.21875, 0.8125, 0.25, 0.32421875 },		--Arcane
		[2] = { 0.21875, 0.8125, 0.0234375, 0.09765625 },	--Fire
		[3] = { 0.21875, 0.8125, 0.13671875, 0.2109375 },	--Nature
		[4] = { 0.21875, 0.8125, 0.36328125, 0.4375},		--Frost
		[5] = { 0.21875, 0.8125, 0.4765625, 0.55078125},	--Shadow
	}

	local function HandleResistanceFrame(frameName)
		for i = 1, 5 do
			local frame, icon, text = _G[frameName..i], _G[frameName..i]:GetRegions()
			frame:Size(24)
			frame:SetTemplate('Default')

			if i ~= 1 then
				frame:ClearAllPoints()
				frame:Point('TOP', _G[frameName..i - 1], 'BOTTOM', 0, -1)
			end

			if icon then
				icon:SetInside()
				icon:SetTexCoord(unpack(ResistanceCoords[i]))
				icon:SetDrawLayer('ARTWORK')
			end

			if text then
				text:SetDrawLayer('OVERLAY')
			end
		end
	end

	HandleResistanceFrame('MagicResFrame')

	for _, slot in pairs({ _G.PaperDollItemsFrame:GetChildren() }) do
		if slot:IsObjectType('Button') then
			local icon = _G[slot:GetName()..'IconTexture']
			local cooldown = _G[slot:GetName()..'Cooldown']

			slot:StripTextures()
			slot:SetTemplate('Default', true, true)
			slot:StyleButton()

			S:HandleIcon(icon)
			icon:SetInside()

			if cooldown then
				E:RegisterCooldown(cooldown)
			end
		end
	end

	hooksecurefunc('PaperDollItemSlotButton_Update', function(self)
		if self.SetBackdropBorderColor then
			local rarity = GetInventoryItemQuality('player', self:GetID())
			if rarity and rarity > 1 then
				self:SetBackdropBorderColor(GetItemQualityColor(rarity))
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	-- PetPaperDollFrame
	_G.PetPaperDollFrame:StripTextures()

	S:HandleButton(_G.PetPaperDollCloseButton)

	S:HandleRotateButton(_G.PetModelFrameRotateLeftButton)
	_G.PetModelFrameRotateLeftButton:ClearAllPoints()
	_G.PetModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	S:HandleRotateButton(_G.PetModelFrameRotateRightButton)
	_G.PetModelFrameRotateRightButton:ClearAllPoints()
	_G.PetModelFrameRotateRightButton:Point('TOPLEFT', _G.PetModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	_G.PetAttributesFrame:StripTextures()

	_G.PetResistanceFrame:CreateBackdrop('Default')
	_G.PetResistanceFrame.backdrop:SetOutside(_G.PetMagicResFrame1, nil, nil, _G.PetMagicResFrame5)

	HandleResistanceFrame('PetMagicResFrame')

	_G.PetPaperDollFrameExpBar:StripTextures()
	_G.PetPaperDollFrameExpBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.PetPaperDollFrameExpBar)
	_G.PetPaperDollFrameExpBar:CreateBackdrop('Default')

	local function updHappiness(self)
		local happiness = GetPetHappiness()
		local _, isHunterPet = HasPetUI()
		if not (happiness and isHunterPet) then return end

		local texture = self:GetRegions()
		if happiness == 1 then
			texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
		elseif happiness == 2 then
			texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
		elseif happiness == 3 then
			texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
		end
	end

	local PetPaperDollPetInfo = _G.PetPaperDollPetInfo
	PetPaperDollPetInfo:Point('TOPLEFT', _G.PetModelFrameRotateLeftButton, 'BOTTOMLEFT', 9, -3)
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetPaperDollPetInfo:SetFrameLevel(_G.PetModelFrame:GetFrameLevel() + 2)
	PetPaperDollPetInfo:CreateBackdrop('Default')
	PetPaperDollPetInfo:Size(24)

	PetPaperDollPetInfo:RegisterEvent('UNIT_HAPPINESS')
	PetPaperDollPetInfo:SetScript('OnEvent', updHappiness)
	PetPaperDollPetInfo:SetScript('OnShow', updHappiness)

	-- Reputation Frame
	_G.ReputationFrame:StripTextures()

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionBar = _G['ReputationBar'..i]
		local factionHeader = _G['ReputationHeader'..i]
		local factionName = _G['ReputationBar'..i..'FactionName']
		local factionWar = _G['ReputationBar'..i..'AtWarCheck']

		factionBar:StripTextures()
		factionBar:CreateBackdrop('Default')
		factionBar:SetStatusBarTexture(E.media.normTex)
		factionBar:Size(108, 13)
		E:RegisterStatusBar(factionBar)

		if i == 1 then
			factionBar:Point('TOPLEFT', 190, -86)
		end

		factionName:Width(140)
		factionName:Point('LEFT', factionBar, 'LEFT', -150, 0)
		factionName.SetWidth = E.noop

		factionHeader:GetNormalTexture():Size(14)
		factionHeader:SetHighlightTexture(nil)
		factionHeader:Point('TOPLEFT', factionBar, 'TOPLEFT', -175, 0)

		factionWar:StripTextures()
		factionWar:Point('LEFT', factionBar, 'RIGHT', 0, 0)

		factionWar.Icon = factionWar:CreateTexture(nil, 'OVERLAY')
		factionWar.Icon:Point('LEFT', 6, -8)
		factionWar.Icon:Size(32)
		factionWar.Icon:SetTexture([[Interface\Buttons\UI-CheckBox-SwordCheck]])
	end

	hooksecurefunc('ReputationFrame_Update', function()
		local numFactions = GetNumFactions()
		local factionIndex, factionHeader
		local factionOffset = FauxScrollFrame_GetOffset(_G.ReputationListScrollFrame)

		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			factionHeader = _G['ReputationHeader'..i]
			factionIndex = factionOffset + i
			if factionIndex <= numFactions then
				if factionHeader.isCollapsed then
					factionHeader:SetNormalTexture(E.Media.Textures.PlusButton)
				else
					factionHeader:SetNormalTexture(E.Media.Textures.MinusButton)
				end
			end
		end
	end)

	_G.ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ReputationListScrollFrameScrollBar)

	_G.ReputationDetailFrame:StripTextures()
	_G.ReputationDetailFrame:SetTemplate('Transparent')
	_G.ReputationDetailFrame:Point('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', -31, -12)

	S:HandleCloseButton(_G.ReputationDetailCloseButton)
	_G.ReputationDetailCloseButton:Point('TOPRIGHT', 2, 2)

	S:HandleCheckBox(_G.ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(_G.ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(_G.ReputationDetailMainScreenCheckBox)

	-- Skill Frame
	_G.SkillFrame:StripTextures()

	_G.SkillFrameExpandButtonFrame:DisableDrawLayer('BACKGROUND')
	_G.SkillFrameCollapseAllButton:GetNormalTexture():Size(15)
	_G.SkillFrameCollapseAllButton:Point('LEFT', _G.SkillFrameExpandTabLeft, 'RIGHT', -40, -3)

	_G.SkillFrameCollapseAllButton:SetHighlightTexture(nil)

	hooksecurefunc('SkillFrame_UpdateSkills', function()
		if strfind(_G.SkillFrameCollapseAllButton:GetNormalTexture():GetTexture(), 'MinusButton') then
			_G.SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.MinusButton)
		else
			_G.SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
		end
	end)

	S:HandleButton(_G.SkillFrameCancelButton)

	for i = 1, _G.SKILLS_TO_DISPLAY do
		local bar = _G['SkillRankFrame'..i]
		local label = _G['SkillTypeLabel'..i]
		local border = _G['SkillRankFrame'..i..'Border']
		local background = _G['SkillRankFrame'..i..'Background']

		bar:CreateBackdrop('Default')
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		border:StripTextures()
		background:SetTexture(nil)

		label:GetNormalTexture():Size(14)
		label:SetHighlightTexture(nil)
	end

	hooksecurefunc('SkillFrame_SetStatusBar', function(statusBarID, skillIndex, numSkills)
		local skillLine = _G['SkillTypeLabel'..statusBarID]
		if strfind(skillLine:GetNormalTexture():GetTexture(), 'MinusButton') then
			skillLine:SetNormalTexture(E.Media.Textures.MinusButton)
		else
			skillLine:SetNormalTexture(E.Media.Textures.PlusButton)
		end
	end)

	_G.SkillListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.SkillListScrollFrameScrollBar)

	_G.SkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(_G.SkillDetailScrollFrameScrollBar)

	_G.SkillDetailStatusBar:StripTextures()
	_G.SkillDetailStatusBar:SetParent(_G.SkillDetailScrollFrame)
	_G.SkillDetailStatusBar:CreateBackdrop('Default')
	_G.SkillDetailStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.SkillDetailStatusBar)

	S:HandleCloseButton(_G.SkillDetailStatusBarUnlearnButton)
	S:HandleButton(_G.SkillDetailStatusBarUnlearnButton)
	_G.SkillDetailStatusBarUnlearnButton:Size(24)
	_G.SkillDetailStatusBarUnlearnButton:Point('LEFT', _G.SkillDetailStatusBarBorder, 'RIGHT', 5, 0)
	_G.SkillDetailStatusBarUnlearnButton:SetHitRectInsets(0, 0, 0, 0)

	-- Honor Tab
	_G.HonorFrame:StripTextures()

	_G.HonorFrameProgressBar:StripTextures()
	_G.HonorFrameProgressBar:Height(22)
	_G.HonorFrameProgressBar:SetParent(_G.HonorFrame)
	_G.HonorFrameProgressBar:CreateBackdrop()
	_G.HonorFrameProgressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.HonorFrameProgressBar)
end

S:AddCallback('CharacterFrame')
