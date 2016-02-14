--[[
	Collection of previous april fools pranks

	Garrison Missions: 	Would create fake Garrison Missions with very rare mounts as rewards.
	Harlem Shake: 		Try it out with the command /harlemshake
	Hello Kitty: 		Try it out with the command /hellokitty (pay attention to the popups, read what it says)
]]

local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local twipe, tinsert = table.wipe, table.insert
local format = format
--WoW API / Variables
local CreateFrame = CreateFrame
local GarrisonMissionButton_SetRewards = GarrisonMissionButton_SetRewards
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_Update = HybridScrollFrame_Update
local PlaySoundFile, PlayMusic, StopMusic = PlaySoundFile, PlayMusic, StopMusic
local GetCVar, SetCVar = GetCVar, SetCVar
local UIFrameFadeOut = UIFrameFadeOut
local ToggleCollectionsJournal = ToggleCollectionsJournal
local MountJournal_GetNumMounts = MountJournal_GetNumMounts
local MountJournal_GetMountInfo = MountJournal_GetMountInfo
local BNGetNumFriendInvites = BNGetNumFriendInvites
local BNGetFriendInviteInfo = BNGetFriendInviteInfo
local BNDeclineFriendInvite = BNDeclineFriendInvite
local DoEmote = DoEmote
local SendChatMessage = SendChatMessage
local PARENS_TEMPLATE = PARENS_TEMPLATE
local NUMBER_IN_PARENTHESES = NUMBER_IN_PARENTHESES
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local GARRISON_MISSION_IN_PROGRESS = GARRISON_MISSION_IN_PROGRESS
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: UIParent, GarrisonMissionFrame, GarrisonMissionList_Update, GameTooltip, Minimap
-- GLOBALS: GARRISON_FOLLOWER_MAX_LEVEL, GARRISON_LONG_MISSION_TIME, GARRISON_LONG_MISSION_TIME_FORMAT
-- GLOBALS: ElvUI_StaticPopup1, ElvUI_StaticPopup1Button1, LeftChatPanel, RightChatPanel
-- GLOBALS: LeftChatToggleButton, RightChatToggleButton, ElvUI_StanceBar, ObjectiveTrackerFrame
-- GLOBALS: HelloKittyLeft, HelloKittyRight


--Garrison Missions (Inactive)
--Unfortunately this one didn't work with MasterPlan (and probably other Garrison Mission AddOns)
--The idea was good, but due to time constraint the execution was not the best
do
	local mountItemID = {
		[72286] = 50818,
		[63796] = 45693,
		[43688] = 33809,
		[179478] = 121815,
		[24252] = 19902,
	}

	local mounts = {
		[50818] = "But I Can't See It!",
		[45693] = "Behold the VX-001 Anti-personnel Assault Cannon!",
		[33809] = "How Ya Doin Mon!",
		[121815] = "Oh, what a void there is in things.",
		[19902] = "Here Kitty Kitty!",
	}

	local missionName
	local function New()
		local self = GarrisonMissionFrame.MissionTab.MissionList;
		local missions;
		if (self.showInProgress) then
			missions = self.inProgressMissions;
		else
			missions = self.availableMissions;
		end
		local numMissions = #missions;
		local scrollFrame = self.listScroll;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local buttons = scrollFrame.buttons;
		local numButtons = #buttons;

		if (numMissions == 0) then
			self.EmptyListString:Show();
		else
			self.EmptyListString:Hide();
		end

		for i = 1, numButtons do
			local button = buttons[i];
			local index = offset + i; -- adjust index
			if ( index <= numMissions) then
				local mission = missions[index];

				if ((i == 1 and not E.db.missionID) or (mission.missionID == E.db.missionID)) then
					mission.isRare = true
					mission.level = 100
					E.db.missionID = mission.missionID
					mission.name = mounts[mountItemID[E.db.aprilFoolsMount]]
					mission.numRewards = 1
					mission.rewards = {
						[1] = {
							itemID = mountItemID[E.db.aprilFoolsMount],
							quantity = 1,
						},
					}
				end

				button.id = index;
				button.info = mission;
				button.Title:Width(0);
				button.Title:SetText(mission.name);
				button.Level:SetText(mission.level);
				if ( mission.durationSeconds >= GARRISON_LONG_MISSION_TIME ) then
					local duration = format(GARRISON_LONG_MISSION_TIME_FORMAT, mission.duration);
					button.Summary:SetFormattedText(PARENS_TEMPLATE, duration);
				else
					button.Summary:SetFormattedText(PARENS_TEMPLATE, mission.duration);
				end
				if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < 655 - mission.numRewards * 65 ) then
					button.Title:Point("LEFT", 165, 0);
					button.Summary:ClearAllPoints();
					button.Summary:Point("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
				else
					button.Title:Point("LEFT", 165, 10);
					button.Title:Width(655 - mission.numRewards * 65);
					button.Summary:ClearAllPoints();
					button.Summary:Point("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
				end
				if ( mission.locPrefix ) then
					button.LocBG:Show();
					button.LocBG:SetAtlas(mission.locPrefix.."-List");
				else
					button.LocBG:Hide();
				end
				if (mission.isRare) then
					button.RareOverlay:Show();
					button.RareText:Show();
					button.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4)
				else
					button.RareOverlay:Hide();
					button.RareText:Hide();
					button.IconBG:SetVertexColor(0, 0, 0, 0.4)
				end
				local showingItemLevel = false;
				if ( mission.level == GARRISON_FOLLOWER_MAX_LEVEL and mission.iLevel > 0 ) then
					button.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, mission.iLevel);
					button.ItemLevel:Show();
					showingItemLevel = true;
				else
					button.ItemLevel:Hide();
				end
				if ( showingItemLevel and mission.isRare ) then
					button.Level:Point("CENTER", button, "TOPLEFT", 40, -22);
				else
					button.Level:Point("CENTER", button, "TOPLEFT", 40, -36);
				end

				button:Enable();
				if (mission.inProgress) then
					button.Overlay:Show();
					button.Summary:SetFormattedText("%s %s%s%s", mission.timeLeft, RED_FONT_COLOR_CODE, GARRISON_MISSION_IN_PROGRESS, FONT_COLOR_CODE_CLOSE);
				else
					button.Overlay:Hide();
				end
				button.MissionType:SetAtlas(mission.typeAtlas);
				GarrisonMissionButton_SetRewards(button, mission.rewards, mission.numRewards);
				button:Show();
			else
				button:Hide();
			end
		end

		local totalHeight = numMissions * scrollFrame.buttonHeight;
		local displayedHeight = numButtons * scrollFrame.buttonHeight;
		HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	end


	local function CreateTrickFrame()
		local af = CreateFrame("Button", "AprilFoolsFrame", UIParent)
		af:Size(418, 72)
		af:Point("TOP", 0, -190)
		af:Hide()
		af:SetScript('OnEnter', function(self)
			PlaySoundFile([[Sound\Interface\LevelUp.wav]])
			UIFrameFadeOut(self, 10, 1, 0)
			E:Delay(10, function() self:Hide() end)
			self:EnableMouse(false)
		end)
		af:SetFrameStrata("DIALOG")

		af.bg = af:CreateTexture(nil, 'BACKGROUND')
		af.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
		af.bg:Point('BOTTOM')
		af.bg:Size(326, 103)
		af.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
		af.bg:SetVertexColor(1, 1, 1, 0.6)

		af.lineTop = af:CreateTexture(nil, 'BACKGROUND')
		af.lineTop:SetDrawLayer('BACKGROUND', 2)
		af.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
		af.lineTop:Point("TOP")
		af.lineTop:Size(418, 7)
		af.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		af.lineBottom = af:CreateTexture(nil, 'BACKGROUND')
		af.lineBottom:SetDrawLayer('BACKGROUND', 2)
		af.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
		af.lineBottom:Point("BOTTOM")
		af.lineBottom:Size(418, 7)
		af.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		af.text = af:CreateFontString(nil, 'ARTWORK', 'GameFont_Gigantic')
		af.text:Point("BOTTOM", 0, 12)
		af.text:SetTextColor(1, 0.82, 0)
		af.text:SetJustifyH("CENTER")
		af.text:SetText("April Fools <3 ElvUI")
	end

	local function EventHandler(self, event, ...)
		if(event == "ADDON_LOADED") then
			local name = ...
			if(name == "Blizzard_GarrisonUI") then
				local canRun = E:IsFoolsDay() or E.db.missionID
				--canRun = true
				if(canRun) then
					CreateTrickFrame()
					if(not E.db.aprilFoolsMount) then
						E.db.aprilFoolsMount = 72286
						ToggleCollectionsJournal()
						ToggleCollectionsJournal()

						--Establish a list of mounts
						for i=1, MountJournal_GetNumMounts() do
							local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, _, _, hideOnChar, isCollected = MountJournal_GetMountInfo(i);
							if(mountItemID[spellID] and isUsable) then
								mountItemID[spellID] = nil
							end
						end

						for x, y in pairs(mountItemID) do
							E.db.aprilFoolsMount = x
							break
						end
					end

					self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
					GarrisonMissionList_Update = New
				end
			end
		elseif(event == "GARRISON_MISSION_BONUS_ROLL_COMPLETE") then
			local missionID, success = ...
			if(success and missionID == E.db.missionID) then
				E.db.missionID = nil;
				E.db.aprilFoolsMount = nil;
				E.global.aprilFools = true;
				-- AprilFoolsFrame:Show()
			end
		else
			for i=1, BNGetNumFriendInvites() do
				local id, _ ,_ , t = BNGetFriendInviteInfo(i)
				if t and t:lower():find("pvpbank") then
					BNDeclineFriendInvite(id)
				end
			end
		  end
	end

	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", EventHandler)
	f:RegisterEvent("BN_FRIEND_INVITE_ADDED")
	f:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED")
	f:RegisterEvent("BN_CONNECTED")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- f:RegisterEvent("ADDON_LOADED")
end


--Harlem Shake (Activate with command: /harlemshake)
--People really seemed to like this one. We got a lot of positive responses.
do
	function E:StopHarlemShake()
		E.isMassiveShaking = nil
		StopMusic()
		SetCVar("Sound_EnableAllSound", self.oldEnableAllSound)
		SetCVar("Sound_EnableMusic", self.oldEnableMusic)

		self:StopShakeHorizontal(ElvUI_StaticPopup1)
		for _, object in pairs(self["massiveShakeObjects"]) do
			if object then
				self:StopShake(object)
			end
		end

		if E.massiveShakeTimer then
			E:CancelTimer(E.massiveShakeTimer)
		end

		E.global.aprilFools = true;
		E:StaticPopup_Hide("HARLEM_SHAKE")
		twipe(self.massiveShakeObjects)
		DoEmote("Dance")
	end

	function E:DoTheHarlemShake()
		E.isMassiveShaking = true
		ElvUI_StaticPopup1Button1:Enable()

		for _, object in pairs(self["massiveShakeObjects"]) do
			if object and object:IsShown() then
				self:Shake(object)
			end
		end

		E.massiveShakeTimer = E:ScheduleTimer("StopHarlemShake", 42.5)
		SendChatMessage("DO THE HARLEM SHAKE!", "YELL")
	end

	function E:BeginHarlemShake()
		DoEmote("Dance")
		ElvUI_StaticPopup1Button1:Disable()
		self:ShakeHorizontal(ElvUI_StaticPopup1)
		self.oldEnableAllSound = GetCVar("Sound_EnableAllSound")
		self.oldEnableMusic = GetCVar("Sound_EnableMusic")

		SetCVar("Sound_EnableAllSound", 1)
		SetCVar("Sound_EnableMusic", 1)
		PlayMusic([[Interface\AddOns\ElvUI\media\sounds\harlemshake.ogg]])
		E:ScheduleTimer("DoTheHarlemShake", 15.5)

		local UF = E:GetModule("UnitFrames")
		local AB = E:GetModule("ActionBars")
		self.massiveShakeObjects = {}
		tinsert(self.massiveShakeObjects, GameTooltip)
		tinsert(self.massiveShakeObjects, Minimap)
		tinsert(self.massiveShakeObjects, ObjectiveTrackerFrame)
		tinsert(self.massiveShakeObjects, LeftChatPanel)
		tinsert(self.massiveShakeObjects, RightChatPanel)
		tinsert(self.massiveShakeObjects, LeftChatToggleButton)
		tinsert(self.massiveShakeObjects, RightChatToggleButton)

		for unit in pairs(UF['units']) do
			tinsert(self.massiveShakeObjects, UF[unit])
		end

		for _, header in pairs(UF['headers']) do
			tinsert(self.massiveShakeObjects, header)
		end

		for _, bar in pairs(AB['handledBars']) do
			for i=1, #bar.buttons do
				tinsert(self.massiveShakeObjects, bar.buttons[i])
			end
		end

		if ElvUI_StanceBar then
			for i=1, #ElvUI_StanceBar.buttons do
				tinsert(self.massiveShakeObjects, ElvUI_StanceBar.buttons[i])
			end
		end

		for i=1, NUM_PET_ACTION_SLOTS do
			local button = _G["PetActionButton"..i]
			if button then
				tinsert(self.massiveShakeObjects, button)
			end
		end
	end

	function E:HarlemShakeToggle()
		self:StaticPopup_Show("HARLEM_SHAKE");
	end
end

--Hello Kitty (Activate with command: /hellokitty)
--This is one of those pranks where you either love it or hate it I think
--Unfortunately there was a bug which caused some of the hello kitty changes to stick,
-- when they should have reverted to the original settings. This bug was fixed later on.
do
	local function OnDragStart(self)
		self:StartMoving()
	end

	local function OnDragStop(self)
		self:StopMovingOrSizing()
	end

	local function OnUpdate(self, elapsed)
		if(self.elapsed and self.elapsed > 0.1) then
			self.tex:SetTexCoord((self.curFrame - 1) * 0.1, 0, (self.curFrame - 1) * 0.1, 1, self.curFrame * 0.1, 0, self.curFrame * 0.1, 1)

			if(self.countUp) then
				self.curFrame = self.curFrame + 1
			else
				self.curFrame = self.curFrame - 1
			end

			if(self.curFrame > 10) then
				self.countUp = false
				self.curFrame = 9
			elseif(self.curFrame < 1) then
				self.countUp = true
				self.curFrame = 2
			end
			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end

	function E:SetupHelloKitty()
		if not self.db.tempSettings then
			self.db.tempSettings = {}
		end

		--Store old settings
		local t = self.db.tempSettings
		local c = self.db.general.backdropcolor
		if(self:HelloKittyFixCheck()) then
			E:HelloKittyFix()
		else
			self.oldEnableAllSound = GetCVar("Sound_EnableAllSound")
			self.oldEnableMusic = GetCVar("Sound_EnableMusic")

			t.backdropcolor = {r = c.r, g = c.g, b = c.b}
			c = self.db.general.backdropfadecolor
			t.backdropfadecolor = {r = c.r, g = c.g, b = c.b, a = c.a}
			c = self.db.general.bordercolor
			t.bordercolor = {r = c.r, g = c.g, b = c.b}
			c = self.db.general.valuecolor
			t.valuecolor = {r = c.r, g = c.g, b = c.b}

			t.panelBackdropNameLeft = self.db.chat.panelBackdropNameLeft
			t.panelBackdropNameRight = self.db.chat.panelBackdropNameRight

			c = self.db.unitframe.colors.health
			t.health = {r = c.r, g = c.g, b = c.b}
			t.healthclass = self.db.unitframe.colors.healthclass

			c = self.db.unitframe.colors.castColor
			t.castColor = {r = c.r, g = c.g, b = c.b}
			t.transparentCastbar = self.db.unitframe.colors.transparentCastbar

			c = self.db.unitframe.colors.auraBarBuff
			t.auraBarBuff = {r = c.r, g = c.g, b = c.b}
			t.transparentAurabars = self.db.unitframe.colors.transparentAurabars

			--Apply new settings
			self.db.general.backdropfadecolor = {r =131/255, g =36/255, b = 130/255, a = 0.36}
			self.db.general.backdropcolor = {r = 223/255, g = 76/255, b = 188/255}
			self.db.general.bordercolor = {r = 223/255, g = 217/255, b = 47/255}
			self.db.general.valuecolor = {r = 223/255, g = 217/255, b = 47/255}

			self.db.chat.panelBackdropNameLeft = [[Interface\AddOns\ElvUI\media\textures\helloKittyChat.tga]]
			self.db.chat.panelBackdropNameRight = [[Interface\AddOns\ElvUI\media\textures\helloKittyChat.tga]]

			self.db.unitframe.colors.castColor = {r = 223/255, g = 76/255, b = 188/255}
			self.db.unitframe.colors.transparentCastbar = true

			self.db.unitframe.colors.auraBarBuff = {r = 223/255, g = 76/255, b = 188/255}
			self.db.unitframe.colors.transparentAurabars = true

			self.db.unitframe.colors.health = {r = 223/255, g = 76/255, b = 188/255}
			self.db.unitframe.colors.healthclass = false

			SetCVar("Sound_EnableAllSound", 1)
			SetCVar("Sound_EnableMusic", 1)
			PlayMusic([[Interface\AddOns\ElvUI\media\sounds\helloKitty.ogg]])
			E:StaticPopup_Show("HELLO_KITTY_END")

			self.db.general.kittys = true
			self:CreateKittys()

			self:UpdateAll()
		end
	end

	function E:RestoreHelloKitty()
		--Store old settings
		self.db.general.kittys = false
		if(HelloKittyLeft) then
			HelloKittyLeft:Hide()
			HelloKittyRight:Hide()
		end

		if not(self.db.tempSettings) then return end
		if(self:HelloKittyFixCheck()) then
			self:HelloKittyFix()
			self.db.tempSettings = nil
			return
		end
		local c = self.db.tempSettings.backdropcolor
		self.db.general.backdropcolor = {r = c.r, g = c.g, b = c.b}

		c = self.db.tempSettings.backdropfadecolor
		self.db.general.backdropfadecolor = {r = c.r, g = c.g, b = c.b, a = (c.a or 0.8)}

		c = self.db.tempSettings.bordercolor
		self.db.general.bordercolor = {r = c.r, g = c.g, b = c.b}

		c = self.db.tempSettings.valuecolor
		self.db.general.valuecolor = {r = c.r, g = c.g, b = c.b}

		self.db.chat.panelBackdropNameLeft = self.db.tempSettings.panelBackdropNameLeft
		self.db.chat.panelBackdropNameRight = self.db.tempSettings.panelBackdropNameRight

		c = self.db.tempSettings.health
		self.db.unitframe.colors.health = {r = c.r, g = c.g, b = c.b}
		self.db.unitframe.colors.healthclass = self.db.tempSettings.healthclass

		c = self.db.tempSettings.castColor
		self.db.unitframe.colors.castColor = {r = c.r, g = c.g, b = c.b}
		self.db.unitframe.colors.transparentCastbar = self.db.tempSettings.transparentCastbar

		c = self.db.tempSettings.auraBarBuff
		self.db.unitframe.colors.auraBarBuff = {r = c.r, g = c.g, b = c.b}
		self.db.unitframe.colors.transparentAurabars = self.db.tempSettings.transparentAurabars

		self.db.tempSettings = nil

		self:UpdateAll()
	end

	function E:CreateKittys()
		if(HelloKittyLeft) then
			HelloKittyLeft:Show()
			HelloKittyRight:Show()
			return
		end
		local helloKittyLeft = CreateFrame("Frame", "HelloKittyLeft", UIParent)
		helloKittyLeft:SetSize(120, 128)
		helloKittyLeft:SetMovable(true)
		helloKittyLeft:EnableMouse(true)
		helloKittyLeft:RegisterForDrag("LeftButton")
		helloKittyLeft:Point("BOTTOMLEFT", LeftChatPanel, "BOTTOMRIGHT", 2, -4)
		helloKittyLeft.tex = helloKittyLeft:CreateTexture(nil, "OVERLAY")
		helloKittyLeft.tex:SetAllPoints()
		helloKittyLeft.tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\helloKitty.tga")
		helloKittyLeft.tex:SetTexCoord(0, 0, 0, 1, 0, 0, 0, 1)
		helloKittyLeft.curFrame = 1
		helloKittyLeft.countUp = true
		helloKittyLeft:SetClampedToScreen(true)
		helloKittyLeft:SetScript("OnDragStart", OnDragStart)
		helloKittyLeft:SetScript("OnDragStop", OnDragStop)
		helloKittyLeft:SetScript("OnUpdate", OnUpdate)

		local helloKittyRight = CreateFrame("Frame", "HelloKittyRight", UIParent)
		helloKittyRight:SetSize(120, 128)
		helloKittyRight:SetMovable(true)
		helloKittyRight:EnableMouse(true)
		helloKittyRight:RegisterForDrag("LeftButton")
		helloKittyRight:Point("BOTTOMRIGHT", RightChatPanel, "BOTTOMLEFT", -2, -4)
		helloKittyRight.tex = helloKittyRight:CreateTexture(nil, "OVERLAY")
		helloKittyRight.tex:SetAllPoints()
		helloKittyRight.tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\helloKitty.tga")
		helloKittyRight.tex:SetTexCoord(0, 0, 0, 1, 0, 0, 0, 1)
		helloKittyRight.curFrame = 10
		helloKittyRight.countUp = false
		helloKittyRight:SetClampedToScreen(true)
		helloKittyRight:SetScript("OnDragStart", OnDragStart)
		helloKittyRight:SetScript("OnDragStop", OnDragStop)
		helloKittyRight:SetScript("OnUpdate", OnUpdate)
	end

	--When it bugged out for a user the command "/hellokittyfix" attempted to restore the changed settings to default
	function E:HelloKittyFixCheck(secondCheck)
		local t = self.db.tempSettings
		if(not t and not secondCheck) then t = self.db.general end
		if(t and t.backdropcolor)then
			return self:Round(t.backdropcolor.r, 2) == 0.87 and self:Round(t.backdropcolor.g, 2) == 0.3 and self:Round(t.backdropcolor.b, 2) == 0.74
		end
	end

	function E:HelloKittyFix()
		local c = P.general.backdropcolor
		self.db.general.backdropcolor = {r = c.r, g = c.g, b = c.b}

		c = P.general.backdropfadecolor
		self.db.general.backdropfadecolor = {r = c.r, g = c.g, b = c.b, a = (c.a or 0.8)}

		c = P.general.bordercolor
		self.db.general.bordercolor = {r = c.r, g = c.g, b = c.b}

		c = P.general.valuecolor
		self.db.general.valuecolor = {r = c.r, g = c.g, b = c.b}

		self.db.chat.panelBackdropNameLeft = ""
		self.db.chat.panelBackdropNameRight = ""

		c = P.unitframe.colors.health
		self.db.unitframe.colors.health = {r = c.r, g = c.g, b = c.b}

		c = P.unitframe.colors.castColor
		self.db.unitframe.colors.castColor = {r = c.r, g = c.g, b = c.b}
		self.db.unitframe.colors.transparentCastbar = false

		c = P.unitframe.colors.castColor
		self.db.unitframe.colors.auraBarBuff = {r = c.r, g = c.g, b = c.b}
		self.db.unitframe.colors.transparentAurabars = false

		if(HelloKittyLeft) then
			HelloKittyLeft:Hide()
			HelloKittyRight:Hide()
			self.db.general.kittys = nil
			return
		end

		self.db.tempSettings = nil
		self:UpdateAll()
	end

	function E:HelloKittyToggle()
		if(HelloKittyLeft and HelloKittyLeft:IsShown()) then
			self:RestoreHelloKitty()
		else
			self:StaticPopup_Show("HELLO_KITTY")
		end
	end
	
	function E:ShowTukuiFrame()
		local f = CreateFrame("Button", "TukuiThanks", E.UIParent)
		f.SetPage = SetPage
		f:Size(550, 260)
		f:SetTemplate("Transparent")
		f:Point("CENTER")
		f:SetFrameStrata('TOOLTIP')
		
		f.Title = f:CreateFontString(nil, 'OVERLAY')
		f.Title:FontTemplate(nil, 17, nil)
		f.Title:Point("TOP", 0, -5)
		f.Title:SetText("Thanks For Testing!")
		
		f.Desc1 = f:CreateFontString(nil, 'OVERLAY')
		f.Desc1:FontTemplate()
		f.Desc1:Point("TOPLEFT", 20, -75)
		f.Desc1:Width(f:GetWidth() - 40)		
		f.Desc1:SetText("Thank you for the five years of testing the experimental version of Tukui codenamed 'ElvUI'. The testing period has now ended your user interface has been adjusted accordingly.")
	
		local close = CreateFrame("Button", "InstallCloseButton", f, "UIPanelCloseButton")
		close:Point("TOPRIGHT", f, "TOPRIGHT")
		close:SetScript("OnClick", function()
			f:Hide()
		end)
		E.Skins:HandleCloseButton(close)	
		
		f.tutorialImage = f:CreateTexture('InstallTutorialImage', 'OVERLAY')
		f.tutorialImage:Size(256, 128)
		f.tutorialImage:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\tukui_logo.tga')	
		f.tutorialImage:Point('BOTTOM', 0, 10)	
	end
end