local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc

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

local useTextureKit = {
	jailerstower = true,
	cypherchoice = true
}

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

	local kit = useTextureKit[frame.uiTextureKit]
	frame:SetTemplate(kit and 'NoBackdrop' or 'Transparent')

	if frame.optionFrameTemplate and frame.optionPools then
		local parchmentRemover = E.private.skins.parchmentRemoverEnable
		local noParchment = not kit and parchmentRemover

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

			if option.Artwork and kit then option.Artwork:Size(64) end -- fix size from icon replacements in tower

			SetupRewards(option.rewards)
			SetupButtons(option.buttons)
		end
	end
end

local function SetupTorghastMover()
	B:BuildWidgetHolder('TorghastChoiceToggleHolder', 'TorghastChoiceToggle', 'CENTER', L["Torghast Choice Toggle"], _G.TorghastPlayerChoiceToggleButton, 'CENTER', E.UIParent, 'CENTER', 0, -200, 300, 40, 'ALL,GENERAL')

	-- whole area is clickable which is pretty big; keep an eye on this
	_G.TorghastPlayerChoiceToggleButton:SetHitRectInsets(70, 70, 40, 40)

	-- this fixes the trajectory of the anima orb to stay in correct place
	hooksecurefunc(_G.TorghastPlayerChoiceToggleButton, 'StartEffect', function(button, effectID)
		local controller = button.effectController
		if not controller then return end

		if effectID == 98 then -- anima orb
			controller:SetDynamicOffsets(-5, -10, -1.33)
		end
	end)
end

function S:Blizzard_PlayerChoice()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.playerChoice) then return end

	SetupTorghastMover()

	hooksecurefunc(_G.PlayerChoiceFrame, 'SetupOptions', SetupOptions)
end

S:AddCallbackForAddon('Blizzard_PlayerChoice')
