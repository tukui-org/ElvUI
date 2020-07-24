local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- SHADOWLANDS
-- DONT FORGET TO ADD ME TO THE OPTIONS

function S:Blizzard_CovenantPreviewUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.CovenantPreview) then return end

	local frame = _G.CovenantPreviewFrame

	hooksecurefunc(frame, 'TryShow', function(self)
		if not self.IsSkinned then
			self.Background:SetAlpha(0)
			self.BorderFrame:SetAlpha(0)

			self:CreateBackdrop('Transparent')

			self.Title:DisableDrawLayer('BACKGROUND')
			self.Title.Text:SetTextColor(1, .8, 0)
			self.Title:CreateBackdrop('Transparent')

			self.ModelSceneContainer.ModelSceneBorder:SetAlpha(0)

			self.InfoPanel.Parchment:SetAlpha(0)
			self.InfoPanel:CreateBackdrop('Transparent')

			S:HandleCloseButton(self.CloseButton)
			S:HandleButton(self.SelectButton)

			self.IsSkinned = true
		end
	end)

	hooksecurefunc(frame, 'SetupTextureKits', function(_, button)
		if button.IconBorder and not button.isSkinned then
			button.IconBorder:SetAlpha(0)
			button.CircleMask:Hide()
			button.Background:SetAlpha(0)

			if not button.bg then
				button.bg = CreateFrame('Frame', nil, button, 'BackdropTemplate')
				S:HandleIcon(button.Icon, button.bg)
			end

			button.isSkinned = true
		end
	end)

	frame.InfoPanel.Description:SetTextColor(1, 1, 1)
	frame.InfoPanel.AbilitiesLabel:SetTextColor(1, .8, 0)

	S:HandleCheckBox(_G.TransmogAndMountDressupFrame.ShowMountCheckButton)
end

S:AddCallbackForAddon('Blizzard_CovenantPreviewUI')
