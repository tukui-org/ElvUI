local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LCG = E.Libs.CustomGlow

local _G = _G
local min, next, select = min, next, select
local unpack, ipairs, pairs = unpack, ipairs, pairs
local hooksecurefunc = hooksecurefunc

local UnitIsGroupLeader = UnitIsGroupLeader
local GetItemInfo = C_Item.GetItemInfo

local C_ChallengeMode_GetAffixInfo = C_ChallengeMode.GetAffixInfo
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local C_ChallengeMode_GetSlottedKeystoneInfo = C_ChallengeMode.GetSlottedKeystoneInfo
local C_LFGList_GetAvailableActivities = C_LFGList.GetAvailableActivities
local C_LFGList_GetAvailableRoles = C_LFGList.GetAvailableRoles
local C_MythicPlus_GetCurrentAffixes = C_MythicPlus.GetCurrentAffixes

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

local function HandleAffixIcons(self)
	local MapID, _, PowerLevel = C_ChallengeMode_GetSlottedKeystoneInfo()

	if MapID then
		local Name = C_ChallengeMode_GetMapUIInfo(MapID)

		if Name and PowerLevel then
			self.DungeonName:SetText(Name.. ' |cffffffff-|r (' .. PowerLevel .. ')')
		end

		self.PowerLevel:SetText('')
	end

	local list = self.AffixesContainer and self.AffixesContainer.Affixes or self.Affixes
	if not list then return end

	for _, frame in ipairs(list) do
		frame.Border:SetTexture()
		frame.Portrait:SetTexture()

		if frame.info then
			frame.Portrait:SetTexture(_G.CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
		elseif frame.affixID then
			local _, _, filedataid = C_ChallengeMode_GetAffixInfo(frame.affixID)
			frame.Portrait:SetTexture(filedataid)
		end

		S:HandleIcon(frame.Portrait, true)

		frame.Percent:FontTemplate(E.media.normFont, 16, 'OUTLINE')
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

	-- Brawl & Solo Shuffle
	_G.ReadyStatus:StripTextures()
	_G.ReadyStatus:SetTemplate('Transparent')
	S:HandleCloseButton(_G.ReadyStatus.CloseButton)

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

	for i = 1, 4 do
		S:HandleTab(_G['PVEFrameTab'..i])
	end

	-- Reposition Tabs
	_G.PVEFrameTab1:ClearAllPoints()
	_G.PVEFrameTab2:ClearAllPoints()
	_G.PVEFrameTab3:ClearAllPoints()
	_G.PVEFrameTab1:Point('BOTTOMLEFT', PVEFrame, 'BOTTOMLEFT', -3, -32)
	_G.PVEFrameTab2:Point('TOPLEFT', _G.PVEFrameTab1, 'TOPRIGHT', -5, 0)
	_G.PVEFrameTab3:Point('TOPLEFT', _G.PVEFrameTab2, 'TOPRIGHT', -5, 0)

	hooksecurefunc('PVEFrame_ShowFrame', function()
		if not _G.PVEFrameTab4:IsShown() then return end

		local twoShown = _G.PVEFrameTab2:IsShown()
		local threeShown = _G.PVEFrameTab3:IsShown()

		_G.PVEFrameTab4:ClearAllPoints()
		_G.PVEFrameTab4:SetPoint('TOPLEFT', (twoShown and threeShown and _G.PVEFrameTab3) or (twoShown and not threeShown and _G.PVEFrameTab2) or _G.PVEFrameTab1, 'TOPRIGHT', -5, 0)
	end)

	-- Scenario Tab [[New in 10.2.7]]
	local ScenarioQueueFrame = _G.ScenarioQueueFrame
	if ScenarioQueueFrame then
		ScenarioQueueFrame:StripTextures()
		_G.ScenarioFinderFrameInset:StripTextures()
		_G.ScenarioQueueFrameBackground:SetAlpha(0)
		S:HandleTrimScrollBar(_G.ScenarioQueueFrameRandomScrollFrame.ScrollBar)
		S:HandleButton(_G.ScenarioQueueFrameFindGroupButton)

		_G.ScenarioQueueFrameSpecificScrollFrame:StripTextures()

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
	S:HandleButton(LFGListFrame.CategorySelection.FindGroupButton)
	LFGListFrame.CategorySelection.FindGroupButton:ClearAllPoints()
	LFGListFrame.CategorySelection.FindGroupButton:Point('BOTTOMRIGHT', -6, 3)

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
	LFGListFrame.SearchPanel.SignUpButton:ClearAllPoints()
	LFGListFrame.SearchPanel.SignUpButton:Point('BOTTOMRIGHT', -6, 3)
	LFGListFrame.SearchPanel.ResultsInset:StripTextures()
	S:HandleTrimScrollBar(LFGListFrame.SearchPanel.ScrollBar)

	S:HandleButton(LFGListFrame.SearchPanel.FilterButton)
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

	-- Follower Dungeons
	hooksecurefunc(_G.LFDQueueFrameFollower.ScrollBox, 'Update', LFDQueueFrameSpecificUpdate)
end

function S:Blizzard_ChallengesUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	local ChallengesFrame = _G.ChallengesFrame
	ChallengesFrame:DisableDrawLayer('BACKGROUND')
	_G.ChallengesFrameInset:StripTextures()

	-- Mythic+ KeyStoneFrame
	local KeyStoneFrame = _G.ChallengesKeystoneFrame
	KeyStoneFrame:SetTemplate('Transparent')
	KeyStoneFrame.DungeonName:FontTemplate(E.media.normFont, 26, 'OUTLINE')
	KeyStoneFrame.TimeLimit:FontTemplate(E.media.normFont, 20, 'OUTLINE')

	S:HandleButton(KeyStoneFrame.StartButton)
	S:HandleCloseButton(KeyStoneFrame.CloseButton)
	S:HandleIcon(KeyStoneFrame.KeystoneSlot.Texture, true)

	KeyStoneFrame.KeystoneSlot:HookScript('OnEvent', function(frame, event, itemID)
		if event == 'CHALLENGE_MODE_KEYSTONE_SLOTTED' and frame.Texture then
			local texture = select(10, GetItemInfo(itemID))
			if texture then
				frame.Texture:SetTexture(texture)
			end
		end
	end)

	hooksecurefunc(KeyStoneFrame, 'OnKeystoneSlotted', HandleAffixIcons)

	hooksecurefunc(ChallengesFrame, 'Update', function(frame)
		for _, child in ipairs(frame.DungeonIcons) do
			if not child.template then
				child:GetRegions():SetAlpha(0)
				child:SetTemplate()
				child.Icon:SetInside()
				S:HandleIcon(child.Icon)
			end

			child.Center:SetDrawLayer('BACKGROUND', -1)
		end
	end)

	hooksecurefunc(_G.ChallengesFrameWeeklyInfoMixin, 'SetUp', function(info)
		if C_MythicPlus_GetCurrentAffixes() then
			HandleAffixIcons(info.Child)
		end
	end)

	hooksecurefunc(KeyStoneFrame, 'Reset', function(frame)
		frame:GetRegions():SetAlpha(0)
		frame.InstructionBackground:SetAlpha(0)
		frame.KeystoneSlotGlow:Hide()
		frame.SlotBG:Hide()
		frame.KeystoneFrame:Hide()
		frame.Divider:Hide()
	end)

	-- New Season Frame
	local NoticeFrame = _G.ChallengesFrame.SeasonChangeNoticeFrame
	S:HandleButton(NoticeFrame.Leave)
	NoticeFrame:StripTextures()
	NoticeFrame:SetTemplate()
	NoticeFrame.Center:SetInside()
	NoticeFrame.Center:SetDrawLayer('ARTWORK', 2)
	NoticeFrame.NewSeason:SetTextColor(1, .8, 0)
	NoticeFrame.NewSeason:SetShadowOffset(1, -1)
	NoticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
	NoticeFrame.SeasonDescription:SetShadowOffset(1, -1)
	NoticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
	NoticeFrame.SeasonDescription2:SetShadowOffset(1, -1)
	NoticeFrame.SeasonDescription3:SetTextColor(1, .8, 0)
	NoticeFrame.SeasonDescription3:SetShadowOffset(1, -1)

	local affix = NoticeFrame.Affix
	affix.AffixBorder:Hide()
	affix.Portrait:SetTexCoord(unpack(E.TexCoords))

	hooksecurefunc(affix, 'SetUp', function(_, affixID)
		local _, _, texture = C_ChallengeMode_GetAffixInfo(affixID)
		if texture then
			affix.Portrait:SetTexture(texture)
		end
	end)
end

S:AddCallback('LookingForGroupFrames')
S:AddCallbackForAddon('Blizzard_ChallengesUI')
