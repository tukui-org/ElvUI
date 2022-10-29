local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function HandleCheckBox(checkbox)
	checkbox:CreateBackdrop()
	checkbox.backdrop:SetInside(nil, 4, 4)

	for _, region in next, { checkbox:GetRegions() } do
		if region:IsObjectType('Texture') then
			if region:GetTexture() == 130751 then
				if E.private.skins.checkBoxSkin then
					region:SetTexture(E.Media.Textures.Melli)

					local checkedTexture = checkbox:GetCheckedTexture()
					checkedTexture:SetVertexColor(1, .82, 0, 0.8)
					checkedTexture:SetInside(checkbox.backdrop)
				end
			else
				region:SetTexture('')
			end
		end
	end
end

local function HandleDialogs()
	local dialog = _G.EditModeSystemSettingsDialog
	for _, button in next, { dialog.Buttons:GetChildren() } do
		if button.Controller and not button.isSkinned then
			S:HandleButton(button)
		end
	end

	for _, frame in next, { dialog.Settings:GetChildren() } do
		local dd = frame.Dropdown
		if dd and (dd.DropDownMenu and not dd.isSkinned) then
			S:HandleDropDownBox(dd.DropDownMenu, 250)
			dd.isSkinned = true
		end

		local checkbox = frame.Button
		if checkbox and not checkbox.backdrop then
			HandleCheckBox(checkbox)
		end
	end
end

function S:EditorManagerFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.editor) then return end

	local editMode = _G.EditModeManagerFrame
	editMode:StripTextures()
	editMode:CreateBackdrop('Transparent')
	editMode.Tutorial:Kill()

	S:HandleCloseButton(editMode.CloseButton)
	S:HandleButton(editMode.RevertAllChangesButton)
	S:HandleButton(editMode.SaveChangesButton)
	S:HandleDropDownBox(editMode.LayoutDropdown.DropDownMenu, 250)

	S:HandleCheckBox(editMode.ShowGridCheckButton.Button)
	S:HandleCheckBox(editMode.EnableSnapCheckButton.Button)

	for _, frame in next, { editMode.AccountSettings.Settings:GetChildren() } do
		if frame.Button then
			S:HandleCheckBox(frame.Button)
		end
	end

	local dialog = _G.EditModeSystemSettingsDialog
	dialog:StripTextures()
	dialog:CreateBackdrop('Transparent')
	S:HandleCloseButton(dialog.CloseButton)

	hooksecurefunc(dialog.Buttons, 'AddLayoutChildren', HandleDialogs)
	HandleDialogs()
end

S:AddCallback('EditorManagerFrame')
