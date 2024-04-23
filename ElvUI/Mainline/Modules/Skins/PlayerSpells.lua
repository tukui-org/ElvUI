local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local GetSpellTexture = GetSpellTexture

--[[
	To Do:  Parchment Remover
		    Monitor it due to changes from Blizz
]]

local function HandleTalentFrameDialog(dialog)
	if not dialog then return end

	dialog:StripTextures()
	dialog:CreateBackdrop('Transparent')

	if dialog.AcceptButton then S:HandleButton(dialog.AcceptButton) end
	if dialog.CancelButton then S:HandleButton(dialog.CancelButton) end
	if dialog.DeleteButton then S:HandleButton(dialog.DeleteButton) end

	S:HandleEditBox(dialog.NameControl.EditBox)
	dialog.NameControl.EditBox.backdrop:Point('TOPLEFT', -5, -10)
	dialog.NameControl.EditBox.backdrop:Point('BOTTOMRIGHT', 5, 10)
end

function S:Blizzard_PlayerSpells()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local PlayerSpellsFrame = _G.PlayerSpellsFrame
	S:HandlePortraitFrame(PlayerSpellsFrame)

	-- Specialisation
	SpecFrame = PlayerSpellsFrame.SpecFrame

	hooksecurefunc(PlayerSpellsFrame.SpecFrame, 'UpdateSpecFrame', function(frame)
		for specContentFrame in frame.SpecContentFramePool:EnumerateActive() do
			if not specContentFrame.isSkinned then
				S:HandleButton(specContentFrame.ActivateButton)

				if specContentFrame.SpellButtonPool then
					for button in specContentFrame.SpellButtonPool:EnumerateActive() do
						if button.Ring then
							button.Ring:Hide()
						end

						if button.spellID then
							local texture = GetSpellTexture(button.spellID)
							if texture then
								button.Icon:SetTexture(texture)
							end
						end

						S:HandleIcon(button.Icon, true)
					end
				end

				specContentFrame.isSkinned = true
			end
		end
	end)

	-- TalentsFrame
	TalentsFrame = PlayerSpellsFrame.TalentsFrame
	TalentsFrame.BlackBG:SetAlpha(0)
	TalentsFrame.BottomBar:SetAlpha(0)

	S:HandleButton(TalentsFrame.ApplyButton)
	S:HandleDropDownBox(TalentsFrame.LoadoutDropDown.DropDownControl.DropDownMenu)

	S:HandleButton(TalentsFrame.InspectCopyButton)

	TalentsFrame.ClassCurrencyDisplay.CurrencyLabel:FontTemplate(nil, 18)
	TalentsFrame.ClassCurrencyDisplay.CurrencyAmount:FontTemplate(nil, 26)

	TalentsFrame.SpecCurrencyDisplay.CurrencyLabel:FontTemplate(nil, 18)
	TalentsFrame.SpecCurrencyDisplay.CurrencyAmount:FontTemplate(nil, 26)

	S:HandleEditBox(TalentsFrame.SearchBox)
	TalentsFrame.SearchBox.backdrop:Point('TOPLEFT', -4, -5)
	TalentsFrame.SearchBox.backdrop:Point('BOTTOMRIGHT', 0, 5)
	TalentsFrame.SearchPreviewContainer:StripTextures()
	TalentsFrame.SearchPreviewContainer:CreateBackdrop('Transparent')

	TalentsFrame.PvPTalentList:StripTextures()
	TalentsFrame.PvPTalentList:CreateBackdrop()
	TalentsFrame.PvPTalentList.backdrop:SetFrameStrata(PlayerSpellsFrame.TalentsFrame.PvPTalentList:GetFrameStrata())
	TalentsFrame.PvPTalentList.backdrop:SetFrameLevel(2000)

	for _, tab in next, { PlayerSpellsFrame.TabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	PlayerSpellsFrame.TabSystem:ClearAllPoints()
	PlayerSpellsFrame.TabSystem:Point('TOPLEFT', PlayerSpellsFrame, 'BOTTOMLEFT', -3, 0)

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

	-- FIX ME 11.0: MONITOR THIS
	-- SpellBook
	SpellBookFrame = PlayerSpellsFrame.SpellBookFrame
	SpellBookFrame:StripTextures()

	if E.global.general.disableTutorialButtons then
		SpellBookFrame.HelpPlateButton:Kill()
	else
		SpellBookFrame.HelpPlateButton.Ring:Hide()
	end

	for _, tab in next, { SpellBookFrame.CategoryTabSystem:GetChildren() } do
		S:HandleTab(tab)
	end

	PagedSpellsFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
	PagedSpellsFrame.View1:DisableDrawLayer('OVERLAY')

	PagingControls = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.PagingControls
	S:HandleNextPrevButton(PagingControls.PrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(PagingControls.NextPageButton, nil, nil, true)
	PagingControls.PageText:SetTextColor(1, 1, 1)
end

S:AddCallbackForAddon('Blizzard_PlayerSpells')
