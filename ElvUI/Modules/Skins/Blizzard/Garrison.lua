local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack, pairs, ipairs, select = unpack, pairs, ipairs, select
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.garrison ~= true then return end

	--These hooks affect both Garrison and OrderHall, so make sure they are set even if Garrison skin is disabled
	hooksecurefunc("GarrisonMissionButton_SetRewards", function(self)
		--Set border color according to rarity of item
		local firstRegion, r, g, b
		local index = 0
		for _, reward in pairs(self.Rewards) do
			firstRegion = reward.GetRegions and reward:GetRegions()
			if firstRegion then firstRegion:Hide() end

			reward:ClearAllPoints()
			if IsAddOnLoaded("GarrisonMissionManager") then -- otherwise we mess with this AddOn
				reward:Point("TOPRIGHT", -E.mult * 65 + (index * -65), -E.mult)
			else
				reward:Point("TOPRIGHT", -E.mult + (index * -65), -E.mult)
			end

			if reward.IconBorder then
				reward.IconBorder:SetTexture()
			end

			if reward.IconBorder and reward.IconBorder:IsShown() then
				r, g, b = reward.IconBorder:GetVertexColor()
			else
				r, g, b = unpack(E.media.bordercolor)
			end

			if not reward.Icon.backdrop then
				S:HandleIcon(reward.Icon, true)
			end

			reward.Icon.backdrop:SetBackdropBorderColor(r, g, b)
			index = index + 1
		end
	end)

	hooksecurefunc("GarrisonMissionPage_SetReward", function(frame)
		frame.BG:SetTexture()
		if not frame.backdrop then
			S:HandleIcon(frame.Icon)
		end
		if frame.IconBorder then
			frame.IconBorder:SetTexture()
		end

		frame.Icon:SetDrawLayer("BORDER", 0)
	end)

	-- Building frame
	local GarrisonBuildingFrame = _G.GarrisonBuildingFrame
	GarrisonBuildingFrame:StripTextures(true)
	GarrisonBuildingFrame.TitleText:Show()
	GarrisonBuildingFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(GarrisonBuildingFrame.CloseButton, GarrisonBuildingFrame.backdrop)
	if E.private.skins.blizzard.tooltip then
		GarrisonBuildingFrame.BuildingLevelTooltip:StripTextures()
		GarrisonBuildingFrame.BuildingLevelTooltip:SetTemplate('Transparent')
	end

	-- Follower List
	local FollowerList = GarrisonBuildingFrame.FollowerList
	S:HandleScrollBar(FollowerList.listScroll.scrollBar)

	FollowerList:ClearAllPoints()
	FollowerList:Point("BOTTOMLEFT", 24, 34)

	local scrollFrame = FollowerList.listScroll
	S:HandleScrollBar(scrollFrame.scrollBar)

	-- Capacitive display frame
	local GarrisonCapacitiveDisplayFrame = _G.GarrisonCapacitiveDisplayFrame
	S:HandlePortraitFrame(GarrisonCapacitiveDisplayFrame, true)
	S:HandleButton(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, true)
	S:HandleButton(GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton, true)
	GarrisonCapacitiveDisplayFrame.Count:StripTextures()
	S:HandleEditBox(GarrisonCapacitiveDisplayFrame.Count)
	S:HandleNextPrevButton(GarrisonCapacitiveDisplayFrame.DecrementButton)
	S:HandleNextPrevButton(GarrisonCapacitiveDisplayFrame.IncrementButton)
	local CapacitiveDisplay = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay
	CapacitiveDisplay.IconBG:SetTexture()
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetInside()
	--Fix unitframes appearing above work orders
	GarrisonCapacitiveDisplayFrame:SetFrameStrata("MEDIUM")
	GarrisonCapacitiveDisplayFrame:SetFrameLevel(45)

	hooksecurefunc('GarrisonCapacitiveDisplayFrame_Update', function(self)
		for _, Reagent in ipairs(self.CapacitiveDisplay.Reagents) do
			if not Reagent.backdrop then
				Reagent.NameFrame:SetTexture()
				S:HandleIcon(Reagent.Icon, true)
				Reagent:CreateBackdrop()
			end
		end
	end)

	-- Recruiter frame
	S:HandlePortraitFrame(_G.GarrisonRecruiterFrame, true)

	-- Recruiter Unavailable frame
	local UnavailableFrame = _G.GarrisonRecruiterFrame.UnavailableFrame
	S:HandleButton(UnavailableFrame:GetChildren())

	-- Mission UI
	local GarrisonMissionFrame = _G.GarrisonMissionFrame
	GarrisonMissionFrame:StripTextures(true)
	GarrisonMissionFrame.TitleText:Show()
	GarrisonMissionFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(GarrisonMissionFrame.CloseButton, GarrisonMissionFrame.backdrop)

	for i = 1,2 do
		S:HandleTab(_G["GarrisonMissionFrameTab"..i])
	end

	_G.GarrisonMissionFrameTab1:ClearAllPoints()
	_G.GarrisonMissionFrameTab1:Point("BOTTOMLEFT", 11, -40)
	GarrisonMissionFrame.GarrCorners:Hide()

	-- Follower list
	FollowerList = GarrisonMissionFrame.FollowerList
	FollowerList:DisableDrawLayer("BORDER")
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(FollowerList.listScroll.scrollBar)
	hooksecurefunc(FollowerList, "ShowFollower", function(self)
		S:HandleFollowerPage(self, true)
	end)

	-- Mission list
	local MissionTab = GarrisonMissionFrame.MissionTab
	local MissionList = MissionTab.MissionList
	local MissionPage = GarrisonMissionFrame.MissionTab.MissionPage
	MissionList:DisableDrawLayer("BORDER")
	S:HandleScrollBar(MissionList.listScroll.scrollBar)
	S:HandleCloseButton(MissionPage.CloseButton)
	MissionPage.CloseButton:SetFrameLevel(MissionPage:GetFrameLevel() + 2)
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	S:HandleButton(MissionPage.StartMissionButton)
	S:HandleButton(GarrisonMissionFrame.MissionComplete.NextMissionButton)

	MissionPage.StartMissionButton.Flash:Hide()
	MissionPage.StartMissionButton.Flash.Show = E.noop
	MissionPage.StartMissionButton.FlashAnim:Stop()
	MissionPage.StartMissionButton.FlashAnim.Play = E.noop

	-- Landing page
	local GarrisonLandingPage = _G.GarrisonLandingPage
	local Report = GarrisonLandingPage.Report
	GarrisonLandingPage:CreateBackdrop("Transparent")
	S:HandleCloseButton(GarrisonLandingPage.CloseButton, GarrisonLandingPage.backdrop)
	S:HandleTab(_G.GarrisonLandingPageTab1)
	S:HandleTab(_G.GarrisonLandingPageTab2)
	S:HandleTab(_G.GarrisonLandingPageTab3)
	_G.GarrisonLandingPageTab1:ClearAllPoints()
	_G.GarrisonLandingPageTab1:Point("TOPLEFT", GarrisonLandingPage, "BOTTOMLEFT", 70, 2)

	if E.private.skins.parchmentRemover.enable then
		for i = 1, 10 do
			select(i, GarrisonLandingPage:GetRegions()):Hide()
		end

		for _, tab in pairs({Report.InProgress, Report.Available}) do
			tab:SetHighlightTexture("")
			tab.Text:ClearAllPoints()
			tab.Text:Point("CENTER")

			local bg = CreateFrame("Frame", nil, tab)
			bg:SetFrameLevel(tab:GetFrameLevel() - 1)
			bg:CreateBackdrop("Transparent")

			local selectedTex = bg:CreateTexture(nil, "BACKGROUND")
			selectedTex:SetAllPoints()
			selectedTex:SetColorTexture(unpack(E.media.rgbvaluecolor))
			selectedTex:SetAlpha(0.25)
			selectedTex:Hide()
			tab.selectedTex = selectedTex

			if tab == Report.InProgress then
				bg:Point("TOPLEFT", 5, 0)
				bg:Point("BOTTOMRIGHT")
			else
				bg:Point("TOPLEFT")
				bg:Point("BOTTOMRIGHT", -7, 0)
			end
		end

		hooksecurefunc("GarrisonLandingPageReport_SetTab", function(self)
			local unselectedTab = Report.unselectedTab
			unselectedTab:Height(36)
			unselectedTab:SetNormalTexture("")
			unselectedTab.selectedTex:Hide()

			self:SetNormalTexture("")
			self.selectedTex:Show()
		end)
	end

	-- Landing page: Report
	Report = GarrisonLandingPage.Report -- reassigned
	Report.List:StripTextures(true)
	scrollFrame = Report.List.listScroll
	S:HandleScrollBar(scrollFrame.scrollBar)
	local buttons = scrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		for _, reward in pairs(button.Rewards) do
			reward.Icon:SetTexCoord(unpack(E.TexCoords))
			if not reward.border then
				reward.border = CreateFrame("Frame", nil, reward)
				S:HandleIcon(reward.Icon, reward.border)
				reward.Quantity:SetParent(reward.border)
				reward.IconBorder:SetAlpha(0)
				-- For some reason, this fix icon border in 8.1
				reward:ClearAllPoints()
				reward:Point("TOPRIGHT", -5, -5)

				if E.private.skins.parchmentRemover.enable then
					button.BG:Hide()

					local bg = CreateFrame("Frame", nil, button)
					bg:Point("TOPLEFT")
					bg:Point("BOTTOMRIGHT", 0, 1)
					bg:SetFrameLevel(button:GetFrameLevel() - 1)
					bg:CreateBackdrop("Transparent")
				end
			end
		end
	end

	-- Landing page: Follower list
	FollowerList = GarrisonLandingPage.FollowerList
	FollowerList.FollowerHeaderBar:Hide()
	FollowerList.FollowerScrollFrame:Hide()
	S:HandleEditBox(FollowerList.SearchBox)
	scrollFrame = FollowerList.listScroll
	S:HandleScrollBar(scrollFrame.scrollBar)

	hooksecurefunc(FollowerList, "ShowFollower", function(self)
		S:HandleFollowerPage(self, nil, true)
	end)

	hooksecurefunc("GarrisonFollowerButton_AddAbility", function(self, index)
		local ability = self.Abilities[index]
		if not ability.styled then
			S:HandleIcon(ability.Icon, ability)
			ability.styled = true
		end
	end)

	-- Garrison Portraits
	S:HandleFollowerListOnUpdateData('GarrisonMissionFrameFollowers')
	S:HandleFollowerListOnUpdateData('GarrisonLandingPageFollowerList') -- this also applies to orderhall landing page

	-- Landing page: Fleet
	local ShipFollowerList = GarrisonLandingPage.ShipFollowerList
	ShipFollowerList.FollowerHeaderBar:Hide()
	S:HandleEditBox(ShipFollowerList.SearchBox)
	scrollFrame = ShipFollowerList.listScroll
	S:HandleScrollBar(scrollFrame.scrollBar)
	-- HandleShipFollowerPage(ShipFollowerList.followerTab)

	-- ShipYard
	local GarrisonShipyardFrame = _G.GarrisonShipyardFrame
	GarrisonShipyardFrame:StripTextures(true)
	GarrisonShipyardFrame.BorderFrame:StripTextures(true)
	GarrisonShipyardFrame:CreateBackdrop("Transparent")
	GarrisonShipyardFrame.backdrop:SetOutside(GarrisonShipyardFrame.BorderFrame)
	GarrisonShipyardFrame.BorderFrame.GarrCorners:Hide()
	S:HandleCloseButton(GarrisonShipyardFrame.BorderFrame.CloseButton2)
	S:HandleTab(_G.GarrisonShipyardFrameTab1)
	S:HandleTab(_G.GarrisonShipyardFrameTab2)

	-- ShipYard: Naval Map
	MissionTab = GarrisonShipyardFrame.MissionTab
	MissionList = MissionTab.MissionList
	MissionList:CreateBackdrop("Transparent")
	MissionList.backdrop:SetOutside(MissionList.MapTexture)
	MissionList.CompleteDialog.BorderFrame:StripTextures()
	MissionList.CompleteDialog.BorderFrame:SetTemplate("Transparent")

	-- ShipYard: Mission
	MissionPage = MissionTab.MissionPage
	S:HandleCloseButton(MissionPage.CloseButton)
	MissionPage.CloseButton:SetFrameLevel(MissionPage.CloseButton:GetFrameLevel() + 2)
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	S:HandleButton(GarrisonShipyardFrame.MissionComplete.NextMissionButton)
	MissionList.CompleteDialog:SetAllPoints(MissionList.MapTexture)
	GarrisonShipyardFrame.MissionCompleteBackground:SetAllPoints(MissionList.MapTexture)
	S:HandleButton(MissionPage.StartMissionButton)
	MissionPage.StartMissionButton.Flash:Hide()
	MissionPage.StartMissionButton.Flash.Show = E.noop
	MissionPage.StartMissionButton.FlashAnim:Stop()
	MissionPage.StartMissionButton.FlashAnim.Play = E.noop
	S:HandleButton(_G.GarrisonMissionFrameHelpBoxButton)

	-- ShipYard: Follower List
	FollowerList = GarrisonShipyardFrame.FollowerList
	scrollFrame = FollowerList.listScroll
	FollowerList:StripTextures()
	S:HandleScrollBar(scrollFrame.scrollBar)
	S:HandleEditBox(FollowerList.SearchBox)
	FollowerList.MaterialFrame:StripTextures()
	FollowerList.MaterialFrame.Icon:SetAtlas("ShipMission_CurrencyIcon-Oil", false) --Re-add the material icon
	-- HandleShipFollowerPage(FollowerList.followerTab)

	--LandingPage Tutorial
	S:HandleCloseButton(_G.GarrisonLandingPageTutorialBox.CloseButton)

	if E.private.skins.blizzard.tooltip ~= true then return end
	-- ShipYard: Mission Tooltip
	local tooltip = _G.GarrisonShipyardMapMissionTooltip
	local reward = tooltip.ItemTooltip
	local bonusReward = tooltip.BonusReward
	local icon = reward.Icon
	local bonusIcon = bonusReward.Icon
	tooltip:SetTemplate("Transparent")
	if icon then
		S:HandleIcon(icon)
		reward.IconBorder:SetTexture()
	end
	if bonusIcon then
		S:HandleIcon(bonusIcon) --TODO: Check how this actually looks
	end

	-- Threat Counter Tooltips
	-- The tooltip starts using blue backdrop and white border unless we re-set the template.
	-- We should check if there is a better way of doing this.
	S:HookScript(_G.GarrisonMissionMechanicFollowerCounterTooltip, "OnShow", function(self)
		self:SetTemplate("Transparent")
	end)
	S:HookScript(_G.GarrisonMissionMechanicTooltip, "OnShow", function(self)
		self:SetTemplate("Transparent")
	end)

	-- MissionFrame
	local OrderHallMissionFrame = _G.OrderHallMissionFrame
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.ClassHallIcon:Kill()
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.GarrCorners:Hide()
	OrderHallMissionFrame:CreateBackdrop("Transparent")
	OrderHallMissionFrame.backdrop:SetOutside(OrderHallMissionFrame.BorderFrame)
	S:HandleCloseButton(OrderHallMissionFrame.CloseButton)
	S:HandleCloseButton(_G.OrderHallMissionTutorialFrame.GlowBox.CloseButton)

	for i = 1, 3 do
		S:HandleTab(_G["OrderHallMissionFrameTab" .. i])
	end

	for _, Button in pairs(OrderHallMissionFrame.MissionTab.MissionList.listScroll.buttons) do
		if not Button.isSkinned then
			Button:StripTextures()
			Button:SetTemplate()
			S:HandleButton(Button)
			Button:SetBackdropBorderColor(0, 0, 0, 0)
			Button.LocBG:Hide()
			Button.isSkinned = true
		end
	end

	-- Followers
	local Follower = _G.OrderHallMissionFrameFollowers
	FollowerList = OrderHallMissionFrame.FollowerList -- swap
	local FollowerTab = OrderHallMissionFrame.FollowerTab
	Follower:StripTextures()
	Follower:SetTemplate("Transparent")
	FollowerList:StripTextures()
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(OrderHallMissionFrame.FollowerList.listScroll.scrollBar)
	hooksecurefunc(FollowerList, "ShowFollower", function(self)
		S:HandleFollowerPage(self, true, true)
	end)
	FollowerTab:StripTextures()
	FollowerTab.Class:Size(50, 43)
	FollowerTab.XPBar:StripTextures()
	FollowerTab.XPBar:SetStatusBarTexture(E.media.normTex)
	FollowerTab.XPBar:CreateBackdrop()

	-- Orderhall Portraits
	S:HandleFollowerListOnUpdateData('OrderHallMissionFrameFollowers')
	S:HandleFollowerListOnUpdateData('GarrisonLandingPageFollowerList') -- this also applies to garrison landing page

	-- Missions
	MissionTab = OrderHallMissionFrame.MissionTab -- swap
	local MissionComplete = OrderHallMissionFrame.MissionComplete
	MissionList = MissionTab.MissionList -- swap
	MissionPage = MissionTab.MissionPage -- swap
	local ZoneSupportMissionPage = MissionTab.ZoneSupportMissionPage
	S:HandleScrollBar(MissionList.listScroll.scrollBar)
	MissionList.CompleteDialog:StripTextures()
	MissionList.CompleteDialog:SetTemplate("Transparent")
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	MissionList:StripTextures()
	MissionList.listScroll:StripTextures()
	S:HandleButton(_G.OrderHallMissionFrameMissions.CombatAllyUI.InProgress.Unassign)
	S:HandleCloseButton(MissionPage.CloseButton)
	S:HandleButton(MissionPage.StartMissionButton)
	S:HandleCloseButton(ZoneSupportMissionPage.CloseButton)
	S:HandleButton(ZoneSupportMissionPage.StartMissionButton)
	S:HandleButton(MissionComplete.NextMissionButton)

	-- BFA Mission
	local MissionFrame = _G.BFAMissionFrame
	MissionFrame.OverlayElements:Hide()
	MissionFrame.TopBorder:Hide()
	MissionFrame.TopLeftCorner:Hide()
	MissionFrame.TopRightCorner:Hide()
	MissionFrame.RightBorder:Hide()
	MissionFrame.LeftBorder:Hide()
	MissionFrame.BotLeftCorner:Hide()
	MissionFrame.BotRightCorner:Hide()
	MissionFrame.BottomBorder:Hide()
	MissionFrame.GarrCorners:Hide()
	MissionFrame.TitleScroll:Hide()
	MissionFrame.BackgroundTile:Kill()
	MissionFrame.Left:Hide()
	MissionFrame.Bottom:Hide()
	MissionFrame.Top:Hide()
	MissionFrame.Right:Hide()

	MissionFrame:CreateBackdrop("Transparent")

	S:HandleCloseButton(MissionFrame.CloseButton)
	S:HandleButton(MissionFrame.MissionComplete.NextMissionButton)
	for i = 1, 3 do
		S:HandleTab(_G["BFAMissionFrameTab"..i])
	end

	-- Missions
	S:HandleButton(_G.BFAMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton)

	-- Mission Tab
	MissionTab = MissionFrame.MissionTab -- swap

	S:HandleCloseButton(MissionTab.MissionPage.CloseButton)
	S:HandleButton(MissionTab.MissionPage.StartMissionButton)
	S:HandleScrollBar(_G.BFAMissionFrameMissionsListScrollFrameScrollBar)

	-- Follower Tab
	Follower = _G.BFAMissionFrameFollowers -- swap
	local XPBar = MissionFrame.FollowerTab.XPBar
	local Class = MissionFrame.FollowerTab.Class
	Follower:StripTextures()
	Follower:SetTemplate("Transparent")
	S:HandleEditBox(Follower.SearchBox)
	hooksecurefunc(Follower, "ShowFollower", function(self)
		S:HandleFollowerPage(self, true, true)
	end)
	S:HandleScrollBar(_G.BFAMissionFrameFollowersListScrollFrameScrollBar)

	S:HandleFollowerListOnUpdateData("BFAMissionFrameFollowers") -- The function needs to be updated for BFA

	XPBar:StripTextures()
	XPBar:SetStatusBarTexture(E.media.normTex)
	XPBar:CreateBackdrop()

	Class:Size(50, 43)
end

local function SkinFollowerTooltip(frame)
	if not frame then return end

	S:HandleTooltipBorderedFrame(frame)
end

local function SkinAbilityTooltip(frame)
	if not frame then return end

	for i = 1, 9 do
		select(i, frame:GetRegions()):Hide()
	end
	local icon = frame.Icon
	icon:SetTexCoord(unpack(E.TexCoords))
	if not frame.border then
		frame.border = CreateFrame("Frame", nil, frame)
		S:HandleIcon(frame.Icon, frame.border)
	end
	frame:SetTemplate("Transparent")
end

local function SkinTooltip()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.garrison ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	SkinFollowerTooltip(_G.GarrisonFollowerTooltip)
	SkinFollowerTooltip(_G.FloatingGarrisonFollowerTooltip)
	SkinFollowerTooltip(_G.FloatingGarrisonMissionTooltip)
	SkinFollowerTooltip(_G.FloatingGarrisonShipyardFollowerTooltip)
	SkinFollowerTooltip(_G.GarrisonShipyardFollowerTooltip)

	SkinAbilityTooltip(_G.GarrisonFollowerAbilityTooltip)
	SkinAbilityTooltip(_G.FloatingGarrisonFollowerAbilityTooltip)
	SkinAbilityTooltip(_G.GarrisonFollowerMissionAbilityWithoutCountersTooltip)
	SkinAbilityTooltip(_G.GarrisonFollowerAbilityWithoutCountersTooltip)

	S:HandleCloseButton(_G.FloatingGarrisonFollowerTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonFollowerAbilityTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonMissionTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonShipyardFollowerTooltip.CloseButton)

	hooksecurefunc("GarrisonFollowerTooltipTemplate_SetGarrisonFollower", function(tooltipFrame)
		-- Abilities
		if tooltipFrame.numAbilitiesStyled == nil then
			tooltipFrame.numAbilitiesStyled = 1
		end
		local numAbilitiesStyled = tooltipFrame.numAbilitiesStyled
		local abilities = tooltipFrame.Abilities
		local ability = abilities[numAbilitiesStyled]
		while ability do
			local icon = ability.Icon
			icon:SetTexCoord(unpack(E.TexCoords))
			if not ability.border then
				ability.border = CreateFrame("Frame", nil, ability)
				S:HandleIcon(ability.Icon, ability.border)
			end

			numAbilitiesStyled = numAbilitiesStyled + 1
			ability = abilities[numAbilitiesStyled]
		end
		tooltipFrame.numAbilitiesStyled = numAbilitiesStyled

		-- Traits
		if tooltipFrame.numTraitsStyled == nil then
			tooltipFrame.numTraitsStyled = 1
		end
		local numTraitsStyled = tooltipFrame.numTraitsStyled
		local traits = tooltipFrame.Traits
		local trait = traits[numTraitsStyled]
		while trait do
			local icon = trait.Icon
			icon:SetTexCoord(unpack(E.TexCoords))
			if not trait.border then
				trait.border = CreateFrame("Frame", nil, trait)
				S:HandleIcon(trait.Icon, trait.border)
			end

			numTraitsStyled = numTraitsStyled + 1
			trait = traits[numTraitsStyled]
		end
		tooltipFrame.numTraitsStyled = numTraitsStyled
	end)

	hooksecurefunc("GarrisonFollowerTooltipTemplate_SetShipyardFollower", function(tooltipFrame)
		-- Properties
		if tooltipFrame.numPropertiesStyled == nil then
			tooltipFrame.numPropertiesStyled = 1
		end
		local numPropertiesStyled = tooltipFrame.numPropertiesStyled
		local properties = tooltipFrame.Properties
		local property = properties[numPropertiesStyled]
		while property do
			local icon = property.Icon
			icon:SetTexCoord(unpack(E.TexCoords))
			if not property.border then
				property.border = CreateFrame("Frame", nil, property)
				S:HandleIcon(property.Icon, property.border)
			end

			numPropertiesStyled = numPropertiesStyled + 1
			property = properties[numPropertiesStyled]
		end
		tooltipFrame.numPropertiesStyled = numPropertiesStyled
	end)
end

S:AddCallbackForAddon('Blizzard_GarrisonUI', "Garrison", LoadSkin)
S:AddCallback("GarrisonTooltips", SkinTooltip)
