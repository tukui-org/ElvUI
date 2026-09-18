local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

-- /run GroupFinderVanillaStyle_LoadUI() _G.LFGParentFrame:Show()

local function InitActivityCheckButton(button)
	local checkButton = button.CheckButton
	if checkButton.IsSkinned then return end

	-- Blizzard sets them again on refresh
	local checked = checkButton:GetCheckedTexture():GetTexture()
	local disabled = checkButton:GetDisabledCheckedTexture():GetTexture()

	S:HandleCheckBox(checkButton, nil, true)

	checkButton:SetCheckedTexture(checked)
	checkButton:SetDisabledCheckedTexture(disabled)
end

local function InitActivityGroupButton(button)
	S:HandleCollapseTexture(button.ExpandOrCollapseButton)
	InitActivityCheckButton(button)
end

local function CategorySelectionAddButton(frame, btnIndex)
	local button = frame.CategoryButtons[btnIndex]
	if not button or button.IsSkinned then return end

	button:SetTemplate()
	button.Icon:SetDrawLayer('BACKGROUND', 2)
	button.Icon:SetTexCoords()
	button.Icon:SetInside()
	button.Cover:Hide()
	button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
	button.HighlightTexture:SetInside()

	button.IsSkinned = true
end

function S:Blizzard_GroupFinder_VanillaStyle()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	local LFGParentFrame = _G.LFGParentFrame
	S:HandleCloseButton(_G.LFGParentFrameCloseButton)

	S:HandleLargeSideTab(LFGParentFrame.ListingTab)
	S:HandleLargeSideTab(LFGParentFrame.BrowsingTab)
	S:HandleLargeSideTab(LFGParentFrame.WhoListingTab)

	S:LayoutLargeSideTabs(LFGParentFrame, { LFGParentFrame.ListingTab, LFGParentFrame.BrowsingTab, LFGParentFrame.WhoListingTab })

	-- "Old" bottom tabs are hidden by LFGVANILLA_SETTING_MODERN_STYLE

	-- Listing
	local LFGListingFrame = _G.LFGListingFrame
	S:HandlePortraitFrame(LFGListingFrame)
	LFGListingFrame.RolesSection:StripTextures()

	S:HandleButton(LFGListingFrame.BackButton)
	S:HandleButton(LFGListingFrame.PostButton)
	S:HandleButton(LFGListingFrame.GroupRoleButtons.RolePollButton)
	S:HandleDropDownBox(LFGListingFrame.GroupRoleButtons.RoleDropdown, 180)
	S:HandleEditBox(_G.LFGListingComment)
	S:HandleTrimScrollBar(LFGListingFrame.ActivityView.ScrollBar)

	for _, roleButton in next, LFGListingFrame.SoloRoleButtons.RoleButtons do
		S:HandleCheckBox(roleButton.CheckButton, nil, nil, true)
	end

	S:HandleCheckBox(LFGListingFrame.NewPlayerFriendlyButton.CheckButton, nil, nil, true)

	hooksecurefunc('LFGListingCategorySelection_AddButton', CategorySelectionAddButton)
	hooksecurefunc('LFGListingActivityView_InitActivityButton', InitActivityCheckButton)
	hooksecurefunc('LFGListingActivityView_InitActivityGroupButton', InitActivityGroupButton)

	-- Browse
	local LFGBrowseFrame = _G.LFGBrowseFrame
	S:HandlePortraitFrame(LFGBrowseFrame)
	S:HandleTrimScrollBar(LFGBrowseFrame.ScrollBar)

	S:HandleButton(LFGBrowseFrame.SendMessageButton)
	S:HandleButton(LFGBrowseFrame.GroupInviteButton)
	S:HandleButton(LFGBrowseFrame.RefreshButton)
	S:HandleDropDownBox(LFGBrowseFrame.CategoryDropdown, 140)
	S:HandleDropDownBox(LFGBrowseFrame.ActivityDropdown, 180)
	S:HandleCloseButton(LFGBrowseFrame.ActivityDropdown.ResetButton)

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.LFGBrowseSearchEntryTooltip)
	end

	-- Who List
	-- ToDo: classic_beta
	-- LFGWhoListButtonTemplate rows: Background, Selected, HighlightTexture (common-button-list-large atlases)
	local LFGWhoListFrame = _G.LFGWhoListFrame
	S:HandlePortraitFrame(LFGWhoListFrame)
	S:HandleTrimScrollBar(LFGWhoListFrame.ScrollBar)
	S:HandleButton(LFGWhoListFrame.WhoSearch)

	LFGWhoListFrame.EditBox.Backdrop:StripTextures()
	LFGWhoListFrame.EditBox.Backdrop:CreateBackdrop()
end

function S:RolePollPopup()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	S:HandleFrame(_G.RolePollPopup)
	S:HandleButton(_G.RolePollPopupAcceptButton)
	S:HandleCloseButton(_G.RolePollPopupCloseButton)

	for _, roleButton in next, { _G.RolePollPopupRoleButtonTank, _G.RolePollPopupRoleButtonHealer, _G.RolePollPopupRoleButtonDPS } do
		local checkButton = roleButton.checkButton
		S:HandleCheckBox(checkButton, nil, nil, true)
		checkButton.backdrop:SetInside()
		checkButton:Size(18)
	end
end

S:AddCallbackForAddon('Blizzard_GroupFinder_VanillaStyle')
S:AddCallback('RolePollPopup')
