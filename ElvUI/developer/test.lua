--[[
	Going to leave this as my bullshit lua file.

	So I can test stuff.
]]

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

			if ((i == 1 and not ElvUI[1].db.missionID) or (mission.missionID == ElvUI[1].db.missionID)) then
				mission.isRare = true
				mission.level = 100
				ElvUI[1].db.missionID = mission.missionID
				mission.name = mounts[mountItemID[ElvUI[1].db.aprilFoolsMount]]
				mission.numRewards = 1
				mission.rewards = {
					[1] = {
						itemID = mountItemID[ElvUI[1].db.aprilFoolsMount],
						quantity = 1,
					},
				}
				isSet = true
			end

			button.id = index;
			button.info = mission;
			button.Title:SetWidth(0);
			button.Title:SetText(mission.name);
			button.Level:SetText(mission.level);
			if ( mission.durationSeconds >= GARRISON_LONG_MISSION_TIME ) then
				local duration = format(GARRISON_LONG_MISSION_TIME_FORMAT, mission.duration);
				button.Summary:SetFormattedText(PARENS_TEMPLATE, duration);
			else
				button.Summary:SetFormattedText(PARENS_TEMPLATE, mission.duration);
			end
			if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < 655 - mission.numRewards * 65 ) then
				button.Title:SetPoint("LEFT", 165, 0);
				button.Summary:ClearAllPoints();
				button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
			else
				button.Title:SetPoint("LEFT", 165, 10);
				button.Title:SetWidth(655 - mission.numRewards * 65);
				button.Summary:ClearAllPoints();
				button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
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
				button.Level:SetPoint("CENTER", button, "TOPLEFT", 40, -22);
			else
				button.Level:SetPoint("CENTER", button, "TOPLEFT", 40, -36);
			end

			button:Enable();
			if (mission.inProgress) then
				button.Overlay:Show();
				button.Summary:SetText(mission.timeLeft.." "..RED_FONT_COLOR_CODE..GARRISON_MISSION_IN_PROGRESS..FONT_COLOR_CODE_CLOSE);
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
		ElvUI[1]:Delay(10, function() self:Hide() end)
		self:EnableMouse(false)
	end)
	af:SetFrameStrata("DIALOG")

	af.bg = af:CreateTexture(nil, 'BACKGROUND')
	af.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	af.bg:SetPoint('BOTTOM')
	af.bg:Size(326, 103)
	af.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	af.bg:SetVertexColor(1, 1, 1, 0.6)

	af.lineTop = af:CreateTexture(nil, 'BACKGROUND')
	af.lineTop:SetDrawLayer('BACKGROUND', 2)
	af.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	af.lineTop:SetPoint("TOP")
	af.lineTop:Size(418, 7)
	af.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	af.lineBottom = af:CreateTexture(nil, 'BACKGROUND')
	af.lineBottom:SetDrawLayer('BACKGROUND', 2)
	af.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	af.lineBottom:SetPoint("BOTTOM")
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
			local canRun = ElvUI[1]:IsFoolsDay() or ElvUI[1].db.missionID
			--canRun = true
			if(canRun) then
				CreateTrickFrame()
				if(not ElvUI[1].db.aprilFoolsMount) then
					ElvUI[1].db.aprilFoolsMount = 72286
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
						ElvUI[1].db.aprilFoolsMount = x
						break
					end
				end

				self:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
				GarrisonMissionList_Update = New
			end
		end
	elseif(event == "GARRISON_MISSION_BONUS_ROLL_COMPLETE") then
		local missionID, success = ...
		if(success and missionID == ElvUI[1].db.missionID) then
			ElvUI[1].db.missionID = nil; 
			ElvUI[1].db.aprilFoolsMount = nil;
			E.global.aprilFools = true;
			AprilFoolsFrame:Show()
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
f:RegisterEvent("ADDON_LOADED")