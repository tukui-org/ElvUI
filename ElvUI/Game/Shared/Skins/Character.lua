local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, next = unpack, next
local format, strlower = format, strlower
local hooksecurefunc = hooksecurefunc
local CreateColor = CreateColor

local HasPetUI = HasPetUI
local UnitResistance = UnitResistance
local GetPetHappiness = GetPetHappiness
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityByID = C_Item.GetItemQualityByID
local GetContainerItemID = C_Container.GetContainerItemID
local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation

local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local STAT_FORMAT = STAT_FORMAT

local HONOR_CURRENCY = Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID
local CHARACTERFRAME_SUBFRAMES = CHARACTERFRAME_SUBFRAMES
local NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED
local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS

local spellSchoolIcon = [[Interface\PaperDollInfoFrame\SpellSchoolIcon]]

local FLYOUT_LOCATIONS = {
	[0xFFFFFFFF] = 'PLACEINBAGS',
	[0xFFFFFFFE] = 'IGNORESLOT',
	[0xFFFFFFFD] = 'UNIGNORESLOT'
}

local oldAtlas = {
	Options_ListExpand_Right = 1,
	Options_ListExpand_Right_Expanded = 1
}

local RESISTANCE_ICONS = { -- atlas suffix to the plain SpellSchoolIcon index
	['UI-Character-Info-Resistance-Holy'] = spellSchoolIcon..2,
	['UI-Character-Info-Resistance-Fire'] = spellSchoolIcon..3,
	['UI-Character-Info-Resistance-Nature'] = spellSchoolIcon..4,
	['UI-Character-Info-Resistance-Frost'] = spellSchoolIcon..5,
	['UI-Character-Info-Resistance-Shadow'] = spellSchoolIcon..6,
	['UI-Character-Info-Resistance-Arcane'] = spellSchoolIcon..7,
}

local ResistanceCoords = {
	{ 0.21875, 0.8125, 0.25, 0.32421875 },		--Arcane
	{ 0.21875, 0.8125, 0.0234375, 0.09765625 },	--Fire
	{ 0.21875, 0.8125, 0.13671875, 0.2109375 },	--Nature
	{ 0.21875, 0.8125, 0.36328125, 0.4375},		--Frost
	{ 0.21875, 0.8125, 0.4765625, 0.55078125},	--Shadow
}

if E.Modern then
	S:AddCallbackForAddon('Blizzard_UIPanels_Game', nil, nil, nil, nil, nil, 'character')
else
	S:AddCallback('Blizzard_UIPanels_Game', nil, nil, 'character')
end

if E.Forever then -- Forever only addon
	S:AddCallbackForAddon('Blizzard_Statistics', nil, nil, nil, nil, nil, 'character')
end

local function UpdateCollapse(texture, atlas)
	if not atlas or oldAtlas[atlas] then
		local parent = texture:GetParent()
		if parent:IsCollapsed() then
			texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Expand')
		else
			texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Collapse')
		end
	end
end

local function UpdateToggleCollapseButton(button)
	local header = button:GetHeader()

	local collapsed
	if header.IsCollapsed then
		collapsed = header:IsCollapsed()
	elseif header.treeNode then -- Forever statistics sub headers
		collapsed = header.treeNode:IsCollapsed()
	end

	local tex = collapsed and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton
	button:SetNormalTexture(tex)
	button:SetPushedTexture(tex)
end

local function UpdateTokenSkinsChild(child)
	if not child.IsSkinned then
		if child.Right then
			child:StripTextures()
			child:CreateBackdrop('Transparent')
			child.backdrop:SetInside(child)

			UpdateCollapse(child.Right)
			UpdateCollapse(child.HighlightRight)

			hooksecurefunc(child.Right, 'SetAtlas', UpdateCollapse)
			hooksecurefunc(child.HighlightRight, 'SetAtlas', UpdateCollapse)
		end

		local icon = child.Content and child.Content.CurrencyIcon
		if icon then
			S:HandleIcon(icon)
		end

		local ToggleCollapseButton = child.ToggleCollapseButton
		if ToggleCollapseButton then
			hooksecurefunc(ToggleCollapseButton, 'RefreshIcon', UpdateToggleCollapseButton)

			UpdateToggleCollapseButton(ToggleCollapseButton)
		end

		child.IsSkinned = true
	end
end

local function UpdateTokenSkins(frame)
	frame:ForEachFrame(UpdateTokenSkinsChild)
end

local function EquipmentManagerPane_UpdateChild(child)
	if not child.IsSkinned then
		if E.Forever then -- Forever outfit cards
			for _, region in next, { child:GetRegions() } do -- the card background and the icon frame are unnamed
				local atlas = region:IsObjectType('Texture') and region:GetAtlas()
				if atlas == 'UI-Character-Info-OutfitCard' or atlas == 'UI-Character-Info-OutfitIcon-Frame' then
					region:SetTexture(E.ClearTexture)
				end
			end

			child:CreateBackdrop()
			child.backdrop:Point('TOPLEFT')
			child.backdrop:Point('BOTTOMRIGHT', -7, 0) -- the scroll bar overlaps the scroll box

			S:HandleIcon(child.icon, true) -- after the row backdrop, so its border draws on top

			for _, bar in next, { child.HighlightBar, child.SelectedBar } do
				bar:ClearAllPoints()
				bar:Point('TOPLEFT', child.icon.backdrop, 'TOPRIGHT', 0, -E.Border)
				bar:Point('BOTTOMRIGHT', child.backdrop, 'BOTTOMRIGHT', -E.Border, E.Border)
			end
		else
			child.BgTop:SetTexture(E.ClearTexture)
			child.BgMiddle:SetTexture(E.ClearTexture)
			child.BgBottom:SetTexture(E.ClearTexture)
			S:HandleIcon(child.icon)
		end

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

local function PaperDollItemSlotButtonUpdate(slot)
	local highlight = slot:GetHighlightTexture()
	highlight:SetTexture(E.Media.Textures.White8x8)
	highlight:SetVertexColor(1, 1, 1, .25)
	highlight:SetInside()
end

local function UpdateAzeriteItem(item)
	if not item.IsSkinned then
		item.IsSkinned = true

		item.AzeriteTexture:SetAlpha(0)
		item.RankFrame.Texture:SetTexture()
		item.RankFrame.Label:FontTemplate(nil, nil, 'OUTLINE')
	end
end

local function UpdateAzeriteEmpoweredItem(item)
	item.AzeriteTexture:SetAtlas('AzeriteIconFrame')
	item.AzeriteTexture:SetInside()
	item.AzeriteTexture:SetTexCoords()
	item.AzeriteTexture:SetDrawLayer('BORDER', 1)
end

local function ColorizeStatPane(frame)
	frame.Background:SetAlpha(0)

	local r, g, b = 0.8, 0.8, 0.8
	local gradientFrom, gradientTo = CreateColor(r, g, b, 0.25), CreateColor(r, g, b, 0)

	frame.leftGrad = frame:CreateTexture(nil, 'BORDER')
	frame.leftGrad:Size(80, frame:GetHeight())
	frame.leftGrad:Point('LEFT', frame, 'CENTER')
	frame.leftGrad:SetTexture(E.Media.Textures.White8x8)
	frame.leftGrad:SetGradient('Horizontal', gradientFrom, gradientTo)

	frame.rightGrad = frame:CreateTexture(nil, 'BORDER')
	frame.rightGrad:Size(80, frame:GetHeight())
	frame.rightGrad:Point('RIGHT', frame, 'CENTER')
	frame.rightGrad:SetTexture(E.Media.Textures.White8x8)
	frame.rightGrad:SetGradient('Horizontal', gradientTo, gradientFrom)
end

local function StatsPane(which)
	local CharacterStatsPane = _G.CharacterStatsPane
	CharacterStatsPane[which]:StripTextures()
	CharacterStatsPane[which]:CreateBackdrop('Transparent')
	CharacterStatsPane[which].backdrop:ClearAllPoints()
	CharacterStatsPane[which].backdrop:Point('CENTER')
	CharacterStatsPane[which].backdrop:Size(150, 18)
end

local function EquipmentDisplayButton(button, index)
	if not button.isHooked then
		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)
		button:SetTemplate()
		button:StyleButton()

		button.icon:SetInside()
		button.icon:SetTexCoords()

		if E.Modern then -- the classic SetItemButtonQuality always hides it
			S:HandleIconBorder(button.IconBorder)
		end

		if E.Forever and (index - 1) % 5 == 0 then -- first button of a row, the others chain to it (37px rows with a 5px gap)
			local spacing = E.Border + E.Spacing
			button:ClearAllPoints()
			button:Point('TOPLEFT', _G.EquipmentFlyoutFrame.buttonFrame, 'TOPLEFT', spacing, -spacing - (42 * ((index - 1) / 5)))
		end

		button.isHooked = true
	end

	if FLYOUT_LOCATIONS[button.location] then -- special slots
		button:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
end

local function EquipmentUpdateItems()
	local flyout = _G.EquipmentFlyoutFrame
	local frame = flyout.buttonFrame
	if not frame.template then
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	if E.Forever then -- Forever flyouts open in four directions from slot sized popout buttons
		for i = 1, frame.numBGs do -- larger layouts add more slices of the flyout art
			frame['bg'..i]:SetAlpha(0)
		end

		for i, button in next, flyout.buttons do
			EquipmentDisplayButton(button, i)
		end

		-- 3px on the top and left, 3px on the bottom, none on the right
		local spacing = E.Border + E.Spacing
		local width, height = frame:GetSize()
		frame:Size(width - 3 + (spacing * 2), height - 6 + (spacing * 2))

		-- Blizzard anchors it 3px below the popout button, which is the height of the slot now
		local slot = flyout.button
		local anchor = slot.popoutButton or slot
		local direction = slot.flyoutDirection
		frame:ClearAllPoints()
		if direction == 'LEFT' then
			frame:Point('TOPRIGHT', anchor, 'TOPLEFT', -spacing, spacing)
		elseif direction == 'UP' then
			frame:Point('BOTTOMLEFT', anchor, 'TOPLEFT', -spacing, spacing)
		elseif direction == 'DOWN' then
			frame:Point('TOPLEFT', anchor, 'BOTTOMLEFT', -spacing, -spacing)
		else
			frame:Point('TOPLEFT', anchor, 'TOPRIGHT', spacing, spacing)
		end
	else
		local width, height = frame:GetSize()
		frame:Size(width+3, height)

		for _, button in next, flyout.buttons do
			EquipmentDisplayButton(button)
		end
	end
end

local function EquipmentUpdateNavigation()
	local navi = _G.EquipmentFlyoutFrame.NavigationFrame
	navi:ClearAllPoints()
	navi:Point('TOPLEFT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMLEFT', 0, -E.Border - E.Spacing)
	navi:Point('TOPRIGHT', _G.EquipmentFlyoutFrameButtons, 'BOTTOMRIGHT', 0, -E.Border - E.Spacing)

	navi:StripTextures()
	navi:SetTemplate('Transparent')
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

local function UpdateFactionSkinsChild(child)
	if not child.IsSkinned then
		if child.Right then
			child:StripTextures()
			child:CreateBackdrop('Transparent')
			child.backdrop:SetInside(child)

			UpdateCollapse(child.Right)
			UpdateCollapse(child.HighlightRight)

			hooksecurefunc(child.Right, 'SetAtlas', UpdateCollapse)
			hooksecurefunc(child.HighlightRight, 'SetAtlas', UpdateCollapse)
		end

		local ReputationBar = child.Content and child.Content.ReputationBar
		if ReputationBar then
			ReputationBar:StripTextures()
			ReputationBar:SetStatusBarTexture(E.media.normTex)
			ReputationBar:CreateBackdrop()
			E:RegisterStatusBar(ReputationBar)
		end

		local ToggleCollapseButton = child.ToggleCollapseButton
		if ToggleCollapseButton then
			hooksecurefunc(ToggleCollapseButton, 'RefreshIcon', UpdateToggleCollapseButton)

			UpdateToggleCollapseButton(ToggleCollapseButton)
		end

		child.IsSkinned = true
	end
end

local function UpdateFactionSkins(frame)
	frame:ForEachFrame(UpdateFactionSkinsChild)
end

local function PaperDollUpdateStats()
	for frame in _G.CharacterStatsPane.statsFramePool:EnumerateActive() do
		if not frame.leftGrad then
			ColorizeStatPane(frame)
		end

		local shown = frame.Background:IsShown()
		frame.leftGrad:SetShown(shown)
		frame.rightGrad:SetShown(shown)
	end
end

local function BackdropDesaturated(background, value)
	if value and background.ignoreDesaturated then
		background:SetDesaturated(false)
	end
end

local function UpdateCurrencyTransferLogLine(frame)
	if frame.IsSkinned then return end

	S:HandleIcon(frame.CurrencyIcon)
	frame.CurrencyIcon:Size(16)

	frame.IsSkinned = true
end

local function UpdateCurrencyTransferLogLines(frame)
	frame:ForEachFrame(UpdateCurrencyTransferLogLine)
end

local function GearManagerPopupFrame_OnShow(frame)
	if not frame.IsSkinned then -- set by HandleIconSelectionFrame
		S:HandleIconSelectionFrame(frame, nil, nil, 'GearManagerPopupFrame')
	end
end

-- Forever character frame
local function SetArrow(texture, rotation)
	texture:SetTexture(E.Media.Textures.ArrowUp)
	texture:SetTexCoord(0, 1, 0, 1)
	texture:SetRotation(rotation)
end

-- Replace title artwork on category rows
local function HandleCategory(frame)
	frame.Background:SetAlpha(0)
	frame:CreateBackdrop()
	frame.backdrop:ClearAllPoints()
	frame.backdrop:Point('CENTER')
	frame.backdrop:Size(150, 18)
end

local function ColoredProgressBar_SetFillWidth(bar, width)
	bar.Fill:SetShown(width > 0)
end

-- ColoredProgressBarTemplate: unnamed background, a masked Fill and Text
local function HandleColoredProgressBar(bar)
	bar:GetRegions():SetTexture(E.ClearTexture)

	bar:CreateBackdrop('Transparent')
	bar.backdrop:Point('TOPLEFT', bar, 'LEFT', -1, 8)
	bar.backdrop:Point('BOTTOMRIGHT', bar, 'RIGHT', 1, -8)

	bar.Text:FontTemplate()

	bar.Fill:RemoveMaskTexture(bar.Mask)
	bar.Fill:ClearAllPoints()
	bar.Fill:Point('TOPLEFT', bar.backdrop, 'TOPLEFT', E.Border, -E.Border)
	bar.Fill:Point('BOTTOMLEFT', bar.backdrop, 'BOTTOMLEFT', E.Border, E.Border)

	hooksecurefunc(bar, 'SetFillWidth', ColoredProgressBar_SetFillWidth)
end

local function HappinessInfo_UpdateHappiness(info)
	if not _G.CharacterStatsPanePetScrollBox:IsShown() then
		info:Hide() -- blizzard shows it on every tab
	end
end

local function ShowSidebar()
	_G.PetPaperDollPetHappinessInfo:UpdateHappiness() -- reshow on the pet tab, the hook above hides it elsewhere
end

local function UpdateTabLayout(frame)
	S:LayoutLargeSideTabs(frame, frame.ModeTabs.Tabs)

	for _, tab in next, frame.ModeTabs.Tabs do
		if tab:IsShown() then
			tab:ClearAllPoints()
			tab:Point('TOPLEFT', frame, 'TOPRIGHT', 3, -1)
			break
		end
	end
end

local function SetLevel() -- blizzard grows PaperDollLevelInfo to 40 for the pet loyalty line but never shrinks it back for the player
	_G.PaperDollLevelInfo:SetHeight(20)
end

local function UpdateRightPaneToggleButton(frame)
	local button = frame.RightPaneToggleButton
	local rotation = S.ArrowRotation[frame:IsRightPaneCollapsed() and 'right' or 'left']
	SetArrow(button:GetNormalTexture(), rotation)
	SetArrow(button:GetPushedTexture(), rotation)
end

-- Blizzard re-applies atlas, size and rotation on every state change (show, hover, click)
local function PopoutButton_RefreshVisualState(button)
	local parent = button:GetParent()
	local direction = (parent and parent.flyoutDirection) or button.flyoutDirection or (parent and parent.verticalFlyout and 'UP') or 'RIGHT'
	if button.flyoutLocked then -- points back at the slot while the flyout is kept open
		direction = (direction == 'RIGHT' and 'LEFT') or (direction == 'LEFT' and 'RIGHT') or (direction == 'UP' and 'DOWN') or 'UP'
	end

	if not button.backdrop then
		button:CreateBackdrop()
		button.backdrop:SetAllPoints()
	end

	if parent then
		if direction == 'UP' or direction == 'DOWN' then
			button:SetWidth(parent:GetWidth())
		else
			button:SetHeight(parent:GetHeight())
		end
	end

	local rotation = S.ArrowRotation[strlower(direction)]
	for _, texture in next, { button:GetNormalTexture(), button:GetPushedTexture() } do
		SetArrow(texture, rotation)
		texture:ClearAllPoints()
		texture:Point('CENTER')
		texture:Size(12)
	end

	local highlight = button:GetHighlightTexture()
	highlight:SetTexture(E.media.blankTex)
	highlight:SetVertexColor(1, 1, 1, .25)
	highlight:SetRotation(0)
	highlight:SetInside(button.backdrop)
end

local function HandleSidebarTab(tab)
	for _, region in next, { tab:GetRegions() } do
		if region ~= tab.Icon and region:IsObjectType('Texture') then
			region:SetTexture(E.ClearTexture)
		end
	end

	-- the stats class art sits on the same level as a lowered backdrop
	tab:OffsetFrameLevel(5)

	tab.Icon:Size(32)
	tab:CreateBackdrop()
	tab.backdrop:SetOutside(tab.Icon, 1, 1)
	tab:StyleButton()

	-- the tab is 42px, fit the state textures to the icon
	for _, texture in next, { tab.hover, tab.pushed, tab.checked } do
		texture:SetAllPoints(tab.Icon)
	end
end

local function UpdateStatsChild(child)
	if child.Title then
		if not child.IsSkinned then
			HandleCategory(child)
			child.IsSkinned = true
		end
	else
		if not child.shade then
			child.Background:SetAlpha(0)

			child.shade = child:CreateTexture(nil, 'BORDER')
			child.shade:SetAllPoints()
			child.shade:SetColorTexture(1, 1, 1, 0.1)
		end

		child.shade:SetShown(child.Background:IsShown()) -- blizzard alternates it per row

		local icon = child.Icon
		local texture = icon and RESISTANCE_ICONS[icon:GetAtlas()]
		if texture then -- resistances, the bordered atlas and its size come back on every init
			icon:SetTexture(texture)
			icon:Size(18)

			S:HandleIcon(icon, true)
		end
	end
end

local function UpdateStats(frame)
	frame:ForEachFrame(UpdateStatsChild)
end

local function HandleStatsPane(pane)
	pane:StripTextures()

	if pane.ClassBackground then -- only the player pane has it, set again through SetAtlas on spec changes
		pane.ClassBackground:SetAlpha(0)
	end

	S:HandleTrimScrollBar(pane.ScrollBar, nil, true)
	pane.ScrollBox:ClearEdgeFade()
	hooksecurefunc(pane.ScrollBox, 'Update', UpdateStats)
end

-- Blizzard sets the icon back to 36px on every init
local function EquipmentManagerPane_InitButton(button)
	button.icon:ClearAllPoints()
	button.icon:Point('TOPLEFT', E.Border, -E.Border)
	button.icon:Point('BOTTOMLEFT', E.Border, E.Border)
	button.icon:Width(button:GetHeight() - (E.Border * 2))
end

-- Reputation, Currency, Skills and Statistics lists share the same header / sub header / entry layout
local function HandleListHeader(header)
	for _, region in next, { header:GetRegions() } do
		if region ~= header.StateIcon and region:IsObjectType('Texture') then -- keep the Blizzard plus / minus
			region:SetTexture(E.ClearTexture)
		end
	end

	header:CreateBackdrop('Transparent')
	header.backdrop:SetInside(header, 0, 1)
end

local function HandleListEntry(child)
	local content = child.Content
	if content then
		local highlight = content.BackgroundHighlight
		if highlight then
			for _, region in next, highlight.TextureRegions do
				region:SetTexture(E.media.blankTex)
			end
		end

		local bar = content.ReputationBar or content.SkillsBar
		if bar then
			HandleColoredProgressBar(bar)
		end

		local icon = content.CurrencyIcon
		if icon then
			S:HandleIcon(icon)
		end
	end

	local collapseButton = child.ToggleCollapseButton -- sub headers only
	if collapseButton then
		hooksecurefunc(collapseButton, 'RefreshIcon', UpdateToggleCollapseButton)
		UpdateToggleCollapseButton(collapseButton)
	end
end

local function UpdateListChild(child)
	if child.IsSkinned then return end

	if child.StateIcon then
		HandleListHeader(child)
	else
		HandleListEntry(child)
	end

	child.IsSkinned = true
end

local function UpdateList(frame)
	frame:ForEachFrame(UpdateListChild)
end

local function HandleListFrame(frame, ignoreUpdates)
	for _, child in next, { frame.ScrollBox:GetChildren() } do
		child:StripTextures()
	end

	S:HandleTrimScrollBar(frame.ScrollBar, ignoreUpdates, true)
	hooksecurefunc(frame.ScrollBox, 'Update', UpdateList)
end

-- CharacterFrameSidePaneTemplate: on the right side
local function SidePane_AcquireRow(pane)
	for row in pane.rowPools:EnumerateActive() do
		if not row.IsSkinned then
			if row.Background then
				HandleCategory(row)
			elseif row.IconSlot then
				row.IconSlot:SetAlpha(0)
				S:HandleIcon(row.Icon, true)
			end

			row.IsSkinned = true
		end
	end
end

local function HandleSidePane(pane)
	pane:StripTextures()
	pane.Divider:SetAlpha(0)
	pane.Title:FontTemplate(nil, 14)

	S:HandleTrimScrollBar(pane.DescriptionScrollBar, nil, true)
	hooksecurefunc(pane, 'AcquireRow', SidePane_AcquireRow)
end

-- Mists, Wrath, TBC and Vanilla
local function HandleItemButtonQuality(button, rarity)
	local r, g, b = E:GetItemQualityColor(rarity and rarity > 1 and rarity)
	button:SetBackdropBorderColor(r, g, b)
end

local function PaperDollItemButtonQuality(button)
	if not button.SetBackdropBorderColor then return end -- bag bar slots run this too, no backdrop when the bag bar is off

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

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup
	TokenFramePopup:ClearAllPoints()
	TokenFramePopup:Point('TOPLEFT', _G.TokenFrame, 'TOPRIGHT', E.Mists and 1 or -31, E.Mists and 0 or -12)
	TokenFramePopup:StripTextures()
	TokenFramePopup:SetTemplate('Transparent')

	S:HandleCheckBox(_G.TokenFramePopupInactiveCheckbox)
	S:HandleCheckBox(_G.TokenFramePopupBackpackCheckbox)

	local TokenFrameContainer = _G.TokenFrameContainer
	if not TokenFrameContainer.buttons then return end -- created on the first OnShow

	for _, button in next, TokenFrameContainer.buttons do
		button.highlight:Kill()
		button.categoryLeft:Kill()
		button.categoryRight:Kill()

		if E.Mists then
			button.categoryMiddle:Kill()
		end

		if not button.backdrop then
			button:CreateBackdrop(nil, nil, nil, true)
		end

		if E.Wrath and button.itemID == HONOR_CURRENCY then -- Blizzard crops the honor icon too
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
				tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', E.Mists and -10 or 1, E.Mists and 0 or 76)
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
		local frame = _G[name..i]
		local icon, text = frame:GetRegions()
		frame:Size(24)
		frame:SetTemplate()

		if i ~= 1 then
			frame:ClearAllPoints()
			frame:Point('TOP', _G[name..(i - 1)], 'BOTTOM', 0, -1)
		end

		icon:SetInside()
		icon:SetTexCoord(unpack(ResistanceCoords[i]))
		icon:SetDrawLayer('ARTWORK')

		text:SetDrawLayer('OVERLAY')
	end
end

-- Retail, Forever and Mists
local function SkinPaperDollFrame(CharacterFrame)
	for _, Slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
		if Slot:IsObjectType('Button') or Slot:IsObjectType('ItemButton') then
			Slot:StripTextures()
			Slot:SetTemplate()
			Slot:StyleButton()

			S:HandleIcon(Slot.icon)
			Slot.icon:SetInside()

			if Slot.ignoreTexture then -- the Forever ammo slot has none
				Slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
			end

			if E.Modern then -- the classic slot update never shows it
				S:HandleIconBorder(Slot.IconBorder)
			end

			if not E.Forever then -- Forever anchors them per flyout direction, PopoutButton_RefreshVisualState sizes them
				if Slot.popoutButton:GetPoint() == 'TOP' then
					Slot.popoutButton:Point('TOP', Slot, 'BOTTOM', 0, 2)
				else
					Slot.popoutButton:Point('LEFT', Slot, 'RIGHT', -2, 0)
				end
			end

			E:RegisterCooldown(_G[Slot:GetName()..'Cooldown']) -- the ammo slot only has the named cooldown

			if Slot.HasPaperDollAzeriteItemOverlay then
				hooksecurefunc(Slot, 'DisplayAsAzeriteItem', UpdateAzeriteItem)
				hooksecurefunc(Slot, 'DisplayAsAzeriteEmpoweredItem', UpdateAzeriteEmpoweredItem)
			end
		end
	end

	if E.Forever then -- pull the slot columns to the pane edge and center them on the model scene
		_G.CharacterHeadSlot:Point('TOPLEFT', CharacterFrame.LeftPaneHost, 6, -55)
		_G.CharacterHandsSlot:Point('TOPRIGHT', CharacterFrame.LeftPaneHost, -6, -55)
		_G.CharacterMainHandSlot:NudgePoint(nil, -24) -- (30-24: 6): weapon row, x depends on the ranged slot being shown

		hooksecurefunc('EquipmentFlyoutPopoutButton_RefreshVisualState', PopoutButton_RefreshVisualState)
	elseif E.Mists then
		local CharacterMainHandSlot = _G.CharacterMainHandSlot
		CharacterMainHandSlot:ClearAllPoints()
		CharacterMainHandSlot:Point('BOTTOMLEFT', _G.PaperDollItemsFrame, 'BOTTOMLEFT', 106, 10)
	end

	--Give character frame model backdrop it's color back
	for _, corner in next, { 'TopLeft', 'TopRight', 'BotLeft', 'BotRight' } do
		local bg = _G['CharacterModelFrameBackground'..corner]
		bg:SetDesaturated(false)
		bg.ignoreDesaturated = true -- so plugins can prevent this if they want.

		hooksecurefunc(bg, 'SetDesaturated', BackdropDesaturated)
	end

	_G.CharacterLevelText:FontTemplate()

	if E.Forever then -- Forever level info
		local LevelTextBackground = _G.CharacterLevelTextBackground
		LevelTextBackground:SetAlpha(0)
		LevelTextBackground:CreateBackdrop()
		hooksecurefunc('PaperDollFrame_SetLevel', SetLevel)
	end

	if E.Modern then
		_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)
		ColorizeStatPane(_G.CharacterStatsPane.ItemLevelFrame)

		if not E.OtherAddons.DejaCharacterStats then
			hooksecurefunc('PaperDollFrame_UpdateStats', PaperDollUpdateStats)

			StatsPane('EnhancementsCategory')
			StatsPane('ItemLevelCategory')
			StatsPane('AttributesCategory')
		end
	else
		S:HandleTrimScrollBar(_G.CharacterStatsPane.ScrollBar)

		for i = 1, 7 do
			local frame = _G['CharacterStatsPaneCategory'..i]
			frame:StripTextures()
			frame:SetTemplate('Transparent')

			frame.Toolbar = _G['CharacterStatsPaneCategory'..i..'Toolbar']
			S:HandleButton(frame.Toolbar, nil, nil, true)

			local name = _G['CharacterStatsPaneCategory'..i..'NameText']
			name:ClearAllPoints()
			name:Point('CENTER', frame.Toolbar)

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

		hooksecurefunc('PaperDollFrame_SetResistance', PaperDollFrameSetResistance)
	end

	if E.Forever then -- Forever lists the stats in scroll boxes, the pane above only feeds them
		HandleStatsPane(_G.CharacterStatsPaneScrollBox)
		HandleStatsPane(_G.CharacterStatsPanePetScrollBox)
	end

	_G.EquipmentFlyoutFrameHighlight:StripTextures()
	_G.EquipmentFlyoutFrameButtons.bg1:SetAlpha(0)
	_G.EquipmentFlyoutFrameButtons:DisableDrawLayer('ARTWORK')

	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.NextButton)

	hooksecurefunc('EquipmentFlyout_SetBackgroundTexture', EquipmentUpdateNavigation)
	hooksecurefunc('EquipmentFlyout_UpdateItems', EquipmentUpdateItems) -- Swap item flyout frame (shown when holding alt over a slot)

	if not E.Modern then
		hooksecurefunc('EquipmentFlyout_DisplayButton', EquipmentItemButtonQuality)
	end

	-- Icon in upper right corner of character frame
	_G.CharacterFramePortrait:Kill()

	local TitleManagerPane = _G.PaperDollFrame.TitleManagerPane
	local EquipmentManagerPane = _G.PaperDollFrame.EquipmentManagerPane
	for _, scrollbar in next, { EquipmentManagerPane.ScrollBar, TitleManagerPane.ScrollBar } do
		S:HandleTrimScrollBar(scrollbar)
	end

	--Strip Textures
	for _, object in next, { _G.CharacterModelScene, _G.CharacterStatsPane, _G.CharacterFrameInset, _G.CharacterFrameInsetRight, _G.PaperDollSidebarTabs } do -- Forever has no insets
		object:StripTextures()
	end

	--Re-add the overlay texture which was removed right above via StripTextures
	local CharacterModelScene = _G.CharacterModelScene
	if E.Forever then -- Forever overlay is an unnamed atlas without the per race alpha
		CharacterModelScene.BackgroundOverlay:SetColorTexture(0, 0, 0, 0.5)

		-- blizzard fills the whole pane behind the slots, box it in between the slot columns like retail
		CharacterModelScene:ClearAllPoints()
		CharacterModelScene:Point('TOPLEFT', CharacterFrame.LeftPaneHost, 46, -31)
		CharacterModelScene:Point('BOTTOMRIGHT', CharacterFrame.LeftPaneHost, -46, 46)
		CharacterModelScene:CreateBackdrop()

		local HappinessInfo = _G.PetPaperDollPetHappinessInfo
		HappinessInfo:ClearAllPoints()
		HappinessInfo:Point('TOPLEFT', CharacterModelScene, 6, -6)
		hooksecurefunc(HappinessInfo, 'UpdateHappiness', HappinessInfo_UpdateHappiness)
		hooksecurefunc('PaperDollFrame_ShowSidebar', ShowSidebar)

		-- race art is a 212x246 piece plus 19px right and 40px bottom strips, keep that ratio instead of blizzards 80x130 strips
		local BackgroundTopLeft, BackgroundTopRight, BackgroundBotLeft, BackgroundBotRight = CharacterModelScene.BackgroundTopLeft, CharacterModelScene.BackgroundTopRight, CharacterModelScene.BackgroundBotLeft, CharacterModelScene.BackgroundBotRight
		BackgroundTopLeft:Point('BOTTOMRIGHT', CharacterModelScene, 'BOTTOMRIGHT', -25, 54)
		BackgroundTopRight:Width(25)
		BackgroundTopRight:Point('BOTTOMRIGHT', CharacterModelScene, 'BOTTOMRIGHT', 0, 54)
		BackgroundBotLeft:Height(54)
		BackgroundBotLeft:Point('BOTTOMRIGHT', CharacterModelScene, 'BOTTOMRIGHT', -25, 0)
		BackgroundBotRight:Size(25, 54)
	else
		_G.CharacterModelFrameBackgroundOverlay:SetColorTexture(0, 0, 0)
		CharacterModelScene:CreateBackdrop()
		CharacterModelScene.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
		CharacterModelScene.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)
	end

	S:HandleModelSceneControlButtons(CharacterModelScene.ControlFrame)

	if E.Forever then
		HandleColoredProgressBar(_G.PetPaperDollFrameExpBar) -- lives in the model scene
	end

	--Titles
	hooksecurefunc(TitleManagerPane.ScrollBox, 'Update', TitleManagerPane_Update)

	--Equipement Manager
	hooksecurefunc(EquipmentManagerPane.ScrollBox, 'Update', EquipmentManagerPane_Update)

	if E.Forever then -- Forever outfit cards with three slice buttons
		EquipmentManagerPane:StripTextures() -- Border and the unnamed scroll line under the list
		hooksecurefunc('PaperDollEquipmentManagerPane_InitButton', EquipmentManagerPane_InitButton)

		S:HandleButton(EquipmentManagerPane.EquipSet, nil, nil, nil, true)
		S:HandleButton(EquipmentManagerPane.SaveSet, nil, nil, nil, true)
		S:HandleButton(EquipmentManagerPane.NewSet, nil, nil, nil, true, nil, nil, nil, true)
		EquipmentManagerPane.NewSet.StateTexture:SetAlpha(0)
	else
		S:HandleButton(_G.PaperDollFrameEquipSet)
		S:HandleButton(_G.PaperDollFrameSaveSet)
	end

	_G.GearManagerPopupFrame:HookScript('OnShow', GearManagerPopupFrame_OnShow)

	if E.Forever then -- Forever sidebar tabs are plain check buttons with an icon
		for i = 1, 3 do
			HandleSidebarTab(_G['PaperDollSidebarTab'..i])
		end
	else
		hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', FixSidebarTabCoords)
	end

	if E.Modern then
		hooksecurefunc('PaperDollItemSlotButton_Update', PaperDollItemSlotButtonUpdate)
	else -- the classic slot update never shows the IconBorder
		hooksecurefunc('PaperDollItemSlotButton_Update', PaperDollItemButtonQuality)
	end
end

-- Wrath, TBC and Vanilla
local function SkinClassicPaperDollFrame()
	_G.PaperDollFrame:StripTextures()

	if not E.Classic then -- vanilla has neither dropdown
		S:HandleDropDownBox(_G.PlayerTitleDropdown, 160)
		S:HandleDropDownBox(_G.PlayerStatFrameLeftDropdown, 110)
		S:HandleDropDownBox(_G.PlayerStatFrameRightDropdown, 110)
	end

	-- Seasonal
	if E.ClassicSOD then
		local runeButton = _G.RuneFrameControlButton
		S:HandleButton(runeButton, true)

		local runeIcon = runeButton:CreateTexture(nil, 'ARTWORK')
		runeIcon:SetTexture(134419) -- Interface\Icons\INV_Misc_Rune_06
		runeIcon:SetTexCoords()
		runeIcon:SetInside()
	end

	_G.CharacterModelFrame:CreateBackdrop('Transparent')
	_G.CharacterModelFrame.backdrop:Point('TOPLEFT', -2, 4)
	_G.CharacterModelFrame.backdrop:Point('BOTTOMRIGHT', _G.CharacterAttributesFrame, 2, -10)

	S:HandleRotateButton(_G.CharacterModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.CharacterModelFrameRotateRightButton)

	_G.CharacterModelFrameRotateLeftButton:Point('TOPLEFT', E.Classic and 3 or 0, E.Classic and -3 or 2) -- tbc and wrath keep it clear of the title dropdown
	_G.CharacterModelFrameRotateRightButton:Point('TOPLEFT', _G.CharacterModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	_G.CharacterAttributesFrame:StripTextures()

	HandleResistanceFrame('MagicResFrame')

	for _, slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
		if slot:IsObjectType('Button') and slot.Count then -- skips GearManagerToggleButton and RuneFrameControlButton
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

	hooksecurefunc('PaperDollItemSlotButton_Update', PaperDollItemButtonQuality)
end

local function SkinPetPaperDollFrame()
	if E.Mists then
		local PetModelFrame = _G.PetModelFrame
		PetModelFrame:StripTextures()
		_G.PetModelFrameShadowOverlay:StripTextures()

		PetModelFrame:CreateBackdrop()
		PetModelFrame.backdrop:Point('TOPLEFT', E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
		PetModelFrame.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

		S:HandleStatusBar(_G.PetPaperDollFrameExpBar)
		S:HandleRotateButton(_G.PetModelFrameRotateLeftButton)
		S:HandleRotateButton(_G.PetModelFrameRotateRightButton)
	else
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
	end
end

local function SkinReputationFrame()
	local ReputationFrame = _G.ReputationFrame
	ReputationFrame:StripTextures()

	if E.Modern then
		if E.Forever then
			HandleListFrame(ReputationFrame)
		else
			S:HandleTrimScrollBar(ReputationFrame.ScrollBar)
		end

		S:HandleDropDownBox(ReputationFrame.filterDropdown)

		local DetailFrame = ReputationFrame.ReputationDetailFrame
		if E.Forever then -- Forever side pane with a standing bar
			HandleSidePane(DetailFrame)
			HandleColoredProgressBar(DetailFrame.StandingBar)
		else
			DetailFrame:StripTextures()
			DetailFrame:SetTemplate('Transparent')
			DetailFrame.CloseButton:StripTextures()
			S:HandleCloseButton(DetailFrame.CloseButton)
		end

		S:HandleCheckBox(DetailFrame.AtWarCheckbox)
		S:HandleCheckBox(DetailFrame.MakeInactiveCheckbox)
		S:HandleCheckBox(DetailFrame.WatchFactionCheckbox)
		S:HandleButton(DetailFrame.ViewRenownButton, nil, nil, nil, true)

		if E.Retail then
			S:HandleTrimScrollBar(DetailFrame.ScrollingDescriptionScrollBar)
			hooksecurefunc(ReputationFrame.ScrollBox, 'Update', UpdateFactionSkins)
		end
	else
		if E.TBC or E.Classic then -- the bar itself is the status bar, headers are separate buttons
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
				S:HandleCollapseTexture(factionHeader, nil, true)

				factionWar:StripTextures()
				factionWar:Point('LEFT', factionBar, 'RIGHT', 0, 0)

				factionWar.Icon = factionWar:CreateTexture(nil, 'OVERLAY')
				factionWar.Icon:Point('LEFT', 6, -8)
				factionWar.Icon:Size(32)
				factionWar.Icon:SetTexture([[Interface\Buttons\UI-CheckBox-SwordCheck]])
			end
		else
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
		end

		_G.ReputationListScrollFrame:StripTextures()
		S:HandleScrollBar(_G.ReputationListScrollFrameScrollBar)

		_G.ReputationDetailFrame:StripTextures()
		_G.ReputationDetailFrame:SetTemplate('Transparent')
		_G.ReputationDetailFrame:Point('TOPLEFT', ReputationFrame, 'TOPRIGHT', E.Mists and 1 or -31, E.Mists and 0 or -12)

		S:HandleCloseButton(_G.ReputationDetailCloseButton)
		_G.ReputationDetailCloseButton:Point('TOPRIGHT', 2, 2)

		S:HandleCheckBox(_G.ReputationDetailAtWarCheckbox)
		S:HandleCheckBox(_G.ReputationDetailInactiveCheckbox)
		S:HandleCheckBox(_G.ReputationDetailMainScreenCheckbox)
	end
end

local function SkinTokenFrame()
	local TokenFrame = _G.TokenFrame
	if E.Modern then
		if E.Forever then
			HandleListFrame(TokenFrame, true) -- updates to this can taint transferring currencies

			local DetailFrame = TokenFrame.DetailFrame
			HandleSidePane(DetailFrame)
			S:HandleCheckBox(DetailFrame.InactiveCheckbox)
			S:HandleCheckBox(DetailFrame.BackpackCheckbox)
			S:HandleButton(DetailFrame.CurrencyTransferToggleButton)
		else
			S:HandleTrimScrollBar(TokenFrame.ScrollBar, true) -- updates to this can taint transferring currencies

			-- Currency Frame
			local TokenFramePopup = _G.TokenFramePopup
			TokenFramePopup:StripTextures()
			TokenFramePopup:SetTemplate('Transparent')
			TokenFramePopup:Point('TOPLEFT', TokenFrame, 'TOPRIGHT', 3, -28)

			S:HandleDropDownBox(TokenFrame.filterDropdown)
			--S:HandleButton(_G.TokenFrame.CurrencyTransferLogToggleButton) -- No no no, this taints

			TokenFrame.CurrencyTransferLogToggleButton.NormalTexture:SetTexture(E.Media.Textures.Copy)
			TokenFrame.CurrencyTransferLogToggleButton.PushedTexture:SetTexture(E.Media.Textures.Copy)
			TokenFrame.CurrencyTransferLogToggleButton.PushedTexture:SetVertexColor(unpack(E.media.rgbvaluecolor))

			S:HandleCheckBox(TokenFramePopup.InactiveCheckbox)
			S:HandleCheckBox(TokenFramePopup.BackpackCheckbox)
			S:HandleButton(TokenFramePopup.CurrencyTransferToggleButton)

			S:HandleCloseButton(TokenFramePopup['$parent.CloseButton']) -- yes, that is the parentKey

			hooksecurefunc(TokenFrame.ScrollBox, 'Update', UpdateTokenSkins)
		end

		S:HandlePortraitFrame(_G.CurrencyTransferLog)
		S:HandleTrimScrollBar(_G.CurrencyTransferLog.ScrollBar)
		hooksecurefunc(_G.CurrencyTransferLog.ScrollBox, 'Update', UpdateCurrencyTransferLogLines)

		-- Currency Transfer
		local currencyTransfer = _G.CurrencyTransferMenu
		currencyTransfer:StripTextures()
		currencyTransfer:SetTemplate('Transparent')

		S:HandleCloseButton(currencyTransfer.CloseButton)
		S:HandleDropDownBox(currencyTransfer.Content.SourceSelector.Dropdown)
		S:HandleButton(currencyTransfer.Content.AmountSelector.MaxQuantityButton)
		S:HandleButton(currencyTransfer.Content.ConfirmButton)
		S:HandleButton(currencyTransfer.Content.CancelButton)
		S:HandleIcon(currencyTransfer.Content.SourceBalancePreview.BalanceInfo.CurrencyIcon)
		S:HandleIcon(currencyTransfer.Content.PlayerBalancePreview.BalanceInfo.CurrencyIcon)

		local transferInputBox = currencyTransfer.Content.AmountSelector.InputBox
		S:HandleEditBox(transferInputBox)
		transferInputBox.backdrop:ClearAllPoints()
		transferInputBox.backdrop:Point('TOPLEFT', 0, -3)
		transferInputBox.backdrop:Point('BOTTOMRIGHT', -1, 8)
	else
		TokenFrame:StripTextures()

		if E.Wrath then
			S:HandleButton(_G.TokenFrameCancelButton)

			local _, _, _, closeFrameButton = TokenFrame:GetChildren() -- Container, MoneyFrame, CancelButton, unnamed UIPanelCloseButton
			closeFrameButton:Kill() -- sits on CharacterFrameCloseButton
		end

		S:HandleScrollBar(_G.TokenFrameContainerScrollBar)
		S:HandleCloseButton(_G.TokenFramePopupCloseButton, _G.TokenFramePopup)

		hooksecurefunc(_G.TokenFrameContainer, 'update', UpdateCurrencySkins)
		hooksecurefunc('TokenFrame_Update', UpdateCurrencySkins)
	end
end

local function SkinSkillFrame()
	if E.Forever then
		local SkillsFrame = _G.SkillsFrame
		HandleListFrame(SkillsFrame)
		HandleSidePane(SkillsFrame.SkillDetailFrame)
		HandleColoredProgressBar(SkillsFrame.SkillDetailFrame.RankBar)
	elseif not (E.Modern or E.Mists) then -- mists has no skill tab
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
	end
end

local function SkinPVPFrame()
	if E.Forever then
		local PVPRankFrame = _G.PVPRankFrame
		PVPRankFrame.MainInfoFrame.Line:SetAlpha(0)
		HandleSidePane(PVPRankFrame.DetailFrame)
	elseif E.Classic then
		-- Honor Tab
		_G.HonorFrame:StripTextures()

		_G.HonorFrameProgressBar:StripTextures()
		_G.HonorFrameProgressBar:Height(22)
		_G.HonorFrameProgressBar:SetParent(_G.HonorFrame)
		_G.HonorFrameProgressBar:CreateBackdrop()
		_G.HonorFrameProgressBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(_G.HonorFrameProgressBar)
	elseif E.Wrath or E.TBC then
		-- Honor/Arena/PvP Tab
		local PVPFrame = _G.PVPFrame
		if E.Wrath then -- its own window, tbc shows it as a character frame tab
			S:HandleFrame(PVPFrame, true, nil, 11, -12, -32, 76)
		else
			PVPFrame:StripTextures(true)
		end

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

		if E.Wrath then
			-- why two close buttons? matches BattlefieldFrameCloseButton
			S:HandleCloseButton(_G.PVPParentFrameCloseButton)
			_G.PVPParentFrameCloseButton:Point('TOPRIGHT', -30, -8)

			for i = 1, 2 do
				S:HandleTab(_G['PVPParentFrameTab'..i])
			end
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
end

function S:Blizzard_UIPanels_Game()
	-- General
	local CharacterFrame = _G.CharacterFrame
	if E.Modern or E.Mists then
		S:HandlePortraitFrame(CharacterFrame)
	else
		S:HandleFrame(CharacterFrame, true, nil, 11, -12, -32, 76)
	end

	if E.Forever then -- Forever splits the frame into two panes with side tabs
		CharacterFrame.LeftPaneHost:StripTextures()

		local RightPaneHost = CharacterFrame.RightPaneHost
		RightPaneHost:StripTextures()
		RightPaneHost:CreateBackdrop('Transparent')
		RightPaneHost.backdrop:SetInside(RightPaneHost, 6, 6)
		RightPaneHost.StoneBg:SetAlpha(0) -- set again through SetAtlas and SetShown on tab changes

		local divider = RightPaneHost:GetChildren() -- unnamed frame on the left edge (The ugly divider strip)
		divider:StripTextures()

		S:HandleNextPrevButton(CharacterFrame.RightPaneToggleButton, 'left', nil, true)
		CharacterFrame.RightPaneToggleButton:SetTemplate()
		hooksecurefunc(CharacterFrame, 'UpdateRightPaneToggleButton', UpdateRightPaneToggleButton)
		UpdateRightPaneToggleButton(CharacterFrame)

		for _, tab in next, CharacterFrame.ModeTabs.Tabs do
			S:HandleLargeSideTab(tab)
		end

		hooksecurefunc(CharacterFrame, 'UpdateTabLayout', UpdateTabLayout)
		UpdateTabLayout(CharacterFrame)
	elseif E.Retail then
		--Handle Tabs at bottom of character frame
		local i = 1
		local tab, prev = _G['CharacterFrameTab'..i]
		while tab do
			S:HandleTab(tab)

			tab:ClearAllPoints()

			if prev then -- Reposition Tabs
				tab:Point('TOPLEFT', prev, 'TOPRIGHT', -5, 0)
			else
				tab:Point('TOPLEFT', _G.CharacterFrame, 'BOTTOMLEFT', -3, 0)
			end

			prev = tab

			i = i + 1
			tab = _G['CharacterFrameTab'..i]
		end
	else
		for i = 1, #CHARACTERFRAME_SUBFRAMES do
			S:HandleTab(_G['CharacterFrameTab'..i])
		end

		-- Reposition Tabs
		hooksecurefunc((E.TBC or E.Classic) and 'PetTab_Update' or 'PetPaperDollFrame_UpdateIsAvailable', HandleTabs)
		HandleTabs()
	end

	if E.Modern or E.Mists then
		SkinPaperDollFrame(CharacterFrame)
	else
		SkinClassicPaperDollFrame()
	end

	if not E.Modern then -- Retail has no pet tab, Forever shows the pet in the model scene
		SkinPetPaperDollFrame()
	end

	SkinReputationFrame()

	if not (E.TBC or E.Classic) then -- tbc and vanilla have no currency tab
		SkinTokenFrame()
	end

	SkinSkillFrame()
	SkinPVPFrame()
end

function S:Blizzard_Statistics()
	HandleListFrame(_G.StatisticsFrame)
end
