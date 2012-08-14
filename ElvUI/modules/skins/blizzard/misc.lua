local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end
	-- Blizzard frame we want to reskin
	local skins = {
		"StaticPopup1",
		"StaticPopup2",
		"StaticPopup3",
		"GameMenuFrame",
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
		"ConsolidatedBuffsTooltip",
		"ReadyCheckFrame",
		"StackSplitFrame",
		"QueueStatusFrame",
	}
	
	QueueStatusFrame:StripTextures()

	for i = 1, getn(skins) do
		_G[skins[i]]:SetTemplate("Transparent")
		if _G[skins[i]] ~= _G["GhostFrameContentsFrame"] or _G[skins[i]] ~= _G["AutoCompleteBox"] then -- frame to blacklist from create shadow function
			_G[skins[i]]:CreateShadow("Default")
		end
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
	LFDRoleCheckPopup:StripTextures()
	LFDRoleCheckPopup:SetTemplate("Transparent")
	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank:GetChildren())
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS:GetChildren())
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer:GetChildren())
	LFDRoleCheckPopupRoleButtonTank:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonTank:GetChildren():GetFrameLevel() + 1)
	LFDRoleCheckPopupRoleButtonDPS:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonDPS:GetChildren():GetFrameLevel() + 1)
	LFDRoleCheckPopupRoleButtonHealer:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonHealer:GetChildren():GetFrameLevel() + 1)
	
	-- reskin popup buttons
	for i = 1, 3 do
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
	
	-- reskin all esc/menu buttons
	local BlizzardMenuButtons = {
		"Options", 
		"SoundOptions", 
		"UIOptions", 
		"Keybindings", 
		"Macros",
		"Ratings",
		"AddOns", 
		"Logout", 
		"Quit", 
		"Continue", 
		"MacOptions",
		"Help"
	}
	
	for i = 1, getn(BlizzardMenuButtons) do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
		if ElvuiMenuButtons then
			S:HandleButton(ElvuiMenuButtons)
		end
	end
	
	if IsAddOnLoaded("OptionHouse") then
		S:HandleButton(GameMenuButtonOptionHouse)
	end
	
	-- skin return to graveyard button
	do
		S:HandleButton(GhostFrame)
		GhostFrame:SetBackdropColor(0,0,0,0)
		GhostFrame:SetBackdropBorderColor(0,0,0,0)
		GhostFrame.SetBackdropColor = E.noop
		GhostFrame.SetBackdropBorderColor = E.noop
		GhostFrame:ClearAllPoints()
		GhostFrame:SetPoint("TOP", E.UIParent, "TOP", 0, -150)
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
		"GameMenuFrame", 
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
				title:SetPoint("TOP", GameMenuFrame, 0, 7)
			else
				title:SetPoint("TOP", BlizzardHeader[i], 0, 0)
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
	
	for i = 1, getn(BlizzardButtons) do
		local ElvuiButtons = _G[BlizzardButtons[i]]
		if ElvuiButtons then
			S:HandleButton(ElvuiButtons)
		end
	end
	
	-- if a button position is not really where we want, we move it here
	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:SetPoint("RIGHT",VideoOptionsFrameApply,"LEFT",-4,0)		 
	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:SetPoint("RIGHT",VideoOptionsFrameCancel,"LEFT",-4,0)	
	AudioOptionsFrameOkay:ClearAllPoints()
	AudioOptionsFrameOkay:SetPoint("RIGHT",AudioOptionsFrameCancel,"LEFT",-4,0)
	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:SetPoint("RIGHT",InterfaceOptionsFrameCancel,"LEFT", -4,0)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame) 
	ReadyCheckFrameYesButton:SetPoint("RIGHT", ReadyCheckFrame, "CENTER", -1, 0)
	ReadyCheckFrameNoButton:SetPoint("LEFT", ReadyCheckFrameYesButton, "RIGHT", 3, 0)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)	
	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:SetPoint("TOP", 0, -12)
	
	-- others
	ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end) -- bug fix, don't show it if initiator
	StackSplitFrame:GetRegions():Hide()

	
	RolePollPopup:SetTemplate("Transparent")
	RolePollPopup:CreateShadow("Default")
	
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
		-- Skin main frame and reposition the header
		MacOptionsFrame:SetTemplate("Default", true)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
 
		--Skin internal frames
		MacOptionsFrameMovieRecording:SetTemplate("Default", true)
		MacOptionsITunesRemote:SetTemplate("Default", true)
 
		--Skin buttons
		S:HandleButton(MacOptionsFrameCancel)
		S:HandleButton(MacOptionsFrameOkay)
		S:HandleButton(MacOptionsButtonKeybindings)
		S:HandleButton(MacOptionsFrameDefaults)
		S:HandleButton(MacOptionsButtonCompress)
 
		--Reposition and resize buttons
		local tPoint, tRTo, tRP, tX, tY =  MacOptionsButtonCompress:GetPoint()
		MacOptionsButtonCompress:SetWidth(136)
		MacOptionsButtonCompress:ClearAllPoints()
		MacOptionsButtonCompress:Point(tPoint, tRTo, tRP, 4, tY)
 
		MacOptionsFrameCancel:SetWidth(96)
		MacOptionsFrameCancel:SetHeight(22)
		tPoint, tRTo, tRP, tX, tY =  MacOptionsFrameCancel:GetPoint()
		MacOptionsFrameCancel:ClearAllPoints()
		MacOptionsFrameCancel:Point(tPoint, tRTo, tRP, -14, tY)
 
		MacOptionsFrameOkay:ClearAllPoints()
		MacOptionsFrameOkay:SetWidth(96)
		MacOptionsFrameOkay:SetHeight(22)
		MacOptionsFrameOkay:Point("LEFT",MacOptionsFrameCancel, -99,0)
 
		MacOptionsButtonKeybindings:ClearAllPoints()
		MacOptionsButtonKeybindings:SetWidth(96)
		MacOptionsButtonKeybindings:SetHeight(22)
		MacOptionsButtonKeybindings:Point("LEFT",MacOptionsFrameOkay, -99,0)
 
		MacOptionsFrameDefaults:SetWidth(96)
		MacOptionsFrameDefaults:SetHeight(22)

	end
	
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")	
	for i=1, WatchFrameCollapseExpandButton:GetNumRegions() do
		local region = select(i, WatchFrameCollapseExpandButton:GetRegions())
		if region:GetObjectType() == 'Texture' then
			region:SetDesaturated(true)
		end
	end
	
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
	
	ChatConfigFrameOkayButton:Point("RIGHT", ChatConfigFrameCancelButton, "RIGHT", -11, -1)
	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
	
	for i=1, 5 do
		local tab = _G["CombatConfigTab"..i]
		tab:StripTextures()
	end
	
	S:HandleEditBox(CombatConfigSettingsNameEditBox)
	
	--This isn't worth the effort
	--[[local function SkinChannelFrame(frame)
		frame:StripTextures()
		frame:SetTemplate("Default")
		if _G[frame:GetName().."Check"] then
			S:HandleCheckBox(_G[frame:GetName().."Check"])
		end
		
		if _G[frame:GetName().."ColorClasses"] then
			S:HandleCheckBox(_G[frame:GetName().."ColorClasses"])
		end
	end
	
	local x = CreateFrame("Frame")
	x:RegisterEvent("PLAYER_ENTERING_WORLD")
	x:SetScript("OnEvent", function(self, event)
		for i=1, #CHAT_CONFIG_CHAT_LEFT do
			local frame = _G["ChatConfigChatSettingsLeftCheckBox"..i]
			SkinChannelFrame(frame)
			
			if i > 1 then
				local point, anchor, point2, x, y = frame:GetPoint()
				frame:SetPoint(point, anchor, point2, x, y-2)
			end
		end	
		
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end)]]
	
	--DROPDOWN MENU
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Default", true)
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Default", true)
		end
	end)	
	
	GuildInviteFrame:StripTextures()
	GuildInviteFrame:SetTemplate('Transparent')
	GuildInviteFrame:CreateShadow()
	GuildInviteFrameLevel:StripTextures()
	GuildInviteFrameLevel:ClearAllPoints()
	GuildInviteFrameLevel:Point('TOP', GuildInviteFrame, 'CENTER', -15, -25)
	S:HandleButton(GuildInviteFrameJoinButton)
	S:HandleButton(GuildInviteFrameDeclineButton)
	GuildInviteFrame:Height(225)
	GuildInviteFrame.SetHeight = E.noop
	GuildInviteFrameWarningText:Kill()
	
	local function SkinWatchFrameItems()
		for i=1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i]
			if not button.skinned then
				button:CreateBackdrop('Default')
				button.backdrop:SetAllPoints()
				button:StyleButton()
				_G["WatchFrameItem"..i.."NormalTexture"]:SetAlpha(0)
				_G["WatchFrameItem"..i.."IconTexture"]:SetInside()
				_G["WatchFrameItem"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				button.skinned = true
			end
		end	
	end
	
	WatchFrame:HookScript("OnEvent", SkinWatchFrameItems)
	
	BattleTagInviteFrame:StripTextures()
	BattleTagInviteFrame:SetTemplate('Transparent')
	S:HandleEditBox(BattleTagInviteFrameScrollFrame)
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
    }
    for i = 1, getn(frames) do
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
    for i = 1, getn(interfacetab) do
        local itab = _G[interfacetab[i]]
        if itab then
            itab:StripTextures()
            S:HandleTab(itab)
        end
    end
    InterfaceOptionsFrameTab1:ClearAllPoints()
    InterfaceOptionsFrameTab1:SetPoint("BOTTOMLEFT",InterfaceOptionsFrameCategories,"TOPLEFT",-11,-2)
    VideoOptionsFrameDefaults:ClearAllPoints()
    InterfaceOptionsFrameDefaults:ClearAllPoints()
    InterfaceOptionsFrameCancel:ClearAllPoints()
    VideoOptionsFrameDefaults:SetPoint("TOPLEFT",VideoOptionsFrameCategoryFrame,"BOTTOMLEFT",-1,-5)
    InterfaceOptionsFrameDefaults:SetPoint("TOPLEFT",InterfaceOptionsFrameCategories,"BOTTOMLEFT",-1,-5)
    InterfaceOptionsFrameCancel:SetPoint("TOPRIGHT",InterfaceOptionsFramePanelContainer,"BOTTOMRIGHT",0,-6)
    local interfacecheckbox = {
        -- Controls
        "ControlsPanelStickyTargeting",
        "ControlsPanelAutoDismount",
        "ControlsPanelAutoClearAFK",
        "ControlsPanelBlockTrades",
        "ControlsPanelBlockGuildInvites",
        "ControlsPanelLootAtMouse",
        "ControlsPanelAutoLootCorpse",
        "ControlsPanelInteractOnLeftClick",
        "ControlsPanelAutoOpenLootHistory",
        -- Combat
        "CombatPanelAttackOnAssist",
        "CombatPanelStopAutoAttack",
        "CombatPanelNameplateClassColors",
        "CombatPanelTargetOfTarget",
        "CombatPanelShowSpellAlerts",
        "CombatPanelReducedLagTolerance",
        "CombatPanelActionButtonUseKeyDown",
        "CombatPanelEnemyCastBarsOnPortrait",
        "CombatPanelEnemyCastBarsOnNameplates",
        "CombatPanelAutoSelfCast",
        -- Display
        "DisplayPanelShowCloak",
        "DisplayPanelShowHelm",
        "DisplayPanelShowAggroPercentage",
        "DisplayPanelPlayAggroSounds",
        "DisplayPanelDetailedLootInfo",
        "DisplayPanelShowSpellPointsAvg",
        "DisplayPanelemphasizeMySpellEffects",
        "DisplayPanelShowFreeBagSpace",
        "DisplayPanelCinematicSubtitles",
        "DisplayPanelRotateMinimap",
        "DisplayPanelScreenEdgeFlash",
        "DisplayPanelShowAccountAchievments",
        --Objectives
        "ObjectivesPanelAutoQuestTracking",
        "ObjectivesPanelAutoQuestProgress",
        "ObjectivesPanelMapQuestDifficulty",
        "ObjectivesPanelAdvancedWorldMap",
        "ObjectivesPanelWatchFrameWidth",
        -- Social
        "SocialPanelProfanityFilter",
        "SocialPanelSpamFilter",
        "SocialPanelChatBubbles",
        "SocialPanelPartyChat",
        "SocialPanelChatHoverDelay",
        "SocialPanelGuildMemberAlert",
        "SocialPanelChatMouseScroll",
        -- Action bars
        "ActionBarsPanelLockActionBars",
        "ActionBarsPanelSecureAbilityToggle",
        "ActionBarsPanelAlwaysShowActionBars",
        "ActionBarsPanelBottomLeft",
        "ActionBarsPanelBottomRight",
        "ActionBarsPanelRight",
        "ActionBarsPanelRightTwo",
        -- Names
        "NamesPanelMyName",
        "NamesPanelFriendlyPlayerNames",
        "NamesPanelFriendlyPets",
        "NamesPanelFriendlyGuardians",
        "NamesPanelFriendlyTotems",
        "NamesPanelUnitNameplatesFriends",
        "NamesPanelUnitNameplatesFriendlyGuardians",
        "NamesPanelUnitNameplatesFriendlyPets",
        "NamesPanelUnitNameplatesFriendlyTotems",
        "NamesPanelGuilds",
        "NamesPanelGuildTitles",
        "NamesPanelTitles",
        "NamesPanelNonCombatCreature",
        "NamesPanelEnemyPlayerNames",
        "NamesPanelEnemyPets",
        "NamesPanelEnemyGuardians",
        "NamesPanelEnemyTotems",
        "NamesPanelUnitNameplatesEnemyPets",
        "NamesPanelUnitNameplatesEnemies",
        "NamesPanelUnitNameplatesEnemyGuardians",
        "NamesPanelUnitNameplatesEnemyTotems",
        -- Combat Text
        "CombatTextPanelTargetDamage",
        "CombatTextPanelPeriodicDamage",
        "CombatTextPanelPetDamage",
        "CombatTextPanelHealing",
        "CombatTextPanelTargetEffects",
        "CombatTextPanelOtherTargetEffects",
        "CombatTextPanelEnableFCT",
        "CombatTextPanelDodgeParryMiss",
        "CombatTextPanelDamageReduction",
        "CombatTextPanelRepChanges",
        "CombatTextPanelReactiveAbilities",
        "CombatTextPanelFriendlyHealerNames",
        "CombatTextPanelCombatState",
        "CombatTextPanelComboPoints",
        "CombatTextPanelLowManaHealth",
        "CombatTextPanelEnergyGains",
        "CombatTextPanelPeriodicEnergyGains",
        "CombatTextPanelHonorGains",
        "CombatTextPanelAuras",
        -- Buffs & Debuffs
        "BuffsPanelBuffDurations",
        "BuffsPanelDispellableDebuffs",
        "BuffsPanelCastableBuffs",
        "BuffsPanelConsolidateBuffs",
        "BuffsPanelShowAllEnemyDebuffs",
        -- Camera
        "CameraPanelFollowTerrain",
        "CameraPanelHeadBob",
        "CameraPanelWaterCollision",
        "CameraPanelSmartPivot",
        -- Mouse
        "MousePanelInvertMouse",
        "MousePanelClickToMove",
        "MousePanelWoWMouse",
        -- Help
        "HelpPanelShowTutorials",
        "HelpPanelLoadingScreenTips",
        "HelpPanelEnhancedTooltips",
        "HelpPanelBeginnerTooltips",
        "HelpPanelShowLuaErrors",
        "HelpPanelColorblindMode",
        "HelpPanelMovePad",
        "BattlenetPanelOnlineFriends",
        "BattlenetPanelOfflineFriends",
        "BattlenetPanelBroadcasts",
        "BattlenetPanelFriendRequests",
        "BattlenetPanelConversations",
        "BattlenetPanelShowToastWindow",
        -- Status Text
        "StatusTextPanelPlayer",
        "StatusTextPanelPet",
        "StatusTextPanelParty",
        "StatusTextPanelTarget",
        "StatusTextPanelAlternateResource",
        "StatusTextPanelPercentages",
        "StatusTextPanelXP",
        -- Unit Frames
        "UnitFramePanelPartyBackground",
        "UnitFramePanelPartyPets",
        "UnitFramePanelArenaEnemyFrames",
        "UnitFramePanelArenaEnemyCastBar",
        "UnitFramePanelArenaEnemyPets",
        "UnitFramePanelFullSizeFocusFrame",
    }
    for i = 1, getn(interfacecheckbox) do
        local icheckbox = _G["InterfaceOptions"..interfacecheckbox[i]]
        if icheckbox then
            S:HandleCheckBox(icheckbox)
        end
    end
    local interfacedropdown ={
        -- Controls
        "ControlsPanelAutoLootKeyDropDown",
        -- Combat
        "CombatPanelTOTDropDown",
        "CombatPanelFocusCastKeyDropDown",
        "CombatPanelSelfCastKeyDropDown",
        -- Display
        "DisplayPanelAggroWarningDisplay",
        "DisplayPanelWorldPVPObjectiveDisplay",
        -- Social
        "SocialPanelChatStyle",
        "SocialPanelWhisperMode",
        "SocialPanelTimestamps",
        "SocialPanelBnWhisperMode",
        "SocialPanelConversationMode",
        -- Action bars
        "ActionBarsPanelPickupActionKeyDropDown",
        -- Names
        "NamesPanelNPCNamesDropDown",
        "NamesPanelUnitNameplatesMotionDropDown",
        -- Combat Text
        "CombatTextPanelFCTDropDown",
        -- Camera
        "CameraPanelStyleDropDown",
        -- Mouse
        "MousePanelClickMoveStyleDropDown",
        "LanguagesPanelLocaleDropDown",
    }
    for i = 1, getn(interfacedropdown) do
        local idropdown = _G["InterfaceOptions"..interfacedropdown[i]]
        if idropdown then
            S:HandleDropDownBox(idropdown)
            DropDownList1:SetTemplate("Transparent")
        end
    end
    S:HandleButton(InterfaceOptionsHelpPanelResetTutorials)
    S:HandleCloseButton(WatchFrameCollapseExpandButton)
    local optioncheckbox = {
        -- Advanced
        "Advanced_MaxFPSCheckBox",
        "Advanced_MaxFPSBKCheckBox",
        "Advanced_UseUIScale",
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
        "Graphics_DisplayModeDropDown",
        "Graphics_ResolutionDropDown",
        "Graphics_RefreshDropDown",
        "Graphics_PrimaryMonitorDropDown",
        "Graphics_MultiSampleDropDown",
        "Graphics_VerticalSyncDropDown",
        "Graphics_TextureResolutionDropDown",
        "Graphics_FilteringDropDown",
        "Graphics_ProjectedTexturesDropDown",
        "Graphics_ViewDistanceDropDown",
        "Graphics_EnvironmentalDetailDropDown",
        "Graphics_GroundClutterDropDown",
        "Graphics_ShadowsDropDown",
        "Graphics_LiquidDetailDropDown",
        "Graphics_SunshaftsDropDown",
        "Graphics_ParticleDensityDropDown",
        "Graphics_SSAODropDown",
        -- Advanced
        "Advanced_BufferingDropDown",
        "Advanced_LagDropDown",
        "Advanced_HardwareCursorDropDown",
        "Advanced_GraphicsAPIDropDown",
        -- Audio
        "AudioOptionsSoundPanelHardwareDropDown",
        "AudioOptionsSoundPanelSoundChannelsDropDown",
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
        end
    end
    local buttons = {
        "RecordLoopbackSoundButton",
        "PlayLoopbackSoundButton",
        "AudioOptionsVoicePanelChatMode1KeyBindingButton",
        "CompactUnitFrameProfilesSaveButton",
        "CompactUnitFrameProfilesDeleteButton",
    }
    for _, button in pairs(buttons) do
        S:HandleButton(_G[button])
    end
    AudioOptionsVoicePanelChatMode1KeyBindingButton:ClearAllPoints()
    AudioOptionsVoicePanelChatMode1KeyBindingButton:Point("CENTER", AudioOptionsVoicePanelBinding, "CENTER", 0, -10)
    S:HandleCheckBox(CompactUnitFrameProfilesRaidStylePartyFrames)
    S:HandleButton(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
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
		"Advanced_UIScaleSlider",
		"Advanced_MaxFPSSlider",
		"Advanced_MaxFPSBKSlider",
		"AudioOptionsSoundPanelSoundQuality",
		"AudioOptionsSoundPanelMasterVolume",
		"AudioOptionsSoundPanelSoundVolume",
		"AudioOptionsSoundPanelMusicVolume",
		"AudioOptionsSoundPanelAmbienceVolume",
		"AudioOptionsVoicePanelMicrophoneVolume",
		"AudioOptionsVoicePanelSpeakerVolume",
		"AudioOptionsVoicePanelSoundFade",
		"AudioOptionsVoicePanelMusicFade",
		"AudioOptionsVoicePanelAmbienceFade",
		"InterfaceOptionsCombatPanelSpellAlertOpacitySlider",
		"InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset",
		"InterfaceOptionsBattlenetPanelToastDurationSlider",
		"InterfaceOptionsCameraPanelMaxDistanceSlider",
		"InterfaceOptionsCameraPanelFollowSpeedSlider",
		"InterfaceOptionsMousePanelMouseSensitivitySlider",
		"InterfaceOptionsMousePanelMouseLookSpeedSlider",
		"OpacityFrameSlider",
	}
	Graphics_RightQuality:Kill()
	for _, slider in pairs(sliders) do
		S:HandleSliderFrame(_G[slider])
	end
end

S:RegisterSkin('ElvUI', LoadSkin)