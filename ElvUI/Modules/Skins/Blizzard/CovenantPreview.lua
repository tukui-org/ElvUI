local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_CovenantPreviewUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantPreview) then return end

	local frame = _G.CovenantPreviewFrame

	if E.private.skins.parchmentRemoverEnable then
		frame.InfoPanel.Name:SetTextColor(1, 1, 1)
		frame.InfoPanel.Location:SetTextColor(1, 1, 1)
		frame.InfoPanel.Description:SetTextColor(1, 1, 1)
		frame.InfoPanel.AbilitiesFrame.AbilitiesLabel:SetTextColor(1, .8, 0)
		frame.InfoPanel.SoulbindsFrame.SoulbindsLabel:SetTextColor(1, .8, 0)
		frame.InfoPanel.CovenantFeatureFrame.Label:SetTextColor(1, .8, 0)
	end

	hooksecurefunc(frame, 'TryShow', function(covenantInfo)
		if covenantInfo and not frame.IsSkinned then
			frame:SetTemplate('Transparent')

			frame.ModelSceneContainer.ModelSceneBorder:SetAlpha(0)
			frame.InfoPanel:SetTemplate('Transparent')

			if E.private.skins.parchmentRemoverEnable then
				frame.Title:DisableDrawLayer('BACKGROUND')
				frame.Title.Text:SetTextColor(1, .8, 0)
				frame.Title:SetTemplate('Transparent')
				frame.Background:SetAlpha(0)
				frame.BorderFrame:SetAlpha(0)
				frame.InfoPanel.Parchment:SetAlpha(0)
			end

			frame.CloseButton.Border:Kill()
			S:HandleCloseButton(frame.CloseButton)
			S:HandleButton(frame.SelectButton)

			frame.IsSkinned = true
		end
	end)

	frame.ModelSceneContainer.Background:SetTexCoord(0.00970873786408, 0.99029126213592, 0.0092807424594, 0.9907192575406)

	S:HandleCheckBox(_G.TransmogAndMountDressupFrame.ShowMountCheckButton)
end

S:AddCallbackForAddon('Blizzard_CovenantPreviewUI')
