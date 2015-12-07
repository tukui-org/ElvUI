local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local LBG = LibStub("LibButtonGlow-1.0", true)

local lower = string.lower

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true then return end
	PVEFrame:StripTextures()
	PVEFrame:StripTextures()
	PVEFrameLeftInset:StripTextures()
	RaidFinderQueueFrame:StripTextures(true)
	PVEFrameBg:Hide()
	PVEFrameTitleBg:Hide()
	PVEFramePortrait:Hide()
	PVEFramePortraitFrame:Hide()
	PVEFrameTopRightCorner:Hide()
	PVEFrameTopBorder:Hide()
	PVEFrameLeftInsetBg:Hide()
	PVEFrame.shadows:Hide()
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
		local proposalExists, id, typeID, subtypeID, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader = GetLFGProposal();
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
		if backdrop.bgFile ~= E["media"].blankTex then
			self:SetTemplate("Transparent")
		end
	end)

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
				roleButton.background:SetPoint("CENTER")
				roleButton.background:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
				roleButton.background:SetAlpha(0.65)

				local buttonName = roleButton:GetName() ~= nil and roleButton:GetName() or roleButton.role
				roleButton.background:SetTexCoord(GetBackgroundTexCoordsForRole((lower(buttonName):find("tank") and "TANK") or (lower(buttonName):find("healer") and "HEALER") or "DAMAGER"))
			end
		end
	end

	LFDQueueFrameRoleButtonLeader.leadIcon = LFDQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
	LFDQueueFrameRoleButtonLeader.leadIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
	LFDQueueFrameRoleButtonLeader.leadIcon:SetPoint(LFDQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint())
	LFDQueueFrameRoleButtonLeader.leadIcon:Size(50)
	LFDQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.4)

	RaidFinderQueueFrameRoleButtonLeader.leadIcon = RaidFinderQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetPoint(RaidFinderQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint())
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:Size(50)
	RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.4)

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

		bu.ring:Hide()
		bu.bg:SetTexture("")
		bu.bg:SetAllPoints()

		bu:SetTemplate()
		bu:StyleButton()

		bu.icon:SetTexCoord(unpack(E.TexCoords))
		bu.icon:SetPoint("LEFT", bu, "LEFT")
		bu.icon:SetDrawLayer("OVERLAY")
		bu.icon:Size(40)
		bu.icon:ClearAllPoints()
		bu.icon:SetPoint("LEFT", 10, 0)
		bu.border = CreateFrame("Frame", nil, bu)
		bu.border:SetTemplate('Default')
		bu.border:SetOutside(bu.icon)
		bu.icon:SetParent(bu.border)
	end

	PVEFrame:CreateBackdrop("Transparent")
	for i=1, 3 do
		S:HandleTab(_G['PVEFrameTab'..i])
	end
	PVEFrameTab1:SetPoint('BOTTOMLEFT', PVEFrame, 'BOTTOMLEFT', 19, E.PixelMode and -31 or -32)

	S:HandleCloseButton(PVEFrameCloseButton)

	-- raid finder
	S:HandleButton(LFDQueueFrameFindGroupButton, true)

	LFDParentFrame:StripTextures()
	LFDParentFrameInset:StripTextures()



	local function ReskinRewards()
		LFDQueueFrame:StripTextures()

		for i = 1, LFD_MAX_REWARDS do
			local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
			local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]

			if button then
				if not button.reskinned then
					local cta = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."ShortageBorder"]
					local count = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
					local na = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."NameFrame"]

					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetDrawLayer("OVERLAY")
					count:SetDrawLayer("OVERLAY")
					na:SetTexture()
					na:SetSize(118, 39)
					cta:SetAlpha(0)

					button.border = CreateFrame("Frame", nil, button)
					button.border:SetTemplate()
					button.border:SetOutside(icon)
					icon:SetParent(button.border)
					count:SetParent(button.border)
					button.reskinned = true

					for j=1, 3 do
						local roleIcon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon"..j]
						if roleIcon then
							roleIcon:SetParent(button.border)
						end
					end
				end
			end
		end
	end

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", ReskinRewards)

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
		S:HandleCheckBox(_G["LFDQueueFrameSpecificListButton"..i].enableButton)
	end

	hooksecurefunc("ScenarioQueueFrameSpecific_Update", function()

		for i = 1, NUM_SCENARIO_CHOICE_BUTTONS do
			local button = _G["ScenarioQueueFrameSpecificButton"..i]

			if button and not button.skinned then
				S:HandleCheckBox(button.enableButton)
				button.skinned = true;
			end
		end
	end)

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local bu = _G["LFRQueueFrameSpecificListButton"..i].enableButton
		S:HandleCheckBox(bu)
	end

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	ScenarioQueueFrame:StripTextures()
	ScenarioFinderFrameInset:StripTextures()
	S:HandleButton(ScenarioQueueFrameFindGroupButton)


	-- Raid Finder
	RaidFinderFrame:StripTextures()
	RaidFinderFrameBottomInset:StripTextures()
	RaidFinderFrameRoleInset:StripTextures()
	RaidFinderFrameBottomInsetBg:Hide()
	RaidFinderFrameBtnCornerRight:Hide()
	RaidFinderFrameButtonBottomBorder:Hide()
	S:HandleDropDownBox(RaidFinderQueueFrameSelectionDropDown)
	RaidFinderFrameFindRaidButton:StripTextures()
	S:HandleButton(RaidFinderFrameFindRaidButton)
	RaidFinderQueueFrame:StripTextures()

	for i = 1, LFD_MAX_REWARDS do
		local button = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i]
		local icon = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."IconTexture"]

		if button then
			if not button.reskinned then
				local cta = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."ShortageBorder"]
				local count = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."Count"]
				local na = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."NameFrame"]
				button:StripTextures()

				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer("OVERLAY")
				count:SetDrawLayer("OVERLAY")
				na:SetTexture()
				na:SetSize(118, 39)
				cta:SetAlpha(0)

				button.border = CreateFrame("Frame", nil, button)
				button.border:SetTemplate()
				button.border:SetOutside(icon)
				icon:SetParent(button.border)
				count:SetParent(button.border)
				button.reskinned = true
			end
		end
	end

	-- Scenario finder
	ScenarioFinderFrameInset:DisableDrawLayer("BORDER")
	ScenarioFinderFrame.TopTileStreaks:Hide()
	ScenarioFinderFrameBtnCornerRight:Hide()
	ScenarioFinderFrameButtonBottomBorder:Hide()
	ScenarioQueueFrame.Bg:Hide()
	ScenarioFinderFrameInset:GetRegions():Hide()

	local function ReskinRewards()
		LFDQueueFrame:StripTextures()

		for i = 1, LFD_MAX_REWARDS do
			local button = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i]
			local icon = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]

			if button then
				if not button.reskinned then
					local cta = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."ShortageBorder"]
					local count = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
					local na = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..i.."NameFrame"]

					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetDrawLayer("OVERLAY")
					count:SetDrawLayer("OVERLAY")
					na:SetTexture()
					na:SetSize(118, 39)
					cta:SetAlpha(0)

					button.border = CreateFrame("Frame", nil, button)
					button.border:SetTemplate()
					button.border:SetOutside(icon)
					icon:SetParent(button.border)
					count:SetParent(button.border)
					button.reskinned = true
				end
			end
		end
	end

	hooksecurefunc("ScenarioQueueFrameRandom_UpdateFrame", ReskinRewards)

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
	LFRBrowseFrameRoleInsetBg:Hide()
	LFRQueueFrameCommentScrollFrame:CreateBackdrop()
	LFRBrowseFrameColumnHeader1:SetWidth(88) --Fix the columns being slightly off

	for i = 1, 14 do
		if i ~= 6 and i ~= 8 then
			select(i, RaidBrowserFrame:GetRegions()):Hide()
		end
	end

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
				S:HandleCheckBox(roleButton.checkButton)
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
	LFGListFrame.CategorySelection.Inset:StripTextures()
	S:HandleButton(LFGListFrame.CategorySelection.StartGroupButton, true)
	S:HandleButton(LFGListFrame.CategorySelection.FindGroupButton, true)
	
	--Fix issue with labels not following changes to GameFontNormal as they should
	local function SetLabelFontObject(self, btnIndex)
		local button = self.CategoryButtons[btnIndex]
		if button then
			button.Label:SetFontObject(GameFontNormal)
		end
	end
	hooksecurefunc("LFGListCategorySelection_AddButton", SetLabelFontObject)

	LFGListFrame.EntryCreation.Inset:StripTextures()
	S:HandleButton(LFGListFrame.EntryCreation.CancelButton, true)
	S:HandleButton(LFGListFrame.EntryCreation.ListGroupButton, true)
	S:HandleEditBox(LFGListEntryCreationDescription)

	S:HandleEditBox(LFGListFrame.EntryCreation.Name)
	S:HandleEditBox(LFGListFrame.EntryCreation.ItemLevel.EditBox)
	S:HandleEditBox(LFGListFrame.EntryCreation.VoiceChat.EditBox)

	S:HandleDropDownBox(LFGListEntryCreationActivityDropDown)
	S:HandleDropDownBox(LFGListEntryCreationGroupDropDown)
	S:HandleDropDownBox(LFGListEntryCreationCategoryDropDown, 330)

	S:HandleCheckBox(LFGListFrame.EntryCreation.ItemLevel.CheckButton)
	S:HandleCheckBox(LFGListFrame.EntryCreation.VoiceChat.CheckButton)

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
		local _,_,_,_, role = C_LFGList.GetApplicationInfo(resultID)
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

	for x, _ in pairs(columns) do
		LFGListFrame.SearchPanel[x.."ColumnHeader"].Left:Hide()
		LFGListFrame.SearchPanel[x.."ColumnHeader"].Middle:Hide()
		LFGListFrame.SearchPanel[x.."ColumnHeader"].Right:Hide()
	end]]

	S:HandleButton(LFGListFrame.SearchPanel.BackButton, true)
	S:HandleButton(LFGListFrame.SearchPanel.SignUpButton, true)
	S:HandleButton(LFGListSearchPanelScrollFrame.StartGroupButton,  true)
	LFGListFrame.SearchPanel.ResultsInset:StripTextures()
	S:HandleScrollBar(LFGListSearchPanelScrollFrameScrollBar)
	LFGListFrame.SearchPanel.AutoCompleteFrame:StripTextures()
	LFGListFrame.SearchPanel.AutoCompleteFrame:SetTemplate("Transparent")

	S:HandleButton(LFGListFrame.SearchPanel.FilterButton)
	S:HandleButton(LFGListFrame.SearchPanel.RefreshButton)
	LFGListFrame.SearchPanel.RefreshButton:Size(26)


	--ApplicationViewer (Custom Groups)
	LFGListFrame.ApplicationViewer.InfoBackground:SetTexCoord(unpack(E.TexCoords))
	S:HandleCheckBox(LFGListFrame.ApplicationViewer.AutoAcceptButton)

	LFGListFrame.ApplicationViewer.Inset:StripTextures()
	LFGListFrame.ApplicationViewer.Inset:SetTemplate("Transparent")

	S:HandleButton(LFGListFrame.ApplicationViewer.NameColumnHeader, true)
	S:HandleButton(LFGListFrame.ApplicationViewer.RoleColumnHeader, true)
	S:HandleButton(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, true)
	LFGListFrame.ApplicationViewer.NameColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.NameColumnHeader:SetPoint("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPLEFT", 0, 1)
	LFGListFrame.ApplicationViewer.RoleColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RoleColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.NameColumnHeader, "RIGHT", 1, 0)
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.RoleColumnHeader, "RIGHT", 1, 0)

	S:HandleButton(LFGListFrame.ApplicationViewer.RefreshButton)
	LFGListFrame.ApplicationViewer.RefreshButton:SetSize(24,24)
	LFGListFrame.ApplicationViewer.RefreshButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RefreshButton:SetPoint("BOTTOMRIGHT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 16, 4)

	S:HandleButton(LFGListFrame.ApplicationViewer.RemoveEntryButton, true)
	S:HandleButton(LFGListFrame.ApplicationViewer.EditButton, true)
	LFGListFrame.ApplicationViewer.RemoveEntryButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RemoveEntryButton:SetPoint("BOTTOMLEFT", -1, 3)
	LFGListFrame.ApplicationViewer.EditButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.EditButton:SetPoint("BOTTOMRIGHT", -6, 3)

	S:HandleScrollBar(LFGListApplicationViewerScrollFrameScrollBar)
	LFGListApplicationViewerScrollFrameScrollBar:ClearAllPoints()
	LFGListApplicationViewerScrollFrameScrollBar:SetPoint("TOPLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 0, -14)
	LFGListApplicationViewerScrollFrameScrollBar:SetPoint("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "BOTTOMRIGHT", 0, 14)
end

S:RegisterSkin("ElvUI", LoadSkin)

local function LoadSecondarySkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfg ~= true then return end
	ChallengesFrameInset:StripTextures()
	ChallengesFrameInsetBg:Hide()
	ChallengesFrameDetails.bg:Hide()

	S:HandleButton(ChallengesFrameLeaderboard, true)
	select(2, ChallengesFrameDetails:GetRegions()):Hide()
	select(9, ChallengesFrameDetails:GetRegions()):Hide()
	select(10, ChallengesFrameDetails:GetRegions()):Hide()
	select(11, ChallengesFrameDetails:GetRegions()):Hide()
	ChallengesFrameDungeonButton1:SetPoint("TOPLEFT", ChallengesFrame, "TOPLEFT", 8, -83)

	for i = 1, 8 do
		local bu = ChallengesFrame["button"..i]
		S:HandleButton(bu)
		bu:StyleButton()
		bu:SetHighlightTexture("")
		bu.selectedTex:SetAlpha(.2)
		bu.selectedTex:SetPoint("TOPLEFT", 1, -1)
		bu.selectedTex:SetPoint("BOTTOMRIGHT", -1, 1)
		bu.NoMedal:Kill()
	end

	for i = 1, 3 do
		local rewardsRow = ChallengesFrame["RewardRow"..i]
		for j = 1, 2 do
			local bu = rewardsRow["Reward"..j]
			bu:CreateBackdrop()
			bu.Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end
end

S:RegisterSkin("Blizzard_ChallengesUI", LoadSecondarySkin)