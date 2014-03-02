local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

local CURRENT_PAGE = 0
local MAX_PAGE = 9

local function SetupChat()
	InstallStepComplete.message = L["Chat Set"]
	InstallStepComplete:Show()			
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_OpenNewWindow("G")
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_OpenNewWindow("P")
	FCF_DockFrame(ChatFrame4)
	FCF_SetLocked(ChatFrame4, 1)
	FCF_OpenNewWindow("W")
	FCF_DockFrame(ChatFrame5)
	FCF_SetLocked(ChatFrame5, 1)
	FCF_OpenNewWindow(LOOT)
	FCF_DockFrame(ChatFrame6)
	FCF_SetLocked(ChatFrame6, 1)
			
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		local chatFrameId = frame:GetID()
		local chatName = FCF_GetChatWindowInfo(chatFrameId)
		
		-- move general bottom left
		if i == 1 then
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)
		end
		
		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
		
		-- set default Elvui font size
		FCF_SetChatWindowFontSize(nil, frame, 13)
		
		-- rename chat windows
		if i == 1 then
			FCF_SetWindowName(frame, "All")
		elseif i == 2 then
			FCF_SetWindowName(frame, "Log")
		end
	end

	-- setup the "All" chat frame to filter out stuff shown in the right chat
	ChatFrame_RemoveMessageGroup(ChatFrame1, "COMBAT_XP_GAIN")
	ChatFrame_RemoveMessageGroup(ChatFrame1, "COMBAT_HONOR_GAIN")
	ChatFrame_RemoveMessageGroup(ChatFrame1, "COMBAT_FACTION_CHANGE")
	ChatFrame_RemoveMessageGroup(ChatFrame1, "LOOT")
	ChatFrame_RemoveMessageGroup(ChatFrame1, "MONEY")

	-- Setup the Guild chat frame
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "GUILD") 
	ChatFrame_AddMessageGroup(ChatFrame3, "OFFICER") 
	ChatFrame_AddMessageGroup(ChatFrame3, "GUILD_ACHIEVEMENT")
	
	-- Setup the Party chat frame
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_AddMessageGroup(ChatFrame4, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame4, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame4, "RAID") 
	ChatFrame_AddMessageGroup(ChatFrame4, "RAID_LEADER") 
	ChatFrame_AddMessageGroup(ChatFrame4, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame4, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame4, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame4, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame4, "INSTANCE_CHAT_LEADER")

	-- Setup the Whisper chat frame
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)
	ChatFrame_AddMessageGroup(ChatFrame5, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame5, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame5, "BN_CONVERSATION")

	-- Setup the right chat
	ChatFrame_RemoveAllMessageGroups(ChatFrame6)
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame6, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame6, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame6, "MONEY")

	if E.myname == "Elvz" then
		SetCVar("scriptErrors", 1)
	end

	-- enable classcolor automatically on login and on each character without doing /configure each time.
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")	
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")		
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")
	
	if E.Chat then
		E.Chat:PositionChat(true)
		if E.db['RightChatPanelFaded'] then
			RightChatToggleButton:Click()
		end
		
		if E.db['LeftChatPanelFaded'] then
			LeftChatToggleButton:Click()
		end		
	end
end

local function SetupCVars()
	SetCVar("alternateResourceText", 1)
	SetCVar("statusTextDisplay", "BOTH")
	SetCVar("scriptErrors", 1)
	SetCVar("buffDurations", 1)
	SetCVar("consolidateBuffs", 0)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("nameplateShowFriends", 0)
	SetCVar("nameplateShowFriendlyPets", 0)
	SetCVar("nameplateShowFriendlyGuardians", 0)
	SetCVar("nameplateShowFriendlyTotems", 0)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowEnemyPets", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("cameraDistanceMax", 50)
	SetCVar("cameraDistanceMaxFactor", 4)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "classic")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("ConversationMode", "inline")
	SetCVar("showTutorials", 0)
	SetCVar("autoDismountFlying", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoQuestProgress", 1)
	SetCVar("guildMemberNotify", 0)
	SetCVar("UberTooltips", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("colorblindMode", 0)
	SetCVar("autoLootDefault", 1)
	SetCVar("bloatthreat", 0)
	SetCVar("bloattest", 0)
	SetCVar("bloatnameplates", 0)
	SetCVar("threatWarning", 3)
	SetCVar('alwaysShowActionBars', 1)
	SetCVar('lockActionBars', 1)
	SetCVar("showTimestamps", "%H:%M:%S ")
	SetCVar("deselectOnClick", 1)
	SetCVar("UnitNameFriendlyGuardianName", 1)
	SetCVar("UnitNameOwn", 1)
	SetCVar("UnitNameGuildTitle", 0)
	SetCVar("ActionButtonUseKeyDown", 0)
	SetCVar("interactOnLeftClick", 0)
	SetCVar('SpamFilter', 0) --Blocks mmo-champion.com, dumb... ElvUI one is more effeciant anyways.

	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue('SHIFT')
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()
		
	InstallStepComplete.message = L["CVars Set"]
	InstallStepComplete:Show()					
end	

function E:GetColor(r, b, g, a)	
	return { r = r, b = b, g = g, a = a }
end

function E:SetupPixelPerfect(enabled, noMsg)
	E.private.general.pixelPerfect = enabled;
	
	if (E.PixelMode ~= enabled) then
		E:StaticPopup_Show('PIXELPERFECT_CHANGED')
	end
	
	if InstallStepComplete and not noMsg then
		InstallStepComplete.message = L["Pixel Perfect Set"]
		InstallStepComplete:Show()	
		E:UpdateAll(true)		
	end
	

	E.PixelMode = enabled
end

function E:SetupTheme(theme, noDisplayMsg)
	local classColor = E.myclass == 'PRIEST' and E.PriestColors or RAID_CLASS_COLORS[E.myclass]
	E.private.theme = theme


	--Set colors
	if theme == "classic" then
		E.db.general.bordercolor = E:GetColor(.31, .31, .31)
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)
		
		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(44/255, 44/255, 44/255)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.31, .31, .31)
		E.db.unitframe.colors.castColor = E:GetColor(168/255, 168/255, 168/255)
		E.db.unitframe.colors.castClassColor = false
		
	elseif theme == "class" then
		E.db.general.bordercolor = E:GetColor(.31, .31, .31)
		E.db.general.backdropcolor = E:GetColor(.1, .1, .1)
		E.db.general.backdropfadecolor = E:GetColor(.06, .06, .06, .8)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(classColor.r, classColor.b, classColor.g)
		E.db.unitframe.colors.healthclass = true
		E.db.unitframe.colors.castClassColor = true
	else
		E.db.general.bordercolor = E:GetColor(.2, .2, .2)
		E.db.general.backdropcolor = E:GetColor(.16, .16, .16)
		E.db.general.backdropfadecolor = E:GetColor(.10, .10, .10, .8)
		E.db.unitframe.colors.auraBarBuff = E:GetColor(.2, .2, .2)
		E.db.unitframe.colors.healthclass = false
		E.db.unitframe.colors.health = E:GetColor(.267, .267, .267)
		E.db.unitframe.colors.castColor = E:GetColor(.66, .66, .66)
	end
	
	--Value Color
	if theme == "class" or theme == "default" then
		E.db.general.valuecolor = E:GetColor(classColor.r, classColor.b, classColor.g)
	elseif theme == "classic" then
		E.db.general.valuecolor = E:GetColor(.09, .819, .513)
	end
	
	if not noDisplayMsg then
		E:UpdateAll(true)
	end

	if InstallStatus then
		InstallStatus:SetStatusBarColor(unpack(E['media'].rgbvaluecolor))
		
		if InstallStepComplete and not noDisplayMsg then
			InstallStepComplete.message = L["Theme Set"]
			InstallStepComplete:Show()		
		end	
	end
end

function E:SetupResolution(noDataReset)
	if not noDataReset then
		E:ResetMovers('')
	end

	if not noDataReset then
		E.db.chat.panelWidth = P.chat.panelWidth
		E.db.chat.panelHeight = P.chat.panelHeight
		
		E:CopyTable(E.db.actionbar, P.actionbar)
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)
		E:SetupPixelPerfect(E.PixelMode, true)
		E.db.auras.wrapAfter = P.auras.wrapAfter;	
		E.db.general.reputation.width = P.general.reputation.width
		E.db.general.experience.width = P.general.experience.width
		
		E.db.lowresolutionset = nil;
	end
	
	if not noDataReset and E.private.theme then
		E:SetupTheme(E.private.theme, true)
	end

	E:UpdateAll(true)
	
	if InstallStepComplete and not noDataReset then
		InstallStepComplete.message = L["Resolution Style Set"]
		InstallStepComplete:Show()		
	end
end

function E:SetupLayout(layout, noDataReset)
	--Unitframes
	if not noDataReset then
		E:CopyTable(E.db.unitframe.units, P.unitframe.units)
	end		
	
	if layout == 'healer' then
		if not IsAddOnLoaded('Clique') then
			E:StaticPopup_Show("CLIQUE_ADVERT")
		end
		
		if not noDataReset then
			E.db.unitframe.units.target.buffs.anchorPoint = 'TOPRIGHT';
			E.db.unitframe.units.target.buffs.yOffset = 2;
			E.db.unitframe.units.target.debuffs.anchorPoint = 'TOPRIGHT';
			E.db.unitframe.units.target.debuffs.yOffset = 1;
			
			E.db.unitframe.units.targettarget.height = 35;
			E.db.unitframe.units.targettarget.debuffs.anchorPoint = 'TOPRIGHT';
			E.db.unitframe.units.targettarget.debuffs.yOffset = 1;
			
			E.db.unitframe.units.focus.buffs.anchorPoint = 'TOPLEFT';
			E.db.unitframe.units.focus.buffs.yOffset = 2;
			E.db.unitframe.units.focus.debuffs.anchorPoint = 'TOPLEFT';
			E.db.unitframe.units.focus.debuffs.yOffset = 1;
			E.db.unitframe.units.focus.castbar.yOffset = 0;
			
			E.db.unitframe.units.focustarget.buffs.anchorPoint = 'TOPLEFT';
			E.db.unitframe.units.focustarget.buffs.yOffset = 2;
			E.db.unitframe.units.focustarget.debuffs.anchorPoint = 'TOPLEFT';
			E.db.unitframe.units.focustarget.debuffs.yOffset = 1;
			
			E.db.unitframe.units.boss.growthDirection = 'UP';
			
			E.db.unitframe.units.arena.width = 200;
			E.db.unitframe.units.arena.castbar.width = 200;
			
			E.db.unitframe.units.party.width = 80;
			E.db.unitframe.units.party.horizontalSpacing = 3;
			E.db.unitframe.units.party.healPrediction = true;
			E.db.unitframe.units.party.health.frequentUpdates = true;
			E.db.unitframe.units.party.startFromCenter = true;
			E.db.unitframe.units.party.petsGroup.enable = true;
			E.db.unitframe.units.party.petsGroup.width = 80;
			E.db.unitframe.units.party.petsGroup.yOffset = 3;
			E.db.unitframe.units.party.targetsGroup.enable = false;

			E.db.unitframe.units.raid10.width = 80;
			E.db.unitframe.units.raid10.horizontalSpacing = 3;
			E.db.unitframe.units.raid10.healPrediction = true;
			E.db.unitframe.units.raid10.health.frequentUpdates = true;
			E.db.unitframe.units.raid10.startFromCenter = true;

			E.db.unitframe.units.raid25.width = 80;
			E.db.unitframe.units.raid25.horizontalSpacing = 3;
			E.db.unitframe.units.raid25.healPrediction = true;
			E.db.unitframe.units.raid25.health.frequentUpdates = true;
			E.db.unitframe.units.raid25.startFromCenter = true;
			
			E.db.unitframe.units.raid40.width = 80;
			E.db.unitframe.units.raid40.horizontalSpacing = 3;
			E.db.unitframe.units.raid40.healPrediction = true;
			E.db.unitframe.units.raid40.health.frequentUpdates = true;
			E.db.unitframe.units.raid40.startFromCenter = true;
			E.db.unitframe.units.raid40.rdebuffs.enable = true;
			E.db.unitframe.units.raid40.rdebuffs.size = 18;
		end
			
		if not E.db.movers then E.db.movers = {}; end
		E.db.movers.ElvUF_PlayerMover = "BOTTOMLEFTElvUIParentBOTTOMLEFT490170"
		E.db.movers.ElvUF_TargetMover = "BOTTOMRIGHTElvUIParentBOTTOMRIGHT-490170"
		E.db.movers.ElvUF_Raid40Mover = "BOTTOMElvUIParentBOTTOM0170"
		E.db.movers.ElvUF_Raid25Mover = "BOTTOMElvUIParentBOTTOM0170"
		E.db.movers.ElvUF_Raid10Mover = "BOTTOMElvUIParentBOTTOM0170"
		E.db.movers.ElvUF_TargetTargetMover = "BOTTOMRIGHTElvUF_TargetBOTTOMRIGHT0150"
		E.db.movers.ElvUF_PartyMover = "BOTTOMElvUIParentBOTTOM0170"
		E.db.movers.ElvUF_PetMover = "BOTTOMLEFTElvUIParentBOTTOMLEFT490120"
		E.db.movers.ElvUF_FocusMover = "BOTTOMLEFTElvUF_PlayerBOTTOMLEFT0150"
		E.db.movers.ElvUF_FocusTargetMover = "BOTTOMLEFTElvUF_FocusBOTTOMLEFT0150"
		E.db.movers.ElvUF_TankMover = "LEFTElvUIParentLEFT4350"
		E.db.movers.ElvUF_AssistMover = "LEFTElvUIParentLEFT4250"
		if BossHeaderMover then
			BossHeaderMover:ClearAllPoints()
			BossHeaderMover:SetPoint("BOTTOMLEFT",E.UIParent,"BOTTOMLEFT",4,250)
			E:SaveMoverPosition("BossHeaderMover")
		end
		if BossButton then
			BossButton:ClearAllPoints()
			BossButton:SetPoint("BOTTOM",E.UIParent,"BOTTOM",425,75)
			E:SaveMoverPosition("BossButton")
		end
		if AltPowerBarMover then
			AltPowerBarMover:ClearAllPoints()
			AltPowerBarMover:SetPoint("BOTTOM",E.UIParent,"BOTTOM",425,20)
			E:SaveMoverPosition("AltPowerBarMover")
		end
	else
		if not noDataReset then
			E:ResetMovers('')
			E:SetupPixelPerfect(E.PixelMode, true)
		end
	end
	
	--Datatexts
	if not noDataReset then
		E:CopyTable(E.db.datatexts.panels, P.datatexts.panels)
		if layout == 'tank' then
			E.db.datatexts.panels.LeftChatDataPanel.left = 'Armor';
			E.db.datatexts.panels.LeftChatDataPanel.middle = 'Attack Power';
			E.db.datatexts.panels.LeftChatDataPanel.right = 'Avoidance';
		elseif layout == 'healer' or layout == 'dpsCaster' then
			E.db.datatexts.panels.LeftChatDataPanel.left = 'Spell/Heal Power';
			E.db.datatexts.panels.LeftChatDataPanel.middle = 'Haste';
			E.db.datatexts.panels.LeftChatDataPanel.right = 'Mastery';
		else
			E.db.datatexts.panels.LeftChatDataPanel.left = 'Attack Power';
			E.db.datatexts.panels.LeftChatDataPanel.middle = 'Haste';
			E.db.datatexts.panels.LeftChatDataPanel.right = 'Crit Chance';
		end

		if InstallStepComplete then
			InstallStepComplete.message = L["Layout Set"]
			InstallStepComplete:Show()	
		end		
	end
	
	E.db.layoutSet = layout
	
	if not noDataReset and E.private.theme then
		E:SetupTheme(E.private.theme, true)
	end	
	
	E:UpdateAll(true)
	local DT = E:GetModule('DataTexts')
	DT:LoadDataTexts()
end


local function SetupAuras(style)
	if not style then
		--PLAYER
		E.db.unitframe.units.player.buffs.enable = true;
		E.db.unitframe.units.player.buffs.attachTo = 'FRAME';
		E.db.unitframe.units.player.buffs.noDuration = false;
		
		E.db.unitframe.units.player.debuffs.attachTo = 'BUFFS';

		E.db.unitframe.units.player.aurabar.enable = false;
		
		--TARGET
		E.db.unitframe.units.target.smartAuraDisplay = 'DISABLED';
		E.db.unitframe.units.target.debuffs.enable = true;
		E.db.unitframe.units.target.aurabar.enable = false;
	elseif style == 'integrated' then
		--seriosly is this fucking hard??
		E.db.unitframe.units.target.smartAuraDisplay = 'SHOW_DEBUFFS_ON_FRIENDLIES';
		E.db.unitframe.units.target.buffs.playerOnly = {friendly = true, enemy = false};
		E.db.unitframe.units.target.debuffs.enable = false;
		E.db.unitframe.units.target.aurabar.attachTo = 'BUFFS';
	end

	E:GetModule('UnitFrames'):Update_AllFrames()	
	if InstallStepComplete then
		InstallStepComplete.message = L["Auras Set"]
		InstallStepComplete:Show()		
	end	
end

local function InstallComplete()
	E.private.install_complete = E.version
	
	if GetCVarBool("Sound_EnableMusic") then
		StopMusic()
	end

	ReloadUI()
end
		
local function ResetAll()
	InstallNextButton:Disable()
	InstallPrevButton:Disable()
	InstallOption1Button:Hide()
	InstallOption1Button:SetScript("OnClick", nil)
	InstallOption1Button:SetText("")
	InstallOption2Button:Hide()
	InstallOption2Button:SetScript('OnClick', nil)
	InstallOption2Button:SetText('')
	InstallOption3Button:Hide()
	InstallOption3Button:SetScript('OnClick', nil)
	InstallOption3Button:SetText('')	
	InstallOption4Button:Hide()
	InstallOption4Button:SetScript('OnClick', nil)
	InstallOption4Button:SetText('')
	ElvUIInstallFrame.SubTitle:SetText("")
	ElvUIInstallFrame.Desc1:SetText("")
	ElvUIInstallFrame.Desc2:SetText("")
	ElvUIInstallFrame.Desc3:SetText("")
	ElvUIInstallFrame:Size(550, 400)
end

local function SetPage(PageNum)
	CURRENT_PAGE = PageNum
	ResetAll()
	InstallStatus:SetValue(PageNum)
	
	local f = ElvUIInstallFrame
	
	if PageNum == MAX_PAGE then
		InstallNextButton:Disable()
	else
		InstallNextButton:Enable()
	end
	
	if PageNum == 1 then
		InstallPrevButton:Disable()
	else
		InstallPrevButton:Enable()
	end

	if PageNum == 1 then
		f.SubTitle:SetText(format(L["Welcome to ElvUI version %s!"], E.version))
		f.Desc1:SetText(L["This install process will help you learn some of the features in ElvUI has to offer and also prepare your user interface for usage."])
		f.Desc2:SetText(L["The in-game configuration menu can be accesses by typing the /ec command or by clicking the 'C' button on the minimap. Press the button below if you wish to skip the installation process."])
		f.Desc3:SetText(L["Please press the continue button to go onto the next step."])
				
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Skip Process"])			
	elseif PageNum == 2 then
		f.SubTitle:SetText(L["CVars"])
		f.Desc1:SetText(L["This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."])
		f.Desc2:SetText(L["Please click the button below to setup your CVars."])
		f.Desc3:SetText(L["Importance: |cff07D400High|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", SetupCVars)
		InstallOption1Button:SetText(L["Setup CVars"])
	elseif PageNum == 3 then
		f.SubTitle:SetText(L["Chat"])
		f.Desc1:SetText(L["This part of the installation process sets up your chat windows names, positions and colors."])
		f.Desc2:SetText(L["The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", SetupChat)
		InstallOption1Button:SetText(L["Setup Chat"])
	elseif PageNum == 4 then
		f.SubTitle:SetText(L["Pixel Perfect"])
		f.Desc1:SetText(L['The Pixel Perfect option will change the overall apperance of your UI. Using Pixel Perfect is a slight performance increase over the traditional layout.'])
		f.Desc2:SetText(L['Using this option will cause your borders around frames to be 1 pixel wide instead of 3 pixel. You may have to finish the installation to notice a differance. By default this is enabled.'])
		f.Desc3:SetText(L["Importance: |cffFF0000Low|r"])
		
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupPixelPerfect(true) end)
		InstallOption1Button:SetText(L["Enable"])	
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E:SetupPixelPerfect(false) end)
		InstallOption2Button:SetText(L['Disable'])			
	elseif PageNum == 5 then
		f.SubTitle:SetText(L['Theme Setup'])
		f.Desc1:SetText(L['Choose a theme layout you wish to use for your initial setup.'])
		f.Desc2:SetText(L['You can always change fonts and colors of any element of elvui from the in-game configuration.'])
		f.Desc3:SetText(L["Importance: |cffFF0000Low|r"])

		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E:SetupTheme('classic') end)
		InstallOption1Button:SetText(L["Classic"])	
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E:SetupTheme('default') end)
		InstallOption2Button:SetText(L['Dark'])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E:SetupTheme('class') end)
		InstallOption3Button:SetText(CLASS)		
	elseif PageNum == 6 then
		f.SubTitle:SetText(L["Resolution"])
		f.Desc1:SetText(format(L["Your current resolution is %s, this is considered a %s resolution."], E.resolution, E.lowversion == true and L["low"] or L["high"]))
		if E.lowversion then
			f.Desc2:SetText(L["This resolution requires that you change some settings to get everything to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["You may need to further alter these settings depending how low you resolution is."])
			f.Desc3:SetText(L["Importance: |cff07D400High|r"])
		else
			f.Desc2:SetText(L["This resolution doesn't require that you change settings for the UI to fit on your screen."].." "..L["Click the button below to resize your chat frames, unitframes, and reposition your actionbars."].." "..L["This is completely optional."])
			f.Desc3:SetText(L["Importance: |cffFF0000Low|r"])
		end
		
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E.SetupResolution('high') end)
		InstallOption1Button:SetText(L["High Resolution"])
	elseif PageNum == 7 then
		f.SubTitle:SetText(L["Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use based on your combat role."])
		f.Desc2:SetText(L["This will change the layout of your unitframes, raidframes, and datatexts."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('tank') end)
		InstallOption1Button:SetText(L['Tank'])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('healer') end)
		InstallOption2Button:SetText(L['Healer'])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('dpsMelee') end)
		InstallOption3Button:SetText(L['Physical DPS'])
		InstallOption4Button:Show()
		InstallOption4Button:SetScript('OnClick', function() E.db.layoutSet = nil; E:SetupLayout('dpsCaster') end)
		InstallOption4Button:SetText(L['Caster DPS'])
	elseif PageNum == 8 then
		f.SubTitle:SetText(L["Auras System"])
		f.Desc1:SetText(L["Select the type of aura system you want to use with ElvUI's unitframes. The integrated system utilizes both aura-bars and aura-icons. The icons only system will display only icons and aurabars won't be used. The classic system will configure your auras to be default."])
		f.Desc2:SetText(L["If you have an icon or aurabar that you don't want to display simply hold down shift and right click the icon for it to disapear."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallOption1Button:Show()
		InstallOption1Button:SetScript('OnClick', function() SetupAuras('classic') end)
		InstallOption1Button:SetText(L['Classic'])
		InstallOption2Button:Show()
		InstallOption2Button:SetScript('OnClick', function() SetupAuras() end)
		InstallOption2Button:SetText(L['Icons Only'])
		InstallOption3Button:Show()
		InstallOption3Button:SetScript('OnClick', function() SetupAuras('integrated') end)
		InstallOption3Button:SetText(L['Integrated'])		
	elseif PageNum == 9 then
		f.SubTitle:SetText(L["Installation Complete"])
		f.Desc1:SetText(L["You are now finished with the installation process. If you are in need of technical support please visit us at http://www.tukui.org."])
		f.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])			
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Finished"])				
		ElvUIInstallFrame:Size(550, 350)
	end
end

local function NextPage()	
	if CURRENT_PAGE ~= MAX_PAGE then
		CURRENT_PAGE = CURRENT_PAGE + 1
		SetPage(CURRENT_PAGE)
	end
end

local function PreviousPage()
	if CURRENT_PAGE ~= 1 then
		CURRENT_PAGE = CURRENT_PAGE - 1
		SetPage(CURRENT_PAGE)
	end
end

--Install UI
function E:Install()	
	if not InstallStepComplete then
		local imsg = CreateFrame("Frame", "InstallStepComplete", E.UIParent)
		imsg:Size(418, 72)
		imsg:Point("TOP", 0, -190)
		imsg:Hide()
		imsg:SetScript('OnShow', function(self)
			if self.message then 
				PlaySoundFile([[Sound\Interface\LevelUp.wav]])
				self.text:SetText(self.message)
				UIFrameFadeOut(self, 3.5, 1, 0)
				E:Delay(4, function() self:Hide() end)	
				self.message = nil
				
				if imsg.firstShow == false then
					if GetCVarBool("Sound_EnableMusic") then
						PlayMusic([[Sound\Music\ZoneMusic\DMF_L70ETC01.mp3]])
					end					
					imsg.firstShow = true
				end
			else
				self:Hide()
			end
		end)
		
		imsg.firstShow = false
		
		imsg.bg = imsg:CreateTexture(nil, 'BACKGROUND')
		imsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
		imsg.bg:SetPoint('BOTTOM')
		imsg.bg:Size(326, 103)
		imsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
		imsg.bg:SetVertexColor(1, 1, 1, 0.6)
		
		imsg.lineTop = imsg:CreateTexture(nil, 'BACKGROUND')
		imsg.lineTop:SetDrawLayer('BACKGROUND', 2)
		imsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
		imsg.lineTop:SetPoint("TOP")
		imsg.lineTop:Size(418, 7)
		imsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
		
		imsg.lineBottom = imsg:CreateTexture(nil, 'BACKGROUND')
		imsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
		imsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
		imsg.lineBottom:SetPoint("BOTTOM")
		imsg.lineBottom:Size(418, 7)
		imsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
		
		imsg.text = imsg:CreateFontString(nil, 'ARTWORK', 'GameFont_Gigantic')
		imsg.text:Point("BOTTOM", 0, 12)
		imsg.text:SetTextColor(1, 0.82, 0)
		imsg.text:SetJustifyH("CENTER")
	end

	--Create Frame
	if not ElvUIInstallFrame then
		local f = CreateFrame("Button", "ElvUIInstallFrame", E.UIParent)
		f.SetPage = SetPage
		f:Size(550, 400)
		f:SetTemplate("Transparent")
		f:SetPoint("CENTER")
		f:SetFrameStrata('TOOLTIP')
		
		f.Title = f:CreateFontString(nil, 'OVERLAY')
		f.Title:FontTemplate(nil, 17, nil)
		f.Title:Point("TOP", 0, -5)
		f.Title:SetText(L["ElvUI Installation"])
		
		f.Next = CreateFrame("Button", "InstallNextButton", f, "UIPanelButtonTemplate")
		f.Next:StripTextures()
		f.Next:SetTemplate("Default", true)
		f.Next:Size(110, 25)
		f.Next:Point("BOTTOMRIGHT", -5, 5)
		f.Next:SetText(CONTINUE)
		f.Next:Disable()
		f.Next:SetScript("OnClick", NextPage)
		E.Skins:HandleButton(f.Next, true)
		
		f.Prev = CreateFrame("Button", "InstallPrevButton", f, "UIPanelButtonTemplate")
		f.Prev:StripTextures()
		f.Prev:SetTemplate("Default", true)
		f.Prev:Size(110, 25)
		f.Prev:Point("BOTTOMLEFT", 5, 5)
		f.Prev:SetText(PREVIOUS)	
		f.Prev:Disable()
		f.Prev:SetScript("OnClick", PreviousPage)
		E.Skins:HandleButton(f.Prev, true)
		
		f.Status = CreateFrame("StatusBar", "InstallStatus", f)
		f.Status:SetFrameLevel(f.Status:GetFrameLevel() + 2)
		f.Status:CreateBackdrop("Default")
		f.Status:SetStatusBarTexture(E["media"].normTex)
		f.Status:SetStatusBarColor(unpack(E["media"].rgbvaluecolor))
		f.Status:SetMinMaxValues(0, MAX_PAGE)
		f.Status:Point("TOPLEFT", f.Prev, "TOPRIGHT", 6, -2)
		f.Status:Point("BOTTOMRIGHT", f.Next, "BOTTOMLEFT", -6, 2)
		f.Status.text = f.Status:CreateFontString(nil, 'OVERLAY')
		f.Status.text:FontTemplate()
		f.Status.text:SetPoint("CENTER")
		f.Status.text:SetText(CURRENT_PAGE.." / "..MAX_PAGE)
		f.Status:SetScript("OnValueChanged", function(self)
			self.text:SetText(self:GetValue().." / "..MAX_PAGE)
		end)
		
		f.Option1 = CreateFrame("Button", "InstallOption1Button", f, "UIPanelButtonTemplate")
		f.Option1:StripTextures()
		f.Option1:Size(160, 30)
		f.Option1:Point("BOTTOM", 0, 45)
		f.Option1:SetText("")
		f.Option1:Hide()
		E.Skins:HandleButton(f.Option1, true)
		
		f.Option2 = CreateFrame("Button", "InstallOption2Button", f, "UIPanelButtonTemplate")
		f.Option2:StripTextures()
		f.Option2:Size(110, 30)
		f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45)
		f.Option2:SetText("")
		f.Option2:Hide()
		f.Option2:SetScript('OnShow', function() f.Option1:SetWidth(110); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45) end)
		f.Option2:SetScript('OnHide', function() f.Option1:SetWidth(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45) end)
		E.Skins:HandleButton(f.Option2, true)		
		
		f.Option3 = CreateFrame("Button", "InstallOption3Button", f, "UIPanelButtonTemplate")
		f.Option3:StripTextures()
		f.Option3:Size(100, 30)
		f.Option3:Point('LEFT', f.Option2, 'RIGHT', 4, 0)
		f.Option3:SetText("")
		f.Option3:Hide()
		f.Option3:SetScript('OnShow', function() f.Option1:SetWidth(100); f.Option1:ClearAllPoints(); f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0); f.Option2:SetWidth(100); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45)  end)
		f.Option3:SetScript('OnHide', function() f.Option1:SetWidth(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45); f.Option2:SetWidth(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
		E.Skins:HandleButton(f.Option3, true)			
		
		f.Option4 = CreateFrame("Button", "InstallOption4Button", f, "UIPanelButtonTemplate")
		f.Option4:StripTextures()
		f.Option4:Size(100, 30)
		f.Option4:Point('LEFT', f.Option3, 'RIGHT', 4, 0)
		f.Option4:SetText("")
		f.Option4:Hide()
		f.Option4:SetScript('OnShow', function() 
			f.Option1:Width(100)
			f.Option2:Width(100)
			
			f.Option1:ClearAllPoints(); 
			f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0); 
			f.Option2:ClearAllPoints(); 
			f.Option2:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45)  
		end)
		f.Option4:SetScript('OnHide', function() f.Option1:SetWidth(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45); f.Option2:SetWidth(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
		E.Skins:HandleButton(f.Option4, true)					

		f.SubTitle = f:CreateFontString(nil, 'OVERLAY')
		f.SubTitle:FontTemplate(nil, 15, nil)		
		f.SubTitle:Point("TOP", 0, -40)
		
		f.Desc1 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc1:FontTemplate()	
		f.Desc1:Point("TOPLEFT", 20, -75)	
		f.Desc1:Width(f:GetWidth() - 40)
		
		f.Desc2 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc2:FontTemplate()	
		f.Desc2:Point("TOPLEFT", 20, -125)		
		f.Desc2:Width(f:GetWidth() - 40)
		
		f.Desc3 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc3:FontTemplate()	
		f.Desc3:Point("TOPLEFT", 20, -175)	
		f.Desc3:Width(f:GetWidth() - 40)
		
		local close = CreateFrame("Button", "InstallCloseButton", f, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", f, "TOPRIGHT")
		close:SetScript("OnClick", function()
			f:Hide()
		end)		
		E.Skins:HandleCloseButton(close)
		
		f.tutorialImage = f:CreateTexture('InstallTutorialImage', 'OVERLAY')
		f.tutorialImage:Size(256, 128)
		f.tutorialImage:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\logo_elvui.tga')
		f.tutorialImage:Point('BOTTOM', 0, 70)

	end
	
	ElvUIInstallFrame:Show()
	NextPage()
end