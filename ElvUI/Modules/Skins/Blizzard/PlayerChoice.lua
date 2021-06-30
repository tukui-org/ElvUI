local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local IsInJailersTower = IsInJailersTower

local function SetupButtons(buttons)
	if buttons and buttons.buttonPool then
		for button in buttons.buttonPool:EnumerateActive() do
			if not button.isSkinned then
				S:HandleButton(button)
			end
		end
	end
end

local function SetupRewards(rewards)
	if rewards and rewards.rewardsPool then
		local parchmentRemover = E.private.skins.parchmentRemoverEnable
		for reward in rewards.rewardsPool:EnumerateActive() do
			if parchmentRemover and reward.Name then
				reward.Name:SetTextColor(1, 1, 1)
			end

			local item = reward.itemButton
			if item and not item.isSkinned then
				S:HandleItemButton(item)
				S:HandleIconBorder(item.IconBorder)
			end
		end
	end
end

local function SetupOptions(frame)
	if not frame.IsSkinned then
		frame.BlackBackground:SetAlpha(0)
		frame.Background:SetAlpha(0)
		frame.NineSlice:SetAlpha(0)

		frame.Title:DisableDrawLayer('BACKGROUND')
		frame.Title.Text:SetTextColor(1, .8, 0)

		S:HandleCloseButton(frame.CloseButton)

		frame.IsSkinned = true
	end

	if frame.CloseButton.Border then -- dont exist in jailer
		frame.CloseButton.Border:SetAlpha(0)
	end

	local inTower = IsInJailersTower()
	frame:SetTemplate(inTower and 'NoBackdrop' or 'Transparent')

	if frame.optionFrameTemplate and frame.optionPools then
		local parchmentRemover = E.private.skins.parchmentRemoverEnable
		local noParchment = not inTower and parchmentRemover

		for option in frame.optionPools:EnumerateActiveByTemplate(frame.optionFrameTemplate) do
			if parchmentRemover then
				option.Header.Text:SetTextColor(1, .8, 0)
				option.OptionText:SetTextColor(1, 1, 1)
			end

			if noParchment then
				option.Background:SetAlpha(0)
				option.Header.Ribbon:SetAlpha(0)
			end

			if option.Artwork then -- blizzard never sets a size
				option.Artwork:Size(64) -- fix it for art replacements
			end

			SetupRewards(option.rewards)
			SetupButtons(option.buttons)
		end
	end
end

function S:Blizzard_PlayerChoice()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.playerChoice) then return end

	hooksecurefunc(_G.PlayerChoiceFrame, 'SetupOptions', SetupOptions)
end

S:AddCallbackForAddon('Blizzard_PlayerChoice')
