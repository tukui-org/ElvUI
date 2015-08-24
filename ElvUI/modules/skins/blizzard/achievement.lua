local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin(event)
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.achievement ~= true then return end

	local function SkinAchievement(Achievement, BiggerIcon)
		if Achievement.isSkinned then return; end

		Achievement:StripTextures(true)
		Achievement:CreateBackdrop("Default", true)
		Achievement.backdrop:SetInside()
		Achievement.icon:SetTemplate()
		Achievement.icon:SetSize(BiggerIcon and 54 or 36, BiggerIcon and 54 or 36)
		Achievement.icon:ClearAllPoints()
		Achievement.icon:Point("TOPLEFT", 8, -8)
		Achievement.icon.bling:Kill()
		Achievement.icon.frame:Kill()
		Achievement.icon.texture:SetTexCoord(unpack(E.TexCoords))
		Achievement.icon.texture:SetInside()

		if Achievement.highlight then
			Achievement.highlight:StripTextures()
			Achievement:HookScript('OnEnter', function(self) self.backdrop:SetBackdropBorderColor(1, 1, 0) end)
			Achievement:HookScript('OnLeave', function(self)
				if (self.player and self.player.accountWide or self.accountWide) then
					self.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
				else
					self.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end
			end)
		end

		if Achievement.label then
			Achievement.label:SetTextColor(1, 1, 1)
		end

		if Achievement.description then
			Achievement.description:SetTextColor(.6, .6, .6)
			hooksecurefunc(Achievement.description, 'SetTextColor', function(self, r, g, b)
				if r == 0 and g == 0 and b == 0 then
					Achievement.description:SetTextColor(.6, .6, .6)
				end
			end)
		end

		if Achievement.hiddenDescription then
			Achievement.hiddenDescription:SetTextColor(1, 1, 1)
		end

		if Achievement.tracked then
			S:HandleCheckBox(Achievement.tracked, true)
			Achievement.tracked:Size(14, 14)
			Achievement.tracked:ClearAllPoints()
			Achievement.tracked:SetPoint('TOPLEFT', Achievement.icon, 'BOTTOMLEFT', 0, -2)
		end
		
		Achievement.isSkinned = true
	end

	if event == "PLAYER_ENTERING_WORLD" then
		hooksecurefunc('HybridScrollFrame_CreateButtons', function(frame, template)
			if template == "AchievementCategoryTemplate" then
				for _, button in pairs(frame.buttons) do
					if button.isSkinned then return; end
					button:StripTextures(true)
					button:StyleButton()
					button.isSkinned = true
				end
			end
			if template == "AchievementTemplate" then
				for _, Achievement in pairs(frame.buttons) do
					SkinAchievement(Achievement, true)
				end
			end
			if template == "ComparisonTemplate" then
				for _, Achievement in pairs(frame.buttons) do
					if Achievement.isSkinned then return; end
					SkinAchievement(Achievement.player)
					SkinAchievement(Achievement.friend)

					hooksecurefunc(Achievement.player, 'Saturate', function()
						if Achievement.player.accountWide then
							Achievement.player.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
							Achievement.friend.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
						else
							Achievement.player.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
							Achievement.friend.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
						end
					end)
				end
			end
			if template == "StatTemplate" then
				for _, Stats in pairs(frame.buttons) do
					-- Stats:StripTextures(true)
					Stats:StyleButton()
				end
			end
		end)
	end
	
	if (not IsAddOnLoaded("Blizzard_AchievementUI")) then
		return;
	end
	
	local frames = {
		"AchievementFrame",
		"AchievementFrameCategories",
		"AchievementFrameSummary",
		"AchievementFrameHeader",
		"AchievementFrameSummaryCategoriesHeader",
		"AchievementFrameSummaryAchievementsHeader",
		"AchievementFrameStatsBG",
		"AchievementFrameAchievements",
		"AchievementFrameComparison",
		"AchievementFrameComparisonHeader",
		"AchievementFrameComparisonSummaryPlayer",
		"AchievementFrameComparisonSummaryFriend",
	}

	for _, frame in pairs(frames) do
		_G[frame]:StripTextures(true)
	end

	local noname_frames = {
		"AchievementFrameStats",
		"AchievementFrameSummary",
		"AchievementFrameAchievements",
		"AchievementFrameComparison"
	}

	for _, frame in pairs(noname_frames) do
		for i=1, _G[frame]:GetNumChildren() do
			local child = select(i, _G[frame]:GetChildren())
			if child and not child:GetName() then
				child:SetBackdrop(nil)
			end
		end
	end

	AchievementFrame:CreateBackdrop("Transparent")
	AchievementFrame.backdrop:Point("TOPLEFT", 0, 6)
	AchievementFrame.backdrop:SetPoint("BOTTOMRIGHT")
	AchievementFrameHeaderTitle:ClearAllPoints()
	AchievementFrameHeaderTitle:Point("TOPLEFT", AchievementFrame.backdrop, "TOPLEFT", -30, -8)
	AchievementFrameHeaderPoints:ClearAllPoints()
	AchievementFrameHeaderPoints:Point("LEFT", AchievementFrameHeaderTitle, "RIGHT", 2, 0)

	--Backdrops
	AchievementFrameCategoriesContainer:CreateBackdrop("Default")
	AchievementFrameCategoriesContainer.backdrop:Point("TOPLEFT", 0, 4)
	AchievementFrameCategoriesContainer.backdrop:Point("BOTTOMRIGHT", -2, -3)
	AchievementFrameAchievementsContainer:CreateBackdrop("Transparent")
	AchievementFrameAchievementsContainer.backdrop:Point("TOPLEFT", -2, 2)
	AchievementFrameAchievementsContainer.backdrop:Point("BOTTOMRIGHT", -2, -3)

	S:HandleCloseButton(AchievementFrameCloseButton, AchievementFrame.backdrop)
	S:HandleDropDownBox(AchievementFrameFilterDropDown)
	AchievementFrameFilterDropDown:Point("TOPRIGHT", AchievementFrame, "TOPRIGHT", -44, 5)

	-- ScrollBars
	S:HandleScrollBar(AchievementFrameCategoriesContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameAchievementsContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameStatsContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameComparisonContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameComparisonStatsContainerScrollBar, 5)

	--Tabs
	for i = 1, 3 do
		S:HandleTab(_G["AchievementFrameTab"..i])
		_G["AchievementFrameTab"..i]:SetFrameLevel(_G["AchievementFrameTab"..i]:GetFrameLevel() + 2)
	end

	local function SkinStatusBar(bar)
		bar:StripTextures()
		bar:SetStatusBarTexture(E["media"].normTex)
		bar:SetStatusBarColor(4/255, 179/255, 30/255)
		bar:CreateBackdrop("Default")

		local StatusBarName = bar:GetName()

		if _G[StatusBarName.."Title"] then
			_G[StatusBarName.."Title"]:SetPoint("LEFT", 4, 0)
		end

		if _G[StatusBarName.."Label"] then
			_G[StatusBarName.."Label"]:SetPoint("LEFT", 4, 0)
		end

		if _G[StatusBarName.."Text"] then
			_G[StatusBarName.."Text"]:SetPoint("RIGHT", -4, 0)
		end
	end

	SkinStatusBar(AchievementFrameSummaryCategoriesStatusBar)
	SkinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar)
	SkinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar)
	AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
	AchievementFrameComparisonSummaryFriendStatusBar.text:SetPoint("CENTER")
	AchievementFrameComparisonHeader:Point("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 45, -20)

	for i=1, 12 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local button = _G["AchievementFrameSummaryCategoriesCategory"..i.."Button"]
		local highlight = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]
		SkinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()

		_G[highlight:GetName().."Middle"]:SetTexture(1, 1, 1, 0.3)
		_G[highlight:GetName().."Middle"]:SetAllPoints(frame)
	end

	hooksecurefunc('AchievementButton_DisplayAchievement', function(frame)
		--If another addon loads Blizzard_AchievementUI as a dependency, our hook might be executed too late.
		if not frame.isSkinned then
			SkinAchievement(frame, true)
		end

		if frame.accountWide then
			frame.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
		else
			frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i=1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local frame = _G["AchievementFrameSummaryAchievement"..i]
			if not frame.isSkinned then
				SkinAchievement(frame)
				frame.isSkinned = true
			end

			--The backdrop borders tend to overlap so add a little more space between summary achievements
			local prevFrame = _G["AchievementFrameSummaryAchievement"..i-1]
			if i ~= 1 then
				frame:ClearAllPoints()
				frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 1)
				frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 1)
			end

			if frame.accountWide then
				frame.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
			else
				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	for i=1, 20 do
		local frame = _G["AchievementFrameStatsContainerButton"..i]
		frame:StyleButton()

		_G["AchievementFrameStatsContainerButton"..i.."BG"]:SetTexture(1, 1, 1, 0.2)
		_G["AchievementFrameStatsContainerButton"..i.."HeaderLeft"]:Kill()
		_G["AchievementFrameStatsContainerButton"..i.."HeaderRight"]:Kill()
		_G["AchievementFrameStatsContainerButton"..i.."HeaderMiddle"]:Kill()

		local frame = "AchievementFrameComparisonStatsContainerButton"..i
		_G[frame]:StripTextures()
		_G[frame]:StyleButton()

		_G[frame.."BG"]:SetTexture(1, 1, 1, 0.2)
		_G[frame.."HeaderLeft"]:Kill()
		_G[frame.."HeaderRight"]:Kill()
		_G[frame.."HeaderMiddle"]:Kill()
	end


	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local frame = _G["AchievementFrameProgressBar"..index]
		if frame then
			if not frame.skinned then
				frame:StripTextures()
				frame:SetStatusBarTexture(E["media"].normTex)
				frame:SetStatusBarColor(4/255, 179/255, 30/255)
				frame:CreateBackdrop("Transparent")
				frame:SetFrameLevel(frame:GetFrameLevel() + 3)
				frame:Height(frame:GetHeight() - 2)

				frame.text:ClearAllPoints()
				frame.text:SetPoint("CENTER", frame, "CENTER", 0, -1)
				frame.text:SetJustifyH("CENTER")

				if index > 1 then
					frame:ClearAllPoints()
					frame:Point("TOP", _G["AchievementFrameProgressBar"..index-1], "BOTTOM", 0, -5)
					frame.SetPoint = E.noop
					frame.ClearAllPoints = E.noop
				end

				frame.skinned = true
			end

		end
	end)

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id)
		local textStrings, metas = 0, 0
		for i = 1, numCriteria do
			local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i)

			if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
				metas = metas + 1;
				local metaCriteria = AchievementButton_GetMeta(metas);
				if ( objectivesFrame.completed and completed ) then
					metaCriteria.label:SetShadowOffset(0, 0)
					metaCriteria.label:SetTextColor(1, 1, 1, 1);
				elseif ( completed ) then
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(0, 1, 0, 1);
				else
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(.6, .6, .6, 1);
				end
			elseif criteriaType ~= 1 then
				textStrings = textStrings + 1;
				local criteria = AchievementButton_GetCriteria(textStrings);
				if ( objectivesFrame.completed and completed ) then
					criteria.name:SetTextColor(1, 1, 1, 1);
					criteria.name:SetShadowOffset(0, 0);
				elseif ( completed ) then
					criteria.name:SetTextColor(0, 1, 0, 1);
					criteria.name:SetShadowOffset(1, -1);
				else
					criteria.name:SetTextColor(.6, .6, .6, 1);
					criteria.name:SetShadowOffset(1, -1);
				end
			end
		end
	end)
	
	--The section below is usually handled in our hook, but another addon may have loaded the AchievementUI before we were ready
	--Categories 
	for i = 1, 20 do
		local button = _G["AchievementFrameCategoriesContainerButton"..i]
		if not button or (button and button.isSkinned) then return end
		button:StripTextures(true)
		button:StyleButton()
		button.isSkinned = true
	end
	
	--Comparison
	for i = 1, 10 do
		local Achievement = _G["AchievementFrameComparisonContainerButton"..i]
		if not Achievement or (Achievement and Achievement.isSkinned) then return end

		SkinAchievement(Achievement.player)
		SkinAchievement(Achievement.friend)

		hooksecurefunc(Achievement.player, 'Saturate', function()
			if Achievement.player.accountWide then
				Achievement.player.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
				Achievement.friend.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
			else
				Achievement.player.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				Achievement.friend.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end
		end)
		
		Achievement.isSkinned = true
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)
	LoadSkin(event)
end)

S:RegisterSkin("Blizzard_AchievementUI", LoadSkin)