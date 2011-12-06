local E, L, DF = unpack(select(2, ...)); --Engine

local CURRENT_PAGE = 0
local MAX_PAGE = 4

local function SetupChat()
	InstallStepComplete.message = L["Chat Set"]
	InstallStepComplete:Show()			
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_OpenNewWindow(GUILD)
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_OpenNewWindow(PARTY)
	FCF_DockFrame(ChatFrame4)
	FCF_SetLocked(ChatFrame4, 1)
	FCF_OpenNewWindow(WHISPER)
	FCF_DockFrame(ChatFrame5)
	FCF_SetLocked(ChatFrame5, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_UnDockFrame(ChatFrame6)
	FCF_SetLocked(ChatFrame6, 1)
	ChatFrame6:Show()
			
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		local chatFrameId = frame:GetID()
		local chatName = FCF_GetChatWindowInfo(chatFrameId)
		
		-- move general bottom left
		if i == 1 then
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", LeftChatToggleButton, "TOPLEFT", 1, 3)			
		elseif i == 6 then
			frame:ClearAllPoints()
			frame:Point("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 1, 3)
		end
		
		FCF_SavePositionAndDimensions(frame)
		FCF_StopDragging(frame)
		
		-- set default Elvui font size
		FCF_SetChatWindowFontSize(nil, frame, 13)
		
		-- rename windows general because moved to chat #3
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

	
	-- enable classcolor automatically on login and on each character without doing /configure each time.
	ToggleChatColorNamesByClassGroup(false, "SAY")
	ToggleChatColorNamesByClassGroup(false, "EMOTE")
	ToggleChatColorNamesByClassGroup(false, "YELL")
	ToggleChatColorNamesByClassGroup(false, "GUILD")
	ToggleChatColorNamesByClassGroup(false, "OFFICER")
	ToggleChatColorNamesByClassGroup(false, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(false, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(false, "PARTY")
	ToggleChatColorNamesByClassGroup(false, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(false, "RAID")
	ToggleChatColorNamesByClassGroup(false, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(false, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(false, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(false, "BATTLEGROUND_LEADER")	
	ToggleChatColorNamesByClassGroup(false, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(false, "CHANNEL11")
	

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
	SetCVar("scriptErrors", 1)
	SetCVar("gxTextureCacheSize", 512)
	SetCVar("buffDurations", 1)
	SetCVar("consolidateBuffs", 0)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("scriptErrors", 1)
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
	SetCVar("CombatDamage", 1)
	SetCVar("CombatHealing", 1)
	SetCVar("showTutorials", 0)
	SetCVar("showNewbieTips", 0)
	SetCVar("autoDismountFlying", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoQuestProgress", 1)
	SetCVar("showLootSpam", 1)
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
	InstallStepComplete.message = L["CVars Set"]
	InstallStepComplete:Show()					
end	

local function InstallComplete()
	E.db.install_complete = true
	
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
	ElvUIInstallFrame.SubTitle:SetText("")
	ElvUIInstallFrame.Desc1:SetText("")
	ElvUIInstallFrame.Desc2:SetText("")
	ElvUIInstallFrame.Desc3:SetText("")
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
		f.SubTitle:SetText(L["Installation Complete"])
		f.Desc1:SetText(L["You are now finished with the installation process. If you are in need technical support please visit us at www.tukui.org."])
		f.Desc2:SetText(L["Please click the button below so you can setup variables and ReloadUI."])			
		InstallOption1Button:Show()
		InstallOption1Button:SetScript("OnClick", InstallComplete)
		InstallOption1Button:SetText(L["Finished"])								
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
	end
	
	ElvUIInstallFrame:Show()
	NextPage()
end