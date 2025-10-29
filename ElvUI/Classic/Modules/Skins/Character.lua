local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local HasPetUI = HasPetUI
local GetNumFactions = GetNumFactions
local GetPetHappiness = GetPetHappiness
local GetInventoryItemQuality = GetInventoryItemQuality
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset

local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES

local ResistanceCoords = {
	{ 0.21875, 0.8125, 0.25, 0.32421875 },		--Arcane
	{ 0.21875, 0.8125, 0.0234375, 0.09765625 },	--Fire
	{ 0.21875, 0.8125, 0.13671875, 0.2109375 },	--Nature
	{ 0.21875, 0.8125, 0.36328125, 0.4375},		--Frost
	{ 0.21875, 0.8125, 0.4765625, 0.55078125},	--Shadow
}

local function ReputationFrameUpdate()
	local factionOffset = FauxScrollFrame_GetOffset(_G.ReputationListScrollFrame)
	local numFactions = GetNumFactions()

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionIndex = factionOffset + i
		if factionIndex <= numFactions then
			local factionHeader = _G['ReputationHeader'..i]
			if factionHeader.isCollapsed then
				factionHeader:SetNormalTexture(E.Media.Textures.PlusButton)
			else
				factionHeader:SetNormalTexture(E.Media.Textures.MinusButton)
			end
		end
	end
end

local function PaperDollItemSlotButtonUpdate(frame)
	if not frame.SetBackdropBorderColor then return end

	local id = frame:GetID()
	local rarity = id and GetInventoryItemQuality('player', id)
	local r, g, b = E:GetItemQualityColor(rarity and rarity > 1 and rarity)
	frame:SetBackdropBorderColor(r, g, b)
end

local function HandleTabs()
	local lastTab
	for index, tab in next, { _G.CharacterFrameTab1, HasPetUI() and _G.CharacterFrameTab2 or nil, _G.CharacterFrameTab3, _G.CharacterFrameTab4, _G.CharacterFrameTab5 } do
		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', 1, 76)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
		end

		lastTab = tab
	end
end

local function HandleHappiness(frame)
	local happiness = GetPetHappiness()
	local _, isHunterPet = HasPetUI()
	if not (happiness and isHunterPet) then return end

	local texture = frame:GetRegions()
	if happiness == 1 then
		texture:SetTexCoord(0.41, 0.53, 0.06, 0.30)
	elseif happiness == 2 then
		texture:SetTexCoord(0.22, 0.345, 0.06, 0.30)
	elseif happiness == 3 then
		texture:SetTexCoord(0.04, 0.15, 0.06, 0.30)
	end
end

local function HandleResistanceFrame(frameName)
	for i = 1, 5 do
		local frame, icon, text = _G[frameName..i], _G[frameName..i]:GetRegions()
		frame:Size(24)
		frame:SetTemplate()

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

function S:CharacterFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- Character Frame
	local CharacterFrame = _G.CharacterFrame
	S:HandleFrame(CharacterFrame, true, nil, 11, -12, -32, 76)

	S:HandleCloseButton(_G.CharacterFrameCloseButton, CharacterFrame.backdrop)

	_G.PaperDollFrame:StripTextures()

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		S:HandleTab(_G['CharacterFrameTab'..i])
	end

	-- Seasonal
	local runeButton = E.ClassicSOD and _G.RuneFrameControlButton
	if runeButton then
		S:HandleButton(runeButton, true)

		if not runeButton.runeIcon then -- make then icon
			runeButton.runeIcon = runeButton:CreateTexture(nil, 'ARTWORK')
			runeButton.runeIcon:SetTexture(134419) -- Interface\Icons\INV_Misc_Rune_06
			runeButton.runeIcon:SetTexCoords()
			runeButton.runeIcon:SetInside(runeButton)
		end
	end

	-- Reposition Tabs
	hooksecurefunc('PetTab_Update', HandleTabs)
	HandleTabs()

	_G.CharacterModelFrame:CreateBackdrop('Transparent')
	_G.CharacterModelFrame.backdrop:Point('TOPLEFT', -2, 4)
	_G.CharacterModelFrame.backdrop:Point('BOTTOMRIGHT', _G.CharacterAttributesFrame, 2, -10)

	S:HandleRotateButton(_G.CharacterModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.CharacterModelFrameRotateRightButton)

	_G.CharacterModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	_G.CharacterModelFrameRotateRightButton:Point('TOPLEFT', _G.CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	_G.CharacterAttributesFrame:StripTextures()

	HandleResistanceFrame('MagicResFrame')

	for _, slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
		if slot:IsObjectType('Button') and slot.Count then
			local name = slot:GetName()
			local icon = _G[name..'IconTexture']
			local cooldown = _G[name..'Cooldown']

			slot:StripTextures()
			slot:SetTemplate(nil, true, true)
			slot:StyleButton()

			S:HandleIcon(icon)
			icon:SetInside()

			if cooldown then
				E:RegisterCooldown(cooldown)
			end
		end
	end

	hooksecurefunc('PaperDollItemSlotButton_Update', PaperDollItemSlotButtonUpdate)

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

	_G.PetResistanceFrame:CreateBackdrop()
	_G.PetResistanceFrame.backdrop:SetOutside(_G.PetMagicResFrame1, nil, nil, _G.PetMagicResFrame5)

	HandleResistanceFrame('PetMagicResFrame')

	_G.PetPaperDollFrameExpBar:StripTextures()
	_G.PetPaperDollFrameExpBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.PetPaperDollFrameExpBar)
	_G.PetPaperDollFrameExpBar:CreateBackdrop()

	local PetPaperDollPetInfo = _G.PetPaperDollPetInfo
	PetPaperDollPetInfo:Point('TOPLEFT', _G.PetModelFrameRotateLeftButton, 'BOTTOMLEFT', 9, -3)
	PetPaperDollPetInfo:GetRegions():SetTexCoord(0.04, 0.15, 0.06, 0.30)
	PetPaperDollPetInfo:OffsetFrameLevel(2, _G.PetModelFrame)
	PetPaperDollPetInfo:CreateBackdrop()
	PetPaperDollPetInfo:Size(24)

	PetPaperDollPetInfo:RegisterEvent('UNIT_HAPPINESS')
	PetPaperDollPetInfo:SetScript('OnEvent', HandleHappiness)
	PetPaperDollPetInfo:SetScript('OnShow', HandleHappiness)

	-- Reputation Frame
	_G.ReputationFrame:StripTextures()

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionBar = _G['ReputationBar'..i]
		local factionHeader = _G['ReputationHeader'..i]
		local factionName = _G['ReputationBar'..i..'FactionName']
		local factionWar = _G['ReputationBar'..i..'AtWarCheck']

		factionBar:StripTextures()
		factionBar:CreateBackdrop()
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
		factionHeader:SetHighlightTexture(E.ClearTexture)
		factionHeader:Point('TOPLEFT', factionBar, 'TOPLEFT', -175, 0)

		factionWar:StripTextures()
		factionWar:Point('LEFT', factionBar, 'RIGHT', 0, 0)

		factionWar.Icon = factionWar:CreateTexture(nil, 'OVERLAY')
		factionWar.Icon:Point('LEFT', 6, -8)
		factionWar.Icon:Size(32)
		factionWar.Icon:SetTexture([[Interface\Buttons\UI-CheckBox-SwordCheck]])
	end

	hooksecurefunc('ReputationFrame_Update', ReputationFrameUpdate)

	_G.ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ReputationListScrollFrameScrollBar)

	_G.ReputationDetailFrame:StripTextures()
	_G.ReputationDetailFrame:SetTemplate('Transparent')
	_G.ReputationDetailFrame:Point('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', -31, -12)

	S:HandleCloseButton(_G.ReputationDetailCloseButton)
	_G.ReputationDetailCloseButton:Point('TOPRIGHT', 2, 2)

	S:HandleCheckBox(_G.ReputationDetailAtWarCheckbox)
	S:HandleCheckBox(_G.ReputationDetailInactiveCheckbox)
	S:HandleCheckBox(_G.ReputationDetailMainScreenCheckbox)

	-- Skill Frame
	_G.SkillFrame:StripTextures()

	_G.SkillFrameExpandButtonFrame:DisableDrawLayer('BACKGROUND')
	_G.SkillFrameCollapseAllButton:GetNormalTexture():Size(15)
	_G.SkillFrameCollapseAllButton:Point('LEFT', _G.SkillFrameExpandTabLeft, 'RIGHT', -40, -3)
	_G.SkillFrameCollapseAllButton:SetHighlightTexture(E.ClearTexture)

	S:HandleCollapseTexture(_G.SkillFrameCollapseAllButton, nil, true)
	_G.SkillFrameCancelButton:Kill() -- Random duplicate close button

	for i = 1, _G.SKILLS_TO_DISPLAY do
		local bar = _G['SkillRankFrame'..i]
		local label = _G['SkillTypeLabel'..i]
		local border = _G['SkillRankFrame'..i..'Border']
		local background = _G['SkillRankFrame'..i..'Background']

		bar:CreateBackdrop()
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		border:StripTextures()
		background:SetTexture(nil)

		label:GetNormalTexture():Size(14)
		label:SetHighlightTexture(E.ClearTexture)
		S:HandleCollapseTexture(label, nil, true)
	end

	_G.SkillListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.SkillListScrollFrameScrollBar)

	_G.SkillDetailScrollFrame:StripTextures()
	S:HandleScrollBar(_G.SkillDetailScrollFrameScrollBar)

	_G.SkillDetailStatusBar:StripTextures()
	_G.SkillDetailStatusBar:SetParent(_G.SkillDetailScrollFrame)
	_G.SkillDetailStatusBar:CreateBackdrop()
	_G.SkillDetailStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.SkillDetailStatusBar)

	S:HandleCloseButton(_G.SkillDetailStatusBarUnlearnButton)
	_G.SkillDetailStatusBarUnlearnButton:CreateBackdrop('Transparent')
	_G.SkillDetailStatusBarUnlearnButton:Size(26)
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
