local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local B = E:GetModule('Blizzard')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

function S:PlayerChoice_SetupButtons(buttons)
	if buttons and buttons.buttonPool then
		for button in buttons.buttonPool:EnumerateActive() do
			if not button.isSkinned then
				S:HandleButton(button)
			end
		end
	end
end

function S:PlayerChoice_SetupRewards(rewards)
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

local function ReskinSpellWidget(spell)
	if spell.Icon and not spell.Icon.backdrop then
		S:HandleIcon(spell.Icon, true)
	end

	if spell.IconMask then
		spell.IconMask:Hide()
	end

	if spell.Border then
		spell.Border:SetAlpha(0)
	end

	if spell.Text then
		spell.Text:SetTextColor(1, .8, 0)
	end
end

S.PlayerChoice_TextureKits = {
	jailerstower = true,
	cypherchoice = true,
	genericplayerchoice = true,
}

function S:PlayerChoice_SetupOptions()
	if not self.IsSkinned then
		self.BlackBackground:SetAlpha(0)
		self.Background:SetAlpha(0)
		self.NineSlice:SetAlpha(0)

		self.Title:DisableDrawLayer('BACKGROUND')
		self.Title.Text:SetTextColor(1, .8, 0)

		S:HandleCloseButton(self.CloseButton)

		self.IsSkinned = true
	end

	if self.CloseButton.Border then -- dont exist in jailer
		self.CloseButton.Border:SetAlpha(0)
	end

	local kit = S.PlayerChoice_TextureKits[self.uiTextureKit]
	self:SetTemplate(kit and 'NoBackdrop' or 'Transparent')

	if self.optionFrameTemplate and self.optionPools then
		local parchmentRemover = E.private.skins.parchmentRemoverEnable
		local noParchment = not kit and parchmentRemover

		for option in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
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

			S:PlayerChoice_SetupRewards(option.rewards)
			S:PlayerChoice_SetupButtons(option.buttons)

			local container = option.WidgetContainer
			if container and container.widgetFrames then
				for _, frame in pairs(container.widgetFrames) do
					if frame.Text then
						frame.Text:SetTextColor(1, 1, 1)
					end

					if frame.Spell then
						ReskinSpellWidget(frame.Spell)
					end
				end
			end
		end
	end
end

function S:TorghastButton_StartEffect(effectID)
	local controller = self.effectController
	if not controller then return end

	if effectID == 98 then -- anima orb
		controller:SetDynamicOffsets(-5, -10, -1.33)
	end
end

local function SetupTorghastMover()
	B:BuildWidgetHolder('TorghastChoiceToggleHolder', 'TorghastChoiceToggle', 'CENTER', L["Torghast Choice Toggle"], _G.TorghastPlayerChoiceToggleButton, 'CENTER', E.UIParent, 'CENTER', 0, -200, 300, 40, 'ALL,GENERAL')

	-- whole area is clickable which is pretty big; keep an eye on this
	_G.TorghastPlayerChoiceToggleButton:SetHitRectInsets(70, 70, 40, 40)

	-- this fixes the trajectory of the anima orb to stay in correct place
	hooksecurefunc(_G.TorghastPlayerChoiceToggleButton, 'StartEffect', S.TorghastButton_StartEffect)
end

function S:Blizzard_PlayerChoice()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.playerChoice) then return end

	SetupTorghastMover()

	if _G.GenericPlayerChoiceToggleButton then
		S:HandleButton(_G.GenericPlayerChoiceToggleButton)
	end

	hooksecurefunc(_G.PlayerChoiceFrame, 'SetupOptions', S.PlayerChoice_SetupOptions)
end

S:AddCallbackForAddon('Blizzard_PlayerChoice')
