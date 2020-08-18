local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- 9.0 SHADOWLANDS

function S:Blizzard_CovenantPreviewUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantPreview) then return end

	local frame = _G.CovenantPreviewFrame
	frame.InfoPanel.Description:SetTextColor(1, 1, 1)
	frame.InfoPanel.AbilitiesLabel:SetTextColor(1, .8, 0)

	hooksecurefunc(frame, 'TryShow', function(covenantInfo)
		if covenantInfo and not frame.IsSkinned then
			frame.Background:SetAlpha(0)
			frame.BorderFrame:SetAlpha(0)

			frame:CreateBackdrop('Transparent')

			frame.Title:DisableDrawLayer('BACKGROUND')
			frame.Title.Text:SetTextColor(1, .8, 0)
			frame.Title:CreateBackdrop('Transparent')

			frame.ModelSceneContainer.ModelSceneBorder:SetAlpha(0)

			frame.InfoPanel.Parchment:SetAlpha(0)
			frame.InfoPanel:CreateBackdrop('Transparent')

			S:HandleCloseButton(frame.CloseButton)
			S:HandleButton(frame.SelectButton)

			frame.IsSkinned = true
		end
	end)

	hooksecurefunc(_G.CovenantAbilityButtonMixin, 'SetupButton', function(button)
		if not button.bg then
			button.bg = CreateFrame('Frame', nil, button, 'BackdropTemplate')
			S:HandleIcon(button.Icon, button.bg)
		end

		if button.CircleMask then
			button.CircleMask:Hide()
		end
		if button.Background then
			button.Background:SetAlpha(0)
		end
		if button.IconBorder then
			button.IconBorder:StripTextures()
		end
	end)

	frame.ModelSceneContainer.Background:SetTexCoord(0.00970873786408, 0.99029126213592, 0.0092807424594, 0.9907192575406)

	S:HandleCheckBox(_G.TransmogAndMountDressupFrame.ShowMountCheckButton)
end

S:AddCallbackForAddon('Blizzard_CovenantPreviewUI')
