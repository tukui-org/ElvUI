local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:EditorManagerFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.editor) then return end

	local EditManager = _G.EditModeManagerFrame
	EditManager:StripTextures()
	EditManager:CreateBackdrop('Transparent') -- Adjust the backdrop FrameStrata

	S:HandleCloseButton(EditManager.CloseButton)
	S:HandleButton(EditManager.RevertAllChangesButton)
	S:HandleButton(EditManager.SaveChangesButton)
	S:HandleDropDownBox(EditManager.LayoutDropdown.DropDownMenu)

	-- ToDO: Wait if it not taints anymore xD
end

--S:AddCallback('EditorManagerFrame')
