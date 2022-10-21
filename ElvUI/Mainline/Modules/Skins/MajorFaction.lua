local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

--ToDo: WoW10
function S:Blizzard_MajorFactions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.majorFactions) then return end

	local MajorFactionRenownFrame = _G.MajorFactionRenownFrame
	MajorFactionRenownFrame:SetTemplate('Transparent')
	S:HandleCloseButton(MajorFactionRenownFrame.CloseButton)

	if E.private.skins.parchmentRemoverEnable then
		hooksecurefunc(MajorFactionRenownFrame, 'SetUpMajorFactionData', function(self)
			if self.NineSlice then self.NineSlice:Hide() end
			if self.Background then self.Background:Hide() end
			if self.BackgroundShadow then self.BackgroundShadow:Hide() end
			if self.Divider then self.Divider:Hide() end
			if self.CloseButton.Border then self.CloseButton.Border:Hide() end
		end)
	end
end

S:AddCallbackForAddon('Blizzard_MajorFactions')
