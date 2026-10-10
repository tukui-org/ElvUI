local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, select, ipairs, next = unpack, select, ipairs, next

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local C_Garrison_GetFollowerInfo = C_Garrison.GetFollowerInfo

S:AddCallbackForAddon('Blizzard_GarrisonUI', nil, nil, nil, nil, nil, 'garrison')

S:AddCallbackForAddon('Blizzard_GarrisonTemplates', nil, nil, nil, nil, nil, function()
	return E.private.skins.blizzard.enable and E.private.skins.blizzard.orderhall and E.private.skins.blizzard.garrison
end)

-- Shared Template on LandingPage/Orderhall-/Garrison-FollowerList
local ReplacedRoleTexture = {
	['Adventures-Tank'] = 'Soulbinds_Tree_Conduit_Icon_Protect',
	['Adventures-Healer'] = 'ui_adv_health',
	['Adventures-DPS'] = 'ui_adv_atk',
	['Adventures-DPS-Ranged'] = 'Soulbinds_Tree_Conduit_Icon_Utility',
}

local function HandleFollowerRole(roleIcon, atlas)
	local newAtlas = ReplacedRoleTexture[atlas]
	if newAtlas then
		roleIcon:SetAtlas(newAtlas)
	end
end

local function HandleGarrisonPortrait(portrait, updateAtlas)
	local main = portrait.Portrait
	if not main then return end

	if not main.backdrop then
		main:CreateBackdrop('Transparent')
	end

	local level = portrait.Level or portrait.LevelText
	if level then
		level:ClearAllPoints()
		level:Point('BOTTOM', portrait, 0, 15)
		level:FontTemplate(nil, 14, 'OUTLINE')

		if portrait.LevelCircle then portrait.LevelCircle:Hide() end
		if portrait.LevelBorder then portrait.LevelBorder:SetScale(0.0001) end
	end

	if portrait.PortraitRing then
		portrait.PortraitRing:Hide()
		portrait.PortraitRingQuality:SetTexture(E.ClearTexture)
		portrait.PortraitRingCover:SetColorTexture(0, 0, 0)
		portrait.PortraitRingCover:SetAllPoints(main.backdrop)
	end

	if portrait.Empty then
		portrait.Empty:SetColorTexture(0, 0, 0)
		portrait.Empty:SetAllPoints(main)
	end

	if portrait.Highlight then portrait.Highlight:Hide() end
	if portrait.PuckBorder then portrait.PuckBorder:SetAlpha(0) end
	if portrait.TroopStackBorder1 then portrait.TroopStackBorder1:SetAlpha(0) end
	if portrait.TroopStackBorder2 then portrait.TroopStackBorder2:SetAlpha(0) end

	if portrait.HealthBar then
		portrait.HealthBar.Border:Hide()

		local roleIcon = portrait.HealthBar.RoleIcon
		roleIcon:ClearAllPoints()
		roleIcon:Point('CENTER', main.backdrop, 'TOPRIGHT')

		if updateAtlas then
			HandleFollowerRole(roleIcon, roleIcon:GetAtlas())
		else
			hooksecurefunc(roleIcon, 'SetAtlas', HandleFollowerRole)
		end

		local background = portrait.HealthBar.Background
		background:SetAlpha(0)
		background:SetInside(main.backdrop, 2, 1) -- unsnap it
		background:Point('TOPLEFT', main.backdrop, 'BOTTOMLEFT', 2, 7)
		portrait.HealthBar.Health:SetTexture(E.media.normTex)
	end
end

local function HandleFollowerAbilities(followerList)
	local followerTab = followerList and followerList.followerTab
	local abilityFrame = followerTab.AbilitiesFrame
	if not abilityFrame then return end

	local abilities = abilityFrame.Abilities
	if abilities then
		for i = 1, #abilities do
			local iconButton = abilities[i].IconButton
			local icon = iconButton and iconButton.Icon
			if icon then
				iconButton.Border:SetAlpha(0)
				S:HandleIcon(icon, true)
			end
		end
	end

	local equipment = abilityFrame.Equipment
	if equipment then
		for i = 1, #equipment do
			local equip = equipment[i]
			if equip then
				equip.Border:SetAlpha(0)
				equip.BG:SetAlpha(0)

				S:HandleIcon(equip.Icon, true)
				equip.Icon.backdrop:SetBackdropColor(1, 1, 1, .15)
			end
		end
	end

	local combatAllySpell = abilityFrame.CombatAllySpell
	if combatAllySpell then
		for i = 1, #combatAllySpell do
			local icon = combatAllySpell[i].iconTexture
			if icon then
				S:HandleIcon(icon, true)
			end
		end
	end

	local xpbar = followerTab.XPBar
	if xpbar and not xpbar.backdrop then
		xpbar:StripTextures()
		xpbar:SetStatusBarTexture(E.media.normTex)
		xpbar:CreateBackdrop('Transparent')
	end
end

local function UpdateFollowerColorOnBoard(self, _, info)
	local r, g, b = E:GetItemQualityColor(info.quality)
	self.Portrait.backdrop:SetBackdropBorderColor(r, g, b)
end

local function ResetFollowerColorOnBoard(self)
	self.Portrait.backdrop:SetBackdropBorderColor(0, 0, 0)
end

local function SkinFollowerBoard(self, group)
	for socketTexture in self[group..'SocketFramePool']:EnumerateActive() do
		socketTexture:DisableDrawLayer('BACKGROUND')
	end

	for frame in self[group..'FramePool']:EnumerateActive() do
		if not frame.IsSkinned then
			HandleGarrisonPortrait(frame)

			frame.PuckShadow:SetAlpha(0)

			-- enemy pucks have neither, mission page follower pucks have both
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

local function UpdateSpellAbilities(followerTab)
	for abilityFrame in followerTab.autoSpellPool:EnumerateActive() do
		if not abilityFrame.IsSkinned then
			S:HandleIcon(abilityFrame.Icon, true)
			abilityFrame.IconMask:Hide()
			abilityFrame.SpellBorder:Hide()

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
			rareOverlay:SetTexture([[Interface\ChatFrame\ChatFrameBackground]])
			rareOverlay:SetAllPoints()
			rareOverlay:SetVertexColor(.098, .537, .969, .2)
		end
		button.Overlay.Overlay:SetAllPoints()

		button.IsSkinned = true
	end
end

local function ReskinMissionList(frame)
	frame:ForEachFrame(ReskinMissionButton)
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
	for _, item in next, { followerTab.ItemWeapon, followerTab.ItemArmor } do
		local icon = item.Icon
		item.Border:Hide()

		S:HandleIcon(icon)
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

	frame.CloseButton:StripTextures()
	S:HandleCloseButton(frame.CloseButton)
	frame.GarrCorners:Hide()

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

	ReskinMissionComplete(frame)
	SkinMissionItems(frame.FollowerTab)

	hooksecurefunc(missionList.ScrollBox, 'Update', ReskinMissionList)
	hooksecurefunc(frame.FollowerTab, 'UpdateAutoSpellAbilities', UpdateSpellAbilities)
end

local function ReportListScrollUpdateChild(button)
	if not button.IsSkinned then
		button.BG:Hide()
		button:CreateBackdrop('Transparent')
		button.backdrop:Point('TOPLEFT')
		button.backdrop:Point('BOTTOMRIGHT', 0, 1)

		for _, reward in next, button.Rewards do
			reward:GetRegions():Hide()
			S:HandleIcon(reward.Icon, true)
			S:HandleIconBorder(reward.IconBorder, reward.Icon.backdrop)
		end

		button.IsSkinned = true
	end
end

local function ReportListScrollUpdate(frame)
	frame:ForEachFrame(ReportListScrollUpdateChild)
end

local function Covenant_SetupTabs(frame)
	frame.MapTab:SetShown(not frame.Tab2:IsShown())
end

local function GarrisonSetRewards(frame)
	local index, r, g, b = 0 -- Set border color according to rarity of item
	for _, reward in next, frame.Rewards do
		reward:GetRegions():Hide()

		reward.IconBorder:SetTexture()

		if reward.IconBorder:IsShown() then
			r, g, b = reward.IconBorder:GetVertexColor()
		else
			r, g, b = unpack(E.media.bordercolor)
		end

		if not reward.Icon.backdrop then
			S:HandleIcon(reward.Icon, true)

			reward.Icon.backdrop:OffsetFrameLevel(nil, reward)
		end

		reward.Icon.backdrop:SetBackdropBorderColor(r, g, b)

		index = index + 1
	end
end

local function GarrisonSetReward(frame)
	frame.BG:SetTexture()
	if not frame.backdrop then
		S:HandleIcon(frame.Icon)
	end

	frame.IconBorder:SetTexture()
	frame.Icon:SetDrawLayer('BORDER', 0)
end

local function SetFollowerPortrait(portraitFrame, followerInfo)
	if not portraitFrame.IsSkinned then
		HandleGarrisonPortrait(portraitFrame)

		portraitFrame.IsSkinned = true
	end

	local r, g, b = E:GetItemQualityColor(followerInfo.quality)
	portraitFrame.Portrait.backdrop:SetBackdropBorderColor(r, g, b)
	portraitFrame.Portrait.backdrop:Show()
end

local function CapacitiveDisplayUpdate(frame)
	for _, Reagent in ipairs(frame.CapacitiveDisplay.Reagents) do
		if not Reagent.template then
			Reagent:SetTemplate()
			Reagent.NameFrame:SetTexture()
			Reagent.Icon:SetDrawLayer('ARTWORK')
			Reagent.Icon:ClearAllPoints()
			Reagent.Icon:Point('TOPLEFT', 1, -1)
			S:HandleIcon(Reagent.Icon)
		end
	end
end

local function PanelUpdateTabs()
	_G.GarrisonLandingPageTab1:ClearAllPoints()
	_G.GarrisonLandingPageTab1:Point('TOPLEFT', _G.GarrisonLandingPage, 'BOTTOMLEFT', -3, 0)

	_G.GarrisonLandingPageTab2:ClearAllPoints()
	_G.GarrisonLandingPageTab2:Point('TOPLEFT', _G.GarrisonLandingPageTab1, 'TOPRIGHT', -5, 0)

	_G.GarrisonLandingPageTab3:ClearAllPoints()
	_G.GarrisonLandingPageTab3:Point('TOPLEFT', _G.GarrisonLandingPageTab2, 'TOPRIGHT', -5, 0)
end

local function GarrisonSetTab(frame)
	local Report = _G.GarrisonLandingPage.Report

	local unselectedTab = Report.unselectedTab
	unselectedTab:Height(36)
	unselectedTab:SetNormalTexture(E.ClearTexture)

	frame:SetNormalTexture(E.ClearTexture)

	if unselectedTab.selectedTex then
		unselectedTab.selectedTex:Hide()
	end

	if frame.selectedTex then
		frame.selectedTex:Show()
	end
end

local function GarrisonAddAbility(frame, index)
	local ability = frame.Abilities[index]
	if not ability.IsSkinned then
		S:HandleIcon(ability.Icon, ability)
		ability.IsSkinned = true
	end
end

local function UpdatePortraitQuality(frame, followerInfo)
	local r, g, b = E:GetItemQualityColor(followerInfo.quality)
	frame.Portrait.backdrop:SetBackdropBorderColor(r, g, b)
end

local function UpdateFollowerButtons(button)
	if not E.Modern then
		button:SetTemplate(button.mode == 'CATEGORY' and 'NoBackdrop' or 'Transparent')
	end

	local category = button.Category
	if category then
		category:ClearAllPoints()
		category:Point('TOP', button, 'TOP', 0, -4)
	end

	local follower = button.Follower
	if follower then
		if not follower.template then
			follower:SetTemplate('Transparent')
			follower.Name:SetWordWrap(false)
			follower.Selection:SetTexture()
			follower.AbilitiesBG:SetTexture()
			follower.BusyFrame:SetAllPoints()
			follower.BG:Hide()

			local hl = follower:GetHighlightTexture()
			hl:SetColorTexture(0.9, 0.9, 0.9, 0.25)
			hl:SetInside()
		end

		local counters = follower.Counters
		if counters then
			for _, counter in next, counters do
				if not counter.template then
					counter:SetTemplate()

					if counter.Border then
						counter.Border:SetTexture()
					end

					if counter.Icon then
						counter.Icon:SetTexCoords()
						counter.Icon:SetInside()
					end
				end
			end
		end

		local portrait = follower.PortraitFrame
		if portrait then
			HandleGarrisonPortrait(portrait, true)

			portrait:ClearAllPoints()
			portrait:Point('TOPLEFT', 3, -3)

			if not follower.PortraitFrameStyled then
				hooksecurefunc(portrait, 'SetupPortrait', UpdatePortraitQuality)
				follower.PortraitFrameStyled = true
			end

			if portrait.backdrop then
				local r, g, b = E:GetItemQualityColor(portrait.quality or (follower.info and follower.info.quality))
				portrait.backdrop:SetBackdropBorderColor(r, g, b)
			end
		end

		if follower.Selection then
			if follower.Selection:IsShown() then
				follower:SetBackdropColor(0.9, 0.8, 0.1, 0.25)
			else
				follower:SetBackdropColor(0, 0, 0, 0.5)
			end
		end
	end
end

function S:Blizzard_GarrisonUI()
	-- These hooks affect both Garrison and OrderHall
	hooksecurefunc('GarrisonMissionButton_SetRewards', GarrisonSetRewards)
	hooksecurefunc('GarrisonMissionPage_SetReward', GarrisonSetReward)
	hooksecurefunc('GarrisonMissionPortrait_SetFollowerPortrait', SetFollowerPortrait)
	hooksecurefunc(_G, 'GarrisonFollowerList_InitButton', UpdateFollowerButtons)

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
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetTexCoords()
	CapacitiveDisplay.ShipmentIconFrame.Icon:SetInside()
	--Fix unitframes appearing above work orders
	GarrisonCapacitiveDisplayFrame:SetFrameStrata('MEDIUM')
	GarrisonCapacitiveDisplayFrame:SetFrameLevel(45)

	hooksecurefunc('GarrisonCapacitiveDisplayFrame_Update', CapacitiveDisplayUpdate)

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
	hooksecurefunc(FollowerList, 'ShowFollower', HandleFollowerAbilities)

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
	MissionPage.CloseButton:OffsetFrameLevel(2, MissionPage)
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	S:HandleButton(GarrisonMissionFrame.MissionComplete.NextMissionButton)
	S:HandleButton(MissionPage.StartMissionButton)
	MissionPage.StartMissionButton.Flash:Kill()

	-- Landing page
	local GarrisonLandingPage = _G.GarrisonLandingPage
	local Report = GarrisonLandingPage.Report
	S:HandleCloseButton(GarrisonLandingPage.CloseButton, GarrisonLandingPage.backdrop)

	local pageTabs = {
		_G.GarrisonLandingPageTab1,
		_G.GarrisonLandingPageTab2,
		_G.GarrisonLandingPageTab3,
	}
	for _, tab in next, pageTabs do
		S:HandleTab(tab)
		tab:SetHeight(tab:GetHeight() * .75)
	end

	-- Reposition Tabs
	hooksecurefunc('PanelTemplates_UpdateTabs', PanelUpdateTabs)

	if E.private.skins.parchmentRemoverEnable then
		GarrisonLandingPage:StripTextures()

		for _, tab in next, { Report.InProgress, Report.Available } do
			tab:SetHighlightTexture(E.ClearTexture)
			tab.Text:ClearAllPoints()
			tab.Text:Point('CENTER')

			local bg = CreateFrame('Frame', nil, tab)
			bg:OffsetFrameLevel(-1, tab)
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

	hooksecurefunc('GarrisonLandingPageReport_SetTab', GarrisonSetTab)

	-- Landing page: Report
	Report = _G.GarrisonLandingPage.Report -- reassigned
	Report:StripTextures(true)

	local List = Report.List
	List:StripTextures()
	S:HandleTrimScrollBar(List.ScrollBar)

	hooksecurefunc(Report.List.ScrollBox, 'Update', ReportListScrollUpdate)

	-- Landing page: Follower list
	FollowerList = GarrisonLandingPage.FollowerList
	FollowerList.FollowerHeaderBar:Hide()
	FollowerList.FollowerScrollFrame:Hide()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleTrimScrollBar(_G.GarrisonLandingPageFollowerList.ScrollBar)

	hooksecurefunc(FollowerList, 'ShowFollower', HandleFollowerAbilities)
	hooksecurefunc('GarrisonFollowerButton_AddAbility', GarrisonAddAbility)

	-- Garrison Portraits
	hooksecurefunc(GarrisonLandingPage.FollowerTab, 'UpdateAutoSpellAbilities', UpdateSpellAbilities)

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
	MissionPage.CloseButton:OffsetFrameLevel(2)
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
	hooksecurefunc(FollowerList, 'ShowFollower', HandleFollowerAbilities)

	FollowerTab.Class:Size(50, 43)
	FollowerTab.XPBar:StripTextures()
	FollowerTab.XPBar:SetStatusBarTexture(E.media.normTex)
	FollowerTab.XPBar:SetTemplate()
	FollowerTab:StripTextures()
	FollowerTab:SetTemplate('Transparent')
	SkinMissionItems(FollowerTab)

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
	hooksecurefunc(Follower, 'ShowFollower', HandleFollowerAbilities)

	local XPBar = FollowerTab.XPBar
	XPBar:StripTextures()
	XPBar:SetStatusBarTexture(E.media.normTex)
	XPBar:CreateBackdrop()

	-- Shadowlands Mission
	local CovenantMissionFrame = _G.CovenantMissionFrame
	SkinMissionFrame(CovenantMissionFrame, E.private.skins.parchmentRemoverEnable)
	S:HandleIcon(_G.CovenantMissionFrameMissions.MaterialFrame.Icon)
	_G.CovenantMissionFrameMissions.RaisedFrameEdges:SetAlpha(0)
	CovenantMissionFrame.RaisedBorder:SetAlpha(0)

	-- This is needed if we use StripTextures on the Covenant Frames
	hooksecurefunc(CovenantMissionFrame, 'SetupTabs', Covenant_SetupTabs)

	-- Complete Missions
	_G.CombatLog.ElevatedFrame:SetAlpha(0)
	_G.CombatLog.CombatLogMessageFrame:StripTextures()
	_G.CombatLog.CombatLogMessageFrame:SetTemplate('Transparent')

	-- Adventures / Follower Tab
	Follower = _G.CovenantMissionFrameFollowers -- swap
	FollowerTab = CovenantMissionFrame.FollowerTab

	hooksecurefunc(Follower, 'ShowFollower', HandleFollowerAbilities)
	Follower:StripTextures()
	S:HandleButton(Follower.HealAllButton)

	FollowerTab:StripTextures()
	FollowerTab:SetTemplate('Transparent')
	FollowerTab.RaisedFrameEdges:SetAlpha(0)

	local HealFollowerFrame = FollowerTab.HealFollowerFrame
	S:HandleIcon(HealFollowerFrame.CostFrame.CostIcon)
	S:HandleButton(HealFollowerFrame.HealFollowerButton)

	-- Mission Tab
	S:HandleCloseButton(CovenantMissionFrame.MissionTab.MissionPage.CloseButton)
	S:HandleIcon(CovenantMissionFrame.MissionTab.MissionPage.CostFrame.CostIcon)
	S:HandleButton(CovenantMissionFrame.MissionTab.MissionPage.StartMissionButton)
	CovenantMissionFrame.MissionTab.MissionPage.StartMissionButton.Flash:Kill()

	CovenantMissionFrame.MissionTab.MissionPage.Board:HookScript('OnShow', SkinMissionBoards)
	CovenantMissionFrame.MissionComplete.Board:HookScript('OnShow', SkinMissionBoards)
end

local function ShowGarrisonFollower(frame, followerID)
	local followerInfo = followerID and C_Garrison_GetFollowerInfo(followerID)
	if not followerInfo then return end

	if not frame.PortraitFrameStyled then
		HandleGarrisonPortrait(frame.PortraitFrame)

		frame.PortraitFrameStyled = true
	end

	local r, g, b = E:GetItemQualityColor(followerInfo.quality or 1)

	frame.Name:SetVertexColor(r, g, b)
	frame.PortraitFrame.Portrait.backdrop:SetBackdropBorderColor(r, g, b)

	frame.XPBar:ClearAllPoints()
	frame.XPBar:Point('BOTTOMLEFT', frame.PortraitFrame, 'BOTTOMRIGHT', 7, -15)
end

function S:Blizzard_GarrisonTemplates()
	hooksecurefunc(_G.GarrisonFollowerTabMixin, 'ShowFollower', ShowGarrisonFollower)
end
