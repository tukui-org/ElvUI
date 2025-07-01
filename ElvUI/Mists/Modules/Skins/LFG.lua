local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LCG = E.Libs.CustomGlow

local _G = _G
local next, min = next, min
local unpack, pairs = unpack, pairs
local hooksecurefunc = hooksecurefunc

local UnitIsGroupLeader = UnitIsGroupLeader

local C_LFGList_GetAvailableActivities = C_LFGList.GetAvailableActivities
local C_LFGList_GetAvailableRoles = C_LFGList.GetAvailableRoles

local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME

local groupButtonIcons = {
	133076, -- interface\icons\inv_helmet_08.blp
	133074, -- interface\icons\inv_helmet_06.blp
	464820 -- interface\icons\achievement_general_stayclassy.blp
}

local function LFDQueueFrameRoleButtonIconOnShow(self)
	LCG.ShowOverlayGlow(self:GetParent().checkButton)
end

local function LFDQueueFrameRoleButtonIconOnHide(self)
	LCG.HideOverlayGlow(self:GetParent().checkButton)
end

local function HandleGoldIcon(button)
	local Button = _G[button]
	if Button.backdrop then return end

	local count = _G[button..'Count']
	local nameFrame = _G[button..'NameFrame']
	local iconTexture = _G[button..'IconTexture']

	Button:CreateBackdrop()
	Button.backdrop:ClearAllPoints()
	Button.backdrop:Point('LEFT', 1, 0)
	Button.backdrop:Size(42)

	iconTexture:SetTexCoord(unpack(E.TexCoords))
	iconTexture:SetDrawLayer('OVERLAY')
	iconTexture:SetParent(Button.backdrop)
	iconTexture:SetInside()

	count:SetParent(Button.backdrop)
	count:SetDrawLayer('OVERLAY')

	nameFrame:SetTexture()
	nameFrame:Size(118, 39)
end

local function SkinItemButton(parentFrame, _, index)
	local parentName = parentFrame:GetName()
	local item = _G[parentName..'Item'..index]
	if item and not item.backdrop then
		item:CreateBackdrop()
		item.backdrop:ClearAllPoints()
		item.backdrop:Point('LEFT', 1, 0)
		item.backdrop:Size(42)

		item.Icon:SetTexCoord(unpack(E.TexCoords))
		item.Icon:SetDrawLayer('OVERLAY')
		item.Icon:SetParent(item.backdrop)
		item.Icon:SetInside()

		item.Count:SetDrawLayer('OVERLAY')
		item.Count:SetParent(item.backdrop)

		item.NameFrame:SetTexture()
		item.NameFrame:Size(118, 39)

		item.shortageBorder:SetTexture()

		item.roleIcon1:SetParent(item.backdrop)
		item.roleIcon2:SetParent(item.backdrop)

		S:HandleIconBorder(item.IconBorder)
	end
end

local function LFDCheckboxMini_SetTexture(region, texture)
	if texture ~= E.Media.Textures.Melli then
		region:SetTexture(E.Media.Textures.Melli)
	end
end

local hookedMiniCheckbox = {}
local function LFDCheckboxMini_HookTexture(_, region)
	if region:GetTexture() == 130751 then
		if E.private.skins.checkBoxSkin then
			region:SetTexture(E.Media.Textures.Melli) -- set the initial texture
			if hookedMiniCheckbox[region] then return end -- dont rehook
			hooksecurefunc(region, 'SetTexture', LFDCheckboxMini_SetTexture)
			hookedMiniCheckbox[region] = true
		end
	else
		region:SetTexture(E.ClearTexture)
	end
end

local function LFDQueueFrameSpecificUpdateChild(child)
	S:ForEachCheckboxTextureRegion(child.enableButton, LFDCheckboxMini_HookTexture)

	if not child.IsSkinned then
		S:HandleCheckBox(child.enableButton)

		child.IsSkinned = true
	end
end

local function LFDQueueFrameSpecificUpdate(frame)
	frame:ForEachFrame(LFDQueueFrameSpecificUpdateChild)
end

function S:LookingForGroupFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	local PVEFrame = _G.PVEFrame
	S:HandlePortraitFrame(PVEFrame)

	_G.PVEFrameBg:Hide()
	PVEFrame.shadows:Kill() -- We need to kill it, because if you switch to Mythic Dungeon Tab and back, it shows back up.

	S:HandleButton(_G.LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(_G.LFDQueueFramePartyBackfillNoBackfillButton)

	_G.LFGDungeonReadyStatus:StripTextures()
	_G.LFGDungeonReadyStatus:SetTemplate('Transparent')

	S:HandleCloseButton(_G.LFGDungeonReadyDialogCloseButton)
	S:SkinReadyDialog(_G.LFGDungeonReadyDialog)

	_G.LFDQueueFrame:StripTextures(true)
	_G.LFDQueueFrameRoleButtonTankIncentiveIcon:SetAlpha(0)
	_G.LFDQueueFrameRoleButtonHealerIncentiveIcon:SetAlpha(0)
	_G.LFDQueueFrameRoleButtonDPSIncentiveIcon:SetAlpha(0)
	_G.LFDQueueFrameRoleButtonTankIncentiveIcon:HookScript('OnShow', LFDQueueFrameRoleButtonIconOnShow)
	_G.LFDQueueFrameRoleButtonHealerIncentiveIcon:HookScript('OnShow', LFDQueueFrameRoleButtonIconOnShow)
	_G.LFDQueueFrameRoleButtonDPSIncentiveIcon:HookScript('OnShow', LFDQueueFrameRoleButtonIconOnShow)
	_G.LFDQueueFrameRoleButtonTankIncentiveIcon:HookScript('OnHide', LFDQueueFrameRoleButtonIconOnHide)
	_G.LFDQueueFrameRoleButtonHealerIncentiveIcon:HookScript('OnHide', LFDQueueFrameRoleButtonIconOnHide)
	_G.LFDQueueFrameRoleButtonDPSIncentiveIcon:HookScript('OnHide', LFDQueueFrameRoleButtonIconOnHide)
	_G.LFDQueueFrameRoleButtonTank.shortageBorder:Kill()
	_G.LFDQueueFrameRoleButtonDPS.shortageBorder:Kill()
	_G.LFDQueueFrameRoleButtonHealer.shortageBorder:Kill()
	S:HandleCloseButton(_G.LFGDungeonReadyStatusCloseButton)

	-- Role check popup
	S:HandleFrame(_G.RolePollPopup)
	S:HandleButton(_G.RolePollPopupAcceptButton)
	S:HandleCloseButton(_G.RolePollPopupCloseButton)

	for _, roleButton in pairs({
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

		-- these three arent scaled to 0.7
		_G.RolePollPopupRoleButtonTank,
		_G.RolePollPopupRoleButtonHealer,
		_G.RolePollPopupRoleButtonDPS,
	}) do
		local checkButton = roleButton.checkButton or roleButton.CheckButton
		if checkButton:GetScale() ~= 1 then
			checkButton:SetScale(1)
		end

		S:HandleCheckBox(checkButton, nil, nil, true)
		checkButton.backdrop:SetInside()
		checkButton:Size(18)
	end

	hooksecurefunc('SetCheckButtonIsRadio', function(button)
		if not button.IsSkinned then
			S:HandleCheckBox(button)
		end
	end)

	for _, checkButton in pairs({ -- Fix issue with role buttons overlapping each other (Blizzard bug)
		_G.LFGListApplicationDialog.TankButton.CheckButton,
		_G.LFGListApplicationDialog.HealerButton.CheckButton,
		_G.LFGListApplicationDialog.DamagerButton.CheckButton,
	}) do
		checkButton:ClearAllPoints()
		checkButton:Point('BOTTOMLEFT', 0, 0)
	end

	hooksecurefunc('LFGListApplicationDialog_UpdateRoles', function(dialog) -- Copy from Blizzard, we just fix position
		local availTank, availHealer, availDPS = C_LFGList_GetAvailableRoles()

		local avail1, avail2
		if availTank then
			avail1 = dialog.TankButton
		end
		if availHealer then
			if avail1 then
				avail2 = dialog.HealerButton
			else
				avail1 = dialog.HealerButton
			end
		end
		if availDPS then
			if avail1 then
				avail2 = dialog.DamagerButton
			else
				avail1 = dialog.DamagerButton
			end
		end

		if avail2 then
			avail1:ClearAllPoints()
			avail1:Point('TOPRIGHT', dialog, 'TOP', -40, -35)
			avail2:ClearAllPoints()
			avail2:Point('TOPLEFT', dialog, 'TOP', 40, -35)
		elseif avail1 then
			avail1:ClearAllPoints()
			avail1:Point('TOP', dialog, 'TOP', 0, -35)
		end
	end)

	hooksecurefunc('LFG_DisableRoleButton', function(button)
		button.checkButton:SetAlpha(button.checkButton:GetChecked() and 1 or 0)

		if button.background then
			button.background:Show()
		end
	end)

	hooksecurefunc('LFG_EnableRoleButton', function(button)
		button.checkButton:SetAlpha(1)
	end)

	hooksecurefunc('LFG_PermanentlyDisableRoleButton', function(button)
		if button.background then
			button.background:Show()
			button.background:SetDesaturated(true)
		end
	end)

	do
		local index = 1
		local button = _G.GroupFinderFrame['groupButton'..index]
		while button do
			button.ring:Hide()
			button.bg:Kill()
			S:HandleButton(button)

			local texture = groupButtonIcons[index]
			if texture then
				button.icon:SetTexture(texture)
			end

			button.icon:Size(45)
			button.icon:ClearAllPoints()
			button.icon:Point('LEFT', 10, 0)
			S:HandleIcon(button.icon, true)

			index = index + 1
			button = _G.GroupFinderFrame['groupButton'..index]
		end
	end

	for i = 1, 3 do
		S:HandleTab(_G['PVEFrameTab'..i])
	end

	-- Reposition Tabs
	_G.PVEFrameTab1:ClearAllPoints()
	_G.PVEFrameTab2:ClearAllPoints()
	_G.PVEFrameTab3:ClearAllPoints()
	_G.PVEFrameTab1:Point('BOTTOMLEFT', _G.PVEFrame, 'BOTTOMLEFT', -10, -32)
	_G.PVEFrameTab2:Point('TOPLEFT', _G.PVEFrameTab1, 'TOPRIGHT', -19, 0)
	_G.PVEFrameTab3:Point('TOPLEFT', _G.PVEFrameTab2, 'TOPRIGHT', -19, 0)

	-- Scenario Tab
	local ScenarioQueueFrame = _G.ScenarioQueueFrame
	if ScenarioQueueFrame then
		ScenarioQueueFrame:StripTextures()
		_G.ScenarioFinderFrameInset:StripTextures()
		_G.ScenarioQueueFrameBackground:SetAlpha(0)
		S:HandleDropDownBox(_G.ScenarioQueueFrameTypeDropdown, 190)
		S:HandleTrimScrollBar(_G.ScenarioQueueFrameRandomScrollFrame.ScrollBar)
		S:HandleTrimScrollBar(_G.ScenarioQueueFrameSpecific.ScrollBar)
		S:HandleButton(_G.ScenarioQueueFrameFindGroupButton)

		_G.ScenarioQueueFrameSpecificScrollFrame:StripTextures()

		_G.ScenarioQueueFrameRandomScrollFrameChildFrameMoneyRewardNameFrame:StripTextures()

		hooksecurefunc(_G.ScenarioQueueFrameSpecificScrollFrame, 'Update', LFDQueueFrameSpecificUpdate)

		if _G.ScenarioQueueFrameRandomScrollFrameScrollBar then
			_G.ScenarioQueueFrameRandomScrollFrameScrollBar:SetAlpha(0)
		end
	end

	-- Dungeon finder
	S:HandleButton(_G.LFDQueueFrameFindGroupButton)
	S:HandleTrimScrollBar(_G.LFDQueueFrameRandomScrollFrame.ScrollBar)

	_G.LFDParentFrame:StripTextures()
	_G.LFDParentFrameInset:StripTextures()

	HandleGoldIcon('LFDQueueFrameRandomScrollFrameChildFrameMoneyReward')

	hooksecurefunc('LFGDungeonListButton_SetDungeon', function(button)
		if button and button.expandOrCollapseButton:IsShown() then
			if button.isCollapsed then
				button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.PlusButton)
			else
				button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.MinusButton)
			end
		end
	end)

	S:HandleDropDownBox(_G.LFDQueueFrameTypeDropdown, 200)

	-- Raid Finder
	_G.RaidFinderFrame:StripTextures()
	_G.RaidFinderFrameRoleInset:StripTextures()
	_G.RaidFinderQueueFrame:StripTextures(true)

	S:HandleDropDownBox(_G.RaidFinderQueueFrameSelectionDropdown, 200)

	S:HandleTrimScrollBar(_G.RaidFinderQueueFrameScrollFrame.ScrollBar)
	HandleGoldIcon('RaidFinderQueueFrameScrollFrameChildFrameMoneyReward')

	_G.RaidFinderFrameFindRaidButton:StripTextures()
	S:HandleButton(_G.RaidFinderFrameFindRaidButton)

	-- Skin Reward Items (This works for all frames, LFD, Raid, Scenario)
	hooksecurefunc('LFGRewardsFrame_SetItemButton', SkinItemButton)

	_G.LFGInvitePopup:StripTextures()
	_G.LFGInvitePopup:SetTemplate('Transparent')
	S:HandleButton(_G.LFGInvitePopupAcceptButton)
	S:HandleButton(_G.LFGInvitePopupDeclineButton)

	S:HandleButton(_G[_G.LFDQueueFrame.PartyBackfill:GetName()..'BackfillButton'])
	S:HandleButton(_G[_G.LFDQueueFrame.PartyBackfill:GetName()..'NoBackfillButton'])
	S:HandleButton(_G[_G.RaidFinderQueueFrame.PartyBackfill:GetName()..'BackfillButton'])
	S:HandleButton(_G[_G.RaidFinderQueueFrame.PartyBackfill:GetName()..'NoBackfillButton'])
	S:HandleTrimScrollBar(_G.LFDQueueFrameSpecific.ScrollBar)

	hooksecurefunc(_G.LFDQueueFrameSpecific.ScrollBox, 'Update', LFDQueueFrameSpecificUpdate)

	local LFGListFrame = _G.LFGListFrame
	LFGListFrame.CategorySelection.Inset:StripTextures()
	S:HandleButton(LFGListFrame.CategorySelection.StartGroupButton)
	LFGListFrame.CategorySelection.StartGroupButton:ClearAllPoints()
	LFGListFrame.CategorySelection.StartGroupButton:Point('BOTTOMLEFT', -1, 3)
	LFGListFrame.CategorySelection.StartGroupButton.RightSeparator:StripTextures()
	S:HandleButton(LFGListFrame.CategorySelection.FindGroupButton)
	LFGListFrame.CategorySelection.FindGroupButton:ClearAllPoints()
	LFGListFrame.CategorySelection.FindGroupButton:Point('BOTTOMRIGHT', -6, 3)
	LFGListFrame.CategorySelection.FindGroupButton.LeftSeparator:StripTextures()

	local EntryCreation = LFGListFrame.EntryCreation
	EntryCreation.Inset:StripTextures()
	S:HandleButton(EntryCreation.CancelButton)
	S:HandleButton(EntryCreation.ListGroupButton)
	EntryCreation.CancelButton:ClearAllPoints()
	EntryCreation.CancelButton:Point('BOTTOMLEFT', -1, 3)
	EntryCreation.ListGroupButton:ClearAllPoints()
	EntryCreation.ListGroupButton:Point('BOTTOMRIGHT', -6, 3)
	S:HandleEditBox(EntryCreation.Description)

	S:HandleDropDownBox(EntryCreation.GroupDropdown)
	S:HandleDropDownBox(EntryCreation.ActivityDropdown, 120)
	S:HandleDropDownBox(EntryCreation.PlayStyleDropdown)

	S:HandleEditBox(EntryCreation.ItemLevel.EditBox)
	S:HandleEditBox(EntryCreation.MythicPlusRating.EditBox)
	S:HandleEditBox(EntryCreation.PVPRating.EditBox)
	S:HandleEditBox(EntryCreation.PvpItemLevel.EditBox)
	S:HandleEditBox(EntryCreation.VoiceChat.EditBox)
	S:HandleEditBox(EntryCreation.Name)

	S:HandleCheckBox(EntryCreation.ItemLevel.CheckButton)
	S:HandleCheckBox(EntryCreation.MythicPlusRating.CheckButton)
	S:HandleCheckBox(EntryCreation.PrivateGroup.CheckButton)
	S:HandleCheckBox(EntryCreation.PvpItemLevel.CheckButton)
	S:HandleCheckBox(EntryCreation.PVPRating.CheckButton)
	S:HandleCheckBox(EntryCreation.VoiceChat.CheckButton)
	S:HandleCheckBox(EntryCreation.CrossFactionGroup.CheckButton)

	EntryCreation.ActivityFinder.Dialog:StripTextures()
	EntryCreation.ActivityFinder.Dialog:SetTemplate('Transparent')
	EntryCreation.ActivityFinder.Dialog.BorderFrame:StripTextures()
	EntryCreation.ActivityFinder.Dialog.BorderFrame:SetTemplate('Transparent')

	S:HandleEditBox(EntryCreation.ActivityFinder.Dialog.EntryBox)
	S:HandleButton(EntryCreation.ActivityFinder.Dialog.SelectButton)
	S:HandleButton(EntryCreation.ActivityFinder.Dialog.CancelButton)

	_G.LFGListApplicationDialog:StripTextures()
	_G.LFGListApplicationDialog:SetTemplate('Transparent')
	S:HandleButton(_G.LFGListApplicationDialog.SignUpButton)
	S:HandleButton(_G.LFGListApplicationDialog.CancelButton)
	S:HandleEditBox(_G.LFGListApplicationDialogDescription)

	_G.LFGListInviteDialog:StripTextures()
	_G.LFGListInviteDialog:SetTemplate('Transparent')
	S:HandleButton(_G.LFGListInviteDialog.AcknowledgeButton)
	S:HandleButton(_G.LFGListInviteDialog.AcceptButton)
	S:HandleButton(_G.LFGListInviteDialog.DeclineButton)

	S:HandleEditBox(LFGListFrame.SearchPanel.SearchBox)
	S:HandleButton(LFGListFrame.SearchPanel.BackButton)
	S:HandleButton(LFGListFrame.SearchPanel.SignUpButton)

	S:OverlayButton(LFGListFrame.SearchPanel.ScrollBox.StartGroupButton, 'StartGroupButton', 135, 22, _G.START_A_GROUP, nil, nil, 'HIGH')

	LFGListFrame.SearchPanel.BackButton:ClearAllPoints()
	LFGListFrame.SearchPanel.BackButton:Point('BOTTOMLEFT', -1, 3)
	LFGListFrame.SearchPanel.BackButton.RightSeparator:StripTextures()
	LFGListFrame.SearchPanel.SignUpButton:ClearAllPoints()
	LFGListFrame.SearchPanel.SignUpButton:Point('BOTTOMRIGHT', -6, 3)
	LFGListFrame.SearchPanel.SignUpButton.LeftSeparator:StripTextures()
	LFGListFrame.SearchPanel.ResultsInset:StripTextures()
	S:HandleTrimScrollBar(LFGListFrame.SearchPanel.ScrollBar)

	S:HandleButton(LFGListFrame.SearchPanel.FilterButton)
	LFGListFrame.SearchPanel.FilterButton:Point('LEFT', LFGListFrame.SearchPanel.SearchBox, 'RIGHT', 5, 0)
	S:HandleButton(LFGListFrame.SearchPanel.RefreshButton)
	S:HandleButton(LFGListFrame.SearchPanel.BackToGroupButton)
	LFGListFrame.SearchPanel.RefreshButton:Size(24)
	LFGListFrame.SearchPanel.RefreshButton.Icon:Point('CENTER')
	S:HandleCloseButton(LFGListFrame.SearchPanel.FilterButton.ResetButton)

	hooksecurefunc('LFGListApplicationViewer_UpdateApplicant', function(button)
		if not button.DeclineButton.template then
			S:HandleButton(button.DeclineButton, nil, true)
		end
		if not button.InviteButton.template then
			S:HandleButton(button.InviteButton)
		end
		if not button.InviteButtonSmall.template then
			S:HandleButton(button.InviteButtonSmall)
		end
	end)

	hooksecurefunc('LFGListSearchEntry_Update', function(button)
		if not button.CancelButton.template then
			S:HandleButton(button.CancelButton, nil, true)
		end
	end)

	hooksecurefunc('LFGListSearchPanel_UpdateAutoComplete', function(panel)
		for _, child in next, { LFGListFrame.SearchPanel.AutoCompleteFrame:GetChildren() } do
			if not child.IsSkinned and child:IsObjectType('Button') then
				S:HandleButton(child)
				child.IsSkinned = true
			end
		end

		local text = panel.SearchBox:GetText()
		local matchingActivities = C_LFGList_GetAvailableActivities(panel.categoryID, nil, panel.filters, text)
		local numResults = min(#matchingActivities, _G.MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES)

		for i = 2, numResults do
			local button = panel.AutoCompleteFrame.Results[i]
			if button and not button.moved then
				button:Point('TOPLEFT', panel.AutoCompleteFrame.Results[i-1], 'BOTTOMLEFT', 0, -2)
				button:Point('TOPRIGHT', panel.AutoCompleteFrame.Results[i-1], 'BOTTOMRIGHT', 0, -2)
				button.moved = true
			end
		end

		panel.AutoCompleteFrame:Height(numResults * (panel.AutoCompleteFrame.Results[1]:GetHeight() + 3.5) + 8)
	end)

	LFGListFrame.SearchPanel.AutoCompleteFrame:StripTextures()
	LFGListFrame.SearchPanel.AutoCompleteFrame:CreateBackdrop('Transparent')
	LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:Point('TOPLEFT', LFGListFrame.SearchPanel.AutoCompleteFrame, 'TOPLEFT', 0, 3)
	LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:Point('BOTTOMRIGHT', LFGListFrame.SearchPanel.AutoCompleteFrame, 'BOTTOMRIGHT', 6, 3)

	LFGListFrame.SearchPanel.AutoCompleteFrame:Point('TOPLEFT', LFGListFrame.SearchPanel.SearchBox, 'BOTTOMLEFT', -2, -8)
	LFGListFrame.SearchPanel.AutoCompleteFrame:Point('TOPRIGHT', LFGListFrame.SearchPanel.SearchBox, 'BOTTOMRIGHT', -4, -8)

	-- ApplicationViewer (Custom Groups)
	LFGListFrame.ApplicationViewer.InfoBackground:Hide() -- even the ugly borders are now an atlas on the texutre? wtf????
	LFGListFrame.ApplicationViewer.InfoBackground:CreateBackdrop('Transparent')
	LFGListFrame.ApplicationViewer.EntryName:FontTemplate()
	S:HandleCheckBox(LFGListFrame.ApplicationViewer.AutoAcceptButton)

	LFGListFrame.ApplicationViewer.Inset:StripTextures()
	LFGListFrame.ApplicationViewer.Inset:SetTemplate('Transparent')

	S:HandleButton(LFGListFrame.ApplicationViewer.NameColumnHeader)
	S:HandleButton(LFGListFrame.ApplicationViewer.RoleColumnHeader)
	S:HandleButton(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader)
	S:HandleButton(LFGListFrame.ApplicationViewer.RatingColumnHeader)
	LFGListFrame.ApplicationViewer.NameColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.NameColumnHeader:Point('BOTTOMLEFT', LFGListFrame.ApplicationViewer.Inset, 'TOPLEFT', 0, 1)
	LFGListFrame.ApplicationViewer.NameColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.RoleColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RoleColumnHeader:Point('LEFT', LFGListFrame.ApplicationViewer.NameColumnHeader, 'RIGHT', 1, 0)
	LFGListFrame.ApplicationViewer.RoleColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:Point('LEFT', LFGListFrame.ApplicationViewer.RoleColumnHeader, 'RIGHT', 1, 0)
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.RatingColumnHeader:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RatingColumnHeader:Point('LEFT', LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, 'RIGHT', 1, 0)
	LFGListFrame.ApplicationViewer.RatingColumnHeader.Label:FontTemplate()
	LFGListFrame.ApplicationViewer.PrivateGroup:FontTemplate()

	S:HandleButton(LFGListFrame.ApplicationViewer.RefreshButton)
	LFGListFrame.ApplicationViewer.RefreshButton:Size(24)
	LFGListFrame.ApplicationViewer.RefreshButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.RefreshButton:Point('BOTTOMRIGHT', LFGListFrame.ApplicationViewer.Inset, 'TOPRIGHT', 16, 4)

	S:HandleButton(LFGListFrame.ApplicationViewer.RemoveEntryButton)
	S:HandleButton(LFGListFrame.ApplicationViewer.EditButton)
	S:HandleButton(LFGListFrame.ApplicationViewer.BrowseGroupsButton)
	LFGListFrame.ApplicationViewer.EditButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.EditButton:Point('BOTTOMRIGHT', -6, 3)
	LFGListFrame.ApplicationViewer.BrowseGroupsButton:ClearAllPoints()
	LFGListFrame.ApplicationViewer.BrowseGroupsButton:Point('BOTTOMLEFT', -1, 3)
	LFGListFrame.ApplicationViewer.BrowseGroupsButton:Size(120, 22)

	S:HandleTrimScrollBar(LFGListFrame.ApplicationViewer.ScrollBar)

	hooksecurefunc('LFGListApplicationViewer_UpdateInfo', function(frame)
		frame.RemoveEntryButton:ClearAllPoints()

		if UnitIsGroupLeader('player', LE_PARTY_CATEGORY_HOME) then
			frame.RemoveEntryButton:Point('RIGHT', frame.EditButton, 'LEFT', -2, 0)
		else
			frame.RemoveEntryButton:Point('BOTTOMLEFT', -1, 3)
		end
	end)

	hooksecurefunc('LFGListCategorySelection_AddButton', function(btn, btnIndex, categoryID, filters)
		local button = btn.CategoryButtons[btnIndex]
		if button then
			if not button.IsSkinned then
				button:SetTemplate()
				button.Icon:SetDrawLayer('BACKGROUND', 2)
				button.Icon:SetTexCoord(unpack(E.TexCoords))
				button.Icon:SetInside()
				button.Cover:Hide()
				button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
				button.HighlightTexture:SetInside()

				-- Fix issue with labels not following changes to GameFontNormal as they should
				button.Label:SetFontObject('GameFontNormal')
				button.IsSkinned = true
			end

			button.SelectedTexture:Hide()
			local selected = btn.selectedCategory == categoryID and btn.selectedFilters == filters
			if selected then
				button:SetBackdropBorderColor(1, 1, 0)
			else
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)
end

function S:Blizzard_ChallengesUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	_G.ChallengesFrameInset:StripTextures(true)

	local DetailsFrame = _G.ChallengesFrameDetails
	local _, a, _, _, _, _, _, _, b, c, d = DetailsFrame:GetRegions()
	a:Hide() b:Hide() c:Hide() d:Hide()
	DetailsFrame.bg:Hide()

	DetailsFrame.MapName:ClearAllPoints()
	DetailsFrame.MapName:Point('TOP', 0, -20)

	local ChallengesFrame = _G.ChallengesFrame
	for i = 1, 9 do
		local button = ChallengesFrame['button'..i]
		if button then
			button:CreateBackdrop('Transparent')

			if i == 1 then
				button:Point('TOPLEFT', ChallengesFrame, 6, -40)
			else
				button:Point('TOP', ChallengesFrame['button'..i - 1], 'BOTTOM', 0, -8)
			end

			button.selectedTex:SetTexture(E.Media.Textures.Highlight)
			button.selectedTex:SetVertexColor(0, 0.7, 1, 0.35)
			button.selectedTex:SetAllPoints()

			local highlight = button:GetHighlightTexture()
			if highlight then
				highlight:SetTexture(E.Media.Textures.Highlight)
				highlight:SetVertexColor(1, 1, 1, 0.35)
				highlight:SetAllPoints()
			end
		end
	end

	for i = 1, 3 do
		local rewardsRow = _G.ChallengesFrame['RewardRow'..i]

		rewardsRow.Bg:SetTexture(E.Media.Textures.Highlight)

		if i == 1 then
			rewardsRow.Bg:SetVertexColor(0.859, 0.545, 0.204, 0.3)
		elseif i == 2 then
			rewardsRow.Bg:SetVertexColor(0.780, 0.722, 0.741, 0.3)
		else
			rewardsRow.Bg:SetVertexColor(0.945, 0.882, 0.337, 0.3)
		end

		for j = 1, 2 do
			local button = rewardsRow['Reward'..j]

			button:CreateBackdrop()

			button.Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end
end

S:AddCallback('LookingForGroupFrames')
S:AddCallbackForAddon('Blizzard_ChallengesUI')
