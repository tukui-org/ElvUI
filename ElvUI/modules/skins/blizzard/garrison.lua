local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.garrison ~= true then return end

	-- Building frame
	GarrisonBuildingFrame:StripTextures(true)
	GarrisonBuildingFrame.TitleText:Show()
	GarrisonBuildingFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(GarrisonBuildingFrame.CloseButton, GarrisonBuildingFrame.backdrop)
	GarrisonBuildingFrame.BuildingLevelTooltip:StripTextures()
	GarrisonBuildingFrame.BuildingLevelTooltip:SetTemplate('Transparent')

	-- Capacitive display frame
	GarrisonCapacitiveDisplayFrame:StripTextures(true)
	GarrisonCapacitiveDisplayFrame:CreateBackdrop("Transparent")
	GarrisonCapacitiveDisplayFrame.Inset:StripTextures()
	S:HandleCloseButton(GarrisonCapacitiveDisplayFrame.CloseButton, GarrisonCapacitiveDisplayFrame.backdrop)
	S:HandleButton(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, true)
	local CapacitiveDisplay = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay
	CapacitiveDisplay.IconBG:SetTexture()
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	CapacitiveDisplay.ShipmentIconFrame:SetTemplate("Default", true)
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetInside()
	--Fix unitframes appearing above work orders
	GarrisonCapacitiveDisplayFrame:SetFrameStrata("MEDIUM")
	GarrisonCapacitiveDisplayFrame:SetFrameLevel(45)

	do
		local reagentIndex = 1
		hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", function(self)
			local reagents = CapacitiveDisplay.Reagents
			local reagent = reagents[reagentIndex]
			while reagent do
				reagent.NameFrame:SetTexture()
				reagent.Icon:SetTexCoord(unpack(E.TexCoords))
				reagent.Icon:SetDrawLayer("BORDER")

				if not reagent.border then
					reagent.border = CreateFrame("Frame", nil, reagent)
					S:HandleIcon(reagent.Icon, reagent.border)
					reagent.Count:SetParent(reagent.border)
				end

				if not reagent.backdrop then
					reagent:CreateBackdrop("Default", true)
				end

				reagentIndex = reagentIndex + 1
				reagent = reagents[reagentIndex]
			end
		end)
	end

	-- Recruiter frame
	GarrisonRecruiterFrame:StripTextures(true)
	GarrisonRecruiterFrame:CreateBackdrop("Transparent")
	GarrisonRecruiterFrame.Inset:StripTextures()
	S:HandleCloseButton(GarrisonRecruiterFrame.CloseButton, GarrisonRecruiterFrame.backdrop)

	-- Recruiter Unavailable frame
	local UnavailableFrame = GarrisonRecruiterFrame.UnavailableFrame
	S:HandleButton(UnavailableFrame:GetChildren())

	-- Mission UI
	GarrisonMissionFrame:StripTextures(true)
	GarrisonMissionFrame.TitleText:Show()
	GarrisonMissionFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(GarrisonMissionFrame.CloseButton, GarrisonMissionFrame.backdrop)
	for i=1,2 do
		S:HandleTab(_G["GarrisonMissionFrameTab"..i])
	end

	GarrisonMissionFrameTab1:ClearAllPoints()
	GarrisonMissionFrameTab1:SetPoint("BOTTOMLEFT", 11, -40)

	-- Handle MasterPlan AddOn
	do
		local function skinMasterPlan()
			S:HandleTab(GarrisonMissionFrameTab3)
			local MissionPage = GarrisonMissionFrame.MissionTab.MissionPage
			S:HandleCloseButton(MissionPage.MinimizeButton, nil, "-")
			MissionPage.MinimizeButton:SetFrameLevel(MissionPage:GetFrameLevel() + 2)
		end

		if IsAddOnLoaded("MasterPlan") then
			skinMasterPlan()
		else
			local f = CreateFrame("Frame")
			f:RegisterEvent("ADDON_LOADED")
			f:SetScript("OnEvent", function(self, event, addon)
				if addon == "MasterPlan" then
					skinMasterPlan()
					self:UnregisterEvent("ADDON_LOADED")
				end
			end)
		end
	end

	-- Follower list
	local FollowerList = GarrisonMissionFrame.FollowerList
	FollowerList:DisableDrawLayer("BORDER")
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(FollowerList.listScroll.scrollBar)

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

	hooksecurefunc("GarrisonMissionButton_SetRewards", function(self, rewards, numRewards)
		if self.numRewardsStyled == nil then
			self.numRewardsStyled = 0
		end
		while self.numRewardsStyled < numRewards do
			self.numRewardsStyled = self.numRewardsStyled + 1
			local reward = self.Rewards[self.numRewardsStyled]
			local icon = reward.Icon
			reward:GetRegions():Hide()
			if not reward.border then
				reward.border = CreateFrame("Frame", nil, reward)
				S:HandleIcon(reward.Icon, reward.border)
			end
		end
	end)

	hooksecurefunc("GarrisonMissionPage_SetReward", function(frame, reward)
		frame.BG:SetTexture()
		if not frame.backdrop then
			S:HandleIcon(frame.Icon)
		end
		frame.Icon:SetDrawLayer("BORDER", 0)
	end)

	hooksecurefunc("GarrisonMissionPage_UpdateStartButton", function(missionPage)
		missionPage.StartMissionButton.Flash:Hide()
		missionPage.StartMissionButton.FlashAnim:Stop();
	end)

	-- Landing page
	-- GarrisonLandingPage:StripTextures(true) -- I actually like the look of this texture. Not sure if we want to remove it.
	GarrisonLandingPage:CreateBackdrop("Transparent")
	S:HandleCloseButton(GarrisonLandingPage.CloseButton, GarrisonLandingPage.backdrop)
	S:HandleTab(GarrisonLandingPageTab1)
	S:HandleTab(GarrisonLandingPageTab2)
	GarrisonLandingPageTab1:ClearAllPoints()
	GarrisonLandingPageTab1:SetPoint("TOPLEFT", GarrisonLandingPage, "BOTTOMLEFT", 70, 2)

	-- Report
	local Report = GarrisonLandingPage.Report
	Report.List:StripTextures(true)
	local scrollFrame = Report.List.listScroll
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
			end
		end
	end

	-- Follower list
	local FollowerList = GarrisonLandingPage.FollowerList
	select(2, FollowerList:GetRegions()):Hide()
	FollowerList.FollowerHeaderBar:Hide()
	S:HandleEditBox(FollowerList.SearchBox)
	local scrollFrame = FollowerList.listScroll
	S:HandleScrollBar(scrollFrame.scrollBar)

	hooksecurefunc("GarrisonFollowerButton_AddAbility", function(self, index)
		local ability = self.Abilities[index]
		if not ability.styled then
			local icon = ability.Icon
			S:HandleIcon(ability.Icon, ability)
			ability.styled = true
		end
	end)

	hooksecurefunc("GarrisonFollowerPage_ShowFollower", function(self, followerID)
		local abilities = self.AbilitiesFrame.Abilities
		if self.numAbilitiesStyled == nil then
			self.numAbilitiesStyled = 1
		end
		local numAbilitiesStyled = self.numAbilitiesStyled
		local ability = abilities[numAbilitiesStyled]
		while ability do
			local icon = ability.IconButton.Icon
			S:HandleIcon(icon, ability.IconButton)
			numAbilitiesStyled = numAbilitiesStyled + 1
			ability = abilities[numAbilitiesStyled]
		end
		self.numAbilitiesStyled = numAbilitiesStyled
	end)
end

local function SkinTooltip()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.garrison ~= true then return end

	local function restyleGarrisonFollowerTooltipTemplate(frame)
		for i = 1, 9 do
			select(i, frame:GetRegions()):Hide()
		end
		frame:SetTemplate("Transparent")
	end

	local function restyleGarrisonFollowerAbilityTooltipTemplate(frame)
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

	restyleGarrisonFollowerTooltipTemplate(GarrisonFollowerTooltip)
	restyleGarrisonFollowerAbilityTooltipTemplate(GarrisonFollowerAbilityTooltip)
	restyleGarrisonFollowerTooltipTemplate(FloatingGarrisonFollowerTooltip)
	S:HandleCloseButton(FloatingGarrisonFollowerTooltip.CloseButton)
	restyleGarrisonFollowerAbilityTooltipTemplate(FloatingGarrisonFollowerAbilityTooltip)
	S:HandleCloseButton(FloatingGarrisonFollowerAbilityTooltip.CloseButton)

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
end

S:RegisterSkin('Blizzard_GarrisonUI', LoadSkin)
S:RegisterSkin('ElvUI', SkinTooltip)