--This file contains the Install process and everything we do after PLAYER_ENTERING_WORLD event.

local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
	
--Install UI
function E.Install()	
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
				E.Delay(5, function() self:Hide() end)	
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

	local CURRENT_PAGE = 0
	local MAX_PAGE = 7
	
	local function InstallComplete()
		ElvuiData[E.myrealm][E.myname].v2_installed = true
		FoolsDay = nil
		
		if GetCVarBool("Sound_EnableMusic") then
			StopMusic()
		end
		
		ReloadUI()
	end
	
	local function ResetUFPos()
		E.SavePath["UFPos"] = nil
		InstallStepComplete.message = L.ElvUIInstall_UFSet
		InstallStepComplete:Show()
	end
	
	local function SetupChat()
		if (C.chat.enable == true) and (not IsAddOnLoaded("Prat") or not IsAddOnLoaded("Chatter")) then	
			InstallStepComplete.message = L.ElvUIInstall_ChatSet
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
				
				_G["ChatFrame"..i]:SetSize(E.Scale(C["chat"].chatwidth - 5), E.Scale(C["chat"].chatheight))
				
				-- this is the default width and height of Elvui chats.
				SetChatWindowSavedDimensions(chatFrameId, E.Scale(C["chat"].chatwidth + -4), E.Scale(C["chat"].chatheight))

				-- move general bottom left
				if i == 1 then
					frame:ClearAllPoints()
					frame:Point("BOTTOMLEFT", ChatLPlaceHolder, "BOTTOMLEFT", 2, 4)
				elseif i == 3 then
					frame:ClearAllPoints()
					frame:Point("BOTTOMRIGHT", ChatRPlaceHolder, "BOTTOMRIGHT", -2, 4)
				end
				
				FCF_SavePositionAndDimensions(frame)
				
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
			ChatFrame_RemoveChannel(ChatFrame1, L.chat_trade)
			ChatFrame_AddChannel(ChatFrame3, L.chat_trade)

			
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
		end	
	end
	
	local function SetupCVars()
		SetCVar("mapQuestDifficulty", 1)
		SetCVar("scriptErrors", 0)
		SetCVar("ShowClassColorInNameplate", 1)
		SetCVar("screenshotQuality", 10)
		SetCVar("cameraDistanceMax", 50)
		SetCVar("cameraDistanceMaxFactor", 3.4)
		SetCVar("chatMouseScroll", 1)
		SetCVar("chatStyle", "classic")
		SetCVar("WholeChatWindowClickable", 0)
		SetCVar("ConversationMode", "inline")
		SetCVar("showTutorials", 0)
		SetCVar("showNewbieTips", 0)
		SetCVar("showLootSpam", 1)
		SetCVar("UberTooltips", 1)
		SetCVar("gxTextureCacheSize", 512)	
		InstallStepComplete.message = L.ElvUIInstall_CVarSet
		InstallStepComplete:Show()					
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
		
		--Page#1
		if PageNum == 1 then
			f.SubTitle:SetText(format(L.ElvUIInstall_page1_subtitle, E.version))
			f.Desc1:SetText(L.ElvUIInstall_page1_desc1)
			f.Desc2:SetText(L.ElvUIInstall_page1_desc2)
			f.Desc3:SetText(L.ElvUIInstall_ContinueMessage)
			InstallOption1Button:Show()
			InstallOption1Button:SetScript("OnClick", InstallComplete)
			InstallOption1Button:SetText(L.ElvUIInstall_page1_button1)			
		elseif PageNum == 2 then
			f.SubTitle:SetText(L.ElvUIInstall_page2_subtitle)
			f.Desc1:SetText(L.ElvUIInstall_page2_desc1)
			f.Desc2:SetText(L.ElvUIInstall_page2_desc2)
			f.Desc3:SetText(L.ElvUIInstall_HighRecommended)
			InstallOption1Button:Show()
			InstallOption1Button:SetScript("OnClick", SetupCVars)
			InstallOption1Button:SetText(L.ElvUIInstall_page2_button1)
		elseif PageNum == 3 then
			f.SubTitle:SetText(L.ElvUIInstall_page3_subtitle)
			f.Desc1:SetText(L.ElvUIInstall_page3_desc1)
			f.Desc2:SetText(L.ElvUIInstall_page3_desc2)
			f.Desc3:SetText(L.ElvUIInstall_MediumRecommended)
			InstallOption1Button:Show()
			InstallOption1Button:SetScript("OnClick", SetupChat)
			InstallOption1Button:SetText(L.ElvUIInstall_page3_button1)
		elseif PageNum == 4 then
			local string_ = L.ElvUIInstall_High
			if E.lowversion then
				string_ = L.ElvUIInstall_Low
			end
			
			f.SubTitle:SetText(L.ElvUIInstall_page4_subtitle)
			f.Desc1:SetText(format(L.ElvUIInstall_page4_desc1, E.getscreenresolution, string_))
			f.Desc2:SetText(L.ElvUIInstall_page4_desc2)			
			f.Desc3:SetText(L.ElvUIInstall_ContinueMessage)
		elseif PageNum == 5 then
			f.SubTitle:SetText(L.ElvUIInstall_page5_subtitle)
			f.Desc1:SetText(L.ElvUIInstall_page5_desc1)
			f.Desc2:SetText(L.ElvUIInstall_page5_desc2)
			f.Desc3:SetText(L.ElvUIInstall_ContinueMessage)	
		elseif PageNum == 6 then
			f.SubTitle:SetText(L.ElvUIInstall_page6_subtitle)
			f.Desc1:SetText(L.ElvUIInstall_page6_desc1)
			f.Desc2:SetText(L.ElvUIInstall_page6_desc2)
			f.Desc3:SetText(L.ElvUIInstall_page6_desc3)
			InstallOption1Button:Show()
			InstallOption1Button:SetScript("OnClick", ResetUFPos)
			InstallOption1Button:SetText(L.ElvUIInstall_page6_button1)							
		elseif PageNum == 7 then
			f.SubTitle:SetText(L.ElvUIInstall_page7_subtitle)
			f.Desc1:SetText(L.ElvUIInstall_page7_desc1)
			f.Desc2:SetText(L.ElvUIInstall_page7_desc2)
			InstallOption1Button:Show()
			InstallOption1Button:SetScript("OnClick", InstallComplete)
			InstallOption1Button:SetText(L.ElvUIInstall_page7_button1)				
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

	--Create Frame
	if not ElvUIInstallFrame then
		local f = CreateFrame("Frame", "ElvUIInstallFrame", E.UIParent)
		f:Size(550, 400)
		f:SetTemplate("Transparent")
		f:CreateShadow("Default")
		f:SetPoint("CENTER")
		
		f:FontString("Title", C["media"].font, 17, "THINOUTLINE")
		f.Title:Point("TOP", 0, -5)
		f.Title:SetText(L.ElvUIInstall_Title)
		
		f.Next = CreateFrame("Button", "InstallNextButton", f, "UIPanelButtonTemplate2")
		f.Next:StripTextures()
		f.Next:SetTemplate("Default", true)
		f.Next:Size(110, 25)
		f.Next:Point("BOTTOMRIGHT", -5, 5)
		f.Next:SetText(CONTINUE)
		f.Next:Disable()
		f.Next:SetScript("OnClick", NextPage)
		
		f.Prev = CreateFrame("Button", "InstallPrevButton", f, "UIPanelButtonTemplate2")
		f.Prev:StripTextures()
		f.Prev:SetTemplate("Default", true)
		f.Prev:Size(110, 25)
		f.Prev:Point("BOTTOMLEFT", 5, 5)
		f.Prev:SetText(PREVIOUS)	
		f.Prev:Disable()
		f.Prev:SetScript("OnClick", PreviousPage)
		
		f.Status = CreateFrame("StatusBar", "InstallStatus", f)
		f.Status:SetFrameLevel(f.Status:GetFrameLevel() + 2)
		f.Status:CreateBackdrop("Default")
		f.Status:SetStatusBarTexture(C["media"].normTex)
		f.Status:SetStatusBarColor(unpack(C["media"].valuecolor))
		f.Status:SetMinMaxValues(0, MAX_PAGE)
		f.Status:Point("TOPLEFT", f.Prev, "TOPRIGHT", 6, -2)
		f.Status:Point("BOTTOMRIGHT", f.Next, "BOTTOMLEFT", -6, 2)
		f.Status:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
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
		
		f:FontString("SubTitle", C["media"].font, 15, "THINOUTLINE")
		f.SubTitle:Point("TOP", 0, -40)
		
		f:FontString("Desc1", C["media"].font, 12)
		f.Desc1:Point("TOPLEFT", 20, -75)	
		f.Desc1:Width(f:GetWidth() - 40)
		
		
		f:FontString("Desc2", C["media"].font, 12)
		f.Desc2:Point("TOPLEFT", 20, -125)		
		f.Desc2:Width(f:GetWidth() - 40)
		
		f:FontString("Desc3", C["media"].font, 12)
		f.Desc3:Point("TOPLEFT", 20, -175)	
		f.Desc3:Width(f:GetWidth() - 40)
		
		local close = CreateFrame("Button", "InstallCloseButton", f, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", f, "TOPRIGHT")
		close:SetScript("OnClick", function()
			f:Hide()
		end)		
		
		E.SkinCloseButton(close)
	end
	
	ElvUIInstallFrame:Show()
	NextPage()
end

local function DisableElvui()
	DisableAddOn("ElvUI"); 
	ReloadUI()
end

local ElvuiOnLogon = CreateFrame("Frame")
ElvuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	--reset april fools day for next year
	if not E.FoolDayCheck() then
		FoolsDay = nil
	end

	if E.getscreenresolution == "800x600"
		or E.getscreenresolution == "1024x768"
		or E.getscreenresolution == "720x576"
		or E.getscreenresolution == "1024x600" -- eeepc reso
		or E.getscreenresolution == "1152x864" then
			SetCVar("useUiScale", 0)
			StaticPopup_Show("DISABLE_UI")
	else
		
		if C["general"].multisampleprotect == true then
			SetMultisampleFormat(1)
		end
		
		if E.Round(UIParent:GetScale(), 5) ~= E.Round(C["general"].uiscale, 5) then
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", C["general"].uiscale)
		end
		
		if ElvuiData == nil then ElvuiData = {} end
		if ElvuiData[E.myrealm] == nil then ElvuiData[E.myrealm] = {} end
		if ElvuiData[E.myrealm][E.myname] == nil then ElvuiData[E.myrealm][E.myname] = {} end
		
		ElvuiData[E.myrealm][E.myname].v2installed = nil--Depreciated
		ElvuiData[E.myrealm][E.myname].installed = nil--Depreciated
		if ElvuiData[E.myrealm][E.myname].v2_installed ~= true then
			E.Install()
		end
	end
	
	if (IsAddOnLoaded("Elvui_RaidDPS") and IsAddOnLoaded("Elvui_RaidHeal")) then
		StaticPopup_Show("DISABLE_RAID")
	end
		
	if C["unitframes"].arena == true then
		SetCVar("showArenaEnemyFrames", 0)
	end
	
	if C["nameplate"].enable == true and C["nameplate"].enhancethreat == true then
		SetCVar("threatWarning", 3)
	end

	E.ChatLIn = true
	E.ChatRIn = true
	
	-- we adjust E.UIParent to screen #1 if Eyefinity is found
	if E.eyefinity then
		local width = E.eyefinity
		local height = E.getscreenheight
		
		-- if autoscale is off, find a new width value of E.UIParent for screen #1.
		if not C.general.autoscale or height > 1200 then
			local h = UIParent:GetHeight()
			local ratio = E.getscreenheight / h
			local w = E.eyefinity / ratio
			
			width = w
			height = h			
		end
		
		E.UIParent:SetSize(width, height)
		E.UIParent:ClearAllPoints()
		E.UIParent:SetPoint("CENTER")	
	else
		E.UIParent:SetSize(UIParent:GetSize())
		E.UIParent:ClearAllPoints()
		E.UIParent:SetPoint("CENTER")		
	end	
	

	if C["general"].loginmessage == true then
		--Noob filter
		local _, _, _, completed = GetAchievementInfo(5807)
		if completed then
			print(format(L.core_welcome1, E.version))
		else
			print(format(L.core_welcome1alt, E.version))
		end
		
		print(L.core_welcome2)
	end
	
	local maxresolution
	for i=1, 30 do
		if select(i, GetScreenResolutions()) ~= nil then
			maxresolution = select(i, GetScreenResolutions())
		end
	end

	if select(GetCurrentResolution(), GetScreenResolutions()) ~= maxresolution then
		print(format(L.core_resowarning, select(GetCurrentResolution(), GetScreenResolutions()), maxresolution))
	end
end)

local eventcount = 0
local ElvuiInGame = CreateFrame("Frame")
ElvuiInGame:RegisterAllEvents()
ElvuiInGame:SetScript("OnEvent", function(self, event)
	eventcount = eventcount + 1
	if InCombatLockdown() then return end

	if eventcount > 6000 then
		collectgarbage("collect")
		eventcount = 0
	end
end)

------------------------------------------------------------------------
--	UI HELP
------------------------------------------------------------------------

-- Print Help Messages
function E.UIHelp()
	print(" ")
	print(L.core_uihelp1)
	print(L.core_uihelp2)
	print(L.core_uihelp3)
	print(L.core_uihelp4)
	print(L.core_uihelp5)
	print(L.core_uihelp6)
	print(L.core_uihelp7)
	print(L.core_uihelp10)
	print(L.core_uihelp11)
	print(L.core_uihelp12)
	print(L.core_uihelp15)
	print(L.core_uihelp16)
	print(L.core_uihelp17)
	print(L.core_uihelp18)
	print(L.core_uihelp19)
	print(L.core_uihelp21)
	print(L.core_uihelp22)
	print(" ")
	print(L.core_uihelp14)
end