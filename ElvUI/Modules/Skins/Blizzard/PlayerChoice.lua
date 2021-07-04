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
			local header = option.Header
			local contents = header and header.Contents

			if parchmentRemover then
				if contents and contents.Text then contents.Text:SetTextColor(1, .8, 0) end -- Normal Header Text
				if header and header.Text then header.Text:SetTextColor(1, .8, 0) end -- Torghast Header Text
				if option.OptionText then option.OptionText:SetTextColor(1, 1, 1) end -- description text
			end

			if noParchment then
				if option.Background then option.Background:SetAlpha(0) end
				if header and header.Ribbon then header.Ribbon:SetAlpha(0) end -- Normal only
			end

			if option.Artwork and inTower then option.Artwork:Size(64) end -- fix size from icon replacements in tower

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
