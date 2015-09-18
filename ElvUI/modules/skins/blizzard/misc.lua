local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local ceil = math.ceil

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
		"LFDReadyCheckPopup",
	}

	QueueStatusFrame:StripTextures()

	for i = 1, getn(skins) do
		_G[skins[i]]:SetTemplate("Transparent")
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
		"AddOns",
		"WhatsNew",
		"Ratings",
		"Addons",
		"Logout",
		"Quit",
		"Continue",
		"MacOptions",
		"Store",
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

		local function forceBackdropColor(self, r, g, b, a)
			if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0 then
				GhostFrame:SetBackdropColor(0,0,0,0)
				GhostFrame:SetBackdropBorderColor(0,0,0,0)
			end
		end

		hooksecurefunc(GhostFrame, "SetBackdropColor", forceBackdropColor)
		hooksecurefunc(GhostFrame, "SetBackdropBorderColor", forceBackdropColor)

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
	S:HandleButton(LFDReadyCheckPopup.YesButton)
	S:HandleButton(LFDReadyCheckPopup.NoButton)

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

		S:HandleCheckBox(iTunesRemoteOptionsFrameCheckButton7)
		S:HandleCheckBox(iTunesRemoteOptionsFrameCheckButton8)

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
			self:SetHeight(100)
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
            _G["ChatConfigChannelSettingsLeftCheckBox"..i]:SetHeight(ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
            S:HandleCheckBox(_G["ChatConfigChannelSettingsLeftCheckBox"..i.."Check"])
            S:HandleCheckBox(_G["ChatConfigChannelSettingsLeftCheckBox"..i.."ColorClasses"])
            _G["ChatConfigChannelSettingsLeftCheckBox"..i.."ColorClasses"]:SetHeight(ChatConfigChatSettingsLeftCheckBox1Check:GetHeight())
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
            _G["ChatConfigChatSettingsLeftCheckBox"..i]:SetHeight(ChatConfigOtherSettingsCombatCheckBox1:GetHeight())
            S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."Check"])
            S:HandleCheckBox(_G["ChatConfigChatSettingsLeftCheckBox"..i.."ColorClasses"])
            _G["ChatConfigChatSettingsLeftCheckBox"..i.."ColorClasses"]:SetHeight(ChatConfigChatSettingsLeftCheckBox1Check:GetHeight())
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
            cctab:SetHeight(cctab:GetHeight()-2)
            cctab:SetWidth(ceil(cctab:GetWidth()+1.6))
            _G["CombatConfigTab"..i.."Text"]:SetPoint("BOTTOM",0,10)
        end
    end
    CombatConfigTab1:ClearAllPoints()
    CombatConfigTab1:SetPoint("BOTTOMLEFT",ChatConfigBackgroundFrame,"TOPLEFT",6,-2)

   local ccbuttons = {
		"ChatConfigFrameOkayButton",
		"ChatConfigFrameDefaultButton",
		"CombatLogDefaultButton",
		"ChatConfigCombatSettingsFiltersDeleteButton",
		"ChatConfigCombatSettingsFiltersAddFilterButton",
		"ChatConfigCombatSettingsFiltersCopyFilterButton",
		"CombatConfigSettingsSaveButton",
    }

   for i = 1, getn(ccbuttons) do
        local ccbtn = _G[ccbuttons[i]]
        if ccbtn then
			S:HandleButton(ccbtn)

        end
    end

	ChatConfigFrameOkayButton:SetPoint("TOPRIGHT",ChatConfigBackgroundFrame,"BOTTOMRIGHT",-3,-5)
    ChatConfigFrameDefaultButton:SetPoint("TOPLEFT",ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
    CombatLogDefaultButton:SetPoint("TOPLEFT",ChatConfigCategoryFrame,"BOTTOMLEFT",1,-5)
    ChatConfigCombatSettingsFiltersDeleteButton:SetPoint("TOPRIGHT",ChatConfigCombatSettingsFilters,"BOTTOMRIGHT",-3,-1)
    ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT",ChatConfigCombatSettingsFiltersDeleteButton,"LEFT",-2,0)
    ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT",ChatConfigCombatSettingsFiltersCopyFilterButton,"LEFT",-2,0)

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
    for i = 1, getn(cccheckbox) do
		local ccbtn = _G[cccheckbox[i]]
        S:HandleCheckBox(ccbtn)
    end

    S:HandleNextPrevButton(ChatConfigMoveFilterUpButton,true)
    S:HandleNextPrevButton(ChatConfigMoveFilterDownButton,true)
    ChatConfigMoveFilterUpButton:ClearAllPoints()
    ChatConfigMoveFilterDownButton:ClearAllPoints()
    ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT",ChatConfigCombatSettingsFilters,"BOTTOMLEFT",3,0)
    ChatConfigMoveFilterDownButton:SetPoint("LEFT",ChatConfigMoveFilterUpButton,24,0)
    S:HandleEditBox(CombatConfigSettingsNameEditBox)
    ChatConfigFrame:Size(680,596)
    ChatConfigFrameHeader:ClearAllPoints()
    ChatConfigFrameHeader:SetPoint("TOP", ChatConfigFrame, 0, -5)

	--DROPDOWN MENU
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Transparent")
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Transparent")
		end
	end)

	--[[GuildInviteFrame:StripTextures()
	GuildInviteFrame:SetTemplate('Transparent')
	GuildInviteFrameLevel:StripTextures()
	GuildInviteFrameLevel:ClearAllPoints()
	GuildInviteFrameLevel:Point('TOP', GuildInviteFrame, 'CENTER', -15, -25)
	S:HandleButton(GuildInviteFrameJoinButton)
	S:HandleButton(GuildInviteFrameDeclineButton)
	GuildInviteFrame:Height(225)
	GuildInviteFrame:HookScript("OnEvent", function()
		GuildInviteFrame:Height(225)
	end)
	GuildInviteFrameWarningText:Kill()]]

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
        "ControlsPanelBlockChatChannelInvites",
        "ControlsPanelStickyTargeting",
        "ControlsPanelAutoDismount",
        "ControlsPanelAutoClearAFK",
        "ControlsPanelBlockTrades",
        "ControlsPanelBlockGuildInvites",
        "ControlsPanelLootAtMouse",
        "ControlsPanelAutoLootCorpse",
        "ControlsPanelInteractOnLeftClick",
        "ControlsPanelAutoOpenLootHistory",
        "ControlsPanelReverseCleanUpBags",
        "ControlsPanelReverseNewLoot",
        -- Combat
        "CombatPanelEnemyCastBarsOnOnlyTargetNameplates",
        "CombatPanelEnemyCastBarsNameplateSpellNames",
        "CombatPanelAttackOnAssist",
        "CombatPanelStopAutoAttack",
        "CombatPanelTargetOfTarget",
        "CombatPanelShowSpellAlerts",
        "CombatPanelReducedLagTolerance",
        "CombatPanelActionButtonUseKeyDown",
        "CombatPanelEnemyCastBarsOnPortrait",
        "CombatPanelEnemyCastBarsOnNameplates",
        "CombatPanelAutoSelfCast",
	  "CombatPanelLossOfControl",
        -- Display
        "DisplayPanelShowCloak",
        "DisplayPanelShowHelm",
        "DisplayPanelShowAggroPercentage",
        "DisplayPanelPlayAggroSounds",
        "DisplayPanelShowSpellPointsAvg",
        "DisplayPanelShowFreeBagSpace",
        "DisplayPanelCinematicSubtitles",
        "DisplayPanelRotateMinimap",
        "DisplayPanelShowAccountAchievments",
		"DisplayPanelAJAlerts",
        --Objectives
        "ObjectivesPanelAutoQuestTracking",
        "ObjectivesPanelMapFade",
        -- Social
        "SocialPanelProfanityFilter",
        "SocialPanelSpamFilter",
        "SocialPanelChatBubbles",
        "SocialPanelPartyChat",
        "SocialPanelChatHoverDelay",
        "SocialPanelGuildMemberAlert",
        "SocialPanelChatMouseScroll",
		"SocialPanelEnableTwitter",
		"SocialPanelWholeChatWindowClickable",
        -- Action bars
        "ActionBarsPanelLockActionBars",
        "ActionBarsPanelSecureAbilityToggle",
        "ActionBarsPanelAlwaysShowActionBars",
        "ActionBarsPanelBottomLeft",
        "ActionBarsPanelBottomRight",
        "ActionBarsPanelRight",
        "ActionBarsPanelRightTwo",
        "ActionBarsPanelCountdownCooldowns",
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
        "NamesPanelMinus",
        "NamesPanelUnitNameplatesEnemyMinus",

        -- Combat Text
        "CombatTextPanelTargetDamage",
        "CombatTextPanelPeriodicDamage",
        "CombatTextPanelPetDamage",
        "CombatTextPanelHealing",
        "CombatTextPanelHealingAbsorbTarget",
        "CombatTextPanelHealingAbsorbSelf",
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
        "CombatTextPanelPetBattle",
        -- Buffs & Debuffs
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
		"MousePanelEnableMouseSpeed",
        -- Help
        "HelpPanelShowTutorials",
        "HelpPanelEnhancedTooltips",
        "HelpPanelShowLuaErrors",
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
        "StatusTextPanelXP",
        -- Unit Frames
        "UnitFramePanelPartyPets",
        "UnitFramePanelArenaEnemyFrames",
        "UnitFramePanelArenaEnemyCastBar",
        "UnitFramePanelArenaEnemyPets",
        "UnitFramePanelFullSizeFocusFrame",

		--Assessability
		"AccessibilityPanelMovePad",
		"AccessibilityPanelColorblindMode",

		--Watev
		"NamesPanelUnitNameplatesNameplateClassColors",
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
        "CombatPanelTOTDropDown",
        "CombatPanelFocusCastKeyDropDown",
        "CombatPanelSelfCastKeyDropDown",
		"CombatPanelLossOfControlFullDropDown",
		"CombatPanelLossOfControlSilenceDropDown",
		"CombatPanelLossOfControlInterruptDropDown",
		"CombatPanelLossOfControlDisarmDropDown",
		"CombatPanelLossOfControlRootDropDown",
        --Objectives
        "ObjectivesPanelQuestSorting",
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
        "CombatTextPanelTargetModeDropDown",
        -- Camera
        "CameraPanelStyleDropDown",
        -- Mouse
        "MousePanelClickMoveStyleDropDown",
		-- Language
        "LanguagesPanelLocaleDropDown",
		"LanguagesPanelAudioLocaleDropDown",
        -- Status Text
        "StatusTextPanelDisplayDropDown",

		--Assess-ability
		"AccessibilityPanelColorFilterDropDown",

		--Locales
		"InterfaceOptionsLanguagesPanelAudioLocaleDropDown",
    }
    for i = 1, getn(interfacedropdown) do
        local idropdown = _G["InterfaceOptions"..interfacedropdown[i]]
        if idropdown then
            S:HandleDropDownBox(idropdown)
            DropDownList1:SetTemplate("Transparent")
        end
    end

	-- Display
	S:HandleDropDownBox(InterfaceOptionsDisplayPanelOutlineDropDown, 210)

    S:HandleButton(InterfaceOptionsHelpPanelResetTutorials)
    local optioncheckbox = {
    	-- Display
    	"Display_RaidSettingsEnabledCheckBox",
        -- Advanced
        "Advanced_MaxFPSCheckBox",
        "Advanced_MaxFPSBKCheckBox",
        "Advanced_UseUIScale",
        "Advanced_ShowHDModels",
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
        "Graphics_ViewDistanceDropDown",
        "Graphics_EnvironmentalDetailDropDown",
        "Graphics_GroundClutterDropDown",
        "Graphics_ShadowsDropDown",
        "Graphics_LiquidDetailDropDown",
        "Graphics_SunshaftsDropDown",
        "Graphics_ParticleDensityDropDown",
        "Graphics_SSAODropDown",
        "Graphics_RefractionDropDown",
		"Graphics_DepthEffectsDropDown",
		"Graphics_LightingQualityDropDown",
		"Graphics_OutlineModeDropDown",

        "RaidGraphics_TextureResolutionDropDown",
        "RaidGraphics_FilteringDropDown",
        "RaidGraphics_ProjectedTexturesDropDown",
        "RaidGraphics_ViewDistanceDropDown",
        "RaidGraphics_EnvironmentalDetailDropDown",
        "RaidGraphics_GroundClutterDropDown",
        "RaidGraphics_ShadowsDropDown",
        "RaidGraphics_LiquidDetailDropDown",
        "RaidGraphics_SunshaftsDropDown",
        "RaidGraphics_ParticleDensityDropDown",
        "RaidGraphics_SSAODropDown",
        "RaidGraphics_RefractionDropDown",
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
		"InterfaceOptionsSocialPanelTwitterLoginButton"
    }
    for _, button in pairs(buttons) do
        S:HandleButton(_G[button])
    end
    AudioOptionsVoicePanelChatMode1KeyBindingButton:ClearAllPoints()
    AudioOptionsVoicePanelChatMode1KeyBindingButton:Point("CENTER", AudioOptionsVoicePanelBinding, "CENTER", 0, -10)
    S:HandleCheckBox(CompactUnitFrameProfilesRaidStylePartyFrames)
    S:HandleButton(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
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
		"RaidGraphics_Quality",
		"Advanced_UIScaleSlider",
		"Advanced_MaxFPSSlider",
		"Advanced_MaxFPSBKSlider",
		"Advanced_RenderScaleSlider",
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
		"InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset",
		"InterfaceOptionsBattlenetPanelToastDurationSlider",
		"InterfaceOptionsCameraPanelMaxDistanceSlider",
		"InterfaceOptionsCameraPanelFollowSpeedSlider",
		"InterfaceOptionsMousePanelMouseSensitivitySlider",
		"InterfaceOptionsMousePanelMouseLookSpeedSlider",
		"InterfaceOptionsAccessibilityPanelColorblindStrengthSlider",
		"OpacityFrameSlider",
	}
	Graphics_RightQuality:Kill()
	RaidGraphics_RightQuality:Kill()
	for _, slider in pairs(sliders) do
		S:HandleSliderFrame(_G[slider])
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
	MacOptionsButtonKeybindings:SetPoint("LEFT", MacOptionsFrameDefaults, "RIGHT", 2, 0)
	MacOptionsFrameOkay:ClearAllPoints()
	MacOptionsFrameOkay:SetPoint("LEFT", MacOptionsButtonKeybindings, "RIGHT", 2, 0)
	MacOptionsFrameCancel:ClearAllPoints()
	MacOptionsFrameCancel:SetPoint("LEFT", MacOptionsFrameOkay, "RIGHT", 2, 0)
	MacOptionsFrameCancel:SetWidth(MacOptionsFrameCancel:GetWidth() - 6)]]

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

	--Addon List
	AddonList:StripTextures()
	AddonList:SetTemplate("Transparent")
	AddonListInset:StripTextures()

	S:HandleButton(AddonListEnableAllButton, true)
	S:HandleButton(AddonListDisableAllButton, true)
	S:HandleButton(AddonListOkayButton, true)
	S:HandleButton(AddonListCancelButton, true)

	S:HandleScrollBar(AddonListScrollFrameScrollBar, 5)

	S:HandleCheckBox(AddonListForceLoad)
	AddonListForceLoad:SetSize(26, 26)
	S:HandleDropDownBox(AddonCharacterDropDown)

	S:HandleCloseButton(AddonListCloseButton)

	for i=1, MAX_ADDONS_DISPLAYED do
		S:HandleCheckBox(_G["AddonListEntry"..i.."Enabled"])
		S:HandleButton(_G["AddonListEntry"..i].LoadAddonButton)
	end
	
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

	--Mirror Timers (Underwater Breath etc.), credit to Azilroka
	for i = 1, MIRRORTIMER_NUMTIMERS do
		local mirrorTimer = _G['MirrorTimer'..i]
		local statusBar = _G['MirrorTimer'..i..'StatusBar']
		local text = _G['MirrorTimer'..i.."Text"]

		mirrorTimer:StripTextures()
		mirrorTimer:Size(222, 18)
		statusBar:SetStatusBarTexture(E["media"].normTex)
		statusBar:CreateBackdrop()
		statusBar:Size(222, 18)
		text:ClearAllPoints()
		text:SetPoint('CENTER', statusBar, 'CENTER', 0, 0)

		E:CreateMover(mirrorTimer, "MirrorTimer"..i.."Mover", L["MirrorTimer"]..i, nil, nil, nil, "ALL,SOLO")
	end
end

S:RegisterSkin('ElvUI', LoadSkin)