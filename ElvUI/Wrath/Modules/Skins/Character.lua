local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, strfind, unpack = pairs, strfind, unpack

local HasPetUI = HasPetUI
local GetPetHappiness = GetPetHappiness
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = GetItemQualityColor
local GetNumFactions = GetNumFactions
local hooksecurefunc = hooksecurefunc

local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset

function S:CharacterFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- Character Frame
	local CharacterFrame = _G.CharacterFrame
	S:HandleFrame(CharacterFrame, true, nil, 11, -12, -32, 76)

	S:HandleCloseButton(_G.CharacterFrameCloseButton)

	S:HandleDropDownBox(_G.PlayerStatFrameRightDropDown, 145)
	S:HandleDropDownBox(_G.PlayerStatFrameLeftDropDown, 147)
	S:HandleDropDownBox(_G.PlayerTitleDropDown, 200)
	_G.PlayerStatFrameRightDropDown:Point('TOP', -2, 24)
	_G.PlayerStatFrameLeftDropDown:Point('LEFT', -25, 24)
	_G.PlayerTitleDropDown:Point('TOP', -7, -51)

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		S:HandleTab(_G['CharacterFrameTab'..i])
	end

	for i = 1, 3 do
		S:HandleTab(_G['PetPaperDollFrameTab'..i], true)
	end

	_G.PaperDollFrame:StripTextures()

	S:HandleRotateButton(_G.CharacterModelFrameRotateLeftButton)
	_G.CharacterModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	S:HandleRotateButton(_G.CharacterModelFrameRotateRightButton)
	_G.CharacterModelFrameRotateRightButton:Point('TOPLEFT', _G.CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	_G.CharacterAttributesFrame:StripTextures()

	local ResistanceCoords = {
		[1] = { 0.21875, 0.8125, 0.25, 0.32421875 }, --Arcane
		[2] = { 0.21875, 0.8125, 0.0234375, 0.09765625 }, --Fire
		[3] = { 0.21875, 0.8125, 0.13671875, 0.2109375 }, --Nature
		[4] = { 0.21875, 0.8125, 0.36328125, 0.4375}, --Frost
		[5] = { 0.21875, 0.8125, 0.4765625, 0.55078125}, --Shadow
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

	local slots = {
		[1] = CharacterHeadSlot,
		[2] = CharacterNeckSlot,
		[3] = CharacterShoulderSlot,
		[4] = CharacterShirtSlot,
		[5] = CharacterChestSlot,
		[6] = CharacterWaistSlot,
		[7] = CharacterLegsSlot,
		[8] = CharacterFeetSlot,
		[9] = CharacterWristSlot,
		[10] = CharacterHandsSlot,
		[11] = CharacterFinger0Slot,
		[12] = CharacterFinger1Slot,
		[13] = CharacterTrinket0Slot,
		[14] = CharacterTrinket1Slot,
		[15] = CharacterBackSlot,
		[16] = CharacterMainHandSlot,
		[17] = CharacterSecondaryHandSlot,
		[18] = CharacterRangedSlot,
		[19] = CharacterTabardSlot,
		[20] = CharacterAmmoSlot,
	}

	for _, slot in pairs(slots) do
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

	hooksecurefunc('PaperDollItemSlotButton_Update', function(frame)
		if frame.SetBackdropBorderColor then
			local rarity = GetInventoryItemQuality('player', frame:GetID())
			if rarity and rarity > 1 then
				frame:SetBackdropBorderColor(GetItemQualityColor(rarity))
			else
				frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	-- PetPaperDollCompanionFrame (Pets and Mounts in WotLK)
	_G.PetPaperDollFrameCompanionFrame:StripTextures()

	S:HandleButton(_G.CompanionSummonButton)

	S:HandleNextPrevButton(_G.CompanionPrevPageButton)
	S:HandleNextPrevButton(_G.CompanionNextPageButton)

	_G.CompanionNextPageButton:ClearAllPoints()
	_G.CompanionNextPageButton:Point('TOPLEFT', _G.CompanionPrevPageButton, 'TOPRIGHT', 100, 0)

	S:HandleRotateButton(_G.CompanionModelFrameRotateLeftButton)
	_G.CompanionModelFrameRotateLeftButton:ClearAllPoints()
	_G.CompanionModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	S:HandleRotateButton(_G.CompanionModelFrameRotateRightButton)
	_G.CompanionModelFrameRotateRightButton:ClearAllPoints()
	_G.CompanionModelFrameRotateRightButton:Point('TOPLEFT', _G.CompanionModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	hooksecurefunc('PetPaperDollFrame_UpdateCompanions', function()
		for i = 1, NUM_COMPANIONS_PER_PAGE do
			local button = _G['CompanionButton'..i]

			if button.creatureID then
				local iconNormal = button:GetNormalTexture()
				iconNormal:SetTexCoord(unpack(E.TexCoords))
				iconNormal:SetInside()
			end
		end
	end)

	for i = 1, NUM_COMPANIONS_PER_PAGE do
		local button = _G['CompanionButton'..i]
		local iconDisabled = button:GetDisabledTexture()
		local activeTexture = _G['CompanionButton'..i..'ActiveTexture']

		button:StyleButton(nil, true)
		button:SetTemplate(nil, true)

		iconDisabled:SetAlpha(0)

		activeTexture:SetInside(button)
		activeTexture:SetTexture(1, 1, 1, .15)

		if i == 7 then
			button:Point('TOP', CompanionButton1, 'BOTTOM', 0, -5)
		elseif i ~= 1 then
			button:Point('LEFT', _G['CompanionButton'..i-1], 'RIGHT', 5, 0)
		end
	end

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

	local function updHappiness(frame)
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
		local factionStatusBar = _G['ReputationBar'..i..'ReputationBar']
		local factionName = _G['ReputationBar'..i..'FactionName']

		factionBar:StripTextures()
		factionStatusBar:StripTextures()
		factionStatusBar:CreateBackdrop('Default')
		factionStatusBar:SetStatusBarTexture(E.media.normTex)
		factionStatusBar:Size(108, 13)

		E:RegisterStatusBar(factionStatusBar)

		factionName:Width(140)
		factionName:Point('LEFT', factionBar, 'LEFT', -150, 0)
		factionName.SetWidth = E.noop
	end

	hooksecurefunc('ReputationFrame_Update', function()
		local numFactions = GetNumFactions()
		local factionIndex, factionBarButton
		local factionOffset = FauxScrollFrame_GetOffset(_G.ReputationListScrollFrame)

		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			factionBarButton = _G['ReputationBar'..i..'ExpandOrCollapseButton']
			factionIndex = factionOffset + i
			if factionIndex <= numFactions then
				if factionBarButton.isCollapsed then
					factionBarButton:SetNormalTexture(E.Media.Textures.PlusButton)
				else
					factionBarButton:SetNormalTexture(E.Media.Textures.MinusButton)
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

	hooksecurefunc('SkillFrame_UpdateSkills', function()
		if SkillFrameCollapseAllButton.isExpanded then
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

	hooksecurefunc('SkillFrame_SetStatusBar', function(statusBarID, skillIndex)
		local _, isHeader, isExpanded = GetSkillLineInfo(skillIndex)
		if not isHeader then return end

		local skillLine = _G['SkillTypeLabel'..statusBarID]
		if isExpanded then
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

	-- Honor/Arena/PvP Tab
	local PVPFrame = _G.PVPFrame
	S:HandleFrame(PVPFrame, true, nil, 11, -12, -32, 76)
	S:HandleCloseButton(_G.PVPParentFrameCloseButton)
	_G.PVPParentFrameCloseButton:Point('TOPRIGHT', -26, -5)

	for i = 1, MAX_ARENA_TEAMS do
		local pvpTeam = _G['PVPTeam'..i]

		pvpTeam:StripTextures()
		pvpTeam:CreateBackdrop('Default')
		pvpTeam.backdrop:Point('TOPLEFT', 9, -4)
		pvpTeam.backdrop:Point('BOTTOMRIGHT', -24, 3)

		pvpTeam:HookScript('OnEnter', S.SetModifiedBackdrop)
		pvpTeam:HookScript('OnLeave', S.SetOriginalBackdrop)

		_G['PVPTeam'..i..'Highlight']:Kill()
	end

	local PVPTeamDetails = _G.PVPTeamDetails
	PVPTeamDetails:StripTextures()
	PVPTeamDetails:SetTemplate('Transparent')
	PVPTeamDetails:Point('TOPLEFT', PVPFrame, 'TOPRIGHT', -30, -12)

	local PVPFrameToggleButton = _G.PVPFrameToggleButton
	S:HandleNextPrevButton(PVPFrameToggleButton)
	PVPFrameToggleButton:Point('BOTTOMRIGHT', PVPFrame, 'BOTTOMRIGHT', -48, 81)
	PVPFrameToggleButton:Size(14)

	for i = 1, 5 do
		local header = _G['PVPTeamDetailsFrameColumnHeader'..i]
		header:StripTextures()
		header:StyleButton()
	end

	for i = 1, 10 do
		local button = _G['PVPTeamDetailsButton'..i]
		button:Width(335)
		S:HandleButtonHighlight(button)
	end

	S:HandleButton(_G.PVPTeamDetailsAddTeamMember)
	S:HandleNextPrevButton(_G.PVPTeamDetailsToggleButton)
	S:HandleCloseButton(_G.PVPTeamDetailsCloseButton)
end

S:AddCallback('CharacterFrame')

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup

	if TokenFramePopup then
		TokenFramePopup:ClearAllPoints()
		TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 4, -28)
		TokenFramePopup:StripTextures()
		TokenFramePopup:SetTemplate('Transparent')
	end

	local TokenFrameContainer = _G.TokenFrameContainer
	if not TokenFrameContainer.buttons then return end

	local buttons = TokenFrameContainer.buttons
	local numButtons = #buttons

	for i = 1, numButtons do
		local button = buttons[i]

		if button then
			if button.highlight then button.highlight:Kill() end
			if button.categoryLeft then button.categoryLeft:Kill() end
			if button.categoryRight then button.categoryRight:Kill() end
			if button.categoryMiddle then button.categoryMiddle:Kill() end

			if not button.backdrop then
				button:CreateBackdrop(nil, nil, nil, true)
			end

			if button.icon then
				button.icon:SetTexCoord(unpack(E.TexCoords))
				button.icon:Size(17, 17)

				button.backdrop:SetOutside(button.icon, 1, 1)
				button.backdrop:Show()
			else
				button.backdrop:Hide()
			end

			if button.expandIcon then
				if not button.highlightTexture then
					button.highlightTexture = button:CreateTexture(button:GetName()..'HighlightTexture', 'HIGHLIGHT')
					button.highlightTexture:SetTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
					button.highlightTexture:SetBlendMode('ADD')
					button.highlightTexture:SetInside(button.expandIcon)

					-- these two only need to be called once
					-- adding them here will prevent additional calls
					button.expandIcon:ClearAllPoints()
					button.expandIcon:Point('LEFT', 4, 0)
					button.expandIcon:Size(15, 15)
				end

				if button.isHeader then
					button.backdrop:Hide()

					-- TODO: WotLK Fix some quirks for the header point keeps changing after you click the expandIcon button.
					for x = 1, button:GetNumRegions() do
						local region = select(x, button:GetRegions())
						if region and region:IsObjectType('FontString') and region:GetText() then
							region:ClearAllPoints()
							region:Point('LEFT', 25, 0)
						end
					end

					if button.isExpanded then
						button.expandIcon:SetTexture(E.Media.Textures.MinusButton)
						button.expandIcon:SetTexCoord(0,1,0,1)
					else
						button.expandIcon:SetTexture(E.Media.Textures.PlusButton)
						button.expandIcon:SetTexCoord(0,1,0,1)
					end

					button.highlightTexture:Show()
				else
					button.highlightTexture:Hide()
				end
			end
		end
	end
end

function S:Blizzard_TokenUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	_G.TokenFrame:StripTextures()

	S:HandleButton(_G.TokenFrameCancelButton)

	S:HandleCheckBox(_G.TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupBackpackCheckBox)

	hooksecurefunc('TokenFrame_Update', UpdateCurrencySkins)
	hooksecurefunc(_G.TokenFrameContainer, 'update', UpdateCurrencySkins)
end

S:AddCallbackForAddon('Blizzard_TokenUI')
