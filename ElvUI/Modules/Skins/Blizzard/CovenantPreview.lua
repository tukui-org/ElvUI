local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- SHADOWLANDS
-- DONT FORGET TO ADD ME TO THE OPTIONS

function S:Blizzard_CovenantPreviewUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.CovenantPreview) then return end

	local frame = _G.CovenantPreviewFrame
	frame.InfoPanel.Description:SetTextColor(1, 1, 1)
	frame.InfoPanel.AbilitiesLabel:SetTextColor(1, .8, 0)

	hooksecurefunc(frame, 'TryShow', function()
		if not frame.IsSkinned then
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

	hooksecurefunc(frame, 'SetupTextureKits', function(_, button)
		if button.IconBorder and not button.isSkinned then
			button.CircleMask:Hide()
			button.Background:SetAlpha(0)
			button.IconBorder:Kill()

			if not button.bg then
				button.bg = CreateFrame('Frame', nil, button, 'BackdropTemplate')
				S:HandleIcon(button.Icon, button.bg)
			end

			button.isSkinned = true
		end
	end)

	S:HandleCheckBox(_G.TransmogAndMountDressupFrame.ShowMountCheckButton)
end

S:AddCallbackForAddon('Blizzard_CovenantPreviewUI')
