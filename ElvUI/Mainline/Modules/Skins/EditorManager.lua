local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

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
end

S:AddCallback('EditorManagerFrame')
