local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local ipairs, unpack = ipairs, unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function SkinRecipeList(self, _, tradeSkillInfo)
	-- +/- Buttons
	if tradeSkillInfo.collapsed then
		self:SetNormalTexture(E.Media.Textures.PlusButton)
	else
		self:SetNormalTexture(E.Media.Textures.MinusButton)
	end

	-- Skillbar
	if tradeSkillInfo.hasProgressBar then
		self.SubSkillRankBar.BorderMid:Hide()
		self.SubSkillRankBar.BorderLeft:Hide()
		self.SubSkillRankBar.BorderRight:Hide()

		if not self.SubSkillRankBar.backdrop then
			self.SubSkillRankBar:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
			self.SubSkillRankBar:SetStatusBarTexture(E.media.normTex)
			E:RegisterStatusBar(self.SubSkillRankBar)
		end
	end
end

function S:Blizzard_TradeSkillUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tradeskill) then return end

	-- MainFrame
	local TradeSkillFrame = _G.TradeSkillFrame
	S:HandlePortraitFrame(TradeSkillFrame)

	TradeSkillFrame:Height(TradeSkillFrame:GetHeight() + 12)
	TradeSkillFrame.RankFrame:SetFrameLevel(3)
	TradeSkillFrame.RankFrame:StripTextures()
	TradeSkillFrame.RankFrame:CreateBackdrop()
	TradeSkillFrame.RankFrame:SetStatusBarTexture(E.media.normTex)
	TradeSkillFrame.RankFrame:SetStatusBarColor(unpack(E.media.rgbvaluecolor))
	TradeSkillFrame.RankFrame.RankText:FontTemplate()
	E:RegisterStatusBar(TradeSkillFrame.RankFrame)
	S:HandleButton(TradeSkillFrame.FilterButton)
	TradeSkillFrame.LinkToButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
	TradeSkillFrame.LinkToButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
	TradeSkillFrame.LinkToButton:GetHighlightTexture():Kill()
	TradeSkillFrame.LinkToButton:SetTemplate()
	TradeSkillFrame.LinkToButton:Size(17, 14)
	TradeSkillFrame.LinkToButton:Point('BOTTOMRIGHT', TradeSkillFrame.FilterButton, 'TOPRIGHT', -2, 4)
	TradeSkillFrame.bg1 = CreateFrame('Frame', nil, TradeSkillFrame)
	TradeSkillFrame.bg1:SetTemplate('Transparent')
	TradeSkillFrame.bg1:Point('TOPLEFT', 4, -81)
	TradeSkillFrame.bg1:Point('BOTTOMRIGHT', -340, 4)
	TradeSkillFrame.bg1:SetFrameLevel(TradeSkillFrame.bg1:GetFrameLevel() - 1)
	TradeSkillFrame.bg2 = CreateFrame('Frame', nil, TradeSkillFrame)
	TradeSkillFrame.bg2:SetTemplate('Transparent')
	TradeSkillFrame.bg2:Point('TOPLEFT', TradeSkillFrame.bg1, 'TOPRIGHT', 1, 0)
	TradeSkillFrame.bg2:Point('BOTTOMRIGHT', TradeSkillFrame, 'BOTTOMRIGHT', -4, 4)
	TradeSkillFrame.bg2:SetFrameLevel(TradeSkillFrame.bg2:GetFrameLevel() - 1)

	S:HandleEditBox(TradeSkillFrame.SearchBox)

	-- RecipeList
	TradeSkillFrame.RecipeInset:StripTextures()
	TradeSkillFrame.RecipeList.LearnedTab:StripTextures()
	TradeSkillFrame.RecipeList.UnlearnedTab:StripTextures()
	S:HandleScrollBar(TradeSkillFrame.RecipeList.scrollBar)

	-- DetailsFrame
	TradeSkillFrame.DetailsFrame:StripTextures()
	TradeSkillFrame.DetailsInset:StripTextures()
	TradeSkillFrame.DetailsFrame.Background:Hide()
	S:HandleEditBox(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox)
	TradeSkillFrame.DetailsFrame.CreateMultipleInputBox:DisableDrawLayer('BACKGROUND')

	S:HandleButton(TradeSkillFrame.DetailsFrame.CreateAllButton)
	S:HandleButton(TradeSkillFrame.DetailsFrame.CreateButton)
	S:HandleButton(TradeSkillFrame.DetailsFrame.ExitButton)

	S:HandleScrollBar(TradeSkillFrame.DetailsFrame.ScrollBar)

	S:HandleNextPrevButton(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.DecrementButton)
	S:HandleNextPrevButton(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.IncrementButton)
	TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.IncrementButton:Point('LEFT', TradeSkillFrame.DetailsFrame.CreateMultipleInputBox, 'RIGHT', 4, 0)

	S:HandleButton(TradeSkillFrame.DetailsFrame.Contents.RecipeLevelSelector)

	if not TradeSkillFrame.DetailsFrame.Contents.RecipeLevel.backdrop then
		TradeSkillFrame.DetailsFrame.Contents.RecipeLevel:StripTextures()
		TradeSkillFrame.DetailsFrame.Contents.RecipeLevel:SetTemplate()
		TradeSkillFrame.DetailsFrame.Contents.RecipeLevel:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(TradeSkillFrame.DetailsFrame.Contents.RecipeLevel)
	end

	hooksecurefunc(TradeSkillFrame.DetailsFrame, 'RefreshDisplay', function()
		local ResultIcon = TradeSkillFrame.DetailsFrame.Contents.ResultIcon
		ResultIcon:StyleButton()

		if ResultIcon:GetNormalTexture() then
			ResultIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			ResultIcon:GetNormalTexture():SetInside()
		end

		ResultIcon:SetTemplate()
		ResultIcon.IconBorder:SetTexture()
		ResultIcon.ResultBorder:SetTexture()

		for i = 1, #TradeSkillFrame.DetailsFrame.Contents.Reagents do
			local Button = TradeSkillFrame.DetailsFrame.Contents.Reagents[i]
			local Icon = Button.Icon
			local Count = Button.Count

			Icon:SetTexCoord(unpack(E.TexCoords))
			Icon:SetDrawLayer('OVERLAY')

			if not Icon.backdrop then
				Icon.backdrop = CreateFrame('Frame', nil, Button)
				Icon.backdrop:SetFrameLevel(Button:GetFrameLevel() - 1)
				Icon.backdrop:SetTemplate()
				Icon.backdrop:SetOutside(Icon)
			end

			Icon:SetParent(Icon.backdrop)
			Count:SetParent(Icon.backdrop)
			Count:SetDrawLayer('OVERLAY')

			Button.NameFrame:Kill()
		end

		for i = 1, #TradeSkillFrame.DetailsFrame.Contents.OptionalReagents do
			local Button = TradeSkillFrame.DetailsFrame.Contents.OptionalReagents[i]
			local Icon = Button.Icon

			Icon:SetTexCoord(unpack(E.TexCoords))
			Icon:SetDrawLayer('OVERLAY')

			if not Icon.backdrop then
				Icon.backdrop = CreateFrame('Frame', nil, Button)
				Icon.backdrop:SetFrameLevel(Button:GetFrameLevel() - 1)
				Icon.backdrop:SetTemplate()
				Icon.backdrop:SetOutside(Icon)
			end

			Button.SocketGlow:SetAtlas(nil)
			Button.SocketGlow:SetColorTexture(0, 1, 0)
			Button.SocketGlow:SetInside(Icon.backdrop)

			Button.SelectedTexture:SetAtlas(nil)
			Button.SelectedTexture:SetColorTexture(0.9, 0.8, 0.1)
			Button.SelectedTexture:SetOutside(Icon.backdrop)

			Button.NameFrame:Kill()
		end
	end)

	hooksecurefunc(TradeSkillFrame.RecipeList, 'Refresh', function()
		for _, tradeSkillButton in ipairs(TradeSkillFrame.RecipeList.buttons) do
			if not tradeSkillButton.headerIsHooked then
				hooksecurefunc(tradeSkillButton, 'SetUpHeader', SkinRecipeList)
				tradeSkillButton.headerIsHooked = true
			end
		end
	end)

	--Guild Crafters
	S:HandleCloseButton(TradeSkillFrame.DetailsFrame.GuildFrame.CloseButton)
	S:HandleButton(TradeSkillFrame.DetailsFrame.ViewGuildCraftersButton)
	TradeSkillFrame.DetailsFrame.GuildFrame:StripTextures()
	TradeSkillFrame.DetailsFrame.GuildFrame:SetTemplate('Transparent')
	TradeSkillFrame.DetailsFrame.GuildFrame.Container:StripTextures()
	TradeSkillFrame.DetailsFrame.GuildFrame.Container:SetTemplate('Transparent')
	--S:HandleScrollBar(TradeSkillFrame.DetailsFrame.GuildFrame.Container.ScrollFrame.scrollBar) --This cannot be skinned due to issues on Blizzards end.
	S:HandleScrollBar(TradeSkillFrame.RecipeList.scrollBar)

	local OptionalReagents = TradeSkillFrame.OptionalReagentList
	OptionalReagents:StripTextures()
	OptionalReagents:SetTemplate('Transparent')

	OptionalReagents.ScrollList:StripTextures()
	OptionalReagents.ScrollList:SetTemplate('Transparent')

	S:HandleCheckBox(OptionalReagents.HideUnownedButton)
	S:HandleScrollBar(OptionalReagents.ScrollList.ScrollFrame.scrollBar)
	S:HandleButton(OptionalReagents.CloseButton)

	-- Needs probably updates - or/also a different way
	hooksecurefunc(_G.OptionalReagentListLineMixin, 'UpdateDisplay', function(frame)
		frame.NameFrame:Kill()
		frame:DisableDrawLayer('ARTWORK')

		S:HandleIcon(frame.Icon, true)
		frame.Icon:Size(32, 32)
		frame.Icon:ClearAllPoints()
		frame.Icon:Point('TOPLEFT', frame, 'TOPLEFT', 3, -3)

		if frame.Icon.backdrop then
			S:HandleIconBorder(frame.IconBorder, frame.Icon.backdrop)
		end
	end)
end

S:AddCallbackForAddon('Blizzard_TradeSkillUI')
