local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, format = pairs, format
local unpack, next = unpack, next

local hooksecurefunc = hooksecurefunc
local UnitResistance = UnitResistance
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityByID = C_Item.GetItemQualityByID
local HasPetUI = HasPetUI

local GetContainerItemID = C_Container.GetContainerItemID
local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local STAT_FORMAT = STAT_FORMAT
local HONOR_CURRENCY = HONOR_CURRENCY

local spellSchoolIcon = [[Interface\PaperDollInfoFrame\SpellSchoolIcon]]

local FLYOUT_LOCATIONS = {
	[0xFFFFFFFF] = 'PLACEINBAGS',
	[0xFFFFFFFE] = 'IGNORESLOT',
	[0xFFFFFFFD] = 'UNIGNORESLOT'
}

local function EquipmentManagerPane_UpdateChild(child)
	if child.icon and not child.IsSkinned then
		child.BgTop:SetTexture(E.ClearTexture)
		child.BgMiddle:SetTexture(E.ClearTexture)
		child.BgBottom:SetTexture(E.ClearTexture)
		S:HandleIcon(child.icon)
		child.HighlightBar:SetColorTexture(1, 1, 1, .25)
		child.HighlightBar:SetDrawLayer('BACKGROUND')
		child.SelectedBar:SetColorTexture(0.8, 0.8, 0.8, .25)
		child.SelectedBar:SetDrawLayer('BACKGROUND')

		child.IsSkinned = true
	end
end

local function EquipmentManagerPane_Update(frame)
	frame:ForEachFrame(EquipmentManagerPane_UpdateChild)
end

local function TitleManagerPane_UpdateChild(child)
	if not child.IsSkinned then
		child:DisableDrawLayer('BACKGROUND')
		child.IsSkinned = true
	end
end

local function TitleManagerPane_Update(frame)
	frame:ForEachFrame(TitleManagerPane_UpdateChild)
end

local function HandleItemButtonQuality(button, rarity)
	local r, g, b = E:GetItemQualityColor(rarity and rarity > 1 and rarity)
	button:SetBackdropBorderColor(r, g, b)
end

local function PaperDollItemButtonQuality(button)
	if not button.SetBackdropBorderColor then return end

	local id = button.id or button:GetID()
	local rarity = id and GetInventoryItemQuality('player', id)

	HandleItemButtonQuality(button, rarity)
end

local function EquipmentItemButtonQuality(button)
	if not button.SetBackdropBorderColor then return end

	local location, rarity = button.location
	if location then
		local _, _, bags, slot, bag = EquipmentManager_UnpackLocation(location)
		if bags then
			local itemID = GetContainerItemID(bag, slot)
			rarity = itemID and GetItemQualityByID(itemID)
		else
			rarity = GetInventoryItemQuality('player', slot)
		end
	end

	HandleItemButtonQuality(button, rarity)
end

local function PaperDollFrameSetResistance(frame, unit, index)
	local _, resistance = UnitResistance(unit, index)
	local icon = format('|T%s%d:12:12:0:0:64:64:4:55:4:55|t', spellSchoolIcon, index + 1)
	local name = frame:GetName()

	_G[name..'Label']:SetFormattedText('%s '..STAT_FORMAT, icon, _G['SPELL_SCHOOL'..index..'_CAP'])

	frame.tooltip = format('%s %s'..PAPERDOLLFRAME_TOOLTIP_FORMAT..' %s%s', icon, HIGHLIGHT_FONT_COLOR_CODE, _G['RESISTANCE'..index..'_NAME'], resistance or 0, FONT_COLOR_CODE_CLOSE)
end

local function TabTextureCoords(tex, x1)
	if x1 ~= 0.16001 then
		tex:SetTexCoord(0.16001, 0.86, 0.16, 0.86)
	end
end

local function FixSidebarTabCoords()
	local hasDejaCharacterStats = E.OtherAddons.DejaCharacterStats

	local index = 1
	local tab = _G['PaperDollSidebarTab'..index]
	while tab do
		if not tab.backdrop then
			tab:CreateBackdrop()
			tab.Icon:SetAllPoints()

			tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
			tab.Highlight:SetAllPoints()

			if hasDejaCharacterStats then
				tab.Hider:SetTexture()
			else
				tab.Hider:SetColorTexture(0, 0, 0, 0.8)
			end

			tab.Hider:SetAllPoints(tab.backdrop)
			tab.TabBg:Kill()

			if index == 1 then
				for _, region in next, { tab:GetRegions() } do
					region:SetTexCoord(0.16, 0.86, 0.16, 0.86)

					hooksecurefunc(region, 'SetTexCoord', TabTextureCoords)
				end
			end
		end

		index = index + 1
		tab = _G['PaperDollSidebarTab'..index]
	end
end

local function BackdropDesaturated(background, value)
	if value and background.ignoreDesaturated then
		background:SetDesaturated(false)
	end
end

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup
	if TokenFramePopup then
		TokenFramePopup:ClearAllPoints()
		TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', 1, 0)
		TokenFramePopup:StripTextures()
		TokenFramePopup:SetTemplate('Transparent')

		S:HandleCheckBox(_G.TokenFramePopupInactiveCheckbox)
		S:HandleCheckBox(_G.TokenFramePopupBackpackCheckbox)
	end

	local TokenFrameContainer = _G.TokenFrameContainer
	if not TokenFrameContainer.buttons then return end

	for _, button in next, TokenFrameContainer.buttons do
		if button.highlight then button.highlight:Kill() end
		if button.categoryLeft then button.categoryLeft:Kill() end
		if button.categoryRight then button.categoryRight:Kill() end
		if button.categoryMiddle then button.categoryMiddle:Kill() end

		if not button.backdrop then
			button:CreateBackdrop(nil, nil, nil, true)
		end

		if button.icon then
			if button.itemID == HONOR_CURRENCY and E.myfaction then
				button.icon:SetTexCoord(0.06325, 0.59375, 0.03125, 0.57375)
			else
				button.icon:SetTexCoord(unpack(E.TexCoords))
			end

			button.icon:Size(17)

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
end

local function HandleTabs()
	local lastTab
	for index, tab in next, { _G.CharacterFrameTab1, HasPetUI() and _G.CharacterFrameTab2 or nil, _G.CharacterFrameTab3, _G.CharacterFrameTab4, _G.CharacterFrameTab5 } do
		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -10, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
		end

		lastTab = tab
	end
end

local function EquipmentDisplayButton(button)
	if not button.isHooked then
		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)
		button:SetTemplate()
		button:StyleButton()

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(E.TexCoords))

		button.isHooked = true
	end

	if FLYOUT_LOCATIONS[button.location] then -- special slots
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function EquipmentUpdateItems()
	local frame = _G.EquipmentFlyoutFrame.buttonFrame
	if not frame.template then
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	local width, height = frame:GetSize()
	frame:Size(width+3, height)

	for _, button in next, _G.EquipmentFlyoutFrame.buttons do
		EquipmentDisplayButton(button)
	end
end

local function EquipmentUpdateNavigation()
	local navi = _G.EquipmentFlyoutFrame.NavigationFrame
	if not navi then return end

	navi:ClearAllPoints()
	navi:Point('TOPLEFT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMLEFT', 0, -E.Border - E.Spacing)
	navi:Point('TOPRIGHT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMRIGHT', 0, -E.Border - E.Spacing)

	navi:StripTextures()
	navi:SetTemplate('Transparent')
end

function S:CharacterFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	-- General
	local CharacterFrame = _G.CharacterFrame
	S:HandlePortraitFrame(CharacterFrame)

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
		_G.CharacterAmmoSlot
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

	-- Give character frame model backdrop it's color back
	for _, corner in pairs({'TopLeft','TopRight','BotLeft','BotRight'}) do
		local bg = _G['CharacterModelFrameBackground'..corner]
		if bg then
			bg:SetDesaturated(false)
			bg.ignoreDesaturated = true -- so plugins can prevent this if they want.

			hooksecurefunc(bg, 'SetDesaturated', BackdropDesaturated)
		end
	end

	_G.CharacterLevelText:FontTemplate()

	-- Strip Textures
	local charframe = {
		'CharacterModelScene',
		'CharacterStatsPane',
		'CharacterFrameInset',
		'CharacterFrameInsetRight',
		'PaperDollSidebarTabs',
		'PetModelFrame',
		'PetModelFrameShadowOverlay'
	}

	-- Icon in upper right corner of character frame
	_G.CharacterFramePortrait:Kill()

	for _, scrollbar in pairs({ _G.PaperDollFrame.EquipmentManagerPane.ScrollBar, _G.PaperDollFrame.TitleManagerPane.ScrollBar, _G.CharacterStatsPane.ScrollBar }) do
		S:HandleTrimScrollBar(scrollbar)
	end

	for _, object in pairs(charframe) do
		_G[object]:StripTextures()
	end

	-- Re-add the overlay texture which was removed right above via StripTextures
	_G.CharacterModelFrameBackgroundOverlay:SetTexture(E.media.blankTex)
	_G.CharacterModelFrameBackgroundOverlay:SetVertexColor(0, 0, 0, 0.6)

	_G.CharacterModelScene:CreateBackdrop()
	_G.CharacterModelScene.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	_G.CharacterModelScene.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	_G.PetModelFrame:CreateBackdrop()
	_G.PetModelFrame.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	_G.PetModelFrame.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	S:HandleModelSceneControlButtons(_G.CharacterModelScene.ControlFrame)

	-- Titles
	hooksecurefunc(_G.PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', TitleManagerPane_Update)

	-- Equipement Manager
	hooksecurefunc(_G.PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', EquipmentManagerPane_Update)
	S:HandleButton(_G.PaperDollFrameEquipSet)
	S:HandleButton(_G.PaperDollFrameSaveSet)

	-- Item Quality Borders and Armor Slots
	local CharacterMainHandSlot = _G.CharacterMainHandSlot
	CharacterMainHandSlot:ClearAllPoints()
	CharacterMainHandSlot:Point('BOTTOMLEFT', _G.PaperDollItemsFrame, 'BOTTOMLEFT', 106, 10)

	-- Icon selection frame
	_G.GearManagerPopupFrame:HookScript('OnShow', function(frame)
		if frame.IsSkinned then return end -- set by HandleIconSelectionFrame

		S:HandleIconSelectionFrame(frame)
	end)

	-- Stats
	for i = 1, 7 do
		local frame = _G['CharacterStatsPaneCategory'..i]
		frame:StripTextures()
		frame:SetTemplate('Transparent')

		frame.Toolbar = _G['CharacterStatsPaneCategory'..i..'Toolbar']
		S:HandleButton(frame.Toolbar, nil, nil, true)

		local name = _G['CharacterStatsPaneCategory'..i..'NameText']
		if name then
			name:ClearAllPoints()
			name:Point('CENTER', frame.Toolbar)
		end

		_G['CharacterStatsPaneCategory'..i..'Stat1']:Point('TOPLEFT', frame, 16, -18)
		_G['CharacterStatsPaneCategory'..i..'ToolbarSortDownArrow']:Kill()
		--_G['CharacterStatsPaneCategory'..i..'ToolbarSortUpArrow']:Kill()
	end

	do -- Expand Button
		local expandButton = _G.CharacterFrameExpandButton
		S:HandleNextPrevButton(expandButton, nil, nil, nil, nil, nil, 26) -- Default UI button size is 32

		expandButton:ClearAllPoints()
		expandButton:Point('BOTTOMRIGHT', _G.CharacterFrameInset, 'BOTTOMRIGHT', -3, 2)

		local expandNormal = expandButton:GetNormalTexture()
		local expandPushed = expandButton:GetPushedTexture()

		local function ExpandToggle()
			expandButton:SetNormalTexture(E.Media.Textures.ArrowUp)
			expandButton:SetPushedTexture(E.Media.Textures.ArrowUp)
			expandButton:SetDisabledTexture(E.Media.Textures.ArrowUp)

			local expanded = CharacterFrame.Expanded
			expandNormal:SetRotation(expanded and 1.57 or -1.57)
			expandPushed:SetRotation(expanded and 1.57 or -1.57)
		end

		ExpandToggle()
		hooksecurefunc(CharacterFrame, 'Collapse', ExpandToggle)
		hooksecurefunc(CharacterFrame, 'Expand', ExpandToggle)
	end

	-- Pet Frame
	S:HandleStatusBar(_G.PetPaperDollFrameExpBar)
	S:HandleRotateButton(_G.PetModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.PetModelFrameRotateRightButton)

	-- Reputation Frame
	_G.ReputationFrame:StripTextures()

	for i = 1, _G.NUM_FACTIONS_DISPLAYED do
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

	-- Try to find the close button
	for _, child in next, { _G.TokenFrame:GetChildren() } do
		if child.Hide and child:IsShown() and not child:GetName() then
			child:Hide()
			break
		end
	end

	S:HandleScrollBar(_G.TokenFrameContainerScrollBar)
	S:HandleCloseButton(_G.TokenFramePopupCloseButton, _G.TokenFramePopup)

	hooksecurefunc(_G.TokenFrameContainer, 'update', UpdateCurrencySkins)
	hooksecurefunc('TokenFrame_Update', UpdateCurrencySkins)
	hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', FixSidebarTabCoords)
	hooksecurefunc('PaperDollFrame_SetResistance', PaperDollFrameSetResistance)
	hooksecurefunc('PaperDollItemSlotButton_Update', PaperDollItemButtonQuality)

	-- Equipment Flyout
	_G.EquipmentFlyoutFrameHighlight:StripTextures()
	_G.EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
	_G.EquipmentFlyoutFrameButtons:DisableDrawLayer('ARTWORK')

	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.NextButton)

	hooksecurefunc('EquipmentFlyout_SetBackgroundTexture', EquipmentUpdateNavigation)
	hooksecurefunc('EquipmentFlyout_UpdateItems', EquipmentUpdateItems) -- Swap item flyout frame (shown when holding alt over a slot)
	hooksecurefunc('EquipmentFlyout_DisplayButton', EquipmentItemButtonQuality)

	-- Tabs
	for i = 1, #_G.CHARACTERFRAME_SUBFRAMES do
		S:HandleTab(_G['CharacterFrameTab'..i])
	end

	-- Reposition Tabs
	hooksecurefunc('PetPaperDollFrame_UpdateIsAvailable', HandleTabs)
	HandleTabs()
end

S:AddCallback('CharacterFrame')
