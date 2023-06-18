local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
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
	for _ in ipairs(followerInfo.autoSpellAbilities) do
		local abilityFrame = spell.autoSpellPool:Acquire()
		if not abilityFrame.IsSkinned then
			S:HandleIcon(abilityFrame.Icon, true)

			if abilityFrame.IconMask then
				abilityFrame.IconMask:Hide()
			end

			if abilityFrame.SpellBorder then
				abilityFrame.SpellBorder:Hide()
			end

			abilityFrame.IsSkinned = true
		end
	end
end

local function ReskinMissionButton(button)
	if not button.IsSkinned then
		local rareOverlay = button.RareOverlay
		local rareText = button.RareText

		button.LocBG:SetDrawLayer('BACKGROUND')
		if button.ButtonBG then button.ButtonBG:Hide() end
		button:StripTextures()
		button:CreateBackdrop('Transparent')
		button.Highlight:SetColorTexture(.6, .8, 1, .15)
		button.Highlight:SetAllPoints()

		if button.CompleteCheck then
			button.CompleteCheck:SetAtlas('Adventures-Checkmark')
		end
		if rareText then
			rareText:ClearAllPoints()
			rareText:SetPoint('BOTTOMLEFT', button, 20, 10)
		end
		if rareOverlay then
			rareOverlay:SetDrawLayer('BACKGROUND')
			rareOverlay:SetTexture('Interface\\ChatFrame\\ChatFrameBackground')
			rareOverlay:SetAllPoints()
			rareOverlay:SetVertexColor(.098, .537, .969, .2)
		end
		if button.Overlay and button.Overlay.Overlay then
			button.Overlay.Overlay:SetAllPoints()
		end

		button.IsSkinned = true
	end
end

local function ReskinMissionList(frame)
	for _, button in next, { frame.ScrollTarget:GetChildren() } do
		ReskinMissionButton(button)
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
		missionComplete.backdrop:Point('TOPLEFT', 3, 2)
		missionComplete.backdrop:Point('BOTTOMRIGHT', -3, -10)

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

local function SkinMissionItems(followerTab)
	for _, item in pairs({followerTab.ItemWeapon, followerTab.ItemArmor}) do
		if item then
			local icon = item.Icon
			item.Border:Hide()
			S:HandleIcon(icon)
		end
	end
end

-- TO DO: Extend this function
local function SkinMissionFrame(frame, strip)
	if strip then
		frame:StripTextures()
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
	end

	if frame.CloseButton then
		frame.CloseButton:StripTextures()
		S:HandleCloseButton(frame.CloseButton)
	end

	if frame.GarrCorners then frame.GarrCorners:Hide() end
	if frame.OverlayElements then frame.OverlayElements:SetAlpha(0) end
	if frame.TitleScroll then
		frame.TitleScroll:StripTextures()
		select(4, frame.TitleScroll:GetRegions()):SetTextColor(1, .8, 0)
	end

	for i = 1, 3 do
		local tab = _G[frame:GetName()..'Tab'..i]
		if tab then S:HandleTab(tab) end
	end

	if frame.MapTab then
		frame.MapTab.ScrollContainer.Child.TiledBackground:Hide()
	end

	local missionList = frame.MissionTab.MissionList
	missionList:StripTextures()

	S:HandleTrimScrollBar(missionList.ScrollBar)

	hooksecurefunc(missionList.ScrollBox, 'Update', ReskinMissionList)

	ReskinMissionComplete(frame)
	SkinMissionItems(frame.FollowerTab)

	hooksecurefunc(missionList.ScrollBox, 'Update', ReskinMissionList)
	hooksecurefunc(frame.FollowerTab, 'UpdateCombatantStats', UpdateSpellAbilities)
end

function S:Blizzard_GarrisonUI()
	if E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip then
		S:GarrisonShipyardTooltip() -- requires Garrison UI unlike the others
	end

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
				reward.Icon.backdrop:SetFrameLevel(reward:GetFrameLevel())
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
	FollowerList:ClearAllPoints()
	FollowerList:Point('BOTTOMLEFT', 24, 34)

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
				Reagent.Icon:Point('TOPLEFT', 1, -1)
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
	_G.GarrisonMissionFrameMissions:CreateBackdrop('Transparent')

	SkinMissionFrame(GarrisonMissionFrame, E.private.skins.parchmentRemoverEnable) -- OG Garrison

	for i = 1,2 do
		S:HandleTab(_G['GarrisonMissionFrameTab'..i])
	end

	_G.GarrisonMissionFrameTab1:ClearAllPoints()
	_G.GarrisonMissionFrameTab1:Point('BOTTOMLEFT', 11, -40)
	GarrisonMissionFrame.GarrCorners:Hide()

	-- Follower list
	FollowerList = GarrisonMissionFrame.FollowerList
	FollowerList:DisableDrawLayer('BORDER')
	FollowerList:CreateBackdrop('Transparent')
	FollowerList.MaterialFrame.BG:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleTrimScrollBar(_G.GarrisonMissionFrameFollowers.ScrollBar)
	hooksecurefunc(FollowerList, 'ShowFollower', showFollower)

	local FollowerTab = GarrisonMissionFrame.FollowerTab
	FollowerTab:StripTextures()
	FollowerTab:SetTemplate('Transparent')
	SkinMissionItems(FollowerTab)

	-- Mission list
	local MissionTab = GarrisonMissionFrame.MissionTab
	local MissionList = MissionTab.MissionList
	local MissionPage = GarrisonMissionFrame.MissionTab.MissionPage

	MissionList:DisableDrawLayer('BORDER')
	S:HandleTrimScrollBar(_G.GarrisonMissionFrameMissions.ScrollBar)
	S:HandleCloseButton(MissionPage.CloseButton)
	MissionPage.CloseButton:SetFrameLevel(MissionPage:GetFrameLevel() + 2)
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	S:HandleButton(GarrisonMissionFrame.MissionComplete.NextMissionButton)
	S:HandleButton(MissionPage.StartMissionButton)
	MissionPage.StartMissionButton.Flash:Kill()

	-- Landing page
	local GarrisonLandingPage = _G.GarrisonLandingPage
	local Report = GarrisonLandingPage.Report
	S:HandleCloseButton(GarrisonLandingPage.CloseButton, GarrisonLandingPage.backdrop)
	S:HandleTab(_G.GarrisonLandingPageTab1)
	S:HandleTab(_G.GarrisonLandingPageTab2)
	S:HandleTab(_G.GarrisonLandingPageTab3)

	-- Reposition Tabs
	hooksecurefunc('PanelTemplates_UpdateTabs', function()
		_G.GarrisonLandingPageTab1:ClearAllPoints()
		_G.GarrisonLandingPageTab2:ClearAllPoints()
		_G.GarrisonLandingPageTab3:ClearAllPoints()
		_G.GarrisonLandingPageTab1:Point('TOPLEFT', _G.GarrisonLandingPage, 'BOTTOMLEFT', -3, 0)
		_G.GarrisonLandingPageTab2:Point('TOPLEFT', _G.GarrisonLandingPageTab1, 'TOPRIGHT', -5, 0)
		_G.GarrisonLandingPageTab3:Point('TOPLEFT', _G.GarrisonLandingPageTab2, 'TOPRIGHT', -5, 0)
	end)

	if E.private.skins.parchmentRemoverEnable then
		GarrisonLandingPage:StripTextures()

		for _, tab in pairs({Report.InProgress, Report.Available}) do
			tab:SetHighlightTexture(E.ClearTexture)
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
	end

	GarrisonLandingPage:SetTemplate('Transparent') -- keep below parchmentRemover
	GarrisonLandingPage.Center:SetDrawLayer('BACKGROUND', -2)

	hooksecurefunc('GarrisonLandingPageReport_SetTab', function(s)
		local unselectedTab = Report.unselectedTab
		unselectedTab:Height(36)
		unselectedTab:SetNormalTexture(E.ClearTexture)

		s:SetNormalTexture(E.ClearTexture)

		if unselectedTab.selectedTex then
			unselectedTab.selectedTex:Hide()
		end

		if s.selectedTex then
			s.selectedTex:Show()
		end
	end)

	-- Landing page: Report
	Report = _G.GarrisonLandingPage.Report -- reassigned
	Report:StripTextures(true)

	local List = Report.List
	List:StripTextures()
	S:HandleTrimScrollBar(List.ScrollBar)

	hooksecurefunc(Report.List.ScrollBox, 'Update', function(frame)
		for _, button in next, { frame.ScrollTarget:GetChildren() } do
			if not button.IsSkinned then
				button.BG:Hide()
				button:CreateBackdrop('Transparent')
				button.backdrop:Point('TOPLEFT')
				button.backdrop:Point('BOTTOMRIGHT', 0, 1)

				for _, reward in pairs(button.Rewards) do
					reward:GetRegions():Hide()
					S:HandleIcon(reward.Icon, true)
					S:HandleIconBorder(reward.IconBorder, reward.Icon.backdrop)
				end

				button.IsSkinned = true
			end
		end
	end)

	-- Landing page: Follower list
	FollowerList = GarrisonLandingPage.FollowerList
	FollowerList.FollowerHeaderBar:Hide()
	FollowerList.FollowerScrollFrame:Hide()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleTrimScrollBar(_G.GarrisonLandingPageFollowerList.ScrollBar)

	hooksecurefunc(FollowerList, 'ShowFollower', showFollower)
	hooksecurefunc('GarrisonFollowerButton_AddAbility', function(s, index)
		local ability = s.Abilities[index]
		if not ability.IsSkinned then
			S:HandleIcon(ability.Icon, ability)
			ability.IsSkinned = true
		end
	end)

	-- Garrison Portraits
	S:HandleFollowerListOnUpdateData('GarrisonMissionFrameFollowers')
	S:HandleFollowerListOnUpdateData('GarrisonLandingPageFollowerList') -- this also applies to orderhall landing page
	hooksecurefunc(GarrisonLandingPage.FollowerTab, 'UpdateCombatantStats', UpdateSpellAbilities)

	-- Landing page: Fleet
	local ShipFollowerList = GarrisonLandingPage.ShipFollowerList
	ShipFollowerList.FollowerHeaderBar:Hide()
	S:HandleEditBox(ShipFollowerList.SearchBox)

	-- ShipYard
	local GarrisonShipyardFrame = _G.GarrisonShipyardFrame
	GarrisonShipyardFrame.BorderFrame:StripTextures(true)
	GarrisonShipyardFrame:StripTextures(true)
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
	FollowerList:StripTextures()
	FollowerList:CreateBackdrop('Transparent')
	FollowerList.MaterialFrame.BG:StripTextures()
	S:HandleTrimScrollBar(_G.GarrisonShipyardFrameFollowers.ScrollBar)
	S:HandleEditBox(FollowerList.SearchBox)

	-- MissionFrame
	local OrderHallMissionFrame = _G.OrderHallMissionFrame
	OrderHallMissionFrame.ClassHallIcon:Kill()
	OrderHallMissionFrame.GarrCorners:Hide()
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame:CreateBackdrop('Transparent')
	S:HandleCloseButton(OrderHallMissionFrame.CloseButton)

	SkinMissionFrame(OrderHallMissionFrame, E.private.skins.parchmentRemoverEnable)

	for i = 1, 3 do
		S:HandleTab(_G['OrderHallMissionFrameTab' .. i])
	end

	-- Followers
	local Follower = _G.OrderHallMissionFrameFollowers
	FollowerList = OrderHallMissionFrame.FollowerList -- swap
	FollowerTab = OrderHallMissionFrame.FollowerTab -- swap

	S:HandleTrimScrollBar(Follower.ScrollBar)

	Follower:StripTextures()
	FollowerList:StripTextures()
	FollowerList:CreateBackdrop('Transparent')
	FollowerList.MaterialFrame.BG:StripTextures()

	S:HandleEditBox(FollowerList.SearchBox)
	hooksecurefunc(FollowerList, 'ShowFollower', showFollower)

	FollowerTab.Class:Size(50, 43)
	FollowerTab.XPBar:StripTextures()
	FollowerTab.XPBar:SetStatusBarTexture(E.media.normTex)
	FollowerTab.XPBar:SetTemplate()
	FollowerTab:StripTextures()
	FollowerTab:SetTemplate('Transparent')
	SkinMissionItems(FollowerTab)

	-- Orderhall Portraits
	S:HandleFollowerListOnUpdateData('OrderHallMissionFrameFollowers')
	S:HandleFollowerListOnUpdateData('GarrisonLandingPageFollowerList') -- this also applies to garrison landing page

	-- Missions
	MissionTab = OrderHallMissionFrame.MissionTab -- swap
	local MissionComplete = OrderHallMissionFrame.MissionComplete
	MissionList = MissionTab.MissionList -- swap
	MissionPage = MissionTab.MissionPage -- swap
	local ZoneSupportMissionPage = MissionTab.ZoneSupportMissionPage
	MissionList.CompleteDialog:StripTextures()
	MissionList.CompleteDialog:SetTemplate('Transparent')
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	MissionList:StripTextures()
	S:HandleCloseButton(MissionPage.CloseButton)
	S:HandleCloseButton(ZoneSupportMissionPage.CloseButton)
	S:HandleButton(MissionComplete.NextMissionButton)
	S:HandleButton(MissionPage.StartMissionButton)
	MissionPage.StartMissionButton.Flash:Kill()
	S:HandleButton(ZoneSupportMissionPage.StartMissionButton)
	ZoneSupportMissionPage.StartMissionButton.Flash:Kill()

	local LegionMissions = _G.OrderHallMissionFrameMissions
	S:HandleButton(LegionMissions.CombatAllyUI.InProgress.Unassign)
	LegionMissions.MaterialFrame.BG:StripTextures()
	LegionMissions:CreateBackdrop('Transparent')

	-- BFA Mission
	local MissionFrame = _G.BFAMissionFrame
	MissionFrame:StripTextures()
	MissionFrame:CreateBackdrop('Transparent')
	MissionFrame.FollowerList:CreateBackdrop('Transparent')
	MissionFrame.OverlayElements:Hide()
	MissionFrame.TitleScroll:Hide()

	SkinMissionFrame(MissionFrame, E.private.skins.parchmentRemoverEnable)

	S:HandleButton(MissionFrame.MissionComplete.NextMissionButton)

	for i = 1, 3 do
		S:HandleTab(_G['BFAMissionFrameTab'..i])
	end

	-- Missions
	local BFAMissions = _G.BFAMissionFrameMissions
	S:HandleButton(BFAMissions.CompleteDialog.BorderFrame.ViewButton)
	BFAMissions.MaterialFrame.BG:StripTextures()
	BFAMissions:StripTextures()
	BFAMissions:CreateBackdrop('Transparent')

	-- Mission Tab
	MissionTab = MissionFrame.MissionTab -- swap
	S:HandleCloseButton(MissionTab.MissionPage.CloseButton)
	S:HandleButton(MissionTab.MissionPage.StartMissionButton)
	MissionTab.MissionPage.StartMissionButton.Flash:Kill()

	-- Follower Tab
	FollowerTab = MissionFrame.FollowerTab -- swap
	FollowerTab:StripTextures()
	FollowerTab:SetTemplate('Transparent')
	FollowerTab.Class:Size(50, 43)
	SkinMissionItems(FollowerTab)

	Follower = _G.BFAMissionFrameFollowers -- swap
	Follower:StripTextures()
	Follower.MaterialFrame.BG:StripTextures()
	S:HandleEditBox(Follower.SearchBox)
	hooksecurefunc(Follower, 'ShowFollower', showFollower)
	S:HandleFollowerListOnUpdateData('BFAMissionFrameFollowers') -- The function needs to be updated for BFA

	local XPBar = FollowerTab.XPBar
	XPBar:StripTextures()
	XPBar:SetStatusBarTexture(E.media.normTex)
	XPBar:CreateBackdrop()

	-- Shadowlands Mission
	local CovenantMissionFrame = _G.CovenantMissionFrame
	SkinMissionFrame(CovenantMissionFrame, E.private.skins.parchmentRemoverEnable)
	S:HandleIcon(_G.CovenantMissionFrameMissions.MaterialFrame.Icon)
	_G.CovenantMissionFrameMissions.RaisedFrameEdges:SetAlpha(0)

	if CovenantMissionFrame.RaisedBorder then
		CovenantMissionFrame.RaisedBorder:SetAlpha(0)
	end

	-- This is needed if we use StripTextures on the Covenant Frames
	hooksecurefunc(CovenantMissionFrame, 'SetupTabs', function(frame)
		frame.MapTab:SetShown(not frame.Tab2:IsShown())
	end)

	-- Complete Missions
	_G.CombatLog.ElevatedFrame:SetAlpha(0)
	_G.CombatLog.CombatLogMessageFrame:StripTextures()
	_G.CombatLog.CombatLogMessageFrame:SetTemplate('Transparent')

	-- Adventures / Follower Tab
	Follower = _G.CovenantMissionFrameFollowers -- swap
	FollowerTab = CovenantMissionFrame.FollowerTab

	hooksecurefunc(Follower, 'ShowFollower', showFollower)
	Follower:StripTextures()

	FollowerTab:StripTextures()
	FollowerTab:SetTemplate('Transparent')
	FollowerTab.RaisedFrameEdges:SetAlpha(0)
	S:HandleIcon(FollowerTab.HealFollowerFrame.CostFrame.CostIcon)

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
end

S:AddCallbackForAddon('Blizzard_GarrisonUI')
