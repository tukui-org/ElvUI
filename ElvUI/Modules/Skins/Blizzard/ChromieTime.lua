local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ChromieTimeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.chromieTime) then return end

	local frame = _G.ChromieTimeFrame
	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.SelectButton)

	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
		frame.Background:Hide()
		frame.Title:StripTextures()
		frame.CurrentlySelectedExpansionInfoFrame.Background:Hide()

		frame:CreateBackdrop('Transparent')
		frame.Title:CreateBackdrop('Transparent')
		frame.CurrentlySelectedExpansionInfoFrame:CreateBackdrop('Transparent')

		frame.CurrentlySelectedExpansionInfoFrame.Name:SetTextColor(1, 1, 1)
		frame.CurrentlySelectedExpansionInfoFrame.Description:SetTextColor(1, 1, 1)

		-- ToDo: Make the option button pretty!
	end
end

S:AddCallbackForAddon('Blizzard_ChromieTimeUI')
