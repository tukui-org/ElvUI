local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:EditorManagerFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.editor) then return end

	local editMode = _G.EditModeManagerFrame
	editMode:StripTextures()
	editMode:CreateBackdrop('Transparent')

	S:HandleCloseButton(editMode.CloseButton)
	S:HandleButton(editMode.RevertAllChangesButton)
	S:HandleButton(editMode.SaveChangesButton)
	--S:HandleDropDownBox(editMode.LayoutDropdown.DropDownMenu)

	-- ToDO: Wait if it not taints anymore xD
end

S:AddCallback('EditorManagerFrame')
