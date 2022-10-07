local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, strfind = unpack, strfind
local ipairs, pairs, select = ipairs, pairs, select

local HasPetUI = HasPetUI
local GetPetHappiness = GetPetHappiness
local GetSkillLineInfo = GetSkillLineInfo
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = GetItemQualityColor
local GetNumFactions = GetNumFactions
local hooksecurefunc = hooksecurefunc

local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS
local NUM_COMPANIONS_PER_PAGE = NUM_COMPANIONS_PER_PAGE
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset

local ResistanceCoords = {
	{ 0.21875, 0.8125, 0.25, 0.32421875 },		--Arcane
	{ 0.21875, 0.8125, 0.0234375, 0.09765625 },	--Fire
	{ 0.21875, 0.8125, 0.13671875, 0.2109375 },	--Nature
	{ 0.21875, 0.8125, 0.36328125, 0.4375},		--Frost
	{ 0.21875, 0.8125, 0.4765625, 0.55078125},	--Shadow
}

local function Update_GearManagerDialogPopup()
	_G.GearManagerDialogPopup:ClearAllPoints()
	_G.GearManagerDialogPopup:Point('TOPLEFT', _G.GearManagerDialog, 'TOPRIGHT', 4, 0)
end

local function Update_Happiness(frame)
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
		local frame = _G[frameName..i]
		local icon, text = frame:GetRegions()
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

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup
	if TokenFramePopup then
		TokenFramePopup:ClearAllPoints()
		TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', -33, -12)
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
				if (button.itemID == Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID and UnitFactionGroup("player")) then
					button.icon:SetTexCoord(0.06325, 0.59375, 0.03125, 0.57375)
				else
					button.icon:SetTexCoord(unpack(E.TexCoords))
				end
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

					-- TODO: Wrath Fix some quirks for the header point keeps changing after you click the expandIcon button.
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

	-- HandleTab looks weird
	for i = 1, 3 do
		local tab = _G['PetPaperDollFrameTab'..i]
		tab:StripTextures()
		tab:Height(24)
		S:HandleButton(tab)
	end

	hooksecurefunc('PetPaperDollFrame_UpdateTabs', function()
		_G.PetPaperDollFrameTab1:ClearAllPoints()
		_G.PetPaperDollFrameTab1:Point('TOPLEFT', _G.PetPaperDollFrameCompanionFrame, 'TOPLEFT', 88, -40)
	end)

	_G.PaperDollFrame:StripTextures()

	S:HandleRotateButton(_G.CharacterModelFrameRotateLeftButton)
	_G.CharacterModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	S:HandleRotateButton(_G.CharacterModelFrameRotateRightButton)
	_G.CharacterModelFrameRotateRightButton:Point('TOPLEFT', _G.CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	_G.CharacterModelFrameRotateLeftButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.CharacterModelFrameRotateLeftButton:GetNormalTexture():SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
	_G.CharacterModelFrameRotateLeftButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.CharacterModelFrameRotateLeftButton:GetPushedTexture():SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)
	_G.CharacterModelFrameRotateRightButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.CharacterModelFrameRotateRightButton:GetNormalTexture():SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
	_G.CharacterModelFrameRotateRightButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
	_G.CharacterModelFrameRotateRightButton:GetPushedTexture():SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)

	_G.CharacterAttributesFrame:StripTextures()

	HandleResistanceFrame('MagicResFrame')

	local slots = {
		_G.CharacterHeadSlot,
		_G.CharacterNeckSlot,
		_G.CharacterShoulderSlot,
		_G.CharacterShirtSlot,
		_G.CharacterChestSlot,
		_G.CharacterWaistSlot,
		_G.CharacterLegsSlot,
		_G.CharacterFeetSlot,
		_G.CharacterWristSlot,
		_G.CharacterHandsSlot,
		_G.CharacterFinger0Slot,
		_G.CharacterFinger1Slot,
		_G.CharacterTrinket0Slot,
		_G.CharacterTrinket1Slot,
		_G.CharacterBackSlot,
		_G.CharacterMainHandSlot,
		_G.CharacterSecondaryHandSlot,
		_G.CharacterRangedSlot,
		_G.CharacterTabardSlot,
		_G.CharacterAmmoSlot,
	}

	for _, slot in pairs(slots) do
		if slot:IsObjectType('Button') then
			local icon = _G[slot:GetName()..'IconTexture']
			local cooldown = _G[slot:GetName()..'Cooldown']

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

	-- PetPaperDollFrame
	_G.PetPaperDollFrame:StripTextures()
	_G.PetPaperDollCloseButton:Kill()

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
	PetPaperDollPetInfo:SetFrameLevel(_G.PetModelFrame:GetFrameLevel() + 2)
	PetPaperDollPetInfo:CreateBackdrop()
	PetPaperDollPetInfo:Size(24)

	PetPaperDollPetInfo:RegisterEvent('UNIT_HAPPINESS')
	PetPaperDollPetInfo:SetScript('OnEvent', Update_Happiness)
	PetPaperDollPetInfo:SetScript('OnShow', Update_Happiness)

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

		button:StyleButton(nil, true)
		button:SetTemplate(nil, true)

		iconDisabled:SetAlpha(0)

		if i == 7 then
			button:Point('TOP', _G.CompanionButton1, 'BOTTOM', 0, -5)
		elseif i ~= 1 then
			button:Point('LEFT', _G['CompanionButton'..i-1], 'RIGHT', 5, 0)
		end
	end

	-- GearManager / EquipmentManager
	local GearManager = _G.GearManagerDialog
	GearManager:StripTextures()
	GearManager:SetTemplate('Transparent')
	GearManager:Point('TOPLEFT', _G.PaperDollFrame, 'TOPRIGHT', -30, -12)

	local GearManagerToggleButton = _G.GearManagerToggleButton
	GearManagerToggleButton:Point('TOPRIGHT', _G.PaperDollItemsFrame, 'TOPRIGHT', -37, -40)

	S:HandleCloseButton(_G.GearManagerDialogClose, GearManager)

	local buttons = {
		_G.GearManagerDialogDeleteSet,
		_G.GearManagerDialogEquipSet,
		_G.GearManagerDialogSaveSet,
	}

	for _, button in pairs(buttons) do
		S:HandleButton(button)
	end

	_G.GearManagerDialogDeleteSet:Point('BOTTOMLEFT', GearManager, 'BOTTOMLEFT', 11, 8)
	_G.GearManagerDialogEquipSet:Point('BOTTOMLEFT', GearManager, 'BOTTOMLEFT', 93, 8)
	_G.GearManagerDialogSaveSet:Point('BOTTOMRIGHT', GearManager, 'BOTTOMRIGHT', -8, 8)

	for _, button in ipairs(GearManager.buttons) do
		button:StripTextures()
		button:CreateBackdrop()
		button:StyleButton(nil, true)

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.backdrop:SetAllPoints()
	end

	S:HandleEditBox(_G.GearManagerDialogPopupEditBox)
	S:HandleIconSelectionFrame(_G.GearManagerDialogPopup, _G.NUM_GEARSET_ICONS_SHOWN, 'GearManagerDialogPopupButton', nil, true)
	hooksecurefunc('GearManagerDialogPopup_Update', Update_GearManagerDialogPopup) -- they set points for frame on _Update, so send (dontOffset: true) to HandleIconSelectionFrame

	-- Reputation Frame
	_G.ReputationFrame:StripTextures()

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local factionBar = _G['ReputationBar'..i]
		local factionStatusBar = _G['ReputationBar'..i..'ReputationBar']
		local factionName = _G['ReputationBar'..i..'FactionName']

		factionBar:StripTextures()
		factionStatusBar:StripTextures()
		factionStatusBar:CreateBackdrop()
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
	_G.SkillFrameCancelButton:Kill()

	_G.SkillFrameExpandButtonFrame:DisableDrawLayer('BACKGROUND')
	_G.SkillFrameCollapseAllButton:GetNormalTexture():Size(15)
	_G.SkillFrameCollapseAllButton:Point('LEFT', _G.SkillFrameExpandTabLeft, 'RIGHT', -40, -3)

	hooksecurefunc('SkillFrame_UpdateSkills', function()
		if _G.SkillFrameCollapseAllButton.isExpanded then
			_G.SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.MinusButton)
		else
			_G.SkillFrameCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
		end
	end)

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
	_G.SkillDetailStatusBar:CreateBackdrop()
	_G.SkillDetailStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.SkillDetailStatusBar)

	S:HandleCloseButton(_G.SkillDetailStatusBarUnlearnButton)
	_G.SkillDetailStatusBarUnlearnButton:Point('LEFT', _G.SkillDetailStatusBarBorder, 'RIGHT', -6, 1)

	-- Honor/Arena/PvP Tab
	local PVPFrame = _G.PVPFrame
	S:HandleFrame(PVPFrame, true, nil, 11, -12, -32, 76)
	S:HandleCloseButton(_G.PVPParentFrameCloseButton)
	_G.PVPParentFrameCloseButton:Point('TOPRIGHT', -26, -5)

	for i = 1, MAX_ARENA_TEAMS do
		local pvpTeam = _G['PVPTeam'..i]

		pvpTeam:StripTextures()
		pvpTeam:CreateBackdrop()
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

	-- BG Queue Tabs
	S:HandleTab(_G.PVPParentFrameTab1)
	S:HandleTab(_G.PVPParentFrameTab2)

	S:HandleButton(_G.PVPTeamDetailsAddTeamMember)
	S:HandleNextPrevButton(_G.PVPTeamDetailsToggleButton)
	S:HandleCloseButton(_G.PVPTeamDetailsCloseButton)

	-- TokenFrame (Currency Tab)
	_G.TokenFrame:StripTextures()
	_G.TokenFrameCancelButton:Kill()
	_G.TokenFrameMoneyFrame:Kill()

	for i = 1, _G.TokenFrame:GetNumChildren() do
		local child = select(i, _G.TokenFrame:GetChildren())
		if child and not child:GetName() and strfind(child:GetNormalTexture():GetTexture(), 'MinimizeButton') then
			child:Hide()
			break
		end
	end

	S:HandleCheckBox(_G.TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupBackpackCheckBox)

	S:HandleCloseButton(_G.TokenFramePopupCloseButton, _G.TokenFramePopup)

	hooksecurefunc('TokenFrame_Update', UpdateCurrencySkins)
	hooksecurefunc(_G.TokenFrameContainer, 'update', UpdateCurrencySkins)
end

S:AddCallback('CharacterFrame')
