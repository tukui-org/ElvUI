local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, unpack = next, unpack

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

	_G.ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript('OnShow', FixReadyCheckFrame)

	S:HandleButton(_G.StaticPopup1ExtraButton)

	if not E:IsAddOnEnabled('ConsolePort_Menu') then
		-- Reskin all esc/menu buttons
		for _, button in next, { _G.GameMenuFrame:GetChildren() } do
			if button.IsObjectType and button:IsObjectType('Button') then
				S:HandleButton(button)
			end
		end

		_G.GameMenuFrame:StripTextures()
		_G.GameMenuFrame:SetTemplate('Transparent')
		_G.GameMenuFrameHeader:SetTexture()
		_G.GameMenuFrameHeader:ClearAllPoints()
		_G.GameMenuFrameHeader:Point('TOP', _G.GameMenuFrame, 0, 7)
	end

	if E:IsAddOnEnabled('OptionHouse') then
		S:HandleButton(_G.GameMenuButtonOptionHouse)
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

	-- Same as above except 'MovieFrame_OnEvent' and 'MovieFrame_OnShow'
	-- Cant be hooked directly so we can just use this
	-- This is called through 'MovieFrame_OnEvent' on the event 'PLAY_MOVIE'
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

	-- LFD Role Picker frame
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

	-- Reskin popup buttons
	for i = 1, 4 do
		local StaticPopup = _G['StaticPopup'..i]
		StaticPopup:HookScript('OnShow', function() -- UpdateRecapButton is created OnShow
			if StaticPopup.UpdateRecapButton and (not StaticPopup.UpdateRecapButtonHooked) then
				StaticPopup.UpdateRecapButtonHooked = true -- We should only hook this once
				hooksecurefunc(_G['StaticPopup'..i], 'UpdateRecapButton', S.UpdateRecapButton)
			end
		end)

		StaticPopup:StripTextures()
		StaticPopup:SetTemplate('Transparent')

		for j = 1, 4 do
			local button = StaticPopup['button'..j]
			S:HandleButton(button)

			button.Flash:Hide()

			button:CreateShadow(5)
			button.shadow:SetAlpha(0)
			button.shadow:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))

			local anim1, anim2 = button.PulseAnim:GetAnimations()
			anim1:SetTarget(button.shadow)
			anim2:SetTarget(button.shadow)
		end

		_G['StaticPopup'..i..'EditBox']:SetFrameLevel(_G['StaticPopup'..i..'EditBox']:GetFrameLevel()+1)
		S:HandleEditBox(_G['StaticPopup'..i..'EditBox'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameGold'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameSilver'])
		S:HandleEditBox(_G['StaticPopup'..i..'MoneyInputFrameCopper'])
		_G['StaticPopup'..i..'EditBox'].backdrop:Point('TOPLEFT', -2, -4)
		_G['StaticPopup'..i..'EditBox'].backdrop:Point('BOTTOMRIGHT', 2, 4)
		_G['StaticPopup'..i..'ItemFrameNameFrame']:Kill()
		_G['StaticPopup'..i..'ItemFrame']:SetTemplate()
		_G['StaticPopup'..i..'ItemFrame']:StyleButton()
		_G['StaticPopup'..i..'ItemFrame'].IconBorder:SetAlpha(0)
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetTexCoord(unpack(E.TexCoords))
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetInside()

		local normTex = _G['StaticPopup'..i..'ItemFrame']:GetNormalTexture()
		if normTex then
			normTex:SetTexture()
			hooksecurefunc(normTex, 'SetTexture', ClearSetTexture)
		end

		S:HandleIconBorder(_G['StaticPopup'..i..'ItemFrame'].IconBorder)
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
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(_G.StackSplitOkayButton)
	S:HandleButton(_G.StackSplitCancelButton)

	for _, btn in next, { StackSplitFrame.LeftButton, StackSplitFrame.RightButton } do
		btn:Size(14, 18)
		btn:ClearAllPoints()

		if btn == StackSplitFrame.LeftButton then
			btn:Point('LEFT', StackSplitFrame.bg1, 'LEFT', 4, 0)
		else
			btn:Point('RIGHT', StackSplitFrame.bg1, 'RIGHT', -4, 0)
		end

		S:HandleNextPrevButton(btn)

		if btn.SetTemplate then
			btn:SetTemplate('NoBackdrop')
		end
	end

	-- NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	hooksecurefunc('NavBar_AddButton', S.HandleNavBarButtons)
end

S:AddCallback('BlizzardMiscFrames')
