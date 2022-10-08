local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local pairs, select = pairs, select
local hooksecurefunc = hooksecurefunc

local function LFGTabs()
	_G.LFGParentFrameTab1:ClearAllPoints()
	_G.LFGParentFrameTab1:Point('TOPLEFT', _G.LFGParentFrame, 'BOTTOMLEFT', 4, 74)
	_G.LFGParentFrameTab2:ClearAllPoints()
	_G.LFGParentFrameTab2:Point('LEFT', _G.LFGParentFrameTab1, 'RIGHT', -14, 0)
end

function S:Blizzard_LookingForGroupUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	-- Main Frame and both Tabs
	_G.LFGParentFramePortrait:Kill()
	_G.LFGListingFrameActivityViewBarLeft:StripTextures()
	_G.LFGListingFrameActivityViewBarMiddle:StripTextures()
	_G.LFGListingFrameActivityViewBarRight:StripTextures()

	local LFGListingFrame = _G.LFGListingFrame
	S:HandleFrame(LFGListingFrame, true, nil, 11, -12, -30, 72)
	LFGListingFrame:HookScript('OnShow', LFGTabs)

	local LFGBrowseFrame = _G.LFGBrowseFrame
	S:HandleFrame(LFGBrowseFrame, true, nil, 11, -12, -30, 72)
	LFGBrowseFrame:HookScript('OnShow', LFGTabs)

	-- Mouseover Tooltip
	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.LFGBrowseSearchEntryTooltip)
	end

	-- Buttons
	local buttons = {
		_G.LFGListingFrameBackButton,
		_G.LFGListingFramePostButton,
		_G.LFGBrowseFrameSendMessageButton,
		_G.LFGBrowseFrameGroupInviteButton
	}

	for _, button in pairs(buttons) do
		S:HandleButton(button)
	end

	_G.LFGListingFrameBackButton:ClearAllPoints()
	_G.LFGListingFrameBackButton:Point('TOPLEFT', _G.LFGParentFrameTab1, 'TOPLEFT', 14, 24)
	_G.LFGBrowseFrameSendMessageButton:ClearAllPoints()
	_G.LFGBrowseFrameSendMessageButton:Point('TOPLEFT', _G.LFGParentFrameTab1, 'TOPLEFT', 14, 24)

	_G.LFGListingFramePostButton:Point('BOTTOMRIGHT', LFGListingFrame, 'BOTTOMRIGHT', -40, 76)
	_G.LFGBrowseFrameGroupInviteButton:Point('BOTTOMRIGHT', LFGBrowseFrame, 'BOTTOMRIGHT', -40, 76)

	_G.LFGBrowseFrameActivityDropDown.ResetButton:ClearAllPoints()
	_G.LFGBrowseFrameActivityDropDown.ResetButton:Point('TOPLEFT', _G.LFGBrowseFrameActivityDropDown, 'TOPLEFT', 22, 14)

	-- CheckBoxes
	local checkBoxes = {
		_G.LFGListingFrameSoloRoleButtonsRoleButtonTank.CheckButton,
		_G.LFGListingFrameSoloRoleButtonsRoleButtonHealer.CheckButton,
		_G.LFGListingFrameSoloRoleButtonsRoleButtonDPS.CheckButton,
		_G.LFGListingFrameNewPlayerFriendlyButton.CheckButton,
	}

	for _, checkbox in pairs(checkBoxes) do
		S:HandleCheckBox(checkbox, nil, nil, true)
	end

	S:HandleButton(_G.LFGListingFrameGroupRoleButtonsInitiateRolePoll)

	S:HandleEditBox(_G.LFGListingComment)

	-- DropDowns
	S:HandleDropDownBox(_G.LFGListingFrameGroupRoleButtonsRoleDropDown, 180)
	S:HandleDropDownBox(_G.LFGBrowseFrameActivityDropDown, 220)
	S:HandleDropDownBox(_G.LFGBrowseFrameCategoryDropDown, 160)

	_G.LFGBrowseFrameCategoryDropDown:ClearAllPoints()
	_G.LFGBrowseFrameCategoryDropDown:Point('TOPLEFT', _G.LFGParentFrame, 'TOPLEFT', -4, -90)
	_G.LFGBrowseFrameActivityDropDown:ClearAllPoints()
	_G.LFGBrowseFrameActivityDropDown:Point('LEFT', _G.LFGBrowseFrameCategoryDropDown, 'RIGHT', -20, 0)

	-- Refresh
	S:HandleButton(_G.LFGBrowseFrameRefreshButton)
	_G.LFGBrowseFrameRefreshButton:Size(22, 22)
	_G.LFGBrowseFrameRefreshButton:ClearAllPoints()
	_G.LFGBrowseFrameRefreshButton:Point('BOTTOM', _G.LFGBrowseFrame.backdrop.Center, 'BOTTOM', 0, 4)

	-- ScrollBars
	-- S:HandleScrollBar(_G.LFGListingFrameActivityViewScrollBar) --Breaks the Group Finder for some reason
	S:HandleScrollBar(_G.LFGBrowseFrameScrollBar)

	-- Role check popup
	S:HandleFrame(_G.RolePollPopup)
	S:HandleButton(_G.RolePollPopupAcceptButton)
	S:HandleCloseButton(_G.RolePollPopupCloseButton)

	S:HandleCheckBox(_G.RolePollPopupRoleButtonTank.checkButton)
	S:HandleCheckBox(_G.RolePollPopupRoleButtonHealer.checkButton)
	S:HandleCheckBox(_G.RolePollPopupRoleButtonDPS.checkButton)

	do
		local i = 1
		local tab = _G['LFGParentFrameTab'..i]
		while tab do
			S:HandleTab(tab)
			tab.IsSkinned = true

			i = i + 1
			tab = _G['LFGParentFrameTab'..i]
		end
	end

	for i = 1, _G.LFGParentFrame:GetNumChildren() do
		local child = select(i, _G.LFGParentFrame:GetChildren())
		if not child.IsSkinned and child:GetObjectType() == 'Button' then
			child:ClearAllPoints()
			child:Point('TOPRIGHT', -26, -6)

			S:HandleCloseButton(child)
			child.IsSkinned = true
		end
	end

	hooksecurefunc('LFGListingActivityView_InitActivityButton', function(button, elementData)
		S:HandleCheckBox(button.CheckButton, nil, true)
		button.CheckButton:SetChecked(LFGListingFrame:IsActivitySelected(elementData.activityID))
		button.CheckButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	end)

	hooksecurefunc('LFGListingActivityView_InitActivityGroupButton', function(button, _, isCollapsed)
		if isCollapsed then
			button.ExpandOrCollapseButton:SetNormalTexture(E.Media.Textures.PlusButton)
		else
			button.ExpandOrCollapseButton:SetNormalTexture(E.Media.Textures.MinusButton)
		end

		S:HandleCheckBox(button.CheckButton, nil, true)
	end)
end

S:AddCallbackForAddon('Blizzard_LookingForGroupUI')
