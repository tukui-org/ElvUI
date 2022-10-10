local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

--ToDo: WoW10
function S:Blizzard_MajorFactions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.majorFactions) then return end

	local MajorFactionRenownFrame = _G.MajorFactionRenownFrame
	MajorFactionRenownFrame:SetTemplate('Transparent')
	S:HandleCloseButton(MajorFactionRenownFrame.CloseButton)

	if E.private.skins.parchmentRemoverEnable then
		MajorFactionRenownFrame.NineSlice:Hide()
	end
end

S:AddCallbackForAddon('Blizzard_MajorFactions')
