local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:LookingForGroupFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.editor) then return end

	local EditModeManagerFrame = _G.EditModeManagerFrame
	EditModeManagerFrame:StripTextures()
	EditModeManagerFrame:SetTemplate('Transparent')
	S:HandleCloseButton(EditModeManagerFrame.CloseButton)
	S:HandleButton(EditModeManagerFrame.RevertAllChangesButton)
	S:HandleButton(EditModeManagerFrame.SaveChangesButton)
	S:HandleDropDownBox(EditModeManagerFrame.LayoutDropdown.DropDownMenu)

	-- ToDO: Wait if it not taints anymore xD
end

--S:AddCallback('EditorManagerFrame')
