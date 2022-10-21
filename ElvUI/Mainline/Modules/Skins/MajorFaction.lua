local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetupMajorFaction(frame)
	if frame.Divider then frame.Divider:Hide() end
	if frame.NineSlice then frame.NineSlice:Hide() end
	if frame.Background then frame.Background:Hide() end
	if frame.BackgroundShadow then frame.BackgroundShadow:Hide() end
	if frame.CloseButton.Border then frame.CloseButton.Border:Hide() end
end

function S:Blizzard_MajorFactions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.majorFactions) then return end

	local RenownFrame = _G.MajorFactionRenownFrame
	RenownFrame:SetTemplate('Transparent')
	S:HandleCloseButton(RenownFrame.CloseButton)

	if E.private.skins.parchmentRemoverEnable then
		hooksecurefunc(RenownFrame, 'SetUpMajorFactionData', SetupMajorFaction)
	end
end

S:AddCallbackForAddon('Blizzard_MajorFactions')
