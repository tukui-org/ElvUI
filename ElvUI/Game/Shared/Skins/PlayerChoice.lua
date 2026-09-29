local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local BL = E:GetModule('Blizzard')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

function S:PlayerChoice_SetupButtons(buttons)
	if not buttons then return end -- the grid layout template has no button container

	for buttonFrame in buttons.buttonFramePool:EnumerateActive() do
		if not buttonFrame.IsSkinned then
			S:HandleButton(buttonFrame.Button, true)

			buttonFrame.IsSkinned = true
		end
	end
end

function S:PlayerChoice_SetupRewards(rewards)
	if not rewards then return end -- only the normal option template has a reward list

	local parchmentRemover = E.private.skins.parchmentRemoverEnable
	for reward in rewards.rewardsPool:EnumerateActive() do
		if parchmentRemover and reward.Name then -- reputation rows have Text instead
			reward.Name:SetTextColor(1, 1, 1)
		end

		local item = reward.itemButton -- item and currency container rows
		if item and not item.IsSkinned then
			S:HandleItemButton(item)
			S:HandleIconBorder(item.IconBorder)
		end
	end
end

local function ReskinSpellWidget(spell)
	if not spell.Icon.backdrop then
		S:HandleIcon(spell.Icon, true)
	end

	spell.IconMask:Hide()
	spell.Border:SetAlpha(0)

	if E.private.skins.parchmentRemoverEnable then
		spell.Text:SetTextColor(1, 0.8, 0)
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
		self.BorderOverlay:SetAlpha(0)

		self.Title:DisableDrawLayer('BACKGROUND')
		self.Title.Text:SetTextColor(1, 0.8, 0)

		S:HandleCloseButton(self.CloseButton)

		self.IsSkinned = true
	end

	if self.CloseButton.Border then -- dont exist in jailer
		self.CloseButton.Border:SetAlpha(0)
	end

	local kit = S.PlayerChoice_TextureKits[self.uiTextureKit]
	self:SetTemplate(kit and 'NoBackdrop' or 'Transparent')

	local parchmentRemover = E.private.skins.parchmentRemoverEnable
	local noParchment = not kit and parchmentRemover

	-- the option templates differ per texture kit and the grid layout template has almost none of these keys
	for option in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
		local header = option.Header
		local contents = header and header.Contents

		if parchmentRemover then
			if contents and contents.Text then contents.Text:SetTextColor(1, 0.8, 0) end -- Normal Header Text
			if header and header.Text then header.Text:SetTextColor(1, 0.8, 0) end -- Torghast Header Text
			if option.OptionText then option.OptionText:SetTextColor(1, 1, 1) end -- description text
		end

		if noParchment then
			if option.Background then option.Background:SetAlpha(0) end
			if header and header.Ribbon then header.Ribbon:SetAlpha(0) end -- Normal only
		end

		if option.Artwork and kit then option.Artwork:Size(64) end -- fix size from icon replacements in tower

		S:PlayerChoice_SetupRewards(option.Rewards)
		S:PlayerChoice_SetupButtons(option.OptionButtonsContainer)

		local container = option.WidgetContainer
		if container and container.widgetFrames then -- only set once a widget set is registered
			for _, frame in pairs(container.widgetFrames) do
				if frame.Text then
					frame.Text:SetTextColor(1, 1, 1)
				end

				if parchmentRemover and frame.Label then
					frame.Label:SetTextColor(1, 1, 1)
				end

				if frame.Spell then
					ReskinSpellWidget(frame.Spell)
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
	BL:BuildWidgetHolder('TorghastChoiceToggleHolder', 'TorghastChoiceToggle', 'CENTER', L["Torghast Choice Toggle"], _G.TorghastPlayerChoiceToggleButton, 'CENTER', E.UIParent, 'CENTER', 0, -200, 300, 40, 'ALL,GENERAL')

	-- whole area is clickable which is pretty big; keep an eye on this
	_G.TorghastPlayerChoiceToggleButton:SetHitRectInsets(70, 70, 40, 40)

	-- this fixes the trajectory of the anima orb to stay in correct place
	hooksecurefunc(_G.TorghastPlayerChoiceToggleButton, 'StartEffect', S.TorghastButton_StartEffect)
end

function S:Blizzard_PlayerChoice()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.playerChoice) then return end

	SetupTorghastMover()
	S:HandleButton(_G.GenericPlayerChoiceToggleButton)

	hooksecurefunc(_G.PlayerChoiceFrame, 'SetupOptions', S.PlayerChoice_SetupOptions)
end

S:AddCallbackForAddon('Blizzard_PlayerChoice')
