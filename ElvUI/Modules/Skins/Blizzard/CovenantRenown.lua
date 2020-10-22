local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_CovenantRenown()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantRenown) then return end

	local frame = _G.CovenantRenownFrame
	S:HandleCloseButton(frame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_CovenantRenown')
