local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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

local function HandleChoiceOptionButton(button, strip)
	if not button or button.backdrop then return end

	if strip then
		button:StripTextures(true)
	end

	S:HandleButton(button, nil, nil, nil, true, nil, nil, nil, true)
end

local function HandleJailerOptionButton(button)
	if not button or button.IsSkinned then return end

	button:StripTextures(true)
	button:SetTemplate()

	button:HookScript('OnEnter', S.SetModifiedBackdrop)
	button:HookScript('OnLeave', S.SetOriginalBackdrop)

	button.IsSkinned = true
end

function S:Blizzard_PlayerChoiceUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.playerChoice) then return end

	local frame = _G.PlayerChoiceFrame
	hooksecurefunc(frame, 'Update', function()
		if not frame.IsSkinned then
			frame.BlackBackground:SetAlpha(0)
			frame.Background:SetAlpha(0)
			frame.NineSlice:SetAlpha(0)
			frame.BorderFrame.Header:SetAlpha(0)

			frame.Title:DisableDrawLayer('BACKGROUND')
			frame.Title.Text:SetTextColor(1, .8, 0)

			S:HandleCloseButton(frame.CloseButton)
			frame.CloseButton.Border:SetAlpha(0)

			frame.IsSkinned = true
		end

		local inTower = IsInJailersTower()
		local noParchment = not inTower and E.private.skins.parchmentRemoverEnable

		frame:SetTemplate(inTower and 'NoBackdrop' or 'Transparent')

		for i = 1, frame:GetNumOptions() do
			local option = frame.Options[i]
			if noParchment then
				option.Header.Text:SetTextColor(1, .8, 0)
				option.OptionText:SetTextColor(1, 1, 1)

				option.Background:SetAlpha(0)
				option.Header.Ribbon:SetAlpha(0)
			end

			if inTower then -- for some reason the buttons are different. W T F
				HandleJailerOptionButton(option.OptionButtonsContainer.button1)
				HandleJailerOptionButton(option.OptionButtonsContainer.button2)
			else
				HandleChoiceOptionButton(option.OptionButtonsContainer.button1, true)
				HandleChoiceOptionButton(option.OptionButtonsContainer.button2) -- smaller button?
			end

			for x = 1, option.WidgetContainer:GetNumChildren() do
				local child = select(x, option.WidgetContainer:GetChildren())
				if child then
					local text = child.Text
					if text and noParchment then
						text:SetTextColor(1, 1, 1)
					end

					local spell = child.Spell
					if spell then
						if not spell.isSkinned then
							spell.Border:SetTexture('')
							spell.IconMask:Hide()

							S:HandleIcon(spell.Icon)

							spell.isSkinned = true
						end

						if noParchment then
							spell.Text:SetTextColor(1, 1, 1)
						end
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
		end
	end)

	hooksecurefunc(frame, 'SetupRewards', function(rewards)
		if rewards.numActiveOptions and E.private.skins.parchmentRemoverEnable then
			for i = 1, rewards.numActiveOptions do
				local option = rewards.Options[i]
				local frameRewards = option and option.RewardsFrame and option.RewardsFrame.Rewards
				if frameRewards and frameRewards.ItemRewardsPool then
					for button in frameRewards.ItemRewardsPool:EnumerateActive() do
						if not button.IsSkinned then
							button.Name:SetTextColor(.9, .8, .5)
							button.IconBorder:SetAlpha(0)

							button.IsSkinned = true
						end
					end
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_PlayerChoiceUI')
