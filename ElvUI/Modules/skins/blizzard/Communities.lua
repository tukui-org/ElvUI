local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local C_Timer_After = C_Timer.After
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Communities ~= true then return end

	local CommunitiesFrame = _G["CommunitiesFrame"]
	CommunitiesFrame:StripTextures()
	CommunitiesFrame.PortraitOverlay:Kill()
	CommunitiesFrame.PortraitOverlay.Portrait:Hide()
	CommunitiesFrame.PortraitOverlay.PortraitFrame:Hide()
	CommunitiesFrame.CommunitiesList.InsetFrame:StripTextures()
	CommunitiesFrame.TopBorder:Hide()
	CommunitiesFrame.LeftBorder:Hide()
	CommunitiesFrame.TopLeftCorner:Hide()

	CommunitiesFrame:CreateBackdrop("Transparent")

	CommunitiesFrameTopTileStreaks:Hide()
	CommunitiesFrameCommunitiesListListScrollFrame:StripTextures()
	CommunitiesFrameInsetBg:Hide()
	CommunitiesFrameInsetInsetBottomBorder:Hide()
	CommunitiesFrameInsetInsetBotLeftCorner:Hide()
	CommunitiesFrameInsetInsetBotRightCorner:Hide()
	CommunitiesFrameInsetInsetRightBorder:Hide()
	CommunitiesFrameInsetInsetLeftBorder:Hide()
	CommunitiesFrameInsetInsetTopBorder:Hide()
	CommunitiesFrameInsetInsetTopRightCorner:Hide()
	CommunitiesFrameCommunitiesListInsetBottomBorder:Hide()
	CommunitiesFrameCommunitiesListInsetBotRightCorner:Hide()
	CommunitiesFrameCommunitiesListInsetRightBorder:Hide()
	CommunitiesFrameInsetBottomBorder:Hide()
	CommunitiesFrameInsetLeftBorder:Hide()
	CommunitiesFrameInsetRightBorder:Hide()
	CommunitiesFrameInsetTopRightCorner:Hide()
	CommunitiesFrameInsetTopLeftCorner:Hide()
	CommunitiesFrameInsetTopBorder:Hide()
	CommunitiesFrameInsetBotRightCorner:Hide()
	CommunitiesFrameInsetBotLeftCorner:Hide()

	local function SkinTab(tab)
		local normTex = tab:GetNormalTexture()
		if normTex then
			normTex:SetTexCoord(unpack(E.TexCoords))
			normTex:SetInside()
		end

		if not tab.isSkinned then
			for i = 1, tab:GetNumRegions() do
				local region = select(i, tab:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetTexture() == "Interface\\SpellBook\\SpellBook-SkillLineTab" then
						region:Kill()
					end
				end
			end

			tab.pushed = true;
			tab:CreateBackdrop("Default")
			tab.backdrop:Point("TOPLEFT", -2, 2)
			tab.backdrop:Point("BOTTOMRIGHT", 2, -2)
			tab:StyleButton(true)
			tab.Icon:SetTexCoord(unpack(E.TexCoords))

			hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
				if texPath ~= nil then
					self:SetPushedTexture(nil);
				end
			end)

			hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
				if texPath ~= nil then
					self:SetHighlightTexture(nil);
				end
			end)

			local point, relatedTo, point2, _, y = tab:GetPoint()
			tab:Point(point, relatedTo, point2, 1, y)
		end

		tab.isSkinned = true
	end
	SkinTab(CommunitiesFrame.ChatTab)
	SkinTab(CommunitiesFrame.RosterTab)
	SkinTab(CommunitiesFrame.GuildBenefitsTab)
	SkinTab(CommunitiesFrame.GuildInfoTab)

	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)
	S:HandleCloseButton(CommunitiesFrameCloseButton)
	S:HandleButton(CommunitiesFrame.InviteButton)
	S:HandleButton(CommunitiesFrame.AddToChatButton)
	S:HandleButton(CommunitiesFrame.GuildFinderFrame.FindAGuildButton)

	select(2, CommunitiesFrame.MemberList.ListScrollFrame:GetChildren()):Hide() -- Hide default ScrollBar
	CommunitiesFrame.MemberList.ListScrollFrame.scrollBar = CreateFrame("Slider", nil, CommunitiesFrame.MemberList.ListScrollFrame, "HybridScrollBarTemplateFixed")
	S:HandleScrollBar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	CommunitiesFrame.MemberList.ListScrollFrame.scrollBar:SetFrameLevel(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar.trackbg:GetFrameLevel()) --Fix issue with background intercepting clicks
	C_Timer_After(0.25, function()
		--Scroll back to top
		CommunitiesFrame.MemberList.ListScrollFrame.scrollBar:SetValue(1)
		CommunitiesFrame.MemberList.ListScrollFrame.scrollBar:SetValue(0)
	end)


	--[[ FIX ME
	S:HandleScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollBar(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	S:HandleScrollBar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	S:HandleDropDownBox(CommunitiesFrame.StreamDropDownMenu)
	S:HandleDropDownBox(CommunitiesFrame.CommunitiesListDropDownMenu)
	]]

	-- [[ CHAT TAB ]]
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:SetTemplate("Transparent")

	CommunitiesFrame.Chat.InsetFrame:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate("Transparent")

	CommunitiesFrame.GuildFinderFrame:StripTextures()
	CommunitiesFrame.GuildFinderFrame.InsetFrame:StripTextures()

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:SetSize(120, 20)

	-- ROSTER TAB
	local MemberList = CommunitiesFrame.MemberList
	local ColumnDisplay = MemberList.ColumnDisplay
	ColumnDisplay:StripTextures()
	ColumnDisplay.InsetBorderLeft:Hide()
	ColumnDisplay.InsetBorderBottomLeft:Hide()
	ColumnDisplay.InsetBorderTopLeft:Hide()
	ColumnDisplay.InsetBorderTop:Hide()
	ColumnDisplay.Background:Hide()
	ColumnDisplay.TopTileStreaks:Hide()


	--[[FIX ME
	S:HandleDropDownBox(CommunitiesFrame.GuildMemberListDropDownMenu)
	]]
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)

	-- [[ PERKS TAB ]]
	local GuildBenefitsFrame = CommunitiesFrame.GuildBenefitsFrame
	GuildBenefitsFrame.InsetBorderLeft:Hide()
	GuildBenefitsFrame.InsetBorderRight:Hide()
	GuildBenefitsFrame.InsetBorderBottomRight:Hide()
	GuildBenefitsFrame.InsetBorderBottomLeft:Hide()
	GuildBenefitsFrame.InsetBorderTopRight:Hide()
	GuildBenefitsFrame.InsetBorderTopLeft:Hide()

	GuildBenefitsFrame.Perks:StripTextures()
	GuildBenefitsFrame.Perks.TitleText:FontTemplate(nil, 14)

	for i = 1, 5 do
		local button = _G["CommunitiesFrameContainerButton"..i]
		button:DisableDrawLayer("BACKGROUND")
		button:DisableDrawLayer("BORDER")
		button:CreateBackdrop("Default")

		button.Icon:SetTexCoord(unpack(E.TexCoords))
	end

	GuildBenefitsFrame.Rewards.TitleText:FontTemplate(nil, 14)

	GuildBenefitsFrame.Rewards.Bg:Hide()

	select(2, CommunitiesFrameRewards:GetChildren()):Hide()
	CommunitiesFrameRewards.scrollBar = CreateFrame("Slider", nil, CommunitiesFrameRewards, "HybridScrollBarTemplateFixed")
	S:HandleScrollBar(CommunitiesFrameRewards.scrollBar)
	CommunitiesFrameRewards.scrollBar:SetFrameLevel(CommunitiesFrameRewards.scrollBar.trackbg:GetFrameLevel()) --Fix issue with background intercepting clicks
	C_Timer_After(0.25, function()
		--Scroll back to top
		CommunitiesFrameRewards.scrollBar:SetValue(1)
		CommunitiesFrameRewards.scrollBar:SetValue(0)
	end)

	hooksecurefunc("CommunitiesGuildRewards_Update", function(self)
		local scrollFrame = self.RewardsContainer
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local buttons = scrollFrame.buttons
		local button, index
		local numButtons = #buttons
		local numRewards = GetNumGuildRewards()

		for i = 1, numButtons do
			button = buttons[i]
			index = offset + i
			button:CreateBackdrop("Default")

			button:SetNormalTexture("")
			button:SetHighlightTexture("")

			local hover = button:CreateTexture()
			hover:SetColorTexture(1, 1, 1, 0.3)
			hover:SetInside()
			button.hover = hover
			button:SetHighlightTexture(hover)

			button.Icon:SetTexCoord(unpack(E.TexCoords))

			button.index = index
		end
	end)

	-- [[ INFO TAB ]]
	CommunitiesFrameGuildDetailsFrame.InsetBorderLeft:Hide()
	CommunitiesFrameGuildDetailsFrame.InsetBorderRight:Hide()
	CommunitiesFrameGuildDetailsFrame.InsetBorderBottomRight:Hide()
	CommunitiesFrameGuildDetailsFrame.InsetBorderBottomLeft:Hide()
	CommunitiesFrameGuildDetailsFrame.InsetBorderTopRight:Hide()
	CommunitiesFrameGuildDetailsFrame.InsetBorderTopLeft:Hide()

	local striptextures = {
		"CommunitiesFrameGuildDetailsFrameInfo",
		"CommunitiesFrameGuildDetailsFrameNews",
		"CommunitiesGuildNewsFiltersFrame",
	}

	for _, frame in pairs(striptextures) do
		_G[frame]:StripTextures()
	end

	CommunitiesFrameGuildDetailsFrameInfo.TitleText:FontTemplate(nil, 14)
	CommunitiesFrameGuildDetailsFrameNews.TitleText:FontTemplate(nil, 14)


	S:HandleScrollBar(CommunitiesFrameGuildDetailsFrameInfoScrollBar)
	--S:HandleScrollBar(CommunitiesFrameGuildDetailsFrameNewsContainer.ScrollBar)
	S:HandleButton(CommunitiesFrame.GuildLogButton)

	-- Filters Frame
	local FiltersFrame = _G["CommunitiesGuildNewsFiltersFrame"]
	FiltersFrame:CreateBackdrop("Transparent")
	S:HandleCheckBox(FiltersFrame.GuildAchievement)
	S:HandleCheckBox(FiltersFrame.Achievement)
	S:HandleCheckBox(FiltersFrame.DungeonEncounter)
	S:HandleCheckBox(FiltersFrame.EpicItemLooted)
	S:HandleCheckBox(FiltersFrame.EpicItemCrafted)
	S:HandleCheckBox(FiltersFrame.EpicItemPurchased)
	S:HandleCheckBox(FiltersFrame.LegendaryItemLooted)

	S:HandleCloseButton(FiltersFrame.CloseButton)

	-- Guild Log
	CommunitiesGuildLogFrame:StripTextures()
	CommunitiesGuildLogFrame.Container:StripTextures()
	CommunitiesGuildLogFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(CommunitiesGuildLogFrameScrollBar, 4)
	S:HandleCloseButton(CommunitiesGuildLogFrameCloseButton)
	--S:HandleButton(CommunitiesGuildLogFrameCloseButton) -- The same name as the CloseButton dafuq?!

	-- Recruitment Info
	CommunitiesGuildRecruitmentFrame:StripTextures()
	CommunitiesGuildRecruitmentFrame:CreateBackdrop("Transparent")
	CommunitiesGuildRecruitmentFrameInset:StripTextures(false)

	-- CheckBoxes
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.QuestButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.DungeonButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.RaidButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.PvPButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.RPButton)

	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekdaysButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekendsButton)

	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame.TankButton.checkButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame.HealerButton.checkButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame.DamagerButton.checkButton)

	S:HandleCloseButton(CommunitiesGuildRecruitmentFrameCloseButton)

	CommunitiesGuildRecruitmentFrameRecruitment.ListGuildButton.LeftSeparator:Hide()
	S:HandleButton(CommunitiesGuildRecruitmentFrameRecruitment.ListGuildButton)

	-- Tabs
	for i = 1, 2 do
		S:HandleTab(_G["CommunitiesGuildRecruitmentFrameTab"..i])
	end

	CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame:StripTextures()
	S:HandleEditBox(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame)

	-- Recruitment Request
	CommunitiesGuildRecruitmentFrameApplicants.InviteButton.RightSeparator:Hide()
	CommunitiesGuildRecruitmentFrameApplicants.DeclineButton.LeftSeparator:Hide()

	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.InviteButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.MessageButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.DeclineButton)

	for i = 1, 5 do
		local bu = _G["CommunitiesGuildRecruitmentFrameApplicantsContainerButton"..i]
		bu:SetBackdrop(nil)
	end
end

S:AddCallbackForAddon("Blizzard_Communities", "Communities", LoadSkin)