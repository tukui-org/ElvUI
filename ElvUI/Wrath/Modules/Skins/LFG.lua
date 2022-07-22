local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, select = pairs, select

local function LFGTabs()
	LFGParentFrameTab1:ClearAllPoints()
	LFGParentFrameTab1:Point('TOPLEFT', LFGParentFrame, 'BOTTOMLEFT', 4, 74)
	LFGParentFrameTab2:ClearAllPoints()
	LFGParentFrameTab2:Point('LEFT', LFGParentFrameTab1, 'RIGHT', -14, 0)
end

function S:Blizzard_LookingForGroupUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

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
	_G.LFGListingFrameBackButton:Point('TOPLEFT', LFGParentFrameTab1, 'TOPLEFT', 14, 24)
	_G.LFGBrowseFrameSendMessageButton:ClearAllPoints()
	_G.LFGBrowseFrameSendMessageButton:Point('TOPLEFT', LFGParentFrameTab1, 'TOPLEFT', 14, 24)

	_G.LFGListingFramePostButton:Point('BOTTOMRIGHT', LFGListingFrame, 'BOTTOMRIGHT', -40, 76)
	_G.LFGBrowseFrameGroupInviteButton:Point('BOTTOMRIGHT', LFGBrowseFrame, 'BOTTOMRIGHT', -40, 76)

	local checkBoxes = {
		_G.LFGListingFrameSoloRoleButtonsRoleButtonTank.CheckButton,
		_G.LFGListingFrameSoloRoleButtonsRoleButtonHealer.CheckButton,
		_G.LFGListingFrameSoloRoleButtonsRoleButtonDPS.CheckButton,
	}

	for _, checkbox in pairs(checkBoxes) do
		S:HandleCheckBox(checkbox, true) -- no backdrop
	end

	S:HandleEditBox(_G.LFGListingComment)

	S:HandleDropDownBox(_G.LFGBrowseFrameActivityDropDown, 220)
	S:HandleDropDownBox(_G.LFGBrowseFrameCategoryDropDown, 160)

	_G.LFGBrowseFrameCategoryDropDown:ClearAllPoints()
	_G.LFGBrowseFrameCategoryDropDown:Point('TOPLEFT', LFGParentFrame, 'TOPLEFT', -4, -90)
	_G.LFGBrowseFrameActivityDropDown:ClearAllPoints()
	_G.LFGBrowseFrameActivityDropDown:Point('LEFT', _G.LFGBrowseFrameCategoryDropDown, 'RIGHT', -20, 0)

	S:HandleButton(_G.LFGBrowseFrameRefreshButton)
	_G.LFGBrowseFrameRefreshButton:ClearAllPoints()
	_G.LFGBrowseFrameRefreshButton:Point('TOPRIGHT', _G.LFGBrowseFrameActivityDropDown, 'TOPRIGHT', -8, 32)

	S:HandleScrollBar(_G.LFGListingFrameActivityViewScrollBar)
	S:HandleScrollBar(_G.LFGBrowseFrameScrollBar)

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

	for i = 1, LFGParentFrame:GetNumChildren() do
		local child = select(i, LFGParentFrame:GetChildren())
		if not child.IsSkinned and child:GetObjectType() == 'Button' then
			child:ClearAllPoints()
			child:Point('TOPRIGHT', -26, -6)

			S:HandleCloseButton(child)
			child.IsSkinned = true
		end
	end
end

S:AddCallbackForAddon('Blizzard_LookingForGroupUI')
