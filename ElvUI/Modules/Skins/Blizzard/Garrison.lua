local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local unpack, pairs, ipairs, select = unpack, pairs, ipairs, select

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function showFollower(s)
	S:HandleFollowerAbilities(s)
end

local function UpdateFollowerColorOnBoard(self, _, info)
	if self.Portrait.backdrop then
		local color = E.QualityColors[info.quality or 1]
		self.Portrait.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end

local function ResetFollowerColorOnBoard(self)
	if self.Portrait.backdrop then
		self.Portrait.backdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

local function SkinFollowerBoard(self, group)
	for socketTexture in self[group..'SocketFramePool']:EnumerateActive() do
		socketTexture:DisableDrawLayer('BACKGROUND')
	end

	for frame in self[group..'FramePool']:EnumerateActive() do
		if not frame.IsSkinned then
			S:HandleGarrisonPortrait(frame)
			frame.PuckShadow:SetAlpha(0)

			if frame.SetFollowerGUID then
				hooksecurefunc(frame, 'SetFollowerGUID', UpdateFollowerColorOnBoard)
			end
			if frame.SetEmpty then
				hooksecurefunc(frame, 'SetEmpty', ResetFollowerColorOnBoard)
			end

			frame.IsSkinned = true
		end
	end
end

local function SkinMissionBoards(board)
	SkinFollowerBoard(board, 'enemy')
	SkinFollowerBoard(board, 'follower')
end

local function UpdateSpellAbilities(spell, followerInfo)
	local autoSpellInfo = followerInfo.autoSpellAbilities
	for _ in ipairs(autoSpellInfo) do
		local abilityFrame = spell.autoSpellPool:Acquire()
		if not abilityFrame.IsSkinned then
			S:HandleIcon(abilityFrame.Icon, true)

			if abilityFrame.SpellBorder then
				abilityFrame.SpellBorder:Hide()
			end
			abilityFrame.IsSkinned = true
		end
	end
end

local function ReskinMissionComplete(frame)
	local missionComplete = frame.MissionComplete
	local bonusRewards = missionComplete.BonusRewards

	if bonusRewards then
		select(11, bonusRewards:GetRegions()):SetTextColor(1, .8, 0)
		bonusRewards.Saturated:StripTextures()
		for i = 1, 9 do
			select(i, bonusRewards:GetRegions()):SetAlpha(0)
		end
		bonusRewards:SetTemplate()
	end

	if missionComplete.NextMissionButton then
		S:HandleButton(missionComplete.NextMissionButton)
	end

	if missionComplete.CompleteFrame then
		if E.private.skins.parchmentRemoverEnable then
			missionComplete:StripTextures()
		end

		missionComplete:CreateBackdrop('Transparent')
		missionComplete.backdrop:SetPoint("TOPLEFT", 3, 2)
		missionComplete.backdrop:SetPoint("BOTTOMRIGHT", -3, -10)

		if E.private.skins.parchmentRemoverEnable then
			missionComplete.CompleteFrame:StripTextures()
		end
		S:HandleButton(missionComplete.CompleteFrame.ContinueButton)
		S:HandleButton(missionComplete.CompleteFrame.SpeedButton)
		S:HandleButton(missionComplete.RewardsScreen.FinalRewardsPanel.ContinueButton)
	end

	if missionComplete.MissionInfo then
		missionComplete.MissionInfo:StripTextures()
	end
	if missionComplete.EnemyBackground then missionComplete.EnemyBackground:Hide() end
	if missionComplete.FollowerBackground then missionComplete.FollowerBackground:Hide() end
end

-- TO DO: Extend this function
local function SkinMissionFrame(frame, strip)
	if strip then
		frame:StripTextures()
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
	end

	frame.CloseButton:StripTextures()
	S:HandleCloseButton(frame.CloseButton)

	if frame.GarrCorners then frame.GarrCorners:Hide() end
	if frame.OverlayElements then frame.OverlayElements:SetAlpha(0) end

	for i = 1, 3 do
		local tab = _G[frame:GetName()..'Tab'..i]
		if tab then S:HandleTab(tab) end
	end

	if frame.MapTab then
		frame.MapTab.ScrollContainer.Child.TiledBackground:Hide()
	end

	ReskinMissionComplete(frame)

	hooksecurefunc(frame.FollowerTab, 'UpdateCombatantStats', UpdateSpellAbilities)

	for _, item in pairs({frame.FollowerTab.ItemWeapon, frame.FollowerTab.ItemArmor}) do
		if item then
			local icon = item.Icon
			item.Border:Hide()
			S:HandleIcon(icon)
		end
	end
end

-- Blizzard didn't set color for currency reward, incorrect color presents after scroll (Credits: siweia - NDui)
local function FixLandingPageRewardBorder(icon)
	local reward = icon:GetParent()
	if reward and not reward.itemID then
		reward.Icon.backdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

function S:Blizzard_GarrisonUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.garrison) then return end

	--These hooks affect both Garrison and OrderHall, so make sure they are set even if Garrison skin is disabled
	hooksecurefunc('GarrisonMissionButton_SetRewards', function(s)
		--Set border color according to rarity of item
		local firstRegion, r, g, b
		local index = 0
		for _, reward in pairs(s.Rewards) do
			firstRegion = reward.GetRegions and reward:GetRegions()
			if firstRegion then firstRegion:Hide() end

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

	hooksecurefunc('GarrisonMissionPage_SetReward', function(frame)
		frame.BG:SetTexture()
		if not frame.backdrop then
			S:HandleIcon(frame.Icon)
		end
		if frame.IconBorder then
			frame.IconBorder:SetTexture()
		end

		frame.Icon:SetDrawLayer('BORDER', 0)
	end)

	hooksecurefunc('GarrisonMissionPortrait_SetFollowerPortrait', function(portraitFrame, followerInfo)
		if not portraitFrame.IsSkinned then
			S:HandleGarrisonPortrait(portraitFrame)
			portraitFrame.IsSkinned = true
		end

		local color = _G.ITEM_QUALITY_COLORS[followerInfo.quality]
		portraitFrame.Portrait.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		portraitFrame.Portrait.backdrop:Show()
	end)

	-- Building frame
	local GarrisonBuildingFrame = _G.GarrisonBuildingFrame
	GarrisonBuildingFrame:StripTextures(true)
	GarrisonBuildingFrame.TitleText:Show()
	GarrisonBuildingFrame:SetTemplate('Transparent')

	S:HandleCloseButton(GarrisonBuildingFrame.CloseButton, GarrisonBuildingFrame.backdrop)

	-- Follower List
	local FollowerList = GarrisonBuildingFrame.FollowerList
	S:HandleScrollBar(FollowerList.listScroll.scrollBar)

	FollowerList:ClearAllPoints()
	FollowerList:Point('BOTTOMLEFT', 24, 34)

	local scrollFrame = FollowerList.listScroll
	S:HandleScrollBar(scrollFrame.scrollBar)

	-- Capacitive display frame
	local GarrisonCapacitiveDisplayFrame = _G.GarrisonCapacitiveDisplayFrame
	S:HandlePortraitFrame(GarrisonCapacitiveDisplayFrame)
	S:HandleButton(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton)
	S:HandleButton(GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton)
	GarrisonCapacitiveDisplayFrame.Count:StripTextures()
	S:HandleEditBox(GarrisonCapacitiveDisplayFrame.Count)
	S:HandleNextPrevButton(GarrisonCapacitiveDisplayFrame.DecrementButton)
	S:HandleNextPrevButton(GarrisonCapacitiveDisplayFrame.IncrementButton)
	local CapacitiveDisplay = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay
	CapacitiveDisplay.IconBG:SetTexture()
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetInside()
	--Fix unitframes appearing above work orders
	GarrisonCapacitiveDisplayFrame:SetFrameStrata('MEDIUM')
	GarrisonCapacitiveDisplayFrame:SetFrameLevel(45)

	hooksecurefunc('GarrisonCapacitiveDisplayFrame_Update', function(s)
		for _, Reagent in ipairs(s.CapacitiveDisplay.Reagents) do
			if not Reagent.template then
				Reagent:SetTemplate()
				Reagent.NameFrame:SetTexture()
				Reagent.Icon:SetDrawLayer('ARTWORK')
				Reagent.Icon:ClearAllPoints()
				Reagent.Icon:SetPoint('TOPLEFT', 1, -1)
				S:HandleIcon(Reagent.Icon)
			end
		end
	end)

	-- Recruiter frame
	S:HandlePortraitFrame(_G.GarrisonRecruiterFrame)

	-- Recruiter Unavailable frame
	local UnavailableFrame = _G.GarrisonRecruiterFrame.UnavailableFrame
	S:HandleButton(UnavailableFrame:GetChildren())

	-- Mission UI
	local GarrisonMissionFrame = _G.GarrisonMissionFrame
	GarrisonMissionFrame:StripTextures(true)
	GarrisonMissionFrame.TitleText:Show()
	GarrisonMissionFrame:SetTemplate('Transparent')
	S:HandleCloseButton(GarrisonMissionFrame.CloseButton, GarrisonMissionFrame.backdrop)

	for i = 1,2 do
		S:HandleTab(_G['GarrisonMissionFrameTab'..i])
	end

	_G.GarrisonMissionFrameTab1:ClearAllPoints()
	_G.GarrisonMissionFrameTab1:Point('BOTTOMLEFT', 11, -40)
	GarrisonMissionFrame.GarrCorners:Hide()

	-- Follower list
	FollowerList = GarrisonMissionFrame.FollowerList
	FollowerList:DisableDrawLayer('BORDER')
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(FollowerList.listScroll.scrollBar)
	hooksecurefunc(FollowerList, 'ShowFollower', showFollower)

	-- Mission list
	local MissionTab = GarrisonMissionFrame.MissionTab
	local MissionList = MissionTab.MissionList
	local MissionPage = GarrisonMissionFrame.MissionTab.MissionPage
	MissionList:DisableDrawLayer('BORDER')
	S:HandleScrollBar(MissionList.listScroll.scrollBar)
	S:HandleCloseButton(MissionPage.CloseButton)
	MissionPage.CloseButton:SetFrameLevel(MissionPage:GetFrameLevel() + 2)
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	S:HandleButton(GarrisonMissionFrame.MissionComplete.NextMissionButton)
	S:HandleButton(MissionPage.StartMissionButton)
	MissionPage.StartMissionButton.Flash:Kill()

	-- Landing page
	local GarrisonLandingPage = _G.GarrisonLandingPage
	local Report = GarrisonLandingPage.Report
	GarrisonLandingPage:SetTemplate('Transparent')
	S:HandleCloseButton(GarrisonLandingPage.CloseButton, GarrisonLandingPage.backdrop)
	S:HandleTab(_G.GarrisonLandingPageTab1)
	S:HandleTab(_G.GarrisonLandingPageTab2)
	S:HandleTab(_G.GarrisonLandingPageTab3)
	_G.GarrisonLandingPageTab1:ClearAllPoints()
	_G.GarrisonLandingPageTab1:Point('TOPLEFT', GarrisonLandingPage, 'BOTTOMLEFT', 70, 2)

	if E.private.skins.parchmentRemoverEnable then
		for i = 1, 10 do
			select(i, GarrisonLandingPage:GetRegions()):Hide()
		end

		for _, tab in pairs({Report.InProgress, Report.Available}) do
			tab:SetHighlightTexture('')
			tab.Text:ClearAllPoints()
			tab.Text:Point('CENTER')

			local bg = CreateFrame('Frame', nil, tab)
			bg:SetFrameLevel(tab:GetFrameLevel() - 1)
			bg:SetTemplate('Transparent')

			local selectedTex = bg:CreateTexture(nil, 'BACKGROUND')
			selectedTex:SetAllPoints()
			selectedTex:SetColorTexture(unpack(E.media.rgbvaluecolor))
			selectedTex:SetAlpha(0.25)
			selectedTex:Hide()
			tab.selectedTex = selectedTex

			if tab == Report.InProgress then
				bg:Point('TOPLEFT', 5, 0)
				bg:Point('BOTTOMRIGHT')
			else
				bg:Point('TOPLEFT')
				bg:Point('BOTTOMRIGHT', -7, 0)
			end
		end

		hooksecurefunc('GarrisonLandingPageReport_SetTab', function(s)
			local unselectedTab = Report.unselectedTab
			unselectedTab:Height(36)
			unselectedTab:SetNormalTexture('')
			unselectedTab.selectedTex:Hide()

			s:SetNormalTexture('')
			s.selectedTex:Show()
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
				reward.border = CreateFrame('Frame', nil, reward)
				S:HandleIcon(reward.Icon, reward.border)
				S:HandleIconBorder(reward.IconBorder, reward.Icon.backdrop)
				hooksecurefunc(reward.Icon, "SetTexture", FixLandingPageRewardBorder)
				reward.Quantity:SetParent(reward.border)
				reward:ClearAllPoints()
				reward:Point('TOPRIGHT', -5, -5)

				if E.private.skins.parchmentRemoverEnable then
					button.BG:Hide()

					local bg = CreateFrame('Frame', nil, button)
					bg:Point('TOPLEFT')
					bg:Point('BOTTOMRIGHT', 0, 1)
					bg:SetFrameLevel(button:GetFrameLevel() - 1)
					bg:SetTemplate('Transparent')
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

	hooksecurefunc(FollowerList, 'ShowFollower', showFollower)

	hooksecurefunc('GarrisonFollowerButton_AddAbility', function(s, index)
		local ability = s.Abilities[index]
		if not ability.styled then
			S:HandleIcon(ability.Icon, ability)
			ability.styled = true
		end
	end)

	-- Garrison Portraits
	S:HandleFollowerListOnUpdateData('GarrisonMissionFrameFollowers')
	S:HandleFollowerListOnUpdateData('GarrisonLandingPageFollowerList') -- this also applies to orderhall landing page

	local FollowerTab = GarrisonLandingPage.FollowerTab
	hooksecurefunc(FollowerTab, 'UpdateCombatantStats', UpdateSpellAbilities)

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
	GarrisonShipyardFrame:SetTemplate('Transparent')
	GarrisonShipyardFrame.BorderFrame.GarrCorners:Hide()
	S:HandleCloseButton(GarrisonShipyardFrame.BorderFrame.CloseButton2)
	S:HandleTab(_G.GarrisonShipyardFrameTab1)
	S:HandleTab(_G.GarrisonShipyardFrameTab2)

	-- ShipYard: Naval Map
	MissionTab = GarrisonShipyardFrame.MissionTab
	MissionList = MissionTab.MissionList
	MissionList:SetTemplate('Transparent')
	MissionList.CompleteDialog.BorderFrame:StripTextures()
	MissionList.CompleteDialog.BorderFrame:SetTemplate('Transparent')

	-- ShipYard: Mission
	MissionPage = MissionTab.MissionPage
	S:HandleCloseButton(MissionPage.CloseButton)
	MissionPage.CloseButton:SetFrameLevel(MissionPage.CloseButton:GetFrameLevel() + 2)
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	S:HandleButton(GarrisonShipyardFrame.MissionComplete.NextMissionButton)
	MissionList.CompleteDialog:SetAllPoints(MissionList.MapTexture)
	GarrisonShipyardFrame.MissionCompleteBackground:SetAllPoints(MissionList.MapTexture)
	S:HandleButton(MissionPage.StartMissionButton)
	MissionPage.StartMissionButton.Flash:Kill()

	-- ShipYard: Follower List
	FollowerList = GarrisonShipyardFrame.FollowerList
	scrollFrame = FollowerList.listScroll
	FollowerList:StripTextures()
	S:HandleScrollBar(scrollFrame.scrollBar)
	S:HandleEditBox(FollowerList.SearchBox)
	FollowerList.MaterialFrame:StripTextures()
	FollowerList.MaterialFrame.Icon:SetAtlas('ShipMission_CurrencyIcon-Oil', false) --Re-add the material icon
	-- HandleShipFollowerPage(FollowerList.followerTab)

	-- MissionFrame
	local OrderHallMissionFrame = _G.OrderHallMissionFrame
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.ClassHallIcon:Kill()
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.GarrCorners:Hide()
	OrderHallMissionFrame:SetTemplate('Transparent')
	S:HandleCloseButton(OrderHallMissionFrame.CloseButton)

	for i = 1, 3 do
		S:HandleTab(_G['OrderHallMissionFrameTab' .. i])
	end

	-- Followers
	local Follower = _G.OrderHallMissionFrameFollowers
	FollowerList = OrderHallMissionFrame.FollowerList -- swap
	FollowerTab = OrderHallMissionFrame.FollowerTab -- swap
	Follower:StripTextures()
	Follower:SetTemplate('Transparent')
	FollowerList:StripTextures()
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(OrderHallMissionFrame.FollowerList.listScroll.scrollBar)
	hooksecurefunc(FollowerList, 'ShowFollower', showFollower)
	FollowerTab:StripTextures()
	FollowerTab.Class:Size(50, 43)
	FollowerTab.XPBar:StripTextures()
	FollowerTab.XPBar:SetStatusBarTexture(E.media.normTex)
	FollowerTab.XPBar:SetTemplate()

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
	MissionList.CompleteDialog:SetTemplate('Transparent')
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	MissionList:StripTextures()
	MissionList.listScroll:StripTextures()
	S:HandleButton(_G.OrderHallMissionFrameMissions.CombatAllyUI.InProgress.Unassign)
	S:HandleCloseButton(MissionPage.CloseButton)
	S:HandleCloseButton(ZoneSupportMissionPage.CloseButton)
	S:HandleButton(MissionComplete.NextMissionButton)
	S:HandleButton(MissionPage.StartMissionButton)
	MissionPage.StartMissionButton.Flash:Kill()
	S:HandleButton(ZoneSupportMissionPage.StartMissionButton)
	ZoneSupportMissionPage.StartMissionButton.Flash:Kill()

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

	MissionFrame:SetTemplate('Transparent')

	S:HandleCloseButton(MissionFrame.CloseButton)
	S:HandleButton(MissionFrame.MissionComplete.NextMissionButton)
	for i = 1, 3 do
		S:HandleTab(_G['BFAMissionFrameTab'..i])
	end

	-- Missions
	S:HandleButton(_G.BFAMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton)

	-- Mission Tab
	MissionTab = MissionFrame.MissionTab -- swap
	S:HandleCloseButton(MissionTab.MissionPage.CloseButton)
	S:HandleScrollBar(_G.BFAMissionFrameMissionsListScrollFrameScrollBar)
	S:HandleButton(MissionTab.MissionPage.StartMissionButton)
	MissionTab.MissionPage.StartMissionButton.Flash:Kill()

	-- Follower Tab
	Follower = _G.BFAMissionFrameFollowers -- swap
	local XPBar = MissionFrame.FollowerTab.XPBar
	local Class = MissionFrame.FollowerTab.Class
	Follower:StripTextures()
	Follower:SetTemplate('Transparent')
	S:HandleEditBox(Follower.SearchBox)
	hooksecurefunc(Follower, 'ShowFollower', showFollower)
	S:HandleScrollBar(_G.BFAMissionFrameFollowersListScrollFrameScrollBar)

	S:HandleFollowerListOnUpdateData('BFAMissionFrameFollowers') -- The function needs to be updated for BFA

	XPBar:StripTextures()
	XPBar:SetStatusBarTexture(E.media.normTex)
	XPBar:CreateBackdrop()

	Class:Size(50, 43)

	-- Shadowlands Mission
	local CovenantMissionFrame = _G.CovenantMissionFrame

	if E.private.skins.parchmentRemoverEnable then
		SkinMissionFrame(CovenantMissionFrame, true)

		hooksecurefunc(CovenantMissionFrame, 'SetupTabs', function(frame)
			frame.MapTab:SetShown(not frame.Tab2:IsShown())
		end)
	else
		SkinMissionFrame(CovenantMissionFrame)
	end

	S:HandleIcon(_G.CovenantMissionFrameMissions.MaterialFrame.Icon)
	_G.CovenantMissionFrameMissions.RaisedFrameEdges:SetAlpha(0)

	if CovenantMissionFrame.RaisedBorder then
		CovenantMissionFrame.RaisedBorder:SetAlpha(0)
	end

	-- Complete Missions
	_G.CombatLog.ElevatedFrame:SetAlpha(0)
	_G.CombatLog.CombatLogMessageFrame:StripTextures()
	_G.CombatLog.CombatLogMessageFrame:SetTemplate('Transparent')

	-- Adventures / Follower Tab
	Follower = _G.CovenantMissionFrameFollowers -- swap
	FollowerTab = CovenantMissionFrame.FollowerTab

	hooksecurefunc(Follower, 'ShowFollower', showFollower)
	Follower:StripTextures()
	Follower:SetTemplate('Transparent')

	FollowerTab:StripTextures()
	FollowerTab.RaisedFrameEdges:SetAlpha(0)
	S:HandleIcon(CovenantMissionFrame.FollowerTab.HealFollowerFrame.CostFrame.CostIcon)

	S:HandleFollowerListOnUpdateData('CovenantMissionFrameFollowers')

	if Follower.HealAllButton then
		S:HandleButton(Follower.HealAllButton)
	end
	if _G.HealFollowerButtonTemplate then
		S:HandleButton(_G.HealFollowerButtonTemplate)
	end

	-- Mission Tab
	S:HandleCloseButton(CovenantMissionFrame.MissionTab.MissionPage.CloseButton)
	S:HandleIcon(CovenantMissionFrame.MissionTab.MissionPage.CostFrame.CostIcon)
	S:HandleButton(CovenantMissionFrame.MissionTab.MissionPage.StartMissionButton)
	CovenantMissionFrame.MissionTab.MissionPage.StartMissionButton.Flash:Kill()

	CovenantMissionFrame.MissionTab.MissionPage.Board:HookScript('OnShow', SkinMissionBoards)
	CovenantMissionFrame.MissionComplete.Board:HookScript('OnShow', SkinMissionBoards)

	if E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip then
		S:GarrisonTooltips()
	end
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
		frame.border = CreateFrame('Frame', nil, frame)
		S:HandleIcon(frame.Icon, frame.border)
	end

	frame:SetTemplate('Transparent')
end

function S:GarrisonTooltips()
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

	hooksecurefunc('GarrisonFollowerTooltipTemplate_SetGarrisonFollower', function(tooltipFrame)
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
				ability.border = CreateFrame('Frame', nil, ability)
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
				trait.border = CreateFrame('Frame', nil, trait)
				S:HandleIcon(trait.Icon, trait.border)
			end

			numTraitsStyled = numTraitsStyled + 1
			trait = traits[numTraitsStyled]
		end
		tooltipFrame.numTraitsStyled = numTraitsStyled
	end)

	hooksecurefunc('GarrisonFollowerTooltipTemplate_SetShipyardFollower', function(tooltipFrame)
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
				property.border = CreateFrame('Frame', nil, property)
				S:HandleIcon(property.Icon, property.border)
			end

			numPropertiesStyled = numPropertiesStyled + 1
			property = properties[numPropertiesStyled]
		end
		tooltipFrame.numPropertiesStyled = numPropertiesStyled
	end)

	do -- ShipYard: Mission Tooltip
		local tooltip = _G.GarrisonShipyardMapMissionTooltip
		tooltip:StripTextures()
		TT:SetStyle(tooltip)

		local reward = tooltip.ItemTooltip
		local icon = reward and reward.Icon
		if icon then
			S:HandleIcon(icon)

			if reward.IconBorder then
				reward.IconBorder:SetAlpha(0)
			end
		end

		local bonusIcon = tooltip.BonusReward and tooltip.BonusReward.Icon
		if bonusIcon then S:HandleIcon(bonusIcon) end
	end

	-- Threat Counter Tooltips
	_G.GarrisonMissionMechanicFollowerCounterTooltip:SetTemplate('Transparent')
	_G.GarrisonMissionMechanicTooltip:SetTemplate('Transparent')

	_G.GarrisonBuildingFrame.BuildingLevelTooltip:StripTextures()
	_G.GarrisonBuildingFrame.BuildingLevelTooltip:SetTemplate('Transparent')
end

S:AddCallbackForAddon('Blizzard_GarrisonUI')
