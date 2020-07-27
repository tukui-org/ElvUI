local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc
local IsInJailersTower = IsInJailersTower

local function StyleText(text)
	if text.IsSkinned then return end
	text:SetTextColor(1, 1, 1)
	text.SetTextColor = E.noop
	text.IsSkinned = true
end

function S:Blizzard_PlayerChoiceUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.PlayerChoice) then return end

	local frame = _G.PlayerChoiceFrame
	hooksecurefunc(frame, 'Update', function()
		if not frame.IsSkinned then
			frame.BlackBackground:SetAlpha(0)
			frame.Background:SetAlpha(0)
			frame.NineSlice:SetAlpha(0)
			frame.BorderFrame.Header:SetAlpha(0)

			frame:CreateBackdrop('Transparent')

			frame.Title:DisableDrawLayer('BACKGROUND')
			frame.Title.Text:SetTextColor(1, .8, 0)

			S:HandleCloseButton(frame.CloseButton)
			frame.CloseButton.Border:SetAlpha(0)

			frame.IsSkinned = true
		end

		frame.backdrop:SetShown(not IsInJailersTower())

		for i = 1, frame:GetNumOptions() do
			local option = frame.Options[i]
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
