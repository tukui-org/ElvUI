local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local ceil = math.ceil
--WoW API / Variables
local UnitIsUnit = UnitIsUnit
local UIDROPDOWNMENU_MAXLEVELS = UIDROPDOWNMENU_MAXLEVELS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end
	-- Blizzard frame we want to reskin
	local skins = {
		"StaticPopup1",
		"StaticPopup2",
		"StaticPopup3",
		"StaticPopup4",
		"InterfaceOptionsFrame",
		"VideoOptionsFrame",
		"AudioOptionsFrame",
		"BNToastFrame",
		"TicketStatusFrameButton",
		"DropDownList1MenuBackdrop",
		"DropDownList2MenuBackdrop",
		"DropDownList1Backdrop",
		"DropDownList2Backdrop",
		"AutoCompleteBox",
		"ReadyCheckFrame",
		"StackSplitFrame",
		"QueueStatusFrame",
		"LFDReadyCheckPopup",
	}

	QueueStatusFrame:StripTextures()

	for i = 1, getn(skins) do
		_G[skins[i]]:SetTemplate("Transparent")
	end

	if not IsAddOnLoaded("ConsolePort") then
		GameMenuFrame:SetTemplate("Transparent")
	end

	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",
	}
	--
	for i = 1, getn(ChatMenus) do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(E['media'].backdropfadecolor)) self:ClearAllPoints() self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30) end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(E['media'].backdropfadecolor)) end)
		end
	end

	--LFD Role Picker frame
	local roleButtons = {
		LFDRoleCheckPopupRoleButtonTank,
		LFDRoleCheckPopupRoleButtonDPS,
		LFDRoleCheckPopupRoleButtonHealer,
	}

	LFDRoleCheckPopup:StripTextures()
	LFDRoleCheckPopup:SetTemplate("Transparent")
	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	for _, roleButton in pairs(roleButtons) do
		S:HandleCheckBox(roleButton.checkButton or roleButton.CheckButton, true)
		roleButton:DisableDrawLayer("OVERLAY")
	end

	-- reskin popup buttons
	for i = 1, 4 do
		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
			S:HandleEditBox(_G["StaticPopup"..i.."EditBox"])
			S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
			S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
			S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])
			_G["StaticPopup"..i.."EditBox"].backdrop:Point("TOPLEFT", -2, -4)
			_G["StaticPopup"..i.."EditBox"].backdrop:Point("BOTTOMRIGHT", 2, 4)
			_G["StaticPopup"..i.."ItemFrameNameFrame"]:Kill()
			_G["StaticPopup"..i.."ItemFrame"]:GetNormalTexture():Kill()
			_G["StaticPopup"..i.."ItemFrame"]:SetTemplate("Default")
			_G["StaticPopup"..i.."ItemFrame"]:StyleButton()
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(unpack(E.TexCoords))
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetInside()
		end
	end

	if not IsAddOnLoaded("ConsolePort") then
		-- reskin all esc/menu buttons
		local BlizzardMenuButtons = {
			"GameMenuButtonOptions",
			"GameMenuButtonSoundOptions",
			"GameMenuButtonUIOptions",
			"GameMenuButtonKeybindings",
			"GameMenuButtonMacros",
			"GameMenuButtonAddOns",
			"GameMenuButtonWhatsNew",
			"GameMenuButtonRatings",
			"GameMenuButtonAddons",
			"GameMenuButtonLogout",
			"GameMenuButtonQuit",
			"GameMenuButtonContinue",
			"GameMenuButtonMacOptions",
			"GameMenuButtonStore",
			"GameMenuButtonHelp"
		}

		for i = 1, #BlizzardMenuButtons do
			local menuButton = _G[BlizzardMenuButtons[i]]
			if menuButton then
				S:HandleButton(menuButton)
			end
		end

		-- Skin the ElvUI Menu Button
		S:HandleButton(GameMenuFrame.ElvUI)
	end

	if IsAddOnLoaded("OptionHouse") then
		S:HandleButton(GameMenuButtonOptionHouse)
	end

	-- skin return to graveyard button
	do
		S:HandleButton(GhostFrame)
		GhostFrame:SetBackdropColor(0,0,0,0)
		GhostFrame:SetBackdropBorderColor(0,0,0,0)

		local function forceBackdropColor(self, r, g, b, a)
			if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0 then
				GhostFrame:SetBackdropColor(0,0,0,0)
				GhostFrame:SetBackdropBorderColor(0,0,0,0)
			end
		end

		hooksecurefunc(GhostFrame, "SetBackdropColor", forceBackdropColor)
		hooksecurefunc(GhostFrame, "SetBackdropBorderColor", forceBackdropColor)

		GhostFrame:ClearAllPoints()
		GhostFrame:Point("TOP", E.UIParent, "TOP", 0, -270)
		S:HandleButton(GhostFrameContentsFrame)
		GhostFrameContentsFrameIcon:SetTexture(nil)
		local x = CreateFrame("Frame", nil, GhostFrame)
		x:SetFrameStrata("MEDIUM")
		x:SetTemplate("Default")
		x:SetOutside(GhostFrameContentsFrameIcon)
		local tex = x:CreateTexture(nil, "OVERLAY")
		tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
		tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		tex:SetInside()
	end

	-- hide header textures and move text/buttons.
	local BlizzardHeader = {
		"InterfaceOptionsFrame",
		"AudioOptionsFrame",
		"VideoOptionsFrame",
	}

	for i = 1, getn(BlizzardHeader) do
		local title = _G[BlizzardHeader[i].."Header"]
		if title then
			title:SetTexture("")
			title:ClearAllPoints()
			if title == _G["GameMenuFrameHeader"] then
				title:Point("TOP", GameMenuFrame, 0, 7)
			else
				title:Point("TOP", BlizzardHeader[i], 0, 0)
			end
		end
	end

	if not IsAddOnLoaded("ConsolePort") then
		GameMenuFrameHeader:SetTexture("")
		GameMenuFrameHeader:ClearAllPoints()
		GameMenuFrameHeader:Point("TOP", GameMenuFrame, 0, 7)
	end

	-- here we reskin all "normal" buttons
	local BlizzardButtons = {
		"VideoOptionsFrameOkay",
		"VideoOptionsFrameCancel",
		"VideoOptionsFrameDefaults",
		"VideoOptionsFrameApply",
		"AudioOptionsFrameOkay",
		"AudioOptionsFrameCancel",
		"AudioOptionsFrameDefaults",
		"InterfaceOptionsFrameDefaults",
		"InterfaceOptionsFrameOkay",
		"InterfaceOptionsFrameCancel",
		"ReadyCheckFrameYesButton",
		"ReadyCheckFrameNoButton",
		"StackSplitOkayButton",
		"StackSplitCancelButton",
		"RolePollPopupAcceptButton"
	}

	for i = 1, getn(BlizzardButtons) do
		local ElvuiButtons = _G[BlizzardButtons[i]]
		if ElvuiButtons then
			S:HandleButton(ElvuiButtons)
		end
	end
	S:HandleButton(LFDReadyCheckPopup.YesButton)
	S:HandleButton(LFDReadyCheckPopup.NoButton)

	-- if a button position is not really where we want, we move it here
	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:Point("RIGHT",VideoOptionsFrameApply,"LEFT",-4,0)
	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:Point("RIGHT",VideoOptionsFrameCancel,"LEFT",-4,0)
	AudioOptionsFrameOkay:ClearAllPoints()
	AudioOptionsFrameOkay:Point("RIGHT",AudioOptionsFrameCancel,"LEFT",-4,0)
	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:Point("RIGHT",InterfaceOptionsFrameCancel,"LEFT", -4,0)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameYesButton:Point("RIGHT", ReadyCheckFrame, "CENTER", -1, 0)
	ReadyCheckFrameNoButton:Point("LEFT", ReadyCheckFrameYesButton, "RIGHT", 3, 0)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:Point("TOP", 0, -12)

	-- others
	StackSplitFrame:GetRegions():Hide()
	ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript("OnShow", function(self)
		-- bug fix, don't show it if player is initiator
		if self.initiator and UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	RolePollPopup:SetTemplate("Transparent")

	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end

		if IsShiftKeyDown() then
			self:StartMoving()
		end
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		S:HandleDropDownBox(MovieRecordingOptionsFrameResolutionDropDown)
		S:HandleDropDownBox(MovieRecordingOptionsFrameFramerateDropDown)
		S:HandleDropDownBox(MovieRecordingOptionsFrameCodecDropDown)

		S:HandleButton(MovieRecordingOptionsButtonCompress)
		S:HandleSliderFrame(MovieRecordingOptionsFrameQualitySlider)

		for i=1, 6 do
			S:HandleCheckBox(_G["MovieRecordingOptionsFrameCheckButton"..i])
		end

		S:HandleCheckBox(MacKeyboardOptionsFrameCheckButton9)
		S:HandleCheckBox(MacKeyboardOptionsFrameCheckButton10)
		S:HandleCheckBox(MacKeyboardOptionsFrameCheckButton11)
	end

	--PVP QUEUE FRAME
	PVPReadyDialog:StripTextures()
	PVPReadyDialog:SetTemplate("Transparent")
	S:HandleButton(PVPReadyDialogEnterBattleButton)
	S:HandleButton(PVPReadyDialogLeaveQueueButton)
	S:HandleCloseButton(PVPReadyDialogCloseButton)
	PVPReadyDialogRoleIcon.texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	PVPReadyDialogRoleIcon.texture:SetAlpha(0.5)

	hooksecurefunc("PVPReadyDialog_Display", function(self, index, displayName, isRated, queueType, gameType, role)
		if role == "DAMAGER" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
		elseif role == "TANK" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
		elseif role == "HEALER" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
		end

		if queueType == "ARENA" then
			self:Height(100)
		end

		self.background:Hide()
	end)


	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	--[[WatchFrameCollapseExpandButton:StripTextures()
	S:HandleCloseButton(WatchFrameCollapseExpandButton)
	WatchFrameCollapseExpandButton:Size(30)
	WatchFrameCollapseExpandButton.text:SetText('-')
	WatchFrameCollapseExpandButton:SetFrameStrata('MEDIUM')

	hooksecurefunc('WatchFrame_Expand', function()
		WatchFrameCollapseExpandButton.text:SetText('-')
	end)

	hooksecurefunc('WatchFrame_Collapse', function()
		WatchFrameCollapseExpandButton.text:SetText('+')
	end)]]

	--Chat Config
	local StripAllTextures = {
		"ChatConfigFrame",
		"ChatConfigBackgroundFrame",
		"ChatConfigCategoryFrame",
		"ChatConfigChatSettingsClassColorLegend",
		"ChatConfigChatSettingsLeft",
		"ChatConfigChannelSettingsLeft",
		"ChatConfigChannelSettingsClassColorLegend",
		"ChatConfigOtherSettingsCombat",
		"ChatConfigOtherSettingsPVP",
		"ChatConfigOtherSettingsSystem",
		"ChatConfigOtherSettingsCreature",
		"ChatConfigCombatSettingsFilters",
		"CombatConfigMessageSourcesDoneBy",
		"CombatConfigMessageSourcesDoneTo",
		"CombatConfigColorsUnitColors",
		"CombatConfigColorsHighlighting",
		"CombatConfigColorsColorizeUnitName",
		"CombatConfigColorsColorizeSpellNames",
		"CombatConfigColorsColorizeDamageNumber",
		"CombatConfigColorsColorizeDamageSchool",
		"CombatConfigColorsColorizeEntireLine",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	ChatConfigFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent")
	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent")

	local chatbuttons = {
		"ChatConfigFrameDefaultButton",
		"ChatConfigFrameRedockButton",
		"ChatConfigFrameOkayButton",
		"CombatLogDefaultButton",
		"ChatConfigCombatSettingsFiltersCopyFilterButton",
		"ChatConfigCombatSettingsFiltersAddFilterButton",
		"ChatConfigCombatSettingsFiltersDeleteButton",
		"CombatConfigSettingsSaveButton",
		"ChatConfigFrameCancelButton",
	}

	for i = 1, #chatbuttons do
		S:HandleButton(_G[chatbuttons[i]], true)
	end

	ChatConfigFrameDefaultButton:ClearAllPoints()
	ChatConfigFrameDefaultButton:Point("TOPLEFT",ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
	ChatConfigFrameRedockButton:ClearAllPoints()
	ChatConfigFrameRedockButton:Point("LEFT", ChatConfigFrameDefaultButton, "RIGHT", 1, 0)
	CombatLogDefaultButton:ClearAllPoints()
	CombatLogDefaultButton:Point("TOPLEFT",ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
	ChatConfigFrameOkayButton:ClearAllPoints()
	ChatConfigFrameOkayButton:Point("RIGHT", ChatConfigFrameCancelButton, "RIGHT", -11, -1)
	ChatConfigCombatSettingsFiltersDeleteButton:ClearAllPoints()
	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:ClearAllPoints()
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:ClearAllPoints()
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	for i=1, 5 do
		local tab = _G["CombatConfigTab"..i]
		tab:StripTextures()
	end

	S:HandleEditBox(CombatConfigSettingsNameEditBox)

	local frames = {
		"ChatConfigFrame",
		"ChatConfigCategoryFrame",
		"ChatConfigBackgroundFrame",
		"ChatConfigChatSettingsClassColorLegend",
		"ChatConfigChannelSettingsClassColorLegend",
		"ChatConfigCombatSettingsFilters",
		"ChatConfigCombatSettingsFiltersScrollFrame",
		"CombatConfigColorsHighlighting",
		"CombatConfigColorsColorizeUnitName",
		"CombatConfigColorsColorizeSpellNames",
		"CombatConfigColorsColorizeDamageNumber",
		"CombatConfigColorsColorizeDamageSchool",
		"CombatConfigColorsColorizeEntireLine",
		"ChatConfigChatSettingsLeft",
		"ChatConfigOtherSettingsCombat",
		"ChatConfigOtherSettingsPVP",
		"ChatConfigOtherSettingsSystem",
		"ChatConfigOtherSettingsCreature",
		"ChatConfigChannelSettingsLeft",
		"CombatConfigMessageSourcesDoneBy",
		"CombatConfigMessageSourcesDoneTo",
		"CombatConfigColorsUnitColors",
	}

	for i = 1, getn(frames) do
		local SkinFrames = _G[frames[i]]
		SkinFrames:StripTextures()
		SkinFrames:SetTemplate("Transparent")
	end

	local otherframe = {
		"CombatConfigColorsColorizeSpellNames",
		"CombatConfigColorsColorizeDamageNumber",
		"CombatConfigColorsColorizeDamageSchool",
		"CombatConfigColorsColorizeEntireLine",
	}

	for i = 1, getn(otherframe) do
		local SkinFrames = _G[otherframe[i]]
		SkinFrames:ClearAllPoints()
		if SkinFrames == CombatConfigColorsColorizeSpellNames then
			SkinFrames:Point("TOP",CombatConfigColorsColorizeUnitName,"BOTTOM",0,-2)
		else
			SkinFrames:Point("TOP",_G[otherframe[i-1]],"BOTTOM",0,-2)
		end
	end

	-- >> Chat >> Channel Settings      /!\ I don't know why, but the skin works only after /reload ui, not at first login =(
	ChatConfigChannelSettingsLeft:RegisterEvent("PLAYER_ENTERING_WORLD")
	ChatConfigChannelSettingsLeft:SetScript("OnEvent", function(self, event)
		ChatConfigChannelSettingsLeft:UnregisterEvent("PLAYER_ENTERING_WORLD")
		for i = 1,#ChatConfigChannelSettingsLeft.checkBoxTable do
			_G["ChatConfigChannelSettingsLeftCheckBox"..i]:StripTextures()
			_G["ChatConfigChannelSettingsLeftCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigChannelSettingsLeftCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigChannelSettingsLeftCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			_G["ChatConfigChannelSettingsLeftCheckBox"..i]:Height(ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
			S:HandleCheckBox(_G["ChatConfigChannelSettingsLeftCheckBox"..i.."Check"])
			S:HandleCheckBox(_G["ChatConfigChannelSettingsLeftCheckBox"..i.."ColorClasses"])
			_G["ChatConfigChannelSettingsLeftCheckBox"..i.."ColorClasses"]:Height(ChatConfigChatSettingsLeftCheckBox1Check:GetHeight())
		end
	end)

	--Makes the skin work, but only after /reload ui :o   (found in chatconfingframe.xml)
	CreateChatChannelList(self, GetChannelList())
	ChatConfig_CreateCheckboxes(ChatConfigChannelSettingsLeft, CHAT_CONFIG_CHANNEL_LIST, "ChatConfigCheckBoxWithSwatchAndClassColorTemplate", CHANNELS)
	ChatConfig_UpdateCheckboxes(ChatConfigChannelSettingsLeft)
	ChatConfigBackgroundFrame:SetScript("OnShow", function(self)
		-- >> Chat >> Chat Settings
		for i = 1,#CHAT_CONFIG_CHAT_LEFT do
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:StripTextures()
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:Height(ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
			S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."Check"])
			S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."ColorClasses"])
			_G["ChatConfigChatSettingsLeftCheckBox"..i.."ColorClasses"]:Height(ChatConfigChatSettingsLeftCheckBox1Check:GetHeight())
		end
		-- >> Other >> Combat
		for i = 1,#CHAT_CONFIG_OTHER_COMBAT do
			_G["ChatConfigOtherSettingsCombatCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsCombatCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsCombatCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsCombatCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsCombatCheckBox"..i.."Check"])
		end
		-- >> Other >> PvP
		for i = 1,#CHAT_CONFIG_OTHER_PVP do
			_G["ChatConfigOtherSettingsPVPCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsPVPCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsPVPCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsPVPCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsPVPCheckBox"..i.."Check"])
		end
		-- >> Other >> System
		for i = 1,#CHAT_CONFIG_OTHER_SYSTEM do
			_G["ChatConfigOtherSettingsSystemCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsSystemCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsSystemCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsSystemCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsSystemCheckBox"..i.."Check"])
		end
		-- >> Other >> Creatures
		for i = 1,#CHAT_CONFIG_CHAT_CREATURE_LEFT do
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsCreatureCheckBox"..i.."Check"])
		end
		-- >> Sources >> DoneBy
		for i = 1,#COMBAT_CONFIG_MESSAGESOURCES_BY do
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i]:StripTextures()
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i]:CreateBackdrop()
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["CombatConfigMessageSourcesDoneByCheckBox"..i.."Check"])
		end
		-- >> Sources >> DoneTo
		for i = 1,#COMBAT_CONFIG_MESSAGESOURCES_TO do
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i]:StripTextures()
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i]:CreateBackdrop()
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["CombatConfigMessageSourcesDoneToCheckBox"..i.."Check"])
		end
		-- >> Combat >> Colors >> Unit Colors
		for i = 1,#COMBAT_CONFIG_UNIT_COLORS do
			_G["CombatConfigColorsUnitColorsSwatch"..i]:StripTextures()
			_G["CombatConfigColorsUnitColorsSwatch"..i]:CreateBackdrop()
			_G["CombatConfigColorsUnitColorsSwatch"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["CombatConfigColorsUnitColorsSwatch"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
		end
		-- >> Combat >> Messages Types
		for i=1,4 do
			for j=1,4 do
				if _G["CombatConfigMessageTypesLeftCheckBox"..i] and _G["CombatConfigMessageTypesLeftCheckBox"..i.."_"..j] then
					S:HandleCheckBox(_G["CombatConfigMessageTypesLeftCheckBox"..i])
					S:HandleCheckBox(_G["CombatConfigMessageTypesLeftCheckBox"..i.."_"..j])
				end
			end
			for j=1,10 do
				if _G["CombatConfigMessageTypesRightCheckBox"..i] and _G["CombatConfigMessageTypesRightCheckBox"..i.."_"..j] then
					S:HandleCheckBox(_G["CombatConfigMessageTypesRightCheckBox"..i])
					S:HandleCheckBox(_G["CombatConfigMessageTypesRightCheckBox"..i.."_"..j])
				end
			end
			S:HandleCheckBox(_G["CombatConfigMessageTypesMiscCheckBox"..i])
		end
	end)

-- >> Combat >> Tabs
	for i = 1,#COMBAT_CONFIG_TABS do
		local cctab = _G["CombatConfigTab"..i]
		if cctab then
			S:HandleTab(cctab)
			cctab:Height(cctab:GetHeight()-2)
			cctab:Width(ceil(cctab:GetWidth()+1.6))
			_G["CombatConfigTab"..i.."Text"]:Point("BOTTOM",0,10)
		end
	end
	CombatConfigTab1:ClearAllPoints()
	CombatConfigTab1:Point("BOTTOMLEFT",ChatConfigBackgroundFrame,"TOPLEFT",6,-2)

   local cccheckbox = {
		"CombatConfigColorsHighlightingLine",
		"CombatConfigColorsHighlightingAbility",
		"CombatConfigColorsHighlightingDamage",
		"CombatConfigColorsHighlightingSchool",
		"CombatConfigColorsColorizeUnitNameCheck",
		"CombatConfigColorsColorizeSpellNamesCheck",
		"CombatConfigColorsColorizeSpellNamesSchoolColoring",
		"CombatConfigColorsColorizeDamageNumberCheck",
		"CombatConfigColorsColorizeDamageNumberSchoolColoring",
		"CombatConfigColorsColorizeDamageSchoolCheck",
		"CombatConfigColorsColorizeEntireLineCheck",
		"CombatConfigFormattingShowTimeStamp",
		"CombatConfigFormattingShowBraces",
		"CombatConfigFormattingUnitNames",
		"CombatConfigFormattingSpellNames",
		"CombatConfigFormattingItemNames",
		"CombatConfigFormattingFullText",
		"CombatConfigSettingsShowQuickButton",
		"CombatConfigSettingsSolo",
		"CombatConfigSettingsParty",
		"CombatConfigSettingsRaid",
	}
	for i = 1, #cccheckbox do
		local ccbtn = _G[cccheckbox[i]]
		S:HandleCheckBox(ccbtn)
	end

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true)
	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true)
	ChatConfigMoveFilterUpButton:ClearAllPoints()
	ChatConfigMoveFilterDownButton:ClearAllPoints()
	ChatConfigMoveFilterUpButton:Point("TOPLEFT",ChatConfigCombatSettingsFilters,"BOTTOMLEFT",3,0)
	ChatConfigMoveFilterDownButton:Point("LEFT",ChatConfigMoveFilterUpButton,24,0)
	S:HandleEditBox(CombatConfigSettingsNameEditBox)
	ChatConfigFrame:Size(680,596)
	ChatConfigFrameHeader:ClearAllPoints()
	ChatConfigFrameHeader:Point("TOP", ChatConfigFrame, 0, -5)

	--DROPDOWN MENU
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Transparent")
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Transparent")
		end
	end)

	GuildInviteFrame:StripTextures()
	GuildInviteFrame:SetTemplate('Transparent')
	GuildInviteFrame.Points:ClearAllPoints()
	GuildInviteFrame.Points:Point('TOP', GuildInviteFrame, 'CENTER', 15, -25)
	S:HandleButton(GuildInviteFrameJoinButton)
	S:HandleButton(GuildInviteFrameDeclineButton)
	GuildInviteFrame:Height(225)
	GuildInviteFrame:HookScript("OnEvent", function()
		GuildInviteFrame:Height(225)
	end)
	GuildInviteFrameWarningText:Kill()

	--[[local function SkinWatchFrameItems()
		for i=1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i]
			if not button.skinned then
				button:CreateBackdrop('Default')
				button.backdrop:SetAllPoints()
				button:StyleButton()
				_G["WatchFrameItem"..i.."NormalTexture"]:SetAlpha(0)
				_G["WatchFrameItem"..i.."IconTexture"]:SetInside()
				_G["WatchFrameItem"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				E:RegisterCooldown(_G["WatchFrameItem"..i.."Cooldown"])
				button.skinned = true
			end
		end
	end

	WatchFrame:HookScript("OnEvent", SkinWatchFrameItems)]]

	BattleTagInviteFrame:StripTextures()
	BattleTagInviteFrame:SetTemplate('Transparent')
	--S:HandleEditBox(BattleTagInviteFrameScrollFrame)
	for i=1, BattleTagInviteFrame:GetNumChildren() do
		local child = select(i, BattleTagInviteFrame:GetChildren())
		if child:GetObjectType() == 'Button' then
			S:HandleButton(child)
		end
	end

	local frames = {
		"VideoOptionsFrameCategoryFrame",
		"VideoOptionsFramePanelContainer",
		"InterfaceOptionsFrameCategories",
		"InterfaceOptionsFramePanelContainer",
		"InterfaceOptionsFrameAddOns",
		"AudioOptionsSoundPanelPlayback",
		"AudioOptionsSoundPanelVolume",
		"AudioOptionsSoundPanelHardware",
		"AudioOptionsVoicePanelTalking",
		"AudioOptionsVoicePanelBinding",
		"AudioOptionsVoicePanelListening",
		"Display_",
		"Graphics_",
		"RaidGraphics_",
	}
	for i = 1, #frames do
		local SkinFrames = _G[frames[i]]
		if SkinFrames then
			SkinFrames:StripTextures()
			SkinFrames:CreateBackdrop("Transparent")
			if SkinFrames ~= _G["VideoOptionsFramePanelContainer"] and SkinFrames ~= _G["InterfaceOptionsFramePanelContainer"] then
				SkinFrames.backdrop:Point("TOPLEFT",-1,0)
				SkinFrames.backdrop:Point("BOTTOMRIGHT",0,1)
			else
				SkinFrames.backdrop:Point("TOPLEFT", 0, 0)
				SkinFrames.backdrop:Point("BOTTOMRIGHT", 0, 0)
			end
		end
	end
	local interfacetab = {
		"InterfaceOptionsFrameTab1",
		"InterfaceOptionsFrameTab2",
	}
	for i = 1, #interfacetab do
		local itab = _G[interfacetab[i]]
		if itab then
			itab:StripTextures()
			S:HandleTab(itab)
			itab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -4 or -6)
		end
	end
	InterfaceOptionsFrameTab1:ClearAllPoints()
	InterfaceOptionsFrameTab1:Point("BOTTOMLEFT",InterfaceOptionsFrameCategories,"TOPLEFT",-11,-2)
	VideoOptionsFrameDefaults:ClearAllPoints()
	InterfaceOptionsFrameDefaults:ClearAllPoints()
	InterfaceOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameDefaults:Point("TOPLEFT",VideoOptionsFrameCategoryFrame,"BOTTOMLEFT",-1,-5)
	InterfaceOptionsFrameDefaults:Point("TOPLEFT",InterfaceOptionsFrameCategories,"BOTTOMLEFT",-1,-5)
	InterfaceOptionsFrameCancel:Point("TOPRIGHT",InterfaceOptionsFramePanelContainer,"BOTTOMRIGHT",0,-6)

	local interfacecheckbox = {
		-- Controls
		"ControlsPanelStickyTargeting",
		"ControlsPanelAutoDismount",
		"ControlsPanelAutoClearAFK",
		"ControlsPanelLootAtMouse",
		"ControlsPanelAutoLootCorpse",
		"ControlsPanelInteractOnLeftClick",
		-- Combat
		"CombatPanelTargetOfTarget",
		"CombatPanelFlashLowHealthWarning",
		"CombatPanelAutoSelfCast",
		"CombatPanelLossOfControl",
		"CombatPanelEnableFloatingCombatText",
		-- Display
		"DisplayPanelRotateMinimap",
		"DisplayPanelAJAlerts",
		"DisplayPanelShowTutorials",
		-- Social
		"SocialPanelBlockTrades",
		"SocialPanelBlockGuildInvites",
		"SocialPanelBlockChatChannelInvites",
		"SocialPanelShowAccountAchievments",
		"SocialPanelOnlineFriends",
		"SocialPanelOfflineFriends",
		"SocialPanelBroadcasts",
		"SocialPanelFriendRequests",
		"SocialPanelShowToastWindow",
		"SocialPanelGuildMemberAlert",
		"SocialPanelProfanityFilter",
		"SocialPanelSpamFilter",
		"SocialPanelEnableTwitter",
		-- ActionBars
		"ActionBarsPanelLockActionBars",
		"ActionBarsPanelAlwaysShowActionBars",
		"ActionBarsPanelBottomLeft",
		"ActionBarsPanelBottomRight",
		"ActionBarsPanelRight",
		"ActionBarsPanelRightTwo",
		"ActionBarsPanelCountdownCooldowns",
		-- Names
		"NamesPanelMyName",
		"NamesPanelNonCombatCreature",
		"NamesPanelFriendlyPlayerNames",
		"NamesPanelFriendlyMinions",
		"NamesPanelEnemyPlayerNames",
		"NamesPanelEnemyMinions",
		-- Camera
		"CameraPanelWaterCollision",
		-- Mouse
		"MousePanelInvertMouse",
		"MousePanelClickToMove",
		"MousePanelEnableMouseSpeed",
		-- Accessability
		"AccessibilityPanelMovePad",
		"AccessibilityPanelCinematicSubtitles",
		"AccessibilityPanelColorblindMode",
	}

	for i = 1, getn(interfacecheckbox) do
		local icheckbox = _G["InterfaceOptions"..interfacecheckbox[i]]
		if icheckbox then
			S:HandleCheckBox(icheckbox)
		 else
			print(interfacecheckbox[i])
		end
	end

	local interfacedropdown ={
		-- Controls
		"ControlsPanelAutoLootKeyDropDown",
		-- Combat
		"CombatPanelFocusCastKeyDropDown",
		"CombatPanelSelfCastKeyDropDown",
		-- Display
		"DisplayPanelSelfHighlightDropDown",
		"DisplayPanelDisplayDropDown",
		"DisplayPanelChatBubblesDropDown",
		-- Social
		"SocialPanelWhisperMode",
		"SocialPanelTimestamps",
		"SocialPanelChatStyle",
		-- Action bars
		"ActionBarsPanelPickupActionKeyDropDown",
		-- Names
		"NamesPanelNPCNamesDropDown",
		"NamesPanelUnitNameplatesMotionDropDown",
		-- Camera
		"CameraPanelStyleDropDown",
		-- Mouse
		"MousePanelClickMoveStyleDropDown",
		-- Language
		"LanguagesPanelLocaleDropDown",
		"LanguagesPanelAudioLocaleDropDown",
		-- Assessability
		"AccessibilityPanelColorFilterDropDown",
	}

	for i = 1, getn(interfacedropdown) do
		local idropdown = _G["InterfaceOptions"..interfacedropdown[i]]
		if idropdown then
			S:HandleDropDownBox(idropdown)
			DropDownList1:SetTemplate("Transparent")
		else
			print(interfacedropdown[i])
		end
	end

	-- Display
	S:HandleDropDownBox(InterfaceOptionsDisplayPanelOutlineDropDown, 210)
	local optioncheckbox = {
		-- Display
		"Display_RaidSettingsEnabledCheckBox",
		-- Advanced
		"Advanced_MaxFPSCheckBox",
		"Advanced_MaxFPSBKCheckBox",
		"Advanced_UseUIScale",
		"Advanced_ShowHDModels",
		"Advanced_DesktopGamma",
		--Network
		"NetworkOptionsPanelAdvancedCombatLogging",
		-- Audio
		"AudioOptionsSoundPanelEnableSound",
		"AudioOptionsSoundPanelSoundEffects",
		"AudioOptionsSoundPanelErrorSpeech",
		"AudioOptionsSoundPanelEmoteSounds",
		"AudioOptionsSoundPanelPetSounds",
		"AudioOptionsSoundPanelMusic",
		"AudioOptionsSoundPanelLoopMusic",
		"AudioOptionsSoundPanelAmbientSounds",
		"AudioOptionsSoundPanelSoundInBG",
		"AudioOptionsSoundPanelReverb",
		"AudioOptionsSoundPanelHRTF",
		"AudioOptionsSoundPanelEnableDSPs",
		"AudioOptionsSoundPanelUseHardware",
		"AudioOptionsVoicePanelEnableVoice",
		"AudioOptionsVoicePanelEnableMicrophone",
		"AudioOptionsVoicePanelPushToTalkSound",
		"AudioOptionsSoundPanelPetBattleMusic",
		"AudioOptionsSoundPanelDialogSounds",

		-- Network
		"NetworkOptionsPanelOptimizeSpeed",
		"NetworkOptionsPanelUseIPv6",
	}
	for i = 1, getn(optioncheckbox) do
		local ocheckbox = _G[optioncheckbox[i]]
		if ocheckbox then
			S:HandleCheckBox(ocheckbox)
		end
	end
	local optiondropdown = {
		-- Graphics
		"Display_DisplayModeDropDown",
		"Display_ResolutionDropDown",
		"Display_RefreshDropDown",
		"Display_PrimaryMonitorDropDown",
		"Display_AntiAliasingDropDown",
		"Display_VerticalSyncDropDown",
		"Graphics_TextureResolutionDropDown",
		"Graphics_FilteringDropDown",
		"Graphics_ProjectedTexturesDropDown",
		"Graphics_ShadowsDropDown",
		"Graphics_LiquidDetailDropDown",
		"Graphics_SunshaftsDropDown",
		"Graphics_ParticleDensityDropDown",
		"Graphics_SSAODropDown",
		"Graphics_DepthEffectsDropDown",
		"Graphics_LightingQualityDropDown",
		"Graphics_OutlineModeDropDown",

		"RaidGraphics_TextureResolutionDropDown",
		"RaidGraphics_FilteringDropDown",
		"RaidGraphics_ProjectedTexturesDropDown",
		"RaidGraphics_ShadowsDropDown",
		"RaidGraphics_LiquidDetailDropDown",
		"RaidGraphics_SunshaftsDropDown",
		"RaidGraphics_ParticleDensityDropDown",
		"RaidGraphics_SSAODropDown",
		"RaidGraphics_DepthEffectsDropDown",
		"RaidGraphics_LightingQualityDropDown",
		"RaidGraphics_OutlineModeDropDown",

		-- Advanced
		"Advanced_BufferingDropDown",
		"Advanced_LagDropDown",
		"Advanced_HardwareCursorDropDown",
		"Advanced_GraphicsAPIDropDown",
		"Advanced_ResampleQualityDropDown",
		"Advanced_MultisampleAlphaTest",
		"Advanced_PostProcessAntiAliasingDropDown",
		"Advanced_MultisampleAntiAliasingDropDown",
		"Advanced_PhysicsInteractionDropDown",

		-- Audio
		"AudioOptionsSoundPanelHardwareDropDown",
		"AudioOptionsSoundPanelSoundChannelsDropDown",
		"AudioOptionsSoundPanelSoundCacheSizeDropDown",
		"AudioOptionsVoicePanelInputDeviceDropDown",
		"AudioOptionsVoicePanelChatModeDropDown",
		"AudioOptionsVoicePanelOutputDeviceDropDown",

		-- Raid Profiles
		"CompactUnitFrameProfilesProfileSelector",
		"CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown",
		"CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown",
	}
	for i = 1, getn(optiondropdown) do
		local odropdown = _G[optiondropdown[i]]
		if odropdown then
			S:HandleDropDownBox(odropdown,165)
			DropDownList1:SetTemplate("Transparent")
		else
			print(optiondropdown[i])
		end
	end
	local buttons = {
		"RecordLoopbackSoundButton",
		"PlayLoopbackSoundButton",
		"AudioOptionsVoicePanelChatMode1KeyBindingButton",
		"InterfaceOptionsSocialPanelTwitterLoginButton",
		"InterfaceOptionsDisplayPanelResetTutorials",
		"InterfaceOptionsSocialPanelRedockChat"
	}
	for _, button in pairs(buttons) do
		if _G[button] then
			S:HandleButton(_G[button])
		end
	end
	AudioOptionsVoicePanelChatMode1KeyBindingButton:ClearAllPoints()
	AudioOptionsVoicePanelChatMode1KeyBindingButton:Point("CENTER", AudioOptionsVoicePanelBinding, "CENTER", 0, -10)
	if CompactUnitFrameProfiles then --Some addons disable the Blizzard addon
		S:HandleCheckBox(CompactUnitFrameProfilesRaidStylePartyFrames)
		S:HandleButton(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
		S:HandleButton(CompactUnitFrameProfilesSaveButton)
		S:HandleButton(CompactUnitFrameProfilesDeleteButton)
	end
	GraphicsButton:StripTextures()
	RaidButton:StripTextures()
	local raidcheckbox = {
		"KeepGroupsTogether",
		"DisplayIncomingHeals",
		"DisplayPowerBar",
		"DisplayAggroHighlight",
		"UseClassColors",
		"DisplayPets",
		"DisplayMainTankAndAssist",
		"DisplayBorder",
		"ShowDebuffs",
		"DisplayOnlyDispellableDebuffs",
		"AutoActivate2Players",
		"AutoActivate3Players",
		"AutoActivate5Players",
		"AutoActivate10Players",
		"AutoActivate15Players",
		"AutoActivate25Players",
		"AutoActivate40Players",
		"AutoActivateSpec1",
		"AutoActivateSpec2",
		"AutoActivatePvP",
		"AutoActivatePvE",
	}
	for i = 1, getn(raidcheckbox) do
		local icheckbox = _G["CompactUnitFrameProfilesGeneralOptionsFrame"..raidcheckbox[i]]
		if icheckbox then
			S:HandleCheckBox(icheckbox)
			icheckbox:SetFrameLevel(40)
		end
	end

	local sliders = {
		"Graphics_Quality",
		"Graphics_ViewDistanceSlider",
		"Graphics_EnvironmentalDetailSlider",
		"Graphics_GroundClutterSlider",
		"RaidGraphics_Quality",
		"RaidGraphics_EnvironmentalDetailSlider",
		"RaidGraphics_GroundClutterSlider",
		"RaidGraphics_ViewDistanceSlider",
		"Advanced_UIScaleSlider",
		"Advanced_MaxFPSSlider",
		"Advanced_MaxFPSBKSlider",
		"Advanced_RenderScaleSlider",
		"Advanced_GammaSlider",
		"AudioOptionsSoundPanelMasterVolume",
		"AudioOptionsSoundPanelSoundVolume",
		"AudioOptionsSoundPanelMusicVolume",
		"AudioOptionsSoundPanelAmbienceVolume",
		"AudioOptionsVoicePanelMicrophoneVolume",
		"AudioOptionsVoicePanelSpeakerVolume",
		"AudioOptionsVoicePanelSoundFade",
		"AudioOptionsVoicePanelMusicFade",
		"AudioOptionsVoicePanelAmbienceFade",
		"AudioOptionsSoundPanelDialogVolume",
		"InterfaceOptionsCombatPanelSpellAlertOpacitySlider",
		"InterfaceOptionsCameraPanelMaxDistanceSlider",
		"InterfaceOptionsCameraPanelFollowSpeedSlider",
		"InterfaceOptionsMousePanelMouseSensitivitySlider",
		"InterfaceOptionsMousePanelMouseLookSpeedSlider",
		"InterfaceOptionsAccessibilityPanelColorblindStrengthSlider",
		"OpacityFrameSlider",
		"CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider",
		"CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider"
	}

	for i = 1, #sliders do
		local slider = _G[sliders[i]]
		if slider then
			S:HandleSliderFrame(slider)
		end
	end

	-- mac option
	--[[MacOptionsFrame:StripTextures()
	MacOptionsFrame:SetTemplate()
	S:HandleButton(MacOptionsButtonCompress)
	S:HandleButton(MacOptionsButtonKeybindings)
	S:HandleButton(MacOptionsFrameDefaults)
	S:HandleButton(MacOptionsFrameOkay)
	S:HandleButton(MacOptionsFrameCancel)
	MacOptionsFrameMovieRecording:StripTextures()
	MacOptionsITunesRemote:StripTextures()
	MacOptionsFrameMisc:StripTextures()


	S:HandleDropDownBox(MacOptionsFrameResolutionDropDown)
	S:HandleDropDownBox(MacOptionsFrameFramerateDropDown)
	S:HandleDropDownBox(MacOptionsFrameCodecDropDown)
	S:HandleSliderFrame(MacOptionsFrameQualitySlider)

	for i = 1, 11 do
		local b = _G["MacOptionsFrameCheckButton"..i]
		S:HandleCheckBox(b)
	end

	MacOptionsButtonKeybindings:ClearAllPoints()
	MacOptionsButtonKeybindings:Point("LEFT", MacOptionsFrameDefaults, "RIGHT", 2, 0)
	MacOptionsFrameOkay:ClearAllPoints()
	MacOptionsFrameOkay:Point("LEFT", MacOptionsButtonKeybindings, "RIGHT", 2, 0)
	MacOptionsFrameCancel:ClearAllPoints()
	MacOptionsFrameCancel:Point("LEFT", MacOptionsFrameOkay, "RIGHT", 2, 0)
	MacOptionsFrameCancel:Width(MacOptionsFrameCancel:GetWidth() - 6)]]

	ReportCheatingDialog:StripTextures()
	ReportCheatingDialogCommentFrame:StripTextures()
	S:HandleButton(ReportCheatingDialogReportButton)
	S:HandleButton(ReportCheatingDialogCancelButton)
	ReportCheatingDialog:SetTemplate("Transparent")
	S:HandleEditBox(ReportCheatingDialogCommentFrameEditBox)

	ReportPlayerNameDialog:StripTextures()
	ReportPlayerNameDialogCommentFrame:StripTextures()
	S:HandleEditBox(ReportPlayerNameDialogCommentFrameEditBox)
	ReportPlayerNameDialog:SetTemplate("Transparent")
	S:HandleButton(ReportPlayerNameDialogReportButton)
	S:HandleButton(ReportPlayerNameDialogCancelButton)

	S:HandleCloseButton(SideDressUpModelCloseButton)
	SideDressUpFrame:StripTextures()
	SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
	S:HandleButton(SideDressUpModelResetButton)
	SideDressUpFrame:SetTemplate("Transparent")

	--What's New
	SplashFrame:CreateBackdrop("Transparent")
	S:HandleButton(SplashFrame.BottomCloseButton)
	S:HandleCloseButton(SplashFrame.TopCloseButton)

	--NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	local function SkinNavBarButtons(self)
		if (self:GetParent():GetName() == "EncounterJournal" and not E.private.skins.blizzard.encounterjournal) or (self:GetParent():GetName() == "WorldMapFrame" and not E.private.skins.blizzard.worldmap) or (self:GetParent():GetName() == "HelpFrameKnowledgebase" and not E.private.skins.blizzard.help) then
			return
		end
		local navButton = self.navList[#self.navList]
		if navButton and not navButton.isSkinned then
			S:HandleButton(navButton, true)
			if navButton.MenuArrowButton then
				S:HandleNextPrevButton(navButton.MenuArrowButton, true)
			end

			navButton.isSkinned = true
		end
	end
	hooksecurefunc("NavBar_AddButton", SkinNavBarButtons)
end

S:AddCallback("Misc", LoadSkin)