local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function LFGTabs()
	_G.LFGParentFrameTab1:ClearAllPoints()
	_G.LFGParentFrameTab1:Point('TOPLEFT', _G.LFGParentFrame, 'BOTTOMLEFT', 1, 72)

	_G.LFGParentFrameTab2:ClearAllPoints()
	_G.LFGParentFrameTab2:Point('LEFT', _G.LFGParentFrameTab1, 'RIGHT', -19, 0)
end

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
	local button = frame.CategoryButtons[btnIndex] -- nil when the category has no activities
	if not button or button.IsSkinned then return end

	button:SetTemplate()
	button.Icon:SetDrawLayer('BACKGROUND', 2)
	button.Icon:SetTexCoords()
	button.Icon:SetInside()
	button.Cover:Hide()
	button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
	button.HighlightTexture:SetInside()

	-- Fix issue with labels not following changes to GameFontNormal as they should
	button.Label:SetFontObject('GameFontNormal')
	button.IsSkinned = true
end

function S:Blizzard_GroupFinder_VanillaStyle()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	-- Main Frame and both Tabs
	_G.LFGParentFramePortrait:Kill()
	_G.LFGListingFrameActivityViewBarLeft:StripTextures()
	_G.LFGListingFrameActivityViewBarMiddle:StripTextures()
	_G.LFGListingFrameActivityViewBarRight:StripTextures()
	-- S:HandleTrimScrollBar(_G.LFGListingFrameActivityViewScrollBar) -- confirmed to taint

	local LFGListingFrame = _G.LFGListingFrame
	S:HandleFrame(LFGListingFrame, true, nil, 11, -12, -30, 72)
	LFGListingFrame:HookScript('OnShow', LFGTabs)

	local LFGBrowseFrame = _G.LFGBrowseFrame
	S:HandleTrimScrollBar(_G.LFGBrowseFrameScrollBar)
	S:HandleFrame(LFGBrowseFrame, true, nil, 11, -12, -30, 72)
	LFGBrowseFrame:HookScript('OnShow', LFGTabs)

	-- Mouseover Tooltip
	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.LFGBrowseSearchEntryTooltip)
	end

	-- Buttons
	for _, button in next, { _G.LFGListingFrameBackButton, _G.LFGListingFramePostButton, _G.LFGBrowseFrameSendMessageButton, _G.LFGBrowseFrameGroupInviteButton } do
		S:HandleButton(button)
	end

	_G.LFGListingFrameBackButton:ClearAllPoints()
	_G.LFGListingFrameBackButton:Point('TOPLEFT', _G.LFGParentFrameTab1, 'TOPLEFT', 14, 24)
	_G.LFGBrowseFrameSendMessageButton:ClearAllPoints()
	_G.LFGBrowseFrameSendMessageButton:Point('TOPLEFT', _G.LFGParentFrameTab1, 'TOPLEFT', 14, 24)

	_G.LFGListingFramePostButton:Point('BOTTOMRIGHT', LFGListingFrame, 'BOTTOMRIGHT', -40, 76)
	_G.LFGBrowseFrameGroupInviteButton:Point('BOTTOMRIGHT', LFGBrowseFrame, 'BOTTOMRIGHT', -40, 76)

	_G.LFGBrowseFrameActivityDropdown.ResetButton:ClearAllPoints()
	_G.LFGBrowseFrameActivityDropdown.ResetButton:Point('TOPRIGHT', _G.LFGBrowseFrameActivityDropdown, 'TOPRIGHT', 0, 16)

	-- CheckBoxes
	for _, roleButton in next, LFGListingFrame.SoloRoleButtons.RoleButtons do
		S:HandleCheckBox(roleButton.CheckButton, nil, nil, true)
	end

	S:HandleCheckBox(_G.LFGListingFrameNewPlayerFriendlyButton.CheckButton, nil, nil, true)
	S:HandleButton(_G.LFGListingFrameGroupRoleButtonsInitiateRolePoll)
	S:HandleEditBox(_G.LFGListingComment)

	-- DropDowns
	S:HandleDropDownBox(_G.LFGListingFrameGroupRoleButtonsRoleDropdown, 180)
	S:HandleDropDownBox(_G.LFGBrowseFrameActivityDropdown, 180)
	S:HandleDropDownBox(_G.LFGBrowseFrameCategoryDropdown, 140)

	_G.LFGBrowseFrameCategoryDropdown:ClearAllPoints()
	_G.LFGBrowseFrameCategoryDropdown:Point('TOPLEFT', _G.LFGParentFrame, 'TOPLEFT', 22, -90)
	_G.LFGBrowseFrameActivityDropdown:ClearAllPoints()
	_G.LFGBrowseFrameActivityDropdown:Point('LEFT', _G.LFGBrowseFrameCategoryDropdown, 'RIGHT', 4, 0)

	-- Refresh
	S:HandleButton(_G.LFGBrowseFrameRefreshButton)
	_G.LFGBrowseFrameRefreshButton:Size(22, 22)
	_G.LFGBrowseFrameRefreshButton:ClearAllPoints()
	_G.LFGBrowseFrameRefreshButton:Point('BOTTOM', _G.LFGBrowseFrame.backdrop.Center, 'BOTTOM', 0, 4)

	S:HandleTab(_G.LFGParentFrameTab1)
	S:HandleTab(_G.LFGParentFrameTab2)

	local closeButton = _G.LFGParentFrame:GetChildren() -- unnamed UIPanelCloseButton
	S:HandleCloseButton(closeButton)
	closeButton:ClearAllPoints()
	closeButton:Point('TOPRIGHT', -26, -6)

	hooksecurefunc('LFGListingCategorySelection_AddButton', CategorySelectionAddButton)
	hooksecurefunc('LFGListingActivityView_InitActivityButton', InitActivityCheckButton)
	hooksecurefunc('LFGListingActivityView_InitActivityGroupButton', InitActivityGroupButton)
end

function S:RolePollPopup()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	S:HandleFrame(_G.RolePollPopup)
	S:HandleButton(_G.RolePollPopupAcceptButton)

	for _, roleButton in next, { _G.RolePollPopupRoleButtonTank, _G.RolePollPopupRoleButtonHealer, _G.RolePollPopupRoleButtonDPS } do
		local checkButton = roleButton.checkButton
		S:HandleCheckBox(checkButton, nil, nil, true)
		checkButton.backdrop:SetInside()
		checkButton:Size(18)
	end
end

S:AddCallbackForAddon('Blizzard_GroupFinder_VanillaStyle')
S:AddCallback('RolePollPopup')
