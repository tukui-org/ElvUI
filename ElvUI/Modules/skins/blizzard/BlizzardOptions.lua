local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs = ipairs
local pairs = pairs
local print = print
local ceil = math.ceil
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local InCombatLockdown = InCombatLockdown
local CreateChatChannelList = CreateChatChannelList
local GetChannelList = GetChannelList
local IsMacClient = IsMacClient

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

function S.AudioOptionsVoicePanel_InitializeCommunicationModeUI(btn)
	HandlePushToTalkButton(btn.PushToTalkKeybindButton)
end

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
			if title == _G.GameMenuFrameHeader then
				title:Point("TOP", _G.GameMenuFrame, 0, 7)
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
	S:HandleButton(_G.LFDReadyCheckPopup.YesButton)
	S:HandleButton(_G.LFDReadyCheckPopup.NoButton)

	-- if a button position is not really where we want, we move it here
	_G.VideoOptionsFrameCancel:ClearAllPoints()
	_G.VideoOptionsFrameCancel:Point("RIGHT",_G.VideoOptionsFrameApply,"LEFT",-4,0)
	_G.VideoOptionsFrameOkay:ClearAllPoints()
	_G.VideoOptionsFrameOkay:Point("RIGHT",_G.VideoOptionsFrameCancel,"LEFT",-4,0)
	_G.AudioOptionsFrameOkay:ClearAllPoints()
	_G.AudioOptionsFrameOkay:Point("RIGHT",_G.AudioOptionsFrameCancel,"LEFT",-4,0)
	_G.InterfaceOptionsFrameOkay:ClearAllPoints()
	_G.InterfaceOptionsFrameOkay:Point("RIGHT",_G.InterfaceOptionsFrameCancel,"LEFT", -4,0)

	local ReadyCheckFrame = _G.ReadyCheckFrame
	_G.ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameYesButton:ClearAllPoints()
	_G.ReadyCheckFrameNoButton:ClearAllPoints()
	_G.ReadyCheckFrameYesButton:Point("TOPRIGHT", ReadyCheckFrame, "CENTER", -3, -5)
	_G.ReadyCheckFrameNoButton:Point("TOPLEFT", ReadyCheckFrame, "CENTER", 3, -5)
	_G.ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameText:ClearAllPoints()
	_G.ReadyCheckFrameText:Point("TOP", 0, -15)

	_G.ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript("OnShow", function(self)
		-- bug fix, don't show it if player is initiator
		if self.initiator and UnitIsUnit("player", self.initiator) then
			self:Hide()
		end
	end)

	_G.RolePollPopup:SetTemplate("Transparent")

	_G.InterfaceOptionsFrame:SetClampedToScreen(true)
	_G.InterfaceOptionsFrame:SetMovable(true)
	_G.InterfaceOptionsFrame:EnableMouse(true)
	_G.InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	_G.InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end
		self:StartMoving()
		self.isMoving = true
	end)
	_G.InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		self.isMoving = false
	end)

	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		S:HandleCheckBox(_G.MacKeyboardOptionsFrameCheckButton9)
		S:HandleCheckBox(_G.MacKeyboardOptionsFrameCheckButton10)
		S:HandleCheckBox(_G.MacKeyboardOptionsFrameCheckButton11)
	end

	--Chat Config
	local ChatConfigFrame = _G.ChatConfigFrame

	hooksecurefunc(_G.ChatConfigFrameChatTabManager, "UpdateWidth", function(self)
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
	_G.ChatConfigBackgroundFrame:SetTemplate("Transparent")
	_G.ChatConfigCategoryFrame:SetTemplate("Transparent")
	_G.ChatConfigCombatSettingsFilters:SetTemplate("Transparent")

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

	_G.ChatConfigFrameDefaultButton:ClearAllPoints()
	_G.ChatConfigFrameDefaultButton:Point("TOPLEFT",_G.ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
	_G.ChatConfigFrameRedockButton:ClearAllPoints()
	_G.ChatConfigFrameRedockButton:Point("LEFT", _G.ChatConfigFrameDefaultButton, "RIGHT", 1, 0)
	_G.CombatLogDefaultButton:ClearAllPoints()
	_G.CombatLogDefaultButton:Point("TOPLEFT",_G.ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
	_G.ChatConfigFrameOkayButton:ClearAllPoints()
	_G.ChatConfigFrameOkayButton:Point("RIGHT", _G.ChatConfigFrameCancelButton, "RIGHT", -11, -1)
	_G.ChatConfigCombatSettingsFiltersDeleteButton:ClearAllPoints()
	_G.ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", _G.ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	_G.ChatConfigCombatSettingsFiltersAddFilterButton:ClearAllPoints()
	_G.ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", _G.ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	_G.ChatConfigCombatSettingsFiltersCopyFilterButton:ClearAllPoints()
	_G.ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", _G.ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	for i=1, 5 do
		local tab = _G["CombatConfigTab"..i]
		tab:StripTextures()
	end

	S:HandleEditBox(_G.CombatConfigSettingsNameEditBox)

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
		if SkinFrames == _G.CombatConfigColorsColorizeSpellNames then
			SkinFrames:Point("TOP", _G.CombatConfigColorsColorizeUnitName, "BOTTOM" ,0, -2)
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
	CreateChatChannelList(_G.ChatConfigChannelSettings, GetChannelList())
	_G.ChatConfigBackgroundFrame:SetScript("OnShow", function()
		-- >> Chat >> Chat Settings
		for i = 1,#_G.CHAT_CONFIG_CHAT_LEFT do
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:StripTextures()
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigChatSettingsLeftCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			_G["ChatConfigChatSettingsLeftCheckBox"..i]:Height(_G.ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
			S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."Check"])
		end
		-- >> Other >> Combat
		for i = 1,#_G.CHAT_CONFIG_OTHER_COMBAT do
			_G["ChatConfigOtherSettingsCombatCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsCombatCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsCombatCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsCombatCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsCombatCheckBox"..i.."Check"])
		end
		-- >> Other >> PvP
		for i = 1,#_G.CHAT_CONFIG_OTHER_PVP do
			_G["ChatConfigOtherSettingsPVPCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsPVPCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsPVPCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsPVPCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsPVPCheckBox"..i.."Check"])
		end
		-- >> Other >> System
		for i = 1,#_G.CHAT_CONFIG_OTHER_SYSTEM do
			_G["ChatConfigOtherSettingsSystemCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsSystemCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsSystemCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsSystemCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsSystemCheckBox"..i.."Check"])
		end
		-- >> Other >> Creatures
		for i = 1,#_G.CHAT_CONFIG_CHAT_CREATURE_LEFT do
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i]:StripTextures()
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i]:CreateBackdrop()
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["ChatConfigOtherSettingsCreatureCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["ChatConfigOtherSettingsCreatureCheckBox"..i.."Check"])
		end
		-- >> Sources >> DoneBy
		for i = 1,#_G.COMBAT_CONFIG_MESSAGESOURCES_BY do
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i]:StripTextures()
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i]:CreateBackdrop()
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["CombatConfigMessageSourcesDoneByCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["CombatConfigMessageSourcesDoneByCheckBox"..i.."Check"])
		end
		-- >> Sources >> DoneTo
		for i = 1,#_G.COMBAT_CONFIG_MESSAGESOURCES_TO do
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i]:StripTextures()
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i]:CreateBackdrop()
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i].backdrop:Point("TOPLEFT",3,-1)
			_G["CombatConfigMessageSourcesDoneToCheckBox"..i].backdrop:Point("BOTTOMRIGHT",-3,1)
			S:HandleCheckBox(_G["CombatConfigMessageSourcesDoneToCheckBox"..i.."Check"])
		end
		-- >> Combat >> Colors >> Unit Colors
		for i = 1,#_G.COMBAT_CONFIG_UNIT_COLORS do
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
	for i = 1,#_G.COMBAT_CONFIG_TABS do
		local cctab = _G["CombatConfigTab"..i]
		if cctab then
			S:HandleTab(cctab)
			cctab:Height(cctab:GetHeight()-2)
			cctab:Width(ceil(cctab:GetWidth()+1.6))
			_G["CombatConfigTab"..i.."Text"]:Point("BOTTOM",0,10)
		end
	end
	_G.CombatConfigTab1:ClearAllPoints()
	_G.CombatConfigTab1:Point("BOTTOMLEFT",_G.ChatConfigBackgroundFrame,"TOPLEFT",6,-2)

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

	S:HandleNextPrevButton(_G.ChatConfigMoveFilterUpButton, true, true)
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterDownButton, true)
	_G.ChatConfigMoveFilterUpButton:ClearAllPoints()
	_G.ChatConfigMoveFilterDownButton:ClearAllPoints()
	_G.ChatConfigMoveFilterUpButton:Point("TOPLEFT",_G.ChatConfigCombatSettingsFilters,"BOTTOMLEFT",3,0)
	_G.ChatConfigMoveFilterDownButton:Point("LEFT",_G.ChatConfigMoveFilterUpButton,24,0)
	S:HandleEditBox(_G.CombatConfigSettingsNameEditBox)
	_G.ChatConfigFrameHeader:ClearAllPoints()
	_G.ChatConfigFrameHeader:Point("TOP", ChatConfigFrame, 0, -5)

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
			if SkinFrames ~= _G.VideoOptionsFramePanelContainer and SkinFrames ~= _G.InterfaceOptionsFramePanelContainer then
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
	_G.InterfaceOptionsFrameTab1:ClearAllPoints()
	_G.InterfaceOptionsFrameTab1:Point("BOTTOMLEFT",_G.InterfaceOptionsFrameCategories,"TOPLEFT",-11,-2)
	_G.VideoOptionsFrameDefaults:ClearAllPoints()
	_G.InterfaceOptionsFrameDefaults:ClearAllPoints()
	_G.InterfaceOptionsFrameCancel:ClearAllPoints()
	_G.VideoOptionsFrameDefaults:Point("TOPLEFT",_G.VideoOptionsFrameCategoryFrame,"BOTTOMLEFT",-1,-5)
	_G.InterfaceOptionsFrameDefaults:Point("TOPLEFT",_G.InterfaceOptionsFrameCategories,"BOTTOMLEFT",-1,-5)
	_G.InterfaceOptionsFrameCancel:Point("TOPRIGHT",_G.InterfaceOptionsFramePanelContainer,"BOTTOMRIGHT",0,-6)

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
	S:HandleDropDownBox(_G.InterfaceOptionsDisplayPanelOutlineDropDown, 210)
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
	_G.InterfaceOptionsSocialPanel.EnableTwitter.Logo:SetAtlas("WoWShare-TwitterLogo")

	local AudioOptionsVoicePanel = _G.AudioOptionsVoicePanel
	local TestInputDevice = AudioOptionsVoicePanel.TestInputDevice

	-- Toggle Test Audio Button - Wow 8.0
	S:HandleButton(TestInputDevice.ToggleTest)

	-- PushToTalk KeybindButton - Wow 8.0
	hooksecurefunc("AudioOptionsVoicePanel_InitializeCommunicationModeUI", S.AudioOptionsVoicePanel_InitializeCommunicationModeUI)

	if _G.CompactUnitFrameProfiles then --Some addons disable the Blizzard addon
		S:HandleCheckBox(_G.CompactUnitFrameProfilesRaidStylePartyFrames)
		S:HandleButton(_G.CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
		S:HandleButton(_G.CompactUnitFrameProfilesSaveButton)
		S:HandleButton(_G.CompactUnitFrameProfilesDeleteButton)

		_G.CompactUnitFrameProfilesNewProfileDialog:StripTextures()
		_G.CompactUnitFrameProfilesNewProfileDialog:CreateBackdrop("Transparent")
		S:HandleEditBox(_G.CompactUnitFrameProfilesNewProfileDialogEditBox)
		_G.CompactUnitFrameProfilesNewProfileDialogEditBox:SetSize(150, 20)
		S:HandleDropDownBox(_G.CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector)
		S:HandleButton(_G.CompactUnitFrameProfilesNewProfileDialogCreateButton)
		S:HandleButton(_G.CompactUnitFrameProfilesNewProfileDialogCancelButton)
	end

	_G.GraphicsButton:StripTextures()
	_G.RaidButton:StripTextures()
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
	local SplashFrame = _G.SplashFrame
	SplashFrame:CreateBackdrop("Transparent")
	SplashFrame.Header:FontTemplate(nil, 22)
	SplashFrame.RightTitle:FontTemplate(nil, 30)
	S:HandleButton(SplashFrame.BottomCloseButton)
	S:HandleCloseButton(SplashFrame.TopCloseButton)

	-- New Voice Sliders
	S:HandleSliderFrame(_G.UnitPopupVoiceSpeakerVolume.Slider)
	S:HandleSliderFrame(_G.UnitPopupVoiceMicrophoneVolume.Slider)
	S:HandleSliderFrame(_G.UnitPopupVoiceUserVolume.Slider)
end

S:AddCallback("SkinBlizzard", LoadSkin)
