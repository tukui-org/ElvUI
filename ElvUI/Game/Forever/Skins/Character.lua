local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, next, strlower, strmatch = unpack, next, strlower, strmatch
local hooksecurefunc = hooksecurefunc

local FLYOUT_LOCATIONS = {
	[0xFFFFFFFF] = 'PLACEINBAGS',
	[0xFFFFFFFE] = 'IGNORESLOT',
	[0xFFFFFFFD] = 'UNIGNORESLOT'
}

local function SetArrow(texture, rotation)
	texture:SetTexture(E.Media.Textures.ArrowUp)
	texture:SetTexCoord(0, 1, 0, 1)
	texture:SetRotation(rotation)
end

local function HandleHighlight(button)
	local highlight = button:GetHighlightTexture()
	highlight:SetTexture(E.media.blankTex)
	highlight:SetVertexColor(1, 1, 1, .25)
	highlight:SetRotation(0)
	highlight:SetInside()
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

	HandleHighlight(button)
	button:GetHighlightTexture():SetInside(button.backdrop)
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

local function BackdropDesaturated(background, value)
	if value and background.ignoreDesaturated then
		background:SetDesaturated(false)
	end
end

local resistanceIcons = { -- atlas suffix to the plain SpellSchoolIcon index
	Holy = 2,
	Fire = 3,
	Nature = 4,
	Frost = 5,
	Shadow = 6,
	Arcane = 7
}

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
		local atlas = icon and icon:GetAtlas()
		if atlas then -- resistances, the bordered atlas and its size come back on every init
			local school = resistanceIcons[strmatch(atlas, 'Resistance%-(%a+)$')]
			if school then
				icon:SetTexture([[Interface\PaperDollInfoFrame\SpellSchoolIcon]]..school)
				icon:Size(18)
				S:HandleIcon(icon, true)
			end
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

local function TitleManagerPane_UpdateChild(child)
	if not child.IsSkinned then
		child:DisableDrawLayer('BACKGROUND')
		child.IsSkinned = true
	end
end

local function TitleManagerPane_Update(frame)
	frame:ForEachFrame(TitleManagerPane_UpdateChild)
end

local function EquipmentManagerPane_UpdateChild(child)
	if not child.IsSkinned then
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

		child.HighlightBar:SetColorTexture(1, 1, 1, .25)
		child.SelectedBar:SetColorTexture(0.8, 0.8, 0.8, .25)

		child.IsSkinned = true
	end
end

-- Blizzard sets the icon back to 36px on every init
local function EquipmentManagerPane_InitButton(button)
	button.icon:ClearAllPoints()
	button.icon:Point('TOPLEFT', E.Border, -E.Border)
	button.icon:Point('BOTTOMLEFT', E.Border, E.Border)
	button.icon:Width(button:GetHeight() - (E.Border * 2))
end

local function EquipmentManagerPane_Update(frame)
	frame:ForEachFrame(EquipmentManagerPane_UpdateChild)
end

local function GearManagerPopupFrame_OnShow(frame)
	if not frame.IsSkinned then -- set by HandleIconSelectionFrame
		S:HandleIconSelectionFrame(frame, nil, nil, 'GearManagerPopupFrame')
	end
end

-- Equipment Flyout: frame gets rebuilt on every update
local function EquipmentDisplayButton(button, index)
	if not button.isHooked then
		button:SetNormalTexture(E.ClearTexture)
		button:SetPushedTexture(E.ClearTexture)
		button:SetTemplate()
		button:StyleButton()

		button.icon:SetInside()
		button.icon:SetTexCoords()

		S:HandleIconBorder(button.IconBorder)

		if (index - 1) % 5 == 0 then -- first button of a row, the others chain to it (37px rows with a 5px gap)
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
end

local function EquipmentUpdateNavigation()
	local flyout = _G.EquipmentFlyoutFrame
	local navi = flyout.NavigationFrame
	navi:ClearAllPoints()
	navi:Point('TOPLEFT', flyout.buttonFrame, 'BOTTOMLEFT', 0, -E.Border - E.Spacing)
	navi:Point('TOPRIGHT', flyout.buttonFrame, 'BOTTOMRIGHT', 0, -E.Border - E.Spacing)

	navi:StripTextures()
	navi:SetTemplate('Transparent')
end

-- Reputation, Currency, Skills and Statistics lists share the same header / sub header / entry layout
local function UpdateToggleCollapseButton(button)
	local header = button:GetHeader()

	local collapsed
	if header.IsCollapsed then
		collapsed = header:IsCollapsed()
	elseif header.treeNode then
		collapsed = header.treeNode:IsCollapsed()
	end

	local tex = collapsed and E.Media.Textures.PlusButton or E.Media.Textures.MinusButton
	button:SetNormalTexture(tex)
	button:SetPushedTexture(tex)
end

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

local function HandleListFrame(frame)
	for _, child in next, { frame.ScrollBox:GetChildren() } do
		child:StripTextures()
	end

	S:HandleTrimScrollBar(frame.ScrollBar, nil, true)
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

function S:Blizzard_UIPanels_Game()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	local CharacterFrame = _G.CharacterFrame
	S:HandlePortraitFrame(CharacterFrame)

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

	-- Paper Doll
	for _, Slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
		if Slot:IsObjectType('Button') or Slot:IsObjectType('ItemButton') then
			Slot:StripTextures()
			Slot:SetTemplate()
			Slot:StyleButton()

			S:HandleIcon(Slot.icon)
			Slot.icon:SetInside()

			S:HandleIconBorder(Slot.IconBorder)

			E:RegisterCooldown(_G[Slot:GetName()..'Cooldown']) -- the ammo slot only has the named cooldown
		end
	end

	-- pull the slot columns to the pane edge and center them on the model scene
	_G.CharacterHeadSlot:Point('TOPLEFT', CharacterFrame.LeftPaneHost, 6, -55)
	_G.CharacterHandsSlot:Point('TOPRIGHT', CharacterFrame.LeftPaneHost, -6, -55)
	_G.CharacterMainHandSlot:NudgePoint(nil, -24) -- (30-24: 6): weapon row, x depends on the ranged slot being shown

	hooksecurefunc('PaperDollItemSlotButton_Update', HandleHighlight)
	hooksecurefunc('EquipmentFlyoutPopoutButton_RefreshVisualState', PopoutButton_RefreshVisualState)

	_G.CharacterFramePortrait:Kill()
	_G.CharacterLevelText:FontTemplate()

	local LevelTextBackground = _G.CharacterLevelTextBackground
	LevelTextBackground:SetAlpha(0)
	LevelTextBackground:CreateBackdrop()
	hooksecurefunc('PaperDollFrame_SetLevel', SetLevel)

	for i = 1, 3 do
		HandleSidebarTab(_G['PaperDollSidebarTab'..i])
	end

	_G.PaperDollSidebarTabs:StripTextures()

	-- Model
	local CharacterModelScene = _G.CharacterModelScene
	CharacterModelScene:StripTextures()
	CharacterModelScene.BackgroundOverlay:SetColorTexture(0, 0, 0, 0.5) -- re-add the overlay which was just stripped

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

	S:HandleModelSceneControlButtons(CharacterModelScene.ControlFrame)
	HandleColoredProgressBar(_G.PetPaperDollFrameExpBar) -- lives in the model scene

	-- Give character frame model backdrop it's color back
	for _, corner in next, { 'TopLeft', 'TopRight', 'BotLeft', 'BotRight' } do
		local bg = _G['CharacterModelFrameBackground'..corner]
		bg:SetDesaturated(false)
		bg.ignoreDesaturated = true -- so plugins can prevent this if they want.

		hooksecurefunc(bg, 'SetDesaturated', BackdropDesaturated)
	end

	-- Stats
	HandleStatsPane(_G.CharacterStatsPaneScrollBox)
	HandleStatsPane(_G.CharacterStatsPanePetScrollBox)

	-- Titles
	local TitleManagerPane = _G.PaperDollFrame.TitleManagerPane
	S:HandleTrimScrollBar(TitleManagerPane.ScrollBar, nil, true)
	hooksecurefunc(TitleManagerPane.ScrollBox, 'Update', TitleManagerPane_Update)

	-- Equipment Manager
	local EquipmentManagerPane = _G.PaperDollFrame.EquipmentManagerPane
	EquipmentManagerPane:StripTextures() -- Border and the unnamed scroll line under the list
	S:HandleTrimScrollBar(EquipmentManagerPane.ScrollBar, nil, true)

	hooksecurefunc(EquipmentManagerPane.ScrollBox, 'Update', EquipmentManagerPane_Update)
	hooksecurefunc('PaperDollEquipmentManagerPane_InitButton', EquipmentManagerPane_InitButton)

	S:HandleButton(EquipmentManagerPane.EquipSet, nil, nil, nil, true)
	S:HandleButton(EquipmentManagerPane.SaveSet, nil, nil, nil, true)
	S:HandleButton(EquipmentManagerPane.NewSet, nil, nil, nil, true, nil, nil, nil, true)
	EquipmentManagerPane.NewSet.StateTexture:SetAlpha(0)

	_G.GearManagerPopupFrame:HookScript('OnShow', GearManagerPopupFrame_OnShow) -- New icon selection

	-- Equipment Flyout
	local EquipmentFlyoutFrame = _G.EquipmentFlyoutFrame
	EquipmentFlyoutFrame.Highlight:StripTextures()
	EquipmentFlyoutFrame.buttonFrame:DisableDrawLayer('ARTWORK')

	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.NextButton)

	hooksecurefunc('EquipmentFlyout_SetBackgroundTexture', EquipmentUpdateNavigation)
	hooksecurefunc('EquipmentFlyout_UpdateItems', EquipmentUpdateItems) -- Swap item flyout frame (shown when holding alt over a slot)

	-- Reputation
	local ReputationFrame = _G.ReputationFrame
	HandleListFrame(ReputationFrame)
	S:HandleDropDownBox(ReputationFrame.filterDropdown)

	local ReputationDetailFrame = ReputationFrame.ReputationDetailFrame
	HandleSidePane(ReputationDetailFrame)
	HandleColoredProgressBar(ReputationDetailFrame.StandingBar)
	S:HandleCheckBox(ReputationDetailFrame.AtWarCheckbox)
	S:HandleCheckBox(ReputationDetailFrame.MakeInactiveCheckbox)
	S:HandleCheckBox(ReputationDetailFrame.WatchFactionCheckbox)
	S:HandleButton(ReputationDetailFrame.ViewRenownButton, nil, nil, nil, true)

	-- Skills
	local SkillsFrame = _G.SkillsFrame
	HandleListFrame(SkillsFrame)
	HandleSidePane(SkillsFrame.SkillDetailFrame)
	HandleColoredProgressBar(SkillsFrame.SkillDetailFrame.RankBar)

	-- PvP
	local PVPRankFrame = _G.PVPRankFrame
	PVPRankFrame.MainInfoFrame.Line:SetAlpha(0)
	HandleSidePane(PVPRankFrame.DetailFrame)

	-- Currency
	local TokenFrame = _G.TokenFrame
	HandleListFrame(TokenFrame)
	HandleSidePane(TokenFrame.DetailFrame)
	S:HandleCheckBox(TokenFrame.DetailFrame.InactiveCheckbox)
	S:HandleCheckBox(TokenFrame.DetailFrame.BackpackCheckbox)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game')

function S:Blizzard_Statistics()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.character) then return end

	HandleListFrame(_G.StatisticsFrame)
end

S:AddCallbackForAddon('Blizzard_Statistics')
