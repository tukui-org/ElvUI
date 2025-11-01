local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function HandleCheckBoxMini(checkbox, region)
	if region:GetTexture() == 130751 then
		if E.private.skins.checkBoxSkin then
			region:SetTexture(E.Media.Textures.Melli)

			local checkedTexture = checkbox:GetCheckedTexture()
			checkedTexture:SetVertexColor(1, .82, 0, 0.8)
			checkedTexture:SetInside(checkbox.backdrop)
		end
	else
		region:SetTexture(E.ClearTexture)
	end
end

local function HandleCheckBox(checkbox)
	checkbox:CreateBackdrop()
	checkbox.backdrop:SetInside(nil, 4, 4)

	S:ForEachCheckboxTextureRegion(checkbox, HandleCheckBoxMini)
end

local function HandleDialogs()
	local dialog = _G.EditModeSystemSettingsDialog
	for _, button in next, { dialog.Buttons:GetChildren() } do
		if button.Controller and not button.IsSkinned then
			S:HandleButton(button)
		end
	end

	for _, frame in next, { dialog.Settings:GetChildren() } do
		local dd = frame.Dropdown
		if dd and (dd.DropDownMenu and not dd.IsSkinned) then
			S:HandleDropDownBox(dd.DropDownMenu, 250)
			dd.IsSkinned = true
		end

		local checkbox = frame.Button
		if checkbox and not checkbox.backdrop then
			HandleCheckBox(checkbox)
		end
	end
end

function S:EditorManagerFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.editor) then return end

	-- Main Window
	local editMode = _G.EditModeManagerFrame
	editMode:StripTextures()
	editMode:CreateBackdrop('Transparent')

	if E.global.general.disableTutorialButtons then
		editMode.Tutorial:Kill()
	end

	S:HandleCloseButton(editMode.CloseButton)
	S:HandleButton(editMode.RevertAllChangesButton)
	S:HandleButton(editMode.SaveChangesButton)
	S:HandleDropDownBox(editMode.LayoutDropdown, 250)

	S:HandleStepSlider(editMode.GridSpacingSlider.Slider)
	S:HandleNextPrevButton(editMode.GridSpacingSlider.Slider.Back)
	S:HandleNextPrevButton(editMode.GridSpacingSlider.Slider.Forward)
	S:HandleCheckBox(editMode.ShowGridCheckButton.Button)
	S:HandleCheckBox(editMode.EnableSnapCheckButton.Button)
	S:HandleCheckBox(editMode.EnableAdvancedOptionsCheckButton.Button)

	S:HandleTrimScrollBar(editMode.AccountSettings.SettingsContainer.ScrollBar)
	editMode.AccountSettings.SettingsContainer.BorderArt:StripTextures()
	editMode.AccountSettings.SettingsContainer:SetTemplate('Transparent')
	editMode.AccountSettings.Expander.Divider:StripTextures()

	-- Group Containers (Basic, Frames, Combat, Misc)
	for _, frames in next, { editMode.AccountSettings.SettingsContainer.ScrollChild:GetChildren() } do
		for _, frame in next, { frames:GetChildren() } do
			if frame.Button then -- BasicOptionsContainer
				S:HandleCheckBox(frame.Button)
			else -- AdvancedOptionsContainer
				for _, child in next, { frame:GetChildren() } do
					if child.Button then
						S:HandleCheckBox(child.Button)
					end
				end
			end
		end
	end

	-- Layout Creator
	local layout = _G.EditModeNewLayoutDialog
	if layout then
		layout:StripTextures()
		layout:CreateBackdrop('Transparent')

		S:HandleButton(layout.AcceptButton)
		S:HandleButton(layout.CancelButton)
		S:HandleEditBox(layout.LayoutNameEditBox)

		HandleCheckBox(layout.CharacterSpecificLayoutCheckButton.Button)
	end

	-- Layout Unsaved
	local unsaved = _G.EditModeUnsavedChangesDialog
	if unsaved then
		unsaved:StripTextures()
		unsaved:CreateBackdrop('Transparent')

		S:HandleButton(unsaved.CancelButton)
		S:HandleButton(unsaved.ProceedButton)
		S:HandleButton(unsaved.SaveAndProceedButton)
	end

	-- Layout Importer
	local import = _G.EditModeImportLayoutDialog
	if import then
		import:StripTextures()
		import:CreateBackdrop('Transparent')
		S:HandleButton(import.AcceptButton)
		S:HandleButton(import.CancelButton)
		HandleCheckBox(import.CharacterSpecificLayoutCheckButton.Button)

		local importBox = import.ImportBox
		S:HandleEditBox(importBox)

		local importBackdrop = importBox.backdrop
		importBackdrop:ClearAllPoints()
		importBackdrop:Point('TOPLEFT', importBox, -4, 4)
		importBackdrop:Point('BOTTOMRIGHT', importBox, 0, -4)

		local scrollbar = importBox.ScrollBar
		S:HandleScrollBar(scrollbar)
		scrollbar:ClearAllPoints()
		scrollbar:Point('TOPLEFT', importBox, 'TOPRIGHT', 4, 4)
		scrollbar:Point('BOTTOMLEFT', importBox, 'BOTTOMRIGHT', 0, -4)

		local editbox = import.LayoutNameEditBox
		S:HandleEditBox(editbox)

		local editbackdrop = editbox.backdrop
		editbackdrop:ClearAllPoints()
		editbackdrop:Point('TOPLEFT', editbox, -2, -4)
		editbackdrop:Point('BOTTOMRIGHT', editbox, 2, 4)
	end

	-- Dialog (Mover Settings)
	local dialog = _G.EditModeSystemSettingsDialog
	if dialog then
		dialog:StripTextures()
		dialog:CreateBackdrop('Transparent')
		S:HandleCloseButton(dialog.CloseButton)

		hooksecurefunc(dialog.Buttons, 'AddLayoutChildren', HandleDialogs)

		HandleDialogs()
	end
end

S:AddCallback('EditorManagerFrame')
