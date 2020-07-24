local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select, select
local hooksecurefunc = hooksecurefunc

-- SHADOWLANDS

function S:Blizzard_PlayerChoiceUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.PlayerChoice) then return end

	local frame = _G.PlayerChoiceFrame

	local function StyleText(self)
		if self.IsSkinned then return end

		self:SetTextColor(1, 1, 1)
		self.SetTextColor = E.noop
		self.IsSkinned = true
	end

	hooksecurefunc(frame, 'Update', function(self)
		if not self.IsSkinned then
			self.BlackBackground:SetAlpha(0)
			self.Background:SetAlpha(0)
			self.NineSlice:SetAlpha(0)
			self.BorderFrame.Header:SetAlpha(0)

			self:CreateBackdrop('Transparent')

			self.Title:DisableDrawLayer('BACKGROUND')
			self.Title.Text:SetTextColor(1, .8, 0)

			S:HandleCloseButton(self.CloseButton)
			self.CloseButton.Border:SetAlpha(0)

			self.IsSkinned = true
		end

		for i = 1, self:GetNumOptions() do
			local option = self.Options[i]
			option.Header.Text:SetTextColor(1, .8, 0)
			option.OptionText:SetTextColor(1, 1, 1)

			for i = 1, option.WidgetContainer:GetNumChildren() do
				local child = select(i, option.WidgetContainer:GetChildren())
				if child then
					if child.Text then
						child.Text:SetTextColor(1, 1, 1)
					end

					if child.Spell then
						if not child.Spell.isSkinned then
							child.Spell.Border:SetTexture("")
							child.Spell.IconMask:Hide()

							S:HandleIcon(child.Spell.Icon)

							 child.Spell.isSkinned = true
						end

						child.Spell.Text:SetTextColor(1, 1, 1)
					end

					for j = 1, child:GetNumChildren() do
						local child2 = select(j, child:GetChildren())
						if child2 then
							if child2.Text then StyleText(child2.Text) end
							if child2.LeadingText then StyleText(child2.LeadingText) end
							if child2.Icon and not child2.Icon.isSkinned then
								S:HandleIcon(child2.Icon)

								child2.Icon.isSkinned = true
							end
						end
					end
				end
			end

			S:HandleButton(option.OptionButtonsContainer.button1)
		end
	end)
end

S:AddCallbackForAddon('Blizzard_PlayerChoiceUI')
