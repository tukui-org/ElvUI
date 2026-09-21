local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local HasPetUI = HasPetUI
local GetPetHappiness = GetPetHappiness
local GetInventoryItemQuality = GetInventoryItemQuality

local HONOR_CURRENCY = Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID
local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS

local ResistanceCoords = {
	{ 0.21875, 0.8125, 0.25, 0.32421875 },		--Arcane
	{ 0.21875, 0.8125, 0.0234375, 0.09765625 },	--Fire
	{ 0.21875, 0.8125, 0.13671875, 0.2109375 },	--Nature
	{ 0.21875, 0.8125, 0.36328125, 0.4375},		--Frost
	{ 0.21875, 0.8125, 0.4765625, 0.55078125},	--Shadow
}

local function PaperDollItemSlotButtonUpdate(frame)
	if not frame.SetBackdropBorderColor then return end -- bag bar slots run this too, no backdrop when the bag bar is off

	local id = frame:GetID()
	local rarity = id and GetInventoryItemQuality('player', id)
	local r, g, b = E:GetItemQualityColor(rarity and rarity > 1 and rarity)
	frame:SetBackdropBorderColor(r, g, b)
end

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup
	TokenFramePopup:ClearAllPoints()
	TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 1, 0)
	TokenFramePopup:StripTextures()
	TokenFramePopup:SetTemplate('Transparent')

	S:HandleCheckBox(_G.TokenFramePopupInactiveCheckbox)
	S:HandleCheckBox(_G.TokenFramePopupBackpackCheckbox)

	for _, button in next, _G.TokenFrameContainer.buttons do
		button.highlight:Kill()
		button.categoryLeft:Kill()
		button.categoryRight:Kill()

		if not button.backdrop then
			button:CreateBackdrop(nil, nil, nil, true)
		end

		if button.itemID == HONOR_CURRENCY then -- Blizzard crops the honor icon too
			button.icon:SetTexCoord(0.06325, 0.59375, 0.03125, 0.57375)
		else
			button.icon:SetTexCoords()
		end

		button.icon:Size(17)

		button.backdrop:SetOutside(button.icon, 1, 1)
		button.backdrop:Show()

		if not button.highlightTexture then
			button.highlightTexture = button:CreateTexture(button:GetName()..'HighlightTexture', 'HIGHLIGHT')
			button.highlightTexture:SetTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
			button.highlightTexture:SetBlendMode('ADD')
			button.highlightTexture:SetInside(button.expandIcon)

			-- these two only need to be called once
			-- adding them here will prevent additional calls
			button.expandIcon:ClearAllPoints()
			button.expandIcon:Point('LEFT', 4, 0)
			button.expandIcon:Size(15)
		end

		if button.isHeader then
			button.backdrop:Hide()

			for _, region in next, { button:GetRegions() } do
				if region:IsObjectType('FontString') and region:GetText() then
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

local function HandleTabs()
	local lastTab
	for index = 1, #CHARACTERFRAME_SUBFRAMES do
		local tab = _G['CharacterFrameTab'..index]
		if index ~= 2 or HasPetUI() then -- pet tab is hidden without a pet
			tab:ClearAllPoints()

			if lastTab then
				tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			else
				tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', 1, 76)
			end

			lastTab = tab
		end
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

local function HandleResistanceFrame(name)
	for i = 1, 5 do
		local frameName = name..i
		local frame = _G[frameName]
		local icon, text = frame:GetRegions()
		frame:Size(24)
		frame:SetTemplate()

		if i ~= 1 then
			frame:ClearAllPoints()
			frame:Point('TOP', _G[frameName - 1], 'BOTTOM', 0, -1)
		end

		icon:SetInside()
		icon:SetTexCoord(unpack(ResistanceCoords[i]))
		icon:SetDrawLayer('ARTWORK')

		text:SetDrawLayer('OVERLAY')
	end
end

function S:CharacterFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- Character Frame
	local CharacterFrame = _G.CharacterFrame
	S:HandleFrame(CharacterFrame, true, nil, 11, -12, -32, 76)

	S:HandleDropDownBox(_G.PlayerTitleDropdown, 160)

	_G.PaperDollFrame:StripTextures()

	for i = 1, #CHARACTERFRAME_SUBFRAMES do
		S:HandleTab(_G['CharacterFrameTab'..i])
	end

	-- stat dropdowns
	S:HandleDropDownBox(_G.PlayerStatFrameLeftDropdown, 110)
	S:HandleDropDownBox(_G.PlayerStatFrameRightDropdown, 110)

	-- Reposition Tabs
	hooksecurefunc('PetPaperDollFrame_UpdateIsAvailable', HandleTabs)
	HandleTabs()

	_G.CharacterModelFrame:CreateBackdrop('Transparent')
	_G.CharacterModelFrame.backdrop:Point('TOPLEFT', -2, 4)
	_G.CharacterModelFrame.backdrop:Point('BOTTOMRIGHT', _G.CharacterAttributesFrame, 2, -10)

	S:HandleRotateButton(_G.CharacterModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.CharacterModelFrameRotateRightButton)

	_G.CharacterModelFrameRotateLeftButton:Point('TOPLEFT', 0, 2)
	_G.CharacterModelFrameRotateRightButton:Point('TOPLEFT', _G.CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	_G.CharacterAttributesFrame:StripTextures()

	HandleResistanceFrame('MagicResFrame')

	for _, slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
		if slot:IsObjectType('Button') and slot.Count then -- skips GearManagerToggleButton
			local name = slot:GetName()
			local icon = _G[name..'IconTexture']

			slot:StripTextures()
			slot:SetTemplate(nil, true, true)
			slot:StyleButton()

			S:HandleIcon(icon)
			icon:SetInside()

			E:RegisterCooldown(_G[name..'Cooldown'])
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
		local factionStatusBar = _G['ReputationBar'..i..'ReputationBar']
		local factionBarButton = _G['ReputationBar'..i..'ExpandOrCollapseButton']
		local factionName = _G['ReputationBar'..i..'FactionName']

		factionBar:StripTextures()
		factionStatusBar:StripTextures()
		factionStatusBar:CreateBackdrop()
		factionStatusBar:SetStatusBarTexture(E.media.normTex)
		factionStatusBar:Size(108, 13)

		S:HandleCollapseTexture(factionBarButton, nil, true)
		E:RegisterStatusBar(factionStatusBar)

		factionName:Width(140)
		factionName:Point('LEFT', factionBar, 'LEFT', -150, 0)
		factionName.SetWidth = E.noop
	end

	_G.ReputationListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ReputationListScrollFrameScrollBar)

	_G.ReputationDetailFrame:StripTextures()
	_G.ReputationDetailFrame:SetTemplate('Transparent')
	_G.ReputationDetailFrame:Point('TOPLEFT', _G.ReputationFrame, 'TOPRIGHT', 1, 0)

	S:HandleCheckBox(_G.ReputationDetailAtWarCheckbox)
	S:HandleCheckBox(_G.ReputationDetailInactiveCheckbox)
	S:HandleCheckBox(_G.ReputationDetailMainScreenCheckbox)

	S:HandleCloseButton(_G.ReputationDetailCloseButton)
	_G.ReputationDetailCloseButton:Point('TOPRIGHT', 2, 2)

	-- TokenFrame (Currency Tab)
	_G.TokenFrame:StripTextures()
	S:HandleButton(_G.TokenFrameCancelButton)

	local _, _, _, closeFrameButton = _G.TokenFrame:GetChildren() -- Container, MoneyFrame, CancelButton, unnamed UIPanelCloseButton
	closeFrameButton:Kill() -- sits on CharacterFrameCloseButton

	S:HandleScrollBar(_G.TokenFrameContainerScrollBar)
	S:HandleCloseButton(_G.TokenFramePopupCloseButton, _G.TokenFramePopup)

	hooksecurefunc(_G.TokenFrameContainer, 'update', UpdateCurrencySkins)
	hooksecurefunc('TokenFrame_Update', UpdateCurrencySkins)

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

	-- Honor/Arena/PvP Tab
	local PVPFrame = _G.PVPFrame
	S:HandleFrame(PVPFrame, true, nil, 11, -12, -32, 76)

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

	-- why two close buttons? matches BattlefieldFrameCloseButton
	S:HandleCloseButton(_G.PVPParentFrameCloseButton)
	_G.PVPParentFrameCloseButton:Point('TOPRIGHT', -30, -8)

	for i = 1, 2 do
		S:HandleTab(_G['PVPParentFrameTab'..i])
	end

	for i = 1, 5 do -- column headers
		local header = _G['PVPTeamDetailsFrameColumnHeader'..i]
		header:StripTextures()
		header:StyleButton()
	end

	for i = 1, 10 do -- team member rows
		local button = _G['PVPTeamDetailsButton'..i]
		button:Width(335)

		S:HandleButtonHighlight(button)
	end

	S:HandleButton(_G.PVPTeamDetailsAddTeamMember)
	S:HandleNextPrevButton(_G.PVPTeamDetailsToggleButton)
	S:HandleCloseButton(_G.PVPTeamDetailsCloseButton)
end

S:AddCallback('CharacterFrame')
