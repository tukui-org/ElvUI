--[[
	Going to leave this as my bullshit lua file.

	So I can test stuff.
]]

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

			if (i == 1 and not missionName) then
				mission.isRare = true
				mission.level = 100
				missionName = mission.name
				mission.name = "But I Can't See It!"
				mission.numRewards = 1
				mission.rewards = {
					[1] = {
						itemID = 50818,
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


local function EventHandler(self, event, ...)
	if(event == "ADDON_LOADED") then
		local name = ...
		if(name == "Blizzard_GarrisonUI") then
			if(ElvUI[1]:IsFoolsDay()) then
				GarrisonMissionList_Update = New
			end
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