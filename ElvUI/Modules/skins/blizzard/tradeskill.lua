local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs, unpack = ipairs, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tradeskill ~= true then return end

	-- MainFrame
	local TradeSkillFrame = _G["TradeSkillFrame"]
	TradeSkillFramePortrait:SetAlpha(0)
	TradeSkillFrame:StripTextures(true)
	TradeSkillFrame:SetTemplate("Transparent")
	TradeSkillFrame:Height(TradeSkillFrame:GetHeight() + 12)
	TradeSkillFrame.RankFrame:StripTextures()
	TradeSkillFrame.RankFrame:CreateBackdrop("Default")
	TradeSkillFrame.RankFrame:SetStatusBarTexture(E.media.normTex)
	TradeSkillFrame.RankFrame.RankText:FontTemplate()
	E:RegisterStatusBar(TradeSkillFrame.RankFrame)
	S:HandleButton(TradeSkillFrame.FilterButton)
	TradeSkillFrame.LinkToButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
	TradeSkillFrame.LinkToButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
	TradeSkillFrame.LinkToButton:GetHighlightTexture():Kill()
	TradeSkillFrame.LinkToButton:CreateBackdrop("Default")
	TradeSkillFrame.LinkToButton:Size(17, 14)
	TradeSkillFrame.LinkToButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame.FilterButton, "TOPRIGHT", -2, 4)
	TradeSkillFrame.bg1 = CreateFrame("Frame", nil, TradeSkillFrame)
	TradeSkillFrame.bg1:SetTemplate("Transparent")
	TradeSkillFrame.bg1:Point("TOPLEFT", 4, -81)
	TradeSkillFrame.bg1:Point("BOTTOMRIGHT", -340, 4)
	TradeSkillFrame.bg1:SetFrameLevel(TradeSkillFrame.bg1:GetFrameLevel() - 1)
	TradeSkillFrame.bg2 = CreateFrame("Frame", nil, TradeSkillFrame)
	TradeSkillFrame.bg2:SetTemplate("Transparent")
	TradeSkillFrame.bg2:Point("TOPLEFT", TradeSkillFrame.bg1, "TOPRIGHT", 1, 0)
	TradeSkillFrame.bg2:Point("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -4, 4)
	TradeSkillFrame.bg2:SetFrameLevel(TradeSkillFrame.bg2:GetFrameLevel() - 1)

	S:HandleEditBox(TradeSkillFrame.SearchBox)
	S:HandleCloseButton(TradeSkillFrameCloseButton)

	-- RecipeList
	TradeSkillFrame.RecipeInset:StripTextures()
	TradeSkillFrame.RecipeList.LearnedTab:StripTextures()
	TradeSkillFrame.RecipeList.UnlearnedTab:StripTextures()

	-- DetailsFrame
	TradeSkillFrame.DetailsFrame:StripTextures()
	TradeSkillFrame.DetailsInset:StripTextures()
	TradeSkillFrame.DetailsFrame.Background:Hide()
	S:HandleEditBox(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox)
	TradeSkillFrame.DetailsFrame.CreateMultipleInputBox:DisableDrawLayer("BACKGROUND")

	S:HandleButton(TradeSkillFrame.DetailsFrame.CreateAllButton, true)
	S:HandleButton(TradeSkillFrame.DetailsFrame.CreateButton, true)
	S:HandleButton(TradeSkillFrame.DetailsFrame.ExitButton, true)

	S:HandleScrollBar(TradeSkillFrame.DetailsFrame.ScrollBar)

	S:HandleNextPrevButton(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.DecrementButton, nil, true)
	S:HandleNextPrevButton(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.IncrementButton)
	TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.IncrementButton:Point("LEFT", TradeSkillFrame.DetailsFrame.CreateMultipleInputBox, "RIGHT", 4, 0)

	hooksecurefunc(TradeSkillFrame.DetailsFrame, "RefreshDisplay", function()
		local ResultIcon = TradeSkillFrame.DetailsFrame.Contents.ResultIcon
		ResultIcon:StyleButton()
		if ResultIcon:GetNormalTexture() then
			ResultIcon:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			ResultIcon:GetNormalTexture():SetInside()
		end
		ResultIcon:SetTemplate("Default")
		ResultIcon.IconBorder:SetTexture(nil)
		ResultIcon.ResultBorder:SetTexture(nil)

		for i = 1, #TradeSkillFrame.DetailsFrame.Contents.Reagents do
			local Button = TradeSkillFrame.DetailsFrame.Contents.Reagents[i]
			local Icon = Button.Icon
			local Count = Button.Count

			Icon:SetTexCoord(unpack(E.TexCoords))
			Icon:SetDrawLayer("OVERLAY")
			if not Icon.backdrop then
				Icon.backdrop = CreateFrame("Frame", nil, Button)
				Icon.backdrop:SetFrameLevel(Button:GetFrameLevel() - 1)
				Icon.backdrop:SetTemplate("Default")
				Icon.backdrop:SetOutside(Icon)
			end

			Icon:SetParent(Icon.backdrop)
			Count:SetParent(Icon.backdrop)
			Count:SetDrawLayer("OVERLAY")

			Button.NameFrame:Kill()
		end
	end)

	local function SkinRecipeList(self, _, tradeSkillInfo)
		-- +/- Buttons
		if tradeSkillInfo.collapsed then
			self:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusButton")
		else
			self:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\MinusButton")
		end

		-- Skillbar
		if tradeSkillInfo.hasProgressBar then
			self.SubSkillRankBar.BorderMid:Hide()
			self.SubSkillRankBar.BorderLeft:Hide()
			self.SubSkillRankBar.BorderRight:Hide()

			if not self.SubSkillRankBar.backdrop then
				self.SubSkillRankBar:CreateBackdrop("Default")
				self.SubSkillRankBar.backdrop:SetAllPoints()
				self.SubSkillRankBar:SetStatusBarTexture(E.media.normTex)
				E:RegisterStatusBar(self.SubSkillRankBar)
			end
		end
	end

	hooksecurefunc(TradeSkillFrame.RecipeList, "Refresh", function()
		for _, tradeSkillButton in ipairs(TradeSkillFrame.RecipeList.buttons) do
			if not tradeSkillButton.headerIsHooked then
				hooksecurefunc(tradeSkillButton, "SetUpHeader", SkinRecipeList)
				tradeSkillButton.headerIsHooked = true
			end
		end
	end)

	--Guild Crafters
	S:HandleCloseButton(TradeSkillFrame.DetailsFrame.GuildFrame.CloseButton)
	S:HandleButton(TradeSkillFrame.DetailsFrame.ViewGuildCraftersButton)
	TradeSkillFrame.DetailsFrame.GuildFrame:StripTextures()
	TradeSkillFrame.DetailsFrame.GuildFrame:SetTemplate("Transparent")
	TradeSkillFrame.DetailsFrame.GuildFrame.Container:StripTextures()
	TradeSkillFrame.DetailsFrame.GuildFrame.Container:SetTemplate("Transparent")
	-- S:HandleScrollBar(TradeSkillFrame.DetailsFrame.GuildFrame.Container.ScrollFrame.scrollBar) --This cannot be skinned due to issues on Blizzards end.
	S:HandleScrollSlider(TradeSkillFrame.RecipeList.scrollBar)
end

S:AddCallbackForAddon("Blizzard_TradeSkillUI", "TradeSkill", LoadSkin)
