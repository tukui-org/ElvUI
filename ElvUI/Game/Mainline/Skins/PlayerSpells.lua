local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local GetSpellTexture = C_Spell.GetSpellTexture

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

local function UpdateSpecFrame(frame)
	for specContentFrame in frame.SpecContentFramePool:EnumerateActive() do
		if not specContentFrame.IsSkinned then
			S:HandleButton(specContentFrame.ActivateButton)

			for button in specContentFrame.SpellButtonPool:EnumerateActive() do
				button.Ring:Hide()
				button.CircleMask:Hide()

				local texture = GetSpellTexture(button.spellID)
				if texture then
					button.Icon:SetTexture(texture)
				end

				S:HandleIcon(button.Icon, true)
			end

			specContentFrame.IsSkinned = true
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

	-- Specialisation
	hooksecurefunc(PlayerSpellsFrame.SpecFrame, 'UpdateSpecFrame', UpdateSpecFrame)

	-- TalentsFrame
	local TalentsFrame = PlayerSpellsFrame.TalentsFrame
	TalentsFrame.BlackBG:SetAlpha(0)
	TalentsFrame.BottomBar:SetAlpha(0)

	S:HandleButton(TalentsFrame.ApplyButton)
	S:HandleDropDownBox(TalentsFrame.LoadSystem.Dropdown)

	S:HandleButton(TalentsFrame.InspectCopyButton)

	TalentsFrame.ClassCurrencyDisplay.CurrencyLabel:FontTemplate(nil, 18)
	TalentsFrame.ClassCurrencyDisplay.CurrentAmountContainer.CurrencyAmount:FontTemplate(nil, 26)

	TalentsFrame.SpecCurrencyDisplay.CurrencyLabel:FontTemplate(nil, 18)
	TalentsFrame.SpecCurrencyDisplay.CurrentAmountContainer.CurrencyAmount:FontTemplate(nil, 26)

	S:HandleEditBox(TalentsFrame.SearchBox)
	TalentsFrame.SearchBox.backdrop:Point('TOPLEFT', -4, -5)
	TalentsFrame.SearchBox.backdrop:Point('BOTTOMRIGHT', 0, 5)
	TalentsFrame.SearchPreviewContainer:StripTextures()
	TalentsFrame.SearchPreviewContainer:CreateBackdrop('Transparent')

	TalentsFrame.PvPTalentList:StripTextures()
	TalentsFrame.PvPTalentList:CreateBackdrop()
	TalentsFrame.PvPTalentList.backdrop:SetFrameStrata(PlayerSpellsFrame.TalentsFrame.PvPTalentList:GetFrameStrata())
	TalentsFrame.PvPTalentList.backdrop:SetFrameLevel(2000)

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
	SpellBookFrame.TopBar:Hide()
	SpellBookFrame.BookCornerFlipbook:Hide()

	if E.global.general.disableTutorialButtons then
		SpellBookFrame.HelpPlateButton:Kill()
	else
		SpellBookFrame.HelpPlateButton.Ring:Hide()
	end

	for _, tab in next, { SpellBookFrame.CategoryTabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

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
