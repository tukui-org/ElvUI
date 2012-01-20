local E, L, DF = unpack(select(2, ...)); --Engine

local CURRENT_PAGE = 0
local MAX_PAGE = 6

local function SetupChat()
	InstallStepComplete.message = L["Chat Set"]
	InstallStepComplete:Show()			
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_UnDockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	ChatFrame3:Show()			
			
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		local chatFrameId = frame:GetID()
		local chatName = FCF_GetChatWindowInfo(chatFrameId)
		
		-- move general bottom left
		if i == 1 then
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)			
		elseif i == 3 then
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
		end
		
		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
		
		-- set default Elvui font size
		FCF_SetChatWindowFontSize(nil, frame, 12)
		
		-- rename windows general because moved to chat #3
		if i == 1 then
			FCF_SetWindowName(frame, GENERAL)
		elseif i == 2 then
			FCF_SetWindowName(frame, GUILD_EVENT_LOG)
		elseif i == 3 then 
			FCF_SetWindowName(frame, LOOT.." / "..TRADE) 
		end
	end
	
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")
	

	ChatFrame_RemoveAllMessageGroups(ChatFrame3)	
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
	ChatFrame_AddChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, L['Trade'])
	ChatFrame_AddChannel(ChatFrame3, L['Trade'])

	
	if E.myname == "Elv" then
		--keep losing my god damn channels everytime i resetui
		ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "tystank")
		ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "tys")
		ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, "crusaderaura")
		ChangeChatColor("CHANNEL5", 147/255, 112/255, 219/255)
		ChangeChatColor("CHANNEL6", 139/255, 115/255, 85/255)
		ChangeChatColor("CHANNEL7", RAID_CLASS_COLORS["PALADIN"].r, RAID_CLASS_COLORS["PALADIN"].g, RAID_CLASS_COLORS["PALADIN"].b)
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
	
	--Adjust Chat Colors
	--General
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	--Trade
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	--Local Defense
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)
	
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
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "classic")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("ConversationMode", "inline")
	SetCVar("showTutorials", 0)
	SetCVar("showNewbieTips", 0)
	SetCVar("showLootSpam", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("threatWarning", 3)
	SetCVar('alwaysShowActionBars', 1)
	InstallStepComplete.message = L["CVars Set"]
	InstallStepComplete:Show()					
end	

local function SetupLayout(isPrimary, layout)
	if isPrimary then
		if layout == 'tank' then
			--datatexts
			E.db.datatexts.panels.spec1.LeftChatDataPanel.left = 'Armor';
			E.db.datatexts.panels.spec1.LeftChatDataPanel.right = 'Avoidance';
			
			--unitframes
			E.db.unitframe.mainSpec = 'Primary';
		elseif layout == 'healer' then
			--datatexts
			E.db.datatexts.panels.spec1.LeftChatDataPanel.left = 'Spell/Heal Power';
			E.db.datatexts.panels.spec1.LeftChatDataPanel.right = 'Haste';
			
			--unitframes
			E.db.unitframe.mainSpec = 'Secondary';		
		elseif layout == 'dpsCaster' then
			--datatexts
			E.db.datatexts.panels.spec1.LeftChatDataPanel.left = 'Spell/Heal Power';
			E.db.datatexts.panels.spec1.LeftChatDataPanel.right = 'Haste';
			
			--unitframes
			E.db.unitframe.mainSpec = 'Primary';			
		else
			--datatexts
			E.db.datatexts.panels.spec1.LeftChatDataPanel.left = 'Attack Power';
			E.db.datatexts.panels.spec1.LeftChatDataPanel.right = 'Crit Chance';
			
			--unitframes
			E.db.unitframe.mainSpec = 'Primary';			
		end
		
		InstallStepComplete.message = L["Primary Layout Set"]
		InstallStepComplete:Show()	
	else
		if layout == 'tank' then
			--datatexts
			E.db.datatexts.panels.spec2.LeftChatDataPanel.left = 'Armor';
			E.db.datatexts.panels.spec2.LeftChatDataPanel.right = 'Avoidance';
			
			--unitframes
			E.db.unitframe.offSpec = 'Primary';
		elseif layout == 'healer' then
			--datatexts
			E.db.datatexts.panels.spec2.LeftChatDataPanel.left = 'Spell/Heal Power';
			E.db.datatexts.panels.spec2.LeftChatDataPanel.right = 'Haste';
			
			--unitframes
			E.db.unitframe.offSpec = 'Secondary';		
		elseif layout == 'dpsCaster' then
			--datatexts
			E.db.datatexts.panels.spec2.LeftChatDataPanel.left = 'Spell/Heal Power';
			E.db.datatexts.panels.spec2.LeftChatDataPanel.right = 'Haste';
			
			--unitframes
			E.db.unitframe.offSpec = 'Primary';			
		else
			--datatexts
			E.db.datatexts.panels.spec2.LeftChatDataPanel.left = 'Attack Power';
			E.db.datatexts.panels.spec2.LeftChatDataPanel.right = 'Crit Chance';
			
			--unitframes
			E.db.unitframe.offSpec = 'Primary';			
		end
		
		InstallStepComplete.message = L["Secondary Layout Set"]
		InstallStepComplete:Show()			
	end
end

local function InstallComplete()
	E.db.install_complete = E.version
	
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
	InstallRoleOptionTank:Hide()
	InstallRoleOptionTank:SetScript('OnClick', nil)
	InstallRoleOptionHealer:Hide()
	InstallRoleOptionHealer:SetScript('OnClick', nil)
	InstallRoleOptionMeleeDPS:Hide()
	InstallRoleOptionMeleeDPS:SetScript('OnClick', nil)	
	InstallRoleOptionCasterDPS:Hide()
	InstallRoleOptionCasterDPS:SetScript('OnClick', nil)		
	ElvUIInstallFrame.SubTitle:SetText("")
	ElvUIInstallFrame.Desc1:SetText("")
	ElvUIInstallFrame.Desc2:SetText("")
	ElvUIInstallFrame.Desc3:SetText("")
	InstallTutorialImage:SetTexture(nil)
	InstallTutorialImage:Hide()
	ElvUIInstallFrame:Size(550, 400)
end

local function SetPage(PageNum)
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
		f.SubTitle:SetText(L["Primary Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use for your primary talents."])
		f.Desc2:SetText(L["This will change the layout of your unitframes, raidframes, and datatexts."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallRoleOptionTank:Show()
		InstallRoleOptionTank:SetScript('OnClick', function() SetupLayout(true, 'tank') end)
		InstallRoleOptionHealer:Show()
		InstallRoleOptionHealer:SetScript('OnClick', function() SetupLayout(true, 'healer') end)
		InstallRoleOptionMeleeDPS:Show()
		InstallRoleOptionMeleeDPS:SetScript('OnClick', function() SetupLayout(true, 'dpsMelee') end)
		InstallRoleOptionCasterDPS:Show()
		InstallRoleOptionCasterDPS:SetScript('OnClick', function() SetupLayout(true, 'dpsCaster') end)		
	elseif PageNum == 5 then
		f.SubTitle:SetText(L["Secondary Layout"])
		f.Desc1:SetText(L["You can now choose what layout you wish to use for your secondary talents."])
		f.Desc2:SetText(L["This will change the layout of your unitframes, raidframes, and datatexts."])
		f.Desc3:SetText(L["Importance: |cffD3CF00Medium|r"])
		InstallRoleOptionTank:Show()
		InstallRoleOptionTank:SetScript('OnClick', function() SetupLayout(false, 'tank') end)
		InstallRoleOptionHealer:Show()
		InstallRoleOptionHealer:SetScript('OnClick', function() SetupLayout(false, 'healer') end)
		InstallRoleOptionMeleeDPS:Show()
		InstallRoleOptionMeleeDPS:SetScript('OnClick', function() SetupLayout(false, 'dpsMelee') end)
		InstallRoleOptionCasterDPS:Show()
		InstallRoleOptionCasterDPS:SetScript('OnClick', function() SetupLayout(false, 'dpsCaster') end)	
	elseif PageNum == 6 then
		f.SubTitle:SetText(L["Installation Complete"])
		f.Desc1:SetText(L["You are now finished with the installation process. Bonus Hint: If you wish to access blizzard micro menu, middle click on the minimap. If you don't have a middle click button then hold down shift and right click the minimap. If you are in need of technical support please visit us at www.tukui.org."])
		f.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])			
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Finished"])				
		InstallTutorialImage:Show()
		InstallTutorialImage:SetTexture([[Interface\AddOns\ElvUI\media\textures\micromenu_tutorial.tga]])
		ElvUIInstallFrame:Size(550, 500)
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
		local f = CreateFrame("Frame", "ElvUIInstallFrame", E.UIParent)
		f:Size(550, 400)
		f:SetTemplate("Default")
		f:CreateShadow("Default")
		f:SetPoint("CENTER")
		
		f.Title = f:CreateFontString(nil, 'OVERLAY')
		f.Title:FontTemplate(nil, 17, nil)
		f.Title:Point("TOP", 0, -5)
		f.Title:SetText(L["ElvUI Installation"])
		
		f.Next = CreateFrame("Button", "InstallNextButton", f, "UIPanelButtonTemplate2")
		f.Next:StripTextures()
		f.Next:SetTemplate("Default", true)
		f.Next:Size(110, 25)
		f.Next:Point("BOTTOMRIGHT", -5, 5)
		f.Next:SetText(CONTINUE)
		f.Next:Disable()
		f.Next:SetScript("OnClick", NextPage)
		E.Skins:HandleButton(f.Next, true)
		
		f.Prev = CreateFrame("Button", "InstallPrevButton", f, "UIPanelButtonTemplate2")
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
		
		f.Option1 = CreateFrame("Button", "InstallOption1Button", f, "UIPanelButtonTemplate2")
		f.Option1:StripTextures()
		f.Option1:SetTemplate("Default", true)
		f.Option1:Size(160, 30)
		f.Option1:Point("BOTTOM", 0, 45)
		f.Option1:SetText("")
		f.Option1:Hide()
		E.Skins:HandleButton(f.Option1, true)
		
		f.RoleOptionTank = CreateFrame('Button', 'InstallRoleOptionTank', f, 'UIPanelButtonTemplate2')
		f.RoleOptionTank:StripTextures()
		f.RoleOptionTank:SetTemplate("Default", true)
		f.RoleOptionTank:Size(100, 30)
		f.RoleOptionTank:Point("BOTTOM", 50, 45)
		f.RoleOptionTank:SetText(L['Tank'])
		f.RoleOptionTank:Hide()
		E.Skins:HandleButton(f.RoleOptionTank, true)
		
		f.RoleOptionHealer = CreateFrame('Button', 'InstallRoleOptionHealer', f, 'UIPanelButtonTemplate2')
		f.RoleOptionHealer:StripTextures()
		f.RoleOptionHealer:SetTemplate("Default", true)
		f.RoleOptionHealer:Size(100, 30)
		f.RoleOptionHealer:Point("LEFT", f.RoleOptionTank, 'RIGHT', 3, 0)
		f.RoleOptionHealer:SetText(L['Healer'])
		f.RoleOptionHealer:Hide()
		E.Skins:HandleButton(f.RoleOptionHealer, true)		
		
		f.RoleOptionMeleeDPS = CreateFrame('Button', 'InstallRoleOptionMeleeDPS', f, 'UIPanelButtonTemplate2')
		f.RoleOptionMeleeDPS:StripTextures()
		f.RoleOptionMeleeDPS:SetTemplate("Default", true)
		f.RoleOptionMeleeDPS:Size(100, 30)
		f.RoleOptionMeleeDPS:Point("RIGHT", f.RoleOptionTank, 'LEFT', -3, 0)
		f.RoleOptionMeleeDPS:SetText(L['Melee DPS'])
		f.RoleOptionMeleeDPS:Hide()
		E.Skins:HandleButton(f.RoleOptionMeleeDPS, true)			

		f.RoleOptionCasterDPS = CreateFrame('Button', 'InstallRoleOptionCasterDPS', f, 'UIPanelButtonTemplate2')
		f.RoleOptionCasterDPS:StripTextures()
		f.RoleOptionCasterDPS:SetTemplate("Default", true)
		f.RoleOptionCasterDPS:Size(100, 30)
		f.RoleOptionCasterDPS:Point("RIGHT", f.RoleOptionMeleeDPS, 'LEFT', -3, 0)
		f.RoleOptionCasterDPS:SetText(L['Caster DPS'])
		f.RoleOptionCasterDPS:Hide()
		E.Skins:HandleButton(f.RoleOptionCasterDPS, true)		
		
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
		f.tutorialImage:Size(250)
		f.tutorialImage:Point('BOTTOM', f.Option1, 'TOP', 0, 4)

	end
	
	ElvUIInstallFrame:Show()
	NextPage()
end