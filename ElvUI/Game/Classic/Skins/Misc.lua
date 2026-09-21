local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame

local function FixReadyCheckFrame(frame)
	if frame.initiator and E:UnitIsUnit('player', frame.initiator) then
		frame:Hide() -- bug fix, don't show it if player is initiator
	end
end

local function FixAutoCompleteLevel(frame)
	local parent = frame:GetParent()
	if not parent then return end

	local frameLevel = parent:GetFrameLevel()
	frame:SetFrameLevel(frameLevel + 4)
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

function S:BlizzardMiscFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	-- Blizzard frame we want to reskin
	for _, frame in next, { _G.AutoCompleteBox, _G.QueueStatusFrame, _G.ReadyCheckFrame } do
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	-- ReadyCheckFrame
	-- Here we reskin all 'normal' buttons
	S:HandleButton(_G.ReadyCheckFrameYesButton)
	S:HandleButton(_G.ReadyCheckFrameNoButton)

	local ReadyCheckFrame = _G.ReadyCheckFrame
	_G.ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameYesButton:ClearAllPoints()
	_G.ReadyCheckFrameNoButton:ClearAllPoints()
	_G.ReadyCheckFrameYesButton:Point('TOPRIGHT', ReadyCheckFrame, 'CENTER', -3, -5)
	_G.ReadyCheckFrameNoButton:Point('TOPLEFT', ReadyCheckFrame, 'CENTER', 3, -5)
	_G.ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameText:ClearAllPoints()
	_G.ReadyCheckFrameText:Point('TOP', 0, -15)
	_G.ReadyCheckFrameText:Width(300)

	_G.PVPReadyDialog:StripTextures()
	_G.PVPReadyDialog:SetTemplate('Transparent')
	S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
	S:HandleButton(_G.PVPReadyDialogHideButton)

	_G.ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript('OnShow', FixReadyCheckFrame)

	_G.AutoCompleteBox:SetScript('OnShow', FixAutoCompleteLevel) -- bug fix, swap to AutoCompleteBoxMixin.OnShow instead of AutoComplete_OnShow

	S:HandleButton(_G.StaticPopup1ExtraButton)

	-- reskin all esc/menu buttons
	if not E.OtherAddons.ConsolePort then
		local GameMenuFrame = _G.GameMenuFrame
		GameMenuFrame:StripTextures()
		GameMenuFrame:CreateBackdrop('Transparent')

		local header = GameMenuFrame.Header
		header:StripTextures()
		header:ClearAllPoints()
		header:Point('TOP', GameMenuFrame, 0, -7)

		hooksecurefunc(GameMenuFrame, 'InitButtons', GameMenuInitButtons)
	end

	local optionHouse = E.OtherAddons.OptionHouse and _G.GameMenuButtonOptionHouse
	if optionHouse then
		S:HandleButton(optionHouse)
	end

	-- since we cant hook `CinematicFrame_OnShow` or `CinematicFrame_OnEvent` directly
	-- we can just hook onto this function so that we can get the correct `self`
	-- this is called through `CinematicFrame_OnShow` so the result would still happen where we want
	hooksecurefunc('CinematicFrame_UpdateLettboxForAspectRatio', function(frame)
		frame:SetScale(E.uiscale)

		local closeDialog = frame.closeDialog
		if not closeDialog.template then
			closeDialog:StripTextures()
			closeDialog:SetTemplate('Transparent')

			local dialogName = closeDialog:GetName()
			S:HandleButton(_G[dialogName..'ConfirmButton'], nil, nil, nil, true)
			S:HandleButton(_G[dialogName..'ResumeButton'], nil, nil, nil, true)
		end
	end)

	local MovieFrame = _G.MovieFrame
	hooksecurefunc(MovieFrame, 'ShowCloseDialog', function(frame)
		frame:SetScale(E.uiscale)

		local closeDialog = frame.CloseDialog
		if not closeDialog.template then
			closeDialog:StripTextures()
			closeDialog:SetTemplate('Transparent')

			S:HandleButton(closeDialog.Buttons.ConfirmButton, nil, nil, nil, true)
			S:HandleButton(closeDialog.Buttons.ResumeButton, nil, nil, nil, true)
		end
	end)

	-- reskin popup buttons
	for i = 1, E.MAX_STATIC_POPUPS do
		S:HandleStaticPopup(_G['StaticPopup'..i])
	end

	_G.OpacityFrame:StripTextures()
	_G.OpacityFrame:SetTemplate('Transparent')

	-- DropDownMenu
	S:SkinDropDownMenu('DropDownList')

	local SideDressUpFrame = _G.SideDressUpFrame
	S:HandleCloseButton(_G.SideDressUpModelCloseButton)
	SideDressUpFrame:StripTextures()
	SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
	S:HandleButton(_G.SideDressUpModelResetButton)
	SideDressUpFrame:SetTemplate('Transparent')

	-- StackSplit
	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:StripTextures()
	StackSplitFrame:SetTemplate('Transparent')

	StackSplitFrame.bg1 = CreateFrame('Frame', nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate('Transparent')
	StackSplitFrame.bg1:Point('TOPLEFT', 10, -15)
	StackSplitFrame.bg1:Point('BOTTOMRIGHT', -10, 55)
	StackSplitFrame.bg1:OffsetFrameLevel(-1)

	S:HandleButton(_G.StackSplitOkayButton)
	S:HandleButton(_G.StackSplitCancelButton)

	for _, btn in next, { _G.StackSplitLeftButton, _G.StackSplitRightButton } do
		btn:Size(14, 18)
		btn:ClearAllPoints()

		if btn == _G.StackSplitLeftButton then
			btn:Point('LEFT', StackSplitFrame.bg1, 'LEFT', 4, 0)
		else
			btn:Point('RIGHT', StackSplitFrame.bg1, 'RIGHT', -4, 0)
		end

		S:HandleNextPrevButton(btn)
		btn:SetTemplate('NoBackdrop')
	end

	-- NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	hooksecurefunc('NavBar_AddButton', S.HandleNavBarButtons)
end

S:AddCallback('BlizzardMiscFrames')
