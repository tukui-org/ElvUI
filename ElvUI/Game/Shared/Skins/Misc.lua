local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

S:AddCallback('BlizzardMiscFrames', nil, nil, 'misc')

local function FixAutoCompleteLevel(frame)
	local parent = frame:GetParent()
	if not parent then return end

	frame:OffsetFrameLevel(4, parent)
end

local function ClearedHooks(button, script)
	if script == 'OnEnter' then
		button:HookScript('OnEnter', S.SetModifiedBackdrop)
	elseif script == 'OnLeave' then
		button:HookScript('OnLeave', S.SetOriginalBackdrop)
	elseif script == 'OnDisable' then
		button:HookScript('OnDisable', S.SetDisabledBackdrop)
	end
end

local function GameMenuInitButtons(menu)
	for button in menu.buttonPool:EnumerateActive() do
		if not button.IsSkinned then
			S:HandleButton(button, nil, nil, nil, true)
			button.backdrop:SetInside(nil, 1, 1)
			hooksecurefunc(button, 'SetScript', ClearedHooks)
		end
	end

	if menu.ElvUI and not menu.ElvUI.IsSkinned then
		S:HandleButton(menu.ElvUI, nil, nil, nil, true)
		menu.ElvUI.backdrop:SetInside(nil, 1, 1)
	end
end

local function UpdateLettboxForAspectRatio(frame)
	frame:SetScale(E.uiscale)

	local closeDialog = frame.closeDialog
	if not closeDialog.template then
		closeDialog:StripTextures()
		closeDialog:SetTemplate('Transparent')

		local dialogName = closeDialog:GetName()
		S:HandleButton(_G[dialogName..'ConfirmButton'], nil, nil, nil, true)
		S:HandleButton(_G[dialogName..'ResumeButton'], nil, nil, nil, true)
	end
end

local function ShowCloseDialog(frame)
	frame:SetScale(E.uiscale)

	local closeDialog = frame.CloseDialog
	if not closeDialog.template then
		closeDialog:StripTextures()
		closeDialog:SetTemplate('Transparent')

		S:HandleButton(closeDialog.Buttons.ConfirmButton, nil, nil, nil, true)
		S:HandleButton(closeDialog.Buttons.ResumeButton, nil, nil, nil, true)
	end
end

function S:BlizzardMiscFrames()
	for _, frame in next, { _G.AddonCompartmentFrame, _G.AutoCompleteBox, _G.QueueStatusFrame } do
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	local ReadyCheckFrame = _G.ReadyCheckFrame
	_G.ReadyCheckFrameText:ClearAllPoints()
	_G.ReadyCheckFrameText:Point('TOP', 0, E.Modern and -30 or -15)
	_G.ReadyCheckFrameText:Width(300)

	S:HandleButton(_G.ReadyCheckFrameYesButton)
	_G.ReadyCheckFrameYesButton:ClearAllPoints()
	_G.ReadyCheckFrameYesButton:Point('TOPRIGHT', ReadyCheckFrame, 'CENTER', -3, -5)

	S:HandleButton(_G.ReadyCheckFrameNoButton)
	_G.ReadyCheckFrameNoButton:ClearAllPoints()
	_G.ReadyCheckFrameNoButton:Point('TOPLEFT', ReadyCheckFrame, 'CENTER', 3, -5)

	-- the Mainline listener frame has a title bar, the classic one is a single texture
	local ListenerFrame = _G.ReadyCheckListenerFrame
	if E.Modern then
		_G.ReadyCheckPortrait:Kill()
		S:HandleFrame(ListenerFrame)

		local TitleContainer = ListenerFrame.TitleContainer
		TitleContainer:ClearAllPoints()
		TitleContainer:Point('TOPLEFT', 1, -1)
		TitleContainer:Point('TOPRIGHT', -1, 0)
	else
		ReadyCheckFrame:StripTextures()
		ReadyCheckFrame:SetTemplate('Transparent')
		ListenerFrame:SetAlpha(0)
	end

	-- Retail, Forever and Mists skin it in PVP.lua
	if not (E.Modern or E.Mists) then
		_G.PVPReadyDialog:StripTextures()
		_G.PVPReadyDialog:SetTemplate('Transparent')
		S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
		S:HandleButton(_G.PVPReadyDialogHideButton)
	end

	-- Mainline moves the box to the TOOLTIP strata itself
	if not E.Modern then
		_G.AutoCompleteBox:HookScript('OnShow', FixAutoCompleteLevel)
	end

	S:HandleButton(_G.StaticPopup1ExtraButton)

	-- reskin all esc/menu buttons
	if not E.OtherAddons.ConsolePort then
		local GameMenuFrame = _G.GameMenuFrame
		GameMenuFrame:StripTextures()
		GameMenuFrame:CreateBackdrop('Transparent')

		local header = GameMenuFrame.Header
		header:StripTextures()
		header:ClearAllPoints()
		header:Point('TOP', GameMenuFrame, 0, E.Modern and 7 or -7)

		hooksecurefunc(GameMenuFrame, 'InitButtons', GameMenuInitButtons)
	end

	local optionHouse = E.OtherAddons.OptionHouse and _G.GameMenuButtonOptionHouse
	if optionHouse then
		S:HandleButton(optionHouse)
	end

	-- since we cant hook `CinematicFrame_OnShow` or `CinematicFrame_OnEvent` directly
	-- we can just hook onto this function so that we can get the correct `self`
	-- this is called through `CinematicFrame_OnShow` so the result would still happen where we want
	hooksecurefunc('CinematicFrame_UpdateLettboxForAspectRatio', UpdateLettboxForAspectRatio)
	hooksecurefunc(_G.MovieFrame, 'ShowCloseDialog', ShowCloseDialog)

	--LFD Role Picker frame
	local LFDRoleCheckPopup = _G.LFDRoleCheckPopup
	if LFDRoleCheckPopup then
		LFDRoleCheckPopup:StripTextures()
		LFDRoleCheckPopup:SetTemplate('Transparent')
		S:HandleButton(_G.LFDRoleCheckPopupAcceptButton)
		S:HandleButton(_G.LFDRoleCheckPopupDeclineButton)

		for _, roleButton in next, {
			_G.LFDRoleCheckPopupRoleButtonTank,
			_G.LFDRoleCheckPopupRoleButtonDPS,
			_G.LFDRoleCheckPopupRoleButtonHealer
		} do
			S:HandleCheckBox(roleButton.checkButton, nil, nil, true)
			roleButton:DisableDrawLayer('OVERLAY')
		end
	end

	-- reskin popup buttons
	for i = 1, E.MAX_STATIC_POPUPS do
		S:HandleStaticPopup(_G['StaticPopup'..i])
	end

	-- skin return to graveyard button
	local GhostFrame = _G.GhostFrame
	if GhostFrame then
		_G.GhostFrameMiddle:SetAlpha(0)
		_G.GhostFrameRight:SetAlpha(0)
		_G.GhostFrameLeft:SetAlpha(0)
		GhostFrame:StripTextures()
		GhostFrame:ClearAllPoints()
		GhostFrame:Point('TOP', E.UIParent, 'TOP', 0, -200)
		_G.GhostFrameContentsFrame:SetTemplate('Transparent')
		_G.GhostFrameContentsFrameText:Point('TOPLEFT', 53, 0)
		_G.GhostFrameContentsFrameIcon:SetTexCoords()
		_G.GhostFrameContentsFrameIcon:Point('RIGHT', _G.GhostFrameContentsFrameText, 'LEFT', -12, 0)

		local button = CreateFrame('Frame', nil, _G.GhostFrameContentsFrameIcon:GetParent())
		button:Point('TOPLEFT', _G.GhostFrameContentsFrameIcon, -E.Border, E.Border)
		button:Point('BOTTOMRIGHT', _G.GhostFrameContentsFrameIcon, E.Border, -E.Border)
		_G.GhostFrameContentsFrameIcon:Size(37, 38)
		_G.GhostFrameContentsFrameIcon:SetParent(button)
		button:SetTemplate()
	end

	_G.OpacityFrame:StripTextures()
	_G.OpacityFrame:SetTemplate('Transparent')

	-- DropDownMenu
	S:SkinDropDownMenu('DropDownList')

	local SideDressUpFrame = _G.SideDressUpFrame
	S:HandleCloseButton(E.Modern and _G.SideDressUpFrameCloseButton or _G.SideDressUpModelCloseButton)
	S:HandleButton(SideDressUpFrame.ResetButton)
	SideDressUpFrame:StripTextures()
	SideDressUpFrame:SetTemplate('Transparent')
	SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
	SideDressUpFrame.ResetButton:OffsetFrameLevel(1)

	if E.Modern then
		S:HandleModelSceneControlButtons(SideDressUpFrame.ModelScene.ControlFrame)
	end

	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:StripTextures()
	StackSplitFrame:SetTemplate('Transparent')

	StackSplitFrame.bg1 = CreateFrame('Frame', nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate('Transparent')
	StackSplitFrame.bg1:Point('TOPLEFT', 10, -15)
	StackSplitFrame.bg1:Point('BOTTOMRIGHT', -10, 55)
	StackSplitFrame.bg1:OffsetFrameLevel(-1)

	S:HandleButton(E.Modern and StackSplitFrame.OkayButton or _G.StackSplitOkayButton)
	S:HandleButton(E.Modern and StackSplitFrame.CancelButton or _G.StackSplitCancelButton)

	local leftButton = E.Modern and StackSplitFrame.LeftButton or _G.StackSplitLeftButton
	local rightButton = E.Modern and StackSplitFrame.RightButton or _G.StackSplitRightButton
	for _, button in next, { leftButton, rightButton } do
		button:ClearAllPoints()

		if button == leftButton then
			button:Point('LEFT', StackSplitFrame.bg1, 'LEFT', 4, 0)
		else
			button:Point('RIGHT', StackSplitFrame.bg1, 'RIGHT', -4, 0)
		end

		S:HandleNextPrevButton(button, nil, nil, true)
	end

	-- NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	hooksecurefunc('NavBar_AddButton', S.HandleNavBarButtons)

	-- Basic Message Dialog
	S:HandleFrame(_G.BasicMessageDialog)
	S:HandleButton(_G.BasicMessageDialogButton)

	-- SplashFrame (Whats New)
	local SplashFrame = _G.SplashFrame
	if SplashFrame then
		S:HandleCloseButton(SplashFrame.TopCloseButton)
		S:HandleButton(SplashFrame.BottomCloseButton)
	end
end
