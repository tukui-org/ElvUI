local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:PVPReadyDialog()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	-- PvP Queue Popup
	_G.PVPReadyDialog:StripTextures()
	_G.PVPReadyDialog:SetTemplate('Transparent')
	S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
	S:HandleButton(_G.PVPReadyDialogHideButton)
end

S:AddCallback('PVPReadyDialog')
