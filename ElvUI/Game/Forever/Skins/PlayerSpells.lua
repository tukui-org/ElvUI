local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function HandleTalentFrameDialog(dialog)
	dialog:StripTextures()
	dialog:CreateBackdrop('Transparent')

	S:HandleButton(dialog.AcceptButton)
	S:HandleButton(dialog.CancelButton)

	if dialog.DeleteButton then -- edit dialog only
		S:HandleButton(dialog.DeleteButton)
	end

	local editbox = dialog.NameControl.EditBox
	S:HandleEditBox(editbox)
	editbox.backdrop:Point('TOPLEFT', -5, -10)
	editbox.backdrop:Point('BOTTOMRIGHT', 5, 10)
end

local function HandleTreeHeaders(frame)
	for _, header in next, frame.treeHeaders do
		if not header.IsSkinned then
			header.Divider:SetAlpha(0)
			header.Name:FontTemplate(nil, 16)
			header.Text:FontTemplate()
			header.TextBackground:SetAlpha(0)
			header.TextBackground:NudgePoint(4, -6) -- away from the spec icon
			header.TextBackground:CreateBackdrop()
			header.TextBackground.backdrop:OffsetFrameLevel(1, header) -- above the spec icon and ring
			header.Text:SetParent(header.TextBackground.backdrop)

			header.IsSkinned = true
		end
	end
end

local function TalentButtonStateBorder(button, visualState)
	button.BorderSheen:Hide() -- Blizzard reshows it on every state update

	local color = _G.TalentButtonUtil.GetColorForBaseVisualState(visualState)
	button.Icon.backdrop:SetBackdropBorderColor(color:GetRGB())
end

local function HandleTalentButton(button)
	button.Shadow:SetAlpha(0)
	button.StateBorder:SetAlpha(0)
	button.StateBorderHover:Kill()
	button.Icon:RemoveMaskTexture(button.IconMask)
	button.DisabledOverlay:RemoveMaskTexture(button.DisabledOverlayMask)

	S:HandleIcon(button.Icon, true)

	hooksecurefunc(button, 'UpdateStateBorder', TalentButtonStateBorder)

	local visualState = button:GetVisualState()
	if visualState then -- state was applied before the hook existed
		TalentButtonStateBorder(button, visualState)
	end
end

-- Talent buttons are pooled and get a per row frame level
-- so skin them here and keep the backdrop under them
local function UpdateButtonFrameLevel(_, button)
	if not button.IsSkinned then
		HandleTalentButton(button)

		button.IsSkinned = true
	end

	button.Icon.backdrop:OffsetFrameLevel(-1, button)
end

local function CategoryTabSelected(tab, selected)
	if selected then
		tab.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		tab.backdrop:SetBackdropBorderColor(r, g, b)
	end
end

-- Uses square icon tabs (TabSystemButtonArtMixin:SetSquareMode)
local function HandleCategoryTabs(tabSystem)
	for _, tab in next, { tabSystem:GetChildren() } do
		if not tab.backdrop then
			local icon = tab.Icon
			icon:SetTexCoords()
			icon:RemoveMaskTexture(tab.IconMask)

			tab.SquareBackground:SetAlpha(0)
			tab.SquareBackgroundActive:SetAlpha(0)
			tab.SquareBackgroundActiveGlow:SetAlpha(0)

			tab:CreateBackdrop()
			tab.backdrop:SetOutside(icon)

			tab:SetHighlightTexture(E.media.blankTex)

			local highlight = tab:GetHighlightTexture()
			highlight:SetVertexColor(1, 1, 1, .25)
			highlight:SetAllPoints(icon)

			hooksecurefunc(tab, 'SetTabSelected', CategoryTabSelected)
			CategoryTabSelected(tab, tab.isSelected)
		end
	end
end

local function HandleHeroTalents(frame)
	for specFrame in frame.SpecContentFramePool:EnumerateActive() do
		if not specFrame.IsSkinned then
			specFrame.SpecName:FontTemplate(nil, 18)
			specFrame.Description:FontTemplate(nil, 14)
			specFrame.CurrencyFrame.LabelText:FontTemplate()
			specFrame.CurrencyFrame.AmountText:FontTemplate(nil, 18)

			S:HandleButton(specFrame.ActivateButton)
			S:HandleButton(specFrame.ApplyChangesButton)

			specFrame.IsSkinned = true
		end
	end
end

function S:Blizzard_PlayerSpells()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local PlayerSpellsFrame = _G.PlayerSpellsFrame
	S:HandlePortraitFrame(PlayerSpellsFrame)

	-- TalentsFrame
	local TalentsFrame = PlayerSpellsFrame.TalentsFrame
	TalentsFrame.Background:SetAlpha(0)
	TalentsFrame.BackgroundBorder:SetAlpha(0)
	TalentsFrame.DividerHorizontalLeft:SetAlpha(0)
	TalentsFrame.DividerHorizontalRight:SetAlpha(0)
	TalentsFrame.DividerVerticalLeft:SetAlpha(0)
	TalentsFrame.DividerVerticalRight:SetAlpha(0)

	S:HandleButton(TalentsFrame.ApplyButton)
	S:HandleDropDownBox(TalentsFrame.LoadSystem.Dropdown)

	S:HandleButton(TalentsFrame.InspectCopyButton)
	S:HandleButton(TalentsFrame.ActiveSpec.ActivateButton)

	local CurrencyDisplay = TalentsFrame.ClassCurrencyDisplay
	CurrencyDisplay.Border:SetAlpha(0)
	CurrencyDisplay.CurrentAmountContainer:CreateBackdrop()
	CurrencyDisplay.UnspentLabel:FontTemplate(nil, 14)
	CurrencyDisplay.UnspentLabel:ClearAllPoints()
	CurrencyDisplay.UnspentLabel:Point('RIGHT', CurrencyDisplay.CurrentAmountContainer, 'LEFT', -6, 0)
	CurrencyDisplay.CurrentAmountContainer.CurrencyAmount:FontTemplate(nil, 26)

	-- Primary / Secondary spec tabs
	for _, tab in next, { TalentsFrame.TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	hooksecurefunc(TalentsFrame, 'RefreshTreeHeaders', HandleTreeHeaders)
	hooksecurefunc(TalentsFrame, 'UpdateButtonFrameLevel', UpdateButtonFrameLevel)

	S:HandleEditBox(TalentsFrame.SearchBox)
	TalentsFrame.SearchBox.backdrop:Point('TOPLEFT', -4, -5)
	TalentsFrame.SearchBox.backdrop:Point('BOTTOMRIGHT', 0, 5)

	local SearchOptions = TalentsFrame.SearchOptionsDropdown
	S:HandleNextPrevButton(SearchOptions, 'down', nil, true)
	SearchOptions:SetTemplate()
	SearchOptions:ClearAllPoints()
	SearchOptions:Point('LEFT', TalentsFrame.SearchBox, 'RIGHT', 3, 0)
	SearchOptions.Arrow:SetAlpha(0)

	TalentsFrame.SearchPreviewContainer:StripTextures()
	TalentsFrame.SearchPreviewContainer:CreateBackdrop('Transparent')

	local TabSystem = PlayerSpellsFrame.TabSystem
	for _, tab in next, { TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	TabSystem.spacing = -5
	TabSystem:MarkDirty()
	TabSystem:ClearAllPoints()
	TabSystem:Point('TOPLEFT', PlayerSpellsFrame, 'BOTTOMLEFT', -3, 0)

	local ImportDialog = _G.ClassTalentLoadoutImportDialog
	HandleTalentFrameDialog(ImportDialog)
	ImportDialog.ImportControl.InputContainer:StripTextures()
	ImportDialog.ImportControl.InputContainer:CreateBackdrop('Transparent')

	HandleTalentFrameDialog(_G.ClassTalentLoadoutCreateDialog)

	local EditDialog = _G.ClassTalentLoadoutEditDialog
	HandleTalentFrameDialog(EditDialog)

	local check = EditDialog.UsesSharedActionBars.CheckButton
	S:HandleCheckBox(check)
	check:Size(20)
	check.backdrop:SetInside()

	-- Hero Talents
	TalentsFrame.HeroTalentsContainer.HeroSpecLabel:FontTemplate(nil, 16)

	local TalentsSelect = _G.HeroTalentsSelectionDialog
	TalentsSelect:StripTextures()
	TalentsSelect:SetTemplate()
	S:HandleCloseButton(TalentsSelect.CloseButton)
	hooksecurefunc(TalentsSelect, 'ShowDialog', HandleHeroTalents)

	-- SpellBook
	local SpellBookFrame = PlayerSpellsFrame.SpellBookFrame
	S:HandleMaxMinFrame(PlayerSpellsFrame.MaxMinButtonFrame)
	S:HandleEditBox(SpellBookFrame.SearchBox)
	SpellBookFrame.SearchBox:Height(20)
	S:HandleNextPrevButton(SpellBookFrame.SettingsDropdown, 'down', nil, true)
	SpellBookFrame.SettingsDropdown:SetTemplate()
	SpellBookFrame.SettingsDropdown:ClearAllPoints()
	SpellBookFrame.SettingsDropdown:Point('TOPRIGHT', SpellBookFrame, 'TOPRIGHT', -30, -23)
	SpellBookFrame.SearchBox:ClearAllPoints()
	SpellBookFrame.SearchBox:Point('RIGHT', SpellBookFrame.SettingsDropdown, 'LEFT', -5, 0)
	SpellBookFrame.TopBar:Hide()
	SpellBookFrame.BookCornerFlipbook:Hide()

	if E.global.general.disableTutorialButtons then
		SpellBookFrame.HelpPlateButton:Kill()
	else
		SpellBookFrame.HelpPlateButton.Ring:Hide()
	end

	HandleCategoryTabs(SpellBookFrame.CategoryTabSystem)
	hooksecurefunc(SpellBookFrame.CategoryTabSystem, 'AddTab', HandleCategoryTabs)

	local PagedSpellsFrame = SpellBookFrame.PagedSpellsFrame
	PagedSpellsFrame.View1:DisableDrawLayer('OVERLAY')

	local PagingControls = PagedSpellsFrame.PagingControls
	PagingControls.PageText:SetTextColor(1, 1, 1)
	S:HandleNextPrevButton(PagingControls.PrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(PagingControls.NextPageButton, nil, nil, true)

	local RotationButton = SpellBookFrame.AssistedCombatRotationSpellFrame.Button
	S:HandleIcon(RotationButton.Icon, true)
	RotationButton.Border:Hide()
	RotationButton:SetHighlightTexture(E.media.blankTex)
	RotationButton:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
	RotationButton:SetPushedTexture(E.media.blankTex)
	RotationButton:GetPushedTexture():SetVertexColor(1, 0.82, 0, 0.4)
end

S:AddCallbackForAddon('Blizzard_PlayerSpells')
