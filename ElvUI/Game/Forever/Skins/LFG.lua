local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

-- /run GroupFinderVanillaStyle_LoadUI() _G.LFGParentFrame:Show()

local function InitActivityCheckButton(button)
	local checkButton = button.CheckButton
	if checkButton.IsSkinned then return end

	-- Blizzard sets them again on refresh
	local checked = checkButton:GetCheckedTexture():GetTexture()
	local disabled = checkButton:GetDisabledCheckedTexture():GetTexture()

	S:HandleCheckBox(checkButton, nil, true)
	checkButton:Size(28)

	checkButton:SetCheckedTexture(checked)
	checkButton:SetDisabledCheckedTexture(disabled)
end

local function InitActivityGroupButton(button)
	S:HandleCollapseTexture(button.ExpandOrCollapseButton)
	InitActivityCheckButton(button)
end

local function CategorySelectionAddButton(frame, btnIndex)
	local button = frame.CategoryButtons[btnIndex]
	if not button or button.IsSkinned then return end -- nil when the category has no activities

	button:SetTemplate()
	button:SetPushedTexture(E.ClearTexture)
	button.Icon:SetDrawLayer('BACKGROUND', 2)
	button.Icon:SetTexCoords()
	button.Icon:SetInside()
	button.Cover:SetAlpha(0)
	button.HighlightTexture:SetColorTexture(1, 1, 1, .1)

	button.IsSkinned = true
end

-- Who List rows (LFGWhoListButtonTemplate)
local function HandleWhoButton(button)
	if button.IsSkinned then return end

	button.Background:SetAlpha(0)
	button:CreateBackdrop('Transparent')
	button.backdrop:SetInside(button, 0, 1)

	local r, g, b = unpack(E.media.rgbvaluecolor)
	button.Selected:SetColorTexture(r, g, b, .25)
	button.Selected:SetInside(button.backdrop)

	local highlight = button:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetInside(button.backdrop)

	S:HandleButton(button.InviteButton)

	button.IsSkinned = true
end

local function LFGWhoList_Update(frame)
	frame:ForEachFrame(HandleWhoButton)
end

-- Browse rows (LFGBrowseSearchEntryTemplate, LFGBrowseNestedSearchEntryTemplate, LFGBrowseSearchEntryGroupingTemplate)
local function HandleBrowseButton(button)
	if button.IsSkinned then return end

	local background = button.ResultBG
	background:SetAlpha(0)

	button:CreateBackdrop('Transparent')
	button.backdrop:SetAllPoints(background)

	local highlight = button.Highlight
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetInside(button.backdrop)

	local selected = button.Selected -- grouping headers have no Selected or DataDisplay
	if selected then
		local r, g, b = unpack(E.media.rgbvaluecolor)
		selected:SetColorTexture(r, g, b, .25)
		selected:SetInside(button.backdrop)

		S:HandleButton(button.DataDisplay.DelistButton)
	end

	button.IsSkinned = true
end

local function LFGBrowse_Update(frame)
	frame:ForEachFrame(HandleBrowseButton)
end

function S:Blizzard_GroupFinder_VanillaStyle()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.LFGBrowseSearchEntryTooltip)
	end

	local LFGParentFrame = _G.LFGParentFrame
	S:HandleCloseButton(_G.LFGParentFrameCloseButton)
	_G.LFGParentFramePortrait:Kill() -- Top left eye button, shows on every OnShow

	S:HandleLargeSideTab(LFGParentFrame.ListingTab)
	S:HandleLargeSideTab(LFGParentFrame.BrowsingTab)
	S:HandleLargeSideTab(LFGParentFrame.WhoListingTab)

	S:LayoutLargeSideTabs(LFGParentFrame, { LFGParentFrame.ListingTab, LFGParentFrame.BrowsingTab, LFGParentFrame.WhoListingTab })

	-- "Old" bottom tabs are hidden by LFGVANILLA_SETTING_MODERN_STYLE

	-- Listing
	local LFGListingFrame = _G.LFGListingFrame
	S:HandlePortraitFrame(LFGListingFrame)
	LFGListingFrame.RolesSection:StripTextures()
	LFGListingFrame.DividerFrame:Hide()

	S:HandleButton(LFGListingFrame.BackButton)
	S:HandleButton(LFGListingFrame.PostButton)
	S:HandleButton(LFGListingFrame.GroupRoleButtons.RolePollButton)
	S:HandleDropDownBox(LFGListingFrame.GroupRoleButtons.RoleDropdown, 180)
	local ListingComment = _G.LFGListingComment
	S:HandleEditBox(ListingComment)
	ListingComment.backdrop:Point('TOPLEFT', -6, 2)
	ListingComment.backdrop:Point('BOTTOMRIGHT', 6, -2)

	local ActivityView = LFGListingFrame.ActivityView
	S:HandleTrimScrollBar(ActivityView.ScrollBar)
	S:HandleCheckBox(ActivityView.LevelRangesCheckbox.Checkbox)
	ActivityView.BarTop:SetAlpha(0)
	ActivityView.BarMiddle:SetAlpha(0)

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
	hooksecurefunc(LFGBrowseFrame.ScrollBox, 'Update', LFGBrowse_Update)

	S:HandleButton(LFGBrowseFrame.SendMessageButton)
	S:HandleButton(LFGBrowseFrame.GroupInviteButton)
	S:HandleDropDownBox(LFGBrowseFrame.CategoryDropdown, 140)

	local ActivityDropdown = LFGBrowseFrame.ActivityDropdown
	S:HandleDropDownBox(ActivityDropdown, 180)
	S:HandleCloseButton(ActivityDropdown.ResetButton)

	local RefreshButton = LFGBrowseFrame.RefreshButton
	S:HandleButton(RefreshButton)
	RefreshButton:Size(21) -- dropdown height minus the backdrop insets
	RefreshButton:ClearAllPoints()
	RefreshButton:Point('LEFT', ActivityDropdown.backdrop, 'RIGHT', 3, 0)
	RefreshButton.Icon:Point('CENTER')

	LFGBrowseFrame.OptionsButton:ClearAllPoints()
	LFGBrowseFrame.OptionsButton:Point('LEFT', RefreshButton, 'RIGHT', 4, 0)

	-- Who List
	local LFGWhoListFrame = _G.LFGWhoListFrame
	S:HandlePortraitFrame(LFGWhoListFrame)
	S:HandleTrimScrollBar(LFGWhoListFrame.ScrollBar)
	hooksecurefunc(LFGWhoListFrame.ScrollBox, 'Update', LFGWhoList_Update)

	local EditBox = LFGWhoListFrame.EditBox
	EditBox:CreateBackdrop()
	EditBox.Left:SetAlpha(0)
	EditBox.Middle:SetAlpha(0)
	EditBox.Right:SetAlpha(0)

	local WhoSearch = LFGWhoListFrame.WhoSearch
	S:HandleButton(WhoSearch)
	WhoSearch:ClearAllPoints()
	WhoSearch:Point('TOPLEFT', EditBox.backdrop, 'TOPRIGHT', 1, 0)
	WhoSearch:Point('BOTTOMLEFT', EditBox.backdrop, 'BOTTOMRIGHT', 1, 0)
	WhoSearch:Width(36)

	local FilterDropdown = LFGWhoListFrame.FilterDropdown
	S:HandleButton(FilterDropdown)

	local ResetButton = FilterDropdown.ResetButton
	S:HandleCloseButton(ResetButton)
	ResetButton:ClearAllPoints()
	ResetButton:Point('CENTER', FilterDropdown, 'TOPRIGHT', 0, 0)
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
