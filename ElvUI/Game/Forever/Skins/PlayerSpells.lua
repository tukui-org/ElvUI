local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function HandleTalentFrameDialog(dialog)
	if not dialog then return end

	dialog:StripTextures()
	dialog:CreateBackdrop('Transparent')

	if dialog.AcceptButton then S:HandleButton(dialog.AcceptButton) end
	if dialog.CancelButton then S:HandleButton(dialog.CancelButton) end
	if dialog.DeleteButton then S:HandleButton(dialog.DeleteButton) end

	local nameControl = dialog.NameControl
	local nameControlEditbox = nameControl and nameControl.EditBox
	if nameControlEditbox then
		S:HandleEditBox(nameControlEditbox)

		nameControlEditbox.backdrop:Point('TOPLEFT', -5, -10)
		nameControlEditbox.backdrop:Point('BOTTOMRIGHT', 5, 10)
	end
end

local function HandleTreeHeaders(frame)
	for _, header in next, frame.treeHeaders do
		if not header.IsSkinned then
			header.Divider:SetAlpha(0)
			header.Name:FontTemplate(nil, 16)
			header.Text:FontTemplate()

			header.IsSkinned = true
		end
	end
end

local function CategoryTabSelected(tab, selected)
	if not tab or not tab.backdrop then return end

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
	if not frame then return end

	for specFrame in frame.SpecContentFramePool:EnumerateActive() do
		if specFrame and not specFrame.IsSkinned then
			if specFrame.SpecName then specFrame.SpecName:FontTemplate(nil, 18) end
			if specFrame.Description then specFrame.Description:FontTemplate(nil, 14) end
			if specFrame.CurrencyFrame then
				specFrame.CurrencyFrame.LabelText:FontTemplate()
				specFrame.CurrencyFrame.AmountText:FontTemplate(nil, 18)
			end

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

	S:HandleButton(TalentsFrame.ApplyButton)
	S:HandleDropDownBox(TalentsFrame.LoadSystem.Dropdown)

	S:HandleButton(TalentsFrame.InspectCopyButton)
	S:HandleButton(TalentsFrame.ActiveSpec.ActivateButton)

	local CurrencyDisplay = TalentsFrame.ClassCurrencyDisplay
	CurrencyDisplay.Border:SetAlpha(0)
	CurrencyDisplay.CurrentAmountContainer:CreateBackdrop('Transparent')
	CurrencyDisplay.UnspentLabel:FontTemplate(nil, 14)
	CurrencyDisplay.UnspentLabel:ClearAllPoints()
	CurrencyDisplay.UnspentLabel:Point('RIGHT', CurrencyDisplay.CurrentAmountContainer, 'LEFT', -6, 0)
	CurrencyDisplay.CurrentAmountContainer.CurrencyAmount:FontTemplate(nil, 26)

	-- Primary / Secondary spec tabs
	for _, tab in next, { TalentsFrame.TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	hooksecurefunc(TalentsFrame, 'RefreshTreeHeaders', HandleTreeHeaders)

	S:HandleEditBox(TalentsFrame.SearchBox)
	TalentsFrame.SearchBox.backdrop:Point('TOPLEFT', -4, -5)
	TalentsFrame.SearchBox.backdrop:Point('BOTTOMRIGHT', 0, 5)
	TalentsFrame.SearchPreviewContainer:StripTextures()
	TalentsFrame.SearchPreviewContainer:CreateBackdrop('Transparent')

	local TabSystem = PlayerSpellsFrame.TabSystem
	for _, tab in next, { TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	TabSystem.spacing = -5
	if TabSystem.MarkDirty then
		TabSystem:MarkDirty()
	end

	TabSystem:ClearAllPoints()
	TabSystem:Point('TOPLEFT', PlayerSpellsFrame, 'BOTTOMLEFT', -3, 0)

	local ImportDialog = _G.ClassTalentLoadoutImportDialog
	if ImportDialog then
		HandleTalentFrameDialog(ImportDialog)
		ImportDialog.ImportControl.InputContainer:StripTextures()
		ImportDialog.ImportControl.InputContainer:CreateBackdrop('Transparent')
	end

	local CreateDialog = _G.ClassTalentLoadoutCreateDialog
	if CreateDialog then
		HandleTalentFrameDialog(CreateDialog)
	end

	local EditDialog = _G.ClassTalentLoadoutEditDialog
	if EditDialog then
		HandleTalentFrameDialog(EditDialog)

		local editbox = EditDialog.LoadoutName
		if editbox then
			S:HandleEditBox(editbox)
			editbox.backdrop:Point('TOPLEFT', -5, -5)
			editbox.backdrop:Point('BOTTOMRIGHT', 5, 5)
		end

		local check = EditDialog.UsesSharedActionBars
		if check then
			S:HandleCheckBox(check.CheckButton)
			check.CheckButton:Size(20)
			check.CheckButton.backdrop:SetInside()
		end
	end

	-- Hero Talents
	local HeroTalentContainer = TalentsFrame.HeroTalentsContainer
	HeroTalentContainer.HeroSpecLabel:FontTemplate(nil, 16)

	local TalentsSelect = _G.HeroTalentsSelectionDialog
	if TalentsSelect then
		TalentsSelect:StripTextures()
		TalentsSelect:SetTemplate()

		S:HandleCloseButton(TalentsSelect.CloseButton)

		hooksecurefunc(TalentsSelect, 'ShowDialog', HandleHeroTalents)
	end

	-- SpellBook
	local SpellBookFrame = PlayerSpellsFrame.SpellBookFrame
	if SpellBookFrame then
		S:HandleMaxMinFrame(PlayerSpellsFrame.MaxMinButtonFrame)
		S:HandleEditBox(SpellBookFrame.SearchBox)
		SpellBookFrame.SearchBox:Height(20)
		S:HandleNextPrevButton(SpellBookFrame.SettingsDropdown, 'down', nil, true)
		SpellBookFrame.SettingsDropdown:SetTemplate()
		SpellBookFrame.SettingsDropdown:ClearAllPoints()
		SpellBookFrame.SettingsDropdown:Point('TOPRIGHT', SpellBookFrame, 'TOPRIGHT', -30, -23)
		SpellBookFrame.SearchBox:ClearAllPoints()
		SpellBookFrame.SearchBox:Point('RIGHT', SpellBookFrame.SettingsDropdown, 'LEFT', -5, 0)

		if SpellBookFrame.TopBar then
			SpellBookFrame.TopBar:Hide()
		end

		if SpellBookFrame.BookCornerFlipbook then
			SpellBookFrame.BookCornerFlipbook:Hide()
		end

		if E.global.general.disableTutorialButtons then
			SpellBookFrame.HelpPlateButton:Kill()
		else
			SpellBookFrame.HelpPlateButton.Ring:Hide()
		end

		HandleCategoryTabs(SpellBookFrame.CategoryTabSystem)
		hooksecurefunc(SpellBookFrame.CategoryTabSystem, 'AddTab', HandleCategoryTabs)

		local PagedSpellsFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
		if PagedSpellsFrame then
			if PagedSpellsFrame.View1 then
				PagedSpellsFrame.View1:DisableDrawLayer('OVERLAY')
			end

			local PagingControls = PagedSpellsFrame.PagingControls
			if PagingControls then
				PagingControls.PageText:SetTextColor(1, 1, 1)

				S:HandleNextPrevButton(PagingControls.PrevPageButton, nil, nil, true)
				S:HandleNextPrevButton(PagingControls.NextPageButton, nil, nil, true)
			end
		end

		local RotationSpellFrame = SpellBookFrame and SpellBookFrame.AssistedCombatRotationSpellFrame
		local RotationButton = RotationSpellFrame and RotationSpellFrame.Button
		if RotationButton then
			S:HandleIcon(RotationButton.Icon, true)

			if RotationButton.Border then
				RotationButton.Border:Hide()
			end

			RotationButton:SetHighlightTexture(E.media.blankTex)
			RotationButton:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.25)
			RotationButton:SetPushedTexture(E.media.blankTex)
			RotationButton:GetPushedTexture():SetVertexColor(1, 0.82, 0, 0.4)
		end
	end
end

S:AddCallbackForAddon('Blizzard_PlayerSpells')
