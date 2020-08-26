local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local unpack = unpack

local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local CreateFrame = CreateFrame

local LFG_ICONS = [[Interface\LFGFrame\UI-LFG-ICONS-ROLEBACKGROUNDS]]
local function SkinNavBarButtons(self)
	if (self:GetParent():GetName() == 'EncounterJournal' and not E.private.skins.blizzard.encounterjournal) or (self:GetParent():GetName() == 'WorldMapFrame' and not E.private.skins.blizzard.worldmap) or (self:GetParent():GetName() == 'HelpFrameKnowledgebase' and not E.private.skins.blizzard.help) then
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

	_G.QueueStatusFrame:StripTextures()

	-- Blizzard frame we want to reskin
	local skins = {
		'AutoCompleteBox',
		'ReadyCheckFrame',
		'QueueStatusFrame',
		'LFDReadyCheckPopup',
	}

	for i = 1, #skins do
		_G[skins[i]]:StripTextures()
		_G[skins[i]]:SetTemplate('Transparent')
	end

	S:HandleButton(_G.StaticPopup1ExtraButton)

	hooksecurefunc('QueueStatusEntry_SetFullDisplay', function(entry, _, _, _, isTank, isHealer, isDPS)
		if not entry then return end
		local nextRoleIcon = 1
		if isDPS then
			local icon = entry['RoleIcon'..nextRoleIcon]
			if icon then
				icon:SetTexture(LFG_ICONS)
				icon:SetTexCoord(_G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
				nextRoleIcon = nextRoleIcon + 1
			end
		end
		if isHealer then
			local icon = entry['RoleIcon'..nextRoleIcon]
			if icon then
				icon:SetTexture(LFG_ICONS)
				icon:SetTexCoord(_G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
				nextRoleIcon = nextRoleIcon + 1
			end
		end
		if isTank then
			local icon = entry['RoleIcon'..nextRoleIcon]
			if icon then
				icon:SetTexture(LFG_ICONS)
				icon:SetTexCoord(_G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
			end
		end
	end)

	hooksecurefunc('QueueStatusFrame_Update', function()
		for frame in _G.QueueStatusFrame.statusEntriesPool:EnumerateActive() do
			frame.HealersFound.Texture:SetTexture(LFG_ICONS)
			frame.TanksFound.Texture:SetTexture(LFG_ICONS)
			frame.DamagersFound.Texture:SetTexture(LFG_ICONS)
			frame.HealersFound.Texture:SetTexCoord(_G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
			frame.TanksFound.Texture:SetTexCoord(_G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
			frame.DamagersFound.Texture:SetTexCoord(_G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
		end
	end)

	if not IsAddOnLoaded('ConsolePortUI_Menu') then
		-- reskin all esc/menu buttons
		for _, Button in pairs({_G.GameMenuFrame:GetChildren()}) do
			if Button.IsObjectType and Button:IsObjectType('Button') then
				S:HandleButton(Button)
			end
		end

		_G.GameMenuFrame:StripTextures()
		_G.GameMenuFrame:SetTemplate('Transparent')
		_G.GameMenuFrame.Header:StripTextures()
		_G.GameMenuFrame.Header:ClearAllPoints()
		_G.GameMenuFrame.Header:SetPoint('TOP', _G.GameMenuFrame, 0, 7)
	end

	if IsAddOnLoaded('OptionHouse') then
		S:HandleButton(_G.GameMenuButtonOptionHouse)
	end

	-- since we cant hook `CinematicFrame_OnShow` or `CinematicFrame_OnEvent` directly
	-- we can just hook onto this function so that we can get the correct `self`
	-- this is called through `CinematicFrame_OnShow` so the result would still happen where we want
	hooksecurefunc('CinematicFrame_OnDisplaySizeChanged', function(s)
		if s and s.closeDialog and not s.closeDialog.template then
			s.closeDialog:StripTextures()
			s.closeDialog:SetTemplate('Transparent')
			s:SetScale(_G.UIParent:GetScale())
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
			s:SetScale(_G.UIParent:GetScale())
			s.CloseDialog:StripTextures()
			s.CloseDialog:SetTemplate('Transparent')
			S:HandleButton(s.CloseDialog.ConfirmButton)
			S:HandleButton(s.CloseDialog.ResumeButton)
		end
	end)

	local ChatMenus = {
		'ChatMenu',
		'EmoteMenu',
		'LanguageMenu',
		'VoiceMacroMenu',
	}

	for i = 1, #ChatMenus do
		if _G[ChatMenus[i]] == _G.ChatMenu then
			_G[ChatMenus[i]]:HookScript('OnShow', function(s) s:SetTemplate('Transparent', true) s:SetBackdropColor(unpack(E.media.backdropfadecolor)) s:ClearAllPoints() s:SetPoint('BOTTOMLEFT', _G.ChatFrame1, 'TOPLEFT', 0, 30) end)
		else
			_G[ChatMenus[i]]:HookScript('OnShow', function(s) s:SetTemplate('Transparent', true) s:SetBackdropColor(unpack(E.media.backdropfadecolor)) end)
		end
	end

	--LFD Role Picker frame
	local roleButtons = {
		_G.LFDRoleCheckPopupRoleButtonTank,
		_G.LFDRoleCheckPopupRoleButtonDPS,
		_G.LFDRoleCheckPopupRoleButtonHealer,
	}

	_G.LFDRoleCheckPopup:StripTextures()
	_G.LFDRoleCheckPopup:SetTemplate('Transparent')
	S:HandleButton(_G.LFDRoleCheckPopupAcceptButton)
	S:HandleButton(_G.LFDRoleCheckPopupDeclineButton)

	for _, roleButton in pairs(roleButtons) do
		S:HandleCheckBox(roleButton.checkButton or roleButton.CheckButton, true)
		roleButton:DisableDrawLayer('OVERLAY')
	end

	-- reskin popup buttons
	for i = 1, 4 do
		local StaticPopup = _G['StaticPopup'..i]
		StaticPopup:HookScript('OnShow', function() -- UpdateRecapButton is created OnShow
			if StaticPopup.UpdateRecapButton and (not StaticPopup.UpdateRecapButtonHooked) then
				StaticPopup.UpdateRecapButtonHooked = true -- we should only hook this once
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
		_G['StaticPopup'..i..'EditBox'].backdrop:SetPoint('TOPLEFT', -2, -4)
		_G['StaticPopup'..i..'EditBox'].backdrop:SetPoint('BOTTOMRIGHT', 2, 4)
		_G['StaticPopup'..i..'ItemFrameNameFrame']:Kill()
		_G['StaticPopup'..i..'ItemFrame']:SetTemplate()
		_G['StaticPopup'..i..'ItemFrame']:StyleButton()
		_G['StaticPopup'..i..'ItemFrame'].IconBorder:SetAlpha(0)
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetTexCoord(unpack(E.TexCoords))
		_G['StaticPopup'..i..'ItemFrameIconTexture']:SetInside()
		local normTex = _G['StaticPopup'..i..'ItemFrame']:GetNormalTexture()
		if normTex then
			normTex:SetTexture()
			hooksecurefunc(normTex, 'SetTexture', function(s, tex)
				if tex ~= nil then s:SetTexture() end
			end)
		end

		-- Quality IconBorder
		hooksecurefunc(_G['StaticPopup'..i..'ItemFrame'].IconBorder, 'SetVertexColor', function(s, r, g, b)
			s:GetParent():SetBackdropBorderColor(r, g, b)
			s:SetTexture()
		end)
		hooksecurefunc(_G['StaticPopup'..i..'ItemFrame'].IconBorder, 'Hide', function(s)
			s:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
	end

	-- skin return to graveyard button
	do
		_G.GhostFrameMiddle:SetAlpha(0)
		_G.GhostFrameRight:SetAlpha(0)
		_G.GhostFrameLeft:SetAlpha(0)
		_G.GhostFrame:StripTextures()
		_G.GhostFrame:ClearAllPoints()
		_G.GhostFrame:SetPoint('TOP', E.UIParent, 'TOP', 0, -150)
		_G.GhostFrameContentsFrame:SetTemplate('Transparent')
		_G.GhostFrameContentsFrameText:SetPoint('TOPLEFT', 53, 0)
		_G.GhostFrameContentsFrameIcon:SetTexCoord(unpack(E.TexCoords))
		_G.GhostFrameContentsFrameIcon:SetPoint('RIGHT', _G.GhostFrameContentsFrameText, 'LEFT', -12, 0)
		local b = CreateFrame('Frame', nil, _G.GhostFrameContentsFrameIcon:GetParent())
		local p = E.PixelMode and 1 or 2
		b:SetPoint('TOPLEFT', _G.GhostFrameContentsFrameIcon, -p, p)
		b:SetPoint('BOTTOMRIGHT', _G.GhostFrameContentsFrameIcon, p, -p)
		_G.GhostFrameContentsFrameIcon:SetSize(37,38)
		_G.GhostFrameContentsFrameIcon:SetParent(b)
		b:SetTemplate()
	end

	_G.OpacityFrame:StripTextures()
	_G.OpacityFrame:SetTemplate('Transparent')

	--DropDownMenu
	hooksecurefunc('UIDropDownMenu_CreateFrames', function(level, index)
		local listFrame = _G['DropDownList'..level];
		local listFrameName = listFrame:GetName();
		local expandArrow = _G[listFrameName..'Button'..index..'ExpandArrow'];
		if expandArrow then
			local normTex = expandArrow:GetNormalTexture()
			expandArrow:SetNormalTexture(E.Media.Textures.ArrowUp)
			normTex:SetVertexColor(unpack(E.media.rgbvaluecolor))
			normTex:SetRotation(S.ArrowRotation.right)
			expandArrow:SetSize(12, 12)
		end

		local Backdrop = _G[listFrameName..'Backdrop']
		if not Backdrop.template then Backdrop:StripTextures() end
		Backdrop:SetTemplate('Transparent')

		local menuBackdrop = _G[listFrameName..'MenuBackdrop']
		if not menuBackdrop.template then menuBackdrop:StripTextures() end
		menuBackdrop:SetTemplate('Transparent')
	end)

	hooksecurefunc('UIDropDownMenu_SetIconImage', function(icon, texture)
		if texture:find('Divider') then
			local r, g, b = unpack(E.media.rgbvaluecolor)
			icon:SetColorTexture(r, g, b, 0.45)
			icon:SetHeight(1)
		end
	end)

	hooksecurefunc('ToggleDropDownMenu', function(level)
		if ( not level ) then
			level = 1;
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

			button.backdrop:Hide()

			if not button.notCheckable then
				uncheck:SetTexture()
				local _, co = check:GetTexCoord()
				if co == 0 then
					check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
					check:SetVertexColor(r, g, b, 1)
					check:SetSize(20, 20)
					check:SetDesaturated(true)
					button.backdrop:SetInside(check, 4, 4)
				else
					check:SetTexture(E.media.normTex)
					check:SetVertexColor(r, g, b, 1)
					check:SetSize(10, 10)
					check:SetDesaturated(false)
					button.backdrop:SetOutside(check)
				end

				button.backdrop:Show()
				check:SetTexCoord(0, 1, 0, 1)
			else
				check:SetSize(16, 16)
			end
		end
	end)

	local SideDressUpFrame = _G.SideDressUpFrame
	S:HandleCloseButton(_G.SideDressUpFrameCloseButton)
	S:HandleButton(_G.SideDressUpFrame.ResetButton)
	_G.SideDressUpFrame.ResetButton:SetFrameLevel(_G.SideDressUpFrame.ResetButton:GetFrameLevel()+1)
	SideDressUpFrame:StripTextures()
	SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
	SideDressUpFrame:SetTemplate('Transparent')

	-- StackSplit
	local StackSplitFrame = _G.StackSplitFrame
	StackSplitFrame:StripTextures()
	StackSplitFrame:CreateBackdrop('Transparent')

	StackSplitFrame.bg1 = CreateFrame('Frame', nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate('Transparent')
	StackSplitFrame.bg1:SetPoint('TOPLEFT', 10, -15)
	StackSplitFrame.bg1:SetPoint('BOTTOMRIGHT', -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	S:HandleButton(StackSplitFrame.OkayButton)
	S:HandleButton(StackSplitFrame.CancelButton)

	local buttons = {StackSplitFrame.LeftButton, StackSplitFrame.RightButton}
	for _, btn in pairs(buttons) do
		btn:SetSize(14, 18)
		btn:ClearAllPoints()

		if btn == StackSplitFrame.LeftButton then
			btn:SetPoint('LEFT', StackSplitFrame.bg1, 'LEFT', 4, 0)
		else
			btn:SetPoint('RIGHT', StackSplitFrame.bg1, 'RIGHT', -4, 0)
		end

		S:HandleNextPrevButton(btn, nil, nil, true)

		if btn.SetTemplate then
			btn:SetTemplate('NoBackdrop')
		end
	end

	--NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	hooksecurefunc('NavBar_AddButton', SkinNavBarButtons)
end

S:AddCallback('BlizzardMiscFrames')
