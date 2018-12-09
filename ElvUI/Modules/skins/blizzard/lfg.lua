local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local LBG = LibStub("LibButtonGlow-1.0", true)

--Cache global variables
--Lua functions
local _G = _G
local unpack, ipairs, pairs, select = unpack, ipairs, pairs, select
local lower = string.lower
local min = math.min
--WoW API / Variables
local CreateFrame = CreateFrame
local GetLFGProposal = GetLFGProposal
local GetBackgroundTexCoordsForRole = GetBackgroundTexCoordsForRole
local C_LFGList_GetAvailableRoles = C_LFGList.GetAvailableRoles
local C_LFGList_GetApplicationInfo = C_LFGList.GetApplicationInfo
local C_LFGList_GetAvailableActivities = C_LFGList.GetAvailableActivities
local C_ChallengeMode_GetAffixInfo = C_ChallengeMode.GetAffixInfo
local C_MythicPlus_GetCurrentAffixes = C_MythicPlus.GetCurrentAffixes
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameFontNormal, NUM_SCENARIO_CHOICE_BUTTONS, MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES
-- GLOBALS: NUM_LFD_CHOICE_BUTTONS, NUM_LFR_CHOICE_BUTTONS, CHALLENGE_MODE_EXTRA_AFFIX_INFO

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true then return end

	local PVEFrame = _G["PVEFrame"]
	PVEFrame:StripTextures()
	PVEFrameLeftInset:StripTextures()
	RaidFinderQueueFrame:StripTextures(true)
	PVEFrameBg:Hide()
	PVEFramePortrait:Hide()
	PVEFrame.shadows:Kill() -- We need to kill it, because if you switch to Mythic Dungeon Tab and back, it shows back up.
	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)
	S:HandleButton(LFDQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)
	S:HandleButton(ScenarioQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton)
	S:HandleScrollBar(ScenarioQueueFrameRandomScrollFrameScrollBar);

	GroupFinderFrameGroupButton1.icon:SetTexture("Interface\\Icons\\INV_Helmet_08")
	GroupFinderFrameGroupButton2.icon:SetTexture("Interface\\Icons\\inv_helmet_06")
	GroupFinderFrameGroupButton3.icon:SetTexture("Interface\\Icons\\Icon_Scenarios")

	LFGDungeonReadyDialogBackground:Kill()
	S:HandleButton(LFGDungeonReadyDialogEnterDungeonButton)
	S:HandleButton(LFGDungeonReadyDialogLeaveQueueButton)
	S:HandleCloseButton(LFGDungeonReadyDialogCloseButton)
	LFGDungeonReadyDialog:StripTextures()
	LFGDungeonReadyDialog:SetTemplate("Transparent")
	LFGDungeonReadyStatus:StripTextures()
	LFGDungeonReadyStatus:SetTemplate("Transparent")
	LFGDungeonReadyDialogRoleIconTexture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	LFGDungeonReadyDialogRoleIconTexture:SetAlpha(0.5)
	hooksecurefunc("LFGDungeonReadyPopup_Update", function()
		local _, _, _, _, _, _, role = GetLFGProposal()
		if LFGDungeonReadyDialogRoleIcon:IsShown() then
			if role == "DAMAGER" then
				LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
			elseif role == "TANK" then
				LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
			elseif role == "HEALER" then
				LFGDungeonReadyDialogRoleIconTexture:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
			end
		end
	end)

	hooksecurefunc(LFGDungeonReadyDialog, "SetBackdrop", function(self, backdrop)
		if backdrop.bgFile ~= E.media.blankTex then
			self:SetTemplate("Transparent")
		end
	end)

	LFDQueueFrame:StripTextures(true)
	LFDQueueFrameRoleButtonTankIncentiveIcon:SetAlpha(0)
	LFDQueueFrameRoleButtonHealerIncentiveIcon:SetAlpha(0)
	LFDQueueFrameRoleButtonDPSIncentiveIcon:SetAlpha(0)

	local function OnShow(self)
		LBG.ShowOverlayGlow(self:GetParent().checkButton)
	end
	local function OnHide(self)
		LBG.HideOverlayGlow(self:GetParent().checkButton)
	end
	LFDQueueFrameRoleButtonTankIncentiveIcon:HookScript("OnShow", OnShow)
	LFDQueueFrameRoleButtonHealerIncentiveIcon:HookScript("OnShow", OnShow)
	LFDQueueFrameRoleButtonDPSIncentiveIcon:HookScript("OnShow", OnShow)
	LFDQueueFrameRoleButtonTankIncentiveIcon:HookScript("OnHide", OnHide)
	LFDQueueFrameRoleButtonHealerIncentiveIcon:HookScript("OnHide", OnHide)
	LFDQueueFrameRoleButtonDPSIncentiveIcon:HookScript("OnHide", OnHide)
	LFDQueueFrameRoleButtonTank.shortageBorder:Kill()
	LFDQueueFrameRoleButtonDPS.shortageBorder:Kill()
	LFDQueueFrameRoleButtonHealer.shortageBorder:Kill()
	LFGDungeonReadyDialog.filigree:SetAlpha(0)
	LFGDungeonReadyDialog.bottomArt:SetAlpha(0)
	S:HandleCloseButton(LFGDungeonReadyStatusCloseButton)

	local roleButtons = {
		LFDQueueFrameRoleButtonHealer,
		LFDQueueFrameRoleButtonDPS,
		LFDQueueFrameRoleButtonLeader,
		LFDQueueFrameRoleButtonTank,
		RaidFinderQueueFrameRoleButtonHealer,
		RaidFinderQueueFrameRoleButtonDPS,
		RaidFinderQueueFrameRoleButtonLeader,
		RaidFinderQueueFrameRoleButtonTank,
		LFGInvitePopupRoleButtonTank,
		LFGInvitePopupRoleButtonHealer,
		LFGInvitePopupRoleButtonDPS,
		LFGListApplicationDialog.TankButton,
		LFGListApplicationDialog.HealerButton,
		LFGListApplicationDialog.DamagerButton,
	}

	for _, roleButton in pairs(roleButtons) do
		S:HandleCheckBox(roleButton.checkButton or roleButton.CheckButton, true)
		roleButton:DisableDrawLayer("ARTWORK")
		roleButton:DisableDrawLayer("OVERLAY")

		if(not roleButton.background) then
			local isLeader = roleButton:GetName() ~= nil and roleButton:GetName():find("Leader") or false
			if(not isLeader) then
				roleButton.background = roleButton:CreateTexture(nil, "BACKGROUND")
				roleButton.background:SetSize(80, 80)
				roleButton.background:Point("CENTER")
				roleButton.background:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
				roleButton.background:SetAlpha(0.65)

				local buttonName = roleButton:GetName() ~= nil and roleButton:GetName() or roleButton.role
				roleButton.background:SetTexCoord(GetBackgroundTexCoordsForRole((lower(buttonName):find("tank") and "TANK") or (lower(buttonName):find("healer") and "HEALER") or "DAMAGER"))
			end
		end
	end

	--Fix issue with role buttons overlapping each other (Blizzard bug)
	local repositionCheckButtons = {
		LFGListApplicationDialog.TankButton.CheckButton,
		LFGListApplicationDialog.HealerButton.CheckButton,
		LFGListApplicationDialog.DamagerButton.CheckButton,
	}
	for _, checkButton in pairs(repositionCheckButtons) do
		checkButton:ClearAllPoints()
		checkButton:Point("BOTTOMLEFT", 0, 0)
	end
	hooksecurefunc("LFGListApplicationDialog_UpdateRoles", function(self) --Copy from Blizzard, we just fix position
		local availTank, availHealer, availDPS = C_LFGList_GetAvailableRoles();

		local avail1, avail2;
		if ( availTank ) then
			avail1 = self.TankButton;
		end
		if ( availHealer ) then
			if ( avail1 ) then
				avail2 = self.HealerButton;
			else
				avail1 = self.HealerButton;
			end
		end
		if ( availDPS ) then
			if ( avail1 ) then
				avail2 = self.DamagerButton;
			else
				avail1 = self.DamagerButton;
			end
		end

		if ( avail2 ) then
			avail1:ClearAllPoints();
			avail1:SetPoint("TOPRIGHT", self, "TOP", -40, -35);
			avail2:ClearAllPoints();
			avail2:SetPoint("TOPLEFT", self, "TOP", 40, -35);
		elseif ( avail1 ) then
			avail1:ClearAllPoints();
			avail1:SetPoint("TOP", self, "TOP", 0, -35);
		end
	end)

	LFDQueueFrameRoleButtonLeader.leadIcon = LFDQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
	LFDQueueFrameRoleButtonLeader.leadIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\leader")
	LFDQueueFrameRoleButtonLeader.leadIcon:Point(LFDQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint(), -10, 5)
	LFDQueueFrameRoleButtonLeader.leadIcon:Size(50)
	LFDQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.6)

	RaidFinderQueueFrameRoleButtonLeader.leadIcon = RaidFinderQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\leader")
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:Point(RaidFinderQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint(), -10, 5)
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:Size(50)
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.6)

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
		local bu = GroupFinderFrame["groupButton"..i]
		bu.ring:Kill()
		bu.bg:Kill()
		S:HandleButton(bu)

		bu.icon:Size(45)
		bu.icon:ClearAllPoints()
		bu.icon:Point("LEFT", 10, 0)
		S:HandleTexture(bu.icon, bu)
	end

	PVEFrame:CreateBackdrop("Transparent")
	for i=1, 3 do
		S:HandleTab(_G['PVEFrameTab'..i])
	end
	PVEFrameTab1:Point('BOTTOMLEFT', PVEFrame, 'BOTTOMLEFT', 19, E.PixelMode and -31 or -32)

	S:HandleCloseButton(PVEFrameCloseButton)

	-- raid finder
	S:HandleButton(LFDQueueFrameFindGroupButton, true)

	LFDParentFrame:StripTextures()
	LFDParentFrameInset:StripTextures()

	local function HandleGoldIcon(button)
		_G[button.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G[button.."IconTexture"]:SetDrawLayer("OVERLAY")
		_G[button.."Count"]:SetDrawLayer("OVERLAY")
		_G[button.."NameFrame"]:SetTexture()
		_G[button.."NameFrame"]:SetSize(118, 39)

		_G[button].border = CreateFrame("Frame", nil, _G[button])
		_G[button].border:SetTemplate()
		_G[button].border:SetOutside(_G[button.."IconTexture"])
		_G[button.."IconTexture"]:SetParent(_G[button].border)
		_G[button.."Count"]:SetParent(_G[button].border)
	end
	HandleGoldIcon("LFDQueueFrameRandomScrollFrameChildFrameMoneyReward")
	HandleGoldIcon("RaidFinderQueueFrameScrollFrameChildFrameMoneyReward")
	HandleGoldIcon("ScenarioQueueFrameRandomScrollFrameChildFrameMoneyReward")

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		S:HandleCheckBox(_G["LFDQueueFrameSpecificListButton"..i].enableButton, nil, true)
	end

	hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
		if button and button.expandOrCollapseButton:IsShown() then
			if button.isCollapsed then
				button.expandOrCollapseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusButton");
			else
				button.expandOrCollapseButton:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\MinusButton");
			end
		end
	end)

	hooksecurefunc("ScenarioQueueFrameSpecific_Update", function()

		for i = 1, NUM_SCENARIO_CHOICE_BUTTONS do
			local button = _G["ScenarioQueueFrameSpecificButton"..i]

			if button and not button.skinned then
				S:HandleCheckBox(button.enableButton, nil, true)
				button.skinned = true;
			end
		end
	end)

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local bu = _G["LFRQueueFrameSpecificListButton"..i].enableButton
		S:HandleCheckBox(bu, nil, true)
	end

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	ScenarioQueueFrame:StripTextures()
	ScenarioFinderFrameInset:StripTextures()
	S:HandleButton(ScenarioQueueFrameFindGroupButton)

	-- Raid Finder
	RaidFinderFrame:StripTextures()
	RaidFinderFrameRoleInset:StripTextures()
	S:HandleDropDownBox(RaidFinderQueueFrameSelectionDropDown)
	RaidFinderFrameFindRaidButton:StripTextures()
	S:HandleButton(RaidFinderFrameFindRaidButton)
	RaidFinderQueueFrame:StripTextures()
	RaidFinderQueueFrameScrollFrameScrollBar:StripTextures()
	S:HandleScrollBar(RaidFinderQueueFrameScrollFrameScrollBar)

	-- Scenario finder
	ScenarioFinderFrameInset:DisableDrawLayer("BORDER")
	ScenarioQueueFrame.Bg:Hide()
	ScenarioFinderFrameInset:GetRegions():Hide()

	--Skin Reward Items (This works for all frames, LFD, Raid, Scenario)
	local function SkinItemButton(parentFrame, _, index)
		local parentName = parentFrame:GetName();
		local item = _G[parentName.."Item"..index];

		if item and not item.isSkinned then
			item.border = CreateFrame("Frame", nil, item)
			item.border:SetTemplate()
			item.border:SetOutside(item.Icon)

			hooksecurefunc(item.IconBorder, "SetVertexColor", function(self, r, g, b)
				self:GetParent().border:SetBackdropBorderColor(r, g, b)
				self:SetTexture("")
			end)
			hooksecurefunc(item.IconBorder, "Hide", function(self)
				self:GetParent().border:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)

			item.Icon:SetTexCoord(unpack(E.TexCoords))
			item.Icon:SetDrawLayer("OVERLAY")
			item.Icon:SetParent(item.border)

			item.Count:SetDrawLayer("OVERLAY")
			item.Count:SetParent(item.border)

			item.NameFrame:SetTexture()
			item.NameFrame:SetSize(118, 39)

			item.shortageBorder:SetTexture(nil)

			item.roleIcon1:SetParent(item.border)
			item.roleIcon2:SetParent(item.border)

			item.isSkinned = true
		end
	end
	hooksecurefunc("LFGRewardsFrame_SetItemButton", SkinItemButton)

	ScenarioQueueFrameFindGroupButton:StripTextures()
	S:HandleButton(ScenarioQueueFrameFindGroupButton)

	S:HandleDropDownBox(ScenarioQueueFrameTypeDropDown)

	-- Looking for raid
	LFRBrowseFrameListScrollFrame:StripTextures()

	LFRBrowseFrame:HookScript('OnShow', function()
		if not LFRBrowseFrameListScrollFrameScrollBar.skinned then
			S:HandleScrollBar(LFRBrowseFrameListScrollFrameScrollBar)
			LFRBrowseFrameListScrollFrameScrollBar.skinned = true
		end
	end)

	LFRBrowseFrameRoleInset:DisableDrawLayer("BORDER")
	RaidBrowserFrameBg:Hide()
	LFRQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
	LFRQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
	LFRQueueFrameCommentScrollFrame:CreateBackdrop()
	LFRBrowseFrameColumnHeader1:Width(94) --Fix the columns being slightly off
	LFRBrowseFrameColumnHeader2:Width(38)

	RaidBrowserFrame:CreateBackdrop('Transparent')
	S:HandleCloseButton(RaidBrowserFrameCloseButton)
	S:HandleButton(LFRQueueFrameFindGroupButton)
	S:HandleButton(LFRQueueFrameAcceptCommentButton)

	S:HandleScrollBar(LFRQueueFrameCommentScrollFrameScrollBar)
	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)
	LFDQueueFrameSpecificListScrollFrame:StripTextures()
	RaidBrowserFrame:HookScript('OnShow', function()
		if not LFRQueueFrameSpecificListScrollFrameScrollBar.skinned then
			S:HandleScrollBar(LFRQueueFrameSpecificListScrollFrameScrollBar)

			local roleButtons = {
				LFRQueueFrameRoleButtonHealer,
				LFRQueueFrameRoleButtonDPS,
				LFRQueueFrameRoleButtonTank,
			}

			LFRBrowseFrame:StripTextures()
			for _, roleButton in pairs(roleButtons) do
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
				tab:CreateBackdrop("Default")
				tab.backdrop:SetAllPoints()
				tab:StyleButton(true)
				hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
					if texPath ~= nil then
						self:SetTexture(nil);
					end
				end)

				hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
					if texPath ~= nil then
						self:SetTexture(nil);
					end
				end	)
			end

			for i=1, 7 do
				local tab = _G['LFRBrowseFrameColumnHeader'..i]
				tab:DisableDrawLayer('BACKGROUND')
			end

			S:HandleDropDownBox(LFRBrowseFrameRaidDropDown)
			S:HandleButton(LFRBrowseFrameRefreshButton)
			S:HandleButton(LFRBrowseFrameInviteButton)
			S:HandleButton(LFRBrowseFrameSendMessageButton)
			LFRQueueFrameSpecificListScrollFrameScrollBar.skinned = true
		end
	end)

	--[[LFGInvitePopup_Update("Elvz", true, true, true)
	StaticPopupSpecial_Show(LFGInvitePopup);]]
	LFGInvitePopup:StripTextures()
	LFGInvitePopup:SetTemplate("Transparent")
	S:HandleButton(LFGInvitePopupAcceptButton)
	S:HandleButton(LFGInvitePopupDeclineButton)

	S:HandleButton(_G[LFDQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[LFDQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])
	S:HandleButton(_G[RaidFinderQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[RaidFinderQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])
	S:HandleButton(_G[ScenarioQueueFrame.PartyBackfill:GetName().."BackfillButton"])
	S:HandleButton(_G[ScenarioQueueFrame.PartyBackfill:GetName().."NoBackfillButton"])
	LFDQueueFrameRandomScrollFrameScrollBar:StripTextures()
	ScenarioQueueFrameSpecificScrollFrame:StripTextures()
	S:HandleScrollBar(LFDQueueFrameRandomScrollFrameScrollBar)
	S:HandleScrollBar(ScenarioQueueFrameSpecificScrollFrameScrollBar)

	--LFGListFrame
	local LFGListFrame = _G["LFGListFrame"]
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

	S:HandleDropDownBox(LFGListEntryCreationActivityDropDown)
	S:HandleDropDownBox(LFGListEntryCreationGroupDropDown)
	S:HandleDropDownBox(LFGListEntryCreationCategoryDropDown, 330)

	S:HandleCheckBox(LFGListFrame.EntryCreation.ItemLevel.CheckButton)
	S:HandleCheckBox(LFGListFrame.EntryCreation.HonorLevel.CheckButton)
	S:HandleCheckBox(LFGListFrame.EntryCreation.VoiceChat.CheckButton)
	S:HandleCheckBox(LFGListFrame.EntryCreation.PrivateGroup.CheckButton)

	LFGListFrame.EntryCreation.ActivityFinder.Dialog:StripTextures()
	LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetTemplate("Transparent")
	LFGListFrame.EntryCreation.ActivityFinder.Dialog.BorderFrame:StripTextures()
	LFGListFrame.EntryCreation.ActivityFinder.Dialog.BorderFrame:SetTemplate("Transparent")

	S:HandleEditBox(LFGListFrame.EntryCreation.ActivityFinder.Dialog.EntryBox)
	S:HandleScrollBar(LFGListEntryCreationSearchScrollFrameScrollBar)
	S:HandleButton(LFGListFrame.EntryCreation.ActivityFinder.Dialog.SelectButton)
	S:HandleButton(LFGListFrame.EntryCreation.ActivityFinder.Dialog.CancelButton)

	LFGListApplicationDialog:StripTextures()
	LFGListApplicationDialog:SetTemplate("Transparent")
	S:HandleButton(LFGListApplicationDialog.SignUpButton)
	S:HandleButton(LFGListApplicationDialog.CancelButton)
	S:HandleEditBox(LFGListApplicationDialogDescription)

	LFGListInviteDialog:SetTemplate("Transparent")
	S:HandleButton(LFGListInviteDialog.AcknowledgeButton)
	S:HandleButton(LFGListInviteDialog.AcceptButton)
	S:HandleButton(LFGListInviteDialog.DeclineButton)
	LFGListInviteDialog.RoleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")

	local function SetRoleIcon(self, resultID)
		local _,_,_,_, role = C_LFGList_GetApplicationInfo(resultID)
		self.RoleIcon:SetTexCoord(GetBackgroundTexCoordsForRole(role))
	end
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
	S:HandleButton(LFGListSearchPanelScrollFrame.StartGroupButton,  true)
	LFGListFrame.SearchPanel.BackButton:ClearAllPoints()
	LFGListFrame.SearchPanel.BackButton:Point("BOTTOMLEFT", -1, 3)
	LFGListFrame.SearchPanel.SignUpButton:ClearAllPoints()
	LFGListFrame.SearchPanel.SignUpButton:Point("BOTTOMRIGHT", -6, 3)
	LFGListFrame.SearchPanel.ResultsInset:StripTextures()
	S:HandleScrollBar(LFGListSearchPanelScrollFrameScrollBar)

	S:HandleButton(LFGListFrame.SearchPanel.FilterButton)
	LFGListFrame.SearchPanel.FilterButton:SetPoint("LEFT", LFGListFrame.SearchPanel.SearchBox, "RIGHT", 5, 0)
	S:HandleButton(LFGListFrame.SearchPanel.RefreshButton)
	LFGListFrame.SearchPanel.RefreshButton:Size(24)
	LFGListFrame.SearchPanel.RefreshButton.Icon:SetPoint("CENTER")

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
			if child and not child.isSkinned and child:GetObjectType() == "Button" then
				S:HandleButton(child)
				child.isSkinned = true
			end
		end

		local text = self.SearchBox:GetText()
		local matchingActivities = C_LFGList_GetAvailableActivities(self.categoryID, nil, self.filters, text)
		local numResults = min(#matchingActivities, MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES)

		for i = 2, numResults do
			local button = self.AutoCompleteFrame.Results[i]
			if button and not button.moved then
				button:SetPoint("TOPLEFT", self.AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, -2)
				button:SetPoint("TOPRIGHT", self.AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, -2)
				button.moved = true
			end
		end
		self.AutoCompleteFrame:SetHeight(numResults * (self.AutoCompleteFrame.Results[1]:GetHeight() + 3.5) + 8)
	end)

	LFGListFrame.SearchPanel.AutoCompleteFrame:StripTextures()
	LFGListFrame.SearchPanel.AutoCompleteFrame:CreateBackdrop("Transparent")
	LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.AutoCompleteFrame, "TOPLEFT", 0, 3)
	LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("BOTTOMRIGHT", LFGListFrame.SearchPanel.AutoCompleteFrame, "BOTTOMRIGHT", 6, 3)

	LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMLEFT", -2, -8)
	LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMRIGHT", -4, -8)

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
	LFGListFrame.ApplicationViewer.RefreshButton:SetSize(24,24)
	LFGListFrame.ApplicationViewer.RefreshButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RefreshButton:Point("BOTTOMRIGHT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 16, 4)

	S:HandleButton(LFGListFrame.ApplicationViewer.RemoveEntryButton, true)
	S:HandleButton(LFGListFrame.ApplicationViewer.EditButton, true)
	LFGListFrame.ApplicationViewer.RemoveEntryButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RemoveEntryButton:Point("BOTTOMLEFT", -1, 3)
	LFGListFrame.ApplicationViewer.EditButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.EditButton:Point("BOTTOMRIGHT", -6, 3)

	S:HandleScrollBar(LFGListApplicationViewerScrollFrameScrollBar)
	LFGListApplicationViewerScrollFrameScrollBar:ClearAllPoints()
	LFGListApplicationViewerScrollFrameScrollBar:Point("TOPLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 0, -14)
	LFGListApplicationViewerScrollFrameScrollBar:Point("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "BOTTOMRIGHT", 0, 14)

	hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex, categoryID, filters)
		local button = self.CategoryButtons[btnIndex]
		if(button) then
			if not button.isSkinned then
				button:SetTemplate("Default")
				button.Icon:SetDrawLayer("BACKGROUND", 2)
				button.Icon:SetTexCoord(unpack(E.TexCoords))
				button.Icon:SetInside()
				button.Cover:Hide()
				button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
				button.HighlightTexture:SetInside()
				--Fix issue with labels not following changes to GameFontNormal as they should
				button.Label:SetFontObject(GameFontNormal)
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
	S:HandleCloseButton(PremadeGroupsPvETutorialAlert.CloseButton)
end
S:AddCallback("LFG", LoadSkin)

local function LoadSecondarySkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true then return end

	local ChallengesFrame = _G["ChallengesFrame"]
	ChallengesFrame:DisableDrawLayer("BACKGROUND")
	ChallengesFrameInset:StripTextures()

	-- Mythic+ KeyStoneFrame
	local KeyStoneFrame = _G["ChallengesKeystoneFrame"]
	KeyStoneFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(KeyStoneFrame.CloseButton)
	S:HandleButton(KeyStoneFrame.StartButton, true)

	hooksecurefunc("ChallengesFrame_Update", function(self)
		for _, frame in ipairs(self.DungeonIcons) do
			if not frame.backdrop then
				frame:CreateBackdrop("Transparent")
				frame.backdrop:SetAllPoints()
				frame:DisableDrawLayer("BORDER")
				frame.Icon:SetTexCoord(unpack(E.TexCoords))
				frame.Icon:SetInside()
			end
		end
	end)

	local function HandleAffixIcons(self)
		for _, frame in ipairs(self.Affixes) do
			frame.Border:SetTexture(nil)
			frame.Portrait:SetTexture(nil)

			if frame.info then
				frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
			elseif frame.affixID then
				local _, _, filedataid = C_ChallengeMode_GetAffixInfo(frame.affixID)
				frame.Portrait:SetTexture(filedataid)
			end
			frame.Portrait:SetTexCoord(unpack(E.TexCoords))
		end
	end

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
end

S:AddCallbackForAddon("Blizzard_ChallengesUI", "Challenges", LoadSecondarySkin)
