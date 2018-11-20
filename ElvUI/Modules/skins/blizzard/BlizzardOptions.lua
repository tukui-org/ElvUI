local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local print = print
local ceil = math.ceil
--WoW API / Variables
local UnitIsUnit = UnitIsUnit
local InCombatLockdown = InCombatLockdown
local GetChannelList = GetChannelList
local IsMacClient = IsMacClient
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CHAT_CONFIG_CHANNEL_LIST, CHAT_CONFIG_CHAT_LEFT, CHANNELS, COMBAT_CONFIG_TABS
-- GLOBALS: COMBAT_CONFIG_UNIT_COLORS, CHAT_CONFIG_CHAT_CREATURE_LEFT
-- GLOBALS: CHAT_CONFIG_OTHER_COMBAT, CHAT_CONFIG_OTHER_PVP, CHAT_CONFIG_OTHER_SYSTEM
-- GLOBALS: COMBAT_CONFIG_MESSAGESOURCES_BY, COMBAT_CONFIG_MESSAGESOURCES_TO

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.BlizzardOptions ~= true then return end

	-- hide header textures and move text/buttons.
	local BlizzardHeader = {
		"InterfaceOptionsFrame",
		"AudioOptionsFrame",
		"VideoOptionsFrame",
	}

	for i = 1, #BlizzardHeader do
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

	for i = 1, #BlizzardButtons do
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
	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameNoButton:ClearAllPoints()
	ReadyCheckFrameYesButton:Point("TOPRIGHT", ReadyCheckFrame, "CENTER", -3, -5)
	ReadyCheckFrameNoButton:Point("TOPLEFT", ReadyCheckFrame, "CENTER", 3, -5)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:Point("TOP", 0, -15)

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
		self:StartMoving()
		self.isMoving = true
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.isMoving = false
	end)

	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		S:HandleCheckBox(MacKeyboardOptionsFrameCheckButton9)
		S:HandleCheckBox(MacKeyboardOptionsFrameCheckButton10)
		S:HandleCheckBox(MacKeyboardOptionsFrameCheckButton11)
	end

	--Chat Config
	local ChatConfigFrame = _G["ChatConfigFrame"]

	hooksecurefunc(ChatConfigFrameChatTabManager, "UpdateWidth", function(self)
		for tab in self.tabPool:EnumerateActive() do
			if not tab.IsSkinned then
				tab:StripTextures()

				tab.IsSkinned = true
			end
		end
	end)

	local StripAllTextures = {
		"ChatConfigFrame",
		"ChatConfigBackgroundFrame",
		"ChatConfigCategoryFrame",
		"ChatConfigChatSettingsLeft",
		"ChatConfigChannelSettingsLeft",
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

	for i = 1, #frames do
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

	for i = 1, #otherframe do
		local SkinFrames = _G[otherframe[i]]
		SkinFrames:ClearAllPoints()
		if SkinFrames == CombatConfigColorsColorizeSpellNames then
			SkinFrames:Point("TOP", CombatConfigColorsColorizeUnitName, "BOTTOM" ,0, -2)
		else
			SkinFrames:Point("TOP", _G[otherframe[i-1]], "BOTTOM", 0, -2)
		end
	end

	-- >> Chat >> Channel Settings
	hooksecurefunc("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable)
		if frame.IsSkinned then return end

		frame:SetBackdrop(nil)
		for index in ipairs(checkBoxTable) do
			local checkBoxName = frame:GetName().."CheckBox"..index
			local checkbox = _G[checkBoxName]

			checkbox:SetBackdrop(nil)
			local bg = CreateFrame("Frame", nil, checkbox)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
			bg:SetFrameLevel(checkbox:GetFrameLevel()-1)
			bg:CreateBackdrop("Default")

			S:HandleCheckBox(_G[checkBoxName.."Check"])
		end

		frame.IsSkinned = true
	end)

	--Makes the skin work, but only after /reload ui :o   (found in chatconfingframe.xml)
	CreateChatChannelList(ChatConfigChannelSettings, GetChannelList())
	ChatConfigBackgroundFrame:SetScript("OnShow", function(self)
		-- >> Chat >> Chat Settings
		for i = 1,#CHAT_CONFIG_CHAT_LEFT do
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:StripTextures()
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:Height(ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
			S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."Check"])
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
		for i = 1, 4 do
			for j = 1, 4 do
				if _G["CombatConfigMessageTypesLeftCheckBox"..i] and _G["CombatConfigMessageTypesLeftCheckBox"..i.."_"..j] then
					S:HandleCheckBox(_G["CombatConfigMessageTypesLeftCheckBox"..i])
					S:HandleCheckBox(_G["CombatConfigMessageTypesLeftCheckBox"..i.."_"..j])
				end
			end
			for j = 1, 10 do
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

	S:HandleNextPrevButton(ChatConfigMoveFilterUpButton, true, true)
	S:HandleNextPrevButton(ChatConfigMoveFilterDownButton, true)
	ChatConfigMoveFilterUpButton:ClearAllPoints()
	ChatConfigMoveFilterDownButton:ClearAllPoints()
	ChatConfigMoveFilterUpButton:Point("TOPLEFT",ChatConfigCombatSettingsFilters,"BOTTOMLEFT",3,0)
	ChatConfigMoveFilterDownButton:Point("LEFT",ChatConfigMoveFilterUpButton,24,0)
	S:HandleEditBox(CombatConfigSettingsNameEditBox)
	ChatConfigFrameHeader:ClearAllPoints()
	ChatConfigFrameHeader:Point("TOP", ChatConfigFrame, 0, -5)

	frames = {
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
		"SocialPanelAutoAcceptQuickJoinRequests",
		-- ActionBars
		"ActionBarsPanelLockActionBars",
		"ActionBarsPanelAlwaysShowActionBars",
		"ActionBarsPanelBottomLeft",
		"ActionBarsPanelBottomRight",
		"ActionBarsPanelRight",
		"ActionBarsPanelRightTwo",
		"ActionBarsPanelStackRightBars",
		"ActionBarsPanelCountdownCooldowns",
		-- Names
		"NamesPanelMyName",
		"NamesPanelNonCombatCreature",
		"NamesPanelFriendlyPlayerNames",
		"NamesPanelFriendlyMinions",
		"NamesPanelEnemyPlayerNames",
		"NamesPanelEnemyMinions",
		-- Nameplates
		"NamesPanelUnitNameplatesMakeLarger",
		"NamesPanelUnitNameplatesEnemies",
		"NamesPanelUnitNameplatesFriends",
		-- Camera
		"CameraPanelWaterCollision",
		-- Mouse
		"MousePanelInvertMouse",
		"MousePanelClickToMove",
		"MousePanelEnableMouseSpeed",
		"MousePanelLockCursorToScreen",
		-- Accessability
		"AccessibilityPanelMovePad",
		"AccessibilityPanelCinematicSubtitles",
		"AccessibilityPanelColorblindMode",
	}

	for i = 1, #interfacecheckbox do
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

	for i = 1, #interfacedropdown do
		local idropdown = _G["InterfaceOptions"..interfacedropdown[i]]
		if idropdown then
			S:HandleDropDownBox(idropdown)
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

	for i = 1, #optioncheckbox do
		local ocheckbox = _G[optioncheckbox[i]]
		if ocheckbox then
			S:HandleCheckBox(ocheckbox)
		end
	end

	local optiondropdown = {
		-- Graphics
		"Display_DisplayModeDropDown",
		"Display_ResolutionDropDown",
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
		"Advanced_GraphicsAPIDropDown",
		"Advanced_ResampleQualityDropDown",
		"Advanced_MultisampleAlphaTest",
		"Advanced_PostProcessAntiAliasingDropDown",
		"Advanced_MultisampleAntiAliasingDropDown",
		"Advanced_PhysicsInteractionDropDown",
		"Advanced_AdapterDropDown",

		-- Audio
		"AudioOptionsSoundPanelHardwareDropDown",
		"AudioOptionsSoundPanelSoundChannelsDropDown",
		"AudioOptionsSoundPanelSoundCacheSizeDropDown",

		-- Raid Profiles
		"CompactUnitFrameProfilesProfileSelector",
		"CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown",
		"CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown",

		-- VoiceChat
		"AudioOptionsVoicePanelOutputDeviceDropdown",
		"AudioOptionsVoicePanelMicDeviceDropdown",
		"AudioOptionsVoicePanelChatModeDropdown",
	}

	for i = 1, #optiondropdown do
		local odropdown = _G[optiondropdown[i]]
		if odropdown then
			S:HandleDropDownBox(odropdown,165)
		else
			print(optiondropdown[i])
		end
	end

	local buttons = {
		"RecordLoopbackSoundButton",
		"PlayLoopbackSoundButton",
		"InterfaceOptionsSocialPanelTwitterLoginButton",
		"InterfaceOptionsDisplayPanelResetTutorials",
		"InterfaceOptionsSocialPanelRedockChat",
	}

	for _, button in pairs(buttons) do
		if _G[button] then
			S:HandleButton(_G[button])
		end
	end

	-- Put back Twitter Birdy (only if your Real ID is enabled in your WoW Account)
	InterfaceOptionsSocialPanel.EnableTwitter.Logo:SetAtlas("WoWShare-TwitterLogo")

	local AudioOptionsVoicePanel = _G["AudioOptionsVoicePanel"]
	local TestInputDevice = AudioOptionsVoicePanel.TestInputDevice

	-- Toggle Test Audio Button - Wow 8.0
	S:HandleButton(TestInputDevice.ToggleTest)

	-- PushToTalk KeybindButton - Wow 8.0
	local function HandlePushToTalkButton(button)
		button:SetSize(button:GetSize())

		button.TopLeft:Hide()
		button.TopRight:Hide()
		button.BottomLeft:Hide()
		button.BottomRight:Hide()
		button.TopMiddle:Hide()
		button.MiddleLeft:Hide()
		button.MiddleRight:Hide()
		button.BottomMiddle:Hide()
		button.MiddleMiddle:Hide()
		button:SetHighlightTexture("")

		button:SetTemplate("Default", true)
		button:HookScript("OnEnter", S.SetModifiedBackdrop)
		button:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	function S.AudioOptionsVoicePanel_InitializeCommunicationModeUI(self)
		HandlePushToTalkButton(self.PushToTalkKeybindButton)
	end
	hooksecurefunc("AudioOptionsVoicePanel_InitializeCommunicationModeUI", S.AudioOptionsVoicePanel_InitializeCommunicationModeUI)

	if CompactUnitFrameProfiles then --Some addons disable the Blizzard addon
		S:HandleCheckBox(CompactUnitFrameProfilesRaidStylePartyFrames)
		S:HandleButton(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
		S:HandleButton(CompactUnitFrameProfilesSaveButton)
		S:HandleButton(CompactUnitFrameProfilesDeleteButton)

		CompactUnitFrameProfilesNewProfileDialog:StripTextures()
		CompactUnitFrameProfilesNewProfileDialog:CreateBackdrop("Transparent")
		S:HandleEditBox(CompactUnitFrameProfilesNewProfileDialogEditBox)
		CompactUnitFrameProfilesNewProfileDialogEditBox:SetSize(150, 20)
		S:HandleDropDownBox(CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector)
		S:HandleButton(CompactUnitFrameProfilesNewProfileDialogCreateButton)
		S:HandleButton(CompactUnitFrameProfilesNewProfileDialogCancelButton)
	end

	GraphicsButton:StripTextures()
	RaidButton:StripTextures()
	local raidcheckbox = {
		"KeepGroupsTogether",
		"HorizontalGroups",
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
		"AutoActivateSpec3",
		"AutoActivateSpec4",
		"AutoActivatePvP",
		"AutoActivatePvE",
	}

	for i = 1, #raidcheckbox do
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
		"Advanced_ContrastSlider",
		"Advanced_BrightnessSlider",
		"Advanced_RenderScaleSlider",
		"Display_RenderScaleSlider",
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
		"CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider",
		"AudioOptionsVoicePanelVoiceChatVolume",
		"AudioOptionsVoicePanelVoiceChatMicVolume",
		"AudioOptionsVoicePanelVoiceChatMicSensitivity",
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

	--What's New
	SplashFrame:CreateBackdrop("Transparent")
	SplashFrame.Header:FontTemplate(nil, 22)
	SplashFrame.RightTitle:FontTemplate(nil, 30)
	S:HandleButton(SplashFrame.BottomCloseButton)
	S:HandleCloseButton(SplashFrame.TopCloseButton)

	-- New Voice Sliders
	S:HandleSliderFrame(UnitPopupVoiceSpeakerVolume.Slider)
	S:HandleSliderFrame(UnitPopupVoiceMicrophoneVolume.Slider)
	S:HandleSliderFrame(UnitPopupVoiceUserVolume.Slider)
end

S:AddCallback("SkinBlizzard", LoadSkin)
