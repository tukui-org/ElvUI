local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs = ipairs
local pairs, unpack = pairs, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function SkinNavBarButtons(self)
	local parentName = self:GetParent():GetName()
	if (parentName == 'EncounterJournal' and not E.private.skins.blizzard.encounterjournal)
	or (parentName == 'WorldMapFrame' and not E.private.skins.blizzard.worldmap)
	or (parentName == 'HelpFrameKnowledgebase' and not E.private.skins.blizzard.help) then
		return
	end

	local navButton = self.navList[#self.navList]
	if navButton and not navButton.isSkinned then
		S:HandleButton(navButton, true)
		navButton:GetFontString():SetTextColor(1, 1, 1)

		if navButton.MenuArrowButton then
			navButton.MenuArrowButton:StripTextures()
			if navButton.MenuArrowButton.Art then
				navButton.MenuArrowButton.Art:SetTexture(E.Media.Textures.ArrowUp)
				navButton.MenuArrowButton.Art:SetTexCoord(0, 1, 0, 1)
				navButton.MenuArrowButton.Art:SetRotation(3.14)
			end
		end

		navButton.xoffset = 1
		navButton.isSkinned = true
	end
end

function S:BlizzardMiscFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	-- Blizzard frame we want to reskin
	local skins = {
		_G.AutoCompleteBox,
		_G.ReadyCheckFrame
	}

	for _, frame in ipairs(skins) do
		frame:StripTextures()
		frame:SetTemplate('Transparent')
	end

	S:HandleButton(_G.StaticPopup1ExtraButton)

	if not E:IsAddOnEnabled('ConsolePortUI_Menu') then
		-- Reskin all esc/menu buttons
		for _, Button in pairs({_G.GameMenuFrame:GetChildren()}) do
			if Button.IsObjectType and Button:IsObjectType("Button") then
				S:HandleButton(Button)
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

	-- Since we cant hook 'CinematicFrame_OnShow' or 'CinematicFrame_OnEvent' directly
	-- We can just hook onto this function so that we can get the correct `self`
	-- This is called through 'CinematicFrame_OnShow' so the result would still happen where we want
	hooksecurefunc('CinematicFrame_OnDisplaySizeChanged', function(s)
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

	local ChatMenus = {
		_G.ChatMenu,
		_G.EmoteMenu,
		_G.LanguageMenu,
		_G.VoiceMacroMenu,
	}

	for _, frame in ipairs(ChatMenus) do
		if frame == _G.ChatMenu then
			frame:HookScript('OnShow', function(menu) menu:SetTemplate('Transparent', true) menu:SetBackdropColor(unpack(E.media.backdropfadecolor)) menu:ClearAllPoints() menu:Point('BOTTOMLEFT', _G.ChatFrame1, 'TOPLEFT', 0, 30) end)
		else
			frame:HookScript('OnShow', function(menu) menu:SetTemplate('Transparent', true) menu:SetBackdropColor(unpack(E.media.backdropfadecolor)) end)
		end
	end

	-- Emotes NineSlice
	_G.ChatMenu.NineSlice:SetTemplate()

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
			hooksecurefunc(normTex, 'SetTexture', function(texture, tex)
				if tex ~= nil then texture:SetTexture() end
			end)
		end

		-- Quality IconBorder
		hooksecurefunc(_G['StaticPopup'..i..'ItemFrame'].IconBorder, 'SetVertexColor', function(frame, r, g, b)
			frame:GetParent():SetBackdropBorderColor(r, g, b)
			frame:SetTexture()
		end)
		hooksecurefunc(_G['StaticPopup'..i..'ItemFrame'].IconBorder, 'Hide', function(frame)
			frame:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
	end

	_G.OpacityFrame:StripTextures()
	_G.OpacityFrame:SetTemplate('Transparent')

	-- DropDownMenu
	hooksecurefunc('UIDropDownMenu_CreateFrames', function(level, index)
		local listFrame = _G['DropDownList'..level]
		local listFrameName = listFrame:GetName()
		local expandArrow = _G[listFrameName..'Button'..index..'ExpandArrow']
		if expandArrow then
			local normTex = expandArrow:GetNormalTexture()
			expandArrow:SetNormalTexture(E.Media.Textures.ArrowUp)
			normTex:SetVertexColor(unpack(E.media.rgbvaluecolor))
			normTex:SetRotation(S.ArrowRotation.right)
			expandArrow:Size(12, 12)
		end

		local Backdrop = _G[listFrameName..'Backdrop']
		if Backdrop and not Backdrop.template then
			Backdrop:StripTextures()
			Backdrop:SetTemplate('Transparent')
		end

		local menuBackdrop = _G[listFrameName..'MenuBackdrop']
		if menuBackdrop and not menuBackdrop.template then
			menuBackdrop:StripTextures()
			menuBackdrop:SetTemplate('Transparent')
		end
	end)

	hooksecurefunc('UIDropDownMenu_SetIconImage', function(icon, texture)
		if texture:find('Divider') then
			local r, g, b = unpack(E.media.rgbvaluecolor)
			icon:SetColorTexture(r, g, b, 0.45)
			icon:Height(1)
		end
	end)

	hooksecurefunc('ToggleDropDownMenu', function(level)
		if not level then
			level = 1
		end

		local r, g, b = unpack(E.media.rgbvaluecolor)

		for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G['DropDownList'..level..'Button'..i]
			local check = _G['DropDownList'..level..'Button'..i..'Check']
			local uncheck = _G['DropDownList'..level..'Button'..i..'UnCheck']
			local highlight = _G['DropDownList'..level..'Button'..i..'Highlight']

			highlight:SetTexture(E.Media.Textures.Highlight)
			highlight:SetBlendMode('BLEND')
			highlight:SetDrawLayer('BACKGROUND')
			highlight:SetVertexColor(r, g, b)

			if not button.backdrop then
				button:CreateBackdrop()
			end

			if not button.notCheckable then
				uncheck:SetTexture()

				local _, co = check:GetTexCoord()
				if co == 0 then
					check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
					check:SetVertexColor(r, g, b, 1)
					check:Size(20, 20)
					check:SetDesaturated(true)
					button.backdrop:SetInside(check, 4, 4)
				else
					check:SetTexture(E.media.normTex)
					check:SetVertexColor(r, g, b, 1)
					check:Size(10, 10)
					check:SetDesaturated(false)
					button.backdrop:SetOutside(check)
				end

				button.backdrop:Show()
				check:SetTexCoord(0, 1, 0, 1)
			else
				button.backdrop:Hide()
				check:Size(16, 16)
			end
		end
	end)

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

	local buttons = {StackSplitFrame.LeftButton, StackSplitFrame.RightButton}
	for _, btn in pairs(buttons) do
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

	--NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	hooksecurefunc('NavBar_AddButton', SkinNavBarButtons)
end

S:AddCallback('BlizzardMiscFrames')
