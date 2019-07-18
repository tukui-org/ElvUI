local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local LBG = E.Libs.ButtonGlow

--Lua functions
local _G = _G
local unpack, ipairs, pairs, select = unpack, ipairs, pairs, select
local min, strlower = min, strlower
--WoW API / Variables
local GetBackgroundTexCoordsForRole = GetBackgroundTexCoordsForRole
local GetLFGProposal = GetLFGProposal
local GetLFGProposalMember = GetLFGProposalMember
local hooksecurefunc = hooksecurefunc
local C_ChallengeMode_GetAffixInfo = C_ChallengeMode.GetAffixInfo
local C_LFGList_GetApplicationInfo = C_LFGList.GetApplicationInfo
local C_LFGList_GetAvailableActivities = C_LFGList.GetAvailableActivities
local C_LFGList_GetAvailableRoles = C_LFGList.GetAvailableRoles
local C_MythicPlus_GetCurrentAffixes = C_MythicPlus.GetCurrentAffixes

local function LFDQueueFrameRoleButtonIconOnShow(self)
	LBG.ShowOverlayGlow(self:GetParent().checkButton)
end
local function LFDQueueFrameRoleButtonIconOnHide(self)
	LBG.HideOverlayGlow(self:GetParent().checkButton)
end

local function HandleGoldIcon(button)
	local Button = _G[button]
	if Button.backdrop then return end

	local count = _G[button.."Count"]
	local nameFrame = _G[button.."NameFrame"]
	local iconTexture = _G[button.."IconTexture"]

	Button:CreateBackdrop()
	Button.backdrop:ClearAllPoints()
	Button.backdrop:Point("LEFT", 1, 0)
	Button.backdrop:Size(42)

	iconTexture:SetTexCoord(unpack(E.TexCoords))
	iconTexture:SetDrawLayer("OVERLAY")
	iconTexture:SetParent(Button.backdrop)
	iconTexture:SetInside()

	count:SetParent(Button.backdrop)
	count:SetDrawLayer("OVERLAY")

	nameFrame:SetTexture()
	nameFrame:Size(118, 39)
end

local function SkinItemButton(parentFrame, _, index)
	local parentName = parentFrame:GetName()
	local item = _G[parentName.."Item"..index]

	if item and not item.backdrop then
		item:CreateBackdrop()
		item.backdrop:ClearAllPoints()
		item.backdrop:Point("LEFT", 1, 0)
		item.backdrop:Size(42)

		item.Icon:SetTexCoord(unpack(E.TexCoords))
		item.Icon:SetDrawLayer("OVERLAY")
		item.Icon:SetParent(item.backdrop)
		item.Icon:SetInside()

		hooksecurefunc(item.IconBorder, "SetVertexColor", function(self, r, g, b)
			self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
			self:SetTexture()
		end)
		hooksecurefunc(item.IconBorder, "Hide", function(self)
			self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		local r, g, b, a = item.IconBorder:GetVertexColor()
		if r then
			item.IconBorder:SetTexture()
			item.backdrop:SetBackdropBorderColor(r, g, b, a)
		end

		item.Count:SetDrawLayer("OVERLAY")
		item.Count:SetParent(item.backdrop)

		item.NameFrame:SetTexture()
		item.NameFrame:Size(118, 39)

		item.shortageBorder:SetTexture()

		item.roleIcon1:SetParent(item.backdrop)
		item.roleIcon2:SetParent(item.backdrop)
	end
end

local function SetRoleIcon(self, resultID)
	local _,_,_,_, role = C_LFGList_GetApplicationInfo(resultID)
	self.RoleIcon:SetTexCoord(GetBackgroundTexCoordsForRole(role))
end

local function HandleAffixIcons(self)
	for _, frame in ipairs(self.Affixes) do
		frame.Border:SetTexture()
		frame.Portrait:SetTexture()

		if frame.info then
			frame.Portrait:SetTexture(_G.CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
		elseif frame.affixID then
			local _, _, filedataid = C_ChallengeMode_GetAffixInfo(frame.affixID)
			frame.Portrait:SetTexture(filedataid)
		end
		frame.Portrait:SetTexCoord(unpack(E.TexCoords))
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true then return end


	local PVEFrame = _G.PVEFrame
	S:HandlePortraitFrame(PVEFrame, true)

	_G.RaidFinderQueueFrame:StripTextures(true)
	_G.PVEFrameBg:Hide()
	PVEFrame.shadows:Kill() -- We need to kill it, because if you switch to Mythic Dungeon Tab and back, it shows back up.

	S:HandleButton(_G.LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(_G.LFDQueueFramePartyBackfillNoBackfillButton)
	S:HandleButton(_G.LFDQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)
	S:HandleButton(_G.ScenarioQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)
	S:HandleScrollBar(_G.ScenarioQueueFrameRandomScrollFrameScrollBar);

	_G.GroupFinderFrame.groupButton1.icon:SetTexture("Interface\\Icons\\INV_Helmet_08")
	_G.GroupFinderFrame.groupButton2.icon:SetTexture("Interface\\LFGFrame\\UI-LFR-PORTRAIT")
	_G.GroupFinderFrame.groupButton3.icon:SetTexture("Interface\\Icons\\Icon_Scenarios")
	_G.GroupFinderFrame.groupButton4.icon:SetTexture("Interface\\Icons\\Achievement_General_StayClassy")

	_G.LFGDungeonReadyDialogBackground:Kill()
	S:HandleButton(_G.LFGDungeonReadyDialogEnterDungeonButton)
	S:HandleButton(_G.LFGDungeonReadyDialogLeaveQueueButton)
	S:HandleCloseButton(_G.LFGDungeonReadyDialogCloseButton)
	_G.LFGDungeonReadyDialog:StripTextures()
	_G.LFGDungeonReadyDialog:SetTemplate("Transparent")
	_G.LFGDungeonReadyStatus:StripTextures()
	_G.LFGDungeonReadyStatus:SetTemplate("Transparent")
	_G.LFGDungeonReadyDialogRoleIconTexture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	_G.LFGDungeonReadyDialogRoleIconTexture:SetAlpha(0.5)

	hooksecurefunc(_G.LFGDungeonReadyDialog, "SetBackdrop", function(frame, backdrop)
		if backdrop ~= nil then frame:SetBackdrop(nil) end
	end)

	hooksecurefunc("LFGDungeonReadyPopup_Update", function()
		local _, _, _, _, _, _, role = GetLFGProposal()
		if _G.LFGDungeonReadyDialogRoleIcon:IsShown() then
			if role == "DAMAGER" then
				_G.LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(_G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
			elseif role == "TANK" then
				_G.LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(_G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
			elseif role == "HEALER" then
				_G.LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(_G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
			end
		end
	end)

	hooksecurefunc("LFGDungeonReadyStatusIndividual_UpdateIcon", function(button)
		local _, role = GetLFGProposalMember(button:GetID())

		button.texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
		button.texture:SetAlpha(0.6)

		if role == "DAMAGER" then
			button.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
		elseif role == "TANK" then
			button.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
		elseif role == "HEALER" then
			button.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
		end
	end)

	_G.LFDQueueFrame:StripTextures(true)
	_G.LFDQueueFrameRoleButtonTankIncentiveIcon:SetAlpha(0)
	_G.LFDQueueFrameRoleButtonHealerIncentiveIcon:SetAlpha(0)
	_G.LFDQueueFrameRoleButtonDPSIncentiveIcon:SetAlpha(0)

	_G.LFDQueueFrameRoleButtonTankIncentiveIcon:HookScript("OnShow", LFDQueueFrameRoleButtonIconOnShow)
	_G.LFDQueueFrameRoleButtonHealerIncentiveIcon:HookScript("OnShow", LFDQueueFrameRoleButtonIconOnShow)
	_G.LFDQueueFrameRoleButtonDPSIncentiveIcon:HookScript("OnShow", LFDQueueFrameRoleButtonIconOnShow)
	_G.LFDQueueFrameRoleButtonTankIncentiveIcon:HookScript("OnHide", LFDQueueFrameRoleButtonIconOnHide)
	_G.LFDQueueFrameRoleButtonHealerIncentiveIcon:HookScript("OnHide", LFDQueueFrameRoleButtonIconOnHide)
	_G.LFDQueueFrameRoleButtonDPSIncentiveIcon:HookScript("OnHide", LFDQueueFrameRoleButtonIconOnHide)
	_G.LFDQueueFrameRoleButtonTank.shortageBorder:Kill()
	_G.LFDQueueFrameRoleButtonDPS.shortageBorder:Kill()
	_G.LFDQueueFrameRoleButtonHealer.shortageBorder:Kill()
	_G.LFGDungeonReadyDialog.filigree:SetAlpha(0)
	_G.LFGDungeonReadyDialog.bottomArt:SetAlpha(0)
	S:HandleCloseButton(_G.LFGDungeonReadyStatusCloseButton)

	local RoleButtons1 = {
		_G.LFDQueueFrameRoleButtonHealer,
		_G.LFDQueueFrameRoleButtonDPS,
		_G.LFDQueueFrameRoleButtonLeader,
		_G.LFDQueueFrameRoleButtonTank,
		_G.RaidFinderQueueFrameRoleButtonHealer,
		_G.RaidFinderQueueFrameRoleButtonDPS,
		_G.RaidFinderQueueFrameRoleButtonLeader,
		_G.RaidFinderQueueFrameRoleButtonTank,
		_G.LFGInvitePopupRoleButtonTank,
		_G.LFGInvitePopupRoleButtonHealer,
		_G.LFGInvitePopupRoleButtonDPS,
		_G.LFGListApplicationDialog.TankButton,
		_G.LFGListApplicationDialog.HealerButton,
		_G.LFGListApplicationDialog.DamagerButton,
	}

	for _, roleButton in pairs(RoleButtons1) do
		S:HandleCheckBox(roleButton.checkButton or roleButton.CheckButton, true)
		roleButton:DisableDrawLayer("ARTWORK")
		roleButton:DisableDrawLayer("OVERLAY")

		if(not roleButton.background) then
			local isLeader = roleButton:GetName() ~= nil and roleButton:GetName():find("Leader") or false
			if(not isLeader) then
				roleButton.background = roleButton:CreateTexture(nil, "BACKGROUND")
				roleButton.background:Size(80, 80)
				roleButton.background:Point("CENTER")
				roleButton.background:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
				roleButton.background:SetAlpha(0.65)

				local buttonName = roleButton:GetName() ~= nil and roleButton:GetName() or roleButton.role
				roleButton.background:SetTexCoord(GetBackgroundTexCoordsForRole((strlower(buttonName):find("tank") and "TANK") or (strlower(buttonName):find("healer") and "HEALER") or "DAMAGER"))
			end
		end
	end

	--Fix issue with role buttons overlapping each other (Blizzard bug)
	local repositionCheckButtons = {
		_G.LFGListApplicationDialog.TankButton.CheckButton,
		_G.LFGListApplicationDialog.HealerButton.CheckButton,
		_G.LFGListApplicationDialog.DamagerButton.CheckButton,
	}
	for _, checkButton in pairs(repositionCheckButtons) do
		checkButton:ClearAllPoints()
		checkButton:Point("BOTTOMLEFT", 0, 0)
	end
	hooksecurefunc("LFGListApplicationDialog_UpdateRoles", function(self) --Copy from Blizzard, we just fix position
		local availTank, availHealer, availDPS = C_LFGList_GetAvailableRoles()

		local avail1, avail2
		if ( availTank ) then
			avail1 = self.TankButton
		end
		if ( availHealer ) then
			if ( avail1 ) then
				avail2 = self.HealerButton
			else
				avail1 = self.HealerButton
			end
		end
		if ( availDPS ) then
			if ( avail1 ) then
				avail2 = self.DamagerButton
			else
				avail1 = self.DamagerButton
			end
		end

		if ( avail2 ) then
			avail1:ClearAllPoints();
			avail1:Point("TOPRIGHT", self, "TOP", -40, -35)
			avail2:ClearAllPoints()
			avail2:Point("TOPLEFT", self, "TOP", 40, -35)
		elseif ( avail1 ) then
			avail1:ClearAllPoints()
			avail1:Point("TOP", self, "TOP", 0, -35)
		end
	end)

	_G.LFDQueueFrameRoleButtonLeader.leadIcon = _G.LFDQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
	_G.LFDQueueFrameRoleButtonLeader.leadIcon:SetTexture(E.Media.Textures.Leader)
	_G.LFDQueueFrameRoleButtonLeader.leadIcon:Point(_G.LFDQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint(), -10, 5)
	_G.LFDQueueFrameRoleButtonLeader.leadIcon:Size(50)
	_G.LFDQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.6)

	_G.RaidFinderQueueFrameRoleButtonLeader.leadIcon = _G.RaidFinderQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
	_G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetTexture(E.Media.Textures.Leader)
	_G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:Point(_G.RaidFinderQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint(), -10, 5)
	_G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:Size(50)
	_G.RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.6)

	hooksecurefunc('LFG_DisableRoleButton', function(button)
		if button.checkButton:GetChecked() then
			button.checkButton:SetAlpha(1)
		else
			button.checkButton:SetAlpha(0)
		end

		if button.background then
			button.background:Show()
		end
	end)

	hooksecurefunc('LFG_EnableRoleButton', function(button)
		button.checkButton:SetAlpha(1)
	end)

	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(self)
		if self.background then
			self.background:Show()
			self.background:SetDesaturated(true)
		end
	end)

	for i = 1, 4 do
		local bu = _G.GroupFinderFrame["groupButton"..i]
		bu.ring:Kill()
		bu.bg:Kill()
		S:HandleButton(bu)

		bu.icon:Size(45)
		bu.icon:ClearAllPoints()
		bu.icon:Point("LEFT", 10, 0)
		S:HandleIcon(bu.icon, true)
	end

	for i = 1, 3 do
		S:HandleTab(_G['PVEFrameTab'..i])
	end
	_G.PVEFrameTab1:Point('BOTTOMLEFT', PVEFrame, 'BOTTOMLEFT', 19, E.PixelMode and -31 or -32)

	-- Raid finder
	S:HandleButton(_G.LFDQueueFrameFindGroupButton, true)

	_G.LFDParentFrame:StripTextures()
	_G.LFDParentFrameInset:StripTextures()

	HandleGoldIcon("LFDQueueFrameRandomScrollFrameChildFrameMoneyReward")
	HandleGoldIcon("RaidFinderQueueFrameScrollFrameChildFrameMoneyReward")
	HandleGoldIcon("ScenarioQueueFrameRandomScrollFrameChildFrameMoneyReward")

	for i = 1, _G.NUM_LFD_CHOICE_BUTTONS do
		S:HandleCheckBox(_G["LFDQueueFrameSpecificListButton"..i].enableButton, nil, true)
	end

	hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
		if button and button.expandOrCollapseButton:IsShown() then
			if button.isCollapsed then
				button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.PlusButton);
			else
				button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.MinusButton);
			end
		end
	end)

	hooksecurefunc("ScenarioQueueFrameSpecific_Update", function()
		for i = 1, _G.NUM_SCENARIO_CHOICE_BUTTONS do
			local button = _G["ScenarioQueueFrameSpecificButton"..i]

			if button and not button.skinned then
				S:HandleCheckBox(button.enableButton, nil, true)
				button.skinned = true;
			end
		end
	end)

	for i = 1, _G.NUM_LFR_CHOICE_BUTTONS do
		local bu = _G["LFRQueueFrameSpecificListButton"..i].enableButton
		S:HandleCheckBox(bu, nil, true)
	end

	S:HandleDropDownBox(_G.LFDQueueFrameTypeDropDown)
	_G.ScenarioQueueFrame:StripTextures()
	_G.ScenarioFinderFrameInset:StripTextures()
	S:HandleButton(_G.ScenarioQueueFrameFindGroupButton)

	-- Raid Finder
	_G.RaidFinderFrame:StripTextures()
	_G.RaidFinderFrameRoleInset:StripTextures()
	S:HandleDropDownBox(_G.RaidFinderQueueFrameSelectionDropDown)
	_G.RaidFinderFrameFindRaidButton:StripTextures()
	S:HandleButton(_G.RaidFinderFrameFindRaidButton)
	_G.RaidFinderQueueFrame:StripTextures()
	_G.RaidFinderQueueFrameScrollFrameScrollBar:StripTextures()
	S:HandleScrollBar(_G.RaidFinderQueueFrameScrollFrameScrollBar)

	-- Scenario finder
	_G.ScenarioFinderFrameInset:DisableDrawLayer("BORDER")
	_G.ScenarioQueueFrame.Bg:Hide()
	_G.ScenarioFinderFrameInset:GetRegions():Hide()

	--Skin Reward Items (This works for all frames, LFD, Raid, Scenario)
	hooksecurefunc("LFGRewardsFrame_SetItemButton", SkinItemButton)

	_G.ScenarioQueueFrameFindGroupButton:StripTextures()
	S:HandleButton(_G.ScenarioQueueFrameFindGroupButton)
	S:HandleDropDownBox(_G.ScenarioQueueFrameTypeDropDown)

	-- Looking for raid
	_G.LFRBrowseFrameListScrollFrame:StripTextures()

	_G.LFRBrowseFrame:HookScript('OnShow', function()
		if not _G.LFRBrowseFrameListScrollFrameScrollBar.skinned then
			S:HandleScrollBar(_G.LFRBrowseFrameListScrollFrameScrollBar)
			_G.LFRBrowseFrameListScrollFrameScrollBar.skinned = true
		end
	end)

	_G.LFRBrowseFrameRoleInset:DisableDrawLayer("BORDER")
	_G.RaidBrowserFrameBg:Hide()
	_G.LFRQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
	_G.LFRQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
	_G.LFRQueueFrameCommentScrollFrame:CreateBackdrop()
	_G.LFRBrowseFrameColumnHeader1:Width(94) --Fix the columns being slightly off
	_G.LFRBrowseFrameColumnHeader2:Width(38)

	_G.RaidBrowserFrame:CreateBackdrop('Transparent')
	S:HandleCloseButton(_G.RaidBrowserFrameCloseButton)
	S:HandleButton(_G.LFRQueueFrameFindGroupButton)
	S:HandleButton(_G.LFRQueueFrameAcceptCommentButton)

	local RoleButtons2 = {
		_G.LFRQueueFrameRoleButtonHealer,
		_G.LFRQueueFrameRoleButtonDPS,
		_G.LFRQueueFrameRoleButtonTank,
	}

	S:HandleScrollBar(_G.LFRQueueFrameCommentScrollFrameScrollBar)
	S:HandleScrollBar(_G.LFDQueueFrameSpecificListScrollFrameScrollBar)
	_G.LFDQueueFrameSpecificListScrollFrame:StripTextures()
	_G.RaidBrowserFrame:HookScript('OnShow', function()
		if not _G.LFRQueueFrameSpecificListScrollFrameScrollBar.skinned then
			S:HandleScrollBar(_G.LFRQueueFrameSpecificListScrollFrameScrollBar)
			_G.LFRBrowseFrame:StripTextures()
			for _, roleButton in pairs(RoleButtons2) do
				roleButton:SetNormalTexture("")
				S:HandleCheckBox(roleButton.checkButton, nil, true)
				roleButton:GetChildren():SetFrameLevel(roleButton:GetChildren():GetFrameLevel() + 1)
			end

			for i=1, 2 do
				local tab = _G['LFRParentFrameSideTab'..i]
				tab:DisableDrawLayer('BACKGROUND')

				tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
				tab:GetNormalTexture():SetInside()

				tab.pushed = true;
				tab:CreateBackdrop()
				tab.backdrop:SetAllPoints()
				tab:StyleButton(true)
				hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
					if texPath ~= nil then
						self:SetTexture();
					end
				end)

				hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
					if texPath ~= nil then
						self:SetTexture();
					end
				end)
			end

			for i=1, 7 do
				local tab = _G['LFRBrowseFrameColumnHeader'..i]
				tab:DisableDrawLayer('BACKGROUND')
			end

			S:HandleDropDownBox(_G.LFRBrowseFrameRaidDropDown)
			S:HandleButton(_G.LFRBrowseFrameRefreshButton)
			S:HandleButton(_G.LFRBrowseFrameInviteButton)
			S:HandleButton(_G.LFRBrowseFrameSendMessageButton)
			_G.LFRQueueFrameSpecificListScrollFrameScrollBar.skinned = true
		end
	end)

	--[[LFGInvitePopup_Update("Elvz", true, true, true)
	StaticPopupSpecial_Show(LFGInvitePopup);]]
	_G.LFGInvitePopup:StripTextures()
	_G.LFGInvitePopup:SetTemplate("Transparent")
	S:HandleButton(_G.LFGInvitePopupAcceptButton)
	S:HandleButton(_G.LFGInvitePopupDeclineButton)

	S:HandleButton(_G[_G.LFDQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[_G.LFDQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])
	S:HandleButton(_G[_G.RaidFinderQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[_G.RaidFinderQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])
	S:HandleButton(_G[_G.ScenarioQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[_G.ScenarioQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])
	_G.LFDQueueFrameRandomScrollFrameScrollBar:StripTextures()
	_G.ScenarioQueueFrameSpecificScrollFrame:StripTextures()
	S:HandleScrollBar(_G.LFDQueueFrameRandomScrollFrameScrollBar)
	S:HandleScrollBar(_G.ScenarioQueueFrameSpecificScrollFrameScrollBar)

	--LFGListFrame
	local LFGListFrame = _G.LFGListFrame
	LFGListFrame.CategorySelection.Inset:StripTextures()
	S:HandleButton(LFGListFrame.CategorySelection.StartGroupButton, true)
	S:HandleButton(LFGListFrame.CategorySelection.FindGroupButton, true)
	LFGListFrame.CategorySelection.StartGroupButton:ClearAllPoints()
	LFGListFrame.CategorySelection.StartGroupButton:Point("BOTTOMLEFT", -1, 3)
	LFGListFrame.CategorySelection.FindGroupButton:ClearAllPoints()
	LFGListFrame.CategorySelection.FindGroupButton:Point("BOTTOMRIGHT", -6, 3)

	LFGListFrame.EntryCreation.Inset:StripTextures()
	S:HandleButton(LFGListFrame.EntryCreation.CancelButton, true)
	S:HandleButton(LFGListFrame.EntryCreation.ListGroupButton, true)
	LFGListFrame.EntryCreation.CancelButton:ClearAllPoints()
	LFGListFrame.EntryCreation.CancelButton:Point("BOTTOMLEFT", -1, 3)
	LFGListFrame.EntryCreation.ListGroupButton:ClearAllPoints()
	LFGListFrame.EntryCreation.ListGroupButton:Point("BOTTOMRIGHT", -6, 3)
	S:HandleEditBox(LFGListFrame.EntryCreation.Description)

	S:HandleEditBox(LFGListFrame.EntryCreation.Name)
	S:HandleEditBox(LFGListFrame.EntryCreation.ItemLevel.EditBox)
	S:HandleEditBox(LFGListFrame.EntryCreation.HonorLevel.EditBox)
	S:HandleEditBox(LFGListFrame.EntryCreation.VoiceChat.EditBox)

	S:HandleDropDownBox(_G.LFGListEntryCreationActivityDropDown)
	S:HandleDropDownBox(_G.LFGListEntryCreationGroupDropDown)
	S:HandleDropDownBox(_G.LFGListEntryCreationCategoryDropDown, 330)

	S:HandleCheckBox(LFGListFrame.EntryCreation.ItemLevel.CheckButton)
	S:HandleCheckBox(LFGListFrame.EntryCreation.HonorLevel.CheckButton)
	S:HandleCheckBox(LFGListFrame.EntryCreation.VoiceChat.CheckButton)
	S:HandleCheckBox(LFGListFrame.EntryCreation.PrivateGroup.CheckButton)

	LFGListFrame.EntryCreation.ActivityFinder.Dialog:StripTextures()
	LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetTemplate("Transparent")
	LFGListFrame.EntryCreation.ActivityFinder.Dialog.BorderFrame:StripTextures()
	LFGListFrame.EntryCreation.ActivityFinder.Dialog.BorderFrame:SetTemplate("Transparent")

	S:HandleEditBox(LFGListFrame.EntryCreation.ActivityFinder.Dialog.EntryBox)
	S:HandleScrollBar(_G.LFGListEntryCreationSearchScrollFrameScrollBar)
	S:HandleButton(LFGListFrame.EntryCreation.ActivityFinder.Dialog.SelectButton)
	S:HandleButton(LFGListFrame.EntryCreation.ActivityFinder.Dialog.CancelButton)

	_G.LFGListApplicationDialog:StripTextures()
	_G.LFGListApplicationDialog:SetTemplate("Transparent")
	S:HandleButton(_G.LFGListApplicationDialog.SignUpButton)
	S:HandleButton(_G.LFGListApplicationDialog.CancelButton)
	S:HandleEditBox(_G.LFGListApplicationDialogDescription)

	_G.LFGListInviteDialog:StripTextures()
	_G.LFGListInviteDialog:SetTemplate("Transparent")
	S:HandleButton(_G.LFGListInviteDialog.AcknowledgeButton)
	S:HandleButton(_G.LFGListInviteDialog.AcceptButton)
	S:HandleButton(_G.LFGListInviteDialog.DeclineButton)
	_G.LFGListInviteDialog.RoleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")

	hooksecurefunc("LFGListInviteDialog_Show", SetRoleIcon)

	S:HandleEditBox(LFGListFrame.SearchPanel.SearchBox)

	--[[local columns = {
		['Name'] = true,
		['Tank'] = true,
		['Healer'] = true,
		['Damager'] = true
	}

	for x in pairs(columns) do
		LFGListFrame.SearchPanel[x.."ColumnHeader"].Left:Hide()
		LFGListFrame.SearchPanel[x.."ColumnHeader"].Middle:Hide()
		LFGListFrame.SearchPanel[x.."ColumnHeader"].Right:Hide()
	end]]

	S:HandleButton(LFGListFrame.SearchPanel.BackButton, true)
	S:HandleButton(LFGListFrame.SearchPanel.SignUpButton, true)
	S:HandleButton(_G.LFGListSearchPanelScrollFrame.StartGroupButton,  true)
	LFGListFrame.SearchPanel.BackButton:ClearAllPoints()
	LFGListFrame.SearchPanel.BackButton:Point("BOTTOMLEFT", -1, 3)
	LFGListFrame.SearchPanel.SignUpButton:ClearAllPoints()
	LFGListFrame.SearchPanel.SignUpButton:Point("BOTTOMRIGHT", -6, 3)
	LFGListFrame.SearchPanel.ResultsInset:StripTextures()
	S:HandleScrollBar(_G.LFGListSearchPanelScrollFrameScrollBar)

	S:HandleButton(LFGListFrame.SearchPanel.FilterButton)
	LFGListFrame.SearchPanel.FilterButton:Point("LEFT", LFGListFrame.SearchPanel.SearchBox, "RIGHT", 5, 0)
	S:HandleButton(LFGListFrame.SearchPanel.RefreshButton)
	LFGListFrame.SearchPanel.RefreshButton:Size(24)
	LFGListFrame.SearchPanel.RefreshButton.Icon:Point("CENTER")

	hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(button)
		if not button.DeclineButton.template then
			S:HandleButton(button.DeclineButton, nil, true)
		end
		if not button.InviteButton.template then
			S:HandleButton(button.InviteButton)
		end
	end)

	hooksecurefunc("LFGListSearchEntry_Update", function(button)
		if not button.CancelButton.template then
			S:HandleButton(button.CancelButton, nil, true)
		end
	end)

	hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", function(self)
		for i = 1, LFGListFrame.SearchPanel.AutoCompleteFrame:GetNumChildren() do
			local child = select(i, LFGListFrame.SearchPanel.AutoCompleteFrame:GetChildren())
			if child and not child.isSkinned and child:IsObjectType('Button') then
				S:HandleButton(child)
				child.isSkinned = true
			end
		end

		local text = self.SearchBox:GetText()
		local matchingActivities = C_LFGList_GetAvailableActivities(self.categoryID, nil, self.filters, text)
		local numResults = min(#matchingActivities, _G.MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES)

		for i = 2, numResults do
			local button = self.AutoCompleteFrame.Results[i]
			if button and not button.moved then
				button:Point("TOPLEFT", self.AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, -2)
				button:Point("TOPRIGHT", self.AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, -2)
				button.moved = true
			end
		end
		self.AutoCompleteFrame:Height(numResults * (self.AutoCompleteFrame.Results[1]:GetHeight() + 3.5) + 8)
	end)

	LFGListFrame.SearchPanel.AutoCompleteFrame:StripTextures()
	LFGListFrame.SearchPanel.AutoCompleteFrame:CreateBackdrop("Transparent")
	LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:Point("TOPLEFT", LFGListFrame.SearchPanel.AutoCompleteFrame, "TOPLEFT", 0, 3)
	LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:Point("BOTTOMRIGHT", LFGListFrame.SearchPanel.AutoCompleteFrame, "BOTTOMRIGHT", 6, 3)

	LFGListFrame.SearchPanel.AutoCompleteFrame:Point("TOPLEFT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMLEFT", -2, -8)
	LFGListFrame.SearchPanel.AutoCompleteFrame:Point("TOPRIGHT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMRIGHT", -4, -8)

	--ApplicationViewer (Custom Groups)
	LFGListFrame.ApplicationViewer.EntryName:FontTemplate()
	LFGListFrame.ApplicationViewer.InfoBackground:SetTexCoord(unpack(E.TexCoords))
	S:HandleCheckBox(LFGListFrame.ApplicationViewer.AutoAcceptButton)

	LFGListFrame.ApplicationViewer.Inset:StripTextures()
	LFGListFrame.ApplicationViewer.Inset:SetTemplate("Transparent")

	S:HandleButton(LFGListFrame.ApplicationViewer.NameColumnHeader, true)
	S:HandleButton(LFGListFrame.ApplicationViewer.RoleColumnHeader, true)
	S:HandleButton(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, true)
	LFGListFrame.ApplicationViewer.NameColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.NameColumnHeader:Point("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPLEFT", 0, 1)
	LFGListFrame.ApplicationViewer.NameColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.RoleColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RoleColumnHeader:Point("LEFT", LFGListFrame.ApplicationViewer.NameColumnHeader, "RIGHT", 1, 0)
	LFGListFrame.ApplicationViewer.RoleColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:Point("LEFT", LFGListFrame.ApplicationViewer.RoleColumnHeader, "RIGHT", 1, 0)
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.PrivateGroup:FontTemplate()

	S:HandleButton(LFGListFrame.ApplicationViewer.RefreshButton)
	LFGListFrame.ApplicationViewer.RefreshButton:Size(24,24)
	LFGListFrame.ApplicationViewer.RefreshButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RefreshButton:Point("BOTTOMRIGHT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 16, 4)

	S:HandleButton(LFGListFrame.ApplicationViewer.RemoveEntryButton, true)
	S:HandleButton(LFGListFrame.ApplicationViewer.EditButton, true)
	LFGListFrame.ApplicationViewer.RemoveEntryButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RemoveEntryButton:Point("BOTTOMLEFT", -1, 3)
	LFGListFrame.ApplicationViewer.EditButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.EditButton:Point("BOTTOMRIGHT", -6, 3)

	local LFGListApplicationViewerScrollFrameScrollBar = _G.LFGListApplicationViewerScrollFrameScrollBar
	S:HandleScrollBar(LFGListApplicationViewerScrollFrameScrollBar)
	LFGListApplicationViewerScrollFrameScrollBar:ClearAllPoints()
	LFGListApplicationViewerScrollFrameScrollBar:Point("TOPLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 0, -14)
	LFGListApplicationViewerScrollFrameScrollBar:Point("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "BOTTOMRIGHT", 0, 14)

	hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex, categoryID, filters)
		local button = self.CategoryButtons[btnIndex]
		if(button) then
			if not button.isSkinned then
				button:SetTemplate()
				button.Icon:SetDrawLayer("BACKGROUND", 2)
				button.Icon:SetTexCoord(unpack(E.TexCoords))
				button.Icon:SetInside()
				button.Cover:Hide()
				button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
				button.HighlightTexture:SetInside()
				--Fix issue with labels not following changes to GameFontNormal as they should
				button.Label:SetFontObject(_G.GameFontNormal)
				button.isSkinned = true
			end

			button.SelectedTexture:Hide()
			local selected = self.selectedCategory == categoryID and self.selectedFilters == filters
			if(selected) then
				button:SetBackdropBorderColor(1, 1, 0)
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	-- Tutorial
	S:HandleCloseButton(_G.PremadeGroupsPvETutorialAlert.CloseButton)
end
S:AddCallback("LFG", LoadSkin)

local function LoadSecondarySkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true then return end

	local ChallengesFrame = _G.ChallengesFrame
	ChallengesFrame:DisableDrawLayer("BACKGROUND")
	_G.ChallengesFrameInset:StripTextures()

	-- Mythic+ KeyStoneFrame
	local KeyStoneFrame = _G.ChallengesKeystoneFrame
	KeyStoneFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(KeyStoneFrame.CloseButton)
	S:HandleButton(KeyStoneFrame.StartButton, true)

	hooksecurefunc("ChallengesFrame_Update", function(self)
		for _, frame in ipairs(self.DungeonIcons) do
			if not frame.backdrop then
				frame:GetRegions():SetAlpha(0)
				frame:CreateBackdrop("Transparent")
				frame.backdrop:SetAllPoints()
				S:HandleIcon(frame.Icon, true)
				frame.Icon:SetInside()
			end
		end
	end)

	hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", function(self)
		local affixes = C_MythicPlus_GetCurrentAffixes()
		if affixes then
			HandleAffixIcons(self.Child)
		end
	end)

	hooksecurefunc(KeyStoneFrame, "Reset", function(self)
		self:GetRegions():SetAlpha(0)
		self.InstructionBackground:SetAlpha(0)
	end)

	hooksecurefunc(KeyStoneFrame, "OnKeystoneSlotted", HandleAffixIcons)

	-- New Season Frame
	local NoticeFrame = _G.ChallengesFrame.SeasonChangeNoticeFrame
	S:HandleButton(NoticeFrame.Leave)
	NoticeFrame:StripTextures()
	NoticeFrame:CreateBackdrop("Overlay")
	NoticeFrame:SetFrameLevel(5)
	NoticeFrame.NewSeason:SetTextColor(1, .8, 0)
	NoticeFrame.NewSeason:SetShadowOffset(1, -1)
	NoticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
	NoticeFrame.SeasonDescription:SetShadowOffset(1, -1)
	NoticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
	NoticeFrame.SeasonDescription2:SetShadowOffset(1, -1)
	NoticeFrame.SeasonDescription3:SetTextColor(1, .8, 0)
	NoticeFrame.SeasonDescription3:SetShadowOffset(1, -1)

	local affix = _G.ChallengesFrame.SeasonChangeNoticeFrame.Affix
	affix:StripTextures()
	S:HandleIcon(affix.Portrait)
end

S:AddCallbackForAddon("Blizzard_ChallengesUI", "Challenges", LoadSecondarySkin)
