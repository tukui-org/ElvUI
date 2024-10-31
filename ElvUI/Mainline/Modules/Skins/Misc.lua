local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack

local UnitIsUnit = UnitIsUnit
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function ClearSetTexture(texture, tex)
	if tex ~= nil then
		texture:SetTexture()
	end
end

local function FixReadyCheckFrame(frame)
	if frame.initiator and UnitIsUnit('player', frame.initiator) then
		frame:Hide() -- bug fix, don't show it if player is initiator
	end
end

function S:BlizzardMiscFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local compartment = _G.AddonCompartmentFrame
	if compartment then
		compartment:StripTextures()
		compartment:SetTemplate('Transparent')
	end

	for _, frame in next, { _G.AutoCompleteBox, _G.QueueStatusFrame } do
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	-- ReadyCheck thing
	S:HandleButton(_G.ReadyCheckFrameYesButton)
	S:HandleButton(_G.ReadyCheckFrameNoButton)

	local ReadyCheckFrame = _G.ReadyCheckFrame
	_G.ReadyCheckPortrait:Kill()
	_G.ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameYesButton:ClearAllPoints()
	_G.ReadyCheckFrameNoButton:ClearAllPoints()
	_G.ReadyCheckFrameYesButton:Point('TOPRIGHT', ReadyCheckFrame, 'CENTER', -3, -5)
	_G.ReadyCheckFrameNoButton:Point('TOPLEFT', ReadyCheckFrame, 'CENTER', 3, -5)
	_G.ReadyCheckFrameText:ClearAllPoints()
	_G.ReadyCheckFrameText:Point('TOP', 0, -30)
	_G.ReadyCheckFrameText:Width(300)

	local ListenerFrame = _G.ReadyCheckListenerFrame
	S:HandleFrame(ListenerFrame)

	local TitleContainer = ListenerFrame.TitleContainer
	TitleContainer:ClearAllPoints()
	TitleContainer:Point('TOPLEFT', 1, -1)
	TitleContainer:Point('TOPRIGHT', -1, 0)

	ReadyCheckFrame:HookScript('OnShow', FixReadyCheckFrame)

	S:HandleButton(_G.StaticPopup1ExtraButton)

	-- reskin all esc/menu buttons
	if not E:IsAddOnEnabled('ConsolePort_Menu') then
		local GameMenuFrame = _G.GameMenuFrame
		GameMenuFrame:StripTextures()
		GameMenuFrame:CreateBackdrop('Transparent')

		GameMenuFrame.Header:StripTextures()
		GameMenuFrame.Header:ClearAllPoints()
		GameMenuFrame.Header:Point('TOP', GameMenuFrame, 0, 7)

		local function ClearedHooks(button, script)
			if script == 'OnEnter' then
				button:HookScript('OnEnter', S.SetModifiedBackdrop)
			elseif script == 'OnLeave' then
				button:HookScript('OnLeave', S.SetOriginalBackdrop)
			elseif script == 'OnDisable' then
				button:HookScript('OnDisable', S.SetDisabledBackdrop)
			end
		end

		hooksecurefunc(GameMenuFrame, 'InitButtons', function(menu)
			if not menu.buttonPool then return end

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
		end)
	end

	-- since we cant hook `CinematicFrame_OnShow` or `CinematicFrame_OnEvent` directly
	-- we can just hook onto this function so that we can get the correct `self`
	-- this is called through `CinematicFrame_OnShow` so the result would still happen where we want
	hooksecurefunc('CinematicFrame_UpdateLettboxForAspectRatio', function(s)
		if s and s.closeDialog and not s.closeDialog.template then
			s.closeDialog:StripTextures()
			s.closeDialog:SetTemplate('Transparent')
			s:SetScale(E.uiscale)

			local dialogName = s.closeDialog.GetName and s.closeDialog:GetName()
			local closeButton = s.closeDialog.ConfirmButton or (dialogName and _G[dialogName..'ConfirmButton'])
			local resumeButton = s.closeDialog.ResumeButton or (dialogName and _G[dialogName..'ResumeButton'])
			if closeButton then S:HandleButton(closeButton) end
			if resumeButton then S:HandleButton(resumeButton) end
		end
	end)

	-- same as above except `MovieFrame_OnEvent` and `MovieFrame_OnShow`
	-- cant be hooked directly so we can just use this
	-- this is called through `MovieFrame_OnEvent` on the event `PLAY_MOVIE`
	hooksecurefunc('MovieFrame_PlayMovie', function(s)
		if s and s.CloseDialog and not s.CloseDialog.template then
			s:SetScale(E.uiscale)
			s.CloseDialog:StripTextures()
			s.CloseDialog:SetTemplate('Transparent')
			S:HandleButton(s.CloseDialog.ConfirmButton)
			S:HandleButton(s.CloseDialog.ResumeButton)
		end
	end)

	do
		local menuBackdrop = function(s)
			s:SetTemplate('Transparent')
		end

		local chatMenuBackdrop = function(s)
			s:SetTemplate('Transparent')

			s:ClearAllPoints()
			s:Point('BOTTOMLEFT', _G.ChatFrame1, 'TOPLEFT', 0, 30)
		end

		for index, menu in next, { _G.ChatMenu, _G.EmoteMenu, _G.LanguageMenu, _G.VoiceMacroMenu } do
			menu:StripTextures()

			if index == 1 then -- ChatMenu
				menu:HookScript('OnShow', chatMenuBackdrop)
			else
				menu:HookScript('OnShow', menuBackdrop)
			end
		end
	end

	--LFD Role Picker frame
	_G.LFDRoleCheckPopup:StripTextures()
	_G.LFDRoleCheckPopup:SetTemplate('Transparent')
	S:HandleButton(_G.LFDRoleCheckPopupAcceptButton)
	S:HandleButton(_G.LFDRoleCheckPopupDeclineButton)

	for _, roleButton in next, {
		_G.LFDRoleCheckPopupRoleButtonTank,
		_G.LFDRoleCheckPopupRoleButtonDPS,
		_G.LFDRoleCheckPopupRoleButtonHealer
	} do
		S:HandleCheckBox(roleButton.checkButton or roleButton.CheckButton, nil, nil, true)
		roleButton:DisableDrawLayer('OVERLAY')
	end

	-- reskin popup buttons
	for i = 1, 4 do
		local StaticPopup = _G['StaticPopup'..i]
		StaticPopup:StripTextures()
		StaticPopup:SetTemplate('Transparent')
		StaticPopup:HookScript('OnShow', function() -- UpdateRecapButton is created OnShow
			if StaticPopup.UpdateRecapButton and (not StaticPopup.UpdateRecapButtonHooked) then
				StaticPopup.UpdateRecapButtonHooked = true -- we should only hook this once
				hooksecurefunc(StaticPopup, 'UpdateRecapButton', S.UpdateRecapButton)
			end
		end)

		for j = 1, 4 do
			local button = StaticPopup['button'..j]
			S:HandleButton(button)

			button:SetFrameLevel(button:GetFrameLevel() + 1)
			button:CreateShadow(5)
			button.shadow:SetAlpha(0)
			button.shadow:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
			button.Flash:Hide()

			local anim1, anim2 = button.PulseAnim:GetAnimations()
			anim1:SetTarget(button.shadow)
			anim2:SetTarget(button.shadow)
		end

		local editbox = _G['StaticPopup'..i..'EditBox']
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameGold'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameSilver'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameCopper'])
		S:HandleEditBox(editbox)
		editbox:SetFrameLevel(editbox:GetFrameLevel()+1)
		editbox.backdrop:Point('TOPLEFT', -2, -4)
		editbox.backdrop:Point('BOTTOMRIGHT', 2, 4)

		_G['StaticPopup'..i..'ItemFrameNameFrame']:Kill()
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetTexCoord(unpack(E.TexCoords))
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetInside()

		local itemFrame = _G['StaticPopup'..i..'ItemFrame']
		itemFrame:SetTemplate()
		itemFrame:StyleButton()
		S:HandleIconBorder(itemFrame.IconBorder)

		local normTex = itemFrame:GetNormalTexture()
		if normTex then
			normTex:SetTexture()
			hooksecurefunc(normTex, 'SetTexture', ClearSetTexture)
		end
	end

	-- skin return to graveyard button
	do
		_G.GhostFrameMiddle:SetAlpha(0)
		_G.GhostFrameRight:SetAlpha(0)
		_G.GhostFrameLeft:SetAlpha(0)
		_G.GhostFrame:StripTextures()
		_G.GhostFrame:ClearAllPoints()
		_G.GhostFrame:Point('TOP', E.UIParent, 'TOP', 0, -200)
		_G.GhostFrameContentsFrame:SetTemplate('Transparent')
		_G.GhostFrameContentsFrameText:Point('TOPLEFT', 53, 0)
		_G.GhostFrameContentsFrameIcon:SetTexCoord(unpack(E.TexCoords))
		_G.GhostFrameContentsFrameIcon:Point('RIGHT', _G.GhostFrameContentsFrameText, 'LEFT', -12, 0)

		local x = E.PixelMode and 1 or 2
		local button = CreateFrame('Frame', nil, _G.GhostFrameContentsFrameIcon:GetParent())
		button:Point('TOPLEFT', _G.GhostFrameContentsFrameIcon, -x, x)
		button:Point('BOTTOMRIGHT', _G.GhostFrameContentsFrameIcon, x, -x)
		_G.GhostFrameContentsFrameIcon:Size(37, 38)
		_G.GhostFrameContentsFrameIcon:SetParent(button)
		button:SetTemplate()
	end

	_G.OpacityFrame:StripTextures()
	_G.OpacityFrame:SetTemplate('Transparent')

	--DropDownMenu
	S:SkinDropDownMenu('DropDownList')

	local SideDressUpFrame = _G.SideDressUpFrame
	S:HandleCloseButton(_G.SideDressUpFrameCloseButton)
	S:HandleButton(SideDressUpFrame.ResetButton)
	SideDressUpFrame:StripTextures()
	SideDressUpFrame:SetTemplate('Transparent')
	SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
	SideDressUpFrame.ResetButton:SetFrameLevel(SideDressUpFrame.ResetButton:GetFrameLevel()+1)
	S:HandleModelSceneControlButtons(SideDressUpFrame.ModelScene.ControlFrame)

	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:StripTextures()
	StackSplitFrame:SetTemplate('Transparent')

	StackSplitFrame.bg1 = CreateFrame('Frame', nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate('Transparent')
	StackSplitFrame.bg1:Point('TOPLEFT', 10, -15)
	StackSplitFrame.bg1:Point('BOTTOMRIGHT', -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(StackSplitFrame.OkayButton)
	S:HandleButton(StackSplitFrame.CancelButton)

	for _, button in next, { StackSplitFrame.LeftButton, StackSplitFrame.RightButton } do
		button:Size(14, 18)
		button:ClearAllPoints()

		if button == StackSplitFrame.LeftButton then
			button:Point('LEFT', StackSplitFrame.bg1, 'LEFT', 4, 0)
		else
			button:Point('RIGHT', StackSplitFrame.bg1, 'RIGHT', -4, 0)
		end

		S:HandleNextPrevButton(button, nil, nil, true)
	end

	-- NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	hooksecurefunc('NavBar_AddButton', S.HandleNavBarButtons)

	-- Basic Message Dialog
	local MessageDialog = _G.BasicMessageDialog
	if MessageDialog then
		S:HandleFrame(MessageDialog)
		S:HandleButton(_G.BasicMessageDialogButton)
	end

	-- SplashFrame (Whats New)
	local SplashFrame = _G.SplashFrame
	S:HandleCloseButton(SplashFrame.TopCloseButton)
	S:HandleButton(SplashFrame.BottomCloseButton)
end

S:AddCallback('BlizzardMiscFrames')
