local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_RuneforgeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.Runeforge) then return end

	-- Skin looks good without hiding stuff
	local frame = _G.RuneforgeFrame

	frame.Title:FontTemplate(nil, 22)

	S:HandleButton(frame.CreateFrame.CraftItemButton)
	S:HandleButton(frame.CreateFrame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_RuneforgeUI')
